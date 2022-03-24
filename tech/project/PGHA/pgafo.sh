#!/bin/bash
#
# @CreationTime
#   2020/11/16 下午16:45:20
# @ModificationDate
#   2020/11/16 下午16:45:20
# @Function
#  初始化3个节点的PG10 HA环境
# @Usage
# 编译
# ../shc-3.8.7/shc  -v -r -T -f pgafo.sh
# @author Siu

# 节点名称	  角色或作用
# pg-node1	pg-service
# pg-node2	pg-service
# pg-node3	pg-service
# pg-afom	  pg-afo monitor

CURRENT_PATH=$(readlink -f "$(dirname "$0")")

# shellcheck source=src/
. "${CURRENT_PATH}"/config

#INNER_RANDOM_CODE=$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n'; echo)

## 返回码
### 操作用户错误
EX_USER_ERR=100

## 记录日志
log() {
  date_str=$(date "+%Y-%m-%d %H:%M:%S.%3N")
  echo "$(hostname -s)" ${date_str} $1
  echo "$(hostname -s)" ${date_str} $1 >>${CURRENT_PATH}/log
}

show_pgafo() {
  echo """
  ================================================
  #                 pgafo 工具                   #
  # 版本： 1.0.0                                 #
  # 作者： Siu                                   #
  # 支持： postgres 10,11,12                     #
  # GCC: (GNU) 4.8.5 20150623 (Red Hat 4.8.5-28) #
  ================================================

  """

  help
}

set_hosts() {
  >/etc/hosts
  echo '127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4' >>/etc/hosts
  echo '::1         localhost localhost.localdomain localhost6 localhost6.localdomain6' >>/etc/hosts
  for node in ${NODE_LIST}; do
    array=(${node//:/ })
    echo "${array[1]} ${array[0]}" >>/etc/hosts
  done
  log "设置主机 hosts"
}

add_ha_admin() {

  id ha-admin >&/dev/null
  if [ $? -ne 0 ]; then
    pass=$(openssl passwd -crypt ${HA_ADMIN_PASS})
    adduser -g root -p ${pass} ha-admin
    # 设置sudo
    chmod u+w /etc/sudoers
    echo 'ha-admin    ALL=(ALL)       NOPASSWD:ALL' >>/etc/sudoers
    chmod u-w /etc/sudoers
    log "添加 ha-admin 用户"
  fi
}

add_group() {
  usermod -a -G postgres ha-admin
}

close_firewall() {
  systemctl stop firewalld.service
  systemctl disable firewalld.service
  log "关闭 firewall"
}

close_SELinux() {
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  setenforce 0
  getenforce
  echo "关闭 SELinux"
}

config_auto_ssh() {
  log "配置$(whoami)到${NODE_LIST}免密"
  log "生成公钥和私钥，默认请回车继续。"
  ssh-keygen -t rsa
  for node in ${NODE_LIST}; do
    array=(${node//:/ })
    log "拷贝公钥到${array[0]}"
    ssh-copy-id -i ~/.ssh/id_rsa.pub $(whoami)@${array[0]}
  done

  #  if [[ $(hostname -s) == "${PG_AFOM_HOSTNAME}" ]]; then
  #    if [[ $1 != "local" ]]; then
  #      ssh-keygen -t rsa
  #      for node in ${NODE_LIST}; do
  #        array=(${node//:/ })
  #        if [[ $(hostname -s) != "${array[0]}" ]]; then
  #          ssh -T -l "$(whoami)" "${array[0]}" <<CMD
  #  cd /opt/PGHA
  #  ./pgafo -a
  #CMD
  #        fi
  #      done
  #    fi
  #  fi
}

uninstall_pg() {
  UNINSTALL_LIST='./uninstall.list'
  rm -f ${UNINSTALL_LIST}
  rpm -qa | grep 'postgres' >>${UNINSTALL_LIST}
  rpm -qa | grep 'pg-auto-failover' >>${UNINSTALL_LIST}

  cat ${UNINSTALL_LIST} | while read line; do
    log "正在卸载：${line}"
    rpm -e --nodeps ${line}
  done
  sudo rm -rf /usr/pgsql-1*
  log '卸载 pg 和 pg-auto-failover 环境'
}

backup_monitor_data() {
  check_root_user
  if [[ $(hostname -s) == "${PG_AFOM_HOSTNAME}" ]]; then
    backup_path=$(date "+%Y%m%d%H%M%S")
    sudo mkdir -p "${PGM_DATA_PATH}/../backup/${backup_path}"
    sudo chown -R postgres:postgres ${PGM_DATA_PATH}/../backup
    sudo pg_basebackup -U postgres -Ft -Pv -Xf -z -Z5 -p 5431 -D "${PGM_DATA_PATH}/../backup/${backup_path}"
    sudo cp -f "${PGM_DATA_PATH}/../backup/${backup_path}/base.tar.gz" "${PGM_DATA_PATH}/../backup/latest_backup.tar.gz"
    # 拷贝到其它节点
    for node in ${NODE_LIST}; do
      #echo "node_info ${node}"
      array=(${node//:/ })
      #echo ${array[0]}
      #echo ${array[1]}
      #echo ${array[2]}

      if [[ $(hostname -s) != "${array[0]}" ]]; then
        log "备份到[${node}]"
        ssh ${array[0]} sudo mkdir -p "${PGM_DATA_PATH}/../backup/${backup_path}"
        #ssh ${array[0]} sudo mkdir -p "${PGM_DATA_PATH}/../backup/latest"
        ssh ${array[0]} sudo chown -R postgres:postgres ${PGM_DATA_PATH}/../backup
        sudo scp "${PGM_DATA_PATH}/../backup/${backup_path}/base.tar.gz" $(whoami)@${array[0]}:"${PGM_DATA_PATH}/../backup/${backup_path}"
        #ssh ${array[0]} sudo cp -f "${PGM_DATA_PATH}/../backup/${backup_path}/base.tar.gz" "${PGM_DATA_PATH}/../backup/latest"
      fi
    done

    log "备份 monitor 数据"
  fi
  clean_old_backup_monitor_data
}

clean_old_backup_monitor_data() {
  #保留文件数
  ReservedNum=100
  FileDir=${PGM_DATA_PATH}/../backup/

  FileNum=$(ls -l $FileDir | grep 2 | wc -l)

  while (($FileNum > $ReservedNum)); do
    OldFile=$(ls -rt $FileDir | head -1)
    log "删除旧的备份数据:"${OldFile}
    rm -rf ${FileDir}/${OldFile}
    let "FileNum--"
  done
}

set_crontab_backup_monitor_data() {
  check_root_user
  echo "*/5  * * * * ${CURRENT_PATH}/pgafo -b" >>conf && crontab conf && rm -f conf
  log "设置定时备份 afo monitor 数据"
}

set_postgresql_conf() {
  if [[ $(hostname -s) != "${PG_AFOM_HOSTNAME}" ]]; then
    # 设置 max_connections
    # max_connections = 1024                  # (change requires restart)
    sed -i "s/max_connections = 100/max_connections = ${PG_CONF_MAX_CONNECTIONS}/g" ${PG_DATA_PATH}/postgresql.conf
    cat ${PG_DATA_PATH}/postgresql.conf | grep max_connections

    # 设置 wal log 相关参数
    sed -i "s/shared_buffers = 128MB/shared_buffers = ${PG_CONF_SHARE_BUFFER}/g" ${PG_DATA_PATH}/postgresql.conf
    cat ${PG_DATA_PATH}/postgresql.conf | grep shared_buffers
    # #checkpoint_completion_target = 0.5
    sed -i "s/#checkpoint_completion_target = 0.5/checkpoint_completion_target = ${PG_CONF_CHECKPOINT_COMPLETION_TARGET}/g" ${PG_DATA_PATH}/postgresql.conf
    cat ${PG_DATA_PATH}/postgresql.conf | grep checkpoint_completion_target
    # #checkpoint_timeout = 5min
    sed -i "s/#checkpoint_timeout = 5min/checkpoint_timeout = ${PG_CONF_CHECKPOINT_TIMEOUT}/g" ${PG_DATA_PATH}/postgresql.conf
    cat ${PG_DATA_PATH}/postgresql.conf | grep checkpoint_timeout
    # #min_wal_size = 80MB
    sed -i "s/#min_wal_size = 80MB/min_wal_size = ${PG_CONF_MIN_WAL_SIZE}/g" ${PG_DATA_PATH}/postgresql.conf
    cat ${PG_DATA_PATH}/postgresql.conf | grep min_wal_size
    # #max_wal_size = 1GB
    sed -i "s/#max_wal_size = 1GB/max_wal_size = ${PG_CONF_MAX_WAL_SIZE}/g" ${PG_DATA_PATH}/postgresql.conf
    cat ${PG_DATA_PATH}/postgresql.conf | grep max_wal_size
    # #wal_log_hints = off
    sed -i "s/#wal_log_hints = off/wal_log_hints = on/g" ${PG_DATA_PATH}/postgresql.conf
    cat ${PG_DATA_PATH}/postgresql.conf | grep wal_log_hints
    # #wal_level = replica
    sed -i "s/#wal_level = replica/wal_level = replica/g" ${PG_DATA_PATH}/postgresql.conf
    cat ${PG_DATA_PATH}/postgresql.conf | grep wal_level
    # #wal_keep_segments = 0
    sed -i "s/#wal_keep_segments = 0/wal_keep_segments = ${PG_CONF_WAL_KEEP_SEGMENTS}/g" ${PG_DATA_PATH}/postgresql.conf
    cat ${PG_DATA_PATH}/postgresql.conf | grep wal_keep_segments
    # #wal_compression = off
    sed -i "s/#wal_compression = off/wal_compression = on/g" ${PG_DATA_PATH}/postgresql.conf
    cat ${PG_DATA_PATH}/postgresql.conf | grep wal_compression

    log '设置 postgresql.conf'
  fi
}

install_pg() {
  rpm -ivh ${CURRENT_PATH}/pkg/postgresql${PG_VERSION}-libs-${PG_VERSION}.${PG_SUB_VERSION}-1PGDG.rhel7.x86_64.rpm
  rpm -ivh ${CURRENT_PATH}/pkg/postgresql${PG_VERSION}-${PG_VERSION}.${PG_SUB_VERSION}-1PGDG.rhel7.x86_64.rpm
  rpm -ivh ${CURRENT_PATH}/pkg/postgresql${PG_VERSION}-server-${PG_VERSION}.${PG_SUB_VERSION}-1PGDG.rhel7.x86_64.rpm
  rpm -ivh ${CURRENT_PATH}/pkg/postgresql${PG_VERSION}-contrib-${PG_VERSION}.${PG_SUB_VERSION}-1PGDG.rhel7.x86_64.rpm
  rpm -ivh ${CURRENT_PATH}/pkg/pg-auto-failover14_${PG_VERSION}-1.4.1-1.el7.x86_64.rpm
  log '安装 pg 和 pg-auto-failover 完成'
}

clean_old_afo() {
  sudo systemctl stop pg${PG_VERSION}-afom
  sudo systemctl stop pg${PG_VERSION}-afo
  sudo rm -rf /var/lib/pgsql/.config/pg_autoctl
  sudo rm -rf /var/lib/pgsql/.local/share/pg_autoctl
  sudo rm -rf ${PGM_DATA_PATH}
  #sudo rm -rf ${PGM_DATA_PATH}/../etcd
  sudo rm -rf ${PG_DATA_PATH}
  sudo rm -rf /etc/systemd/system/pg${PG_VERSION}-afom.service
  sudo rm -rf /etc/systemd/system/pg${PG_VERSION}-afo.service
  sudo rm -rf /root/.config/pg_autoctl${PGM_DATA_PATH}/pg_autoctl.cfg
  sudo systemctl daemon-reload
  log "清理旧的 pg-auto-failover 环境"
}

init_dir() {
  sudo mkdir -p ${PGM_DATA_PATH}
  sudo mkdir -p ${PGM_DATA_PATH}/../backup
  sudo mkdir -p ${PGM_DATA_PATH}/../backup/latest
  #sudo mkdir -p ${PGM_DATA_PATH}/../etcd
  sudo mkdir -p ${PG_DATA_PATH}
  sudo chown -R postgres:postgres /data
  sudo chown -R postgres:postgres /pgafo
  log "初始化目录"
}

check_opt_user() {
  if [[ $(whoami) != 'ha-admin' ]]; then
    log "WARN:执行失败，请使用ha-admin用户执行：su ha-admin"
    log "WARN:中止退出..."
    su ha-admin
    exit ${EX_USER_ERR}
  fi
  sudo chmod 766 -R ./log
}

check_root_user() {
  if [[ $(whoami) != 'root' ]]; then
    log "WARN:执行失败，请使用root用户执行"
    exit ${EX_USER_ERR}
  fi
}

if_server_exist_exit() {
  if [[ $(hostname -s) == "${PG_AFOM_HOSTNAME}" ]]; then
    exist=$(systemctl list-units | grep pg10-afom | wc -l)
    if [ ${exist} -ne 0 ]; then
      log "pg10-afom 服务存在，退出"
      exit 0
    fi
  else
    exist=$(systemctl list-units | grep pg10-afo | wc -l)
    if [ ${exist} -ne 0 ]; then
      log "pg10-afo 服务存在，退出"
      exit 0
    fi
  fi
}

run_pgafom() {
  if [[ $(hostname -s) == "${PG_AFOM_HOSTNAME}" ]]; then
    # 检查是否有 afom进程运行，有退出
    if_server_exist_exit
    sudo su postgres -c "/usr/pgsql-${PG_VERSION}/bin/pg_autoctl create monitor --auth trust --ssl-self-signed --pgdata ${PGM_DATA_PATH} --pgport ${PGM_PORT} --pgctl /usr/pgsql-${PG_VERSION}/bin/pg_ctl"
    for ips in ${PG_HBA_MD5}; do
      sudo su postgres -c "echo 'host    all             all             ${ips}         md5' >> ${PGM_DATA_PATH}/pg_hba.conf"
    done

    sudo su postgres -c "/usr/pgsql-${PG_VERSION}/bin/pg_autoctl -q show systemd --pgdata ${PGM_DATA_PATH} > ${PGM_DATA_PATH}/../pg${PG_VERSION}-afom.service"
    sudo mv ${PGM_DATA_PATH}/../pg${PG_VERSION}-afom.service /etc/systemd/system
    sudo systemctl daemon-reload
    sudo systemctl enable pg${PG_VERSION}-afom
    sudo systemctl start pg${PG_VERSION}-afom
    sudo systemctl status pg${PG_VERSION}-afom

    {
      echo "[pg_autoctl]"
      echo "role = monitor"
      echo "hostname = pg-afom"
      echo ""
      echo "[postgresql]"
      echo "pgdata = ${PGM_DATA_PATH}"
      echo "pg_ctl = /usr/pgsql-${PG_VERSION}/bin/pg_ctl"
      echo "username = autoctl_node"
      echo "dbname = pg_auto_failover"
      echo "port = ${PGM_PORT}"
      echo "listen_addresses = *"
      echo "auth_method = trust"
      echo ""
      echo "[ssl]"
      echo "sslmode = require"
      echo "active = 1"
    } >>~/pg_autoctl.cfg
    sudo mkdir -p /root/.config/pg_autoctl${PGM_DATA_PATH}/
    sudo mv ~/pg_autoctl.cfg /root/.config/pg_autoctl${PGM_DATA_PATH}/
    # 等待pg 节点启动
    #sleep 10
    show_nodes
    #show_uri
    log "查看复制：/usr/pgsql-${PG_VERSION}/bin/pg_autoctl show state --pgdata ${PGM_DATA_PATH}"
    log '初始化 pg-auto-failover monitor'
    #else
    # 让monitor服务先启动
  #  sleep 5
  fi

}

run_pgafo() {
  if [[ $(hostname -s) != "${PG_AFOM_HOSTNAME}" ]]; then
    if_server_exist_exit
    sudo su postgres -c "/usr/pgsql-${PG_VERSION}/bin/pg_autoctl create postgres --pgdata ${PG_DATA_PATH} --pgport ${PG_PORT} --auth trust --ssl-self-signed --name $(hostname -s) --username postgres --hostname $(hostname -s) --pgctl /usr/pgsql-${PG_VERSION}/bin/pg_ctl --monitor 'postgres://autoctl_node@${PG_AFOM_HOSTNAME}:${PGM_PORT}/pg_auto_failover?sslmode=require'"
    for ips in ${PG_HBA_MD5}; do
      sudo su postgres -c "echo 'host    all             all             ${ips}         md5' >> ${PG_DATA_PATH}/pg_hba.conf"
    done
    sudo su postgres -c "/usr/pgsql-${PG_VERSION}/bin/pg_autoctl -q show systemd --pgdata ${PG_DATA_PATH} > ${PG_DATA_PATH}/pg${PG_VERSION}-afo.service"

    sudo mv ${PG_DATA_PATH}/pg${PG_VERSION}-afo.service /etc/systemd/system
    sudo systemctl daemon-reload
    sudo systemctl enable pg${PG_VERSION}-afo
    sudo systemctl start pg${PG_VERSION}-afo
    sudo systemctl status pg${PG_VERSION}-afo
    log '初始化 pg-auto-failover node'
  fi

}

load_install_package() {
  log "分发安装包到其它节点"
  #rm -fr !(pgafo.sh|config|pkg)
  #ln -s ${CURRENT_PATH}/pgafo /usr/bin/pgafo
  #ln -s ${CURRENT_PATH}/config /usr/bin/config
  #ln -s ${CURRENT_PATH}/pkg /usr/bin/pkg
  for node in ${NODE_LIST}; do
    array=(${node//:/ })
    if [[ $(hostname -s) != "${array[0]}" ]]; then
      ssh ${array[0]} mkdir -p /opt/PGHA
      scp -r ${CURRENT_PATH}/pgafo $(whoami)@${array[0]}:/opt/PGHA
      scp -r ${CURRENT_PATH}/config $(whoami)@${array[0]}:/opt/PGHA
      scp -r ${CURRENT_PATH}/pkg $(whoami)@${array[0]}:/opt/PGHA
      ssh ${array[0]} chmod +x /opt/PGHA/pgafo
      #ssh ln -s /opt/PGHA/pgafo /usr/bin/pgafo
      #ssh ln -s /opt/PGHA/config /usr/bin/config
      #ssh ln -s /opt/PGHA/pkg /usr/bin/pkg
    fi
  done
}

init_hosts() {
  check_root_user
  set_hosts
  close_firewall
  close_SELinux
  add_ha_admin
  if [[ $(hostname -s) == "${PG_AFOM_HOSTNAME}" ]]; then
    if [[ $1 != "local" ]]; then
      load_install_package
      for node in ${NODE_LIST}; do
        array=(${node//:/ })
        if [[ $(hostname -s) != "${array[0]}" ]]; then
          ssh -T -l "$(whoami)" "${array[0]}" <<CMD
  cd /opt/PGHA
  ./pgafo -p
CMD
        fi
      done
    fi
  fi

}

clean_env() {
  check_root_user

  #echo "arg1="$1
  if [[ $1 == 'cZyRZs817JsBpHnizNMgtg2niZrBpd' ]]; then
    clean_old_afo
    uninstall_pg
  else
    while true; do
      code=$(
        strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 4 | tr -d '\n'
        echo
      )
      read -r -p "[$(hostname -s)] 清理旧afo环境，将卸载清除数据，确定继续吗？ [请输入 ${code} 继续，no 退出] " input
      case $input in
      ${code})
        clean_old_afo
        uninstall_pg
        break
        ;;

      [nN][oO] | [nN])
        exit 1
        ;;

      *)
        echo "Invalid input..."
        ;;
      esac
    done
  fi

  if [[ $(hostname -s) == "${PG_AFOM_HOSTNAME}" ]]; then
    if [[ $1 != "local" ]]; then
      for node in ${NODE_LIST}; do
        array=(${node//:/ })

        if [[ $(hostname -s) != "${array[0]}" ]]; then
          #log "清理旧[${array[0]}]afo环境，将卸载清除数据"
          ssh -T -l "$(whoami)" "${array[0]}" <<CMD
  cd /opt/PGHA
  ./pgafo -c cZyRZs817JsBpHnizNMgtg2niZrBpd
CMD
        fi
      done
    fi
  fi
}

install_afo() {
  check_root_user

  if [[ $1 == 'cZyRZs817JsBpHnizNMgtg2niZrBpd' ]]; then
    install_pg
    add_group
    init_dir
  else
    while true; do
      code=$(
        strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 4 | tr -d '\n'
        echo
      )
      read -r -p "[$(hostname -s)] 初始化afo基础环境，会重新安装afo并初始化相关目录，确定继续吗？ [请输入 ${code} 继续，no 退出] " input
      case $input in
      ${code})
        install_pg
        add_group
        init_dir
        break
        ;;

      [nN][oO] | [nN])
        exit 1
        ;;

      *)
        echo "Invalid input..."
        ;;
      esac
    done
  fi
  # 定时备份数据
  #
  # set_crontab_backup_monitor_data

  if [[ $(hostname -s) == "${PG_AFOM_HOSTNAME}" ]]; then
    if [[ $1 != "local" ]]; then
      for node in ${NODE_LIST}; do
        array=(${node//:/ })
        if [[ $(hostname -s) != "${array[0]}" ]]; then
          ssh -T -l "$(whoami)" "${array[0]}" <<CMD
  cd /opt/PGHA
  ./pgafo -i cZyRZs817JsBpHnizNMgtg2niZrBpd
CMD
        fi
      done
    fi
  fi
}

run_afo() {
  check_opt_user
  run_pgafom
  run_pgafo

  if [[ $(hostname -s) == "${PG_AFOM_HOSTNAME}" ]]; then
    if [[ $1 != "local" ]]; then
      for node in ${NODE_LIST}; do
        array=(${node//:/ })
        if [[ $(hostname -s) != "${array[0]}" ]]; then
          ssh -T -l "$(whoami)" "${array[0]}" <<CMD
  cd /opt/PGHA
  ./pgafo -r
CMD
        fi
      done
    fi
  fi

  show
}

drop_node() {
  if [[ $(hostname -s) == "${PG_AFOM_HOSTNAME}" ]]; then
    while true; do
      read -r -p "删除节点[$1]，确定继续吗？ [yes/no] " input
      case $input in
      [yY][eE][sS] | [yY])
        show_nodes
        sudo /usr/pgsql-${PG_VERSION}/bin/pg_autoctl drop node --hostname $1 --pgport ${PG_PORT} --pgdata ${PGM_DATA_PATH}
        show_nodes
        exit 0
        ;;

      [nN][oO] | [nN])
        exit 1
        ;;

      *)
        echo "Invalid input..."
        ;;
      esac
    done

  else
    log "非 Monitor 节点不能执行 drop node 命令"

  fi
}

show() {
  if [[ $(hostname -s) != "${PG_AFOM_HOSTNAME}" ]]; then
    log "非 Monitor 节点不能执行 show 命令"
    exit 0
  fi
  show_nodes
  show_uri
  show_file
  show_settings
}

perform_switchover() {
  if [[ $(hostname -s) == "${PG_AFOM_HOSTNAME}" ]]; then
    while true; do
      read -r -p "主动触发故障转移，确定继续吗？ [yes/no] " input
      case $input in
      [yY][eE][sS] | [yY])
        show_nodes
        sudo /usr/pgsql-${PG_VERSION}/bin/pg_autoctl perform switchover --pgdata ${PGM_DATA_PATH}
        show_nodes
        exit 0
        ;;

      [nN][oO] | [nN])
        exit 1
        ;;

      *)
        echo "Invalid input..."
        ;;
      esac
    done
  else
    log "非 Monitor 节点不能执行 perform switchover 命令"
  fi

}

show_server_log() {
  if [[ $(hostname -s) == "${PG_AFOM_HOSTNAME}" ]]; then
    sudo journalctl -u pg10-afom.service --since today
  else
    sudo journalctl -u pg10-afo.service --since today
  fi
}

show_nodes() {
  if [[ $(hostname -s) != "${PG_AFOM_HOSTNAME}" ]]; then
    log "非 Monitor 节点不能执行 show state 命令"
    exit 0
  fi

  log "查看节点状态"
  if [[ $(hostname -s) == "${PG_AFOM_HOSTNAME}" ]]; then
    sudo /usr/pgsql-${PG_VERSION}/bin/pg_autoctl show state --pgdata ${PGM_DATA_PATH}
  else
    sudo ssh ${PG_AFOM_HOSTNAME} /usr/pgsql-${PG_VERSION}/bin/pg_autoctl show state --pgdata ${PGM_DATA_PATH}
  fi

  if [ -z "$1" ]; then
    sleep 0
  else
    sleep $1
    clear
    show_nodes $1
  fi
}

show_uri() {
  if [[ $(hostname -s) == "${PG_AFOM_HOSTNAME}" ]]; then
    sudo su postgres -c "/usr/pgsql-${PG_VERSION}/bin/pg_autoctl show uri --formation default --pgdata ${PGM_DATA_PATH}"
  else
    sudo ssh ${PG_AFOM_HOSTNAME} /usr/pgsql-${PG_VERSION}/bin/pg_autoctl show uri --formation default --pgdata ${PGM_DATA_PATH}
  fi
}

show_file() {
  if [[ $(hostname -s) == "${PG_AFOM_HOSTNAME}" ]]; then
    sudo /usr/pgsql-${PG_VERSION}/bin/pg_autoctl show file --pgdata ${PGM_DATA_PATH}
  else
    sudo ssh ${PG_AFOM_HOSTNAME} /usr/pgsql-${PG_VERSION}/bin/pg_autoctl show file --pgdata ${PGM_DATA_PATH}
  fi
}

show_settings() {
  if [[ $(hostname -s) == "${PG_AFOM_HOSTNAME}" ]]; then
    sudo /usr/pgsql-${PG_VERSION}/bin/pg_autoctl get formation settings --pgdata ${PGM_DATA_PATH}
  else
    sudo ssh ${PG_AFOM_HOSTNAME} /usr/pgsql-${PG_VERSION}/bin/pg_autoctl get formation settings --pgdata ${PGM_DATA_PATH}
  fi
}

enable_maintenance_node() {
  if [[ $(hostname -s) != "${PG_AFOM_HOSTNAME}" ]]; then
    status=$(sudo su - postgres -c "psql -At -c 'select  pg_is_in_recovery();'")
    if [ $status == "t" ]; then
      log "开始维护 $(hostname -s) ，当前节点为 Secondary"
      sudo su postgres -c "/usr/pgsql-${PG_VERSION}/bin/pg_autoctl enable maintenance --pgdata ${PG_DATA_PATH}"
    else
      log "开始维护 $(hostname -s) ，当前节点为 Primary"
      sudo su postgres -c "/usr/pgsql-${PG_VERSION}/bin/pg_autoctl enable maintenance --allow-failover --pgdata ${PG_DATA_PATH}"
    fi
  else
    log "非PG节点，不能执行 maintenance 命令"
  fi
}

disable_maintenance_node() {
  if [[ $(hostname -s) != "${PG_AFOM_HOSTNAME}" ]]; then
    sudo su postgres -c "/usr/pgsql-${PG_VERSION}/bin/pg_autoctl disable maintenance --pgdata ${PG_DATA_PATH}"
  else
    log "非PG节点，不能执行 maintenance 命令"
  fi
}


set_sync_standby_number() {
   if [[ $(hostname -s) == "${PG_AFOM_HOSTNAME}" ]]; then
    sudo /usr/pgsql-${PG_VERSION}/bin/pg_autoctl set formation number-sync-standbys $1 --pgdata ${PGM_DATA_PATH}
  else
    log "非Monitor节点，不能执行 set formation number-sync-standbys 命令"
  fi
}

set_replication_quorum() {
   if [[ $(hostname -s) == "${PG_AFOM_HOSTNAME}" ]]; then
    sudo /usr/pgsql-${PG_VERSION}/bin/pg_autoctl set node replication-quorum $1 --name $2 --pgdata ${PGM_DATA_PATH}
  else
    log "非Monitor节点，不能执行 set node replication-quorum 命令"
  fi
}

################################################
# Monitor SPOF solution

install_keepalived() {
  log "安装 keepalived"
}

is_master_afom() {
  journalctl -u keepalived | grep 'Entering' | grep 'STATE'
  master_flag=$(journalctl -u keepalived | grep 'Entering' | grep 'STATE' | tail -1 | grep 'Entering MASTER STATE')
  process_num=$(ps -ef | grep postgres | grep monitor | grep -c "${PGM_PORT}")
  if [ ${master_flag} -ne 0 ]; then
    log "pg10-afom 主节点"
    if [ "$process_num" -eq 0 ]; then
      systemctl start pg10-afom
      log "systemctl start pg10-afom"
    fi
  else
    log "pg10-afom 备用节点"
    if [ "$process_num" -ne 0 ]; then
      systemctl stop pg10-afom
      log "systemctl stop pg10-afom"
    fi

  fi
  systemctl status pg10-afom

}

install_pgafom_ha() {
  # 安装keepalived
  install_keepalived
  # 安装 pg-afom
  init_hosts local
  install_afo local
  run_afo local

}

################################################

help() {
  echo """
Usage: ./pgafo -p
       ./pgafo -s
       ./pgafo -l
       ./pgafo -c local
       ./pgafo -p -c -i
       ./pgafo -d pg-node5

Options:
  -a      设置当前用户 ssh 免密
  -p      初始化主机
  -c      清理旧 afo 环境（重装时需要，必须输入验证码二次确认）
  -i      安装 afo 基础环境（必须输入验证码二次确认）
  -r      启动 afo、afom
  -b      备份 afo monitor数据
  -n      查看节点信息
  -s      查看节点信息（节点情况、连接串、pg_autoctl 配置文件、节点配置）
  -d      删除节点（必须二次确认）
  -o      主动故障转移（必须二次确认）
  -g      设置 postgresql.conf（需要重启PG）
  -l      查看服务日志
  -m      维护节点
  -R      维护完成，启用节点
  -h      帮助信息
  -v      pgafo 工具版本信息

  """
}

#echo original parameters=[$@]

# https://www.jianshu.com/p/6393259f0a13
#-o或--options选项后面是可接受的短选项，如ab:c::，表示可接受的短选项为-a -b -c，
#其中-a选项不接参数，-b选项后必须接参数，-c选项的参数为可选的
#-l或--long选项后面是可接受的长选项，用逗号分开，冒号的意义同短选项。
#-n选项后接选项解析错误时提示的脚本名字
#ARGS=$(getopt -o ab:c:: --long along,blong:,clong:: -n "$0" -- "$@")
ARGS=$(getopt -o a::gmRlovhp::c::i::r::bsn::d: -n "$0" -- "$@")
if [ $? != 0 ]; then
  echo "参数错误，退出..."
  help
  exit 1
fi

#echo ARGS=[$ARGS]
#将规范化后的命令行参数分配至位置参数（$1,$2,...)
eval set -- "${ARGS}"
#echo formatted parameters=[$@]

while true; do
  case "$1" in
  -v)
    show_pgafo
    exit 0
    shift
    ;;
  -h)
    help
    exit 0
    shift
    ;;
  -g)
    set_postgresql_conf
    exit 0
    shift
    ;;
  -l)
    show_server_log
    exit 0
    shift
    ;;
  -m)
    enable_maintenance_node
    exit 0
    shift
    ;;
  -R)
    disable_maintenance_node
    exit 0
    shift
    ;;
  -a)
    config_auto_ssh $4
    shift 2
    ;;
  -p)
    init_hosts $4
    shift 2
    ;;
  -o)
    perform_switchover
    shift
    ;;
  -c)
    #echo "Option c,arg=$4"
    clean_env $4
    shift 2
    ;;
  -i)
    install_afo $4
    shift 2
    ;;
  -r)
    run_afo $4
    shift 2
    ;;
  -b)
    backup_monitor_data
    shift
    ;;
  -d)
    drop_node $2
    shift 2
    ;;
  -s)
    show
    shift
    ;;
  -n)
    show_nodes $4
    shift 2
    ;;
  --)
    shift
    break
    ;;
  *)
    help
    exit 1
    ;;
  esac
done

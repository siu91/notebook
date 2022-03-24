

**1、安装 MinIO Client**

```
wget https://dl.min.io/client/mc/release/linux-amd64/mc -P /usr/local/bin/
chmod +x /usr/local/bin/mc
```

**2、添加云存储**

```
# MinIO云存储
mc config host add minio http://192.168.5.149:9001 minio minio123 --api s3v4
```

**3、开始同步**

```
# 创建 bucket
mc mb minio/jenkins-backup
# 同步
mc mirror -w --overwrite --remove --exclude "caches/*" --exclude ".cache/*" --exclude ".git/*" --exclude "atomic*tmp" --exclude "*/cec-jpl/*" /var/jenkins_home minio/jenkins-backup

nohup mc mirror -w --overwrite --remove --exclude "caches/*" --exclude ".cache/*" --exclude ".git/*" --exclude "atomic*tmp" --exclude "*/cec-jpl/*" /var/jenkins_home minio/jenkins-backup > /var/jenkinssync.log 2>&1 &
```

设置开机自启

```shell
#修改成你需要实时同步备份的文件夹
backup="/var/jenkins_home"
#修改成你要备份到的存储桶
bucket="jenkins-backup"
#将以下代码一起复制到SSH运行
cat > /etc/systemd/system/minioc.service <<EOF
[Unit]
Description=minioc
After=network.target

[Service]
Type=simple
ExecStart=$(command -v mc) mirror -w --overwrite --remove --exclude "caches/*" --exclude ".cache/*" --exclude ".git/*" --exclude "atomic*tmp" --exclude "*/cec-jpl/*" ${backup} minio/${bucket}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
```

```shell
systemctl start minioc
systemctl enable minioc
```





**4、恢复**

```
# 从已准备的 image 恢复，原始未配置的 jenkins
docker save -o jenkins.tar jenkinsci/blueocean:latest
docker load < jenkins.tar
# 启动 jenkins
  docker run \
  --name jenkinsci-blueocean \
  -u root \
  -d \
  -p 49000:8080 \
  -p 50000:50000 \
  -v /home/jenkins:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /etc/localtime:/etc/localtime \
  jenkinsci/blueocean

# 备份 jenkins_home
cp -avx /var/jenkins_home /var/jenkins_home_bak
# 下载备份镜像
mc mirror minio/jenkins-backup /var/jenkins_home_config
# 修改配置：config.xml 中的 oauth 配置 
# 修改配置：jenkins.model.JenkinsLocationConfiguration.xml 中 jenkins URL
# 恢复到 jenkins_home
cp -r /var/jenkins_home_config/* /var/jenkins_home
```


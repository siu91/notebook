
### 保存镜像

```shell script
docker save image_id > image_file.tar
```

### 加载镜像
```shell script
docker load < image_file.tar
```

### 镜像打tag

```shell
docker tag image_id image_name
# 注：image_name格式为<仓库地址>/<项目名称>/<镜像名称>:<标签>
# 例：docker tag bf756fb1ae65 core.harbor.domain:30147/library/hellp-world:v1.0.0
```

### 删除镜像

```shell
docker rmi image_id
# 强制删除
docker rmi -f image_id
```

### 登录Harbor

```shell
docker login -u admin -p Harbor12345 core.harbor.domain:30147
```

### Push 镜像

```shell
docker push core.harbor.domain:30147/library/hellp-world:v1.0.0
```


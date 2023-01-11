## 设置 hosts

cat >> /etc/hosts << EOF
192.168.5.151 minio-1
192.168.5.150 minio-2
192.168.5.149minio-3
EOF

## 安装 minio 集群
docker run -d --name minio \
  --restart=always --net=host \
  -e MINIO_ACCESS_KEY=minio \
  -e MINIO_SECRET_KEY=minio123 \
  -v minio-data1:/data/miniodata1 \
  -v minio-data2:/data/miniodata2 \
  minio/minio server \
  --address 192.168.5.151:9000 \
  http://minio-{1...3}/data/miniodata{1...2}

  docker run -d --name minio \
  --restart=always --net=host \
  -e MINIO_ACCESS_KEY=minio \
  -e MINIO_SECRET_KEY=minio123 \
  -v minio-data1:/data/miniodata1 \
  -v minio-data2:/data/miniodata2 \
  minio/minio server \
  --address 192.168.5.150:9000 \
  http://minio-{1...3}/data/miniodata{1...2}



docker run -d --name minio \

  --restart=always --net=host \
  -e MINIO_ACCESS_KEY=minio \
  -e MINIO_SECRET_KEY=minio123 \
  -v minio-data1:/data/miniodata1 \
  -v minio-data2:/data/miniodata2 \
  minio/minio server \
  --address 192.168.5.149:9000 \
  http://minio-{1...3}/data/miniodata{1...2}


  ## 配置负载均衡

  upstream minio_server {
    server 192.168.5.151:9000;
    server 192.168.5.150:9000;
    server 192.168.5.149:9000;
    }

server {
    listen 9001;
    server_name  localhost;
    ignore_invalid_headers off;
    client_max_body_size 0;
    proxy_buffering off;
    location / {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $http_host;
        proxy_connect_timeout 300;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        chunked_transfer_encoding off;
        proxy_pass http://minio_server;
    }
}
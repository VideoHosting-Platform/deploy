#!/bin/bash

# Директории
LOCAL_DIR="/tmp/videos"
VIDEO_BUCKET="videos"
HLS_BUCKET="video-files"
mkdir -p $LOCAL_DIR

# 144p
wget https://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4 -P $LOCAL_DIR
# 240p
wget https://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_640x360.m4v -P $LOCAL_DIR
# 360p
wget https://download.blender.org/peach/bigbuckbunny_movies/big_buck_bunny_480p_h264.mov    -P $LOCAL_DIR
# 480p
wget https://download.blender.org/peach/bigbuckbunny_movies/big_buck_bunny_480p_stereo.avi  -P $LOCAL_DIR
# 720p
wget https://download.blender.org/peach/bigbuckbunny_movies/big_buck_bunny_720p_stereo.avi -P $LOCAL_DIR
# 1K
wget https://download.blender.org/peach/bigbuckbunny_movies/big_buck_bunny_1080p_stereo.avi -P $LOCAL_DIR
# 2K
wget https://download.blender.org/demo/movies/BBB/bbb_sunflower_2160p_60fps_normal.mp4.zip -P $LOCAL_DIR
unzip -j bbb_sunflower_2160p_60fps_normal.mp4.zip -d "$LOCAL_DIR"
rm tmp/videos/bbb_sunflower_2160p_60fps_normal.mp4.zip
# 4K
wget https://upload.wikimedia.org/wikipedia/commons/c/c0/Big_Buck_Bunny_4K.webm -P $LOCAL_DIR


mc alias set kubemc $(minikube service -n minio minio --url | head -n 1) minioadmin minioadmin

# Загрузка в MinIO
mc cp --recursive $LOCAL_DIR/ kubemc/$VIDEO_BUCKET
echo "Видео успешно загружены в MinIO"

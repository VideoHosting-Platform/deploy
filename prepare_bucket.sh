#!/bin/bash

# Директории
LOCAL_DIR="tmp/videos"
MINIO_BUCKET="kubemc/videos"
mkdir -p $LOCAL_DIR

# Скачивание видео в 4K 2K 1K 720p 480p 360p 240p 144p
# Требуемые форматы: mp4, mov, wmv, avi, avchd, flv, f4v, mkv, webm
# Загружаются здесь: mp4, mov, avi, webm



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


export PATH=$PATH:$HOME/minio-binaries/
mc alias set minio http://localhost:9000 minioadmin minioadmin

# Загрузка в MinIO
mc mb $MINIO_BUCKET
mc cp --recursive $LOCAL_DIR/ $MINIO_BUCKET

echo "Видео успешно загружены в MinIO"

# # Скачиваем все видео файлы с сайта (используем wget)
# wget -r -np -nd -A "*.mp4,*.avi,*.mov,*.mkv" https://download.blender.org/peach/bigbuckbunny_movies/

# # Или если нужно скачать конкретные файлы:
# wget https://download.blender.org/peach/bigbuckbunny_movies/big_buck_bunny_720p_stereo.ogg

# # и т.д.

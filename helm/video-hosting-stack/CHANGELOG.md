# Changelog

## [0.1.10] - 18.06.25
### Added
- Плеер(files/palyer.html). Полностю работает, корректно меняет качество.
- Добавлен путь до плеера - /player?id={id}
- Открыт публичный доступ на скачивание из бакета videos и httproute в traefik для этого бакета
- 
### Fixed
- Путь до страница загрузки / -> /upload-video
- Изменена структура templates/. Добавлены папки jobs/ и traefik-routes/ для структурирования

## [0.1.11] - 20.06.26
### Added
- Вынес hook delete policy для minio в values.yaml
- Добавил двойную политику удаления для pre-install-crd.yaml

### Fixed
- Прошелся по всем файлам, убрал везде namespace: default где было
- Поменял права для video-service в rabbitmq на всякий случай, а то что-то не работает
- Добавил persistence true в дефолтных настройках
- Поменял все ссылки в dependencies на общий регистри

## [0.1.12] - 20.06.26
### Added
- Добавлена новая страница - список видео. Доступна по /
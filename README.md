# inium/docker-php

본 Branch는 Laravel용 입니다. 일반 PHP 프로젝트는 master 브랜치를 참조해주세요.

PHP Docker 공식 이미지에 추가 패키지를 포함한 Dockerfile과 실행을 위해 구현된 환경설정 프로젝트 입니다.

## 개요

PHP Docker 공식 이미지 중 [php:7.4.4-fpm](https://hub.docker.com/layers/php/library/php/7.4.4-fpm/images/sha256-215232c33da867319f013815a8e136d4a7380ff0dafc286c11e33e80356d5a43?context=explore)을 이용해 추가 패키지를 포함한 Dockerfile 구성과 실행을 위한 환경설정을 구현하였습니다.

## 구성

### 환경 변수

본 프로젝트는 아래 2개의 동작 환경에 사용되는 환경 변수를 사용합니다.

- DOCKER_ENV: 운영 모드. development, production 중 1이며 기본값은 development.

### 동작 환경 Mode

본 프로젝트는 DOCEKR_ENV 값을 참조해 개발(development)모드와 운영(production)모드 2가지로 동작합니다. DOCKER_ENV 값이 development면 개발, production면 운영 모드로 동작하며 기본값은 development 입니다.

실행 시 컨테이너(Container) 내부에 저장된 `run.sh` (원본: [docker-run.sh](/docker-run.sh)) 를 실행하며 아래와 같이 동작합니다.

- Development mode
  - `php` 명령어를 이용한 built-in 서버를 이용해 동작.
  - Xdebug 활성화

- Production mode
  - `php-fpm` 명령어 실행
  - Xdebug 활성화 되지 않음

### Ports

Port는 80, 9000 번 2가지를 사용합니다.

- 80번: development, production 웹 서버용으로 사용.
  - development: `php` 명령어를 이용한 built-in server 실행
  - production: `php-fpm` 명령어 실행. php-fpm 에서 사용하는 기본 Port는 9000번이나 xdebug에서 사용하는 Port 번호와 혼동되지 않도록 80번으로 강제 변경하여 사용하도록 설정.
- 9000번: Xdebug 용으로 사용.

### Volumes

아래의 Volume들을 설정하여 사용합니다.

- /var/www/html: 웹 서버 Root
- /usr/local/etc/php/conf.d/php.ini: PHP 환경설정 파일. [php.ini](/php.ini) 참조.

### 기타

- php 패키지 설치를 위한 `composer` 전역 설치
- 패키지 미러사이트를 Kaist(ftp.kaist.ac.kr)로 변경 가능하도록 Dockerfile내 추가
  - [Dockerfile](/Dockerfile) 내 주석처리
  - 필요시(한국서버 사용 or Local 개발용으로 사용 시 속도향상을 위해 사용 등) 주석해제 후 `docker build` 하여 사용 가능.

## 사용 방법

본 프로젝트의 실행 환경 설정은 `docker-compose.yml`에 정의하였습니다.

### 1. Clone

```bash
sudo git clone https://github.com/inium/docker-php.git /path/to
```

### 2. 실행

```bash
sudo docker-compose up -d
```

## 추가 설정

### Visual Studio Code에서 Xdebug 설정

개발(Development) 모드에서 Xdebug 사용이 가능합니다. Visual Studio Code에서 Xdebug 설정은 아래와 같습니다.

- 참고: <https://stackoverflow.com/questions/52579102/debug-php-with-vscode-and-docker>

### launch.json

```bash
{
    "version": "0.2.0",
    "configurations": [
        {
        "name": "Listen for XDebug",
        "type": "php",
        "request": "launch",
        "port": 9000,
        "log": true,
        "externalConsole": false,
        "pathMappings": {
            "/var/www/html": "${workspaceRoot}",
        },
        "ignore": [
            "**/vendor/**/*.php"
        ]
    }]
}
```

`launch.json`의 생성은 Run View의 Configure gear icon(톱니 아이콘)으로 생성이 가능합니다.

- 참조: <https://code.visualstudio.com/docs/editor/debugging>

컨테이너(Container)의 xdebug 설정은 컨테이너로 실행 시 실행되는 `run.sh` (원본: [docker-run.sh](/docker-run.sh)) 파일 내에 정의되어 있습니다.

### Production 모드에서 NginX 설정

운영(Production) 모드에서 사용 시 NginX를 이용할 경우 fastcgi를 이용하며 아래와 같이 적용해야 합니다.

- 참고: <https://stackoverflow.com/questions/44706951/nginx-to-serve-php-files-from-a-different-server>

```bash
server {
    ...

    root {STATIC-FILES-LOCATION};
    index index.php index.html;

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass {PHP-FPM-SERVER}:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```

- {STATIC-FILES-LOCATION}: Container 내 소스코드 저장 경로로(Document Root) 본 프로젝트는 /var/www/html/public 경로. NginX 컨테이너에 해당 volume이 공유되어 있어야 함.
- {PHP-FPM-SERVER}: 컨테이너(Container)의 이름 or IP 주소

## License

MIT

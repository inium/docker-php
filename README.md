# inium/docker-php

PHP Docker 공식 이미지에 추가 패키지를 포함한 Dockerfile과 실행을 위해 구현된 프로젝트 입니다.

## 개요

PHP Docker 공식 이미지 중 [php:7.4.4-fpm](https://hub.docker.com/layers/php/library/php/7.4.4-fpm/images/sha256-215232c33da867319f013815a8e136d4a7380ff0dafc286c11e33e80356d5a43?context=explore)을 이용해 추가 패키지를 포함한 Dockerfile 구성과 실행을 위한 환경설정을 구현하였습니다.

## 구성

### 환경 변수

본 프로젝트는 아래 2개의 동작 환경에 사용되는 환경 변수를 사용합니다.

- DOCKER_ENV: 운영 모드. development / production 중 1이며 기본값은 development.
- DOCKER_LARAVEL: [Laravel](https://laravel.com) 프레임워크 사용 여부. true / false 중 1이며 기본값은 false.

### 동작 환경

아래와 같이 환경 변수에 따라 동작 환경이 변경됩니다.

#### 운영 모드

본 프로젝트는 DOCEKR_ENV 환경변수 값을 참조해 개발(development)모드와 운영(production)모드 2가지로 동작합니다. DOCKER_ENV 환경변수 값이 development면 개발, production면 운영 모드로 동작하며 기본값은 development 입니다.

실행 시 컨테이너(Container) 내부에 저장된 `run.sh` (원본: [docker-run.sh](/docker-run.sh)) 를 실행하며 아래와 같이 동작합니다.

- development
  - `php` 명령어를 이용해 built-in 서버 동작.
  - Xdebug 활성화

- production
  - `php-fpm` 명령어 실행
  - Xdebug 활성화 되지 않음

#### Laravel 사용 여부

development 모드에서 DOCKER_LARAVEL 환경변수 값을 true로 하면 Laravel 프레임워크 실행이 가능합니다. 기본 값은 false 입니다.

- DOCKER_LARAVEL 환경변수 값을 true로 하여 실행 시 /public 디렉터리 파일을 실행합니다. Laravel 뿐만 아니라 /public 디렉터리에 실행파일이 있는 프로젝트인 경우 true로 설정하여 사용 가능합니다.

production 모드일 경우 nginx 환경설정 파일의 Root 지시자(Directive)의 값을 Laravel 실행 디렉터리인 /var/www/html/public로 수정하여 사용해야 합니다([Production 모드에서 NginX 설정](#production-모드에서-nginx-설정) 참조)

### Ports

Port는 80, 9000 번 2가지를 사용합니다.

- 80번: development, production 웹 서버용으로 사용.
  - development: `php` 명령어를 이용한 built-in server 실행
  - production: `php-fpm` 명령어 실행. **php-fpm 에서 사용하는 기본 Port는 9000번이나 xdebug에서 사용하는 Port 번호와 혼동되지 않도록 80번으로 강제 변경하여 사용하도록 설정.**
- 9000번: Xdebug 용으로 사용.

### Volumes

아래의 Volume들을 설정하여 사용합니다.

- /var/www/html: 웹 서버 Root.
- /usr/local/etc/php/conf.d/php.ini: PHP 환경설정 파일. [php.ini](/php.ini) 참조.

### 기타

- php 패키지 설치를 위한 `composer` 전역 설치
- 패키지 미러사이트를 Kaist(ftp.kaist.ac.kr)로 변경 가능하도록 Dockerfile내 추가
  - [Dockerfile](/Dockerfile) 내 주석처리
  - 필요시(한국서버 사용 or Local 개발용으로 사용 시 속도향상을 위해 사용 등) 주석해제 후 `docker build` 하여 사용 가능.

## 사용 방법

### 1. Clone this project

```bash
sudo git clone https://github.com/inium/docker-php.git /path/to
```

/path/to 는 프로젝트 저장 디렉터리 입니다.

### 2. Dockerfile build

Project를 Clone한 디렉터리에서 아래 명령어를 실행합니다.

```bash
docker build --tag inium/php:7.4.4-fpm .
```

### 3. 실행

#### 3-1. Docker Run 이용

일반 php 프로젝트일 경우(/var/www/html을 Root로 하는 경우), 아래의 명령어로 실행합니다.

```bash
sudo docker run -d \
            --name php \
            -p 10000:80 \
            -e DOCKER_ENV=development
            -v /path/to/html:/var/www/html \
            -v /path/to/php.ini:/usr/local/etc/php/conf.d/php.ini:ro
            inium/php:7.4.4-fpm
```

`-v` 옵션의 /path/to는 해당 파일이 존재하는 디렉터리 입니다.

- /path/to/html: 웹사이트 소스코드 저장경로
- /path/to/php.ini: php.ini 저장 경로. 위의 예시에서는 ro(read only)로 설정.

`-e` 옵션의 DOCKER_ENV 는 운영 모드를 설정하는 변수로 기본값은 development 입니다. production 모드로 실행할 경우 DOCKER_ENV 값을 production으로 변경합니다.

Laravel 프로젝트를 실행할 경우 아래와 같이 DOCKER_LARAVEL 환경변수를 true로 설정한 후 실행합니다(Laravel 뿐만 아니라 /var/www/html/public 디렉터리의 파일을 실행해야 하는 프로젝트에도 true로 설정).

```bash
sudo docker run -d \
            --name php \
            -p 10000:80 \
            -e DOCKER_ENV=development
            -e DOCKER_LARAVEL=true
            -v /path/to/html:/var/www/html \
            -v /path/to/php.ini:/usr/local/etc/php/conf.d/php.ini:ro
            inium/php:7.4.4-fpm
```

#### 3-2. Docker Compose 이용

본 프로젝트에는 `docker compose`를 이용해 실행할 수 있도록 docker-compose.yml이 정의되어 있으며 환경변수 입력을 위해 `.env`를 이용합니다. `.env` 파일의 구조는 아래와 같습니다.

```bash
DOCKER_ENV=development
DOCKER_LARAVEL=false
```

사용방법은 아래와 같습니다.

1. `.env.template` 파일을 `.env`로 복사 후 해당 정보 수정

```bash
sudo cp .env.template .env
```

2. `docker compose 실행`

```bash
docker-compose up -d
```

### 4. Laravel 프로젝트 생성

라라벨 프로젝트의 경우 아래의 명령어를 통해 프로젝트를 실행할 수 있습니다.

```bash
sudo docker-compose run --rm --service-ports php composer create-project --prefer-dist laravel/laravel .
```

위 명령어의 마지막 .은 Container에서 /var/www/html을 말하며 Host에서 ./html 디렉터리를 의미합니다.

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

- {STATIC-FILES-LOCATION}: Container 내 소스코드 저장 경로로 웹 서버 Root(/var/www/html) 입력.
  - Laravel을 사용할 경우 (DOCKER_LARAVEL 값이 true일 경우) /public 디렉터리의 파일을 실행하기 때문에 /var/www/html/public입력.
  - NginX Container에 해당 volume이 공유되어 있어야 함.
- {PHP-FPM-SERVER}: Container의 이름 or IP 주소

## License

MIT

# inium/docker-php

PHP Docker 공식 이미지에 추가 패키지를 포함한 Dockerfile과 실행을 위한 환경설정 입니다.

## 개요

[PHP Docker 공식 이미지](https://hub.docker.com/_/php)을 기반으로 추가 패키지를 포함한 Dockerfile 구성과 실행을 위한 `docker-compose` 환경설정 입니다.

## 구성

### Dockerfile

[php:7.4.4](https://hub.docker.com/layers/php/library/php/7.4.4/images/sha256-bfb6b2686209534d79c26597e7ef9e21a385ff6f2c2984c0ba3c9cf0b282ecff?context=explore)를 기반으로 하며 주요 내용은 아래와 같습니다.

- 패키지 미러사이트를 kaist(ftp.kaist.ac.kr)로 변경
- 추가 패키지 설치: Dockerfile 참조
- php 패키지 설치를 위한 `composer` 전역 설치
- `docker run`시 Bash Shell 실행

#### ports

80, 8000 번 포트를 노출(expose) 합니다. 8000 포트는 편의상 Laravel의 `php artisan serve` 명령어를 통해 개발용으로 사용하기 위해 지정하였습니다.

#### volumes

아래의 항목을 설정하여 사용합니다.

- /var/www/html: 웹 서버 Root
- /usr/local/etc/php/conf.d/php.ini: PHP 환경설정 파일이며 `php.ini` 참조

### docker-compose.yml

본 프로젝트의 설정을 저장한 파일이며 주요 내용은 아래와 같습니다. 사용 방법은 하단의 사용방법 항목을 참조 부탁드립니다.

#### ports

아래의 항목이 {외부}:{내부} 로 사용됩니다. 위에서 언급한 듯이 8000번 포트는 개발용으로 지정해 두었습니다. 필요할 경우, {외부} 포트를 변경하여 사용 가능합니다 ({내부} 포트를 변경하려면 Dockerfile의 EXPOSE 항목을 수정하면 됩니다).

- 10000:80
- 18000:8000

#### volumes

아래의 항목이 Host와 Container가 공유됩니다.

- ./html:/var/www/html
  - html 디렉터리는 PHP 어플리케이션이 저장되는 디렉터리입니다. 디렉터리를 바꾸고 싶을 경우 상대경로를 입력하여 지정합니다. ex) ../lorem/ipsum
- php.ini:/usr/local/etc/php/conf.d/php.ini:ro
  - PHP 환경설정 파일입니다. Container에서는 read-only 속성으로 사용합니다.

#### command

`docker-compose`를 실행하면 php 명령을 이용해 웹 어플리케이션을 실행합니다. `docker-compose run`명령을 이용해 실행할 경우 Service 이름 뒤에 명령어를 입력하면 이 command 항목은 무시됩니다.

#### working_dir

Container가 실행되면 설정되어 있는 /var/www/html 디렉터리에서 명령어(command)가 실행됩니다.

### php.ini

PHP 환경설정 파일입니다. 옵션은 [링크](https://www.php.net/manual/en/ini.list.php)의 참조를 부탁드립니다.

_cf. 옵션 적용 여부는 phpinfo() 참조 가능합니다._

## 사용방법

### 1. Clone this reponsitory

```bash
sudo git clone https://github.com/inium/docker-php.git /path/to
```

### 2. 실행

```bash
sudo docker-compose up -d
```

실행 시 `./html` 디렉터리 혹은 docker-compose.yml 내 volume에 웹 어플리케이션 디렉터리가 지정되어 있지않은 경우 자동으로 생성됩니다.

## 기타

### Laravel 프로젝트 생성

라라벨 프로젝트의 경우 아래의 명령어를 통해 프로젝트를 실행할 수 있습니다.

```bash
sudo docker-compose run --rm --service-ports php composer create-project --prefer-dist laravel/laravel .
```

위 명령어의 마지막 .은 Container에서 /var/www/html을 말하며 Host에서 ./html 디렉터리를 의미합니다.

### Port expose 관련

Reverse Proxy 를 사용할 경우 외부 접속을 위한 Port인 10000, 18000은 특별한 이유가 있지 않는 한 필요하지 않습니다. 이 경우 `docker-compose`파일을 이용해 실행한다면 Port 항목을 삭제한 후 실행하시면 됩니다.

## License

MIT

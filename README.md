# docker-apache2-php7-rewrite

apache2의 rewrite와 php7의 확장 모듈 설치가 적용된 dockerfile 입니다.

## 개요
Docker 공식 이미지인 [php7](https://hub.docker.com/_/php/) 의 php:7.1-apache 버전 이미지를 기반으로 제작된 apache2와 php7이 설정된 dockerfile 이며 아래의 참고 사이트의 내용을 기반으로 추가 모듈 설치 및 설정이 되어 있습니다.

참고 사이트
- [http://stackoverflow.com/questions/37527803/how-to-install-extension-for-php-via-docker-php-ext-install](http://stackoverflow.com/questions/37527803/how-to-install-extension-for-php-via-docker-php-ext-install)
- [https://hub.docker.com/_/php/](https://hub.docker.com/_/php/)

### OS
ubuntu:trusty를 기반으로 하며 아래의 추가 모듈 설치
- libfreetype6-dev, libjpeg62-turbo-dev, libmcrypt-dev, libpng12-dev, libicu-dev, libxml2-dev
- vim
- curl
- wget
- unzip
- git


### apache2
- /etc/apache2/apache2.conf의 servername localhost 추가
- /etc/apache2/apache2.conf의 Document Root(/var/www/html)의 AllowOverride 옵션을 All로 변환
- rewrite on

### php7
아래의 추가 확장 모듈 설치
- gd
- iconv
- intl
- xml
- soap
- mcrypt
- opcache
- pdo 
- pdo_mysql 
- mysqli 
- mbstring



## 사용방법

### Clone this repository

본 프로젝트를 Clone 하여 Local 에 저장합니다.

```
git clone https://github.com/edeun/
```

### Build dockerfile to docker image

Clone을 완료한 후, 아래와 같이 `docker build` 명령어를 이용해 이미지를 생성합니다.

```
docker build --tag apache2-php7 .
```
> --tag 뒤의 apache2-php7은 생성될 docker image의 이름이며 임의로 지정할 수 있습니다. 필요할 경우, apache2-php7:1.0 과 같이 docker image 이름 뒤에 버전을 명시할 수 있습니다.

### 실행

아래의 명령어와 같이 build된 docker image를 실행합니다.

```
docker run -d --name php7-test -p 10000:80 \
-v $(pwd)/examples/helloworld:/var/www/html apache2-php7 
```

-v 옵션 뒤 $(pwd)/example/helloworld는 본 프로젝트의 /example/helloworld 디렉터리 입니다. 

### With Database

본 프로젝트의 dockerfile을 이용해 build한 image로부터 생성한 컨테이너와 db 컨테이너를 연결하여 사용할 수 있으며 아래의 2가지 방법이 있습니다. 

아래의 내용에서 사용한 DB는 docker 공식 이미지 중 하나인 [mariadb](https://hub.docker.com/_/mariadb/)를 이용하였습니다. mariadb가 실행되고 있지 않을 경우, 공식 이미지의 설명에 기재된 명령어를 이용해 mariadb를 실행합니다.

```
docker run --name mariadb -e MYSQL_ROOT_PASSWORD='on!yf0rTe$t' -d mariadb
```

> *cf.* 비밀번호는 임의로 지정하였으며 단순 예시용입니다.

#### --link 옵션을 이용할 경우

```
docker run -d --name apache2-php7 -p 10000:80 --link mariadb:db \
-v $(pwd)/examples/database/link:/var/www/html apache2-php7
```

--link 옵션을 이용하면 실행된 컨테이너의 DB_ 로 시작하는 환경변수로 설정이 되며 컨테이너에 접속한 후 env 명령어를 통해 확인 가능합니다. 사용 예시는 `/examples/database/link` 를 참고하시기 바랍니다.

> *cf.* `docker exec -it apache2-php7 bash` 명령어를 이용해 실행중인 컨테이너에 접속할 수 있습니다. 

> *cf.* [Legacy container links](https://docs.docker.com/engine/userguide/networking/default_network/dockerlinks/) 의 내용에 따르면,  --link 버전은 점차 없어질(deprecated) 될 예정입니다 (Warning: The --link flag is a deprecated legacy feature of Docker 항목 참조).

#### container 이름을 이용할 경우 
--link 옵션이 점차 없어질 예정이기 때문에, docker에서는 컨테이너 이름을 이용해 상호간 통신이 가능하도록 지원하고 있으며 db를 연결할 때 host 이름으로 컨테이너 이름을 이용할 수 있습니다.(단, 컨테이너들은 같은 네트워크 브릿지 내에 있어야 합니다.)
```
docker run -d --name apache2-php7 -p 10000:80 --link mariadb:db \
-v $(pwd)/examples/database/network:/var/www/html apache2-php7
```

/examples/database/network 디렉터리의 index.php와 같이 host 이름을 db로 지정하여 사용할 수 있습니다.

### docker-compose를 이용하여 실행하기

`docker compose` 를 이용해 Database 와 본 프로젝트의 이미지, 그 외 다른 이미지와 같이 연결하여 사용할 수 있습니다. 본 프로젝트의 `/examples/docker_compose/docker-compose.yml` 파일을 아래의 명령어를 이용해 실행을 하면 mariadb, apache-php7, phpmyadmin이 동시에 실행됩니다.

```
docker-compose up -d
```

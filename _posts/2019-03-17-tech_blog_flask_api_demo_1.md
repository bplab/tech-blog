---
title: "Docker + Python  운영환경 정복하기 with Flask 1"
tags:
  - docker
  - docker-compose
  - python
  - flask
  - api
  - tutorial
---

안녕하세요 BlueprintLAB의 개발자 구상모 입니다.
첫 기술 블로그 포스팅을 하게 되었는데
Python의 웹 프레임워크인 Flask로 권한 및 인증 API Server 프로젝트를 만들어 보도록하겠습니다.

초보자도 쉽게 따라할 수 있도록 자세히 포스팅 할 것입니다!

그럼 천천히 하나하나씩 구현하도록 하겠습니다.

- - -
# Project Name
- flask-api-demo
- github: [https://github.com/bplab/flask_api_demo](https://github.com/bplab/flask_api_demo/tree/dee5f25aaa1e79de192675d1e5edc3daaefd1595)


---

## Chapter 1 - Docker Setting, Hello World

## 1. Git

첫번째로, Git을 Setting 해보도록 하겠습니다.  

> Git은 프로그램 등의 소스코드 관리를 위한 분산 버전 관리 시스템이다.  
(- Wikipedia -)

Git은 여러명의 개발자가 특정 프로젝트를 협업하여 개발하면서 버전 관리를 할 수 있는 시스템입니다.

본격적으로 프로젝트를 시작해보도록 하겠습니다.

- Git Repository를 만들고 .gitignore를 설정해줍니다.

- **.gitignore** : Git 버전 관리에서 제외할 디렉토리 혹은 파일의 목록을 적어놓은 파일입니다.
.gitignore를 설정하지 않으면 버전 관리에 필요없는 Data나 password 및 access key 등 중요한 데이터가 온라인상에 올라갈 수 있으므로 필수적으로 작성해야 합니다.

> 사용중인 OS와 IDE에 맞게 .gitignore를설정 할 수 있는 사이트 입니다.  
> **[www.gitignore.io](https://www.gitignore.io/)** 사이트 들어가서 검색창에 원하는 OS나 IDE 이름 입력 후 생성 버튼을 클릭하여 .gitignore를 작성 할 수 있습니다.
- - -

간단한 git Setting이 끝났습니다. git에 대한 자세한 설명은 [Git](https://git-scm.com/) 에서 확인하실 수 있습니다.

## 2. Docker
Docker를 알기 위해선 간단한 사전 설명이 필요합니다.

먼저 **Docker** 에 대해서 설명하겠습니다.

- Docker는 Linux의 container 기반의 오픈소스 가상화 플랫폼입니다. 쉽게 설명하자면 container를 만들고 사용할 수 있도록 하는 기술입니다.

그렇다면 **container** 는 무엇일까요?

- container 는 뜻 그대로 화물 수송용 박스를 생각하면 됩니다. container에 다양한 화물을 넣고 다양한 운송수단에 적재되어 쉽게 옮길 수 있는데 서버에서도 마찬가지입니다. 서버 실행에 필요한 모든 것(코드, 런타임, 시스템도구)들을 container에 넣어 쉽게 추상화하고 어디서에든(GCP, AWS, Local-machine) 실행할 수 있습니다.

**Docker** 를 사용하는 이유는 container를 활용하여 쉽게 개발환경과 운영환경을 동일하게 구성할 수 있기 때문입니다.

여기서 또 알아야 할 개념이 **docker image** 입니다.

- docker image는 container의 모든 정보를 포함한 하나의 단위로 볼 수 있습니다.
- *docker image와 conatiner의 차이점 설명*

이제 python image를 사용하여 docker container를 만들 것 입니다.  

> Docker에 대한 자세한 설명은 **[Docker](https://docs.docker.com/)** 에서 확인 하실 수 있습니다.

### 2-1 docker-compose.yml 작성
container를 실행하기 위해선 docker의 command 명령어인 docker run 을 사용하여 container를 생성하고 구동시킵니다.  
docker container를 동시에 여러개를 생성하여 구동하려면 어떻게 해야 할까요?

하나씩 docker run 명령어를 치는 것은 귀찮음과 더불어 생산성도 떨어지게 됩니다.
이러한 문제를 해결하기 위하여 **docker-compose** 를 사용합니다.

- docker-compose는 한번에 여러개의 container를 정의하고 실행시킬 수 있는
yml 형식의 설정 파일입니다

그러면 docker-compose를 사용해보도록 하겠습니다.

- 먼저 docker-compose.yml 파일을 작성합니다.

**docker-compose.yml 예제**
```
version: '3'

services:
  api:
    image: python:latest
    volumes:
      - ${proj_path}:/root/flask_api_demo
    working_dir: /root/flask_api_demo
```
- **version** : docker-compose.yml version을 정의합니다. yml 형식의 문법을 정의 합니다.
- **services** : docker container를 정의하는 부분입니다. 하나의 container를 하나의
service로 볼 수 있습니다.
- **api** : service 이름입니다. 예제에서는 api라는 이름의 service로
container를 구동하겠습니다. 임의로 service이름을 설정할 수 있습니다.
- **image** : docker의 image를 입력할 수 있습니다. docker image는 container의
모든 정보를 포함한 하나의 단위 입니다. 조금 더 쉽게 설명하자면 container의 snapshot을 의미합니다.
- **volumes** : container 상의 Data를 host machine과 공유하기 위한 기능입니다.
volumes는 *host_path:container_path* 로 값을 입력할 수 있습니다.
예제에 나와있는 ${proj_path} 부분은 잠시 후에 설명하도록 하겠습니다.
- **working_dir**: container의 working directory로 볼 수 있습니다.
예를들어 container의 bash shell은 정해준 directroy path에서 실행됩니다.

> docker compose 자세한 정보는 **[docker-compose](https://docs.docker.com/compose/compose-file/)** 에서 참고 하실 수 있습니다.  

### 2-2 run-docker-compose script 작성
- docker-compose.yml을 작성했으면 다음으로 container를 실행시켜야 합니다.
- docker-compose up 이라는 명령어를 사용해서   
docker container를 구동할 수 있으나 script를 작성하여 구동시켜보도록 하겠습니다.

**run-docker-compose script 예제**
```
#!/bin/sh

cd $(cd "$(dirname "$0")" && pwd)

# Create .env file
echo "proj_path=""$(pwd)" > .env

# Run docker-compose
docker-compose run --rm -p 5000:5000 api bash

```
- **#!/bin/sh** : shebang code입니다. script를 bash 혹은 sh에서 실행시킨다는 의미의
코드입니다.
- `cd $(cd "$(dirname "$0")" && pwd)` : script 파일의 현재 위치를 의미합니다.
ex) sehll의 pwd는 /foo 이면서 script 파일이 /foo/bar/script.sh 에 있는 경우
script 를 실행시켰을 때 shell의 path가 /foo가 아닌 /foo/bar
즉 script.sh가 위치한 path로 이동하게 됩니다.
- **echo "proj_path=""$(pwd)" > .env** : docker-compose.yml 예제의 volumes의 보면
{proj_path}:/root/flask_api_demo 가 있습니다.
volume의 host path의 의존성을 제거하기 위해 env 파일로 proj_path 값을
현재 디렉토리 path로 설정하였습니다.
- **docker-compose run \--rm -p 5000:5000 api bash** : Docker container를
구동시키는 명령어 입니다.
보통 docker-compose up의 명령어를 사용하지만 개발환경을 맞추기 위해 몇가지 옵션을 주었습니다.  
- *\--rm* : container의 프로세스가 끝나면 자동으로 container를 삭제하는 옵션입니다.  
- *-p* : docker container의 port 값을 설정합니다. host_port:container_port 로 입력합니다.  
- *api bash* : api는 docker-compose에 설정한 service 이름입니다.  
- bash는 api service container의 bash shell을 실행시킨다는 명령어입니다.

- **docker-compose 실행 화면**  

![docker-compose](/assets/images/2019-03-17-tech_blog_flask_api_demo_1/docker-compose.png)

이로써 Docker Setting이 끝났습니다. 다음으로는 본격적으로 Python을
docker container상에서 다뤄보도록 하겠습니다.
- - -

## 3. Installed python dependencies
python에서 필요한 dependencies를 정의하고 실제 설치를 해보도록 하겠습니다.  
앞으로 진행되는 script는 python container상에서 실행해야 합니다.

### 3-1 requirements.txt 작성
- **requirements.txt** : python project에서 필요한 package의 목록을 적은 파일입니다.
필요한 python package를 pip를 이용하여 한번에 설치할 수 있습니다.  

**requirements.txt 예제**

```
Flask
```

**Flask** 란? 파이썬에서 쓰이는 웹 프레임워크 입니다.  
간단한 웹이나 서버를 만들기에 적합한 웹 프레임워크로 가볍고 빠른속도가 장점입니다.

### 3-2 installed python dependencies script
- python dependencie를 설치하는 script를 작성하였습니다.

**install-python-dependencies script 예제**
```
#!/bin/sh

cd $(cd "$(dirname "$0")" && pwd)

rm -rf $(pwd)/venv && \
python3 -m venv venv && \
. venv/bin/activate && \
python3 -m pip install --upgrade pip && \
python3 -m pip install --trusted-host pypi.python.org -r $(pwd)/requirements.txt

```
- **#!/bin/sh** : 위 설명 참고  
- `cd $(cd "$(dirname "$0")" && pwd)` : 위 설명 참고
- **venv** : python 가상 환경을 만드는 모듈 입니다.
- **pip** : pip는 python의 package 라이브러리를 관리해주는 시스템입니다.
- **rm -rf $(pwd)/venv** : venv 및 하위 폴더를 모두 삭제 합니다. 기존에 남아있거나 혹은
docker volume 설정으로 생긴 기존의 venv를 삭제하고 requirements.txt에 있는 package
목록의 무결성을 보장합니다.
- **python -m venv venv** : venv 모듈로 venv 폴더에 python 가상환경을 만듭니다.
- **. venv/bin/activate** : Python 가상환경을 활성화 시키는 명령어입니다.
- **python3 -m pip install \--upgrade pip** : python package를 최신버전으로
업그레이드 합니다.
- **python3 -m pip install \--trusted-host pypi.python.org -r $(pwd)/requirements.txt**: \--trusted-host pypi.python.org는 SSL인증 오류를 해결하기 위한 명령어입니다. requirements에 있는 package를 설치합니다.

**install-python-dependencies sciprt 실행 화면**  

![install-python](/assets/images/2019-03-17-tech_blog_flask_api_demo_1/install-python.png)

**참고 Python library 설치 안될 시 Window Soft Symbolick link** 문제 해결
- window 10 이상부터 Guest OS의 shared folder를 symbolick link로 설정할 수 있습니다.
- 기본적으로 admin권한만 설정되어있으므로 수동으로 사용자에게 권한을 주어야 합니다.

```
1. window + R 버튼을 누른 후 secpol.msc 실행시킵니다.
2. 로컬 정책의 사용자 권한 할당을 선택 후 심볼릭 링크 만들기를 클릭합니다.
3. 사용자 또는 그룹 추가에 사용자를 추가합니다.

window home에서는 secpol.msc가 설치되어 있지 않습니다.
아래의 명령어를 입력해야 secpol.msc가 설치 됩니다.

echo "@echo off
pushd \"%~dp0\"

dir /b %SystemRoot%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientExtensions-Package~3*.mum >List.txt
dir /b %SystemRoot%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientTools-Package~3*.mum >>List.txt

for /f %%i in ('findstr /i . List.txt 2^>nul') do dism /online /norestart /add-package:\"%SystemRoot%\servicing\Packages\%%i\"
pause" > gpedit-enabler.bat

./gpedit-enabler.bat

```
- - -

## 4. Implemented Simple Api
자 드디어 본격적으로 python 코드를 진행하도록 하겠습니다.
flask를 사용하여 hello world를 화면에 띄우는 예제성 코드를 작성하도록 하겠습니다.

### 4-1 flask_api_demo/`__init__.py` 작성
- `__init__.py` 예제

```
from flask import Flask


def create_app():
    app = Flask(__name__)

    @app.route('/')
    def hello_world():
        return 'Hello, World!'

    return app

```

- `__init__.py`는 현재 directory가 python project의 package임을 나타냅니다.
이 directory에서 .py 확장자 파일은 python 모듈 입니다.
이로써 python코드를 좀더 계층적으로 나눌 수 있습니다.
- **from flask import Flask** :  flask라는 패키지에서 Flask 모듈을 import 해줌으로써  
flask를 사용할 수 있도록 설정하는 부분입니다.
- **def create_app():** : Flask instance를 생성하는 함수를 정의합니다.
- **app = Flask(`__name__`)** : app의 변수로 Flask 인스턴스를 정의합니다.
- **`__name__`** 은 python 명령어로 실행되었을 경우 `__main__`으로 인식되며
import 한 경우는 `__모듈이름__` 으로 인식됩니다.
- ` @app.route('/') ` : @app.route()는 데코레이터로써 Flask 어플리케이션에서 특정 URL로 요청이 올때  어떤 함수 실행을 시켜야할지 flask에게 알려줍니다.
- **def hello_world():** : 위의 예시코드에서 ` @app.route('/') ` 가 호출하는 함수입니다.
Flask 어플리케이션의 /로 접속하게 되면 hello_world() 함수의 return 'Hello, World' 값을 반환합니다.
- **return app** : Flask 인스턴스를 반환합니다.

### 4-2 run-flask-api script 작성
이번 포스팅에서는 실행관련 command를 모두 script화 한 것을 확인할 수 있습니다.
그러면 script 작성을 이어서 해보도록 하겠습니다.

- **run-flask-api scirpt 예제**

```
#!/bin/sh

cd $(cd "$(dirname "$0")" && pwd)

. venv/bin/activate

export FLASK_APP=flask_api_demo
export FLASK_ENV=development
flask run --host 0.0.0.0

```

- 중복된 code는 설명 생략하겠습니다.
- **export FLASK_APP=flask_api_demo** : Flask 서버를 실행할 때, 실행할 어플리케이션을  
지정해주는 역할을 합니다. FLASK_APP을 flask_api_demo로 입력하여 `flask_api_demo/__init__.py` 의  
 `__name__`이 flask_api_demo로 설정됩니다.  
- **export FLASK_ENV=development** : FLASK_ENV를 development를 설정하였을 경우
log의 형식이 development형으로 나와 좀 더 자세한 log를 확인할 수 있습니다.
- **flask run \--host 0.0.0.0** : flask로 python을 실행시킵니다. \--host명령은
flask 애플리케이션은 host 값을 default 값으로 실행시켰을시 127.0.0.1:5000
즉, localhost:5000을 갖는데 docker container 외부에서 접근을 허용하기 위해 0.0.0.0으로
지정해줍니다.

**run-flask-api script 화면**  

![flask-run](/assets/images/2019-03-17-tech_blog_flask_api_demo_1/flask-run.png)

- run-docker-compose script에서 설정한 5000번 포트로 docker-toolbox의 default ip
주소인 192.168.99.100:5000에 접속 합니다.
docker for mac, window 는 localhost:5000으로 접속 가능합니다.

**Flask app 실행 화면**  

![flask-app](/assets/images/2019-03-17-tech_blog_flask_api_demo_1/flask-app.png)

 Project Dockerized Python  운영환경 정복하기 with Flask 의 Chapter 1이 끝났습니다.
 수고하셨습니다. 박수!! 짝짝짝

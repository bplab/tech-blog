---
title: "Dockerized Python  운영환경 정복하기 with Flask"
categories:
  - development
tags:
  - docker
  - docker-compose
  - python
  - flask
  - api
  - tutorial
---

본 포스팅은 BluprintLAB 개발팀의 기술 공유 및 tutorial로 작성되었습니다. 문의사항 및 궁금한 점이 있다면  
software@blueprint-lab.com으로 문의 주시길 바랍니다.  

BlueprintLAB 개발팀
- - -
# Project Name
- flask-api-demo
- github: [https://github.com/jetsbee/flask_api_demo](https://github.com/jetsbee/flask_api_demo)

---

## Chapter 1 - Docker Setting, Hello World

## 1. Git Initalized

첫번째로, Git Initalized를 해보도록 하겠습니다.  

- Git Repository를 만들고 .gitignore를 설정해줍니다.

- **.gitignore**:  Git 버전 관리에서 제외할 디렉토리 혹은 파일의 목록을 적어놓은 파일입니다.
.gitignore를 설정하지 않으면 필요없는 Data나 password 및 access key 등 중요한 데이터가
온라인상에 올라갈 수 있으므로 필수적으로 작성해야 합니다.

- Project 시작단계에서 필요없는 Data 생성을 방지하게 위하여 각각의 IDE나 OS에 맞게
.gitignore 목록을 작성합니다.

> 사용중인 OS와 IDE에 맞게 .gitignore를설정 할 수 있는 사이트 입니다.  
> [www.gitignore.io](https://www.gitignore.io/) 사이트 들어가서 검색창에 원하는 OS나 IDE 이름 입력 후 생성 버튼을
클릭하여 .gitignore를 작성 할 수 있습니다.
- - -

## 2. Dockerized python
이번에는 Python을 Docker container 개발환경으로 구성해보도록 하겠습니다.  

### 2-1 docker-compose.yml 작성
- docker-compose.yml 파일을 작성합니다.
- docker-compose는 한번에 여러개의 container를 정의하고 실행시킬 수 있는
yml 형식의 설정 파일입니다.

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
- **version** : docker-compose의 version을 정의합니다. version별로 약간의 문법의
차이가 있으니 참고 하길 바랍니다.
- **services** : docker container를 정의하는 부분입니다. 하나의 container를 하나의
service로 볼 수 있습니다.
- **api** : service 이름입니다. 예제에서는 api라는 이름의 service로
container를 구동하겠습니다. 임의로 service이름을 설정할 수 있습니다.
- **image** : docker의 image를 입력할 수 있습니다. docker image는 container의
모든 정보를 포함한 하나의 단위 입니다.
- **volumes** : container 상의 Data를 Local로 공유하기 위한 기능입니다.
volumes는 *local_path:container_path* 로 값을 입력할 수 있습니다.
예제에 나와있는 ${proj_path} 부분은 잠시 후에 설명하도록 하겠습니다.
- **working_dir**: container의 working directory로 볼 수 있습니다.
예를들어 container의 bash shell은 정해준 directroy path에서 실행됩니다.

> 자세한 정보는 [여기](https://docs.docker.com/compose/compose-file/) 에서 참고 하실 수 있습니다.  

**issue** - Window OS shared folder issue 해결 - Docker-toolbox & window 10 pro
```
window 10 이상부터 Guest OS의 shared folder를 symlink로 설정할 수 있습니다.
그러나 기본적으로 admin권한만 설정되어있으므로 수동으로 사용자에게 권한을 주어야 합니다.
1. window + R 버튼을 누른 후 secpol.msc 실행시킵니다.
2. 로컬 정책의 사용자 권한 할당을 선택 후 심볼릭 링크 만들기를 클릭합니다.
3. 사용자 또는 그룹 추가에 사용자를 추가합니다.
4. Docker-toolbox 상에서 docker-machine stop을 입력 후 VirutalBox의 공유 폴더를 설정합니다.
공유폴더는 자동마운트와 항상 사용하기 옵션을 줍니다.
5. C 드라이브와 D드라이브를 공유 폴더로 사용할 경우 아래와 같은 명령어 Docker-toolbox 상에서 입력합니다
"/c/Program Files/Oracle/VirtualBox/vboxmanage" setextradata default "VBoxInternal2/SharedFoldersEnableSymlinksCreate/c" 1
"/c/Program Files/Oracle/VirtualBox/vboxmanage" setextradata default "VBoxInternal2/SharedFoldersEnableSymlinksCreate/d" 1
6. Docker-machine start를 입력합니다.
```

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
volume의 local path의 의존성을 제거하기 위해 env 파일로 proj_path 값을
현재 디렉토리 path로 설정하였습니다.
- **docker-compose run --rm -p 5000:5000 api bash** : Docker container를
구동시키는 명령어 입니다.
보통 docker-compose up의 명령어를 사용하지만 개발환경을 맞추기 위해 몇가지 옵션을 주었습니다.  
*--rm* : container의 프로세스가 끝나면 자동으로 컨테이너를 삭제하는 옵션입니다.  
*-p* : docker container의 port 값을 설정합니다. host_port:container_port 로 입력합니다.  
*api bash* : api는 docker-compose에 설정한 service 이름입니다.  
bash는 api service container의 bash shell을 실행시킨다는 명령어입니다.

- **docker-compose 실행 화면**  
![docker-compose](/assets/images/2019-03-17/docker-compose.png)

이로써 Dockerized python이 끝났습니다. 다음으로는 본격적으로 Python을
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
flask
```
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
- **. venv/bin/activate** : 가상환경을 활성화 시키는 명령어입니다.
- **python3 -m pip install --upgrade pip** : python package를 최신버전으로
업그레이드 합니다.
- **python3 -m pip install --trusted-host pypi.python.org -r $(pwd)/requirements.txt**
: --trusted-host pypi.python.org는 SSL인증 오류를 해결하기 위한 명령어입니다.
requirements에 있는 package를 설치합니다.

- **install-python-dependencies sciprt 실행 화면**  
![install-python](/assets/images/2019-03-17/install-python.png)

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
- **from flask import Flask** : flask class를 import 합니다.
- **def** : python의 함수를 정의합니다. create_app이라는 함수를 정의하였습니다.
- **app = Flask(`__name__`)** : app의 변수로 Flask 인스턴스를 정의합니다.
- **`__name__`** 은 python 명령어로 실행되었을 경우 `__main__`으로 인식되며
import 한 경우는 `__모듈이름__` 으로 인식됩니다.
- ` @app.route('/') ` : route()함수는 Flask 어플리케이션에서 URL이 호출되어야 하는
연관된 함수를 요청합니다.
- **def hello_world():** : 위의 예시코드에서 ` @app.route('/') ` 과 연관된 함수입니다.
Flask 어플리케이션의 /로 접속하게 되면 hello_world() 함수의 return 'Hello, World' 값을 반환합니다.
- **return app** : app을 반환하여 Flask 인스턴스가 실행됩니다.

### 4-2 run-flask-api script 작성
실행관련 command를 모두 script화 한 것을 확인할 수 있습니다.

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
- **export FLASK_APP=flask_api_demo** : FLASK_APP을 flask_api_demo로 입력하여
`flask_api_demo/__init__.py` 의 `__name__`이 flask_api_demo로 설정됩니다.
- **export FLASK_ENV=development** : FLASK_ENV를 development를 설정하였을 경우
log의 형식이 development형으로 나와 좀 더 자세한 log를 확인할 수 있습니다.
- **flask run --host 0.0.0.0** : flask로 python을 실행시킵니다. --host명령은
flask 애플리케이션은 host 값을 default 값으로 실행시켰을시 127.0.0.1:5000
즉, localhost:5000을 갖는데 docker container에서의 접근을 허용하기 위해 0.0.0.0으로
지정해줍니다.

- **run-flask-api script 화면**  
![flask-run](/assets/images/2019-03-17/flask-run.png)

- run-docker-compose script에서 설정한 5000번 포트로 docker-toolbox의 default ip
주소인 192.168.99.100:5000에 접속 합니다.
docker for mac, window 는 localhost:5000으로 접속 가능합니다.

- **Flask app 실행 화면**  
![flask-app](/assets/images/2019-03-17/flask-app.png)

 Project Dockerized Python  운영환경 정복하기 with Flask 의 Chapter 1이 끝났습니다.
 수고하셨습니다. 박수!! 짝짝짝

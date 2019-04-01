---
title: "Docker + Python  운영환경 정복하기 with Flask 3"
tags:
  - docker
  - docker-compose
  - python
  - flask
  - api
  - tutorial
---

안녕하세요 블루프린트랩 개발자 구상모입니다. 벌써 3번째 포스팅입니다. 시간이 참 빠르게 지나가는 것 같습니다.  

이번 포스팅에선 권한 및 인증 API를 위한 Test Code를 작성해보도록 하겠습니다.

- - -
# Project Name
- flask-api-demo
- github: [https://github.com/bplab/flask_api_demo](https://github.com/bplab/flask_api_demo/tree/b2fc8986f4e38a3b6a1a34df39e904389378f45f)


---

## Chapter 3 - Testing Codes for Authentication, Authorization

## 1. Set MongoDB container

**Mongo DB** 는 NoSQL 의 대표적인 Database로 C++로 작성되었으며
Mongo DB 를 Docker container로 구축해보겠습니다.

Docker와 Docker-compose에 대한 간단한 설명은 *[이전 포스팅](https://tech.blueprint-lab.com/tech_blog_flask_api_demo_1/)* 에서 확인하실 수 있습니다.

먼저 docker-compose.yml 을 보도록 하겠습니다.

**docker-compose.yml 예제**
```
version: '3'

services:
  api:
    image: python:latest
    volumes:
      - ${proj_path}:/root/flask_api_demo
    working_dir: /root/flask_api_demo
    depends_on:
      - db

  db:
    image: mongo:latest
    volumes:
      - mongo_configdb:/data/configdb
      - mongo_db:/data/db
    ports:
      - "27017:27017"

volumes:
  mongo_configdb:
  mongo_db:

```

예제에서 service 가 db이고 Docker image로 mongo:latest 인 것을 확인할 수 있습니다. 새롭게 추가된 내용은 **ports** 옵션인데  기본적으로 docker container가 생성되면 외부 네트워크와 통신이 불가능합니다.

docker conatiner가 외부와 통신이 가능하려면 port를 설정해줘야 하는데 이때 docker-compose의 ports 옵션으로 외부 노출 port를 설정할 수 있습니다.

예제에서 db container의 port가 27017:27107 로 설정되어 있는 것을 확인 할 수 있습니다. 이는 외부에서 27107 port로 요청이 들어오면 db container의 27017 port로 forwarding 한다는 뜻 입니다. port 형식은 `<외부 port>:<container port>` 형식으로 쓰입니다.


## 2. Configure For Testing

이제 DB container 설정이 끝났습니다. 저희는 **TDD** 를 활용하기로 하였습니다. TDD란 Test Driven Development의 약자로써 말그대로 테스트 주도 개발이라는 뜻입니다.  

TDD에 대해 간략히 설명해보도록 하곘습니다.
- 요구사항이 포함된 Test Case를 만듭니다.
- Test Case가 작성되었으면 테스트에 통과 하는 소스코드를 작성합니다.
- 테스트에 통과 하는 코드를 반복적으로 만들면서 제대로 동작하는지 확인하며 리팩토링을 진행합니다.

python Flask에서 Test Case를 작성하는데 필요한 것들을 하나씩 차례대로 진행하겠습니다.

**1. Python Package 설치**

```
Flask
Flask_restful
Flask_PyMongo
pytest
```
- requirements.txt에 필요한 package를 추가합니다.
- Flask에서 Mongo DB에 접근할 수 있는 Flask_PyMongo 와 Python test case를 실행시킬 수 있는 pytest package를 설치합니다.


지난 포스팅에서 작성해놓았던 `install-python-dependencies.sh` 를 사용해서 설치하도록 합니다.

**2. config.py 예제**
```
class Config(object):
    DEBUG = False
    TESTING = False
    MONGO_URI = 'mongodb://db:27017/flask_api_demo'


class TestingConfig(Config):
    TESTING = True
    MONGO_URI = 'mongodb://db:27017/flask_api_demo_test'


class DevelopmentConfig(Config):
    DEBUG = True


class ProductionConfig(Config):
    pass

```
- config.py는 Flask를 실행시킬때 설정할 config들을 정의 합니다.
- MONGO_URI는 mongo DB 서버의 주소를 나타낸다.
- 맨 처음에 정의된 class Config를 상속 받는 것을 확인 할 수 있습니다.


 config.py를 구성하였고 실제로 python code에서 어떻게 쓰이는지 알아보도록 하겠습니다.

 **3. init.py 예제**
 ```
from flask import Flask
from flask_restful import Api

import config


def create_app():
    app = Flask(__name__)

    if app.config['ENV'] == 'development':
        app.config.from_object(config.DevelopmentConfig)
    elif app.config['ENV'] == 'testing':
        app.config.from_object(config.TestingConfig)
    elif app.config['ENV'] == 'production':
        app.config.from_object(config.ProductionConfig)
    else:
        raise ValueError('Check FLASK_ENV')

    # ref. https://github.com/flask-restful/flask-restful/issues/280
    handle_exception = app.handle_exception
    handle_user_exception = app.handle_user_exception

    from .resources.foo import (
        foo_bp,
        Hello,
    )

    api_foo = Api(foo_bp)
    api_foo.add_resource(Hello, '/')

    app.register_blueprint(foo_bp)

    # ref. https://github.com/flask-restful/flask-restful/issues/280
    app.handle_exception = handle_exception
    app.handle_user_exception = handle_user_exception

    return app

 ```

이전 소스코드와 비교해 보았을때 크게 바뀐점이 2가지가 있습니다.
- 첫번째로 Import Config가 추가되습니다. config.py를 python코드에서 import하여 flask instance에 어떠한 config가 적용이 될지 정하는 부분이 생겼습니다.
- 두번째로 resource를 import 하는 부분과 rest api가 밑으로 옮겨진 것을 확인할 수 있습니다. 그 이유는 config.py가 생기면서 앞으로 DB에 접근하게 될 때 config보다 DB로 접근 하는 api가 먼저 import 되면 에러가 날 수 있기 때문입니다.

## 3. Write Testing Code

test case 작성에 앞서 **인증** 에 대한 간단한 설명을 하도록 하겠습니다.

**인증** 이란 Resource를 사용하는 User의 신원을 확인하는 일 입니다. 웹 서비스에 로그인을 통해 인증을 받으면 권한 내에서 자유롭게 웹 서비스 Resource를 사용할 수 있게 됩니다. 웹 서비스에서 User의 인증 방식은 크게 두가지로 나뉩니다.

1. **서버 기반 인증**: 서버 기반 인증은 서버에 인증 기록을 저장하는 방식입니다. 서버에 저장된 것을 **세션** 이라 부르고 세션이 많아진다면 서버가 과부하가 걸릴 수 있습니다. 즉 다시말해 로그인 하는 User수가 많아 질 수록 서버 성능에 영향을 끼치는 것 입니다.

2. **토큰 기반 인증**: 토큰 기반 인증은 서버가 인증 기록을 세션에 담아두지 않습니다. 서버측에서 User 정보를 검증 후 User에게 토큰을 발급하고 이 토큰을 User가 사용하여 로그인 할때마다 해당 토큰을 헤더에 담아 request 합니다.


저희는 토큰 기반 인증으로 인증을 진행하며 웹 표준인 JWT를 사용하여 test case를 작성해보도록 하겠습니다. 저희는 pytest를 사용하였으며 본격적으로 python test case를 작성해보도록 하겠습니다.

> **pytest** 에 관한 자세한 정보는 *[여기](https://docs.pytest.org/en/latest/contents.html)* 에서 확인하실 수 있습니다.

**1.conftest.py 예제**

```
import pytest
import json

from flask_pymongo import PyMongo

from flask_api_demo import create_app


app = create_app()

if app.config['ENV'] != 'testing':
    raise ValueError('Check FLASK_ENV')


@pytest.fixture(scope='session')
def reset_testing_db():
    mongo = PyMongo(app)
    cx = mongo.cx

    yield reset_testing_db

    cx.drop_database('flask_api_demo_test')


@pytest.fixture(scope='session')
def tester(reset_testing_db):
    tester = app.test_client()

    return tester


@pytest.fixture(scope='session')
def jwt(tester):
    resp = tester.post(
        '/users/registration',
        data=json.dumps({'username': 'test', 'password': 'test'}),
        content_type='application/json',
    )
    resp_data = resp.get_json()
    result = {
        'access_token': resp_data['access_token'],
        'refresh_token': resp_data['refresh_token'],
    }

    return result

```
- test function은 `@pytest.fixture` 라는 fixture 데코레이터로 정의 되어있으며 fixture 객체를 받을 수 있습니다. 쉽게 말해 fixture를 사용하면 test function을 parameter로 쓸 수 있습니다.
- **reset_testing_db** : mongoDB의 test 성 database를 생성하며 yeild 예약어로 reset_testing_db가 끝나면 test 성 database를 삭제합니다.
- **tester** : flask test instance를 생성합니다.
- **jwt** : JWT token을 발급받는 함수입니다.
- tester를 통해 token을 발급받고 tester는 flask instance를 생성할떄 test Database를 설정하는 것을 확인 할 수 있습니다. 이 함수들을 가지고 본격적으로 test를 진행해보도록 하겠습니다.


**2. test_foo.py 예제**

```
def test_hello_ok(tester):
    resp = tester.get(
        '/tests/hello',
        content_type='application/json',
    )

    assert {'Hello': 'World!'} == resp.get_json()
    assert 200 == resp.status_code


def test_secret_ok(tester, jwt):
    resp = tester.get(
        '/tests/secret',
        headers={'Authorization': 'Bearer {}'.format(jwt['access_token'])},
        content_type='application/json',
    )

    assert {'Hello': 'Secret!'} == resp.get_json()
    assert 200 == resp.status_code


def test_secret_without_header(tester):
    resp = tester.get(
        '/tests/secret',
        headers=None,
        content_type='application/json',
    )

    assert {'msg': 'Missing Authorization Header'} == resp.get_json()
    assert 401 == resp.status_code


def test_secret_with_refresh_token(tester, jwt):
    resp = tester.get(
        '/tests/secret',
        headers={'Authorization': 'Bearer {}'.format(jwt['refresh_token'])},
        content_type='application/json',
    )

    assert {'msg': 'Only access tokens are allowed'} == resp.get_json()
    assert 422 == resp.status_code


def test_secret_with_bad_access_token(tester, jwt):
    resp = tester.get(
        '/tests/secret',
        headers={'Authorization': 'Bearer {}extra-string'.format(jwt['access_token'])},
        content_type='application/json',
    )

    assert {'msg': 'Signature verification failed'} == resp.get_json()
    assert 422 == resp.status_code


def test_secret_with_bad_jwt(tester):
    resp = tester.get(
        '/tests/secret',
        headers={'Authorization': 'Bearer {}'.format('this-is-not-json-web-token')},
        content_type='application/json',
    )

    assert {'msg': 'Not enough segments'} == resp.get_json()
    assert 422 == resp.status_code


def test_secret_with_bad_header(tester):
    resp = tester.get(
        '/tests/secret',
        headers={'Authorization': '{}'.format('this-is-plain-text')},
        content_type='application/json',
    )

    assert {'msg': "Bad Authorization header. Expected value 'Bearer <JWT>'"} == resp.get_json()
    assert 422 == resp.status_code

```

- pytest는 test_ prefix가 붙은 function과 file을 test할 것으로 간주합니다. 그러므로 file 이름과 function에 test_ 가 붙은 것을 확인 할 수 있습니다.
- User는 Access token과 Refresh token 을 발급 받습니다. Access token은 로그인할때 사용되며 refresh token은 Access token의 유효 시간을 갱신 해주는 token 입니다.
- User는 token을 header에 담아 request 보내는데 header의 형식이 정해져 있습니다. `{'Authorization' : 'Bearer <Access Token> }` 와 같습니다.
- 전체적인 Test Case는 Token이 정상적일때와 비정상적일 때의 Case를 고려하였습니다.

자 이제 거의 다 왔습니다... Test Case를 작성하는게 조금만 더하면 됩니다!!

**run-pytest.sh 예제**
```
#!/bin/sh

cd $(cd "$(dirname "$0")" && pwd)

. venv/bin/activate
export FLASK_ENV=testing
pytest -s -v --tb=short

```

저희는 모든 명령어를 script 화 하였습니다. pytest도 마찬가지 script를 통해서 실행시키도록 하겠습니다.
- **export FLASK_ENV=testing** : Flask ENV를 testing으로 설정함으로써 config.py의 TestingConfig의 config를 가지게 됩니다.
- **pytest -s -v \--tb=short** : pytest의 명령어 입니다. -s 옵션은 가장 수행시간이 길었던 10개의 test를 출력하는 명령어 입니다. -v는 pytest의 information을 좀 더 자세히 출력합니다. 마지막으로 \--tb=short 짧은 형식의 traceback을 나타냅니다.


**Pytest 구동 화면**

![pytest](/assets/images/2019-03-31-tech_blog_flask_api_demo_3/pytest.png)  

test case에 통과하지 못하였지만 이제 앞으로 저 빨간색 들이 초록색으로 변하는 날까지 꾸준히 포스팅 하도록 하겠습니다. 모두 수고 하셨습니다!!! 

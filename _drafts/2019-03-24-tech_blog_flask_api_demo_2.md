---
title: "Docker + Python  운영환경 정복하기 with Flask 2"
tags:
  - docker
  - docker-compose
  - python
  - flask
  - api
  - tutorial
---

이번 포스팅은 Flask를 활용하여 RESTful api를 구축 하고 Blueprint를 적용시켜보도록 하겠습니다.

자세한 설명은 잠시 뒤에 설명하도록 하겠습니다.

- - -
# Project Name
- flask-api-demo
- github: [https://github.com/bplab/flask_api_demo](https://github.com/bplab/flask_api_demo/tree/db436bb44382b5d0ba191b5bd33b7dbf9de02821)


---

## Chapter 2 - Flask-RESTful + Blueprints

## 1. Installed Flask-RESTful

**Flask-RESTful** 라이브러리를 설치합니다.
Flask-RESTful 라이브러리는 파이썬으로 만든 웹서비스에 REST API를 적용하기 쉽게 도와줍니다.

들어가기에 앞서 먼저 **RESTful** 이 무엇인지 알아야 합니다. RESTful을 알기위해선 **REST** 의 개념도 알아햐 합니다.

- **REST** : 간단히 설명하면 웹사이트의 이미지나 텍스트 같은 모든 **자원(Resource)** 에
HTTP URI를 부여하고 **HTTP Method** 를 통해 CRUD Operation을 적용하는 것을 의미합니다.

그러면 먼저 Flask-RESTful을 설치하도록 하겠습니다.

**requirements.txt 예제**
```
Flask
Flask_restful
```

- **requirements 설치 화면**  

![requirements](/assets/images/2019-03-24-tech_blog_flask_api_demo_2/requirments.png)

- requirements.txt에 Flask_restful을 추가함으로써 지난 포스팅에 만들어놓은  
install-python-dependencies.sh를 통해 python conatiner에 Flask_restful을  
설치합니다.

> Flask_restful에 대한 자세한 설명은 **[Flask-RESTful](https://flask-restful.readthedocs.io/en/latest/)** 에서 확인할 수 있습니다.

## 2. Flask-RESTful과 Blueprints를 사용하여 API 구성

파이썬 API를 Flask-RESTful과 Blueprint를 사용하여 구성해보도록 하겠습니다.

**Blueprints** 어플리케이션을 구분된 컴포넌트로 배열하는 기법입니다. 큰 규모의 어플리케이션을 좋게 구성할 수 있는 방법입니다.

> 자세한 설명은 **[Flask Bluepirnt](http://flask.pocoo.org/docs/1.0/blueprints/)** 에서 확인할 수 있습니다.

먼저 프로젝트 구조의 변화를 체크해보도록 하겠습니다.

**Project 구조 변화**
- 지난번의 project 구조와 현재의 project 구조를 간략하게 표현 해봤습니다.

```                               
Project +                                     Project +
        |                                             |
        |                                             |
        /flask_api_demo +                             /flask_api_demo +
        |               |                             |               |
        |               + __init__.py                 |               /resource + __init__.py
        |                                             |               |         + foo.py
        + docker-compose.yml                          |               |         
        + install-python-dependencies.sh              |               + __init__.py           
        + README.md                                   |               
        + requirements.txt                            + docker-compose.yml
        + run-docker-compose.sh                       + install-python-dependencies.sh
        + run-flask-api.sh                            + README.md
                                                      + requirements.txt
                                                      + run-docker-compose.sh
                                                      + run-flask-api.sh  
```

- 구조를 비교해 보았을때 /resource 디렉토리가 추가된 것을 확인 할 수 있습니다.
- /resource의 foo.py는 Blueprint를 적용 하는 부분입니다.

**foo.py**
```
from flask import Blueprint
from flask_restful import Resource


foo_bp = Blueprint('foo', __name__)


class Hello(Resource):
    def get(self):
        return 'Hello, World!', 200

```
- **from flask import Blueprint** : flask 패키지에서 Blueprint 모듈을 Import 함으로써
Blueprint를 사용할 수 있도록 합니다.  
- **from flask_restful import Resource** : flask_restful에서 Resource을 Import 합니다. 위에 설명한 REST의 개념으로 자원을 만드는 것입니다.
- **foo_bp = Blueprint('foo', __name__)** : foo라는 Blueprint 객체를 만들어 foo_bp 변수에 정의 합니다.  
- **Class Hello(Resource):** : Hello Class를 정의 하고 인자는 flask_restful의 Resource를 상속 받습니다. 여기서 Resource는 REST의 자원(Resource)와 일맥 상통 합니다.
- **def get(self)** : Hello Class에 속한 get method를 정의합니다. 여기서 get은 HTTP METHOD의 GET 입니다.
- **return 'Hello, World!', 200** : Hello, World!를 return 하며 페이지의 상태코드 200이 되도록 정의합니다.

/resource 디렉토리의 `__init__.py`는 지난번 포스팅에서 설명한 것처럼 /resource가 project의 package임을 나타냅니다.

다음으로 /flaks_api_demo 디렉토리의 `__inti__.py`를 살펴보도록 하겠습니다.

**__init__.py**
```
from flask import Flask
from flask_restful import Api

from .resources.foo import foo_bp
from .resources.foo import Hello


def create_app():
    app = Flask(__name__)
    api_foo = Api(foo_bp)

    # ref. https://github.com/flask-restful/flask-restful/issues/280
    handle_exception = app.handle_exception
    handle_user_exception = app.handle_user_exception

    api_foo.add_resource(Hello, '/')
    app.register_blueprint(foo_bp)

    # ref. https://github.com/flask-restful/flask-restful/issues/280
    app.handle_exception = handle_exception
    app.handle_user_exception = handle_user_exception

    return app

```

- Import 부분은 .resource.foo 만 설명하도록 하겠습니다.
- **from .resources.foo import foo_bp** : foo.py에서 만든 Blueprint 객체를 import 합니다.
- **from .resources.foo import Hello** : foo.py에서 만든 Hello Class(Restful Resource) 를 import 합니다.
- **def create_app():** : create_app 함수를 정의합니다.
- **app = Flask(__name__)** : app의 변수로 Flask 인스턴스를 정의합니다.
- **api_foo = Api(foo_bp)** : flask_restful에서 import한 Api가 foo_bp(Blueprint)를 인자로 받습니다.
- **handle_exception과 handle_user_exception** : Flask-RESTful을 사용하게 되면  
flask의 error handlers를 사용할 수 없게 됩니다. 이를 방지하기 위하여  
미리 error handler를 변수에 담아두고 Flask-restful api가 한번 호출이 있고 난 뒤에  
다시 error handler를 복원 하는 부분입니다.  
- **api_foo.add_resource(Hello, '/')** : api를 정의합니다. 첫번째 인자로 foo.py에서 Import한 Hello를 받고 두번째 인자로 URL 경로를 입력해줍니다.
- **app.register_blueprint(foo_bp)** : foo.py에서 생성한 Blueprint객체를 등록합니다. 큰 어플리케이션에서 모듈화 하기 쉽습니다. 향후에 다시 blueprints를 소개하도록 하겠습니다.
- **return app** : app에 정의 된 flask instance를 return 합니다.


- **Project 구동 화면**  

![flask-restful](/assets/images/2019-03-24-tech_blog_flask_api_demo_2/flask-restful.png)

이로써 Flask-RESTful을 이용한 API를 구성하였고 더불어 Blueprint도 적용시켜보았습니다!!
수고하셨습니다!! 다음 포스팅엔 authentication, authorization을 진행하도록 하겠습니다!

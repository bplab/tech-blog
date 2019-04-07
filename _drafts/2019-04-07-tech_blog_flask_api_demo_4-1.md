---
title: "Docker + Python  운영환경 정복하기 with Flask 4-1"
tags:
  - docker
  - docker-compose
  - python
  - flask
  - api
  - tutorial
---

안녕하세요 블루프린트랩 개발자 구상모입니다. chapter 가 진행될 수록 기존에 설명드렸던 것을 생략함에 따라 설명이 점점 더 단순해지는 것 같습니다... 근데 또 진행할수록 코드의 난이도는 어려워지는 것 같아서 많이 고민이 됩니다... 최대한 자세히 설명할 수 있게 노력해보겠습니다!!! 

이번 chapter는 4-1과 4-2로 나누어 진행하도록 하겠습니다.  
이전 포스팅을 참고하여 주시고 이번 포스팅 진행해 주시면 됩니다! 

- - -
# Project Name
- flask-api-demo
- github: [https://github.com/bplab/flask_api_demo](https://github.com/bplab/flask_api_demo/tree/422d4a48bd54f105cd22e635f90c66695ca91830)


**part 1** : [Docker + Python  운영환경 정복하기 with Flask 1](../tech_blog_flask_api_demo_1)  
**part 2** : [Docker + Python  운영환경 정복하기 with Flask 2](../tech_blog_flask_api_demo_2)  
**part 3** : [Docker + Python  운영환경 정복하기 with Flask 3](../tech_blog_flask_api_demo_3)

---

## Chapter 4-1 - Models + flask-jwt-extendes
<br>
이번 Chapter에서는 변경된 파일을 기준으로 설명하며 4-2가 완성되었을 때 JWT Token과 MongoDB의 Model이 어떤 프로세스로 작동되는지 확인 할 수 있게 됩니다. 
먼저 **JWT**에 대해서 간단히 설명하겠습니다.

### JWT 는 무엇인가?
- JWT는 JSON Web Token의 약자로 2015년 7월에 웹 표준 **[RFC 7519](https://tools.ietf.org/html/rfc7519)**으로 등록 되었습니다. JWT는 JSON 객체를 사용하여 서로 간에 *정보(information)*를 안전하게 전달하기 위하여 아주 단순하고 독립적입니다.

- 여기서 말하는 **정보(information)**는 디지털 서명(Digitally Signed) 입니다. 디지털 서명은 신뢰성이 보장되고 검증이 되어있습니다. Secret 형식이나 public/private key 키 쌍을 사용하여 작성이 되기 때문입니다.

### JWT를 사용하는 경우
- JWT를 사용하면 좋은 경우는 **인증**(Authorization)을 하거나 **정보교환**(Information Exchange) 를 하는 경우에 사용 됩니다. 인증의 경우에는 지난 포스팅에서 설명한 **토큰 기반 인증**의 경우에서 처럼 사용 되며 정보 교환의 경우에는 디지털 서명으로 송신자가 변경되었는지 내용이 변조되지 않았는지 확인할 수 있기 때문에 사용합니다.

그러면 **JWT**를 Flask에서 어떻게 설정하고 사용할 수 있는지 본격적으로 알아보도록 하겠습니다.

## 1. .gitignore 설정
<br>
먼저 python 코드를 변경하기 전에 gitignore를 설정해야 합니다.
기존의 .gitignore와 달라진 점을 확인할 수 있습니다. 

**gitignore 변경사항**

![gitignore](/assets/images/2019-04-07-tech_blog_flask_api_demo_4-1/gitignore.png)

* instance에 대한 gitignore 형식이 바뀐 것을 확인 할 수 있습니다.
* flask의 민감한 정보는 instance directory의 **application.cfg**에 저장합니다. 우리가 앞으로 사용할 JWT의 **Secret key** 가 바로 application.cfg에 저장됩니다.  
* Secret Key가 노출되면 공격자는 JWT의 디지털 서명을 위조할 수 있습니다. 그러므로 gitignore를 instance directory 로 설정해주는 것 입니다.
* application.cfg.example는 application.cfg가 어떤 형식인지 예를 든 파일입니다. JWT_SECRET_KEY 예제 값이 들어 있는 것을 확인 할 수 있습니다.

**applicaiton.cfg.example 예제**
```
JWT_SECRET_KEY = 'jwt-secret-string-1234-!@#$'
```

## 2. JWT Setting - Flask 
flask에서 JWT를 사용하기 위해서는 여러 설정이 필요 합니다. 하나씩 설정해 나가도록 하겠습니다.

**2-1 requirements.txt**
```
Flask_restful
Flask_PyMongo
pytest
passlib
flask-jwt-extended
```
- 기존 requirements.txt에서 passlib와 flask-jwt-extended가 추가된 것을 확인할 수 있습니다.
- flask에서 jwt설정을 위해 flask_jwt_extended package가 필요합니다. 
- passlib은 간단하게 설명하자면 DB에 저장되는 password 값을 알아볼 수 없도록 다시 암호화 하는 package입니다. 자세한 설명은 다음 포스팅에서 설명하도록 하겠습니다.
- `run-docker-compose.sh` -> `install-python-dependencies.sh` 순서대로 실행하여 필요한 package를 설치합니다.

**2-2 __init__.py 변경사항**
```python
from flask import Flask
from flask_restful import Api
from flask_jwt_extended import JWTManager

import config
from .models.db import mongo


def create_app():
    app = Flask(__name__, instance_relative_config=True)

    if app.config['ENV'] == 'development':
        app.config.from_object(config.DevelopmentConfig)
    elif app.config['ENV'] == 'testing':
        app.config.from_object(config.TestingConfig)
    elif app.config['ENV'] == 'production':
        app.config.from_object(config.ProductionConfig)
    else:
        raise ValueError('Check FLASK_ENV')

    app.config.from_pyfile('application.cfg')

    mongo.init_app(app)
    jwt = JWTManager(app)

    # ref. https://github.com/flask-restful/flask-restful/issues/280
    handle_exception = app.handle_exception
    handle_user_exception = app.handle_user_exception

    from .resources.foo import (
        foo_bp,
        Hello,
        HelloSecret,
    )

    api_foo = Api(foo_bp)
    api_foo.add_resource(Hello, '/hello')
    api_foo.add_resource(HelloSecret, '/secret')

    app.register_blueprint(foo_bp)

    # ref. https://github.com/flask-restful/flask-restful/issues/280
    app.handle_exception = handle_exception
    app.handle_user_exception = handle_user_exception

    return app
```

JWT와 관련된 코드만 먼저 살펴보도록 하겠습니다. 
- **from flask_jwt_extended import JWTManager** : flask_jwt_extended 패키지에서 JTWManager를 import 하고 있습니다. 여기서 JWTManager는 flask instance에서 JWT을 사용할 수 있게 만들어주는 역할을 합니다.
- **app = Flask(__name__, instance_relative_config=True)** : flask의 instance directory는 버전 관리와 어떤 배포환경에 속하지 않도록 설정된 directory 입니다. 그러므로 민감한 configuration 파일들은 instance directory 로 저장되고 이로 인해 gitignore에 instance directory를 설정하였습니다. flask instance에서 config를 load 할때 설정된 default path는 root path 인데   `instance_realtive_config=True` 값을 주게 되면 app상에서 configuration에 대한 경로가 root가 아닌 instance directory 를 바라보게 됩니다. 
- **app.config.from_pyfile('application.cfg')** : 위의 `instance_realtive_config=True`가 설정되어 있지 않다면 config를 load 하는데 있어서 `application.cfg` 파일은 flask의 root path에서 찾을 것입니다. 그러나 `instance_realtive_config=True` 가 설정되어 있다면 flask의 instance directory path에서 찾게 됩니다.  
- **jwt = JWTManager(app)** :  flask instance에서 jwt을 초기화(initialize) 하는 것 입니다. JWTManager(app)을 설정해줘야 flask istance에서 jwt를 사용할 수 있게 됩니다.
- **api_foo 관련** : api의 add_resource 부분이 바뀐 것을 확인 할 수 있습니다.  `/hello`와 `/secret`에 대한 설명은 실제 `foo.py` 코드를 보면서 설명하겠습니다.

**2-3 foo.py 변경사항**
```python
from flask import Blueprint
from flask_restful import Resource
from flask_jwt_extended import jwt_required


foo_bp = Blueprint('foo', __name__, url_prefix='/tests')


class Hello(Resource):
    def get(self):
        return {'Hello': 'World!'}, 200


class HelloSecret(Resource):
    @jwt_required
    def get(self):
        return {'Hello': 'Secret!'}, 200

```

- 기존의 코드와 다른점은 크게 **HelloSecret** 가 추가된 것입니다. 이 부분에서 `@jwt_required`는 api 요청을 할때 Authorization 헤더에 jwt 토큰 값을 정해줘야 접근이 가능합니다. 
- `init.py`와 관련하여 flask instance에서 `/hello`의 api로 요청이 오게 되면 `{'Hello': 'World!'}` 를 반환하게 됩니다.
- `/secret`으로 요청이 오면 jwt 토큰이 있어야 `{'Hello': 'Secret!'}` 반환합니다. 쉽게말해 로그인이 된 User는 `/secret`에 접속이 가능하고 로그인이 안된 User는 접속이 불가능합니다.


여기까지 JWT 와 관련된 설정이 끝났습니다. 다음 4-2 Chapter에서는 JWT와 Database Model을 어떻게 정의하고 사용하는지에 대해 알아보겠습니다! 수고하셨습니다!! 







## Posts Guideline

- `_posts` 디렉토리 아래에 작성
- `yyyy-mm-dd-english-title.md` 형식의 파일 이름을 따를 것, 파일 이름에서 띄어쓰기가 필요한 경우 `-`을 이용
- 아래의 예시와 같이 header 작성: tags는 post의 keyword를 영어로 작성
    ```
    ---
    title: "작성 예시"
    tags:
        - blog
        - example
    ---
    ```
- `#`, `##`, `###`를 사용할 경우 h3까지만 사용할 것
- `---` 과 같은 line break는 가급적이면 사용하지 말 것
- post내에서 image를 사용할 경우 
  - `root` 경로의 `assets/images` 내에서 post와 동일한 이름의 디렉토리를 생성
  - image를 해당 경로에 저장
  - post에서 아래의 예시처럼 사용
    ```
    ![image name](/assets/images/yyyy-mm-dd-title/image1.png)
    ```
    
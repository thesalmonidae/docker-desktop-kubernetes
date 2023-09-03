ARG             PYTHON_TAG
FROM            python:${PYTHON_TAG}

ARG             USER="dev"
ARG             FLASK_VERSION="2.3.3"

RUN             pip install Flask==${FLASK_VERSION} && \
                adduser -D ${USER}

COPY            app/ /app

USER            ${USER}

ENTRYPOINT      ["python3", "/app/app.py"]

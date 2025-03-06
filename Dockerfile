ARG VERSION=v0.33.0

FROM ghcr.io/runatlantis/atlantis:$VERSION

ARG HTTP_PROXY
ARG HTTPS_PROXY

ENV HTTP_PROXY=$HTTP_PROXY
ENV HTTPS_PROXY=$HTTPS_PROXY

USER root

RUN apk add --no-cache --update \
    git \
    rust \
    cargo \
    build-base \
    bzip2-dev \
    libffi-dev \
    linux-headers \
    openssl-dev \
    readline-dev \
    sqlite-dev \
    zlib-dev

USER atlantis

ARG PYTHON_VERSION=3.8.3

ARG PYENV_HOME=/home/atlantis/.pyenv

RUN git clone --depth 1 https://github.com/pyenv/pyenv.git $PYENV_HOME && \
    rm -rfv $PYENV_HOME/.git

ENV PATH=$PYENV_HOME/versions/$PYTHON_VERSION/bin:$PYENV_HOME/shims:$PYENV_HOME/bin:$PATH

RUN pyenv install $PYTHON_VERSION && \
    pyenv global $PYTHON_VERSION && \
    pip install --upgrade pip && \
    pip install --upgrade 'poetry>=1.0.5' && \
    poetry config virtualenvs.create false

RUN mkdir -p /tmp/atlantis-install

RUN mkdir -p /home/atlantis/.terraform.d/plugins; chown -R atlantis:atlantis /home/atlantis/.terraform.d/plugins

USER atlantis
RUN chmod 0755 ~/.terraform.d/plugins/* || true

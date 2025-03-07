ARG PY_VERSION=3.13

FROM python:${PY_VERSION} AS base

FROM base AS builder
ARG PY_VERSION
ARG WITH_S3

RUN mkdir /install
WORKDIR /install
RUN pip install --target="/install" --upgrade pip setuptools wheel
ADD requirements_s3.txt /install
ADD requirements.txt /install
RUN if [ ! -z "$WITH_S3" ] \
     ; then \
     pip install --target="/install" \
        -r requirements.txt \
        -r requirements_s3.txt \
     ; else \
     pip install --target="/install" \
        -r requirements.txt \
     ; fi



FROM python:${PY_VERSION}-slim
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

ARG PY_VERSION
ARG WITH_S3

COPY --from=builder /install /usr/local/lib/python${PY_VERSION}/site-packages
RUN mkdir /bandersnatch && mkdir /conf && chmod 777 /conf
WORKDIR /bandersnatch
COPY setup.cfg /bandersnatch
COPY setup.py /bandersnatch
COPY README.md /bandersnatch
COPY LICENSE /bandersnatch
COPY src /bandersnatch/src
RUN if [ ! -z "$WITH_S3" ] \
     ; then \
     pip --no-cache-dir install /bandersnatch/[s3] \
     ; else \
     pip --no-cache-dir install /bandersnatch/ \
     ; fi

CMD ["python", "/bandersnatch/src/runner.py", "3600"]

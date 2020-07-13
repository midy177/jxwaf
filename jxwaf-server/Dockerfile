################################################
# Dockerfile to build jxWAF container images   #
# Based on centos 8                            #
#                                              #
################################################
#Set the base image to jessie
FROM python:alpine3.12
#File Author
MAINTAINER Wuluoyong

ADD jxwaf-server-devel /jxwaf-server-devel
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --no-cache --virtual .build-deps gcc make mysql mysql-dev \
    #&& python -m pip install --upgrade pip \
    && pip install -r /jxwaf-server-devel/requirements.txt -i https://pypi.douban.com/simple \
    && apk del .build-deps

ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["python","/jxwaf-server-devel/manage.py","runserver","0.0.0.0:80"]
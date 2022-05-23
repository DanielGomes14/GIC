FROM python:3.8-buster
SHELL ["/bin/bash", "-c"]

# Set up virtualenv
#ENV VIRTUAL_ENV=/home/mediacms.io
#ENV PATH="$VIRTUAL_ENV/bin:$PATH"
#ENV PIP_NO_CACHE_DIR=1

RUN mkdir -p /home/mediacms.io/mediacms/{logs} && cd /home/mediacms.io
#RUN apt-get install python3-dev && apt-get install gcc && libc-dev
# Install dependencies:
COPY requirements.txt .
RUN pip install -r requirements.txt

#Setup working directory
WORKDIR /home/mediacms.io/mediacms
ADD ./mediacmsfiles /home/mediacms.io/mediacms

RUN apt-get update && apt-get -y dist-upgrade
RUN apt install -y netcat


#Install Bento4
RUN wget -q http://zebulon.bok.net/Bento4/binaries/Bento4-SDK-1-6-0-637.x86_64-unknown-linux.zip && \
    unzip Bento4-SDK-1-6-0-637.x86_64-unknown-linux.zip -d ../bento4 && \
    mv ../bento4/Bento4-SDK-1-6-0-637.x86_64-unknown-linux/* ../bento4/ && \
    rm -rf ../bento4/Bento4-SDK-1-6-0-637.x86_64-unknown-linux && \
    rm -rf ../bento4/docs && \
    rm Bento4-SDK-1-6-0-637.x86_64-unknown-linux.zip

#Install ffmpeg
COPY ffmpeg-release-amd64-static.tar.xz .

RUN mkdir -p ffmpeg-tmp && \
    tar -xf ffmpeg-release-amd64-static.tar.xz --strip-components 1 -C ffmpeg-tmp && \
    cp -v ffmpeg-tmp/ffmpeg ffmpeg-tmp/ffprobe ffmpeg-tmp/qt-faststart /usr/local/bin && \
    rm -rf ffmpeg-tmp ffmpeg-release-amd64-static.tar.xz


EXPOSE 9000 80
ADD entrypoint.sh .
RUN chmod +x ./entrypoint.sh

ENTRYPOINT ["/home/mediacms.io/mediacms/entrypoint.sh"]
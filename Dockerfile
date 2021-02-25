FROM ubuntu:16.04

RUN apt -y update
RUN apt -y install wget
RUN apt -y install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget
RUN wget https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tar.xz
RUN tar -xf Python-3.7.2.tar.xz
RUN apt -y update

RUN apt-get -y install software-properties-common python-software-properties && add-apt-repository -y ppa:deadsnakes/ppa && apt-get -y update
RUN apt-get -y install python3.7
RUN apt-get -y update && \
    apt-get -y install sudo && \
    sudo apt-get update -qq && \
    apt-get install -y python3-pip \
                       python3-dev \
                       build-essential \
                       software-properties-common \
                       openjdk-8-jdk \
                       git \
                       wget && \
    sudo add-apt-repository ppa:openjdk-r/ppa && \
         apt-get update -qq && \
         apt-get install -y openjdk-8-jdk

RUN ln -svT "/usr/lib/jvm/java-8-openjdk-$(dpkg --print-architecture)" /docker-java-home
ENV JAVA_HOME=/docker-java-home \
    JCC_JDK=/docker-java-home

RUN sudo apt-get install gcc python3-dev
RUN python3 -m pip install --no-binary :all: psutil
RUN sudo apt-get install -y jcc && \
    python3.7 -m pip install --upgrade pip \
                                     wheel \
                                     JCC \
                                     urllib3 \
                                     jupyter \
			              nilearn \
			              sklearn \
			              nose \
			              matplotlib \
			              scipy 

RUN useradd --no-user-group --create-home --shell /bin/bash neuro && \
    mkdir /home/neuro/nighres
COPY build.sh cbstools-lib-files.sh setup.py MANIFEST.in README.rst LICENSE imcntk-lib-files.sh /home/neuro/nighres/
COPY nighres /home/neuro/nighres/nighres

RUN cd /home/neuro/nighres && \
    ./build.sh && \
    cd /home/neuro/nighres && python3 -m pip install . && \
    mkdir /home/neuro/notebooks && \
    chown -R neuro /home/neuro

COPY docker/jupyter_notebook_config.py /etc/jupyter/

EXPOSE 8888

ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

EXPOSE 8888
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0"]

USER neuro

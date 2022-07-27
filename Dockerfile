FROM ubuntu

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y openssh-server sudo openjdk-8-jdk curl git yarn zip psmisc gnome-keyring libsecret-tools && \
    apt-get clean

RUN groupadd -g 53559 jellyfin && \
    useradd -u 53559 -g jellyfin -m -s /bin/bash jellyfin

# Set JAVA_HOME variable
RUN echo export JAVA_HOME=`echo -ne '\n' | echo \`update-alternatives --config java\` | cut -d "(" -f2 | cut -d ")" -f1 | sed 's/.........$//'` >> /etc/bashrc
RUN mkdir /var/run/sshd

RUN curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash - && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g webpack webpack-cli

USER jellyfin

RUN wget -q http://download.tizen.org/sdk/Installer/tizen-studio_4.6/web-cli_Tizen_Studio_4.6_ubuntu-64.bin -O ~/tizen-studio.bin && \
    chmod +x ~/tizen-studio.bin && \
    ~/tizen-studio.bin --accept-license ~/tizen-studio && \
    rm ~/tizen-studio.bin && \
    rm -rf ~/.package-manager/run/tizensdk_*/

RUN echo 'export PATH=$PATH:~/tizen-studio/tools/ide/bin:~/tizen-studio/tools' > ~/.bashrc

USER root

COPY root/ /
RUN chmod +x /init/*

USER jellyfin

ENV RUN_BUILD=true
ENV RUN_DEPLOY=true
ENV TIZEN_YOUR_NAME="Default"
ENV TIZEN_YOUR_COUNTRY="DE"
ENV TIZEN_YOUR_CITY="DefaultCity"
ENV TIZEN_YOUR_ORGANISATION="DefaultOrg"
ENV TIZEN_YOUR_EMAIL="default@mail.de"
ENV TIZEN_CERT_NAME="TizenCert"
ENV TIZEN_CERT_FILE_NAME="tizencert"
ENV TIZEN_CERT_PASSWORD="1234"

ENTRYPOINT [ "/init/0-entrypoint.sh" ]
WORKDIR /home/jellyfin/data

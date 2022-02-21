################################################################################
# Magna Presstec - Dockerfile
################################################################################

#Set Base Image
#FROM debian:latest
FROM debian:bullseye

#More Information: https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

#Ensures that the shell is not printing interactive messages
ARG DEBIAN_FRONTEND=noninteractive
#Name of the new non-root user to create
ARG APP_USER

RUN echo "###### Check arguments ######" && \
	if [ -z $APP_USER ]; then \
		APP_USER=appuser; \
	fi

RUN echo "###### Install needed applications ######" && \
	apt-get update -y && \
	apt-get install -y --no-install-recommends git nano zsh curl wget ca-certificates gosu

#Add non root user
RUN echo "###### Add non-root user ######" && \
	groupadd -r -g 999 $APP_USER && \
    useradd -r -u 999 -g $APP_USER $APP_USER && \
	mkhomedir_helper $APP_USER

#Add non-root user to sudoers
RUN echo "###### Install user and sudo ######" && \ 
	apt-get install -y --no-install-recommends sudo  && \
    echo "$APP_USER ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/user && \
    chmod 0440 /etc/sudoers.d/user

#Install oh my zsh and change default theme
RUN gosu $APP_USER sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
	gosu $APP_USER sed -i 's/robbyrussell/dallas/g' "$(eval echo ~$APP_USER)/.zshrc"

#Install WebServer nginx
RUN apt-get install -y --no-install-recommends nginx

#Install Oracle Java
#Set Variables
ENV JAVA_PKG=https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz \
	JAVA_HOME=/usr/share/java/jdk-17

RUN set -eux; \ 
	JAVA_SHA256=$(curl "$JAVA_PKG".sha256) ; \
	curl --output /tmp/jdk.tgz "$JAVA_PKG" && \
	echo "$JAVA_SHA256 */tmp/jdk.tgz" | sha256sum -c; \
	mkdir -p "$JAVA_HOME"; \
	tar --extract --file /tmp/jdk.tgz --directory "$JAVA_HOME" --strip-components 1 && \
	ln -s $JAVA_HOME/bin/java /usr/bin/java

#Add java home dictionary to path
ENV	PATH=$JAVA_HOME/bin:$PATH

#Install .net6.0
#Set Variables
ENV dotNet_PKG=https://download.visualstudio.microsoft.com/download/pr/32230fb9-df1e-4b86-b009-12d889cbfa8a/f57a5d92327bb2936caac94bcf602c22/aspnetcore-runtime-6.0.1-linux-x64.tar.gz \
	DOTNET_HOME=/usr/share/dotnet

#Download .net6.0
RUN curl --output /tmp/dotnet.tar.gz "$dotNet_PKG"

#Extract
RUN mkdir $DOTNET_HOME && \
	tar zxf /tmp/dotnet.tar.gz -C $DOTNET_HOME && \
	ln -s $DOTNET_HOME/dotnet /usr/bin/dotnet

#Add .net home dictionary to path
ENV	PATH=$DOTNET_HOME/bin:$PATH

#Install openSSH
########################### ! ToDo:  DO NOT USE IN PRODUCTION! Start ########################### 
RUN echo "###### Install SSH and key files ######" && \
	apt-get install -y --no-install-recommends openssh-server && \
	sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config

#Copy allowed keys to image
RUN gosu $APP_USER mkdir "$(eval echo ~$APP_USER)/.ssh"
COPY authorized_keys /tmp/authorized_keys
RUN mv -f "/tmp/authorized_keys" "$(eval echo ~$APP_USER)/.ssh/authorized_keys"
########################### ! ToDo:  DO NOT USE IN PRODUCTION! End #############################

#Cleanup
RUN	echo "###### Cleanup ######" && \
	rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

#Switch to new user
USER $APP_USER

#ToDo: Add local files here or in startup.sh (z.B. via git)
#COPY applications/ /home/$APP_USER/applications

#Copy startup.sh to image
COPY start.sh /usr/bin/start.sh

#Create startup command for container
CMD ["/bin/bash", "/usr/bin/start.sh"]
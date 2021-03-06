FROM arm64v8/ubuntu:16.04
#FROM aarch64/ubuntu:16.04

#Development Tools
RUN apt-get update && \
    apt-get install -y tmux \
                       wget zip unzip curl \
                       bash-completion git \
                       software-properties-common

# Nvidia driver
WORKDIR /tmp
Add nvidia_drivers.tbz2 /

# Nvidia config
Add config.tbz2 /

# Nvidia cuda
WORKDIR /tmp
RUN wget http://developer.download.nvidia.com/devzone/devcenter/mobile/jetpack_l4t/013/linux-x64/cuda-repo-l4t-8-0-local_8.0.84-1_arm64.deb
# COPY cuda-repo-l4t-8-0-local_8.0.84-1_arm64.deb ./
RUN wget http://developer.download.nvidia.com/devzone/devcenter/mobile/jetpack_l4t/013/linux-x64/libcudnn6_6.0.21-1+cuda8.0_arm64.deb && \
    wget http://developer.download.nvidia.com/devzone/devcenter/mobile/jetpack_l4t/013/linux-x64/libcudnn6-dev_6.0.21-1+cuda8.0_arm64.deb && \
    wget http://developer.download.nvidia.com/devzone/devcenter/mobile/jetpack_l4t/013/linux-x64/libcudnn6-doc_6.0.21-1+cuda8.0_arm64.deb
# COPY libcudnn6_6.0.21-1+cuda8.0_arm64.deb libcudnn6-dev_6.0.21-1+cuda8.0_arm64.deb libcudnn6-doc_6.0.21-1+cuda8.0_arm64.deb ./
RUN apt-get update
RUN dpkg -i cuda-repo-l4t-8-0-local_8.0.84-1_arm64.deb && \
    rm cuda-repo-l4t-8-0-local_8.0.84-1_arm64.deb && \
    dpkg -i libcudnn6_6.0.21-1+cuda8.0_arm64.deb && \
    rm libcudnn6_6.0.21-1+cuda8.0_arm64.deb && \
    dpkg -i libcudnn6-dev_6.0.21-1+cuda8.0_arm64.deb && \
    rm libcudnn6-dev_6.0.21-1+cuda8.0_arm64.deb && \
    dpkg -i libcudnn6-doc_6.0.21-1+cuda8.0_arm64.deb && \
    rm libcudnn6-doc_6.0.21-1+cuda8.0_arm64.deb && \
    apt-get update && \
    apt-get install -y cuda-toolkit-8-0 && \
    usermod -aG video root && \
    echo "# Add CUDA bin & library paths:" >> ~/.bashrc && \
    echo "export PATH=/usr/local/cuda/bin:$PATH" >> ~/.bashrc && \
    echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib:/usr/lib/aarch64-linux-gnu/tegra:/usr/lib/aarch64-linux-gnu/tegra-egl:$LD_LIBRARY_PATH" >> ~/.bashrc

# Vim
RUN apt-get install -y  vim-nox && \
    curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh -o /tmp/install.sh
WORKDIR /tmp
RUN /bin/bash -c "sh ./install.sh" && \
    git clone https://github.com/tomasr/molokai && \
    mkdir -p ~/.vim/colors && \
    cp ./molokai/colors/molokai.vim ~/.vim/colors/
COPY .vimrc /root/.vimrc

# Tmux
WORKDIR /tmp
COPY .tmux.conf /root/.tmux.conf

# QtCreator
RUN apt-get update && apt-get install -y qtcreator

# Pycharm
RUN apt-get update && apt-get install -y openjdk-8-jdk
WORKDIR /opt
ARG PYCHARM_VERSION=2017.2.4
RUN wget https://download.jetbrains.com/python/pycharm-community-$PYCHARM_VERSION.tar.gz && \
    tar -zxvf pycharm-community-$PYCHARM_VERSION.tar.gz && \
    rm pycharm-community-$PYCHARM_VERSION.tar.gz
RUN mv pycharm-community-$PYCHARM_VERSION pycharm-community && \
    touch /usr/local/bin/pycharm && \
    echo "#!/bin/bash" >> /usr/local/bin/pycharm-ros && \
    echo "bash -i -c \"/opt/pycharm-community/bin/pycharm.sh\" %f" >> /usr/local/bin/pycharm && \
    chmod u+x /usr/local/bin/pycharm

## VS Code (not working)
#WORKDIR /tmp
#RUN apt-get install -y apt-transport-https && \
#    wget -O - https://code.headmelted.com/installers/apt.sh > install-vscode.sh && \
#    chmod +x install-vscode.sh && \
#    ./install-vscode.sh &&\
#    rm install-vscode.sh
#RUN touch /usr/local/bin/code-oss-as-root && \
#    echo "#!/bin/bash" >> /usr/local/bin/code-oss-as-root && \
#    echo "code-oss --user-data-dir=\"/root\" \$@" >> /usr/local/bin/code-oss-as-root && \
#    chmod +x /usr/local/bin/code-oss-as-root

WORKDIR /root
CMD ["/bin/bash"]

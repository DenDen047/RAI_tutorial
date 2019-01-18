#!/bin/bash

### General configuration of bash and flags for apt-get and add-apt-repository
set -e
set -o xtrace

APT_GET_FLAGS=-qq
ADD_APT_REPOSITORY_FLAGS=-y

########### installed CUDA and CudNN here ##############
### CUDA by downloading deb file and follow instructions on download page
### Do not change NVidia version since cuda installer will automatically update it to what it needs
### CudNN by downloading CudNN file and copy paste it to cp cuda/include/* usr/local/cuda/include/ and cp cuda/lib64/* usr/local/cuda/lib64/

#add-apt-repository ppa:fkrull/deadsnakes
#apt-get update
#apt-get install -y python3.5

### Bazel 0.5.4
apt-get install -y pkg-config zip g++ zlib1g-dev unzip python wget
wget https://github.com/bazelbuild/bazel/releases/download/0.5.4/bazel-0.5.4-installer-linux-x86_64.sh
chmod +x bazel-0.5.4-installer-linux-x86_64.sh
./bazel-0.5.4-installer-linux-x86_64.sh --prefix=/usr
rm bazel-0.5.4-installer-linux-x86_64.sh

## Swig
apt-get install -y $APT_GET_FLAGS swig

## Setting up python and virtualenv

#python
apt-get install -y software-properties-common
add-apt-repository $ADD_APT_REPOSITORY_FLAGS ppa:fkrull/deadsnakes

# python 3.5
apt-get install -y $APT_GET_FLAGS python3.5-dev

# Installing pip
apt-get install -y $APT_GET_FLAGS python-pip
apt-get install -y $APT_GET_FLAGS python3-pip
pip3 install --upgrade pip

# Installing virtualenv
apt-get install -y $APT_GET_FLAGS python-virtualenv
apt-get install -y $APT_GET_FLAGS python3-setuptools

# Installing virtualenvwrapper
pip3 install $APT_GET_FLAGS virtualenvwrapper
sed -i '/WORKON_HOME/d' $HOME/.bashrc
printf 'export WORKON_HOME=~/.virtualenvs\n' >> $HOME/.bashrc
sed -i '/VIRTUALENVWRAPPER_PYTHON/d' $HOME/.bashrc
printf 'export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3\n' >> $HOME/.bashrc
sed -i '/source virtualenvwrapper.sh/d' $HOME/.bashrc
printf 'source virtualenvwrapper.sh\n' >> $HOME/.bashrc
source ~/.bashrc

# Enable
source ~/.bashrc
VIRTUALENVWRAPPER_PYTHON='/usr/bin/python3'
source virtualenvwrapper.sh

# Generate virtualenv for tensorflow (called tensorflow)
VIRTUALENV_NAME=tensorflow
rm -rf "$WORKON_HOME/$VIRTUALENV_NAME"
mkvirtualenv -p python3.5 $VIRTUALENV_NAME || true

# Activate virtualenv
workon $VIRTUALENV_NAME

# Installing python-dev
apt-get install -y $APT_GET_FLAGS python-dev
pip3 install numpy

##### now run configure
cd "$RAI_ROOT"
cd ./deepLearning
rm -rf tensorflow
git clone https://github.com/tensorflow/tensorflow.git
cd tensorflow
git checkout tags/v1.3.0

##  Debug Tensorflow build error(Temporary 14.09.17)
sed -i '\@https://github.com/google/protobuf/archive/0b059a3d8a8f8aa40dde7bea55edca4ec5dfea66.tar.gz@d' tensorflow/workspace.bzl

echo "select the following path as your python path: " $WORKON_HOME/tensorflow/bin/python
bazel clean --expunge
./configure

echo -n "do you have gpu (y/n)? "
read answer
if echo "$answer" | grep -iq "^y" ;then
    bazel build -c opt --config=cuda --copt="-mtune=native" --copt="-O3" tensorflow:libtensorflow_cc.so tensorflow:libtensorflow.so --genrule_strategy=standalone --spawn_strategy=standalone
    pip3 install --upgrade tensorflow-gpu==1.3.0
else
    bazel build -c opt --copt="-mtune=native" --copt="-O3" tensorflow:libtensorflow_cc.so tensorflow:libtensorflow.so --genrule_strategy=standalone --spawn_strategy=standalone
    pip3 install --upgrade tensorflow
fi

# Update protobuf
cd $HOME/.cache/bazel/_bazel_root
for d in */ ; do
    if [ "$d" != "install/" ]; then
	echo "Entering $d"
	cd $d
	cd external/protobuf
	./autogen.sh && ./configure && make -j3 && make install
    fi
done

exit
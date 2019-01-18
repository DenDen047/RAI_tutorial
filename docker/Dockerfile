FROM nvidia/cuda:8.0-cudnn6-runtime-ubuntu16.04

# init
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y git


# RAI
WORKDIR /opt
RUN git clone https://bitbucket.org/leggedrobotics/rai.git
WORKDIR /opt/rai
ADD install.sh /opt/rai/install.sh
RUN chmod +x install.sh
RUN ./install.sh



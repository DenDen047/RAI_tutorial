FROM tensorflow/tensorflow:1.3.0-gpu-py3

# init
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y git sudo wget

# RAI
WORKDIR /opt
RUN git clone https://bitbucket.org/leggedrobotics/rai.git
WORKDIR /opt/rai
ADD install.sh /opt/rai/install.sh
RUN chmod +x install.sh
RUN ./install.sh
RUN mkdir build && cd build && cmake .. -DRAI_APP=examples/poleBalwithTRPO && make -j

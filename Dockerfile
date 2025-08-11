# Use an appropriate base image with cmake and git
FROM ubuntu:20.04

# Set environment variable to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages including OpenMPI
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    make \
    g++ \
    openmpi-bin \
    libopenmpi-dev \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Clone the repository
RUN git clone https://github.com/soedinglab/hh-suite.git

# Create build directory and navigate into it
RUN mkdir -p hh-suite/build && cd hh-suite/build \
    && cmake -DCMAKE_INSTALL_PREFIX=. .. \
    && make -j 4 && make install

# Set the PATH environment variable
ENV PATH="/hh-suite/build/bin:/hh-suite/build/scripts:$PATH"

# Default command (optional)
CMD ["bash"]

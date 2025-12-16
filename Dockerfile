# Use Ubuntu as base - force amd64 for Android build tools compatibility and best performance via Rosetta 2
FROM --platform=linux/amd64 ubuntu:22.04

# Set environment variables early
ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    openjdk-17-jdk \
    wget \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Find and set JAVA_HOME by creating a symlink
RUN JAVA_DIR=$(dirname $(dirname $(readlink -f $(which java)))) && \
    ln -s $JAVA_DIR /opt/java && \
    echo "JAVA_HOME set to: $JAVA_DIR"

ENV JAVA_HOME=/opt/java
ENV PATH=${PATH}:${JAVA_HOME}/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools

# Download and install Android command line tools
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    cd ${ANDROID_HOME}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
    unzip commandlinetools-linux-11076708_latest.zip && \
    rm commandlinetools-linux-11076708_latest.zip && \
    mv cmdline-tools latest

# Accept licenses and install required SDK components
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0"

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Make gradlew executable
RUN chmod +x ./gradlew

# Run the test command
# CMD ["./gradlew", "testFdroidDebug"]
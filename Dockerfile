FROM debian:stable-slim

# Use local checkout as build source
COPY . /tmp/minuimus-src

RUN \
echo "************************************************************" && \
echo "****  update and install build packages ****" && \
apt-get update -qy && \
 apt-get install -qy --no-install-recommends \
 ca-certificates \
 curl \
 g++ \
 gcc \
 git \
 unzip \
 zlib1g-dev \
 libpng-dev \
 make \
 wget && \
echo "************************************************************" && \
echo "**** install bazelisk ****" && \
ARCH=$(dpkg --print-architecture) && \
if [ "$ARCH" = "amd64" ]; then BAZELISK_ARCH="amd64"; else BAZELISK_ARCH="arm64"; fi && \
wget -O /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-${BAZELISK_ARCH} && \
chmod +x /usr/local/bin/bazel && \
echo "************************************************************" && \
echo "**** install required and optional packages ****" && \
 apt-get install -qy --no-install-recommends \
 advancecomp \
 brotli \
 bzip2 \
 cabextract \
 ffmpeg \
 file \
 flac \
 gifsicle \
 imagemagick \
 jbig2dec \
 jpegoptim \
 libjpeg-progs \
 libtiff-tools \
 lzip \
 mupdf-tools \
 optipng \
 p7zip-full \
 parallel \
 perl \
 poppler-utils \
 qpdf \
 rzip \
 unrar-free \
 webp \
 zip \
 zpaq && \
echo "************************************************************" && \
echo "**** compile minuimus and extras ****" && \
cd /tmp/minuimus-src && \
make install && \
rm -r /tmp/minuimus-src && \
echo "************************************************************" && \
echo "**** install flexiGIF ****" && \
mkdir -p /tmp/flexigif-src && \
cd /tmp/flexigif-src && \
wget -O /tmp/flexigif-src/flexigif https://create.stephan-brumme.com/flexigif-lossless-gif-lzw-optimization/flexiGIF.2018.11a && \
mv flexigif /usr/bin/flexigif && \
chmod +x /usr/bin/flexigif && \
rm -r /tmp/flexigif-src && \
echo "************************************************************" && \
echo "**** compile gif2apng ****" && \
mkdir -p /tmp/gif2apng-src && \
cd /tmp/gif2apng-src && \
wget -O gif2apng.zip "https://master.dl.sourceforge.net/project/gif2apng/1.9/gif2apng-1.9-src.zip?viasf=1" && \
unzip gif2apng.zip && \
make && \
mv gif2apng /usr/bin/gif2apng && \
rm -r /tmp/gif2apng-src && \
echo "************************************************************" && \
echo "**** install pdfsizeopt, pngout, jbig2 and dependencies ****" && \
mkdir /var/opt/pdfsizeopt && \
cd /var/opt/pdfsizeopt  && \
wget -O pdfsizeopt_libexec_linux.tar.gz https://github.com/pts/pdfsizeopt/releases/download/2017-01-24/pdfsizeopt_libexec_linux-v3.tar.gz && \
tar xzvf pdfsizeopt_libexec_linux.tar.gz && \
rm -f pdfsizeopt_libexec_linux.tar.gz && \
ln pdfsizeopt_libexec/pngout /usr/bin/pngout && \
ln pdfsizeopt_libexec/jbig2 /usr/bin/jbig2 && \
ln pdfsizeopt_libexec/png22pnm /usr/bin/png22pnm && \
ln pdfsizeopt_libexec/sam2p /usr/bin/sam2p && \
wget -O pdfsizeopt.single https://raw.githubusercontent.com/pts/pdfsizeopt/master/pdfsizeopt.single && \
chmod +x pdfsizeopt.single && \
ln -s pdfsizeopt.single pdfsizeopt && \
echo "************************************************************" && \
echo "**** compile leanify ****" && \
mkdir -p /tmp/leanify-src && \
cd /tmp/leanify-src && \
wget -O leanify.zip https://github.com/JayXon/Leanify/archive/refs/heads/master.zip && \
unzip leanify.zip && \
rm leanify.zip && \
cd Leanify-master && \
make && \
mv leanify /usr/bin/leanify && \
rm -r /tmp/leanify-src && \
echo "************************************************************" && \
echo "**** compile knusperli ****" && \
mkdir -p /tmp/knusperli-src && \
cd /tmp/knusperli-src && \
wget -O knusperli.zip https://github.com/google/knusperli/archive/refs/heads/master.zip && \
unzip knusperli.zip && \
rm knusperli.zip && \
cd knusperli-master && \
CC=gcc bazel build :knusperli && \
mv bazel-bin/knusperli /usr/bin/knusperli && \
rm -r /tmp/knusperli-src && \
echo "************************************************************" && \
echo "**** compile imgdataopt ****" && \
mkdir -p /tmp/imgdataopt && \
cd /tmp/imgdataopt && \
wget -O imgdataopt.zip https://github.com/pts/imgdataopt/archive/refs/heads/master.zip && \
unzip imgdataopt.zip && \
cd imgdataopt-master && \
make && \
mv imgdataopt /usr/bin/imgdataopt && \
rm -r /tmp/imgdataopt && \
echo "************************************************************" && \
echo "**** Cleanup ****" && \
rm -f /usr/local/bin/bazel && \
apt-get purge -qy \
 curl \
 g++ \
 gcc \
 git \
 unzip \
 zlib1g-dev \
 libpng-dev \
 make \
 wget && \
apt-get autoremove -qy && \
rm -rf /var/lib/apt/lists/* && \
cat

VOLUME /data
ENTRYPOINT ["minuimus.pl"]

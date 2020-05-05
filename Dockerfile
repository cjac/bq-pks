# bq-pks
FROM debian:stable-backports

# Install some gcloud dependencies
RUN apt-get update \
    && apt-get install -y gnupg curl \
    && apt-get clean

# Install gcloud
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
      | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
      | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - \
    && apt-get update -y \
    && apt-get install google-cloud-sdk -y \
    && apt-get clean

# Install some perl dependencies
RUN apt-get update \
    && apt-get install -y make gcc unzip \
                          cpanminus \
                          libplack-perl libclass-loader-perl libconvert-ascii-armour-perl \
                          libdigest-md2-perl libmath-prime-util-perl libfile-homedir-perl libsub-uplevel-perl \
                          libtest-exception-perl libdata-buffer-perl libfile-which-perl libtie-encryptedhash-perl \
                          libsort-versions-perl \
                          libcrypt-blowfish-perl libcrypt-rijndael-perl libcrypt-des-ede3-perl libcrypt-des-perl \
                          libcrypt-twofish-perl libcrypt-cbc-perl libcrypt-dsa-perl libcrypt-cast5-perl \
    && apt-get clean

# Install some perl modules
RUN cpanm --local-lib=~/perl5 local::lib \
    && eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib) \
    ; cpanm install Math::Pari \
                    Statistics::ChiSquare \
                    Alt::Crypt::RSA::BigInt \
                    Crypt::RIPEMD160 \
                    Crypt::IDEA \
                    Crypt::Random \
                    Crypt::CAST5_PP \
                    Crypt::OpenPGP

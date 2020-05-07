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
                          cpanminus liblocal-lib-perl starman \
			  liburl-encode-perl \
                          libplack-perl libclass-loader-perl libconvert-ascii-armour-perl \
                          libdigest-md2-perl libmath-prime-util-perl libfile-homedir-perl libsub-uplevel-perl \
                          libtest-exception-perl libdata-buffer-perl libfile-which-perl libtie-encryptedhash-perl \
                          libsort-versions-perl \
                          libcrypt-blowfish-perl libcrypt-rijndael-perl libcrypt-des-ede3-perl libcrypt-des-perl \
                          libcrypt-twofish-perl libcrypt-cbc-perl libcrypt-dsa-perl libcrypt-cast5-perl \
    && apt-get clean

# set up the environment
ENV PROJECT_NAME=bq-pks
ENV WORKDIR=/opt/${PROJECT_NAME}

# initialize local::lib under ${WORKDIR}
RUN perl -I ${WORKDIR}/perl5/lib/perl5/ -Mlocal::lib=${WORKDIR}/perl5

# pretend like we ran eval $(perl -I ${WORKDIR}/perl5/lib/perl5/ -Mlocal::lib=${WORKDIR}/perl5)
ENV PATH="${WORKDIR}/bin${PATH:+:${PATH}}"
ENV PERL5LIB="${WORKDIR}/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
ENV PERL_LOCAL_LIB_ROOT="${WORKDIR}${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
ENV PERL_MB_OPT="--install_base \"${WORKDIR}\""
ENV PERL_MM_OPT="INSTALL_BASE=${WORKDIR}"

# Install some perl modules
RUN eval $(perl -I ${WORKDIR}/perl5/lib/perl5/ -Mlocal::lib=${WORKDIR}/perl5) \
    && cpanm --local-lib=${WORKDIR}/perl5 \
          install Math::Pari \
                  Statistics::ChiSquare \
                  Alt::Crypt::RSA::BigInt \
                  Crypt::RIPEMD160 \
                  Crypt::IDEA \
                  Crypt::Random \
                  Crypt::CAST5_PP \
                  Crypt::OpenPGP

# Deploy HKP listener code
COPY hkp.psgi ${WORKDIR}/

# Deploy HKP Handler code
COPY lib/HKP/Handler/GnuPG.pm ${WORKDIR}/lib/HKP/Handler/GnuPG.pm

# Start the HTTP Keyserver Protocol server
CMD eval $(perl -I ${WORKDIR}/perl5/lib/perl5/ -Mlocal::lib=${WORKDIR}/perl5) && starman --port 11371 ${WORKDIR}/hkp.psgi

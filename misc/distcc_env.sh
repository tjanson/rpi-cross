export DISTCC_HOSTS=vagrant-ubuntu-trusty-64.lan,cpp,lzo
export DISTCC_SKIP_LOCAL_RETRY=1
export DISTCC_VERBOSE=1
export DISTCC_LOG=distcc.log
export DISTCC_BACKOFF_PERIOD=0
export DISTCC_FALLBACK=0
export PATH=/usr/lib/distcc:${PATH}

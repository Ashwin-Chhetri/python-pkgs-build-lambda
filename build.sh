#!/bin/bash
set -ex

yum update -y
yum install -y \
    atlas-devel \
    atlas-sse3-devel \
    blas-devel \
    gcc \
    gcc-c++ \
    lapack-devel \
    python36-devel \
    python36-virtualenv \
    findutils \
    zip \
    git

do_pip () {
    pip install --upgrade pip wheel
    test -f /outputs/requirements.txt && pip install -r /outputs/requirements.txt
    pip install --no-binary numpy numpy
    pip install --no-binary scipy scipy
    pip install --no-binary pandas pandas
}

strip_virtualenv () {
    echo "venv original size $(du -sh $VIRTUAL_ENV | cut -f1)"
    find $VIRTUAL_ENV/lib64/python3.6/site-packages/ -name "*.so" | xargs strip
    echo "venv stripped size $(du -sh $VIRTUAL_ENV | cut -f1)"
    find $VIRTUAL_ENV/lib64/python3.6/site-packages/ -name "test" | xargs rm -rf
    find $VIRTUAL_ENV/lib64/python3.6/site-packages/ -name "tests" | xargs rm -rf
    echo "venv tests removed size $(du -sh $VIRTUAL_ENV | cut -f1)"
    find $VIRTUAL_ENV/lib64/python3.6/site-packages/ -name "doc" | xargs rm -rf
    find $VIRTUAL_ENV/lib64/python3.6/site-packages/ -name "docs" | xargs rm -rf
    echo "venv docs removed size $(du -sh $VIRTUAL_ENV | cut -f1)"
    # find $VIRTUAL_ENV/lib64/python3.6/site-packages/ -name "*.py" | xargs python -m py_compile
    # find $VIRTUAL_ENV/lib64/python3.6/site-packages/ -name "*.py" | xargs rm -f
    # echo "venv py files compiled size $(du -sh $VIRTUAL_ENV | cut -f1)"
    find $VIRTUAL_ENV/lib64/python3.6/site-packages/ -name "*.json" | xargs rm -f
    echo "json files removed size $(du -sh $VIRTUAL_ENV | cut -f1)"
    pushd $VIRTUAL_ENV/lib/python3.6/site-packages/ && zip -r -9 -q /tmp/partial-venv.zip * ; popd
    pushd $VIRTUAL_ENV/lib64/python3.6/site-packages/ && zip -r -9 --out /outputs/venv.zip -q /tmp/partial-venv.zip * ; popd
    echo "site-packages compressed size $(du -sh /outputs/venv.zip | cut -f1)"

    pushd $VIRTUAL_ENV && zip -r -q /outputs/full-venv.zip * ; popd
    echo "venv compressed size $(du -sh /outputs/full-venv.zip | cut -f1)"
}

shared_libs () {
    libdir="$VIRTUAL_ENV/lib64/python3.6/site-packages/lib/"
    mkdir -p $VIRTUAL_ENV/lib64/python3.6/site-packages/lib || true
    cp /usr/lib64/atlas/* $libdir
    cp /usr/lib64/libquadmath.so.0 $libdir
    cp /usr/lib64/libgfortran.so.3 $libdir
}

main () {
    mkdir -p /root/.ssh
    chmod 0700 /root/.ssh
    echo "made root/.ssh dir"
    cat /outputs/private_key.txt > ~/.ssh/id_rsa
    echo "put private key in .ssh/id_rsa"
    chmod 600 ~/.ssh/id_rsa
    echo "changed permissions on .ssh/rsa"

    /usr/bin/virtualenv-3.6 \
        --python /usr/bin/python3.6 /sklearn_build \
        --always-copy \
        --no-site-packages
    source /sklearn_build/bin/activate

    do_pip

    shared_libs

    strip_virtualenv
}
main

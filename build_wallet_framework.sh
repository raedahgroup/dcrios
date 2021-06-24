#!/bin/bash
export LIB_DIR=$(pwd)/libs
export DCRLIBWALLET_GIT_DIR=$GOPATH/src/github.com/raedahgroup/dcrlibwallet
export DCRLIBWALLET_REPO_URL=https://github.com/raedahgroup/dcrlibwallet.git

installGo(){
    echo "Installing golang"
    curl -O https://storage.googleapis.com/golang/go1.12.9.darwin-amd64.tar.gz
    sha256sum go1.12.9.darwin-amd64.tar.gz
    tar -xvf go1.12.9.darwin-amd64.tar.gz
    sudo chown -R root:root ./go
    sudo mv go /usr/local
	export GOPATH=$HOME/go
	export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
}

installGomobile(){
    echo "Installing gomobile"
    go get -u golang.org/x/mobile/cmd/gomobile
    gomobile init
}

cloneDcrlibwallet() {
	rm -rf $DCRLIBWALLET_GIT_DIR
	mkdir -p $DCRLIBWALLET_GIT_DIR
	git clone $DCRLIBWALLET_GIT_DIR
	echo "Dcrlibwallet clone complete"
}

updateDcrlibwallet() {
	cd $DCRLIBWALLET_GIT_DIR
	git pull $DCRLIBWALLET_REPO_URL master
	echo "Dcrlibwallet update complete"
}

buildDcrlibwallet() {

	if !(hash go 2>/dev/null); then
		installGo
	fi

	if !(hash gomobile 2>/dev/null); then
		installGomobile
	fi

	cd $DCRLIBWALLET_GIT_DIR
	rm -rf Dcrlibwallet.framework/
	export GO111MODULE=on && go mod vendor && export GO111MODULE=off
	gomobile bind -target=ios
}

if [ -e $DCRLIBWALLET_GIT_DIR ]
then
	echo "Dcrlibwallet folder exists in GOPATH, updating from master"
	updateDcrlibwallet;
else
	echo "Dcrlibwallet folder does not exist in GOPATH, cloning from master"
	cloneDcrlibwallet;
fi

echo "Building Dcrlibwallet Framework"
buildDcrlibwallet;

echo "Coping Dcrlibwallet framework to $LIB_DIR"
mkdir $LIB_DIR
rm -rf $LIB_DIR/Dcrlibwallet.Framework
cp -R -f Dcrlibwallet.framework $LIB_DIR/Dcrlibwallet.framework
echo "Done"

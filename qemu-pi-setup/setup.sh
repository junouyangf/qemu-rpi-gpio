#!/bin/sh
TARGET=https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2020-02-14/2020-02-13-raspbian-buster-lite
DISK="sd.img"
BOOTFS=rootfs
SIZE=256
SIZEUNIT=M
TMPMOUNT=tmpmnt
ROUTE= /home/jose/2020-02-13-raspbian-buster-lite.zip
setup_dependencies() {
	sudo apt update
	sudo apt install -y qemu-system-arm
	sudo apt install -y p7zip-full
}

download_pi_os() {
	TARGET="$1"
	wget "$TARGET.zip"
	#IMGNAME="$(7z l $(basename $TARGET).zip | awk '/  raspios/{print $NF}')"
	#if [ ! -f "$IMGNAME" ]; then
		unzip /home/jose/2020-02-13-raspbian-buster-lite.zip #Add variable for the directory
	#fi
	#Entender IMGNAME!!!
	
	echo "$IMGNAME"
	
}

get_files() {
	BOOTFS="$1"
	TMPMOUNT="$2"
	IMGNAME="$3"
	mkdir -p "$BOOTFS"
	mkdir -p "$TMPMOUNT"

	DEVNAME="$(losetup | awk "/$IMGNAME/{print \$1}")"
	losetup
	if [ "x$DEVNAME" != "x" ]; then
		sudo losetup -d "$DEVNAME"
	fi
	losetup
	sudo losetup -o $(( 8192 * 512 )) -f "$IMGNAME"
	losetup
	DEVNAME="$(losetup | awk "/$IMGNAME/{print \$1}")"
	sudo mount "$DEVNAME" "$TMPMOUNT"
	sudo cp -rav "$TMPMOUNT"/* "$BOOTFS"
	sudo chown -R "$USER:$USER" "$BOOTFS"
	sudo umount "$TMPMOUNT"
	sudo losetup -d "$DEVNAME"
	losetup

	cp -rav "$BOOTFS" "$BOOTFS.orig"
}

resize_img() {
	IMGNAME="$1"
	SIZE="$2"
	qemu-img resize -f raw /home/jose/2020-02-13-raspbian-buster-lite.img "$SIZE" #Add variable for the directory
}

cd "$HOME"

setup_dependencies
IMGNAME="$(download_pi_os "$TARGET")"
get_files "$BOOTFS" "$TMPMOUNT" "$IMGNAME"
resize_img "$IMGNAME" 2G

#!/usr/bin/env bash

main() {

  echo -e "\e[1m=================================================="
  echo "| Dump1090-Mutability installation script v0.3.1|"
  echo -e "==================================================\e[0m"

  # get required build packages
  status "Running apt-get to update package database... " info
  sudo apt-get update >/dev/null 2>&1
  status "Checking for packages required for building:" info
  status "build-essential, libusb-1.0-0-dev, pkg-config, debhelper, curl"
  status "git, adduser and fakeroot"
  APT_RESULT=$(sudo apt-get install -y fakeroot curl build-essential libusb-1.0-0-dev pkg-config debhelper git adduser|grep upgrade)
  status "$APT_RESULT" ok

  # names of the latest versions of each package
  LIBRTLSDR_VERSION=pi-package
  DUMP1090M_VERSION=master

  # URLs for source
  SOURCE_LIBRTLSDR=https://github.com/mutability/librtlsdr.git
  SOURCE_DUMP1090M=https://github.com/mutability/dump1090.git

  # Configure the build environment
  NOBUILDDIR="true"

  while [[ $NOBUILDDIR == 'true' ]]
  do
    prompt=$(status "Please enter the build directory: [$PWD/build]" "input " "93")
    read -p  "$prompt " BUILDDIR

    # If no build directory was supplied by the user use a default one.
    if [[ $BUILDDIR == '' ]]; then 
     BUILDDIR="$PWD/build" 
    fi

    # Create the build directory then make sure it exists.
    if [ ! -d "$BUILDDIR" ]; then 
      mkdir -p $BUILDDIR 
    fi

    # Check that the newly created build directory does indeed now exists.
    if [ -d "$BUILDDIR" ]; then 
        NOBUILDDIR="false"
    else
        status "Please make sure the path specified is valid or try another path." warn
    fi
  done

  # check for rtlsdr
  status "Checking for installed rtlsdr package or libraries..." info
  # If librstdr-dev package is not installed
  if [ $(dpkg-query -W -f='${Status}' librtlsdr-dev 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    # Check for out of package compiled libraried and terminate if found
    if [ -e /usr/lib/librtlsdr.so ]; then
      status "Out of package librtlsdr libraries found in /usr/lib" quit
      status "Please delete them and try this script again."
      exit 1 # terminate script
    fi
    # If librtlsdr-dev can be found in repository
    if [ $(apt-cache policy librtlsdr-dev 2>/dev/null | grep -c "Candidate:") -eq 1 ]; then
      status "librtlsdr packages not found, installing from repository..." info
      apt_result=$(sudo apt-get install -y librtlsdr-dev|grep upgrade)
      status "$apt_result" ok
     # We can't find the package in a repository
    else
      status  "librtlsdr packages not found, building and installing from GitHub" info
      sudo apt-get -y install cmake
      process $SOURCE_LIBRTLSDR $BPATH $LIBRTLSDR_VERSION librtlsdr
    fi
  else
    rtl_ver=$(dpkg-query -W -f='${Version}' librtlsdr-dev)
    status "Found rtlsdr version $rtl_ver..." ok
  fi

  # get Dump1090-Mutability from git
  process $SOURCE_DUMP1090M $BUILDDIR $DUMP1090M_VERSION dump1090-mutability

  # clean build directory?
  prompt=$(status "Would you like to delete the build directory? [Y/n]")
  read -p "$prompt " DELBUILD

  if [[ ! $DELBUILD =~ ^[Nn]$ ]]; then
    sudo rm -r $BUILDDIR
  fi

  # End script
  echo -e "\e[1m=================================================="
  echo "| Dump1090-Mutability installation complete!     |"
  echo -e "==================================================\e[0m"

exit 0
}

status() {
  case $2 in
      ok) echo -e -n "\e[92m[ ok ]" ;;
    info) echo -e -n "\e[96m[info]" ;;
    warn) echo -e -n "\e[93m[warn]" ;;
    quit) echo -e -n "\e[91m[exit]" ;;
      *)  echo -e -n "\e[30m[    ]" ;;
  esac

  echo -e " \e[1;39m$1\e[0m"
}

process() {
  source=$1
  path=$2
  ver=$3
  basename=$4
  clone $source $path $ver $basename
  build $path $basename
  for file in $BUILDDIR/$basename*.deb; do pkg_install $BUILDDIR $file; done
}

build() {
  build=$1
  basename=$2
  cd $build/$basename
  ver=$(dpkg-parsechangelog --show-field Version)
  status "Now building $basename $ver" info
  dpkg-buildpackage -b -uc
  if [ $? -eq 0 ]; then
    status "Package $basename v$ver built successfully..." ok
  else
    status "Error building $basename, script will now exit." quit
    exit 1
  fi
}

clone() {
  url=$1
  target=$2
  branch=$3
  basename=$4
  cd $target
  if [ -d $target/$basename/.git ]; then
    cd $basename
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u})
    BASE=$(git merge-base @ @{u})
    if [ $LOCAL = $REMOTE ]; then
      status "Local git repository is up-to-date" ok
    elif [ $LOCAL = $BASE ]; then
      git pull
      status "Local git repository has been updated" ok
    fi
  else
    status "Cloning $basename from $url" info
    git clone -b $branch $url $basename
    if [ $? -eq 0 ]; then
      status "$url cloned..." ok
    else
      status "Error cloning $url, script will now exit." quit
      exit 1
    fi
  fi
}

pkg_install() {
  local build=$1
  local package=$2
  status "Installing $package to system" info
  cd $build
  sudo dpkg -i $package
  if [ $? -eq 0 ]; then
    status "$package installed..." ok
  else
    status "Error installing $package, script will now exit." quit
    exit 1
  fi
}

main "$@"

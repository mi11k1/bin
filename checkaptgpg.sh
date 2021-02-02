#!/bin/bash

APT_VERSION="$(apt-get --version | head -n1 | cut -f2 -d\ )"

check_exceptions(){
#The Ubuntu keyserver now has gpg keys for most of these, but will leave this function in the script for the time being.

case $1 in
  *www.bchemnet.com_suldr*)
    echo -e "*** wget download the suldr.gpg file, install with 'apt-key add' command:"                                \\n\\n\
            "    su -c 'wget -q -O- http://www.bchemnet.com/suldr/suldr.gpg | apt-key add -'"                          \\n ;;

  *www.daveserver.info_antiX_debs*)
    echo -e "*** wget download the key.pub file, install with 'apt-key add' command:"                                  \\n\\n\
            "    su -c 'wget -q -O- http://www.daveserver.info/antiX/debs/key.pub | apt-key add -'"                    \\n ;;

  *deb-multimedia.org*)
    echo -e "*** install the deb-multimedia-keyring package:"                                                          \\n\\n\
            "    su -c 'apt-get install deb-multimedia-keyring'"                                                       \\n ;;

  *download.tuxfamily.org*)
    echo -e "*** wget download the gericom.asc file, install with 'apt-key add' command:"                              \\n\\n\
            "    su -c 'wget -q -O- http://download.tuxfamily.org/gericom/gericom.asc | apt-key add -'"                \\n ;;

  *dl.google.com_linux*)
    echo -e "*** wget download the linux_signing_key.pub file, install with 'apt-key add' command:"                    \\n\\n\
            "    su -c 'wget -q -O- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'"            \\n ;;

  *deb.opera.com_*)
    echo -e "*** wget download the archive.key file, install with 'apt-key add' command:"                              \\n\\n\
            "    su -c 'wget -q -O- http://deb.opera.com/archive.key | apt-key add -'"                                 \\n ;;

  *siduction*)
    echo -e "*** install the siduction-archive-keyring package:"                                                       \\n\\n\
            "    su -c 'apt-get install siduction-archive-keyring'"                                                    \\n ;;

  *qt-kde.debian.net*)
    echo -e "*** install the pkg-kde-archive-keyring package:"                                                         \\n\\n\
            "    su -c 'apt-get install pkg-kde-archive-keyring'"                                                      \\n ;;

  *download.virtualbox.org_virtualbox*)
    echo -e "*** wget download the oracle_vbox_2016.asc file:"                                                              \\n\\n\
            "    su -c 'wget -q -O- http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc | apt-key add -'" \\n ;;
  *) ;;
esac
}

# Check for command line options
WAITATEND="0"

while [ $# -gt 0 ]; do
  case $1 in
    --wait-at-end) #Started from menu system, keep terminal open so user can review output.
                   WAITATEND="1"
                   ;;

                *) #Unknown option - don't print any error message.
                   ;;
  esac
  shift
done

# Check that user is root.
[ $(id -u) -eq 0 ] || { echo -e $"\n\t You need to be root!\n" ; exit 1 ; }

# Check if we are running BASH for colourisation
if [ $BASH ]; then
  RED='\e[1;31m'
  BLUE='\e[1;34m'
  GREEN='\e[0;32m'
  END='\e[0m'
else
  RED=''
  BLUE=''
  GREEN=''
  END=''
fi

# The location of the Release and InRelease files.
APT_LISTS=/var/lib/apt/lists

# Get a list of repositories for which we have downloaded a Release file.
# Include Release and InRelease files from both /var/lib/apt/lists and /var/lib/apt/lists/partial.
REPOSITORIES="$(find $APT_LISTS -regex .*Release$ | cut -c20- | cut -f2- -d/)"

# There's no GPG signature for the mepis7cr|mepis8cr|mepis85cr|mepis11cr CR repos, so
# exclude them to prevent a "No GPG Release signature found." message from being shown.
REPOSITORIES="$(sed 's/ /\n/g' <<<$REPOSITORIES | grep -v -emepis{7,8,85,11}cr)"

# Look for a matching Release.gpg signature for each Repository.
# For Wheezy and earlier Debian releases it should be in a *.gpg or *.gpg.reverify file.
# For Jessie and newer Debian releases the gpg signature is included in the *_InRelease files.
# The gpg signature also seems to be in the *_Release files in Jessie, but not in the *_Release
# files of earlier Debian releases.
for repo in $REPOSITORIES
do
  echo -e \\nChecking $repo
  RELEASE=$(find $APT_LISTS -regex .*Release$ | grep $repo)
  GPG=$(grep -H -m1 'BEGIN PGP SIGNATURE' $(find $APT_LISTS -regex .*Release.* | grep $repo) | cut -f1 -d:)
  if [ "$GPG" != "" ]
    then
      # We have found a Release gpg signature
      if [ "$GPG" = "$RELEASE" ]; then RELEASE=""; fi
      ANSWER=$(gpgv --ignore-time-conflict $(find /etc/apt/trusted.gpg* -regex .*gpg$ | sed 's/^/ --keyring /') $GPG $RELEASE 2>&1)
      if [ $? -ne 0 ]
        then
          if [ "$APT_VERSION" \< "1.3" ]
            then
              GPGKEY=$(grep -Eo \ [0-9A-F]{8} <<<$ANSWER)
            else
              GPGKEY=$(grep -Eo \ [0-9A-F]{16} <<<$ANSWER)
          fi
          KEYSERVER_LIST="\
          keyserver.ubuntu.com
          hkp://pgp.mit.edu
          hkp://subkeys.pgp.net
          pool.sks-keyservers.net
          #eu.pool.sks-keyservers.net
          #hkp://keys.gnupg.net
          #hkp://keyservers.org
          #hkp://keyserver.linux.it"
          # try to download a key from keyserver(s) until it succeeds, or the end of the list has been reached
          if [ "$APT_VERSION" \< "1.3" ]
            then
              for KEYSERVER in $(sed 's/ /\n/g' <<<$KEYSERVER_LIST | grep -v ^#)
              do
                apt-key adv --keyserver $KEYSERVER --recv-key $GPGKEY 1>/dev/null
                if [ $? -eq 0 ]; then
                  break
                fi
                echo
              done
            else
              for KEYSERVER in $(sed 's/ /\n/g' <<<$KEYSERVER_LIST | grep -v ^#)
              do
                apt-key adv --keyserver $KEYSERVER --recv-key $GPGKEY
                if [ $? -eq 0 ]; then
                  break
                fi
                echo
              done
          fi
          if [ "$APT_VERSION" \< "1.3" ]
            then
              for i in $GPGKEY; do apt-key list \
              | grep -q $i 2>/dev/null || \
              { echo -e \\n$i" key not found on keyservers"\\n ;\
              check_exceptions $repo ; } ; done
            else
              for i in $GPGKEY; do apt-key list 2>/dev/null \
              | grep -q "$(echo $i | grep -Eo [0-9A-F]{4} | sed ':a;N;$!ba;s/\n/ /g')" 2>/dev/null || \
              { echo -e \\n$i" key not found on keyservers"\\n ;\
              check_exceptions $repo ; } ; done
          fi
        else
          printf "$GREEN%s$END" "    Good GPG signature found."
          echo
      fi
    else
      printf "$BLUE%s$END" "*** No GPG Release signature found."
      echo
      check_exceptions $repo
  fi
done

echo

if [ "$WAITATEND" = "1" ]; then
    echo
    HelpOrQuit=""
    read -sn 1 -t 999999999 -p "Press 'H' for online help, press any other key to close this window." HelpOrQuit
    sleep .1
    
    case $(cut -f1 -d_ <<<$LANG) in
      fr) HelpUrl="https://mxlinux.org/wiki/help-files/help-contr%C3%B4le-de-apt-gpg" ;;
       *) HelpUrl="https://mxlinux.org/wiki/help-files/help-mx-check-apt-gpg" ;;
    esac
    
    
    if [ "$HelpOrQuit" = "h" ] || [ "$HelpOrQuit" = "H" ]
      then
        echo
        echo
        echo "Please wait while the link '"$HelpUrl"' opens ..."
        echo
        if [ -e /usr/bin/mx-viewer ]; then helpViewer="mx-viewer"; else helpViewer="xdg-open"; fi
        User=$(who | grep '(:0)' -m1 | awk '{print $1}')
        1>&2 2>/dev/null su - $User -c 'env XAUTHORITY=/$HOME/.Xauthority DISPLAY=:0 1>&2 2>/dev/null '$helpViewer' '$HelpUrl'&'
        sleep 2
        read -sn 1 -p "Press any key to close this window." -t 999999999
        sleep .1
    fi
echo
fi

#!/usr/bin/env bash
basefile="install"
logfile="general.log"
timestamp=`date '+%Y-%m-%d %H:%M:%S'`

if [ "$#" -ne 1 ]; then
  msg="[ERROR]: $basefile failed to receive enough args"
  echo "$msg"
  echo "$msg" >> $logfile
  exit 1
fi

function setup-logging(){
  scope="setup-logging"
  info_base="[$timestamp INFO]: $basefile::$scope"

  echo "$info_base started" >> $logfile

  echo "$info_base removing old logs" >> $logfile

  rm -f $logfile

  echo "$info_base ended" >> $logfile

  echo "================" >> $logfile
}

function root-check(){
  scope="root-check"
  info_base="[$timestamp INFO]: $basefile::$scope"

  echo "$info_base started" >> $logfile

  #Make sure the script is running as root.
  if [ "$UID" -ne "0" ]; then
    echo "[$timestamp ERROR]: $basefile::$scope you must be root to run $0" >> $logfile
    echo "==================" >> $logfile
    echo "You must be root to run $0. Try the following"
    echo "sudo $0"
    exit 1
  fi

  echo "$info_base ended" >> $logfile
  echo "================" >> $logfile
}

function docker-check() {
  scope="docker-check"
  info_base="[$timestamp INFO]: $basefile::$scope"
  cmd=`docker -v`

  echo "$info_base started" >> $logfile

  if [ -z "$cmd" ]; then
    echo "$info_base docker not installed"
    echo "$info_base docker not installed" >> $logfile
  fi

  echo "$info_base ended" >> $logfile
  echo "================" >> $logfile

}

function docker-compose-check() {
  scope="docker-compose-check"
  info_base="[$timestamp INFO]: $basefile::$scope"
  cmd=`docker-compose -v`

  echo "$info_base started" >> $logfile

  if [ -z "$cmd" ]; then
    echo "$info_base docker-compose not installed"
    echo "$info_base docker-compose not installed" >> $logfile
  fi

  echo "$info_base ended" >> $logfile
  echo "================" >> $logfile

}
function usage() {
    echo ""
    echo "Usage: "
    echo ""
    echo "-u: start."
    echo "-d: tear down."
    echo "-h: Display this help and exit."
    echo ""
}
function create-certs() {
  local docker_img_tag=$1
  local docker_img_name=$2
  local services=$3
  local target_dir=$4

  if [[ -e "$(pwd)/$docker_img_tag/$target_dir" ]]; then
    echo "removing old keystore"

    rm -Rf "$(pwd)/$docker_img_tag/$target_dir"
  fi

  echo "build keystore image"

  sudo docker build -t $docker_img_tag $(pwd)/$docker_img_tag

  echo "run keystore image"

  sudo docker run -d --name $docker_img_name $docker_img_tag

  echo "copy from image"

  sudo docker cp $docker_img_name:/$target_dir $(pwd)/$docker_img_tag

  echo "remove image"

  sudo docker rm $docker_img_name

  echo "loop services"

  for d in `echo $services | awk '{print $0}'`; do
    #statements
    echo "$(pwd)/$d"

    echo "copy files from keystore to service"

    cp -R "$(pwd)/$docker_img_tag/$target_dir" "$(pwd)/$d"
  done

}
function remove-certs() {
  local docker_img_tag=$1
  local services=$2
  local target_dir=$3

  if [[ -e "$(pwd)/$docker_img_tag/$target_dir" ]]; then
    echo "removing old keystore"

    rm -Rf "$(pwd)/$docker_img_tag/$target_dir"
  fi

  for d in `echo $services | awk '{print $0}'`; do
    #statements
    rm -Rf "$(pwd)/$d/$target_dir"
  done

}
function keystore() {
  local flag=$1
  local dropwizard_path="bin/src/main/java/example"
  local spring_path="bin/src/main/resources"
  local docker_img_tag="keystore-srv"
  local docker_img_name="keystore-certs"
  local services="api/${dropwizard_path} java-srv/${spring_path}"
  local target_dir="keystore"

  if [[ $flag == 1 ]]; then
    #statements
    create-certs $docker_img_tag $docker_img_name "api/$dropwizard_path" $target_dir
    create-certs $docker_img_tag $docker_img_name "java-srv/$spring_path" $target_dir
    # create-certs $docker_img_tag $docker_img_name $services $target_dir
  else
    remove-certs $docker_img_tag "api/$dropwizard_path" $target_dir
    remove-certs $docker_img_tag "java-srv/$spring_path" $target_dir
    # remove-certs $docker_img_tag $services $target_dir
  fi

}
function start-up(){

    scope="start-up"
    docker_img_name=`head -n 1 README.md | sed 's/# //'`
    info_base="[$timestamp INFO]: $basefile::$scope"

    echo "$info_base started" >> $logfile

    echo "$info_base build image" >> $logfile

    keystore 1

    sudo docker-compose up --build

    echo "$info_base running image" >> $logfile

    echo "$info_base ended" >> $logfile

    echo "================" >> $logfile
}
function tear-down(){

    scope="tear-down"
    info_base="[$timestamp INFO]: $basefile::$scope"

    echo "$info_base started" >> $logfile

    echo "$info_base stoping services" >> $logfile

    keystore 2

    sudo docker-compose down

    echo "$info_base ended" >> $logfile

    echo "================" >> $logfile
}

root-check
docker-check
docker-compose-check

while getopts ":udh" opts; do
  case $opts in
    u)
      setup-logging
      start-up ;;
    d)
      tear-down ;;
    h)
      usage
      exit 0 ;;
    /?)
      usage
      exit 1 ;;
  esac
done
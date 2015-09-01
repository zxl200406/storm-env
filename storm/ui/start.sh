#!/usr/bin/env bash
export LC_ALL="en_US.UTF-8"
job_name="ui"
run_dir="/home/work/app/storm-env/storm/ui"

run_dir=`cd "$run_dir"; pwd`

start_time=`date +%Y%m%d-%H%M%S`

pid=`echo $$`

package_dir="$run_dir/package"
log_dir="$run_dir/log"
pid_file="$run_dir/${job_name}.pid"

if [[ ! -d $run_dir/stdout ]]; then 
   mkdir $run_dir/stdout
fi

output_file="$run_dir/stdout/${job_name}_${start_time}.out"

jar_dirs="$package_dir/:$package_dir/lib/*:$package_dir/*"
params="-Xloggc:$run_dir/stdout/ui_gc_${start_time}.log -Xmx1024m -Xms1024m -Xmn512m -XX:MaxDirectMemorySize=1024m -XX:MaxPermSize=256m -XX:+DisableExplicitGC -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$log_dir -XX:+PrintGCApplicationStoppedTime -XX:+PrintGCApplicationConcurrentTime -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=80 -XX:+UseMembar -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:ParallelGCThreads=16 -XX:ConcGCThreads=16 -Dlogfile.name=ui.log -Dstorm.home=$run_dir -Dstorm.log.dir=$run_dir/logs -Djava.library.path="/opt/soft/jdk/lib:/opt/soft/jre/lib:/usr/local/lib" -Dlogback.configurationFile=$run_dir/cluster.xml -Dstorm.log.level=info -Djava.security.krb5.conf=$run_dir/krb5.conf backtype.storm.ui.core "

security_jars=""
for jar in `find $package_dir/ -name hadoop-security-*.jar`; do
  if [ -n "$security_jars" ]; then
    security_jars=$security_jars";"$jar 
  else
    security_jars=$jar
  fi
done

if [ -n "$security_jars" ]; then
  params="-Xbootclasspath/p:$security_jars $params"
fi

java="/opt/soft/jdk/bin/java"
if ! [ -e $java ]; then
  java="/usr/bin/java"
fi

class_path="$run_dir/:$jar_dirs"

if [ -f $pid_file ]; then
  if kill -0 `cat $pid_file` > /dev/null 2>&1; then
    echo -e "\033[33mThe $job_name is running, skipped.\033[0m"
    exit 0
  else
    rm -f "$pid_file" || exit 1
  fi
fi

options=""
if [ -d "$package_dir/lib/native" ]; then
  JAVA_PLATFORM=""
  if [ -z $JAVA_PLATFORM ]; then
    JAVA_PLATFORM=`CLASSPATH=${class_path} ${java} org.apache.hadoop.util.PlatformName | sed -e "s/ /_/g"`
  fi

  JAVA_LIBRARY_PATH="$JAVA_LIBRARY_PATH:$package_dir/lib/native/:$package_dir/lib/native/${JAVA_PLATFORM}"

  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$JAVA_LIBRARY_PATH"
  options="$OPTS -Djava.library.path=$JAVA_LIBRARY_PATH"
fi

export SUPERVISOR_LOG_DIR=/home/work/storm/supervisor

export HADOOP_COMMON_HOME=$package_dir
export HADOOP_HDFS_HOME=$package_dir
export HADOOP_YARN_HOME=$package_dir
export HADOOP_MAPRED_HOME=$package_dir

# for compatibility
export YARN_HOME=$package_dir

if [ -f ./pre.sh ]; then
  source ./pre.sh $job_name $run_dir
fi
exec ${java} -cp $class_path $options $params $@ 1>$output_file 2>&1

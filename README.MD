# storm-env
storm的环境搭建，必须之前先搭建好zookeeper  
在zk上创建/storm/xltst-dev节点(如果需要修改xltst-dev,需要修改三个文件配置文件 分别在目录 nimbus,supervisor,ui修改storm.yaml里的)  

在每台机器的/home/work目录下创建app,data,packages目录

在storm.apache.org的官方下载storm客户端
apache-storm-0.9.1-incubating.tar.gz
copy在每一台机器的/home/work/packages目录,并解压



在每台机器上/home/work/app目录下git clone https://github.com/zxl200406/storm-env.git

> pc1 选取好一点的机器启动nimbus  
cd /home/work/app/storm-env/storm/nimbus/  
sh start.sh &  
cd /home/work/app/storm-env/storm/supervisor/  
sh start.sh &  
cd /home/work/app/storm-env/storm/ui/  
sh start.sh &  

> pc2 to pc N 只需要执行supervisor进程  
cd /home/work/app/storm-env/storm/supervisor/  
sh start.sh &  



ui可以启动在任何一台机器上，不需要和nimbus在同一台机器  




#jdk环境,必须是1.6的版本，storm官方要求


jdk1.6.0.37安装在/opt/soft目录
创建软链接jdk



export JAVA_HOME=/opt/soft/jdk  
export PATH=$JAVA_HOME/bin:$PATH  
export CLASSPATH=$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/rt.jar:$CLASSPATH  
export LD_LIBRARY_PATH=$JAVA_HOME/jre/lib/amd64/server:$LD_LIBRARY_PATH  



/usr/bin目录 创建软链  
ln -s /opt/soft/jdk/bin/java java  
ln -s /opt/soft/jdk/bin/javac javac  
ln -s /opt/soft/jdk/bin/javadoc javadoc  
ln -s /opt/soft/jdk/bin/javah javah  
ln -s /opt/soft/jdk/bin/javap javap  

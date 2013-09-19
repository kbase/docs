#!/bin/bash

# To compile and run the Example.java program, you must compile correcly against the existing classes.  You can do so
# by manually changing your java CLASSPATH variable in your environment to point to "lib/java_interface" or you can
# do so during the compilation and execution of your java file (see below).
#
# In addition, to run the file you must either copy the dynamic library to the current directory, or point to dynamic
# library locations using the -D flag to set the variable java.library.path to the correct location.  Again, see
# below in this script for example usage.
#
# For some reason on KBase v10, the javac and java on the path are incompatible!  Don't understand that, but to solve it, here
# is the path to a compatible JVM.

javac -classpath "../../lib/java_interface" Example.java
/usr/lib/jvm/java-7-openjdk-amd64/bin/java -classpath "../../lib/java_interface":"." -Djava.library.path="../../lib/java_interface" Example
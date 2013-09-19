#!/bin/bash

# To compile and run the Example.java program, you must compile correcly against the existing classes.  You can do so
# by manually changing your java CLASSPATH variable in your environment to point to "lib/java_interface" or you can
# do so during the compilation and execution of your java file (see below).
#
# In addition, to run the file you must either copy the dynamic library to the current directory, or point to dynamic
# library locations using the -D flag to set the variable java.library.path to the correct location.  Again, see
# below in this script for example usage.

javac -classpath "../../lib/java_interface" Example.java
java -classpath "../../lib/java_interface":"." -Djava.library.path="../../lib/java_interface" Example
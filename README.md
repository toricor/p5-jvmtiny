# p5-jvmtiny
[![](https://github.com/toricor/p5-jvmtiny/workflows/linux/badge.svg)](https://github.com/toricor/p5-jvmtiny/actions) 

p5-jvmtiny is an implementation of Java Virtual Machine in Perl5.
This is toy project.

### Run HelloWorld
- install modules `carton install`
- generate classfile (Java 8) `javac -encoding UTF-8 example/HelloWorld.java`  
- run the script `./dev_env.sh perl main.pl example/HelloWorld.class` or `carton exec -- perl main.pl example/HelloWorld.class`

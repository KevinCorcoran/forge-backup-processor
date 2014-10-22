Forge Backup Processor
======================

This silly little script operates on a backup of the forge
and finds all of the unique modules.  It knows how to do things like
account for multiple versions of a given module, ignore extraneous files, etc.

Usage
=====

First, download a backup of the forge.  Then, extract it: 
```
tar -xvf latest.tar
```

Now, go into the directory created by previous command 
and extract all of the module archives:
```
cd 2014-10-22_000008
find . -exec tar -zxvf '{}' \;
```

Then, pass that directory as the argument to this script:
```
./insanity.rb ~/tmp/forge/2014-10-22_000008
```

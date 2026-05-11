# Mini-Termux-2-adb
Some bootstrap script to work with Termux on ADB shell, from `/data/local/tmp` with `proot`, bypassing some SELinux restrictions with binary cloning and symbolic links to simulate a root file system with all resources in the same context, without needing to disable SELinux. Slow to initialize and large space usage for cloning, but functional.

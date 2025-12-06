# Zocker
Trying to implement some of dockers functionalities.

## Task 1
- Checkout to the task 1 tag (`git checkout t1`).
- Dissociate child process PID Namespace from the default.
- Modify the Makefile, so the `./zocker run` will not require `sudo` to function properly. 
- Include `exec` subcommand by adding required flags and `setns(2)` syscall. 
### Useful Links
- https://man7.org/linux/man-pages/man2/clone.2.html
- https://man7.org/linux/man-pages/man2/unshare.2.html
- https://man7.org/linux/man-pages/man2/fork.2.html
- https://man7.org/linux/man-pages/man7/namespaces.7.html
- https://man7.org/linux/man-pages/man8/setcap.8.html
- https://man7.org/linux/man-pages/man2/setns.2.html

## Task 2
- Check out to the task 2 tag (`git checkout t2`).
- Run a shell in a container using `./zocker run --name test-container 'sh'` and try executing `ps aux`. Although you have already placed the container's process in a separate PID namespace, you may observe that the command behaves the same as before. Try to understand the root cause and resolve it.
- After resolving the previous issue, running `./zocker run` may cause some functionalities of your system to break. Read about mount namespace hierarchy and propagation, and resolve this issue as well.
- Dissociate the container process's UTS namespace from the default. Also, set the hostname to the value of `--name` so that the `hostname` command prints the container name instead of the host machine name.
### Useful Links
- https://man7.org/linux/man-pages/man2/mount.2.html
- https://man7.org/linux/man-pages/man7/namespaces.7.html
- https://man7.org/linux/man-pages/man2/gethostname.2.html

# Task 3
- Check out to the task 3 tag (`git checkout t3`).
- The ultimate goal is to change the root of a container started by following command to `/tmp/zocker/test-container` using `chroot(2)`.
```
./zocker run --name test-container 'sh'
```
- You may need to modify `setup_bin_dir` and `setup_lib_dir` in `src/setup.c`.
- Verify your code using `pwd`, `cd`, and `ls`.
### Useful Links
- https://man7.org/linux/man-pages/man2/chroot.2.html
- https://man7.org/linux/man-pages/man2/chdir.2.html
- https://man7.org/linux/man-pages/man1/ldd.1.html

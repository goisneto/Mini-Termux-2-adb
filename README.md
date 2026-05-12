# Mini-Termux-2-adb

A bootstrap script to run Termux inside an ADB shell from `/data/local/tmp` using `proot`, bypassing some **SELinux** restrictions through `binary cloning` and `symbolic links` to *simulate* a *root filesystem* with **all resources** under the same SELinux `context`, without needing to **disable SELinux**.

Initialization is **slow** and requires a **large amount of storage space** due to the binary cloning process, but it is fully functional.

---

# Installation: How do I make this work on my phone?

## 1. Download and extract Mini-Termux

Download `mini-termux.tar.gz` to the `/sdcard` directory of your device, or clone the repository and move `mini-termux.tar.gz` to `/sdcard`, or directly move the `mini-termux` directory to `/data/local/tmp`.

### 1.1 Direct download from the terminal

Before starting, open an `ADB` shell:

```shell
# First enter the ADB shell
adb shell
```

Or use the `rish` shell from **Shizuku**:

```shell
# Alternatively, use the Shizuku rish shell
rish
```

Then run:

```shell
curl -sL -o /sdcard/mini-termux.tar.gz \
https://github.com/goisneto/Mini-Termux-2-adb/raw/refs/heads/main/mini-termux.tar.gz

curl -sL -o /data/local/tmp/unpack_mini-termux.sh \
https://github.com/goisneto/Mini-Termux-2-adb/raw/refs/heads/main/unpack_mini-termux.sh

chmod +x /data/local/tmp/unpack_mini-termux.sh

/data/local/tmp/unpack_mini-termux.sh

chmod +x /data/local/tmp/mini-termux/{backup_mini-termux.sh,tar_root_system_bins.sh,proot-mini-termux}

exec /data/local/tmp/mini-termux/proot-mini-termux
```

---

### 1.2 Clone the repository and transfer via ADB

```shell
git clone https://github.com/goisneto/Mini-Termux-2-adb.git Mini-Termux-2-adb

adb push -z any Mini-Termux-2-adb/mini-termux /data/local/tmp/

adb push -z any Mini-Termux-2-adb/unpack_mini-termux.sh /data/local/tmp/

adb shell 'chmod +x /data/local/tmp/unpack_mini-termux.sh /data/local/tmp/mini-termux/{backup_mini-termux.sh,tar_root_system_bins.sh,proot-mini-termux}'

adb shell -tt /data/local/tmp/mini-termux/proot-mini-termux
```

---

### 1.3 Clone the repository and transfer via `rish` (Shizuku)

Using [Shizuku](https://github.com/rikkaapps/shizuku):

```shell
git clone https://github.com/goisneto/Mini-Termux-2-adb.git Mini-Termux-2-adb

tar -C Mini-Termux-2-adb -cf - mini-termux unpack_mini-termux.sh \
| rish -c 'tar -C /tmp -xf -; mv /tmp/unpack_mini-termux.sh /tmp/mini-termux /data/local/tmp/'

rish -c 'chmod +x /data/local/tmp/unpack_mini-termux.sh /data/local/tmp/mini-termux/{backup_mini-termux.sh,tar_root_system_bins.sh,proot-mini-termux}'

rish /data/local/tmp/mini-termux/proot-mini-termux
```

---

## 2. Re-entering Mini-Termux after the first initialization

After the first initialization process finishes, everything becomes much faster and easier, assuming the first setup completed successfully.

To launch Mini-Termux again from either the `ADB` shell or `rish`, you can run the same final command from step `1`.

### 2.1 ADB

```shell
adb shell -tt /data/local/tmp/mini-termux/proot-mini-termux
```

### 2.2 Rish

```shell
rish /data/local/tmp/mini-termux/proot-mini-termux
```

During the first execution, the script generates:

```text
/data/local/tmp/mini-termux/.entry
```

Subsequent launches detect this file and jump directly into it.

You can also execute `.entry` directly.

### 2.3 Direct `.entry` execution via ADB

```shell
adb shell -tt /data/local/tmp/mini-termux/.entry
```

### 2.4 Direct `.entry` execution via Rish

```shell
rish /data/local/tmp/mini-termux/.entry
```

---

# Why not just use `proot` directly with a copy of the Termux bootstrap?

The Android shell user has many additional permissions that regular **Termux** does not have, or would otherwise need to acquire through commands executed from the shell user via either `ADB` or `rish`.

If you simply copy the **Termux** bootstrap and try to execute it, many binaries will repeatedly attempt to access:

```text
/data/data/com.termux
```

In many cases this path is not configurable and is hardcoded directly into the binaries themselves.

The only ways to change this are:

- recompiling all **Termux** binaries, or
- using `proot` to simulate a `chroot`-like subsystem where the extracted bootstrap is mounted onto `/data/data/com.termux`.

However, this introduces another issue.

`proot` relies on `PTRACE` to intercept filesystem-related syscalls and redirect them into the virtualized paths. SELinux blocks certain system binaries from being intercepted through `PTRACE`, and simply denies execution when interception is detected.

The solution implemented here was to clone all required system binaries into the `proot` subsystem itself, making them behave like ordinary shell binaries sharing the same SELinux `context` as the `ADB` or `rish` shell user.

This allows the environment to retain:

- the full privileges of the Android shell user,
- access to all required binaries,
- and compatibility with `proot` + the **Termux** bootstrap,

even while syscalls are being intercepted through `PTRACE`.
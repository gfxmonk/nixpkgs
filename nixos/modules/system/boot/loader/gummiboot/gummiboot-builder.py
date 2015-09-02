#! @python@/bin/python
import argparse
import shutil
import os
import errno
import subprocess
import glob
import tempfile
import errno

def copy_if_not_exists(source, dest):
    if not os.path.exists(dest):
        shutil.copyfile(source, dest)

system_dir = lambda generation: "/nix/var/nix/profiles/system-%d-link" % (generation)

def write_entry(generation, kernel, initrd, xen_efi, xen_params):
    entry_file = "@efiSysMountPoint@/loader/entries/nixos-generation-%d.conf" % (generation)
    generation_dir = os.readlink(system_dir(generation))
    tmp_path = "%s.tmp" % (entry_file)
    kernel_params = "systemConfig=%s init=%s/init " % (generation_dir, generation_dir)
    with open("%s/kernel-params" % (generation_dir)) as params_file:
        kernel_params = kernel_params + params_file.read()
    with open(tmp_path, 'w') as f:
        print >> f, "title NixOS"
        print >> f, "version Generation %d" % (generation)
        if machine_id is not None: print >> f, "machine-id %s" % (machine_id)
        if xen_efi is not None:
            print >> f, "efi %s" % (xen_efi)
            cfg_path = xen_efi[:-3] + 'cfg'
            with open("@efiSysMountPoint@" + cfg_path, 'w') as cfg:
                print >> cfg, "[global]"
                print >> cfg, "[xen]"
                print >> cfg, "kernel=%s boot.shell_on_fail %s" % (os.path.basename(kernel), kernel_params)
                print >> cfg, "ramdisk=%s" % (os.path.basename(initrd))
                print >> cfg, "options=log_lvl=all guest_loglvl=all %s" % (xen_params)
        else:
            print >> f, "linux %s" % (kernel)
            print >> f, "initrd %s" % (initrd)
            print >> f, "options %s" % (kernel_params)
    os.rename(tmp_path, entry_file)

def write_loader_conf(generation):
    with open("@efiSysMountPoint@/loader/loader.conf.tmp", 'w') as f:
        if "@timeout@" != "":
            print >> f, "timeout @timeout@"
        print >> f, "default nixos-generation-%d" % (generation)
    os.rename("@efiSysMountPoint@/loader/loader.conf.tmp", "@efiSysMountPoint@/loader/loader.conf")

def copy_from_profile(generation, name, dry_run=False):
    store_file_path = os.readlink("%s/%s" % (system_dir(generation), name))
    suffix = os.path.basename(store_file_path)
    store_dir = os.path.basename(os.path.dirname(store_file_path))
    efi_file_path = "/efi/nixos/%s-%s.efi" % (store_dir, suffix)
    if not dry_run:
        copy_if_not_exists(store_file_path, "@efiSysMountPoint@%s" % (efi_file_path))
    return efi_file_path

def copy_efi_from_profile(generation, name, dry_run=False):
    try:
        store_file_path = os.readlink("%s/%s" % (system_dir(generation), name))
        # store_cfg_path = os.readlink("%s/%s" % (system_dir(generation), name))
    except OSError as e:
        import errno
        if e.errno == errno.ENOENT:
            return None
        raise
    suffix = os.path.basename(store_file_path)
    store_dir = store_file_path.replace('/','-')
    efi_file_path = "/efi/nixos/%s-%s" % (store_dir, suffix)
    # store_cfg_path = store_file_path[:-3] + 'cfg'
    # cfg_file_path = efi_file_path[:-3] + 'cfg'
    if not dry_run:
        copy_if_not_exists(store_file_path, "@efiSysMountPoint@%s" % (efi_file_path))
        # copy_if_not_exists(store_cfg_path, "@efiSysMountPoint@%s" % (cfg_file_path))
    return efi_file_path

def add_entry(generation):
    efi_kernel_path = copy_from_profile(generation, "kernel")
    efi_initrd_path = copy_from_profile(generation, "initrd")
    efi_xen_path = copy_efi_from_profile(generation, "xen.efi")
    xen_params = None
    if efi_xen_path is not None:
        with open("%s/%s" % (system_dir(generation), "xen-params")) as f:
            xen_params = f.read().strip()
    write_entry(generation, efi_kernel_path, efi_initrd_path, efi_xen_path, xen_params)

def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as e:
        if e.errno != errno.EEXIST or not os.path.isdir(path):
            raise

def get_generations(profile):
    gen_list = subprocess.check_output([
        "@nix@/bin/nix-env",
        "--list-generations",
        "-p",
        "/nix/var/nix/profiles/%s" % (profile),
        "--option", "build-users-group", ""
        ])
    gen_lines = gen_list.split('\n')
    gen_lines.pop()
    return [ int(line.split()[0]) for line in gen_lines ]

def remove_old_entries(gens):
    slice_start = len("@efiSysMountPoint@/loader/entries/nixos-generation-")
    slice_end = -1 * len(".conf")
    known_paths = []
    for gen in gens:
        known_paths.append(copy_from_profile(gen, "kernel", True))
        known_paths.append(copy_from_profile(gen, "initrd", True))
    for path in glob.iglob("@efiSysMountPoint@/loader/entries/nixos-generation-[1-9]*.conf"):
        try:
            gen = int(path[slice_start:slice_end])
            if not gen in gens:
                os.unlink(path)
        except ValueError:
            pass
    for path in glob.iglob("@efiSysMountPoint@/efi/nixos/*"):
        if not path in known_paths:
            os.unlink(path)

parser = argparse.ArgumentParser(description='Update NixOS-related gummiboot files')
parser.add_argument('default_config', metavar='DEFAULT-CONFIG', help='The default NixOS config to boot')
args = parser.parse_args()

# We deserve our own env var!
if os.getenv("NIXOS_INSTALL_GRUB") == "1":
    if "@canTouchEfiVariables@" == "1":
        subprocess.check_call(["@gummiboot@/bin/gummiboot", "--path=@efiSysMountPoint@", "install"])
    else:
        subprocess.check_call(["@gummiboot@/bin/gummiboot", "--path=@efiSysMountPoint@", "--no-variables", "install"])

mkdir_p("@efiSysMountPoint@/efi/nixos")
mkdir_p("@efiSysMountPoint@/loader/entries")
try:
    with open("/etc/machine-id") as machine_file:
        machine_id = machine_file.readlines()[0]
except IOError as e:
    if e.errno != errno.ENOENT:
        raise
    machine_id = None

gens = get_generations("system")
remove_old_entries(gens)
for gen in gens:
    add_entry(gen)
    if os.readlink(system_dir(gen)) == args.default_config:
        write_loader_conf(gen)

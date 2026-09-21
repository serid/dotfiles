For directories Impermanence creates units of type `mount`.
For files Impermanence creates a service that invokes `/nix/store/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-persistence-mount-file` with file path. At "auto" setting it either:
* Bind-mounts the file at tree from persistence if file exists in persistence.
* Creates a symlink from tree to its expected place in persistence. This way file does not exist, but if some program creates it, it will be written to persistence.

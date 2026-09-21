# Fish variables are always arrays, possibly singletons.

# Variable uses splat all elements as separate arguments.
# $ set foo a b
# $ printf '[%s]' $foo
# [a][b]⏎

# A singleton with space is not word-split on space, unlike Bash. So no need to quote every variable use.
# $ set foo "a b"
# $ printf '[%s]' $foo
# [a b]⏎

# Fish does not expand globs in variable uses
# $ set foo "*"
# $ echo $foo
# *

# Or in literal variable assignments
# $ set foo (echo '*')
# $ echo $foo
# *

# This one is different though
# $ set foo *
# $ echo $foo # Quoting not necessary, as established earlier
# Desktop Documents Downloads

# Move a file or directory tree to /persist.
# After invoking this you can add the path to NixOS Impermanence and do `nixos-rebuild switch` so Impermanence creates a bind mount to the new persistent data.
# Does not follow symlinks.
# Assumes no newlines in filenames.
function persist
	if test (count $argv) -ne 1
		echo "persist: error: expected exactly one path" >&2
		return 1
	end

	set -l src $argv[1]

	if not string match -q '/*' $src
		echo "persist: error: '$src' is not an absolute path" >&2
		return 1
	end
	
	# path normalize is perfect since it operates on pure string basis and we already have an absolute path and don't want symlink resolution
	set -l src (path normalize -- $src)

	if test $src = "/"
    echo "persist: error: refusing to move /" >&2
    return 1
  end
	if string match -q '/persist/*' $src/
		echo "persist: error: '$src' shall not be in '/persist'" >&2
		return 1
	end
	if test -L $src
		echo "persist: refusing to move symbolic link '$src'" >&2
		return 1
	end
	# Reject special files (block devices, char devices, FIFOs, sockets) anywhere in the input tree.
	# cp -r follows symlink in argument, but copies symlinks in subdirectories. find -H matches this behavior.
	# but since we move, do -P, so "never follow symlinks"
	set -l specials (find -P $src \( -type b -o -type c -o -type p -o -type s \))
	set -l find_status $status
	if test $find_status -ne 0
		echo "persist: error: could not scan '$src'" >&2
		return 1
	end
	if test (count $specials) -gt 0
		for f in $specials
			echo "persist: error: special file: $f" >&2
		end
		return 1
	end

	set -l dest /persist$src
	# Error if destination exists or is a symlink (valid or broken)
	if test -e $dest; or test -L $dest
		echo "persist: error: '$dest' already exists" >&2
		return 1
	end

	set -l prefix (dirname -- $dest)
	# mkdir will give a diagnostic if prefix already exists and is not a file
	mkdir -p $prefix
	if test $status -ne 0
    echo "persist: error: could not create parent directory '$prefix'" >&2
    return 1
  end

	# Accept both files and directories in input
	mv -v --no-clobber -- $src $dest
	return $status
end

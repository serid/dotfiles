import { execSync } from 'child_process'
import { opendir, unlink, rmdir } from 'fs/promises'
import { isAbsolute, normalize, join, resolve } from 'path'

function parse() {
  if (process.argv.length < 3) {
    process.stderr.write("purge-persistence-volume: Delete all files and directories from volume specified in first argument (e. g. `/persist`)\n
while keeping files and directories listed in\n
/workshop/dotfiles/home-linker/persisted-files.toml\n
/workshop/dotfiles/home-linker/persisted-directories.toml\n

Pass `--dry-run` to print changes without modifying the filesystem.\n")
    process.exit(1)
  }
  let args = process.argv.slice(2)

  let dryRunIx = args.indexOf("--dry-run")
  let dryRun = dryRunIx != -1
  if (dryRun) {
    args.splice(dryRunIx, 1)
    process.stderr.write("Running dry.\n")
  }

  if (args.length > 1) {
    process.stderr.write("Too many arguments.")
    process.exit(1)
  }
  let root = args[0]

  let excludeFiles = JSON.parse(execSync(`${process.env.TOMLQ} -e ".paths" /workshop/dotfiles/home-linker/persisted-files.toml`))
  let excludeDirs = JSON.parse(execSync(`${process.env.TOMLQ} -e ".paths" /workshop/dotfiles/home-linker/persisted-directories.toml`))

  let exit = false
  for (let list of [excludeDirs, excludeFiles])
    for (let i = 0; i < list.length; i++) {
      if (!isAbsolute(list[i])) {
        process.stderr.write("expected an absolute path in a persistence list: " + x)
        exit = true
      }

      // Augment paths to start from given root
      list[i] = join(root, list[i])
    }
  // Augment dir paths to end with /
  excludeDirs = excludeDirs.map(x => join(x, '/'))

  if (exit) process.exit(1)

  return { dryRun, root, excludeFiles, excludeDirs }
}

let { dryRun, root, excludeFiles, excludeDirs } = parse()

console.log(excludeFiles)
console.log(excludeDirs)

// Assumes `dir` to be path to a directory
// Returns false if the directory was kept around
// Returns true if the directory was emptied and removed
async function walk(dir) {
  dir = resolve(dir) // convert to absolute path
  if (excludeDirs.some(x => normalize(dir + '/') === x)) { // handle paths with terminal slash
    process.stderr.write(`keeping dir: ${dir}\n`)
    return false
  }

  let anyKept = false
  for await (let entry of await opendir(dir)) {
    let path = join(dir, entry.name)
    if (entry.isDirectory()) {
      if ((await walk(path)) === false)
        anyKept = true
    }
    else if (entry.isFile() || entry.isSymbolicLink()) {
      if (excludeFiles.includes(path)) {
        process.stderr.write(`keeping file: ${path}\n`)
        anyKept = true
        continue
      }
      // process.stderr.write(`removing file: ${path}\n`)

      if (!dryRun)
       await unlink(path)
    }
    else throw new Error("unexpected type: " + path)
  }

  if (anyKept) {
    process.stderr.write(`keeping non-empty dir: ${dir}\n`)
    return false
  }

  process.stderr.write(`removing dir: ${dir}\n`)
  if (!dryRun)
    await rmdir(dir)

  return true
}

await walk(root)

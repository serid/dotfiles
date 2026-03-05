// Prints what files in home directory have recorded mtime after $1
// Subtracts ./home-linker/persisted-files.toml

// TODO: invent some way to concisely extend the salvation list and
// of writing the newly persistent file to disk
// jq '. + ["new_item"]' data.json > new-data.json && mv new-data.json data.json
// but for toml while preserving comments

import { execSync } from 'child_process'

if (process.argv.length != 3) {
  // process.stderr.write('One argument required: period within which modification occured, e. g. "30 seconds ago"')
  process.stderr.write('One argument required: period within which modification occured, e. g. "30 seconds ago"')
  process.exit(1)
}
const period = process.argv[2]

const paths = execSync(`${process.env.FIND} ~ -xdev -type f -newermt "${period}"`, { encoding: 'utf-8' }).trim().split('\n')
const excludePaths = JSON.parse(execSync(`${process.env.TOMLQ} -e ".paths" ${process.env.PERSISTED_FILES}`))

// can reduce time complexety to O(N+M) here if you feel like it
const result = paths.filter(path => !excludePaths.includes(path))

console.log(result.join('\n'))
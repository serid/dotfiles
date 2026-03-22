import { createInterface } from "node:readline/promises"

let i = createInterface({ input: process.stdin, output: process.stdout })
let url = await i.question("champagne?")
i.close()

let matches = url.match(/ss:\/\/(.+)@(.+):(\d+)/);
if (!matches) {
    console.error("Invalid ss:// URL format");
    process.exit(1);
}

let user = matches[1]
let [method, password] = Buffer.from(user, 'base64').toString('utf-8').split(':')

console.log("Method:", method)
console.log("Password:", password)
console.log("IP:", matches[2])
console.log("Port:", matches[3])

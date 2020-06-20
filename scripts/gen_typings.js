#!/usr/bin/env node

const fs = require('fs');

// mmm tasty regex
const definRegex = /export\s+fn\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(((\s*([A-Za-z_][A-Za-z0-9_]*)\s*:\s*(.+?),?)*)\)\s*(.+?)[ \n\r{]+?/g;
const paramRegex = /\s*([A-Za-z_][A-Za-z0-9_]*)\s*:\s*([^,]+),?/g;

run(process.argv);

function usage(err) {
    if (err !== undefined && err !== "")
        console.log("Error: " + err + "\n");

    console.log("Usage: ./gen_typings.js [file.zig]\n\n\t-o, --output [file.d.ts]\n\t-m, --module [name]\n\t-h, --help\n\t")
}

function run(args) {
    if (args.length < 3) return usage("Not enough arguments.");

    let output = "";
    let mod = "typings";
    let input = "";

    let i = 2;
    while (i < args.length) {
        if (args[i] === "-o" || args[i] === "--output") {
            if (++i >= args.length)
                return usage("Expected output file.");
            output = args[i];
        } else if (args[i] === "-m" || args[i] === "--module") {
            if (++i >= args.length)
                return usage("Expected module name.");
            mod = args[i];
        } else if (args[i] === "-h" || args[i] === "--help") {
            return usage();
        } else {
            if (input === "")
                input = args[i];
            else
                return usage("Expected one input file.")
        }
        i++;
    }

    if (input === "")
        return usage("Expected an input file.");

    const dtsFile = parse(input, mod, output);

    if (output === "")
        console.log(dtsFile);
    else
        fs.writeFileSync(output, dtsFile);
}

function parse(inputFile, mod) {
    const contents = fs.readFileSync(inputFile).toString();
    const res = [...contents.matchAll(definRegex)];

    let o = `declare module '${mod}' {\n`;

    for (let i = 0; i < res.length; i++) {
        const funcName = res[i][1];
        const params = res[i][2];
        const retType = res[i][6];

        o += `  export function ${funcName}(`;

        const parRes = [...params.matchAll(paramRegex)];
        for (let j = 0; j < parRes.length; j++) {
            o += `${parRes[j][1]}: number`;
            if (j < parRes.length - 1)
                o += ', ';
        }

        o += `): ${retType === "void" ? "void" : "number"};\n`;
    }

    o += `}`;

    return o;
}
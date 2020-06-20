const { readFileSync } = require("fs");
const wasmBytes = readFileSync("./bin/main.wasm");

/** @returns {Promise<import("main")>} */
async function instWasm(buf) {
    const lib = (await WebAssembly.instantiate(buf, {env: {
        inv(a) { return a + 1; },
        stdoutWrite(ptr, len) {
            const view = new Uint8Array(lib.memory.buffer, ptr, len);
            process.stdout.write(view);
        }
    }})).instance.exports;

    return lib;
}

(async function() {
    const lib = await instWasm(wasmBytes);

    lib.hello();
})();
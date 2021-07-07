#!/usr/bin/node

let fs = require('fs');
let process = require('process');

function readNpmPackageJsonPathsFromStdinAsPromise()
{
    return new Promise((accepted, rejected) => {
        let data = '';

        process.stdin.on('data', (new_data) => {
            data += new_data;
        });
        process.stdin.on('end', () => {
            let files = data.split('\n');
            files = files.filter((file) => file.length > 1);
            accepted(files);
        });
    });
}

function readAllNpmJsons(paths)
{
    let promises = paths.map(path => loadNpmPackageJsonAsPromise(path));
    return Promise.all(promises);
}

function loadNpmPackageJsonAsPromise(path)
{
    return new Promise((accepted, rejected) => {
        fs.readFile(path, 'utf8', (err, json_string) => {
            if (err) {
                rejected(err);
                return;
            }

            let json = JSON.parse(json_string);
            if (json.name === undefined || json.name.length <= 0 || json.version.length <= 0) {
                rejected("Error processing " + path);
            }
            accepted(json);
        });
    });
}

function getSortedUniqueNpmJsons(npm_jsons)
{
    npm_jsons.sort((a, b) => {
        let ret = a.name.localeCompare(b.name);
        if (ret == 0)
            ret = a.version.localeCompare(b.version);
        return ret;
    });

    return npm_jsons.filter((json, idx, array) => {
        if (idx == 0)
            return true;

        return array[idx - 1].name !== json.name || array[idx - 1].version !== json.version;
    });
}

function npmJsonsToRpmProvidesStrings(npm_jsons)
{
    return npm_jsons.map(json => {
        let s = 'Provides:       bundled(node-' + json.name + ') = ' + json.version;
        return s;
    });
}

function printToStdoutWithNewlines(provides)
{
    process.stdout.write(provides.join('\\n'));
}

// -- MAIN --
readNpmPackageJsonPathsFromStdinAsPromise()
.then(paths => readAllNpmJsons(paths))
.then(npm_jsons => getSortedUniqueNpmJsons(npm_jsons))
.then(npm_jsons => npmJsonsToRpmProvidesStrings(npm_jsons))
.then(provides => printToStdoutWithNewlines(provides));


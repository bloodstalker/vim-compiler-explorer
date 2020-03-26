#!/usr/bin/node
"use strict"
//npm install node-fetch
//npm install argparse
//npm install zlib

const fetch = require('node-fetch')
const fs = require("fs")
const util = require("util")
const zlib = require("zlib")
const readFile = util.promisify(fs.readFile)
const path = require("path")
const REST_URL = "https://godbolt.org/api/"
const defaultOpts = {
"userArguments":"-O3", "filters":
  {"binary":false,
    "commentOnly":true,
    "demangle":true,
    "directives":true,
    "execute":false,
    "intel":true,
    "labels":true,
    "lables":true,
    "libraryCode":false,
    "trim":false
  }
}

const ArgumentParser = require("argparse").ArgumentParser
var parser = new ArgumentParser({})
parser.addArgument(["-d", "--compdb"], {
  help: "path to compilation database.",
  required: true,
  dest: "compdb"
})
parser.addArgument(["-s", "--src"], {
  help: "path to source file to send.",
  require: true,
  dest: "source"
})
parser.addArgument(["-c", "--config"], {
  help: "path to config.",
  require: true,
  dest: "config"
})
parser.addArgument(["-u", "--url"], {
  help: "the url for the API",
  dest: "url"
})

function get_compiler_list() {return fetch(REST_URL + "compilers", {headers:{"Accept": "application/json"}})}
function get_language_list() {return fetch(REST_URL + "languages", {headers:{"Accept": "application/json"}})}
function get_libraries_list() {return fetch(REST_URL + "libraries", {headers:{"Accept": "application/json"}})}
async function read_C_source(path) {return await readFile(path, "utf-8")}
async function get_config_for_file(path_to_config) {return await JSON.parse(fs.readFileSync(path_to_config))}

function get_comp_options_for_file(database, filename) {
  const comp_db = JSON.parse(fs.readFileSync(database))
  for (var i in comp_db) {
    if (comp_db[i].file == filename) {
      console.log(comp_db[i].command)
      console.log(comp_db[i].directory)
      console.log(comp_db[i].file)
      return comp_db[i]
    }
  }
}

function JSON_POST_req(data, options) {
  const config = fs.readFileSync(options, "utf-8")
  const dummy = {"source": data, "options": JSON.parse(config)}
  return {method:"POST", body:JSON.stringify(dummy), headers:{"Content-Type":"application/json"}}
}

function JSON_POST_req_v2(data, options) {
  const config = fs.readFileSync(options, "utf-8")
  const dummy = {"source": data, "options": JSON.parse(config)}
  return {method:"POST", body:JSON.stringify(dummy), headers:{"Content-Type":"application/json"}}
}

function compiler_explorer(path, options) {
  read_C_source(path).then(data=>
    JSON_POST_req(data, options)).then(post_arg=>
    fetch(REST_URL + "compiler/g92/compile", post_arg)).then(res=>
    res.text()).then(body=>
      console.log(body.split("\n").slice(1,body.split("\n").length).join("\n"))).catch(error=>
        console.log(error))
}

const args = parser.parseArgs()
console.log(args)
console.log(args.compdb)
console.log(args.config)
get_compiler_list().then(data=>data.json().then(data=>console.log(data)))
get_language_list().then(data=>data.json().then(data=>console.log(data)))
get_libraries_list().then(data=>data.json().then(data=>console.log(data)))
get_comp_options_for_file(args.compdb, args.source)
compiler_explorer(args.source, args.config)


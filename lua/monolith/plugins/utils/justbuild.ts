// TypeScript source for justbuild.lua
// to compile this file into lua source
// use 'tstl -p ~/.config/nvim/tsconfig.json'
// or '~/.config/nvim/tstl.sh'
// This part is written in TypeScript because of complexity
// and me not wanting to struggle with this in lua

// TODO: add job quit func

//------------------------------------------------------------------//
//                            INTERFACES                            //
//------------------------------------------------------------------//

declare function require(modname: string): any;
declare function print(val: any): void;
declare function tostring(val: number): string;
declare function tonumber(val: string): number;

declare namespace string {
    function format(this: void, fmt: string, val: any): string;
}

declare namespace vim {
    namespace fn {
        function system(this: void, com: string): string;
        function input(this: void, prompt: string, val: string): string;
        function getcwd(this: void): string;
        function filereadable(this: void, file: string): number;
        function expand(this: void, str: string): string;
        function fnamemodify(this: void, str: string, flags: string): string;
        function setqflist(this: void, val: any, mode: string): any;
        function confirm(this: void, prompt: string, choice: string, cdefault: number): any;
    }
    function inspect(this: void, val: any): any;
    namespace bo {
        var filetype: string;
    }
    function cmd(this: void, expr: string): any;
    namespace diagnostic {
        function setqflist(this: void, opts: any): any;
    }
    function schedule(this: void, callback: Function): any;
}

/** @noSelf */
declare namespace telescope {
    let pickers: {
        new: (this: void, opts: any, obj: any) => any
    }
    namespace finders {
        function new_table(this: void, obj: any): any;
    }
    namespace config {
        namespace values {
            function generic_sorter(this: void, opts: any): any;
        }
    }
    namespace actions {
        namespace select_default {
            function replace(this: any, callback: Function): any;
        }
        namespace state {
            function get_selected_entry(this: void): any;
        }
        function close(this: void, buf: any): any;
    }
    namespace themes {
        function get_dropdown(this: void, opts: any): any;
    }
}

interface PlenaryJob {
    new(job: any): PlenaryJob;
    sync(this: void): any;
    start(this: void): any;
}

declare namespace io {
    function open(this: void, name: string, mode: string): any;
    function close(this: void, file: any): any;
    function write(this: void, content: string): any;
}

declare namespace os {
    function date(format: string): string;
    function getenv(varname: string): string;
    function execute(command: string): string;
    function clock(): number;
}

declare namespace table {
    function insert(tbl: any, val: any): any;
}

//------------------------------------------------------------------//
//                             IMPORTS                              //
//------------------------------------------------------------------//

let pickers = require("telescope.pickers") as typeof telescope.pickers;
let finders = require("telescope.finders") as typeof telescope.finders;
let conf = require("telescope.config").values as typeof telescope.config.values;
let actions = require("telescope.actions") as typeof telescope.actions;
let action_state = require("telescope.actions.state") as typeof telescope.actions.state;
let themes = require("telescope.themes") as typeof telescope.themes;
let async = require("plenary.job") as PlenaryJob

let notify = require("notify");

//------------------------------------------------------------------//
//                            FUNCTIONS                             //
//------------------------------------------------------------------//

function popup(message: string, errlvl: string = "info", title: string = "Info"): void {
    notify(message, errlvl, { title: title });
}

function getConfigDir(): string {
    return vim.fn.fnamemodify(vim.fn.expand("$MYVIMRC"), ":p:h");
}

function get_build_names(lang: string = ""): string[][] {
    let arr: string[] = [];
    // table.remove(tbl, 1);

    let pjustfile: string = `${vim.fn.getcwd()}/justfile`;
    if (vim.fn.filereadable(pjustfile) == 1) {
        let overrideList: string = vim.fn.system(`just -f ${pjustfile} --list`);
        let oarr: string[] = overrideList.split("\n");
        if (oarr[0].startsWith("error")) {
            popup(overrideList, "error", "Build");
            return [];
        }
        oarr.shift();
        oarr.pop();
        let rem: boolean = false;
        for (let i = 0; i < arr.length; ++i) {
            for (let j = 0; j < oarr.length; ++j) {
                let fnor: string =  arr[i].split(" ").filter(e => e !== '')[0];
                let fnov: string = oarr[j].split(" ").filter(e => e !== '')[0];
                // popup(`${fnor} : ${fnov}`);
                if (fnor == fnov) {
                    rem = true;
                }
            }
            if (rem) arr.splice(i, 1);
            rem = false;
        }
        arr = arr.concat(oarr);
    } else {
        popup("Justfile not found in project directory", "error", "Build");
        return [];
    }
    //////////////////// add vim.fn.cwd()
    // table.remove(tbl, #tbl);
    let tbl: string[][] = [];
    for (let i = 0; i < arr.length; ++i) {
        // popup(tbl[i]);
        let comment: string = arr[i].split("#")[1];
        let options: string[] = arr[i].split("#")[0].split(" ");
        options = options.filter(e => e !== '');
        // print(vim.inspect(options));
        let name = options[0];
        let langname = (name.split("_")[0]).toLowerCase();
        // popup(langname);
        if (langname == lang.toLowerCase() || lang == "" || langname == "any") {
            // tbl.push(name);
            let parts: string[] = name.split("_");
            let out: string;
            if (parts.length == 1) {
                out = parts[0];
            } else {
                out = `${parts[0]}: `;
                parts.shift();
                out += parts.join(" ");
            }
            let wd = 34;
            let rn = Math.max(0, wd - out.length);
            out += `${" ".repeat(rn)} ${comment == null ? "" : comment}`;
            tbl.push([out, name]);
        }
        // popup(`${name}: ${options.length}`, "info", "Info");
    }
    return tbl;
}

/**
@summary Checks if argument is defined as keyword (i.e "FILEPATH", "FILEEXT") and
returns corresponding string. If argument is not keyword function returns single space
@param arg Argument to check
*/
function check_keyword_arg(arg: string): string {
    switch (arg) {
        // Full file path
        case "FILEPATH": return vim.fn.expand("%:p");
        // Full file name
        case "FILENAME": return vim.fn.expand("%:t");
        // File path without filename
        case "FILEDIR": return vim.fn.expand("%:p:h");
        // File extension
        case "FILEEXT": return vim.fn.expand("%:e");
        // File name without extension
        case "FILENOEXT": return vim.fn.expand("%:t:r");
        // Current directory
        case "CWD": return vim.fn.getcwd();
        // Relative file path
        case "RELPATH": return vim.fn.expand("%");
        // Relative file path without filename
        case "RELDIR": return vim.fn.expand("%:h");
        // Time and date consts
        case "TIME": return os.date("%H:%M:%S");
        // Date in Day/Month/Year format
        case "DATE": return os.date("%d/%m/%Y");
        // Date in Month/Day/Year format
        case "USDATE": return os.date("%m/%d/%Y");
        // User name
        case "USERNAME": return os.getenv("USER");
        // PC name
        case "PCNAME": return vim.fn.system("uname -a").split(" ")[1];
        // OS
        case "OS": return vim.fn.system("uname").split("\n")[0];
        default: return " ";
    }
}

function get_build_args(build_name: string): string[] {
    let justloc = "";
    let pjustfile: string = `${vim.fn.getcwd()}/justfile`;
    if (vim.fn.filereadable(pjustfile) == 1) { justloc = `just -f ${pjustfile}`; }

    if (justloc == ""){
        popup("Justfile not found in project directory", "error", "Build");
        return [];
    }

    let outshow = vim.fn.system(`${justloc} -s ${build_name}`);
    if (outshow.startsWith("#") || outshow.startsWith("alias")) {
        outshow = outshow.split("\n")[1];
    }
    let outinfo = outshow.split(":")[0];
    // print(vim.inspect(outinfo));
    let args = outinfo.split(" ");
    // table.remove(args, 1);
    args.shift();
    if (args.length == 0) return [];
    let argsout: string[] = [];
    for (let i = 0; i < args.length; ++i) {
        let arg = args[i];
        let keywd = check_keyword_arg(arg);
        if (keywd == " ") {
            let a: string = "";
            if (arg.includes("=")) {
                let argw: string[] = arg.split("=");
                a = vim.fn.input(`${argw[0]}: `, argw[1]);
            } else {
                a = vim.fn.input(`${arg}: `, "");
            }
            // table.inser;t(argsout, a);
            // print(vim.inspect(a));
            // argsout.push(`"${a}"`);
            argsout.push(`${a}`);
        } else {
            if (keywd == "") keywd = " ";
            argsout.push(`"${keywd}"`);
        }
    }
    // popup(`Command args: ${argsout.join(" ")}`);
    return argsout;
}

// doesnt include aliases
function build_runner(build_name: string): void {
    let args: string[] = get_build_args(build_name);
    let justloc = "";
    let pjustfile: string = `${vim.fn.getcwd()}/justfile`;
    if (vim.fn.filereadable(pjustfile) == 1) { justloc = `just -f ${pjustfile}`; }

    if (justloc == ""){
        popup("Justfile not found in project directory", "error", "Build");
        return;
    }

    let command: string = `${justloc} -d . ${build_name} ${args.join(" ")}`;
    // popup(command);
    // let success: string = `aplay ${getConfigDir()}/res/build_success.wav -q`;
    // let error: string = `aplay ${getConfigDir()}/res/build_error.wav -q`;

    // USING AsyncRun
    // let lcom: string = `:AsyncRun /bin/bash -c '( ${command} ) && ( ${success} ) || ( ${error} )'`;
    // vim.cmd(lcom);

    // SECTION: ASYNC RUNNER
    // Own implementation depending on Plenary
    // I'm doing it because I prefer having control over those things
    // and AsyncRun was giving me some wierd errors at some places
    // and I can make it even prettier
    vim.schedule(function() {
        vim.cmd("copen");
        vim.fn.setqflist([{text: "Starting build job: " + command}, {text: ""}], "r");
    });

    let stime = os.clock();

    // @ts-ignore
    async.new({
        command: "bash",
        args: ["-c", `( ${command} )`],
        cwd: vim.fn.getcwd(),
        on_exit: function(j: any, ret: number) {
            let etime = os.clock() - stime;
            vim.schedule(function() {
                vim.fn.setqflist([
                    {text: ""},
                    {text: `Finished in ${string.format("%.2f", etime)} seconds`}
                ], "a");
                vim.cmd("cbottom");
                if (ret == 0) {
                    // @ts-ignore
                    async.new({
                        command: "aplay",
                        args: [`${getConfigDir()}/res/build_success.wav`, "-q"]
                    }).start();
                } else {
                    // @ts-ignore
                    async.new({
                        command: "aplay",
                        args: [`${getConfigDir()}/res/build_error.wav`, "-q"]
                    }).start();
                }
            });

        },
        on_stdout: function(err: string, data: string) {
            vim.schedule(function() {
                vim.fn.setqflist([{text: data}], "a");
                vim.cmd("cbottom");
            });
        },
        on_stderr: function(err: string, data: string) {
            vim.schedule(function() {
                // vim.cmd("copen");
                vim.cmd(`caddexpr '${data}'`);
                // vim.fn.setqflist([{text: data}], "a");
                vim.cmd("cbottom");
            });
        },
    }).start();
    // END SECTION: ASYNC RUNNER

    // popup("Done");
}

export function build_select(opts: any): void {
    if (opts == null) opts = [];
    let tasks: string[][] = get_build_names();
    if (tasks.length == 0) return;
    // TODO: replace with fzf
    let picker = pickers.new(opts, {
        prompt_title: "Build tasks",
        border: {},
        // borderchars: [ "─", "│", "─", "│", "┌", "┐", "┘", "└" ],
        borderchars: [ " ", " ", " ", " ", "┌", "┐", "┘", "└" ],
        finder: finders.new_table({
            results: tasks,
            entry_maker: (entry: any[]) => {
                return {
                    value: entry,
                    display: entry[0],
                    ordinal: entry[0]
                }
            }
        }),
        sorter: conf.generic_sorter(opts),
        attach_mappings: (buf: any, map: any) => {
            actions.select_default.replace(() => {
                actions.close(buf);
                let selection = action_state.get_selected_entry();
                let build_name = selection.value[2];
                build_runner(build_name);
            });
            return true;
        }
    });
    picker.find();
}

let telescopeConfig = { borderchars: {
     prompt: [ " ", " ", " ", " ", "┌", "┐", " ", " " ],
    results: [ " ", " ", " ", " ", "├", "┤", "┘", "└" ],
    preview: [ " ", " ", " ", " ", "┌", "┐", "┘", "└" ]
    //  prompt: [ "─", "│", " ", "│", "┌", "┐", "│", "│" ],
    // results: [ "─", "│", "─", "│", "├", "┤", "┘", "└" ],
    // preview: [ "─", "│", "─", "│", "┌", "┐", "┘", "└" ]
}}

export function run_task_select(): void {
    build_select(themes.get_dropdown(telescopeConfig));
}

export function run_task_default(): void {
    let tasks: string[][] = get_build_names();
    if (tasks.length == 0) return;
    for (let i = 0; i < tasks.length; ++i) {
        let opts: string[] = tasks[i][1].split("_");
        if (opts.length == 1) {
            if (opts[0].toLowerCase() == "default") {
                build_runner(tasks[i][1]);
                return;
            }
        }
    }
    popup(`Could not find default task. \nPlease select task from list.`, "warn", "Build");
    run_task_select();
}

export function run_task_build(): void {
    let tasks: string[][] = get_build_names();
    if (tasks.length == 0) return;
    for (let i = 0; i < tasks.length; ++i) {
        let opts: string[] = tasks[i][1].split("_");
        if (opts.length == 1) {
            if (opts[0].toLowerCase() == "build") {
                build_runner(tasks[i][1]);
                return;
            }
        }
    }
    popup(`Could not find build task. \nPlease select task from list.`, "warn", "Build");
    run_task_select();
}

export function run_task_run(): void {
    let tasks: string[][] = get_build_names();
    if (tasks.length == 0) return;
    for (let i = 0; i < tasks.length; ++i) {
        let opts: string[] = tasks[i][1].split("_");
        if (opts.length == 1) {
            if (opts[0].toLowerCase() == "run") {
                build_runner(tasks[i][1]);
                return;
            }        }
    }
    popup(`Could not find run task. \nPlease select task from list.`, "warn", "Build");
    run_task_select();
}

export function run_task_test(): void {
    let tasks: string[][] = get_build_names();
    if (tasks.length == 0) return;
    for (let i = 0; i < tasks.length; ++i) {
        let opts: string[] = tasks[i][1].split("_");
        if (opts.length == 1) {
            if (opts[0].toLowerCase() == "test") {
                build_runner(tasks[i][1]);
                return;
            }
        }
    }
    popup(`Could not find test task. \nPlease select task from list.`, "warn", "Build");
    run_task_select();
}

export function add_build_template(): void {
    let pjustfile: string = `${vim.fn.getcwd()}/justfile`;
    if (vim.fn.filereadable(pjustfile) == 1) {
        let opt = vim.fn.confirm("Justfile already exists in this project, create anyway?", "&Yes\n&No", 2);
        if (opt != 1) return;
    }

    let f = io.open(pjustfile, "w");
    f.write(
`# just reference: https://just.systems/man/en/
# cheatsheet: https://cheatography.com/linux-china/cheat-sheets/justfile/
# monolith flavor: ~/.config/nvim/readme/build.md

# Allows positional arguments
set positional-arguments

# This is a default recipe
# Tf "default" recipe is not there then
# first recipe will be considered default
#
# Prints all available recipes
# default:
#     @just --list
#
# Here's a quick cheatsheet/overview of just and monoltih flavor
# Monolith \\bb, \\br, \\bt behavor (\\bB will show all)
# build - will be default build task "\\bb"
# run - will be default run task "\\br"
# test - will be default test task "\\bt"
#
# Just:
# Set a variable (variable case is arbitrary)
# SINGLE := "--single"
#
# Join paths:
# myPaths := "path/to" / "file" + ".txt"
#
# Or conditions
# foo := if "2" == "2" { "Good!" } else { "1984" }
#
# Run set configurations
# all: build_d build_d_custom _echo
#
# Alias to a recipe (just noecho)
# alias noecho := _echo
#
# Example configuration (dub build not going to be printed):
# build_d:
#     @dub build
#
# Or use this to silence all command prints (output will still print):
# @build_d_custom:
#     dub build
#     dub run
#
# Continue even on fail  by adding "-" ([linux] makes recipe be seen only in linux)
# [linux]
# test:
#    -cat notexists.txt
#    echo "Still executes"
#
# Configuration using variable from above
# buildFile FILENAME:
#     dub build {{SINGLE}} $1
#
# Set env
# @test_d:
#     #!/bin/bash
#     ./test.sh
#
# Private task
# _echo:
#     echo "From echo"
#
# A command's arguments can be passed to dependency
# build target:
#     @echo "Building {{target}}…"
#
# push target: (build target)
#     @echo 'Pushing {{target}}…'
#
# Use \`\` to eval command, () to join paths
# in them and arg=default to set default value
# test target test=\`echo "default"\`:
#     @echo 'Testing {{target}} {{test}}'
#
# Use + (1 ore more) or * (0 or more) to make argument variadic. Must be last
# ntest +FILES="justfile1 justfile2":
#     echo "{{FILES}}"
#
# Dependencies always run before recipe, unless they're after &&
# This example will run "a" before "b" and "c" and "d" after "b"
# b: a && c d:
#     echo "b"
#
# Each recipe line is executed by a new shell,
# so if you change the working directory on one line,
# it won't have an effect on later lines.
# A safe way to work around this is to use shebang ("#!/bin/bash")
# foo:
#     pwd    # This \`pwd\` will print the same directory…
#     cd bar
#     pwd    # …as this \`pwd\`!
`);
    f.close();

    popup("Template justfile created", "info", "Build");
}
// run_task_select();
// run_default_task();


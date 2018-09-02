extern crate cmdshelf;

use std::process::{ exit };
use std::env;
use cmdshelf::reporter;
use cmdshelf::commands;

const VERSION: &str = "2.0.0";

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        commands::help_command().run([].to_vec()).ok();
        return
    }

    if args[1] == "--version" {
        println!("{}", VERSION);
        return
    }

    let mut _args = args;
    let args_remainder = _args.split_off(2);
    let mut sub_command = commands::sub_command(&_args[1]);
    match sub_command.run(args_remainder) {
        Ok(status)  => exit(status),
        Err(err) => {
            reporter::error(format!("cmdshelf {}: {}", sub_command.name(), err));
            exit(1)
        },
    }
}


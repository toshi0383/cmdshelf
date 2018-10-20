extern crate cmdshelf;

use std::process::{ exit };
use std::env;
use cmdshelf::reporter;
use cmdshelf::commands::Runnable;
use cmdshelf::commands;

const VERSION: &str = "2.0.2";

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        commands::help_command().run([].to_vec()).ok();
        return
    }

    if args[1] == "--help" {
        commands::help_command().run([].to_vec()).ok();
        return
    }

    if args[1] == "--version" {
        println!("{}", VERSION);
        return
    }

    let mut _args = args;
    let args_remainder = _args.split_off(2);

    let status = commands::sub_command(&_args[1])
        .and_then(|mut sub_command: Box<dyn Runnable + 'static>| -> Result<i32, String> {
            sub_command.run(args_remainder)
                .or_else(|msg| {
                    reporter::error(format!("cmdshelf {}: {} ", sub_command.name(), msg));
                    Ok(1)
                })
        })
        .or_else(|msg: String| -> Result<i32, String> {
            reporter::error(format!("cmdshelf: {}", msg));
            Ok(1)
        })
        .unwrap();

    exit(status)
}


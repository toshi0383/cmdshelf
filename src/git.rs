use context::Context;
use corecli::{ get_stdout };
use reporter;

use std::io::stdout;
use std::io::Write;

pub fn clone_remotes_if_needed(ctx: &Context) {

    for r in &ctx.remotes {

        let remote_dir = ctx.remote_alias_path(&r.alias);
        let remote_dir_path = remote_dir.as_path();

        if !remote_dir_path.exists() {

            print!("[{}] Cloning ...", r.alias);
            stdout().flush().expect("stdout().flush() failed.");

            let cmd = format!("git clone {} {}", r.url, remote_dir_path.to_str().unwrap());
            match get_stdout(&cmd) {

                Ok(_)    => reporter::successful("success".to_owned()),

                Err(msg) => {
                    reporter::error("failed".to_owned());
                    println!("{}", msg);
                },

            }
        }
    }
}

pub fn update_or_clone_remotes(ctx: &Context) {

    clone_remotes_if_needed(ctx);

    for r in &ctx.remotes {

        let remote_dir = ctx.remote_alias_path(&r.alias);
        let remote_dir_path = remote_dir.as_path();

        if remote_dir_path.exists() {

            print!("[{}] Updating ...", r.alias);
            stdout().flush().expect("stdout().flush() failed.");

            let cmd = format!("cd {} && git fetch origin master && git checkout origin/master", remote_dir.to_str().unwrap());

            match get_stdout(&cmd) {

                Ok(_)    => reporter::successful("success".to_owned()),

                Err(msg) => {
                    reporter::error("failed".to_owned());
                    println!("{}", msg);
                },

            }
        }
    }
}

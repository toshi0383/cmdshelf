use context::Context;
use corecli::{ get_stdout };
use reporter;

use std::io::stdout;
use std::io::Write;
use std::path::Path;

pub fn clone_remotes_if_needed(ctx: &Context) {

    for r in &ctx.remotes {

        let remote_dir = format!("{}/remote/{}", ctx.workspace_dir, r.alias);

        if !Path::new(&remote_dir).exists() {

            print!("[{}] Cloning ...", r.alias);
            stdout().flush().expect("stdout().flush() failed.");

            let cmd = format!("git clone {} {}", r.url, &remote_dir);

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

        let remote_dir = format!("{}/remote/{}", ctx.workspace_dir, r.alias);

        if Path::new(&remote_dir).exists() {

            print!("[{}] Updating ...", r.alias);
            stdout().flush().expect("stdout().flush() failed.");

            let cmd = format!("cd {} && git fetch origin master && git checkout origin/master", &remote_dir);

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

use super::Runnable;
use context::Context;
use corecli::spawn;
use git;

pub struct Run {
}
impl Runnable for Run {
    fn name(&self) -> String {
        return "run".to_owned()
    }

    fn run(&mut self, args: Vec<String>) -> Result<i32, String> {
        if args.len() == 0 {
            return Err("missing argument".to_owned());
        }

        let arg = &args[0];
        let ctx = Context::new();

        git::clone_remotes_if_needed(&ctx);

        ctx.command_path(arg)
            .and_then(|executable_fullpath| {
                let args = &args[1..];
                let mut args: Vec<String> = args.into_iter().map(|x| format!("'{}'", x)).collect();
                let executable_fullpath = executable_fullpath.as_path().to_str().unwrap();

                args.insert(0, executable_fullpath.to_owned());
                let command = args.join(" ");
                spawn(&command)
                    .map_err(|()| "failed to execute command".to_owned())
            })
    }
}

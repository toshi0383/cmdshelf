use super::Runnable;
use context::Context;
use corecli::spawn;
use git;

pub struct Cat {
}
impl Runnable for Cat {
    fn name(&self) -> String {
        return "cat".to_owned()
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
                let cmd = format!("cat {}", executable_fullpath);
                spawn(&cmd)
                    .map_err(|()| "failed to execute command".to_owned())
            })
    }
}

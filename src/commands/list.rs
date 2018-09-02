use super::Runnable;
use context::Context;
use git;

pub struct List {
}
impl Runnable for List {
    fn name(&self) -> String {
        return "list".to_owned()
    }

    fn run(&mut self, args: Vec<String>) -> Result<i32, String> {
        let is_fullpath = args.contains(&"--path".to_owned());

        let ctx = Context::new();

        git::clone_remotes_if_needed(&ctx);

        for command_entry in &ctx.all_commandentries() {

            let path_str: String = if is_fullpath {
                command_entry.fullpath.to_owned()
            } else {
                format!("{}:{}", command_entry.remote, command_entry.path())
            };

            println!("{}", path_str);
        }

        Ok(0)
    }
}

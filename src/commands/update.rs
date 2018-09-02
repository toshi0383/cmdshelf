use super::Runnable;
use context::Context;
use git;

pub struct Update {
}
impl Runnable for Update {
    fn name(&self) -> String {
        return "update".to_owned()
    }

    fn run(&mut self, _: Vec<String>) -> Result<i32, String> {
        let ctx = Context::new();
        git::update_or_clone_remotes(&ctx);
        Ok(0)
    }
}

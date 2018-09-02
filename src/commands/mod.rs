mod cat;
mod help;
mod list;
mod remote;
mod run;
mod update;

use self::cat::Cat;
use self::help::Help;
use self::list::List;
use self::remote::Remote;
use self::run::Run;
use self::update::Update;

pub trait Runnable {
    fn name(&self) -> String;
    fn run(&mut self, args: Vec<String>) -> Result<i32, String>;
}

pub fn help_command() -> Box<Runnable + 'static> {
    Box::new(Help { })
}

pub fn sub_command(string: &str) -> Box<Runnable + 'static> {
    match string.as_ref() {
        "cat"    => Box::new(Cat { }),
        "list"   => Box::new(List { }),
        "ls"     => Box::new(List { }),
        "remote" => Box::new(Remote { }),
        "run"    => Box::new(Run { }),
        "update" => Box::new(Update { }),
        _        => Box::new(Help { }),
    }
}

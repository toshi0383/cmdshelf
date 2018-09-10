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

pub fn help_command() -> Box<dyn Runnable + 'static> {
    Box::new(Help { })
}

pub fn sub_command(string: &str) -> Result<Box<dyn Runnable + 'static>, String> {
    match string.as_ref() {
        "cat"    => Ok(Box::new(Cat { })),
        "list"   => Ok(Box::new(List { })),
        "ls"     => Ok(Box::new(List { })),
        "remote" => Ok(Box::new(Remote { })),
        "run"    => Ok(Box::new(Run { })),
        "update" => Ok(Box::new(Update { })),
        "help"   => Ok(Box::new(Help { })),
        _        => Err(format!("no such command: {}", string)),
    }
}

use super::Runnable;
use context::Context;
use std::path::MAIN_SEPARATOR;

pub struct Remote {
}
impl Runnable for Remote {
    fn name(&self) -> String {
        return "remote".to_owned()
    }

    fn run(&mut self, args: Vec<String>) -> Result<i32, String> {
        if args.len() < 1 {
            return Err("missing arguments".to_owned())
        }

        let mut _args = args;
        let args_remainder = _args.split_off(1);

        sub_command(&_args[0])
            .and_then(|mut c| c.run(args_remainder))
    }

}

fn sub_command(arg: &str) -> Result<Box<Runnable + 'static>, String> {
    match arg {
        "add"    => Ok(Box::new(Add { })),
        "remove" => Ok(Box::new(Remove { })),
        "list"   => Ok(Box::new(List { })),
        "ls"     => Ok(Box::new(List { })),
        _        => Err(format!("invalid argument: {}", arg)),
    }
}

struct Add {
}

impl Runnable for Add {

    fn name(&self) -> String {
        return "add".to_owned()
    }

    fn run(&mut self, args: Vec<String>) -> Result<i32, String> {
        if args.len() < 2 {
            return Err("add: missing arguments".to_owned());
        }

        let alias = &args[0];

        let a = &args[1];

        let url =
            if !(a.starts_with("https") || a.starts_with("git"))
                && a.split(MAIN_SEPARATOR).collect::<Vec<&str>>().len() == 2 {
                format!("git@github.com:{}.git", a)
            } else {
                format!("{}", a)
            };

        let ctx = Context::new();
        ctx.add_or_update_remote(alias, &url)
            .and(Ok(0))
    }
}

struct Remove {
}

impl Runnable for Remove {

    fn name(&self) -> String {
        return "remove".to_owned()
    }

    fn run(&mut self, args: Vec<String>) -> Result<i32, String> {
        if args.len() < 1 {
            return Err("remove: missing arguments".to_owned());
        }

        let alias = &args[0];

        let ctx = Context::new();
        ctx.remove_remote(alias)
            .and(Ok(0))
    }
}

struct List {
}

impl Runnable for List {

    fn name(&self) -> String {
        return "list".to_owned()
    }

    fn run(&mut self, _: Vec<String>) -> Result<i32, String> {
        let ctx = Context::new();
        for r in ctx.remotes {
            println!("{}:{}", &r.alias, &r.url);
        }

        Ok(0)
    }
}

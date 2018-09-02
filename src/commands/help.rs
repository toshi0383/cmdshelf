use super::Runnable;
use corecli::spawn;

use std::fmt;

#[derive(Copy,Clone)]
enum HelpPage {
    Run,
    Cat,
    List,
    Remote,
    Update,
    Default,
}

impl HelpPage {
    fn from(arg: &str) -> HelpPage {
        match arg {
            "run"     => HelpPage::Run,
            "cat"     => HelpPage::Cat,
            "list"    => HelpPage::List,
            "ls"      => HelpPage::List,
            "remote"  => HelpPage::Remote,
            "update"  => HelpPage::Update,
            _         => HelpPage::Default,
        }
    }

    fn manpage(&self) -> String {
        format!("cmdshelf-{}", self)
    }
}

impl fmt::Display for HelpPage {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let printable = match *self {
            HelpPage::Default => "default",
            HelpPage::Run     => "run",
            HelpPage::Cat     => "cat",
            HelpPage::List    => "list",
            HelpPage::Remote  => "remote",
            HelpPage::Update  => "update",
        };
        write!(f, "{}", printable)
    }
}

pub struct Help {
}
impl Runnable for Help {
    fn name(&self) -> String {
        return "help".to_owned()
    }

    fn run(&mut self, args: Vec<String>) -> Result<i32, String> {
        let helppage = {
            if args.len() < 1 {
                HelpPage::Default
            } else {
                HelpPage::from(&args[0])
            }
        };

        let manpage = match helppage {
            HelpPage::Default => "cmdshelf".to_owned(),
            _ => helppage.manpage(),
        };
        println!("{}", manpage);

        let cmd = format!("man {} | ${{PAGER:-more}}", manpage);

        spawn(&cmd)
            .map_err(|_| "Failed to spawn man-page process.".to_owned())
    }
}

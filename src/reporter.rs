use std::io::Write;

enum Color {
    Red,
    Green,
    Yellow,
    Reset,
}

fn color_string(color: Color) -> String {
    match color {
        Color::Red    => "\u{001B}[0;31m".to_string(),
        Color::Green  => "\u{001B}[0;32m".to_string(),
        Color::Yellow => "\u{001B}[0;33m".to_string(),
        Color::Reset  => "\u{001B}[0;0m".to_string(),
    }
}

fn _println<O>(out: &mut O, color: Color, message: String) where O: Write {
    writeln!(
        out,
        "{}{}{}",
        color_string(color),
        message,
        color_string(Color::Reset)
    ).expect("Failed writing to stderr");
}

pub fn successful(message: String) {
    _println(&mut ::std::io::stdout(), Color::Green, message);
}

pub fn error(message: String) {
    _println(&mut ::std::io::stderr(), Color::Red, message);
}

pub fn warning(message: String) {
    _println(&mut ::std::io::stdout(), Color::Yellow, message);
}

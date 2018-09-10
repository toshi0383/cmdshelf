use std::fmt;
use std::io::Write;

enum Color {
    Red,
    Green,
    Yellow,
    Reset,
}

impl fmt::Display for Color {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let s: &str = match self {
            Color::Red    => "\u{001B}[0;31m",
            Color::Green  => "\u{001B}[0;32m",
            Color::Yellow => "\u{001B}[0;33m",
            Color::Reset  => "\u{001B}[0;0m",
        };

        write!(f, "{}", s)
    }
}

fn _println<O>(out: &mut O, color: Color, message: String) where O: Write {
    writeln!(
        out,
        "{}{}{}",
        color,
        message,
        Color::Reset
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

#[cfg(test)]
mod tests {
    use super::{Color, _println};
    
    #[test]
    fn _println_with_color_red() {
        let mut v: Vec<u8> = Vec::new();
        _println(&mut v, Color::Red, "__test__".to_string());
        assert_eq!(String::from_utf8(v).unwrap(), "\u{1b}[0;31m__test__\u{1b}[0;0m\n");
    }

    #[test]
    fn _println_with_color_green() {
        let mut v: Vec<u8> = Vec::new();
        _println(&mut v, Color::Green, "__test__".to_string());
        assert_eq!(String::from_utf8(v).unwrap(), "\u{1b}[0;32m__test__\u{1b}[0;0m\n");
    }

    #[test]
    fn _println_with_color_yellow() {
        let mut v: Vec<u8> = Vec::new();
        _println(&mut v, Color::Yellow, "__test__".to_string());
        assert_eq!(String::from_utf8(v).unwrap(), "\u{1b}[0;33m__test__\u{1b}[0;0m\n");
    }

    #[test]
    fn _println_with_color_reset() {
        let mut v: Vec<u8> = Vec::new();
        _println(&mut v, Color::Reset, "__test__".to_string());
        assert_eq!(String::from_utf8(v).unwrap(), "\u{1b}[0;0m__test__\u{1b}[0;0m\n");
    }
}
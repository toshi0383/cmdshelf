use std::process::Command;

pub fn spawn(command: &str) -> Result<i32, ()> {
    let child = if cfg!(target_os = "windows") {
        Command::new("cmd")
                .args(&["/C", command])
                .spawn()
    } else {
        Command::new("sh")
                .arg("-c")
                .arg(command)
                .spawn()
    };
    if let Ok(mut child) = child {
        match child.wait() {
            Ok(status) => Ok(status.code().unwrap()),
            Err(_)     => Ok(256),
        }
    } else {
        Err(())
    }
}

// TODO: read lines progressively
// https://doc.rust-lang.org/std/io/trait.BufRead.html
// https://doc.rust-lang.org/std/io/struct.Lines.html
pub fn get_stdout(command: &str) -> Result<String, String> {
    let output = if cfg!(target_os = "windows") {
        Command::new("cmd")
                .args(&["/C", command])
                .output()
    } else {
        Command::new("sh")
                .arg("-c")
                .arg(command)
                .output()
    };

    output
        .map(|output| format!("{}", String::from_utf8_lossy(&output.stdout)))
        .map_err(|err| err.to_string())
}

extern crate is_executable;
extern crate walkdir;

use self::walkdir::{ WalkDir, DirEntry };
use self::is_executable::IsExecutable;
use std::path::{ Path, PathBuf, MAIN_SEPARATOR };
use std::error::Error;
use std::fmt;
use std::fs;
use toml;

pub struct Context {
    pub remotes: Vec<RemoteConfig>,
    pub workspace_dir: String,
}

pub struct CommandEntry<'a> {
    pub remote: &'a str,
    pub fullpath: String,
}

impl<'a> CommandEntry<'a> {
    pub fn new(remote: &'a str, fullpath: String) -> Self {
        CommandEntry {
            remote: remote,
            fullpath: fullpath,
        }
    }

    pub fn path(&self) -> &str {
        let s = format!("{}{}", self.remote, MAIN_SEPARATOR);
        let paths = self.fullpath.split(&s).collect::<Vec<&str>>();
        let command_path = paths.last();

        command_path.unwrap()
    }
}

impl<'a> Context {
    pub fn new() -> Self {
        let toml = default_toml_path();
        let config = read_or_create_config(toml.as_path());

        let mut remotes = Vec::new();
        for r in config.remotes {
            remotes.push(r.clone());
        }

        let mut workspace_dir = get_homedir_path().expect("");
        workspace_dir.push(".cmdshelf");

        Context {
            remotes: remotes,
            workspace_dir: workspace_dir.as_path().to_str().unwrap().to_owned(),
        }
    }

    pub fn remote_alias_path(&self, alias: &str) -> PathBuf {
        let mut remote_dir = Path::new(&self.workspace_dir).join("remote");
        remote_dir.push(alias);
        remote_dir
    }

    /// returns: command's fullpath
    ///   Err if not exists or not an executable
    pub fn command_path(&self, arg: &str) -> Result<PathBuf, String> {
        let vec: Vec<&str> = arg.split(":").collect();

        match vec.len() {
            1 => {
                for remote in &self.remotes {
                    let result: Option<Result<PathBuf, String>> = match self.get_path(&remote.alias, &vec[0]) {
                        Ok(path) => Option::Some(Ok(path)),
                        Err(err) => {
                            match &err {
                                FileError::NotFound(_) => None,
                                FileError::NotExecutable(_) => Option::Some(Err(err.description_())),
                                FileError::NoHomeDir => Option::Some(Err(err.description_())),
                            }
                        },
                    };
                    if let Some(result) = result {
                        return result;
                    }
                }
                Err(format!("No such command: {}", arg))
            },

            2 => {
                self.get_path(&vec[0], &vec[1])
                    .map_err(|e| e.description_())
            },

            _ => panic!(),

        }
    }

    pub fn all_commandentries(&'a self) -> Vec<CommandEntry<'a>> {
        // TODO: use flat_map. Did not compile.

        let mut arr = Vec::new();

        for remote in self.remotes.iter() {

            let mut remote_base = Path::new(&self.workspace_dir)
                .join("remote");

            remote_base.push(&remote.alias);

            //
            // recursive children using walkdir lib.
            //

            fn is_hidden(entry: &DirEntry) -> bool {
                entry.file_name()
                     .to_str()
                     .map(|s| s.starts_with("."))
                     .unwrap_or(false)
            }

            for entry in WalkDir::new(remote_base)
                .follow_links(true)
                .into_iter()
                .filter_entry(|e| !is_hidden(e)) {

                let tmp = entry.unwrap();
                let fullpath = tmp.path();
                let is_git = {
                    let tmp = fullpath.to_str().unwrap();
                    let components: Vec<&str> = tmp.split(MAIN_SEPARATOR).collect();
                    components.contains(&".git")
                };

                if is_git || !fullpath.is_file() || !fullpath.is_executable() {
                    continue;
                }

                let fullpath_string = fullpath.to_str().unwrap().to_owned();

                let commandentry = CommandEntry::new(&remote.alias, fullpath_string);

                arr.push(commandentry);
            }
        }

        arr
    }

    fn get_path(&self, remote: &str, path: &str) -> Result<PathBuf, FileError> {
        let result = get_homedir_path()
            .map(|home| {
                let mut buf = home.join(".cmdshelf");

                buf.push("remote");
                buf.push(remote);
                buf.push(path);

                return buf
            });

        self.validate_path(result)
    }

    fn validate_path(&self, result: Result<PathBuf, FileError>) -> Result<PathBuf, FileError> {
        match result {
            Ok(p) => {
                let path = p.as_path();

                if path.exists() {

                    let s = path.to_str().unwrap().to_owned();

                    if p.is_executable() {
                        return Ok(path.to_path_buf());
                    } else {
                        return Err(FileError::NotExecutable(s));
                    }
                }

                Err(FileError::NotFound(path.to_str().unwrap().to_owned()))
            },

            result @ Err(_) => result
        }
    }

    pub fn remove_remote(&self, alias: &str) -> Result<(), String> {
        let toml = default_toml_path();
        let mut config = read_or_create_config(toml.as_path());

        let mut remotes = config.remotes.to_vec();

        let mut index: Option<usize> = None;

        for (i, r) in remotes.iter().enumerate() {
            if r.alias == alias {
                index = Some(i);
                break;
            }
        }

        if let Some(i) = index {
            remotes.remove(i);
        }

        config.remotes = remotes;

        let s = toml::to_string(&config).unwrap();

        fs::write(&toml, s)
            .map_err(|_| format!("failed to write toml at: {}", toml.as_path().to_str().unwrap()))
    }

    pub fn add_or_update_remote(&self, alias: &str, url: &str) -> Result<(), String> {
        let toml = default_toml_path();
        let mut config = read_or_create_config(toml.as_path());

        // check for duplicate
        {
            let remotes = config.remotes.clone().to_vec();

            for r in remotes {
                if r.alias.as_str() == alias {
                    return Err(format!("remote alias '{}' already exists.", alias).to_owned());
                }
            }
        }

        let remote = RemoteConfig {
            alias: alias.to_owned(),
            url: url.to_owned(),
        };

        let mut remotes = config.remotes.to_vec();

        remotes.push(remote);
        config.remotes = remotes;

        let s = toml::to_string(&config).unwrap();

        fs::write(&toml, s)
            .map_err(|_| format!("failed to write toml at: {}", toml.as_path().to_str().unwrap()))
    }
}

#[derive(Debug, Deserialize, Serialize)]
pub struct Config {
    remotes: Vec<RemoteConfig>,
}

impl Config {
    fn new() -> Self {
        Config {
            remotes: vec![],
        }
    }
}

#[derive(Debug, Deserialize, Serialize)]
pub struct RemoteConfig {
    pub alias: String,
    pub url: String,
}

impl Clone for RemoteConfig {
    fn clone(&self) -> RemoteConfig {
        RemoteConfig {
            alias: self.alias.clone(),
            url: self.url.clone(),
        }
    }
}

#[derive(Debug)]
enum FileError {
    NotFound(String),
    NotExecutable(String),
    NoHomeDir,
}

impl Error for FileError {
    fn description(&self) -> &str {
        ""
    }
}

impl FileError {
    fn description_(&self) -> String {
        match self {
            FileError::NotFound(string) => format!("No such command: {}", string),
            FileError::NotExecutable(string) => format!("Permission denied: {}", string),
            FileError::NoHomeDir => "No HOME directory specified".to_owned(),
        }
    }
}

impl fmt::Display for FileError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "invalid first item to double")
    }
}

fn get_homedir_path() -> Result<PathBuf, FileError> {
    use std::env;

    env::home_dir()
        .map(|p| p.canonicalize().expect("failed to canonizalize"))
        .ok_or(FileError::NoHomeDir)
}

fn read_or_create_config(path: &Path) -> Config {
    let config: Config = match fs::read_to_string(path) {
        Ok(contents) => {
            toml::from_str(&contents)
                .unwrap_or_else(|_| create_new_config(path))
        },
        Err(_) => {
            create_new_config(path)
        },
    };

    config
}

fn create_new_config(path: &Path) -> Config {
    let config = Config::new();
    let s = toml::to_string(&config).unwrap();
    fs::write(path.to_str().unwrap(), s).expect("failed to write toml");
    config
}

fn default_toml_path() -> PathBuf {
    let mut home = get_homedir_path().expect("");
    home.push(".cmdshelf.toml");
    home
}


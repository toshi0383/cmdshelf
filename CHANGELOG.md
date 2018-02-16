## 0.9.4
##### Enhancement
* Add missing man-pages [#67](https://github.com/toshi384/cmdshelf/pull/67)  
  [Toshihiro Suzuki](https://github.com/toshi0383)

* Use $PAGER for spawning man-page process if specified [#66](https://github.com/toshi384/cmdshelf/pull/66)  
  [Toshihiro Suzuki](https://github.com/toshi0383)

* improve `update` command output [#63](https://github.com/toshi0383/cmdshelf/pull/63)  
  [Toshihiro Suzuki](https://github.com/toshi0383)

## 0.9.3
##### Bugfix
* fix crash on empty runner [#61](https://github.com/toshi0383/cmdshelf/pull/61)  
  [Toshihiro Suzuki](https://github.com/toshi0383)

- fix --version printing "--version" [#62](https://github.com/toshi0383/cmdshelf/pull/62)  
  [Toshihiro Suzuki](https://github.com/toshi0383)

- fix -h or --help not working [#62](https://github.com/toshi0383/cmdshelf/pull/62)  
  [Toshihiro Suzuki](https://github.com/toshi0383)


## 0.9.2
##### Enhancements
* Open man-pager on `help list` [#57](https://github.com/toshi0383/cmdshelf/pull/57)  
  [Toshihiro Suzuki](https://github.com/toshi0383)

* Add man1/cmdshelf-list.1 manual page [#56](https://github.com/toshi0383/cmdshelf/pull/56)  
  [Toshihiro Suzuki](https://github.com/toshi0383)

## 0.9.1
##### Enhancements
* Add man1/cmdshelf.1 manual page [#54](https://github.com/toshi0383/cmdshelf/pull/54)  
  [Toshihiro Suzuki](https://github.com/toshi0383)

## 0.9.0
##### Bugfix & Breaking
* [fixed] set error status code on error [#52](https://github.com/toshi0383/cmdshelf/pull/52)  
  [Toshihiro Suzuki](https://github.com/toshi0383)

* [fixed] Quoted parameter is unquoted [#49](https://github.com/toshi0383/cmdshelf/issues/49)  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#50](https://github.com/toshi0383/cmdshelf/issues/50)  
  **Breaking**: This changes the way subcommand is evaluated. Double/Single quoted alias parameter argument does not work any more.

## 0.8.0
##### Enhancements
* No need to quote command with parameters  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#43](https://github.com/toshi0383/cmdshelf/pull/43)

* Improve Help and Manual Pages  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#45](https://github.com/toshi0383/cmdshelf/pull/45)

## 0.7.2
##### Enhancements
* Add description for each commands  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#40](https://github.com/toshi0383/cmdshelf/pull/40)

## 0.7.1
##### Bugfix
* [fixed] run concats all parameters  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#35](https://github.com/toshi0383/cmdshelf/issues/35)

* [fixed] [Linux] Runtime Error  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#38](https://github.com/toshi0383/cmdshelf/issues/38)

## 0.7.0
##### Enhancements
* Add --path option for `list` command  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#33](https://github.com/toshi0383/cmdshelf/pull/33)

* Introduce new COMMAND argument syntax to distinguish remotes  
  `"[remoteName:]my/command [parameter ...]"`  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#34](https://github.com/toshi0383/cmdshelf/pull/34)

## 0.6.0
##### Enhancements
* Add cat command  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#27](https://github.com/toshi0383/cmdshelf/pull/27)

* Add S and L option to curl command of `run`  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#29](https://github.com/toshi0383/cmdshelf/pull/29)

##### Bugfix
* [Fixed] blob adds relative path and `run` fails to execute.  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#28](https://github.com/toshi0383/cmdshelf/pull/28)

## 0.5.0
##### Enhancements
* Linux Support  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#25](https://github.com/toshi0383/cmdshelf/pull/25)

## 0.4.0
##### Breaking
* Remove `swiftpm` command  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#21](https://github.com/toshi0383/cmdshelf/pull/21)

* Remove `remote run` command  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#22](https://github.com/toshi0383/cmdshelf/pull/22)

##### Bugfix
* Fix URL blob ignoring parameters  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#23](https://github.com/toshi0383/cmdshelf/pull/23)

##### Enhancements
* Colorful Output on warning and error  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#14](https://github.com/toshi0383/cmdshelf/pull/14)

* Improve run command description  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#17](https://github.com/toshi0383/cmdshelf/pull/17)

* Pass through stdin  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#16](https://github.com/toshi0383/cmdshelf/pull/16)

* Improve error handling and output  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#20](https://github.com/toshi0383/cmdshelf/pull/20)

## 0.3.1

##### Enhancements
* Deprecate swiftpm command  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#13](https://github.com/toshi0383/cmdshelf/pull/13)

## 0.3.0
##### Breaking
* Remove bootstrap sub-command  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#10](https://github.com/toshi0383/cmdshelf/pull/10)

##### Bugfix
* Fix remote updating process: git pull => fetch and checkout  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#8](https://github.com/toshi0383/cmdshelf/pull/8)

## 0.2.1
##### Enhancements

* Allow local path for blob  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#7](https://github.com/toshi0383/cmdshelf/pull/7)

* Print SwiftPM Version on `list` command  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#6](https://github.com/toshi0383/cmdshelf/pull/6)

##### Bugfix

* Fix checking out wrong tag on SwiftPM update  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#4](https://github.com/toshi0383/cmdshelf/pull/4)

## 0.2.0
##### Enhancements

* Safer `update` and improve logging  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#3](https://github.com/toshi0383/cmdshelf/pull/3)

* Add branch and tag support for SwiftPM  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#2](https://github.com/toshi0383/cmdshelf/pull/2)

* Avoid potential name collision issue  
  [Toshihiro Suzuki](https://github.com/toshi0383)
  [#1](https://github.com/toshi0383/cmdshelf/pull/1)

## 0.1.x (Initial)

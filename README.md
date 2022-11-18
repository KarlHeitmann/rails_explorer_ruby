# OVERVIEW

Simple wrapper for [ripgrep](https://github.com/BurntSushi/ripgrep). You must install ripgrep to use this wrapper.

The goal of this project is to read the output from ripgrep in JSON format, and provide the user with some commands to
do further work with the results.

Up until now, I created some classes that model the different types of objects ripgrep will generate with `--json` flag.
But I have not found any cool [TUI](https://en.wikipedia.org/wiki/Text-based_user_interface) library for Ruby. So I am
putting all my efforts on [rg_wrapper](https://github.com/KarlHeitmann/rg_wrapper) project.

Some cool TUI libraries are available for other languages:
- GO: [bubbleatea](https://github.com/charmbracelet/bubbletea) and
[asciigraph](https://github.com/guptarohit/asciigraph). However, asciigraph is a library to plot data, not a TUI.
- Rust: [tui](https://docs.rs/tui/latest/tui/)

If somebody founds something like this but for Ruby, leave a comment in any section and I will resume this project.

# OUTDATED!!! USAGE EXAMPLES

Run this commands and compare the output. Ensure you have ripgrep installed on yout system before running the following
examples:

> rg def

This will search all `def` words inside this folder. ie, all places where a function is defined. Take a look at the
output: it shows you the name of the file where there is one or more matches, and then it shows you in which line of the
file is the match.

> rg def --json

This will do the same search as above, but the format is JSON. This is so difficult for humands to read, but this data
is easy to parse, and you can parse it in almost every programming language. It has much more details than the command
ran before.



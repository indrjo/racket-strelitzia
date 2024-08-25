# Strelitzia

Suppose you have just installed a [minimal TeX Live](https://github.com/indrjo/minimal-texlive-installer.git) or you suspect you do not have enough packages. Assume also you want to produce your document with, say,

``` sh
$ pdflatex main.tex
```

It probably won't work owing to missing packages from your TeX Live. It is a work for `strelitzia`:

``` sh
$ strelitzia main.tex
```

*Strelitzia* coordinates a couple of actors: while it runs `pdflatex main.tex`, it extracts from the log the names of the missing files, invokes *tlmgr* to infer the name of the packages owning them and uses *tlmgr* to install them.

**(Warning)** How the command `pdflatex main.tex` terminates (zero o non-zero exit code) is not relevant to the program.

**(Warning)** The dependencies of TeX Live are a hell: which means you might have to run *strelitzia* more than once to get all dependencies satisfied.

**(Hint)** You can help the *strelitzia*., at least for the very first times. The option `--check-imports FILE`, where `FILE` is the file where you have declared the document class and the packages required, will make *strelitzia* install those packages first of all. Thus, for example, you may run something like this

``` sh
$ strelitzia --check-imports preamble.tex main.tex
```

This often results in a minor amount of re-runs.

Once your ecosystem is enough for your work, you can go back to the good old

``` sh
$ pdflatex main.tex
```


## Usage

**(Warning)** Always refer to `strelitzia --help`, because the program might change faster than its documentation.

Basic usage:

``` sh
$ strelitzia -e TEX_ENGINE FILE.tex
```

If you omit the part `-e TEX_ENGINE`, then the program will assume `TEX_ENGINE` equal to `pdflatex`. Other values for `TEX_ENGINE` are `pdflatex`, `lualatex`, `xelatex` and so on... Make sure binaries can be found in one of the directories in `PATH`.


## Installation

The program is written in [Racket](https://racket-lang.org). One module that may not be installed is `parsack`. Install it if needed:

``` sh
$ raco pkg install parsack
```

There is a simple `Makefile` here.

```sh
$ make       # install strelitzia
$ make doc   # a copy of this README for you
```

The program and the documentation are put in `~/.local/bin`: just make sure the location you want occurs in `$PATH`. If you want to change this behaviour, edit the following line of `Makefile`:

```Makefile
INSTALL_DIR = $(HOME)/.local/bin
```


## Friends

* https://github.com/indrjo/haskell-strelitzia.git


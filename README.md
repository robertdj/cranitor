cranitor
========

<!-- badges: start -->
[![Travis build status](https://travis-ci.org/robertdj/cranitor.svg?branch=master)](https://travis-ci.org/robertdj/cranitor)
[![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/robertdj/cranitor?branch=master&svg=true)](https://ci.appveyor.com/project/robertdj/cranitor)
<!-- badges: end -->


# Overview

A CRAN is nothing but compressed versions of package files (in `tar.gz` or `zip` format) in a certain folder structure and with a few metadata files.

The *cranitor* package helps to organize a CRAN from creating it in the first place to updating it with new packages.
The goal is to have a CRAN that works with the built-in `install.packages` and `install_version` from the [remotes package](https://github.com/r-lib/remotes).

Note that in order to make CRAN accessible it should be served over HTTP. 
The *cranitor* package does not provide hosting -- this should be done using other tools.
If you want to try out *cranitor* , the tests show how to use the [servr package](https://github.com/yihui/servr) to perform the hosting.

My usecase for *cranitor* is to maintain a CRAN for internally developed packages. 
As part of our continuous integration pipelines new versions of a package are first compressed/compiled and then imported into our CRAN using *cranitor*.


# Installation

*cranitor* is currently only available on GitHub and can be installed using e.g. the remotes package:

```
remotes::install_github("robertdj/cranitor")
```

I have no experience trying to publish a package to CRAN, but let me know if I should try :-)


# Usage

A demo CRAN can be made that import a few "empty packages":

```
library(cranitor)
make_demo_cran("path/to/cran")
```

An R package can be compressed into a `tar.gz` file using `R CMD build` from the command line or the [devtools package](https://github.com/r-lib/devtools) inside the corresponding project:

```
targz_file <- devtools::build()
```

The created `tar.gz` file can be imported into a CRAN:

```
update_cran("path/to/cran", targz_file)
```

A third, optional argument is a `zip` file with a *binary* version of the package made with `devtools::build(binary = TRUE)`. This is very handy if you use Windows -- especially if the package contains compiled code.

The `update_cran` function archives old versions of the package and updates the metadata.

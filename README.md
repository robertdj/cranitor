cranitor
========

<!-- badges: start -->
[![R build status](https://github.com/robertdj/cranitor/workflows/R-CMD-check/badge.svg)](https://github.com/robertdj/cranitor/actions)
<!-- badges: end -->


# Overview

A CRAN is nothing but compressed versions of package files (in `tar.gz` or `zip` format) in a certain folder structure and with a few metadata files.

The {cranitor} package helps to organize a CRAN from creating it in the first place to updating it with new packages.
The goal is to have a CRAN that works with the built-in `install.packages` and `install_version` from the [remotes package](https://github.com/r-lib/remotes).

Note that in order to make CRAN accessible it should be served over HTTP. 
The {cranitor} package does not provide hosting -- this should be done using other tools.
If you want to try out {cranitor}, the tests show how to use the [servr package](https://github.com/yihui/servr) to perform the hosting.

My usecase for {cranitor} is to maintain a CRAN for internally developed packages. 
As part of our continuous integration pipelines new versions of a package are first compressed/compiled and then imported into our CRAN using {cranitor}.


# Installation

{cranitor} is currently only available on GitHub and can be installed using e.g. the remotes package:

```
remotes::install_github("robertdj/cranitor")
```

I have no experience trying to publish a package to CRAN, but let me know if I should try :-)


# Usage

To create/update a local CRAN with a new package file the `update_cran` function is available:

```
cranitor::update_cran(package_file, cran_root)
```

The `package_file` can be `tar.gz` file (with the source of a package) or a `zip` file (a binary version of package suitable for Windows).
{cranitor} figures out where the `package_file` should go in the CRAN and updates metadata.

A demo CRAN can be made that create and import a few "empty packages":

```
cran_root <- cranitor::make_demo_cran()
```

The empty packages are created with `create_empty_package`.

Alternatively, a vector of filenames with paths to package files can be supplied to `make_demo_cran`.
Package files can be made from a project with `devtools::build` or downloaded from another CRAN.

If a CRAN is a mess (I have typically seen unwanted files scattered in different folders), the function `clean_cran` can help out by deleting unexpected files.


# Binary Linux packages

As of version 0.3.0 {cranitor} supports binary Linux packages -- that is, R packages that does not require compilation on the user's computer.
The approach is inspired by (the demo videos I have seen of) [RStudio's Package Manager](https://rstudio.com/products/package-manager), where each Linux distribution and version of R has a dedicated folder with binary packages.

The format of a binary Linux package is still `tar.gz` like for source packages.
It is *not* possible to infer which Linux distribution compiled the package, since all Linux distributions are collectively referred to as "unix" in the metadata.
Therefore, the `update_cran` function needs a `distro` argument for binary Linux packages.


# CRAN Content

With R 4.0.x on Windows the content of `cran_root` looks like this:

```
> cran_root <- cranitor::make_demo_cran(cran_root = fs::path_temp("cran"), binary = TRUE)
> fs::dir_tree(cran_root)
+-- bin
|   \-- windows
|       \-- contrib
|           \-- 4.0
|               +-- bar_0.0.1.zip
|               +-- foo_0.0.2.zip
|               +-- PACKAGES
|               +-- PACKAGES.gz
|               \-- PACKAGES.rds
\-- src
    \-- contrib
        +-- Archive
        |   \-- foo
        |       \-- foo_0.0.1.tar.gz
        +-- bar_0.0.1.tar.gz
        +-- foo_0.0.2.tar.gz
        +-- Meta
        |   \-- archive.rds
        +-- PACKAGES
        +-- PACKAGES.gz
        \-- PACKAGES.rds
```

With R 4.0.2 on Ubuntu 20.04 the content of `cran_root` looks like this (the value of the `distro` argument is an example):

```
> cran_root <- cranitor::make_demo_cran(cran_root = fs::path_temp("cran"), binary = TRUE, distro = "ubuntu/focal")
> fs::dir_tree(cran_root)
├── __linux__
│   └── ubuntu
│       └── focal
│           └── 4.0.2
│               └── src
│                   └── contrib
│                       ├── PACKAGES
│                       ├── PACKAGES.gz
│                       ├── PACKAGES.rds
│                       ├── bar_0.0.1.tar.gz
│                       └── foo_0.0.2.tar.gz
└── src
    └── contrib
        ├── Archive
        │   └── foo
        │       └── foo_0.0.1.tar.gz
        ├── Meta
        │   └── archive.rds
        ├── PACKAGES
        ├── PACKAGES.gz
        ├── PACKAGES.rds
        ├── bar_0.0.1.tar.gz
        └── foo_0.0.2.tar.gz
```

In this example the URL for the binary Linux packages should be `<CRAN URL>/__linux__/ubuntu/focal/4.0.2`.
When packages are downloaded to **the same Linux distribution** R figures out that the packages are already compiled.

When making a binary package on Linux the filename typically includes information about the architecture, such as `foo_0.0.1_R_x86_64-pc-linux-gnu.tar.gz`.
However, R on Linux expects package names to be of the form `<name>_<version>.tar.gz`, so everything else is stripped when importing the package.


# macOS

Unfortunately, I don't have access to a contemporary Mac, making it very difficult to debug on this platform.
As a consequence, there is no support for `tgz` files (a binary version suitable for macOS).


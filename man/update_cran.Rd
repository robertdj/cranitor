% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/update.R
\name{update_cran}
\alias{update_cran}
\title{Update local CRAN with the package}
\usage{
update_cran(package_file, cran_root, distro = "ubuntu/focal")
}
\arguments{
\item{package_file}{The location of the package file in either \code{tar.gz} format (source/Linux),
\code{zip} (Windows) or \code{tgz} (Mac).}

\item{cran_root}{The folder containing the CRAN.}

\item{distro}{Only relevant for \strong{binary} Linux packages. The name of the Linux distribution
compiling the package. The only restriction is that it should fit in a URL. As an example,
\code{ubuntu/focal} is a permitted name.}
}
\description{
Import package files into a local CRAN and update the metadata. Check the README in the repo.
}

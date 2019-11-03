#' Get the R version
#'
#' Get the R version as `<major>.<minor>`.
r_version <- function() {
    paste(R.version$major, sub("\\..*$", "", R.version$minor), sep = ".")
}


#' The path of the source package folder
#'
#' @inheritParams update_cran
source_package_dir <- function(cran_root) {
    file.path(cran_root, "src", "contrib")
}


#' The path of the Windows package folder
#'
#' @inheritParams update_cran
win_package_dir <- function(cran_root) {
    file.path(cran_root, "bin", "windows", "contrib", r_version())
}


#' The path of the archive metadata
#'
#' @inheritParams update_cran
#'
#' @return The path of `archive.rds` relative to `cran_root`
archive_metadata_path <- function(cran_root) {
    file.path(source_package_dir(cran_root), "Meta", "archive.rds")
}


#' The path of the Archive folder
#'
#' @inheritParams update_cran
#'
#' @return The path of the `Archive` folder relative to `cran_root`
archive_path <- function(cran_root) {
    file.path(source_package_dir(cran_root), "Archive")
}

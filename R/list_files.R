# List files ----------------------------------------------------------------------------------

#' List packages
#'
#' List `tar.gz` or `zip` archives of a package sorted according to modification time with newest
#' first.
#'
#' @param package_root The folder with the `tar.gz`/`zip` files.
#' @param package_name Name of the package.
#'
#' @return A vector with file names.
list_package_files <- function(package_root, package_name) {
    package_file_pattern <- paste0("^", package_name, "_([[:digit:]]{1,4}\\.[[:digit:]]{1,2}\\.[[:digit:]]{1,})\\.(tar\\.gz|zip)$")

    unsorted_files <- list.files(package_root, package_file_pattern, full.names = TRUE)

    version_numbers <- sub(package_file_pattern, "\\1", basename(unsorted_files)) %>%
        package_version()

    unsorted_files[order(version_numbers, decreasing = TRUE)]
}


#' @inheritParams update_cran
source_package_files <- function(cran_root, package_name) {
    list_package_files(source_package_dir(cran_root), package_name)
}


#' @inheritParams update_cran
windows_package_files <- function(cran_root, package_name) {
    list_package_files(win_package_dir(cran_root), package_name)
}


#' Files in archive
#'
#' List the files in the `Archive` folder of a local CRAN *sans* the folder.
#'
#' @inheritParams update_cran
archive_package_files <- function(cran_root) {
    fs::dir_ls(archive_path(cran_root), recurse = 1, fail = FALSE, glob = "*.tar.gz")
}


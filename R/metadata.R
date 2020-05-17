#' List the archived packages
#'
#' List the archived packages' metadata in the form expected for a CRAN.
#'
#' @inheritParams update_cran
formatted_archive_metadata <- function(cran_root) {
    archived_package_paths <- archive_package_files(cran_root)
    archived_package_filenames <- basename(archived_package_paths)

    package_names <- package_name_from_filename(archived_package_filenames)

    split(package_metadata(archived_package_paths), package_names)
}


#' Get package metadata
#'
#' Get the metadata of a package from its `tar.gz` source file.
#'
#' @param package_files A vector of strings with locations of `tar.gz` source files.
#'
#' @return A `data.frame` with columns `size`, `isdir`, `mode`, `mtime`, `ctime`, `atime`, `uid`,
#' `gid`, `uname` and `grname`. This is file [file.info()] for the package file.
package_metadata <- function(package_files) {
    metadata <- file.info(fs::path(package_files))
    package_basename <- basename(package_files)
    rownames(metadata) <- fs::path(package_name_from_filename(package_basename), package_basename)

    return(metadata)
}

#' Archive outdated versions of a package
#'
#' {cranitor} only retains the most recent version of a binary package; older versions are deleted.
#' If there are multiple elements in `package_files` all but the most recent are deleted.
#'
#' @param package_files A vector with filenames.
archive_single_binary_package <- function(package_files) {
    package_name <- unique(package_name_from_filename(package_files))
    assertthat::assert_that(
        assertthat::is.string(package_name)
    )

    if (length(package_files) <= 1)
        return(invisible(NULL))

    sorted_packages <- sort_files_by_version(package_files)

    fs::file_delete(sorted_packages[-1])
}

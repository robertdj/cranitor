#' Build package files and import to CRAN
#'
#' Update DESCRIPTION, build package files for CRAN and import them.
#'
#' @inheritParams update_cran
#' @param ... Input for [devtools::build()] besides `binary`
#'
#' @export
build_update_cran <- function(cran_root, ...) {
    targz_file <- devtools::build(binary = FALSE, ...)
    zip_file <- devtools::build(binary = TRUE, ...)

    update_cran(cran_root, targz_file, zip_file)
}


#' Update local CRAN with the package
#'
#' Import package files into a local CRAN and update the metadata. Check the README in the repo.
#'
#' @param cran_root The folder containing the CRAN.
#' @param targz_file The location of the `tar.gz` file for source.
#' @param zip_file The location of the `zip` file for Windows.
#'
#' @export
update_cran <- function(cran_root, targz_file, zip_file = NULL) {
    update_cran_source(cran_root, targz_file)
    update_cran_source(cran_root, zip_file)
}


update_cran_source <- function(cran_root, targz_file) {
    import_source_package(cran_root, targz_file)

    archive_package(cran_root, basename_from_targz(targz_file))

    if (isTRUE(file.exists(archive_metadata_path(cran_root))))
        make_archive_metadata(cran_root)

    tools::write_PACKAGES(source_package_dir(cran_root), type = "source")

}


update_cran_win <- function(cran_root, zip_file) {
    import_win_package(cran_root, zip_file)

    # TODO: basename_from_targz is not a good name
    archive_windows_package(cran_root, basename_from_targz(zip_file))

    tools::write_PACKAGES(win_package_dir(cran_root), type = "win.binary")

}

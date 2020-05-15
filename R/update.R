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


get_package_desc <- function(package_file) {
    package_name <- package_name_from_filename(basename(package_file))

    if (package_ext(package_file) == "zip") {
        extractor <- unzip
    } else {
        extractor <- untar
    }


    tmp_dir <- fs::path_temp(package_name)
    # Move to separate function and use defer_parent
    withr::defer(fs::dir_delete(tmp_dir))

    files_in_tar <- extractor(package_file, list = TRUE)
    # unzip returns a dataframe. untar returns a vector
    if (is.data.frame(files_in_tar))
        files_in_tar <- files_in_tar$Name

    desc_location <- fs::path(package_name, "DESCRIPTION")
    desc_exists_in_tar <- any(desc_location == files_in_tar)

    if (isFALSE(desc_exists_in_tar))
        stop("DESCRIPTION is not in expected location in package file")

    extractor(package_file, files = desc_location, exdir = tmp_dir)

    desc_file <- fs::path(tmp_dir, desc_location)


    desc <- tryCatch(read.dcf(desc_file), error = identity)

    if ((inherits(desc, "error")) || (length(desc) == 0))
        stop("Malformed DESCRIPTION in ", package_file)

    return(desc)
}


update_cran_win <- function(cran_root, zip_file) {
    print("win")
    desc <- get_package_desc(zip_file)
    meta <- get_package_meta(zip_file)

    import_win_package(cran_root, zip_file)

    # TODO: basename_from_targz is not a good name
    archive_windows_package(cran_root, basename_from_targz(zip_file))

    tools::write_PACKAGES(win_package_dir(cran_root), type = "win.binary")
}

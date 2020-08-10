#' Update local CRAN with the package
#'
#' Import package files into a local CRAN and update the metadata. Check the README in the repo.
#'
#' @param cran_root The folder containing the CRAN.
#' @param package_file The location of the package file in either `tar.gz` format (source), `zip`
#' (Windows) or `tgz` (Mac).
#'
#' @export
update_cran <- function(cran_root, package_file) {
    switch(
        package_ext(package_file),
        "tar.gz" = update_cran_source(cran_root, package_file),
        "zip"    = update_cran_win(cran_root, package_file)
        # "tgz"    = update_cran_mac(cran_root, package_file)
    )
}



get_package_desc <- function(archive) {
    package_name <- package_name_from_filename(basename(archive))

    desc_file <- get_file_in_archive(archive, fs::path(package_name, "DESCRIPTION"))

    desc <- tryCatch(read.dcf(desc_file), error = identity)

    if ((inherits(desc, "error")) || (length(desc) == 0))
        stop("Malformed DESCRIPTION in ", archive)

    return(desc[1L, ])
}


get_package_meta <- function(archive) {
    package_name <- package_name_from_filename(basename(archive))

    meta_file <- get_file_in_archive(archive, fs::path(package_name, "Meta", "package.rds"))

    meta <- tryCatch(readRDS(meta_file), error = identity)

    if (inherits(meta, "error"))
        stop("Malformed package meta data in ", archive)

    return(meta)
}


get_file_in_archive <- function(archive, package_file) {
    if (package_ext(archive) == "zip") {
        extractor <- utils::unzip
    } else if (package_ext(archive) %in% c("tgz", "tar.gz")) {
        extractor <- utils::untar
    } else {
        rlang::abort("Unknown archive extension")
    }

    tmp_dir <- fs::path_temp(package_file)
    withr::defer_parent(fs::dir_delete(tmp_dir))

    # TODO: Consider just extracting the file in a tryCatch
    files_in_archive <- extractor(archive, list = TRUE)
    if (package_ext(archive) == "zip")
        files_in_archive <- files_in_archive$Name

    if (!(package_file %in% files_in_archive))
        stop(package_file, " does not exist in ", archive)

    extractor(archive, files = package_file, exdir = tmp_dir)

    fs::path(tmp_dir, package_file)
}


package_name_from_filename <- function(package_file) {
    # TODO: Make sure that we work on basename(package_file)
    package_file_sans_path <- basename(package_file)
    substr(package_file_sans_path, 1, regexpr("_", package_file_sans_path) - 1)
}

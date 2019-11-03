#' Save archive metadata
#'
#' Save archive metadata to `src/contrib/Meta/archive.rds`.
#'
#' @inheritParams update_cran
make_archive_metadata <- function(cran_root) {
    archive_metadata <- formatted_archive_metadata(cran_root)

    metadata_dir <- dirname(archive_metadata_path(cran_root))
    if (isFALSE(fs::dir_exists(metadata_dir)))
        fs::dir_create(metadata_dir)

    saveRDS(archive_metadata, archive_metadata_path(cran_root))
}


#' Archive package in CRAN
#'
#' If there are multiple `tar.gz`/`zip` files for the same package, all but the one with the highest
#' version are moved/deleted.
#'
#' @inheritParams update_cran
#' @param package_name The name of the package **without** the version & file extension.
#'
archive_package <- function(cran_root, package_name) {
    source_files <- source_package_files(cran_root, package_name)
    if (length(source_files) > 1) {
        archive_source_package(cran_root, source_files[-1])
    } else {
        message("No source packages archived")
    }

    # TODO: Make sure that the source and bin have the same version

    bin_files <- windows_package_files(cran_root, package_name)
    if (length(bin_files) > 1) {
        archive_windows_package(cran_root, bin_files[-1])
    } else {
        message("No binary packages archived/deleted")
    }
}


#' Archive source package
#'
#' Move `tar.gz` files with source code to the correct location in the CRAN.
#'
#' @inheritParams update_cran
#' @param source_files The `tar.gz` filenames with source code *sans* path.
archive_source_package <- function(cran_root, source_files) {
    # TODO: Make sure all source_files belong to the same package
    package_name <- basename_from_targz(source_files[1])
    # TODO: Check if file already exists in Archive?
    source_archive <- file.path(archive_path(cran_root), package_name)
    if (isFALSE(fs::dir_exists(source_archive)))
        fs::dir_create(source_archive, recurse = TRUE)

    fs::file_move(source_files, source_archive)
}


#' Archive Windows package
#'
#' Move `zip` files with compiled source code to the correct location in the CRAN.
#'
#' @inheritParams update_cran
#' @param bin_files The `zip` files with compiled code.
archive_windows_package <- function(cran_root, bin_files) {
    # TODO: Only keep the latest
    fs::file_delete(bin_files)
}


#' Extract package name
#'
#' A packed source code file is of the form `<package name>_<version>.tar.gz`. This function
#' returns `<package name>` from such a file name.
#'
#' @param targz A vector of filenames.
#'
#' @return A vector of package names.
basename_from_targz <- function(targz) {
    vapply(strsplit(basename(targz), "_"), `[[`, character(1), 1)
}

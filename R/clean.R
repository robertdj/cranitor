#' Clean a CRAN
#'
#' Clean a CRAN by archiving as needed for each platform and removing unncessary flies.
#'
#' @inheritParams update_cran
#'
#' @export
clean_cran <- function(cran_root) {
    clean_cran_source(cran_root)
    clean_cran_win(cran_root)
    clean_cran_mac(cran_root)
}


clean_cran_source <- function(cran_root) {
    if (isFALSE(fs::dir_exists(source_package_dir(cran_root))))
        message("No source packages in ", cran_root)

    source_packages <- fs::dir_ls(source_package_dir(cran_root), type = "file", glob = "*.tar.gz")
    all_files_in_source_dir <- fs::dir_ls(source_package_dir(cran_root), type = "file", regexp = "^PACKAGES*", invert = TRUE)

    non_targz_files <- setdiff(all_files_in_source_dir, source_packages)
    # TODO: Option to list files instead of deleting?
    if (length(non_targz_files) > 0)
        fs::file_delete(non_targz_files)

    # TODO: Should baesname be here or in function?
    # TODO: Move archiving to new function
    package_names <- package_name_from_filename(basename(source_packages))
    packages_by_name <- split(source_packages, package_names)

    for (package_files in packages_by_name) {
        archive_source_single_package(cran_root, package_files)
    }

    update_meta(cran_root)

    tools::write_PACKAGES(source_package_dir(cran_root), type = "source")
}


update_meta <- function(cran_root) {
    archive_metadata <- formatted_archive_metadata(cran_root)

    if (length(archive_metadata) == 0)
        return(invisible(NULL))

    metadata_dir <- dirname(archive_metadata_path(cran_root))
    if (isFALSE(fs::dir_exists(metadata_dir)))
        fs::dir_create(metadata_dir)

    saveRDS(archive_metadata, archive_metadata_path(cran_root))
}


archive_source_single_package <- function(cran_root, package_files) {
    package_name <- unique(package_name_from_filename(package_files))
    assertthat::assert_that(
        # assertthat::is.dir(package_files),
        assertthat::is.string(package_name)
    )

    if (length(package_files) <= 1)
        return(invisible(NULL))

    sorted_packages <- sort_files_by_version(package_files)

    source_archive <- fs::path(archive_path(cran_root), package_name)
    if (isFALSE(fs::dir_exists(source_archive)))
        fs::dir_create(source_archive)

    fs::file_move(sorted_packages[-1], source_archive)
}


sort_files_by_version <- function(package_files) {
    # TODO: This is also tested in archive_source_single_package
    filenames_sans_path <- basename(package_files)
    package_name <- unique(package_name_from_filename(filenames_sans_path))

    if (length(package_name) != 1)
        stop("sort_files_by_version: Only archives of a single package allowed")

    package_file_pattern <- paste0(
        "^", package_name,
        "_(([[:digit:]]{1,}\\.){3,4})(tar\\.gz|tgz|zip)$"
    )

    version_numbers_plus_dot <- sub(package_file_pattern, "\\1", filenames_sans_path)
    version_numbers_as_strings <- substr(
        version_numbers_plus_dot, 1, nchar(version_numbers_plus_dot) - 1
    )
    version_numbers <- package_version(version_numbers_as_strings)

    package_files[order(version_numbers, decreasing = TRUE)]
}



clean_cran_win <- function(cran_root) {
    if (isFALSE(fs::dir_exists(win_package_dir(cran_root))))
        message("No Windows packages in ", cran_root)
}


clean_cran_mac <- function(cran_root) {
    if (isFALSE(fs::dir_exists(mac_package_dir(cran_root))))
        message("No source packages in ", cran_root)
}

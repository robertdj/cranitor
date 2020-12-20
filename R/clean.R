#' Clean a CRAN
#'
#' Clean a CRAN by archiving as needed for each platform and removing unnecessary files.
#'
#' @inheritParams update_cran
#' @param list `[logical]` List unnecessary files or delete them.
#'
#' @export
clean_cran <- function(cran_root, list = FALSE) {
    assertthat::assert_that(assertthat::is.flag(list))

    clean_cran_source(cran_root, list = list)
    clean_cran_win(cran_root, list = list)
    # clean_cran_mac(cran_root)
}


clean_cran_source <- function(cran_root, list = FALSE) {
    assertthat::assert_that(assertthat::is.flag(list))

    if (isFALSE(fs::dir_exists(source_package_dir(cran_root))))
        return(invisible(NULL))

    source_packages <- fs::dir_ls(
        source_package_dir(cran_root), recurse = TRUE, type = "file", glob = "*.tar.gz"
    )
    meta_files <- fs::path(
        source_package_dir(cran_root),
        c("PACKAGES", "PACKAGES.rds", "PACKAGES.gz", "Meta/archive.rds")
    )
    all_files_in_source_dir <- fs::dir_ls(
        source_package_dir(cran_root), recurse = TRUE, type = "file"
    )

    unwanted_files <- setdiff(all_files_in_source_dir, c(source_packages, meta_files))
    if (length(unwanted_files) > 0) {
        if (isTRUE(list))
            return(unwanted_files)

        fs::file_delete(unwanted_files)
    }

    # TODO: Move archiving to new function
    package_names <- package_name_from_filename(source_packages)
    packages_by_name <- split(source_packages, package_names)

    purrr::walk(packages_by_name, archive_single_source_package, cran_root = cran_root)

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


archive_single_source_package <- function(package_files, cran_root) {
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
        "_(([[:digit:]]{1,}[[:punct:]]){3,4}).*(tar\\.gz|tgz|zip)$"
    )

    version_numbers_plus_dot <- sub(package_file_pattern, "\\1", filenames_sans_path)
    version_numbers_as_strings <- substr(
        version_numbers_plus_dot, 1, nchar(version_numbers_plus_dot) - 1
    )
    version_numbers <- package_version(version_numbers_as_strings)

    package_files[order(version_numbers, decreasing = TRUE)]
}


clean_cran_win <- function(cran_root, list = FALSE) {
    assertthat::assert_that(assertthat::is.flag(list))

    win_versions <- list_win_package_dirs(cran_root)
    purrr::walk(win_versions, clean_cran_win_single_version, cran_root = cran_root, list = list)
}


clean_cran_win_single_version <- function(r_version, cran_root, list = FALSE) {
    assertthat::assert_that(assertthat::is.flag(list))

    if (isFALSE(fs::dir_exists(win_package_dir(r_version, cran_root))))
        message("No Windows packages for R version", r_version, " in ", cran_root)

    win_packages <- fs::dir_ls(win_package_dir(r_version, cran_root), type = "file", glob = "*.zip")
    all_files_in_win_dir <- fs::dir_ls(
        win_package_dir(r_version, cran_root), type = "file", regexp = "^PACKAGES*", invert = TRUE
    )

    non_zip_files <- setdiff(all_files_in_win_dir, win_packages)
    if (length(non_zip_files) > 0) {
        if (isTRUE(list))
            return(non_zip_files)

        fs::file_delete(non_zip_files)
    }

    # TODO: Move archiving to new function
    package_names <- package_name_from_filename(win_packages)
    packages_by_name <- split(win_packages, package_names)

    purrr::walk(packages_by_name, archive_single_win_package, cran_root = cran_root)

    tools::write_PACKAGES(win_package_dir(r_version, cran_root), type = "win.binary")
}


archive_single_win_package <- function(package_files, cran_root) {
    package_name <- unique(package_name_from_filename(package_files))
    assertthat::assert_that(
        assertthat::is.string(package_name)
    )

    if (length(package_files) <= 1)
        return(invisible(NULL))

    sorted_packages <- sort_files_by_version(package_files)

    fs::file_delete(sorted_packages[-1])
}


clean_cran_mac <- function(cran_root) {
    if (isFALSE(fs::dir_exists(mac_package_dir(cran_root))))
        message("No source packages in ", cran_root)
}


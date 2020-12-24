update_cran_win <- function(zip_file, cran_root) {
    import_win_package(zip_file, cran_root)

    archive_win_packages(cran_root)

    r_version <- pkg.peek::get_r_version(zip_file)
    tools::write_PACKAGES(win_package_dir(r_version, cran_root), type = "win.binary")
}


import_win_package <- function(zip_file, cran_root) {
    assertthat::assert_that(
        assertthat::is.string(cran_root),
        fs::is_file(zip_file),
        assertthat::has_extension(zip_file, "zip"),
        pkg.peek::is_package_built(zip_file)
    )

    meta <- pkg.peek::get_package_meta(zip_file)
    if (tolower(meta$Built$OStype) != "windows")
        stop(zip_file, " not built on Windows")

    r_version <- pkg.peek::get_r_version(zip_file)
    win_dir <- win_package_dir(r_version, cran_root)
    if (isFALSE(fs::dir_exists(win_dir)))
        fs::dir_create(win_dir)

    fs::file_copy(zip_file, win_dir)
}


archive_win_packages <- function(r_version, cran_root, list = FALSE) {
    win_packages <- fs::dir_ls(win_package_dir(r_version, cran_root), type = "file", glob = "*.zip")

    package_names <- package_name_from_filename(win_packages)
    packages_by_name <- split(win_packages, package_names)

    purrr::walk(packages_by_name, archive_single_win_package, cran_root = cran_root)
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

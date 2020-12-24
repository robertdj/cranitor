update_cran_win <- function(zip_file, cran_root) {
    assertthat::assert_that(
        assertthat::is.string(cran_root)
    )

    r_version <- pkg.peek::get_r_version(zip_file)
    win_dir <- win_package_dir(r_version, cran_root)

    import_win_package(zip_file, win_dir)

    archive_win_packages(win_dir)

    tools::write_PACKAGES(win_dir, type = "win.binary")
}


import_win_package <- function(zip_file, win_dir) {
    assertthat::assert_that(
        fs::is_file(zip_file),
        assertthat::has_extension(zip_file, "zip"),
        pkg.peek::is_package_built(zip_file),
        is_valid_windows_dir(win_dir)
    )

    meta <- pkg.peek::get_package_meta(zip_file)
    if (tolower(meta$Built$OStype) != "windows")
        stop(zip_file, " not built on Windows")

    if (isFALSE(fs::dir_exists(win_dir)))
        fs::dir_create(win_dir)

    fs::file_copy(zip_file, win_dir)
}


archive_win_packages <- function(win_dir) {
    win_packages <- fs::dir_ls(win_package_dir(r_version, cran_root), type = "file", glob = "*.zip")

    package_names <- package_name_from_filename(win_packages)
    packages_by_name <- split(win_packages, package_names)

    purrr::walk(packages_by_name, archive_single_binary_package, cran_root = cran_root)
}

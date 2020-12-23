update_cran_win <- function(zip_file, cran_root) {
    import_win_package(zip_file, cran_root)

    clean_cran_win(cran_root)

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


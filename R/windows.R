update_cran_win <- function(zip_file, cran_root) {
    assertthat::assert_that(
        assertthat::is.string(cran_root),
        assertthat::is.string(zip_file),
        package_ext(zip_file) == "zip"
    )

    meta <- get_package_meta(zip_file)

    if (tolower(meta$Built$OStype) != "windows")
        stop(zip_file, " not built on Windows")

    r_version_used_in_build <- meta$Built$R
    import_win_package(zip_file, r_version_used_in_build, cran_root)

    clean_cran_win(cran_root)

    tools::write_PACKAGES(win_package_dir(r_version_used_in_build, cran_root), type = "win.binary")
}


import_win_package <- function(package, r_version, cran_root) {
    assertthat::assert_that(
        assertthat::has_extension(package, "zip")
    )

    # TODO: Don't check
    if (isFALSE(fs::dir_exists(win_package_dir(cran_root, cran_root))))
        fs::dir_create(win_package_dir(r_version, cran_root))

    # TODO: copy or move?
    fs::file_copy(package, win_package_dir(r_version, cran_root))
}


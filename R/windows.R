update_cran_win <- function(cran_root, zip_file) {
    assertthat::assert_that(
        assertthat::is.string(cran_root),
        assertthat::is.string(zip_file),
        package_ext(zip_file) == "zip"
    )

    desc <- get_package_desc(zip_file)
    is_source_package <- is.na(desc["Built"])

    if (isTRUE(is_source_package)) {
        stop(zip_file, " is a source package")
        return(invisible(NULL))
    }

    meta <- get_package_meta(zip_file)

    if (tolower(meta$Built$OStype) != "windows")
        stop(zip_file, " not built on Windows")

    r_version_used_in_build <- meta$Built$R
    import_win_package(cran_root, zip_file, r_version_used_in_build)

    clean_cran_win(cran_root, r_version_used_in_build)

    tools::write_PACKAGES(win_package_dir(cran_root, r_version_used_in_build), type = "win.binary")
}


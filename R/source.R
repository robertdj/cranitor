update_cran_source <- function(cran_root, targz_file) {
    assertthat::assert_that(
        assertthat::is.string(cran_root),
        assertthat::is.string(targz_file),
        package_ext(targz_file) == "tar.gz"
    )

    desc <- get_package_desc(targz_file)
    is_source_package <- is.na(desc["Built"])

    if (isFALSE(is_source_package)) {
        warning("Linux binary packages are not supported")
        return(NULL)
    }

    import_source_package(cran_root, targz_file)

    clean_cran_source(cran_root)

    tools::write_PACKAGES(source_package_dir(cran_root), type = "source")
}


import_source_package <- function(cran_root, targz_file) {
    assertthat::assert_that(
        package_ext(targz_file) == "tar.gz"
    )

    if (isFALSE(fs::dir_exists(source_package_dir(cran_root))))
        fs::dir_create(source_package_dir(cran_root))

    # TODO: copy or move?
    fs::file_copy(targz_file, source_package_dir(cran_root))
}

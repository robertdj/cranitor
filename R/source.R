update_cran_source <- function(targz_file, cran_root) {
    assertthat::assert_that(
        assertthat::is.string(cran_root),
        fs::is_file(targz_file),
        package_ext(targz_file) == "tar.gz"
    )

    desc <- get_package_desc(targz_file)
    is_source_package <- is.na(desc["Built"])

    if (isFALSE(is_source_package)) {
        warning("Binary Linux packages are not supported")
        return(NULL)
    }

    import_source_package(targz_file, cran_root)

    clean_cran_source(cran_root)

    tools::write_PACKAGES(source_package_dir(cran_root), type = "source")
}


import_source_package <- function(targz_file, cran_root) {
    assertthat::assert_that(
        fs::is_file(targz_file),
        package_ext(targz_file) == "tar.gz"
    )

    # TODO: Don't check
    if (isFALSE(fs::dir_exists(source_package_dir(cran_root))))
        fs::dir_create(source_package_dir(cran_root))

    # TODO: copy or move?
    fs::file_copy(targz_file, source_package_dir(cran_root))
}

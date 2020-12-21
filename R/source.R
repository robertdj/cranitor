update_cran_source <- function(targz_file, cran_root) {
    assertthat::assert_that(
        assertthat::is.string(cran_root),
        fs::is_file(targz_file),
        package_ext(targz_file) == "tar.gz",
        !pkg.peek::is_package_built(targz_file)
    )

    import_source_package(targz_file, cran_root)

    clean_cran_source(cran_root)

    tools::write_PACKAGES(source_package_dir(cran_root), type = "source")
}


import_source_package <- function(targz_file, cran_root) {
    assertthat::assert_that(
        fs::is_file(targz_file),
        package_ext(targz_file) == "tar.gz"
    )

    source_dir <- source_package_dir(cran_root)
    if (isFALSE(fs::dir_exists(source_dir)))
        fs::dir_create(source_dir)

    # TODO: copy or move?
    fs::file_copy(targz_file, source_dir)
}

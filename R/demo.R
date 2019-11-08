make_demo_cran <- function(cran_root = NULL) {
    if (is.null(cran_root))
        cran_root <- file.path(tempdir(), "demo_cran")

    if (dir.exists(cran_root)) {
        warning(cran_root, " already exists. It is now replaced.")
        unlink(cran_root, recursive = TRUE)
    }

    make_local_cran(cran_root)

    import_source_package(cran_root, testdata_path("foo_0.0.1.tar.gz"))
    import_source_package(cran_root, testdata_path("foo_0.0.2.tar.gz"))
    import_source_package(cran_root, testdata_path("bar_0.0.1.tar.gz"))

    archive_package(cran_root, "foo")
    archive_package(cran_root, "bar")

    make_archive_metadata(cran_root)

    tools::write_PACKAGES(source_package_dir(cran_root), type = "source")

    return(cran_root)
}

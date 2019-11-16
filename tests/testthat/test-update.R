test_that("PACKAGES metadata files are created", {
    cran_root <- file.path(tempdir(), "cran")
    on.exit(unlink(cran_root, recursive = TRUE), add = TRUE)

    make_local_cran(cran_root)

    # TODO: More messages than expected
    number_of_packages <- update_cran_source(cran_root, testdata_path("foo_0.0.1.tar.gz"))
    expect_equal(number_of_packages, 1L)

    update_cran_source(cran_root, testdata_path("foo_0.0.2.tar.gz"))
})

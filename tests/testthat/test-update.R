test_that("PACKAGES metadata files are created", {
    cran_root <- file.path(tempdir(), "cran")
    on.exit(unlink(cran_root, recursive = TRUE), add = TRUE)

    make_local_cran(cran_root)

    # TODO: More messages than expected
    number_of_packages <- update_cran_source(cran_root, src_package_paths["foo_0.0.1"])
    expect_equal(number_of_packages, 1L)

    update_cran_source(cran_root, src_package_paths["foo_0.0.2"])
})

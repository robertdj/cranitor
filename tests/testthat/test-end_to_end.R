test_that("End-to-end archive update", {
    cran_parent <- tempdir()
    cran_root <- fs::path(cran_parent, "e2e-cran")
    withr::defer(fs::dir_delete(cran_root), envir = environment())

    make_demo_cran(cran_root)

    expect_equal(
        fs::dir_ls(cran_root, recurse = TRUE, type = "file"),
        fs::path(cran_root, c(
            "src/contrib/Archive/foo/foo_0.0.1.tar.gz",
            "src/contrib/Meta/archive.rds",
            "src/contrib/PACKAGES",
            "src/contrib/PACKAGES.gz",
            "src/contrib/PACKAGES.rds",
            "src/contrib/bar_0.0.1.tar.gz",
            "src/contrib/foo_0.0.2.tar.gz"
        ))
    )
})


test_that("Overwrite demo archive", {
    cran_parent <- tempdir()
    cran_root <- fs::path(cran_parent, "e2e-cran")
    withr::defer(fs::dir_delete(cran_root), envir = environment())

    make_demo_cran(cran_root)

    expect_true(fs::file_exists(cran_root))
    expect_warning(make_demo_cran(cran_root), "e2e-cran already exists. It is now replaced")
})

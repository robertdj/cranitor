test_that("End-to-end archive update", {
    cran_parent <- tempdir()
    cran_root <- file.path(cran_parent, "e2e-cran")
    on.exit(unlink(cran_root, recursive = TRUE), add = TRUE)

    make_demo_cran(cran_root)

    # The sorting is different in devtools::test() and devtools::check()
    expect_equal(
        sort(dir(cran_root, recursive = TRUE)),
        sort(c(
            "src/contrib/Archive/foo/foo_0.0.1.tar.gz",
            "src/contrib/bar_0.0.1.tar.gz",
            "src/contrib/foo_0.0.2.tar.gz",
            "src/contrib/Meta/archive.rds",
            "src/contrib/PACKAGES",
            "src/contrib/PACKAGES.gz",
            "src/contrib/PACKAGES.rds"
        ))
    )
})


test_that("Overwrite demo archive", {
    cran_parent <- tempdir()
    cran_root <- file.path(cran_parent, "e2e-cran")
    on.exit(unlink(cran_root, recursive = TRUE), add = TRUE)

    make_demo_cran(cran_root)

    expect_true(file.exists(cran_root))
    expect_warning(make_demo_cran(cran_root), "e2e-cran already exists. It is now replaced")
})

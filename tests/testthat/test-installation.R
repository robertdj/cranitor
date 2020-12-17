# Setup ---------------------------------------------------------------------------------------

cran_root <- make_demo_cran(packages = package_paths)

cran_port <- servr::random_port()
cran_url <- paste0("http://localhost:", cran_port)

p <- processx::process$new(
    file.path(Sys.getenv("R_HOME"), "bin", "R"),
    c("-e", paste0("servr::httd(dir = '", cran_root, "', port = ", cran_port, ")")),
    cleanup_tree = TRUE
)

# servr needs a little time to start
Sys.sleep(1)


# Tests ---------------------------------------------------------------------------------------

test_that("List available packages in CRAN", {
    demo_cran_packages <- available.packages(repos = cran_url)

    expect_type(demo_cran_packages, "character")
    expect_equal(ncol(demo_cran_packages), 17)
    expect_equal(nrow(demo_cran_packages), 2)

    expect_equal(rownames(demo_cran_packages), c("bar", "foo"))

    expect_equal(demo_cran_packages[, "Version"], c(bar = "0.0.1", foo = "0.0.2"))
})


test_that("Install source package from hosted CRAN", {
    test_library <- make_test_library()
    withr::defer(fs::dir_delete(test_library))

    test_library_packages <- installed.packages(lib.loc = test_library)
    expect_equal(nrow(test_library_packages), 0)

    install.packages(
        "foo", lib = test_library, repos = cran_url, type = "source", quiet = TRUE
    )

    test_library_packages <- installed.packages(lib.loc = test_library)
    expect_equal(rownames(test_library_packages), c(Package = "foo"))
    expect_equal(test_library_packages[, "Package"], "foo")
    expect_equal(test_library_packages[, "Version"], "0.0.2")
})


test_that("Install archived versions of package from hosted CRAN", {
    test_library <- make_test_library()
    withr::defer(fs::dir_delete(test_library))

    remotes::install_version(
        "foo", version = "0.0.1", lib = test_library, repos = cran_url, quiet = TRUE
    )

    test_library_packages <- installed.packages(lib.loc = test_library)
    expect_equal(test_library_packages[, "Package"], "foo")
    expect_equal(test_library_packages[, "Version"], "0.0.1")
})


test_that("Install binary package from hosted CRAN", {
    skip_on_os(c("linux", "mac", "solaris"))

    test_library <- make_test_library()
    withr::defer(fs::dir_delete(test_library))

    test_library_packages <- installed.packages(lib.loc = test_library)
    expect_equal(nrow(test_library_packages), 0)

    install.packages(
        "foo", lib = test_library, repos = cran_url, type = "binary", quiet = TRUE
    )

    test_library_packages <- installed.packages(lib.loc = test_library)
    expect_equal(rownames(test_library_packages), c(Package = "foo"))
    expect_equal(test_library_packages[, "Package"], "foo")
    expect_equal(test_library_packages[, "Version"], "0.0.2")
})


p$kill()

cran_root <- make_demo_cran()

test_library <- fs::path(tempdir(), "r_test_library")
fs::dir_create(test_library)

cran_port <- servr::random_port()
cran_url <- paste0("http://localhost:", cran_port)

p <- processx::process$new(
    file.path(Sys.getenv("R_HOME"), "bin", "R"),
    c("-e", paste0("servr::httd(dir = '", cran_root, "', port = ", cran_port, ")")),
    cleanup_tree = TRUE
)
# print(p)

# servr needs a little time to start
Sys.sleep(1)


test_that("CRAN lists available packages", {
    demo_cran_packages <- available.packages(repos = cran_url)

    expect_type(demo_cran_packages, "character")
    expect_equal(ncol(demo_cran_packages), 17)
    expect_equal(nrow(demo_cran_packages), 2)

    expect_equal(rownames(demo_cran_packages), c("bar", "foo"))

    expect_equal(demo_cran_packages[, "Version"], c(bar = "0.0.1", foo = "0.0.2"))
})


test_that("Install source package from hosted CRAN", {
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
    remotes::install_version(
        "foo", version = "0.0.1", lib = test_library, repos = cran_url, quiet = TRUE
    )

    test_library_packages <- installed.packages(lib.loc = test_library)
    expect_equal(test_library_packages[, "Package"], "foo")
    expect_equal(test_library_packages[, "Version"], "0.0.1")
})


test_that("Install Windows package from hosted CRAN", {
    skip_on_os(c("linux", "mac", "solaris"))

})


test_that("Install macOS package from hosted CRAN", {
    skip_on_os(c("linux", "solaris", "windows"))

})

p$kill()
# print(p)

unlink(cran_root, recursive = TRUE)
unlink(test_library, recursive = TRUE)

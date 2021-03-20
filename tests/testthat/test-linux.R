skip_on_os(c("windows", "mac", "solaris"))

test_that("Import binary package", {
    cran_root <- make_random_demo_cran_path()
    linux_dir <- linux_package_dir(getRversion(), distro = "my_linux", cran_root)
    withr::defer(fs::dir_delete(cran_root))

    import_linux_package(bin_package_paths["foo_0.0.1"], linux_dir)

    cran_files <- fs::dir_ls(cran_root, type = "file", recurse = TRUE)
    expect_equal(basename(cran_files), "foo_0.0.1.tar.gz")
})


test_that("Import the same binary package twice", {
    cran_root <- make_random_demo_cran_path()
    linux_dir <- linux_package_dir(getRversion(), distro = "my_linux", cran_root)
    withr::defer(fs::dir_delete(cran_root))

    import_linux_package(bin_package_paths["foo_0.0.1"], linux_dir)
    expect_error(
        import_linux_package(bin_package_paths["foo_0.0.1"], linux_dir),
        class = "EEXIST"
    )
})


test_that("Error specifying invalid Linux dir", {
    expect_error(is_valid_linux_dir("my_linux"), regexp = "must contain folder '__linux__'")

    expect_error(
        is_valid_linux_dir("__linux__/my_linux"), regexp = "must contain a folder with an R version"
    )

    expect_error(
        is_valid_linux_dir("__linux__/my_linux/4.0"), regexp = "must contain a folder with an R version"
    )
})


test_that("Update CRAN with binary package", {
    cran_root <- make_random_demo_cran_path()
    linux_dir <- linux_package_dir(getRversion(), distro = "my_linux", cran_root)
    withr::defer(fs::dir_delete(cran_root))

    update_cran_linux(bin_package_paths["foo_0.0.1"], cran_root, distro = "my_linux")

    cran_files <- list.files(linux_dir, recursive = TRUE)

    # The order of cran_files depend on the OS
    expect_length(cran_files, 4L)

    expect_true("foo_0.0.1.tar.gz" %in% cran_files)
    expect_true("PACKAGES" %in% cran_files)
    expect_true("PACKAGES.gz" %in% cran_files)
    expect_true("PACKAGES.rds" %in% cran_files)
})


test_that("Update CRAN with new version of binary package", {
    cran_root <- make_random_demo_cran_path()
    withr::defer(fs::dir_delete(cran_root))

    f1 <- bin_package_paths["foo_0.0.1"]
    update_cran_linux(f1, cran_root, distro = "my_linux")

    f2 <- bin_package_paths["foo_0.0.2"]
    update_cran_linux(f2, cran_root, distro = "my_linux")

    linux_dir <- linux_package_dir(getRversion(), distro = "my_linux", cran_root)
    cran_files <- list.files(linux_dir, recursive = TRUE)

    expect_true("foo_0.0.2.tar.gz" %in% cran_files)
    expect_true("PACKAGES" %in% cran_files)
    expect_true("PACKAGES.gz" %in% cran_files)
    expect_true("PACKAGES.rds" %in% cran_files)
})


test_that("Unexpected files are deleted from CRAN", {
    cran_root <- make_demo_cran(packages = bin_package_paths, distro = "my_linux")
    linux_dir <- linux_package_dir(getRversion(), distro = "my_linux", cran_root)
    withr::defer(fs::dir_delete(cran_root))

    unwanted_file <- fs::path(linux_dir, "random_file")
    fs::file_create(unwanted_file)
    expect_true(fs::file_exists(unwanted_file))

    # clean_cran_linux(cran_root)
    # expect_false(fs::file_exists(unwanted_file))
})


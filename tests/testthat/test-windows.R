skip_on_os(c("linux", "mac", "solaris"))


test_that("Import binary package", {
    clean_test_cran(cran_root)

    import_win_package(cran_root, bin_package_paths["foo_0.0.1"], getRversion())

    cran_files <- fs::dir_ls(cran_root, type = "file", recurse = TRUE)
    expect_equal(basename(cran_files), basename(bin_package_paths["foo_0.0.1"]))
})


test_that("Import the same binary package twice", {
    clean_test_cran(cran_root)

    import_win_package(cran_root, bin_package_paths["foo_0.0.1"], getRversion())
    expect_error(
        import_win_package(cran_root, bin_package_paths["foo_0.0.1"], getRversion()),
        class = "EEXIST"
    )
})


test_that("Update CRAN with binary package", {
    clean_test_cran(cran_root)

    update_cran_win(cran_root, bin_package_paths["foo_0.0.1"])

    cran_files <- list.files(win_package_dir(getRversion(), cran_root), recursive = TRUE)

    # The order of cran_files depend on the OS
    expect_length(cran_files, 4L)

    expect_true(basename(bin_package_paths["foo_0.0.1"]) %in% cran_files)
    expect_true("PACKAGES" %in% cran_files)
    expect_true("PACKAGES.gz" %in% cran_files)
    expect_true("PACKAGES.rds" %in% cran_files)
})


test_that("Update CRAN with new version of binary package", {
    clean_test_cran(cran_root)

    f1 <- bin_package_paths["foo_0.0.1"]
    update_cran_win(cran_root, f1)

    f2 <- bin_package_paths["foo_0.0.2"]
    update_cran_win(cran_root, f2)

    cran_files <- list.files(win_package_dir(getRversion(), cran_root), recursive = TRUE)

    expect_true(basename(f2) %in% cran_files)
    expect_true("PACKAGES" %in% cran_files)
    expect_true("PACKAGES.gz" %in% cran_files)
    expect_true("PACKAGES.rds" %in% cran_files)
})


test_that("Unexpected files are deleted from CRAN", {
    cran_root <- make_demo_cran(packages = bin_package_paths)
    withr::defer(fs::dir_delete(cran_root))

    unwanted_file <- fs::path(win_package_dir(cran_root = cran_root), "random_file")
    fs::file_create(unwanted_file)
    expect_true(fs::file_exists(unwanted_file))

    clean_cran_win(cran_root)
    expect_false(fs::file_exists(unwanted_file))
})


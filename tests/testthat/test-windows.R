skip_on_os(c("linux", "mac", "solaris"))


test_that("Import binary package", {
    cran_root <- make_random_demo_cran_path()
    withr::defer(fs::dir_delete(cran_root))

    zip_file <- bin_package_paths["foo_0.0.1"]
    r_version <- pkg.peek::get_r_version(zip_file)
    win_dir <- win_package_dir(r_version, cran_root)

    import_win_package(zip_file, win_dir)

    cran_files <- fs::dir_ls(cran_root, type = "file", recurse = TRUE)
    expect_equal(basename(cran_files), basename(zip_file))
})


test_that("Import the same binary package twice", {
    cran_root <- make_random_demo_cran_path()
    withr::defer(fs::dir_delete(cran_root))

    zip_file <- bin_package_paths["foo_0.0.1"]
    r_version <- pkg.peek::get_r_version(zip_file)
    win_dir <- win_package_dir(r_version, cran_root)

    import_win_package(zip_file, win_dir)
    expect_error(
        import_win_package(zip_file, win_dir),
        class = "EEXIST"
    )
})


test_that("Update CRAN with binary package", {
    cran_root <- make_random_demo_cran_path()
    withr::defer(fs::dir_delete(cran_root))

    zip_file <- bin_package_paths["foo_0.0.1"]
    update_cran_win(zip_file, cran_root)

    cran_files <- list.files(win_package_dir(getRversion(), cran_root), recursive = TRUE)

    # The order of cran_files depend on the OS
    expect_length(cran_files, 4L)

    expect_true(basename(zip_file) %in% cran_files)
    expect_true("PACKAGES" %in% cran_files)
    expect_true("PACKAGES.gz" %in% cran_files)
    expect_true("PACKAGES.rds" %in% cran_files)
})


test_that("Update CRAN with new version of binary package", {
    cran_root <- make_random_demo_cran_path()
    withr::defer(fs::dir_delete(cran_root))

    f1 <- bin_package_paths["foo_0.0.1"]
    update_cran_win(f1, cran_root)

    f2 <- bin_package_paths["foo_0.0.2"]
    update_cran_win(f2, cran_root)

    cran_files <- list.files(win_package_dir(getRversion(), cran_root), recursive = TRUE)

    expect_true(basename(f2) %in% cran_files)
    expect_true("PACKAGES" %in% cran_files)
    expect_true("PACKAGES.gz" %in% cran_files)
    expect_true("PACKAGES.rds" %in% cran_files)
})


test_that("Unexpected files are deleted from CRAN", {
    cran_root <- make_demo_cran(packages = bin_package_paths)
    withr::defer(fs::dir_delete(cran_root))

    unwanted_file <- fs::path(win_package_dir(getRversion(), cran_root), "random_file")
    fs::file_create(unwanted_file)
    expect_true(fs::file_exists(unwanted_file))

    clean_cran_win(cran_root)
    expect_false(fs::file_exists(unwanted_file))
})



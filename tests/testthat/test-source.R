test_that("Import source package", {
    cran_root <- make_random_demo_cran_path()
    withr::defer(fs::dir_delete(cran_root))

    import_source_package(src_package_paths[1], cran_root)

    cran_files <- fs::dir_ls(cran_root, type = "file", recurse = TRUE)
    expect_equal(basename(cran_files), basename(src_package_paths[1]))
})


test_that("Import the same source package twice", {
    cran_root <- make_random_demo_cran_path()
    withr::defer(fs::dir_delete(cran_root))

    import_source_package(src_package_paths[1], cran_root)
    expect_error(
        import_source_package(src_package_paths[1], cran_root),
        class = "EEXIST"
    )
})


test_that("Update CRAN with source package", {
    cran_root <- make_random_demo_cran_path()
    withr::defer(fs::dir_delete(cran_root))

    update_cran_source(src_package_paths[1], cran_root)

    # Use list.files instead of fs::dir_ls to avoid the full path
    cran_files <- list.files(source_package_dir(cran_root), recursive = TRUE)

    # The order of cran_files depend on the OS
    expect_length(cran_files, 4L)

    expect_true(basename(src_package_paths[1]) %in% cran_files)
    expect_true("PACKAGES" %in% cran_files)
    expect_true("PACKAGES.gz" %in% cran_files)
    expect_true("PACKAGES.rds" %in% cran_files)
})


test_that("Update CRAN with new version of source package", {
    cran_root <- make_random_demo_cran_path()
    withr::defer(fs::dir_delete(cran_root))

    f1 <- src_package_paths["foo_0.0.1"]
    update_cran_source(f1, cran_root)

    f2 <- src_package_paths["foo_0.0.2"]
    update_cran_source(f2, cran_root)

    cran_files <- list.files(source_package_dir(cran_root), recursive = TRUE)

    expect_true(basename(f2) %in% cran_files)
    expect_true("PACKAGES" %in% cran_files)
    expect_true("PACKAGES.gz" %in% cran_files)
    expect_true("PACKAGES.rds" %in% cran_files)
    expect_true("Meta/archive.rds" %in% cran_files)
    expect_true(
        fs::path("Archive", package_name_from_filename(f1), basename(f1)) %in% cran_files
    )
})


test_that("Unexpected files are deleted from CRAN", {
    cran_root <- make_demo_cran(packages = src_package_paths)
    withr::defer(fs::dir_delete(cran_root))

    unwanted_file <- fs::path(source_package_dir(cran_root), "random_file")
    fs::file_create(unwanted_file)
    expect_true(fs::file_exists(unwanted_file))

    unwanted_files <- clean_cran_source(cran_root, list = TRUE)
    expect_equal(basename(unwanted_files), "random_file")

    clean_cran_source(cran_root)
    expect_false(fs::file_exists(unwanted_file))
})


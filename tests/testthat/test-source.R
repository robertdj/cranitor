test_that("Import source package", {
    clean_test_cran(cran_root)

    import_source_package(cran_root, src_package_paths[1])

    cran_files <- fs::dir_ls(cran_root, type = "file", recurse = TRUE)
    expect_equal(basename(cran_files), basename(src_package_paths[1]))
})


test_that("Import the same source package twice", {
    clean_test_cran(cran_root)

    import_source_package(cran_root, src_package_paths[1])
    expect_error(
        import_source_package(cran_root, src_package_paths[1]),
        class = "EEXIST"
    )
})


test_that("Update CRAN with source package", {
    clean_test_cran(cran_root)

    update_cran_source(cran_root, src_package_paths[1])

    # cran_files <- fs::dir_ls(cran_root, type = "file", recurse = TRUE)
    cran_files <- list.files(fs::path(cran_root, "src", "contrib"), recursive = TRUE)

    expect_length(cran_files, 4L)

    expect_true(basename(src_package_paths[1]) %in% cran_files)
    expect_true("PACKAGES" %in% cran_files)
    expect_true("PACKAGES.gz" %in% cran_files)
    expect_true("PACKAGES.rds" %in% cran_files)
})


test_that("Update CRAN with new version of source package", {
    clean_test_cran(cran_root)

    f1 <- src_package_paths[1]
    update_cran_source(cran_root, f1)

    f2 <- src_package_paths[2]
    update_cran_source(cran_root, f2)

    # cran_files <- fs::dir_ls(cran_root, type = "file", recurse = TRUE)
    cran_files <- list.files(source_package_dir(cran_root), recursive = TRUE)

    # TODO: Save the basenames in setup
    expect_true(basename(f2) %in% cran_files)
    expect_true("PACKAGES" %in% cran_files)
    expect_true("PACKAGES.gz" %in% cran_files)
    expect_true("PACKAGES.rds" %in% cran_files)
    expect_true("Meta/archive.rds" %in% cran_files)
    expect_true(
        fs::path("Archive", package_name_from_filename(basename(f1)), basename(f1)) %in% cran_files
    )
})


test_that("Unexpected files are deleted from CRAN", {
    clean_test_cran(cran_root)

    make_demo_cran(cran_root, packages = src_package_paths)

    unwanted_file <- fs::path(source_package_dir(cran_root), "random_file")
    fs::file_create(unwanted_file)
    expect_true(fs::file_exists(unwanted_file))

    clean_cran_source(cran_root)
    expect_false(fs::file_exists(unwanted_file))
})
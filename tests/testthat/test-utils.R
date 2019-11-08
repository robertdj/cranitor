# Setup ---------------------------------------------------------------------------------------

cran_root <- file.path(tempdir(), "cran")

make_local_cran(cran_root)

win_folder <- win_package_dir(cran_root)
source_folder <- source_package_dir(cran_root)


# Unit tests ----------------------------------------------------------------------------------

test_that("Local CRAN has expected folder structure", {
    expect_true(dir.exists(win_folder))
    expect_true(dir.exists(source_folder))

    expect_length(dir(win_folder), 0)
    expect_length(dir(source_folder), 0)
})


test_that("Import packages", {
    import_source_package(cran_root, testdata_path("foo_0.0.1.tar.gz"))
    expect_equal(basename(source_package_files(cran_root, "foo")), "foo_0.0.1.tar.gz")

    # TODO: Until a zip file is included in the test data
    expect_error(
        import_win_package(cran_root, testdata_path("foo_0.0.1.zip")),
        "no file found",
        ignore.case = TRUE
    )
    # expect_equal(basename(windows_package_files(cran_root, "foo")), "foo_0.0.1.zip")
})


test_that("PACKAGES metadata files are created", {
    package_files_source <- file.path(source_folder, c("PACKAGES", "PACKAGES.gz", "PACKAGES.rds"))
    expect_false(all(file.exists(package_files_source)))

    tools::write_PACKAGES(source_folder, type = "source")
    expect_true(all(file.exists(package_files_source)))

    packages <- readLines(package_files_source[1])
    expect_equal(length(packages), 4)

    packages_gz_con <- gzfile(package_files_source[2], "rt")
    packages_gz <- readLines(packages_gz_con)
    close(packages_gz_con)
    expect_equal(packages, packages_gz)

    packages_rds <- readRDS(package_files_source[3])
    expect_equal(ncol(packages_rds), 15)
    expect_equal(nrow(packages_rds), 1)

    expect_equal(
        paste(c("Package:", "Version:", "MD5sum:", "NeedsCompilation:"),
              packages_rds[, c("Package", "Version", "MD5sum", "NeedsCompilation")]),
        packages
    )

    # tools::write_PACKAGES(win_folder, type = "win.binary")
    # package_files_win <- file.path(win_folder, c("PACKAGES", "PACKAGES.gz", "PACKAGES.rds"))
    # expect_true(all(fs::file_exists(package_files_win)))
})


test_that("Archive package", {
    expect_false(dir.exists(archive_path(cran_root)))
    expect_false(file.exists(archive_metadata_path(cran_root)))

    expect_message(archive_package(cran_root, "foo"), "No source packages archived")
    expect_message(archive_package(cran_root, "foo"), "No binary packages archived")


    foo_source_package <- source_package_files(cran_root, "foo")
    import_source_package(cran_root, testdata_path("foo_0.0.2.tar.gz"))

    expect_equal(
        basename(source_package_files(cran_root, "foo")),
        c("foo_0.0.2.tar.gz", "foo_0.0.1.tar.gz")
    )

    # foo_bin_package <- windows_package_files(cran_root, "foo")
    # fs::file_copy(
    #     foo_bin_package,
    #     file.path(win_package_dir(cran_root), "foo_0.0.2.zip")
    # )

    # expect_equal(
    #     basename(windows_package_files(cran_root, "foo")),
    #     c("foo_0.0.2.zip", "foo_0.0.1.zip")
    # )


    # TODO: Have an archive_source_function and an archive_bin_function
    archive_package(cran_root, "foo")
    expect_true(dir.exists(archive_path(cran_root)))

    expect_equal(basename(archive_package_files(cran_root)), "foo_0.0.1.tar.gz")
    expect_equal(basename(source_package_files(cran_root, "foo")), "foo_0.0.2.tar.gz")
    # expect_equal(basename(windows_package_files(cran_root, "foo")), "foo_0.0.2.zip")
})


test_that("Update archive metadata", {
    metadata <- formatted_archive_metadata(cran_root)

    expect_type(metadata, "list")
    expect_named(metadata, "foo")
    expect_s3_class(metadata$foo, "data.frame")
    expect_named(
        metadata$foo,
        c("size", "isdir", "mode", "mtime", "ctime", "atime", "uid", "gid", "uname", "grname")
    )


    expect_false(file.exists(archive_metadata_path(cran_root)))
    make_archive_metadata(cran_root)
    expect_true(file.exists(archive_metadata_path(cran_root)))
})


unlink(cran_root, recursive = TRUE)

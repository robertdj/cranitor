# Setup ---------------------------------------------------------------------------------------

cran_root <- file.path(tempdir(), "cran")

# if (dir.exists(cran_root))
#     unlink(cran_root, recursive = TRUE)

dir.create(cran_root)
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
    # import_win_package(cran_root, testdata_path("foo_0.0.1.zip"))

    expect_equal(basename(source_package_files(cran_root, "foo")), "foo_0.0.1.tar.gz")
    # expect_equal(basename(windows_package_files(cran_root, "foo")), "foo_0.0.1.zip")


    expect_error(
        import_source_package(cran_root, testdata_path("foo_0.0.1.zip"))
    )

    # expect_error(
    #     import_win_package(cran_root, testdata_path("foo_0.0.1.tar.gz"))
    # )
})


test_that("PACKAGES metadata files are created", {
    tools::write_PACKAGES(source_folder, type = "source")
    package_files_source <- file.path(source_folder, c("PACKAGES", "PACKAGES.gz", "PACKAGES.rds"))
    expect_true(all(fs::file_exists(package_files_source)))


    # tools::write_PACKAGES(win_folder, type = "win.binary")
    # package_files_win = file.path(win_folder, c("PACKAGES", "PACKAGES.gz", "PACKAGES.rds"))
    # expect_true(all(fs::file_exists(package_files_win)))


    packages <- read.csv(
        file.path(source_folder, "PACKAGES"), sep = ":", header = FALSE, as.is = TRUE
    )

    expect_equal(ncol(packages), 2)
    expect_equal(packages[,1], c("Package", "Version", "MD5sum", "NeedsCompilation"))
    expect_equal(packages[1:2, 2], c(" foo", " 0.0.1"))
})


test_that("Archive package", {
    expect_false(dir.exists(archive_path(cran_root)))
    expect_false(file.exists(archive_metadata_path(cran_root)))

    expect_message(archive_package(cran_root, "foo"), "No source packages archived")
    expect_message(archive_package(cran_root, "foo"), "No binary packages archived")


    foo_source_package <- source_package_files(cran_root, "foo")
    import_source_package(cran_root, testdata_path("foo_0.0.2.tar.gz"))

    # foo_bin_package <- windows_package_files(cran_root, "foo")
    # fs::file_copy(
    #     foo_bin_package,
    #     file.path(win_package_dir(cran_root), "foo_0.0.2.zip")
    # )

    expect_equal(
        basename(source_package_files(cran_root, "foo")),
        c("foo_0.0.2.tar.gz", "foo_0.0.1.tar.gz")
    )
    # expect_equal(
    #     basename(windows_package_files(cran_root, "foo")),
    #     c("foo_0.0.2.zip", "foo_0.0.1.zip")
    # )


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


# End-to-end test -----------------------------------------------------------------------------

test_that("End-to-end archive update", {
    cran_parent <- tempdir()
    cran_root <- file.path(cran_parent, "e2e-cran")
    # dir.create(cran_root)
    make_demo_cran(cran_root)
    on.exit(unlink(cran_root, recursive = TRUE), add = TRUE)

    # cran_root <- make_demo_cran()

    # make_local_cran(cran_root)

    # After the very first import there is nothing to import; silence the message
    # update_cran(
    #     cran_root,
    #     testdata_path("foo_0.0.1.tar.gz")
    #     # testdata_path("foo_0.0.1.zip")
    # )


    # import_source_package(cran_root, testdata_path("foo_0.0.2.tar.gz"))
    # file.copy(
    #     testdata_path("foo_0.0.1.tar.gz"),
    #     file.path(cran_parent, "foo_0.0.2.tar.gz")
    # )

    # file.copy(
    #     testdata_path("foo_0.0.1.zip"),
    #     file.path(cran_parent, "foo_0.0.2.zip")
    # )

    # update_cran(
    #     cran_root,
    #     file.path(cran_parent, "foo_0.0.2.tar.gz")
    #     # file.path(cran_parent, "foo_0.0.2.zip")
    # )


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


# Clean up ------------------------------------------------------------------------------------

unlink(cran_root, recursive = TRUE)

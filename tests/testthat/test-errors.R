
test_that("Import non-package archive", {
    tmp_file <- fs::file_create(fs::file_temp())
    writeLines("foobar\n", con = tmp_file)

    targz_file <-  fs::file_temp(pattern = "foo_", ext = "tar.gz")
    # TODO: Change WD to quiet message from tar
    utils::tar(tarfile = targz_file, files = tmp_file, compression = "gzip", compression_level = 9L, tar = "tar")

    expect_error(
        update_cran(fs::path_temp("demo_cran"), targz_file),
        "foo/DESCRIPTION does not exist"
    )
})


test_that("Import archive with corrupted DESCRIPTION", {
    tmp_dir <- fs::path_temp()
    fs::dir_create(fs::path(tmp_dir, "foo"))
    tmp_file <- fs::file_create(fs::path(tmp_dir, "foo", "DESCRIPTION"))
    writeLines("foobar", con = tmp_file)

    targz_file <-  fs::file_temp(pattern = "foo_", ext = "tar.gz")
    withr::with_dir(
        tmp_dir,
        utils::tar(
            tarfile = targz_file, files = fs::path("foo", "DESCRIPTION"),
            compression = "gzip", compression_level = 9L, tar = "tar"
        )
    )

    fs::dir_delete(fs::path(tmp_dir, "foo"))
    expect_error(
        update_cran(fs::path_temp("demo_cran"), targz_file),
        "Malformed DESCRIPTION"
    )
})

test_that("Import non-package archive", {
    withr::with_tempdir({
        tmp_file <- basename(fs::file_temp())
        writeLines("foobar\n", con = tmp_file)
        targz_file <-  fs::file_temp(pattern = "foo_", ext = "tar.gz")

        utils::tar(
            tarfile = targz_file, files = tmp_file,
            compression = "gzip", compression_level = 9L, tar = "tar"
        )
    })

    expect_error(
        update_cran(fs::path_temp("demo_cran"), targz_file),
        "foo/DESCRIPTION does not exist"
    )
})


test_that("Import archive with corrupted DESCRIPTION", {
    withr::with_tempdir({
        fs::dir_create("foo")
        writeLines("foobar", con = fs::path("foo", "DESCRIPTION"))
        targz_file <-  fs::file_temp(pattern = "foo_", ext = "tar.gz")

        utils::tar(
            tarfile = targz_file, files = fs::path("foo", "DESCRIPTION"),
            compression = "gzip", compression_level = 9L, tar = "tar"
        )
    })

    expect_error(
        update_cran(fs::path_temp("demo_cran"), targz_file),
        "Malformed DESCRIPTION"
    )
})

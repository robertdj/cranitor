make_baz_archive <- function(tmp_file) {
    withr::with_tempdir({
        withr::defer(fs::dir_delete("baz"))
        fs::dir_create("baz")

        writeLines("foobar", con = fs::path("baz", tmp_file))

        targz_file <-  fs::path_temp("baz_0.0.1.tar.gz")
        withr::defer_parent(fs::file_delete(targz_file))

        utils::tar(
            tarfile = targz_file, files = fs::path("baz", tmp_file),
            compression = "gzip", compression_level = 9L, tar = "tar"
        )
    })

    return(targz_file)
}


test_that("Import non-package archive", {
    targz_file <- make_baz_archive(basename(fs::file_temp()))

    expect_error(
        update_cran(fs::path_temp("demo_cran"), targz_file),
        "baz/DESCRIPTION does not exist"
    )
})


test_that("Import archive with corrupted DESCRIPTION", {
    targz_file <- make_baz_archive("DESCRIPTION")

    expect_error(
        update_cran(fs::path_temp("demo_cran"), targz_file),
        "Malformed DESCRIPTION"
    )
})

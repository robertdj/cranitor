testdata_path <- function(filename) {
    system.file(file.path("testdata", filename), package = "cranitor", lib.loc = .libPaths()[1], mustWork = TRUE)
}

create_empty_package <- function(package_name, version) {
    package_path <- file.path(tempdir(), package_name)
    dir.create(package_path)
    usethis::create_package(package_path, rstudio = FALSE, open = FALSE)
    unlink(file.path(package_path, "R"), recursive = TRUE)

    package_desc <- desc::desc(file = file.path(package_path, "DESCRIPTION"))
    package_desc$set_version(version)
    package_desc$write()

    devtools::build(pkg = package_path)
}


file.copy(create_empty_package("foo", "0.0.1"), here::here("inst", "testdata"), overwrite = TRUE)
file.copy(create_empty_package("foo", "0.0.2"), here::here("inst", "testdata"), overwrite = TRUE)

file.copy(create_empty_package("bar", "0.0.1"), here::here("inst", "testdata"), overwrite = TRUE)

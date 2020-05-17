fs::file_delete(src_package_paths)

if (is_win_or_mac()) {
    fs::file_delete(bin_package_paths)
}

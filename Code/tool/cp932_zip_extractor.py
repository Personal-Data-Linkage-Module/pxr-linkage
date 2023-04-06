#!/usr/bin/env python

import sys
import zipfile


def rename_encode(zippedfile):
    for info in zippedfile.infolist():
        info.filename = info.filename.encode("cp437").decode("cp932")


def rename_directory(zippedfile, dest):
    for info in zippedfile.infolist():
        info.filename = info.filename.replace("パーソナルデータ連携モジュール1.0.0", dest)


def extract_src_zip(src, dest):
    with zipfile.ZipFile(src) as parent:
        rename_encode(parent)
        for parent_info in parent.infolist():
            if parent_info.filename == "パーソナルデータ連携モジュール_ソースコード/パーソナルデータ連携モジュール1.0.0.zip":
                with parent.open(parent_info) as child:
                    with zipfile.ZipFile(child) as srczip:
                        rename_encode(srczip)
                        rename_directory(srczip, dest)
                        for src_info in srczip.infolist():
                            srczip.extract(src_info)


def main():
    src = sys.argv[1]
    dest = sys.argv[2]
    extract_src_zip(src, dest)


if __name__ == "__main__":
    main()
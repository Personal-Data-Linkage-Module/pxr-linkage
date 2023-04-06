/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- -- DBを作成（MiniSHIFT単位、Pod名）
-- DROP DATABASE IF EXISTS pxr_pod;
-- CREATE DATABASE pxr_pod WITH ENCODING 'UTF-8';

-- -- DBをスイッチング
-- \c pxr_pod;

-- 新しくユーザーを作成
CREATE USER pxr_identify_verify_user WITH PASSWORD 'pxr_password';

-- スキーマーを生成
CREATE SCHEMA pxr_identify_verify AUTHORIZATION pxr_identify_verify_user;

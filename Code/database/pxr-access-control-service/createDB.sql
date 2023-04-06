/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- -- DBを作成（MiniSHIFT単位、Pod名）
-- DROP DATABASE IF EXISTS pod;
-- CREATE DATABASE pod WITH ENCODING 'UTF-8';

-- -- DBをスイッチング
-- \c pod;

-- 新しくユーザーを作成
CREATE USER pxr_access_control_user WITH PASSWORD 'pxr_password';

-- スキーマーを生成
CREATE SCHEMA pxr_access_control AUTHORIZATION pxr_access_control_user;

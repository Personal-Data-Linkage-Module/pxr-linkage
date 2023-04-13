/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- 新しくユーザーを作成
CREATE USER pxr_local_ctoken_user WITH PASSWORD 'pxr_password';

-- スキーマーを生成
CREATE SCHEMA pxr_local_ctoken AUTHORIZATION pxr_local_ctoken_user;

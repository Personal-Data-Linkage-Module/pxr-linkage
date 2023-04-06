/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- 新しくユーザーを作成
CREATE USER pxr_access_manage_user WITH PASSWORD 'pxr_password';

-- スキーマーを作成
CREATE SCHEMA pxr_access_manage AUTHORIZATION pxr_access_manage_user;

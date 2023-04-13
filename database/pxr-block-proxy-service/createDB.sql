/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- 新しくユーザーを作成
CREATE USER pxr_block_proxy_user WITH PASSWORD 'pxr_password';

-- スキーマーを生成
CREATE SCHEMA pxr_block_proxy AUTHORIZATION pxr_block_proxy_user;

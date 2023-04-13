/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- スキーマを作成
CREATE SCHEMA pxr_certification_authority;

-- 新しくユーザーを作成
CREATE ROLE pxr_certification_authority_user LOGIN PASSWORD 'pxr_password';

-- 作成したユーザーに作成したスキーマの操作権限を付与
GRANT USAGE ON SCHEMA pxr_certification_authority TO pxr_certification_authority_user;

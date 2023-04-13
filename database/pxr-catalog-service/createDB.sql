/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- DBを作成
/*
CREATE DATABASE pxr_pod
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Japanese_Japan.932'
    LC_CTYPE = 'Japanese_Japan.932'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
;
COMMENT ON DATABASE postgres IS 'pxr-pod database';

上記をpgAdmin4上で手動で作成する。

1. 左サイドメニューでPostgreSQL 12を左クリックして、Create > Database... を選択
2. Generalタブで以下を設定
    Database: pxr_pod
    Owner: postgres(デフォルト)
    Comment: pxr-pod database
3. Definitionタブで以下を設定
    Encoding: UTF8(デフォルト)
    Tablespace: pg_default
    Collation: C
    Character type: C
    Connection limit: -1(デフォルト)
4. Saveを押下
*/

-- スキーマを作成
CREATE SCHEMA pxr_catalog;

-- 新しくユーザーを作成
CREATE ROLE pxr_catalog_user LOGIN PASSWORD 'pxr_password';

-- 作成したユーザーに作成したスキーマの操作権限を付与
GRANT USAGE ON SCHEMA pxr_catalog TO pxr_catalog_user;

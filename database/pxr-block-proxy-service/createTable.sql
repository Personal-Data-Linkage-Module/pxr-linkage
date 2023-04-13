/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- 呼出ログ
DROP TABLE IF EXISTS pxr_block_proxy.log_called_api CASCADE;
CREATE TABLE IF NOT EXISTS pxr_block_proxy.log_called_api
(
    id bigserial,
    type smallint NOT NULL,
    api_method varchar(255) NOT NULL,
    caller_block_catalog_code bigint NOT NULL,
    caller_block_catalog_version bigint NOT NULL,
    caller_api_url text,
    destination_block_catalog_code bigint NOT NULL,
    destination_block_catalog_version bigint NOT NULL,
    destination_api_url text NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- ユーザーにテーブル・シーケンスの操作権限を付与



/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- 外部キーを削除
--ALTER TABLE pxr_access_control.caller_role
--    DROP CONSTRAINT caller_role_ibfk_1;

-- APIアクセス許可テーブルの作成
DROP TABLE IF EXISTS pxr_access_control.api_access_permission CASCADE;
CREATE TABLE IF NOT EXISTS pxr_access_control.api_access_permission
(
    id bigserial,
    token varchar(255) NOT NULL UNIQUE,
    target_block_code bigint,
    target_api_url text NOT NULL,
    target_api_method varchar(255) NOT NULL,
    target_user_id varchar(255),
    expiration_date timestamp(3) NOT NULL,
    caller_block_code bigint NOT NULL,
    caller_api_url text NOT NULL,
    caller_api_method varchar(255) NOT NULL,
    caller_api_code varchar(255) NOT NULL,
    caller_wf_code bigint,
    caller_wf_version bigint,
    caller_app_code bigint,
    caller_app_version bigint,
    caller_operator_type smallint NOT NULL,
    caller_operator_login_id varchar(255) NOT NULL,
    parameter text,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_access_control.api_access_permission IS 'APIアクセス許可テーブル';
COMMENT ON COLUMN pxr_access_control.api_access_permission.id IS 'ID';
COMMENT ON COLUMN pxr_access_control.api_access_permission.token IS 'トークン';
COMMENT ON COLUMN pxr_access_control.api_access_permission.target_block_code IS '呼出先Blockカタログコード';
COMMENT ON COLUMN pxr_access_control.api_access_permission.target_api_url IS '呼出先APIURL';
COMMENT ON COLUMN pxr_access_control.api_access_permission.target_api_method IS '呼出先APIメソッド';
COMMENT ON COLUMN pxr_access_control.api_access_permission.target_user_id IS '利用者ID';
COMMENT ON COLUMN pxr_access_control.api_access_permission.expiration_date IS '有効期限';
COMMENT ON COLUMN pxr_access_control.api_access_permission.caller_block_code IS '呼出元Blockカタログコード';
COMMENT ON COLUMN pxr_access_control.api_access_permission.caller_api_url IS '呼出元APIURL';
COMMENT ON COLUMN pxr_access_control.api_access_permission.caller_api_method IS '呼出元APIメソッド';
COMMENT ON COLUMN pxr_access_control.api_access_permission.caller_api_code IS '呼出元APIコード';
COMMENT ON COLUMN pxr_access_control.api_access_permission.caller_wf_code IS '呼出元ワークフローカタログコード';
COMMENT ON COLUMN pxr_access_control.api_access_permission.caller_wf_version IS '呼出元ワークフローカタログバージョン';
COMMENT ON COLUMN pxr_access_control.api_access_permission.caller_app_code IS '呼出元アプリケーションカタログコード';
COMMENT ON COLUMN pxr_access_control.api_access_permission.caller_app_version IS '呼出元アプリケーションカタログバージョン';
COMMENT ON COLUMN pxr_access_control.api_access_permission.caller_operator_type IS '呼出元オペレータタイプ';
COMMENT ON COLUMN pxr_access_control.api_access_permission.caller_operator_login_id IS '呼出元オペレータ';
COMMENT ON COLUMN pxr_access_control.api_access_permission.parameter IS 'パラメーター';
COMMENT ON COLUMN pxr_access_control.api_access_permission.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_access_control.api_access_permission.created_by IS '登録者';
COMMENT ON COLUMN pxr_access_control.api_access_permission.created_at IS '登録日時';
COMMENT ON COLUMN pxr_access_control.api_access_permission.updated_by IS '更新者';
COMMENT ON COLUMN pxr_access_control.api_access_permission.updated_at IS '更新日時';

-- 呼び出し元ロールテーブルの作成
DROP TABLE IF EXISTS pxr_access_control.caller_role CASCADE;
CREATE TABLE IF NOT EXISTS pxr_access_control.caller_role
(
    id bigserial,
    api_access_permission_id bigint REFERENCES pxr_access_control.api_access_permission (id),
    role_catalog_code bigint NOT NULL,
    role_catalog_version bigint NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_access_control.caller_role IS '呼出元ロールテーブル';
COMMENT ON COLUMN pxr_access_control.caller_role.id IS 'ID';
COMMENT ON COLUMN pxr_access_control.caller_role.api_access_permission_id IS 'APIアクセス許可ID';
COMMENT ON COLUMN pxr_access_control.caller_role.role_catalog_code IS '呼出元ロールカタログコード';
COMMENT ON COLUMN pxr_access_control.caller_role.role_catalog_version IS '呼出元ロールカタログバージョン';
COMMENT ON COLUMN pxr_access_control.caller_role.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_access_control.caller_role.created_by IS '登録者';
COMMENT ON COLUMN pxr_access_control.caller_role.created_at IS '登録日時';
COMMENT ON COLUMN pxr_access_control.caller_role.updated_by IS '更新者';
COMMENT ON COLUMN pxr_access_control.caller_role.updated_at IS '更新日時';

-- APIトークンテーブルの作成
DROP TABLE IF EXISTS pxr_access_control.api_token CASCADE;
CREATE TABLE IF NOT EXISTS pxr_access_control.api_token
(
    id bigserial,
    token varchar(255) NOT NULL UNIQUE,
    target_block_code bigint,
    target_api_url text NOT NULL,
    target_api_method varchar(255) NOT NULL,
    target_user_id varchar(255),
    expiration_date timestamp(3) NOT NULL,
    caller_block_code bigint NOT NULL,
    caller_api_url text NOT NULL,
    caller_api_method varchar(255) NOT NULL,
    caller_api_code varchar(255) NOT NULL,
    caller_wf_code bigint,
    caller_wf_version bigint,
    caller_app_code bigint,
    caller_app_version bigint,
    caller_operator_type smallint NOT NULL,
    caller_operator_login_id varchar(255) NOT NULL,
    attribute text,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_access_control.api_token IS 'APIトークンテーブル';
COMMENT ON COLUMN pxr_access_control.api_token.id IS 'ID';
COMMENT ON COLUMN pxr_access_control.api_token.token IS 'トークン';
COMMENT ON COLUMN pxr_access_control.api_token.target_block_code IS '呼出先Blockカタログコード';
COMMENT ON COLUMN pxr_access_control.api_token.target_api_url IS '呼出先APIURL';
COMMENT ON COLUMN pxr_access_control.api_token.target_api_method IS '呼出先APIメソッド';
COMMENT ON COLUMN pxr_access_control.api_token.target_user_id IS '利用者ID';
COMMENT ON COLUMN pxr_access_control.api_token.expiration_date IS '有効期限';
COMMENT ON COLUMN pxr_access_control.api_token.caller_block_code IS '呼出元Blockカタログコード';
COMMENT ON COLUMN pxr_access_control.api_token.caller_api_url IS '呼出元APIURL';
COMMENT ON COLUMN pxr_access_control.api_token.caller_api_method IS '呼出元APIメソッド';
COMMENT ON COLUMN pxr_access_control.api_token.caller_api_code IS '呼出元APIコード';
COMMENT ON COLUMN pxr_access_control.api_token.caller_wf_code IS '呼出元ワークフローカタログコード';
COMMENT ON COLUMN pxr_access_control.api_token.caller_wf_version IS '呼出元ワークフローカタログバージョン';
COMMENT ON COLUMN pxr_access_control.api_token.caller_app_code IS '呼出元アプリケーションカタログコード';
COMMENT ON COLUMN pxr_access_control.api_token.caller_app_version IS '呼出元アプリケーションカタログバージョン';
COMMENT ON COLUMN pxr_access_control.api_token.caller_operator_type IS '呼出元オペレータタイプ';
COMMENT ON COLUMN pxr_access_control.api_token.caller_operator_login_id IS '呼出元オペレータ';
COMMENT ON COLUMN pxr_access_control.api_token.attribute IS '属性';
COMMENT ON COLUMN pxr_access_control.api_token.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_access_control.api_token.created_by IS '登録者';
COMMENT ON COLUMN pxr_access_control.api_token.created_at IS '登録日時';
COMMENT ON COLUMN pxr_access_control.api_token.updated_by IS '更新者';
COMMENT ON COLUMN pxr_access_control.api_token.updated_at IS '更新日時';

-- 外部キーを追加
ALTER TABLE pxr_access_control.caller_role
    ADD CONSTRAINT caller_role_ibfk_1
    FOREIGN KEY (api_access_permission_id) REFERENCES pxr_access_control.api_access_permission (id);

-- インデックスを追加
-- DROP INDEX pxr_access_control.api_token_search_token_idx;
-- DROP INDEX pxr_access_control.api_access_permission_token_idx;
CREATE INDEX api_token_search_token_idx ON pxr_access_control.api_token(expiration_date, caller_api_url, caller_operator_login_id, target_api_url, target_api_method, caller_block_code);
CREATE INDEX api_access_permission_token_idx ON pxr_access_control.api_access_permission(token, caller_api_url, target_api_url, target_api_method);









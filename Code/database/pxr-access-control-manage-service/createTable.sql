/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- 外部キーを削除
--ALTER TABLE pxr_access_manage.caller_role
--    DROP CONSTRAINT caller_role_ibfk_1;
--ALTER TABLE pxr_access_manage.token_access_history
--    DROP CONSTRAINT token_access_history_ibfk_1;

-- APIトークン生成記録
DROP TABLE IF EXISTS pxr_access_manage.token_generation_history CASCADE;
CREATE TABLE IF NOT EXISTS pxr_access_manage.token_generation_history
(
    id bigserial,
    caller_block_catalog_code bigint NOT NULL,
    caller_api_url varchar(255) NOT NULL,
    caller_api_method varchar(10) NOT NULL,
    caller_api_code varchar(255) NOT NULL,
    caller_workflow_catalog_code bigint,
    caller_workflow_catalog_version bigint,
    caller_application_catalog_code bigint,
    caller_application_catalog_version bigint,
    caller_operator_type smallint NOT NULL,
    caller_operator_id bigint,
    pxr_id bigint,
    caller_user_id varchar(255),
    temporary_code varchar(255),
    identity_code varchar(255),
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- APIアクセス許可記録
DROP TABLE IF EXISTS pxr_access_manage.token_access_history CASCADE;
CREATE TABLE IF NOT EXISTS pxr_access_manage.token_access_history
(
    id bigserial,
    created_history_id bigint REFERENCES pxr_access_manage.token_generation_history (id),
    api_token varchar(255) NOT NULL,
    destination_block_catalog_code bigint NOT NULL,
    destination_api_url varchar(255) NOT NULL,
    destination_api_method varchar(10) NOT NULL,
    destination_user_id  varchar(255),
    expiration_at timestamp(3) NOT NULL,
    parameter text,
    status smallint,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- 呼出元ロール
DROP TABLE IF EXISTS pxr_access_manage.caller_role CASCADE;
CREATE TABLE IF NOT EXISTS pxr_access_manage.caller_role
(
    id bigserial,
    created_history_id bigint REFERENCES pxr_access_manage.token_generation_history (id),
    caller_role_catalog_code bigint NOT NULL,
    caller_role_catalog_version bigint NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- 外部キーを追加
ALTER TABLE pxr_access_manage.caller_role
    ADD CONSTRAINT caller_role_ibfk_1
    FOREIGN KEY (created_history_id) REFERENCES pxr_access_manage.token_generation_history (id);
ALTER TABLE pxr_access_manage.token_access_history
    ADD CONSTRAINT token_access_history_ibfk_1
    FOREIGN KEY (created_history_id) REFERENCES pxr_access_manage.token_generation_history (id);









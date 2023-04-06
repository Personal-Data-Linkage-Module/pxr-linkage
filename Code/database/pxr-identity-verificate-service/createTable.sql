/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- 本人性確認テーブル
DROP TABLE IF EXISTS pxr_identify_verify.identify_verify CASCADE;
CREATE TABLE IF NOT EXISTS pxr_identify_verify.identify_verify
(
    id bigserial,
    code varchar(255) NOT NUll,
    actor_catalog_code bigint NOT NULL,
    actor_catalog_version bigint NOT NULL,
    region_catalog_code bigint,
    region_catalog_version bigint,
    application_catalog_code bigint,
    application_catalog_version bigint,
    workflow_catalog_code bigint,
    workflow_catalog_version bigint,
    pxr_id varchar(255) NOT NULL,
    user_id varchar(255),
    is_verified smallint NOT NULL DEFAULT 0,
    expiration_at timestamp(3),
    is_disabled boolean NOT NULL default false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT now(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT now(),
    PRIMARY KEY (id)
);

-- 本人性確認用URLテーブル
DROP TABLE IF EXISTS pxr_identify_verify.identify_verify_url CASCADE;
CREATE TABLE IF NOT EXISTS pxr_identify_verify.identify_verify_url
(
    id bigserial,
    code varchar(255) NOT NUll,
    type smallint NOT NULL,
    user_id varchar(255) NOT NULL,
    actor_catalog_code bigint NOT NULL,
    actor_catalog_version bigint NOT NULL,
    region_catalog_code bigint,
    region_catalog_version bigint,
    application_catalog_code bigint,
    application_catalog_version bigint,
    workflow_catalog_code bigint,
    workflow_catalog_version bigint,
    expiration_at timestamp(3),
    is_disabled boolean NOT NULL default false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT now(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT now(),
    PRIMARY KEY (id)
);







/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- 外部キーを削除(2回目以降のテーブル作成する時のみ必要)
-- ALTER TABLE pxr_catalog_update.actor_approval_manage DROP CONSTRAINT actor_approval_manage_actor_manage_id_fkey;
-- ALTER TABLE pxr_catalog_update.join_approval_manage DROP CONSTRAINT join_approval_manage_join_manage_id_fkey;
-- ALTER TABLE pxr_catalog_update.alliance_approval_manage DROP CONSTRAINT alliance_approval_manage_alliance_manage_id_fkey;
-- ALTER TABLE pxr_catalog_update.region_approval_manage DROP CONSTRAINT region_approval_manage_region_manage_id_fkey;

-- アクター申請管理テーブルを作成
DROP TABLE IF EXISTS pxr_catalog_update.actor_manage CASCADE;
CREATE TABLE IF NOT EXISTS pxr_catalog_update.actor_manage
(
    id bigserial,
    caller_actor_code bigint,
    caller_actor_version bigint,
    caller_block_code bigint NOT NULL,
    caller_block_version bigint NOT NULL,
    template text,
    approval_expire_at timestamp(3),
    type smallint NOT NULL,
    applicant_date timestamp(3),
    is_draft boolean NOT NULL DEFAULT false,
    attributes text,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- アクター申請承認管理テーブルを作成
DROP TABLE IF EXISTS pxr_catalog_update.actor_approval_manage CASCADE;
CREATE TABLE IF NOT EXISTS pxr_catalog_update.actor_approval_manage
(
    id bigserial,
    actor_manage_id bigint NOT NULL,
    auth_code varchar(255),
    status smallint NOT NULL DEFAULT 0,
    comment text,
    migration_actor_code bigint,
    migration_actor_version bigint,
    migration_comment text,
    migragtion_approver varchar(255),
    migration_approval_at timestamp(3),
    approval_actor_code bigint,
    approval_actor_version bigint,
    approver varchar(255),
    approval_at timestamp(3),
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- Region参加申請管理テーブルを作成
DROP TABLE IF EXISTS pxr_catalog_update.join_manage CASCADE;
CREATE TABLE IF NOT EXISTS pxr_catalog_update.join_manage
(
    id bigserial,
    join_actor_code bigint NOT NULL,
    join_actor_version bigint NOT NULL,
    join_region_code bigint NOT NULL,
    join_region_version bigint NOT NULL,
    applicant_actor_code bigint,
    applicant_actor_version bigint,
    approval_expire_at timestamp(3),
    type smallint NOT NULL,
    applicant_date timestamp(3),
    is_draft boolean NOT NULL DEFAULT false,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- Region参加申請承認管理テーブルを作成
DROP TABLE IF EXISTS pxr_catalog_update.join_approval_manage CASCADE;
CREATE TABLE IF NOT EXISTS pxr_catalog_update.join_approval_manage
(
    id bigserial,
    join_manage_id bigint NOT NULL,
    auth_code varchar(255),
    status smallint NOT NULL DEFAULT 0,
    comment text,
    approval_actor_code bigint,
    approval_actor_version bigint,
    approver varchar(255),
    approval_at timestamp(3),
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- Region参加サービステーブル追加
DROP TABLE IF EXISTS pxr_catalog_update.join_service_manage CASCADE;
CREATE TABLE IF NOT EXISTS pxr_catalog_update.join_service_manage
(
    id bigserial,
    join_manage_id bigint NOT NULL,
    type smallint NOT NULL,
    service_code bigint NOT NULL,
    service_version bigint NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- 提携申請管理テーブルを作成
DROP TABLE IF EXISTS pxr_catalog_update.alliance_manage CASCADE;
CREATE TABLE IF NOT EXISTS pxr_catalog_update.alliance_manage
(
    id bigserial,
    alliance_trader_code bigint NOT NULL,
    alliance_trader_version bigint NOT NULL,
    alliance_consumer_code bigint,
    alliance_consumer_version bigint,
    alliance_region_code bigint,
    alliance_region_version bigint,
    applicant_actor_code bigint NOT NULL,
    applicant_actor_version bigint NOT NULL,
    approval_expire_at timestamp(3),
    type smallint NOT NULL,
    applicant_date timestamp(3),
    is_draft boolean NOT NULL DEFAULT false,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- 提携申請承認管理テーブルを作成
DROP TABLE IF EXISTS pxr_catalog_update.alliance_approval_manage CASCADE;
CREATE TABLE IF NOT EXISTS pxr_catalog_update.alliance_approval_manage
(
    id bigserial,
    alliance_manage_id bigint NOT NULL,
    auth_code varchar(255) NOT NULL,
    status smallint NOT NULL DEFAULT 0,
    comment text,
    approval_actor_code bigint,
    approval_actor_version bigint,
    approver varchar(255),
    approval_at timestamp(3),
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- データ処理定義管理テーブルを作成
DROP TABLE IF EXISTS pxr_catalog_update.data_operation_manage CASCADE;
CREATE TABLE IF NOT EXISTS pxr_catalog_update.data_operation_manage
(
    id bigserial,
    template text,
    application_actor_code bigint NOT NULL,
    application_block_code bigint NOT NULL,
    application_at timestamp(3),
    is_draft boolean NOT NULL DEFAULT false,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- 監査レポート管理テーブルを作成
DROP TABLE IF EXISTS pxr_catalog_update.audit_report_manage CASCADE;
CREATE TABLE IF NOT EXISTS pxr_catalog_update.audit_report_manage
(
    id bigserial,
    target_actor_code bigint NOT NULL,
    target_actor_version bigint NOT NULL,
    audit_actor_code bigint NOT NULL,
    audit_actor_version bigint NOT NULL,
    auditor varchar(255) NOT NULL,
    report_template text,
    report_created_at timestamp(3) NOT NULL DEFAULT NOW(),
    is_draft boolean NOT NULL DEFAULT false,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- Region開始終了申請管理テーブルを作成
DROP TABLE IF EXISTS pxr_catalog_update.region_manage CASCADE;
CREATE TABLE IF NOT EXISTS pxr_catalog_update.region_manage
(
    id bigserial,
    region_code bigint,
    region_version bigint,
    caller_block_code bigint NOT NULL,
    caller_block_version bigint NOT NULL,
    applicant_actor_code bigint,
    applicant_actor_version bigint,
    approval_actor_code bigint,
    approval_actor_version bigint,
    template text,
    approval_expire_at timestamp(3),
    type smallint NOT NULL,
    is_draft boolean NOT NULL DEFAULT false,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- Region開始終了申請承認管理テーブルを作成
DROP TABLE IF EXISTS pxr_catalog_update.region_approval_manage CASCADE;
CREATE TABLE IF NOT EXISTS pxr_catalog_update.region_approval_manage
(
    id bigserial,
    region_manage_id bigint NOT NULL,
    auth_code varchar(255),
    status bigint NOT NULL DEFAULT 0,
    comment text,
    approval_actor_code bigint,
    approval_actor_version bigint,
    approver varchar(255),
    approval_at timestamp(3),
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- Region開始終了申請管理テーブルを作成
DROP TABLE IF EXISTS pxr_catalog_update.region_status_manage CASCADE;
CREATE TABLE IF NOT EXISTS pxr_catalog_update.region_status_manage
(
    id bigserial,
    region_code bigint,
    region_version bigint,
    caller_block_code bigint NOT NULL,
    caller_block_version bigint NOT NULL,
    applicant_actor_code bigint,
    applicant_actor_version bigint,
    approval_actor_code bigint,
    approval_actor_version bigint,
    end_date timestamp(3),
    approval_expire_at timestamp(3),
    type smallint NOT NULL,
    request_comment text,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- Region開始終了申請承認管理テーブルを作成
DROP TABLE IF EXISTS pxr_catalog_update.region_status_approval_manage CASCADE;
CREATE TABLE IF NOT EXISTS pxr_catalog_update.region_status_approval_manage
(
    id bigserial,
    region_status_manage_id bigint NOT NULL,
    auth_code varchar(255),
    status bigint NOT NULL DEFAULT 0,
    comment text,
    approval_actor_code bigint,
    approval_actor_version bigint,
    approver varchar(255),
    approval_at timestamp(3),
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- PF利用規約管理テーブルを作成
DROP TABLE IF EXISTS pxr_catalog_update.platform_terms_of_use_manage CASCADE;
CREATE TABLE IF NOT EXISTS pxr_catalog_update.platform_terms_of_use_manage
(
    id bigserial,
    terms_of_use_code bigint,
    terms_of_use_version bigint,
    template text,
    application_actor_code bigint NOT NULL,
    application_block_code bigint NOT NULL,
    application_at timestamp(3) NOT NULL,
    is_disabled BOOLEAN NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- Region利用規約管理テーブルを作成
DROP TABLE IF EXISTS pxr_catalog_update.region_terms_of_use_manage CASCADE;
CREATE TABLE IF NOT EXISTS pxr_catalog_update.region_terms_of_use_manage
(
    id bigserial,
    terms_of_use_code bigint,
    terms_of_use_version bigint,
    template text,
    application_actor_code bigint NOT NULL,
    application_block_code bigint NOT NULL,
    application_at timestamp(3) NOT NULL,
    is_disabled BOOLEAN NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- 外部キーを追加
ALTER TABLE pxr_catalog_update.actor_approval_manage ADD FOREIGN KEY (actor_manage_id) REFERENCES pxr_catalog_update.actor_manage(id);
ALTER TABLE pxr_catalog_update.join_approval_manage ADD FOREIGN KEY (join_manage_id) REFERENCES pxr_catalog_update.join_manage(id);
ALTER TABLE pxr_catalog_update.alliance_approval_manage ADD FOREIGN KEY (alliance_manage_id) REFERENCES pxr_catalog_update.alliance_manage(id);
ALTER TABLE pxr_catalog_update.region_approval_manage ADD FOREIGN KEY (region_manage_id) REFERENCES pxr_catalog_update.region_manage(id);







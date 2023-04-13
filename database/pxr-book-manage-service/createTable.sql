/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- 外部キーを削除(2回目以降のテーブル作成する時のみ必要)
/*
ALTER TABLE pxr_book_manage.my_condition_data_output_code DROP CONSTRAINT my_condition_data_output_code_book_id_fkey;
ALTER TABLE pxr_book_manage.user_id_cooperate DROP CONSTRAINT user_id_cooperate_book_id_fkey;
ALTER TABLE pxr_book_manage.identification DROP CONSTRAINT identification_book_id_fkey;
ALTER TABLE pxr_book_manage.temporarily_shared_code DROP CONSTRAINT temporarily_shared_code_data_operate_definition_id_fkey;
ALTER TABLE pxr_book_manage.data_operation DROP CONSTRAINT data_operation_book_id_fkey;
ALTER TABLE pxr_book_manage.data_operation DROP CONSTRAINT data_operation_region_use_id_fkey;
ALTER TABLE pxr_book_manage.region_use DROP CONSTRAINT region_use_book_id_fkey;
ALTER TABLE pxr_book_manage.data_operation_data_type DROP CONSTRAINT data_operation_data_type_data_operation_id_fkey;
ALTER TABLE pxr_book_manage.data_operation_data DROP CONSTRAINT data_operation_data_data_operation_id_fkey;
ALTER TABLE pxr_book_manage.tou_consent DROP CONSTRAINT tou_consent_book_id_fkey;
ALTER TABLE pxr_book_manage.terms_of_use_notification_ind DROP CONSTRAINT terms_of_use_notification_ind_book_id_fkey;
ALTER TABLE pxr_book_manage.mcd_output_code_data_file DROP CONSTRAINT mcd_output_code_data_file_mcd_output_code_fkey;
ALTER TABLE pxr_book_manage.terms_of_use_notification_ind DROP CONSTRAINT terms_of_use_notification_ind_terms_of_use_notification_id_fkey;
ALTER TABLE pxr_book_manage.mcd_output_code_actor DROP CONSTRAINT mcd_output_code_actor_mcd_output_code_id_fkey;
ALTER TABLE pxr_book_manage.mcd_output_code_data_type DROP CONSTRAINT mcd_output_code_data_type_mcd_output_code_actor_id_fkey;
ALTER TABLE pxr_book_manage.mcd_alteration DROP CONSTRAINT mcd_alteration_book_id_fkey;
ALTER TABLE pxr_book_manage.mcd_alteration_actor DROP CONSTRAINT mcd_alteration_actor_mcd_alteration_id_fkey;
ALTER TABLE pxr_book_manage.mcd_alteration_data DROP CONSTRAINT mcd_alteration_data_mcd_alteration_actor_id_fkey;
ALTER TABLE pxr_book_manage.share_source_datatype DROP CONSTRAINT share_source_datatype_store_event_notificate_id_fkey;
ALTER TABLE pxr_book_manage.share_source_source DROP CONSTRAINT share_source_source_share_source_datatype_id_fkey;
*/

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- My-Condition-Bookテーブルを作成
DROP TABLE IF EXISTS pxr_book_manage.my_condition_book;
CREATE TABLE IF NOT EXISTS pxr_book_manage.my_condition_book
(
    id bigserial,
    pxr_id varchar(255) NOT NULL,
    status smallint NOT NULL DEFAULT 0,
    book_close_available boolean NOT NULL DEFAULT false,
    book_close_available_at timestamp(3),
    attributes text,
    appendix text,
    force_deletion_flag boolean NOT NULL DEFAULT false,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_manage.my_condition_book IS 'My-Condition-Book';
COMMENT ON COLUMN pxr_book_manage.my_condition_book.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.my_condition_book.pxr_id IS 'PXR-ID';
COMMENT ON COLUMN pxr_book_manage.my_condition_book.status IS 'ステータス';
COMMENT ON COLUMN pxr_book_manage.my_condition_book.book_close_available IS 'Book閉鎖可能フラグ';
COMMENT ON COLUMN pxr_book_manage.my_condition_book.book_close_available_at IS 'Book閉鎖フラグON日時';
COMMENT ON COLUMN pxr_book_manage.my_condition_book.attributes IS '属性';
COMMENT ON COLUMN pxr_book_manage.my_condition_book.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.my_condition_book.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.my_condition_book.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.my_condition_book.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.my_condition_book.updated_at IS '更新日時';

-- 利用者ID連携テーブルを作成
DROP TABLE IF EXISTS pxr_book_manage.user_id_cooperate;
CREATE TABLE IF NOT EXISTS pxr_book_manage.user_id_cooperate
(
    id bigserial,
    book_id bigint NOT NULL,
    actor_catalog_code bigint NOT NULL,
    actor_catalog_version bigint NOT NULL,
    region_catalog_code bigint,
    region_catalog_version bigint,
    app_catalog_code bigint,
    app_catalog_version bigint,
    wf_catalog_code bigint,
    wf_catalog_version bigint,
    user_id varchar(255),
    status smallint NOT NULL DEFAULT 0,
    start_at timestamp(3),
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_manage.user_id_cooperate IS '利用者ID連携';
COMMENT ON COLUMN pxr_book_manage.user_id_cooperate.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.user_id_cooperate.book_id IS 'ブックID';
COMMENT ON COLUMN pxr_book_manage.user_id_cooperate.actor_catalog_code IS 'アクターカタログコード';
COMMENT ON COLUMN pxr_book_manage.user_id_cooperate.actor_catalog_version IS 'アクターカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.user_id_cooperate.region_catalog_code IS 'リージョンカタログコード';
COMMENT ON COLUMN pxr_book_manage.user_id_cooperate.region_catalog_version IS 'リージョンカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.user_id_cooperate.app_catalog_code IS 'アプリケーションカタログコード';
COMMENT ON COLUMN pxr_book_manage.user_id_cooperate.app_catalog_version IS 'アプリケーションカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.user_id_cooperate.wf_catalog_code IS 'ワークフローカタログコード';
COMMENT ON COLUMN pxr_book_manage.user_id_cooperate.wf_catalog_version IS 'ワークフローカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.user_id_cooperate.user_id IS '利用者ID';
COMMENT ON COLUMN pxr_book_manage.user_id_cooperate.status IS 'ステータス';
COMMENT ON COLUMN pxr_book_manage.user_id_cooperate.start_at IS '連携開始日時';
COMMENT ON COLUMN pxr_book_manage.user_id_cooperate.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.user_id_cooperate.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.user_id_cooperate.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.user_id_cooperate.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.user_id_cooperate.updated_at IS '更新日時';

-- 本人性確認事項テーブルを作成
DROP TABLE IF EXISTS pxr_book_manage.identification;
CREATE TABLE IF NOT EXISTS pxr_book_manage.identification
(
    id bigserial,
    book_id bigint NOT NULL,
    identification_code bigint NOT NULL,
    identification_version bigint NOT NULL,
    template text NOT NULL,
    template_hash varchar(255) NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_manage.identification IS '本人性確認事項';
COMMENT ON COLUMN pxr_book_manage.identification.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.identification.book_id IS 'ブックID';
COMMENT ON COLUMN pxr_book_manage.identification.identification_code IS '本人性確認事項カタログコード';
COMMENT ON COLUMN pxr_book_manage.identification.identification_version IS '本人性確認事項カタログバージョン';
COMMENT ON COLUMN pxr_book_manage.identification.template IS 'カタログテンプレート';
COMMENT ON COLUMN pxr_book_manage.identification.template_hash IS 'カタログテンプレートハッシュ';
COMMENT ON COLUMN pxr_book_manage.identification.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.identification.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.identification.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.identification.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.identification.updated_at IS '更新日時';

-- データ操作定義テーブルを作成
DROP TABLE IF EXISTS pxr_book_manage.data_operation;
CREATE TABLE IF NOT EXISTS pxr_book_manage.data_operation
(
    id bigserial,
    book_id bigint NOT NULL,
    region_use_id bigint,
    type varchar(255) NOT NULL,
    operation_catalog_code bigint,
    operation_catalog_version bigint,
    actor_catalog_code bigint NOT NULL,
    actor_catalog_version bigint NOT NULL,
    app_catalog_code bigint,
    app_catalog_version bigint,
    wf_catalog_code bigint,
    wf_catalog_version bigint,
    attributes text,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_manage.data_operation IS 'データ操作定義';
COMMENT ON COLUMN pxr_book_manage.data_operation.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.data_operation.book_id IS 'ブックID';
COMMENT ON COLUMN pxr_book_manage.data_operation.region_use_id IS 'Region利用設定ID';
COMMENT ON COLUMN pxr_book_manage.data_operation.type IS '種別';
COMMENT ON COLUMN pxr_book_manage.data_operation.operation_catalog_code IS 'データ操作カタログコード';
COMMENT ON COLUMN pxr_book_manage.data_operation.operation_catalog_version IS 'データ操作カタログバージョン';
COMMENT ON COLUMN pxr_book_manage.data_operation.actor_catalog_code IS 'アクターカタログコード';
COMMENT ON COLUMN pxr_book_manage.data_operation.actor_catalog_version IS 'アクターカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.data_operation.app_catalog_code IS 'アプリケーションカタログコード';
COMMENT ON COLUMN pxr_book_manage.data_operation.app_catalog_version IS 'アプリケーションカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.data_operation.wf_catalog_code IS 'ワークフローカタログコード';
COMMENT ON COLUMN pxr_book_manage.data_operation.wf_catalog_version IS 'ワークフローカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.data_operation.attributes IS '属性';
COMMENT ON COLUMN pxr_book_manage.data_operation.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.data_operation.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.data_operation.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.data_operation.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.data_operation.updated_at IS '更新日時';

-- データ操作定義データ種テーブルを作成
DROP TABLE IF EXISTS pxr_book_manage.data_operation_data_type;
CREATE TABLE IF NOT EXISTS pxr_book_manage.data_operation_data_type
(
    id bigserial,
    data_operation_id bigint NOT NULL,
    catalog_uuid varchar(255),
    document_catalog_code bigint,
    document_catalog_version bigint,
    event_catalog_code bigint,
    event_catalog_version bigint,
    thing_catalog_code bigint,
    thing_catalog_version bigint,
    consent_flg boolean NOT NULL DEFAULT true,
    attributes text,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_manage.data_operation_data_type IS 'データ操作定義データ種';
COMMENT ON COLUMN pxr_book_manage.data_operation_data_type.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.data_operation_data_type.data_operation_id IS 'データ操作定義ID';
COMMENT ON COLUMN pxr_book_manage.data_operation_data_type.catalog_uuid IS 'カタログUUID';
COMMENT ON COLUMN pxr_book_manage.data_operation_data_type.document_catalog_code IS 'ドキュメントカタログコード';
COMMENT ON COLUMN pxr_book_manage.data_operation_data_type.document_catalog_version IS 'ドキュメントカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.data_operation_data_type.event_catalog_code IS 'イベントカタログコード';
COMMENT ON COLUMN pxr_book_manage.data_operation_data_type.event_catalog_version IS 'イベントカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.data_operation_data_type.thing_catalog_code IS 'モノカタログコード';
COMMENT ON COLUMN pxr_book_manage.data_operation_data_type.thing_catalog_version IS 'モノカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.data_operation_data_type.consent_flg IS '同意フラグ';
COMMENT ON COLUMN pxr_book_manage.data_operation_data_type.attributes IS '属性';
COMMENT ON COLUMN pxr_book_manage.data_operation_data_type.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.data_operation_data_type.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.data_operation_data_type.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.data_operation_data_type.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.data_operation_data_type.updated_at IS '更新日時';

-- データ操作定義データテーブルを生成
DROP TABLE IF EXISTS pxr_book_manage.data_operation_data;
CREATE TABLE IF NOT EXISTS pxr_book_manage.data_operation_data
(
    id bigserial,
    data_operation_id bigint NOT NULL,
    parent_data_id varchar(255),
    type smallint,
    identifier varchar(255),
    attributes text,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_book_manage.data_operation_data IS 'データ操作定義データ';
COMMENT ON COLUMN pxr_book_manage.data_operation_data.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.data_operation_data.data_operation_id IS 'データ操作定義ID';
COMMENT ON COLUMN pxr_book_manage.data_operation_data.parent_data_id IS '親データID';
COMMENT ON COLUMN pxr_book_manage.data_operation_data.type IS 'データ種';
COMMENT ON COLUMN pxr_book_manage.data_operation_data.identifier IS 'データ識別子';
COMMENT ON COLUMN pxr_book_manage.data_operation_data.attributes IS '属性';
COMMENT ON COLUMN pxr_book_manage.data_operation_data.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.data_operation_data.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.data_operation_data.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.data_operation_data.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.data_operation_data.updated_at IS '更新日時';

-- データ操作定義通知管理テーブルを生成
DROP TABLE IF EXISTS pxr_book_manage.data_operation_notification;
CREATE TABLE IF NOT EXISTS pxr_book_manage.data_operation_notification
(
    id bigserial,
    _value bigint NOT NULL,
    _ver bigint,
    status smallint NOT NULL DEFAULT 0,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_book_manage.data_operation_notification IS 'データ操作定義通知管理';
COMMENT ON COLUMN pxr_book_manage.data_operation_notification.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.data_operation_notification._value IS 'コード';
COMMENT ON COLUMN pxr_book_manage.data_operation_notification._ver IS 'バージョン';
COMMENT ON COLUMN pxr_book_manage.data_operation_notification.status IS 'ステータス';
COMMENT ON COLUMN pxr_book_manage.data_operation_notification.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.data_operation_notification.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.data_operation_notification.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.data_operation_notification.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.data_operation_notification.updated_at IS '更新日時';

-- データ操作定義通知個人管理テーブルを生成
DROP TABLE IF EXISTS pxr_book_manage.data_operation_notification_ind;
CREATE TABLE IF NOT EXISTS pxr_book_manage.data_operation_notification_ind
(
    id bigserial,
    data_operation_notification_id bigint NOT NULL,
    book_id bigint NOT NULL,
    status smallint NOT NULL DEFAULT 0,
    last_sent_at timestamp(3),
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_book_manage.data_operation_notification_ind IS 'データ操作定義通知個人管理';
COMMENT ON COLUMN pxr_book_manage.data_operation_notification_ind.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.data_operation_notification_ind.data_operation_notification_id IS 'データ操作定義通知管理ID';
COMMENT ON COLUMN pxr_book_manage.data_operation_notification_ind.book_id IS 'MyConditionBook_ID';
COMMENT ON COLUMN pxr_book_manage.data_operation_notification_ind.status IS 'ステータス';
COMMENT ON COLUMN pxr_book_manage.data_operation_notification_ind.last_sent_at IS '最終送付日時';
COMMENT ON COLUMN pxr_book_manage.data_operation_notification_ind.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.data_operation_notification_ind.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.data_operation_notification_ind.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.data_operation_notification_ind.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.data_operation_notification_ind.updated_at IS '更新日時';

-- Region利用設定テーブルを作成
DROP TABLE IF EXISTS pxr_book_manage.region_use;
CREATE TABLE IF NOT EXISTS pxr_book_manage.region_use
(
    id bigserial,
    book_id bigint NOT NULL,
    code varchar(255) NOT NULL,
    region_catalog_code bigint NOT NULL,
    region_catalog_version bigint NOT NULL,
    attributes text,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_manage.region_use IS 'Region利用設定';
COMMENT ON COLUMN pxr_book_manage.region_use.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.region_use.book_id IS 'ブックID';
COMMENT ON COLUMN pxr_book_manage.region_use.code IS 'コード';
COMMENT ON COLUMN pxr_book_manage.region_use.region_catalog_code IS 'Regionカタログコード';
COMMENT ON COLUMN pxr_book_manage.region_use.region_catalog_version IS 'Regionカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.region_use.attributes IS '属性';
COMMENT ON COLUMN pxr_book_manage.region_use.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.region_use.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.region_use.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.region_use.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.region_use.updated_at IS '更新日時';

-- 一時的データ共有コードテーブルを生成
DROP TABLE IF EXISTS pxr_book_manage.temporarily_shared_code;
CREATE TABLE IF NOT EXISTS pxr_book_manage.temporarily_shared_code
(
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    data_operate_definition_id bigint NOT NULL,
    expire_at timestamp(3) NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE pxr_book_manage.temporarily_shared_code IS '一時的データ共有コード';
COMMENT ON COLUMN pxr_book_manage.temporarily_shared_code.id IS 'ID(コード)';
COMMENT ON COLUMN pxr_book_manage.temporarily_shared_code.data_operate_definition_id IS 'データ操作定義テーブルID';
COMMENT ON COLUMN pxr_book_manage.temporarily_shared_code.expire_at IS '有効期限';
COMMENT ON COLUMN pxr_book_manage.temporarily_shared_code.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.temporarily_shared_code.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.temporarily_shared_code.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.temporarily_shared_code.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.temporarily_shared_code.updated_at IS '更新日時';

-- My-Condition-Data出力コードテーブルを生成
DROP TABLE IF EXISTS pxr_book_manage.my_condition_data_output_code;
CREATE TABLE IF NOT EXISTS pxr_book_manage.my_condition_data_output_code
(
    id bigserial,
    book_id bigint NOT NULL,
    code varchar(255),
    output_type bigint NOT NULL,
    actor_catalog_code bigint,
    actor_catalog_version bigint,
    region_catalog_code bigint,
    region_catalog_version bigint,
    app_catalog_code bigint,
    app_catalog_version bigint,
    wf_catalog_code bigint,
    wf_catalog_version bigint,
    bucket_name varchar(255),
    presigned_url_expire_at timestamp(3),
    presigned_url_status smallint,
    release_cooperate_approval_status smallint,
    release_cooperate_status smallint,
    release_service_cooperate_status smallint,
    is_processing boolean NOT NULL DEFAULT false,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id),
    UNIQUE(code)
);
COMMENT ON TABLE pxr_book_manage.my_condition_data_output_code IS 'My-Condition-Data出力コード';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.book_id IS 'ブックID';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.code IS 'コード';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.output_type IS '出力タイプ';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.actor_catalog_code IS 'アクターカタログコード';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.actor_catalog_version IS 'アクターカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.region_catalog_code IS 'リージョンカタログコード';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.region_catalog_version IS 'リージョンカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.app_catalog_code IS 'アプリケーションカタログコード';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.app_catalog_version IS 'アプリケーションカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.wf_catalog_code IS 'ワークフローカタログコード';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.wf_catalog_version IS 'ワークフローカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.bucket_name IS 'S3バケット名';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.presigned_url_expire_at IS '署名付きURL出力有効期限';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.presigned_url_status IS '署名付きURL出力ステータス';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.release_cooperate_approval_status IS 'Region利用者連携解除承認ステータス';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.release_cooperate_status IS 'Region利用者連携解除ステータス';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.release_service_cooperate_status IS 'Service利用者連携解除ステータス';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.is_processing IS '処理中フラグ';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.my_condition_data_output_code.updated_at IS '更新日時';

-- 利用規約同意テーブルを作成
DROP TABLE IF EXISTS pxr_book_manage.tou_consent;
CREATE TABLE IF NOT EXISTS pxr_book_manage.tou_consent
(
    id bigserial,
    book_id bigint NOT NULL,
    terms_type bigint NOT NULL,
    terms_of_use_code bigint NOT NULL,
    terms_of_use_version bigint NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_manage.tou_consent IS '利用規約同意';
COMMENT ON COLUMN pxr_book_manage.tou_consent.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.tou_consent.book_id IS 'ブックID';
COMMENT ON COLUMN pxr_book_manage.tou_consent.terms_type IS '規約タイプ';
COMMENT ON COLUMN pxr_book_manage.tou_consent.terms_of_use_code IS '利用規約カタログコード';
COMMENT ON COLUMN pxr_book_manage.tou_consent.terms_of_use_version IS '利用規約カタログバージョン';
COMMENT ON COLUMN pxr_book_manage.tou_consent.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.tou_consent.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.tou_consent.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.tou_consent.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.tou_consent.updated_at IS '更新日時';

-- 利用規約更新通知管理テーブルを作成
DROP TABLE IF EXISTS pxr_book_manage.terms_of_use_notification;
CREATE TABLE IF NOT EXISTS pxr_book_manage.terms_of_use_notification
(
    id bigserial,
    terms_type bigint NOT NULL,
    _value bigint NOT NULL,
    _ver bigint,
    status smallint NOT NULL DEFAULT 0,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_manage.terms_of_use_notification IS '利用規約更新通知管理';
COMMENT ON COLUMN pxr_book_manage.terms_of_use_notification.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.terms_of_use_notification._value IS '利用規約カタログコード';
COMMENT ON COLUMN pxr_book_manage.terms_of_use_notification._ver IS '利用規約カタログバージョン';
COMMENT ON COLUMN pxr_book_manage.terms_of_use_notification.status IS 'ステータス';
COMMENT ON COLUMN pxr_book_manage.terms_of_use_notification.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.terms_of_use_notification.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.terms_of_use_notification.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.terms_of_use_notification.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.terms_of_use_notification.updated_at IS '更新日時';

-- 利用規約更新通知個人管理テーブルを作成
DROP TABLE IF EXISTS pxr_book_manage.terms_of_use_notification_ind;
CREATE TABLE IF NOT EXISTS pxr_book_manage.terms_of_use_notification_ind
(
    id bigserial,
    terms_of_use_notification_id bigint NOT NULL,
    book_id bigint NOT NULL,
    status smallint NOT NULL DEFAULT 0,
    last_sent_at timestamp(3),
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_manage.terms_of_use_notification_ind IS '利用規約更新通知個人管理';
COMMENT ON COLUMN pxr_book_manage.terms_of_use_notification_ind.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.terms_of_use_notification_ind.book_id IS 'ブックID';
COMMENT ON COLUMN pxr_book_manage.terms_of_use_notification_ind.status IS 'ステータス';
COMMENT ON COLUMN pxr_book_manage.terms_of_use_notification_ind.last_sent_at IS '最終送付日時';
COMMENT ON COLUMN pxr_book_manage.terms_of_use_notification_ind.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.terms_of_use_notification_ind.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.terms_of_use_notification_ind.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.terms_of_use_notification_ind.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.terms_of_use_notification_ind.updated_at IS '更新日時';

-- 出力データ管理テーブルを作成
DROP TABLE IF EXISTS pxr_book_manage.mcd_output_code_data_file;
CREATE TABLE IF NOT EXISTS pxr_book_manage.mcd_output_code_data_file
(
    id bigserial,
    mcd_output_code_actor_id bigint,
    mcd_output_code varchar(255) NOT NULL,
    actor_catalog_code bigint,
    actor_catalog_version bigint,
    output_data_approval_status smallint,
    output_file_type smallint NOT NULL,
    upload_file_type smallint,
    notification_status smallint,
    file_name varchar(255),
    input_file_preparation_status smallint NOT NULL,
    output_status smallint NOT NULL,
    delete_data_spec smallint NOT NULL,
    delete_status smallint NOT NULL,
    is_processing boolean NOT NULL DEFAULT false,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_manage.mcd_output_code_data_file IS '出力データ管理';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_file.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_file.mcd_output_code_actor_id IS 'My-Condition-出力データ収集アクターID';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_file.mcd_output_code IS 'My-Condition-Data出力コード';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_file.actor_catalog_code IS 'アクターカタログコード';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_file.actor_catalog_version IS 'アクターカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_file.output_data_approval_status IS 'データ出力承認ステータス';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_file.output_file_type IS '出力ファイル種別';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_file.upload_file_type IS 'アップロードファイル種別';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_file.notification_status IS '個別データ通知ステータス';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_file.file_name IS 'ファイル名';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_file.input_file_preparation_status IS '入力ファイル準備ステータス';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_file.delete_data_spec IS '出力ステータス';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_file.delete_status IS '削除ステータス';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_file.is_processing IS '処理中フラグ';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_file.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_file.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_file.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_file.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_file.updated_at IS '更新日時';

-- 出力データ収集アクターテーブルを作成
DROP TABLE IF EXISTS pxr_book_manage.mcd_output_code_actor;
CREATE TABLE IF NOT EXISTS pxr_book_manage.mcd_output_code_actor
(
    id bigserial,
    mcd_output_code_id bigint NOT NULL,
    target_term_start timestamp(3),
    target_term_end timestamp(3),
    actor_catalog_code bigint NOT NULL,
    actor_catalog_version bigint NOT NULL,
    app_catalog_code bigint,
    app_catalog_version bigint,
    wf_catalog_code bigint,
    wf_catalog_version bigint,
    ind_request varchar(255),
    release_cooperate_spec smallint NOT NULL,
    release_cooperate_status smallint NOT NULL,
    return_data_spec smallint NOT NULL DEFAULT 0,
    approval_status smallint NOT NULL,
    message text,
    delete_data_spec smallint NOT NULL DEFAULT 0,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_manage.mcd_output_code_actor IS '出力データ収集アクターテーブル';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.mcd_output_code_id IS 'My-Condition-Data出力コードID';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.target_term_start IS '対象期間From';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.target_term_end IS '対象期間To';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.actor_catalog_code IS 'アクターカタログコード';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.actor_catalog_version IS 'アクターカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.app_catalog_code IS 'アプリケーションカタログコード';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.app_catalog_version IS 'アプリケーションカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.wf_catalog_code IS 'ワークフローカタログコード';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.wf_catalog_version IS 'ワークフローカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.ind_request IS '個別リクエスト';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.release_cooperate_spec IS '利用者ID連携解除指定';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.release_cooperate_status IS '利用者ID連携解除ステータス';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.return_data_spec IS 'データ返却指定';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.approval_status IS '承認ステータス';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.message IS '対応予定時期・対応内容/否認理由';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.delete_data_spec IS 'データ削除指定';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_actor.updated_at IS '更新日時';

-- 出力データタイプテーブルを作成
DROP TABLE IF EXISTS pxr_book_manage.mcd_output_code_data_type;
CREATE TABLE IF NOT EXISTS pxr_book_manage.mcd_output_code_data_type
(
    id bigserial,
    mcd_output_code_actor_id bigint NOT NULL,
    document_catalog_code bigint,
    document_catalog_version bigint,
    document_id varchar(255),
    event_catalog_code bigint,
    event_catalog_version bigint,
    event_id varchar(255),
    thing_catalog_code bigint,
    thing_catalog_version bigint,
    thing_id varchar(255),
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_manage.mcd_output_code_data_type IS '出力データタイプ';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_type.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_type.mcd_output_code_actor_id IS '出力データ収集アクターID';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_type.document_catalog_code IS 'ドキュメントカタログコード';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_type.document_catalog_version IS 'ドキュメントカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_type.document_id IS 'ドキュメント識別子';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_type.event_catalog_code IS 'イベントカタログコード';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_type.event_catalog_version IS 'イベントカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_type.event_id IS 'イベント識別子';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_type.thing_catalog_code IS 'モノカタログコード';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_type.thing_catalog_version IS 'モノカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_type.thing_id IS 'モノ識別子';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_type.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_type.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_type.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_type.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.mcd_output_code_data_type.updated_at IS '更新日時';

-- My-Condition-Data変更請求テーブルを生成
DROP TABLE IF EXISTS pxr_book_manage.mcd_alteration;
CREATE TABLE IF NOT EXISTS pxr_book_manage.mcd_alteration
(
    id bigserial,
    book_id bigint NOT NULL,
    actor_catalog_code bigint,
    actor_catalog_version bigint,
    region_catalog_code bigint,
    region_catalog_version bigint,
    alteration text,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_book_manage.mcd_alteration IS 'My-Condition-Data変更請求テーブル';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration.book_id IS 'ブックID';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration.actor_catalog_code IS 'アクターカタログコード';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration.actor_catalog_version IS 'アクターカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration.region_catalog_code IS 'リージョンカタログコード';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration.region_catalog_version IS 'リージョンカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration.alteration IS '変更内容';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration.updated_at IS '更新日時';

-- 利用者データ変更アクターテーブルを作成
DROP TABLE IF EXISTS pxr_book_manage.mcd_alteration_actor;
CREATE TABLE IF NOT EXISTS pxr_book_manage.mcd_alteration_actor
(
    id bigserial,
    mcd_alteration_id bigint NOT NULL,
    target_term_start timestamp(3),
    target_term_end timestamp(3),
    actor_catalog_code bigint NOT NULL,
    actor_catalog_version bigint NOT NULL,
    app_catalog_code bigint,
    app_catalog_version bigint,
    wf_catalog_code bigint,
    wf_catalog_version bigint,
    alteration text,
    approval_status smallint NOT NULL,
    message text,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_manage.mcd_alteration_actor IS '利用者データ変更アクターテーブル';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_actor.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_actor.mcd_alteration_id IS 'My-Condition-Data変更請求ID';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_actor.target_term_start IS '対象期間From';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_actor.target_term_end IS '対象期間To';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_actor.actor_catalog_code IS 'アクターカタログコード';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_actor.actor_catalog_version IS 'アクターカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_actor.app_catalog_code IS 'アプリケーションカタログコード';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_actor.app_catalog_version IS 'アプリケーションカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_actor.wf_catalog_code IS 'ワークフローカタログコード';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_actor.wf_catalog_version IS 'ワークフローカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_actor.alteration IS '変更内容';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_actor.approval_status IS '承認ステータス';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_actor.message IS '対応予定時期・対応内容/否認理由';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_actor.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_actor.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_actor.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_actor.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_actor.updated_at IS '更新日時';

-- 変更対象データテーブルを作成
DROP TABLE IF EXISTS pxr_book_manage.mcd_alteration_data;
CREATE TABLE IF NOT EXISTS pxr_book_manage.mcd_alteration_data
(
    id bigserial,
    mcd_alteration_actor_id bigint NOT NULL,
    document_catalog_code bigint,
    document_catalog_version bigint,
    document_id varchar(255),
    event_catalog_code bigint,
    event_catalog_version bigint,
    event_id varchar(255),
    thing_catalog_code bigint,
    thing_catalog_version bigint,
    thing_id varchar(255),
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_manage.mcd_alteration_data IS '変更対象データ';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_data.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_data.mcd_alteration_actor_id IS '利用者データ変更アクターID';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_data.document_catalog_code IS 'ドキュメントカタログコード';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_data.document_catalog_version IS 'ドキュメントカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_data.document_id IS 'ドキュメント識別子';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_data.event_catalog_code IS 'イベントカタログコード';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_data.event_catalog_version IS 'イベントカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_data.event_id IS 'イベント識別子';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_data.thing_catalog_code IS 'モノカタログコード';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_data.thing_catalog_version IS 'モノカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_data.thing_id IS 'モノ識別子';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_data.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_data.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_data.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_data.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.mcd_alteration_data.updated_at IS '更新日時';

-- 蓄積イベント通知定義テーブルを作成
DROP TABLE IF EXISTS pxr_book_manage.store_event_notificate;
CREATE TABLE IF NOT EXISTS pxr_book_manage.store_event_notificate
(
    id bigserial NOT NULL,
    notificate_type varchar(255),
    store_event_notificate_catalog_code bigint,
    store_event_notificate_catalog_version bigint,
    share_catalog_code bigint,
    share_catalog_version bigint,
    share_uuid varchar(255),
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_manage.store_event_notificate IS '蓄積イベント通知定義';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate.notificate_type IS '送信種別';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate.store_event_notificate_catalog_code IS '蓄積イベント通知/共有トリガー定義カタログコード';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate.store_event_notificate_catalog_version IS '蓄積イベント通知/共有トリガー定義カタログバージョン';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate.share_catalog_code IS '共有定義カタログコード';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate.share_catalog_version IS '共有定義カタログバージョン';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate.share_uuid IS '共有定義UUID';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate.is_disabled IS '削除フラグ（削除済：true）';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate.updated_at IS '更新日時';

-- 共有元指定データ種テーブルを作成
DROP TABLE IF EXISTS pxr_book_manage.share_source_datatype;
CREATE TABLE IF NOT EXISTS pxr_book_manage.share_source_datatype
(
    id bigserial NOT NULL,
    store_event_notificate_id bigint NOT NULL,
    share_catalog_code bigint,
    share_catalog_version bigint,
    share_uuid varchar(255),
    document_catalog_code bigint,
    document_catalog_version bigint,
    event_catalog_code bigint,
    event_catalog_version bigint,
    thing_catalog_code bigint,
    thing_catalog_version bigint,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_manage.share_source_datatype IS '共有元指定データ種';
COMMENT ON COLUMN pxr_book_manage.share_source_datatype.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.share_source_datatype.store_event_notificate_id IS '蓄積イベント通知定義ID';
COMMENT ON COLUMN pxr_book_manage.share_source_datatype.share_catalog_code IS '共有定義カタログコード';
COMMENT ON COLUMN pxr_book_manage.share_source_datatype.share_catalog_version IS '共有定義カタログバージョン';
COMMENT ON COLUMN pxr_book_manage.share_source_datatype.share_uuid IS '共有定義UUID';
COMMENT ON COLUMN pxr_book_manage.share_source_datatype.document_catalog_code IS 'ドキュメントカタログコード';
COMMENT ON COLUMN pxr_book_manage.share_source_datatype.document_catalog_version IS 'ドキュメントカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.share_source_datatype.event_catalog_code IS 'イベントカタログコード';
COMMENT ON COLUMN pxr_book_manage.share_source_datatype.event_catalog_version IS 'イベントカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.share_source_datatype.thing_catalog_code IS 'モノカタログコード';
COMMENT ON COLUMN pxr_book_manage.share_source_datatype.thing_catalog_version IS 'モノカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.share_source_datatype.is_disabled IS '削除フラグ（削除済：true）';
COMMENT ON COLUMN pxr_book_manage.share_source_datatype.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.share_source_datatype.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.share_source_datatype.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.share_source_datatype.updated_at IS '更新日時';

-- 共有元指定共有元テーブルを作成
DROP TABLE IF EXISTS pxr_book_manage.share_source_source;
CREATE TABLE IF NOT EXISTS pxr_book_manage.share_source_source
(
    id bigserial NOT NULL,
    share_source_datatype_id bigint NOT NULL,
    actor_catalog_code bigint,
    actor_catalog_version bigint,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_manage.share_source_source IS '共有元指定共有元';
COMMENT ON COLUMN pxr_book_manage.share_source_source.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.share_source_source.share_source_datatype_id IS '共有元指定データ種ID';
COMMENT ON COLUMN pxr_book_manage.share_source_source.actor_catalog_code IS 'アクターカタログコード';
COMMENT ON COLUMN pxr_book_manage.share_source_source.actor_catalog_version IS 'アクターカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.share_source_source.is_disabled IS '削除フラグ（削除済：true）';
COMMENT ON COLUMN pxr_book_manage.share_source_source.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.share_source_source.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.share_source_source.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.share_source_source.updated_at IS '更新日時';

-- 蓄積イベント通知履歴テーブルを作成
DROP TABLE IF EXISTS pxr_book_manage.store_event_notificate_history;
CREATE TABLE IF NOT EXISTS pxr_book_manage.store_event_notificate_history
(
    id bigserial NOT NULL,
    notificate_type varchar(255),
    process_type varchar(255),
    user_id varchar(255),
    data_id varchar(255),
    document_catalog_code bigint,
    document_catalog_version bigint,
    event_catalog_code bigint,
    event_catalog_version bigint,
    thing_catalog_code bigint,
    thing_catalog_version bigint,
    share_source_actor_catalog_code bigint,
    share_source_actor_catalog_version bigint,
    share_source_app_catalog_code bigint,
    share_source_app_catalog_version bigint,
    share_source_wf_catalog_code bigint,
    share_source_wf_catalog_version bigint,
    share_target_actor_catalog_code bigint,
    share_target_actor_catalog_version bigint,
    share_target_app_catalog_code bigint,
    share_target_app_catalog_version bigint,
    share_target_wf_catalog_code bigint,
    share_target_wf_catalog_version bigint,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_manage.store_event_notificate_history IS '蓄積イベント通知履歴';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.notificate_type IS '送信種別';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.process_type IS '処理種別';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.user_id IS '利用者ID';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.data_id IS 'データID';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.document_catalog_code IS 'ドキュメント種別カタログコード';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.document_catalog_version IS 'ドキュメント種別カタログバージョン';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.event_catalog_code IS 'イベント種別カタログコード';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.event_catalog_version IS 'イベント種別カタログバージョン';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.thing_catalog_code IS 'モノ種別カタログコード';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.thing_catalog_version IS 'モノ種別カタログバージョン';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.share_source_actor_catalog_code IS '共有元アクターカタログコード';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.share_source_actor_catalog_version IS '共有元アクターカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.share_source_app_catalog_code IS '共有元アプリケーションカタログコード';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.share_source_app_catalog_version IS '共有元アプリケーションカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.share_source_wf_catalog_code IS '共有元ワークフローカタログコード';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.share_source_wf_catalog_version IS '共有元ワークフローカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.share_target_actor_catalog_code IS '共有先アクターカタログコード';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.share_target_actor_catalog_version IS '共有先アクターカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.share_target_app_catalog_code IS '共有先アプリケーションカタログコード';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.share_target_app_catalog_version IS '共有先アプリケーションカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.share_target_wf_catalog_code IS '共有先ワークフローカタログコード';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.share_target_wf_catalog_version IS '共有先ワークフローカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.is_disabled IS '削除フラグ（削除済：true）';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.store_event_notificate_history.updated_at IS '更新日時';

-- 終了済Regionテーブルテーブルを生成
DROP TABLE IF EXISTS pxr_book_manage.stopped_region;
CREATE TABLE IF NOT EXISTS pxr_book_manage.stopped_region
(
    id bigserial,
    actor_catalog_code bigint NOT NULL,
    actor_catalog_version bigint NOT NULL,
    region_catalog_code bigint NOT NULL,
    region_catalog_version bigint NOT NULL,
    closed_at  timestamp(3),
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_book_manage.stopped_region IS '終了済Region';
COMMENT ON COLUMN pxr_book_manage.stopped_region.id IS 'ID';
COMMENT ON COLUMN pxr_book_manage.stopped_region.actor_catalog_code IS 'アクターカタログコード';
COMMENT ON COLUMN pxr_book_manage.stopped_region.actor_catalog_version IS 'アクターカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.stopped_region.region_catalog_code IS 'リージョンカタログコード';
COMMENT ON COLUMN pxr_book_manage.stopped_region.region_catalog_version IS 'リージョンカタログバージョン';
COMMENT ON COLUMN pxr_book_manage.stopped_region.closed_at IS '終了日時';
COMMENT ON COLUMN pxr_book_manage.stopped_region.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_manage.stopped_region.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_manage.stopped_region.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_manage.stopped_region.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_manage.stopped_region.updated_at IS '更新日時';

-- 外部キーを追加
ALTER TABLE pxr_book_manage.temporarily_shared_code ADD FOREIGN KEY (data_operate_definition_id) REFERENCES pxr_book_manage.data_operation(id);
ALTER TABLE pxr_book_manage.user_id_cooperate ADD FOREIGN KEY (book_id) REFERENCES pxr_book_manage.my_condition_book(id) ON DELETE CASCADE;
ALTER TABLE pxr_book_manage.identification ADD FOREIGN KEY (book_id) REFERENCES pxr_book_manage.my_condition_book(id) ON DELETE CASCADE;
ALTER TABLE pxr_book_manage.tou_consent ADD FOREIGN KEY (book_id) REFERENCES pxr_book_manage.my_condition_book(id) ON DELETE CASCADE;
ALTER TABLE pxr_book_manage.terms_of_use_notification_ind ADD FOREIGN KEY (terms_of_use_notification_id) REFERENCES pxr_book_manage.terms_of_use_notification(id);
ALTER TABLE pxr_book_manage.terms_of_use_notification_ind ADD FOREIGN KEY (book_id) REFERENCES pxr_book_manage.my_condition_book(id) ON DELETE CASCADE;
ALTER TABLE pxr_book_manage.data_operation ADD FOREIGN KEY (book_id) REFERENCES pxr_book_manage.my_condition_book(id) ON DELETE CASCADE;
ALTER TABLE pxr_book_manage.data_operation ADD FOREIGN KEY (region_use_id) REFERENCES pxr_book_manage.region_use(id);
ALTER TABLE pxr_book_manage.data_operation_data_type ADD FOREIGN KEY (data_operation_id) REFERENCES pxr_book_manage.data_operation(id) ON DELETE CASCADE;
ALTER TABLE pxr_book_manage.data_operation_data ADD FOREIGN KEY (data_operation_id) REFERENCES pxr_book_manage.data_operation(id);
ALTER TABLE pxr_book_manage.region_use ADD FOREIGN KEY (book_id) REFERENCES pxr_book_manage.my_condition_book(id) ON DELETE CASCADE;
ALTER TABLE pxr_book_manage.my_condition_data_output_code ADD FOREIGN KEY (book_id) REFERENCES pxr_book_manage.my_condition_book(id) ON DELETE CASCADE;
ALTER TABLE pxr_book_manage.mcd_output_code_data_file ADD FOREIGN KEY (mcd_output_code) REFERENCES pxr_book_manage.my_condition_data_output_code(code) ON DELETE CASCADE;
ALTER TABLE pxr_book_manage.mcd_output_code_actor ADD FOREIGN KEY (mcd_output_code_id) REFERENCES pxr_book_manage.my_condition_data_output_code(id) ON DELETE CASCADE;
ALTER TABLE pxr_book_manage.mcd_output_code_data_type ADD FOREIGN KEY (mcd_output_code_actor_id) REFERENCES pxr_book_manage.mcd_output_code_actor(id) ON DELETE CASCADE;
ALTER TABLE pxr_book_manage.mcd_alteration ADD FOREIGN KEY (book_id) REFERENCES pxr_book_manage.my_condition_book(id);
ALTER TABLE pxr_book_manage.mcd_alteration_actor ADD FOREIGN KEY (mcd_alteration_id) REFERENCES pxr_book_manage.mcd_alteration(id);
ALTER TABLE pxr_book_manage.mcd_alteration_data ADD FOREIGN KEY (mcd_alteration_actor_id) REFERENCES pxr_book_manage.mcd_alteration_actor(id);
ALTER TABLE pxr_book_manage.share_source_datatype ADD FOREIGN KEY (store_event_notificate_id) REFERENCES pxr_book_manage.store_event_notificate(id);
ALTER TABLE pxr_book_manage.share_source_source ADD FOREIGN KEY (share_source_datatype_id) REFERENCES pxr_book_manage.share_source_datatype(id);

-- ユニーク制約を追加
ALTER TABLE pxr_book_manage.data_operation ADD UNIQUE(book_id, operation_catalog_code);







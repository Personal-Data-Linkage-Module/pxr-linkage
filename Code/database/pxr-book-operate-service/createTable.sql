/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- 外部キーを削除(2回目以降のテーブル作成する時のみ必要)
/*
ALTER TABLE pxr_book_operate.cmatrix_2_n_relation DROP CONSTRAINT cmatrix_2_n_relation_cmatrix_2n_id_fkey;
ALTER TABLE pxr_book_operate.cmatrix_2_n_relation DROP CONSTRAINT cmatrix_2_n_relation_cmatrix_event_id_fkey;
ALTER TABLE pxr_book_operate.cmatrix_floating_column DROP CONSTRAINT cmatrix_floating_column_cmatrix_thing_id_fkey;
ALTER TABLE pxr_book_operate.cmatrix_thing DROP CONSTRAINT cmatrix_thing_cmatrix_event_id_fkey;
ALTER TABLE pxr_book_operate.binary_file DROP CONSTRAINT binary_file_thing_id_fkey;
ALTER TABLE pxr_book_operate.document DROP CONSTRAINT document_my_condition_book_id_fkey;
ALTER TABLE pxr_book_operate.shared_access_log DROP CONSTRAINT shared_access_log_my_condition_book_id_fkey;
ALTER TABLE pxr_book_operate.shared_access_log_data_type DROP CONSTRAINT shared_access_log_data_type_share_access_log_id_fkey;
ALTER TABLE pxr_book_operate.thing DROP CONSTRAINT thing_event_id_fkey;
ALTER TABLE pxr_book_operate.event DROP CONSTRAINT event_my_condition_book_id_fkey;
ALTER TABLE pxr_book_operate.share_trigger_waiting DROP CONSTRAINT share_trigger_waiting_share_status_id_fkey;
*/

-- My-Condition-Bookテーブルを作成
DROP TABLE IF EXISTS pxr_book_operate.my_condition_book;
CREATE TABLE IF NOT EXISTS pxr_book_operate.my_condition_book
(
    id bigserial,
    user_id varchar(255) NOT NULL,
    actor_catalog_code bigint NOT NULL,
    actor_catalog_version bigint NOT NULL,
    region_catalog_code bigint,
    region_catalog_version bigint,
    app_catalog_code bigint,
    app_catalog_version bigint,
    wf_catalog_code bigint,
    wf_catalog_version bigint,
    open_start_at timestamp(3) NOT NULL,
    identify_code varchar(255),
    attributes text,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_operate.my_condition_book IS 'My-Condition-Book';
COMMENT ON COLUMN pxr_book_operate.my_condition_book.id IS 'ID';
COMMENT ON COLUMN pxr_book_operate.my_condition_book.user_id IS '利用者ID';
COMMENT ON COLUMN pxr_book_operate.my_condition_book.actor_catalog_code IS 'アクターカタログコード';
COMMENT ON COLUMN pxr_book_operate.my_condition_book.actor_catalog_version IS 'アクターカタログバージョン';
COMMENT ON COLUMN pxr_book_operate.my_condition_book.region_catalog_code IS 'リージョンカタログコード';
COMMENT ON COLUMN pxr_book_operate.my_condition_book.region_catalog_version IS 'リージョンカタログバージョン';
COMMENT ON COLUMN pxr_book_operate.my_condition_book.app_catalog_code IS 'アプリケーションカタログコード';
COMMENT ON COLUMN pxr_book_operate.my_condition_book.app_catalog_version IS 'アプリケーションカタログバージョン';
COMMENT ON COLUMN pxr_book_operate.my_condition_book.wf_catalog_code IS 'ワークフローカタログコード';
COMMENT ON COLUMN pxr_book_operate.my_condition_book.wf_catalog_version IS 'ワークフローカタログバージョン';
COMMENT ON COLUMN pxr_book_operate.my_condition_book.open_start_at IS '開設日時';
COMMENT ON COLUMN pxr_book_operate.my_condition_book.identify_code IS '本人性確認コード';
COMMENT ON COLUMN pxr_book_operate.my_condition_book.attributes IS '属性';
COMMENT ON COLUMN pxr_book_operate.my_condition_book.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_operate.my_condition_book.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_operate.my_condition_book.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_operate.my_condition_book.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_operate.my_condition_book.updated_at IS '更新日時';

-- 共有アクセスログテーブルを作成
DROP TABLE IF EXISTS pxr_book_operate.shared_access_log;
CREATE TABLE IF NOT EXISTS pxr_book_operate.shared_access_log
(
    id bigserial,
    my_condition_book_id bigint NOT NULL,
    log_identifier varchar(255) NOT NULL,
    user_name varchar(255) NOT NULL,
    data_type smallint NOT NULL,
    share_catalog_code bigint,
    req_actor_catalog_code bigint NOT NULL,
    req_actor_catalog_version bigint NOT NULL,
    req_block_catalog_code bigint NOT NULL,
    req_block_catalog_version bigint NOT NULL,
    access_at timestamp(3) NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_operate.shared_access_log IS '共有アクセスログ';
COMMENT ON COLUMN pxr_book_operate.shared_access_log.id IS 'ID';
COMMENT ON COLUMN pxr_book_operate.shared_access_log.my_condition_book_id IS 'My-Condition-Book_ID';
COMMENT ON COLUMN pxr_book_operate.shared_access_log.log_identifier IS '共有ログ識別子';
COMMENT ON COLUMN pxr_book_operate.shared_access_log.user_name IS 'ユーザ名';
COMMENT ON COLUMN pxr_book_operate.shared_access_log.data_type IS 'データ共有タイプ';
COMMENT ON COLUMN pxr_book_operate.shared_access_log.share_catalog_code IS '状態共有機能カタログコード';
COMMENT ON COLUMN pxr_book_operate.shared_access_log.req_actor_catalog_code IS '要求Actorカタログコード';
COMMENT ON COLUMN pxr_book_operate.shared_access_log.req_actor_catalog_version IS '要求Actorカタログバージョン';
COMMENT ON COLUMN pxr_book_operate.shared_access_log.req_block_catalog_code IS '要求Blockカタログコード';
COMMENT ON COLUMN pxr_book_operate.shared_access_log.req_block_catalog_version IS '要求Blockカタログバージョン';
COMMENT ON COLUMN pxr_book_operate.shared_access_log.access_at IS 'アクセス日時';
COMMENT ON COLUMN pxr_book_operate.shared_access_log.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_operate.shared_access_log.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_operate.shared_access_log.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_operate.shared_access_log.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_operate.shared_access_log.updated_at IS '更新日時';

-- 共有アクセスログデータ種テーブルを作成
DROP TABLE IF EXISTS pxr_book_operate.shared_access_log_data_type;
CREATE TABLE IF NOT EXISTS pxr_book_operate.shared_access_log_data_type
(
    id bigserial,
    share_access_log_id  bigint NOT NULL,
    data_type smallint NOT NULL,
    data_type_catalog_code bigint NOT NULL,
    data_type_catalog_version bigint NOT NULL,
    attributes text,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_operate.shared_access_log_data_type IS '共有アクセスログ';
COMMENT ON COLUMN pxr_book_operate.shared_access_log_data_type.id IS 'ID';
COMMENT ON COLUMN pxr_book_operate.shared_access_log_data_type.share_access_log_id IS '共有アクセスログID';
COMMENT ON COLUMN pxr_book_operate.shared_access_log_data_type.data_type IS 'データ種';
COMMENT ON COLUMN pxr_book_operate.shared_access_log_data_type.data_type_catalog_code IS 'データ種カタログコード';
COMMENT ON COLUMN pxr_book_operate.shared_access_log_data_type.data_type_catalog_version IS 'データ種カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.shared_access_log_data_type.attributes IS '属性';
COMMENT ON COLUMN pxr_book_operate.shared_access_log_data_type.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_operate.shared_access_log_data_type.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_operate.shared_access_log_data_type.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_operate.shared_access_log_data_type.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_operate.shared_access_log_data_type.updated_at IS '更新日時';

-- イベントテーブルを作成
DROP TABLE IF EXISTS pxr_book_operate.event;
CREATE TABLE IF NOT EXISTS pxr_book_operate.event
(
    id bigserial,
    my_condition_book_id bigint NOT NULL,
    source_id varchar(255),
    event_identifier varchar(255) NOT NULL,
    event_catalog_code bigint NOT NULL,
    event_catalog_version bigint NOT NULL,
    event_start_at timestamp(3),
    event_end_at timestamp(3),
    event_outbreak_position varchar(255),
    event_actor_code bigint NOT NULL,
    event_actor_version bigint NOT NULL,
    wf_catalog_code bigint,
    wf_catalog_version bigint,
    wf_role_code bigint,
    wf_role_version bigint,
    wf_staff_identifier varchar(255),
    app_catalog_code bigint,
    app_catalog_version bigint,
    template text,
    attributes text,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_operate.event IS 'イベント';
COMMENT ON COLUMN pxr_book_operate.event.id IS 'ID';
COMMENT ON COLUMN pxr_book_operate.event.my_condition_book_id IS 'my-condition-bookID';
COMMENT ON COLUMN pxr_book_operate.event.source_id IS 'ソースID';
COMMENT ON COLUMN pxr_book_operate.event.event_identifier IS 'イベント識別子';
COMMENT ON COLUMN pxr_book_operate.event.event_catalog_code IS 'イベント種別カタログコード';
COMMENT ON COLUMN pxr_book_operate.event.event_catalog_version IS 'イベント種別カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.event.event_start_at IS 'イベント開始時間';
COMMENT ON COLUMN pxr_book_operate.event.event_end_at IS 'イベント終了時間';
COMMENT ON COLUMN pxr_book_operate.event.event_outbreak_position IS 'イベント発生位置';
COMMENT ON COLUMN pxr_book_operate.event.event_actor_code IS 'イベントを発生させたアクター識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.event.event_actor_version IS 'イベントを発生させたアクター識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.event.wf_catalog_code IS 'ワークフロー識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.event.wf_catalog_version IS 'ワークフロー識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.event.wf_role_code IS 'ワークフローロール識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.event.wf_role_version IS 'ワークフローロール識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.event.wf_staff_identifier IS 'ワークフロー職員識別子';
COMMENT ON COLUMN pxr_book_operate.event.app_catalog_code IS 'アプリケーション識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.event.app_catalog_version IS 'アプリケーション識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.event.template IS 'テンプレート';
COMMENT ON COLUMN pxr_book_operate.event.attributes IS '属性';
COMMENT ON COLUMN pxr_book_operate.event.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_operate.event.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_operate.event.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_operate.event.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_operate.event.updated_at IS '更新日時';

-- モノテーブルを作成
DROP TABLE IF EXISTS pxr_book_operate.thing;
CREATE TABLE IF NOT EXISTS pxr_book_operate.thing
(
    id bigserial,
    event_id bigint NOT NULL,
    source_id varchar(255),
    thing_identifier varchar(255) NOT NULL,
    thing_catalog_code bigint NOT NULL,
    thing_catalog_version bigint NOT NULL,
    thing_actor_code bigint NOT NULL,
    thing_actor_version bigint NOT NULL,
    wf_catalog_code bigint,
    wf_catalog_version bigint,
    wf_role_code bigint,
    wf_role_version bigint,
    wf_staff_identifier varchar(255),
    app_catalog_code bigint,
    app_catalog_version bigint,
    template text,
    attributes text,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_operate.thing IS 'モノ';
COMMENT ON COLUMN pxr_book_operate.thing.id IS 'ID';
COMMENT ON COLUMN pxr_book_operate.thing.event_id IS 'イベントID';
COMMENT ON COLUMN pxr_book_operate.thing.source_id IS 'ソースID';
COMMENT ON COLUMN pxr_book_operate.thing.thing_identifier IS 'モノ識別子';
COMMENT ON COLUMN pxr_book_operate.thing.thing_catalog_code IS 'モノ種別カタログコード';
COMMENT ON COLUMN pxr_book_operate.thing.thing_catalog_version IS 'モノ種別カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.thing.thing_actor_code IS 'モノを発生させたアクター識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.thing.thing_actor_version IS 'モノを発生させたアクター識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.thing.wf_catalog_code IS 'ワークフロー識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.thing.wf_catalog_version IS 'ワークフロー識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.thing.wf_role_code IS 'ワークフローロール識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.thing.wf_role_version IS 'ワークフローロール識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.thing.wf_staff_identifier IS 'ワークフロー職員識別子';
COMMENT ON COLUMN pxr_book_operate.thing.app_catalog_code IS 'アプリケーション識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.thing.app_catalog_version IS 'アプリケーション識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.thing.template IS 'テンプレート';
COMMENT ON COLUMN pxr_book_operate.thing.attributes IS '属性';
COMMENT ON COLUMN pxr_book_operate.thing.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_operate.thing.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_operate.thing.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_operate.thing.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_operate.thing.updated_at IS '更新日時';

-- ドキュメントテーブルを作成
DROP TABLE IF EXISTS pxr_book_operate.document;
CREATE TABLE IF NOT EXISTS pxr_book_operate.document
(
    id bigserial,
    my_condition_book_id bigint NOT NULL,
    source_id varchar(255),
    doc_identifier varchar(255) NOT NULL,
    doc_catalog_code bigint NOT NULL,
    doc_catalog_version bigint NOT NULL,
    doc_create_at timestamp(3),
    doc_actor_code bigint NOT NULL,
    doc_actor_version bigint NOT NULL,
    wf_catalog_code bigint,
    wf_catalog_version bigint,
    wf_role_code bigint,
    wf_role_version bigint,
    wf_staff_identifier varchar(255),
    app_catalog_code bigint,
    app_catalog_version bigint,
    template text,
    attributes text,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_operate.document IS 'ドキュメント';
COMMENT ON COLUMN pxr_book_operate.document.id IS 'ID';
COMMENT ON COLUMN pxr_book_operate.document.my_condition_book_id IS 'My-Condition-Book-ID';
COMMENT ON COLUMN pxr_book_operate.document.source_id IS 'ソースID';
COMMENT ON COLUMN pxr_book_operate.document.doc_identifier IS 'ドキュメント識別子';
COMMENT ON COLUMN pxr_book_operate.document.doc_catalog_code IS 'ドキュメント種別カタログコード';
COMMENT ON COLUMN pxr_book_operate.document.doc_catalog_version IS 'ドキュメント種別カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.document.doc_create_at IS 'ドキュメント作成時間';
COMMENT ON COLUMN pxr_book_operate.document.doc_actor_code IS 'ドキュメントを発生させたアクター識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.document.doc_actor_version IS 'ドキュメントを発生させたアクター識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.document.wf_catalog_code IS 'ワークフロー識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.document.wf_catalog_version IS 'ワークフロー識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.document.wf_role_code IS 'ワークフローロール識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.document.wf_role_version IS 'ワークフローロール識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.document.wf_staff_identifier IS 'ワークフロー職員識別子';
COMMENT ON COLUMN pxr_book_operate.document.app_catalog_code IS 'アプリケーション識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.document.app_catalog_version IS 'アプリケーション識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.document.template IS 'テンプレート';
COMMENT ON COLUMN pxr_book_operate.document.attributes IS '属性';
COMMENT ON COLUMN pxr_book_operate.document.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_operate.document.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_operate.document.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_operate.document.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_operate.document.updated_at IS '更新日時';

-- ドキュメントイベントセットリレーションテーブルを作成
DROP TABLE IF EXISTS pxr_book_operate.document_event_set_relation;
CREATE TABLE IF NOT EXISTS pxr_book_operate.document_event_set_relation
(
    id bigserial,
    document_id bigint NOT NULL,
    title varchar(255) NOT NULL,
    attributes text,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_operate.document_event_set_relation IS 'ドキュメントイベントセットリレーション';
COMMENT ON COLUMN pxr_book_operate.document_event_set_relation.id IS 'ID';
COMMENT ON COLUMN pxr_book_operate.document_event_set_relation.document_id IS 'ドキュメントID';
COMMENT ON COLUMN pxr_book_operate.document_event_set_relation.title IS 'タイトル';
COMMENT ON COLUMN pxr_book_operate.document_event_set_relation.attributes IS '属性';
COMMENT ON COLUMN pxr_book_operate.document_event_set_relation.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_operate.document_event_set_relation.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_operate.document_event_set_relation.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_operate.document_event_set_relation.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_operate.document_event_set_relation.updated_at IS '更新日時';

-- イベントセットイベントリレーションテーブルを作成
DROP TABLE IF EXISTS pxr_book_operate.event_set_event_relation;
CREATE TABLE IF NOT EXISTS pxr_book_operate.event_set_event_relation
(
    id bigserial,
    event_set_id bigint NOT NULL,
    event_id bigint NOT NULL,
    source_id_at_created varchar(255),
    attributes text,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_operate.event_set_event_relation IS 'イベントセットイベントリレーション';
COMMENT ON COLUMN pxr_book_operate.event_set_event_relation.id IS 'ID';
COMMENT ON COLUMN pxr_book_operate.event_set_event_relation.event_set_id IS 'イベントセットID';
COMMENT ON COLUMN pxr_book_operate.event_set_event_relation.event_id IS 'イベントID';
COMMENT ON COLUMN pxr_book_operate.event_set_event_relation.source_id_at_created IS '登録時ソースID ';
COMMENT ON COLUMN pxr_book_operate.event_set_event_relation.attributes IS '属性';
COMMENT ON COLUMN pxr_book_operate.event_set_event_relation.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_operate.event_set_event_relation.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_operate.event_set_event_relation.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_operate.event_set_event_relation.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_operate.event_set_event_relation.updated_at IS '更新日時';

-- バイナリファイルテーブルを作成
DROP TABLE IF EXISTS pxr_book_operate.binary_file;
CREATE TABLE IF NOT EXISTS pxr_book_operate.binary_file
(
    id bigserial,
    thing_id bigint NOT NULL,
    file_path varchar(255) NOT NULL,
    mime_type varchar(255) NOT NULL,
    file_size bigint NOT NULL,
    file_hash varchar(255) NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_operate.binary_file IS 'バイナリファイル';
COMMENT ON COLUMN pxr_book_operate.binary_file.id IS 'ID';
COMMENT ON COLUMN pxr_book_operate.binary_file.thing_id IS 'モノID';
COMMENT ON COLUMN pxr_book_operate.binary_file.file_path IS 'ファイルパス';
COMMENT ON COLUMN pxr_book_operate.binary_file.mime_type IS 'MIMEタイプ';
COMMENT ON COLUMN pxr_book_operate.binary_file.file_size IS 'ファイルサイズ';
COMMENT ON COLUMN pxr_book_operate.binary_file.file_hash IS 'ファイルハッシュ';
COMMENT ON COLUMN pxr_book_operate.binary_file.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_operate.binary_file.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_operate.binary_file.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_operate.binary_file.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_operate.binary_file.updated_at IS '更新日時';

-- CMatrixイベントテーブルを作成
DROP TABLE IF EXISTS pxr_book_operate.cmatrix_event;
CREATE TABLE IF NOT EXISTS pxr_book_operate.cmatrix_event
(
    id bigserial,
    "1_1" varchar(255) NOT NULL,
    "1_2" timestamp(3),
    "1_3" smallint,
    "3_1_1" varchar(255) NOT NULL,
    "3_1_2_1" bigint NOT NULL,
    "3_1_2_2" bigint NOT NULL,
    "3_2_1" timestamp(3),
    "3_2_2" timestamp(3),
    "3_3_1" varchar(255),
    "3_5_1_1" bigint NOT NULL,
    "3_5_1_2" bigint NOT NULL,
    "3_5_2_1" bigint,
    "3_5_2_2" bigint,
    "3_5_3_1" bigint,
    "3_5_3_2" bigint,
    "3_5_4" varchar(255),
    "3_5_5_1" bigint,
    "3_5_5_2" bigint,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_operate.cmatrix_event IS 'CMatrixイベント';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event.id IS 'ID';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event."1_1" IS '個人識別子';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event."1_2" IS '生年月日';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event."1_3" IS '性別';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event."3_1_1" IS 'イベント識別子';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event."3_1_2_1" IS 'イベント種別カタログコード';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event."3_1_2_2" IS 'イベント種別カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event."3_2_1" IS 'イベント開始時間';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event."3_2_2" IS 'イベント終了時間';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event."3_3_1" IS 'イベント発生位置';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event."3_5_1_1" IS 'イベントを発生させたアクター識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event."3_5_1_2" IS 'イベントを発生させたアクター識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event."3_5_2_1" IS 'ワークフロー識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event."3_5_2_2" IS 'ワークフロー識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event."3_5_3_1" IS 'ワークフローロール識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event."3_5_3_2" IS 'ワークフローロール識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event."3_5_4" IS 'ワークフロー職員識別子';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event."3_5_5_1" IS 'アプリケーション識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event."3_5_5_2" IS 'アプリケーション識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_operate.cmatrix_event.updated_at IS '更新日時';

-- CMatrixモノテーブルを作成
DROP TABLE IF EXISTS pxr_book_operate.cmatrix_thing;
CREATE TABLE IF NOT EXISTS pxr_book_operate.cmatrix_thing
(
    id bigserial,
    cmatrix_event_id bigint NOT NULL,
    "4_1_1" varchar(255) NOT NULL,
    "4_1_2_1" bigint NOT NULL,
    "4_1_2_2" bigint NOT NULL,
    "4_4_1_1" bigint NOT NULL,
    "4_4_1_2" bigint NOT NULL,
    "4_4_2_1" bigint,
    "4_4_2_2" bigint,
    "4_4_3_1" bigint,
    "4_4_3_2" bigint,
    "4_4_4" varchar(255),
    "4_4_5_1" bigint,
    "4_4_5_2" bigint,
    row_hash varchar(255) NOT NULL,
    row_hash_create_at varchar(255) NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_operate.cmatrix_thing IS 'CMatrixモノ';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing.id IS 'ID';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing.cmatrix_event_id IS 'CMatrixイベントID';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing."4_1_1" IS 'モノ識別子';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing."4_1_2_1" IS 'モノ種別カタログコード';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing."4_1_2_2" IS 'モノ種別カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing."4_4_1_1" IS 'モノを発生させたアクター識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing."4_4_1_2" IS 'モノを発生させたアクター識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing."4_4_2_1" IS 'ワークフロー識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing."4_4_2_2" IS 'ワークフロー識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing."4_4_3_1" IS 'ワークフローロール識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing."4_4_3_2" IS 'ワークフローロール識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing."4_4_4" IS 'ワークフロー職員識別子';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing."4_4_5_1" IS 'アプリケーション識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing."4_4_5_2" IS 'アプリケーション識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing.row_hash IS '行ハッシュ(SHA256)';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing.row_hash_create_at IS '行ハッシュ生成時間';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_operate.cmatrix_thing.updated_at IS '更新日時';

-- CMatrix変動列テーブルを作成
DROP TABLE IF EXISTS pxr_book_operate.cmatrix_floating_column;
CREATE TABLE IF NOT EXISTS pxr_book_operate.cmatrix_floating_column
(
    id bigserial,
    cmatrix_thing_id bigint NOT NULL,
    index_key varchar(255) NOT NULL,
    value varchar(255),
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_operate.cmatrix_floating_column IS 'CMatrix変動列';
COMMENT ON COLUMN pxr_book_operate.cmatrix_floating_column.id IS 'ID';
COMMENT ON COLUMN pxr_book_operate.cmatrix_floating_column.cmatrix_thing_id IS 'CMatrixモノID';
COMMENT ON COLUMN pxr_book_operate.cmatrix_floating_column.index_key IS 'インデックス';
COMMENT ON COLUMN pxr_book_operate.cmatrix_floating_column.value IS '値';
COMMENT ON COLUMN pxr_book_operate.cmatrix_floating_column.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_operate.cmatrix_floating_column.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_operate.cmatrix_floating_column.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_operate.cmatrix_floating_column.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_operate.cmatrix_floating_column.updated_at IS '更新日時';

-- CMatrix_2_(n)リレーションテーブルを作成
DROP TABLE IF EXISTS pxr_book_operate.cmatrix_2_n_relation;
CREATE TABLE IF NOT EXISTS pxr_book_operate.cmatrix_2_n_relation
(
    id bigserial,
    n bigint NOT NULL,
    cmatrix_event_id bigint NOT NULL,
    cmatrix_2n_id bigint NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_operate.cmatrix_2_n_relation IS 'CMatrix_2_(n)リレーション';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n_relation.id IS 'ID';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n_relation.n IS 'ドキュメント連番';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n_relation.cmatrix_event_id IS 'CMatrixイベントID';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n_relation.cmatrix_2n_id IS 'CMatrix2(n)ID';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n_relation.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n_relation.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n_relation.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n_relation.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n_relation.updated_at IS '更新日時';

-- CMatrix_2_(n)テーブルを作成
DROP TABLE IF EXISTS pxr_book_operate.cmatrix_2_n;
CREATE TABLE IF NOT EXISTS pxr_book_operate.cmatrix_2_n
(
    id bigserial,
    _1_1 varchar(255) NOT NULL,
    _1_2_1 bigint NOT NULL,
    _1_2_2 bigint NOT NULL,
    _2_1 timestamp(3) NOT NULL,
    _3_1_1 bigint NOT NULL,
    _3_1_2 bigint NOT NULL,
    _3_2_1 bigint,
    _3_2_2 bigint,
    _3_3_1 bigint,
    _3_3_2 bigint,
    _3_4 varchar(255),
    _3_5_1 bigint,
    _3_5_2 bigint,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_operate.cmatrix_2_n IS 'CMatrix_2_(n)';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n.id IS 'ID';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n._1_1 IS 'ドキュメント識別子';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n._1_2_1 IS 'ドキュメント種別カタログコード';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n._1_2_2 IS 'ドキュメント種別カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n._2_1 IS 'ドキュメント作成時間';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n._3_1_1 IS 'ドキュメントを発生させたアクター識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n._3_1_2 IS 'ドキュメントを発生させたアクター識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n._3_2_1 IS 'ワークフロー識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n._3_2_2 IS 'ワークフロー識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n._3_3_1 IS 'ワークフローロール識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n._3_3_2 IS 'ワークフローロール識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n._3_4 IS 'ワークフロー職員識別子';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n._3_5_1 IS 'アプリケーション識別子カタログコード';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n._3_5_2 IS 'アプリケーション識別子カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_operate.cmatrix_2_n.updated_at IS '更新日時';

-- データ提供契約収集依頼
DROP TABLE IF EXISTS pxr_book_operate.collection_request;
CREATE TABLE IF NOT EXISTS pxr_book_operate.collection_request
(
    id bigserial,
    status smallint NOT NULL DEFAULT 0,
    pcd_code varchar(255) NOT NULL,
    actor_code bigint NOT NULL,
    block_code bigint NOT NULL,
    supply_proposal_id bigint NOT NULL,
    contract_id bigint NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_operate.collection_request IS 'データ提供契約収集依頼';
COMMENT ON COLUMN pxr_book_operate.collection_request.id IS 'ID';
COMMENT ON COLUMN pxr_book_operate.collection_request.status IS 'ステータス';
COMMENT ON COLUMN pxr_book_operate.collection_request.pcd_code IS 'PCDコード';
COMMENT ON COLUMN pxr_book_operate.collection_request.actor_code IS 'アクターコード';
COMMENT ON COLUMN pxr_book_operate.collection_request.block_code IS 'ブロックコード';
COMMENT ON COLUMN pxr_book_operate.collection_request.supply_proposal_id IS 'データ提供契約申込ID';
COMMENT ON COLUMN pxr_book_operate.collection_request.contract_id IS 'データ提供契約ID';
COMMENT ON COLUMN pxr_book_operate.collection_request.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_operate.collection_request.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_operate.collection_request.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_operate.collection_request.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_operate.collection_request.updated_at IS '更新日時';

-- データ提供契約収集依頼データ種
DROP TABLE IF EXISTS pxr_book_operate.collection_request_data_type;
CREATE TABLE IF NOT EXISTS pxr_book_operate.collection_request_data_type
(
    id bigserial,
    collection_request_id bigint NOT NULL,
    event_code bigint,
    event_version bigint,
    thing_code bigint NOT NULL,
    thing_version bigint NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_operate.collection_request_data_type IS 'データ提供契約収集依頼データ種';
COMMENT ON COLUMN pxr_book_operate.collection_request_data_type.id IS 'ID';
COMMENT ON COLUMN pxr_book_operate.collection_request_data_type.collection_request_id IS 'データ提供契約収集依頼ID';
COMMENT ON COLUMN pxr_book_operate.collection_request_data_type.event_code IS 'イベントカタログコード';
COMMENT ON COLUMN pxr_book_operate.collection_request_data_type.event_version IS 'イベントカタログバージョン';
COMMENT ON COLUMN pxr_book_operate.collection_request_data_type.thing_code IS 'モノカタログコード';
COMMENT ON COLUMN pxr_book_operate.collection_request_data_type.thing_version IS 'モノカタログバージョン';
COMMENT ON COLUMN pxr_book_operate.collection_request_data_type.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_operate.collection_request_data_type.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_operate.collection_request_data_type.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_operate.collection_request_data_type.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_operate.collection_request_data_type.updated_at IS '更新日時';

-- データ提供契約収集依頼同意
DROP TABLE IF EXISTS pxr_book_operate.collection_request_consent;
CREATE TABLE IF NOT EXISTS pxr_book_operate.collection_request_consent
(
    id bigserial,
    collection_request_id bigint NOT NULL,
    status smallint NOT NULL DEFAULT 0,
    user_id varchar(255) NOT NULL,
    mask_id varchar(255) NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_operate.collection_request_consent IS 'データ提供契約収集依頼同意';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent.id IS 'ID';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent.collection_request_id IS 'データ提供契約収集依頼ID';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent.status IS 'ステータス';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent.user_id IS '利用者ID';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent.mask_id IS 'マスクID';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent.updated_at IS '更新日時';

-- データ提供契約収集依頼送付データ件数
DROP TABLE IF EXISTS pxr_book_operate.collection_request_consent_data_amount;
CREATE TABLE IF NOT EXISTS pxr_book_operate.collection_request_consent_data_amount
(
    id bigserial,
    collection_request_consent_id bigint NOT NULL,
    event_code bigint,
    event_version bigint,
    thing_code bigint NOT NULL,
    thing_version bigint NOT NULL,
    amount bigint NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_operate.collection_request_consent_data_amount IS 'データ提供契約収集依頼送付データ件数';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent_data_amount.id IS 'ID';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent_data_amount.collection_request_consent_id IS 'データ提供契約収集依頼同意ID';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent_data_amount.event_code IS 'イベントカタログコード';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent_data_amount.event_version IS 'イベントカタログバージョン';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent_data_amount.thing_code IS 'モノカタログコード';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent_data_amount.thing_version IS 'モノカタログバージョン';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent_data_amount.amount IS '件数';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent_data_amount.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent_data_amount.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent_data_amount.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent_data_amount.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent_data_amount.updated_at IS '更新日時';

-- 待機中共有トリガー
DROP TABLE IF EXISTS pxr_book_operate.share_trigger_waiting;
CREATE TABLE IF NOT EXISTS pxr_book_operate.share_trigger_waiting
(
    id bigserial,
    share_status_id bigint,
    user_id varchar(255) NOT NULL,
    share_trigger_code bigint NOT NULL,
    share_trigger_version bigint NOT NULL,
    share_code bigint NOT NULL,
    share_version bigint NOT NULL,
    source_actor_code bigint NOT NULL,
    source_actor_version bigint NOT NULL,
    source_app_code bigint,
    source_app_version bigint,
    source_wf_code bigint,
    source_wf_version bigint,
    dest_actor_code bigint NOT NULL,
    dest_actor_version bigint NOT NULL,
    dest_app_code bigint,
    dest_app_version bigint,
    dest_wf_code bigint,
    dest_wf_version bigint,
    process_type smallint NOT NULL,
    end_of_waiting_at timestamp(3),
    identifier varchar(255) NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_operate.share_trigger_waiting IS '待機中共有トリガー';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.id IS 'ID';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.share_status_id IS '共有トリガーによる共有状態ID';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.user_id IS '利用者ID';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.share_trigger_code IS '共有トリガーカタログコード';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.share_trigger_version IS '共有トリガーカタログバージョン';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.share_code IS '共有定義カタログコード';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.share_version IS '共有定義カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.source_actor_code IS '共有元アクターカタログコード';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.source_actor_version IS '共有元アクターカタログバージョン';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.source_app_code IS '共有元アプリケーションカタログコード';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.source_app_version IS '共有元アプリケーションカタログバージョン';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.source_wf_code IS '共有元ワークフローカタログコード';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.source_wf_version IS '共有元ワークフローカタログバージョン';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.dest_actor_code IS '共有先アクターカタログコード';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.dest_actor_version IS '共有先アクターカタログバージョン';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.dest_app_code IS '共有先アプリケーションカタログコード';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.dest_app_version IS '共有先アプリケーションカタログバージョン';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.dest_wf_code IS '共有先ワークフローカタログコード';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.dest_wf_version IS '共有先ワークフローカタログバージョン';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.process_type IS '処理種別';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.end_of_waiting_at IS '待機終了日時';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.identifier IS 'データ識別子';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_operate.share_trigger_waiting.updated_at IS '更新日時';

-- 共有トリガーによる共有状態
DROP TABLE IF EXISTS pxr_book_operate.share_status;
CREATE TABLE IF NOT EXISTS pxr_book_operate.share_status
(
    id bigserial,
    user_id varchar(255) NOT NULL,
    share_trigger_code bigint NOT NULL,
    share_trigger_version bigint NOT NULL,
    share_code bigint NOT NULL,
    share_version bigint NOT NULL,
    end_method smallint NOT NULL ,
    start_datetime timestamp(3),
    end_datetime timestamp(3),
    status smallint NOT NULL DEFAULT 0,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_book_operate.share_status IS '共有トリガーによる共有状態';
COMMENT ON COLUMN pxr_book_operate.share_status.id IS 'ID';
COMMENT ON COLUMN pxr_book_operate.share_status.user_id IS '利用者ID';
COMMENT ON COLUMN pxr_book_operate.share_status.share_trigger_code IS '共有トリガーカタログコード';
COMMENT ON COLUMN pxr_book_operate.share_status.share_trigger_version IS '共有トリガーカタログバージョン';
COMMENT ON COLUMN pxr_book_operate.share_status.share_code IS '共有定義カタログコード';
COMMENT ON COLUMN pxr_book_operate.share_status.share_version IS '共有定義カタログバージョン';
COMMENT ON COLUMN pxr_book_operate.share_status.end_method IS '共有終了方法';
COMMENT ON COLUMN pxr_book_operate.share_status.start_datetime IS '共有開始日時';
COMMENT ON COLUMN pxr_book_operate.share_status.end_datetime IS '共有終了日時';
COMMENT ON COLUMN pxr_book_operate.share_status.status IS '共有状態';
COMMENT ON COLUMN pxr_book_operate.share_status.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_book_operate.share_status.created_by IS '登録者';
COMMENT ON COLUMN pxr_book_operate.share_status.created_at IS '登録日時';
COMMENT ON COLUMN pxr_book_operate.share_status.updated_by IS '更新者';
COMMENT ON COLUMN pxr_book_operate.share_status.updated_at IS '更新日時';


-- 外部キーを追加
ALTER TABLE pxr_book_operate.event ADD FOREIGN KEY (my_condition_book_id) REFERENCES pxr_book_operate.my_condition_book(id) ON DELETE CASCADE;
ALTER TABLE pxr_book_operate.shared_access_log ADD FOREIGN KEY (my_condition_book_id) REFERENCES pxr_book_operate.my_condition_book(id) ON DELETE CASCADE;
ALTER TABLE pxr_book_operate.shared_access_log_data_type ADD FOREIGN KEY (share_access_log_id) REFERENCES pxr_book_operate.shared_access_log(id) ON DELETE CASCADE;
ALTER TABLE pxr_book_operate.thing ADD FOREIGN KEY (event_id) REFERENCES pxr_book_operate.event(id) ON DELETE CASCADE;
ALTER TABLE pxr_book_operate.document ADD FOREIGN KEY (my_condition_book_id) REFERENCES pxr_book_operate.my_condition_book(id) ON DELETE CASCADE;
ALTER TABLE pxr_book_operate.binary_file ADD FOREIGN KEY (thing_id) REFERENCES pxr_book_operate.thing(id) ON DELETE CASCADE;
ALTER TABLE pxr_book_operate.cmatrix_floating_column ADD FOREIGN KEY (cmatrix_thing_id) REFERENCES pxr_book_operate.cmatrix_thing(id);
ALTER TABLE pxr_book_operate.cmatrix_thing ADD FOREIGN KEY (cmatrix_event_id) REFERENCES pxr_book_operate.cmatrix_event(id);
ALTER TABLE pxr_book_operate.cmatrix_2_n_relation ADD FOREIGN KEY (cmatrix_2n_id) REFERENCES pxr_book_operate.cmatrix_2_n(id);
ALTER TABLE pxr_book_operate.cmatrix_2_n_relation ADD FOREIGN KEY (cmatrix_event_id) REFERENCES pxr_book_operate.cmatrix_event(id);
ALTER TABLE pxr_book_operate.share_trigger_waiting ADD FOREIGN KEY (share_status_id) REFERENCES pxr_book_operate.share_status(id);

-- インデックスを追加
-- DROP INDEX pxr_book_operate.share_trigger_waiting_end_of_waiting_at_idx;
-- DROP INDEX pxr_book_operate.my_condition_book_user_id_idx;
-- DROP INDEX pxr_book_operate.event_catalog_code_version_is_disabled_idx;
-- DROP INDEX pxr_book_operate.event_updated_at_idx;
-- DROP INDEX pxr_book_operate.event_my_condition_book_id_idx;
-- DROP INDEX pxr_book_operate.thing_updated_at_idx;
-- DROP INDEX pxr_book_operate.thing_event_id_idx;
-- DROP INDEX pxr_book_operate.cmatrix_event_catalog_code_version_user_id_idx;
-- DROP INDEX pxr_book_operate.cmatrix_event_id_idx;
-- DROP INDEX pxr_book_operate.cmatrix_thing_id_idx;
CREATE INDEX share_trigger_waiting_end_of_waiting_at_idx ON pxr_book_operate.share_trigger_waiting(end_of_waiting_at);
CREATE INDEX my_condition_book_user_id_idx ON pxr_book_operate.my_condition_book(user_id);
CREATE INDEX event_catalog_code_version_is_disabled_idx ON pxr_book_operate.event(is_disabled, event_catalog_code, event_catalog_version);
CREATE INDEX event_updated_at_idx ON pxr_book_operate.event(updated_at);
CREATE INDEX event_my_condition_book_id_idx ON pxr_book_operate.event(my_condition_book_id);
CREATE INDEX thing_updated_at_idx ON pxr_book_operate.thing(updated_at);
CREATE INDEX thing_event_id_idx ON pxr_book_operate.thing(event_id);
CREATE INDEX cmatrix_event_catalog_code_version_user_id_idx ON pxr_book_operate.cmatrix_event("3_1_2_1", "3_1_2_2", "1_1");
CREATE INDEX cmatrix_event_id_idx ON pxr_book_operate.cmatrix_thing(cmatrix_event_id);
CREATE INDEX cmatrix_thing_id_idx ON pxr_book_operate.cmatrix_floating_column(cmatrix_thing_id);







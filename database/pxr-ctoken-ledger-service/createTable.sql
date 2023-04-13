/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- CTokenテーブル
DROP TABLE IF EXISTS pxr_ctoken_ledger.ctoken CASCADE;
CREATE TABLE IF NOT EXISTS pxr_ctoken_ledger.ctoken
(
    id bigserial,
    pxr_id varchar(255) NOT NUll,
    ctoken varchar(255) NOT NUll,
    ctoken_create_at timestamp(3) NOT NULL DEFAULT now(),
    is_disabled boolean NOT NULL default false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT now(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT now(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_ctoken_ledger.ctoken IS 'CToken';
COMMENT ON COLUMN pxr_ctoken_ledger.ctoken.id IS 'ID';
COMMENT ON COLUMN pxr_ctoken_ledger.ctoken.pxr_id IS 'PXR-ID';
COMMENT ON COLUMN pxr_ctoken_ledger.ctoken.ctoken IS 'CToken';
COMMENT ON COLUMN pxr_ctoken_ledger.ctoken.ctoken_create_at IS 'CToken作成日時';
COMMENT ON COLUMN pxr_ctoken_ledger.ctoken.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_ctoken_ledger.ctoken.created_by IS '登録者';
COMMENT ON COLUMN pxr_ctoken_ledger.ctoken.created_at IS '登録日時';
COMMENT ON COLUMN pxr_ctoken_ledger.ctoken.updated_by IS '更新者';
COMMENT ON COLUMN pxr_ctoken_ledger.ctoken.updated_at IS '更新日時';

-- CToken履歴テーブル
DROP TABLE IF EXISTS pxr_ctoken_ledger.ctoken_history CASCADE;
CREATE TABLE IF NOT EXISTS pxr_ctoken_ledger.ctoken_history
(
    id bigserial,
    ctoken_id bigint NOT NUll,
    ctoken varchar(255) NOT NUll,
    ctoken_create_at timestamp(3) NOT NULL DEFAULT now(),
    is_disabled boolean NOT NULL default false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT now(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT now(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_ctoken_ledger.ctoken_history IS 'CToken履歴';
COMMENT ON COLUMN pxr_ctoken_ledger.ctoken_history.id IS 'ID';
COMMENT ON COLUMN pxr_ctoken_ledger.ctoken_history.ctoken_id IS 'CTokenID';
COMMENT ON COLUMN pxr_ctoken_ledger.ctoken_history.ctoken IS 'CToken';
COMMENT ON COLUMN pxr_ctoken_ledger.ctoken_history.ctoken_create_at IS 'CToken作成日時';
COMMENT ON COLUMN pxr_ctoken_ledger.ctoken_history.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_ctoken_ledger.ctoken_history.created_by IS '登録者';
COMMENT ON COLUMN pxr_ctoken_ledger.ctoken_history.created_at IS '登録日時';
COMMENT ON COLUMN pxr_ctoken_ledger.ctoken_history.updated_by IS '更新者';
COMMENT ON COLUMN pxr_ctoken_ledger.ctoken_history.updated_at IS '更新日時';

-- 行列ハッシュテーブル
DROP TABLE IF EXISTS pxr_ctoken_ledger.cmatrix CASCADE;
CREATE TABLE IF NOT EXISTS pxr_ctoken_ledger.cmatrix
(
    id bigserial,
    ctoken_id bigint NOT NUll,
    actor_catalog_code bigint NOT NUll,
    actor_catalog_version bigint NOT NUll,
    "1_1" varchar(255) NOT NUll,
    cmatrix_hash varchar(255) NOT NUll,
    cmatrix_hash_create_at timestamp(3) NOT NUll DEFAULT now(),
    is_disabled boolean NOT NULL default false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT now(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT now(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_ctoken_ledger.cmatrix IS '行列ハッシュ';
COMMENT ON COLUMN pxr_ctoken_ledger.cmatrix.id IS 'ID';
COMMENT ON COLUMN pxr_ctoken_ledger.cmatrix.ctoken_id IS 'CTokenID';
COMMENT ON COLUMN pxr_ctoken_ledger.cmatrix.actor_catalog_code IS 'アクターカタログコード';
COMMENT ON COLUMN pxr_ctoken_ledger.cmatrix.actor_catalog_version IS 'アクターカタログバージョン';
COMMENT ON COLUMN pxr_ctoken_ledger.cmatrix."1_1" IS '個人識別子';
COMMENT ON COLUMN pxr_ctoken_ledger.cmatrix.cmatrix_hash IS '行列ハッシュ';
COMMENT ON COLUMN pxr_ctoken_ledger.cmatrix.cmatrix_hash_create_at IS '行列ハッシュ生成時間';
COMMENT ON COLUMN pxr_ctoken_ledger.cmatrix.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_ctoken_ledger.cmatrix.created_by IS '登録者';
COMMENT ON COLUMN pxr_ctoken_ledger.cmatrix.created_at IS '登録日時';
COMMENT ON COLUMN pxr_ctoken_ledger.cmatrix.updated_by IS '更新者';
COMMENT ON COLUMN pxr_ctoken_ledger.cmatrix.updated_at IS '更新日時';

-- 行ハッシュテーブル
DROP TABLE IF EXISTS pxr_ctoken_ledger.row_hash CASCADE;
CREATE TABLE IF NOT EXISTS pxr_ctoken_ledger.row_hash
(
    id bigserial,
    cmatrix_id bigint NOT NUll,
    "3_1_1" varchar(255) NOT NUll,
    "3_1_2_1" bigint NOT NUll,
    "3_1_2_2" bigint NOT NUll,
    "3_2_1" timestamp(3),
    "3_2_2" timestamp(3),
    "3_5_1_1" bigint NOT NUll,
    "3_5_1_2" bigint NOT NUll,
    "3_5_2_1" bigint,
    "3_5_2_2" bigint,
    "3_5_5_1" bigint,
    "3_5_5_2" bigint,
    "4_1_1" varchar(255) NOT NUll,
    "4_1_2_1" bigint NOT NUll,
    "4_1_2_2" bigint NOT NUll,
    "4_4_1_1" bigint NOT NUll,
    "4_4_1_2" bigint NOT NUll,
    "4_4_2_1" bigint,
    "4_4_2_2" bigint,
    "4_4_5_1" bigint,
    "4_4_5_2" bigint,
    row_hash varchar(255) NOT NUll,
    row_hash_create_at timestamp(3) NOT NUll,
    is_disabled boolean NOT NULL default false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT now(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT now(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_ctoken_ledger.row_hash IS '行ハッシュ';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash.id IS 'ID';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash.cmatrix_id IS '行列ハッシュID';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash."3_1_1" IS 'イベント識別子';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash."3_1_2_1" IS 'イベント種別カタログコード';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash."3_1_2_2" IS 'イベント種別カタログバージョン';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash."3_2_1" IS 'イベント開始時間';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash."3_2_2" IS 'イベント終了時間';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash."3_5_1_1" IS 'イベントを発生させたアクター識別子カタログコード';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash."3_5_1_2" IS 'イベントを発生させたアクター識別子カタログバージョン';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash."3_5_2_1" IS 'ワークフロー識別子カタログコード';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash."3_5_2_2" IS 'ワークフロー識別子カタログバージョン';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash."3_5_5_1" IS 'アプリケーション識別子カタログコード';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash."3_5_5_2" IS 'アプリケーション識別子カタログコード';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash."4_1_1" IS 'モノ識別子';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash."4_1_2_1" IS 'モノ種別カタログコード';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash."4_1_2_2" IS 'モノ種別カタログバージョン';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash."4_4_1_1" IS 'モノを発生させたアクター識別子カタログコード';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash."4_4_1_2" IS 'モノを発生させたアクター識別子カタログバージョン';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash."4_4_2_1" IS 'ワークフロー識別子カタログコード';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash."4_4_2_2" IS 'ワークフロー識別子カタログバージョン';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash."4_4_5_1" IS 'アプリケーション識別子カタログコード';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash."4_4_5_2" IS 'アプリケーション識別子カタログコード';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash.row_hash IS '行ハッシュ';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash.row_hash_create_at IS '行ハッシュ生成時間';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash.created_by IS '登録者';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash.created_at IS '登録日時';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash.updated_by IS '更新者';
COMMENT ON COLUMN pxr_ctoken_ledger.row_hash.updated_at IS '更新日時';

-- ドキュメントテーブル
DROP TABLE IF EXISTS pxr_ctoken_ledger.document CASCADE;
CREATE TABLE IF NOT EXISTS pxr_ctoken_ledger.document
(
    id bigserial,
    row_hash_id bigint NOT NUll,
    _1_1 varchar(255) NOT NUll,
    _1_2_1 bigint NOT NUll,
    _1_2_2 bigint NOT NUll,
    _2_1 timestamp(3) NOT NULL,
    _3_1_1 bigint NOT NUll,
    _3_1_2 bigint NOT NUll,
    _3_2_1 bigint,
    _3_2_2 bigint,
    _3_5_1 bigint,
    _3_5_2 bigint,
    is_disabled boolean NOT NULL default false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT now(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT now(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_ctoken_ledger.document IS 'ドキュメント';
COMMENT ON COLUMN pxr_ctoken_ledger.document.id IS 'ID';
COMMENT ON COLUMN pxr_ctoken_ledger.document.row_hash_id IS '行ハッシュID';
COMMENT ON COLUMN pxr_ctoken_ledger.document._1_1 IS 'ドキュメント識別子';
COMMENT ON COLUMN pxr_ctoken_ledger.document._1_2_1 IS 'ドキュメント種別カタログコード';
COMMENT ON COLUMN pxr_ctoken_ledger.document._1_2_2 IS 'ドキュメント種別カタログバージョン';
COMMENT ON COLUMN pxr_ctoken_ledger.document._2_1 IS 'ドキュメント作成時間';
COMMENT ON COLUMN pxr_ctoken_ledger.document._3_1_1 IS 'ドキュメントを発生させたアクター識別子カタログコード';
COMMENT ON COLUMN pxr_ctoken_ledger.document._3_1_2 IS 'ドキュメントを発生させたアクター識別子カタログバージョン';
COMMENT ON COLUMN pxr_ctoken_ledger.document._3_2_1 IS 'ワークフロー識別子カタログコード';
COMMENT ON COLUMN pxr_ctoken_ledger.document._3_2_2 IS 'ワークフロー識別子カタログバージョン';
COMMENT ON COLUMN pxr_ctoken_ledger.document._3_5_1 IS 'アプリケーション識別子カタログコード';
COMMENT ON COLUMN pxr_ctoken_ledger.document._3_5_2 IS 'アプリケーション識別子カタログバージョン';
COMMENT ON COLUMN pxr_ctoken_ledger.document.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_ctoken_ledger.document.created_by IS '登録者';
COMMENT ON COLUMN pxr_ctoken_ledger.document.created_at IS '登録日時';
COMMENT ON COLUMN pxr_ctoken_ledger.document.updated_by IS '更新者';
COMMENT ON COLUMN pxr_ctoken_ledger.document.updated_at IS '更新日時';












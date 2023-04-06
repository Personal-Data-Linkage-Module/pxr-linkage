/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- 外部キーを削除(2回目以降のテーブル作成する時のみ必要)
/*
ALTER TABLE pxr_catalog.ns_update_set DROP CONSTRAINT ns_update_set_update_set_id_fkey;
ALTER TABLE pxr_catalog.catalog_update_set DROP CONSTRAINT catalog_update_set_update_set_id_fkey;
ALTER TABLE pxr_catalog.catalog_item_attribute DROP CONSTRAINT catalog_item_attribute_catalog_item_id_fkey;
ALTER TABLE pxr_catalog.item_template DROP CONSTRAINT item_template_catalog_item_id_fkey;
-- ALTER TABLE pxr_catalog.item_template DROP CONSTRAINT item_template_template_property_id_fkey;
ALTER TABLE pxr_catalog.template_property DROP CONSTRAINT template_property_item_template_id_fkey;
ALTER TABLE pxr_catalog.cmatrix_index DROP CONSTRAINT cmatrix_index_catalog_item_id_fkey;
ALTER TABLE pxr_catalog.catalog_relationship DROP CONSTRAINT catalog_relationship_catalog_item_id_fkey;
*/

-- ネームスペーステーブルを作成
DROP TABLE IF EXISTS pxr_catalog.ns;
CREATE TABLE IF NOT EXISTS pxr_catalog.ns
(
    id bigserial,
    type varchar(255),
    name text NOT NULL,
    description text,
    is_disabled boolean NOT NULL DEFAULT false,
    attributes text,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_catalog.ns IS 'ネームスペーステーブル';
COMMENT ON COLUMN pxr_catalog.ns.id IS 'ID';
COMMENT ON COLUMN pxr_catalog.ns.type IS 'タイプ';
COMMENT ON COLUMN pxr_catalog.ns.name IS '名前空間';
COMMENT ON COLUMN pxr_catalog.ns.description IS '説明';
COMMENT ON COLUMN pxr_catalog.ns.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_catalog.ns.attributes IS 'その他属性';
COMMENT ON COLUMN pxr_catalog.ns.created_by IS '登録者';
COMMENT ON COLUMN pxr_catalog.ns.created_at IS '登録日時';
COMMENT ON COLUMN pxr_catalog.ns.updated_by IS '更新者';
COMMENT ON COLUMN pxr_catalog.ns.updated_at IS '更新日時';

-- カタログテーブルを作成
DROP TABLE IF EXISTS pxr_catalog.catalog;
CREATE TABLE IF NOT EXISTS pxr_catalog.catalog
(
    id varchar(255) NOT NULL,
    name varchar(255) NOT NULL,
    description text,
    ext_name text NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    attributes text,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_catalog.catalog IS 'カタログテーブル';
COMMENT ON COLUMN pxr_catalog.catalog.id IS 'UUID';
COMMENT ON COLUMN pxr_catalog.catalog.name IS '名称';
COMMENT ON COLUMN pxr_catalog.catalog.description IS '説明';
COMMENT ON COLUMN pxr_catalog.catalog.ext_name IS '拡張ネームスペース';
COMMENT ON COLUMN pxr_catalog.catalog.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_catalog.catalog.attributes IS 'その他属性';
COMMENT ON COLUMN pxr_catalog.catalog.created_by IS '登録者';
COMMENT ON COLUMN pxr_catalog.catalog.created_at IS '登録日時';
COMMENT ON COLUMN pxr_catalog.catalog.updated_by IS '更新者';
COMMENT ON COLUMN pxr_catalog.catalog.updated_at IS '更新日時';

-- カタログ項目テーブルを作成
DROP TABLE IF EXISTS pxr_catalog.catalog_item;
CREATE TABLE IF NOT EXISTS pxr_catalog.catalog_item
(
    id bigserial,
    code bigint NOT NULL,
    version bigint NOT NULL,
    ns_id bigint,
    name text,
    description text,
    inherit_code bigint,
    inherit_version bigint,
    is_reserved boolean NOT NULL DEFAULT false,
    is_disabled boolean NOT NULL DEFAULT false,
    response text,
    attributes text,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id),
    UNIQUE (code, version)
);
COMMENT ON TABLE pxr_catalog.catalog_item IS 'カタログ項目テーブル';
COMMENT ON COLUMN pxr_catalog.catalog_item.id IS 'ID';
COMMENT ON COLUMN pxr_catalog.catalog_item.code IS 'コード';
COMMENT ON COLUMN pxr_catalog.catalog_item.version IS 'バージョン';
COMMENT ON COLUMN pxr_catalog.catalog_item.ns_id IS '名前空間ID';
COMMENT ON COLUMN pxr_catalog.catalog_item.name IS '名称';
COMMENT ON COLUMN pxr_catalog.catalog_item.description IS '説明';
COMMENT ON COLUMN pxr_catalog.catalog_item.inherit_code IS '継承カタログ項目コード';
COMMENT ON COLUMN pxr_catalog.catalog_item.inherit_version IS '継承カタログ項目バージョン';
COMMENT ON COLUMN pxr_catalog.catalog_item.is_reserved IS '予約フラグ';
COMMENT ON COLUMN pxr_catalog.catalog_item.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_catalog.catalog_item.response IS 'レスポンスJSON';
COMMENT ON COLUMN pxr_catalog.catalog_item.attributes IS 'その他属性';
COMMENT ON COLUMN pxr_catalog.catalog_item.created_by IS '登録者';
COMMENT ON COLUMN pxr_catalog.catalog_item.created_at IS '登録日時';
COMMENT ON COLUMN pxr_catalog.catalog_item.updated_by IS '更新者';
COMMENT ON COLUMN pxr_catalog.catalog_item.updated_at IS '更新日時';

-- カタログ項目属性テーブルを作成
DROP TABLE IF EXISTS pxr_catalog.catalog_item_attribute;
CREATE TABLE IF NOT EXISTS pxr_catalog.catalog_item_attribute
(
    id bigserial,
    catalog_item_id bigint,
    catalog_code bigint,
    type smallint NOT NULL,
    key_code bigint,
    key_version bigint,
    ns_id bigint,
    value text,
    description text,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_catalog.catalog_item_attribute IS 'カタログ項目属性テーブル';
COMMENT ON COLUMN pxr_catalog.catalog_item_attribute.id IS 'ID';
COMMENT ON COLUMN pxr_catalog.catalog_item_attribute.catalog_item_id IS 'カタログ項目ID';
COMMENT ON COLUMN pxr_catalog.catalog_item_attribute.key_code IS 'キーコード';
COMMENT ON COLUMN pxr_catalog.catalog_item_attribute.key_version IS 'キーバージョン';
COMMENT ON COLUMN pxr_catalog.catalog_item_attribute.value IS '値';
COMMENT ON COLUMN pxr_catalog.catalog_item_attribute.description IS '説明';
COMMENT ON COLUMN pxr_catalog.catalog_item_attribute.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_catalog.catalog_item_attribute.created_by IS '登録者';
COMMENT ON COLUMN pxr_catalog.catalog_item_attribute.created_at IS '登録日時';
COMMENT ON COLUMN pxr_catalog.catalog_item_attribute.updated_by IS '更新者';
COMMENT ON COLUMN pxr_catalog.catalog_item_attribute.updated_at IS '更新日時';

-- アイテムテンプレートテーブルを作成
DROP TABLE IF EXISTS pxr_catalog.item_template;
CREATE TABLE IF NOT EXISTS pxr_catalog.item_template
(
    id bigserial,
    catalog_item_id bigint,
    template_property_id bigint,
    template text,
    inner_name text,
    inner_inherit_code bigint,
    inner_inherit_version bigint,
    is_disabled boolean NOT NULL DEFAULT false,
    response text,
    attributes text,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_catalog.item_template IS 'アイテムテンプレートテーブル';
COMMENT ON COLUMN pxr_catalog.item_template.id IS 'ID';
COMMENT ON COLUMN pxr_catalog.item_template.catalog_item_id IS 'カタログ項目ID';
COMMENT ON COLUMN pxr_catalog.item_template.template_property_id IS 'プロパティ定義ID';
COMMENT ON COLUMN pxr_catalog.item_template.template IS 'テンプレート';
COMMENT ON COLUMN pxr_catalog.item_template.inner_name IS '内部クラス名称';
COMMENT ON COLUMN pxr_catalog.item_template.inner_inherit_code IS '内部クラス継承カタログ項目コード';
COMMENT ON COLUMN pxr_catalog.item_template.inner_inherit_version IS '内部クラス継承カタログ項目バージョン';
COMMENT ON COLUMN pxr_catalog.item_template.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_catalog.item_template.response IS '内部クラス用レスポンスJSON';
COMMENT ON COLUMN pxr_catalog.item_template.attributes IS 'その他属性';
COMMENT ON COLUMN pxr_catalog.item_template.created_by IS '登録者';
COMMENT ON COLUMN pxr_catalog.item_template.created_at IS '登録日時';
COMMENT ON COLUMN pxr_catalog.item_template.updated_by IS '更新者';
COMMENT ON COLUMN pxr_catalog.item_template.updated_at IS '更新日時';

-- CMatrixインデックステーブルを作成
DROP TABLE IF EXISTS pxr_catalog.cmatrix_index;
CREATE TABLE IF NOT EXISTS pxr_catalog.cmatrix_index
(
    id bigserial,
    catalog_item_id bigint NOT NULL,
    index_key varchar(255) NOT NULL,
    value text,
    reserved boolean NOT NULL DEFAULT false,
    is_disabled boolean NOT NULL DEFAULT false,
    attributes text,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_catalog.cmatrix_index IS 'CMatrixインデックステーブル';
COMMENT ON COLUMN pxr_catalog.cmatrix_index.id IS 'ID';
COMMENT ON COLUMN pxr_catalog.cmatrix_index.catalog_item_id IS 'カタログ項目ID';
COMMENT ON COLUMN pxr_catalog.cmatrix_index.index_key IS 'インデックス';
COMMENT ON COLUMN pxr_catalog.cmatrix_index.value IS '値';
COMMENT ON COLUMN pxr_catalog.cmatrix_index.reserved IS '予約フラグ';
COMMENT ON COLUMN pxr_catalog.cmatrix_index.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_catalog.cmatrix_index.attributes IS 'その他属性';
COMMENT ON COLUMN pxr_catalog.cmatrix_index.created_by IS '登録者';
COMMENT ON COLUMN pxr_catalog.cmatrix_index.created_at IS '登録日時';
COMMENT ON COLUMN pxr_catalog.cmatrix_index.updated_by IS '更新者';
COMMENT ON COLUMN pxr_catalog.cmatrix_index.updated_at IS '更新日時';

-- カタログリレーションテーブルを作成
DROP TABLE IF EXISTS pxr_catalog.catalog_relationship;
CREATE TABLE IF NOT EXISTS pxr_catalog.catalog_relationship
(
    id bigserial,
    catalog_item_id bigint NOT NULL,
    ref_catalog_item_id bigint NOT NULL,
    ref_type varchar(255) NOT NULL,
    is_get_latest boolean NOT NULL DEFAULT false,
    item_template_id bigint,
    template_property_id bigint,
    property_candidate_id bigint,
    is_disabled boolean NOT NULL DEFAULT false,
    attributes text,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_catalog.catalog_relationship IS 'カタログリレーションテーブル';
COMMENT ON COLUMN pxr_catalog.catalog_relationship.id IS 'ID';
COMMENT ON COLUMN pxr_catalog.catalog_relationship.catalog_item_id IS '参照元カタログ項目ID';
COMMENT ON COLUMN pxr_catalog.catalog_relationship.ref_catalog_item_id IS '参照先カタログ項目ID';
COMMENT ON COLUMN pxr_catalog.catalog_relationship.ref_type IS '参照タイプ';
COMMENT ON COLUMN pxr_catalog.catalog_relationship.is_get_latest IS '最新取得フラグ';
COMMENT ON COLUMN pxr_catalog.catalog_relationship.item_template_id IS '参照元項目テンプレートID';
COMMENT ON COLUMN pxr_catalog.catalog_relationship.template_property_id IS '参照元項目テンプレートプロパティID';
COMMENT ON COLUMN pxr_catalog.catalog_relationship.property_candidate_id IS '参照元プロパティ候補ID';
COMMENT ON COLUMN pxr_catalog.catalog_relationship.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_catalog.catalog_relationship.attributes IS 'その他属性';
COMMENT ON COLUMN pxr_catalog.catalog_relationship.created_by IS '登録者';
COMMENT ON COLUMN pxr_catalog.catalog_relationship.created_at IS '登録日時';
COMMENT ON COLUMN pxr_catalog.catalog_relationship.updated_by IS '更新者';
COMMENT ON COLUMN pxr_catalog.catalog_relationship.updated_at IS '更新日時';

-- テンプレートプロパティテーブルを作成
DROP TABLE IF EXISTS pxr_catalog.template_property;
CREATE TABLE IF NOT EXISTS pxr_catalog.template_property
(
    id bigserial,
    item_template_id bigint NOT NULL,
    key_name varchar(255) NOT NULL,
    type varchar(255),
    code bigint,
    version bigint,
    filter varchar(255),
    index_key varchar(255),
    format_code bigint,
    format_version bigint,
    unit_code bigint,
    unit_version bigint,
    description text,
    is_disabled boolean NOT NULL DEFAULT false,
    attributes text,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_catalog.template_property IS 'テンプレートプロパティテーブル';
COMMENT ON COLUMN pxr_catalog.template_property.id IS 'ID';
COMMENT ON COLUMN pxr_catalog.template_property.item_template_id IS '項目テンプレートID';
COMMENT ON COLUMN pxr_catalog.template_property.key_name IS 'キー';
COMMENT ON COLUMN pxr_catalog.template_property.type IS 'タイプ';
COMMENT ON COLUMN pxr_catalog.template_property.code IS 'コード';
COMMENT ON COLUMN pxr_catalog.template_property.version IS 'バージョン';
COMMENT ON COLUMN pxr_catalog.template_property.filter IS 'フィルター';
COMMENT ON COLUMN pxr_catalog.template_property.index_key IS 'インデックス';
COMMENT ON COLUMN pxr_catalog.template_property.format_code IS 'フォーマットコード';
COMMENT ON COLUMN pxr_catalog.template_property.format_version IS 'フォーマットバージョン';
COMMENT ON COLUMN pxr_catalog.template_property.unit_code IS '単位コード';
COMMENT ON COLUMN pxr_catalog.template_property.unit_version IS '単位バージョン';
COMMENT ON COLUMN pxr_catalog.template_property.description IS '説明';
COMMENT ON COLUMN pxr_catalog.template_property.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_catalog.template_property.attributes IS 'その他属性';
COMMENT ON COLUMN pxr_catalog.template_property.created_by IS '登録者';
COMMENT ON COLUMN pxr_catalog.template_property.created_at IS '登録日時';
COMMENT ON COLUMN pxr_catalog.template_property.updated_by IS '更新者';
COMMENT ON COLUMN pxr_catalog.template_property.updated_at IS '更新日時';

-- テンプレートコードテーブルを作成
DROP TABLE IF EXISTS pxr_catalog.template_code;
CREATE TABLE IF NOT EXISTS pxr_catalog.template_code
(
    id bigserial,
    template_property_id bigint NOT NULL,
    code bigint,
    version bigint,
    is_disabled boolean NOT NULL DEFAULT false,
    attributes text,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_catalog.template_code IS 'テンプレートプロパティテーブル';
COMMENT ON COLUMN pxr_catalog.template_code.id IS 'ID';
COMMENT ON COLUMN pxr_catalog.template_code.template_property_id IS 'プロパティ定義ID';
COMMENT ON COLUMN pxr_catalog.template_code.code IS 'コード';
COMMENT ON COLUMN pxr_catalog.template_code.version IS 'バージョン';
COMMENT ON COLUMN pxr_catalog.template_code.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_catalog.template_code.attributes IS 'その他属性';
COMMENT ON COLUMN pxr_catalog.template_code.created_by IS '登録者';
COMMENT ON COLUMN pxr_catalog.template_code.created_at IS '登録日時';
COMMENT ON COLUMN pxr_catalog.template_code.updated_by IS '更新者';
COMMENT ON COLUMN pxr_catalog.template_code.updated_at IS '更新日時';

-- プロパティ候補テーブルを作成
DROP TABLE IF EXISTS pxr_catalog.property_candidate;
CREATE TABLE IF NOT EXISTS pxr_catalog.property_candidate
(
    id bigserial,
    template_property_id bigint NOT NULL,
    ns_id bigint,
    is_descendant boolean NOT NULL DEFAULT false,
    code bigint,
    version bigint,
    base_code bigint,
    base_version bigint,
    value text,
    inners text,
    description text,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_catalog.property_candidate IS 'テンプレートプロパティテーブル';
COMMENT ON COLUMN pxr_catalog.property_candidate.id IS 'ID';
COMMENT ON COLUMN pxr_catalog.property_candidate.template_property_id IS 'プロパティ定義ID';
COMMENT ON COLUMN pxr_catalog.property_candidate.ns_id IS 'ネームスペースID';
COMMENT ON COLUMN pxr_catalog.property_candidate.is_descendant IS '子要素フラグ';
COMMENT ON COLUMN pxr_catalog.property_candidate.code IS 'コード';
COMMENT ON COLUMN pxr_catalog.property_candidate.version IS 'バージョン';
COMMENT ON COLUMN pxr_catalog.property_candidate.base_code IS '基底コード';
COMMENT ON COLUMN pxr_catalog.property_candidate.base_version IS '基底バージョン';
COMMENT ON COLUMN pxr_catalog.property_candidate.value IS '候補値';
COMMENT ON COLUMN pxr_catalog.property_candidate.inners IS '内部クラス';
COMMENT ON COLUMN pxr_catalog.property_candidate.description IS '説明';
COMMENT ON COLUMN pxr_catalog.property_candidate.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_catalog.property_candidate.created_by IS '登録者';
COMMENT ON COLUMN pxr_catalog.property_candidate.created_at IS '登録日時';
COMMENT ON COLUMN pxr_catalog.property_candidate.updated_by IS '更新者';
COMMENT ON COLUMN pxr_catalog.property_candidate.updated_at IS '更新日時';

-- カタログコード範囲を作成
DROP TABLE IF EXISTS pxr_catalog.catalog_code_scope;
CREATE TABLE IF NOT EXISTS pxr_catalog.catalog_code_scope
(
    id bigserial,
    type varchar(255) NOT NULL,
    start_code bigint NOT NULL,
    end_code bigint NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_catalog.catalog_code_scope IS 'カタログコード範囲テーブル';
COMMENT ON COLUMN pxr_catalog.catalog_code_scope.id IS 'ID';
COMMENT ON COLUMN pxr_catalog.catalog_code_scope.type IS 'タイプ';
COMMENT ON COLUMN pxr_catalog.catalog_code_scope.start_code IS 'コード開始';
COMMENT ON COLUMN pxr_catalog.catalog_code_scope.end_code IS 'コード終了';
COMMENT ON COLUMN pxr_catalog.catalog_code_scope.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_catalog.catalog_code_scope.created_by IS '登録者';
COMMENT ON COLUMN pxr_catalog.catalog_code_scope.created_at IS '登録日時';
COMMENT ON COLUMN pxr_catalog.catalog_code_scope.updated_by IS '更新者';
COMMENT ON COLUMN pxr_catalog.catalog_code_scope.updated_at IS '更新日時';

-- カタログ変更セット
DROP TABLE IF EXISTS pxr_catalog.update_set;
CREATE TABLE IF NOT EXISTS pxr_catalog.update_set
(
    id bigserial,
    name text NOT NULL,
    description text,
    type smallint,
    caller_actor_code bigint,
    caller_actor_version bigint,
    approval_actor_code bigint,
    approval_actor_version bigint,
    approver varchar(255),
    approval_at timestamp(3),
    comment text,
    status smallint NOT NULL DEFAULT 0,
    register_actor_code bigint,
    register_actor_version bigint,
    register varchar(255),
    regist_at timestamp(3),
    appendix text,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_catalog.update_set IS 'カタログ変更セットテーブル';
COMMENT ON COLUMN pxr_catalog.update_set.id IS 'ID';
COMMENT ON COLUMN pxr_catalog.update_set.name IS '名称';
COMMENT ON COLUMN pxr_catalog.update_set.description IS '説明';
COMMENT ON COLUMN pxr_catalog.update_set.type IS 'タイプ';
COMMENT ON COLUMN pxr_catalog.update_set.caller_actor_code IS '申請元アクターコード';
COMMENT ON COLUMN pxr_catalog.update_set.caller_actor_version IS '申請元アクターバージョン';
COMMENT ON COLUMN pxr_catalog.update_set.approval_actor_code IS '承認アクターコード';
COMMENT ON COLUMN pxr_catalog.update_set.approval_actor_version IS '承認アクターバージョン';
COMMENT ON COLUMN pxr_catalog.update_set.approver IS '承認者';
COMMENT ON COLUMN pxr_catalog.update_set.approval_at IS '承認日時';
COMMENT ON COLUMN pxr_catalog.update_set.comment IS '承認コメント';
COMMENT ON COLUMN pxr_catalog.update_set.status IS 'ステータス';
COMMENT ON COLUMN pxr_catalog.update_set.register_actor_code IS '登録アクターコード';
COMMENT ON COLUMN pxr_catalog.update_set.register_actor_version IS '登録アクターバージョン';
COMMENT ON COLUMN pxr_catalog.update_set.register IS '登録者';
COMMENT ON COLUMN pxr_catalog.update_set.regist_at IS '登録日時';
COMMENT ON COLUMN pxr_catalog.update_set.appendix IS 'その他';
COMMENT ON COLUMN pxr_catalog.update_set.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_catalog.update_set.created_by IS '登録者';
COMMENT ON COLUMN pxr_catalog.update_set.created_at IS '登録日時';
COMMENT ON COLUMN pxr_catalog.update_set.updated_by IS '更新者';
COMMENT ON COLUMN pxr_catalog.update_set.updated_at IS '更新日時';

-- 変更セットカタログ
DROP TABLE IF EXISTS pxr_catalog.catalog_update_set;
CREATE TABLE IF NOT EXISTS pxr_catalog.catalog_update_set
(
    id bigserial,
    update_set_id bigint NOT NULL,
    type smallint NOT NULL DEFAULT 0,
    catalog_item_id bigint,
    catalog_item_code bigint,
    comment text,
    template text NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_catalog.catalog_update_set IS '変更セットカタログテーブル';
COMMENT ON COLUMN pxr_catalog.catalog_update_set.id IS 'ID';
COMMENT ON COLUMN pxr_catalog.catalog_update_set.update_set_id IS '変更セットID';
COMMENT ON COLUMN pxr_catalog.catalog_update_set.type IS 'タイプ';
COMMENT ON COLUMN pxr_catalog.catalog_update_set.catalog_item_id IS '対象カタログ項目ID';
COMMENT ON COLUMN pxr_catalog.catalog_update_set.catalog_item_code IS '対象カタログ項目コード';
COMMENT ON COLUMN pxr_catalog.catalog_update_set.comment IS 'コメント';
COMMENT ON COLUMN pxr_catalog.catalog_update_set.template IS 'テンプレート';
COMMENT ON COLUMN pxr_catalog.catalog_update_set.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_catalog.catalog_update_set.created_by IS '登録者';
COMMENT ON COLUMN pxr_catalog.catalog_update_set.created_at IS '登録日時';
COMMENT ON COLUMN pxr_catalog.catalog_update_set.updated_by IS '更新者';
COMMENT ON COLUMN pxr_catalog.catalog_update_set.updated_at IS '更新日時';

-- 変更セットネームスペース
DROP TABLE IF EXISTS pxr_catalog.ns_update_set;
CREATE TABLE IF NOT EXISTS pxr_catalog.ns_update_set
(
    id bigserial,
    update_set_id bigint NOT NULL,
    type smallint NOT NULL DEFAULT 0,
    ns_id bigint,
    comment text,
    template text NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_catalog.ns_update_set IS '変更セットネームスペーステーブル';
COMMENT ON COLUMN pxr_catalog.ns_update_set.id IS 'ID';
COMMENT ON COLUMN pxr_catalog.ns_update_set.update_set_id IS '変更セットID';
COMMENT ON COLUMN pxr_catalog.ns_update_set.type IS 'タイプ';
COMMENT ON COLUMN pxr_catalog.ns_update_set.ns_id IS '対象ネームスペースID';
COMMENT ON COLUMN pxr_catalog.ns_update_set.comment IS 'コメント';
COMMENT ON COLUMN pxr_catalog.ns_update_set.template IS 'テンプレート';
COMMENT ON COLUMN pxr_catalog.ns_update_set.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_catalog.ns_update_set.created_by IS '登録者';
COMMENT ON COLUMN pxr_catalog.ns_update_set.created_at IS '登録日時';
COMMENT ON COLUMN pxr_catalog.ns_update_set.updated_by IS '更新者';
COMMENT ON COLUMN pxr_catalog.ns_update_set.updated_at IS '更新日時';

-- 変更セット属性
DROP TABLE IF EXISTS pxr_catalog.attribute_update_set;
CREATE TABLE IF NOT EXISTS pxr_catalog.attribute_update_set
(
    id bigserial,
    update_set_id bigint NOT NULL,
    type smallint NOT NULL DEFAULT 0,
    catalog_code bigint,
    comment text,
    attribute text NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_catalog.attribute_update_set IS '変更セット属性テーブル';
COMMENT ON COLUMN pxr_catalog.attribute_update_set.id IS 'ID';
COMMENT ON COLUMN pxr_catalog.attribute_update_set.update_set_id IS '変更セットID';
COMMENT ON COLUMN pxr_catalog.attribute_update_set.type IS 'タイプ';
COMMENT ON COLUMN pxr_catalog.attribute_update_set.catalog_code IS '対象カタログコード';
COMMENT ON COLUMN pxr_catalog.catalog_update_set.comment IS 'コメント';
COMMENT ON COLUMN pxr_catalog.attribute_update_set.attribute IS '属性テンプレート';
COMMENT ON COLUMN pxr_catalog.attribute_update_set.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_catalog.attribute_update_set.created_by IS '登録者';
COMMENT ON COLUMN pxr_catalog.attribute_update_set.created_at IS '登録日時';
COMMENT ON COLUMN pxr_catalog.attribute_update_set.updated_by IS '更新者';
COMMENT ON COLUMN pxr_catalog.attribute_update_set.updated_at IS '更新日時';

-- 外部キーを追加
ALTER TABLE pxr_catalog.catalog_item_attribute ADD FOREIGN KEY (catalog_item_id) REFERENCES pxr_catalog.catalog_item(id);
ALTER TABLE pxr_catalog.item_template ADD FOREIGN KEY (catalog_item_id) REFERENCES pxr_catalog.catalog_item(id);
-- ALTER TABLE pxr_catalog.item_template ADD FOREIGN KEY (template_property_id) REFERENCES pxr_catalog.template_property(id);
ALTER TABLE pxr_catalog.template_property ADD FOREIGN KEY (item_template_id) REFERENCES pxr_catalog.item_template(id);
ALTER TABLE pxr_catalog.cmatrix_index ADD FOREIGN KEY (catalog_item_id) REFERENCES pxr_catalog.catalog_item(id);
ALTER TABLE pxr_catalog.catalog_relationship ADD FOREIGN KEY (catalog_item_id) REFERENCES pxr_catalog.catalog_item(id);
ALTER TABLE pxr_catalog.catalog_update_set ADD FOREIGN KEY (update_set_id) REFERENCES pxr_catalog.update_set(id);
ALTER TABLE pxr_catalog.ns_update_set ADD FOREIGN KEY (update_set_id) REFERENCES pxr_catalog.update_set(id);

-- インデックスを追加
/*
DROP INDEX pxr_catalog.catalog_item_ns_id_idx;
DROP INDEX pxr_catalog.ns_name_idx;
DROP INDEX pxr_catalog.ns_type_idx;
DROP INDEX pxr_catalog.update_set_status_idx;
DROP INDEX pxr_catalog.ns_update_set_update_set_id_idx;
DROP INDEX pxr_catalog.catalog_update_set_update_set_id_idx;
DROP INDEX pxr_catalog.template_property_update_key_name_idx;
DROP INDEX pxr_catalog.catalog_item_attribute_key_code_key_version_idx;
DROP INDEX pxr_catalog.catalog_item_attribute_catalog_item_id_idx;
DROP INDEX pxr_catalog.cmatrix_index_catalog_item_id_idx;
*/
CREATE INDEX catalog_item_ns_id_idx ON pxr_catalog.catalog_item(ns_id);
CREATE INDEX ns_name_idx ON pxr_catalog.ns(name);
CREATE INDEX ns_type_idx ON pxr_catalog.ns(type);
CREATE INDEX update_set_status_idx ON pxr_catalog.update_set(status);
CREATE INDEX ns_update_set_update_set_id_idx ON pxr_catalog.ns_update_set(update_set_id);
CREATE INDEX catalog_update_set_update_set_id_idx ON pxr_catalog.catalog_update_set(update_set_id);
CREATE INDEX template_property_update_key_name_idx ON pxr_catalog.template_property(key_name);
CREATE INDEX catalog_item_attribute_key_code_key_version_idx ON pxr_catalog.catalog_item_attribute(key_code, key_version);
CREATE INDEX catalog_item_attribute_catalog_item_id_idx ON pxr_catalog.catalog_item_attribute(catalog_item_id);
CREATE INDEX cmatrix_index_catalog_item_id_idx ON pxr_catalog.cmatrix_index(catalog_item_id);







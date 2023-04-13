/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- 外部キーを削除(2回目以降のテーブル作成する時のみ必要)
/*
ALTER TABLE pxr_operator.session DROP CONSTRAINT session_operator_id_fkey;
ALTER TABLE pxr_operator.one_time_login_code DROP CONSTRAINT one_time_login_code_operator_id_fkey;
ALTER TABLE pxr_operator.role_setting DROP CONSTRAINT role_setting_operator_id_fkey;
ALTER TABLE pxr_operator.sms_verification_code DROP CONSTRAINT sms_verification_code_operator_id_fkey;
*/

-- オペレーターテーブルを作成
DROP TABLE IF EXISTS pxr_operator.operator;
CREATE TABLE IF NOT EXISTS pxr_operator.operator
(
    id bigserial,
    type smallint NOT NULL DEFAULT 0,
    login_id varchar(255) NOT NULL,
    hpassword varchar(255),
    pxr_id varchar(255),
    user_information text,
    name varchar(255),
    mobile_phone varchar(255),
    mail varchar(255),
    auth text,
    last_login_at timestamp(3),
    password_changed_flg boolean NOT NULL DEFAULT false,
    login_prohibited_flg boolean NOT NULL DEFAULT false,
    attributes text,
    lock_flg boolean NOT NULL DEFAULT false,
    lock_start_at timestamp(3) DEFAULT NULL,
    password_updated_at timestamp(3) DEFAULT NOW(),
    user_id varchar(255),
    region_catalog_code bigint,
    app_catalog_code bigint,
    wf_catalog_code bigint,
    client_id varchar(255),
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    unique_check_login_id text NOT NULL,
    PRIMARY KEY (id),
    UNIQUE(unique_check_login_id)
);
COMMENT ON TABLE pxr_operator.operator IS 'オペレーターテーブル';
COMMENT ON COLUMN pxr_operator.operator.id IS 'ID';
COMMENT ON COLUMN pxr_operator.operator.type IS '種別';
COMMENT ON COLUMN pxr_operator.operator.login_id IS 'ログインID';
COMMENT ON COLUMN pxr_operator.operator.hpassword IS 'ハッシュパスワード';
COMMENT ON COLUMN pxr_operator.operator.pxr_id IS 'PXR-ID';
COMMENT ON COLUMN pxr_operator.operator.user_information IS '利用者情報';
COMMENT ON COLUMN pxr_operator.operator.name IS '表示名';
COMMENT ON COLUMN pxr_operator.operator.mobile_phone IS '携帯電話番号';
COMMENT ON COLUMN pxr_operator.operator.mail IS 'メールアドレス';
COMMENT ON COLUMN pxr_operator.operator.auth IS '権限';
COMMENT ON COLUMN pxr_operator.operator.last_login_at IS '前回ログイン日時';
COMMENT ON COLUMN pxr_operator.operator.password_changed_flg IS 'パスワード変更フラグ（false: パスワード変更なし, true: パスワード変更済み）';
COMMENT ON COLUMN pxr_operator.operator.login_prohibited_flg IS 'ログイン不可フラグ（false: ログイン可能, true: ログイン不可）';
COMMENT ON COLUMN pxr_operator.operator.attributes IS 'その他属性';
COMMENT ON COLUMN pxr_operator.operator.lock_flg IS 'アカウントロックフラグ';
COMMENT ON COLUMN pxr_operator.operator.lock_start_at IS 'アカウントロック開始日時';
COMMENT ON COLUMN pxr_operator.operator.password_updated_at IS 'パスワード更新日時';
COMMENT ON COLUMN pxr_operator.operator.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_operator.operator.user_id IS '利用者ID';
COMMENT ON COLUMN pxr_operator.operator.region_catalog_code IS 'リージョンカタログコード';
COMMENT ON COLUMN pxr_operator.operator.app_catalog_code IS 'アプリケーションカタログコード';
COMMENT ON COLUMN pxr_operator.operator.wf_catalog_code IS 'ワークフローカタログコード';
COMMENT ON COLUMN pxr_operator.operator.client_id IS 'クライアントID';
COMMENT ON COLUMN pxr_operator.operator.created_by IS '登録者';
COMMENT ON COLUMN pxr_operator.operator.created_at IS '登録日時';
COMMENT ON COLUMN pxr_operator.operator.updated_by IS '更新者';
COMMENT ON COLUMN pxr_operator.operator.updated_at IS '更新日時';
COMMENT ON COLUMN pxr_operator.operator.unique_check_login_id is '一意性制約チェック列：login_id';

-- セッションテーブルを作成
DROP TABLE IF EXISTS pxr_operator.session;
CREATE TABLE IF NOT EXISTS pxr_operator.session
(
    id varchar(255) NOT NULL,
    operator_id bigint NOT NULL,
    expire_at timestamp(3) NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_operator.session IS 'セッションテーブル';
COMMENT ON COLUMN pxr_operator.session.id IS 'ID';
COMMENT ON COLUMN pxr_operator.session.operator_id IS 'オペレーターID';
COMMENT ON COLUMN pxr_operator.session.expire_at IS '有効期限';
COMMENT ON COLUMN pxr_operator.operator.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_operator.session.created_by IS '登録者';
COMMENT ON COLUMN pxr_operator.session.created_at IS '登録日時';
COMMENT ON COLUMN pxr_operator.session.updated_by IS '更新者';
COMMENT ON COLUMN pxr_operator.session.updated_at IS '更新日時';

-- ワンタイムログインコードテーブルを作成
DROP TABLE IF EXISTS pxr_operator.one_time_login_code;
CREATE TABLE IF NOT EXISTS pxr_operator.one_time_login_code
(
    id bigserial,
    code varchar(255) NOT NULL,
    operator_id bigint NOT NULL,
    expire_at timestamp(3) NOT NULL,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_operator.one_time_login_code IS 'ワンタイムログインコードテーブル';
COMMENT ON COLUMN pxr_operator.one_time_login_code.id IS 'ID';
COMMENT ON COLUMN pxr_operator.one_time_login_code.code IS 'ワンタイムコード';
COMMENT ON COLUMN pxr_operator.one_time_login_code.operator_id IS 'オペレーターID';
COMMENT ON COLUMN pxr_operator.one_time_login_code.expire_at IS '有効期限';
COMMENT ON COLUMN pxr_operator.one_time_login_code.created_by IS '登録者';
COMMENT ON COLUMN pxr_operator.one_time_login_code.created_at IS '登録日時';
COMMENT ON COLUMN pxr_operator.one_time_login_code.updated_by IS '更新者';
COMMENT ON COLUMN pxr_operator.one_time_login_code.updated_at IS '更新日時';

-- ロール設定テーブルを作成
DROP TABLE IF EXISTS pxr_operator.role_setting;
CREATE TABLE IF NOT EXISTS pxr_operator.role_setting
(
    id bigserial,
    operator_id bigint NOT NULL,
    role_catalog_code bigint NOT NULL,
    role_catalog_version bigint NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_operator.role_setting IS 'ロール設定テーブル';
COMMENT ON COLUMN pxr_operator.role_setting.id IS 'ID';
COMMENT ON COLUMN pxr_operator.role_setting.operator_id IS 'オペレーターID';
COMMENT ON COLUMN pxr_operator.role_setting.role_catalog_code IS 'ロールカタログコード';
COMMENT ON COLUMN pxr_operator.role_setting.role_catalog_version IS 'ロールカタログバージョン';
COMMENT ON COLUMN pxr_operator.role_setting.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_operator.role_setting.created_by IS '登録者';
COMMENT ON COLUMN pxr_operator.role_setting.created_at IS '登録日時';
COMMENT ON COLUMN pxr_operator.role_setting.updated_by IS '更新者';
COMMENT ON COLUMN pxr_operator.role_setting.updated_at IS '更新日時';

-- ログイン履歴管理テーブルを作成
DROP TABLE IF EXISTS pxr_operator.login_history;
CREATE TABLE IF NOT EXISTS pxr_operator.login_history
(
    id bigserial,
    operator_id bigint NOT NULL,
    login_at timestamp(3) NOT NULL,
    result boolean NOT NULL DEFAULT false,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_operator.login_history IS 'ログイン履歴管理テーブル';
COMMENT ON COLUMN pxr_operator.login_history.id IS 'ID';
COMMENT ON COLUMN pxr_operator.login_history.operator_id IS 'オペレーターID';
COMMENT ON COLUMN pxr_operator.login_history.login_at IS 'ログイン日時';
COMMENT ON COLUMN pxr_operator.login_history.result IS 'ログイン結果（false: 失敗, true: 成功）';
COMMENT ON COLUMN pxr_operator.login_history.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_operator.login_history.created_by IS '登録者';
COMMENT ON COLUMN pxr_operator.login_history.created_at IS '登録日時';
COMMENT ON COLUMN pxr_operator.login_history.updated_by IS '更新者';
COMMENT ON COLUMN pxr_operator.login_history.updated_at IS '更新日時';

-- パスワード履歴管理テーブルを作成
DROP TABLE IF EXISTS pxr_operator.password_history;
CREATE TABLE IF NOT EXISTS pxr_operator.password_history
(
    id bigserial,
    operator_id bigint NOT NULL,
    hpassword varchar(255) NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_operator.password_history IS 'パスワード履歴管理テーブル';
COMMENT ON COLUMN pxr_operator.password_history.id IS 'ID';
COMMENT ON COLUMN pxr_operator.password_history.operator_id IS 'オペレーターID';
COMMENT ON COLUMN pxr_operator.password_history.hpassword IS '更新前パスワード履歴';
COMMENT ON COLUMN pxr_operator.login_history.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_operator.login_history.created_by IS '登録者';
COMMENT ON COLUMN pxr_operator.login_history.created_at IS '登録日時';
COMMENT ON COLUMN pxr_operator.login_history.updated_by IS '更新者';
COMMENT ON COLUMN pxr_operator.login_history.updated_at IS '更新日時';

-- アクターコード管理テーブルの追加
DROP TABLE IF EXISTS pxr_operator.manage_block_info;
CREATE TABLE pxr_operator.manage_block_info
(
    id bigserial,
    actor_code bigint NOT NULL,
    actor_version bigint NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON COLUMN pxr_operator.manage_block_info.id IS 'id';
COMMENT ON COLUMN pxr_operator.manage_block_info.actor_code IS 'アクターコード';
COMMENT ON COLUMN pxr_operator.manage_block_info.actor_version IS 'アクターバージョン';
COMMENT ON COLUMN pxr_operator.manage_block_info.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_operator.manage_block_info.created_by IS '登録者';
COMMENT ON COLUMN pxr_operator.manage_block_info.created_at IS '登録日時';
COMMENT ON COLUMN pxr_operator.manage_block_info.updated_by IS '更新者';
COMMENT ON COLUMN pxr_operator.manage_block_info.updated_at IS '更新日時';

-- 利用者管理情報テーブルを作成
DROP TABLE IF EXISTS pxr_operator.user_information;
CREATE TABLE IF NOT EXISTS pxr_operator.user_information
(
    id bigserial,
    operator_id bigint NOT NULL,
    catalog_code bigint NOT NULL,
    catalog_version bigint NOT NULL,
    value text NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_operator.user_information IS '利用者管理情報テーブル';
COMMENT ON COLUMN pxr_operator.user_information.id IS 'ID';
COMMENT ON COLUMN pxr_operator.user_information.operator_id IS 'オペレーターID';
COMMENT ON COLUMN pxr_operator.user_information.catalog_code IS 'カタログコード';
COMMENT ON COLUMN pxr_operator.user_information.catalog_version IS 'カタログバージョン';
COMMENT ON COLUMN pxr_operator.user_information.value IS '設定値';
COMMENT ON COLUMN pxr_operator.user_information.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_operator.user_information.created_by IS '登録者';
COMMENT ON COLUMN pxr_operator.user_information.created_at IS '登録日時';
COMMENT ON COLUMN pxr_operator.user_information.updated_by IS '更新者';
COMMENT ON COLUMN pxr_operator.user_information.updated_at IS '更新日時';

-- 本人性確認コード管理テーブルを作成
DROP TABLE IF EXISTS pxr_operator.identify_code;
CREATE TABLE IF NOT EXISTS pxr_operator.identify_code
(
    id bigserial,
    code varchar(255) NOT NULL,
    pxr_id varchar(255) NOT NULL,
    expiration_at timestamp(3) NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_operator.identify_code IS '本人性確認コード管理テーブル';
COMMENT ON COLUMN pxr_operator.identify_code.id IS 'ID';
COMMENT ON COLUMN pxr_operator.identify_code.code IS 'コード';
COMMENT ON COLUMN pxr_operator.identify_code.pxr_id IS 'PXR-ID';
COMMENT ON COLUMN pxr_operator.identify_code.expiration_at IS '有効期限';
COMMENT ON COLUMN pxr_operator.identify_code.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_operator.identify_code.created_by IS '登録者';
COMMENT ON COLUMN pxr_operator.identify_code.created_at IS '登録日時';
COMMENT ON COLUMN pxr_operator.identify_code.updated_by IS '更新者';
COMMENT ON COLUMN pxr_operator.identify_code.updated_at IS '更新日時';

-- SMS検証コードテーブルを作成
DROP TABLE IF EXISTS pxr_operator.sms_verification_code;
CREATE TABLE IF NOT EXISTS pxr_operator.sms_verification_code
(
    id bigserial,
    operator_id bigint NOT NULL,
    verification_code varchar(255) NOT NULL,
    verification_code_expiration timestamp(3) NOT NULL,
    verification_result smallint NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

COMMENT ON TABLE pxr_operator.sms_verification_code IS 'SMS検証コード';
COMMENT ON COLUMN pxr_operator.sms_verification_code.id IS 'ID';
COMMENT ON COLUMN pxr_operator.sms_verification_code.operator_id IS 'オペレーターID';
COMMENT ON COLUMN pxr_operator.sms_verification_code.verification_code IS '検証コード';
COMMENT ON COLUMN pxr_operator.sms_verification_code.verification_code_expiration IS '検証コード有効期限';
COMMENT ON COLUMN pxr_operator.sms_verification_code.verification_result IS '検証結果 （1: 未検証, 2: 検証済）';
COMMENT ON COLUMN pxr_operator.sms_verification_code.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_operator.sms_verification_code.created_by IS '登録者';
COMMENT ON COLUMN pxr_operator.sms_verification_code.created_at IS '登録日時';
COMMENT ON COLUMN pxr_operator.sms_verification_code.updated_by IS '更新者';
COMMENT ON COLUMN pxr_operator.sms_verification_code.updated_at IS '更新日時';

-- 外部キーを追加
ALTER TABLE pxr_operator.session ADD FOREIGN KEY (operator_id) REFERENCES pxr_operator.operator(id);
ALTER TABLE pxr_operator.one_time_login_code ADD FOREIGN KEY (operator_id) REFERENCES pxr_operator.operator(id);
ALTER TABLE pxr_operator.role_setting ADD FOREIGN KEY (operator_id) REFERENCES pxr_operator.operator(id);
ALTER TABLE pxr_operator.sms_verification_code ADD FOREIGN KEY (operator_id) REFERENCES pxr_operator.operator(id);

-- インデックスを追加
/*
DROP INDEX pxr_operator.operator_pxr_id_idx;
DROP INDEX pxr_operator.operator_login_id_idx;
DROP INDEX pxr_operator.operator_user_id_idx;
DROP INDEX pxr_operator.operator_type_idx;
*/

CREATE INDEX operator_pxr_id_idx ON pxr_operator.operator(pxr_id);
CREATE INDEX operator_login_id_idx ON pxr_operator.operator(login_id);
CREATE INDEX operator_user_id_idx ON pxr_operator.operator(user_id);
CREATE INDEX operator_type_idx ON pxr_operator.operator(type);







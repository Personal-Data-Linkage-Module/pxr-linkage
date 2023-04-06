/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/

-- 証明書管理テーブルを作成
DROP TABLE IF EXISTS pxr_certification_authority.certificate_manage;
CREATE TABLE IF NOT EXISTS pxr_certification_authority.certificate_manage
(
    id bigserial NOT NULL,
    cert_type varchar(255) NOT NULL,
    subject text NOT NULL,
    serial_no varchar(255) NOT NULL,
    finger_print varchar(255) NOT NULL,
    valid_period_start timestamp(3) NOT NULL,
    valid_period_end timestamp(3) NOT NULL,
    certificate text NOT NULL,
    actor_code bigint,
    actor_version bigint,
    block_code bigint,
    block_version bigint,
    is_distributed boolean NOT NULL DEFAULT false,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_certification_authority.certificate_manage IS '証明書管理テーブル';
COMMENT ON COLUMN pxr_certification_authority.certificate_manage.id IS 'ID';
COMMENT ON COLUMN pxr_certification_authority.certificate_manage.cert_type IS '証明書タイプ';
COMMENT ON COLUMN pxr_certification_authority.certificate_manage.subject IS 'サブジェクト';
COMMENT ON COLUMN pxr_certification_authority.certificate_manage.serial_no IS 'シリアル番号';
COMMENT ON COLUMN pxr_certification_authority.certificate_manage.finger_print IS 'フィンガープリント';
COMMENT ON COLUMN pxr_certification_authority.certificate_manage.valid_period_start IS '有効期間開始';
COMMENT ON COLUMN pxr_certification_authority.certificate_manage.valid_period_end IS '有効期間終了';
COMMENT ON COLUMN pxr_certification_authority.certificate_manage.certificate IS '証明書(PEM)';
COMMENT ON COLUMN pxr_certification_authority.certificate_manage.actor_code IS 'アクターカタログコード';
COMMENT ON COLUMN pxr_certification_authority.certificate_manage.actor_version IS 'アクターカタログバージョン';
COMMENT ON COLUMN pxr_certification_authority.certificate_manage.block_code IS 'ブロックコード';
COMMENT ON COLUMN pxr_certification_authority.certificate_manage.block_version IS 'ブロックバージョン';
COMMENT ON COLUMN pxr_certification_authority.certificate_manage.is_distributed IS '配布フラグ';
COMMENT ON COLUMN pxr_certification_authority.certificate_manage.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_certification_authority.certificate_manage.created_by IS '登録者';
COMMENT ON COLUMN pxr_certification_authority.certificate_manage.created_at IS '登録日時';
COMMENT ON COLUMN pxr_certification_authority.certificate_manage.updated_by IS '更新者';
COMMENT ON COLUMN pxr_certification_authority.certificate_manage.updated_at IS '更新日時';







/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- 外部キーを削除(2回目以降のテーブル作成する時のみ必要)
/*
ALTER TABLE pxr_binary_manage.file_upload_data DROP CONSTRAINT file_upload_data_file_upload_manage_id_fkey;
*/

-- アップロードファイル管理テーブルを作成
DROP TABLE IF EXISTS pxr_binary_manage.file_upload_manage;
CREATE TABLE IF NOT EXISTS pxr_binary_manage.file_upload_manage
(
    id varchar(255) NOT NULL,
    file_name varchar(255) NOT NULL,
    status smallint NOT NULL DEFAULT 0,
    chunk_count smallint NOT NULL DEFAULT 0,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_binary_manage.file_upload_manage IS 'アップロードファイル管理テーブル';
COMMENT ON COLUMN pxr_binary_manage.file_upload_manage.id IS 'ID(UUID)';
COMMENT ON COLUMN pxr_binary_manage.file_upload_manage.file_name IS 'ファイル名';
COMMENT ON COLUMN pxr_binary_manage.file_upload_manage.status IS 'ステータス(0:アップロード中、1:アップロード完了、2:アップロードキャンセル)';
COMMENT ON COLUMN pxr_binary_manage.file_upload_manage.chunk_count IS '分割ファイル数';
COMMENT ON COLUMN pxr_binary_manage.file_upload_manage.is_disabled IS '削除フラグ';
COMMENT ON COLUMN pxr_binary_manage.file_upload_manage.created_by IS '登録者';
COMMENT ON COLUMN pxr_binary_manage.file_upload_manage.created_at IS '登録日時';
COMMENT ON COLUMN pxr_binary_manage.file_upload_manage.updated_by IS '更新者';
COMMENT ON COLUMN pxr_binary_manage.file_upload_manage.updated_at IS '更新日時';

-- アップロードファイルデータテーブルを作成
DROP TABLE IF EXISTS pxr_binary_manage.file_upload_data;
CREATE TABLE IF NOT EXISTS pxr_binary_manage.file_upload_data
(
    id bigserial,
    file_upload_manage_id varchar(255) NOT NULL,
    seq_no bigint NOT NULL DEFAULT 1,
    file_data bytea NOT NULL,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);
COMMENT ON TABLE pxr_binary_manage.file_upload_data IS 'アップロードファイルデータテーブル';
COMMENT ON COLUMN pxr_binary_manage.file_upload_data.id IS 'ID';
COMMENT ON COLUMN pxr_binary_manage.file_upload_data.file_upload_manage_id IS 'アップロードファイル管理ID';
COMMENT ON COLUMN pxr_binary_manage.file_upload_data.seq_no IS '連番';
COMMENT ON COLUMN pxr_binary_manage.file_upload_data.file_data IS 'ファイルデータ';
COMMENT ON COLUMN pxr_binary_manage.file_upload_data.created_by IS '登録者';
COMMENT ON COLUMN pxr_binary_manage.file_upload_data.created_at IS '登録日時';
COMMENT ON COLUMN pxr_binary_manage.file_upload_data.updated_by IS '更新者';
COMMENT ON COLUMN pxr_binary_manage.file_upload_data.updated_at IS '更新日時';

-- 外部キーを追加
ALTER TABLE pxr_binary_manage.file_upload_data ADD FOREIGN KEY (file_upload_manage_id) REFERENCES pxr_binary_manage.file_upload_manage(id);







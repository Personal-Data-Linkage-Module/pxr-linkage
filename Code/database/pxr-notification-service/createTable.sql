/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- 外部キーを削除
-- ALTER TABLE pxr_notification.notification_destination
--     DROP CONSTRAINT notification_destination_ibfk_1;
-- ALTER TABLE pxr_notification.approval_managed
--     DROP CONSTRAINT approval_managed_ibfk_1;
-- ALTER TABLE pxr_notification.readflag_management
--     DROP CONSTRAINT readflag_management_idfk_1;

-- 通知テーブルの作成
DROP TABLE IF EXISTS pxr_notification.notification CASCADE;
CREATE TABLE IF NOT EXISTS pxr_notification.notification
(
    id bigserial,
    type smallint NOT NULL DEFAULT 0,
    from_block_catalog_code bigint
     NOT NULL,
    from_application_catalog_code bigint,
    from_workflow_catalog_code bigint,
    from_operator_id bigint NOT NULL,
    from_actor_code bigint,
    from_actor_version bigint,
    to_block_catalog_code bigint NOT NULL,
    to_operator_type smallint NOT NULL,
    category_catalog_code bigint NOT NULL,
    category_catalog_version bigint NOT NULL,
    is_send_all boolean NOT NULL DEFAULT false,
    title varchar(255) NOT NULL,
    content text NOT NULL,
    attributes text DEFAULT '',
    send_at timestamp(3) NOT NULL,
    is_transfer boolean NOT NULL DEFAULT false,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- 宛先テーブルの作成
DROP TABLE IF EXISTS pxr_notification.notification_destination CASCADE;
CREATE TABLE IF NOT EXISTS pxr_notification.notification_destination
(
    id bigserial,
    notification_id bigint REFERENCES pxr_notification.notification (id),
    destination_operator_id bigint,
    destination_user_id varchar(255),
    actor_code bigint,
    actor_version bigint,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- 既読フラグテーブル
DROP TABLE IF EXISTS pxr_notification.readflag_management CASCADE;
CREATE TABLE IF NOT EXISTS pxr_notification.readflag_management
(
    id bigserial,
    notification_id bigint REFERENCES pxr_notification.notification (id),
    operator_id bigint NOT NULL,
    user_id varchar(255) NOT NULL,
    read_at timestamp(3) NOT NULL DEFAULT NOW(),
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- 承認管理テーブルの作成
DROP TABLE IF EXISTS pxr_notification.approval_managed CASCADE;
CREATE TABLE IF NOT EXISTS pxr_notification.approval_managed
(
    id bigserial,
    notification_id bigint REFERENCES pxr_notification.notification (id),
    approver_operator_id bigint,
    status smallint NOT NULL DEFAULT 0,
    comment varchar(255),
    approval_at timestamp(3),
    notice_block_code bigint NOT NULL,
    notice_url text NOT NULL,
    expiration_at timestamp(3) NOT NULL,
    is_disabled boolean NOT NULL DEFAULT false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT NOW(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- 外部キーを追加
ALTER TABLE pxr_notification.notification_destination
    ADD CONSTRAINT notification_destination_ibfk_1
    FOREIGN KEY (notification_id) REFERENCES pxr_notification.notification (id);
ALTER TABLE pxr_notification.readflag_management
    ADD CONSTRAINT readflag_management_idfk_1
    FOREIGN KEY (notification_id) REFERENCES pxr_notification.notification (id);
ALTER TABLE pxr_notification.approval_managed
    ADD CONSTRAINT approval_managed_ibfk_1
    FOREIGN KEY (notification_id) REFERENCES pxr_notification.notification (id);

-- インデックスを追加
-- DROP INDEX pxr_notification.notification_send_at_idx;
CREATE INDEX notification_send_at_idx ON pxr_notification.notification(send_at);

-- DROP INDEX pxr_notification.notification_destination_notification_id_idx;
-- DROP INDEX pxr_notification.notification_destination_destination_operator_id_idx;
CREATE INDEX notification_destination_notification_id_idx ON pxr_notification.notification_destination(notification_id);
CREATE INDEX notification_destination_destination_operator_id_idx ON pxr_notification.notification_destination(destination_operator_id);











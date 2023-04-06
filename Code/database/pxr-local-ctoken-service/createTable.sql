/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- 行ハッシュテーブル
DROP TABLE IF EXISTS pxr_local_ctoken.row_hash CASCADE;
CREATE TABLE IF NOT EXISTS pxr_local_ctoken.row_hash
(
    id bigserial,
    type smallint NOT NUll,
    status smallint NOT NUll default 0,
    "1_1" varchar(255) NOT NUll,
    "3_1_1" varchar(255) NOT NUll,
    "3_1_2_1" bigint,
    "3_1_2_2" bigint,
    "3_2_1" timestamp(3),
    "3_2_2" timestamp(3),
    "3_5_1_1" bigint,
    "3_5_1_2" bigint,
    "3_5_2_1" bigint,
    "3_5_2_2" bigint,
    "3_5_5_1" bigint,
    "3_5_5_2" bigint,
    "4_1_1" varchar(255) NOT NUll,
    "4_1_2_1" bigint,
    "4_1_2_2" bigint,
    "4_4_1_1" bigint,
    "4_4_1_2" bigint,
    "4_4_2_1" bigint,
    "4_4_2_2" bigint,
    "4_4_5_1" bigint,
    "4_4_5_2" bigint,
    row_hash varchar(255),
    row_hash_create_at timestamp(3),
    is_disabled boolean NOT NULL default false,
    created_by varchar(255) NOT NULL,
    created_at timestamp(3) NOT NULL DEFAULT now(),
    updated_by varchar(255) NOT NULL,
    updated_at timestamp(3) NOT NULL DEFAULT now(),
    PRIMARY KEY (id)
);

-- ドキュメントテーブル
DROP TABLE IF EXISTS pxr_local_ctoken.document CASCADE;
CREATE TABLE IF NOT EXISTS pxr_local_ctoken.document
(
    id bigserial,
    row_hash_id bigint NOT NUll,
    _1_1 varchar(255) NOT NUll,
    _1_2_1 bigint,
    _1_2_2 bigint,
    _2_1 timestamp(3),
    _3_1_1 bigint,
    _3_1_2 bigint,
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

-- DROP INDEX pxr_local_ctoken.row_hash_user_id_event_thing_identifier_idx;
CREATE INDEX row_hash_user_id_event_thing_identifier_idx ON pxr_local_ctoken.row_hash("1_1", "3_1_1", "4_1_1");






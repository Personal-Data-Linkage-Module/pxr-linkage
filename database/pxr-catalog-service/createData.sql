/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- カタログコード範囲にデータを追加
INSERT INTO pxr_catalog.catalog_code_scope
(
	type, start_code, end_code, is_disabled, created_by, created_at, updated_by, updated_at
)
VALUES
(
    'model',
    1,
    10000,
    false,
    'pxr_user', NOW(), 'pxr_user', NOW()
)
;
INSERT INTO pxr_catalog.catalog_code_scope
(
	type, start_code, end_code, is_disabled, created_by, created_at, updated_by, updated_at
)
VALUES
(
    'built_in',
    10001,
    1000000,
    false,
    'pxr_user', NOW(), 'pxr_user', NOW()
)
;
INSERT INTO pxr_catalog.catalog_code_scope
(
	type, start_code, end_code, is_disabled, created_by, created_at, updated_by, updated_at
)
VALUES
(
    'ext',
    1000001,
    10000000,
    false,
    'pxr_user', NOW(), 'pxr_user', NOW()
)
;

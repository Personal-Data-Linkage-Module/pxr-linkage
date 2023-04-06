/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- カラム制約変更
-- カタログ変更セット

ALTER TABLE pxr_catalog.update_set ALTER COLUMN type DROP NOT NULL;
ALTER TABLE pxr_catalog.update_set ALTER COLUMN type DROP DEFAULT;

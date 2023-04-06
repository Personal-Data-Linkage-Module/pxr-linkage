/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- インデックスを追加
CREATE INDEX catalog_item_ns_id_idx ON pxr_catalog.catalog_item(ns_id);

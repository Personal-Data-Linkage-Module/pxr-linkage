/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- インデックスを追加
CREATE INDEX my_condition_book_user_id_idx ON pxr_book_operate.my_condition_book(user_id);
CREATE INDEX event_catalog_code_version_is_disabled_idx ON pxr_book_operate.event(is_disabled, event_catalog_code, event_catalog_version);
CREATE INDEX event_updated_at_idx ON pxr_book_operate.event(updated_at);
CREATE INDEX event_my_condition_book_id_idx ON pxr_book_operate.event(my_condition_book_id);
CREATE INDEX thing_updated_at_idx ON pxr_book_operate.thing(updated_at);
CREATE INDEX thing_event_id_idx ON pxr_book_operate.thing(event_id);

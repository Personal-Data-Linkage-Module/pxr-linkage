/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
CREATE INDEX cmatrix_event_catalog_code_version_user_id_idx ON pxr_book_operate.cmatrix_event("3_1_2_1", "3_1_2_2", "1_1");
CREATE INDEX cmatrix_event_id_idx ON pxr_book_operate.cmatrix_thing(cmatrix_event_id);
CREATE INDEX cmatrix_thing_id_idx ON pxr_book_operate.cmatrix_floating_column(cmatrix_thing_id);

/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- インデックスを追加
CREATE INDEX api_token_search_token_idx ON pxr_access_control.api_token(expiration_date, caller_api_url, caller_operator_login_id, target_api_url, target_api_method, caller_block_code);
CREATE INDEX api_access_permission_token_idx ON pxr_access_control.api_access_permission(token, caller_api_url, target_api_url, target_api_method);

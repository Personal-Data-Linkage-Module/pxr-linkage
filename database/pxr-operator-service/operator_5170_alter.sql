/** Copyright 2022 NEC Corporation
Released under the MIT license.
https://opensource.org/licenses/mit-license.php
*/
-- type, wf/app/regionコードが同じlogin_idの一意制約チェック列を追加
ALTER TABLE pxr_operator.operator ADD column unique_check_login_id text;
COMMENT ON column pxr_operator.operator.unique_check_login_id is '一意性制約チェック列：login_id';

-- 既存レコードに値設定
UPDATE pxr_operator.operator SET unique_check_login_id = (case when is_disabled then cast(id as text) when "type" = 0 then (login_id || coalesce(cast(type as text), '')|| coalesce(cast(app_catalog_code as text), '') || coalesce(cast(wf_catalog_code as text), '') || coalesce(cast(region_catalog_code as text), '') || cast(login_prohibited_flg as text) || cast(is_disabled as text)) else (login_id || coalesce(cast(type as text), '')) end);

-- UNIQUE, NN制約の追加
ALTER TABLE pxr_operator.operator ALTER COLUMN unique_check_login_id SET NOT NULL;
ALTER TABLE pxr_operator.operator ADD UNIQUE(unique_check_login_id);

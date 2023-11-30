-- collection_request_consentにwf_catalog_code, app_catalog_codeカラム追加
ALTER TABLE pxr_book_operate.collection_request_consent ADD COLUMN wf_catalog_code bigint;
ALTER TABLE pxr_book_operate.collection_request_consent ADD COLUMN app_catalog_code bigint;

COMMENT ON COLUMN pxr_book_operate.collection_request_consent.wf_catalog_code IS 'ワークフローカタログコード';
COMMENT ON COLUMN pxr_book_operate.collection_request_consent.app_catalog_code IS 'アプリケーションカタログコード';
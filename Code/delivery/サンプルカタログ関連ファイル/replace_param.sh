#!/bin/sh

FIND=$(find . -path "./.git" -prune -o -path "./logs" -prune -o -path "./node_modules" -prune -o -type f -name "*.json")

for file in ${FIND}; do
  echo ${file}
  
  # 共通
  sed -i 's/{ext_name}/pxross1/g' $file
  sed -i 's/{pxr_root_actor_code}/1000431/g' $file
  sed -i 's/<ext_name>/pxross1/g' $file
  sed -i 's/<pxr_root_name>/A市データ連携基盤サービス運営事業者/g' $file
  sed -i 's/<global_setting_code>/1000374/g' $file
  sed -i 's/<pf_terms_code>/1000782/g' $file
  sed -i 's/<actor_setting_code>/1000731/g' $file
  sed -i 's/<actor_own_setting_code>/1000781/g' $file
  sed -i 's/<pxr_root_actor_code>/1000431/g' $file
  sed -i 's/<pxr_root_block_code>/1000401/g' $file
  sed -i 's/<person_item_type_address_code>/1000371/g' $file
  sed -i 's/<person_item_type_yob_code>/1000372/g' $file
  sed -i 's/<pxr_root_user_information_code>/1000373/g' $file
done

# society_catalog.json
TARGET='./society_catalog.json'
echo ${TARGET}
sed -i 's/<catalog_description>/パーソナルデータ連携モジュールが提供するデータカタログです。/g' ${TARGET}

# /ext/{ext_name}/actor/pxr-root/A市データ連携基盤サービス運営事業者_item.json
TARGET='./ext/pxross1/actor/pxr-root/A市データ連携基盤サービス運営事業者_item.json'
echo ${TARGET}
sed -i 's/<pf_description_title>/プラットフォーム概要/g' ${TARGET}
sed -i 's/<pf_description_subtitle>/プラットフォーム概要/g' ${TARGET}
sed -i 's/<pf_description_sentence>/プラットフォーム概要～/g' ${TARGET}
sed -i 's/<region_certification_criteria_title>/領域運営サービスプロバイダーの認定基準/g' ${TARGET}
sed -i 's/<region_certification_criteria_sentence>/領域運営サービスプロバイダーの認定基準です。/g' ${TARGET}
sed -i 's/<region_audit_procedure_title>/領域運営サービスプロバイダーの監査手順/g' ${TARGET}
sed -i 's/<region_audit_procedure_sentence>/領域運営サービスプロバイダーの監査手順です。/g' ${TARGET}
sed -i 's/<app_certification_criteria_title>/アプリケーションプロバイダーの認定基準/g' ${TARGET}
sed -i 's/<app_certification_criteria_sentence>/アプリケーションプロバイダーの認定基準です。/g' ${TARGET}
sed -i 's/<app_audit_procedure_title>/アプリケーションプロバイダーの監査手順/g' ${TARGET}
sed -i 's/<app_audit_procedure_sentence>/アプリケーションプロバイダーの監査手順です。/g' ${TARGET}
sed -i 's/<organization_statement_title>/組織ステートメント/g' ${TARGET}
sed -i 's/<organization_statement_subtitle>/組織ステートメント/g' ${TARGET}
sed -i 's/<organization_statement_sentence>/A市データ連携基盤サービス運営事業者です。/g' ${TARGET}

# /ext/{ext_name}/block/pxr-root/PXR-Root-Block_item.json
TARGET='./ext/pxross1/block/pxr-root/PXR-Root-Block_item.json'
echo ${TARGET}
sed -i 's/<domain>/domain.sample-pxr.jp/g' ${TARGET}

# /ext/{ext_name}/setting/actor-own/pxr-root/actor_{pxr_root_actor_code}/setting_item.json
TARGET='./ext/pxross1/setting/actor-own/pxr-root/actor_1000431/setting_item.json'
echo ${TARGET}
sed -i 's/<email-address>/test@test.jp/g' ${TARGET}
sed -i 's/<tel-number>/000-000-0000/g' ${TARGET}
sed -i 's/<address>//g' ${TARGET}
sed -i 's/<information-site>//g' ${TARGET}

# /ext/{ext_name}/setting/global/setting_item.json
TARGET='./ext/pxross1/setting/global/setting_item.json'
echo ${TARGET}
sed -i 's/<management_password_similarity_check>/true/g' ${TARGET}
sed -i 's/<pxr_id_prefix>//g' ${TARGET}
sed -i 's/<pxr_id_suffix>//g' ${TARGET}
sed -i 's/<pxr_id_password_similarity_check>/true/g' ${TARGET}
sed -i 's/<identity-verification-expiration_type>/day/g' ${TARGET}
sed -i 's/<identity-verification-expiration_value>/7/g' ${TARGET}
sed -i 's/<password-expiration_type>/day/g' ${TARGET}
sed -i 's/<password-expiration_value>/90/g' ${TARGET}
sed -i 's/<password-generations-number>/4/g' ${TARGET}
sed -i 's/<session-expiration_type>/hour/g' ${TARGET}
sed -i 's/<session-expiration_value>/3/g' ${TARGET}
sed -i 's/<account-lock-count>/6/g' ${TARGET}
sed -i 's/<account-lock-release-time_type>/minute/g' ${TARGET}
sed -i 's/<account-lock-release-time_value>/30/g' ${TARGET}
sed -i 's/<login_sms_message>/Your code is %s/g' ${TARGET}
sed -i 's/<book_create_sms_message>/%s?ID=%s パスワードは次のメッセージでお送りします/g' ${TARGET}
sed -i 's/<personal_disassociation>/true/g' ${TARGET}
sed -i 's/<personal_two-step_verification>/true/g' ${TARGET}
sed -i 's/<personal_share_basic_policy>/false/g' ${TARGET}
sed -i 's/<personal_account_delete>/false/g' ${TARGET}
sed -i 's/<use_app-p>/true/g' ${TARGET}
sed -i 's/<use_share>/true/g' ${TARGET}
sed -i 's/<region-tou_re-consent_notification_interval_type>/day/g' ${TARGET}
sed -i 's/<region-tou_re-consent_notification_interval_value>/3/g' ${TARGET}
sed -i 's/<platform-tou_re-consent_notification_interval_type>/day/g' ${TARGET}
sed -i 's/<platform-tou_re-consent_notification_interval_value>/3/g' ${TARGET}
sed -i 's/<use_region_service_operation>/true/g' ${TARGET}
sed -i 's/<min_period_for_platform-tou_re-consent_type>/day/g' ${TARGET}
sed -i 's/<min_period_for_platform-tou_re-consent_value>/7/g' ${TARGET}
sed -i 's/<min_period_for_region-tou_re-consent_type>/day/g' ${TARGET}
sed -i 's/<min_period_for_region-tou_re-consent_value>/7/g' ${TARGET}
sed -i 's/<book_deletion_pending_term_type>/day/g' ${TARGET}
sed -i 's/<book_deletion_pending_term_value>/14/g' ${TARGET}
sed -i 's/<data_download_term_expiration_type>/day/g' ${TARGET}
sed -i 's/<data_download_term_expiration_value>/14/g' ${TARGET}

# /ext/{ext_name}/terms-of-use/platform/pf-terms-of-use_item.json
TARGET='./ext/pxross1/terms-of-use/platform/pf-terms-of-use_item.json'
echo ${TARGET}
sed -i 's/<pf_terms_title>/プラットフォーム利用規約/g' ${TARGET}
sed -i 's/<pf_terms_subtitle>/第1項/g' ${TARGET}
sed -i 's/<pf_terms_sentence>/規約～～～。/g' ${TARGET}
sed -i 's/<re-consent-flag>/false/g' ${TARGET}
sed -i 's/<period-of-re-consent>/null/g' ${TARGET}
sed -i 's/<deleting-data-flag>/true/g' ${TARGET}
sed -i 's/<returning-data-flag>/true/g' ${TARGET}

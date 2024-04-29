--------------------------------------------------------
--  DDL for Package Body AMS_IMP_LIST_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IMP_LIST_HEADERS_PKG" as
/* $Header: amstimpb.pls 115.16 2002/11/14 21:59:35 jieli noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IMP_LIST_HEADERS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_IMP_LIST_HEADERS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstimpb.pls';


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createInsertBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
          px_import_list_header_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_view_application_id    NUMBER,
          p_name    VARCHAR2,
          p_version    VARCHAR2,
          p_import_type    VARCHAR2,
          p_owner_user_id    NUMBER,
          p_list_source_type_id    NUMBER,
          p_status_code    VARCHAR2,
          p_status_date    DATE,
          p_user_status_id    NUMBER,
          p_source_system    VARCHAR2,
          p_vendor_id    NUMBER,
          p_pin_id    NUMBER,
          px_org_id   IN OUT NOCOPY NUMBER,
          p_scheduled_time    DATE,
          p_loaded_no_of_rows    NUMBER,
          p_loaded_date    DATE,
          p_rows_to_skip    NUMBER,
          p_processed_rows    NUMBER,
          p_headings_flag    VARCHAR2,
          p_expiry_date    DATE,
          p_purge_date    DATE,
          p_description    VARCHAR2,
          p_keywords    VARCHAR2,
          p_transactional_cost    NUMBER,
          p_transactional_currency_code    VARCHAR2,
          p_functional_cost    NUMBER,
          p_functional_currency_code    VARCHAR2,
          p_terminated_by    VARCHAR2,
          p_enclosed_by    VARCHAR2,
          p_data_filename    VARCHAR2,
          p_process_immed_flag    VARCHAR2,
          p_dedupe_flag    VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          p_custom_setup_id    NUMBER,
          p_country    NUMBER,
          p_usage    NUMBER,
          p_number_of_records    NUMBER,
          p_data_file_name    VARCHAR2,
          p_b2b_flag    VARCHAR2,
          p_rented_list_flag    VARCHAR2,
          p_server_flag    VARCHAR2,
          p_log_file_name    NUMBER,
          p_number_of_failed_records    NUMBER,
          p_number_of_duplicate_records    NUMBER,
          p_enable_word_replacement_flag    VARCHAR2,
			 p_batch_id NUMBER,
			 p_server_name VARCHAR2,
			 p_user_name   VARCHAR2,
			 p_password    VARCHAR2,
			 p_upload_flag VARCHAR2,
			 p_parent_imp_header_id NUMBER,
			 p_record_update_flag VARCHAR2,
		    p_error_threshold NUMBER,
			 p_charset VARCHAR2)

 IS
  l_rowid VARCHAR2(20);
  cursor C is select ROWID from AMS_IMP_LIST_HEADERS_ALL
    where IMPORT_LIST_HEADER_ID = px_import_list_header_id;

BEGIN



   INSERT INTO AMS_IMP_LIST_HEADERS_ALL(
           import_list_header_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           view_application_id,
           name,
           version,
           import_type,
           owner_user_id,
           list_source_type_id,
           status_code,
           status_date,
           user_status_id,
           source_system,
           vendor_id,
           pin_id,
           org_id,
           scheduled_time,
           loaded_no_of_rows,
           loaded_date,
           rows_to_skip,
           processed_rows,
           headings_flag,
           expiry_date,
           purge_date,
           description,
           keywords,
           transactional_cost,
           transactional_currency_code,
           functional_cost,
           functional_currency_code,
           terminated_by,
           enclosed_by,
           data_filename,
           process_immed_flag,
           dedupe_flag,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           custom_setup_id,
           country,
           usage,
           number_of_records,
           data_file_name,
           b2b_flag,
           rented_list_flag,
           server_flag,
           log_file_name,
           number_of_failed_records,
           number_of_duplicate_records,
           enable_word_replacement_flag,
	   batch_id,
  	   execute_mode,
           validate_file,
		server_name,
		user_name,
		password,
		upload_flag,
		parent_imp_header_id,
		record_update_flag,
		error_threshold,
		charset
   ) VALUES (
           DECODE( px_import_list_header_id, FND_API.g_miss_num, NULL, px_import_list_header_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_view_application_id, FND_API.g_miss_num, NULL, p_view_application_id),
           DECODE( p_name, FND_API.g_miss_char, NULL, p_name),
           DECODE( p_version, FND_API.g_miss_char, NULL, p_version),
           DECODE( p_import_type, FND_API.g_miss_char, NULL, p_import_type),
           DECODE( p_owner_user_id, FND_API.g_miss_num, NULL, p_owner_user_id),
           DECODE( p_list_source_type_id, FND_API.g_miss_num, NULL, p_list_source_type_id),
           DECODE( p_status_code, FND_API.g_miss_char, NULL, p_status_code),
           DECODE( p_status_date, FND_API.g_miss_date, NULL, p_status_date),
           DECODE( p_user_status_id, FND_API.g_miss_num, NULL, p_user_status_id),
           DECODE( p_source_system, FND_API.g_miss_char, NULL, p_source_system),
           DECODE( p_vendor_id, FND_API.g_miss_num, NULL, p_vendor_id),
           DECODE( p_pin_id, FND_API.g_miss_num, NULL, p_pin_id),
           DECODE( px_org_id, FND_API.g_miss_num, NULL, px_org_id),
           DECODE( p_scheduled_time, FND_API.g_miss_date, NULL, p_scheduled_time),
           DECODE( p_loaded_no_of_rows, FND_API.g_miss_num, NULL, p_loaded_no_of_rows),
           DECODE( p_loaded_date, FND_API.g_miss_date, NULL, p_loaded_date),
           DECODE( p_rows_to_skip, FND_API.g_miss_num, NULL, p_rows_to_skip),
           DECODE( p_processed_rows, FND_API.g_miss_num, NULL, p_processed_rows),
           DECODE( p_headings_flag, FND_API.g_miss_char, NULL, p_headings_flag),
           DECODE( p_expiry_date, FND_API.g_miss_date, NULL, p_expiry_date),
           DECODE( p_purge_date, FND_API.g_miss_date, NULL, p_purge_date),
           DECODE( p_description, FND_API.g_miss_char, NULL, p_description),
           DECODE( p_keywords, FND_API.g_miss_char, NULL, p_keywords),
           DECODE( p_transactional_cost, FND_API.g_miss_num, NULL, p_transactional_cost),
           DECODE( p_transactional_currency_code, FND_API.g_miss_char, NULL, p_transactional_currency_code),
           DECODE( p_functional_cost, FND_API.g_miss_num, NULL, p_functional_cost),
           DECODE( p_functional_currency_code, FND_API.g_miss_char, NULL, p_functional_currency_code),
           DECODE( p_terminated_by, FND_API.g_miss_char, NULL, p_terminated_by),
           DECODE( p_enclosed_by, FND_API.g_miss_char, NULL, p_enclosed_by),
           DECODE( p_data_filename, FND_API.g_miss_char, NULL, p_data_filename),
           DECODE( p_process_immed_flag, FND_API.g_miss_char, NULL, p_process_immed_flag),
           DECODE( p_dedupe_flag, FND_API.g_miss_char, NULL, p_dedupe_flag),
           DECODE( p_attribute_category, FND_API.g_miss_char, NULL, p_attribute_category),
           DECODE( p_attribute1, FND_API.g_miss_char, NULL, p_attribute1),
           DECODE( p_attribute2, FND_API.g_miss_char, NULL, p_attribute2),
           DECODE( p_attribute3, FND_API.g_miss_char, NULL, p_attribute3),
           DECODE( p_attribute4, FND_API.g_miss_char, NULL, p_attribute4),
           DECODE( p_attribute5, FND_API.g_miss_char, NULL, p_attribute5),
           DECODE( p_attribute6, FND_API.g_miss_char, NULL, p_attribute6),
           DECODE( p_attribute7, FND_API.g_miss_char, NULL, p_attribute7),
           DECODE( p_attribute8, FND_API.g_miss_char, NULL, p_attribute8),
           DECODE( p_attribute9, FND_API.g_miss_char, NULL, p_attribute9),
           DECODE( p_attribute10, FND_API.g_miss_char, NULL, p_attribute10),
           DECODE( p_attribute11, FND_API.g_miss_char, NULL, p_attribute11),
           DECODE( p_attribute12, FND_API.g_miss_char, NULL, p_attribute12),
           DECODE( p_attribute13, FND_API.g_miss_char, NULL, p_attribute13),
           DECODE( p_attribute14, FND_API.g_miss_char, NULL, p_attribute14),
           DECODE( p_attribute15, FND_API.g_miss_char, NULL, p_attribute15),
           DECODE( p_custom_setup_id, FND_API.g_miss_num, NULL, p_custom_setup_id),
           DECODE( p_country, FND_API.g_miss_num, NULL, p_country),
           DECODE( p_usage, FND_API.g_miss_num, NULL, p_usage),
           DECODE( p_number_of_records, FND_API.g_miss_num, NULL, p_number_of_records),
           DECODE( p_data_file_name, FND_API.g_miss_char, NULL, p_data_file_name),
           DECODE( p_b2b_flag, FND_API.g_miss_char, NULL, p_b2b_flag),
           DECODE( p_rented_list_flag, FND_API.g_miss_char, NULL, p_rented_list_flag),
           DECODE( p_server_flag, FND_API.g_miss_char, NULL, p_server_flag),
           DECODE( p_log_file_name, FND_API.g_miss_num, NULL, p_log_file_name),
           DECODE( p_number_of_failed_records, FND_API.g_miss_num, NULL, p_number_of_failed_records),
           DECODE( p_number_of_duplicate_records, FND_API.g_miss_num, NULL, p_number_of_duplicate_records),
           DECODE( p_enable_word_replacement_flag, FND_API.g_miss_char, NULL, p_enable_word_replacement_flag),
           DECODE( p_batch_id, FND_API.g_miss_num, NULL, p_batch_id),
           'N',
           'Y',
			  DECODE( p_server_name, FND_API.g_miss_char, NULL, p_server_name),
			  DECODE( p_user_name, FND_API.g_miss_char, NULL, p_user_name),
			  DECODE( p_password, FND_API.g_miss_char, NULL, p_password),
			  DECODE( p_upload_flag, FND_API.g_miss_char, NULL, p_upload_flag),
			  DECODE( p_parent_imp_header_id, FND_API.g_miss_num, NULL, p_parent_imp_header_id),
			  DECODE( p_record_update_flag, FND_API.g_miss_char, NULL, p_record_update_flag),
			  DECODE( p_error_threshold, FND_API.g_miss_num, NULL, p_error_threshold),
			  DECODE( p_charset, FND_API.g_miss_char, NULL, p_charset)
			);

   INSERT INTO AMS_IMP_LIST_HEADERS_ALL_TL(
           import_list_header_id,
           last_update_date,
           last_update_by,
           creation_date,
           created_by,
           last_update_login,
           language,
           source_lang,
           name,
           description
   )  select
    px_import_list_header_id,
    p_last_update_date,
    p_last_updated_by,
    p_creation_date,
    p_created_by,
    p_last_update_login,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    p_name,
    p_description
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_IMP_LIST_HEADERS_ALL_TL T
    where T.IMPORT_LIST_HEADER_ID = px_import_list_header_id
    and T.LANGUAGE = L.LANGUAGE_CODE);

 open c;
  fetch c into l_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;


END Insert_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createUpdateBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_import_list_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_view_application_id    NUMBER,
          p_name    VARCHAR2,
          p_version    VARCHAR2,
          p_import_type    VARCHAR2,
          p_owner_user_id    NUMBER,
          p_list_source_type_id    NUMBER,
          p_status_code    VARCHAR2,
          p_status_date    DATE,
          p_user_status_id    NUMBER,
          p_source_system    VARCHAR2,
          p_vendor_id    NUMBER,
          p_pin_id    NUMBER,
          p_org_id    NUMBER,
          p_scheduled_time    DATE,
          p_loaded_no_of_rows    NUMBER,
          p_loaded_date    DATE,
          p_rows_to_skip    NUMBER,
          p_processed_rows    NUMBER,
          p_headings_flag    VARCHAR2,
          p_expiry_date    DATE,
          p_purge_date    DATE,
          p_description    VARCHAR2,
          p_keywords    VARCHAR2,
          p_transactional_cost    NUMBER,
          p_transactional_currency_code    VARCHAR2,
          p_functional_cost    NUMBER,
          p_functional_currency_code    VARCHAR2,
          p_terminated_by    VARCHAR2,
          p_enclosed_by    VARCHAR2,
          p_data_filename    VARCHAR2,
          p_process_immed_flag    VARCHAR2,
          p_dedupe_flag    VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          p_custom_setup_id    NUMBER,
          p_country    NUMBER,
          p_usage    NUMBER,
          p_number_of_records    NUMBER,
          p_data_file_name    VARCHAR2,
          p_b2b_flag    VARCHAR2,
          p_rented_list_flag    VARCHAR2,
          p_server_flag    VARCHAR2,
          p_log_file_name    NUMBER,
          p_number_of_failed_records    NUMBER,
          p_number_of_duplicate_records    NUMBER,
          p_enable_word_replacement_flag    VARCHAR2,
			 p_validate_file VARCHAR2,
			 p_record_update_flag VARCHAR2,
		    p_error_threshold NUMBER)

 IS
 BEGIN
    Update AMS_IMP_LIST_HEADERS_ALL
    SET
              import_list_header_id = DECODE( p_import_list_header_id, FND_API.g_miss_num, import_list_header_id, p_import_list_header_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              view_application_id = DECODE( p_view_application_id, FND_API.g_miss_num, view_application_id, p_view_application_id),
              name = DECODE( p_name, FND_API.g_miss_char, name, p_name),
              version = DECODE( p_version, FND_API.g_miss_char, version, p_version),
              import_type = DECODE( p_import_type, FND_API.g_miss_char, import_type, p_import_type),
              owner_user_id = DECODE( p_owner_user_id, FND_API.g_miss_num, owner_user_id, p_owner_user_id),
              list_source_type_id = DECODE( p_list_source_type_id, FND_API.g_miss_num, list_source_type_id, p_list_source_type_id),
              status_code = DECODE( p_status_code, FND_API.g_miss_char, status_code, p_status_code),
              status_date = DECODE( p_status_date, FND_API.g_miss_date, status_date, p_status_date),
              user_status_id = DECODE( p_user_status_id, FND_API.g_miss_num, user_status_id, p_user_status_id),
              source_system = DECODE( p_source_system, FND_API.g_miss_char, source_system, p_source_system),
              vendor_id = DECODE( p_vendor_id, FND_API.g_miss_num, vendor_id, p_vendor_id),
              pin_id = DECODE( p_pin_id, FND_API.g_miss_num, pin_id, p_pin_id),
              org_id = DECODE( p_org_id, FND_API.g_miss_num, org_id, p_org_id),
              scheduled_time = DECODE( p_scheduled_time, FND_API.g_miss_date, scheduled_time, p_scheduled_time),
              loaded_no_of_rows = DECODE( p_loaded_no_of_rows, FND_API.g_miss_num, loaded_no_of_rows, p_loaded_no_of_rows),
              loaded_date = DECODE( p_loaded_date, FND_API.g_miss_date, loaded_date, p_loaded_date),
              rows_to_skip = DECODE( p_rows_to_skip, FND_API.g_miss_num, rows_to_skip, p_rows_to_skip),
              processed_rows = DECODE( p_processed_rows, FND_API.g_miss_num, processed_rows, p_processed_rows),
              headings_flag = DECODE( p_headings_flag, FND_API.g_miss_char, headings_flag, p_headings_flag),
              expiry_date = DECODE( p_expiry_date, FND_API.g_miss_date, expiry_date, p_expiry_date),
              purge_date = DECODE( p_purge_date, FND_API.g_miss_date, purge_date, p_purge_date),
              description = DECODE( p_description, FND_API.g_miss_char, description, p_description),
              keywords = DECODE( p_keywords, FND_API.g_miss_char, keywords, p_keywords),
              transactional_cost = DECODE( p_transactional_cost, FND_API.g_miss_num, transactional_cost, p_transactional_cost),
              transactional_currency_code = DECODE( p_transactional_currency_code, FND_API.g_miss_char, transactional_currency_code, p_transactional_currency_code),
              functional_cost = DECODE( p_functional_cost, FND_API.g_miss_num, functional_cost, p_functional_cost),
              functional_currency_code = DECODE( p_functional_currency_code, FND_API.g_miss_char, functional_currency_code, p_functional_currency_code),
              terminated_by = DECODE( p_terminated_by, FND_API.g_miss_char, terminated_by, p_terminated_by),
              enclosed_by = DECODE( p_enclosed_by, FND_API.g_miss_char, enclosed_by, p_enclosed_by),
              data_filename = DECODE( p_data_filename, FND_API.g_miss_char, data_filename, p_data_filename),
              process_immed_flag = DECODE( p_process_immed_flag, FND_API.g_miss_char, process_immed_flag, p_process_immed_flag),
              dedupe_flag = DECODE( p_dedupe_flag, FND_API.g_miss_char, dedupe_flag, p_dedupe_flag),
              attribute_category = DECODE( p_attribute_category, FND_API.g_miss_char, attribute_category, p_attribute_category),
              attribute1 = DECODE( p_attribute1, FND_API.g_miss_char, attribute1, p_attribute1),
              attribute2 = DECODE( p_attribute2, FND_API.g_miss_char, attribute2, p_attribute2),
              attribute3 = DECODE( p_attribute3, FND_API.g_miss_char, attribute3, p_attribute3),
              attribute4 = DECODE( p_attribute4, FND_API.g_miss_char, attribute4, p_attribute4),
              attribute5 = DECODE( p_attribute5, FND_API.g_miss_char, attribute5, p_attribute5),
              attribute6 = DECODE( p_attribute6, FND_API.g_miss_char, attribute6, p_attribute6),
              attribute7 = DECODE( p_attribute7, FND_API.g_miss_char, attribute7, p_attribute7),
              attribute8 = DECODE( p_attribute8, FND_API.g_miss_char, attribute8, p_attribute8),
              attribute9 = DECODE( p_attribute9, FND_API.g_miss_char, attribute9, p_attribute9),
              attribute10 = DECODE( p_attribute10, FND_API.g_miss_char, attribute10, p_attribute10),
              attribute11 = DECODE( p_attribute11, FND_API.g_miss_char, attribute11, p_attribute11),
              attribute12 = DECODE( p_attribute12, FND_API.g_miss_char, attribute12, p_attribute12),
              attribute13 = DECODE( p_attribute13, FND_API.g_miss_char, attribute13, p_attribute13),
              attribute14 = DECODE( p_attribute14, FND_API.g_miss_char, attribute14, p_attribute14),
              attribute15 = DECODE( p_attribute15, FND_API.g_miss_char, attribute15, p_attribute15),
              custom_setup_id = DECODE( p_custom_setup_id, FND_API.g_miss_num, custom_setup_id, p_custom_setup_id),
              country = DECODE( p_country, FND_API.g_miss_num, country, p_country),
              usage = DECODE( p_usage, FND_API.g_miss_num, usage, p_usage),
              number_of_records = DECODE( p_number_of_records, FND_API.g_miss_num, number_of_records, p_number_of_records),
              data_file_name = DECODE( p_data_file_name, FND_API.g_miss_char, data_file_name, p_data_file_name),
              b2b_flag = DECODE( p_b2b_flag, FND_API.g_miss_char, b2b_flag, p_b2b_flag),
              rented_list_flag = DECODE( p_rented_list_flag, FND_API.g_miss_char, rented_list_flag, p_rented_list_flag),
              server_flag = DECODE( p_server_flag, FND_API.g_miss_char, server_flag, p_server_flag),
              log_file_name = DECODE( p_log_file_name, FND_API.g_miss_num, log_file_name, p_log_file_name),
              number_of_failed_records = DECODE( p_number_of_failed_records, FND_API.g_miss_num, number_of_failed_records, p_number_of_failed_records),
              number_of_duplicate_records = DECODE( p_number_of_duplicate_records, FND_API.g_miss_num, number_of_duplicate_records, p_number_of_duplicate_records),
              enable_word_replacement_flag = DECODE( p_enable_word_replacement_flag, FND_API.g_miss_char, enable_word_replacement_flag, p_enable_word_replacement_flag),
              validate_file = DECODE( p_validate_file, FND_API.g_miss_char, validate_file, p_validate_file),
				  record_update_flag = DECODE( p_record_update_flag, FND_API.g_miss_char, record_update_flag, p_record_update_flag),
				  error_threshold = DECODE( p_error_threshold, FND_API.g_miss_num, error_threshold, p_error_threshold)
	WHERE IMPORT_LIST_HEADER_ID = p_IMPORT_LIST_HEADER_ID
   AND   object_version_number = p_object_version_number;

  update AMS_IMP_LIST_HEADERS_ALL_TL
  set
           last_update_date=DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
           last_update_by=DECODE( p_last_updated_by, FND_API.g_miss_num, last_update_by, p_last_updated_by),
           last_update_login=DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
           source_lang=userenv('LANG'),
           name=DECODE( p_name, FND_API.g_miss_char, name, p_name),
           description=DECODE( p_description, FND_API.g_miss_char, description, p_description)
  where IMPORT_LIST_HEADER_ID = p_IMPORT_LIST_HEADER_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);


   IF (SQL%NOTFOUND) THEN
RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
END Update_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createDeleteBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_IMPORT_LIST_HEADER_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_IMP_LIST_HEADERS_ALL
    WHERE IMPORT_LIST_HEADER_ID = p_IMPORT_LIST_HEADER_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;



----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createLockBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
          p_import_list_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_view_application_id    NUMBER,
          p_name    VARCHAR2,
          p_version    VARCHAR2,
          p_import_type    VARCHAR2,
          p_owner_user_id    NUMBER,
          p_list_source_type_id    NUMBER,
          p_status_code    VARCHAR2,
          p_status_date    DATE,
          p_user_status_id    NUMBER,
          p_source_system    VARCHAR2,
          p_vendor_id    NUMBER,
          p_pin_id    NUMBER,
          p_org_id    NUMBER,
          p_scheduled_time    DATE,
          p_loaded_no_of_rows    NUMBER,
          p_loaded_date    DATE,
          p_rows_to_skip    NUMBER,
          p_processed_rows    NUMBER,
          p_headings_flag    VARCHAR2,
          p_expiry_date    DATE,
          p_purge_date    DATE,
          p_description    VARCHAR2,
          p_keywords    VARCHAR2,
          p_transactional_cost    NUMBER,
          p_transactional_currency_code    VARCHAR2,
          p_functional_cost    NUMBER,
          p_functional_currency_code    VARCHAR2,
          p_terminated_by    VARCHAR2,
          p_enclosed_by    VARCHAR2,
          p_data_filename    VARCHAR2,
          p_process_immed_flag    VARCHAR2,
          p_dedupe_flag    VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          p_custom_setup_id    NUMBER,
          p_country    NUMBER,
          p_usage    NUMBER,
          p_number_of_records    NUMBER,
          p_data_file_name    VARCHAR2,
          p_b2b_flag    VARCHAR2,
          p_rented_list_flag    VARCHAR2,
          p_server_flag    VARCHAR2,
          p_log_file_name    NUMBER,
          p_number_of_failed_records    NUMBER,
          p_number_of_duplicate_records    NUMBER,
          p_enable_word_replacement_flag    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_IMP_LIST_HEADERS_ALL
        WHERE IMPORT_LIST_HEADER_ID =  p_IMPORT_LIST_HEADER_ID
        FOR UPDATE of IMPORT_LIST_HEADER_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    If (c%NOTFOUND) then
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (
           (      Recinfo.import_list_header_id = p_import_list_header_id)
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.view_application_id = p_view_application_id)
            OR (    ( Recinfo.view_application_id IS NULL )
                AND (  p_view_application_id IS NULL )))
       AND (    ( Recinfo.name = p_name)
            OR (    ( Recinfo.name IS NULL )
                AND (  p_name IS NULL )))
       AND (    ( Recinfo.version = p_version)
            OR (    ( Recinfo.version IS NULL )
                AND (  p_version IS NULL )))
       AND (    ( Recinfo.import_type = p_import_type)
            OR (    ( Recinfo.import_type IS NULL )
                AND (  p_import_type IS NULL )))
       AND (    ( Recinfo.owner_user_id = p_owner_user_id)
            OR (    ( Recinfo.owner_user_id IS NULL )
                AND (  p_owner_user_id IS NULL )))
       AND (    ( Recinfo.list_source_type_id = p_list_source_type_id)
            OR (    ( Recinfo.list_source_type_id IS NULL )
                AND (  p_list_source_type_id IS NULL )))
       AND (    ( Recinfo.status_code = p_status_code)
            OR (    ( Recinfo.status_code IS NULL )
                AND (  p_status_code IS NULL )))
       AND (    ( Recinfo.status_date = p_status_date)
            OR (    ( Recinfo.status_date IS NULL )
                AND (  p_status_date IS NULL )))
       AND (    ( Recinfo.user_status_id = p_user_status_id)
            OR (    ( Recinfo.user_status_id IS NULL )
                AND (  p_user_status_id IS NULL )))
       AND (    ( Recinfo.source_system = p_source_system)
            OR (    ( Recinfo.source_system IS NULL )
                AND (  p_source_system IS NULL )))
       AND (    ( Recinfo.vendor_id = p_vendor_id)
            OR (    ( Recinfo.vendor_id IS NULL )
                AND (  p_vendor_id IS NULL )))
       AND (    ( Recinfo.pin_id = p_pin_id)
            OR (    ( Recinfo.pin_id IS NULL )
                AND (  p_pin_id IS NULL )))
       AND (    ( Recinfo.org_id = p_org_id)
            OR (    ( Recinfo.org_id IS NULL )
                AND (  p_org_id IS NULL )))
       AND (    ( Recinfo.scheduled_time = p_scheduled_time)
            OR (    ( Recinfo.scheduled_time IS NULL )
                AND (  p_scheduled_time IS NULL )))
       AND (    ( Recinfo.loaded_no_of_rows = p_loaded_no_of_rows)
            OR (    ( Recinfo.loaded_no_of_rows IS NULL )
                AND (  p_loaded_no_of_rows IS NULL )))
       AND (    ( Recinfo.loaded_date = p_loaded_date)
            OR (    ( Recinfo.loaded_date IS NULL )
                AND (  p_loaded_date IS NULL )))
       AND (    ( Recinfo.rows_to_skip = p_rows_to_skip)
            OR (    ( Recinfo.rows_to_skip IS NULL )
                AND (  p_rows_to_skip IS NULL )))
       AND (    ( Recinfo.processed_rows = p_processed_rows)
            OR (    ( Recinfo.processed_rows IS NULL )
                AND (  p_processed_rows IS NULL )))
       AND (    ( Recinfo.headings_flag = p_headings_flag)
            OR (    ( Recinfo.headings_flag IS NULL )
                AND (  p_headings_flag IS NULL )))
       AND (    ( Recinfo.expiry_date = p_expiry_date)
            OR (    ( Recinfo.expiry_date IS NULL )
                AND (  p_expiry_date IS NULL )))
       AND (    ( Recinfo.purge_date = p_purge_date)
            OR (    ( Recinfo.purge_date IS NULL )
                AND (  p_purge_date IS NULL )))
       AND (    ( Recinfo.description = p_description)
            OR (    ( Recinfo.description IS NULL )
                AND (  p_description IS NULL )))
       AND (    ( Recinfo.keywords = p_keywords)
            OR (    ( Recinfo.keywords IS NULL )
                AND (  p_keywords IS NULL )))
       AND (    ( Recinfo.transactional_cost = p_transactional_cost)
            OR (    ( Recinfo.transactional_cost IS NULL )
                AND (  p_transactional_cost IS NULL )))
       AND (    ( Recinfo.transactional_currency_code = p_transactional_currency_code)
            OR (    ( Recinfo.transactional_currency_code IS NULL )
                AND (  p_transactional_currency_code IS NULL )))
       AND (    ( Recinfo.functional_cost = p_functional_cost)
            OR (    ( Recinfo.functional_cost IS NULL )
                AND (  p_functional_cost IS NULL )))
       AND (    ( Recinfo.functional_currency_code = p_functional_currency_code)
            OR (    ( Recinfo.functional_currency_code IS NULL )
                AND (  p_functional_currency_code IS NULL )))
       AND (    ( Recinfo.terminated_by = p_terminated_by)
            OR (    ( Recinfo.terminated_by IS NULL )
                AND (  p_terminated_by IS NULL )))
       AND (    ( Recinfo.enclosed_by = p_enclosed_by)
            OR (    ( Recinfo.enclosed_by IS NULL )
                AND (  p_enclosed_by IS NULL )))
       AND (    ( Recinfo.data_filename = p_data_filename)
            OR (    ( Recinfo.data_filename IS NULL )
                AND (  p_data_filename IS NULL )))
       AND (    ( Recinfo.process_immed_flag = p_process_immed_flag)
            OR (    ( Recinfo.process_immed_flag IS NULL )
                AND (  p_process_immed_flag IS NULL )))
       AND (    ( Recinfo.dedupe_flag = p_dedupe_flag)
            OR (    ( Recinfo.dedupe_flag IS NULL )
                AND (  p_dedupe_flag IS NULL )))
       AND (    ( Recinfo.attribute_category = p_attribute_category)
            OR (    ( Recinfo.attribute_category IS NULL )
                AND (  p_attribute_category IS NULL )))
       AND (    ( Recinfo.attribute1 = p_attribute1)
            OR (    ( Recinfo.attribute1 IS NULL )
                AND (  p_attribute1 IS NULL )))
       AND (    ( Recinfo.attribute2 = p_attribute2)
            OR (    ( Recinfo.attribute2 IS NULL )
                AND (  p_attribute2 IS NULL )))
       AND (    ( Recinfo.attribute3 = p_attribute3)
            OR (    ( Recinfo.attribute3 IS NULL )
                AND (  p_attribute3 IS NULL )))
       AND (    ( Recinfo.attribute4 = p_attribute4)
            OR (    ( Recinfo.attribute4 IS NULL )
                AND (  p_attribute4 IS NULL )))
       AND (    ( Recinfo.attribute5 = p_attribute5)
            OR (    ( Recinfo.attribute5 IS NULL )
                AND (  p_attribute5 IS NULL )))
       AND (    ( Recinfo.attribute6 = p_attribute6)
            OR (    ( Recinfo.attribute6 IS NULL )
                AND (  p_attribute6 IS NULL )))
       AND (    ( Recinfo.attribute7 = p_attribute7)
            OR (    ( Recinfo.attribute7 IS NULL )
                AND (  p_attribute7 IS NULL )))
       AND (    ( Recinfo.attribute8 = p_attribute8)
            OR (    ( Recinfo.attribute8 IS NULL )
                AND (  p_attribute8 IS NULL )))
       AND (    ( Recinfo.attribute9 = p_attribute9)
            OR (    ( Recinfo.attribute9 IS NULL )
                AND (  p_attribute9 IS NULL )))
       AND (    ( Recinfo.attribute10 = p_attribute10)
            OR (    ( Recinfo.attribute10 IS NULL )
                AND (  p_attribute10 IS NULL )))
       AND (    ( Recinfo.attribute11 = p_attribute11)
            OR (    ( Recinfo.attribute11 IS NULL )
                AND (  p_attribute11 IS NULL )))
       AND (    ( Recinfo.attribute12 = p_attribute12)
            OR (    ( Recinfo.attribute12 IS NULL )
                AND (  p_attribute12 IS NULL )))
       AND (    ( Recinfo.attribute13 = p_attribute13)
            OR (    ( Recinfo.attribute13 IS NULL )
                AND (  p_attribute13 IS NULL )))
       AND (    ( Recinfo.attribute14 = p_attribute14)
            OR (    ( Recinfo.attribute14 IS NULL )
                AND (  p_attribute14 IS NULL )))
       AND (    ( Recinfo.attribute15 = p_attribute15)
            OR (    ( Recinfo.attribute15 IS NULL )
                AND (  p_attribute15 IS NULL )))
       AND (    ( Recinfo.custom_setup_id = p_custom_setup_id)
            OR (    ( Recinfo.custom_setup_id IS NULL )
                AND (  p_custom_setup_id IS NULL )))
       AND (    ( Recinfo.country = p_country)
            OR (    ( Recinfo.country IS NULL )
                AND (  p_country IS NULL )))
       AND (    ( Recinfo.usage = p_usage)
            OR (    ( Recinfo.usage IS NULL )
                AND (  p_usage IS NULL )))
       AND (    ( Recinfo.number_of_records = p_number_of_records)
            OR (    ( Recinfo.number_of_records IS NULL )
                AND (  p_number_of_records IS NULL )))
       AND (    ( Recinfo.data_file_name = p_data_file_name)
            OR (    ( Recinfo.data_file_name IS NULL )
                AND (  p_data_file_name IS NULL )))
       AND (    ( Recinfo.b2b_flag = p_b2b_flag)
            OR (    ( Recinfo.b2b_flag IS NULL )
                AND (  p_b2b_flag IS NULL )))
       AND (    ( Recinfo.rented_list_flag = p_rented_list_flag)
            OR (    ( Recinfo.rented_list_flag IS NULL )
                AND (  p_rented_list_flag IS NULL )))
       AND (    ( Recinfo.server_flag = p_server_flag)
            OR (    ( Recinfo.server_flag IS NULL )
                AND (  p_server_flag IS NULL )))
       AND (    ( Recinfo.log_file_name = p_log_file_name)
            OR (    ( Recinfo.log_file_name IS NULL )
                AND (  p_log_file_name IS NULL )))
       AND (    ( Recinfo.number_of_failed_records = p_number_of_failed_records)
            OR (    ( Recinfo.number_of_failed_records IS NULL )
                AND (  p_number_of_failed_records IS NULL )))
       AND (    ( Recinfo.number_of_duplicate_records = p_number_of_duplicate_records)
            OR (    ( Recinfo.number_of_duplicate_records IS NULL )
                AND (  p_number_of_duplicate_records IS NULL )))
       AND (    ( Recinfo.enable_word_replacement_flag = p_enable_word_replacement_flag)
            OR (    ( Recinfo.enable_word_replacement_flag IS NULL )
                AND (  p_enable_word_replacement_flag IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

-- --------------------------------------------------------
procedure ADD_LANGUAGE
is
begin
  delete from AMS_IMP_LIST_HEADERS_ALL_TL T
  where not exists
    (select NULL
    from AMS_IMP_LIST_HEADERS_ALL B
    where B.IMPORT_LIST_HEADER_ID = T.IMPORT_LIST_HEADER_ID
    );

  update AMS_IMP_LIST_HEADERS_ALL_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from AMS_IMP_LIST_HEADERS_ALL_TL B
    where B.IMPORT_LIST_HEADER_ID = T.IMPORT_LIST_HEADER_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.IMPORT_LIST_HEADER_ID,
      T.LANGUAGE
  ) in (select
      SUBT.IMPORT_LIST_HEADER_ID,
      SUBT.LANGUAGE
    from AMS_IMP_LIST_HEADERS_ALL_TL SUBB, AMS_IMP_LIST_HEADERS_ALL_TL SUBT
    where SUBB.IMPORT_LIST_HEADER_ID = SUBT.IMPORT_LIST_HEADER_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_IMP_LIST_HEADERS_ALL_TL (
    NAME,
    DESCRIPTION,
    LAST_UPDATE_LOGIN,
    IMPORT_LIST_HEADER_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATE_BY,
    CREATION_DATE,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_LOGIN,
    B.IMPORT_LIST_HEADER_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_IMP_LIST_HEADERS_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_IMP_LIST_HEADERS_ALL_TL T
    where T.IMPORT_LIST_HEADER_ID = B.IMPORT_LIST_HEADER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;

END AMS_IMP_LIST_HEADERS_PKG;

/

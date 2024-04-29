--------------------------------------------------------
--  DDL for Package Body AMS_APPR_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_APPR_HIST_PKG" as
/* $Header: amstaphb.pls 115.0 2002/12/01 12:12:03 vmodur noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Appr_Hist_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Appr_Hist_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstaphb.pls';




--  ========================================================
--
--  NAME
--  Insert_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          p_object_id   IN OUT NOCOPY NUMBER,
          p_object_type_code    VARCHAR2,
          p_sequence_num    NUMBER,
          p_object_version_num    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_action_code    VARCHAR2,
          p_action_date    DATE,
          p_approver_id    NUMBER,
          p_approval_detail_id    NUMBER,
          p_note    VARCHAR2,
          p_last_update_login    NUMBER,
          p_approval_type    VARCHAR2,
          p_approver_type    VARCHAR2,
          p_custom_setup_id    NUMBER,
	  p_log_message  VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);


BEGIN



   INSERT INTO ams_approval_history(
           object_id,
           object_type_code,
           sequence_num,
           object_version_num,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           action_code,
           action_date,
           approver_id,
           approval_detail_id,
           note,
           last_update_login,
           approval_type,
           approver_type,
           custom_setup_id,
	   log_message
   ) VALUES (
           DECODE( p_object_id, FND_API.G_MISS_NUM, NULL, p_object_id),
           DECODE( p_object_type_code, FND_API.g_miss_char, NULL, p_object_type_code),
           DECODE( p_sequence_num, FND_API.G_MISS_NUM, NULL, p_sequence_num),
           DECODE( p_object_version_num, FND_API.G_MISS_NUM, NULL, p_object_version_num),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_action_code, FND_API.g_miss_char, NULL, p_action_code),
           DECODE( p_action_date, FND_API.G_MISS_DATE, NULL, p_action_date),
           DECODE( p_approver_id, FND_API.G_MISS_NUM, NULL, p_approver_id),
           DECODE( p_approval_detail_id, FND_API.G_MISS_NUM, NULL, p_approval_detail_id),
           DECODE( p_note, FND_API.g_miss_char, NULL, p_note),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           DECODE( p_approval_type, FND_API.g_miss_char, NULL, p_approval_type),
           DECODE( p_approver_type, FND_API.g_miss_char, NULL, p_approver_type),
           DECODE( p_custom_setup_id, FND_API.G_MISS_NUM, NULL, p_custom_setup_id),
	   DECODE( p_log_message, FND_API.g_miss_char, NULL, p_log_message));

END Insert_Row;




--  ========================================================
--
--  NAME
--  Update_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_object_id    NUMBER,
          p_object_type_code    VARCHAR2,
          p_sequence_num    NUMBER,
          p_object_version_num    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_action_code    VARCHAR2,
          p_action_date    DATE,
          p_approver_id    NUMBER,
          p_approval_detail_id    NUMBER,
          p_note    VARCHAR2,
          p_last_update_login    NUMBER,
          p_approval_type    VARCHAR2,
          p_approver_type    VARCHAR2,
          p_custom_setup_id    NUMBER,
	  p_log_message  VARCHAR2)

 IS
 BEGIN
    Update ams_approval_history
    SET
              object_id = DECODE( p_object_id, null, object_id, FND_API.G_MISS_NUM, null, p_object_id),
              object_type_code = DECODE( p_object_type_code, null, object_type_code, FND_API.g_miss_char, null, p_object_type_code),
              sequence_num = DECODE( p_sequence_num, null, sequence_num, FND_API.G_MISS_NUM, null, p_sequence_num),
              object_version_num = DECODE( p_object_version_num, null, object_version_num, FND_API.G_MISS_NUM, null, p_object_version_num),
              last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              action_code = DECODE( p_action_code, null, action_code, FND_API.g_miss_char, null, p_action_code),
              action_date = DECODE( p_action_date, null, action_date, FND_API.G_MISS_DATE, null, p_action_date),
              approver_id = DECODE( p_approver_id, null, approver_id, FND_API.G_MISS_NUM, null, p_approver_id),
              approval_detail_id = DECODE( p_approval_detail_id, null, approval_detail_id, FND_API.G_MISS_NUM, null, p_approval_detail_id),
              note = DECODE( p_note, null, note, FND_API.g_miss_char, null, p_note),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
              approval_type = DECODE( p_approval_type, null, approval_type, FND_API.g_miss_char, null, p_approval_type),
              approver_type = DECODE( p_approver_type, null, approver_type, FND_API.g_miss_char, null, p_approver_type),
              custom_setup_id = DECODE( p_custom_setup_id, null, custom_setup_id, FND_API.G_MISS_NUM, null, p_custom_setup_id),
	      log_message = DECODE( p_log_message, null, log_message, FND_API.g_miss_char, null, p_log_message)
   WHERE object_id = p_object_id
   AND   object_type_code = p_object_type_code
   AND   approval_type = p_approval_type
   AND   sequence_num = p_sequence_num;

   /*
   IF (SQL%NOTFOUND) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   */


END Update_Row;




--  ========================================================
--
--  NAME
--  Delete_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_object_id  NUMBER,
    p_object_type_code    VARCHAR2,
    p_sequence_num    NUMBER,
    p_action_code   VARCHAR2,
    p_object_version_num    NUMBER,
    p_approval_type VARCHAR2)
 IS
 BEGIN
   DELETE FROM ams_approval_history
    WHERE object_id = DECODE( p_object_id, null, object_id, FND_API.G_MISS_NUM, null, p_object_id)
    AND object_type_code = DECODE( p_object_type_code, null, object_type_code, FND_API.g_miss_char, null, p_object_type_code)
    AND approval_type = DECODE( p_approval_type, null, approval_type, FND_API.g_miss_char, null, p_approval_type)
    AND sequence_num = DECODE( p_sequence_num, null, sequence_num, FND_API.G_MISS_NUM, null, p_sequence_num)
    AND object_version_num = DECODE( p_object_version_num, null, object_version_num, FND_API.G_MISS_NUM, null, p_object_version_num)
    AND action_code = DECODE( p_action_code, null, action_code, FND_API.g_miss_char, null, p_action_code);

    -- Do not need it as 'Open' rows will not exist in case of 1 approver
    -- and it is not possible to check for existence of these rows before
    -- deleting them
    -- Also 11.5.9 upgrade customers will get errors
    /*
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
   */
 END Delete_Row ;



END AMS_Appr_Hist_PKG;

/

--------------------------------------------------------
--  DDL for Package Body OZF_THRESHOLD_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_THRESHOLD_RULES_PKG" as
/* $Header: ozfttrub.pls 115.1 2003/11/28 12:27:14 pkarthik noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_THRESHOLD_RULES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_THRESHOLD_RULES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfttrub.pls';


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
PROCEDURE Insert_Row(
          px_threshold_rule_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_id    NUMBER,
          p_program_update_date    DATE,
          p_period_type    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_threshold_calendar   VARCHAR2,
          p_start_period_name    VARCHAR2,
          p_end_period_name    VARCHAR2,
          p_threshold_id    NUMBER,
          p_start_date    DATE,
          p_end_date    DATE,
          p_value_limit    VARCHAR2,
          p_operator_code    VARCHAR2,
          p_percent_amount    NUMBER,
          p_base_line    VARCHAR2,
          p_error_mode    VARCHAR2,
          p_repeat_frequency    NUMBER,
          p_frequency_period    VARCHAR2,
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
          p_org_id    NUMBER,
          p_security_group_id    NUMBER,
          p_converted_days    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_comparison_type    VARCHAR2,
          p_alert_type    VARCHAR2
          )

 IS
   x_rowid    VARCHAR2(30);


BEGIN
/*
   IF (p_org_id IS NULL OR p_org_id = FND_API.G_MISS_NUM) THEN
       SELECT NVL(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99)
       INTO p_org_id
       FROM DUAL;
   END IF;
*/

   px_object_version_number := 1;


   INSERT INTO OZF_THRESHOLD_RULES_ALL(
           threshold_rule_id,
           last_update_date,
           last_updated_by,
           last_update_login,
           creation_date,
           created_by,
           created_from,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           period_type,
           enabled_flag,
           threshold_calendar,
           start_period_name,
           end_period_name,
           threshold_id,
           start_date,
           end_date,
           value_limit,
           operator_code,
           percent_amount,
           base_line,
           error_mode,
           repeat_frequency,
           frequency_period,
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
           org_id,
           security_group_id,
           converted_days,
           object_version_number,
           comparison_type,
           alert_type
   ) VALUES (
           px_threshold_rule_id,
           p_last_update_date,
           p_last_updated_by,
           p_last_update_login,
           p_creation_date,
           p_created_by,
           p_created_from,
           p_request_id,
           p_program_application_id,
           p_program_id,
           p_program_update_date,
           p_period_type,
           p_enabled_flag,
           p_threshold_calendar,
           p_start_period_name,
           p_end_period_name,
           p_threshold_id,
           p_start_date,
           p_end_date,
           p_value_limit,
           p_operator_code,
           p_percent_amount,
           p_base_line,
           p_error_mode,
           p_repeat_frequency,
           p_frequency_period,
           p_attribute_category,
           p_attribute1,
           p_attribute2,
           p_attribute3,
           p_attribute4,
           p_attribute5,
           p_attribute6,
           p_attribute7,
           p_attribute8,
           p_attribute9,
           p_attribute10,
           p_attribute11,
           p_attribute12,
           p_attribute13,
           p_attribute14,
           p_attribute15,
           p_org_id,
           p_security_group_id,
           p_converted_days,
           px_object_version_number,
           p_comparison_type,
           p_alert_type);
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
          p_threshold_rule_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_created_from    VARCHAR2,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_id    NUMBER,
          p_program_update_date    DATE,
          p_period_type    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_threshold_calendar   VARCHAR2,
          p_start_period_name    VARCHAR2,
          p_end_period_name    VARCHAR2,
          p_threshold_id    NUMBER,
          p_start_date    DATE,
          p_end_date    DATE,
          p_value_limit    VARCHAR2,
          p_operator_code    VARCHAR2,
          p_percent_amount    NUMBER,
          p_base_line    VARCHAR2,
          p_error_mode    VARCHAR2,
          p_repeat_frequency    NUMBER,
          p_frequency_period    VARCHAR2,
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
          p_org_id    NUMBER,
          p_security_group_id    NUMBER,
          p_converted_days    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_comparison_type    VARCHAR2,
          p_alert_type    VARCHAR2
          )

 IS
 BEGIN
    Update OZF_THRESHOLD_RULES_ALL
    SET
              threshold_rule_id = p_threshold_rule_id,
              last_update_date = p_last_update_date,
              last_updated_by = p_last_updated_by,
              last_update_login = p_last_update_login,
              created_from = p_created_from,
              request_id = p_request_id,
              program_application_id = p_program_application_id,
              program_id = p_program_id,
              program_update_date = p_program_update_date,
              period_type = p_period_type,
              enabled_flag = p_enabled_flag,
              threshold_calendar = p_threshold_calendar,
              start_period_name = p_start_period_name,
              end_period_name = p_end_period_name,
              threshold_id = p_threshold_id,
              start_date = p_start_date,
              end_date = p_end_date,
              value_limit = p_value_limit,
              operator_code = p_operator_code,
              percent_amount = p_percent_amount,
              base_line = p_base_line,
              error_mode = p_error_mode,
              repeat_frequency = p_repeat_frequency,
              frequency_period = p_frequency_period,
              attribute_category = p_attribute_category,
              attribute1 = p_attribute1,
              attribute2 = p_attribute2,
              attribute3 = p_attribute3,
              attribute4 = p_attribute4,
              attribute5 = p_attribute5,
              attribute6 = p_attribute6,
              attribute7 = p_attribute7,
              attribute8 = p_attribute8,
              attribute9 = p_attribute9,
              attribute10 = p_attribute10,
              attribute11 = p_attribute11,
              attribute12 = p_attribute12,
              attribute13 = p_attribute13,
              attribute14 = p_attribute14,
              attribute15 = p_attribute15,
              --org_id = p_org_id,
              security_group_id = p_security_group_id,
              converted_days = p_converted_days,
              object_version_number = DECODE( px_object_version_number, FND_API.g_miss_num, object_version_number + 1, px_object_version_number + 1),
              comparison_type = p_comparison_type,
              alert_type = p_alert_type
   WHERE THRESHOLD_RULE_ID = p_THRESHOLD_RULE_ID
   AND   object_version_number = px_object_version_number;

   IF (SQL%NOTFOUND) THEN
RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   px_object_version_number := px_object_version_number + 1;

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
    p_THRESHOLD_RULE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM OZF_THRESHOLD_RULES_ALL
    WHERE THRESHOLD_RULE_ID = p_THRESHOLD_RULE_ID;
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
          p_threshold_rule_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_id    NUMBER,
          p_program_update_date    DATE,
          p_period_type    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_threshold_calendar   VARCHAR2,
          p_start_period_name    VARCHAR2,
          p_end_period_name    VARCHAR2,
          p_threshold_id    NUMBER,
          p_start_date    DATE,
          p_end_date    DATE,
          p_value_limit    VARCHAR2,
          p_operator_code    VARCHAR2,
          p_percent_amount    NUMBER,
          p_base_line    VARCHAR2,
          p_error_mode    VARCHAR2,
          p_repeat_frequency    NUMBER,
          p_frequency_period    VARCHAR2,
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
          p_org_id    NUMBER,
          p_security_group_id    NUMBER,
          p_converted_days    NUMBER,
          p_object_version_number    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM OZF_THRESHOLD_RULES_ALL
        WHERE THRESHOLD_RULE_ID =  p_THRESHOLD_RULE_ID
        FOR UPDATE of THRESHOLD_RULE_ID NOWAIT;
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
           (      Recinfo.threshold_rule_id = p_threshold_rule_id)
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.created_from = p_created_from)
            OR (    ( Recinfo.created_from IS NULL )
                AND (  p_created_from IS NULL )))
       AND (    ( Recinfo.request_id = p_request_id)
            OR (    ( Recinfo.request_id IS NULL )
                AND (  p_request_id IS NULL )))
       AND (    ( Recinfo.program_application_id = p_program_application_id)
            OR (    ( Recinfo.program_application_id IS NULL )
                AND (  p_program_application_id IS NULL )))
       AND (    ( Recinfo.program_id = p_program_id)
            OR (    ( Recinfo.program_id IS NULL )
                AND (  p_program_id IS NULL )))
       AND (    ( Recinfo.program_update_date = p_program_update_date)
            OR (    ( Recinfo.program_update_date IS NULL )
                AND (  p_program_update_date IS NULL )))
       AND (    ( Recinfo.period_type = p_period_type)
            OR (    ( Recinfo.period_type IS NULL )
                AND (  p_period_type IS NULL )))
       AND (    ( Recinfo.enabled_flag = p_enabled_flag)
            OR (    ( Recinfo.enabled_flag IS NULL )
                AND (  p_enabled_flag IS NULL )))
       AND (    ( Recinfo.threshold_calendar = p_threshold_calendar)
            OR (    ( Recinfo.threshold_calendar IS NULL )
                AND (  p_threshold_calendar IS NULL )))
       AND (    ( Recinfo.start_period_name = p_start_period_name)
            OR (    ( Recinfo.start_period_name IS NULL )
                AND (  p_start_period_name IS NULL )))
       AND (    ( Recinfo.end_period_name = p_end_period_name)
            OR (    ( Recinfo.end_period_name IS NULL )
                AND (  p_end_period_name IS NULL )))
       AND (    ( Recinfo.threshold_id = p_threshold_id)
            OR (    ( Recinfo.threshold_id IS NULL )
                AND (  p_threshold_id IS NULL )))
       AND (    ( Recinfo.start_date = p_start_date)
            OR (    ( Recinfo.start_date IS NULL )
                AND (  p_start_date IS NULL )))
       AND (    ( Recinfo.end_date = p_end_date)
            OR (    ( Recinfo.end_date IS NULL )
                AND (  p_end_date IS NULL )))
       AND (    ( Recinfo.value_limit = p_value_limit)
            OR (    ( Recinfo.value_limit IS NULL )
                AND (  p_value_limit IS NULL )))
       AND (    ( Recinfo.operator_code = p_operator_code)
            OR (    ( Recinfo.operator_code IS NULL )
                AND (  p_operator_code IS NULL )))
       AND (    ( Recinfo.percent_amount = p_percent_amount)
            OR (    ( Recinfo.percent_amount IS NULL )
                AND (  p_percent_amount IS NULL )))
       AND (    ( Recinfo.base_line = p_base_line)
            OR (    ( Recinfo.base_line IS NULL )
                AND (  p_base_line IS NULL )))
       AND (    ( Recinfo.error_mode = p_error_mode)
            OR (    ( Recinfo.error_mode IS NULL )
                AND (  p_error_mode IS NULL )))
       AND (    ( Recinfo.repeat_frequency = p_repeat_frequency)
            OR (    ( Recinfo.repeat_frequency IS NULL )
                AND (  p_repeat_frequency IS NULL )))
       AND (    ( Recinfo.frequency_period = p_frequency_period)
            OR (    ( Recinfo.frequency_period IS NULL )
                AND (  p_frequency_period IS NULL )))
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
       AND (    ( Recinfo.org_id = p_org_id)
            OR (    ( Recinfo.org_id IS NULL )
                AND (  p_org_id IS NULL )))
       AND (    ( Recinfo.security_group_id = p_security_group_id)
            OR (    ( Recinfo.security_group_id IS NULL )
                AND (  p_security_group_id IS NULL )))
       AND (    ( Recinfo.converted_days = p_converted_days)
            OR (    ( Recinfo.converted_days IS NULL )
                AND (  p_converted_days IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END OZF_THRESHOLD_RULES_PKG;

/

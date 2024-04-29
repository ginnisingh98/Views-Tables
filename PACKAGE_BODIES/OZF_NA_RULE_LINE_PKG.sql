--------------------------------------------------------
--  DDL for Package Body OZF_NA_RULE_LINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_NA_RULE_LINE_PKG" as
/* $Header: ozftdnlb.pls 120.0 2005/05/31 23:40:31 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Na_Rule_Line_PKG
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Na_Rule_Line_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstam.b.pls';




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
          px_na_rule_line_id   IN OUT NOCOPY NUMBER,
          p_na_rule_header_id    NUMBER,
          p_na_deduction_rule_id    NUMBER,
          p_active_flag    VARCHAR2,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO ozf_na_rule_lines(
           na_rule_line_id,
           na_rule_header_id,
           na_deduction_rule_id,
           active_flag,
           object_version_number,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login
   ) VALUES (
           DECODE( px_na_rule_line_id, FND_API.G_MISS_NUM, NULL, px_na_rule_line_id),
           DECODE( p_na_rule_header_id, FND_API.G_MISS_NUM, NULL, p_na_rule_header_id),
           DECODE( p_na_deduction_rule_id, FND_API.G_MISS_NUM, NULL, p_na_deduction_rule_id),
           DECODE( p_active_flag, FND_API.g_miss_char, NULL, p_active_flag),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login));

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
          p_na_rule_line_id    NUMBER,
          p_na_rule_header_id    NUMBER,
          p_na_deduction_rule_id    NUMBER,
          p_active_flag    VARCHAR2,
          p_object_version_number   IN NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER)

 IS
 BEGIN
    Update ozf_na_rule_lines
    SET
              na_rule_line_id = DECODE( p_na_rule_line_id, null, na_rule_line_id, FND_API.G_MISS_NUM, null, p_na_rule_line_id),
              na_rule_header_id = DECODE( p_na_rule_header_id, null, na_rule_header_id, FND_API.G_MISS_NUM, null, p_na_rule_header_id),
              na_deduction_rule_id = DECODE( p_na_deduction_rule_id, null, na_deduction_rule_id, FND_API.G_MISS_NUM, null, p_na_deduction_rule_id),
              active_flag = DECODE( p_active_flag, null, active_flag, FND_API.g_miss_char, null, p_active_flag),
            object_version_number = nvl(p_object_version_number,0) + 1 ,
              last_update_date = DECODE( p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(NULL), p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login)
   WHERE na_rule_line_id = p_na_rule_line_id
   AND   object_version_number = p_object_version_number;


   IF (SQL%NOTFOUND) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


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
    p_na_rule_line_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM ozf_na_rule_lines
    WHERE na_rule_line_id = p_na_rule_line_id
    AND object_version_number = p_object_version_number;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;





--  ========================================================
--
--  NAME
--  Lock_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
    p_na_rule_line_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM ozf_na_rule_lines
        WHERE na_rule_line_id =  p_na_rule_line_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF na_rule_line_id NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN

   OPEN c;
   FETCH c INTO Recinfo;
   IF (c%NOTFOUND) THEN
      CLOSE c;
      AMS_Utility_PVT.error_message ('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c;
END Lock_Row;



END OZF_Na_Rule_Line_PKG;

/

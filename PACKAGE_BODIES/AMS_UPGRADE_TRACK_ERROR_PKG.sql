--------------------------------------------------------
--  DDL for Package Body AMS_UPGRADE_TRACK_ERROR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_UPGRADE_TRACK_ERROR_PKG" as
/* $Header: amstuteb.pls 120.0 2005/05/31 21:55:15 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_UPGRADE_TRACK_ERROR_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_UPGRADE_TRACK_ERROR_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstuteb.pls';


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
          p_object_code    VARCHAR2,
          p_object_id    NUMBER,
          p_creation_date    DATE,
          p_error_code    VARCHAR2,
          p_object_name    VARCHAR2,
          p_language    VARCHAR2,
          p_error_message    VARCHAR2,
          p_proposed_action    VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   INSERT INTO AMS_UPGRADE_TRACK_ERROR(
           object_code,
           object_id,
           creation_date,
           error_code,
           object_name,
           language,
           error_message,
           proposed_action
   ) VALUES (
           DECODE( p_object_code, FND_API.g_miss_char, NULL, p_object_code),
           DECODE( p_object_id, FND_API.g_miss_num, NULL, p_object_id),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_error_code, FND_API.g_miss_char, NULL, p_error_code),
           DECODE( p_object_name, FND_API.g_miss_char, NULL, p_object_name),
           DECODE( p_language, FND_API.g_miss_char, NULL, p_language),
           DECODE( p_error_message, FND_API.g_miss_char, NULL, p_error_message),
           DECODE( p_proposed_action, FND_API.g_miss_char, NULL, p_proposed_action));
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
          p_object_code    VARCHAR2,
          p_object_id    NUMBER,
          p_creation_date    DATE,
          p_error_code    VARCHAR2,
          p_object_name    VARCHAR2,
          p_language    VARCHAR2,
          p_error_message    VARCHAR2,
          p_proposed_action    VARCHAR2)

 IS
 BEGIN
    Update AMS_UPGRADE_TRACK_ERROR
    SET
              object_code = DECODE( p_object_code, FND_API.g_miss_char, object_code, p_object_code),
              object_id = DECODE( p_object_id, FND_API.g_miss_num, object_id, p_object_id),
              error_code = DECODE( p_error_code, FND_API.g_miss_char, error_code, p_error_code),
              object_name = DECODE( p_object_name, FND_API.g_miss_char, object_name, p_object_name),
              language = DECODE( p_language, FND_API.g_miss_char, language, p_language),
              error_message = DECODE( p_error_message, FND_API.g_miss_char, error_message, p_error_message),
              proposed_action = DECODE( p_proposed_action, FND_API.g_miss_char, proposed_action, p_proposed_action)
   WHERE OBJECT_CODE = p_object_code
   AND   OBJECT_ID = p_OBJECT_ID;

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
    p_OBJECT_CODE Number
    ,p_OBJECT_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_UPGRADE_TRACK_ERROR
    WHERE OBJECT_CODE = p_OBJECT_CODE
    AND   OBJECT_ID = p_OBJECT_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;

END AMS_UPGRADE_TRACK_ERROR_PKG;

/

--------------------------------------------------------
--  DDL for Package Body AMS_ADV_FILTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ADV_FILTER_PKG" as
/* $Header: amstadfb.pls 120.1 2005/06/27 05:39:16 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_ADV_FILTER_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_ADV_FILTER_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstadfb.pls';

--  ========================================================
--
--  NAME
--  createInsertBody
--
--  PURPOSE  To create a Database record in JTF_PERZ_QUERY_PARAM table.
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          px_query_param_id  IN OUT NOCOPY    NUMBER,
          p_query_id                   NUMBER,
          p_parameter_name             VARCHAR2,
          p_parameter_type             VARCHAR2,
          p_parameter_value            VARCHAR2,
          p_parameter_condition        VARCHAR2,
          p_parameter_sequence         NUMBER,
          p_created_by                 NUMBER,
          p_last_updated_by            NUMBER,
          p_last_update_date           DATE,
          p_last_update_login          NUMBER,
          p_security_group_id          NUMBER
                     )

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   INSERT INTO JTF_PERZ_QUERY_PARAM
   (
           query_param_id,
           query_id,
           parameter_name,
           parameter_type,
           parameter_value,
           parameter_condition,
           parameter_sequence,
           created_by,
           last_updated_by,
           last_update_date,
           last_update_login,
           security_group_id
   ) VALUES
   (
           DECODE( px_query_param_id, FND_API.g_miss_num, NULL, px_query_param_id),
           DECODE( p_query_id, FND_API.g_miss_num, NULL, p_query_id),
           DECODE( p_parameter_name, FND_API.g_miss_char, NULL, p_parameter_name),
           DECODE( p_parameter_type, FND_API.g_miss_char, NULL, p_parameter_type),
           DECODE( p_parameter_value, FND_API.g_miss_char, NULL, p_parameter_value),
           DECODE( p_parameter_condition, FND_API.g_miss_char, NULL, p_parameter_condition),
           DECODE( p_parameter_sequence, FND_API.g_miss_num, NULL, p_parameter_sequence),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( p_security_group_id, FND_API.g_miss_num, NULL, p_security_group_id)
   );
END Insert_Row;



--  ========================================================
--
--  NAME
--  create UpdateBody
--
--  PURPOSE  Update the Record in JTF_PERZ_QUERY_PARAM table.
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          px_query_param_id         NUMBER,
          p_query_id                NUMBER,
          p_parameter_name          VARCHAR2,
          p_parameter_type          VARCHAR2,
          p_parameter_value         VARCHAR2,
          p_parameter_condition     VARCHAR2,
          p_parameter_sequence      NUMBER,
          p_last_updated_by         NUMBER,
          p_last_update_date        DATE,
          p_last_update_login       NUMBER,
          p_security_group_id       NUMBER
                 )
 IS
         l_flag   VARCHAR2(4);
 BEGIN
         AMS_UTILITY_PVT.debug_message('Table Handler API: Update_row');

    Update JTF_PERZ_QUERY_PARAM
    SET
           parameter_name = DECODE( p_parameter_name, FND_API.g_miss_char, parameter_name, p_parameter_name),
           parameter_value = DECODE( p_parameter_value, FND_API.g_miss_char, parameter_value, p_parameter_value),
           parameter_condition = DECODE( p_parameter_condition, FND_API.g_miss_char, parameter_condition, p_parameter_condition),
           parameter_sequence = DECODE( p_parameter_sequence, FND_API.g_miss_num, parameter_sequence, p_parameter_sequence),
           last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
           last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
           last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
           security_group_id = DECODE( p_security_group_id, FND_API.g_miss_num, security_group_id, p_security_group_id)
   WHERE   query_param_id = px_query_param_id
   AND     query_id = p_query_id
   AND     parameter_type = p_parameter_type ;

   IF (SQL%NOTFOUND) THEN
     l_flag := 'true';
     AMS_UTILITY_PVT.debug_message('Table Handler API: Update_row Flag '|| l_flag);
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSE
     commit;
   END IF;

END Update_Row;


--  ========================================================
--
--  NAME
--  createDeleteBody
--
--  PURPOSE  Delete a Row from JTF_PERZ_QUERY_PARAM Table.
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_query_param_id NUMBER)
 IS
 BEGIN
    DELETE FROM JTF_PERZ_QUERY_PARAM
    WHERE query_param_id = p_query_param_id;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;



END AMS_ADV_FILTER_PKG;

/

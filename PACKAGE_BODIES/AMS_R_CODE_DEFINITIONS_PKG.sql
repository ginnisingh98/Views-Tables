--------------------------------------------------------
--  DDL for Package Body AMS_R_CODE_DEFINITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_R_CODE_DEFINITIONS_PKG" as
/* $Header: amstcdnb.pls 120.1 2005/06/27 05:39:43 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_R_CODE_DEFINITIONS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_R_CODE_DEFINITIONS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstcdnb.pls';


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
          p_creation_date    DATE,
          p_last_update_date    DATE,
          p_created_by    NUMBER,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_type    VARCHAR2,
          p_column_name    VARCHAR2,
          p_object_def    VARCHAR2,
          px_code_definition_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER)

 IS
   x_rowid    VARCHAR2(30);
   l_dbi_rank_count NUMBER:=0;

   CURSOR c_get_dbi_ranks IS
    SELECT count(*)
    FROM  BIM_R_CODE_DEFINITIONS
    WHERE object_type = 'RANK_DBI'
    and column_name = 'Z';


BEGIN


--AMS_UTILITY_PVT.debug_message( 'Inside insert Row ');

   px_object_version_number := 1;

   --AMS_UTILITY_PVT.debug_message( 'Before calling insert ');


   INSERT INTO BIM_R_CODE_DEFINITIONS(
           creation_date,
           last_update_date,
           created_by,
           last_updated_by,
           last_update_login,
           object_type,
           column_name,
           object_def,
           code_definition_id,
           object_version_number
   ) VALUES (
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( p_object_type, FND_API.g_miss_char, NULL, p_object_type),
           DECODE( p_column_name, FND_API.g_miss_char, NULL, p_column_name),
           DECODE( p_object_def, FND_API.g_miss_char, NULL, p_object_def),
          -- DECODE( px_code_definition_id, FND_API.g_miss_num, NULL, px_code_definition_id),
	  BIM_R_CODE_DEFINITIONS_s.NEXTVAL,
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number));

	  -- AMS_UTILITY_PVT.debug_message( 'After first Insert_Row '||p_object_type);

if( p_object_type = 'RANK') then

--AMS_UTILITY_PVT.debug_message( 'Inside Rank loop'||p_object_type);

--delete from BIM_R_CODE_DEFINITIONS where object_type = 'RANK_DBI';

INSERT INTO BIM_R_CODE_DEFINITIONS(
           creation_date,
           last_update_date,
           created_by,
           last_updated_by,
           last_update_login,
           object_type,
           column_name,
           object_def,
           code_definition_id,
           object_version_number
   ) VALUES (
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           'RANK_DBI',
           DECODE( p_column_name, FND_API.g_miss_char, NULL,'A',p_column_name,'B',p_column_name,'C',p_column_name,'D',p_column_name,'Z'),
           DECODE( p_object_def, FND_API.g_miss_char, NULL, p_object_def),
           BIM_R_CODE_DEFINITIONS_s.NEXTVAL,
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number));

	   --AMS_UTILITY_PVT.debug_message( 'After second Insert_Row ');

 OPEN c_get_dbi_ranks;

 FETCH c_get_dbi_ranks INTO l_dbi_rank_count  ;

      If (  l_dbi_rank_count>0) THEN

DELETE FROM  BIM_R_CODE_DEFINITIONS WHERE  column_name = 'Z';

END IF;

--AMS_UTILITY_PVT.debug_message( 'After third Insert_Row ');


INSERT INTO BIM_R_CODE_DEFINITIONS(
           creation_date,
           last_update_date,
           created_by,
           last_updated_by,
           last_update_login,
           object_type,
           column_name,
           object_def,
           code_definition_id,
           object_version_number)
   ( SELECT
           sysdate,
           sysdate,
           1,
           1,
           1,
           'RANK_DBI',
           'Z',
           rank_id,
           BIM_R_CODE_DEFINITIONS_s.NEXTVAL,
           1
     FROM AS_SALES_LEAD_RANKS_VL a
     --WHERE enabled_flag = 'Y'
     WHERE to_char(a.rank_id)
     NOT IN
   ( SELECT object_def from BIM_R_CODE_DEFINITIONS WHERE object_type = 'RANK' and column_name in ('A','B','C','D')
   )
   )
           ;

	   --AMS_UTILITY_PVT.debug_message( 'After fourth Insert_Row ');

end if;
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
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_type    VARCHAR2,
          p_column_name    VARCHAR2,
          p_object_def    VARCHAR2,
          p_code_definition_id    NUMBER,
          p_object_version_number    NUMBER)

 IS

 CURSOR c_get_dbi_ranks(l_code_definition_id IN NUMBER) IS
    SELECT count(*)
    FROM  BIM_R_CODE_DEFINITIONS
    WHERE object_type = 'RANK_DBI'
    and code_definition_id = l_code_definition_id;

CURSOR c_get_dbi_ranks2 IS
    SELECT count(*)
    FROM  BIM_R_CODE_DEFINITIONS
    WHERE object_type = 'RANK_DBI'
    and column_name = 'Z';


     l_dbi_rank_count NUMBER:=0;
     l_dbi_rank_count2 NUMBER:=0;

 BEGIN
    Update BIM_R_CODE_DEFINITIONS
    SET
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_type = DECODE( p_object_type, FND_API.g_miss_char, object_type, p_object_type),
              column_name = DECODE( p_column_name, FND_API.g_miss_char, column_name, p_column_name),
              object_def = DECODE( p_object_def, FND_API.g_miss_char, object_def, p_object_def),
              code_definition_id = DECODE( p_code_definition_id, FND_API.g_miss_num, code_definition_id, p_code_definition_id),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number + 1)
   WHERE CODE_DEFINITION_ID = p_CODE_DEFINITION_ID;

OPEN c_get_dbi_ranks(p_CODE_DEFINITION_ID+1);
FETCH c_get_dbi_ranks INTO l_dbi_rank_count;
CLOSE c_get_dbi_ranks;

      If (  l_dbi_rank_count>0) THEN



if( p_object_type = 'RANK') then

  Update BIM_R_CODE_DEFINITIONS
    SET
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_type = 'RANK_DBI',
              column_name = DECODE( p_column_name, FND_API.g_miss_char, column_name, p_column_name),
              object_def = DECODE( p_object_def, FND_API.g_miss_char, object_def, p_object_def),
              code_definition_id = DECODE( p_code_definition_id, FND_API.g_miss_num, code_definition_id, p_code_definition_id),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number + 1)
   WHERE CODE_DEFINITION_ID = p_CODE_DEFINITION_ID+1
         AND object_type = 'RANK_DBI';

OPEN c_get_dbi_ranks2;

 FETCH c_get_dbi_ranks2 INTO l_dbi_rank_count2  ;

      If (  l_dbi_rank_count2>0) THEN

DELETE FROM  BIM_R_CODE_DEFINITIONS WHERE  column_name = 'Z';


   INSERT INTO BIM_R_CODE_DEFINITIONS(
           creation_date,
           last_update_date,
           created_by,
           last_updated_by,
           last_update_login,
           object_type,
           column_name,
           object_def,
           code_definition_id,
           object_version_number)
   ( SELECT
           sysdate,
           sysdate,
           1,
           1,
           1,
           'RANK_DBI',
           'Z',
           rank_id,
           BIM_R_CODE_DEFINITIONS_s.NEXTVAL,
           1
     FROM AS_SALES_LEAD_RANKS_VL a
     --WHERE enabled_flag = 'Y'
     WHERE to_char(a.rank_id)
     NOT IN
   ( SELECT object_def from BIM_R_CODE_DEFINITIONS WHERE object_type = 'RANK')
   )
           ;

   END IF;
   END IF;
END IF;

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
    p_CODE_DEFINITION_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM BIM_R_CODE_DEFINITIONS
    WHERE CODE_DEFINITION_ID = p_CODE_DEFINITION_ID;

  DELETE FROM BIM_R_CODE_DEFINITIONS
    WHERE CODE_DEFINITION_ID = p_CODE_DEFINITION_ID + 1
    AND object_type = 'RANK_DBI';

 DELETE FROM  BIM_R_CODE_DEFINITIONS WHERE  column_name = 'Z';

 INSERT INTO BIM_R_CODE_DEFINITIONS(
           creation_date,
           last_update_date,
           created_by,
           last_updated_by,
           last_update_login,
           object_type,
           column_name,
           object_def,
           code_definition_id,
           object_version_number)
   ( SELECT
           sysdate,
           sysdate,
           1,
           1,
           1,
           'RANK_DBI',
           'Z',
           rank_id,
           BIM_R_CODE_DEFINITIONS_s.NEXTVAL,
           1
     FROM AS_SALES_LEAD_RANKS_VL a
     --WHERE enabled_flag = 'Y'
     WHERE to_char(a.rank_id)
     NOT IN
   ( SELECT object_def from BIM_R_CODE_DEFINITIONS WHERE object_type = 'RANK')
   )
           ;

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
          p_creation_date    DATE,
          p_last_update_date    DATE,
          p_created_by    NUMBER,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_type    VARCHAR2,
          p_column_name    VARCHAR2,
          p_object_def    VARCHAR2,
          p_code_definition_id    NUMBER,
          p_object_version_number    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM BIM_R_CODE_DEFINITIONS
        WHERE CODE_DEFINITION_ID =  p_CODE_DEFINITION_ID
        FOR UPDATE of CODE_DEFINITION_ID NOWAIT;
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
           (      Recinfo.creation_date = p_creation_date)
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.object_type = p_object_type)
            OR (    ( Recinfo.object_type IS NULL )
                AND (  p_object_type IS NULL )))
       AND (    ( Recinfo.column_name = p_column_name)
            OR (    ( Recinfo.column_name IS NULL )
                AND (  p_column_name IS NULL )))
       AND (    ( Recinfo.object_def = p_object_def)
            OR (    ( Recinfo.object_def IS NULL )
                AND (  p_object_def IS NULL )))
       AND (    ( Recinfo.code_definition_id = p_code_definition_id)
            OR (    ( Recinfo.code_definition_id IS NULL )
                AND (  p_code_definition_id IS NULL )))
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

END AMS_R_CODE_DEFINITIONS_PKG;

/

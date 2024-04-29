--------------------------------------------------------
--  DDL for Package Body HZ_MERGE_DICTIONARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MERGE_DICTIONARY_PKG" as
/* $Header: ARHMDTBB.pls 120.10 2006/04/26 09:37:26 vsegu noship $ */
-- Start of Comments
-- Package name     : HZ_MERGE_DICTIONARY_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'HZ_MERGE_DICTIONARY_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'arhtdtbb.pls';
----------------------------------
--Declaration of private procedures and functions
----------------------------------
PROCEDURE Validate_Parent_Entity(
           p_parent_entity IN VARCHAR2,
           p_owner IN VARCHAR2,
           p_error_text OUT NOCOPY VARCHAR2,
           p_return_status OUT NOCOPY VARCHAR2)
IS
  l_owner1 VARCHAR2(255);
  l_temp VARCHAR2(255);
  l_bool BOOLEAN;

CURSOR c_table IS
  SELECT 'Exists'
  FROM sys.ALL_OBJECTS
  WHERE OBJECT_NAME = p_parent_entity
--  AND OWNER = l_owner1
  AND (OBJECT_TYPE = 'TABLE' OR OBJECT_TYPE = 'VIEW')
  and rownum = 1;

CURSOR c_bulk IS
  SELECT BULK_FLAG, PK_COLUMN_NAME
  FROM HZ_MERGE_DICTIONARY
  WHERE ENTITY_NAME = p_parent_entity;

l_exist VARCHAR2(10);

  l_bulk_flag VARCHAR2(1);
  l_par_pkcol VARCHAR2(255);
  l_status VARCHAR2(255);

BEGIN
  l_bool := fnd_installation.GET_APP_INFO(p_owner,l_status,l_temp,l_owner1);
  IF p_parent_entity IS NULL  THEN
    p_return_status := 'N';
    p_error_text := 'HZ_INVALID_PARENTITY_NAME';
    RETURN ;
  END IF;

  OPEN c_bulk;
  FETCH c_bulk INTO l_bulk_flag, l_par_pkcol;
  IF c_bulk%NOTFOUND OR (l_bulk_flag IS NOT NULL AND l_bulk_flag = 'Y')
     OR (upper(l_par_pkcol) = 'ROWID') THEN
    CLOSE c_bulk;
    p_error_text := 'HZ_INVALID_PARENTITY';
    p_return_status := 'N';
    RETURN  ;
  END IF;
  CLOSE c_bulk;


  IF  FND_PROFILE.VALUE('USER_ID') = '1' THEN
    RETURN;
  END IF;


  OPEN c_table;
  FETCH c_table INTO l_exist;
  IF c_table%NOTFOUND THEN
     p_error_text := 'HZ_INVALID_PARENTITY_NAME';
     p_return_status := 'N';
    RETURN ;
  end if;


/*  Successful */
   p_return_status := 'Y';

end Validate_Parent_Entity;

PROCEDURE Validate_Primary_Key(
          p_primary_key IN VARCHAR2,
          p_owner IN VARCHAR2,
          p_entity_name IN VARCHAR2,
          p_error_message OUT NOCOPY VARCHAR2,
          p_return_status OUT NOCOPY VARCHAR2) IS
l_exist VARCHAR2(10);
l_status VARCHAR2(255);
l_owner1 VARCHAR2(255);
l_temp VARCHAR2(255);
l_bool BOOLEAN;

CURSOR c_table_col IS
  SELECT 'Exists'
  FROM sys.ALL_TAB_COLUMNS
  WHERE TABLE_NAME = p_entity_name
  AND COLUMN_NAME = p_primary_key
  --and owner = l_owner1;
  and rownum = 1;


BEGIN
  l_bool := fnd_installation.GET_APP_INFO(p_owner,l_status,l_temp,l_owner1);
  IF p_primary_key IS NULL OR FND_PROFILE.VALUE('USER_ID') = '1'
     OR p_primary_key = 'ROWID' THEN
    p_error_message := 'HZ_INVALID_PK_COLUMN';
    p_return_status := 'N';
    RETURN;
  END IF;
/*
  IF p_primary_key IS NULL THEN
     p_error_message := 'HZ_INVALID_PK_COLUMN';
     p_return_status := 'N';
     RETURN;
  end if;
*/

  OPEN c_table_col;
  FETCH c_table_col INTO l_exist;
  IF c_table_col%NOTFOUND THEN
     p_error_message := 'HZ_INVALID_PK_COLUMN';
     p_return_status := 'N';
     RETURN;
  end if;
  CLOSE c_table_col;

/*  Successful */
   p_return_status := 'Y';

end Validate_Primary_Key;

PROCEDURE Validate_Foreign_Key(
          p_foreign_key IN VARCHAR2,
          p_owner IN VARCHAR2,
          p_entity_name IN VARCHAR2,
          p_error_message OUT NOCOPY VARCHAR2,
          p_return_status OUT NOCOPY VARCHAR2) IS
l_exist VARCHAR2(10);
l_status VARCHAR2(255);
l_owner1 VARCHAR2(255);
l_temp VARCHAR2(255);
l_bool BOOLEAN;
CURSOR c_table_col IS
  SELECT 'Exists'
  FROM sys.ALL_TAB_COLUMNS
  WHERE TABLE_NAME = p_entity_name
  AND COLUMN_NAME = p_foreign_key
  --and owner = l_owner1;
  and rownum = 1;

BEGIN
/*
  IF p_foreign_key IS NULL OR FND_PROFILE.VALUE('USER_ID') = '1' THEN
    RETURN;
  END IF;
*/
  l_bool := fnd_installation.GET_APP_INFO(p_owner,l_status,l_temp,l_owner1);
  IF p_entity_name IS NULL THEN
    p_error_message := 'HZ_INVALID_ENTITY_NAME';
    p_return_status := 'N';
    RETURN;
  end if;

  OPEN c_table_col;
  FETCH c_table_col INTO l_exist;
  IF c_table_col%NOTFOUND THEN
    p_error_message := 'HZ_INVALID_FK_COLUMN';
    p_return_status := 'N';
    RETURN;
  end if;
  CLOSE c_table_col;

/*  Successful */
   p_return_status := 'Y';

end Validate_Foreign_Key;

PROCEDURE Validate_Entity(
  p_entity_name IN VARCHAR2,
  p_owner IN VARCHAR2,
  p_error_message OUT NOCOPY VARCHAR2,
  p_return_status OUT NOCOPY VARCHAR2) IS
l_exist VARCHAR2(10);
l_status VARCHAR2(255);
l_owner1 VARCHAR2(255);
l_temp VARCHAR2(255);
l_bool BOOLEAN;
CURSOR c_table IS
  SELECT 'Exists'
  FROM sys.ALL_OBJECTS
  WHERE OBJECT_NAME = p_entity_name
  AND (OBJECT_TYPE = 'TABLE' OR OBJECT_TYPE = 'VIEW')
  and rownum = 1;
  --and owner = l_owner1;

BEGIN
/*
  IF p_entity_name IS NULL OR FND_PROFILE.VALUE('USER_ID') = '1' THEN
    RETURN;
  END IF;
*/
l_bool := fnd_installation.GET_APP_INFO(p_owner,l_status,l_temp,l_owner1);
  OPEN c_table;
  FETCH c_table INTO l_exist;
  IF c_table%NOTFOUND THEN
    p_error_message := 'HZ_INVALID_ENTITY_NAME';
    p_return_status := 'N';
    RETURN;
  end if;
/*  Successful */
   p_return_status := 'Y';

end Validate_Entity;

PROCEDURE Insert_Row(
          px_MERGE_DICT_ID   IN OUT NOCOPY NUMBER,
          p_RULE_SET_NAME    VARCHAR2,
          p_ENTITY_NAME    VARCHAR2,
          p_PARENT_ENTITY_NAME    VARCHAR2,
          p_PK_COLUMN_NAME    VARCHAR2,
          p_FK_COLUMN_NAME    VARCHAR2,
          p_DESC_COLUMN_NAME    VARCHAR2,
          p_PROCEDURE_TYPE    VARCHAR2,
          p_PROCEDURE_NAME    VARCHAR2,
          p_JOIN_CLAUSE    VARCHAR2,
          p_DICT_APPLICATION_ID    NUMBER,
          p_DESCRIPTION    VARCHAR2,
          px_SEQUENCE_NO    IN OUT NOCOPY NUMBER,
          p_BULK_FLAG    VARCHAR2,
	  p_BATCH_MERGE_FLAG VARCHAR2, --4634891
	  p_VALIDATE_PURGE_FLAG VARCHAR2, --5125968
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER)

 IS
   CURSOR C1(cp_md_id NUMBER) IS
      SELECT MERGE_DICT_ID FROM HZ_MERGE_DICTIONARY WHERE MERGE_DICT_ID=cp_md_id;

   CURSOR C2 IS SELECT HZ_MERGE_DICTIONARY_S.nextval FROM sys.dual;

   CURSOR C3 IS SELECT 10*(1+trunc(nvl(max(SEQUENCE_NO), 0)/10))
                FROM HZ_MERGE_DICTIONARY
                WHERE PARENT_ENTITY_NAME = p_PARENT_ENTITY_NAME;

   l_temp NUMBER;
BEGIN
   If (px_MERGE_DICT_ID IS NULL) OR (px_MERGE_DICT_ID = FND_API.G_MISS_NUM) then


       LOOP
         OPEN C2;
         FETCH C2 INTO px_MERGE_DICT_ID;
         CLOSE C2;

         OPEN C1(px_MERGE_DICT_ID);
         FETCH C1 INTO l_temp;
         EXIT WHEN C1%NOTFOUND;
         CLOSE C1;
       END LOOP;
       CLOSE C1;

   End If;

   If (px_SEQUENCE_NO IS NULL) OR (px_SEQUENCE_NO = FND_API.G_MISS_NUM) then
      if p_PARENT_ENTITY_NAME IS NOT NULL then
        OPEN C3;
        FETCH C3 INTO px_SEQUENCE_NO;
        CLOSE C3;

      else
        px_SEQUENCE_NO := 1;
      End if;
   End If;
   INSERT INTO HZ_MERGE_DICTIONARY(
           MERGE_DICT_ID,
           RULE_SET_NAME,
           ENTITY_NAME,
           PARENT_ENTITY_NAME,
           PK_COLUMN_NAME,
           FK_COLUMN_NAME,
           DESC_COLUMN_NAME,
           PROCEDURE_TYPE,
           PROCEDURE_NAME,
           JOIN_CLAUSE,
           DICT_APPLICATION_ID,
           DESCRIPTION,
           SEQUENCE_NO,
           BULK_FLAG,
	   BATCH_MERGE_FLAG, --4634891
	   VALIDATE_PURGE_FLAG, --5125968
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
          ) VALUES (
           px_MERGE_DICT_ID,
           decode( p_RULE_SET_NAME, FND_API.G_MISS_CHAR, NULL, p_RULE_SET_NAME),
           decode( p_ENTITY_NAME, FND_API.G_MISS_CHAR, NULL, p_ENTITY_NAME),
           decode( p_PARENT_ENTITY_NAME, FND_API.G_MISS_CHAR, NULL, p_PARENT_ENTITY_NAME),
           decode( p_PK_COLUMN_NAME, FND_API.G_MISS_CHAR, NULL, p_PK_COLUMN_NAME),
           decode( p_FK_COLUMN_NAME, FND_API.G_MISS_CHAR, NULL, p_FK_COLUMN_NAME),
           decode( p_DESC_COLUMN_NAME, FND_API.G_MISS_CHAR, NULL, p_DESC_COLUMN_NAME),
           decode( p_PROCEDURE_TYPE, FND_API.G_MISS_CHAR, NULL, p_PROCEDURE_TYPE),
           decode( p_PROCEDURE_NAME, FND_API.G_MISS_CHAR, NULL, p_PROCEDURE_NAME),
           decode( p_JOIN_CLAUSE, FND_API.G_MISS_CHAR, NULL, p_JOIN_CLAUSE),
           decode( p_DICT_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_DICT_APPLICATION_ID),
           decode( p_DESCRIPTION, FND_API.G_MISS_CHAR, NULL, p_DESCRIPTION),
           px_SEQUENCE_NO,
           decode( p_BULK_FLAG, FND_API.G_MISS_CHAR, NULL, p_BULK_FLAG),
	   decode( p_BATCH_MERGE_FLAG, FND_API.G_MISS_CHAR, NULL, p_BATCH_MERGE_FLAG), --4634891
	   decode( p_VALIDATE_PURGE_FLAG, FND_API.G_MISS_CHAR, NULL, p_VALIDATE_PURGE_FLAG), --5125968
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY));
End Insert_Row;

PROCEDURE Update_Row(
          p_MERGE_DICT_ID    NUMBER,
          p_RULE_SET_NAME    VARCHAR2,
          p_ENTITY_NAME    VARCHAR2,
          p_PARENT_ENTITY_NAME    VARCHAR2,
          p_PK_COLUMN_NAME    VARCHAR2,
          p_FK_COLUMN_NAME    VARCHAR2,
          p_DESC_COLUMN_NAME    VARCHAR2,
          p_PROCEDURE_TYPE    VARCHAR2,
          p_PROCEDURE_NAME    VARCHAR2,
          p_JOIN_CLAUSE    VARCHAR2,
          p_DICT_APPLICATION_ID    NUMBER,
          p_DESCRIPTION    VARCHAR2,
          px_SEQUENCE_NO    IN OUT NOCOPY NUMBER,
          p_BULK_FLAG    IN VARCHAR2,
	  p_BATCH_MERGE_FLAG IN VARCHAR2, --4634891
	  p_VALIDATE_PURGE_FLAG IN VARCHAR2, --5125968
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER)

 IS
   CURSOR C1 IS
     SELECT nvl(PARENT_ENTITY_NAME, 'NONAME')
     FROM HZ_MERGE_DICTIONARY
     WHERE MERGE_DICT_ID = p_MERGE_DICT_ID;

   CURSOR C3 IS SELECT 10*(1+trunc(nvl(max(SEQUENCE_NO), 0)/10))
                FROM HZ_MERGE_DICTIONARY
                WHERE PARENT_ENTITY_NAME = p_PARENT_ENTITY_NAME;

   l_old_parent_ent_name HZ_MERGE_DICTIONARY.PARENT_ENTITY_NAME%TYPE;
 BEGIN
    OPEN C1;
    FETCH C1 INTO l_old_parent_ent_name;
    CLOSE C1;

    IF l_old_parent_ent_name<> nvl(p_PARENT_ENTITY_NAME, 'NONAME') THEN
      OPEN C3;
      FETCH C3 INTO px_sequence_no;
      CLOSE C3;
    END IF;

    Update HZ_MERGE_DICTIONARY
    SET
              RULE_SET_NAME = decode( p_RULE_SET_NAME, FND_API.G_MISS_CHAR, RULE_SET_NAME, p_RULE_SET_NAME),
              ENTITY_NAME = decode( p_ENTITY_NAME, FND_API.G_MISS_CHAR, ENTITY_NAME, p_ENTITY_NAME),
              PARENT_ENTITY_NAME = decode( p_PARENT_ENTITY_NAME, FND_API.G_MISS_CHAR, PARENT_ENTITY_NAME, p_PARENT_ENTITY_NAME),
              PK_COLUMN_NAME = decode( p_PK_COLUMN_NAME, FND_API.G_MISS_CHAR, PK_COLUMN_NAME, p_PK_COLUMN_NAME),
              FK_COLUMN_NAME = decode( p_FK_COLUMN_NAME, FND_API.G_MISS_CHAR, FK_COLUMN_NAME, p_FK_COLUMN_NAME),
              DESC_COLUMN_NAME = decode( p_DESC_COLUMN_NAME, FND_API.G_MISS_CHAR, DESC_COLUMN_NAME, p_DESC_COLUMN_NAME),
              PROCEDURE_TYPE = decode( p_PROCEDURE_TYPE, FND_API.G_MISS_CHAR, PROCEDURE_TYPE, p_PROCEDURE_TYPE),
              PROCEDURE_NAME = decode( p_PROCEDURE_NAME, FND_API.G_MISS_CHAR, PROCEDURE_NAME, p_PROCEDURE_NAME),
              JOIN_CLAUSE = decode( p_JOIN_CLAUSE, FND_API.G_MISS_CHAR, JOIN_CLAUSE, p_JOIN_CLAUSE),
              DICT_APPLICATION_ID = decode( p_DICT_APPLICATION_ID, FND_API.G_MISS_NUM, DICT_APPLICATION_ID, p_DICT_APPLICATION_ID),
              DESCRIPTION = decode( p_DESCRIPTION, FND_API.G_MISS_CHAR, DESCRIPTION, p_DESCRIPTION),
              SEQUENCE_NO = decode( px_SEQUENCE_NO, FND_API.G_MISS_NUM, SEQUENCE_NO, px_SEQUENCE_NO),
              BULK_FLAG = decode( p_BULK_FLAG, FND_API.G_MISS_CHAR, BULK_FLAG, p_BULK_FLAG),
	      BATCH_MERGE_FLAG = decode( p_BATCH_MERGE_FLAG, FND_API.G_MISS_CHAR, BATCH_MERGE_FLAG, p_BATCH_MERGE_FLAG), -- 4634891
	      VALIDATE_PURGE_FLAG = decode( p_VALIDATE_PURGE_FLAG,  FND_API.G_MISS_CHAR, VALIDATE_PURGE_FLAG, p_VALIDATE_PURGE_FLAG), --5125968
              -- Bug 3032780
              /*
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              */
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY)
    where MERGE_DICT_ID = p_MERGE_DICT_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_MERGE_DICT_ID  NUMBER)
 IS
 BEGIN

BEGIN
  DELETE FROM HZ_MERGE_DICTIONARY hmd
  where parent_entity_name in ( select entity_name
                                from HZ_MERGE_DICTIONARY hmd1
                                where hmd1.merge_dict_id=p_MERGE_DICT_ID);
EXCEPTION
WHEN NO_DATA_FOUND THEN
     NULL;
END;

DELETE FROM HZ_MERGE_DICTIONARY
    WHERE MERGE_DICT_ID = p_MERGE_DICT_ID;


   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_MERGE_DICT_ID    NUMBER,
          p_RULE_SET_NAME    VARCHAR2,
          p_ENTITY_NAME    VARCHAR2,
          p_PARENT_ENTITY_NAME    VARCHAR2,
          p_PK_COLUMN_NAME    VARCHAR2,
          p_FK_COLUMN_NAME    VARCHAR2,
          p_DESC_COLUMN_NAME    VARCHAR2,
          p_PROCEDURE_TYPE    VARCHAR2,
          p_PROCEDURE_NAME    VARCHAR2,
          p_JOIN_CLAUSE    VARCHAR2,
          p_DICT_APPLICATION_ID    NUMBER,
          p_DESCRIPTION    VARCHAR2,
          p_SEQUENCE_NO    NUMBER,
          p_BULK_FLAG    VARCHAR2,
	  p_BATCH_MERGE_FLAG VARCHAR2, --4634891
	  p_VALIDATE_PURGE_FLAG VARCHAR2, --5125968
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM HZ_MERGE_DICTIONARY
        WHERE MERGE_DICT_ID =  p_MERGE_DICT_ID
        FOR UPDATE of MERGE_DICT_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;
    if (
           (      Recinfo.MERGE_DICT_ID = p_MERGE_DICT_ID)
       AND (    ( Recinfo.RULE_SET_NAME = p_RULE_SET_NAME)
            OR (    ( Recinfo.RULE_SET_NAME IS NULL )
                AND (  p_RULE_SET_NAME IS NULL )))
       AND (    ( Recinfo.ENTITY_NAME = p_ENTITY_NAME)
            OR (    ( Recinfo.ENTITY_NAME IS NULL )
                AND (  p_ENTITY_NAME IS NULL )))
       AND (    ( Recinfo.PARENT_ENTITY_NAME = p_PARENT_ENTITY_NAME)
            OR (    ( Recinfo.PARENT_ENTITY_NAME IS NULL )
                AND (  p_PARENT_ENTITY_NAME IS NULL )))
       AND (    ( Recinfo.PK_COLUMN_NAME = p_PK_COLUMN_NAME)
            OR (    ( Recinfo.PK_COLUMN_NAME IS NULL )
                AND (  p_PK_COLUMN_NAME IS NULL )))
       AND (    ( Recinfo.FK_COLUMN_NAME = p_FK_COLUMN_NAME)
            OR (    ( Recinfo.FK_COLUMN_NAME IS NULL )
                AND (  p_FK_COLUMN_NAME IS NULL )))
       AND (    ( Recinfo.DESC_COLUMN_NAME = p_DESC_COLUMN_NAME)
            OR (    ( Recinfo.DESC_COLUMN_NAME IS NULL )
                AND (  p_DESC_COLUMN_NAME IS NULL )))
       AND (    ( Recinfo.PROCEDURE_TYPE = p_PROCEDURE_TYPE)
            OR (    ( Recinfo.PROCEDURE_TYPE IS NULL )
                AND (  p_PROCEDURE_TYPE IS NULL )))
       AND (    ( Recinfo.PROCEDURE_NAME = p_PROCEDURE_NAME)
            OR (    ( Recinfo.PROCEDURE_NAME IS NULL )
                AND (  p_PROCEDURE_NAME IS NULL )))
       AND (    ( Recinfo.JOIN_CLAUSE = p_JOIN_CLAUSE)
            OR (    ( Recinfo.JOIN_CLAUSE IS NULL )
                AND (  p_JOIN_CLAUSE IS NULL )))
       AND (    ( Recinfo.DICT_APPLICATION_ID = p_DICT_APPLICATION_ID)
            OR (    ( Recinfo.DICT_APPLICATION_ID IS NULL )
                AND (  p_DICT_APPLICATION_ID IS NULL )))
       AND (    ( Recinfo.DESCRIPTION = p_DESCRIPTION)
            OR (    ( Recinfo.DESCRIPTION IS NULL )
                AND (  p_DESCRIPTION IS NULL )))
       AND (    ( Recinfo.SEQUENCE_NO = p_SEQUENCE_NO)
            OR (    ( Recinfo.SEQUENCE_NO IS NULL )
                AND (  p_SEQUENCE_NO IS NULL )))
       AND (    ( Recinfo.BULK_FLAG = p_BULK_FLAG)
            OR (    ( Recinfo.BULK_FLAG IS NULL )
                AND (  p_BULK_FLAG IS NULL )))
       AND (    ( Recinfo.BATCH_MERGE_FLAG = p_BATCH_MERGE_FLAG) --4634891
            OR (    ( Recinfo.BATCH_MERGE_FLAG IS NULL )
                AND (  p_BATCH_MERGE_FLAG IS NULL )))
       AND (    ( Recinfo.VALIDATE_PURGE_FLAG = p_VALIDATE_PURGE_FLAG) --5125968
            OR (    ( Recinfo.VALIDATE_PURGE_FLAG IS NULL )
                AND (  p_VALIDATE_PURGE_FLAG IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End HZ_MERGE_DICTIONARY_PKG;

/

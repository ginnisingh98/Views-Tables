--------------------------------------------------------
--  DDL for Package Body HZ_MERGE_PARTY_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MERGE_PARTY_DETAILS_PKG" as
/* $Header: ARHPDTBB.pls 120.2 2005/10/30 04:22:04 appldev noship $ */
-- Start of Comments
-- Package name     : HZ_MERGE_PARTY_DETAILS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'HZ_MERGE_PARTY_DETAILS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'arhtdtbb.pls';

PROCEDURE Insert_Row(
          p_BATCH_PARTY_ID    NUMBER,
          p_ENTITY_NAME    VARCHAR2,
          p_MERGE_FROM_ENTITY_ID    NUMBER,
          p_MERGE_TO_ENTITY_ID    NUMBER,
          p_MANDATORY_MERGE    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER)

 IS
BEGIN
   INSERT INTO HZ_MERGE_PARTY_DETAILS(
           BATCH_PARTY_ID,
           ENTITY_NAME,
           MERGE_FROM_ENTITY_ID,
           MERGE_TO_ENTITY_ID,
           MANDATORY_MERGE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
          ) VALUES (
           decode( p_BATCH_PARTY_ID, FND_API.G_MISS_NUM, NULL, p_BATCH_PARTY_ID),
           decode( p_ENTITY_NAME, FND_API.G_MISS_CHAR, NULL, p_ENTITY_NAME),
           decode( p_MERGE_FROM_ENTITY_ID, FND_API.G_MISS_NUM, NULL, p_MERGE_FROM_ENTITY_ID),
           decode( p_MERGE_TO_ENTITY_ID, FND_API.G_MISS_NUM, NULL, p_MERGE_TO_ENTITY_ID),
           decode( p_MANDATORY_MERGE, FND_API.G_MISS_CHAR, NULL, p_MANDATORY_MERGE),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY));
End Insert_Row;

PROCEDURE Update_Row(
          p_BATCH_PARTY_ID    NUMBER,
          p_ENTITY_NAME    VARCHAR2,
          p_MERGE_FROM_ENTITY_ID    NUMBER,
          p_MERGE_TO_ENTITY_ID    NUMBER,
          p_MANDATORY_MERGE    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER)

 IS
 BEGIN
    Update HZ_MERGE_PARTY_DETAILS
    SET
              ENTITY_NAME = decode( p_ENTITY_NAME, FND_API.G_MISS_CHAR, ENTITY_NAME, p_ENTITY_NAME),
              MERGE_FROM_ENTITY_ID = decode( p_MERGE_FROM_ENTITY_ID, FND_API.G_MISS_NUM, MERGE_FROM_ENTITY_ID, p_MERGE_FROM_ENTITY_ID),
              MERGE_TO_ENTITY_ID = decode( p_MERGE_TO_ENTITY_ID, FND_API.G_MISS_NUM, MERGE_TO_ENTITY_ID, p_MERGE_TO_ENTITY_ID),
              MANDATORY_MERGE = decode( p_MANDATORY_MERGE, FND_API.G_MISS_CHAR, MANDATORY_MERGE, p_MANDATORY_MERGE),
              -- Bug 3032780
              /*
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              */
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY)
    where  batch_party_id = p_batch_party_id
    and ENTITY_NAME = p_ENTITY_NAME
    and MERGE_FROM_ENTITY_ID = p_MERGE_FROM_ENTITY_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Lock_Row(
          p_BATCH_PARTY_ID    NUMBER,
          p_ENTITY_NAME    VARCHAR2,
          p_MERGE_FROM_ENTITY_ID    NUMBER,
          p_MERGE_TO_ENTITY_ID    NUMBER,
          p_MANDATORY_MERGE    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM HZ_MERGE_PARTY_DETAILS
        WHERE  batch_party_id = p_batch_party_id
        and ENTITY_NAME = p_ENTITY_NAME
        and MERGE_FROM_ENTITY_ID = p_MERGE_FROM_ENTITY_ID
        FOR UPDATE NOWAIT;
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
           (      Recinfo.BATCH_PARTY_ID = p_BATCH_PARTY_ID)
       AND (    ( Recinfo.ENTITY_NAME = p_ENTITY_NAME)
            OR (    ( Recinfo.ENTITY_NAME IS NULL )
                AND (  p_ENTITY_NAME IS NULL )))
       AND (    ( Recinfo.MERGE_FROM_ENTITY_ID = p_MERGE_FROM_ENTITY_ID)
            OR (    ( Recinfo.MERGE_FROM_ENTITY_ID IS NULL )
                AND (  p_MERGE_FROM_ENTITY_ID IS NULL )))
       AND (    ( Recinfo.MERGE_TO_ENTITY_ID = p_MERGE_TO_ENTITY_ID)
            OR (    ( Recinfo.MERGE_TO_ENTITY_ID IS NULL )
                AND (  p_MERGE_TO_ENTITY_ID IS NULL )))
       AND (    ( Recinfo.MANDATORY_MERGE = p_MANDATORY_MERGE)
            OR (    ( Recinfo.MANDATORY_MERGE IS NULL )
                AND (  p_MANDATORY_MERGE IS NULL )))
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

PROCEDURE Delete_Row(
    p_BATCH_PARTY_ID  NUMBER,
    p_ENTITY_NAME    VARCHAR2,
    p_MERGE_FROM_ENTITY_ID    NUMBER)

 IS
 BEGIN
   DELETE FROM HZ_MERGE_PARTY_DETAILS
    WHERE BATCH_PARTY_ID = p_BATCH_PARTY_ID
	and ENTITY_NAME = p_ENTITY_NAME
        and MERGE_FROM_ENTITY_ID = p_MERGE_FROM_ENTITY_ID;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
END Delete_Row;


End HZ_MERGE_PARTY_DETAILS_PKG;

/

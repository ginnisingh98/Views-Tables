--------------------------------------------------------
--  DDL for Package Body HZ_MERGE_PARTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MERGE_PARTIES_PKG" as
/* $Header: ARHMPTBB.pls 120.2 2005/06/16 21:12:45 jhuang noship $ */
-- Start of Comments
-- Package name     : HZ_MERGE_PARTIES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'HZ_MERGE_PARTIES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'arhtptbb.pls';

PROCEDURE Insert_Row(
          px_BATCH_PARTY_ID   IN OUT NOCOPY NUMBER,
          p_BATCH_ID    NUMBER,
          p_MERGE_TYPE    VARCHAR2,
          p_FROM_PARTY_ID    NUMBER,
          p_TO_PARTY_ID    NUMBER,
          p_MERGE_REASON_CODE    VARCHAR2,
          p_MERGE_STATUS    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER)

 IS
   CURSOR C2 IS SELECT HZ_MERGE_PARTIES_S.nextval FROM sys.dual;
BEGIN
   If (px_BATCH_PARTY_ID IS NULL) OR (px_BATCH_PARTY_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_BATCH_PARTY_ID;
       CLOSE C2;
   End If;
   INSERT INTO HZ_MERGE_PARTIES(
           BATCH_PARTY_ID,
           BATCH_ID,
           MERGE_TYPE,
           FROM_PARTY_ID,
           TO_PARTY_ID,
           MERGE_REASON_CODE,
           MERGE_STATUS,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
          ) VALUES (
           px_BATCH_PARTY_ID,
           decode( p_BATCH_ID, FND_API.G_MISS_NUM, NULL, p_BATCH_ID),
           decode( p_MERGE_TYPE, FND_API.G_MISS_CHAR, NULL, p_MERGE_TYPE),
           decode( p_FROM_PARTY_ID, FND_API.G_MISS_NUM, NULL, p_FROM_PARTY_ID),
           decode( p_TO_PARTY_ID, FND_API.G_MISS_NUM, NULL, p_TO_PARTY_ID),
           decode( p_MERGE_REASON_CODE, FND_API.G_MISS_CHAR, NULL, p_MERGE_REASON_CODE),
           decode( p_MERGE_STATUS, FND_API.G_MISS_CHAR, NULL, p_MERGE_STATUS),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY));
End Insert_Row;

PROCEDURE Update_Row(
          p_BATCH_PARTY_ID    NUMBER,
          p_BATCH_ID    NUMBER,
          p_MERGE_TYPE    VARCHAR2,
          p_FROM_PARTY_ID    NUMBER,
          p_TO_PARTY_ID    NUMBER,
          p_MERGE_REASON_CODE    VARCHAR2,
          p_MERGE_STATUS    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER)

 IS
 BEGIN
    Update HZ_MERGE_PARTIES
    SET
              BATCH_ID = decode( p_BATCH_ID, FND_API.G_MISS_NUM, BATCH_ID, p_BATCH_ID),
              MERGE_TYPE = decode( p_MERGE_TYPE, FND_API.G_MISS_CHAR, MERGE_TYPE, p_MERGE_TYPE),
              FROM_PARTY_ID = decode( p_FROM_PARTY_ID, FND_API.G_MISS_NUM, FROM_PARTY_ID, p_FROM_PARTY_ID),
              TO_PARTY_ID = decode( p_TO_PARTY_ID, FND_API.G_MISS_NUM, TO_PARTY_ID, p_TO_PARTY_ID),
              MERGE_REASON_CODE = decode( p_MERGE_REASON_CODE, FND_API.G_MISS_CHAR, MERGE_REASON_CODE, p_MERGE_REASON_CODE),
              MERGE_STATUS = decode( p_MERGE_STATUS, FND_API.G_MISS_CHAR, MERGE_STATUS, p_MERGE_STATUS),
              -- Bug 3032780
              /*
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              */
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY)
    where BATCH_PARTY_ID = p_BATCH_PARTY_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_BATCH_PARTY_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM HZ_MERGE_PARTIES
    WHERE BATCH_PARTY_ID = p_BATCH_PARTY_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_BATCH_PARTY_ID    NUMBER,
          p_BATCH_ID    NUMBER,
          p_MERGE_TYPE    VARCHAR2,
          p_FROM_PARTY_ID    NUMBER,
          p_TO_PARTY_ID    NUMBER,
          p_MERGE_REASON_CODE    VARCHAR2,
          p_MERGE_STATUS    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM HZ_MERGE_PARTIES
        WHERE BATCH_PARTY_ID =  p_BATCH_PARTY_ID
        FOR UPDATE of BATCH_PARTY_ID NOWAIT;
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
       AND (    ( Recinfo.BATCH_ID = p_BATCH_ID)
            OR (    ( Recinfo.BATCH_ID IS NULL )
                AND (  p_BATCH_ID IS NULL )))
       AND (    ( Recinfo.MERGE_TYPE = p_MERGE_TYPE)
            OR (    ( Recinfo.MERGE_TYPE IS NULL )
                AND (  p_MERGE_TYPE IS NULL )))
       AND (    ( Recinfo.FROM_PARTY_ID = p_FROM_PARTY_ID)
            OR (    ( Recinfo.FROM_PARTY_ID IS NULL )
                AND (  p_FROM_PARTY_ID IS NULL )))
       AND (    ( Recinfo.TO_PARTY_ID = p_TO_PARTY_ID)
            OR (    ( Recinfo.TO_PARTY_ID IS NULL )
                AND (  p_TO_PARTY_ID IS NULL )))
       AND (    ( Recinfo.MERGE_REASON_CODE = p_MERGE_REASON_CODE)
            OR (    ( Recinfo.MERGE_REASON_CODE IS NULL )
                AND (  p_MERGE_REASON_CODE IS NULL )))
       AND (    ( Recinfo.MERGE_STATUS = p_MERGE_STATUS)
            OR (    ( Recinfo.MERGE_STATUS IS NULL )
                AND (  p_MERGE_STATUS IS NULL )))
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

End HZ_MERGE_PARTIES_PKG;

/

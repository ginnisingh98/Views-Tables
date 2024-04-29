--------------------------------------------------------
--  DDL for Package Body HZ_MERGE_BATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MERGE_BATCH_PKG" as
/* $Header: ARHMBTBB.pls 120.2 2005/06/16 21:12:21 jhuang noship $ */
-- Start of Comments
-- Package name     : HZ_MERGE_BATCH_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'HZ_MERGE_BATCH_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'arhtbtbb.pls';

PROCEDURE Insert_Row(
          px_BATCH_ID   IN OUT NOCOPY NUMBER,
          p_RULE_SET_NAME    VARCHAR2,
          p_BATCH_NAME    VARCHAR2,
          p_REQUEST_ID    NUMBER,
          p_BATCH_STATUS    VARCHAR2,
          p_BATCH_COMMIT    VARCHAR2,
          p_BATCH_DELETE    VARCHAR2,
          p_MERGE_REASON_CODE    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER)

 IS
   CURSOR C2 IS SELECT HZ_MERGE_BATCH_S.nextval FROM sys.dual;
BEGIN
   If (px_BATCH_ID IS NULL) OR (px_BATCH_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_BATCH_ID;
       CLOSE C2;
   End If;
   INSERT INTO HZ_MERGE_BATCH(
           BATCH_ID,
           RULE_SET_NAME,
           BATCH_NAME,
           REQUEST_ID,
           BATCH_STATUS,
           BATCH_COMMIT,
           BATCH_DELETE,
           MERGE_REASON_CODE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
          ) VALUES (
           px_BATCH_ID,
           decode( p_RULE_SET_NAME, FND_API.G_MISS_CHAR, NULL, p_RULE_SET_NAME),
           decode( p_BATCH_NAME, FND_API.G_MISS_CHAR, NULL, p_BATCH_NAME),
           decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
           decode( p_BATCH_STATUS, FND_API.G_MISS_CHAR, NULL, p_BATCH_STATUS),
           decode( p_BATCH_COMMIT, FND_API.G_MISS_CHAR, NULL, p_BATCH_COMMIT),
           decode( p_BATCH_DELETE, FND_API.G_MISS_CHAR, NULL, p_BATCH_DELETE),
           decode( p_MERGE_REASON_CODE, FND_API.G_MISS_CHAR, NULL, p_MERGE_REASON_CODE),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY));
End Insert_Row;

PROCEDURE Update_Row(
          p_BATCH_ID    NUMBER,
          p_RULE_SET_NAME    VARCHAR2,
          p_BATCH_NAME    VARCHAR2,
          p_REQUEST_ID    NUMBER,
          p_BATCH_STATUS    VARCHAR2,
          p_BATCH_COMMIT    VARCHAR2,
          p_BATCH_DELETE    VARCHAR2,
          p_MERGE_REASON_CODE    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER)

 IS
 BEGIN
    Update HZ_MERGE_BATCH
    SET
              RULE_SET_NAME = decode( p_RULE_SET_NAME, FND_API.G_MISS_CHAR, RULE_SET_NAME, p_RULE_SET_NAME),
              BATCH_NAME = decode( p_BATCH_NAME, FND_API.G_MISS_CHAR, BATCH_NAME, p_BATCH_NAME),
              REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID),
              BATCH_STATUS = decode( p_BATCH_STATUS, FND_API.G_MISS_CHAR, BATCH_STATUS, p_BATCH_STATUS),
              BATCH_COMMIT = decode( p_BATCH_COMMIT, FND_API.G_MISS_CHAR, BATCH_COMMIT, p_BATCH_COMMIT),
              BATCH_DELETE = decode( p_BATCH_DELETE, FND_API.G_MISS_CHAR, BATCH_DELETE, p_BATCH_DELETE),
              MERGE_REASON_CODE = decode( p_MERGE_REASON_CODE, FND_API.G_MISS_CHAR, MERGE_REASON_CODE, p_MERGE_REASON_CODE),
              -- Bug 3032780
              /*
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              */
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY)
    where BATCH_ID = p_BATCH_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_BATCH_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM HZ_MERGE_BATCH
    WHERE BATCH_ID = p_BATCH_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_BATCH_ID    NUMBER,
          p_RULE_SET_NAME    VARCHAR2,
          p_BATCH_NAME    VARCHAR2,
          p_REQUEST_ID    NUMBER,
          p_BATCH_STATUS    VARCHAR2,
          p_BATCH_COMMIT    VARCHAR2,
          p_BATCH_DELETE    VARCHAR2,
          p_MERGE_REASON_CODE    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM HZ_MERGE_BATCH
        WHERE BATCH_ID =  p_BATCH_ID
        FOR UPDATE of BATCH_ID NOWAIT;
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
           (      Recinfo.BATCH_ID = p_BATCH_ID)
       AND (    ( Recinfo.RULE_SET_NAME = p_RULE_SET_NAME)
            OR (    ( Recinfo.RULE_SET_NAME IS NULL )
                AND (  p_RULE_SET_NAME IS NULL )))
       AND (    ( Recinfo.BATCH_NAME = p_BATCH_NAME)
            OR (    ( Recinfo.BATCH_NAME IS NULL )
                AND (  p_BATCH_NAME IS NULL )))
       AND (    ( Recinfo.REQUEST_ID = p_REQUEST_ID)
            OR (    ( Recinfo.REQUEST_ID IS NULL )
                AND (  p_REQUEST_ID IS NULL )))
       AND (    ( Recinfo.BATCH_STATUS = p_BATCH_STATUS)
            OR (    ( Recinfo.BATCH_STATUS IS NULL )
                AND (  p_BATCH_STATUS IS NULL )))
       AND (    ( Recinfo.BATCH_COMMIT = p_BATCH_COMMIT)
            OR (    ( Recinfo.BATCH_COMMIT IS NULL )
                AND (  p_BATCH_COMMIT IS NULL )))
       AND (    ( Recinfo.BATCH_DELETE = p_BATCH_DELETE)
            OR (    ( Recinfo.BATCH_DELETE IS NULL )
                AND (  p_BATCH_DELETE IS NULL )))
       AND (    ( Recinfo.MERGE_REASON_CODE = p_MERGE_REASON_CODE)
            OR (    ( Recinfo.MERGE_REASON_CODE IS NULL )
                AND (  p_MERGE_REASON_CODE IS NULL )))
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

End HZ_MERGE_BATCH_PKG;

/

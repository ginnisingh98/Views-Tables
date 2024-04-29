--------------------------------------------------------
--  DDL for Package Body CSP_PART_PRIORITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PART_PRIORITIES_PKG" as
/* $Header: csptpapb.pls 115.0 2003/06/10 19:49:19 ajosephg noship $ */
-- Start of Comments
-- Package name     : CSP_PART_PRIORITIES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_PART_PRIORITIES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptpapb.pls';

PROCEDURE Insert_Row(
          px_PART_PRIORITY_ID   IN OUT NOCOPY NUMBER,
          p_PRIORITY       VARCHAR2,
          p_LOWER_RANGE    NUMBER,
          p_UPPER_RANGE    NUMBER,
          p_CREATED_BY     NUMBER,
          p_CREATION_DATE  DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE   DATE,
          p_LAST_UPDATE_LOGIN  NUMBER)

 IS
   CURSOR C2 IS SELECT CSP_PART_PRIORITIES_S1.nextval FROM sys.dual;
BEGIN
   If (px_PART_PRIORITY_ID IS NULL) OR (px_PART_PRIORITY_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_PART_PRIORITY_ID;
       CLOSE C2;
   End If;

   INSERT INTO CSP_PART_PRIORITIES(
          PART_PRIORITY_ID,
          PRIORITY,
          LOWER_RANGE,
          UPPER_RANGE,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN)
          VALUES (
          px_PART_PRIORITY_ID,
          decode( p_PRIORITY, FND_API.G_MISS_CHAR, NULL, p_PRIORITY),
          decode( p_LOWER_RANGE, FND_API.G_MISS_NUM, NULL, p_LOWER_RANGE),
          decode( p_UPPER_RANGE, FND_API.G_MISS_NUM, NULL, p_UPPER_RANGE),
          decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
          decode(p_CREATION_DATE,fnd_api.g_miss_date,to_date(null),p_creation_date),
          decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
          decode(p_LAST_UPDATE_DATE,fnd_api.g_miss_date,to_date(null),p_last_update_date),
          decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN));
End Insert_Row;

PROCEDURE Update_Row(
          p_PART_PRIORITY_ID   NUMBER,
          p_PRIORITY       VARCHAR2,
          p_LOWER_RANGE    NUMBER,
          p_UPPER_RANGE    NUMBER,
          p_CREATED_BY     NUMBER,
          p_CREATION_DATE  DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER)

 IS
 BEGIN
    Update CSP_PART_PRIORITIES
    SET  PRIORITY = decode( p_PRIORITY, FND_API.G_MISS_CHAR, PRIORITY, p_PRIORITY),
         LOWER_RANGE = decode( p_LOWER_RANGE, FND_API.G_MISS_NUM, LOWER_RANGE, p_LOWER_RANGE),
         UPPER_RANGE = decode( p_UPPER_RANGE, FND_API.G_MISS_NUM, UPPER_RANGE, p_UPPER_RANGE),
         CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
         CREATION_DATE = decode(p_CREATION_DATE,fnd_api.g_miss_date,creation_date,p_creation_date),
         LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
         LAST_UPDATE_DATE = decode(p_LAST_UPDATE_DATE,fnd_api.g_miss_date,last_update_date,p_last_update_date),
         LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN)
    where PART_PRIORITY_ID = p_PART_PRIORITY_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_PART_PRIORITY_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSP_PART_PRIORITIES
    WHERE PART_PRIORITY_ID = p_PART_PRIORITY_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_PART_PRIORITY_ID   NUMBER,
     	  p_PRIORITY       VARCHAR2,
          p_LOWER_RANGE    NUMBER,
    	  p_UPPER_RANGE    NUMBER,
          p_CREATED_BY     NUMBER,
          p_CREATION_DATE  DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM CSP_PART_PRIORITIES
        WHERE PART_PRIORITY_ID =  p_PART_PRIORITY_ID
        FOR UPDATE of PART_PRIORITY_ID NOWAIT;
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
           (      Recinfo.PART_PRIORITY_ID = p_PART_PRIORITY_ID)
       AND (    ( Recinfo.PRIORITY = p_PRIORITY)
            OR (    ( Recinfo.PRIORITY IS NULL )
                AND (  p_PRIORITY IS NULL )))
       AND (    ( Recinfo.LOWER_RANGE = p_LOWER_RANGE)
            OR (    ( Recinfo.LOWER_RANGE IS NULL )
                AND (  p_LOWER_RANGE IS NULL )))
       AND (    ( Recinfo.UPPER_RANGE = p_UPPER_RANGE)
            OR (    ( Recinfo.UPPER_RANGE IS NULL )
                AND (  p_UPPER_RANGE IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))

       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End CSP_PART_PRIORITIES_PKG;

/

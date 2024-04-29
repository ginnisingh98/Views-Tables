--------------------------------------------------------
--  DDL for Package Body HZ_INDUSTRIAL_CLASS_APP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_INDUSTRIAL_CLASS_APP_PKG" as
/* $Header: ARHOCATB.pls 120.3 2005/10/30 04:20:42 appldev ship $ */


PROCEDURE Insert_Row(
                  x_Rowid       IN OUT NOCOPY            VARCHAR2,
                  x_CODE_APPLIED_ID               NUMBER,
                  x_BEGIN_DATE                    DATE,
                  x_PARTY_ID                      NUMBER,
                  x_END_DATE                      DATE,
                  x_INDUSTRIAL_CLASS_ID           NUMBER,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE,
                  x_CONTENT_SOURCE_TYPE           VARCHAR2,
                  x_IMPORTANCE_RANKING            VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM HZ_INDUSTRIAL_CLASS_APP
            WHERE CODE_APPLIED_ID = x_CODE_APPLIED_ID;
BEGIN
   INSERT INTO HZ_INDUSTRIAL_CLASS_APP(
           CODE_APPLIED_ID,
           BEGIN_DATE,
           PARTY_ID,
           END_DATE,
           INDUSTRIAL_CLASS_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           WH_UPDATE_DATE,
           CONTENT_SOURCE_TYPE
           --IMPORTANCE_RANKING
   ) VALUES (
          x_CODE_APPLIED_ID,
           decode( x_BEGIN_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_BEGIN_DATE),
           decode( x_PARTY_ID, FND_API.G_MISS_NUM, NULL,x_PARTY_ID),
           decode( x_END_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_END_DATE),
           decode( x_INDUSTRIAL_CLASS_ID, FND_API.G_MISS_NUM, NULL,x_INDUSTRIAL_CLASS_ID),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_REQUEST_ID, FND_API.G_MISS_NUM, NULL,x_REQUEST_ID),
           decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL,x_PROGRAM_APPLICATION_ID),
           decode( x_PROGRAM_ID, FND_API.G_MISS_NUM, NULL,x_PROGRAM_ID),
           decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_PROGRAM_UPDATE_DATE),
           decode( x_WH_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_WH_UPDATE_DATE),
           decode( x_CONTENT_SOURCE_TYPE, FND_API.G_MISS_CHAR, NULL,x_CONTENT_SOURCE_TYPE));
           --decode( x_IMPORTANCE_RANKING, FND_API.G_MISS_CHAR, NULL,x_IMPORTANCE_RANKING));
  OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_CODE_APPLIED_ID               NUMBER
 ) IS
 BEGIN
   DELETE FROM HZ_INDUSTRIAL_CLASS_APP
    WHERE CODE_APPLIED_ID = x_CODE_APPLIED_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid          IN OUT NOCOPY         VARCHAR2,
                  x_CODE_APPLIED_ID               NUMBER,
                  x_BEGIN_DATE                    DATE,
                  x_PARTY_ID                      NUMBER,
                  x_END_DATE                      DATE,
                  x_INDUSTRIAL_CLASS_ID           NUMBER,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE,
                  x_CONTENT_SOURCE_TYPE           VARCHAR2,
                  x_IMPORTANCE_RANKING            VARCHAR2
 ) IS
 BEGIN
    Update HZ_INDUSTRIAL_CLASS_APP
    SET
             CODE_APPLIED_ID = decode( x_CODE_APPLIED_ID, FND_API.G_MISS_NUM,CODE_APPLIED_ID,x_CODE_APPLIED_ID),
             BEGIN_DATE = decode( x_BEGIN_DATE, FND_API.G_MISS_DATE,BEGIN_DATE,x_BEGIN_DATE),
             PARTY_ID = decode( x_PARTY_ID, FND_API.G_MISS_NUM,PARTY_ID,x_PARTY_ID),
             END_DATE = decode( x_END_DATE, FND_API.G_MISS_DATE,END_DATE,x_END_DATE),
             INDUSTRIAL_CLASS_ID = decode( x_INDUSTRIAL_CLASS_ID, FND_API.G_MISS_NUM,INDUSTRIAL_CLASS_ID,x_INDUSTRIAL_CLASS_ID),
             -- Bug 3032780
             /*
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             */
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             REQUEST_ID = decode( x_REQUEST_ID, FND_API.G_MISS_NUM,REQUEST_ID,x_REQUEST_ID),
             PROGRAM_APPLICATION_ID = decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM,PROGRAM_APPLICATION_ID,x_PROGRAM_APPLICATION_ID),
             PROGRAM_ID = decode( x_PROGRAM_ID, FND_API.G_MISS_NUM,PROGRAM_ID,x_PROGRAM_ID),
             PROGRAM_UPDATE_DATE = decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE,PROGRAM_UPDATE_DATE,x_PROGRAM_UPDATE_DATE),
             WH_UPDATE_DATE = decode( x_WH_UPDATE_DATE, FND_API.G_MISS_DATE,WH_UPDATE_DATE,x_WH_UPDATE_DATE),
             CONTENT_SOURCE_TYPE = decode( x_CONTENT_SOURCE_TYPE, FND_API.G_MISS_CHAR,CONTENT_SOURCE_TYPE,x_CONTENT_SOURCE_TYPE)
             --IMPORTANCE_RANKING = decode( x_IMPORTANCE_RANKING, FND_API.G_MISS_CHAR,IMPORTANCE_RANKING,x_IMPORTANCE_RANKING)
   where rowid = X_RowId;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_CODE_APPLIED_ID               NUMBER,
                  x_BEGIN_DATE                    DATE,
                  x_PARTY_ID                      NUMBER,
                  x_END_DATE                      DATE,
                  x_INDUSTRIAL_CLASS_ID           NUMBER,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE,
                  x_CONTENT_SOURCE_TYPE           VARCHAR2,
                  x_IMPORTANCE_RANKING            VARCHAR2
 ) IS
   CURSOR C IS
        SELECT *
          FROM HZ_INDUSTRIAL_CLASS_APP
         WHERE rowid = x_Rowid
         FOR UPDATE of CODE_APPLIED_ID NOWAIT;
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
           (    ( Recinfo.CODE_APPLIED_ID = x_CODE_APPLIED_ID)
            OR (    ( Recinfo.CODE_APPLIED_ID = NULL )
                AND (  x_CODE_APPLIED_ID = NULL )))
       AND (    ( Recinfo.BEGIN_DATE = x_BEGIN_DATE)
            OR (    ( Recinfo.BEGIN_DATE = NULL )
                AND (  x_BEGIN_DATE = NULL )))
       AND (    ( Recinfo.PARTY_ID = x_PARTY_ID)
            OR (    ( Recinfo.PARTY_ID = NULL )
                AND (  x_PARTY_ID = NULL )))
       AND (    ( Recinfo.END_DATE = x_END_DATE)
            OR (    ( Recinfo.END_DATE = NULL )
                AND (  x_END_DATE = NULL )))
       AND (    ( Recinfo.INDUSTRIAL_CLASS_ID = x_INDUSTRIAL_CLASS_ID)
            OR (    ( Recinfo.INDUSTRIAL_CLASS_ID = NULL )
                AND (  x_INDUSTRIAL_CLASS_ID = NULL )))
       AND (    ( Recinfo.CREATED_BY = x_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY = NULL )
                AND (  x_CREATED_BY = NULL )))
       AND (    ( Recinfo.CREATION_DATE = x_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE = NULL )
                AND (  x_CREATION_DATE = NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = x_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN = NULL )
                AND (  x_LAST_UPDATE_LOGIN = NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = x_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE = NULL )
                AND (  x_LAST_UPDATE_DATE = NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = x_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY = NULL )
                AND (  x_LAST_UPDATED_BY = NULL )))
       AND (    ( Recinfo.REQUEST_ID = x_REQUEST_ID)
            OR (    ( Recinfo.REQUEST_ID = NULL )
                AND (  x_REQUEST_ID = NULL )))
       AND (    ( Recinfo.PROGRAM_APPLICATION_ID = x_PROGRAM_APPLICATION_ID)
            OR (    ( Recinfo.PROGRAM_APPLICATION_ID = NULL )
                AND (  x_PROGRAM_APPLICATION_ID = NULL )))
       AND (    ( Recinfo.PROGRAM_ID = x_PROGRAM_ID)
            OR (    ( Recinfo.PROGRAM_ID = NULL )
                AND (  x_PROGRAM_ID = NULL )))
       AND (    ( Recinfo.PROGRAM_UPDATE_DATE = x_PROGRAM_UPDATE_DATE)
            OR (    ( Recinfo.PROGRAM_UPDATE_DATE = NULL )
                AND (  x_PROGRAM_UPDATE_DATE = NULL )))
       AND (    ( Recinfo.WH_UPDATE_DATE = x_WH_UPDATE_DATE)
            OR (    ( Recinfo.WH_UPDATE_DATE = NULL )
                AND (  x_WH_UPDATE_DATE = NULL )))
       AND (    ( Recinfo.CONTENT_SOURCE_TYPE = x_CONTENT_SOURCE_TYPE)
            OR (    ( Recinfo.CONTENT_SOURCE_TYPE = NULL )
                AND (  x_CONTENT_SOURCE_TYPE = NULL )))
/*
       AND (    ( Recinfo.IMPORTANCE_RANKING = x_IMPORTANCE_RANKING)
            OR (    ( Recinfo.IMPORTANCE_RANKING = NULL )
                AND (  x_IMPORTANCE_RANKING = NULL )))
*/
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

END HZ_INDUSTRIAL_CLASS_APP_PKG;

/

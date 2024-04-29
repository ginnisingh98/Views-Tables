--------------------------------------------------------
--  DDL for Package Body HZ_INDUSTRIAL_CLASSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_INDUSTRIAL_CLASSES_PKG" as
/* $Header: ARHOICTB.pls 120.3 2005/10/30 04:20:54 appldev ship $ */


PROCEDURE Insert_Row(
                  x_Rowid          IN OUT NOCOPY         VARCHAR2,
                  x_INDUSTRIAL_CLASS_ID           NUMBER,
                  x_INDUSTRIAL_CODE_NAME          VARCHAR2,
                  x_CODE_PRIMARY_SEGMENT          VARCHAR2,
                  x_INDUSTRIAL_CLASS_SOURCE       VARCHAR2,
                  x_CODE_DESCRIPTION              VARCHAR2,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE
 ) IS
   CURSOR C IS SELECT rowid FROM HZ_INDUSTRIAL_CLASSES
            WHERE INDUSTRIAL_CLASS_ID = x_INDUSTRIAL_CLASS_ID;
BEGIN
   INSERT INTO HZ_INDUSTRIAL_CLASSES(
           INDUSTRIAL_CLASS_ID,
           INDUSTRIAL_CODE_NAME,
           CODE_PRIMARY_SEGMENT,
           INDUSTRIAL_CLASS_SOURCE,
           CODE_DESCRIPTION,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           WH_UPDATE_DATE
          ) VALUES (
          x_INDUSTRIAL_CLASS_ID,
           decode( x_INDUSTRIAL_CODE_NAME, FND_API.G_MISS_CHAR, NULL,x_INDUSTRIAL_CODE_NAME),
           decode( x_CODE_PRIMARY_SEGMENT, FND_API.G_MISS_CHAR, NULL,x_CODE_PRIMARY_SEGMENT),
           decode( x_INDUSTRIAL_CLASS_SOURCE, FND_API.G_MISS_CHAR, NULL,x_INDUSTRIAL_CLASS_SOURCE),
           decode( x_CODE_DESCRIPTION, FND_API.G_MISS_CHAR, NULL,x_CODE_DESCRIPTION),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_REQUEST_ID, FND_API.G_MISS_NUM, NULL,x_REQUEST_ID),
           decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL,x_PROGRAM_APPLICATION_ID),
           decode( x_PROGRAM_ID, FND_API.G_MISS_NUM, NULL,x_PROGRAM_ID),
           decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_PROGRAM_UPDATE_DATE),
           decode( x_WH_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_WH_UPDATE_DATE));
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_INDUSTRIAL_CLASS_ID           NUMBER
 ) IS
 BEGIN
   DELETE FROM HZ_INDUSTRIAL_CLASSES
    WHERE INDUSTRIAL_CLASS_ID = x_INDUSTRIAL_CLASS_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid         IN OUT NOCOPY          VARCHAR2,
                  x_INDUSTRIAL_CLASS_ID           NUMBER,
                  x_INDUSTRIAL_CODE_NAME          VARCHAR2,
                  x_CODE_PRIMARY_SEGMENT          VARCHAR2,
                  x_INDUSTRIAL_CLASS_SOURCE       VARCHAR2,
                  x_CODE_DESCRIPTION              VARCHAR2,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE
 ) IS
 BEGIN
    Update HZ_INDUSTRIAL_CLASSES
    SET
             INDUSTRIAL_CLASS_ID = decode( x_INDUSTRIAL_CLASS_ID, FND_API.G_MISS_NUM,INDUSTRIAL_CLASS_ID,x_INDUSTRIAL_CLASS_ID),
             INDUSTRIAL_CODE_NAME = decode( x_INDUSTRIAL_CODE_NAME, FND_API.G_MISS_CHAR,INDUSTRIAL_CODE_NAME,x_INDUSTRIAL_CODE_NAME),
             CODE_PRIMARY_SEGMENT = decode( x_CODE_PRIMARY_SEGMENT, FND_API.G_MISS_CHAR,CODE_PRIMARY_SEGMENT,x_CODE_PRIMARY_SEGMENT),
             INDUSTRIAL_CLASS_SOURCE = decode( x_INDUSTRIAL_CLASS_SOURCE, FND_API.G_MISS_CHAR,INDUSTRIAL_CLASS_SOURCE,x_INDUSTRIAL_CLASS_SOURCE),
             CODE_DESCRIPTION = decode( x_CODE_DESCRIPTION, FND_API.G_MISS_CHAR,CODE_DESCRIPTION,x_CODE_DESCRIPTION),
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
             WH_UPDATE_DATE = decode( x_WH_UPDATE_DATE, FND_API.G_MISS_DATE,WH_UPDATE_DATE,x_WH_UPDATE_DATE)
    where rowid = X_RowId;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_INDUSTRIAL_CLASS_ID           NUMBER,
                  x_INDUSTRIAL_CODE_NAME          VARCHAR2,
                  x_CODE_PRIMARY_SEGMENT          VARCHAR2,
                  x_INDUSTRIAL_CLASS_SOURCE       VARCHAR2,
                  x_CODE_DESCRIPTION              VARCHAR2,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE
 ) IS
   CURSOR C IS
        SELECT *
          FROM HZ_INDUSTRIAL_CLASSES
         WHERE rowid = x_Rowid
         FOR UPDATE of INDUSTRIAL_CLASS_ID NOWAIT;
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
           (    ( Recinfo.INDUSTRIAL_CLASS_ID = x_INDUSTRIAL_CLASS_ID)
            OR (    ( Recinfo.INDUSTRIAL_CLASS_ID = NULL )
                AND (  x_INDUSTRIAL_CLASS_ID = NULL )))
       AND (    ( Recinfo.INDUSTRIAL_CODE_NAME = x_INDUSTRIAL_CODE_NAME)
            OR (    ( Recinfo.INDUSTRIAL_CODE_NAME = NULL )
                AND (  x_INDUSTRIAL_CODE_NAME = NULL )))
       AND (    ( Recinfo.CODE_PRIMARY_SEGMENT = x_CODE_PRIMARY_SEGMENT)
            OR (    ( Recinfo.CODE_PRIMARY_SEGMENT = NULL )
                AND (  x_CODE_PRIMARY_SEGMENT = NULL )))
       AND (    ( Recinfo.INDUSTRIAL_CLASS_SOURCE = x_INDUSTRIAL_CLASS_SOURCE)
            OR (    ( Recinfo.INDUSTRIAL_CLASS_SOURCE = NULL )
                AND (  x_INDUSTRIAL_CLASS_SOURCE = NULL )))
       AND (    ( Recinfo.CODE_DESCRIPTION = x_CODE_DESCRIPTION)
            OR (    ( Recinfo.CODE_DESCRIPTION = NULL )
                AND (  x_CODE_DESCRIPTION = NULL )))
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
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

END HZ_INDUSTRIAL_CLASSES_PKG;

/

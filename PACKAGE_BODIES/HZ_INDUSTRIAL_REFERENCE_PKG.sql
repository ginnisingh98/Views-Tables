--------------------------------------------------------
--  DDL for Package Body HZ_INDUSTRIAL_REFERENCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_INDUSTRIAL_REFERENCE_PKG" as
/* $Header: ARHORITB.pls 120.3 2005/10/30 04:21:08 appldev ship $ */


PROCEDURE Insert_Row(
                  x_Rowid          IN  OUT NOCOPY        VARCHAR2,
                  x_INDUSTRY_REFERENCE_ID         NUMBER,
                  x_INDUSTRY_REFERENCE            VARCHAR2,
                  x_ISSUED_BY_AUTHORITY           VARCHAR2,
                  x_NAME_OF_REFERENCE             VARCHAR2,
                  x_RECOGNIZED_AS_OF_DATE         DATE,
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
                  x_PARTY_ID                      NUMBER,
                  x_STATUS                         VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM HZ_INDUSTRIAL_REFERENCE
            WHERE INDUSTRY_REFERENCE_ID = x_INDUSTRY_REFERENCE_ID;
BEGIN
   INSERT INTO HZ_INDUSTRIAL_REFERENCE(
           INDUSTRY_REFERENCE_ID,
           INDUSTRY_REFERENCE,
           ISSUED_BY_AUTHORITY,
           NAME_OF_REFERENCE,
           RECOGNIZED_AS_OF_DATE,
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
           PARTY_ID,
           STATUS
          ) VALUES (
          x_INDUSTRY_REFERENCE_ID,
           decode( x_INDUSTRY_REFERENCE, FND_API.G_MISS_CHAR, NULL,x_INDUSTRY_REFERENCE),
           decode( x_ISSUED_BY_AUTHORITY, FND_API.G_MISS_CHAR, NULL,x_ISSUED_BY_AUTHORITY),
           decode( x_NAME_OF_REFERENCE, FND_API.G_MISS_CHAR, NULL,x_NAME_OF_REFERENCE),
           decode( x_RECOGNIZED_AS_OF_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_RECOGNIZED_AS_OF_DATE),
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
           decode( x_PARTY_ID, FND_API.G_MISS_NUM, NULL,x_PARTY_ID),
           decode(x_STATUS,FND_API.G_MISS_CHAR,'A',x_STATUS));
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_INDUSTRY_REFERENCE_ID         NUMBER
 ) IS
 BEGIN
   DELETE FROM HZ_INDUSTRIAL_REFERENCE
    WHERE INDUSTRY_REFERENCE_ID = x_INDUSTRY_REFERENCE_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid        IN  OUT NOCOPY          VARCHAR2,
                  x_INDUSTRY_REFERENCE_ID         NUMBER,
                  x_INDUSTRY_REFERENCE            VARCHAR2,
                  x_ISSUED_BY_AUTHORITY           VARCHAR2,
                  x_NAME_OF_REFERENCE             VARCHAR2,
                  x_RECOGNIZED_AS_OF_DATE         DATE,
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
                  x_PARTY_ID                      NUMBER,
                  x_STATUS                        VARCHAR2
 ) IS
 BEGIN
    Update HZ_INDUSTRIAL_REFERENCE
    SET
             INDUSTRY_REFERENCE_ID = decode( x_INDUSTRY_REFERENCE_ID, FND_API.G_MISS_NUM,INDUSTRY_REFERENCE_ID,x_INDUSTRY_REFERENCE_ID),
             INDUSTRY_REFERENCE = decode( x_INDUSTRY_REFERENCE, FND_API.G_MISS_CHAR,INDUSTRY_REFERENCE,x_INDUSTRY_REFERENCE),
             ISSUED_BY_AUTHORITY = decode( x_ISSUED_BY_AUTHORITY, FND_API.G_MISS_CHAR,ISSUED_BY_AUTHORITY,x_ISSUED_BY_AUTHORITY),
             NAME_OF_REFERENCE = decode( x_NAME_OF_REFERENCE, FND_API.G_MISS_CHAR,NAME_OF_REFERENCE,x_NAME_OF_REFERENCE),
             RECOGNIZED_AS_OF_DATE = decode( x_RECOGNIZED_AS_OF_DATE, FND_API.G_MISS_DATE,RECOGNIZED_AS_OF_DATE,x_RECOGNIZED_AS_OF_DATE),
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
             PARTY_ID = decode( x_PARTY_ID, FND_API.G_MISS_NUM,PARTY_ID,x_PARTY_ID),
             STATUS =decode(x_STATUS,FND_API.G_MISS_CHAR,STATUS,x_STATUS)
    where rowid = X_RowId;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_INDUSTRY_REFERENCE_ID         NUMBER,
                  x_INDUSTRY_REFERENCE            VARCHAR2,
                  x_ISSUED_BY_AUTHORITY           VARCHAR2,
                  x_NAME_OF_REFERENCE             VARCHAR2,
                  x_RECOGNIZED_AS_OF_DATE         DATE,
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
                  x_PARTY_ID                      NUMBER,
                  x_STATUS                        VARCHAR2
 ) IS
   CURSOR C IS
        SELECT *
          FROM HZ_INDUSTRIAL_REFERENCE
         WHERE rowid = x_Rowid
         FOR UPDATE of INDUSTRY_REFERENCE_ID NOWAIT;
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
           (    ( Recinfo.INDUSTRY_REFERENCE_ID = x_INDUSTRY_REFERENCE_ID)
            OR (    ( Recinfo.INDUSTRY_REFERENCE_ID = NULL )
                AND (  x_INDUSTRY_REFERENCE_ID = NULL )))
       AND (    ( Recinfo.INDUSTRY_REFERENCE = x_INDUSTRY_REFERENCE)
            OR (    ( Recinfo.INDUSTRY_REFERENCE = NULL )
                AND (  x_INDUSTRY_REFERENCE = NULL )))
       AND (    ( Recinfo.ISSUED_BY_AUTHORITY = x_ISSUED_BY_AUTHORITY)
            OR (    ( Recinfo.ISSUED_BY_AUTHORITY = NULL )
                AND (  x_ISSUED_BY_AUTHORITY = NULL )))
       AND (    ( Recinfo.NAME_OF_REFERENCE = x_NAME_OF_REFERENCE)
            OR (    ( Recinfo.NAME_OF_REFERENCE = NULL )
                AND (  x_NAME_OF_REFERENCE = NULL )))
       AND (    ( Recinfo.RECOGNIZED_AS_OF_DATE = x_RECOGNIZED_AS_OF_DATE)
            OR (    ( Recinfo.RECOGNIZED_AS_OF_DATE = NULL )
                AND (  x_RECOGNIZED_AS_OF_DATE = NULL )))
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
       AND (    ( Recinfo.PARTY_ID = x_PARTY_ID)
            OR (    ( Recinfo.PARTY_ID = NULL )
                AND (  x_PARTY_ID = NULL )))

       AND (    ( Recinfo.STATUS = x_PARTY_ID)
            OR (    ( Recinfo.STATUS = NULL )
                AND (  x_STATUS = NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

END HZ_INDUSTRIAL_REFERENCE_PKG;

/

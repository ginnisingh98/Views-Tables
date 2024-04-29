--------------------------------------------------------
--  DDL for Package Body HZ_CERTIFICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CERTIFICATIONS_PKG" as
/* $Header: ARHOCETB.pls 120.3 2005/10/30 04:20:45 appldev ship $ */


PROCEDURE Insert_Row(
                  x_Rowid        IN OUT NOCOPY           VARCHAR2,
                  x_CERTIFICATION_ID              NUMBER,
                  x_CERTIFICATION_NAME            VARCHAR2,
                  x_CURRENT_STATUS                VARCHAR2,
                  x_PARTY_ID                      NUMBER,
                  x_EXPIRES_ON_DATE               DATE,
                  x_GRADE                         VARCHAR2,
                  x_ISSUED_BY_AUTHORITY           VARCHAR2,
                  x_ISSUED_ON_DATE                DATE,
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
                  x_STATUS                        VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM HZ_CERTIFICATIONS
            WHERE CERTIFICATION_ID = x_CERTIFICATION_ID;
BEGIN
   INSERT INTO HZ_CERTIFICATIONS(
           CERTIFICATION_ID,
           CERTIFICATION_NAME,
           CURRENT_STATUS,
           PARTY_ID,
           EXPIRES_ON_DATE,
           GRADE,
           ISSUED_BY_AUTHORITY,
           ISSUED_ON_DATE,
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
           STATUS
          ) VALUES (
          x_CERTIFICATION_ID,
           decode( x_CERTIFICATION_NAME, FND_API.G_MISS_CHAR, NULL,x_CERTIFICATION_NAME),
           decode( x_CURRENT_STATUS, FND_API.G_MISS_CHAR, NULL,x_CURRENT_STATUS),
           decode( x_PARTY_ID, FND_API.G_MISS_NUM, NULL,x_PARTY_ID),
           decode( x_EXPIRES_ON_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_EXPIRES_ON_DATE),
           decode( x_GRADE, FND_API.G_MISS_CHAR, NULL,x_GRADE),
           decode( x_ISSUED_BY_AUTHORITY, FND_API.G_MISS_CHAR, NULL,x_ISSUED_BY_AUTHORITY),
           decode( x_ISSUED_ON_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_ISSUED_ON_DATE),
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
           decode(x_STATUS,FND_API.G_MISS_CHAR,'A',x_STATUS));
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_CERTIFICATION_ID              NUMBER
 ) IS
 BEGIN
   DELETE FROM HZ_CERTIFICATIONS
    WHERE CERTIFICATION_ID = x_CERTIFICATION_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid         IN OUT NOCOPY          VARCHAR2,
                  x_CERTIFICATION_ID              NUMBER,
                  x_CERTIFICATION_NAME            VARCHAR2,
                  x_CURRENT_STATUS                VARCHAR2,
                  x_PARTY_ID                      NUMBER,
                  x_EXPIRES_ON_DATE               DATE,
                  x_GRADE                         VARCHAR2,
                  x_ISSUED_BY_AUTHORITY           VARCHAR2,
                  x_ISSUED_ON_DATE                DATE,
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
                  x_STATUS                        VARCHAR2
 ) IS
 BEGIN
    Update HZ_CERTIFICATIONS
    SET
             CERTIFICATION_ID = decode( x_CERTIFICATION_ID, FND_API.G_MISS_NUM,CERTIFICATION_ID,x_CERTIFICATION_ID),
             CERTIFICATION_NAME = decode( x_CERTIFICATION_NAME, FND_API.G_MISS_CHAR,CERTIFICATION_NAME,x_CERTIFICATION_NAME),
             CURRENT_STATUS = decode( x_CURRENT_STATUS, FND_API.G_MISS_CHAR,CURRENT_STATUS,x_CURRENT_STATUS),
             PARTY_ID = decode( x_PARTY_ID, FND_API.G_MISS_NUM,PARTY_ID,x_PARTY_ID),
             EXPIRES_ON_DATE = decode( x_EXPIRES_ON_DATE, FND_API.G_MISS_DATE,EXPIRES_ON_DATE,x_EXPIRES_ON_DATE),
             GRADE = decode( x_GRADE, FND_API.G_MISS_CHAR,GRADE,x_GRADE),
             ISSUED_BY_AUTHORITY = decode( x_ISSUED_BY_AUTHORITY, FND_API.G_MISS_CHAR,ISSUED_BY_AUTHORITY,x_ISSUED_BY_AUTHORITY),
             ISSUED_ON_DATE = decode( x_ISSUED_ON_DATE, FND_API.G_MISS_DATE,ISSUED_ON_DATE,x_ISSUED_ON_DATE),
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

             STATUS = decode( x_STATUS,FND_API.G_MISS_char,STATUS,x_STATUS)
    where rowid = X_RowId;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_CERTIFICATION_ID              NUMBER,
                  x_CERTIFICATION_NAME            VARCHAR2,
                  x_CURRENT_STATUS                VARCHAR2,
                  x_PARTY_ID                      NUMBER,
                  x_EXPIRES_ON_DATE               DATE,
                  x_GRADE                         VARCHAR2,
                  x_ISSUED_BY_AUTHORITY           VARCHAR2,
                  x_ISSUED_ON_DATE                DATE,
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
                  x_STATUS                        VARCHAR2
 ) IS
   CURSOR C IS
        SELECT *
          FROM HZ_CERTIFICATIONS
         WHERE rowid = x_Rowid
         FOR UPDATE of CERTIFICATION_ID NOWAIT;
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
           (    ( Recinfo.CERTIFICATION_ID = x_CERTIFICATION_ID)
            OR (    ( Recinfo.CERTIFICATION_ID = NULL )
                AND (  x_CERTIFICATION_ID = NULL )))
       AND (    ( Recinfo.CERTIFICATION_NAME = x_CERTIFICATION_NAME)
            OR (    ( Recinfo.CERTIFICATION_NAME = NULL )
                AND (  x_CERTIFICATION_NAME = NULL )))
       AND (    ( Recinfo.CURRENT_STATUS = x_CURRENT_STATUS)
            OR (    ( Recinfo.CURRENT_STATUS = NULL )
                AND (  x_CURRENT_STATUS = NULL )))
       AND (    ( Recinfo.PARTY_ID = x_PARTY_ID)
            OR (    ( Recinfo.PARTY_ID = NULL )
                AND (  x_PARTY_ID = NULL )))
       AND (    ( Recinfo.EXPIRES_ON_DATE = x_EXPIRES_ON_DATE)
            OR (    ( Recinfo.EXPIRES_ON_DATE = NULL )
                AND (  x_EXPIRES_ON_DATE = NULL )))
       AND (    ( Recinfo.GRADE = x_GRADE)
            OR (    ( Recinfo.GRADE = NULL )
                AND (  x_GRADE = NULL )))
       AND (    ( Recinfo.ISSUED_BY_AUTHORITY = x_ISSUED_BY_AUTHORITY)
            OR (    ( Recinfo.ISSUED_BY_AUTHORITY = NULL )
                AND (  x_ISSUED_BY_AUTHORITY = NULL )))
       AND (    ( Recinfo.ISSUED_ON_DATE = x_ISSUED_ON_DATE)
            OR (    ( Recinfo.ISSUED_ON_DATE = NULL )
                AND (  x_ISSUED_ON_DATE = NULL )))
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


       AND (    ( Recinfo.STATUS = x_STATUS)
            OR (    ( Recinfo.STATUS = NULL )
                AND (  x_STATUS= NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

END HZ_CERTIFICATIONS_PKG;

/

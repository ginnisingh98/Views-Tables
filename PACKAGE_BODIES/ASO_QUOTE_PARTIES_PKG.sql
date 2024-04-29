--------------------------------------------------------
--  DDL for Package Body ASO_QUOTE_PARTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_QUOTE_PARTIES_PKG" as
/* $Header: asotqptb.pls 120.0 2005/05/31 12:03:26 appldev noship $ */
-- Start of Comments
-- Package name     : ASO_QUOTE_PARTIES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_QUOTE_PARTIES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asotqptb.pls';

PROCEDURE Insert_Row(
          px_QUOTE_PARTY_ID   IN OUT NOCOPY  NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_HEADER_ID    NUMBER,
          p_QUOTE_LINE_ID    NUMBER,
          p_QUOTE_SHIPMENT_ID    NUMBER,
          p_PARTY_TYPE    VARCHAR2,
          p_PARTY_ID    NUMBER,
          p_PARTY_OBJECT_TYPE    VARCHAR2,
          p_PARTY_OBJECT_ID    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_OBJECT_VERSION_NUMBER  NUMBER
		)
 --         p_SECURITY_GROUP_ID    NUMBER,

 IS
   CURSOR C2 IS SELECT ASO_QUOTE_PARTIES_S.nextval FROM sys.dual;
BEGIN
   If (px_QUOTE_PARTY_ID IS NULL) OR (px_QUOTE_PARTY_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_QUOTE_PARTY_ID;
       CLOSE C2;
   End If;
   INSERT INTO ASO_QUOTE_PARTIES(
           QUOTE_PARTY_ID,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATED_BY,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           QUOTE_HEADER_ID,
           QUOTE_LINE_ID,
           QUOTE_SHIPMENT_ID,
           PARTY_TYPE,
           PARTY_ID,
           PARTY_OBJECT_TYPE,
           PARTY_OBJECT_ID,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           OBJECT_VERSION_NUMBER
         --  SECURITY_GROUP_ID,
          ) VALUES (
           px_QUOTE_PARTY_ID,
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
           decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_APPLICATION_ID),
           decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID),
           decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_PROGRAM_UPDATE_DATE),
           decode( p_QUOTE_HEADER_ID, FND_API.G_MISS_NUM, NULL, p_QUOTE_HEADER_ID),
           decode( p_QUOTE_LINE_ID, FND_API.G_MISS_NUM, NULL, p_QUOTE_LINE_ID),
           decode( p_QUOTE_SHIPMENT_ID, FND_API.G_MISS_NUM, NULL, p_QUOTE_SHIPMENT_ID),
           decode( p_PARTY_TYPE, FND_API.G_MISS_CHAR, NULL, p_PARTY_TYPE),
           decode( p_PARTY_ID, FND_API.G_MISS_NUM, NULL, p_PARTY_ID),
           decode( p_PARTY_OBJECT_TYPE, FND_API.G_MISS_CHAR, NULL, p_PARTY_OBJECT_TYPE),
           decode( p_PARTY_OBJECT_ID, FND_API.G_MISS_CHAR, NULL, p_PARTY_OBJECT_ID),
           decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY),
           decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1),
           decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2),
           decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3),
           decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4),
           decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5),
           decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6),
           decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7),
           decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8),
           decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9),
           decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10),
           decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11),
           decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12),
           decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13),
           decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14),
           decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15),
		 decode ( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM,1,NULL,1, p_OBJECT_VERSION_NUMBER)
		 );
    --       decode( p_SECURITY_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_SECURITY_GROUP_ID),
End Insert_Row;

PROCEDURE Update_Row(
          p_QUOTE_PARTY_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_HEADER_ID    NUMBER,
          p_QUOTE_LINE_ID    NUMBER,
          p_QUOTE_SHIPMENT_ID    NUMBER,
          p_PARTY_TYPE    VARCHAR2,
          p_PARTY_ID    NUMBER,
          p_PARTY_OBJECT_TYPE    VARCHAR2,
          p_PARTY_OBJECT_ID    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_OBJECT_VERSION_NUMBER  NUMBER
		)
    --      p_SECURITY_GROUP_ID    NUMBER,

 IS
 BEGIN
    Update ASO_QUOTE_PARTIES
    SET
             /* CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),*/
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID),
              PROGRAM_APPLICATION_ID = decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, p_PROGRAM_APPLICATION_ID),
              PROGRAM_ID = decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, p_PROGRAM_ID),
              PROGRAM_UPDATE_DATE = decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, p_PROGRAM_UPDATE_DATE),
              QUOTE_HEADER_ID = decode( p_QUOTE_HEADER_ID, FND_API.G_MISS_NUM, QUOTE_HEADER_ID, p_QUOTE_HEADER_ID),
              QUOTE_LINE_ID = decode( p_QUOTE_LINE_ID, FND_API.G_MISS_NUM, QUOTE_LINE_ID, p_QUOTE_LINE_ID),
              QUOTE_SHIPMENT_ID = decode( p_QUOTE_SHIPMENT_ID, FND_API.G_MISS_NUM, QUOTE_SHIPMENT_ID, p_QUOTE_SHIPMENT_ID),
              PARTY_TYPE = decode( p_PARTY_TYPE, FND_API.G_MISS_CHAR, PARTY_TYPE, p_PARTY_TYPE),
              PARTY_ID = decode( p_PARTY_ID, FND_API.G_MISS_NUM, PARTY_ID, p_PARTY_ID),
              PARTY_OBJECT_TYPE = decode( p_PARTY_OBJECT_TYPE, FND_API.G_MISS_CHAR, PARTY_OBJECT_TYPE, p_PARTY_OBJECT_TYPE),
              PARTY_OBJECT_ID = decode( p_PARTY_OBJECT_ID, FND_API.G_MISS_CHAR, PARTY_OBJECT_ID, p_PARTY_OBJECT_ID),
              ATTRIBUTE_CATEGORY = decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY),
              ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, p_ATTRIBUTE1),
              ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, p_ATTRIBUTE2),
              ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, p_ATTRIBUTE3),
              ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, p_ATTRIBUTE4),
              ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, p_ATTRIBUTE5),
              ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, p_ATTRIBUTE6),
              ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, p_ATTRIBUTE7),
              ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, p_ATTRIBUTE8),
              ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, p_ATTRIBUTE9),
              ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, p_ATTRIBUTE10),
              ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, p_ATTRIBUTE11),
              ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, p_ATTRIBUTE12),
              ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, p_ATTRIBUTE13),
              ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, p_ATTRIBUTE14),
              ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, p_ATTRIBUTE15),
		    OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, nvl(OBJECT_VERSION_NUMBER,0)+1, nvl(p_OBJECT_VERSION_NUMBER, nvl(OBJECT_VERSION_NUMBER,0))+1)
        --      SECURITY_GROUP_ID = decode( p_SECURITY_GROUP_ID, FND_API.G_MISS_NUM, SECURITY_GROUP_ID, p_SECURITY_GROUP_ID),
    where QUOTE_PARTY_ID = p_QUOTE_PARTY_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_QUOTE_PARTY_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM ASO_QUOTE_PARTIES
    WHERE QUOTE_PARTY_ID = p_QUOTE_PARTY_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          --p_OBJECT_VERSION_NUMBER  NUMBER,
          p_QUOTE_PARTY_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_HEADER_ID    NUMBER,
          p_QUOTE_LINE_ID    NUMBER,
          p_QUOTE_SHIPMENT_ID    NUMBER,
          p_PARTY_TYPE    VARCHAR2,
          p_PARTY_ID    NUMBER,
          p_PARTY_OBJECT_TYPE    VARCHAR2,
          p_PARTY_OBJECT_ID    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2)
      --    p_SECURITY_GROUP_ID    NUMBER,

 IS
   CURSOR C IS
        SELECT
         --OBJECT_VERSION_NUMBER,
           QUOTE_PARTY_ID,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATED_BY,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           QUOTE_HEADER_ID,
           QUOTE_LINE_ID,
           QUOTE_SHIPMENT_ID,
           PARTY_TYPE,
           PARTY_ID,
           PARTY_OBJECT_TYPE,
           PARTY_OBJECT_ID,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15
         --  SECURITY_GROUP_ID,
         FROM ASO_QUOTE_PARTIES
        WHERE QUOTE_PARTY_ID =  p_QUOTE_PARTY_ID
        FOR UPDATE of QUOTE_PARTY_ID NOWAIT;
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
/*
           (      Recinfo.QUOTE_PARTY_ID = p_QUOTE_PARTY_ID)
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND
*/
	  (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
/*
       AND
	   (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
	      OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
		         AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.REQUEST_ID = p_REQUEST_ID)
            OR (    ( Recinfo.REQUEST_ID IS NULL )
                AND (  p_REQUEST_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID)
            OR (    ( Recinfo.PROGRAM_APPLICATION_ID IS NULL )
                AND (  p_PROGRAM_APPLICATION_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_ID = p_PROGRAM_ID)
            OR (    ( Recinfo.PROGRAM_ID IS NULL )
                AND (  p_PROGRAM_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE)
            OR (    ( Recinfo.PROGRAM_UPDATE_DATE IS NULL )
                AND (  p_PROGRAM_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.QUOTE_HEADER_ID = p_QUOTE_HEADER_ID)
            OR (    ( Recinfo.QUOTE_HEADER_ID IS NULL )
                AND (  p_QUOTE_HEADER_ID IS NULL )))
       AND (    ( Recinfo.QUOTE_LINE_ID = p_QUOTE_LINE_ID)
            OR (    ( Recinfo.QUOTE_LINE_ID IS NULL )
                AND (  p_QUOTE_LINE_ID IS NULL )))
       AND (    ( Recinfo.QUOTE_SHIPMENT_ID = p_QUOTE_SHIPMENT_ID)
            OR (    ( Recinfo.QUOTE_SHIPMENT_ID IS NULL )
                AND (  p_QUOTE_SHIPMENT_ID IS NULL )))
       AND (    ( Recinfo.PARTY_TYPE = p_PARTY_TYPE)
            OR (    ( Recinfo.PARTY_TYPE IS NULL )
                AND (  p_PARTY_TYPE IS NULL )))
       AND (    ( Recinfo.PARTY_ID = p_PARTY_ID)
            OR (    ( Recinfo.PARTY_ID IS NULL )
                AND (  p_PARTY_ID IS NULL )))
       AND (    ( Recinfo.PARTY_OBJECT_TYPE = p_PARTY_OBJECT_TYPE)
            OR (    ( Recinfo.PARTY_OBJECT_TYPE IS NULL )
                AND (  p_PARTY_OBJECT_TYPE IS NULL )))
       AND (    ( Recinfo.PARTY_OBJECT_ID = p_PARTY_OBJECT_ID)
            OR (    ( Recinfo.PARTY_OBJECT_ID IS NULL )
                AND (  p_PARTY_OBJECT_ID IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE_CATEGORY = p_ATTRIBUTE_CATEGORY)
            OR (    ( Recinfo.ATTRIBUTE_CATEGORY IS NULL )
                AND (  p_ATTRIBUTE_CATEGORY IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE1 = p_ATTRIBUTE1)
            OR (    ( Recinfo.ATTRIBUTE1 IS NULL )
                AND (  p_ATTRIBUTE1 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE2 = p_ATTRIBUTE2)
            OR (    ( Recinfo.ATTRIBUTE2 IS NULL )
                AND (  p_ATTRIBUTE2 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE3 = p_ATTRIBUTE3)
            OR (    ( Recinfo.ATTRIBUTE3 IS NULL )
                AND (  p_ATTRIBUTE3 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE4 = p_ATTRIBUTE4)
            OR (    ( Recinfo.ATTRIBUTE4 IS NULL )
                AND (  p_ATTRIBUTE4 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE5 = p_ATTRIBUTE5)
            OR (    ( Recinfo.ATTRIBUTE5 IS NULL )
                AND (  p_ATTRIBUTE5 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE6 = p_ATTRIBUTE6)
            OR (    ( Recinfo.ATTRIBUTE6 IS NULL )
                AND (  p_ATTRIBUTE6 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE7 = p_ATTRIBUTE7)
            OR (    ( Recinfo.ATTRIBUTE7 IS NULL )
                AND (  p_ATTRIBUTE7 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE8 = p_ATTRIBUTE8)
            OR (    ( Recinfo.ATTRIBUTE8 IS NULL )
                AND (  p_ATTRIBUTE8 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE9 = p_ATTRIBUTE9)
            OR (    ( Recinfo.ATTRIBUTE9 IS NULL )
                AND (  p_ATTRIBUTE9 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE10 = p_ATTRIBUTE10)
            OR (    ( Recinfo.ATTRIBUTE10 IS NULL )
                AND (  p_ATTRIBUTE10 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE11 = p_ATTRIBUTE11)
            OR (    ( Recinfo.ATTRIBUTE11 IS NULL )
                AND (  p_ATTRIBUTE11 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE12 = p_ATTRIBUTE12)
            OR (    ( Recinfo.ATTRIBUTE12 IS NULL )
                AND (  p_ATTRIBUTE12 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE13 = p_ATTRIBUTE13)
            OR (    ( Recinfo.ATTRIBUTE13 IS NULL )
                AND (  p_ATTRIBUTE13 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE14 = p_ATTRIBUTE14)
            OR (    ( Recinfo.ATTRIBUTE14 IS NULL )
                AND (  p_ATTRIBUTE14 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE15 = p_ATTRIBUTE15)
            OR (    ( Recinfo.ATTRIBUTE15 IS NULL )
                AND (  p_ATTRIBUTE15 IS NULL )))
*/
/*       AND (    ( Recinfo.SECURITY_GROUP_ID = p_SECURITY_GROUP_ID)
            OR (    ( Recinfo.SECURITY_GROUP_ID IS NULL )
                AND (  p_SECURITY_GROUP_ID IS NULL )))
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))*/
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

PROCEDURE Delete_Row(
    p_QUOTE_LINE_ID  NUMBER)
IS
BEGIN
  DELETE FROM ASO_QUOTE_PARTIES
    WHERE QUOTE_LINE_ID = p_QUOTE_LINE_ID;
   If (SQL%NOTFOUND) then
       null;
   End If;
END;

PROCEDURE Delete_Row(
    p_QUOTE_HEADER_ID  NUMBER)
IS
BEGIN
  DELETE FROM ASO_QUOTE_PARTIES
    WHERE QUOTE_HEADER_ID = p_QUOTE_HEADER_ID;
   If (SQL%NOTFOUND) then
       null;
   End If;
END;

PROCEDURE Delete_Row(
    p_QUOTE_SHIPMENT_ID  NUMBER)
IS
BEGIN
  DELETE FROM ASO_QUOTE_PARTIES
    WHERE QUOTE_SHIPMENT_ID = p_QUOTE_SHIPMENT_ID;
   If (SQL%NOTFOUND) then
       null;
   End If;
END;



End ASO_QUOTE_PARTIES_PKG;

/

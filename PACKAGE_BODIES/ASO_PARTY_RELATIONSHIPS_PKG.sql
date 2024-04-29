--------------------------------------------------------
--  DDL for Package Body ASO_PARTY_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_PARTY_RELATIONSHIPS_PKG" as
/* $Header: asotparb.pls 120.1 2005/06/29 12:39:44 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_PARTY_RELATIONSHIPS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_PARTY_RELATIONSHIPS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asotparb.pls';

PROCEDURE Insert_Row(
          px_PARTY_RELATIONSHIP_ID   IN OUT NOCOPY /* file.sql.39 change */  NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_HEADER_ID    NUMBER,
          p_QUOTE_LINE_ID    NUMBER,
          p_OBJECT_TYPE_CODE    VARCHAR2,
          p_OBJECT_ID    NUMBER,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR,
          p_OBJECT_VERSION_NUMBER  NUMBER
		)

 IS
   CURSOR C2 IS SELECT ASO_PARTY_RELATIONSHIPS_S.nextval FROM sys.dual;
BEGIN
   If (px_PARTY_RELATIONSHIP_ID IS NULL) OR (px_PARTY_RELATIONSHIP_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_PARTY_RELATIONSHIP_ID;
       CLOSE C2;
   End If;
   INSERT INTO ASO_PARTY_RELATIONSHIPS(
  PARTY_RELATIONSHIP_ID
, CREATION_DATE
, CREATED_BY
, LAST_UPDATE_DATE
, LAST_UPDATED_BY
, LAST_UPDATE_LOGIN
, REQUEST_ID
, PROGRAM_APPLICATION_ID
, PROGRAM_ID
, PROGRAM_UPDATE_DATE
, QUOTE_HEADER_ID
, QUOTE_LINE_ID
, OBJECT_TYPE_CODE
, OBJECT_ID
, RELATIONSHIP_TYPE_CODE
,OBJECT_VERSION_NUMBER
          ) VALUES (
           px_PARTY_RELATIONSHIP_ID,
           ASO_UTILITY_PVT.decode( p_CREATION_DATE, FND_API.G_MISS_DATE, NULL, p_CREATION_DATE),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           ASO_UTILITY_PVT.decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
           decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_APPLICATION_ID),
           decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID),
           ASO_UTILITY_PVT.decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_PROGRAM_UPDATE_DATE),
           decode( p_QUOTE_HEADER_ID, FND_API.G_MISS_NUM, NULL, p_QUOTE_HEADER_ID),
           decode( p_QUOTE_LINE_ID, FND_API.G_MISS_NUM, NULL, p_QUOTE_LINE_ID),
           decode( p_OBJECT_TYPE_CODE, FND_API.G_MISS_CHAR, NULL, p_OBJECT_TYPE_CODE),
           decode( p_OBJECT_ID, FND_API.G_MISS_NUM, NULL, p_OBJECT_ID),
           decode( p_RELATIONSHIP_TYPE_CODE, FND_API.G_MISS_CHAR, NULL, p_RELATIONSHIP_TYPE_CODE),
		 decode ( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM,1,NULL,1, p_OBJECT_VERSION_NUMBER)
		 );
End Insert_Row;

PROCEDURE Update_Row(
          p_PARTY_RELATIONSHIP_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_HEADER_ID    NUMBER,
          p_QUOTE_LINE_ID    NUMBER,
          p_OBJECT_TYPE_CODE    VARCHAR2,
          p_OBJECT_ID    NUMBER,
	  p_RELATIONSHIP_TYPE_CODE    VARCHAR,
          p_OBJECT_VERSION_NUMBER  NUMBER
	  )

 IS
 BEGIN
    Update ASO_PARTY_RELATIONSHIPS
    SET
              CREATION_DATE = ASO_UTILITY_PVT.decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              LAST_UPDATE_DATE = ASO_UTILITY_PVT.decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID),
              PROGRAM_APPLICATION_ID = decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, p_PROGRAM_APPLICATION_ID),
              PROGRAM_ID = decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, p_PROGRAM_ID),
              PROGRAM_UPDATE_DATE = ASO_UTILITY_PVT.decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, p_PROGRAM_UPDATE_DATE),
               QUOTE_HEADER_ID = decode( p_QUOTE_HEADER_ID, FND_API.G_MISS_NUM, QUOTE_HEADER_ID, p_QUOTE_HEADER_ID),
              QUOTE_LINE_ID = decode( p_QUOTE_LINE_ID, FND_API.G_MISS_NUM, QUOTE_LINE_ID, p_QUOTE_LINE_ID),
              OBJECT_TYPE_CODE = decode( p_OBJECT_TYPE_CODE, FND_API.G_MISS_CHAR, OBJECT_TYPE_CODE, p_OBJECT_TYPE_CODE),
              OBJECT_ID = decode( p_OBJECT_ID, FND_API.G_MISS_NUM, OBJECT_ID, p_OBJECT_ID),
 RELATIONSHIP_TYPE_CODE = decode( p_RELATIONSHIP_TYPE_CODE, FND_API.G_MISS_CHAR, RELATIONSHIP_TYPE_CODE, p_RELATIONSHIP_TYPE_CODE),
 OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, nvl(OBJECT_VERSION_NUMBER,0)+1, nvl(p_OBJECT_VERSION_NUMBER, nvl(OBJECT_VERSION_NUMBER,0))+1)
    where PARTY_RELATIONSHIP_ID = p_PARTY_RELATIONSHIP_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_PARTY_RELATIONSHIP_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM ASO_PARTY_RELATIONSHIPS
    WHERE PARTY_RELATIONSHIP_ID = p_PARTY_RELATIONSHIP_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          --p_OBJECT_VERSION_NUMBER  NUMBER,
          p_PARTY_RELATIONSHIP_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_HEADER_ID    NUMBER,
          p_QUOTE_LINE_ID    NUMBER,
          p_OBJECT_TYPE_CODE    VARCHAR2,
          p_OBJECT_ID    NUMBER,
	  p_RELATIONSHIP_TYPE_CODE    VARCHAR)

 IS
   CURSOR C IS
        SELECT PARTY_RELATIONSHIP_ID,
--OBJECT_VERSION_NUMBER,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN,
REQUEST_ID,
PROGRAM_APPLICATION_ID,
PROGRAM_ID,
PROGRAM_UPDATE_DATE,
QUOTE_HEADER_ID,
QUOTE_LINE_ID,
OBJECT_TYPE_CODE,
OBJECT_ID,
RELATIONSHIP_TYPE_CODE
         FROM ASO_PARTY_RELATIONSHIPS
        WHERE PARTY_RELATIONSHIP_ID =  p_PARTY_RELATIONSHIP_ID
        FOR UPDATE of PARTY_RELATIONSHIP_ID NOWAIT;
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
           (      Recinfo.PARTY_RELATIONSHIP_ID = p_PARTY_RELATIONSHIP_ID)
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

       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
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
*/
   /*    AND (    ( Recinfo.QUOTE_OBJECT_TYPE = p_QUOTE_OBJECT_TYPE)
            OR (    ( Recinfo.QUOTE_OBJECT_TYPE IS NULL )
                AND (  p_QUOTE_OBJECT_TYPE IS NULL )))
       AND (    ( Recinfo.QUOTE_OBJECT_ID = p_QUOTE_OBJECT_ID)
            OR (    ( Recinfo.QUOTE_OBJECT_ID IS NULL )
                AND (  p_QUOTE_OBJECT_ID IS NULL ))) */
/*
       AND (    ( Recinfo.RELATIONSHIP_TYPE_CODE = p_RELATIONSHIP_TYPE_CODE)
            OR (    ( Recinfo.RELATIONSHIP_TYPE_CODE IS NULL )
                AND (  p_RELATIONSHIP_TYPE_CODE IS NULL )))
*/
   /*    AND (    ( Recinfo.RELATED_OBJECT_TYPE_CODE = p_RELATED_OBJECT_TYPE_CODE)
            OR (    ( Recinfo.RELATED_OBJECT_TYPE_CODE IS NULL )
                AND (  p_RELATED_OBJECT_TYPE_CODE IS NULL )))
       AND (    ( Recinfo.RELATED_OBJECT_ID = p_RELATED_OBJECT_ID)
            OR (    ( Recinfo.RELATED_OBJECT_ID IS NULL )
                AND (  p_RELATED_OBJECT_ID IS NULL )))  */
/*
       AND (    ( Recinfo.QUOTE_HEADER_ID = p_QUOTE_HEADER_ID)
            OR (    ( Recinfo.QUOTE_HEADER_ID IS NULL )
                AND (  p_QUOTE_HEADER_ID IS NULL )))
       AND (    ( Recinfo.QUOTE_LINE_ID = p_QUOTE_LINE_ID)
            OR (    ( Recinfo.QUOTE_LINE_ID IS NULL )
                AND (  p_QUOTE_LINE_ID IS NULL )))
       AND (    ( Recinfo.OBJECT_TYPE_CODE = p_OBJECT_TYPE_CODE)
            OR (    ( Recinfo.OBJECT_TYPE_CODE IS NULL )
                AND (  p_OBJECT_TYPE_CODE IS NULL )))
       AND (    ( Recinfo.OBJECT_ID = p_OBJECT_ID)
            OR (    ( Recinfo.OBJECT_ID IS NULL )
                AND (  p_OBJECT_ID IS NULL )))
*/
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End ASO_PARTY_RELATIONSHIPS_PKG;

/
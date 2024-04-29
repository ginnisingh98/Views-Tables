--------------------------------------------------------
--  DDL for Package Body CSC_COLOR_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_COLOR_CODES_PKG" as
/* $Header: csctpccb.pls 120.2 2005/08/24 04:07:05 vshastry ship $ */
-- Start of Comments
-- Package name     : CSC_COLOR_CODES_PKG
-- Purpose          :
-- History          :
--	03 Nov 00	axsubram	Added Load_row for NLS (#1487340)
-- 27 Nov 02   jamose For Fnd_Api_G_Miss* and NOCOPY changes
--
-- 19 july 2005 tpalaniv Modified the logic in load_row API to fetch l_user_id from fnd API
--                       as part of R12 ATG Project
--
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_COLOR_CODES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csctpccb.pls';

PROCEDURE Insert_Row(
          px_COLOR_CODE   IN OUT NOCOPY VARCHAR2,
          p_RATING_CODE     VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER)

 IS
BEGIN
   INSERT INTO CSC_COLOR_CODES(
           COLOR_CODE,
           RATING_CODE,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN
          ) VALUES (
           px_COLOR_CODE,
		 p_rating_code,
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, NULL, p_CREATION_DATE),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN));
End Insert_Row;

PROCEDURE Update_Row(
          p_COLOR_CODE    VARCHAR2,
          p_RATING_CODE    VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER)

 IS
 BEGIN
    Update CSC_COLOR_CODES
    SET
              COLOR_CODE = p_COLOR_CODE,
              LAST_UPDATE_DATE =p_LAST_UPDATE_DATE,
              LAST_UPDATED_BY = p_LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN
    where RATING_CODE = p_RATING_CODE;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_COLOR_CODE  VARCHAR2)
 IS
 BEGIN
   DELETE FROM CSC_COLOR_CODES
    WHERE COLOR_CODE = p_COLOR_CODE;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_COLOR_CODE    VARCHAR2,
          p_RATING_CODE    VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM CSC_COLOR_CODES
        WHERE RATING_CODE =  p_RATING_CODE
        FOR UPDATE of RATING_CODE NOWAIT;
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
           (      Recinfo.RATING_CODE = p_RATING_CODE)
       AND (    ( Recinfo.COLOR_CODE = p_COLOR_CODE)
            OR (    ( Recinfo.COLOR_CODE IS NULL )
                AND (  p_COLOR_CODE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
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

PROCEDURE Load_Row(
          p_COLOR_CODE         VARCHAR2,
          p_RATING_CODE        VARCHAR2,
          p_LAST_UPDATE_DATE   DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN  NUMBER,
		p_owner			 VARCHAR2)
IS
	l_user_id	number := 0;
	l_color_code	varchar2(30);
   Begin

	l_color_code := p_color_code ;

 	Csc_Color_Codes_Pkg.Update_Row(
           	p_COLOR_CODE          => p_color_code,
           	p_RATING_CODE         => p_rating_code,
           	p_LAST_UPDATE_DATE    => p_last_update_date,
           	p_LAST_UPDATED_BY     => p_last_updated_by,
           	p_LAST_UPDATE_LOGIN   => 0);

   EXCEPTION
      WHEN NO_DATA_FOUND THEN

         Csc_Color_Codes_Pkg.Insert_Row(
           	px_COLOR_CODE         => l_color_code,
            	p_RATING_CODE         => p_rating_code,
           	p_LAST_UPDATE_DATE    => p_last_update_date,
           	p_LAST_UPDATED_BY     => p_last_updated_by,
          	p_CREATION_DATE       => p_last_update_date,
           	p_CREATED_BY          => p_last_updated_by,
           	p_LAST_UPDATE_LOGIN   => 0);


   End Load_Row;

End CSC_COLOR_CODES_PKG;

/

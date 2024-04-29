--------------------------------------------------------
--  DDL for Package Body CSC_PROF_GROUP_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROF_GROUP_CATEGORIES_PKG" as
/* $Header: csctpcab.pls 120.3 2005/09/18 23:44:08 vshastry ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_GROUP_CATEGORIES_PKG
-- Purpose          :
-- History          :
-- 26 Nov 2002 JAmose For Fnd_Api.G_Miss* changes
-- 19 july 2005 tpalaniv Modified the load_row API to fetch last_updated_by using FND API
-- 19-09-2005 vshastry Bug 4596220. Added condition in insert row
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PROF_GROUP_CATEGORIES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csctpgcb.pls';

PROCEDURE Insert_Row(
          px_GROUP_CATEGORY_ID   IN OUT NOCOPY NUMBER,
          p_GROUP_ID    NUMBER,
          p_CATEGORY_CODE    VARCHAR2,
          p_CATEGORY_SEQUENCE    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SEEDED_FLAG     VARCHAR2)

 IS
   CURSOR C2 IS SELECT CSC_PROF_GROUP_CATEGORIES_S.nextval FROM sys.dual;
   ps_SEEDED_FLAG    Varchar2(3);
BEGIN

   /* added the below 2 lines for bug 4596220 */
   ps_seeded_flag := p_seeded_flag;
   IF NVL(p_seeded_flag, 'N') <> 'Y' THEN

   /* Added This If Condition for Bug 1944040*/
      If p_Created_by=1 then
           ps_seeded_flag:='Y';
      Else
           ps_seeded_flag:='N';
      End If;
   END IF;

   If (px_GROUP_CATEGORY_ID IS NULL) OR (px_GROUP_CATEGORY_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_GROUP_CATEGORY_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSC_PROF_GROUP_CATEGORIES(
           GROUP_CATEGORY_ID,
           GROUP_ID,
           CATEGORY_CODE,
           CATEGORY_SEQUENCE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           SEEDED_FLAG
          ) VALUES (
           px_GROUP_CATEGORY_ID,
           decode( p_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_GROUP_ID),
           decode( p_CATEGORY_CODE, FND_API.G_MISS_CHAR, NULL, p_CATEGORY_CODE),
           decode( p_CATEGORY_SEQUENCE, FND_API.G_MISS_NUM, NULL, p_CATEGORY_SEQUENCE),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, NULL, p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_SEEDED_FLAG,CSC_CORE_UTILS_PVT.G_MISS_CHAR, NULL, ps_SEEDED_FLAG));
End Insert_Row;

PROCEDURE Update_Row(
          p_GROUP_CATEGORY_ID    NUMBER,
          p_GROUP_ID    NUMBER,
          p_CATEGORY_CODE    VARCHAR2,
          p_CATEGORY_SEQUENCE    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SEEDED_FLAG       VARCHAR2)

 IS
 BEGIN
    Update CSC_PROF_GROUP_CATEGORIES
    SET
              GROUP_ID = p_GROUP_ID,
              CATEGORY_CODE = p_CATEGORY_CODE,
              CATEGORY_SEQUENCE =p_CATEGORY_SEQUENCE,
              LAST_UPDATED_BY = p_LAST_UPDATED_BY,
              LAST_UPDATE_DATE = p_LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN =p_LAST_UPDATE_LOGIN,
              SEEDED_FLAG= p_SEEDED_FLAG
    where GROUP_CATEGORY_ID = p_GROUP_CATEGORY_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_GROUP_CATEGORY_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSC_PROF_GROUP_CATEGORIES
    WHERE GROUP_CATEGORY_ID = p_GROUP_CATEGORY_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_GROUP_CATEGORY_ID    NUMBER,
          p_GROUP_ID    NUMBER,
          p_CATEGORY_CODE    VARCHAR2,
          p_CATEGORY_SEQUENCE    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SEEDED_FLAG    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM CSC_PROF_GROUP_CATEGORIES
        WHERE GROUP_CATEGORY_ID =  p_GROUP_CATEGORY_ID
        FOR UPDATE of GROUP_CATEGORY_ID NOWAIT;
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
           (      Recinfo.GROUP_CATEGORY_ID = p_GROUP_CATEGORY_ID)
       AND (    ( Recinfo.GROUP_ID = p_GROUP_ID)
            OR (    ( Recinfo.GROUP_ID IS NULL )
                AND (  p_GROUP_ID IS NULL )))
       AND (    ( Recinfo.CATEGORY_CODE = p_CATEGORY_CODE)
            OR (    ( Recinfo.CATEGORY_CODE IS NULL )
                AND (  p_CATEGORY_CODE IS NULL )))
       AND (    ( Recinfo.CATEGORY_SEQUENCE = p_CATEGORY_SEQUENCE)
            OR (    ( Recinfo.CATEGORY_SEQUENCE IS NULL )
                AND (  p_CATEGORY_SEQUENCE IS NULL )))
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
        AND (    ( Recinfo.SEEDED_FLAG = p_SEEDED_FLAG)
            OR (    ( Recinfo.SEEDED_FLAG IS NULL )
                AND (  p_SEEDED_FLAG IS NULL )))

       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

Procedure LOAD_ROW (
 p_GROUP_CATEGORY_ID    in number,
 p_GROUP_ID             in number,
 p_CATEGORY_CODE        in varchar2,
 p_CATEGORY_SEQUENCE    in number ,
 p_SEEDED_FLAG          in varchar2,
 p_last_updated_by      IN NUMBER,
 p_last_update_date     IN DATE
 ) is

 l_user_id               number := 0;
 l_group_category_id     number := p_GROUP_CATEGORY_ID;

Begin

 Csc_Prof_Group_Categories_Pkg.Update_Row(
    p_GROUP_CATEGORY_ID     => p_GROUP_CATEGORY_ID,
    p_GROUP_ID              => p_GROUP_ID,
    p_CATEGORY_CODE         => p_CATEGORY_CODE,
    p_CATEGORY_SEQUENCE     => p_CATEGORY_SEQUENCE,
    p_LAST_UPDATED_BY       => p_last_updated_by,
    p_LAST_UPDATE_DATE      => p_last_update_date,
    p_LAST_UPDATE_LOGIN     => 0,
    p_SEEDED_FLAG           => p_SEEDED_FLAG);

 Exception
   When no_data_found then
    Csc_Prof_Group_Categories_Pkg.Insert_Row(
      px_GROUP_CATEGORY_ID    => l_group_category_id,
      p_GROUP_ID              => p_GROUP_ID,
      p_CATEGORY_CODE         => p_CATEGORY_CODE,
      p_CATEGORY_SEQUENCE     => p_CATEGORY_SEQUENCE,
      p_CREATED_BY            => p_last_updated_by,
      p_CREATION_DATE         => p_last_update_date,
      p_LAST_UPDATED_BY       => p_last_updated_by,
      p_LAST_UPDATE_DATE      => p_last_update_date,
      p_LAST_UPDATE_LOGIN     => 0,
      p_SEEDED_FLAG           => p_SEEDED_FLAG );

End Load_Row;


End CSC_PROF_GROUP_CATEGORIES_PKG;

/

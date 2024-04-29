--------------------------------------------------------
--  DDL for Package Body CSP_BUSINESS_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_BUSINESS_RULES_PKG" as
/* $Header: csptbrub.pls 120.2 2007/12/09 20:26:47 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_BUSINESS_RULES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_BUSINESS_RULES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptbrub.pls';


PROCEDURE Insert_Row(
          px_BUSINESS_RULE_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY            NUMBER,
          p_CREATION_DATE         DATE,
          p_LAST_UPDATED_BY       NUMBER,
          p_LAST_UPDATE_DATE      DATE,
          p_LAST_UPDATE_LOGIN     NUMBER,
          p_BUSINESS_RULE_NAME    VARCHAR2,
          p_DESCRIPTION    	  VARCHAR2,
          p_BUSINESS_RULE_TYPE    VARCHAR2,
	  p_BUSINESS_RULE_VALUE1  NUMBER,
	  p_BUSINESS_RULE_VALUE2  NUMBER,
	  p_BUSINESS_RULE_VALUE3  NUMBER,
	  p_BUSINESS_RULE_VALUE4  NUMBER,
	  p_BUSINESS_RULE_VALUE5  NUMBER,
	  p_BUSINESS_RULE_VALUE6  NUMBER,
	  p_BUSINESS_RULE_VALUE7  NUMBER,
	  p_BUSINESS_RULE_VALUE8  NUMBER,
	  p_BUSINESS_RULE_VALUE9  NUMBER,
	  p_BUSINESS_RULE_VALUE10 NUMBER,
	  p_BUSINESS_RULE_VALUE11 NUMBER,
	  p_BUSINESS_RULE_VALUE12 NUMBER,
	  p_BUSINESS_RULE_VALUE13 NUMBER,
	  p_BUSINESS_RULE_VALUE14 NUMBER,
	  p_BUSINESS_RULE_VALUE15 NUMBER,
	  p_BUSINESS_RULE_VALUE16 NUMBER,
	  p_BUSINESS_RULE_VALUE17 NUMBER,
	  p_BUSINESS_RULE_VALUE18 NUMBER,
	  p_BUSINESS_RULE_VALUE19 NUMBER,
	  p_BUSINESS_RULE_VALUE20 NUMBER,
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
          p_ATTRIBUTE15    VARCHAR2
	  )
 IS
   CURSOR C2 IS SELECT CSP_BUSINESS_RULES_B_S1.nextval FROM sys.dual;
BEGIN
   If (px_BUSINESS_RULE_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO px_BUSINESS_RULE_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSP_BUSINESS_RULES_B(
           BUSINESS_RULE_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           BUSINESS_RULE_NAME,
           BUSINESS_RULE_TYPE,
	   BUSINESS_RULE_VALUE1,
	   BUSINESS_RULE_VALUE2,
	   BUSINESS_RULE_VALUE3,
	   BUSINESS_RULE_VALUE4,
	   BUSINESS_RULE_VALUE5,
	   BUSINESS_RULE_VALUE6,
	   BUSINESS_RULE_VALUE7,
	   BUSINESS_RULE_VALUE8,
	   BUSINESS_RULE_VALUE9,
	   BUSINESS_RULE_VALUE10,
	   BUSINESS_RULE_VALUE11,
	   BUSINESS_RULE_VALUE12,
	   BUSINESS_RULE_VALUE13,
	   BUSINESS_RULE_VALUE14,
	   BUSINESS_RULE_VALUE15,
	   BUSINESS_RULE_VALUE16,
	   BUSINESS_RULE_VALUE17,
	   BUSINESS_RULE_VALUE18,
	   BUSINESS_RULE_VALUE19,
	   BUSINESS_RULE_VALUE20,
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
          ) VALUES (
           px_BUSINESS_RULE_ID,
           p_CREATED_BY,
           p_CREATION_DATE,
           p_LAST_UPDATED_BY,
           p_LAST_UPDATE_DATE,
           p_LAST_UPDATE_LOGIN,
           p_BUSINESS_RULE_NAME,
           p_BUSINESS_RULE_TYPE,
	   p_BUSINESS_RULE_VALUE1,
	   p_BUSINESS_RULE_VALUE2,
	   p_BUSINESS_RULE_VALUE3,
	   p_BUSINESS_RULE_VALUE4,
	   p_BUSINESS_RULE_VALUE5,
	   p_BUSINESS_RULE_VALUE6,
	   p_BUSINESS_RULE_VALUE7,
	   p_BUSINESS_RULE_VALUE8,
	   p_BUSINESS_RULE_VALUE9,
	   p_BUSINESS_RULE_VALUE10,
	   p_BUSINESS_RULE_VALUE11,
	   p_BUSINESS_RULE_VALUE12,
	   p_BUSINESS_RULE_VALUE13,
	   p_BUSINESS_RULE_VALUE14,
	   p_BUSINESS_RULE_VALUE15,
	   p_BUSINESS_RULE_VALUE16,
	   p_BUSINESS_RULE_VALUE17,
	   p_BUSINESS_RULE_VALUE18,
	   p_BUSINESS_RULE_VALUE19,
	   p_BUSINESS_RULE_VALUE20,
           p_ATTRIBUTE_CATEGORY,
           p_ATTRIBUTE1,
           p_ATTRIBUTE2,
           p_ATTRIBUTE3,
           p_ATTRIBUTE4,
           p_ATTRIBUTE5,
           p_ATTRIBUTE6,
           p_ATTRIBUTE7,
           p_ATTRIBUTE8,
           p_ATTRIBUTE9,
           p_ATTRIBUTE10,
           p_ATTRIBUTE11,
           p_ATTRIBUTE12,
           p_ATTRIBUTE13,
           p_ATTRIBUTE14,
           p_ATTRIBUTE15);

  insert into CSP_BUSINESS_RULES_TL (
    BUSINESS_RULE_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    pX_BUSINESS_RULE_ID,
    p_CREATED_BY,
    p_CREATION_DATE,
    p_LAST_UPDATED_BY,
    p_last_update_DATE,
    p_LAST_UPDATE_LOGIN,
    p_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CSP_BUSINESS_RULES_TL T
    where T.BUSINESS_RULE_ID = pX_BUSINESS_RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

End Insert_Row;

PROCEDURE Update_Row(
          p_BUSINESS_RULE_ID      NUMBER,
          p_CREATED_BY            NUMBER,
          p_CREATION_DATE         DATE,
          p_LAST_UPDATED_BY       NUMBER,
          p_LAST_UPDATE_DATE      DATE,
          p_LAST_UPDATE_LOGIN     NUMBER,
          p_BUSINESS_RULE_NAME    VARCHAR2,
          p_DESCRIPTION    	  VARCHAR2,
          p_BUSINESS_RULE_TYPE    VARCHAR2,
	  p_BUSINESS_RULE_VALUE1  NUMBER,
	  p_BUSINESS_RULE_VALUE2  NUMBER,
	  p_BUSINESS_RULE_VALUE3  NUMBER,
	  p_BUSINESS_RULE_VALUE4  NUMBER,
	  p_BUSINESS_RULE_VALUE5  NUMBER,
	  p_BUSINESS_RULE_VALUE6  NUMBER,
	  p_BUSINESS_RULE_VALUE7  NUMBER,
	  p_BUSINESS_RULE_VALUE8  NUMBER,
	  p_BUSINESS_RULE_VALUE9  NUMBER,
	  p_BUSINESS_RULE_VALUE10 NUMBER,
	  p_BUSINESS_RULE_VALUE11 NUMBER,
	  p_BUSINESS_RULE_VALUE12 NUMBER,
	  p_BUSINESS_RULE_VALUE13 NUMBER,
	  p_BUSINESS_RULE_VALUE14 NUMBER,
	  p_BUSINESS_RULE_VALUE15 NUMBER,
	  p_BUSINESS_RULE_VALUE16 NUMBER,
	  p_BUSINESS_RULE_VALUE17 NUMBER,
	  p_BUSINESS_RULE_VALUE18 NUMBER,
	  p_BUSINESS_RULE_VALUE19 NUMBER,
	  p_BUSINESS_RULE_VALUE20 NUMBER,
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
 IS
 BEGIN
    Update CSP_BUSINESS_RULES_B
    SET
              CREATED_BY = p_CREATED_BY,
              CREATION_DATE = p_CREATION_DATE,
              LAST_UPDATED_BY = p_LAST_UPDATED_BY,
              LAST_UPDATE_DATE = p_last_update_DATE,
              LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN,
              BUSINESS_RULE_NAME = p_BUSINESS_RULE_NAME,
              BUSINESS_RULE_TYPE = p_BUSINESS_RULE_TYPE,
              BUSINESS_RULE_VALUE1 = p_BUSINESS_RULE_VALUE1,
              BUSINESS_RULE_VALUE2 = p_BUSINESS_RULE_VALUE2,
              BUSINESS_RULE_VALUE3 = p_BUSINESS_RULE_VALUE3,
              BUSINESS_RULE_VALUE4 = p_BUSINESS_RULE_VALUE4,
              BUSINESS_RULE_VALUE5 = p_BUSINESS_RULE_VALUE5,
              BUSINESS_RULE_VALUE6 = p_BUSINESS_RULE_VALUE6,
              BUSINESS_RULE_VALUE7 = p_BUSINESS_RULE_VALUE7,
              BUSINESS_RULE_VALUE8 = p_BUSINESS_RULE_VALUE8,
              BUSINESS_RULE_VALUE9 = p_BUSINESS_RULE_VALUE9,
              BUSINESS_RULE_VALUE10 = p_BUSINESS_RULE_VALUE10,
              BUSINESS_RULE_VALUE11 = p_BUSINESS_RULE_VALUE11,
              BUSINESS_RULE_VALUE12 = p_BUSINESS_RULE_VALUE12,
              BUSINESS_RULE_VALUE13 = p_BUSINESS_RULE_VALUE13,
              BUSINESS_RULE_VALUE14 = p_BUSINESS_RULE_VALUE14,
              BUSINESS_RULE_VALUE15 = p_BUSINESS_RULE_VALUE15,
              BUSINESS_RULE_VALUE16 = p_BUSINESS_RULE_VALUE16,
              BUSINESS_RULE_VALUE17 = p_BUSINESS_RULE_VALUE17,
              BUSINESS_RULE_VALUE18 = p_BUSINESS_RULE_VALUE18,
              BUSINESS_RULE_VALUE19 = p_BUSINESS_RULE_VALUE19,
              BUSINESS_RULE_VALUE20 = p_BUSINESS_RULE_VALUE20,
              ATTRIBUTE_CATEGORY = p_ATTRIBUTE_CATEGORY,
              ATTRIBUTE1 = p_ATTRIBUTE1,
              ATTRIBUTE2 = p_ATTRIBUTE2,
              ATTRIBUTE3 = p_ATTRIBUTE3,
              ATTRIBUTE4 = p_ATTRIBUTE4,
              ATTRIBUTE5 = p_ATTRIBUTE5,
              ATTRIBUTE6 = p_ATTRIBUTE6,
              ATTRIBUTE7 = p_ATTRIBUTE7,
              ATTRIBUTE8 = p_ATTRIBUTE8,
              ATTRIBUTE9 = p_ATTRIBUTE9,
              ATTRIBUTE10 = p_ATTRIBUTE10,
              ATTRIBUTE11 = p_ATTRIBUTE11,
              ATTRIBUTE12 = p_ATTRIBUTE12,
              ATTRIBUTE13 = p_ATTRIBUTE13,
              ATTRIBUTE14 = p_ATTRIBUTE14,
              ATTRIBUTE15 = p_ATTRIBUTE15
    where BUSINESS_RULE_ID = p_BUSINESS_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CSP_BUSINESS_RULES_TL set
    DESCRIPTION = p_DESCRIPTION,
    LAST_UPDATE_DATE = p_last_update_DATE,
    LAST_UPDATED_BY = p_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where BUSINESS_RULE_ID = p_BUSINESS_RULE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;


END Update_Row;

PROCEDURE Delete_Row(
    p_BUSINESS_RULE_ID  NUMBER)
 IS
 BEGIN
  delete from CSP_BUSINESS_RULES_TL
  where BUSINESS_RULE_ID = p_BUSINESS_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

   DELETE FROM CSP_BUSINESS_RULES_B
    WHERE BUSINESS_RULE_ID = p_BUSINESS_RULE_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_BUSINESS_RULE_ID      NUMBER,
          p_CREATED_BY            NUMBER,
          p_CREATION_DATE         DATE,
          p_LAST_UPDATED_BY       NUMBER,
          p_LAST_UPDATE_DATE      DATE,
          p_LAST_UPDATE_LOGIN     NUMBER,
          p_BUSINESS_RULE_NAME    VARCHAR2,
          p_DESCRIPTION    	  VARCHAR2,
          p_BUSINESS_RULE_TYPE    VARCHAR2,
	  p_BUSINESS_RULE_VALUE1  NUMBER,
	  p_BUSINESS_RULE_VALUE2  NUMBER,
	  p_BUSINESS_RULE_VALUE3  NUMBER,
	  p_BUSINESS_RULE_VALUE4  NUMBER,
	  p_BUSINESS_RULE_VALUE5  NUMBER,
	  p_BUSINESS_RULE_VALUE6  NUMBER,
	  p_BUSINESS_RULE_VALUE7  NUMBER,
	  p_BUSINESS_RULE_VALUE8  NUMBER,
	  p_BUSINESS_RULE_VALUE9  NUMBER,
	  p_BUSINESS_RULE_VALUE10 NUMBER,
	  p_BUSINESS_RULE_VALUE11 NUMBER,
	  p_BUSINESS_RULE_VALUE12 NUMBER,
	  p_BUSINESS_RULE_VALUE13 NUMBER,
	  p_BUSINESS_RULE_VALUE14 NUMBER,
	  p_BUSINESS_RULE_VALUE15 NUMBER,
	  p_BUSINESS_RULE_VALUE16 NUMBER,
	  p_BUSINESS_RULE_VALUE17 NUMBER,
	  p_BUSINESS_RULE_VALUE18 NUMBER,
	  p_BUSINESS_RULE_VALUE19 NUMBER,
	  p_BUSINESS_RULE_VALUE20 NUMBER,
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
 IS
   CURSOR C IS
        SELECT *
         FROM CSP_BUSINESS_RULES_B
        WHERE BUSINESS_RULE_ID =  p_BUSINESS_RULE_ID
        FOR UPDATE of BUSINESS_RULE_ID NOWAIT;

 cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CSP_BUSINESS_RULES_TL
    where BUSINESS_RULE_ID = p_BUSINESS_RULE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of BUSINESS_RULE_ID nowait;

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
           (      Recinfo.BUSINESS_RULE_ID = p_BUSINESS_RULE_ID)
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
       AND (    ( Recinfo.BUSINESS_RULE_NAME = p_BUSINESS_RULE_NAME)
            OR (    ( Recinfo.BUSINESS_RULE_NAME IS NULL )
                AND (  p_BUSINESS_RULE_NAME IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_TYPE = p_BUSINESS_RULE_TYPE)
            OR (    ( Recinfo.BUSINESS_RULE_TYPE IS NULL )
                AND (  p_BUSINESS_RULE_TYPE IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_VALUE1 = p_BUSINESS_RULE_VALUE1)
            OR (    ( Recinfo.BUSINESS_RULE_VALUE1 IS NULL )
                AND (  p_BUSINESS_RULE_VALUE1 IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_VALUE2 = p_BUSINESS_RULE_VALUE2)
            OR (    ( Recinfo.BUSINESS_RULE_VALUE2 IS NULL )
                AND (  p_BUSINESS_RULE_VALUE2 IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_VALUE3 = p_BUSINESS_RULE_VALUE3)
            OR (    ( Recinfo.BUSINESS_RULE_VALUE3 IS NULL )
                AND (  p_BUSINESS_RULE_VALUE3 IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_VALUE4 = p_BUSINESS_RULE_VALUE4)
            OR (    ( Recinfo.BUSINESS_RULE_VALUE4 IS NULL )
                AND (  p_BUSINESS_RULE_VALUE4 IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_VALUE5 = p_BUSINESS_RULE_VALUE5)
            OR (    ( Recinfo.BUSINESS_RULE_VALUE5 IS NULL )
                AND (  p_BUSINESS_RULE_VALUE5 IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_VALUE6 = p_BUSINESS_RULE_VALUE6)
            OR (    ( Recinfo.BUSINESS_RULE_VALUE6 IS NULL )
                AND (  p_BUSINESS_RULE_VALUE6 IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_VALUE7 = p_BUSINESS_RULE_VALUE7)
            OR (    ( Recinfo.BUSINESS_RULE_VALUE7 IS NULL )
                AND (  p_BUSINESS_RULE_VALUE7 IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_VALUE8 = p_BUSINESS_RULE_VALUE8)
            OR (    ( Recinfo.BUSINESS_RULE_VALUE8 IS NULL )
                AND (  p_BUSINESS_RULE_VALUE8 IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_VALUE9 = p_BUSINESS_RULE_VALUE9)
            OR (    ( Recinfo.BUSINESS_RULE_VALUE9 IS NULL )
                AND (  p_BUSINESS_RULE_VALUE9 IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_VALUE10 = p_BUSINESS_RULE_VALUE10)
            OR (    ( Recinfo.BUSINESS_RULE_VALUE10 IS NULL )
                AND (  p_BUSINESS_RULE_VALUE10 IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_VALUE11 = p_BUSINESS_RULE_VALUE11)
            OR (    ( Recinfo.BUSINESS_RULE_VALUE11 IS NULL )
                AND (  p_BUSINESS_RULE_VALUE11 IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_VALUE12 = p_BUSINESS_RULE_VALUE12)
            OR (    ( Recinfo.BUSINESS_RULE_VALUE12 IS NULL )
                AND (  p_BUSINESS_RULE_VALUE12 IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_VALUE13 = p_BUSINESS_RULE_VALUE13)
            OR (    ( Recinfo.BUSINESS_RULE_VALUE13 IS NULL )
                AND (  p_BUSINESS_RULE_VALUE13 IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_VALUE14 = p_BUSINESS_RULE_VALUE14)
            OR (    ( Recinfo.BUSINESS_RULE_VALUE14 IS NULL )
                AND (  p_BUSINESS_RULE_VALUE14 IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_VALUE15 = p_BUSINESS_RULE_VALUE15)
            OR (    ( Recinfo.BUSINESS_RULE_VALUE15 IS NULL )
                AND (  p_BUSINESS_RULE_VALUE15 IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_VALUE16 = p_BUSINESS_RULE_VALUE16)
            OR (    ( Recinfo.BUSINESS_RULE_VALUE16 IS NULL )
                AND (  p_BUSINESS_RULE_VALUE16 IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_VALUE17 = p_BUSINESS_RULE_VALUE17)
            OR (    ( Recinfo.BUSINESS_RULE_VALUE17 IS NULL )
                AND (  p_BUSINESS_RULE_VALUE17 IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_VALUE18 = p_BUSINESS_RULE_VALUE18)
            OR (    ( Recinfo.BUSINESS_RULE_VALUE18 IS NULL )
                AND (  p_BUSINESS_RULE_VALUE18 IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_VALUE19 = p_BUSINESS_RULE_VALUE19)
            OR (    ( Recinfo.BUSINESS_RULE_VALUE19 IS NULL )
                AND (  p_BUSINESS_RULE_VALUE19 IS NULL )))
       AND (    ( Recinfo.BUSINESS_RULE_VALUE20 = p_BUSINESS_RULE_VALUE20)
            OR (    ( Recinfo.BUSINESS_RULE_VALUE20 IS NULL )
                AND (  p_BUSINESS_RULE_VALUE20 IS NULL )))
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
       ) then

   null;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;

   for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DESCRIPTION = p_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (p_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;

END Lock_Row;

procedure ADD_LANGUAGE
is
begin
  delete from CSP_BUSINESS_RULES_TL T
  where not exists
    (select NULL
    from CSP_BUSINESS_RULES_B B
    where B.BUSINESS_RULE_ID = T.BUSINESS_RULE_ID
    );

  update CSP_BUSINESS_RULES_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from CSP_BUSINESS_RULES_TL B
    where B.BUSINESS_RULE_ID = T.BUSINESS_RULE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.BUSINESS_RULE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.BUSINESS_RULE_ID,
      SUBT.LANGUAGE
    from CSP_BUSINESS_RULES_TL SUBB, CSP_BUSINESS_RULES_TL SUBT
    where SUBB.BUSINESS_RULE_ID = SUBT.BUSINESS_RULE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CSP_BUSINESS_RULES_TL (
    BUSINESS_RULE_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.BUSINESS_RULE_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CSP_BUSINESS_RULES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CSP_BUSINESS_RULES_TL T
    where T.BUSINESS_RULE_ID = B.BUSINESS_RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE Translate_Row
( p_business_rule_id     IN  NUMBER
, p_description          IN  VARCHAR2
, p_owner                IN  VARCHAR2
)
IS
l_user_id    NUMBER := 0;
BEGIN

  if p_owner = 'SEED' then
    l_user_id := 1;
  end if;

  UPDATE csp_business_rules_tl
    SET description = p_description
      , last_update_date  = SYSDATE
      , last_updated_by   = l_user_id
      , last_update_login = 0
      , source_lang       = userenv('LANG')
    WHERE business_rule_id = p_business_rule_id
      AND userenv('LANG') IN (language, source_lang);

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Translate_Row');
    END IF;
    RAISE;

END Translate_Row;

PROCEDURE Load_Row
( p_business_rule_id    IN  NUMBER
, p_description         IN  VARCHAR2
, p_owner               IN VARCHAR2
)
IS

l_business_rule_id      NUMBER;
l_user_id               NUMBER := 0;

BEGIN

  -- assign user ID
  if p_owner = 'SEED' then
    l_user_id := 1; --SEED
  end if;

  BEGIN
    -- update row if present
    Update_Row(
          p_business_rule_id         	=>      p_business_rule_id,
          p_CREATED_BY                  =>      FND_API.G_MISS_NUM,
          p_CREATION_DATE               =>      FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY             =>      l_user_id,
          p_LAST_UPDATE_DATE            =>      SYSDATE,
          p_LAST_UPDATE_LOGIN           =>      0,
          p_business_rule_name       	=>      FND_API.G_MISS_CHAR,
          p_business_rule_type  	=>      FND_API.G_MISS_CHAR,
          p_business_rule_value1  	=>      FND_API.G_MISS_NUM,
          p_business_rule_value2  	=>      FND_API.G_MISS_NUM,
          p_business_rule_value3  	=>      FND_API.G_MISS_NUM,
          p_business_rule_value4  	=>      FND_API.G_MISS_NUM,
          p_business_rule_value5  	=>      FND_API.G_MISS_NUM,
          p_business_rule_value6  	=>      FND_API.G_MISS_NUM,
          p_business_rule_value7  	=>      FND_API.G_MISS_NUM,
          p_business_rule_value8  	=>      FND_API.G_MISS_NUM,
          p_business_rule_value9  	=>      FND_API.G_MISS_NUM,
          p_business_rule_value10  	=>      FND_API.G_MISS_NUM,
          p_business_rule_value11  	=>      FND_API.G_MISS_NUM,
          p_business_rule_value12  	=>      FND_API.G_MISS_NUM,
          p_business_rule_value13  	=>      FND_API.G_MISS_NUM,
          p_business_rule_value14  	=>      FND_API.G_MISS_NUM,
          p_business_rule_value15  	=>      FND_API.G_MISS_NUM,
          p_business_rule_value16  	=>      FND_API.G_MISS_NUM,
          p_business_rule_value17  	=>      FND_API.G_MISS_NUM,
          p_business_rule_value18  	=>      FND_API.G_MISS_NUM,
          p_business_rule_value19  	=>      FND_API.G_MISS_NUM,
          p_business_rule_value20  	=>      FND_API.G_MISS_NUM,
          p_ATTRIBUTE_CATEGORY          =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE1                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE2                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE3                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE4                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE5                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE6                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE7                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE8                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE9                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE10                 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE11                 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE12                 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE13                 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE14                 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE15                 =>      FND_API.G_MISS_CHAR,
          p_DESCRIPTION                 =>      p_description);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- insert row
      Insert_Row(
          px_business_rule_id        	=>      l_business_rule_id,
          p_CREATED_BY                  =>      FND_API.G_MISS_NUM,
          p_CREATION_DATE               =>      FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY             =>      l_user_id,
          p_LAST_UPDATE_DATE            =>      SYSDATE,
          p_LAST_UPDATE_LOGIN           =>      0,
          p_business_rule_name       	=>      FND_API.G_MISS_CHAR,
          p_business_rule_type    	=>      FND_API.G_MISS_CHAR,
          p_business_rule_value1    	=>      FND_API.G_MISS_NUM,
          p_business_rule_value2    	=>      FND_API.G_MISS_NUM,
          p_business_rule_value3    	=>      FND_API.G_MISS_NUM,
          p_business_rule_value4    	=>      FND_API.G_MISS_NUM,
          p_business_rule_value5    	=>      FND_API.G_MISS_NUM,
          p_business_rule_value6    	=>      FND_API.G_MISS_NUM,
          p_business_rule_value7    	=>      FND_API.G_MISS_NUM,
          p_business_rule_value8    	=>      FND_API.G_MISS_NUM,
          p_business_rule_value9    	=>      FND_API.G_MISS_NUM,
          p_business_rule_value10    	=>      FND_API.G_MISS_NUM,
          p_business_rule_value11    	=>      FND_API.G_MISS_NUM,
          p_business_rule_value12    	=>      FND_API.G_MISS_NUM,
          p_business_rule_value13    	=>      FND_API.G_MISS_NUM,
          p_business_rule_value14    	=>      FND_API.G_MISS_NUM,
          p_business_rule_value15    	=>      FND_API.G_MISS_NUM,
          p_business_rule_value16    	=>      FND_API.G_MISS_NUM,
          p_business_rule_value17    	=>      FND_API.G_MISS_NUM,
          p_business_rule_value18    	=>      FND_API.G_MISS_NUM,
          p_business_rule_value19    	=>      FND_API.G_MISS_NUM,
          p_business_rule_value20    	=>      FND_API.G_MISS_NUM,
          p_ATTRIBUTE_CATEGORY          =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE1                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE2                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE3                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE4                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE5                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE6                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE7                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE8                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE9                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE10                 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE11                 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE12                 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE13                 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE14                 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE15                 =>      FND_API.G_MISS_CHAR,
          p_DESCRIPTION                 =>      p_description);
  END;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Load_Row');
    END IF;
    RAISE;

END Load_Row;

End CSP_BUSINESS_RULES_PKG;

/

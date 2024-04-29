--------------------------------------------------------
--  DDL for Package Body OZF_REASON_CODES_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_REASON_CODES_ALL_PKG" as
/* $Header: ozftreab.pls 120.2 2005/07/08 07:07:05 appldev ship $ */
-- Start of Comments
-- Package name     : OZF_REASON_CODES_ALL_PKG
-- Purpose          :
-- History          : 30-AUG-2001  MCHANG   Add one more column: REASON_TYPE
--                    15-jul-2002  upoluri   Sequnce generation check.
-- History          : 28-SEP-2003  ANUJGUPT  Add one more column: PARTNER_ACCESS_FLAG  VARCHAR2(1)
-- History          : 28-SEP-2003  ANUJGUPT  Add one more column: PARTNER_ACCESS_FLAG  VARCHAR2(1)
-- History          : 22-Jun-2005  KDHULIPA  Add one more column: INVOICING_REASON_CODE  VARCHAR2(30)
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_REASON_CODES_ALL_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftreab.pls';

PROCEDURE Insert_Row(
          px_REASON_CODE_ID   IN OUT NOCOPY NUMBER,
          px_OBJECT_VERSION_NUMBER   IN OUT NOCOPY NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REASON_CODE    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE,
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
          p_NAME    VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          px_ORG_ID   IN OUT NOCOPY NUMBER,
          P_REASON_TYPE    VARCHAR2,
          p_ADJUSTMENT_REASON_CODE    VARCHAR2,
	  p_INVOICING_REASON_CODE   VARCHAR2,
          px_ORDER_TYPE_ID    NUMBER,
	  p_PARTNER_ACCESS_FLAG  VARCHAR2)

IS
   X_ROWID           VARCHAR2(30);
   l_reason_count   NUMBER;

   CURSOR C IS SELECT rowid FROM OZF_REASON_CODES_ALL_B
            WHERE REASON_CODE_ID = px_REASON_CODE_ID;
   CURSOR C2 IS SELECT OZF_REASON_CODES_ALL_B_S.nextval FROM sys.dual;
   CURSOR C_REASON_COUNT(l_reason_code_id NUMBER) IS
          SELECT COUNT(REASON_CODE_ID)
          FROM OZF_REASON_CODES_ALL_B
          WHERE REASON_CODE_ID = l_reason_code_id;

BEGIN
/*   IF (px_ORG_ID IS NULL OR px_ORG_ID = FND_API.G_MISS_NUM) THEN
       select nvl(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99)
       into px_ORG_ID
       from dual;
   END IF;  */

   IF (px_REASON_CODE_ID IS NULL) THEN
   LOOP
       OPEN C2;
        FETCH C2 INTO px_REASON_CODE_ID;
       CLOSE C2;

       OPEN C_REASON_COUNT(px_REASON_CODE_ID);
       FETCH C_REASON_COUNT INTO l_reason_count;
       CLOSE C_REASON_COUNT;
       EXIT WHEN l_reason_count = 0;
   END LOOP;
   END IF;

   IF (px_OBJECT_VERSION_NUMBER IS NULL OR
       px_OBJECT_VERSION_NUMBER = FND_API.G_MISS_NUM) THEN
       px_OBJECT_VERSION_NUMBER := 1;
   END IF;

   INSERT INTO OZF_REASON_CODES_ALL_B(
           REASON_CODE_ID,
           OBJECT_VERSION_NUMBER,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           REASON_CODE,
           START_DATE_ACTIVE,
           END_DATE_ACTIVE,
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
           ORG_ID,
           REASON_TYPE,
           ADJUSTMENT_REASON_CODE,
	   INVOICING_REASON_CODE,
           ORDER_TYPE_ID,
	   PARTNER_ACCESS_FLAG
          ) VALUES (
           px_REASON_CODE_ID,
           px_OBJECT_VERSION_NUMBER,
           p_LAST_UPDATE_DATE,
           p_LAST_UPDATED_BY,
           p_CREATION_DATE,
           p_CREATED_BY,
           p_LAST_UPDATE_LOGIN,
           p_REASON_CODE,
           p_START_DATE_ACTIVE,
           p_END_DATE_ACTIVE,
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
           p_ATTRIBUTE15,
           px_ORG_ID,
           p_REASON_TYPE,
           p_ADJUSTMENT_REASON_CODE,
	   p_INVOICING_REASON_CODE,
           px_ORDER_TYPE_ID,
	   p_PARTNER_ACCESS_FLAG  );

   INSERT INTO OZF_REASON_CODES_ALL_TL (
           REASON_CODE_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           NAME,
           DESCRIPTION,
           ORG_ID,
           LANGUAGE,
           SOURCE_LANG
   ) select
           px_REASON_CODE_ID,
           p_LAST_UPDATE_DATE,
           p_LAST_UPDATED_BY,
           p_CREATION_DATE,
           p_CREATED_BY,
           p_LAST_UPDATE_LOGIN,
           p_NAME,
           p_DESCRIPTION,
           px_ORG_ID,
           L.LANGUAGE_CODE,
           userenv('LANG')
   from FND_LANGUAGES L
   where L.INSTALLED_FLAG in ('I', 'B')
   and not exists
    (select NULL
     from OZF_REASON_CODES_ALL_TL T
     where T.REASON_CODE_ID = px_REASON_CODE_ID
     and T.LANGUAGE = L.LANGUAGE_CODE);

   OPEN C;
   FETCH C INTO x_rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;

PROCEDURE Update_Row(
          p_REASON_CODE_ID    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
--          p_CREATION_DATE    DATE,
--          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REASON_CODE    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE,
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
          p_NAME    VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_ORG_ID    NUMBER,
          P_REASON_TYPE    VARCHAR2,
          p_ADJUSTMENT_REASON_CODE    VARCHAR2,
	  p_INVOICING_REASON_CODE   VARCHAR2,
          p_ORDER_TYPE_ID   NUMBER,
	  p_PARTNER_ACCESS_FLAG  VARCHAR2)

 IS
 BEGIN
    Update OZF_REASON_CODES_ALL_B
    SET
              REASON_CODE_ID = p_REASON_CODE_ID,
              OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER,
              LAST_UPDATE_DATE = p_LAST_UPDATE_DATE,
              LAST_UPDATED_BY = p_LAST_UPDATED_BY,
--              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
--              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN,
              REASON_CODE = p_REASON_CODE,
              START_DATE_ACTIVE = p_START_DATE_ACTIVE,
              END_DATE_ACTIVE = p_END_DATE_ACTIVE,
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
              ATTRIBUTE15 = p_ATTRIBUTE15,
              ORG_ID = p_ORG_ID,
              REASON_TYPE = p_REASON_TYPE,
              ADJUSTMENT_REASON_CODE = p_ADJUSTMENT_REASON_CODE,
	      INVOICING_REASON_CODE = p_INVOICING_REASON_CODE,
              ORDER_TYPE_ID = p_ORDER_TYPE_ID,
	      PARTNER_ACCESS_FLAG = p_PARTNER_ACCESS_FLAG
    where REASON_CODE_ID = p_REASON_CODE_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

  update OZF_REASON_CODES_ALL_TL set
    NAME = p_NAME,
    DESCRIPTION = p_DESCRIPTION,
    LAST_UPDATE_DATE = p_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = p_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where REASON_CODE_ID = p_REASON_CODE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

END Update_Row;

PROCEDURE Delete_Row(
    p_REASON_CODE_ID  NUMBER)
 IS
 BEGIN
   delete from OZF_REASON_CODES_ALL_TL
   where REASON_CODE_ID = p_REASON_CODE_ID;

   if (sql%notfound) then
      raise no_data_found;
   end if;

   DELETE FROM OZF_REASON_CODES_ALL_B
   WHERE REASON_CODE_ID = p_REASON_CODE_ID;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
END Delete_Row;

PROCEDURE Lock_Row(
          p_REASON_CODE_ID    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REASON_CODE    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE,
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
          p_NAME    VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_ORG_ID    NUMBER,
          P_REASON_TYPE    VARCHAR2,
          p_ADJUSTMENT_REASON_CODE    VARCHAR2,
	  p_INVOICING_REASON_CODE VARCHAR2,
          p_ORDER_TYPE_ID    NUMBER,
	  p_PARTNER_ACCESS_FLAG  VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM OZF_REASON_CODES_ALL_B
        WHERE REASON_CODE_ID =  p_REASON_CODE_ID
        FOR UPDATE of REASON_CODE_ID NOWAIT;
   Recinfo C%ROWTYPE;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from OZF_REASON_CODES_ALL_TL
    where REASON_CODE_ID = p_REASON_CODE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of REASON_CODE_ID nowait;
 BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('OZF', 'OZF_API_RECORD_NOT_FOUND');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;
    if (
           (      Recinfo.REASON_CODE_ID = p_REASON_CODE_ID)
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
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
       AND (    ( Recinfo.REASON_CODE = p_REASON_CODE)
            OR (    ( Recinfo.REASON_CODE IS NULL )
                AND (  p_REASON_CODE IS NULL )))
       AND (    ( Recinfo.START_DATE_ACTIVE = p_START_DATE_ACTIVE)
            OR (    ( Recinfo.START_DATE_ACTIVE IS NULL )
                AND (  p_START_DATE_ACTIVE IS NULL )))
       AND (    ( Recinfo.END_DATE_ACTIVE = p_END_DATE_ACTIVE)
            OR (    ( Recinfo.END_DATE_ACTIVE IS NULL )
                AND (  p_END_DATE_ACTIVE IS NULL )))
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
       AND (    ( Recinfo.ORG_ID = p_ORG_ID)
            OR (    ( Recinfo.ORG_ID IS NULL )
                AND (  p_ORG_ID IS NULL )))
       AND (    ( Recinfo.REASON_TYPE = p_REASON_TYPE)
            OR (    ( Recinfo.REASON_TYPE IS NULL )
                AND (  p_REASON_TYPE IS NULL )))
       AND (    ( Recinfo.ADJUSTMENT_REASON_CODE = p_ADJUSTMENT_REASON_CODE)
            OR (    ( Recinfo.ADJUSTMENT_REASON_CODE IS NULL )
                AND (  p_ADJUSTMENT_REASON_CODE IS NULL )))
	AND (    ( Recinfo.INVOICING_REASON_CODE = p_INVOICING_REASON_CODE)
            OR (    ( Recinfo.INVOICING_REASON_CODE IS NULL )
                AND (  p_INVOICING_REASON_CODE IS NULL )))
       AND (    ( Recinfo.ORDER_TYPE_ID = p_ORDER_TYPE_ID)
            OR (    ( Recinfo.ORDER_TYPE_ID IS NULL )
                AND (  p_ORDER_TYPE_ID IS NULL )))
       AND (    ( Recinfo.PARTNER_ACCESS_FLAG = p_PARTNER_ACCESS_FLAG)
            OR (    ( Recinfo.PARTNER_ACCESS_FLAG IS NULL )
                AND (  p_PARTNER_ACCESS_FLAG IS NULL )))

       ) then
       null;
   else
       FND_MESSAGE.SET_NAME('OZF', 'OZF_API_RECORD_NOT_FOUND');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = p_NAME)
          AND ((tlinfo.DESCRIPTION = p_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (p_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;

END Lock_Row;

procedure ADD_LANGUAGE
is
begin
  delete from OZF_REASON_CODES_ALL_TL T
  where not exists
    (select NULL
    from OZF_REASON_CODES_ALL_B B
    where B.REASON_CODE_ID = T.REASON_CODE_ID
    and   NVL(B.ORG_ID,NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
          NVL(T.ORG_ID, NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99))
    );

  update OZF_REASON_CODES_ALL_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from OZF_REASON_CODES_ALL_TL B
    where B.REASON_CODE_ID = T.REASON_CODE_ID
    and B.LANGUAGE = T.SOURCE_LANG
    and   NVL(B.ORG_ID,NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
          NVL(T.ORG_ID, NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) )
  where (
      T.REASON_CODE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.REASON_CODE_ID,
      SUBT.LANGUAGE
    from OZF_REASON_CODES_ALL_TL SUBB, OZF_REASON_CODES_ALL_TL SUBT
    where SUBB.REASON_CODE_ID = SUBT.REASON_CODE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and   NVL(SUBB.ORG_ID,NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
          NVL(SUBT.ORG_ID, NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99))
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into OZF_REASON_CODES_ALL_TL (
    ORG_ID,
    REASON_CODE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ORG_ID,
    B.REASON_CODE_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from OZF_REASON_CODES_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from OZF_REASON_CODES_ALL_TL T
    where T.REASON_CODE_ID = B.REASON_CODE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE
    and   NVL(T.ORG_ID,NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
          NVL(B.ORG_ID, NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
          NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) );
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_REASON_CODE_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2) IS
begin

    -- note org_id is not used here because in NLS mode it is important
    -- update a line id across all orgs because data will be translated
    -- only once for a single org

    update ozf_reason_codes_all_tl
      set name = X_NAME,
          description = X_DESCRIPTION,
          source_lang = userenv('LANG'),
          last_update_date = sysdate,
          last_updated_by = decode(X_OWNER, 'SEED', -1, 0),
          last_update_login = 0
    where reason_code_id = X_REASON_CODE_ID
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

End OZF_REASON_CODES_ALL_PKG;

/

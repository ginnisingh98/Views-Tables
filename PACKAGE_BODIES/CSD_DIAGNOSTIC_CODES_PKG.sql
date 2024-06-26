--------------------------------------------------------
--  DDL for Package Body CSD_DIAGNOSTIC_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_DIAGNOSTIC_CODES_PKG" as
/* $Header: csdtcdcb.pls 115.4 2003/11/04 23:54:42 gilam noship $ */

procedure INSERT_ROW (
  PX_ROWID in out nocopy VARCHAR2,
  PX_DIAGNOSTIC_CODE_ID in out nocopy NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_CREATED_BY in NUMBER,
  P_CREATION_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATE_LOGIN in NUMBER,
  P_DIAGNOSTIC_CODE in VARCHAR2,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_ACTIVE_FROM in DATE,
  P_ACTIVE_TO in DATE,
  P_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2
) is
  cursor C is select ROWID from CSD_DIAGNOSTIC_CODES_B
    where DIAGNOSTIC_CODE_ID = PX_DIAGNOSTIC_CODE_ID
    ;
begin

  select CSD_DIAGNOSTIC_CODES_S1.nextval
  into PX_DIAGNOSTIC_CODE_ID
  from dual;

  insert into CSD_DIAGNOSTIC_CODES_B (
    DIAGNOSTIC_CODE_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DIAGNOSTIC_CODE,
    ACTIVE_FROM,
    ACTIVE_TO,
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
  ) values (
    PX_DIAGNOSTIC_CODE_ID,
    P_OBJECT_VERSION_NUMBER,
    P_CREATED_BY,
    P_CREATION_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATE_LOGIN,
    P_DIAGNOSTIC_CODE,
    P_ACTIVE_FROM,
    P_ACTIVE_TO,
    P_ATTRIBUTE_CATEGORY,
    P_ATTRIBUTE1,
    P_ATTRIBUTE2,
    P_ATTRIBUTE3,
    P_ATTRIBUTE4,
    P_ATTRIBUTE5,
    P_ATTRIBUTE6,
    P_ATTRIBUTE7,
    P_ATTRIBUTE8,
    P_ATTRIBUTE9,
    P_ATTRIBUTE10,
    P_ATTRIBUTE11,
    P_ATTRIBUTE12,
    P_ATTRIBUTE13,
    P_ATTRIBUTE14,
    P_ATTRIBUTE15  );

  insert into CSD_DIAGNOSTIC_CODES_TL (
    DIAGNOSTIC_CODE_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    PX_DIAGNOSTIC_CODE_ID,
    P_CREATED_BY,
    P_CREATION_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATE_LOGIN,
    P_NAME,
    P_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CSD_DIAGNOSTIC_CODES_TL T
    where T.DIAGNOSTIC_CODE_ID = PX_DIAGNOSTIC_CODE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into PX_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  PX_ROWID in out nocopy VARCHAR2,
  P_DIAGNOSTIC_CODE_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER

  --commented out the rest of the record
  /*,
  P_DIAGNOSTIC_CODE in VARCHAR2,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_ACTIVE_FROM in DATE,
  P_ACTIVE_TO in DATE,
  P_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2
  */
  --
) is
  cursor c is select
    DIAGNOSTIC_CODE_ID,
    OBJECT_VERSION_NUMBER

    --commented out the rest of the fields
    /*,
    DIAGNOSTIC_CODE,
    ACTIVE_FROM,
    ACTIVE_TO,
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
    */
    --
    from CSD_DIAGNOSTIC_CODES_B
    where DIAGNOSTIC_CODE_ID = P_DIAGNOSTIC_CODE_ID
    for update of DIAGNOSTIC_CODE_ID nowait;
  recinfo c%rowtype;

  --commented out cursor for TL table
  /*
  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CSD_DIAGNOSTIC_CODES_TL
    where DIAGNOSTIC_CODE_ID = P_DIAGNOSTIC_CODE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DIAGNOSTIC_CODE_ID nowait;
  */
  --
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
 if (
          (recinfo.DIAGNOSTIC_CODE_ID = P_DIAGNOSTIC_CODE_ID)
      AND ((recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
           OR (recinfo.OBJECT_VERSION_NUMBER IS NULL ))

      --commented out the comparison for the rest of the record
      /*
      AND ((recinfo.ATTRIBUTE10 = P_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (P_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = P_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (P_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE7 = P_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (P_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = P_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (P_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = P_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (P_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE15 = P_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (P_ATTRIBUTE15 is null)))
      AND (recinfo.DIAGNOSTIC_CODE = P_DIAGNOSTIC_CODE)

      AND ((recinfo.ACTIVE_FROM = P_ACTIVE_FROM)
           OR ((recinfo.ACTIVE_FROM is null) AND (P_ACTIVE_FROM = FND_API.G_MISS_DATE))
           OR (P_ACTIVE_FROM is null))

      AND ((recinfo.ACTIVE_TO = P_ACTIVE_TO)
           OR ((recinfo.ACTIVE_TO is null) AND (P_ACTIVE_TO = FND_API.G_MISS_DATE))
           OR (P_ACTIVE_TO is null))

      AND ((recinfo.ATTRIBUTE_CATEGORY = P_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (P_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = P_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (P_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = P_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (P_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = P_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (P_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = P_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (P_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = P_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (P_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = P_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (P_ATTRIBUTE6 is null)))
        AND ((recinfo.ATTRIBUTE12 = P_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (P_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = P_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (P_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = P_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (P_ATTRIBUTE14 is null)))
      */
      --
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  --commented out the comparison for TL fields
  /*
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = P_NAME)
          AND ((tlinfo.DESCRIPTION = P_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (P_DESCRIPTION = FND_API.G_MISS_CHAR))
               OR (P_DESCRIPTION is null))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  */
  --
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  P_DIAGNOSTIC_CODE_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_CREATED_BY in NUMBER,
  P_CREATION_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATE_LOGIN in NUMBER,
  P_DIAGNOSTIC_CODE in VARCHAR2,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_ACTIVE_FROM in DATE,
  P_ACTIVE_TO in DATE,
  P_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2
) is
begin
  update CSD_DIAGNOSTIC_CODES_B set
        OBJECT_VERSION_NUMBER = decode( P_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, NULL, OBJECT_VERSION_NUMBER, P_OBJECT_VERSION_NUMBER)
       ,CREATED_BY = decode( P_CREATED_BY, FND_API.G_MISS_NUM, NULL, NULL, CREATED_BY, P_CREATED_BY)
       ,CREATION_DATE = decode( P_CREATION_DATE, FND_API.G_MISS_DATE, NULL, NULL, CREATION_DATE, P_CREATION_DATE)
       ,LAST_UPDATED_BY = decode( P_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, NULL, LAST_UPDATED_BY, P_LAST_UPDATED_BY)
       ,LAST_UPDATE_DATE = decode( P_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, NULL, LAST_UPDATE_DATE, P_LAST_UPDATE_DATE)
       ,LAST_UPDATE_LOGIN = decode( P_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, NULL, LAST_UPDATE_LOGIN, P_LAST_UPDATE_LOGIN)
       ,DIAGNOSTIC_CODE = decode( P_DIAGNOSTIC_CODE, FND_API.G_MISS_CHAR, NULL, NULL, DIAGNOSTIC_CODE, P_DIAGNOSTIC_CODE)
       ,ACTIVE_FROM = decode( P_ACTIVE_FROM, FND_API.G_MISS_DATE, NULL, NULL, ACTIVE_FROM, P_ACTIVE_FROM)
       ,ACTIVE_TO = decode( P_ACTIVE_TO, FND_API.G_MISS_DATE, NULL, NULL, ACTIVE_TO, P_ACTIVE_TO)
       ,ATTRIBUTE_CATEGORY = decode( P_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE_CATEGORY, P_ATTRIBUTE_CATEGORY)
       ,ATTRIBUTE1 = decode( P_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE1, P_ATTRIBUTE1)
       ,ATTRIBUTE2 = decode( P_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE2, P_ATTRIBUTE2)
       ,ATTRIBUTE3 = decode( P_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE3, P_ATTRIBUTE3)
       ,ATTRIBUTE4 = decode( P_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE4, P_ATTRIBUTE4)
       ,ATTRIBUTE5 = decode( P_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE5, P_ATTRIBUTE5)
       ,ATTRIBUTE6 = decode( P_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE6, P_ATTRIBUTE6)
       ,ATTRIBUTE7 = decode( P_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE7, P_ATTRIBUTE7)
       ,ATTRIBUTE8 = decode( P_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE8, P_ATTRIBUTE8)
       ,ATTRIBUTE9 = decode( P_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE9, P_ATTRIBUTE9)
       ,ATTRIBUTE10 = decode( P_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE10, P_ATTRIBUTE10)
       ,ATTRIBUTE11 = decode( P_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE11, P_ATTRIBUTE11)
       ,ATTRIBUTE12 = decode( P_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE12, P_ATTRIBUTE12)
       ,ATTRIBUTE13 = decode( P_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE13, P_ATTRIBUTE13)
       ,ATTRIBUTE14 = decode( P_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE14, P_ATTRIBUTE14)
       ,ATTRIBUTE15 = decode( P_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE15, P_ATTRIBUTE15)
  where DIAGNOSTIC_CODE_ID = P_DIAGNOSTIC_CODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CSD_DIAGNOSTIC_CODES_TL set
          CREATED_BY = decode( P_CREATED_BY, FND_API.G_MISS_NUM, NULL, NULL, CREATED_BY, P_CREATED_BY)
         ,CREATION_DATE = decode( P_CREATION_DATE, FND_API.G_MISS_DATE, NULL, NULL, CREATION_DATE, P_CREATION_DATE)
         ,LAST_UPDATED_BY = decode( P_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, NULL, LAST_UPDATED_BY, P_LAST_UPDATED_BY)
         ,LAST_UPDATE_DATE = decode( P_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, NULL, LAST_UPDATE_DATE, P_LAST_UPDATE_DATE)
         ,LAST_UPDATE_LOGIN = decode( P_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, NULL, LAST_UPDATE_LOGIN, P_LAST_UPDATE_LOGIN)
         ,NAME = decode( P_NAME, FND_API.G_MISS_CHAR, NULL, NULL, NAME, P_NAME)
         ,DESCRIPTION = decode( P_DESCRIPTION, FND_API.G_MISS_CHAR, NULL, NULL, DESCRIPTION, P_DESCRIPTION)
         ,SOURCE_LANG = userenv('LANG')
  where DIAGNOSTIC_CODE_ID = P_DIAGNOSTIC_CODE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  P_DIAGNOSTIC_CODE_ID in NUMBER
) is
begin
  delete from CSD_DIAGNOSTIC_CODES_TL
  where DIAGNOSTIC_CODE_ID = P_DIAGNOSTIC_CODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CSD_DIAGNOSTIC_CODES_B
  where DIAGNOSTIC_CODE_ID = P_DIAGNOSTIC_CODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CSD_DIAGNOSTIC_CODES_TL T
  where not exists
    (select NULL
    from CSD_DIAGNOSTIC_CODES_B B
    where B.DIAGNOSTIC_CODE_ID = T.DIAGNOSTIC_CODE_ID
    );

  update CSD_DIAGNOSTIC_CODES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from CSD_DIAGNOSTIC_CODES_TL B
    where B.DIAGNOSTIC_CODE_ID = T.DIAGNOSTIC_CODE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DIAGNOSTIC_CODE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DIAGNOSTIC_CODE_ID,
      SUBT.LANGUAGE
    from CSD_DIAGNOSTIC_CODES_TL SUBB, CSD_DIAGNOSTIC_CODES_TL SUBT
    where SUBB.DIAGNOSTIC_CODE_ID = SUBT.DIAGNOSTIC_CODE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CSD_DIAGNOSTIC_CODES_TL (
    DIAGNOSTIC_CODE_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.DIAGNOSTIC_CODE_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CSD_DIAGNOSTIC_CODES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CSD_DIAGNOSTIC_CODES_TL T
    where T.DIAGNOSTIC_CODE_ID = B.DIAGNOSTIC_CODE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end CSD_DIAGNOSTIC_CODES_PKG;

/

--------------------------------------------------------
--  DDL for Package Body CSD_RULE_CONDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_RULE_CONDITIONS_PKG" as
/* $Header: csdtrcnb.pls 120.0.12010000.1 2008/12/11 01:08:45 swai noship $ */

procedure INSERT_ROW (
  PX_ROWID             in out nocopy VARCHAR2,
  PX_RULE_CONDITION_ID          in out nocopy NUMBER,
  P_OBJECT_VERSION_NUMBER        in NUMBER,
  P_CREATION_DATE                in DATE,
  P_CREATED_BY                   in NUMBER,
  P_LAST_UPDATE_DATE             in DATE,
  P_LAST_UPDATED_BY              in NUMBER,
  P_LAST_UPDATE_LOGIN            in NUMBER,
  P_NAME                         in VARCHAR2,
  P_RULE_ID                      in NUMBER,
  P_ATTRIBUTE_CATEGORY           in VARCHAR2,
  P_ATTRIBUTE1                   in VARCHAR2,
  P_ATTRIBUTE2                   in VARCHAR2,
  P_ATTRIBUTE3                   in VARCHAR2,
  P_ATTRIBUTE4                   in VARCHAR2,
  P_ATTRIBUTE5                   in VARCHAR2,
  P_ATTRIBUTE6                   in VARCHAR2,
  P_ATTRIBUTE7                   in VARCHAR2,
  P_ATTRIBUTE8                   in VARCHAR2,
  P_ATTRIBUTE9                   in VARCHAR2,
  P_ATTRIBUTE10                  in VARCHAR2,
  P_ATTRIBUTE11                  in VARCHAR2,
  P_ATTRIBUTE12                  in VARCHAR2,
  P_ATTRIBUTE13                  in VARCHAR2,
  P_ATTRIBUTE14                  in VARCHAR2,
  P_ATTRIBUTE15                  in VARCHAR2
) is

  cursor C is select ROWID from CSD_RULE_CONDITIONS_B
    where RULE_CONDITION_ID = PX_RULE_CONDITION_ID
    ;

begin

  select CSD_RULE_CONDITIONS_S1.nextval
  into PX_RULE_CONDITION_ID
  from dual;

  insert into CSD_RULE_CONDITIONS_B (
    RULE_CONDITION_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    RULE_ID,
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
    PX_RULE_CONDITION_ID,
    P_OBJECT_VERSION_NUMBER,
    P_CREATION_DATE,
    P_CREATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN,
    P_RULE_ID,
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
    P_ATTRIBUTE15
  );

  insert into CSD_RULE_CONDITIONS_TL (
    RULE_CONDITION_ID,
    NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
        PX_RULE_CONDITION_ID,
        P_NAME,
        P_CREATED_BY,
        P_CREATION_DATE,
        P_LAST_UPDATED_BY,
        P_LAST_UPDATE_DATE,
        P_LAST_UPDATE_LOGIN,
        L.LANGUAGE_CODE,
        userenv('LANG')
    from FND_LANGUAGES L
   where L.INSTALLED_FLAG in ('I', 'B')
     and not exists
    (select NULL
       from CSD_RULE_CONDITIONS_TL T
      where T.RULE_CONDITION_ID = PX_RULE_CONDITION_ID
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
  P_RULE_CONDITION_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      OBJECT_VERSION_NUMBER
    from CSD_RULE_CONDITIONS_B
    where RULE_CONDITION_ID = P_RULE_CONDITION_ID
    for update of RULE_CONDITION_ID nowait;
  recinfo c%rowtype;

begin

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if (recinfo.OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

/*
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DESCRIPTION = P_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (P_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
*/

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  P_RULE_CONDITION_ID            in NUMBER,
  P_OBJECT_VERSION_NUMBER        in NUMBER,
  P_CREATION_DATE                in DATE,
  P_CREATED_BY                   in NUMBER,
  P_LAST_UPDATE_DATE             in DATE,
  P_LAST_UPDATED_BY              in NUMBER,
  P_LAST_UPDATE_LOGIN            in NUMBER,
  P_NAME                         in VARCHAR2,
  P_RULE_ID                      in NUMBER,
  P_ATTRIBUTE_CATEGORY           in VARCHAR2,
  P_ATTRIBUTE1                   in VARCHAR2,
  P_ATTRIBUTE2                   in VARCHAR2,
  P_ATTRIBUTE3                   in VARCHAR2,
  P_ATTRIBUTE4                   in VARCHAR2,
  P_ATTRIBUTE5                   in VARCHAR2,
  P_ATTRIBUTE6                   in VARCHAR2,
  P_ATTRIBUTE7                   in VARCHAR2,
  P_ATTRIBUTE8                   in VARCHAR2,
  P_ATTRIBUTE9                   in VARCHAR2,
  P_ATTRIBUTE10                  in VARCHAR2,
  P_ATTRIBUTE11                  in VARCHAR2,
  P_ATTRIBUTE12                  in VARCHAR2,
  P_ATTRIBUTE13                  in VARCHAR2,
  P_ATTRIBUTE14                  in VARCHAR2,
  P_ATTRIBUTE15                  in VARCHAR2
) is
begin
  update CSD_RULE_CONDITIONS_B set
         OBJECT_VERSION_NUMBER = decode( P_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, NULL, OBJECT_VERSION_NUMBER, P_OBJECT_VERSION_NUMBER)
         ,CREATED_BY = decode( P_CREATED_BY, FND_API.G_MISS_NUM, NULL, NULL, CREATED_BY, P_CREATED_BY)
         ,CREATION_DATE = decode( P_CREATION_DATE, FND_API.G_MISS_DATE, NULL, NULL, CREATION_DATE, P_CREATION_DATE)
         ,LAST_UPDATED_BY = decode( P_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, NULL, LAST_UPDATED_BY, P_LAST_UPDATED_BY)
         ,LAST_UPDATE_DATE = decode( P_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, NULL, LAST_UPDATE_DATE, P_LAST_UPDATE_DATE)
         ,LAST_UPDATE_LOGIN = decode( P_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, NULL, LAST_UPDATE_LOGIN, P_LAST_UPDATE_LOGIN)

         ,RULE_ID = decode( P_RULE_ID, FND_API.G_MISS_NUM, NULL, NULL, RULE_ID, P_RULE_ID)

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
  where RULE_CONDITION_ID = P_RULE_CONDITION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CSD_RULE_CONDITIONS_TL set
          CREATED_BY = decode( P_CREATED_BY, FND_API.G_MISS_NUM, NULL, NULL, CREATED_BY, P_CREATED_BY)
         ,CREATION_DATE = decode( P_CREATION_DATE, FND_API.G_MISS_DATE, NULL, NULL, CREATION_DATE, P_CREATION_DATE)
         ,LAST_UPDATED_BY = decode( P_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, NULL, LAST_UPDATED_BY, P_LAST_UPDATED_BY)
         ,LAST_UPDATE_DATE = decode( P_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, NULL, LAST_UPDATE_DATE, P_LAST_UPDATE_DATE)
         ,LAST_UPDATE_LOGIN = decode( P_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, NULL, LAST_UPDATE_LOGIN, P_LAST_UPDATE_LOGIN)
         ,NAME = decode( P_NAME, FND_API.G_MISS_CHAR, NULL, NULL, NAME, P_NAME)
         ,SOURCE_LANG = userenv('LANG')
  where RULE_CONDITION_ID = P_RULE_CONDITION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  P_RULE_CONDITION_ID in NUMBER
) is
begin
  delete from CSD_RULE_CONDITIONS_TL
  where RULE_CONDITION_ID = P_RULE_CONDITION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CSD_RULE_CONDITIONS_B
  where RULE_CONDITION_ID = P_RULE_CONDITION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CSD_RULE_CONDITIONS_TL T
  where not exists
    (select NULL
    from CSD_RULE_CONDITIONS_B B
    where B.RULE_CONDITION_ID = T.RULE_CONDITION_ID
    );

  update CSD_RULE_CONDITIONS_TL T set (
      NAME
    ) = (select
      B.NAME
    from CSD_RULE_CONDITIONS_TL B
    where B.RULE_CONDITION_ID = T.RULE_CONDITION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RULE_CONDITION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RULE_CONDITION_ID,
      SUBT.LANGUAGE
    from CSD_RULE_CONDITIONS_TL SUBB, CSD_RULE_CONDITIONS_TL SUBT
    where SUBB.RULE_CONDITION_ID = SUBT.RULE_CONDITION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
  ));

  insert into CSD_RULE_CONDITIONS_TL (
    RULE_CONDITION_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.RULE_CONDITION_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CSD_RULE_CONDITIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CSD_RULE_CONDITIONS_TL T
    where T.RULE_CONDITION_ID = B.RULE_CONDITION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end CSD_RULE_CONDITIONS_PKG;

/

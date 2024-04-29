--------------------------------------------------------
--  DDL for Package Body CS_FORUM_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_FORUM_CATEGORIES_PKG" AS
/* $Header: csfcab.pls 120.1 2005/06/22 12:20:52 appldev ship $ */
procedure INSERT_ROW (
  X_CATEGORY_ID in NUMBER,
  X_CATEGORY_TYPE in VARCHAR2,
  X_CATEGORY_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL
) is
  cursor C is select CATEGORY_ID from CS_FORUM_CATEGORIES_B
    where CATEGORY_ID = X_CATEGORY_ID
    ;
begin
  insert into CS_FORUM_CATEGORIES_B (
    CATEGORY_ID,
    CATEGORY_TYPE,
    CATEGORY_NAME,
    STATUS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
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
    X_CATEGORY_ID,
    X_CATEGORY_TYPE,
    X_CATEGORY_NAME,
    X_STATUS,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15
  );

  insert into CS_FORUM_CATEGORIES_TL (
    CATEGORY_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CATEGORY_ID,
    X_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CS_FORUM_CATEGORIES_TL T
    where T.CATEGORY_ID = X_CATEGORY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
/*
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
*/
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_CATEGORY_ID in NUMBER,
  X_CATEGORY_TYPE in VARCHAR2,
  X_CATEGORY_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL
) is
  cursor c is select
      CATEGORY_ID,
      CATEGORY_TYPE,
      CATEGORY_NAME,
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
    from CS_FORUM_CATEGORIES_B
    where CATEGORY_ID = X_CATEGORY_ID
    for update of CATEGORY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CS_FORUM_CATEGORIES_TL
    where CATEGORY_ID = X_CATEGORY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CATEGORY_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
/*    fnd_CATEGORY.set_name('FND', 'FORM_RECORD_DELETED');   */
    app_exception.raise_exception;
  end if;
  close c;
  if (
          ((recinfo.CATEGORY_ID = X_CATEGORY_ID)
           OR ((recinfo.CATEGORY_ID is null) AND (X_CATEGORY_ID is null)))
      AND ((recinfo.CATEGORY_NAME = X_CATEGORY_NAME)
           OR ((recinfo.CATEGORY_NAME is null) AND (X_CATEGORY_NAME is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
  ) then
    null;
  else
/*    fnd_CATEGORY.set_name('FND', 'FORM_RECORD_CHANGED');   */
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.NAME = X_NAME)
               OR ((tlinfo.NAME is null) AND (X_NAME is null)))
          AND ((X_DESCRIPTION = tlinfo.DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
/*        fnd_CATEGORY.set_name('FND', 'FORM_RECORD_CHANGED');   */
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_CATEGORY_ID in NUMBER,
  X_CATEGORY_TYPE in VARCHAR2,
  X_CATEGORY_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL
) is
begin
  update CS_FORUM_CATEGORIES_B set
    CATEGORY_TYPE = X_CATEGORY_TYPE,
    CATEGORY_NAME = X_CATEGORY_NAME,
    STATUS = X_STATUS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15
  where CATEGORY_ID = X_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CS_FORUM_CATEGORIES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CATEGORY_ID = X_CATEGORY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CATEGORY_ID in NUMBER
) is
begin
  delete from CS_FORUM_CATEGORIES_TL
  where CATEGORY_ID = X_CATEGORY_ID;

/*
  if (sql%notfound) then
    raise no_data_found;
  end if;
  */

  delete from CS_FORUM_CATEGORIES_B
  where CATEGORY_ID = X_CATEGORY_ID;
/*
  if (sql%notfound) then
    raise no_data_found;
  end if;
  */
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CS_FORUM_CATEGORIES_TL T
  where not exists
    (select NULL
    from CS_FORUM_CATEGORIES_B B
    where B.CATEGORY_ID = T.CATEGORY_ID
    );

  update CS_FORUM_CATEGORIES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from CS_FORUM_CATEGORIES_TL B
    where B.CATEGORY_ID = T.CATEGORY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CATEGORY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CATEGORY_ID,
      SUBT.LANGUAGE
    from CS_FORUM_CATEGORIES_TL SUBB, CS_FORUM_CATEGORIES_TL SUBT
    where SUBB.CATEGORY_ID = SUBT.CATEGORY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or (SUBB.DESCRIPTION <> SUBT.DESCRIPTION)
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CS_FORUM_CATEGORIES_TL (
    CATEGORY_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CATEGORY_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CS_FORUM_CATEGORIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CS_FORUM_CATEGORIES_TL T
    where T.CATEGORY_ID = B.CATEGORY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;



PROCEDURE TRANSLATE_ROW(
        X_CATEGORY_ID in number,
        x_name in varchar2,
        x_description in varchar2,
        x_owner in varchar2
        )
is
begin
    update cs_forum_categories_tl set
        description = x_description,
        name = x_name,
        LAST_UPDATE_DATE = sysdate,
        LAST_UPDATED_BY = decode(x_owner, 'SEED', 1, 0),
        LAST_UPDATE_LOGIN = 0,
        SOURCE_LANG = userenv('LANG')
        where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
           and CATEGORY_ID = X_CATEGORY_ID;
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_CATEGORY_ID in NUMBER,
  X_CATEGORY_TYPE in VARCHAR2,
  X_CATEGORY_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_STATUS in VARCHAR2,
  x_owner in varchar2

) is
    l_user_id number;

begin
    if (x_owner = 'SEED') then
           l_user_id := 1;
    else
           l_user_id := 0;
    end if;

    CS_FORUM_CATEGORIES_PKG.Update_Row(
        	X_CATEGORY_ID => X_CATEGORY_ID,
       		X_CATEGORY_TYPE => X_CATEGORY_TYPE,
            X_CATEGORY_NAME => X_CATEGORY_NAME,
            X_NAME => X_NAME,
            X_DESCRIPTION => X_DESCRIPTION,
            X_STATUS => X_STATUS,
    		X_Last_Update_Date => sysdate,
    		X_Last_Updated_By => l_user_id,
    		X_Last_Update_Login => 0);

     exception
      when no_data_found then
        	CS_FORUM_CATEGORIES_PKG.Insert_Row(
        	X_CATEGORY_ID => X_CATEGORY_ID,
       		X_CATEGORY_TYPE => X_CATEGORY_TYPE,
            X_CATEGORY_NAME => X_CATEGORY_NAME,
            X_NAME => X_NAME,
            X_DESCRIPTION => X_DESCRIPTION,
            X_STATUS => X_STATUS,
    		X_Creation_Date => sysdate,
    		X_Created_By => l_user_id,
    		X_Last_Update_Date => sysdate,
    		X_Last_Updated_By => l_user_id,
    		X_Last_Update_Login => 0);

end LOAD_ROW;


end CS_FORUM_CATEGORIES_PKG;

/

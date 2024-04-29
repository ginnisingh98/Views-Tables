--------------------------------------------------------
--  DDL for Package Body PFT_VAL_INDEX_FORMULA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PFT_VAL_INDEX_FORMULA_PKG" as
/* $Header: PFTVALINDFB.pls 120.0 2005/10/19 19:16:12 appldev noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_VALUE_INDEX_FORMULA_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PFT_VAL_INDEX_FORMULA_B
    where VALUE_INDEX_FORMULA_ID = X_VALUE_INDEX_FORMULA_ID
    ;
begin
  insert into PFT_VAL_INDEX_FORMULA_B (
    VALUE_INDEX_FORMULA_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_VALUE_INDEX_FORMULA_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into PFT_VAL_INDEX_FORMULA_TL (
    VALUE_INDEX_FORMULA_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_VALUE_INDEX_FORMULA_ID,
    X_DISPLAY_NAME,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PFT_VAL_INDEX_FORMULA_TL T
    where T.VALUE_INDEX_FORMULA_ID = X_VALUE_INDEX_FORMULA_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_VALUE_INDEX_FORMULA_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER
    from PFT_VAL_INDEX_FORMULA_B
    where VALUE_INDEX_FORMULA_ID = X_VALUE_INDEX_FORMULA_ID
    for update of VALUE_INDEX_FORMULA_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PFT_VAL_INDEX_FORMULA_TL
    where VALUE_INDEX_FORMULA_ID = X_VALUE_INDEX_FORMULA_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of VALUE_INDEX_FORMULA_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
          AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_VALUE_INDEX_FORMULA_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PFT_VAL_INDEX_FORMULA_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where VALUE_INDEX_FORMULA_ID = X_VALUE_INDEX_FORMULA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PFT_VAL_INDEX_FORMULA_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where VALUE_INDEX_FORMULA_ID = X_VALUE_INDEX_FORMULA_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_VALUE_INDEX_FORMULA_ID in NUMBER
) is
begin
  delete from PFT_VAL_INDEX_FORMULA_TL
  where VALUE_INDEX_FORMULA_ID = X_VALUE_INDEX_FORMULA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PFT_VAL_INDEX_FORMULA_B
  where VALUE_INDEX_FORMULA_ID = X_VALUE_INDEX_FORMULA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from PFT_VAL_INDEX_FORMULA_TL T
  where not exists
    (select NULL
    from PFT_VAL_INDEX_FORMULA_B B
    where B.VALUE_INDEX_FORMULA_ID = T.VALUE_INDEX_FORMULA_ID
    );

  update PFT_VAL_INDEX_FORMULA_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from PFT_VAL_INDEX_FORMULA_TL B
    where B.VALUE_INDEX_FORMULA_ID = T.VALUE_INDEX_FORMULA_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.VALUE_INDEX_FORMULA_ID,
      T.LANGUAGE
  ) in (select
      SUBT.VALUE_INDEX_FORMULA_ID,
      SUBT.LANGUAGE
    from PFT_VAL_INDEX_FORMULA_TL SUBB, PFT_VAL_INDEX_FORMULA_TL SUBT
    where SUBB.VALUE_INDEX_FORMULA_ID = SUBT.VALUE_INDEX_FORMULA_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into PFT_VAL_INDEX_FORMULA_TL (
    VALUE_INDEX_FORMULA_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.VALUE_INDEX_FORMULA_ID,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PFT_VAL_INDEX_FORMULA_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PFT_VAL_INDEX_FORMULA_TL T
    where T.VALUE_INDEX_FORMULA_ID = B.VALUE_INDEX_FORMULA_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end PFT_VAL_INDEX_FORMULA_PKG;

/

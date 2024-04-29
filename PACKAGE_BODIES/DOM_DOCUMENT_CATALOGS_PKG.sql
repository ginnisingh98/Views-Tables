--------------------------------------------------------
--  DDL for Package Body DOM_DOCUMENT_CATALOGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DOM_DOCUMENT_CATALOGS_PKG" as
/* $Header: DOMCATB.pls 120.0 2006/02/23 02:12:07 ysireesh noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CATALOG_ID in NUMBER,
  X_INTERNAL_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from DOM_DOCUMENT_CATALOGS
    where CATALOG_ID = X_CATALOG_ID
    ;
begin
  insert into DOM_DOCUMENT_CATALOGS (
    CATALOG_ID,
    INTERNAL_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_CATALOG_ID,
    X_INTERNAL_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into DOM_DOCUMENT_CATALOGS_TL (
    CATALOG_ID,
    INTERNAL_NAME,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CATALOG_ID,
    X_INTERNAL_NAME,
    X_NAME,
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
    from DOM_DOCUMENT_CATALOGS_TL T
    where T.CATALOG_ID = X_CATALOG_ID
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
  X_CATALOG_ID in NUMBER,
  X_INTERNAL_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      INTERNAL_NAME
    from DOM_DOCUMENT_CATALOGS
    where CATALOG_ID = X_CATALOG_ID
    for update of CATALOG_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from DOM_DOCUMENT_CATALOGS_TL
    where CATALOG_ID = X_CATALOG_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CATALOG_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.INTERNAL_NAME = X_INTERNAL_NAME)
           OR ((recinfo.INTERNAL_NAME is null) AND (X_INTERNAL_NAME is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.NAME = X_NAME)
               OR ((tlinfo.NAME is null) AND (X_NAME is null)))
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
  X_CATALOG_ID in NUMBER,
  X_INTERNAL_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update DOM_DOCUMENT_CATALOGS set
    INTERNAL_NAME = X_INTERNAL_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CATALOG_ID = X_CATALOG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update DOM_DOCUMENT_CATALOGS_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CATALOG_ID = X_CATALOG_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CATALOG_ID in NUMBER
) is
begin
  delete from DOM_DOCUMENT_CATALOGS_TL
  where CATALOG_ID = X_CATALOG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from DOM_DOCUMENT_CATALOGS
  where CATALOG_ID = X_CATALOG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from DOM_DOCUMENT_CATALOGS_TL T
  where not exists
    (select NULL
    from DOM_DOCUMENT_CATALOGS B
    where B.CATALOG_ID = T.CATALOG_ID
    );

  update DOM_DOCUMENT_CATALOGS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from DOM_DOCUMENT_CATALOGS_TL B
    where B.CATALOG_ID = T.CATALOG_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CATALOG_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CATALOG_ID,
      SUBT.LANGUAGE
    from DOM_DOCUMENT_CATALOGS_TL SUBB, DOM_DOCUMENT_CATALOGS_TL SUBT
    where SUBB.CATALOG_ID = SUBT.CATALOG_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into DOM_DOCUMENT_CATALOGS_TL (
    CATALOG_ID,
    INTERNAL_NAME,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CATALOG_ID,
    B.INTERNAL_NAME,
    B.NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from DOM_DOCUMENT_CATALOGS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from DOM_DOCUMENT_CATALOGS_TL T
    where T.CATALOG_ID = B.CATALOG_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end DOM_DOCUMENT_CATALOGS_PKG;

/

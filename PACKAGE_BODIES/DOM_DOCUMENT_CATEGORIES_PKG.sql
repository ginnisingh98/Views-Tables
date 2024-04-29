--------------------------------------------------------
--  DDL for Package Body DOM_DOCUMENT_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DOM_DOCUMENT_CATEGORIES_PKG" as
/* $Header: DOMCATGB.pls 120.0 2006/02/23 02:35 rkhasa noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CATALOG_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_PARENT_CATEGORY_ID in NUMBER,
  X_DOC_CREATION_ALLOWED in VARCHAR2,
  X_INACTIVE_ON in DATE,
  X_DEFAULT_FOLDER_OPTION in VARCHAR2,
  X_DEFAULT_REPOSITORY_ID in NUMBER,
  X_DEFAULT_FOLDER_LOCATION in VARCHAR2,
  X_DEF_FOLDER_NAMING_METHOD in VARCHAR2,
  X_DEF_FOLDER_PREFIX in VARCHAR2,
  X_DEF_FOLDER_SUFFIX in VARCHAR2,
  X_DOC_NUM_SCHEME in VARCHAR2,
  X_DOC_NUM_PREFIX in VARCHAR2,
  X_DOC_NUM_START_NUMBER in NUMBER,
  X_DOC_NUM_INCR in NUMBER,
  X_DOC_NUM_SUFFIX in VARCHAR2,
  X_DOC_NUM_FUNC_ACTION_ID in NUMBER,
  X_DOC_REV_SCHEME in VARCHAR2,
  X_DOC_REV_SEEDED_SEQ_CODE in VARCHAR2,
  X_DOC_REV_PREFIX in VARCHAR2,
  X_DOC_REV_START_NUMBER in NUMBER,
  X_DOC_REV_INCR in NUMBER,
  X_DOC_REV_SUFFIX in VARCHAR2,
  X_DOC_REV_FUNC_ACTION_ID in NUMBER,
  X_DOC_NAME_SCHEME in VARCHAR2,
  X_DOC_NAME_FUNC_ACTION_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from DOM_DOCUMENT_CATEGORIES
    where CATALOG_ID = X_CATALOG_ID
    and CATEGORY_ID = X_CATEGORY_ID
    ;
begin
  insert into DOM_DOCUMENT_CATEGORIES (
    CATALOG_ID,
    CATEGORY_ID,
    PARENT_CATEGORY_ID,
    DOC_CREATION_ALLOWED,
    INACTIVE_ON,
    DEFAULT_FOLDER_OPTION,
    DEFAULT_REPOSITORY_ID,
    DEFAULT_FOLDER_LOCATION,
    DEF_FOLDER_NAMING_METHOD,
    DEF_FOLDER_PREFIX,
    DEF_FOLDER_SUFFIX,
    DOC_NUM_SCHEME,
    DOC_NUM_PREFIX,
    DOC_NUM_START_NUMBER,
    DOC_NUM_INCR,
    DOC_NUM_SUFFIX,
    DOC_NUM_FUNC_ACTION_ID,
    DOC_REV_SCHEME,
    DOC_REV_SEEDED_SEQ_CODE,
    DOC_REV_PREFIX,
    DOC_REV_START_NUMBER,
    DOC_REV_INCR,
    DOC_REV_SUFFIX,
    DOC_REV_FUNC_ACTION_ID,
    DOC_NAME_SCHEME,
    DOC_NAME_FUNC_ACTION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_CATALOG_ID,
    X_CATEGORY_ID,
    X_PARENT_CATEGORY_ID,
    X_DOC_CREATION_ALLOWED,
    X_INACTIVE_ON,
    X_DEFAULT_FOLDER_OPTION,
    X_DEFAULT_REPOSITORY_ID,
    X_DEFAULT_FOLDER_LOCATION,
    X_DEF_FOLDER_NAMING_METHOD,
    X_DEF_FOLDER_PREFIX,
    X_DEF_FOLDER_SUFFIX,
    X_DOC_NUM_SCHEME,
    X_DOC_NUM_PREFIX,
    X_DOC_NUM_START_NUMBER,
    X_DOC_NUM_INCR,
    X_DOC_NUM_SUFFIX,
    X_DOC_NUM_FUNC_ACTION_ID,
    X_DOC_REV_SCHEME,
    X_DOC_REV_SEEDED_SEQ_CODE,
    X_DOC_REV_PREFIX,
    X_DOC_REV_START_NUMBER,
    X_DOC_REV_INCR,
    X_DOC_REV_SUFFIX,
    X_DOC_REV_FUNC_ACTION_ID,
    X_DOC_NAME_SCHEME,
    X_DOC_NAME_FUNC_ACTION_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into DOM_DOCUMENT_CATEGORIES_TL (
    LAST_UPDATE_LOGIN,
    CATALOG_ID,
    CATEGORY_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_LOGIN,
    X_CATALOG_ID,
    X_CATEGORY_ID,
    X_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from DOM_DOCUMENT_CATEGORIES_TL T
    where T.CATALOG_ID = X_CATALOG_ID
    and T.CATEGORY_ID = X_CATEGORY_ID
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
  X_CATEGORY_ID in NUMBER,
  X_PARENT_CATEGORY_ID in NUMBER,
  X_DOC_CREATION_ALLOWED in VARCHAR2,
  X_INACTIVE_ON in DATE,
  X_DEFAULT_FOLDER_OPTION in VARCHAR2,
  X_DEFAULT_REPOSITORY_ID in NUMBER,
  X_DEFAULT_FOLDER_LOCATION in VARCHAR2,
  X_DEF_FOLDER_NAMING_METHOD in VARCHAR2,
  X_DEF_FOLDER_PREFIX in VARCHAR2,
  X_DEF_FOLDER_SUFFIX in VARCHAR2,
  X_DOC_NUM_SCHEME in VARCHAR2,
  X_DOC_NUM_PREFIX in VARCHAR2,
  X_DOC_NUM_START_NUMBER in NUMBER,
  X_DOC_NUM_INCR in NUMBER,
  X_DOC_NUM_SUFFIX in VARCHAR2,
  X_DOC_NUM_FUNC_ACTION_ID in NUMBER,
  X_DOC_REV_SCHEME in VARCHAR2,
  X_DOC_REV_SEEDED_SEQ_CODE in VARCHAR2,
  X_DOC_REV_PREFIX in VARCHAR2,
  X_DOC_REV_START_NUMBER in NUMBER,
  X_DOC_REV_INCR in NUMBER,
  X_DOC_REV_SUFFIX in VARCHAR2,
  X_DOC_REV_FUNC_ACTION_ID in NUMBER,
  X_DOC_NAME_SCHEME in VARCHAR2,
  X_DOC_NAME_FUNC_ACTION_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      PARENT_CATEGORY_ID,
      DOC_CREATION_ALLOWED,
      INACTIVE_ON,
      DEFAULT_FOLDER_OPTION,
      DEFAULT_REPOSITORY_ID,
      DEFAULT_FOLDER_LOCATION,
      DEF_FOLDER_NAMING_METHOD,
      DEF_FOLDER_PREFIX,
      DEF_FOLDER_SUFFIX,
      DOC_NUM_SCHEME,
      DOC_NUM_PREFIX,
      DOC_NUM_START_NUMBER,
      DOC_NUM_INCR,
      DOC_NUM_SUFFIX,
      DOC_NUM_FUNC_ACTION_ID,
      DOC_REV_SCHEME,
      DOC_REV_SEEDED_SEQ_CODE,
      DOC_REV_PREFIX,
      DOC_REV_START_NUMBER,
      DOC_REV_INCR,
      DOC_REV_SUFFIX,
      DOC_REV_FUNC_ACTION_ID,
      DOC_NAME_SCHEME,
      DOC_NAME_FUNC_ACTION_ID
    from DOM_DOCUMENT_CATEGORIES
    where CATALOG_ID = X_CATALOG_ID
    and CATEGORY_ID = X_CATEGORY_ID
    for update of CATALOG_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from DOM_DOCUMENT_CATEGORIES_TL
    where CATALOG_ID = X_CATALOG_ID
    and CATEGORY_ID = X_CATEGORY_ID
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
  if (    ((recinfo.PARENT_CATEGORY_ID = X_PARENT_CATEGORY_ID)
           OR ((recinfo.PARENT_CATEGORY_ID is null) AND (X_PARENT_CATEGORY_ID is null)))
      AND ((recinfo.DOC_CREATION_ALLOWED = X_DOC_CREATION_ALLOWED)
           OR ((recinfo.DOC_CREATION_ALLOWED is null) AND (X_DOC_CREATION_ALLOWED is null)))
      AND ((recinfo.INACTIVE_ON = X_INACTIVE_ON)
           OR ((recinfo.INACTIVE_ON is null) AND (X_INACTIVE_ON is null)))
      AND ((recinfo.DEFAULT_FOLDER_OPTION = X_DEFAULT_FOLDER_OPTION)
           OR ((recinfo.DEFAULT_FOLDER_OPTION is null) AND (X_DEFAULT_FOLDER_OPTION is null)))
      AND ((recinfo.DEFAULT_REPOSITORY_ID = X_DEFAULT_REPOSITORY_ID)
           OR ((recinfo.DEFAULT_REPOSITORY_ID is null) AND (X_DEFAULT_REPOSITORY_ID is null)))
      AND ((recinfo.DEFAULT_FOLDER_LOCATION = X_DEFAULT_FOLDER_LOCATION)
           OR ((recinfo.DEFAULT_FOLDER_LOCATION is null) AND (X_DEFAULT_FOLDER_LOCATION is null)))
      AND ((recinfo.DEF_FOLDER_NAMING_METHOD = X_DEF_FOLDER_NAMING_METHOD)
           OR ((recinfo.DEF_FOLDER_NAMING_METHOD is null) AND (X_DEF_FOLDER_NAMING_METHOD is null)))
      AND ((recinfo.DEF_FOLDER_PREFIX = X_DEF_FOLDER_PREFIX)
           OR ((recinfo.DEF_FOLDER_PREFIX is null) AND (X_DEF_FOLDER_PREFIX is null)))
      AND ((recinfo.DEF_FOLDER_SUFFIX = X_DEF_FOLDER_SUFFIX)
           OR ((recinfo.DEF_FOLDER_SUFFIX is null) AND (X_DEF_FOLDER_SUFFIX is null)))
      AND ((recinfo.DOC_NUM_SCHEME = X_DOC_NUM_SCHEME)
           OR ((recinfo.DOC_NUM_SCHEME is null) AND (X_DOC_NUM_SCHEME is null)))
      AND ((recinfo.DOC_NUM_PREFIX = X_DOC_NUM_PREFIX)
           OR ((recinfo.DOC_NUM_PREFIX is null) AND (X_DOC_NUM_PREFIX is null)))
      AND ((recinfo.DOC_NUM_START_NUMBER = X_DOC_NUM_START_NUMBER)
           OR ((recinfo.DOC_NUM_START_NUMBER is null) AND (X_DOC_NUM_START_NUMBER is null)))
      AND ((recinfo.DOC_NUM_INCR = X_DOC_NUM_INCR)
           OR ((recinfo.DOC_NUM_INCR is null) AND (X_DOC_NUM_INCR is null)))
      AND ((recinfo.DOC_NUM_SUFFIX = X_DOC_NUM_SUFFIX)
           OR ((recinfo.DOC_NUM_SUFFIX is null) AND (X_DOC_NUM_SUFFIX is null)))
      AND ((recinfo.DOC_NUM_FUNC_ACTION_ID = X_DOC_NUM_FUNC_ACTION_ID)
           OR ((recinfo.DOC_NUM_FUNC_ACTION_ID is null) AND (X_DOC_NUM_FUNC_ACTION_ID is null)))
      AND ((recinfo.DOC_REV_SCHEME = X_DOC_REV_SCHEME)
           OR ((recinfo.DOC_REV_SCHEME is null) AND (X_DOC_REV_SCHEME is null)))
      AND ((recinfo.DOC_REV_SEEDED_SEQ_CODE = X_DOC_REV_SEEDED_SEQ_CODE)
           OR ((recinfo.DOC_REV_SEEDED_SEQ_CODE is null) AND (X_DOC_REV_SEEDED_SEQ_CODE is null)))
      AND ((recinfo.DOC_REV_PREFIX = X_DOC_REV_PREFIX)
           OR ((recinfo.DOC_REV_PREFIX is null) AND (X_DOC_REV_PREFIX is null)))
      AND ((recinfo.DOC_REV_START_NUMBER = X_DOC_REV_START_NUMBER)
           OR ((recinfo.DOC_REV_START_NUMBER is null) AND (X_DOC_REV_START_NUMBER is null)))
      AND ((recinfo.DOC_REV_INCR = X_DOC_REV_INCR)
           OR ((recinfo.DOC_REV_INCR is null) AND (X_DOC_REV_INCR is null)))
      AND ((recinfo.DOC_REV_SUFFIX = X_DOC_REV_SUFFIX)
           OR ((recinfo.DOC_REV_SUFFIX is null) AND (X_DOC_REV_SUFFIX is null)))
      AND ((recinfo.DOC_REV_FUNC_ACTION_ID = X_DOC_REV_FUNC_ACTION_ID)
           OR ((recinfo.DOC_REV_FUNC_ACTION_ID is null) AND (X_DOC_REV_FUNC_ACTION_ID is null)))
      AND ((recinfo.DOC_NAME_SCHEME = X_DOC_NAME_SCHEME)
           OR ((recinfo.DOC_NAME_SCHEME is null) AND (X_DOC_NAME_SCHEME is null)))
      AND ((recinfo.DOC_NAME_FUNC_ACTION_ID = X_DOC_NAME_FUNC_ACTION_ID)
           OR ((recinfo.DOC_NAME_FUNC_ACTION_ID is null) AND (X_DOC_NAME_FUNC_ACTION_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
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
  X_CATEGORY_ID in NUMBER,
  X_PARENT_CATEGORY_ID in NUMBER,
  X_DOC_CREATION_ALLOWED in VARCHAR2,
  X_INACTIVE_ON in DATE,
  X_DEFAULT_FOLDER_OPTION in VARCHAR2,
  X_DEFAULT_REPOSITORY_ID in NUMBER,
  X_DEFAULT_FOLDER_LOCATION in VARCHAR2,
  X_DEF_FOLDER_NAMING_METHOD in VARCHAR2,
  X_DEF_FOLDER_PREFIX in VARCHAR2,
  X_DEF_FOLDER_SUFFIX in VARCHAR2,
  X_DOC_NUM_SCHEME in VARCHAR2,
  X_DOC_NUM_PREFIX in VARCHAR2,
  X_DOC_NUM_START_NUMBER in NUMBER,
  X_DOC_NUM_INCR in NUMBER,
  X_DOC_NUM_SUFFIX in VARCHAR2,
  X_DOC_NUM_FUNC_ACTION_ID in NUMBER,
  X_DOC_REV_SCHEME in VARCHAR2,
  X_DOC_REV_SEEDED_SEQ_CODE in VARCHAR2,
  X_DOC_REV_PREFIX in VARCHAR2,
  X_DOC_REV_START_NUMBER in NUMBER,
  X_DOC_REV_INCR in NUMBER,
  X_DOC_REV_SUFFIX in VARCHAR2,
  X_DOC_REV_FUNC_ACTION_ID in NUMBER,
  X_DOC_NAME_SCHEME in VARCHAR2,
  X_DOC_NAME_FUNC_ACTION_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update DOM_DOCUMENT_CATEGORIES set
    PARENT_CATEGORY_ID = X_PARENT_CATEGORY_ID,
    DOC_CREATION_ALLOWED = X_DOC_CREATION_ALLOWED,
    INACTIVE_ON = X_INACTIVE_ON,
    DEFAULT_FOLDER_OPTION = X_DEFAULT_FOLDER_OPTION,
    DEFAULT_REPOSITORY_ID = X_DEFAULT_REPOSITORY_ID,
    DEFAULT_FOLDER_LOCATION = X_DEFAULT_FOLDER_LOCATION,
    DEF_FOLDER_NAMING_METHOD = X_DEF_FOLDER_NAMING_METHOD,
    DEF_FOLDER_PREFIX = X_DEF_FOLDER_PREFIX,
    DEF_FOLDER_SUFFIX = X_DEF_FOLDER_SUFFIX,
    DOC_NUM_SCHEME = X_DOC_NUM_SCHEME,
    DOC_NUM_PREFIX = X_DOC_NUM_PREFIX,
    DOC_NUM_START_NUMBER = X_DOC_NUM_START_NUMBER,
    DOC_NUM_INCR = X_DOC_NUM_INCR,
    DOC_NUM_SUFFIX = X_DOC_NUM_SUFFIX,
    DOC_NUM_FUNC_ACTION_ID = X_DOC_NUM_FUNC_ACTION_ID,
    DOC_REV_SCHEME = X_DOC_REV_SCHEME,
    DOC_REV_SEEDED_SEQ_CODE = X_DOC_REV_SEEDED_SEQ_CODE,
    DOC_REV_PREFIX = X_DOC_REV_PREFIX,
    DOC_REV_START_NUMBER = X_DOC_REV_START_NUMBER,
    DOC_REV_INCR = X_DOC_REV_INCR,
    DOC_REV_SUFFIX = X_DOC_REV_SUFFIX,
    DOC_REV_FUNC_ACTION_ID = X_DOC_REV_FUNC_ACTION_ID,
    DOC_NAME_SCHEME = X_DOC_NAME_SCHEME,
    DOC_NAME_FUNC_ACTION_ID = X_DOC_NAME_FUNC_ACTION_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CATALOG_ID = X_CATALOG_ID
  and CATEGORY_ID = X_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update DOM_DOCUMENT_CATEGORIES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CATALOG_ID = X_CATALOG_ID
  and CATEGORY_ID = X_CATEGORY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CATALOG_ID in NUMBER,
  X_CATEGORY_ID in NUMBER
) is
begin
  delete from DOM_DOCUMENT_CATEGORIES_TL
  where CATALOG_ID = X_CATALOG_ID
  and CATEGORY_ID = X_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from DOM_DOCUMENT_CATEGORIES
  where CATALOG_ID = X_CATALOG_ID
  and CATEGORY_ID = X_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from DOM_DOCUMENT_CATEGORIES_TL T
  where not exists
    (select NULL
    from DOM_DOCUMENT_CATEGORIES B
    where B.CATALOG_ID = T.CATALOG_ID
    and B.CATEGORY_ID = T.CATEGORY_ID
    );

  update DOM_DOCUMENT_CATEGORIES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from DOM_DOCUMENT_CATEGORIES_TL B
    where B.CATALOG_ID = T.CATALOG_ID
    and B.CATEGORY_ID = T.CATEGORY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CATALOG_ID,
      T.CATEGORY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CATALOG_ID,
      SUBT.CATEGORY_ID,
      SUBT.LANGUAGE
    from DOM_DOCUMENT_CATEGORIES_TL SUBB, DOM_DOCUMENT_CATEGORIES_TL SUBT
    where SUBB.CATALOG_ID = SUBT.CATALOG_ID
    and SUBB.CATEGORY_ID = SUBT.CATEGORY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into DOM_DOCUMENT_CATEGORIES_TL (
    LAST_UPDATE_LOGIN,
    CATALOG_ID,
    CATEGORY_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.LAST_UPDATE_LOGIN,
    B.CATALOG_ID,
    B.CATEGORY_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from DOM_DOCUMENT_CATEGORIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from DOM_DOCUMENT_CATEGORIES_TL T
    where T.CATALOG_ID = B.CATALOG_ID
    and T.CATEGORY_ID = B.CATEGORY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end DOM_DOCUMENT_CATEGORIES_PKG;

/
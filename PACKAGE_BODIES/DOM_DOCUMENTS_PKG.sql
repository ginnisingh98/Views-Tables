--------------------------------------------------------
--  DDL for Package Body DOM_DOCUMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DOM_DOCUMENTS_PKG" as
/* $Header: DOMDOCB.pls 120.1 2006/03/22 03:43:32 ysireesh noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_DOCUMENT_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_DOC_NUMBER in VARCHAR2,
  X_DEF_REP_ID in NUMBER,
  X_DEF_FOLDER_ID in NUMBER,
  X_LOCK_STATUS in VARCHAR2,
  X_LOCKED_BY in NUMBER,
  X_LIFECYCLE_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from DOM_DOCUMENTS
    where DOCUMENT_ID = X_DOCUMENT_ID
    ;
begin
  insert into DOM_DOCUMENTS (
    DOCUMENT_ID,
    CATEGORY_ID,
    DOC_NUMBER,
    DEF_REP_ID,
    DEF_FOLDER_ID,
    LOCK_STATUS,
    LOCKED_BY,
    LIFECYCLE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_DOCUMENT_ID,
    X_CATEGORY_ID,
    X_DOC_NUMBER,
    X_DEF_REP_ID,
    X_DEF_FOLDER_ID,
    X_LOCK_STATUS,
    X_LOCKED_BY,
    X_LIFECYCLE_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into DOM_DOCUMENTS_TL (
    DOCUMENT_ID,
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
    X_DOCUMENT_ID,
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
    from DOM_DOCUMENTS_TL T
    where T.DOCUMENT_ID = X_DOCUMENT_ID
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
  X_DOCUMENT_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_DOC_NUMBER in VARCHAR2,
  X_DEF_REP_ID in NUMBER,
  X_DEF_FOLDER_ID in NUMBER,
  X_LOCK_STATUS in VARCHAR2,
  X_LOCKED_BY in NUMBER,
  X_LIFECYCLE_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      CATEGORY_ID,
      DOC_NUMBER,
      DEF_REP_ID,
      DEF_FOLDER_ID,
      LOCK_STATUS,
      LOCKED_BY,
      LIFECYCLE_ID
    from DOM_DOCUMENTS
    where DOCUMENT_ID = X_DOCUMENT_ID
    for update of DOCUMENT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from DOM_DOCUMENTS_TL
    where DOCUMENT_ID = X_DOCUMENT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DOCUMENT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.CATEGORY_ID = X_CATEGORY_ID)
      AND (recinfo.DOC_NUMBER = X_DOC_NUMBER)
      AND ((recinfo.DEF_REP_ID = X_DEF_REP_ID)
           OR ((recinfo.DEF_REP_ID is null) AND (X_DEF_REP_ID is null)))
      AND ((recinfo.DEF_FOLDER_ID = X_DEF_FOLDER_ID)
           OR ((recinfo.DEF_FOLDER_ID is null) AND (X_DEF_FOLDER_ID is null)))
      AND ((recinfo.LOCK_STATUS = X_LOCK_STATUS)
           OR ((recinfo.LOCK_STATUS is null) AND (X_LOCK_STATUS is null)))
      AND ((recinfo.LOCKED_BY = X_LOCKED_BY)
           OR ((recinfo.LOCKED_BY is null) AND (X_LOCKED_BY is null)))
      AND ((recinfo.LIFECYCLE_ID = X_LIFECYCLE_ID)
           OR ((recinfo.LIFECYCLE_ID is null) AND (X_LIFECYCLE_ID is null)))
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
  X_DOCUMENT_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_DOC_NUMBER in VARCHAR2,
  X_DEF_REP_ID in NUMBER,
  X_DEF_FOLDER_ID in NUMBER,
  X_LOCK_STATUS in VARCHAR2,
  X_LOCKED_BY in NUMBER,
  X_LIFECYCLE_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update DOM_DOCUMENTS set
    CATEGORY_ID = X_CATEGORY_ID,
    DOC_NUMBER = X_DOC_NUMBER,
    DEF_REP_ID = X_DEF_REP_ID,
    DEF_FOLDER_ID = X_DEF_FOLDER_ID,
    LOCK_STATUS = X_LOCK_STATUS,
    LOCKED_BY = X_LOCKED_BY,
    LIFECYCLE_ID = X_LIFECYCLE_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DOCUMENT_ID = X_DOCUMENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update DOM_DOCUMENTS_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DOCUMENT_ID = X_DOCUMENT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DOCUMENT_ID in NUMBER
) is
begin
  delete from DOM_DOCUMENTS_TL
  where DOCUMENT_ID = X_DOCUMENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from DOM_DOCUMENTS
  where DOCUMENT_ID = X_DOCUMENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from DOM_DOCUMENTS_TL T
  where not exists
    (select NULL
    from DOM_DOCUMENTS B
    where B.DOCUMENT_ID = T.DOCUMENT_ID
    );

  update DOM_DOCUMENTS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from DOM_DOCUMENTS_TL B
    where B.DOCUMENT_ID = T.DOCUMENT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DOCUMENT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DOCUMENT_ID,
      SUBT.LANGUAGE
    from DOM_DOCUMENTS_TL SUBB, DOM_DOCUMENTS_TL SUBT
    where SUBB.DOCUMENT_ID = SUBT.DOCUMENT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into DOM_DOCUMENTS_TL (
    DOCUMENT_ID,
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
    B.DOCUMENT_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from DOM_DOCUMENTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from DOM_DOCUMENTS_TL T
    where T.DOCUMENT_ID = B.DOCUMENT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end DOM_DOCUMENTS_PKG;

/

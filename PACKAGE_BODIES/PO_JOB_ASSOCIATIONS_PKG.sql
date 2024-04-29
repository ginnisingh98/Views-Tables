--------------------------------------------------------
--  DDL for Package Body PO_JOB_ASSOCIATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_JOB_ASSOCIATIONS_PKG" AS
/* $Header: POXTIJAB.pls 115.0 2003/09/08 19:58:25 tpoon noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_JOB_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_INACTIVE_DATE in DATE,
  X_JOB_DESCRIPTION in VARCHAR2,
  X_JOB_LONG_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PO_JOB_ASSOCIATIONS_B
    where JOB_ID = X_JOB_ID
    ;
begin
  insert into PO_JOB_ASSOCIATIONS_B (
    JOB_ID,
    CATEGORY_ID,
    INACTIVE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_JOB_ID,
    X_CATEGORY_ID,
    X_INACTIVE_DATE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into PO_JOB_ASSOCIATIONS_TL (
    JOB_ID,
    JOB_DESCRIPTION,
    JOB_LONG_DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_JOB_ID,
    X_JOB_DESCRIPTION,
    X_JOB_LONG_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PO_JOB_ASSOCIATIONS_TL T
    where T.JOB_ID = X_JOB_ID
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
  X_JOB_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_INACTIVE_DATE in DATE,
  X_JOB_DESCRIPTION in VARCHAR2,
  X_JOB_LONG_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      CATEGORY_ID,
      INACTIVE_DATE
    from PO_JOB_ASSOCIATIONS_B
    where JOB_ID = X_JOB_ID
    for update of JOB_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      JOB_DESCRIPTION,
      JOB_LONG_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PO_JOB_ASSOCIATIONS_TL
    where JOB_ID = X_JOB_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of JOB_ID nowait;
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
      AND ((recinfo.INACTIVE_DATE = X_INACTIVE_DATE)
           OR ((recinfo.INACTIVE_DATE is null) AND (X_INACTIVE_DATE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.JOB_DESCRIPTION = X_JOB_DESCRIPTION)
          AND ((tlinfo.JOB_LONG_DESCRIPTION = X_JOB_LONG_DESCRIPTION)
               OR ((tlinfo.JOB_LONG_DESCRIPTION is null) AND (X_JOB_LONG_DESCRIPTION is null)))
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
  X_JOB_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_INACTIVE_DATE in DATE,
  X_JOB_DESCRIPTION in VARCHAR2,
  X_JOB_LONG_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PO_JOB_ASSOCIATIONS_B set
    CATEGORY_ID = X_CATEGORY_ID,
    INACTIVE_DATE = X_INACTIVE_DATE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where JOB_ID = X_JOB_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PO_JOB_ASSOCIATIONS_TL set
    JOB_DESCRIPTION = X_JOB_DESCRIPTION,
    JOB_LONG_DESCRIPTION = X_JOB_LONG_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where JOB_ID = X_JOB_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_JOB_ID in NUMBER
) is
begin
  delete from PO_JOB_ASSOCIATIONS_TL
  where JOB_ID = X_JOB_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PO_JOB_ASSOCIATIONS_B
  where JOB_ID = X_JOB_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from PO_JOB_ASSOCIATIONS_TL T
  where not exists
    (select NULL
    from PO_JOB_ASSOCIATIONS_B B
    where B.JOB_ID = T.JOB_ID
    );

  insert into PO_JOB_ASSOCIATIONS_TL (
    JOB_ID,
    JOB_DESCRIPTION,
    JOB_LONG_DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.JOB_ID,
    B.JOB_DESCRIPTION,
    B.JOB_LONG_DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PO_JOB_ASSOCIATIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PO_JOB_ASSOCIATIONS_TL T
    where T.JOB_ID = B.JOB_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end PO_JOB_ASSOCIATIONS_PKG;

/

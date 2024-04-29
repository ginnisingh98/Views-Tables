--------------------------------------------------------
--  DDL for Package Body OKC_DELIVERABLE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_DELIVERABLE_TYPES_PKG" as
/* $Header: OKCDELTYPESB.pls 120.0 2005/10/06 16:00:15 amakalin noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_DELIVERABLE_TYPE_CODE in VARCHAR2,
  X_INTERNAL_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from OKC_DELIVERABLE_TYPES_B
    where DELIVERABLE_TYPE_CODE = X_DELIVERABLE_TYPE_CODE
    ;
begin
  insert into OKC_DELIVERABLE_TYPES_B (
    DELIVERABLE_TYPE_CODE,
    INTERNAL_FLAG,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_DELIVERABLE_TYPE_CODE,
    X_INTERNAL_FLAG,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into OKC_DELIVERABLE_TYPES_TL (
    DELIVERABLE_TYPE_CODE,
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
    X_DELIVERABLE_TYPE_CODE,
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
    from OKC_DELIVERABLE_TYPES_TL T
    where T.DELIVERABLE_TYPE_CODE = X_DELIVERABLE_TYPE_CODE
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
  X_DELIVERABLE_TYPE_CODE in VARCHAR2,
  X_INTERNAL_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      INTERNAL_FLAG,
      OBJECT_VERSION_NUMBER
    from OKC_DELIVERABLE_TYPES_B
    where DELIVERABLE_TYPE_CODE = X_DELIVERABLE_TYPE_CODE
    for update of DELIVERABLE_TYPE_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from OKC_DELIVERABLE_TYPES_TL
    where DELIVERABLE_TYPE_CODE = X_DELIVERABLE_TYPE_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DELIVERABLE_TYPE_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.INTERNAL_FLAG = X_INTERNAL_FLAG)
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
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
  X_DELIVERABLE_TYPE_CODE in VARCHAR2,
  X_INTERNAL_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update OKC_DELIVERABLE_TYPES_B set
    INTERNAL_FLAG = X_INTERNAL_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DELIVERABLE_TYPE_CODE = X_DELIVERABLE_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update OKC_DELIVERABLE_TYPES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DELIVERABLE_TYPE_CODE = X_DELIVERABLE_TYPE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DELIVERABLE_TYPE_CODE in VARCHAR2
) is
begin
  delete from OKC_DELIVERABLE_TYPES_TL
  where DELIVERABLE_TYPE_CODE = X_DELIVERABLE_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from OKC_DELIVERABLE_TYPES_B
  where DELIVERABLE_TYPE_CODE = X_DELIVERABLE_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from OKC_DELIVERABLE_TYPES_TL T
  where not exists
    (select NULL
    from OKC_DELIVERABLE_TYPES_B B
    where B.DELIVERABLE_TYPE_CODE = T.DELIVERABLE_TYPE_CODE
    );

  update OKC_DELIVERABLE_TYPES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from OKC_DELIVERABLE_TYPES_TL B
    where B.DELIVERABLE_TYPE_CODE = T.DELIVERABLE_TYPE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DELIVERABLE_TYPE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.DELIVERABLE_TYPE_CODE,
      SUBT.LANGUAGE
    from OKC_DELIVERABLE_TYPES_TL SUBB, OKC_DELIVERABLE_TYPES_TL SUBT
    where SUBB.DELIVERABLE_TYPE_CODE = SUBT.DELIVERABLE_TYPE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into OKC_DELIVERABLE_TYPES_TL (
    DELIVERABLE_TYPE_CODE,
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
    B.DELIVERABLE_TYPE_CODE,
    B.NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from OKC_DELIVERABLE_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from OKC_DELIVERABLE_TYPES_TL T
    where T.DELIVERABLE_TYPE_CODE = B.DELIVERABLE_TYPE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end OKC_DELIVERABLE_TYPES_PKG;

/

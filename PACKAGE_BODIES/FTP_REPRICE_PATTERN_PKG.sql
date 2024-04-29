--------------------------------------------------------
--  DDL for Package Body FTP_REPRICE_PATTERN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTP_REPRICE_PATTERN_PKG" as
/* $Header: ftpreptb.pls 120.1 2005/12/02 13:51:52 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_REPRICE_ID in NUMBER,
  X_ADJUSTABLE_TYPE_CODE in NUMBER,
  X_PATTERN_TYPE_CODE in NUMBER,
  X_PATTERN_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FTP_REPRICE_PATTERN_B
    where REPRICE_ID = X_REPRICE_ID
    ;
begin
  insert into FTP_REPRICE_PATTERN_B (
    REPRICE_ID,
    ADJUSTABLE_TYPE_CODE,
    PATTERN_TYPE_CODE,
    PATTERN_NAME,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_REPRICE_ID,
    X_ADJUSTABLE_TYPE_CODE,
    X_PATTERN_TYPE_CODE,
    X_PATTERN_NAME,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FTP_REPRICE_PATTERN_TL (
    OBJECT_VERSION_NUMBER,
    REPRICE_ID,
    ADJUSTABLE_TYPE_CODE,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_OBJECT_VERSION_NUMBER,
    X_REPRICE_ID,
    X_ADJUSTABLE_TYPE_CODE,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FTP_REPRICE_PATTERN_TL T
    where T.REPRICE_ID = X_REPRICE_ID
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
  X_REPRICE_ID in NUMBER,
  X_ADJUSTABLE_TYPE_CODE in NUMBER,
  X_PATTERN_TYPE_CODE in NUMBER,
  X_PATTERN_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ADJUSTABLE_TYPE_CODE,
      PATTERN_TYPE_CODE,
      PATTERN_NAME,
      OBJECT_VERSION_NUMBER
    from FTP_REPRICE_PATTERN_B
    where REPRICE_ID = X_REPRICE_ID
    for update of REPRICE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FTP_REPRICE_PATTERN_TL
    where REPRICE_ID = X_REPRICE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of REPRICE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.ADJUSTABLE_TYPE_CODE = X_ADJUSTABLE_TYPE_CODE)
      AND (recinfo.PATTERN_TYPE_CODE = X_PATTERN_TYPE_CODE)
      AND (recinfo.PATTERN_NAME = X_PATTERN_NAME)
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
      if (    ((tlinfo.DESCRIPTION = X_DESCRIPTION)
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
  X_REPRICE_ID in NUMBER,
  X_ADJUSTABLE_TYPE_CODE in NUMBER,
  X_PATTERN_TYPE_CODE in NUMBER,
  X_PATTERN_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FTP_REPRICE_PATTERN_B set
    ADJUSTABLE_TYPE_CODE = X_ADJUSTABLE_TYPE_CODE,
    PATTERN_TYPE_CODE = X_PATTERN_TYPE_CODE,
    PATTERN_NAME = X_PATTERN_NAME,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where REPRICE_ID = X_REPRICE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FTP_REPRICE_PATTERN_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where REPRICE_ID = X_REPRICE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_REPRICE_ID in NUMBER
) is
begin
  delete from FTP_REPRICE_PATTERN_TL
  where REPRICE_ID = X_REPRICE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FTP_REPRICE_PATTERN_B
  where REPRICE_ID = X_REPRICE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FTP_REPRICE_PATTERN_TL T
  where not exists
    (select NULL
    from FTP_REPRICE_PATTERN_B B
    where B.REPRICE_ID = T.REPRICE_ID
    );

  update FTP_REPRICE_PATTERN_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from FTP_REPRICE_PATTERN_TL B
    where B.REPRICE_ID = T.REPRICE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.REPRICE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.REPRICE_ID,
      SUBT.LANGUAGE
    from FTP_REPRICE_PATTERN_TL SUBB, FTP_REPRICE_PATTERN_TL SUBT
    where SUBB.REPRICE_ID = SUBT.REPRICE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FTP_REPRICE_PATTERN_TL (
    OBJECT_VERSION_NUMBER,
    REPRICE_ID,
    ADJUSTABLE_TYPE_CODE,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.OBJECT_VERSION_NUMBER,
    B.REPRICE_ID,
    B.ADJUSTABLE_TYPE_CODE,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FTP_REPRICE_PATTERN_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FTP_REPRICE_PATTERN_TL T
    where T.REPRICE_ID = B.REPRICE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FTP_REPRICE_PATTERN_PKG;

/

--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_CLASSIFICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_CLASSIFICATIONS_PKG" as
/* $Header: ENGECCB.pls 115.0 2003/10/30 21:08:21 lkasturi noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CLASSIFICATION_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_DESCRIPTION in VARCHAR2,
  X_CLASSIFICATION_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ENG_CHANGE_CLASSIFICATIONS_B
    where CLASSIFICATION_ID = X_CLASSIFICATION_ID
    ;
begin
  insert into ENG_CHANGE_CLASSIFICATIONS_B (
    START_DATE,
    END_DATE,
    CLASSIFICATION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_START_DATE,
    X_END_DATE,
    X_CLASSIFICATION_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
  insert into ENG_CHANGE_CLASSIFICATIONS_TL (
    DESCRIPTION,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    CLASSIFICATION_NAME,
    CLASSIFICATION_ID,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DESCRIPTION,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CLASSIFICATION_NAME,
    X_CLASSIFICATION_ID,
    X_LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ENG_CHANGE_CLASSIFICATIONS_TL T
    where T.CLASSIFICATION_ID = X_CLASSIFICATION_ID
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
  X_CLASSIFICATION_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_DESCRIPTION in VARCHAR2,
  X_CLASSIFICATION_NAME in VARCHAR2
) is
  cursor c is select
      START_DATE,
      END_DATE
    from ENG_CHANGE_CLASSIFICATIONS_B
    where CLASSIFICATION_ID = X_CLASSIFICATION_ID
    for update of CLASSIFICATION_ID nowait;
  recinfo c%rowtype;
  cursor c1 is select
      DESCRIPTION,
      CLASSIFICATION_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ENG_CHANGE_CLASSIFICATIONS_TL
    where CLASSIFICATION_ID = X_CLASSIFICATION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CLASSIFICATION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.START_DATE = X_START_DATE)
           OR ((recinfo.START_DATE is null) AND (X_START_DATE is null)))
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
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
          AND ((tlinfo.CLASSIFICATION_NAME = X_CLASSIFICATION_NAME)
               OR ((tlinfo.CLASSIFICATION_NAME is null) AND (X_CLASSIFICATION_NAME is null)))
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
  X_CLASSIFICATION_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_DESCRIPTION in VARCHAR2,
  X_CLASSIFICATION_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ENG_CHANGE_CLASSIFICATIONS_B set
    START_DATE = X_START_DATE,
    END_DATE = X_END_DATE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CLASSIFICATION_ID = X_CLASSIFICATION_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  update ENG_CHANGE_CLASSIFICATIONS_TL set
    DESCRIPTION = X_DESCRIPTION,
    CLASSIFICATION_NAME = X_CLASSIFICATION_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CLASSIFICATION_ID = X_CLASSIFICATION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;
procedure DELETE_ROW (
  X_CLASSIFICATION_ID in NUMBER
) is
begin
  delete from ENG_CHANGE_CLASSIFICATIONS_TL
  where CLASSIFICATION_ID = X_CLASSIFICATION_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  delete from ENG_CHANGE_CLASSIFICATIONS_B
  where CLASSIFICATION_ID = X_CLASSIFICATION_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
procedure ADD_LANGUAGE
is
begin
  delete from ENG_CHANGE_CLASSIFICATIONS_TL T
  where not exists
    (select NULL
    from ENG_CHANGE_CLASSIFICATIONS_B B
    where B.CLASSIFICATION_ID = T.CLASSIFICATION_ID
    );
  update ENG_CHANGE_CLASSIFICATIONS_TL T set (
      DESCRIPTION,
      CLASSIFICATION_NAME
    ) = (select
      B.DESCRIPTION,
      B.CLASSIFICATION_NAME
    from ENG_CHANGE_CLASSIFICATIONS_TL B
    where B.CLASSIFICATION_ID = T.CLASSIFICATION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CLASSIFICATION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CLASSIFICATION_ID,
      SUBT.LANGUAGE
    from ENG_CHANGE_CLASSIFICATIONS_TL SUBB, ENG_CHANGE_CLASSIFICATIONS_TL SUBT
    where SUBB.CLASSIFICATION_ID = SUBT.CLASSIFICATION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      or SUBB.CLASSIFICATION_NAME <> SUBT.CLASSIFICATION_NAME
      or (SUBB.CLASSIFICATION_NAME is null and SUBT.CLASSIFICATION_NAME is not null)
      or (SUBB.CLASSIFICATION_NAME is not null and SUBT.CLASSIFICATION_NAME is null)
  ));
  insert into ENG_CHANGE_CLASSIFICATIONS_TL (
    DESCRIPTION,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    CLASSIFICATION_NAME,
    CLASSIFICATION_ID,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.DESCRIPTION,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CLASSIFICATION_NAME,
    B.CLASSIFICATION_ID,
    B.LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ENG_CHANGE_CLASSIFICATIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ENG_CHANGE_CLASSIFICATIONS_TL T
    where T.CLASSIFICATION_ID = B.CLASSIFICATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
end ENG_CHANGE_CLASSIFICATIONS_PKG;

/

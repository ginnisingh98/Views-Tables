--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_TEMPLATES_PKG" as
/* $Header: ENGTMPLB.pls 115.0 2004/02/03 12:39:23 pdutta noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CHANGE_TEMPLATE_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_TEMPLATE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ENG_CHANGE_TEMPLATES_B
    where CHANGE_TEMPLATE_ID = X_CHANGE_TEMPLATE_ID
    ;
begin
  insert into ENG_CHANGE_TEMPLATES_B (
    CHANGE_TEMPLATE_ID,
    ORGANIZATION_ID,
    START_DATE,
    END_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_CHANGE_TEMPLATE_ID,
    X_ORGANIZATION_ID,
    X_START_DATE,
    X_END_DATE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into ENG_CHANGE_TEMPLATES_TL (
    CHANGE_TEMPLATE_ID,
    TEMPLATE_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CHANGE_TEMPLATE_ID,
    X_TEMPLATE_NAME,
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
    from ENG_CHANGE_TEMPLATES_TL T
    where T.CHANGE_TEMPLATE_ID = X_CHANGE_TEMPLATE_ID
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
  X_CHANGE_TEMPLATE_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_TEMPLATE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ORGANIZATION_ID,
      START_DATE,
      END_DATE
    from ENG_CHANGE_TEMPLATES_B
    where CHANGE_TEMPLATE_ID = X_CHANGE_TEMPLATE_ID
    for update of CHANGE_TEMPLATE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TEMPLATE_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ENG_CHANGE_TEMPLATES_TL
    where CHANGE_TEMPLATE_ID = X_CHANGE_TEMPLATE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CHANGE_TEMPLATE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
      AND ((recinfo.START_DATE = X_START_DATE)
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
      if (    (tlinfo.TEMPLATE_NAME = X_TEMPLATE_NAME)
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
  X_CHANGE_TEMPLATE_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_TEMPLATE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ENG_CHANGE_TEMPLATES_B set
    ORGANIZATION_ID = X_ORGANIZATION_ID,
    START_DATE = X_START_DATE,
    END_DATE = X_END_DATE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CHANGE_TEMPLATE_ID = X_CHANGE_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ENG_CHANGE_TEMPLATES_TL set
    TEMPLATE_NAME = X_TEMPLATE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CHANGE_TEMPLATE_ID = X_CHANGE_TEMPLATE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CHANGE_TEMPLATE_ID in NUMBER
) is
begin
  delete from ENG_CHANGE_TEMPLATES_TL
  where CHANGE_TEMPLATE_ID = X_CHANGE_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ENG_CHANGE_TEMPLATES_B
  where CHANGE_TEMPLATE_ID = X_CHANGE_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from ENG_CHANGE_TEMPLATES_TL T
  where not exists
    (select NULL
    from ENG_CHANGE_TEMPLATES_B B
    where B.CHANGE_TEMPLATE_ID = T.CHANGE_TEMPLATE_ID
    );

  update ENG_CHANGE_TEMPLATES_TL T set (
      TEMPLATE_NAME,
      DESCRIPTION
    ) = (select
      B.TEMPLATE_NAME,
      B.DESCRIPTION
    from ENG_CHANGE_TEMPLATES_TL B
    where B.CHANGE_TEMPLATE_ID = T.CHANGE_TEMPLATE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CHANGE_TEMPLATE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CHANGE_TEMPLATE_ID,
      SUBT.LANGUAGE
    from ENG_CHANGE_TEMPLATES_TL SUBB, ENG_CHANGE_TEMPLATES_TL SUBT
    where SUBB.CHANGE_TEMPLATE_ID = SUBT.CHANGE_TEMPLATE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TEMPLATE_NAME <> SUBT.TEMPLATE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into ENG_CHANGE_TEMPLATES_TL (
    CHANGE_TEMPLATE_ID,
    TEMPLATE_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CHANGE_TEMPLATE_ID,
    B.TEMPLATE_NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ENG_CHANGE_TEMPLATES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ENG_CHANGE_TEMPLATES_TL T
    where T.CHANGE_TEMPLATE_ID = B.CHANGE_TEMPLATE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end ENG_CHANGE_TEMPLATES_PKG;

/

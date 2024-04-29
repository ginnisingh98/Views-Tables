--------------------------------------------------------
--  DDL for Package Body BIS_LEVELS_CUSTOMIZATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_LEVELS_CUSTOMIZATIONS_PKG" as
/* $Header: BISPCDLB.pls 115.1 2003/12/09 14:52:00 ankgoel noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ID in NUMBER,
  X_LEVEL_ID in NUMBER,
  X_ENABLED in VARCHAR2,
  X_USER_ID in NUMBER,
  X_RESPONSIBILITY_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_ORG_ID in NUMBER,
  X_SITE_ID in NUMBER,
  X_PAGE_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BIS_LEVELS_CUSTOMIZATIONS
    where ID = X_ID
    ;
begin
  IF ( X_ENABLED = FND_API.G_FALSE ) THEN
    BIS_DIMENSION_LEVEL_PUB.validate_disabling(p_dim_level_id => X_LEVEL_ID );
  END IF;

  insert into BIS_LEVELS_CUSTOMIZATIONS (
    ID,
    LEVEL_ID,
    ENABLED,
    USER_ID,
    RESPONSIBILITY_ID,
    APPLICATION_ID,
    ORG_ID,
    SITE_ID,
    PAGE_ID,
    FUNCTION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ID,
    X_LEVEL_ID,
    X_ENABLED,
    X_USER_ID,
    X_RESPONSIBILITY_ID,
    X_APPLICATION_ID,
    X_ORG_ID,
    X_SITE_ID,
    X_PAGE_ID,
    X_FUNCTION_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into BIS_LEVELS_CUSTOMIZATIONS_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    ID,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_ID,
    X_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BIS_LEVELS_CUSTOMIZATIONS_TL T
    where T.ID = X_ID
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
  X_ID in NUMBER,
  X_LEVEL_ID in NUMBER,
  X_ENABLED in VARCHAR2,
  X_USER_ID in NUMBER,
  X_RESPONSIBILITY_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_ORG_ID in NUMBER,
  X_SITE_ID in NUMBER,
  X_PAGE_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      LEVEL_ID,
      ENABLED,
      USER_ID,
      RESPONSIBILITY_ID,
      APPLICATION_ID,
      ORG_ID,
      SITE_ID,
      PAGE_ID,
      FUNCTION_ID
    from BIS_LEVELS_CUSTOMIZATIONS
    where ID = X_ID
    for update of ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BIS_LEVELS_CUSTOMIZATIONS_TL
    where ID = X_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.LEVEL_ID = X_LEVEL_ID)
      AND ((recinfo.ENABLED = X_ENABLED)
           OR ((recinfo.ENABLED is null) AND (X_ENABLED is null)))
      AND ((recinfo.USER_ID = X_USER_ID)
           OR ((recinfo.USER_ID is null) AND (X_USER_ID is null)))
      AND ((recinfo.RESPONSIBILITY_ID = X_RESPONSIBILITY_ID)
           OR ((recinfo.RESPONSIBILITY_ID is null) AND (X_RESPONSIBILITY_ID is null)))
      AND ((recinfo.APPLICATION_ID = X_APPLICATION_ID)
           OR ((recinfo.APPLICATION_ID is null) AND (X_APPLICATION_ID is null)))
      AND ((recinfo.ORG_ID = X_ORG_ID)
           OR ((recinfo.ORG_ID is null) AND (X_ORG_ID is null)))
      AND ((recinfo.SITE_ID = X_SITE_ID)
           OR ((recinfo.SITE_ID is null) AND (X_SITE_ID is null)))
      AND ((recinfo.PAGE_ID = X_PAGE_ID)
           OR ((recinfo.PAGE_ID is null) AND (X_PAGE_ID is null)))
      AND ((recinfo.FUNCTION_ID = X_FUNCTION_ID)
           OR ((recinfo.FUNCTION_ID is null) AND (X_FUNCTION_ID is null)))
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
  X_ID in NUMBER,
  X_LEVEL_ID in NUMBER,
  X_ENABLED in VARCHAR2,
  X_USER_ID in NUMBER,
  X_RESPONSIBILITY_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_ORG_ID in NUMBER,
  X_SITE_ID in NUMBER,
  X_PAGE_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  IF ( X_ENABLED = FND_API.G_FALSE ) THEN
    BIS_DIMENSION_LEVEL_PUB.validate_disabling(p_dim_level_id => X_LEVEL_ID );
  END IF;

  update BIS_LEVELS_CUSTOMIZATIONS set
    LEVEL_ID = X_LEVEL_ID,
    ENABLED = X_ENABLED,
    USER_ID = X_USER_ID,
    RESPONSIBILITY_ID = X_RESPONSIBILITY_ID,
    APPLICATION_ID = X_APPLICATION_ID,
    ORG_ID = X_ORG_ID,
    SITE_ID = X_SITE_ID,
    PAGE_ID = X_PAGE_ID,
    FUNCTION_ID = X_FUNCTION_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ID = X_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BIS_LEVELS_CUSTOMIZATIONS_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ID = X_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ID in NUMBER
) is
begin
  delete from BIS_LEVELS_CUSTOMIZATIONS_TL
  where ID = X_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BIS_LEVELS_CUSTOMIZATIONS
  where ID = X_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BIS_LEVELS_CUSTOMIZATIONS_TL T
  where not exists
    (select NULL
    from BIS_LEVELS_CUSTOMIZATIONS B
    where B.ID = T.ID
    );

  update BIS_LEVELS_CUSTOMIZATIONS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from BIS_LEVELS_CUSTOMIZATIONS_TL B
    where B.ID = T.ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ID,
      T.LANGUAGE
  ) in (select
      SUBT.ID,
      SUBT.LANGUAGE
    from BIS_LEVELS_CUSTOMIZATIONS_TL SUBB, BIS_LEVELS_CUSTOMIZATIONS_TL SUBT
    where SUBB.ID = SUBT.ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into BIS_LEVELS_CUSTOMIZATIONS_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    ID,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.ID,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BIS_LEVELS_CUSTOMIZATIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BIS_LEVELS_CUSTOMIZATIONS_TL T
    where T.ID = B.ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BIS_LEVELS_CUSTOMIZATIONS_PKG;

/

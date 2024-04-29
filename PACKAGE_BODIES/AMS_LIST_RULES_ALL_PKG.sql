--------------------------------------------------------
--  DDL for Package Body AMS_LIST_RULES_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_RULES_ALL_PKG" as
/* $Header: amstlsrb.pls 120.1 2005/06/27 05:40:31 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_LIST_RULE_ID in NUMBER,
  X_LIST_SOURCE_TYPE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_WEIGHTAGE_FOR_DEDUPE in NUMBER,
  X_ACTIVE_FROM_DATE in DATE,
  X_ACTIVE_TO_DATE in DATE,
  X_LIST_RULE_TYPE in VARCHAR2,
  X_LIST_RULE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AMS_LIST_RULES_ALL
    where LIST_RULE_ID = X_LIST_RULE_ID
    ;
begin
  insert into AMS_LIST_RULES_ALL (
    LIST_SOURCE_TYPE,
    ENABLED_FLAG,
    SEEDED_FLAG,
    LIST_RULE_ID,
    OBJECT_VERSION_NUMBER,
    WEIGHTAGE_FOR_DEDUPE,
    ACTIVE_FROM_DATE,
    ACTIVE_TO_DATE,
    LIST_RULE_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LIST_RULE_NAME
  ) values (
    X_LIST_SOURCE_TYPE,
    X_ENABLED_FLAG,
    X_SEEDED_FLAG,
    X_LIST_RULE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_WEIGHTAGE_FOR_DEDUPE,
    X_ACTIVE_FROM_DATE,
    X_ACTIVE_TO_DATE,
    X_LIST_RULE_TYPE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LIST_RULE_NAME
  );

  insert into AMS_LIST_RULES_ALL_TL (
    LIST_RULE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LIST_RULE_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LIST_RULE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY, -- igoswami :: manually changed here
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LIST_RULE_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_LIST_RULES_ALL_TL T
    where T.LIST_RULE_ID = X_LIST_RULE_ID
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
  X_LIST_RULE_ID in NUMBER,
  X_LIST_SOURCE_TYPE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_WEIGHTAGE_FOR_DEDUPE in NUMBER,
  X_ACTIVE_FROM_DATE in DATE,
  X_ACTIVE_TO_DATE in DATE,
  X_LIST_RULE_TYPE in VARCHAR2,
  X_LIST_RULE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      LIST_SOURCE_TYPE,
      ENABLED_FLAG,
      SEEDED_FLAG,
      OBJECT_VERSION_NUMBER,
      WEIGHTAGE_FOR_DEDUPE,
      ACTIVE_FROM_DATE,
      ACTIVE_TO_DATE,
      LIST_RULE_TYPE
    from AMS_LIST_RULES_ALL
    where LIST_RULE_ID = X_LIST_RULE_ID
    for update of LIST_RULE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      LIST_RULE_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMS_LIST_RULES_ALL_TL
    where LIST_RULE_ID = X_LIST_RULE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of LIST_RULE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.LIST_SOURCE_TYPE = X_LIST_SOURCE_TYPE)
           OR ((recinfo.LIST_SOURCE_TYPE is null) AND (X_LIST_SOURCE_TYPE is null)))
      AND ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
           OR ((recinfo.ENABLED_FLAG is null) AND (X_ENABLED_FLAG is null)))
      AND ((recinfo.SEEDED_FLAG = X_SEEDED_FLAG)
           OR ((recinfo.SEEDED_FLAG is null) AND (X_SEEDED_FLAG is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.WEIGHTAGE_FOR_DEDUPE = X_WEIGHTAGE_FOR_DEDUPE)
           OR ((recinfo.WEIGHTAGE_FOR_DEDUPE is null) AND (X_WEIGHTAGE_FOR_DEDUPE is null)))
      AND (recinfo.ACTIVE_FROM_DATE = X_ACTIVE_FROM_DATE)
      AND ((recinfo.ACTIVE_TO_DATE = X_ACTIVE_TO_DATE)
           OR ((recinfo.ACTIVE_TO_DATE is null) AND (X_ACTIVE_TO_DATE is null)))
      AND ((recinfo.LIST_RULE_TYPE = X_LIST_RULE_TYPE)
           OR ((recinfo.LIST_RULE_TYPE is null) AND (X_LIST_RULE_TYPE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.LIST_RULE_NAME = X_LIST_RULE_NAME)
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
  X_LIST_RULE_ID in NUMBER,
  X_LIST_SOURCE_TYPE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_WEIGHTAGE_FOR_DEDUPE in NUMBER,
  X_ACTIVE_FROM_DATE in DATE,
  X_ACTIVE_TO_DATE in DATE,
  X_LIST_RULE_TYPE in VARCHAR2,
  X_LIST_RULE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_LIST_RULES_ALL set
    LIST_SOURCE_TYPE = X_LIST_SOURCE_TYPE,
    ENABLED_FLAG = X_ENABLED_FLAG,
    SEEDED_FLAG = X_SEEDED_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    WEIGHTAGE_FOR_DEDUPE = X_WEIGHTAGE_FOR_DEDUPE,
    ACTIVE_FROM_DATE = X_ACTIVE_FROM_DATE,
    ACTIVE_TO_DATE = X_ACTIVE_TO_DATE,
    LIST_RULE_TYPE = X_LIST_RULE_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where LIST_RULE_ID = X_LIST_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_LIST_RULES_ALL_TL set
    LIST_RULE_NAME = X_LIST_RULE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,        -- igoswami :: manually changed here
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where LIST_RULE_ID = X_LIST_RULE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LIST_RULE_ID in NUMBER
) is
begin
  delete from AMS_LIST_RULES_ALL_TL
  where LIST_RULE_ID = X_LIST_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_LIST_RULES_ALL
  where LIST_RULE_ID = X_LIST_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_LIST_RULES_ALL_TL T
  where not exists
    (select NULL
    from AMS_LIST_RULES_ALL B
    where B.LIST_RULE_ID = T.LIST_RULE_ID
    );

  update AMS_LIST_RULES_ALL_TL T set (
      LIST_RULE_NAME,
      DESCRIPTION
    ) = (select
      B.LIST_RULE_NAME,
      B.DESCRIPTION
    from AMS_LIST_RULES_ALL_TL B
    where B.LIST_RULE_ID = T.LIST_RULE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LIST_RULE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.LIST_RULE_ID,
      SUBT.LANGUAGE
    from AMS_LIST_RULES_ALL_TL SUBB, AMS_LIST_RULES_ALL_TL SUBT
    where SUBB.LIST_RULE_ID = SUBT.LIST_RULE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.LIST_RULE_NAME <> SUBT.LIST_RULE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_LIST_RULES_ALL_TL (
    LIST_RULE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LIST_RULE_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.LIST_RULE_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LIST_RULE_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_LIST_RULES_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_LIST_RULES_ALL_TL T
    where T.LIST_RULE_ID = B.LIST_RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end AMS_LIST_RULES_ALL_PKG;

/

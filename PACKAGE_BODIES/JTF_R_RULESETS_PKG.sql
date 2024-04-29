--------------------------------------------------------
--  DDL for Package Body JTF_R_RULESETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_R_RULESETS_PKG" as
/* $Header: ibagrstb.pls 115.1 2000/11/08 15:17:26 pkm ship   $ */
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_RULESET_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_IBA_SORT_BY_CODE in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_RULESET_CLASS in BLOB,
  X_RULESET_SER in LONG,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_IBA_SORT_ORDER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_R_RULESETS_B
    where RULESET_ID = X_RULESET_ID
    ;
begin
  insert into JTF_R_RULESETS_B (
    RULESET_ID,
    APPLICATION_ID,
    STATUS,
    IBA_SORT_BY_CODE,
    START_DATE,
    END_DATE,
    RULESET_CLASS,
    RULESET_SER,
    OBJECT_VERSION_NUMBER,
    IBA_SORT_ORDER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_RULESET_ID,
    X_APPLICATION_ID,
    X_STATUS,
    X_IBA_SORT_BY_CODE,
    X_START_DATE,
    X_END_DATE,
    X_RULESET_CLASS,
    X_RULESET_SER,
    X_OBJECT_VERSION_NUMBER,
    X_IBA_SORT_ORDER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_R_RULESETS_TL (
    DESCRIPTION,
    OBJECT_VERSION_NUMBER,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    NAME,
    RULESET_ID,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DESCRIPTION,
    X_OBJECT_VERSION_NUMBER,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_NAME,
    X_RULESET_ID,
    X_CREATED_BY,
    X_CREATION_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_R_RULESETS_TL T
    where T.RULESET_ID = X_RULESET_ID
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
  X_RULESET_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_IBA_SORT_BY_CODE in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_RULESET_CLASS in BLOB,
  X_RULESET_SER in LONG,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_IBA_SORT_ORDER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      APPLICATION_ID,
      STATUS,
      IBA_SORT_BY_CODE,
      START_DATE,
      END_DATE,
      RULESET_CLASS,
      RULESET_SER,
      OBJECT_VERSION_NUMBER,
      IBA_SORT_ORDER
    from JTF_R_RULESETS_B
    where RULESET_ID = X_RULESET_ID
    for update of RULESET_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_R_RULESETS_TL
    where RULESET_ID = X_RULESET_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of RULESET_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.STATUS = X_STATUS)
      AND ((recinfo.IBA_SORT_BY_CODE = X_IBA_SORT_BY_CODE)
           OR ((recinfo.IBA_SORT_BY_CODE is null) AND (X_IBA_SORT_BY_CODE is null)))
      AND ((recinfo.START_DATE = X_START_DATE)
           OR ((recinfo.START_DATE is null) AND (X_START_DATE is null)))
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
  /* commenting this BLOB comparison, since the compilation is failing
      AND ((recinfo.RULESET_CLASS = X_RULESET_CLASS)
           OR ((recinfo.RULESET_CLASS is null) AND (X_RULESET_CLASS is null)))
  */
      AND ((recinfo.RULESET_SER = X_RULESET_SER)
           OR ((recinfo.RULESET_SER is null) AND (X_RULESET_SER is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.IBA_SORT_ORDER = X_IBA_SORT_ORDER)
           OR ((recinfo.IBA_SORT_ORDER is null) AND (X_IBA_SORT_ORDER is null)))
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
  X_RULESET_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_IBA_SORT_BY_CODE in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_RULESET_CLASS in BLOB,
  X_RULESET_SER in LONG,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_IBA_SORT_ORDER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_R_RULESETS_B set
    APPLICATION_ID = X_APPLICATION_ID,
    STATUS = X_STATUS,
    IBA_SORT_BY_CODE = X_IBA_SORT_BY_CODE,
    START_DATE = X_START_DATE,
    END_DATE = X_END_DATE,
    RULESET_CLASS = X_RULESET_CLASS,
    RULESET_SER = X_RULESET_SER,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    IBA_SORT_ORDER = X_IBA_SORT_ORDER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where RULESET_ID = X_RULESET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_R_RULESETS_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where RULESET_ID = X_RULESET_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RULESET_ID in NUMBER
) is
begin
  delete from JTF_R_RULESETS_TL
  where RULESET_ID = X_RULESET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_R_RULESETS_B
  where RULESET_ID = X_RULESET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_R_RULESETS_TL T
  where not exists
    (select NULL
    from JTF_R_RULESETS_B B
    where B.RULESET_ID = T.RULESET_ID
    );

  update JTF_R_RULESETS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from JTF_R_RULESETS_TL B
    where B.RULESET_ID = T.RULESET_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RULESET_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RULESET_ID,
      SUBT.LANGUAGE
    from JTF_R_RULESETS_TL SUBB, JTF_R_RULESETS_TL SUBT
    where SUBB.RULESET_ID = SUBT.RULESET_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into JTF_R_RULESETS_TL (
    DESCRIPTION,
    OBJECT_VERSION_NUMBER,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    NAME,
    RULESET_ID,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.DESCRIPTION,
    B.OBJECT_VERSION_NUMBER,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.NAME,
    B.RULESET_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_R_RULESETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_R_RULESETS_TL T
    where T.RULESET_ID = B.RULESET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
 X_RULESET_ID in NUMBER,
 X_OWNER in VARCHAR2,
 X_NAME in VARCHAR2,
 X_DESCRIPTION in VARCHAR2
) is
begin
  update JTF_R_RULESETS_TL set
    name              = nvl(X_NAME, name),
    description       = nvl(X_DESCRIPTION, description),
    last_update_date  = sysdate,
    last_updated_by   = decode(X_OWNER, 'SEED', 1, 0),
    last_update_login = 0,
    source_lang       = userenv('LANG')
  where RULESET_ID = X_RULESET_ID
  and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

end JTF_R_RULESETS_PKG;

/

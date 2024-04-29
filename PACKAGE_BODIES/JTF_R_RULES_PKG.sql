--------------------------------------------------------
--  DDL for Package Body JTF_R_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_R_RULES_PKG" as
/* $Header: ibagrulb.pls 115.1 2000/11/08 15:14:43 pkm ship   $ */
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_RULE_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_PRIORITY in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RULESET_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_NAME in VARCHAR2,
  X_COND_DESC in VARCHAR2,
  X_ACTION_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_R_RULES_B
    where RULE_ID = X_RULE_ID
    ;
begin
  insert into JTF_R_RULES_B (
    START_DATE,
    END_DATE,
    PRIORITY,
    OBJECT_VERSION_NUMBER,
    RULESET_ID,
    STATUS,
    RULE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_START_DATE,
    X_END_DATE,
    X_PRIORITY,
    X_OBJECT_VERSION_NUMBER,
    X_RULESET_ID,
    X_STATUS,
    X_RULE_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_R_RULES_TL (
    RULE_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    NAME,
    COND_DESC,
    ACTION_DESC,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_RULE_ID,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_NAME,
    X_COND_DESC,
    X_ACTION_DESC,
    X_OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_R_RULES_TL T
    where T.RULE_ID = X_RULE_ID
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
  X_RULE_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_PRIORITY in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RULESET_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_NAME in VARCHAR2,
  X_COND_DESC in VARCHAR2,
  X_ACTION_DESC in VARCHAR2
) is
  cursor c is select
      START_DATE,
      END_DATE,
      PRIORITY,
      OBJECT_VERSION_NUMBER,
      RULESET_ID,
      STATUS
    from JTF_R_RULES_B
    where RULE_ID = X_RULE_ID
    for update of RULE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      COND_DESC,
      ACTION_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_R_RULES_TL
    where RULE_ID = X_RULE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of RULE_ID nowait;
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
      AND ((recinfo.PRIORITY = X_PRIORITY)
           OR ((recinfo.PRIORITY is null) AND (X_PRIORITY is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND (recinfo.RULESET_ID = X_RULESET_ID)
      AND (recinfo.STATUS = X_STATUS)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
          AND ((tlinfo.COND_DESC = X_COND_DESC)
               OR ((tlinfo.COND_DESC is null) AND (X_COND_DESC is null)))
          AND ((tlinfo.ACTION_DESC = X_ACTION_DESC)
               OR ((tlinfo.ACTION_DESC is null) AND (X_ACTION_DESC is null)))
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
  X_RULE_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_PRIORITY in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RULESET_ID in NUMBER,
  X_STATUS in VARCHAR2,
  X_NAME in VARCHAR2,
  X_COND_DESC in VARCHAR2,
  X_ACTION_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_R_RULES_B set
    START_DATE = X_START_DATE,
    END_DATE = X_END_DATE,
    PRIORITY = X_PRIORITY,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    RULESET_ID = X_RULESET_ID,
    STATUS = X_STATUS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where RULE_ID = X_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_R_RULES_TL set
    NAME = X_NAME,
    COND_DESC = X_COND_DESC,
    ACTION_DESC = X_ACTION_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where RULE_ID = X_RULE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RULE_ID in NUMBER
) is
begin
  delete from JTF_R_RULES_TL
  where RULE_ID = X_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_R_RULES_B
  where RULE_ID = X_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_R_RULES_TL T
  where not exists
    (select NULL
    from JTF_R_RULES_B B
    where B.RULE_ID = T.RULE_ID
    );

  update JTF_R_RULES_TL T set (
      NAME,
      COND_DESC,
      ACTION_DESC
    ) = (select
      B.NAME,
      B.COND_DESC,
      B.ACTION_DESC
    from JTF_R_RULES_TL B
    where B.RULE_ID = T.RULE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RULE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RULE_ID,
      SUBT.LANGUAGE
    from JTF_R_RULES_TL SUBB, JTF_R_RULES_TL SUBT
    where SUBB.RULE_ID = SUBT.RULE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.COND_DESC <> SUBT.COND_DESC
      or (SUBB.COND_DESC is null and SUBT.COND_DESC is not null)
      or (SUBB.COND_DESC is not null and SUBT.COND_DESC is null)
      or SUBB.ACTION_DESC <> SUBT.ACTION_DESC
      or (SUBB.ACTION_DESC is null and SUBT.ACTION_DESC is not null)
      or (SUBB.ACTION_DESC is not null and SUBT.ACTION_DESC is null)
  ));

  insert into JTF_R_RULES_TL (
    RULE_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    NAME,
    COND_DESC,
    ACTION_DESC,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.RULE_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.NAME,
    B.COND_DESC,
    B.ACTION_DESC,
    B.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_R_RULES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_R_RULES_TL T
    where T.RULE_ID = B.RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
 X_RULE_ID in NUMBER,
 X_OWNER in VARCHAR2,
 X_NAME in VARCHAR2,
 X_COND_DESC in VARCHAR2,
 X_ACTION_DESC in VARCHAR2
) is
begin
  update JTF_R_RULES_TL set
    name              = nvl(X_NAME, name),
    cond_desc         = nvl(X_COND_DESC, cond_desc),
    action_desc       = nvl(X_ACTION_DESC, action_desc),
    last_update_date  = sysdate,
    last_updated_by   = decode(X_OWNER, 'SEED', 1, 0),
    last_update_login = 0,
    source_lang       = userenv('LANG')
  where rule_id = X_RULE_ID
  and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

end JTF_R_RULES_PKG;

/

--------------------------------------------------------
--  DDL for Package Body IEU_UWQ_LOGIN_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQ_LOGIN_RULES_PKG" as
/* $Header: IEULRULB.pls 120.2 2005/06/20 02:18:43 appldev ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SVR_LOGIN_RULE_ID IN NUMBER,
  X_LOGIN_RULE_TYPE IN VARCHAR2,
  X_LOGIN_RULE IN VARCHAR2,
  X_LOGIN_RULE_NAME IN VARCHAR2,
  X_LOGIN_RULE_DESC IN VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is

  cursor C is select ROWID from IEU_UWQ_LOGIN_RULES_B
    where SVR_LOGIN_RULE_ID = X_SVR_LOGIN_RULE_ID;

begin
  insert into IEU_UWQ_LOGIN_RULES_B (
    SVR_LOGIN_RULE_ID,
    LOGIN_RULE_TYPE,
    LOGIN_RULE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SVR_LOGIN_RULE_ID,
    X_LOGIN_RULE_TYPE,
    X_LOGIN_RULE,
    1,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into IEU_UWQ_LOGIN_RULES_TL (
    SVR_LOGIN_RULE_ID,
    LOGIN_RULE_NAME,
    LOGIN_RULE_DESC,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_SVR_LOGIN_RULE_ID,
    X_LOGIN_RULE_NAME,
    X_LOGIN_RULE_DESC,
    1,
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
    from IEU_UWQ_LOGIN_RULES_TL T
    where T.SVR_LOGIN_RULE_ID = X_SVR_LOGIN_RULE_ID
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
  X_SVR_LOGIN_RULE_ID IN NUMBER,
  X_LOGIN_RULE_TYPE IN VARCHAR2,
  X_LOGIN_RULE IN VARCHAR2,
  X_LOGIN_RULE_NAME IN VARCHAR2,
  X_LOGIN_RULE_DESC IN VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      LOGIN_RULE_TYPE,
      LOGIN_RULE
    from IEU_UWQ_LOGIN_RULES_B
    where SVR_LOGIN_RULE_ID = X_SVR_LOGIN_RULE_ID
    for update of SVR_LOGIN_RULE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      LOGIN_RULE_NAME,
      LOGIN_RULE_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IEU_UWQ_LOGIN_RULES_TL
    where SVR_LOGIN_RULE_ID = X_SVR_LOGIN_RULE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SVR_LOGIN_RULE_ID nowait;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.LOGIN_RULE_TYPE = X_LOGIN_RULE_TYPE)
      AND (recinfo.LOGIN_RULE= X_LOGIN_RULE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.LOGIN_RULE_NAME = X_LOGIN_RULE_NAME)
          AND (tlinfo.LOGIN_RULE_DESC = X_LOGIN_RULE_DESC)
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
  X_SVR_LOGIN_RULE_ID IN NUMBER,
  X_LOGIN_RULE_TYPE IN VARCHAR2,
  X_LOGIN_RULE IN VARCHAR2,
  X_LOGIN_RULE_NAME IN VARCHAR2,
  X_LOGIN_RULE_DESC IN VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IEU_UWQ_LOGIN_RULES_B set
    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
    LOGIN_RULE_TYPE = X_LOGIN_RULE_TYPE,
    LOGIN_RULE = X_LOGIN_RULE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SVR_LOGIN_RULE_ID = X_SVR_LOGIN_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IEU_UWQ_LOGIN_RULES_TL set
    LOGIN_RULE_NAME = X_LOGIN_RULE_NAME,
    LOGIN_RULE_DESC = X_LOGIN_RULE_DESC,
    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SVR_LOGIN_RULE_ID = X_SVR_LOGIN_RULE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SVR_LOGIN_RULE_ID in NUMBER
) is
begin
  delete from IEU_UWQ_LOGIN_RULES_TL
  where SVR_LOGIN_RULE_ID = X_SVR_LOGIN_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEU_UWQ_LOGIN_RULES_B
  where SVR_LOGIN_RULE_ID = X_SVR_LOGIN_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IEU_UWQ_LOGIN_RULES_TL T
  where not exists
    (select NULL
    from IEU_UWQ_LOGIN_RULES_B B
    where B.SVR_LOGIN_RULE_ID = T.SVR_LOGIN_RULE_ID
    );

  update IEU_UWQ_LOGIN_RULES_TL T set (
      LOGIN_RULE_NAME,
      LOGIN_RULE_DESC
    ) = (select
      B.LOGIN_RULE_NAME,
      B.LOGIN_RULE_DESC
    from IEU_UWQ_LOGIN_RULES_TL B
    where B.SVR_LOGIN_RULE_ID = T.SVR_LOGIN_RULE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SVR_LOGIN_RULE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SVR_LOGIN_RULE_ID,
      SUBT.LANGUAGE
    from IEU_UWQ_LOGIN_RULES_TL SUBB, IEU_UWQ_LOGIN_RULES_TL SUBT
    where SUBB.SVR_LOGIN_RULE_ID = SUBT.SVR_LOGIN_RULE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.LOGIN_RULE_NAME <> SUBT.LOGIN_RULE_NAME
      or SUBB.LOGIN_RULE_DESC <> SUBT.LOGIN_RULE_DESC
  ));

  insert into IEU_UWQ_LOGIN_RULES_TL (
    SVR_LOGIN_RULE_ID,
    LOGIN_RULE_NAME,
    LOGIN_RULE_DESC,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SVR_LOGIN_RULE_ID,
    B.LOGIN_RULE_NAME,
    B.LOGIN_RULE_DESC,
    B.OBJECT_VERSION_NUMBER,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEU_UWQ_LOGIN_RULES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEU_UWQ_LOGIN_RULES_TL T
    where T.SVR_LOGIN_RULE_ID = B.SVR_LOGIN_RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_SVR_LOGIN_RULE_ID IN NUMBER,
  X_LOGIN_RULE_TYPE IN VARCHAR2,
  X_LOGIN_RULE IN VARCHAR2,
  X_LOGIN_RULE_NAME IN VARCHAR2,
  X_LOGIN_RULE_DESC IN VARCHAR2,
  X_OWNER in VARCHAR2
) is
  l_user_id  number := 0;
  l_rowid    varchar2(50);

begin

  IF (x_owner = 'SEED') then
    l_user_id := 1;
  end if;

  begin

    UPDATE_ROW(
      X_SVR_LOGIN_RULE_ID => X_SVR_LOGIN_RULE_ID,
      X_LOGIN_RULE_TYPE => X_LOGIN_RULE_TYPE,
      X_LOGIN_RULE => X_LOGIN_RULE,
      X_LOGIN_RULE_NAME => X_LOGIN_RULE_NAME,
      X_LOGIN_RULE_DESC => X_LOGIN_RULE_DESC,
      X_LAST_UPDATE_DATE => SYSDATE,
      --X_LAST_UPDATED_BY => l_user_id,
      X_LAST_UPDATED_BY => fnd_load_util.owner_id(X_OWNER),
      X_LAST_UPDATE_LOGIN => 0
    );

    if (sql%notfound) then
      raise no_data_found;
    end if;

  exception
    when no_data_found then

      INSERT_ROW(
        X_ROWID => l_rowid,
        X_SVR_LOGIN_RULE_ID => X_SVR_LOGIN_RULE_ID,
        X_LOGIN_RULE_TYPE => X_LOGIN_RULE_TYPE,
        X_LOGIN_RULE => X_LOGIN_RULE,
        X_LOGIN_RULE_NAME => X_LOGIN_RULE_NAME,
        X_LOGIN_RULE_DESC => X_LOGIN_RULE_DESC,
        X_CREATION_DATE => SYSDATE,
        --X_CREATED_BY => l_user_id,
        X_CREATED_BY => fnd_load_util.owner_id(X_OWNER),
        X_LAST_UPDATE_DATE => SYSDATE,
        --X_LAST_UPDATED_BY => l_user_id,
        X_LAST_UPDATED_BY => fnd_load_util.owner_id(X_OWNER),
        X_LAST_UPDATE_LOGIN => 0
      );

  end;

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_SVR_LOGIN_RULE_ID IN NUMBER,
  X_LOGIN_RULE_NAME IN VARCHAR2,
  X_LOGIN_RULE_DESC IN VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin

  -- only UPDATE rows that have not been altered by user

  UPDATE
    IEU_UWQ_LOGIN_RULES_TL
  SET
    source_lang = userenv('LANG'),
    login_rule_name = x_login_rule_name,
    login_rule_desc = x_login_rule_desc,
    last_update_date = sysdate,
    --last_updated_by = decode(x_owner, 'SEED', 1, 0),
    last_updated_by = fnd_load_util.owner_id(x_owner),
    last_update_login = 0
  WHERE
    (SVR_LOGIN_RULE_ID = X_SVR_LOGIN_RULE_ID) and
    (userenv('LANG') IN (language, source_lang));

  if (sql%notfound) then
    raise no_data_found;
  end if;

end TRANSLATE_ROW;

procedure LOAD_SEED_ROW (
  X_UPLOAD_MODE IN VARCHAR2,
  X_SVR_LOGIN_RULE_ID IN NUMBER,
  X_LOGIN_RULE_TYPE IN VARCHAR2,
  X_LOGIN_RULE IN VARCHAR2,
  X_LOGIN_RULE_NAME IN VARCHAR2,
  X_LOGIN_RULE_DESC IN VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin

if (X_UPLOAD_MODE = 'NLS') then
  TRANSLATE_ROW (
    X_SVR_LOGIN_RULE_ID,
    X_LOGIN_RULE_NAME,
    X_LOGIN_RULE_DESC,
    X_OWNER);

else
  LOAD_ROW (
    X_SVR_LOGIN_RULE_ID,
    X_LOGIN_RULE_TYPE,
    X_LOGIN_RULE,
    X_LOGIN_RULE_NAME,
    X_LOGIN_RULE_DESC,
    X_OWNER);
end if;

end LOAD_SEED_ROW;

end IEU_UWQ_LOGIN_RULES_PKG;

/

--------------------------------------------------------
--  DDL for Package Body JTF_DPF_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DPF_RULES_PKG" as
/* $Header: jtfdpfrb.pls 120.2 2005/10/25 05:18:33 psanyal ship $ */
procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_RULE_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RULE_NAME in VARCHAR2,
  X_RULE_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_DPF_RULES_B
    where RULE_ID = X_RULE_ID
    ;
begin
  insert into JTF_DPF_RULES_B (
    APPLICATION_ID,
    OBJECT_VERSION_NUMBER,
    RULE_ID,
    RULE_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_OBJECT_VERSION_NUMBER,
    X_RULE_ID,
    X_RULE_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_DPF_RULES_TL (
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    RULE_ID,
    RULE_DESCRIPTION,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_RULE_ID,
    X_RULE_DESCRIPTION,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_DPF_RULES_TL T
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
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RULE_NAME in VARCHAR2,
  X_RULE_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      APPLICATION_ID,
      OBJECT_VERSION_NUMBER,
      RULE_NAME
    from JTF_DPF_RULES_B
    where RULE_ID = X_RULE_ID
    for update of RULE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      RULE_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_DPF_RULES_TL
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
  if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.RULE_NAME = X_RULE_NAME)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.RULE_DESCRIPTION = X_RULE_DESCRIPTION)
               OR ((tlinfo.RULE_DESCRIPTION is null) AND (X_RULE_DESCRIPTION is null)))
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
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RULE_NAME in VARCHAR2,
  X_RULE_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_DPF_RULES_B set
    APPLICATION_ID = X_APPLICATION_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    RULE_NAME = X_RULE_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where RULE_ID = X_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_DPF_RULES_TL set
    RULE_DESCRIPTION = X_RULE_DESCRIPTION,
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
  delete from JTF_DPF_RULES_TL
  where RULE_ID = X_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_DPF_RULES_B
  where RULE_ID = X_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_DPF_RULES_TL T
  where not exists
    (select NULL
    from JTF_DPF_RULES_B B
    where B.RULE_ID = T.RULE_ID
    );

  update JTF_DPF_RULES_TL T set (
      RULE_DESCRIPTION
    ) = (select
      B.RULE_DESCRIPTION
    from JTF_DPF_RULES_TL B
    where B.RULE_ID = T.RULE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RULE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RULE_ID,
      SUBT.LANGUAGE
    from JTF_DPF_RULES_TL SUBB, JTF_DPF_RULES_TL SUBT
    where SUBB.RULE_ID = SUBT.RULE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.RULE_DESCRIPTION <> SUBT.RULE_DESCRIPTION
      or (SUBB.RULE_DESCRIPTION is null and SUBT.RULE_DESCRIPTION is not null)
      or (SUBB.RULE_DESCRIPTION is not null and SUBT.RULE_DESCRIPTION is null)
  ));

  insert into JTF_DPF_RULES_TL (
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    RULE_ID,
    RULE_DESCRIPTION,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.RULE_ID,
    B.RULE_DESCRIPTION,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_DPF_RULES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_DPF_RULES_TL T
    where T.RULE_ID = B.RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

  procedure TRANSLATE_ROW (
     X_RULE_NAME IN VARCHAR2,
     X_APPLICATION_ID IN VARCHAR2,
     X_RULE_DESCRIPTION IN VARCHAR2,
     X_OWNER IN VARCHAR2) is
     l_rule_id number;
     l_user_id number;
  begin
    l_user_id := 0;
    if x_owner = 'SEED' then l_user_id := 1; end if;

    l_rule_id := find(x_rule_name, x_application_id);

    update jtf_dpf_rules_tl set
        rule_description = x_rule_description
      where userenv('LANG') in (LANGUAGE, SOURCE_LANG) and
        rule_id = l_rule_id;
  end;

  procedure LOAD_ROW (
     X_RULE_NAME in VARCHAR2,
     X_APPLICATION_ID in VARCHAR2,
     X_RULE_DESCRIPTION  in VARCHAR2,
     X_NUM_PARAMS IN VARCHAR2,
     X_OWNER in VARCHAR2
  ) is
    -- select instances of this rule, identified by appid and name
    cursor c is select rule_id from jtf_dpf_rules_b
      where application_id = x_application_id and
	rule_name=x_rule_name;

    t_old_rule_id number;
    t_new_rule_id number;
    t_rowid rowid;
    t_user number;
  begin
    t_user := 0;
    if x_owner = 'SEED' then t_user := 1; end if;

    -- see whether a row with this appid and rule_name already exists
    open c;
    fetch c into t_old_rule_id;

    -- if it's not already there
    if c%notfound then
      close c;

      -- get a new pseudo-sequence number
      -- arsingh: prevent use of same id by different threads.
      select JTF_DPF_RULES_S.nextval into t_new_rule_id from dual;
      -- select max(rule_id) into t_new_rule_id from jtf_dpf_rules_b
      --   where rule_id<10000;
      -- if t_new_rule_id is null then
      --   t_new_rule_id := 1;
      -- else
      --   t_new_rule_id := t_new_rule_id+1;
      -- end if;

      -- call _pkg.insert_row to handle _b and _tl tables
      insert_row (
        X_ROWID                      => t_rowid,
        X_RULE_ID                    => t_new_rule_id,
        X_APPLICATION_ID             => x_application_id,
        X_OBJECT_VERSION_NUMBER      => 1,
        X_RULE_NAME                  => x_rule_name,
        X_RULE_DESCRIPTION           => x_rule_description,
        X_CREATION_DATE              => SYSDATE,
        X_CREATED_BY                 => t_user,
        X_LAST_UPDATE_DATE           => SYSDATE,
        X_LAST_UPDATED_BY            => t_user,
        X_LAST_UPDATE_LOGIN          =>  0); --  FND_GLOBAL.CONC_LOGIN_ID);
    -- else, if this rule already exists, so update it
    else
      close c;
      -- call _pkg.update_row to handle _b and _tl tables
      update_row (
        X_RULE_ID                    => t_old_rule_id,
        X_APPLICATION_ID             => x_application_id,
        X_OBJECT_VERSION_NUMBER      => 1,
        X_RULE_NAME                  => x_rule_name,
        X_RULE_DESCRIPTION           => x_rule_description,
        X_LAST_UPDATE_DATE           => sysdate,
        X_LAST_UPDATED_BY            => t_user,
        X_LAST_UPDATE_LOGIN          => 0) ; -- fnd_global.conc_login_id);

      -- the seed data specifies that the rule (appid, rule_name)
      -- has no param with sequence higher than x_num_params
      delete from jtf_dpf_rule_params where
        rule_id = t_old_rule_id and
	rule_param_sequence > x_num_params;
    end if;
  end;

  procedure INSERT_RULE_PARAMS(
    X_RULE_PARAM_SEQUENCE NUMBER,
    X_RULE_ID NUMBER,
    X_RULE_PARAM_CONDITION VARCHAR2,
    X_RULE_PARAM_NAME VARCHAR2,
    X_RULE_PARAM_VALUE VARCHAR2,
    X_OWNER IN VARCHAR2
  ) is
    l_user_id number;
  begin
    l_user_id := 0;
    if x_owner = 'SEED' then l_user_id := 1; end if;

    insert into jtf_dpf_rule_params(
	rule_param_sequence,
        rule_id,
        rule_param_condition,
        rule_param_name,
        rule_param_value,
		OBJECT_VERSION_NUMBER,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN)
    values (
	X_RULE_PARAM_SEQUENCE,
        X_rule_id,
        X_RULE_PARAM_CONDITION,
        X_RULE_PARAM_NAME,
        X_RULE_PARAM_VALUE,
		1,
		l_user_id,
		sysdate,
		sysdate,
		l_user_id,
		0);
  end;

  procedure UPDATE_RULE_PARAMS(
    X_RULE_PARAM_SEQUENCE NUMBER,
    X_RULE_ID NUMBER,
    X_RULE_PARAM_CONDITION VARCHAR2,
    X_RULE_PARAM_NAME VARCHAR2,
    X_RULE_PARAM_VALUE VARCHAR2,
    X_OWNER IN VARCHAR2
  ) is
    l_user_id number;
  begin
    l_user_id := 0;
    if x_owner = 'SEED' then l_user_id := 1; end if;

    update jtf_dpf_rule_params set
	rule_param_name = x_rule_param_name,
	rule_param_value = x_rule_param_value,
	rule_param_condition = x_rule_param_condition,
		object_version_number = object_version_number +1,
		last_update_date = sysdate,
		last_updated_by = l_user_id,
		last_update_login = 0
      where rule_id = x_rule_id and
	rule_param_sequence = x_rule_param_sequence;
  end;

  function find(
    x_rule_name varchar2,
    x_application_id in varchar2
  ) return number is
    cursor c1(p_rule_name varchar2, p_application_id number) is
      select rule_id from jtf_dpf_rules_b
        where rule_name = p_rule_name and application_id = p_application_id;
    retval number := null;
  begin
    open c1(x_rule_name, x_application_id);
    fetch c1 into retval;
    close c1;
    return retval;
  end;

end JTF_DPF_RULES_PKG;

/

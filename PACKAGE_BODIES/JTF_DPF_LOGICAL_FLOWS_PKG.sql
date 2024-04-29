--------------------------------------------------------
--  DDL for Package Body JTF_DPF_LOGICAL_FLOWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DPF_LOGICAL_FLOWS_PKG" as
/* $Header: jtfdpffb.pls 120.2 2005/10/25 05:16:26 psanyal ship $ */
    cursor find_match_with_owner(x_logical_flow_name varchar2,
      x_application_id varchar2,
      x_last_updated_by number) is
        select logical_flow_id from jtf_dpf_logical_flows_b
          where logical_flow_name=x_logical_flow_name and
	    application_id=x_application_id and
	    last_updated_by = x_last_updated_by
          order by last_update_date;

    -- same query, without the last_updated_by test
    cursor find_match(x_logical_flow_name varchar2,
      x_application_id varchar2) is
        select logical_flow_id from jtf_dpf_logical_flows_b
          where logical_flow_name=x_logical_flow_name and
	    application_id=x_application_id
          order by last_update_date;

procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_LOGICAL_FLOW_ID in NUMBER,
  X_LOGICAL_FLOW_HEAD_ID in NUMBER,
  X_LOGICAL_FLOW_NAME in VARCHAR2,
  X_SECURE_FLOW_FLAG in VARCHAR2,
  X_VALIDATE_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FLOW_FINALIZER_CLASS in VARCHAR2,
  X_RETURN_TO_PAGE_ID in NUMBER,
  X_BASE_FLOW_FLAG in VARCHAR2,
--  X_ENABLED_CLONE_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LOGICAL_FLOW_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER) is
  l_flowid number;
  l_enabled varchar2(1);
  cursor C is select ROWID from JTF_DPF_LOGICAL_FLOWS_B
    where LOGICAL_FLOW_ID = X_LOGICAL_FLOW_ID;
  cursor any_others_with_same_name is
    select logical_flow_id
      from jtf_dpf_logical_flows_b
      where logical_flow_name = x_logical_flow_name and
        application_id = x_application_id;
begin
  -- if there are any other flows of the same appid and name, then set
  -- l_enabled to 'F', else set it to 'T'.
  open any_others_with_same_name;
  fetch any_others_with_same_name into l_flowid;
  close any_others_with_same_name;

  if l_flowid is null then
    l_enabled := 'T';
  else
    l_enabled := 'F';
  end if;

  insert into JTF_DPF_LOGICAL_FLOWS_B (
    LOGICAL_FLOW_ID,
    LOGICAL_FLOW_HEAD_ID,
    LOGICAL_FLOW_NAME,
    SECURE_FLOW_FLAG,
    VALIDATE_FLAG,
    APPLICATION_ID,
    FLOW_FINALIZER_CLASS,
    RETURN_TO_PAGE_ID,
    BASE_FLOW_FLAG,
    ENABLED_CLONE_FLAG,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_LOGICAL_FLOW_ID,
    X_LOGICAL_FLOW_HEAD_ID,
    X_LOGICAL_FLOW_NAME,
    X_SECURE_FLOW_FLAG,
    X_VALIDATE_FLAG,
    X_APPLICATION_ID,
    X_FLOW_FINALIZER_CLASS,
    X_RETURN_TO_PAGE_ID,
    X_BASE_FLOW_FLAG,
    l_enabled,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_DPF_LOGICAL_FLOWS_TL (
    LOGICAL_FLOW_ID,
    LOGICAL_FLOW_DESCRIPTION,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LOGICAL_FLOW_ID,
    X_LOGICAL_FLOW_DESCRIPTION,
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
    from JTF_DPF_LOGICAL_FLOWS_TL T
    where T.LOGICAL_FLOW_ID = X_LOGICAL_FLOW_ID
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
  X_LOGICAL_FLOW_ID in NUMBER,
  X_LOGICAL_FLOW_HEAD_ID in NUMBER,
  X_LOGICAL_FLOW_NAME in VARCHAR2,
  X_SECURE_FLOW_FLAG in VARCHAR2,
  X_VALIDATE_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FLOW_FINALIZER_CLASS in VARCHAR2,
  X_RETURN_TO_PAGE_ID in NUMBER,
  X_BASE_FLOW_FLAG in VARCHAR2,
  X_ENABLED_CLONE_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LOGICAL_FLOW_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      LOGICAL_FLOW_HEAD_ID,
      LOGICAL_FLOW_NAME,
      SECURE_FLOW_FLAG,
      VALIDATE_FLAG,
      APPLICATION_ID,
      FLOW_FINALIZER_CLASS,
      RETURN_TO_PAGE_ID,
      BASE_FLOW_FLAG,
      ENABLED_CLONE_FLAG,
      OBJECT_VERSION_NUMBER
    from JTF_DPF_LOGICAL_FLOWS_B
    where LOGICAL_FLOW_ID = X_LOGICAL_FLOW_ID
    for update of LOGICAL_FLOW_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      LOGICAL_FLOW_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_DPF_LOGICAL_FLOWS_TL
    where LOGICAL_FLOW_ID = X_LOGICAL_FLOW_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of LOGICAL_FLOW_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.LOGICAL_FLOW_HEAD_ID = X_LOGICAL_FLOW_HEAD_ID)
      AND (recinfo.LOGICAL_FLOW_NAME = X_LOGICAL_FLOW_NAME)
      AND (recinfo.SECURE_FLOW_FLAG = X_SECURE_FLOW_FLAG)
      AND (recinfo.VALIDATE_FLAG = X_VALIDATE_FLAG)
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND ((recinfo.FLOW_FINALIZER_CLASS = X_FLOW_FINALIZER_CLASS)
           OR ((recinfo.FLOW_FINALIZER_CLASS is null) AND (X_FLOW_FINALIZER_CLASS is null)))
      AND ((recinfo.RETURN_TO_PAGE_ID = X_RETURN_TO_PAGE_ID)
           OR ((recinfo.RETURN_TO_PAGE_ID is null) AND (X_RETURN_TO_PAGE_ID is null)))
      AND (recinfo.BASE_FLOW_FLAG = X_BASE_FLOW_FLAG)
--      AND (recinfo.ENABLED_CLONE_FLAG = X_ENABLED_CLONE_FLAG)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.LOGICAL_FLOW_DESCRIPTION = X_LOGICAL_FLOW_DESCRIPTION)
               OR ((tlinfo.LOGICAL_FLOW_DESCRIPTION is null) AND (X_LOGICAL_FLOW_DESCRIPTION is null)))
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
  X_LOGICAL_FLOW_ID in NUMBER,
  X_LOGICAL_FLOW_HEAD_ID in NUMBER,
  X_LOGICAL_FLOW_NAME in VARCHAR2,
  X_SECURE_FLOW_FLAG in VARCHAR2,
  X_VALIDATE_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FLOW_FINALIZER_CLASS in VARCHAR2,
  X_RETURN_TO_PAGE_ID in NUMBER,
  X_BASE_FLOW_FLAG in VARCHAR2,
--  X_ENABLED_CLONE_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LOGICAL_FLOW_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_DPF_LOGICAL_FLOWS_B set
    LOGICAL_FLOW_HEAD_ID = X_LOGICAL_FLOW_HEAD_ID,
    LOGICAL_FLOW_NAME = X_LOGICAL_FLOW_NAME,
    SECURE_FLOW_FLAG = X_SECURE_FLOW_FLAG,
    VALIDATE_FLAG = X_VALIDATE_FLAG,
    APPLICATION_ID = X_APPLICATION_ID,
    FLOW_FINALIZER_CLASS = X_FLOW_FINALIZER_CLASS,
    RETURN_TO_PAGE_ID = X_RETURN_TO_PAGE_ID,
    BASE_FLOW_FLAG = X_BASE_FLOW_FLAG,
--    ENABLED_CLONE_FLAG = X_ENABLED_CLONE_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where LOGICAL_FLOW_ID = X_LOGICAL_FLOW_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_DPF_LOGICAL_FLOWS_TL set
    LOGICAL_FLOW_DESCRIPTION = X_LOGICAL_FLOW_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where LOGICAL_FLOW_ID = X_LOGICAL_FLOW_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LOGICAL_FLOW_ID in NUMBER
) is
begin
  delete from JTF_DPF_LOGICAL_FLOWS_TL
  where LOGICAL_FLOW_ID = X_LOGICAL_FLOW_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_DPF_LOGICAL_FLOWS_B
  where LOGICAL_FLOW_ID = X_LOGICAL_FLOW_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_DPF_LOGICAL_FLOWS_TL T
  where not exists
    (select NULL
    from JTF_DPF_LOGICAL_FLOWS_B B
    where B.LOGICAL_FLOW_ID = T.LOGICAL_FLOW_ID
    );

  update JTF_DPF_LOGICAL_FLOWS_TL T set (
      LOGICAL_FLOW_DESCRIPTION
    ) = (select
      B.LOGICAL_FLOW_DESCRIPTION
    from JTF_DPF_LOGICAL_FLOWS_TL B
    where B.LOGICAL_FLOW_ID = T.LOGICAL_FLOW_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LOGICAL_FLOW_ID,
      T.LANGUAGE
  ) in (select
      SUBT.LOGICAL_FLOW_ID,
      SUBT.LANGUAGE
    from JTF_DPF_LOGICAL_FLOWS_TL SUBB, JTF_DPF_LOGICAL_FLOWS_TL SUBT
    where SUBB.LOGICAL_FLOW_ID = SUBT.LOGICAL_FLOW_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.LOGICAL_FLOW_DESCRIPTION <> SUBT.LOGICAL_FLOW_DESCRIPTION
      or (SUBB.LOGICAL_FLOW_DESCRIPTION is null and SUBT.LOGICAL_FLOW_DESCRIPTION is not null)
      or (SUBB.LOGICAL_FLOW_DESCRIPTION is not null and SUBT.LOGICAL_FLOW_DESCRIPTION is null)
  ));

  insert into JTF_DPF_LOGICAL_FLOWS_TL (
    LOGICAL_FLOW_ID,
    LOGICAL_FLOW_DESCRIPTION,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LOGICAL_FLOW_ID,
    B.LOGICAL_FLOW_DESCRIPTION,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_DPF_LOGICAL_FLOWS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_DPF_LOGICAL_FLOWS_TL T
    where T.LOGICAL_FLOW_ID = B.LOGICAL_FLOW_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

  function find_oldest_prefer_owned_by(x_logical_flow_name varchar2,
    x_application_id varchar2, x_last_updated_by number) return number is
    l_candidate number;
  begin
    -- if there's one in seed data (i.e. with l_updated_by = 1)
    -- then return it
    open find_match_with_owner(x_logical_flow_name, x_application_id,
      x_last_updated_by);
    fetch find_match_with_owner into l_candidate;
    close find_match_with_owner;
    if l_candidate is not null then return l_candidate; end if;

    -- if there's any at all (seed data or not), then return it
    open find_match(x_logical_flow_name, x_application_id);
    fetch find_match into l_candidate;
    close find_match;

    return l_candidate;
  end;

  procedure insert_flow_params(
    x_flow_id number,
    x_parameter_name varchar2,
    x_parameter_type varchar2,
    x_parameter_sequence varchar2,
    x_owner varchar2) is
    l_user_id number;
  begin
    l_user_id := 0;
    if x_owner = 'SEED' then l_user_id := 1; end if;

    insert into jtf_dpf_lgcl_flow_params(
	LOGICAL_FLOW_ID,
	PARAMETER_NAME,
	PARAMETER_TYPE,
	PARAMETER_SEQUENCE,
		OBJECT_VERSION_NUMBER,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN)
    values (
	x_flow_id,
	x_parameter_name,
	x_parameter_type,
	x_parameter_sequence,
		1,
		l_user_id,
		sysdate,
		sysdate,
		l_user_id,
		0);
  end;

  procedure update_flow_params(
    x_flow_id number,
    x_parameter_name varchar2,
    x_parameter_type varchar2,
    x_parameter_sequence varchar2,
    x_owner varchar2) is
    l_user_id number;
  begin
    l_user_id := 0;
    if x_owner = 'SEED' then l_user_id := 1; end if;
    update jtf_dpf_lgcl_flow_params set
	PARAMETER_TYPE = x_parameter_type,
	PARAMETER_NAME = x_parameter_name,
		OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
		LAST_UPDATE_DATE = sysdate,
		LAST_UPDATED_BY = l_user_id,
		LAST_UPDATE_LOGIN = 0
      where logical_flow_id = x_flow_id and
	parameter_sequence=x_parameter_sequence;
  end;

  procedure translate_row(
    x_flow_name varchar2,
    x_application_id varchar2,
    x_flow_description varchar2,
    x_owner varchar2
  ) is
    l_flow_id number;
    l_user_id number;
  begin
    l_user_id := 0;
    if x_owner = 'SEED' then l_user_id := 1; end if;

    l_flow_id := find_oldest_prefer_owned_by(x_flow_name, x_application_id,
      l_user_id);
    update jtf_dpf_logical_flows_tl set
      logical_flow_description = x_flow_description,
	last_updated_by = l_user_id,
	last_update_date = sysdate,
	last_update_login = 0
      where userenv('LANG') in (LANGUAGE, SOURCE_LANG) and
        logical_flow_id = l_flow_id;
  end;

  procedure load_row(
    X_APPLICATION_ID VARCHAR2,
    X_LOGICAL_FLOW_NAME VARCHAR2,
    X_HEAD_LOGICAL_PAGE_NAME VARCHAR2,
    X_HEAD_LOGICAL_PAGE_APP_ID VARCHAR2,
    X_SECURE_FLOW_FLAG VARCHAR2,
    X_VALIDATE_FLAG VARCHAR2,
    X_FLOW_FINALIZER_CLASS VARCHAR2,
    X_RTN_TO_LOGICAL_PAGE_NAME VARCHAR2,
    X_RTN_TO_LOGICAL_PAGE_APP_ID VARCHAR2,
    X_BASE_FLOW_FLAG VARCHAR2,
--    X_ENABLED_CLONE_FLAG VARCHAR2,
    X_LOGICAL_FLOW_DESCRIPTION VARCHAR2,
    X_OWNER in VARCHAR2) is
    t_user number;
    t_rowid rowid;
    t_header_id number;
    t_return_to_id number;
    l_new_flow_id number;
    l_flow_id number;
    l_counter number;
  begin
    t_user := 0;
    if x_owner = 'SEED' then t_user := 1; end if;

    t_header_id := jtf_dpf_logical_pages_pkg.find(
      X_HEAD_LOGICAL_PAGE_NAME, X_HEAD_LOGICAL_PAGE_APP_ID);
    t_return_to_id := jtf_dpf_logical_pages_pkg.find(
      X_RTN_TO_LOGICAL_PAGE_NAME,
      X_RTN_TO_LOGICAL_PAGE_APP_ID);

    -- see whether there's already a Flow owned by t_user
    open find_match_with_owner(x_logical_flow_name, x_application_id, t_user);
    fetch find_match_with_owner into l_flow_id;
    close find_match_with_owner;

    if l_flow_id is null then
      -- cons up a new flow_id, smaller than 10000
      l_new_flow_id := null;
      -- arsingh: prevent use of same id by different threads.
      select JTF_DPF_LOGICAL_FLOWS_S.nextval into l_new_flow_id from dual;
      -- select max(logical_flow_id) into l_new_flow_id from
      --   jtf_dpf_logical_flows_b where logical_flow_id<10000;
      -- if l_new_flow_id is null then
      --   l_new_flow_id := 1;
      -- else
      --   l_new_flow_id := l_new_flow_id+1;
      -- end if;

      -- do an insert
      insert_row(
        X_ROWID => t_rowid,
        X_LOGICAL_FLOW_ID => l_new_flow_id,
        X_LOGICAL_FLOW_HEAD_ID => t_header_id,
        X_LOGICAL_FLOW_NAME => X_LOGICAL_FLOW_NAME,
        X_SECURE_FLOW_FLAG => X_SECURE_FLOW_FLAG,
        X_VALIDATE_FLAG => X_VALIDATE_FLAG,
        X_APPLICATION_ID => X_APPLICATION_ID,
        X_FLOW_FINALIZER_CLASS => X_FLOW_FINALIZER_CLASS,
        X_RETURN_TO_PAGE_ID => t_return_to_id,
        X_BASE_FLOW_FLAG => X_BASE_FLOW_FLAG,
--        X_ENABLED_CLONE_FLAG => X_ENABLED_CLONE_FLAG,
        X_OBJECT_VERSION_NUMBER => 1,
        X_LOGICAL_FLOW_DESCRIPTION => X_LOGICAL_FLOW_DESCRIPTION,
        X_CREATION_DATE => sysdate,
        X_CREATED_BY => t_user,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => t_user,
        X_LAST_UPDATE_LOGIN => 0);

      -- if there's exactly one row with a flow wit this appid/flowname,
      -- then make sure that row has enabled_clone_flag = 'T'
      select count(*) into l_counter from jtf_dpf_logical_flows_b
        where application_id = x_application_id and
	  logical_flow_name = x_logical_flow_name;
      if l_counter = 1 then
        update jtf_dpf_logical_flows_b set
	  enabled_clone_flag = 'T'
          where application_id = x_application_id and
	    logical_flow_name = x_logical_flow_name;
      end if;
    else
      update_row(
        X_LOGICAL_FLOW_ID => l_flow_id,
        X_LOGICAL_FLOW_HEAD_ID => t_header_id,
        X_LOGICAL_FLOW_NAME => X_LOGICAL_FLOW_NAME,
        X_SECURE_FLOW_FLAG => X_SECURE_FLOW_FLAG,
        X_VALIDATE_FLAG => X_VALIDATE_FLAG,
        X_APPLICATION_ID => X_APPLICATION_ID,
        X_FLOW_FINALIZER_CLASS => X_FLOW_FINALIZER_CLASS,
        X_RETURN_TO_PAGE_ID => t_return_to_id,
        X_BASE_FLOW_FLAG => X_BASE_FLOW_FLAG,
      --  X_ENABLED_CLONE_FLAG => X_ENABLED_CLONE_FLAG,
        X_OBJECT_VERSION_NUMBER => 1,
        X_LOGICAL_FLOW_DESCRIPTION => X_LOGICAL_FLOW_DESCRIPTION,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => t_user,
        X_LAST_UPDATE_LOGIN => 0);
    end if;
  end;

  procedure ins_upd_or_ign_lgcl_next_rules(
    x_rule_eval_seq varchar2,
    x_default_next_flag varchar2,
    x_logical_flow_application_id varchar2,
    x_logical_flow_name varchar2,
    x_logical_page_application_id varchar2,
    x_logical_page_name varchar2,
    x_logical_next_page_app_id varchar2,
    x_logical_next_page_name varchar2,
    x_rule_application_id varchar2,
    x_rule_name varchar2,
    x_owner varchar2,
    x_force_update_flag varchar2
  ) is
    l_user_id number := 0;
    l_rule_id number;
    l_logical_id number;
    l_next_logical_id number;
    l_flow_id number;
    l_lnrid number;
    l_last_updated_by number;
    cursor another_default(x_flow_id number, x_logical_id number) is
      select logical_next_rule_id
	from jtf_dpf_lgcl_next_rules
	where logical_flow_id = x_flow_id and
	  logical_page_id = x_logical_id and
	  default_next_flag='T';
    cursor another_non_default(x_flow_id number, x_logical_id number,
	x_seq number) is
      select logical_next_rule_id
	from jtf_dpf_lgcl_next_rules
	where logical_flow_id = x_flow_id and
	  logical_page_id = x_logical_id and
	  default_next_flag='F' and
	  rule_eval_seq = x_seq;
  begin
    if x_owner = 'SEED' then l_user_id := 1; end if;

    -- get ids for: the flow, the starting logical, the next logical,
    -- and the rule_id
    l_logical_id := jtf_dpf_logical_pages_pkg.find(
      x_logical_page_name, x_logical_page_application_id);
    l_next_logical_id := jtf_dpf_logical_pages_pkg.find(
      x_logical_next_page_name, x_logical_next_page_app_id);
    l_rule_id := jtf_dpf_rules_pkg.find(
      x_rule_name, x_rule_application_id);
    l_flow_id := jtf_dpf_logical_flows_pkg.find_oldest_prefer_owned_by(
      x_logical_flow_name, x_logical_flow_application_id, l_user_id);

    -- if we weren't called with force_update_flag='TRUE', and if
    -- the flow in question is not owned by us, then just return
    -- without doing anything
    if x_force_update_flag is null and x_force_update_flag <> 'TRUE' then
      select last_updated_by into l_last_updated_by
        from jtf_dpf_logical_flows_b where logical_flow_id = l_flow_id;
      if l_last_updated_by <> l_user_id then return; end if;
    end if;

    -- try to find a row which matches this one (to see whether we should
    -- do an UPDATE rather than an INSERT).  If there's such a row, then
    -- l_lnrid will be the LOGICAL_NEXT_RULE_ID from table
    -- JTF_DPF_LGCL_NEXT_RULES.
    if 'T' = x_default_next_flag then
      -- if there's already a default...
      open another_default(l_flow_id, l_logical_id);
      fetch another_default into l_lnrid;
      close another_default;
    else
      -- if there's already a non-default...
      open another_non_default(l_flow_id, l_logical_id, x_rule_eval_seq);
      fetch another_non_default into l_lnrid;
      close another_non_default;
    end if;

    if l_lnrid is not null then
      update jtf_dpf_lgcl_next_rules set
	LOGICAL_PAGE_ID = l_logical_id,
	LOGICAL_NEXT_PAGE_ID = l_next_logical_id,
	DEFAULT_NEXT_FLAG = x_default_next_flag,
	RULE_EVAL_SEQ = x_rule_eval_seq,
	LOGICAL_FLOW_ID = l_flow_id,
	RULE_ID = l_rule_id,
		OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
		LAST_UPDATE_DATE = sysdate,
		LAST_UPDATED_BY = l_user_id,
		LAST_UPDATE_LOGIN = 0
        where logical_next_rule_id = l_lnrid;
    else
      -- arsingh: prevent use of same id by different threads.
      select JTF_DPF_LGCL_NXT_RULES_S.nextval into l_lnrid from dual;
      -- select max(logical_next_rule_id) into l_lnrid
      --   from jtf_dpf_lgcl_next_rules where
      --   logical_next_rule_id < 10000;
      -- if l_lnrid is null then
      --   l_lnrid := 1;
      -- else
      --   l_lnrid := l_lnrid + 1;
      -- end if;

      insert into jtf_dpf_lgcl_next_rules (
	LOGICAL_NEXT_RULE_ID,
	LOGICAL_PAGE_ID,
	LOGICAL_NEXT_PAGE_ID,
	DEFAULT_NEXT_FLAG,
	RULE_EVAL_SEQ,
	LOGICAL_FLOW_ID,
	RULE_ID,
		OBJECT_VERSION_NUMBER,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN)
    values (
	l_lnrid,
	l_logical_id,
	l_next_logical_id,
	x_default_next_flag,
	x_rule_eval_seq,
	l_flow_id,
	l_rule_id,
		1,
		l_user_id,
		sysdate,
		sysdate,
		l_user_id,
		0);
    end if;
  end;
end JTF_DPF_LOGICAL_FLOWS_PKG;

/

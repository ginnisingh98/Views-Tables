--------------------------------------------------------
--  DDL for Package Body JTF_DPF_LOGICAL_PAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DPF_LOGICAL_PAGES_PKG" as
/* $Header: jtfdpflb.pls 120.2 2005/10/25 05:17:14 psanyal ship $ */
    -- select instances of this rule, identified by appid and name
  cursor get_logical_id(
	x_logical_page_name varchar2,
	x_application_id number) is select logical_page_id
    from jtf_dpf_logical_pages_b
    where application_id = x_application_id and
      logical_page_name=x_logical_page_name;

procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_LOGICAL_PAGE_ID in NUMBER,
  X_LOGICAL_PAGE_NAME in VARCHAR2,
  X_LOGICAL_PAGE_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_PAGE_CONTROLLER_CLASS in VARCHAR2,
  X_PAGE_PERMISSION_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LOGICAL_PAGE_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_DPF_LOGICAL_PAGES_B
    where LOGICAL_PAGE_ID = X_LOGICAL_PAGE_ID
    ;
begin
  insert into JTF_DPF_LOGICAL_PAGES_B (
    LOGICAL_PAGE_ID,
    LOGICAL_PAGE_NAME,
    LOGICAL_PAGE_TYPE,
    APPLICATION_ID,
    ENABLED_FLAG,
    PAGE_CONTROLLER_CLASS,
    PAGE_PERMISSION_NAME,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_LOGICAL_PAGE_ID,
    X_LOGICAL_PAGE_NAME,
    X_LOGICAL_PAGE_TYPE,
    X_APPLICATION_ID,
    X_ENABLED_FLAG,
    X_PAGE_CONTROLLER_CLASS,
    X_PAGE_PERMISSION_NAME,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_DPF_LOGICAL_PAGES_TL (
    LOGICAL_PAGE_ID,
    LOGICAL_PAGE_DESCRIPTION,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LOGICAL_PAGE_ID,
    X_LOGICAL_PAGE_DESCRIPTION,
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
    from JTF_DPF_LOGICAL_PAGES_TL T
    where T.LOGICAL_PAGE_ID = X_LOGICAL_PAGE_ID
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
  X_LOGICAL_PAGE_ID in NUMBER,
  X_LOGICAL_PAGE_NAME in VARCHAR2,
  X_LOGICAL_PAGE_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_PAGE_CONTROLLER_CLASS in VARCHAR2,
  X_PAGE_PERMISSION_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LOGICAL_PAGE_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      LOGICAL_PAGE_NAME,
      LOGICAL_PAGE_TYPE,
      APPLICATION_ID,
      ENABLED_FLAG,
      PAGE_CONTROLLER_CLASS,
      PAGE_PERMISSION_NAME,
      OBJECT_VERSION_NUMBER
    from JTF_DPF_LOGICAL_PAGES_B
    where LOGICAL_PAGE_ID = X_LOGICAL_PAGE_ID
    for update of LOGICAL_PAGE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      LOGICAL_PAGE_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_DPF_LOGICAL_PAGES_TL
    where LOGICAL_PAGE_ID = X_LOGICAL_PAGE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of LOGICAL_PAGE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.LOGICAL_PAGE_NAME = X_LOGICAL_PAGE_NAME)
      AND ((recinfo.LOGICAL_PAGE_TYPE = X_LOGICAL_PAGE_TYPE)
           OR ((recinfo.LOGICAL_PAGE_TYPE is null) AND (X_LOGICAL_PAGE_TYPE is null)))
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND ((recinfo.PAGE_CONTROLLER_CLASS = X_PAGE_CONTROLLER_CLASS)
           OR ((recinfo.PAGE_CONTROLLER_CLASS is null) AND (X_PAGE_CONTROLLER_CLASS is null)))
      AND ((recinfo.PAGE_PERMISSION_NAME = X_PAGE_PERMISSION_NAME)
           OR ((recinfo.PAGE_PERMISSION_NAME is null) AND (X_PAGE_PERMISSION_NAME is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.LOGICAL_PAGE_DESCRIPTION = X_LOGICAL_PAGE_DESCRIPTION)
               OR ((tlinfo.LOGICAL_PAGE_DESCRIPTION is null) AND (X_LOGICAL_PAGE_DESCRIPTION is null)))
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
  X_LOGICAL_PAGE_ID in NUMBER,
  X_LOGICAL_PAGE_NAME in VARCHAR2,
  X_LOGICAL_PAGE_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_PAGE_CONTROLLER_CLASS in VARCHAR2,
  X_PAGE_PERMISSION_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LOGICAL_PAGE_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_DPF_LOGICAL_PAGES_B set
    LOGICAL_PAGE_NAME = X_LOGICAL_PAGE_NAME,
    LOGICAL_PAGE_TYPE = X_LOGICAL_PAGE_TYPE,
    APPLICATION_ID = X_APPLICATION_ID,
    ENABLED_FLAG = X_ENABLED_FLAG,
    PAGE_CONTROLLER_CLASS = X_PAGE_CONTROLLER_CLASS,
    PAGE_PERMISSION_NAME = X_PAGE_PERMISSION_NAME,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where LOGICAL_PAGE_ID = X_LOGICAL_PAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_DPF_LOGICAL_PAGES_TL set
    LOGICAL_PAGE_DESCRIPTION = X_LOGICAL_PAGE_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where LOGICAL_PAGE_ID = X_LOGICAL_PAGE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LOGICAL_PAGE_ID in NUMBER
) is
begin
  delete from JTF_DPF_LOGICAL_PAGES_TL
  where LOGICAL_PAGE_ID = X_LOGICAL_PAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_DPF_LOGICAL_PAGES_B
  where LOGICAL_PAGE_ID = X_LOGICAL_PAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_DPF_LOGICAL_PAGES_TL T
  where not exists
    (select NULL
    from JTF_DPF_LOGICAL_PAGES_B B
    where B.LOGICAL_PAGE_ID = T.LOGICAL_PAGE_ID
    );

  update JTF_DPF_LOGICAL_PAGES_TL T set (
      LOGICAL_PAGE_DESCRIPTION
    ) = (select
      B.LOGICAL_PAGE_DESCRIPTION
    from JTF_DPF_LOGICAL_PAGES_TL B
    where B.LOGICAL_PAGE_ID = T.LOGICAL_PAGE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LOGICAL_PAGE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.LOGICAL_PAGE_ID,
      SUBT.LANGUAGE
    from JTF_DPF_LOGICAL_PAGES_TL SUBB, JTF_DPF_LOGICAL_PAGES_TL SUBT
    where SUBB.LOGICAL_PAGE_ID = SUBT.LOGICAL_PAGE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.LOGICAL_PAGE_DESCRIPTION <> SUBT.LOGICAL_PAGE_DESCRIPTION
      or (SUBB.LOGICAL_PAGE_DESCRIPTION is null and SUBT.LOGICAL_PAGE_DESCRIPTION is not null)
      or (SUBB.LOGICAL_PAGE_DESCRIPTION is not null and SUBT.LOGICAL_PAGE_DESCRIPTION is null)
  ));

  insert into JTF_DPF_LOGICAL_PAGES_TL (
    LOGICAL_PAGE_ID,
    LOGICAL_PAGE_DESCRIPTION,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LOGICAL_PAGE_ID,
    B.LOGICAL_PAGE_DESCRIPTION,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_DPF_LOGICAL_PAGES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_DPF_LOGICAL_PAGES_TL T
    where T.LOGICAL_PAGE_ID = B.LOGICAL_PAGE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

  procedure TRANSLATE_ROW (
    X_LOGICAL_PAGE_NAME IN VARCHAR2,
    X_APPLICATION_ID IN VARCHAR2,
    X_LOGICAL_PAGE_DESCRIPTION IN VARCHAR2,
    X_OWNER IN VARCHAR2
  ) is
    l_lid number;
    l_user_id number;
  begin
    l_user_id := 0;
    if x_owner = 'SEED' then l_user_id := 1; end if;

    l_lid := find(x_logical_page_name, x_application_id);
    update jtf_dpf_logical_pages_tl set
	logical_page_description = x_logical_page_description,
	last_updated_by = l_user_id,
	last_update_date = sysdate,
	last_update_login = 0,
	source_lang = userenv('LANG')
      where userenv('LANG') in (LANGUAGE, SOURCE_LANG) and
        logical_page_id = l_lid;
  end;

  procedure ceiling_lgcl_phy(
    X_LOGICAL_PAGE_NAME VARCHAR2,
    X_APPLICATION_ID VARCHAR2,
    X_NUM_NON_DEF_RULES VARCHAR2,
    X_OWNER VARCHAR2,
    X_FORCE_UPDATE_FLAG VARCHAR2) is
    l_do_it boolean := false;
    l_logical_page_id number;
    l_user number;
    l_owner_of_l2p number;
  begin
    l_user := 0;
    if x_owner = 'SEED' then l_user := 1; end if;

    -- figure which logical_id we're talking about
    l_logical_page_id := find(x_logical_page_name, x_application_id);

    -- if we're forced to, then do it!
    if x_force_update_flag = 'TRUE' then l_do_it := true; end if;

    -- if we haven't yet decided whether to do it, see whether we own the
    -- default l2p row in lgcl_phy table
    if not l_do_it then
      begin
        select last_updated_by into l_owner_of_l2p
          from jtf_dpf_lgcl_phy_rules
          where logical_page_id = l_logical_page_id and
	    default_page_flag = 'T';
        if l_owner_of_l2p = l_user then l_do_it := true; end if;
       exception when no_data_found then return;
      end;
    end if;

    -- if we've decided to do it,...
    if l_do_it then
      -- delete the rows, if any...
      delete from jtf_dpf_lgcl_phy_rules
        where logical_page_id = l_logical_page_id and
	  default_page_flag = 'F' and
	  rule_eval_sequence > x_num_non_def_rules;
    end if;
  end;

  procedure LOAD_ROW (
    X_LOGICAL_PAGE_NAME in VARCHAR2,
    X_APPLICATION_ID in VARCHAR2,
    X_LOGICAL_PAGE_DESCRIPTION  in VARCHAR2,
--    X_NUM_NON_DEF_RULES IN VARCHAR2,
    X_LOGICAL_PAGE_TYPE IN VARCHAR2,
    X_ENABLED_FLAG IN VARCHAR2,
    X_PAGE_CONTROLLER_CLASS IN VARCHAR2,
    X_PAGE_PERMISSION_NAME IN VARCHAR2,
    X_OWNER in VARCHAR2
  ) is

    t_old_logical_id number;
    t_new_logical_id number;
    t_rowid rowid;
    t_user number;
  begin
    t_user := 0;
    if x_owner = 'SEED' then t_user := 1; end if;

    -- see whether a row with this appid and logical_page_name already exists
    open get_logical_id(x_logical_page_name, x_application_id);
    fetch get_logical_id into t_old_logical_id;

    -- if it's not already there
    if get_logical_id%notfound then
      close get_logical_id;

      -- get a new pseudo-sequence number
      -- arsingh: prevent use of same id by different threads.
      select JTF_DPF_LOGICAL_PAGES_S.nextval into t_new_logical_id from dual;
      -- select max(logical_page_id) into t_new_logical_id
      --   from jtf_dpf_logical_pages_b
      --   where logical_page_id < 10000;
      -- if t_new_logical_id is null then
      --   t_new_logical_id := 1;
      -- else
      --   t_new_logical_id := t_new_logical_id+1;
      -- end if;

      -- call _pkg.insert_row to handle _b and _tl tables
      insert_row(
	X_ROWID				=> t_rowid,
	X_LOGICAL_PAGE_ID		=> t_new_logical_id,
	X_LOGICAL_PAGE_NAME		=> x_logical_page_name,
	X_LOGICAL_PAGE_TYPE		=> x_logical_page_type,
	X_APPLICATION_ID		=> x_application_id,
	X_ENABLED_FLAG			=> x_enabled_flag,
	X_PAGE_CONTROLLER_CLASS		=> x_page_controller_class,
	X_PAGE_PERMISSION_NAME		=> x_page_permission_name,
	X_OBJECT_VERSION_NUMBER		=> 1,
	X_LOGICAL_PAGE_DESCRIPTION	=> x_logical_page_description,
	X_CREATION_DATE			=> sysdate,
	X_CREATED_BY			=> t_user,
	X_LAST_UPDATE_DATE		=> sysdate,
	X_LAST_UPDATED_BY		=> t_user,
	X_LAST_UPDATE_LOGIN		=> 0
      );
    else
      close get_logical_id;

      -- call _pkg.update_row to handle _b and _tl tables
      update_row(
	X_LOGICAL_PAGE_ID		=> t_old_logical_id,
	X_LOGICAL_PAGE_NAME		=> x_logical_page_name,
	X_LOGICAL_PAGE_TYPE		=> x_logical_page_type,
	X_APPLICATION_ID		=> x_application_id,
	X_ENABLED_FLAG			=> x_enabled_flag,
	X_PAGE_CONTROLLER_CLASS		=> x_page_controller_class,
	X_PAGE_PERMISSION_NAME		=> x_page_permission_name,
	X_OBJECT_VERSION_NUMBER		=> 1,
	X_LOGICAL_PAGE_DESCRIPTION	=> x_logical_page_description,
	X_LAST_UPDATE_DATE		=> sysdate,
	X_LAST_UPDATED_BY		=> t_user,
	X_LAST_UPDATE_LOGIN		=> 0
      );
    end if;
  end;

  function find(
    x_logical_page_name varchar2,
    x_application_id in varchar2
  ) return number is
    retval number := null;
  begin
    open get_logical_id(x_logical_page_name, x_application_id);
    fetch get_logical_id into retval;
    close get_logical_id;
    return retval;
  end;

  procedure ins_upd_or_ign_lgcl_phy_rules(
    x_rule_eval_sequence		varchar2,
    x_default_page_flag			varchar2,
    x_logical_page_application_id	varchar2,
    x_logical_page_name			varchar2,
    x_physical_page_application_id	varchar2,
    x_physical_page_name		varchar2,
    x_rule_application_id		varchar2,
    x_rule_name				varchar2,
    x_owner				varchar2,
    x_force_update_flag			varchar2) is
    l_last_updated_by number;
    l_logical_id number := null;
    l_physical_id number := null;
    l_rule_id number := null;
    l_lpid number := null;
    t_new_lpid number := null;
    l_is_update varchar2(1);
    l_user_id number;
    l_owner_of_l2p number;
    l_do_it boolean := false;
    cursor another_default(p_logical_page_id number) is
      select logical_physical_id
	from jtf_dpf_lgcl_phy_rules
	where logical_page_id=p_logical_page_id and
	  default_page_flag='T';
    cursor another_non_default(p_logical_page_id number, p_seq number) is
      select logical_physical_id
	from jtf_dpf_lgcl_phy_rules
	where logical_page_id=p_logical_page_id and
	  default_page_flag='F' and
	  rule_eval_sequence = p_seq;
  begin
    l_user_id := 0;
    if x_owner = 'SEED' then l_user_id := 1; end if;

    -- get the logical_id that corresponds to this
    l_logical_id := find(x_logical_page_name, x_logical_page_application_id);
    l_rule_id := jtf_dpf_rules_pkg.find(x_rule_name, x_rule_application_id);
    l_physical_id := jtf_dpf_physical_pages_pkg.find_oldest_prefer_owned_by(
	x_physical_page_name, x_physical_page_application_id, l_user_id);

    -- if we're forced to, then do it!
    if x_force_update_flag = 'TRUE' then l_do_it := true; end if;

    -- if we haven't yet decided whether to do it, see whether we own the
    -- default l2p row in lgcl_phy table
    if not l_do_it then
      begin
        select last_updated_by into l_owner_of_l2p
          from jtf_dpf_lgcl_phy_rules
          where logical_page_id = l_logical_id and
	    default_page_flag = 'T';
        if l_owner_of_l2p = l_user_id then l_do_it := true; end if;
       exception when no_data_found then l_do_it := true;
      end;
    end if;

    -- if we've decided not to do it, then just return
    if not l_do_it then return; end if;

    -- try to find a row which matches this one (to see whether we should
    -- do an UPDATE rather than an INSERT). If there's such a row, then
    -- l_lpid will be the LOGICAL_PHYSICAL_ID of that row, else it'll remain
    -- null.
    if 'T' = x_default_page_flag then
      -- if there's already a default
      open another_default(l_logical_id);
      fetch another_default into l_lpid;
      close another_default;
    -- else handle non-default row
    else
      open another_non_default(l_logical_id, x_rule_eval_sequence);
      fetch another_non_default into l_lpid;
      close another_non_default;
    end if;

    -- if there's no such row, then do an insert.

    if l_lpid is null then
      -- get a new logical_physical_id (pseudo-sequence)
      -- arsingh: prevent use of same id by different threads.
      select JTF_DPF_LGCL_PHY_RULES_S.nextval into t_new_lpid from dual;
      -- select max(logical_physical_id) into t_new_lpid
      --   from jtf_dpf_lgcl_phy_rules where logical_physical_id < 10000;
      -- if t_new_lpid is null then
      --  t_new_lpid := 1;
      -- else
      --  t_new_lpid := t_new_lpid  + 1;
      -- end if;
      -- insert a new row

      insert into jtf_dpf_lgcl_phy_rules(
	logical_physical_id,
	logical_page_id,
	rule_eval_sequence,
	default_page_flag,
	physical_page_id,
	rule_id,
		object_version_number,
		created_by,
		creation_date,
		last_update_date,
		last_updated_by,
		last_update_login)
      values (
	t_new_lpid,
	l_logical_id,
	x_rule_eval_sequence,
	x_default_page_flag,
	l_physical_id,
	l_rule_id,
	1,
	l_user_id,
	sysdate,
	sysdate,
	l_user_id,
	0);
    else
      -- if there is such as row, and we either own it, or FORCE_UPDATE_FLAG
      -- is true, then update it. else do nothing
      select last_updated_by into l_last_updated_by
	from jtf_dpf_lgcl_phy_rules
        where logical_physical_id = l_lpid;
      if l_last_updated_by = l_user_id or
	  x_force_update_flag = 'TRUE' then
        update jtf_dpf_lgcl_phy_rules set
	  physical_page_id = l_physical_id,
	  rule_id = l_rule_id,
		object_version_number = object_version_number +1,
		last_update_date = sysdate,
		last_updated_by = l_user_id,
		last_update_login = 0
        where logical_physical_id = l_lpid;
      end if;
    end if;
  end;

end JTF_DPF_LOGICAL_PAGES_PKG;

/

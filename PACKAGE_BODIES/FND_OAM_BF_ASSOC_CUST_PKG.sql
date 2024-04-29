--------------------------------------------------------
--  DDL for Package Body FND_OAM_BF_ASSOC_CUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_BF_ASSOC_CUST_PKG" as
/* $Header: AFOAMFACB.pls 120.1 2005/07/02 03:03:16 appldev noship $ */
  -- Module name for this package
  MODULE constant varchar2(200) := 'fnd.plsql.FND_OAM_BF_ASSOC_CUST_PKG';

  --
  -- Name
  --  check_loop
  --
  -- Purpose
  --  Checks if adding the given subflow as a child of the given
  --  parent flow could cause a potential loop. An exception is
  --  raised if a possible loop could result
  --
  -- Input Arguments
  --  x_biz_flow_parent_key - parent flow key
  --  x_biz_flow_child_key  - key for the flow to be added as child.
  --
  -- Output Arguments
  --
  -- Notes:
  --
  procedure check_loop (
    X_BIZ_FLOW_PARENT_KEY in VARCHAR2,
    X_BIZ_FLOW_CHILD_KEY in VARCHAR2)
  is
  	v_ct_ancestors number := 0;
	v_msg varchar2(1024) := '';
  begin
	select count(*) into v_ct_ancestors
	from fnd_oam_bf_assoc_cust a
	where a.biz_flow_parent_key = X_BIZ_FLOW_CHILD_KEY
	start with a.biz_flow_child_key = X_BIZ_FLOW_PARENT_KEY
	connect by prior a.biz_flow_parent_key = a.biz_flow_child_key;

	if v_ct_ancestors > 0 or X_BIZ_FLOW_PARENT_KEY = X_BIZ_FLOW_CHILD_KEY then
		v_msg := 'Cannot add ' || X_BIZ_FLOW_CHILD_KEY ||	' as a child of ' || X_BIZ_FLOW_PARENT_KEY || ' as ' || X_BIZ_FLOW_CHILD_KEY || ' is already an ancestor of ' || X_BIZ_FLOW_PARENT_KEY || '.';
		if (fnd_log.level_error >= fnd_log.g_current_runtime_level) then
			fnd_log.string(log_level=>fnd_log.level_error,
		      	  module=>MODULE||'.raise_alert',
		      	  message=>v_msg);
		end if;
		raise_application_error(-20500, v_msg);
	end if;
  exception
	when no_data_found then
		null;
	when others then
		raise;
  end check_loop;

  --
  -- Name
  --   load_row
  --
  -- Purpose
  --   Loads the association between a parent flow and a child flow
  --   into the database. This procedure will be called by the
  --   OAM Business Flows Definition Loader program.
  --
  -- Input Arguments
  --	x_biz_flow_parent_key - parent flow key. Pass in ROOT_KEY for
  --      flows that are top level that dont have a parent.
  --    x_biz_flow_child_key - child flow key.
  --    x_monitored_flag - Y/N - whether the child flow is active in
  --      context of its parent.
  --    x_owner - owner e.g. ORACLE
  -- Output Arguments
  --
  -- Notes:
  --
  --
procedure LOAD_ROW (
    X_BIZ_FLOW_PARENT_KEY in VARCHAR2,
    X_BIZ_FLOW_CHILD_KEY in VARCHAR2,
    X_MONITORED_FLAG in VARCHAR2,
    X_DISPLAY_ORDER in NUMBER,
    X_OWNER in VARCHAR2)
is
begin
   FND_OAM_BF_ASSOC_CUST_pkg.LOAD_ROW (
       X_BIZ_FLOW_PARENT_KEY => X_BIZ_FLOW_PARENT_KEY,
       X_BIZ_FLOW_CHILD_KEY => X_BIZ_FLOW_CHILD_KEY,
       X_MONITORED_FLAG => X_MONITORED_FLAG,
       X_DISPLAY_ORDER => X_DISPLAY_ORDER,
       X_OWNER => X_OWNER,
       x_custom_mode => '',
       x_last_update_date => '');
end LOAD_ROW;

procedure LOAD_ROW (
    X_BIZ_FLOW_PARENT_KEY in VARCHAR2,
    X_BIZ_FLOW_CHILD_KEY in VARCHAR2,
    X_MONITORED_FLAG in VARCHAR2,
    X_DISPLAY_ORDER in NUMBER,
    X_OWNER in VARCHAR2,
    x_custom_mode         in      varchar2,
    x_last_update_date    in      varchar2)
is
      row_id varchar2(64);
      f_luby    number;  -- entity owner in file
      f_ludate  date;    -- entity update date in file
      db_luby   number;  -- entity owner in db
      db_ludate date;    -- entity update date in db
begin
      -- Translate owner to file_last_updated_by
      f_luby := fnd_load_util.owner_id(x_owner);

      -- Translate char last_update_date to date
      f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

      begin
        select LAST_UPDATED_BY, LAST_UPDATE_DATE
        into db_luby, db_ludate
        from   FND_OAM_BF_ASSOC_CUST
        where  biz_flow_parent_key = X_BIZ_FLOW_PARENT_KEY
        and  biz_flow_child_key = X_BIZ_FLOW_CHILD_KEY;

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
        FND_OAM_BF_ASSOC_CUST_pkg.UPDATE_ROW (
          X_BIZ_FLOW_PARENT_KEY => X_BIZ_FLOW_PARENT_KEY,
          X_BIZ_FLOW_CHILD_KEY => X_BIZ_FLOW_CHILD_KEY,
          X_MONITORED_FLAG => X_MONITORED_FLAG,
	  X_DISPLAY_ORDER => X_DISPLAY_ORDER,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_LOGIN => 0 );
        end if;
      exception
        when NO_DATA_FOUND then

        FND_OAM_BF_ASSOC_CUST_pkg.INSERT_ROW (
          X_ROWID => row_id,
          X_BIZ_FLOW_PARENT_KEY => X_BIZ_FLOW_PARENT_KEY,
          X_BIZ_FLOW_CHILD_KEY => X_BIZ_FLOW_CHILD_KEY,
          X_MONITORED_FLAG => X_MONITORED_FLAG,
	  X_DISPLAY_ORDER => X_DISPLAY_ORDER,
          X_CREATION_DATE => f_ludate,
          X_CREATED_BY => f_luby,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_LOGIN => 0 );
    end;
END LOAD_ROW;

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_BIZ_FLOW_PARENT_KEY in VARCHAR2,
  X_BIZ_FLOW_CHILD_KEY in VARCHAR2,
  X_MONITORED_FLAG in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER)
is
  cursor C is select ROWID from FND_OAM_BF_ASSOC_CUST
    where BIZ_FLOW_PARENT_KEY = X_BIZ_FLOW_PARENT_KEY
    and biz_flow_child_key = x_biz_flow_child_key;
begin
  check_loop(
    X_BIZ_FLOW_PARENT_KEY,
    X_BIZ_FLOW_CHILD_KEY);

  insert into FND_OAM_BF_ASSOC_CUST (
    BIZ_FLOW_PARENT_KEY,
    BIZ_FLOW_CHILD_KEY,
    MONITORED_FLAG,
    DISPLAY_ORDER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_BIZ_FLOW_PARENT_KEY,
    X_BIZ_FLOW_CHILD_KEY,
    X_MONITORED_FLAG,
    X_DISPLAY_ORDER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
end INSERT_ROW;

procedure UPDATE_ROW (
  X_BIZ_FLOW_PARENT_KEY in VARCHAR2,
  X_BIZ_FLOW_CHILD_KEY in VARCHAR2,
  X_MONITORED_FLAG in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_OAM_BF_ASSOC_CUST set
    monitored_flag = x_monitored_flag,
    display_order = x_display_order,
    last_update_date = x_last_update_date,
    last_updated_by = x_last_updated_by,
    last_update_login = x_last_update_login
  where biz_flow_parent_key = x_biz_flow_parent_key
  and biz_flow_child_key = x_biz_flow_child_key;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_BIZ_FLOW_PARENT_KEY in VARCHAR2,
  X_BIZ_FLOW_CHILD_KEY in VARCHAR2
) is
begin
  delete from FND_OAM_BF_ASSOC_CUST
  where biz_flow_parent_key = x_biz_flow_parent_key
  and biz_flow_child_key = x_biz_flow_child_key;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end FND_OAM_BF_ASSOC_CUST_PKG;

/

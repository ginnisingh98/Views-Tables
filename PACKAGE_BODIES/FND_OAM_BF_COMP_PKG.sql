--------------------------------------------------------
--  DDL for Package Body FND_OAM_BF_COMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_BF_COMP_PKG" as
/* $Header: AFOAMFPB.pls 120.1 2005/07/02 03:03:48 appldev noship $ */


procedure LOAD_ROW (
    X_BIZ_FLOW_KEY in VARCHAR2,
    X_COMPONENT_TYPE in VARCHAR2,
    X_COMPONENT_APPL_SHORT_NAME in VARCHAR2,
    X_COMPONENT_NAME in VARCHAR,
    X_MONITORED_FLAG in VARCHAR2,
    X_DISPLAY_ORDER in NUMBER,
    X_OWNER in VARCHAR2)
is
begin
  fnd_oam_bf_comp_pkg.LOAD_ROW(
	X_BIZ_FLOW_KEY => X_BIZ_FLOW_KEY,
	X_COMPONENT_TYPE => X_COMPONENT_TYPE,
	X_COMPONENT_APPL_SHORT_NAME => X_COMPONENT_APPL_SHORT_NAME,
	X_COMPONENT_NAME => X_COMPONENT_NAME,
	X_MONITORED_FLAG => X_MONITORED_FLAG,
	X_DISPLAY_ORDER => X_DISPLAY_ORDER,
	X_OWNER => X_OWNER,
	X_CUSTOM_MODE => '',
	X_LAST_UPDATE_DATE => '');
end LOAD_ROW;

procedure LOAD_ROW (
    X_BIZ_FLOW_KEY in VARCHAR2,
    X_COMPONENT_TYPE in VARCHAR2,
    X_COMPONENT_APPL_SHORT_NAME in VARCHAR2,
    X_COMPONENT_NAME in VARCHAR2,
    X_MONITORED_FLAG in VARCHAR2,
    X_DISPLAY_ORDER in NUMBER,
    X_OWNER in VARCHAR2,
    x_custom_mode         in      varchar2,
    x_last_update_date    in      varchar2)
is
  v_component_appl_id number;
  v_component_id number;
begin
  begin
   if (x_component_type = 'FUNCTION') then
	v_component_appl_id := -1;
   else
	select application_id into v_component_appl_id
    		from fnd_application
    		where application_short_name = X_COMPONENT_APPL_SHORT_NAME;
   end if;


   select component_id into v_component_id
    from fnd_app_components_vl
    where component_type = X_COMPONENT_TYPE
    and application_id = v_component_appl_id
    and component_name = X_COMPONENT_NAME;
  exception
--    when no_data_found then
--	null;
--	return;
    when others then
	raise;
  end;

  fnd_oam_bf_comp_pkg.LOAD_ROW(
	X_BIZ_FLOW_KEY => X_BIZ_FLOW_KEY,
	X_COMPONENT_TYPE => X_COMPONENT_TYPE,
	X_COMPONENT_APPL_ID => v_component_appl_id,
	X_COMPONENT_ID => v_component_id,
	X_MONITORED_FLAG => X_MONITORED_FLAG,
	X_DISPLAY_ORDER => X_DISPLAY_ORDER,
	X_OWNER => X_OWNER,
	X_CUSTOM_MODE => X_CUSTOM_MODE,
	X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE);
end LOAD_ROW;

procedure LOAD_ROW (
    X_BIZ_FLOW_KEY in VARCHAR2,
    X_COMPONENT_TYPE in VARCHAR2,
    X_COMPONENT_APPL_ID in NUMBER,
    X_COMPONENT_ID in NUMBER,
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
        from   fnd_oam_bf_comp
        where  biz_flow_key = X_BIZ_FLOW_KEY
        and  component_type = x_component_type
  	and component_appl_id = x_component_appl_id
  	and component_id = x_component_id;

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
        fnd_oam_bf_comp_pkg.UPDATE_ROW (
          X_BIZ_FLOW_KEY => X_BIZ_FLOW_KEY,
	  X_COMPONENT_TYPE => X_COMPONENT_TYPE,
   	  X_COMPONENT_APPL_ID => X_COMPONENT_APPL_ID,
	  X_COMPONENT_ID => X_COMPONENT_ID,
          X_MONITORED_FLAG => X_MONITORED_FLAG,
	  X_DISPLAY_ORDER => X_DISPLAY_ORDER,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_LOGIN => 0 );
        end if;
      exception
        when NO_DATA_FOUND then

        fnd_oam_bf_comp_pkg.INSERT_ROW (
          X_ROWID => row_id,
          X_BIZ_FLOW_KEY => X_BIZ_FLOW_KEY,
	  X_COMPONENT_TYPE => X_COMPONENT_TYPE,
   	  X_COMPONENT_APPL_ID => X_COMPONENT_APPL_ID,
	  X_COMPONENT_ID => X_COMPONENT_ID,
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
  X_BIZ_FLOW_KEY in VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_COMPONENT_APPL_ID in NUMBER,
  X_COMPONENT_ID in NUMBER,
  X_MONITORED_FLAG in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER)
is
  cursor C is select ROWID from FND_OAM_BF_COMP
    where BIZ_FLOW_KEY = X_BIZ_FLOW_KEY
    and component_type = x_component_type
    and component_appl_id = x_component_appl_id
    and component_id = x_component_id;
begin
  insert into fnd_oam_bf_comp (
    BIZ_FLOW_KEY,
    component_type,
    component_appl_id,
    component_id,
    MONITORED_FLAG,
    DISPLAY_ORDER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_BIZ_FLOW_KEY,
    X_COMPONENT_TYPE,
    X_COMPONENT_APPL_ID,
    X_COMPONENT_ID,
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
  X_BIZ_FLOW_KEY in VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_COMPONENT_APPL_ID in NUMBER,
  X_COMPONENT_ID in NUMBER,
  X_MONITORED_FLAG in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
)
is
begin
  update FND_OAM_BF_COMP set
    monitored_flag = x_monitored_flag,
    display_order = x_display_order,
    last_update_date = x_last_update_date,
    last_updated_by = x_last_updated_by,
    last_update_login = x_last_update_login
  where biz_flow_key = x_biz_flow_key
  and component_type = x_component_type
  and component_appl_id = x_component_appl_id
  and component_id = x_component_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_BIZ_FLOW_KEY in VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_COMPONENT_APPL_ID in NUMBER,
  X_COMPONENT_ID in NUMBER
)
is
begin
  delete from fnd_oam_bf_comp
  where biz_flow_key = x_biz_flow_key
  and component_type = x_component_type
  and component_appl_id = x_component_appl_id
  and component_id = x_component_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure DELETE_ROW (
  X_BIZ_FLOW_KEY in VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_COMPONENT_APPL_SHORT_NAME in VARCHAR2,
  X_COMPONENT_NAME in VARCHAR2
)
is
  v_component_appl_id number;
  v_component_id number;
begin
  begin
   select application_id into v_component_appl_id
    from fnd_application
    where application_short_name = X_COMPONENT_APPL_SHORT_NAME;

   select component_id into v_component_id
    from fnd_app_components_vl
    where component_type = X_COMPONENT_TYPE
    and application_id = v_component_appl_id
    and component_name = X_COMPONENT_NAME;
  exception
--    when no_data_found then
--	null;
--	return;
    when others then
	raise;
  end;

  fnd_oam_bf_comp_pkg.delete_row(
	X_BIZ_FLOW_KEY => X_BIZ_FLOW_KEY,
   	X_COMPONENT_TYPE => X_COMPONENT_TYPE,
	X_COMPONENT_APPL_ID => v_component_appl_id,
	X_COMPONENT_ID => v_component_id);
end DELETE_ROW;

end FND_OAM_BF_COMP_PKG;

/

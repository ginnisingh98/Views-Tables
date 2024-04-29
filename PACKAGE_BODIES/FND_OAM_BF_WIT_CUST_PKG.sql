--------------------------------------------------------
--  DDL for Package Body FND_OAM_BF_WIT_CUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_BF_WIT_CUST_PKG" as
/* $Header: AFOAMFWCB.pls 120.1 2005/07/02 03:04:15 appldev noship $ */


procedure LOAD_ROW (
    X_BIZ_FLOW_KEY in VARCHAR2,
    X_ITEM_TYPE in VARCHAR2,
    X_MONITORED_FLAG in VARCHAR2,
    X_DISPLAY_ORDER in NUMBER,
    X_OWNER in VARCHAR2)
is
begin
   FND_OAM_BF_WIT_CUST_pkg.LOAD_ROW (
       X_BIZ_FLOW_KEY => X_BIZ_FLOW_KEY,
       X_ITEM_TYPE => X_ITEM_TYPE,
       X_MONITORED_FLAG => X_MONITORED_FLAG,
       X_DISPLAY_ORDER => X_DISPLAY_ORDER,
       X_OWNER => X_OWNER,
       x_custom_mode => '',
       x_last_update_date => '');
end LOAD_ROW;

procedure LOAD_ROW (
    X_BIZ_FLOW_KEY in VARCHAR2,
    X_ITEM_TYPE in VARCHAR2,
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
        from   FND_OAM_BF_WIT_CUST
        where  biz_flow_key = X_BIZ_FLOW_KEY
        and  item_type = X_ITEM_TYPE;

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
        FND_OAM_BF_WIT_CUST_pkg.UPDATE_ROW (
          X_BIZ_FLOW_KEY => X_BIZ_FLOW_KEY,
          X_ITEM_TYPE => X_ITEM_TYPE,
          X_MONITORED_FLAG => X_MONITORED_FLAG,
  	  X_DISPLAY_ORDER => X_DISPLAY_ORDER,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_LOGIN => 0 );
        end if;
      exception
        when NO_DATA_FOUND then

        FND_OAM_BF_WIT_CUST_pkg.INSERT_ROW (
          X_ROWID => row_id,
	  X_BIZ_FLOW_KEY => X_BIZ_FLOW_KEY,
          X_ITEM_TYPE => X_ITEM_TYPE,
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
  X_ITEM_TYPE in VARCHAR2,
  X_MONITORED_FLAG in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER)
is
  cursor C is select ROWID from FND_OAM_BF_WIT_CUST
    where BIZ_FLOW_KEY = X_BIZ_FLOW_KEY
    and item_type = X_ITEM_TYPE;
begin
  insert into FND_OAM_BF_WIT_CUST (
    BIZ_FLOW_KEY,
    ITEM_TYPE,
    MONITORED_FLAG,
    DISPLAY_ORDER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_BIZ_FLOW_KEY,
    X_ITEM_TYPE,
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
  X_ITEM_TYPE in VARCHAR2,
  X_MONITORED_FLAG in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_OAM_BF_WIT_CUST set
    monitored_flag = x_monitored_flag,
    display_order = x_display_order,
    last_update_date = x_last_update_date,
    last_updated_by = x_last_updated_by,
    last_update_login = x_last_update_login
  where biz_flow_key = x_biz_flow_key
  and item_type = x_item_type;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_BIZ_FLOW_KEY in VARCHAR2,
  X_ITEM_TYPE in VARCHAR2
) is
begin
  delete from FND_OAM_BF_WIT_CUST
  where biz_flow_key = X_BIZ_FLOW_KEY
  and item_type = X_ITEM_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end FND_OAM_BF_WIT_CUST_PKG;

/

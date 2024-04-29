--------------------------------------------------------
--  DDL for Package Body FND_WEB_APPLICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_WEB_APPLICATION_PKG" AS
  /* $Header: AFSCWAPB.pls 120.0.12010000.2 2019/08/21 10:35:46 ssumaith noship $ */


 procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FAMILY_SHORT_NAME in VARCHAR2,
  X_IS_ENABLED in VARCHAR2,
  X_TXN_DATA in CLOB,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor c is select ROWID from FND_WEB_APPLICATION
    where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
    ;
begin
  insert into FND_WEB_APPLICATION (
    APPLICATION_SHORT_NAME,
	FAMILY_SHORT_NAME,
    IS_ENABLED,
	TXN_DATA,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
	X_APPLICATION_SHORT_NAME,
	X_FAMILY_SHORT_NAME,
	X_IS_ENABLED,
	X_TXN_DATA,
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

procedure LOCK_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FAMILY_SHORT_NAME in VARCHAR2,
  X_IS_ENABLED in VARCHAR2,
  X_TXN_DATA in CLOB
) is
  cursor c is select
    APPLICATION_SHORT_NAME,
	FAMILY_SHORT_NAME,
    IS_ENABLED,
	TXN_DATA
    from FND_WEB_APPLICATION
    where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
    for update of APPLICATION_SHORT_NAME nowait;
  recinfo c%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if ((recinfo.APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME)
      AND (((recinfo.FAMILY_SHORT_NAME is null) AND (X_FAMILY_SHORT_NAME is null)))
      AND (((recinfo.IS_ENABLED is null) AND (X_IS_ENABLED is null)))
	  AND (((recinfo.TXN_DATA is null) AND (X_TXN_DATA is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FAMILY_SHORT_NAME in VARCHAR2,
  X_IS_ENABLED in VARCHAR2,
  X_TXN_DATA in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_WEB_APPLICATION set
    IS_ENABLED = X_IS_ENABLED,
	TXN_DATA = X_TXN_DATA,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2
) is
begin

  delete from FND_WEB_APPLICATION
  where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


procedure LOAD_ROW (
  X_OWNER in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FAMILY_SHORT_NAME in VARCHAR2,
  X_IS_ENABLED in VARCHAR2,
  X_TXN_DATA in CLOB,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
 ) is
	f_luby    number;  -- entity owner in file
	f_ludate  date;    -- entity update date in file
	db_luby   number;  -- entity owner in db
	db_ludate date;    -- entity update date in db
	row_id varchar2(64);

	l_txn_data clob;
 begin
-- Translate owner to file_last_updated_by
        f_luby := fnd_load_util.owner_id(X_OWNER);

        -- Translate char last_update_date to date
        f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
        begin
          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from FND_WEB_APPLICATION
          where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME;

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, X_CUSTOM_MODE)) then
	    -- Update existing row
            FND_WEB_APPLICATION_PKG.UPDATE_ROW (
			  X_APPLICATION_SHORT_NAME => X_APPLICATION_SHORT_NAME,
			  X_FAMILY_SHORT_NAME => X_FAMILY_SHORT_NAME,
			  X_IS_ENABLED => X_IS_ENABLED,
			  X_TXN_DATA => X_TXN_DATA,
			  X_LAST_UPDATE_DATE => f_ludate,
			  X_LAST_UPDATED_BY => f_luby,
			  X_LAST_UPDATE_LOGIN => null
			);
          end if;
        exception
          when no_data_found then
            -- Record doesn't exist - insert in all cases

            FND_WEB_APPLICATION_pkg.INSERT_ROW (
			  X_ROWID => row_id,
			  X_APPLICATION_SHORT_NAME => X_APPLICATION_SHORT_NAME,
			  X_FAMILY_SHORT_NAME => X_FAMILY_SHORT_NAME,
			  X_IS_ENABLED => X_IS_ENABLED,
			  X_TXN_DATA => X_TXN_DATA,
			  X_CREATION_DATE => sysdate,
			  X_CREATED_BY => 0,
			  X_LAST_UPDATE_DATE => f_ludate,
			  X_LAST_UPDATED_BY => f_luby,
			  X_LAST_UPDATE_LOGIN => null
			);
   end;
 end LOAD_ROW;

 procedure SET_APPLICATION_STATE(
	P_APP_SHORT_NAME in VARCHAR2,
	P_IS_ENABLED in VARCHAR2
	)
 is
 begin

	update FND_WEB_APPLICATION
	set IS_ENABLED = P_IS_ENABLED
	where APPLICATION_SHORT_NAME = P_APP_SHORT_NAME;

	-- Invalidate the cache
	FND_WEB_RESOURCE_PKG.InvalidateCache;
 end SET_APPLICATION_STATE;

 procedure ENABLE(
	P_APP_SHORT_NAME in VARCHAR2
	)
 is
 begin
	FND_WEB_APPLICATION_PKG.set_application_state(P_APP_SHORT_NAME => p_app_short_name, P_IS_ENABLED => 'Y');
 end ENABLE;

 procedure DISABLE(
	P_APP_SHORT_NAME in VARCHAR2
	)
 is
 begin
	FND_WEB_APPLICATION_PKG.set_application_state(P_APP_SHORT_NAME => p_app_short_name, P_IS_ENABLED => 'N');
 end DISABLE;

 function GET_LICENSING_STATUS(
	P_APP_SHORT_NAME in VARCHAR2
	)
 return VARCHAR2
 is
	l_licence_status varchar2(5);
 begin

	select fpi.status into l_licence_status
    from fnd_application fa, fnd_product_installations fpi
    where fpi.application_id = fa.application_id and
	fa.application_short_name = P_APP_SHORT_NAME;

	return l_licence_status;

exception
	when no_data_found then
		return 'X';

 end GET_LICENSING_STATUS;

 function GET_TXN_DATA_STATUS(
	P_APP_SHORT_NAME in VARCHAR2
	)
 return VARCHAR2
 is
	l_txn_data clob;
	l_txn_status varchar2(10);
 begin

	select TXN_DATA into l_txn_data
	from FND_WEB_APPLICATION
	where APPLICATION_SHORT_NAME  = P_APP_SHORT_NAME;

	-- if null then no txn data query is seeded
	if(l_txn_data is null)
		then return 'X';
	end if;

	begin
		EXECUTE IMMEDIATE l_txn_data INTO l_txn_status;
		if(l_txn_status is null)
			then return 'N';
		else
			return 'Y';
		end if;
	exception
		when no_data_found then
		return 'N';
	end;

 exception
	when no_data_found then
		return 'X';

 end GET_TXN_DATA_STATUS;

 END fnd_web_application_pkg;

/

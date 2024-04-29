--------------------------------------------------------
--  DDL for Package Body FND_WEB_USED_RESOURCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_WEB_USED_RESOURCE_PKG" AS
  /* $Header: AFSCWURB.pls 120.0.12010000.2 2019/08/21 10:43:31 ssumaith noship $ */


 PROCEDURE load_used_resource(
	P_RESOURCE_NAME in VARCHAR2,
	P_RESOURCE_TYPE in VARCHAR2,
	P_APPLICATION_SHORT_NAME in VARCHAR2,
	P_IS_USED in VARCHAR2
	)
 IS
	l_rowid VARCHAR2(200);
 BEGIN
	FND_WEB_USED_RESOURCE_PKG.INSERT_ROW(
	X_ROWID => l_rowid,
	X_RESOURCE_NAME => P_RESOURCE_NAME,
	X_RESOURCE_TYPE => P_RESOURCE_TYPE,
	X_APPLICATION_SHORT_NAME => P_APPLICATION_SHORT_NAME,
	X_IS_USED => P_IS_USED,
	X_CREATION_DATE => SYSDATE,
	X_CREATED_BY => 0,
	X_LAST_UPDATE_DATE => SYSDATE,
	X_LAST_UPDATED_BY => 0,
	X_LAST_UPDATE_LOGIN => null
	);

       -- Invalidate the cache
        FND_WEB_RESOURCE_PKG.InvalidateCache;

 END load_used_resource;

 PROCEDURE load_resource(
	P_RESOURCE_NAME in VARCHAR2,
	P_RESOURCE_TYPE in VARCHAR2,
	P_USING_APP_SHORT_NAME in VARCHAR2,
	P_OWNING_APP_SHORT_NAME in VARCHAR2,
	P_IS_USED in VARCHAR2
	)
 IS
 BEGIN
	FND_WEB_USED_RESOURCE_PKG.load_used_resource(
		P_RESOURCE_NAME => P_RESOURCE_NAME,
		P_RESOURCE_TYPE => P_RESOURCE_TYPE,
		P_APPLICATION_SHORT_NAME => P_USING_APP_SHORT_NAME,
		P_IS_USED => P_IS_USED
		);
	commit;

	FND_WEB_RESOURCE_PKG.load_web_resource(
		P_RESOURCE_NAME => P_RESOURCE_NAME,
		P_APPLICATION_SHORT_NAME => P_OWNING_APP_SHORT_NAME,
		P_RESOURCE_TYPE => P_RESOURCE_TYPE
		);
	commit;

	-- Invalidate the cache
	FND_WEB_RESOURCE_PKG.InvalidateCache;
 END load_resource;

FUNCTION web_used_resource_exists(
	P_RESOURCE_NAME in VARCHAR2,
	P_RESOURCE_TYPE in VARCHAR2,
	P_APP_SHORT_NAME in VARCHAR2
	)
 RETURN boolean
 IS
	l_resource_name VARCHAR2(2000);
 BEGIN
	select RESOURCE_NAME into l_resource_name from FND_WEB_USED_RESOURCE
	where RESOURCE_NAME = P_RESOURCE_NAME
	and RESOURCE_TYPE = P_RESOURCE_TYPE
	and APPLICATION_SHORT_NAME = P_APP_SHORT_NAME;

	if(SQL%NOTFOUND) then
		return false;
	else
		return true;
	end if;
 EXCEPTION
	WHEN no_data_found THEN
		return false;
 END web_used_resource_exists;


 procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_RESOURCE_NAME in VARCHAR2,
  X_RESOURCE_TYPE in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_IS_USED in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor c is select ROWID from FND_WEB_USED_RESOURCE
    where RESOURCE_NAME = X_RESOURCE_NAME
	and RESOURCE_TYPE = X_RESOURCE_TYPE
	and APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
    ;
begin
  insert into FND_WEB_USED_RESOURCE (
    RESOURCE_NAME,
	RESOURCE_TYPE,
    APPLICATION_SHORT_NAME,
    IS_USED,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
	X_RESOURCE_NAME,
	X_RESOURCE_TYPE,
	X_APPLICATION_SHORT_NAME,
	X_IS_USED,
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
  X_RESOURCE_NAME in VARCHAR2,
  X_RESOURCE_TYPE in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_IS_USED in VARCHAR2
) is
  cursor c is select
    RESOURCE_NAME,
	RESOURCE_TYPE,
    APPLICATION_SHORT_NAME,
    IS_USED
    from FND_WEB_USED_RESOURCE
    where RESOURCE_NAME = X_RESOURCE_NAME
	and RESOURCE_TYPE = X_RESOURCE_TYPE
	and APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
    for update of RESOURCE_NAME nowait;
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
  if ((recinfo.RESOURCE_NAME = X_RESOURCE_NAME)
      AND  (recinfo.RESOURCE_TYPE = X_RESOURCE_TYPE)
      AND (((recinfo.APPLICATION_SHORT_NAME is null) AND (X_APPLICATION_SHORT_NAME is null)))
      AND (((recinfo.IS_USED is null) AND (X_IS_USED is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_RESOURCE_NAME in VARCHAR2,
  X_RESOURCE_TYPE in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_IS_USED in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_WEB_USED_RESOURCE set
    IS_USED = X_IS_USED,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where RESOURCE_NAME = X_RESOURCE_NAME
  and RESOURCE_TYPE = X_RESOURCE_TYPE
  and APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RESOURCE_NAME in VARCHAR2,
  X_RESOURCE_TYPE in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2
) is
begin

  delete from FND_WEB_USED_RESOURCE
  where RESOURCE_NAME = X_RESOURCE_NAME
  and RESOURCE_TYPE = X_RESOURCE_TYPE
  and APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


procedure LOAD_ROW (
  X_OWNER in VARCHAR2,
  X_RESOURCE_NAME in VARCHAR2,
  X_RESOURCE_TYPE in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_IS_USED in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
 ) is
	f_luby    number;  -- entity owner in file
	f_ludate  date;    -- entity update date in file
	db_luby   number;  -- entity owner in db
	db_ludate date;    -- entity update date in db
	row_id varchar2(64);


 begin
-- Translate owner to file_last_updated_by
        f_luby := fnd_load_util.owner_id(X_OWNER);

        -- Translate char last_update_date to date
        f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
        begin
          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from FND_WEB_USED_RESOURCE
          where RESOURCE_NAME = X_RESOURCE_NAME
		  and RESOURCE_TYPE = X_RESOURCE_TYPE
		  and APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME;


	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, X_CUSTOM_MODE)) then
	    -- Update existing row
            FND_WEB_USED_RESOURCE_PKG.UPDATE_ROW (
			  X_RESOURCE_NAME => X_RESOURCE_NAME,
			  X_RESOURCE_TYPE => X_RESOURCE_TYPE,
			  X_APPLICATION_SHORT_NAME => X_APPLICATION_SHORT_NAME,
			  X_IS_USED => X_IS_USED,
			  X_LAST_UPDATE_DATE => f_ludate,
			  X_LAST_UPDATED_BY => f_luby,
			  X_LAST_UPDATE_LOGIN => null
			);
          end if;
        exception
          when no_data_found then
            -- Record doesn't exist - insert in all cases

            FND_WEB_USED_RESOURCE_pkg.INSERT_ROW (
			  X_ROWID => row_id,
			  X_RESOURCE_NAME => X_RESOURCE_NAME,
			  X_RESOURCE_TYPE => X_RESOURCE_TYPE,
			  X_APPLICATION_SHORT_NAME => X_APPLICATION_SHORT_NAME,
			  X_IS_USED => X_IS_USED,
			  X_CREATION_DATE => sysdate,
			  X_CREATED_BY => 0,
			  X_LAST_UPDATE_DATE => f_ludate,
			  X_LAST_UPDATED_BY => f_luby,
			  X_LAST_UPDATE_LOGIN => null
			);
   end;
 end LOAD_ROW;

 procedure SET_RESOURCE_STATE(
	P_RESOURCE_NAME in VARCHAR2,
	P_RESOURCE_TYPE in VARCHAR2,
	P_APP_SHORT_NAME in VARCHAR2,
	P_IS_USED in VARCHAR2
	)
 is
	l_cur_is_used varchar2(1);
 begin

	/*
	* We don't really need this check for now
	* if(FND_WEB_RESOURCE_PKG.web_resource_exists(P_RESOURCE_NAME, P_RESOURCE_TYPE) = false) then
	* 	RAISE_APPLICATION_ERROR(-20218, 'Resource '||P_RESOURCE_NAME||' does not exist in FND_WEB_RESOURCE');
	* end if;
	*/

	select IS_USED into l_cur_is_used
	from FND_WEB_USED_RESOURCE
	where RESOURCE_NAME = P_RESOURCE_NAME
	and RESOURCE_TYPE = P_RESOURCE_TYPE
	and APPLICATION_SHORT_NAME = P_APP_SHORT_NAME;

	if(l_cur_is_used <> P_IS_USED) then
		update FND_WEB_USED_RESOURCE
		set IS_USED = P_IS_USED
		where RESOURCE_NAME = P_RESOURCE_NAME
		and RESOURCE_TYPE = P_RESOURCE_TYPE
		and APPLICATION_SHORT_NAME = P_APP_SHORT_NAME;

		-- **
		-- ** if(P_IS_USED = 'Y') then
		-- ** 	FND_WEB_RESOURCE_PKG.INCREASE_USED_COUNT(P_RESOURCE_NAME);
		-- ** else
		-- ** 	FND_WEB_RESOURCE_PKG.DECREASE_USED_COUNT(P_RESOURCE_NAME);
		-- ** end if;

		-- Invalidate the cache
		FND_WEB_RESOURCE_PKG.InvalidateCache;

	else
		-- resource is already in the same state. no op.
		return;
	end if;
 end SET_RESOURCE_STATE;


 END fnd_web_used_resource_pkg;

/

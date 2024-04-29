--------------------------------------------------------
--  DDL for Package Body FND_WEB_RESOURCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_WEB_RESOURCE_PKG" AS
/* $Header: AFSCWRSB.pls 120.0.12010000.3 2019/11/15 06:20:17 ssumaith noship $ */

 PROCEDURE load_web_resource(
	P_RESOURCE_NAME in VARCHAR2,
	P_APPLICATION_SHORT_NAME in VARCHAR2,
	P_RESOURCE_TYPE in VARCHAR2
	)
 IS
	l_rowid VARCHAR2(200);
 BEGIN
	FND_WEB_RESOURCE_PKG.INSERT_ROW(
		X_ROWID => l_rowid,
		X_RESOURCE_NAME => P_RESOURCE_NAME,
		X_RESOURCE_TYPE => P_RESOURCE_TYPE,
		X_APPLICATION_SHORT_NAME => P_APPLICATION_SHORT_NAME,
		X_CREATION_DATE => SYSDATE,
		X_CREATED_BY => 0,
		X_LAST_UPDATE_DATE => SYSDATE,
		X_LAST_UPDATED_BY => 0,
		X_LAST_UPDATE_LOGIN => null
		);

 END load_web_resource;

 FUNCTION web_resource_exists(
	P_RESOURCE_NAME in VARCHAR2,
	P_RESOURCE_TYPE in VARCHAR2
	)
 RETURN boolean
 IS
	l_resource_name VARCHAR2(2000);
 BEGIN
	select RESOURCE_NAME into l_resource_name from FND_WEB_RESOURCE
	where RESOURCE_NAME = P_RESOURCE_NAME
	and RESOURCE_TYPE = P_RESOURCE_TYPE;

	if(SQL%NOTFOUND) then
		return false;
	else
		return true;
	end if;
 EXCEPTION
	WHEN no_data_found THEN
		return false;
 END web_resource_exists;

 procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_RESOURCE_NAME in VARCHAR2,
  X_RESOURCE_TYPE in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor c is select ROWID from FND_WEB_RESOURCE
    where RESOURCE_NAME = X_RESOURCE_NAME
	and RESOURCE_TYPE = X_RESOURCE_TYPE;
begin
  insert into FND_WEB_RESOURCE (
    RESOURCE_NAME,
    RESOURCE_TYPE,
    APPLICATION_SHORT_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
	X_RESOURCE_NAME,
	X_RESOURCE_TYPE,
	X_APPLICATION_SHORT_NAME,
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
  X_APPLICATION_SHORT_NAME in VARCHAR2
) is
  cursor c is select
    RESOURCE_NAME,
    RESOURCE_TYPE,
    APPLICATION_SHORT_NAME
    from FND_WEB_RESOURCE
    where RESOURCE_NAME = X_RESOURCE_NAME
	and RESOURCE_TYPE = X_RESOURCE_TYPE
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
      AND ((recinfo.RESOURCE_TYPE = X_RESOURCE_TYPE)
           OR ((recinfo.APPLICATION_SHORT_NAME is null) AND (X_APPLICATION_SHORT_NAME is null)))
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
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_WEB_RESOURCE set
    APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where RESOURCE_NAME = X_RESOURCE_NAME
  and RESOURCE_TYPE = X_RESOURCE_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RESOURCE_NAME in VARCHAR2,
  X_RESOURCE_TYPE in VARCHAR2
) is
begin

  delete from FND_WEB_RESOURCE
  where RESOURCE_NAME = X_RESOURCE_NAME
  and RESOURCE_TYPE = X_RESOURCE_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


procedure LOAD_ROW (
  X_OWNER in VARCHAR2,
  X_RESOURCE_NAME in VARCHAR2,
  X_RESOURCE_TYPE in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
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
          from FND_WEB_RESOURCE
          where RESOURCE_NAME = X_RESOURCE_NAME
		  and RESOURCE_TYPE = X_RESOURCE_TYPE;


	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, X_CUSTOM_MODE)) then
	    -- Update existing row
            FND_WEB_RESOURCE_PKG.UPDATE_ROW (
			  X_RESOURCE_NAME => X_RESOURCE_NAME,
			  X_RESOURCE_TYPE => X_RESOURCE_TYPE,
			  X_APPLICATION_SHORT_NAME => X_APPLICATION_SHORT_NAME,
			  X_LAST_UPDATE_DATE => f_ludate,
			  X_LAST_UPDATED_BY => f_luby,
			  X_LAST_UPDATE_LOGIN => null
			);
          end if;
        exception
          when no_data_found then
            -- Record doesn't exist - insert in all cases

            FND_WEB_RESOURCE_pkg.INSERT_ROW (
			  X_ROWID => row_id,
			  X_RESOURCE_NAME => X_RESOURCE_NAME,
			  X_RESOURCE_TYPE => X_RESOURCE_TYPE,
			  X_APPLICATION_SHORT_NAME => X_APPLICATION_SHORT_NAME,
			  X_CREATION_DATE => sysdate,
			  X_CREATED_BY => 0,
			  X_LAST_UPDATE_DATE => f_ludate,
			  X_LAST_UPDATED_BY => f_luby,
			  X_LAST_UPDATE_LOGIN => null
			);
   end;
 end LOAD_ROW;


 procedure AUDIT_RESOURCE(
	P_RESOURCE_NAME in VARCHAR2,
	P_LAST_ACCESSED_BY in NUMBER default null,
	P_LAST_ACCESSED_DATE in VARCHAR2 default null,
	P_FIRST_ACCESSED_BY in NUMBER default null,
	P_FIRST_ACCESSED_DATE in VARCHAR2 default null,
	P_ACCESS_COUNT in VARCHAR2 default null,
	P_IS_ACCEPTED in VARCHAR2 default null
	)
 is
	l_last_accessed_by number(15);
	l_last_accessed_date date;
	l_first_accessed_by number(15);
	l_first_accessed_date date;
	l_access_count number(15);
	l_is_accepted varchar2(1);
 begin
	select
	LAST_ACCESSED_BY,
	LAST_ACCESSED_DATE,
	FIRST_ACCESSED_BY,
	FIRST_ACCESSED_DATE,
	ACCESS_COUNT,
	IS_ACCEPTED
	into
		l_last_accessed_by,
		l_last_accessed_date,
		l_first_accessed_by,
		l_first_accessed_date,
		l_access_count,
		l_is_accepted
	from FND_WEB_RESOURCE_AUDIT
	where RESOURCE_NAME = P_RESOURCE_NAME;


	update FND_WEB_RESOURCE_AUDIT
	set LAST_ACCESSED_BY = nvl(P_LAST_ACCESSED_BY, l_last_accessed_by),
	LAST_ACCESSED_DATE = nvl(to_date(P_LAST_ACCESSED_DATE),sysdate),
	FIRST_ACCESSED_BY = nvl(P_FIRST_ACCESSED_BY, nvl(l_first_accessed_by,-1)),
	FIRST_ACCESSED_DATE = nvl(to_date(P_FIRST_ACCESSED_DATE), nvl(l_first_accessed_date,sysdate)),
	ACCESS_COUNT = nvl(p_access_count,access_count+1),
	IS_ACCEPTED = nvl(P_IS_ACCEPTED, nvl(l_is_accepted,'Y'))
	where RESOURCE_NAME = P_RESOURCE_NAME;

	commit;
 exception
	when no_data_found then
		-- Resource does not exist, insert data
                l_last_accessed_by := nvl(p_last_accessed_by,-1);
                l_lAst_accessed_date:= nvl(p_lAst_accessed_date,sysdate);
                l_last_ACCESSED_DATE:=nvl(P_FIRST_ACCESSED_DATE,sysdate);
                l_first_accessed_by:= nvl(P_FIRST_ACCESSED_BY,nvl(l_last_accessed_by,-1));
                l_FIRST_ACCESSED_DATE:=nvl(P_FIRST_ACCESSED_DATE,sysdate);
                l_IS_ACCEPTED:= nvl(P_IS_ACCEPTED,'Y');
                l_access_count := nvl(p_access_count,1);



			INSERT INTO
			FND_WEB_RESOURCE_AUDIT(
				RESOURCE_NAME,
				LAST_ACCESSED_BY,
				LAST_ACCESSED_DATE,
				FIRST_ACCESSED_BY,
				FIRST_ACCESSED_DATE,
				ACCESS_COUNT,
				IS_ACCEPTED)
			VALUES(
				P_RESOURCE_NAME,
				L_LAST_ACCESSED_BY,
				L_LAST_ACCESSED_DATE,
				L_FIRST_ACCESSED_BY,
				L_FIRST_ACCESSED_DATE,
				L_ACCESS_COUNT,
				L_IS_ACCEPTED);
		commit;
 end AUDIT_RESOURCE;

 procedure ALLOW_DENY_RESOURCE (
   X_RESOURCE_NAME in VARCHAR2,
   X_RESOURCE_TYPE in VARCHAR2,
   X_RESOURCE_STATE in VARCHAR2
  )

IS
cursor c is  select APPLICATION_SHORT_NAME from fnd_web_used_resource  where RESOURCE_NAME = X_RESOURCE_NAME and RESOURCE_TYPE = X_RESOURCE_TYPE and  IS_USED <> X_RESOURCE_STATE ;
X_APP_SHORT_NAME VARCHAR2(2000);
begin

open c;
LOOP
   FETCH c into X_APP_SHORT_NAME;
   EXIT WHEN c%notfound;
   fnd_web_used_resource_pkg.SET_RESOURCE_STATE(X_RESOURCE_NAME,X_RESOURCE_TYPE,X_APP_SHORT_NAME,X_RESOURCE_STATE);
END LOOP;
close c;
end;

 function IS_RESOURCE_ALLOWED(
		P_RESOURCE_NAME in VARCHAR2,
		P_RESOURCE_TYPE in VARCHAR2
		)
 return VARCHAR2
 is
	l_used_count number(15);

 begin
	-- ** l_used_count := GET_RESOURCE_USED_COUNT(P_RESOURCE_NAME);

	select USED_COUNT into l_used_count
	from FND_WEB_ALLOWED_RESOURCE_V
	where RESOURCE_NAME = P_RESOURCE_NAME
	and RESOURCE_TYPE = P_RESOURCE_TYPE;

	if (l_used_count > 0)
	then return 'Y';
	else return 'N';
	end if;

 exception
	when no_data_found then
		return 'N';
	when others then
		return 'N';
 end IS_RESOURCE_ALLOWED;

 /*
	Checks if sufficient web activity( > 6months) has been collected or not.

	Queries against the FND_WEB_RESOURCE_AUDIT table for the
	minimum FIRST_ACCESSED_DATE to make that determination.
 */
 function IS_SUFFICIENT_WEB_ACTIVITY
 return BOOLEAN
 is
	l_min_fad date;
 begin
	select min(FIRST_ACCESSED_DATE) into l_min_fad from FND_WEB_RESOURCE_AUDIT;

	if((SYSDATE-l_min_fad) >= 180) then
		return true;
	else
		return false;
	end if;
end IS_SUFFICIENT_WEB_ACTIVITY;

 /*
  Get the web activity status for either a resource or an application.

  Returns
	'X' -- If not sufficient data collected to determine web activity status
	'Y' -- If web activity records for the passed resource/application found
	'N' -- If no web activity records for the passed resource/application found
 */
 function GET_WEB_ACTIVITY_STATUS(
	P_RESOURCE_NAME in VARCHAR2 default null,
	P_APP_SHORT_NAME in VARCHAR2 default null
	)
 return VARCHAR2
 is
  l_status varchar2(1);
  l_cnt number(15);
 begin
	if(not IS_SUFFICIENT_WEB_ACTIVITY) then
		return 'X';
	end if;

	if(P_RESOURCE_NAME is not null) then
		select count(*) into l_cnt
		from FND_WEB_RESOURCE_AUDIT
		where RESOURCE_NAME = P_RESOURCE_NAME;

		if(l_cnt>0) then return 'Y';
		else return 'N';
		end if;
	end if;

	if(P_APP_SHORT_NAME is not null) then
		select count(*) into l_cnt
		from FND_WEB_RESOURCE fwr, FND_WEB_RESOURCE_AUDIT fwra
		where fwr.RESOURCE_NAME = fwra.RESOURCE_NAME
		and fwr.APPLICATION_SHORT_NAME = P_APP_SHORT_NAME;

		if (l_cnt>0) then return 'Y';
		else return 'N';
		end if;
	end if;

 end GET_WEB_ACTIVITY_STATUS;

 /*
	Get the used count of a resource.

	Queries the FND_ALLOWED_RESOURCE_V to return the used count.
	Returns 0 if FND_ALLOWED_RESOURCE_V returns no rows for the resource
*/
 function GET_USED_COUNT(
	P_RESOURCE_NAME in VARCHAR2,
	P_RESOURCE_TYPE in VARCHAR2
	)
 return NUMBER
 is
	l_used_count number(15,0);
 begin
	select USED_COUNT into l_used_count
	from FND_WEB_ALLOWED_RESOURCE_V
	where RESOURCE_NAME = P_RESOURCE_NAME
	and RESOURCE_TYPE = P_RESOURCE_TYPE;

	return l_used_count;

  exception
	when no_data_found then
		return 0;
 end GET_USED_COUNT;

/*

Cache invalidation.

THe UI must notify the cache that a change had been made and metadata must be reloaded.

Implementation Note:
     A profile is set with the current timestamp.
	 Client either can ask for the profile and act when changed, or
	 client can subscribe to the WF Business Event
See Bug 25599446
*/
 procedure InvalidateCache
 IS
 now VARCHAR2(200);
 BEGIN
    select CURRENT_TIMESTAMP into now from dual;
    if  NOT fnd_profile.save('FND_SEC_RESOURCES_LAST_UPDATE',now,'SITE',null) then
       fnd_message.set_name('FND','FND_CACHE_COMP_CLEAR_ERROR');
       app_exception.raise_exception;
   end if;

 END InvalidateCache;

  PROCEDURE ALLOW_DENY_RESOURCES(p_res_attrs            IN FND_WEB_RESOURCE_TBL,
		                 x_return_status        OUT NOCOPY VARCHAR2    ,
                                 x_num_records          OUT NOCOPY NUMBER)
  IS
   L_RESULT_ATTRS  FND_WEB_RESOURCE_TBL:= FND_WEB_RESOURCE_TBL(null);
  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.AFSCWRSB.DO_OPERATION.begin',
                      'STARTED: ' );
    END IF;
    x_return_status := 'S';
    FOR  i in 1 ..p_res_attrs.count
    LOOP

        if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
           FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.AFSCWRSB.DO_OPERATION.LOOP',
                      'p_res_attrs(i).Name =  ' || p_res_attrs(i).Name  );
	   FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.AFSCWRSB.DO_OPERATION.LOOP',
                      'p_res_attrs(i).TYPE =  ' || p_res_attrs(i).TYPE  );
	   FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.AFSCWRSB.DO_OPERATION.LOOP',
                      'p_res_attrs(i).VALUE =  ' || p_res_attrs(i).VALUE  );
	end if;
    	ALLOW_DENY_RESOURCE(X_RESOURCE_NAME  =>   p_res_attrs(i).Name   ,
		            X_RESOURCE_TYPE  =>   p_res_attrs(i).type   ,
                            X_RESOURCE_STATE =>   p_res_attrs(i).value  );

        x_num_records := i;
      END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
       x_return_status := 'E';
  END ALLOW_DENY_RESOURCES;


 END fnd_web_resource_pkg;

/

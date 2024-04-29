--------------------------------------------------------
--  DDL for Package Body JTF_UM_ROLE_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_ROLE_RESP_PKG" as
/* $Header: JTFUMRRB.pls 120.3 2005/11/28 08:51:15 vimohan ship $ */
procedure INSERT_USERTYPE_ROLE_ROW (
    x_usertype_id            IN	NUMBER,
    x_principal_name  	     IN	VARCHAR2,
    x_effective_start_date   IN DATE,
    x_effective_end_date     IN	DATE,
    x_creation_date          IN DATE,
    x_created_by             IN NUMBER,
    x_last_update_date       IN DATE,
    x_last_updated_by        IN NUMBER,
    x_last_update_login      IN NUMBER
) is
begin
  insert into jtf_um_usertype_role (
	usertype_id ,
	principal_name ,
 	effective_start_date ,
    	effective_end_date ,
	creation_date ,
    	created_by ,
    	last_update_date ,
    	last_updated_by ,
    	last_update_login
  ) values (
 	x_usertype_id ,
	x_principal_name ,
 	x_effective_start_date ,
    	x_effective_end_date ,
	x_creation_date ,
    	x_created_by ,
    	x_last_update_date ,
    	x_last_updated_by ,
    	x_last_update_login
  );
end INSERT_USERTYPE_ROLE_ROW;

procedure UPDATE_USERTYPE_ROLE_ROW (
    x_usertype_id            IN	NUMBER,
    x_principal_name         IN VARCHAR2,
    x_effective_end_date     IN	DATE,
    x_last_update_date       IN DATE,
    x_last_updated_by        IN NUMBER,
    x_last_update_login      IN NUMBER
) is
begin
  update jtf_um_usertype_role set
    	effective_end_date = x_effective_end_date ,
    	last_update_date = x_last_update_date ,
    	last_updated_by = x_last_updated_by ,
    	last_update_login = x_last_update_login
  where usertype_id = x_usertype_id AND
	principal_name = x_principal_name;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_USERTYPE_ROLE_ROW;

procedure LOAD_usertype_role_ROW (
    x_usertype_id            IN	NUMBER,
    x_principal_name         IN VARCHAR2,
    x_effective_start_date   IN DATE,
    x_effective_end_date     IN	DATE,
    x_owner 		     IN VARCHAR2,
    x_last_update_date       in varchar2 default NULL,
    X_CUSTOM_MODE            in varchar2 default NULL
) is
  l_user_id NUMBER := fnd_load_util.owner_id(x_owner);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin
      -- if (x_owner = 'SEED') then
      --  	l_user_id := 1;
      --	end if;


-- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

    -- This select stmnt also checks if
    -- there is a row for this app_id and this app_short_name
    -- Exception is thrown otherwise.
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
      into db_luby, db_ludate
      FROM jtf_um_usertype_role
     where usertype_id = x_usertype_id AND
	principal_name = x_principal_name;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then

-- Update row if present
	JTF_UM_ROLE_RESP_PKG.UPDATE_USERTYPE_ROLE_ROW (
		x_usertype_id 		=> x_usertype_id,
	  	x_principal_name 	=> x_principal_name,
	  	x_effective_end_date	=> x_effective_end_date,
	  	x_last_update_date 	=> f_ludate,
 	  	x_last_updated_by 	=> f_luby,
	  	x_last_update_login 	=> l_user_id
	);

   end if;

	exception
	when NO_DATA_FOUND then

	  -- Insert a new row
	  JTF_UM_ROLE_RESP_PKG.INSERT_USERTYPE_ROLE_ROW (
	  	x_usertype_id 		=> x_usertype_id,
	  	x_principal_name 	=> x_principal_name,
	  	x_effective_start_date	=> x_effective_start_date,
	  	x_effective_end_date	=> x_effective_end_date,
	  	x_creation_date		=> f_ludate,
	  	x_created_by 		=> f_luby,
	  	x_last_update_date 	=> f_ludate,
 	  	x_last_updated_by 	=> f_luby,
	  	x_last_update_login 	=> l_user_id
	  );
end LOAD_USERTYPE_ROLE_ROW;

procedure INSERT_USERTYPE_RESP_ROW (
    x_usertype_id            IN	NUMBER,
    x_responsibility_key     IN VARCHAR2,
    x_is_default_flag	     IN VARCHAR2,
    x_effective_start_date   IN DATE,
    x_effective_end_date     IN	DATE,
    x_creation_date          IN DATE,
    x_created_by             IN NUMBER,
    x_last_update_date       IN DATE,
    x_last_updated_by        IN NUMBER,
    x_last_update_login      IN NUMBER,
    x_application_id         IN NUMBER
) is
begin
  insert into jtf_um_usertype_resp (
	usertype_id ,
	responsibility_key ,
    	is_default_flag ,
 	effective_start_date ,
    	effective_end_date ,
	creation_date ,
    	created_by ,
    	last_update_date ,
    	last_updated_by ,
    	last_update_login ,
    	application_id
  ) values (
 	x_usertype_id ,
	x_responsibility_key ,
	x_is_default_flag ,
 	x_effective_start_date ,
    	x_effective_end_date ,
	x_creation_date ,
    	x_created_by ,
    	x_last_update_date ,
    	x_last_updated_by ,
    	x_last_update_login ,
    	x_application_id
  );
end INSERT_USERTYPE_RESP_ROW;

procedure UPDATE_USERTYPE_RESP_ROW (
    x_usertype_id            IN	NUMBER,
    x_responsibility_key     IN VARCHAR2,
    x_is_default_flag	     IN VARCHAR2,
    x_effective_end_date     IN	DATE,
    x_last_update_date       IN DATE,
    x_last_updated_by        IN NUMBER,
    x_last_update_login      IN NUMBER,
    x_application_id         IN NUMBER
) is
begin
  update jtf_um_usertype_resp set
    	is_default_flag = x_is_default_flag ,
    	effective_end_date = x_effective_end_date ,
    	last_update_date = x_last_update_date ,
    	last_updated_by = x_last_updated_by ,
    	last_update_login = x_last_update_login ,
    	application_id = x_application_id
  where usertype_id = x_usertype_id AND
	responsibility_key = x_responsibility_key ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_usertype_resp_ROW;

procedure LOAD_USERTYPE_RESP_ROW (
    x_usertype_id            IN	NUMBER,
    x_responsibility_key     IN VARCHAR2,
    x_is_default_flag	     IN VARCHAR2,
    x_effective_start_date   IN DATE,
    x_effective_end_date     IN	DATE,
    x_owner 		     IN VARCHAR2,
    x_application_id         IN NUMBER,
    x_last_update_date       in varchar2 default NULL,
    x_custom_mode            in varchar2 default NULL
) is
  l_user_id NUMBER := fnd_load_util.owner_id(x_owner);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin
       --	if (x_owner = 'SEED') then
       -- 		l_user_id := 1;
       -- 	end if;
-- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

    -- This select stmnt also checks if
    -- there is a row for this app_id and this app_short_name
    -- Exception is thrown otherwise.
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
      into db_luby, db_ludate
      FROM jtf_um_usertype_resp
     where usertype_id = x_usertype_id AND
	responsibility_key = x_responsibility_key ;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then


	-- Update row if present
	JTF_UM_ROLE_RESP_PKG.UPDATE_USERTYPE_RESP_ROW (
		x_usertype_id 		=> x_usertype_id,
	  	x_responsibility_key 	=> x_responsibility_key,
	  	x_is_default_flag	=> x_is_default_flag,
	  	x_effective_end_date	=> x_effective_end_date,
	  	x_last_update_date 	=> f_ludate,
 	  	x_last_updated_by 	=> f_luby,
	  	x_last_update_login 	=> l_user_id,
	  	x_application_id 	=> x_application_id
	);

  end if;
	exception
	when NO_DATA_FOUND then

	  -- Insert a new row
	  JTF_UM_ROLE_RESP_PKG.INSERT_USERTYPE_RESP_ROW (
	  	x_usertype_id 		=> x_usertype_id,
	  	x_responsibility_key 	=> x_responsibility_key,
	  	x_is_default_flag	=> x_is_default_flag,
	  	x_effective_start_date	=> x_effective_start_date,
	  	x_effective_end_date	=> x_effective_end_date,
	  	x_creation_date		=> f_ludate,
	  	x_created_by 		=> f_luby,
	  	x_last_update_date 	=> f_ludate,
 	  	x_last_updated_by 	=> f_luby,
	  	x_last_update_login 	=> l_user_id,
	  	x_application_id 	=> x_application_id
	  );
end LOAD_USERTYPE_RESP_ROW;

procedure INSERT_SUBSCRIPTION_ROLE_ROW (
    x_subscription_id        IN	NUMBER,
    x_principal_name         IN VARCHAR2,
    x_effective_start_date   IN DATE,
    x_effective_end_date     IN	DATE,
    x_creation_date          IN DATE,
    x_created_by             IN NUMBER,
    x_last_update_date       IN DATE,
    x_last_updated_by        IN NUMBER,
    x_last_update_login      IN NUMBER
) is
begin
  insert into jtf_um_subscription_role (
	subscription_id ,
	principal_name ,
 	effective_start_date ,
    	effective_end_date ,
	creation_date ,
    	created_by ,
    	last_update_date ,
    	last_updated_by ,
    	last_update_login
  ) values (
 	x_subscription_id ,
	x_principal_name ,
 	x_effective_start_date ,
    	x_effective_end_date ,
	x_creation_date ,
    	x_created_by ,
    	x_last_update_date ,
    	x_last_updated_by ,
    	x_last_update_login
  );
end INSERT_SUBSCRIPTION_ROLE_ROW;

procedure UPDATE_SUBSCRIPTION_ROLE_ROW (
    x_subscription_id        IN	NUMBER,
    x_principal_name         IN VARCHAR2,
    x_effective_end_date     IN	DATE,
    x_last_update_date       IN DATE,
    x_last_updated_by        IN NUMBER,
    x_last_update_login      IN NUMBER
) is
begin
  update jtf_um_subscription_role set
    	effective_end_date = x_effective_end_date ,
    	last_update_date = x_last_update_date ,
    	last_updated_by = x_last_updated_by ,
    	last_update_login = x_last_update_login
  where subscription_id = x_subscription_id AND
	principal_name = x_principal_name ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_SUBSCRIPTION_ROLE_ROW;

procedure LOAD_SUBSCRIPTION_ROLE_ROW (
    x_subscription_id        IN	NUMBER,
    x_principal_name         IN VARCHAR2,
    x_effective_start_date   IN DATE,
    x_effective_end_date     IN	DATE,
    x_owner 		     IN VARCHAR2,
    x_last_update_date       in varchar2 default NULL,
    x_custom_mode            in varchar2 default NULL
) is
	l_user_id NUMBER := fnd_load_util.owner_id(x_owner);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db


begin
     --	if (x_owner = 'SEED') then
    -- 		l_user_id := 1;
	--end if;


 -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

    -- This select stmnt also checks if
    -- there is a row for this app_id and this app_short_name
    -- Exception is thrown otherwise.
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
      into db_luby, db_ludate
      FROM jtf_um_subscription_role
     where subscription_id = x_subscription_id AND
	principal_name = x_principal_name ;


    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then


	-- Update row if present
	JTF_UM_ROLE_RESP_PKG.UPDATE_SUBSCRIPTION_ROLE_ROW (
		x_subscription_id 	=> x_subscription_id,
	  	x_principal_name 	=> x_principal_name,
	  	x_effective_end_date	=> x_effective_end_date,
	  	x_last_update_date 	=> f_ludate,
 	  	x_last_updated_by 	=> f_luby,
	  	x_last_update_login 	=> l_user_id
	);


  end if;
	exception
	when NO_DATA_FOUND then

	  -- Insert a new row
	  JTF_UM_ROLE_RESP_PKG.INSERT_SUBSCRIPTION_ROLE_ROW (
	  	x_subscription_id 	=> x_subscription_id,
	  	x_principal_name 	=> x_principal_name,
	  	x_effective_start_date	=> x_effective_start_date,
	  	x_effective_end_date	=> x_effective_end_date,
	  	x_creation_date		=> f_ludate,
	  	x_created_by 		=> f_luby,
	  	x_last_update_date 	=> f_ludate,
 	  	x_last_updated_by 	=> f_luby,
	  	x_last_update_login 	=> l_user_id
	  );
end LOAD_SUBSCRIPTION_ROLE_ROW;

procedure INSERT_SUBSCRIPTION_RESP_ROW (
    x_subscription_id        IN	NUMBER,
    x_responsibility_key     IN VARCHAR2,
    x_effective_start_date   IN DATE,
    x_effective_end_date     IN	DATE,
    x_creation_date          IN DATE,
    x_created_by             IN NUMBER,
    x_last_update_date       IN DATE,
    x_last_updated_by        IN NUMBER,
    x_last_update_login      IN NUMBER,
    x_application_id         IN NUMBER
) is
begin
  insert into jtf_um_subscription_resp (
	subscription_id ,
	responsibility_key ,
 	effective_start_date ,
    	effective_end_date ,
	creation_date ,
    	created_by ,
    	last_update_date ,
    	last_updated_by ,
    	last_update_login ,
    	application_id
  ) values (
 	x_subscription_id ,
	x_responsibility_key ,
 	x_effective_start_date ,
    	x_effective_end_date ,
	x_creation_date ,
    	x_created_by ,
    	x_last_update_date ,
    	x_last_updated_by ,
    	x_last_update_login ,
    	x_application_id
  );
end INSERT_SUBSCRIPTION_RESP_ROW;

procedure UPDATE_SUBSCRIPTION_RESP_ROW (
    x_subscription_id        IN	NUMBER,
    x_responsibility_key     IN VARCHAR2,
    x_effective_end_date     IN	DATE,
    x_last_update_date       IN DATE,
    x_last_updated_by        IN NUMBER,
    x_last_update_login      IN NUMBER,
    x_application_id         IN NUMBER
) is
begin
  update jtf_um_subscription_resp set
    	effective_end_date = x_effective_end_date ,
    	last_update_date = x_last_update_date ,
    	last_updated_by = x_last_updated_by ,
    	last_update_login = x_last_update_login ,
    	application_id = x_application_id
  where subscription_id = x_subscription_id AND
	responsibility_key = x_responsibility_key ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_SUBSCRIPTION_RESP_ROW;

procedure LOAD_SUBSCRIPTION_RESP_ROW (
    x_subscription_id        IN	NUMBER,
    x_responsibility_key     IN VARCHAR2,
    x_effective_start_date   IN DATE,
    x_effective_end_date     IN	DATE,
    x_owner 		     IN VARCHAR2,
    x_application_id         IN NUMBER,
    x_last_update_date       in varchar2 default NULL,
    X_CUSTOM_MODE            in varchar2 default NULL
) is
	l_user_id NUMBER := fnd_load_util.owner_id(x_owner);

  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin
--	if (x_owner = 'SEED') then
--		l_user_id := 1;
--	end if;

-- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

    -- This select stmnt also checks if
    -- there is a row for this app_id and this app_short_name
    -- Exception is thrown otherwise.
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
      into db_luby, db_ludate
      FROM jtf_um_subscription_resp
     where subscription_id = x_subscription_id AND
	responsibility_key = x_responsibility_key ;


    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then


	-- Update row if present
	JTF_UM_ROLE_RESP_PKG.UPDATE_SUBSCRIPTION_RESP_ROW (
		x_subscription_id 	=> x_subscription_id,
	  	x_responsibility_key 	=> x_responsibility_key,
	  	x_effective_end_date	=> x_effective_end_date,
	  	x_last_update_date 	=> f_ludate,
 	  	x_last_updated_by 	=> f_luby,
	  	x_last_update_login 	=> l_user_id,
	  	x_application_id 	=> x_application_id
	);

end if;

	exception
	when NO_DATA_FOUND then

	  -- Insert a new row
	  JTF_UM_ROLE_RESP_PKG.INSERT_SUBSCRIPTION_RESP_ROW (
	  	x_subscription_id 	=> x_subscription_id,
	  	x_responsibility_key 	=> x_responsibility_key,
	  	x_effective_start_date	=> x_effective_start_date,
	  	x_effective_end_date	=> x_effective_end_date,
	  	x_creation_date		=> f_ludate,
	  	x_created_by 		=> f_luby,
	  	x_last_update_date 	=> f_ludate,
 	  	x_last_updated_by 	=> f_luby,
	  	x_last_update_login 	=> l_user_id,
	  	x_application_id 	=> x_application_id
	  );
end LOAD_SUBSCRIPTION_RESP_ROW;

end JTF_UM_ROLE_RESP_PKG;

/

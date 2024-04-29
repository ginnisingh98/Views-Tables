--------------------------------------------------------
--  DDL for Package Body FND_SEC_BULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SEC_BULK" as
/* $Header: AFSCBLKB.pls 120.3 2005/11/02 12:13:05 rsheh noship $ */


/*
** cloneuser_attr - setup a new user with the attributes, responsibilities,
**             and profile option settings of an existing user.
**             Note: this procedure should live in fnd_user_pkg
*/
PROCEDURE cloneuser_attr(p_template_user  in varchar2,
                         p_new_user       in varchar2,
                         description      in varchar2,
                         email            in varchar2)
is
  new_userid number;
  cursor template_user is
    select end_date,
           description,
           password_lifespan_accesses,
           password_lifespan_days,
           employee_id,
           email_address,
           fax,
           customer_id,
           supplier_id
    from   fnd_user
    where  user_name = upper(p_template_user);

begin
  begin
  select user_id into new_userid
  from   fnd_user
  where  user_name = upper(p_new_user);
  exception
    when no_data_found then
      null;
  end;

  for tu in template_user loop
    fnd_user_pkg.UpdateUser(
      x_user_name                  => upper(p_new_user),
      x_owner                      => 'CUST',
      x_end_date                   => tu.end_date,
      x_description                => nvl(description, tu.description),
      x_password_date              => sysdate,
      x_password_accesses_left     => tu.password_lifespan_accesses,
      x_password_lifespan_accesses => tu.password_lifespan_accesses,
      x_password_lifespan_days     => tu.password_lifespan_days,
      x_employee_id	           => tu.employee_id,
      x_email_address              => nvl(email, tu.email_address),
      x_fax	                   => tu.fax,
      x_customer_id	           => tu.customer_id,
      x_supplier_id	           => tu.supplier_id);
  end loop;

end;

/*
** cloneuser_resp - setup a new user with the attributes, responsibilities,
**             and profile option settings of an existing user.
**             Note: this procedure should live in fnd_user_pkg
*/
PROCEDURE cloneuser_resp(p_template_user  in varchar2,
                         p_new_user       in varchar2)
is
  new_userid number;

  cursor resp_groups is
    select a.application_short_name app,
           r.responsibility_key resp,
           s.security_group_key sg,
           decode(u.last_updated_by, 1, 'SEED', 'CUSTOM') owner,
           to_char(ur.start_date, 'YYYY/MM/DD') start_date,
           to_char(ur.end_date, 'YYYY/MM/DD') end_date,
           ur.description
    from   fnd_user u,
           fnd_user_resp_groups ur,
           fnd_application_vl a,
           fnd_responsibility_vl r,
           fnd_security_groups_vl s
    where  u.user_name                      = upper(p_template_user)
    and    ur.user_id                       = u.user_id
    and    ur.responsibility_id             = r.responsibility_id
    and    ur.responsibility_application_id = r.application_id
    and    ur.responsibility_application_id = a.application_id
    and    ur.security_group_id             = s.security_group_id;

begin
  begin
  select user_id into new_userid
  from   fnd_user
  where  user_name = upper(p_new_user);
  exception
    when no_data_found then
      null;
  end;

  for rgx in resp_groups loop
    fnd_user_resp_groups_api.load_row(
      x_user_name      => upper(p_new_user),
      x_resp_key       => rgx.resp,
      x_app_short_name => rgx.app,
      x_security_group => rgx.sg,
      x_owner          => rgx.owner,
      x_start_date     => rgx.start_date,
      x_end_date       => rgx.end_date,
      x_description    => rgx.description);
  end loop;

end;
/*
** cloneuser_prof - setup a new user with the attributes, responsibilities,
**             and profile option settings of an existing user.
**             Note: this procedure should live in fnd_user_pkg
*/
PROCEDURE cloneuser_prof(p_template_user  in varchar2,
                         p_new_user       in varchar2)
is
  new_userid number;
  ret boolean;
  cursor profile_values is
    select pov.application_id appid,
           p.profile_option_name proname,
           pov.profile_option_value val
    from   fnd_profile_option_values pov,
           fnd_profile_options p,
           fnd_user u
    where  pov.level_id    = 10004
    and    pov.level_value = u.user_id
    and    pov.profile_option_id = p.profile_option_id
    and    pov.application_id = p.application_id
    and    u.user_name     = upper(p_template_user);
begin
  begin
  select user_id into new_userid
  from   fnd_user
  where  user_name = upper(p_new_user);
  exception
    when no_data_found then
      null;
  end;

  for pvx in profile_values loop
     ret := fnd_profile.save(pvx.proname, pvx.val, 'USER', new_userid, '');
  end loop;
end;

--------------------------------------------------------------------------
-- AddRespUserGroup
--   Assign a responsibility key to a group of users.
--   The group of users is defined in x_user_group_clause.
--   You can optionally supply description, start_date and end_date.
--   The return value is the number of users processed.
--
-- Usage Example
--   declare
--     user_clause varchar2(2000);
--     cnt number;
--   begin
--     user_clause := fnd_sec_bulk.UserAssignResp('FND',
--                                                'SYSTEM_ADMINISTRATOR',
--                                                'STANDARD');
--     cnt:= fnd_sec_bulk.AddRespUserGroup(user_clause,
--                                   'FND',
--                                   'SYSTEM_ADMINISTRATOR_GUI',
--                                   '',
--                                   'New SYSADMIN responsibility');
--
-- OR  cnt:= fnd_sec_bulk.AddRespUserGroup(user_clause,
--                                   'FND',
--                                   'SYSTEM_ADMINISTRATOR_GUI',
--   end;
--
-- Input Arguments
--   x_user_group_clause:  A sql statement returns all user's user_id
--                         For example, "select user_id from fnd_user where..."
--   x_resp_application:   Responsibility application short name
--   x_responsibility:     Responsibility key
--   x_security_group:     Security Group. Default is null.
--                         If x_user_group_clause is provided from calling
--                         UserAssignResp(), then DO NOT pass in
--                         x_security_group.
--                         If x_user_group_clause is provided by yourself,
--                         then you SHOULD input the x_security_group.
--   x_description:        Description
--   x_start_date:         Start date
--   x_end_date:           End date

function AddRespUserGroup(
  x_user_group_clause          in varchar2,
  x_resp_application           in varchar2,
  x_responsibility             in varchar2,
  x_security_group             in varchar2 default '',
  x_description                in varchar2 default '',
  x_start_date                 in date default sysdate,
  x_end_date                   in date default null) return number is

  uid number := -1;
  respid number := -1;
  appid  number := -1;
  secid  number := -1;
  cnt number := 0;
  TYPE cur_typ IS REF CURSOR;
  c           cur_typ;

begin

  -- Do nothing if no user defined
  if (x_user_group_clause is null) then
    return(0);
  end if;

  -- Add a single responsibility to a group of users

  begin
  select application_id into appid
  from   fnd_application
  where  application_short_name = x_resp_application;
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'FND-INVALID APPLICATION');
      fnd_message.set_token('APPL', x_resp_application);
      app_exception.raise_exception;
  end;

  begin
  select responsibility_id into respid
  from   fnd_responsibility
  where  application_id = appid
  and    responsibility_key = x_responsibility;
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'FND-INVALID RESPONSIBILITY');
      fnd_message.set_token('RESP', x_responsibility);
      app_exception.raise_exception;
  end;

  -- Security group should copied from the original --

  if (x_security_group is not null) then
    begin
    select security_group_id into secid
    from   fnd_security_groups
    where  security_group_key = x_security_group;
    exception
      when no_data_found then
        fnd_message.set_name('FND', 'FND-INVALID SECURITY');
        fnd_message.set_token('SEC', x_security_group);
        app_exception.raise_exception;
    end;
  end if;

  cnt := 0;
  OPEN c FOR x_user_group_clause;
  LOOP
    if (x_security_group is not null) then
      FETCH c INTO uid;
    else
      FETCH c INTO uid, secid;
    end if;

    EXIT WHEN c%NOTFOUND;

    -- process each row (user)
    fnd_user_resp_groups_api.UPLOAD_ASSIGNMENT(
      USER_ID                       => uid,
      RESPONSIBILITY_ID             => respid,
      RESPONSIBILITY_APPLICATION_ID => appid,
      SECURITY_GROUP_ID             => secid,
      START_DATE                    => x_start_date,
      END_DATE                      => x_end_date,
      DESCRIPTION                   => x_description);

    cnt := cnt + 1;
  END LOOP;
  CLOSE c;

  return(cnt);
end AddRespUserGroup;

--------------------------------------------------------------------------
-- AddRespIdUserGroup
--   Assign a responsibility which identified by ID to a group of users.
--   The group of users is defined in x_user_group_clause.
--   You can optionally supply security, description, start_date and end_date.
--   The return value is the number of users processed.
--
-- Usage Example
--   declare
--     user_clause varchar2(2000);
--   begin
--     user_clause := fnd_sec_bulk.UserAssignRespId(0, 101, 'STANDARD');
--     cnt :=  fnd_sec_bulk.AddRespIdUserGroup(user_clause, 0, 20420);
--   end;
--
-- Input Arguments
--   x_user_group_clause:  A sql statement returns all user's user_id
--                         For example, "select user_id from fnd_user where..."
--   x_resp_application_id:Responsibility application id
--   x_responsibility_id:  Responsibility id
--   x_security_group:     Security Group. Default is null.
--                         If x_user_group_clause is provided from calling
--                         UserAssignRespId(), then DO NOT pass in
--                         x_security_group.
--                         If x_user_group_clause is provided by yourself,
--                         then you SHOULD input the x_security_group.
--   x_description:        Description
--   x_start_date:         Start date
--   x_end_date:           End date

function AddRespIdUserGroup(
  x_user_group_clause          in varchar2,
  x_resp_application_id        in number,
  x_responsibility_id          in number,
  x_security_group             in varchar2 default '',
  x_description                in varchar2 default '',
  x_start_date                 in date default sysdate,
  x_end_date                   in date default null) return number is

  uid number := -1;
  respid number := -1;
  appid  number := -1;
  secid  number := -1;
  cnt number := 0;
  TYPE cur_typ IS REF CURSOR;
  c           cur_typ;

begin

  -- Do nothing if no user defined
  if (x_user_group_clause is null) then
    return(0);
  end if;

  -- Add a single responsibility to a group of users

  begin
  select application_id into appid
  from fnd_application
  where application_id = x_resp_application_id;
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'FND-INVALID APPLICATION');
      fnd_message.set_token('APPL', to_char(x_resp_application_id));
      app_exception.raise_exception;
  end;

  begin
  select responsibility_id into respid
  from   fnd_responsibility
  where  application_id = appid
  and    responsibility_id = x_responsibility_id;
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'FND-INVALID RESPONSIBILITY');
      fnd_message.set_token('RESP', to_char(x_responsibility_id));
      app_exception.raise_exception;
  end;

  if (x_security_group is not null) then
    begin
    select security_group_id into secid
    from   fnd_security_groups
    where  security_group_key = x_security_group;
    exception
      when no_data_found then
        fnd_message.set_name('FND', 'FND-INVALID SECURITY');
        fnd_message.set_token('SEC', x_security_group);
        app_exception.raise_exception;
    end;
  end if;

  cnt := 0;
  OPEN c FOR x_user_group_clause;
  LOOP
    if (x_security_group is not null) then
      FETCH c INTO uid;
    else
      FETCH c INTO uid, secid;
    end if;

    EXIT WHEN c%NOTFOUND;

    -- process each row (user)
    fnd_user_resp_groups_api.UPLOAD_ASSIGNMENT(
      USER_ID                       => uid,
      RESPONSIBILITY_ID             => respid,
      RESPONSIBILITY_APPLICATION_ID => appid,
      SECURITY_GROUP_ID             => secid,
      START_DATE                    => x_start_date,
      END_DATE                      => x_end_date,
      DESCRIPTION                   => x_description);

    cnt := cnt + 1;
  END LOOP;
  CLOSE c;
  return(cnt);
end AddRespIdUserGroup;

--------------------------------------------------------------------------
-- UserAssignResp
--   Find all the users that have this given responsibility key and
--   security group pair.
--   Construct a full qualified sql statement to return all the user_ids.
--   So that this kind of sql statement can be used when calling
--   AddRespUserGroup().
-- Usage Example
--   declare
--     user_clause varchar2(2000);
--     cnt number;
--   begin
--     user_clause := fnd_sec_bulk.UserAssignResp('FND',
--                                                'SYSTEM_ADMINISTRATOR',
--                                                'STANDARD');
--     cnt := fnd_sec_bulk.AddRespUserGroup(user_clause,
--                                   'FND',
--                                   'SYSTEM_ADMINISTRATOR_GUI');
--   end;
-- Input Arguments
--   x_resp_application:   Responsibility application short name
--   x_responsibility:     Responsibility key
--   x_security_group:     Responsibility security group name

function UserAssignResp(
  x_resp_application          in varchar2,
  x_responsibility            in varchar2,
  x_security_group            in varchar2 default 'STANDARD')
  return varchar2 is

  user_group_clause varchar2(2000) := '';
  respid number := -1;
  appid  number := -1;
  secid  number := -1;
begin
  -- return a sql statement clause which defines a group of users

  begin

  select application_id into appid
  from   fnd_application
  where  application_short_name = x_resp_application;

  select security_group_id into secid
  from   fnd_security_groups
  where  security_group_key = x_security_group;

  select responsibility_id into respid
  from   fnd_responsibility
  where  application_id = appid
  and    responsibility_key = x_responsibility;

  user_group_clause :=
                  'select r.user_id, r.security_group_id ' ||
                  'from fnd_user_resp_groups r '||
                  'where r.responsibility_id = '||respid||
                  ' and r.security_group_id = '||secid||
                  ' and r.responsibility_application_id = '||appid;

  exception
    when no_data_found then
      user_group_clause := null;
  end;

  return(user_group_clause);

end UserAssignResp;


--------------------------------------------------------------------------
-- UserAssignRespId
--   Find all the users that have this given responsibility identified by ID
--   and security group pair.
--   Construct a full qualified sql statement to return all the user_ids.
--   So that this kind of sql statement can be used when calling
--   AddRespUserGroup().
-- Usage Example
--   declare
--     user_clause varchar2(2000);
--     cnt number;
--   begin
--     user_clause := fnd_sec_bulk.UserAssignRespId(0,101, 'STANDARD');
--
--     cnt := fnd_sec_bulk.AddRespIdUserGroup(user_clause, 0, 20420);
--   end;
-- Input Arguments
--   x_resp_application_id:Responsibility application id
--   x_responsibility_id:  Responsibility id
--   x_security_group:     Responsibility security group name

function UserAssignRespId(
  x_resp_application_id       in number,
  x_responsibility_id         in number,
  x_security_group            in varchar2 default 'STANDARD')
  return varchar2 is

  user_group_clause varchar2(2000) := '';
  respid number := -1;
  appid  number := -1;
  secid  number := -1;
begin
  -- return a sql statement clause which defines a group of users

  begin

  select application_id into appid
  from   fnd_application
  where  application_id = x_resp_application_id;

  select security_group_id into secid
  from   fnd_security_groups
  where  security_group_key = x_security_group;

  -- There was this upgrade script afpnls01.sql which deleted all the
  -- 107 responsibility from fnd_responsibility table. So, we have to
  -- skip this validation for that sake.
  -- Although the 107 responsibility got deleted from the table but
  -- all the assignments are still in fnd_user_resp_group table.
/*
  select responsibility_id into respid
  from   fnd_responsibility
  where  application_id = appid
  and    responsibility_id = x_responsibility_id;
*/
  respid := x_responsibility_id;



  user_group_clause :=
                  'select r.user_id, r.security_group_id '||
                  'from fnd_user_resp_groups r '||
                  'where r.responsibility_id = '||respid||
                  ' and r.security_group_id = '||secid||
                  ' and r.responsibility_application_id = '||appid;

  exception
    when no_data_found then
      user_group_clause := null;
  end;

  return(user_group_clause);

end UserAssignRespId;


--------------------------------------------------------------------------
-- UpdateUserGroup
--   Update some of user attributes for a group of users.
--   Non-specified attribute is treated as taking the current
--   default value.
--   The group of users is defined in x_user_group_clause which is a full
--   qualified "select" sql statement.
--
-- Input Arguments
--   x_user_group_clause:  A sql statement returns all user's user_id
--                         For example, "select user_id from fnd_user where..."
--   x_start_date:         Start date
--   x_end_date:           End date
--   x_description:        User Description
--   x_password_lifespan_access: To control password expiration
--   x_password_lifespan_days:  To  control password expiration
--   x_email_address:      User email address
--   x_fax:                User fax number

procedure UpdateUserGroup(
	x_user_group_clause          in varchar2,
	x_start_date                 in date default null,
	x_end_date                   in date default null,
	x_description                in varchar2 default null,
	x_password_lifespan_accesses in number default null,
	x_password_lifespan_days     in number default null,
	x_email_address              in varchar2 default null,
	x_fax	                       in varchar2 default null) is

	uid	number;
	TYPE cur_typ IS REF CURSOR;
	c		cur_typ;

begin

	if (x_user_group_clause is null) then
		return;
	end if;

	-- Update a group of user with the input user attriutes

	open c for x_user_group_clause;
	loop
		fetch c into uid;
		exit when c%NOTFOUND;

		update	fnd_user
		set		last_update_date = sysdate,
					start_date = nvl(x_start_date, start_date),
					end_date = nvl(x_end_date, end_date),
					description = nvl(x_description, description),
					password_lifespan_accesses = nvl(x_password_lifespan_accesses,
						password_lifespan_accesses),
					password_lifespan_days = nvl(x_password_lifespan_days,
						password_lifespan_days),
					email_address = nvl(x_email_address, email_address),
					fax = nvl(x_fax, fax)
		where		user_id = uid;

		-- Added for Function Security Cache Invalidation Project.
		fnd_function_security_cache.update_user(uid);

	end loop;
	close c;

end UpdateUserGroup;



--------------------------------------------------------------------------
-- UpdateUserGroupTemplate
--   Update a group of users to have the same privileges as the given
--   template user. Supported privileges are user attributes, assigned
--   responsibilities and profiles.
--   The group of users is defined in x_user_group_clause.
--   You can optionally choose to clone all user attributes, all
--   responsibilities or all profile options.
--
-- Usage Example
--   declare
--     user_clause varchar2(2000);
--   begin
--     user_clause := fnd_sec_bulk.UserAssignResp('FND',
--                                             'ASSISTANT_SYSTEM_ADMINISTRATOR',
--                                                'STANDARD');
--     /* This will give all users SYSADMIN's's profile but not */
--     /* responsibilities and other attributes. */
--     fnd_sec_bulk.UpdateUserGroupTemplate(user_clause,
--                                          'SYSADMIN',
--                                          FALSE, FALSE, TRUE);
--   end;
--
-- Input Arguments
--   x_user_group_clause:  A select sql statement returns all user's user_id
--                         For example, "select user_id from fnd_user where..."
--   x_template_user:      The user name that you are going to clone from
--   x_attribute_flag:     Whether to clone user attributes
--   x_responsibility_flag:Whether to clone responsibility
--   x_profile_flag:       Whether to clone profile

procedure UpdateUserGroupTemplate(
  x_user_group_clause    in varchar2,
  x_template_user              in varchar2,
  x_attribute_flag             in boolean default TRUE,
  x_responsibility_flag        in boolean default TRUE,
  x_profile_flag               in boolean default TRUE) is

  uname varchar2(100);
  uid number;
  TYPE cur_typ IS REF CURSOR;
  c           cur_typ;
begin
  -- Update a group of users by copying the user attributes, profile and
  -- responsibilities from a template user.
  -- x_attribute_flag, x_responsibility_flag and x_profile_flag is
  -- to control whether to copy those value.
  -- For example if you are going to assign bunch of users with the same
  -- privilege as user "ACCOUNT_MANAGER".


  if (x_user_group_clause is null) then
    return;
  end if;

  open c for x_user_group_clause;
  loop
    fetch c into uid;
    exit when c%NOTFOUND;

    begin
    select user_name into uname
    from fnd_user where user_id = uid;
    exception
      when no_data_found then
        -- just skip this user
        null;
    end;

    if (x_attribute_flag) then
      cloneuser_attr(x_template_user, uname, '', '');
    end if;

    if (x_responsibility_flag) then
      cloneuser_resp(x_template_user, uname);
    end if;

    if (x_profile_flag) then
      cloneuser_prof(x_template_user, uname);
    end if;

  end loop;
  close c;

end UpdateUserGroupTemplate;


--------------------------------------------------------------------------
-- DisableUserGroup
--   Disable a group of user by setting their end_date to sysdate.
--   The group of users is defined in x_user_group_clause.
--
-- Usage Example
--
-- Input Arguments
--   x_user_group_clause:  A sql statement returns all user's user_id

/*
procedure DisableUserGroup(
  x_user_group_clause    in varchar2) is

  sql_string varchar2(2000);
begin
  -- set end_date to disable group of users.

  sql_string := 'update fnd_user set end_date = sysdate where userid in ('||
                x_user_group_clause||')';
  execute immediate sql_string;

end DisableUserGroup;
*/

end FND_SEC_BULK;

/

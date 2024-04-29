--------------------------------------------------------
--  DDL for Package Body FND_USER_RESP_GROUPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_USER_RESP_GROUPS_API" as
/* $Header: AFSCURGB.pls 120.16.12010000.2 2012/07/17 12:55:26 srinnakk ship $ */

  C_PKG_NAME       CONSTANT VARCHAR2(30) := 'FND_USER_RESP_GROUPS_API';
  C_LOG_HEAD       CONSTANT VARCHAR2(240)
                               := 'fnd.plsql.FND_USER_RESP_GROUPS_API.';

-- This is a one level cache used in check_secgrp_enabled.
  G_ENABLED_RESPID NUMBER      := null;
  G_ENABLED_APPID  NUMBER      := null;
  G_ENABLED_RETVAL varchar2(1) := null;


--
-- Generic_Error (Internal)
--
-- Set error message and raise exception for unexpected sql errors.
--
procedure Generic_Error(
  routine in varchar2,
  errcode in number,
  errmsg in varchar2)
is
begin
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE', routine);
    fnd_message.set_token('ERRNO', errcode);
    fnd_message.set_token('REASON', errmsg);
    app_exception.raise_exception;
end Generic_Error;

--
-- Returns 'Y' if security groups are enabled for this app, 'N' otherwise.
--
function check_secgrp_enabled(respid in number, appid in number)
return varchar2
is
  prof_value varchar2(240);
begin
    /* Check one level cache first */
    if (    (G_ENABLED_RESPID = respid)
        and (G_ENABLED_APPID = appid)) then
       return G_ENABLED_RETVAL;
    end if;

    prof_value := nvl(fnd_profile.value_specific(
                        'ENABLE_SECURITY_GROUPS',
                        NULL,
                        respid,
                        appid),
                    'N');

    if (prof_value = 'N') then
      G_ENABLED_RETVAL := 'N';
    else
      G_ENABLED_RETVAL := 'Y';
    end if;

    G_ENABLED_RESPID := respid;
    G_ENABLED_APPID := appid;

    return G_ENABLED_RETVAL;
end check_secgrp_enabled;


--
-- Role_Name_from_Resp_name -
--
-- Returns role name in the format FND_RESP|SECGRPKEY|APPSNAME|RESPKEY
-- from the names passed in
--
function Role_Name_from_Resp_name(
  x_respkey in varchar2,
  x_applsname in varchar2,
  x_secgrpkey in varchar2) return varchar2 is
 rolename varchar2(1000);
begin

  rolename := 'FND_RESP'||'|'||
                x_applsname||'|'||
                x_respkey||'|'||
                x_secgrpkey;

  /* Colons are a special character that is currently not allowed in */
  /* workflow so we work around this by replacing it with the string %col.*/
  /* See bug 3591913.  If that is fixed we might be able to remove this. */
  rolename := replace(rolename, ':', '%col');

  if(LENGTHB(rolename) > 320) then
     /* This should never happen, but if it does, show what went wrong.*/
     rolename := substrb('UNEXPECTED_ERROR:KEYTOOBIG:Role_Name_from_Resp:'||
                        rolename, 1, 320);

  end if;

  return rolename;
end Role_Name_from_Resp_name;

--
-- Role_Name_from_Resp (INTERNAL ONLY)-
--
-- Returns role name in the format FND_RESP|APPSNAME|RESPKEY|SECGRPKEY
-- from the security group and resp passed in.
--
function Role_Name_from_Resp(
  x_resp_id in number,
  x_resp_appl_id in number,
  x_secgrp_id in number)
return varchar2 is
 rolename varchar2(1000);
 secgrpkey varchar2(30);
 appsname  varchar2(50);
 respkey   varchar2(30);
begin

  select security_group_key
    into secgrpkey
    from fnd_security_groups
   where security_group_id = x_secgrp_id;

  select application_short_name
    into appsname
    from fnd_application
   where application_id = x_resp_appl_id;

  select responsibility_key
    into respkey
    from fnd_responsibility
   where application_id = x_resp_appl_id
     and responsibility_id = x_resp_id;

  return Role_Name_from_Resp_name(respkey, appsname, secgrpkey);
end Role_Name_from_Resp;


/* This is a version of role_name_from_resp which won't return errors, */
/* to be used when calling from somewhere that errors can't be trapped */
/* like inline inside a SQL select statement */
function Role_Name_from_Resp_No_Exc(
  x_resp_id in number,
  x_resp_appl_id in number,
  x_secgrp_id in number)
 return varchar2 is
begin

  return fnd_user_resp_groups_api.Role_Name_from_Resp(
    x_resp_id,
    x_resp_appl_id,
    x_secgrp_id);

exception
  when no_data_found then
    return 'BAD_FK:'||x_resp_id||':'|| x_resp_appl_id ||':'||x_secgrp_id;
  when others then
    return 'ERROR:'||x_resp_id||':'|| x_resp_appl_id ||':'||x_secgrp_id;
end Role_Name_from_Resp_No_Exc;

-- Upgrade_Resp_Role
-- Converts role names from FND_RESPX:Y format to FND_RESP|A|B|C format
-- if necessary. returns upgraded role name or original.
function upgrade_resp_role(respid in number,
                            appid in number) return varchar2 is
  new_role_name varchar2(255);
begin

  begin
      new_role_name := fnd_user_resp_groups_api.Role_Name_from_Resp(
                   x_resp_id      => respid,
                   x_resp_appl_id => appid,
                   x_secgrp_id    => 0);

  exception
    when no_data_found then /* If invalid foreign keys, bail. */
      return 'INVALID_FK_APPID_'||appid||'_RESPID_'||respid;
  end;

  return new_role_name;
end upgrade_resp_role;

--
-- Assignment_Check (INTERNAL routine only)
--
-- Check whether a particular assignment of a user to a role exists,
-- regardless of start/end date.  This is different from
-- wf_directory.IsPerformer which only operates for current sysdate.
-- In: username- user name
-- In: rolename- role name
--
function Assignment_Check(username in varchar2,
                          rolename in varchar2,
                       direct_flag in varchar2)
 return boolean is
 result boolean;
 dummy number;
begin

 if(direct_flag = 'E') then
   begin
     select null
       into dummy
       from wf_all_user_roles
      where user_name = username
        and role_name = rolename
        and rownum = 1;
     result := TRUE;
   exception
    when no_data_found then
      result := FALSE;
    when others then
      Generic_Error('FND_USER_RESP_GROUPS_API.ASSIGNMENT_CHECK(E)',
         sqlcode, sqlerrm);
    end;
 elsif (direct_flag = 'D') then
   begin
     select null
       into dummy
       from wf_all_user_roles
      where user_name = username
        and role_name = rolename
        and assignment_type = direct_flag
        and rownum = 1;
     result := TRUE;
   exception
    when no_data_found then
      result := FALSE;
    when others then
      Generic_Error('FND_USER_RESP_GROUPS_API.ASSIGNMENT_CHECK(D)',
         sqlcode, sqlerrm);
    end;
 elsif (direct_flag = 'I') then
   begin
     select null
       into dummy
       from wf_all_user_roles
      where user_name = username
        and role_name = rolename
        and assignment_type = direct_flag
        and rownum = 1;
     result := TRUE;
   exception
    when no_data_found then
      result := FALSE;
    when others then
      Generic_Error('FND_USER_RESP_GROUPS_API.ASSIGNMENT_CHECK(I)',
         sqlcode, sqlerrm);
    end;
 end if;
 return result;
end Assignment_Check;

--
-- Assignment_Exists
--   Check if user/resp/group assignment exists.  This API does not check
--   start or end dates on the user, repsonsibility, or responsibility
--   assignment.
-- IN
--   user_id - User to get assignment
--   responsibility_id - Responsibility to be assigned
--   responsibility_application_id - Resp Application to be assigned
--   security_group_id - Security Group to be assigned (default to current)
--   direct_flag- 'D', 'I', or 'E' (default) determines whether this checks
--                indirect assignments from wf_role_hierarchy or just
--                direct assignments.
--     'D'= Direct only.     Dates can be updated.
--     'I'= Indirect only.   Dates cannot be updated on these assignments.
--     'E'= Either Direct or Indirect. (this is the default)
-- RETURNS
--   TRUE if assignment is found
--
function Assignment_Exists(
  user_id in number,
  responsibility_id in number,
  responsibility_application_id in number,
  security_group_id in number default null,
  direct_flag in varchar2 default null /* null means 'E': Direct or Indirect*/
  )
return boolean
is
  dummy number;
  sgid number;
  rolename varchar2(320);
  username varchar2(100);
  l_direct_flag varchar2(1);
begin
  if(direct_flag is NULL) then
    l_direct_flag := 'E'; /* Default to 'E' meaning Either direct or indirect*/
  else
    l_direct_flag := direct_flag;
  end if;

  if (security_group_id is null) then
    sgid := fnd_global.security_group_id;
  else
    sgid := security_group_id;
  end if;

  begin
    select user_name
      into username
      from fnd_user
     where user_id = assignment_exists.user_id;

    rolename := role_name_from_resp(responsibility_id,
                                  responsibility_application_id,
                                  sgid);

  exception  /* This exception handler is new to fix bug 3573846. */
    when no_data_found then
      /* If some data passed is invalid, there can't be an assignment.*/
      /* This preserves backward compatibility. */
      return FALSE;
  end;

  return Assignment_Check(
    username ,
    rolename,
    l_direct_flag);

exception
  when others then
    Generic_Error('FND_USER_RESP_GROUPS_API.ASSIGNMENT_EXISTS',
        sqlcode, sqlerrm);
end Assignment_Exists;


--
-- Validates the security context to determine if the given user has access
-- to the given responsibility.
-- IN
--   p_user_id - the user id
--   p_resp_appl_id - the application id of the responsibility
--   p_responsibility_id - the responsibility id
--   p_security_group_id - the security group id
-- OUT
--  x_status:
--    'N' if the security context is not valid
--    'Y' if the security context is valid
--
procedure validate_security_context(
  p_user_id            in  number,
  p_resp_appl_id       in  number,
  p_responsibility_id  in  number,
  p_security_group_id  in  number,
  x_status             out nocopy varchar2)
is
begin
  /* # Someday this routine could be reimplemented against the database */
  /* objects underlying the fnd_user_resp_groups view, but not needed now.*/
  x_status := 'N';

  select 'Y'
  into x_status
  from dual
  where exists
   (select null
    from fnd_user u,
         fnd_user_resp_groups urg,
         fnd_responsibility r
    where u.user_id = p_user_id
    and sysdate between u.start_date and nvl(u.end_date, sysdate)
    and urg.user_id = u.user_id
    and urg.responsibility_application_id = p_resp_appl_id
    and urg.responsibility_id = p_responsibility_id
    and urg.security_group_id in (-1, p_security_group_id)
/*NOT NEEDED: and sysdate between urg.start_date and nvl(urg.end_date,sysdate)*/
    and r.application_id = urg.responsibility_application_id
    and r.responsibility_id = urg.responsibility_id
    and sysdate between r.start_date and nvl(r.end_date, sysdate));
exception
  when no_data_found then
    x_status := 'N';

end validate_security_context;


--
-- Lock_Assignment
--   Lock the row for an assignment (used by a UI)
-- IN
--   user_id - User
--   responsibility_id - Responsibility
--   responsibility_application_id - Resp Application
--   security_group_id - Security Group
--   start_date - Start date of assignment
--   end_date - End date of assignment
--
procedure Lock_Assignment(
  x_user_id in number,
  x_responsibility_id in number,
  x_resp_application_id in number,
  x_security_group_id in number,
  x_start_date in date,
  x_end_date in date,
  x_description in varchar2)
is
  cursor c (user varchar2, role varchar2) is
   select start_date,
          end_date
     from wf_all_user_role_assignments    --BUG5467610
    where user_name = user
      and role_name = role
      and rownum = 1
      for update of start_date nowait;
  rolename varchar2(1000);
  username varchar2(100);
  recinfo c%rowtype;
begin

  select user_name
    into username
    from fnd_user
   where user_id = x_user_id;

  rolename := role_name_from_resp(x_responsibility_id,
                                  x_resp_application_id,
                                  x_security_group_id);

  open c(username, rolename);
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.start_date = x_start_date)
           OR ((recinfo.start_date is null) AND (x_start_date is null)))
      AND ((recinfo.end_date = x_end_date)
           OR ((recinfo.end_date is null) AND (x_end_date is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

end Lock_Assignment;


--
-- Insert_Assignment
--   Insert a new user/resp/group assignment
-- IN
--   user_id - User to get assignment
--   responsibility_id - Responsibility to be assigned
--   responsibility_application_id - Resp Application to be assigned
--   security_group_id - Security Group to be assigned
--   start_date - Start date of assignment
--   end_date - End date of assignment
--   description - Optional comment
-- EXCEPTION
--   If user/resp/group assignment already exists
--
procedure Insert_Assignment(
  user_id in number,
  responsibility_id in number,
  responsibility_application_id in number,
  security_group_id in number,
  start_date in date,
  end_date in date,
  description in varchar2)
is
 sgid number;
 rolename varchar2(4000);
 secgrpkey varchar2(30);
 appsname  varchar2(50);
 respkey   varchar2(30);
 username  varchar2(100);
 l_user_orig_system varchar2(30);
 l_user_orig_system_id number;
 result boolean;
 old_rolename varchar2(4000);
 l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin
  if (security_group_id is null) then
    sgid := fnd_global.security_group_id;
  else
    sgid := security_group_id;
  end if;

  rolename := role_name_from_resp(responsibility_id,
                                  responsibility_application_id,
                                  sgid);

  --
  -- Generate old role name for backwards compatibility.
  --

  old_rolename := 'FND_RESP'||responsibility_application_id||
                  ':'||responsibility_id;

  select user_name
    into username
    from fnd_user
   where user_id = Insert_assignment.user_id;


  select application_short_name
    into appsname
    from fnd_application
   where application_id = responsibility_application_id;


  /* Check whether there already is a direct row; if so, */
  /* we can't insert a duplicate. */
  result := assignment_check(username, rolename, 'D');
  if (result = TRUE) then
    fnd_message.set_name('FND', 'FND_CANT_INSERT_USER_ROLE');
    fnd_message.set_token('USERNAME', username);
    fnd_message.set_token('ROLENAME', rolename);
    fnd_message.set_token('ROUTINE',
                           'FND_USER_RESP_GROUPS_API.Insert_Assignment');
    app_exception.raise_exception;
  end if;


  /* We can't just assume that the orig system is FND_USR.  It could */
  /* be PER because the row in wf_users/wf_roles is one or the other */
  wf_directory.GetRoleOrigSysInfo(username,
                                    l_user_orig_system,
                                    l_user_orig_system_id);

  /* In case there is no WF user, sync this user up so there is one.*/
  /* Should never happen but be safe in case sync wasn't perfect in past */
  /* # Should we remove this code and just trust the bulk sync? */
  if(    (l_user_orig_system is NULL)
     and (l_user_orig_system_id is NULL)) then
     fnd_user_pkg.user_synch(username);
     wf_directory.GetRoleOrigSysInfo(username,
                                      l_user_orig_system,
                                      l_user_orig_system_id);
  end if;

  wf_local_synch.PropagateUserRole
                             (p_user_name=>username,
                              p_role_name=>rolename,
                              p_user_orig_system=>l_user_orig_system,
                              p_user_orig_system_id=>l_user_orig_system_id,
                              p_role_orig_system=>'FND_RESP',
                              p_role_orig_system_id=>responsibility_id,
                              p_start_date=>start_date,
                              p_expiration_date=>end_date,
                              p_overwrite=>TRUE,
                              p_raiseErrors=>TRUE,
                              p_parent_orig_system => 'FND_RESP',
                              p_parent_orig_system_id => responsibility_id,
                              p_ownerTag => appsname,
                              p_createdBy => fnd_global.user_id,/*Bug3626390*/
                              p_lastUpdatedBy => fnd_global.user_id,
                              p_lastUpdateLogin => 0,
                              p_creationDate => sysdate, /*Bug3626390 sysdate*/
                              p_lastUpdatedate=> sysdate,
                              p_assignmentReason=>description);

  --
  -- Need to propagate the old roles for backwards compatibility.
  --

  wf_local_synch.PropagateUserRole
                             (p_user_name=>username,
                              p_role_name=>old_rolename,
                              p_user_orig_system=>l_user_orig_system,
                              p_user_orig_system_id=>l_user_orig_system_id,
                              p_role_orig_system=>'FND_RESP'||responsibility_application_id,
                              p_role_orig_system_id=>responsibility_id,
                              p_start_date=>start_date,
                              p_expiration_date=>end_date,
                              p_overwrite=>TRUE,
                              p_raiseErrors=>TRUE,
                              p_parent_orig_system => 'FND_RESP'||responsibility_application_id,
                              p_parent_orig_system_id => responsibility_id,
                              p_ownerTag => appsname,
                              p_createdBy => fnd_global.user_id,/*Bug3626390*/
                              p_lastUpdatedBy => fnd_global.user_id,
                              p_lastUpdateLogin => 0,
                              p_creationDate => sysdate, /*Bug3626390 sysdate*/
                              p_lastUpdatedate=> sysdate,
                              p_assignmentReason=>description);

  wf_event.raise('oracle.apps.fnd.security.user.assignment.change',
                   Insert_Assignment.user_id||':'||
                             Insert_Assignment.responsibility_id,
                   null, null);
 --we have to raise a differnt event as for USER_INFO_CACHE
 --the key should be just the user_id
 wf_event.addparametertolist(p_name          => 'FND_USER_ID',
                             p_value         => Insert_Assignment.user_id,
                             p_parameterlist => l_parameters);

 wf_event.addparametertolist(p_name          => 'FND_RESPONSIBILITY_ID',
                             p_value         => Insert_Assignment.responsibility_id,
                             p_parameterlist => l_parameters);

 wf_event.addparametertolist(p_name          => 'FND_APPS_SHORT_NAME',
                             p_value         => appsname,
                             p_parameterlist => l_parameters);

 wf_event.addparametertolist(p_name          => 'FND_RESPONSIBILITY_APPS_ID',
                             p_value         => Insert_Assignment.responsibility_application_id,
                             p_parameterlist => l_parameters);

 wf_event.raise(p_event_name => 'oracle.apps.fnd.user.role.insert',
                p_event_key  => to_char(Insert_Assignment.user_id)||':'||to_char(Insert_Assignment.responsibility_id)||':'||appsname||':'||to_char(Insert_Assignment.responsibility_application_id),
                  p_event_data => NULL,
                  p_parameters => l_parameters,
                  p_send_date  => Sysdate);

exception
  when others then
    Generic_Error('FND_USER_RESP_GROUPS_API.INSERT_ASSIGNMENT',
        sqlcode, sqlerrm);
end Insert_Assignment;

--
-- Update_Assignment
--   Update an existing user/resp/group assignment
-- IN
-- KEY VALUES:  These columns identify row to update
--   user_id - User to get assignment
--   responsibility_id - Responsibility to be assigned
--   responsibility_application_id - Resp Application to be assigned
--   security_group_id - Security Group to be assigned
-- UPDATE VALUES: These columns identify values to update
--   start_date - Start date of assignment
--   end_date - End date of assignment
--   description - Optional comment
-- FLAGS
--   update_who_columns- pass 'Y' or 'N' ('Y' is default if not passed)
--     'N' = leave old who vals.  'Y'= update who cols to current user/date
-- EXCEPTION
--   If user/resp/group assignment does not exist
--
procedure Update_Assignment(
  user_id in number,
  responsibility_id in number,
  responsibility_application_id in number,
  security_group_id in number,
  start_date in date,
  end_date in date,
  description in varchar2,
  update_who_columns in varchar2 default null
     /* 'N' = leave old who vals.  'Y' (default) = update who to current*/)
is
  sgid number;
  rolename varchar2(4000);
  secgrpkey varchar2(30);
  appsname  varchar2(50);
  respkey   varchar2(30);
  username  varchar2(100);
  l_user_orig_system varchar2(30);
  l_user_orig_system_id number;
  result boolean;
  old_rolename varchar2(4000);
  l_parameters wf_parameter_list_t := wf_parameter_list_t();
  l_last_update_date date;
  l_last_updated_by number;
  l_last_update_login number;
  l_creation_date date;
  l_created_by number;
  l_update_who boolean;  --Bug5467610
begin

  if (security_group_id is null) then
    sgid := fnd_global.security_group_id;
  else
    sgid := security_group_id;
  end if;

  rolename := role_name_from_resp(responsibility_id,
                                  responsibility_application_id,
                                  sgid);

  --
  -- Generate old role name for backwards compatibility.
  --

  old_rolename := 'FND_RESP'||responsibility_application_id||
                  ':'||responsibility_id;

  select user_name
    into username
    from fnd_user
   where user_id = Update_assignment.user_id;


  select application_short_name
    into appsname
    from fnd_application
   where application_id = responsibility_application_id;


  /* Check whether there already is a direct row to update; if not, */
  /* the caller probably queried an indirect row and is trying to */
  /* update it which is not allowed. */
  result := assignment_check(username, rolename,'D');
  if (result = FALSE) then
    fnd_message.set_name('FND', 'FND_CANT_UPDATE_USER_ROLE');
    fnd_message.set_token('USERNAME', username);
    fnd_message.set_token('ROLENAME', rolename);
    fnd_message.set_token('ROUTINE',
                           'FND_USER_RESP_GROUPS_API.Update_Assignment');
    app_exception.raise_exception;
  end if;

  /* We can't just assume that the orig system is FND_USR.  It could */
  /* be PER because the row in wf_users/wf_roles is one or the other */
  wf_directory.GetRoleOrigSysInfo(username,
                                    l_user_orig_system,
                                    l_user_orig_system_id);

  /* In case there is no WF user, sync this user up so there is one.*/
  /* Should never happen but be safe in case sync wasn't perfect in past */
  /* # Should we remove this code and just trust bulk sync?*/
  if(    (l_user_orig_system is NULL)
     and (l_user_orig_system_id is NULL)) then
     fnd_user_pkg.user_synch(username);
     wf_directory.GetRoleOrigSysInfo(username,
                                      l_user_orig_system,
                                      l_user_orig_system_id);
  end if;

  /* Get the old who values.  Note that there is no exception handler around*/
  /* this because the assignment_check() above should have already verified */
  /* that we have the row.  */
  /* NOTE: Workflow has added support for '*NOCHANGE*' for the who  */
  /*       parameters for RUP4.  This SQL will be removed and this option */
  /*       will be used */
 -- Bug5121512 - Replaced SQL to eliminate the case where it is returning
 -- a 1422.
 -- Bug5467610 Removing the following SQL as it is no longer needed and adding
 -- the p_updatewho parameter to the wf_local_synch.PropagateUserRole call.

--   select created_by, creation_date, last_updated_by,
--         last_update_date, last_update_login
--   into l_created_by, l_creation_date, l_last_updated_by,
--        l_last_update_date, l_last_update_login
--   from wf_all_user_roles
--     where  user_name = Update_Assignment.username
--     and role_orig_system_id = Update_Assignment.responsibility_id
--     and role_name = Update_Assignment.rolename
--     and role_orig_system = 'FND_RESP';

  /* If we passed the flag saying to update the who columns */
  /* then we set the last_update who columns to current user/date. */
  if (update_who_columns = 'Y') then
     l_last_updated_by :=  fnd_global.user_id;
     l_last_update_login :=  0;
     l_last_update_date := sysdate;
     l_update_who := TRUE;     -- Bug5467610 update who columns.
  end if;


  -- Bug4747169 - Removed passing in the parameters p_created_by and
  --              p_creation_date as this is the update processing.

 wf_local_synch.PropagateUserRole
                             (p_user_name=>username,
                              p_role_name=>rolename,
                              p_user_orig_system=>l_user_orig_system,
                              p_user_orig_system_id=>l_user_orig_system_id,
                              p_role_orig_system=>'FND_RESP',
                              p_role_orig_system_id=>responsibility_id,
                              p_start_date=>start_date,
                              p_expiration_date=>end_date,
                              p_overwrite=>TRUE,
                              p_raiseErrors=>TRUE,
                              p_parent_orig_system => 'FND_RESP',
                              p_parent_orig_system_id => responsibility_id,
                              p_ownerTag => appsname,
                              p_createdBy => l_created_by,
                              p_creationDate => l_creation_date, /*Bug3626390 sysdate*/
                              p_lastUpdatedate=> l_last_update_date,
                              p_lastUpdatedBy => l_last_updated_by,
                              p_lastUpdateLogin => l_last_update_login,
                              p_assignmentReason=>description,
                              p_updatewho => l_update_who); -- Bug5467610

--
-- Need to propagate the old role name
--

 wf_local_synch.PropagateUserRole
                             (p_user_name=>username,
                              p_role_name=>old_rolename,
                              p_user_orig_system=>l_user_orig_system,
                              p_user_orig_system_id=>l_user_orig_system_id,
                              p_role_orig_system=>'FND_RESP'||responsibility_application_id,
                              p_role_orig_system_id=>responsibility_id,
                              p_start_date=>start_date,
                              p_expiration_date=>end_date,
                              p_overwrite=>TRUE,
                              p_raiseErrors=>TRUE,
                              p_parent_orig_system => 'FND_RESP'||responsibility_application_id,
                              p_parent_orig_system_id => responsibility_id,
                              p_ownerTag => appsname,
                              p_createdBy => l_created_by,
                              p_creationDate => l_creation_date, /*Bug3626390 sysdate*/
                              p_lastUpdatedate=> l_last_update_date,
   			      p_lastUpdatedBy => l_last_updated_by,
                              p_lastUpdateLogin => l_last_update_login,
                              p_assignmentReason=>description,
                              p_updatewho => l_update_who); -- Bug5467610


  wf_event.raise('oracle.apps.fnd.security.user.assignment.change',
                   Update_Assignment.user_id||':'||
                             Update_Assignment.responsibility_id,
                   null, null);
  --Raise the invalidation event attached to the USER_INFO_CACHE
  --(ideally this should be done by the wf API once the propagation
  --has been sucessful) / or if they are not doing it then we should attach
  --our business event to the CACHE as we do not really know what
  --subscriptions are attcahed to the wf event.
  --o.k putting our event (but we need to change the b3664848.ldt
  --and the event-subscription file to attach this event to the
  --bes control group.
  wf_event.addparametertolist(p_name          => 'FND_USER_ID',
                             p_value         => Update_Assignment.user_id,
                             p_parameterlist => l_parameters);

 wf_event.addparametertolist(p_name          => 'FND_RESPONSIBILITY_ID',
                             p_value         => Update_Assignment.responsibility_id,
                             p_parameterlist => l_parameters);

 wf_event.addparametertolist(p_name          => 'FND_APPS_SHORT_NAME',
                             p_value         => appsname,
                             p_parameterlist => l_parameters);

 wf_event.addparametertolist(p_name          => 'FND_RESPONSIBILITY_APPS_ID',
                             p_value         => Update_Assignment.responsibility_application_id,
                             p_parameterlist => l_parameters);

 wf_event.raise(p_event_name => 'oracle.apps.fnd.user.role.update',
                p_event_key  => to_char(Update_Assignment.user_id)||':'||to_char(Update_Assignment.responsibility_id)||':'||appsname||':'||to_char(Update_Assignment.responsibility_application_id),
                  p_event_data => NULL,
                  p_parameters => l_parameters,
                  p_send_date  => Sysdate);

exception
  when others then
    Generic_Error('FND_USER_RESP_GROUPS_API.UPDATE_ASSIGNMENT',
        sqlcode, sqlerrm);

end Update_Assignment;

procedure LOAD_ROW (
  X_USER_NAME		in	VARCHAR2,
  X_RESP_KEY		in	VARCHAR2,
  X_APP_SHORT_NAME	in	VARCHAR2,
  X_SECURITY_GROUP	in	VARCHAR2,
  X_OWNER               in	VARCHAR2,
  X_START_DATE		in	VARCHAR2,
  X_END_DATE		in	VARCHAR2,
  X_DESCRIPTION		in	VARCHAR2,
  X_LAST_UPDATE_DATE    in      DATE default sysdate) is
    u_id      number;
    app_id    number;
    resp_id   number;
    sgroup_id number;
    l_end_date varchar2(4000);
    l_owner number;
    rolename varchar2(4000);
    l_user_orig_system varchar2(30);
    l_user_orig_system_id number;
    old_rolename varchar2(4000);

begin
  select user_id into u_id
  from   fnd_user
  where  user_name = X_USER_NAME;

  select application_id into app_id
  from   fnd_application
  where  application_short_name = X_APP_SHORT_NAME;

  select responsibility_id into resp_id
  from   fnd_responsibility
  where  responsibility_key = X_RESP_KEY
  and    application_id = app_id;

  select security_group_id into sgroup_id
  from   fnd_security_groups
  where  security_group_key = X_SECURITY_GROUP;

  select decode(X_END_DATE,
                fnd_load_util.null_value, null,
                null, X_END_DATE,
                X_END_DATE)
  into l_end_date
  from dual;

  -- bug3649874 Modified to use fnd_load_util to get the owner_id

  l_owner := fnd_load_util.owner_id(X_OWNER);

  fnd_user_resp_groups_api.UPLOAD_ASSIGNMENT(
    USER_ID                       => u_id,
    RESPONSIBILITY_ID             => resp_id,
    RESPONSIBILITY_APPLICATION_ID => app_id,
    SECURITY_GROUP_ID             => sgroup_id,
    START_DATE                    => to_date(X_START_DATE, 'YYYY/MM/DD'),
    END_DATE                      => to_date(l_end_date, 'YYYY/MM/DD'),
    DESCRIPTION                   => X_DESCRIPTION);

  --------------------------------------------------------------------------
  -- The upload_assignment routine uses fnd_global.user_id and
  -- fnd_global.login_id which is not what we want for loader updates.
  -- Also upload_assignment only updates created_by if the row was just
  -- created.
  -- Added call to PropagateUserRole to correctly set the who columns.
  --------------------------------------------------------------------------
  rolename := Role_Name_from_Resp_name(
                X_RESP_KEY,
                X_APP_SHORT_NAME,
                X_SECURITY_GROUP);
  --
  -- Generate old role name for backwards compatibility.
  --

  old_rolename := 'FND_RESP'||app_id||
                  ':'||resp_id;

  -- Bug3649874 propagate the who columns

  wf_directory.GetRoleOrigSysInfo(x_user_name,
                                 l_user_orig_system,
                                 l_user_orig_system_id);

  wf_local_synch.PropagateUserRole
                          (p_user_name=>x_user_name,
                           p_role_name=>rolename,
                           p_user_orig_system=>l_user_orig_system,
                           p_user_orig_system_id=>l_user_orig_system_id,
                           p_role_orig_system=>'FND_RESP',
                           p_role_orig_system_id=>resp_id,
                           p_start_date=> to_date(X_START_DATE, 'YYYY/MM/DD'),
                           p_expiration_date=>to_date(l_end_date, 'YYYY/MM/DD'),
                           p_overwrite=>TRUE,
                           p_raiseErrors=>TRUE,
                           p_parent_orig_system => 'FND_RESP',
                           p_parent_orig_system_id => resp_id,
                           p_ownerTag => X_APP_SHORT_NAME,
                           p_createdBy => l_owner,
                           p_creationDate => sysdate, /*Bug3626390 sysdate*/
                           p_lastUpdatedate=> x_last_update_date,
                           p_lastUpdatedBy => l_owner,
                           p_lastUpdateLogin => 0,
                           p_assignmentReason=>X_DESCRIPTION);


--
-- Need to propagate the old role name
--

wf_local_synch.PropagateUserRole
                          (p_user_name=>x_user_name,
                           p_role_name=>old_rolename,
                           p_user_orig_system=>l_user_orig_system,
                           p_user_orig_system_id=>l_user_orig_system_id,
                           p_role_orig_system=>'FND_RESP'||app_id,
                           p_role_orig_system_id=>resp_id,
                           p_start_date=> to_date(X_START_DATE, 'YYYY/MM/DD'),
                           p_expiration_date=>to_date(l_end_date, 'YYYY/MM/DD'),
                           p_overwrite=>TRUE,
                           p_raiseErrors=>TRUE,
                           p_parent_orig_system => 'FND_RESP'||app_id,
                           p_parent_orig_system_id => resp_id,
                           p_ownerTag => X_APP_SHORT_NAME,
                           p_createdBy => l_owner,
                           p_lastUpdatedBy => l_owner,
                           p_lastUpdateLogin => 0,
                           p_creationDate => sysdate, /*Bug3626390 sysdate*/
                           p_lastUpdatedate=> x_last_update_date,
                           p_assignmentReason=>X_DESCRIPTION);

end LOAD_ROW;

--
-- Upload_Assignment
--   Update user/resp/group assignment if it exists,
--   otherwise insert new assignment.
-- IN
--   user_id - User to get assignment
--   responsibility_id - Responsibility to be assigned
--   responsibility_application_id - Resp Application to be assigned
--   security_group_id - Security Group to be assigned
--   start_date - Start date of assignment
--   end_date - End date of assignment
--   description - Optional comment
--   update_who_columns- pass 'Y' or 'N' ('Y' is default if not passed)
--     'N' = leave old who vals.  'Y'= update who cols to current user/date

--
procedure Upload_Assignment(
  user_id in number,
  responsibility_id in number,
  responsibility_application_id in number,
  security_group_id in number,
  start_date in date,
  end_date in date,
  description in varchar2,
  update_who_columns in varchar2 default null
     /* 'N' = leave old who vals.  'Y' (default) = update who to current*/)
is
  sgid number;
begin

  if (security_group_id is null) then
    sgid := fnd_global.security_group_id;
  else
    sgid := security_group_id;
  end if;

  if (Fnd_User_Resp_Groups_Api.Assignment_Exists(
          Upload_Assignment.user_id,
          Upload_Assignment.responsibility_id,
          Upload_Assignment.responsibility_application_id,
          Upload_Assignment.sgid,
          'D'))
  then
    Fnd_User_Resp_Groups_Api.Update_Assignment(
      Upload_Assignment.user_id,
      Upload_Assignment.responsibility_id,
      Upload_Assignment.responsibility_application_id,
      Upload_Assignment.sgid,
      Upload_Assignment.start_date,
      Upload_Assignment.end_date,
      Upload_Assignment.description,
      update_who_columns);
  else
    Fnd_User_Resp_Groups_Api.Insert_Assignment(
      Upload_Assignment.user_id,
      Upload_Assignment.responsibility_id,
      Upload_Assignment.responsibility_application_id,
      Upload_Assignment.sgid,
      Upload_Assignment.start_date,
      Upload_Assignment.end_date,
      Upload_Assignment.description);
  end if;
exception
  when others then
    Generic_Error('FND_USER_RESP_GROUPS_API.UPLOAD_ASSIGNMENT',
        sqlcode, sqlerrm);
end Upload_Assignment;

--
-- Sync_roles_one_resp_secgrp
--   Sync the role for a particular resp and security group.
--
procedure sync_roles_one_resp_secgrp(
                   respid in number,
                   appid in number,
                   respkey in varchar2,
                   secgrpid in number,
                   secgrpkey in varchar2,
                   startdate in date,
                   enddate in date)
is
  l_respkey varchar2(30);
  l_secgrpkey varchar2(30);
  applsname varchar2(50);
  role_name varchar2(320);
  role_display_name varchar2(1000);
  secgrp_name varchar2(80);
  resp_name varchar2(100);
  descr     varchar2(240);
  wf_parameters wf_parameter_list_t;
  old_rolename varchar2(320);
  -- Bug4507634 - Parameters needed to determine WF STATUS.
  my_exp    date;
  my_start  date;
  my_creationdate date;
  my_lastupdatedate date;
  my_createdby number;
  my_lastupdatedby number;
  my_lastupdatelogin number;

begin

  --
  -- Generate old role name for backwards compatibility.
  --

  old_rolename := 'FND_RESP'||appid||
                  ':'||respid;

  /* If caller didn't have respkey to pass, get it from respid/appid */
  if (respkey is null) then
    begin
      select responsibility_key
        into l_respkey
        from fnd_responsibility
       where responsibility_id = respid
         and application_id = appid;
    exception
      when no_data_found then
        return; /* Bad foreign key; we can't build a role. Return. */
    end;
  else
    l_respkey := respkey;
  end if;

  /* If caller didn't have secgrpkey to pass, get it from secgrpid */
  if (secgrpkey is null) then
    begin
      select security_group_key
        into l_secgrpkey
        from fnd_security_groups
       where security_group_id = secgrpid;
    exception
      when no_data_found then
        return; /* Bad foreign key; we can't build a role. Return. */
    end;
  else
    l_secgrpkey := secgrpkey;
  end if;

  /* Get the application short name for role name */
  begin
    select application_short_name
      into applsname
      from fnd_application
     where application_id = appid;

    role_name := fnd_user_resp_groups_api.role_name_from_resp_name(
                   respkey, applsname, secgrpkey);

  exception
    when no_data_found then
       /* invalid foreign key to a nonexistant app. Skip. */
       role_name := null;
       applsname := null;
       return;
  end;

  /* Get the responsibility name of base language for role display name */
  begin
    select responsibility_name, description
      into resp_name, descr
      from fnd_responsibility_tl
     where responsibility_id = respid
       and application_id = appid
       and language = (select language_code
                         from fnd_languages
                        where installed_flag = 'B');
  exception
    when no_data_found then
      /* This shouldn't normally happen, it's just for bad TL tables*/
      resp_name := applsname ||':'||respkey;
      descr := NULL;
  end;

  /* Get the security group name of base language for role display name */
  /* Don't need the name for STANDARD, so skip the select */
  if (secgrpid <> 0) then
    begin
      select security_group_name
        into secgrp_name
        from fnd_security_groups_tl
        where security_group_id = secgrpid
        and language = (select language_code
                           from fnd_languages
                          where installed_flag = 'B');
    exception
      when no_data_found then
        /* This shouldn't normally happen, it's just for bad TL tables*/
        secgrp_name := secgrpkey;
    end;
  end if;

   -- Bug4507634 Need to attain values for start/end date in order to
   -- correctly update the status in WF.

   -- Bug4864465 Added getting the WHO column data also.

   begin
    select start_date, end_date,
           created_by, creation_date,
           last_updated_by, last_update_date, last_update_login
     into   my_start, my_exp, my_createdby, my_creationdate,
            my_lastupdatedby, my_lastupdatedate, my_lastupdatelogin
     from   fnd_responsibility
     where responsibility_id = respid
     and application_id = appid;
   exception
      when no_data_found then
        return; /* Bad foreign key; we can't build a role. Return. */
   end;

  -- Insert or update role in workflow.
  -- Need to do this even if role already exists, to update
  -- attribute values.
  wf_parameters := NULL;
  wf_event.AddParameterToList('USER_NAME',
                               role_name , wf_parameters);
  if(secgrpkey = 'STANDARD') then
     role_display_name := resp_name;
  else
     role_display_name := resp_name||':'||secgrp_name;
  end if;

  wf_event.AddParameterToList('DISPLAYNAME',
                              role_display_name, wf_parameters);
  wf_event.AddParameterToList('DESCRIPTION',
                              descr, wf_parameters);
  wf_event.AddParameterToList('OWNER_TAG',
                              applsname, wf_parameters);
  wf_event.AddParameterToList('RAISEERRORS',
                              'TRUE', wf_parameters);

  -- Bug4507634 added WFSYNCH_OVERWRITE and ORCLISENABLED parameters.

  wf_event.AddParameterToList('WFSYNCH_OVERWRITE',
                               'TRUE', wf_parameters);
   if ((my_exp is null) OR
      (trunc(sysdate) between my_start and my_exp)) then
     wf_event.AddParameterToList('ORCLISENABLED', 'ACTIVE', wf_parameters);
   else
     wf_event.AddParameterToList('ORCLISENABLED', 'INACTIVE', wf_parameters);
   end if;

  -- Bug4864465 Adding the WHO column values to be propagated.

  wf_event.AddParameterToList('LAST_UPDATED_BY',my_lastupdatedby,wf_parameters);

  -- Bug5729583 - Updated date values to use WF_CORE.canonical_date_mask.

  wf_event.AddParameterToList('LAST_UPDATE_DATE',
                              to_char(my_lastupdatedate,WF_CORE.canonical_date_mask),wf_parameters);
  wf_event.AddParameterToList('CREATED_BY',my_createdby,wf_parameters);

  -- Bug5729583 - Updated date values to use WF_CORE.canonical_date_mask.

  wf_event.AddParameterToList('CREATION_DATE',to_char(my_creationdate,WF_CORE.canonical_date_mask),wf_parameters);
  wf_event.AddParameterToList('LAST_UPDATE_LOGIN',
                              my_lastupdatelogin,wf_parameters);

  wf_local_synch.propagate_role(p_orig_system=>'FND_RESP',
                                p_orig_system_id=>respid,
                                p_attributes=> wf_parameters,
                                p_start_date=>startdate,
                                p_expiration_date=>enddate);

  -- Insert or update role in workflow for old_rolename.
  wf_parameters := NULL;
  wf_event.AddParameterToList('USER_NAME',
                               old_rolename , wf_parameters);

  role_display_name := resp_name||':Any security group';

  wf_event.AddParameterToList('DISPLAYNAME',
                              role_display_name, wf_parameters);
  wf_event.AddParameterToList('DESCRIPTION',
                              descr, wf_parameters);
  wf_event.AddParameterToList('OWNER_TAG',
                              applsname, wf_parameters);
  wf_event.AddParameterToList('RAISEERRORS',
                              'TRUE', wf_parameters);

  -- Bug4507634 added WFSYNCH_OVERWRITE parameter.

  wf_event.AddParameterToList('WFSYNCH_OVERWRITE',
                               'TRUE', wf_parameters);

  -- Bug4699363 added parameter for ORCLISENABLED.

  if ((my_exp is null) OR
       (trunc(sysdate) between my_start and my_exp)) then
      wf_event.AddParameterToList('ORCLISENABLED', 'ACTIVE', wf_parameters);
  else
      wf_event.AddParameterToList('ORCLISENABLED', 'INACTIVE', wf_parameters);
  end if;

 -- Bug4864465 Adding the WHO column values to be propagated.

  wf_event.AddParameterToList('LAST_UPDATED_BY',my_lastupdatedby,wf_parameters);

 -- Bug5729583 - Updated date values to use WF_CORE.canonical_date_mask.

  wf_event.AddParameterToList('LAST_UPDATE_DATE',
                              to_char(my_lastupdatedate,WF_CORE.canonical_date_mask), wf_parameters);
  wf_event.AddParameterToList('CREATED_BY',my_createdby, wf_parameters);
  wf_event.AddParameterToList('CREATION_DATE',to_char(my_creationdate,WF_CORE.canonical_date_mask),wf_parameters);
  wf_event.AddParameterToList('LAST_UPDATE_LOGIN',
                              my_lastupdatelogin, wf_parameters);

  wf_local_synch.propagate_role(p_orig_system=>'FND_RESP'||appid,
                                p_orig_system_id=>respid,
                                p_attributes=> wf_parameters,
                                p_start_date=>startdate,
                                p_expiration_date=>enddate);

end sync_roles_one_resp_secgrp;

--
-- sync_roles_all_secgrps
--   For a given resp, sync roles for all security groups
-- NOTE: This is intended to be called whenever a responsibility
-- is inserted or updated.
--

procedure sync_roles_all_secgrps(
                   respid in number,
                   appid in number,
                   respkey in varchar2,
                   startdate in date,
                   enddate in date)
 is
    cursor get_secgrp is
                select  security_group_id,
                        security_group_key
                  from  fnd_security_groups;

begin

  if (check_secgrp_enabled(respid, appid) = 'N') then
       -- Security Groups not enabled for this resp,
       -- only create a role for the STANDARD sec grp.
       sync_roles_one_resp_secgrp( respid=>    respid,
                           appid=>     appid,
                           respkey=>   respkey,
                           secgrpid=>  0,
                           secgrpkey=> 'STANDARD',
                           startdate=> startdate,
                           enddate=>   enddate);
  else
    -- Security Groups are enabled, create one role for
    -- every resp/secgrp pair.
    for secrec in get_secgrp loop
         sync_roles_one_resp_secgrp(
                   respid => respid,
                   appid => appid,
                   respkey => respkey,
                   secgrpid => secrec.security_group_id,
                   secgrpkey => secrec.security_group_key,
                   startdate => startdate,
                   enddate => enddate);
    end loop;
  end if;

end sync_roles_all_secgrps;

--
-- sync_roles_all_resps
--   For a given security group, sync roles for all responsibilities
-- NOTE: This is intended to be called whenever a security group
-- is inserted or updated.
-- ### Security groups can be deleted, should also sync that.
--
procedure sync_roles_all_resps(secgrpid in varchar2,
                               secgrpkey in varchar2) is
   cursor get_resp is
                select  application_id,
                        responsibility_id,
                        responsibility_key,
                        start_date,
                        end_date
                  from  fnd_responsibility;
begin
  for resprec in get_resp loop
    -- If secgrp is STANDARD, then create resp/secgrp role for all resps.
    -- Otherwise, only create roles for resps with security groups enabled.
    if ((secgrpid = 0) or
        (check_secgrp_enabled(resprec.responsibility_id,
                              resprec.application_id) = 'Y'))
    then
        sync_roles_one_resp_secgrp(
                   resprec.responsibility_id,
                   resprec.application_id,
                   resprec.responsibility_key,
                   secgrpid,
                   secgrpkey,
                   resprec.start_date,
                   resprec.end_date);
    end if;
  end loop;

end sync_roles_all_resps;

--
-- sync_roles_all_resp_secgrps
--   Create roles for all resp/security group pairs.
--
-- Bug4349774 - Added sync_all_flag to default to previous behavior
--              where if TRUE is passed then updates and inserts are
--              processed otherwise only inserts are done.

procedure sync_roles_all_resp_secgrps (sync_all_flag in boolean default FALSE)
   is
   cursor get_resp is
                select  application_id,
                        responsibility_id,
                        responsibility_key,
                        start_date,
                        end_date
                  from  fnd_responsibility;
begin

  if (sync_all_flag = TRUE) then
      for resprec in get_resp loop
    sync_roles_all_secgrps(respid=>    resprec.responsibility_id,
                               appid=>     resprec.application_id,
                               respkey=>   resprec.responsibility_key,
                               startdate=> resprec.start_date,
                               enddate=>   resprec.end_date);
    commit;
   end loop;
 else
  -- Bug4322412 changed call to internal procedure so that if the role
  -- exists we do not waste time updating again.

  for resprec in get_resp loop
    sync_roles_all_secgrps_int(respid=>    resprec.responsibility_id,
                               appid=>     resprec.application_id,
                               respkey=>   resprec.responsibility_key,
                               startdate=> resprec.start_date,
                               enddate=>   resprec.end_date);
    commit;
  end loop;
end if;

end sync_roles_all_resp_secgrps;


--
-- Moves old data from fnd_user_resp_groups table to new workflow tables.
-- This routine is exposed so that it can be called from a one time
-- upgrade script, and it should never need to be run after that.
-- Running it unnecessarily might invalidate work that
-- admins have done to split assignments out into roles
--
-- Before calling this, make sure you have called
-- sync_roles_all_resp_secgrps() in order to get the roles in place that
-- this routine will depend on.
--
-- OBSOLETE: This functionality is now in the bulk sync of FND_RESP
-- which is called from the affurgol.sql script.
-- This code is just here in case the bulk sync fails as a last ditch
-- effort this code could be called.
procedure one_time_furg_to_wf_upgrade is  /* THIS ROUTINE IS OBSOLETE */
begin
  null; /* ### Stubbed ### */
/*
   l_api_name  CONSTANT VARCHAR2(30) := 'one_time_furg_to_wf_upgrade';
   cursor get_old_row is
                select   fu.user_name,
                         secgrp.security_group_key,
                         app.application_short_name,
                         resp.responsibility_key,
                         resp.start_date resp_start_date,
                         resp.end_date resp_end_date,
                         furgo.user_id,
                         furgo.responsibility_id,
                         furgo.responsibility_application_id,
                         furgo.start_date,
                         furgo.end_date,
                         furgo.security_group_id,
                         furgo.created_by,
                         furgo.creation_date,
                         furgo.last_updated_by,
                         furgo.last_update_date,
                         furgo.last_update_login
                    from fnd_user_resp_groups_old furgo,
                         fnd_user fu,
                         fnd_application app,
                         fnd_responsibility resp,
                         fnd_security_groups secgrp
                   where furgo.user_id = fu.user_id
                     and furgo.responsibility_id = resp.responsibility_id
                     and furgo.responsibility_application_id
                           = resp.application_id
                     and furgo.responsibility_application_id
                           = app.application_id
                     and furgo.security_group_id = secgrp.security_group_id;
  resp_name varchar2(100);
  descr varchar2(240);
  secgrp_name varchar2(80);
  dummy varchar2(255);
  wf_parameters wf_parameter_list_t;
  l_user_orig_system varchar2(30);
  l_user_orig_system_id number;
  rolename varchar2(1000);
  resp_key varchar2(100);
begin
 if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name);
 end if;

 for rowrec in get_old_row loop

  resp_key := rowrec.responsibility_key;

  rolename := role_name_from_resp_name( resp_key,
                                        rowrec.application_short_name,
                                        rowrec.security_group_key);

 if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
   fnd_log.string(FND_LOG.LEVEL_STATEMENT,
          c_log_head || l_api_name || '.processing',
          'Processing role:'|| rolename ||' for user_id:'||
          rowrec.user_id ||' user_name:'||rowrec.user_name);
 end if;
  begin
    select name
      into dummy
      from wf_local_roles partition (FND_RESP)
     where name = rolename
       and rownum = 1;
  exception   -- This shouldnt be necessary since the roles should already
    when no_data_found then    -- have been created, but be safe.
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
            c_log_head || l_api_name || '.need_to_create_role',
            'Creating role:'|| rolename);
      end if;
      fnd_user_resp_groups_api.sync_roles_one_resp_secgrp(
                   rowrec.responsibility_id,
                   rowrec.responsibility_application_id,
                   rowrec.responsibility_key,
                   rowrec.security_group_id,
                   rowrec.security_group_key,
                   rowrec.resp_start_date,
                   rowrec.resp_end_date);
  end;

  begin
    select role_name
      into dummy
      from wf_all_user_roles waur
     where waur.role_name = rolename
       and waur.user_name = rowrec.user_name
       and (   (waur.start_date = rowrec.start_date)
            OR((waur.start_date is NULL) AND (rowrec.start_date is NULL)))
       and (   (waur.expiration_date = rowrec.end_date)
            OR((waur.expiration_date is NULL) AND(rowrec.end_date is NULL)));
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
            c_log_head || l_api_name || '.ur_exists',
            'USER_ROLE FOUND. Not inserting.');
      end if;
  exception
    when no_data_found then
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
              c_log_head || l_api_name || '.ur_notfound',
             'USER_ROLE Not FOUND. Need to insert');
      end if;
      -- We cant just assume that the orig system is FND_USR.  It could
      -- be PER because the row in wf_users/wf_roles is one or the other
      wf_directory.GetRoleOrigSysInfo(rowrec.user_name,
                                      l_user_orig_system,
                                      l_user_orig_system_id);
      -- In case there is no WF user, sync this user up so there is one.
      -- Should never happen but be safe in case sync wasnt perfect in past
      if(    (l_user_orig_system is NULL)
         and (l_user_orig_system_id is NULL)) then
         if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
               c_log_head || l_api_name || '.orig_notfound',
               'Orig system and id not found.  Trying to sync user:'||
                   rowrec.user_name);
         end if;
         fnd_user_pkg.user_synch(rowrec.user_name);
         wf_directory.GetRoleOrigSysInfo(rowrec.user_name,
                                      l_user_orig_system,
                                      l_user_orig_system_id);
      end if;
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
            c_log_head || l_api_name || '.got_orig',
            'Looked up orig:  l_user_orig_system:'||
            l_user_orig_system ||' l_user_orig_system_id:'||
            l_user_orig_system_id);
      end if;
   end;

   -- Sync the User/Role (but not if there is no wf_user)
   if(    (l_user_orig_system is not NULL)
      or (l_user_orig_system_id is not NULL)) then
     begin
       wf_local_synch.PropagateUserRole
                          (p_user_name=>rowrec.user_name,
                           p_role_name=>rolename,
                           p_user_orig_system=>l_user_orig_system,
                           p_user_orig_system_id=>l_user_orig_system_id,
                           p_role_orig_system=>'FND_RESP',
                           p_role_orig_system_id=>rowrec.responsibility_id,
                           p_start_date=>rowrec.start_date,
                           p_expiration_date=>rowrec.end_date,
                           p_overwrite=>TRUE,
                           p_raiseErrors=>TRUE,
                           p_parent_orig_system => 'FND_RESP',
                           p_parent_orig_system_id =>rowrec.responsibility_id,
                           p_ownerTag => rowrec.application_short_name,
                           p_createdBy => fnd_global.user_id,
                           p_lastUpdatedBy => fnd_global.user_id,
                           p_lastUpdateLogin => 0,
                           p_creationDate => sysdate,
                           p_lastUpdatedate=> sysdate);

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
            c_log_head || l_api_name || '.called_prop',
            'Successfully called wf_local_synch.PropagateUserRole');
      end if;
    exception when others then
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
               c_log_head || l_api_name || '.propagate_fail',
           'PropogateUserRole call failed with exception for user:'||
                   rowrec.user_name || ' role:'||rolename ||
                   ' sql code:'||sqlcode ||
                   ' sql errm:'||sqlerrm);
      end if;
    end;
   else
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
               c_log_head || l_api_name || '.orig_notfound',
           'Did not propogate role because Orig System not found for user:'||
                   rowrec.user_name);
      end if;
   end if;

   commit;

 end loop;

 if (fnd_log.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end',
          c_pkg_name || '.' ||l_api_name );
 end if;
*/
end one_time_furg_to_wf_upgrade;

-- sync_roles_all_secgrps_int
--
--  Bug4322412
--   For a given resp, sync roles for all security groups if the role
--   does not already exist.
--
--   NOTE:This routine does not update existing roles. To update existing roles
--   the routine sync_roles_all_secgrps should be used.
--
procedure sync_roles_all_secgrps_int(
                   respid in number,
                   appid in number,
                   respkey in varchar2,
                   startdate in date,
                   enddate in date)
 is
    cursor get_secgrp is
                select  security_group_id,
                        security_group_key
                  from  fnd_security_groups;

 rolename varchar2(320);
 dummy number;

begin

  if (check_secgrp_enabled(respid, appid) = 'N') then
       -- Security Groups not enabled for this resp,
       -- only create a role for the STANDARD sec grp.
       sync_roles_one_resp_secgrp( respid=>    respid,
                           appid=>     appid,
                           respkey=>   respkey,
                           secgrpid=>  0,
                           secgrpkey=> 'STANDARD',
                           startdate=> startdate,
                           enddate=>   enddate);
  else
    -- Security Groups are enabled, create one role for
    -- every resp/secgrp pair.

    for secrec in get_secgrp loop

     begin
     rolename := role_name_from_resp(respid, appid,
                                   secrec.security_group_id);
      select null
        into dummy
        from wf_local_roles
        where name = rolename
        and partition_id = 2
        and rownum = 1;

      exception
       when no_data_found then
         sync_roles_one_resp_secgrp(
                   respid => respid,
                   appid => appid,
                   respkey => respkey,
                   secgrpid => secrec.security_group_id,
                   secgrpkey => secrec.security_group_key,
                   startdate => startdate,
                   enddate => enddate);
     end;
    end loop;
  end if;

end sync_roles_all_secgrps_int;


end Fnd_User_Resp_Groups_Api;

/

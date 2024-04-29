--------------------------------------------------------
--  DDL for Package Body WF_DIRECTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_DIRECTORY" as
/* $Header: wfdirb.pls 120.30.12010000.15 2014/04/02 10:33:05 sstomar ship $ */

--
-- Private variables and APIs
--
hasBulkSyncView boolean;
g_origSystem    varchar2(30);
g_partitionID   number;
g_localPartitionID number;
g_partitionName varchar2(30);
g_localPartitionName varchar2(30);
g_system_status  varchar2(30);

-- logging variable
g_plsqlName varchar2(30) := 'wf.plsql.WF_DIRECTORY.';

-- System_Status (PRIVATE)
-- Returns the current System Status
function System_Status
return varchar2
is
begin
  if wf_directory.g_system_status is null then
   wf_directory.g_system_status:= wf_core.translate('WF_SYSTEM_STATUS');
  end if;
  return wf_directory.g_system_status;
end;
--
-- MinDate (PRIVATE)
--   Return the earliest of the two dates
-- IN
--   date1
--   date2
-- OUT
-- RETURN
--   date
--
function MinDate(date1 in date,
                 date2 in date)
return date
is
begin
  if (date2 is not null) then
    --
    -- when date2 is non-null, so we need to check
    -- both if date1 is null and which is ealier.
    --
    if (date1 is null or date2 < date1) then
      return(date2);
    end if;
  end if;

  -- Note that date1 could be null
  return date1;
end MinDate;

--
-- IsBulkSync (Private)
--   Return true if bulk sync view exists
--
-- RETURN
--   boolean
--
function IsBulkSync
return boolean
is
  cnt number;
begin
  if (hasBulkSyncView is null) then

    select count(1) into cnt
      from USER_VIEWS
     where VIEW_NAME = 'WF_FND_USR_ROLES';

    if (cnt = 0) then
      hasBulkSyncView := false;
    else
      hasBulkSyncView := true;
    end if;
  end if;

  return hasBulkSyncView;
end IsBulkSync;


--
-- String_To_UserTable (PRIVATE)
--   Converts a comma/space delimited string of users into a UserTable
-- IN
--   P_UserList  VARCHAR2
-- OUT
-- RETURN
--   P_UserTable WF_DIRECTORY.UserTable
--
procedure String_To_UserTable (p_UserList  in VARCHAR2,
                               p_UserTable out NOCOPY WF_DIRECTORY.UserTable)
is

  c1          pls_integer;
  u1          pls_integer := 0;
  l_userList  varchar2(32000);

begin
  if ( (p_UserList is not NULL) and
       (length(trim(p_UserList))> 0) ) then
    --
    -- NOTE: This API provides more flexibility than dbms_utility.comma_to_table
    --       , so we would like to fix it here.
    --
    -- l_userList := trim(p_UserList);
    l_userList := trim(ltrim(rtrim(trim(p_UserList), ','), ',') );

    <<UserLoop>>
    loop
      c1 := instr(l_userList, ',');
      if (c1 = 0) then
         c1 := instr(l_userList, ' ');
        if (c1 = 0) then
          p_UserTable(u1) := l_userList;
          exit;
        else
          p_UserTable(u1) := trim(substr(l_userList, 1, c1-1));
        end if;
      else
        p_UserTable(u1) := trim(substr(l_userList, 1, c1-1));
      end if;
      u1 := u1 + 1;
      l_userList := trim(substr(l_userList, c1+1));

    end loop UserLoop;
  end if;
end String_To_UserTable;


--
-- CompositeName (PRIVATE)
--   Extracts the origSystem/origSystemID from a composite name
-- IN
--   p_CompositeName  VARCHAR2
-- OUT
--   p_CompositeName  VARCHAR2
--   p_origSystem     VARCHAR2
--   p_origSystemID   NUMBER
-- RETURN
--   boolean
--     TRUE - if name is composite
--     FALSE - if name is not composite
--
function CompositeName (p_CompositeName IN VARCHAR2,
                        p_OrigSystem OUT NOCOPY VARCHAR2,
                        p_OrigSystemID OUT NOCOPY NUMBER) return boolean is

  invalidNumConv EXCEPTION;
  pragma exception_init(invalidNumConv, -6502);
  colon NUMBER;

  begin
    colon := instr(p_CompositeName,':');
    if (colon <> 0) then
      p_origSystemID := to_number(substrb(p_CompositeName, colon+1));
      p_origSystem := substrb(p_CompositeName, 1, colon-1);
      return TRUE;
    else
      return FALSE;
    end if;
  exception
    when invalidNumConv then
      return FALSE;

    when others then
      wf_core.context('Wf_Directory','CompositeName',p_CompositeName);
      raise;
  end;

--
-- End Private API section
--

--
-- GETROLEUSERS
--   list of users who perform role
-- IN
--   role
-- OUT
--   table of users that perform the role
--
procedure GetRoleUsers(
  role in varchar2,
  users out NOCOPY Wf_Directory.UserTable)

is
  l_origSystem VARCHAR2(30);
  l_origSystemID NUMBER;
  l_partID NUMBER;
  l_partName VARCHAR2(30);

  cursor c(c_rolename varchar2) is
    select UR.USER_NAME
    from WF_USER_ROLES UR
    where UR.ROLE_NAME = c_rolename
      and UR.PARTITION_ID not in (9,8,7,6,4);

  cursor corig(c_rolename varchar2, c_origSys  varchar2,
               c_origSysID number, c_partID number) is
    select UR.USER_NAME
    from WF_USER_ROLES UR
    where UR.ROLE_ORIG_SYSTEM = c_origSys
    and UR.ROLE_ORIG_SYSTEM_ID = c_origSysID
    and UR.ROLE_NAME = c_rolename
    and UR.PARTITION_ID = c_partID;

begin
  if (compositeName(role, l_origSystem, l_origSystemID)) then
    AssignPartition(l_origSystem, l_partID, l_partName);
    open corig(role, l_origSystem, l_origSystemID, l_partID);
    fetch corig bulk collect into users;
    close corig;
  else
    open c(role);
    fetch c bulk collect into users;
    close c;
  end if;
exception
  when others then
    if c%ISOPEN then
      close c;
    elsif corig%ISOPEN then
      close corig;
    end if;
    wf_core.context('Wf_Directory','GetRoleUsers',Role);
    raise;
end GetRoleUsers;

--
-- GETUSERRELATION
--   list of users associated with a user
-- IN
--   base user
--   relationship
-- OUT
--   table of related users
-- NOTES
--   currently unimplemented!
--   different relations may be supported by different directory services,
--   so the implementation of this procedure is expected to vary.
--   Example relationships are 'MANAGER', 'REPORT', 'HR_REP'
--
procedure GetUserRelation(
  base_user in varchar2,
  relation in varchar2,
  users out NOCOPY Wf_Directory.UserTable)
is
begin
  null;
exception
  when others then
        wf_core.context('Wf_Directory','GetUserRelation',base_user,relation);
        raise;
end GetUserRelation;

--
-- GETUSERROLES
--   list of roles performed by user
-- IN
--   user
-- OUT
--   table of roles performed by the user
--
procedure GetUserRoles(
  user in varchar2,
  roles out NOCOPY Wf_Directory.RoleTable)
is
  l_origSystem VARCHAR2(30);
  l_origSystemID NUMBER;

  cursor c(c_username varchar2) is
    select UR.ROLE_NAME
    from   WF_USER_ROLES UR
    where UR.USER_NAME = c_username
      and UR.USER_ORIG_SYSTEM not in ('HZ_PARTY','CUST_CONT');

  cursor corig(c_username varchar2,
               c_origSystem varchar2,
               c_origSystemID number) is
    select UR.ROLE_NAME
    from WF_USER_ROLES UR
    where UR.USER_ORIG_SYSTEM = c_origSystem
    and UR.USER_ORIG_SYSTEM_ID = c_origSystemID
    and UR.USER_NAME = c_username;

begin
  if (CompositeName(user, l_origSystem, l_origSystemID)) then
    open corig(user, l_origSystem, l_origSystemID);
    fetch corig bulk collect into roles;
    close corig;
  else
    open c(user);
    fetch c bulk collect into roles;
    close c;
  end if;
exception
  when others then
    if (c%ISOPEN) then
      close c;
    elsif (corig%ISOPEN) then
      close corig;
    end if;

    wf_core.context('Wf_Directory','GetUserRoles',User);
    raise;
end GetUserRoles;

--
-- GETROLEINFO
--   information about a role
-- IN
--  role
-- OUT
--   display_name
--   email_address
--   notification_preference
--   language
--   territory
--
procedure GetRoleInfo(
  role in varchar2,
  display_name out NOCOPY varchar2,
  email_address out NOCOPY varchar2,
  notification_preference out NOCOPY varchar2,
  language out NOCOPY varchar2,
  territory out NOCOPY varchar2)
is
  role_info_tbl wf_directory.wf_local_roles_tbl_type;
begin
  Wf_Directory.GetRoleInfo2(role, role_info_tbl);

  display_name            := role_info_tbl(1).display_name;
  email_address           := role_info_tbl(1).email_address;
  notification_preference := role_info_tbl(1).notification_preference;
  language                := role_info_tbl(1).language;
  territory               := role_info_tbl(1).territory;

exception
  when others then
    wf_core.context('Wf_Directory','GetRoleInfo',Role);
    raise;
end GetRoleInfo;

--
-- GETROLEINFO2
--   information about a role
-- IN
--  role
-- OUT
--   role_info_tbl
--
procedure GetRoleInfo2(
  role in varchar2,
  role_info_tbl out NOCOPY wf_directory.wf_local_roles_tbl_type)
is
  l_origSystem VARCHAR2(30);
  l_origSystemID NUMBER;
  l_isComposite BOOLEAN;
  l_api varchar2(250) := g_plsqlName ||'GetRoleInfo2';
  l_logPROC boolean := false;

begin
  l_logPROC := WF_LOG_PKG.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level;
  if( l_logPROC ) then
    wf_log_pkg.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'BEGIN');
  end if;

  --Check for composite name.
  l_isComposite := CompositeName(role, l_origSystem, l_origSystemID);

  /*
   ** First try to get the role information from the new
   ** wfa_sec.get_role_info function.  This function looks at each component
   ** of the wf_roles view and attempts to get the information from there.
   ** If it does not find the role then use the old method of looking at the
   ** view.
   */

   --Get all info including expiration_date , fax and
   --status for the role.  Call get_role_info2
   wfa_sec.get_role_info3(l_isComposite,
                          role,
                          role_info_tbl(1).name,
                          role_info_tbl(1).display_name,
                          role_info_tbl(1).description,
                          role_info_tbl(1).email_address,
                          role_info_tbl(1).notification_preference,
                          role_info_tbl(1).orig_system,
                          role_info_tbl(1).orig_system_id,
                          role_info_tbl(1).fax,
                          role_info_tbl(1).status,
                          role_info_tbl(1).expiration_date,
                          role_info_tbl(1).language,
                          role_info_tbl(1).territory,
                          role_info_tbl(1).nls_date_format, -- <7578908> new NLS parameters
                          role_info_tbl(1).nls_date_language,
                          role_info_tbl(1).nls_calendar,
                          role_info_tbl(1).nls_numeric_characters,
                          role_info_tbl(1).nls_sort,
                          role_info_tbl(1).nls_currency  -- </7578908>
                          );

  if (role_info_tbl.COUNT = 0 or role_info_tbl(1).display_name is NULL) then
    if( l_logPROC ) then
      wf_log_pkg.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,
        'no records found by wfa_sec.get_role_info3(), querying *active* roles in other partitions then.');
    end if;

    if NOT (l_isComposite) then
      if( l_logPROC ) then
        wf_log_pkg.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'case of no composite name');
      end if;

      -- try to select from all the ORIG_SYSTEMs that have no colon.
      -- we query FNDRESPXXX also since we cannot list all of them here.
      -- it is safer to use 'not in', in case of custom additions.
      select R.NAME,
             substrb(R.DISPLAY_NAME,1,360),
             substrb(R.DESCRIPTION,1,1000),
             R.NOTIFICATION_PREFERENCE,
             R.LANGUAGE,
             R.TERRITORY,
           wf_core.nls_date_format, -- <7578908> new NLS parameters
           R.LANGUAGE,  -- default nls_date_language
           wf_core.nls_calendar ,
           wf_core.nls_numeric_characters,
           wf_core.nls_sort,
           wf_core.nls_currency,  -- </7578908>
             substrb(R.EMAIL_ADDRESS,1,320),
             R.FAX,
             R.STATUS,
             R.EXPIRATION_DATE,
             R.ORIG_SYSTEM,
             R.ORIG_SYSTEM_ID,
             R.PARENT_ORIG_SYSTEM,
             R.PARENT_ORIG_SYSTEM_ID,
             R.OWNER_TAG,
             R.LAST_UPDATE_DATE,
             R.LAST_UPDATED_BY,
             R.CREATION_DATE,
             R.CREATED_BY,
             R.LAST_UPDATE_LOGIN
      into   role_info_tbl(1)
      from   WF_ROLES R
      where  R.NAME = GetRoleInfo2.role
      and    R.PARTITION_ID not in (9,8,7,6,4)
      and    nvl(R.EXPIRATION_DATE, sysdate+1) > sysdate
      and    rownum = 1;

    else
      if( l_logPROC ) then
        wf_log_pkg.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'case of composite name, querying with orig_system');
      end if;

      select R.NAME,
             substrb(R.DISPLAY_NAME,1,360),
             substrb(R.DESCRIPTION,1,1000),
             R.NOTIFICATION_PREFERENCE,
             R.LANGUAGE,
             R.TERRITORY,
           wf_core.nls_date_format, -- <7578908> new NLS parameters
           R.LANGUAGE,  -- default nls_date_language
           wf_core.nls_calendar ,
           wf_core.nls_numeric_characters,
           wf_core.nls_sort,
           wf_core.nls_currency,  -- </7578908>
             substrb(R.EMAIL_ADDRESS,1,320),
             R.FAX,
             R.STATUS,
             R.EXPIRATION_DATE,
             R.ORIG_SYSTEM,
             R.ORIG_SYSTEM_ID,
             R.PARENT_ORIG_SYSTEM,
             R.PARENT_ORIG_SYSTEM_ID,
             R.OWNER_TAG,
             R.LAST_UPDATE_DATE,
             R.LAST_UPDATED_BY,
             R.CREATION_DATE,
             R.CREATED_BY,
             R.LAST_UPDATE_LOGIN
      into   role_info_tbl(1)
      from   WF_ROLES R
      where  R.ORIG_SYSTEM = l_origSystem
      and    R.ORIG_SYSTEM_ID = l_origSystemID
      and    R.NAME = GetRoleInfo2.role
      and    nvl(R.EXPIRATION_DATE, sysdate+1) > sysdate
      and    rownum = 1;
    end if;

  else
    role_info_tbl(1).name := role;
  end if;

  if( l_logPROC ) then
    wf_log_pkg.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'END');
  end if;
exception
  when no_data_found then
    if( WF_LOG_PKG.LEVEL_EXCEPTION >=  fnd_log.g_current_runtime_level) then
      wf_log_pkg.String(WF_LOG_PKG.LEVEL_EXCEPTION, l_api,'role not found, querying ALL roles');
    end if;
  --If the role is not found in the local tables, we will check the view to make
  --sure we continue to support standalone which has not denormalized wfds.
  begin
    if NOT (l_isComposite) then
      if( l_logPROC ) then
        wf_log_pkg.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'case of not composite role name');
      end if;
      select R.NAME,
             substrb(R.DISPLAY_NAME,1,360),
             substrb(R.DESCRIPTION,1,1000),
             R.NOTIFICATION_PREFERENCE,
             R.LANGUAGE,
             R.TERRITORY,
           wf_core.nls_date_format, -- <7578908> new NLS parameters
           R.LANGUAGE,  -- default nls_date_language
           wf_core.nls_calendar ,
           wf_core.nls_numeric_characters,
           wf_core.nls_sort,
           wf_core.nls_currency,  -- </7578908>
             substrb(R.EMAIL_ADDRESS,1,320),
             R.FAX,
             R.STATUS,
             R.EXPIRATION_DATE,
             R.ORIG_SYSTEM,
             R.ORIG_SYSTEM_ID,
             NULL,
             to_number(NULL),
             NULL,
             to_date(NULL),
             to_number(NULL),
             to_date(NULL),
             to_number(NULL),
             to_number(NULL)
      into   role_info_tbl(1)
      from   WF_ROLES R
      where  R.NAME = GetRoleInfo2.role
      and    R.PARTITION_ID not in (9,8,7,6,4)
      and    rownum = 1;
      else
        if( l_logPROC ) then
          wf_log_pkg.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'case of composite role name');
        end if;

        select R.NAME,
               substrb(R.DISPLAY_NAME,1,360),
               substrb(R.DESCRIPTION,1,1000),
               R.NOTIFICATION_PREFERENCE,
               R.LANGUAGE,
               R.TERRITORY,
           wf_core.nls_date_format, -- <7578908> new NLS parameters
           R.LANGUAGE,  -- default nls_date_language
           wf_core.nls_calendar ,
           wf_core.nls_numeric_characters,
           wf_core.nls_sort,
           wf_core.nls_currency,  -- </7578908>
               substrb(R.EMAIL_ADDRESS,1,320),
               R.FAX,
               R.STATUS,
               R.EXPIRATION_DATE,
               R.ORIG_SYSTEM,
               R.ORIG_SYSTEM_ID,
               NULL,
               to_number(NULL),
               NULL,
               to_date(NULL),
               to_number(NULL),
               to_date(NULL),
               to_number(NULL),
               to_number(NULL)
       into   role_info_tbl(1)
       from   WF_ROLES R
       where  R.ORIG_SYSTEM = l_origSystem
       and    R.ORIG_SYSTEM_ID = l_origSystemID
       and    R.NAME = GetRoleInfo2.role
       and    rownum = 1;
      end if;

      if( l_logPROC ) then
        wf_log_pkg.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'END');
      end if;
    exception
      when NO_DATA_FOUND then
        if( WF_LOG_PKG.LEVEL_EXCEPTION >=  fnd_log.g_current_runtime_level) then
          wf_log_pkg.String(WF_LOG_PKG.LEVEL_EXCEPTION, l_api,'role not found again, setting role_info_tbl fields to NULL');
        end if;
        role_info_tbl(1).name := '';
        role_info_tbl(1).display_name := '';
        role_info_tbl(1).description := '';
        role_info_tbl(1).notification_preference := '';
        role_info_tbl(1).language := '';
        role_info_tbl(1).territory := '';
        role_info_tbl(1).email_address := '';
        role_info_tbl(1).fax := '';
        role_info_tbl(1).status := '';
        role_info_tbl(1).expiration_date := to_date(null);
        role_info_tbl(1).orig_system := '';
        role_info_tbl(1).orig_system_id := to_number(null);
        role_info_tbl(1).parent_orig_system := '';
        role_info_tbl(1).parent_orig_system_id := to_number(null);
        role_info_tbl(1).owner_tag := null;
        role_info_tbl(1).last_update_date := to_date(null);
        role_info_tbl(1).last_updated_by := to_number(null);
        role_info_tbl(1).creation_date := to_date(null);
        role_info_tbl(1).last_update_login := to_number(null);
        role_info_tbl(1).NLS_DATE_FORMAT :='';
        role_info_tbl(1).NLS_DATE_LANGUAGE    :='';
        role_info_tbl(1).NLS_CALENDAR   :='';
        role_info_tbl(1).NLS_NUMERIC_CHARACTERS :='';
        role_info_tbl(1).NLS_SORT   :='';
        role_info_tbl(1).NLS_CURRENCY :='';

        if( l_logPROC ) then
          wf_log_pkg.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'END');
        end if;
    end;

  when others then
    wf_core.context('Wf_Directory','GetRoleInfo2',Role);
    raise;
end GetRoleInfo2;

--
-- GETROLEINFOMAIL
--   All information about a role for mailer
-- IN
--  role
-- OUT
--   display_name
--   email_address
--   notification_preference
--   language
--   territory
--   orig_system
--   orig_system_id
--   installed_flag - Y when a language is installed in WF_LANGUAGES,
--                    N otherwise.
--
procedure GetRoleInfoMail(
  role in varchar2,
  display_name out NOCOPY varchar2,
  email_address out NOCOPY varchar2,
  notification_preference out NOCOPY varchar2,
  language out NOCOPY varchar2,
  territory out NOCOPY varchar2,
  orig_system out NOCOPY varchar2,
  orig_system_id out NOCOPY number,
  installed_flag out NOCOPY varchar2)
is
  role_info_tbl wf_directory.wf_local_roles_tbl_type;
begin

  Wf_Directory.GetRoleInfo2(role, role_info_tbl);

  display_name            := role_info_tbl(1).display_name;
  email_address           := role_info_tbl(1).email_address;
  notification_preference := role_info_tbl(1).notification_preference;
  language                := role_info_tbl(1).language;
  territory               := role_info_tbl(1).territory;
  orig_system             := role_info_tbl(1).orig_system;
  orig_system_id          := role_info_tbl(1).orig_system_id;

  begin
    select nvl(INSTALLED_FLAG, 'N')
      into GetRoleInfoMail.installed_flag
      from WF_LANGUAGES
     where NLS_LANGUAGE = GetRoleInfoMail.language;
  exception
    when NO_DATA_FOUND then
      installed_flag := 'N';
  end;

exception
  when others then
    wf_core.context('Wf_Directory','GetRoleInfoMail',Role);
    raise;
end GetRoleInfoMail;

  procedure GetRoleInfoMail2( p_role in varchar2,
                              p_display_name out NOCOPY varchar2,
                              p_email_address out NOCOPY varchar2,
                              p_notification_preference out NOCOPY varchar2,
                              p_orig_system out NOCOPY varchar2,
                              p_orig_system_id out NOCOPY number,
                              p_installed_flag out NOCOPY varchar2
                            , p_nlsLanguage out NOCOPY varchar2,
                              p_nlsTerritory out NOCOPY varchar2
                            , p_nlsDateFormat out NOCOPY varchar2
                            , p_nlsDateLanguage out NOCOPY varchar2
                            , p_nlsCalendar out NOCOPY varchar2
                            , p_nlsNumericCharacters out NOCOPY varchar2
                            , p_nlsSort out NOCOPY varchar2
                            , p_nlsCurrency out NOCOPY varchar2)
  is
    l_role_info_tbl wf_directory.wf_local_roles_tbl_type;
    l_api varchar2(250) := g_plsqlName ||'GetRoleInfoMail2';

  begin
    if( WF_LOG_PKG.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level ) then
        wf_log_pkg.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'BEGIN');
    end if;

    Wf_Directory.GetRoleInfo2(p_role, l_role_info_tbl);

    p_display_name            := l_role_info_tbl(1).display_name;
    p_email_address           := l_role_info_tbl(1).email_address;
    p_notification_preference := l_role_info_tbl(1).notification_preference;
    p_orig_system             := l_role_info_tbl(1).orig_system;
    p_orig_system_id          := l_role_info_tbl(1).orig_system_id;

    p_nlsLanguage          := l_role_info_tbl(1).language;
    p_nlsTerritory         := l_role_info_tbl(1).territory;
    p_nlsDateFormat        := l_role_info_tbl(1).NLS_DATE_FORMAT;
    p_nlsDateLanguage      := l_role_info_tbl(1).NLS_DATE_LANGUAGE;
    p_nlsCalendar          := l_role_info_tbl(1).NLS_CALENDAR;
    p_nlsNumericCharacters := l_role_info_tbl(1).NLS_NUMERIC_CHARACTERS;
    p_nlsSort              := l_role_info_tbl(1).NLS_SORT;
    p_nlsCurrency          := l_role_info_tbl(1).NLS_CURRENCY;

    begin
      select nvl(INSTALLED_FLAG, 'N')
        into GetRoleInfoMail2.p_installed_flag
        from WF_LANGUAGES
       where NLS_LANGUAGE = GetRoleInfoMail2.p_nlsLanguage;
    exception
      when NO_DATA_FOUND then
        p_installed_flag := 'N';
    end;

    if( WF_LOG_PKG.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level ) then
      wf_log_pkg.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'END');
    end if;
  exception
    when others then
      wf_core.context('Wf_Directory','GetRoleInfoMail2', p_role);
      raise;
  end GetRoleInfoMail2;

--
-- GETROLENTFPREF
--   Obtains the notification preference for a given role
-- IN
--  role
-- OUT
--  notification_preference
--
function GetRoleNtfPref(
  role in varchar2) return varchar2
is
  role_info_tbl wf_directory.wf_local_roles_tbl_type;
  notification_preference varchar2(8);
begin

  Wf_Directory.GetRoleInfo2(role, role_info_tbl);
  notification_preference := role_info_tbl(1).notification_preference;

  return notification_preference;
exception
  when others then
    wf_core.context('Wf_Directory','GetRoleNotePref',Role);
    raise;
end GetRoleNtfPref;

--
-- GETROLEORIGSYSINFO
--   orig system information about a role
-- IN
--  role
-- OUT
--   orig_system
--   orig_system_id
--
procedure GetRoleOrigSysInfo(
  role in varchar2,
  orig_system out NOCOPY varchar2,
  orig_system_id out NOCOPY number
)
is
  role_info_tbl wf_directory.wf_local_roles_tbl_type;
begin
  Wf_Directory.GetRoleInfo2(role, role_info_tbl);

  orig_system    := role_info_tbl(1).orig_system;
  orig_system_id := role_info_tbl(1).orig_system_id;

exception
  when others then
    wf_core.context('Wf_Directory','GetRoleOrigSysInfo',Role);
    raise;
end GetRoleOrigSysInfo;

--
-- GETROLEPARTITIONINFO
--   partition information about a role
-- IN
--  role
-- OUT
--  partition_id
--  orig_system
--  display_name
--
procedure GetRolePartitionInfo(
  role in varchar2,
  partition_id out nocopy number,
  orig_system out nocopy varchar2,
  display_name out nocopy varchar2
)
is
  l_orig_system varchar2(30);
  l_orig_system_id number;
  l_is_composite boolean;
begin
  l_is_composite := CompositeName(role, l_orig_system, l_orig_system_id);

  if not l_is_composite then
    select partition_id, orig_system
    into GetRolePartitionInfo.partition_id, GetRolePartitionInfo.orig_system
    from wf_local_roles
    where name = GetRolePartitionInfo.role
    and nvl(expiration_date, sysdate+1) > sysdate
    and rownum = 1;
  else
    select partition_id, orig_system
    into GetRolePartitionInfo.partition_id, GetRolePartitionInfo.orig_system
    from wf_local_roles
    where name = GetRolePartitionInfo.role
    and orig_system =l_orig_system
    and orig_system_id = l_orig_system_id
    and nvl(expiration_date, sysdate+1) > sysdate
    and rownum = 1;
  end if;

  select orig_system, display_name
  into GetRolePartitionInfo.orig_system,
  GetRolePartitionInfo.display_name
  from wf_directory_partitions_vl
  where GetRolePartitionInfo.partition_id <> 1
  and partition_id = GetRolePartitionInfo.partition_id
  or GetRolePartitionInfo.partition_id = 1
  and orig_system = GetRolePartitionInfo.orig_system;

exception
  when no_data_found then
    begin
      if not l_is_composite then
        select partition_id, orig_system
        into GetRolePartitionInfo.partition_id, GetRolePartitionInfo.orig_system
        from wf_roles
        where name = GetRolePartitionInfo.role
        and rownum = 1;
      else
        select partition_id, orig_system
        into GetRolePartitionInfo.partition_id, GetRolePartitionInfo.orig_system
        from wf_roles
        where name = GetRolePartitionInfo.role
        and orig_system =l_orig_system
        and orig_system_id = l_orig_system_id
        and rownum = 1;
      end if;

      select orig_system, display_name
      into GetRolePartitionInfo.orig_system,
      GetRolePartitionInfo.display_name
      from wf_directory_partitions_vl
      where GetRolePartitionInfo.partition_id <> 1
     and partition_id = GetRolePartitionInfo.partition_id
     or GetRolePartitionInfo.partition_id = 1
     and orig_system = GetRolePartitionInfo.orig_system;

    exception
      when no_data_found then
        partition_id := -1;
        orig_system := null;
        display_name := null;
      when others then
        wf_core.context('Wf_Directory','GetRolePartitionInfo',role);
        raise;
    end;
  when others then
    wf_core.context('Wf_Directory','GetRolePartitionInfo',role);
    raise;
end GetRolePartitionInfo;

--
-- ISPERFORMER
--   test if user performs role
--
function IsPerformer(
    user in varchar2,
    role in varchar2) return boolean
is
  userComposite boolean;
  roleComposite boolean;
  l_uorigSys varchar2(30);
  l_uorigSysID number;
  l_rorigSys varchar(30);
  l_rorigSysID number;
  l_partID number;
  l_partName varchar2(30);
  dummy pls_integer;

begin
  userComposite := CompositeName(user, l_uorigSys, l_uorigSysID);
  roleComposite := CompositeName(role, l_rorigSys, l_rorigSysID);

  if NOT (roleComposite) then
    if NOT (userComposite) then
      select 1
      into dummy
      from SYS.DUAL
      where exists
        (select null
        from WF_USER_ROLES UR
        where UR.USER_NAME = IsPerformer.user
        and UR.USER_ORIG_SYSTEM not in ('HZ_PARTY')
        and UR.ROLE_NAME = IsPerformer.role
        and UR.PARTITION_ID not in (9,8,7,6,4)
        );
    else
      select 1
      into dummy
      from SYS.DUAL
      where exists
        (select null
        from WF_USER_ROLES UR
        where UR.USER_ORIG_SYSTEM = l_uOrigSys
        and UR.USER_ORIG_SYSTEM_ID = l_uOrigSysID
        and UR.USER_NAME = IsPerformer.user
        and UR.ROLE_NAME = IsPerformer.role
        and UR.PARTITION_ID not in (9,8,7,6,4)
        );
    end if;
  else
    AssignPartition (l_rorigSys,l_partID,l_partName);
    if NOT (userComposite) then
      select 1
      into dummy
      from SYS.DUAL
      where exists
        (select null
        from WF_USER_ROLES UR
        where UR.USER_NAME = IsPerformer.user
        and UR.USER_ORIG_SYSTEM not in ('HZ_PARTY')
        and UR.ROLE_NAME = IsPerformer.role
        and UR.ROLE_ORIG_SYSTEM = l_rorigSys
        and UR.ROLE_ORIG_SYSTEM_ID = l_rorigSysID
        and UR.PARTITION_ID = l_partID);
    else
      select 1
      into dummy
      from SYS.DUAL
      where exists
        (select null
        from WF_USER_ROLES UR
        where UR.USER_ORIG_SYSTEM = l_uOrigSys
        and UR.USER_ORIG_SYSTEM_ID = l_rOrigSysID
        and UR.USER_NAME = IsPerformer.user
        and UR.ROLE_ORIG_SYSTEM = l_rOrigSys
        and UR.ROLE_ORIG_SYSTEM_ID = l_rOrigSysID
        and UR.ROLE_NAME = IsPerformer.role
        and UR.PARTITION_ID = l_partID);
    end if;
  end if;
  return TRUE;
exception
  when no_data_found then
    return FALSE;
  when others then
    wf_core.context('Wf_Directory','IsPerformer',User,Role);
    raise;
end IsPerformer;

--
-- CURRENTUSER
--   user name for current db session
-- NOTES
--   unimplemented!  This needs more thought.
--
function CurrentUser return varchar2
is
begin
  return NULL;
exception
  when others then
    wf_core.context('Wf_Directory','CurrentUser');
    raise;
end CurrentUser;

--
-- USERACTIVE
--   determine if a user is currently active
-- IN
--   username
-- RETURN:
--   True  - If user is Active
--   False - If User is NOT Active
--
function UserActive(
  username in varchar2)
return boolean
is
  colon pls_integer;
  dummy pls_integer;
begin
  colon := instr(username, ':');
  if (colon = 0) then
    select 1
    into dummy
    from SYS.DUAL
    where exists
      (select null
      from wf_users
      where name = username
      and PARTITION_ID <> 9
      and status = 'ACTIVE');
  else
    select 1
    into dummy
    from SYS.DUAL
    where exists
      (select null
      from wf_users
      where orig_system = substr(username, 1, colon-1)
      and orig_system_id = substr(username, colon+1)
      and name = username
      and status = 'ACTIVE');
  end if;

  return TRUE;
exception
  when no_data_found then
    return FALSE;
  when others then
    wf_core.context('Wf_Directory','UserActive',Username);
    raise;
end UserActive;

--
-- RoleActive
--   determine if a user is currently active
-- IN
--   rolename
-- RETURN:
--   True  - If user is Active
--   False - If User is NOT Active
--
function RoleActive(
  p_rolename in varchar2)
return boolean
is
  colon pls_integer;
  dummy pls_integer;
begin
  if WF_DIRECTORY.UserActive(p_rolename) then
    return TRUE;
  end if;
  colon := instr(p_rolename, ':');
  if (colon = 0) then
    select 1
    into dummy
    from SYS.DUAL
    where exists
      (select null
      from WF_ROLES
      where name = p_rolename
      and status = 'ACTIVE');
  else
    select 1
    into dummy
    from SYS.DUAL
    where exists
      (select null
      from WF_ROLES
      where orig_system = substr(p_rolename, 1, colon-1)
      and orig_system_id = substr(p_rolename, colon+1)
      and name = p_rolename
      and status = 'ACTIVE');
  end if;
  return TRUE;
exception
  when no_data_found then
    return FALSE;
  when others then
    wf_core.context('Wf_Directory','RoleActive',p_rolename);
    raise;
end RoleActive;

--
-- GETUSERNAME
--   returns the Workflow username given the originating system info
-- IN
--   orig_system     - Code identifying the original table
--   orig_system_id  - Id of the row in original table
-- OUT
--   user_name       - Workflow user_name
--   display_name    - Users display name
--
procedure GetUserName(p_orig_system    in  varchar2,
                      p_orig_system_id in  varchar2,
                      p_name           out NOCOPY varchar2,
                      p_display_name   out NOCOPY varchar2)
is
  cursor c_user is
    select name,
           substrb(display_name,1,360)
           p_display_name
    from   wf_users
    where  orig_system     = p_orig_system
    and    orig_system_id  = p_orig_system_id
    order by status, start_date;

begin
    open  c_user;
    fetch c_user into p_name, p_display_name;
    close c_user;
exception
  when others then
    wf_core.context('Wf_Directory','GetUserName', p_orig_system,
                    p_orig_system_id);
    raise;
end GetuserName;

--
-- GETROLENAME
--   returns the Workflow rolename given the originating system info
-- IN
--   orig_system     - Code identifying the original table
--   orig_system_id  - Id of the row in original table
-- OUT
--   name            - Workflow role name
--   display_name    - role display name
--
procedure GetRoleName(p_orig_system    in  varchar2,
                      p_orig_system_id in  varchar2,
                      p_name           out NOCOPY varchar2,
                      p_display_name   out NOCOPY varchar2)
is
  cursor c_role is
    select name,
           substrb(display_name,1,360)
           p_display_name
    from   wf_roles
    where  orig_system     = p_orig_system
    and    orig_system_id  = p_orig_system_id
    order by status, start_date;
begin
    open  c_role;
    fetch c_role into p_name,p_display_name;
    close c_role;
exception
  when others then
    wf_core.context('Wf_Directory','GetRoleName',p_orig_system,p_orig_system);
    raise;
end GetRoleName;

--
-- GetRoleDisplayName
--   Return display name of role
-- IN
--   p_role_name - internal name of role
-- RETURNS
--   role display name
--
-- NOTE
--   Cannot implement using GetRoleInfo/GetRoleInfo2, because of the
-- pragma WNPS.
--
function GetRoleDisplayName (
  p_role_name in varchar2)
return varchar2
is
  colon pls_integer;

  cursor c_role (l_name in varchar2) is
    select substrb(display_name,1,360)
    from wf_roles
    where name = l_name
    and   PARTITION_ID not in (9,8,7,6,4);

  cursor corig_role (l_name in varchar2, l_origSys in varchar2,
                     l_origSysID in number) is
    select substrb(display_name,1,360)
    from wf_roles
    where orig_system = l_origSys
    and orig_system_id = l_origSysID
    and name = l_name;

  l_display_name wf_roles.display_name%TYPE;
  invalidNumConv EXCEPTION;
  pragma exception_init(invalidNumConv, -6502);
begin
  begin
    colon := instr(p_role_name, ':');
    if (colon = 0) then
      open c_role(p_role_name);
      fetch c_role into l_display_name;
      close c_role;
    else
      open corig_role(p_role_name, substr(p_role_name, 1, colon-1),
                      to_number(substr(p_role_name, colon+1)));
      fetch corig_role into l_display_name;
      close corig_role;
    end if;
  exception
    when invalidNumConv then
      --p_role_name is not a true composite so we failed to open corig_role
      --we will fall back to c_role.
      open c_role(p_role_name);
      fetch c_role into l_display_name;
      close c_role;
  end;
  return l_display_name;
end GetRoleDisplayName;

--
-- GetRoleDisplayName2
--   Return display name of active/inactive role
-- IN
--   p_role_name - internal name of role
-- RETURNS
--   role display name
--
-- NOTE
--   Cannot implement using GetRoleInfo/GetRoleInfo2, because of the
-- pragma WNPS.
--
function GetRoleDisplayName2 (
  p_role_name in varchar2)
return varchar2
is
  colon pls_integer;

  cursor c_role (l_name in varchar2) is
    select substrb(nvl(wrt.display_name,wr.display_name),1,360)
    from wf_local_roles wr, wf_local_roles_tl wrt
    where wr.name = l_name
    and   wr.orig_system = wrt.orig_system (+)
    and   wr.orig_system_id = wrt.orig_system_id (+)
    and   wr.name = wrt.name (+)
    and   wr.partition_id  = wrt.partition_id (+)
    and   wrt.language (+) = userenv('LANG')
    and   wr.partition_id not in (9,8,7,6,4,3);

  cursor corig_role (l_name in varchar2, l_origSys in varchar2,
                     l_origSysID in number) is
    select substrb(nvl(wrt.display_name,wr.display_name),1,360)
    from wf_local_roles wr, wf_local_roles_tl wrt
    where wr.orig_system = l_origSys
    and   wr.orig_system_id = l_origSysID
    and   wr.name = l_name
    and   wr.orig_system = wrt.orig_system (+)
    and   wr.orig_system_id = wrt.orig_system_id (+)
    and   wr.name = wrt.name (+)
    and   wr.partition_id  = wrt.partition_id (+)
    and   wrt.language (+) = userenv('LANG')
    AND   wr.partition_id <> 3;

  l_display_name varchar2(360);
  invalidNumConv EXCEPTION;
  pragma exception_init(invalidNumConv, -6502);
begin
  begin
    colon := instr(p_role_name, ':');
    if (colon = 0) then
      open c_role(p_role_name);
      fetch c_role into l_display_name;
      close c_role;
    else
      open corig_role(p_role_name, substr(p_role_name, 1, colon-1),
                      to_number(substr(p_role_name, colon+1)));
      fetch corig_role into l_display_name;
      close corig_role;
    end if;
  exception
    when invalidNumConv then
      --p_role_name is not a true composite so we failed to open corig_role
      --we will fall back to c_role.
      open c_role(p_role_name);
      fetch c_role into l_display_name;
      close c_role;
  end;
  return l_display_name;
end GetRoleDisplayName2;

--
-- SetAdHocUserStatus
--   Update status for user
-- IN
--   user_name        -
--   status           - status could be 'ACTIVE' or 'INACTIVE'
-- OUT
--
procedure SetAdHocUserStatus(user_name      in varchar2,
                             status         in varchar2)
is
begin
  --
  -- Update Status
  --
  SetUserAttr(user_name=>SetAdHocUserStatus.user_name,
              orig_system=>'WF_LOCAL_USERS',
              orig_system_id=>0,
              display_name=>NULL,
              notification_preference=>NULL,
              language=>NULL,
              territory=>NULL,
              email_address=>NULL,
              fax=>NULL,
              expiration_date=>NULL,
              status=>SetAdHocUserStatus.status);

exception
  when others then
    wf_core.context('Wf_Directory', 'SetAdHocUserStatus', user_name, status);
    raise;
end SetAdHocUserStatus;

--
-- SetAdHocRoleStatus
--   Update status for role
-- IN
--   role_name        -
--   status           - status could be 'ACTIVE' or 'INACTIVE'
-- OUT
--
procedure SetAdHocRoleStatus(role_name      in varchar2,
                        status         in varchar2)
is
begin
  --
  -- Update Status
  --
  SetRoleAttr(role_name=>SetAdHocRoleStatus.role_name,
              orig_system=>'WF_LOCAL_ROLES',
              orig_system_id=>0,
              display_name=>NULL,
              notification_preference=>NULL,
              language=>NULL,
              territory=>NULL,
              email_address=>NULL,
              fax=>NULL,
              expiration_date=>NULL,
              status=>SetAdHocRoleStatus.status);

exception
  when others then
    wf_core.context('Wf_Directory', 'SetAdHocRoleStatus', role_name, status);
    raise;
end SetAdHocRoleStatus;

--
-- Translate_Role
--
-- IN
-- p_role_name
-- p_role_orig_system
-- p_role_orig_system_id
-- p_partition_id
-- p_display_name
-- p_description
-- p_source_lang: identify what language is being translated.
-- p_overwrite: to tell whether to update the who columns
-- who column values
--
-- COMMENTS
-- This procedure is used to translate the roles to a langauage
-- specified by parameter p_source_lang. The 'US' record is held in
-- base table WF_LOCAL_ROLES while translation for all installed
-- languages are held in WF_LOCAL_ROLES_TL

procedure translate_role (p_name in varchar2,
                          p_orig_system in varchar2,
                          p_orig_system_id in number,
                          p_partition_id number,
                          p_display_name in varchar2,
                          p_description in varchar2,
                          p_source_lang in varchar2,
                          p_overwrite in varchar2,
                          p_owner_tag in varchar2,
                          p_last_updated_by in number,
                          p_last_update_date in date,
                          p_last_update_login in number) is
  l_source_lang WF_LOCAL_ROLES.LANGUAGE%TYPE := nvl(p_source_lang, userenv('LANG'));
  l_created_by number := WFA_SEC.USER_ID;
  l_creation_date date := SYSDATE;
begin
  update WF_LOCAL_ROLES_TL
  set    DISPLAY_NAME      = nvl(p_display_name, DISPLAY_NAME),
         DESCRIPTION       = nvl(p_description, DESCRIPTION),
         --SOURCE_LANG       = p_source_lang,
         LAST_UPDATED_BY   = decode(p_overwrite, 'Y', p_last_updated_by, 'N', LAST_UPDATED_BY),
         LAST_UPDATE_DATE  = decode(p_overwrite, 'Y', p_last_update_date, 'N', LAST_UPDATE_DATE),
         LAST_UPDATE_LOGIN = decode(p_overwrite, 'Y', p_last_update_login, 'N', LAST_UPDATE_LOGIN)
  where  NAME           = p_name and
         ORIG_SYSTEM    = p_orig_system and
         ORIG_SYSTEM_ID = p_orig_system_id and
         PARTITION_ID   = p_partition_id and
         --and l_source_lang in (LANGUAGE, SOURCE_LANG);
         LANGUAGE = l_source_lang;

  if (sql%rowcount = 0) then
    insert into  WF_LOCAL_ROLES_TL (NAME,
                                    DISPLAY_NAME,
                                    DESCRIPTION,
                                    ORIG_SYSTEM,
                                    ORIG_SYSTEM_ID,
                                    PARTITION_ID,
                                    LANGUAGE,
                                    --SOURCE_LANG,
                                    OWNER_TAG,
                                    CREATED_BY,
                                    CREATION_DATE,
                                    LAST_UPDATED_BY,
                                    LAST_UPDATE_DATE,
                                    LAST_UPDATE_LOGIN)
    (select p_name,
            p_display_name,
            p_description,
            p_orig_system,
            p_orig_system_id,
            p_partition_id,
            L.LANGUAGE_CODE,
            --userenv('LANG'),
            p_owner_tag,
            l_created_by,
            l_creation_date,
            p_last_updated_by,
            p_last_update_date,
            p_last_update_login
     from FND_LANGUAGES L
     where INSTALLED_FLAG in ('I','B')
       and L.LANGUAGE_CODE <> 'US' --So that we do not maintain the 'US'
                                   --row in the TL table.
       and not exists (select null
                       from WF_LOCAL_ROLES_TL TL, WF_LOCAL_ROLES B
                       where B.NAME            = p_name
                         and B.ORIG_SYSTEM     = p_orig_system
                         and B.ORIG_SYSTEM_ID  = p_orig_system_id
                         and B.PARTITION_ID    = p_partition_id
                         and TL.NAME           = B.NAME
                         and TL.ORIG_SYSTEM    = B.ORIG_SYSTEM
                         and TL.ORIG_SYSTEM_ID = B.ORIG_SYSTEM_ID
                         and TL.PARTITION_ID   = B.PARTITION_ID
                         and TL.LANGUAGE       = L.LANGUAGE_CODE));
  end if;
end translate_role;

--
-- CreateUser (PRIVATE)
--   Create a User
-- IN
--   name          - User Name
--   display_name  - User display name
--   description   -
--   notification_preference -
--   language      -
--   territory     -
--   email_address -
--   fax           -
--   status        -
--   expiration_date - NULL expiration date means no expiration
--   orig_system
--   orig_system_id
--   parent_orig_system
--   parent_orig_system_id
--   owner_tag -
--   last_update_date -
--   last_updated_by -
--   creation_date -
--   created_by -
--   last_update_login
-- OUT
--

procedure CreateUser( name                    in  varchar2,
                      display_name            in  varchar2,
                      orig_system             in  varchar2,
                      orig_system_id          in  number,
                      language                in  varchar2,
                      territory               in  varchar2,
                      description             in  varchar2,
                      notification_preference in  varchar2,
                      email_address           in  varchar2,
                      fax                     in  varchar2,
                      status                  in  varchar2,
                      expiration_date         in  date,
                      start_date              in  date,
                      parent_orig_system      in  varchar2,
                      parent_orig_system_id   in  number,
                      owner_tag               in  varchar2,
                      last_update_date        in  date,
                      last_updated_by         in  number,
                      creation_date           in  date,
                      created_by              in  number,
                      last_update_login       in  number,
                      source_lang             in  varchar2)
  is
    l_name  WF_LOCAL_ROLES.NAME%TYPE;
    l_display_name WF_LOCAL_ROLES.DISPLAY_NAME%TYPE;
    nlang   varchar2(30);
    nterr   varchar2(30);
    l_partitionID number;
    l_partitionName varchar2(30);
    l_origSys VARCHAR2(30);

    l_count   number;
    l_creatby number;
    l_creatdt date;
    l_lastupdby number;
    l_lastupddt date;
    l_lastupdlog number;

    l_ntfPref varchar2(8);

  begin

    -- [Name Validation]
    -- If concat name is passed, check to make sure it is valid.
    --
    if ( instr(name, ':') > 0 ) then
      if ( (orig_system||':'||orig_system_id ) <> name) then
        WF_CORE.Token('NAME', name);
        WF_CORE.Token('ORIG_SYSTEM', orig_system);
        WF_CORE.Token('ORIG_SYS_ID', orig_system_id);
        WF_CORE.Raise('WF_INVAL_CONCAT_NAME');

      end if;

    end if;

    --
    -- Make sure no '#' or '/' exist in name.
    --
    /* Bug 2779747
    if ( (instr(name, '/') > 0) or (instr(name, '#') > 0) ) then
      WF_CORE.Token('ROLENAME', name);
      WF_CORE.Raise('WF_INVALID_ROLE');
    */

    --
    -- Make sure the length of the name is  <= 320
    --
    if ( lengthb(name) > 320 ) then
      WF_CORE.Token('NAME', name);
      WF_CORE.Token('LENGTH', 320);
      WF_CORE.Raise('WF_ROLENAME_TOO_LONG');

    end if;

    --
    -- [Status Validation]
    --
    if ( CreateUser.status not in ('ACTIVE', 'TMPLEAVE', 'EXTLEAVE',
                                   'INACTIVE') ) then

      WF_CORE.Token('STATUS', CreateUser.status);
      WF_CORE.Raise('WF_INVALID_ROLE_STATUS');

    end if;

    --
    -- [Notification_Preference Validation]
    --
    -- Bug 2779747
    if (CreateUser.notification_preference is NULL) then
      if (CreateUser.email_address is NULL) then
        l_ntfPref := 'QUERY';
      else
        l_ntfPref := 'MAILHTML';
      end if;
    elsif (CreateUser.notification_preference not in ('MAILHTML','MAILHTM2',
         'MAILATTH', 'SUMMARY', 'SUMHTML', 'QUERY', 'MAILTEXT','DISABLED')) then
      WF_CORE.Token('NTF_PREF', CreateUser.notification_preference);
      WF_CORE.Raise('WF_INVALID_NTF_PREF');
    else
      l_ntfPref := CreateUser.notification_preference;
    end if;

    --
    -- Resolve Territory and Language
    --
    if (language is null or territory is null) then
      begin
        select nls_territory, nls_language into nterr, nlang
          from WF_LANGUAGES
         where code = userenv('LANG');
      exception
        when NO_DATA_FOUND then
          wf_core.raise('WF_NO_LANG_TERR');
      end;

    end if;

    l_origSys := UPPER(CreateUser.orig_system);
    --
    -- Set the partition for the orig_system
    --
      AssignPartition(l_origSys, l_partitionID, l_partitionName);

    --<rwunderl:4115907> Check to make sure the same name does not exist under
    --a different orig_system_id within this orig_system.  We may want to
    --change the indexes later to control this but given the data-model change
    --on the stage tables, we are just performing the check.
    if (instr(CreateUser.name, ':') < 1) then
      select count(*)
      into   l_count
      from   WF_LOCAL_ROLES
      where  NAME = CreateUser.name
      and    PARTITION_ID = l_partitionID
      and    ORIG_SYSTEM = l_origSys
      and    ORIG_SYSTEM_ID <> CreateUser.orig_system_id;
    end if;

    if (l_count > 0) then
      WF_CORE.Token('NAME', CreateUser.name);
      WF_CORE.Token('ORIG_SYSTEM', l_origSys);
      WF_CORE.Raise('WFDS_DUPLICATE_NAME');
    end if;
    --
    -- Evaluating the WHO columns in case they are not passed

    l_creatby := nvl(Createuser.created_by,WFA_SEC.USER_ID);
    l_creatdt   := nvl(CreateUser.creation_date, SYSDATE);
    l_lastupdby := nvl(CreateUser.last_updated_by, WFA_SEC.USER_ID);
    l_lastupddt := nvl(CreateUser.last_update_date, SYSDATE);
    l_lastupdlog:= nvl(CreateUser.last_update_login, WFA_SEC.LOGIN_ID);

    l_name := nvl(CreateUser.name,
                  l_origSys||':'||CreateUser.orig_system_id);
      l_display_name := nvl(CreateUser.display_name, l_name);

    -- Insert WF_LOCAL_ROLES with USER_FLAG = 'Y'
    --
      insert into WF_LOCAL_ROLES
         (name,
          display_name,
          description,
          notification_preference,
          language,
          territory,
          email_address,
          fax,
          status,
          expiration_date,
          orig_system,
          orig_system_id,
          start_date,
          user_flag,
          partition_id,
          parent_orig_system,
          parent_orig_system_id,
          owner_tag,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login)
        values(
      l_name,
      l_display_name,
           CreateUser.description,
           l_ntfPref,
           nvl(CreateUser.language, nlang),
           nvl(CreateUser.territory, nterr),
           CreateUser.email_address,
           CreateUser.fax,
           CreateUser.status,
           CreateUser.expiration_date,
           l_origSys,
           CreateUser.orig_system_id,
           CreateUser.start_date,
           'Y',
           l_partitionID,
           nvl(CreateUser.parent_orig_system, CreateUser.orig_system),
           nvl(CreateUser.parent_orig_system_id, CreateUser.orig_system_id),
           CreateUser.owner_tag,
           l_lastupddt,
           l_lastupdby,
           l_creatdt,
           l_creatby,
           l_lastupdlog );
    --If MLS language support is enabled for this orig_system
    --then sync the data to _TL table aswell.
    if (WF_DIRECTORY.IsMLSEnabled(l_origSys) = TRUE) then
      translate_role (p_name => l_name,
                      p_orig_system => l_origSys,
                      p_orig_system_id => CreateUser.orig_system_id,
                      p_partition_id => l_partitionID,
                      P_display_name => l_display_name,
                      p_description => CreateUser.description,
                      p_source_lang => CreateUser.source_lang,
                      p_overwrite => 'Y', -- *** possibly needs review.
                      p_owner_tag => CreateUser.owner_tag,
                      p_last_updated_by => l_lastupdby,
                      p_last_update_date => l_lastupddt,
                      p_last_update_login => l_lastupdlog);
                      --No need to pass CREATION_DATE or CREATED_BY as
                      --translate_role will assign the same value as CreateUser
    end if;



    --All Users belong to their own user/role relationship.
    begin
      CreateUserRole(user_name=>CreateUser.name,
                     role_name=>CreateUser.name,
                     user_orig_system=>l_origSys,
                     user_orig_system_id=>CreateUser.orig_system_id,
                     role_orig_system=>l_origSys,
                     role_orig_system_id=>CreateUser.orig_system_id,
                     start_date=>CreateUser.start_date,
                     end_date=>CreateUser.expiration_date,
                     validateUserRole=>FALSE,
                     parent_orig_system=>CreateUser.parent_orig_system,
                     parent_orig_system_id=>CreateUser.parent_orig_system_id,
                     owner_tag=>CreateUser.Owner_Tag,
                     last_update_date=>CreateUser.last_update_date,
                     last_updated_by=>CreateUser.last_updated_by,
                     creation_date=>CreateUser.creation_date,
                     created_by=>CreateUser.created_by,
                     last_update_login=>CreateUser.last_update_login);

    exception
      when OTHERS then
        if (WF_CORE.error_name = 'WF_DUP_USER_ROLE') then
          SetUserRoleAttr(user_name=>CreateUser.name,
                          role_name=>CreateUser.name,
                          user_orig_system=>l_origSys,
                          user_orig_system_id=>CreateUser.orig_system_id,
                          role_orig_system=>l_origSys,
                          role_orig_system_id=>CreateUser.orig_system_id,
                          start_date=>CreateUser.start_date,
                          end_date=>CreateUser.expiration_date,
                          overWrite=>TRUE,
                          parent_orig_system=>CreateUser.parent_orig_system,
                          parent_orig_system_id=>
                          CreateUser.parent_orig_system_id,
                          owner_tag=>CreateUser.owner_tag,
                          last_update_date=>CreateUser.last_update_date,
                          last_updated_by=>CreateUser.last_updated_by,
                          last_update_login=>CreateUser.last_update_login,
                          created_by=>CreateUser.created_by,
                          creation_date=>CreateUser.creation_date);

        else
          raise;

        end if;
    end;
exception
  when DUP_VAL_ON_INDEX then
    WF_CORE.Token('DISPNAME', CreateUser.display_name);
    WF_CORE.Token('USERNAME', nvl(CreateUser.name,
                                        l_origSys || ':' ||
                                        CreateUser.orig_system_id));
    WF_CORE.Raise('WF_DUP_USER');

  when others then
    wf_core.context('Wf_Directory', 'CreateUser', CreateUser.Name,
                    l_origSys, CreateUser.orig_system_id );
    raise;
end CreateUser;


--
-- CreateAdHocUser
--   Create an ad hoc user given a user name, display name, etc.
-- IN
--   name          - User name
--   display_name  - User display name
--   description   -
--   notification_preference -
--   language      -
--   territory     -
--   email_address -
--   fax           -
--   status        -
--   expiration_date - NULL expiration date means no expiration
-- OUT
--
procedure CreateAdHocUser(name                in out NOCOPY varchar2,
                      display_name            in out NOCOPY varchar2,
                      language                in  varchar2,
                      territory               in  varchar2,
                      description             in  varchar2,
                      notification_preference in  varchar2,
                      email_address           in  varchar2,
                      fax                     in  varchar2,
                      status                  in  varchar2,
                      expiration_date         in  date,
                      parent_orig_system      in  varchar2,
                      parent_orig_system_id   in  number)
is
  role_id pls_integer;
  d1      pls_integer;

begin
  --
  -- Check if user name and display name exists in wf_users
  --
  if (name is not null and display_name is not null) then

    /* GK: The display name does not have to be unique

    select count(1) into d1
      from wf_users u
      where u.name = CreateAdHocUser.name
         or u.display_name = CreateAdHocUser.display_name;
    if (d1 > 0) then
      wf_core.token('USERNAME', CreateAdHocUser.name);
      wf_core.token('DISPNAME', CreateAdHocUser.display_name);
      wf_core.raise('WF_DUP_USER');
    end if;

    */

    NULL;
  elsif (name is null ) then
    begin
      select to_char(WF_ADHOC_ROLE_S.NEXTVAL)
      into role_id
      from SYS.DUAL;
    exception
      when others then
        raise;
    end;

    CreateAdHocUser.name := '~WF_ADHOC-' || role_id;
    if display_name is null then
       CreateAdHocUser.display_name := CreateAdHocUser.name;
    end if;
  end if;

  CreateUser(name=>CreateAdHocUser.name,
             display_name=>CreateAdHocUser.display_name,
             orig_system=>'WF_LOCAL_USERS',
             orig_system_id=>0,
             language=>CreateAdHocUser.language,
             territory=>CreateAdHocUser.territory,
             description=>CreateAdHocUser.description,
             notification_preference=>CreateAdHocUser.notification_preference,
             email_address=>CreateAdHocUser.email_address,
             fax=>CreateAdHocUser.fax,
             status=>CreateAdHocUser.status,
             expiration_date=>CreateAdHocUser.expiration_date,
             parent_orig_system=>CreateAdhocUser.parent_orig_system,
             parent_orig_system_id=>CreateAdhocUser.parent_orig_system_id);


exception
  when others then
    wf_core.context('Wf_Directory', 'CreateAdHocUser');
    raise;
end CreateAdHocUser;


--
-- CreateRole (PRIVATE)
--   Create a role given a specific name
-- IN
--   role_name          -
--   role_display_name  -
--   role_description   -
--   notification_preference -
--   language           -
--   territory          -
--   email_address      -
--   fax                -
--   status             -
--   start_date         - defaults to sysdate
--   expiration_date   - Null means no expiration date
-- OUT
--
procedure CreateRole( role_name               in  varchar2,
                      role_display_name       in  varchar2,
                      orig_system             in  varchar2,
                      orig_system_id          in  number,
                      language                in  varchar2,
                      territory               in  varchar2,
                      role_description        in  varchar2,
                      notification_preference in  varchar2,
                      email_address           in  varchar2,
                      fax                     in  varchar2,
                      status                  in  varchar2,
                      expiration_date         in  date,
                      start_date              in  date,
                      parent_orig_system      in  varchar2,
                      parent_orig_system_id   in  number,
                      owner_tag               in  varchar2,
                      last_update_date        in  date,
                      last_updated_by         in  number,
                      creation_date           in  date,
                      created_by              in  number,
                      last_update_login       in  number,
                      source_lang             in  varchar2)

is
  nlang         varchar2(30);
  nterr         varchar2(30);
  l_partitionID NUMBER;
  l_partitionName VARCHAR2(30);
  l_origSys     VARCHAR2(30);
  --ER 16570228
  l_role_name WF_LOCAL_ROLES_TL.NAME%TYPE;
  l_display_name WF_LOCAL_ROLES_TL.DISPLAY_NAME%TYPE;

  TYPE numTAB is table of number index by binary_integer;
  l_origSysIDTAB numTAB;

  l_creatby number;
  l_creatdt date;
  l_lastupdby number;
  l_lastupddt date;
  l_lastupdlog number;

  l_ntfPref varchar2(8);
begin

  -- These validations are also performed in CreateUser.  Should the
  -- validations become resource intensive such as accessing DB, we
  -- might want to have a private variable to indicate if this is
  -- being called by CreateUser.

  -- [Name Validation]
  -- If concat role_name is passed, check to make sure it is valid.
  --
  if ( instr(role_name, ':') > 0 ) then
    if ( (orig_system||':'||orig_system_id ) <> role_name) then
      WF_CORE.Token('NAME', role_name);
      WF_CORE.Token('ORIG_SYSTEM', orig_system);
      WF_CORE.Token('ORIG_SYS_ID', orig_system_id);
      WF_CORE.Raise('WF_INVAL_CONCAT_NAME');

    end if;

  end if;

  --
  -- Make sure no '#' or '/' exist in role_name.
  --
  /* Bug 2779747
  if ( (instr(role_name, '/') > 0) or (instr(role_name, '#') > 0) ) then
    WF_CORE.Token('ROLENAME', role_name);
    WF_CORE.Raise('WF_INVALID_ROLE');
  */

  --
  -- Make sure the length of the role_name is  <= 320
  --
  if ( lengthb(role_name) > 320 ) then
    WF_CORE.Token('NAME', role_name);
    WF_CORE.Token('LENGTH', 320);
    WF_CORE.Raise('WF_ROLENAME_TOO_LONG');

  end if;

  --
  -- [Status Validation]
  --
  if ( CreateRole.status not in ('ACTIVE', 'TMPLEAVE', 'EXTLEAVE',
                                 'INACTIVE') ) then

    WF_CORE.Token('STATUS', CreateRole.status);
    WF_CORE.Raise('WF_INVALID_ROLE_STATUS');

  end if;

  --
  -- [Notification_Preference Validation]
  --
  -- Bug 2779747
    if (CreateRole.notification_preference is NULL) then
      if (CreateRole.email_address is NULL) then
        l_ntfPref := 'QUERY';
      else
        l_ntfPref := 'MAILHTML';
      end if;
    elsif (CreateRole.notification_preference not in ('MAILHTML','MAILHTM2',
         'MAILATTH', 'SUMMARY', 'SUMHTML', 'QUERY', 'MAILTEXT','DISABLED')) then
      WF_CORE.Token('NTF_PREF', CreateRole.notification_preference);
      WF_CORE.Raise('WF_INVALID_NTF_PREF');
    else
      l_ntfPref := CreateRole.notification_preference;
    end if;

  --
  -- Resolve Territory and Language
  --
    if (language is null or territory is null) then
      begin
        select nls_territory, nls_language into nterr, nlang
        from   WF_LANGUAGES
        where  code = userenv('LANG');

      exception
        when NO_DATA_FOUND then
          wf_core.raise('WF_NO_LANG_TERR');
      end;

    else
      nlang := CreateRole.language;
      nterr := CreateRole.territory;

    end if;

  l_origSys := UPPER(CreateRole.orig_system);

  --
  -- Check the partition.
  --
   AssignPartition(l_origSys,l_PartitionID, l_PartitionName);

  --<rwunderl:4115907> Check to make sure the same name does not exist under
  --a different orig_system_id within this orig_system.  We may want to
  --change the indexes later to control this but given the data-model change
  --on the stage tables, we are just performing the check.

  --We are also using bulk operation so we do not have to catch a
  --NO_DATA_FOUND exception which we expect this condition often.
  if (instr(CreateRole.role_name, ':') < 1) then

    select ORIG_SYSTEM_ID
    bulk collect into l_origSysIDTAB
    from   WF_LOCAL_ROLES
    where  NAME = CreateRole.role_name
    and    PARTITION_ID = l_partitionID
    and    ORIG_SYSTEM = CreateRole.orig_system
    and    ORIG_SYSTEM_ID <> CreateRole.orig_system_id
    and    rownum < 2;

  end if;

    -- Evaluating the WHO columns in case they are not passed

    l_creatby := nvl(CreateRole.created_by,WFA_SEC.USER_ID);
    l_creatdt   := nvl(CreateRole.creation_date, SYSDATE);
    l_lastupdby := nvl(CreateRole.last_updated_by, WFA_SEC.USER_ID);
    l_lastupddt := nvl(CreateRole.last_update_date, SYSDATE);
    l_lastupdlog:= nvl(CreateRole.last_update_login, WFA_SEC.LOGIN_ID);

  if (l_origSysIDTAB.COUNT > 0) then
    if (l_partitionID <> 2) then
      WF_CORE.Token('NAME', CreateRole.role_name);
      WF_CORE.Token('ORIG_SYSTEM', l_origSys);
      WF_CORE.Raise('WFDS_DUPLICATE_NAME');
    else
      --This is an FND_RESP which could be coming in from the loader using
      --afrole.lct, so we will go ahead and call the SetUserAttr() api
      --for the other orig_system_id.
      SetRoleAttr(role_name=>CreateRole.role_name,
                  orig_system=>l_origSys,
                  orig_system_id=>l_origSysIDTAB(1),
                  display_name=>CreateRole.role_display_name,
                  description=>CreateRole.role_description,
                  notification_preference=>l_ntfPref,
                  language=>CreateRole.language,
                  territory=>CreateRole.territory,
                  email_address=>CreateRole.email_address,
                  fax=>CreateRole.fax,
                  start_date=>CreateRole.start_date,
                  expiration_date=>CreateRole.Expiration_date,
                  status=>CreateRole.status,
                  parent_orig_system=>CreateRole.parent_orig_system,
                  parent_orig_system_id=>CreateRole.parent_orig_system_id,
                  owner_tag=>CreateRole.owner_tag,
                  source_lang=>CreateRole.source_lang);
    end if;
  else
    --
    -- Insert WF_LOCAL_ROLES with USER_FLAG = 'N'
    --
     l_role_name := nvl(CreateRole.role_name, l_origSys ||':'||CreateRole.orig_system_id);
     l_display_name := nvl(CreateRole.role_display_name, (l_role_name));

     insert into WF_LOCAL_ROLES
        (name,
         display_name,
         description,
         notification_preference,
         language,
         territory,
         email_address,
         fax,
         status,
         expiration_date,
         orig_system,
         orig_system_id,
         start_date,
         user_flag,
         partition_id,
         parent_orig_system,
         parent_orig_system_id,
         owner_tag,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login)
       values
        (l_role_name,
         l_display_name,
         CreateRole.role_description,
         l_ntfPref,
         nvl(CreateRole.language, nlang),
         nvl(CreateRole.territory, nterr),
         CreateRole.email_address,
         CreateRole.fax,
         CreateRole.status,
         CreateRole.expiration_date,
         l_origSys,
         CreateRole.orig_system_id,
         CreateRole.start_date,
         'N',
         l_PartitionID,
         CreateRole.parent_orig_system,
         CreateRole.parent_orig_system_id,
         CreateRole.owner_tag,
         l_lastupddt,
         l_lastupdby,
         l_creatdt,
         l_creatby,
         l_lastupdlog );

     if (WF_DIRECTORY.IsMLSEnabled(l_origSys) = TRUE) then
      --If the orig_system is MLS enabled then sync the dat into
      --the _TL table aswell.
      translate_role (p_name => l_role_name,
                      p_orig_system => l_origSys,
                      p_orig_system_id => CreateRole.orig_system_id,
                      p_partition_id => l_partitionID,
                      p_display_name => l_display_name,
                      p_description => CreateRole.role_description,
                      p_source_lang => source_lang,
                      p_overwrite => 'Y',
                      p_owner_tag => CreateRole.owner_tag,
                      p_last_updated_by => l_lastupdby,
                      p_last_update_date => l_lastupddt,
                      p_last_update_login => l_lastupdlog);
      end if;
    end if;
exception
  when DUP_VAL_ON_INDEX then
    WF_CORE.Token('DISPNAME', CreateRole.role_display_name);
    WF_CORE.Token('ROLENAME', nvl(CreateRole.role_name,
                                        l_origSys || ':' ||
                                        CreateRole.orig_system_id));
    WF_CORE.Raise('WF_DUP_ROLE');

  when others then
    wf_core.context('Wf_Directory', 'CreateRole', CreateRole.role_Name,
                    l_origSys, CreateRole.orig_system_id);
    raise;
end CreateRole;


--
-- CreateAdHocRole
--   Create an ad hoc role given a specific name
-- IN
--   role_name          -
--   role_display_name  -
--   role_description   -
--   notification_preference -
--   role_users         - Comma or space delimited list
--   language           -
--   territory          -
--   email_address      -
--   fax                -
--   status             -
--   expiration_date   - Null means no expiration date
-- OUT
--
procedure CreateAdHocRole(role_name               in out NOCOPY varchar2,
                          role_display_name       in out NOCOPY varchar2,
                          language                in            varchar2,
                          territory               in            varchar2,
                          role_description        in            varchar2,
                          notification_preference in            varchar2,
                          role_users              in            varchar2,
                          email_address           in            varchar2,
                          fax                     in            varchar2,
                          status                  in            varchar2,
                          expiration_date         in            date,
                          parent_orig_system      in            varchar2,
                          parent_orig_system_id   in            number,
                          owner_tag               in            varchar2)
is
  l_users WF_DIRECTORY.UserTable;

begin
  --Convert the string to a proper user table.
  if (role_users is NOT NULL) then
    WF_DIRECTORY.string_to_userTable(role_users, l_users);
  end if;

  --Pass the call over to the superceding procedure CreateAdHocRole2
  WF_DIRECTORY.CreateAdHocRole2(role_name=>CreateAdhocRole.role_name,
               role_display_name=>CreateAdhocRole.role_display_name,
               language=>CreateAdhocRole.language,
               territory=>CreateAdhocRole.Territory,
               role_description=>CreateAdhocRole.role_description,
               notification_preference=>CreateAdhocRole.notification_preference,
               role_users=>l_users,
               email_address=>CreateAdhocRole.email_address,
               fax=>CreateAdhocRole.fax,
               status=>CreateAdhocRole.status,
               expiration_date=>CreateAdhocRole.expiration_date,
               parent_orig_system=>CreateAdhocRole.parent_orig_system,
               parent_orig_system_id=>CreateAdhocRole.parent_orig_system_id,
               owner_tag=>CreateAdhocRole.owner_tag);
exception
  when others then
    wf_core.context('Wf_Directory', 'CreateAdHocRole');
    raise;
end CreateAdHocRole;

--
-- CreateAdHocRole2
--   Create an ad hoc role given a specific name
-- IN
--   role_name               -
--   role_display_name       -
--   role_description        -
--   notification_preference -
--   role_users              - WF_DIRECTORY.UserTable
--   language                -
--   territory               -
--   email_address           -
--   fax                     -
--   status                  -
--   expiration_date         - Null means no expiration date
-- OUT
--
procedure CreateAdHocRole2(role_name               in out NOCOPY varchar2,
                           role_display_name       in out NOCOPY varchar2,
                           language                in            varchar2,
                           territory               in            varchar2,
                           role_description        in            varchar2,
                           notification_preference in            varchar2,
                           role_users              in WF_DIRECTORY.UserTable,
                           email_address           in            varchar2,
                           fax                     in            varchar2,
                           status                  in            varchar2,
                           expiration_date         in            date,
                           parent_orig_system      in            varchar2,
                           parent_orig_system_id   in            number,
                           owner_tag               in            varchar2)
is
  role_id pls_integer;
  name    varchar2(320);
  d1      pls_integer;

begin
  --
  -- Check if role name exists in wf_roles
  --
  if (role_name is not null and role_display_name is not null) then
    /* GK: The display name does not have to be unique

    select count(1) into d1
      from wf_roles
      where name = CreateAdHocRole.role_name
         or display_name = CreateAdHocRole.role_display_name;
    if (d1 > 0) then
      wf_core.token('ROLENAME', CreateAdHocRole.role_name);
      wf_core.token('DISPNAME', CreateAdHocRole.role_display_name);
      wf_core.raise('WF_DUP_ROLE');
    end if;

    */

    NULL;

  elsif role_name is null then
  --
  -- Create role name if not exist
  --
    begin
      select to_char(WF_ADHOC_ROLE_S.NEXTVAL)
      into role_id
      from SYS.DUAL;
    exception
      when others then
        raise;
    end;

    role_name := '~WF_ADHOC-' || role_id;
    if role_display_name is null then
     role_display_name := role_name;
    end if;
  end if;

    CreateRole( role_name=>CreateAdHocRole2.role_name,
              role_display_name=>CreateAdHocRole2.role_display_name,
              orig_system=>'WF_LOCAL_ROLES',
              orig_system_id=>0,
              language=>CreateAdHocRole2.language,
              territory=>CreateAdHocRole2.territory,
              role_description=>CreateAdHocRole2.role_description,
              notification_preference=>CreateAdHocRole2.notification_preference,
              email_address=>CreateAdHocRole2.email_address,
              fax=>CreateAdHocRole2.fax,
              status=>CreateAdHocRole2.status,
              expiration_date=>CreateAdHocRole2.expiration_date,
              parent_orig_system=>CreateAdHocRole2.parent_orig_system,
              parent_orig_system_id=>CreateAdHocRole2.parent_orig_system_id,
              owner_tag=>CreateAdHocRole2.owner_tag );


  --
  -- Add Role Users
  --
  if (role_users.COUNT > 0) then
    AddUsersToAdHocRole2(CreateAdHocRole2.role_name,
                         CreateAdHocRole2.role_users);
  end if;


exception
  when others then
    wf_core.context('Wf_Directory', 'CreateAdHocRole2');
    raise;
end CreateAdHocRole2;

--
-- CreateUserRole (PRIVATE)
--   Create a user to role relationship.
-- IN
--   user_name -
--   role_name -
--   start_date -
--   expiration_date -
--   user_orig_system -
--   user_orig_system_id -
--   role_orig_system -
--   role_orig_system_id -
--   validateUserRole -
--   start_date  -
--   end_date -
--   created_by -
--   creation_date  -
--   last_updated_by  -
--   last_update_date -
--   last_update_login -
--   assignment_type -
--   assignment_type -
--   parent_orig_system -,
--   parent_orig_system_id -
--   owner_tag -
--   assignment_reason -
--
procedure CreateUserRole ( user_name             in  varchar2,
                           role_name             in  varchar2,
                           user_orig_system      in  varchar2,
                           user_orig_system_id   in  number,
                           role_orig_system      in  varchar2,
                           role_orig_system_id   in  number,
                           validateUserRole      in  boolean,
                           start_date            in  date,
                           end_date              in  date,
                           created_by            in  number,
                           creation_date         in  date,
                           last_updated_by       in  number,
                           last_update_date      in  date,
                           last_update_login     in  number,
                           assignment_type       in  varchar2,
                           parent_orig_system    in  varchar2,
                           parent_orig_system_id in  number,
                           owner_tag             in  varchar2,
                           assignment_reason     in  varchar2,
                           eventParams           in wf_parameter_list_t )

is
  l_count  PLS_INTEGER;
  l_upartID number;
  l_rpartID number;
  l_partitionID number;
  l_partitionName varchar2(30);
  l_uorigSys VARCHAR2(30);
  l_uorigSysID NUMBER;
  l_rorigSys VARCHAR2(30);
  l_rorigSysID NUMBER;
  l_validateUserRole BOOLEAN;
  l_params  WF_PARAMETER_LIST_T;
  l_affectedRow rowid;
  l_userStartDate date;
  l_userExpDate date;
  l_roleStartDate date;
  l_roleExpDate date;
  l_effStartDate date;
  l_effEndDate date;

  l_creatdt date;
  l_lastupddt date;
  l_lastupdby number;
  l_creatby   number;
  l_lastupdlog number;
  event wf_event_t;
  result varchar2(10);
  sub_id raw(20);
begin
  if ((user_orig_system is NULL) or (user_orig_system_id is NULL) or
      (role_orig_system is NULL) or (role_orig_system_id is NULL)) then
    --We need to validate by USER_NAME and ROLE_NAME to retreive the origSys
    --info.
    --Checking the user.
    begin
      SELECT ORIG_SYSTEM, ORIG_SYSTEM_ID,
      START_DATE, EXPIRATION_DATE,PARTITION_ID
      INTO   l_uorigSys, l_uorigSysID,
      l_userStartDate, l_userExpDate, l_upartID
      FROM   WF_LOCAL_ROLES
      WHERE  NAME = CreateUserRole.USER_NAME
      AND    ROWNUM < 2;
    exception
      when NO_DATA_FOUND then
        WF_CORE.Token('NAME', CreateUserRole.user_name);
        WF_CORE.Token('ORIG_SYSTEM', 'NULL');
        WF_CORE.Token('ORIG_SYSTEM_ID', 'NULL');
        WF_CORE.Raise('WF_NO_USER');
    end;

    --Checking the Role.
    begin
      SELECT ORIG_SYSTEM, ORIG_SYSTEM_ID,
      START_DATE, EXPIRATION_DATE, PARTITION_ID
      INTO   l_rorigSys, l_rorigSysID,
      l_roleStartDate, l_roleExpDate,l_rpartID
      FROM   WF_LOCAL_ROLES
      WHERE  NAME = CreateUserRole.ROLE_NAME
      AND    ROWNUM < 2;
    exception
      when NO_DATA_FOUND then
        WF_CORE.Token('NAME', CreateUserRole.role_name);
        WF_CORE.Token('ORIG_SYSTEM', 'NULL');
        WF_CORE.Token('ORIG_SYSTEM_ID', 'NULL');
        WF_CORE.Raise('WF_NO_ROLE');
    end;
  else
    l_validateUserRole := validateUserRole;
    l_uorigSys   := UPPER(CreateUserRole.user_orig_system);
    l_uorigSysID := CreateUserRole.user_orig_system_id;
    l_rorigSys   := UPPER(CreateUserRole.role_orig_system);
    l_rorigSysID := CreateUserRole.role_orig_system_id;

  end if;

  --
  -- Confirm that the User and Role actually exist.  We also need to make
  -- sure the user and role start/end dates are recorded.

  --
  -- Removed the requirement for the user_name to be an actual user per Kevin
  -- and Mark for JTF team.
  if (l_validateUserRole) then
    begin
     if (l_upartID is null) then
      AssignPartition(l_uorigSys,l_upartID, l_partitionName);
     end if;
      SELECT start_date, expiration_date
      into l_userStartDate, l_userExpDate
      FROM   WF_LOCAL_ROLES
      WHERE   NAME = CreateUserRole.user_name
      AND    ORIG_SYSTEM = l_uorigSys
      AND    ORIG_SYSTEM_ID = l_uorigSysID
      AND    PARTITION_ID = l_upartID;
    exception
      when NO_DATA_FOUND then
        WF_CORE.Token('NAME', CreateUserRole.user_name);
        WF_CORE.Token('ORIG_SYSTEM', l_uorigSys);
        WF_CORE.Token('ORIG_SYSTEM_ID', l_uorigSysID);
        WF_CORE.Raise('WF_NO_USER');
    end;

    begin
     if (l_rpartID is null) then
      AssignPartition(l_rorigSys,l_rpartID, l_partitionName);
     end if;

      SELECT start_date, expiration_date
      INTO l_roleStartDate, l_roleExpDate
      FROM   WF_LOCAL_ROLES
      WHERE  NAME = CreateUserRole.role_name
      AND    ORIG_SYSTEM = l_rorigSys
      AND    ORIG_SYSTEM_ID = l_rorigSysID
      AND    PARTITION_ID = l_rpartID;
    exception
      when NO_DATA_FOUND then
        WF_CORE.Token('NAME', CreateUserRole.role_name);
        WF_CORE.Token('ORIG_SYSTEM', l_rorigSys);
        WF_CORE.Token('ORIG_SYSTEM_ID', l_rorigSysID);
        WF_CORE.Raise('WF_NO_ROLE');
    end;
  elsif (CreateUserRole.user_name = CreateUserRole.role_name) then
    --If this is a self reference we can set the user and role date values to
    --the same as the start/end of the user/role relationship as they are the
    --same.
    l_userStartDate := CreateUserRole.start_date;
    l_userExpDate := CreateUserRole.end_date;
    l_roleStartDate := CreateUserRole.start_date;
    l_roleExpDate := CreateUserRole.end_date;
  end if;

  --
  -- Set the partition for the orig_system of the role_name
  --
  if (l_rpartID is null) then
   AssignPartition(l_rorigSys,
                  l_rpartID, l_partitionName);
  end if;

  -- Determine the effective dates for the user/role
  WF_ROLE_HIERARCHY.Calculate_Effective_Dates
                ( CreateUserRole.start_date,
                  CreateUserRole.end_date,
                  l_userStartDate,
                  l_userExpDate,
                  l_roleStartDate,
                  l_roleExpDate,
                  null,
                  null,
                  l_effStartDate,
                  l_effEndDate);

    -- Evaluate the WHO columns in case they are not passed

    l_creatby := nvl(CreateUserRole.created_by,WFA_SEC.USER_ID);
    l_creatdt   := nvl(CreateUserRole.creation_date, SYSDATE);
    l_lastupdby := nvl(CreateUserRole.last_updated_by, WFA_SEC.USER_ID);
    l_lastupddt := nvl(CreateUserRole.last_update_date, SYSDATE);
    l_lastupdlog:= nvl(CreateUserRole.last_update_login, WFA_SEC.LOGIN_ID);

    -- Insert
    begin
      insert into WF_LOCAL_USER_ROLES
                  ( USER_NAME,
                    ROLE_NAME,
                    USER_ORIG_SYSTEM,
                    USER_ORIG_SYSTEM_ID,
                    ROLE_ORIG_SYSTEM,
                    ROLE_ORIG_SYSTEM_ID,
                    START_DATE,
                    EXPIRATION_DATE,
                    USER_START_DATE,
                    USER_END_DATE,
                    ROLE_START_DATE,
                    ROLE_END_DATE,
                    EFFECTIVE_START_DATE,
                    EFFECTIVE_END_DATE,
                    PARTITION_ID,
                    PARENT_ORIG_SYSTEM,
                    PARENT_ORIG_SYSTEM_ID,
                    ASSIGNMENT_TYPE,
                    OWNER_TAG,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN,
                    ASSIGNMENT_REASON
                  )
               values
                  (
                    CreateUserRole.user_name,
                    CreateUserRole.role_name,
                    l_uorigSys,
                    l_uorigSysID,
                    l_rorigSys,
                    l_rorigSysID,
                    trunc(CreateUserRole.start_date),
                    trunc(CreateUserRole.end_date),
                    l_userStartDate,
                    l_userExpDate,
                    l_roleStartDate,
                    l_roleExpDate,
                    l_effStartDate,
                    l_effEndDate,
                    l_rpartID,
                    nvl(CreateUserRole.parent_orig_system,
                        CreateUserRole.role_orig_system),
                    nvl(CreateUserRole.parent_orig_system_id,
                        CreateUserRole.role_orig_system_id),
                    CreateUserRole.assignment_type,
                    CreateUserRole.owner_tag,
                    l_lastupddt,
                    l_lastupdby,
                    l_creatdt,
                    l_creatby,
                    l_lastupdlog,
                    CreateUserRole.assignment_reason
                   ) returning rowid into l_affectedRow;

    --We were able to insert the record, so we will raise the created event
    --Build parameter list.
    WF_EVENT.AddParameterToList('ROWID', ROWIDTOCHAR(l_affectedRow), l_params);
    WF_EVENT.AddParameterToList('USER_NAME', CreateUserRole.user_name, l_params);
    WF_EVENT.AddParameterToList('ROLE_NAME', CreateUserRole.role_name, l_params);
    WF_EVENT.AddParameterToList('USER_ORIG_SYSTEM', l_uorigSys, l_params);
    WF_EVENT.AddParameterToList('USER_ORIG_SYSTEM_ID', l_uorigSysID,  l_params);
    WF_EVENT.AddParameterToList('ROLE_ORIG_SYSTEM', l_rorigSys, l_params);
    WF_EVENT.AddParameterToList('ROLE_ORIG_SYSTEM_ID', l_rorigSysID, l_params);
    WF_EVENT.AddParameterToList('START_DATE',
                                to_char(trunc(CreateUserRole.start_date),
                                        WF_CORE.Canonical_Date_Mask),
                                l_params);
    WF_EVENT.AddParameterToList('END_DATE',
                                to_char(trunc(CreateUserRole.end_date),
                                        WF_CORE.Canonical_Date_Mask),
                                l_params);

    WF_EVENT.AddParameterToList('CREATED_BY',
                                to_char(CreateUserRole.created_by,
                                        WF_CORE.canonical_number_mask), l_params);

  WF_EVENT.AddParameterToList('CREATION_DATE',
                               to_char(CreateUserRole.creation_date,
                                        WF_CORE.canonical_date_mask), l_params);

    WF_EVENT.AddParameterToList('LAST_UPDATED_BY',
                                to_char(CreateUserRole.last_updated_by,
                                WF_CORE.canonical_number_mask), l_params);
     WF_EVENT.AddParameterToList('LAST_UPDATE_DATE',
                                to_char(CreateUserRole.last_update_date,
                                        WF_CORE.canonical_date_mask), l_params);
    WF_EVENT.AddParameterToList('LAST_UPDATE_LOGIN',
                                to_char(CreateUserRole.last_update_login,
                                WF_CORE.canonical_number_mask), l_params);
    WF_EVENT.AddParameterToList('ASSIGNMENT_TYPE',
                                CreateUserRole.assignment_type, l_params);
    WF_EVENT.AddParameterToList('PARENT_ORIG_SYSTEM',
                                CreateUserRole.parent_orig_system, l_params);
    WF_EVENT.AddParameterToList('PARENT_ORIG_SYSTEM_ID',
                                to_char(CreateUserRole.parent_orig_system_id,
                                WF_CORE.canonical_number_mask), l_params);
    WF_EVENT.AddParameterToList('PARTITION_ID', to_char(l_partitionID,
                                WF_CORE.canonical_number_mask),l_params);
    WF_EVENT.AddParameterToList('ASSIGNMENT_REASON',
                                CreateUserRole.assignment_reason, l_params);
   if (eventParams is not null and eventParams.count>0) then
     for i in eventParams.first..eventParams.last loop
       WF_EVENT.AddParameterToList(upper(eventParams(i).getName()),
          eventParams(i).getValue(),l_params);
     end loop;
  end if;
  --determine if BES is enabled
  if (wf_directory.System_Status()='DISABLED') then
  --Create the event that is to be raised

    wf_event_t.initialize(event);
    event.Send_Date      := sysdate;
    event.Event_Name     := 'oracle.apps.fnd.wf.ds.userRole.created';
    event.Event_Key      := l_uOrigSys||':'||
                                to_char(l_uOrigSysId)||'|'||
                             l_rOrigSys||':'||
                                to_char(l_rOrigSysId)||'|'||
                                to_char(SYSDATE, 'J:SSSSS');
    event.Parameter_List := l_params;
    sub_id:= hextoraw('1');
    result:= WF_ROLE_HIERARCHY.Cascade_RF(sub_id,event);
    if (result='SUCCESS') then
     result:= WF_ROLE_HIERARCHY.Aggregate_User_Roles_RF(sub_id,event);
    end if;
  else
    WF_EVENT.Raise(p_event_name=>'oracle.apps.fnd.wf.ds.userRole.created',
                   p_event_key=> l_uOrigSys||':'||
                                to_char(l_uOrigSysId)||'|'||
                             l_rOrigSys||':'||
                                to_char(l_rOrigSysId)||'|'||
                                to_char(SYSDATE, 'J:SSSSS'),
                   p_parameters=>l_params);
  end if;

  exception
      when DUP_VAL_ON_INDEX then
        WF_CORE.Token('UNAME', CreateUserRole.user_name);
        WF_CORE.Token('RNAME', CreateUserRole.role_name);
        WF_CORE.Raise('WF_DUP_USER_ROLE');

      when OTHERS then
        raise;

  end;



exception
  when others then
    wf_core.context('Wf_Directory', 'CreateUserRole',
        user_name, role_name, l_uorigSys,
        to_char(nvl(user_orig_system_id, l_uorigSysID)),
        l_rorigSys, to_char(nvl(role_orig_system_id, l_rorigSysID)));

    raise;

end CreateUserRole;


--
-- SetUserRoleAttr (PRIVATE)
--   Update a user to role relationship.
-- IN
--   user_name -
--   role_name -
--   start_date -
--   expiration_date -
--   user_orig_system -
--   user_orig_system_id -
--   role_orig_system -
--   role_orig_system_id -
--   OverWrite -
--   last_updated_by -
--   last_update_date -
--   last_update_login -
--   assignment_type  -
--   parent_orig_system -
--   parent_orig_system_id
--   owner_tag
--   last_update_date -
--   last_updated_by -
--   creation_date -
--   created_by -
--   last_update_login  -
--   assignment_reason -
--   updateWho
procedure SetUserRoleAttr ( user_name             in varchar2,
                            role_name             in varchar2,
                            start_date            in date,
                            end_date              in date,
                            user_orig_system      in varchar2,
                            user_orig_system_id   in number,
                            role_orig_system      in varchar2,
                            role_orig_system_id   in number,
                            OverWrite             in boolean,
                            last_updated_by       in number,
                            last_update_date      in date,
                            last_update_login     in number,
                            created_by            in number,
                            creation_date         in date,
                            assignment_type       in varchar2,
                            parent_orig_system    in varchar2,
                            parent_orig_system_id in number,
                            owner_tag             in varchar2,
                            assignment_reason     in varchar2,
                            updateWho             in BOOLEAN,
                            eventParams           in wf_parameter_list_t) is

  l_uorigSys    VARCHAR2(30) := UPPER(user_orig_system);
  l_uorigSysID  NUMBER       := UPPER(user_orig_system_id);
  l_rorigSys    VARCHAR2(30) := UPPER(role_orig_system);
  l_rorigSysID  NUMBER       := UPPER(role_orig_system_id);
  l_porigSys    VARCHAR2(30) := UPPER(nvl(parent_orig_system,
                                          role_orig_system));
  l_porigSysID  NUMBER       := UPPER(nvl(parent_orig_system_id,
                                          role_orig_system_id));
  l_params      WF_PARAMETER_LIST_T;
  l_affectedRow rowid;

  l_lastupdby  NUMBER;
  l_lastupddt  DATE;
  l_lastupdlog NUMBER;
  l_oldstartdate date;
  l_oldenddate date;
  l_UpdateWho BOOLEAN := nvl(updateWho,TRUE);
  l_partitionID number;
  l_partitionName varchar2(30);
  event wf_event_t;
  result varchar2(10);
  sub_id raw(20);
begin
  --<rwunderl:2823630> Lookup origSys info if not provided.
  if ((SetUserRoleAttr.user_orig_system is NULL) or
      (SetUserRoleAttr.user_orig_system_id is NULL)) then
    --Checking the user.
    begin
      SELECT ORIG_SYSTEM, ORIG_SYSTEM_ID
      INTO   l_uorigSys, l_uorigSysID
      FROM   WF_LOCAL_ROLES
      WHERE  NAME = SetUserRoleAttr.user_name
      and    rownum < 2;

    exception
      when NO_DATA_FOUND then
        WF_CORE.Token('NAME', SetUserRoleAttr.user_name);
        WF_CORE.Token('ORIG_SYSTEM', 'NULL');
        WF_CORE.Token('ORIG_SYSTEM_ID', 'NULL');
        WF_CORE.Raise('WF_NO_USER');
    end;
  end if;


  if ((SetUserRoleAttr.role_orig_system is NULL) or
      (SetUserRoleAttr.role_orig_system_id is NULL)) then
    --Checking the role.
    begin
      SELECT ORIG_SYSTEM, ORIG_SYSTEM_ID, PARTITION_ID
      INTO   l_rorigSys, l_rorigSysID,l_partitionID
      FROM   WF_LOCAL_ROLES
      WHERE  NAME = SetUserRoleAttr.role_name
      AND    rownum < 2;

     if (l_porigSys is NULL or l_porigSysID is NULL) then
       l_porigSys := l_rorigSys;
       l_porigSysID := l_rorigSysID;
     end if;

    exception
      when NO_DATA_FOUND then
        WF_CORE.Token('NAME', SetUserRoleAttr.role_name);
        WF_CORE.Token('ORIG_SYSTEM', 'NULL');
        WF_CORE.Token('ORIG_SYSTEM_ID', 'NULL');
        WF_CORE.Raise('WF_NO_ROLE');
    end;
  end if;
  if (l_partitionID is null) then
   AssignPartition(l_rorigSys,l_partitionID,l_partitionName);
  end if;
  --We  need to capture the current start/end date in case they are
  --changed.
  begin
    -- Bug 8680963 / 9323176
    select START_DATE, END_DATE
    into   l_oldStartDate, l_oldEndDate
    from   (select START_DATE, END_DATE
            from   WF_USER_ROLE_ASSIGNMENTS
            where  USER_NAME          = SetUserRoleAttr.user_name
            and    ROLE_NAME          = SetUserRoleAttr.role_name
            and    USER_ORIG_SYSTEM    = l_uorigSys
            and    USER_ORIG_SYSTEM_ID = l_uorigSysID
            and    ROLE_ORIG_SYSTEM    = l_rorigSys
            and    ROLE_ORIG_SYSTEM_ID = l_rorigSysID
            and    PARTITION_ID = l_partitionID
            order  by relationship_id)
    where   rownum = 1;
    -- By using rownum=1 and ordering by relationship_id we guarantee the
    -- direct assignment will go first and then the older indirect assignments

  exception
    when NO_DATA_FOUND then
       WF_CORE.Raise('WF_INVAL_USER_ROLE');
  end;

    -- Evaluating the WHO columns in case they are not passed
    l_lastupdby := nvl(setuserroleattr.last_updated_by, WFA_SEC.USER_ID);
    l_lastupddt := nvl(setuserroleattr.last_update_date, SYSDATE);
    l_lastupdlog:= nvl(setuserroleattr.last_update_login, WFA_SEC.LOGIN_ID);

  if (OverWrite and l_updateWho) then
    update WF_LOCAL_USER_ROLES
    set EXPIRATION_DATE       = SetUserRoleAttr.end_date,
        START_DATE            = SetUserRoleAttr.start_date,
        LAST_UPDATED_BY       = l_lastupdby,
        LAST_UPDATE_DATE      = l_lastupddt,
        LAST_UPDATE_LOGIN     = l_lastupdlog,
          -- <7298384> never update CREATION_DATE, CREATED_BY on update dml
--        CREATION_DATE         = nvl(SetUserRoleAttr.creation_date,
--                                    CREATION_DATE),
--        CREATED_BY            = nvl(SetUserRoleAttr.created_by, CREATED_BY), -- </7298384>
        PARENT_ORIG_SYSTEM    = l_porigSys,
        PARENT_ORIG_SYSTEM_ID = l_porigSysID,
        ASSIGNMENT_REASON     = SetUserRoleAttr.assignment_reason
    where  USER_NAME          = SetUserRoleAttr.user_name
    and    ROLE_NAME          = SetUserRoleAttr.role_name
    and    USER_ORIG_SYSTEM    = l_uorigSys
    and    USER_ORIG_SYSTEM_ID = l_uorigSysID
    and    ROLE_ORIG_SYSTEM    = l_rorigSys
    and    ROLE_ORIG_SYSTEM_ID = l_rorigSysID
    and    PARTITION_ID = l_partitionID
    returning rowid into l_affectedRow;

  elsif (OverWrite) then  --donot Update WHO Columns
    update WF_LOCAL_USER_ROLES
    set EXPIRATION_DATE       = SetUserRoleAttr.end_date,
        START_DATE            = SetUserRoleAttr.start_date,
        PARENT_ORIG_SYSTEM    = l_porigSys,
        PARENT_ORIG_SYSTEM_ID = l_porigSysID,
        ASSIGNMENT_REASON     = SetUserRoleAttr.assignment_reason
    where  USER_NAME          = SetUserRoleAttr.user_name
    and    ROLE_NAME          = SetUserRoleAttr.role_name
    and    USER_ORIG_SYSTEM    = l_uorigSys
    and    USER_ORIG_SYSTEM_ID = l_uorigSysID
    and    ROLE_ORIG_SYSTEM    = l_rorigSys
    and    ROLE_ORIG_SYSTEM_ID = l_rorigSysID
    and    PARTITION_ID = l_partitionID
    returning rowid into l_affectedRow;

  elsif (l_updateWho) then -- Update WHO columns
    update WF_LOCAL_USER_ROLES
          set    EXPIRATION_DATE = nvl(SetUserRoleAttr.end_date, EXPIRATION_DATE),
                 START_DATE = nvl(SetUserRoleAttr.start_date, START_DATE),
                 PARENT_ORIG_SYSTEM = nvl(SetUserRoleAttr.parent_orig_system,
                                          l_porigSys),
                 PARENT_ORIG_SYSTEM_ID = nvl(
                                          SetUserRoleAttr.parent_orig_system_id,
                                           l_porigSysID),
                 LAST_UPDATED_BY     = l_lastupdby,
                 LAST_UPDATE_DATE    = l_lastupddt,
                 LAST_UPDATE_LOGIN   = l_lastupdlog,
                 -- <7298384> never update CREATION_DATE, CREATED_BY on update dml
--                 CREATED_BY          = nvl(SetUserRoleAttr.created_by,
--                                           created_by),
--                 CREATION_DATE       = nvl(SetUserRoleAttr.creation_date,
--                                           creation_date), -- </7298384>
                 ASSIGNMENT_REASON   = nvl(SetUserRoleAttr.assignment_reason,
                                           ASSIGNMENT_REASON)
          where  USER_NAME        = SetUserRoleAttr.user_name
          and    ROLE_NAME        = SetUserRoleAttr.role_name
          and    USER_ORIG_SYSTEM    = l_uorigSys
          and    USER_ORIG_SYSTEM_ID = l_uorigSysID
          and    ROLE_ORIG_SYSTEM    = l_rorigSys
          and    ROLE_ORIG_SYSTEM_ID = l_rorigSysID
    and    PARTITION_ID = l_partitionID
          returning rowid into l_affectedRow;


  else  --Donot Update Who columns
    update WF_LOCAL_USER_ROLES
          set    EXPIRATION_DATE = nvl(SetUserRoleAttr.end_date, EXPIRATION_DATE),
                 START_DATE = nvl(SetUserRoleAttr.start_date, START_DATE),
                 PARENT_ORIG_SYSTEM = nvl(SetUserRoleAttr.parent_orig_system,
                                          l_porigSys),
                 PARENT_ORIG_SYSTEM_ID = nvl(
                                          SetUserRoleAttr.parent_orig_system_id,
                                           l_porigSysID),
                 ASSIGNMENT_REASON   = nvl(SetUserRoleAttr.assignment_reason,
                                           ASSIGNMENT_REASON)
          where  USER_NAME        = SetUserRoleAttr.user_name
          and    ROLE_NAME        = SetUserRoleAttr.role_name
          and    USER_ORIG_SYSTEM    = l_uorigSys
          and    USER_ORIG_SYSTEM_ID = l_uorigSysID
          and    ROLE_ORIG_SYSTEM    = l_rorigSys
          and    ROLE_ORIG_SYSTEM_ID = l_rorigSysID
          and    PARTITION_ID = l_partitionID
          returning rowid into l_affectedRow;

  end if;

  if (sql%ROWCOUNT = 0) then
    WF_CORE.Raise('WF_INVAL_USER_ROLE');

  end if;
    --We were able to update an existing record, so we will raise the
    --updated event

    --Build parameter list.
    WF_EVENT.AddParameterToList('ROWID', ROWIDTOCHAR(l_affectedRow), l_params);
    WF_EVENT.AddParameterToList('USER_NAME', SetUserRoleAttr.user_name,
                                l_params);
    WF_EVENT.AddParameterToList('ROLE_NAME', SetUserRoleAttr.role_name,
                                l_params);
    WF_EVENT.AddParameterToList('USER_ORIG_SYSTEM', l_uorigSys, l_params);
    WF_EVENT.AddParameterToList('USER_ORIG_SYSTEM_ID', to_char(l_uorigSysID,
                               WF_CORE.canonical_number_mask), l_params);
    WF_EVENT.AddParameterToList('ROLE_ORIG_SYSTEM', l_rorigSys, l_params);
    WF_EVENT.AddParameterToList('ROLE_ORIG_SYSTEM_ID', to_char(l_rorigSysID,
                              WF_CORE.canonical_number_mask), l_params);
    WF_EVENT.AddParameterToList('PARENT_ORIG_SYSTEM', l_porigSys, l_params);
    WF_EVENT.AddParameterToList('PARENT_ORIG_SYSTEM_ID', to_char(l_porigSysID,
                              WF_CORE.canonical_number_mask), l_params);
    WF_EVENT.AddParameterToList('START_DATE',
                                to_char(trunc(SetUserRoleAttr.start_date),
                                        WF_CORE.canonical_date_mask),
                                l_params);
    WF_EVENT.AddParameterToList('END_DATE',
                                to_char(trunc(SetUserRoleAttr.end_date),
                                        WF_CORE.canonical_date_mask),
                                l_params);

    if ((((l_oldStartDate is NOT NULL) and
         (SetUserRoleAttr.start_date is NOT NULL)) and
         (trunc(l_oldStartDate) <> trunc(SetUserRoleAttr.start_date))) or
        ((l_oldStartDate is NULL and SetUserRoleAttr.start_date is NOT NULL) or
         (SetUserRoleAttr.start_date is NULL and l_oldStartDate is NOT NULL))) then

      WF_EVENT.AddParameterToList('OLD_START_DATE',
                                  to_char(trunc(l_oldStartDate),
                                          WF_CORE.Canonical_Date_Mask),
                                          l_params);
    else
      WF_EVENT.AddParameterToList('OLD_START_DATE', '*UNDEFINED*',
                                          l_params);
    end if;

    if ((((l_oldEndDate is NOT NULL) and
         (SetUserRoleAttr.end_date is NOT NULL)) and
         (trunc(l_oldEndDate) <> trunc(SetUserRoleAttr.end_date))) or
        ((l_oldEndDate is NULL and SetUserRoleAttr.end_date is NOT NULL)
        or (SetUserRoleAttr.end_date is NULL
          and l_oldEndDate is NOT NULL))) then

      WF_EVENT.AddParameterToList('OLD_END_DATE',
                                  to_char(trunc(l_oldEndDate),
                                          WF_CORE.Canonical_Date_Mask),
                                  l_params);
    else
      WF_EVENT.AddParameterToList('OLD_END_DATE', '*UNDEFINED*',
                                          l_params);
    end if;


    WF_EVENT.AddParameterToList('LAST_UPDATED_BY',
                                to_char(SetUserRoleAttr.last_updated_by,
                                WF_CORE.canonical_number_mask), l_params);

    WF_EVENT.AddParameterToList('LAST_UPDATE_DATE',
                                to_char(SetUserRoleAttr.last_update_date,
                                        WF_CORE.canonical_date_mask), l_params);
    WF_EVENT.AddParameterToList('LAST_UPDATE_LOGIN',
                                to_char(SetUserRoleAttr.last_update_login,
                                WF_CORE.canonical_number_mask), l_params);

    WF_EVENT.AddParameterToList('CREATED_BY',
                                to_char(SetUserRoleAttr.created_by,
                                WF_CORE.canonical_number_mask), l_params);

    WF_EVENT.AddParameterToList('CREATION_DATE',
                               to_char(SetUserRoleAttr.creation_date,
                                        WF_CORE.canonical_date_mask), l_params);

    WF_EVENT.AddParameterToList('ASSIGNMENT_TYPE',
                                SetUserRoleAttr.assignment_type, l_params);

    WF_EVENT.AddParameterToList('ASSIGNMENT_REASON',
                                SetUserRoleAttr.assignment_reason, l_params);

    if (OverWrite) then
     WF_EVENT.AddParameterToList('WFSYNCH_OVERWRITE', 'TRUE',l_params );
    end if;

    if (l_updateWho) then
     WF_EVENT.AddParameterToList('UPDATE_WHO','TRUE',l_params);
    end if;

   if (eventParams is not null and eventParams.count>0) then
     for i in eventParams.first..eventParams.last loop
       WF_EVENT.AddParameterToList(upper(eventParams(i).getName()),
          eventParams(i).getValue(),l_params);
     end loop;
  end if;

  --determine if BES is enabled
  if (wf_directory.System_Status()='DISABLED') then
  --Create the event that is to be raised

    wf_event_t.initialize(event);
    event.Send_Date      := sysdate;
    event.Event_Name     := 'oracle.apps.fnd.wf.ds.userRole.updated';
    event.Event_Key      :=  l_uOrigSys||':'||
                                to_char(l_uOrigSysId)||'|'||
                             l_rOrigSys||':'||
                                to_char(l_rOrigSysId)||'|'||
                                to_char(SYSDATE, 'J:SSSSS');

    event.Parameter_List := l_params;
    sub_id :=hextoraw('1');
    result:= WF_ROLE_HIERARCHY.Cascade_RF(sub_id,event);
    if (result='SUCCESS') then
     result:= WF_ROLE_HIERARCHY.Aggregate_User_Roles_RF(sub_id,event);
    end if;
  else
    WF_EVENT.Raise(p_event_name=>'oracle.apps.fnd.wf.ds.userRole.updated',
                   p_event_key=> l_uOrigSys||':'||
                                to_char(l_uOrigSysId)||'|'||
                             l_rOrigSys||':'||
                                to_char(l_rOrigSysId)||'|'||
                                to_char(SYSDATE, 'J:SSSSS'),
                   p_parameters=>l_params);
  end if;


end;


--
-- RemoveUserRole (PRIVATE)
--   Remove a user from a role.
-- IN
--   user_name -
--   role_name -
--   user_orig_system -
--   user_orig_system_id -
--   role_orig_system -
--   role_orig_system_id -
--
procedure RemoveUserRole(user_name           in varchar2,
                         role_name           in varchar2,
                         user_orig_system    in varchar2,
                         user_orig_system_id in number,
                         role_orig_system    in varchar2,
                         role_orig_system_id in number)
is

  l_lastupddt date;
  l_lastupdlog number;
  l_lastupdby  number;
  l_expdate    date;
  l_partitionID number;
  l_partitionName varchar2(30);

begin
  -- set the expiration date
  l_expdate := SYSDATE;

  --set the who columns

  l_lastupddt := SYSDATE;
  l_lastupdby := WFA_SEC.USER_ID;
  l_lastupdlog := WFA_SEC.LOGIN_ID;

  AssignPartition( RemoveUserRole.role_orig_system,l_partitionId,l_partitionName);

  if (user_orig_system is null or user_orig_system_id is null) then
    -- Expire user
    update WF_LOCAL_USER_ROLES
    set    EXPIRATION_DATE     =  l_expdate,
           EFFECTIVE_END_DATE = l_expdate,
           LAST_UPDATED_BY     =  l_lastupdby,
           LAST_UPDATE_LOGIN   =  l_lastupdlog,
           LAST_UPDATE_DATE    =  l_lastupddt
    where  USER_NAME           =  RemoveUserRole.user_name
    and    ROLE_NAME           =  RemoveUserRole.role_name
    and    ROLE_ORIG_SYSTEM    =  RemoveUserRole.role_orig_system
    and    ROLE_ORIG_SYSTEM_ID =  RemoveUserRole.role_orig_system_id
    and    PARTITION_ID        =  l_partitionID;

   update WF_USER_ROLE_ASSIGNMENTS
    set    END_DATE     =  l_expdate,
           EFFECTIVE_END_DATE = l_expdate,
           LAST_UPDATED_BY     = l_lastupdby,
           LAST_UPDATE_LOGIN   =  l_lastupdlog,
           LAST_UPDATE_DATE    =  l_lastupddt
    where  USER_NAME           =  RemoveUserRole.user_name
    and    ROLE_NAME           =  RemoveUserRole.role_name
    and    ROLE_ORIG_SYSTEM    =  RemoveUserRole.role_orig_system
    and    ROLE_ORIG_SYSTEM_ID =  RemoveUserRole.role_orig_system_id;

  else

    -- Expire user with orig system and orig system id
    update WF_LOCAL_USER_ROLES
    set    EXPIRATION_DATE     =  l_expdate,
           EFFECTIVE_END_DATE  = l_expdate,
           LAST_UPDATED_BY     = l_lastupdby,
           LAST_UPDATE_LOGIN   =  l_lastupdlog,
           LAST_UPDATE_DATE    =  l_lastupddt
    where  USER_NAME           =  RemoveUserRole.user_name
    and    ROLE_NAME           =  RemoveUserRole.role_name
    and    USER_ORIG_SYSTEM    =  RemoveUserRole.user_orig_system
    and    USER_ORIG_SYSTEM_ID =  RemoveUserRole.user_orig_system_id
    and    ROLE_ORIG_SYSTEM    =  RemoveUserRole.role_orig_system
    and    ROLE_ORIG_SYSTEM_ID =  RemoveUserRole.role_orig_system_id
    and    PARTITION_ID        = l_partitionID;

    update WF_USER_ROLE_ASSIGNMENTS
    set    END_DATE            =  l_expdate,
           EFFECTIVE_END_DATE  = l_expdate,
           LAST_UPDATED_BY     =  l_lastupdby,
           LAST_UPDATE_LOGIN   =  l_lastupdlog,
           LAST_UPDATE_DATE    =  l_lastupddt
    where  USER_NAME           =  RemoveUserRole.user_name
    and    ROLE_NAME           =  RemoveUserRole.role_name
    and    USER_ORIG_SYSTEM    =  RemoveUserRole.user_orig_system
    and    USER_ORIG_SYSTEM_ID =  RemoveUserRole.user_orig_system_id
    and    ROLE_ORIG_SYSTEM    =  RemoveUserRole.role_orig_system
    and    ROLE_ORIG_SYSTEM_ID =  RemoveUserRole.role_orig_system_id;

  end if;

  -- DL: did not trap the WF_INVALID_USER error here.
  -- It should be fine if someone want to remove a user again from the
  -- same role.  Plus it should be a user/role not exist, not an invalid
  -- user.

exception
  when others then
    wf_core.context('Wf_Directory', 'RemoveUserRole',
        user_name, role_name, user_orig_system, to_char(user_orig_system_id),
        role_orig_system, to_char(role_orig_system_id));

    raise;
end RemoveUserRole;

--
-- AddUsersToAdHocRole (Deprecated)
--   Use AddUsersToAdHocRole2
-- IN
--   role_name     - AdHoc role name
--   role_users    - Space or comma delimited list of apps-based users
--                      or adhoc users
-- OUT
--
procedure AddUsersToAdHocRole(role_name         in varchar2,
                              role_users        in  varchar2)
is
  l_users WF_DIRECTORY.UserTable;

begin

  if (role_users is NOT NULL) then
    String_To_UserTable (p_UserList=>AddUsersToAdHocRole.role_users,
                         p_UserTable=>l_users);

    AddUsersToAdHocRole2(role_name=>AddUsersToAdHocRole.role_name,
                         role_users=>l_users);
  end if;

exception
  when others then
    wf_core.context('Wf_Directory', 'AddUsersToAdHocRole',
        role_name, '"'||role_users||'"');
    raise;
end AddUsersToAdHocRole;

--
-- AddUsersToAdHocRole2
--   Add users to an existing ad hoc role
-- IN
--   role_name     - AdHoc role name
--   role_users    - Space or comma delimited list of apps-based users
--                      or adhoc users
-- OUT
--
procedure AddUsersToAdHocRole2(role_name         in varchar2,
                               role_users        in WF_DIRECTORY.UserTable) is

  d1               pls_integer;
  colon            pls_integer;
  userIND          number;
  l_orig_system    varchar2(30) := NULL;
  l_orig_system_id number       := NULL;

begin
  -- Validate Role
  if (wfa_sec.DS_Count_Local_Role(AddUsersToAdHocRole2.role_name) <= 0) then
    wf_core.token('ROLENAME', AddUsersToAdHocRole2.role_name);
    wf_core.raise('WF_INVALID_ROLE');
  end if;

  if (role_users.COUNT > 0) then
    for userIND in role_users.FIRST..role_users.LAST loop
      if (role_users(userIND) is NOT NULL) then
        -- Validation
        -- 1379875: (Performance) added support for orig_system, orig_system_id
        -- composite name.
        -- Changed Validation and duplicate checking to limit selects against
        -- wf_users.
        -- Used a sub-block to use exception handling instead of single count
        -- into.


         begin
           colon := instr(role_users(userIND), ':');
           if (colon = 0) then
             --Bug 2465881
              --To eliminate error: Exact fetch returning more than
              --requested number of rows.
            SELECT  ORIG_SYSTEM, ORIG_SYSTEM_ID
            INTO    l_orig_system, l_orig_system_id
            FROM    WF_USERS
            WHERE   NAME = role_users(userIND)
            AND     partition_id <> 9
            AND     rownum < 2;
          else
            -- Bug 2465881
            SELECT ORIG_SYSTEM, ORIG_SYSTEM_ID
            INTO   l_orig_system, l_orig_system_id
            FROM   WF_USERS
            WHERE  ORIG_SYSTEM = substr(role_users(userIND), 1, colon-1)
            AND    ORIG_SYSTEM_ID = substr(role_users(userIND), colon+1)
            AND    rownum < 2;
          end if;
        exception
          when NO_DATA_FOUND then
            wf_core.token('USERNAME', role_users(userIND));
            wf_core.raise('WF_INVALID_USER');

          when others then
            wf_core.context('Wf_Directory', 'AddUsersToAdHocRole2', role_name);
            raise;
        end;

        -- Check Duplicate
        -- for local table, check user name and role name are sufficient
        -- there will not be index on orig system and orig system id
        -- orig systems and orig system ids are identical among the users
        -- from WF_LOCAL_ROLES.
        --

        -- <rwunderl:5218259>
        -- Commenting out this check and catching a dup user/role exception
        -- select count(1) into d1
        -- from WF_LOCAL_USER_ROLES
        -- where USER_NAME = role_users(userIND)
        -- and ROLE_NAME = AddUsersToAdHocRole2.role_name
        -- and ROLE_ORIG_SYSTEM = 'WF_LOCAL_ROLES'
        -- and ROLE_ORIG_SYSTEM_ID = 0;

        -- if (d1 > 0) then
        --   wf_core.token('USERNAME', role_users(userIND));
        --   wf_core.token('DISPNAME', '');
        --   wf_core.raise('WF_DUP_USER');
        -- end if;

        CreateUserRole(user_name=>role_users(userIND),
                       role_name=>AddUsersToAdHocRole2.role_name,
                       user_orig_system=>l_orig_system,
                       user_orig_system_id=>l_orig_system_id,
                       role_orig_system=>'WF_LOCAL_ROLES',
                       role_orig_system_id=>0,
                       start_date=>sysdate,
                       end_date=>to_date(NULL),
                       validateUserRole=>FALSE,
                       created_by=>WFA_SEC.user_id,
                       creation_date=>sysdate,
                       last_updated_by=>WFA_SEC.user_id,
                       last_update_date=>sysdate,
                       last_update_login=>WFA_SEC.login_id);

      end if;
    end loop;
  end if;

exception
  when others then
    wf_core.context('Wf_Directory', 'AddUsersToAdHocRole2',
        role_name);
    raise;
end AddUsersToAdHocRole2;


--
-- SetUserAttr (PRIVATE)
--   Update additional attributes for users
-- IN
--   user_name        - user name
--   orig_system      -
--   orig_system_id   -
--   display_name  -
--   notification_preference -
--   language      -
--   territory     -
--   email_address -
--   fax           -
--   expiration_date  - New expiration date
--   status           - status could be 'ACTIVE' or 'INACTIVE'
--   start_date -
--   OverWrite -
--   parent_orig_system -
--   parent_orig_system_id -
--   owner_tag -
--   last_updated_by -
--   last_update_date -
--   last_update_login -
-- OUT
--
procedure SetUserAttr(user_name               in  varchar2,
                      orig_system             in  varchar2,
                      orig_system_id          in  number,
                      display_name            in  varchar2,
                      description             in  varchar2,
                      notification_preference in  varchar2,
                      language                in  varchar2,
                      territory               in  varchar2,
                      email_address           in  varchar2,
                      fax                     in  varchar2,
                      expiration_date         in  date,
                      status                  in  varchar2,
                      start_date              in  date,
                      OverWrite               in  boolean,
                      Parent_Orig_System      in  varchar2,
                      Parent_orig_system_id   in  number,
                      owner_tag               in  varchar2,
                      last_updated_by         in  number,
                      last_update_date        in  date,
                      last_update_login       in  number,
                      created_by              in  number,
                      creation_date           in  date,
                      eventParams             in  wf_parameter_list_t,
                      source_lang             in  varchar2)
is

  l_expiration DATE;
  l_params WF_PARAMETER_LIST_T;
  l_oldStartDate DATE;
  l_oldEndDate   DATE;
  l_lastupddt DATE;
  l_creatdt   DATE;
  l_creatby   NUMBER;
  l_lastupdby NUMBER;
  l_lastupdlog NUMBER;
  l_partitionID NUMBER;
  l_partitionName VARCHAR2(30);
  l_overwrite varchar2(1) := 'Y';

begin
  --We first need to capture the current start/end date in case they are
  --changed.
  AssignPartition(SetUserAttr.orig_system, l_partitionID, l_partitionName);
  if not OverWrite then
    l_overwrite := 'N';
  end if;

  begin
    SELECT START_DATE, EXPIRATION_DATE
    INTO   l_oldStartDate, l_oldEndDate
    FROM   WF_LOCAL_ROLES
    WHERE  NAME = SetUserAttr.user_name
    AND    ORIG_SYSTEM = SetUserAttr.orig_system
    AND    ORIG_SYSTEM_ID = SetUserAttr.orig_system_id
    AND    PARTITION_ID = l_partitionID;
  exception
    when NO_DATA_FOUND then
      wf_core.token('USERNAME', user_name);
      wf_core.raise('WF_INVALID_USER');
  end;

    --
  -- Evaluate the WHO columns, and set default values if they are not passed

  l_creatdt := nvl(SetUserAttr.creation_date, SYSDATE);
  l_creatby := nvl(SetUserAttr.created_by, WFA_SEC.USER_ID);
  l_lastupddt := nvl(SetUserAttr.last_update_date, SYSDATE);
  l_lastupdby := nvl(SetUserAttr.last_updated_by, WFA_SEC.USER_ID);
  l_lastupdlog := nvl(SetUserAttr.last_update_login, WFA_SEC.LOGIN_ID);

  -- Update WF_LOCAL_ROLES where user_flag = 'Y'
  update WF_LOCAL_ROLES
     set NOTIFICATION_PREFERENCE = nvl(SetUserAttr.notification_preference,
                                       NOTIFICATION_PREFERENCE),
         LANGUAGE                = nvl(SetUserAttr.language, LANGUAGE),
         TERRITORY               = nvl(SetUserAttr.territory, TERRITORY),
         EMAIL_ADDRESS           = SetUserAttr.email_address,
         FAX                     = SetUserAttr.fax,
         --ER 16570228. Only update base table if SOURCE_LANG is 'US'
         DISPLAY_NAME            = decode(source_lang, 'US',
                                   nvl(SetUserAttr.display_name, DISPLAY_NAME), DISPLAY_NAME),
         DESCRIPTION             = decode(source_lang, 'US',
                                          SetUserAttr.description, DESCRIPTION),
         EXPIRATION_DATE         = SetUserAttr.expiration_date,
         STATUS                  = nvl(SetUserAttr.status, STATUS),
         START_DATE              = SetUserAttr.start_date,
         PARENT_ORIG_SYSTEM      = SetUserAttr.parent_orig_system,
         PARENT_ORIG_SYSTEM_ID   = SetUserAttr.parent_orig_system_id,
         OWNER_TAG               = SetUserAttr.owner_tag,
         -- <7298384> always keep CREATED_BY and CREATION_DATE in update
         LAST_UPDATED_BY         = decode(l_overwrite, 'Y', l_lastupdby, 'N', LAST_UPDATED_BY),

         LAST_UPDATE_DATE        = decode(l_overwrite, 'Y', l_lastupddt, 'N', LAST_UPDATE_DATE),
         LAST_UPDATE_LOGIN       = decode(l_overwrite, 'Y', l_lastupdlog, 'N', LAST_UPDATE_LOGIN)
   where NAME           = user_name
     and ORIG_SYSTEM    = SetUserAttr.orig_system
     and ORIG_SYSTEM_ID = SetUserAttr.orig_system_id
     and PARTITION_ID   = l_partitionID
     and USER_FLAG      = 'Y';
  --Update the _TL table in case the sourge_language is not ENGLISH, and
  --the originating system is MLS enabled.
  if source_lang <> 'US' and isMLSEnabled(SetUserAttr.orig_system)=TRUE then
     translate_role (p_name => SetUserAttr.user_name,
                     p_orig_system => SetUserAttr.orig_system,
                     p_orig_system_id => SetUserAttr.orig_system_id,
                     p_partition_id => l_partitionID,
                     P_display_name => SetUserAttr.display_name,
                     p_description => SetUserAttr.description,
                     p_source_lang => SetUserAttr.source_lang,
                     p_overwrite => l_overwrite,
                     p_owner_tag => SetUserAttr.owner_tag,
                     p_last_updated_by => l_lastupdby,
                     p_last_update_date => l_lastupddt,
                     p_last_update_login => l_lastupdlog);
                     --No need to pass CREATION_DATE or CREATED_BY as
                     --translate_role will assign the same value as CreateUser
  end if;

  --We were able to update the record, so we will raise the updated event
  --Build parameter list.
  WF_EVENT.AddParameterToList('USER_NAME', SetUserAttr.user_name, l_params);
  WF_EVENT.AddParameterToList('ORIG_SYSTEM', SetUserAttr.orig_system,
                              l_params);
  WF_EVENT.AddParameterToList('ORIG_SYSTEM_ID',
                              to_char(SetUserAttr.orig_system_id), l_params);
  WF_EVENT.AddParameterToList('DISPLAY_NAME', SetUserAttr.display_name,
                              l_params);
  WF_EVENT.AddParameterToList('DESCRIPTION', SetUserAttr.description,
                              l_params);
  WF_EVENT.AddParameterToList('NOTIFICATION_PREFERENCE',
                              SetUserAttr.notification_preference, l_params);
  WF_EVENT.AddParameterToList('LANGUAGE', SetUserAttr.language,  l_params);
  WF_EVENT.AddParameterToList('TERRITORY', SetUserAttr.territory, l_params);
  WF_EVENT.AddParameterToList('EMAIL_ADDRESS', SetUserAttr.email_address,
                              l_params);
  WF_EVENT.AddParameterToList('FAX', SetUserAttr.fax, l_params);
  WF_EVENT.AddParameterToList('EXPIRATION_DATE',
                              to_char(trunc(SetUserAttr.expiration_date),
                                      WF_CORE.Canonical_Date_Mask),
                              l_params);
  WF_EVENT.AddParameterToList('STATUS', SetUserAttr.status, l_params);
  WF_EVENT.AddParameterToList('START_DATE',
                              to_char(trunc(SetUserAttr.start_date),
                                      WF_CORE.Canonical_Date_Mask),
                                      l_params);
  if ((((l_oldStartDate is NOT NULL) and
       (SetUserAttr.start_date is NOT NULL)) and
       (trunc(l_oldStartDate) <> trunc(SetUserAttr.start_date))) or
      ((l_oldStartDate is NULL and SetUserAttr.start_date is NOT NULL) or
       (SetUserAttr.start_date is NULL and l_oldStartDate is NOT NULL))) then

    WF_EVENT.AddParameterToList('OLD_START_DATE',
                                to_char(trunc(l_oldStartDate),
                                        WF_CORE.Canonical_Date_Mask),
                                        l_params);
  else
    WF_EVENT.AddParameterToList('OLD_START_DATE', '*UNDEFINED*',
                                        l_params);
  end if;

  if ((((l_oldEndDate is NOT NULL) and
       (SetUserAttr.expiration_date is NOT NULL)) and
       (trunc(l_oldEndDate) <> trunc(SetUserAttr.expiration_date))) or
      ((l_oldEndDate is NULL and SetUserAttr.expiration_date is NOT NULL)
      or (SetUserAttr.expiration_date is NULL
        and l_oldEndDate is NOT NULL))) then

    WF_EVENT.AddParameterToList('OLD_END_DATE',
                                to_char(trunc(l_oldEndDate),
                                        WF_CORE.Canonical_Date_Mask),
                                l_params);
  else
    WF_EVENT.AddParameterToList('OLD_END_DATE', '*UNDEFINED*',
                                        l_params);
  end if;

    WF_EVENT.AddParameterToList('PARENT_ORIG_SYSTEM',
                                SetUserAttr.parent_orig_system, l_params);
    WF_EVENT.AddParameterToList('PARENT_ORIG_SYSTEM_ID',
                                to_char(SetUserAttr.parent_orig_system_id ,
                                WF_CORE.canonical_number_mask), l_params);
    WF_EVENT.AddParameterToList('OWNER_TAG', SetUserAttr.owner_tag, l_params);
    WF_EVENT.AddParameterToList('LAST_UPDATED_BY',
                                to_char(SetUserAttr.last_updated_by,
                                WF_CORE.canonical_number_mask), l_params);
    WF_EVENT.AddParameterToList('LAST_UPDATE_DATE',
                                to_char(SetUserAttr.last_update_date,
                                        WF_CORE.canonical_date_mask), l_params);
    WF_EVENT.AddParameterToList('LAST_UPDATE_LOGIN',
                                to_char(SetUserAttr.last_update_login ,
                                WF_CORE.canonical_number_mask), l_params);
    WF_EVENT.AddParameterToList('CREATED_BY', to_char(SetUserAttr.created_by ,
                                WF_CORE.canonical_number_mask), l_params);
    WF_EVENT.AddParameterToList('CREATION_DATE',
                                to_char(SetUserAttr.creation_date,
                                        WF_CORE.canonical_date_mask), l_params);
   if (eventParams is not null and eventParams.count>0) then
     for i in eventParams.first..eventParams.last loop
       WF_EVENT.AddParameterToList(upper(eventParams(i).getName()),
          eventParams(i).getValue(),l_params);
     end loop;
  end if;

    WF_EVENT.Raise(p_event_name=>'oracle.apps.fnd.wf.ds.user.updated',
                   p_event_key=>user_name, p_parameters=>l_params);

exception
  when others then
    wf_core.context('Wf_Directory', 'SetUserAttr', user_name, display_name);
    raise;
end SetUserAttr;

--
-- SetRoleAttr (PRIVATE)
--   Update additional attributes for roles
-- IN
--   role_name        - role name
--   orig_system      -
--   orig_system_id   -
--   display_name  -
--   notification_preference -
--   language      -
--   territory     -
--   email_address -
--   fax           -
--   expiration_date  - New expiration date
--   status           - status could be 'ACTIVE' or 'INACTIVE'
-- OUT
--
procedure SetRoleAttr(role_name               in  varchar2,
                      orig_system             in  varchar2,
                      orig_system_id          in  number,
                      display_name            in  varchar2,
                      description             in  varchar2,
                      notification_preference in  varchar2,
                      language                in  varchar2,
                      territory               in  varchar2,
                      email_address           in  varchar2,
                      fax                     in  varchar2,
                      expiration_date         in  date,
                      status                  in  varchar2,
                      start_date              in  date,
                      OverWrite               in  boolean,
                      Parent_Orig_System      in  varchar2,
                      Parent_Orig_System_ID   in  number,
                      owner_tag               in  varchar2,
                      last_updated_by         in  number,
                      last_update_date        in  date,
                      last_update_login       in  number,
                      created_by              in  number,
                      creation_date           in  date,
                      eventParams             in wf_parameter_list_t,
                      source_lang             in  varchar2)
is
  l_overwrite varchar2(1) := 'Y';
  l_expiration DATE;
  l_params WF_PARAMETER_LIST_T;
  l_oldStartDate DATE;
  l_oldEndDate   DATE;

  l_creatdt date;
  l_lastupddt date;
  l_creatby number;
  l_lastupdby number;
  l_lastupdlog number;
  l_partitionID number;
  l_partitionName varchar2(30);

begin
  if not OverWrite then
    l_overwrite := 'N';
  end if;
  --We first need to capture the current start/end date in case they are
  --changed.
   AssignPartition(SetRoleAttr.orig_system, l_partitionID, l_partitionName);

  begin
    SELECT START_DATE, EXPIRATION_DATE
    INTO   l_oldStartDate, l_oldEndDate
    FROM   WF_LOCAL_ROLES
    WHERE  NAME = SetRoleAttr.role_name
    AND    ORIG_SYSTEM = SetRoleAttr.orig_system
    AND    ORIG_SYSTEM_ID = SetRoleAttr.orig_system_id
    AND    PARTITION_ID   = l_partitionID;
  exception
    when NO_DATA_FOUND then
      WF_CORE.Token('ROLENAME', role_name);
      WF_CORE.Raise('WF_INVALID_ROLE');
  end;
  --


    -- Evaluating the WHO columns in case they are not passed
    l_creatdt   := nvl(SetRoleAttr.creation_date, SYSDATE);
    l_creatby   := nvl(SetRoleAttr.created_by, WFA_SEC.USER_ID);
    l_lastupdby := nvl(SetRoleAttr.last_updated_by, WFA_SEC.USER_ID);
    l_lastupddt := nvl(SetRoleAttr.last_update_date, SYSDATE);
    l_lastupdlog:= nvl(SetRoleAttr.last_update_login, WFA_SEC.LOGIN_ID);


  -- Update WF_LOCAL_ROLES
  --
  -- if (OverWrite) then
  --Update the description field and display name field
  --in the base table only if the session language is 'US'
  --Else update theses values for the _TL table and keep the
  --base table values same
  update WF_LOCAL_ROLES
  set    NOTIFICATION_PREFERENCE = nvl(SetRoleAttr.notification_preference,
                                       NOTIFICATION_PREFERENCE),
         LANGUAGE                = nvl(SetRoleAttr.language, LANGUAGE),
         TERRITORY               = nvl(SetRoleAttr.territory, TERRITORY),
         EMAIL_ADDRESS           = SetRoleAttr.email_address,
         FAX                     = SetRoleAttr.fax,
         --ER 16570228. Only update base table if SOURCE_LANG is 'US'
         DISPLAY_NAME            = decode(source_lang, 'US',
                                   nvl(SetRoleAttr.display_name, DISPLAY_NAME), DISPLAY_NAME),
         DESCRIPTION             = decode(source_lang, 'US',
                                          SetRoleAttr.description, DESCRIPTION),
         EXPIRATION_DATE         = SetRoleAttr.expiration_date,
         STATUS                  = nvl(SetRoleAttr.status, STATUS),
         START_DATE              = SetRoleAttr.start_date,
         PARENT_ORIG_SYSTEM      = SetRoleAttr.parent_orig_system,
         PARENT_ORIG_SYSTEM_ID   = SetRoleAttr.parent_orig_system_id,
         OWNER_TAG               = nvl(SetRoleAttr.owner_tag, OWNER_TAG),
         LAST_UPDATED_BY         = decode(l_overwrite, 'Y', l_lastupdby, 'N', LAST_UPDATED_BY),
         LAST_UPDATE_DATE        = decode(l_overwrite, 'Y', l_lastupddt, 'N', LAST_UPDATE_DATE),
         LAST_UPDATE_LOGIN       = decode(l_overwrite, 'Y', l_lastupdlog, 'N', LAST_UPDATE_LOGIN)
         -- <7298384> always keep CREATED_BY and CREATION_DATE - no update
  where  NAME           = role_name
    and  ORIG_SYSTEM    = SetRoleAttr.orig_system
    and  ORIG_SYSTEM_ID = SetRoleAttr.orig_system_id
    and PARTITION_ID   = l_partitionID;
  --Bug 3490260
  --lets keep the code here rather than end for better understanding
  --If the role information was not updated, we need to raise an
  --invalid role error so the caller can call the CreateRole api.
  if (sql%rowcount = 0) then
    WF_CORE.Token('ROLENAME', role_name);
    WF_CORE.Raise('WF_INVALID_ROLE');
  end if;
  --ER 16570228: Maintain the translated rows in the TL table.
  --Update the _TL table for the display_name and description
  if source_lang <> 'US' and isMLSEnabled(SetRoleAttr.orig_system)=TRUE then
    translate_role (p_name => role_name,
                    p_orig_system => SetRoleAttr.orig_system,
                    p_orig_system_id => SetRoleAttr.orig_system_id,
                    p_partition_id => l_partitionID,
                    P_display_name => nvl(SetRoleAttr.display_name, DISPLAY_NAME),
                    p_description => SetRoleAttr.description,
                    p_source_lang => SetRoleAttr.source_lang,
                    p_overwrite => l_overwrite,
                    p_owner_tag => nvl(SetRoleAttr.owner_tag, OWNER_TAG),
                    p_last_updated_by => l_lastupdby,
                    p_last_update_date => l_lastupddt,
                    p_last_update_login => l_lastupdlog);
  end if;
  --We were able to update the record, so we will raise the updated event
  --Build parameter list.
  WF_EVENT.AddParameterToList('ROLE_NAME', SetRoleAttr.role_name, l_params);
  WF_EVENT.AddParameterToList('ORIG_SYSTEM', SetRoleAttr.orig_system, l_params);
  WF_EVENT.AddParameterToList('ORIG_SYSTEM_ID',
                              to_char(SetRoleAttr.orig_system_id), l_params);
  WF_EVENT.AddParameterToList('DISPLAY_NAME', SetRoleAttr.display_name, l_params);
  WF_EVENT.AddParameterToList('DESCRIPTION', SetRoleAttr.description, l_params);
  WF_EVENT.AddParameterToList('NOTIFICATION_PREFERENCE',
                              SetRoleAttr.notification_preference, l_params);
  WF_EVENT.AddParameterToList('LANGUAGE', SetRoleAttr.language,  l_params);
  WF_EVENT.AddParameterToList('TERRITORY', SetRoleAttr.territory, l_params);
  WF_EVENT.AddParameterToList('EMAIL_ADDRESS', SetRoleAttr.email_address,
                              l_params);
  WF_EVENT.AddParameterToList('FAX', SetRoleAttr.fax, l_params);
  WF_EVENT.AddParameterToList('EXPIRATION_DATE',
                              to_char(trunc(SetRoleAttr.expiration_date),
                                      WF_CORE.Canonical_Date_Mask), l_params);
  WF_EVENT.AddParameterToList('STATUS', SetRoleAttr.status, l_params);
  WF_EVENT.AddParameterToList('START_DATE',
                              to_char(trunc(SetRoleAttr.start_date),
                                      WF_CORE.Canonical_Date_Mask), l_params);
  if ((((l_oldStartDate is NOT NULL) and
       (SetRoleAttr.start_date is NOT NULL)) and
       (trunc(l_oldStartDate) <> trunc(SetRoleAttr.start_date))) or
      ((l_oldStartDate is NULL and SetRoleAttr.start_date is NOT NULL) or
       (SetRoleAttr.start_date is NULL and l_oldStartDate is NOT NULL))) then

    WF_EVENT.AddParameterToList('OLD_START_DATE',
                                to_char(trunc(l_oldStartDate),
                                        WF_CORE.Canonical_Date_Mask),
                                        l_params);
  else
    WF_EVENT.AddParameterToList('OLD_START_DATE', '*UNDEFINED*', l_params);
  end if;

    if ((((l_oldEndDate is NOT NULL) and
         (SetRoleAttr.expiration_date is NOT NULL)) and
         (trunc(l_oldEndDate) <> trunc(SetRoleAttr.expiration_date))) or
        ((l_oldEndDate is NULL and SetRoleAttr.expiration_date is NOT NULL)
        or (SetRoleAttr.expiration_date is NULL
          and l_oldEndDate is NOT NULL))) then

      WF_EVENT.AddParameterToList('OLD_END_DATE',
                                  to_char(trunc(l_oldEndDate),
                                          WF_CORE.Canonical_Date_Mask),
                                  l_params);
    else
      WF_EVENT.AddParameterToList('OLD_END_DATE', '*UNDEFINED*',
                                  l_params);
    end if;

    WF_EVENT.AddParameterToList('PARENT_ORIG_SYSTEM',
                                SetRoleAttr.parent_orig_system, l_params);
    WF_EVENT.AddParameterToList('PARENT_ORIG_SYSTEM_ID',
                                to_char(SetRoleAttr.parent_orig_system_id ,
                                WF_CORE.canonical_number_mask),l_params);

    WF_EVENT.AddParameterToList('OWNER_TAG', SetRoleAttr.owner_tag, l_params);
    WF_EVENT.AddParameterToList('LAST_UPDATED_BY',
                                to_char(SetRoleAttr.last_updated_by ,
                                WF_CORE.canonical_number_mask), l_params);
    WF_EVENT.AddParameterToList('LAST_UPDATE_DATE',
                                to_char(SetRoleAttr.last_update_date,
                                        WF_CORE.canonical_date_mask), l_params);
    WF_EVENT.AddParameterToList('LAST_UPDATE_LOGIN',
                                to_char(SetRoleAttr.last_update_login ,
                                WF_CORE.canonical_number_mask), l_params);
   if (eventParams is not null and eventParams.count>0) then
     for i in eventParams.first..eventParams.last loop
       WF_EVENT.AddParameterToList(upper(eventParams(i).getName()),
          eventParams(i).getValue(),l_params);
     end loop;
   end if;
    WF_EVENT.Raise(p_event_name=>'oracle.apps.fnd.wf.ds.role.updated',
                   p_event_key=>role_name, p_parameters=>l_params);

exception
  when others then
    wf_core.context('Wf_Directory', 'SetRoleAttr', SetRoleAttr.role_name,
                    SetRoleAttr.display_name);
    raise;
end SetRoleAttr;

--
-- SetAdHocUserExpiration
--   Update expiration date for ad hoc users
-- IN
--   user_name        - Ad hoc user name
--   expiration_date  - New expiration date
-- OUT
--
procedure SetAdHocUserExpiration(user_name      in varchar2,
                      expiration_date           in date)
is
begin
  --
  -- Update Expiration Date
  --
  SetUserAttr(user_name=>SetAdHocUserExpiration.user_name,
              orig_system=>'WF_LOCAL_USERS',
              orig_system_id=>0,
              display_name=>NULL,
              notification_preference=>NULL,
              language=>NULL,
              territory=>NULL,
              email_address=>NULL,
              fax=>NULL,
              expiration_date=>SetAdHocUserExpiration.expiration_date,
              status=>NULL);

exception
  when others then
    wf_core.context('Wf_Directory', 'SetAdHocUserExpiration', user_name, expiration_date);
    raise;
end SetAdHocUserExpiration;

--
-- SetAdHocRoleExpiration
--   Update expiration date for ad hoc roles, user roles
-- IN
--   role_name        - Ad hoc role name
--   expiration_date  - New expiration date
-- OUT
--
procedure SetAdHocRoleExpiration(role_name      in varchar2,
                      expiration_date           in date)
is
begin
  --
  -- Update Expiration Date
  --
  SetRoleAttr(role_name=>SetAdHocRoleExpiration.role_name,
              orig_system=>'WF_LOCAL_ROLES',
              orig_system_id=>0,
              display_name=>NULL,
              notification_preference=>NULL,
              language=>NULL,
              territory=>NULL,
              email_address=>NULL,
              fax=>NULL,
              expiration_date=>SetAdHocRoleExpiration.expiration_date,
              status=>NULL);

exception
  when others then
    wf_core.context('Wf_Directory', 'SetAdHocRoleExpiration', role_name,
                    expiration_date);
    raise;
end SetAdHocRoleExpiration;

--
-- SetAdHocUserAttr
--   Update additional attributes for ad hoc users
-- IN
--   user_name        - Ad hoc user name
--   display_name  -
--   notification_preference -
--   language      -
--   territory     -
--   email_address -
--   fax           -
-- OUT
--
procedure SetAdHocUserAttr(user_name          in  varchar2,
                      display_name            in  varchar2,
                      notification_preference in  varchar2,
                      language                in  varchar2,
                      territory               in  varchar2,
                      email_address           in  varchar2,
                      fax                     in  varchar2,
                      parent_orig_system      in  varchar2,
                      parent_orig_system_id   in  number,
                      owner_tag               in  varchar2)
is
begin
  --
  -- Update the user.
  --
  SetUserAttr(user_name=>SetAdHocUserAttr.user_name,
              orig_system=>'WF_LOCAL_USERS',
              orig_system_id=>0,
              display_name=>SetAdHocUserAttr.display_name,
              notification_preference=>SetAdHocUserAttr.notification_preference,
              language=>SetAdHocUserAttr.language,
              territory=>SetAdHocUserAttr.territory,
              email_address=>SetAdHocUserAttr.email_address,
              fax=>SetAdHocUserAttr.fax,
              expiration_date=>NULL,
              status=>NULL,
              parent_orig_system=>SetAdHocUserAttr.parent_orig_system,
              parent_orig_system_id=>SetAdHocUserAttr.parent_orig_system_id,
              owner_tag=>SetAdhocUserAttr.owner_tag);

exception
  when others then
    wf_core.context('Wf_Directory', 'SetAdHocUserAttr', user_name,
                    display_name);
    raise;
end SetAdHocUserAttr;

--
-- SetAdHocRoleAttr
--   Update additional attributes for ad hoc roles, user roles
-- IN
--   role_name        - Ad hoc role name
--   display_name  -
--   notification_preference -
--   language      -
--   territory     -
--   email_address -
--   fax           -
-- OUT
--
procedure SetAdHocRoleAttr(role_name          in  varchar2,
                      display_name            in  varchar2,
                      notification_preference in  varchar2,
                      language                in  varchar2,
                      territory               in  varchar2,
                      email_address           in  varchar2,
                      fax                     in  varchar2,
                      parent_orig_system      in  varchar2,
                      parent_orig_system_id   in  number,
                      owner_tag               in  varchar2)
is
begin
  --
  -- Update the role
  --
  SetRoleAttr(role_name=>SetAdHocRoleAttr.role_name,
              orig_system=>'WF_LOCAL_ROLES',
              orig_system_id=>0,
              display_name=>SetAdHocRoleAttr.display_name,
              notification_preference=>SetAdHocRoleAttr.notification_preference,
              language=>SetAdHocRoleAttr.language,
              territory=>SetAdHocRoleAttr.territory,
              email_address=>SetAdHocRoleAttr.email_address,
              fax=>fax,
              expiration_date=>NULL,
              status=>NULL,
              parent_orig_system=>SetAdHocRoleAttr.parent_orig_system,
              parent_orig_system_id=>SetAdHocRoleAttr.parent_orig_system_id,
              owner_tag=>SetAdHocRoleAttr.owner_tag);

exception
  when others then
    wf_core.context('Wf_Directory', 'SetAdHocRoleAttr', role_name,
                    display_name);
    raise;
end SetAdHocRoleAttr;

--
-- RemoveUsersFromAdHocRole
--   Remove users from an existing ad hoc role
-- IN
--   role_name     -
--   role_users    -
-- OUT
--
procedure RemoveUsersFromAdHocRole(role_name in varchar2,
                      role_users             in varchar2)
is
  user varchar2(320);
  rest varchar2(2000);
  c1   pls_integer;
begin
  if (role_users is null) then
    -- Delete all users
    begin
      delete from WF_LOCAL_USER_ROLES UR
       where UR.ROLE_NAME = RemoveUsersFromAdHocRole.role_name
         and UR.ROLE_ORIG_SYSTEM = 'WF_LOCAL_ROLES'
         and UR.ROLE_ORIG_SYSTEM_ID = 0
         and UR.PARTITION_ID = 0;

   --delete from WF_USER_ROLE_ASSIGNMENTS as well
      delete from WF_USER_ROLE_ASSIGNMENTS URA
       where URA.ROLE_NAME = RemoveUsersFromAdHocRole.role_name
         and URA.ROLE_ORIG_SYSTEM = 'WF_LOCAL_ROLES'
         and URA.ROLE_ORIG_SYSTEM_ID = 0
         and URA.PARTITION_ID = 0;
    end;
  else
    --
    -- Delete Users
    --
    rest := ltrim(role_users);
    loop
      c1 := instr(rest, ',');
      if (c1 = 0) then
         c1 := instr(rest, ' ');
        if (c1 = 0) then
          user := rest;
        else
          user := substr(rest, 1, c1-1);
        end if;
      else
        user := substr(rest, 1, c1-1);
      end if;

      -- Delete
      delete from WF_LOCAL_USER_ROLES UR
       where UR.USER_NAME = user
         and UR.ROLE_NAME = RemoveUsersFromAdHocRole.role_name
         and UR.ROLE_ORIG_SYSTEM = 'WF_LOCAL_ROLES'
         and UR.ROLE_ORIG_SYSTEM_ID = 0
         and UR.PARTITION_ID = 0;
      if (sql%rowcount = 0) then
        wf_core.token('USERNAME', user);
        wf_core.raise('WF_INVALID_USER');
      end if;

      -- Delete from wf_user_role_Assignments as well
      delete from WF_USER_ROLE_ASSIGNMENTS URA
       where URA.USER_NAME = user
         and URA.ROLE_NAME = RemoveUsersFromAdHocRole.role_name
         and URA.ROLE_ORIG_SYSTEM = 'WF_LOCAL_ROLES'
         and URA.ROLE_ORIG_SYSTEM_ID = 0
         and URA.PARTITION_ID = 0;
      exit when (c1 = 0);

      rest := ltrim(substr(rest, c1+1));
    end loop;
  end if;

exception
  when others then
    wf_core.context('Wf_Directory', 'RemoveUsersFromAdHocRole',
        role_name, '"'||role_users||'"');
    raise;
end RemoveUsersFromAdHocRole;


--
-- ChangeLocalUserName
--  Change a User's Name in the WF_LOCAL_ROLES table.
-- IN
--  OldName
--  NewName
--  Propagate - call WF_MAINTENANCE.PropagateChangedName
-- OUT
--

function ChangeLocalUserName (OldName in varchar2,
                              NewName in varchar2,
                              Propagate in boolean)
return boolean

is
NumRows pls_integer;
l_oldname varchar2(320);
l_newname varchar2(320);

begin
  l_newname := substrb(NewName,1,320);
  l_oldname := substrb(OldName,1,320);

  NumRows := wfa_sec.DS_Count_Local_Role(l_oldname);

  if (NumRows = 1) then
    wfa_sec.DS_Update_Local_Role(l_oldname,l_newname);
    commit;

    if (Propagate) then
	WF_MAINTENANCE.PropagateChangedName(l_oldname, l_newname);
    end if;

    return TRUE;

  else

    return FALSE;

  end if;

exception
 when others then
 WF_CORE.Context('WF_DIRECTORY', 'ChangeLocalUserName', OldName, NewName);
 raise;

end ChangeLocalUserName;

--
-- ReassignUserRoles
--   Reassigns user/roles when the user information changes.
-- IN
--   p_user_name
--   p_old_user_origSystem
--   p_old_user_origSystemID
--   p_new_user_origSystem
--   p_new_user_origSystemID
--   p_last_update_date
--   p_last_updated_by
--   p_last_update_login
--
-- OUT
--
procedure ReassignUserRoles (p_user_name             in VARCHAR2,
                             p_old_user_origSystem   in VARCHAR2,
                             p_old_user_origSystemID in VARCHAR2,
                             p_new_user_origSystem   in VARCHAR2,
                             p_new_user_origSystemID in VARCHAR2,
                             p_last_update_date      in DATE,
                             p_last_updated_by       in NUMBER,
                             p_last_update_login     in NUMBER
                             -- <6817561>
                           , p_overWriteUserRoles in boolean
                           -- </6817561>
                             ) is

  l_overWriteUserRoles  varchar2(2) := 'N';
  l_api varchar2(250) := g_plsqlName ||'ReassignUserRoles';

BEGIN
  if(wf_log_pkg.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'BEGIN');
  end if;

  -- <6817561>
  if (p_overWriteUserRoles) then
    l_overWriteUserRoles := 'Y';
  end if; -- </6817561>
  --First Update the user self-reference.
  begin
    Update WF_USER_ROLE_ASSIGNMENTS
    Set    USER_ORIG_SYSTEM = p_new_user_origSystem,
           USER_ORIG_SYSTEM_ID = p_new_user_origSystemID,
           ROLE_ORIG_SYSTEM = p_new_user_origSystem,
           ROLE_ORIG_SYSTEM_ID = p_new_user_origSystemID,
           -- <6817561>
           LAST_UPDATE_DATE = decode(l_overWriteUserRoles,'Y', nvl(p_last_update_date, LAST_UPDATE_DATE), LAST_UPDATE_DATE),
           LAST_UPDATED_BY = decode(l_overWriteUserRoles,'Y', nvl(p_last_updated_by, LAST_UPDATED_BY), LAST_UPDATED_BY),
           LAST_UPDATE_LOGIN = decode(l_overWriteUserRoles,'Y', nvl(p_last_update_login, LAST_UPDATE_LOGIN), LAST_UPDATE_LOGIN)
         -- </6817561>
    Where  USER_ORIG_SYSTEM = p_old_user_origSystem
    And    USER_ORIG_SYSTEM_ID = p_old_user_origSystemID
    And    ROLE_ORIG_SYSTEM = p_old_user_origSystem
    And    ROLE_ORIG_SYSTEM_ID = p_old_user_origSystemID
    And    USER_NAME = p_user_name;
  exception
    when DUP_VAL_ON_INDEX then
      --This is an old reference that can be deleted
      Delete from WF_USER_ROLE_ASSIGNMENTS
      Where  USER_ORIG_SYSTEM = p_old_user_origSystem
      And    USER_ORIG_SYSTEM_ID = p_old_user_origSystemID
      And    ROLE_ORIG_SYSTEM = p_old_user_origSystem
      And    ROLE_ORIG_SYSTEM_ID = p_old_user_origSystemID
      And    USER_NAME = p_user_name;
  end;
  begin
    Update WF_LOCAL_USER_ROLES
    Set    USER_ORIG_SYSTEM = p_new_user_origSystem,
           USER_ORIG_SYSTEM_ID = p_new_user_origSystemID,
           ROLE_ORIG_SYSTEM = p_new_user_origSystem,
           ROLE_ORIG_SYSTEM_ID = p_new_user_origSystemID,
           -- <6817561>
           LAST_UPDATE_DATE = decode(l_overWriteUserRoles,'Y', nvl(p_last_update_date, LAST_UPDATE_DATE), LAST_UPDATE_DATE),
           LAST_UPDATED_BY = decode(l_overWriteUserRoles,'Y', nvl(p_last_updated_by, LAST_UPDATED_BY), LAST_UPDATED_BY),
           LAST_UPDATE_LOGIN = decode(l_overWriteUserRoles,'Y', nvl(p_last_update_login, LAST_UPDATE_LOGIN), LAST_UPDATE_LOGIN)
         -- </6817561>
    Where  USER_ORIG_SYSTEM = p_old_user_origSystem
    And    USER_ORIG_SYSTEM_ID = p_old_user_origSystemID
    And    ROLE_ORIG_SYSTEM = p_old_user_origSystem
    And    ROLE_ORIG_SYSTEM_ID = p_old_user_origSystemID
    And    USER_NAME = p_user_name;
  exception
    when DUP_VAL_ON_INDEX then
      --This is an old reference that can be deleted
      Delete from WF_LOCAL_USER_ROLES
      Where  USER_ORIG_SYSTEM = p_old_user_origSystem
      And    USER_ORIG_SYSTEM_ID = p_old_user_origSystemID
      And    ROLE_ORIG_SYSTEM = p_old_user_origSystem
      And    ROLE_ORIG_SYSTEM_ID = p_old_user_origSystemID
      And    USER_NAME = p_user_name;
  end;

  --Now update all other role references (self-reference is already updated so
  --it will not be effected by these updates)
  Update WF_LOCAL_USER_ROLES
  Set    USER_ORIG_SYSTEM = p_new_user_origSystem,
         USER_ORIG_SYSTEM_ID = p_new_user_origSystemID,
         -- <6817561>
         LAST_UPDATE_DATE = decode(l_overWriteUserRoles,'Y', nvl(p_last_update_date, LAST_UPDATE_DATE), LAST_UPDATE_DATE),
         LAST_UPDATED_BY = decode(l_overWriteUserRoles,'Y', nvl(p_last_updated_by, LAST_UPDATED_BY), LAST_UPDATED_BY),
         LAST_UPDATE_LOGIN = decode(l_overWriteUserRoles,'Y', nvl(p_last_update_login, LAST_UPDATE_LOGIN), LAST_UPDATE_LOGIN)
         -- </6817561>
  Where  USER_ORIG_SYSTEM = p_old_user_origSystem
  And    USER_ORIG_SYSTEM_ID = p_old_user_origSystemID
  And    USER_NAME = p_user_name;

 Update WF_USER_ROLE_ASSIGNMENTS
  Set    USER_ORIG_SYSTEM = p_new_user_origSystem,
         USER_ORIG_SYSTEM_ID = p_new_user_origSystemID,
         -- <6817561>
         LAST_UPDATE_DATE = decode(l_overWriteUserRoles,'Y', nvl(p_last_update_date, LAST_UPDATE_DATE), LAST_UPDATE_DATE),
         LAST_UPDATED_BY = decode(l_overWriteUserRoles,'Y', nvl(p_last_updated_by, LAST_UPDATED_BY), LAST_UPDATED_BY),
         LAST_UPDATE_LOGIN = decode(l_overWriteUserRoles,'Y', nvl(p_last_update_login, LAST_UPDATE_LOGIN), LAST_UPDATE_LOGIN)
         -- </6817561>
  Where  USER_ORIG_SYSTEM = p_old_user_origSystem
  And    USER_ORIG_SYSTEM_ID = p_old_user_origSystemID
  And    USER_NAME = p_user_name;

  if(wf_log_pkg.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'END');
  end if;
END ReassignUserRoles;


--
-- AssignPartition (PRIVATE)
--
-- IN
--  p_orig_system (VARCHAR2)
--
-- RETURNS
--  Partition ID (NUMBER)
--
-- COMMENTS
--  This api will check to see the partition for the p_orig_system exists.
--  if it does not exist, it will be added to p_table_name.  In either case
--  the Partition_ID will be returned for the calling api to properly populate
--  that column on insert/update.
--
procedure AssignPartition (p_orig_system   in  varchar2,
                           p_partitionID   out NOCOPY number,
                           p_partitionName out NOCOPY varchar2) is

begin
  begin
    --Check for existing partition.
      if ((g_origSystem <> UPPER(p_orig_system))) or (g_origSystem is NULL) then

      --Orig_systems such as FND_RESP have the application id concatenated
      --which makes the responsibilities for various applications fall under
      --different orig_systems.  However all responsibilities need to go into
      --the same partition, so we handle that here.  Any other systems that
      --we need to bulksynch who add to the orig system will need to be here
      --as well.
        if ((substr(UPPER(p_orig_system), 1, 8) = 'FND_RESP') and
            ((length(p_orig_system) = 8) or --In case we just get 'FND_RESP'
            (substr(p_orig_system, 9, 9) between '0' and '9'))) then
          g_origSystem := 'FND_RESP';

        else
          g_origSystem := UPPER(p_orig_system);

        end if;
        /* We will place PER in FND_USR */

        SELECT Partition_ID, orig_system
        INTO   g_partitionID, g_partitionName
        FROM   WF_DIRECTORY_PARTITIONS
        WHERE  ORIG_SYSTEM = DECODE(g_origSystem, 'PER', 'FND_USR',
                                    g_origSystem)
        AND    PARTITION_ID IS NOT NULL;

    end if;

  exception
    when NO_DATA_FOUND then
        --If the partition does not exist, we will put this into the
        --WF_LOCAL partition
        if (g_localPartitionID is NULL) then
          begin
            SELECT Partition_ID, orig_system
            INTO   g_localPartitionID, g_localPartitionName
            FROM   WF_DIRECTORY_PARTITIONS
            WHERE  ORIG_SYSTEM = 'WF_LOCAL_ROLES';

         exception
           when NO_DATA_FOUND then
             g_localPartitionID := 0;
             g_localPartitionName := 'WF_LOCAL_ROLES';

         end;
       end if;

       g_partitionID := g_localPartitionID;
       g_partitionName := g_localPartitionName;

  end;
  p_partitionID := g_partitionID;
  p_partitionName := g_partitionName;

exception
  when OTHERS then
    WF_CORE.Context('WF_DIRECTORY', 'AssignPartition', p_orig_system);
    raise;
end;

-- Bug 3090738
-- GetInfoFromMail
--
-- IN
--   email address
-- OUT
--   User attributes as in WF_ROLES view
--
-- This API queries wf_roles view for information of the user when
-- the e-mail address is given.
procedure GetInfoFromMail(mailid            in         varchar2,
                          role              out NOCOPY varchar2,
                          display_name      out NOCOPY varchar2,
                          description       out NOCOPY varchar2,
                          notification_preference out NOCOPY varchar2,
                          language          out NOCOPY varchar2,
                          territory         out NOCOPY varchar2,
                          fax               out NOCOPY varchar2,
                          expiration_date   out NOCOPY date,
                          status            out NOCOPY varchar2,
                          orig_system       out NOCOPY varchar2,
                          orig_system_id    out NOCOPY number)
is
  l_email    varchar2(2000);
  l_start    pls_integer;
  l_end      pls_integer;
begin
  -- strip off the unwanted info from email. Emails from the mailer
  -- could be of the form "Vijay Shanmugam"<vshanmug@oracle.com>
  l_start := instr(mailid, '<', 1, 1);
  if (l_start > 0) then
     l_end := instr(mailid, '>', l_start);
     l_email := substr(mailid, l_start+1, l_end-l_start-1);
  else
     l_email := mailid;
  end if;

  -- lets find any active user with this e-mail id if not we will
  -- check for inactive user
  begin
     select WR.NAME,
            WR.DISPLAY,
            WR.DESCRIPTION,
            WR.NOTIFICATION_PREFERENCE,
            WR.LANGUAGE,
            WR.TERRITORY,
            WR.FAX,
            WR.STATUS,
            WR.EXPIRATION_DATE,
            WR.ORIG_SYSTEM,
            WR.ORIG_SYSTEM_ID
     into   ROLE,
            DISPLAY_NAME,
            DESCRIPTION,
            NOTIFICATION_PREFERENCE,
            LANGUAGE,
            TERRITORY,
            FAX,
            STATUS,
            EXPIRATION_DATE,
            ORIG_SYSTEM,
            ORIG_SYSTEM_ID
       from (select R.NAME,
                    substrb(R.DISPLAY_NAME,1,360) DISPLAY,
                    substrb(R.DESCRIPTION,1,1000) DESCRIPTION,
                    R.NOTIFICATION_PREFERENCE,
                    R.LANGUAGE,
                    R.TERRITORY,
                    R.FAX,
                    R.STATUS,
                    R.EXPIRATION_DATE,
                    R.ORIG_SYSTEM,
                    R.ORIG_SYSTEM_ID,
                    decode (R.STATUS, 'ACTIVE', 1, 2) ACTIVE_ORDER,
                    decode (R.ORIG_SYSTEM, 'PER', 1, 'FND_USR', 2, 3) ORIG_SYS_ORDER
              from  WF_ROLES R
             where  UPPER(R.EMAIL_ADDRESS) = UPPER(l_email)
              order by ACTIVE_ORDER asc, ORIG_SYS_ORDER asc, START_DATE asc) WR
     where  ROWNUM < 2;
  exception
   when others then
      ROLE := '';
      DISPLAY_NAME := '';
      DESCRIPTION := '';
      NOTIFICATION_PREFERENCE := '';
      LANGUAGE := '';
      TERRITORY := '';
      FAX := '';
      STATUS := '';
      EXPIRATION_DATE := to_date(null);
      ORIG_SYSTEM := '';
      ORIG_SYSTEM_ID := to_number(null);
  end;
end GetInfoFromMail;

  /* (PRIVATE) - to be used by WF only
   *
   * Fetches role information when the e-mail address is given.
   * Added other parameters for full NLS support -phase 1-, bug 7578908
   *
   * In phase 1, we only use constant default values for NLS parameters
   * not currently stored in wf_local_roles table.
   */
  procedure GetInfoFromMail2( p_emailid in varchar2
                            , p_role out NOCOPY varchar2,
                              p_display_name out NOCOPY varchar2,
                              p_description out NOCOPY varchar2,
                              p_notification_preference out NOCOPY varchar2,
                              p_orig_system out NOCOPY varchar2,
                              p_orig_system_id out NOCOPY number,
                              p_fax out NOCOPY number,
                              p_expiration_date out nocopy date,
                              p_status out NOCOPY varchar2
                            , p_nlsLanguage out NOCOPY varchar2,
                              p_nlsTerritory out NOCOPY varchar2
                            , p_nlsDateFormat out NOCOPY varchar2
                            , p_nlsDateLanguage out NOCOPY varchar2
                            , p_nlsCalendar out NOCOPY varchar2
                            , p_nlsNumericCharacters out NOCOPY varchar2
                            , p_nlsSort out NOCOPY varchar2
                            , p_nlsCurrency out NOCOPY varchar2)
  is
    l_isComposite boolean;
    l_name varchar2(320);
    l_email_address varchar2(320);
    l_origSystem varchar2(30);
    l_origSystemID number;
    l_api varchar2(250) := g_plsqlName ||'GetInfoFromMail2';

  begin
    if(wf_log_pkg.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'BEGIN');
    end if;

    GetInfoFromMail(mailid =>  p_emailid,
                    role  => l_name,
                    display_name => p_display_name,
                    description => p_description,
                    notification_preference => p_notification_preference,
                    language => p_nlsLanguage,
                    territory => p_nlsTerritory,
                    fax => p_fax,
                    expiration_date => p_expiration_date,
                    status  => p_status,
                    orig_system  => p_orig_system,
                    orig_system_id => p_orig_system_id);

    if (l_name is not null) then
    -- got a unique entry, get NLS params from EBS profiles

      l_isComposite := CompositeName(p_role, l_origSystem, l_origSystemID);

      p_role:= l_name;
      wfa_sec.get_role_info3(l_isComposite,
                            l_name,
                            p_role,
                            p_display_name,
                            p_description,
                            l_email_address,
                            p_notification_preference,
                            p_orig_system,
                            p_orig_system_id,
                            p_fax,
                            p_STATUS,
                            p_EXPIRATION_DATE,
                            p_nlsLanguage,
                            p_nlsTerritory
                          , p_nlsDateFormat
                          , p_nlsDateLanguage
                          , p_nlsCalendar
                          , p_nlsNumericCharacters
                          , p_nlsSort
                          , p_nlsCurrency);

    else
      p_nlsDateFormat := '';
      p_nlsDateLanguage := '';
      p_nlsCalendar := '';
      p_nlsNumericCharacters := '';
      p_nlsSort := '';
      p_nlsCurrency := '';
    end if;

    if(wf_log_pkg.LEVEL_PROCEDURE >= fnd_log.g_current_runtime_level) then
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_api,'END');
    end if;
  end GetInfoFromMail2;

function IsMLSEnabled(p_orig_system  in   varchar2)
return boolean
is
mls_enabled   number;
l_origSys varchar2(30);
begin
  l_origSys := UPPER(p_orig_system);
  if ((substr(l_origSys, 1, 8) = 'FND_RESP') and
      ((length(l_origSys) = 8) or --In case we just get 'FND_RESP'
       (substr(l_origSys, 9, 9) between '0' and '9'))) then
    l_origSys := 'FND_RESP';

  end if;

  --We can use the global variable set in wf_local.syncroles
  --but for standalone so as not to introduce dependency on WF_LOCAL
  --package we query from wf_directory_partitions directly.
  select  count(1)
  into    mls_enabled
  from    wf_directory_partitions
  where   orig_system = l_origSys
  and     ROLE_TL_VIEW is not NULL ;
  if (mls_enabled = 1) then
     return TRUE;
  end if;
  --else case return false
  return FALSE;
end IsMLSEnabled;

-- Change_Name_References_RF (PRIVATE)
--
-- IN
--  p_sub_guid (RAW)
--  p_event    (WF_EVENT_T)
--
-- RETURNS
--  varchar2
--
-- COMMENTS
--  This api is a rule function to be called by BES.  It is primarily used for
--  a user name change to update all the fk references.  The subscription is
--  set as deferred to offline the updates to return control back to the user
--  more quickly.
--
function Change_Name_References_RF( p_sub_guid  in            RAW,
                                    p_event     in out NOCOPY WF_EVENT_T )
                          return VARCHAR2 is
    l_newName        VARCHAR2(360);
    l_oldName        VARCHAR2(360);

  begin
    l_newName := p_event.getValueForParameter('USER_NAME');
    l_oldName := p_event.getValueForParameter('OLD_USER_NAME');

   /* --Update the user/roles
    UPDATE  WF_LOCAL_USER_ROLES
    SET     USER_NAME = l_newName
    WHERE   USER_NAME = l_oldName;

    --Update the user/role assignments
    UPDATE  WF_USER_ROLE_ASSIGNMENTS
    SET     USER_NAME = l_newName
    WHERE   USER_NAME = l_oldName;*/ --these updates are now made inline

    --Call WF_MAINTENANCE to update all the other fk references.
    WF_MAINTENANCE.PropagateChangedName(OLDNAME=>l_oldName, NEWNAME=>l_newName);
    return 'SUCCESS';
exception
  when OTHERS then
    return 'ERROR';

end Change_Name_References_RF;

--
-- DeleteRole
-- IN
-- p_name (VARCHAR2)
-- p_OrigSystem (VARCHAR2)
-- p_OrigSystemID (NUMBER)
--
--
-- COMMENTS
-- This API is to be used to remove a specified end-dated role or user with
-- its references from the WFDS Tables.
--
procedure DeleteRole ( p_name in varchar2,
                       p_origSystem in varchar2,
                       p_origSystemID in number)
is

 TYPE numTab is table of number index by binary_integer;

 l_count pls_integer;
 l_flag  char(1);
 l_partitionID number;
 l_partitionName varchar2(30);
 l_relIDTAB numTab;
begin
  AssignPartition (p_origSystem,l_partitionID,l_partitionName);
  begin
  --check whether the role name is truly end dated

  select 1 into l_count
  from SYS.DUAL
  where exists (select null from wf_roles
                where name=p_name
                );

  --if we have reached here, it implies that the user or role
  -- is not truly end dated.
  -- raise error

   if(wf_log_pkg.level_exception >= fnd_log.g_current_runtime_level) then
    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_EXCEPTION,
    'WF_DIRECTORY.deleteRole',
    'Role is still active. Make sure it is end dated ');
   end if;
   WF_CORE.Context('WF_DIRECTORY', 'deleteRole', p_name);
   WF_CORE.Token('ROLE',p_name);
   WF_CORE.Raise('WFDS_ROLE_ACTIVE');
  exception
   when no_data_found then

    delete from wf_local_roles
    where name=p_name
    and orig_system=p_origSystem
    and orig_system_id=p_origSystemId
    and partition_id =l_partitionID
    returning  user_flag into l_flag;

--   once the role has been successfully removed, remove the assignments as well
   if l_flag ='Y' then
    --a user has been removed so call deleteUserRoles to remove all user/role
    -- associations for the user.
    DeleteUserRole(p_username=>p_name,
                   p_userorigSystem=>p_origSystem,
                   p_userorigSystemID=>p_origSystemID);
   else
   -- a role has been removed so call deleteUserRoles to remove all user/role
   -- associations for the role.
   -- also call wf_role_hierarchy.removeRelaionship to delete all hierarchical
   -- relationships in which the role participates.
   begin
    select relationship_id bulk collect into l_relIDTab
     from wf_role_hierarchies where sub_name=p_name
    or super_name = p_name;
    if (l_relIDTAB.count>0) then
     for i in l_relIDTAB.first..l_RelIDTAB.last loop
     WF_ROLE_HIERARCHY.RemoveRelationship(l_relIDTab(i),TRUE);
     end loop;
    end if;
   exception
     when no_data_found then
      null;
   end;

    DeleteUserRole(p_rolename=>p_name,
                   p_roleorigSystem=>p_origSystem,
                   p_roleorigSystemID=>p_origSystemID);
   end if;
  end;


exception
    when others then
    WF_CORE.Context('WF_DIRECTORY', 'deleteRole', p_name);
    raise;
end;


--
-- DeleteUserRole
--
-- IN
-- p_username (VARCHAR2)
-- p_rolename (VARCHAR2)
-- p_userOrigSystem (VARCHAR2)
-- p_userOrigSystemID (NUMBER)
-- p_roleOrigSystem (VARCHAR2)
-- p_roleOrigSystemID (NUMBER)
--
-- COMMENTS
-- This API is to be used to remove a specified end-dated user/role
-- assignment along with its references from the WFDS Tables.
--
procedure DeleteUserRole ( p_username in varchar2,
                           p_rolename in varchar2,
                           p_userOrigSystem in varchar2,
                           p_userOrigSystemID in number,
			   p_roleOrigSystem in varchar2,
		           p_roleOrigSystemID in number)
is

 l_count pls_integer;
 l_partitionID number;
 l_partitionName varchar2(30);
begin

  --check whether both the inbound parameters are null
  -- or the orig sys information is not provided

  if (((p_username is null) and (p_rolename is null))
  or(p_username is not null and (p_userOrigSystem is null
    or p_userOrigSystemID is null))
  or(p_rolename is not null and (p_roleOrigSystem is null
    or p_roleOrigSystemID is null))) then

   --raise error
    WF_CORE.Context('WF_DIRECTORY', 'DeleteUserRole', p_username,p_rolename);
    WF_CORE.Raise('WFSQL_ARGS');

  elsif p_username is null then -- role has been passed
  begin

       AssignPartition(p_roleorigSystem,l_partitionID, l_partitionName);

      -- check whether the role is end-dated

        select 1 into l_count
        from SYS.DUAL
        where exists (select null from wf_local_roles
                where name=p_rolename)
          and ( exists (select null from wf_user_roles
                where role_name=p_rolename
              )
          or exists (select null from wf_user_role_assignments_v
                where role_name=p_rolename
             )
          or exists (select null from wf_role_hierarchies
                where (super_name=p_rolename
                or sub_name=p_rolename)
                and enabled_flag='Y'
          ));

         --if we have reached here, it implies that the role
         -- is not truly end dated.
         -- raise error

        if(wf_log_pkg.level_exception >=
         fnd_log.g_current_runtime_level) then
        WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_EXCEPTION,
        'WF_DIRECTORY.DeleteUserRole',
         'User/Role assignment is still active. Make sure it is end dated ' ||
        'and removed from any hierarchies');
        end if;
        WF_CORE.Context('WF_DIRECTORY', 'DeleteUserRole', p_rolename);
        WF_CORE.Token('ROLE',p_rolename);
        WF_CORE.Raise('WFDS_USER_ROLE_ACTIVE');
  exception
   when no_data_found then
   -- assignment is truly end dated

        delete from wf_user_role_assignments
        where role_name=p_rolename;

        delete from wf_local_user_roles
        where role_name=p_rolename
        and role_orig_system=p_roleorigSystem
        and role_orig_system_id=p_roleorigSystemID
        and partition_id = l_partitionID;


  end;
  elsif p_rolename is null then --user has been passed
  begin
        --check whether user is truly end dated
        select 1 into l_count
        from SYS.DUAL
        where exists (select null from wf_local_roles
                where name=p_username)
          and ( exists (select null from wf_user_roles
                where user_name=p_username
              )
          or exists (select null from wf_user_role_assignments_v
                where user_name=p_username
        ));

         --if we have reached here, it implies that the user
         -- is not truly end dated.
         -- raise error

        if(wf_log_pkg.level_exception >=
         fnd_log.g_current_runtime_level) then
        WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_EXCEPTION,
        'WF_DIRECTORY.DeleteUserRole',
         'User/Role assignment is still active. Make sure it is end dated ' ||
        'and removed from any hierarchies');
        end if;
        WF_CORE.Context('WF_DIRECTORY', 'DeleteUserRole', p_username);
        WF_CORE.Token('ROLE',p_username);
        WF_CORE.Raise('WFDS_USER_ROLE_ACTIVE');
  exception
   when no_data_found then
   -- assignment is truly end dated

        delete from wf_user_role_assignments
        where user_name=p_username;

        delete from wf_local_user_roles
        where user_name=p_username
        and user_orig_system=p_userorigSystem
        and user_orig_system_id=p_userorigSystemID;

  end;
  else --both role and user have been passed
  begin
       AssignPartition(p_roleorigSystem,l_partitionID, l_partitionName);

        --check whether user/role is truly end dated

        select 1 into l_count
        from SYS.DUAL
        where exists (select null from wf_local_roles
                where name=p_rolename or name=p_username)
          and ( exists (select null from wf_user_roles
                where role_name=p_rolename
                and user_name=p_username
              )
          or exists (select null from wf_user_role_assignments_v
                where role_name=p_rolename
                and user_name=p_username
             )
          or exists (select null from wf_role_hierarchies
                where (super_name=p_rolename
                or sub_name=p_rolename)
                and enabled_flag='Y'
          ));

        --if we have reached here, it implies that the user/role
        -- is not truly end dated.
        -- raise error

        if(wf_log_pkg.level_exception >=
         fnd_log.g_current_runtime_level) then
        WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_EXCEPTION,
        'WF_DIRECTORY.DeleteUserRole',
         'User/Role assignment is still active. Make sure it is end dated ' ||
        'and removed from any hierarchies');
        end if;
        WF_CORE.Context('WF_DIRECTORY', 'DeleteUserRole', p_username,p_rolename);
        WF_CORE.Token('ROLE',p_rolename);
        WF_CORE.Token('USER',p_username);
        WF_CORE.Raise('WFDS_ASSIGNMENT_ACTIVE');
  exception
   when no_data_found then
   -- assignment is truly end dated

        delete from wf_user_role_assignments
        where role_name=p_rolename
        and user_name=p_username;

        delete from wf_local_user_roles
        where role_name=p_rolename
        and user_name=p_username
        and role_orig_system=p_roleorigSystem
        and role_orig_system_id=p_roleorigSystemID
        and user_orig_system=p_userOrigSystem
        and user_orig_system_id=p_userOrigSystemID
        and partition_id  = l_partitionID;
  end;
  end if;
exception
    when others then
    WF_CORE.Context('WF_DIRECTORY', 'DeleteUserRole', p_username,p_rolename);
    raise;
end;

procedure add_language is
begin
  insert into WF_LOCAL_ROLES_TL (NAME,
                                 DISPLAY_NAME,
                                 DESCRIPTION,
                                 ORIG_SYSTEM,
                                 ORIG_SYSTEM_ID,
                                 PARTITION_ID,
                                 LANGUAGE,
                                 OWNER_TAG,
                                 CREATED_BY,
                                 CREATION_DATE,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATED_BY,
                                 LAST_UPDATE_LOGIN)
    select B.NAME,
             B.DISPLAY_NAME,
             B.DESCRIPTION,
             B.ORIG_SYSTEM,
             B.ORIG_SYSTEM_ID,
             B.PARTITION_ID,
             L.LANGUAGE_CODE,
             B.OWNER_TAG,
             B.CREATED_BY,
             B.CREATION_DATE,
             B.LAST_UPDATE_DATE,
             B.LAST_UPDATED_BY,
             B.LAST_UPDATE_LOGIN
    from WF_LOCAL_ROLES B, FND_LANGUAGES L, WF_DIRECTORY_PARTITIONS WFP
    where L.INSTALLED_FLAG in ('I', 'B')
      and L.LANGUAGE_CODE<>'US'
      and L.LANGUAGE_CODE=userenv('LANG')
      --<MLS enabled orig systems>
      --Similar to what WF_DIRECTORY.IsMLSEnabled does as we only want
      --to translate MLS-enabled originating systems, not all of them
      and B.PARTITION_ID=WFP.PARTITION_ID
      and WFP.ROLE_TL_VIEW is not NULL
      --</MLS enabled orig systems>
      and not exists (select NULL
                     from  WF_LOCAL_ROLES_TL TL
                     where B.NAME           = TL.NAME and
                           B.ORIG_SYSTEM    = TL.ORIG_SYSTEM and
                           B.ORIG_SYSTEM_ID = TL.ORIG_SYSTEM_ID and
                           B.PARTITION_ID   = TL.PARTITION_ID and
                           TL.LANGUAGE      = L.LANGUAGE_CODE);
end add_language;

end Wf_Directory;

/

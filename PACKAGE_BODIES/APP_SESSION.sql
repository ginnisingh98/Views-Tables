--------------------------------------------------------
--  DDL for Package Body APP_SESSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."APP_SESSION" as
/* $Header: AFSCSESB.pls 120.3 2006/05/17 00:49:23 gashford noship $ */

--
-- Initialize
--   Initialize session in apps schema
--
procedure Initialize
is
  l_apps_sname varchar2(30);
begin
  -- Get the apps schema name

  select oracle_username
  into l_apps_sname
  from fnd_oracle_userid
  where oracle_id = 900;

  -- Set the session schema

  execute immediate 'alter session set current_schema = ' ||l_apps_sname;
end Initialize;

--
-- Get_Icx_Cookie_Name
--   Get the name of the cookie containing the icx_session_id
-- RETURNS
--   Cookie Name
--
function Get_Icx_Cookie_Name return varchar2
is
begin
  return (fnd_session_management.getSessionCookieName);
end Get_Icx_Cookie_Name;

--
-- Create_Icx_Session
--   Create or re-establish an ICX session for the identified user.
-- IN
--   p_sso_guid - the user's SSO guid (required)
--   p_old_icx_cookie_value - the user's previous cookie value, if
--     trying to re-establish an existing session (optional)
--   p_resp_appl_short_name - the application short name of the responsibility
--   p_responsibility_key - the responsibility key
--   p_security_group_key - the security group key
-- OUT
--   p_icx_cookie_value - the new ICX session cookie value
-- RAISES
--   SSO_USER_UNKNOWN - if there is no user corresponding to the SSO guid
--   SESSION_CREATION_FAILED - if a session could not be created
--   SECURITY_CONTEXT_INVALID - if the user, responsibility application
--     short name, responsibility, and security group do not form a valid
--     security context
--
procedure Create_Icx_Session(
  p_sso_guid             in         varchar2,
  p_old_icx_cookie_value in         varchar2 default null,
  p_resp_appl_short_name in         varchar2 default null,
  p_responsibility_key   in         varchar2 default null,
  p_security_group_key   in         varchar2 default null,
  p_icx_cookie_value     out nocopy varchar2)
is
  l_session_id    number;           -- session id from cookie
  l_user_guid     varchar2(32);     -- guid of current session user
  l_user_record   Apps_User_Type;
  l_session_valid boolean := false; -- flag if current session is still valid

  l_user_id           number := null;
  l_resp_appl_id      number;
  l_responsibility_id number;
  l_security_group_id number;
  l_status            varchar2(30);

begin
  if(p_resp_appl_short_name is not null or
     p_responsibility_key is not null or
     p_security_group_key is not null) then

    -- get the application_id, responsibility_id, and security_group_id

    begin
      select application_id
        into l_resp_appl_id
        from fnd_application
       where application_short_name = p_resp_appl_short_name;

      select responsibility_id
        into l_responsibility_id
        from fnd_responsibility
       where application_id = l_resp_appl_id
         and responsibility_key = p_responsibility_key;

      select security_group_id
        into l_security_group_id
        from fnd_security_groups
       where security_group_key = p_security_group_key;
    exception
      when no_data_found then
        raise SECURITY_CONTEXT_INVALID;
    end;
  end if;

  if (p_old_icx_cookie_value is not null) then
    -- try to re-establish the existing session
    -- check that the session is still valid and that the users match

    l_session_id := -1;

    begin
      -- turn the cookie into a session id

      l_session_id := fnd_session_utilities.XSID_to_SessionID(
        p_old_icx_cookie_value);
    exception
      when others then
        null;
    end;

    if(l_session_id <> -1) then
      -- get the user guid and user id for the session

      begin
        select fu.user_guid,
               fu.user_id
          into l_user_guid,
               l_user_id
          from icx_sessions ses,
               fnd_user fu
         where ses.user_id = fu.user_id
           and ses.session_id = l_session_id;

        if(l_user_guid = p_sso_guid) then
          -- the session user matches the SSO guid

          if(l_responsibility_id is not null) then
            -- validate the security context

            fnd_user_resp_groups_api.validate_security_context(
              p_user_id           => l_user_id,
              p_resp_appl_id      => l_resp_appl_id,
              p_responsibility_id => l_responsibility_id,
              p_security_group_id => l_security_group_id,
              x_status            => l_status);

            if(l_status <> 'Y') then
              raise SECURITY_CONTEXT_INVALID;
            end if;
          end if;

          -- check session status

          l_status := fnd_session_management.check_session(l_session_id);

          if (l_status = 'VALID') then
            -- copy the old cookie value to the new so that
            -- the cookie value is retained

            p_icx_cookie_value := p_old_icx_cookie_value;

            l_session_valid := true;
          elsif (l_status = 'EXPIRED') then
            -- reset the existing session

            fnd_session_management.reset_session(l_session_id);

            -- copy the old cookie value to the new so that
            -- the cookie value is retained

            p_icx_cookie_value := p_old_icx_cookie_value;

            l_session_valid := true;
          elsif (l_status = 'INVALID') then
            -- do nothing; a new session will be created

            null;
          elsif (l_status = 'ERROR') then
            -- do nothing; a new session will be created

            null;
          else
            -- do nothing; a new session will be created

            null;
          end if;
        end if;
      exception
        when no_data_found then
          -- session no longer exists, can't reactivate

          null;
      end;
    end if;
  end if;

  if(not l_session_valid) then
    -- old session not given or unable to reactivate it
    -- create a new session

    -- get the default user_id for this SSO user
    l_user_record := App_Session.Get_Default_User(p_sso_guid);
    l_user_id := l_user_record.user_id;

    if(l_responsibility_id is not null) then
      -- validate the security context

      fnd_user_resp_groups_api.validate_security_context(
        p_user_id           => l_user_id,
        p_resp_appl_id      => l_resp_appl_id,
        p_responsibility_id => l_responsibility_id,
        p_security_group_id => l_security_group_id,
        x_status            => l_status);

      if(l_status <> 'Y') then
        raise SECURITY_CONTEXT_INVALID;
      end if;
    end if;

    -- create a new session for the user

    l_session_id := fnd_session_management.createSession(l_user_id);

    if(l_session_id = -1) then
      raise SESSION_CREATION_FAILED;
    end if;

    -- turn the session id into a cookie value

    p_icx_cookie_value := fnd_session_utilities.sessionID_to_XSID(l_session_id);
  end if;

  if(l_responsibility_id is not null) then
    -- ICX initialization

    fnd_session_management.initializeSSWAGlobals(
      p_session_id        => l_session_id,
      p_resp_appl_id      => l_resp_appl_id,
      p_responsibility_id => l_responsibility_id,
      p_security_group_id => l_security_group_id);

    -- FND initialization

    fnd_session_management.setSessionPrivate(
      p_user_id            => l_user_id,
      p_responsibility_id  => l_responsibility_id,
      p_resp_appl_id       => l_resp_appl_id,
      p_security_group_id  => l_security_group_id,
      p_date_format        => fnd_session_management.g_date_format,
      p_language           => fnd_session_management.g_language,
      p_date_language      => fnd_session_management.g_date_language,
      p_numeric_characters => fnd_session_management.g_numeric_characters,
      p_nls_sort           => fnd_session_management.g_nls_sort,
      p_nls_territory      => fnd_session_management.g_nls_territory);
  end if;
end Create_Icx_Session;

--
-- Validate_Icx_Session
--   Validates an ICX session
-- IN
--   p_icx_cookie_value - the ICX session cookie value
-- RETURNS
--   Nothing.  No exception means session is valid.
-- RAISES
--   SESSION_DOES_NOT_EXIST
--   SESSION_NOT_VALID
--   SESSION_EXPIRED
--
procedure Validate_Icx_Session(
  p_icx_cookie_value in varchar2)
is
  l_ses_status varchar2(30);  -- Session status code
begin
  -- Check session status

  declare
    l_session_id             number;
    l_transaction_id         number;
    l_user_id                number;
    l_responsibility_id      number;
    l_resp_appl_id           number;
    l_security_group_id      number;
    l_language_code          varchar2(30);
    l_nls_language           varchar2(30);
    l_date_format_mask       varchar2(80);
    l_nls_date_language      varchar2(30);
    l_nls_numeric_characters varchar2(30);
    l_nls_sort               varchar2(30);
    l_nls_territory          varchar2(30);
  begin
    l_ses_status := fnd_session_management.validateSessionPrivate(
      c_XSID                 => p_icx_cookie_value,
      session_id             => l_session_id,
      transaction_id         => l_transaction_id,
      user_id                => l_user_id,
      responsibility_id      => l_responsibility_id,
      resp_appl_id           => l_resp_appl_id,
      security_group_id      => l_security_group_id,
      language_code          => l_language_code,
      nls_language           => l_nls_language,
      date_format_mask       => l_date_format_mask,
      nls_date_language      => l_nls_date_language,
      nls_numeric_characters => l_nls_numeric_characters,
      nls_sort               => l_nls_sort,
      nls_territory          => l_nls_territory);
  exception
    when others then
      raise SESSION_DOES_NOT_EXIST;
  end;

  if (l_ses_status = 'VALID') then
    return;
  elsif (l_ses_status = 'EXPIRED') then
    raise SESSION_EXPIRED;
  elsif (l_ses_status = 'INVALID') then
    raise SESSION_NOT_VALID;
  elsif (l_ses_status = 'ERROR') then
    raise SESSION_NOT_VALID;
  else
    raise SESSION_NOT_VALID;
  end if;
end Validate_Icx_Session;

--
-- Get_All_Linked_Users
--   Return a list of all FND users linked to an SSO guid
-- IN
--   p_sso_guid - the user's SSO guid (required)
-- RETURNS
--   An array of users linked to this guid
-- RAISES
--   SSO_USER_UNKNOWN - if no users are linked to this GUID
--
function Get_All_Linked_Users(
  p_sso_guid in varchar2)
return Apps_User_Table
is
  l_user_list Apps_User_Table;
  found boolean := FALSE;

  -- Fetch users linked to guid
  -- Default 'N' as a placeholder for default_user flag in the fetch.
  -- Default_user needs to be calculated using preferences.
  cursor guid_users(l_sso_guid in varchar2) is
    select fu.user_id, fu.user_name, 'N'
    from fnd_user fu
    where fu.user_guid = l_sso_guid
    order by user_id;

begin
  -- Fetch all users linked to guid
  open guid_users (p_sso_guid);
  fetch guid_users bulk collect into l_user_list;
  close guid_users;

  -- Check for no linked rows and raise error
  if (l_user_list.FIRST is null or l_user_list.FIRST <> 1) then
    raise SSO_USER_UNKNOWN;
  end if;

  -- Calculate default_user flag
  -- Check for a preference
  for i in l_user_list.FIRST .. l_user_list.LAST loop
    if (upper(substr(fnd_preference.get(l_user_list(i).user_name, 'APPS_SSO',
                           'DEFAULT_USER'),1,1)) = 'Y') then
      l_user_list(i).default_user := 'Y';
      found := TRUE;
      exit;
    end if;
  end loop;

  -- If no user has a preference, the use the
  -- first user found as the "default default".
  if (not found) then
    l_user_list(l_user_list.FIRST).default_user := 'Y';
  end if;

  return l_user_list;
end Get_All_Linked_Users;

--
-- Get_Default_User
--   Get the default FND user linked to an SSO guid
-- IN
--   p_sso_guid - the user's SSO guid (required)
-- RETURNS
--   A record for default user linked to this guid
-- RAISES
--   SSO_USER_UNKNOWN - if no users are linked to this GUID
--
function Get_Default_User(
  p_sso_guid in varchar2)
return Apps_User_Type
is
  l_user_list Apps_User_Table;
begin
  -- Get all users
  l_user_list := Get_All_Linked_Users(p_sso_guid);

  -- Find the default and return it
  for i in l_user_list.FIRST .. l_user_list.LAST loop
    if (l_user_list(i).default_user = 'Y') then
      return (l_user_list(i));
    end if;
  end loop;

  -- Should never happen, but just in case...
  return l_user_list(l_user_list.FIRST);
end Get_Default_User;

end APP_SESSION;

/

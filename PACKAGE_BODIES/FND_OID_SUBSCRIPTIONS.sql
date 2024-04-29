--------------------------------------------------------
--  DDL for Package Body FND_OID_SUBSCRIPTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OID_SUBSCRIPTIONS" as
/* $Header: AFSCOSBB.pls 120.19.12010000.9 2015/08/17 20:11:40 ctilley ship $ */
--
/*****************************************************************************/
-- Start of Package Globals

 G_MODULE_SOURCE constant  varchar2(80) :=
    'fnd.plsql.oid.fnd_oid_subscriptions.';

-- End of Package Globals
--
-------------------------------------------------------------------------------
-- Start of Private Program Units
/*
** Name      : fnd_create_update
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
procedure fnd_create_update(
    p_event_type           in  varchar2
  , p_user_name             in fnd_user.user_name%type
  , p_owner                 in varchar2
  , p_unencrypted_password  in varchar2
  , p_description           in fnd_user.description%type
  , p_email_address         in fnd_user.email_address%type
  , p_fax                   in fnd_user.fax%type
  , p_start_date            in varchar2
  , p_end_date              in varchar2
  , p_isenabled             in varchar2
  , p_user_guid             in fnd_user.user_guid%type
  , x_user_id               out nocopy fnd_user.user_id%type
) is
  l_module_source varchar2(256);
  l_apps_username_key fnd_oid_util.apps_user_key_type;
  l_apps_userguid_key fnd_oid_util.apps_user_key_type;
  l_user_name     fnd_user.user_name%type;
  l_found         boolean;
  l_allow_sync    varchar2(1);
  l_user_profiles fnd_oid_util.apps_sso_user_profiles_type;
  l_profile_defined boolean;
  l_start_date    date;
  l_end_date      date;
  l_description  fnd_user.description%type;
  l_fax          fnd_user.fax%type;
  l_email_address fnd_user.email_address%type;
  l_filter varchar2(10);
  l_filter_defined boolean;


begin
  l_module_source := G_MODULE_SOURCE || 'fnd_create_update: ';
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;
  if (p_event_type = wf_oid.IDENTITY_MODIFY) then
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'IDENTITY_MODIFY '
        || 'event is handled by fnd_user_pkg.user_change().');
    end if;
    return;
   end if;
  --Check whether this guid already exists. Don't raise alerts because we receive echo
  --from OID for each user that is created.
  l_apps_userguid_key := fnd_oid_util.get_fnd_user(p_user_guid => p_user_guid);
  -- Disable user in FND when user unsubscribed from the application in OID
  if (p_event_type = wf_oid.SUBSCRIPTION_DELETE) then
     update fnd_user set end_date= sysdate
       where user_name = l_apps_userguid_key.user_name;
   end if;
  if (l_apps_userguid_key.user_id is not null) then
    if(fnd_log.LEVEL_UNEXPECTED >=  fnd_log.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source,
        'GUID ' || p_user_guid || ' is already linked'
        ||  ' to user_name ' || l_apps_userguid_key.user_name);
    end if;
    return;
  end if;
  -- Check whether this user_name already exists. We won't link (update user_guid) here.
  -- We let Auto Link profile or the linking page controls who is linked to whom.
  l_apps_username_key := fnd_oid_util.get_fnd_user(p_user_name => p_user_name);
  if (l_apps_username_key.user_id is not null) then
    -- Is this user linked to someone else?  Raise alert because it's a security threat.
    if (l_apps_username_key.user_guid is not null and l_apps_username_key.user_guid <> p_user_guid) then
      if(fnd_log.LEVEL_UNEXPECTED >=
        fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_message.SET_NAME('FND', 'FND_SSO_UNABLE_TO_LINK');
        fnd_message.SET_TOKEN('USER_NAME', p_user_name);
        fnd_message.SET_TOKEN('ORCLGUID', l_apps_username_key.user_guid);
        fnd_log.MESSAGE(fnd_log.LEVEL_UNEXPECTED, l_module_source, TRUE);
        fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source,
        'User_name ' || p_user_name || '
         already exists in E-Business and is linked to an OID account with GUID '
         || l_apps_username_key.user_guid);
      end if;
    end if;
    return;
  end if;
   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
	fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Enabled flag is: ' || p_isenabled);
   end if;
  -- Don't create user if disabled in OID
  if (p_isenabled = 'INACTIVE' or p_isenabled = 'DISABLED') then
     fnd_profile.get_specific(
	name_z      => 'APPS_SSO_PROV_DISABLED_LDAPUSR',
	val_z      => l_filter,
	defined_z    => l_filter_defined);
    if (l_filter_defined AND l_filter='Y') then
        if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,
            'User ' || p_user_name || ' is disabled at OID but will be created created in FND_USER  because APPS_SSO_PROV_DISABLED_LDAPUSR=Y');
        end if;
    else
        if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,
            'User ' || p_user_name || ' will not be created in FND_USER, because ' ||
            'it''s Disabled in OID. APPS_SSO_PROV_DISABLED_LDAPUSR='||l_filter);
        end if;
        return;
   end if;
  end if;

  --This means neither user name nor guid exist in fnd_user
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,
        'User does not exist in FND_USER. About to create a new user...');
  end if;
   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
	fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Start_date input: ' || p_start_date);
	fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End_date input: ' || p_end_date);
   end if;
  -- WF_ENTITY_MGR returns '*UNKNOWN*' string if the value was not found in attr_cache table
  -- we should not populate the fnd_user table with this, for fax and description.

  -- Bug 5347086 - fnd_user_pkg does not check for UNKNOWN when creating the user.  Doing it here
  if (p_description in ('*UNKNOWN*','*NULL*')) then
     l_description := null;
  else
     l_description := p_description;
  end if;

  if (p_email_address in ('*UNKNOWN*','*NULL*')) then
     l_email_address := null;
  else
     l_email_address := p_email_address;
  end if;

  if (p_fax in ('*UNKNOWN*','*NULL*')) then
     l_fax := null;
  else
     l_fax := p_fax;
  end if;

  if (p_start_date is null or p_start_date = '*UNKNOWN*') then
    l_start_date := sysdate;
  else
    l_start_date := to_date(substr(p_start_date, 1, 14), fnd_oid_util.G_YYYYMMDDHH24MISS);
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
	fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Start_date output: ' || l_start_date);
  end if;

  if (p_end_date is null or p_end_date = '*UNKNOWN*') then
    l_end_date := null;
  else
    l_end_date := to_date(substr(p_end_date, 1, 14), fnd_oid_util.G_YYYYMMDDHH24MISS);
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End_date output: ' || l_end_date);
  end if;

  x_user_id := fnd_user_pkg.CreateUserId(
        x_user_name => p_user_name
      , x_owner => p_owner
      , x_unencrypted_password => fnd_web_sec.EXTERNAL_PWD -- passowrd will be set to EXTERNAL
      , x_description => l_description
      , x_email_address => l_email_address
      , x_start_date => l_start_date
      , x_end_date  => l_end_date
      , x_fax => l_fax
      , x_user_guid => p_user_guid
      , x_change_source =>  fnd_user_pkg.change_source_oid
      );

  -- API to set user profile value;
  l_found := fnd_profile.save(x_name => 'APPS_SSO_LOCAL_LOGIN'
                     , x_value => 'SSO'
                     , x_level_name => 'USER'
                     , x_level_value => x_user_id);
  if not l_found then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,
           'Unable to set APPS_SSO_LOCAL_LOGIN profile value to SSO for user ' || p_user_name);
    end if;
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
end fnd_create_update;

procedure fnd_create_update(
    p_wf_event      in  wf_event_t
  , p_event_type   in  varchar2
  , p_user_name     in  fnd_user.user_name%type
  , p_user_guid     in fnd_user.user_guid%type
  , x_user_id       out nocopy fnd_user.user_id%type
) is

  l_module_source varchar2(256);
  l_description   fnd_user.description%type;
  l_email_address fnd_user.email_address%type;
  l_fax           fnd_user.fax%type;
  l_user_id       number;
  l_start_date    varchar2(4000);
  l_end_date      varchar2(4000);
  l_isenabled     varchar2(4000);

begin
  l_module_source := G_MODULE_SOURCE || 'fnd_create_update: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  -- Read the values from wf_attribute_cache
  l_description := wf_entity_mgr.get_attribute_value(p_event_type,
    p_user_name, 'DESCRIPTION');
  l_email_address := wf_entity_mgr.get_attribute_value(p_event_type,
    p_user_name, 'MAIL');
  l_fax := wf_entity_mgr.get_attribute_value(p_event_type,
    p_user_name, 'FACSIMILETELEPHONENUMBER');
  l_start_date := wf_entity_mgr.get_attribute_value(p_event_type,
    p_user_name, 'ORCLACTIVESTARTDATE');
  l_end_date := wf_entity_mgr.get_attribute_value(p_event_type,
    p_user_name, 'ORCLACTIVEENDDATE');
  l_isenabled := wf_entity_mgr.get_attribute_value(p_event_type,
    p_user_name, 'ORCLISENABLED');
  if (l_isenabled = '*UNKNOWN*') then
    l_isenabled := wf_entity_mgr.get_attribute_value('USER',
    p_user_name, 'ORCLISENABLED');
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,
      'l_description = ' || l_description ||
      'l_email_address = ' || l_email_address ||
      'l_fax = ' || l_fax
    );
  end if;

  fnd_create_update(
    p_event_type => p_event_type
  , p_user_name => p_wf_event.GetEventKey
  , p_user_guid => p_user_guid
  , p_owner => fnd_oid_util.G_CUST
  , p_unencrypted_password => null
  , p_description => l_description
  , p_email_address => l_email_address
  , p_fax => l_fax
  , p_start_date => l_start_date
  , p_end_date => l_end_date
  , p_isenabled => l_isenabled
  , x_user_id  => l_user_id);

  x_user_id := l_user_id;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;
exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
end fnd_create_update;
--

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
/*
** Name      : hz_create_update
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
procedure hz_create_update(
    p_wf_event      in          wf_event_t
  , p_event_type    in  varchar2
  , p_return_status out nocopy  varchar2
);
--
-- End of Private Program Units
--
-------------------------------------------------------------------------------
function identity_add(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
  return varchar2 is

  l_module_source varchar2(256);
  l_event_name          varchar2(256);
  l_event_key           varchar2(256);
  l_change_source       varchar2(256);
  l_user_id             number;
  l_orcl_guid           fnd_user.user_guid%type;

begin
  l_module_source := G_MODULE_SOURCE || 'identity_add: ';

  if (fnd_log.LEVEL_EVENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_EVENT, l_module_source,
      'EBIZ is NOW capable of understanding IDENTITY_ADD');
  end if;
  --RDESPOTO, Add IDENTITY_ADD, 11/09/2004
  l_event_key := p_event.GetEventKey;
  l_event_name := WF_OID.IDENTITY_ADD;

  l_change_source := p_event.GetValueForParameter(
    fnd_oid_util.G_CHANGE_SOURCE);

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
      , 'l_event_key = ' || l_event_key ||
      ', l_event_name = ' || l_event_name ||
      ', l_change_source = ' || l_change_source);
  end if;
  --Change_source has to be OID
  if (l_change_source = fnd_oid_util.G_OID) then
    l_orcl_guid := p_event.GetValueForParameter(
      fnd_oid_util.G_ORCLGUID);
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'User_guid is:'
      || l_orcl_guid || ', user_name is ' || l_event_key);
    end if;
    -- Maintain IDENTITY_ADD event type to pick up email and fax correctly
    fnd_create_update(
        p_wf_event    => p_event
      , p_event_type => wf_oid.IDENTITY_ADD
      , p_user_name   => l_event_key
      , p_user_guid   => l_orcl_guid
      , x_user_id     => l_user_id
    );
  end if;
  return(wf_rule.default_rule(p_subscription_guid, p_event));
exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    return(wf_rule.error_rule(p_subscription_guid, p_event));

end identity_add;
--
-------------------------------------------------------------------------------
function identity_modify(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
  return varchar2 is

  l_module_source varchar2(256);
  l_user_id       number;
  l_orcl_guid           fnd_user.user_guid%type;

begin
  l_module_source := G_MODULE_SOURCE || 'identity_modify: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;
  --THIS SUBSCRIPTION IS NOT USED! fnd_user_pkg.user_change SUBSCRIPTION IS USED INSTEAD.
  --Rada, 01/31/2005
  l_orcl_guid := p_event.GetValueForParameter(
      fnd_oid_util.G_ORCLGUID);
  fnd_create_update(
      p_wf_event    => p_event
    , p_event_type => WF_OID.IDENTITY_MODIFY
    , p_user_name   => p_event.GetEventKey()
    , p_user_guid   => l_orcl_guid
    , x_user_id     => l_user_id
  );

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

  return(wf_rule.default_rule(p_subscription_guid, p_event));

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    return(wf_rule.error_rule(p_subscription_guid, p_event));

end identity_modify;
--
-------------------------------------------------------------------------------
function identity_delete(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
  return varchar2 is

  l_module_source varchar2(256);
  l_profiles fnd_oid_util.apps_sso_user_profiles_type;
  l_found boolean;
  l_user_id fnd_user.user_id%type;
begin
  l_module_source := G_MODULE_SOURCE || 'identity_delete: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  -- Do something

   -- Bug 13829710
   -- Moving the end dating of the user to this subscription so it may be
   -- disabled
   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End dating user: '||p_event.GetEventKey);
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Setting encpwds to EXTERNAL for user: '||p_event.GetEventKey);
  end if;

   -- Bug 14469422 changes for unlinked users:
   --    end-date the user
   --    set pwds to EXTERNAL
   --    null out certain user level profiles
   update fnd_user
   set end_date = sysdate,
       encrypted_user_password = 'EXTERNAL',
       encrypted_foundation_password = 'EXTERNAL',
       last_updated_by = FND_GLOBAL.USER_ID, /* added for bug 19250301 */
       last_update_date = sysdate           /* added for bug 19250301 */
   where user_name = p_event.GetEventKey;

   select user_id into l_user_id
   from fnd_user
   where user_name = p_event.GetEventKey;

   l_profiles := fnd_ldap_mapper.map_sso_user_profiles(p_event.GetEventKey);
   if (l_profiles.ldap_sync is not null) then
   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Setting user level profile APPS_SSO_LDAP_SYNC to null for user: '||p_event.GetEventKey);
   end if;
     l_found := fnd_profile.save(x_name => 'APPS_SSO_LDAP_SYNC'
                     , x_value =>null
                     , x_level_name => 'USER'
                     , x_level_value => l_user_id);

     if not l_found then
       if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,
           'Unable to set APPS_SSO_LDAP_SYNC profile value to null for user ' || p_event.GetEventKey);
       end if;
     end if;
   end if;

   if (l_profiles.local_login is not null) then
   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Setting user level profile APPS_SSO_LOCAL_LOGIN to null for user: '||p_event.GetEventKey);
   end if;
     l_found := fnd_profile.save(x_name => 'APPS_SSO_LOCAL_LOGIN'
                     , x_value =>null
                     , x_level_name => 'USER'
                     , x_level_value => l_user_id);

     if not l_found then
       if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,
           'Unable to set APPS_SSO_LOCAL_LOGIN profile value to null for user ' || p_event.GetEventKey);
       end if;
     end if;
   end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

  return(wf_rule.default_rule(p_subscription_guid, p_event));

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    return(wf_rule.error_rule(p_subscription_guid, p_event));

end identity_delete;
--
-------------------------------------------------------------------------------
/**
 * This subscription handles the following events:
 *    OID   -> User subscribing to an EBIZ instance
 *    EBIZ  -> Linking of an FND_USER to OID user
 * In both instances a SUBSCRIPTION_ADD event is raised. The change_source
 * attribute is however different as below:
 *    OID   -> change_source attribute is OID
 *    EBIZ  -> change_source attribute is EBIZ
 * Please make sure that the change_source is indeed EBIZ and not FND_USER
 * when the event is raised by EBIZ.
 */
function subscription_add(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
  return varchar2 is

  l_module_source       varchar2(256);
  l_sso_user_profiles   fnd_oid_util.apps_sso_user_profiles_type;
  l_event_name          varchar2(256);
  l_event_key           varchar2(256);
  l_change_source       varchar2(256);
  l_user_id             number;
  l_orcl_guid           fnd_user.user_guid%type;

begin
  l_module_source := G_MODULE_SOURCE || 'subscription_add: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;
  l_event_key := p_event.GetEventKey;
  l_event_name := WF_OID.SUBSCRIPTION_ADD;

  l_change_source := p_event.GetValueForParameter(
    fnd_oid_util.G_CHANGE_SOURCE);

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
      , 'l_event_key = ' || l_event_key ||
      ', l_event_name = ' || l_event_name ||
      ', l_change_source = ' || l_change_source);
  end if;

  if (l_change_source = fnd_oid_util.G_OID) then
    l_orcl_guid := p_event.GetValueForParameter(
      fnd_oid_util.G_ORCLGUID);
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'User_guid is:'
      || l_orcl_guid || ', user_name is ' || l_event_key);
    end if;
    fnd_create_update(
        p_wf_event    => p_event
      , p_event_type => wf_oid.SUBSCRIPTION_ADD
      , p_user_name   => l_event_key
      , p_user_guid   => l_orcl_guid
      , x_user_id     => l_user_id
    );
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

  return(wf_rule.default_rule(p_subscription_guid, p_event));

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    return(wf_rule.error_rule(p_subscription_guid, p_event));

end subscription_add;
--
-------------------------------------------------------------------------------
/**
 * This subscription handles the following events:
 *    OID   -> User unsubscribing to an EBIZ instance
 *    EBIZ  -> Uninking of an FND_USER with the OID user
 * In both instances a SUBSCRIPTION_DELETE event is raises. The change_source
 * attribute is however different as below:
 *    OID   -> change_source attribute is OID
 *    EBIZ  -> change_source attribute is EBIZ
 * Please make sure that the change_source is indeed EBIZ and not FND_USER
 * when the event is raised by EBIZ.
 */
function subscription_delete(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
  return varchar2 is

  l_module_source       varchar2(256);
  l_sso_user_profiles   fnd_oid_util.apps_sso_user_profiles_type;
  l_event_name          varchar2(256);
  l_event_key           varchar2(256);
  l_change_source       varchar2(256);
  l_user_id            number;
  l_orcl_guid           fnd_user.user_guid%type;


begin
  l_module_source := G_MODULE_SOURCE || 'subscription_delete: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  l_event_key := p_event.GetEventKey;
  l_event_name := WF_OID.SUBSCRIPTION_DELETE;
  l_change_source := p_event.GetValueForParameter(
    fnd_oid_util.G_CHANGE_SOURCE);

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
      , 'l_event_key = ' || l_event_key ||
      ', l_event_name = ' || l_event_name ||
      ', l_change_source = ' || l_change_source);
  end if;

  l_sso_user_profiles := fnd_ldap_mapper.map_sso_user_profiles(l_event_key);

  if (l_change_source = fnd_oid_util.G_EBIZ)
  then
    insert into wf_entity_changes(
      entity_type, entity_key_value, flavor, change_date)
    values(
      wf_oid.SUBSCRIPTION_DELETE, l_event_key, l_change_source, sysdate);

  else
    --Rada, 01/31/2005
    l_orcl_guid := p_event.GetValueForParameter(
      fnd_oid_util.G_ORCLGUID);
    /*fnd_create_update(
        p_event_type           => l_event_name
      , p_user_name             => p_event.GetEventKey
      , p_user_guid             => l_orcl_guid
      , p_owner                 => fnd_oid_util.G_CUST
      , p_unencrypted_password  => null
      , p_description           => null
      , p_email_address         => null
      , p_fax                   => null
      , p_start_date            => fnd_oid_util.G_NULL
      , p_end_date              => fnd_oid_util.G_NULL
      , x_user_id               => l_user_id);*/
      fnd_create_update(
        p_wf_event    => p_event
      , p_event_type =>  wf_oid.SUBSCRIPTION_DELETE
      , p_user_name   => l_event_key
      , p_user_guid   => l_orcl_guid
      , x_user_id     => l_user_id
    );
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

  return(wf_rule.default_rule(p_subscription_guid, p_event));

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    return(wf_rule.error_rule(p_subscription_guid, p_event));
end subscription_delete;
-------------------------------------------------------------------------------
--
function synch_oid_to_tca(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
 return varchar2 is

 cursor cur_attribute_cache(p_user_name in wf_attribute_cache.entity_key_value%type) is
    select attribute_name
           , attribute_value
      from wf_attribute_cache
     where entity_type = fnd_oid_util.G_USER
       and entity_key_value = p_user_name
       and attribute_name <> fnd_oid_util.G_CACHE_CHANGED;

  l_module_source       varchar2(256);
  l_user_name fnd_user.user_name%type;
  l_result pls_integer;

  l_old_user_guid  fnd_user.user_guid%type;
  l_user_guid fnd_user.user_guid%type;
  l_user_guid_changed boolean;

  l_old_person_party_id fnd_user.person_party_id%type;
  l_person_party_id fnd_user.person_party_id%type;
  l_person_party_id_changed boolean;
  l_apps_sso_link_truth_src   varchar2(5);
  l_profile_defined boolean;
begin
  l_module_source := G_MODULE_SOURCE || '	synch_oid_to_tca: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  -- Ignore TCA's own changes
  -- bug 4411121
  -- If the change source is HZ_PARTY. Further processing is stopped
  -- This has to be addressed later. If this was HZ change we have to push it to OID.
  if (p_event.GetValueForParameter('CHANGE_SOURCE') = 'HZ_PARTY') then

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'changeSrc is TCA no processing required');
   end if;

    return 'SUCCESS';
  end if;


  l_user_guid_changed := false;
  l_person_party_id_changed := false;

  l_user_name := p_event.getEventKey();

 if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
                   'USER_NAME: '||l_user_name);
  end if;

  for l_rec in cur_attribute_cache(l_user_name)
  loop
    if (l_rec.attribute_name = 'OLD_PERSON_PARTY_ID')
     then
       l_old_person_party_id := l_rec.attribute_value;

    elsif(l_rec.attribute_name = 'OLD_ORCLGUID')
     then
       l_old_user_guid := l_rec.attribute_value;

    elsif(l_rec.attribute_name = 'ORCLGUID')
     then
       l_user_guid := l_rec.attribute_value;

    else
     if(l_rec.attribute_name = 'PERSON_PARTY_ID')
      then
         l_person_party_id := l_rec.attribute_value;
     end if;
    end if;
  end loop;

 if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
                   ' OLD_PERSON_PARTY_ID:: '||l_old_person_party_id||'::'||
                   ' PERSON_PARTY_ID:: '||l_person_party_id||'::'||
                   ' OLD_ORCLGUID::'||l_old_user_guid||'::'||
                   ' ORCLGUID::'||l_user_guid||'::');
  end if;

--verify if the "*NULL*" case needs to be handled separately. !!scheruku

    if(l_old_person_party_id IS NULL and  l_person_party_id IS NOT NULL) or
      (l_old_person_party_id <> l_person_party_id)
    then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
       then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
                   'person party id changed');
       end if;
     l_person_party_id_changed := true;
  end if;

  if(l_old_user_guid IS NULL and  l_user_guid IS NOT NULL) or (l_old_user_guid <> l_user_guid)
    then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
       then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
                   'GUID changed');
       end if;
     l_user_guid_changed := true;
  end if;


  if(l_person_party_id_changed or l_user_guid_changed)
    then
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
                   ' Either GUID or person party id has changed:');
     end if;

     fnd_profile.get_specific(
	name_z      => 'APPS_SSO_LINK_TRUTH_SRC',
	val_z      => l_apps_sso_link_truth_src,
	defined_z    => l_profile_defined);


     if(l_apps_sso_link_truth_src is NULL or l_apps_sso_link_truth_src = fnd_oid_util.G_OID)
     then
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
        then
	  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
		     ' OID  is source of Truth during linking ');
        end if;
	fnd_oid_util.synch_user_from_LDAP_NO_AUTO(p_user_name => l_user_name,
                                        p_result => l_result);

        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
        then
	  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
		     ' After synch l_result: '||l_result);
        end if;
      else
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
        then
	  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
		     ' Apps is source of Truth during linking ');
        end if;
       ---Fix me as and when available add code here to fetch attributes from TCA/HR and send to OID. !!scheruku
      end if;
  end if;


   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

  return(wf_rule.default_rule(p_subscription_guid, p_event));
exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    return(wf_rule.error_rule(p_subscription_guid, p_event));
end synch_oid_to_tca;

-------------------------------------------------------------------------------
--
function on_demand_user_create(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
 return varchar2 is

  l_module_source varchar2(256);
  l_user_name         fnd_user.user_name%type;
  l_user_guid         fnd_user.user_guid%type;
  l_result pls_integer;

begin
 l_module_source := G_MODULE_SOURCE || '	on_demand_user_create: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;
  l_user_name:= p_event.GetValueForParameter('USER_NAME');
  l_user_guid:= p_event.GetValueForParameter('ORCLGUID');

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
                        'username: '||l_user_name||' user_guid: '||l_user_guid);
  end if;

--	Replaced by subscribing assign_def_resp to "oracle.apps.fnd.ondemand.create" event
--  assign_default_resp(
--           p_user_name=>l_user_name
--  );

	fnd_oid_util.synch_user_from_LDAP_NO_AUTO(p_user_name => l_user_name,
                                        p_result => l_result);
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
	  then
		  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
		     ' After synch l_result: '||l_result);
  end if;

  return(wf_rule.default_rule(p_subscription_guid, p_event));

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    return(wf_rule.error_rule(p_subscription_guid, p_event));

end on_demand_user_create;
-------------------------------------------------------------------------------
--
function event_error(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
   return varchar2 is

  l_module_source varchar2(256);
  l_event_id          wf_entity_changes.entity_id%type;
  l_user_name         fnd_user.user_name%type;
  l_user_guid         fnd_user.user_guid%type;

begin
  l_module_source := G_MODULE_SOURCE || 'event_error: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;
  --RDESPOTO, 09/07/2004
  --need constants for these in FND_OID_UTIL
  l_event_id := p_event.GetValueForParameter('ENTITY_ID');
  l_user_name:= p_event.GetValueForParameter('USER_NAME');
  l_user_guid:= p_event.GetValueForParameter('ORCLGUID');


  if(fnd_log.LEVEL_UNEXPECTED >=
	    fnd_log.G_CURRENT_RUNTIME_LEVEL) then

  	fnd_message.SET_NAME('FND', 'FND_SSO_EVENT_ERROR');
  	fnd_message.SET_TOKEN('USER_NAME', l_user_name);
  	fnd_message.SET_TOKEN('ENTITY_ID', l_event_id);
    fnd_message.SET_TOKEN('ORCLGUID', l_user_guid);
  	fnd_log.MESSAGE(fnd_log.LEVEL_UNEXPECTED,
     							l_module_source, TRUE);
    fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source,
        'Synchronization of user definiton between E-Business Suite'||
        ' and Oracle Internet Directory has failed for user:' || l_user_name ||
        ', event id:' || l_event_id || ', guid:' || l_user_guid);
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return(wf_rule.default_rule(p_subscription_guid, p_event));

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    return(wf_rule.error_rule(p_subscription_guid, p_event));
end event_error;
--
-------------------------------------------------------------------------------
function event_resend(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
   return varchar2 is

  l_module_source varchar2(256);
  l_event_id          wf_entity_changes.entity_id%type;
  l_user_name         fnd_user.user_name%type;
  l_user_guid         fnd_user.user_guid%type;

begin
  l_module_source := G_MODULE_SOURCE || 'event_resend: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;
  --RDESPOTO, 09/07/2004
  --need constants for these in FND_OID_UTIL
  l_event_id := p_event.GetValueForParameter('ENTITY_ID');
  l_user_name:= p_event.GetValueForParameter('USER_NAME');
  l_user_guid:= p_event.GetValueForParameter('ORCLGUID');


  if(fnd_log.LEVEL_UNEXPECTED >=
	    fnd_log.G_CURRENT_RUNTIME_LEVEL) then

  	fnd_message.SET_NAME('FND', 'FND_SSO_EVENT_RESEND');
  	fnd_message.SET_TOKEN('USER_NAME', l_user_name);
  	fnd_message.SET_TOKEN('ENTITY_ID', l_event_id);
    fnd_message.SET_TOKEN('ORCLGUID', l_user_guid);
  	fnd_log.MESSAGE(fnd_log.LEVEL_UNEXPECTED,
     							l_module_source, TRUE);
    fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source,
        'Synchronization event between E-Business Suite'
        || ' and Oracle Internet Directory has to be resent for user '
        || l_user_name || ', event id:' || l_event_id || ', guid:' || l_user_guid);
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return(wf_rule.default_rule(p_subscription_guid, p_event));

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    return(wf_rule.error_rule(p_subscription_guid, p_event));
end event_resend;
--
-------------------------------------------------------------------------------
function hz_identity_add(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
  return varchar2 is

  l_module_source varchar2(256);
  l_return_status varchar2(1);
  l_change_source       varchar2(256);

begin
  l_module_source := G_MODULE_SOURCE || 'hz_identity_add: ';

  if (fnd_log.LEVEL_EVENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_EVENT, l_module_source,
      'EBIZ is NOW capable of understanding IDENTITY_ADD.');
  end if;
  --RDESPOTO, Add IDENTITY_ADD, 11/09/2004
  l_change_source := p_event.GetValueForParameter(
    fnd_oid_util.G_CHANGE_SOURCE);
  --Change_source has to be OID
  if (l_change_source = fnd_oid_util.G_OID) then
  hz_create_update(
    p_wf_event      => p_event
  , p_event_type    => wf_oid.IDENTITY_ADD
  , p_return_status => l_return_status);
  --RDESPOTO, End IDENTITY_ADD
  end if;

  return(wf_rule.default_rule(p_subscription_guid, p_event));

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    return(wf_rule.error_rule(p_subscription_guid, p_event));
end hz_identity_add;
--
-------------------------------------------------------------------------------
function hz_identity_modify(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
  return varchar2 is

  l_module_source varchar2(256);
  l_ldap_message  fnd_oid_util.ldap_message_type;
  l_return_status varchar2(1);
  hz_failed_exp   exception;

begin
  l_module_source := G_MODULE_SOURCE || 'hz_identity_modify: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  hz_create_update(
    p_wf_event      => p_event
  , p_event_type    => wf_oid.IDENTITY_MODIFY
  , p_return_status => l_return_status);

  if (l_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise hz_failed_exp;
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

  return(wf_rule.default_rule(p_subscription_guid, p_event));

exception
  when hz_failed_exp then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source,
        'hz_failed_exp: l_return_status = ' ||
        l_return_status);
    end if;
    return(wf_rule.error_rule(p_subscription_guid, p_event));

  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    return(wf_rule.error_rule(p_subscription_guid, p_event));
end hz_identity_modify;
--
-------------------------------------------------------------------------------
function hz_identity_delete(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
  return varchar2 is

  l_module_source varchar2(256);

begin
  l_module_source := G_MODULE_SOURCE || 'hz_identity_delete: ';

  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source,
      'This is a no-op for now. This subscription should be disabled. ' ||
      ' Please contact your System administrator to disable subscription');
  end if;

  return(wf_rule.default_rule(p_subscription_guid, p_event));

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    return(wf_rule.error_rule(p_subscription_guid, p_event));
end hz_identity_delete;
--
-------------------------------------------------------------------------------
function hz_subscription_add(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
  return varchar2 is

  l_module_source varchar2(256);
  l_ldap_message  fnd_oid_util.ldap_message_type;
  l_return_status varchar2(1);
  hz_failed_exp   exception;

begin
  l_module_source := G_MODULE_SOURCE || 'hz_subscription_add: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  hz_create_update(
    p_wf_event      => p_event
  , p_event_type    => wf_oid.SUBSCRIPTION_ADD
  , p_return_status => l_return_status);

  if (l_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise hz_failed_exp;
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

  return(wf_rule.default_rule(p_subscription_guid, p_event));

exception
  when hz_failed_exp then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source,
        'hz_failed_exp: l_return_status = ' ||
        l_return_status);
    end if;
    return(wf_rule.error_rule(p_subscription_guid, p_event));

  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    return(wf_rule.error_rule(p_subscription_guid, p_event));
end hz_subscription_add;
--
-------------------------------------------------------------------------------
function hz_subscription_delete(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
  return varchar2 is

  l_module_source varchar2(256);

begin
  l_module_source := G_MODULE_SOURCE || 'hz_subscription_delete: ';

  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source,
      'This is a no-op for now. This subscription should be disabled. ' ||
      ' Please contact your System administrator to disable subscription');
  end if;

  return(wf_rule.default_rule(p_subscription_guid, p_event));

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    return(wf_rule.error_rule(p_subscription_guid, p_event));
end hz_subscription_delete;
--
-------------------------------------------------------------------------------
procedure hz_create_update(
    p_wf_event      in wf_event_t
  , p_event_type    in varchar2
  , p_return_status out nocopy  varchar2
) is

  l_module_source   varchar2(256);
  l_ldap_message    fnd_oid_util.ldap_message_type;
  l_return_status   varchar2(1);
  l_count	    number;
  l_event_key           varchar2(256);

begin
  l_module_source := G_MODULE_SOURCE || 'hz_create_update: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  fnd_ldap_mapper.map_ldap_message(p_wf_event, p_event_type, l_ldap_message);

  if (fnd_oid_util.person_party_exists(p_wf_event.GetEventKey))
  then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,
        'Person Party exists in FND_USER');
    end if;
    fnd_oid_users.hz_update(
        p_ldap_message  => l_ldap_message
      , x_return_status => p_return_status);
  else
    l_event_key :=  p_wf_event.GetEventKey;
    select count(*) into l_count
    from fnd_user
    where user_name = l_event_key
    and user_guid is not null;

    if (l_count > 0) then
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,
          'Person Party does NOT exist in FND_USER, creating a new TCA entry');
      end if;
      fnd_oid_users.hz_create(
          p_ldap_message  => l_ldap_message
        , x_return_status => p_return_status);
    else
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,
          'FND User is not linked to OID user, therefore not creating TCA party');
      end if;
    end if;

  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
end hz_create_update;
--
-------------------------------------------------------------------------------
procedure get_resp_app_id(p_resp_key in fnd_responsibility.responsibility_key%type
                        , x_responsibility_id out nocopy fnd_responsibility.responsibility_id%type
                        , x_application_id out nocopy fnd_responsibility.application_id%type) is

 l_module_source varchar2(256);
 l_responsibility_id fnd_responsibility.responsibility_id%type;
 l_application_id    fnd_responsibility.application_id%type;
 l_found boolean;

 cursor cur_fnd_responsibility  is
    SELECT responsibility_id, application_id
    from fnd_responsibility
   where RESPONSIBILITY_KEY = p_resp_key;
begin
   l_module_source := G_MODULE_SOURCE || 'get_resp_app_id ';

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
     fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
   end if;

 open cur_fnd_responsibility;
 fetch cur_fnd_responsibility into l_responsibility_id, l_application_id;
 l_found := cur_fnd_responsibility%found;

  if (not l_found)
  then
    l_responsibility_id := null;
    l_application_id := null;
  end if;
  close cur_fnd_responsibility;

  x_responsibility_id := l_responsibility_id;
  x_application_id := l_application_id;

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
     fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
   end if;

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    raise;
end get_resp_app_id;
--
-------------------------------------------------------------------------------
procedure assign_default_resp(p_user_name in varchar2) is

  l_module_source varchar2(256);
  l_apps_user_key fnd_oid_util.apps_user_key_type;
  l_found         boolean := false;

  l_responsibility_id fnd_responsibility.responsibility_id%type;
  l_application_id    fnd_responsibility.application_id%type;
  l_resp_key  fnd_responsibility.responsibility_key%type;

begin
  l_module_source := G_MODULE_SOURCE || 'assign_default_resp: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  l_apps_user_key := fnd_oid_util.get_fnd_user(p_user_name => p_user_name);

  l_resp_key := 'PREFERENCES';
  get_resp_app_id(p_resp_key => l_resp_key
	     , x_responsibility_id=>l_responsibility_id
	     , x_application_id=>l_application_id
	     );

  l_found := fnd_user_resp_groups_api.assignment_exists(
      user_id                       => l_apps_user_key.user_id
    , responsibility_id             => l_responsibility_id
    , responsibility_application_id => l_application_id
    , security_group_id             => null);

  if (not l_found)
  then
    fnd_user_resp_groups_api.insert_assignment(
        user_id                       => l_apps_user_key.user_id
      , responsibility_id             => l_responsibility_id
      , responsibility_application_id => l_application_id
      , security_group_id             => null
      , start_date                    => sysdate
      , end_date                      => null
      , description                   => 'Default Assignment for OID User'
    );
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
end assign_default_resp;
--
-------------------------------------------------------------------------------
/* This function assigns default "Preference SSWA" responsibility to any
 user created in OID or Ebiz */

function assign_def_resp(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
  return varchar2 is

  l_module_source       varchar2(256);
  l_event_name          varchar2(256);
  l_event_key           varchar2(256);
  l_change_source       varchar2(256);
  l_apps_user_key       fnd_oid_util.apps_user_key_type;
  l_found               boolean := false;

  l_responsibility_id fnd_responsibility.responsibility_id%type;
  l_application_id    fnd_responsibility.application_id%type;
  l_resp_key  fnd_responsibility.responsibility_key%type;

begin
  l_module_source := G_MODULE_SOURCE || 'assign_def_resp: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  l_event_key := p_event.GetEventKey;
  l_event_name := WF_OID.SUBSCRIPTION_ADD;
  l_change_source := p_event.GetValueForParameter(
    fnd_oid_util.G_CHANGE_SOURCE);

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
      , 'l_event_key = ' || l_event_key ||
      ', l_event_name = ' || l_event_name ||
      ', l_change_source = ' || l_change_source);
  end if;

  l_apps_user_key := fnd_oid_util.get_fnd_user(p_user_name => l_event_key);

  l_resp_key := 'PREFERENCES';
  get_resp_app_id(p_resp_key => l_resp_key
	     , x_responsibility_id=>l_responsibility_id
	     , x_application_id=>l_application_id
	     );


/* check whether the user is already assigned the responsibility  */


  l_found := fnd_user_resp_groups_api.assignment_exists(
      user_id                       => l_apps_user_key.user_id
    , responsibility_id             => l_responsibility_id
    , responsibility_application_id => l_application_id
    , security_group_id             => null);

/* If user is not assigned the responsibility,assign the default responsibility */

  if (not l_found)
  then
    fnd_user_resp_groups_api.insert_assignment(
        user_id                       => l_apps_user_key.user_id
      , responsibility_id             => l_responsibility_id
      , responsibility_application_id => l_application_id
      , security_group_id             => null
      , start_date                    => sysdate
      , end_date                      => null
      , description                   => 'Default Assignment for OID and Ebiz User'
    );
  end if;


  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

  return(wf_rule.default_rule(p_subscription_guid, p_event));

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    return(wf_rule.error_rule(p_subscription_guid, p_event));

end assign_def_resp;

--
------------------------------------------------------------------------

function set_password_external(
    p_subscription_guid in            raw
  , p_event             in out nocopy wf_event_t)
  return varchar2 is

  l_module_source       varchar2(256);
  l_event_name          varchar2(256);
  l_event_key           varchar2(256);
  l_change_source       varchar2(256);
  l_apps_user_key       fnd_oid_util.apps_user_key_type;
  l_found               boolean := false;
  l_ext_user_found        number;

begin
  l_module_source := G_MODULE_SOURCE || 'set_password_external: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  l_event_key := p_event.GetEventKey;
  l_event_name := WF_OID.IDENTITY_MODIFY;
  l_change_source := p_event.GetValueForParameter(fnd_oid_util.G_CHANGE_SOURCE);

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
      , 'l_event_key = ' || l_event_key ||
      ', l_event_name = ' || l_event_name ||
      ', l_change_source = ' || l_change_source);
  end if;

  l_apps_user_key := fnd_oid_util.get_fnd_user(p_user_name => l_event_key);

  -- Check if the user pwd is external already
  select count(1) into l_ext_user_found from fnd_user
  where user_name like upper(l_event_key)
  and encrypted_user_password <> 'EXTERNAL'
  and encrypted_foundation_password <> 'EXTERNAL';


  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Check for user - count: '||l_ext_user_found);
  end if;

  if (l_ext_user_found > 0) then
     -- Call API to set pwd to external
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Found user now set password to EXTERNAL');
       end if;

     fnd_sso_util.setPasswordExternal(p_user_name_patt=>l_event_key,p_upd_local_user=>'N');
  end if;


  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

  return(wf_rule.default_rule(p_subscription_guid, p_event));

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    return(wf_rule.error_rule(p_subscription_guid, p_event));

end set_password_external;
--
------------------------------------------------------------------------


end fnd_oid_subscriptions;

/

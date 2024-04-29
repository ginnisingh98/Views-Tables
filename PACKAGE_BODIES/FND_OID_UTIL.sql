--------------------------------------------------------
--  DDL for Package Body FND_OID_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OID_UTIL" as
/* $Header: AFSCOUTB.pls 120.26.12010000.20 2015/04/14 17:42:10 fskinner ship $ */
--
-- Start of Package Globals

   G_MODULE_SOURCE  constant varchar2(80) := 'fnd.plsql.oid.fnd_oid_util.';

  -- FIXME: For compiling get_key, PutOIDEvent only - Should be removed
  key_guid               varchar2(8);
  procedure validate_OID_preferences (
  my_host         varchar2,
  my_port         varchar2,
  my_user         varchar2,
  my_pwd          varchar2
);
 procedure validate_preference (
  my_preference_name         varchar2,
  my_preference_value        varchar2
);

-- End of Package Globals
--
-------------------------------------------------------------------------------
function unbind(p_session in out nocopy dbms_ldap.session) return pls_integer
is
  retval pls_integer;
begin
  retval := dbms_ldap.unbind_s(p_session);
  return retval;
exception
  when others then return null;
end;
--
-------------------------------------------------------------------------------
function get_orclappname return varchar2 is

l_module_source   varchar2(256);
orclAppName varchar2(256);

begin

  l_module_source := G_MODULE_SOURCE || 'get_orclappname: ';

 -- Performance bug 5001849 - now using the FND API

  orclAppName := fnd_preference.get(p_user_name => '#INTERNAL',
                                    p_module_name => 'LDAP_SYNCH',
                                    p_pref_name => 'USERNAME');


  return orclAppName;
exception
when others then
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;

end get_orclappname;
--
-------------------------------------------------------------------------------
procedure entity_changes(p_username in varchar2) is

  l_module_source   varchar2(256);
  my_flavor         varchar2(5);
  l_user_name       varchar2(100);
  my_userid         number;
  my_start          date;
  my_end            date;
  my_parms          wf_parameter_list_t;
  l_allow_sync      varchar2(1);
  l_profile_defined boolean;

begin
  l_module_source := G_MODULE_SOURCE || 'entity_changes: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'p_username = ' || p_username);
  end if;
  -- FIXME: Need to move this out as a separate function
  begin
    select decode(employee_id,
         null, decode(customer_id, null, 'FND', 'TCA'),
         'HR'),
         user_id, start_date, end_date
      into my_flavor, my_userid, my_start, my_end
      from fnd_user
     where user_name = p_username;
  exception
    when no_data_found then
      my_flavor := 'FND';
      my_userid := NULL;
  end;
  -- Fix bug 4245881, don't sync inactive users
  if (my_start <= sysdate and (my_end is null or my_end > sysdate)) then
    insert into wf_entity_changes(
    entity_type, entity_key_value, flavor, change_date)
    values('USER', p_username, my_flavor, sysdate);
  elsif my_start > sysdate then
     wf_event.AddParameterToList('USER_NAME', p_username, my_parms);
      wf_util.call_me_later(
        p_callback    => 'wf_oid.future_callback',
        p_when        => my_start,
        p_parameters  => my_parms);
  elsif my_end < sysdate then
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'We don''t sync end-dated users to OID: ' || p_username);
    end if;
  end if;
  --We don't propagate end-dating events to OID in this asynchronous process.
  --This code can be uncommented when supporting logic for propagating end-dating events
  --is implemented.
  /*if (my_end > sysdate)
    wf_event.AddParameterToList('USER_NAME', p_username, my_parms);
      wf_util.call_me_later(
        p_callback    => 'wf_oid.future_callback',
        p_when        => my_end,
        p_parameters  => my_parms);
  end if;*/
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    raise;
end entity_changes;
--
-------------------------------------------------------------------------------
function get_user_attributes(
    p_userguid  in          varchar2
  , p_user_name out nocopy  varchar2
) return ldap_attr_list is

  l_module_source   varchar2(256);
  l_session         dbms_ldap.session;
  l_result_message  dbms_ldap.message;
  l_attrs           dbms_ldap.string_collection;
  l_entry_message   dbms_ldap.message;
  l_ber_element     dbms_ldap.ber_element;
  l_values          dbms_ldap.string_collection;
  l_attribute_name  varchar2(256);
  l_attribute_value varchar2(4000);
  l_attribute_list  ldap_attr_list;
  l_index           number;
  l_retval          pls_integer;
  l_orclcommonnicknameattr varchar2(256);
  flag pls_integer;
  l_session_flag boolean := false;
begin
  l_module_source := G_MODULE_SOURCE || 'get_user_attributes: ';
  l_index := 1;
  l_retval := -1;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source || 'Begin'
    , 'p_userguid = ' || p_userguid);
  end if;

  l_session := fnd_ldap_util.c_get_oid_session(flag);
  l_session_flag := true; /* fix for bug 8271359 */
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag = true' );
  end if;

  -- 8580552
  p_user_name := fnd_ldap_user.get_username_from_guid(p_userguid);
 -- l_orclcommonnicknameattr := upper(fnd_ldap_util.get_orclcommonnicknameattr(p_user_name));
  -- Query up the user's attributes from OID using user's GUID
  l_retval := dbms_ldap.search_s(
      ld        => l_session
    , base      => ' '
    , scope     => dbms_ldap.scope_subtree
    , filter    => 'orclguid=' || p_userguid
    , attrs     => l_attrs
    , attronly  => 0
    , res       => l_result_message);

  -- walk the results and convert to an ldap_attr_list
  l_attribute_list := ldap_attr_list();
  l_entry_message := dbms_ldap.first_entry(
      ld  => l_session
    , msg => l_result_message);

  if (l_entry_message is not null)
  then
    l_attribute_name := dbms_ldap.first_attribute(
        ld        => l_session
      , ldapentry => l_entry_message
      , ber_elem  => l_ber_element);

    while (l_attribute_name is not null)
    loop
      -- Bug 16631656 - ignore jpegphoto attribute to resolve ORA-12703
     if (l_attribute_name <> 'jpegphoto') then

      l_values := dbms_ldap.get_values(
          ld        => l_session
        , ldapentry => l_entry_message
        , attr      => l_attribute_name);

      if (l_values.count > 0)
      then
        l_attribute_value := substr(l_values(l_values.first), 1, 4000);
      else
        l_attribute_value := null;
      end if;


      l_attribute_list.extend;
      l_attribute_list(l_index) := ldap_attr(
          attr_name       => l_attribute_name
        , attr_value      => l_attribute_value
        , attr_bvalue     => null
        , attr_value_len  => length(l_attribute_value)
        , attr_type       => 0
        , attr_mod_op     => 2);
      l_index := l_index+1;

     end if; -- executed only if not jpegphoto

      l_attribute_name := dbms_ldap.next_attribute(
          ld        => l_session
        , ldapentry => l_entry_message
        , ber_elem  => l_ber_element);

    end loop;
  end if;

  fnd_ldap_util.c_unbind(l_session,flag);
  l_session_flag := false;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag : = false ' );
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP SESSION CLOSED NORMALLY : ' );
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return(l_attribute_list);

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
          /* Fix for 8271359*/
   if l_session_flag = true then

     if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
         fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closing in EXCEPTION BLOCK - START ' );
     end if;

     fnd_ldap_util.c_unbind(l_session,flag);

     if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
         fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closed in EXCEPTION BLOCK - END ');
     end if;
   end if;
    raise;
    return null;
end get_user_attributes;
--
-------------------------------------------------------------------------------
function get_ldap_event_str(p_ldap_event in ldap_event)
  return varchar2 is

  l_module_source varchar2(256);
  l_str           varchar2(4000);

begin
  l_module_source := G_MODULE_SOURCE || 'get_ldap_event_str: ';

  if (p_ldap_event is not null) then
    l_str := 'event_type: ' || p_ldap_event.event_type;
    l_str := l_str || ', event_id: ' || p_ldap_event.event_id;
    l_str := l_str || ', event_src: ' || p_ldap_event.event_src;
    l_str := l_str || ', event_time: ' || p_ldap_event.event_time;
    l_str := l_str || ', object_name: ' || p_ldap_event.object_name;
    l_str := l_str || ', object_type: ' || p_ldap_event.object_type;
    l_str := l_str || ', object_guid: ' || p_ldap_event.object_guid;
    l_str := l_str || ', object_dn: ' || p_ldap_event.object_dn;
    l_str := l_str || ', profile_id: ' || p_ldap_event.profile_id;

  end if;

  return l_str;

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    raise;
    return null;
end get_ldap_event_str;
--
-------------------------------------------------------------------------------
function get_ldap_attr_str(p_ldap_attr in ldap_attr)
  return varchar2 is

  l_str           varchar2(4000);
  l_module_source varchar2(256);

begin
  l_module_source := G_MODULE_SOURCE || 'get_ldap_attr_str: ';

  if (p_ldap_attr is not null) then
    l_str := 'attr_name : ' || p_ldap_attr.attr_name;
    l_str := l_str || ', attr_value: ' || p_ldap_attr.attr_value;
    l_str := l_str || ', attr_value_len: ' || p_ldap_attr.attr_value_len;
    l_str := l_str || ', attr_type: ' || p_ldap_attr.attr_type;
    l_str := l_str || ', attr_mod_op: ' || p_ldap_attr.attr_mod_op;
  end if;

  return (l_str);

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;

    raise;
    return null;
end get_ldap_attr_str;
--
-------------------------------------------------------------------------------
function get_ldap_event_status_str(p_ldap_event_status in ldap_event_status)
  return varchar2 is

  l_module_source varchar2(256);
  l_str           varchar2(4000);

begin
  l_module_source := G_MODULE_SOURCE || 'get_ldap_event_status_str: ';

  if (p_ldap_event_status is not null) then
    l_str := 'event_id : ' || p_ldap_event_status.event_id;
    l_str := l_str || ', orclguid: ' || p_ldap_event_status.orclguid;
    l_str := l_str || ', error_code: ' || p_ldap_event_status.error_code;
    l_str := l_str || ', error_String: ' || p_ldap_event_status.error_String;
    l_str := l_str || ', error_disposition: ' ||
      p_ldap_event_status.error_disposition;
  end if;

  return (l_str);
exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;

    raise;
    return null;
end get_ldap_event_status_str;
--
-------------------------------------------------------------------------------
function get_fnd_user(p_user_guid in varchar2)
  return apps_user_key_type is


  cursor cur_fnd_users is
    select user_id, user_name, user_guid, person_party_id
      from fnd_user
     where user_guid = hextoraw(p_user_guid);

  l_module_source varchar2(256);
  l_apps_user_key apps_user_key_type;
  l_found         boolean;

begin
  l_module_source := G_MODULE_SOURCE || 'get_fnd_user: ';
  l_found := false;

  open cur_fnd_users;
  fetch cur_fnd_users into l_apps_user_key.user_id, l_apps_user_key.user_name
    , l_apps_user_key.user_guid, l_apps_user_key.person_party_id;
  l_found := cur_fnd_users%found;

  if (not l_found)
  then
    l_apps_user_key.user_guid := null;
    l_apps_user_key.user_id := null;
    l_apps_user_key.user_name := null;
    l_apps_user_key.person_party_id := null;
  end if;
  close cur_fnd_users;

  return (l_apps_user_key);

exception
  when others then
    if (cur_fnd_users%isopen)
    then
      close cur_fnd_users;
    end if;

    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;

    raise;
    return null;
end get_fnd_user;
--
-------------------------------------------------------------------------------
function get_fnd_user(p_user_name in varchar2)
  return apps_user_key_type is


  cursor cur_fnd_users is
    select user_id, user_name, user_guid, person_party_id
      from fnd_user
     where user_name = upper(p_user_name);

  l_module_source varchar2(256);
  l_apps_user_key apps_user_key_type;
  l_found         boolean;

begin
  l_module_source := G_MODULE_SOURCE || 'get_fnd_user: ';
  l_found := false;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'p_user_name = ' || p_user_name);
  end if;

  open cur_fnd_users;
  fetch cur_fnd_users into l_apps_user_key.user_id, l_apps_user_key.user_name
    , l_apps_user_key.user_guid, l_apps_user_key.person_party_id;
  l_found := cur_fnd_users%found;

  if (not l_found)
  then
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
	    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
                ,'User not found: ' || p_user_name);
     end if;
    l_apps_user_key.user_guid := null;
    l_apps_user_key.user_id := null;
    l_apps_user_key.user_name := null;
    l_apps_user_key.person_party_id := null;
  else
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
	    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
                ,'User found: user_guid: '||l_apps_user_key.user_guid ||
		 ' user_name: '||l_apps_user_key.user_name);
    end if;
  end if;
  close cur_fnd_users;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return (l_apps_user_key);

exception
  when others then
    if (cur_fnd_users%isopen)
    then
      close cur_fnd_users;
    end if;

    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;

    raise;
    return null;
end get_fnd_user;
--
-------------------------------------------------------------------------------
function isUserEnabled(p_ldap_attr_list in ldap_attr_list) return boolean is

l_module_source varchar2(256);
l_user_enabled boolean;
l_inactive_start boolean;
l_inactive_end boolean;
l_start_date date;
l_start_date_oid_tz date;
l_end_date date;
l_end_date_oid_tz date;
begin

  l_module_source := G_MODULE_SOURCE || 'isUserEnabled: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;
   --default l_user_enable to true, if OID does not pass OrclisEnabled, we will synch the user.
  l_user_enabled := true;
  l_inactive_start := false;
  l_inactive_end := false;

  if (p_ldap_attr_list is not null AND p_ldap_attr_list.count > 0) then
    for j in p_ldap_attr_list.first .. p_ldap_attr_list.last loop
       if(upper(p_ldap_attr_list(j).attr_name) = G_ORCLISENABLED) then
	  if(p_ldap_attr_list(j).attr_value = G_DISABLED) then
             l_user_enabled := false;
             fnd_message.set_name ('FND', 'FND_SSO_USER_DISABLED');

             if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
                fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
	          'OrclisuserEnabled: Disabled');
             end if;
	  end if;
       end if;
       -- if start greater than sysdate or end date less than equal sysdate
       -- user is disabled.

       if(upper(p_ldap_attr_list(j).attr_name) = G_ORCLACTIVESTARTDATE) then

	  if(p_ldap_attr_list(j).attr_value is not null) then

             l_start_date_oid_tz := to_date(substr(p_ldap_attr_list(j).attr_value,1,14),G_YYYYMMDDHH24MISS);

             if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)  then
                 fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
	           'Start date in OID time zone:: '||to_char(l_start_date_oid_tz, 'YYYY-MM-DD HH:MI:SS PM'));
             end if;

             l_start_date := fnd_timezones_pvt.adjust_datetime(l_start_date_oid_tz, 'GMT', fnd_timezones.get_server_timezone_code);

             if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
                 fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
	           'Start date in Ebiz time zone:: '||to_char(l_start_date, 'YYYY-MM-DD HH:MI:SS PM'));
             end if;


             if(l_start_date > sysdate) then
                 l_inactive_start := true;
                 fnd_message.set_name ('FND', 'FND_SSO_USER_FUTURE_DATE');

                 if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)  then
                    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'OrclActive start date, greater than sysdate');
                 end if;
             end if;

/* start date = null, is still a valid user */
/*        else
 *	 -- start date is null which is not a valid user
 *	 l_inactive_start := true;
 *	 fnd_message.set_name ('FND', 'FND_SSO_USER_DISABLED');*/

	  end if;
       end if;

       if(upper(p_ldap_attr_list(j).attr_name) = G_ORCLACTIVEENDDATE) then

         if(p_ldap_attr_list(j).attr_value is not null) then

	   l_end_date_oid_tz := to_date(substr(p_ldap_attr_list(j).attr_value,1,14),G_YYYYMMDDHH24MISS);
	   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
               fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
	         'End date in OID time zone:: '||to_char(l_end_date_oid_tz, 'YYYY-MM-DD HH:MI:SS PM'));
           end if;

           l_end_date := fnd_timezones_pvt.adjust_datetime(l_end_date_oid_tz,
                           'GMT',
                           fnd_timezones.get_server_timezone_code);
	   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
               fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
	     'End date in Ebiz time zone:: '||to_char(l_end_date, 'YYYY-MM-DD HH:MI:SS PM'));
           end if;

	   if(l_end_date < sysdate) then
               l_inactive_end := true;
               fnd_message.set_name ('FND', 'FND_SSO_USER_END_DATE');
               if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
                   fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
	                 'OrclActive end date, less than sysdate');
               end if;
	   end if;

         end if;
       end if;

    end loop;

  else

    -- parameter list not passed cannot figure user enabled or disabled.
    if (fnd_log.LEVEL_EVENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)then
        fnd_log.string(fnd_log.LEVEL_EVENT, l_module_source
                 , 'Parameter list not passed in event from OID cannot process further.');
    end if;
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END->false');
    end if;
    return false;

  end if;

   -- return false if l_user_enabled is false or L_inactive_start is true or l_inactive_end is true.

  if( not l_user_enabled or l_inactive_start or l_inactive_end) then
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Return false, user is disabled');
    end if;
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END->false');
    end if;
    return false;
  else
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
             fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Return true, user is enabled');
    end if;
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END->true');
  end if;
  return true;


end isUserEnabled;
--
-------------------------------------------------------------------------------
procedure process_identity_add(p_event in ldap_event) is

  l_module_source varchar2(256);
  l_ldap_attr_list  ldap_attr_list;
  l_user_name       fnd_user.user_name%type;
  my_ent_type       varchar2(50);
  my_parms          wf_parameter_list_t;
  l_allow_identity_add  varchar2(1);
  l_profile_defined     boolean;
  l_user_enabled        boolean;
  l_prov_disabled_user  varchar2(10);
  l_prov_filter_defined boolean;

begin
  l_module_source := G_MODULE_SOURCE || 'process_identity_add: ';
  l_ldap_attr_list := get_user_attributes(p_event.object_guid, l_user_name);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'Begin');
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'p_event = ' || get_ldap_event_str(p_event));
  end if;

  --check for OrclIsEnabled flag and stop further processing
  -- bug fix for bug #4583452

  -- Bug 12907365: Providing a profile to indicate whether to create disabled
  -- users that are provisioned from LDAP.
   fnd_profile.get_specific(name_z => 'APPS_SSO_PROV_DISABLED_LDAPUSR',
                            val_z => l_prov_disabled_user,
                            defined_z => l_prov_filter_defined);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Getting profile to determine if disabled users should be created.  APPS_SSO_PROV_DISABLED_LDAPUSR: '|| l_prov_disabled_user);
  end if;


 if ((l_prov_filter_defined and l_prov_disabled_user = 'Y') OR isUserEnabled (p_event.attr_list))
 then

  --RDESPOTO, Add IDENTITY_ADD, 11/09/2004
  --Check site profile APPS_SSO_OID_IDENTITY
  fnd_profile.get_specific(
      name_z      => 'APPS_SSO_OID_IDENTITY',
      user_id_z   => null,
      val_z       => l_allow_identity_add,
      defined_z   => l_profile_defined);
    -- Check whether profile is defined
    -- We don't receive IDENTITY_ADD events when application is registered
    if (l_profile_defined and l_allow_identity_add = 'Y') then
    -- Raise oracle.apps.identity.add
    wf_event.AddParameterToList('CHANGE_SOURCE', G_OID, my_parms);
    wf_event.AddParameterToList('ORCLGUID', p_event.object_guid, my_parms);
    wf_event.AddParameterToList('CHANGE_TYPE', G_LOAD, my_parms);
    save_to_cache(
      p_ldap_attr_list    => l_ldap_attr_list
    , p_entity_type       => wf_oid.IDENTITY_ADD
    , p_entity_key_value  => l_user_name);
    wf_event.raise('oracle.apps.fnd.identity.add',
    upper(l_user_name), null, my_parms);
    -- Raise SUBSCRIPTION_ADD
    send_subscription_add_to_OID
     (p_orcl_guid => p_event.object_guid);

  else
    if (fnd_log.LEVEL_EVENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
       fnd_log.string(fnd_log.LEVEL_EVENT, l_module_source
           , 'APPS_SSO_OID_IDENTITY profile is Disabled.');
    end if;

  end if;


 else

 -- user is disabled do not synch. log it
  if (fnd_log.LEVEL_EVENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_EVENT, l_module_source
      , 'Orclisenabled is Disabled. so stopping further processing');
  end if;

 end if; --user is disabled

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'End');
  end if;

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;

    raise;
end process_identity_add;
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
procedure process_identity_modify(p_event in ldap_event) is

  cursor cur_fnd_users(p_user_guid in varchar2) is
    select user_name, user_id
      from fnd_user
     where user_guid = hextoraw(p_user_guid);

  l_module_source varchar2(256);
  l_profiles      apps_sso_user_profiles_type;
  l_user_name     fnd_user.user_name%type;
  l_oid_user_name       fnd_user.user_name%type;
  l_user_id       fnd_user.user_id%type;
  l_ldap_attr_list  ldap_attr_list;
  l_count pls_integer:= 0;

begin
  l_module_source := G_MODULE_SOURCE || 'process_identity_modify: ';
  l_ldap_attr_list := get_user_attributes(p_event.object_guid, l_oid_user_name);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'Begin');
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'p_event = ' || get_ldap_event_str(p_event));
  end if;


  open cur_fnd_users(p_event.object_guid);
  loop
    fetch cur_fnd_users into l_user_name, l_user_id;
    exit when cur_fnd_users%notfound;
    l_count := l_count+1;

    l_profiles := fnd_ldap_mapper.map_sso_user_profiles(l_user_name);
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
         , 'username:'||l_user_name||' LDAP_SYNC:'||l_profiles.ldap_sync||'
login_type:'||l_profiles.local_login );
    end if;

    if ( (l_profiles.ldap_sync = G_Y)
      and (l_profiles.local_login <> G_LOCAL) )
    then
      --For AOl/J consumption
      wf_entity_mgr.put_attribute_value(G_USER, l_user_name,
        G_ORCLGUID, p_event.object_guid);
      -- Bug 20047631
      -- p_ldap_attr_list => p_event.attr_list was changed to l_ldap_attr_list
      -- p_event.attr_list carries only the modified user attribute which was
      -- causing the other attributes to be missing from the cache incase of
      -- a WF attribute cache purge.
      save_to_cache(
          p_ldap_attr_list    => l_ldap_attr_list
        , p_entity_type       => G_USER
        , p_entity_key_value  => l_user_name);
      wf_entity_mgr.process_changes(G_USER, l_user_name, G_OID);
      --For our consumption so that only we update TCA tables
      save_to_cache(
       p_ldap_attr_list    => l_ldap_attr_list
      , p_entity_type       => wf_oid.IDENTITY_MODIFY
      , p_entity_key_value  => l_user_name);
      wf_event.raise('oracle.apps.fnd.identity.modify',
        upper(l_user_name), null, null);

    end if;
  end loop;
  close cur_fnd_users;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
         , 'events risen:'||l_count);
  END IF;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
      , 'End');
  end if;

exception
  when others then
    if (cur_fnd_users%isopen)
    then
      close cur_fnd_users;
    end if;

    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;

    raise;
end process_identity_modify;
--
--
-------------------------------------------------------------------------------
procedure process_identity_delete(p_event in ldap_event) is

  cursor cur_fnd_users(p_user_guid in varchar2) is
    select user_name, user_id
      from  fnd_user
     where  user_guid = hextoraw(p_user_guid);

  l_module_source varchar2(256);
  l_profiles      apps_sso_user_profiles_type;
  l_user_name     fnd_user.user_name%type;
  l_user_id       fnd_user.user_id%type;
  my_parms        wf_parameter_list_t;

begin
  l_module_source := G_MODULE_SOURCE || 'process_identity_delete: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'Begin');
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'p_event = ' || get_ldap_event_str(p_event));
  end if;

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Get users');
  end if;

  open cur_fnd_users(p_event.object_guid);
  loop
    fetch cur_fnd_users into l_user_name, l_user_id;
    exit when cur_fnd_users%notfound;

    -- Bug 14469422: Unlink all users with same user_guid.
    update fnd_user
      set   user_guid = null
      where user_name = l_user_name;

    l_profiles := fnd_ldap_mapper.map_sso_user_profiles(l_user_name);

    /* Bug 14469422 - remove ldap_sync profile as a condition for raising the delete event */
    if (l_profiles.local_login <> G_LOCAL)
    then
      /*wf_entity_mgr.put_attribute_value(G_USER, l_user_name,
        G_CACHE_CHANGED, G_YES);
      -- Fix bug 4231145
      wf_entity_mgr.put_attribute_value(G_USER, l_user_name,
        G_ORCLGUID, p_event.object_guid);
      wf_entity_mgr.process_changes(G_USER, l_user_name,
        G_OID, G_DELETE);
        */

  /* Bug 13829710 - Raise the oracle.apps.fnd.identity.delete event so that
   * administrators can add custom subscription
   */

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Raise identity_delete event for user: '||l_user_name);
   end if;

    wf_entity_mgr.put_attribute_value(G_USER,l_user_name,G_CACHE_CHANGED,G_YES);
    wf_event.AddParameterToList('CHANGE_SOURCE', G_OID, my_parms);
    wf_event.AddParameterToList('ORCLGUID', p_event.object_guid, my_parms);
    wf_event.AddParameterToList('CHANGE_TYPE', G_DELETE, my_parms);

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'added parameters');
   end if;

     save_to_cache(
       p_ldap_attr_list    => p_event.attr_list
      , p_entity_type       => wf_oid.IDENTITY_DELETE
      , p_entity_key_value  => l_user_name);

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'saved to cache...now raise event');
   end if;

    wf_event.raise('oracle.apps.fnd.identity.delete', upper(l_user_name), null, null);

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Unlink user');
   end if;

      -- don't call fnd_user_pkg.DisableUser(), it'd fail because user is deleted on OID

      -- Bug 13829710: Moved the end dating of the user to the fnd_oid_subscriptions.identity_delete

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Successfully unlinked user and raised event');
  end if;

    end if;
  end loop;
  close cur_fnd_users;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'End');
  end if;

exception
  when others then
    if (cur_fnd_users%isopen)
    then
      close cur_fnd_users;
    end if;

    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;

    raise;
end process_identity_delete;
--
-------------------------------------------------------------------------------
procedure process_subscription_add(p_event in ldap_event) is

  l_module_source   varchar2(256);
  l_ldap_attr_list  ldap_attr_list;
  l_user_name       fnd_user.user_name%type;
  my_ent_type       varchar2(50);
  my_parms          wf_parameter_list_t;
  l_prov_disabled_user  varchar2(10);
  l_prov_filter_defined boolean;
begin
  l_module_source := G_MODULE_SOURCE || 'process_subscription_add: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'Begin');
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'p_event = ' || get_ldap_event_str(p_event));
  end if;


  l_ldap_attr_list := get_user_attributes(p_event.object_guid, l_user_name);

  -- Bug 12907365: Providing a profile to indicate whether to create disabled
  -- users that are provisioned from LDAP.
  fnd_profile.get_specific(name_z => 'APPS_SSO_PROV_DISABLED_LDAPUSR',
                           val_z => l_prov_disabled_user,
                           defined_z => l_prov_filter_defined);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Getting profile to determine if disabled users should be created.  APPS_SSO_PROV_DISABLED_LDAPUSR: '|| l_prov_disabled_user);
  end if;


 if ((l_prov_filter_defined and l_prov_disabled_user = 'Y') OR isUserEnabled(l_ldap_attr_list)) then
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User is enabled or profile is set - process subscription_add');
    end if;

-- Moving it out since we need the orclisenabled
--  l_ldap_attr_list := get_user_attributes(p_event.object_guid, l_user_name);
  wf_entity_mgr.put_attribute_value(wf_oid.SUBSCRIPTION_ADD, l_user_name,
    G_CACHE_CHANGED, G_YES);

  save_to_cache(
      p_ldap_attr_list    => l_ldap_attr_list
    , p_entity_type       => wf_oid.SUBSCRIPTION_ADD
    , p_entity_key_value  => l_user_name);
  my_ent_type := upper(wf_oid.SUBSCRIPTION_ADD);
  wf_entity_mgr.put_attribute_value(my_ent_type, l_user_name,
                                     'CACHE_CHANGED', 'NO');
  wf_event.AddParameterToList('CHANGE_SOURCE', G_OID, my_parms);
  wf_event.AddParameterToList('ORCLGUID', p_event.object_guid, my_parms);
  wf_event.AddParameterToList('CHANGE_TYPE', G_LOAD, my_parms);
  wf_event.raise('oracle.apps.fnd.subscription.add',
    upper(l_user_name), null, my_parms);

else

 if (fnd_log.LEVEL_EVENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_EVENT, l_module_source
      , 'Disabled users are not replicated - Orcluserenabled is disabled');
  end if;

end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'End');
  end if;



exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;

    raise;
end process_subscription_add;
--
-------------------------------------------------------------------------------
procedure process_subscription_delete(p_event in ldap_event) is

  l_module_source varchar2(256);

begin
  l_module_source := G_MODULE_SOURCE || 'process_subscription_delete: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'Begin');
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'p_event = ' || get_ldap_event_str(p_event));
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'End');
  end if;

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;

    raise;
end process_subscription_delete;
--
-------------------------------------------------------------------------------
procedure synch_user_from_LDAP(
  p_user_name   in  fnd_user.user_name%type
, p_result out nocopy pls_integer
) is
  l_module_source     varchar2(256);
  l_apps_user_key     apps_user_key_type;
  l_user_name         fnd_user.user_name%type;
  l_ldap_attr_list  ldap_attr_list;
  l_ldap_message    fnd_oid_util.ldap_message_type;
  l_return_status      varchar2(1);

  PRAGMA AUTONOMOUS_TRANSACTION;
begin
  l_module_source := G_MODULE_SOURCE || 'synch_user_from_LDAP: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  if(p_user_name is null)
    then
      raise user_name_null_exp;
  end if;

  l_user_name := p_user_name;
  l_apps_user_key := fnd_oid_util.get_fnd_user(p_user_name => l_user_name);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
     'l_user_name:'||l_user_name);
  end if;


  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
        'Trying to get ldap attribute list for GUID: '||l_apps_user_key.user_guid||'::');
  end if;


  if(l_apps_user_key.user_guid is null)
    then
      raise user_guid_null_exp;
  end if;

  l_ldap_attr_list := fnd_oid_util.get_user_attributes(p_userguid  => l_apps_user_key.user_guid,
                                 p_user_name => l_user_name);
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
   fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
        'Got the ldap attribute list');
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
     'Before calling map_ldap_message: l_user_name:'||l_user_name||' p_user_name:'||p_user_name||
	' from l_apps_user_key:'||l_apps_user_key.user_name);
  end if;

  fnd_ldap_mapper.map_ldap_message(p_user_name      => p_user_name
                              , p_ldap_attr_list => l_ldap_attr_list
                              , p_ldap_message   => l_ldap_message);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
        'Got the ldap message ldap_message object name::'||l_ldap_message.object_name||'::');
  end if;

  if (l_apps_user_key.person_party_id is not null)
   then
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
        'Person Party exists in FND_USER for user:'||l_apps_user_key.user_name);
     end if;
     fnd_oid_users.hz_update(
        p_ldap_message  => l_ldap_message
      , x_return_status => l_return_status);

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
       then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
          'after hz_update return Status: '||l_return_status);
      end if;
    else
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
        'Person Party does NOT exist in FND_USER for user:'||l_apps_user_key.user_name||', creating a new TCA entry');
     end if;
   if (isTCAenabled('ADD')) then
     fnd_oid_users.hz_create(
        p_ldap_message  => l_ldap_message
      , x_return_status => l_return_status);
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
        'after hz_create return Status: '||l_return_status);
     end if;
    end if;
  end if;
    commit;
    if(l_return_status = FND_API.G_RET_STS_SUCCESS)
	then
	  p_result := fnd_ldap_wrapper.G_SUCCESS;
    else
	  p_result := fnd_ldap_wrapper.G_FAILURE;
    end if;

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
   end if;

exception
  when user_name_null_exp then
    rollback;
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source
        , 'Cannot call synch_user_from_LDAP will null username');
    end if;
    p_result := fnd_ldap_wrapper.G_FAILURE;
  when user_guid_null_exp then
    rollback;
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source
        , 'call to synch_user_from_LDAP failed since GUID is NULL');
    end if;
    p_result := fnd_ldap_wrapper.G_FAILURE;
  when others then
    rollback;
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    raise;
    p_result := fnd_ldap_wrapper.G_FAILURE;
end synch_user_from_LDAP;
--
-------------------------------------------------------------------------------
procedure synch_user_from_LDAP_NO_AUTO(
  p_user_name   in  fnd_user.user_name%type
, p_result out nocopy pls_integer
) is
  l_module_source     varchar2(256);
  l_apps_user_key     apps_user_key_type;
  l_user_name         fnd_user.user_name%type;
  l_ldap_attr_list  ldap_attr_list;
  l_ldap_message    fnd_oid_util.ldap_message_type;
  l_return_status      varchar2(1);
begin
  l_module_source := G_MODULE_SOURCE || 'synch_user_from_LDAP_NO_AUTO: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  if(p_user_name is null)
    then
      raise user_name_null_exp;
  end if;

  l_user_name := p_user_name;
  l_apps_user_key := fnd_oid_util.get_fnd_user(p_user_name => l_user_name);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
     'l_user_name:'||l_user_name);
   end if;


  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
        'Trying to get ldap attribute list for GUID: '||l_apps_user_key.user_guid||'::');
  end if;


  if(l_apps_user_key.user_guid is null)
    then
      raise user_guid_null_exp;
  end if;

    l_ldap_attr_list := fnd_oid_util.get_user_attributes(p_userguid  => l_apps_user_key.user_guid,
                                  p_user_name => l_user_name);
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
	'Got the ldap attribute list');
    end if;

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
	'Before calling map_ldap_message: l_user_name:'||l_user_name||' p_user_name:'||p_user_name||
	' from l_apps_user_key:'||l_apps_user_key.user_name);
    end if;

    fnd_ldap_mapper.map_ldap_message(p_user_name      => p_user_name
                              , p_ldap_attr_list => l_ldap_attr_list
                              , p_ldap_message   => l_ldap_message);

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
        'Got the ldap message ldap_message object name::'||l_ldap_message.object_name||'::');
    end if;

     if (l_apps_user_key.person_party_id is not null)
     then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
       then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
         'Person Party exists in FND_USER for user:'||l_apps_user_key.user_name);
      end if;
      fnd_oid_users.hz_update(
        p_ldap_message  => l_ldap_message
      , x_return_status => l_return_status);

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
       then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
          'after hz_update return Status: '||l_return_status);
      end if;
    else
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
        'Person Party does NOT exist in FND_USER for user:'||l_apps_user_key.user_name||', creating a new TCA entry');
     end if;
     if (isTCAenabled('ADD')) then
     fnd_oid_users.hz_create(
        p_ldap_message  => l_ldap_message
      , x_return_status => l_return_status);
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
        'after hz_create return Status: '||l_return_status);
     end if;
    end if;
   end if;
    if(l_return_status = FND_API.G_RET_STS_SUCCESS)
	then
	  p_result := fnd_ldap_wrapper.G_SUCCESS;
    else
	  p_result := fnd_ldap_wrapper.G_FAILURE;
    end if;

 if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
 end if;

exception
  when user_name_null_exp then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source
        , 'Cannot call synch_user_from_LDAP will null username');
    end if;
    p_result := fnd_ldap_wrapper.G_FAILURE;
  when user_guid_null_exp then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source
        , 'call to synch_user_from_LDAP failed since GUID is NULL');
    end if;
    p_result := fnd_ldap_wrapper.G_FAILURE;
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    raise;
    p_result := fnd_ldap_wrapper.G_FAILURE;
end synch_user_from_LDAP_NO_AUTO;
--
-------------------------------------------------------------------------------
procedure on_demand_user_create(
  p_user_name   in  varchar2,
  p_user_guid   in  varchar2
) is

  cursor cur_fnd_users is
    select user_id, start_date, end_date, encrypted_user_password
      from fnd_user
     where user_name = p_user_name
       and (user_guid is NULL or user_guid = hextoraw(p_user_guid))
       and sysdate >= start_date
       and (end_date is NULL or end_date > sysdate);

  l_module_source     varchar2(256);
  l_event_name        varchar2(80);
  l_parmeter_list     wf_parameter_list_t;
  l_result            pls_integer;
  l_sub_add_result            pls_integer;
  l_ldap_attr_list    ldap_attr_list;
  l_ldap_message      ldap_message_type;
  l_user_name         fnd_user.user_name%type;
  l_rec               cur_fnd_users%rowtype;
  l_found	      boolean;
  l_local_login       varchar2(10);
  l_profile_defined   boolean;
  l_user_id           number;
begin
  -- Make sure the event is seeded and downloaded
  l_module_source := G_MODULE_SOURCE || 'on_demand_user_create: ';
  l_event_name := 'oracle.apps.fnd.ondemand.create';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  if(p_user_name is null or p_user_guid is null)
    then
      raise user_name_null_exp;
  end if;
 if(p_user_guid is null)
    then
      raise user_guid_null_exp;
  end if;


  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
    'Before calling get_user_attributes username: '||p_user_name||' GUID: '||p_user_guid);
  end if;
  l_user_name := p_user_name;

-- Adding the following login for updating FAX and Email from OID when users are creared onDemand
-- Refer to Bug 4411170
  l_ldap_attr_list := fnd_oid_util.get_user_attributes(p_userguid => p_user_guid,
                                                      p_user_name => l_user_name);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Got ldap_attr_list');
  end if;

  fnd_ldap_mapper.map_ldap_message(p_user_name      => l_user_name
                              , p_ldap_attr_list => l_ldap_attr_list
                              , p_ldap_message   => l_ldap_message);


  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'After calling map_ldap_message');
  end if;

 open cur_fnd_users;
 fetch cur_fnd_users into l_rec;
 l_found := cur_fnd_users%found;
 close cur_fnd_users;

 if (l_found)
  then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
	then
	   fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Found a linakble user: ');
      end if;

      fnd_profile.get_specific(name_z => G_APPS_SSO_LOCAL_LOGIN,
                               user_id_z => l_rec.user_id,
                               val_z => l_local_login,
                               defined_z => l_profile_defined);
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'APPS_SSO_LOCAL_LOGIN: '||l_local_login);
      end if;
     if(l_local_login <>G_LOCAL)
     then
       if(l_local_login = G_SSO)
       then
	     fnd_user_pkg.UpdateUser(
  	        x_user_name=>p_user_name
   	      , x_owner=>null
              , x_unencrypted_password=>fnd_web_sec.EXTERNAL_PWD
   	      , x_email_address => l_ldap_message.mail
  	      , x_fax => l_ldap_message.facsimileTelephoneNumber
  	      , x_user_guid=>p_user_guid
	      , x_change_source =>  fnd_user_pkg.change_source_oid
             );

        else
	     fnd_user_pkg.UpdateUser(
  	        x_user_name=>p_user_name
   	      , x_owner=>null
   	      , x_email_address => l_ldap_message.mail
  	      , x_fax => l_ldap_message.facsimileTelephoneNumber
  	      , x_user_guid=>p_user_guid
	      , x_change_source =>  fnd_user_pkg.change_source_oid
             );
       end if;
     end if;
  else
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
	then
	   fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Could not find a linkable user: ');
     end if;
    -- Changed to CreateUserId - we need the user_id to set the profile.
     l_user_id := fnd_user_pkg.CreateUserId(
	           x_user_name=>p_user_name
	         , x_owner=>null
	         , x_unencrypted_password=>fnd_web_sec.EXTERNAL_PWD
	         , x_email_address => l_ldap_message.mail
	         , x_fax => l_ldap_message.facsimileTelephoneNumber
	         , x_user_guid=>p_user_guid
		 , x_change_source =>  fnd_user_pkg.change_source_oid
                );

    -- Bug 4880490 New users should have the local login profile set to SSO
    l_found := fnd_profile.save(x_name => 'APPS_SSO_LOCAL_LOGIN'
                     , x_value => 'SSO'
                     , x_level_name => 'USER'
                     , x_level_value => l_user_id);
    if not l_found then
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
             fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,
             'Unable to set APPS_SSO_LOCAL_LOGIN profile value to SSO for user ' || p_user_name);
      end if;
    end if;

  end if;


 if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
    'After calling CreateUser or UpdateUser username: '||p_user_name||' GUID: '||p_user_guid);
  end if;

-- send_subscription_add_to_OID(p_orcl_guid=>p_user_guid);
   add_user_to_OID_sub_list(p_orclguid => p_user_guid, x_result   => l_sub_add_result);


  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'After calling send_subscription_add_to_OID '||
      'to send the subscription to OID');
  end if;
  wf_event.AddParameterToList('ORCLGUID', p_user_guid, l_parmeter_list);
  wf_event.AddParameterToList('USER_NAME', p_user_name, l_parmeter_list);
  wf_event.raise(l_event_name, p_user_name, null, l_parmeter_list);

  -- Create a subscription that will add the preferences responsiblity
  -- See fnd_oid_subscriptions.assign_default_resp

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

exception
  when user_guid_null_exp then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source
        , 'Cannot call on_demand_user_create will null GUID');
    end if;
    if (cur_fnd_users%isopen)
    then
      close cur_fnd_users;
    end if;
    raise;

  when user_name_null_exp then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source
        , 'Cannot call on_demand_user_create will null username');
    end if;
    if (cur_fnd_users%isopen)
    then
      close cur_fnd_users;
    end if;
    raise;

  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    if (cur_fnd_users%isopen)
    then
      close cur_fnd_users;
    end if;

    raise;
end on_demand_user_create;
--
-------------------------------------------------------------------------------
procedure process_no_success_event(p_event_status in ldap_event_status) is

  l_module_source       varchar2(256);
  l_entity_key_value    wf_entity_changes.entity_key_value%type;
  l_event_name          varchar2(80);
  my_ent_type           varchar2(50);
  my_parms              wf_parameter_list_t;

begin
  l_module_source := G_MODULE_SOURCE || 'process_no_success_event: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  if (p_event_status.error_disposition = wf_oid.EVENT_ERROR)
  then
    l_event_name := 'oracle.apps.fnd.oidsync.error';

  elsif (p_event_status.error_disposition = wf_oid.EVENT_RESEND)
  then
    l_event_name := 'oracle.apps.fnd.oidsync.resend';
  end if;
  -- Get the fnd_user.user_name
  fnd_oid_util.get_entity_key_value(p_event_status.event_id
    , l_entity_key_value);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
      'p_event_status.error_disposition = ' ||
        p_event_status.error_disposition ||
      ', l_entity_key_value = ' || l_entity_key_value ||
      ', l_event_name = ' || l_event_name);
  end if;
  --RDESPOTO, 09/02/2004, add ENTITY_ID parameter
  --similar to wf_entity_mgr.process_changes()
  if (fnd_log.LEVEL_EVENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_EVENT, l_module_source, 'About to '
     || 'raise event ' || l_event_name || ' with the following '
     ||  'parameters: CACHE_CHANGED=NO, CHANGE_SOURCE=' || G_OID ||
     ', CHANGE_TYPE=' ||  G_LOAD || ', ORCLGUID=' || p_event_status.orclguid ||
     ', USER_NAME=' || l_entity_key_value || ', ENTITY_ID=' || p_event_status.event_id);
  end if;
  my_ent_type := upper(p_event_status.error_disposition);
  wf_entity_mgr.put_attribute_value(my_ent_type, l_entity_key_value,
                                     'CACHE_CHANGED', 'NO');
  wf_event.AddParameterToList('CHANGE_SOURCE', G_OID, my_parms);
  wf_event.AddParameterToList('CHANGE_TYPE', G_LOAD, my_parms);
  wf_event.AddParameterToList('ORCLGUID', p_event_status.orclguid, my_parms);
  wf_event.AddParameterToList('USER_NAME', l_entity_key_value, my_parms);
  wf_event.AddParameterToList('ENTITY_ID', p_event_status.event_id, my_parms);
  wf_event.raise(l_event_name, upper(l_entity_key_value), null, my_parms);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    raise;
end process_no_success_event;
--
-------------------------------------------------------------------------------
procedure save_to_cache(
    p_ldap_attr_list    in  ldap_attr_list
  , p_entity_type       in  varchar2
  , p_entity_key_value  in  varchar2
) is

  l_module_source varchar2(256);

begin
  l_module_source := G_MODULE_SOURCE || 'save_to_cache: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'Begin');
  end if;

  if (p_ldap_attr_list is not null AND p_ldap_attr_list.count > 0)
  then
    for j in p_ldap_attr_list.first .. p_ldap_attr_list.last
    loop

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
          , 'p_ldap_attr_list(' || j || ') = ' ||
          get_ldap_attr_str(p_ldap_attr_list(j)));
      end if;

      if ((upper(p_ldap_attr_list(j).attr_name) <> G_USERPASSWORD)
       --  AND (upper(p_ldap_attr_list(j).attr_name) <> G_ORCLISENABLED)
        AND (upper(p_ldap_attr_list(j).attr_name) <> G_OBJECTCLASS))
      then
        wf_entity_mgr.put_attribute_value(p_entity_type, p_entity_key_value,
          p_ldap_attr_list(j).attr_name, p_ldap_attr_list(j).attr_value);
      end if;
    end loop;
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'End');
  end if;

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;

    raise;
end save_to_cache;
--
-------------------------------------------------------------------------------
procedure get_entity_key_value(
    p_event_id          in          wf_entity_changes.entity_id%type
  , p_entity_key_value  out nocopy  wf_entity_changes.entity_key_value%type
) is

  cursor cur_entity_changes is
    select entity_key_value
    from wf_entity_changes
   where entity_id = p_event_id;

  l_module_source varchar2(256);

begin
  l_module_source := G_MODULE_SOURCE || 'get_entity_key_value: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'p_event_id = ' || p_event_id);
  end if;

  open cur_entity_changes;
  fetch cur_entity_changes into p_entity_key_value;
  close cur_entity_changes;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

exception
  when no_data_found then
    if (cur_entity_changes%isopen)
    then
      close cur_entity_changes;
    end if;
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source
        , 'Could not find matching entity for entity_id ' || p_event_id);
    end if;
    raise;

  when others then
    if (cur_entity_changes%isopen)
    then
      close cur_entity_changes;
    end if;

    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    raise;

end get_entity_key_value;
--
-------------------------------------------------------------------------------
function get_key return varchar2 is

  l_module_source varchar2(256);
  my_ident        varchar2(256);
  retval          pls_integer;
  my_session      dbms_ldap.session;
  my_results      dbms_ldap.message;
  my_attrs        dbms_ldap.string_collection;
  my_entry        dbms_ldap.message;
  my_vals         dbms_ldap.string_collection;
  flag            pls_integer;
  my_session_flag boolean := false;
begin
  l_module_source := G_MODULE_SOURCE || 'get_key: ';
  retval := -1;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'key_guid = ' || key_guid);
  end if;

  if (key_guid is null) then
    -- go to OID and get it --
    my_session := fnd_ldap_util.c_get_oid_session(flag);
    my_session_flag := true;
    my_ident := fnd_preference.get('#INTERNAL', 'LDAP_SYNCH', 'USERNAME');
    validate_preference('USERNAME', my_ident);
    my_attrs(1) := 'orclguid';

    /*************
    When available, get key from "orclODIPEncryptedAttrKey" . It will be
    an attribute in the profile. The profile DN is of the form
    "<AppGUID>_<OrgGuid>,cn=provisioning profiles,cn=changelog,cn=oracle
     internet directory".  Instead of 8 byte key , we should then shoot for
     32 byte key.
    *************/

    retval := dbms_ldap.search_s(my_session,
                                 my_ident,
                                 DBMS_LDAP.SCOPE_BASE,
                                 'objectclass=*',
                                 my_attrs,
                                 0, -- retrieve both types AND values
                                 my_results);

    my_entry := dbms_ldap.first_entry(my_session, my_results);
    if (my_entry IS NOT NULL)
    then
      my_vals := dbms_ldap.get_values(my_session, my_entry, 'orclguid');

      if (my_vals.COUNT > 0)
      then
        key_guid := substr(my_vals(my_vals.FIRST),1,8);
      else
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
        then
          fnd_log.string(FND_LOG.LEVEL_STATEMENT, 'get_key',
            'orclguid attribute not found');
        end if;
        key_guid := null;
      end if;

    else
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT, 'get_key',
          'Application Identity '||my_ident||' not found');
      end if;
      key_guid := null;
    end if;

     fnd_ldap_util.c_unbind(my_session,flag);
     my_session_flag := false;
  end if;


  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return key_guid;

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    raise;
    return null;
end get_key;
--
-------------------------------------------------------------------------------
function get_oid_session
  return dbms_ldap.session is

  l_module_source varchar2(256);
  l_retval          pls_integer;
  l_host         varchar2(256);
  l_port         varchar2(256);
  l_user         varchar2(256);
  l_pwd          varchar2(256);
  l_ldap_auth    varchar2(256);
  l_db_wlt_url   varchar2(256);
  l_db_wlt_pwd   varchar2(256);
  l_session      dbms_ldap.session;

begin
  l_module_source := G_MODULE_SOURCE || 'get_oid_session: ';
  -- change it to FAILURE if open_ssl fails, else let the simple_bind_s
  -- go through
  l_retval := dbms_ldap.SUCCESS;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  dbms_ldap.use_exception := TRUE;

  l_host := fnd_preference.get(fnd_ldap_util.G_INTERNAL, fnd_ldap_util.G_LDAP_SYNCH, fnd_ldap_util.G_HOST);
  l_port := fnd_preference.get(fnd_ldap_util.G_INTERNAL, fnd_ldap_util.G_LDAP_SYNCH, fnd_ldap_util.G_PORT);
  l_user := fnd_preference.get(fnd_ldap_util.G_INTERNAL, fnd_ldap_util.G_LDAP_SYNCH, fnd_ldap_util.G_USERNAME);
  l_pwd  := fnd_preference.eget(fnd_ldap_util.G_INTERNAL, fnd_ldap_util.G_LDAP_SYNCH, fnd_ldap_util.G_EPWD, fnd_ldap_util.G_LDAP_PWD);
  l_ldap_auth := fnd_preference.get(fnd_ldap_util.G_INTERNAL, fnd_ldap_util.G_LDAP_SYNCH, fnd_ldap_util.G_DBLDAPAUTHLEVEL);
  l_db_wlt_url := fnd_preference.get(fnd_ldap_util.G_INTERNAL, fnd_ldap_util.G_LDAP_SYNCH, fnd_ldap_util.G_DBWALLETDIR);
  l_db_wlt_pwd := fnd_preference.eget(fnd_ldap_util.G_INTERNAL, fnd_ldap_util.G_LDAP_SYNCH, fnd_ldap_util.G_DBWALLETPASS, fnd_ldap_util.G_LDAP_PWD);

  --Fix bug 4233320, raise both exception and alert when preferences are missing
  validate_OID_preferences (l_host, l_port, l_user, l_pwd);

  l_session := DBMS_LDAP.init(l_host, l_port);

  -- Elan, 04/27/2004, Not disclosing the password - gets saved to the database
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
    , 'l_host = ' || l_host || ', l_port = ' || l_port ||
    ', l_ldap_auth = ' || l_ldap_auth || ', l_db_wlt_url = ' ||
     l_db_wlt_url ||
     ', l_user = ' || l_user || ', l_pwd = ****');
  end if;

  if ( l_ldap_auth > 0 )
  then
    l_retval := dbms_ldap.open_ssl
      (l_session, 'file:'||l_db_wlt_url, l_db_wlt_pwd, l_ldap_auth);
  end if;

  if (l_retval = dbms_ldap.SUCCESS) then
    l_retval := dbms_ldap.simple_bind_s(l_session, l_user, l_pwd);
  else
    fnd_message.set_name ('FND', 'FND_SSO_SSL_ERROR');
    raise_application_error(-20002, 'FND_SSO_SSL_ERROR');
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return l_session;

exception
when dbms_ldap.invalid_session then
  fnd_message.set_name ('FND', 'FND_SSO_INV_SESSION');
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;
when dbms_ldap.invalid_ssl_wallet_loc then
  fnd_message.set_name ('FND', 'FND_SSO_WALLET_LOC');
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;
when dbms_ldap.invalid_ssl_wallet_passwd then
  fnd_message.set_name ('FND', 'FND_SSO_WALLET_PWD');
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;
when dbms_ldap.invalid_ssl_auth_mode then
  fnd_message.set_name ('FND', 'FND_SSO_INV_AUTH_MODE');
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;
when others then
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;
end;
--
-------------------------------------------------------------------------------
function get_entity_changes_rec_str(
  p_entity_changes_rec in wf_entity_changes_rec_type)
  return varchar2 is

  l_module_source varchar2(256);
  l_str           varchar2(4000);

begin
  l_module_source := G_MODULE_SOURCE || 'get_entity_changes_rec_str: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  l_str := 'entity_type: ' || p_entity_changes_rec.entity_type ||
    ', entity_key_value: ' || p_entity_changes_rec.entity_key_value ||
    ', flavor: ' || p_entity_changes_rec.flavor ||
    ', change_date: ' || p_entity_changes_rec.change_date ||
    ', entity_id: ' || p_entity_changes_rec.entity_id ||
    ', change_date_in_char: ' || p_entity_changes_rec.change_date_in_char;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return (l_str);

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    raise;

end get_entity_changes_rec_str;
--
-------------------------------------------------------------------------------
function get_oid_nickname(p_user_guid in fnd_user.user_guid%type)
return varchar2 is

l_module_source   varchar2(256);
result pls_integer;
l_message dbms_ldap.message := null;
l_entry dbms_ldap.message := null;
l_attrs dbms_ldap.string_collection;
subsNode varchar2(1000);
l_nickname_attr  varchar2(256);
l_nickname_value varchar2(2000);
ldapSession dbms_ldap.session;

begin
  l_module_source := G_MODULE_SOURCE || 'get_oid_nickname: ';
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;
  l_nickname_value := FND_LDAP_USER.get_username_from_guid(p_user_guid);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;
  return l_nickname_value;

 exception
   when others then
     l_nickname_value := '';
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Error occured: '
    || sqlcode || ', ' || sqlerrm);
  end if;
  return l_nickname_value;
end get_oid_nickname;

--
-------------------------------------------------------------------------------
function person_party_exists(p_user_name in varchar2)
  return boolean is

  l_module_source varchar2(256);
  l_retval        boolean;
  l_apps_user_key apps_user_key_type;

begin
  l_module_source := G_MODULE_SOURCE || 'person_party_exists: ';
  l_retval := false;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  l_apps_user_key := get_fnd_user(p_user_name => p_user_name);

  if (l_apps_user_key.person_party_id is not null)
  then
    l_retval := true;
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return (l_retval);

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
  return (l_retval);
end person_party_exists;
--
-------------------------------------------------------------------------------
procedure set_ldap_message_attr is

  l_module_source varchar2(256);

begin
  l_module_source := G_MODULE_SOURCE || 'set_ldap_message_attr: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  G_LDAP_MESSAGE_ATTR.object_name := 'OBJECT_NAME';
  G_LDAP_MESSAGE_ATTR.cn := 'CN';
  G_LDAP_MESSAGE_ATTR.sn := 'SN';
  G_LDAP_MESSAGE_ATTR.userPassword := 'USERPASSWORD';
  G_LDAP_MESSAGE_ATTR.telephoneNumber := 'TELEPHONENUMBER';
  G_LDAP_MESSAGE_ATTR.street := 'STREET';
  G_LDAP_MESSAGE_ATTR.postalCode := 'POSTALCODE';
  G_LDAP_MESSAGE_ATTR.physicalDeliveryOfficeName :=
    'PHYSICALDELIVERYOFFICENAME';
  G_LDAP_MESSAGE_ATTR.st := 'ST';
  G_LDAP_MESSAGE_ATTR.l := 'L';
  G_LDAP_MESSAGE_ATTR.displayName := 'DISPLAYNAME';
  G_LDAP_MESSAGE_ATTR.givenName := 'GIVENNAME';
  G_LDAP_MESSAGE_ATTR.homePhone := 'HOMEPHONE';
  G_LDAP_MESSAGE_ATTR.mail := 'MAIL';
  G_LDAP_MESSAGE_ATTR.c := 'C';
  G_LDAP_MESSAGE_ATTR.facsimileTelephoneNumber := 'FACSIMILETELEPHONENUMBER';
  G_LDAP_MESSAGE_ATTR.description := 'DESCRIPTION';
  G_LDAP_MESSAGE_ATTR.orclisEnabled := 'ORCLISENABLED';
  G_LDAP_MESSAGE_ATTR.orclActiveStartDate := 'ORCLACTIVESTARTDATE';
  G_LDAP_MESSAGE_ATTR.orclActiveEndDate := 'ORCLACTIVEENDDATE';
  G_LDAP_MESSAGE_ATTR.orclGUID := 'ORCLGUID';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
end set_ldap_message_attr;
--
-------------------------------------------------------------------------------
function is_guid_already_subscribed(p_orclguid in
fnd_user.user_guid%type,ldapSession in dbms_ldap.session) return BOOLEAN
is
	l_module_source varchar(256);
	l_attrs dbms_ldap.string_collection;
	subsNode varchar2(1000);
	l_message1 dbms_ldap.message := null;
	l_message2 dbms_ldap.message := null;
	usersDN varchar2(1000);
	l_result pls_integer;

	l_result1  BOOLEAN := FALSE;
	l_result2  BOOLEAN := FALSE;

begin
	l_module_source := G_MODULE_SOURCE || 'is_guid_already_subscribed' ;

	subsNode := 'cn=ACCOUNTS,cn=subscription_data,cn=subscriptions,' || fnd_ldap_util.get_orclappname;

	--Search the ldap with orclOwnerGUID attribute filter
	l_result := dbms_ldap.search_s(ld => ldapSession, base => subsNode,
		     scope => dbms_ldap.SCOPE_SUBTREE, filter =>
		     'orclOwnerGUID=' || p_orclguid, attrs => l_attrs, attronly => 0,
		     res => l_message1);

	IF DBMS_LDAP.count_entries(ld => ldapSession, msg => l_message1) > 0 THEN
		l_result1 := TRUE;
		if(fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
			fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'orclOwnerGUID present');
		end if;
	ELSE
		if(fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
                        fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'orclOwnerGUID not present');
                end if;
	END IF;

	--Search the ldap with uniquemember filter
	usersDN := fnd_ldap_util.get_dn_for_guid(p_orclguid => p_orclguid);
	l_result := dbms_ldap.search_s(ld => ldapSession, base => subsNode,
                     scope => dbms_ldap.SCOPE_SUBTREE, filter =>
                     'uniquemember=' || usersDN, attrs => l_attrs,attronly => 0,
                     res => l_message2);

	IF DBMS_LDAP.count_entries(ld => ldapSession, msg => l_message2) > 0 THEN
		l_result2 := TRUE;
                if(fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
                        fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'uniquemember present');
                end if;
	ELSE
		if(fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
                        fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'uniquemember not present');
                end if;
        END IF;

	--If both results have some values means - user subscribed
	--If both results are null means - user NOT subscribed
	--If only one of the results has a value - Data corrupted - throw exception

	if( l_result1 and l_result2 ) then
		return TRUE;
	elsif( (NOT l_result1) and (NOT l_result2) ) then
		return FALSE;
	else
		raise user_subs_data_corrupt_exp;
	end if;
exception
	when user_subs_data_corrupt_exp then
		if(fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
                then
                        fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'Subscription data is corrupt');
                end if;
		raise;
	when others then
		if(fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
		then
			fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    		end if;
		return FALSE;
end;


procedure add_user_to_OID_sub_list(p_orclguid in  fnd_user.user_guid%type, x_result out nocopy pls_integer) is

l_module_source		varchar2(256);
usersDN			varchar2(1000);
subsNode		varchar2(1000);
l_registration		pls_integer;
result			pls_integer;
retval			pls_integer;
ldapSession		dbms_ldap.session;
modArray		dbms_ldap.mod_array;
modmultivalues		dbms_ldap.string_collection;
guid_subscribed		BOOLEAN;
err			varchar2(1000);
session_num             pls_integer;
session_flag             boolean := false;

begin
  l_module_source := G_MODULE_SOURCE || 'add_user_to_OID_sub_list ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
      , 'Begin');
  end if;

	fnd_ldap_wrapper.get_registration(x_registration => l_registration);

	if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'Registration :: '||l_registration);
  end if;

	if (l_registration = FND_LDAP_WRAPPER.G_VALID_REGISTRATION)
		then
			if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
		  then
				fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
		      ,'Valid registration');
			end if;

           -- bug 19912456
 	   ldapSession := fnd_ldap_util.c_get_oid_session(session_num);
           session_flag := TRUE;

			--check if the entry exists in ldap for a particular GUID.If NOT then create the entry.
			guid_subscribed := is_guid_already_subscribed(p_orclguid, ldapSession);

			if guid_subscribed
				then
					if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
					then
						fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'User already subscribed.');
					end if;
					x_result :=  fnd_ldap_util.G_SUCCESS;
   			                fnd_ldap_util.c_unbind(ldapSession,session_num);
                                        session_flag := FALSE;
					return;
			else
				subsNode := 'cn=ACCOUNTS,cn=subscription_data,cn=subscriptions,' || fnd_ldap_util.get_orclappname;

				modArray := dbms_ldap.create_mod_array(num => 1);

				modmultivalues(0) := 'orclServiceSubscriptionDetail';
				dbms_ldap.populate_mod_array(modptr => modArray, mod_op => dbms_ldap.mod_add,
				                           mod_type => 'objectclass', modval => modmultivalues);
				subsNode := 'orclOwnerGUID=' || p_orclguid || ',' || subsNode;
				retval := dbms_ldap.add_s(ld => ldapSession, entrydn => subsNode, modptr => modArray);
			end if;

  		if (retval = dbms_ldap.SUCCESS)
				then
						usersDN := fnd_ldap_util.get_dn_for_guid(p_orclguid => p_orclguid);
						if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
							then
								fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
					      ,'Adding unique member :: '||usersDN);
					  end if;
						modArray := dbms_ldap.create_mod_array(num => 1);
						modmultivalues(0) := usersDN;
						dbms_ldap.populate_mod_array(modptr => modArray,
																				 mod_op => dbms_ldap.mod_add,
																				 mod_type => 'uniquemember',
																				 modval => modmultivalues);
						subsNode := 'cn=ACCOUNTS,cn=subscription_data,cn=subscriptions,' || fnd_ldap_util.get_orclappname;
						retval := dbms_ldap.modify_s(ld => ldapSession, entrydn => subsNode, modptr => modArray);
						if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
						  then
								fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
					      ,'Completed modify');
						end if;

						if (retval = dbms_ldap.SUCCESS)
							then
						    retval := fnd_ldap_util.G_SUCCESS;
						else
							  retval := fnd_ldap_util.G_FAILURE;
						end if;
			else
				retval := fnd_ldap_util.G_FAILURE;
			end if;

			dbms_ldap.free_mod_array(modptr => modArray);

                        -- bug 19912456
   			fnd_ldap_util.c_unbind(ldapSession,session_num);
                        session_flag := FALSE;

	else
		if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
			then
				fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
		      ,'No registration or invalid registration');
	  end if;
		retval := fnd_ldap_util.G_FAILURE;
	end if;

	x_result := retval;
	if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
      , 'End');
  end if;
exception
	when others
		then
			err := sqlerrm;
			if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
				then
			   fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, err);
			end if;

                        -- bug 19912456
                       if (session_flag) then

                          if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
                             fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closing in EXCEPTION BLOCK - START ' );
                          end if;

                          fnd_ldap_util.c_unbind(ldapSession,session_num);
                          session_flag := FALSE;

                          if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
                             fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closed in EXCEPTION BLOCK - END ');
                          end if;
                        end if;

			if (instr(err,'Already exists. Object already exists')>1)
			 then
				if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
			        then
	                           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
				   'User already subscribed');
                                end if;
				x_result :=  fnd_ldap_util.G_SUCCESS;
			else
				raise;
		        end if;

end add_user_to_OID_sub_list;
--
-------------------------------------------------------------------------------
procedure send_subscription_add_to_OID
(p_orcl_guid    fnd_user.user_guid%type)
is
  l_module_source   varchar2(256);
  l_apps_user_key apps_user_key_type;
  l_user_name       fnd_user.user_name%type;
  my_parms          wf_parameter_list_t;
begin
  l_module_source := G_MODULE_SOURCE || 'send_subscription_add_to_OID: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'Begin');
  end if;
  -- Cache attributes are queried in wf_oid.GetAppEvent based on FND user_name
  l_apps_user_key:= get_fnd_user(p_user_guid => p_orcl_guid);
  l_user_name := l_apps_user_key.user_name;
  if (l_user_name is null) then
   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'Cannot send SUBSCRIPTION_ADD to OID because user ' ||
      'does not exist in FND_USER');
      end if;
     return;
  end if;
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'User name for SUBSCRIPTION_ADD is ' || l_user_name);
  end if;
  -- Insert guid only so that SUBSCRIPTION_ADD sends guid to OID
  wf_entity_mgr.put_attribute_value(wf_oid.SUBSCRIPTION_ADD, l_user_name,
    G_CACHE_CHANGED, G_YES);
  wf_entity_mgr.put_attribute_value(wf_oid.SUBSCRIPTION_ADD, l_user_name,
    G_ORCLGUID, p_orcl_guid);
   insert into wf_entity_changes(
    entity_type, entity_key_value, flavor, change_date)
    values(wf_oid.SUBSCRIPTION_ADD, upper(l_user_name), 'FND', sysdate);
  wf_entity_mgr.put_attribute_value(upper(wf_oid.SUBSCRIPTION_ADD), l_user_name,
                                     'CACHE_CHANGED', 'NO');
  commit;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'End');
  end if;

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;

    raise;
end send_subscription_add_to_OID;
--
-------------------------------------------------------------------------------
procedure validate_OID_preferences (
  my_host         varchar2,
  my_port         varchar2,
  my_user         varchar2,
  my_pwd          varchar2
)
is
partial_registration  exception;
l_module_source       varchar2(256);
begin
  l_module_source := G_MODULE_SOURCE || 'validate_OID_preferences: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;
  validate_preference('HOST', my_host);
  validate_preference('PORT', my_port);
  validate_preference('USERNAME', my_user);
  validate_preference('EPWD', my_pwd);
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;
end;
---
---------------------------------------------------------------------

function isTCAEnabled (p_action in varchar2) return boolean IS

l_module_source varchar2(256);
l_status varchar2(10);

begin

 l_module_source := G_MODULE_SOURCE || 'isTCAEnabled: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'Begin');
   end if;


  if (p_action = 'ADD') then
     select status into l_status from wf_event_subscriptions
     where rule_function = 'fnd_oid_subscriptions.hz_identity_add';
  elsif (p_action = 'MODIFY') then
     select status into l_status from wf_event_subscriptions
     where rule_function = 'fnd_oid_subscriptions.hz_identity_modify';
  elsif (p_action = 'DELETE') then
     select status into l_status from wf_event_subscriptions
     where rule_function = 'fnd_oid_subscriptions.hz_identity_delete';
  else
    -- Invalid action return true by default
     l_status := 'ENABLED';
  end if;

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'For action:
'||p_action||' status is: '||l_status );
   end if;


 if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
     fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'END');
 end if;

  if (l_status = 'ENABLED') then
    return TRUE;
  else
    return FALSE;
  end if;


exception
  when no_data_found then
   if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
       fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'Subscription does
not exist for '||p_action);
   end if;

    return false;
  when others then
   if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
       fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
     end if;

    return false;

end;
----------------------------------------------------------------------------------

procedure validate_preference (
  my_preference_name         varchar2,
  my_preference_value        varchar2
)
is
l_module_source       varchar2(256);
begin
  l_module_source := G_MODULE_SOURCE || 'validate_preference: ';
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;
  if my_preference_value is null then
    if(fnd_log.LEVEL_UNEXPECTED >=
      fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_message.SET_NAME('FND', 'FND_SSO_PARTIAL_PREFERENCES');
      fnd_message.SET_TOKEN('PARAMETER', my_preference_name);
      fnd_log.MESSAGE(fnd_log.LEVEL_UNEXPECTED, l_module_source, TRUE);
      fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source,
        my_preference_name || ' parameter is missing in preferences table.');
    end if;
    raise_application_error(-20100, my_preference_name || ' parameter is missing'
    || ' in the E-Business preferences table. Please re-register your application' ||
    ' with Oracle Internet Directory to populate missing parameters."');
  end if;
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;
end;

begin
  set_ldap_message_attr;
end fnd_oid_util;

/

--------------------------------------------------------
--  DDL for Package Body FND_LDAP_MAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_LDAP_MAPPER" as
/* $Header: AFSCOLMB.pls 120.9.12010000.3 2009/04/23 19:33:51 rsantis ship $ */
   G_MODULE_SOURCE  constant varchar2(80) := 'fnd.plsql.oid.fnd_ldap_mapper.';

--
-------------------------------------------------------------------------------
function map_sso_user_profiles(p_user_name in varchar2)
  return fnd_oid_util.apps_sso_user_profiles_type is

  cursor cur_fnd_users is
    select user_id
      from fnd_user
     where user_name = p_user_name;

  l_module_source   varchar2(256);
  l_rec             cur_fnd_users%rowtype;
  l_found           boolean;
  l_val             varchar2(80);
  l_defined         boolean;
  l_user_profiles   fnd_oid_util.apps_sso_user_profiles_type;
  no_such_user_exp  exception;

begin
  l_module_source := G_MODULE_SOURCE || 'map_sso_user_profiles: ';
  l_found := false;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  open cur_fnd_users;
  fetch cur_fnd_users into l_rec;
  l_found := cur_fnd_users%found;
  close cur_fnd_users;

  if (not l_found)
  then
    raise no_such_user_exp;
  end if;

  fnd_profile.get_specific(
      name_z    => fnd_oid_util.G_APPS_SSO_LDAP_SYNC
    , user_id_z => l_rec.user_id
    , val_z     => l_val
    , defined_z => l_defined);

  if (l_defined)
  then
    l_user_profiles.ldap_sync := l_val;
  else
    l_user_profiles.ldap_sync := fnd_oid_util.G_N;
  end if;

  fnd_profile.get_specific(
      name_z   => fnd_oid_util.G_APPS_SSO_LOCAL_LOGIN
    , user_id_z => l_rec.user_id
    , val_z    => l_val
    , defined_z => l_defined);

  if (l_defined)
  then
    l_user_profiles.local_login := l_val;
  else
    l_user_profiles.local_login := fnd_oid_util.G_LOCAL;
  end if;

  --Rada, 01/31/2005, AUTO LINK

  fnd_profile.get_specific(
      name_z   => fnd_oid_util.G_APPS_SSO_AUTO_LINK_USER
    , user_id_z => l_rec.user_id
    , val_z    => l_val
    , defined_z => l_defined);

  if (l_defined)
  then
    l_user_profiles.auto_link := l_val;
  else
    l_user_profiles.auto_link := fnd_oid_util.G_N;
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'l_user_profiles = ldap_sync: ' || l_user_profiles.ldap_sync ||
      ', local_login: ' || l_user_profiles.local_login);
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return (l_user_profiles);

exception
  when no_such_user_exp then
    if (cur_fnd_users%isopen)
    then
      close cur_fnd_users;
    end if;
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source,
        'no_such_user_exp: No matching record for FND_USER.user_name = ' ||
        p_user_name);
    end if;
    raise;
    return null;

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
end map_sso_user_profiles;
--
-------------------------------------------------------------------------------
procedure map_entity_changes_rec(
  p_entity_changes_rec  in out  nocopy  fnd_oid_util.wf_entity_changes_rec_type
) is

  cursor cur_entity_changes is
    select entity_type, entity_key_value, flavor, change_date
           , to_char(change_date, fnd_oid_util.G_YYYYMMDDHH24MISS) change_date_in_char
      from wf_entity_changes
     where entity_id is null
       and change_date <= sysdate
     order by change_date
       for update of entity_id;

  l_module_source varchar2(256);
  l_rec           cur_entity_changes%rowtype;
  l_found         boolean;

begin
  l_module_source := G_MODULE_SOURCE || 'map_entity_changes_rec: ';
  l_found := false;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  open cur_entity_changes;
  fetch cur_entity_changes into l_rec;
  l_found := cur_entity_changes%found;
  if (cur_entity_changes%notfound)
  then
    raise fnd_oid_util.event_not_found_exp;
  end if;

  p_entity_changes_rec.entity_type := l_rec.entity_type;
  p_entity_changes_rec.entity_key_value := l_rec.entity_key_value;
  p_entity_changes_rec.flavor := l_rec.flavor;
  p_entity_changes_rec.change_date := l_rec.change_date;
  p_entity_changes_rec.change_date_in_char := l_rec.change_date_in_char;

  select wf_entity_changes_s.nextval
    into p_entity_changes_rec.entity_id
    from dual;

  update wf_entity_changes
     set entity_id = p_entity_changes_rec.entity_id
   where current of cur_entity_changes;

  close cur_entity_changes;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

exception
  when fnd_oid_util.event_not_found_exp then
    if (cur_entity_changes%isopen)
    then
      close cur_entity_changes;
    end if;

    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source
        , 'No more changes in WF_ENTITY_CHANGES');
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
end map_entity_changes_rec;
--
-------------------------------------------------------------------------------
procedure map_ldap_attr_list(
    p_entity_type       in            wf_attribute_cache.entity_type%type
  , p_entity_key_value  in            wf_attribute_cache.entity_key_value%type
  , p_ldap_key          in out nocopy fnd_oid_util.ldap_key_type
  , p_ldap_attr_list    out    nocopy ldap_attr_list
) is

  cursor cur_attribute_cache is
    select attribute_name
           , attribute_value
           , decode(attribute_value, '*NULL*', 1, 2) attr_mod_op
      from wf_attribute_cache
     where entity_type = p_entity_type
       and entity_key_value = p_entity_key_value
       and attribute_name <> fnd_oid_util.G_CACHE_CHANGED;
 cursor cur_user_guid is
   select user_guid
    from fnd_user
   where user_name = p_entity_key_value;

  l_module_source   varchar2(256);
  l_pwd             varchar2(256);
  l_index           number;
  l_attribute_value varchar2(4000);
  l_ldap_attr       ldap_attr;
  l_start_date      date;
  l_end_date        date;
  l_username_changed boolean;
  l_oid_nickname fnd_user.user_name%type;
  l_old_fnd_username fnd_user.user_name%type;
  l_new_fnd_username fnd_user.user_name%type;
  l_nicknameattr varchar2(256);

begin
  l_module_source := G_MODULE_SOURCE || 'map_ldap_attr_list: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
      , 'p_entity_type = ' || p_entity_type ||
      ', p_entity_key_value = ' || p_entity_key_value);
  end if;

  p_ldap_attr_list := ldap_attr_list();
  l_index := 1;
  l_username_changed := false;
  l_nicknameattr:= upper(fnd_oid_plug.getNickNameAttr(p_entity_key_value));
  for l_rec in cur_attribute_cache
  loop
    if (l_rec.attribute_name = 'OLD_USER_NAME') then
      l_username_changed := true;
      l_old_fnd_username := l_rec.attribute_value;
    end if;

    if (l_rec.attribute_name = 'USER_NAME') then
      l_new_fnd_username := l_rec.attribute_value;
    end if;

    if (l_rec.attribute_name = fnd_oid_util.G_ORCLGUID)
    then
      p_ldap_key.orclGUID := l_rec.attribute_value;

    elsif (l_rec.attribute_name = fnd_oid_util.G_SN)
    then
      p_ldap_key.sn := l_rec.attribute_value;

    elsif (l_rec.attribute_name = fnd_oid_util.G_CN)
    then
      p_ldap_key.cn := l_rec.attribute_value;

    elsif (l_rec.attribute_name = fnd_oid_util.G_ORCLACTIVESTARTDATE)
    then
      l_start_date := to_date(substr(l_rec.attribute_value,1,14), fnd_oid_util.G_YYYYMMDDHH24MISS);
      p_ldap_key.orclActiveStartDate :=
        to_date(substr(l_rec.attribute_value,1,14), fnd_oid_util.G_YYYYMMDDHH24MISS);
    elsif (l_rec.attribute_name = fnd_oid_util.G_ORCLACTIVEENDDATE)
    then
     l_end_date := to_date(substr(l_rec.attribute_value,1,14), fnd_oid_util.G_YYYYMMDDHH24MISS);
     p_ldap_key.orclActiveEndDate :=
        to_date(substr(l_rec.attribute_value,1,14), fnd_oid_util.G_YYYYMMDDHH24MISS);

    elsif (l_rec.attribute_name = fnd_oid_util.G_ORCLISENABLED)
    then
      -- Elan, 18-MAR-2003. Skip the attribute, we'll compute it ourselves
      -- based on start_date and end_date.
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
            , 'Skipping attribute: ' || l_rec.attribute_name ||
            ' - will be computed later with start_date and end_date');
      end if;

    elsif (l_rec.attribute_name = fnd_oid_util.G_USERPASSWORD)
    then
      l_pwd := fnd_web_sec.get_reencrypted_password(
        p_entity_key_value, fnd_oid_util.get_key(), fnd_oid_util.G_OID);

      if (l_pwd is not null
        and l_pwd <> fnd_oid_util.G_INVALID
        and l_pwd <> fnd_oid_util.G_EXTERNAL)
      then
        l_attribute_value := rawtohex(utl_raw.cast_to_raw(l_pwd));
        l_ldap_attr := ldap_attr(
            l_rec.attribute_name
          , l_attribute_value
          , null
          , length(l_attribute_value)
          , wf_oid.ATTR_TYPE_ENCRYPTED_STRING
          , l_rec.attr_mod_op);
        p_ldap_attr_list.extend;
        p_ldap_attr_list(l_index) := l_ldap_attr;
        l_index := l_index + 1;
      end if;

    else
      -- Fix bug 4231203: REMOVE NICKNAME/USER_NAME ATTRIBUTE FROM LDAP ATTRIBUTE LISTS
      -- Handle USER_NAME later

      if (l_rec.attribute_name <> l_nicknameattr
          and l_rec.attribute_name <> 'USER_NAME') then
          l_ldap_attr := ldap_attr(
            l_rec.attribute_name
          , l_rec.attribute_value
          , null
          , length(l_rec.attribute_value)
          , wf_oid.ATTR_TYPE_STRING
          , l_rec.attr_mod_op);
          p_ldap_attr_list.extend;
          p_ldap_attr_list(l_index) := l_ldap_attr;
          l_index := l_index + 1;
     end if;

--      if (l_rec.attribute_name = fnd_oid_util.G_ORCLACTIVESTARTDATE)
--      then
--        l_start_date := to_date(substr(l_rec.attribute_value,1,14), fnd_oid_util.G_YYYYMMDDHH24MISS);
--         null;
--      end if;
--
--      if (l_rec.attribute_name = fnd_oid_util.G_ORCLACTIVEENDDATE)
--      then
--        l_end_date := to_date(substr(l_rec.attribute_value,1,14), fnd_oid_util.G_YYYYMMDDHH24MISS);
--        null;
--      end if;

    end if;

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
        , 'l_ldap_attr(' || (l_index - 1) || ') = ' ||
        fnd_oid_util.get_ldap_attr_str(l_ldap_attr));
    end if;

  end loop;


 if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Computing ORCLISENABLED l_start_date:: '||
    to_char(l_start_date, fnd_oid_util.G_YYYYMMDDHH24MISS) ||' l_end_date:: '||
    to_char(l_end_date, fnd_oid_util.G_YYYYMMDDHH24MISS));
  end if;

  -- Translate start/end dates into orclIsEnabled --
  if ((l_start_date is not null and l_start_date > sysdate)
    or
      (l_end_date is not null and l_end_date <= sysdate))
  then
   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Setting ORCLISENABLED to DISABLED');
   end if;
   p_ldap_key.orclisEnabled := fnd_oid_util.G_DISABLED;
  else
   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Setting ORCLISENABLED to ENABLED');
   end if;
    p_ldap_key.orclisEnabled := fnd_oid_util.G_ENABLED;
  end if;

  l_ldap_attr := ldap_attr(fnd_oid_util.G_ORCLISENABLED
    , p_ldap_key.orclisEnabled
    , null
    , length(p_ldap_key.orclisEnabled), wf_oid.ATTR_TYPE_STRING
    , WF_OID.MOD_REPLACE);
  p_ldap_attr_list.extend;
  p_ldap_attr_list(l_index) := l_ldap_attr;
  l_index := l_index + 1;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
        , 'l_ldap_attr(' || (l_index - 1) || ') = ' ||
        fnd_oid_util.get_ldap_attr_str(l_ldap_attr));
  end if;


-- Is this really new user? Guid in cache may not be up-to-date.
 if (p_ldap_key.orclGUID is null) then
  open cur_user_guid;
  fetch cur_user_guid into p_ldap_key.orclGUID;
  close cur_user_guid;
 end if;

  -- This is a brand new user as far as we know
  -- Sync SN and CN only if IDENTITY_ADD

  if (p_ldap_key.orclGUID is null) then
    l_ldap_attr := ldap_attr(
        fnd_oid_util.G_SN
      , p_ldap_key.sn
      , null
      , length(p_ldap_key.sn)
      , wf_oid.ATTR_TYPE_STRING
      , WF_OID.MOD_REPLACE);

    p_ldap_attr_list.extend;
    p_ldap_attr_list(l_index) := l_ldap_attr;
    l_index := l_index + 1;

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
        , 'l_ldap_attr(' || (l_index - 1) || ') = ' ||
        fnd_oid_util.get_ldap_attr_str(l_ldap_attr));
    end if;
    l_ldap_attr := ldap_attr(
        fnd_oid_util.G_CN
      , p_ldap_key.cn
      , null
      , length(p_ldap_key.cn)
      , wf_oid.ATTR_TYPE_STRING
      , WF_OID.MOD_REPLACE);
    p_ldap_attr_list.extend;
    p_ldap_attr_list(l_index) := l_ldap_attr;
    l_index := l_index + 1;
    --Add USER_NAME if new user
    l_ldap_attr := ldap_attr(
        'USER_NAME'
      , p_ldap_key.cn
      , null
      , length(p_ldap_key.cn)
      , wf_oid.ATTR_TYPE_STRING
      , WF_OID.MOD_REPLACE);
    p_ldap_attr_list.extend;
    p_ldap_attr_list(l_index) := l_ldap_attr;
    l_index := l_index + 1;

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
        , 'l_ldap_attr(' || (l_index - 1) || ') = ' ||
        fnd_oid_util.get_ldap_attr_str(l_ldap_attr));
    end if;
  else
   l_oid_nickname := upper(fnd_oid_util.get_oid_nickname(p_ldap_key.orclGUID));
   if l_username_changed and l_oid_nickname = l_old_fnd_username then
    -- Fixed bug 4309356:
    --Change USER_NAME - but only if old fnd and OID user names are the same
    l_ldap_attr := ldap_attr(
        'USER_NAME'
      , l_new_fnd_username
      , null
      , length(l_new_fnd_username)
      , wf_oid.ATTR_TYPE_STRING
      , WF_OID.MOD_REPLACE);
    p_ldap_attr_list.extend;
    p_ldap_attr_list(l_index) := l_ldap_attr;
    l_index := l_index + 1;
   end if;
  end if;

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
end map_ldap_attr_list;
--
-------------------------------------------------------------------------------
procedure map_ldap_message(
    p_wf_event      in wf_event_t
  , p_event_type    in varchar2
  , p_ldap_message  in out nocopy fnd_oid_util.ldap_message_type
) is

  l_module_source varchar2(256);

begin
  l_module_source := G_MODULE_SOURCE || 'map_ldap_message: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  p_ldap_message.object_name := p_wf_event.GetEventKey;

 p_ldap_message.sn := wf_entity_mgr.get_attribute_value(p_event_type,
    p_ldap_message.object_name, fnd_oid_util.G_LDAP_MESSAGE_ATTR.sn);

  if (p_ldap_message.sn in ('*UNKNOWN*','*NULL*')) then
    p_ldap_message.sn := null;
 end if;

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Surname is:' ||  p_ldap_message.sn
    || ', attribute name is: ' || fnd_oid_util.G_LDAP_MESSAGE_ATTR.sn);
  end if;

  p_ldap_message.cn := wf_entity_mgr.get_attribute_value(p_event_type,
    p_ldap_message.object_name, fnd_oid_util.G_LDAP_MESSAGE_ATTR.cn);

   if (p_ldap_message.cn in ('*UNKNOWN*','*NULL*')) then
    p_ldap_message.cn := null;
   end if;

  p_ldap_message.userPassword := wf_entity_mgr.get_attribute_value(p_event_type,
    p_ldap_message.object_name, fnd_oid_util.G_LDAP_MESSAGE_ATTR.userPassword);


  p_ldap_message.telephoneNumber := wf_entity_mgr.get_attribute_value(p_event_type,
    p_ldap_message.object_name, fnd_oid_util.G_LDAP_MESSAGE_ATTR.telephoneNumber);

   if (p_ldap_message.telephoneNumber in ('*UNKNOWN*','*NULL*')) then
      p_ldap_message.telephoneNumber := null;
   end if;

  p_ldap_message.street := wf_entity_mgr.get_attribute_value(p_event_type,
    p_ldap_message.object_name, fnd_oid_util.G_LDAP_MESSAGE_ATTR.street);

   if (p_ldap_message.street in ('*UNKNOWN*','*NULL*')) then
      p_ldap_message.street := null;
  end if;

  p_ldap_message.postalCode := wf_entity_mgr.get_attribute_value(p_event_type,
    p_ldap_message.object_name, fnd_oid_util.G_LDAP_MESSAGE_ATTR.postalCode);

  if (p_ldap_message.postalCode in ('*UNKNOWN*','*NULL*')) then
      p_ldap_message.postalCode := null;
  end if;

  p_ldap_message.physicalDeliveryOfficeName := wf_entity_mgr.get_attribute_value(p_event_type,
    p_ldap_message.object_name, fnd_oid_util.G_LDAP_MESSAGE_ATTR.physicalDeliveryOfficeName);

   if (p_ldap_message.physicalDeliveryOfficeName in ('*UNKNOWN*','*NULL*')) then
      p_ldap_message.physicalDeliveryOfficeName := null;
  end if;

  p_ldap_message.st := wf_entity_mgr.get_attribute_value(p_event_type,
    p_ldap_message.object_name, fnd_oid_util.G_LDAP_MESSAGE_ATTR.st);

  if (p_ldap_message.st in ('*UNKNOWN*','*NULL*')) then
      p_ldap_message.st := null;
  end if;

  p_ldap_message.l := wf_entity_mgr.get_attribute_value(p_event_type,
    p_ldap_message.object_name, fnd_oid_util.G_LDAP_MESSAGE_ATTR.l);

  if (p_ldap_message.l in ('*UNKNOWN*','*NULL*')) then
      p_ldap_message.l := null;
  end if;

  p_ldap_message.displayName := wf_entity_mgr.get_attribute_value(p_event_type,
    p_ldap_message.object_name, fnd_oid_util.G_LDAP_MESSAGE_ATTR.displayName);

  if (p_ldap_message.displayName in ('*UNKNOWN*','*NULL*')) then
      p_ldap_message.displayName := null;
  end if;

  p_ldap_message.givenName := wf_entity_mgr.get_attribute_value(p_event_type,
    p_ldap_message.object_name, fnd_oid_util.G_LDAP_MESSAGE_ATTR.givenName);

  if (p_ldap_message.givenName in ('*UNKNOWN*','*NULL*')) then
      p_ldap_message.givenName := null;
  end if;

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Given name is:' ||  p_ldap_message.givenName
    || ', attribute name is: ' || fnd_oid_util.G_LDAP_MESSAGE_ATTR.givenName);
  end if;

  p_ldap_message.homePhone := wf_entity_mgr.get_attribute_value(p_event_type,
    p_ldap_message.object_name, fnd_oid_util.G_LDAP_MESSAGE_ATTR.homePhone);

  if (p_ldap_message.homePhone in ('*UNKNOWN*','*NULL*')) then
      p_ldap_message.homePhone := null;
  end if;

  p_ldap_message.mail := wf_entity_mgr.get_attribute_value(p_event_type,
    p_ldap_message.object_name, fnd_oid_util.G_LDAP_MESSAGE_ATTR.mail);

   if (p_ldap_message.mail in ('*UNKNOWN*','*NULL*')) then
      p_ldap_message.mail := null;
  end if;

  p_ldap_message.c := wf_entity_mgr.get_attribute_value(p_event_type,
    p_ldap_message.object_name, fnd_oid_util.G_LDAP_MESSAGE_ATTR.c);

   if (p_ldap_message.c in ('*UNKNOWN*','*NULL*')) then
      p_ldap_message.c := null;
  end if;

  p_ldap_message.facsimileTelephoneNumber := wf_entity_mgr.get_attribute_value(p_event_type,
    p_ldap_message.object_name, fnd_oid_util.G_LDAP_MESSAGE_ATTR.facsimileTelephoneNumber);

   if (p_ldap_message.facsimileTelephoneNumber in ('*UNKNOWN*','*NULL*')) then
      p_ldap_message.facsimileTelephoneNumber := null;
  end if;

  p_ldap_message.description := wf_entity_mgr.get_attribute_value(p_event_type,
    p_ldap_message.object_name, fnd_oid_util.G_LDAP_MESSAGE_ATTR.description);

   if (p_ldap_message.description in ('*UNKNOWN*','*NULL*')) then
      p_ldap_message.description := null;
  end if;

  p_ldap_message.orclisEnabled := wf_entity_mgr.get_attribute_value(p_event_type,
    p_ldap_message.object_name, fnd_oid_util.G_LDAP_MESSAGE_ATTR.orclisEnabled);

  p_ldap_message.orclActiveStartDate := wf_entity_mgr.get_attribute_value(p_event_type,
    p_ldap_message.object_name, fnd_oid_util.G_LDAP_MESSAGE_ATTR.orclActiveStartDate);

  p_ldap_message.orclActiveEndDate := wf_entity_mgr.get_attribute_value(p_event_type,
    p_ldap_message.object_name, fnd_oid_util.G_LDAP_MESSAGE_ATTR.orclActiveEndDate);

  p_ldap_message.orclGUID := wf_entity_mgr.get_attribute_value(p_event_type,
    p_ldap_message.object_name, fnd_oid_util.G_LDAP_MESSAGE_ATTR.orclGUID);

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
end map_ldap_message;
--
-------------------------------------------------------------------------------
procedure map_ldap_message(
    p_user_name    in fnd_user.user_name%type
  , p_ldap_attr_list   in ldap_attr_list
  , p_ldap_message  in out nocopy fnd_oid_util.ldap_message_type
) is

  l_module_source varchar2(256);
begin
  l_module_source := G_MODULE_SOURCE || 'map_ldap_message: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  p_ldap_message.object_name := p_user_name;
  if (p_ldap_attr_list is not null AND p_ldap_attr_list.count > 0)
  then
    for j in p_ldap_attr_list.first .. p_ldap_attr_list.last
    loop
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
          , 'p_ldap_attr_list(' || j || ') = ' ||
          fnd_oid_util.get_ldap_attr_str(p_ldap_attr_list(j)));
      end if;


      if (upper(p_ldap_attr_list(j).attr_name)= fnd_oid_util.G_LDAP_MESSAGE_ATTR.sn)
      then
        p_ldap_message.sn := p_ldap_attr_list(j).attr_value;

         if (p_ldap_message.sn in ('*UNKNOWN*','*NULL*')) then
            p_ldap_message.sn := null;
         end if;


      elsif(upper(p_ldap_attr_list(j).attr_name)= fnd_oid_util.G_LDAP_MESSAGE_ATTR.cn)
      then
        p_ldap_message.cn := p_ldap_attr_list(j).attr_value;
        if (p_ldap_message.cn in ('*UNKNOWN*','*NULL*')) then
            p_ldap_message.cn := null;
        end if;

      elsif(upper(p_ldap_attr_list(j).attr_name)= fnd_oid_util.G_LDAP_MESSAGE_ATTR.telephoneNumber)
      then
        p_ldap_message.telephoneNumber := p_ldap_attr_list(j).attr_value;
        if (p_ldap_message.telephoneNumber in ('*UNKNOWN*','*NULL*')) then
            p_ldap_message.telephoneNumber := null;
        end if;

      elsif(upper(p_ldap_attr_list(j).attr_name)= fnd_oid_util.G_LDAP_MESSAGE_ATTR.street)
      then
        p_ldap_message.street := p_ldap_attr_list(j).attr_value;
          if (p_ldap_message.street in ('*UNKNOWN*','*NULL*')) then
              p_ldap_message.street := null;
          end if;

      elsif(upper(p_ldap_attr_list(j).attr_name)= fnd_oid_util.G_LDAP_MESSAGE_ATTR.postalCode)
      then
        p_ldap_message.postalCode := p_ldap_attr_list(j).attr_value;
        if (p_ldap_message.postalCode in ('*UNKNOWN*','*NULL*')) then
            p_ldap_message.postalCode := null;
        end if;

      elsif(upper(p_ldap_attr_list(j).attr_name)= fnd_oid_util.G_LDAP_MESSAGE_ATTR.physicalDeliveryOfficeName)
      then
        p_ldap_message.physicalDeliveryOfficeName := p_ldap_attr_list(j).attr_value;
         if (p_ldap_message.physicalDeliveryOfficeName in ('*UNKNOWN*','*NULL*')) then
             p_ldap_message.physicalDeliveryOfficeName := null;
         end if;

      elsif(upper(p_ldap_attr_list(j).attr_name)= fnd_oid_util.G_LDAP_MESSAGE_ATTR.st)
      then
         p_ldap_message.st := p_ldap_attr_list(j).attr_value;
        if (p_ldap_message.st in ('*UNKNOWN*','*NULL*')) then
            p_ldap_message.st := null;
        end if;

      elsif(upper(p_ldap_attr_list(j).attr_name)= fnd_oid_util.G_LDAP_MESSAGE_ATTR.l)
      then
        p_ldap_message.l := p_ldap_attr_list(j).attr_value;
        if (p_ldap_message.l in ('*UNKNOWN*','*NULL*')) then
           p_ldap_message.l := null;
        end if;

      elsif(upper(p_ldap_attr_list(j).attr_name)= fnd_oid_util.G_LDAP_MESSAGE_ATTR.displayName)
      then
        p_ldap_message.displayName := p_ldap_attr_list(j).attr_value;
        if (p_ldap_message.displayName in ('*UNKNOWN*','*NULL*')) then
          p_ldap_message.displayName := null;
        end if;

      elsif(upper(p_ldap_attr_list(j).attr_name)= fnd_oid_util.G_LDAP_MESSAGE_ATTR.givenName)
      then
         p_ldap_message.givenName := p_ldap_attr_list(j).attr_value;
         if (p_ldap_message.givenName in ('*UNKNOWN*','*NULL*')) then
           p_ldap_message.givenName := null;
         end if;

      elsif(upper(p_ldap_attr_list(j).attr_name)= fnd_oid_util.G_LDAP_MESSAGE_ATTR.homePhone)
      then
         p_ldap_message.homePhone := p_ldap_attr_list(j).attr_value;
         if (p_ldap_message.homePhone in ('*UNKNOWN*','*NULL*')) then
            p_ldap_message.homePhone := null;
         end if;

      elsif(upper(p_ldap_attr_list(j).attr_name)= fnd_oid_util.G_LDAP_MESSAGE_ATTR.mail)
      then
        p_ldap_message.mail := p_ldap_attr_list(j).attr_value;
          if (p_ldap_message.mail in ('*UNKNOWN*','*NULL*')) then
              p_ldap_message.mail := null;
          end if;

      elsif(upper(p_ldap_attr_list(j).attr_name)= fnd_oid_util.G_LDAP_MESSAGE_ATTR.c)
      then
        p_ldap_message.c := p_ldap_attr_list(j).attr_value;
        if (p_ldap_message.c in ('*UNKNOWN*','*NULL*')) then
            p_ldap_message.c := null;
         end if;

      elsif(upper(p_ldap_attr_list(j).attr_name)= fnd_oid_util.G_LDAP_MESSAGE_ATTR.facsimileTelephoneNumber)
      then
        p_ldap_message.facsimileTelephoneNumber := p_ldap_attr_list(j).attr_value;
        if (p_ldap_message.facsimileTelephoneNumber in ('*UNKNOWN*','*NULL*')) then
            p_ldap_message.facsimileTelephoneNumber := null;
         end if;

      elsif(upper(p_ldap_attr_list(j).attr_name)= fnd_oid_util.G_LDAP_MESSAGE_ATTR.description)
      then
        p_ldap_message.description := p_ldap_attr_list(j).attr_value;
        if (p_ldap_message.description in ('*UNKNOWN*','*NULL*')) then
            p_ldap_message.description := null;
        end if;

      elsif(upper(p_ldap_attr_list(j).attr_name)= fnd_oid_util.G_LDAP_MESSAGE_ATTR.orclisEnabled)
      then
        p_ldap_message.orclisEnabled := p_ldap_attr_list(j).attr_value;

      elsif(upper(p_ldap_attr_list(j).attr_name)= fnd_oid_util.G_LDAP_MESSAGE_ATTR.orclActiveStartDate)
      then
        p_ldap_message.orclActiveStartDate := p_ldap_attr_list(j).attr_value;

      elsif(upper(p_ldap_attr_list(j).attr_name)= fnd_oid_util.G_LDAP_MESSAGE_ATTR.orclActiveEndDate)
      then
        p_ldap_message.orclActiveEndDate := p_ldap_attr_list(j).attr_value;
      else

        if(upper(p_ldap_attr_list(j).attr_name)= fnd_oid_util.G_LDAP_MESSAGE_ATTR.orclGUID)
        then
          p_ldap_message.orclGUID := p_ldap_attr_list(j).attr_value;
        end if;
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
end map_ldap_message;
--
-------------------------------------------------------------------------------
procedure map_oid_event(
    p_ldap_key            in          fnd_oid_util.ldap_key_type
  , p_entity_changes_rec  in          fnd_oid_util.wf_entity_changes_rec_type
  , p_ldap_attr_list      in          ldap_attr_list
  , p_event               out nocopy  ldap_event
) is

  l_module_source varchar2(256);

begin
  l_module_source := G_MODULE_SOURCE || 'map_oid_event: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  if (p_ldap_key.orclGUID is null
    and p_entity_changes_rec.entity_type = fnd_oid_util.G_USER)
  then
    p_event := ldap_event(
        event_type  => wf_oid.IDENTITY_ADD
      , event_id    => to_char(p_entity_changes_rec.entity_id)
      , event_src   => fnd_oid_util.G_EBIZ
      , event_time  => p_entity_changes_rec.change_date_in_char
      , object_name => p_entity_changes_rec.entity_key_value
      , object_type => p_entity_changes_rec.flavor
      , object_guid => null
      , object_dn   => null
      , profile_id  => fnd_oid_util.G_NOT_FOR_IMPORT
      , attr_list   => p_ldap_attr_list);
  elsif (p_entity_changes_rec.entity_type = wf_oid.SUBSCRIPTION_ADD)
  then
    p_event := ldap_event(
        event_type  => wf_oid.SUBSCRIPTION_ADD
      , event_id    => to_char(p_entity_changes_rec.entity_id)
      , event_src   => fnd_oid_util.G_EBIZ
      , event_time  => p_entity_changes_rec.change_date_in_char
      , object_name => p_entity_changes_rec.entity_key_value
      , object_type => p_entity_changes_rec.flavor
      , object_guid => p_ldap_key.orclGUID
      , object_dn   => null
      , profile_id  => fnd_oid_util.G_NOT_FOR_IMPORT
      , attr_list   => null);

  elsif (p_entity_changes_rec.entity_type = fnd_oid_util.G_USER)
  then
    p_event := ldap_event(
        event_type  => wf_oid.IDENTITY_MODIFY
      , event_id    => to_char(p_entity_changes_rec.entity_id)
      , event_src   => fnd_oid_util.G_EBIZ
      , event_time  => p_entity_changes_rec.change_date_in_char
      , object_name => null
      , object_type => p_entity_changes_rec.flavor
      , object_guid => p_ldap_key.orclGUID
      , object_dn   => null
      , profile_id  => fnd_oid_util.G_NOT_FOR_IMPORT
      , attr_list   => p_ldap_attr_list);

  elsif (p_entity_changes_rec.entity_type = wf_oid.SUBSCRIPTION_DELETE)
  then
    p_event := ldap_event(
        event_type  => wf_oid.SUBSCRIPTION_DELETE
      , event_id    => to_char(p_entity_changes_rec.entity_id)
      , event_src   => fnd_oid_util.G_EBIZ
      , event_time  => p_entity_changes_rec.change_date_in_char
      , object_name => null
      , object_type => p_entity_changes_rec.flavor
      , object_guid => p_ldap_key.orclGUID
      , object_dn   => null
      , profile_id  => fnd_oid_util.G_NOT_FOR_IMPORT
      , attr_list   => null);

  end if;

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
end map_oid_event;
--
-------------------------------------------------------------------------------
end fnd_ldap_mapper;

/

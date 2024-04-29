--------------------------------------------------------
--  DDL for Package Body WF_LDAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_LDAP" as
/* $Header: WFLDAPB.pls 120.1 2005/07/02 03:15:36 appldev ship $ */
------------------------------------------------------------------------------
WF_LDAP_LOCAL_CHARSET  varchar2(100) := null;
WF_LDAP_CHANGELOG_SUB  varchar2(256) := 'cn=WF_SYNCH_'||
 fnd_web_config.database_id()||
 ',cn=Subscriber Profile,cn=ChangeLog Subscriber,cn=Oracle Internet Directory';
------------------------------------------------------------------------------
usernameAttr varchar2(256) := 'ORCLCOMMONNICKNAMEATTRIBUTE';
usernameAttrBase varchar2(256):= 'cn=Common,cn=Products,cn=OracleContext';
------------------------------------------------------------------------------

/*
** cs_convert - <private> convert incoming OID attribute value to db charset
*/
FUNCTION cs_convert(p_value in varchar2) return varchar2 is
  new_val varchar2(4000);
  ulang   varchar2(256);
begin
  if (wf_ldap.WF_LDAP_LOCAL_CHARSET is null) then
    ulang := userenv('LANGUAGE');
    wf_ldap.WF_LDAP_LOCAL_CHARSET := substr(ulang, instr(ulang,'.')+1,
                                            length(ulang));
  end if;

  if (wf_ldap.WF_LDAP_LOCAL_CHARSET = 'UTF8') then
    new_val := p_value;
  else
    new_val := convert(p_value, wf_ldap.WF_LDAP_LOCAL_CHARSET, 'UTF8');
  end if;

  return new_val;
exception
  when others then
    wf_core.context('wf_ldap', 'cs_convert', p_value);
    raise;
end cs_convert;
------------------------------------------------------------------------------
/*
** dump_ldap_msg <PRIVATE> - write out the contents of an ldap message
*/
PROCEDURE dump_ldap_msg(p_session in out NOCOPY DBMS_LDAP.session,
                        p_message in     DBMS_LDAP.message) is
  i            pls_integer;
  my_entry     DBMS_LDAP.message;
  my_ber_elmt  DBMS_LDAP.ber_element;
  my_vals      DBMS_LDAP.STRING_COLLECTION;
  my_attrname  varchar2(256);
begin
  null;

/******************** uncomment if needed *********************************

  dbms_output.put_line('-------------------------');
  dbms_output.put_line('This LDAP message contains '||
                        to_char(dbms_ldap.count_entries(p_session,p_message))||
                        ' entries');
  my_entry := dbms_ldap.first_entry(p_session, p_message);
  while my_entry IS NOT NULL loop
    dbms_output.put_line('-------------------------');
    dbms_output.put_line('dn: '||dbms_ldap.get_dn(p_session, my_entry));

    my_attrname := dbms_ldap.first_attribute(p_session,my_entry,my_ber_elmt);
    while my_attrname IS NOT NULL loop
      my_vals := dbms_ldap.get_values(p_session, my_entry, my_attrname);
      if my_vals.COUNT > 0 then
        FOR i in my_vals.FIRST..my_vals.LAST loop
          dbms_output.put_line(my_attrname||' : '||SUBSTR(my_vals(i),1,200));
        end loop;
      end if;
      my_attrname := DBMS_LDAP.next_attribute(p_session,my_entry,my_ber_elmt);
    end loop;
    my_entry := DBMS_LDAP.next_entry(p_session, my_entry);
  end loop;
*************************************************************************/
end dump_ldap_msg;
------------------------------------------------------------------------------
/*
** setsizelimit <PRIVATE> - set the orclsizelimit parameter value
*/
PROCEDURE setsizelimit(p_session in out NOCOPY dbms_ldap.session,
                       p_size    in     varchar2 default '1000')
is
  mod_array  DBMS_LDAP.MOD_ARRAY;
  mod_vals   DBMS_LDAP.STRING_COLLECTION;
  retval     pls_integer;
begin
  mod_vals(1) := p_size;
  mod_array   := DBMS_LDAP.create_mod_array(1);

  DBMS_LDAP.populate_mod_array(mod_array, DBMS_LDAP.MOD_REPLACE,
                               'orclsizelimit', mod_vals);
  retval := DBMS_LDAP.modify_s(p_session, ' ', mod_array);
  dbms_ldap.free_mod_array(mod_array);
exception
  when others then
    wf_core.context('wf_ldap', 'setsizelimit',
                    'Error code: '||to_char(sqlcode),
                    'Error Message: '||substr(sqlerrm, 1, 238));
    raise;
end setsizelimit;
------------------------------------------------------------------------------
/*
** setLastChangeNumber <PRIVATE> - set the lastchangenum for our subscription
*/
PROCEDURE setLastChangeNumber(p_session in out NOCOPY dbms_ldap.session,
                              p_cnum    in     varchar2)
is
  mod_array  DBMS_LDAP.MOD_ARRAY;
  mod_vals   DBMS_LDAP.STRING_COLLECTION;
  retval     pls_integer;
begin
  mod_vals(1) := p_cnum;
  mod_array   := DBMS_LDAP.create_mod_array(1);

  DBMS_LDAP.populate_mod_array(mod_array, DBMS_LDAP.MOD_REPLACE,
                               'orclLastAppliedChangeNumber', mod_vals);
  retval := DBMS_LDAP.modify_s(p_session, WF_LDAP_CHANGELOG_SUB, mod_array);
  dbms_ldap.free_mod_array(mod_array);
exception
  when others then
    wf_core.context('wf_ldap', 'setLastChangeNumber',
                    'Error code: '||to_char(sqlcode),
                    'Error Message: '||substr(sqlerrm, 1, 238));
    raise;
end setLastChangeNumber;
------------------------------------------------------------------------------
/*
** search <PRIVATE> - Perform an LDAP query
*/
FUNCTION search(p_session in out NOCOPY dbms_ldap.session,
                p_base    in     varchar2,
                p_results in out NOCOPY dbms_ldap.message,
                p_scope   in     pls_integer default DBMS_LDAP.SCOPE_SUBTREE,
                p_filter  in     varchar2    default 'objectclass=*',
                p_attr    in     varchar2    default '*')
return pls_integer is
  retval    pls_integer := -1;
  my_attrs  dbms_ldap.string_collection;
begin
  my_attrs(1) := p_attr;

  return dbms_ldap.search_s(p_session,
                            p_base,
                            p_scope,
                            p_filter,
                            my_attrs,
                            0, -- retrieve both types AND values
                            p_results);
exception
  when others then
    wf_core.context('wf_ldap', 'search',
                    'Error code: '||to_char(sqlcode),
                    'Error Message: '||substr(sqlerrm, 1, 238));
    raise;
end search;
------------------------------------------------------------------------------
/*
** get_cfg_val <PRIVATE> - Fetch a configuration value from the root base
*/
FUNCTION get_cfg_val(p_session in out NOCOPY dbms_ldap.session,
                     p_name    in     varchar2) return varchar2
is
  results   DBMS_LDAP.message;
  my_entry  DBMS_LDAP.message;
  my_vals   DBMS_LDAP.STRING_COLLECTION;
  retval    pls_integer;
begin
  retval := WF_LDAP.search(p_session, ' ', results, DBMS_LDAP.SCOPE_BASE,
                           'objectclass=*', p_name);
  my_entry := dbms_ldap.first_entry(p_session, results);

  if (my_entry is not null) then
    my_vals := dbms_ldap.get_values(p_session, my_entry, p_name);
    if (my_vals.COUNT > 0) then
      return my_vals(my_vals.FIRST);
    end if;
  end if;
  return null;
exception
  when others then
    return null;
end get_cfg_val;
------------------------------------------------------------------------------
/*
** getlastappliedchangenum <PRIVATE> - self explanatory
*/
FUNCTION getlastappliedchangenum(p_session in out NOCOPY dbms_ldap.session)
         return varchar2
is
  results   DBMS_LDAP.message;
  my_entry  DBMS_LDAP.message;
  my_vals   DBMS_LDAP.STRING_COLLECTION;
  retval    pls_integer;
begin
  retval := wf_ldap.search(p_session, WF_LDAP_CHANGELOG_SUB, results,
                           DBMS_LDAP.SCOPE_SUBTREE, 'objectclass=*',
                           'orcllastappliedchangenumber');
  my_entry := dbms_ldap.first_entry(p_session, results);

  if (my_entry is not null) then
    my_vals := dbms_ldap.get_values(p_session, my_entry,
                                    'orcllastappliedchangenumber');
    if (my_vals.COUNT > 0) then
      return my_vals(my_vals.FIRST);
    end if;
  end if;
  return null;
exception
  when others then
    return null;
end getlastappliedchangenum;
------------------------------------------------------------------------------
/*
** createSubscription <PRIVATE> - create our OID changelog subscription object
*/
PROCEDURE createSubscription(p_session in out NOCOPY dbms_ldap.session)
is
  lastclog   varchar2(10);
  mod_array  DBMS_LDAP.MOD_ARRAY;
  mod_vals   DBMS_LDAP.STRING_COLLECTION;
  retval     pls_integer;
begin
  lastclog := wf_ldap.get_cfg_val(p_session, 'lastchangenumber');
  if (lastclog is null) then
    lastclog := '0';
  end if;

  mod_array := DBMS_LDAP.create_mod_array(5);

  mod_vals(1) := lastclog;
  DBMS_LDAP.populate_mod_array(mod_array, DBMS_LDAP.MOD_ADD,
                               'orclLastAppliedChangeNumber', mod_vals);
  mod_vals(1) := 'WF_SYNCH26';
  DBMS_LDAP.populate_mod_array(mod_array, DBMS_LDAP.MOD_ADD,
                               'userpassword', mod_vals);
  mod_vals(1) := '0';
  DBMS_LDAP.populate_mod_array(mod_array, DBMS_LDAP.MOD_ADD,
                               'orclSubscriberDisable', mod_vals);
  mod_vals(1) := 'orclChangeSubscriber';
  DBMS_LDAP.populate_mod_array(mod_array, DBMS_LDAP.MOD_ADD,
                               'objectclass', mod_vals);
  mod_vals(1) := 'top';
  DBMS_LDAP.populate_mod_array(mod_array, DBMS_LDAP.MOD_ADD,
                               'objectclass', mod_vals);
  dbms_ldap.use_exception := FALSE;
  retval := DBMS_LDAP.add_s(p_session, WF_LDAP_CHANGELOG_SUB, mod_array);
  dbms_ldap.use_exception := TRUE;

  --
  -- Update changenumber.  Doesn't affect anything if subscription is new
  -- but desirable if old subscription with an outdated value already exists.
  --
  wf_ldap.setLastChangeNumber(p_session, lastclog);

  --
  -- grant access to the OID Change Log Object Container
  --
  dbms_ldap.free_mod_array(mod_array);
  mod_array := DBMS_LDAP.create_mod_array(1);

  mod_vals(1) := WF_LDAP_CHANGELOG_SUB;
  DBMS_LDAP.populate_mod_array(mod_array, DBMS_LDAP.MOD_ADD,
                               'uniqueMember', mod_vals);

  dbms_ldap.use_exception := FALSE; -- hide possible dup entry exception --
  retval := DBMS_LDAP.modify_s(p_session,
            'cn=odipgroup,cn=odi,cn=Oracle Internet Directory', mod_array);
  dbms_ldap.use_exception := TRUE;  -- end hide --

  dbms_ldap.free_mod_array(mod_array);
exception
  when others then
    wf_core.context('WF_LDAP', 'createSubscription',
                    'Error code: '||to_char(sqlcode),
                    'Error Message: '||substr(sqlerrm, 1, 238));
    raise;
end createSubscription;
------------------------------------------------------------------------------
/*
** walk_and_load <PRIVATE> -
**
**  For each user, walk and load its attributes into the attribute cache
**  using the Entity Mgr.  Entity Mgr will examine the attribute changes
**  and raise an event to let interested parties know when there is
**  new information.  Returns the last key_value processed.
*/
PROCEDURE walk_and_load(p_session    in out NOCOPY dbms_ldap.session,
                        p_data       in     dbms_ldap.message,
                        p_mode       in     varchar2,
                        p_key_attr   in     varchar2,
                        p_entity     in     varchar2,
                        p_delkey     in     varchar2 default null)
is
  my_entry     DBMS_LDAP.message;
  my_ber_elmt  DBMS_LDAP.ber_element;
  my_vals      DBMS_LDAP.STRING_COLLECTION;
  my_attrname  varchar2(256);
  new_val      varchar2(4000);
  my_key_value varchar2(256);
begin
  if (p_mode <> 'DELETE') then

  my_entry := dbms_ldap.first_entry(p_session, p_data);
  while (my_entry IS NOT NULL) loop
    my_vals := DBMS_LDAP.get_values(p_session, my_entry, p_key_attr);
    my_key_value := my_vals(my_vals.first);

    my_attrname := dbms_ldap.first_attribute(p_session, my_entry, my_ber_elmt);
    while my_attrname IS NOT NULL loop

      my_vals := dbms_ldap.get_values(p_session, my_entry, my_attrname);
      if (my_vals.COUNT > 0) then
        new_val := wf_ldap.cs_convert(substr(my_vals(my_vals.FIRST),1,4000));
      else
        new_val := null;
      end if;

      wf_entity_mgr.put_attribute_value(p_entity, my_key_value,
                                        my_attrname, new_val);
      my_attrname := DBMS_LDAP.next_attribute(p_session,my_entry,my_ber_elmt);
    end loop;

    wf_entity_mgr.process_changes(p_entity, my_key_value, 'LDAP');
    commit;

    my_entry := DBMS_LDAP.next_entry(p_session, my_entry);
  end loop;

  else  /* 'Delete' */

     wf_entity_mgr.flush_cache(p_entity, p_delkey);
     wf_entity_mgr.put_attribute_value(p_entity, p_delkey,
                                       'CACHE_CHANGED', 'YES');
     wf_entity_mgr.process_changes(p_entity, p_delkey, 'LDAP', 'DELETE');
     commit;

/* Bug 3147044
    wf_entity_mgr.flush_cache(p_entity, p_delkey);
    wf_entity_mgr.put_attribute_value(p_entity, my_key_value,
          'CACHE_CHANGED', 'YES');
    wf_entity_mgr.process_changes(p_entity, p_delkey, 'LDAP', 'DELETE');
    commit;
*/

  end if;
end walk_and_load;
------------------------------------------------------------------------------
/*
** get_ldap_session <PRIVATE> - Setup up an LDAP session
*/
PROCEDURE get_ldap_session(p_session in out NOCOPY dbms_ldap.session) is
  retval   pls_integer;
  my_host  varchar2(256);
  my_port  varchar2(256);
  my_user  varchar2(256);
  my_pwd   varchar2(256);
begin
  dbms_ldap.use_exception := TRUE;

  my_host := fnd_preference.get('#INTERNAL', 'LDAP_SYNCH', 'HOST');
  my_port := fnd_preference.get('#INTERNAL', 'LDAP_SYNCH', 'PORT');
  my_user := fnd_preference.get('#INTERNAL', 'LDAP_SYNCH', 'USERNAME');
  my_pwd  := fnd_preference.eget('#INTERNAL','LDAP_SYNCH', 'EPWD', 'LDAP_PWD');

  p_session := DBMS_LDAP.init(my_host, my_port);
  retval := dbms_ldap.simple_bind_s(p_session, my_user, my_pwd);
exception
  when others then
    wf_core.context('WF_LDAP', 'get_ldap_session',
                    'Error code: '||to_char(sqlcode),
                    'Error Message: '||substr(sqlerrm, 1, 238));
    raise;
end get_ldap_session;
------------------------------------------------------------------------------
/*
** unbind <PRIVATE> - Unbind the LDAP session
*/
PROCEDURE unbind(p_session in out NOCOPY dbms_ldap.session)
is
  retval pls_integer := -1;
begin
  retval := DBMS_LDAP.unbind_s(p_session);
exception
  when others then null;
end unbind;
------------------------------------------------------------------------------
/*
** get_name_attr
*/
FUNCTION get_name_attr(p_session in out nocopy dbms_ldap.session)
return varchar2
is
  retval         pls_integer := -1;
  results        dbms_ldap.message;
  my_entry     DBMS_LDAP.message;
  my_ber_elmt  DBMS_LDAP.ber_element;
  my_vals      DBMS_LDAP.STRING_COLLECTION;
  my_attrname  varchar2(256);
  new_val      varchar2(256);
  l_AttrFound number := 0;
begin

  retval := WF_LDAP.search(p_session, usernameAttrBase, results,
                           DBMS_LDAP.SCOPE_SUBTREE);

  my_entry := dbms_ldap.first_entry(p_session, results);
  while (my_entry IS NOT NULL) loop
    my_vals := DBMS_LDAP.get_values(p_session, my_entry, usernameAttr);

    my_attrname := dbms_ldap.first_attribute(p_session, my_entry, my_ber_elmt);
    while my_attrname IS NOT NULL loop

      my_vals := dbms_ldap.get_values(p_session, my_entry, my_attrname);
      if (my_vals.COUNT > 0) then
        new_val := my_vals(my_vals.FIRST);
      else
        new_val := null;
      end if;

      if upper(my_attrname) = userNameAttr then
        l_AttrFound := 1;
        exit;
      end if;
      my_attrname := DBMS_LDAP.next_attribute(p_session,my_entry,my_ber_elmt);
    end loop;
    if l_AttrFound = 1 then
        exit;
    end if;
    my_entry := DBMS_LDAP.next_entry(p_session, my_entry);
 end loop;

 return(NVL(new_val,'cn'));

end get_name_attr;
------------------------------------------------------------------------------
/*
** synch_changes - <described in WFLDAPS.pls>
*/
FUNCTION synch_changes return boolean
is
  retval         pls_integer := -1;
  my_host        varchar2(256);
  my_log_base    varchar2(256);
  my_user_base   varchar2(256);
  comp_user_base varchar2(256);
  my_attrname    varchar2(256);
  my_TargetDN    varchar2(4000);
  comp_TargetDN  varchar2(4000);
  my_mode        varchar2(20);
  my_change_num  varchar2(20);
  my_uname       varchar2(256);
  my_key_att     varchar2(256);
  my_session     dbms_ldap.session;
  my_changelogs  dbms_ldap.message;
  my_user_data   DBMS_LDAP.message;
  my_entry       DBMS_LDAP.message;
  my_ber_elmt    DBMS_LDAP.ber_element;
  my_vals        DBMS_LDAP.STRING_COLLECTION;
  found          boolean := FALSE;
  fullbucket     boolean := TRUE;
begin
  wf_ldap.get_ldap_session(my_session);
  my_host      := fnd_preference.get('#INTERNAL','LDAP_SYNCH','HOST');
  my_user_base := fnd_preference.get('#INTERNAL','LDAP_SYNCH','USER_DIR');
  my_log_base  := fnd_preference.get('#INTERNAL','LDAP_SYNCH','CHANGELOG_DIR');

  if (my_log_base is null OR my_user_base is null) then
    wf_core.context('wf_ldap', 'synch_changes');
    wf_core.raise('WF_LDAP_INVALID_PREFS');
  end if;

  comp_user_base := lower(replace(my_user_base, ' '));

  -- Get the last processed changelog# --
  my_change_num := wf_ldap.getlastappliedchangenum(my_session);

  dbms_ldap.use_exception := FALSE;  -- to survive possible sizelimit excp --
  while (fullbucket) loop
    -- fetch any new changelog entries since the last synch --
    retval := WF_LDAP.search(
              my_session, my_log_base, my_changelogs, DBMS_LDAP.SCOPE_ONELEVEL,
              '(&(objectclass=changelogentry)(changenumber>='||
                    to_char(to_number(my_change_num)+1)||'))');

    if (retval <> dbms_ldap.success AND
        retval <> dbms_ldap.sizelimit_exceeded)
    then
      wf_core.context('wf_ldap', 'synch_changes');
      wf_core.raise('WF_LDAP_SEARCH_FAIL');
    elsif (retval = dbms_ldap.sizelimit_exceeded) then
      fullbucket := TRUE;
    else
      fullbucket := FALSE;
    end if;

    --
    -- Inspect each changelog entry to see if it looks like a user record.
    -- All we reliably have is the targetdn, so look at that to see if it
    -- includes the user base directory.  If so, use it to query the user.
    --
    my_entry := DBMS_LDAP.first_entry(my_session, my_changelogs);
    while my_entry IS NOT NULL loop
      my_attrname :=DBMS_LDAP.first_attribute(my_session,my_entry,my_ber_elmt);
      while my_attrname IS NOT NULL loop
        my_vals := DBMS_LDAP.get_values(my_session, my_entry, my_attrname);

        if (my_attrname = 'targetdn') then
          my_targetdn := substr(my_vals(my_vals.first),1,4000);
          comp_TargetDN := lower(replace(my_targetdn, ' '));
        elsif (my_attrname = 'changetype') then
          my_mode := upper(substr(my_vals(my_vals.first),1,20));
        elsif (my_attrname = 'changenumber') then
          my_change_num := substr(my_vals(my_vals.first),1,20);
        end if;

        my_attrname:=DBMS_LDAP.next_attribute(my_session,my_entry,my_ber_elmt);
      end loop; /* attributes */

      -- dbms_output.put_line('-- debug -------------------');
      -- dbms_output.put_line('TargetDN:   '||my_TargetDN);
      -- dbms_output.put_line('ChangeType: '||my_mode);
      -- dbms_output.put_line('Change#:    '||my_change_num);

      if (instr(comp_targetdn, comp_user_base) > 0) then
        my_uname := substr(my_targetdn, instr(my_targetdn, '=') + 1,
                    instr(my_targetdn, ',')-instr(my_targetdn, '=')-1);

        -- dbms_output.put_line('Found potential User: '||my_uname);
        found := TRUE;

        retval := WF_LDAP.search(my_session, my_user_base, my_user_data,
                                 DBMS_LDAP.SCOPE_SUBTREE,
                                 '(&(objectclass=person)(cn='||my_uname||'))');

--start bug 3101137
        my_key_att := fnd_preference.get('#INTERNAL','LDAP_SYNCH', 'KEYATT');
        if (my_key_att is null) then
          my_key_att := 'cn';
        end if;
--        my_key_att := get_name_attr(my_session);
--end bug 3101137

        wf_ldap.walk_and_load(my_session, my_user_data, my_mode, my_key_att,
                              'USER', my_uname);
      end if;

      my_entry := DBMS_LDAP.next_entry(my_session, my_entry);
    end loop;  /* entries */
    wf_ldap.setLastChangeNumber(my_session, my_change_num);
  end loop; /* changelogs */
  dbms_ldap.use_exception := TRUE;

  WF_LDAP.unbind(my_session);
  commit;
  return TRUE;
exception
  when others then
    wf_core.context('wf_ldap', 'synch_changes',
                    'Error code: '||to_char(sqlcode),
                    'Error Message: '||substr(sqlerrm, 1, 238));
    raise;
end synch_changes;
------------------------------------------------------------------------------
/*
** synch_all - <described in WFLDAPS.pls>
*/
FUNCTION synch_all return boolean is
  retval         pls_integer := -1;
  results        dbms_ldap.message;
  my_session     dbms_ldap.session;
  my_user_base   varchar2(256);
  my_key_att     varchar2(256);
  lastclog       varchar2(10);
  origsizelimit  varchar2(10) := 'DUNNO';
begin
  wf_ldap.get_ldap_session(my_session);

  my_user_base := fnd_preference.get('#INTERNAL','LDAP_SYNCH','USER_DIR');
  if (my_user_base is null) then
    wf_core.context('wf_ldap', 'synch_all');
    wf_core.raise('WF_LDAP_INVALID_PREFS');
  end if;

  --
  -- Fetch and resize the orclsizelimit.  This will allow us to query all
  -- of the users in one shot.  We will reset the value when we're done.
  --
  origsizelimit := wf_ldap.get_cfg_val(my_session, 'orclsizelimit');
  wf_ldap.setsizelimit(my_session, '10000000');

  --
  -- set up our OID Change Subscription Object.  This guarantees
  -- availability of subsequent changelogs
  --
  wf_ldap.createSubscription(my_session);

  --
  -- fetch and process all of the users
  --
  retval := WF_LDAP.search(my_session, my_user_base, results,
                           DBMS_LDAP.SCOPE_SUBTREE, 'objectclass=person');
  wf_entity_mgr.flush_cache('*ALL*', null);

--start bug 3101137
  my_key_att := fnd_preference.get('#INTERNAL','LDAP_SYNCH', 'KEYATT');
  if (my_key_att is null) then
    my_key_att := 'cn';
  end if;
--  my_key_att := get_name_attr(my_session);
--end bug 3101137

  wf_ldap.walk_and_load(my_session, results, 'LOAD', my_key_att, 'USER');
  wf_ldap.setsizelimit(my_session, origsizelimit);
  wf_ldap.unbind(my_session);
  return TRUE;
exception
  when others then
    wf_core.context('WF_LDAP', 'synch_all',
                    'Error code: '||to_char(sqlcode),
                    'Error Message: '||substr(sqlerrm, 1, 238),
                     substr(sqlerrm, 239, 490));
    if (origsizelimit <> 'DUNNO') then
      wf_ldap.setsizelimit(my_session, origsizelimit);
    end if;
    raise;
end synch_all;
------------------------------------------------------------------------------
/*
** update_ldap - Update LDAP directory with specified user changes
*/
PROCEDURE update_ldap(p_entity_type      in varchar2,
                      p_entity_key_value in varchar2,
                      p_change_source    in varchar2,
                      p_change_type      in varchar2,
                      p_user_base        in varchar2)
is
  my_session  dbms_ldap.session;
  emp_array   DBMS_LDAP.MOD_ARRAY;
  emp_vals    DBMS_LDAP.STRING_COLLECTION;
  emp_dn      varchar2(256);
  retval      pls_integer := -1;

  cursor attribute_data is
    select attribute_name  aname,
           attribute_value avalue
    from   wf_attribute_cache
    where  entity_key_value = p_entity_key_value
    and    entity_type = p_entity_type
    and    attribute_name <> 'CACHE_CHANGED';

begin
  if (p_change_source = 'LDAP') then
    return;
  end if;
/*********************** NOT IMPLEMENTED *****************
  dbms_output.put_line('wf_ldap.app_user_change called for <'||
         p_entity_type||':'||p_entity_key_value||'>');

  wf_ldap.get_ldap_session(my_session);

  -- update LDAP --
  --  for atts in attribute_data loop   need to join with list of
  --       null;                        LDAP supported attributes
  --  end loop;
  -- dbms_ldap.modify(...)

  emp_dn := 'cn=EDDIE.LAWSON,'||p_user_base;

  -- Create and setup attribute array for the New entry
  emp_array := DBMS_LDAP.create_mod_array(2);

  emp_vals(1) := 'Try this out!';

  DBMS_LDAP.populate_mod_array(emp_array,DBMS_LDAP.MOD_REPLACE,
                               'description',emp_vals);

  emp_vals(1) := '1231234';

  DBMS_LDAP.populate_mod_array(emp_array,DBMS_LDAP.MOD_REPLACE,
                               'telephonenumber',emp_vals);

  -- Modify entry in ldap directory
  retval := DBMS_LDAP.modify_s(my_session,emp_dn,emp_array);
************** NOT IMPLEMENTED *************************/
end update_ldap;
------------------------------------------------------------------------------
/*
** synch_concurrent - <Described in WFLDAPS.pls>
*/
PROCEDURE synch_concurrent(errbuf   out NOCOPY varchar2,
                           retcode  out NOCOPY varchar2,
                           p_mode   in  varchar2 default 'CHANGES') is
  errname  varchar2(30);
  errmsg   varchar2(2000);
  errstack varchar2(4000);
  val      boolean := FALSE;
begin
  if (p_mode = 'CHANGES') then
    if (wf_ldap.synch_changes() = TRUE) then
      -- Return 0 for successful completion --
      errbuf  := '';
      retcode := '0';
    else
      errbuf  := 'FAILED';
      retcode := '2';
    end if;
  elsif (p_mode = 'ALL') then
    if (wf_ldap.synch_all() = TRUE) then
      -- Return 0 for successful completion --
      errbuf  := '';
      retcode := '0';
    else
      errbuf  := 'FAILED';
      retcode := '2';
    end if;
  end if;
exception
  when others then
    wf_core.get_error(errname, errmsg, errstack);
    if (errmsg is not null) then
      errbuf := errmsg;
    else
      errbuf := sqlerrm;
    end if;

    -- Return 2 for error --
    retcode := '2';
end synch_concurrent;
------------------------------------------------------------------------------
/*
** schedule_changes - <Described in WFLDAPS.pls>
*/
PROCEDURE schedule_changes(
  l_day in pls_integer default 0,
  l_hour in pls_integer default 0,
  l_minute in pls_integer default 10
)
is
  retval     pls_integer := -1;
  l_rundate  date;
  l_job      pls_integer;
  l_sec      pls_integer := 0;
begin

  l_job := to_number(NULL);
  l_rundate := to_date(null);

  DBMS_JOB.Submit(
    job=>l_job,
      what=>'declare err boolean; begin err := WF_LDAP.synch_changes; end;',
      next_date=>nvl(l_rundate, sysdate),
      interval=>to_date(null)
   );

  -- next rundate should be future date
  if (Wf_Setup.JobNextRunDate(l_job,l_day,l_hour,l_minute,l_sec)
      <= sysdate) then
    wf_core.raise('WFE_LATER_INTERVAL');
  end if;

  DBMS_JOB.Interval(
    job=>l_job,
    interval=>'Wf_Setup.JobNextRunDate('||to_char(l_job)||','||
              to_char(l_day)||','||
              to_char(l_hour)||','||
              to_char(l_minute)||','||
              to_char(l_sec)||')'
  );

  -- force it to run the first time
  if (l_rundate is null) then
    DBMS_JOB.Run(
      job=>l_job
    );
  end if;

  commit;

exception
  when others then
    wf_core.context('WF_LDAP', 'schedule_changes',
                    'Error code: '||to_char(sqlcode),
                    'Error Message: '||substr(sqlerrm, 1, 238));
    raise;
end schedule_changes;
------------------------------------------------------------------------------
end WF_LDAP;

/

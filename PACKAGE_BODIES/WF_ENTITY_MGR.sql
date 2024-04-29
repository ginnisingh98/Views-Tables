--------------------------------------------------------
--  DDL for Package Body WF_ENTITY_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ENTITY_MGR" as
/* $Header: WFEMGRB.pls 120.3.12010000.2 2010/03/09 21:02:43 alsosa ship $ */
------------------------------------------------------------------------------
/*
** InitCache - <private> Creates the 'CACHE_CHANGED' attribute for a specific
**                       entity_type/entity_key
*/
procedure InitCache(p_entity_type in varchar2,
                    p_entity_key_value in varchar2) is
  pragma autonomous_transaction;
begin
  insert into wf_attribute_cache (
  entity_type,
  entity_key_value,
  attribute_name,
  attribute_value,
  last_update_date,
  change_number)
 values
  (p_entity_type,
   upper(p_entity_key_value),
   'CACHE_CHANGED',
   'PENDING',
   sysdate,
   NULL);

  --We commit the transaction so all sessions can see the attribute.
  commit;
exception
  when DUP_VAL_ON_INDEX then
    --This can occur from race condition (two sessions tried to update at
    --same time).
    null;
end;

/*
** put - <private> construct cache rows
*/
PROCEDURE put(p_entity_type      in varchar2,
              p_entity_key_value in varchar2,
              p_att              in varchar2,
              p_value            in varchar2,
              p_change_number    in number ) is

  l_cacheLocked boolean;

begin


  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then

      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
         'wf.plsql.WF_ENTITY_MGR.put',
                       'Begin put('||p_entity_type||', '||
                       p_entity_key_value||', '||p_att||', '||
                       p_value||', '||p_change_number||')');
  end if;

  if (p_value = '*UNKNOWN*') then
    return;
  elsif (p_att <> 'CACHE_CHANGED') then
    --First lock the cache or call InitCache() if the attribute
    --does not exist..
    l_cacheLocked := FALSE;
    while not (l_cacheLocked) loop
      update wf_attribute_cache
      set    attribute_value = 'YES'
      where  entity_type = p_entity_type
      and    entity_key_value = upper(p_entity_key_value)
      and    attribute_name = 'CACHE_CHANGED';

      if sql%notfound then
        WF_ENTITY_MGR.InitCache(put.p_entity_type,
                                put.p_entity_key_value);
      else
        --We locked the cache so we can exit the loop.
        l_cacheLocked := TRUE;
      end if;
    end loop;
  end if;

  --We acquired a lock on the entity_type/entity_key so we can update/create
  --Attributes.
  update wf_attribute_cache
  set    attribute_value = nvl(p_value, '*NULL*'),
         last_update_date = sysdate,
         change_number = nvl(p_change_number, change_number)
  where  entity_type = p_entity_type
  and    entity_key_value = upper(p_entity_key_value)
  and    attribute_name = upper(p_att);

  --No need to worry about race condition here because we have a lock on the
  --entity_type/entity_key.
  if SQL%notfound then
    insert into wf_attribute_cache (
      entity_type,
      entity_key_value,
      attribute_name,
      attribute_value,
      last_update_date,
      change_number)
        values
     (p_entity_type,
      upper(p_entity_key_value),
      upper(p_att),
      nvl(p_value, '*NULL*'),
      sysdate,
      p_change_number);
  end if;

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then

      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
         'wf.plsql.WF_ENTITY_MGR.put',
                       'End put('||p_entity_type||', '||
                       p_entity_key_value||', '||p_att||', '||
                       p_value||', '||p_change_number||')');
  end if;

end;
------------------------------------------------------------------------------
/*
** process_changes - <described in WFEMGRS.pls>
*/
PROCEDURE process_changes(p_entity_type      in varchar2,
                          p_entity_key_value in varchar2,
                          p_change_source    in varchar2,
                          p_change_type      in varchar2 ,
                          p_event_name       in varchar2 )
is
  my_user_base varchar2(256);
  my_ent_type  varchar2(50) := upper(p_entity_type);
  my_parms     wf_parameter_list_t;
  my_key_value varchar2(256);
begin

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then

      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
         'wf.plsql.WF_ENTITY_MGR.process_changes',
                       'Begin process_changes('||p_entity_type||', '||
                       p_entity_key_value||', '||p_change_source||', '||
                       p_change_type||', '||p_event_name||')');
  end if;

  if (wf_entity_mgr.get_attribute_value(my_ent_type, p_entity_key_value,
                                       'CACHE_CHANGED') = 'YES') then
    --
    -- Tell everybody about the change by raising the appropriate event
    --
    -- First, mark this entity in the cache as unchanged so we can pick up
    -- any actual subsequent changes
    --
    wf_entity_mgr.put_attribute_value(my_ent_type, p_entity_key_value,
                                     'CACHE_CHANGED', 'NO');
    wf_event.AddParameterToList('CHANGE_SOURCE', p_change_source, my_parms);
    wf_event.AddParameterToList('CHANGE_TYPE', p_change_type, my_parms);

    if (p_event_name is null) then
      wf_event.raise('oracle.apps.global.'||lower(my_ent_type)||'.change',
                     upper(p_entity_key_value), null, my_parms);
    else
      wf_event.raise(p_event_name, upper(p_entity_key_value), null, my_parms);
    end if;
  end if;

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then

      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
         'wf.plsql.WF_ENTITY_MGR.process_changes',
                       'End process_changes('||p_entity_type||', '||
                       p_entity_key_value||', '||p_change_source||', '||
                       p_change_type||', '||p_event_name||')');
  end if;

end;
------------------------------------------------------------------------------
/*
** get_attribute_value - <described in WFEMGRS.pls>
*/
FUNCTION get_attribute_value(p_entity_type      in varchar2,
                             p_entity_key_value in varchar2,
                             p_attribute        in varchar2) return varchar2
is
  my_att_val  varchar2(4000);
begin

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then

      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
         'wf.plsql.WF_ENTITY_MGR. get_attribute_value',
                       'Begin  get_attribute_value('||p_entity_type||', '||
                       p_entity_key_value||', '||
                       p_attribute||')');
  end if;

  select attribute_value into my_att_val
  from   wf_attribute_cache
  where  entity_type = upper(p_entity_type)
  and    entity_key_value = upper(p_entity_key_value)
  and    attribute_name = upper(p_attribute);

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then

      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
         'wf.plsql.WF_ENTITY_MGR. get_attribute_value',
                       'End  get_attribute_value('||p_entity_type||', '||
                       p_entity_key_value||', '||
                       p_attribute||')');
  end if;

  return my_att_val;
exception when no_data_found then
  if (wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_UNEXPECTED,
                       'wf.plsql.WF_ENTITY_MGR. get_attribute_value',
                       'Exception: '||sqlerrm);
  end if;

  return '*UNKNOWN*';
end;
------------------------------------------------------------------------------
/*
** put_attribute_value - <described in WFEMGRS.pls>
*/
PROCEDURE put_attribute_value(p_entity_type      in varchar2,
                              p_entity_key_value in varchar2,
                              p_attribute        in varchar2,
                              p_attribute_value  in varchar2)
is
  old_att_val varchar2(4000);
  my_ent_type varchar2(50) := upper(p_entity_type);
begin

 if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then

      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
         'wf.plsql.WF_ENTITY_MGR. put_attribute_value',
                     'Begin put_attribute_value('||p_entity_type||', '||
                     p_entity_key_value||', '||
                     p_attribute||', '||p_attribute_value||')');
 end if;

  if (p_attribute = 'CACHE_CHANGED') then
    wf_entity_mgr.put(my_ent_type,
                      p_entity_key_value,
                      'CACHE_CHANGED',
                      p_attribute_value,
                      NULL);

  elsif (p_attribute_value = '*UNKNOWN*') then
    null;

  elsif (p_attribute_value is null) then
    null;  -- means "do not update" like for fndload --
           -- if you want to null out a value, use *NULL* --
  else
    old_att_val := wf_entity_mgr.get_attribute_value(my_ent_type,
                                                     p_entity_key_value,
                                                     p_attribute);
    if (p_attribute_value <> old_att_val) then
      wf_entity_mgr.put(my_ent_type,
                        p_entity_key_value,
                        p_attribute,
                        p_attribute_value,
                        NULL);
    end if;
  end if;
 if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then

    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
         'wf.plsql.WF_ENTITY_MGR. put_attribute_value',
                       'End put_attribute_value('||p_entity_type||', '||
                       p_entity_key_value||', '||
                       p_attribute||', '||p_attribute_value||')');

 end if;

end;
------------------------------------------------------------------------------
/*
** flush_cache - <described in WFEMGRS.pls>
*/
PROCEDURE flush_cache(p_entity_type      in varchar2 ,
                      p_entity_key_value in varchar2 )
is
  pragma autonomous_transaction;
begin
  if (p_entity_type = '*ALL*') then
    purge_cache_attributes(sysdate);
  elsif ((p_entity_type is NOT NULL) and (p_entity_key_value is NOT NULL)) then
    delete from wf_attribute_cache
    where  entity_type = upper(p_entity_type)
    and    entity_key_value = upper(p_entity_key_value);
  else
    delete from wf_attribute_cache
    where  ((entity_type is NULL) or (entity_type = upper(p_entity_type)))
    and    ((entity_key_value is NULL) or
            (entity_key_value = upper(p_entity_key_value)));
  end if;

  commit;
exception
  when others then
    wf_core.context('WF_ENTITY_MGR', 'flush_cache', p_entity_type);
    raise;
end;
------------------------------------------------------------------------------
/*
** get_entity_type - <described in WFEMGRS.pls>
*/
FUNCTION get_entity_type(p_event_name in varchar2) return varchar2 is
  a  number := instr(p_event_name,'.',-1,2)+1;
  b  number := instr(p_event_name,'.',-1) - a;
begin
  return upper( substr(p_event_name, a, b) );
end;
------------------------------------------------------------------------------
/*
** gen_xml_payload - <described in WFEMGRS.pls>
*/
FUNCTION gen_xml_payload(p_event_name in varchar2,
                         p_event_key  in varchar2) return clob
is
  my_clob     clob;
  my_ent_type varchar2(50) := wf_entity_mgr.get_entity_type(p_event_name);
  found       boolean := FALSE;

  l_doc      xmldom.DOMDocument;
  l_root     xmldom.DOMNode;
  l_node     xmldom.DOMNode;

  cursor attribute_data is
    select attribute_name aname,
           attribute_value avalue
    from   wf_attribute_cache
    where  entity_type = my_ent_type
    and    entity_key_value = upper(p_event_key)
    and    attribute_name <> 'CACHE_CHANGED';

begin
  l_doc  := xmldom.newDOMDocument;
  l_root := xmldom.makeNode(l_doc);
  l_root := wf_event_xml.newtag(l_doc, l_root, my_ent_type);

  for atts in attribute_data loop
    l_node := wf_event_xml.newtag(l_doc, l_root, atts.aname, atts.avalue);
    found := TRUE;
  end loop;

  if (found) then
    dbms_lob.createtemporary(my_clob, FALSE);
    xmldom.writeToClob(l_root, my_clob);
    return my_clob;
  else
    return null;
  end if;
end;
---------------------------------------------------------------------------
/*
** isChanged - <Described in WFEMGRS.pls>
*/
FUNCTION isChanged(p_new_val in varchar2,
                   p_old_val in varchar2) return boolean is
  retval boolean := FALSE;
begin
  if (p_new_val = '*UNKNOWN*') then
    retval := FALSE;
  elsif (p_new_val <> p_old_val) then
    retval := TRUE;
  end if;

  return retval;
end;

------------------------------------------------------------------------------
/*
** purge_entities - Described in WFEMGRS.pls
*/
PROCEDURE purge_cache_attributes (p_enddate date) is

begin
  delete from WF_ATTRIBUTE_CACHE
  where LAST_UPDATE_DATE <= p_enddate;
exception
  when no_data_found then
    null;
  when others then
    wf_core.context('WF_ENTITY_MANAGER', 'purge_cache_attributes', p_enddate);
    raise;
end;
------------------------------------------------------------------------------
end WF_ENTITY_MGR;

/

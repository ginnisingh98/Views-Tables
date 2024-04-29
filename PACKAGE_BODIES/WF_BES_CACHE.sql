--------------------------------------------------------
--  DDL for Package Body WF_BES_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_BES_CACHE" as
/* $Header: WFBECACB.pls 120.6.12010000.3 2012/10/30 13:14:17 alsosa ship $ */

/*---------+
 | Globals |
 +---------*/
g_Event_Idx  number := 1;
g_Agent_Idx  number := 2;
g_System_Idx number := 3;

g_event_const  varchar2(30) := 'EVENTS';
g_agent_const  varchar2(30) := 'AGENTS';
g_system_const varchar2(30) := 'SYSTEMS';

g_src_type_local    varchar2(8) := 'LOCAL';
g_src_type_external varchar2(8) := 'EXTERNAL';
g_src_type_error    varchar2(8) := 'ERROR';

g_event_any         varchar2(240) := 'oracle.apps.wf.event.any';
g_event_unexpected  varchar2(240) := 'oracle.apps.wf.event.unexpected';

g_java_sub     varchar2(240) := 'java://';

g_status_yes   varchar2(1) := 'Y';
g_status_no    varchar2(1) := 'N';

g_date_mask    varchar2(26) := 'YYYY/MM/DD HH24:MI:SS';

g_initialized  boolean := false;

-- Initialize (PRIVATE)
--   Procedure to initialize the cache management related variables like
--   cache size, hash size etc.
procedure Initialize
is
  l_cache_size number;
begin
  if (g_initialized) then
    return;
  end if;

  -- the token value may not have been loaded, null or may be a non-numeric
  -- value specified. in such cases, default it to 50.
  begin
    l_cache_size := to_number(wf_core.translate('WFBES_MAX_CACHE_SIZE'));
  exception
    when others then
      l_cache_size := 50;
  end;

  wf_object_cache.SetCacheSize(l_cache_size);

  g_local_system_guid := hextoraw(wf_core.translate('WF_SYSTEM_GUID'));
  g_local_system_status := wf_core.translate('WF_SYSTEM_STATUS');
  g_schema_name       := wf_core.translate('WF_SCHEMA');
  begin
    SELECT name
    INTO   g_local_system_name
    FROM   wf_systems
    WHERE  guid = g_local_system_guid;
  exception
    when no_data_found then
      g_local_system_name := null;
  end;
  g_initialized := true;
end Initialize;

-- SetMetaDataUploaded
--   This procedure is called from the BES table handlers when meta-data
--   is being uploaded to the database tables. This procedure sets a BES
--   caching context with the sysdate when the meta-data is loaded.
procedure SetMetaDataUploaded
is
  --Bug 14602624. Deferred agent listener runs by under the SYSADMIN schema. It
  --needs to be set for name spaces not to get lost
  l_username FND_USER.USER_NAME%TYPE := nvl(FND_GLOBAL.user_name,'SYSADMIN');
begin
  dbms_session.set_context(namespace => 'WFBES_CACHE_CTX',
                           attribute => 'WFBES_METADATA_UPLOADED',
                           value     => to_char(sysdate, g_date_mask),
                           client_id => l_username);
exception
  when others then
    wf_core.context('WF_BES_CACHE', 'MetaDataUploaded');
    raise;
end SetMetaDataUploaded;

-- GetMetaDataUploaded (PRIVATE)
--   This function returns the date at which BES meta-data was last uploaded
--   to the database after the session's cache was initialized.
function GetMetaDataUploaded
return date
is
  l_value varchar2(4000);
begin
  l_value := sys_context('WFBES_CACHE_CTX', 'WFBES_METADATA_UPLOADED');
  return to_date(l_value, g_date_mask);
exception
  when others then
    wf_core.context('WF_BES_CACHE', 'GetMetaDataUploaded');
    raise;
end GetMetaDataUploaded;

-- SetMetaDataCached (PRIVATE)
--   This procedure is called when cache is created to set the timestamp
--   at which the cache is initialized for this session
procedure SetMetaDataCached(p_date in date)
is
begin
  -- If the date is already set in this session, do not set it again
  -- or if the p_date is null, we want to reset the last cache update
  if (g_LastCacheUpdate is null or p_date is null) then
    g_LastCacheUpdate := p_date;
  end if;
end SetMetaDataCached;

-- CacheValid
--   This function validates if the current session's cache is valid or
--   not. This procedure compares the time at which the meta-data was
--   loaded into the database with the time at which the sessions cache
--   was initialized. If the former is greater than the latter, new data
--   has been uploaded to the database and cache is invalid.
-- RETURN
--   Boolean status of whether cache is valid or not
function CacheValid
return boolean
is
  l_lastMetaUpload date;
begin
  l_lastMetaUpload := GetMetaDataUploaded();

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement,
                    'wf.plsql.WF_BES_CACHE.CacheValid.Check',
                    'Last upload time {'||to_char(l_lastMetaUpload, g_date_mask)||
                    '} Last cache time {'||to_char(g_LastCacheUpdate, g_date_mask)||'}');
  end if;

  if (l_lastMetaUpload is not null and g_LastCacheUpdate is not null and
      l_lastMetaUpload > g_LastCacheUpdate) then
    return false;
  end if;
  return true;
end CacheValid;

-- ClearCache
--   Clears the cached objects from memory and resets requires variables
--   given the name of the cache.
procedure ClearCache
is
begin
  wf_object_cache.Clear();
  g_initialized := false;
  SetMetaDataCached(null);
end ClearCache;

-- ValidateCache (PRIVATE)
--   This procedure validates the cache and clears if found invalid
procedure ValidateCache
is
begin
  -- if cache is invalid, clear it so that it can be rebuilt from database
  if (not CacheValid()) then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_BES_CACHE.ValidateCache.Cache_Invalid',
                      'Cache is invalid. Clearing the cache');
    end if;
    ClearCache();
  end if;
end ValidateCache;

--
-- EVENTS and SUBSCRIPTIONS caching routines
--

-- Get_Event_Object (PRIVATE)
--   This procedure sets the given event object to the Object cache. This
--   procedure set the event object to the appropriate cache created for
--   events
procedure Get_Event_Object(p_event_name in  varchar2,
                           p_event_obj  in out nocopy WF_Event_Obj)
is
  l_any_data AnyData;
  l_dummy    pls_integer;
begin
  -- Get the event from the object cache
  l_any_data := wf_object_cache.GetObject(g_Event_Idx, p_event_name);
  if (l_any_data is not null) then
    l_dummy := l_any_data.getObject(p_event_obj);
  else
    p_event_obj := null;
  end if;
end Get_Event_Object;

-- Set_Event_Object (PRIVATE)
--   This procedure gets the event object from the Object cache for the given
--   event name.
procedure Set_Event_Object(p_event_name in varchar2,
                           p_event_obj  in WF_Event_Obj)
is
  l_any_data AnyData;
begin
  -- Store this object in the cache for future use
  l_any_data := sys.AnyData.ConvertObject(p_event_obj);
  wf_object_cache.SetObject(g_Event_Idx, l_any_data, p_event_name);
end Set_Event_Object;

-- Load_Event (PRIVATE)
--   Given the event name, this procedure loads the event information to the
--   wf_event_obj instance
procedure Load_Event(p_event_name in varchar2,
                     p_event_obj   in out nocopy wf_event_obj)
is

  CURSOR c_get_event (cp_event_name varchar2) IS
  SELECT guid, name, type, status, generate_function,
         java_generate_func, licensed_flag
  FROM   wf_events
  WHERE  name = cp_event_name;

begin
  if (p_event_obj is null) then
    wf_event_obj.Initialize(p_event_obj);
  end if;

  open c_get_event(p_event_name);
  fetch c_get_event into p_event_obj.guid, p_event_obj.name, p_event_obj.type,
                         p_event_obj.status, p_event_obj.generate_function,
                         p_event_obj.java_generate_func, p_event_obj.licensed_flag;
  if (c_get_event%NOTFOUND) then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_BES_CACHE.Load_Event.Not_Found',
                      'Event {'||p_event_name||'} not found in the database');
    end if;
    -- If event not found in the set wf_event_obj to null
    p_event_obj := null;
  end if;
  close c_get_event;

end Load_Event;

-- Load_Subscriptions (PRIVATE)
--   Given the event name this procedure loads all the valid subscriptions
--   into the wf_event_obj
procedure Load_Subscriptions(p_event_name   in varchar2,
                             p_source_type  in varchar2,
                             p_source_agent in raw,
                             p_subs_count   in out nocopy number,
                             p_event_obj    in out nocopy wf_event_obj)
is

  -- Cursor from wf_event.Dispatch that fetches all the valid subscriptions to the
  -- event and the event group to which the event belongs
  cursor active_subs (cp_event_name        varchar2,
                      cp_source_type       varchar2,
                      cp_source_agent_guid raw)
  is
  select subscription_guid,
         system_guid,
         subscription_source_type,
         subscription_source_agent_guid,
         subscription_phase,
         subscription_rule_data,
         subscription_out_agent_guid,
         subscription_to_agent_guid,
         subscription_priority,
         subscription_rule_function,
         wf_process_type,
         wf_process_name,
         subscription_parameters,
         '',
         '',
         '',
         '',
         '',
         subscription_on_error_type,
         ''
  from wf_active_subscriptions_v
  where event_name in(cp_event_name, g_event_any)
  and   subscription_source_type = cp_source_type
  and   ((subscription_source_agent_guid is NOT NULL AND
          subscription_source_agent_guid = nvl(cp_source_agent_guid, subscription_source_agent_guid))
          OR subscription_source_agent_guid is NULL)
  and   system_guid = wf_bes_cache.g_local_system_guid
  order by 5;

  cursor active_event_subs(cp_event_name        varchar2,
                           cp_source_type       varchar2,
                           cp_source_agent_guid raw)
  is
  (select sub.guid                  sub_guid,
          sub.system_guid           sys_guid,
          sub.source_type           src_type,
          sub.source_agent_guid     src_agt,
          nvl(sub.phase,0)          phase,
          sub.rule_data             rule_data,
	  sub.out_agent_guid        out_agt,
          sub.to_agent_guid         to_agt,
          sub.priority              priority,
	  DECODE(sub.rule_function, NULL,
                 DECODE(sub.java_rule_func, NULL, NULL,
                        g_java_sub||sub.java_rule_func),
	         sub.rule_function) rule_func,
          sub.wf_process_type       proc_type,
          sub.wf_process_name       proc_name,
          sub.parameters            params,
          sub.expression            exp,
          sub.invocation_id         inv_id,
          sub.map_code              map_code,
          sub.standard_type         std_type,
          sub.standard_code         std_code,
          sub.on_error_code         on_error,
          sub.action_code           action
   from   wf_event_subscriptions sub,
          wf_events evt
   where  sub.system_guid   = wf_event.local_system_guid
   and    sub.status        = 'ENABLED'
   and    sub.licensed_flag = 'Y'
   and    sub.source_type   = cp_source_type
   and    ((sub.source_agent_guid is NOT NULL AND
           sub.source_agent_guid = nvl(cp_source_agent_guid, sub.source_agent_guid))
           OR sub.source_agent_guid is NULL)
   and    sub.event_filter_guid  = evt.guid
   and    evt.name          = cp_event_name
   and    evt.type          = 'EVENT'
   and    evt.status        = 'ENABLED'
   and    evt.licensed_flag = 'Y')
   order by 5;

   l_subscription WF_Event_Subs_Obj;
   l_count        number;
begin

  -- Check if subscriptions are already loaded for this source type
  if (upper(p_event_obj.GetSubsLoaded(p_source_type)) = g_status_yes) then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_BES_CACHE.Load_Subscriptions.Check',
                      p_source_type||' subscriptions for event {'||
                      p_event_name||'} are already loaded.');
    end if;
    return;
  end if;

  WF_Event_Subs_Obj.Initialize(l_subscription);
  l_count := 0;

  -- Load all LOCAL subscriptions from the Database
  if (lower(p_event_name) in (g_event_unexpected, g_event_any)) then
    open active_event_subs(p_event_name, p_source_type, p_source_agent);
    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_procedure,
                       'wf.plsql.WF_BES_CACHE.Load_Subscriptions.active_event_subs',
                       'Using cursor active_event_subs for event {'||p_event_name||'}');
    end if;

    loop
      fetch active_event_subs into l_subscription.GUID,
                                   l_subscription.SYSTEM_GUID,
                                   l_subscription.SOURCE_TYPE,
                                   l_subscription.SOURCE_AGENT_GUID,
                                   l_subscription.PHASE,
                                   l_subscription.RULE_DATA,
                                   l_subscription.OUT_AGENT_GUID,
                                   l_subscription.TO_AGENT_GUID,
                                   l_subscription.PRIORITY,
                                   l_subscription.RULE_FUNCTION,
                                   l_subscription.WF_PROCESS_TYPE,
                                   l_subscription.WF_PROCESS_NAME,
                                   l_subscription.PARAMETERS,
                                   l_subscription.EXPRESSION,
                                   l_subscription.INVOCATION_ID,
                                   l_subscription.MAP_CODE,
                                   l_subscription.STANDARD_TYPE,
                                   l_subscription.STANDARD_CODE,
                                   l_subscription.ON_ERROR_CODE,
                                   l_subscription.ACTION_CODE;

      exit when active_event_subs%NOTFOUND;

      -- This is an optimization flag to indicate that the subcription list has
      -- non-null source agent For an agent listener session, if this flag is Y,
      -- the list will be searched. Else the complete subscription list is returned
      if (l_subscription.SOURCE_AGENT_GUID is not null) then
        p_event_obj.SetSourceAgentAvl(p_source_type, g_status_yes);
      end if;

      p_event_obj.AddSubscriptionToList(l_subscription, p_source_type);
      l_count := l_count+1;
    end loop;
    close active_event_subs;
  else
    open active_subs(p_event_name, p_source_type, p_source_agent);
    if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_procedure,
                       'wf.plsql.WF_BES_CACHE.Load_Subscriptions.active_subs',
                       'Using cursor active_subs for event {'||p_event_name||'}');
    end if;

    loop
      fetch active_subs into l_subscription.GUID,
                             l_subscription.SYSTEM_GUID,
                             l_subscription.SOURCE_TYPE,
                             l_subscription.SOURCE_AGENT_GUID,
                             l_subscription.PHASE,
                             l_subscription.RULE_DATA,
                             l_subscription.OUT_AGENT_GUID,
                             l_subscription.TO_AGENT_GUID,
                             l_subscription.PRIORITY,
                             l_subscription.RULE_FUNCTION,
                             l_subscription.WF_PROCESS_TYPE,
                             l_subscription.WF_PROCESS_NAME,
                             l_subscription.PARAMETERS,
                             l_subscription.EXPRESSION,
                             l_subscription.INVOCATION_ID,
                             l_subscription.MAP_CODE,
                             l_subscription.STANDARD_TYPE,
                             l_subscription.STANDARD_CODE,
                             l_subscription.ON_ERROR_CODE,
                             l_subscription.ACTION_CODE;

      exit when active_subs%NOTFOUND;

      -- This is an optimization flag to indicate that the subcription list has
      -- non-null source agent For an agent listener session, if this flag is Y,
      -- the list will be searched. Else the complete subscription list is returned
      if (l_subscription.SOURCE_AGENT_GUID is not null) then
        p_event_obj.SetSourceAgentAvl(p_source_type, g_status_yes);
      end if;

      p_event_obj.AddSubscriptionToList(l_subscription, p_source_type);
      l_count := l_count+1;
    end loop;
    close active_subs;
  end if;

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure,
                    'wf.plsql.WF_BES_CACHE.Load_Subscriptions.End',
                    'Loaded {'||l_count||'} '||p_source_type||' subscriptions '||
                    'for event {'||p_event_name||'}');
  end if;

  p_event_obj.SetSubsLoaded(p_source_type, g_status_yes);
  p_subs_count := l_count;
end Load_Subscriptions;

-- GetEventByName
--   This function returns an instance of WF_Event_Obj object type which
--   contains the complete event information along with valid subscriptions
--   to the event. The information could come from the cache memory or from
--   the database.
-- IN
--   p_event_name - Event name whose information is required
function GetEventByName(p_event_name  in varchar2)
return wf_event_obj
is
  l_event_obj wf_event_obj;
  l_any_data  anyData;
  l_dummy     pls_integer;
begin
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure,
                    'wf.plsql.WF_BES_CACHE.GetEventByName.Begin',
                    'Getting event details for {'||p_event_name||'}');
  end if;

  l_event_obj := null;

  if (not g_initialized) then
    Initialize();
  end if;

  ValidateCache();

  -- Each object type being cached is identified by a number within
  -- the session
  if (not wf_object_cache.IsCacheCreated(g_Event_Idx)) then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_BES_CACHE.GetEventByName.Create_Cache',
                      'Cache is not created for EVENTS index {'||g_Event_Idx||'}');
    end if;
    wf_object_cache.CreateCache(g_Event_Idx);
    SetMetaDataCached(sysdate);
  else
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_BES_CACHE.GetEventByName.Cache_Get',
                      'Getting the event from Cache');
    end if;
    Get_Event_Object(p_event_name, l_event_obj);
  end if;

  -- If the event is not in the object cache, initialize the object and
  -- retrieve the details from the database
  if (l_event_obj is null) then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_BES_CACHE.GetEventByName.Load_Event',
                      'Event not found in cache. Loading from Database');
    end if;
    -- Load event from the database to the object
    Load_Event(p_event_name, l_event_obj);

    if (l_event_obj is not null) then
      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_BES_CACHE.GetEventByName.Set_Cache',
                        'Setting event {'||p_event_name||'} to cache');
      end if;
      Set_Event_Object(p_event_name, l_event_obj);
    end if;
  end if;

  -- return the event object only if the event is ENABLED and product licensed
  if (l_event_obj is not null and
       l_event_obj.STATUS = 'ENABLED' and
	 l_event_obj.LICENSED_FLAG = 'Y') then
    return l_event_obj;
  else
    return null;
  end if;

exception
  when others then
    wf_core.context('WF_BES_CACHE', 'GetEventByName', p_event_name);
    raise;
end GetEventByName;

-- GetSubscriptions
--   This function returns a table of WF_EVENT_SUBS_OBJ that are the valid
--   subscriptions to the given event.
function GetSubscriptions(p_event_name   in varchar2,
                          p_source_type  in varchar2,
                          p_source_agent in raw)
return wf_event_subs_tab
is
  l_event_obj     wf_event_obj;
  l_any_data      anyData;
  l_dummy         pls_integer;
  l_subs_count    number;
begin
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure,
                    'wf.plsql.WF_BES_CACHE.GetSubscriptions.Begin',
                    'Getting subscriptions for event {'||p_event_name||'}'||
                    ' Source Type {'||p_source_type||'} Source Agt {'||p_source_agent||'}');
  end if;

  -- Get the event information from the cache or the database
  l_event_obj := GetEventByName(p_event_name);

  -- Event not found in the cache as well as in database or disabled
  if (l_event_obj is null) then
    return null;
  end if;

  -- Load subscriptions for a given source type if not already loaded
  if (upper(l_event_obj.GetSubsLoaded(p_source_type)) = g_status_no) then

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_BES_CACHE.GetSubscriptions.Load_Subs',
                      'Subscriptions for {'||p_event_name||'} is not already loaded.'||
                      ' Loading from DB for Source Type {'||p_source_type||
                      '} Source Agt {'||p_source_agent||'}');
    end if;

    -- NOTE: within an agent listener's session we would only require subscriptions
    -- with the same source_agent_guid. so it should be ok to cache only subscriptions
    -- with that source_agent_guid and with null source_agent_guid
    -- TODO!! currently we are loading for all source_agent_guid

    -- load subscriptions for all source_agents if not already loaded
    Load_Subscriptions(p_event_name, p_source_type, null, l_subs_count, l_event_obj);
    Set_Event_Object(p_event_name, l_event_obj);
  else
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_BES_CACHE.GetSubscriptions.Subs_Loaded',
                      'Subscriptions for {'||p_event_name||'} is already loaded to cache');
    end if;
  end if;

  -- If p_source_agent is not null, dispatcher needs only subscriptions
  -- with the specified SOURCE_AGENT_GUID
  if (p_source_agent is not null and
       l_event_obj.GetSourceAgentAvl(p_source_type) = g_status_yes) then
    return l_event_obj.GetSubscriptionBySrcAgtGUID(p_source_type, p_source_agent);
  else
    -- All subscriptions for a given event are loaded for the given source type
    return l_event_obj.GetSubscriptionList(p_source_type);
  end if;
exception
  when others then
    wf_core.context('WF_BES_CACHE', 'GetSubscriptions', p_event_name, p_source_type);
    raise;
end GetSubscriptions;

-- GetSubscriptionByGUID
--   This function returns a WF_EVENT_SUBS_OBJ that contains the subscription
--   to the given event and mathing the given subscription GUID.
function GetSubscriptionByGUID(p_event_name in varchar2,
                                p_sub_guid   in raw)
return wf_event_subs_obj
is
  l_event_obj   WF_Event_Obj;
  l_subs_count  number;
  l_subs_loaded boolean;
begin
  -- If either of the parameter values are null, no info can be returned
  if (p_event_name is null or p_sub_guid is null) then
    return null;
  end if;

  l_event_obj := wf_bes_cache.GetEventByName(p_event_name);

  if (l_event_obj is null) then
    return null;
  end if;

  l_subs_loaded := false;
  -- Load subscriptions if not already loaded
  if (upper(l_event_obj.GetSubsLoaded(g_src_type_local)) = g_status_no) then
    Load_Subscriptions(p_event_name, g_src_type_local, null, l_subs_count, l_event_obj);
    l_subs_loaded := true;
  end if;
  if (upper(l_event_obj.GetSubsLoaded(g_src_type_external)) = g_status_no) then
    Load_Subscriptions(p_event_name, g_src_type_external, null, l_subs_count, l_event_obj);
    l_subs_loaded := true;
  end if;
  if (upper(l_event_obj.GetSubsLoaded(g_src_type_error)) = g_status_no) then
    Load_Subscriptions(p_event_name, g_src_type_error, null, l_subs_count, l_event_obj);
    l_subs_loaded := true;
  end if;

  if (l_subs_loaded) then
    -- Set the event object to cache if in case some subscriptions were loaded
    Set_Event_Object(p_event_name, l_event_obj);
  end if;

  return l_event_obj.GetSubscriptionByGUID(p_sub_guid);
exception
  when others then
    wf_core.context('WF_BES_CACHE', 'GetSubscriptionByGUID', p_event_name, p_sub_guid);
    raise;
end GetSubscriptionByGUID;

--
-- AGENTS caching routines
--

-- Get_Agent_Object (PRIVATE)
--   This procedure sets the given agent object to the Object cache. This
--   procedure sets the agent object to the appropriate cache created for
--   agents
procedure Get_Agent_Object(p_agent_key in  varchar2,
                           p_agent_obj in out nocopy WF_Agent_Obj)
is
  l_any_data AnyData;
  l_dummy    pls_integer;
begin
  -- Get the agent from the object cache
  l_any_data := wf_object_cache.GetObject(g_Agent_Idx, p_agent_key);
  if (l_any_data is not null) then
    l_dummy := l_any_data.getObject(p_agent_obj);
  else
    p_agent_obj := null;
  end if;
end Get_Agent_Object;

-- Set_Agent_Object (PRIVATE)
--   This procedure gets the agent object from the Object cache for the given
--   agent name + system name.
procedure Set_Agent_Object(p_agent_key in varchar2,
                           p_agent_obj in WF_Agent_Obj)
is
  l_any_data AnyData;
begin
  -- Store this object in the cache for future use
  l_any_data := sys.AnyData.ConvertObject(p_agent_obj);
  wf_object_cache.SetObject(g_Agent_Idx, l_any_data, p_agent_key);
end Set_Agent_Object;

-- Load_Agent (PRIVATE)
--   Given the agent name and system name, this procedure loads the agent
--   information to the wf_agent_obj instance. This procedure takes agent
--   name, system name and agent guid as inputs.
-- o if agent name and system name are not null, it uses this to get info
-- o if agent name and/or system name are null and agent guid is not null
--   it agent guid to get the info
procedure Load_Agent(p_agent_guid  in raw,
                     p_agent_name  in varchar2,
                     p_system_name in varchar2,
                     p_agent_obj   in out nocopy wf_agent_obj)
is

  CURSOR c_get_agent_n (cp_agent_name varchar2, cp_system_name varchar2) IS
  SELECT a.guid, a.name, a.system_guid, s.name, a.protocol, a.address,
         a.queue_handler, a.queue_name, a.direction, a.status,
         a.display_name, a.type, a.java_queue_handler
  FROM   wf_agents a, wf_systems s
  WHERE  a.name        = cp_agent_name
  AND    a.system_guid = s.guid
  AND    s.name        = cp_system_name;

  CURSOR c_get_agent_g (cp_agent_guid raw) IS
  SELECT a.guid, a.name, a.system_guid, s.name, a.protocol, a.address,
         a.queue_handler, a.queue_name, a.direction, a.status,
         a.display_name, a.type, a.java_queue_handler
  FROM   wf_agents a, wf_systems s
  WHERE  a.guid = cp_agent_guid
  AND    s.guid = a.system_guid;

begin
  if (p_agent_obj is null) then
    wf_agent_obj.Initialize(p_agent_obj);
  end if;

  if (p_agent_name is not null and p_system_name is not null) then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                       'wf.plsql.WF_BES_CACHE.Load_Agent.Cursor',
                       'Loading agent by name '||p_agent_name||'+'||p_system_name);
    end if;
    open c_get_agent_n(p_agent_name, p_system_name);
    fetch c_get_agent_n into p_agent_obj.GUID,
                             p_agent_obj.NAME,
                             p_agent_obj.SYSTEM_GUID,
                             p_agent_obj.SYSTEM_NAME,
                             p_agent_obj.PROTOCOL,
                             p_agent_obj.ADDRESS,
                             p_agent_obj.QUEUE_HANDLER,
                             p_agent_obj.QUEUE_NAME,
                             p_agent_obj.DIRECTION,
                             p_agent_obj.STATUS,
                             p_agent_obj.DISPLAY_NAME,
                             p_agent_obj.TYPE,
                             p_agent_obj.JAVA_QUEUE_HANDLER;

    if (c_get_agent_n%NOTFOUND) then
      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_BES_CACHE.Load_Agent.Not_Found',
                        'Agent not found in the database.');
      end if;
      -- If agent not found in the set wf_agent_obj to null
      p_agent_obj := null;
    end if;
    close c_get_agent_n;
  elsif (p_agent_guid is not null) then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                       'wf.plsql.WF_BES_CACHE.Load_Agent.Not_Found',
                       'Loading agent by GUID '||p_agent_guid);
    end if;
    open c_get_agent_g(p_agent_guid);
    fetch c_get_agent_g into p_agent_obj.GUID,
                             p_agent_obj.NAME,
                             p_agent_obj.SYSTEM_GUID,
                             p_agent_obj.SYSTEM_NAME,
                             p_agent_obj.PROTOCOL,
                             p_agent_obj.ADDRESS,
                             p_agent_obj.QUEUE_HANDLER,
                             p_agent_obj.QUEUE_NAME,
                             p_agent_obj.DIRECTION,
                             p_agent_obj.STATUS,
                             p_agent_obj.DISPLAY_NAME,
                             p_agent_obj.TYPE,
                             p_agent_obj.JAVA_QUEUE_HANDLER;

    if (c_get_agent_g%NOTFOUND) then
      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_BES_CACHE.Load_Agent.Not_Found',
                        'Agent not found in the database');
      end if;
      -- If agent not found in the set wf_agent_obj to null
      p_agent_obj := null;
    end if;
    close c_get_agent_g;
  else
    p_agent_obj := null;
  end if;

end Load_Agent;

-- Load_Agent_QH (PRIVATE)
--   Given the queue handler name, this procedure loads the agent
--   information to the wf_agent_obj instance of the first agent whose
--   queue handler matches with this queue handler
procedure Load_Agent_QH(p_agent_qh  in varchar2,
                        p_direction in varchar2,
                        p_agent_obj in out nocopy wf_agent_obj)
is

  CURSOR c_get_agent (cp_agent_qh varchar2, cp_direction varchar2) IS
  SELECT a.guid, a.name, a.system_guid, s.name, a.protocol, a.address,
         a.queue_handler, a.queue_name, a.direction, a.status,
         a.display_name, a.type, a.java_queue_handler
  FROM   wf_agents  a, wf_systems s
  WHERE  a.system_guid   = wf_event.local_system_guid
  AND    a.system_guid   = s.guid
  AND    a.queue_handler = cp_agent_qh
  AND    a.direction     = cp_direction;

begin
  if (p_agent_obj is null) then
    wf_agent_obj.Initialize(p_agent_obj);
  end if;

  if (p_agent_qh is null) then
    return;
  end if;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement,
                     'wf.plsql.WF_BES_CACHE.Load_Agent_QH.Cursor',
                     'Loading from DB for Queue Handler '||p_agent_qh);
  end if;

  open c_get_agent(p_agent_qh, p_direction);
  fetch c_get_agent into p_agent_obj.GUID,
                         p_agent_obj.NAME,
                         p_agent_obj.SYSTEM_GUID,
                         p_agent_obj.SYSTEM_NAME,
                         p_agent_obj.PROTOCOL,
                         p_agent_obj.ADDRESS,
                         p_agent_obj.QUEUE_HANDLER,
                         p_agent_obj.QUEUE_NAME,
                         p_agent_obj.DIRECTION,
                         p_agent_obj.STATUS,
                         p_agent_obj.DISPLAY_NAME,
                         p_agent_obj.TYPE,
                         p_agent_obj.JAVA_QUEUE_HANDLER;

  if (c_get_agent%NOTFOUND) then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_BES_CACHE.Load_Agent.Not_Found',
                      'No Agent exists for the given queue handler');
    end if;
    -- If agent not found in the set wf_agent_obj to null
    p_agent_obj := null;
  end if;
  close c_get_agent;

end Load_Agent_QH;

-- GetAgentByName
--   This function returns an instance of WF_AGENT_OBJ that contains the
--   information about the specified Agent name + System Name. If null
--   system name is provided, local system is assumed.
function GetAgentByName(p_agent_name  in varchar2,
                        p_system_name in varchar2)
return wf_agent_obj
is
  l_agent_obj   wf_agent_obj;
  l_any_data    anyData;
  l_dummy       pls_integer;
  l_agent_key   varchar2(60);
  l_system_name varchar2(30);
begin
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure,
                    'wf.plsql.WF_BES_CACHE.GetAgentByName.Begin',
                    'Getting agent details for {'||p_agent_name||
                    '+'||p_system_name||'}');
  end if;

  -- Initialize cache variables if not already initialized
  if (not g_initialized) then
    Initialize();
  end if;

  -- if provided system name is null, default to local system name
  if (p_system_name is null) then
    l_system_name := g_local_system_name;
  else
    l_system_name := p_system_name;
  end if;

  if (p_agent_name is null) then
    return null;
  end if;

  l_agent_key := p_agent_name||l_system_name;
  l_agent_obj := null;

  ValidateCache();

  -- Each object type being cached is identified by a number within
  -- the session
  if (not wf_object_cache.IsCacheCreated(g_Agent_Idx)) then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_BES_CACHE.GetAgentByName.Create_Cache',
                      'Cache is not created for AGENTS index {'||g_Agent_Idx||'}');
    end if;
    wf_object_cache.CreateCache(g_Agent_Idx);
    SetMetaDataCached(sysdate);
  else
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_BES_CACHE.GetAgentByName.Cache_Get',
                      'Getting the Agent from Cache');
    end if;
    Get_Agent_Object(l_agent_key, l_agent_obj);
  end if;

  -- If the Agent is not in the object cache, initialize the object and
  -- retrieve the details from the database
  if (l_agent_obj is null) then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_BES_CACHE.GetAgentByName.Load_Agent',
                      'Agent not found in cache. Loading from Database');
    end if;
    -- Load agent from the database to the object

    Load_Agent(null, p_agent_name, l_system_name, l_agent_obj);

    if (l_agent_obj is not null) then
      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_BES_CACHE.GetAgentByName.Set_Cache',
                        'Setting Agent {'||l_agent_key||'} to cache');
      end if;
      Set_Agent_Object(l_agent_key, l_agent_obj);
    end if;
  end if;

  return l_agent_obj;

end GetAgentByName;

-- GetAgentByGUID
--   This function returns an instance of WF_AGENT_OBJ that contains the
--   information about the specified Agent guid
function GetAgentByGUID(p_agent_guid in raw)
return wf_agent_obj
is
  l_all_agents  wf_object_cache.wf_objects_t;
  l_agent_key   varchar2(60);
  l_agent_obj   wf_agent_obj;
  l_dummy       pls_integer;
  l_agent_name  varchar2(30);
  l_system_name varchar2(30);
  l_found       boolean;
  l_loc         number;
begin

  if (p_agent_guid is null) then
    return null;
  end if;

  -- Initialize cache if not already initialized
  if (not g_initialized) then
    Initialize();
  end if;

  l_agent_obj := null;

  ValidateCache();

  -- check if the Agent cache is created. if created get all agent objects
  if (not wf_object_cache.IsCacheCreated(g_Agent_Idx)) then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_BES_CACHE.GetAgentByGUID.Create_Cache',
                      'Cache is not created for AGENTS index {'||g_Agent_Idx||'}');
    end if;
    wf_object_cache.CreateCache(g_Agent_Idx);
    SetMetaDataCached(sysdate);
  else
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_BES_CACHE.GetAgentByGUID.Get_All',
                      'Getting all cached agent objects');
    end if;
    l_all_agents := wf_object_cache.GetAllObjects(g_Agent_Idx);
  end if;

  -- check if at least one agent is cached. then look for the agent with GUID
  if (l_all_agents is not null) then

    l_found := false;

    l_loc := l_all_agents.FIRST;
    while (l_loc is not null) loop
      l_dummy := l_all_agents(l_loc).getObject(l_agent_obj);
      if (l_agent_obj.GUID = p_agent_guid) then
        l_found := true;
        exit;
      end if;
      l_loc := l_all_agents.NEXT(l_loc);
    end loop;

    if (l_found) then
      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_BES_CACHE.GetAgentByGUID.Cache_Hit',
                        'Agent found in cache for GUID '||p_agent_guid);
      end if;
      return l_agent_obj;
    end if;
  end if;

  -- agent not in cache. add the agent to cache from database
  Load_Agent(p_agent_guid, null, null, l_agent_obj);

  -- set it to cache if found in database
  if (l_agent_obj is not null) then
    l_agent_name := l_agent_obj.NAME;
    l_system_name := l_agent_obj.SYSTEM_NAME;
    l_agent_key := l_agent_name||l_system_name;
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                       'wf.plsql.WF_BES_CACHE.GetAgentByGUID.Set_Object',
                       'Agent loaded from Database for GUID '||p_agent_guid||
                       '. Setting to cache for '||l_agent_key);
    end if;
    Set_Agent_Object(l_agent_key, l_agent_obj);
  end if;
  return l_agent_obj;

exception
  when others then
    wf_core.context('WF_BES_CACHE', 'GetAgentByGUID', p_agent_guid);
    raise;
end GetAgentByGUID;

-- GetAgentByQH
--   This function returns an instance of WF_AGENT_OBJ that contains the
--   information about first agent that matches the specified Queue Handler
function GetAgentByQH(p_agent_qh  in varchar2,
                      p_direction in varchar2)
return wf_agent_obj
is
  l_all_agents  wf_object_cache.wf_objects_t;
  l_agent_key   varchar2(60);
  l_agent_obj   wf_agent_obj;
  l_dummy       pls_integer;
  l_agent_name  varchar2(30);
  l_system_name varchar2(30);
  l_found       boolean;
  l_loc         number;
begin

  if (p_agent_qh is null) then
    return null;
  end if;

  -- Initialize cache if not already initialized
  if (not g_initialized) then
    Initialize();
  end if;

  l_agent_obj := null;

  ValidateCache();

  -- check if the Agent cache is created. if created get all agent objects
  if (not wf_object_cache.IsCacheCreated(g_Agent_Idx)) then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_BES_CACHE.GetAgentByQH.Create_Cache',
                      'Cache is not created for AGENTS index {'||g_Agent_Idx||'}');
    end if;
    wf_object_cache.CreateCache(g_Agent_Idx);
    SetMetaDataCached(sysdate);
  else
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_BES_CACHE.GetAgentByQH.Get_All',
                      'Getting all cached agent objects');
    end if;
    l_all_agents := wf_object_cache.GetAllObjects(g_Agent_Idx);
  end if;

  -- check if at least one agent is cached. then look for the agent with GUID
  if (l_all_agents is not null) then

    l_found := false;

    l_loc := l_all_agents.FIRST;
    while (l_loc is not null) loop
      l_dummy := l_all_agents(l_loc).getObject(l_agent_obj);
      if (l_agent_obj.DIRECTION = p_direction and
            l_agent_obj.QUEUE_HANDLER = p_agent_qh) then
        l_found := true;
        exit;
      end if;
      l_loc := l_all_agents.NEXT(l_loc);
    end loop;

    if (l_found) then
      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
        wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_BES_CACHE.GetAgentByQH.Cache_Hit',
                        'Agent found in cache for Queue Handler '||p_agent_qh);
      end if;
      return l_agent_obj;
    end if;
  end if;

  -- agent not in cache. add the agent to cache from database
  Load_Agent_QH(p_agent_qh, p_direction, l_agent_obj);

  -- set it to cache if found in database
  if (l_agent_obj is not null) then
    l_agent_name := l_agent_obj.NAME;
    l_system_name := l_agent_obj.SYSTEM_NAME;
    l_agent_key := l_agent_name||l_system_name;
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                       'wf.plsql.WF_BES_CACHE.GetAgentByQH.Set_Object',
                       'Agent loaded from Database for Queue Hander '||p_agent_qh||
                       '. Setting to cache for '||l_agent_key);
    end if;
    Set_Agent_Object(l_agent_key, l_agent_obj);
  end if;
  return l_agent_obj;

exception
  when others then
    wf_core.context('WF_BES_CACHE', 'GetAgentByQH', p_agent_qh, p_direction);
    raise;
end GetAgentByQH;

--
-- SYSTEMS caching routines
--

-- GetSystemByName
--   This function returns an instance of WF_SYSTEM_OBJ that contains the
--   information about the specified System name.
function GetSystemByName(p_system_name in varchar2)
return wf_system_obj
is
begin
  return null;
end GetSystemByName;

end WF_BES_CACHE;

/

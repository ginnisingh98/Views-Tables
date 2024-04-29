--------------------------------------------------------
--  DDL for Package Body WF_OBJECT_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_OBJECT_CACHE" as
/* $Header: WFOBCACB.pls 120.0.12010000.2 2008/08/09 13:36:23 sstomar ship $ */

/*-------------------+
 | Caching strutures |
 +-------------------*/

g_Object           WF_OBJECTS_T;
g_Object_List      WF_OBJECTS_TAB_T;

/*------------+
 | Procedures |
 +------------*/

-- SetCacheSize
--   Procedure to set the maximum size of the cache.
procedure SetCacheSize(p_size in number)
is
begin
  g_cacheMaxSize := p_size;
end SetCacheSize;

-- GetHashValue (PRIVATE)
--   This function generates hash value for a given name
function getHashValue(p_hash_name in varchar2)
return number
is
begin
  return dbms_utility.get_hash_value(p_hash_name, g_hashBase, g_hashSize);
end getHashValue;

-- CreateCache
--   Procedure to create a new cache to store an object type.
--   For example,
--   in BES if Events, Agents and Systems are the objects to be cached,
--   each of these object types would be referenced with an unique
--   identifier and this API called with that identifier. The identifier
--   would be used to store and retrieve that object type in cache.
procedure CreateCache(p_cache_index in varchar2)
is
begin

  -- if already created, donot create. it will overwrite the cached
  -- objects
  if (g_Object_List.EXISTS(p_cache_index)) then
    return;
  end if;

  -- Initialize the cache list and its related variables
  g_Object_List(p_cache_index).Cache_Objs := g_Object;
  g_Object_List(p_cache_index).Hash_Val(1) := null;
  g_Object_List(p_cache_index).Curr_Idx := 1;
  g_Object_List(p_cache_index).Overflow := false;

exception
  when others then
    wf_core.context('WF_OBJECT_CACHE', 'CreateCache', p_cache_index);
    raise;
end CreateCache;

-- IsCacheCreated
--   Function that checks if cache is already created for a given cache index
--   If cache is already created, it need not be created again.
function IsCacheCreated(p_cache_index in number)
return boolean
is
begin
  -- Check if cache is available for this object in the cache list
  if (g_Object_List.COUNT = 0) then
    return false;
  else
    return g_Object_List.EXISTS(p_cache_index);
  end if;
end IsCacheCreated;

--
-- Check_Size (PRIVATE)
--   Checks the size of the cache object. If the cache has exceeded the
--   max size specified, removes the oldest record in that cache.
--
procedure Check_Size(p_cache_key    in number,
                     p_object_key   in number)
is
  l_oldest   number;
  l_currIdx  number;
begin
  l_currIdx :=  g_Object_List(p_cache_key).Curr_Idx;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement,
                    'wf.plsql.WF_OBJECT_CACHE.Check_Size.Begin',
                    'Checking size of Cache. CurrIdx {'||l_currIdx||'}');
  end if;

  -- Check the current age pointer against max cache size
  if (l_currIdx > g_cacheMaxSize) then
    -- Reset the current index pointing to the hash value
    l_currIdx := mod(l_currIdx, g_cacheMaxSize);
    g_Object_List(p_cache_key).Curr_Idx := l_currIdx;

    g_Object_List(p_cache_key).Overflow := true;
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_OBJECT_CACHE.Check_Size.Begin',
                      'Curr Idx exceeded Max Cache size, reseting CurrIdx. '||
                      ' Max Cache Size {'||g_cacheMaxSize||'}');
    end if;
  end if;

  -- If the cache has reached it's max size, remove the oldest record
  if (g_Object_List(p_cache_key).Overflow) then
    l_oldest := g_Object_List(p_cache_key).Hash_Val(l_currIdx);
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_OBJECT_CACHE.Check_Size.Begin',
                      'Removing oldest record {'||l_oldest||'} from cache');
    end if;
    g_Object_List(p_cache_key).Cache_Objs.DELETE(l_oldest);
  end if;
end Check_Size;

function isDuplicate(p_cache_key    in number,
                     p_object_key   in number)
return boolean
is
begin
  return g_Object_List(p_cache_key).Cache_Objs.EXISTS(p_object_key);
end isDuplicate;

procedure Assign_Object(p_object       in anydata,
                        p_cache_key    in number,
                        p_object_key   in number)
is
  l_object  anyData;
  l_exists  boolean;
  l_currIdx number;

  l_event  wf_event_obj;
  dummy pls_integer;
  l_anyData sys.anyData;
begin
  -- Set object would be called only if the required object was not already
  -- in the cache.
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure,
                    'wf.plsql.WF_OBJECT_CACHE.Assign_Object.Begin',
                    'Assigning object at {'||p_object_key||'} in cache {'||p_cache_key||'}');
  end if;

  g_Object_List(p_cache_key).Cache_Objs(p_object_key) := p_object;

  l_currIdx := g_Object_List(p_cache_key).Curr_Idx;
  g_Object_List(p_cache_key).Hash_Val(l_currIdx) := p_object_key;
  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement,
                    'wf.plsql.WF_OBJECT_CACHE.Assign_Object.Begin',
                    'Current Idx for age table is {'||l_currIdx||'}');
  end if;

  l_currIdx := l_currIdx + 1;
  g_Object_List(p_cache_key).Curr_Idx := l_currIdx;

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure,
                    'wf.plsql.WF_OBJECT_CACHE.Assign_Object.End',
                    'Assigned object to cache. Next Idx {'||l_currIdx||'}');
  end if;
end Assign_Object;

-- SetObject
--   This procedure helps to store an object of type ANYDATA within a cache
--   that was previously created with CreateCache. The object is stored
--   within a PLSQL table under a subscript that is a hash value generated
--   from the object key.
--   For example,
--   If an event object is to be cached whose name is oracle.apps.vj.test,
--   a hash value is generated for event name oracle.apps.vj.test and the object
--   is stored under that location within the PLSQL table.
procedure SetObject(p_cache_index in number,
                    p_object      in anydata,
                    p_object_key  in varchar2)
is
  l_cacheLoc   number;
  l_objHashVal number;

begin

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure,
                    'wf.plsql.WF_OBJECT_CACHE.SetObject.Begin',
                    'Setting object {'||p_object_key||'} in cache {'||p_cache_index||'}');
  end if;

  l_cacheLoc := p_cache_index;
  l_objHashVal := getHashValue(p_object_key);

  if (isDuplicate(l_cacheLoc, l_objHashVal)) then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_OBJECT_CACHE.SetObject.Overwrite',
                      'Object already in cache. Overwriting.');
    end if;
    -- If the object is already in cache, overwrite it. The new one might be an
    -- updated one with more information
    g_Object_List(l_cacheLoc).Cache_Objs(l_objHashVal) := p_object;
  else
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_OBJECT_CACHE.SetObject.Assign',
                      'Checking cache size and storing object in cache');
    end if;
    -- Checks if cache reached max size. If size reached, the oldest
    -- record in that cache is removed to give space for the new one
    Check_Size(l_cacheLoc, l_objHashVal);

    -- Assign the new object to the location as per hash value
    Assign_Object(p_object, l_cacheLoc, l_objHashVal);
  end if;

exception
  when others then
    wf_core.context('WF_OBJECT_CACHE', 'SetObject', p_object_key);
    raise;
end SetObject;

-- GetObject
--   This procedure returns ANYDATA object from a given cache for a given
--   object cache.
function GetObject(p_cache_index in number,
                   p_object_key  in  varchar2)
return anyData
is
  l_cacheLoc   number;
  l_objHashVal number;
  l_idx number;
  l_anyData sys.anyData;
  dummy        pls_integer;
  l_event      wf_event_obj;
begin

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure,
                     'wf.plsql.WF_OBJECT_CACHE.GetObject.Begin',
                     'Getting {'||p_object_key||'} from cache {'||p_cache_index||'}');
  end if;

  l_cacheLoc := p_cache_index;
  l_objHashVal := getHashValue(p_object_key);

  if (g_Object_List.EXISTS(l_cacheLoc) and
      g_Object_List(l_cacheLoc).Cache_Objs.EXISTS(l_objHashVal)) then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_OBJECT_CACHE.GetObject.Cache_Hit',
                      'Object found in cache for {'||p_object_key||'}');
    end if;
    return g_Object_List(l_cacheLoc).Cache_Objs(l_objHashVal);
  else
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_OBJECT_CACHE.GetObject.Cache_Hit',
                      'Object not found in cache for {'||p_object_key||'}');
    end if;
    return null;
  end if;

exception
  when others then
    wf_core.context('WF_OBJECT_CACHE', 'GetObject', p_object_key);
    raise;
end GetObject;

-- GetAllObjects
--   This procedure returns all the ANYDATA objects cached under a given cache
function GetAllObjects(p_cache_index in number)
return wf_objects_t
is
  l_objs wf_objects_t;
begin
  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement,
                    'wf.plsql.WF_OBJECT_CACHE.GetAllObjects.Begin',
                    'Returning all cached objects for {'||p_cache_index||'}');
  end if;
  return g_Object_List(p_cache_index).Cache_Objs;
end GetAllObjects;

-- Clear
--   This procedure deletes all the caches from memory. This is done in case
--   cache is found to be invalid.
procedure Clear(p_cache_index in varchar2)
is
  l_cacheLoc number;
begin

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_procedure,
                    'wf.plsql.WF_OBJECT_CACHE.Clear.Begin',
                    'Clearing object at cache index {'||p_cache_index||'}');
  end if;
  -- If cache index is specified, delete only that specified cache
  if (p_cache_index is not null) then
    g_Object_List.DELETE(p_cache_index);
  else
    -- Since no name is specified, delete the complete cache
    l_cacheLoc := g_Object_List.FIRST;

    while (l_cacheLoc is not null) loop
      g_Object_List.DELETE(l_cacheLoc);
      l_cacheLoc := g_Object_List.NEXT(l_cacheLoc);
    end loop;
  end if;

end Clear;

end WF_OBJECT_CACHE;

/

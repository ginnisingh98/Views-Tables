--------------------------------------------------------
--  DDL for Package WF_OBJECT_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_OBJECT_CACHE" AUTHID CURRENT_USER as
/* $Header: WFOBCACS.pls 120.0.12010000.2 2008/08/09 13:41:28 sstomar ship $ */

/*-------------------+
 | Type declarations |
 |-------------------*/

-- Table of anydata that stores the application object to be cached
Type WF_OBJECTS_T is table of ANYDATA index by binary_integer;

-- Internal table that maintains the age for each of the
Type WF_OBJECTS_HASHVAL_T is table of number index by binary_integer;

-- Record that stores all the information related to cache and its age
Type WF_OBJECT_REC is record
(
  Cache_Objs  WF_OBJECTS_T,
  Hash_Val    WF_OBJECTS_HASHVAL_T,
  Curr_Idx    number,
  Overflow    boolean
);

-- Internal table of wf_objects_t to maintain a list of caches for
-- different objects that requires to be cached
Type WF_OBJECTS_TAB_T is table of WF_OBJECT_REC index by binary_integer;


/*------------------+
 | Global variables |
 +------------------*/

-- Cache maximum size
g_cacheMaxSize  number := 50;

-- Hash range
g_hashBase        number := 1;
g_hashSize        number := 16777216;  -- 2^24


/*------------+
 | Procedures |
 +------------*/

-- SetCacheSize
--   Procedure to set the maximum size of the cache.
procedure SetCacheSize(p_size in number);

-- CreateCache
--   Procedure to create a new cache to store an object type.
--   For example,
--   in BES if Events, Agents and Systems are the objects to be cached,
--   each of these object types would be referenced with an unique
--   identifier and this API called with that identifier. The identifier
--   would be used to store and retrieve that object type in cache.
procedure CreateCache(p_cache_index in varchar2);

-- IsCacheCreated
--   Function that checks if cache is already created for a given cache index
--   If cache is already created, it need not be created again.
function IsCacheCreated(p_cache_index in number)
return boolean;

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
                    p_object_key  in varchar2);

-- GetObject
--   This procedure returns ANYDATA object from a given cache for a given
--   object cache.
function GetObject(p_cache_index in number,
                   p_object_key  in varchar2)
return anyData;

-- GetAllObjects
--   This procedure returns all the ANYDATA objects cached under a given cache
function GetAllObjects(p_cache_index in number)
return wf_objects_t;

-- Clear
--   This procedure deletes all the caches from memory. This is done in case
--   cache is found to be invalid.
procedure Clear(p_cache_index in varchar2 default null);

end WF_OBJECT_CACHE;

/

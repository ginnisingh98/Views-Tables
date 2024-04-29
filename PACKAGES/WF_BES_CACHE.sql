--------------------------------------------------------
--  DDL for Package WF_BES_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_BES_CACHE" AUTHID CURRENT_USER as
/* $Header: WFBECACS.pls 120.0 2005/09/02 15:15:18 vshanmug noship $ */

-- Timestamp at which the session's cache was initialized
g_LastCacheUpdate date := null;

-- Local system information
g_local_system_name   varchar2(30);
g_local_system_guid   raw(16);
g_local_system_status varchar2(30);
g_schema_name         varchar2(80);

-- SetMetaDataUploaded
--   This procedure is called from the BES table handlers when meta-data
--   is being uploaded to the database tables. This procedure sets a BES
--   caching context with the sysdate when the meta-data is loaded.
procedure SetMetaDataUploaded;

-- CacheValid
--   This function validates if the current session's cache is valid or
--   not. This procedure compares the time at which the meta-data was
--   loaded into the database with the time at which the sessions cache
--   was initialized. If the former is greater than the latter, new data
--   has been uploaded to the database and cache is invalid.
-- RETURN
--   Boolean status of whether cache is valid or not
function CacheValid
return boolean;

-- GetEventByName
--   This function returns an instance of WF_Event_Obj object type which
--   contains the complete event information along with valid subscriptions
--   to the event. The information could come from the cache memory or from
--   the database.
-- IN
--   p_event_name - Event name whose information is required
function GetEventByName(p_event_name in varchar2)
return wf_event_obj;

-- GetSubscriptions
--   This function returns a table of WF_EVENT_SUBS_OBJ that are the valid
--   subscriptions to the given event.
function GetSubscriptions(p_event_name   in varchar2,
                          p_source_type  in varchar2,
                          p_source_agent in raw)
return wf_event_subs_tab;

-- GetSubscriptionByGUID
--   This function returns a WF_EVENT_SUBS_OBJ that contains the subscription
--   to the given event and mathing the given subscription GUID.
function GetSubscriptionByGUID(p_event_name in varchar2,
                                p_sub_guid   in raw)
return wf_event_subs_obj;

-- GetAgentByName
--   This function returns an instance of WF_AGENT_OBJ that contains the
--   information about the specified Agent name + System name
function GetAgentByName(p_agent_name  in varchar2,
                        p_system_name in varchar2)
return wf_agent_obj;

-- GetAgentByGUID
--   This function returns an instance of WF_AGENT_OBJ that contains the
--   information about the specified Agent GUID
function GetAgentByGUID(p_agent_guid  in raw)
return wf_agent_obj;

-- GetAgentByQH
--   This function returns an instance of WF_AGENT_OBJ that contains the
--   information about first agent that matches the specified Queue Handler
function GetAgentByQH(p_agent_qh  in varchar2,
                      p_direction in varchar2)
return wf_agent_obj;

-- GetSystemByName
--   This function returns an instance of WF_SYSTEM_OBJ that contains the
--   information about the specified System name.
function GetSystemByName(p_system_name in varchar2)
return wf_system_obj;

-- ClearCache
--   Clears the cached objects from memory and resets requires variables
--   given the name of the cache.
procedure ClearCache;

end WF_BES_CACHE;

 

/

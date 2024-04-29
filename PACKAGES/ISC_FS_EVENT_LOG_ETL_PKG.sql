--------------------------------------------------------
--  DDL for Package ISC_FS_EVENT_LOG_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_FS_EVENT_LOG_ETL_PKG" 
/* $Header: iscfsevntlogetls.pls 120.0 2005/08/28 14:57:03 kreardon noship $ */
AUTHID CURRENT_USER as

function check_events_enabled
return varchar2;

function log_task
( p_subscription_guid          in     raw
, p_event                      in out nocopy wf_event_t
)
return varchar2;

function log_task_assignment
( p_subscription_guid          in     raw
, p_event                      in out nocopy wf_event_t
)
return varchar2;

function log_sr
( p_subscription_guid          in     raw
, p_event                      in out nocopy wf_event_t
)
return varchar2;

function enable_events
( x_error_message out nocopy varchar2
)
return number;

end isc_fs_event_log_etl_pkg;

 

/

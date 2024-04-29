--------------------------------------------------------
--  DDL for Package FND_OAM_DASHBOARD_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DASHBOARD_UTIL" AUTHID CURRENT_USER AS
  /* $Header: AFOAMDUS.pls 115.4 2004/04/21 15:31:14 ppradhan noship $ */

  -- Name
  --   get_trans_name_values
  --
  -- Purpose
  --   Gets the translated list of name values that will be used in the
  --   system alert raised by the dashboard collection program.
  --
  -- Input Arguments
  --   p_message_type - Value should be either 'MET' for message based on
  --     threshold values
  --     or 'STATUS' for metrics based on status values
  --   p_name_val_codes:
  --     If p_message_type is 'MET' then this should be a comma delimited
  --      list of metric_short_name:metric_value
  --      values. For example:
  --	   'ACTIVE_USERS:300,DB_SESSIONS:404'
  --     If p_message_type is 'STATUS' then this should be a comma delimited
  --      list of application_id:concurrent_queue_id:status_code or
  --      metric_short_name:statis_code values
  --
  --      For example:
  --       '0:3042:2,0:10434:2,PHP_GEN:2'
  --
  -- Output Arguments
  --
  -- Returns
  --     If p_message_type is 'MET' then returns the list of
  --     translated metric display name and metric value
  --
  --     If p_message_type is 'STATUS' then returns the list of
  --     translated service instance display name and status values.
  --
  --     For example:
  --      MET: 'Active Users: 300;Database Sessions: 404;'
  --      STATUS: 'Workflow Mailer: Down; Standard Manager: Down; PHP: Down'
  -- Notes:
  --   INTERNAL_USE_ONLY - This function is for use by the dashboard
  --   collection program only.
  --
  FUNCTION get_trans_name_values (
	p_message_type varchar2,
	p_name_val_codes varchar2) RETURN varchar2;

  PRAGMA RESTRICT_REFERENCES(get_trans_name_values, WNDS);


  -- Name
  --   load_svci_info
  --
  -- Purpose
  --   Loads services instances related alerting, collection information
  --   into fnd_oam_svci_info. For the given service instance if a row
  --   already exists it updates the row; otherwise it inserts a new row.
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Returns
  --
  -- Notes:
  --
  PROCEDURE load_svci_info(
	p_application_id number,
	p_concurrent_queue_name varchar2,
	p_alert_enabled_flag varchar2,
	p_collection_enabled_flag varchar2,
	p_threshold_value varchar2,
	p_owner varchar2);

  -- Name
  --   save_web_ping_timeout
  --
  -- Purpose
  --   Saves the value for the new web ping timeout by simply updating
  --   the profile option "OAM_DASHBOARD_WEB_PING_TIMEOUT"
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Returns
  --
  -- Notes:
  --
  FUNCTION save_web_ping_timeout(p_new_val VARCHAR2) return number;

  -- Name
  --   format_time
  --
  -- Purpose
  --   Formats the given number of seconds into 'HH:MM:SS' format.
  --   e.g. 66 is converted to 00:01:06
  --
  -- Input Arguments
  --   p_seconds - Time in seconds
  --
  -- Output Arguments
  --
  -- Returns
  --  Formated String in 'HH:MM:SS' format
  --
  -- Notes:
  --
  FUNCTION format_time(p_seconds number) return varchar2;

  -- Name
  --   get_meaning
  --
  -- Purpose
  --   Gets the meaning for the given lookup_type and comma seperated
  --   look_up codes from the fnd_lookups table
  --
  -- Input Arguments
  --   p_lookup_type - Look up type (String)
  --   p_lookup_codes - Comma separated lookup codes with no space in between
  --      them. for eg: '2,1,3,4' etc.
  --
  -- Output Arguments
  --
  -- Returns
  --  Comma separated meanings corresponding to each code.
  --
  -- Notes:
  --

  FUNCTION get_meaning (p_lookup_type varchar2,
	p_lookup_codes varchar2) RETURN varchar2;

END fnd_oam_dashboard_util;

 

/

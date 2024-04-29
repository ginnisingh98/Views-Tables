--------------------------------------------------------
--  DDL for Package FND_OAM_EM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_EM" AUTHID CURRENT_USER AS
/* $Header: AFOAMEMS.pls 120.1.12000000.2 2007/01/24 06:09:32 appldev ship $ */


  TYPE oam_cursor_type IS REF CURSOR;

  /* DONE FOR LEVEL 1 */
  FUNCTION get_native_svcs return oam_em_srvcs_table_type;

  /* DONE FOR LEVEL 1*/
  FUNCTION get_wf_agent_activity return oam_cursor_type;

  /* DONE FOR LEVEL 1*/
  FUNCTION get_apps_sys_status return oam_cursor_type;

  /* DONE FOR LEVEL 1*/
  FUNCTION get_conf_changed return oam_cursor_type;

  /* DONE FOR LEVEL 1*/
  FUNCTION get_web_components_status return oam_cursor_type;

  /* DONE FOR LEVEL 1*/
  FUNCTION get_ebiz_int_sys_alerts return oam_cursor_type;

  /* DONE FOR LEVEL 1*/
  FUNCTION get_icm_status return number;


/*
  FUNCTION get_ebiz_activity return oam_cursor_type;
  FUNCTION get_rqsts_stats return oam_cursor_type;
  FUNCTION get_procs_rqsts_per_conc return oam_em_prpc_table_type;
  FUNCTION get_pend_rqsts(status_code CHAR, app_id NUMBER, mgr_id NUMBER)
    return NUMBER;
  FUNCTION get_workitem_metrics return oam_cursor_type;
  FUNCTION get_block_icm_crm return oam_cursor_type;
  FUNCTION get_apps_sys_metrics return oam_cursor_type;

  FUNCTION get_apps_framework_agent return oam_cursor_type;
  FUNCTION get_apps_general_info return oam_cursor_type;
  FUNCTION get_apps_level return CHAR;
  FUNCTION get_wf_notification return oam_cursor_type;

  FUNCTION get_ebiz_status return oam_cursor_type;
  FUNCTION get_web_user_last_hour return oam_cursor_type;
  FUNCTION get_active_requests_by_app return oam_cursor_type;
  FUNCTION get_hourly_completed_requests return oam_cursor_type;
*/


END fnd_oam_em;

 

/

  GRANT EXECUTE ON "APPS"."FND_OAM_EM" TO "EM_OAM_MONITOR_ROLE";

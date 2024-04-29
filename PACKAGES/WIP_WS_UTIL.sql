--------------------------------------------------------
--  DDL for Package WIP_WS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WS_UTIL" AUTHID CURRENT_USER as
/* $Header: wipwsuts.pls 120.12.12010000.3 2008/09/16 21:40:04 awongwai ship $ */

  g_timezone_enabled   BOOLEAN := (fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS') = 'Y' AND
                        fnd_profile.value('CLIENT_TIMEZONE_ID') IS NOT NULL AND
                        fnd_profile.value('SERVER_TIMEZONE_ID') IS NOT NULL AND
                        fnd_profile.value('CLIENT_TIMEZONE_ID') <>
                        fnd_profile.value('SERVER_TIMEZONE_ID'));

  g_client_id NUMBER  := fnd_profile.value('CLIENT_TIMEZONE_ID');
  g_server_id NUMBER  := fnd_profile.value('SERVER_TIMEZONE_ID');

  --start constants for bugfix 6755623
  g_pref_id_comp_short NUMBER := 33;
  g_pref_level_id_site NUMBER := 1;
  g_pref_val_mast_org_att       VARCHAR2(30) := 'masterorg';
  g_pref_val_calclevel_att      VARCHAR2(30) := 'calclevel';
 --end constants for bugfix 6755623

  function get_instance_name
  (
    p_instance_name varchar2,
    p_serial_number varchar2
  ) return VARCHAR2;


  function get_preference_value_code(
    p_pref_id number,
    p_resp_key varchar2,
    p_org_id number,
    p_dept_id number
  ) return varchar2;

  function get_preference_level_id(
    p_pref_id number,
    p_resp_key varchar2,
    p_org_id number,
    p_dept_id number
  ) return number;

  function get_preference_value_code(p_pref_id number, p_level_id number) return varchar2;

  function get_jobop_name(p_job_name varchar2, p_op_seq number) return varchar2;

  procedure retrieve_first_shift
  (
    p_org_id number,
    p_dept_id number,
    p_resource_id number,
    p_date date,
    x_shift_seq out nocopy number,
    x_shift_num out nocopy number,
    x_shift_start_date out nocopy date,
    x_shift_end_date out nocopy date,
    x_shift_string out nocopy varchar2
  );

  function get_component_avail(p_org_id number, p_component_id number) return number;

  function get_employee_name(p_employee_id number, p_date date) return varchar2;

  function get_appended_date(p_date date, p_time number)  return date;

  function get_next_date(p_date date)  return date;

  function get_next_work_date_by_calcode(p_calendar_code varchar2, p_date date) return date;

  function get_next_work_date_by_org_id(p_org_id number, p_date date) return date;

  function get_first_workday(p_org_id number, p_dept_id number, p_date date)  return date;

  function get_calendar_code(p_org_id number) return varchar2;

  function get_shift_info_for_display(p_org_id number, p_shift_seq number, p_shift_num number)  return varchar2;

  function get_job_note_header(p_wip_entity_id number, p_op_seq number, p_employee_id number) return varchar2;

  function get_employee_id(p_employee_number varchar2, p_org_id number)  return number;

  procedure clear_msg_stack;

  function get_current_resp_key return varchar2;

  procedure append_job_note(p_wip_entity_id number, p_msg varchar2,
                              p_init_msg_list IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2);

  procedure append_job_note(p_wip_entity_id number, p_clob_msg clob,
                              p_init_msg_list IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2);

  procedure append_exception_note(p_exception_id number, p_msg varchar2,
                              p_init_msg_list IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2);

  function get_projected_completion_date
  (
    p_organization_id number,
    p_wip_entity_id number,
    p_op_seq_num number,
    p_resource_seq_num number,
    p_resource_id number,
    p_instance_id number,
    p_start_date date
  ) return date;

  procedure set_legal_entity_ctx(
    p_org_id number);

  function get_instance_name(p_resource_id IN NUMBER,
                             p_instance_id IN NUMBER,
                             p_serial_number IN VARCHAR2) return VARCHAR2;

  procedure init_timezone;

  function get_page_title(p_oahp varchar2, p_oasf varchar2)  return varchar2;

  function get_multival_pref_seq(p_pref_id IN NUMBER,
                                 p_level_id IN NUMBER,
                                 p_attribute_name IN VARCHAR2,
                                 p_attribute_val IN VARCHAR2) return NUMBER;

  function get_multival_pref_val_code(p_pref_id IN NUMBER,
                                      p_level_id IN NUMBER,
                                      p_seq_num IN NUMBER,
                                      p_attribute_name IN VARCHAR2) return VARCHAR2;

  g_logLevel NUMBER:= fnd_log.g_current_runtime_level;
  procedure log_time(p_msg IN VARCHAR2, p_date IN DATE DEFAULT SYSDATE);

FUNCTION get_lock_handle (
         p_org_id       IN NUMBER,
	 p_lock_prefix  IN Varchar2) RETURN VARCHAR2;

PROCEDURE get_lock(
          x_return_status OUT nocopy varchar2,
          x_msg_count     OUT nocopy number,
          x_msg_data      OUT nocopy varchar2,
          x_lock_status   OUT nocopy number,
          p_org_id        IN  NUMBER,
	  p_lock_prefix   IN  Varchar2);

PROCEDURE release_lock(
          x_return_status OUT NOCOPY VARCHAR2,
          x_msg_count     OUT NOCOPY NUMBER,
          x_msg_data      OUT NOCOPY VARCHAR2,
          p_org_id        IN  NUMBER,
	  p_lock_prefix   IN  varchar2);
PROCEDURE trace_log(p_msg IN VARCHAR2);

--functions for checking shortages in MES workorders tab in supervisor dashboard
FUNCTION check_comp_shortage(p_wip_entity_id IN NUMBER,
			     p_org_id        IN NUMBER) RETURN NUMBER;

FUNCTION check_res_shortage(p_wip_entity_id IN NUMBER,
			    p_org_id        IN NUMBER) RETURN NUMBER;

FUNCTION get_csh_calc_level(p_org_id Number) return NUMBER;


PROCEDURE log_for_duplicate_concurrent(
    p_org_id       in number,
    p_program_name in varchar2);

FUNCTION get_no_of_running_concurrent(
    p_program_application_id in number,
    p_concurrent_program_id  in number,
    p_org_id                 in number) RETURN NUMBER;



end wip_ws_util;


/

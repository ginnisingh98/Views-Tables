--------------------------------------------------------
--  DDL for Package WIP_WS_PTPKPI_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WS_PTPKPI_UTIL" AUTHID CURRENT_USER as
/* $Header: WIPWSPUS.pls 120.4 2008/01/14 20:41:13 ksuleman noship $ */

  type shift_info_t is record (
    shift_id varchar2(1000),
    from_date_char varchar2(1000),
    to_date_char varchar2(1000),
    -- shift_start_time_char varchar2(50),    -- 08:00 - 17:00
    -- shift_end_time_char varchar2(50),
    from_date date,
    to_date date,
    shift_num number,
    seq_num number,
    display varchar(1000)
  );

  function get_calendar_code(
    p_organization_id in number
  ) return varchar2;

  function get_primary_uom_code(
    p_org_id in number,
    p_wip_entity_id in number
  ) return varchar2;

  function get_project_id(
    p_org_id in number,
    p_wip_entity_id in number
  ) return number;

  function get_task_id(
    p_org_id in number,
    p_wip_entity_id in number
  ) return number;

  function get_operation_lead_time(
    p_org_id in number,
    p_wip_entity_id in number,
    p_op_seq_num in number
  ) return number;

  function get_shift_id_for_date(
    p_org_id in number,
    p_dept_id in number,
    p_resource_id in number,
    p_date in date
  ) return varchar2;

  function get_datetime_for_shift(
    p_org_id in number,
    p_shift_id in varchar2,
    p_start_or_end in number
  ) return date;

  function get_chart_str_for_shift(
    p_org_id in number,
    p_shift_id in varchar2
  ) return varchar2;

  function get_chart_str_for_day(
    p_org_id in number,
    p_shift_id in varchar2
  ) return varchar2;

  procedure load_shift_information(
    p_org_id in number,
    p_shift_id in varchar2,
    x_shift_day out nocopy date,
    x_shift_start out nocopy date,
    x_shift_end out nocopy date,
    x_shift_chart_str out nocopy varchar2
  );

  function get_n_previous_working_day(
    p_org_id number,
    n number,
    p_date date
  ) return date;

  --------------------------------------------------
  --------------------------------------------------
  /* start: for ui -- work in progress */
  procedure get_shifts(
    p_organization_id in number,
    p_department_id in number,
    p_resource_id in number,
    p_start_shift_date in date,
    p_end_shift_date in date
  );

  procedure get_org_shifts(
    p_organization_id in number,
    p_start_shift_date in date,
    p_end_shift_date in date
  );

  procedure get_dept_resource_shifts(
    p_organization_id in number,
    p_department_id in number,
    p_resource_id in number,
    p_start_shift_date in date,
    p_end_shift_date in date
  );

  /*
    Find all the candidate shifts that a timestamp of the given day might
    fall into.

    Suppose we don't know the time part of the timestamp. For the timestamp
    on a given day, it might belong to any shift

    Take department into consideration.
  */
  procedure get_candidate_shifts_for_day(
    p_organization_id in number,
    p_department_id in number,
    p_day in date
  );
  /* end: for ui -- work in progress */

  /*
   Used by UI to construct shift name for a given shift number
  */
  function get_shift_name_for_display(
    p_shift_num in number) return varchar2;

  function get_date_as_string(
    p_date in date) return varchar2;

 function get_shift_display_str(
    p_shift_date in date,
    p_shift_num in number,
    p_shift_desc in varchar2) return varchar2;


End WIP_WS_PTPKPI_UTIL;


/

--------------------------------------------------------
--  DDL for Package WIP_WS_DL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WS_DL_UTIL" AUTHID CURRENT_USER as
/* $Header: wipwsdls.pls 120.5.12010000.3 2010/02/19 08:50:48 hliew ship $ */

  LIST_MODE_SCHEDULED constant number := 1;
  LIST_MODE_CURRENT constant number := 2;
  LIST_MODE_UPSTREAM constant number := 3;

  WIP_WS_DEFAULT_DL_TYPE constant number := 8;

  WP_JOB_STATUS constant number := 16;
  WP_DL_ORDERING_CRITERIA constant number := 12;

  WP_READY_STATUS_CRITERIA constant number := 21;
  WP_READY_STATUS_JOB_STATUS constant number := 1;
  WP_READY_STATUS_EXCEPTIONS constant number := 2;
  WP_READY_STATUS_COMP_AVAIL constant number := 3;
  WP_READY_STATUS_SF_STATUS  constant number := 4;
  WP_READY_STATUS_QTY        constant number := 5;

  WP_INCLUDE_COMPLETE_QTY constant number := 15;
  WP_VALUE_YES constant varchar2(1) := '1';
  WP_VALUE_DIRECTION_DOWN constant varchar2(1) := '2';

  l_move_table wip_batch_move.move_table;

  procedure get_first_calendar_date
  (
    l_cal_code varchar2,
    p_date date,
    x_seq out nocopy number,
    x_start_date out nocopy date,
    x_end_date out nocopy date
  );

  function get_first_shift_id
  (
    p_org_id number,
    p_dept_id number,
    p_resource_id number
  ) return varchar2;

  procedure get_first_dept_resource_shift
      (
        p_cal_code varchar2,
        p_dept_id number,
        p_resource_id number,
        p_date date,
        x_shift_seq out nocopy number,
        x_shift_num out nocopy number,
        x_shift_start_date out nocopy date,
        x_shift_end_date out nocopy date
      );

  procedure get_first_shift
  (
    p_cal_code varchar2,
    p_dept_id number,
    p_resource_id number,
    p_date date,
    x_shift_seq out nocopy number,
    x_shift_num out nocopy number,
    x_shift_start_date out nocopy date,
    x_shift_end_date out nocopy date
  );

  function get_col_job_on_name(p_employee_id number) return varchar2;

  function get_col_total_prior_qty(p_wip_entity_id number, p_op_seq number) return number;

  function get_col_customer(p_org_id number, p_wip_entity_id number) return varchar2;

  function get_col_sales_order(p_org_id number, p_wip_entity_id number) return varchar2;

  function get_col_shift_id
  (
    p_org_id number,
    p_dept_id number,
    p_resource_id number,
    p_op_date date,
    p_expedited varchar2,
    p_first_shift_id varchar2,
    p_first_shift_end_date date
  ) return varchar2;

  function get_col_exception(p_wip_entity_id number, p_op_seq number) return varchar;

  function get_col_project(p_wip_entity_id number) return varchar;

  function get_col_task(p_wip_entity_id number) return varchar;

  function get_col_resource_setup(p_wip_entity_id number, p_op_seq number) return varchar;

  function get_col_res_usage_req
  (
    p_wip_entity_id number,
    p_op_seq number,
    p_dept_id number,
    p_resource_id number,
    p_resource_seq_num number
  ) return number;

  function get_col_component_uom(p_org_id number, p_comp_id number) return varchar2;

  function get_col_component_usage
  (
    p_org_id number,
    p_wip_entity_id number,
    p_op_seq number,
    p_comp_id number
  ) return number;


  function get_col_ready_status
  (
    p_resp_key varchar2,
    p_org_id number,
    p_dept_id number,
    p_wip_entity_id number,
    p_op_seq_num number
  ) return varchar2;

  function get_jobop_queue_run_qty(p_wip_entity_id number, p_op_seq_num number) return number;

  function get_jobop_shopfloor_status(p_wip_entity_id number, p_op_seq_num number) return varchar2;

  function get_jobop_num_exceptions(p_wip_entity_id number, p_op_seq_num number) return number;

  function get_job_released_status(p_wip_entity_id number) return varchar2;

  procedure build_dispatch_list_sql
  (
    p_resp_key varchar2,
    p_org_id number,
    p_dept_id number,
    p_resource_id number,
    p_instance_option number,
    p_instance_id number,
    p_serial_number varchar2,
    p_list_mode number,
    p_from_date date,
    p_to_date date,
    p_job_type number,
    p_component_id number,
    p_bind_number number,
    x_where_clause in out nocopy varchar2,
    x_bind_variables in out nocopy varchar2,
    x_order_by_columns in out nocopy varchar2,
    x_order_by_clause in out nocopy varchar2,
    x_required in varchar2 default null			--Bug -7364131
  );

  procedure build_dispatch_list_order_by
  (
    p_resp_key varchar2,
    p_org_id number,
    p_dept_id number,
    x_order_by_columns in out nocopy varchar2,
    x_order_by_clause in out nocopy varchar2
  );

  procedure build_dispatch_list_where
  (
    p_resp_key varchar2,
    p_org_id number,
    p_dept_id number,
    p_resource_id number,
    p_instance_assigned number,
    p_instance_id number,
    p_serial_number varchar2,
    p_list_mode number,
    p_from_date date,
    p_to_date date,
    p_job_type number,
    p_component_id number,
    p_bind_number number,
    x_where_clause in out nocopy varchar2,
    x_bind_variables in out nocopy varchar2,
    x_required in varchar2			--Bug -7364131
  );

  procedure expedite
  (
    p_wip_entity_id number,
    p_op_seq_num number,
    x_status in out nocopy varchar2,
    x_msg_count in out nocopy number,
    x_msg in out nocopy number
  );

  procedure unexpedite
  (
    p_wip_entity_id number,
    p_op_seq_num number,
    x_status in out nocopy varchar2,
    x_msg_count in out nocopy number,
    x_msg in out nocopy number
  );

  procedure batch_move_add(
    p_index number,
    p_wip_entity_id number,
    p_wip_entity_name varchar2,
    p_op_seq varchar2,
    p_move_qty number,
    p_scrap_qty number,
    p_assy_serial varchar2 default null,
    x_return_status out nocopy varchar2
  );

  procedure batch_move_process
  (
    p_resp_key varchar2,
    p_org_id number,
    p_dept_id number,
    p_employee_id number,
    x_return_status out nocopy varchar2
  );

  function get_shift_capacity
  (
    p_org_id number,
    p_dept_id number,
    p_resource_id number,
    p_shift_seq number,
    p_shift_num number
  ) return number;

  function get_cap_num_ns_jobs
  (
    p_resp_key varchar2,
    p_org_id number,
    p_department_id number,
    p_resource_id number,
    p_shift_num number,
    p_from_date date,
    p_to_date date
  ) return number;

  function get_cap_resource_avail
  (
    p_org_id number,
    p_department_id number,
    p_resource_id number,
    p_shift_num number,
    p_from_date date -- Fix bug 9392379
  ) return number;

  function get_cap_resource_required
  (
    p_resp_key varchar2,
    p_org_id number,
    p_department_id number,
    p_resource_id number,
    p_shift_num number,
    p_from_date date,
    p_to_date date

  ) return number;

  function is_jobop_completed
  (
    p_resp_key varchar2,
    p_wip_entity_id number,
    p_op_seq number
  ) return varchar2;

end WIP_WS_DL_UTIL;


/

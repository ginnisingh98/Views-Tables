--------------------------------------------------------
--  DDL for Package MSC_UPDATE_RESOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_UPDATE_RESOURCE" AUTHID CURRENT_USER AS
/* $Header: MSCFNAVS.pls 120.1 2007/10/02 02:04:53 eychen ship $ */
/*
   PROCEDURE apply_simulation(p_org_id IN NUMBER,
                           p_res_group IN VARCHAR2,
                           p_simulation_set IN VARCHAR2,
                           p_cutoff_date IN VARCHAR2);
*/
   PROCEDURE apply_change(p_query_id IN NUMBER,
                          p_plan_id IN NUMBER);
   PROCEDURE initialize_table;
   PROCEDURE calculate_change;
   PROCEDURE update_table;
   PROCEDURE add_new_record(m NUMBER, retain_old boolean default false,
                         retain_id boolean default false);
   FUNCTION get_transaction_id RETURN NUMBER;
   PROCEDURE aggregate_child_records(v_plan_id NUMBER);
   PROCEDURE aggregate_one_resource(v_plan_id NUMBER,
                                  p_org_id NUMBER,
                                  p_instance_id NUMBER,
                                  p_dept_id NUMBER,
                                  p_res_id  NUMBER);

PROCEDURE aggregate_some_resources(v_plan_id NUMBER,
                                  p_org_instance_list varchar2,
                                  p_dept_class_list VARCHAR2,
                                  p_res_group_list VARCHAR2,
                                  p_dept_list varchar2,
                                  p_res_list  varchar2,
                                  p_line_list VARCHAR2);
Function insert_undo_data(undo_type number,
                         j number default null,
                         v_undo_parent_id number default null) return number;

PROCEDURE refresh_parent_record(p_plan_id number,
                                p_instance_id number,
                                p_transaction_id number);

FUNCTION isFirstOP(p_plan_id number,
                                p_supply_id number,
                                p_changed_op number,
                                p_changed_res number) RETURN boolean;

PROCEDURE move_res_req(p_plan_id number,
                                p_supply_id number);

PROCEDURE get_new_time(p_plan_id NUMBER,
                                  p_org_id NUMBER,
                                  p_inst_id NUMBER,
                                  p_dept_id NUMBER,
                                  p_res_id  NUMBER,
                                  p_changed_date date,
                                  p_res_hours number,
                                  p_assign_units number,
                                  p_first_activity boolean,
                                  p_new_start out nocopy date,
                                  p_new_end out nocopy date,
                                  p_error_status out nocopy varchar2);

Procedure ProcessDates(p_plan_id in number,
                            p_supply_id in number,
                            p_effective_date out nocopy date,
                            p_disable_date out nocopy date);

PROCEDURE calculate_ops(p_plan_id NUMBER,
                                p_supply_id number,
                                p_changed_op number,
                                p_changed_res number,
                                p_changed_date date,
                                p_new_end_date date,
                                p_status out nocopy varchar2 );

FUNCTION routing_res_unit(p_plan_id number, p_op_seq_id number,
                      p_rt_seq_id number, p_res_id number,
                      p_assign_units number) RETURN number;

PROCEDURE reset_changes;

PROCEDURE verify_data(p_plan_id number, p_supply_id number);


END Msc_UPDATE_RESOURCE;

/

--------------------------------------------------------
--  DDL for Package MSC_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ACTIONS" AUTHID CURRENT_USER AS
/* $Header: MSCPACTS.pls 115.9 2004/01/28 20:03:14 eychen ship $ */

   FUNCTION save_as(plan NUMBER) RETURN NUMBER;
   PROCEDURE group_by(
        l_plan_node NUMBER,
	var_exception_id NUMBER,
	count_list VARCHAR2, count_list_mfq VARCHAR2,
 	where_clause VARCHAR2,
	p_plan_id NUMBER,
	p_inst_id NUMBER,
	p_org_id NUMBER,
	p_item_id NUMBER,
	p_planning_grp VARCHAR2,
	p_project_id NUMBER,
	p_task_id NUMBER,
	p_category_name VARCHAR2,
	p_pf_id NUMBER,
	p_dept_id NUMBER,
	p_resource_id NUMBER,
	p_supplier_id NUMBER,
	p_version NUMBER,
	p_exc_grp_id NUMBER,
	p_exception_id NUMBER,
	p_dept_class VARCHAR2,
	p_res_group VARCHAR2);
   PROCEDURE insert_exc_groups(
	var_exception_id NUMBER);
   PROCEDURE update_row(p_exception_id number,
                        p_omit_list VARCHAR2,
                        p_row_id VARCHAR2,
                        p_last_update_login NUMBER,
                        p_last_updated_by NUMBER);
   FUNCTION lock_row(p_exception_id number, p_omit_list VARCHAR2)
                                             RETURN NUMBER;

END MSC_ACTIONS;

 

/

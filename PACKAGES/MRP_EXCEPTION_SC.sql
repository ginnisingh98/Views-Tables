--------------------------------------------------------
--  DDL for Package MRP_EXCEPTION_SC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_EXCEPTION_SC" AUTHID CURRENT_USER AS
/* $Header: MRPXSUMS.pls 115.8 2002/02/15 16:44:17 pkm ship      $ */

   FUNCTION save_as(org_id number, plan VARCHAR2) RETURN NUMBER;
   FUNCTION group_by(
	var_exception_id NUMBER,
	planning_org NUMBER, planned_org NUMBER,
	count_list VARCHAR2, count_list_mfq VARCHAR2,
 	compile_designator VARCHAR2, where_clause_segment VARCHAR2,                all_orgs number default null)
	       RETURN NUMBER;
   PROCEDURE update_row(p_exception_id number,
                        p_omit_list VARCHAR2,
                        p_row_id VARCHAR2,
                        p_last_update_login NUMBER,
                        p_last_updated_by NUMBER);
   FUNCTION lock_row(p_exception_id number, p_omit_list VARCHAR2)
                                             RETURN NUMBER;

   FUNCTION item_number(p_org_id number, p_inventory_item_id NUMBER) RETURN VARCHAR2;

  FUNCTION supplier(arg_supplier_id IN NUMBER) return varchar2;

  FUNCTION supplier_site(arg_supplier_site_id IN NUMBER) return varchar2;

END MRP_EXCEPTION_SC;

 

/

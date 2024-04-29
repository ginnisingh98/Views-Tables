--------------------------------------------------------
--  DDL for Package CST_RES_COST_IMPORT_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_RES_COST_IMPORT_INTERFACE" AUTHID CURRENT_USER as
/* $Header: CSTRIMPS.pls 115.3 2002/11/11 22:44:28 awwang ship $ */

PROCEDURE Validate_resource_costs (Error_number OUT NOCOPY NUMBER
                                   ,i_group_id IN NUMBER
                                   ,i_new_csttype IN VARCHAR2
                                   ,i_del_option IN NUMBER
                                   ,i_run_option IN NUMBER
                                   );

Procedure Start_res_cost_import_process(Error_number OUT NOCOPY NUMBER
                                        ,i_Next_value IN VARCHAR2
                                        ,i_grp_id IN NUMBER
                                        ,i_cst_type IN VARCHAR2
                                        ,i_del_option IN NUMBER
                                        ,i_run_option IN NUMBER);
END CST_RES_COST_IMPORT_INTERFACE;

 

/

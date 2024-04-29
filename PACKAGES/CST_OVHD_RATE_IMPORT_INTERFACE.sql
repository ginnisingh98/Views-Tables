--------------------------------------------------------
--  DDL for Package CST_OVHD_RATE_IMPORT_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_OVHD_RATE_IMPORT_INTERFACE" AUTHID CURRENT_USER as
/* $Header: CSTOIMPS.pls 115.3 2002/11/08 23:02:49 awwang ship $ */

Procedure Validate_Department_overheads(Error_number OUT NOCOPY NUMBER
                                        ,i_new_csttype IN VARCHAR2
                                        ,i_group_id IN NUMBER
                                        ,i_del_option IN NUMBER
                                        ,i_run_option IN NUMBER);
Procedure Validate_Resource_overheads(Error_number OUT NOCOPY NUMBER
                                       ,i_new_csttype VARCHAR2
                                       ,i_group_id IN NUMBER
                                       ,i_del_option IN NUMBER
                                       ,i_run_option IN NUMBER);

Procedure Start_process(Error_number OUT NOCOPY NUMBER
                        ,i_cst_type IN VARCHAR2
                        ,i_Next_value IN VARCHAR2
                        ,i_grp_id IN NUMBER
                        ,i_del_option IN NUMBER
                        ,i_run_option IN NUMBER);
END CST_OVHD_RATE_IMPORT_INTERFACE;

 

/

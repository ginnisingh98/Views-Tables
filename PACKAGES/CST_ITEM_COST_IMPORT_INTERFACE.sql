--------------------------------------------------------
--  DDL for Package CST_ITEM_COST_IMPORT_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_ITEM_COST_IMPORT_INTERFACE" AUTHID CURRENT_USER as
/* $Header: CSTCIMPS.pls 115.3 2002/11/08 03:14:35 awwang ship $ */

PROCEDURE validate_phase1(Error_number OUT NOCOPY NUMBER
                          ,i_new_csttype IN VARCHAR2
                          ,i_group_id IN NUMBER
                          );
PROCEDURE validate_phase2 (Error_number OUT NOCOPY NUMBER,i_group_id IN NUMBER);

PROCEDURE insert_csttype_and_def(Error_number OUT NOCOPY NUMBER
                                 ,i_new_csttype IN Varchar2
                                 ,i_group_id IN NUMBER
                                 );

Procedure insert_cic_cicd(Error_number OUT NOCOPY NUMBER,
                          i_group_id IN NUMBER,
                          i_del_option IN NUMBER,
                          i_run_option IN NUMBER);
Procedure Start_item_cost_import_process(Error_number OUT NOCOPY NUMBER,
                                         i_next_value IN VARCHAR2,
                                         i_grp_id IN NUMBER,
                                         i_del_option IN NUMBER,
                                         i_cost_type IN VARCHAR2,
                                         i_run_option IN NUMBER);
END CST_ITEM_COST_IMPORT_INTERFACE;

 

/

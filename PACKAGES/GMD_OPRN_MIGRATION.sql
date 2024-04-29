--------------------------------------------------------
--  DDL for Package GMD_OPRN_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_OPRN_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: GMDOMIGS.pls 115.15 2004/05/04 18:18:00 txdaniel noship $ */

 procedure insert_gmd_operations;
 procedure insert_gmd_operation_comps (P_Oprn_id IN NUMBER);
 procedure insert_operation_activity;
 procedure insert_operation_resource(p_oprn_id NUMBER,p_oprn_line_id NUMBER);

 v_activity_rec fm_oprn_dtl_bak%ROWTYPE;

end gmd_oprn_migration;

 

/

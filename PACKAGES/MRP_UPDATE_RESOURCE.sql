--------------------------------------------------------
--  DDL for Package MRP_UPDATE_RESOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_UPDATE_RESOURCE" AUTHID CURRENT_USER AS
/* $Header: MRPFCAVS.pls 115.1 99/07/16 12:20:43 porting shi $ */

   PROCEDURE apply_simulation(p_org_id IN NUMBER,
                           p_res_group IN VARCHAR2,
                           p_simulation_set IN VARCHAR2,
                           p_cutoff_date IN VARCHAR2);
   PROCEDURE apply_change(p_query_id IN NUMBER,
                        p_compile_designator IN VARCHAR2);
   PROCEDURE initialize_table;
   PROCEDURE calculate_change;
   PROCEDURE update_table;
END MRP_UPDATE_RESOURCE;

 

/

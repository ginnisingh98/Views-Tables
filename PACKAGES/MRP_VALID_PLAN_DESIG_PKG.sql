--------------------------------------------------------
--  DDL for Package MRP_VALID_PLAN_DESIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_VALID_PLAN_DESIG_PKG" AUTHID CURRENT_USER AS
/* $Header: MRPPVPDS.pls 115.0 99/07/16 12:35:39 porting ship $ */

PROCEDURE mrp_valid_plan_designator(
                            arg_compile_desig   IN      VARCHAR2,
                            arg_org_id          IN      NUMBER,
                            arg_exploder        IN      CHAR,
                            arg_snapshot        IN      CHAR,
                            arg_planner         IN      CHAR,
                            arg_crp_planner     IN      CHAR );

END mrp_valid_plan_desig_pkg;

 

/

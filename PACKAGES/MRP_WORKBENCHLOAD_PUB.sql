--------------------------------------------------------
--  DDL for Package MRP_WORKBENCHLOAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_WORKBENCHLOAD_PUB" AUTHID CURRENT_USER AS
/* $Header: MRPPWBLS.pls 115.1 2002/11/26 21:08:15 schaudha ship $ */

PROCEDURE planner_workbench_load(arg_org_id IN NUMBER,
								arg_compile_desig IN VARCHAR2,
								arg_query_id IN NUMBER,
								arg_user_id IN NUMBER,
								arg_wip_load IN VARCHAR2,
							    arg_po_load IN VARCHAR2,
							    arg_wip_resched IN VARCHAR2,
							    arg_po_resched IN VARCHAR2,
								arg_rep_load IN VARCHAR2,
								arg_po_group_by IN NUMBER,
								arg_wip_group_id IN NUMBER,
								arg_launch_process OUT NOCOPY NUMBER);
END MRP_WorkbenchLoad_PUB;

 

/

--------------------------------------------------------
--  DDL for Package WIP_SCHEDULING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_SCHEDULING" AUTHID CURRENT_USER AS
/* $Header: wipsilds.pls 115.7 2002/11/29 18:53:18 simishra ship $ */

/*
   This procedure inserts records into WIP_SCHEDULING_INTERFACE
   for the job identified by the P_WIP_ENTITY_ID parameter.

   It inserts a record for each operation if P_SCHEDULING_LEVEL = 1
   It inserts a record for each resource if P_SCHEDULING_LEVEL = 2

   Each of these records is inserted with a unique INTERFACE_ID
   using the sequence WIP_INTERFACE_S.  Each record will be
   assigned GROUP_ID = P_GROUP_ID.

 */

PROCEDURE LOAD_INTERFACE (
P_WIP_ENTITY_ID		NUMBER,
P_ORGANIZATION_ID	NUMBER,
P_JOB_INTERFACE_GROUP_ID NUMBER,
P_GROUP_ID		NUMBER,
P_SCHEDULING_LEVEL 	NUMBER);

/* This procedure validates and loads information into WIP tables
   based on information in the WIP_SCHEDULING_INTERFACE_TABLE.
 */
PROCEDURE LOAD_WIP(P_GROUP_ID NUMBER);


/*
   This procedure is used as a concurrent program to invoke
   LOAD_WIP.
   It checks if data are available in WIP_SCHEDULING_INTERFACE with
   the specified group_id and if the data have
   process_phase = 2 (validation) and process_status = 1 (pending).
   If no data are available in the table, it returns a warning (retcode = 1).
   If errors occur in LOAD_WIP, it returns an error (retcode = 2)
*/

PROCEDURE LOAD_WIP_CONCURRENT(	errbuf out NOCOPY varchar2,
				retcode out NOCOPY number,
				p_group_id number);




/* This procedure errors out records in the WIP_SCHEDULING_INTERFACE table
   that do not correspond to existing jobs in the system that are status
   	Unreleased
	Released
	Complete
	Hold
 */

PROCEDURE VALIDATE_JOBS(P_GROUP_ID NUMBER);
PROCEDURE VALIDATE_SCHEDULING_LEVEL(P_GROUP_ID NUMBER);
PROCEDURE VALIDATE_DATES(P_GROUP_ID NUMBER);
PROCEDURE VALIDATE_USAGE_RATE(P_GROUP_ID NUMBER);
PROCEDURE VALIDATE_OPS_RES_MATCH(P_GROUP_ID NUMBER);
PROCEDURE ERROR_ALL_IF_ANY(P_GROUP_ID NUMBER);

PROCEDURE UPDATE_REQ_DATES(P_WIP_ENTITY_ID NUMBER,
			   P_ORGANIZATION_ID NUMBER);

PROCEDURE UPDATE_JOB_DATES(P_WIP_ENTITY_ID NUMBER,
			   P_ORGANIZATION_ID NUMBER);

END WIP_SCHEDULING;

 

/

--------------------------------------------------------
--  DDL for Package WIP_MASS_LOAD_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_MASS_LOAD_PROCESSOR" AUTHID CURRENT_USER AS
/* $Header: wipmlprs.pls 115.9 2002/12/03 10:12:23 rmahidha ship $ */


/* This procedure is a wrapper for the RELEASE stored procedure.  It is
   called from the WIP Mass Load Exploder.  It returns 1 if the
   job is released successfully, 0 otherwise.
 */
PROCEDURE ML_Release(P_Wip_Entity_Id IN NUMBER,
		    P_Organization_Id IN NUMBER,
		    P_Class_Code IN VARCHAR2,
		    P_New_Status_Type IN NUMBER,
		    P_Success_Flag OUT NOCOPY NUMBER,
		    P_Error_Msg OUT NOCOPY VARCHAR2,
                    P_Release_Date IN Date DEFAULT NULL); /* 2424987 */

/* This procedure is a wrapper for both the release and unrelease
   procedures.  P_Success_Flag = 0 if the action fails, 1 if it
   succeeds.

   The routine assumes that either P_New or P_Old is 1 (Unreleased)
   but not both.
 */
PROCEDURE ML_Status_Change(P_Wip_Entity_Id IN NUMBER,
		    P_Organization_Id IN NUMBER,
		    P_Class_Code IN VARCHAR2,
		    P_New_Status_Type IN NUMBER,
		    P_Old_Status_Type IN NUMBER,
		    P_Success_Flag OUT NOCOPY NUMBER,
		    P_Error_Msg OUT NOCOPY VARCHAR2,
                    P_Release_Date in Date DEFAULT NULL); /* 2424987 */

/* DELETE_COMPLETED_RECORDS (GROUP_ID)

   This procedure deletes records from the WIP_JOB_SCHEDULE_INTERFACE table
   that were successfully loaded by the Mass Load Process.

   It only acts on records in the interface table that have
        WIP_JOB_SCHEDULE_INTERFACE.GROUP_ID = Group_Id
 */
PROCEDURE Delete_Completed_Records(P_Group_Id IN NUMBER);

/* This procedure sets the Process Status to Error for all records in a
   P_Group_Id whenever a SQL error is found.
 */

PROCEDURE Raise_Sql_Error(P_Group_Id IN NUMBER);

END WIP_MASS_LOAD_PROCESSOR;

 

/

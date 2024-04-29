--------------------------------------------------------
--  DDL for Package WIP_SCHEDULER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_SCHEDULER" AUTHID CURRENT_USER AS
/* $Header: wipschds.pls 115.7 2003/09/05 22:06:58 kbavadek ship $ */

/* EXPLODE_ROUTING

   This package creates operations, operation_resources, and
   operation_instructions for a job.  It does not attempt
   to schedule;  instead it sets all operation and resource
   start and end dates to the date parameters passed to this
   routine.
 */

PROCEDURE explode_routing(
	X_Wip_Entity_Id			NUMBER,
	X_Organization_Id		NUMBER,
	X_Repetitive_Schedule_Id	NUMBER,
	X_Start_Date			VARCHAR2,
	X_Completion_Date		VARCHAR2,
	X_Routing_Seq 			NUMBER,
	X_Routing_Rev_Date		VARCHAR2,
	X_Quantity			NUMBER,
	X_Created_By			NUMBER,
	X_Last_Update_Login		NUMBER);

/* This procedure sets the Start and End dates for existing Operations
   and Operation resources to the date parameters passed.  It will
   also change the date required of any components if necessary.

   If the job is not being released or unreleased, and the quantity has
   changed, it will make sure that
        If no operations on the routing:
                If the new quantity is less than what was in queue
                        of the first op give an error
                Otherwise adjust quantity in queue by the difference
                        between old quantity and new quantity
        If operations:
                If the new quantity is less than quantity already
                        completed then give an error
        If no error, set scheduled quantity to new quantity for all ops
 */
PROCEDURE update_routing(
	X_Wip_Entity_Id                 NUMBER,
        X_load_type                     NUMBER,
        X_Organization_Id               NUMBER,
        X_Repetitive_Schedule_Id        NUMBER,
        X_Start_Date                    VARCHAR2,
        X_Completion_Date               VARCHAR2,
	X_Old_Status_Type 		NUMBER,
	X_Status_Type			NUMBER,
        X_Old_Quantity                  NUMBER,
        X_Quantity                      NUMBER,
        X_Last_Updated_By               NUMBER,
        X_Last_Update_Login             NUMBER,
	X_Success_Flag OUT NOCOPY	NUMBER);

END WIP_SCHEDULER;

 

/

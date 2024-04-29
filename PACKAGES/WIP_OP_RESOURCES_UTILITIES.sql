--------------------------------------------------------
--  DDL for Package WIP_OP_RESOURCES_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_OP_RESOURCES_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: wiporuts.pls 115.8 2003/09/22 23:49:28 ccai ship $ */

--Raises an exception if an operation already exists with the same primary key
  PROCEDURE Check_Unique(X_Wip_Entity_Id		NUMBER,
			X_Organization_Id 		NUMBER,
			X_Operation_Seq_Num		NUMBER,
			X_Resource_Seq_Num		NUMBER,
			X_Repetitive_Schedule_Id	NUMBER);

--Raises an error if trying to insert a second PO Move resource
  PROCEDURE Check_One_Pomove(X_Wip_Entity_Id                NUMBER,
                             X_Organization_Id               NUMBER,
                             X_Operation_Seq_Num             NUMBER,
                             X_Resource_Seq_Num              NUMBER,
                             X_Repetitive_Schedule_Id        NUMBER);

--Raises an error if trying to insert a second Prior resource
  PROCEDURE Check_One_Prior(X_Wip_Entity_Id                 NUMBER,
                            X_Organization_Id               NUMBER,
                            X_Operation_Seq_Num             NUMBER,
                            X_Resource_Seq_Num              NUMBER,
                            X_Repetitive_Schedule_Id        NUMBER);

--Raises an error if trying to insert a second Next resource
  PROCEDURE Check_One_Next(X_Wip_Entity_Id                 NUMBER,
                           X_Organization_Id               NUMBER,
                           X_Operation_Seq_Num             NUMBER,
                           X_Resource_Seq_Num              NUMBER,
                           X_Repetitive_Schedule_Id        NUMBER);

--Sets resource dates based on operation dates
  PROCEDURE Set_Resource_Dates(X_Wip_Entity_Id		NUMBER,
		        X_Organization_Id 		NUMBER,
		        X_Operation_Seq_Num		NUMBER,
			X_Resource_Seq_Num		NUMBER,
		        X_Repetitive_Schedule_Id	NUMBER,
			X_First_Unit_Start_Date		DATE,
			X_Last_Unit_Completion_Date     DATE);

--Returns TRUE if there are pending transactions otherwise FALSE
  FUNCTION Pending_Transactions(
	   X_Wip_Entity_Id                 NUMBER,
	   X_Organization_Id               NUMBER,
	   X_Operation_Seq_Num             NUMBER,
	   X_Resource_Seq_Num              NUMBER,
	   X_Line_Id        NUMBER) RETURN BOOLEAN;

--Gets the class for a given UOM Code
  FUNCTION Get_Uom_Class(X_Unit VARCHAR2) RETURN VARCHAR2;

/*=====================================================================+
 | PROCEDURE
 |   Delete_Orphaned_Alternates
 |
 | PURPOSE
 |   When redefining the resource requirements for a wip entity, it is
 |   possible to delete/change the primary resource of a substitute
 |   group, such that alternate resources exist in
 |   wip_sub_operation_resources without a corresponding primary res in
 |   wor.  Call this procedure after all changes are inserted in the
 |   database to remove the orphaned subs.
 |
 | ARGUMENTS
 |   IN
 |     p_wip_entity_id
 |     p_schedule_id
 |   OUT
 |     x_return_status
 |
 +=====================================================================*/
 Procedure Delete_Orphaned_Alternates (p_wip_entity_id in number,
                                       p_schedule_id in number,
                                       x_return_status OUT NOCOPY varchar2);

/*=====================================================================+
 | PROCEDURE
 |   Validate_Sub_Groups
 |
 | PURPOSE
 |   Substitute groups must be ordered by nvl(schedule_seq_num, resource
 |   seq_num), and simultaneous resources must be in the same sub group.
 |   Call this procedure after all changes are inserted in the
 |   database to check if these rules are violated
 |
 | ARGUMENTS
 |   IN
 |     p_wip_entity_id
 |     p_schedule_id
 |   OUT
 |     x_return_status
 |     x_msg_data:  returns the error msg depending on which rule was
 |          violated
 |     x_operation_seq_num: returns the op seq at which the error
 |          occurred
 |
 +=====================================================================*/
 Procedure Validate_Sub_Groups (p_wip_entity_id NUMBER,
                                p_schedule_id NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_data OUT NOCOPY VARCHAR2,
                                x_operation_seq_num OUT NOCOPY NUMBER);

/*=====================================================================+
 | PROCEDURE
 |   Update_Resource_Instances
 |
 | PURPOSE
 |   If the job/op/resources are rescheduled from the infinite scheduler,
 |   the start/end date of these instances need to be updated to be the
 |   same as the resource start/end date.
 |
 | ARGUMENTS
 |   IN
 |     p_wip_entity_id
 |     p_org_id
 |
 | NOTES
 |   This procedure is being called from wicmex.opp for infinite
 |   scheduling
 |
 +=====================================================================*/
 Procedure Update_Resource_Instances(p_wip_entity_id NUMBER,
                                     p_org_id NUMBER);

END WIP_OP_RESOURCES_UTILITIES;

 

/

--------------------------------------------------------
--  DDL for Package PA_ASSIGNMENT_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ASSIGNMENT_APPROVAL_PVT" AUTHID CURRENT_USER AS
/*$Header: PARAAPVS.pls 120.1 2005/08/19 16:47:15 mwasowic noship $*/


--
--Organize the approvers in the table in sequential order.
--Validate that no duplicate order exists between the approvers.
--The pl/sql table should have at least one record.
--
PROCEDURE Validate_approver_orders
( x_return_status         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895



--
--Determine if the specified assignment is a new assignment.
--A new assignment is one that has not been previously approved.
--
FUNCTION Is_New_Assignment
  (
   p_assignment_id        IN   pa_project_assignments.assignment_id%TYPE
  )
  RETURN VARCHAR2;



--
--Get the change_id from the pa_assignments_history table.
--
FUNCTION Get_Change_Id
  (
   p_assignment_id        IN   pa_project_assignments.assignment_id%TYPE
  )
  RETURN NUMBER;

--
-- Get lookup_meaning from pa_lookups
--
FUNCTION get_lookup_meaning ( p_lookup_type  IN  VARCHAR2
                             ,p_lookup_code  IN  VARCHAR2)
RETURN VARCHAR2;


--
--Determine if the specified assignment requires approval.
--
PROCEDURE Check_Approval_Required
  (
    p_assignment_id            IN   pa_project_assignments.assignment_id%TYPE
   ,p_new_assignment_flag   IN   VARCHAR2					:= FND_API.G_MISS_CHAR
--   ,p_resource_authority_flag  IN   VARCHAR2					:= FND_API.G_MISS_CHAR
   ,x_approval_required_flag       OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status            OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );



--
--Update the Assignment Approval Status depending on the action performed, and calls schedule API to
--update schedule statuses if needed.  Any time the Assignment Approval Status need to be updated, this API will
--be called.  This including when workflow is successful or failure.
--
--The allowed actions are: 'APPROVE', 'REJECT', 'SUBMIT', 'UPDATE', and 'REVERT'.
--
PROCEDURE Update_Approval_Status
  (
    p_assignment_id             IN   pa_project_assignments.assignment_id%TYPE
   ,p_action_code               IN   VARCHAR2					:= FND_API.G_MISS_CHAR
   ,p_record_version_number     IN   pa_project_assignments.record_version_number%TYPE
   ,p_note_to_approver          IN   VARCHAR2                                   := FND_API.G_MISS_CHAR
   ,x_apprvl_status_code        OUT  NOCOPY pa_project_statuses.project_status_code%TYPE --File.Sql.39 bug 4440895
   ,x_change_id                 OUT  NOCOPY pa_assignments_history.change_id%TYPE     --File.Sql.39 bug 4440895
   ,x_record_version_number     OUT  NOCOPY pa_project_assignments.record_version_number%TYPE    --File.Sql.39 bug 4440895
   ,x_return_status             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                 OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


--
--Get the new assignment approval status after the specified action is performed
--
--The allowed actions are: 'APPROVE', 'REJECT', 'SUBMIT', 'UPDATE', and 'REVERT'.
--
PROCEDURE Get_Next_Status_After_Action
  (
    p_action_code               IN   VARCHAR2					 := FND_API.G_MISS_CHAR
   ,p_status_code               IN   pa_project_statuses.project_status_code%TYPE:= FND_API.G_MISS_CHAR
   ,x_status_code               OUT  NOCOPY pa_project_statuses.project_status_code%TYPE --File.Sql.39 bug 4440895
   ,x_return_status             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );



--
--This procedure inserts current record in the PA_PROJECT_ASSIGNMENTS into the PA_ASSIGNMENTS_HISTORY table when the
-- record's Assignment Approval Status changes from 'APPROVED' to 'WORKING'.
--
PROCEDURE Insert_Into_Assignment_History
  (
    p_assignment_id             IN  pa_project_assignments.assignment_id%TYPE
   ,x_change_id                 OUT  NOCOPY pa_assignments_history.change_id%TYPE --File.Sql.39 bug 4440895
   ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

--
--This procedure abort the workflow approval outstanding for the specific assignment
--and update the pending_approval_flag to 'N'
--
PROCEDURE Abort_Assignment_Approval
  (
    p_assignment_id             IN  pa_project_assignments.assignment_id%TYPE
   ,p_project_id                IN  pa_project_assignments.project_id%TYPE
   ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


--
-- Return following record based on p_assignment_is
--   x_saved_asmt_rec : assignment record having values in pa_project_assignments
--   x_asmt_history_rec : assignment record having values in pa_assignments_history
--
PROCEDURE get_asmt_and_asmt_history_rec (p_assignment_id     IN  NUMBER
                                        ,x_saved_asmt_rec    OUT NOCOPY PA_ASSIGNMENTS_PUB.assignment_rec_type  --File.Sql.39 bug 4440895
                                        ,x_asmt_history_rec  OUT NOCOPY pa_assignments_pub.assignment_rec_type --File.Sql.39 bug 4440895
                                        ,x_return_status     OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


END PA_ASSIGNMENT_APPROVAL_PVT ;
 

/

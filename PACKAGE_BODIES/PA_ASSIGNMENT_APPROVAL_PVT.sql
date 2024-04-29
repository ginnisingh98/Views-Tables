--------------------------------------------------------
--  DDL for Package Body PA_ASSIGNMENT_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ASSIGNMENT_APPROVAL_PVT" AS
/*$Header: PARAAPVB.pls 120.1.12000000.2 2007/11/23 12:39:09 kjai ship $*/

--
--Organize the approvers in the table in sequential order.
--Validate that no duplicate order exists between the approvers.
--The pl/sql table should have at least one record.
--
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */

PROCEDURE Validate_approver_orders (
 x_return_status         OUT    NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

  l_approver_rec   PA_ASSIGNMENT_APPROVAL_PUB.Asgmt_Approvers_Rec_Type;
  l_return_status  VARCHAR2(1);
  l_sorted         BOOLEAN;
  l_first          BINARY_INTEGER;
  l_before_last    BINARY_INTEGER;
BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.set_err_stack('PA_ASSIGNMENT_APPROVAL_PVT.Validate_approver_orders');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PVT.Validate_approver_orders.begin'
                     ,x_msg         => 'Beginning of Validate_approver_orders'
                     ,x_log_level   => 5);
  END IF;
  -- Initialize
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  --If table empty, then return error that at least one approver is needed.
  --Else use bubble sort to put approvers according to their order, then check if any duplicate order exists.
  --
  IF PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl.FIRST IS NULL AND PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl.LAST IS NULL THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       =>  'PA_NO_NON_EXCLUDED_APR');
    l_return_status := FND_API.G_RET_STS_ERROR;
  ELSE

    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PVT.Validate_approver_orders.bubble_sort'
                     ,x_msg         => 'Starting bubble sort.'
                     ,x_log_level   => 5);
    END IF;

    --
    --Starting Bubble Sort.
    --
    l_sorted := FALSE;
    IF (PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl.FIRST <>PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl.LAST) THEN
      l_first  := PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl.FIRST;
      l_before_last := PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl.PRIOR(PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl.LAST);
      WHILE l_sorted = FALSE LOOP

        l_sorted := TRUE;
        FOR i IN l_first .. l_before_last LOOP

          IF (PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl(i).orders >
            PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl(PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl.NEXT(i)).orders) THEN
            l_approver_rec := PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl(i);
            PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl(i) :=
                              PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl(PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl.NEXT(i));
            PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl(PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl.NEXT(i)) := l_approver_rec;
            l_sorted := FALSE;
          END IF;
        END LOOP;
      END LOOP;

      --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PVT.Validate_approver_orders.check_duplicate'
                     ,x_msg         => 'Checking duplicate orders.'
                     ,x_log_level   => 5);
    END IF;
      --Check if any duplicate orders exist.
      FOR i IN l_first .. l_before_last LOOP

        IF (PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl(i).orders =
          PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl(PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl.NEXT(i)).orders) THEN
    	  PA_UTILS.Add_Message( p_app_short_name => 'PA'
                             ,p_msg_name       =>  'PA_DUPLICATE_APR_ORDERS');
          l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END LOOP; -- end of check duplicate order
    END IF;-- end of check only one item in the table
  END IF; --End of check table.


  PA_DEBUG.Reset_err_stack;  /* 3148857 */
  --Assign out parameters
  x_return_status := l_return_status;


  EXCEPTION
     WHEN OTHERS THEN
         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PVT.Validate_approver_orders'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         RAISE;  -- This is optional depending on the needs
END Validate_approver_orders;




--
--Determine if the specified assignment is a new assignment.
--A new assignment is one that has not been previously approved.
--
FUNCTION Is_New_Assignment
(
 p_assignment_id        IN   pa_project_assignments.assignment_id%TYPE
)
RETURN VARCHAR2
IS

 l_new_assignment_flag   VARCHAR2(1);
 l_flag                  VARCHAR2(1);

/* Commenting this cursor for bug 4183614

CURSOR get_assignment_id IS
 SELECT 'X'
 FROM pa_assignments_history pah,
      pa_project_assignments ppa
 WHERE pah.assignment_id = p_assignment_id
 OR    ( ppa.assignment_id = p_assignment_id
       AND ppa.apprvl_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_approved);

End of comment for bug 4183614 */

/* Added this tuned query for cursor get_Assignment_id for bug 4183614 */

CURSOR get_assignment_id IS
SELECT 'X'
FROM pa_assignments_history pah
WHERE pah.assignment_id = p_assignment_id
UNION ALL
SELECT 'X'
FROM pa_project_assignments ppa
WHERE ppa.assignment_id = p_assignment_id
      AND ppa.apprvl_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_approved;

BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.set_err_stack('PA_ASSIGNMENT_APPROVAL_PVT.Is_New_Assignment');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PVT.Is_New_Assignment.begin'
                     ,x_msg         => 'Beginning of Is_New_Assignment'
                     ,x_log_level   => 5);
  END IF;

  l_new_assignment_flag := 'N';

  OPEN get_assignment_id;

  FETCH get_assignment_id INTO l_flag;

  IF get_assignment_id%NOTFOUND THEN
    l_new_assignment_flag := 'Y';
  END IF;

  CLOSE get_assignment_id;

  PA_DEBUG.Reset_err_stack;  /* 3148857 */

  RETURN l_new_assignment_flag;

  EXCEPTION
     WHEN OTHERS THEN
         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PVT.Is_New_Assignment'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         RAISE;  -- This is optional depending on the needs

END Is_New_Assignment;




--
--Get the change_id from the pa_assignments_history table.
--
FUNCTION Get_Change_Id
(
 p_assignment_id        IN   pa_project_assignments.assignment_id%TYPE
)
RETURN NUMBER
IS

 l_change_id       pa_assignments_history.change_id%TYPE;

 CURSOR get_change_id IS
  SELECT change_id
  FROM pa_assignments_history
  WHERE assignment_id = p_assignment_id
  AND last_approved_flag = 'Y';

BEGIN


  -- Initialize the Error Stack
  PA_DEBUG.set_err_stack('PA_ASSIGNMENT_APPROVAL_PVT.Get_Change_Id');

  --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PVT.Get_Change_Id.begin'
                     ,x_msg         => 'Beginning of Get_Change_Id'
                     ,x_log_level   => 5);
    END IF;
  OPEN get_change_id;

  FETCH get_change_id INTO l_change_id;

  IF get_change_id%NOTFOUND THEN
    l_change_id := -1;
  END IF;

  CLOSE get_change_id;
  PA_DEBUG.Reset_Err_Stack; /* 3148857 */
  RETURN l_change_id;

  EXCEPTION
     WHEN OTHERS THEN
         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PVT.Get_Change_Id'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         RAISE;  -- This is optional depending on the needs


END Get_Change_Id;



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
) IS

l_approval_required_flag     VARCHAR2(1);

BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.set_err_stack('PA_ASSIGNMENT_APPROVAL_PVT.Check_Approval_Required');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PVT.Check_Approval_Required.begin'
                     ,x_msg         => 'Beginning of Check_Approval_Required'
                     ,x_log_level   => 5);
  END IF;


  -- Initialize
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_approval_required_flag := 'N';

  -- If the specified assignment has not been previously approved and the submitter has no resource authority
  -- Then approval required.
  -- Otherwise, check if approval required assignment items and schedule has any changes.
  -- If change occured, then approval required.
  --
  IF p_new_assignment_flag = 'Y' THEN

    l_approval_required_flag := 'Y';

  ELSE
    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PVT.Check_Approval_Required.items_changed'
                     ,x_msg         => 'Checking if Assignment Approval Items are changed.'
                     ,x_log_level   => 5);
    END IF;

    l_approval_required_flag := PA_CLIENT_EXTN_ASGMT_APPRVL.Is_Asgmt_Appr_Items_Changed(p_assignment_id);
    IF l_approval_required_flag NOT IN ('Y', 'N') THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  END IF;  -- end of checking new assignment flag

  pa_debug.reset_err_stack;  /* 3148857 */

  x_approval_required_flag := l_approval_required_flag;

  EXCEPTION
     WHEN OTHERS THEN
         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PVT.Check_Approval_Required'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         --
         RAISE;  -- This is optional depending on the needs

END Check_Approval_Required;





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
 ,p_note_to_approver          IN   VARCHAR2					:= FND_API.G_MISS_CHAR
 ,x_apprvl_status_code        OUT  NOCOPY pa_project_statuses.project_status_code%TYPE --File.Sql.39 bug 4440895
 ,x_change_id                 OUT  NOCOPY pa_assignments_history.change_id%TYPE  --File.Sql.39 bug 4440895
 ,x_record_version_number     OUT  NOCOPY pa_project_assignments.record_version_number%TYPE    --File.Sql.39 bug 4440895
 ,x_return_status             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                 OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

) IS

 l_record_version_number      NUMBER;
 l_apprvl_status_code         pa_project_statuses.project_status_code%TYPE;
 l_return_status              VARCHAR2(1);
 l_msg_data                   VARCHAR2(2000);
 l_msg_count                  NUMBER;
 l_error_count                NUMBER;
 l_msg_index_out              NUMBER;

CURSOR get_status_and_rec_num IS
 SELECT apprvl_status_code, record_version_number
 FROM pa_project_assignments
 WHERE assignment_id = p_assignment_id;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.set_err_stack('PA_ASSIGNMENT_APPROVAL_PVT.Update_Approval_Status');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PVT.Update_Approval_Status.begin'
                     ,x_msg         => 'Beginning of Update_Approval_Status.'
                     ,x_log_level   => 5);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_change_id := NULL;
  x_record_version_number := NULL;

  --Initialize local variables
  l_record_version_number := p_record_version_number;
  l_error_count := FND_MSG_PUB.Count_Msg;

  -- Get the current status code and record version number
  OPEN get_status_and_rec_num;
  FETCH get_status_and_rec_num INTO l_apprvl_status_code, l_record_version_number;
  CLOSE get_status_and_rec_num;



  -- IF current status is 'Approved' and action to be performed is 'Update', then insert the current record
  -- into history table.
  IF l_apprvl_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_approved
     AND p_action_code =PA_ASSIGNMENT_APPROVAL_PUB.g_update_action THEN

     --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PVT.Update_Approval_Status.insert_history'
                     ,x_msg         => 'Inserting record into assignment history table.'
                     ,x_log_level   => 5);
    END IF;

     PA_ASSIGNMENT_APPROVAL_PVT.Insert_Into_Assignment_History ( p_assignment_id => p_assignment_id
                                                                ,x_change_id => x_change_id
                                                                ,x_return_status => l_return_status);
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
     END IF;
     l_return_status := FND_API.G_MISS_CHAR;

/* Changed bug 1635170*/
  ELSE
     x_change_id:=PA_ASSIGNMENT_APPROVAL_PVT.get_change_id(p_assignment_id);
  END IF;
/* End bug 1635170*/

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PVT.Update_Approval_Status.get_next_stus'
                     ,x_msg         => 'Get next assignment approval status.'
                     ,x_log_level   => 5);
  END IF;

  -- Get the status code after action performed.
  PA_ASSIGNMENT_APPROVAL_PVT.Get_Next_Status_After_Action ( p_action_code => p_action_code
                                                    ,p_status_code => l_apprvl_status_code
                                                    ,x_status_code => x_apprvl_status_code
                                                    ,x_return_status => l_return_status);
--dbms_output.put_line('next status:'|| x_apprvl_status_code);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    x_return_status := l_return_status;
  END IF;
  l_return_status := FND_API.G_MISS_CHAR;

/* --moved after schedule success or failure

  --If no error, update the current assignment record with the new status and increment record_version_number
  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
--dbms_output.put_line('calling update row');

    PA_PROJECT_ASSIGNMENTS_PKG.Update_Row ( p_assignment_id => p_assignment_id
                                           ,p_record_version_number => p_record_version_number
                                           ,p_apprvl_status_code => x_apprvl_status_code
                                           ,p_note_to_approver   => p_note_to_approver
                                           ,x_return_status => l_return_status );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
    ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
       x_record_version_number := p_record_version_number +1;
    END IF;
    l_return_status := FND_API.G_MISS_CHAR;
  END IF;

*/


  --In the case of Approve or Reject, also call schedule's success/failure method to update schedule statuses.
  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

    IF p_action_code = PA_ASSIGNMENT_APPROVAL_PUB.g_approve_action THEN
      --call schedule's success method
      --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PVT.Update_Approval_Status.schedule_success'
                     ,x_msg         => 'Calling schedule success method.'
                     ,x_log_level   => 5);
    END IF;

      PA_SCHEDULE_PVT.UPDATE_SCH_WF_SUCCESS ( p_assignment_id          => p_assignment_id
                                              ,p_record_version_number => l_record_version_number
					      ,x_return_status         => l_return_status
					      ,x_msg_count             => l_msg_count
					      ,x_msg_data              => l_msg_data);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
      END IF;
      l_record_version_number := NULL;
    ELSIF p_action_code = PA_ASSIGNMENT_APPROVAL_PUB.g_reject_action THEN
       --call schedule's failure method
      --Log Message
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PVT.Update_Approval_Status.schedule_failure'
                     ,x_msg         => 'Calling schedule failure method.'
                     ,x_log_level   => 5);
      END IF;

       PA_SCHEDULE_PVT.UPDATE_SCH_WF_FAILURE ( p_assignment_id           => p_assignment_id
					        ,p_record_version_number => l_record_version_number
						,x_return_status         => l_return_status
						,x_msg_count             => l_msg_count
						,x_msg_data              => l_msg_data);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
      END IF;
      l_record_version_number := NULL;
    END IF; -- end of calling success/failure
    l_return_status := FND_API.G_MISS_CHAR;
    l_msg_count := FND_API.G_MISS_NUM;
    l_msg_data := FND_API.G_MISS_CHAR;
  END IF;



  --If no error, update the current assignment record with the new status and increment record_version_number
  --The record_version_number passed in will be NULL if Schedule Sucess/failure API has already updated the record
  --otherwise, use the p_record_version_number

  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PVT.Update_Approval_Status.update_status'
                     ,x_msg         => 'update current approval status.'
                     ,x_log_level   => 5);
    END IF;

    --Update record in assignment table Only if
    --p_note_to_approver exists OR
    --apprvl_status_code has been changed.
    IF (p_note_to_approver <> FND_API.G_MISS_CHAR AND p_note_to_approver IS NOT NULL) OR
       ((x_apprvl_status_code IS NOT NULL AND l_apprvl_status_code IS NULL) OR
       (x_apprvl_status_code <> l_apprvl_status_code)) THEN
      PA_PROJECT_ASSIGNMENTS_PKG.Update_Row ( p_assignment_id => p_assignment_id
                                           ,p_record_version_number => l_record_version_number
                                           ,p_apprvl_status_code => x_apprvl_status_code
                                           ,p_note_to_approver   => p_note_to_approver
                                           ,x_return_status => l_return_status );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
      ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        IF l_record_version_number IS NOT NULL THEN
          x_record_version_number := l_record_version_number +1;
        END IF;
      END IF;
      l_return_status := FND_API.G_MISS_CHAR;
    END IF;
  END IF;


  x_msg_count :=  FND_MSG_PUB.Count_Msg - l_error_count;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  IF x_msg_count > 0 THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Reset the error stack when returning to the calling program

  PA_DEBUG.Reset_Err_Stack;

  EXCEPTION
     WHEN OTHERS THEN
         -- Set the exception Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PVT.Update_Approval_Status'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         RAISE;  -- This is optional depending on the needs


END Update_Approval_Status;



--
--Get the new assignment approval status after the specified action is performed
--
--The allowed actions are: 'APPROVE', 'REJECT', 'SUBMIT', 'UPDATE', and 'REVERT'.
--After bug 6625421, 'SAVE_AND_SUBMIT' action also allowed.
--
PROCEDURE Get_Next_Status_After_Action
(
  p_action_code               IN   VARCHAR2					 := FND_API.G_MISS_CHAR
 ,p_status_code               IN   pa_project_statuses.project_status_code%TYPE  := FND_API.G_MISS_CHAR
 ,x_status_code               OUT  NOCOPY pa_project_statuses.project_status_code%TYPE --File.Sql.39 bug 4440895
 ,x_return_status             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

 l_return_status         VARCHAR2(1);
 l_error_message_code    VARCHAR2(100);
 l_success_status_code   pa_project_statuses.project_status_code%TYPE;
 l_failure_status_code   pa_project_statuses.project_status_code%TYPE;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.set_err_stack('PA_ASSIGNMENT_APPROVAL_PVT.Get_Next_Status_After_Action');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.write_log (x_module      => 'Get_Next_Status_After_Action.begin'
                     ,x_msg         => 'Beginning of Get_Next_Status_After_Action.'
                     ,x_log_level   => 5);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  --Check only valid action is passed in.
  IF p_action_code NOT IN (PA_ASSIGNMENT_APPROVAL_PUB.g_approve_action, PA_ASSIGNMENT_APPROVAL_PUB.g_reject_action,
                           PA_ASSIGNMENT_APPROVAL_PUB.g_submit_action, PA_ASSIGNMENT_APPROVAL_PUB.g_update_action,
			   PA_ASSIGNMENT_APPROVAL_PUB.g_revert_action, PA_ASSIGNMENT_APPROVAL_PUB.g_cancel_action,
                           PA_MASS_ASGMT_TRX.g_save_and_submit) THEN /*SAVE_AND_SUBMIT added for bug 6625421*/
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       =>  'PA_UNEXP_APPRVL_ACTION');
--dbms_output.put_line('unexpected action code');
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;



  --Check only valid assignment approval status is passed in
  IF p_status_code IS NOT NULL AND p_status_code NOT IN (PA_ASSIGNMENT_APPROVAL_PUB.g_approved,
                                                         PA_ASSIGNMENT_APPROVAL_PUB.g_rejected,
                                                         PA_ASSIGNMENT_APPROVAL_PUB.g_submitted,
                                                         PA_ASSIGNMENT_APPROVAL_PUB.g_working,
                                                         PA_ASSIGNMENT_APPROVAL_PUB.g_req_resub) THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       =>  'PA_INVALID_APPRVL_STUS');
--dbms_output.put_line('unexpected apprvl status');
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF (p_action_code = PA_ASSIGNMENT_APPROVAL_PUB.g_submit_action
      OR
      p_action_code = PA_MASS_ASGMT_TRX.g_save_and_submit)    THEN /*SAVE_AND_SUBMIT added for bug 6625421*/

    x_status_code := PA_ASSIGNMENT_APPROVAL_PUB.g_submitted;

  ELSIF p_action_code = PA_ASSIGNMENT_APPROVAL_PUB.g_revert_action THEN

    x_status_code :=  PA_ASSIGNMENT_APPROVAL_PUB.g_approved;

  ELSIF p_action_code = PA_ASSIGNMENT_APPROVAL_PUB.g_cancel_action THEN

    x_status_code := PA_ASSIGNMENT_APPROVAL_PUB.g_canceled;

  ELSIF p_action_code = PA_ASSIGNMENT_APPROVAL_PUB.g_update_action THEN

    IF p_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_working THEN

         x_status_code := PA_ASSIGNMENT_APPROVAL_PUB.g_working;

    ELSIF p_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_submitted THEN
/*
	PA_UTILS.Add_Message( p_app_short_name => 'PA'
                             ,p_msg_name       =>  'PA_WF_APPROVAL_PENDING');
        x_return_status := FND_API.G_RET_STS_ERROR;
*/
        x_status_code := PA_ASSIGNMENT_APPROVAL_PUB.g_submitted;

    ELSIF p_status_code IS NULL THEN
        x_status_code := NULL;
    ELSE
        x_status_code :=  PA_ASSIGNMENT_APPROVAL_PUB.g_req_resub;
    END IF;

  ELSE

    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'Get_Next_Status_After_Action.get_wf_status_code'
                     ,x_msg         => 'Get success and failure status code'
                     ,x_log_level   => 5);
    END IF;
    --
    --call get_workflow_info to get success and failure status code
    --
    PA_PROJECT_STUS_UTILS.get_wf_success_failure_status
                                (p_status_code             => PA_ASSIGNMENT_APPROVAL_PUB.g_submitted
                                ,p_status_type             => 'ASGMT_APPRVL'
                                ,x_wf_success_status_code  => l_success_status_code
                                ,x_wf_failure_status_code  => l_failure_status_code
                                ,x_return_status           => l_return_status
                                ,x_error_message_code      => l_error_message_code) ;



    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      x_return_status := l_return_status;
      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => l_error_message_code);
    ELSE

      IF p_action_code = PA_ASSIGNMENT_APPROVAL_PUB.g_approve_action THEN
        x_status_code :=  l_success_status_code;
      ELSIF p_action_code = PA_ASSIGNMENT_APPROVAL_PUB.g_reject_action THEN
        x_status_code :=  l_failure_status_code;
      END IF;
    END IF;
  END IF; --end of checking p_action_code
pa_debug.reset_err_stack;  /* 3148857 */
  EXCEPTION
     WHEN OTHERS THEN
         -- Set the exception Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PVT.Get_Next_Status_After_Action'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         RAISE;  -- This is optional depending on the needs
END Get_Next_Status_After_Action;


--
--This procedure inserts current record in the PA_PROJECT_ASSIGNMENTS into the PA_ASSIGNMENTS_HISTORY table when the
-- record's Assignment Approval Status changes from 'APPROVED' to 'WORKING'.
--
PROCEDURE Insert_Into_Assignment_History
(
  p_assignment_id             IN  pa_project_assignments.assignment_id%TYPE
 ,x_change_id                 OUT  NOCOPY pa_assignments_history.change_id%TYPE --File.Sql.39 bug 4440895
 ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

  l_assignment_rec       PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
  l_assignment_row_id    ROWID;
  l_change_id            NUMBER;
  l_pending_approval_flag pa_assignments_history.pending_approval_flag%TYPE;
  l_return_status        VARCHAR2(1);
  l_msg_data             VARCHAR2(2000);
  l_msg_count            NUMBER;
  l_project_subteam_id   NUMBER;

CURSOR get_project_subteam_id IS
 SELECT project_subteam_id
 FROM pa_project_subteam_parties
 WHERE object_type = 'PA_PROJECT_ASSIGNMENTS'
 AND   object_id = p_assignment_id
 AND   primary_subteam_flag = 'Y';

BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.set_err_stack('PA_ASSIGNMENT_APPROVAL_PVT.Insert_Into_Assignment_History');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PVT.Insert_Into_Assignment_History.begin'
                     ,x_msg         => 'Beginning of Insert_Into_Assignment_History'
                     ,x_log_level   => 5);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_change_id := NULL;

  --
  -- Get the current assignment record details
  --
  SELECT
         assignment_id
        ,assignment_name
        ,assignment_type
        ,multiple_status_flag
        ,record_version_number
        ,apprvl_status_code
        ,status_code
        ,staffing_priority_code
        ,staffing_owner_person_id
        ,project_id
        ,project_role_id
        ,resource_id
        ,project_party_id
        ,description
        ,note_to_approver
        ,start_date
        ,end_date
        ,assignment_effort
        ,extension_possible
        ,source_assignment_id
        ,assignment_template_id
        ,min_resource_job_level
        ,max_resource_job_level
        ,assignment_number
        ,additional_information
        ,work_type_id
        ,revenue_currency_code
        ,revenue_bill_rate
        ,expense_owner
        ,expense_limit
        ,expense_limit_currency_code
        ,fcst_tp_amount_type
        ,fcst_job_id
        ,fcst_job_group_id
        ,expenditure_org_id
        ,expenditure_organization_id
        ,expenditure_type_class
        ,expenditure_type
        ,location_id
        ,calendar_type
        ,calendar_id
        ,resource_calendar_percent
        ,pending_approval_flag
        ,no_of_active_candidates
        ,competence_match_weighting
        ,availability_match_weighting
        ,job_level_match_weighting
        ,search_min_availability
        ,search_country_code
        ,search_exp_org_struct_ver_id
        ,search_exp_start_org_id
        ,search_min_candidate_score
        ,last_auto_search_date
        ,enable_auto_cand_nom_flag
        ,mass_wf_in_progress_flag
        ,bill_rate_override
        ,bill_rate_curr_override
        ,markup_percent_override
        ,tp_rate_override
        ,tp_currency_override
        ,tp_calc_base_code_override
        ,tp_percent_applied_override
        ,markup_percent
        ,attribute_category
        ,attribute1
        ,attribute2
        ,attribute3
        ,attribute4
        ,attribute5
        ,attribute6
        ,attribute7
        ,attribute8
        ,attribute9
        ,attribute10
        ,attribute11
        ,attribute12
        ,attribute13
        ,attribute14
        ,attribute15
        ,transfer_price_rate  -- Added for bug 3051110
        ,transfer_pr_rate_curr
	,discount_percentage  -- Added for bug 3041583
	,rate_disc_reason_code -- Added for bug 3041583
  INTO
        l_assignment_rec.assignment_id
        ,l_assignment_rec.assignment_name
        ,l_assignment_rec.assignment_type
        ,l_assignment_rec.multiple_status_flag
        ,l_assignment_rec.record_version_number
        ,l_assignment_rec.apprvl_status_code
        ,l_assignment_rec.status_code
        ,l_assignment_rec.staffing_priority_code
        ,l_assignment_rec.staffing_owner_person_id
        ,l_assignment_rec.project_id
        ,l_assignment_rec.project_role_id
        ,l_assignment_rec.resource_id
        ,l_assignment_rec.project_party_id
        ,l_assignment_rec.description
        ,l_assignment_rec.note_to_approver
        ,l_assignment_rec.start_date
        ,l_assignment_rec.end_date
        ,l_assignment_rec.assignment_effort
        ,l_assignment_rec.extension_possible
        ,l_assignment_rec.source_assignment_id
        ,l_assignment_rec.assignment_template_id
        ,l_assignment_rec.min_resource_job_level
        ,l_assignment_rec.max_resource_job_level
        ,l_assignment_rec.assignment_number
        ,l_assignment_rec.additional_information
        ,l_assignment_rec.work_type_id
        ,l_assignment_rec.revenue_currency_code
        ,l_assignment_rec.revenue_bill_rate
        ,l_assignment_rec.expense_owner
        ,l_assignment_rec.expense_limit
        ,l_assignment_rec.expense_limit_currency_code
        ,l_assignment_rec.fcst_tp_amount_type
        ,l_assignment_rec.fcst_job_id
        ,l_assignment_rec.fcst_job_group_id
        ,l_assignment_rec.expenditure_org_id
        ,l_assignment_rec.expenditure_organization_id
        ,l_assignment_rec.expenditure_type_class
        ,l_assignment_rec.expenditure_type
        ,l_assignment_rec.location_id
        ,l_assignment_rec.calendar_type
        ,l_assignment_rec.calendar_id
        ,l_assignment_rec.resource_calendar_percent
        ,l_pending_approval_flag
        ,l_assignment_rec.no_of_active_candidates
        ,l_assignment_rec.comp_match_weighting
        ,l_assignment_rec.avail_match_weighting
        ,l_assignment_rec.job_level_match_weighting
        ,l_assignment_rec.search_min_availability
        ,l_assignment_rec.search_country_code
        ,l_assignment_rec.search_exp_org_struct_ver_id
        ,l_assignment_rec.search_exp_start_org_id
        ,l_assignment_rec.search_min_candidate_score
        ,l_assignment_rec.last_auto_search_date
        ,l_assignment_rec.enable_auto_cand_nom_flag
        ,l_assignment_rec.mass_wf_in_progress_flag
        ,l_assignment_rec.bill_rate_override
        ,l_assignment_rec.bill_rate_curr_override
        ,l_assignment_rec.markup_percent_override
        ,l_assignment_rec.tp_rate_override
        ,l_assignment_rec.tp_currency_override
        ,l_assignment_rec.tp_calc_base_code_override
        ,l_assignment_rec.tp_percent_applied_override
        ,l_assignment_rec.markup_percent
        ,l_assignment_rec.attribute_category
        ,l_assignment_rec.attribute1
        ,l_assignment_rec.attribute2
        ,l_assignment_rec.attribute3
        ,l_assignment_rec.attribute4
        ,l_assignment_rec.attribute5
        ,l_assignment_rec.attribute6
        ,l_assignment_rec.attribute7
        ,l_assignment_rec.attribute8
        ,l_assignment_rec.attribute9
        ,l_assignment_rec.attribute10
        ,l_assignment_rec.attribute11
        ,l_assignment_rec.attribute12
        ,l_assignment_rec.attribute13
        ,l_assignment_rec.attribute14
        ,l_assignment_rec.attribute15
        ,l_assignment_rec.transfer_price_rate  -- Added for bug 3051110
        ,l_assignment_rec.transfer_pr_rate_curr
	,l_assignment_rec.discount_percentage  -- Added for bug 3041583
	,l_assignment_rec.rate_disc_reason_code -- Added for bug 3041583
  FROM pa_project_assignments
  WHERE assignment_id = p_assignment_id;

  --
  --Get the subteam id
  --
  OPEN get_project_subteam_id;
  FETCH get_project_subteam_id INTO l_project_subteam_id;
  IF get_project_subteam_id%NOTFOUND THEN
    l_project_subteam_id := NULL;
  END IF;
  CLOSE get_project_subteam_id;

  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PVT.Insert_Into_Assignment_History.last_approved_flag'
                     ,x_msg         => 'update previously last approved record flag to N'
                     ,x_log_level   => 5);
  END IF;
  --
  --Only the newly inserted row should have last_approved_flag set to 'Y',
  --so updating the previously last approved record's flag to 'N'.
  --
  --IF no previous approved record exist, this statement does nothing.
  --
  --  PA_ASSIGNMENTS_HISTORY_PKG.Update_Row is not used, since the last_approved_flag is used as both
  --  an criteria for search and the parameter need to be updated.
  --
  UPDATE pa_assignments_history
  SET last_approved_flag = 'N'
  WHERE assignment_id = p_assignment_id
  AND last_approved_flag = 'Y';


  --If no errors, insert the approved assignment record into the history table.
  IF (FND_MSG_PUB.Count_Msg = 0) THEN
    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PVT.Insert_Into_Assignment_History.insert_row'
                     ,x_msg         => 'insert last approved record into assignment history table.'
                     ,x_log_level   => 5);
    END IF;

    PA_ASSIGNMENTS_HISTORY_PKG.Insert_Row
    (p_assignment_id               => l_assignment_rec.assignment_id
    ,p_assignment_name             => l_assignment_rec.assignment_name
    ,p_assignment_type             => l_assignment_rec.assignment_type
    ,p_multiple_status_flag        => l_assignment_rec.multiple_status_flag
    ,p_record_version_number       => l_assignment_rec.record_version_number
    ,p_apprvl_status_code          => l_assignment_rec.apprvl_status_code
    ,p_status_code                 => l_assignment_rec.status_code
    ,p_staffing_priority_code      => l_assignment_rec.staffing_priority_code
    ,p_staffing_owner_person_id    => l_assignment_rec.staffing_owner_person_id
    ,p_project_id                  => l_assignment_rec.project_id
    ,p_project_role_id             => l_assignment_rec.project_role_id
    ,p_resource_id                 => l_assignment_rec.resource_id
    ,p_project_party_id            => l_assignment_rec.project_party_id
    ,p_project_subteam_id          => l_project_subteam_id
    ,p_description                 => l_assignment_rec.description
    ,p_note_to_approver            => l_assignment_rec.note_to_approver
    ,p_start_date                  => l_assignment_rec.start_date
    ,p_end_date                    => l_assignment_rec.end_date
    ,p_assignment_effort           => l_assignment_rec.assignment_effort
    ,p_extension_possible          => l_assignment_rec.extension_possible
    ,p_source_assignment_id        => l_assignment_rec.source_assignment_id
    ,p_assignment_template_id      => l_assignment_rec.assignment_template_id
    ,p_min_resource_job_level      => l_assignment_rec.min_resource_job_level
    ,p_max_resource_job_level      => l_assignment_rec.max_resource_job_level
    ,p_assignment_number           => l_assignment_rec.assignment_number
    ,p_additional_information      => l_assignment_rec.additional_information
    ,p_work_type_id                => l_assignment_rec.work_type_id
    ,p_revenue_currency_code       => l_assignment_rec.revenue_currency_code
    ,p_revenue_bill_rate           => l_assignment_rec.revenue_bill_rate
    ,p_fcst_tp_amount_type         => l_assignment_rec.fcst_tp_amount_type
    ,p_fcst_job_id                 => l_assignment_rec.fcst_job_id
    ,p_fcst_job_group_id           => l_assignment_rec.fcst_job_group_id
    ,p_expenditure_org_id          => l_assignment_rec.expenditure_org_id
    ,p_expenditure_organization_id => l_assignment_rec.expenditure_organization_id
    ,p_expenditure_type_class      => l_assignment_rec.expenditure_type_class
    ,p_expenditure_type            => l_assignment_rec.expenditure_type
    ,p_expense_owner               => l_assignment_rec.expense_owner
    ,p_expense_limit               => l_assignment_rec.expense_limit
    ,p_expense_limit_currency_code => l_assignment_rec.expense_limit_currency_code
    ,p_location_id                 => l_assignment_rec.location_id
    ,p_calendar_type               => l_assignment_rec.calendar_type
    ,p_calendar_id                 => l_assignment_rec.calendar_id
    ,p_resource_calendar_percent   => l_assignment_rec.resource_calendar_percent
    ,p_pending_approval_flag       => l_pending_approval_flag
    ,p_last_approved_flag          => 'Y'
    ,p_no_of_active_candidates     => l_assignment_rec.no_of_active_candidates
    ,p_comp_match_weighting        => l_assignment_rec.comp_match_weighting
    ,p_avail_match_weighting       => l_assignment_rec.avail_match_weighting
    ,p_job_level_match_weighting   => l_assignment_rec.job_level_match_weighting
    ,p_search_min_availability     => l_assignment_rec.search_min_availability
    ,p_search_country_code         => l_assignment_rec.search_country_code
    ,p_search_exp_org_struct_ver_id=> l_assignment_rec.search_exp_org_struct_ver_id
    ,p_search_exp_start_org_id     => l_assignment_rec.search_exp_start_org_id
    ,p_search_min_candidate_score  => l_assignment_rec.search_min_candidate_score
    ,p_last_auto_search_date       => l_assignment_rec.last_auto_search_date
    ,p_enable_auto_cand_nom_flag   => l_assignment_rec.enable_auto_cand_nom_flag
    ,p_mass_wf_in_progress_flag    => l_assignment_rec.mass_wf_in_progress_flag
    ,p_bill_rate_override          => l_assignment_rec.bill_rate_override
    ,p_bill_rate_curr_override     => l_assignment_rec.bill_rate_curr_override
    ,p_markup_percent_override     => l_assignment_rec.markup_percent_override
    ,p_tp_rate_override            => l_assignment_rec.tp_rate_override
    ,p_tp_currency_override        => l_assignment_rec.tp_currency_override
    ,p_tp_calc_base_code_override  => l_assignment_rec.tp_calc_base_code_override
    ,p_tp_percent_applied_override => l_assignment_rec.tp_percent_applied_override
    ,p_markup_percent              => l_assignment_rec.markup_percent
    ,p_attribute_category          => l_assignment_rec.attribute_category
    ,p_attribute1                  => l_assignment_rec.attribute1
    ,p_attribute2                  => l_assignment_rec.attribute2
    ,p_attribute3                  => l_assignment_rec.attribute3
    ,p_attribute4                  => l_assignment_rec.attribute4
    ,p_attribute5                  => l_assignment_rec.attribute5
    ,p_attribute6                  => l_assignment_rec.attribute6
    ,p_attribute7                  => l_assignment_rec.attribute7
    ,p_attribute8                  => l_assignment_rec.attribute8
    ,p_attribute9                  => l_assignment_rec.attribute9
    ,p_attribute10                 => l_assignment_rec.attribute10
    ,p_attribute11                 => l_assignment_rec.attribute11
    ,p_attribute12                 => l_assignment_rec.attribute12
    ,p_attribute13                 => l_assignment_rec.attribute13
    ,p_attribute14                 => l_assignment_rec.attribute14
    ,p_attribute15                 => l_assignment_rec.attribute15
    ,p_transfer_price_rate         => l_assignment_rec.transfer_price_rate  -- Added for bug 3051110
    ,p_transfer_pr_rate_curr       => l_assignment_rec.transfer_pr_rate_curr
    ,p_discount_percentage         => l_assignment_rec.discount_percentage  -- Added for bug 3041583
    ,p_rate_disc_reason_code       => l_assignment_rec.rate_disc_reason_code -- Added for bug 3041583
    ,x_assignment_row_id           => l_assignment_row_id
    ,x_change_id                   => l_change_id
    ,x_return_status               => l_return_status);

    --dbms_output.put_line('x_change_id: '|| l_change_id);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
    END IF;
    l_return_status := FND_API.G_MISS_CHAR;
  END IF;



  IF (FND_MSG_PUB.Count_Msg = 0) THEN
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module     => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PVT.Insert_Into_Assignment_History.schedule_history'
                       ,x_msg        => 'Updating Schedule history table.'
                       ,x_log_level  => 5);
    END IF;

    --Call Schedule's API to insert into schedule history table
    PA_SCHEDULE_PVT.UPDATE_HISTORY_TABLE ( P_ASSIGNMENT_ID      => l_assignment_rec.assignment_id
 					,P_CHANGE_ID          => l_change_id
					,X_RETURN_STATUS      => l_return_status
					,X_MSG_COUNT          => l_msg_count
					,X_MSG_DATA           => l_msg_data);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
    END IF;
  ELSE
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  x_change_id := l_change_id;

  PA_DEBUG.Reset_Err_Stack; /* 3148857 */

  EXCEPTION
     WHEN OTHERS THEN
         -- Set the exception Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PVT.Insert_Into_Assignment_History'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         RAISE;  -- This is optional depending on the needs

END Insert_Into_Assignment_History;


--
--This procedure abort the workflow approval outstanding for the specific assignment
--and update the pending_approval_flag to 'N'
--
PROCEDURE Abort_Assignment_Approval
(
 p_assignment_id             IN  pa_project_assignments.assignment_id%TYPE
,p_project_id                IN  pa_project_assignments.project_id%TYPE
,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

CURSOR get_item_key IS
SELECT item_key, item_type
FROM pa_wf_processes
WHERE item_key = (
 SELECT max(item_key)
 FROM pa_wf_processes
 WHERE wf_type_code = 'ASSIGNMENT_APPROVAL'
 AND entity_key1 = to_char(p_project_id)
 AND entity_key2 = to_char(p_assignment_id)
)
and item_type = 'PAWFAAP';

l_item_key      pa_wf_processes.item_key%TYPE;
l_item_type     pa_wf_processes.item_type%TYPE;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.set_err_stack('PA_ASSIGNMENT_APPROVAL_PVT.Insert_Into_Assignment_History');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PVT.Abort_Assignment_Approval.begin'
                     ,x_msg         => 'Beginning of Abort_Assignment_Approval'
                     ,x_log_level   => 5);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  --Get the item key of the workflow process
  OPEN get_item_key;
  FETCH get_item_key INTO l_item_key, l_item_type;

  IF get_item_key%NOTFOUND THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       =>  'PA_NO_WF_TO_ABORT');
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  CLOSE get_item_key;

  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    --Abort the process
    wf_engine.abortprocess (itemtype => l_item_type,
                            itemkey  => l_item_key);

    --Set the pending_approval_flag to 'N'
    PA_ASGMT_WFSTD.Maintain_wf_pending_flag (p_assignment_id => p_assignment_id
                                            ,p_mode  => 'APPROVAL_PROCESS_COMPLETED');
  END IF;

  PA_DEBUG.Reset_err_stack;  /* 3148857 */

  EXCEPTION
     WHEN OTHERS THEN
         -- Set the exception Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PVT.Abort_Assignment_Approval'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         RAISE;  -- This is optional depending on the needs

END Abort_Assignment_Approval;

--
-- Returns meaning from pa_lookups which has p_lookup_type and p_lookup_code
--
FUNCTION get_lookup_meaning (p_lookup_type  IN  VARCHAR2
                            ,p_lookup_code  IN  VARCHAR2)
RETURN VARCHAR2
IS
 l_meaning VARCHAR2(80);
BEGIN

 SELECT meaning
 INTO  l_meaning
 FROM  pa_lookups
 WHERE lookup_type = p_lookup_type
 AND   lookup_code = p_lookup_code;

 return l_meaning;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
        return null;
    WHEN OTHERS THEN
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );

        RAISE;  -- This is optional depending on the needs

END get_lookup_meaning;


--
-- Return following record based on p_assignment_is
--   x_saved_asmt_rec : assignment record having values in pa_project_assignments
--   x_asmt_history_rec : assignment record having values in pa_assignments_history
--
PROCEDURE get_asmt_and_asmt_history_rec (p_assignment_id     IN  NUMBER
                                        ,x_saved_asmt_rec    OUT NOCOPY PA_ASSIGNMENTS_PUB.assignment_rec_type  --File.Sql.39 bug 4440895
                                        ,x_asmt_history_rec  OUT NOCOPY pa_assignments_pub.assignment_rec_type --File.Sql.39 bug 4440895
                                        ,x_return_status     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
CURSOR get_saved_asmt_rec IS
  SELECT assignment_id,
          assignment_name,
          staffing_priority_code,
          description,
          extension_possible,
          additional_information,
          work_type_id,
          expense_owner,
          expense_limit,
          fcst_tp_amount_type,
          expenditure_type_class,
          expenditure_type,
          location_id,
          tp_currency_override,
          tp_rate_override,
          tp_calc_base_code_override,
          tp_percent_applied_override,
          staffing_owner_person_id
  FROM  pa_project_assignments
  WHERE assignment_id = p_assignment_id;

CURSOR get_asmt_history_rec IS
  SELECT assignment_id,
          assignment_name,
          staffing_priority_code,
          description,
          extension_possible,
          additional_information,
          work_type_id,
          expense_owner,
          expense_limit,
          fcst_tp_amount_type,
          expenditure_type_class,
          expenditure_type,
          location_id,
          tp_currency_override,
          tp_rate_override,
          tp_calc_base_code_override,
          tp_percent_applied_override,
          staffing_owner_person_id
  FROM  pa_assignments_history
  WHERE assignment_id = p_assignment_id
  AND   last_approved_flag = 'Y';

CURSOR get_apprvl_status_code IS
  SELECT apprvl_status_code
  FROM  pa_project_assignments
  WHERE assignment_id = p_assignment_id;

l_apprvl_status_code pa_project_assignments.apprvl_status_code%TYPE;
l_change_id NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  ------------------------------------------------------
  -- Get saved_asmt_rec
  ------------------------------------------------------
  OPEN get_saved_asmt_rec;
  FETCH get_saved_asmt_rec INTO
         x_saved_asmt_rec.assignment_id,
         x_saved_asmt_rec.assignment_name,
         x_saved_asmt_rec.staffing_priority_code,
         x_saved_asmt_rec.description,
         x_saved_asmt_rec.extension_possible,
         x_saved_asmt_rec.additional_information,
         x_saved_asmt_rec.work_type_id,
         x_saved_asmt_rec.expense_owner,
         x_saved_asmt_rec.expense_limit,
         x_saved_asmt_rec.fcst_tp_amount_type,
         x_saved_asmt_rec.expenditure_type_class,
         x_saved_asmt_rec.expenditure_type,
         x_saved_asmt_rec.location_id,
         x_saved_asmt_rec.tp_currency_override,
         x_saved_asmt_rec.tp_rate_override,
         x_saved_asmt_rec.tp_calc_base_code_override,
         x_saved_asmt_rec.tp_percent_applied_override,
         x_saved_asmt_rec.staffing_owner_person_id;
  CLOSE get_saved_asmt_rec;

  ------------------------------------------------------
  -- Get asmt_history_rec
  ------------------------------------------------------
  -- get change_id just to check if the history table has a value for this asmt
  l_change_id := Get_Change_Id (p_assignment_id);

  -- get approval status
  OPEN get_apprvl_status_code;
  FETCH get_apprvl_status_code INTO l_apprvl_status_code;
  CLOSE get_apprvl_status_code;

  -- Following two cases we need to get data for x_asmt_history_rec from pa_project_assignments
  -- 1. If history table doesn't have a record for this assignment
  -- 2. If history table has a record but its approval_status is 'approved'
  --    Then it is mass update/schedule submit case, the record in history table is last approved
  --    data not the current approved one which is what we want to show on Change details page.
  IF (l_change_id = -1 OR
      (l_change_id <> -1 AND l_apprvl_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_approved)) THEN
     OPEN get_saved_asmt_rec;
     FETCH get_saved_asmt_rec INTO
         x_asmt_history_rec.assignment_id,
         x_asmt_history_rec.assignment_name,
         x_asmt_history_rec.staffing_priority_code,
         x_asmt_history_rec.description,
         x_asmt_history_rec.extension_possible,
         x_asmt_history_rec.additional_information,
         x_asmt_history_rec.work_type_id,
         x_asmt_history_rec.expense_owner,
         x_asmt_history_rec.expense_limit,
         x_asmt_history_rec.fcst_tp_amount_type,
         x_asmt_history_rec.expenditure_type_class,
         x_asmt_history_rec.expenditure_type,
         x_asmt_history_rec.location_id,
         x_asmt_history_rec.tp_currency_override,
         x_asmt_history_rec.tp_rate_override,
         x_asmt_history_rec.tp_calc_base_code_override,
         x_asmt_history_rec.tp_percent_applied_override,
         x_asmt_history_rec.staffing_owner_person_id;
     CLOSE get_saved_asmt_rec;

   -- If hitory table has a record for this assignment and its approval_status is not 'approved'
   ELSE
     OPEN get_asmt_history_rec;
     FETCH get_asmt_history_rec INTO
         x_asmt_history_rec.assignment_id,
         x_asmt_history_rec.assignment_name,
         x_asmt_history_rec.staffing_priority_code,
         x_asmt_history_rec.description,
         x_asmt_history_rec.extension_possible,
         x_asmt_history_rec.additional_information,
         x_asmt_history_rec.work_type_id,
         x_asmt_history_rec.expense_owner,
         x_asmt_history_rec.expense_limit,
         x_asmt_history_rec.fcst_tp_amount_type,
         x_asmt_history_rec.expenditure_type_class,
         x_asmt_history_rec.expenditure_type,
         x_asmt_history_rec.location_id,
         x_asmt_history_rec.tp_currency_override,
         x_asmt_history_rec.tp_rate_override,
         x_asmt_history_rec.tp_calc_base_code_override,
         x_asmt_history_rec.tp_percent_applied_override,
         x_asmt_history_rec.staffing_owner_person_id;
     CLOSE get_asmt_history_rec;
   END IF;

   EXCEPTION
     WHEN OTHERS THEN
         -- Set the exception Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PVT.get_asmt_and_asmt_history_rec'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         RAISE;  -- This is optional depending on the needs
END get_asmt_and_asmt_history_rec;

END PA_ASSIGNMENT_APPROVAL_PVT ;

/

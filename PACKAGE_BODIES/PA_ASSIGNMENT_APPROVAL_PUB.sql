--------------------------------------------------------
--  DDL for Package Body PA_ASSIGNMENT_APPROVAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ASSIGNMENT_APPROVAL_PUB" AS
/*$Header: PARAAPBB.pls 120.7.12010000.5 2010/06/14 07:05:54 kkorrapo ship $*/
--------------------------------------------------------------------------------------------------------------
-- This procedure prints the text which is being passed as the input
-- Input parameters
-- Parameters                   Type           Required  Description
--  p_log_msg                   VARCHAR2        YES      It stores text which you want to print on screen
-- Out parameters
----------------------------------------------------------------------------------------------------------------
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */

PROCEDURE log_message (p_log_msg IN VARCHAR2)
IS
BEGIN
    --dbms_output.put_line('log: ' || p_log_msg);
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       pa_debug.write('log_message: ' || 'Assignment Approval', 'log: ' || p_log_msg, 3);
    END IF;
        NULL;
END log_message;

--
-- Wrapper API to set approval status and determine which kind of workflow to launch.  The API will
-- only be called from Submit for Approval Page, when the user hit Submit, Approve or Reject buttons
-- or the Cancel button on team list.
-- p_action_code allowed: 'APPROVE', 'SUBMIT', 'REJECT', 'CANCEL'
--
PROCEDURE Start_Assignment_Approvals
( p_assignment_id               IN pa_project_assignments.assignment_id%TYPE
 ,p_new_assignment_flag         IN VARCHAR2
 ,p_action_code                 IN VARCHAR2
 ,p_note_to_approver            IN VARCHAR2                          := FND_API.G_MISS_CHAR
 ,p_record_version_number       IN NUMBER
 ,p_apr_person_id               IN NUMBER   DEFAULT NULL
 ,p_apr_person_name             IN VARCHAR2 DEFAULT NULL
 ,p_apr_person_type             IN VARCHAR2 DEFAULT NULL
 ,p_apr_person_order            IN NUMBER   DEFAULT NULL
 ,p_apr_person_exclude          IN VARCHAR2 DEFAULT NULL
 ,p_check_overcommitment_flag   IN VARCHAR2                          := 'N'
 ,p_conflict_group_id           IN NUMBER   DEFAULT NULL
 ,p_resolve_con_action_code     IN VARCHAR2 DEFAULT NULL
 ,p_api_version                 IN    NUMBER                         := 1.0
 ,p_init_msg_list               IN    VARCHAR2                       := FND_API.G_FALSE
 ,p_commit                      IN    VARCHAR2                       := FND_API.G_FALSE
 ,p_validate_only               IN    VARCHAR2                       := FND_API.G_TRUE
 ,p_max_msg_count               IN    NUMBER                         := FND_API.G_MISS_NUM
 ,x_overcommitment_flag         OUT   NOCOPY VARCHAR2       --File.Sql.39 bug 4440895
 ,x_conflict_group_id           OUT   NOCOPY VARCHAR2         --File.Sql.39 bug 4440895
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

  l_approver_rec                PA_ASSIGNMENT_APPROVAL_PUB.Asgmt_Approvers_Rec_Type;
  l_assignment_type             pa_project_assignments.assignment_type%TYPE;
  l_project_id                  pa_project_assignments.project_id%TYPE;
  l_project_status_name         pa_project_statuses.project_status_name%TYPE;
  l_success_status_code         pa_project_statuses.project_status_code%TYPE;
  l_failure_status_code         pa_project_statuses.project_status_code%TYPE;
  l_start_date                  pa_project_assignments.start_date%TYPE;
  l_pending_approval_flag       pa_project_assignments.pending_approval_flag%TYPE;
  l_project_manager_person_id   NUMBER ;
  l_project_manager_name        VARCHAR2(200);
  l_project_party_id            NUMBER ;
  l_project_role_id             NUMBER ;
  l_project_role_name           VARCHAR2(80);
  l_approver_person_id          NUMBER;
  -- bug 4537865
  l_new_approver_person_id      NUMBER;
   -- bug 4537865
  l_approver_person_type        VARCHAR2(100);
  l_approver2_person_id         NUMBER;
  l_approver2_person_type       VARCHAR2(100);
  l_change_id                   NUMBER;
  l_record_version_number       NUMBER;
  l_return_status               VARCHAR2(1);
  l_apprvl_status_code          pa_project_assignments.apprvl_status_code%TYPE;
  l_next_status_code            pa_project_assignments.apprvl_status_code%TYPE;
  l_schedule_status_code        pa_project_assignments.status_code%TYPE;
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_msg_index_out               NUMBER;
  l_wf_type                     VARCHAR2(80)  := NULL;
  l_wf_item_type                VARCHAR2(2000):= NULL;
  l_wf_process                  VARCHAR2(2000):= NULL;
  l_resource_type_id            NUMBER;
  l_action_code                 VARCHAR2(7);
  l_overcommitment_flag         VARCHAR2(1);
  l_conflict_group_id           NUMBER;
  l_error_message_code          fnd_new_messages.message_name%TYPE;
  l_approval_required_flag      VARCHAR2(1);
  l_check_id_flag               VARCHAR2(1);
  l_status_flag                 VARCHAR2(1);
  l_submitter_user_id           NUMBER;
  l_submitter_person_id         NUMBER;

CURSOR get_asgmt_info IS
 SELECT ppa.assignment_type, ppa.project_id, ppa.start_date, ppa.status_code,
        pps.project_status_name, ppa.pending_approval_flag
 FROM   pa_project_assignments ppa,
        pa_project_statuses pps,
        pa_projects_all pal
 WHERE  ppa.assignment_id = p_assignment_id
   AND  ppa.project_id = pal.project_id
   AND  pal.project_status_code = pps.project_status_code;

CURSOR get_status_codes IS
SELECT DISTINCT status_code
  FROM pa_schedules /* Bug 5614557  Changed usage from pa_schedules_v to pa_schedules */
 WHERE assignment_id = p_assignment_id;

CURSOR l_submitter_person_id_csr(l_submitter_user_id NUMBER) IS
 SELECT employee_id
 FROM   fnd_user
 WHERE  user_id = l_submitter_user_id;

TYPE status_codes IS TABLE OF pa_project_assignments.status_code%TYPE;
l_status_codes     status_codes;


BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ASSIGNMENT_APPROVAL_PUB.Start_Assignment_Approvals');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Start_Assignment_Approvals.begin'
                     ,x_msg         => 'Beginning of Start_Assignment_Approvals'
                     ,x_log_level   => 5);
  END IF;

  -- Initialize the out paramaters
  x_return_status       := FND_API.G_RET_STS_SUCCESS;
  x_overcommitment_flag := 'N';
  x_conflict_group_id   := null;

  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    --Clear the global PL/SQL message table
    FND_MSG_PUB.initialize;

    -- delete all the records from the approver_tbl
    PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl.delete;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT   ASG_APR_PUB_START_APPRVL;
  END IF;

  -- set local variables
  l_conflict_group_id := p_conflict_group_id;

  --
  -- Get the necessary assignment info to start workflow
  --
  OPEN get_asgmt_info;
  FETCH get_asgmt_info INTO l_assignment_type, l_project_id, l_start_date, l_schedule_status_code,
        l_project_status_name, l_pending_approval_flag;
  CLOSE get_asgmt_info;


  --------------------------------------------------------------------------------------------------------
  -- Put the approver's info into global PL/SQL table
  --------------------------------------------------------------------------------------------------------
  -- Check Resource Name or ID
  IF (p_apr_person_id IS NOT NULL AND p_apr_person_id <>FND_API.G_MISS_NUM) OR
     (p_apr_person_name IS NOT NULL AND p_apr_person_name <>FND_API.G_MISS_CHAR) THEN

    l_approver_person_id := p_apr_person_id;

    --Log Message
        IF P_DEBUG_MODE = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Start_Assignment_Approvals.check_resource'
                       ,x_msg         => 'Checking Resource.'
                       ,x_log_level   => 5);
        END IF;
   /* A temporary fix:
    Need to avoid the LOV ID clearing check implemented in most validation packages.
    Since only the ids are passed in and not the names.*/

    l_check_id_flag := PA_STARTUP.G_Check_ID_Flag;
    IF PA_STARTUP.G_Calling_Application = 'SELF_SERVICE' THEN
       PA_STARTUP.G_Check_ID_Flag := 'N';
    END IF;

    PA_RESOURCE_UTILS.Check_ResourceName_OR_ID  ( p_resource_id        => l_approver_person_id
                                                ,p_resource_name       => p_apr_person_name
                                                ,p_check_id_flag       => PA_STARTUP.G_Check_ID_Flag
                                                ,p_date                => l_start_date
                                                --,x_resource_id         => l_approver_person_id        * Bug: 4537865
                                                ,x_resource_id         => l_new_approver_person_id      -- Bug: 4537865
                                                ,x_resource_type_id    => l_resource_type_id
                                                ,x_return_status       => l_return_status
                                                ,x_error_message_code  => l_error_message_code);
    PA_STARTUP.G_Check_ID_Flag := l_check_id_flag;
    -- bug 4537865
    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
    l_approver_person_id := l_new_approver_person_id;
    END IF;
    -- bug 4537865
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      PA_UTILS.Add_Message('PA', l_error_message_code);

    ELSE
      -- Get submitter_person_id : added for bug#2247058
      OPEN l_submitter_person_id_csr(FND_GLOBAL.USER_ID);
      FETCH l_submitter_person_id_csr INTO l_submitter_person_id;
      IF l_submitter_person_id_csr%NOTFOUND THEN
        pa_utils.add_message (p_app_short_name  => 'PA',
                              p_msg_name        => 'PA_NO_EMP_ID_USER');
      END IF;
      CLOSE l_submitter_person_id_csr;

      l_return_status := FND_API.G_MISS_CHAR;
      l_error_message_code := FND_API.G_MISS_CHAR;

      -- Put the Approver into record only exclude flag=N and submitter is not the approver
      IF p_apr_person_exclude = 'N' AND l_submitter_person_id <> l_approver_person_id THEN
                IF P_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Start_Assignment_Approvals.into_g_table'
                           ,x_msg         => 'Putting approver into global table.'
                           ,x_log_level   => 5);
                END IF;
        l_approver_rec.person_id   := l_approver_person_id;
        l_approver_rec.approver_person_type := p_apr_person_type;
        l_approver_rec.orders      := p_apr_person_order;

        PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl(PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl.COUNT+1) := l_approver_rec;
      END IF; -- IF p_apr_person_exclude = 'N'

    END IF;-- end of valid resource

  END IF; -- IF (p_apr_person_id IS NOT NULL AND ...

  --------------------------------------------------------------------------------------------------------
  --  Overcommitment checking
  --------------------------------------------------------------------------------------------------------
  IF (p_check_overcommitment_flag IS NOT NULL AND p_check_overcommitment_flag='Y') THEN
     PA_SCHEDULE_PVT.Check_overcommitment_single
                          ( p_assignment_id                 => p_assignment_id
                           ,p_resolve_conflict_action_code  => p_resolve_con_action_code
                           ,x_overcommitment_flag           => l_overcommitment_flag
                           ,x_conflict_group_id             => l_conflict_group_id
                           ,x_return_status                 => l_return_status
                           ,x_msg_count                     => l_msg_count
                           ,x_msg_data                      => l_msg_data);

     x_overcommitment_flag := l_overcommitment_flag;
     x_conflict_group_id   := to_char(l_conflict_group_id);

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (l_overcommitment_flag = 'Y') THEN
        return;
     END IF;
  END IF; --overcommitment_flag='Y'

  --------------------------------------------------------------------------------------------------------
  -- If p_validate_only = FALSE and need to check overcom, then do all the processing to start assignment approval
  --------------------------------------------------------------------------------------------------------
  IF (p_validate_only = FND_API.G_FALSE AND (p_check_overcommitment_flag ='N'
      OR (p_check_overcommitment_flag ='Y' AND l_overcommitment_flag = 'N'))) THEN

        IF P_DEBUG_MODE = 'Y' THEN
      PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Start_Assignment_Approvals.validate_false'
                       ,x_msg         => 'Not just validating.'
                       ,x_log_level   => 5);
    END IF;
    --------------------------------------------------------------------------------------------------------
    -- Validate Action Code
    --------------------------------------------------------------------------------------------------------
    l_action_code := p_action_code;
    IF l_action_code NOT IN (PA_ASSIGNMENT_APPROVAL_PUB.g_approve_action, PA_ASSIGNMENT_APPROVAL_PUB.g_reject_action,
                           PA_ASSIGNMENT_APPROVAL_PUB.g_submit_action, PA_ASSIGNMENT_APPROVAL_PUB.g_cancel_action) THEN
       PA_UTILS.Add_Message('PA', 'PA_UNEXP_APPRVL_ACTION');
    END IF;


    --IF submitting for approval, then check is approval is required.
    --  IF approval is required, then check if workflow is enabled.
    --    IF workflow is enabled, then validate the approvers order, and check if project manager exists.
    --       And launch workflow.
    --  IF no approval is required, then changes are approved.

    --------------------------------------------------------------------------------------------------------
    --  If Action = SUBMIT
    --------------------------------------------------------------------------------------------------------
    IF l_action_code = PA_ASSIGNMENT_APPROVAL_PUB.g_submit_action THEN

      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
         PA_DEBUG.write_log ('pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Start_Assignment_Approvals.submit'
                          ,'Submitting an approval.', 5);
      END IF;

      --Check if approval is required
      PA_ASSIGNMENT_APPROVAL_PVT.Check_Approval_Required(p_assignment_id          => p_assignment_id
                                                        ,p_new_assignment_flag    => p_new_assignment_flag
                                                        ,x_approval_required_flag => l_approval_required_flag
                                                        ,x_return_status          => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --------------------------------------------------------------------------------------------------------
        --  If Approval Required
        --------------------------------------------------------------------------------------------------------
        IF l_approval_required_flag = 'Y' THEN
          IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
             PA_DEBUG.write_log ('pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Start_Assignment_Approvals.appr_reqd'
                              ,'Approval Required.', 5);
          END IF;

          --Check if workflow enabled
          PA_ASGMT_WFSTD.get_workflow_process_info(p_status_code => PA_ASSIGNMENT_APPROVAL_PUB.g_submitted,
                                                 x_wf_item_type => l_wf_item_type,
                                                 x_wf_process => l_wf_process,
                                                 x_wf_type => l_wf_type,
                                                 x_msg_count => l_msg_count,
                                                 x_msg_data => l_msg_data,
                                                 x_return_status => l_return_status,
                                                 x_error_message_code => l_error_message_code);

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            PA_UTILS.Add_Message('PA',l_error_message_code);
          END IF;
/*  commented out for bug #2247058
          --------------------------------------------------------------------------------------------------------
          --  If Workflow is Enabled
          --------------------------------------------------------------------------------------------------------
          IF l_wf_type <> 'NOT_ENABLED' THEN
               PA_DEBUG.write_log ('pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Start_Assignment_Approvals.enabled'
                                ,'Workflow is enabled. Now validating approvers order.',5);

            --Validate Approvers Order
            PA_ASSIGNMENT_APPROVAL_PVT.Validate_Approver_Orders (x_return_status => l_return_status);
          END IF; --end of workflow enabled
*/
        -- if approval is not required
        ELSE
          l_action_code := PA_ASSIGNMENT_APPROVAL_PUB.g_approve_action;
        END IF; -- if l_approval_required_flag = 'Y'

      END IF; -- l_return_status = FND_API.G_RET_STS_SUCCESS

    END IF; --  If Action = SUBMIT


    --------------------------------------------------------------------------------------------------------
    --  Check project status controls to see if provisional/confirmed assignments are allowed
    --------------------------------------------------------------------------------------------------------
    --Get the schedule status(es) of the assignment
    IF l_schedule_status_code IS NULL THEN
       OPEN get_status_codes;
       FETCH get_status_codes BULK COLLECT INTO l_status_codes;
       CLOSE get_status_codes;
    ELSE
       --use constructor to initialize the nested table.
       l_status_codes := status_codes(l_schedule_status_code);
    END IF;


    --Get their success/failure statuses
    --and check to see if provisional/confirmed assignments are allowed for the given project statuses
    FOR l_index IN 1..l_status_codes.COUNT LOOP

       --Get success/failure statuses
       PA_PROJECT_STUS_UTILS.get_wf_success_failure_status
                                (p_status_code             => l_status_codes(l_index)
                                ,p_status_type             => 'STAFFED_ASGMT'
                                ,x_wf_success_status_code  => l_success_status_code
                                ,x_wf_failure_status_code  => l_failure_status_code
                                ,x_return_status           => l_return_status
                                ,x_error_message_code      => l_error_message_code) ;

       --Check to see if the the success status is allowed for the given project status
       IF( PA_ASSIGNMENT_UTILS.is_asgmt_allow_stus_ctl_check(
                                         p_asgmt_status_code  => l_success_status_code
                                        ,p_project_id         => l_project_id
                                        ,p_add_message        => 'N') = 'N' ) THEN

         PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_APPRVL_PROJ_STUS_NOT_ALLOW'
                              ,p_token1         => 'PROJ_STATUS'
                              ,p_value1         => l_project_status_name);
         EXIT;
         --dbms_output.put_line('Open Assignment Status not allowed');
       END IF; --end of check provisional

       --Check to see if the failure status is allowed for the given project status
       IF( PA_ASSIGNMENT_UTILS.is_asgmt_allow_stus_ctl_check(
                                       p_asgmt_status_code  => l_failure_status_code
                                      ,p_project_id         => l_project_id
                                      ,p_add_message        => 'N') = 'N' ) THEN

          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_APPRVL_PROJ_STUS_NOT_ALLOW'
                               ,p_token1         => 'PROJ_STATUS'
                               ,p_value1         => l_project_status_name);
          EXIT;
          --dbms_output.put_line('Open Assignment Status not allowed');
       END IF; --end of check provisional

    END LOOP; --end of for loop


    -- if there is no error so far
    IF FND_MSG_PUB.Count_Msg < 1 THEN

      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
         PA_DEBUG.write_log ('pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Start_Assignment_Approvals.update_status',
                          'Update Assignment Approval Status.', 5);
      END IF;
      --------------------------------------------------------------------------------------------------------
      --  Update Approval Status
      --------------------------------------------------------------------------------------------------------
      PA_ASSIGNMENT_APPROVAL_PVT.Update_Approval_Status(p_assignment_id      => p_assignment_id
                                                ,p_action_code        => l_action_code
                                                ,p_note_to_approver   => p_note_to_approver
                                                ,p_record_version_number => p_record_version_number
                                                ,x_apprvl_status_code => l_apprvl_status_code
                                                ,x_change_id          => l_change_id
                                                ,x_record_version_number => l_record_version_number
                                                ,x_return_status      => l_return_status
                                                ,x_msg_count          => l_msg_count
                                                ,x_msg_data           => l_msg_data);

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        l_return_status := FND_API.G_MISS_CHAR;

        --------------------------------------------------------------------------------------------------------
        --  Resolve Overcommitment conflict for Approve case
        --------------------------------------------------------------------------------------------------------
        IF (l_conflict_group_id IS NOT NULL AND l_action_code=PA_ASSIGNMENT_APPROVAL_PUB.g_approve_action) THEN
           -- resolve remaining conflicts by taking action chosen by user
           PA_SCHEDULE_PVT.RESOLVE_CONFLICTS (p_conflict_group_id   => l_conflict_group_id
                                             ,p_assignment_id       => p_assignment_id
                                             ,x_return_status       => l_return_status
                                             ,x_msg_count           => l_msg_count
                                             ,x_msg_data            => l_msg_data);
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;

           -- complete post overcommitment processing
           PA_SCHEDULE_PVT.OVERCOM_POST_APRVL_PROCESSING
                                              (p_conflict_group_id   => l_conflict_group_id
                                              ,p_fnd_user_name       => FND_GLOBAL.USER_NAME
                                              ,x_return_status       => l_return_status
                                              ,x_msg_count           => l_msg_count
                                              ,x_msg_data            => l_msg_data);
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF; -- IF (l_conflict_group_id IS NOT NULL...


        --If previously no workflow info has been obtained, then get it.
        IF (l_wf_item_type IS NULL AND l_wf_process IS NULL AND l_wf_type IS NULL) THEN

          IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
             PA_DEBUG.write_log ('pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Start_Assignment_Approvals.get_wf_info'
                             ,'Getting workflow info.', 5);
          END IF;

          --dbms_output.put_line('error before get_workflow_process_info'||FND_MSG_PUB.Count_Msg);
          PA_ASGMT_WFSTD.get_workflow_process_info(p_status_code => l_apprvl_status_code,
                                                 x_wf_item_type => l_wf_item_type,
                                                 x_wf_process => l_wf_process,
                                                 x_wf_type => l_wf_type,
                                                 x_msg_count => l_msg_count,
                                                 x_msg_data => l_msg_data,
                                                 x_return_status => l_return_status,
                                                 x_error_message_code => l_error_message_code);
          --dbms_output.put_line('inside wf type'||l_wf_type);

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            PA_UTILS.Add_Message('PA', l_error_message_code);
          END IF;

        END IF; -- (l_wf_item_type IS NULL AND l..

        --dbms_output.put_line('l_action_code'||l_action_code);
        --dbms_output.put_line('p_new_assignment_flag'||p_new_assignment_flag);

        --------------------------------------------------------------------------------------------------------
        --  If workflow launch is required
        --------------------------------------------------------------------------------------------------------
        --workflow enabled and no error when getting workflow info
        --For Cancel option, do not launch workflow if the assignment have not been previously approved.
        IF (l_wf_type <> 'NOT_ENABLED') AND
           (l_action_code <> PA_ASSIGNMENT_APPROVAL_PUB.g_cancel_action OR p_new_assignment_flag = 'N' )THEN

          --dbms_output.put_line('ready to launch');
          IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
             PA_DEBUG.write_log ('pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Start_Assignment_Approvals.get_approvers',
                             'Workflow enabled. Getting Approvers ready for start workflow.', 5);
          END IF;

          --------------------------------------------------------------------------------------------------------
          --  Get the approvers from the PL/SQL Table
          --------------------------------------------------------------------------------------------------------
          l_approver_person_id := NULL;
          l_approver_person_type := NULL;
          l_approver2_person_id := NULL;
          l_approver2_person_type := NULL;

          IF g_approver_tbl.FIRST IS NOT NULL THEN
            l_approver_person_id   := g_approver_tbl(g_approver_tbl.FIRST).person_id;
            l_approver_person_type := g_approver_tbl(g_approver_tbl.FIRST).approver_person_type;

            IF g_approver_tbl.COUNT > 1 THEN
               l_approver2_person_id   := g_approver_tbl(g_approver_tbl.LAST).person_id;
               l_approver2_person_type := g_approver_tbl(g_approver_tbl.LAST).approver_person_type;
            END IF;
          END IF;

          --------------------------------------------------------------------------------------------------------
          --  Validate if a project manager exist for non-admin projects
          --------------------------------------------------------------------------------------------------------
          IF l_assignment_type <> 'STAFFED_ADMIN_ASSIGNMENT' THEN
                        IF P_DEBUG_MODE = 'Y' THEN
              PA_DEBUG.write_log (x_module => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Start_Assignment_Approvals.check_prj_manager.'
                               ,x_msg    => 'Check if proj manger exists.'
                               ,x_log_level => 5);
                        END IF;
            pa_project_parties_utils.get_curr_proj_mgr_details
                  (p_project_id         => l_project_id
                  ,x_manager_person_id  => l_project_manager_person_id
                  ,x_manager_name       => l_project_manager_name
                  ,x_project_party_id   => l_project_party_id
                  ,x_project_role_id    => l_project_role_id
                  ,x_project_role_name  => l_project_role_name
                  ,x_return_status      => l_return_status
                  ,x_error_message_code => l_error_message_code );

            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                PA_UTILS.Add_Message('PA', l_error_message_code);
            END IF;

            l_return_status := FND_API.G_MISS_CHAR;
            l_error_message_code := FND_API.G_MISS_CHAR;
          END IF;  -- IF l_assignment_type <> 'STAFFED_ADMIN_ASSIGNMENT'

          ----------------------------------------------------------
          --  check Pending Approval
          ----------------------------------------------------------
          IF NVL(l_pending_approval_flag, 'N') = 'Y' THEN
             PA_UTILS.Add_Message('PA', 'PA_ASG_APPROVAL_PENDING');
          ELSE
             -- set approval pending flag if this assignment has been submitted
             IF l_action_code = g_submit_action THEN
                PA_ASGMT_WFSTD.Maintain_wf_pending_flag
                        (p_assignment_id => p_assignment_id,
                         p_mode          => 'PENDING_APPROVAL') ;
             END IF;
          END IF;

          --------------------------------------------------------------------------------------------------------
          --  Launch workflow
          --------------------------------------------------------------------------------------------------------
          IF FND_MSG_PUB.Count_Msg < 1 THEN
             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                PA_DEBUG.write_log ('pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Start_Assignment_Approvals.launch_wf'
                                ,'Launching workflow.', 5);
             END IF;
             --dbms_output.put_line('wf item type: '||l_wf_item_type ||', wf process: '||l_wf_process ||
             --                     'apprvl_status_code'||l_apprvl_status_code);

             PA_ASGMT_WFSTD.Start_Workflow ( p_project_id             => l_project_id
                                           , p_assignment_id          => p_assignment_id
                                           , p_status_code            => l_apprvl_status_code
                                           , p_wf_item_type           => l_wf_item_type
                                           , p_wf_process             => l_wf_process
                                           , p_approver1_person_id    => l_approver_person_id
                                           , p_approver1_type         => l_approver_person_type
                                           , p_approver2_person_id    => l_approver2_person_id
                                           , p_approver2_type         => l_approver2_person_type
                                           , p_conflict_group_id      => l_conflict_group_id
                                           , x_msg_count              => l_msg_count
                                           , x_msg_data               => l_msg_data
                                           , x_return_status          => l_return_status
                                           , x_error_message_code     => l_error_message_code);
            --dbms_output.put_line('start_workflow return status:'||l_return_status );

            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               PA_UTILS.Add_Message('PA', l_error_message_code);
            END IF;
          END IF; -- FND_MSG_PUB.Count_Msg < 1

        END IF; -- IF (l_wf_type <> 'NOT_ENABLED') AND...
      END IF; -- return_status of update_approval_status  = FND_API.G_RET_STS_SUCCESS
    END IF; -- IF FND_MSG_PUB.Count_Msg < 1


    --clear PL/SQL table for next time
    PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl.DELETE;

  END IF; -- IF p_validate_only = FND_API.G_FALSE

  --------------------------------------------------------------------------------------------------------
  -- Set OUT parameters
  --------------------------------------------------------------------------------------------------------
  x_msg_count :=  FND_MSG_PUB.Count_Msg;

  -- If g_error_exists is TRUE then set the x_return_status to 'E'
  IF x_msg_count >0  THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

     IF x_msg_count = 1 THEN
        pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                             ,p_msg_index     => 1
                                             ,p_data          => x_msg_data
                                             ,p_msg_index_out => l_msg_index_out );
     END IF;
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_count := FND_MSG_PUB.Count_Msg;

       IF x_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages (p_encoded       => FND_API.G_TRUE,
                                               p_msg_index      => 1,
                                               p_data           => x_msg_data,
                                               p_msg_index_out  => l_msg_index_out );
       END IF;

     WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO  ASG_APR_PUB_START_APPRVL;
        END IF;

        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PVT.Start_Assignment_Approvals'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --clear PL/SQL table for next time
        PA_ASSIGNMENT_APPROVAL_PUB.g_approver_tbl.DELETE;
        RAISE;  -- This is optional depending on the needs

END  Start_Assignment_Approvals;




--
--API used to revert the current record in pa_project_assignments table to the last approved record in history table.
--
PROCEDURE Revert_To_Last_Approved
( p_assignment_id          IN   pa_project_assignments.assignment_id%TYPE
 ,p_api_version                 IN    NUMBER                                                  := 1.0
 ,p_init_msg_list               IN    VARCHAR2                                                := FND_API.G_FALSE
 ,p_commit                      IN    VARCHAR2                                                := FND_API.G_FALSE
 ,p_validate_only               IN    VARCHAR2                                                := FND_API.G_TRUE
 ,p_max_msg_count               IN    NUMBER                                                  := FND_API.G_MISS_NUM
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS

  l_assignment_rec        PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
  l_change_id             NUMBER;
  l_record_version_number NUMBER;
  l_return_status         VARCHAR2(1);
  l_apprvl_status_code    pa_project_assignments.apprvl_status_code%TYPE;
  l_next_status_code      pa_project_assignments.apprvl_status_code%TYPE;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_msg_index_out         NUMBER;
  l_project_subteam_party_id NUMBER;
  l_project_subteam_id       NUMBER;

CURSOR get_apprvl_stus_and_record_num IS
 SELECT apprvl_status_code, record_version_number
 FROM pa_project_assignments
 WHERE assignment_id = p_assignment_id;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ASSIGNMENT_APPROVAL_PUB.Revert_To_Last_Approved');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Revert_To_Last_Approved.begin'
                       ,x_msg         => 'Beginning of Revert_To_Last_Approved.'
                       ,x_log_level   => 5);
  END IF;

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT   ASG_APR_PUB_REVERT;
  END IF;

IF PA_ASGMT_WFSTD.is_approval_pending(p_assignment_id => p_assignment_id) = 'Y' THEN

   PA_UTILS.Add_Message( p_app_short_name => 'PA'
                        ,p_msg_name       => 'PA_WF_APPROVAL_PENDING');
ELSIF PA_ASSIGNMENT_APPROVAL_PVT.is_new_assignment(p_assignment_id => p_assignment_id) = 'Y' THEN
   PA_UTILS.Add_Message( p_app_short_name => 'PA'
                        ,p_msg_name       => 'PA_NO_APPRV_ASGMT_TO_REVERT');
ELSE
  --
  --Get last approved record from assignments history
  --
  SELECT
         assignment_id
        ,assignment_name
        ,assignment_type
        ,multiple_status_flag
        ,record_version_number
        ,change_id
        ,apprvl_status_code
        ,status_code
        ,staffing_priority_code
        ,project_id
        ,project_role_id
        ,resource_id
        ,project_party_id
        ,project_subteam_id
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
     --   ,no_of_active_candidates
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
  INTO
        l_assignment_rec.assignment_id
        ,l_assignment_rec.assignment_name
        ,l_assignment_rec.assignment_type
        ,l_assignment_rec.multiple_status_flag
        ,l_assignment_rec.record_version_number
        ,l_change_id
        ,l_assignment_rec.apprvl_status_code
        ,l_assignment_rec.status_code
        ,l_assignment_rec.staffing_priority_code
        ,l_assignment_rec.project_id
        ,l_assignment_rec.project_role_id
        ,l_assignment_rec.resource_id
        ,l_assignment_rec.project_party_id
        ,l_project_subteam_id
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
     --   ,l_assignment_rec.no_of_active_candidates
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
  FROM pa_assignments_history
  WHERE assignment_id = p_assignment_id
  AND last_approved_flag = 'Y';


  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Revert_To_Last_Approved.delete_row'
                       ,x_msg         => 'Deleting last approved record.'
                       ,x_log_level   => 5);
  END IF;

  --
  --Delete the last approved record from the assignment history table.
  --
  IF (FND_MSG_PUB.Count_Msg = 0) THEN
    PA_ASSIGNMENTS_HISTORY_PKG.Delete_Row( p_assignment_id      => p_assignment_id
                                          ,p_last_approved_flag => 'Y'
                                          ,x_return_status      => l_return_status);
  END IF;


  --
  --Get current assignment status and record version number
  --
  OPEN get_apprvl_stus_and_record_num;
  FETCH get_apprvl_stus_and_record_num INTO l_apprvl_status_code, l_record_version_number;

  CLOSE get_apprvl_stus_and_record_num;


  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Revert_To_Last_Approved.get_next_stus'
                       ,x_msg         => 'Get next assignment approval status..'
                       ,x_log_level   => 5);
  END IF;

  --
  --Get the Assignment Approval Status after reverting
  --
  PA_ASSIGNMENT_APPROVAL_PVT.Get_Next_Status_After_Action ( p_action_code => PA_ASSIGNMENT_APPROVAL_PUB.g_revert_action
                                                    ,p_status_code => l_apprvl_status_code
                                                    ,x_status_code => l_next_status_code
                                                    ,x_return_status => l_return_status);



  --
  --Update the current assignment record with new status and record details from the history table
  --
  IF (FND_MSG_PUB.Count_Msg = 0) THEN

    --Log Message
        IF P_DEBUG_MODE = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Revert_To_Last_Approved.update_row'
                       ,x_msg         => 'Update current record with history record details.'
                       ,x_log_level   => 5);
    END IF;

    PA_PROJECT_ASSIGNMENTS_PKG.Update_Row
    (p_assignment_id               => l_assignment_rec.assignment_id
    ,p_record_version_number       => l_record_version_number
    ,p_assignment_name             => l_assignment_rec.assignment_name
    ,p_assignment_type             => l_assignment_rec.assignment_type
    ,p_multiple_status_flag        => l_assignment_rec.multiple_status_flag
    ,p_apprvl_status_code          => l_next_status_code
    ,p_staffing_priority_code      => l_assignment_rec.staffing_priority_code
    ,p_status_code                 => l_assignment_rec.status_code
    ,p_project_id                  => l_assignment_rec.project_id
    ,p_project_role_id             => l_assignment_rec.project_role_id
    ,p_resource_id                 => l_assignment_rec.resource_id
    ,p_project_party_id            => l_assignment_rec.project_party_id
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
    ,p_pending_approval_flag       => 'N'
 --   ,p_no_of_active_candidates     => l_assignment_rec.no_of_active_candidates
    ,p_comp_match_weighting        => l_assignment_rec.comp_match_weighting
    ,p_avail_match_weighting       => l_assignment_rec.avail_match_weighting
    ,p_job_level_match_weighting   => l_assignment_rec.job_level_match_weighting
    ,p_search_min_availability     => l_assignment_rec.search_min_availability
    ,p_search_country_code         => l_assignment_rec.search_country_code
    ,p_search_exp_org_struct_ver_id => l_assignment_rec.search_exp_org_struct_ver_id
    ,p_search_exp_start_org_id     => l_assignment_rec.search_exp_start_org_id
    ,p_search_min_candidate_score  => l_assignment_rec.search_min_candidate_score
 -- ,p_last_auto_search_date       => l_assignment_rec.last_auto_search_date
    ,p_enable_auto_cand_nom_flag   => l_assignment_rec.enable_auto_cand_nom_flag
 -- ,p_mass_wf_in_progress_flag    => l_assignment_rec.mass_wf_in_progress_flag
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
    ,x_return_status               => l_return_status);

    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Revert_To_Last_Approved.revert_schedule'
                       ,x_msg         => 'Reverting Schedule.'
                       ,x_log_level   => 5);
    END IF;
    --
    --Revert the schedule records also.
    --
    PA_SCHEDULE_PVT.Revert_To_Last_Approved ( p_assignment_id  => p_assignment_id
                                             ,p_change_id      => l_change_id
                                             ,x_return_status  => l_return_status
                                             ,x_msg_count      => l_msg_count
                                             ,x_msg_data       => l_msg_data);
    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Revert_To_Last_Approved.revert_subteam'
                       ,x_msg         => 'Reverting Subteam.'
                       ,x_log_level   => 5);
    END IF;

    --
    --Revert the Project Subteam
    --
    PA_PROJECT_SUBTEAM_PARTIES_PVT.Update_SPT_Assgn
    ( p_validate_only                   => p_validate_only
     ,p_get_subteam_party_id_flag       => 'Y'
     ,p_project_subteam_id              => l_project_subteam_id
     ,p_object_type                     => 'PA_PROJECT_ASSIGNMENTS'
     ,p_object_id                       => p_assignment_id
     ,x_project_subteam_party_id        => l_project_subteam_party_id
     ,x_return_status                   => l_return_status
     ,x_record_version_number           => l_record_version_number
     ,x_msg_count                       => l_msg_count
     ,x_msg_data                        => l_msg_data
    );

  END IF; -- end of update row and revert


END IF; --end of checking approval pending on the current record
  --
  --Take care the out parameters
  --
  --
  -- IF the number of messaages is 1 then fetch the message code from the stack and return its text
  --

  x_msg_count :=  FND_MSG_PUB.Count_Msg;

  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program

  PA_DEBUG.Reset_Err_Stack;

  -- If g_error_exists is TRUE then set the x_return_status to 'E'

  IF FND_MSG_PUB.Count_Msg >0  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;


  EXCEPTION
     WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO ASG_APR_PUB_REVERT;
        END IF;

         -- Set the exception Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PUB.Revert_To_Last_Approved'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         RAISE;  -- This is optional depending on the needs

END Revert_To_Last_Approved;




--
-- This procedure populates the PA_ASGMT_CHANGED_ITEMS table with changes on the assignment if the
-- assignment has been previously approved (i.e. not a new assignment). It compares the record with
-- the last approved record, and stores those changed fields and their old and new values in the table.
-- Currently, this api is called by Single/Mass Submit for Approval
--
PROCEDURE Populate_Changed_Items_Table
( p_assignment_id               IN  pa_project_assignments.assignment_id%TYPE
 ,p_populate_mode               IN  VARCHAR2                                                := 'SAVED'
 ,p_assignment_name             IN  pa_project_assignments.assignment_name%TYPE             := FND_API.G_MISS_CHAR
 ,p_project_id                  IN  pa_project_assignments.project_id%TYPE                  := FND_API.G_MISS_NUM
 ,p_staffing_priority_code      IN  pa_project_assignments.staffing_priority_code%TYPE      := FND_API.G_MISS_CHAR
 ,p_description                 IN  pa_project_assignments.description%TYPE                 := FND_API.G_MISS_CHAR
 ,p_extension_possible          IN  pa_project_assignments.extension_possible%TYPE          := FND_API.G_MISS_CHAR
 ,p_additional_information      IN  pa_project_assignments.additional_information%TYPE      := FND_API.G_MISS_CHAR
 ,p_work_type_id                IN  pa_project_assignments.work_type_id%TYPE                := FND_API.G_MISS_NUM
 ,p_expense_owner               IN  pa_project_assignments.expense_owner%TYPE               := FND_API.G_MISS_CHAR
 ,p_expense_limit               IN  pa_project_assignments.expense_limit%TYPE               := FND_API.G_MISS_NUM
 ,p_fcst_tp_amount_type         IN  pa_project_assignments.fcst_tp_amount_type%TYPE         := FND_API.G_MISS_CHAR
 ,p_expenditure_type_class      IN  pa_project_assignments.expenditure_type_class%TYPE      := FND_API.G_MISS_CHAR
 ,p_expenditure_type            IN  pa_project_assignments.expenditure_type%TYPE            := FND_API.G_MISS_CHAR
 ,p_location_id                 IN  pa_project_assignments.location_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_staffing_owner_person_id    IN  pa_project_assignments.staffing_owner_person_id%TYPE    := FND_API.G_MISS_NUM
 ,p_staffing_owner_name         IN  per_people_f.full_name%TYPE                             := FND_API.G_MISS_CHAR
 ,p_exception_type_code         IN  VARCHAR2                                                := NULL
 ,p_start_date                  IN  DATE                                                    := NULL
 ,p_end_date                    IN  DATE                                                    := NULL
 ,p_requirement_status_code     IN  VARCHAR2                                                := NULL
 ,p_assignment_status_code      IN  VARCHAR2                                                := NULL
 ,p_start_date_tbl              IN  SYSTEM.PA_DATE_TBL_TYPE                                 := NULL
 ,p_end_date_tbl                IN  SYSTEM.PA_DATE_TBL_TYPE                                 := NULL
 ,p_monday_hours_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE                                  := NULL
 ,p_tuesday_hours_tbl           IN  SYSTEM.PA_NUM_TBL_TYPE                                  := NULL
 ,p_wednesday_hours_tbl         IN  SYSTEM.PA_NUM_TBL_TYPE                                  := NULL
 ,p_thursday_hours_tbl          IN  SYSTEM.PA_NUM_TBL_TYPE                                  := NULL
 ,p_friday_hours_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE                                  := NULL
 ,p_saturday_hours_tbl          IN  SYSTEM.PA_NUM_TBL_TYPE                                  := NULL
 ,p_sunday_hours_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE                                  := NULL
 ,p_non_working_day_flag        IN  VARCHAR2                                                := 'N'
 ,p_change_hours_type_code      IN  VARCHAR2                                                := NULL
 ,p_hrs_per_day                 IN  NUMBER                                                  := NULL
 ,p_calendar_percent            IN  NUMBER                                                  := NULL
 ,p_change_calendar_type_code   IN  VARCHAR2                                                := NULL
 ,p_change_calendar_name        IN  VARCHAR2                                                := NULL
 ,p_change_calendar_id          IN  NUMBER                                                  := NULL
 ,p_duration_shift_type_code    IN  VARCHAR2                                                := NULL
 ,p_duration_shift_unit_code    IN  VARCHAR2                                                := NULL
 ,p_number_of_shift             IN  NUMBER                                                  := NULL
 ,p_api_version                 IN  NUMBER                                                  := 1.0
 ,p_init_msg_list               IN  VARCHAR2                                                := FND_API.G_FALSE
 ,p_max_msg_count               IN  NUMBER                                                  := FND_API.G_MISS_NUM
 ,x_new_assignment_flag         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_approval_required_flag      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_record_version_number       OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
  l_new_value              pa_lookups.meaning%TYPE;
  l_old_value              pa_lookups.meaning%TYPE;
  l_new_city               pa_locations.city%TYPE;
  l_new_region             pa_locations.region%TYPE;
  l_new_country_code       pa_locations.country_code%TYPE;
  l_old_city               pa_locations.city%TYPE;
  l_old_region             pa_locations.region%TYPE;
  l_old_country_code       pa_locations.country_code%TYPE;
  l_new_work_type          pa_work_types_vl.name%TYPE;
  l_old_work_type          pa_work_types_vl.name%TYPE;
  l_new_subteam_name       pa_project_subteams.name%TYPE;
  l_old_subteam_name       pa_project_subteams.name%TYPE;
  l_project_subteam_id     pa_project_subteam_parties.project_subteam_id%TYPE;
  l_his_project_subteam_id pa_assignments_history.project_subteam_id%TYPE;
  l_msg_index_out          NUMBER;
  l_change_id              NUMBER;
  l_return_status          VARCHAR2(1);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_changed_item           pa_lookups.meaning%TYPE;
  l_asmt_history_rec       pa_assignments_pub.assignment_rec_type;
  l_saved_asmt_rec         pa_assignments_pub.assignment_rec_type;
  l_updated_asmt_rec       pa_assignments_pub.assignment_rec_type;

CURSOR get_rec_ver_num IS
 SELECT record_version_number
 FROM pa_project_assignments
 WHERE assignment_id = p_assignment_id;

CURSOR  get_locations (new_location_id NUMBER, old_location_id NUMBER) IS
 SELECT location_id, city, region, country_code
 FROM   pa_locations
 WHERE  location_id in (new_location_id, old_location_id);

CURSOR get_project_subteam_names (new_project_subteam_id NUMBER, old_project_subteam_id NUMBER)IS
  SELECT project_subteam_id, name
  FROM   pa_project_subteams
  WHERE  project_subteam_id in (new_project_subteam_id, old_project_subteam_id);

CURSOR get_project_subteam_id IS
 SELECT project_subteam_id
 FROM pa_project_subteam_parties
 WHERE object_type = 'PA_PROJECT_ASSIGNMENTS'
 AND   object_id  = p_assignment_id
 AND   primary_subteam_flag = 'Y';

CURSOR get_his_project_subteam_id IS
 SELECT project_subteam_id
 FROM   pa_assignments_history
 WHERE  assignment_id      = p_assignment_id
 AND    last_approved_flag = 'Y';

CURSOR get_work_type_names (new_work_type_id NUMBER, old_work_type_id NUMBER) IS
 SELECT work_type_id, name
 FROM  pa_work_types_vl
 WHERE work_type_id in (new_work_type_id, old_work_type_id);

BEGIN
  --Issue rollback to clean up the Global Temporary Table PA_ASGMT_CHANGED_ITEMS
  ROLLBACK;

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ASSIGNMENT_APPROVAL_PUB.Populate_Changed_Items_Table');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- set out parameter
  OPEN get_rec_ver_num;
  FETCH get_rec_ver_num INTO x_record_version_number;
  CLOSE get_rec_ver_num;

  ---------------------------------------------------------------------------
  -- Check if it is a New Assignemnt
  ---------------------------------------------------------------------------
  x_new_assignment_flag := PA_ASSIGNMENT_APPROVAL_PVT.Is_New_Assignment(p_assignment_id => p_assignment_id);

  -- Check if approval is required to pass the out parameter 'x_approval_required_flag'
  PA_ASSIGNMENT_APPROVAL_PVT.Check_Approval_Required( p_assignment_id          => p_assignment_id
                                                     ,p_new_assignment_flag    => x_new_assignment_flag
                                                     ,x_approval_required_flag => x_approval_required_flag
                                                     ,x_return_status          => l_return_status);

  ---------------------------------------------------------------------------
  -- If it is a New Assignemnt => just return
  ---------------------------------------------------------------------------
  IF x_new_assignment_flag = 'Y' THEN
    return;
  END IF;

  ---------------------------------------------------------------------------
  -- Generate history_asmt_rec and latest updated_asmt_rec
  ---------------------------------------------------------------------------
  PA_ASSIGNMENT_APPROVAL_PVT.get_asmt_and_asmt_history_rec
                              (p_assignment_id       => p_assignment_id
                              ,x_saved_asmt_rec      => l_saved_asmt_rec
                              ,x_asmt_history_rec    => l_asmt_history_rec
                              ,x_return_status       => l_return_status);

  l_updated_asmt_rec := l_saved_asmt_rec;

  -- if this api is called by drill down from Mass Update Assignemnt Basic Info/Forecast, we need to
  -- consider the passed(unsaved) values for latest values. Otherwise the latest values would be
  -- in the db already.
  IF (p_populate_mode = 'ASSIGNMENT_UPDATED') THEN
     -- get the latest updated_asmt_rec based on db saved rec and the passed(unsaved) values, we will use
     -- the latest updated_asmt_rec and l_asmt_history_rec to get the changed items.
     SELECT DECODE(p_assignment_id, null, l_saved_asmt_rec.assignment_id, p_assignment_id),
            DECODE(p_assignment_name, null, l_saved_asmt_rec.assignment_name, p_assignment_name),
            DECODE(p_staffing_priority_code, null, l_saved_asmt_rec.staffing_priority_code, p_staffing_priority_code),
            DECODE(p_description, null, l_saved_asmt_rec.description, p_description),
            DECODE(p_extension_possible, null, l_saved_asmt_rec.extension_possible, p_extension_possible),
            DECODE(p_additional_information, null, l_saved_asmt_rec.additional_information, p_additional_information),
            DECODE(p_work_type_id, null, l_saved_asmt_rec.work_type_id, p_work_type_id),
            DECODE(p_expense_owner, null, l_saved_asmt_rec.expense_owner, p_expense_owner),
            DECODE(p_expense_limit, null, l_saved_asmt_rec.expense_limit, p_expense_limit),
            DECODE(p_fcst_tp_amount_type, null, l_saved_asmt_rec.fcst_tp_amount_type, p_fcst_tp_amount_type),
            DECODE(p_expenditure_type_class, null, l_saved_asmt_rec.expenditure_type_class, p_expenditure_type_class),
            DECODE(p_expenditure_type, null, l_saved_asmt_rec.expenditure_type, p_expenditure_type),
            DECODE(p_location_id, null, l_saved_asmt_rec.location_id, p_location_id),
            DECODE(p_staffing_owner_person_id, null, l_saved_asmt_rec.staffing_owner_person_id, p_staffing_owner_person_id)
     INTO   l_updated_asmt_rec.assignment_id,
            l_updated_asmt_rec.assignment_name,
            l_updated_asmt_rec.staffing_priority_code,
            l_updated_asmt_rec.description,
            l_updated_asmt_rec.extension_possible,
            l_updated_asmt_rec.additional_information,
            l_updated_asmt_rec.work_type_id,
            l_updated_asmt_rec.expense_owner,
            l_updated_asmt_rec.expense_limit,
            l_updated_asmt_rec.fcst_tp_amount_type,
            l_updated_asmt_rec.expenditure_type_class,
            l_updated_asmt_rec.expenditure_type,
            l_updated_asmt_rec.location_id,
            l_updated_asmt_rec.staffing_owner_person_id
     FROM DUAL;
  END IF;

  ------------------------------------------------------------------------------
  -- Populate Table for the updated assignment items
  ------------------------------------------------------------------------------

  -- Compare Additional Staffing Information
  l_changed_item := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('PA_CHANGED_ITEMS', 'ADDITIONAL_STAFF_INFO');
  IF (NVL(l_asmt_history_rec.additional_information,-1) <> NVL(l_updated_asmt_rec.additional_information,-1)) THEN
     INSERT INTO pa_asgmt_changed_items (assignment_id, changed_item_name, new_value, old_value)
     VALUES (p_assignment_id,l_changed_item,l_updated_asmt_rec.additional_information,l_asmt_history_rec.additional_information);
  END IF;

  -- Compare Expenditure Type
  l_changed_item := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('PA_CHANGED_ITEMS', 'ASMT_EXP_TYPE');
  IF (NVL(l_asmt_history_rec.expenditure_type,-1) <> NVL(l_updated_asmt_rec.expenditure_type,-1)) THEN
     INSERT INTO pa_asgmt_changed_items (assignment_id, changed_item_name, new_value, old_value)
     VALUES (p_assignment_id, l_changed_item, l_updated_asmt_rec.expenditure_type, l_asmt_history_rec.expenditure_type);
  END IF;

  -- Compare Assignment Name
  l_changed_item := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('PA_CHANGED_ITEMS', 'ASSIGNMENT_NAME');
  IF (NVL(l_asmt_history_rec.assignment_name,-1) <> NVL(l_updated_asmt_rec.assignment_name,-1)) THEN
     INSERT INTO pa_asgmt_changed_items (assignment_id, changed_item_name, new_value, old_value)
     VALUES (p_assignment_id, l_changed_item, l_updated_asmt_rec.assignment_name, l_asmt_history_rec.assignment_name);
  END IF;

  -- Compare Description
  l_changed_item := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('PA_CHANGED_ITEMS', 'DESCRIPTION');
  IF (NVL(l_asmt_history_rec.description,-1) <> NVL(l_updated_asmt_rec.description,-1)) THEN
     INSERT INTO pa_asgmt_changed_items (assignment_id, changed_item_name, new_value, old_value)
     VALUES (p_assignment_id, l_changed_item, l_updated_asmt_rec.description, l_asmt_history_rec.description);
  END IF;

  -- Compare Expense Limit
  l_changed_item := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('PA_CHANGED_ITEMS', 'EXPENSE_LIMIT');
  IF (NVL(l_asmt_history_rec.expense_limit,-1) <> NVL(l_updated_asmt_rec.expense_limit,-1)) THEN
     INSERT INTO pa_asgmt_changed_items (assignment_id, changed_item_name, new_value, old_value)
     VALUES (p_assignment_id, l_changed_item, to_char(l_updated_asmt_rec.expense_limit),
             to_char(l_asmt_history_rec.expense_limit));
  END IF;

  -- Compare Expense Owner
  l_changed_item := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('PA_CHANGED_ITEMS', 'EXPENSE_OWNER');
  IF (NVL(l_asmt_history_rec.expense_owner,-1) <> NVL(l_updated_asmt_rec.expense_owner,-1)) THEN
     l_new_value := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('EXPENSE_OWNER_TYPE', l_updated_asmt_rec.expense_owner);
     l_old_value := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('EXPENSE_OWNER_TYPE', l_asmt_history_rec.expense_owner);

     INSERT INTO pa_asgmt_changed_items (assignment_id, changed_item_name, new_value, old_value)
     VALUES (p_assignment_id, l_changed_item, l_new_value, l_old_value);
  END IF;

  -- Compare Extension Possible
  l_changed_item := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('PA_CHANGED_ITEMS', 'EXTENSION_POSSIBLE');
  IF (NVL(l_asmt_history_rec.extension_possible,-1) <> NVL(l_updated_asmt_rec.extension_possible,-1)) THEN
     INSERT INTO pa_asgmt_changed_items (assignment_id, changed_item_name, new_value, old_value)
     VALUES (p_assignment_id, l_changed_item, l_updated_asmt_rec.extension_possible, l_asmt_history_rec.extension_possible);
  END IF;

  -- Compare Location
  l_changed_item := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('PA_CHANGED_ITEMS', 'LOCATION');
  IF (NVL(l_asmt_history_rec.location_id,-1) <> NVL(l_updated_asmt_rec.location_id,-1)) THEN
     FOR c2 IN get_locations(l_asmt_history_rec.location_id, l_updated_asmt_rec.location_id) LOOP
        IF c2.location_id = l_updated_asmt_rec.location_id THEN
           l_new_city         := c2.city;
           l_new_region       := c2.region;
           l_new_country_code := c2.country_code;
        ELSIF c2.location_id = l_asmt_history_rec.location_id THEN
           l_old_city         := c2.city;
           l_old_region       := c2.region;
           l_old_country_code := c2.country_code;
        END IF;
     END LOOP;

     INSERT INTO pa_asgmt_changed_items (assignment_id, changed_item_name, new_value, old_value)
     VALUES (p_assignment_id, l_changed_item, l_new_city || ', ' || l_new_region || ', ' || l_new_country_code,
             l_old_city||', ' || l_old_region || ', ' || l_old_country_code);
  END IF;

  -- Compare Staffing Priority
  l_changed_item := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('PA_CHANGED_ITEMS', 'STAFFING_PRIORITY');
  IF (NVL(l_asmt_history_rec.staffing_priority_code,-1) <> NVL(l_updated_asmt_rec.staffing_priority_code,-1)) THEN
     l_new_value := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('STAFFING_PRIORITY_CODE', l_updated_asmt_rec.staffing_priority_code);
     l_old_value := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('STAFFING_PRIORITY_CODE', l_asmt_history_rec.staffing_priority_code);

     INSERT INTO pa_asgmt_changed_items (assignment_id, changed_item_name, new_value, old_value)
     VALUES (p_assignment_id, l_changed_item, l_new_value, l_old_value);
  END IF;

  -- Compare project Subteam
  l_changed_item := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('PA_CHANGED_ITEMS', 'SUB_TEAM');

  -- get project_subteam_id from pa_project_subteam_parties
  OPEN get_project_subteam_id;
  FETCH get_project_subteam_id INTO l_project_subteam_id;
  IF get_project_subteam_id%NOTFOUND THEN
     l_project_subteam_id := NULL;
  END IF;
  CLOSE get_project_subteam_id;

  -- get project_subteam_id from pa_assignments_history, it history table doesn't have a record
  -- for this assignment, pass current project_subteam_id.
  OPEN get_his_project_subteam_id;
  FETCH get_his_project_subteam_id INTO l_his_project_subteam_id;
  IF get_his_project_subteam_id%NOTFOUND THEN
     l_his_project_subteam_id := l_project_subteam_id;
  END IF;
  CLOSE get_his_project_subteam_id;

  IF (NVL(l_project_subteam_id,-1) <> NVL(l_his_project_subteam_id,-1)) THEN
     FOR c2 IN get_project_subteam_names(l_project_subteam_id, l_his_project_subteam_id) LOOP
        IF c2.project_subteam_id = l_project_subteam_id THEN
           l_new_subteam_name := c2.name;
        ELSIF c2.project_subteam_id = l_his_project_subteam_id THEN
           l_old_subteam_name := c2.name;
        END IF;
     END LOOP;

     INSERT INTO pa_asgmt_changed_items (assignment_id, changed_item_name, new_value, old_value)
     VALUES (p_assignment_id, l_changed_item, l_new_subteam_name, l_old_subteam_name);
  END IF;

  -- Compare Staffing Owner
  l_changed_item := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('PA_CHANGED_ITEMS', 'STAFFING_OWNER');

  IF (NVL(l_asmt_history_rec.staffing_owner_person_id,-1) <> NVL(l_updated_asmt_rec.staffing_owner_person_id,-1)) THEN
     -- If p_staffing_owner_person_id=null and p_staffing_owner_name<>null(when user just type name instead of
     -- using LOV in Mass Update page), l_updated_asmt_rec.staffing_owner_person_id won't have the latest
     -- value. Because p_staffing_owner_person_id=null, we can get the latest value from p_staffing_owner_name
     IF p_staffing_owner_name IS NOT NULL THEN
        l_new_value := p_staffing_owner_name;
     ELSE
        pa_resource_utils.get_person_name (p_person_id      => l_updated_asmt_rec.staffing_owner_person_id,
                                           x_person_name    => l_new_value,
                                           x_return_status  => l_return_Status);
     END IF;

     pa_resource_utils.get_person_name (p_person_id      => l_asmt_history_rec.staffing_owner_person_id,
                                        x_person_name    => l_old_value,
                                        x_return_status  => l_return_Status);

     INSERT INTO pa_asgmt_changed_items (assignment_id, changed_item_name, new_value, old_value)
     VALUES (p_assignment_id, l_changed_item, l_new_value, l_old_value);
  END IF;

  -- Compare TP Amount Type
  l_changed_item := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('PA_CHANGED_ITEMS', 'TRANSFER_AMT_TYPE');

  IF (NVL(l_asmt_history_rec.fcst_tp_amount_type,-1) <> NVL(l_updated_asmt_rec.fcst_tp_amount_type,-1)) THEN
     l_new_value := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('TP_AMOUNT_TYPE', l_updated_asmt_rec.fcst_tp_amount_type);
     l_old_value := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('TP_AMOUNT_TYPE', l_asmt_history_rec.fcst_tp_amount_type);

     INSERT INTO pa_asgmt_changed_items (assignment_id, changed_item_name, new_value, old_value)
     VALUES (p_assignment_id, l_changed_item, l_new_value, l_old_value);
  END IF;

  -- Compare Work Type
  l_changed_item := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('PA_CHANGED_ITEMS', 'WORK_TYPE');

  IF (NVL(l_asmt_history_rec.work_type_id,-1) <> NVL(l_updated_asmt_rec.work_type_id,-1)) THEN
     FOR c2 IN get_work_type_names(l_asmt_history_rec.work_type_id, l_updated_asmt_rec.work_type_id) LOOP
        IF c2.work_type_id = l_updated_asmt_rec.work_type_id THEN
           l_new_work_type := c2.name;
        ELSIF c2.work_type_id = l_asmt_history_rec.work_type_id THEN
           l_old_work_type := c2.name;
        END IF;
     END LOOP;

     INSERT INTO pa_asgmt_changed_items (assignment_id, changed_item_name, new_value, old_value)
     VALUES (p_assignment_id, l_changed_item, l_new_work_type, l_old_work_type);
  END IF;

  -- Compare Transfer Price Currency Override
  l_changed_item := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('PA_CHANGED_ITEMS', 'TP_CURRENCY_OVERRIDE');

  IF (NVL(l_asmt_history_rec.tp_currency_override,-1) <> NVL(l_updated_asmt_rec.tp_currency_override,-1)) THEN
     INSERT INTO pa_asgmt_changed_items (assignment_id, changed_item_name, new_value, old_value)
     VALUES (p_assignment_id, l_changed_item, l_updated_asmt_rec.tp_currency_override,
             l_asmt_history_rec.tp_currency_override);
  END IF;

  -- Compare Transfer Price Rate Override
  l_changed_item := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('PA_CHANGED_ITEMS', 'TP_RATE_OVERRIDE');

  IF (NVL(l_asmt_history_rec.tp_rate_override,-1) <> NVL(l_updated_asmt_rec.tp_rate_override,-1)) THEN
     INSERT INTO pa_asgmt_changed_items (assignment_id, changed_item_name, new_value, old_value)
     VALUES (p_assignment_id, l_changed_item, to_char(l_updated_asmt_rec.tp_rate_override),
             to_char(l_asmt_history_rec.tp_rate_override));
  END IF;

  -- Compare Transfer Price Basis Override
  l_changed_item := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('PA_CHANGED_ITEMS', 'TP_CALC_BASE_CODE_OVERRIDE');

  IF (NVL(l_asmt_history_rec.tp_calc_base_code_override,-1) <> NVL(l_updated_asmt_rec.tp_calc_base_code_override,-1)) THEN
     INSERT INTO pa_asgmt_changed_items (assignment_id, changed_item_name, new_value, old_value)
     VALUES (p_assignment_id, l_changed_item, l_updated_asmt_rec.tp_calc_base_code_override,
             l_asmt_history_rec.tp_calc_base_code_override);
  END IF;

  -- Compare Transfer Price Apply % Override
  l_changed_item := PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('PA_CHANGED_ITEMS', 'TP_PERCENT_APPLIED_OVERRIDE');

  IF (NVL(l_asmt_history_rec.tp_percent_applied_override,-1) <> NVL(l_updated_asmt_rec.tp_percent_applied_override,-1)) THEN
     INSERT INTO pa_asgmt_changed_items (assignment_id, changed_item_name, new_value, old_value)
     VALUES (p_assignment_id, l_changed_item, to_char(l_updated_asmt_rec.tp_percent_applied_override),
             to_char(l_asmt_history_rec.tp_percent_applied_override));
  END IF;


  ---------------------------------------------------------------------------
  -- Populate Table for the updated schedule items
  ---------------------------------------------------------------------------
  -- get change_id just to check, it will pass -1 if the history table has no record for this asmt
  l_change_id := PA_ASSIGNMENT_APPROVAL_PVT.Get_Change_Id (p_assignment_id);

  PA_SCHEDULE_PVT.update_asgmt_changed_items_tab (
          p_assignment_id             => p_assignment_id
         ,p_populate_mode             => p_populate_mode
         ,p_change_id                 => l_change_id
         ,p_exception_type_code       => p_exception_type_code
         ,p_start_date                => p_start_date
         ,p_end_date                  => p_end_date
         ,p_requirement_status_code   => p_requirement_status_code
         ,p_assignment_status_code    => p_assignment_status_code
         ,p_start_date_tbl            => p_start_date_tbl
         ,p_end_date_tbl              => p_end_date_tbl
         ,p_monday_hours_tbl          => p_monday_hours_tbl
         ,p_tuesday_hours_tbl         => p_tuesday_hours_tbl
         ,p_wednesday_hours_tbl       => p_wednesday_hours_tbl
         ,p_thursday_hours_tbl        => p_thursday_hours_tbl
         ,p_friday_hours_tbl          => p_friday_hours_tbl
         ,p_saturday_hours_tbl        => p_saturday_hours_tbl
         ,p_sunday_hours_tbl          => p_sunday_hours_tbl
         ,p_non_working_day_flag      => p_non_working_day_flag
         ,p_change_hours_type_code    => p_change_hours_type_code
         ,p_hrs_per_day               => p_hrs_per_day
         ,p_calendar_percent          => p_calendar_percent
         ,p_change_calendar_type_code => p_change_calendar_type_code
         ,p_change_calendar_name      => p_change_calendar_name
         ,p_change_calendar_id        => p_change_calendar_id
         ,p_duration_shift_type_code  => p_duration_shift_type_code
         ,p_duration_shift_unit_code  => p_duration_shift_unit_code
         ,p_number_of_shift           => p_number_of_shift
         ,x_return_status             => l_return_status );


  ---------------------------------------------------------------------------
  -- Set out parameters
  ---------------------------------------------------------------------------
  x_msg_count :=  FND_MSG_PUB.Count_Msg;

  -- If g_error_exists is TRUE then set the x_return_status to 'E'
  IF x_msg_count > 0  THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

     IF x_msg_count = 1 THEN
        pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                             ,p_msg_index     => 1
                                             ,p_data          => x_msg_data
                                             ,p_msg_index_out => l_msg_index_out );
     END IF;
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  EXCEPTION
     WHEN OTHERS THEN
         -- Set the exception Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PUB.Populate_Changed_Items_Table'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;  -- This is optional depending on the needs

END Populate_Changed_Items_Table;




PROCEDURE Change_Assignment_Status
        (
          p_record_version_number         IN Number          ,
          p_assignment_id                 IN Number          ,
          p_assignment_type               IN Varchar2        ,
          p_start_date                    IN date            ,
          p_end_date                      IN date            ,
          p_assignment_status_code        IN Varchar2        := FND_API.G_MISS_CHAR,
          p_init_msg_list                 IN VARCHAR2        :=  FND_API.G_FALSE,
          p_commit                        IN VARCHAR2        :=  FND_API.G_FALSE,
          x_return_status                 OUT  NOCOPY Varchar2      , --File.Sql.39 bug 4440895
          x_msg_count                     OUT  NOCOPY NUMBER        , --File.Sql.39 bug 4440895
          x_msg_data                      OUT  NOCOPY Varchar2 ) --File.Sql.39 bug 4440895
IS
 l_msg_index_out               NUMBER;
 l_assignment_row_id           ROWID;
 l_assignment_number           pa_project_assignments.assignment_number%TYPE;
 l_project_id                  pa_project_assignments.project_id%TYPE;
 l_calendar_id                 pa_project_assignments.calendar_id%TYPE;
 l_asgn_end_date               pa_project_assignments.end_date%TYPE;
 l_asgn_start_date             pa_project_assignments.start_date%TYPE;
 l_source_assignment_id        pa_project_assignments.source_assignment_id%TYPE;
 l_record_version_number       pa_project_assignments.record_version_number%TYPE;
 l_asgn_status_canceled_flag   VARCHAR2(1);
 l_req_status_canceled_flag    VARCHAR2(1);
 l_full_cancel_flag            VARCHAR2(1);
 l_start_req_status_code       pa_project_statuses.project_status_code%TYPE;
 l_new_assignment_flag         VARCHAR2(1);
 l_change_id                   NUMBER;
 l_apprvl_status_code          pa_project_statuses.project_status_code%TYPE;
 l_save_to_hist                VARCHAR2(1);
 l_new_assignment_id           NUMBER;
 l_assignment_type             pa_project_assignments.assignment_type%TYPE;
 l_req_start_date              pa_project_assignments.start_date%TYPE;
 l_project_party_id            pa_project_assignments.project_party_id%TYPE;
 l_error_message_code          fnd_new_messages.message_name%TYPE;
 l_resource_id                 pa_project_assignments.resource_id%TYPE;
 l_conflict_group_id           NUMBER;
 l_overcommitment_flag         VARCHAR2(1);
 l_action_set_id               NUMBER;
 l_return_status               VARCHAR2(1);

 l_task_assignment_id_tbl       system.pa_num_tbl_type;
 l_task_version_id_tbl                  system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_budget_version_id_tbl        system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_struct_version_id_tbl        system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_cur_role_flag                                pa_res_formats_b.role_enabled_flag%TYPE;


CURSOR check_record_version IS
SELECT ROWID, project_id, calendar_id, start_date, end_date, source_assignment_id, project_party_id, resource_id
FROM   pa_project_assignments
WHERE  assignment_id = p_assignment_id
AND    record_version_number = p_record_version_number;

CURSOR get_requirement_info IS
SELECT assignment_type, start_date
FROM   pa_project_assignments
WHERE  assignment_id = l_source_assignment_id;

CURSOR get_record_version IS
SELECT record_version_number
FROM   pa_project_assignments
WHERE  assignment_id = p_assignment_id;

-- get advertisement action set details
CURSOR get_action_set IS
SELECT action_set_id, record_version_number
  FROM pa_action_sets
 WHERE object_id = p_assignment_id
   AND object_type = 'OPEN_ASSIGNMENT'
   AND action_set_type_code = 'ADVERTISEMENT'
   AND status_code <> 'DELETED';

 CURSOR get_linked_res_asgmts IS
 SELECT resource_assignment_id, wbs_element_version_id, budget_version_id, project_structure_version_id
 FROM
 (
         (SELECT ra.resource_assignment_id, ra.wbs_element_version_id, bv.budget_version_id, bv.project_structure_version_id
          FROM  PA_RESOURCE_ASSIGNMENTS ra
               ,PA_BUDGET_VERSIONS bv
               ,PA_PROJ_ELEM_VER_STRUCTURE evs
                 --  ,PA_PROJECT_ASSIGNMENTS pa -- 5110598 Removed PA_PROJECT_ASSIGNMENTS table usage
          WHERE ra.project_id = bv.project_id
          AND   bv.project_id = evs.project_id
          AND   ra.budget_version_id = bv.budget_version_id
          AND   bv.project_structure_version_id = evs.element_version_id
--        AND   ra.project_id = l_assignment_rec.project_id
--        AND   pa.assignment_id = p_assignment_id -- 5110598 Removed table usage
--        AND   ra.project_id = pa.project_id -- 5110598 Removed table usage
          AND   ra.project_assignment_id = p_assignment_id
          AND   evs.status_code = 'STRUCTURE_WORKING')
   UNION ALL
         (SELECT ra.resource_assignment_id, ra.wbs_element_version_id, bv.budget_version_id, bv.project_structure_version_id
          FROM  PA_RESOURCE_ASSIGNMENTS ra
               ,PA_BUDGET_VERSIONS bv
               ,PA_PROJ_ELEM_VER_STRUCTURE evs
                   ,PA_PROJ_WORKPLAN_ATTR pwa
--                 ,PA_PROJECT_ASSIGNMENTS pa -- 5110598 Removed PA_PROJECT_ASSIGNMENTS table usage
          WHERE pwa.wp_enable_Version_flag = 'N'
          AND   pwa.project_id = ra.project_id
          AND   pwa.proj_element_id = evs.proj_element_id
          AND   ra.project_id = bv.project_id
          AND   bv.project_id = evs.project_id
          AND   ra.budget_version_id = bv.budget_version_id
          AND   bv.project_structure_version_id = evs.element_version_id
--        AND   ra.project_id = l_assignment_rec.project_id
--        AND   pa.assignment_id = p_assignment_id -- 5110598 Removed table usage
--        AND   ra.project_id = pa.project_id -- 5110598 Removed table usage
          AND   ra.project_assignment_id = p_assignment_id)
 )
 ORDER BY budget_version_id, project_structure_version_id;

 CURSOR get_res_mand_attributes IS
 SELECT rf.ROLE_ENABLED_FLAG
 FROM   pa_res_formats_b rf,
        pa_resource_list_members rlm,
                pa_project_assignments pa
 WHERE  pa.assignment_id = p_assignment_id
 AND    pa.resource_list_member_id IS NOT NULL
 AND    rlm.resource_list_member_id = pa.resource_list_member_id
 AND    rlm.res_format_id = rf.res_format_id;

BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ASSIGNMENT_APPROVAL_PUB.Cancel_Assignment');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Cancel_Assignment.begin'
                     ,x_msg         => 'Beginning of Cancel_Assignment'
                     ,x_log_level   => 5);
  END IF;

  -- Initialize the error flag
  PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_FALSE;

  --  Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT   ASG_PUB_CHANGE_STATUS;
  END IF;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  OPEN check_record_version;

  FETCH check_record_version INTO l_assignment_row_id, l_project_id, l_calendar_id,
                                  l_asgn_start_date, l_asgn_end_date, l_source_assignment_id,
                                  l_project_party_id, l_resource_id;

  IF check_record_version%NOTFOUND THEN

    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_XC_RECORD_CHANGED');
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;

  ELSE

    l_record_version_number := p_record_version_number;

    --Change Status in the Schedule tables
/*
    IF p_assignment_type = 'OPEN_ASSIGNMENT' THEN
      l_save_to_hist := FND_API.G_FALSE;
    ELSE
      l_save_to_hist := FND_API.G_TRUE;
    END IF;
*/


    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Cancel_Assignment'
                     ,x_msg         => 'calling PA_SCHEDULE_PUB.Change_Status'
                     ,x_log_level   => 5);
    END IF;
    PA_SCHEDULE_PUB.Change_Status(p_record_version_number => l_record_version_number,
                                p_project_id => l_project_id,
                                p_calendar_id =>l_calendar_id,
                                p_assignment_id => p_assignment_id,
                                p_assignment_type => p_assignment_type,
                                p_status_type => null,
                                p_start_date => p_start_date,
                                p_end_date => p_end_date,
                                p_assignment_status_code => p_assignment_status_code,
                                p_asgn_start_date => l_asgn_start_date,
                                p_asgn_end_date => l_asgn_end_date,
                             --   p_save_to_hist  => l_save_to_hist,
                                x_return_status => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data);
    -- dbms_output.put_line('status after 1st change_status'||x_return_status);

    --
    --Find out if full duration cancel
    --
    IF p_assignment_type = 'OPEN_ASSIGNMENT' THEN
      l_req_status_canceled_flag:=
                       PA_ASSIGNMENT_UTILS.Is_Open_Asgmt_Cancelled(p_status_code=>p_assignment_status_code
                                                                     ,p_status_type => 'OPEN_ASGMT');
      IF (l_req_status_canceled_flag = 'Y') AND (p_start_date = l_asgn_start_date)
          AND (p_end_date = l_asgn_end_date) THEN

        l_full_cancel_flag := 'Y';


--commenting out: since no partial cancellation
/*
      ELSIF (l_req_status_canceled_flag = 'Y') THEN

        l_full_cancel_flag := PA_SCHEDULE_UTILS.check_input_system_status(p_assignment_id => p_assignment_id
                                                                         ,p_status_type   => 'OPEN_ASGMT'
                                                                       ,p_in_system_status_code => 'OPEN_ASGMT_CANCEL');
*/
      END IF;

    ELSE
      l_asgn_status_canceled_flag:=
                       PA_ASSIGNMENT_UTILS.Is_Staffed_Asgmt_Cancelled(p_status_code=>p_assignment_status_code
                                                                     ,p_status_type => 'STAFFED_ASGMT');
      IF (l_asgn_status_canceled_flag = 'Y') AND (p_start_date = l_asgn_start_date)
         AND (p_end_date = l_asgn_end_date) THEN
        l_full_cancel_flag := 'Y';

--commenting out: since no partial cancellation
/*
      ELSIF (l_asgn_status_canceled_flag = 'Y') THEN

        l_full_cancel_flag := PA_SCHEDULE_UTILS.check_input_system_status(p_assignment_id => p_assignment_id
                                                                         ,p_status_type   => 'STAFFED_ASGMT'
                                                                    ,p_in_system_status_code => 'STAFFED_ASGMT_CANCEL');
*/
      END IF;
    END IF;
    --dbms_output.put_line('l_full_cancel'||l_full_cancel_flag);

    -- If this is an open requirement, close the Advertisement Action Set
    IF p_assignment_type = 'OPEN_ASSIGNMENT' THEN

       -- dbms_output.put_line('declining candidates');
       IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Cancel_Assignment'
                          ,x_msg         => 'Calling PA_CANDIDATE_PUB.Decline_Candidates'
                          ,x_log_level   => 5);
       END IF;

       -- Decline all active candidates in the requirement
       PA_CANDIDATE_PUB.Decline_Candidates(
              p_assignment_id      => p_assignment_id,
              x_return_status      => x_return_status,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data);

       OPEN get_action_set;
        FETCH get_action_set INTO l_action_set_id, l_record_version_number;
       CLOSE get_action_set;

        --dbms_output.put_line('before PA_ACTION_SETS_PUB.Update_Action_Set');

    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN
    PA_DEBUG.write_log (x_module    => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Cancel_Assignment'
                     ,x_msg         => 'calling PA_ACTION_SETS_PUB.Update_Action_Set'
                     ,x_log_level   => 5);
    END IF;

        PA_ACTION_SETS_PUB.Update_Action_Set(
                 p_action_set_id         => l_action_set_id
                ,p_object_id             => p_assignment_id
                ,p_object_type           => 'OPEN_ASSIGNMENT'
                ,p_action_set_type_code  => 'ADVERTISEMENT'
                ,p_status_code           => 'CLOSED'
                ,p_record_version_number => l_record_version_number
                ,p_commit                => p_commit
                ,p_validate_only         => FND_API.G_FALSE
                ,p_init_msg_list         => FND_API.G_FALSE
                ,x_return_status         => x_return_status
                ,x_msg_count             => x_msg_count
                ,x_msg_data              => x_msg_data);


        --dbms_output.put_line('after PA_ACTION_SETS_PUB.Update_Action_Set');

      END IF;


    --IF full duration cancel and assignment
    IF (l_full_cancel_flag = 'Y') AND (p_assignment_type <> 'OPEN_ASSIGNMENT') THEN

      --IF pending approval, then abort
      IF PA_ASGMT_WFSTD.Is_Approval_Pending (p_assignment_id => p_assignment_id) = 'Y' THEN
        --dbms_output.put_line('abort assignment');

        PA_ASSIGNMENT_APPROVAL_PVT.Abort_Assignment_Approval(p_assignment_id => p_assignment_id
                                                            ,p_project_id    => l_project_id
                                                            ,x_return_status => x_return_status);
        --dbms_output.put_line('abort assignment result:'||x_return_status);
      END IF;

      --dbms_output.put_line('before PA_PROJECT_PARTIES_PVT.Delete_Project_Party');

      --
      --Delete the Project Party Role
      --
      IF l_project_party_id IS NOT NULL THEN
        PA_PROJECT_PARTIES_PVT.Delete_Project_Party(
                                                   p_commit => 'F',
                                                   p_validate_only => 'F',
                                                   p_project_party_id => l_project_party_id,
                                                   p_calling_module => 'ASSIGNMENT',
                                                   p_record_version_number => null,
                                                   x_return_status => x_return_status,
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data => x_msg_data);
      END IF;

      --dbms_output.put_line('after PA_PROJECT_PARTIES_PVT.Delete_Project_Party');
      --
      --Reverse the Candidate status for the resource assigned
      --
      PA_CANDIDATE_UTILS.Reverse_Candidate_Status (p_assignment_id  => l_source_assignment_id
                                                  ,p_resource_id        => l_resource_id
                                                  ,x_return_status      => x_return_status
                                                  ,x_error_message_code => l_error_message_code);

      --dbms_output.put_line('after PA_CANDIDATE_UTILS.Reverse_Candidate_Status ');


      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name       => l_error_message_code);
      END IF;

      --
      --Reopen requirement when necessary
      --
      --If source requirement exist, then reopen it.
      --This is under the assumption that only way for assignment to have source_assignment_id is from a requirement
      --
      IF l_source_assignment_id IS NOT NULL THEN

        OPEN get_requirement_info;
        FETCH get_requirement_info INTO l_assignment_type, l_req_start_date;

        IF get_requirement_info%FOUND THEN

          IF l_assignment_type = 'OPEN_ASSIGNMENT' THEN

            --dbms_output.put_line('Reopen requirement now');


            --create a new requirement for canceled assignment
            PA_ASSIGNMENTS_PUB.Copy_Team_Role    (p_assignment_id        => l_source_assignment_id
                                                 ,p_asgn_creation_mode   => 'COPY'  ---Fix for Bug 6169205
                                                 ,x_new_assignment_id    => l_new_assignment_id
                                                 ,x_assignment_number    => l_assignment_number
                                                 ,x_assignment_row_id    => l_assignment_row_id
                                                 ,x_return_status        => x_return_status
                                                 ,x_msg_count            => x_msg_count
                                                 ,x_msg_data             => x_msg_data
                                                 );

                        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

                    --Need to keep the link from the new requirement to the canceled assignment
                    UPDATE pa_project_assignments
                    SET source_assignment_id = p_assignment_id
                    WHERE assignment_id = l_new_assignment_id;

                        --Copy the Candidate List from the old requirement to the new requirement
                        PA_CANDIDATE_PUB.Copy_Candidates
                                 (p_old_requirement_id  => l_source_assignment_id
                                 ,p_new_requirement_id  => l_new_assignment_id
                                 ,p_new_start_date      => l_req_start_date
                                 ,x_return_status       => x_return_status
                                 ,x_msg_count           => x_msg_count
                                 ,x_msg_data            => x_msg_data);

                ELSE
                    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                         ,p_msg_name       => 'PA_FAILED_TO_CREATE_OPEN_ASGN');
                END IF;

            --dbms_output.put_line('new requirement'||x_return_status);
          END IF; -- IF l_assignment_type = 'OPEN_ASSIGNMENT' THEN
        END IF; -- IF get_requirement_info%FOUND THEN

        CLOSE get_requirement_info;

		  --anuragag changes for bug 8763672
		 PA_CANDIDATE_PUB.Delete_Candidates(p_assignment_id => l_source_assignment_id,
     p_status_code        => NULL
	 ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data);

	 update pa_project_assignments set no_of_active_candidates=0
	 where assignment_id = l_source_assignment_id;
	 --end of anuragag changes for bug 8763672

      END IF; -- end of checking source assignment id

      --Update apprvl_status_code and send notification if necessary
      l_new_assignment_flag := PA_ASSIGNMENT_APPROVAL_PVT.Is_New_Assignment(p_assignment_id => p_assignment_id);
      --dbms_output.put_line('new assignment flag'||l_new_assignment_flag);

      -- update the assignment approval status and send notification when the canceled assignment
      -- has ever been approved.

      PA_ASSIGNMENT_APPROVAL_PUB.Start_Assignment_Approvals( p_assignment_id       => p_assignment_id
                                                            ,p_new_assignment_flag => l_new_assignment_flag
                                                            ,p_action_code =>PA_ASSIGNMENT_APPROVAL_PUB.g_cancel_action
                                                            ,p_record_version_number => NULL
                                                            ,p_validate_only   => FND_API.G_FALSE
                                                            ,x_overcommitment_flag => l_overcommitment_flag
                                                            ,x_conflict_group_id   => l_conflict_group_id
                                                            ,x_return_status   => x_return_status
                                                            ,x_msg_count       => x_msg_count
                                                            ,x_msg_data        => x_msg_data);
      --dbms_output.put_line('start_assignment_approval'||x_return_status);

    --Else if full duration cancel, just set cancel status
    ELSIF l_full_cancel_flag = 'Y' THEN

      -- Update apprvl_status_code
      PA_ASSIGNMENT_APPROVAL_PVT.Update_Approval_Status(
                                                 P_ASSIGNMENT_ID         => p_assignment_id
                                                ,P_ACTION_CODE           => PA_ASSIGNMENT_APPROVAL_PUB.g_cancel_action
                                                ,P_RECORD_VERSION_NUMBER => NULL
                                                ,X_APPRVL_STATUS_CODE    => l_apprvl_status_code
                                                ,X_CHANGE_ID             => l_change_id
                                                ,X_RECORD_VERSION_NUMBER => l_record_version_number
                                                ,X_RETURN_STATUS         => x_return_status
                                                ,X_MSG_COUNT             => x_msg_count
                                                ,X_MSG_DATA              => x_msg_data);
    --dbms_output.put_line('update_approval_status'||x_return_status);

    END IF; -- end of check full duration cancel

    -- FP-M Development
    -- Break the link between associated task assignments
        -- and the cancelled team role
        OPEN  get_linked_res_asgmts;
        FETCH get_linked_res_asgmts
    BULK COLLECT INTO l_task_assignment_id_tbl,
                      l_task_version_id_tbl,
                                  l_budget_version_id_tbl,
                                          l_struct_version_id_tbl;
        CLOSE get_linked_res_asgmts;

    -- 1. Change project_assignment_id to NULL (-1)
    -- 2. Don't wipe out project_role_id
    -- 3. Wipe out named_role when it is not a mandatory attribute
    --    of planning resource
    OPEN  get_res_mand_attributes;
    FETCH get_res_mand_attributes INTO l_cur_role_flag;

        IF get_res_mand_attributes%FOUND AND l_cur_role_flag = 'Y' THEN
                pa_assignments_pvt.Update_Task_Assignments(
                  p_task_assignment_id_tbl      =>      l_task_assignment_id_tbl
                 ,p_task_version_id_tbl         =>  l_task_version_id_tbl
                 ,p_budget_version_id_tbl       =>  l_budget_version_id_tbl
                 ,p_struct_version_id_tbl       =>  l_struct_version_id_tbl
                 ,p_project_assignment_id       =>  -1
                 ,x_return_status           =>  l_return_status
            );
        ELSE
                pa_assignments_pvt.Update_Task_Assignments(
                  p_task_assignment_id_tbl      =>      l_task_assignment_id_tbl
                 ,p_task_version_id_tbl         =>  l_task_version_id_tbl
                 ,p_budget_version_id_tbl       =>  l_budget_version_id_tbl
                 ,p_struct_version_id_tbl       =>  l_struct_version_id_tbl
                 ,p_project_assignment_id       =>  -1
                 ,p_named_role                          =>      FND_API.G_MISS_CHAR
                 ,x_return_status           =>  l_return_status
            );
        END IF;
    CLOSE get_res_mand_attributes;

  END IF; -- end of checking record_verison_number

  CLOSE check_record_version;

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack and return its text
  --
  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


  IF x_msg_count > 0  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;


  -- Put any message text from message stack into the Message ARRAY
  --
  EXCEPTION
     WHEN OTHERS THEN
         IF p_commit = FND_API.G_TRUE THEN
           ROLLBACK TO ASG_PUB_CHANGE_STATUS;
         END IF;
         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PUB.Change_Assignment_Status'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;  -- This is optional depending on the needs

--
END Change_Assignment_Status;



--
-- Procedure            : Get_Current_Approver
-- Purpose              : Get the approver which has the current approver flag set.
-- Parameters           :
--
PROCEDURE Get_Current_Approver
        (
          p_assignment_id                 IN NUMBER          ,
          p_project_id                    IN NUMBER          ,
          p_apprvl_status_code            IN VARCHAR2        ,
          x_approver_name                 OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_user_id          NUMBER;
l_resource_id      NUMBER;
l_person_id        NUMBER;
l_item_type        pa_wf_processes.item_type%TYPE;
l_item_key         pa_wf_processes.item_key%TYPE;

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

CURSOR get_user_id IS
      SELECT fu.user_id
      FROM   pa_wf_ntf_performers pwnp,
             fnd_user       fu
      WHERE  pwnp.object_id1 = p_assignment_id
      AND    pwnp.object_id2 = p_project_id
      AND    pwnp.item_type = l_item_type
      AND    pwnp.item_key  = l_item_key
      AND    pwnp.current_approver_flag = 'Y'
      AND    pwnp.user_name = fu.user_name;

-- Added for Bug# 8296021
CURSOR get_wf_progress_flag IS
     SELECT nvl(mass_wf_in_progress_flag,'N')
     FROM pa_project_assignments
     WHERE assignment_id = p_assignment_id;

CURSOR get_user_id_mflow IS
     SELECT fu.user_id
     FROM pa_wf_ntf_performers pwnp,
          fnd_user fu
     WHERE wf_type_code = 'MASS_ASSIGNMENT_APPROVAL'
     AND object_id1 = p_assignment_id
     AND object_id2 = -1
     AND fu.user_name = pwnp.user_name
     AND (group_id, routing_order) in (SELECT max(group_id), min(routing_order)
                                      FROM pa_wf_ntf_performers
                                      WHERE wf_type_code = 'MASS_ASSIGNMENT_APPROVAL'
                                      AND object_id1 = p_assignment_id
                                      AND object_id2 = -1);

wf_progress_flag VARCHAR2(10) := 'N';
-- End of Bug# 8296021

BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ASSIGNMENT_APPROVAL_PUB.Get_Current_Approver');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Get_Current_Approver.begin'
                     ,x_msg         => 'Beginning of Get_Current_Approver'
                     ,x_log_level   => 5);
  END IF;

  --Check to see if assignment is pending approval
  IF p_apprvl_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_submitted THEN
    -- Added for Bug# 8296021
    OPEN get_wf_progress_flag;
    FETCH get_wf_progress_flag INTO wf_progress_flag;
    CLOSE get_wf_progress_flag;

    IF (wf_progress_flag = 'N') THEN
    -- End of Bug# 8296021

      --Get the maximum item key
      OPEN get_item_key;
      FETCH get_item_key INTO l_item_key, l_item_type;

      IF get_item_key%FOUND THEN

        --Get the current approver user_name
        OPEN get_user_id;
        FETCH get_user_id INTO l_user_id;
        CLOSE get_user_id;

        --Get the approver name from the user_name
        IF l_user_id IS NOT NULL THEN
          PA_COMP_PROFILE_PUB.get_user_info(p_user_id    => l_user_id
                                         ,x_person_id    => l_person_id
                                         ,x_resource_id  => l_resource_id
                                         ,x_resource_name=> x_approver_name );
        END IF;
      END IF;
      CLOSE get_item_key;
    -- Start of Bug# 8296021
    ELSIF (wf_progress_flag = 'Y') THEN
      OPEN get_user_id_mflow;
      FETCH get_user_id_mflow INTO l_user_id;
      CLOSE get_user_id_mflow;

      IF l_user_id IS NOT NULL THEN
        PA_COMP_PROFILE_PUB.get_user_info(p_user_id    => l_user_id
                                         ,x_person_id    => l_person_id
                                         ,x_resource_id  => l_resource_id
                                         ,x_resource_name=> x_approver_name);
      END IF;
    END IF; -- end for wf_progress_flag
    -- End of Bug# 8296021
  END IF; -- end of checking if assignment is pending approval

  -- Put any message text from message stack into the Message ARRAY
  --
  EXCEPTION
     WHEN OTHERS THEN
        -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PUB.Get_Current_Approver'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         RAISE;  -- This is optional depending on the needs

END Get_Current_Approver;



PROCEDURE Cancel_Assignment
        (
          p_record_version_number         IN Number          ,
          p_assignment_id                 IN Number          ,
          p_assignment_type               IN Varchar2        ,
          p_start_date                    IN date            ,
          p_end_date                      IN date            ,
          p_init_msg_list                 IN VARCHAR2        :=  FND_API.G_FALSE,
          p_commit                        IN VARCHAR2        :=  FND_API.G_FALSE,
          x_return_status                 OUT  NOCOPY Varchar2      , --File.Sql.39 bug 4440895
          x_msg_count                     OUT  NOCOPY NUMBER        , --File.Sql.39 bug 4440895
          x_msg_data                      OUT  NOCOPY Varchar2 ) --File.Sql.39 bug 4440895

IS
  l_assignment_status_code    pa_project_assignments.status_code%TYPE;
  l_msg_index_out             NUMBER;
  l_start_date                DATE;
  l_end_date                  DATE;
  l_return_status             VARCHAR2(1);
  l_error_message_code        fnd_new_messages.message_name%TYPE;
  l_project_id                NUMBER;
  l_person_id                 NUMBER;

 CURSOR get_start_end_date IS
  SELECT asgn.start_date, asgn.end_date, asgn.project_id, res.person_id
  FROM   pa_project_assignments asgn,
         pa_resources_denorm res
  WHERE  assignment_id = p_assignment_id
    AND  res.resource_id = asgn.resource_id
    AND  rownum=1;

BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ASSIGNMENT_APPROVAL_PUB.Cancel_Assignment');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.Cancel_Assignment.begin'
                     ,x_msg         => 'Beginning of Cancel_Assignment'
                     ,x_log_level   => 5);
  END IF;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Assignment cannot be deleted if project transactions
  -- are associated with it
  OPEN get_start_end_date;
  FETCH get_start_end_date INTO l_start_date, l_end_date, l_project_id, l_person_id;
  CLOSE get_start_end_date;

  -- Should perform EI validation only for assignments
  IF p_assignment_type <> 'OPEN_ASSIGNMENT' THEN
    -- Bug 2797890: Added p_project_id, p_person_id parameters
    PA_TRANS_UTILS.Check_Txn_Exists(  p_assignment_id   => p_assignment_id
                                     ,p_project_id      => l_project_id
                                     ,p_person_id       => l_person_id
                                     ,p_calling_mode    => 'CANCEL'
                                     ,p_old_start_date  => null
                                     ,p_old_end_date    => null
                                     ,p_new_start_date  => l_start_date
                                     ,p_new_end_date    => l_end_date
                                     ,x_error_message_code => l_error_message_code
                                     ,x_return_status      => l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => l_error_message_code);
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE; --bug#8240018
    END IF;
    l_return_status := NULL;
  END IF;

  --Bug#8240018
  -- proceed with the code flow only when there is no error returned
 IF  PA_ASSIGNMENTS_PUB.g_error_exists <>  FND_API.G_TRUE THEN

  --Get Profile Default Status
  IF p_assignment_type = 'OPEN_ASSIGNMENT' THEN
    FND_PROFILE.Get('PA_DEF_CANCELED_REQMT_STATUS',l_assignment_status_code);
  ELSE
    FND_PROFILE.Get('PA_DEF_CANCELED_ASGMT_STATUS',l_assignment_status_code);
  END IF;

  IF l_assignment_status_code IS NOT NULL THEN

    --call Change_Assignment_Status
    PA_ASSIGNMENT_APPROVAL_PUB.Change_Assignment_Status
        (
          p_record_version_number     =>  p_record_version_number
          ,p_assignment_id             =>  p_assignment_id
          ,p_assignment_type           =>  p_assignment_type
          ,p_start_date                =>  p_start_date
          ,p_end_date                  =>  p_end_date
          ,p_assignment_status_code    =>  l_assignment_status_code
          ,x_return_status             =>  x_return_status
          ,x_msg_count                 =>  x_msg_count
          ,x_msg_data                  =>  x_msg_data   );

  ELSE
     PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                           ,p_msg_name => 'PA_START_STATUS_NOT_DEFINED');

  END IF;

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack and return its text
  --
  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


  IF x_msg_count > 0  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;
  END IF;  --end of if loop for Bug#8240018
  EXCEPTION
     WHEN OTHERS THEN
         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PUB.Cancel_Assignment'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;  -- This is optional depending on the needs

END Cancel_Assignment;

/* --------------------------Begin  Mass Assignment Approval Code-------------------------------------*/
/* Added a new parameter p_overriding_authority_flag in the procedure below for the bug 3213509 */
--BEGIN FORWARD DECLARATIONS

PROCEDURE validate_approver_name_id
    ( p_project_id                  IN    NUMBER
     ,p_assignment_id_tbl           IN    SYSTEM.pa_num_tbl_type      := prm_empty_num_tbl
     ,p_approver1_id_tbl            IN    SYSTEM.pa_num_tbl_type      := prm_empty_num_tbl
     ,p_approver1_name_tbl          IN    SYSTEM.pa_varchar2_240_tbl_type  := prm_empty_varchar2_240_tbl
     ,p_approver2_id_tbl            IN    SYSTEM.pa_num_tbl_type           := prm_empty_num_tbl
     ,p_approver2_name_tbl          IN    SYSTEM.pa_varchar2_240_tbl_type  := prm_empty_varchar2_240_tbl
     ,p_submitter_user_id           IN    NUMBER
     ,p_group_id                    IN    NUMBER
     ,p_api_version                 IN    NUMBER                       := 1.0
     ,p_init_msg_list               IN    VARCHAR2                     := FND_API.G_TRUE
     ,p_max_msg_count               IN    NUMBER                       := FND_API.G_MISS_NUM
     ,p_commit                      IN    VARCHAR2                     := FND_API.G_FALSE
     ,p_validate_only               IN    VARCHAR2                     := FND_API.G_TRUE
     ,p_overriding_authority_flag   IN    VARCHAR2                         := 'N'
     ,x_assignment_id_tbl           OUT   NOCOPY SYSTEM.pa_num_tbl_type
     ,x_approver1_id_tbl            OUT   NOCOPY SYSTEM.pa_num_tbl_type
     ,x_approver2_id_tbl            OUT   NOCOPY SYSTEM.pa_num_tbl_type
     ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                   OUT   NOCOPY NUMBER         --File.Sql.39 bug 4440895
     ,x_msg_data                    OUT   NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
);

--END FORWARD DECLARATIONS



---------------------------------------------------------------
--This API is called from the Mass Submit for approval pages.
--The IN parameters are all parameters needed to call
--the mass transaction API. This API is called online
--and so there are no validations, it calls the mass
--transaction API by passing all the IN variables
---------------------------------------------------------------
PROCEDURE mass_submit_for_asgmt_aprvl
           (p_mode                        IN    VARCHAR2
           ,p_action                      IN    VARCHAR2
           ,p_resource_id_tbl             IN    SYSTEM.pa_num_tbl_type                                 := prm_empty_num_tbl
           ,p_assignment_id_tbl           IN    SYSTEM.pa_num_tbl_type                                 := prm_empty_num_tbl
           ,p_assignment_name             IN    pa_project_assignments.assignment_name%TYPE             := FND_API.G_MISS_CHAR
           ,p_assignment_type             IN    pa_project_assignments.assignment_type%TYPE             := FND_API.G_MISS_CHAR
            ,p_status_code                IN    pa_project_assignments.status_code%TYPE                 := FND_API.G_MISS_CHAR
            ,p_multiple_status_flag       IN    pa_project_assignments.multiple_status_flag%TYPE        := FND_API.G_MISS_CHAR
            ,p_staffing_priority_code     IN    pa_project_assignments.staffing_priority_code%TYPE      := FND_API.G_MISS_CHAR
            ,p_project_id                 IN    pa_project_assignments.project_id%TYPE                  := FND_API.G_MISS_NUM
            ,p_project_role_id            IN    pa_project_assignments.project_role_id%TYPE             := FND_API.G_MISS_NUM
            ,p_role_list_id               IN    pa_role_lists.role_list_id%TYPE                         := FND_API.G_MISS_NUM
            ,p_project_subteam_id         IN    pa_project_subteams.project_subteam_id%TYPE             := FND_API.G_MISS_NUM
           ,p_description                 IN    pa_project_assignments.description%TYPE                 := FND_API.G_MISS_CHAR
           ,p_append_description_flag     IN    VARCHAR2                                                := 'N'
           ,p_start_date                  IN    pa_project_assignments.start_date%TYPE                  := FND_API.G_MISS_DATE
           ,p_end_date                    IN    pa_project_assignments.end_date%TYPE                    := FND_API.G_MISS_DATE
           ,p_extension_possible          IN    pa_project_assignments.extension_possible%TYPE          := FND_API.G_MISS_CHAR
           ,p_min_resource_job_level      IN    pa_project_assignments.min_resource_job_level%TYPE      := FND_API.G_MISS_NUM
           ,p_max_resource_job_level      IN    pa_project_assignments.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
           ,p_additional_information      IN    pa_project_assignments.additional_information%TYPE      := FND_API.G_MISS_CHAR
           ,p_append_information_flag     IN    VARCHAR2                                                := 'N'
           ,p_location_id                 IN    pa_project_assignments.location_id%TYPE                 := FND_API.G_MISS_NUM
           ,p_work_type_id                IN    pa_project_assignments.work_type_id%TYPE                := FND_API.G_MISS_NUM
           ,p_calendar_type               IN    pa_project_assignments.calendar_type%TYPE               := FND_API.G_MISS_CHAR
           ,p_calendar_id                 IN    pa_project_assignments.calendar_id%TYPE                 := FND_API.G_MISS_NUM
           ,p_resource_calendar_percent   IN    pa_project_assignments.resource_calendar_percent%TYPE   := FND_API.G_MISS_NUM
           ,p_project_name                IN    pa_projects_all.name%TYPE                               := FND_API.G_MISS_CHAR
           ,p_project_number              IN    pa_projects_all.segment1%TYPE                           := FND_API.G_MISS_CHAR
           ,p_project_subteam_name        IN    pa_project_subteams.name%TYPE                           := FND_API.G_MISS_CHAR
           ,p_project_status_name         IN    pa_project_statuses.project_status_name%TYPE            := FND_API.G_MISS_CHAR
           ,p_staffing_priority_name      IN    pa_lookups.meaning%TYPE                                 := FND_API.G_MISS_CHAR
           ,p_project_role_name           IN    pa_project_role_types.meaning%TYPE                      := FND_API.G_MISS_CHAR
           ,p_location_city               IN    pa_locations.city%TYPE                                  := FND_API.G_MISS_CHAR
           ,p_location_region             IN    pa_locations.region%TYPE                                := FND_API.G_MISS_CHAR
           ,p_location_country_name       IN    fnd_territories_tl.territory_short_name%TYPE            := FND_API.G_MISS_CHAR
           ,p_location_country_code       IN    pa_locations.country_code%TYPE                          := FND_API.G_MISS_CHAR
           ,p_calendar_name               IN    jtf_calendars_tl.calendar_name%TYPE                     := FND_API.G_MISS_CHAR
           ,p_work_type_name              IN    pa_work_types_vl.name%TYPE                              := FND_API.G_MISS_CHAR
           ,p_expense_owner               IN    pa_project_assignments.expense_owner%TYPE               := FND_API.G_MISS_CHAR
           ,p_expense_limit               IN    pa_project_assignments.expense_limit%TYPE               := FND_API.G_MISS_NUM
           ,p_expense_limit_currency_code IN    pa_project_assignments.expense_limit_currency_code%TYPE := FND_API.G_MISS_CHAR
           ,p_fcst_tp_amount_type         IN    pa_project_assignments.fcst_tp_amount_type%TYPE         := FND_API.G_MISS_CHAR
           ,p_fcst_job_id                 IN    pa_project_assignments.fcst_job_id%TYPE                 := FND_API.G_MISS_NUM
           ,p_fcst_job_group_id           IN    pa_project_assignments.fcst_job_group_id%TYPE           := FND_API.G_MISS_NUM
           ,p_expenditure_org_id          IN    pa_project_assignments.expenditure_org_id%TYPE          := FND_API.G_MISS_NUM
           ,p_expenditure_organization_id IN    pa_project_assignments.expenditure_organization_id%TYPE := FND_API.G_MISS_NUM
           ,p_expenditure_type_class      IN    pa_project_assignments.expenditure_type_class%TYPE      := FND_API.G_MISS_CHAR
           ,p_expenditure_type            IN    pa_project_assignments.expenditure_type%TYPE            := FND_API.G_MISS_CHAR
           ,p_comp_match_weighting        IN    pa_project_assignments.competence_match_weighting%TYPE  := FND_API.G_MISS_NUM
           ,p_avail_match_weighting       IN    pa_project_assignments.availability_match_weighting%TYPE := FND_API.G_MISS_NUM
           ,p_job_level_match_weighting   IN    pa_project_assignments.job_level_match_weighting%TYPE   := FND_API.G_MISS_NUM
           ,p_search_min_availability     IN    pa_project_assignments.search_min_availability%TYPE     := FND_API.G_MISS_NUM
           ,p_search_country_code         IN    pa_project_assignments.search_country_code%TYPE         := FND_API.G_MISS_CHAR
           ,p_search_country_name         IN    fnd_territories_vl.territory_short_name%TYPE            := FND_API.G_MISS_CHAR
           ,p_search_exp_org_struct_ver_id IN   pa_project_assignments.search_exp_org_struct_ver_id%TYPE := FND_API.G_MISS_NUM
           ,p_search_exp_org_hier_name    IN    per_organization_structures.name%TYPE                   := FND_API.G_MISS_CHAR
           ,p_search_exp_start_org_id     IN    pa_project_assignments.search_exp_start_org_id%TYPE     := FND_API.G_MISS_NUM
           ,p_search_exp_start_org_name   IN    hr_organization_units.name%TYPE                         := FND_API.G_MISS_CHAR
           ,p_search_min_candidate_score  IN    pa_project_assignments.search_min_candidate_score%TYPE  := FND_API.G_MISS_NUM
           ,p_enable_auto_cand_nom_flag   IN    pa_project_assignments.enable_auto_cand_nom_flag%TYPE   := FND_API.G_MISS_CHAR
           ,p_staffing_owner_person_id    IN    pa_project_assignments.staffing_owner_person_id%TYPE    := FND_API.G_MISS_NUM
           ,p_staffing_owner_name         IN    per_people_f.full_name%TYPE                             := FND_API.G_MISS_CHAR
           ,p_fcst_job_name               IN    per_jobs.name%TYPE                                      := FND_API.G_MISS_CHAR
           ,p_fcst_job_group_name         IN    per_job_groups.displayed_name%TYPE                      := FND_API.G_MISS_CHAR
           ,p_expenditure_org_name        IN    per_organization_units.name%TYPE                        := FND_API.G_MISS_CHAR
           ,p_exp_organization_name       IN    per_organization_units.name%TYPE                        := FND_API.G_MISS_CHAR
            ,p_exception_type_code        IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_change_start_date          IN    DATE                                                    := FND_API.G_MISS_DATE
            ,p_change_end_date            IN    DATE                                                    := FND_API.G_MISS_DATE
            ,p_change_rqmt_status_code    IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_change_asgmt_status_code   IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_change_start_date_tbl      IN    SYSTEM.PA_DATE_TBL_TYPE := NULL
            ,p_change_end_date_tbl        IN    SYSTEM.PA_DATE_TBL_TYPE := NULL
            ,p_monday_hours_tbl           IN    SYSTEM.PA_NUM_TBL_TYPE  := NULL
            ,p_tuesday_hours_tbl          IN    SYSTEM.PA_NUM_TBL_TYPE  := NULL
            ,p_wednesday_hours_tbl        IN    SYSTEM.PA_NUM_TBL_TYPE  := NULL
            ,p_thursday_hours_tbl         IN    SYSTEM.PA_NUM_TBL_TYPE  := NULL
            ,p_friday_hours_tbl           IN    SYSTEM.PA_NUM_TBL_TYPE  := NULL
            ,p_saturday_hours_tbl         IN    SYSTEM.PA_NUM_TBL_TYPE  := NULL
            ,p_sunday_hours_tbl           IN    SYSTEM.PA_NUM_TBL_TYPE  := NULL
            ,p_non_working_day_flag       IN    VARCHAR2                                                := 'N'
            ,p_change_hours_type_code     IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_hrs_per_day                IN    NUMBER                                                  := FND_API.G_MISS_NUM
            ,p_calendar_percent           IN    NUMBER                                                  := FND_API.G_MISS_NUM
            ,p_change_calendar_type_code  IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_change_calendar_name       IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_change_calendar_id         IN    NUMBER                                                  := FND_API.G_MISS_NUM
            ,p_duration_shift_type_code   IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_duration_shift_unit_code   IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_num_of_shift               IN    NUMBER                                                  := FND_API.G_MISS_NUM
            ,p_approver1_id_tbl           IN    SYSTEM.pa_num_tbl_type                                        := prm_empty_num_tbl
            ,p_approver1_name_tbl         IN    SYSTEM.pa_varchar2_240_tbl_type                               := prm_empty_varchar2_240_tbl
            ,p_approver2_id_tbl           IN    SYSTEM.pa_num_tbl_type                                        := prm_empty_num_tbl
            ,p_approver2_name_tbl         IN    SYSTEM.pa_varchar2_240_tbl_type                               := prm_empty_varchar2_240_tbl
            ,p_appr_over_auth_flag        IN    VARCHAR2                                                := 'N'
            ,p_note_to_all_approvers      IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_competence_id_tbl          IN    SYSTEM.pa_num_tbl_type                                        := prm_empty_num_tbl
            ,p_competence_name_tbl        IN    SYSTEM.pa_varchar2_240_tbl_type                               := prm_empty_varchar2_240_tbl
            ,p_competence_alias_tbl       IN    SYSTEM.pa_varchar2_30_tbl_type                                := prm_empty_varchar2_30_tbl
            ,p_rating_level_id_tbl        IN    SYSTEM.pa_num_tbl_type                                        := prm_empty_num_tbl
            ,p_mandatory_flag_tbl         IN    SYSTEM.pa_varchar2_1_tbl_type                                 := prm_empty_varchar2_1_tbl
            ,p_resolve_con_action_code    IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_api_version                IN    NUMBER                                                  := 1.0
            ,p_init_msg_list              IN    VARCHAR2                                                := FND_API.G_TRUE
            ,p_max_msg_count              IN    NUMBER                                                  := FND_API.G_MISS_NUM
            ,p_commit                     IN    VARCHAR2                                                := FND_API.G_FALSE
            ,p_validate_only              IN    VARCHAR2                                                := FND_API.G_TRUE
            ,x_return_status              OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
            ,x_msg_count                  OUT   NOCOPY NUMBER         --File.Sql.39 bug 4440895
            ,x_msg_data                   OUT   NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
)
IS

    l_project_manager_person_id   NUMBER ;
    l_project_manager_name        VARCHAR2(200);
    l_project_party_id            NUMBER ;
    l_project_role_id             NUMBER ;
    l_project_role_name           VARCHAR2(80);
    l_admin_project               VARCHAR2(1); --Variable which denotes if a project is an admin project or not
    l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_error_message_code          fnd_new_messages.message_name%TYPE;
    l_assignment_start_date       DATE;
    l_approver1_person_id         NUMBER;
    l_approver1_person_name       VARCHAR2(200);
    l_approver2_person_id         NUMBER;
    l_approver2_person_name       VARCHAR2(200);
    l_resource_type_id            NUMBER;--Used in Name ID validation
    l_msg_index_out               NUMBER;

    --These are the local copies of the approver ids used in Name ID validation
    l_approver1_id_tbl            SYSTEM.pa_num_tbl_type;
    l_approver2_id_tbl            SYSTEM.pa_num_tbl_type;
    l_project_id                  NUMBER;

BEGIN

    -- Initialize the Error Stack
    PA_DEBUG.init_err_stack('PA_ASSIGNMENT_APPROVAL_PUB.mass_submit_for_assignment_approval');

    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN
    PA_DEBUG.write_log
        ( x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.mass_submit_for_assignment_approval.begin'
         ,x_msg         => 'Beginning of mass_submit_for_assignment_approval'
         ,x_log_level   => 1);
    END IF;

    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Clear the global PL/SQL message table
    FND_MSG_PUB.initialize;

    -- Issue API savepoint if the transaction is to be committed
    IF p_commit  = FND_API.G_TRUE THEN
        SAVEPOINT   MASS_SUBMIT_ASGN_APPRVL;
    END IF;

    -----------------------------------------
    --Initialize the local approver id tables
    -----------------------------------------
    l_approver1_id_tbl := p_approver1_id_tbl;
    l_approver2_id_tbl := p_approver2_id_tbl;

    --Getting Project id from project number if
    --project id = null

    l_project_id := p_project_id;

    IF l_project_id is null THEN

        SELECT project_id
        INTO   l_project_id
        FROM   pa_projects_all
        WHERE  segment1 = p_project_number;

    END IF;

    --Get the project type
    SELECT NVL(pt.administrative_flag,'N') admin_flag
    INTO   l_admin_project
    FROM   pa_projects_all pap,
           pa_project_types_all pt
    WHERE  pap.project_id  = l_project_id
    AND    pt.project_type = pap.project_type
--    AND    nvl(pap.org_id, -99) = nvl(pt.org_id, -99); /* Added nvl for bug#2467666 */ -R12: Bug 4633092
    AND    pap.org_id = pt.org_id;

    -------------------------------------------------------------
    --Validate if a project manager exists for non-admin projects
    -------------------------------------------------------------
    IF l_admin_project = 'N' THEN

        --Log Message
        IF P_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.write_log
            (x_module    => 'PA_ASSIGNMENT_APPROVAL_PUB.mass_submit_for_assignment_approval.check_prj_manager.'
            ,x_msg       => 'Check if project manger exists.'
            ,x_log_level => 1);
        END IF;

        pa_project_parties_utils.get_curr_proj_mgr_details
            ( p_project_id         => l_project_id
             ,x_manager_person_id  => l_project_manager_person_id
             ,x_manager_name       => l_project_manager_name
             ,x_project_party_id   => l_project_party_id
             ,x_project_role_id    => l_project_role_id
             ,x_project_role_name  => l_project_role_name
             ,x_return_status      => l_return_status
             ,x_error_message_code => l_error_message_code );

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                 ,p_msg_name       => l_error_message_code);
        END IF;

        l_error_message_code := FND_API.G_MISS_CHAR;

    END IF;

    IF l_return_status <> FND_API.G_RET_STS_ERROR THEN

        ---------------------------------
        --Call the mass transaction API
        ---------------------------------
        PA_MASS_ASGMT_TRX.Start_Mass_Asgmt_Trx_Wf(
                p_mode                         => p_mode
               ,p_action                       => p_action
               ,p_resource_id_tbl              => p_resource_id_tbl
               ,p_assignment_id_tbl            => p_assignment_id_tbl
               ,p_assignment_name              => p_assignment_name
               ,p_assignment_type              => p_assignment_type
               ,p_status_code                  => p_status_code
               ,p_multiple_status_flag         => p_multiple_status_flag
               ,p_staffing_priority_code       => p_staffing_priority_code
               ,p_project_id                   => l_project_id
               ,p_project_role_id              => p_project_role_id
               ,p_role_list_id                 => p_role_list_id
               ,p_project_subteam_id           => p_project_subteam_id
               ,p_description                  => p_description
               ,p_append_description_flag      => p_append_description_flag
               ,p_start_date                   => p_start_date
               ,p_end_date                     => p_end_date
               ,p_extension_possible           => p_extension_possible
               ,p_min_resource_job_level       => p_min_resource_job_level
               ,p_max_resource_job_level       => p_max_resource_job_level
               ,p_additional_information       => p_additional_information
               ,p_append_information_flag      => p_append_information_flag
               ,p_location_id                  => p_location_id
               ,p_work_type_id                 => p_work_type_id
               ,p_calendar_type                => p_calendar_type
               ,p_calendar_id                  => p_calendar_id
               ,p_resource_calendar_percent    => p_resource_calendar_percent
               ,p_project_name                 => p_project_name
               ,p_project_number               => p_project_number
               ,p_project_subteam_name         => p_project_subteam_name
               ,p_project_status_name          => p_project_status_name
               ,p_staffing_priority_name       => p_staffing_priority_name
               ,p_project_role_name            => p_project_role_name
               ,p_location_city                => p_location_city
               ,p_location_region              => p_location_region
               ,p_location_country_name        => p_location_country_name
               ,p_location_country_code        => p_location_country_code
               ,p_calendar_name                => p_calendar_name
               ,p_work_type_name               => p_work_type_name
               ,p_expense_owner                => p_expense_owner
               ,p_expense_limit                => p_expense_limit
               ,p_expense_limit_currency_code  => p_expense_limit_currency_code
               ,p_fcst_tp_amount_type          => p_fcst_tp_amount_type
               ,p_fcst_job_id                  => p_fcst_job_id
               ,p_fcst_job_group_id            => p_fcst_job_group_id
               ,p_expenditure_org_id           => p_expenditure_org_id
               ,p_expenditure_organization_id  => p_expenditure_organization_id
               ,p_expenditure_type_class       => p_expenditure_type_class
               ,p_expenditure_type             => p_expenditure_type
               ,p_comp_match_weighting         => p_comp_match_weighting
               ,p_avail_match_weighting        => p_avail_match_weighting
               ,p_job_level_match_weighting    => p_job_level_match_weighting
               ,p_search_min_availability      => p_search_min_availability
               ,p_search_country_code          => p_search_country_code
               ,p_search_country_name          => p_search_country_name
               ,p_search_exp_org_struct_ver_id => p_search_exp_org_struct_ver_id
               ,p_search_exp_org_hier_name     => p_search_exp_org_hier_name
               ,p_search_exp_start_org_id      => p_search_exp_start_org_id
               ,p_search_exp_start_org_name    => p_search_exp_start_org_name
               ,p_search_min_candidate_score   => p_search_min_candidate_score
               ,p_enable_auto_cand_nom_flag    => p_enable_auto_cand_nom_flag
               ,p_staffing_owner_person_id     => p_staffing_owner_person_id
               ,p_staffing_owner_name          => p_staffing_owner_name
               ,p_fcst_job_name                => p_fcst_job_name
               ,p_fcst_job_group_name          => p_fcst_job_group_name
               ,p_expenditure_org_name         => p_expenditure_org_name
               ,p_exp_organization_name        => p_exp_organization_name
               ,p_exception_type_code          => p_exception_type_code
               ,p_change_start_date            => p_change_start_date
               ,p_change_end_date              => p_change_end_date
               ,p_change_rqmt_status_code      => p_change_rqmt_status_code
               ,p_change_asgmt_status_code     => p_change_asgmt_status_code
               ,p_change_start_date_tbl        => p_change_start_date_tbl
               ,p_change_end_date_tbl          => p_change_end_date_tbl
               ,p_monday_hours_tbl             => p_monday_hours_tbl
               ,p_tuesday_hours_tbl            => p_tuesday_hours_tbl
               ,p_wednesday_hours_tbl          => p_wednesday_hours_tbl
               ,p_thursday_hours_tbl           => p_thursday_hours_tbl
               ,p_friday_hours_tbl             => p_friday_hours_tbl
               ,p_saturday_hours_tbl           => p_saturday_hours_tbl
               ,p_sunday_hours_tbl             => p_sunday_hours_tbl
               ,p_non_working_day_flag         => p_non_working_day_flag
               ,p_change_hours_type_code       => p_change_hours_type_code
               ,p_hrs_per_day                  => p_hrs_per_day
               ,p_calendar_percent             => p_calendar_percent
               ,p_change_calendar_type_code    => p_change_calendar_type_code
               ,p_change_calendar_name         => p_change_calendar_name
               ,p_change_calendar_id           => p_change_calendar_id
               ,p_duration_shift_type_code     => p_duration_shift_type_code
               ,p_duration_shift_unit_code     => p_duration_shift_unit_code
               ,p_num_of_shift                 => p_num_of_shift
               ,p_approver1_id_tbl             => l_approver1_id_tbl     --The local updated table is passed
               ,p_approver1_name_tbl           => p_approver1_name_tbl
               ,p_approver2_id_tbl             => l_approver2_id_tbl     --The local updated table is passed
               ,p_approver2_name_tbl           => p_approver2_name_tbl
               ,p_appr_over_auth_flag          => p_appr_over_auth_flag
               ,p_note_to_all_approvers        => p_note_to_all_approvers
               ,p_competence_id_tbl            => p_competence_id_tbl
               ,p_competence_name_tbl          => p_competence_name_tbl
               ,p_competence_alias_tbl         => p_competence_alias_tbl
               ,p_rating_level_id_tbl          => p_rating_level_id_tbl
               ,p_mandatory_flag_tbl           => p_mandatory_flag_tbl
               ,p_resolve_con_action_code      => p_resolve_con_action_code
               ,x_return_status                => l_return_status  );

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := l_return_status;
        END IF;

    END IF;

    x_msg_count :=  FND_MSG_PUB.Count_Msg;

    -- IF the number of messages is 1 then fetch the message code from
    -- the stack and return its text
    IF x_msg_count = 1 THEN
        pa_interface_utils_pub.get_messages
            ( p_encoded       => FND_API.G_TRUE
             ,p_msg_index     => 1
             ,p_data          => x_msg_data
             ,p_msg_index_out => l_msg_index_out );
    END IF;

    -- Reset the error stack when returning to the calling program
    PA_DEBUG.Reset_Err_Stack;

    -- If g_error_exists is TRUE then set the x_return_status to 'E'
    IF FND_MSG_PUB.Count_Msg >0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

EXCEPTION
     WHEN OTHERS THEN

         IF p_commit = FND_API.G_TRUE THEN
             ROLLBACK TO  MASS_SUBMIT_ASGN_APPRVL;
         END IF;

         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PUB.mass_submit_for_asgmt_aprvl'
              ,p_procedure_name => PA_DEBUG.G_Err_Stack );

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;

END mass_submit_for_asgmt_aprvl;

---------------------------------------------------------------------------
--This API is called from the Mass Transaction Server API
--This is the main API which starts the assignment
--approval process
--The IN parameters are assignments table which are submitted for
--approval along with 2 approvers tables
---------------------------------------------------------------------------
PROCEDURE mass_assignment_approval
    ( p_project_id                  IN    pa_project_assignments.project_id%TYPE   := FND_API.G_MISS_NUM
     ,p_mode                        IN    VARCHAR2
     ,p_assignment_id_tbl           IN    SYSTEM.pa_num_tbl_type           := prm_empty_num_tbl
     ,p_approver1_id_tbl            IN    SYSTEM.pa_num_tbl_type           := prm_empty_num_tbl
     ,p_approver1_name_tbl          IN    SYSTEM.pa_varchar2_240_tbl_type  := prm_empty_varchar2_240_tbl
     ,p_approver2_id_tbl            IN    SYSTEM.pa_num_tbl_type           := prm_empty_num_tbl
     ,p_approver2_name_tbl          IN    SYSTEM.pa_varchar2_240_tbl_type  := prm_empty_varchar2_240_tbl
     ,p_overriding_authority_flag   IN    VARCHAR2                     := 'N'
     ,p_submitter_user_id           IN    NUMBER                       := FND_API.G_MISS_NUM
     ,p_note_to_all_approvers       IN    VARCHAR2                     := FND_API.G_MISS_CHAR
     ,p_conflict_group_id           IN    NUMBER                       := FND_API.G_MISS_NUM
     ,p_update_info_doc             IN    VARCHAR2                     := FND_API.G_MISS_CHAR
     ,p_api_version                 IN    NUMBER                       := 1.0
     ,p_init_msg_list               IN    VARCHAR2                     := FND_API.G_TRUE
     ,p_max_msg_count               IN    NUMBER                       := FND_API.G_MISS_NUM
     ,p_commit                      IN    VARCHAR2                     := FND_API.G_FALSE
     ,p_validate_only               IN    VARCHAR2                     := FND_API.G_TRUE
     ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                   OUT   NOCOPY NUMBER         --File.Sql.39 bug 4440895
     ,x_msg_data                    OUT   NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
)
IS

    l_return_status               VARCHAR2(1);
    l_error_message_code          fnd_new_messages.message_name%TYPE;
    x_error_message_code          fnd_new_messages.message_name%TYPE;
    l_msg_index_out               NUMBER;
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);
    l_data                        VARCHAR2(2000);
    l_assignment_status           VARCHAR2(10) := PA_ASSIGNMENT_APPROVAL_PUB.g_submit_action;
    l_approver1_id_tbl            SYSTEM.pa_num_tbl_type;
    l_approver1_name_tbl          SYSTEM.pa_varchar2_240_tbl_type;
    l_approver2_id_tbl            SYSTEM.pa_num_tbl_type;
    l_approver2_name_tbl          SYSTEM.pa_varchar2_240_tbl_type;
    l_assignment_id_tbl           SYSTEM.pa_num_tbl_type;
    l_apr1_res_auth               VARCHAR2(1) := 'Y';
    l_apr2_res_auth               VARCHAR2(1) := 'Y';
    l_new_asgmt_flag              VARCHAR2(1);
    x_aprvl_required              VARCHAR2(1);
    l_routing_order               NUMBER;
    l_change_id                   NUMBER;
    l_record_version_number       NUMBER;
    p_record_version_number       NUMBER;
    l_apprvl_status_code          pa_project_assignments.apprvl_status_code%TYPE;
    l_project_super_user_submitter VARCHAR2(1);
    l_display_name                VARCHAR2(360);  /* Modified length from 200 to 360 for bug 3148857 */
    l_approver_name               VARCHAR2(320);  /* Modified length from 200 to 320 for bug 3148857 */

    CURSOR resource_id (p_assignment_id NUMBER) IS
    SELECT resource_id
    FROM   pa_project_assignments
    WHERE  assignment_id = p_assignment_id;

    l_resource_id NUMBER;

    CURSOR get_rec_num ( p_assignment_id IN NUMBER )IS
    SELECT record_version_number
    FROM pa_project_assignments
    WHERE assignment_id = p_assignment_id;

    CURSOR l_stus_csr IS
    SELECT ps.enable_wf_flag
    FROM   pa_project_statuses ps
    WHERE  ps.project_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_submitted;

    l_stus_rec  l_stus_csr%ROWTYPE;

    l_approvers_list_tbl  PA_CLIENT_EXTN_ASGMT_WF.Users_List_Tbltyp ;
    l_out_approvers_list_tbl  PA_CLIENT_EXTN_ASGMT_WF.Users_List_Tbltyp ;
    l_number_of_approvers  NUMBER := 0;
    l_approvers_list_rec  PA_CLIENT_EXTN_ASGMT_WF.Users_List_Rectyp ;
    l_approver_person_id  NUMBER := 0;

    l_group_id NUMBER;
    l_approver_group_id NUMBER;

    CURSOR distinct_approvers IS
    SELECT distinct user_name
    FROM   pa_wf_ntf_performers ntf,
           pa_project_assignments asgn
    WHERE  ntf.group_id            = l_group_id
    AND    ntf.object_id1          = asgn.assignment_id
    AND    asgn.apprvl_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_submitted
    AND    ntf.routing_order       = 1;

    l_customer_id         NUMBER;
    l_customer_name       VARCHAR2(2000);
    l_project_manager_person_id   NUMBER ;
    l_project_manager_name        VARCHAR2(200);
    l_project_party_id    NUMBER ;
    l_project_role_id     NUMBER ;
    l_project_role_name   VARCHAR2(80);
    l_submitter_person_id NUMBER;
    l_submitter_user_name VARCHAR2(100);  /* Modified length from 30 to 100 for bug 3148857 */

    CURSOR l_projects_csr(l_project_id IN NUMBER) IS
    SELECT pap.project_id project_id,
           pap.name name,
           pap.segment1 segment1,
           pap.carrying_out_organization_id carrying_out_organization_id,
           pap.location_id,
           hr.name organization_name,
           NVL(pt.administrative_flag,'N') admin_flag
    FROM   pa_projects_all pap,
           hr_all_organization_units_tl hr, -- Bug 4358492
           pa_project_types_all pt
    WHERE  pap.project_id = l_project_id
    AND    pap.carrying_out_organization_id = hr.organization_id
    AND    pt.project_type = pap.project_type
    AND    pap.org_id = pt.org_id -- Bug 4358492
    AND    userenv('LANG') = hr.language; -- Bug 4358492

    l_projects_rec l_projects_csr%ROWTYPE;

    CURSOR get_submitter_details IS
    SELECT employee_id,
           user_name
    FROM   fnd_user
    WHERE  user_id = p_submitter_user_id;
    l_submitter_rec get_submitter_details%ROWTYPE;

    l_asgn_approval_status pa_project_assignments.apprvl_status_code%TYPE;

    PROCESS_ASSIGNMENT_EXCEPTION EXCEPTION;
    NO_WORKFLOW_EXCEPTION EXCEPTION;
    INVALID_STATUS EXCEPTION;

    l_num_apr_asgns NUMBER := 0;
    l_num_rej_asgns NUMBER := 0;

    --Default value is Y
    --If any assignment is submitted then flag is set to N
    l_error_flag VARCHAR2(1) := 'Y';
    l_error_count NUMBER;

    l_appr_asgmt_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

    l_privelege varchar2(30);
    l_resource_super_user varchar2(1);

BEGIN

    -- Initialize the Error Stack
    PA_DEBUG.init_err_stack('PA_ASSIGNMENT_APPROVAL_PUB.mass_assignment_approval');

    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN
    PA_DEBUG.write_log
        ( x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.mass_assignment_approval.begin'
         ,x_msg         => 'Beginning of mass_assignment_approval'
         ,x_log_level   => 1);
    END IF;

    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Clear the global PL/SQL message table
    FND_MSG_PUB.initialize;

    -- Issue API savepoint if the transaction is to be committed
    IF p_commit  = FND_API.G_TRUE THEN
        SAVEPOINT   MASS_ASGN_APPRVL;
    END IF;

    ---------------------------------------------------------------------
    --Generate the group id for this mass transaction
    --This group id is inserted for every record in PA_WF_NTF_PERFORMERS
    --The group_id is inserted from the sequence PA_WF_NTF_PERFORMERS_S
    --The approver_group_id is initialy null
    --The group id is used to group all records which belong to this
    --mass transaction and is used in sending FYI notifications to
    --managers in the end when there are no pending approvals
    ---------------------------------------------------------------------
    SELECT PA_WF_NTF_PERFORMERS_S.nextval
    INTO   l_group_id
    FROM   dual;

    OPEN get_submitter_details;
    FETCH get_submitter_details INTO l_submitter_rec;
    CLOSE get_submitter_details;

    l_submitter_person_id := l_submitter_rec.employee_id;
    l_submitter_user_name := l_submitter_rec.user_name;

    ------------------------------------------
    --Validate the Name Id for approvers
    ------------------------------------------
    log_message('Before Calling Validate_approver_name_id');
     /*Added a new parameter p_overriding_authority_flag for bug 3213509*/
    Validate_approver_name_id
        ( p_project_id                => p_project_id
         ,p_assignment_id_tbl         => p_assignment_id_tbl
         ,p_approver1_id_tbl          => p_approver1_id_tbl
         ,p_approver1_name_tbl        => p_approver1_name_tbl
         ,p_approver2_id_tbl          => p_approver2_id_tbl
         ,p_approver2_name_tbl        => p_approver2_name_tbl
         ,p_submitter_user_id         => p_submitter_user_id
         ,p_group_id                  => l_group_id
         ,p_overriding_authority_flag => p_overriding_authority_flag
         ,x_assignment_id_tbl         => l_assignment_id_tbl
         ,x_approver1_id_tbl          => l_approver1_id_tbl
         ,x_approver2_id_tbl          => l_approver2_id_tbl
         ,x_return_status             => x_return_status
         ,x_msg_count                 => x_msg_count
         ,x_msg_data                  => x_msg_data);

    log_message('After Calling Validate_approver_name_id');

    ---------------------------------------------------------------------------------------
    --Getting the Project details once instead of in every call to start_mass_approval_flow
    ---------------------------------------------------------------------------------------
    OPEN l_projects_csr( p_project_id);
    FETCH l_projects_csr INTO l_projects_rec;
    IF l_projects_csr%NOTFOUND THEN

        pa_utils.add_message (p_app_short_name  => 'PA',
                              p_msg_name        => 'PA_INVALID_PROJECT_ID');

    END IF;
    CLOSE l_projects_csr;

    PA_ASGMT_WFSTD.Check_And_Get_Proj_Customer
        (p_project_id    => p_project_id
        ,x_customer_id   => l_customer_id
        ,x_customer_name => l_customer_name );

    -- Get the project manager details
    pa_project_parties_utils.get_curr_proj_mgr_details
        (p_project_id         => l_projects_rec.project_id
        ,x_manager_person_id  => l_project_manager_person_id
        ,x_manager_name       => l_project_manager_name
        ,x_project_party_id   => l_project_party_id
        ,x_project_role_id    => l_project_role_id
        ,x_project_role_name  => l_project_role_name
        ,x_return_status      => l_return_status
        ,x_error_message_code => l_error_message_code );

    -- Only non-admin projects require a manager
    IF l_projects_rec.admin_flag = 'N' THEN
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            pa_utils.add_message (p_app_short_name  => 'PA',
                                  p_msg_name        => l_error_message_code);
        END IF;
    END IF;

    log_message('After Getting Project information');

     -- Status Validation to check if workflow is enabled. If status is not valid,
     -- RAISE an ERROR.
     -- Also if Workflow is disabled - then exit
     OPEN l_stus_csr;
     FETCH l_stus_csr INTO l_stus_rec;
     IF l_stus_csr%NOTFOUND THEN
         l_return_status := FND_API.G_RET_STS_ERROR;
         l_error_message_code := 'PA_INVALID_STATUS_CODE';
         pa_utils.add_message (p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_INVALID_STATUS_CODE');
         RAISE INVALID_STATUS;
         log_message('Error in Workflow enabled check');
     END IF;
     CLOSE l_stus_csr;

     IF NVL(l_stus_rec.enable_wf_flag,'N') = 'N' THEN
         pa_utils.add_message (p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_INVALID_STATUS_CODE');
         RAISE NO_WORKFLOW_EXCEPTION;
     END IF;

     log_message('Completed Workflow enabled check');

    --Initialize locals
    l_approver1_name_tbl := p_approver1_name_tbl;
    l_approver2_name_tbl := p_approver2_name_tbl;

    FOR i in 1..l_assignment_id_tbl.COUNT LOOP

    SAVEPOINT PROCESS_ASSIGNMENT_SUBMISSION;

    BEGIN

        log_message('Loop:' || i);

        IF l_assignment_id_tbl(i) IS NOT NULL THEN

           log_message('approver 1 id:' || l_approver1_id_tbl(i));
           log_message('approver 2 id:' || l_approver2_id_tbl(i));

            OPEN resource_id ( l_assignment_id_tbl(i));
            FETCH resource_id INTO l_resource_id;
            CLOSE resource_id;

            -------------------------------------------
            --Check if overriding authority flag is set
            -------------------------------------------
            IF p_overriding_authority_flag = 'Y' THEN

                log_message('Overriding auth flag set');

                ------------------------------------------------------------------------------------
                --Below logic determines if the submitter is the resource super user responsibility
                --There are 2 checks done
                -- 1. Profile check
                -- 2. User has privelege to confirm assignments
                --NOTE: The MASS ASSIGNMENT workflow has already initialized the submitters
                --responsibility id and product id and user id
                -----------------------------------------------------------------------------------
                l_project_super_user_submitter := fnd_profile.value_specific('PA_SUPER_RESOURCE',
                                                                    p_submitter_user_id,
                                                                    fnd_global.resp_id,
                                                                    fnd_global.resp_appl_id);

                IF l_project_super_user_submitter = 'Y' THEN

                    IF l_projects_rec.admin_flag = 'N' THEN
                       l_privelege := 'PA_ASN_CONFIRM';
                    ELSIF l_projects_rec.admin_flag = 'Y' THEN
                       l_privelege := 'PA_ADM_ASN_CONFIRM';
                    END IF;

                    IF fnd_function.test(l_privelege) THEN
                      l_resource_super_user := 'Y';
                    ELSE
                      l_resource_super_user := 'N';
                    END IF;

                END IF;

                IF l_resource_super_user = 'Y' OR
                   pa_resource_utils.check_user_has_res_auth (l_submitter_person_id, l_resource_id) = 'Y' THEN
                    l_assignment_status := PA_ASSIGNMENT_APPROVAL_PUB.g_approve_action;
                ELSE --submitter does not have resource authority

                    ----------------------------------------------------------------------
                    --If submitter has no resource authority and both approvers are null
                    --assignment cannot be approved as there are no approvers
                    ----------------------------------------------------------------------
                    IF l_approver1_id_tbl(i) is null AND l_approver2_id_tbl(i) is null THEN

                        --Add error message to error stack
                        l_error_message_code := 'PA_RESOURCE_NO_AUTH';
                        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                             ,p_msg_name       => l_error_message_code);

                        RAISE PROCESS_ASSIGNMENT_EXCEPTION;
                    ELSE
                        l_assignment_status := PA_ASSIGNMENT_APPROVAL_PUB.g_submit_action;
                    END IF;
                END IF;

            ELSIF l_approver1_id_tbl(i) = l_submitter_person_id  THEN

                IF l_approver2_id_tbl(i) is null  THEN
                    l_assignment_status := PA_ASSIGNMENT_APPROVAL_PUB.g_approve_action;
                ELSIF l_approver2_id_tbl(i) = l_submitter_person_id  THEN
                    l_assignment_status := PA_ASSIGNMENT_APPROVAL_PUB.g_approve_action;
                ELSE
                    l_approver1_id_tbl(i) := l_approver2_id_tbl(i);
                    l_approver1_name_tbl(i) := l_approver2_name_tbl(i);
                    l_approver2_id_tbl(i) := null;
                    l_approver2_name_tbl(i):= null;
                    l_assignment_status := PA_ASSIGNMENT_APPROVAL_PUB.g_submit_action;
                END IF;

            ELSIF l_approver1_id_tbl(i) is null AND l_approver2_id_tbl(i) is null THEN

                --Add error message to error stack
                l_error_message_code := 'PA_RESOURCE_NO_AUTH';
                PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                     ,p_msg_name       => l_error_message_code);
                log_message('No approver');
                RAISE PROCESS_ASSIGNMENT_EXCEPTION;

            END IF; --end l_overriding_authority_flag = 'Y

            IF l_approver2_id_tbl(i) = l_submitter_person_id  THEN
                l_approver2_id_tbl(i) := null;
            END IF;

            --------------------------------
            --Need to reorder approver list
            --------------------------------
            IF l_approver1_id_tbl(i) is null THEN
                l_approver1_id_tbl(i) := l_approver2_id_tbl(i);
                l_approver1_name_tbl(i) := l_approver2_name_tbl(i);
                l_approver2_id_tbl(i) := null;
                l_approver2_name_tbl(i):= null;
            END IF;

            ---------------------------------------------------------------------------------
             --Validate approver only if l_assignment_status = g_submit_action
             --Validate Approver One and Approver Two has resource authority over the resource
             --for that assignment, otherwise raise an error.
            ---------------------------------------------------------------------------------
            IF l_assignment_status = PA_ASSIGNMENT_APPROVAL_PUB.g_submit_action THEN



                log_message('Checkin resource authority');
                log_message('Approver 1: ' || l_approver1_id_tbl(i));
                log_message('Approver 2: ' || l_approver2_id_tbl(i));
                log_message('Resource : ' || l_resource_id);

                l_apr1_res_auth := pa_resource_utils.check_user_has_res_auth (l_approver1_id_tbl(i), l_resource_id);

                IF l_approver2_id_tbl(i) is not null THEN
                    l_apr2_res_auth := pa_resource_utils.check_user_has_res_auth (l_approver2_id_tbl(i), l_resource_id);
                END IF;

                IF l_apr1_res_auth = 'N' OR l_apr2_res_auth = 'N' THEN

                    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                         ,p_msg_name       => 'PA_RESOURCE_NO_AUTH');
                    log_message('No resource authority 1');
                    RAISE PROCESS_ASSIGNMENT_EXCEPTION;

                END IF;
            END IF;

            ------------------------------------------------------------------
            --When l_assignment_status is not null implies that the assignment
            --can be processed for assignment approval
            ------------------------------------------------------------------
            IF l_assignment_status = PA_ASSIGNMENT_APPROVAL_PUB.g_submit_action THEN

                l_new_asgmt_flag := PA_ASSIGNMENT_APPROVAL_PVT.Is_New_Assignment( l_assignment_id_tbl(i) );

                IF l_new_asgmt_flag = 'N' THEN

                    PA_ASSIGNMENT_APPROVAL_PVT.check_approval_required
                        ( l_assignment_id_tbl(i)
                         ,l_new_asgmt_flag
                         ,x_aprvl_required
                         ,l_return_status );

                    IF x_aprvl_required = 'N' THEN
                        l_assignment_status := PA_ASSIGNMENT_APPROVAL_PUB.g_approve_action;
                    END IF;

                END IF;

            END IF; --end l_assignment_status = 'SUBMIT'

            ----------------------------------------------------------
            --Store previous value of assignment status to be inserted into
            --pa_wf_ntf_performers table
            ----------------------------------------------------------
            BEGIN
                    SELECT apprvl_status_code
                    INTO   l_asgn_approval_status
                    FROM   pa_project_assignments
                    WHERE  assignment_id = l_assignment_id_tbl(i);
            EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_asgn_approval_status := null;
            END;

            IF l_assignment_status = PA_ASSIGNMENT_APPROVAL_PUB.g_approve_action THEN

                log_message('Approve action for loop' || i);

                OPEN get_rec_num ( l_assignment_id_tbl(i) );
                FETCH get_rec_num INTO p_record_version_number;
                CLOSE get_rec_num;

                PA_ASSIGNMENT_APPROVAL_PVT.Update_Approval_Status
                    ( p_assignment_id         => l_assignment_id_tbl(i)
                     ,p_action_code           => PA_ASSIGNMENT_APPROVAL_PUB.g_approve_action
                     ,p_note_to_approver      => p_note_to_all_approvers
                     ,p_record_version_number => p_record_version_number
                     ,x_apprvl_status_code    => l_apprvl_status_code
                     ,x_change_id             => l_change_id
                     ,x_record_version_number => l_record_version_number
                     ,x_return_status         => l_return_status
                     ,x_msg_count             => l_msg_count
                     ,x_msg_data              => l_msg_data);

                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    l_return_status := FND_API.G_MISS_CHAR;
                    log_message('Error in Update approval status 1');
                    RAISE PROCESS_ASSIGNMENT_EXCEPTION;
                END IF;

                -- resolve remaining conflicts by taking action chosen by user
                PA_SCHEDULE_PVT.resolve_conflicts (p_conflict_group_id   => p_conflict_group_id
                                                  ,p_assignment_id       => l_assignment_id_tbl(i)
                                                  ,x_return_status       => l_return_status
                                                  ,x_msg_count           => l_msg_count
                                                  ,x_msg_data            => l_msg_data);

                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    l_return_status := FND_API.G_MISS_CHAR;
                    log_message('Error in conflict resolution');
                    RAISE PROCESS_ASSIGNMENT_EXCEPTION;
                END IF;

                 ----------------------------------------------------------------------------
                --Insert this assignment into pa_wf_ntf_performers for sending manager
                --notifications. The approver is the submitter in this case
                ----------------------------------------------------------------------------
                IF l_submitter_user_name is not null THEN

                        INSERT INTO pa_wf_ntf_performers(
                            WF_TYPE_CODE
                           ,ITEM_TYPE
                           ,ITEM_KEY
                           ,OBJECT_ID1
                           ,OBJECT_ID2
                           ,GROUP_ID
                           ,USER_NAME
                           ,USER_TYPE
                           ,ROUTING_ORDER
                           ,APPROVAL_STATUS)
                         VALUES ('MASS_ASSIGNMENT_APPROVAL'
                            ,'-1'
                            ,'-1'
                            ,l_assignment_id_tbl(i)
                            ,-1
                            ,l_group_id
                            ,l_submitter_user_name
                            ,'APPROVER'
                            ,1
                            ,l_asgn_approval_status
                          );
                END IF;

                -------------------------------------------------------
                --Process the resource notification for this assignment
                -------------------------------------------------------
                PA_ASGMT_WFSTD.process_res_fyi_notification
                    ( p_project_id        => p_project_id
                     ,p_mode              => p_mode
                     ,p_assignment_id     => l_assignment_id_tbl(i)
                     ,p_project_name      => l_projects_rec.name
                     ,p_project_number    => l_projects_rec.segment1
                     ,p_project_manager   => l_project_manager_name
                     ,p_project_org       => l_projects_rec.organization_name
                     ,p_project_cus       => l_customer_name
                     ,p_conflict_group_id => p_conflict_group_id
                     ,x_return_status     => l_return_status
                     ,x_msg_count         => l_msg_count
                     ,x_msg_data          => l_msg_data);

             ELSE --l_assignment_status  = SUBMITTED

                log_message('Submit action for loop' || i );
                log_message('Assignment Id: ' || l_assignment_id_tbl(i) );

                OPEN get_rec_num ( l_assignment_id_tbl(i) );
                FETCH get_rec_num INTO p_record_version_number;
                CLOSE get_rec_num;

                log_message('Record version number: ' || p_record_version_number );

                PA_ASSIGNMENT_APPROVAL_PVT.Update_Approval_Status
                    ( p_assignment_id         => l_assignment_id_tbl(i)
                     ,p_action_code           => PA_ASSIGNMENT_APPROVAL_PUB.g_submit_action
                     ,p_note_to_approver      => p_note_to_all_approvers
                     ,p_record_version_number => p_record_version_number
                     ,x_apprvl_status_code    => l_apprvl_status_code
                     ,x_change_id             => l_change_id
                     ,x_record_version_number => l_record_version_number
                     ,x_return_status         => l_return_status
                     ,x_msg_count             => l_msg_count
                     ,x_msg_data              => l_msg_data);

                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    l_return_status := FND_API.G_MISS_CHAR;
                    log_message('Error in Update approval status 2');
                    RAISE PROCESS_ASSIGNMENT_EXCEPTION;
                END IF;

                ---------------------------------------------------------------------------
                --If no errors for this assignment then :
                --  i. call PA_CLIENT_EXTN_ASGMT_WF.Generate_Assignment_Approvers(..) to get
                --     any client defined Approvers.
                --  ii. insert into PA_WF_NTF_PERFORMERS (insert Approvers and assignment)
                --Note: All the inserted records have a unique identifier Group_id
                -- We can recognize all the records in PA_WF_NTF_PERFORMERS
                --for a given transaction using this identifier.
                ---------------------------------------------------------------------------

		IF l_approvers_list_tbl.COUNT > 0 THEN
                 l_approvers_list_tbl.DELETE ;
                END IF;

                --Construct the in list of approvers
                FOR j IN 1..2 LOOP
                    IF j = 1 AND l_approver1_id_tbl(i) IS NOT NULL THEN
                        l_approvers_list_rec.Person_id := l_approver1_id_tbl(i);

                        --Get the approver User name (FND_USER)
                        wf_directory.getusername
                           (p_orig_system    => 'PER'
                           ,p_orig_system_id => l_approver1_id_tbl(i)
                           ,p_name           => l_approver_name
                           ,p_display_name   => l_display_name);

                        l_approvers_list_rec.User_Name := l_approver_name;
                        l_approver_name := null; --reset

                        l_approvers_list_rec.Routing_Order :=  j;
                        l_approvers_list_tbl(j) := l_approvers_list_rec;

                    END IF;

                    IF j = 2  AND l_approver2_id_tbl(i) IS NOT NULL THEN
                        l_approvers_list_rec.Person_id := l_approver2_id_tbl(i);

                        --Get the approver User name (FND_USER)
                        wf_directory.getusername
                            (p_orig_system    => 'PER'
                            ,p_orig_system_id => l_approver2_id_tbl(i)
                            ,p_name           => l_approver_name
                            ,p_display_name   => l_display_name);

                        l_approvers_list_rec.User_Name := l_approver_name;
                        l_approver_name := null; --reset

                        l_approvers_list_rec.Routing_Order :=  j;
                        l_approvers_list_tbl(j) := l_approvers_list_rec;

                    END IF;

                END LOOP;--end j loop

                log_message('In Count:' || l_approvers_list_tbl.COUNT);

                PA_CLIENT_EXTN_ASGMT_WF.Generate_Assignment_Approvers
                    (p_assignment_id            => l_assignment_id_tbl(i)
                    ,p_project_id               => p_project_id
                    ,p_in_list_of_approvers     => l_approvers_list_tbl
                    ,x_out_list_of_approvers    => l_out_approvers_list_tbl
                    ,x_number_of_approvers      => l_number_of_approvers );

                log_message('OUT  Count:' || l_out_approvers_list_tbl.COUNT);

                -------------------------------------------------------
                --Insert All approvers into PA_WF_NTF_PERFORMERS Table
                -------------------------------------------------------
                l_routing_order := 0;
                FOR k in 1..l_out_approvers_list_tbl.COUNT LOOP

                    IF l_out_approvers_list_tbl(k).user_name is not null THEN

                        INSERT INTO pa_wf_ntf_performers(
                            WF_TYPE_CODE
                           ,ITEM_TYPE
                           ,ITEM_KEY
                           ,OBJECT_ID1
                           ,OBJECT_ID2
                           ,GROUP_ID
                           ,USER_NAME
                           ,USER_TYPE
                           ,ROUTING_ORDER
                           ,APPROVAL_STATUS)
                         VALUES ('MASS_ASSIGNMENT_APPROVAL'
                            ,'-1'
                            ,'-1'
                            ,l_assignment_id_tbl(i)
                            ,-1
                            ,l_group_id
                            ,l_out_approvers_list_tbl(k).user_name
                            ,'APPROVER'
                            ,l_routing_order + 1
                            ,l_asgn_approval_status
                          );
                    END IF;

                    l_routing_order := l_routing_order + 1;

                END LOOP;--end k loop

                --Set pending approval flag for assignment record in pa_project_assignments
                PA_ASGMT_WFSTD.Maintain_wf_pending_flag
                    (p_assignment_id => l_assignment_id_tbl(i),
                     p_mode          => 'PENDING_APPROVAL') ;

            END IF;--end l_assignment_status  = SUBMITTED

            log_message('Completed Loop ' || i );

        END IF; --assignment id null check

    EXCEPTION
        WHEN PROCESS_ASSIGNMENT_EXCEPTION THEN

            log_message('Exception during assignment processing');

            ROLLBACK TO PROCESS_ASSIGNMENT_SUBMISSION;

            log_message('Assignment id:' || l_assignment_id_tbl(i));

            PA_MESSAGE_UTILS.save_messages
                   (p_user_id            =>  p_submitter_user_id,
                    p_source_type1       =>  PA_MASS_ASGMT_TRX.G_SOURCE_TYPE1,
                    p_source_type2       =>  'MASS_APPROVAL',
                    p_source_identifier1 =>  'PAWFAAP',
                    p_source_identifier2 =>  l_group_id,
                    p_context1           =>  p_project_id,
                    p_context2           =>  l_assignment_id_tbl(i),
                    p_context3           =>  l_resource_id,
                    p_commit             =>  FND_API.G_FALSE,
                    x_return_status      =>  l_return_status);

             --Setting pending approval flag in pa_project_assignments
             PA_ASGMT_WFSTD.Maintain_wf_pending_flag
                    (p_assignment_id => l_assignment_id_tbl(i),
                     p_mode          => 'APPROVAL_PROCESS_COMPLETED') ;

             ---------------------------
             --Set the mass wf flag
             ---------------------------
             UPDATE pa_project_assignments
             SET    mass_wf_in_progress_flag = 'N'
             WHERE  assignment_id = l_assignment_id_tbl(i);

             l_assignment_id_tbl(i) := NULL;
        WHEN OTHERS THEN
            RAISE;
    END;

    END LOOP; --end i loop for all assignments for this mass transaction

    log_message('After populating pa_wf_ntf_performers');

    -----------------------------------------------------------------------------------------
    /*FOR each distinct approver one in PA_WF_NTF_PERFORMERS belonging
      to mass transaction group l_group_id
      update the approver_group_id in PA_WF_NTF_PERFORMERS for these assignments with a
      new sequence value.  Store this value in l_approver_group_id
      The l_approver_group_id is the approver transaction id which is used
      in grouping and sending approval required notifications for the next (second) set of approvers.
      Approver group id is used in grouping the approvers in the next routing order
     */
    -----------------------------------------------------------------------------------------
    FOR rec IN distinct_approvers LOOP

        SELECT PA_WF_NTF_PERFORMERS_S.nextval
        INTO   l_approver_group_id
        FROM   dual;

        UPDATE pa_wf_ntf_performers
        SET    approver_group_id = l_approver_group_id
        WHERE  group_id          = l_group_id
        AND    user_name         = rec.user_name
        AND    routing_order     = 1;

        ----------------------------------------------------------
        --Call API to start one workflow for each grouped approver
        ----------------------------------------------------------

        log_message('Before Calling workflow for group_id, approver_group_id:' || l_group_id||','||l_approver_group_id);

        PA_ASGMT_WFSTD.start_mass_approval_flow
            (p_project_id           => p_project_id
            ,p_mode                 => p_mode
            ,p_note_to_approvers    => p_note_to_all_approvers
            ,p_forwarded_from       => null
            ,p_performer_user_name  => rec.user_name
            ,p_routing_order        => 1
            ,p_group_id             => l_group_id
            ,p_approver_group_id    => l_approver_group_id
            ,p_update_info_doc      => p_update_info_doc
            ,p_project_name         => l_projects_rec.name
            ,p_project_number       => l_projects_rec.segment1
            ,p_project_manager      => l_project_manager_name
            ,p_project_org          => l_projects_rec.organization_name
            ,p_project_cus          => l_customer_name
            ,p_submitter_user_name  => l_submitter_user_name
            ,p_conflict_group_id    => p_conflict_group_id
            ,x_return_status        => l_return_status
            ,x_msg_count            => l_msg_count
            ,x_msg_data             => l_msg_data);

         l_error_flag := 'N';

        log_message('After Calling workflow for group_id, approver_group_id:' || l_group_id||','||l_approver_group_id);

    END LOOP;--end loop distinct approvers

    -------------------------------------------------------
    --Getting number of approved and rejected assignments
    -------------------------------------------------------
    BEGIN

        SELECT count(*)
        INTO   l_num_apr_asgns
        FROM   pa_wf_ntf_performers ntf,
               pa_project_assignments asgn
        WHERE  ntf.group_id      = l_group_id
        AND    ntf.routing_order = 1
        AND    ntf.object_id1    = asgn.assignment_id
        AND    asgn.apprvl_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_approved ;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            null;
        WHEN OTHERS THEN
            RAISE;
    END;

    BEGIN

        SELECT count(*)
        INTO   l_num_rej_asgns
        FROM   pa_wf_ntf_performers ntf,
               pa_project_assignments asgn
        WHERE  ntf.group_id      = l_group_id
        AND    ntf.routing_order = 1
        AND    ntf.object_id1    = asgn.assignment_id
        AND    asgn.apprvl_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_rejected ;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            null;
        WHEN OTHERS THEN
            RAISE;
    END;

    ---------------------------------------
    --Getting number of errored assignments
    --------------------------------------
    BEGIN
        SELECT count( distinct ( attribute2))
        INTO   l_error_count
        FROM   PA_REPORTING_EXCEPTIONS
        WHERE  context            = PA_MASS_ASGMT_TRX.G_SOURCE_TYPE1
        AND    sub_context        = 'MASS_APPROVAL'
        AND    source_identifier1 = 'PAWFAAP'
        AND    source_identifier2 = l_group_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_error_count := 0;
        WHEN OTHERS THEN
            RAISE;
    END;

    -------------------------------------------------------
    --If No assignment was sumbitted (l_error_flag = Y) but
    --some assignments were auto approved then the
    --Managers must get notifications
    -------------------------------------------------------
    IF l_error_flag = 'Y' AND (l_num_apr_asgns > 0) THEN

        --Start Manager Notifications
        log_message('Calling mgr fyi notification');

        BEGIN

            --Get all assignments in this mass transaction
            --which have been approved
            SELECT ntf.object_id1
            BULK COLLECT INTO l_appr_asgmt_id_tbl
            FROM   pa_wf_ntf_performers ntf,
                   pa_project_assignments asgn
            WHERE  ntf.group_id            = l_group_id
            AND    ntf.routing_order       = 1
            AND    ntf.object_id1          = asgn.assignment_id
            AND    asgn.apprvl_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_approved ;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                null;
        END;

        PA_ASGMT_WFSTD.process_mgr_fyi_notification
            ( p_assignment_id_tbl   => l_appr_asgmt_id_tbl
             ,p_project_id          => p_project_id
             ,p_mode                => p_mode
             ,p_group_id            => l_group_id
             ,p_update_info_doc     => p_update_info_doc
             ,p_num_apr_asgns       => l_num_apr_asgns
             ,p_num_rej_asgns       => l_num_rej_asgns
             ,p_project_name        => l_projects_rec.name
             ,p_project_number      => l_projects_rec.segment1
             ,p_project_manager     => l_project_manager_name
             ,p_project_org         => l_projects_rec.organization_name
             ,p_project_cus         => l_customer_name
             ,p_submitter_user_name => l_submitter_user_name
             ,p_conflict_group_id   => p_conflict_group_id
             ,x_return_status       => l_return_status
             ,x_msg_count           => l_msg_count
             ,x_msg_data            => l_msg_data);

         log_message('Calling overcom_post_aprvl_processing');

        ------------------------------------------------------------------
        --This API is called to send notifications to conflicting managers
        ------------------------------------------------------------------
        PA_SCHEDULE_PVT.overcom_post_aprvl_processing
                        ( p_conflict_group_id   => p_conflict_group_id
                         ,p_fnd_user_name       => l_submitter_user_name
                         ,x_return_status       => l_return_status
                         ,x_msg_count           => l_msg_count
                         ,x_msg_data            => l_msg_data);

    END IF;

    -----------------------------------------------------------------------------------
    --The error flag by default is Y. It is changed to N if any assignment is submitted
    --in which case notification to submitter will be handled in mass approve flow
    -----------------------------------------------------------------------------------
    IF l_error_count > 0 AND l_error_flag = 'Y' THEN
        l_error_flag := 'Y';
    END IF;

    log_message('Count of failed assignments:' || l_error_count);

    -----------------------------------------------------------------------
    --The codebelow  processes the submitter notifcations when all assignments
    --fail submission or
    --if there are erorrs and some auto-approved assignments but none
    --was submitted. In other words if the mass approval transaction completes
    --and there were errors after the submit process the FYI error notification
    --is sent to submitter
    -----------------------------------------------------------------------
    IF l_error_flag = 'Y' THEN --Submission failed for all assignments.

       log_message('Submission Failed');

       log_message('Calling submitter notification');

       PA_ASGMT_WFSTD.process_submitter_notification
                (p_project_id          => p_project_id
                ,p_mode                => p_mode
                ,p_group_id            => l_group_id
                ,p_update_info_doc     => p_update_info_doc
                ,p_num_apr_asgns       => l_num_apr_asgns
                ,p_num_rej_asgns       => l_num_rej_asgns
                ,p_project_name        => l_projects_rec.name
                ,p_project_number      => l_projects_rec.segment1
                ,p_project_manager     => l_project_manager_name
                ,p_project_org         => l_projects_rec.organization_name
                ,p_project_cus         => l_customer_name
                ,p_submitter_user_name => l_submitter_user_name
                ,p_assignment_id       => p_assignment_id_tbl(1)
                ,x_return_status       => l_return_status
                ,x_msg_count           => l_msg_count
                ,x_msg_data            => l_msg_data);

    END IF;

    -- IF the number of messages is 1 then fetch the message code from
    -- the stack and return its text
    x_msg_count :=  FND_MSG_PUB.Count_Msg;

    IF x_msg_count = 1 THEN
        pa_interface_utils_pub.get_messages
            ( p_encoded       => FND_API.G_TRUE
             ,p_msg_index     => 1
             ,p_data          => x_msg_data
             ,p_msg_index_out => l_msg_index_out );
    END IF;

    -- Reset the error stack when returning to the calling program
    PA_DEBUG.Reset_Err_Stack;

    -- If g_error_exists is TRUE then set the x_return_status to 'E'
    IF FND_MSG_PUB.Count_Msg >0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

EXCEPTION
    WHEN NO_WORKFLOW_EXCEPTION THEN
        --TODO: Check
        x_return_status := FND_API.G_RET_STS_SUCCESS;

    WHEN INVALID_STATUS THEN

        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO  MASS_ASGN_APPRVL;
        END IF;

         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PUB.mass_assignment_approval'
              ,p_procedure_name => PA_DEBUG.G_Err_Stack );

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;

    WHEN OTHERS THEN

        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO  MASS_ASGN_APPRVL;
        END IF;

         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PUB.mass_assignment_approval'
              ,p_procedure_name => PA_DEBUG.G_Err_Stack );

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;
END mass_assignment_approval;

---------------------------------------------------------
--This API is called from the mass approve page
--It starts a worflow to process the approval result
--as a deferred activity
--Workflow Itemtype: PARMAAP
--Workflow process : 'PA_MASS_PROCESS_APRVL_RESULT'
---------------------------------------------------------
PROCEDURE mass_process_approval_result
    ( p_project_id                  IN    pa_project_assignments.project_id%TYPE   := FND_API.G_MISS_NUM
     ,p_mode                        IN    VARCHAR2
     ,p_assignment_id_tbl           IN    SYSTEM.pa_num_tbl_type             := prm_empty_num_tbl
     ,p_approval_status_tbl         IN    SYSTEM.pa_varchar2_30_tbl_type     := prm_empty_varchar2_30_tbl
     ,p_group_id                    IN    NUMBER
     ,p_approver_group_id           IN    NUMBER
     ,p_routing_order               IN    NUMBER
     ,p_item_key                    IN    NUMBER
     ,p_notification_id             IN    NUMBER
     ,p_submitter_user_name         IN    VARCHAR2
     ,p_conflict_group_id           IN    NUMBER                       := FND_API.G_MISS_NUM
     ,p_api_version                 IN    NUMBER                       := 1.0
     ,p_init_msg_list               IN    VARCHAR2                     := FND_API.G_TRUE
     ,p_max_msg_count               IN    NUMBER                       := FND_API.G_MISS_NUM
     ,p_commit                      IN    VARCHAR2                     := FND_API.G_FALSE
     ,p_validate_only               IN    VARCHAR2                     := FND_API.G_TRUE
     ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                   OUT   NOCOPY NUMBER         --File.Sql.39 bug 4440895
     ,x_msg_data                    OUT   NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
)
IS

    l_itemkey             VARCHAR2(30);
    l_responsibility_id   NUMBER;
    l_resp_appl_id        NUMBER;
    l_wf_started_date     DATE;
    l_wf_started_by_id    NUMBER;
    l_return_status       VARCHAR2(1);
    l_error_message_code  VARCHAR2(30);
    l_save_threshold      NUMBER;
    l_msg_count           NUMBER ;
    l_msg_index_out           NUMBER ;
    l_msg_data            VARCHAR2(2000);
    l_wf_item_type        VARCHAR2(2000):= 'PARMAAP'; --Assignment Approval Item type
    l_wf_process          VARCHAR2(2000):= 'PA_MASS_PROCESS_APRVL_RESULT'; --Mass Assignment Approval process
    l_err_code                    NUMBER := 0;
    l_err_stage                   VARCHAR2(2000);
    l_err_stack                   VARCHAR2(2000);
    l_text_attr_name_tbl  Wf_Engine.NameTabTyp;
    l_text_attr_value_tbl Wf_Engine.TextTabTyp;
    l_num_attr_name_tbl   Wf_Engine.NameTabTyp;
    l_num_attr_value_tbl  Wf_Engine.NumTabTyp;
    l_update_info_doc     VARCHAR2(32767);
    l_note_to_approvers   VARCHAR2(2000);
    l_forwarded_from       fnd_user.user_name%TYPE;  /* Commented for bug 3261755 VARCHAR2(30); */

BEGIN

     -- Initialize the Error Stack
    PA_DEBUG.init_err_stack('PA_ASSIGNMENT_APPROVAL_PUB.mass_process_approval_result');

    log_message('Inside  mass_process_approval_result');

    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN
    PA_DEBUG.write_log
        ( x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.mass_process_approval_result.begin'
         ,x_msg         => 'Beginning of mass_assignment_approval'
         ,x_log_level   => 1);
    END IF;

    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Clear the global PL/SQL message table
    FND_MSG_PUB.initialize;

    -- Issue API savepoint if the transaction is to be committed
    IF p_commit  = FND_API.G_TRUE THEN
        SAVEPOINT   MASS_APPRVL_RESULT;
    END IF;

    --------------------------------------------------------
    --Update object_id2 column to 100 for these assignments
    --in pa_wf_ntf_performers table to differentiate
    --between assignments for which user has aproved/rejected
    --and those for which notification is pending
    ---------------------------------------------------------
    UPDATE pa_wf_ntf_performers
    SET    object_id2    = 100
    where  group_id      = p_group_id
    and    routing_order = p_routing_order
    and    approver_group_id = p_approver_group_id;

    -----------------------------------------------
    -- Create the unique item key to launch WF with
    -----------------------------------------------
    SELECT pa_prm_wf_item_key_s.nextval
    INTO   l_itemkey
    FROM   dual;

    l_wf_started_by_id  := FND_GLOBAL.user_id;
    l_responsibility_id := FND_GLOBAL.resp_id;
    l_resp_appl_id      := FND_GLOBAL.resp_appl_id;

    FND_GLOBAL.Apps_Initialize ( user_id      => l_wf_started_by_id
                               , resp_id      => l_responsibility_id
                               , resp_appl_id => l_resp_appl_id );

    -- Setting thresold value to run the process in background
    l_save_threshold    := wf_engine.threshold;
    wf_engine.threshold := -1;

     -- Create the WF process
    wf_engine.CreateProcess
        ( ItemType => l_wf_item_type
        , ItemKey  => l_itemkey
        , process  => l_wf_process );


    ------------------------------------------------------------
    --Creating the attribute arrays from assignment id table and
    --Status table
    ------------------------------------------------------------
    IF p_assignment_id_tbl.COUNT > 0 THEN

        log_message('Creating assignment attributes');

        FOR i IN p_assignment_id_tbl.FIRST .. p_assignment_id_tbl.LAST LOOP

            l_num_attr_name_tbl( l_num_attr_name_tbl.COUNT+1 )  := 'ASSIGNMENT_' || i;
            l_num_attr_value_tbl( l_num_attr_value_tbl.COUNT+1 ):= p_assignment_id_tbl(i);

        END LOOP;

    END IF;

    IF p_approval_status_tbl.COUNT > 0 THEN

        log_message('Creating status  attributes');

        FOR i IN p_approval_status_tbl.FIRST .. p_approval_status_tbl.LAST LOOP

            l_text_attr_name_tbl( l_text_attr_name_tbl.COUNT+1 )  := 'STATUS_' || i;
            l_text_attr_value_tbl( l_text_attr_value_tbl.COUNT+1 ):= p_approval_status_tbl(i);

        END LOOP;

    END IF;

    -----------------------------------------------------------------
    --Set all the required workflow attributes and start the workflow
    -----------------------------------------------------------------
    wf_engine.SetItemAttrNumber
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'PROJECT_ID'
        , avalue   => p_project_id  );

    wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'MODE'
        , avalue   => p_mode  );

    --Setting Assignment Ids
    wf_engine.AddItemAttrNumberArray
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => l_num_attr_name_tbl
        , avalue   => l_num_attr_value_tbl );

    --Setting Status table
    wf_engine.AddItemAttrTextArray
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => l_text_attr_name_tbl
        , avalue   => l_text_attr_value_tbl );

    wf_engine.SetItemAttrNumber
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'GROUP_ID'
        , avalue   => p_group_id  );

    wf_engine.SetItemAttrNumber
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'APPROVER_GROUP_ID'
        , avalue   => p_approver_group_id  );

    wf_engine.SetItemAttrNumber
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'ROUTING_ORDER'
        , avalue   => p_routing_order  );

    wf_engine.SetItemAttrNumber
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'NUMBER_OF_ASSIGNMENTS'
        , avalue   => p_assignment_id_tbl.COUNT  );

    --Get and set the Update info document
    l_update_info_doc := wf_engine.getItemAttrDocument
                          ( itemtype => 'PAWFAAP'
                          , itemkey  => p_item_key
                          , aname    => 'UPDATED_INFO_DOC' );

    wf_engine.SetItemAttrDocument
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'UPDATED_INFO_DOC'
        , documentid   => l_update_info_doc  );

    wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'SUBMITTER_UNAME'
        , avalue   => p_submitter_user_name  );

    wf_engine.SetItemAttrNumber
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'CONFLICT_GROUP_ID'
        , avalue   => p_conflict_group_id  );

    --Set the previous approver (forwarded from and note to approvers)
    l_forwarded_from := wf_engine.getItemAttrText
                                  ( itemtype => 'PAWFAAP'
                                  , itemkey  => p_item_key
                                  , aname    => 'NTFY_APPRVL_RECIPIENT_NAME');

    l_note_to_approvers := wf_engine.getItemAttrText
                                  ( itemtype => 'PAWFAAP'
                                  , itemkey  => p_item_key
                                  , aname    => 'NOTE_TO_APPROVER');

    wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'NTFY_APPRVL_RECIPIENT_NAME'
        , avalue   => l_forwarded_from  );

    wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'NOTE_TO_APPROVER'
        , avalue   =>  l_note_to_approvers );

    -------------------------------
    --Start the workflow process
    -------------------------------
    wf_engine.StartProcess ( itemtype => l_wf_item_type
                            ,itemkey  => l_itemkey );

    PA_WORKFLOW_UTILS.Insert_WF_Processes
        (p_wf_type_code        => 'MASS_ASSIGNMENT_APPROVAL'
        ,p_item_type           => l_wf_item_type
        ,p_item_key            => l_itemkey
        ,p_entity_key1         => to_char(p_project_id)
        ,p_entity_key2         => to_char(p_group_id)
        ,p_description         => NULL
        ,p_err_code            => l_err_code
        ,p_err_stage           => l_err_stage
        ,p_err_stack           => l_err_stack );

    --Setting the original value
    wf_engine.threshold := l_save_threshold;

    log_message('Exiting  mass_process_approval_result');

EXCEPTION
     WHEN OTHERS THEN

         IF p_commit = FND_API.G_TRUE THEN
             ROLLBACK TO  MASS_APPRVL_RESULT;
         END IF;

         --Setting the original value
         wf_engine.threshold := l_save_threshold;

         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PUB.mass_process_approval_result'
              ,p_procedure_name => PA_DEBUG.G_Err_Stack );

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;
END mass_process_approval_result;

----------------------------------------------------
--This procedure validates the approvers name and id
--It is called in mass_assignment_approval API
----------------------------------------------------
/* Added a new parameter p_overriding_authority_flag for the bug 3213509*/
PROCEDURE validate_approver_name_id
    ( p_project_id                  IN    NUMBER
     ,p_assignment_id_tbl           IN    SYSTEM.pa_num_tbl_type           := prm_empty_num_tbl
     ,p_approver1_id_tbl            IN    SYSTEM.pa_num_tbl_type           := prm_empty_num_tbl
     ,p_approver1_name_tbl          IN    SYSTEM.pa_varchar2_240_tbl_type  := prm_empty_varchar2_240_tbl
     ,p_approver2_id_tbl            IN    SYSTEM.pa_num_tbl_type           := prm_empty_num_tbl
     ,p_approver2_name_tbl          IN    SYSTEM.pa_varchar2_240_tbl_type  := prm_empty_varchar2_240_tbl
     ,p_submitter_user_id           IN    NUMBER
     ,p_group_id                    IN    NUMBER
     ,p_api_version                 IN    NUMBER                           := 1.0
     ,p_init_msg_list               IN    VARCHAR2                         := FND_API.G_TRUE
     ,p_max_msg_count               IN    NUMBER                           := FND_API.G_MISS_NUM
     ,p_commit                      IN    VARCHAR2                         := FND_API.G_FALSE
     ,p_validate_only               IN    VARCHAR2                         := FND_API.G_TRUE
     ,p_overriding_authority_flag   IN    VARCHAR2                         := 'N'
     ,x_assignment_id_tbl           OUT   NOCOPY SYSTEM.pa_num_tbl_type
     ,x_approver1_id_tbl            OUT   NOCOPY SYSTEM.pa_num_tbl_type
     ,x_approver2_id_tbl            OUT   NOCOPY SYSTEM.pa_num_tbl_type
     ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                   OUT   NOCOPY NUMBER         --File.Sql.39 bug 4440895
     ,x_msg_data                    OUT   NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
)
IS

    l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_error_message_code          fnd_new_messages.message_name%TYPE;
    l_assignment_start_date       DATE;
    l_approver1_person_id         NUMBER;
    l_approver1_person_name       VARCHAR2(200);
    l_approver2_person_id         NUMBER;
    l_approver2_person_name       VARCHAR2(200);
    l_resource_type_id            NUMBER;--Used in Name ID validation
    l_msg_index_out               NUMBER;
    l_resource_id                 NUMBER;

BEGIN

     -- Initialize the Error Stack
    PA_DEBUG.init_err_stack('PA_ASSIGNMENT_APPROVAL_PUB.validate_approver_name_id');

    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN
    PA_DEBUG.write_log
        ( x_module      => 'pa.plsql.PA_ASSIGNMENT_APPROVAL_PUB.validate_approver_name_id.begin'
         ,x_msg         => 'Beginning of approver name id validation'
         ,x_log_level   => 1);
    END IF;

    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Clear the global PL/SQL message table
    FND_MSG_PUB.initialize;

    -- Issue API savepoint if the transaction is to be committed
    IF p_commit  = FND_API.G_TRUE THEN
        SAVEPOINT   MASS_APPRVL_VALIDATE_NAMEID;
    END IF;

    log_message('Group id:' || p_group_id);
    log_message('Value of submitter user id:' || p_submitter_user_id);

    x_approver1_id_tbl := prm_empty_num_tbl;
    x_approver2_id_tbl := prm_empty_num_tbl;
    x_assignment_id_tbl := prm_empty_num_tbl;

    x_approver1_id_tbl.EXTEND( p_assignment_id_tbl.COUNT);
    x_approver2_id_tbl.EXTEND( p_assignment_id_tbl.COUNT);
    x_assignment_id_tbl.EXTEND( p_assignment_id_tbl.COUNT);

    ---------------------------------------------------------
    --Name to ID validation for approvers of each assignment
    --The above must be done for both the approvers
    ---------------------------------------------------------
    IF p_assignment_id_tbl.COUNT > 0 THEN



        FOR i IN p_assignment_id_tbl.FIRST .. p_assignment_id_tbl.LAST LOOP

            log_message('Loop:' || i);

            --Initialize locals to null before every loop
            l_approver1_person_id := null;
            l_approver1_person_name := null;
            l_approver2_person_id := null;
            l_approver2_person_name := null;

            --Get the assignment start date
            SELECT start_date
            INTO   l_assignment_start_date
            FROM   pa_project_assignments
            WHERE  assignment_id = p_assignment_id_tbl(i);

            IF p_approver1_id_tbl.EXISTS(i) THEN
                IF p_approver1_id_tbl(i) <> -999 THEN
                    l_approver1_person_id := p_approver1_id_tbl(i);
                    log_message('Person_id1:' || l_approver1_person_id);
                END IF;
            END IF;

            IF p_approver1_name_tbl.EXISTS(i) THEN
                l_approver1_person_name  := p_approver1_name_tbl(i);
                log_message('Person_Name1:' || l_approver1_person_name);
            END IF;

            IF p_approver2_id_tbl.EXISTS(i) THEN

                IF p_approver2_id_tbl(i) <> -999 THEN
                   l_approver2_person_id := p_approver2_id_tbl(i);
                   log_message('Person_id2:' || l_approver2_person_id);
                END IF;

            END IF;

            IF p_approver2_name_tbl.EXISTS(i) THEN
                l_approver2_person_name  := p_approver2_name_tbl(i);
                log_message('Person_Name2:' || l_approver2_person_name);
            END IF;

            -----------------------------------------------------------------
            --If there are no approvers for this assignment then signal error
            -----------------------------------------------------------------\
              /* Added the check for the bug 3213509*/
          IF p_overriding_authority_flag = 'N' then
            IF ( l_approver1_person_id IS NULL AND l_approver1_person_name IS NULL
                                               AND l_approver2_person_id IS NULL
                                               AND l_approver2_person_name IS NULL )
            THEN
                log_message('No Approvers for Loop:' || i);

                l_error_message_code :=  'PA_RESOURCE_NO_APPROVAL';
                PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                     ,p_msg_name       => l_error_message_code);

            END IF;
          END IF;
            ---------------------
            --Validate approvers
            ---------------------
            IF ( l_approver1_person_id IS NOT NULL OR
                 l_approver1_person_name IS NOT NULL )
            THEN

               log_message('Before calling check_resourcename_or_id  for Approver1 Loop:' || i);

                PA_RESOURCE_UTILS.Check_ResourceName_OR_ID (
                    p_resource_id         => l_approver1_person_id
                   ,p_resource_name       => l_approver1_person_name
                   ,p_check_id_flag       => PA_STARTUP.G_Check_ID_Flag
                   ,p_date                => l_assignment_start_date
                   ,x_resource_id         => x_approver1_id_tbl (i)
                   ,x_resource_type_id    => l_resource_type_id
                   ,x_return_status       => l_return_status
                   ,x_error_message_code  => l_error_message_code );

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                         ,p_msg_name       => l_error_message_code);
                END IF;

                log_message('After calling check_resourcename_or_id  for Approver1 Loop:' || i);
                log_message('Person_id:' || x_approver1_id_tbl (i));
                log_message('Return Status:' || l_return_status);
                log_message('Error:' || l_error_message_code);

                --x_approver1_id_tbl (i) := l_approver1_person_id;

            END IF;

            IF ( l_approver2_person_id IS NOT NULL OR
                 l_approver2_person_name IS NOT NULL )
            THEN

                log_message('Before calling check_resourcename_or_id  for Approver2 Loop:' || i);
                log_message('Check Id flag: ' || PA_STARTUP.G_Check_ID_Flag);

                PA_RESOURCE_UTILS.Check_ResourceName_OR_ID (
                    p_resource_id         => l_approver2_person_id
                   ,p_resource_name       => l_approver2_person_name
                   ,p_check_id_flag       => PA_STARTUP.G_Check_ID_Flag
                   ,p_date                => l_assignment_start_date
                   ,x_resource_id         => x_approver2_id_tbl (i)
                   ,x_resource_type_id    => l_resource_type_id
                   ,x_return_status       => l_return_status
                   ,x_error_message_code  => l_error_message_code);

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                         ,p_msg_name       => l_error_message_code);
                END IF;

                log_message('After calling check_resourcename_or_id  for Approver2 Loop:' || i);
                log_message('Person_id:' || x_approver2_id_tbl (i));
                log_message('Person Name:' || l_approver2_person_name);
                log_message('Return Status:' || l_return_status);
                log_message('Error:' || l_error_message_code);

                --x_approver2_id_tbl (i) := l_approver2_person_id;

            END IF;

            log_message('COUNT of message stack:' || FND_MSG_PUB.Count_Msg);

            -------------------------------------------
            --Populate x_success_assignment_id_tbl
            -------------------------------------------
            IF FND_MSG_PUB.Count_Msg > 0 THEN

                --Setting pending approval flag in pa_project_assignments
                PA_ASGMT_WFSTD.Maintain_wf_pending_flag
                    (p_assignment_id => p_assignment_id_tbl(i),
                     p_mode          => 'APPROVAL_PROCESS_COMPLETED') ;

                ---------------------------
                --Set the mass wf flag
                ---------------------------
                UPDATE pa_project_assignments
                SET    mass_wf_in_progress_flag = 'N'
                WHERE  assignment_id = p_assignment_id_tbl(i);

                x_assignment_id_tbl (i) := null;
            ELSE
                x_assignment_id_tbl (i) := p_assignment_id_tbl (i);
            END IF;

            IF FND_MSG_PUB.Count_Msg > 0 THEN

                SELECT resource_id
                INTO   l_resource_id
                FROM   pa_project_assignments
                WHERE  assignment_id = p_assignment_id_tbl(i);

                log_message('Value of submitter user id:' || p_submitter_user_id);

                PA_MESSAGE_UTILS.save_messages
                   (p_user_id            =>  p_submitter_user_id,
                    p_source_type1       =>  PA_MASS_ASGMT_TRX.G_SOURCE_TYPE1,
                    p_source_type2       =>  'MASS_APPROVAL',
                    p_source_identifier1 =>  'PAWFAAP',
                    p_source_identifier2 =>  p_group_id,
                    p_context1           =>  p_project_id,
                    p_context2           =>  p_assignment_id_tbl(i),
                    p_context3           =>  l_resource_id,
                    p_commit             =>  FND_API.G_FALSE,
                    x_return_status      =>  l_return_status);

            END IF;

        END LOOP;--end i loop

    END IF; --end name validations for all assignments

EXCEPTION
    WHEN OTHERS THEN

         IF p_commit = FND_API.G_TRUE THEN
             ROLLBACK TO  MASS_APPRVL_VALIDATE_NAMEID;
         END IF;

         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_ASSIGNMENT_APPROVAL_PUB.validate_approver_name_id'
              ,p_procedure_name => PA_DEBUG.G_Err_Stack );

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;
END validate_approver_name_id;


END PA_ASSIGNMENT_APPROVAL_PUB;

/

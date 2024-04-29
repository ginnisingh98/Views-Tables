--------------------------------------------------------
--  DDL for Package Body PA_ASGMT_WFSTD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ASGMT_WFSTD" AS
--  $Header: PAWFAAPB.pls 120.13.12010000.11 2009/09/10 12:23:31 jravisha ship $
-- forward declarations
--------------------------------------------------------------------------------------------------------------
-- This procedure prints the text which is being passed as the input
-- Input parameters
-- Parameters                   Type           Required  Description
--  p_log_msg                   VARCHAR2        YES      It stores text which you want to print on screen
-- Out parameters
----------------------------------------------------------------------------------------------------------------
PROCEDURE log_message (p_log_msg IN VARCHAR2)
IS
BEGIN
    --dbms_output.put_line('Log : ' || p_log_msg);
        NULL;
END log_message;

PROCEDURE Capture_approver_response (p_item_type IN VARCHAR2,
                                     p_item_key  IN VARCHAR2) ;

PROCEDURE Set_Nf_Error_Msg_Attr (p_item_type IN VARCHAR2,
                     p_item_key  IN VARCHAR2,
                 p_msg_count IN NUMBER,
                 p_msg_data IN VARCHAR2 ) ;
PROCEDURE get_primary_contact_info
                           (p_resource_id  IN NUMBER
                          , p_assignment_id IN NUMBER
                          , p_approver1_person_id IN NUMBER
                          , p_approver1_type IN      VARCHAR2
                          , p_approver2_person_id IN NUMBER
                          , p_approver2_type IN      VARCHAR2
                          , x_PrimaryContactId     OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895

PROCEDURE populate_wf_performers
    ( p_wf_type_code IN VARCHAR2
     ,p_item_type    IN VARCHAR2
     ,p_item_key     IN VARCHAR2
     ,p_object_id1  IN VARCHAR2
     ,p_object_id2  IN VARCHAR2
     ,p_in_performers_tbl PA_CLIENT_EXTN_ASGMT_WF.Users_List_Tbltyp
     ,p_current_approver_flag  IN VARCHAR2
     ,x_number_of_performers OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895

PROCEDURE get_wf_performer (p_wf_type_code IN VARCHAR2,
                p_item_type    IN VARCHAR2,
                p_item_key     IN VARCHAR2,
                p_routing_order IN NUMBER,
                    p_object_id1  IN VARCHAR2 ,
                x_performer_name OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                x_performer_type OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE Set_approver_comments (p_apprvl_item_type VARCHAR2,
                 p_apprvl_item_key  VARCHAR2,
                 p_item_type  VARCHAR2,
                 p_item_key  VARCHAR2,
                 p_assignment_id NUMBER ) ;

PROCEDURE Set_Comment_Attributes (p_item_type IN VARCHAR2,
                          p_item_key  IN VARCHAR2,
                  p_rect_type IN VARCHAR2 );

/*PROCEDURE Check_And_Get_Proj_Customer ( p_project_id IN NUMBER
                       ,x_customer_id OUT NUMBER
                       ,x_customer_name OUT VARCHAR2 );*/

PROCEDURE   Set_NF_Subject_and_Desc  (p_item_type       IN VARCHAR2,
                      p_item_key        IN VARCHAR2,
                      p_assignment_type IN VARCHAR2,
                      p_reapproval_flag IN VARCHAR2,
                      p_msg_type        IN VARCHAR2 );

-- end forward declarations

PROCEDURE Start_Workflow (  p_project_id           IN NUMBER DEFAULT NULL
                          , p_assignment_id        IN NUMBER
              , p_status_code          IN VARCHAR2 DEFAULT NULL
                          , p_person_id            IN NUMBER DEFAULT NULL
                          , p_wf_item_type         IN VARCHAR2
                          , p_wf_process           IN VARCHAR2
              , p_approver1_person_id  IN NUMBER DEFAULT NULL
              , p_approver1_type       IN VARCHAR2 DEFAULT NULL
              , p_approver2_person_id  IN NUMBER DEFAULT NULL
              , p_approver2_type       IN VARCHAR2  DEFAULT NULL
              , p_apprvl_item_type     IN VARCHAR2 DEFAULT NULL
              , p_apprvl_item_key      IN VARCHAR2 DEFAULT NULL
                          , p_conflict_group_id    IN NUMBER DEFAULT NULL
              , x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
              , x_msg_data             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              , x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              , x_error_message_code   OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

CURSOR l_assignments_csr IS
SELECT ppa.assignment_id,
       ppa.assignment_name,
       ppa.assignment_effort,
       ppa.additional_information,
       ppa.description,
       ppa.note_to_approver,
       ppa.project_id,
       ppa.resource_id,
       ppa.start_date,
       ppa.end_date,
       ppa.status_code,
       ppa.apprvl_status_code,
       ppa.pending_approval_flag,
       ppa.assignment_type,
       ppa.revenue_bill_rate,
       ppa.revenue_currency_code,
       ppa.bill_rate_override,
       ppa.bill_rate_curr_override,
       ppa.markup_percent_override,
       ppa.fcst_tp_amount_type_name,
       ppa.tp_rate_override,
       ppa.tp_currency_override,
       ppa.tp_calc_base_code_override,
       ppa.tp_percent_applied_override,
       ppa.work_type_name,
       ppa.transfer_price_rate,   --  Added for bug 3051110
       ppa.transfer_pr_rate_curr
FROM pa_project_assignments_v ppa
WHERE assignment_id = p_assignment_id;

CURSOR csr_get_override_basis_name (p_override_basis_code IN VARCHAR2) IS
SELECT plks.meaning
FROM   pa_lookups plks
WHERE  plks.lookup_type = 'CC_MARKUP_BASE_CODE'
AND    plks.lookup_code = p_override_basis_code;

CURSOR l_stus_csr (c_status_code IN VARCHAR2) IS
SELECT ps.wf_success_status_code,
       ps.wf_failure_status_code,
       ps.project_status_name
FROM   pa_project_statuses ps
WHERE  project_status_code = c_status_code;

CURSOR l_resource_csr(l_resource_id IN NUMBER, p_start_date IN DATE) IS
SELECT per.full_name resource_name,
       rta.person_id resource_person_id,
       rta.resource_id resource_id,
       hou.name resource_organization_name,
       assign.supervisor_id manager_id
FROM   per_all_people_f per,
       per_all_assignments_f assign,
       hr_all_organization_units hou,
       pa_resource_txn_attributes rta
WHERE  rta.resource_id = l_resource_id
AND    rta.person_id = per.person_id
AND    rta.person_id = assign.person_id
AND    assign.primary_flag = 'Y'
AND    assign.assignment_type in ('E','C')
AND    hou.organization_id = assign.organization_id
AND    trunc(p_start_date) BETWEEN assign.effective_start_date AND assign.effective_end_date /*bug 8817301 */
AND    trunc(p_start_date) BETWEEN per.effective_start_date AND per.effective_end_date  /*bug 8817301 */ /* 2983985 - Added this condition */
;


CURSOR l_projects_csr(l_project_id IN NUMBER) IS
SELECT pap.project_id project_id,
       pap.name name,
       pap.segment1 segment1,
       pap.carrying_out_organization_id carrying_out_organization_id,
       pap.location_id,
       hr.name organization_name,
       NVL(pt.administrative_flag,'N') admin_flag
FROM pa_projects_all pap,
     hr_all_organization_units hr,
     pa_project_types_all pt
WHERE pap.project_id = l_project_id
AND   pap.carrying_out_organization_id =
      hr.organization_id
AND   pap.org_id = pt.org_id    -- Added for Bug 5389093
AND   pt.project_type = pap.project_type;

/* Commenting Below and changing cursor query for bug 7640483
CURSOR l_prev_asgmt_info_csr (l_assignment_id IN NUMBER)
IS
SELECT assignment_effort prev_effort,
      (trunc(end_date) -
      (trunc(start_date)+1)) prev_duration
FROM pa_assignments_history
WHERE assignment_id = l_assignment_id
AND   nvl(last_approved_flag,'N') = 'Y';
*/

CURSOR l_prev_asgmt_info_csr (l_assignment_id IN NUMBER)
IS
SELECT assignment_effort prev_effort,
      (trunc(end_date) - trunc(start_date) + 1) prev_duration
FROM pa_assignments_history
WHERE assignment_id = l_assignment_id
AND   nvl(last_approved_flag,'N') = 'Y';

l_assignments_rec l_assignments_csr%ROWTYPE;
l_resource_rec l_resource_csr%ROWTYPE;
l_projects_rec l_projects_csr%ROWTYPE;
l_prev_asgmt_info_rec l_prev_asgmt_info_csr%ROWTYPE;
l_asgmt_details_url      VARCHAR2(600);
l_resource_details_url   VARCHAR2(600);
l_resource_schedules_url VARCHAR2(600);
l_itemkey  VARCHAR2(30);
l_responsibility_id       NUMBER;
l_resp_appl_id            NUMBER;
l_wf_started_date         DATE;
l_wf_started_by_id        NUMBER;
l_wf_started_by_full_name     per_people_f.full_name%TYPE;
l_wf_started_by_email_address per_people_f.email_address%TYPE;
l_wf_started_by_username      fnd_user.user_name%TYPE;
l_display_name        wf_users.display_name%TYPE; ---- VARCHAR2(200); Changed for bug 3267790
l_project_manager_person_id  NUMBER ;
l_project_manager_name    per_all_people_f.full_name%TYPE;  ---- VARCHAR2(200);  Changed for bug 3267790
l_project_manager_uname   wf_users.name%TYPE;        ---- VARCHAR2(200); Changed for bug 3267790
l_project_party_id        NUMBER ;
l_project_role_id         NUMBER ;
l_project_role_name       pa_project_role_types.meaning%TYPE; ---- VARCHAR2(80);  Changed for bug 3267790
l_approver1_user_name     wf_users.name%TYPE;        ---- VARCHAR2(200); Changed for bug 3267790
l_approver2_user_name     wf_users.name%TYPE;        ---- VARCHAR2(200); Changed for bug 3267790
l_approver1_type          VARCHAR2(200);
l_approver2_type          VARCHAR2(200);
l_apprvl_nf_rec1_uname    wf_users.name%TYPE;        ---- VARCHAR2(200); Changed for bug 3267790
l_apprvl_nf_rec2_uname    wf_users.name%TYPE;        ---- VARCHAR2(200); Changed for bug 3267790
l_apprvl_nf_rec3_uname    wf_users.name%TYPE;        ---- VARCHAR2(200); Changed for bug 3267790
l_apprvl_nf_rec4_uname    wf_users.name%TYPE;        ---- VARCHAR2(200); Changed for bug 3267790
l_apprvl_nf_rec1_utype    VARCHAR2(30);
l_apprvl_nf_rec2_utype    VARCHAR2(30);
l_apprvl_nf_rec3_utype    VARCHAR2(30);
l_apprvl_nf_rec4_utype    VARCHAR2(30);
l_apprvl_nf_rec1_person_id NUMBER := 0;
l_apprvl_nf_rec2_person_id NUMBER := 0;
l_apprvl_nf_rec3_person_id NUMBER := 0;
l_apprvl_nf_rec4_person_id NUMBER := 0;

l_reject_nf_rec1_uname    wf_users.name%TYPE;        ---- VARCHAR2(200); Changed for bug 3267790
l_reject_nf_rec2_uname    wf_users.name%TYPE;        ---- VARCHAR2(200); Changed for bug 3267790
l_reject_nf_rec3_uname    wf_users.name%TYPE;        ---- VARCHAR2(200); Changed for bug 3267790
l_reject_nf_rec4_uname    wf_users.name%TYPE;        ---- VARCHAR2(200); Changed for bug 3267790
l_reject_nf_rec1_utype    VARCHAR2(30);
l_reject_nf_rec2_utype    VARCHAR2(30);
l_reject_nf_rec3_utype    VARCHAR2(30);
l_reject_nf_rec4_utype    VARCHAR2(30);
l_reject_nf_rec1_person_id NUMBER := 0;
l_reject_nf_rec2_person_id NUMBER := 0;
l_reject_nf_rec3_person_id NUMBER := 0;
l_reject_nf_rec4_person_id NUMBER := 0;

l_cancel_nf_rec1_uname     wf_users.name%TYPE;       ---- VARCHAR2(200); Changed for bug 3267790
l_cancel_nf_rec2_uname     wf_users.name%TYPE;       ---- VARCHAR2(200); Changed for bug 3267790
l_cancel_nf_rec3_uname     wf_users.name%TYPE;       ---- VARCHAR2(200); Changed for bug 3267790
l_cancel_nf_rec4_uname     wf_users.name%TYPE;       ---- VARCHAR2(200); Changed for bug 3267790
l_cancel_nf_rec1_utype    VARCHAR2(30);
l_cancel_nf_rec2_utype    VARCHAR2(30);
l_cancel_nf_rec3_utype    VARCHAR2(30);
l_cancel_nf_rec4_utype    VARCHAR2(30);
l_cancel_nf_rec1_person_id NUMBER := 0;
l_cancel_nf_rec2_person_id NUMBER := 0;
l_cancel_nf_rec3_person_id NUMBER := 0;
l_cancel_nf_rec4_person_id NUMBER := 0;
l_number_of_approvers     NUMBER := 0;
l_number_of_apprvl_nf_rects  NUMBER := 0;
l_number_of_reject_nf_rects  NUMBER := 0;
l_number_of_cancel_nf_rects  NUMBER := 0;

l_return_status           VARCHAR2(1);
l_error_message_code      VARCHAR2(30);
l_wf_success_status_code      pa_project_statuses.project_status_code%TYPE;
l_wf_failure_status_code      pa_project_statuses.project_status_code%TYPE;
l_project_status_name         pa_project_statuses.project_status_name%TYPE;
l_resource_person_id NUMBER;
l_reapproval_flag  VARCHAR2(1);
l_country_name            VARCHAR2(200);
l_city                    VARCHAR2(200);
l_region                  VARCHAR2(200);
l_country_code            VARCHAR2(30);
l_err_code            NUMBER := 0;
l_err_stage           VARCHAR2(2000);
l_err_stack           VARCHAR2(2000);
l_msg_count    NUMBER ;
l_msg_index_out    NUMBER ;
l_msg_data     VARCHAR2(2000);
l_data             VARCHAR2(2000);
l_primarycontactid NUMBER := 0;
l_primarycontactname  wf_users.name%TYPE;        ---- VARCHAR2(240); Changed for bug 3267790
l_resource_start_date  DATE;

-- 4363092 TCA changes, replaced RA views with HZ tables
/*
l_customer_id      ra_customers.customer_id%TYPE;
l_customer_name    ra_customers.customer_name%TYPE;
*/

l_customer_id                hz_cust_accounts.cust_account_id%TYPE;
l_customer_name              hz_parties.party_name%TYPE;

-- 4363092 end

l_workflow_started_by_uname fnd_user.user_name%TYPE; ----VARCHAR2(100); Changed for bug 3267790 /* Increased length from 30 to 100 for bug 3148857 */
l_waiting_time     NUMBER := 0;
l_number_of_reminders NUMBER := 0;
l_save_threshold      NUMBER;
l_override_basis_name VARCHAR2(80) := NULL;

l_last_approver_uname fnd_user.USER_NAME%TYPE; --- VARCHAR2(240); -- Added for the bug 3817940
l_res_manager_id PER_PEOPLE_F.PERSON_ID%TYPE;  -- Added for bug 4334741
BEGIN
        -- dbms_output.put_line ('inside start workflow');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
        /*
    IF fnd_msg_pub.count_msg > 0 THEN
       insert_into_temp ('msgs in stack inside start_workflow is',
                  fnd_msg_pub.count_msg);
        END IF;
        */
    fnd_msg_pub.initialize;
        pa_debug.init_err_stack ('pa_asgmt_wfstd.start_workflow');
    x_msg_count := 0;
 -- Create the unique item key to launch WF with
        SELECT pa_prm_wf_item_key_s.nextval
        INTO l_itemkey
        FROM dual;

    l_wf_started_by_id  := FND_GLOBAL.user_id;
    l_responsibility_id := FND_GLOBAL.resp_id;
    l_resp_appl_id      := FND_GLOBAL.resp_appl_id;

    FND_GLOBAL.Apps_Initialize ( user_id => l_wf_started_by_id
                               , resp_id => l_responsibility_id
                               , resp_appl_id => l_resp_appl_id );

    -- Setting thresold value to run the process in background
    l_save_threshold      := wf_engine.threshold;
    wf_engine.threshold := -1;


    -- Now start fetching the details
        OPEN l_assignments_csr;
    FETCH l_assignments_csr INTO l_assignments_rec;
    IF l_assignments_csr%NOTFOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       pa_utils.add_message (p_app_short_name  => 'PA',
                                 p_msg_name        => 'PA_INVALID_ASMGT_ID');
       x_error_message_code := 'PA_INVALID_ASMGT_ID'; -- msg already avail
       CLOSE l_assignments_csr;
       x_msg_count := x_msg_count + 1;
        ELSE
       CLOSE l_assignments_csr;
        END IF;
       -- := l_assignments_rec.apprvl_status_code;
/*
     -- Do not launch a workflow if an approval is already pending
        IF NVL(l_assignments_rec.pending_approval_flag, 'N') = 'Y' THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       pa_utils.add_message (p_app_short_name => 'PA',
                                 p_msg_name       =>
                'PA_ASG_APPROVAL_PENDING' );
       x_error_message_code := 'PA_ASG_APPROVAL_PENDING';
       x_msg_count := x_msg_count + 1;
    END IF;
*/
    OPEN l_stus_csr(l_assignments_rec.apprvl_status_code);
    FETCH l_stus_csr INTO
        l_wf_success_status_code,
        l_wf_failure_status_code,
        l_project_status_name ;
    IF l_stus_csr%NOTFOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       pa_utils.add_message (p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_INVALID_STATUS_CODE');
       x_error_message_code := 'PA_INVALID_STATUS_CODE';-- msg already avail
       CLOSE l_stus_csr;
       x_msg_count := x_msg_count + 1;
        ELSE
       CLOSE l_stus_csr;
    END IF;

        OPEN l_projects_csr(l_assignments_rec.project_id);
    FETCH l_projects_csr INTO l_projects_rec;
    IF l_projects_csr%NOTFOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_error_message_code := 'PA_INVALID_PROJECT_ID'; -- msg already avail
       pa_utils.add_message (p_app_short_name  => 'PA',
                                 p_msg_name        => 'PA_INVALID_PROJECT_ID');
       CLOSE l_projects_csr;
       x_msg_count := x_msg_count + 1;
        ELSE
       CLOSE l_projects_csr;
        END IF;

        Check_And_Get_Proj_Customer
                   (p_project_id   => l_assignments_rec.project_id
           ,x_customer_id  => l_customer_id
               ,x_customer_name => l_customer_name );
        -- Get the previously approved effort and duration
    -- in case of re-approvals
        OPEN l_prev_asgmt_info_csr (l_assignments_rec.assignment_id) ;
    FETCH l_prev_asgmt_info_csr INTO
          l_prev_asgmt_info_rec;
    IF    l_prev_asgmt_info_csr%NOTFOUND THEN
          l_reapproval_flag := 'N';
        ELSE
          l_reapproval_flag := 'Y';
        END IF;
    CLOSE l_prev_asgmt_info_csr;

        -- Get the Location details of the project location
        IF l_projects_rec.location_id IS NOT NULL THEN
           pa_location_utils.Get_PA_Location_Details
              ( p_location_id   => l_projects_rec.location_id
               ,x_country_name  => l_country_name
               ,x_city          => l_city
               ,x_region        => l_region
               ,x_country_code  => l_country_code
               ,x_return_status => l_return_status
               ,x_error_message_code  => l_error_message_code );
       -- dbms_output.put_line ('after pa_location_utils');

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          x_error_message_code := l_error_message_code ;
          pa_utils.add_message (p_app_short_name  => 'PA',
                                    p_msg_name        => l_error_message_code);
           END IF;
         END IF;

    -- Bug 5362698 - use sysdate to get the name so that the latest name
    -- is obtained.
    -- OPEN l_resource_csr(l_assignments_rec.resource_id, l_assignments_rec.start_date);
    -- Need to get the Max of StartDate or the Sysdate for future hire. Fix
    -- for Bug# 7585927.
    if(l_assignments_rec.start_date > sysdate) then
      l_resource_start_date := l_assignments_rec.start_date;
    else
      l_resource_start_date := sysdate;
    end if;

    OPEN l_resource_csr(l_assignments_rec.resource_id,  l_resource_start_date );
       FETCH l_resource_csr INTO l_resource_rec;
       IF l_resource_csr%NOTFOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_INVALID_PERSON_ID'; --msg already avail
          pa_utils.add_message (p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_INVALID_PERSON_ID');
           CLOSE l_resource_csr;
           x_msg_count := x_msg_count + 1;
    ELSE
           CLOSE l_resource_csr;
    END IF;

      -- Get the project manager details
         pa_project_parties_utils.get_curr_proj_mgr_details
        (p_project_id => l_projects_rec.project_id
        ,x_manager_person_id => l_project_manager_person_id
        ,x_manager_name      => l_project_manager_name
        ,x_project_party_id  => l_project_party_id
                ,x_project_role_id   => l_project_role_id
                ,x_project_role_name => l_project_role_name
                ,x_return_status     => l_return_status
                ,x_error_message_code => l_error_message_code );

       -- dbms_output.put_line ('after pa_project_parties_utils');
        -- Only non-admin projects require a manager
      IF l_projects_rec.admin_flag = 'N' THEN
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
        x_error_message_code := l_error_message_code;
        pa_utils.add_message (p_app_short_name  => 'PA',
                                  p_msg_name        => l_error_message_code);
         END IF;
      END IF;
    -- If there are any busines rules violations , then do
    -- not proceed. Return
         l_msg_count := fnd_msg_pub.count_msg;
         IF l_msg_count > 0 THEN
           IF l_msg_count = 1 THEN
             pa_interface_utils_pub.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data ,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out );
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
       ELSE
             x_msg_count := l_msg_count;
           END IF;
           pa_debug.reset_err_stack;
       RETURN;
         END IF;
    -- Get the approvers user name
       IF p_approver1_person_id IS NOT NULL THEN
          wf_directory.getusername
            (p_orig_system => 'PER',
                 p_orig_system_id => p_approver1_person_id,
                 p_name         => l_approver1_user_name,
                 p_display_name => l_display_name);
           l_number_of_approvers := l_number_of_approvers + 1;
           l_approver1_type := p_approver1_type;
       END IF;

       IF p_approver2_person_id IS NOT NULL THEN
          wf_directory.getusername
            (p_orig_system => 'PER',
                 p_orig_system_id => p_approver2_person_id,
                 p_name         => l_approver2_user_name,
                 p_display_name => l_display_name);
           l_number_of_approvers := l_number_of_approvers + 1;
           l_approver2_type := p_approver2_type;
       END IF;

    -- get the recipients user name (resource , project manager ,
        -- If person_id is passed use that value to get the user name
        -- of the resource, otherwise, use the person id fetched from resources
         IF p_person_id IS NULL THEN
            l_resource_person_id := l_resource_rec.resource_person_id;
             ELSE
            l_resource_person_id := p_person_id;
             END IF;
         wf_directory.getusername
            (p_orig_system => 'PER',
                     p_orig_system_id => l_resource_person_id,
                 p_name         => l_apprvl_nf_rec1_uname,
                 p_display_name => l_display_name);
        l_reject_nf_rec1_uname := l_apprvl_nf_rec1_uname;
            l_cancel_nf_rec1_uname := l_apprvl_nf_rec1_uname;
        l_apprvl_nf_rec1_utype := 'RESOURCE';
        l_apprvl_nf_rec1_person_id := l_resource_person_id;
        l_reject_nf_rec1_utype := 'RESOURCE';
        l_reject_nf_rec1_person_id := l_resource_person_id;
        l_cancel_nf_rec1_utype := 'RESOURCE';
        l_cancel_nf_rec1_person_id := l_resource_person_id;
        l_number_of_apprvl_nf_rects := l_number_of_apprvl_nf_rects +1;
        l_number_of_reject_nf_rects := l_number_of_reject_nf_rects +1;
        l_number_of_cancel_nf_rects := l_number_of_cancel_nf_rects +1;

    -- Now get the resource's manager name , since the approvers may or
    -- may not be the resource's manager
    -- Begin changes for Bug 4334741 Changed resource manager from l_resource_rec.manager_id to l_res_manager_id
-- Bug 4473484
--    l_res_manager_id := pa_resource_utils.get_hr_manager_id(l_resource_rec.resource_id,l_assignments_rec.assignment_id);
      l_res_manager_id := pa_resource_utils.get_hr_manager_id(p_resource_id => l_resource_rec.resource_id,
                                                              p_start_date  => l_assignments_rec.start_date);
	  IF l_res_manager_id IS NOT NULL THEN
             wf_directory.getusername
            (p_orig_system => 'PER',
                 p_orig_system_id => l_res_manager_id,
                 p_name         =>   l_apprvl_nf_rec2_uname,
                 p_display_name => l_display_name);
             l_reject_nf_rec2_uname := l_apprvl_nf_rec2_uname;
             l_cancel_nf_rec2_uname := l_apprvl_nf_rec2_uname;
             l_apprvl_nf_rec2_utype := 'RESOURCE_MANAGER';
             l_apprvl_nf_rec2_person_id := l_res_manager_id;
             l_reject_nf_rec2_utype := 'RESOURCE_MANAGER';
             l_reject_nf_rec2_person_id := l_res_manager_id;
             l_cancel_nf_rec2_utype := 'RESOURCE_MANAGER';
             l_cancel_nf_rec2_person_id := l_res_manager_id;
             l_number_of_apprvl_nf_rects := l_number_of_apprvl_nf_rects +1;
             l_number_of_reject_nf_rects := l_number_of_reject_nf_rects +1;
             l_number_of_cancel_nf_rects := l_number_of_cancel_nf_rects +1;

              END IF;
    -- End changes for Bug 4334741 Changed resource manager from l_resource_rec.manager_id to l_res_manager_id
    -- Now get the project manager's user name
           IF l_project_manager_person_id IS NOT NULL THEN
             wf_directory.getusername
            (p_orig_system => 'PER',
                 p_orig_system_id => l_project_manager_person_id,
                 p_name         =>   l_project_manager_uname,
                 p_display_name => l_display_name);
         l_apprvl_nf_rec3_uname := l_project_manager_uname;
             l_reject_nf_rec3_uname := l_project_manager_uname;
             l_cancel_nf_rec3_uname := l_project_manager_uname;
             l_apprvl_nf_rec3_utype := 'PROJECT_MANAGER';
             l_apprvl_nf_rec3_person_id := l_project_manager_person_id;
             l_reject_nf_rec3_utype := 'PROJECT_MANAGER';
             l_reject_nf_rec3_person_id := l_project_manager_person_id;
             l_cancel_nf_rec3_utype := 'PROJECT_MANAGER';
             l_cancel_nf_rec3_person_id := l_project_manager_person_id;
             l_number_of_apprvl_nf_rects := l_number_of_apprvl_nf_rects +1;
             l_number_of_reject_nf_rects := l_number_of_reject_nf_rects +1;
             l_number_of_cancel_nf_rects := l_number_of_cancel_nf_rects +1;
           END IF;

             -- Ramesh 07/11/00
        -- Primary contact would be one of the two approvers
        -- Call the procedure to get the primary contact id
                get_primary_contact_info
                   (p_resource_id         => l_resource_rec.resource_id
                   ,p_assignment_id       => l_assignments_rec.assignment_id
                   ,p_approver1_person_id => p_approver1_person_id
                   ,p_approver1_type      => p_approver1_type
                   ,p_approver2_person_id => p_approver2_person_id
                   ,p_approver2_type      => p_approver2_type
                   ,x_PrimaryContactId    => l_primarycontactid );
    -- dbms_output.put_line ('after resource utils - primary contact');
        -- Now get the primary contact's user name
               IF l_primarycontactid IS NOT NULL THEN
                 wf_directory.getusername
                    (p_orig_system => 'PER',
                     p_orig_system_id => l_primarycontactid,
                     p_name         =>   l_primarycontactname,
                     p_display_name =>   l_display_name);
                 l_apprvl_nf_rec4_uname := l_primarycontactname;
                 l_reject_nf_rec4_uname := l_primarycontactname;
                 l_cancel_nf_rec4_uname := l_primarycontactname;
             l_apprvl_nf_rec4_utype := 'ORG_PRIMARY_CONTACT';
             l_apprvl_nf_rec4_person_id := l_primarycontactid;
             l_reject_nf_rec4_utype := 'ORG_PRIMARY_CONTACT';
             l_reject_nf_rec4_person_id :=  l_primarycontactid;
             l_cancel_nf_rec4_utype := 'ORG_PRIMARY_CONTACT';
             l_cancel_nf_rec4_person_id :=  l_primarycontactid;
                 l_number_of_apprvl_nf_rects := l_number_of_apprvl_nf_rects +1;
                 l_number_of_reject_nf_rects := l_number_of_reject_nf_rects +1;
             l_number_of_cancel_nf_rects := l_number_of_cancel_nf_rects +1;
               END IF;
        -- End 07/11/00 changes
    -- We now have all the values in local variables
    -- Create the WF process
        wf_engine.CreateProcess ( ItemType => p_wf_item_type
                                , ItemKey  => l_itemkey
                                , process  => p_wf_process
                                );

    --Set approval type
    wf_engine.SetItemAttrText
        ( itemtype => p_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'APPROVAL_TYPE'
        , avalue   => PA_ASGMT_WFSTD.G_SINGLE_APPROVAL  );

    -- Now set the values as appropriate  in the WF attributes
        -- Set Project details attributes
         wf_engine.SetItemAttrNumber
                                ( itemtype => p_wf_item_type
                                , itemkey => l_itemkey
                                , aname => 'PROJECT_ID'
                                , avalue => l_projects_rec.project_id
                                );

          wf_engine.SetItemAttrText
                               ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'PROJECT_NUMBER'
                               , avalue => l_projects_rec.segment1
                               );

           wf_engine.SetItemAttrText
                               ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'PROJECT_NAME'
                               , avalue => l_projects_rec.name
                               );

           wf_engine.SetItemAttrText
                               ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'PROJECT_ORGANIZATION'
                               , avalue => l_projects_rec.organization_name
                               );
/*Commented the code for the bug 3595857
            Bug 3595857 - Adding the FROM_ROLE_VALUE Attribute
           wf_engine.SetItemAttrText
                               ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'FROM_ROLE_VALUE'
                               , avalue => fnd_global.user_name
                               );*/

           wf_engine.SetItemAttrText
                               ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'PROJECT_LOCATION'
                               , avalue => l_city||' , ' ||l_region||
                           ' , ' ||l_country_name
                               );
    -- Set the customer name if it is not null
     IF l_customer_name IS NOT NULL THEN
           wf_engine.SetItemAttrText
                               ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'PROJECT_CUSTOMER'
                               , avalue => l_customer_name
                               );
     END IF;


    -- Set Assignment related attributes

           wf_engine.SetItemAttrNumber
                ( itemtype => p_wf_item_type
                                , itemkey => l_itemkey
                                , aname => 'ASSIGNMENT_ID'
                                , avalue => l_assignments_rec.assignment_id
                                );

           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'ASSIGNMENT_NAME'
                               , avalue => l_assignments_rec.assignment_name
                               );

           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'ASSIGNMENT_TYPE'
                               , avalue => l_assignments_rec.assignment_type
                               );

           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'DESCRIPTION'
                               , avalue => l_assignments_rec.description
                               );

/* Added for bug 3051110 */

           wf_engine.SetItemAttrNumber(itemtype => p_wf_item_type
                , Itemkey => l_itemkey
                , aname => 'TRANSFER_PRICE_RATE'
                    , avalue => l_assignments_rec.transfer_price_rate);

           wf_engine.SetItemAttrtext(itemtype => p_wf_item_type
                , Itemkey => l_itemkey
                , aname => 'TRANSFER_PR_RATE_CURR'
                    , avalue => l_assignments_rec.transfer_pr_rate_curr);

           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'ADDITIONAL_INFORMATION'
                               , avalue =>
                    l_assignments_rec.additional_information
                               );

           wf_engine.SetItemAttrDate
                  (itemtype => p_wf_item_type
                              , itemkey => l_itemkey
                              , aname => 'START_DATE'
                              , avalue => l_assignments_rec.start_date
                              );

           wf_engine.SetItemAttrDate
                 (itemtype => p_wf_item_type
                              , itemkey => l_itemkey
                              , aname => 'END_DATE'
                              , avalue => l_assignments_rec.end_date
                             );

           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'ASSIGNMENT_DURATION'
                               , avalue =>
                 (trunc(l_assignments_rec.end_date) -
                     trunc(l_assignments_rec.start_date)+1)
                               );

           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'ASSIGNMENT_EFFORT'
                               , avalue => l_assignments_rec.assignment_effort
                               );

           -- Start Additions by RM for bug 2274426
           wf_engine.SetItemAttrNumber
                               ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'REVENUE_BILL_RATE'
                               , avalue => l_assignments_rec.revenue_bill_rate
                               );
           wf_engine.SetItemAttrText
                            ( itemtype => p_wf_item_type
                            , itemkey => l_itemkey
                            , aname => 'REVENUE_BILL_RATE_CURR'
                            , avalue => l_assignments_rec.revenue_currency_code
                            );
           wf_engine.SetItemAttrNumber
                               ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'BILL_RATE_OVERRIDE'
                               , avalue => l_assignments_rec.bill_rate_override
                               );
           wf_engine.SetItemAttrText
                          ( itemtype => p_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'BILL_RATE_OVERRIDE_CURR'
                          , avalue => l_assignments_rec.bill_rate_curr_override
                          );
           IF l_assignments_rec.markup_percent_override IS NOT NULL THEN
              wf_engine.SetItemAttrText
                          ( itemtype => p_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'MARKUP_PCT_OVERRIDE'
                          , avalue => to_char(l_assignments_rec.markup_percent_override)||'%'
                          );
           ELSE
               wf_engine.SetItemAttrText
                          ( itemtype => p_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'MARKUP_PCT_OVERRIDE'
                          , avalue => to_char(l_assignments_rec.markup_percent_override)
                          );
           END IF;
           wf_engine.SetItemAttrText
                          ( itemtype => p_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'TP_AMT_TYPE_NAME'
                          , avalue => l_assignments_rec.fcst_tp_amount_type_name
                          );
           wf_engine.SetItemAttrNumber
                          ( itemtype => p_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'TP_RATE_OVERRIDE'
                          , avalue => l_assignments_rec.tp_rate_override
                          );
           wf_engine.SetItemAttrText
                          ( itemtype => p_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'TP_RATE_OVERRIDE_CURR'
                          , avalue => l_assignments_rec.tp_currency_override
                          );
           IF l_assignments_rec.tp_calc_base_code_override IS NOT NULL THEN
              open csr_get_override_basis_name(l_assignments_rec.tp_calc_base_code_override);
              fetch csr_get_override_basis_name into l_override_basis_name;
              close csr_get_override_basis_name;
           END IF;
           wf_engine.SetItemAttrText
                          ( itemtype => p_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'OVERRIDE_BASIS_NAME'
                          , avalue => l_override_basis_name
                          );
           IF l_assignments_rec.tp_percent_applied_override IS NOT NULL THEN
              IF l_override_basis_name IS NOT NULL THEN
                 wf_engine.SetItemAttrText
                     ( itemtype => p_wf_item_type
                     , itemkey => l_itemkey
                     , aname => 'TP_PCT_APPLIED_OVERRIDE'
                     , avalue => ', '||to_char(l_assignments_rec.tp_percent_applied_override)||'%'
                     );
              ELSE
                 wf_engine.SetItemAttrText
                     ( itemtype => p_wf_item_type
                     , itemkey => l_itemkey
                     , aname => 'TP_PCT_APPLIED_OVERRIDE'
                     , avalue => to_char(l_assignments_rec.tp_percent_applied_override)||'%'
                     );
              END IF;
           ELSE
              wf_engine.SetItemAttrText
                     ( itemtype => p_wf_item_type
                     , itemkey => l_itemkey
                     , aname => 'TP_PCT_APPLIED_OVERRIDE'
                     , avalue => to_char(l_assignments_rec.tp_percent_applied_override)
                     );
           END IF;
           wf_engine.SetItemAttrText
                          ( itemtype => p_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'WORK_TYPE_NAME'
                          , avalue => l_assignments_rec.work_type_name
                          );
           -- End of Additions by RM

           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'CURRENT_ASGMT_STATUS_CODE'
                               , avalue => l_assignments_rec.apprvl_status_code
                               );

           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'NOTE_TO_APPROVER'
                               , avalue => l_assignments_rec.note_to_approver
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'ASGMT_FAILURE_STATUS_CODE'
                               , avalue => l_wf_failure_status_code
                               );

           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'ASGMT_SUCCESS_STATUS_CODE'
                               , avalue => l_wf_success_status_code
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'PROJECT_STATUS_NAME'
                               , avalue => l_project_status_name
                               );

           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'REAPPROVAL_FLAG'
                               , avalue => l_reapproval_flag
                               );
     -- Set the previously approved values , if it is a re-approval
     IF l_reapproval_flag = 'Y' THEN
           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'PREV_DURATION'
                               , avalue => l_prev_asgmt_info_rec.prev_duration );
           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                    , itemkey => l_itemkey
                    , aname   => 'PREV_EFFORT'
                    , avalue  => l_prev_asgmt_info_rec.prev_effort );
    END IF;

    -- Set resource related attributes

           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                                , itemkey => l_itemkey
                                , aname => 'RESOURCE_ID'
                                , avalue => l_resource_rec.resource_id
                               );

           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                                , itemkey => l_itemkey
                                , aname => 'RESOURCE_PERSON_ID'
                                , avalue => l_resource_person_id
                               );

           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'RESOURCE_NAME'
                               , avalue => l_resource_rec.resource_name
                               );

           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'RESOURCE_ORGANIZATION'
                               , avalue =>
                 l_resource_rec.resource_organization_name
                               );

    -- Set project manager attributes

           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                                , itemkey => l_itemkey
                                , aname => 'PROJECT_MANAGER_PERSON_ID'
                                , avalue => l_project_manager_person_id
                               );

           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'PROJECT_MANAGER_NAME'
                               , avalue => l_project_manager_name
                               );

           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'PROJECT_MANAGER_UNAME'
                               , avalue =>
                 l_project_manager_uname
                               );
    -- Set the other attributes

           wf_engine.SetItemAttrNumber
                   (  itemtype => p_wf_item_type
                                , itemkey => l_itemkey
                                , aname => 'NUMBER_OF_APPROVERS'
                                , avalue => l_number_of_approvers
                               );

           wf_engine.SetItemAttrNumber
                   (  itemtype => p_wf_item_type
                                , itemkey => l_itemkey
                                , aname => 'NUMBER_OF_APPRVL_NF_RECIPIENTS'
                                , avalue => l_number_of_apprvl_nf_rects
                );

           wf_engine.SetItemAttrNumber
                   (  itemtype => p_wf_item_type
                                , itemkey => l_itemkey
                                , aname => 'NUMBER_OF_REJECT_NF_RECIPIENTS'
                                , avalue => l_number_of_reject_nf_rects
                               );

           wf_engine.SetItemAttrNumber
                   (  itemtype => p_wf_item_type
                                , itemkey => l_itemkey
                                , aname => 'NUMBER_OF_CANCEL_NF_RECIPIENTS'
                                , avalue => l_number_of_reject_nf_rects
                               );


           wf_engine.SetItemAttrNumber
                   (  itemtype => p_wf_item_type
                                , itemkey => l_itemkey
                                , aname => 'APPROVER_LOOP_COUNTER'
                                , avalue => 0
                               );
           wf_engine.SetItemAttrNumber
                   (  itemtype => p_wf_item_type
                                , itemkey => l_itemkey
                                , aname => 'APPROVAL_NF_LOOP_COUNTER'
                                , avalue => 0
                               );
           wf_engine.SetItemAttrNumber
                   (  itemtype => p_wf_item_type
                                , itemkey => l_itemkey
                                , aname => 'REJECTION_NF_LOOP_COUNTER'
                                , avalue => 0
                               );

           wf_engine.SetItemAttrNumber
                   (  itemtype => p_wf_item_type
                                , itemkey => l_itemkey
                                , aname => 'CANCELLATION_NF_LOOP_COUNTER'
                                , avalue => 0
                               );

           wf_engine.SetItemAttrNumber
                   (  itemtype => p_wf_item_type
                                , itemkey => l_itemkey
                                , aname => 'APPROVER_1_PERSON_ID'
                                , avalue => p_approver1_person_id
                               );

           wf_engine.SetItemAttrNumber
                   (  itemtype => p_wf_item_type
                                , itemkey => l_itemkey
                                , aname => 'APPROVER_2_PERSON_ID'
                                , avalue => p_approver2_person_id
                               );

           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'APPROVER1_USER_NAME'
                               , avalue => l_approver1_user_name
                               );

           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'APPROVER2_USER_NAME'
                               , avalue => l_approver2_user_name
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'APPROVER_1_TYPE'
                               , avalue => l_approver1_type
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'APPROVER_2_TYPE'
                               , avalue => l_approver2_type
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'APPROVAL_NF_REC1_USER_NAME'
                               , avalue => l_apprvl_nf_rec1_uname
                               );

           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'APPROVAL_NF_REC1_USER_TYPE'
                               , avalue => l_apprvl_nf_rec1_utype
                               );
           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'APPROVAL_NF_REC1_PERSON_ID'
                               , avalue => l_apprvl_nf_rec1_person_id
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'APPROVAL_NF_REC2_USER_NAME'
                               , avalue => l_apprvl_nf_rec2_uname
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'APPROVAL_NF_REC2_USER_TYPE'
                               , avalue => l_apprvl_nf_rec2_utype
                               );
           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'APPROVAL_NF_REC2_PERSON_ID'
                               , avalue => l_apprvl_nf_rec2_person_id
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'APPROVAL_NF_REC3_USER_NAME'
                               , avalue => l_apprvl_nf_rec3_uname
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'APPROVAL_NF_REC3_USER_TYPE'
                               , avalue => l_apprvl_nf_rec3_utype
                               );
           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'APPROVAL_NF_REC3_PERSON_ID'
                               , avalue => l_apprvl_nf_rec3_person_id
                               );
        -- Ramesh 07/11/00
         IF l_apprvl_nf_rec4_uname IS NOT NULL THEN
           wf_engine.SetItemAttrText
                               ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'APPROVAL_NF_REC4_USER_NAME'
                               , avalue => l_apprvl_nf_rec4_uname
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'APPROVAL_NF_REC4_USER_TYPE'
                               , avalue => l_apprvl_nf_rec4_utype
                               );
           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'APPROVAL_NF_REC4_PERSON_ID'
                               , avalue => l_apprvl_nf_rec4_person_id
                               );
         END IF;
        -- End 07/11/00 changes

           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'REJECT_NF_REC1_USER_NAME'
                               , avalue => l_reject_nf_rec1_uname
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'REJECT_NF_REC1_USER_TYPE'
                               , avalue => l_reject_nf_rec1_utype
                               );
           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'REJECT_NF_REC1_PERSON_ID'
                               , avalue => l_reject_nf_rec1_person_id
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'REJECT_NF_REC2_USER_NAME'
                               , avalue => l_reject_nf_rec2_uname
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'REJECT_NF_REC2_USER_TYPE'
                               , avalue => l_reject_nf_rec2_utype
                               );
           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'REJECT_NF_REC2_PERSON_ID'
                               , avalue => l_reject_nf_rec2_person_id
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'REJECT_NF_REC3_USER_NAME'
                               , avalue => l_reject_nf_rec3_uname
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'REJECT_NF_REC3_USER_TYPE'
                               , avalue => l_reject_nf_rec3_utype
                               );
           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'REJECT_NF_REC3_PERSON_ID'
                               , avalue => l_reject_nf_rec3_person_id
                               );
            -- Ramesh 07/11/00 changes
        IF l_reject_nf_rec4_uname IS NOT NULL THEN
           wf_engine.SetItemAttrText
                               ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'REJECT_NF_REC4_USER_NAME'
                               , avalue => l_reject_nf_rec4_uname
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'REJECT_NF_REC4_USER_TYPE'
                               , avalue => l_reject_nf_rec4_utype
                               );
           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'REJECT_NF_REC4_PERSON_ID'
                               , avalue => l_reject_nf_rec4_person_id
                               );
        END IF;
        -- End 07/11/00 changes

           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'CANCEL_NF_REC1_USER_NAME'
                               , avalue => l_cancel_nf_rec1_uname
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'CANCEL_NF_REC1_USER_TYPE'
                               , avalue => l_cancel_nf_rec1_utype
                               );
           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'CANCEL_NF_REC1_PERSON_ID'
                               , avalue => l_cancel_nf_rec1_person_id
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'CANCEL_NF_REC2_USER_NAME'
                               , avalue => l_cancel_nf_rec2_uname
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'CANCEL_NF_REC2_USER_TYPE'
                               , avalue => l_cancel_nf_rec2_utype
                               );
           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'CANCEL_NF_REC2_PERSON_ID'
                               , avalue => l_cancel_nf_rec2_person_id
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'CANCEL_NF_REC3_USER_NAME'
                               , avalue => l_cancel_nf_rec3_uname
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'CANCEL_NF_REC3_USER_TYPE'
                               , avalue => l_cancel_nf_rec3_utype
                               );
           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'CANCEL_NF_REC3_PERSON_ID'
                               , avalue => l_cancel_nf_rec3_person_id
                               );
            -- Ramesh 07/11/00 changes
        IF l_cancel_nf_rec4_uname IS NOT NULL THEN
           wf_engine.SetItemAttrText
                               ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'CANCEL_NF_REC4_USER_NAME'
                               , avalue => l_cancel_nf_rec4_uname
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'CANCEL_NF_REC4_USER_TYPE'
                               , avalue => l_cancel_nf_rec4_utype
                               );
           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'CANCEL_NF_REC4_PERSON_ID'
                               , avalue => l_cancel_nf_rec4_person_id
                               );
        END IF;
        -- End 07/11/00 changes

            -- Set the item attributes for apprvl item type
        -- and apprvl item key . This would be the item type
        -- and item key of the approval process
        IF (p_apprvl_item_type IS NOT NULL AND p_apprvl_item_key
            IS NOT NULL ) THEN
            wf_engine.SetItemAttrText
                         ( itemtype => p_wf_item_type
                         , itemkey =>  l_itemkey
                         , aname => 'APPRVL_ITEM_TYPE'
                         , avalue => p_apprvl_item_type
                         );
            wf_engine.SetItemAttrText
                         ( itemtype => p_wf_item_type
                         , itemkey =>  l_itemkey
                         , aname => 'APPRVL_ITEM_KEY'
                         , avalue => p_apprvl_item_key
                         );
          /*Bug 3817940 : Code addition Starts*/
      if p_wf_process = 'PA_APRVL_NF_SP' or p_wf_process = 'PA_CANCEL_NF_SP' or p_wf_process = 'PA_REJ_NF_SP'
      Then
        l_last_approver_uname :=     wf_engine.GetItemAttrText
                   ( itemtype => p_apprvl_item_type
                               , itemkey =>  p_apprvl_item_key
                               , aname => 'APPROVER_UNAME');

            wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey =>  l_itemkey
                               , aname => 'FROM_ROLE_VALUE1'
                               , avalue => l_last_approver_uname
                               );
           END IF;
            /*Bug 3817940 : Code addition ends*/
        END IF;

        --
        --Bug 1733307: set URL
        --
/*Code modified for bug 6408552*/
/*For Admin Assignment, we should call with paCalledPage as 'AdminAsmt'*/
IF (l_assignments_rec.assignment_type = 'STAFFED_ADMIN_ASSIGNMENT') THEN

	   l_asgmt_details_url :=
           'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode=PA_ASMT_LAYOUT&paCalledPage=AdminAsmt&paAssignmentId='||p_assignment_id||'&addBreadCrumb=RP';

ELSE -- Old code that was being called generically

	   l_asgmt_details_url :=
           'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode=PA_ASMT_LAYOUT&paCalledPage=ProjStaffedAsmt&paAssignmentId='||p_assignment_id||'&addBreadCrumb=RP';

END IF ;
/*Code modification ends for bug 6408552*/
           l_resource_schedules_url := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode=PA_VIEW_RESOURCE_LAYOUT&paResourceId='||l_resource_rec.resource_id||'&addBreadCrumb=RP';

           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey  => l_itemkey
                               , aname => 'ASSIGNMENT_DETAILS_URL_INFO'
                               , avalue => l_asgmt_details_url
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey =>  l_itemkey
                               , aname => 'RESOURCE_DETAILS_URL_INFO'
                               , avalue => l_resource_details_url
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => p_wf_item_type
                               , itemkey =>  l_itemkey
                               , aname => 'RESOURCE_SCHEDULES_URL_INFO'
                               , avalue => l_resource_schedules_url
                               );

           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                               , itemkey =>  l_itemkey
                               , aname => 'CONFLICT_GROUP_ID'
                               , avalue => p_conflict_group_id
                               );

    -- Set workflow started by attributes
    -- Get the current user_id using FND_GLOBAL.USER_ID
    -- Get the user name from the user id
    -- Set the workflow started by user name
    l_workflow_started_by_uname := FND_GLOBAL.USER_NAME;
            wf_engine.SetItemAttrText
                         ( itemtype => p_wf_item_type
                         , itemkey =>  l_itemkey
                         , aname => 'WORKFLOW_STARTED_BY_UNAME'
                         , avalue => l_workflow_started_by_uname
                         );

    -- Call the client extensions to set the waiting period
    -- for reminders as well as the number of times to remind
    PA_CLIENT_EXTN_ASGMT_WF.Set_Timeout_And_Reminders
        ( p_assignment_id          => l_assignments_rec.assignment_id
          ,p_project_id            => l_projects_rec.project_id
          ,x_waiting_time          => l_waiting_time
          ,x_number_of_reminders   => l_number_of_reminders );

    IF l_waiting_time IS NULL THEN
       -- If the client extension did not return a valid
       -- waiting time , then set it to the default defined
       -- by the product , which is 3 days (expressed in minutes)
       -- (3 * 24 * 60) = 4320
       l_waiting_time := 4320;
    END IF;
    IF l_number_of_reminders IS NULL THEN
       -- If the client extension did not return a valid
       -- waiting time , then set it to the default defined
       -- by the product , which is 3
       l_number_of_reminders := 3;
        END IF;
       -- Now set the appropriate attributes in the workflow process
           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'TIMEOUT_WAITING_PERIOD'
                               , avalue => l_waiting_time
                               );

           wf_engine.SetItemAttrNumber
                   ( itemtype => p_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'NUMBER_OF_REMINDERS'
                               , avalue => l_number_of_reminders
                               );
    -- Now start the WF process
           wf_engine.StartProcess ( itemtype => p_wf_item_type
                                  , itemkey => l_itemkey );
            PA_WORKFLOW_UTILS.Insert_WF_Processes
            (p_wf_type_code        => 'ASSIGNMENT_APPROVAL'
            ,p_item_type           => p_wf_item_type
            ,p_item_key            => l_itemkey
                ,p_entity_key1         => to_char(l_projects_rec.project_id)
            ,p_entity_key2         => to_char(p_assignment_id)
            ,p_description         => NULL
            ,p_err_code            => l_err_code
            ,p_err_stage           => l_err_stage
            ,p_err_stack           => l_err_stack
            );
        --Setting the original value
        wf_engine.threshold := l_save_threshold;

    -- dbms_output.put_line ('after pa_workflow_utils ');
EXCEPTION
 WHEN OTHERS THEN
     --Setting the original value
     wf_engine.threshold := l_save_threshold;

     -- dbms_output.put_line ('others exception raised ');
     -- dbms_output.put_line ('error is '||SQLERRM);

     -- 4537865 : RESET other OUT params also
     x_msg_data := SUBSTRB(SQLERRM,1,240);
     x_error_message_code := SQLCODE ;
     -- 4537865 : End
     fnd_msg_pub.add_exc_msg
      (p_pkg_name => 'PA_ASGMT_WFSTD',
       p_procedure_name => pa_debug.g_err_stack );
       x_msg_count := fnd_msg_pub.count_msg;
       x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
END Start_Workflow ;



PROCEDURE  get_workflow_process_info
              (p_status_code IN VARCHAR2
               ,x_wf_item_type OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
               ,x_wf_process   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
               ,x_wf_type      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
               ,x_msg_count    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
               ,x_msg_data     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
               ,x_return_status  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
               ,x_error_message_code OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895
CURSOR l_stus_csr IS
SELECT ps.wf_success_status_code,
       ps.wf_failure_status_code,
       ps.workflow_item_type,
       ps.workflow_process,
       ps.project_system_status_code ,
       ps.enable_wf_flag
FROM   pa_project_statuses ps
WHERE  project_status_code = p_status_code;

l_stus_rec  l_stus_csr%ROWTYPE;
l_msg_count    NUMBER :=0;
l_msg_index_out    NUMBER ;
l_msg_data     VARCHAR2(2000);
l_data             VARCHAR2(2000);
BEGIN
    -- This procedure returns whether wf is enabled for the given
    -- assignment approval status and if so, the item type and process
    -- It also returns whether the WF is an approval WF or an FYI WF
    -- The logic is
    -- If the approval status is a SUBMITTED status , then the
    -- workflow is an APPROVAL WORKFLOW. else if the status
    -- is an APPROVED or REJECTED status, the workflow is a FYI only
    x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;
        pa_debug.init_err_stack ('pa_asgmt_wfstd.get_workflow_process_info');
    OPEN l_stus_csr;
    FETCH l_stus_csr INTO l_stus_rec;
    IF l_stus_csr%NOTFOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_error_message_code := 'PA_INVALID_STATUS_CODE';-- msg already avail
       pa_utils.add_message (p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_INVALID_STATUS_CODE');
       l_msg_count := l_msg_count + 1;
       CLOSE l_stus_csr;
           -- RETURN;
        ELSE
       CLOSE l_stus_csr;
    END IF;

         IF l_msg_count > 0 THEN
           IF l_msg_count = 1 THEN
             pa_interface_utils_pub.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data ,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out );
             x_msg_data  := l_data;
             x_msg_count := l_msg_count;
       ELSE
             x_msg_count := l_msg_count;
           END IF;
           pa_debug.reset_err_stack;
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
         END IF;

     IF NVL(l_stus_rec.enable_wf_flag,'N') = 'N' THEN
        x_wf_type := 'NOT_ENABLED';
     END IF ;
     IF NVL(l_stus_rec.enable_wf_flag,'N') = 'Y' THEN
            x_wf_item_type := l_stus_rec.workflow_item_type;
        x_wf_process   := l_stus_rec.workflow_process;
            IF l_stus_rec.project_system_status_code =
        'ASGMT_APPRVL_SUBMITTED' THEN
         x_wf_type := 'APPROVAL_PROCESS';
        ELSIF l_stus_rec.project_system_status_code IN
             ('ASGMT_APPRVL_APPROVED','ASGMT_APPRVL_REJECTED','ASGMT_APPRVL_CANCELED') THEN
         x_wf_type := 'FYI_NF';
        END IF;
     END IF;
EXCEPTION
 WHEN OTHERS THEN
     -- 4537865 : RESET other OUT params also
     x_msg_data := SUBSTRB(SQLERRM,1,240);
     x_error_message_code := SQLCODE ;
     x_wf_item_type := NULL ;
     x_wf_process   := NULL ;
     x_wf_type      := NULL ;

     -- 4537865 : End
     fnd_msg_pub.add_exc_msg
      (p_pkg_name => 'PA_ASGMT_WFSTD',
       p_procedure_name => pa_debug.g_err_stack );
       x_msg_count := fnd_msg_pub.count_msg;
       x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE ;
END Get_workflow_process_info ;

FUNCTION Is_approval_pending (p_assignment_id IN NUMBER) RETURN VARCHAR2
IS
CURSOR l_asgmt_csr IS
SELECT NVL(pending_approval_flag,'N')
FROM pa_project_assignments
WHERE assignment_id = p_assignment_id;
l_pending_approval_flag pa_project_assignments.pending_approval_flag%TYPE;
BEGIN
    OPEN l_asgmt_csr;
    FETCH l_asgmt_csr INTO l_pending_approval_flag;
    IF l_asgmt_csr%NOTFOUND THEN
       l_pending_approval_flag := 'N';
    END IF;
    CLOSE l_asgmt_csr;
    RETURN l_pending_approval_flag;
EXCEPTION
 WHEN OTHERS THEN
    RAISE ;
END Is_Approval_Pending ;



PROCEDURE Generate_URL ( itemtype  IN VARCHAR2
                         , itemkey   IN VARCHAR2
                         , actid     IN NUMBER
                         , funcmode  IN VARCHAR2
                         , resultout OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         ) IS

l_asgmt_details_url          VARCHAR2(600);
l_resource_details_url       VARCHAR2(600);
l_resource_schedules_url     VARCHAR2(600);
l_view_conflict_url          VARCHAR2(600);
l_overcom_description        VARCHAR2(600);
l_resolve_conflicts_by_rmvl  VARCHAR2(1);
l_assignment_id              NUMBER;
l_resource_person_id         NUMBER;
l_resource_id                NUMBER;
l_conflict_group_id          NUMBER;
l_asgmt_start_date           DATE;
l_asgmt_end_date             DATE;
l_return_status              VARCHAR2(1);
l_msg_count                  NUMBER;
l_msg_data                   VARCHAR2(2000);

l_asgmt_type                 pa_project_assignments.assignment_type%TYPE; /*Added for bug 6408552*/
BEGIN

        pa_debug.init_err_stack ('pa_asgmt_wfstd.Generate_URL');
        -- Return if WF Not Running
    IF (funcmode <> wf_engine.eng_run) THEN
            resultout := wf_engine.eng_null;
            RETURN;
    END IF;
        l_assignment_id := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'ASSIGNMENT_ID');

        l_resource_person_id := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'RESOURCE_PERSON_ID');

        l_resource_id  := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'RESOURCE_ID');

        l_asgmt_start_date  := wf_engine.GetItemAttrDate
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'START_DATE');

        l_asgmt_end_date  := wf_engine.GetItemAttrDate
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'END_DATE');

        l_conflict_group_id  := wf_engine.GetItemAttrNumber
                       (itemtype => itemtype,
                        itemkey  => itemkey,
                        aname    => 'CONFLICT_GROUP_ID');

        /*Added for bug 6408552*/
	l_asgmt_type := wf_engine.GetItemAttrText
    			       (itemtype => itemtype,
     			        itemkey  => itemkey,
     			        aname    => 'ASSIGNMENT_TYPE');
        resultout := wf_engine.eng_completed||':'||'S';
    -- call to the generate url api goes here
    -- If unable to generate url return
    -- resultout := wf_engine.eng_completed||':'||'F';
    -- If such URL generation succeded then set the appropriate attributes
    -- so that it gets displayed in the NF
/*Code modified for bug 6408552*/
/*make url with paCalledPage as 'AdminAsmt' for an Admin Assignment*/
IF (l_asgmt_type = 'STAFFED_ADMIN_ASSIGNMENT') THEN

	   l_asgmt_details_url := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode=PA_ASMT_LAYOUT'
                               || '&paCalledPage=AdminAsmt&paAssignmentId=' || l_assignment_id
                               ||'&addBreadCrumb=RP';

ELSE -- old code that was being called generically

	   l_asgmt_details_url := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode=PA_ASMT_LAYOUT'
                               || '&paCalledPage=ProjStaffedAsmt&paAssignmentId=' || l_assignment_id
                               ||'&addBreadCrumb=RP';

END IF ;
/*Code modifications end for bug 6408552*/
           l_resource_schedules_url := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode='
                                    || 'PA_VIEW_RESOURCE_LAYOUT&paResourceId=' || l_resource_id
                                    || '&addBreadCrumb=RP';

           wf_engine.SetItemAttrText
                   ( itemtype => itemtype
                               , itemkey => itemkey
                               , aname => 'ASSIGNMENT_DETAILS_URL_INFO'
                               , avalue => l_asgmt_details_url
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'RESOURCE_DETAILS_URL_INFO'
                               , avalue => l_resource_details_url
                               );
           wf_engine.SetItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'RESOURCE_SCHEDULES_URL_INFO'
                               , avalue => l_resource_schedules_url
                               );

           -- Display the overcommitment description and URL only when there is any conflict.
           IF (l_conflict_group_id IS NOT NULL) THEN
              PA_SCHEDULE_PVT.will_resolve_conflicts_by_rmvl
                                           ( p_conflict_group_id         => l_conflict_group_id
                                           , x_resolve_conflicts_by_rmvl => l_resolve_conflicts_by_rmvl
                       , x_msg_count             => l_msg_count
                       , x_msg_data                  => l_msg_data
                       , x_return_status             => l_return_status);

              -- set overcommitment description
              IF (l_resolve_conflicts_by_rmvl = 'Y') THEN
                 l_overcom_description := 'If approved, this assignment will result in the removal of conflicting '
                                       || 'hours from an existing assignment of the resource.';
              ELSE
                 l_overcom_description := 'If approved, this assignment will result in an overcommitment of the resource.';
              END IF;

              wf_engine.SetItemAttrText
                      ( itemtype => itemtype
                                  , itemkey  => itemkey
                                  , aname    => 'OVERCOM_DESCRIPTION'
                                  , avalue   => l_overcom_description );

              -- set 'Number of Assignments Resulting in Resource Overcommitment -1/0' for single approval
              -- required notification.
              wf_engine.SetItemAttrNumber
                   ( itemtype => itemtype
                               , itemkey => itemkey
                               , aname => 'NUMBER_OF_OVERCOM_ASGMT'
                               , avalue => 1 );
           ELSE
              wf_engine.SetItemAttrNumber
                   ( itemtype => itemtype
                               , itemkey => itemkey
                               , aname => 'NUMBER_OF_OVERCOM_ASGMT'
                               , avalue => 0 );
           END IF; -- IF (l_conflict_group_id IS NULL)

           -- set overcommitment url
           l_view_conflict_url := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode=PA_RES_OVERCOMMITMENT_LAYOUT'
                               || '&paAssignmentId=' || l_assignment_id || '&paConflictGroupId=' || l_conflict_group_id
                               || '&paCallingPage=Default&addBreadCrumb=RP';

           wf_engine.SetItemAttrText
                      ( itemtype => itemtype
                                  , itemkey  => itemkey
                                  , aname    => 'VIEW_CONFLICT_URL_INFO'
                                  , avalue   => l_view_conflict_url );

          pa_debug.reset_err_stack;

EXCEPTION
   WHEN OTHERS THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Generate_URL',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
    resultout := wf_engine.eng_completed||':'||'F';
    RAISE;

END Generate_URL ;

PROCEDURE Generate_URL_failure
            ( itemtype  IN VARCHAR2
                         , itemkey   IN VARCHAR2
                         , actid     IN NUMBER
                         , funcmode  IN VARCHAR2
                         , resultout OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         ) IS
l_mesg    VARCHAR2(240);
BEGIN
        -- Return if WF Not Running
    IF (funcmode <> wf_engine.eng_run) THEN
            resultout := wf_engine.eng_null;
            RETURN;
    END IF;
      FND_MESSAGE.SET_NAME ('PA','PA_ASGMT_URL_GEN_FAILURE');
      l_mesg := FND_MESSAGE.GET;
          wf_engine.SetItemAttrText
                   (itemtype => itemtype
                               ,itemkey =>  itemkey
                               ,aname => 'URL_FAILURE_INFO'
                               ,avalue => l_mesg
                               );
EXCEPTION
   WHEN OTHERS THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Generate_URL_Failure',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
       RAISE;
END Generate_URL_failure;

PROCEDURE Start_New_WF   (itemtype IN VARCHAR2
                         , itemkey IN VARCHAR2
                         , actid IN NUMBER
                         , funcmode IN VARCHAR2
                         , resultout OUT NOCOPY VARCHAR2 )  IS --File.Sql.39 bug 4440895

l_new_item_type         VARCHAR2(30);
l_new_process           VARCHAR2(30);
l_new_item_key          VARCHAR2(30);
l_project_id            NUMBER;
l_assignment_id         NUMBER;
l_resource_person_id    NUMBER;
l_new_asgmt_status_code VARCHAR2(30);
l_conflict_group_id     NUMBER;
l_msg_count             NUMBER;
l_msg_data          VARCHAR2(200);
l_error_message_code    VARCHAR2(200);
l_return_status         VARCHAR2(30);
BEGIN
        pa_debug.init_err_stack ('pa_asgmt_wfstd.start_new_wf');
        -- Return if WF Not Running
    IF (funcmode <> wf_engine.eng_run) THEN
            resultout := wf_engine.eng_null;
            RETURN;
    END IF;
        l_new_item_type      := wf_engine.GetItemAttrText
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'NEW_WF_ITEM_TYPE');

        l_new_process        := wf_engine.GetItemAttrText
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'NEW_WF_PROCESS_NAME');
    IF (l_new_item_type IS NOT NULL AND
        l_new_process IS NOT NULL ) THEN
        -- Get the necessary details from the item attributes
             l_new_asgmt_status_code      :=
             wf_engine.GetItemAttrText
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'NEW_ASGMT_STATUS_CODE' );
             l_project_id     := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'PROJECT_ID' );
             l_assignment_id    := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'ASSIGNMENT_ID');
             l_resource_person_id    := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'RESOURCE_PERSON_ID');
             l_conflict_group_id     := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'CONFLICT_GROUP_ID');

         Start_Workflow
                ( p_project_id          =>  l_project_id
                        , p_assignment_id       => l_assignment_id
                        , p_status_code         => l_new_asgmt_status_code
                        , p_person_id           => l_resource_person_id
                        , p_wf_item_type        => l_new_item_type
                        , p_wf_process          => l_new_process
                        , p_approver1_person_id => NULL
                        , p_approver1_type      => NULL
                        , p_approver2_person_id => NULL
                        , p_approver2_type      => NULL
            , p_apprvl_item_type    => itemtype
            , p_apprvl_item_key     => itemkey
                        , p_conflict_group_id   => l_conflict_group_id
                        , x_msg_count           => l_msg_count
                        , x_msg_data            => l_msg_data
                        , x_return_status       => l_return_status
                        , x_error_message_code  => l_error_message_code);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   raise_application_error(-20001, l_error_message_code);
            END IF;
           END IF;
           resultout := wf_engine.eng_completed||':'||'S';
           pa_debug.reset_err_stack;
EXCEPTION
 WHEN OTHERS THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Start_New_WF',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
      resultout := wf_engine.eng_completed||':'||'F';
      RAISE ;
END Start_New_WF ;

  PROCEDURE Set_Success_Status  (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 )  IS --File.Sql.39 bug 4440895

---l_asgmt_success_status_code  pa_project_statuses.project_status_code%TYPE;
l_asgmt_success_status_code  VARCHAR2(30);
-- l_assignment_id  pa_project_assignments.assignment_id%TYPE;
l_assignment_id  NUMBER;
l_msg_count     NUMBER;
l_msg_data  VARCHAR2(200);
l_error_message_code VARCHAR2(200);
l_return_status VARCHAR2(30);
l_schedule_exception_id NUMBER;
l_is_new_assignment_flag VARCHAR2(1);
BEGIN
        pa_debug.init_err_stack ('pa_asgmt_wfstd.Set_Success_Status');
        -- Return if WF Not Running
    IF (funcmode <> wf_engine.eng_run) THEN
            resultout := wf_engine.eng_null;
            RETURN;
    END IF;
        l_asgmt_success_status_code      :=
            wf_engine.GetItemAttrText
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'ASGMT_SUCCESS_STATUS_CODE');
        l_assignment_id        :=
            wf_engine.GetItemAttrText
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'ASSIGNMENT_ID');
    -- Now store the approvers' response in the global variable
    Capture_approver_response (p_item_type => itemtype,
                   p_item_key  => itemkey );
    Set_Asgmt_wf_result_Status
        (p_assignment_id => l_assignment_id,
         p_status_code   => l_asgmt_success_status_code,
                 p_result_type   => 'APPROVE',
         p_item_type     => itemtype,
         p_item_key      => itemkey ,
         x_return_status => l_return_status );

    -- Any additional API for schedules goes here
    -- IF l_schedule_exception_id IS NOT NULL THEN
/*
          SAVEPOINT asgmt_success;
      pa_schedule_pvt.update_asgn_wf_success  (
          P_ASSIGNMENT_ID           =>  l_assignment_id
                 ,P_IS_NEW_ASSIGNMENT_FLAG  =>  l_is_new_assignment_flag
         ,P_SCH_EXCEPTION_ID        =>  l_schedule_exception_id
         ,P_SUCCESS_STATUS_CODE    =>   l_asgmt_success_status_code
         ,X_RETURN_STATUS            => l_return_status
         ,X_MSG_COUNT                => l_msg_count
         ,X_MSG_DATA                 => l_msg_data );
         */
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               resultout := wf_engine.eng_completed||':'||'F';
           RETURN;
           END IF;
        resultout := wf_engine.eng_completed||':'||'S';
        pa_debug.reset_err_stack;

EXCEPTION
WHEN OTHERS THEN
    WF_CORE.CONTEXT
    ('PA_ASGMT_WFSTD',
     'Set_Success_Status',
      itemtype,
      itemkey,
      to_char(actid),
      funcmode);
    resultout := wf_engine.eng_completed||':'||'F';
        RAISE;

END Set_Success_Status ;


PROCEDURE Set_Failure_Status  (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 )  IS --File.Sql.39 bug 4440895

l_asgmt_failure_status_code  pa_project_statuses.project_status_code%TYPE;
l_assignment_id  pa_project_assignments.assignment_id%TYPE;
l_msg_count     NUMBER;
l_msg_data  VARCHAR2(200);
l_error_message_code VARCHAR2(200);
l_return_status VARCHAR2(30);
l_schedule_exception_id pa_schedule_exceptions.schedule_exception_id%TYPE;
l_is_new_assignment_flag VARCHAR2(1);
BEGIN
        pa_debug.init_err_stack ('pa_asgmt_wfstd.Set_Failure_Status');
        -- Return if WF Not Running
    IF (funcmode <> wf_engine.eng_run) THEN
            resultout := wf_engine.eng_null;
            RETURN;
    END IF;
        l_asgmt_failure_status_code      :=
            wf_engine.GetItemAttrText
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'ASGMT_FAILURE_STATUS_CODE');
        l_assignment_id        :=
            wf_engine.GetItemAttrText
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'ASSIGNMENT_ID');
    -- Now store the approvers' response in the global variable
    Capture_approver_response (p_item_type => itemtype,
                   p_item_key  => itemkey );
    Set_Asgmt_wf_result_Status
        (p_assignment_id => l_assignment_id,
         p_status_code   => l_asgmt_failure_status_code,
                 p_result_type   => 'REJECT',
         p_item_type     => itemtype,
         p_item_key      => itemkey,
             x_return_status => l_return_status );

    -- Any additional API for schedules goes here
     -- IF l_schedule_exception_id IS NOT NULL THEN
       /*
    SAVEPOINT asgmt_failure;
    pa_schedule_pvt.update_asgn_wf_failure
        (p_assignment_id     => l_assignment_id
        ,p_is_new_assignment_flag => l_is_new_assignment_flag
        ,p_sch_exception_id  => l_schedule_exception_id
        ,p_failure_status_code   => l_asgmt_failure_status_code
        ,x_return_status     => l_return_status
        ,x_msg_count         => l_msg_count
        ,x_msg_data          => l_msg_data );
         */
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               resultout := wf_engine.eng_completed||':'||'F';
           RETURN;
          END IF;
     resultout := wf_engine.eng_completed||':'||'S';
     pa_debug.reset_err_stack;

EXCEPTION
WHEN OTHERS THEN
    WF_CORE.CONTEXT
       ('PA_ASGMT_WFSTD',
    'Set_Failure_Status',
    itemtype,
    itemkey,
    to_char(actid),
    funcmode);
     resultout := wf_engine.eng_completed||':'||'F';
     RAISE;
END Set_Failure_Status ;

  PROCEDURE Check_Wf_Enabled    (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 )  IS --File.Sql.39 bug 4440895

l_assignment_id pa_project_statuses.project_status_code%TYPE;
l_new_item_type  VARCHAR2(30);
l_new_process    VARCHAR2(30);
l_new_asgmt_status_code   pa_project_statuses.project_status_code%TYPE;
l_return_status           VARCHAR2(1);
l_error_message_code      VARCHAR2(30);
l_wf_type   VARCHAR2(30);
l_msg_count     NUMBER;
l_msg_data  VARCHAR2(200);

BEGIN
    /*
    Get the foll item attr
     'NEW_ASGMT_STATUS_CODE'
    Get the WF enabled flag, item type and process name
    of the new asgmt status code
    If wf enabled flag = 'N' then resultout = 'F'
    else
      set the new wf item type and new wf process attr
      resultout = 'T'
    */
        pa_debug.init_err_stack ('pa_asgmt_wfstd.Check_Wf_Enabled');
        -- Return if WF Not Running
    IF (funcmode <> wf_engine.eng_run) THEN
            resultout := wf_engine.eng_null;
            RETURN;
    END IF;
        l_new_asgmt_status_code      :=
            wf_engine.GetItemAttrText
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'NEW_ASGMT_STATUS_CODE' );
        get_workflow_process_info
                 (p_status_code => l_new_asgmt_status_code
                 ,x_wf_item_type => l_new_item_type
                 ,x_wf_process   => l_new_process
                 ,x_wf_type      => l_wf_type
                 ,x_msg_count    => l_msg_count
         ,x_msg_data     => l_msg_data
                 ,x_return_status  => l_return_status
                 ,x_error_message_code => l_error_message_code );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           resultout := wf_engine.eng_completed||':'||'N';
       RETURN;
    END IF;
    IF l_wf_type = 'NOT_ENABLED' THEN
           resultout := wf_engine.eng_completed||':'||'N';
    ELSE
        IF (l_new_item_type IS NOT NULL AND
        l_new_process IS NOT NULL ) THEN
               wf_engine.SetItemAttrText
                   (itemtype => itemtype
                               ,itemkey =>  itemkey
                               ,aname => 'NEW_WF_ITEM_TYPE'
                               ,avalue => l_new_item_type
                               );
               wf_engine.SetItemAttrText
                   (itemtype => itemtype
                               ,itemkey =>  itemkey
                               ,aname => 'NEW_WF_PROCESS_NAME'
                               ,avalue => l_new_process
                               );
               resultout := wf_engine.eng_completed||':'||'Y';
         ELSE
               resultout := wf_engine.eng_completed||':'||'N';
             END IF;
          END IF;
           pa_debug.reset_err_stack;
EXCEPTION
  WHEN OTHERS THEN
      WF_CORE.CONTEXT
    ('PA_ASGMT_WFSTD',
     'Check_Wf_Enabled',
      itemtype,
      itemkey,
      to_char(actid),
      funcmode);
     RAISE;
END Check_Wf_Enabled ;


  PROCEDURE Generate_Approvers (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 )  IS --File.Sql.39 bug 4440895

l_approvers_list_tbl  PA_CLIENT_EXTN_ASGMT_WF.Users_List_Tbltyp ;
l_out_approvers_list_tbl  PA_CLIENT_EXTN_ASGMT_WF.Users_List_Tbltyp ;
l_number_of_approvers  NUMBER := 0;
l_approvers_list_rec  PA_CLIENT_EXTN_ASGMT_WF.Users_List_Rectyp ;
l_assignment_id   pa_project_assignments.assignment_id%TYPE;
l_project_id      pa_projects_all.project_id%TYPE;
l_approver_user_name   wf_users.name%type; ----- VARCHAR2(30); Commented for bug 3267790 VARCHAR2(100);
/* Modified length from 30 to 100 for bug 3148857 */
l_approver_person_id  NUMBER := 0;
l_approver_type   VARCHAR2(30);
l_item_attr_name  VARCHAR2(30);
l_approvers_list_tbl_idx NUMBER := 1;
BEGIN
        pa_debug.init_err_stack ('pa_asgmt_wfstd.Generate_Approvers');
        -- Return if WF Not Running
    IF (funcmode <> wf_engine.eng_run) THEN
            resultout := wf_engine.eng_null;
            RETURN;
    END IF;
     NULL;
        l_assignment_id := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'ASSIGNMENT_ID');
        l_project_id     := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'PROJECT_ID' );
--  Now populate the PL/SQL table with the 2 approvers
--  which are done by the product by default
    FOR i IN 1..2
      LOOP
    l_item_attr_name := 'APPROVER_'||i||'_PERSON_ID';
        l_approver_person_id :=
                             wf_engine.GetItemAttrNumber
                   (  itemtype => itemtype
                                , itemkey =>  itemkey
                                , aname => l_item_attr_name
                               );

    l_item_attr_name := 'APPROVER'||i||'_USER_NAME';
        l_approver_user_name := wf_engine.GetItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname =>  l_item_attr_name
                               );
    l_item_attr_name := 'APPROVER_'||i||'_TYPE';
        l_approver_type :=    wf_engine.GetItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname =>  l_item_attr_name
                               );
    IF l_approver_user_name IS NOT NULL THEN
         l_approvers_list_rec.User_Name := l_approver_user_name;
         l_approvers_list_rec.Person_id := l_approver_person_id;
         l_approvers_list_rec.Type :=  l_approver_type;
         l_approvers_list_rec.Routing_Order :=  i;
         l_approvers_list_tbl(l_approvers_list_tbl_idx) := l_approvers_list_rec;
         l_approvers_list_tbl_idx := l_approvers_list_tbl_idx + 1;
       END IF;
     END LOOP;
    -- Pass the pl/sql table to the client extension so
    -- users can customize the approvers
   PA_CLIENT_EXTN_ASGMT_WF.Generate_Assignment_Approvers
    (p_assignment_id                => l_assignment_id
    ,p_project_id               => l_project_id
    ,p_in_list_of_approvers     => l_approvers_list_tbl
    ,x_out_list_of_approvers        => l_out_approvers_list_tbl
    ,x_number_of_approvers      => l_number_of_approvers );

    -- Call the populate_wf_performers procedure
    populate_wf_performers
        ( p_wf_type_code => 'ASSIGNMENT_APPROVAL'
         ,p_item_type    => itemtype
         ,p_item_key     => itemkey
         ,p_object_id1  => l_assignment_id
         ,p_object_id2  => l_project_id
         ,p_in_performers_tbl => l_out_approvers_list_tbl
         ,p_current_approver_flag  => 'N'
     ,x_number_of_performers => l_number_of_approvers );

    -- Now set the number of approvers
           wf_engine.SetItemAttrNumber
                   (  itemtype => itemtype
                                , itemkey =>  itemkey
                                , aname => 'NUMBER_OF_APPROVERS'
                                , avalue => l_number_of_approvers
                               );
           pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Generate_Approvers',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
     RAISE;
END Generate_Approvers ;

PROCEDURE get_Approver         (itemtype IN VARCHAR2
                               ,itemkey IN VARCHAR2
                               ,actid IN NUMBER
                               ,funcmode IN VARCHAR2
                               ,resultout OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895
l_number_of_approvers  NUMBER := 0;
l_approver_loop_counter NUMBER := 0;
l_approver_item_attr_name VARCHAR2(30);
l_approver_user_name pa_wf_ntf_performers.user_name%TYPE; ----VARCHAR2(240); Commented for bug 3267790
l_prev_approver_user_name wf_users.name%TYPE;             ----VARCHAR2(240); Commented for bug 3267790 as this takes the value from wf_users
l_approver_type      VARCHAR2(30);
l_assignment_id   NUMBER;
l_wf_startedby_uname fnd_user.user_name%type;

BEGIN
    /*
     Get item attr approvals loop counter and number of approvers
     Approvals loop counter := approvals loop counter + 1;
     If approvals loop counter > number of approvers , resultout = 'F'
          and return
     Else if approval loop counter = 1, set performer to approver1
     and so on.
     Set performer item attr concat with approvals loop counter
     Set approvals loop counter
     Resultout = 'S'
    */
        -- Return if WF Not Running
        pa_debug.init_err_stack ('pa_asgmt_wfstd.get_approver');
    IF (funcmode <> wf_engine.eng_run) THEN
            resultout := wf_engine.eng_null;
            RETURN;
    END IF;
           l_number_of_approvers := wf_engine.GetItemAttrNumber
                   (  itemtype => itemtype
                                , itemkey =>  itemkey
                                , aname => 'NUMBER_OF_APPROVERS'
                               );
           l_approver_loop_counter := wf_engine.getItemAttrNumber
                   (  itemtype => itemtype
                                , itemkey =>  itemkey
                                , aname => 'APPROVER_LOOP_COUNTER'
                               );
           l_assignment_id := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'ASSIGNMENT_ID');

       l_approver_loop_counter := l_approver_loop_counter + 1;
    IF l_approver_loop_counter > l_number_of_approvers THEN
             resultout := wf_engine.eng_completed||':'||'F';
         RETURN ;
    END IF;
        get_wf_performer (p_wf_type_code => 'ASSIGNMENT_APPROVAL'
              ,p_item_type   => itemtype
              ,p_item_key    => itemkey
              ,p_routing_order => l_approver_loop_counter
                  ,p_object_id1  => l_assignment_id
              ,x_performer_name => l_approver_user_name
              ,x_performer_type => l_approver_type );

    IF l_approver_user_name IS NULL THEN
             resultout := wf_engine.eng_completed||':'||'F';
         RETURN ;
    END IF;
    -- In order to set the forwarded from, capture the current
    -- approver before modifying the same
    -- Set the current approver as the previous approver
    -- Handling a NULL previous approver (which is likely when
    -- the current approver is the first approver) is done
    -- in the Set forwarded from procedure
    l_prev_approver_user_name := wf_engine.GetItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'APPROVER_UNAME'
                               );
        wf_engine.SetItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'PREV_APPROVER_UNAME'
                               , avalue => l_prev_approver_user_name
                               );
        wf_engine.SetItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'APPROVER_UNAME'
                               , avalue => l_approver_user_name
                               );
           wf_engine.SetItemAttrNumber
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'APPROVER_LOOP_COUNTER'
                               , avalue => l_approver_loop_counter
                               );

/*Added the code for the bug 3595857*/
    IF l_approver_loop_counter = 1 THEN
        l_wf_startedby_uname := wf_engine.GetItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'WORKFLOW_STARTED_BY_UNAME'
                               );

           wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey => itemkey
                               , aname => 'FROM_ROLE_VALUE'
                               , avalue =>  l_wf_startedby_uname
                               );
   ELSE
               wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey => itemkey
                               , aname => 'FROM_ROLE_VALUE'
                               , avalue => l_prev_approver_user_name
                               );
    END IF;
    /*End of the code addition for the bug 3595857*/

        -- Need to set the current user as the current approver
        -- and set the flag to 'N' for the rest
        --
        UPDATE pa_wf_ntf_performers
        SET current_approver_flag =
        (DECODE(user_name,l_approver_user_name,'Y','N'))
        WHERE item_type = itemtype
        AND   item_key  = itemkey
        AND   object_id1 = l_assignment_id;
            resultout := wf_engine.eng_completed||':'||'S';
           pa_debug.reset_err_stack;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Get_Approver',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
     RAISE;
END Get_Approver ;

PROCEDURE Generate_apprvl_nf_recipients
                    (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

l_approval_nf_rects_tbl  PA_CLIENT_EXTN_ASGMT_WF.Users_List_Tbltyp ;
l_out_approval_nf_rects_tbl  PA_CLIENT_EXTN_ASGMT_WF.Users_List_Tbltyp ;
l_number_of_recipients  NUMBER := 0;
l_approval_nf_rects_rec  PA_CLIENT_EXTN_ASGMT_WF.Users_List_Rectyp ;
l_assignment_id   pa_project_assignments.assignment_id%TYPE;
l_project_id      pa_projects_all.project_id%TYPE;
l_approval_nf_rect_username   VARCHAR2(100);  /* Modified length from 30 to 100 for bug 3148857 */
l_rect_person_id  NUMBER := 0;
l_recipient_type   VARCHAR2(30);
l_item_attr_name  VARCHAR2(30);
l_number_of_apprvl_nf_rects  NUMBER := 0;
l_approval_nf_loop_counter  NUMBER := 0;
l_ntfy_rect_item_attr_name VARCHAR2(30);
l_ntfy_apprvl_recipient_name wf_users.name%TYPE;  ---VARCHAR2(240); Changed for bug 3267790
l_ntfy_apprvl_rect_person_id NUMBER := 0;
l_ntfy_apprvl_rect_type VARCHAR2(30);
l_apprvl_item_type  VARCHAR2(30);
l_apprvl_item_key  VARCHAR2(30);
l_number_of_apprvl_recipients NUMBER := 0;

BEGIN
    -- This will not do anything in milestone 1. In version 1
    -- appropriate client extensions will be called

       pa_debug.init_err_stack ('pa_asgmt_wfstd.Generate_apprvl_nf_recipients');
        -- Return if WF Not Running
    IF (funcmode <> wf_engine.eng_run) THEN
            resultout := wf_engine.eng_null;
            RETURN;
    END IF;
        l_assignment_id := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'ASSIGNMENT_ID');
        l_project_id     := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'PROJECT_ID' );
--  Now populate the PL/SQL table with the 4 recipients
--  which are done by the product by default
        l_number_of_apprvl_nf_rects := wf_engine.GetItemAttrNumber
                   (  itemtype => itemtype
                                , itemkey =>  itemkey
                                , aname => 'NUMBER_OF_APPRVL_NF_RECIPIENTS'
                               );

    l_apprvl_item_type  := wf_engine.getItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'APPRVL_ITEM_TYPE' );

    l_apprvl_item_key   := wf_engine.getItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'APPRVL_ITEM_KEY');

     FOR i IN 1..l_number_of_apprvl_nf_rects  LOOP
       l_ntfy_rect_item_attr_name :=
        'APPROVAL_NF_REC'||i||'_USER_NAME';
           l_ntfy_apprvl_recipient_name := wf_engine.getItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => l_ntfy_rect_item_attr_name
                               );
       l_ntfy_rect_item_attr_name :=
        'APPROVAL_NF_REC'||i||'_USER_TYPE';
           l_ntfy_apprvl_rect_type := wf_engine.getItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => l_ntfy_rect_item_attr_name
                               );
       l_ntfy_rect_item_attr_name :=
        'APPROVAL_NF_REC'||i||'_PERSON_ID';
           l_ntfy_apprvl_rect_person_id := wf_engine.getItemAttrNumber
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => l_ntfy_rect_item_attr_name
                               );
       IF l_ntfy_apprvl_recipient_name IS NOT NULL THEN
              l_number_of_apprvl_recipients := l_number_of_apprvl_recipients + 1;
              l_approval_nf_rects_rec.User_Name := l_ntfy_apprvl_recipient_name;
              l_approval_nf_rects_rec.Person_id := l_ntfy_apprvl_rect_person_id;
              l_approval_nf_rects_rec.Type      := l_ntfy_apprvl_rect_type;
              l_approval_nf_rects_rec.Routing_Order :=  l_number_of_apprvl_recipients;
              l_approval_nf_rects_tbl(l_number_of_apprvl_recipients) := l_approval_nf_rects_rec;
           END IF;
     END LOOP;
    -- Pass the pl/sql table to the client extension so
    -- users can customize the approvers

     PA_CLIENT_EXTN_ASGMT_WF.Generate_NF_Recipients
    (p_assignment_id                => l_assignment_id
    ,p_project_id               => l_project_id
    ,p_notification_type            => 'APPROVAL_FYI'
    ,p_in_list_of_recipients        => l_approval_nf_rects_tbl
    ,x_out_list_of_recipients       => l_out_approval_nf_rects_tbl
    ,x_number_of_recipients     => l_number_of_recipients );

    populate_wf_performers
        ( p_wf_type_code => 'APPROVAL_FYI'
         ,p_item_type    => itemtype
         ,p_item_key     => itemkey
         ,p_object_id1  => l_assignment_id
         ,p_object_id2  => l_project_id
         ,p_in_performers_tbl => l_out_approval_nf_rects_tbl
         ,p_current_approver_flag  => 'N'
     ,x_number_of_performers => l_number_of_recipients );

    -- Now set the number of approvl nf recipients based
    -- on how many records were inserted

         wf_engine.SetItemAttrNumber
            (itemtype => itemtype
                        ,itemkey =>  itemkey
                        ,aname => 'NUMBER_OF_APPRVL_NF_RECIPIENTS'
                        ,avalue => l_number_of_recipients
            );
    -- Now populate the Comments fields, which would have
    -- been stored in the pa_wf_ntf_performers table
       IF (l_apprvl_item_type IS NOT NULL AND l_apprvl_item_key
           IS NOT NULL ) THEN
         Set_approver_comments  (p_apprvl_item_type => l_apprvl_item_type
                ,p_apprvl_item_key  => l_apprvl_item_key
                ,p_item_type        => itemtype
                ,p_item_key         => itemkey
                ,p_assignment_id    => l_assignment_id);
      END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Generate_apprvl_nf_recipients',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
     RAISE;
END Generate_apprvl_nf_recipients ;

PROCEDURE Get_Approval_NF_Recipient
                                (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 )  IS --File.Sql.39 bug 4440895

l_number_of_apprvl_nf_rects  NUMBER := 0;
l_approval_nf_loop_counter  NUMBER := 0;
l_ntfy_rect_item_attr_name VARCHAR2(30);
l_ntfy_apprvl_recipient_name pa_wf_ntf_performers.user_name%TYPE; ---VARCHAR2(240); Changed for bug 3267790
l_ntfy_apprvl_rect_type VARCHAR2(30);
l_assignment_id NUMBER := 0;

BEGIN
    /*
     Get item attr approval nf rect loop counter and number of rects
     Approvals nf rect loop counter := approvals nf rect loop counter + 1;
     If loop counter > number of rcts , resultout = 'F'
          and return
     Read the wf performers table and get the
     recipient record based on the loop counter.
     Set performer to the retrieved record
     If performer = resource , remove all comments
     else restore the comments
     Set loop counter
     Resultout = 'T'
    */
        -- Return if WF Not Running
    IF (funcmode <> wf_engine.eng_run) THEN
            resultout := wf_engine.eng_null;
            RETURN;
    END IF;
           l_number_of_apprvl_nf_rects := wf_engine.GetItemAttrNumber
                   (  itemtype => itemtype
                                , itemkey =>  itemkey
                                , aname => 'NUMBER_OF_APPRVL_NF_RECIPIENTS'
                               );
           l_approval_nf_loop_counter := wf_engine.getItemAttrNumber
                   (  itemtype => itemtype
                                , itemkey =>  itemkey
                                , aname => 'APPROVAL_NF_LOOP_COUNTER'
                               );
           l_assignment_id := wf_engine.getItemAttrNumber
                   (  itemtype => itemtype
                                , itemkey =>  itemkey
                                , aname => 'ASSIGNMENT_ID'
                               );
     l_approval_nf_loop_counter := l_approval_nf_loop_counter + 1;
     IF l_approval_nf_loop_counter > l_number_of_apprvl_nf_rects THEN
             resultout := wf_engine.eng_completed||':'||'F';
         RETURN;
         END IF;
        get_wf_performer (p_wf_type_code => 'APPROVAL_FYI'
              ,p_item_type   => itemtype
              ,p_item_key    => itemkey
              ,p_routing_order => l_approval_nf_loop_counter
                  ,p_object_id1  =>  l_assignment_id
              ,x_performer_name =>l_ntfy_apprvl_recipient_name
              ,x_performer_type =>l_ntfy_apprvl_rect_type );
           wf_engine.SetItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'NTFY_APPRVL_RECIPIENT_NAME'
                               , avalue => l_ntfy_apprvl_recipient_name
                               );
           wf_engine.SetItemAttrNumber
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'APPROVAL_NF_LOOP_COUNTER'
                               , avalue => l_approval_nf_loop_counter
                               );
        -- Do not show comments if the recipient is the resource
        -- otherwise show the comments. To achieve this, set the
        -- displayed comments field appropriately
        -- This is done in the set_comments procedure
           Set_Comment_Attributes (p_item_type => itemtype,
                       p_item_key  => itemkey ,
                       p_rect_type =>
                       l_ntfy_apprvl_rect_type );

            resultout := wf_engine.eng_completed||':'||'S';
EXCEPTION
WHEN OTHERS THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Get_Approval_NF_Recipient',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
     RAISE;
END Get_Approval_NF_Recipient ;

  PROCEDURE Generate_reject_nf_recipients
                                (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 )  IS --File.Sql.39 bug 4440895
l_reject_nf_rects_tbl  PA_CLIENT_EXTN_ASGMT_WF.Users_List_Tbltyp ;
l_out_reject_nf_rects_tbl  PA_CLIENT_EXTN_ASGMT_WF.Users_List_Tbltyp ;
l_number_of_recipients  NUMBER := 0;
l_reject_nf_rects_rec  PA_CLIENT_EXTN_ASGMT_WF.Users_List_Rectyp ;
l_assignment_id   pa_project_assignments.assignment_id%TYPE;
l_project_id      pa_projects_all.project_id%TYPE;
l_reject_nf_rect_username   wf_users.name%type; ---VARCHAR2(100); /* Modified length from 30 to 100 for bug 3148857 */ -- Changed for bug 3267790
l_rect_person_id  NUMBER := 0;
l_recipient_type   VARCHAR2(30);
l_item_attr_name  VARCHAR2(30);
l_number_of_reject_nf_rects  NUMBER := 0;
l_reject_nf_loop_counter  NUMBER := 0;
l_ntfy_rect_item_attr_name VARCHAR2(30);
l_ntfy_reject_recipient_name wf_users.name%type; ----- VARCHAR2(240);Changed for bug 3267790
l_ntfy_reject_rect_person_id NUMBER := 0;
l_ntfy_reject_rect_type VARCHAR2(30);
l_apprvl_item_type  VARCHAR2(30);
l_apprvl_item_key  VARCHAR2(30);

BEGIN
        -- Return if WF Not Running
    IF (funcmode <> wf_engine.eng_run) THEN
            resultout := wf_engine.eng_null;
            RETURN;
    END IF;
        l_assignment_id := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'ASSIGNMENT_ID');
        l_project_id     := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'PROJECT_ID' );
--  Now populate the PL/SQL table with the 4 recipients
--  which are done by the product by default
        l_number_of_reject_nf_rects := wf_engine.GetItemAttrNumber
                   (  itemtype => itemtype
                                , itemkey =>  itemkey
                                , aname => 'NUMBER_OF_REJECT_NF_RECIPIENTS'
                               );

    l_apprvl_item_type  := wf_engine.getItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'APPRVL_ITEM_TYPE' );

    l_apprvl_item_key   := wf_engine.getItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'APPRVL_ITEM_KEY');

    FOR i IN 1..l_number_of_reject_nf_rects
     LOOP
       l_ntfy_rect_item_attr_name :=
        'REJECT_NF_REC'||i||'_USER_NAME';
           l_ntfy_reject_recipient_name := wf_engine.getItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => l_ntfy_rect_item_attr_name
                               );
       l_ntfy_rect_item_attr_name :=
        'REJECT_NF_REC'||i||'_USER_TYPE';
           l_ntfy_reject_rect_type := wf_engine.getItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => l_ntfy_rect_item_attr_name
                               );
       l_ntfy_rect_item_attr_name :=
        'REJECT_NF_REC'||i||'_PERSON_ID';
           l_ntfy_reject_rect_person_id := wf_engine.getItemAttrNumber
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => l_ntfy_rect_item_attr_name
                               );
       IF l_ntfy_reject_recipient_name IS NOT NULL THEN
              l_reject_nf_rects_rec.User_Name := l_ntfy_reject_recipient_name;
              l_reject_nf_rects_rec.Person_id :=
             l_ntfy_reject_rect_person_id;
              l_reject_nf_rects_rec.Type      :=
             l_ntfy_reject_rect_type;
              l_reject_nf_rects_rec.Routing_Order :=  i;
              l_reject_nf_rects_tbl(i)        := l_reject_nf_rects_rec;
           END IF;
     END LOOP;
    -- Pass the pl/sql table to the client extension so
    -- users can customize the approvers

     PA_CLIENT_EXTN_ASGMT_WF.Generate_NF_Recipients
    (p_assignment_id                => l_assignment_id
    ,p_project_id               => l_project_id
    ,p_notification_type            => 'REJECTION_FYI'
    ,p_in_list_of_recipients        => l_reject_nf_rects_tbl
    ,x_out_list_of_recipients       => l_out_reject_nf_rects_tbl
    ,x_number_of_recipients     => l_number_of_recipients );

    populate_wf_performers
        ( p_wf_type_code => 'REJECTION_FYI'
         ,p_item_type    => itemtype
         ,p_item_key     => itemkey
         ,p_object_id1  => l_assignment_id
         ,p_object_id2  => l_project_id
         ,p_in_performers_tbl => l_out_reject_nf_rects_tbl
         ,p_current_approver_flag  => 'N'
     ,x_number_of_performers => l_number_of_recipients );

    -- Now set the number of reject nf recipients based
    -- on how many records were inserted

         wf_engine.SetItemAttrNumber
            (itemtype => itemtype
                        ,itemkey =>  itemkey
                        ,aname => 'NUMBER_OF_REJECT_NF_RECIPIENTS'
                        ,avalue => l_number_of_recipients
            );
    -- Now populate the Comments fields, which would have
    -- been stored in the pa_wf_ntf_performers table
       IF (l_apprvl_item_type IS NOT NULL AND l_apprvl_item_key
           IS NOT NULL ) THEN
         Set_approver_comments  (p_apprvl_item_type => l_apprvl_item_type
                ,p_apprvl_item_key  => l_apprvl_item_key
                ,p_item_type        => itemtype
                ,p_item_key         => itemkey
                ,p_assignment_id    => l_assignment_id);
      END IF;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Generate_reject_nf_recipients',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
     RAISE;
END Generate_reject_nf_recipients ;

PROCEDURE Get_Reject_NF_Recipient
                    (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

l_number_of_reject_nf_rects  NUMBER := 0;
l_rejection_nf_loop_counter  NUMBER := 0;
l_ntfy_rect_item_attr_name VARCHAR2(30);
l_ntfy_reject_recipient_name pa_wf_ntf_performers.user_name%type; ----- VARCHAR2(240);Changed for bug 3267790
l_ntfy_reject_rect_type VARCHAR2(30);
l_assignment_id NUMBER := 0;

BEGIN
    /*
     Get item attr reject nf rect loop counter and number of rects
     reject nf rect loop counter := reject nf rect loop counter + 1;
     If loop counter > number of rcts , resultout = 'F'
          and return
     Read the wf performers table and get the
     recipient record based on the loop counter.
     Set performer to the retrieved record
     If performer = resource , remove all comments
     else restore the comments
     Set loop counter
     Resultout = 'T'
    */
           -- Return if WF Not Running
       IF (funcmode <> wf_engine.eng_run) THEN
               resultout := wf_engine.eng_null;
               RETURN;
       END IF;
           l_number_of_reject_nf_rects := wf_engine.GetItemAttrNumber
                   (  itemtype => itemtype
                                , itemkey =>  itemkey
                                , aname => 'NUMBER_OF_REJECT_NF_RECIPIENTS'
                               );
           l_rejection_nf_loop_counter := wf_engine.getItemAttrNumber
                   (  itemtype => itemtype
                                , itemkey =>  itemkey
                                , aname => 'REJECTION_NF_LOOP_COUNTER'
                               );

           l_assignment_id := wf_engine.getItemAttrNumber
                   (  itemtype => itemtype
                                , itemkey =>  itemkey
                                , aname => 'ASSIGNMENT_ID'
                               );
     l_rejection_nf_loop_counter := l_rejection_nf_loop_counter + 1;
     IF l_rejection_nf_loop_counter > l_number_of_reject_nf_rects THEN
             resultout := wf_engine.eng_completed||':'||'F';
         RETURN;
         END IF;
        get_wf_performer (p_wf_type_code => 'REJECTION_FYI'
              ,p_item_type   => itemtype
              ,p_item_key    => itemkey
              ,p_routing_order => l_rejection_nf_loop_counter
                  ,p_object_id1  =>  l_assignment_id
              ,x_performer_name =>l_ntfy_reject_recipient_name
              ,x_performer_type =>l_ntfy_reject_rect_type );
           wf_engine.SetItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'NTFY_REJECT_RECIPIENT_NAME'
                               , avalue => l_ntfy_reject_recipient_name
                               );
           wf_engine.SetItemAttrNumber
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'REJECTION_NF_LOOP_COUNTER'
                               , avalue => l_rejection_nf_loop_counter
                               );
        -- Do not show comments if the recipient is the resource
        -- otherwise show the comments. To achieve this, set the
        -- displayed comments field appropriately
        -- This is done in the set_comments procedure
           Set_Comment_Attributes (p_item_type => itemtype,
                       p_item_key  => itemkey ,
                       p_rect_type =>
                       l_ntfy_reject_rect_type );
            resultout := wf_engine.eng_completed||':'||'S';
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Get_Reject_NF_Recipient',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
     RAISE;
END Get_Reject_NF_Recipient ;



  PROCEDURE Generate_cancel_nf_recipients
                                (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 )  IS --File.Sql.39 bug 4440895
l_cancel_nf_rects_tbl  PA_CLIENT_EXTN_ASGMT_WF.Users_List_Tbltyp ;
l_out_cancel_nf_rects_tbl  PA_CLIENT_EXTN_ASGMT_WF.Users_List_Tbltyp ;
l_number_of_recipients  NUMBER := 0;
l_cancel_nf_rects_rec  PA_CLIENT_EXTN_ASGMT_WF.Users_List_Rectyp ;
l_assignment_id   pa_project_assignments.assignment_id%TYPE;
l_project_id      pa_projects_all.project_id%TYPE;
l_cancel_nf_rect_username  wf_users.name%type; ----- VARCHAR2(30);Changed for bug 3267790
--VARCHAR2(100); /* Modified length from 30 to 100 for bug 3148857 */
l_rect_person_id  NUMBER := 0;
l_recipient_type   VARCHAR2(30);
l_item_attr_name  VARCHAR2(30);
l_number_of_cancel_nf_rects  NUMBER := 0;
l_cancel_nf_loop_counter  NUMBER := 0;
l_ntfy_rect_item_attr_name VARCHAR2(30);
l_ntfy_cancel_recipient_name wf_users.name%type; --- VARCHAR2(240);Changed for bug 3267790
l_ntfy_cancel_rect_person_id NUMBER := 0;
l_ntfy_cancel_rect_type VARCHAR2(30);
l_apprvl_item_type  VARCHAR2(30);
l_apprvl_item_key  VARCHAR2(30);

l_counter NUMBER := 0; -- local variable for bug 7511389

BEGIN
        -- Return if WF Not Running
    IF (funcmode <> wf_engine.eng_run) THEN
            resultout := wf_engine.eng_null;
            RETURN;
    END IF;
        l_assignment_id := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'ASSIGNMENT_ID');
        l_project_id     := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'PROJECT_ID' );
--  Now populate the PL/SQL table with the 4 recipients
--  which are done by the product by default
        l_number_of_cancel_nf_rects := wf_engine.GetItemAttrNumber
                   (  itemtype => itemtype
                                , itemkey =>  itemkey
                                , aname => 'NUMBER_OF_CANCEL_NF_RECIPIENTS'
                               );

    l_apprvl_item_type  := wf_engine.getItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'APPRVL_ITEM_TYPE' );

    l_apprvl_item_key   := wf_engine.getItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'APPRVL_ITEM_KEY');

    FOR i IN 1..l_number_of_cancel_nf_rects
     LOOP
       l_ntfy_rect_item_attr_name :=
        'CANCEL_NF_REC'||i||'_USER_NAME';
           l_ntfy_cancel_recipient_name := wf_engine.getItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => l_ntfy_rect_item_attr_name
                               );
       l_ntfy_rect_item_attr_name :=
        'CANCEL_NF_REC'||i||'_USER_TYPE';
           l_ntfy_cancel_rect_type := wf_engine.getItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => l_ntfy_rect_item_attr_name
                               );
       l_ntfy_rect_item_attr_name :=
        'CANCEL_NF_REC'||i||'_PERSON_ID';
           l_ntfy_cancel_rect_person_id := wf_engine.getItemAttrNumber
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => l_ntfy_rect_item_attr_name
                               );
       IF l_ntfy_cancel_recipient_name IS NOT NULL THEN

       /*Bug 7511389 : increasing the counter */
       l_counter := l_counter + 1;

              l_cancel_nf_rects_rec.User_Name := l_ntfy_cancel_recipient_name;
              l_cancel_nf_rects_rec.Person_id :=
             l_ntfy_cancel_rect_person_id;
              l_cancel_nf_rects_rec.Type      :=
             l_ntfy_cancel_rect_type;

             /*For bug 7511389 : removing 'i' and using 'l_counter' instead */
--              l_cancel_nf_rects_rec.Routing_Order :=  i;
--              l_cancel_nf_rects_tbl(i)        := l_cancel_nf_rects_rec;
                l_cancel_nf_rects_rec.Routing_Order :=  l_counter;
                l_cancel_nf_rects_tbl(l_counter)        := l_cancel_nf_rects_rec;
           END IF;
     END LOOP;
    -- Pass the pl/sql table to the client extension so
    -- users can customize the approvers

     PA_CLIENT_EXTN_ASGMT_WF.Generate_NF_Recipients
    (p_assignment_id                => l_assignment_id
    ,p_project_id               => l_project_id
    ,p_notification_type            => 'CANCELLATION_FYI'
    ,p_in_list_of_recipients        => l_cancel_nf_rects_tbl
    ,x_out_list_of_recipients       => l_out_cancel_nf_rects_tbl
    ,x_number_of_recipients     => l_number_of_recipients );

    populate_wf_performers
        ( p_wf_type_code => 'CANCELLATION_FYI'
         ,p_item_type    => itemtype
         ,p_item_key     => itemkey
         ,p_object_id1  => l_assignment_id
         ,p_object_id2  => l_project_id
         ,p_in_performers_tbl => l_out_cancel_nf_rects_tbl
         ,p_current_approver_flag  => 'N'
     ,x_number_of_performers => l_number_of_recipients );

    -- Now set the number of cancel nf recipients based
    -- on how many records were inserted

         wf_engine.SetItemAttrNumber
            (itemtype => itemtype
                        ,itemkey =>  itemkey
                        ,aname => 'NUMBER_OF_CANCEL_NF_RECIPIENTS'
                        ,avalue => l_number_of_recipients
            );
    -- Now populate the Comments fields, which would have
    -- been stored in the pa_wf_ntf_performers table
       IF (l_apprvl_item_type IS NOT NULL AND l_apprvl_item_key
           IS NOT NULL ) THEN
         Set_approver_comments  (p_apprvl_item_type => l_apprvl_item_type
                ,p_apprvl_item_key  => l_apprvl_item_key
                ,p_item_type        => itemtype
                ,p_item_key         => itemkey
                ,p_assignment_id    => l_assignment_id);
      END IF;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Generate_cancel_nf_recipients',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
     RAISE;
END Generate_cancel_nf_recipients ;


PROCEDURE Get_Cancel_NF_Recipient
                    (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

l_number_of_cancel_nf_rects  NUMBER := 0;
l_cancellation_nf_loop_counter  NUMBER := 0;
l_ntfy_rect_item_attr_name VARCHAR2(30);
l_ntfy_cancel_recipient_name pa_wf_ntf_performers.user_name%TYPE; ----- VARCHAR2(240);Changed for bug 3267790
l_ntfy_cancel_rect_type VARCHAR2(30);
l_assignment_id NUMBER := 0;

BEGIN
    /*
     Get item attr cancel nf rect loop counter and number of rects
     cancel nf rect loop counter := cancel nf rect loop counter + 1;
     If loop counter > number of rcts , resultout = 'F'
          and return
     Read the wf performers table and get the
     recipient record based on the loop counter.
     Set performer to the retrieved record
     If performer = resource , remove all comments
     else restore the comments
     Set loop counter
     Resultout = 'T'
    */
           -- Return if WF Not Running
       IF (funcmode <> wf_engine.eng_run) THEN
               resultout := wf_engine.eng_null;
               RETURN;
       END IF;
           l_number_of_cancel_nf_rects := wf_engine.GetItemAttrNumber
                   (  itemtype => itemtype
                                , itemkey =>  itemkey
                                , aname => 'NUMBER_OF_CANCEL_NF_RECIPIENTS'
                               );
           l_cancellation_nf_loop_counter := wf_engine.getItemAttrNumber
                   (  itemtype => itemtype
                                , itemkey =>  itemkey
                                , aname => 'CANCELLATION_NF_LOOP_COUNTER'
                               );

           l_assignment_id := wf_engine.getItemAttrNumber
                   (  itemtype => itemtype
                                , itemkey =>  itemkey
                                , aname => 'ASSIGNMENT_ID'
                               );
     l_cancellation_nf_loop_counter := l_cancellation_nf_loop_counter + 1;
     IF l_cancellation_nf_loop_counter > l_number_of_cancel_nf_rects THEN
             resultout := wf_engine.eng_completed||':'||'F';
         RETURN;
         END IF;
        get_wf_performer (p_wf_type_code => 'CANCELLATION_FYI'
              ,p_item_type   => itemtype
              ,p_item_key    => itemkey
              ,p_routing_order => l_cancellation_nf_loop_counter
                  ,p_object_id1  =>  l_assignment_id
              ,x_performer_name =>l_ntfy_cancel_recipient_name
              ,x_performer_type =>l_ntfy_cancel_rect_type );
           wf_engine.SetItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'NTFY_CANCEL_RECIPIENT_NAME'
                               , avalue => l_ntfy_cancel_recipient_name
                               );
           wf_engine.SetItemAttrNumber
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'CANCELLATION_NF_LOOP_COUNTER'
                               , avalue => l_cancellation_nf_loop_counter
                               );
        -- Do not show comments if the recipient is the resource
        -- otherwise show the comments. To achieve this, set the
        -- displayed comments field appropriately
        -- This is done in the set_comments procedure
           Set_Comment_Attributes (p_item_type => itemtype,
                       p_item_key  => itemkey ,
                       p_rect_type =>
                       l_ntfy_cancel_rect_type );
            resultout := wf_engine.eng_completed||':'||'S';
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Get_Cancel_NF_Recipient',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
     RAISE;
END Get_Cancel_NF_Recipient ;



PROCEDURE Set_Forwarded_From  (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895
l_forwarded_from  wf_users.name%type; ----- VARCHAR2(240); Changed for bug 3267790
BEGIN

        -- Return if WF Not Running
    IF (funcmode <> wf_engine.eng_run) THEN
            resultout := wf_engine.eng_null;
            RETURN;
    END IF;
    -- The approval notification would have been forwarded
    -- from either the initial submittor or the last approver
    -- Prev Approver uname is set only in get approver node
    -- Hence, if that value is not set, get the value
    -- from workflow started by uname attribute, which
    -- is always set at the time of starting the workflow
     l_forwarded_from := wf_engine.GetItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'PREV_APPROVER_UNAME'
                               );
     IF l_forwarded_from IS NULL THEN
        l_forwarded_from := wf_engine.GetItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'WORKFLOW_STARTED_BY_UNAME'
                               );
     END IF;
      -- Now set the forwarded from field
         wf_engine.SetItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'FORWARDED_FROM'
                               , avalue => l_forwarded_from
                               );
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Set_Forwarded_From',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
     RAISE;
END Set_Forwarded_From;

PROCEDURE Set_Approval_Reqd_Msg (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
l_assignment_type   pa_project_assignments.assignment_type%TYPE;
l_reapproval_flag   VARCHAR2(1);
BEGIN
    IF (funcmode <> wf_engine.eng_run) THEN
            resultout := wf_engine.eng_null;
            RETURN;
    END IF;
        -- Check whether the assignment is work or admin assignment
    -- If work assignment check whether this is a reapproval
    -- Accordingly set the attributes for MSG_SUBJECT and MSG_DESCRIPTION
    -- All this is done in the Set_NF_Subject_and_Desc procedure

    l_assignment_type := wf_engine.GetItemAttrText
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'ASSIGNMENT_TYPE');

    l_reapproval_flag := wf_engine.GetItemAttrText
                 (itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'REAPPROVAL_FLAG');

    -- Set the appropriate notification subject and description
    -- item attributes

        Set_NF_Subject_and_Desc  (p_item_type   => itemtype,
                  p_item_key    => itemkey,
                  p_assignment_type => l_assignment_type,
                  p_reapproval_flag => l_reapproval_flag,
                  p_msg_type        => 'ASSIGNMENT_APPROVAL');

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Set_Approval_Reqd_Msg',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
     RAISE;
END Set_Approval_Reqd_Msg ;

PROCEDURE Set_Approved_Msg   (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
BEGIN
    IF (funcmode <> wf_engine.eng_run) THEN
            resultout := wf_engine.eng_null;
            RETURN;
    END IF;

    -- Set the appropriate notification subject and description
    -- item attributes
    -- assignment type and re-approval flags are not needed for
    -- the approved FYI messages

        Set_NF_Subject_and_Desc  (p_item_type   => itemtype,
                  p_item_key    => itemkey,
                  p_assignment_type => NULL,
                  p_reapproval_flag => NULL,
                  p_msg_type        => 'APPROVAL_FYI');

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Set_Approved_Msg',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
     RAISE;
END Set_Approved_Msg;

PROCEDURE Set_Rejected_Msg     (itemtype IN VARCHAR2
                               ,itemkey IN VARCHAR2
                               ,actid IN NUMBER
                               ,funcmode IN VARCHAR2
                               ,resultout OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

IS
BEGIN
    IF (funcmode <> wf_engine.eng_run) THEN
            resultout := wf_engine.eng_null;
            RETURN;
    END IF;

    -- Set the appropriate notification subject and description
    -- item attributes
    -- assignment type and re-approval flags are not needed for
    -- the rejected FYI messages

        Set_NF_Subject_and_Desc  (p_item_type   => itemtype,
                  p_item_key    => itemkey,
                  p_assignment_type => NULL,
                  p_reapproval_flag => NULL,
                  p_msg_type        => 'REJECTION_FYI');
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Set_Rejected_Msg',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
     RAISE;
END Set_Rejected_Msg;


PROCEDURE Set_Canceled_Msg     (itemtype IN VARCHAR2
                               ,itemkey IN VARCHAR2
                               ,actid IN NUMBER
                               ,funcmode IN VARCHAR2
                               ,resultout OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

IS
BEGIN
    IF (funcmode <> wf_engine.eng_run) THEN
            resultout := wf_engine.eng_null;
            RETURN;
    END IF;

    -- Set the appropriate notification subject and description
    -- item attributes
    -- assignment type and re-approval flags are not needed for
    -- the rejected FYI messages

        Set_NF_Subject_and_Desc  (p_item_type   => itemtype,
                  p_item_key    => itemkey,
                  p_assignment_type => NULL,
                  p_reapproval_flag => NULL,
                  p_msg_type        => 'CANCELLATION_FYI');
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Set_Canceled_Msg',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
     RAISE;
END Set_Canceled_Msg;


PROCEDURE Validate_Forwarded_User
                    ( itemtype IN VARCHAR2
                                , itemkey IN VARCHAR2
                                , actid IN NUMBER
                                , funcmode IN VARCHAR2
                                , resultout OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895
l_msg_text   VARCHAR2(240);
invalid_user_exception EXCEPTION;
BEGIN
/*
    IF funcmode = 'FORWARD' THEN
      Notification assignee validations go here
      get the assigned user which is available in wf_engine.context_text
      validate this user
      If not valid user fnd_message.set_name ('PA','PA_NO_RESOURCE_AUTHORITY');
      l_msg_text := fnd_message.get;
      RAISE invalid_user_exception;
          END IF;
*/
    NULL;
EXCEPTION
  WHEN invalid_user_exception THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Validate_Forwarded_User',
          l_msg_text,
          NULL,
          NULL,
          NULL);
     RAISE;

  WHEN OTHERS THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Validate_Forwarded_User',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
     RAISE;

END Validate_Forwarded_User ;

PROCEDURE Set_Approval_Pending  (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

l_assignment_id pa_project_assignments.assignment_id%TYPE;
BEGIN
        l_assignment_id := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'ASSIGNMENT_ID');
    Maintain_wf_pending_flag
            (p_assignment_id => l_assignment_id,
             p_mode      => 'PENDING_APPROVAL'
            ) ;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Set_Approval_Pending',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
     RAISE;
END Set_Approval_Pending;

PROCEDURE Maintain_wf_pending_flag (p_assignment_id  IN NUMBER,
                    p_mode  IN VARCHAR2 ) IS
l_pending_approval_flag  VARCHAR2(1);
BEGIN
    -- if mode = 'PENDING_APPROVAL' set pending_approval_flag = 'Y'
    -- elseif mode = 'APPROVAL_PROCESS_COMPLETED' set
    --- pending_approval_flag = 'N'
    -- This is de-coupled from update status (though updating
    -- the same entity, since status may be maintained in multiple
    -- places and the pending flag has to be maintained both at the
    --start and completeion of the approval WF.
      IF p_mode = 'PENDING_APPROVAL' THEN
         l_pending_approval_flag := 'Y';
      ELSIF
         p_mode = 'APPROVAL_PROCESS_COMPLETED' THEN
         l_pending_approval_flag := 'N';
      ELSE
         -- placeholder for any possible future values
         l_pending_approval_flag := 'N';
          END IF;
      UPDATE pa_project_assignments
      SET    pending_approval_flag = l_pending_approval_flag,
         record_version_number = record_version_number + 1
      WHERE  assignment_id = p_assignment_id;
EXCEPTION
   WHEN OTHERS THEN
    RAISE;
END Maintain_wf_pending_flag ;


PROCEDURE Set_Asgmt_wf_result_Status
     (p_assignment_id IN pa_project_assignments.assignment_id%TYPE,
      p_status_code IN pa_project_statuses.project_status_code%TYPE,
      p_result_type  IN VARCHAR2,
      p_item_type IN VARCHAR2,
      p_item_key  IN VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
l_apprvl_status_code pa_project_statuses.project_status_code%TYPE;
l_change_id pa_assignments_history.change_id%TYPE;
l_return_status VARCHAR2(30);
l_msg_count   NUMBER := 0;
l_msg_data    VARCHAR2(500);
l_record_version_number NUMBER := 0;
l_out_record_version_number NUMBER := 0;
l_conflict_group_id         NUMBER;
l_submitter_uname          wf_users.name%type; --- VARCHAR2(100); Changed for bug 3267790
/* Modified length from 30 to 100 for bug 3148857 */
NO_ASSIGNMENT_ID            EXCEPTION;

CURSOR l_get_record_version_csr IS
SELECT record_version_number FROM
pa_project_assignments
WHERE assignment_id = p_assignment_id;

BEGIN
  OPEN l_get_record_version_csr;
  FETCH l_get_record_version_csr
  INTO l_record_version_number;

  IF l_get_record_version_csr%NOTFOUND THEN
     CLOSE l_get_record_version_csr;
     RAISE NO_ASSIGNMENT_ID;
  END IF;
  CLOSE l_get_record_version_csr;

  -- call the pa_asgmt_approval_pvt to update the
  -- assignment approval status and the schedules
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  SAVEPOINT asgmt_apprvl;

  pa_assignment_approval_pvt.update_approval_status
           (p_assignment_id         => p_assignment_id,
        p_action_code           => p_result_type,
        p_record_version_number => l_record_version_number,
        x_apprvl_status_code    => l_apprvl_status_code,
        x_change_id             => l_change_id,
            x_record_version_number => l_out_record_version_number,
        x_return_status         => l_return_status ,
        x_msg_count         => l_msg_count,
        x_msg_data          => l_msg_data );

  -- if return status <> SUCCESS, populate the error messages rollback to asgmt_apprvl
  -- and return error
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     set_nf_error_msg_attr (p_item_type => p_item_type,
                            p_item_key  => p_item_key,
                    p_msg_count => l_msg_count,
                        p_msg_data  => l_msg_data);
     ROLLBACK TO asgmt_apprvl;
     x_return_status := l_return_status;
  ELSE
     -------------------------------------------------------------------
     --  Resolve Overcommitment conflict for Approve
     -------------------------------------------------------------------
     l_conflict_group_id  := wf_engine.GetItemAttrNumber
                             (itemtype => p_item_type,
                              itemkey  => p_item_key,
                              aname    => 'CONFLICT_GROUP_ID');

     l_submitter_uname := wf_engine.GetItemAttrText
                   ( itemtype => p_item_type
                               , itemkey  => p_item_key
                               , aname    => 'WORKFLOW_STARTED_BY_UNAME');

     IF (l_conflict_group_id IS NOT NULL AND p_result_type=PA_ASSIGNMENT_APPROVAL_PUB.g_approve_action) THEN
        -- resolve remaining conflicts by taking action chosen by user
        PA_SCHEDULE_PVT.RESOLVE_CONFLICTS (p_conflict_group_id   => l_conflict_group_id
                                          ,p_assignment_id       => p_assignment_id
                                      ,x_return_status       => l_return_status
                                          ,x_msg_count           => l_msg_count
                                          ,x_msg_data            => l_msg_data);
        /*IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;*/

        -- complete post overcommitment processing
        PA_SCHEDULE_PVT.OVERCOM_POST_APRVL_PROCESSING
                                              (p_conflict_group_id   => l_conflict_group_id
                                              ,p_fnd_user_name       => l_submitter_uname
                                      ,x_return_status       => l_return_status
                                              ,x_msg_count           => l_msg_count
                                              ,x_msg_data            => l_msg_data);
        /*IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;*/
     END IF; -- IF (l_conflict_group_id IS NOT NULL...
  END IF;

  Maintain_wf_pending_flag
        (p_assignment_id => p_assignment_id,
                 p_mode  => 'APPROVAL_PROCESS_COMPLETED');

  -- Set the attribute NEW_ASGMT_STATUS_CODE
  wf_engine.SetItemAttrText
                   ( itemtype => p_item_type
                               , itemkey =>  p_item_key
                               , aname => 'NEW_ASGMT_STATUS_CODE'
                               , avalue => l_apprvl_status_code);
EXCEPTION
  WHEN NO_ASSIGNMENT_ID THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Set_Asgmt_wf_result_status',
          p_item_type,
          p_item_key,
          'INVALID_ASSIGNMENT_ID',
          NULL );
     RAISE;
 WHEN OTHERS THEN RAISE;
END Set_Asgmt_wf_result_status;



PROCEDURE Capture_approver_comment  (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
l_comment               VARCHAR2(4000); --VARCHAR2(2000); Bug 7459451 : Changed the length to accomodate max length returned by wf_engine.getItemAttrText
l_approver_user_name    wf_users.name%type; ----- VARCHAR2(240);Changed for bug 3267790
/* Modified length from 30 to 100 for bug 3148857 */
l_assignment_id     NUMBER;
l_wf_context_user       pa_wf_ntf_performers.user_name%TYPE;
l_reassignee_user_name  pa_wf_ntf_performers.user_name%TYPE;
l_object_id1            pa_wf_ntf_performers.object_id1%TYPE;
l_object_id2            pa_wf_ntf_performers.object_id2%TYPE;
l_prev_approver_user_name pa_wf_ntf_performers.user_name%TYPE;

CURSOR get_reassignee IS
SELECT USER_NAME
FROM   pa_wf_ntf_performers
WHERE  user_name = l_wf_context_user
AND    wf_type_code = 'ASSIGNMENT_APPROVAL'
AND    item_type = itemtype
AND    item_key  = itemkey;

CURSOR get_objectids IS
SELECT object_id1, object_id2
FROM   pa_wf_ntf_performers
WHERE  wf_type_code = 'ASSIGNMENT_APPROVAL'
AND    item_type = itemtype
AND    item_key  = itemkey
AND    current_approver_flag = 'Y';

BEGIN
       l_comment := wf_engine.GetItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'APPROVER_RESPONSE'
                               );
       IF l_comment IS NOT NULL THEN
           l_approver_user_name := wf_engine.GetItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'APPROVER_UNAME'
                               );
           l_assignment_id := wf_engine.GetItemAttrNumber
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ASSIGNMENT_ID'
                               );
       UPDATE pa_wf_ntf_performers
       SET  approver_comments = substr(l_comment,1,255)
       WHERE item_type  = itemtype
       AND   item_key   = itemkey
       AND   object_id1 = l_assignment_id
       AND   user_name  = l_approver_user_Name;
       -- Now reset the approver response attribute
       -- so that the next approver can add his/her comments
            wf_engine.SetItemAttrText
                         ( itemtype => itemtype
                         , itemkey =>  itemkey
                         , aname => 'APPROVER_RESPONSE'
                         , avalue => NULL
                         );
       END IF;

       --IF the user reassigns the notification to another person, two things need to be done
       --1) If the reassignee is not already in the notification table, insert into notification and
       --   set current_approver_flag to 'Y'.  If reassignee is already in the table, then just set flag to 'Y'
       --2) Set the Forwarded_From attribute for display
       IF funcmode IN ('TRANSFER', 'FORWARD') THEN

          l_wf_context_user := WF_ENGINE.context_text;

          --Check to see if the reassignee already in the table
           OPEN get_reassignee;
          FETCH get_reassignee INTO l_reassignee_user_name;
          CLOSE get_reassignee;

          --IF not in the table, then insert and set current_approver_flag to 'Y'
          IF l_reassignee_user_name IS NULL THEN


            --Get object_ids for inserting into the new record
            OPEN get_objectids;
            FETCH get_objectids INTO l_object_id1, l_object_id2;
            CLOSE get_objectids;

            INSERT INTO pa_wf_ntf_performers (WF_TYPE_CODE, ITEM_TYPE, ITEM_KEY,
                                              OBJECT_ID1, OBJECT_ID2, USER_NAME,
                                              USER_TYPE, CURRENT_APPROVER_FLAG)
              VALUES ('ASSIGNMENT_APPROVAL', itemtype, itemkey,
                       l_object_id1, l_object_id2, l_wf_context_user,
                       'REASSIGNEE', 'Y');

          END IF;


          --Set current_approver_flag to 'N' for the previous current_approver
          UPDATE pa_wf_ntf_performers
            SET current_approver_flag = (DECODE(user_name,l_wf_context_user,'Y','N'))
            WHERE wf_type_code = 'ASSIGNMENT_APPROVAL'
            AND   item_type = itemtype
            AND   item_key  = itemkey
            AND   current_approver_flag = 'Y';


          --
          --Correctly set the forwarded_from attribute
          --

          --set the previous_approver attribute correctly
          l_prev_approver_user_name :=
                    wf_engine.GetItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'APPROVER_UNAME');
          wf_engine.SetItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'PREV_APPROVER_UNAME'
                               , avalue => l_prev_approver_user_name
                               );

          --set current_approver to be the reassignee
          wf_engine.SetItemAttrText
                   ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'APPROVER_UNAME'
                               , avalue => l_wf_context_user
                               );


          --call set_forwarded_from procedure
          Set_Forwarded_From  (itemtype    => itemtype
                               , itemkey   => itemkey
                               , actid     => actid
                               , funcmode  => funcmode
                               , resultout => resultout);

          --set notification attribute forwarded_from to let the change show up
          WF_NOTIFICATION.SetAttrText (nid    => WF_ENGINE.context_nid
                                      ,aname  => 'FORWARDED_FROM'
                                      ,avalue => l_prev_approver_user_name);

/*

            INSERT INTO pa_wf_ntf_performers (WF_TYPE_CODE, ITEM_TYPE, ITEM_KEY,
                                              OBJECT_ID1, OBJECT_ID2, USER_NAME,
                                              USER_TYPE, CURRENT_APPROVER_FLAG)
              VALUES ('ASSIGNMENT_APPROVAL', itemtype, itemkey,
                       1, 2, l_wf_context_user,
                       'REASSIGNEE', 'Y');
*/
       END IF;  --end of checking in 'TRANSFER'/'FORWARD' mode
exception
WHEN OTHERS THEN
   wf_core.context
    ('PA_ASGMT_WFSTD',
    'Capture_approver_comment',
     itemtype,
     itemkey);
        RAISE;
END Capture_approver_comment;

PROCEDURE Capture_approver_response (p_item_type IN VARCHAR2,
                     p_item_key  IN VARCHAR2)
IS
BEGIN
    g_approver_response :=
                            wf_engine.GetItemAttrText
                   ( itemtype => p_item_type
                               , itemkey =>  p_item_key
                               , aname => 'APPROVER_RESPONSE'
                               );
EXCEPTION
 WHEN OTHERS THEN RAISE;
END Capture_approver_response;

PROCEDURE Populate_approval_NF_comments  (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
l_assignment_id pa_project_assignments.assignment_id%TYPE;

BEGIN
   -- Call the set_approver_comments procedure.
   -- Since populate_approval_NF_comments is being called from the
   -- approval process, pass the same item type and item key values
   -- for both p_apprvl and p_item parameters

        l_assignment_id := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'ASSIGNMENT_ID');

        Set_approver_comments   (p_apprvl_item_type => itemtype
                ,p_apprvl_item_key  => itemkey
                ,p_item_type        => itemtype
                ,p_item_key         => itemkey
                ,p_assignment_id    => l_assignment_id);

   -- Now call the set comment attributes procedure
   -- This will copy the comments from the internal comments
   -- attribute to the displayed comments attributes
   -- Since the comments are to be displayed only to
   -- an approver, there is no need to send a value for
   -- p_rect_type parameter. A value for this parameter
   -- is needed only if the recipient is the RESOURCE
   -- since all comments have to be suppressed in a notification
   -- a Resource recieves. A Resource would never recieve an
   -- 'Approval required ' notification

       Set_Comment_Attributes (p_item_type => itemtype,
                   p_item_key  => itemkey ,
                   p_rect_type => NULL );
EXCEPTION
WHEN OTHERS THEN
   wf_core.context
    ('PA_ASGMT_WFSTD',
    'Populate_approval_NF_comments' ,
     itemtype,
     itemkey);
RAISE;

END Populate_approval_NF_comments;

PROCEDURE generate_sch_err_msg
                (document_id     IN      VARCHAR2,
                 display_type    IN      VARCHAR2,
                 document        IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                 document_type   IN OUT  NOCOPY VARCHAR2)  IS --File.Sql.39 bug 4440895
l_msg_count    NUMBER ;
l_msg_index_out    NUMBER ;
l_msg_data     VARCHAR2(2000);
l_data             VARCHAR2(2000);
l_newline      VARCHAR2(10);
l_item_type    VARCHAR2(200);
l_item_key     VARCHAR2(200);
l_msg_text VARCHAR2(300);
CURSOR l_nf_csr IS
SELECT item_type, item_key
FROM   wf_item_activity_statuses
WHERE  notification_id = document_id;

BEGIN
     l_newline := FND_GLOBAL.newline;
     l_msg_count := FND_MSG_PUB.Count_Msg;
     OPEN l_nf_csr;
     FETCH l_nf_csr INTO l_item_type, l_item_key;
     IF l_nf_csr%NOTFOUND THEN
    document := 'Item Key not found';
        CLOSE l_nf_csr;
        RETURN;
     ELSE
        CLOSE l_nf_csr;
     END IF;
     -- document := '<html>';
       document_type := 'text/html';
     l_msg_data := wf_engine.GetItemAttrText
                   ( itemtype => l_item_type
                               , itemkey =>  l_item_key
                               , aname => 'L_MSG_DATA'
                               );
     IF l_msg_count = 0 THEN
    document := 'No errors in the stack';
    RETURN;
     END IF;

     IF l_msg_count > 1 THEN
        FOR i in 1..l_msg_count LOOP
        pa_interface_utils_pub.get_messages
        (p_encoded        => FND_API.G_FALSE,
         p_msg_index      => i,
                 p_msg_count      => l_msg_count ,
                 p_msg_data       => l_msg_data ,
                 p_data           => l_data,
                 p_msg_index_out  => l_msg_index_out );
          document := document ||  ' <p>' || l_data ||' </p>';
       END LOOP;
     ELSIF l_msg_count = 1 THEN
            FND_MESSAGE.SET_ENCODED (l_msg_data);
            l_data := FND_MESSAGE.GET;
            document := document ||  ' <p>' || l_data ||' </p>';
     END IF;

exception
WHEN OTHERS THEN
   wf_core.context('PA_ASGMT_WFSTD','Generate_sch_err_msg',Document_id,NULL);
        RAISE;
END generate_sch_err_msg;

PROCEDURE set_nf_error_msg_attr (p_item_type IN VARCHAR2,
                     p_item_key  IN VARCHAR2,
                 p_msg_count IN NUMBER,
                 p_msg_data IN VARCHAR2 ) IS

l_msg_index_out    NUMBER ;
l_msg_data     VARCHAR2(2000);
l_data             VARCHAR2(2000);
l_item_attr_name   VARCHAR2(30);
BEGIN
          IF p_msg_count = 0 THEN
           RETURN;
          END IF;

      IF p_msg_count = 1 THEN
         IF p_msg_data IS NOT NULL THEN
                FND_MESSAGE.SET_ENCODED (p_msg_data);
                l_data := FND_MESSAGE.GET;
                wf_engine.SetItemAttrText
                   ( itemtype => p_item_type
                               , itemkey =>  p_item_key
                               , aname => 'ERROR_MSG1'
                               , avalue => l_data
                               );
         END IF;
             RETURN ;
          END IF;

          IF p_msg_count > 1 THEN
              FOR i in 1..p_msg_count
        LOOP
          IF i > 5 THEN
         EXIT;
          END IF;
          pa_interface_utils_pub.get_messages
        (p_encoded        => FND_API.G_FALSE,
         p_msg_index      => i,
                 p_msg_count      => p_msg_count ,
                 p_msg_data       => p_msg_data ,
                 p_data           => l_data,
                 p_msg_index_out  => l_msg_index_out );
                 l_item_attr_name := 'ERROR_MSG'||i;
                   wf_engine.SetItemAttrText
                   ( itemtype => p_item_type
                               , itemkey =>  p_item_key
                               , aname => l_item_attr_name
                               , avalue => l_data
                               );
            END LOOP;
      END IF;
EXCEPTION
    WHEN OTHERS THEN RAISE;
END set_nf_error_msg_attr;

PROCEDURE get_primary_contact_info
               (p_resource_id  IN NUMBER
              , p_assignment_id IN NUMBER
              , p_approver1_person_id IN NUMBER
              , p_approver1_type IN      VARCHAR2
              , p_approver2_person_id IN NUMBER
              , p_approver2_type IN      VARCHAR2
              , x_PrimaryContactId     OUT NOCOPY NUMBER ) --File.Sql.39 bug 4440895
IS
l_primarycontactname per_all_people_f.full_name%type; ----- VARCHAR2(240);Changed for bug 3267790
l_managerid      NUMBER := 0;
l_managername        per_all_people_f.full_name%type;----- VARCHAR2(240);Changed for bug 3267790
l_return_status      VARCHAR2(1);
l_msg_count      NUMBER ;
l_msg_data       VARCHAR2(2000);
BEGIN
    -- If the primary contact was either the 1st or 2nd approver
    -- then return the appropriate person id
    IF p_approver1_type = 'ORG_PRIMARY_CONTACT' THEN
           x_PrimaryContactId := p_approver1_person_id;
       RETURN;
        ELSIF p_approver2_type = 'ORG_PRIMARY_CONTACT' THEN
       x_PrimaryContactId := p_approver2_person_id;
       RETURN;
    END IF;
        -- If the primary contact is neither of the two approvers,
    -- then get that info from the DB
         pa_resource_utils.get_org_primary_contact
                          (P_ResourceId          => p_resource_id
                           ,p_assignment_id      => p_assignment_id
                           ,x_PrimaryContactId   => x_primarycontactid
                           ,x_PrimaryContactName => l_primarycontactname
                           ,x_ManagerId          => l_managerid
                           ,x_ManagerName        => l_managername
                           ,x_return_Status      => l_return_status
                           ,x_msg_count          => l_msg_count
                           ,x_msg_data           => l_msg_data
                           ) ;
EXCEPTION
 WHEN OTHERS THEN RAISE;

END get_primary_contact_info;

PROCEDURE populate_wf_performers
    ( p_wf_type_code IN VARCHAR2
     ,p_item_type    IN VARCHAR2
     ,p_item_key     IN VARCHAR2
     ,p_object_id1  IN VARCHAR2
     ,p_object_id2  IN VARCHAR2
     ,p_in_performers_tbl PA_CLIENT_EXTN_ASGMT_WF.Users_List_Tbltyp
     ,p_current_approver_flag  IN VARCHAR2
     ,x_number_of_performers OUT NOCOPY NUMBER ) --File.Sql.39 bug 4440895
IS
l_number_of_performers NUMBER := 0;
BEGIN
    -- Need to insert the user names into
    -- the members table. To validate the users first
    -- to ensure that notifications can be appropriately sent
    -- Insert only active users
    x_number_of_performers := 0;
      IF p_in_performers_tbl.EXISTS(1) THEN
     FOR i IN 1..p_in_performers_tbl.COUNT LOOP
         IF wf_directory.UserActive
        (p_in_performers_tbl(i).User_Name) THEN
             INSERT INTO pa_wf_ntf_performers (
                  Wf_Type_Code,Item_Type,
                  Item_Key,object_id1,
                  object_id2,User_Name,User_Type,
                  Routing_Order,Current_Approver_flag
          )
              VALUES
          ( p_wf_type_code,
            p_item_type,
            p_item_key,
            p_object_id1,
            p_object_id2,
            p_in_performers_tbl(i).User_Name,
            p_in_performers_tbl(i).Type,
            p_in_performers_tbl(i).Routing_Order,
                p_current_approver_flag );
             l_number_of_performers := l_number_of_performers + 1;
      END IF;
    END LOOP;
      END IF;
     x_number_of_performers := l_number_of_performers;
EXCEPTION
 WHEN OTHERS THEN RAISE;
END populate_wf_performers;

PROCEDURE get_wf_performer (p_wf_type_code IN VARCHAR2,
                p_item_type    IN VARCHAR2,
                p_item_key     IN VARCHAR2,
                p_routing_order IN NUMBER,
                    p_object_id1  IN VARCHAR2 ,
                x_performer_name OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                x_performer_type OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
CURSOR l_get_next_performer_csr
IS
SELECT User_Name , User_Type FROM pa_wf_ntf_performers
WHERE  wf_type_code = p_wf_type_code
AND    item_type    = p_item_type
AND    item_key     = p_item_key
AND   routing_order = p_routing_order
AND   object_id1   = p_object_id1;

l_user_name        pa_wf_ntf_performers.user_name%TYPE;

BEGIN

    OPEN l_get_next_performer_csr ;
    FETCH l_get_next_performer_csr INTO
          x_performer_name, x_performer_type ;
    IF l_get_next_performer_csr%NOTFOUND THEN
       x_performer_name := NULL;
       x_performer_type := NULL;
    END IF;

    CLOSE l_get_next_performer_csr;


        --Bug 1770103: do not send FYI notification to the user logged in.

        IF p_wf_type_code like '%FYI' THEN

          --Get the Name of the User logged In.
      l_user_name := wf_engine.GetItemAttrText
                         ( itemtype => p_item_type
                         , itemkey =>  p_item_key
                         , aname => 'WORKFLOW_STARTED_BY_UNAME');
    /*  IF x_performer_name = l_user_name THEN
             x_performer_name := NULL;
             x_performer_type := NULL;
          END IF;*/
        END IF;
        --end of bug 1770103

EXCEPTION
 WHEN OTHERS THEN RAISE;
END get_wf_performer ;

PROCEDURE Set_approver_comments (p_apprvl_item_type VARCHAR2,
                 p_apprvl_item_key  VARCHAR2,
                 p_item_type  VARCHAR2,
                 p_item_key  VARCHAR2,
                 p_assignment_id NUMBER )
IS
CURSOR l_get_approver_comments_csr IS
SELECT user_Name,approver_comments
FROM pa_wf_ntf_performers
WHERE item_type = p_apprvl_item_type
AND   item_key  = p_apprvl_item_key
AND   object_id1 = p_assignment_id
AND   approver_comments IS NOT NULL;
l_get_approver_comments_rec l_get_approver_comments_csr%ROWTYPE;
l_counter NUMBER := 0;
l_item_attr_name   VARCHAR2(30);
BEGIN
    -- Using the approval item type , get the
    -- comments of the approvers.
        -- p_apprvl_item_type and p_item_type
    -- would be different if the FYI notification wf is triggered
    -- by the approval workflow.
        -- When this procedure is invoked by the approval workflow
    -- p_apprvl_item_type and p_item_type would be the same

    IF (p_apprvl_item_type IS NOT NULL AND p_apprvl_item_key
        IS NOT NULL ) THEN
    OPEN l_get_approver_comments_csr;
    LOOP
        FETCH l_get_approver_comments_csr INTO
        l_get_approver_comments_rec;
        IF l_get_approver_comments_csr%NOTFOUND THEN
           EXIT;
        END IF;
        l_counter := l_counter + 1;
        IF l_counter > 5 THEN
           EXIT;
        END IF;
      -- Now set the appropriate comments attributes for this WF
      -- Populate the internal comments only . displayed comments
      -- will be done by the get_recipients nodes
        l_item_attr_name := 'INTERNAL_APPROVER_COMMENTS_'||l_counter ;
            wf_engine.SetItemAttrText
                   ( itemtype => p_item_type
                               , itemkey =>  p_item_key
                               , aname => l_item_attr_name
                               , avalue =>
                 l_get_approver_comments_rec.user_name ||
                 ' : ' ||
                l_get_approver_comments_rec.approver_comments
                               );
    END LOOP;
    CLOSE l_get_approver_comments_csr;
      END IF;

EXCEPTION
   WHEN OTHERS THEN RAISE;
END Set_Approver_Comments;

PROCEDURE Set_Comment_Attributes (p_item_type IN VARCHAR2,
                          p_item_key  IN VARCHAR2,
                  p_rect_type IN VARCHAR2 ) IS
l_comments_item_attr_name  VARCHAR2(30);
l_comments VARCHAR2(4000); -- VARCHAR2(255); Bug 7459451 : Changed the length to accomodate max length returned by wf_engine.getItemAttrText
BEGIN
    -- Set displayed comments to NULL if the recipient is resource
    -- otherwise set the displayed comments to the internal comments
        FOR i IN 1..5 LOOP
        l_comments_item_attr_name := 'INTERNAL_APPROVER_COMMENTS_'||i;
        l_comments := wf_engine.getItemAttrText
                   ( itemtype => p_item_type
                               , itemkey =>  p_item_key
                               , aname => l_comments_item_attr_name
                               );
             IF p_rect_type = 'RESOURCE' THEN
                l_comments := NULL;
             END IF;
                 wf_engine.SetItemAttrText
                   ( itemtype => p_item_type
                               , itemkey =>  p_item_key
                               , aname => 'APPROVER_COMMENTS_'||i
                               , avalue => l_comments
                               );
        END LOOP;

EXCEPTION
   WHEN OTHERS THEN RAISE;
END Set_Comment_Attributes;

PROCEDURE Check_And_Get_Proj_Customer ( p_project_id IN NUMBER
                       ,x_customer_id OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                       ,x_customer_name OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

l_customer_id    pa_project_customers.customer_id%TYPE;
l_num_ids        NUMBER;

CURSOR l_check_one_cust_only_csr IS
SELECT customer_id FROM pa_project_customers
WHERE project_id = p_project_id;

/*
CURSOR l_get_cust_csr IS
SELECT ppc.customer_id,rac.customer_name
FROM pa_project_customers ppc,
     ra_customers rac
WHERE ppc.project_id = p_project_id
AND   rac.customer_id = ppc.customer_id ;
*/

-- 4363092 TCA changes, replaced RA views with HZ tables
/*
CURSOR l_get_cust_csr IS
SELECT customer_name
FROM ra_customers
WHERE customer_id = l_customer_id;
*/
CURSOR l_get_cust_csr IS
SELECT substrb(party.party_name,1,50) customer_name
FROM hz_parties party, hz_cust_accounts cust_acct
WHERE cust_acct.cust_account_id = l_customer_id
      and cust_acct.party_id = party.party_id ;
-- 4363092 end

BEGIN
   OPEN l_check_one_cust_only_csr;

   LOOP
     FETCH l_check_one_cust_only_csr INTO l_customer_id;
     EXIT WHEN (l_check_one_cust_only_csr%ROWCOUNT > 1 OR l_check_one_cust_only_csr%NOTFOUND);
   END LOOP;
   l_num_ids := l_check_one_cust_only_csr%ROWCOUNT;

   CLOSE l_check_one_cust_only_csr;

   IF (l_num_ids = 1) THEN
     x_customer_id := l_customer_id;

     OPEN l_get_cust_csr;
     FETCH l_get_cust_csr INTO
        x_customer_name;
     CLOSE l_get_cust_csr;
   END IF;

EXCEPTION
   WHEN OTHERS THEN RAISE;

END Check_And_Get_proj_customer;

PROCEDURE   Set_NF_Subject_and_Desc  (p_item_type       IN VARCHAR2,
                      p_item_key        IN VARCHAR2,
                      p_assignment_type IN VARCHAR2,
                      p_reapproval_flag IN VARCHAR2,
                      p_msg_type        IN VARCHAR2) IS
l_msg_subj_code              VARCHAR2(30);
l_msg_desc_code              VARCHAR2(30);
l_msg_subj_text              VARCHAR2(2000);
l_msg_desc_text              VARCHAR2(2000);
l_msg_subj_itemattr_name     VARCHAR2(30);
l_msg_desc_itemattr_name     VARCHAR2(30);
l_assignment_id              NUMBER ;
l_conflict_group_id          NUMBER ;
l_resolve_conflicts_by_rmvl  VARCHAR2(1);
l_view_conflict_url          VARCHAR2(2000);
l_return_status              VARCHAR2(1);
l_msg_count              NUMBER ;
l_msg_data               VARCHAR2(2000);

BEGIN

    /*
    Pass the following . assignment_type,reapproval_flag
                    ,msg_type - ASSIGNMENT_APPROVAL
                ,       APPROVAL_FYI , REJECTION_FYI
        If assignment approval ,
       If admin assignment
        Set msg subj and header as Admin approval
       Else
         If reapproval set msg subj and header as reapproval
       End if
    Elsif
       approval FYI set msg subj and header FYI depends on ovecommitment result.
    Elsif
       rejection FYI set msg subj and header FYI as rejected
        Elsif
           cancellation FYI set msg subj and header FYI as canceled
    End if
    */
    IF p_msg_type = 'ASSIGNMENT_APPROVAL' THEN
           l_msg_subj_itemattr_name := 'MSG_SUBJECT';
           l_msg_desc_itemattr_name := 'MSG_DESCRIPTION';

       IF p_assignment_type = 'STAFFED_ADMIN_ASSIGNMENT' THEN
          l_msg_subj_code := 'PA_NFSUBJ_ADM_ASG_APRVL_REQD';
          l_msg_desc_code := 'PA_NFDESC_ADM_ASG_APRVL_REQD';
       ELSIF p_assignment_type = 'STAFFED_ASSIGNMENT' THEN
        IF p_reapproval_flag = 'Y' THEN
               l_msg_subj_code := 'PA_NFSUBJ_ASG_REAPRVL_REQD';
               l_msg_desc_code := 'PA_NFDESC_ASG_REAPRVL_REQD';
            ELSE
               l_msg_subj_code := 'PA_NFSUBJ_ASG_APRVL_REQD';
               l_msg_desc_code := 'PA_NFDESC_ASG_APRVL_REQD';
            END IF;
           END IF;

         ELSIF p_msg_type = 'APPROVAL_FYI' THEN
               l_assignment_id := wf_engine.GetItemAttrNumber
                           (itemtype => p_item_type,
                            itemkey  => p_item_key,
                            aname    => 'ASSIGNMENT_ID');
               l_conflict_group_id := wf_engine.GetItemAttrNumber
                               (itemtype => p_item_type,
                                itemkey  => p_item_key,
                                aname    => 'CONFLICT_GROUP_ID');

               -- If there is no overcommitment conflict
               IF (l_conflict_group_id IS NULL) THEN
              l_msg_subj_code := 'PA_NFSUBJ_ASGMT_APPROVED';
              l_msg_desc_code := 'PA_NFDESC_ASGMT_APPROVED';

                  -- set 'Number of Assignments Resulting in Resource Overcommitment -1/0' for single
                  -- approval FYI notification.
                  wf_engine.SetItemAttrNumber
                   ( itemtype => p_item_type
                               , itemkey  => p_item_key
                               , aname    => 'NUMBER_OF_OVERCOM_ASGMT'
                               , avalue   => 0 );
               -- If there is any overcommitment conflict
               ELSE
                  PA_SCHEDULE_PVT.has_resolved_conflicts_by_rmvl
                                  ( p_conflict_group_id         => l_conflict_group_id
                                  , p_assignment_id             => l_assignment_id
                                  , x_resolve_conflicts_by_rmvl => l_resolve_conflicts_by_rmvl
                                  , x_return_status             => l_return_status
                                  , x_msg_count                 => l_msg_count
                                  , x_msg_data                  => l_msg_data);
                  IF (l_resolve_conflicts_by_rmvl = 'Y') THEN
                 l_msg_subj_code := 'PA_NFSUBJ_ASGMT_APPR_CONF_REM';
                 l_msg_desc_code := 'PA_NFDESC_ASGMT_APPR_CONF_REM';
                  ELSE
                 l_msg_subj_code := 'PA_NFSUBJ_ASGMT_APPR_KP_CONF';
                 l_msg_desc_code := 'PA_NFDESC_ASGMT_APPR_KP_CONF';
                  END IF;

                  -- set 'Number of Assignments Resulting in Resource Overcommitment -1/0' for single
                  -- approval FYI notification.
                  wf_engine.SetItemAttrNumber
                   ( itemtype => p_item_type
                               , itemkey  => p_item_key
                               , aname    => 'NUMBER_OF_OVERCOM_ASGMT'
                               , avalue   => 1 );
               END IF; -- If (l_conflict_group_id IS NULL)

               -- set resource overcommitment url
               l_view_conflict_url := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode='
                                   || 'PA_RES_OVERCOMMITMENT_LAYOUT&paAssignmentId=' || l_assignment_id
                                   || '&paConflictGroupId=' || l_conflict_group_id
                                   || '&paCallingPage=Default&addBreadCrumb=RP';

               wf_engine.SetItemAttrText
                      ( itemtype => p_item_type
                                  , itemkey  => p_item_key
                                  , aname    => 'VIEW_CONFLICT_URL_INFO'
                                  , avalue   => l_view_conflict_url );
     ELSIF p_msg_type = 'REJECTION_FYI' OR p_msg_type = 'CANCELLATION_FYI' THEN
               -- set 'Number of Assignments Resulting in Resource Overcommitment -0' for single
               -- reject/cancel FYI notification.
               wf_engine.SetItemAttrNumber
                   ( itemtype => p_item_type
                               , itemkey  => p_item_key
                               , aname    => 'NUMBER_OF_OVERCOM_ASGMT'
                               , avalue   => 0 );

               l_assignment_id := wf_engine.GetItemAttrNumber
                           (itemtype => p_item_type,
                            itemkey  => p_item_key,
                            aname    => 'ASSIGNMENT_ID');
               -- set resource overcommitment url
               l_view_conflict_url := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode='
                                   || 'PA_RES_OVERCOMMITMENT_LAYOUT&paAssignmentId=' || l_assignment_id
                                   || '&paConflictGroupId=&paCallingPage=Default&addBreadCrumb=RP';

               wf_engine.SetItemAttrText
                      ( itemtype => p_item_type
                                  , itemkey  => p_item_key
                                  , aname    => 'VIEW_CONFLICT_URL_INFO'
                                  , avalue   => l_view_conflict_url );

           IF p_msg_type = 'REJECTION_FYI' THEN
              l_msg_subj_code := 'PA_NFSUBJ_ASGMT_REJECTED';
              l_msg_desc_code := 'PA_NFDESC_ASGMT_REJECTED';
               ELSIF p_msg_type = 'CANCELLATION_FYI' THEN
              l_msg_subj_code := 'PA_NFSUBJ_ASGMT_CANCELED';
              l_msg_desc_code := 'PA_NFDESC_ASGMT_CANCELED';
               END IF;
     END IF;

     IF p_msg_type IN ('APPROVAL_FYI','REJECTION_FYI','CANCELLATION_FYI') THEN
           l_msg_subj_itemattr_name := 'MSG_SUBJECT_FYI';
           l_msg_desc_itemattr_name := 'MSG_DESCRIPTION_FYI';
     END IF;

         -- Now that the message codes have been set,
     -- get the message from fnd messages
     FND_MESSAGE.SET_NAME ('PA',l_msg_subj_code);
     l_msg_subj_text := FND_MESSAGE.GET;
     FND_MESSAGE.SET_NAME ('PA',l_msg_desc_code);
     l_msg_desc_text := FND_MESSAGE.GET;

         wf_engine.SetItemAttrText
                   ( itemtype => p_item_type
                               , itemkey =>  p_item_key
                               , aname =>    l_msg_subj_itemattr_name
                               , avalue =>   l_msg_subj_text
                               );
         wf_engine.SetItemAttrText
                   ( itemtype => p_item_type
                               , itemkey =>  p_item_key
                               , aname =>    l_msg_desc_itemattr_name
                               , avalue =>   l_msg_desc_text
                               );
EXCEPTION
  WHEN OTHERS THEN RAISE;

END Set_NF_Subject_and_Desc ;



PROCEDURE Delete_Assignment_WF_Records (p_assignment_id  IN   pa_project_assignments.assignment_id%TYPE,
                                        p_project_id     IN   pa_project_assignments.project_id%TYPE)
IS

/*CURSOR get_project_id IS
  SELECT project_id
  FROM pa_project_assignments
  WHERE assignment_id = p_assignment_id;

l_project_id   pa_project_assignments.project_id%TYPE;*/

BEGIN

  /*OPEN get_project_id;
  FETCH get_project_id INTO l_project_id;
  CLOSE get_project_id;*/

  DELETE FROM pa_wf_processes
  WHERE  entity_key1 = to_char(p_project_id)
  AND    entity_key2 = to_char(p_assignment_id)
  AND    wf_type_code = 'ASSIGNMENT_APPROVAL';


  DELETE FROM pa_wf_ntf_performers
  WHERE wf_type_code in ('ASSIGNMENT_APPROVAL','REJECTION_FYI','APPROVAL_FYI','CANCELLATION_FYI')
  AND   object_id1 = p_assignment_id;

END Delete_Assignment_WF_Records;

---------------------------------------------------------------------------------------------------
--                               Workflow apis for mass assignment approval
---------------------------------------------------------------------------------------------------
--Begin Forward declaration
PROCEDURE process_approval_result
    ( p_project_id                  IN NUMBER
     ,p_mode                        IN    VARCHAR2
     ,p_assignment_id_tbl           IN    SYSTEM.pa_num_tbl_type
     ,p_approval_status_tbl         IN    SYSTEM.pa_varchar2_30_tbl_type
     ,p_group_id                    IN    NUMBER
     ,p_approver_group_id           IN    NUMBER
     ,p_routing_order               IN    NUMBER
     ,p_num_of_assignments          IN    NUMBER
     ,p_submitter_user_name         IN    VARCHAR2
     ,p_conflict_group_id           IN    NUMBER
     ,p_update_info_doc             IN    VARCHAR2
     ,p_forwarded_from              IN    VARCHAR2
     ,p_note_to_approvers           IN    VARCHAR2);



--END Forward declarations

--------------------------------------------
--This API starts the mass approval workflow
--It is called when a notification needs to
--be sent to approver for assignment approval
--This API is called in mass_assignment_approval
--and in process_approval_result_wf
--------------------------------------------
PROCEDURE start_mass_approval_flow
   ( p_project_id          IN   NUMBER              := FND_API.G_MISS_NUM
    ,p_mode                IN   VARCHAR2            := FND_API.G_MISS_CHAR
    ,p_note_to_approvers   IN   VARCHAR2            := FND_API.G_MISS_CHAR
    ,p_forwarded_from      IN   VARCHAR2
    ,p_performer_user_name IN   VARCHAR2            := FND_API.G_MISS_CHAR
    ,p_routing_order       IN   NUMBER              := FND_API.G_MISS_NUM
    ,p_group_id            IN   NUMBER              := FND_API.G_MISS_NUM
    ,p_approver_group_id   IN   NUMBER              := FND_API.G_MISS_NUM
    ,p_submitter_user_name IN   VARCHAR2            := FND_API.G_MISS_CHAR
    ,p_update_info_doc     IN   VARCHAR2            := FND_API.G_MISS_CHAR
    ,p_project_name        IN   VARCHAR2
    ,p_project_number      IN   VARCHAR2
    ,p_project_manager     IN   VARCHAR2
    ,p_project_org         IN   VARCHAR2
    ,p_project_cus         IN   VARCHAR2
    ,p_conflict_group_id   IN   NUMBER              := FND_API.G_MISS_NUM
    ,x_return_status       OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count           OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data            OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
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
    l_msg_index_out   NUMBER ;
    l_msg_data            VARCHAR2(2000);
    l_wf_item_type        VARCHAR2(2000):= 'PAWFAAP'; --Assignment Approval Item type
    l_wf_process          VARCHAR2(2000):= 'PA_ASGMT_APPRVL_MP'; --Assignment Approval process
    l_err_code        NUMBER := 0;
    l_err_stage           VARCHAR2(2000);
    l_err_stack           VARCHAR2(2000);

    l_ntfy_apprvl_recipient_name  pa_wf_ntf_performers.user_name%TYPE;  --- Commented for 3267790 fnd_user.user_name%TYPE; --used to set NTFY_APPRVL_RECIPIENT_NAME attribute
    l_prev_user                   fnd_user.user_name%TYPE; --used to set FORWARDED_FROM attribute
    l_number_of_assignments NUMBER;
    l_mass_approve_url    VARCHAR2(2000); --Mass Approve page URL
    l_debug_mode VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); -- 5345171

BEGIN

    -- Initialize the Error Stack
    PA_DEBUG.init_err_stack('PA_ASGMT_WFSTD.start_mass_approval_flow');

    --Log Message
    IF l_debug_mode = 'Y' THEN -- 5345171
        PA_DEBUG.write_log
        ( x_module      => 'pa.plsql.PA_ASGMT_WFSTD.start_mass_approval_flow.begin'
         ,x_msg         => 'Beginning of mass approval workflow api'
         ,x_log_level   => 1);
    END IF;

    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Clear the global PL/SQL message table
    FND_MSG_PUB.initialize;

    log_message('Inside Start mass approval flow: 0');
    log_message('Value of updated info doc:' || p_update_info_doc);

    -- Create the unique item key to launch WF with
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

    -----------------------------------
    --Getting the current approver name
    -----------------------------------
    BEGIN
        SELECT user_name
        INTO   l_ntfy_apprvl_recipient_name
        FROM   pa_wf_ntf_performers
        WHERE  group_id          = p_group_id
        AND    approver_group_id = p_approver_group_id
        AND    routing_order     = p_routing_order
        AND    rownum            = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            null;
    END;

    log_message('l_ntfy_apprvl_recipient_name:' || l_ntfy_apprvl_recipient_name);
    log_message('Inside Start mass approval flow: 1');

    ----------------------------------------------------------
    --Getting the Forwared From (Submitter/previous approver)
    ----------------------------------------------------------
    IF p_forwarded_from IS NULL THEN
       l_prev_user := p_submitter_user_name;
    ELSE
       l_prev_user := p_forwarded_from;
    END IF;

    log_message('Inside Start mass approval flow: 2');

    --------------------------------------------
    --Getting number of assignments for approval
    --------------------------------------------
    BEGIN
        SELECT count(object_id1)
        INTO   l_number_of_assignments
        FROM   pa_wf_ntf_performers pf,
               pa_project_assignments asmt
        WHERE  pf.group_id          = p_group_id
        AND    pf.approver_group_id = p_approver_group_id
        AND    pf.routing_order     = p_routing_order
        AND    pf.object_id1 = asmt.assignment_id
        AND    asmt.apprvl_status_code <> PA_ASSIGNMENT_APPROVAL_PUB.g_rejected;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_number_of_assignments := 0;
    END;

    log_message('Inside Start mass approval flow: 3');
    log_message('Conflict group_id:' || p_conflict_group_id);

    IF l_number_of_assignments > 0 THEN
    ----------------------------------
    --Constructing mass approve URL
    ---------------------------------
    l_mass_approve_url := 'JSP:/OA_HTML/OA.jsp?akRegionCode=PA_MASS_APPR_LAYOUT' ||
'&akRegionApplicationId=275' ||
'&paProjectId='||
p_project_id || '&paGroupId=' ||
p_group_id || '&paApproverGroupId=' ||
p_approver_group_id ||
'&paRoutingOrder=' || p_routing_order ||
'&paMode=' || p_mode || '&paNotificationId=' ||
'&#NID' || '&paItemKey=' || l_itemkey ||
'&paSubmitterUserName=' || p_submitter_user_name ||
'&paConflictGroupId=' || p_conflict_group_id || '&addBreadCrumb=RP';

    log_message('l_mass_approve_url:' || l_mass_approve_url);

    -- Create the WF process
    wf_engine.CreateProcess
        ( ItemType => l_wf_item_type
        , ItemKey  => l_itemkey
        , process  => l_wf_process );

    log_message('Inside Start mass approval flow : 4');

    ----------------------------------------------------------------
    --Set all the required workflow attributes and start the workflow
    -----------------------------------------------------------------
    --set group_id
    wf_engine.SetItemAttrNumber
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'GROUP_ID'
        , avalue   => p_group_id);

    wf_engine.SetItemAttrNumber
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'APPROVER_GROUP_ID'
        , avalue   => p_approver_group_id);

    wf_engine.SetItemAttrNumber
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'ROUTING_ORDER'
        , avalue   => p_routing_order);

    --This is required for check_notiifcation_completed API logic
    wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'MODE'
        , avalue   => p_mode);

    wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'SUBMITTER_UNAME'
        , avalue   => p_submitter_user_name);

    wf_engine.SetItemAttrDocument
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'UPDATED_INFO_DOC'
        , documentid   => p_update_info_doc  );

    --Set approval type
    wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'APPROVAL_TYPE'
        , avalue   => PA_ASGMT_WFSTD.G_MASS_APPROVAL  );

    --Setting Mass Assignments details
    wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'NTFY_APPRVL_RECIPIENT_NAME'
        , avalue   => l_ntfy_apprvl_recipient_name  );

    wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'FORWARDED_FROM'
        , avalue   => l_prev_user  );

    wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'NOTE_TO_APPROVER'
        , avalue   => p_note_to_approvers  );

    wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'NUMBER_OF_ASSIGNMENTS'
        , avalue   => l_number_of_assignments  );

    wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'MASS_APPROVE_URL_INFO'
        , avalue   => l_mass_approve_url );

    --Setting the Upadate info document
     wf_engine.SetItemAttrDocument
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'UPDATED_INFO_DOC'
        , documentid   => p_update_info_doc );

    --Setting Project Details
    IF p_project_manager IS NOT NULL THEN
        wf_engine.SetItemAttrText
            ( itemtype => l_wf_item_type
            , itemkey  => l_itemkey
            , aname    => 'PROJECT_MANAGER_NAME'
            , avalue   => p_project_manager );
    END IF;

    wf_engine.SetItemAttrNumber
        ( itemtype => l_wf_item_type
         , itemkey => l_itemkey
         , aname   => 'PROJECT_ID'
         , avalue  => p_project_id);

    wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'PROJECT_NUMBER'
        , avalue   => p_project_number);

    wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
         , itemkey => l_itemkey
         , aname   => 'PROJECT_NAME'
         , avalue  => p_project_name);

    wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'PROJECT_ORGANIZATION'
        , avalue   => p_project_org);

   wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'FROM_ROLE_VALUE'
        , avalue   => p_submitter_user_name); --Added for bug 4535838

    -- Set the customer name if it is not null
    IF p_project_cus IS NOT NULL THEN
        wf_engine.SetItemAttrText
            ( itemtype => l_wf_item_type
            , itemkey  => l_itemkey
            , aname    => 'PROJECT_CUSTOMER'
            , avalue   => p_project_cus);
    END IF;

    log_message('Starting process');
    -----------------------------
    --Start the workflow process
    -----------------------------
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

    END IF; --l_num_of_assignments > 0

    --Setting the original value
    wf_engine.threshold := l_save_threshold;

EXCEPTION
    WHEN OTHERS THEN

         --Setting the original value
         wf_engine.threshold := l_save_threshold;

         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_ASGMT_WFSTD.start_mass_Approval_flow'
              ,p_procedure_name => PA_DEBUG.G_Err_Stack );

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;
END start_mass_approval_flow;


/** This API starts the FYI notifications to indicate if
  * asignments have been approved or rejected. It sends the following notification.
  *     1. Resource FYI for every assignment approved/rejected
  */
PROCEDURE process_res_fyi_notification
    ( p_project_id           IN   NUMBER    := FND_API.G_MISS_NUM
     ,p_assignment_id        IN   NUMBER    := FND_API.G_MISS_NUM
     ,p_mode                 IN   VARCHAR2
     ,p_project_name         IN   VARCHAR2
     ,p_project_number       IN   VARCHAR2
     ,p_project_manager      IN   VARCHAR2
     ,p_project_org          IN   VARCHAR2
     ,p_project_cus          IN   VARCHAR2
     ,p_conflict_group_id    IN   NUMBER    := NULL
     ,x_return_status        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count            OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data             OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

    l_itemkey             VARCHAR2(30);
    l_responsibility_id   NUMBER;
    l_resp_appl_id        NUMBER;
    l_wf_started_date     DATE;
    l_wf_started_by_id    NUMBER;
    l_return_status       VARCHAR2(1);
    l_error_message_code  VARCHAR2(30);
    x_error_message_code  VARCHAR2(30);
    l_save_threshold      NUMBER;
    l_msg_count           NUMBER ;
    l_msg_index_out   NUMBER ;
    l_msg_data            VARCHAR2(2000);
    l_wf_item_type        VARCHAR2(2000):= 'PARMAAP'; --Assignment Approval Item type
    l_wf_process          VARCHAR2(2000):= 'PA_MASS_APRVL_RES_FP';
    l_err_code        NUMBER := 0;
    l_err_stage       VARCHAR2(2000);
    l_err_stack           VARCHAR2(2000);
    l_display_name        wf_users.display_name%TYPE;  ---VARCHAR2(200); Changed for bug 3267790
    l_approver_name       VARCHAR2(200);
    l_resource_id         NUMBER;
    --l_res_user_name       VARCHAR2(200);
    l_msg_subj_code       VARCHAR2(30);
    l_msg_desc_code       VARCHAR2(30);
    l_msg_subj_text       VARCHAR2(2000);
    l_msg_desc_text       VARCHAR2(2000);
    l_resolve_conflicts_by_rmvl  VARCHAR2(1);
    l_view_conflict_url   VARCHAR2(2000);

    l_approval_nf_rects_tbl  PA_CLIENT_EXTN_ASGMT_WF.Users_List_Tbltyp ;
    l_out_approval_nf_rects_tbl  PA_CLIENT_EXTN_ASGMT_WF.Users_List_Tbltyp ;
    l_number_of_recipients  NUMBER := 0;
    l_approval_nf_rects_rec  PA_CLIENT_EXTN_ASGMT_WF.Users_List_Rectyp ;
    l_ntfy_apprvl_recipient_name wf_users.name%TYPE; ---VARCHAR2(240); Changed for bug 3267790
    l_ntfy_apprvl_rect_person_id NUMBER := 0;
    l_ntfy_apprvl_rect_type VARCHAR2(30);
    l_notification_type VARCHAR2(30);

    l_asgmt_details_url      VARCHAR2(600);
    l_resource_schedules_url VARCHAR2(600);
    l_reapproval_flag  VARCHAR2(1);
    l_aprvl_status pa_project_assignments.apprvl_status_code%TYPE;
    l_override_basis_name VARCHAR2(80) := NULL;
    l_resource_start_date  DATE;

    CURSOR l_prev_asgmt_info_csr (l_assignment_id IN NUMBER)
    IS
    SELECT assignment_effort prev_effort,
          (trunc(end_date) -
          (trunc(start_date)+1)) prev_duration
    FROM  pa_assignments_history
    WHERE assignment_id               = l_assignment_id
    AND   nvl(last_approved_flag,'N') = 'Y';

    CURSOR l_assignments_csr IS
    SELECT
       ppa.assignment_name,
       ppa.assignment_effort,
       ppa.additional_information,
       ppa.description,
       ppa.start_date,
       ppa.end_date,
       ppa.apprvl_status_code,
       ppa.revenue_bill_rate,
       ppa.revenue_currency_code,
       ppa.bill_rate_override,
       ppa.bill_rate_curr_override,
       ppa.markup_percent_override,
       ppa.fcst_tp_amount_type_name,
       ppa.tp_rate_override,
       ppa.tp_currency_override,
       ppa.tp_calc_base_code_override,
       ppa.tp_percent_applied_override,
       ppa.work_type_name,
       ppa.transfer_price_rate,   -- Added for bug 3051110
       ppa.transfer_pr_rate_curr
    FROM pa_project_assignments_v ppa
    WHERE assignment_id = p_assignment_id;

    CURSOR csr_get_override_basis_name (p_override_basis_code IN VARCHAR2) IS
    SELECT plks.meaning
    FROM   pa_lookups plks
    WHERE  plks.lookup_type = 'CC_MARKUP_BASE_CODE'
    AND    plks.lookup_code = p_override_basis_code;

    -- Bug 5362698 - Get the name from HR instead of pa_resources_denorm so
    -- that the latest name is obtained.
    /*
    CURSOR l_resource_csr (l_resource_id IN NUMBER, l_start_date IN DATE) IS
    SELECT res.resource_name,
           hr.name
    FROM   pa_resources_denorm res,
           hr_all_organization_units hr
    WHERE  res.resource_id = l_resource_id
    AND    hr.organization_id = res.resource_organization_id
    AND    l_start_date between resource_effective_start_date and resource_effective_end_date;
    */

    CURSOR l_resource_csr(l_resource_id IN NUMBER, p_start_date IN DATE) IS
    SELECT per.full_name resource_name,
           hou.name
    FROM   per_people_f per,
           per_assignments_f assign,
           hr_all_organization_units hou,
           pa_resource_txn_attributes rta
    WHERE  rta.resource_id = l_resource_id
    AND    rta.person_id = per.person_id
    AND    rta.person_id = assign.person_id
    AND    assign.primary_flag = 'Y'
    AND    assign.assignment_type in ('E','C')
    AND    hou.organization_id = assign.organization_id
    AND    trunc(p_start_date) BETWEEN assign.effective_start_date /*bug 8817301 */
                            AND assign.effective_end_date
    AND    trunc(p_start_date) BETWEEN per.effective_start_date  /*bug 8817301 */
                            AND per.effective_end_date;

    l_prev_asgmt_info_rec l_prev_asgmt_info_csr%ROWTYPE;
    l_assignments_rec l_assignments_csr%ROWTYPE;
    l_resource_rec l_resource_csr%ROWTYPE;
    l_debug_mode VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); -- 5345171

BEGIN

    -- Initialize the Error Stack
    PA_DEBUG.init_err_stack('PA_ASGMT_WFSTD.process_res_fyi_notification');

    --Log Message
    IF l_debug_mode = 'Y' THEN -- 5345171
        PA_DEBUG.write_log
        ( x_module      => 'pa.plsql.PA_ASGMT_WFSTD.process_res_fyi_notification.begin'
         ,x_msg         => 'Beginning of mass fyi workflow api'
         ,x_log_level   => 1);
    END IF;
    log_message('Inside process res mgr');

    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Clear the global PL/SQL message table
    FND_MSG_PUB.initialize;
    x_msg_count := 0;

    ---------------------------------
    --Set the pending approval flag
    ---------------------------------
    Maintain_wf_pending_flag
        (p_assignment_id => p_assignment_id,
         p_mode          => 'APPROVAL_PROCESS_COMPLETED') ;

    log_message('After Maintain pending flag for assignment id:' || p_assignment_id);

    ---------------------------
    --Set the mass wf flag
    ---------------------------
    UPDATE pa_project_assignments
    SET    mass_wf_in_progress_flag = 'N'
    WHERE  assignment_id = p_assignment_id;

    log_message('After setting mass wf flag');

    SELECT resource_id
    INTO   l_resource_id
    FROM   pa_project_assignments
    WHERE  assignment_id = p_assignment_id;

    log_message('After getting resource_id:'|| l_resource_id);

   --------------------------------------------------------------
   --Call Client extension to get the resource recepient(s)
   --------------------------------------------------------------
   --Getting recepients approval type
    SELECT apprvl_status_code
    INTO   l_aprvl_status
    FROM   pa_project_assignments
    WHERE  assignment_id = p_assignment_id;

    log_message('After getting recepients approval type:' || l_aprvl_status);

    IF l_aprvl_status = PA_ASSIGNMENT_APPROVAL_PUB.g_approved THEN
        l_notification_type := 'APPROVAL_FYI';
    ELSE l_notification_type := 'REJECTION_FYI';
    END IF;

    --Getting recepients person_id
    SELECT res.person_id
    INTO   l_ntfy_apprvl_rect_person_id
    FROM   pa_resources_denorm res
    WHERE  res.resource_id    = l_resource_id
    AND    rownum             = 1;

    log_message('After getting person_id:' || l_ntfy_apprvl_rect_person_id);

    --Getting recepients fnd user name
    wf_directory.getusername
        (p_orig_system    => 'PER'
        ,p_orig_system_id => l_ntfy_apprvl_rect_person_id
        ,p_name           => l_ntfy_apprvl_recipient_name
        ,p_display_name   => l_display_name);

   l_ntfy_apprvl_rect_type := 'RESOURCE';

   log_message('After getting l_ntfy_apprvl_recipient_name:' || l_ntfy_apprvl_recipient_name);

   --ceating the recipient in table
   IF l_ntfy_apprvl_recipient_name IS NOT NULL THEN
              l_approval_nf_rects_rec.User_Name := l_ntfy_apprvl_recipient_name;
              l_approval_nf_rects_rec.Person_id := l_ntfy_apprvl_rect_person_id;
              l_approval_nf_rects_rec.Type      := l_ntfy_apprvl_rect_type;
              --l_approval_nf_rects_rec.Routing_Order :=  ?;
              l_approval_nf_rects_tbl(1)        := l_approval_nf_rects_rec;


   log_message('Before Calling client extension to get all recipients');
   log_message('Recipient count:' || l_approval_nf_rects_tbl.COUNT);

   --Calling client extension to get all recipients
   PA_CLIENT_EXTN_ASGMT_WF.Generate_NF_Recipients
       (p_assignment_id             => p_assignment_id
       ,p_project_id                => p_project_id
       ,p_notification_type         => l_notification_type
       ,p_in_list_of_recipients     => l_approval_nf_rects_tbl
       ,x_out_list_of_recipients    => l_out_approval_nf_rects_tbl
       ,x_number_of_recipients      => l_number_of_recipients );

   log_message('After Calling client extension');
   log_message('Recipient count:' || l_out_approval_nf_rects_tbl.COUNT);

   IF (l_out_approval_nf_rects_tbl.COUNT > 0 ) THEN --GSI Bug 7430471

    --Getting the out recipient record
    l_approval_nf_rects_rec := l_out_approval_nf_rects_tbl(1);

    l_ntfy_apprvl_recipient_name := l_approval_nf_rects_rec.User_Name;
    l_ntfy_apprvl_rect_person_id := l_approval_nf_rects_rec.Person_id;
    l_ntfy_apprvl_rect_type      := l_approval_nf_rects_rec.Type;

    log_message('After getting out recipient recoed');

    --------------------------------------
    --Start Resource Notification workflow
    --------------------------------------
    l_wf_started_by_id  := FND_GLOBAL.user_id;
    l_responsibility_id := FND_GLOBAL.resp_id;
    l_resp_appl_id      := FND_GLOBAL.resp_appl_id;

    FND_GLOBAL.Apps_Initialize ( user_id      => l_wf_started_by_id
                               , resp_id      => l_responsibility_id
                               , resp_appl_id => l_resp_appl_id );

    -- Setting thresold value to run the process in background
    l_save_threshold    := wf_engine.threshold;
    wf_engine.threshold := -1;

    log_message('RESOURCE PERSON ID:' || l_ntfy_apprvl_rect_person_id);
    log_message('RESOURCE UNAME:' || l_ntfy_apprvl_recipient_name);

    ----------------------------------------------------------------
    --Getting all local variables required for workflow attributes
    ---------------------------------------------------------------
    OPEN l_assignments_csr;
    FETCH l_assignments_csr INTO l_assignments_rec;

    IF l_assignments_csr%NOTFOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
           pa_utils.add_message (p_app_short_name  => 'PA',
                                 p_msg_name        => 'PA_INVALID_ASMGT_ID');
       x_msg_count := x_msg_count + 1;

        END IF;
    CLOSE l_assignments_csr;

    l_asgmt_details_url := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode=PA_ASMT_LAYOUT' ||
                           '&paCalledPage=ProjStaffedAsmt&paAssignmentId='||p_assignment_id||'&addBreadCrumb=RP';

    l_resource_schedules_url := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode=PA_VIEW_RESOURCE_LAYOUT' ||
                                '&paResourceId='||l_resource_id||'&addBreadCrumb=RP';

    OPEN l_prev_asgmt_info_csr (p_assignment_id) ;
    FETCH l_prev_asgmt_info_csr INTO
          l_prev_asgmt_info_rec;
    IF    l_prev_asgmt_info_csr%NOTFOUND THEN
          l_reapproval_flag := 'N';
    ELSE
          l_reapproval_flag := 'Y';
    END IF;
    CLOSE l_prev_asgmt_info_csr;

    -- Bug 5362698 - use sysdate to get the name so that the latest name
    -- is obtained.
    -- Need to get the Max of StartDate or the Sysdate for future hire. Fix
    -- for Bug# 7585927.
    if(l_assignments_rec.start_date > sysdate) then
      l_resource_start_date := l_assignments_rec.start_date;
    else
      l_resource_start_date := sysdate;
    end if;
    OPEN l_resource_csr(l_resource_id, l_resource_start_date);
    FETCH l_resource_csr INTO l_resource_rec;

    IF l_resource_csr%NOTFOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        pa_utils.add_message (p_app_short_name => 'PA',
                              p_msg_name       => 'PA_INVALID_PERSON_ID');
        x_msg_count := x_msg_count + 1;
    END IF;
    CLOSE l_resource_csr;

     -- Create the unique item key to launch WF with
    SELECT pa_prm_wf_item_key_s.nextval
    INTO   l_itemkey
    FROM   dual;

     -- Create the WF process
    wf_engine.CreateProcess
        ( ItemType => l_wf_item_type
        , ItemKey  => l_itemkey
        , process  => l_wf_process );

    ----------------------------------------------------------------
    -- Set subject, description and overcommiment conflict detail URL
    ---------------------------------------------------------------
    IF (l_assignments_rec.apprvl_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_approved) THEN

       -- If there is no overcommitment conflict
       IF (p_conflict_group_id IS NULL) THEN
          l_msg_subj_code := 'PA_NFSUBJ_ASGMT_APPROVED';
          l_msg_desc_code := 'PA_NFDESC_ASGMT_APPROVED';

       -- If there is any overcommitment conflict
       ELSE
          PA_SCHEDULE_PVT.has_resolved_conflicts_by_rmvl
                                  ( p_conflict_group_id         => p_conflict_group_id
                                  , p_assignment_id             => p_assignment_id
                                  , x_resolve_conflicts_by_rmvl => l_resolve_conflicts_by_rmvl
                                  , x_return_status             => l_return_status
                                  , x_msg_count                 => l_msg_count
                                  , x_msg_data                  => l_msg_data);
          IF (l_resolve_conflicts_by_rmvl = 'Y') THEN
         l_msg_subj_code := 'PA_NFSUBJ_ASGMT_APPR_CONF_REM';
             l_msg_desc_code := 'PA_NFDESC_ASGMT_APPR_CONF_REM';
          ELSE
             l_msg_subj_code := 'PA_NFSUBJ_ASGMT_APPR_KP_CONF';
             l_msg_desc_code := 'PA_NFDESC_ASGMT_APPR_KP_CONF';
          END IF;
       END IF; -- If (p_conflict_group_id IS NULL)
    ELSE
       l_msg_subj_code := 'PA_NFSUBJ_ASGMT_REJECTED';
       l_msg_desc_code := 'PA_NFDESC_ASGMT_REJECTED';
    END IF; -- IF (l_assignments_rec.apprvl_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_approved)

    -- get the message from fnd messages for subject and description
    FND_MESSAGE.SET_NAME ('PA',l_msg_subj_code);
    l_msg_subj_text := FND_MESSAGE.GET;
    FND_MESSAGE.SET_NAME ('PA',l_msg_desc_code);
    l_msg_desc_text := FND_MESSAGE.GET;

    -- set resource overcommitment url
    l_view_conflict_url := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode='
                        || 'PA_RES_OVERCOMMITMENT_LAYOUT&paAssignmentId=' || p_assignment_id
                        || '&paConflictGroupId=' || p_conflict_group_id
                        || '&paCallingPage=Default&addBreadCrumb=RP';

    log_message('Setting item attributes Inside process res mgr');

    ------------------------------------------------------------
    --Set the item attributes required for resource notification
    ------------------------------------------------------------
    -- setting subject, description, conflict URL for overcommitment
    wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'MSG_SUBJECT'
        , avalue   => l_msg_subj_text);

     wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'MSG_DESCRIPTION'
        , avalue   => l_msg_desc_text );

--    IF (l_assignments_rec.apprvl_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_approved AND
--        p_conflict_group_id IS NOT NULL) THEN
          wf_engine.SetItemAttrText
              ( itemtype => l_wf_item_type
              , itemkey  => l_itemkey
              , aname    => 'CONFLICT_URL'
              , avalue   => l_view_conflict_url );
--    END IF;

    --Setting Resource attributes
    wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'NTFY_FYI_USER_NAME'
        , avalue   => l_ntfy_apprvl_recipient_name);

     wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'RESOURCE_NAME'
        , avalue   => l_resource_rec.resource_name );

    wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'RESOURCE_ORGANIZATION'
        , avalue   => l_resource_rec.name );


    --Setting URL information
    wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'ASSIGNMENT_DETAILS_URL'
        , avalue   => l_asgmt_details_url );

    wf_engine.SetItemAttrText
    ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'RESOURCE_SCHEDULES_URL'
        , avalue   => l_resource_schedules_url );

    --Setting assignment attributes
    IF l_reapproval_flag = 'Y' THEN
           wf_engine.SetItemAttrNumber
                    ( itemtype => l_wf_item_type
                    , itemkey => l_itemkey
                    , aname   => 'PREV_DURATION'
                    , avalue  => l_prev_asgmt_info_rec.prev_duration );

           wf_engine.SetItemAttrNumber
                   ( itemtype => l_wf_item_type
                    ,itemkey  => l_itemkey
                    , aname   => 'PREV_EFFORT'
                    , avalue  => l_prev_asgmt_info_rec.prev_effort );
    END IF;

           -- Start Additions by RM for bug 2274426
           wf_engine.SetItemAttrNumber
                               ( itemtype => l_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'REVENUE_BILL_RATE'
                               , avalue => l_assignments_rec.revenue_bill_rate
                               );
           wf_engine.SetItemAttrText
                            ( itemtype => l_wf_item_type
                            , itemkey => l_itemkey
                            , aname => 'REVENUE_BILL_RATE_CURR'
                            , avalue => l_assignments_rec.revenue_currency_code
                            );
           wf_engine.SetItemAttrNumber
                               ( itemtype => l_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'BILL_RATE_OVERRIDE'
                               , avalue => l_assignments_rec.bill_rate_override
                               );
           wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'BILL_RATE_OVERRIDE_CURR'
                          , avalue => l_assignments_rec.bill_rate_curr_override
                          );
           IF l_assignments_rec.markup_percent_override IS NOT NULL THEN
              wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'MARKUP_PCT_OVERRIDE'
                          , avalue => to_char(l_assignments_rec.markup_percent_override)||'%'
                          );
           ELSE
               wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'MARKUP_PCT_OVERRIDE'
                          , avalue => to_char(l_assignments_rec.markup_percent_override)
                          );
           END IF;
           wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'TP_AMT_TYPE_NAME'
                          , avalue => l_assignments_rec.fcst_tp_amount_type_name
                          );
           wf_engine.SetItemAttrNumber
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'TP_RATE_OVERRIDE'
                          , avalue => l_assignments_rec.tp_rate_override
                          );
           wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'TP_RATE_OVERRIDE_CURR'
                          , avalue => l_assignments_rec.tp_currency_override
                          );
           IF l_assignments_rec.tp_calc_base_code_override IS NOT NULL THEN
              open csr_get_override_basis_name(l_assignments_rec.tp_calc_base_code_override);
              fetch csr_get_override_basis_name into l_override_basis_name;
              close csr_get_override_basis_name;
           END IF;
           wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'OVERRIDE_BASIS_NAME'
                          , avalue => l_override_basis_name
                          );
           IF l_assignments_rec.tp_percent_applied_override IS NOT NULL THEN
              IF l_override_basis_name IS NOT NULL THEN
                 wf_engine.SetItemAttrText
                     ( itemtype => l_wf_item_type
                     , itemkey => l_itemkey
                     , aname => 'TP_PCT_APPLIED_OVERRIDE'
                     , avalue => ', '||to_char(l_assignments_rec.tp_percent_applied_override)||'%'
                     );
              ELSE
                 wf_engine.SetItemAttrText
                     ( itemtype => l_wf_item_type
                     , itemkey => l_itemkey
                     , aname => 'TP_PCT_APPLIED_OVERRIDE'
                     , avalue => to_char(l_assignments_rec.tp_percent_applied_override)||'%'
                     );
              END IF;
           ELSE
              wf_engine.SetItemAttrText
                     ( itemtype => l_wf_item_type
                     , itemkey => l_itemkey
                     , aname => 'TP_PCT_APPLIED_OVERRIDE'
                     , avalue => to_char(l_assignments_rec.tp_percent_applied_override)
                     );
           END IF;
           wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'WORK_TYPE_NAME'
                          , avalue => l_assignments_rec.work_type_name
                          );
           -- End of Additions by RM

    wf_engine.SetItemAttrText
    ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'ASSIGNMENT_NAME'
        , avalue   => l_assignments_rec.assignment_name );

    wf_engine.SetItemAttrNumber
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'ASSIGNMENT_DURATION'
        , avalue   => (trunc(l_assignments_rec.end_date) -
                     trunc(l_assignments_rec.start_date)+1) );

    wf_engine.SetItemAttrNumber
    ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'ASSIGNMENT_EFFORT'
        , avalue   => l_assignments_rec.assignment_effort );

    wf_engine.SetItemAttrText
    ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'DESCRIPTION'
        , avalue   => l_assignments_rec.description );

    wf_engine.SetItemAttrText
    ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'ADDITIONAL_INFORMATION'
        , avalue   => l_assignments_rec.additional_information );

    --Setting Project attributes
    wf_engine.SetItemAttrText
    ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'PROJECT_NAME'
        , avalue   => p_project_name );

    wf_engine.SetItemAttrText
    ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'PROJECT_NUMBER'
        , avalue   => p_project_number );

    wf_engine.SetItemAttrText
    ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'PROJECT_MANAGER_NAME'
        , avalue   => p_project_manager );

    wf_engine.SetItemAttrText
    ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'PROJECT_ORGANIZATION'
        , avalue   => p_project_org );

    wf_engine.SetItemAttrText
    ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'PROJECT_CUSTOMER'
        , avalue   => p_project_cus );

    wf_engine.SetItemAttrDate
    ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'START_DATE'
        , avalue   => l_assignments_rec.start_date);

    wf_engine.SetItemAttrDate
    ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'END_DATE'
        , avalue   => l_assignments_rec.end_date);

/*  Added for bug 3051110   */

    wf_engine.SetItemAttrNumber
        (  itemtype => l_wf_item_type
         , Itemkey => l_itemkey
         , aname => 'TRANSFER_PRICE_RATE'
         , avalue => l_assignments_rec.transfer_price_rate);

    wf_Engine.SetItemAttrText
       (itemtype => l_wf_item_type
        , itemkey => l_itemkey
    , aname => 'TRANSFER_PR_RATE_CURR'
    , avalue => l_assignments_rec.transfer_pr_rate_curr);

    --Start the workflow process
    wf_engine.StartProcess ( itemtype => l_wf_item_type
                            ,itemkey  => l_itemkey );

    PA_WORKFLOW_UTILS.Insert_WF_Processes
        (p_wf_type_code        => 'MASS_ASSIGNMENT_APPROVAL'
        ,p_item_type           => l_wf_item_type
        ,p_item_key            => l_itemkey
        ,p_entity_key1         => to_char(p_project_id)
        ,p_entity_key2         => to_char(p_assignment_id)
        ,p_description         => NULL
        ,p_err_code            => l_err_code
        ,p_err_stage           => l_err_stage
        ,p_err_stack           => l_err_stack );

     END IF ; -- GSI Bug 7430471
    END IF;--end recipient name is null (no fnd_user for this resource)


    --Setting the original value
    wf_engine.threshold := l_save_threshold;

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
    WHEN OTHERS THEN

         --Setting the original value
         wf_engine.threshold := l_save_threshold;

         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_ASGMT_WFSTD.process_res_fyi_notification'
              ,p_procedure_name => PA_DEBUG.G_Err_Stack );

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;
END process_res_fyi_notification;

--------------------------------------------------------
--This API sets the workflow attributes for Manager FYIs
--Manager FYIs include notifications to Resource Manager
--Staffing Manager and Project Managers
---------------------------------------------------------
PROCEDURE set_manager_attributes
    ( itemtype               IN   VARCHAR2
     ,itemkey                IN   VARCHAR2
     ,p_group_id             IN   NUMBER
     ,p_mode                 IN   VARCHAR2
     ,p_update_info_doc      IN   VARCHAR2  := FND_API.G_MISS_CHAR
     ,p_num_apr_asgns        IN   NUMBER
     ,p_num_rej_asgns        IN   NUMBER
     ,p_project_name         IN   VARCHAR2
     ,p_project_number       IN   VARCHAR2
     ,p_project_manager      IN   VARCHAR2
     ,p_project_org          IN   VARCHAR2
     ,p_project_cus          IN   VARCHAR2
     ,p_conflict_group_id    IN   NUMBER    := FND_API.G_MISS_NUM
     ,p_notified_id          IN   NUMBER
     ,x_return_status        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count            OUT  NOCOPY NUMBER ) --File.Sql.39 bug 4440895
IS

    l_assignment_id         NUMBER;
    l_msg_count             NUMBER := 0;
    l_error_message_code    VARCHAR2(30);
    l_return_status         VARCHAR2(1);
    l_wf_item_type          VARCHAR2(30);
    l_itemkey               NUMBER;
    l_conflict_url          VARCHAR2(600);
    l_selected_roles_url   VARCHAR2(600);
    l_selected_roles2_url   VARCHAR2(600);
    l_selected_resources_url   VARCHAR2(600);
    l_selected_resources2_url   VARCHAR2(600);
    l_conflict_group_id     NUMBER;

    CURSOR l_assignments_csr (l_assignment_id IN NUMBER ) IS
    SELECT
       ppa.project_id,
       ppa.assignment_name,
       ppa.assignment_effort,
       ppa.additional_information,
       ppa.description,
       ppa.start_date,
       ppa.end_date,
       ppa.revenue_bill_rate,
       ppa.revenue_currency_code,
       ppa.bill_rate_override,
       ppa.bill_rate_curr_override,
       ppa.markup_percent_override,
       ppa.fcst_tp_amount_type_name,
       ppa.tp_rate_override,
       ppa.tp_currency_override,
       ppa.tp_calc_base_code_override,
       ppa.tp_percent_applied_override,
       ppa.work_type_name,
       hr.name
    FROM pa_project_assignments_v ppa,
         pa_resources_denorm res,
         hr_all_organization_units hr
    WHERE ppa.assignment_id    = l_assignment_id
    AND   res.resource_id      = ppa.resource_id
    AND   ppa.start_date BETWEEN res.resource_effective_start_date
                             AND res.resource_effective_end_date
    AND   hr.organization_id   = res.resource_organization_id;

CURSOR csr_get_override_basis_name (p_override_basis_code IN VARCHAR2) IS
SELECT plks.meaning
FROM   pa_lookups plks
WHERE  plks.lookup_type = 'CC_MARKUP_BASE_CODE'
AND    plks.lookup_code = p_override_basis_code;

    l_assignments_rec l_assignments_csr%ROWTYPE;
    l_override_basis_name  VARCHAR2(80) := NULL;

BEGIN

        log_message('Inside set manager attributes');

        l_wf_item_type := itemtype;
        l_itemkey      := itemkey;

        BEGIN
                SELECT object_id1
                INTO   l_assignment_id
                FROM   pa_wf_ntf_performers
                WHERE  group_id = p_group_id
                AND    rownum   = 1;
            EXCEPTION
                WHEN OTHERS THEN
                   null;
            END;

            OPEN l_assignments_csr (l_assignment_id);
            FETCH l_assignments_csr INTO l_assignments_rec;

            IF l_assignments_csr%NOTFOUND THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
                   pa_utils.add_message (p_app_short_name  => 'PA',
                                         p_msg_name        => 'PA_INVALID_ASMGT_ID');
               l_msg_count := l_msg_count + 1;

            END IF;
            CLOSE l_assignments_csr;

          l_selected_roles_url := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275' ||
                '&akRegionCode=PA_SELECTED_ROLES_LAYOUT&paCallingPage=WF_Notifications' ||
                '&paProjectId=' || l_assignments_rec.project_id || '&paNotifiedId=' ||
                p_notified_id || '&paGroupId=' || p_group_id || '&paApprovalStatus=Approved&addBreadCrumb=RP';

          l_selected_roles2_url := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275' ||
                '&akRegionCode=PA_SELECTED_ROLES_LAYOUT&paCallingPage=WF_Notifications' ||
                '&paProjectId=' || l_assignments_rec.project_id || '&paNotifiedId=' ||
                p_notified_id || '&paGroupId=' || p_group_id || '&paApprovalStatus=Rejected&addBreadCrumb=RP';

        ------------------------------------------------------------
        --If this is assignment creation mode set assignment info
        --else set Updated Info attributes
        -----------------------------------------------------------

        IF p_mode = PA_MASS_ASGMT_TRX.G_MASS_ASGMT THEN

            l_selected_resources_url := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275' ||
                '&akRegionCode=PA_SELECTED_RESOURCES_LAYOUT&paCallingPage=WF_Notifications' ||
                '&paProjectId=' || l_assignments_rec.project_id || '&paNotifiedId=' ||
                p_notified_id || '&paGroupId=' || p_group_id || '&paApprovalStatus=Approved&addBreadCrumb=RP';

            l_selected_resources2_url := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275' ||
                '&akRegionCode=PA_SELECTED_RESOURCES_LAYOUT&paCallingPage=WF_Notifications' ||
                '&paProjectId=' || l_assignments_rec.project_id || '&paNotifiedId=' ||
                p_notified_id || '&paGroupId=' || p_group_id || '&paApprovalStatus=Rejected&addBreadCrumb=RP';

            wf_engine.SetItemAttrText
                ( itemtype => l_wf_item_type
                , itemkey  => l_itemkey
                , aname    => 'SELECTED_RESOURCES_URL'
                , avalue   => l_selected_resources_url);

            wf_engine.SetItemAttrText
                ( itemtype => l_wf_item_type
                , itemkey  => l_itemkey
                , aname    => 'SELECTED_RESOURCES2_URL'
                , avalue   => l_selected_resources2_url);

             wf_engine.SetItemAttrText
                 ( itemtype => l_wf_item_type
                 , itemkey  => l_itemkey
                 , aname    => 'ASSIGNMENT_NAME'
                 , avalue   => l_assignments_rec.assignment_name );

            wf_engine.SetItemAttrText
                ( itemtype => l_wf_item_type
                , itemkey  => l_itemkey
                , aname    => 'RESOURCE_ORGANIZATION'
                , avalue   => l_assignments_rec.name );

            wf_engine.SetItemAttrNumber
                ( itemtype => l_wf_item_type
                , itemkey  => l_itemkey
                , aname    => 'ASSIGNMENT_DURATION'
                , avalue   => (trunc(l_assignments_rec.end_date) -
                               trunc(l_assignments_rec.start_date)+1) );

            wf_engine.SetItemAttrNumber
                ( itemtype => l_wf_item_type
                , itemkey  => l_itemkey
                , aname    => 'ASSIGNMENT_EFFORT'
                , avalue   => l_assignments_rec.assignment_effort );

            wf_engine.SetItemAttrText
                ( itemtype => l_wf_item_type
                , itemkey  => l_itemkey
                , aname    => 'DESCRIPTION'
                , avalue   => l_assignments_rec.description );

            wf_engine.SetItemAttrText
                ( itemtype => l_wf_item_type
                , itemkey  => l_itemkey
                , aname    => 'ADDITIONAL_INFORMATION'
                , avalue   => l_assignments_rec.additional_information );

           wf_engine.SetItemAttrDate
                  (itemtype => l_wf_item_type
                              , itemkey => l_itemkey
                              , aname => 'START_DATE'
                              , avalue => l_assignments_rec.start_date
                              );

           wf_engine.SetItemAttrDate
                  (itemtype => l_wf_item_type
                              , itemkey => l_itemkey
                              , aname => 'END_DATE'
                              , avalue => l_assignments_rec.end_date
                              );
           -- Start Additions by RM for bug 2274426
           wf_engine.SetItemAttrNumber
                               ( itemtype => l_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'REVENUE_BILL_RATE'
                               , avalue => l_assignments_rec.revenue_bill_rate
                               );
           wf_engine.SetItemAttrText
                            ( itemtype => l_wf_item_type
                            , itemkey => l_itemkey
                            , aname => 'REVENUE_BILL_RATE_CURR'
                            , avalue => l_assignments_rec.revenue_currency_code
                            );
           wf_engine.SetItemAttrNumber
                               ( itemtype => l_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'BILL_RATE_OVERRIDE'
                               , avalue => l_assignments_rec.bill_rate_override
                               );
           wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'BILL_RATE_OVERRIDE_CURR'
                          , avalue => l_assignments_rec.bill_rate_curr_override
                          );
           IF l_assignments_rec.markup_percent_override IS NOT NULL THEN
              wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'MARKUP_PCT_OVERRIDE'
                          , avalue => to_char(l_assignments_rec.markup_percent_override)||'%'
                          );
           ELSE
               wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'MARKUP_PCT_OVERRIDE'
                          , avalue => to_char(l_assignments_rec.markup_percent_override)
                          );
           END IF;
           wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'TP_AMT_TYPE_NAME'
                          , avalue => l_assignments_rec.fcst_tp_amount_type_name
                          );
           wf_engine.SetItemAttrNumber
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'TP_RATE_OVERRIDE'
                          , avalue => l_assignments_rec.tp_rate_override
                          );
           wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'TP_RATE_OVERRIDE_CURR'
                          , avalue => l_assignments_rec.tp_currency_override
                          );
           IF l_assignments_rec.tp_calc_base_code_override IS NOT NULL THEN
              open csr_get_override_basis_name(l_assignments_rec.tp_calc_base_code_override);
              fetch csr_get_override_basis_name into l_override_basis_name;
              close csr_get_override_basis_name;
           END IF;
           wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'OVERRIDE_BASIS_NAME'
                          , avalue => l_override_basis_name
                          );
           IF l_assignments_rec.tp_percent_applied_override IS NOT NULL THEN
              IF l_override_basis_name IS NOT NULL THEN
                 wf_engine.SetItemAttrText
                     ( itemtype => l_wf_item_type
                     , itemkey => l_itemkey
                     , aname => 'TP_PCT_APPLIED_OVERRIDE'
                     , avalue => ', '||to_char(l_assignments_rec.tp_percent_applied_override)||'%'
                     );
              ELSE
                 wf_engine.SetItemAttrText
                     ( itemtype => l_wf_item_type
                     , itemkey => l_itemkey
                     , aname => 'TP_PCT_APPLIED_OVERRIDE'
                     , avalue => to_char(l_assignments_rec.tp_percent_applied_override)||'%'
                     );
              END IF;
           ELSE
              wf_engine.SetItemAttrText
                     ( itemtype => l_wf_item_type
                     , itemkey => l_itemkey
                     , aname => 'TP_PCT_APPLIED_OVERRIDE'
                     , avalue => to_char(l_assignments_rec.tp_percent_applied_override)
                     );
           END IF;
           wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'WORK_TYPE_NAME'
                          , avalue => l_assignments_rec.work_type_name
                          );
           -- End of Additions by RM

        ELSIF (p_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_ASGMT_BASIC_INFO OR
               p_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_COMPETENCIES     OR
               p_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_FORECAST_ITEMS   OR
               p_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_SCHEDULE )

        THEN

            wf_engine.SetItemAttrDocument
                ( itemtype => l_wf_item_type
                , itemkey  => l_itemkey
                , aname    => 'UPDATED_INFO_DOC'
                , documentid   => p_update_info_doc );

        END IF;

        ---------------------------------------------------------------------
        --Setting Common attributes for CRN / UPD / APS
        --------------------------------------------------------------------

        --Setting Assignment Attributes
        wf_engine.SetItemAttrNumber
            ( itemtype => l_wf_item_type
            , itemkey  => l_itemkey
            , aname    => 'APPROVED_ASSIGNMENTS'
            , avalue   => p_num_apr_asgns );

        wf_engine.SetItemAttrText
            ( itemtype => l_wf_item_type
            , itemkey  => l_itemkey
            , aname    => 'SELECTED_ROLES_URL'
            , avalue   => l_selected_roles_url);

        wf_engine.SetItemAttrText
            ( itemtype => l_wf_item_type
            , itemkey  => l_itemkey
            , aname    => 'SELECTED_ROLES2_URL'
            , avalue   => l_selected_roles2_url);

         wf_engine.SetItemAttrNumber
            ( itemtype => l_wf_item_type
            , itemkey  => l_itemkey
            , aname    => 'REJECTED_ASSIGNMENTS'
            , avalue   => p_num_rej_asgns );

        --Setting Project attributes
        wf_engine.SetItemAttrText
            ( itemtype => l_wf_item_type
            , itemkey  => l_itemkey
            , aname    => 'PROJECT_NAME'
            , avalue   => p_project_name );

        wf_engine.SetItemAttrText
           ( itemtype => l_wf_item_type
            , itemkey  => l_itemkey
            , aname    => 'PROJECT_NUMBER'
            , avalue   => p_project_number );

        wf_engine.SetItemAttrText
            ( itemtype => l_wf_item_type
            , itemkey  => l_itemkey
            , aname    => 'PROJECT_MANAGER_NAME'
            , avalue   => p_project_manager );

        wf_engine.SetItemAttrText
            ( itemtype => l_wf_item_type
            , itemkey  => l_itemkey
            , aname    => 'PROJECT_ORGANIZATION'
            , avalue   => p_project_org );

        wf_engine.SetItemAttrText
            ( itemtype => l_wf_item_type
            , itemkey  => l_itemkey
            , aname    => 'PROJECT_CUSTOMER'
            , avalue   => p_project_cus );

        -- Always display View Conflict link
        IF (p_conflict_group_id IS NUll OR p_conflict_group_id = FND_API.G_MISS_NUM) THEN
           l_conflict_group_id := '';
        ELSE
           l_conflict_group_id := p_conflict_group_id;
        END IF;

        l_conflict_url := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode=PA_VIEW_CONFLICTS_LAYOUT&paProjectId=' ||
                          l_assignments_rec.project_id || '&paCallingPage=MassAsmtFYINotif&paConflictGroupId=' ||
                          l_conflict_group_id || '&addBreadCrumb=RP';

         wf_engine.SetItemAttrText
               ( itemtype => l_wf_item_type
               , itemkey  => l_itemkey
               , aname    => 'CONFLICT_URL'
               , avalue   => l_conflict_url );

        x_msg_count := l_msg_count;

END set_manager_attributes;

/** This API starts the FYI notifications to indicate if
  * asignments have been approved or rejected. It sends the following notification.
  *     1. Staffing Manager FYI for the mass txn
  *     2. Resource Manager FYI for the mass txn
  *     3. Project Manager FYI for the mass txn
  * The logic involves calling the client extension for every
  * assignment and populating pa_wf_ntf_performers table
  * Notifications are then sent to recipients from the pa_wf_ntf_performers table
  */
PROCEDURE process_mgr_fyi_notification
    ( p_assignment_id_tbl    IN   SYSTEM.pa_num_tbl_type
     ,p_project_id           IN   NUMBER    := FND_API.G_MISS_NUM
     ,p_group_id             IN   NUMBER    := FND_API.G_MISS_NUM
     ,p_mode                 IN   VARCHAR2
     ,p_update_info_doc      IN   VARCHAR2  := FND_API.G_MISS_CHAR
     ,p_num_apr_asgns        IN   NUMBER
     ,p_num_rej_asgns        IN   NUMBER
     ,p_project_name         IN   VARCHAR2
     ,p_project_number       IN   VARCHAR2
     ,p_project_manager      IN   VARCHAR2
     ,p_project_org          IN   VARCHAR2
     ,p_project_cus          IN   VARCHAR2
     ,p_submitter_user_name  IN   VARCHAR2
     ,p_conflict_group_id    IN   NUMBER    := FND_API.G_MISS_NUM
     ,x_return_status        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count            OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data             OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
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
    l_msg_index_out   NUMBER ;
    l_msg_data            VARCHAR2(2000);
    l_wf_item_type        VARCHAR2(2000):= 'PARMAAP'; --Assignment Approval Item type
    l_wf_process          VARCHAR2(2000);
    l_err_code        NUMBER := 0;
    l_err_stage       VARCHAR2(2000);
    l_err_stack           VARCHAR2(2000);
    l_assignment_id       NUMBER;
    l_recipients_tbl      SYSTEM.pa_varchar2_240_tbl_type;  /*Commented SYSTEM.pa_varchar2_30_tbl_type for the bug 3311991*/
    l_recipients_type_tbl SYSTEM.pa_varchar2_30_tbl_type;

    l_approval_nf_rects_tbl                  PA_CLIENT_EXTN_ASGMT_WF.Users_List_Tbltyp ;
    l_out_approval_nf_rects_tbl              PA_CLIENT_EXTN_ASGMT_WF.Users_List_Tbltyp ;
    l_number_of_recipients                   NUMBER := 0;
    l_approval_nf_rects_rec                  PA_CLIENT_EXTN_ASGMT_WF.Users_List_Rectyp ;
    l_ntfy_apprvl_recipient_name             wf_users.name%TYPE; ---VARCHAR2(240); Changer for 3267790
    l_ntfy_apprvl_rect_person_id             NUMBER := 0;
    l_ntfy_apprvl_rect_type                  VARCHAR2(30);
    l_notification_type                      VARCHAR2(30);

    l_res_mgr_person_id           NUMBER;
    l_staff_mgr_person_id         NUMBER;
    l_project_manager_person_id   NUMBER ;
    l_project_manager_name        per_all_people_f.full_name%TYPE; --VARCHAR2(200);  Changed for bug 3267790
    l_project_party_id            NUMBER ;
    l_project_role_id             NUMBER ;
    l_project_role_name           VARCHAR2(80);
    l_admin_project               VARCHAR2(1); --Variable which denotes if a project is an admin project or not
    l_num_apr_asgns               NUMBER ;
    l_num_rej_asgns               NUMBER ;
    l_display_name        wf_users.display_name%TYPE; --VARCHAR2(360); Commented VARCHAR2(360) for bug 3267790 --Commented VARCHAR2(200) for bug 3311991
    l_approver_name       wf_users.display_name%TYPE; --VARCHAR2(320); Commented VARCHAR2(320) for bug 3267790 --Commented VARCHAR2(200) for bug 3311991
    l_aprvl_status_code   pa_project_assignments.apprvl_status_code%TYPE;
    l_assignment_id_tbl   SYSTEM.pa_num_tbl_type;

    CURSOR Resource_Manager IS
    SELECT distinct res.manager_id
    FROM   pa_resources_denorm res,
           pa_project_assignments asgn,
           pa_wf_ntf_performers ntf,
           fnd_user fnd
    WHERE  ntf.group_id       = p_group_id
    AND    asgn.assignment_id = l_assignment_id
    AND    asgn.assignment_id = ntf.object_id1
    AND    res.resource_id    = asgn.resource_id
    AND    asgn.start_date BETWEEN res.resource_effective_start_date
               AND     res.resource_effective_end_date
    AND    res.manager_id     = fnd.employee_id
    AND    fnd.user_name     <> ntf.user_name;

    CURSOR Staffing_Manager IS
    SELECT distinct per.person_id as staffing_mgr_id
    FROM   fnd_grants fg,
           fnd_objects fob,
           fnd_user fnd,
           pa_resources_denorm res,
           /* Commenting this for performance tuning Bug#2499051
           (select pa_security_pvt.get_menu_id('PA_PRM_RES_PRMRY_CONTACT') menu_id
              from   dual) temp, */
           pa_project_assignments asgn,
           pa_wf_ntf_performers ntf,
           wf_roles wf,
           per_all_people_f per
    WHERE  ntf.group_id       = p_group_id
    AND    asgn.assignment_id = l_assignment_id
    AND    asgn.assignment_id = ntf.object_id1
    AND    res.resource_id    = asgn.resource_id
    AND    asgn.start_date BETWEEN res.resource_effective_start_date
               AND     res.resource_effective_end_date
    --AND    fnd.employee_id    = to_number(substr(fg.grantee_key,instr(fg.grantee_key,':')+1))
    AND    fnd.employee_id    = per.person_id
    AND    per.party_id = wf.orig_system_id
    AND    sysdate between per.effective_start_date and per.effective_end_date
    AND    wf.orig_system = 'HZ_PARTY'
    AND    fg.grantee_key = wf.name
    AND    fnd.user_name     <> ntf.user_name
    AND    fg.instance_pk1_value = TO_CHAR(res.resource_organization_id)
    AND    fg.instance_type   = 'INSTANCE'
    AND    fg.object_id       = fob.object_id
    AND    fob.obj_name       = 'ORGANIZATION'
    AND    fg.menu_id         = pa_security_pvt.get_menu_id('PA_PRM_RES_PRMRY_CONTACT') /* temp.menu_id commented for bug#2499051 */
    AND    fg.grantee_type    = 'USER'
    AND    trunc(SYSDATE) BETWEEN trunc(fg.start_date)
                          AND     trunc(NVL(fg.END_DATE, SYSDATE+1));

    l_index NUMBER;

    CURSOR get_managers IS
        SELECT distinct user_name,
               user_type
        FROM pa_wf_ntf_performers
        WHERE wf_type_code  = 'MASS_APPROVAL_FYI'
        AND group_id        = p_group_id;
    l_notified_id NUMBER;
    l_debug_mode VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); -- 5345171

BEGIN

    -- Initialize the Error Stack
    PA_DEBUG.init_err_stack('PA_ASGMT_WFSTD.process_mgr_fyi_notification');

    --Log Message
    IF l_debug_mode = 'Y' THEN -- 5345171
        PA_DEBUG.write_log
        ( x_module      => 'pa.plsql.PA_ASGMT_WFSTD.process_mgr_fyi_notification.begin'
         ,x_msg         => 'Beginning of mass fyi workflow api'
         ,x_log_level   => 1);
    END IF;

    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Clear the global PL/SQL message table
    FND_MSG_PUB.initialize;

    --------------------------------------------
    --Get Project Manager for these assignments
    --------------------------------------------
    --Get the project type
    --MOAC Changes: Bug 4363092 : removed nvl usage with org_id
    SELECT NVL(pt.administrative_flag,'N') admin_flag
    INTO   l_admin_project
    FROM   pa_projects_all pap,
           pa_project_types_all pt
    WHERE  pap.project_id = p_project_id
    AND    pt.project_type = pap.project_type
    AND    pap.org_id = pt.org_id;

    --Only Non-admin Projects have managers
    IF l_admin_project = 'N' THEN

        --Log Message
        IF l_debug_mode = 'Y' THEN -- 5345171
                PA_DEBUG.write_log
                    (x_module    => 'pa.plsql.PA_ASGMT_WFSTD.process_mgr_fyi_notification.check_prj_manager.'
                    ,x_msg       => 'Check if project manger exists.'
                    ,x_log_level => 1);
        END IF;

        pa_project_parties_utils.get_curr_proj_mgr_details
            ( p_project_id         => p_project_id
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

        l_return_status := FND_API.G_MISS_CHAR;
        l_error_message_code := FND_API.G_MISS_CHAR;

    END IF; --end l_admin_project = 'N'

    log_message('After Getting manager');

    l_assignment_id_tbl := p_assignment_id_tbl;

    ---------------------------------------------------------
    --For every assignment in this mass transaction populate
    --pa_wf_ntf_performers with recipients
    --Assumptions: The project manager remains the same for
    --all assignments in the client extension
    --------------------------------------------------------
    FOR i in 1..l_assignment_id_tbl.COUNT LOOP

        --Getting recepients approval type
        SELECT apprvl_status_code
        INTO   l_aprvl_status_code
        FROM   pa_project_assignments
        WHERE  assignment_id = l_assignment_id_tbl(i);

        IF l_aprvl_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_approved THEN
            l_notification_type := 'APPROVAL_FYI';
        ELSE l_notification_type := 'REJECTION_FYI';
        END IF;

        --Get Resource Manager and Staffing Manager for this
        --assignment and pass to client extension along with
        --Project Manager
        l_assignment_id := l_assignment_id_tbl(i);

        --Getting Resource manager
        OPEN Resource_Manager;
        FETCH Resource_manager INTO l_res_mgr_person_id;
        CLOSE Resource_Manager;

        --Getting Staffing Manager
        OPEN Staffing_Manager;
        FETCH Staffing_manager INTO l_staff_mgr_person_id;
        CLOSE Staffing_Manager;

        ----------------------------------------------
        --Build recipient IN table for client extensions
        ----------------------------------------------

        l_index := 0;

        --Populating Resource manager in recipient table
        ------------------------------------------------
        IF l_res_mgr_person_id IS NOT NULL THEN

            --Getting recepients fnd user name
            wf_directory.getusername
            (p_orig_system    => 'PER'
            ,p_orig_system_id => l_res_mgr_person_id
            ,p_name           => l_ntfy_apprvl_recipient_name
            ,p_display_name   => l_display_name);

            l_ntfy_apprvl_rect_type := 'RESOURCE_MANAGER';

            --ceating the recipient in table
            IF l_ntfy_apprvl_recipient_name IS NOT NULL THEN
                l_approval_nf_rects_rec.User_Name := l_ntfy_apprvl_recipient_name;
                l_approval_nf_rects_rec.Person_id := l_res_mgr_person_id;
                l_approval_nf_rects_rec.Type      := l_ntfy_apprvl_rect_type;
                --l_approval_nf_rects_rec.Routing_Order :=  ?;
                l_approval_nf_rects_tbl(l_index + 1)        := l_approval_nf_rects_rec;
                l_index := l_index + 1;
            END IF;

        END IF;

        log_message('Resource Mgr name:' || l_ntfy_apprvl_recipient_name);


        --Populating Staffing manager in recipient table
        ------------------------------------------------
        IF l_staff_mgr_person_id IS NOT NULL THEN

            --Getting recepients fnd user name
            wf_directory.getusername
            (p_orig_system    => 'PER'
            ,p_orig_system_id => l_staff_mgr_person_id
            ,p_name           => l_ntfy_apprvl_recipient_name
            ,p_display_name   => l_display_name);

            l_ntfy_apprvl_rect_type := 'STAFFING_MANAGER';

            IF l_ntfy_apprvl_recipient_name IS NOT NULL THEN
                l_approval_nf_rects_rec.User_Name := l_ntfy_apprvl_recipient_name;
                l_approval_nf_rects_rec.Person_id := l_staff_mgr_person_id;
                l_approval_nf_rects_rec.Type      := l_ntfy_apprvl_rect_type;
                --l_approval_nf_rects_rec.Routing_Order :=  ?;
                l_approval_nf_rects_tbl(l_index + 1)        := l_approval_nf_rects_rec;
                l_index := l_index + 1;
            END IF;

        END IF;

        log_message('Staff Mgr name:' || l_ntfy_apprvl_recipient_name);


        --Populating Project manager in recipient table
        -----------------------------------------------
        IF l_project_manager_person_id IS NOT NULL THEN

            --Getting recepients fnd user name
            wf_directory.getusername
            (p_orig_system    => 'PER'
            ,p_orig_system_id => l_project_manager_person_id
            ,p_name           => l_ntfy_apprvl_recipient_name
            ,p_display_name   => l_display_name);

            l_ntfy_apprvl_rect_type := 'PROJECT_MANAGER';

            IF l_ntfy_apprvl_recipient_name IS NOT NULL THEN
                l_approval_nf_rects_rec.User_Name := l_ntfy_apprvl_recipient_name;
                l_approval_nf_rects_rec.Person_id := l_project_manager_person_id;
                l_approval_nf_rects_rec.Type      := l_ntfy_apprvl_rect_type;
                --l_approval_nf_rects_rec.Routing_Order :=  ?;
                l_approval_nf_rects_tbl(l_index + 1)        := l_approval_nf_rects_rec;
                l_index := l_index + 1;
            END IF;

        END IF;

        log_message('Before calling mgr client extensions');
        log_message('Project Mgr name:' || l_ntfy_apprvl_recipient_name);
        log_message('assignment_id:' || l_assignment_id);
        log_message('Before COUNT:' || l_approval_nf_rects_tbl.COUNT);

        -------------------------------------------------
        --Calling client extension to get all recipients
        -------------------------------------------------
        PA_CLIENT_EXTN_ASGMT_WF.Generate_NF_Recipients
           (p_assignment_id             => l_assignment_id
           ,p_project_id                => p_project_id
           ,p_notification_type         => l_notification_type
           ,p_in_list_of_recipients     => l_approval_nf_rects_tbl
           ,x_out_list_of_recipients    => l_out_approval_nf_rects_tbl
           ,x_number_of_recipients      => l_number_of_recipients );

        log_message('After calling mgr client extensions');
        log_message('After COUNT:' || l_out_approval_nf_rects_tbl.COUNT);
        log_message('Total number of managers is:' || l_number_of_recipients );

        IF l_out_approval_nf_rects_tbl.COUNT > 0 THEN

        ---------------------------------------------------------
        --Get Recipients and populate pa_wf_ntf_performers table
        --Use WF_TYPE_CODE as MASS_APPROVAL_FYI
        ---------------------------------------------------------
        FOR j IN 1..l_out_approval_nf_rects_tbl.COUNT LOOP
            l_approval_nf_rects_rec := l_out_approval_nf_rects_tbl(j);

            log_message('User Name ' || j || ':' || l_approval_nf_rects_rec.user_name);

            IF l_approval_nf_rects_rec.user_name IS NOT NULL THEN

                log_message('Insert in loop:' || j);

                INSERT INTO pa_wf_ntf_performers(
                        WF_TYPE_CODE
                       ,ITEM_TYPE
                       ,ITEM_KEY
                       ,OBJECT_ID1
                       ,GROUP_ID
                       ,USER_NAME
                       ,USER_TYPE
                       ,ROUTING_ORDER )
                VALUES ('MASS_APPROVAL_FYI'
                      ,'-1'
                      ,'-1'
                      ,l_assignment_id
                      ,p_group_id
                      ,l_approval_nf_rects_rec.user_name
                      ,l_approval_nf_rects_rec.type
                      ,l_approval_nf_rects_rec.routing_order
                      );
            END IF;--end l_approval_nf_rects_rec.user_name

        END LOOP;--end j loop

        END IF;

    END LOOP;--end i loop

    log_message('After inserting manager records');

    --------------------------------------------------------
    --Select distinct recipients for this mass transaction
    --from pa_wf_ntf_performers table and send notifications
    --------------------------------------------------------
    OPEN get_managers;
    FETCH get_managers BULK COLLECT INTO l_recipients_tbl, l_recipients_type_tbl;
    CLOSE get_managers;

    log_message('Number of manangers :' || l_recipients_tbl.COUNT);

    --Delete recipients from pa_wf_ntf_performers table
    --for this mass transaction
    DELETE
    FROM pa_wf_ntf_performers
    WHERE wf_type_code  = 'MASS_APPROVAL_FYI'
    AND group_id        = p_group_id;

    --------------------------------------------------------
    --Start Notification Workflow for all manager recipients
    --------------------------------------------------------
    l_wf_started_by_id  := FND_GLOBAL.user_id;
    l_responsibility_id := FND_GLOBAL.resp_id;
    l_resp_appl_id      := FND_GLOBAL.resp_appl_id;

    FND_GLOBAL.Apps_Initialize ( user_id      => l_wf_started_by_id
                               , resp_id      => l_responsibility_id
                               , resp_appl_id => l_resp_appl_id );

    -- Setting thresold value to run the process in background
    l_save_threshold    := wf_engine.threshold;
    wf_engine.threshold := -1;

    -----------------------------------------------------------------------------
    --Setting Process Creation / Update / Aproval submission  mode for assignments
    -----------------------------------------------------------------------------
    IF p_mode = PA_MASS_ASGMT_TRX.G_MASS_ASGMT THEN

        l_wf_process := 'PA_MASS_APRVL_CRN_FP';

    ELSIF (p_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_ASGMT_BASIC_INFO OR
           p_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_COMPETENCIES     OR
           p_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_FORECAST_ITEMS   OR
           p_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_SCHEDULE )
    THEN

        l_wf_process := 'PA_MASS_APRVL_UPD_FP';

    ELSIF  p_mode = PA_MASS_ASGMT_TRX.G_MASS_SUBMIT_FOR_APPROVAL THEN

        l_wf_process := 'PA_MASS_APRVL_APS_FP';

    END IF;


    For k IN 1..l_recipients_tbl.COUNT LOOP

        -- Create the unique item key to launch WF with
        SELECT pa_prm_wf_item_key_s.nextval
        INTO   l_itemkey
        FROM   dual;

        -- Create the WF process
        wf_engine.CreateProcess
            ( ItemType => l_wf_item_type
            , ItemKey  => l_itemkey
            , process  => l_wf_process );

        ------------------------------------------------------------
        --Set the item attributes required for manager notifications
        ------------------------------------------------------------
        wf_engine.SetItemAttrText
            ( itemtype => l_wf_item_type
            , itemkey  => l_itemkey
            , aname    => 'NTFY_FYI_USER_NAME'
            , avalue   => l_recipients_tbl(k));

        ------------------------------------------------------------------
        --Getting manager person_id
        --The logic below gets the manager person id only for
        --Staffing and Resource managers. For Project managers
        --notified_id will be null and selected roles and selected resources
        --pages should display all resources/roles in the mass transaction
        -------------------------------------------------------------------
        l_notified_id := null;
        BEGIN

            IF l_recipients_type_tbl(k) <> 'PROJECT_MANAGER' THEN
                SELECT employee_id
                INTO   l_notified_id
                FROM   fnd_user
                WHERE  user_name = l_recipients_tbl(k)
                AND    rownum = 1;

                -- bug 2475300 : added following two select stmt to set # of approved/rejected
                -- asmt according to the resource/staffing manager. Resource/staffing mgr should
                -- see the # of asmt which is related to only their resources.
                SELECT count(*)
                INTO   l_num_apr_asgns
                FROM   pa_res_aprvl_roles_v ar
                WHERE  ar.notified_id = l_notified_id
                AND    ar.group_id = p_group_id
                AND    ar.approval_status = 'ASGMT_APPRVL_APPROVED';

                SELECT count(*)
                INTO   l_num_rej_asgns
                FROM   pa_res_aprvl_roles_v ar
                WHERE  ar.notified_id = l_notified_id
                AND    ar.group_id = p_group_id
                AND    ar.approval_status = 'ASGMT_APPRVL_REJECTED';
            ELSE
               l_num_apr_asgns := p_num_apr_asgns;
               l_num_rej_asgns := p_num_rej_asgns;
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                null;
        END;

       log_message('Before Calling set manager attributes');

        set_manager_attributes
            ( itemtype               => l_wf_item_type
             ,itemkey                => l_itemkey
             ,p_group_id             => p_group_id
             ,p_mode                 => p_mode
             ,p_update_info_doc      => p_update_info_doc
             ,p_num_apr_asgns        => p_num_apr_asgns
             ,p_num_rej_asgns        => p_num_rej_asgns
             ,p_project_name         => p_project_name
             ,p_project_number       => p_project_number
             ,p_project_manager      => p_project_manager
             ,p_project_org          => p_project_org
             ,p_project_cus          => p_project_cus
             ,p_conflict_group_id    => p_conflict_group_id
             ,p_notified_id          => l_notified_id
             ,x_return_status        => l_return_status
             ,x_msg_count            => l_msg_count );

        log_message('After Calling set manager attributes');

        --Start the workflow process
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

    END LOOP;--end k loop


    --Setting the original value
    wf_engine.threshold := l_save_threshold;

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
    WHEN OTHERS THEN

         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_ASGMT_WFSTD.process_mgr_fyi_notification'
              ,p_procedure_name => PA_DEBUG.G_Err_Stack );

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;
END process_mgr_fyi_notification;



----------------------------------------------------------------
--This API is called inside the workflow to make the processing
--of approval result a background process
--It doest the processing of approval result by calling API
--process_approval_result
----------------------------------------------------------------
PROCEDURE process_approval_result_wf
    ( itemtype    IN      VARCHAR2
     ,itemkey     IN      VARCHAR2
     ,actid       IN      NUMBER
     ,funcmode    IN      VARCHAR2
     ,resultout   OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
IS
    l_msg_index_out         NUMBER;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_return_status         VARCHAR2(1);
    x_return_status         VARCHAR2(1);
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(2000);

    l_project_id            pa_project_assignments.project_id%TYPE;
    l_mode                  VARCHAR2(30);
    l_assignment_id_tbl     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_approval_status_tbl   SYSTEM.pa_varchar2_30_tbl_type:= SYSTEM.pa_varchar2_30_tbl_type();
    l_group_id              NUMBER;
    l_approver_group_id     NUMBER;
    l_routing_order         NUMBER;
    l_num_assignments       NUMBER;
    l_conflict_group_id     NUMBER;
    l_update_info_doc VARCHAR2(2000);
    l_submitter_user_name fnd_user.user_name%type; /* Commeted for bug 3261755 VARCHAR2(30); */
    l_note_to_approvers   VARCHAR2(2000);
    l_forwarded_from      fnd_user.user_name%type; /* Commeted for bug 3261755 VARCHAR2(30); */
    l_debug_mode VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); -- 5345171

BEGIN
    log_message('Inside mass_process_approval_result_wf');

    -- Initialize the Error Stack
    PA_DEBUG.init_err_stack('PA_ASGMT_WFSTD.mass_process_approval_result_wf');

    --Log Message
    IF l_debug_mode = 'Y' THEN -- 5345171
        PA_DEBUG.write_log
        ( x_module      => 'pa.plsql.PA_ASGMT_WFSTD.mass_process_approval_result_wf.begin'
         ,x_msg         => 'Beginning of mass_assignment_approval'
         ,x_log_level   => 1);
    END IF;

    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Clear the global PL/SQL message table
    FND_MSG_PUB.initialize;

    log_message('Inside mass_process_approval_result_wf 2');

    ---------------------------------------------------
    --Get the values required from the item attributes
    ---------------------------------------------------
    l_project_id := wf_engine.getItemAttrNumber
                        ( itemtype => itemtype
                        , itemkey  => itemkey
                        , aname    => 'PROJECT_ID' );

    l_mode := wf_engine.getItemAttrText
                  ( itemtype => itemtype
                  , itemkey  => itemkey
                  , aname    => 'MODE' );

    l_group_id := wf_engine.getItemAttrNumber
                        ( itemtype => itemtype
                        , itemkey  => itemkey
                        , aname    => 'GROUP_ID' );

    l_approver_group_id := wf_engine.getItemAttrNumber
                               ( itemtype => itemtype
                               , itemkey  => itemkey
                               , aname    => 'APPROVER_GROUP_ID' );

    l_routing_order := wf_engine.getItemAttrNumber
                           ( itemtype => itemtype
                           , itemkey  => itemkey
                           , aname    => 'ROUTING_ORDER' );

    l_num_assignments := wf_engine.getItemAttrNumber
                             ( itemtype => itemtype
                             , itemkey  => itemkey
                             , aname    => 'NUMBER_OF_ASSIGNMENTS' );

    --Get the Update Info document
    l_update_info_doc := wf_engine.getItemAttrDocument
                             ( itemtype => itemtype
                             , itemkey  => itemkey
                             , aname    => 'UPDATED_INFO_DOC' );

    l_submitter_user_name := wf_engine.getItemAttrText
                                  ( itemtype => itemtype
                                  , itemkey  => itemkey
                                  , aname    => 'SUBMITTER_UNAME');

    l_conflict_group_id := wf_engine.getItemAttrNumber
                           ( itemtype => itemtype
                           , itemkey  => itemkey
                           , aname    => 'CONFLICT_GROUP_ID' );

    l_forwarded_from := wf_engine.getItemAttrText
                                  ( itemtype => itemtype
                                  , itemkey  => itemkey
                                  , aname    => 'NTFY_APPRVL_RECIPIENT_NAME');

    l_note_to_approvers := wf_engine.getItemAttrText
                                  ( itemtype => itemtype
                                  , itemkey  => itemkey
                                  , aname    => 'NOTE_TO_APPROVER');

    -----------------------------------------------------------
    --Loop through all assignments and populate the assignment
    --and status tables
    --Also get number of approved and rejected assignments
    -----------------------------------------------------------
    FOR i IN 1..l_num_assignments LOOP
        l_assignment_id_tbl.extend;
        l_assignment_id_tbl(i) := wf_engine.getItemAttrNumber
                                      ( itemtype => itemtype
                                       ,itemkey  => itemkey
                                       ,aname    => 'ASSIGNMENT_'|| i );

        l_approval_status_tbl.extend;
        l_approval_status_tbl(i) := wf_engine.getItemAttrText
                                        ( itemtype => itemtype
                                         ,itemkey  => itemkey
                                         ,aname    => 'STATUS_'|| i );
    END LOOP;

    log_message('Before Calling process approval_result');

    process_approval_result
        ( p_project_id            => l_project_id
         ,p_mode                  => l_mode
         ,p_assignment_id_tbl     => l_assignment_id_tbl
         ,p_approval_status_tbl   => l_approval_status_tbl
         ,p_group_id              => l_group_id
         ,p_approver_group_id     => l_approver_group_id
         ,p_routing_order         => l_routing_order
         ,p_num_of_assignments    => l_num_assignments
         ,p_submitter_user_name   => l_submitter_user_name
         ,p_conflict_group_id     => l_conflict_group_id
         ,p_update_info_doc       => l_update_info_doc
         ,p_forwarded_from        => l_forwarded_from
         ,p_note_to_approvers     => l_note_to_approvers);

    log_message('After Calling process approval_result');

    ------------------------------------------------------------------
    -- IF the number of messages is 1 then fetch the message code from
    -- the stack and return its text
    ------------------------------------------------------------------
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
    WHEN OTHERS THEN

         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_ASGMT_WFSTD.process_approval_result_wf'
              ,p_procedure_name => PA_DEBUG.G_Err_Stack );

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;
END process_approval_result_wf;

-----------------------------------------------------------
--This Procedure reverts the assignment status to
--Working or Requires Re-submission from
--submitted in case of errors
-----------------------------------------------------------
PROCEDURE Revert_assignment_status(
                   p_assignment_id IN  NUMBER
                  ,p_group_id      IN  NUMBER
                  ,x_return_status OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

    CURSOR get_status_and_rec_num IS
    SELECT record_version_number
    FROM   pa_project_assignments
    WHERE  assignment_id = p_assignment_id;

    CURSOR get_assignment_status IS
    SELECT approval_status
    FROM   pa_wf_ntf_performers
    WHERE  group_id   = p_group_id
    AND    object_id1 = p_assignment_id
    AND    rownum     = 1;

    l_record_version_number      NUMBER;
    l_apprvl_status_code         pa_project_statuses.project_status_code%TYPE;
    l_return_status              VARCHAR2(1);

BEGIN

    OPEN get_status_and_rec_num;
    FETCH get_status_and_rec_num INTO l_record_version_number;
    CLOSE get_status_and_rec_num;

    OPEN get_assignment_status;
    FETCH get_assignment_status INTO l_apprvl_status_code ;
    CLOSE get_assignment_status;

    PA_PROJECT_ASSIGNMENTS_PKG.Update_Row (
        p_assignment_id         => p_assignment_id
       ,p_record_version_number => l_record_version_number
       ,p_apprvl_status_code    => l_apprvl_status_code
       ,x_return_status         => l_return_status );

    x_return_status := l_return_status;

     ---------------------------------
    --Set the pending approval flag
    ---------------------------------
    Maintain_wf_pending_flag
        (p_assignment_id => p_assignment_id,
         p_mode          => 'APPROVAL_PROCESS_COMPLETED') ;

    log_message('After Maintain pending flag for assignment id:' || p_assignment_id);

    ---------------------------
    --Set the mass wf flag
    ---------------------------
    UPDATE pa_project_assignments
    SET    mass_wf_in_progress_flag = 'N'
    WHERE  assignment_id = p_assignment_id;

EXCEPTION
     WHEN OTHERS THEN

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;
END Revert_assignment_status;

----------------------------------------------------------
--This procedure does the per assignment approval processing
--tasks
-----------------------------------------------------------
PROCEDURE process_assignment_tasks (
            p_assignment_id       IN NUMBER
           ,p_approval_status     IN pa_project_assignments.apprvl_status_code%TYPE
           ,p_action_code         IN VARCHAR2
           ,p_conflict_group_id   IN NUMBER
           ,p_project_id          IN NUMBER
           ,p_mode                IN VARCHAR2
           ,p_project_name        IN VARCHAR2
           ,p_project_number      IN VARCHAR2
           ,p_project_manager     IN VARCHAR2
           ,p_project_org         IN VARCHAR2
           ,p_project_cus         IN VARCHAR2
           ,p_submitter_user_name IN VARCHAR2
           ,p_group_id            IN NUMBER
           ,p_routing_order       IN NUMBER)

IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_change_id              NUMBER;
    l_aprvl_status_code      pa_project_assignments.apprvl_status_code%TYPE;
    l_resource_id            NUMBER;
    l_submitter_user_id      NUMBER;
    l_record_version_number1 NUMBER;
    l_record_version_number2 NUMBER;
    l_return_status          VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

    CURSOR pending_approvals (c_assignment_id IN NUMBER) IS
    SELECT user_name
    FROM   pa_wf_ntf_performers ntf
    WHERE  ntf.group_id          = p_group_id
    AND    ntf.routing_order     = p_routing_order + 1
    AND    ntf.object_id1        = c_assignment_id;

    l_pending_approvals pending_approvals%ROWTYPE;

    CURSOR get_rec_num ( p_assignment_id IN NUMBER )IS
    SELECT record_version_number
    FROM pa_project_assignments
    WHERE assignment_id = p_assignment_id;

BEGIN

        SAVEPOINT UPDATE_APPROVAL_STATUS;

        OPEN pending_approvals (p_assignment_id);
        FETCH pending_approvals INTO l_pending_approvals;

        IF (pending_approvals%NOTFOUND) OR (p_approval_status = PA_ASSIGNMENT_APPROVAL_PUB.g_reject_action) THEN

            log_message('No pending approvals for assignment:' || p_assignment_id);

            OPEN get_rec_num ( p_assignment_id );
            FETCH get_rec_num INTO l_record_version_number1;
            CLOSE get_rec_num;

            log_message('Record version number:' || l_record_version_number1);
            log_message('Before calling Update approval status');

            PA_ASSIGNMENT_APPROVAL_PVT.Update_Approval_Status
                ( p_assignment_id         => p_assignment_id
                 ,p_action_code           => p_action_code
                 ,p_note_to_approver      => null
                 ,p_record_version_number => l_record_version_number1
                 ,x_apprvl_status_code    => l_aprvl_status_code
                 ,x_change_id             => l_change_id
                 ,x_record_version_number => l_record_version_number2
                 ,x_return_status         => l_return_status
                 ,x_msg_count             => l_msg_count
                 ,x_msg_data              => l_msg_data);

            log_message('After calling Update approval status');
            log_message('Before  Calling resolve conflicts:' || p_conflict_group_id);

            If (p_conflict_group_id IS NOT NULL) THEN
               PA_SCHEDULE_PVT.resolve_conflicts
                        ( p_conflict_group_id   => p_conflict_group_id
                         ,p_assignment_id       => p_assignment_id
                         ,x_return_status       => l_return_status
                         ,x_msg_count           => l_msg_count
                         ,x_msg_data            => l_msg_data);
            END IF;

            log_message('After Calling resolve conflicts');

            --------------------------------
            --Call resource fyi notification
            --------------------------------
            log_message('Before Calling process res fyi');

            process_res_fyi_notification
                ( p_project_id        => p_project_id
                 ,p_mode              => p_mode
                 ,p_assignment_id     => p_assignment_id
                 ,p_project_name      => p_project_name
                 ,p_project_number    => p_project_number
                 ,p_project_manager   => p_project_manager
                 ,p_project_org       => p_project_org
                 ,p_project_cus       => p_project_cus
                 ,p_conflict_group_id => p_conflict_group_id
                 ,x_return_status     => l_return_status
                 ,x_msg_count         => l_msg_count
                 ,x_msg_data          => l_msg_data);

            log_message('After Calling process res fyi');

            IF FND_MSG_PUB.Count_Msg > 0 THEN

               log_message('Error in res_fyi');

               ROLLBACK TO  UPDATE_APPROVAL_STATUS;

               SELECT user_id
               INTO   l_submitter_user_id
               FROM   fnd_user
               WHERE  user_name = p_submitter_user_name;

               SELECT resource_id
               INTO   l_resource_id
               FROM   pa_project_assignments
               WHERE  assignment_id = p_assignment_id;

               --Revert assignment status back to Working or Requires Re-submission
               Revert_assignment_status(
                   p_assignment_id => p_assignment_id
                  ,p_group_id      => p_group_id
                  ,x_return_status => l_return_status);

               PA_MESSAGE_UTILS.save_messages
                   (p_user_id            =>  l_submitter_user_id,
                    p_source_type1       =>  PA_MASS_ASGMT_TRX.G_SOURCE_TYPE1,
                    p_source_type2       =>  'MASS_APPROVAL',
                    p_source_identifier1 =>  'PAWFAAP',
                    p_source_identifier2 =>  p_group_id,
                    p_context1           =>  p_project_id,
                    p_context2           =>  p_assignment_id,
                    p_context3           =>  l_resource_id,
                    p_commit             =>  FND_API.G_TRUE,
                    x_return_status      =>  l_return_status);

               log_message('After Error in res_fyi');

            ELSE
                ----------------------------
                --Commit per assignment
                ----------------------------
                COMMIT;
            END IF; --end l_return_status <> success

        ELSE

            COMMIT; --When pending_approvals not found

        END IF;--end pending_approvals%NOTFOUND
        CLOSE pending_approvals;

EXCEPTION
    WHEN OTHERS THEN

         ROLLBACK TO UPDATE_APPROVAL_STATUS;

         RAISE;
END process_assignment_tasks;

------------------------------------------------------------------
--This API is called by the workflow API process_approval_result_wf
--This API does the processing of approval result including sending
--notifications to managers and resource
-------------------------------------------------------------------
PROCEDURE process_approval_result
    ( p_project_id                  IN NUMBER
     ,p_mode                        IN    VARCHAR2
     ,p_assignment_id_tbl           IN    SYSTEM.pa_num_tbl_type
     ,p_approval_status_tbl         IN    SYSTEM.pa_varchar2_30_tbl_type
     ,p_group_id                    IN    NUMBER
     ,p_approver_group_id           IN    NUMBER
     ,p_routing_order               IN    NUMBER
     ,p_num_of_assignments          IN    NUMBER
     ,p_submitter_user_name         IN    VARCHAR2
     ,p_conflict_group_id           IN    NUMBER
     ,p_update_info_doc             IN    VARCHAR2
     ,p_forwarded_from              IN    VARCHAR2
     ,p_note_to_approvers           IN    VARCHAR2)
IS
    l_approval_status       pa_project_assignments.apprvl_status_code%TYPE;
    l_aprvl_status_code     pa_project_assignments.apprvl_status_code%TYPE;
    l_change_id             NUMBER;
    l_action_code           VARCHAR2(30);
    l_approver_group_id     NUMBER;
    l_assignment_id_tbl     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_msg_index_out         NUMBER;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_return_status         VARCHAR2(1);
    x_return_status         VARCHAR2(1);
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(2000);
    l_error_message_code    VARCHAR(30);
    x_error_message_code  VARCHAR2(30);

/*  Commented and altered as below for bug 5595003
    CURSOR distinct_approvers IS
    SELECT distinct user_name
    FROM   pa_wf_ntf_performers ntf,
           pa_project_assignments asgn
    WHERE  ntf.group_id            = p_group_id
    AND    ntf.object_id1          = asgn.assignment_id
    AND    asgn.apprvl_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_submitted
    AND    ntf.routing_order       = p_routing_order + 1; */

    CURSOR distinct_approvers IS
    SELECT distinct ntf.user_name
    FROM   pa_wf_ntf_performers ntf,
           pa_project_assignments asgn,
	   pa_wf_ntf_performers ntf1
    WHERE  ntf.group_id            = p_group_id
    AND    ntf.object_id1          = asgn.assignment_id
    AND    asgn.apprvl_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_submitted
    AND    ntf.routing_order       = p_routing_order + 1
    AND    ntf1.group_id            = p_group_id
    AND    ntf1.object_id1          = asgn.assignment_id
    AND    ntf1.routing_order       = p_routing_order
    AND    ntf1.approver_group_id   = p_approver_group_id;

    CURSOR pending_txn_approvals IS
    SELECT 'Y'
    FROM   pa_wf_ntf_performers ntf,
           pa_project_assignments asgn
    WHERE  ntf.group_id            = p_group_id
    AND    ntf.object_id1          = asgn.assignment_id
    AND    asgn.apprvl_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_submitted;

    l_pending_txn_approvals pending_txn_approvals%ROWTYPE;

    l_num_apr_asgns NUMBER;
    l_num_rej_asgns NUMBER;

    l_customer_id         NUMBER;
    l_customer_name       VARCHAR2(2000);
    l_project_manager_person_id   NUMBER ;
    l_project_manager_name        per_all_people_f.full_name%TYPE;--VARCHAR2(200);  Commented For 3267790
    l_project_party_id            NUMBER ;
    l_project_role_id             NUMBER ;
    l_project_role_name           VARCHAR2(80);

    CURSOR l_projects_csr(l_project_id IN NUMBER) IS
    SELECT pap.project_id project_id,
           pap.name name,
           pap.segment1 segment1,
           pap.carrying_out_organization_id carrying_out_organization_id,
           pap.location_id,
           hr.name organization_name,
           NVL(pt.administrative_flag,'N') admin_flag
    FROM   pa_projects_all pap,
           hr_all_organization_units hr,
           pa_project_types_all pt
    WHERE  pap.project_id = l_project_id
    AND    pap.carrying_out_organization_id = hr.organization_id
    AND    pap.org_id = pt.org_id    -- Added for Bug 5389093
    AND    pt.project_type = pap.project_type;

    l_projects_rec l_projects_csr%ROWTYPE;
    l_update_info_doc VARCHAR2(2000);

    l_submitter_user_id NUMBER;

    CURSOR sub_not_required_csr IS
    SELECT 'Y'
    FROM    PA_REPORTING_EXCEPTIONS
    WHERE  user_id            = l_submitter_user_id
    AND    context            = PA_MASS_ASGMT_TRX.G_SOURCE_TYPE1
    AND    sub_context        =  'MASS_APPROVAL'
    AND    source_identifier1 = 'PAWFAAP'
    AND    source_identifier2 =  p_group_id;

    l_sub_not_required_rec sub_not_required_csr%ROWTYPE;


BEGIN

    log_message('Inside process approval result');
    -----------------------------------------------------------
    --Get the Project information for FYI notifications
    -------------------------------------------------------
    OPEN l_projects_csr( p_project_id);
    FETCH l_projects_csr INTO l_projects_rec;
    IF l_projects_csr%NOTFOUND THEN
        pa_utils.add_message (p_app_short_name  => 'PA',
                              p_msg_name        => 'PA_INVALID_PROJECT_ID');
    END IF;
    CLOSE l_projects_csr;

    Check_And_Get_Proj_Customer
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
            x_return_status := l_return_status;
            x_error_message_code := l_error_message_code;
            pa_utils.add_message (p_app_short_name  => 'PA',
                                  p_msg_name        => l_error_message_code);
        END IF;
    END IF;

    ----------------------------------------
    --Start processing the approval result
    ----------------------------------------

    FOR i IN 1..p_assignment_id_tbl.COUNT LOOP

        l_approval_status  := p_approval_status_tbl(i);

        IF l_approval_status = PA_ASSIGNMENT_APPROVAL_PUB.g_approve_action THEN

            l_action_code := PA_ASSIGNMENT_APPROVAL_PUB.g_approve_action;
            --l_num_apr_asgns := l_num_apr_asgns + 1;

        ELSIF l_approval_status = PA_ASSIGNMENT_APPROVAL_PUB.g_reject_action THEN

            l_action_code := PA_ASSIGNMENT_APPROVAL_PUB.g_reject_action;
            --l_num_rej_asgns := l_num_rej_asgns + 1;

        END IF;

        ----------------------------------------------------------------------
        --The API below does the per assignment approval result processing tasks
        ----------------------------------------------------------------------
        log_message('Check if there are any pending approvals for assignment:' ||p_assignment_id_tbl(i) );
        log_message('Routing order:' || p_routing_order);

        process_assignment_tasks (
            p_assignment_id       => p_assignment_id_tbl(i)
           ,p_approval_status     => l_approval_status
           ,p_action_code         => l_action_code
           ,p_conflict_group_id   => p_conflict_group_id
           ,p_project_id          => p_project_id
           ,p_mode                => p_mode
           ,p_project_name        => l_projects_rec.name
           ,p_project_number      => l_projects_rec.segment1
           ,p_project_manager     => l_project_manager_name
           ,p_project_org         => l_projects_rec.organization_name
           ,p_project_cus         => l_customer_name
           ,p_submitter_user_name => p_submitter_user_name
           ,p_group_id            => p_group_id
           ,p_routing_order       => p_routing_order
        );

    END LOOP; --end i loop

    ---------------------------------------------------
    --For each distinct approvers in next routing order
    --start approval required notification
    ---------------------------------------------------
    FOR rec IN distinct_approvers LOOP

        SELECT PA_WF_NTF_PERFORMERS_S.nextval
        INTO   l_approver_group_id
        FROM   dual;

        /* Commented and altered as below for bug 5595003
	UPDATE pa_wf_ntf_performers
        SET    approver_group_id = l_approver_group_id
        WHERE  group_id          = p_group_id
        AND    user_name         = rec.user_name
        AND    routing_order     = p_routing_order + 1;  */

	FORALL  k in p_assignment_id_tbl.first..p_assignment_id_tbl.last
		UPDATE pa_wf_ntf_performers
		SET    approver_group_id = l_approver_group_id
		WHERE  group_id          = p_group_id
		AND    user_name         = rec.user_name
		AND    routing_order     = p_routing_order + 1
		AND    object_id1        = p_assignment_id_tbl(k)
		AND    p_approval_status_tbl(k) = PA_ASSIGNMENT_APPROVAL_PUB.g_approve_action;

        log_message('New approver group id:' || l_approver_group_id);

        ----------------------------------------------------------
        --Call API to start one workflow for each grouped approver
        ----------------------------------------------------------
        log_message('Before Calling start_mass_approval_flow for approver :' || rec.user_name);

        start_mass_approval_flow
                   (p_project_id           => p_project_id
                   ,p_mode                 => p_mode
                   ,p_note_to_approvers    => p_note_to_approvers
                   ,p_forwarded_from       => p_forwarded_from
                   ,p_performer_user_name  => rec.user_name
                   ,p_routing_order        => p_routing_order + 1
                   ,p_group_id             => p_group_id
                   ,p_approver_group_id    => l_approver_group_id
                   ,p_project_name         => l_projects_rec.name
                   ,p_project_number       => l_projects_rec.segment1
                   ,p_project_manager      => l_project_manager_name
                   ,p_project_org          => l_projects_rec.organization_name
                   ,p_project_cus          => l_customer_name
                   ,p_conflict_group_id    => p_conflict_group_id
                   ,p_submitter_user_name  => p_submitter_user_name
                   ,x_return_status        => l_return_status
                   ,x_msg_count            => l_msg_count
                   ,x_msg_data             => l_msg_data);

        log_message('After Calling start_mass_approval_flow for approver :' || rec.user_name);

    END LOOP;--end distinct approvers loop

    ---------------------------------------------------------------------
    -- Call FYI Notifications for Managers if all status have been changed
    -- for this mass transaction
    -- And call schedule APIs to resolve overcommitment conflict.
    ---------------------------------------------------------------------
    log_message('Checking pending txn approvals');

    OPEN pending_txn_approvals;
    FETCH pending_txn_approvals INTO l_pending_txn_approvals;

    IF pending_txn_approvals%NOTFOUND THEN

        BEGIN

            --Get all assignments in this mass transaction
            SELECT ntf.object_id1
            BULK COLLECT INTO l_assignment_id_tbl
            FROM   pa_wf_ntf_performers ntf
            WHERE  ntf.group_id            = p_group_id
            AND    ntf.routing_order       = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                null;
        END;

        --Reset the number of approved and rejected assignments
        l_num_apr_asgns := 0;
        l_num_rej_asgns := 0;

        FOR i IN 1..l_assignment_id_tbl.COUNT LOOP

            l_approval_status := null;

            BEGIN
                SELECT apprvl_status_code
                INTO   l_approval_status
                FROM   pa_project_assignments
                WHERE  assignment_id = l_assignment_id_tbl(i);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                null;
            END;

           IF l_approval_status = PA_ASSIGNMENT_APPROVAL_PUB.g_approved THEN

               l_num_apr_asgns := l_num_apr_asgns + 1;

           ELSIF l_approval_status = PA_ASSIGNMENT_APPROVAL_PUB.g_rejected THEN

               l_num_rej_asgns := l_num_rej_asgns + 1;

           END IF;
        END LOOP;

        log_message('Calling mgr fyi notification');

        process_mgr_fyi_notification
            ( p_assignment_id_tbl   => l_assignment_id_tbl
             ,p_project_id          => p_project_id
             ,p_mode                => p_mode
             ,p_group_id            => p_group_id
             ,p_update_info_doc     => l_update_info_doc
             ,p_num_apr_asgns       => l_num_apr_asgns
             ,p_num_rej_asgns       => l_num_rej_asgns
             ,p_project_name        => l_projects_rec.name
             ,p_project_number      => l_projects_rec.segment1
             ,p_project_manager     => l_project_manager_name
             ,p_project_org         => l_projects_rec.organization_name
             ,p_project_cus         => l_customer_name
             ,p_submitter_user_name => p_submitter_user_name
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
                         ,p_fnd_user_name       => p_submitter_user_name
                         ,x_return_status       => l_return_status
                         ,x_msg_count           => l_msg_count
                         ,x_msg_data            => l_msg_data);

        BEGIN
               SELECT user_id
               INTO   l_submitter_user_id
               FROM   fnd_user
               WHERE  user_name = p_submitter_user_name;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            null;
        END;
        ------------------------------------------------
        --This API processes the submitter notifcations
        ------------------------------------------------

        OPEN sub_not_required_csr;
        FETCH sub_not_required_csr INTO l_sub_not_required_rec;

        IF sub_not_required_csr%FOUND THEN

        log_message('Calling submitter notification');

        process_submitter_notification
                (p_project_id          => p_project_id
                ,p_mode                => p_mode
                ,p_group_id            => p_group_id
                ,p_update_info_doc     => l_update_info_doc
                ,p_num_apr_asgns       => l_num_apr_asgns
                ,p_num_rej_asgns       => l_num_rej_asgns
                ,p_project_name        => l_projects_rec.name
                ,p_project_number      => l_projects_rec.segment1
                ,p_project_manager     => l_project_manager_name
                ,p_project_org         => l_projects_rec.organization_name
                ,p_project_cus         => l_customer_name
                ,p_submitter_user_name => p_submitter_user_name
                ,x_return_status       => l_return_status
                ,x_msg_count           => l_msg_count
                ,x_msg_data            => l_msg_data);

        END IF;
        CLOSE sub_not_required_csr;

    END IF; --end call to fyi notifications
    CLOSE pending_txn_approvals;

    log_message('After call to mgr fyi');

EXCEPTION
    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;
END process_approval_result;

-----------------------------------------------------------
--This API processes the notification sent to the submitter
--if there are errors in the end of the mass transaction
--approval process
--This API raises a NO_ASSIGNMENT_ERRORS EXCEPTION
--when there are no errors and in that case notification
--is not sent to the submitter
-----------------------------------------------------------
PROCEDURE process_submitter_notification
    ( p_project_id           IN   NUMBER    := FND_API.G_MISS_NUM
     ,p_mode                 IN  VARCHAR2
     ,p_group_id             IN   NUMBER    := FND_API.G_MISS_NUM
     ,p_update_info_doc      IN   VARCHAR2  := FND_API.G_MISS_CHAR
     ,p_num_apr_asgns        IN   NUMBER
     ,p_num_rej_asgns        IN   NUMBER
     ,p_project_name         IN   VARCHAR2
     ,p_project_number       IN   VARCHAR2
     ,p_project_manager      IN   VARCHAR2
     ,p_project_org          IN   VARCHAR2
     ,p_project_cus          IN   VARCHAR2
     ,p_submitter_user_name  IN   VARCHAR2
     ,p_assignment_id        IN   NUMBER := FND_API.G_MISS_NUM
     ,x_return_status        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count            OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data             OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

    l_itemkey             VARCHAR2(30);
    l_responsibility_id   NUMBER;
    l_resp_appl_id        NUMBER;
    l_wf_started_date     DATE;
    l_wf_started_by_id    NUMBER;
    l_return_status       VARCHAR2(1);
    l_error_message_code  VARCHAR2(30);
    x_error_message_code  VARCHAR2(30);
    l_save_threshold      NUMBER;
    l_msg_count           NUMBER ;
    l_msg_index_out       NUMBER ;
    l_msg_data            VARCHAR2(2000);
    l_wf_item_type        VARCHAR2(2000):= 'PARMAAP'; --Assignment Approval Item type
    l_wf_process          VARCHAR2(2000);
    l_err_code            NUMBER := 0;
    l_err_stage           VARCHAR2(2000);
    l_err_stack           VARCHAR2(2000);
    l_assignment_id       NUMBER;
    l_error_asgns_count   NUMBER := 0;
    l_view_errors_url     VARCHAR2(2000);

    CURSOR l_assignments_csr (l_assignment_id IN NUMBER ) IS
    SELECT
       ppa.project_id,
       ppa.assignment_name,
       ppa.assignment_effort,
       ppa.additional_information,
       ppa.description,
       ppa.start_date,
       ppa.end_date,
       ppa.revenue_bill_rate,
       ppa.revenue_currency_code,
       ppa.bill_rate_override,
       ppa.bill_rate_curr_override,
       ppa.markup_percent_override,
       ppa.fcst_tp_amount_type_name,
       ppa.tp_rate_override,
       ppa.tp_currency_override,
       ppa.tp_calc_base_code_override,
       ppa.tp_percent_applied_override,
       ppa.work_type_name,
       hr.name
    FROM pa_project_assignments_v ppa,
         pa_resources_denorm res,
         hr_all_organization_units hr
    WHERE assignment_id        = l_assignment_id
    AND   res.resource_id      = ppa.resource_id
    AND   ppa.start_date BETWEEN res.resource_effective_start_date
                             AND res.resource_effective_end_date
    AND   hr.organization_id   = res.resource_organization_id;

    l_assignments_rec l_assignments_csr%ROWTYPE;

CURSOR csr_get_override_basis_name (p_override_basis_code IN VARCHAR2) IS
SELECT plks.meaning
FROM   pa_lookups plks
WHERE  plks.lookup_type = 'CC_MARKUP_BASE_CODE'
AND    plks.lookup_code = p_override_basis_code;

    CURSOR count_error_asgns IS
    SELECT count( distinct ( attribute2))
    FROM   PA_REPORTING_EXCEPTIONS
    WHERE  context            = PA_MASS_ASGMT_TRX.G_SOURCE_TYPE1
      AND  sub_context        = 'MASS_APPROVAL'
      AND  source_identifier1 = 'PAWFAAP'
      AND  source_identifier2 = p_group_id;

      NO_ASSIGNMENT_ERRORS EXCEPTION;

l_override_basis_name VARCHAR2(80) := NULL;
l_debug_mode VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); -- 5345171


BEGIN

    -- Initialize the Error Stack
    PA_DEBUG.init_err_stack('PA_ASGMT_WFSTD.process_submitter_notification');

    --Log Message
    IF l_debug_mode = 'Y' THEN -- 5345171
        PA_DEBUG.write_log
        ( x_module      => 'pa.plsql.PA_ASGMT_WFSTD.process_submitter_notification.begin'
         ,x_msg         => 'Beginning of mass fyi workflow api'
         ,x_log_level   => 1);
    END IF;

    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Clear the global PL/SQL message table
    FND_MSG_PUB.initialize;
    x_msg_count := 0;

    log_message('Inside submitter notification');

    --Setting local variables
    OPEN count_error_asgns;
    FETCH count_error_asgns INTO l_error_asgns_count;
    CLOSE count_error_asgns;

    log_message('Error messages:' || l_error_asgns_count);

    -----------------------------------------------------------
    --If there are no errors this notiifcation must not be sent
    -----------------------------------------------------------
    IF l_error_asgns_count = 0 THEN
        RAISE NO_ASSIGNMENT_ERRORS;
    END IF;
    --------------------------------------
    --Start Submitter Notification workflow
    --------------------------------------
    l_wf_started_by_id  := FND_GLOBAL.user_id;
    l_responsibility_id := FND_GLOBAL.resp_id;
    l_resp_appl_id      := FND_GLOBAL.resp_appl_id;

    FND_GLOBAL.Apps_Initialize ( user_id      => l_wf_started_by_id
                               , resp_id      => l_responsibility_id
                               , resp_appl_id => l_resp_appl_id );

    -- Setting thresold value to run the process in background
    l_save_threshold    := wf_engine.threshold;
    wf_engine.threshold := -1;

    ----------------------------------------------------------------
    --Getting all local variables required for workflow attributes
    ---------------------------------------------------------------

    -- Create the unique item key to launch WF with
    SELECT pa_prm_wf_item_key_s.nextval
    INTO   l_itemkey
    FROM   dual;

    log_message('The value of p_mode is:' || p_mode );
     log_message('The value of item_key is :' || l_itemkey );
    -----------------------------------------------------------------------------
    --Setting Process Creation / Update / Aproval submission  mode
    -----------------------------------------------------------------------------
    IF p_mode = PA_MASS_ASGMT_TRX.G_MASS_ASGMT THEN

        l_wf_process := 'PA_MASS_APRVL_SUB_CRN';

    ELSIF (p_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_ASGMT_BASIC_INFO OR
           p_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_COMPETENCIES     OR
           p_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_FORECAST_ITEMS   OR
           p_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_SCHEDULE )
    THEN

        l_wf_process := 'PA_MASS_APRVL_SUB_UPD';

    ELSIF  p_mode = PA_MASS_ASGMT_TRX.G_MASS_SUBMIT_FOR_APPROVAL THEN

        l_wf_process := 'PA_MASS_APRVL_SUB_APS';

    END IF;

     -- Create the WF process
    wf_engine.CreateProcess
        ( ItemType => l_wf_item_type
        , ItemKey  => l_itemkey
        , process  => l_wf_process );

    log_message('After creating process');

    ------------------------------------------------------------
    --Set the item attributes required for submitter notification
    --based on the mode
    ------------------------------------------------------------
    IF p_mode = PA_MASS_ASGMT_TRX.G_MASS_ASGMT THEN

            BEGIN
                SELECT object_id1
                INTO   l_assignment_id
                FROM   pa_wf_ntf_performers
                WHERE  group_id = p_group_id
                AND    rownum   = 1;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_assignment_id := p_assignment_id;
                WHEN OTHERS THEN
                   null;
            END;

            OPEN l_assignments_csr (l_assignment_id);
            FETCH l_assignments_csr INTO l_assignments_rec;

            IF l_assignments_csr%NOTFOUND THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
                   pa_utils.add_message (p_app_short_name  => 'PA',
                                         p_msg_name        => 'PA_INVALID_ASMGT_ID');
            END IF;

            CLOSE l_assignments_csr;

            wf_engine.SetItemAttrText
                 ( itemtype => l_wf_item_type
                 , itemkey  => l_itemkey
                 , aname    => 'ASSIGNMENT_NAME'
                 , avalue   => l_assignments_rec.assignment_name );

            wf_engine.SetItemAttrText
                ( itemtype => l_wf_item_type
                , itemkey  => l_itemkey
                , aname    => 'RESOURCE_ORGANIZATION'
                , avalue   => l_assignments_rec.name );

            wf_engine.SetItemAttrNumber
                ( itemtype => l_wf_item_type
                , itemkey  => l_itemkey
                , aname    => 'ASSIGNMENT_DURATION'
                , avalue   => (trunc(l_assignments_rec.end_date) -
                               trunc(l_assignments_rec.start_date)+1) );

            wf_engine.SetItemAttrNumber
                ( itemtype => l_wf_item_type
                , itemkey  => l_itemkey
                , aname    => 'ASSIGNMENT_EFFORT'
                , avalue   => l_assignments_rec.assignment_effort );

            wf_engine.SetItemAttrText
                ( itemtype => l_wf_item_type
                , itemkey  => l_itemkey
                , aname    => 'DESCRIPTION'
                , avalue   => l_assignments_rec.description );

            wf_engine.SetItemAttrText
                ( itemtype => l_wf_item_type
                , itemkey  => l_itemkey
                , aname    => 'ADDITIONAL_INFORMATION'
                , avalue   => l_assignments_rec.additional_information );

           -- Start Additions by RM for bug 2274426
           wf_engine.SetItemAttrNumber
                               ( itemtype => l_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'REVENUE_BILL_RATE'
                               , avalue => l_assignments_rec.revenue_bill_rate
                               );
           wf_engine.SetItemAttrText
                            ( itemtype => l_wf_item_type
                            , itemkey => l_itemkey
                            , aname => 'REVENUE_BILL_RATE_CURR'
                            , avalue => l_assignments_rec.revenue_currency_code
                            );
           wf_engine.SetItemAttrNumber
                               ( itemtype => l_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'BILL_RATE_OVERRIDE'
                               , avalue => l_assignments_rec.bill_rate_override
                               );
           wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'BILL_RATE_OVERRIDE_CURR'
                          , avalue => l_assignments_rec.bill_rate_curr_override
                          );
           IF l_assignments_rec.markup_percent_override IS NOT NULL THEN
              wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'MARKUP_PCT_OVERRIDE'
                          , avalue => to_char(l_assignments_rec.markup_percent_override)||'%'
                          );
           ELSE
               wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'MARKUP_PCT_OVERRIDE'
                          , avalue => to_char(l_assignments_rec.markup_percent_override)
                          );
           END IF;
           wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'TP_AMT_TYPE_NAME'
                          , avalue => l_assignments_rec.fcst_tp_amount_type_name
                          );
           wf_engine.SetItemAttrNumber
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'TP_RATE_OVERRIDE'
                          , avalue => l_assignments_rec.tp_rate_override
                          );
           wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'TP_RATE_OVERRIDE_CURR'
                          , avalue => l_assignments_rec.tp_currency_override
                          );
           IF l_assignments_rec.tp_calc_base_code_override IS NOT NULL THEN
              open csr_get_override_basis_name(l_assignments_rec.tp_calc_base_code_override);
              fetch csr_get_override_basis_name into l_override_basis_name;
              close csr_get_override_basis_name;
           END IF;
           wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'OVERRIDE_BASIS_NAME'
                          , avalue => l_override_basis_name
                          );
           IF l_assignments_rec.tp_percent_applied_override IS NOT NULL THEN
              IF l_override_basis_name IS NOT NULL THEN
                 wf_engine.SetItemAttrText
                     ( itemtype => l_wf_item_type
                     , itemkey => l_itemkey
                     , aname => 'TP_PCT_APPLIED_OVERRIDE'
                     , avalue => ', '||to_char(l_assignments_rec.tp_percent_applied_override)||'%'
                     );
              ELSE
                 wf_engine.SetItemAttrText
                     ( itemtype => l_wf_item_type
                     , itemkey => l_itemkey
                     , aname => 'TP_PCT_APPLIED_OVERRIDE'
                     , avalue => to_char(l_assignments_rec.tp_percent_applied_override)||'%'
                     );
              END IF;
           ELSE
              wf_engine.SetItemAttrText
                     ( itemtype => l_wf_item_type
                     , itemkey => l_itemkey
                     , aname => 'TP_PCT_APPLIED_OVERRIDE'
                     , avalue => to_char(l_assignments_rec.tp_percent_applied_override)
                     );
           END IF;
           wf_engine.SetItemAttrText
                          ( itemtype => l_wf_item_type
                          , itemkey => l_itemkey
                          , aname => 'WORK_TYPE_NAME'
                          , avalue => l_assignments_rec.work_type_name
                          );
           -- End of Additions by RM

            --Setting Successful assignments count
            wf_engine.SetItemAttrNumber
                ( itemtype => l_wf_item_type
                , itemkey  => l_itemkey
                , aname    => 'APPROVED_ASSIGNMENTS'
                , avalue   => p_num_apr_asgns + p_num_rej_asgns);

        ELSIF (p_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_ASGMT_BASIC_INFO OR
               p_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_COMPETENCIES     OR
               p_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_FORECAST_ITEMS   OR
               p_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_SCHEDULE )

        THEN
            wf_engine.SetItemAttrDocument
                ( itemtype => l_wf_item_type
                , itemkey  => l_itemkey
                , aname    => 'UPDATED_INFO_DOC'
                , documentid  => p_update_info_doc );

            --Setting Successful assignments count
            wf_engine.SetItemAttrNumber
                ( itemtype => l_wf_item_type
                , itemkey  => l_itemkey
                , aname    => 'APPROVED_ASSIGNMENTS'
                , avalue   => p_num_apr_asgns + p_num_rej_asgns);

        END IF;

        ---------------------------------------------------------------------
        --Setting Common Assignment attributes for CRN / UPD / APS
        --------------------------------------------------------------------

        log_message('Setting common attributes');

        --Setting total assignments count
        wf_engine.SetItemAttrNumber
            ( itemtype => l_wf_item_type
            , itemkey  => l_itemkey
            , aname    => 'NUMBER_OF_ASSIGNMENTS'
            , avalue   => p_num_apr_asgns + p_num_rej_asgns + l_error_asgns_count);

        --Setting failed assignments count
         wf_engine.SetItemAttrNumber
            ( itemtype => l_wf_item_type
            , itemkey  => l_itemkey
            , aname    => 'REJECTED_ASSIGNMENTS'
            , avalue   =>  l_error_asgns_count);

        --Setting Project attributes
        wf_engine.SetItemAttrText
            ( itemtype => l_wf_item_type
            , itemkey  => l_itemkey
            , aname    => 'PROJECT_NAME'
            , avalue   => p_project_name );

        wf_engine.SetItemAttrText
            ( itemtype => l_wf_item_type
            , itemkey  => l_itemkey
            , aname    => 'PROJECT_NUMBER'
            , avalue   => p_project_number );

        wf_engine.SetItemAttrText
            ( itemtype => l_wf_item_type
            , itemkey  => l_itemkey
            , aname    => 'PROJECT_MANAGER_NAME'
            , avalue   => p_project_manager );

        wf_engine.SetItemAttrText
            ( itemtype => l_wf_item_type
            , itemkey  => l_itemkey
            , aname    => 'PROJECT_ORGANIZATION'
            , avalue   => p_project_org );

        wf_engine.SetItemAttrText
            ( itemtype => l_wf_item_type
            , itemkey  => l_itemkey
            , aname    => 'PROJECT_CUSTOMER'
            , avalue   => p_project_cus );

     wf_engine.SetItemAttrText
        ( itemtype => l_wf_item_type
        , itemkey  => l_itemkey
        , aname    => 'SUBMITTER_UNAME'
        , avalue   => p_submitter_user_name);

     l_view_errors_url := 'JSP:/OA_HTML/OA.jsp?akRegionCode=PA_ERROR_LAYOUT&akRegionApplicationId=275&paProjectId='
     || p_project_id ||'&paSrcType1=MASS_ASSIGNMENT_TRANSACTION&paSrcType2=MASS_APPROVAL&paSrcId1=PAWFAAP&paSrcId2='
     || p_group_id || '&addBreadCrumb=RP' ;

      wf_engine.SetItemAttrText
               ( itemtype => l_wf_item_type
               , itemkey  => l_itemkey
               , aname    => 'VIEW_ERRORS_URL'
               , avalue   => l_view_errors_url );

     log_message('Staring process for :' || l_wf_item_type || ':' || l_itemkey);

    --Start the workflow process
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

   log_message('Out of  submitter notification');


    --Setting the original value
    wf_engine.threshold := l_save_threshold;

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
    WHEN NO_ASSIGNMENT_ERRORS THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
    WHEN OTHERS THEN

         --Setting the original value
         wf_engine.threshold := l_save_threshold;

         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_ASGMT_WFSTD.process_submitter_notification'
              ,p_procedure_name => PA_DEBUG.G_Err_Stack );

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;
END process_submitter_notification;

---------------------------------------------------------
--This API is called from Assignment Approval workflow
--This determines if approval is for a single
--transaction or a mass transaction
---------------------------------------------------------
PROCEDURE Check_Approval_Type
              ( itemtype  IN VARCHAR2
               ,itemkey   IN VARCHAR2
               ,actid     IN NUMBER
               ,funcmode  IN VARCHAR2
               ,resultout OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

l_approval_type              VARCHAR2(10);

BEGIN

    pa_debug.init_err_stack ('pa_asgmt_wfstd.Check_approval_type');

    -- Return if WF Not Running
    IF (funcmode <> wf_engine.eng_run) THEN
        resultout := wf_engine.eng_null;
        RETURN;
    END IF;

    l_approval_type := wf_engine.GetItemAttrText
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'APPROVAL_TYPE');

    IF l_approval_type = PA_ASGMT_WFSTD.G_MASS_APPROVAL THEN

        resultout := wf_engine.eng_completed||':'||'M';

    ELSIF l_approval_type = PA_ASGMT_WFSTD.G_SINGLE_APPROVAL THEN

        resultout := wf_engine.eng_completed||':'||'S';

    END IF;

    pa_debug.reset_err_stack;

EXCEPTION
   WHEN OTHERS THEN
    WF_CORE.CONTEXT
        ('PA_ASGMT_WFSTD',
         'Check_approval_type',
          itemtype,
          itemkey,
          to_char(actid),
          funcmode);
    resultout := wf_engine.eng_completed||':'||'S';
    RAISE;

END Check_Approval_Type ;

-------------------------------------------------------------
--This is a post notification function being called when user
--either responds to notification by closing the notification
--or when notification times out
--This is called from approval required mass notification
-------------------------------------------------------------
PROCEDURE Check_Notification_Completed
              ( itemtype  IN VARCHAR2
               ,itemkey   IN VARCHAR2
               ,actid     IN NUMBER
               ,funcmode  IN VARCHAR2
               ,resultout OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

    l_project_id            pa_project_assignments.project_id%TYPE;
    l_mode                  VARCHAR2(30);
    l_assignment_id_tbl     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    l_approval_status_tbl   SYSTEM.pa_varchar2_30_tbl_type:= SYSTEM.pa_varchar2_30_tbl_type();
    l_group_id              NUMBER;
    l_approver_group_id     NUMBER;
    l_routing_order         NUMBER;
    l_num_assignments       NUMBER;
    l_conflict_group_id     NUMBER;
    l_update_info_doc VARCHAR2(2000);
    l_submitter_user_name fnd_user.user_name%type; ----- VARCHAR2(30); Commented for bug 3267790
    l_note_to_approvers   VARCHAR2(2000);
    l_forwarded_from      fnd_user.user_name%type;--VARCHAR2(30); 5345171
    l_ntfy_apprvl_recip_name fnd_user.user_name%TYPE; --skkoppul commented for bug 6744129  VARCHAR2(30); -- added for bug 5488496

    CURSOR pending_txn_approvals IS
    SELECT 'Y'
    FROM   pa_wf_ntf_performers ntf,
           pa_project_assignments asgn
    WHERE  ntf.group_id          = l_group_id
    AND    ntf.approver_group_id = l_approver_group_id	--uncommented this line for Bug#5662785
    AND    ntf.routing_order     = l_routing_order
    AND    ntf.user_name         = l_ntfy_apprvl_recip_name  -- added for bug 5488496
    AND    ntf.object_id1        = asgn.assignment_id
    AND    ntf.object_id2        <> 100
    AND   ( asgn.apprvl_status_code <> PA_ASSIGNMENT_APPROVAL_PUB.g_rejected OR
            asgn.apprvl_status_code <> PA_ASSIGNMENT_APPROVAL_PUB.g_approved );

    l_pending_txn_approvals pending_txn_approvals%ROWTYPE;

BEGIN

    l_group_id := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'GROUP_ID');

    l_approver_group_id := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'APPROVER_GROUP_ID');

    l_routing_order := wf_engine.GetItemAttrNumber
                   (itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'ROUTING_ORDER');

-- added for bug 5488496
    l_ntfy_apprvl_recip_name := wf_engine.getItemAttrText
 	                     (itemtype => itemtype,
 	                     itemkey  => itemkey,
 	                     aname    => 'NTFY_APPRVL_RECIPIENT_NAME');

    IF funcmode = 'RESPOND' THEN

        ------------------------------------------------
        --Check if approver has handled the notification
        --Approver should have either approved/rejected
        --the assignments
        --In this case we check if assignment status is
        --approved/rejected
        -----------------------------------------------
        OPEN pending_txn_approvals;
        FETCH pending_txn_approvals INTO l_pending_txn_approvals;

        IF pending_txn_approvals%FOUND THEN

		--	resultout := 'ERROR:PA_NO_ACTION_ON_NOTIFCATIONS';  commented for Bug#5650363
		--	Added for the below line for Bug#5650363
		resultout := 'ERROR:' || substrb(fnd_message.get_string('PA','PA_NO_ACTION_ON_NOTIFCATIONS'),1,114);

		CLOSE pending_txn_approvals;		 -- Added Close statement for BUG#6328067
		ELSE
		CLOSE pending_txn_approvals;         -- Added Close statement for BUG#6328067
        END IF;

    END IF;--end respond

    ---------------------------------------------------------------
    --In the case of timeout all the assignments in the notifcation
    --have to be rejected. Get all relevant attributes from workflow
    --and call process_approval_result API
    ----------------------------------------------------------------
    IF funcmode = 'TIMEOUT' THEN

        SELECT ntf.object_id1
        BULK COLLECT INTO l_assignment_id_tbl
        FROM   pa_wf_ntf_performers ntf,
               pa_project_assignments asgn
        WHERE  ntf.group_id            = l_group_id
        AND    ntf.approver_group_id   = l_approver_group_id
        AND    ntf.routing_order       = l_routing_order
        AND    ntf.object_id1          = asgn.assignment_id
        AND    asgn.apprvl_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_submitted;

        l_project_id := wf_engine.getItemAttrNumber
                        ( itemtype => itemtype
                        , itemkey  => itemkey
                        , aname    => 'PROJECT_ID' );

        l_mode := wf_engine.getItemAttrText
                  ( itemtype => itemtype
                  , itemkey  => itemkey
                  , aname    => 'MODE' );

        l_num_assignments := l_assignment_id_tbl.COUNT;

        --Get the Update Info document
        l_update_info_doc := wf_engine.getItemAttrDocument
                             ( itemtype => itemtype
                             , itemkey  => itemkey
                             , aname    => 'UPDATED_INFO_DOC' );

        l_submitter_user_name := wf_engine.getItemAttrText
                                  ( itemtype => itemtype
                                  , itemkey  => itemkey
                                  , aname    => 'SUBMITTER_UNAME');

        l_conflict_group_id := wf_engine.getItemAttrNumber
                           ( itemtype => itemtype
                           , itemkey  => itemkey
                           , aname    => 'CONFLICT_GROUP_ID' );

        l_forwarded_from := wf_engine.getItemAttrText
                                  ( itemtype => itemtype
                                  , itemkey  => itemkey
                                  , aname    => 'NTFY_APPRVL_RECIPIENT_NAME');

        l_note_to_approvers := wf_engine.getItemAttrText
                                  ( itemtype => itemtype
                                  , itemkey  => itemkey
                                  , aname    => 'NOTE_TO_APPROVER');

        FOR i IN 1..l_assignment_id_tbl.COUNT LOOP
            l_approval_status_tbl.extend;
            l_approval_status_tbl(i) := PA_ASSIGNMENT_APPROVAL_PUB.g_reject_action;
        END LOOP;

        process_approval_result
            ( p_project_id            => l_project_id
             ,p_mode                  => l_mode
             ,p_assignment_id_tbl     => l_assignment_id_tbl
             ,p_approval_status_tbl   => l_approval_status_tbl
             ,p_group_id              => l_group_id
             ,p_approver_group_id     => l_approver_group_id
             ,p_routing_order         => l_routing_order
             ,p_num_of_assignments    => l_num_assignments
             ,p_submitter_user_name   => l_submitter_user_name
             ,p_conflict_group_id     => l_conflict_group_id
             ,p_update_info_doc       => l_update_info_doc
             ,p_forwarded_from        => l_forwarded_from
             ,p_note_to_approvers     => l_note_to_approvers);

    END IF; --end timeout case
-- 4537865 : Included Exception Block
EXCEPTION
        WHEN OTHERS THEN
        Wf_Core.Context('PA_ASGMT_WFSTD','Check_Notification_Completed',itemtype,itemkey,to_char(actid),funcmode);
        RAISE;
END Check_Notification_Completed ;

PROCEDURE Set_Submitter_User_Name
            (p_item_type     IN        VARCHAR2,
             p_item_key      IN        VARCHAR2,
             p_actid         IN        NUMBER,
             p_funcmode      IN        VARCHAR2,
             p_result        OUT       NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS

 l_error_item_type      VARCHAR2(30);
 l_error_item_key       NUMBER;
 l_submitter_user_name  VARCHAR2(240);

 BEGIN

   log_message('Inside Set_Submitter_User_Name');


   --get the following wf attributes for the process that errored out.
   l_error_item_type :=            WF_ENGINE.GetItemAttrText(itemtype =>  p_item_type,
                                                              itemkey  => p_item_key,
                                                              aname    => 'ERROR_ITEM_TYPE');

   l_error_item_key  :=            WF_ENGINE.GetItemAttrText(itemtype =>  p_item_type,
                                                              itemkey  => p_item_key,
                                                              aname    => 'ERROR_ITEM_KEY');

   l_submitter_user_name :=        WF_ENGINE.GetItemAttrText(itemtype => l_error_item_type,
                                                             itemkey  => l_error_item_key,
                                                             aname    => 'SUBMITTER_UNAME');

   --SET the Text item attributes (these attributes were created at design time)
    WF_ENGINE.SetItemAttrText(itemtype => p_item_type,
                              itemkey  => p_item_key,
                              aname    => 'SUBMITTER_UNAME',
                              avalue   => l_submitter_user_name);

   log_message('After Set_Submitter_User_Name');
-- 4537865 : Included Exception Block
EXCEPTION
	WHEN OTHERS THEN
	Wf_Core.Context('PA_ASGMT_WFSTD','Set_Submitter_User_Name',p_item_type,p_item_key,to_char(p_actid),p_funcmode);
	RAISE;
 END Set_Submitter_User_Name;

--if there is an unexpected error then the sysadmin can choose to abort or retry
--the unprocessed items.  If he chooses to abort then this API is called in
--order to revert the errored assignments to previous status

PROCEDURE Abort_Remaining_Trx
            (p_item_type     IN        VARCHAR2,
             p_item_key      IN        VARCHAR2,
             p_actid         IN        NUMBER,
             p_funcmode      IN        VARCHAR2,
             p_result        OUT       NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

 IS

 l_error_item_type   VARCHAR2(30);
 l_submitter_uname   fnd_user.user_name%type; ----- VARCHAR2(30); Commented for bug 3267790
 l_error_item_key    NUMBER;
 l_submitter_user_id NUMBER;
 l_resource_id       pa_resources_denorm.resource_id%TYPE;
 l_return_status     VARCHAR2(1);
 l_group_id          NUMBER;
 l_project_id        NUMBER;
 l_assignment_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

 BEGIN

   log_message('Inside Abort_Remaining_Trx');

   --aborting a wf happens when there is an unexpected error and
   --the sysadmin chooses to abort the workflow.
   --but we commit 1 at a time, so some of the transactions
   --may be complete - so we are only aborting the ones that are not yet processed.

   --get the following wf attributes for the process that errored out.
   l_error_item_type :=            WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                              itemkey  => p_item_key,
                                                              aname    => 'ERROR_ITEM_TYPE');

   l_error_item_key  :=            WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                              itemkey  => p_item_key,
                                                              aname    => 'ERROR_ITEM_KEY');

   l_project_id :=                       WF_ENGINE.GetItemAttrText(itemtype => l_error_item_type,
                                                                   itemkey  => l_error_item_key,
                                                                   aname    => 'PROJECT_ID');

   l_submitter_uname :=          WF_ENGINE.GetItemAttrText(itemtype => l_error_item_type,
                                                             itemkey  => l_error_item_key,
                                                             aname    => 'SUBMITTER_UNAME');

   l_group_id :=                 WF_ENGINE.GetItemAttrText(itemtype => l_error_item_type,
                                                             itemkey  => l_error_item_key,
                                                             aname    => 'GROUP_ID');

   SELECT ntf.object_id1
   BULK COLLECT INTO l_assignment_id_tbl
   FROM   pa_wf_ntf_performers ntf,
          pa_project_assignments asgn
   WHERE  ntf.group_id            = l_group_id
   AND    ntf.routing_order       = 1
   AND    ntf.object_id1          = asgn.assignment_id
   AND    asgn.apprvl_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_submitted;


         --if there are any aborted items then add a message to the stack
         --saying that those items were aborted by the sysadmin.
         IF l_assignment_id_tbl.COUNT > 0 THEN

            FOR i IN l_assignment_id_tbl.FIRST .. l_assignment_id_tbl.LAST LOOP

               FND_MSG_PUB.initialize;

               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_PROCESS_ABORTED_SYSADMIN');

               SELECT user_id
               INTO   l_submitter_user_id
               FROM   fnd_user
               WHERE  user_name = l_submitter_uname;

               SELECT resource_id
               INTO   l_resource_id
               FROM   pa_project_assignments
               WHERE  assignment_id = l_assignment_id_tbl(i);

               --Revert assignment status back to previous status before approval
               Revert_assignment_status(
                   p_assignment_id => l_assignment_id_tbl(i)
                  ,p_group_id      => l_group_id
                  ,x_return_status => l_return_status);

               PA_MESSAGE_UTILS.save_messages(p_user_id            =>  l_submitter_user_id,
                                              p_source_type1       =>  PA_MASS_ASGMT_TRX.G_SOURCE_TYPE1,
                                              p_source_type2       =>  'MASS_APPROVAL',
                                              p_source_identifier1 =>  'PAWFAAP',
                                              p_source_identifier2 =>  l_group_id,
                                              p_context1           =>  l_project_id,
                                              p_context2           =>  l_assignment_id_tbl(i),
                                              p_context3           =>  l_resource_id,
                                              p_commit             =>  FND_API.G_FALSE,
                                              x_return_status      =>  l_return_status);

            END LOOP;

         END IF;
    log_message('Abort_Remaining_Trx');

 EXCEPTION
   WHEN OTHERS THEN
      RAISE;

 END Abort_Remaining_Trx;

END PA_ASGMT_WFSTD;

/

  GRANT EXECUTE ON "APPS"."PA_ASGMT_WFSTD" TO "EBSBI";

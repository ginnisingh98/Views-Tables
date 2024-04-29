--------------------------------------------------------
--  DDL for Package Body PA_WORKPLAN_WORKFLOW_CLIENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_WORKPLAN_WORKFLOW_CLIENT" as
/*$Header: PAXSTWCB.pls 120.8.12010000.3 2009/08/12 12:12:52 jsundara ship $*/

/*=================================================================

Name:         START_WORKFLOW
Type:         Procedure
Description:  This API has been created for initialization.
              This is a Client Extension provided to the customer
              to add new variables and initialize them before
              the workflow process begins.

IN:
p_item_type   --The internal name for the item type. Item types
                are defined in the Oracle Workflow Builder.
p_item_key    --A string that represents a primary key generated
                by the workflow-enabled application for the item
                type. The string uniquely identifies the item
                within an item type.
actid         --The ID number of the activity from which this
                procedure is called.
funcmode      --The execution mode of the activity. If the activity
                is a function activity, the mode is either 'RUN' or
                'CANCEL'. If the activity is a notification activity,
                with a post-notification function, then the mode can
                be 'RESPOND', 'FORWARD', 'TRANSFER', 'TIMEOUT', or
                'RUN'. Other execution modes may be added in the
                future.

OUT:
resultout     --If a result type is specified in the Activities
                properties page for the activity in the Oracle
                Workflow Builder, this parameter represents the
                expected result that is returned when the procedure
                completes.

=================================================================*/
  procedure START_WORKFLOW
  (
    p_item_type              IN  VARCHAR2
   ,p_item_key               IN  VARCHAR2
   ,p_process_name           IN  VARCHAR2
   ,p_structure_version_id   IN  NUMBER
   ,p_responsibility_id      IN  NUMBER
   ,p_user_id                IN  NUMBER
   ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_structure_ver_name   VARCHAR2(240);
    l_structure_ver_num    NUMBER;
    l_structure_ver_desc   VARCHAR2(250);
    l_locked_by_person_id  NUMBER;
    l_project_id           NUMBER;
    l_project_name         VARCHAR2(30);
    l_project_num          VARCHAR2(25);
    l_record_version_num   NUMBER;
    l_submitter_role       VARCHAR2(30);
    l_submitter_role_users VARCHAR2(300);
    l_submitter_name         per_all_people_f.full_name%type;  -- Added for bug# 7368606


    display_name            VARCHAR2(2000);
    email_address           VARCHAR2(2000);
    notification_preference VARCHAR2(2000);
    language                VARCHAR2(2000);
    territory               VARCHAR2(2000);
    -- Added for Bug fix: 4537865
    l_new_submitter_role    VARCHAR2(30);
    -- Added for Bug fix: 4537865

    CURSOR getStructureVerInfo IS
      select a.VERSION_NUMBER, a.NAME, a.PROJECT_ID, a.LOCKED_BY_PERSON_ID,
             a.record_version_number, a.description
        from pa_proj_elem_ver_structure a,
             pa_proj_element_versions b
       where p_structure_version_id = b.element_version_id
         and b.project_id = a.project_id
         and b.element_version_id = a.element_version_id;

    CURSOR getProjectInfo(c_project_id NUMBER) IS
      select a.name, a.segment1
        from pa_projects_all a
       where c_project_id = a.project_id;

    --Cursor for selecting submitter
    -- 4586987 customer_id changed  to person_party_id
    /*
    CURSOR getSubmitter IS
      select usr.user_id, usr.customer_id, usr.user_name, papf.email_address,
             papf.full_name person_name
        from per_all_people_f papf, fnd_user usr
       where papf.person_id = usr.employee_id
         and trunc(sysdate) between papf.effective_start_date
             and nvl(papf.effective_end_date, sysdate+1)
         and trunc(sysdate) between usr.start_date
             and nvl(usr.end_date, sysdate+1)
         and usr.user_id = l_locked_by_person_id;
    */

    -- Bug 6826760 - Replaced l_locked_by_person_id with p_user_id.
    CURSOR getSubmitter IS
     SELECT usr.user_id, usr.person_party_id, usr.user_name, papf.email_address, --customer_id is replaced with person_party_id
             papf.full_name person_name
         FROM per_all_people_f papf, fnd_user usr
         WHERE papf.person_id = usr.employee_id
         AND trunc(sysdate) between papf.effective_start_date
         AND nvl(papf.effective_end_date, sysdate+1)
         AND trunc(sysdate) between usr.start_date
         AND nvl(usr.end_date, sysdate+1)
         AND usr.user_id = p_user_id;

    -- End of  bug Number 4586987

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN getStructureVerInfo;
    FETCH getStructureVerInfo INTO l_structure_ver_num, l_structure_ver_name, l_project_id, l_locked_by_person_id, l_record_version_num, l_structure_ver_desc;
    CLOSE getStructureVerInfo;

    --set structure_ver_name
    wf_engine.SetItemAttrText(p_item_type, p_item_key,
                              'STRUCTURE_VER_NAME',l_structure_ver_name);

    --set structure_ver_number
    wf_engine.SetItemAttrText(p_item_type, p_item_key,
                              'STRUCTURE_VER_NUM', to_char(l_structure_ver_num));

    --set structure_ver_id
    wf_engine.SetItemAttrNumber(p_item_type, p_item_key,
                                'STRUCTURE_VER_ID',p_structure_version_id);
    wf_engine.SetItemAttrText(p_item_type, p_item_key,
                                'STRUCTURE_VER_ID_T',to_char(p_structure_version_id));

    --set structure_ver_name
    wf_engine.SetItemAttrText(p_item_type, p_item_key,
                              'STRUCTURE_VER_DESC',l_structure_ver_desc);

    --set record_version_number
    wf_engine.SetItemAttrNumber(p_item_type, p_item_key,
                                'RECORD_VERSION_NUMBER',l_record_version_num);


    OPEN getProjectInfo(l_project_id);
    FETCH getProjectInfo into l_project_name, l_project_num;
    CLOSE getProjectInfo;

    --set project_name
    wf_engine.SetItemAttrText(p_item_type, p_item_key,
                              'PROJECT_NAME', l_project_name);
    --set project_num
    wf_engine.SetItemAttrText(p_item_type, p_item_key,
                              'PROJECT_NUM', l_project_num);
    --set project_id
    wf_engine.SetItemAttrNumber(p_item_type, p_item_key,
                                'PROJECT_ID', l_project_id);

    --set responsibility_id
    wf_engine.SetItemAttrNUMBER(p_item_type, p_item_key,
                                'RESPONSIBILITY_ID', p_responsibility_id);

    --set user_id
    wf_engine.SetItemAttrNUMBER(p_item_type, p_item_key,
                                'USER_ID', p_user_id);

    --set workplan_submitter
    l_submitter_role := 'SUBMITBY_'||p_item_type||p_item_key;

    -- Bug 6826760 (Initialize l_new_submitter_role)
    l_new_submitter_role := l_submitter_role;


    l_submitter_role_users := NULL;
    FOR v_submitter in getSubmitter LOOP
      IF (l_submitter_role_users IS NOT NULL) THEN
        l_submitter_role_users := l_submitter_role_users||',';
      END IF;

      WF_DIRECTORY.GetRoleInfo(v_submitter.user_name,
                               display_name,
                               email_address,
                               notification_preference,
                               language,
                               territory);
      IF display_name is NULL then

        WF_DIRECTORY.CreateAdHocUser(name => v_submitter.user_name
                                    ,display_name => v_submitter.person_name
                                    ,email_address => v_submitter.email_address);
      END IF;
      -- Bug 6826760
      l_submitter_role_users := l_submitter_role_users || v_submitter.user_name;
      l_submitter_name :=  v_submitter.person_name; -- Added for bug# 7368606

    END LOOP;

     WF_DIRECTORY.CreateAdHocRole(role_name => l_submitter_role
                                 ,role_display_name => l_submitter_name        -- added for Bug: 4537865
                                ,expiration_date => sysdate+1); -- Set an expiration date for bug#5962410
            -- added for Bug: 4537865
                l_submitter_role := l_new_submitter_role;
            -- added for Bug: 4537865

    IF (l_submitter_role_users IS NOT NULL) THEN
      wf_directory.addUsersToAdHocRole(l_submitter_role,
                                       l_submitter_role_users);
      wf_engine.setItemAttrText(p_item_type
                               ,p_item_key
                               ,'WORKPLAN_SUBMITTER'
                               ,l_submitter_role);

    wf_engine.SetItemAttrText
                        (itemtype   => p_item_type,
			 itemkey  	=> p_item_key,
			 aname 		=> '#FROM_ROLE',
			 avalue		=> l_submitter_role -- Added for bug# 7368606
			);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_count :=1;
      x_msg_data:= substr(SQLERRM, 1, 2000);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE;
  END START_WORKFLOW;


/*=================================================================

Name:         SELECT_APPROVER
Type:         Procedure
Description:  This API has been created for selecting an approver.
              This is a Client Extension provided to the customer
              to modify the default approver when the approver is
              not specified.

IN:
p_item_type   --The internal name for the item type. Item types
                are defined in the Oracle Workflow Builder.
p_item_key    --A string that represents a primary key generated
                by the workflow-enabled application for the item
                type. The string uniquely identifies the item
                within an item type.
actid         --The ID number of the activity from which this
                procedure is called.
funcmode      --The execution mode of the activity. If the activity
                is a function activity, the mode is either 'RUN' or
                'CANCEL'. If the activity is a notification activity,
                with a post-notification function, then the mode can
                be 'RESPOND', 'FORWARD', 'TRANSFER', 'TIMEOUT', or
                'RUN'. Other execution modes may be added in the
                future.

OUT:
resultout     --If a result type is specified in the Activities
                properties page for the activity in the Oracle
                Workflow Builder, this parameter represents the
                expected result that is returned when the procedure
                completes.
=================================================================*/

  procedure SELECT_APPROVER
  (
    p_item_type          IN  VARCHAR2
   ,p_item_key           IN  VARCHAR2
   ,actid                IN  NUMBER
   ,funcmode             IN  VARCHAR2
   ,resultout            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_project_id            NUMBER;
    l_submitted_by_id       NUMBER;
    l_approver_source_id    NUMBER;
    l_approval_role         VARCHAR2(30);
    l_approval_role_users   VARCHAR2(300);
    l_source_id             NUMBER;
    l_source_type           NUMBER;

    /* Commented the following cursor and modified as below for bug# 3732090
    CURSOR getApprover IS
      select wp_approver_source_id, wp_approver_source_type
        from pa_proj_workplan_attr
       where project_id = l_project_id; */

    CURSOR getApprover IS
      select wp.wp_approver_source_id, wp.wp_approver_source_type, p1.full_name
        from pa_proj_workplan_attr wp, per_all_people_f p1
       where wp.project_id = l_project_id
         and p1.person_id = wp.wp_approver_source_id
     and trunc(sysdate) between trunc(p1.effective_start_date)
             and NVL(p1.effective_end_date, sysdate);
    /* Changes ended for bug# 3732090*/

    /* Modify this cursor to select the default approver when
       the approver is not specified */
    CURSOR getProjectManagerHR IS
      select fu.user_name, p1.supervisor_id person_id, p2.full_name person_name,
             p2.email_address
        from per_assignments_f p1, per_all_people_f p2,
             fnd_user fu, pa_project_parties p
       where p.project_id = l_project_id
         and p.project_role_id = 1
         and TRUNC(sysdate) between p.START_DATE_ACTIVE
             and NVL(p.END_DATE_ACTIVE, sysdate+1)
       -- and p1.assignment_type = 'E'  /* Bug#2911451 */ -- Commented by avaithia for Bug 3448680
          and p1.assignment_type in ('E','C')             -- Included By  avaithia for Bug 3448680
         and p1.primary_flag = 'Y'     /* Bug#2911451 */
         and p.resource_source_id = p1.person_id
         and p1.supervisor_id = p2.person_id
         and trunc(sysdate) between p1.effective_start_date
             and p1.effective_end_date
         and trunc(sysdate) between p2.effective_start_date
             and NVL(p2.effective_end_date, sysdate)
         and fu.employee_id = p1.supervisor_id;

    CURSOR l_approver_csr_person IS
      select distinct fu.user_id, fu.user_name, papf.email_address,
             papf.full_name person_name
        from fnd_user fu, per_all_people_f papf
       where fu.employee_id = l_source_id
         and papf.person_id = fu.employee_id
         and trunc(sysdate) between papf.EFFECTIVE_START_DATE
             and Nvl(papf.effective_end_date, Sysdate + 1)
         and trunc(sysdate) between fu.START_DATE and nvl(fu.END_DATE, sysdate+1);

    -- 4586987 customer_id changed to person_party_id
    /*
    CURSOR l_approver_csr_party IS
      select distinct fu.user_id, fu.user_name, papf.email_address,
             papf.full_name person_name
        from fnd_user fu,per_all_people_f papf
       where fu.customer_id = l_source_id
         and papf.person_id = fu.employee_id
         and trunc(sysdate) between papf.EFFECTIVE_START_DATE
             and Nvl(papf.effective_end_date, Sysdate + 1)
         and trunc(sysdate) between fu.START_DATE
             and nvl(fu.END_DATE, sysdate+1);
    */
    CURSOR l_approver_csr_party IS
    select distinct fu.user_id, fu.user_name, papf.email_address,
             papf.full_name person_name
        from fnd_user fu,per_all_people_f papf
        where fu.person_party_id = l_source_id --reference is changed from customer_id to person_party_id
        and papf.person_id = fu.employee_id
        and trunc(sysdate) between papf.EFFECTIVE_START_DATE
        and Nvl(papf.effective_end_date, Sysdate + 1)
        and trunc(sysdate) between fu.START_DATE
        and nvl(fu.END_DATE, sysdate+1);

    -- 4586987 end

    display_name            VARCHAR2(2000);
    email_address           VARCHAR2(2000);
    notification_preference VARCHAR2(2000);
    language                VARCHAR2(2000);
    territory               VARCHAR2(2000);
    l_approver_name         per_all_people_f.full_name%type;  -- Added for bug# 3732090
  BEGIN
    /* get stored values */
    l_project_id := wf_engine.getItemAttrNumber(
                                      itemtype => p_item_type
                                     ,itemkey  => p_item_key
                                     ,aname     => 'PROJECT_ID');

    l_submitted_by_id := wf_engine.getItemAttrNumber(
                                      itemtype => p_item_type
                                     ,itemkey  => p_item_key
                                     ,aname     => 'SUBMITTED_BY_ID');

    l_approval_role := 'APVR_'||p_item_type||p_item_key;

    /* Create role */
    /* Commented the following call to CreateAdHocRole and moved down with modifications for bug# 3732090
    wf_directory.CreateAdHocRole(role_name => l_approval_role
                                ,role_display_name => l_approval_role
                                ,expiration_date => NULL);
    */

    /* get approver */
    OPEN getApprover;
    /* Commented the following fetch statement and modified as below for bug# 3732090
    FETCH getApprover into l_source_id, l_source_type;*/
    FETCH getApprover into l_source_id, l_source_type, l_approver_name;
    /* Changes ended for bug# 3732090 */
    IF (l_source_id IS NULL) or (l_source_type IS NULL) or getApprover%NOTFOUND THEN
      --No approver has been specified.
      --Default cursor will obtain the project manager's HR manager
      --Modify getProjectManagerHR cursor to obtain desired user as
      --default approver.
      l_approval_role_users := NULL;

      For v_approvers in getProjectManagerHR LOOP
        IF (l_approval_role_users IS NOT NULL) THEN
          l_approval_role_users := l_approval_role_users || ',';
        END IF;
        WF_DIRECTORY.GetRoleInfo(v_approvers.user_name,
                                 display_name,
                                 email_address,
                                 notification_preference,
                                 language,
                                 territory);
        IF display_name is NULL THEN
          --Add user to directory
          WF_DIRECTORY.createAdHocUser(name => v_approvers.user_name
                                      ,display_name => v_approvers.person_name
                                      ,email_address => v_approvers.email_address);
        END IF;
        l_approval_role_users := l_approval_role_users ||v_approvers.user_name;
        l_approver_name := v_approvers.person_name; -- Added for bug# 3732090
      END LOOP;
    ELSE
      --Approver has been specified.
      l_approval_role_users := NULL;
      --get approver
      IF (l_source_type = 101) THEN
        --Get internal users
        FOR v_approvers IN l_approver_csr_person LOOP
          IF (l_approval_role_users IS NOT NULL) THEN
            l_approval_role_users := l_approval_role_users || ',';
          END IF;
          WF_DIRECTORY.GetRoleInfo(v_approvers.user_name,
                                   display_name,
                                   email_address,
                                   notification_preference,
                                   language,
                                   territory);

          IF display_name IS NULL THEN
            --Add user to directory
            WF_DIRECTORY.createAdHocUser(name => v_approvers.user_name
                                        ,display_name => v_approvers.person_name
                                        ,email_address => v_approvers.email_address);
          END IF;
          l_approval_role_users := l_approval_role_users ||v_approvers.user_name;
        END LOOP;
      ELSIF (l_source_type = 112) THEN
        --Get external users
        FOR v_approvers IN l_approver_csr_party LOOP
          IF (l_approval_role_users IS NOT NULL) THEN
            l_approval_role_users := l_approval_role_users || ',';
          END IF;
          WF_DIRECTORY.GetRoleInfo(v_approvers.user_name,
                                   display_name,
                                   email_address,
                                   notification_preference,
                                   language,
                                   territory);
          IF display_name IS NULL THEN
            --Add user to directory
            WF_DIRECTORY.createAdHocUser(name => v_approvers.user_name
                                        ,display_name => v_approvers.person_name
                                        ,email_address => v_approvers.email_address);
          END IF;
          l_approval_role_users := l_approval_role_users ||v_approvers.user_name;
        END LOOP;
      END IF;
    END IF;
    CLOSE getApprover;
    /* Added the following call to CreateAdHocRole for bug# 3732090 */
    wf_directory.CreateAdHocRole(role_name => l_approval_role
                                ,role_display_name => l_approver_name  -- Modifed the parameter from l_approval_role to l_approver_name bug#3732090
                                ,expiration_date => sysdate+1); -- Set an expiration date for bug#5962410

  /* wf_engine.SetItemAttrText
                        (itemtype   => p_item_type,
			 itemkey  	=> p_item_key,
			 aname 		=> '#FROM_ROLE',
			 avalue		=> l_approval_role ); janani */


    IF (l_approval_role_users IS NOT NULL) THEN
      --Add the selected user(s) to the role
      WF_DIRECTORY.ADDUSERSTOADHOCROLE(l_approval_role,
                                       l_approval_role_users);
      WF_engine.setItemAttrText(p_item_type,
                                p_item_key,
                                'WORKPLAN_APPROVER',
                                l_approval_role);
      resultout := wf_engine.eng_completed||':'||'T';
    ELSE
      resultout := wf_engine.eng_completed||':'||'F';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END SELECT_APPROVER;

/*=================================================================

Name:         SET_NOTIFICATION_PARTY
Type:         Procedure
Description:  This API has been created for selecting the notifying
              party when the workplan has been approved or rejected.
              This is a Client Extension provided to the customer
              to modify the default receiver of the notifications

IN:
p_item_type   --The internal name for the item type. Item types
                are defined in the Oracle Workflow Builder.
p_item_key    --A string that represents a primary key generated
                by the workflow-enabled application for the item
                type. The string uniquely identifies the item
                within an item type.
actid         --The ID number of the activity from which this
                procedure is called.
funcmode      --The execution mode of the activity. If the activity
                is a function activity, the mode is either 'RUN' or
                'CANCEL'. If the activity is a notification activity,
                with a post-notification function, then the mode can
                be 'RESPOND', 'FORWARD', 'TRANSFER', 'TIMEOUT', or
                'RUN'. Other execution modes may be added in the
                future.

OUT:
resultout     --If a result type is specified in the Activities
                properties page for the activity in the Oracle
                Workflow Builder, this parameter represents the
                expected result that is returned when the procedure
                completes.
=================================================================*/
  procedure set_notification_party
  (
    p_item_type          IN  VARCHAR2
   ,p_item_key           IN  VARCHAR2
   ,p_status_code        IN  VARCHAR2
   ,actid                IN  NUMBER
   ,funcmode             IN  VARCHAR2
   ,resultout            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_project_id   NUMBER;
    l_structure_version_id    NUMBER;
    --This cursor is used when the workplan is approved or rejected.
    --This cursor returns all project members who has the edit privilege.
    --This cursor returns internal users.
    CURSOR getApprovedRejectedPerson IS
      select distinct fu.user_id, fu.user_name, papf.email_address,
             papf.full_name person_name
        from fnd_user fu, per_all_people_f papf, pa_project_parties ppp,
             pa_project_role_types pprt
       where object_type = 'PA_PROJECTS'
         --and object_id = l_project_id Bug 4562762
     -- Bug 4562762 : Added logic to select program too
     and object_id IN (select ver.project_id
                       from pa_object_relationships obj
                , pa_proj_element_versions ver
               where obj.object_id_to1=l_structure_version_id
               and obj.relationship_type = 'LW'
               and obj.object_id_from1=ver.element_version_id
               union
               select l_project_id
               from dual)
         and ppp.resource_type_id = 101
         and ppp.project_role_id = pprt.project_role_id
         and ppp.resource_source_id = fu.employee_id
         and papf.person_id = fu.employee_id
         and trunc(sysdate) between papf.effective_start_date
             and nvl(papf.effective_end_date, sysdate+1)
         and trunc(sysdate) between fu.start_date
             and nvl(fu.end_date, sysdate+1)
         and trunc(sysdate) between ppp.start_date_active
             and nvl(ppp.end_date_active, sysdate+1)
         and pprt.menu_id IN (select f1.menu_id
             from fnd_compiled_menu_functions f1, fnd_form_functions f2
            where (f2.function_name = 'PA_PAXPREPR_OPT_WORKPLAN_STR')
              and f2.function_id = f1.function_id)
         UNION /*Added this clause for Approver 4291185 */
            select distinct fu.user_id, fu.user_name, papf.email_address,
             papf.full_name person_name
        from fnd_user fu, per_all_people_f papf
       where fu.user_id =  fnd_global.USER_ID
         and papf.person_id = fu.employee_id
         and trunc(sysdate) between papf.effective_start_date
             and nvl(papf.effective_end_date, sysdate+1)
         and trunc(sysdate) between fu.start_date
             and nvl(fu.end_date, sysdate+1) ;

    --This cursor is used when the workplan is approved or rejected.
    --This cursor returns all project members who has the edit privilege.
    --This cursor returns external users or companies.
    -- 4586987 customer_id changed  to person_party_id
    /*
    CURSOR getApprovedRejectedParty IS
      select distinct fu.user_id, fu.user_name, papf.email_address,
             papf.full_name person_name
        from fnd_user fu, per_all_people_f papf, pa_project_parties ppp,
             pa_project_role_types pprt
       where object_type = 'PA_PROJECTS'
         and object_id = l_project_id
         and ppp.resource_type_id = 112
         and ppp.project_role_id = pprt.project_role_id
         and ppp.resource_id = fu.customer_id
         and papf.person_id = fu.employee_id
         and trunc(sysdate) between papf.effective_start_date
             and nvl(papf.effective_end_date, sysdate+1)
         and trunc(sysdate) between fu.start_date
             and nvl(fu.end_date, sysdate+1)
         and trunc(sysdate) between ppp.start_date_active
             and nvl(ppp.end_date_active, sysdate+1)
         and pprt.menu_id IN (select f1.menu_id
             from fnd_compiled_menu_functions f1, fnd_form_functions f2
            where (f2.function_name = 'PA_PAXPREPR_OPT_WORKPLAN_STR')
              and f2.function_id = f1.function_id);
    */

    CURSOR getApprovedRejectedParty IS
    select distinct fu.user_id, fu.user_name, papf.email_address,
             papf.full_name person_name
        from fnd_user fu, per_all_people_f papf, pa_project_parties ppp,
             pa_project_role_types pprt
         where object_type = 'PA_PROJECTS'
         and object_id = l_project_id
         and ppp.resource_type_id = 112
         and ppp.project_role_id = pprt.project_role_id
         and ppp.resource_id = fu.person_party_id -- customer_id is changed to person_party_id
         and papf.person_id = fu.employee_id
         and trunc(sysdate) between papf.effective_start_date
         and nvl(papf.effective_end_date, sysdate+1)
         and trunc(sysdate) between fu.start_date
         and nvl(fu.end_date, sysdate+1)
         and trunc(sysdate) between ppp.start_date_active
         and nvl(ppp.end_date_active, sysdate+1)
         and pprt.menu_id IN (select f1.menu_id
         from fnd_compiled_menu_functions f1, fnd_form_functions f2
         where (f2.function_name = 'PA_PAXPREPR_OPT_WORKPLAN_STR')
         and f2.function_id = f1.function_id);

    -- 4586987 end

    --This cursor is used when the workplan is published.
    --This cursor returns all project members and task managers
    --who has the view privilege.
    --This cursor returns internal users.
    --Bug No 3695601 Performance Fix Using EXISTS instead of IN
/*    CURSOR getWorkplanViewerPerson IS
      select distinct fu.user_id, fu.user_name, papf.email_address,
             papf.full_name person_name
        from fnd_user fu, per_all_people_f papf, pa_project_parties ppp,
             pa_project_role_types pprt
       where object_type = 'PA_PROJECTS'
         and object_id = l_project_id
         and ppp.resource_type_id = 101
         and ppp.project_role_id = pprt.project_role_id
         and ppp.resource_source_id = fu.employee_id
         and papf.person_id = fu.employee_id
         and trunc(sysdate) between papf.effective_start_date
             and nvl(papf.effective_end_date, sysdate+1)
         and trunc(sysdate) between fu.start_date
             and nvl(fu.end_date, sysdate+1)
         and trunc(sysdate) between ppp.start_date_active
             and nvl(ppp.end_date_active, sysdate+1)
         and pprt.menu_id IN (select f1.menu_id
             from fnd_compiled_menu_functions f1, fnd_form_functions f2
            where (f2.function_name = 'PA_PAXPREPR_OPT_WORKPLAN_STR'
                   or f2.function_name = 'PA_PAXPREPR_OPT_WORKPLAN_STR_V')
              and f2.function_id = f1.function_id)
       UNION
      select distinct fu.user_id, fu.user_name, papf.email_address,
             papf.full_name person_name
        from fnd_user fu, per_all_people_f papf, pa_proj_elements ele
       where ele.project_id = l_project_id
         and ele.MANAGER_PERSON_ID = fu.employee_id
         and papf.person_id = fu.employee_id
         and trunc(sysdate) between papf.effective_start_date
             and nvl(papf.effective_end_date, sysdate+1)
         and trunc(sysdate) between fu.start_date
             and nvl(fu.end_date, sysdate+1);*/

    CURSOR getWorkplanViewerPerson IS
      select distinct fu.user_id, fu.user_name, papf.email_address,
             papf.full_name person_name
        from fnd_user fu, per_all_people_f papf, pa_project_parties ppp,
             pa_project_role_types pprt
       where object_type = 'PA_PROJECTS'
         and object_id = l_project_id
         and ppp.resource_type_id = 101
         and ppp.project_role_id = pprt.project_role_id
         and ppp.resource_source_id = fu.employee_id
         and papf.person_id = fu.employee_id
         and trunc(sysdate) between papf.effective_start_date
             and nvl(papf.effective_end_date, sysdate+1)
         and trunc(sysdate) between fu.start_date
             and nvl(fu.end_date, sysdate+1)
         and trunc(sysdate) between ppp.start_date_active
             and nvl(ppp.end_date_active, sysdate+1)
         and EXISTS (select f1.menu_id
             from fnd_compiled_menu_functions f1, fnd_form_functions f2
            where (f2.function_name = 'PA_PAXPREPR_OPT_WORKPLAN_STR'
                   or f2.function_name = 'PA_PAXPREPR_OPT_WORKPLAN_STR_V')
              and f2.function_id = f1.function_id)
       UNION
      select distinct fu.user_id, fu.user_name, papf.email_address,
             papf.full_name person_name
        from fnd_user fu, per_all_people_f papf, pa_proj_elements ele
       where ele.project_id = l_project_id
         and ele.MANAGER_PERSON_ID = fu.employee_id
         and papf.person_id = fu.employee_id
         and trunc(sysdate) between papf.effective_start_date
             and nvl(papf.effective_end_date, sysdate+1)
         and trunc(sysdate) between fu.start_date
             and nvl(fu.end_date, sysdate+1)
       UNION
      select distinct fu.user_id, fu.user_name, papf.email_address,
             papf.full_name person_name
        from fnd_user fu, per_all_people_f papf
       where fu.user_id = fnd_global.USER_ID
         and papf.person_id = fu.employee_id
         and trunc(sysdate) between papf.effective_start_date
             and nvl(papf.effective_end_date, sysdate+1)
         and trunc(sysdate) between fu.start_date
             and nvl(fu.end_date, sysdate+1);


    --This cursor is used when the workplan is published.
    --This cursor returns all project members who has the view privilege.
    --This cursor returns external users or companies.
    -- 4586987 customer_id changed  to person_party_id in fnd_user table
    /*
    CURSOR getWorkplanViewerParty IS
      select distinct fu.user_id, fu.user_name, papf.email_address,
             papf.full_name person_name
        from fnd_user fu, per_all_people_f papf, pa_project_parties ppp,
             pa_project_role_types pprt
       where object_type = 'PA_PROJECTS'
         and object_id = l_project_id
         and ppp.resource_type_id = 112
         and ppp.project_role_id = pprt.project_role_id
         and ppp.resource_id = fu.customer_id
         and papf.person_id = fu.employee_id
         and trunc(sysdate) between papf.effective_start_date
             and nvl(papf.effective_end_date, sysdate+1)
         and trunc(sysdate) between fu.start_date
             and nvl(fu.end_date, sysdate+1)
         and trunc(sysdate) between ppp.start_date_active
             and nvl(ppp.end_date_active, sysdate+1)
         and pprt.menu_id IN (select f1.menu_id
             from fnd_compiled_menu_functions f1, fnd_form_functions f2
            where (f2.function_name = 'PA_PAXPREPR_OPT_WORKPLAN_STR'
                   or f2.function_name = 'PA_PAXPREPR_OPT_WORKPLAN_STR_V')
              and f2.function_id = f1.function_id);
    */

    CURSOR getWorkplanViewerParty IS
       select distinct fu.user_id, fu.user_name, papf.email_address,
             papf.full_name person_name
        from fnd_user fu, per_all_people_f papf, pa_project_parties ppp,
             pa_project_role_types pprt
         where object_type = 'PA_PROJECTS'
         and object_id = l_project_id
         and ppp.resource_type_id = 112
         and ppp.project_role_id = pprt.project_role_id
         and ppp.resource_id = fu.person_party_id -- customer_id changed  to person_party_id in fnd_user table
         and papf.person_id = fu.employee_id
         and trunc(sysdate) between papf.effective_start_date
         and nvl(papf.effective_end_date, sysdate+1)
         and trunc(sysdate) between fu.start_date
         and nvl(fu.end_date, sysdate+1)
         and trunc(sysdate) between ppp.start_date_active
         and nvl(ppp.end_date_active, sysdate+1)
         and pprt.menu_id IN (select f1.menu_id
          from fnd_compiled_menu_functions f1, fnd_form_functions f2
          where (f2.function_name = 'PA_PAXPREPR_OPT_WORKPLAN_STR'
                   or f2.function_name = 'PA_PAXPREPR_OPT_WORKPLAN_STR_V')
              and f2.function_id = f1.function_id);
     -- 4586987 end

    l_appr_rej_role           VARCHAR2(30);
    l_appr_rej_role_usr       VARCHAR2(300);
    l_wp_viewer_role          VARCHAR2(30);
    -- Commented for Bug 5561154 (Base bug 5559025) l_wp_viewer_role_usr      VARCHAR2(300);
    -- Added for Bug 5561154 (Base bug 5559025)
    l_wp_viewer_role_usr      VARCHAR2(4000);

    display_name            VARCHAR2(2000);
    email_address           VARCHAR2(2000);
    notification_preference VARCHAR2(2000);
    language                VARCHAR2(2000);
    territory               VARCHAR2(2000);
  BEGIN
    --Need to set the followings
    --  APPROVED_REJECTED_RECEIVER
    --  WORKPLAN_VIEWER
    l_project_id           := wf_engine.GetItemAttrNumber(
                                          itemtype => p_item_type,
                                          itemkey  => p_item_key,
                                          aname    => 'PROJECT_ID');

    l_structure_version_id := wf_engine.GetItemAttrNumber(
                                          itemtype => p_item_type,
                                          itemkey  => p_item_key,
                                          aname    => 'STRUCTURE_VER_ID');

    l_appr_rej_role := 'APRJ_'||p_item_type||p_item_key;
    WF_DIRECTORY.CREATEADHOCROLE(role_name => l_appr_rej_role
                                 ,role_display_name => l_appr_rej_role
                                 ,expiration_date => sysdate+1); -- Set an expiration date for bug#5962410

    --For approved_rejected_receiver
    --Get internal users
    l_appr_rej_role_usr := NULL;

    FOR v_appr_rej IN getApprovedRejectedPerson LOOP
      IF (l_appr_rej_role_usr IS NOT NULL) THEN
        l_appr_rej_role_usr := l_appr_rej_role_usr||',';
      END IF;
      WF_DIRECTORY.GetRoleInfo(v_appr_rej.user_name,
                               display_name,
                               email_address,
                               notification_preference,
                               language,
                               territory);

      IF display_name IS NULL THEN
        --Add user to directory
        wf_directory.createadhocuser( name => v_appr_rej.user_name
                                     ,display_name => v_appr_rej.person_name
                                     ,email_address => v_appr_rej.email_address);
      END IF;
      l_appr_rej_role_usr := l_appr_rej_role_usr||v_appr_rej.user_name;
    END LOOP;

    --Get external user
    FOR v_appr_rej IN getApprovedRejectedParty LOOP
      IF (l_appr_rej_role_usr IS NOT NULL) THEN
        l_appr_rej_role_usr := l_appr_rej_role_usr||',';
      END IF;
      WF_DIRECTORY.GetRoleInfo(v_appr_rej.user_name,
                               display_name,
                               email_address,
                               notification_preference,
                               language,
                               territory);

      IF display_name IS NULL THEN
        --Add user to directory
        wf_directory.createadhocuser( name => v_appr_rej.user_name
                                     ,display_name => v_appr_rej.person_name
                                     ,email_address => v_appr_rej.email_address);
      END IF;
      l_appr_rej_role_usr := l_appr_rej_role_usr||v_appr_rej.user_name;
    END LOOP;

    IF (l_appr_rej_role_usr IS NOT NULL) THEN
      --Add the selected user(s) to the role
      wf_directory.adduserstoadhocRole(l_appr_rej_role
                                      ,l_appr_rej_role_usr);
      wf_engine.setitemattrtext(p_item_type
                               ,p_item_key
                               ,'APPROVED_REJECTED_RECEIVER'
                               ,l_appr_rej_role);
    END IF;

    --For workplan_viewer
    --Get internal user
    l_wp_viewer_role := 'WPVR_'||p_item_type||p_item_key;
    WF_DIRECTORY.CREATEADHOCROLE(role_name => l_wp_viewer_role
                                 ,role_display_name => l_wp_viewer_role
                                 ,expiration_date => sysdate+1); -- Set an expiration date for bug#5962410

    l_wp_viewer_role_usr := NULL;
    FOR v_wp_vr IN getWorkplanViewerPerson LOOP
      IF (l_wp_viewer_role_usr IS NOT NULL) THEN
        l_wp_viewer_role_usr := l_wp_viewer_role_usr||',';
      END IF;
      WF_DIRECTORY.GetRoleInfo(v_wp_vr.user_name,
                               display_name,
                               email_address,
                               notification_preference,
                               language,
                               territory);

      IF display_name IS NULL THEN
        --Add user to directory
        wf_directory.createadhocuser( name => v_wp_vr.user_name
                                     ,display_name => v_wp_vr.person_name
                                     ,email_address => v_wp_vr.email_address);
      END IF;
      l_wp_viewer_role_usr := l_wp_viewer_role_usr||v_wp_vr.user_name;
    END LOOP;

    --Get external user
    FOR v_wp_vr IN getWorkplanViewerParty LOOP
      IF (l_wp_viewer_role_usr IS NOT NULL) THEN
        l_wp_viewer_role_usr := l_wp_viewer_role_usr||',';
      END IF;
      WF_DIRECTORY.GetRoleInfo(v_wp_vr.user_name,
                               display_name,
                               email_address,
                               notification_preference,
                               language,
                               territory);

      IF display_name IS NULL THEN
        --Add user to directory
        wf_directory.createadhocuser( name => v_wp_vr.user_name
                                     ,display_name => v_wp_vr.person_name
                                     ,email_address => v_wp_vr.email_address);
      END IF;
      l_wp_viewer_role_usr := l_wp_viewer_role_usr||v_wp_vr.user_name;
    END LOOP;

    IF (l_wp_viewer_role_usr IS NOT NULL) THEN
      --Add the selected user(s) to the role
      wf_directory.adduserstoadhocRole(l_wp_viewer_role
                                      ,l_wp_viewer_role_usr);
      wf_engine.setitemattrtext(p_item_type
                               ,p_item_key
                               ,'WORKPLAN_VIEWER'
                               ,l_wp_viewer_role);
    END IF;

  END set_notification_party;


  procedure show_workplan_preview
  (document_id IN VARCHAR2,
   display_type IN VARCHAR2,
   document IN OUT NOCOPY clob, --File.Sql.39 bug 4440895
   document_type IN OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

  IS

    l_content clob;

    CURSOR get_workplan_preview_info IS
      SELECT page_content
        FROM PA_PAGE_CONTENTS
       WHERE pk1_value = document_id
         AND object_type = 'PA_STRUCTURES'
         AND pk2_value IS NULL;


    l_size number;

    l_chunk_size  pls_integer:=10000;
    l_copy_size int;
    l_pos int := 0;

    l_line varchar2(30000) := '' ; -- Changed the length from 10000 to 30000 for bug 3795807

    -- Bug 3861540
    l_return_status varchar2(1);
    l_msg_count     number;
    l_msg_data      varchar2(2000);

  BEGIN

    open get_workplan_preview_info;
    fetch get_workplan_preview_info into l_content;
    IF (get_workplan_preview_info%FOUND) THEN
      close get_workplan_preview_info;

      -- parse the retrieved clob data
      l_size := dbms_lob.getlength(l_content);


      l_pos := 1;
      l_copy_size := 0;

      while (l_copy_size < l_size) loop

        dbms_lob.read(l_content,l_chunk_size,l_pos,l_line);

        dbms_lob.write(document,l_chunk_size,l_pos,l_line);
        l_copy_size := l_copy_size + l_chunk_size;
        l_pos := l_pos + l_chunk_size;
      end loop;

      --Bug 3861540
      pa_workflow_utils.modify_wf_clob_content(
            p_document                     =>      document
            ,x_return_status               =>  l_return_status
            ,x_msg_count                   =>  l_msg_count
            ,x_msg_data                    =>  l_msg_data
                                  );

      if (l_return_status <>  FND_API.G_RET_STS_SUCCESS) then
              WF_NOTIFICATION.WriteToClob(document, 'Content Generation failed');
              dbms_lob.writeappend(document, 255, substr(Sqlerrm, 255));
      end if;


      --End of Changes Bug 3861540
    ELSE
      close get_workplan_preview_info;
    END IF;

    document_type := 'text/html';

  EXCEPTION
    WHEN OTHERS THEN
      WF_NOTIFICATION.WriteToClob(document, 'Content Generation failed');
      dbms_lob.writeappend(document, 255, substrb(Sqlerrm, 255));  -- changed substr to substrb for bug 3795807
    NULL;
  END show_workplan_preview;
/*=================================================================

Name:         SET_LEAD_DAYS
Type:         Procedure
Description:  This API has been created for giving a flexibility
              to implementing organization to define the task
              execution lead time before which task execution
              workflow process should be started . The project
              identifier,task identifier and the task execution
              workflow item type will be passed to client extension
              so that task execution lead time can be set per task.

IN:
p_item_type     --The internal name for the item type. Item types
                are defined in the Oracle Workflow Builder.
p_task_number   -- Unique identifier of the task for which lead
                 time needs to be set .
p_project_number-- Unique identifier of the project.
x_lead_days     -- Lead Days
=================================================================*/
  PROCEDURE SET_LEAD_DAYS
  (
    p_item_type      IN VARCHAR2 :='PATSKEX'
   ,p_task_number    IN VARCHAR2
   ,p_project_number IN VARCHAR2
   ,x_lead_days      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  )
  IS
/* Important Note : 3961136
   The Task Number and the Project Number are Case-Sensitive.
   The Customer needs to take care of this while Coding.
*/
    CURSOR get_lead_days
      IS
   SELECT ppe.wf_start_lead_days
     FROM pa_proj_elements ppe,
          pa_projects_all pa
     WHERE pa.segment1=p_project_number --Removed Upper() from both sides for Performance Bug Fix 3961136
       AND ppe.element_number = p_task_number --Removed Upper() from both sides for Performance Bug Fix 3961136
       AND pa.project_id = ppe.project_id ;

  BEGIN
    OPEN get_lead_days ;
    FETCH get_lead_days INTO x_lead_days ;
    CLOSE  get_lead_days ;
EXCEPTION
WHEN OTHERS THEN
      RAISE;
END SET_LEAD_DAYS;

end PA_WORKPLAN_WORKFLOW_CLIENT;

/

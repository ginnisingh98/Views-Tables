--------------------------------------------------------
--  DDL for Package Body PA_MASS_ASGMT_TRX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MASS_ASGMT_TRX" AS
-- $Header: PARMATXB.pls 120.4.12010000.4 2010/03/31 10:55:14 nisinha ship $

PROCEDURE start_mass_asgmt_trx_wf
           (p_mode                        IN    VARCHAR2
           ,p_action                      IN    VARCHAR2
           ,p_resource_id_tbl             IN    SYSTEM.pa_num_tbl_type                                 := pa_empty_num_tbl
           ,p_assignment_id_tbl           IN    SYSTEM.pa_num_tbl_type                                 := pa_empty_num_tbl
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
           ,p_max_resource_job_level	  IN    pa_project_assignments.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
           ,p_additional_information      IN    pa_project_assignments.additional_information%TYPE      := FND_API.G_MISS_CHAR
           ,p_append_information_flag     IN    VARCHAR2                                                := 'N'
           ,p_location_id                 IN    pa_project_assignments.location_id%TYPE                 := FND_API.G_MISS_NUM
           ,p_work_type_id                IN    pa_project_assignments.work_type_id%TYPE                := FND_API.G_MISS_NUM
           ,p_calendar_type               IN    pa_project_assignments.calendar_type%TYPE               := FND_API.G_MISS_CHAR
           ,p_calendar_id	          IN    pa_project_assignments.calendar_id%TYPE	                := FND_API.G_MISS_NUM
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
           ,p_revenue_currency_code       IN    pa_project_assignments.revenue_currency_code%TYPE       := FND_API.G_MISS_CHAR
           ,p_revenue_bill_rate           IN    pa_project_assignments.revenue_bill_rate%TYPE           := FND_API.G_MISS_NUM
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
           ,p_enable_auto_cand_nom_flag   IN	pa_project_assignments.enable_auto_cand_nom_flag%TYPE	:= FND_API.G_MISS_CHAR
           ,p_staffing_owner_person_id    IN  pa_project_assignments.staffing_owner_person_id%TYPE      := FND_API.G_MISS_NUM       --FP.L Development
           ,p_staffing_owner_name         IN  per_people_f.full_name%TYPE                               := FND_API.G_MISS_CHAR      --FP.L Development
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
            ,p_approver1_id_tbl           IN    SYSTEM.pa_num_tbl_type                                 := pa_empty_num_tbl
            ,p_approver1_name_tbl         IN    SYSTEM.pa_varchar2_240_tbl_type                        := pa_empty_varchar2_240_tbl
            ,p_approver2_id_tbl           IN    SYSTEM.pa_num_tbl_type                                 := pa_empty_num_tbl
            ,p_approver2_name_tbl         IN    SYSTEM.pa_varchar2_240_tbl_type                        := pa_empty_varchar2_240_tbl
            ,p_appr_over_auth_flag        IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_note_to_all_approvers      IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_competence_id_tbl          IN    SYSTEM.pa_num_tbl_type                                 := pa_empty_num_tbl
            ,p_competence_name_tbl        IN    SYSTEM.pa_varchar2_240_tbl_type                        := pa_empty_varchar2_240_tbl
            ,p_competence_alias_tbl       IN    SYSTEM.pa_varchar2_30_tbl_type                         := pa_empty_varchar2_30_tbl
            ,p_rating_level_id_tbl        IN    SYSTEM.pa_num_tbl_type                                 := pa_empty_num_tbl
            ,p_mandatory_flag_tbl         IN    SYSTEM.pa_varchar2_1_tbl_type                          := pa_empty_varchar2_1_tbl
            ,p_resolve_con_action_code    IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,x_return_status              OUT NOCOPY   VARCHAR2             -- 4537865
)
IS

CURSOR csr_get_tp_amt_type_name (p_tp_amt_type IN VARCHAR2) IS
SELECT plks.meaning
FROM   pa_lookups plks
WHERE  plks.lookup_type = 'TP_AMOUNT_TYPE'
AND    plks.lookup_code = p_tp_amt_type;

l_item_type                 VARCHAR2(8) := 'PARMATRX';
l_item_key                  NUMBER;
l_save_threshold            NUMBER;
l_text_attr_name_tbl        Wf_Engine.NameTabTyp;
l_text_attr_value_tbl       Wf_Engine.TextTabTyp;
l_set_text_attr_name_tbl    Wf_Engine.NameTabTyp;
l_set_text_attr_value_tbl   Wf_Engine.TextTabTyp;
l_num_attr_name_tbl         Wf_Engine.NameTabTyp;
l_num_attr_value_tbl        Wf_Engine.NumTabTyp;
l_set_num_attr_name_tbl     Wf_Engine.NameTabTyp;
l_set_num_attr_value_tbl    Wf_Engine.NumTabTyp;
l_date_attr_name_tbl        Wf_Engine.NameTabTyp;
l_date_attr_value_tbl       Wf_Engine.DateTabTyp;
l_set_date_attr_name_tbl    Wf_Engine.NameTabTyp;
l_set_date_attr_value_tbl   Wf_Engine.DateTabTyp;
l_err_code                  fnd_new_messages.message_name%TYPE;
l_err_stage                 VARCHAR2(2000);
l_err_stack                 VARCHAR2(2000);
l_object_id_tbl             SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_approver1_id_tbl          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_approver1_name_tbl        SYSTEM.pa_varchar2_240_tbl_type := SYSTEM.pa_varchar2_240_tbl_type();
l_approver2_id_tbl          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_approver2_name_tbl        SYSTEM.pa_varchar2_240_tbl_type := SYSTEM.pa_varchar2_240_tbl_type();
l_project_id                pa_projects_all.project_id%TYPE;
l_fcst_tp_amount_type_name  VARCHAR2(80);
/* Commented for bug 9114634
----Added following folloeing for bug 6199871   ------------------------
l_apprvl_status_code           PA_PROJECT_ASSIGNMENTS.APPRVL_STATUS_CODE%TYPE;
l_change_id                        NUMBER;
l_record_version_number    NUMBER;
l_return_status                   VARCHAR2(1);
l_msg_count                       NUMBER;
l_msg_data                        VARCHAR2(2000);
------------------------------------------------------------------------
*/
BEGIN

   --initialize return status to Success
   x_return_status    := FND_API.G_RET_STS_SUCCESS;

   -- Setting thresold value to run the process in background
   l_save_threshold      := wf_engine.threshold;

   IF wf_engine.threshold < 0 THEN
      wf_engine.threshold := l_save_threshold;
   END IF;
   wf_engine.threshold := -1;

   --get item key
   SELECT pa_mass_asgmt_trx_wf_s.nextval
     INTO l_item_key
     FROM dual;

/* Commented for bug 9114634
    ---------------------------------------------------------------------------
    --  Bug Ref # 6199871
    --  Changing Approval Status to Submitted for each Assignment
    --  Record version Id is passes as 1,as it will be populated inside
    --  the API to the correct one which is queried from
    --  'pa_project_assignments' for the Given Assignment id.
    ---------------------------------------------------------------------------
   IF p_assignment_id_tbl.COUNT > 0 THEN
          FOR i IN p_assignment_id_tbl.FIRST .. p_assignment_id_tbl.LAST LOOP
	     PA_ASSIGNMENT_APPROVAL_PVT.Update_Approval_Status(
	     p_assignment_id        => p_assignment_id_tbl(i)
            ,p_action_code          => p_action
            ,p_note_to_approver     => p_note_to_all_approvers
            ,p_record_version_number=> 1
   	    ,x_apprvl_status_code   => l_apprvl_status_code
   	    ,x_change_id            => l_change_id
            ,x_record_version_number=> l_record_version_number
   	    ,x_return_status        => l_return_status
            ,x_msg_count            => l_msg_count
            ,x_msg_data             => l_msg_data);

	  END LOOP;
     END IF;
     --------------------------------------------------------------------------
*/
    -- Creating the work flow process
    WF_ENGINE.CreateProcess( itemtype => l_item_type,
                             itemkey  => l_item_key,
                             process  => 'PA_MASS_ASGMT_TRX_WF') ;

    --if project id is not passed (could only happen when adding a delivery or
    --an admin assignment from the resource context) then get the project id
    --from the project number.  Project number is required.
    IF p_project_id IS NULL OR p_project_id = FND_API.G_MISS_NUM THEN
       SELECT project_id INTO l_project_id
         FROM pa_projects_all
        WHERE segment1 = p_project_number;
    ELSE
       l_project_id := p_project_id;
    END IF;

    --insert a record for this wf into the pa_wf_processes table.
    PA_WORKFLOW_UTILS.Insert_WF_Processes
              (p_wf_type_code        => p_mode
              ,p_item_type           => l_item_type
      	      ,p_item_key            => to_char(l_item_key)
              ,p_entity_key1         => to_char(l_project_id)
      	      ,p_description         => p_mode
              ,p_err_code            => l_err_code
              ,p_err_stage           => l_err_stage
              ,p_err_stack           => l_err_stack);


     --store all attributes in text, number, or date plsql tables depending on their
     --datatype.  One table for the names of the attributes, and one for the value.
     --the name/value tables will be used to dynamically create the workflow item attributes.

     l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'MODE';
     l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_mode;

     l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'ACTION';
     l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_action;

     --if this is a mass assignment then assign the resource id tbl to the object id tbl.
     --otherwise assign the assignment id tbl to the object di tbl.
     IF p_mode = G_MASS_ASGMT AND p_resource_id_tbl.COUNT > 0 THEN

        l_object_id_tbl := p_resource_id_tbl;

     ELSIF p_assignment_id_tbl.COUNT > 0 THEN

         l_object_id_tbl := p_assignment_id_tbl;

     END IF;

     --if this is SAVE action then there are no approvers, so
     --need to extend these plsql tables so that the bulk insert
     --below will not fail
     --if it is in SAVE_AND_SUBMIT or SUBMIT action then assign
     --the approver tables IN parameters to the local variables.
     IF p_action = G_SAVE THEN
        l_approver1_id_tbl.EXTEND(l_object_id_tbl.COUNT);
        l_approver2_id_tbl.EXTEND(l_object_id_tbl.COUNT);
        l_approver1_name_tbl.EXTEND(l_object_id_tbl.COUNT);
        l_approver2_name_tbl.EXTEND(l_object_id_tbl.COUNT);
     ELSE
        l_approver1_id_tbl   := p_approver1_id_tbl;
        l_approver1_name_tbl := p_approver1_name_tbl;
        l_approver2_id_tbl   := p_approver2_id_tbl;
        l_approver2_name_tbl := p_approver2_name_tbl;
     END IF;

     --if there are any object ids then insert the wf process details.
     IF l_object_id_tbl.COUNT > 0 THEN
        FORALL i IN l_object_id_tbl.FIRST .. l_object_id_tbl.LAST
           INSERT INTO pa_wf_process_details(wf_type_code,
                                             item_type,
                                             item_key,
                                             object_id1,
                                             process_status_code,
                                             source_attribute1,
                                             source_attribute2,
                                             source_attribute3,
                                             source_attribute4,
                                             last_update_date,
		                             last_updated_by,
		                             creation_date,
                                             created_by,
                                             last_update_login
                                            )
                                             VALUES
                                            (p_mode,
                                             l_item_type,
                                             to_char(l_item_key),
                                             l_object_id_tbl(i),
                                             'P',
                                             decode(p_action, G_SAVE, NULL, to_char(l_approver1_id_tbl(i))),
                                             decode(p_action, G_SAVE, NULL, l_approver1_name_tbl(i)),
                                             decode(p_action, G_SAVE, NULL, to_char(l_approver2_id_tbl(i))),
                                             decode(p_action, G_SAVE, NULL, l_approver2_name_tbl(i)),
                                             sysdate,
                                             fnd_global.user_id,
                                             sysdate,
                                             fnd_global.user_id,
                                             fnd_global.login_id
   		 	                    );

     END IF;

     l_set_num_attr_name_tbl(l_set_num_attr_name_tbl.COUNT+1)  := 'NUMBER_OF_RESOURCES';
     l_set_num_attr_value_tbl(l_set_num_attr_value_tbl.COUNT+1) := l_object_id_tbl.COUNT;

     l_set_num_attr_name_tbl(l_set_num_attr_name_tbl.COUNT+1)  := 'NUMBER_OF_ASSIGNMENTS';
     l_set_num_attr_value_tbl(l_set_num_attr_value_tbl.COUNT+1) := l_object_id_tbl.COUNT;

     -- p_project_id should be used here instead of l_project_id because
     -- p_project_id = null case must be handled in Create_Assignment API to
     -- get additional default attributes from project when the project
     -- number lov is not used.
     l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'PROJECT_ID';
     l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_project_id;

     --store the following attributes in the name/value plsql tables if mode
     --is Mass Assignment or Mass Update Basic Information.
     IF p_mode = G_MASS_ASGMT or p_mode = G_MASS_UPDATE_ASGMT_BASIC_INFO  THEN

       --this attribute is not dynamically created because it will be displayed
       --in the notification so it must be created as a workflow attribute at
       --design time.
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1)  := 'ASSIGNMENT_NAME';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := p_assignment_name;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'ASSIGNMENT_TYPE';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_assignment_type;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'STATUS_CODE';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_status_code;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'MULTIPLE_STATUS_FLAG';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_multiple_status_flag;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'STAFFING_PRIORITY_CODE';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_staffing_priority_code;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'PROJECT_ROLE_ID';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_project_role_id;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'ROLE_LIST_ID';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_role_list_id;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'WORK_TYPE_ID';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_work_type_id;

       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1)  := 'WORK_TYPE_NAME';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := p_work_type_name;

       -- FP.L Development: Passing Staffing Owner Id
       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'STAFFING_OWNER_PERSON_ID';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_staffing_owner_person_id;

       -- FP.L Development: Passing Staffing Owner Name
       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'STAFFING_OWNER_NAME';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_staffing_owner_name;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'PROJECT_SUBTEAM_ID';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_project_subteam_id;

       --this attribute is not dynamically created because it will be displayed
       --in the notification so it must be created as a workflow attribute at
       --design time.
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1)  := 'DESCRIPTION';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := p_description;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'APPEND_DESCRIPTION_FLAG';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_append_description_flag;

       l_set_date_attr_name_tbl(l_set_date_attr_name_tbl.COUNT+1)  := 'START_DATE';
       l_set_date_attr_value_tbl(l_set_date_attr_value_tbl.COUNT+1) := p_start_date;

       l_set_date_attr_name_tbl(l_set_date_attr_name_tbl.COUNT+1)  := 'END_DATE';
       l_set_date_attr_value_tbl(l_set_date_attr_value_tbl.COUNT+1) := p_end_date;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'EXTENSION_POSSIBLE';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_extension_possible;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'MIN_RESOURCE_JOB_LEVEL';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_min_resource_job_level;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'MAX_RESOURCE_JOB_LEVEL';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_max_resource_job_level;

       --this attribute is not dynamically created because it will be displayed
       --in the notification so it must be created as a workflow attribute at
       --design time.
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1)  := 'ADDITIONAL_INFORMATION';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := p_additional_information;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'APPEND_INFORMATION_FLAG';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_append_information_flag;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'LOCATION_ID';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_location_id;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'CALENDAR_TYPE';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_calendar_type;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'CALENDAR_ID';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_calendar_id;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'RESOURCE_CALENDAR_PERCENT';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_resource_calendar_percent;

       --this attribute is not dynamically created because it will be displayed
       --in the notification so it must be created as a workflow attribute at
       --design time.
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1)  := 'PROJECT_NAME';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := p_project_name;

       --this attribute is not dynamically created because it will be displayed
       --in the notification so it must be created as a workflow attribute at
       --design time.
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1)  := 'PROJECT_NUMBER';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := p_project_number;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'PROJECT_SUBTEAM_NAME';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_project_subteam_name;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'PROJECT_STATUS_NAME';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_project_status_name;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'STAFFING_PRIORITY_NAME';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_staffing_priority_name;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'PROJECT_ROLE_NAME';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_project_role_name;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'LOCATION_CITY';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_location_city;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'LOCATION_REGION';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_location_region;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'LOCATION_COUNTRY_NAME';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_location_country_name;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'LOCATION_COUNTRY_CODE';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_location_country_code;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'CALENDAR_NAME';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_calendar_name;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'EXPENSE_OWNER';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_expense_owner;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'EXPENSE_LIMIT';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_expense_limit;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'EXPENSE_LIMIT_CURRENCY_CODE';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_expense_limit_currency_code;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'COMP_MATCH_WEIGHTING';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_comp_match_weighting;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'AVAIL_MATCH_WEIGHTING';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_avail_match_weighting;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'JOB_LEVEL_MATCH_WEIGHTING';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_job_level_match_weighting;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'SEARCH_MIN_AVAILABILITY';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_search_min_availability;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'SEARCH_COUNTRY_CODE';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_search_country_code;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'SEARCH_COUNTRY_NAME';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_search_country_name;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'SEARCH_EXP_ORG_STRUCT_VER_ID';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_search_exp_org_struct_ver_id;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'SEARCH_EXP_ORG_HIER_NAME';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_search_exp_org_hier_name;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'SEARCH_EXP_START_ORG_ID';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_search_exp_start_org_id;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'SEARCH_EXP_START_ORG_NAME';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_search_exp_start_org_name;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'SEARCH_MIN_CANDIDATE_SCORE';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_search_min_candidate_score;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'ENABLE_AUTO_CAND_NOM_FLAG';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_enable_auto_cand_nom_flag;

       l_set_num_attr_name_tbl(l_set_num_attr_name_tbl.COUNT+1) := 'REVENUE_BILL_RATE';
       l_set_num_attr_value_tbl(l_set_num_attr_value_tbl.COUNT+1) := p_revenue_bill_rate;
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'REVENUE_BILL_RATE_CURR';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := p_revenue_currency_code;

       IF p_fcst_tp_amount_type IS NOT NULL THEN
          open csr_get_tp_amt_type_name(p_fcst_tp_amount_type);
          fetch csr_get_tp_amt_type_name into l_fcst_tp_amount_type_name;
          close csr_get_tp_amt_type_name;
       END IF;

       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'TP_AMT_TYPE_NAME';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_fcst_tp_amount_type_name;

    --store the following attributes in the name/value plsql tables if mode
    --is Mass Update Forecast Items
    ELSIF p_mode = G_MASS_UPDATE_FORECAST_ITEMS THEN

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'WORK_TYPE_ID';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_work_type_id;

       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1)  := 'WORK_TYPE_NAME';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := p_work_type_name;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'FCST_TP_AMOUNT_TYPE';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_fcst_tp_amount_type;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'FCST_JOB_ID';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_fcst_job_id;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'FCST_JOB_GROUP_ID';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_fcst_job_group_id;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'EXPENDITURE_ORG_ID';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_expenditure_org_id;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'EXPENDITURE_ORGANIZATION_ID';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_expenditure_organization_id;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'EXPENDITURE_TYPE_CLASS';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_expenditure_type_class;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'EXPENDITURE_TYPE';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_expenditure_type;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'FCST_JOB_NAME';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_fcst_job_name;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'FCST_JOB_GROUP_NAME';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_fcst_job_group_name;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'EXPENDITURE_ORG_NAME';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_expenditure_org_name;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'EXP_ORGANIZATION_NAME';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_exp_organization_name;

    --store the following attributes in the name/value plsql tables if mode
    --is Mass Update Schedule
    ELSIF p_mode = G_MASS_UPDATE_SCHEDULE THEN

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'EXCEPTION_TYPE_CODE';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_exception_type_code;

       l_date_attr_name_tbl(l_date_attr_name_tbl.COUNT+1)  := 'CHANGE_START_DATE';
       l_date_attr_value_tbl(l_date_attr_value_tbl.COUNT+1) := p_change_start_date;

       l_date_attr_name_tbl(l_date_attr_name_tbl.COUNT+1)  := 'CHANGE_END_DATE';
       l_date_attr_value_tbl(l_date_attr_value_tbl.COUNT+1) := p_change_end_date;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'CHANGE_RQMT_STATUS_CODE';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_change_rqmt_status_code;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'CHANGE_ASGMT_STATUS_CODE';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_change_asgmt_status_code;

       IF (p_exception_type_code = 'CHANGE_WORK_PATTERN') THEN
         IF (p_change_start_date_tbl.COUNT > 0) THEN
           FOR j IN p_change_start_date_tbl.FIRST .. p_change_end_date_tbl.LAST LOOP

             l_date_attr_name_tbl(l_date_attr_name_tbl.COUNT+1)  := 'CHANGE_START_DATE'||j;
             l_date_attr_value_tbl(l_date_attr_value_tbl.COUNT+1) := p_change_start_date_tbl(j);

             l_date_attr_name_tbl(l_date_attr_name_tbl.COUNT+1)  := 'CHANGE_END_DATE'||j;
             l_date_attr_value_tbl(l_date_attr_value_tbl.COUNT+1) := p_change_end_date_tbl(j);

             l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'MONDAY_HOURS'||j;
             l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_monday_hours_tbl(j);

             l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'TUESDAY_HOURS'||j;
             l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_tuesday_hours_tbl(j);

             l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'WEDNESDAY_HOURS'||j;
             l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_wednesday_hours_tbl(j);

             l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'THURSDAY_HOURS'||j;
             l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_thursday_hours_tbl(j);

             l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'FRIDAY_HOURS'||j;
             l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_friday_hours_tbl(j);

             l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'SATURDAY_HOURS'||j;
             l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_saturday_hours_tbl(j);

             l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'SUNDAY_HOURS'||j;
             l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_sunday_hours_tbl(j);
           END LOOP;
         END IF;
       END IF;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'NUM_OF_SCH_PERIODS';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_change_start_date_tbl.COUNT;
       -- END IF;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'NON_WORKING_DAY_FLAG';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_non_working_day_flag;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'CHANGE_HOURS_TYPE_CODE';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_change_hours_type_code;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'HRS_PER_DAY';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_hrs_per_day;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'CALENDAR_PERCENT';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_calendar_percent;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'CHANGE_CALENDAR_TYPE_CODE';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_change_calendar_type_code;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'CHANGE_CALENDAR_NAME';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_change_calendar_name;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'CHANGE_CALENDAR_ID';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_change_calendar_id;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'DURATION_SHIFT_TYPE_CODE';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_duration_shift_type_code;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'DURATION_SHIFT_UNIT_CODE';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_duration_shift_unit_code;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'NUM_OF_SHIFT';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_num_of_shift;

    --store the following attributes in the name/value plsql tables if mode
    --is Mass Update Competencies
    ELSIF p_mode = G_MASS_UPDATE_COMPETENCIES THEN

       IF p_competence_id_tbl.COUNT > 0 THEN
          FOR i IN p_competence_id_tbl.FIRST .. p_competence_id_tbl.LAST LOOP
             l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'COMPETENCE_ID'||i;
             l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_competence_id_tbl(i);
             l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'COMPETENCE_NAME'||i;
             l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_competence_name_tbl(i);
             l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'COMPETENCE_ALIAS'||i;
             l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_competence_alias_tbl(i);
             l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'RATING_LEVEL_ID'||i;
             l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_rating_level_id_tbl(i);
             l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'MANDATORY_FLAG'||i;
             l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_mandatory_flag_tbl(i);
          END LOOP;
        END IF;

       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'NUMBER_OF_COMPETENCIES';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := p_competence_id_tbl.COUNT;

    END IF;

    --store the following attributes in the name/value plsql tables if mode
    --is  Mass Submit for Approval, or if action is save and SUBMIT - which
    --means the assignment will be submitted for approval after the create/update
    --is performed.
    IF p_mode = G_MASS_SUBMIT_FOR_APPROVAL OR p_action = G_SAVE_AND_SUBMIT THEN

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1) := 'APPR_OVER_AUTH_FLAG';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_appr_over_auth_flag;

       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'NOTE_TO_ALL_APPROVERS';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_note_to_all_approvers;

    END IF;

    l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1)  := 'RESOLVE_CONFLICT_ACTION_CODE';
    l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := p_resolve_con_action_code;

    --set the item attribute for the Submitter - this is who will receive the notification.
    --this attribute is not dynamically created because this attribute is the
    --notification performer - and the performer attribute must be included as a
    --workflow item attribute at design time.
    l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1)  := 'SUBMITTER_USER_NAME';
    l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := FND_GLOBAL.user_name;

    l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'SUBMITTER_USER_ID';
    l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := FND_GLOBAL.user_id;

    l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'SUBMITTER_RESP_ID';
    l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := FND_GLOBAL.resp_id;

    l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1)  := 'SUBMITTER_RESP_APPL_ID';
    l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := FND_GLOBAL.resp_appl_id;

    --dynamically create and set the Text item attributes
    WF_ENGINE.AddItemAttrTextArray(itemtype => l_item_type,
                                   itemkey  => l_item_key,
                                   aname    => l_text_attr_name_tbl,
                                   avalue   => l_text_attr_value_tbl);

    --dynamically create and set the Number item attributes
    WF_ENGINE.AddItemAttrNumberArray(itemtype => l_item_type,
                                   itemkey  => l_item_key,
                                   aname    => l_num_attr_name_tbl,
                                   avalue   => l_num_attr_value_tbl);

    --dynamically create and set the Date item attributes
    WF_ENGINE.AddItemAttrDateArray(itemtype => l_item_type,
                                   itemkey  => l_item_key,
                                   aname    => l_date_attr_name_tbl,
                                   avalue   => l_date_attr_value_tbl);

    --SET the Text item attributes (these attributes were created at design time)
    WF_ENGINE.SetItemAttrTextArray(itemtype => l_item_type,
                                   itemkey  => l_item_key,
                                   aname    => l_set_text_attr_name_tbl,
                                   avalue   => l_set_text_attr_value_tbl);

    --SET the Number item attributes (these attributes were created at design time)
    WF_ENGINE.SetItemAttrNumberArray(itemtype => l_item_type,
                                   itemkey  => l_item_key,
                                   aname    => l_set_num_attr_name_tbl,
                                   avalue   => l_set_num_attr_value_tbl);

    --SET the Date item attributes
    WF_ENGINE.SetItemAttrDateArray(itemtype => l_item_type,
                                   itemkey  => l_item_key,
                                   aname    => l_set_date_attr_name_tbl,
                                   avalue   => l_set_date_attr_value_tbl);


      -- start the workflow process
      WF_ENGINE.StartProcess( itemtype => l_item_type,
                              itemkey  => l_item_key);

      --Setting the original value
      wf_engine.threshold := l_save_threshold;

    --if this is a mass update then set the mass_wf_in_progress_flag to 'Y'
    --in pa_project_assignments.  This is a bulk update for all assignments being updated.
    IF p_mode <> G_MASS_ASGMT THEN

       FORALL i in p_assignment_id_tbl.FIRST .. p_assignment_id_tbl.LAST
         UPDATE pa_project_assignments
            SET mass_wf_in_progress_flag = 'Y'
          WHERE assignment_id = p_assignment_id_tbl(i);

    END IF;

EXCEPTION
   WHEN OTHERS THEN

     --Setting the original value
      wf_engine.threshold := l_save_threshold;

     -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'pa_mass_asgmt_trx.start_mass_asgmt_trx_wf'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END start_mass_asgmt_trx_wf;

PROCEDURE mass_asgmt_trx_wf
            (p_item_type     IN        VARCHAR2,
             p_item_key      IN        VARCHAR2,
             p_actid         IN        NUMBER,
             p_funcmode      IN        VARCHAR2,
             p_result        OUT NOCOPY      VARCHAR2) -- 4537865

IS

l_mode                          VARCHAR2(30);
l_action                        VARCHAR2(30);
l_assignment_id_tbl             SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_resource_id_tbl               SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_object_id_tbl                 SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_success_assignment_id_tbl     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_asgmt_overcom_id_tbl          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_project_id                    pa_project_assignments.project_id%TYPE;
l_start_date                    pa_project_assignments.start_date%TYPE;
l_end_date                      pa_project_assignments.end_date%TYPE;
l_project_name                  pa_projects_all.name%TYPE;
l_project_number                pa_projects_all.segment1%TYPE;
l_success_assignments           NUMBER := 0;
l_failure_assignments           NUMBER := 0;
l_text_attr_name_tbl            Wf_Engine.NameTabTyp;
l_text_attr_value_tbl           Wf_Engine.TextTabTyp;
l_num_attr_name_tbl             Wf_Engine.NameTabTyp;
l_num_attr_value_tbl            Wf_Engine.NumTabTyp;
l_add_num_attr_name_tbl         Wf_Engine.NameTabTyp;
l_add_num_attr_value_tbl        Wf_Engine.NumTabTyp;
l_project_organization          pa_project_lists_v.CARRYING_OUT_ORGANIZATION_NAME%TYPE;
l_project_customer              pa_project_lists_v.customer_name%TYPE;
l_project_manager               pa_project_lists_v.person_name%TYPE;
l_err_code                      VARCHAR2(2000);
l_err_stage                     VARCHAR2(2000);
l_err_stack                     VARCHAR2(2000);
l_return_status                 VARCHAR2(1);
l_msg_count                     NUMBER;
l_msg_data                      fnd_new_messages.message_text%TYPE;
l_success_assignments_link      VARCHAR2(2000);
l_failure_assignments_link      VARCHAR2(2000);
l_assignment_duration           NUMBER;
l_result                        VARCHAR2(2000);
l_number_of_resources           NUMBER;
l_number_of_assignments         NUMBER;
l_any_success_assignment_id     NUMBER;
l_assignment_effort             NUMBER;
l_first_assignment_id           NUMBER;
l_document                      VARCHAR2(32767);
l_conflict_group_id             NUMBER;
l_overcommitment_flag           VARCHAR2(1);
l_resolve_con_action_code       pa_lookups.meaning%TYPE;
l_view_conflicts_link           VARCHAR2(2000);
l_conf_asgmt_count              NUMBER;
l_message_name                  fnd_new_messages.message_name%TYPE;
l_view_conf_action_text         fnd_new_messages.message_text%TYPE;
l_calling_page                  VARCHAR2(30);

----Added following code for bug 6199871 and 9114634-----------------------
l_apprvl_status_code           PA_PROJECT_ASSIGNMENTS.APPRVL_STATUS_CODE%TYPE;
l_change_id                        NUMBER;
l_record_version_number            NUMBER;
l_note_to_all_approvers           VARCHAR(2000);
l_success_assignment_id_tbl2     SYSTEM.pa_num_tbl_type ;
----Added following code for bug 6199871 and 9114634-----------------------


TYPE success_failure_count_tbl  IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;
l_success_failure_count_tbl     success_failure_count_tbl;

BEGIN

--initialize the message sta.
FND_MSG_PUB.initialize;

IF (p_funcmode = 'RUN') THEN

   --Initialize the p_result to NONE - no notification will be sent.
   p_result := 'NONE';

   --bulk collect the pending resource or assignment ids for this mass transaction.
   SELECT object_id1 BULK COLLECT INTO l_object_id_tbl
     FROM pa_wf_process_details
    WHERE item_type = p_item_type
      AND item_key = p_item_key
      AND process_status_code = 'P';

    l_mode :=                       WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                              itemkey  => p_item_key,
                                                              aname    => 'MODE');

     --if this is a mass assignment then assign the resource id tbl to the object id tbl.
     --otherwise assign the assignment id tbl to the object id tbl.
    IF l_mode = G_MASS_ASGMT THEN

       l_resource_id_tbl := l_object_id_tbl;

    ELSE

       l_assignment_id_tbl := l_object_id_tbl;

    END IF;

   --during a mass asgmt/update, the assignments created/updated will be
   --committed if successful/rolled back if any errors - ONE AT A TIME.
   --no commits are allowed in the workflow transaction, so call this
   --API which will start an autonomous transaction.
   --pa_wf_process_details.process_status_code will be updated inside
   --the autonomous transaction
   PA_MASS_ASGMT_TRX.mass_asgmt_autonomous_trx
         (p_item_type                 => p_item_type,
          p_item_key                  => p_item_key,
          p_actid                     => p_actid,
          p_funcmode                  => p_funcmode,
          p_resource_id_tbl           => l_resource_id_tbl,
          p_assignment_id_tbl         => l_assignment_id_tbl,
          x_mode                      => l_mode,
          x_action                    => l_action,
          x_start_date                => l_start_date,
          x_end_date                  => l_end_date,
          x_project_id                => l_project_id,
          x_document                  => l_document);

      --get the number of success/failure assignments
      SELECT sum(decode(process_status_code, 'S', 1,0)),
             sum(decode(process_status_code, 'A', 1, 'E', 1, 0))
        INTO l_success_assignments,
             l_failure_assignments
        FROM pa_wf_process_details
       WHERE item_type = p_item_type
         AND item_key = p_item_key;

   --if the mass trx is submitted for approval and any assignments were
   --successfully created / updated then do the following to
   --check overcommitment.
   IF l_action <> G_SAVE AND l_success_assignments > 0 THEN

      l_resolve_con_action_code :=   WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                           itemkey  => p_item_key,
                                                           aname    => 'RESOLVE_CONFLICT_ACTION_CODE');


      PA_SCHEDULE_PVT.Check_Overcommitment_Mult
         (
          p_item_type                      =>  p_item_type,
          p_item_key                       =>  p_item_key,
          p_resolve_conflict_action_code   =>  l_resolve_con_action_code,
          p_conflict_group_id              =>  NULL,
          x_overcommitment_flag            =>  l_overcommitment_flag,
          x_conflict_group_id              =>  l_conflict_group_id,
          x_return_status                  =>  l_return_status,
          x_msg_count                      =>  l_msg_count,
          x_msg_data                       =>  l_msg_data);

       l_add_num_attr_name_tbl(l_add_num_attr_name_tbl.COUNT+1) := 'CONFLICT_GROUP_ID';
       l_add_num_attr_value_tbl(l_add_num_attr_value_tbl.COUNT+1) := l_conflict_group_id;

   END IF;

      --store the num success assignment in the plsql table which will be used
      --to bulk set the workflow item attributes to be displayed in the notification.
      l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1) := 'NUM_SUCCESS_ASSIGNMENTS';
      l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := l_success_assignments;

      --if any assignments were processed successfully...
      IF l_success_assignments > 0 THEN

          --if this is a mass assign then get the assignment effort and
          --store it in the name/value plsql tables to be displayed in the
          --notification.
          --this can ONLY be done if there was at least one successfully created assignment
          --as the assignment needs to be in the database for assignment effort to
          --be calculated.
          IF l_mode = G_MASS_ASGMT THEN

             SELECT assignment_id INTO l_any_success_assignment_id
               FROM pa_mass_txn_asgmt_success_v
              WHERE item_type = p_item_type
                AND item_key= p_item_key
                AND ROWNUM = 1;

              l_assignment_effort := PA_SCHEDULE_UTILS.get_num_hours(
                                                p_project_id    => l_project_id,
                                                p_assignment_id => l_any_success_assignment_id);

              l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1) := 'ASSIGNMENT_EFFORT';
              l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := l_assignment_effort;

          END IF;

       END IF;

      --store the num failure assignments in the plsql table which will be used
      --to bulk set the workflow item attributes to be displayed in the notification.
       l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1) := 'NUM_FAILURE_ASSIGNMENTS';
       l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := l_failure_assignments;

       --link to view errors page from the notification
       l_failure_assignments_link := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275'||'&'||'akRegionCode=PA_ERROR_LAYOUT'||'&'||'paProjectId='||l_project_id||'&'||'paSrcType1=MASS_ASSIGNMENT_TRANSACTION'
       ||'&'||'paSrcType2='||l_mode||'&'||'paSrcId1='||PA_MASS_ASGMT_TRX.G_WORKFLOW_ITEM_TYPE||'&'||'paSrcId2='||PA_MASS_ASGMT_TRX.G_WORKFLOW_ITEM_KEY||'&'||'addBreadCrumb=RP';

       --store the failure assignments link the the name/value plsql tables.
       l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1) := 'FAILURE_ASSIGNMENTS_LINK';
       l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := l_failure_assignments_link;

       --if there were any assignments not processed successfully...
       IF l_failure_assignments > 0 THEN
          --if there were any assignment failures then set the p_result
          --accordingly based on the mode,  either create or update.
          --Currently a notification is only sent to the submitter if there are any
          --errors -so a notification will be sent if p_result is either of the following.
          IF l_mode = G_MASS_ASGMT THEN
             IF l_overcommitment_flag = 'Y' AND l_resolve_con_action_code = 'NOTIFY_IF_CONFLICT' THEN
                p_result := 'CREATE_ASGMT_FAIL_OC';
             ELSE
                p_result := 'CREATE_ASGMT_FAILURE';
             END IF;
          ELSIF l_mode = G_MASS_SUBMIT_FOR_APPROVAL THEN
            IF l_overcommitment_flag = 'Y' AND l_resolve_con_action_code = 'NOTIFY_IF_CONFLICT' THEN
                p_result := 'SUBMIT_ASGMT_FAILURE_OC';
             ELSE
                p_result := 'SUBMIT_ASSIGNMENT_FAILURE';
             END IF;
          ELSE
             IF l_overcommitment_flag = 'Y' AND l_resolve_con_action_code = 'NOTIFY_IF_CONFLICT' THEN
                p_result := 'UPDATE_ASGMT_FAIL_OC';
             ELSE
                p_result := 'UPDATE_ASGMT_FAILURE';
             END IF;
          END IF;

       --if there were no assignment failures then set the p_result
       --accordingly based on the mode,  either create or update.
       ELSE
          IF l_mode = G_MASS_ASGMT THEN
            IF l_overcommitment_flag = 'Y' AND l_resolve_con_action_code = 'NOTIFY_IF_CONFLICT' THEN
                p_result := 'CREATE_ASGMT_SUCCESS_OC';
             ELSE
                p_result := 'CREATE_ASGMT_SUCCESS';
             END IF;
          ELSIF l_mode = G_MASS_SUBMIT_FOR_APPROVAL THEN
            IF l_overcommitment_flag = 'Y' AND l_resolve_con_action_code = 'NOTIFY_IF_CONFLICT' THEN
                p_result := 'SUBMIT_ASGMT_SUCCESS_OC';
             ELSE
                p_result := 'SUBMIT_ASSIGNMENT_SUCCESS';
             END IF;
          ELSE
             IF l_overcommitment_flag = 'Y' AND l_resolve_con_action_code = 'NOTIFY_IF_CONFLICT' THEN
                p_result := 'UPDATE_ASGMT_SUCCESS_OC';
             ELSE
                p_result := 'UPDATE_ASGMT_SUCCESS';
             END IF;
          END IF;

       END IF;

     IF (l_mode = G_MASS_SUBMIT_FOR_APPROVAL OR l_action = G_SAVE_AND_SUBMIT) AND    -- Bug 9430922
        l_success_assignments > 0 THEN
     -- Bug 9114634
     l_note_to_all_approvers := WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                  itemkey  => p_item_key,
                                                                  aname    => 'NOTE_TO_ALL_APPROVERS');
     END IF;

     -- Bug 9114634. Change of placement.
     if l_success_assignments > 0 THEN
  -- bug#9464279
SELECT pmt.assignment_id BULK COLLECT INTO l_success_assignment_id_tbl2
FROM pa_mass_txn_asgmt_success_v pmt,
pa_project_assignments ppa
WHERE pmt.item_type = p_item_type
AND pmt.item_key= p_item_key
and pmt.assignment_id= ppa.assignment_id
and ppa.assignment_type in ('STAFFED_ASSIGNMENT','STAFFED_ADMIN_ASSIGNMENT');
  -- bug#9464279
       ---------------------------------------------------------------------------
    --  Bug Ref # 6199871
    --  Changing Approval Status to Submitted for each Assignment
    --  Record version Id is passes as 1,as it will be populated inside
    --  the API to the correct one which is queried from
    --  'pa_project_assignments' for the Given Assignment id.
    ---------------------------------------------------------------------------
      IF l_success_assignment_id_tbl2.COUNT > 0 THEN
          FOR i IN l_success_assignment_id_tbl2.FIRST .. l_success_assignment_id_tbl2.LAST LOOP
	     PA_ASSIGNMENT_APPROVAL_PVT.Update_Approval_Status(
	     p_assignment_id        => l_success_assignment_id_tbl2(i)
            ,p_action_code          => l_action
            ,p_note_to_approver     => l_note_to_all_approvers
            ,p_record_version_number=> 1
   	    ,x_apprvl_status_code   => l_apprvl_status_code
   	    ,x_change_id            => l_change_id
            ,x_record_version_number=> l_record_version_number
   	    ,x_return_status        => l_return_status
            ,x_msg_count            => l_msg_count
            ,x_msg_data             => l_msg_data);

	    END LOOP;
       END IF;
     --------------------------------------------------------------------------
     END IF;

       --if this is a mass assign then calculate the assignment duration and
       --store in the name/value plsql tables.
       IF l_mode = G_MASS_ASGMT THEN

          l_assignment_duration := l_end_date - l_start_date +1;

          l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1) := 'ASSIGNMENT_DURATION';
          l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := l_assignment_duration;

       END IF;

       --if project id was not passed to the start wf API then get the project
       --id from the assignment.  When creating an assignment project id will always
       --be passed - it could only be an update case.  We want to show the project info
       --in the notification even if none of the updates were successful - so get the
       --first assignment id and use it to get the project id.
       --l_success_assignment_id_tbl only has successful assignments

       IF l_project_id IS NULL or l_project_id = FND_API.G_MISS_NUM THEN

          SELECT project_id
            INTO l_project_id
            FROM pa_project_assignments
           WHERE assignment_id = l_assignment_id_tbl(1);

        END IF;

       --get the project attributes to be displayed in the notification.
       -- Commented for SQL ID 14910543 Bug 4918687
       -- SELECT proj.name,
       --       proj.segment1,
       --       proj.CARRYING_OUT_ORGANIZATION_NAME,
       --       proj.person_name,
       --       proj.customer_name
       --  INTO l_project_name,
       --       l_project_number,
       --       l_project_organization,
       --       l_project_manager,
       --       l_project_customer
       --  FROM pa_project_lists_v proj
       -- WHERE project_id = l_project_id;

	-- Added for Perf fix 4918687 SQL ID 14910543
	SELECT proj.name,
	      proj.segment1,
	      pa_resource_utils.get_organization_name(proj.carrying_out_organization_id) CARRYING_OUT_ORGANIZATION_NAME ,
	      pa_project_parties_utils.get_project_manager_name(proj.project_id) person_name,
	      pa_projects_maint_utils.get_primary_customer_name(proj.project_id) customer_name
	INTO  l_project_name,
	      l_project_number,
	      l_project_organization,
	      l_project_manager,
	      l_project_customer
	FROM  pa_projects_all proj
	WHERE project_id  = l_project_id;

        --store the project attributes in the name/value plsql tables.
        l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1) := 'PROJECT_NAME';
        l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := l_project_name;

        l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1) := 'PROJECT_NUMBER';
        l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := l_project_number;

        l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1) := 'PROJECT_ORGANIZATION';
        l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := l_project_organization;

        l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1) := 'PROJECT_MANAGER';
        l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := l_project_manager;

        l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1) := 'PROJECT_CUSTOMER';
        l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := l_project_customer;

        PA_SCHEDULE_PVT.Get_Conflicting_Asgmt_Count(p_conflict_group_id => l_conflict_group_id,
                                                     x_assignment_count  => l_conf_asgmt_count,
                                                     x_return_status     => l_return_status,
                                                     x_msg_count         => l_msg_count,
                                                     x_msg_data          => l_msg_data);

        l_num_attr_name_tbl(l_num_attr_name_tbl.COUNT+1) := 'NUM_OVERCOMMIT';
        l_num_attr_value_tbl(l_num_attr_value_tbl.COUNT+1) := l_conf_asgmt_count;

        IF l_resolve_con_action_code = 'NOTIFY_IF_CONFLICT' THEN
           IF l_mode = G_MASS_ASGMT THEN
               l_calling_page := 'MassAsgmtCreateSubmitNotif';
           ELSIF l_mode = G_MASS_SUBMIT_FOR_APPROVAL THEN
               l_calling_page := 'MassAsgmtSubmitOnlyNotif';
           ELSE
               l_calling_page := 'MassAsgmtUpdateSubmitNotif';
           END IF;
        ELSE
           IF l_mode = G_MASS_ASGMT THEN
               l_calling_page := 'MassAsgmtCreateFYINotif';
           ELSIF l_mode = G_MASS_SUBMIT_FOR_APPROVAL THEN
               l_calling_page := 'MassAsgmtSubmitOnlyFYINotif';
           ELSE
               l_calling_page := 'MassAsgmtUpdateFYINotif';
           END IF;
         END IF;

        l_view_conflicts_link := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275'||'&'||'akRegionCode=PA_VIEW_CONFLICTS_LAYOUT'||'&'||'paProjectId='||l_project_id||'&'||
        'paConflictGroupId='||l_conflict_group_id||'&'||'paCallingPage='||l_calling_page||'&'||'paItemType=PARMATRX'||'&'||'paItemKey='||p_item_key||'&'||'addBreadCrumb=RP';

        l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1) := 'VIEW_CONFLICTS_LINK';
        l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := l_view_conflicts_link;

        IF l_resolve_con_action_code = 'NOTIFY_IF_CONFLICT' THEN

           l_message_name := 'PA_NOTIFY_IF_CONFLICT';

           BEGIN

	   /* 2708879 - Added two conditions for application id and language code for the query from fnd_new_messages below */

              SELECT message_text INTO l_view_conf_action_text
                FROM fnd_new_messages
               WHERE message_name = l_message_name
                     and application_id = 275
                     and language_code = userenv('LANG');

           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 l_view_conf_action_text := l_message_name;
           END;

           l_text_attr_name_tbl(l_text_attr_name_tbl.COUNT+1) := 'VIEW_CONFLICTS_ACTION_TEXT';
           l_text_attr_value_tbl(l_text_attr_value_tbl.COUNT+1) := l_view_conf_action_text;

        END IF;

        --dynamically create and set the Number item attributes
        WF_ENGINE.AddItemAttrNumberArray(itemtype => p_item_type,
                                         itemkey  => p_item_key,
                                         aname    => l_add_num_attr_name_tbl,
                                         avalue   => l_add_num_attr_value_tbl);
        --set the wf item attributes.
        WF_ENGINE.SetItemAttrTextArray(itemtype => p_item_type,
                                       itemkey  => p_item_key,
                                       aname    => l_text_attr_name_tbl,
                                       avalue   => l_text_attr_value_tbl);

      WF_ENGINE.SetItemAttrNumberArray(itemtype => p_item_type,
                                       itemkey  => p_item_key,
                                       aname    => l_num_attr_name_tbl,
                                       avalue   => l_num_attr_value_tbl);

      --the document type is used to dynamically create the Updated Information section
      --of the mass update wf notification.
      --see the mass_asgmt_autonomous_trx API for more information.
      --also refer to the Oracle Workflow documentation for information
      --regarding Document types.
      WF_ENGINE.SetItemAttrDocument(itemtype => p_item_type,
                                    itemkey => p_item_key,
                                    aname => 'UPDATED_INFORMATION_DOCUMENT',
                                    documentid => 'plsql:PA_MASS_ASGMT_TRX.Display_Updated_Attributes/'	||l_document);

END IF;  --p_funcmode = 'RUN'

   EXCEPTION
     WHEN OTHERS THEN

	 -- 4537865 : Need to ask Rajnish whether p_result to be set as NONE
	  p_result := 'NONE' ; -- In case of Unexpected Error,No Notification will be sent. Simply Exception will be RAISED.

         -- Included as per discussion with Rajnish : 4537865
	 Wf_Core.Context('pa_mass_asgmt_trx','start_mass_asgmt_trx_wf',p_item_type,p_item_key,to_char(p_actid),p_funcmode);

         FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'pa_mass_asgmt_trx.start_mass_asgmt_trx_wf'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         RAISE;

  END mass_asgmt_trx_wf;

PROCEDURE mass_asgmt_autonomous_trx
            (p_item_type                 IN        VARCHAR2,
             p_item_key                  IN        VARCHAR2,
             p_actid                     IN        NUMBER,
             p_funcmode                  IN        VARCHAR2,
             p_resource_id_tbl           IN        SYSTEM.pa_num_tbl_type,
             p_assignment_id_tbl         IN        SYSTEM.pa_num_tbl_type,
             x_mode                      OUT NOCOPY       VARCHAR2, -- 4537865
             x_action                    OUT NOCOPY      VARCHAR2,  -- 4537865
             x_start_date                OUT NOCOPY      DATE, -- 4537865
             x_end_date                  OUT NOCOPY      DATE, -- 4537865
             x_project_id                OUT NOCOPY      NUMBER, -- 4537865
             x_document                  OUT NOCOPY      VARCHAR2) -- 4537865
IS

-- Commented for Perf fix 4918687 SQL ID 14910597
--cursor csr_get_tp_amt_type (p_asg_id NUMBER) IS
--SELECT fcst_tp_amount_type_name
--FROM   pa_project_assignments_v
--WHERE  assignment_id = p_asg_id;

-- Added for Perf fix 4918687 SQL ID 14910597
cursor csr_get_tp_amt_type (p_asg_id NUMBER) IS
SELECT lkup.meaning fcst_tp_amount_type_name
FROM   pa_project_assignments asgn, pa_lookups lkup
WHERE  lkup.lookup_type(+) = 'TP_AMOUNT_TYPE'
  AND  asgn.fcst_tp_amount_type = lkup.lookup_code(+)
  AND  asgn.assignment_id =  p_asg_id;

--this must be an autonomous transaction as no commits are allowed in
--the workflow transaction itself.
PRAGMA AUTONOMOUS_TRANSACTION;

l_mode                          VARCHAR2(30);
l_action                        VARCHAR2(30);
l_success_assignment_id_tbl     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_single_obj_id_tbl             SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_object_id_tbl                 SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_assignment_name               pa_project_assignments.assignment_name%TYPE;
l_wf_assignment_type            pa_project_assignments.assignment_type%TYPE;
l_assignment_type               pa_project_assignments.assignment_type%TYPE;
l_status_code                   pa_project_assignments.status_code%TYPE;
l_multiple_status_flag          pa_project_assignments.multiple_status_flag%TYPE;
l_staffing_priority_code        pa_project_assignments.staffing_priority_code%TYPE;
l_project_id                    NUMBER;
l_project_role_id               NUMBER;
l_role_list_id                  NUMBER;
l_project_subteam_id            NUMBER;
l_description                   pa_project_assignments.description%TYPE;
l_append_description_flag       VARCHAR2(1);
l_start_date                    pa_project_assignments.start_date%TYPE;
l_end_date                      pa_project_assignments.end_date%TYPE;
l_extension_possible            pa_project_assignments.extension_possible%TYPE;
l_min_resource_job_level        pa_project_assignments.min_resource_job_level%TYPE;
l_max_resource_job_level        pa_project_assignments.max_resource_job_level%TYPE;
l_additional_information        pa_project_assignments.additional_information%TYPE;
l_append_information_flag       VARCHAR2(1);
l_location_id                   NUMBER;
l_work_type_id                  NUMBER;
l_calendar_type                 pa_project_assignments.calendar_type%TYPE;
l_calendar_id                   NUMBER;
l_resource_calendar_percent     pa_project_assignments.resource_calendar_percent%TYPE;
l_project_name                  pa_projects_all.name%TYPE;
l_project_number                pa_projects_all.segment1%TYPE;
l_project_subteam_name          pa_project_subteams.name%TYPE;
l_project_status_name           pa_project_statuses.project_status_name%TYPE;
l_staffing_priority_name        pa_lookups.meaning%TYPE;
l_project_role_name             pa_project_role_types.meaning%TYPE;
l_location_city                 pa_locations.city%TYPE;
l_location_region               pa_locations.region%TYPE;
l_location_country_name         fnd_territories_tl.territory_short_name%TYPE;
l_location_country_code         pa_locations.country_code%TYPE;
l_calendar_name                 jtf_calendars_tl.calendar_name%TYPE;
l_work_type_name                pa_work_types_vl.name%TYPE;
l_tp_amt_type_name              pa_project_assignments_v.fcst_tp_amount_type_name%TYPE;
l_expense_owner                 pa_project_assignments.expense_owner%TYPE;
l_expense_limit                 pa_project_assignments.expense_limit%TYPE;
l_expense_limit_currency_code   pa_project_assignments.expense_limit_currency_code%TYPE;
l_comp_match_weighting          pa_project_assignments.competence_match_weighting%TYPE;
l_avail_match_weighting         pa_project_assignments.availability_match_weighting%TYPE;
l_job_level_match_weighting     pa_project_assignments.job_level_match_weighting%TYPE;
l_search_min_availability       pa_project_assignments.search_min_availability%TYPE;
l_search_country_code           pa_project_assignments.search_country_code%TYPE;
l_search_country_name           fnd_territories_vl.territory_short_name%TYPE;
l_search_exp_org_struct_ver_id  pa_project_assignments.search_exp_org_struct_ver_id%TYPE;
l_search_exp_org_hier_name      per_organization_structures.name%TYPE;
l_search_exp_start_org_id       pa_project_assignments.search_exp_start_org_id%TYPE;
l_search_exp_start_org_name     hr_organization_units.name%TYPE;
l_search_min_candidate_score    pa_project_assignments.search_min_candidate_score%TYPE;
l_enable_auto_cand_nom_flag	pa_project_assignments.enable_auto_cand_nom_flag%TYPE;
l_enable_auto_cand_nom_meaning	fnd_lookups.meaning%TYPE;
l_fcst_tp_amount_type           pa_project_assignments.fcst_tp_amount_type%TYPE;
l_fcst_job_id                   NUMBER;
l_fcst_job_group_id             NUMBER;
l_expenditure_org_id            NUMBER;
l_expenditure_organization_id   NUMBER;
l_expenditure_type_class        pa_project_assignments.expenditure_type_class%TYPE;
l_expenditure_type              pa_project_assignments.expenditure_type%TYPE;
l_fcst_job_name                 per_jobs.name%TYPE;
l_fcst_job_group_name           per_job_groups.displayed_name%TYPE;
l_expenditure_org_name          per_organization_units.name%TYPE;
l_exp_organization_name         per_organization_units.name%TYPE;
l_exception_type_code           VARCHAR2(30);
l_change_start_date             DATE;
l_change_end_date               DATE;
l_change_rqmt_status_code       VARCHAR2(30);
l_change_asgmt_status_code      VARCHAR2(30);
l_change_start_date_tbl         SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_change_end_date_tbl           SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_monday_hours_tbl              SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_tuesday_hours_tbl             SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_wednesday_hours_tbl           SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_thursday_hours_tbl            SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_friday_hours_tbl              SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_saturday_hours_tbl            SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_sunday_hours_tbl              SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_num_of_sch_periods            NUMBER;
l_non_working_day_flag          VARCHAR2(1);
l_change_hours_type_code        VARCHAR2(30);
l_hrs_per_day                   NUMBER;
l_calendar_percent              NUMBER;
l_change_calendar_type_code     VARCHAR2(30);
l_change_calendar_name          VARCHAR2(50);
l_change_calendar_id            NUMBER;
l_duration_shift_type_code      VARCHAR2(30);
l_duration_shift_unit_code      VARCHAR2(30);
l_num_of_shift                  NUMBER;
l_success_assignments           NUMBER;
l_failure_assignments           NUMBER;
l_success_asgmt_name_tbl        Wf_Engine.NameTabTyp;
l_success_asgmt_val_tbl         Wf_Engine.NumTabTyp;
l_project_organization          pa_project_lists_v.carrying_out_organization_name%TYPE;
l_project_customer              pa_project_lists_v.customer_name%TYPE;
l_project_manager               pa_project_lists_v.person_name%TYPE;
l_err_code                      VARCHAR2(2000);
l_err_stage                     VARCHAR2(2000);
l_err_stack                     VARCHAR2(2000);
l_return_status                 VARCHAR2(1);
l_msg_count                     NUMBER;
l_msg_data                      fnd_new_messages.message_text%TYPE;
l_number_of_resources           NUMBER;
l_number_of_assignments         NUMBER;
l_number_of_competencies        NUMBER;
l_success_assignments_link      VARCHAR2(2000);
l_failure_assignments_link      VARCHAR2(2000);
l_assignment_duration           NUMBER;
l_competence_id_tbl             SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_competence_alias_tbl          SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_competence_name_tbl           SYSTEM.pa_varchar2_240_tbl_type := SYSTEM.pa_varchar2_240_tbl_type();
l_rating_level_id_tbl           SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_mandatory_flag_tbl            SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type() ;
l_extension_possible_meaning    fnd_lookups.meaning%TYPE;
l_mandatory_flag_meaning        fnd_lookups.meaning%TYPE;
l_expense_owner_meaning         pa_lookups.meaning%TYPE;
l_fcst_tp_amount_type_meaning   pa_lookups.meaning%TYPE;
l_rating_level                  per_rating_levels_v.step_value%TYPE;
l_submitter_user_id             NUMBER;
l_submitter_resp_id             NUMBER;
l_submitter_resp_appl_id        NUMBER;
l_calendar_display              VARCHAR2(60);
-- FP.L Development
l_staffing_owner_person_id      pa_project_assignments.staffing_owner_person_id%TYPE;
l_staffing_owner_name           per_people_f.full_name%TYPE;

BEGIN

   --set the check ID flag to 'N'
   --this will avoid validation in the value-id conversion APIs if the
   --id is passed in - it must be valid.
   PA_STARTUP.G_Check_ID_Flag := 'N';

   --retrieve the number of assignments attribute
   l_submitter_user_id :=      WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                            itemkey  => p_item_key,
                                                            aname    => 'SUBMITTER_USER_ID');

   l_submitter_resp_id :=      WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                            itemkey  => p_item_key,
                                                            aname    => 'SUBMITTER_RESP_ID');

   l_submitter_resp_appl_id := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                            itemkey  => p_item_key,
                                                            aname    => 'SUBMITTER_RESP_APPL_ID');

   FND_GLOBAL.Apps_Initialize ( user_id      => l_submitter_user_id
                              , resp_id      => l_submitter_resp_id
                              , resp_appl_id => l_submitter_resp_appl_id
                              );

   --set globals to be used by APIs called by this API.
   PA_MASS_ASGMT_TRX.G_SUBMITTER_USER_ID := l_submitter_user_id;
   PA_MASS_ASGMT_TRX.G_WORKFLOW_ITEM_KEY := p_item_key;

   --get the following wf item attributes regardless of the mode
   l_mode :=                       WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                             itemkey  => p_item_key,
                                                             aname    => 'MODE');
   x_mode := l_mode;

   l_action :=                     WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                             itemkey  => p_item_key,
                                                             aname    => 'ACTION');
   x_action := l_action;


   l_project_id :=                 WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                               itemkey  => p_item_key,
                                                               aname    => 'PROJECT_ID');
   x_project_id := l_project_id;




   --if the mode is mass assignment or mass update basic info then get the
   --following attributes.
   IF l_mode = G_MASS_ASGMT OR l_mode = G_MASS_UPDATE_ASGMT_BASIC_INFO THEN

      l_assignment_name :=            WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'ASSIGNMENT_NAME');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_assignment_name <> FND_API.G_MISS_CHAR AND l_assignment_name IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('ASSIGNMENT_NAME')||' - '||l_assignment_name||'<BR>';
      END IF;

      l_wf_assignment_type :=         WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'ASSIGNMENT_TYPE');

      l_status_code :=                WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'STATUS_CODE');

      l_project_status_name :=        WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'PROJECT_STATUS_NAME');

      l_multiple_status_flag :=       WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'MULTIPLE_STATUS_FLAG');

      l_work_type_id :=               WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'WORK_TYPE_ID');

      l_work_type_name :=             WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'WORK_TYPE_NAME');

      l_staffing_priority_code :=     WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'STAFFING_PRIORITY_CODE');

      l_staffing_priority_name :=     WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'STAFFING_PRIORITY_NAME');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      --get the name as we will only have the code as the field is a poplist on the page
      IF l_staffing_priority_code <> FND_API.G_MISS_CHAR AND l_staffing_priority_code IS NOT NULL THEN
         IF l_staffing_priority_name = FND_API.G_MISS_CHAR OR l_staffing_priority_name IS NULL THEN
            SELECT meaning INTO l_staffing_priority_name
              FROM pa_lookups
             WHERE lookup_type = 'STAFFING_PRIORITY_CODE'
               AND lookup_code = l_staffing_priority_code;
         END IF;
         x_document := x_document||get_translated_attr_name('STAFFING_PRIORITY_NAME')||' - '||l_staffing_priority_name||'<BR>';
      END IF;

      l_project_role_id :=            WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'PROJECT_ROLE_ID');

      l_project_role_name :=          WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'PROJECT_ROLE_NAME');

      l_role_list_id :=               WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'ROLE_LIST_ID');

      l_project_subteam_id :=         WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'PROJECT_SUBTEAM_ID');

      l_project_subteam_name :=       WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'PROJECT_SUBTEAM_NAME');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      --get the name as we will only have the code as the field is a poplist on the page
      IF l_project_subteam_id <> FND_API.G_MISS_NUM and l_project_subteam_id IS NOT NULL THEN
         IF l_project_subteam_name = FND_API.G_MISS_CHAR OR l_project_subteam_name IS NULL THEN
            SELECT name INTO l_project_subteam_name
              FROM pa_project_subteams
             WHERE project_subteam_id = l_project_subteam_id;
         END IF;
         x_document := x_document||get_translated_attr_name('PROJECT_SUBTEAM_NAME')||' - '||l_project_subteam_name||'<BR>';
      END IF;

      l_extension_possible :=         WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'EXTENSION_POSSIBLE');


      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      --get the meaning as we will not have it as the field is a poplist on the page
      IF l_extension_possible <> FND_API.G_MISS_CHAR AND l_extension_possible IS NOT NULL THEN
         SELECT meaning INTO l_extension_possible_meaning
           FROM fnd_lookups
          WHERE lookup_type='YES_NO'
            AND lookup_code = l_extension_possible;
         x_document := x_document||get_translated_attr_name('EXTENSION_POSSIBLE')||' - '||l_extension_possible_meaning||'<BR>';
      END IF;

      l_min_resource_job_level :=     WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'MIN_RESOURCE_JOB_LEVEL');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_min_resource_job_level <> FND_API.G_MISS_NUM AND l_min_resource_job_level IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('MIN_RESOURCE_JOB_LEVEL')||' - '||l_min_resource_job_level||'<BR>';
      END IF;

      l_max_resource_job_level :=     WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'MAX_RESOURCE_JOB_LEVEL');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_max_resource_job_level <> FND_API.G_MISS_NUM AND l_max_resource_job_level IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('MAX_RESOURCE_JOB_LEVEL')||' - '||l_max_resource_job_level||'<BR>';
      END IF;

      -- FP.L Development
      l_staffing_owner_person_id :=   WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'STAFFING_OWNER_PERSON_ID');

      l_staffing_owner_name      :=   WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'STAFFING_OWNER_NAME');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_staffing_owner_name <> FND_API.G_MISS_CHAR AND l_staffing_owner_name IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('STAFFING_OWNER')||' - '||l_staffing_owner_name||'<BR>';
      END IF;

      l_description :=                WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'DESCRIPTION');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_description <> FND_API.G_MISS_CHAR AND l_description IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('DESCRIPTION')||' - '||l_description||'<BR>';
      END IF;

      l_append_description_flag :=    WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'APPEND_DESCRIPTION_FLAG');

      l_additional_information :=     WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'ADDITIONAL_INFORMATION');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_additional_information <> FND_API.G_MISS_CHAR AND l_additional_information IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('ADDITIONAL_INFORMATION')||' - '||l_additional_information||'<BR>';
      END IF;

      l_append_information_flag :=    WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'APPEND_INFORMATION_FLAG');

      l_start_date :=                 WF_ENGINE.GetItemAttrDate(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'START_DATE');
      x_start_date := l_start_date;

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_start_date <> FND_API.G_MISS_DATE AND l_start_date IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('START_DATE')||' - '||l_start_date||'<BR>';
      END IF;

      l_end_date :=                   WF_ENGINE.GetItemAttrDate(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'END_DATE');

      x_end_date := l_end_date;

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_end_date <> FND_API.G_MISS_DATE AND l_end_date IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('END_DATE')||' - '||l_end_date||'<BR>';
      END IF;

      l_location_id :=                WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'LOCATION_ID');

      l_location_city :=              WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'LOCATION_CITY');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_location_city <> FND_API.G_MISS_CHAR AND l_location_city IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('LOCATION_CITY')||' - '||l_location_city||'<BR>';
      END IF;

      l_location_region :=            WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'LOCATION_REGION');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_location_region <> FND_API.G_MISS_CHAR AND l_location_region IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('LOCATION_REGION')||' - '||l_location_region||'<BR>';
      END IF;

      l_location_country_name :=      WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'LOCATION_COUNTRY_NAME');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_location_country_name <> FND_API.G_MISS_CHAR AND l_location_country_name IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('LOCATION_COUNTRY_NAME')||' - '||l_location_country_name||'<BR>';
      END IF;

      l_location_country_code :=      WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'LOCATION_COUNTRY_CODE');

      l_calendar_type :=              WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'CALENDAR_TYPE');

      l_calendar_id :=                WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'CALENDAR_ID');

      l_resource_calendar_percent :=  WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'RESOURCE_CALENDAR_PERCENT');

      l_project_name :=               WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'PROJECT_NAME');

      l_project_number :=             WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'PROJECT_NUMBER');

      l_calendar_name :=              WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'CALENDAR_NAME');

      l_expense_owner :=              WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'EXPENSE_OWNER');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      --get the meaning as we will not have it as the field is a poplist on the page
      IF l_expense_owner <> FND_API.G_MISS_CHAR AND l_expense_owner IS NOT NULL THEN
         SELECT meaning INTO l_expense_owner_meaning
          FROM pa_lookups
         WHERE lookup_type = 'EXPENSE_OWNER_TYPE'
           AND lookup_code = l_expense_owner;
         x_document := x_document||get_translated_attr_name('EXPENSE_OWNER')||' - '||l_expense_owner_meaning||'<BR>';
      END IF;

      l_expense_limit :=              WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'EXPENSE_LIMIT');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_expense_limit <> FND_API.G_MISS_NUM AND l_expense_limit IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('EXPENSE_LIMIT')||' - '||l_expense_limit||'<BR>';
      END IF;

      l_expense_limit_currency_code :=  WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'EXPENSE_LIMIT_CURRENCY_CODE');

      l_comp_match_weighting := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                            itemkey  => p_item_key,
                                                            aname    => 'COMP_MATCH_WEIGHTING');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_comp_match_weighting <> FND_API.G_MISS_NUM AND l_comp_match_weighting IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('COMP_MATCH_WEIGHTING')||' - '||l_comp_match_weighting||'<BR>';
      END IF;

      l_avail_match_weighting := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                             itemkey  => p_item_key,
                                                             aname    => 'AVAIL_MATCH_WEIGHTING');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_avail_match_weighting <> FND_API.G_MISS_NUM AND l_avail_match_weighting IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('AVAIL_MATCH_WEIGHTING')||' - '||l_avail_match_weighting||'<BR>';
      END IF;

      l_job_level_match_weighting := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                             itemkey  => p_item_key,
                                                             aname    => 'JOB_LEVEL_MATCH_WEIGHTING');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_job_level_match_weighting <> FND_API.G_MISS_NUM AND l_job_level_match_weighting IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('JOB_LEVEL_MATCH_WEIGHTING')||' - '||l_job_level_match_weighting||'<BR>';
      END IF;

      l_search_min_availability := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                              itemkey  => p_item_key,
                                                              aname    => 'SEARCH_MIN_AVAILABILITY');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_search_min_availability <> FND_API.G_MISS_NUM AND l_search_min_availability IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('SEARCH_MIN_AVAILABILITY')||' - '||l_search_min_availability||'<BR>';
      END IF;

      l_search_country_code :=  WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                              itemkey  => p_item_key,
                                                              aname    => 'SEARCH_COUNTRY_CODE');

      l_search_country_name :=      WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'SEARCH_COUNTRY_NAME');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_search_country_name <> FND_API.G_MISS_CHAR AND l_search_country_name IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('LOCATION_COUNTRY_NAME')||' - '||l_search_country_name||'<BR>';
      END IF;

      l_search_exp_org_struct_ver_id := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                    itemkey  => p_item_key,
                                                                    aname    => 'SEARCH_EXP_ORG_STRUCT_VER_ID');

      l_search_exp_org_hier_name :=      WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                   itemkey  => p_item_key,
                                                                   aname    => 'SEARCH_EXP_ORG_HIER_NAME');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_search_exp_org_hier_name <> FND_API.G_MISS_CHAR AND l_search_exp_org_hier_name IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('SEARCH_EXP_ORG_HIER_NAME')||' - '||l_search_exp_org_hier_name||'<BR>';
      END IF;

      l_search_exp_start_org_id := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                               itemkey  => p_item_key,
                                                               aname    => 'SEARCH_EXP_START_ORG_ID');

      l_search_exp_start_org_name :=      WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                   itemkey  => p_item_key,
                                                                   aname    => 'SEARCH_EXP_START_ORG_NAME');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_search_exp_start_org_name <> FND_API.G_MISS_CHAR AND l_search_exp_start_org_name IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('SEARCH_EXP_START_ORG_NAME')||' - '||l_search_exp_start_org_name||'<BR>';
      END IF;

      l_search_min_candidate_score := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                              itemkey  => p_item_key,
                                                              aname    => 'SEARCH_MIN_CANDIDATE_SCORE');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_search_min_candidate_score <> FND_API.G_MISS_NUM AND l_search_min_candidate_score IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('SEARCH_MIN_CANDIDATE_SCORE')||' - '||l_search_min_candidate_score||'<BR>';
      END IF;

      L_ENABLE_AUTO_CAND_NOM_FLAG :=      WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                   itemkey  => p_item_key,
                                                                   aname    => 'ENABLE_AUTO_CAND_NOM_FLAG');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF L_ENABLE_AUTO_CAND_NOM_FLAG <> FND_API.G_MISS_CHAR AND L_ENABLE_AUTO_CAND_NOM_FLAG IS NOT NULL THEN
         SELECT meaning INTO L_ENABLE_AUTO_CAND_NOM_MEANING
           FROM fnd_lookups
          WHERE lookup_type='YES_NO'
            AND lookup_code = L_ENABLE_AUTO_CAND_NOM_FLAG;
         x_document := x_document||get_translated_attr_name('ENABLE_AUTO_CAND_NOM_FLAG')||' - '||L_ENABLE_AUTO_CAND_NOM_MEANING||'<BR>';
      END IF;

   ELSIF l_mode = G_MASS_UPDATE_FORECAST_ITEMS THEN

      l_work_type_id :=               WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'WORK_TYPE_ID');

      l_work_type_name :=             WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'WORK_TYPE_NAME');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      --get the name as we will not have it as the field is a poplist on the page
      IF l_work_type_id <> FND_API.G_MISS_NUM AND l_work_type_id IS NOT NULL THEN
         IF l_work_type_name = FND_API.G_MISS_CHAR OR l_work_type_name IS NULL THEN
            SELECT name INTO l_work_type_name
              FROM pa_work_types_vl
             WHERE work_type_id = l_work_type_id;
         END IF;
         x_document := x_document||get_translated_attr_name('WORK_TYPE_NAME')||' - '||l_work_type_name||'<BR>';
      END IF;

      l_fcst_tp_amount_type :=        WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'FCST_TP_AMOUNT_TYPE');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      --get the meaning as we will not have it as the field is a poplist on the page
      IF l_fcst_tp_amount_type <> FND_API.G_MISS_CHAR AND l_fcst_tp_amount_type IS NOT NULL THEN
         SELECT meaning INTO l_fcst_tp_amount_type_meaning
           FROM pa_lookups
          WHERE lookup_type = 'TP_AMOUNT_TYPE'
            AND lookup_code = l_fcst_tp_amount_type;
         x_document := x_document||get_translated_attr_name('FCST_TP_AMOUNT_TYPE')||' - '||l_fcst_tp_amount_type_meaning||'<BR>';
      END IF;

      l_fcst_job_id :=                WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'FCST_JOB_ID');

      l_fcst_job_name :=              WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'FCST_JOB_NAME');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_fcst_job_name <> FND_API.G_MISS_CHAR AND l_fcst_job_name IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('FCST_JOB_NAME')||' - '||l_fcst_job_name||'<BR>';
      END IF;

      l_fcst_job_group_id :=          WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'FCST_JOB_GROUP_ID');

      l_fcst_job_group_name :=        WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'FCST_JOB_GROUP_NAME');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_fcst_job_group_name <> FND_API.G_MISS_CHAR AND l_fcst_job_group_name IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('FCST_JOB_GROUP_NAME')||' - '||l_fcst_job_group_name||'<BR>';
      END IF;

      l_expenditure_org_id :=         WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'EXPENDITURE_ORG_ID');

      l_expenditure_org_name :=       WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'EXPENDITURE_ORG_NAME');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_expenditure_org_name <> FND_API.G_MISS_CHAR AND l_expenditure_org_name IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('EXPENDITURE_ORG_NAME')||' - '||l_expenditure_org_name||'<BR>';
      END IF;

      l_expenditure_organization_id :=  WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'EXPENDITURE_ORGANIZATION_ID');

      l_exp_organization_name :=      WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'EXP_ORGANIZATION_NAME');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_exp_organization_name <> FND_API.G_MISS_CHAR AND l_exp_organization_name IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('EXP_ORGANIZATION_NAME')||' - '||l_exp_organization_name||'<BR>';
      END IF;

      l_expenditure_type_class :=     WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'EXPENDITURE_TYPE_CLASS');

      l_expenditure_type :=           WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'EXPENDITURE_TYPE');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_expenditure_type <> FND_API.G_MISS_CHAR AND l_expenditure_type IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('EXPENDITURE_TYPE')||' - '||l_expenditure_type||'<BR>';
      END IF;


   ELSIF l_mode = G_MASS_UPDATE_SCHEDULE THEN


      l_exception_type_code :=        WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'EXCEPTION_TYPE_CODE');

      l_change_start_date :=          WF_ENGINE.GetItemAttrDate(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'CHANGE_START_DATE');

      IF l_exception_type_code = 'CHANGE_DURATION' THEN
         --if the attribute has been updated then
         --append to x_document to display the Updated Information region in the wf notification
         IF l_change_start_date <> FND_API.G_MISS_DATE THEN
            x_document := x_document||get_translated_attr_name('START_DATE')||' - '||l_change_start_date||'<BR>';
         END IF;
      END IF;

      l_change_end_date :=            WF_ENGINE.GetItemAttrDate(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'CHANGE_END_DATE');

      IF l_exception_type_code = 'CHANGE_DURATION' THEN
         --if the attribute has been updated then
         --append to x_document to display the Updated Information region in the wf notification
         IF l_change_end_date <> FND_API.G_MISS_DATE THEN
            x_document := x_document||get_translated_attr_name('END_DATE')||' - '||l_change_end_date||'<BR>';
         END IF;
      END IF;

      l_change_rqmt_status_code :=    WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'CHANGE_RQMT_STATUS_CODE');

      IF l_change_rqmt_status_code <> FND_API.G_MISS_CHAR THEN

            SELECT project_status_name INTO l_project_status_name
              FROM pa_project_statuses
             WHERE project_status_code = l_change_rqmt_status_code
               AND status_type='OPEN_ASGMT' ;

         x_document := x_document||get_translated_attr_name('STATUS_NAME')||' - '||l_project_status_name||'<BR>';

      END IF;

      l_change_asgmt_status_code :=   WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'CHANGE_ASGMT_STATUS_CODE');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      --get the name as we will only have the code as the field is a poplist on the page
      IF l_change_asgmt_status_code <> FND_API.G_MISS_CHAR THEN
            SELECT project_status_name INTO l_project_status_name
              FROM pa_project_statuses
             WHERE project_status_code = l_change_asgmt_status_code
               AND status_type='STAFFED_ASGMT' ;
         x_document := x_document||get_translated_attr_name('STATUS_NAME')||' - '||l_project_status_name||'<BR>';
      END IF;

      -- Multi-period Work Pattern Updates
      l_num_of_sch_periods :=     WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                  itemkey  => p_item_key,
                                                                  aname    => 'NUM_OF_SCH_PERIODS');
      IF l_num_of_sch_periods > 0 THEN

        l_change_start_date_tbl.EXTEND(l_num_of_sch_periods);
        l_change_end_date_tbl.EXTEND(l_num_of_sch_periods);
        l_monday_hours_tbl.EXTEND(l_num_of_sch_periods);
        l_tuesday_hours_tbl.EXTEND(l_num_of_sch_periods);
        l_wednesday_hours_tbl.EXTEND(l_num_of_sch_periods);
        l_thursday_hours_tbl.EXTEND(l_num_of_sch_periods);
        l_friday_hours_tbl.EXTEND(l_num_of_sch_periods);
        l_saturday_hours_tbl.EXTEND(l_num_of_sch_periods);
        l_sunday_hours_tbl.EXTEND(l_num_of_sch_periods);

        FOR j IN 1 .. l_num_of_sch_periods LOOP

          l_change_start_date_tbl(j) :=          WF_ENGINE.GetItemAttrDate(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'CHANGE_START_DATE'||j);

          --if the attribute has been updated then
          --append to x_document to display the Updated Information region in the wf notification
          IF l_change_start_date_tbl(j) <> FND_API.G_MISS_DATE THEN
            x_document := x_document||get_translated_attr_name('START_DATE')||' - '||l_change_start_date_tbl(j)||'<BR>';
          END IF;

          l_change_end_date_tbl(j) :=            WF_ENGINE.GetItemAttrDate(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'CHANGE_END_DATE'||j);

          --if the attribute has been updated then
          --append to x_document to display the Updated Information region in the wf notification
          IF l_change_end_date_tbl(j) <> FND_API.G_MISS_DATE THEN
            x_document := x_document||get_translated_attr_name('END_DATE')||' - '||l_change_end_date_tbl(j)||'<BR>';
          END IF;

          l_monday_hours_tbl(j) :=               WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'MONDAY_HOURS'||j);

          --if the attribute has been updated then
          --append to x_document to display the Updated Information region in the wf notification
          IF l_monday_hours_tbl(j) <> FND_API.G_MISS_NUM AND l_monday_hours_tbl(j) IS NOT NULL THEN
            x_document := x_document||get_translated_attr_name('MONDAY_HOURS')||' - '||l_monday_hours_tbl(j)||'<BR>';
          END IF;

          l_tuesday_hours_tbl(j) :=              WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'TUESDAY_HOURS'||j);

          --if the attribute has been updated then
          --append to x_document to display the Updated Information region in the wf notification
          IF l_tuesday_hours_tbl(j) <> FND_API.G_MISS_NUM AND l_tuesday_hours_tbl(j) IS NOT NULL THEN
           x_document := x_document||get_translated_attr_name('TUESDAY_HOURS')||' - '||l_tuesday_hours_tbl(j)||'<BR>';
          END IF;

          l_wednesday_hours_tbl(j) :=            WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'WEDNESDAY_HOURS'||j);

          --if the attribute has been updated then
          --append to x_document to display the Updated Information region in the wf notification
          IF l_wednesday_hours_tbl(j) <> FND_API.G_MISS_NUM AND l_wednesday_hours_tbl(j) IS NOT NULL THEN
           x_document := x_document||get_translated_attr_name('WEDNESDAY_HOURS')||' - '||l_wednesday_hours_tbl(j)||'<BR>';
          END IF;

          l_thursday_hours_tbl(j) :=             WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'THURSDAY_HOURS'||j);

          --if the attribute has been updated then
          --append to x_document to display the Updated Information region in the wf notification
          IF l_thursday_hours_tbl(j) <> FND_API.G_MISS_NUM AND l_thursday_hours_tbl(j) IS NOT NULL THEN
            x_document := x_document||get_translated_attr_name('THURSDAY_HOURS')||' - '||l_thursday_hours_tbl(j)||'<BR>';
          END IF;

          l_friday_hours_tbl(j) :=               WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'FRIDAY_HOURS'||j);

          --if the attribute has been updated then
          --append to x_document to display the Updated Information region in the wf notification
          IF l_friday_hours_tbl(j) <> FND_API.G_MISS_NUM AND l_friday_hours_tbl(j) IS NOT NULL THEN
            x_document := x_document||get_translated_attr_name('FRIDAY_HOURS')||' - '||l_friday_hours_tbl(j)||'<BR>';
          END IF;

          l_saturday_hours_tbl(j) :=             WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'SATURDAY_HOURS'||j);

          --if the attribute has been updated then
          --append to x_document to display the Updated Information region in the wf notification
          IF l_saturday_hours_tbl(j) <> FND_API.G_MISS_NUM AND l_saturday_hours_tbl(j) IS NOT NULL THEN
            x_document := x_document||get_translated_attr_name('SATURDAY_HOURS')||' - '||l_saturday_hours_tbl(j)||'<BR>';
          END IF;

          l_sunday_hours_tbl(j) :=               WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'SUNDAY_HOURS'||j);

          --if the attribute has been updated then
          --append to x_document to display the Updated Information region in the wf notification
          IF l_sunday_hours_tbl(j) <> FND_API.G_MISS_NUM AND l_sunday_hours_tbl(j) IS NOT NULL THEN
            x_document := x_document||get_translated_attr_name('SUNDAY_HOURS')||' - '||l_sunday_hours_tbl(j)||'<BR>';
          END IF;

        END LOOP;
      END IF; -- End if for muti-period work pattern updates

      l_non_working_day_flag :=       WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'NON_WORKING_DAY_FLAG');

      l_change_hours_type_code :=     WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'CHANGE_HOURS_TYPE_CODE');

      l_hrs_per_day :=                WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'HRS_PER_DAY');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_hrs_per_day <> FND_API.G_MISS_NUM AND l_hrs_per_day IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('HRS_PER_DAY')||' - '||l_hrs_per_day||'<BR>';
      END IF;

      l_change_calendar_type_code :=  WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'CHANGE_CALENDAR_TYPE_CODE');

      l_change_calendar_name :=       WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'CHANGE_CALENDAR_NAME');

      IF l_change_calendar_name <> FND_API.G_MISS_CHAR and l_change_calendar_name IS NOT NULL THEN
         l_calendar_display := ': '||l_change_calendar_name;
      END IF;

      l_change_calendar_id :=         WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'CHANGE_CALENDAR_ID');

      l_calendar_percent :=           WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'CALENDAR_PERCENT');

      --if the attribute has been updated then
      --append to x_document to display the Updated Information region in the wf notification
      IF l_calendar_percent <> FND_API.G_MISS_NUM AND l_calendar_percent IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('CALENDAR_PERCENT')||': '||get_translated_attr_name(l_change_calendar_type_code||'_CALENDAR')||l_calendar_display||' - '||l_calendar_percent||'<BR>';
      END IF;


      l_duration_shift_type_code :=   WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'DURATION_SHIFT_TYPE_CODE');

      l_duration_shift_unit_code :=   WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'DURATION_SHIFT_UNIT_CODE');

      l_num_of_shift :=               WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  =>  p_item_key,
                                                                aname    => 'NUM_OF_SHIFT');

      IF l_num_of_shift <> FND_API.G_MISS_NUM AND l_num_of_shift IS NOT NULL THEN
         x_document := x_document||get_translated_attr_name('NUM_OF_SHIFT')||' '||l_num_of_shift||' '||get_translated_attr_name(l_duration_shift_unit_code)||' '||get_translated_attr_name(l_duration_shift_type_code)||'<BR>';
      END IF;

   ELSIF l_mode = G_MASS_UPDATE_COMPETENCIES THEN

      l_number_of_competencies :=     WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                  itemkey  => p_item_key,
                                                                  aname    => 'NUMBER_OF_COMPETENCIES');

      IF l_number_of_competencies > 0 THEN

         l_competence_id_tbl.EXTEND(l_number_of_competencies);
         l_competence_name_tbl.EXTEND(l_number_of_competencies);
         l_competence_alias_tbl.EXTEND(l_number_of_competencies);
         l_rating_level_id_tbl.EXTEND(l_number_of_competencies);
         l_mandatory_flag_tbl.EXTEND(l_number_of_competencies);

         FOR i IN 1 .. l_number_of_competencies LOOP

            l_competence_id_tbl(i) := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                          itemkey  => p_item_key,
                                                          aname    => 'COMPETENCE_ID'||i);

            l_competence_name_tbl(i) := WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                          itemkey  => p_item_key,
                                                          aname    => 'COMPETENCE_NAME'||i);

            l_competence_alias_tbl(i) := WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                          itemkey  => p_item_key,
                                                          aname    => 'COMPETENCE_ALIAS'||i);

            l_rating_level_id_tbl(i) := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                          itemkey  => p_item_key,
                                                          aname    => 'RATING_LEVEL_ID'||i);

            --if rating level id is not null then get the actual rating level
            --in order to display on the wf notification.
            IF l_rating_level_id_tbl(i) <> FND_API.G_MISS_NUM AND l_rating_level_id_tbl(i) IS NOT NULL THEN
               SELECT step_value INTO l_rating_level
                 FROM per_rating_levels_v
                WHERE rating_level_id = l_rating_level_id_tbl(i);
            END IF;

            l_mandatory_flag_tbl(i) := WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                          itemkey  => p_item_key,
                                                          aname    => 'MANDATORY_FLAG'||i);

            --if mandatory_flag is not null then get the meaning
            --in order to display on the wf notification.
            IF l_mandatory_flag_tbl(i) <> FND_API.G_MISS_CHAR AND l_mandatory_flag_tbl(i) IS NOT NULL THEN
               SELECT meaning INTO l_mandatory_flag_meaning
                 FROM fnd_lookups
                WHERE lookup_type = 'YES_NO'
                  AND lookup_code = l_mandatory_flag_tbl(i);
            END IF;

          --for updated competencies append to x_document to display
          --the Updated Information region in the wf notification
            x_document := x_document||get_translated_attr_name('COMPETENCE_NAME')||' - '||l_competence_name_tbl(i)||', '||get_translated_attr_name('COMPETENCE_ALIAS')||' - '
           ||l_competence_alias_tbl(i)||', '||get_translated_attr_name('PROFICIENCY_LEVEL')||' - '||l_rating_level||', '||get_translated_attr_name('MANDATORY_FLAG')||' - '||l_mandatory_flag_meaning||'<BR>';

         END LOOP;

      END IF;

   END IF;

   --if this is a mass assignment then assign the resource id tbl to the object id tbl.
   --otherwise assign the assignment id tbl to the object id tbl.
   IF l_mode = G_MASS_ASGMT THEN
      l_object_id_tbl := p_resource_id_tbl;
   ELSE
      l_object_id_tbl := p_assignment_id_tbl;
   END IF;

   --if this is not a mass submit then call the apis to create/update assignments.
   IF l_mode <> G_MASS_SUBMIT_FOR_APPROVAL THEN

    IF l_object_id_tbl.COUNT > 0 THEN

     --loop through the objects ids and call the api one resource/assignment at a time.
     --it is done this way because a requirement came at the late stages that the
     --process should be re-runnable in case of unexpected error.  In order to only have
     --an impact on this API, it is done in this way.
     FOR i IN l_object_id_tbl.FIRST .. l_object_id_tbl.LAST LOOP

      -- Bug 2402193: reset the l_assignment_type
      l_assignment_type := l_wf_assignment_type;
      --store the object id being processed in l_single_obj_id_tbl
      l_single_obj_id_tbl := SYSTEM.pa_num_tbl_type(l_object_id_tbl(i));

      --call mass create assignments API if mode is mass asgmt

      IF l_mode = G_MASS_ASGMT THEN

         PA_ASSIGNMENTS_PUB.Mass_Create_Assignments
             (p_asgn_creation_mode               => 'MASS',
              p_assignment_name                  => l_assignment_name ,
              p_assignment_type                  => l_assignment_type ,
              p_multiple_status_flag             => l_multiple_status_flag,
              p_status_code                      => l_status_code ,
              p_staffing_priority_code           => l_staffing_priority_code ,
              p_project_id                       => l_project_id ,
              p_project_role_id                  => l_project_role_id ,
              p_role_list_id                     => l_role_list_id ,
              p_resource_id_tbl                  => l_single_obj_id_tbl,
              p_project_subteam_id               => l_project_subteam_id ,
              p_description                      => l_description ,
              p_start_date                       => l_start_date ,
              p_end_date                         => l_end_date ,
              p_extension_possible               => l_extension_possible ,
              p_min_resource_job_level           => l_min_resource_job_level ,
              p_max_resource_job_level           => l_max_resource_job_level ,
              p_additional_information           => l_additional_information ,
              p_location_id                      => l_location_id ,
              p_work_type_id                     => l_work_type_id ,
              p_calendar_type                    => l_calendar_type ,
              p_calendar_id                      => l_calendar_id ,
              p_resource_calendar_percent        => l_resource_calendar_percent ,
              p_project_name                     => l_project_name ,
              p_project_number                   => l_project_number ,
              p_project_subteam_name             => l_project_subteam_name ,
              p_project_status_name              => l_project_status_name ,
              p_staffing_priority_name           => l_staffing_priority_name ,
              p_project_role_name                => l_project_role_name ,
              p_location_city                    => l_location_city ,
              p_location_region                  => l_location_region ,
              p_location_country_name            => l_location_country_name ,
              p_location_country_code            => l_location_country_code ,
              p_calendar_name                    => l_calendar_name ,
              p_work_type_name                   => l_work_type_name ,
              p_init_msg_list                    => FND_API.G_TRUE ,
              p_commit                           => FND_API.G_TRUE ,
              p_validate_only                    => FND_API.G_FALSE ,
              x_success_assignment_id_tbl        => l_success_assignment_id_tbl,
              x_return_status                    => l_return_status,
              x_msg_count                        => l_msg_count,
              x_msg_data                         => l_msg_data
              );



    IF l_success_assignment_id_tbl(1) IS NOT NULL THEN

       OPEN csr_get_tp_amt_type(l_success_assignment_id_tbl(1));
       FETCH csr_get_tp_amt_type into l_tp_amt_type_name;
       CLOSE csr_get_tp_amt_type;

    END IF;

      WF_ENGINE.SetItemAttrText(itemtype => p_item_type,
                                itemkey  => p_item_key,
                                aname    => 'TP_AMT_TYPE_NAME',
                                avalue   => l_tp_amt_type_name);

            --if the assignment was created successfully and the assignment will
            --be submitted for approval, then set the mass wf in progress flag
            --to 'Y' on the newly created assignment in order to prevent updates
            --until the approval process is complete.
            IF l_success_assignment_id_tbl(1) IS NOT NULL AND l_action <> G_SAVE THEN

               UPDATE pa_project_assignments
                  SET mass_wf_in_progress_flag = 'Y'
                WHERE assignment_id = l_success_assignment_id_tbl(1);

            END IF;

      --call mass upate assignments api if mode is mass update basic info
      ELSIF l_mode = G_MASS_UPDATE_ASGMT_BASIC_INFO THEN

         PA_ASSIGNMENTS_PUB.Mass_Update_Assignments
         (    p_update_mode                    => l_mode,
              p_assignment_id_tbl              => l_single_obj_id_tbl,
              p_assignment_type                => l_assignment_type ,
              p_assignment_name                => l_assignment_name ,
              p_staffing_priority_code         => l_staffing_priority_code ,
              p_project_id                     => l_project_id ,
              p_project_subteam_id             => l_project_subteam_id ,
              p_append_description_flag        => l_append_description_flag ,
              p_description                    => l_description ,
              p_extension_possible             => l_extension_possible ,
              p_min_resource_job_level         => l_min_resource_job_level ,
              p_max_resource_job_level         => l_max_resource_job_level ,
              p_append_information_flag        => l_append_information_flag ,
              p_additional_information         => l_additional_information ,
              p_location_id                    => l_location_id ,
              p_expense_owner                  => l_expense_owner ,
              p_expense_limit                  => l_expense_limit ,
              p_expense_limit_currency_code    => l_expense_limit_currency_code ,
              p_project_subteam_name           => l_project_subteam_name ,
              p_staffing_priority_name         => l_staffing_priority_name ,
              p_location_city                  => l_location_city ,
              p_location_region                => l_location_region ,
              p_location_country_name          => l_location_country_name ,
              p_location_country_code          => l_location_country_code ,
              p_comp_match_weighting           => l_comp_match_weighting,
              p_avail_match_weighting          => l_avail_match_weighting,
              p_job_level_match_weighting      => l_job_level_match_weighting,
              p_search_min_availability        => l_search_min_availability,
              p_search_country_code            => l_search_country_code,
              p_search_country_name            => l_search_country_name,
              p_search_exp_org_struct_ver_id   => l_search_exp_org_struct_ver_id,
              p_search_exp_org_hier_name       => l_search_exp_org_hier_name,
              p_search_exp_start_org_id        => l_search_exp_start_org_id,
              p_search_exp_start_org_name      => l_search_exp_start_org_name,
              p_search_min_candidate_score     => l_search_min_candidate_score,
              p_enable_auto_cand_nom_flag      => l_enable_auto_cand_nom_flag,
              p_staffing_owner_person_id       => l_staffing_owner_person_id,
              p_staffing_owner_name            => l_staffing_owner_name,
              p_commit                         => FND_API.G_TRUE ,
              p_validate_only                  => FND_API.G_FALSE ,
              x_success_assignment_id_tbl      => l_success_assignment_id_tbl,
              x_return_status                  => l_return_status,
              x_msg_count                      => l_msg_count,
              x_msg_data                       => l_msg_data);

      --call mass process competencies api if mode is mass update competencies
      ELSIF l_mode = G_MASS_UPDATE_COMPETENCIES THEN

        PA_COMPETENCE_PUB.Mass_Process_Competences
              (p_project_id                     => l_project_id ,
               p_assignment_tbl                 => l_single_obj_id_tbl ,
               p_competence_id_tbl              => l_competence_id_tbl ,
               p_competence_name_tbl            => l_competence_name_tbl,
               p_competence_alias_tbl           => l_competence_alias_tbl,
               p_rating_level_id_tbl            => l_rating_level_id_tbl,
               p_mandatory_flag_tbl             => l_mandatory_flag_tbl,
               p_commit                         => FND_API.G_TRUE ,
               p_validate_only                  => FND_API.G_FALSE ,
               x_success_assignment_id_tbl      => l_success_assignment_id_tbl,
               x_return_status                  => l_return_status,
               x_msg_count                      => l_msg_count,
               x_msg_data                       => l_msg_data);

      --call mass update assignments api if mode is mass update forecast items
      ELSIF l_mode = G_MASS_UPDATE_FORECAST_ITEMS THEN

           PA_ASSIGNMENTS_PUB.Mass_Update_Assignments
         (    p_update_mode                    => l_mode,
              p_assignment_id_tbl              => l_single_obj_id_tbl ,
              p_project_id                     => l_project_id,
              p_fcst_tp_amount_type            => l_fcst_tp_amount_type ,
              p_fcst_job_id                    => l_fcst_job_id ,
              p_fcst_job_group_id              => l_fcst_job_group_id ,
              p_expenditure_org_id             => l_expenditure_org_id ,
              p_expenditure_organization_id    => l_expenditure_organization_id ,
              p_expenditure_type_class         => l_expenditure_type_class ,
              p_expenditure_type               => l_expenditure_type ,
              p_work_type_name                 => l_work_type_name ,
              p_work_type_id                   => l_work_type_id ,
              p_fcst_job_name                  => l_fcst_job_name ,
              p_fcst_job_group_name            => l_fcst_job_group_name ,
              p_expenditure_org_name           => l_expenditure_org_name ,
              p_exp_organization_name          => l_exp_organization_name ,
              p_commit                         => FND_API.G_TRUE ,
              p_validate_only                  => FND_API.G_FALSE ,
              x_success_assignment_id_tbl      => l_success_assignment_id_tbl,
              x_return_status                  => l_return_status,
              x_msg_count                      => l_msg_count,
              x_msg_data                       => l_msg_data);

      --call mass update schedule api if mode is mass update schedule
      ELSIF l_mode = G_MASS_UPDATE_SCHEDULE THEN

         PA_SCHEDULE_PUB.mass_update_schedule
           (  p_project_id                     => l_project_id ,
              p_exception_type_code            => l_exception_type_code ,
              p_assignment_id_array            => l_single_obj_id_tbl ,
              p_change_start_date              => l_change_start_date ,
              p_change_end_date                => l_change_end_date ,
              p_change_rqmt_status_code        => l_change_rqmt_status_code ,
              p_change_asgmt_status_code       => l_change_asgmt_status_code ,
              p_change_start_date_tbl          => l_change_start_date_tbl,
              p_change_end_date_tbl            => l_change_end_date_tbl,
              p_monday_hours_tbl               => l_monday_hours_tbl ,
              p_tuesday_hours_tbl              => l_tuesday_hours_tbl ,
              p_wednesday_hours_tbl            => l_wednesday_hours_tbl ,
              p_thursday_hours_tbl             => l_thursday_hours_tbl ,
              p_friday_hours_tbl               => l_friday_hours_tbl ,
              p_saturday_hours_tbl             => l_saturday_hours_tbl ,
              p_sunday_hours_tbl               => l_sunday_hours_tbl ,
              p_non_working_day_flag           => l_non_working_day_flag ,
              p_change_hours_type_code         => l_change_hours_type_code ,
              p_hrs_per_day                    => l_hrs_per_day ,
              p_calendar_percent               => l_calendar_percent ,
              p_change_calendar_type_code      => l_change_calendar_type_code ,
              p_change_calendar_name           => l_change_calendar_name ,
              p_change_calendar_id             => l_change_calendar_id ,
              p_duration_shift_type_code       => l_duration_shift_type_code ,
              p_duration_shift_unit_code       => l_duration_shift_unit_code ,
              p_number_of_shift                => l_num_of_shift ,
              p_commit                         => FND_API.G_TRUE ,
              x_success_assignment_id_tbl      => l_success_assignment_id_tbl,
              x_return_status                  => l_return_status,
              x_msg_count                      => l_msg_count,
              x_msg_data                       => l_msg_data);

      END IF;

      --set the mass_wf_in_progress_flag to 'N' if the assignments will not be submitted
      --for approval and this is not a mass assignment.  (If it is a mass assignment
      --not is not submitted then the flag will not already be set to 'Y'
      IF (l_assignment_type IS NULL OR l_assignment_type = FND_API.G_MISS_CHAR) THEN
         SELECT assignment_type INTO l_assignment_type
           FROM pa_project_assignments
          WHERE assignment_id = l_single_obj_id_tbl(1);
      END IF;
      IF (l_action = G_SAVE OR l_success_assignment_id_tbl(1) IS NULL OR l_assignment_type = 'OPEN_ASSIGNMENT') AND l_mode <> G_MASS_ASGMT THEN

         UPDATE pa_project_assignments
            SET mass_wf_in_progress_flag = 'N'
          WHERE assignment_id = l_single_obj_id_tbl(1);

      END IF;

      --set pa_wf_process_details.process_status_code.
      --if the assignment was created/updated successfully then l_success_assignment_id_tbl(1)
      --will be not null - so set process_status_code to 'S'
      --otherwise the assignemnt was not created/updated successfully due to a validation
      --error so set process_status_code to 'E'.
      UPDATE pa_wf_process_details
         SET process_status_code = decode(l_success_assignment_id_tbl(1), NULL, 'E', 'S'),
             object_id2 = decode(l_mode, G_MASS_ASGMT, l_success_assignment_id_tbl(1), NULL)
       WHERE item_type = p_item_type
         AND item_key = p_item_key
         AND object_id1 = l_single_obj_id_tbl(1);

      --need to commit here in this autonomous transaction in case of
      --an unexpected error later on.  This will make the process
      --rerunnable from the point of the unexpected error.  Only
      --items with a process_status_code = 'P' will be picked up to
      --process - items already processed will not be picked up again.
      --the actual API called above will commit OR rollback the actual trx data
      --as p_commit is passed as True.
      COMMIT;

    END LOOP;
   END IF;

   --if l_mode is mass submit for approval then set everything to S.
   ELSIF l_object_id_tbl.COUNT > 0 THEN

      FORALL i IN l_object_id_tbl.FIRST .. l_object_id_tbl.LAST
         UPDATE pa_wf_process_details
            SET process_status_code = 'S'
          WHERE item_type = p_item_type
            AND item_key = p_item_key
            AND object_id1 = l_object_id_tbl(i);
      COMMIT;
   END IF;

   -- Bug 2513254
   -- Get the project_id from project_number and return the project_id
   -- This handles the case when user performs Mass Assignment Creation
   --  (Add Delivery/Admin Assignment) by entering the project number
   --  without using the LOV
   IF l_mode = G_MASS_ASGMT AND (l_project_id IS NULL OR l_project_id = FND_API.G_MISS_NUM)
      AND l_project_number IS NOT NULL AND l_project_number <> FND_API.G_MISS_CHAR THEN

       select project_id into l_project_id
         from pa_projects_all
        where segment1 = l_project_number;

       x_project_id := l_project_id;

    END IF;


 EXCEPTION
   WHEN OTHERS THEN
      --need to end the autonomous transaction.

      -- 4537865 : RESET OUT PARAMS

             x_mode       := NULL ;
             x_action     := NULL ;
             x_start_date := NULL ;
             x_end_date   := NULL ;
             x_project_id := NULL ;
             x_document   := 'An Unexpected error has occured - ' || SUBSTRB(SQLERRM,1,240) ;

	WF_CORE.CONTEXT('pa_mass_asgmt_trx','mass_asgmt_autonomous_trx' ,p_item_type,p_item_key,to_char(p_actid),p_funcmode);
      -- End : 4537865

      ROLLBACK;
      RAISE;

 END mass_asgmt_autonomous_trx;


PROCEDURE Start_Mass_Apprvl_WF_If_Req
            (p_item_type     IN        VARCHAR2,
             p_item_key      IN        VARCHAR2,
             p_actid         IN        NUMBER,
             p_funcmode      IN        VARCHAR2,
             p_result        OUT  NOCOPY     VARCHAR2)     --  4537865
IS

l_mode                          VARCHAR2(30);
l_action                        VARCHAR2(30);
l_approver1_id_tbl              SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_approver2_id_tbl              SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_approver1_name_tbl            SYSTEM.pa_varchar2_240_tbl_type := SYSTEM.pa_varchar2_240_tbl_type();
l_approver2_name_tbl            SYSTEM.pa_varchar2_240_tbl_type := SYSTEM.pa_varchar2_240_tbl_type();
l_appr_over_auth_flag           VARCHAR2(1);
l_note_to_all_approvers         VARCHAR2(2000);
l_conflict_group_id             NUMBER;
l_return_status                 VARCHAR2(1);
l_msg_count                     NUMBER;
l_msg_data                      fnd_new_messages.message_text%TYPE;
l_assignment_id_tbl             SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_document                      VARCHAR2(32767);
l_project_id                    pa_projects_all.project_id%TYPE;
l_submitter_user_id             NUMBER;
l_num_success_assignments       NUMBER;


BEGIN

   --get the mode and action for this wf process
   l_mode :=                       WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                             itemkey  => p_item_key,
                                                             aname    => 'MODE');

   l_action :=                     WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                             itemkey  => p_item_key,
                                                             aname    => 'ACTION');

   l_num_success_assignments :=    WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                          itemkey  => p_item_key,
                                                          aname    => 'NUM_SUCCESS_ASSIGNMENTS');

    --if the assignments in this process are to be submitted then
    IF (l_mode = G_MASS_SUBMIT_FOR_APPROVAL OR l_action = G_SAVE_AND_SUBMIT) AND
        l_num_success_assignments > 0 THEN

       --get the conflict group id
       --this is used to filter out the assignments that the user chose to
       --cancel or revert due to overcommitment and not to pass them on to
       --be submitted.
       l_conflict_group_id     :=      WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                   itemkey  => p_item_key,
                                                                   aname    => 'CONFLICT_GROUP_ID');


       --select the assignments that were successfully processed that were
       --not selected to be canceled or reverted.
            SELECT asgmt.assignment_id,
                   wf.source_attribute1,
                   wf.source_attribute2,
                   wf.source_attribute3,
                   wf.source_attribute4
 BULK COLLECT INTO l_assignment_id_tbl,
                   l_approver1_id_tbl,
                   l_approver1_name_tbl,
                   l_approver2_id_tbl,
                   l_approver2_name_tbl
              FROM pa_wf_process_details wf,
                   pa_project_assignments asgmt
             WHERE wf.item_type = p_item_type
               AND wf.item_key = p_item_key
               AND wf.process_status_code = 'S'
               AND decode(l_mode, G_MASS_ASGMT, object_id2, object_id1) = asgmt.assignment_id
               AND asgmt.assignment_type <> 'OPEN_ASSIGNMENT'
               AND asgmt.assignment_id NOT IN  (
                                            SELECT distinct assignment_id
                                            FROM pa_assignment_conflict_hist
                                           WHERE conflict_group_id = l_conflict_group_id
                                             AND resolve_conflicts_action_code IN ('CANCEL_TXN_ITEM', 'REVERT_TXN_ITEM'))
               ;


          --if there are any assignment ids to be submitted for approval then get
          --the approval attributes.
          IF l_assignment_id_tbl.COUNT > 0 THEN


             l_appr_over_auth_flag := WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'APPR_OVER_AUTH_FLAG');

             l_note_to_all_approvers := WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                                  itemkey  => p_item_key,
                                                                  aname    => 'NOTE_TO_ALL_APPROVERS');

             l_project_id := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                         itemkey  => p_item_key,
                                                         aname    => 'PROJECT_ID');

             l_document := WF_ENGINE.GetItemAttrDocument(itemtype => p_item_type,
                                                         itemkey  => p_item_key,
                                                         aname    => ' UPDATED_INFORMATION_DOCUMENT',
                                                         ignore_notfound => TRUE);

             l_submitter_user_id := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'SUBMITTER_USER_ID');

             --call the submit for approval API.
             PA_ASSIGNMENT_APPROVAL_PUB.mass_assignment_approval
                                    (p_project_id                    => l_project_id,
                                     p_mode                          => l_mode,
                                     p_assignment_id_tbl             => l_assignment_id_tbl,
                                     p_approver1_id_tbl              => l_approver1_id_tbl,
                                     p_approver1_name_tbl            => l_approver1_name_tbl,
                                     p_approver2_id_tbl              => l_approver2_id_tbl,
                                     p_approver2_name_tbl            => l_approver2_name_tbl,
                                     p_overriding_authority_flag     => l_appr_over_auth_flag,
                                     p_note_to_all_approvers         => l_note_to_all_approvers,
                                     p_conflict_group_id             => l_conflict_group_id,
                                     p_update_info_doc               => l_document,
                                     p_submitter_user_id             => l_submitter_user_id,
                                     x_return_status                 => l_return_status,
                                     x_msg_count                     => l_msg_count,
                                     x_msg_data                      => l_msg_data);

            END IF;

      END IF;
 -- 4537865 : Included EXCEPTION BLOCK
 EXCEPTION
	WHEN OTHERS THEN
	 -- I havent reset value of p_result as this param is not assigned value anywhere in this API.
	 -- The Workflow function (Start Apprvl WF If Required) doesnt expect any result type

         -- Included as per discussion with Rajnish : 4537865
         Wf_Core.Context('pa_mass_asgmt_trx','Start_Mass_Apprvl_WF_If_Req',p_item_type,p_item_key,to_char(p_actid),p_funcmode);
         RAISE ;
 END Start_Mass_Apprvl_WF_If_Req;


 PROCEDURE Revert_Cancel_Overcom_Items
            (p_item_type     IN        VARCHAR2,
             p_item_key      IN        VARCHAR2,
             p_actid         IN        NUMBER,
             p_funcmode      IN        VARCHAR2,
             p_result        OUT  NOCOPY     VARCHAR2) IS --  4537865

 l_conflict_group_id     NUMBER;
 l_return_status         VARCHAR2(1);
 l_msg_count             NUMBER;
 l_msg_data              fnd_new_messages.message_text%TYPE;

 BEGIN

    --from the View Conflicts page from the notification to the submitter the
    --submitter may choose to cancel or revert certain assignments.
    --this API is called after the user has taken action on conflicts and
    --closed the notification in order to cancel or revert those assignments.
    l_conflict_group_id     :=      WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                               itemkey  => p_item_key,
                                                               aname    => 'CONFLICT_GROUP_ID');

    --set mass_wf_in_progress_flag = 'N' for those assignments to be canceled
    --or reverted.
    UPDATE pa_project_assignments
       SET mass_wf_in_progress_flag = 'N'
     WHERE assignment_id IN
            (SELECT distinct assignment_id
               FROM pa_assignment_conflict_hist
               WHERE conflict_group_id = l_conflict_group_id
                 AND resolve_conflicts_action_code IN ('CANCEL_TXN_ITEM', 'REVERT_TXN_ITEM'));


    --call APIs to revert / cancel assignments based on the conflict group id.
    PA_SCHEDULE_PVT.Revert_Overcom_Txn_Items
                               (p_conflict_group_id   =>  l_conflict_group_id,
                                x_return_status       =>  l_return_status,
                                x_msg_count           =>  l_msg_count,
                                x_msg_data            =>  l_msg_data);

    PA_SCHEDULE_PVT.Cancel_Overcom_Txn_Items
                               (p_conflict_group_id   =>  l_conflict_group_id,
                                x_return_status       =>  l_return_status,
                                x_msg_count           =>  l_msg_count,
                                x_msg_data            =>  l_msg_data);

-- 4537865 : Included EXCEPTION BLOCK
 EXCEPTION
        WHEN OTHERS THEN
         -- I havent reset value of p_result as this param is not assigned value anywhere in this API.
	 -- The Workflow function (Revert/Cancel Overcom Items) doesnt expect any result type

         -- Included as per discussion with Rajnish : 4537865
         Wf_Core.Context('pa_mass_asgmt_trx','Revert_Cancel_Overcom_Items',p_item_type,p_item_key,to_char(p_actid),p_funcmode);
   	 RAISE;
 END Revert_Cancel_Overcom_Items;

 --this function is not currently used.
 FUNCTION Is_Asgmt_Revert_Or_Cancel(p_conflict_group_id     IN   NUMBER,
                                    p_assignment_id         IN pa_project_assignments.assignment_id%TYPE)
   RETURN BOOLEAN IS

  l_resolve_con_action_code   pa_lookups.meaning%TYPE;

  CURSOR check_asgmt_revert_or_cancel IS
  SELECT resolve_conflicts_action_code
    FROM pa_assignment_conflict_hist
   WHERE conflict_group_id = p_conflict_group_id
     AND assignment_id = p_assignment_id;

  BEGIN

    OPEN check_asgmt_revert_or_cancel;

    FETCH check_asgmt_revert_or_cancel INTO l_resolve_con_action_code;

    CLOSE check_asgmt_revert_or_cancel;

    IF l_resolve_con_action_code = 'CANCEL_TXN_ITEM' OR l_resolve_con_action_code = 'REVERT_TXN_ITEM' THEN

       RETURN TRUE;

    ELSE

       RETURN FALSE;

    END IF;

  END;

 --this API is used as a workflow process post-notification function.
 --if the submitter has chosen to be notified in case of conflicts then the
 --user must navigate to the view conflicts page from the notification and
 --take action on conflicts before closing the notification.
 --this API will return an error as p_result if the user has not taken action
 --on the conflicts and the user will not be able to close the notification.
 PROCEDURE check_action_on_conflicts
            (p_item_type     IN        VARCHAR2,
             p_item_key      IN        VARCHAR2,
             p_actid         IN        NUMBER,
             p_funcmode      IN        VARCHAR2,
             p_result        OUT   NOCOPY    VARCHAR2) -- 4537865
 IS

 l_conflict_group_id     NUMBER;
 l_action_taken          VARCHAR2(1);
 l_return_status         VARCHAR2(1);
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);

 BEGIN

 IF p_funcmode = 'RESPOND' THEN

    l_conflict_group_id     :=      WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
                                                                itemkey  => p_item_key,
                                                                aname    => 'CONFLICT_GROUP_ID');

    PA_SCHEDULE_PVT.Has_Action_Taken_On_Conflicts(p_conflict_group_id => l_conflict_group_id,
                                                  x_action_taken      => l_action_taken,
                                                  x_return_status     => l_return_status,
                                                  x_msg_count         => l_msg_count,
                                                  x_msg_data          => l_msg_data);


    IF l_action_taken = 'N' THEN

       -- p_result := 'ERROR:PA_NO_ACTION_ON_CONFLICTS';
       -- Bug 2134157 - show the message text and not the name.  WF does
       -- not do the apps error message translation from name to text.
       p_result := 'ERROR:' ||
                   fnd_message.get_string('PA','PA_NO_ACTION_ON_CONFLICTS');

    END IF;

  END IF;

-- 4537865 : Included EXCEPTION BLOCK
 EXCEPTION
        WHEN OTHERS THEN
         -- p_result := 'NONE' ;  No need for populating this value - Verified with the WF Function
         -- Included as per discussion with Rajnish : 4537865
         Wf_Core.Context('pa_mass_asgmt_trx','check_action_on_conflicts',p_item_type,p_item_key,to_char(p_actid),p_funcmode);
         RAISE ;
 END check_action_on_conflicts;

 --this API is called in case response required workflow notifications time out.
 --the mass_wf_in_progress_flag is set to 'N' for all assignments in this transaction.
 PROCEDURE Cancel_Mass_Trx_WF
            (p_item_type     IN        VARCHAR2,
             p_item_key      IN        VARCHAR2,
             p_actid         IN        NUMBER,
             p_funcmode      IN        VARCHAR2,
             p_result        OUT  NOCOPY     VARCHAR2) -- 4537865
 IS

 l_mode    VARCHAR2(30);

 BEGIN

   l_mode :=                       WF_ENGINE.GetItemAttrText(itemtype => p_item_type,
                                                             itemkey  => p_item_key,
                                                             aname    => 'MODE');


    UPDATE pa_project_assignments
       SET mass_wf_in_progress_flag = 'N'
     WHERE assignment_id IN
           (SELECT decode(l_mode, G_MASS_ASGMT, object_id2, object_id1)
              FROM pa_wf_process_details
             WHERE item_type = p_item_type
               AND item_key = p_item_key);

 EXCEPTION
   WHEN OTHERS THEN
--4537865 : Start
-- I havent reset value of p_result as this param is not assigned value anywhere in this API.
-- The Workflow function (Cancel Mass Transaction) doesnt expect any result type

         -- Included as per discussion with Rajnish : 4537865
         Wf_Core.Context('pa_mass_asgmt_trx','Cancel_Mass_Trx_WF',p_item_type,p_item_key,to_char(p_actid),p_funcmode);
-- 4537865 : End
      RAISE;

 END;

--if there is an unexpected error then the sysadmin can choose to abort or retry
--the unprocessed items.  If he chooses to abort then this API is called in
--order to set pa_wf_process_details.process_status_code to 'A'.

PROCEDURE Abort_Remaining_Trx
            (p_item_type     IN        VARCHAR2,
             p_item_key      IN        VARCHAR2,
             p_actid         IN        NUMBER,
             p_funcmode      IN        VARCHAR2,
             p_result        OUT NOCOPY      VARCHAR2) --4537865

 IS

 l_mode              VARCHAR2(30);
 l_error_item_type   VARCHAR2(30);
 l_error_item_key    NUMBER;
 l_submitter_user_id NUMBER;
 l_assignment_id     pa_project_assignments.assignment_id%TYPE;
 l_resource_id       pa_resources_denorm.resource_id%TYPE;
 l_return_status     VARCHAR2(1);
 l_project_id        pa_projects_all.project_id%TYPE;
 TYPE object_id_tbl IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
 l_object_id1_tbl   object_id_tbl;


 BEGIN

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

   l_mode :=                       WF_ENGINE.GetItemAttrText(itemtype => l_error_item_type,
                                                             itemkey  => l_error_item_key,
                                                             aname    => 'MODE');

   l_submitter_user_id :=          WF_ENGINE.GetItemAttrText(itemtype => l_error_item_type,
                                                             itemkey  => l_error_item_key,
                                                             aname    => 'SUBMITTER_USER_ID');

   l_project_id :=                 WF_ENGINE.GetItemAttrText(itemtype => l_error_item_type,
                                                             itemkey  => l_error_item_key,
                                                             aname    => 'PROJECT_ID');

    --set process_status_code to 'A' for the pending items.
    UPDATE pa_wf_process_details
       SET process_status_code = 'A' --'A' for aborted
     WHERE item_type = l_error_item_type
       AND item_key = l_error_item_key
       AND process_status_code = 'P';  --'P' for pending

    --set mass_wf_in_progress_flag='N' for the aborted items.
    UPDATE pa_project_assignments
       SET mass_wf_in_progress_flag = 'N'
     WHERE assignment_id IN
           (SELECT decode(l_mode, G_MASS_ASGMT, object_id2, object_id1)
              FROM pa_wf_process_details
             WHERE item_type = l_error_item_type
               AND item_key = l_error_item_key
               AND process_status_code = 'A');

     --get the object id (will be either resource id or assignment id)
     --for the aborted transactions.
     SELECT object_id1 BULK COLLECT INTO l_object_id1_tbl
       FROM pa_wf_process_details
      WHERE item_type = l_error_item_type
        AND item_key  = l_error_item_key
        AND process_status_code = 'A';

         --if there are any aborted items then add a message to the stack
         --saying that those items were aborted by the sysadmin.
         IF l_object_id1_tbl.COUNT > 0 THEN

            FOR i IN l_object_id1_tbl.FIRST .. l_object_id1_tbl.LAST LOOP

               FND_MSG_PUB.initialize;

               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_PROCESS_ABORTED_SYSADMIN');

               IF l_mode = G_MASS_ASGMT THEN
                  l_resource_id := l_object_id1_tbl(i);
                  l_assignment_id := NULL;
               ELSE
                  l_resource_id := NULL;
                  l_assignment_id := l_object_id1_tbl(i);
               END IF;

               PA_MESSAGE_UTILS.save_messages(p_user_id            =>  l_submitter_user_id,
                                              p_source_type1       =>  PA_MASS_ASGMT_TRX.G_SOURCE_TYPE1,
                                              p_source_type2       =>  l_mode,
                                              p_source_identifier1 =>  l_error_item_type,
                                              p_source_identifier2 =>  l_error_item_key,
                                              p_context1           =>  l_project_id,
                                              p_context2           =>  l_assignment_id,
                                              p_context3           =>  l_resource_id,
                                              p_commit             =>  FND_API.G_FALSE,
                                              x_return_status      =>  l_return_status);

            END LOOP;

         END IF;


 EXCEPTION
   WHEN OTHERS THEN
--4537865 : Start
-- I havent reset value of p_result as this param is not assigned value anywhere in this API.
-- The Workflow function (Abort Remaining Transactions) doesnt expect any result type

         -- Included as per discussion with Rajnish : 4537865
         Wf_Core.Context('pa_mass_asgmt_trx','Abort_Remaining_Trx',p_item_type,p_item_key,to_char(p_actid),p_funcmode);
-- 4537865 : End

      RAISE;

 END;

 PROCEDURE Set_Submitter_User_Name
            (p_item_type     IN        VARCHAR2,
             p_item_key      IN        VARCHAR2,
             p_actid         IN        NUMBER,
             p_funcmode      IN        VARCHAR2,
             p_result        OUT   NOCOPY    VARCHAR2) --4537865
 IS

 l_error_item_type      VARCHAR2(30);
 l_error_item_key       NUMBER;
 l_submitter_user_name  wf_users.name%TYPE;  --VARCHAR2(240); Changed for bug 3267790

 BEGIN


   --get the following wf attributes for the process that errored out.
   l_error_item_type :=            WF_ENGINE.GetItemAttrText(itemtype =>  p_item_type,
                                                              itemkey  => p_item_key,
                                                              aname    => 'ERROR_ITEM_TYPE');

   l_error_item_key  :=            WF_ENGINE.GetItemAttrText(itemtype =>  p_item_type,
                                                              itemkey  => p_item_key,
                                                              aname    => 'ERROR_ITEM_KEY');

   l_submitter_user_name :=        WF_ENGINE.GetItemAttrText(itemtype => l_error_item_type,
                                                             itemkey  => l_error_item_key,
                                                             aname    => 'SUBMITTER_USER_NAME');

   --SET the Text item attributes (these attributes were created at design time)
    WF_ENGINE.SetItemAttrText(itemtype => p_item_type,
                              itemkey  => p_item_key,
                              aname    => 'SUBMITTER_USER_NAME',
                              avalue   => l_submitter_user_name);
--4537865 :Included Exception block
 EXCEPTION
   WHEN OTHERS THEN
-- I havent reset value of p_result as this param is not assigned value anywhere in this API.
-- The Workflow function (Set Submitter User Name) doesnt expect any result type

      -- Included as per discussion with Rajnish : 4537865
      Wf_Core.Context('pa_mass_asgmt_trx','Set_Submitter_User_Name',p_item_type,p_item_key,to_char(p_actid),p_funcmode);
      RAISE;

 END;


 PROCEDURE Display_Updated_Attributes(document_id   IN VARCHAR2,
                                      display_type  IN VARCHAR2,
                                      document      IN OUT NOCOPY VARCHAR2, --4537865
                                      document_type IN OUT NOCOPY VARCHAR2) --4537865

 IS

 --4537865
 l_original_document_type  VARCHAR2(200);
 BEGIN

 --this API will be called by workflow in order to show the Updated Information section
 --of the workflow notification.  The document_id passed to the API was created dynamically
 --during the mass_asgmt_autonomous_trx API and then set as the value of the
 --UPDATED_INFORMATION_DOCUMENT workflow attribute.
 --See the  mass_asgmt_autonomous_trx API above for details.
 --a Document wf type is used instead of plain text because plain text has a limit of 4K while
 --Document has a limit of 32K.

 l_original_document_type := document_type ;

 --set the document out parameter = to the document_id IN parameter.
 document := document_id;

--4537865
EXCEPTION
	WHEN OTHERS THEN

	document := 'An Unexpected Error has occured - ' || SUBSTRB(SQLERRM,1,240) ;
 	document_type := l_original_document_type ;

        WF_CORE.CONTEXT('pa_mass_asgmt_trx','Display_Updated_Attributes' );
        RAISE ;
 END;

 FUNCTION get_translated_attr_name (p_lookup_code IN VARCHAR2)
   RETURN VARCHAR2
 IS

 l_meaning  VARCHAR2(2000);

 BEGIN

 --get the translated updated attribute name from lookups.
 --this will be displayed in the Updated Information section of the mass update
 --workflow notification.
 SELECT meaning INTO l_meaning
   FROM pa_lookups
  WHERE lookup_type = 'MASS_ASSIGNMENT_UPDATE_ATTR'
    AND lookup_code = p_lookup_code;

 RETURN l_meaning;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN p_lookup_code;
   WHEN OTHERS THEN
      RAISE;

 END;


END;


/

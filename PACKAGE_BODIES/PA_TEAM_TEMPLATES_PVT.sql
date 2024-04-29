--------------------------------------------------------
--  DDL for Package Body PA_TEAM_TEMPLATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TEAM_TEMPLATES_PVT" AS
/*$Header: PARTPVTB.pls 120.1 2005/08/19 17:01:20 mwasowic noship $*/
--
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
PROCEDURE Start_Apply_Team_Template_WF
(p_team_template_id_tbl            IN     PA_TEAM_TEMPLATES_PUB.team_template_id_tbl
,p_project_id                      IN     pa_projects_all.project_id%TYPE
,p_project_start_date              IN     pa_projects_all.start_date%TYPE
,p_team_start_date                 IN     pa_team_templates.team_start_date%TYPE      := FND_API.G_MISS_DATE
,p_use_project_location            IN     VARCHAR2                                    := 'N'
,p_project_location_id             IN     pa_projects_all.location_id%TYPE            := NULL
,p_use_project_calendar            IN     VARCHAR2                                    := 'N'
,p_project_calendar_id             IN     pa_projects_all.calendar_id%TYPE            := NULL
,p_commit                          IN     VARCHAR2                                    := FND_API.G_FALSE
,x_return_status                   OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_item_type           VARCHAR2(8) := 'PARAPTEM';
l_item_key            VARCHAR2(2000);
l_team_template_id    pa_team_templates.team_template_id%TYPE;
l_project_name        pa_projects_all.name%TYPE;
l_project_number      pa_projects_all.segment1%TYPE;
l_team_template_name  pa_team_templates.team_template_name%TYPE;
l_save_threshold      NUMBER;
l_nextval             NUMBER;

CURSOR get_project_name_and_number IS
SELECT name, segment1
  FROM pa_projects_all
 WHERE project_id = p_project_id;

CURSOR get_team_template_name(l_team_template_id  NUMBER) IS
SELECT team_template_name
  FROM pa_team_templates
 WHERE team_template_id = l_team_template_id;

BEGIN
   --initialize return status to Success
   x_return_status    := FND_API.G_RET_STS_SUCCESS;

   -- Setting thresold value to run the process in background
   l_save_threshold      := wf_engine.threshold;

   IF wf_engine.threshold < 0 THEN
      wf_engine.threshold := l_save_threshold;
   END IF;
   wf_engine.threshold := -1;

   FOR l_index IN p_team_template_id_tbl.FIRST..p_team_template_id_tbl.LAST LOOP

      SELECT pa_apply_team_template_wf_s.nextval
        INTO l_nextval
        FROM dual;

      --get the item key --- **USE SEQUENCE**
      l_item_key := p_team_template_id_tbl(l_index).team_template_id||'-'||l_nextval;

      -- Creating the work flow process
      WF_ENGINE.CreateProcess( itemtype => l_item_type,
                               itemkey  => l_item_key,
                               process  => 'PA_APPLY_TEAM_TEMPLATE') ;

      -- Setting the attribute value for team template id
      WF_ENGINE.SetItemAttrNumber( itemtype => l_item_type,
	                           itemkey  => l_item_key,
                                   aname    => 'TEAM_TEMPLATE_ID',
                                   avalue   => p_team_template_id_tbl(l_index).team_template_id);

      -- Setting the attribute value for project id
      WF_ENGINE.SetItemAttrNumber( itemtype => l_item_type,
	                           itemkey  => l_item_key,
                                   aname    => 'PROJECT_ID',
                                   avalue   => p_project_id);

      -- Setting the attribute value for project start date
      WF_ENGINE.SetItemAttrDate( itemtype => l_item_type,
	                         itemkey  => l_item_key,
                                 aname    => 'PROJECT_START_DATE',
                                 avalue   => p_project_start_date);

      -- Setting the attribute value for team start date
      WF_ENGINE.SetItemAttrDate( itemtype => l_item_type,
	                         itemkey  => l_item_key,
                                 aname    => 'TEAM_START_DATE',
                                 avalue   => p_team_start_date);

      -- Setting the attribute value for use project location
      WF_ENGINE.SetItemAttrText( itemtype => l_item_type,
	                         itemkey  => l_item_key,
                                 aname    => 'USE_PROJECT_LOCATION',
                                 avalue   => p_use_project_location);

      -- Setting the attribute value for project location id
      WF_ENGINE.SetItemAttrNumber( itemtype => l_item_type,
	                           itemkey  => l_item_key,
                                   aname    => 'PROJECT_LOCATION_ID',
                                   avalue   => p_project_location_id);

      -- Setting the attribute value for use project calendar
      WF_ENGINE.SetItemAttrText( itemtype => l_item_type,
	                         itemkey  => l_item_key,
                                 aname    => 'USE_PROJECT_CALENDAR',
                                 avalue   => p_use_project_calendar);

      -- Setting the attribute value for project calendar id
      WF_ENGINE.SetItemAttrNumber( itemtype => l_item_type,
	                           itemkey  => l_item_key,
                                   aname    => 'PROJECT_CALENDAR_ID',
                                   avalue   => p_project_calendar_id);

      -- Setting the attribute value for project calendar id
      WF_ENGINE.SetItemAttrText( itemtype => l_item_type,
	                         itemkey  => l_item_key,
                                 aname    => 'APPLIER_USER_NAME',
                                 avalue   => FND_GLOBAL.user_name);

	---- Code added for bug 3919767 for setting the context values for running WF process


	WF_ENGINE.SetItemAttrNumber( itemtype => l_item_type
			  , itemkey =>  l_item_key
			  , aname => 'USER_ID'
			  , avalue => FND_GLOBAL.USER_ID);

	WF_ENGINE.SetItemAttrNumber( itemtype => l_item_type
			  , itemkey =>  l_item_key
			  , aname => 'RESPONSIBILITY_ID'
			  , avalue => FND_GLOBAL.RESP_ID);

	WF_ENGINE.SetItemAttrNumber( itemtype => l_item_type
			  , itemkey =>  l_item_key
			  , aname => 'APPLICATION_ID'
			  , avalue => FND_GLOBAL.RESP_APPL_ID);

	----- Code addition end for bug 3919767

      --get the project name/number to be used in the notification.
      OPEN get_project_name_and_number;
      FETCH get_project_name_and_number INTO l_project_name, l_project_number;
      CLOSE get_project_name_and_number;

      WF_ENGINE.SetItemAttrText( itemtype => l_item_type,
	                         itemkey  => l_item_key,
                                 aname    => 'PROJECT_NAME',
                                 avalue   => l_project_name);

      WF_ENGINE.SetItemAttrText( itemtype => l_item_type,
	                         itemkey  => l_item_key,
                                 aname    => 'PROJECT_NUMBER',
                                 avalue   => l_project_number);

      --get the team template name to be used in the notification.
      OPEN get_team_template_name(p_team_template_id_tbl(l_index).team_template_id);
      FETCH get_team_template_name INTO l_team_template_name;
      CLOSE get_team_template_name;

      WF_ENGINE.SetItemAttrText( itemtype => l_item_type,
	                         itemkey  => l_item_key,
                                 aname    => 'TEAM_TEMPLATE_NAME',
                                 avalue   => l_team_template_name);

      -- start the workflow process
      WF_ENGINE.StartProcess( itemtype => l_item_type,
                              itemkey  => l_item_key);


      UPDATE pa_team_templates
         SET workflow_in_progress_flag = 'Y'
       WHERE team_template_id = p_team_template_id_tbl(l_index).team_template_id;

   END LOOP;

   --Setting the original value
    wf_engine.threshold := l_save_threshold;

EXCEPTION
   WHEN OTHERS THEN

     --Setting the original value
      wf_engine.threshold := l_save_threshold;

     -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TEAM_TEMPLATES_PVT.Apply_Team_Template'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END Start_Apply_Team_Template_WF;


PROCEDURE Apply_Team_Template_WF
(p_item_type     IN        VARCHAR2,
 p_item_key      IN        VARCHAR2,
 p_actid         IN        NUMBER,
 p_funcmode      IN        VARCHAR2,
 p_result        OUT       NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_team_template_id        pa_team_templates.team_template_id%TYPE;
l_project_id              pa_projects_all.project_id%TYPE;
l_project_start_date      pa_projects_all.start_date%TYPE;
l_team_start_date         pa_team_templates.team_start_date%TYPE;
l_use_project_location    VARCHAR2(1);
l_project_location_id     pa_projects_all.location_id%TYPE;
l_use_project_calendar    VARCHAR2(1);
l_project_calendar_id     pa_projects_all.calendar_id%TYPE;
l_return_status           VARCHAR2(1);
l_msg_count               NUMBER;
l_count                   NUMBER;
l_msg_data                fnd_new_messages.message_text%TYPE;
l_msg_index_out           NUMBER;
l_err_code                NUMBER;
l_err_stage               VARCHAR2(2000);
l_err_stack               VARCHAR2(2000);
l_name VARCHAR2(1);

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

--initialize the message stack.
FND_MSG_PUB.initialize;

IF (p_funcmode = 'RUN') THEN

   --set the check ID flag to 'N'
   PA_STARTUP.G_Check_ID_Flag := 'N';

   l_team_template_id      := WF_ENGINE.GetItemAttrNumber (itemtype => p_item_type,
                                                           itemkey  => p_item_key,
                                                           aname    => 'TEAM_TEMPLATE_ID');
   --set the team template id token global variable so that the template
   --name will show up in the error message.
   PA_ASSIGNMENT_UTILS.g_team_template_id := l_team_template_id;

   l_project_id            := WF_ENGINE.GetItemAttrNumber (itemtype => p_item_type,
                                                           itemkey  => p_item_key,
                                                           aname    => 'PROJECT_ID');

   l_project_start_date    := WF_ENGINE.GetItemAttrDate   (itemtype => p_item_type,
                                                           itemkey  => p_item_key,
                                                           aname    => 'PROJECT_START_DATE');

   l_team_start_date       := WF_ENGINE.GetItemAttrDate   (itemtype => p_item_type,
                                                           itemkey  => p_item_key,
                                                           aname    => 'TEAM_START_DATE');

   l_use_project_location  := WF_ENGINE.GetItemAttrText   (itemtype => p_item_type,
                                                           itemkey  => p_item_key,
                                                           aname    => 'USE_PROJECT_LOCATION');

   l_project_location_id   := WF_ENGINE.GetItemAttrNumber (itemtype => p_item_type,
                                                           itemkey  => p_item_key,
                                                           aname    => 'PROJECT_LOCATION_ID');

   l_use_project_calendar  := WF_ENGINE.GetItemAttrText   (itemtype => p_item_type,
                                                           itemkey  => p_item_key,
                                                           aname    => 'USE_PROJECT_CALENDAR');

   l_project_calendar_id   := WF_ENGINE.GetItemAttrNumber (itemtype => p_item_type,
                                                           itemkey  => p_item_key,
                                                           aname    => 'PROJECT_CALENDAR_ID');
   /*
   dbms_output.put_line('l_team_template_id = '||l_team_template_id);
   dbms_output.put_line('l_project_id = '||l_project_id);
   dbms_output.put_line('l_project_start_date = '||l_project_start_date);
   dbms_output.put_line('l_team_start_date = '||l_team_start_date);
   */

   PA_TEAM_TEMPLATES_PVT.Apply_Team_Template( p_team_template_id       =>  l_team_template_id,
                                              p_project_id             =>  l_project_id,
                                              p_project_start_date     =>  l_project_start_date,
                                              p_team_start_date        =>  l_team_start_date,
                                              p_use_project_location   =>  l_use_project_location,
                                              p_project_location_id    =>  l_project_location_id,
                                              p_use_project_calendar   =>  l_use_project_calendar,
                                              p_project_calendar_id    =>  l_project_calendar_id,
                                              p_commit                 =>  FND_API.G_TRUE,
                                              x_return_status          =>  l_return_status);

   l_msg_count := FND_MSG_PUB.Count_Msg;

   IF l_msg_count = 0 THEN
      p_result := 'COMPLETE:S';
   ELSE
      p_result := 'COMPLETE:F';
      FOR l_count IN 1..l_msg_count LOOP
         FND_MSG_PUB.get( p_encoded       => FND_API.G_FALSE
                         ,p_msg_index     => l_count
                         ,p_data          => l_msg_data
                         ,p_msg_index_out => l_msg_index_out);

         WF_ENGINE.SetItemAttrText( itemtype => p_item_type
			          , itemkey =>  p_item_key
			          , aname => 'ERROR_MESSAGE_'||l_count
			          , avalue => l_count||'. '||l_msg_data);

         EXIT WHEN l_msg_count=20;

       END LOOP;
    END IF; --msg count=0

    --update the workflow in progress flag if no other workflows are active or pending
    --for this team template.

    /* Bug 3271891 - Added AND condition for item_key <> p_item_key along with
       activity_status_code <> 'DEFERRED' in the below query */

    UPDATE PA_TEAM_TEMPLATES
       SET workflow_in_progress_flag = 'N'
     WHERE team_template_id = l_team_template_id
       AND NOT EXISTS(
                      SELECT 'Y'
                        FROM wf_item_activity_statuses_v
                       WHERE item_type = p_item_type
                         AND substr(item_key, 1, instr(item_key, '-')) = substr(p_item_key, 1, instr(p_item_key, '-'))
                         AND ((activity_status_code = 'DEFERRED' AND item_key <> p_item_key)  OR
                             (activity_name='START_APPLY_TEAM_TEMPLATE_WF' AND activity_status_code = 'ACTIVE' AND item_key <> p_item_key)))
                      ;

     --INSERT INTO NOTIFICATIONS TABLE
     PA_WORKFLOW_UTILS.Insert_WF_Processes
              (p_wf_type_code        => 'APPLY_TEAM_TEMPLATE'
              ,p_item_type           => p_item_type
      	      ,p_item_key            => p_item_key
              ,p_entity_key1         => to_char(l_project_id)
      	      ,p_description         => NULL
              ,p_err_code            => l_err_code
              ,p_err_stage           => l_err_stage
              ,p_err_stack           => l_err_stack);


  END IF;   --p_funcmode = RUN

  COMMIT;

EXCEPTION

   WHEN OTHERS THEN
     -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TEAM_TEMPLATES_PVT.Apply_Team_Template'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       RAISE;


END Apply_Team_Template_WF;


PROCEDURE Apply_Team_Template
(p_team_template_id                IN     pa_team_templates.team_template_id%TYPE
,p_project_id                      IN     pa_projects_all.project_id%TYPE
,p_project_start_date              IN     pa_projects_all.start_date%TYPE
,p_team_start_date                 IN     pa_team_templates.team_start_date%TYPE      := FND_API.G_MISS_DATE
,p_use_project_location            IN     VARCHAR2                                    := 'N'
,p_project_location_id             IN     pa_projects_all.location_id%TYPE            := NULL
,p_use_project_calendar            IN     VARCHAR2                                    := 'N'
,p_project_calendar_id             IN     pa_projects_all.calendar_id%TYPE            := NULL
,p_commit                          IN     VARCHAR2                                    := FND_API.G_FALSE
,x_return_status                   OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_new_assignment_id         pa_project_assignments.assignment_id%TYPE;
l_assignment_number         pa_project_assignments.assignment_number%TYPE;
l_assignment_row_id         ROWID;
l_resource_id               pa_resources.resource_id%TYPE;
l_return_status             VARCHAR2(1);
l_error_message_code        fnd_new_messages.message_name%TYPE;
l_msg_count                 NUMBER;
l_msg_data                  fnd_new_messages.message_text%TYPE;
l_index                     NUMBER;
l_project_calendar_id       pa_projects_all.calendar_id%TYPE;
l_project_location_id       pa_projects_all.location_id%TYPE;
l_number_of_days            NUMBER;
l_project_subteam_id        pa_project_subteams.project_subteam_id%TYPE;
l_subteam_name              pa_project_subteams.name%TYPE;
l_subteam_row_id            ROWID;
l_team_start_date           pa_team_templates.team_start_date%TYPE;
l_template_requirement_rec  PA_ASSIGNMENTS_PUB.assignment_rec_type;
l_person_name               PER_PEOPLE_F.full_name%TYPE;
l_err_msg_code              VARCHAR2(80);

CURSOR get_project_location_and_cal IS
SELECT calendar_id, location_id
  FROM pa_projects_all
 WHERE project_id = p_project_id;

CURSOR get_template_req_attributes(p_team_template_id  NUMBER) IS
SELECT  assignment_name
        ,'OPEN_ASSIGNMENT'
        ,assignment_type
        ,status_code
        ,staffing_priority_code
        ,project_role_id
        ,description
        ,start_date
        ,end_date
        ,extension_possible
        ,min_resource_job_level
        ,max_resource_job_level
        ,additional_information
        ,location_id
        ,work_type_id
        ,expense_owner
        ,expense_limit
        ,expense_limit_currency_code
        ,expenditure_org_id
        ,expenditure_organization_id
        ,expenditure_type_class
        ,expenditure_type
        ,calendar_type
        ,calendar_id
        ,assignment_id   --used for source_assignment_id
        ,assignment_template_id  --used to tieback to the team template the requirement was created from
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
  FROM pa_project_assignments
 WHERE assignment_template_id = p_team_template_id
   AND template_flag = 'Y';

CURSOR get_team_template_subteams(p_team_template_id  NUMBER) IS
SELECT name
  FROM pa_project_subteams
 WHERE object_type = 'PA_TEAM_TEMPLATES'
   AND object_id = p_team_template_id;

CURSOR get_team_start_date(p_team_template_id  NUMBER) IS
SELECT team_start_date
  FROM pa_team_templates
 WHERE team_template_id = p_team_template_id;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_TEAM_TEMPLATES_PVT.Apply_Team_Template');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT   ASG_PVT_APPLY_TEAM_TEMPLATE;
  END IF;

  --Log Message
  IF (P_DEBUG_MODE ='Y') THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATES_PVT.apply_team_template'
                     ,x_msg         => 'Beginning of Apply_Team_Template'
                     ,x_log_level   => 5);
  END IF;

  l_project_calendar_id := p_project_calendar_id;
  l_project_location_id := p_project_location_id;

  --if p_use_project_location = Y or p_use_project_calendar='Y' and the values are not
  --passed in to the API then get the project calendar/location.
  IF (p_use_project_location ='Y' AND p_project_location_id IS NULL) OR
     (p_use_project_calendar='Y' AND p_project_calendar_id IS NULL) THEN

     OPEN  get_project_location_and_cal;

     FETCH  get_project_location_and_cal INTO l_project_calendar_id, l_project_location_id;

     CLOSE  get_project_location_and_cal;

  END IF;

  --validate that a project calendar is defined if p_use_project_calendar='Y'
  IF p_use_project_calendar ='Y' AND l_project_calendar_id IS NULL THEN

    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PROJ_CAL_NOT_DEFINED');

  END IF;

  --validate that a project location is defined if p_use_project_location='Y'
  IF p_use_project_location ='Y' AND l_project_location_id IS NULL THEN

    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PROJ_LOC_NOT_DEFINED');

  END IF;
/*
  --Loop through the team templates to be applied.

  FOR l_index IN p_team_template_id_tbl.FIRST..p_team_template_id_tbl.LAST LOOP
*/
     --set the team template id token global variable so that the template
     --name will show up in the error message.
--     PA_ASSIGNMENT_UTILS.g_team_template_id :=p_team_template_id_tbl(l_index).team_template_id;
     PA_ASSIGNMENT_UTILS.g_team_template_id :=p_team_template_id;

     --if the team start date was not passed in then get it
     l_team_start_date := p_team_start_date;

     IF p_team_start_date IS NULL OR p_team_start_date = FND_API.G_MISS_DATE THEN

        OPEN get_team_start_date(p_team_template_id);

        FETCH get_team_start_date INTO l_team_start_date;

        CLOSE get_team_start_date;

     END IF;

     --calculate the difference between the project_start_date and the team
     --start date.  This will be used to determine the requirement start
     --and end dates.
     l_number_of_days := p_project_start_date - l_team_start_date;

     --If the template requirement has subteams then check if those subteams already
     --exist on the project. If they don't, then call API to create it.
     OPEN get_team_template_subteams(p_team_template_id);

     LOOP

        FETCH get_team_template_subteams INTO l_subteam_name;

        EXIT WHEN get_team_template_subteams%NOTFOUND;

        l_project_subteam_id := NULL;


        PA_PROJECT_SUBTEAM_UTILS.Check_Subteam_Name_Or_Id( p_subteam_name       => l_subteam_name
                                                          ,p_object_type        => 'PA_PROJECTS'
                                                          ,p_object_id          => p_project_id
                                                          ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                          ,x_subteam_id         => l_project_subteam_id
                                                          ,x_return_status      => l_return_status
                                                          ,x_error_message_code => l_error_message_code );

        --if the project subteam id returned is null then that subteam does not exist on that
        --project, so call create subteam API
        IF  l_project_subteam_id IS NULL THEN

           PA_PROJECT_SUBTEAMS_PUB.Create_Subteam(p_subteam_name => l_subteam_name,
                                                  p_object_type => 'PA_PROJECTS',
                                                  p_object_id => p_project_id,
                                                  p_validate_only => FND_API.G_FALSE,
                                                  p_init_msg_list => FND_API.G_FALSE,
                                                  x_new_subteam_id => l_project_subteam_id,
                                                  x_subteam_row_id => l_subteam_row_id,
                                                  x_return_status => l_return_status,
                                                  x_msg_count => l_msg_count,
                                                  x_msg_data => l_msg_data);

        END IF;

     END LOOP;  --get subteams

     CLOSE get_team_template_subteams;

     --get the template requirements to be copied if there are no
     --validation errors.
     IF FND_MSG_PUB.Count_Msg = 0 THEN

        OPEN get_template_req_attributes(p_team_template_id);

        LOOP
        --not using PA_ASSIGNMENTS_PUB.Copy_Team_Role because API expects the
        --assignment id to be copied to be passed in.  But it would be an extra db hit to
        --get the assignment ids in this API and then pass them to copy_team_role.  So
        --I'll just get everything here and call create assignment.
        FETCH get_template_req_attributes INTO l_template_requirement_rec.assignment_name
                                              ,l_template_requirement_rec.assignment_type
                                              ,l_template_requirement_rec.source_assignment_type
                                              ,l_template_requirement_rec.status_code
                                              ,l_template_requirement_rec.staffing_priority_code
                                              ,l_template_requirement_rec.project_role_id
                                              ,l_template_requirement_rec.description
                                              ,l_template_requirement_rec.start_date
                                              ,l_template_requirement_rec.end_date
                                              ,l_template_requirement_rec.extension_possible
                                              ,l_template_requirement_rec.min_resource_job_level
                                              ,l_template_requirement_rec.max_resource_job_level
                                              ,l_template_requirement_rec.additional_information
                                              ,l_template_requirement_rec.location_id
                                              ,l_template_requirement_rec.work_type_id
                                              ,l_template_requirement_rec.expense_owner
                                              ,l_template_requirement_rec.expense_limit
                                              ,l_template_requirement_rec.expense_limit_currency_code
                                              ,l_template_requirement_rec.expenditure_org_id
                                              ,l_template_requirement_rec.expenditure_organization_id
                                              ,l_template_requirement_rec.expenditure_type_class
                                              ,l_template_requirement_rec.expenditure_type
                                              ,l_template_requirement_rec.calendar_type
                                              ,l_template_requirement_rec.calendar_id
                                              ,l_template_requirement_rec.source_assignment_id
                                              ,l_template_requirement_rec.assignment_template_id
                                              ,l_template_requirement_rec.attribute_category
                                              ,l_template_requirement_rec.attribute1
                                              ,l_template_requirement_rec.attribute2
                                              ,l_template_requirement_rec.attribute3
                                              ,l_template_requirement_rec.attribute4
                                              ,l_template_requirement_rec.attribute5
                                              ,l_template_requirement_rec.attribute6
                                              ,l_template_requirement_rec.attribute7
                                              ,l_template_requirement_rec.attribute8
                                              ,l_template_requirement_rec.attribute9
                                              ,l_template_requirement_rec.attribute10
                                              ,l_template_requirement_rec.attribute11
                                              ,l_template_requirement_rec.attribute12
                                              ,l_template_requirement_rec.attribute13
                                              ,l_template_requirement_rec.attribute14
                                              ,l_template_requirement_rec.attribute15
          ;

          EXIT WHEN get_template_req_attributes%NOTFOUND;

          --set the assignment id token global variable so that the template
          --name will show up in the error message.
          PA_ASSIGNMENT_UTILS.g_team_role_name_token := l_template_requirement_rec.assignment_name;

           --set the project id into the pl/sql record.
           l_template_requirement_rec.project_id := p_project_id;

           --determine the requirement's start and end dates by adding l_number_of_days to
           --the template requirement's start and end dates.
           l_template_requirement_rec.start_date := l_template_requirement_rec.start_date + l_number_of_days;

           l_template_requirement_rec.end_date := l_template_requirement_rec.end_date + l_number_of_days;


           --set the project location id if the project location should be used.
           IF p_use_project_location ='Y' THEN

              l_template_requirement_rec.location_id := l_project_location_id;

           END IF;

           --set the project calendar id if the project calendar should be used.
           IF p_use_project_calendar = 'Y' THEN

              l_template_requirement_rec.calendar_id := l_project_calendar_id;

           END IF;

           --set default staffing owner
           pa_assignment_utils.Get_Default_Staffing_Owner
           ( p_project_id                  => p_project_id
            ,p_exp_org_id                  => null
            ,x_person_id                   => l_template_requirement_rec.staffing_owner_person_id
            ,x_person_name                 => l_person_name
            ,x_return_status               => x_return_status
            ,x_error_message_code          => l_err_msg_code);

   --        Do I need role list check?  Should only be on client side.

           --call API to create the requirement
           --using mode 'COPY' because the requirement is being copied from the
           --template requirement - and then the source assignment id will only be
           --used to get the subteams to copy, and will not be inserted to the db (no link kept).
           PA_ASSIGNMENTS_PUB.Create_Assignment(p_assignment_rec             => l_template_requirement_rec
                                               ,p_asgn_creation_mode         => 'COPY'
                                               ,p_validate_only              => FND_API.G_FALSE
                                               ,x_new_assignment_id          => l_new_assignment_id
                                               ,x_assignment_number          => l_assignment_number
                                               ,x_assignment_row_id          => l_assignment_row_id
                                               ,x_resource_id                => l_resource_id
                                               ,x_return_status              => l_return_status
                                               ,x_msg_count                  => l_msg_count
                                               ,x_msg_data                   => l_msg_data
                                               );

            IF p_commit = FND_API.G_TRUE THEN
               IF l_return_status <> 'S' THEN
                  ROLLBACK;
               ELSE COMMIT;
               END IF;
            END IF;


        END LOOP;  --template requirements in 1 team template

        CLOSE get_template_req_attributes;

     END IF;  --no errors

--     END LOOP; --multiple team templates


  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO ASG_PVT_APPLY_TEAM_TEMPLATE;
        END IF;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TEAM_TEMPLATES_PVT.Apply_Team_Template'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END Apply_Team_Template;



PROCEDURE Create_Team_Template
( p_team_template_rec              IN     PA_TEAM_TEMPLATES_PUB.team_template_rec
 ,p_commit                         IN     VARCHAR2                                     := FND_API.G_FALSE
 ,p_validate_only                  IN     VARCHAR2                                     := FND_API.G_TRUE
 ,x_team_template_id               OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status                  OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_msg_count                 NUMBER;
l_team_template_rec         PA_TEAM_TEMPLATES_PUB.team_template_rec;
l_team_template_name_unique VARCHAR2(1);

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.set_err_stack('PA_TEAM_TEMPLATE_PVT.Create_Team_Template');

  --Log Message
  IF (P_DEBUG_MODE ='Y') THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATES_PVT.Create_Team_Template.begin'
                     ,x_msg         => 'Beginning of the PVT Create_Team_Template'
                     ,x_log_level   => 5);
  END IF;

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Issue API savepoint if the transaction is to be committed
  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT ASGN_PVT_CREATE_TEAM_TEMPLATE;
  END IF;

  l_team_template_rec := p_team_template_rec;

  --validate that team template name is unique
  l_team_template_name_unique := PA_TEAM_TEMPLATES_UTILS.Is_Team_Template_Name_Unique
                                           (p_team_template_name => l_team_template_rec.team_template_name);

  IF l_team_template_name_unique = 'N' THEN

     PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_TEAM_TEMPLATE_NAME_INVALID');

  END IF;

  --validate effective start date is before effective end date
  IF  l_team_template_rec.end_date_active IS NOT NULL and l_team_template_rec.end_date_active <> FND_API.G_MISS_DATE AND l_team_template_rec.start_date_active > l_team_template_rec.end_date_active THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_INVALID_START_DATE');
  END IF;

  --If no validation errors then insert the team template.
  IF p_validate_only = FND_API.G_FALSE AND FND_MSG_PUB.Count_Msg = 0 THEN
     IF (P_DEBUG_MODE ='Y') THEN
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATE_PVT.Create_Team_Template.calling_insert_row'
                        ,x_msg         => 'calling pa_team_templates.insert_row.'
                        ,x_log_level   => 5);
     END IF;

      PA_TEAM_TEMPLATES_PKG.Insert_Row(
                         p_team_template_name => l_team_template_rec.team_template_name,
                         p_description => l_team_template_rec.description,
                         p_start_date_active => l_team_template_rec.start_date_active,
                         p_end_date_active => l_team_template_rec.end_date_active,
                         p_calendar_id => l_team_template_rec.calendar_id,
                         p_work_type_id => l_team_template_rec.work_type_id,
                         p_role_list_id => l_team_template_rec.role_list_id,
                         p_team_start_date => l_team_template_rec.team_start_date,
                         x_team_template_id => x_team_template_id,
                         x_return_status => x_return_status);

   END IF;

  l_msg_count := FND_MSG_PUB.Count_Msg;

     -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND l_msg_count =0 THEN
    COMMIT;
  END IF;

  -- Reset the error stack when returning to the calling program
     PA_DEBUG.Reset_Err_Stack;

  -- If any errors exist then set the x_return_status to 'E'

  IF l_msg_count>0 THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;


  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO ASGN_PVT_CREATE_TEAM_TEMPLATE;
        END IF;
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TEAM_TEMPLATE_PVT.Create_Team_Template'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

END Create_Team_Template;


PROCEDURE Update_Team_Template
( p_team_template_rec              IN     PA_TEAM_TEMPLATES_PUB.team_template_rec
 ,p_commit                         IN     VARCHAR2                                     := FND_API.G_FALSE
 ,p_validate_only                  IN     VARCHAR2                                     := FND_API.G_TRUE
 ,x_return_status                  OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_msg_count              NUMBER;
l_team_template_rec      PA_TEAM_TEMPLATES_PUB.team_template_rec;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.set_err_stack('PA_TEAM_TEMPLATE_PVT.Update_Team_Template');

  --Log Message
  IF (P_DEBUG_MODE ='Y') THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATES_PVT.Update_Team_Template.begin'
                     ,x_msg         => 'Beginning of the PVT Update_Team_Template'
                     ,x_log_level   => 5);
  END IF;

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Issue API savepoint if the transaction is to be committed
  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT ASGN_PVT_Update_TEAM_TEMPLATE;
  END IF;

  l_team_template_rec := p_team_template_rec;

  --validate effective start date is before effective end date
  IF  l_team_template_rec.end_date_active IS NOT NULL and l_team_template_rec.end_date_active <> FND_API.G_MISS_DATE AND l_team_template_rec.start_date_active > l_team_template_rec.end_date_active THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_INVALID_START_DATE');
  END IF;

  --If no validation errors then insert the team template.
  IF p_validate_only = FND_API.G_FALSE AND FND_MSG_PUB.Count_Msg = 0 THEN
   IF (P_DEBUG_MODE ='Y') THEN
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATE_PVT.Update_Team_Template.calling_update_row'
                        ,x_msg         => 'calling pa_team_templates.update_row.'
                        ,x_log_level   => 5);
    END IF;

      PA_TEAM_TEMPLATES_PKG.Update_Row(
                         p_team_template_id => l_team_template_rec.team_template_id,
                         p_team_template_name => l_team_template_rec.team_template_name,
                         p_record_version_number => l_team_template_rec.record_version_number,
                         p_description => l_team_template_rec.description,
                         p_start_date_active => l_team_template_rec.start_date_active,
                         p_end_date_active => l_team_template_rec.end_date_active,
                         p_calendar_id => l_team_template_rec.calendar_id,
                         p_work_type_id => l_team_template_rec.work_type_id,
                         p_role_list_id => l_team_template_rec.role_list_id,
                         p_team_start_date => l_team_template_rec.team_start_date,
                         p_workflow_in_progress_flag => l_team_template_rec.workflow_in_progress_flag,
                         x_return_status => x_return_status);

   END IF;

  l_msg_count := FND_MSG_PUB.Count_Msg;

     -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND l_msg_count =0 THEN
    COMMIT;
  END IF;

  -- Reset the error stack when returning to the calling program
     PA_DEBUG.Reset_Err_Stack;

  -- If any errors exist then set the x_return_status to 'E'

  IF l_msg_count>0 THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;


  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO ASGN_PVT_UPDATE_TEAM_TEMPLATE;
        END IF;
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TEAM_TEMPLATE_PVT.Update_Team_Template'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

END Update_Team_Template;

PROCEDURE Delete_Team_Template
( p_team_template_id            IN     pa_team_templates.team_template_id%TYPE
 ,p_record_version_number       IN     NUMBER
 ,p_commit                      IN     VARCHAR2                                     := FND_API.G_FALSE
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )
IS

l_return_status                 VARCHAR2(1);
l_msg_count                     NUMBER;
l_msg_data                      fnd_new_messages.message_text%TYPE;
l_check_team_template_in_use    VARCHAR2(1);

CURSOR check_team_template_in_use IS
SELECT 'X'
  FROM pa_project_assignments
 WHERE assignment_template_id = p_team_template_id
   AND template_flag <> 'Y';

CURSOR get_template_req_details IS
SELECT assignment_id,
       record_version_number,
       assignment_type
  FROM pa_project_assignments
 WHERE assignment_template_id = p_team_template_id
   AND template_flag = 'Y';

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_TEAM_TEMPLATE_PVT.Delete_Assignment');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --  Issue API savepoint if the transaction is to be committed
  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT   ASGN_PVT_DELETE_TEAM_TEMPLATE;
  END IF;

   --Log Message
 IF (P_DEBUG_MODE ='Y') THEN
   PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATE_PVT.Delete_Team_Template.begin'
                     ,x_msg         => 'Beginning of Delete Team Template PVT.'
                     ,x_log_level   => 5);
 END IF;

     --check if the team template is in use
     OPEN  check_team_template_in_use;

     FETCH check_team_template_in_use INTO l_check_team_template_in_use;

     CLOSE check_team_template_in_use;

     IF l_check_team_template_in_use = 'X' THEN

         PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_TEAM_TEMPLATE_IN_USE');

     ELSE

        --delete the subteams belonging to this team template
        --Log Message
  IF (P_DEBUG_MODE ='Y') THEN
        PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATE_PVT.Delete_Team_Template'
                           ,x_msg         => 'calling delete subteam'
                           ,x_log_level   => 5);
  END IF;
        --don't pass subteam id and this API will delete all subteams belonging to the
        --team template.
        PA_PROJECT_SUBTEAMS_PUB.Delete_Subteam_By_Obj
                                              (p_init_msg_list => FND_API.G_FALSE,
                                               p_validate_only => FND_API.G_FALSE,
                                               p_object_type => 'PA_TEAM_TEMPLATES',
                                               p_object_id => p_team_template_id,
                                               x_return_status => l_return_status,
                                               x_msg_count => l_msg_count,
                                               x_msg_data => l_msg_data);

        --delete the template requirements
        --Log Message
  IF (P_DEBUG_MODE ='Y') THEN
        PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATE_PVT.Delete_Team_Template'
                           ,x_msg         => 'calling delete assignment (template req)'
                           ,x_log_level   => 5);
  END IF;
        FOR l_template_requirements IN get_template_req_details LOOP

           PA_ASSIGNMENTS_PUB.Delete_Assignment(
                               p_assignment_id => l_template_requirements.assignment_id,
                               p_record_version_number => l_template_requirements.record_version_number,
                               p_assignment_type => l_template_requirements.assignment_type,
                               p_calling_module => 'TEMPLATE_REQUIREMENT',
                               p_validate_only => FND_API.G_FALSE,
                               x_return_status => l_return_status,
                               x_msg_count => l_msg_count,
                               x_msg_data => l_msg_data);

         END LOOP;


         --delete the team template header

         --Log Message
  IF (P_DEBUG_MODE ='Y') THEN
         PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATE_PVT.Delete_Team_Template'
                            ,x_msg         => 'calling delete_row'
                            ,x_log_level   => 5);
  END IF;
         PA_TEAM_TEMPLATES_PKG.Delete_Row(p_team_template_id => p_team_template_id
                                         ,p_record_version_number => p_record_version_number
                                         ,x_return_status => x_return_status);

      END IF; --check team template in use.


   -- If errors exist then set the x_return_status to 'E'

   IF FND_MSG_PUB.Count_Msg > 0 THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

   END IF;

   EXCEPTION
      WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
  	   ROLLBACK TO ASGN_PVT_DELETE_ASSIGNMENTT;
        END IF;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TEAM_TEMPLATE_PVT.Delete_Team_Template'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

END Delete_Team_Template;

END pa_team_templates_pvt;

/

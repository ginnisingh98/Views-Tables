--------------------------------------------------------
--  DDL for Package Body PA_ADVERTISEMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ADVERTISEMENTS_PUB" AS
--$Header: PARAVPBB.pls 120.1 2005/08/19 16:48:46 mwasowic noship $
--


----------------------------------------------------------------------
-- Procedure
--   Validate Advertisement Action Line
--
-- Purpose
--   This API is currently empty.
--   Validate a single action line of an advertisement action set
--   template or an advertisement action set on a requirement.
----------------------------------------------------------------------
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */

PROCEDURE Validate_Action_Set_Line (
  p_action_set_type_code           IN  pa_action_sets.action_set_type_code%TYPE
, p_action_set_line_rec            IN  pa_action_set_lines%ROWTYPE
, p_action_line_conditions_tbl     IN  pa_action_set_utils.action_line_cond_tbl_type
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

BEGIN

  NULL;

END Validate_Action_Set_Line;

----------------------------------------------------------------------
-- Procedure
--   Process Advertisement Action Set
--
-- Purpose
--   Re-order the action lines and validate the advertisement
--   action set or advertisement action lines on a requirement.
--   Invoked when a new action set is created, an existing action
--   set or action lines on the requirement are updated, or an action
--   set is started on a requirement.
----------------------------------------------------------------------
PROCEDURE Process_Action_Set (
  p_action_set_type_code           IN  pa_action_sets.action_set_type_code%TYPE
, p_action_set_id                  IN  NUMBER
, p_action_set_template_flag       IN  pa_action_sets.action_set_template_flag%TYPE :=NULL
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

  TYPE varchar_tbl                    IS TABLE OF VARCHAR2(30)
   INDEX BY BINARY_INTEGER;
  TYPE number_tbl                     IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;
  TYPE date_tbl                       IS TABLE OF DATE
   INDEX BY BINARY_INTEGER;

  l_start_date                pa_project_assignments.start_date%TYPE := NULL;
  l_adv_action_set_status_code  pa_action_sets.status_code%TYPE := NULL;
  l_adv_action_set_start_date   pa_action_sets.actual_start_date%TYPE := NULL;
  l_pub_to_org_line_id        pa_action_set_lines.action_set_line_id%TYPE := NULL;
  l_action_code_tbl           varchar_tbl;
  l_condition_code_tbl        varchar_tbl;
  l_condition_attribute1_tbl  varchar_tbl;
  l_condition_attribute2_tbl  varchar_tbl;
  l_condition_date_tbl        date_tbl;
  l_action_set_line_id_tbl    number_tbl;
  l_action_status_code_tbl    varchar_tbl;
  l_action_attribute1_tbl     varchar_tbl;
  l_action_attribute3_tbl     varchar_tbl;
  l_action_attribute4_tbl     varchar_tbl;
  l_action_set_line_number_tbl number_tbl;
  i                           NUMBER;
  l_need_validation           VARCHAR2(1) := 'F';
  l_undeleted_action_code_tbl varchar_tbl;

  l_return_status             VARCHAR2(1);
  l_msg_data                  fnd_new_messages.message_name%TYPE;
  l_msg_count                 NUMBER;
  l_msg_index_out             NUMBER;

  --cursor to get the related details of the requirement
  CURSOR get_req_action_set_info IS
  SELECT pa.start_date,
         ast.status_code,
         ast.actual_start_date
  FROM   pa_project_assignments pa,
         pa_action_sets ast
  WHERE  pa.assignment_id = ast.object_id
  AND    ast.action_set_id = p_action_set_id;

  --cursor to get pending and complete action lines
  CURSOR get_action_lines IS
  SELECT action_code
  FROM pa_action_set_lines
  WHERE action_set_id = p_action_set_id
    AND (status_code = 'PENDING'
     OR status_code = 'UPDATE_PENDING'
     OR status_code = 'COMPLETE');

  --cursor to get pending and complete action lines
  CURSOR get_undeleted_action_lines IS
  SELECT action_code
  FROM pa_action_set_lines
  WHERE action_set_id = p_action_set_id
    AND line_deleted_flag = 'N';

  --cursor to check if validation is needed
  CURSOR check_esc_to_next_lvl_exists IS
  SELECT 'T'
  FROM pa_action_set_lines
  WHERE action_set_id = p_action_set_id
    AND action_code = 'ADVERTISEMENT_ESC_TO_NEXT_LVL'
    AND (status_code = 'PENDING'
         OR status_code = 'UPDATE_PENDING'
         OR status_code = 'COMPLETE')
    AND rownum=1;

  --cursor to check if a Publish to Organizations action line exist before
  --the first Escalate to next level action line for
  --requirement's action set
  CURSOR check_pub_to_org_exists IS
  SELECT action_set_line_id
  FROM pa_action_set_lines
  WHERE action_set_id = p_action_set_id
    AND rownum = 1
    AND action_code = 'ADVERTISEMENT_PUB_TO_START_ORG'
    AND (status_code = 'PENDING'
     OR status_code = 'UPDATE_PENDING'
     OR status_code = 'COMPLETE')
    AND action_set_line_number < (
       SELECT MIN(action_set_line_number)
       FROM pa_action_set_lines
       WHERE action_code = 'ADVERTISEMENT_ESC_TO_NEXT_LVL'
         AND action_set_id = p_action_set_id
         AND (status_code = 'PENDING'
          OR status_code = 'UPDATE_PENDING'
          OR status_code = 'COMPLETE'));

  --cursor to check if a Publish to Organizations action line exist before
  --the first Escalate to next level action line for action set template
  CURSOR check_pub_to_org_in_template IS
  SELECT action_set_line_id
  FROM pa_action_set_lines
  WHERE action_set_id = p_action_set_id
    AND rownum = 1
    AND action_code = 'ADVERTISEMENT_PUB_TO_START_ORG'
    AND action_set_line_number < (
       SELECT MIN(action_set_line_number)
       FROM pa_action_set_lines
       WHERE action_code = 'ADVERTISEMENT_ESC_TO_NEXT_LVL'
         AND action_set_id = p_action_set_id);

 BEGIN

  --dbms_output.put_line('PA_ADVERTISEMENTS_PUB.Process_Action_Set');

  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.WRITE_LOG(x_Module => 'pa.plsql.PA_ADVERTISEMENTS_PUB.Prepare_Adv_Action_Set.begin',x_Msg => 'in PA_ADVERTISEMENTS_PUB.Prepare_Adv_Action_Set', x_Log_Level => 6);
  END IF;

  --initialize the return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialise the error stack
  PA_DEBUG.init_err_stack('PA_ADVERTISEMENTS_PUB.Prepare_Adv_Action_Set');

  --get the related details of the requirement if
  --validating the action set of the requirement
  IF p_action_set_template_flag='N' OR p_action_set_template_flag IS NULL THEN
     OPEN get_req_action_set_info;
      FETCH get_req_action_set_info INTO
       l_start_date,
       l_adv_action_set_status_code,
       l_adv_action_set_start_date;
     CLOSE get_req_action_set_info;
  END IF;

  --dbms_output.put_line('calling PA_ADVERTISEMENTS_PVT.Order_Adv_Action_Lines');

  --
  -- order the action lines
  --
  PA_ADVERTISEMENTS_PVT.Order_Adv_Action_Lines (
     p_action_set_id                => p_action_set_id
   , p_action_set_template_flag     => p_action_set_template_flag
   , p_object_start_date            => l_start_date
   , p_action_set_status_code       => l_adv_action_set_status_code
   , p_action_set_actual_start_date => l_adv_action_set_start_date
   , x_return_status                => l_return_status
  );

  --dbms_output.put_line('Action Line has been ordered');

  --
  -- validate the action lines
  --
  -- get all Pending, Change Pending and Performed action lines
  OPEN get_action_lines;
   FETCH get_action_lines BULK COLLECT INTO l_action_code_tbl;
  CLOSE get_action_lines;

  -- get all undeleted action lines
  OPEN get_undeleted_action_lines;
   FETCH get_undeleted_action_lines BULK COLLECT INTO l_undeleted_action_code_tbl;
  CLOSE get_undeleted_action_lines;


  -- CHECK 1: if there is no such action line, returns error
  IF l_undeleted_action_code_tbl.COUNT=0 THEN

    PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                          ,p_msg_name => 'PA_NO_ACTION_LINE');

  -- CHECK 2: if Escalate to Next Level is the only action line, returns error
  ELSIF l_action_code_tbl.COUNT = 1 AND
        l_action_code_tbl(1)='ADVERTISEMENT_ESC_TO_NEXT_LVL' THEN

    PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                          ,p_msg_name => 'PA_ADV_ESC_NEXT_LVL_ERR');

  -- CHECK 3: if there are more than 1 action lines,
  -- further validation is needed
  ELSIF l_action_code_tbl.COUNT > 1 THEN

    --dbms_output.put_line('More than 1 action lines');

    -- CHECK 4: need further validation only if Escalate to Next Level
    -- action line exists
    OPEN check_esc_to_next_lvl_exists;
     FETCH check_esc_to_next_lvl_exists INTO l_need_validation;
    CLOSE check_esc_to_next_lvl_exists;

    IF l_need_validation = 'T' THEN

      --dbms_output.put_line('Need validation');

      -- CHECK 5: if the advertisement action set has
      -- been started on the requirement
      IF l_adv_action_set_status_code <> 'NOT_STARTED' AND
         l_adv_action_set_status_code <> 'CLOSED' AND
         l_adv_action_set_start_date IS NOT NULL THEN

        -- dbms_output.put_line('Validate action set on Requirement');

        -- CHECK 5.1:check if a Publish to Organizations action line exist before
        -- the first Escalate to next level action line
        OPEN check_pub_to_org_exists;
         FETCH check_pub_to_org_exists INTO l_pub_to_org_line_id;
        CLOSE check_pub_to_org_exists;

        IF l_pub_to_org_line_id IS NULL THEN

          PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name => 'PA_ADV_ESC_NEXT_LVL_ERR');
        END IF;

      -- CHECK 6: if this is template action set,
      -- or action set has not been started on the requirement
      ELSE

        --dbms_output.put_line('Validate template action set');

        -- Get the condition codes and condition parameters of action
        -- lines with action codes equal Publish to Organizations or
        -- Escalate to next level order by line number
        SELECT aslc.condition_code, aslc.condition_attribute1, aslc.condition_attribute2
        BULK COLLECT INTO l_condition_code_tbl, l_condition_attribute1_tbl, l_condition_attribute2_tbl
        FROM pa_action_set_lines asl,
             pa_action_set_line_cond aslc
        WHERE asl.action_set_id = p_action_set_id
          AND asl.action_set_line_id = aslc.action_set_line_id
          AND (asl.action_code = 'ADVERTISEMENT_ESC_TO_NEXT_LVL'
           OR asl.action_code = 'ADVERTISEMENT_PUB_TO_START_ORG')
          AND (asl.status_code = 'PENDING'
           OR asl.status_code = 'UPDATE_PENDING'
           OR asl.status_code = 'COMPLETE')
        ORDER BY asl.action_set_line_number;

        FOR i in l_condition_code_tbl.FIRST+1 ..l_condition_code_tbl.LAST LOOP

          -- CHECK 6.1: If these lines use different condition code,
          -- returns error
          IF l_condition_code_tbl(i) <> l_condition_code_tbl(i-1) THEN

            PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name => 'PA_ADV_DIFF_COND_ERR');
            EXIT; -- exit the loop
          END IF;

          -- CHECK 6.2: If the condition code is Days Open or Remaining and
          -- the Number of Days Remaining is not in descending order
          -- then returns error
          IF l_condition_code_tbl(i) = 'ADVERTISEMENT_DAYS_OPN_REMAIN' AND
             to_number(l_condition_attribute2_tbl(i)) > to_number(l_condition_attribute2_tbl(i-1)) THEN

            PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name => 'PA_ADV_COND_ATT_ERR');
            EXIT; -- exit the loop

          END IF;

        END LOOP;

        -- CHECK 6.3: check if a Publish to Organizations action line
        -- exist before the first Escalate to next level action line
        OPEN check_pub_to_org_in_template;
         FETCH check_pub_to_org_in_template INTO l_pub_to_org_line_id;
        CLOSE check_pub_to_org_in_template;

        IF l_pub_to_org_line_id IS NULL THEN

          PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name => 'PA_ADV_ESC_NEXT_LVL_ERR');
        END IF;

      END IF; -- if it is requirement and advertisement has been started
    END IF; -- need validation
  END IF; -- more than 1 action line

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  -- If there are any messages in the stack then set x_return_status

  IF FND_MSG_PUB.Count_Msg > 0  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

 -- Put any message text from message stack into the Message ARRAY
 EXCEPTION
    WHEN OTHERS THEN

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ADVERTISEMENTS_PUB.Prepare_Adv_Action_Set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs

 END Process_Action_Set;


----------------------------------------------------------------------
-- Procedure
--   Perform Advertisement Action Set Line
--
-- Purpose
--   Invoked by the generic perform action set API to perform an action
--   line in the advertisement action set on an object.
----------------------------------------------------------------------
PROCEDURE Perform_Action_Set_Line (
  p_action_set_type_code           IN  pa_action_sets.action_set_type_code%TYPE
, p_action_set_details_rec         IN  pa_action_sets%ROWTYPE
, p_action_set_line_rec            IN  pa_action_set_lines%ROWTYPE
, p_action_line_conditions_tbl     IN  pa_action_set_utils.action_line_cond_tbl_type
, x_action_line_audit_tbl          OUT NOCOPY pa_action_set_utils.insert_audit_lines_tbl_type -- For 1159 mandate changes bug#2674619
, x_action_line_result_code        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

  TYPE varchar_tbl                    IS TABLE OF VARCHAR2(30)
   INDEX BY BINARY_INTEGER;
  TYPE number_tbl                     IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;
  TYPE date_tbl                       IS TABLE OF DATE
   INDEX BY BINARY_INTEGER;

  l_msg_index_out             NUMBER;
  l_object_id                 pa_project_assignments.assignment_id%TYPE;
  l_project_id                pa_project_assignments.project_id%TYPE;
  l_start_date                pa_project_assignments.start_date%TYPE;
  l_record_version_number     pa_project_assignments.record_version_number%TYPE;
  l_adv_action_set_status_code  pa_action_sets.status_code%TYPE;
  l_adv_action_set_start_date   pa_action_sets.actual_start_date%TYPE;
  l_return_status             VARCHAR2(1);

  --cursor to get the related details of the requirement
  CURSOR get_req_action_set_info IS
  SELECT pa.assignment_id,
         pa.project_id,
         pa.start_date,
         pa.record_version_number
  FROM   pa_project_assignments pa,
         pa_action_sets ast
  WHERE  pa.assignment_id = ast.object_id
  AND    ast.action_set_id = p_action_set_line_rec.action_set_id;

 BEGIN

  --dbms_output.put_line('begin of PA_ADVERTISEMENTS_PUB.Perform_Adv_Action_Set');

  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.WRITE_LOG(x_Module => 'pa.plsql.PA_ADVERTISEMENTS_PUB.Perform_Adv_Action_Set.begin',x_Msg => 'in PA_ADVERTISEMENTS_PUB.Perform_Adv_Action_Set ', x_Log_Level => 6);
  END IF;

  -- Initialise the error stack
  PA_DEBUG.init_err_stack('PA_ADVERTISEMENTS_PUB.Perform_Adv_Action_Set');

  -- Initialize audit record table
  g_action_line_audit_tbl.DELETE;

  --get the related details of the requirement
  OPEN get_req_action_set_info;
   FETCH get_req_action_set_info INTO
     l_object_id,
     l_project_id,
     l_start_date,
     l_record_version_number;
  CLOSE get_req_action_set_info;

  --
  -- Process the action if if the condition of the action line is met
  -- or if the line status is UPDATE_PENDING
  --
  IF p_action_line_conditions_tbl(p_action_line_conditions_tbl.COUNT).condition_date <= SYSDATE OR p_action_set_line_rec.status_code = 'UPDATE_PENDING' THEN

      -- CASE 1: Publish to All
      IF p_action_set_line_rec.action_code = 'ADVERTISEMENT_PUB_TO_ALL' THEN

        PA_ADVERTISEMENTS_PVT.Publish_To_all(
            p_action_set_line_id   => p_action_set_line_rec.action_set_line_id
          , p_object_id            => l_object_id
          , p_action_code          => p_action_set_line_rec.action_code
          , p_action_status_code   => p_action_set_line_rec.status_code
          , x_return_status        => l_return_status
        );

      -- CASE 2: Publish to Starting Organization
      ELSIF p_action_set_line_rec.action_code = 'ADVERTISEMENT_PUB_TO_START_ORG' THEN

        PA_ADVERTISEMENTS_PVT.Publish_To_Organizations(
            p_action_set_line_id   => p_action_set_line_rec.action_set_line_id
          , p_object_id            => l_object_id
          , p_action_code          => p_action_set_line_rec.action_code
          , p_action_status_code   => p_action_set_line_rec.status_code
          , p_org_hierarchy_version_id  => to_number(p_action_set_line_rec.action_attribute1)
          , p_starting_organization_id  => to_number(p_action_set_line_rec.action_attribute2)
          , x_return_status        => l_return_status
        );

      -- CASE 3: Publish to Staffing Manager
      ELSIF p_action_set_line_rec.action_code = 'ADVERTISEMENT_PUB_TO_SM' THEN

        PA_ADVERTISEMENTS_PVT.Publish_To_Staffing_Managers(
            p_action_set_line_id   => p_action_set_line_rec.action_set_line_id
          , p_object_id            => l_object_id
          , p_action_code          => p_action_set_line_rec.action_code
          , p_action_status_code   => p_action_set_line_rec.status_code
          , p_organization_id      => to_number(p_action_set_line_rec.action_attribute1)
          , x_return_status        => l_return_status
        );

      -- CASE 4: Escalate to Next Level
      ELSIF p_action_set_line_rec.action_code = 'ADVERTISEMENT_ESC_TO_NEXT_LVL' THEN

        PA_ADVERTISEMENTS_PVT.Escalate_to_Next_Level(
            p_action_set_line_id     => p_action_set_line_rec.action_set_line_id
          , p_action_set_line_number => p_action_set_line_rec.action_set_line_number
          , p_action_set_id          => p_action_set_line_rec.action_set_id
          , p_action_set_line_rec_ver_num  => p_action_set_line_rec.record_version_number
          , p_action_set_line_cond_tbl => p_action_line_conditions_tbl
          , p_object_id              => l_object_id
          , p_action_code            => p_action_set_line_rec.action_code
          , p_action_status_code     => p_action_set_line_rec.status_code
          , x_return_status          => l_return_status
        );

      -- CASE 5: Send Email
      ELSIF p_action_set_line_rec.action_code = 'ADVERTISEMENT_SEND_EMAIL' THEN

        PA_ADVERTISEMENTS_PVT.Send_Email(
              p_action_set_line_id   => p_action_set_line_rec.action_set_line_id
            , p_object_id            => l_object_id
            , p_action_code          => p_action_set_line_rec.action_code
            , p_action_status_code   => p_action_set_line_rec.status_code
            , p_email_address        => p_action_set_line_rec.action_attribute1
            , p_project_id           => l_project_id
            , x_return_status        => l_return_status
        );

      -- CASE 6: Send Notification to Person
      ELSIF p_action_set_line_rec.action_code = 'ADVERTISEMENT_SEND_NTF_PERSON' THEN

        PA_ADVERTISEMENTS_PVT.Send_Notification(
              p_action_set_line_id   => p_action_set_line_rec.action_set_line_id
            , p_object_id            => l_object_id
            , p_action_code          => p_action_set_line_rec.action_code
            , p_action_status_code   => p_action_set_line_rec.status_code
            , p_method               => 'PERSON'
            , p_person_id            => to_number(p_action_set_line_rec.action_attribute1)
            , p_project_id           => l_project_id
            , p_project_role_id      => null
            , x_return_status        => l_return_status
        );

      -- CASE 7: Send Notification to Project Role
      ELSIF p_action_set_line_rec.action_code = 'ADVERTISEMENT_SEND_NTF_ROLE' THEN

        PA_ADVERTISEMENTS_PVT.Send_Notification(
              p_action_set_line_id   => p_action_set_line_rec.action_set_line_id
            , p_object_id            => l_object_id
            , p_action_code          => p_action_set_line_rec.action_code
            , p_action_status_code   => p_action_set_line_rec.status_code
            , p_method               => 'PROJECT_ROLE'
            , p_person_id            => null
            , p_project_id           => l_project_id
            , p_project_role_id      => to_number(p_action_set_line_rec.action_attribute1)
            , x_return_status        => l_return_status

        );

      -- CASE 8: Update Staffing Priority
      ELSIF p_action_set_line_rec.action_code = 'ADVERTISEMENT_UPDATE_SP' THEN

        PA_ADVERTISEMENTS_PVT.Update_Staffing_Priority(
              p_action_set_line_id     => p_action_set_line_rec.action_set_line_id
            , p_object_id              => l_object_id
            , p_action_code            => p_action_set_line_rec.action_code
            , p_action_status_code     => p_action_set_line_rec.status_code
            , p_staffing_priority_code => p_action_set_line_rec.action_attribute1
            , p_record_version_number  => l_record_version_number
            , x_return_status          => l_return_status
        );

      -- CASE 9: Remove Advertisement
      ELSIF p_action_set_line_rec.action_code = 'ADVERTISEMENT_REMOVE_ADV' THEN

        PA_ADVERTISEMENTS_PVT.Remove_Advertisement(
            p_action_set_line_id   => p_action_set_line_rec.action_set_line_id
          , p_object_id            => l_object_id
          , p_action_code          => p_action_set_line_rec.action_code
          , p_action_status_code   => p_action_set_line_rec.status_code
          , p_project_id           => l_project_id
          , x_return_status        => l_return_status
        );

      END IF;

      --
      -- Set the Result Code to be returned to generic API
      --
      IF p_action_set_line_rec.status_code = 'PENDING' THEN

        x_action_line_result_code := pa_action_set_utils.G_PERFORMED_COMPLETE;

      ELSIF p_action_set_line_rec.status_code = 'REVERSE_PENDING' THEN

        IF p_action_set_line_rec.action_code = 'ADVERTISEMENT_REMOVE_ADV' OR
           p_action_set_line_rec.action_code = 'ADVERTISEMENT_UPDATE_SP' THEN
          x_action_line_result_code := pa_action_set_utils.G_REVERSED_CUSTOM_AUDIT;
        ELSIF (p_action_set_line_rec.action_code = 'ADVERTISEMENT_SEND_EMAIL' OR
               p_action_set_line_rec.action_code = 'ADVERTISEMENT_SEND_NTF_PERSON' OR
               p_action_set_line_rec.action_code = 'ADVERTISEMENT_SEND_NTF_ROLE')
              AND l_return_status = FND_API.G_RET_STS_ERROR THEN
          x_action_line_result_code := pa_action_set_utils.G_REVERSED_CUSTOM_AUDIT;
        ELSE
          x_action_line_result_code := pa_action_set_utils.G_REVERSED_DEFAULT_AUDIT;
        END IF;

      ELSE -- update pending

        IF p_action_set_line_rec.action_code = 'ADVERTISEMENT_REMOVE_ADV' OR
           p_action_set_line_rec.action_code = 'ADVERTISEMENT_UPDATE_SP' THEN
          x_action_line_result_code := pa_action_set_utils.G_UPDATED_CUSTOM_AUDIT;
        ELSIF (p_action_set_line_rec.action_code = 'ADVERTISEMENT_SEND_EMAIL' OR
               p_action_set_line_rec.action_code = 'ADVERTISEMENT_SEND_NTF_PERSON' OR
               p_action_set_line_rec.action_code = 'ADVERTISEMENT_SEND_NTF_ROLE')
              AND l_return_status = FND_API.G_RET_STS_ERROR THEN
          x_action_line_result_code := pa_action_set_utils.G_UPDATED_CUSTOM_AUDIT;
        ELSE
          x_action_line_result_code := pa_action_set_utils.G_UPDATED_DEFAULT_AUDIT;
        END IF;

      END IF;  -- action line status

  ELSE -- condition met
    x_action_line_result_code := pa_action_set_utils.G_NOT_PERFORMED;
  END IF;

  x_action_line_audit_tbl := g_action_line_audit_tbl;

  --dbms_output.put_line('result code = '||x_action_line_result_code);

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

 EXCEPTION
    WHEN OTHERS THEN

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ADVERTISEMENTS_PUB.Perform_Adv_Action_Set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );

       x_action_line_result_code := pa_action_set_utils.G_NOT_PERFORMED;
       RAISE;  -- This is optional depending on the needs

 END Perform_Action_Set_Line;


----------------------------------------------------------------------
-- Procedure
--   Reevaluate Advertisement Action Set
--
-- Purpose
--   Re-evaluate the advertisement action lines on the requirement by
--   updating the statuses of the action lines based on the
--   condition and the new requirement start date.
----------------------------------------------------------------------
PROCEDURE Reevaluate_Adv_Action_Set (
  p_object_id                      IN  pa_action_sets.object_id%TYPE
, p_object_type                    IN  pa_action_sets.object_type%TYPE
, p_new_object_start_date          IN  DATE
, p_validate_only                  IN  VARCHAR2    := FND_API.G_TRUE
, p_api_version                    IN  NUMBER      := 1.0
, p_init_msg_list                  IN  VARCHAR2    := FND_API.G_FALSE
, p_commit                         IN  VARCHAR2    := FND_API.G_FALSE
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_project_id                pa_project_assignments.project_id%TYPE;
  l_start_date                pa_project_assignments.start_date%TYPE;
  l_adv_action_set_status_code  pa_action_sets.status_code%TYPE;
  l_adv_action_set_start_date   pa_action_sets.actual_start_date%TYPE;
  l_action_set_id             pa_action_sets.action_set_id%TYPE;
  l_action_set_line_id_tbl    pa_action_set_utils.number_tbl_type;
  l_action_status_code_tbl    pa_action_set_utils.varchar_tbl_type;
  l_condition_date_tbl        pa_action_set_utils.date_tbl_type;
  l_action_line_cond_id_tbl   pa_action_set_utils.number_tbl_type;
  l_action_set_template_flag  VARCHAR2(1);
  l_msg_index_out             NUMBER;

  --cursor to get the related details of the requirement
  CURSOR get_req_action_set_info IS
  SELECT pa.project_id,
         pa.start_date,
         ast.status_code,
         ast.actual_start_date,
         ast.action_set_id,
         ast.action_set_template_flag
  FROM   pa_project_assignments pa,
         pa_action_sets ast
  WHERE  pa.assignment_id = p_object_id
  AND    ast.object_id = p_object_id
  AND    ast.object_type = p_object_type
  AND    ast.action_set_type_code = 'ADVERTISEMENT'
  AND    ast.status_code <> 'DELETED';

 BEGIN

  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.WRITE_LOG(x_Module => 'pa.plsql.PA_ADVERTISEMENTS_PUB.Reevaluate_Adv_Action_Set.begin',x_Msg => 'in PA_ADVERTISEMENTS_PUB.Reevaluate_Adv_Action_Set', x_Log_Level => 6);
  END IF;

  --initialize the return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialise the error stack
  PA_DEBUG.init_err_stack('PA_ADVERTISEMENTS_PUB.Reevaluate_Adv_Action_Set');

  --get the related details of the requirement
  OPEN get_req_action_set_info;
   FETCH get_req_action_set_info INTO
     l_project_id,
     l_start_date,
     l_adv_action_set_status_code,
     l_adv_action_set_start_date,
     l_action_set_id,
     l_action_set_template_flag;
  CLOSE get_req_action_set_info;

  --get the action lines on the requirement if the advertisement
  --action set has started and is not closed
  IF (l_adv_action_set_status_code <> 'NOT_STARTED'
      AND l_adv_action_set_status_code <> 'CLOSED')
      AND l_adv_action_set_start_date IS NOT NULL THEN

    -- re-order the action lines and generate the new condition dates
    PA_ADVERTISEMENTS_PVT.Order_Adv_Action_Lines (
       p_action_set_id                => l_action_set_id
     , p_action_set_template_flag     => l_action_Set_template_flag
     , p_object_start_date            => p_new_object_start_date
     , p_action_set_status_code       => l_adv_action_set_status_code
     , p_action_set_actual_start_date => l_adv_action_set_start_date
     , x_return_status                => l_return_status
    );
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- get all completed action lines whose conditions are no longer met
    SELECT asl.action_set_line_id, 'UPDATE_PENDING', aslc.condition_date, aslc.action_set_line_condition_id
    BULK COLLECT INTO l_action_set_line_id_tbl, l_action_status_code_tbl, l_condition_date_tbl, l_action_line_cond_id_tbl
    FROM pa_action_set_lines asl,
         pa_action_set_line_cond aslc
    WHERE asl.action_set_id = l_action_set_id
      AND asl.status_code = 'COMPLETE'
      AND asl.action_set_line_id = aslc.action_set_line_id
      AND aslc.condition_date > SYSDATE;

    -- bulk udpate advertisement action line status and condition date
    PA_ACTION_SETS_PVT.Bulk_Update_Line_Status(
        p_action_set_line_id_tbl => l_action_set_line_id_tbl
       ,p_line_status_tbl        => l_action_status_code_tbl
       ,x_return_status          => l_return_status
    );
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    PA_ACTION_SETS_PVT.Bulk_Update_Condition_Date(
        p_action_line_condition_id_tbl  => l_action_line_cond_id_tbl
       ,p_condition_date_tbl            => l_condition_date_tbl
       ,x_return_status                 => l_return_status
    );
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- reset the plsql tables
    l_action_set_line_id_tbl.DELETE;
    l_action_status_code_tbl.DELETE;
    l_condition_date_tbl.DELETE;
    l_action_line_cond_id_tbl.DELETE;

    -- Bug 2450716: PJ.J:B1:AVT: SHIFTING DURATION IS FIRING
    --              THE WRONG ADVT. ACTION LINE
    -- Bulk update the line status and condition date for lines that
    -- were reversed due to Cancel Advertisement and the condition
    -- is no longer met
    -- These lines will be in REVERSED status with deleted_flag <> 'Y'
    SELECT asl.action_set_line_id, 'PENDING', aslc.condition_date, aslc.action_set_line_condition_id
    BULK COLLECT INTO l_action_set_line_id_tbl, l_action_status_code_tbl, l_condition_date_tbl, l_action_line_cond_id_tbl
    FROM pa_action_set_lines asl,
         pa_action_set_line_cond aslc
    WHERE asl.action_set_id = l_action_set_id
      AND asl.status_code = 'REVERSED'
      AND nvl(asl.line_deleted_flag, 'N') = 'N'
      AND asl.action_set_line_id = aslc.action_set_line_id
      AND aslc.condition_date > SYSDATE;

    PA_ACTION_SETS_PVT.Bulk_Update_Line_Status(
        p_action_set_line_id_tbl => l_action_set_line_id_tbl
       ,p_line_status_tbl        => l_action_status_code_tbl
       ,x_return_status          => l_return_status
    );
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    PA_ACTION_SETS_PVT.Bulk_Update_Condition_Date(
        p_action_line_condition_id_tbl  => l_action_line_cond_id_tbl
       ,p_condition_date_tbl            => l_condition_date_tbl
       ,x_return_status                 => l_return_status
    );
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- call generic action set API to perform the action set again
    PA_ACTION_SETS_PUB.Perform_Single_Action_Set(
       p_action_set_id         => l_action_set_id
      ,p_action_set_type_code  => 'ADVERTISEMENT'
      ,p_object_id             => p_object_id
      ,p_object_type           => 'OPEN_ASSIGNMENT'
      ,p_validate_only         => p_validate_only
      ,p_commit                => p_commit
      ,p_init_msg_list         => FND_API.G_FALSE
      ,x_return_status         => l_return_status
      ,x_msg_count             => l_msg_count
      ,x_msg_data              => l_msg_data);
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  -- If there are any messages in the stack then set x_return_status

  IF FND_MSG_PUB.Count_Msg > 0  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

 -- Put any message text from message stack into the Message ARRAY
 EXCEPTION
    WHEN OTHERS THEN

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ADVERTISEMENTS_PUB.Reevaluate_Adv_Action_Set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs

 END Reevaluate_Adv_Action_Set;


----------------------------------------------------------------------
-- Function
--   Is Action Set Started On Apply
--
-- Purpose
--   Check if the action set should be started upon application.
----------------------------------------------------------------------
FUNCTION Is_Action_Set_Started_On_Apply(
 p_action_set_type_code   IN pa_action_sets.action_set_type_code%TYPE
,p_object_type            IN pa_action_sets.object_type%TYPE
,p_object_id              IN pa_action_sets.object_id%TYPE
) RETURN VARCHAR2 IS

 l_action_set_start_flag  VARCHAR2(1);

BEGIN

    pa_debug.init_err_stack ('PA_ADVERTISEMENTS_PUB.Is_Action_Set_Started_On_Apply');


  IF PA_ADVERTISEMENTS_PUB.g_start_adv_action_set_flag IS NOT NULL THEN
    l_action_set_start_flag := PA_ADVERTISEMENTS_PUB.g_start_adv_action_set_flag;
  ELSE

    SELECT proj.start_adv_action_set_flag
    INTO l_action_set_start_flag
    FROM pa_project_assignments asgn,
         pa_projects_all proj
    WHERE asgn.assignment_id = p_object_id
      AND asgn.project_id = proj.project_id;

  END IF;

  PA_ADVERTISEMENTS_PUB.g_start_adv_action_set_flag := NULL;

  RETURN l_action_set_start_flag;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'N';
  WHEN OTHERS THEN
    RETURN 'N';
 END Is_Action_Set_Started_On_Apply;

END PA_ADVERTISEMENTS_PUB;

/

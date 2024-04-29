--------------------------------------------------------
--  DDL for Package Body PA_ADVERTISEMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ADVERTISEMENTS_PVT" AS
--$Header: PARAVPVB.pls 120.9.12010000.3 2010/03/24 09:42:12 sugupta ship $
--

----------------------------------------------------------------------
-- Procedure
--   Order Advertisement Action Lines
--
-- Purpose
--   Order the action lines of an advertisement action set
--   or an advertisement action lines on a requirement that have been
--   inserted into pa_action_set_lines table.
----------------------------------------------------------------------
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */

PROCEDURE Order_Adv_Action_Lines (
  p_action_set_id                  IN  pa_action_sets.action_set_id%TYPE
, p_action_set_template_flag       IN  pa_action_sets.action_set_template_flag%TYPE :=NULL
, p_object_start_date              IN  DATE        := NULL
, p_action_set_status_code         IN  pa_action_sets.status_code%TYPE := NULL
, p_action_set_actual_start_date   IN  pa_action_sets.actual_start_date%TYPE := NULL
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS


  TYPE number_tbl                     IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;
  TYPE date_tbl                       IS TABLE OF DATE
   INDEX BY BINARY_INTEGER;
  TYPE varchar_tbl                    IS TABLE OF VARCHAR2(150)
   INDEX BY BINARY_INTEGER;

  i                             NUMBER;
  l_action_line_id_tbl          number_tbl;
  l_action_code_tbl             varchar_tbl;
  l_condition_code_tbl          varchar_tbl;
  l_condition_attribute1_tbl    varchar_tbl;
  l_condition_attribute2_tbl    varchar_tbl;
  l_action_line_id_tbl2         pa_action_set_utils.number_tbl_type;
  l_condition_date_tbl2         pa_action_set_utils.date_tbl_type;
  l_action_line_number_tbl2     pa_action_set_utils.number_tbl_type;
  l_start_date                  pa_project_assignments.start_date%TYPE;
  l_adv_action_set_status_code  pa_action_sets.status_code%TYPE;
  l_adv_action_set_start_date   pa_action_sets.actual_start_date%TYPE;
  l_action_line_cond_id_tbl     pa_action_set_utils.number_tbl_type;
  l_action_line_cond_id_tbl2    pa_action_set_utils.number_tbl_type;
  l_return_status               VARCHAR2(1);

  --cursor to get the related details of the requirement
  CURSOR get_req_action_set_info IS
  SELECT pa.start_date,
         ast.status_code,
         ast.actual_start_date
  FROM   pa_project_assignments pa,
         pa_action_sets ast
  WHERE  pa.assignment_id = ast.object_id
  AND    ast.action_set_id = p_action_set_id;

 BEGIN

   -- Initialize the Error Stack
   PA_DEBUG.init_err_stack('PA_ADVERTISEMENTS_PVT.Order_Adv_Action_Lines');

 -- 4537865 : Initiliaze x_return_status
   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   --Log Message
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ADVERTISEMENTS_PVT.Order_Adv_Action_Lines.begin'
                        ,x_msg         => 'Beginning of PA_ADVERTISEMENTS_PVT.Order_Adv_Action_Lines'
                        ,x_log_level   => 5);
   END IF;

   -- Initialize the return status to success
   l_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Clear the temporary table
   DELETE FROM pa_adv_action_lines_order_temp;

   --get the related details of the requirement
   IF (p_action_set_template_flag='N' OR p_action_set_template_flag IS NULL)
      AND (p_object_start_date IS NULL OR p_action_set_status_code IS NULL OR p_action_set_actual_start_date IS NULL) THEN

     --dbms_output.put_line('Fetch requirement action set details');
     OPEN get_req_action_set_info;
      FETCH get_req_action_set_info INTO
       l_start_date,
       l_adv_action_set_status_code,
       l_adv_action_set_start_date;
     CLOSE get_req_action_set_info;
   ELSE

     l_start_date := p_object_start_date;
     l_adv_action_set_status_code := p_action_set_status_code;
     l_adv_action_set_start_date := p_action_set_actual_start_date;
   END IF;

   IF (p_action_set_template_flag='N' OR p_action_set_template_flag IS NULL)
     AND l_adv_action_set_start_date IS NOT NULL THEN

     -- if the object's action set has been started,
     -- get the current and previous action sets' actions
     SELECT asl.action_set_line_id,
          asl.action_code,
          aslc.condition_code,
          aslc.condition_attribute1,
          aslc.condition_attribute2,
          aslc.action_set_line_condition_id
     BULK COLLECT INTO l_action_line_id_tbl,
          l_action_code_tbl,
          l_condition_code_tbl,
          l_condition_attribute1_tbl,
          l_condition_attribute2_tbl,
          l_action_line_cond_id_tbl
     FROM pa_action_set_lines asl,
          pa_action_set_line_cond aslc,
          pa_action_sets asets,
          pa_action_sets asets2
     WHERE asets2.action_set_id = p_action_set_id
       AND asets.object_id = asets2.object_id
       AND asets.object_type = 'OPEN_ASSIGNMENT'
       AND asets.action_set_type_code = 'ADVERTISEMENT'
       AND asl.action_set_id = asets.action_set_id
       AND asl.action_set_line_id = aslc.action_set_line_id;

     --dbms_output.put_line('GET ALL number of lines: '||l_action_line_id_tbl.COUNT);


  ELSE

     -- if the action set is a template or if the object's
     -- action set has not been started,
     -- get only the current action set's action as
     -- there is either no previous action set or
     -- the actions on the previous action set are deleted.
     SELECT asl.action_set_line_id,
          asl.action_code,
          aslc.condition_code,
          aslc.condition_attribute1,
          aslc.condition_attribute2,
          aslc.action_set_line_condition_id
     BULK COLLECT INTO l_action_line_id_tbl,
          l_action_code_tbl,
          l_condition_code_tbl,
          l_condition_attribute1_tbl,
          l_condition_attribute2_tbl,
          l_action_line_cond_id_tbl
     FROM pa_action_set_lines asl,
          pa_action_set_line_cond aslc
     WHERE asl.action_set_id = p_action_set_id
       AND asl.action_set_line_id = aslc.action_set_line_id;

     --dbms_output.put_line('GET CURRENT number of lines: '||l_action_line_id_tbl.COUNT);


  END IF;

  IF l_action_line_id_tbl.COUNT > 0 THEN

   -- CASE 1: Order the action lines based on the condition date if:
   --         1) the object type is requirement, and
   --         2) the action set has been started on the requirement, and
   --         3) there are more than 1 action lines
   IF (p_action_set_template_flag='N' OR p_action_set_template_flag IS NULL)
     AND l_adv_action_set_start_date IS NOT NULL THEN

       --dbms_output.put_line('Order action set lines for a started requirement action set.');

       -- Derive the condition dates and insert the action lines
       -- into the temporary table.
       -- Truncate the condition dates to make sure all date records
       -- are set to 12 am. This facilates the ordering of special
       -- actions like 'Remove Advertisement' and 'Escalate to Next Level'.
       FORALL i IN l_action_line_id_tbl.FIRST .. l_action_line_id_tbl.LAST
         INSERT INTO pa_adv_action_lines_order_temp (
             action_set_line_id
           , action_code
           , condition_code
           , condition_attribute1
           , condition_attribute2
           , condition_date
           , action_set_line_condition_id
         )
         VALUES (
             l_action_line_id_tbl(i)
           , l_action_code_tbl(i)
           , l_condition_code_tbl(i)
           , l_condition_attribute1_tbl(i)
           , l_condition_attribute2_tbl(i)
           , DECODE(l_condition_code_tbl(i),
              'ADVERTISEMENT_DAYS_OPEN', TRUNC(l_adv_action_set_start_date+l_condition_attribute1_tbl(i)),
              'ADVERTISEMENT_DAYS_REMAINING', TRUNC(l_start_date-l_condition_attribute2_tbl(i)),
              'ADVERTISEMENT_DAYS_OPN_REMAIN', TRUNC(LEAST(l_adv_action_set_start_date+l_condition_attribute1_tbl(i), l_start_date-l_condition_attribute2_tbl(i))))
           , l_action_line_cond_id_tbl(i)
         );

       -- Add 0.1 and 0.2 day to the 'Escalate to Next Level' and
       -- 'Remove Advertisement' action lines respectively to
       -- make sure these lines are ordered after other action
       -- lines if their condition dates are the same
       UPDATE pa_adv_action_lines_order_temp
       SET condition_date = condition_date+0.1
       WHERE action_code = 'ADVERTISEMENT_ESC_TO_NEXT_LVL';

       UPDATE pa_adv_action_lines_order_temp
       SET condition_date = condition_date+0.2
       WHERE action_code = 'ADVERTISEMENT_REMOVE_ADV';

       -- Bulk collect the sorted action lines into plsql tables
       SELECT action_set_line_id, TRUNC(condition_date), action_set_line_condition_id
       BULK COLLECT INTO l_action_line_id_tbl2, l_condition_date_tbl2, l_action_line_cond_id_tbl2
       FROM pa_adv_action_lines_order_temp
       ORDER BY condition_date;

   -- CASE 2: Order the action lines by Days Open and then Days
   --         Remaining if:
   --         1) the object type is template or
   --            the object type is requirement and the action set has not
   --            been started on the requirement, and
   --         2) there are more than 1 action lines
   ELSE

     --dbms_output.put_line('Order action set lines for a template action set.');

       -- Insert the action lines into the temporary table.
       FORALL i IN l_action_line_id_tbl.FIRST .. l_action_line_id_tbl.LAST
         INSERT INTO pa_adv_action_lines_order_temp (
             action_set_line_id
           , action_code
           , condition_code
           , condition_attribute1
           , condition_attribute2
           , condition_date
           , action_set_line_condition_id
         )
         VALUES (
             l_action_line_id_tbl(i)
           , l_action_code_tbl(i)
           , l_condition_code_tbl(i)
           , l_condition_attribute1_tbl(i)
           , l_condition_attribute2_tbl(i)
           , null
           , l_action_line_cond_id_tbl(i)
         );

       -- Bulk collect the sorted action lines into plsql tables
       SELECT action_set_line_id, condition_date, action_set_line_condition_id
       BULK COLLECT INTO l_action_line_id_tbl2, l_condition_date_tbl2, l_action_line_cond_id_tbl2
       FROM pa_adv_action_lines_order_temp
       ORDER BY to_number(condition_attribute1), to_number(condition_attribute2) desc;

   END IF;

   -- For both CASE 1 and CASE 2, now the plsql tables contain the sorted
   -- action lines and the record index in the plsql tables will be
   -- the correct action line number
   -- Call generic actions set API to update the condition date and line number

   SELECT rownum
   BULK COLLECT INTO l_action_line_number_tbl2
   FROM pa_adv_action_lines_order_temp;

   --dbms_output.put_line('number of lines: '||l_action_line_cond_id_tbl2.COUNT);
   --dbms_output.put_line('number of lines2: '||l_condition_date_tbl2.COUNT);
   --dbms_output.put_line('number of lines3: '||l_action_line_id_tbl2.COUNT);
   --dbms_output.put_line('number of lines4: '||l_action_line_number_tbl2.COUNT);

   PA_ACTION_SETS_PVT.Bulk_Update_Condition_Date(
        p_action_line_condition_id_tbl  => l_action_line_cond_id_tbl2
       ,p_condition_date_tbl            => l_condition_date_tbl2
       ,x_return_status                 => l_return_status
   );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   PA_ACTION_SETS_PVT.Bulk_Update_Line_Number(
        p_action_set_line_id_tbl     => l_action_line_id_tbl2
       ,p_line_number_tbl            => l_action_line_number_tbl2
       ,x_return_status              => x_return_status
   );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

  END IF; -- more than 0 line
 -- 4537865 : Included Exception Block
 EXCEPTION
	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ADVERTISEMENTS_PVT'
				, p_procedure_name => 'Order_Adv_Action_Lines'
				, p_error_text	=> SUBSTRB(SQLERRM,1,240));
	RAISE ;
 END Order_Adv_Action_Lines;


----------------------------------------------------------------------
-- Procedure
--   Perform Publish To All
--
-- Purpose
--   Advertise to everyone
----------------------------------------------------------------------
PROCEDURE Publish_To_All (
  p_action_set_line_id             IN  pa_action_set_lines.action_set_line_id%TYPE
, p_object_id                      IN  pa_action_sets.object_id%TYPE
, p_action_code                    IN  pa_action_set_lines.action_code%TYPE
, p_action_status_code             IN  pa_action_set_lines.status_code%TYPE
, p_insert_audit_flag              IN  VARCHAR2 := 'T'
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

 l_return_status          VARCHAR2(1);
 l_action_line_audit_rec  pa_action_set_utils.insert_audit_lines_rec_type;
 l_index                  NUMBER;

 BEGIN

   -- Initialize the Error Stack
   PA_DEBUG.init_err_stack('PA_ADVERTISEMENTS_PVT.Publish_To_All');

   --dbms_output.put_line('PA_ADVERTISEMENTS_PVT.publish to all');

   --Log Message
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ADVERTISEMENTS_PVT.Publish_To_All.begin'
                        ,x_msg         => 'Beginning of PA_ADVERTISEMENTS_PVT.Publish_To_All'
                        ,x_log_level   => 5);
   END IF;

   -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Handle PENDING action line only as REVERSE_PENDING and UPDATE_PENDING
   -- lines can be handled generically by the action set model.
   -- Insert the Publish to All action into audit table
   --
   IF p_action_status_code = 'PENDING' AND p_insert_audit_flag = 'T' THEN

     -- insert the single audit line into the global audit record
     l_action_line_audit_rec.reason_code                 := 'CONDITION_MET';
     l_action_line_audit_rec.action_code                 := p_action_code;
     l_action_line_audit_rec.audit_display_attribute     := NULL;
     l_action_line_audit_rec.audit_attribute             := NULL;
     l_action_line_audit_rec.reversed_action_set_line_id := NULL;
     l_index := PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl.COUNT;
     PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl(l_index) := l_action_line_audit_rec;

   END IF;
 -- 4537865 : Included Exception Block
 EXCEPTION
        WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ADVERTISEMENTS_PVT'
                                , p_procedure_name => 'Publish_To_All'
                                , p_error_text  => SUBSTRB(SQLERRM,1,240));
        RAISE ;
 END Publish_To_All;



----------------------------------------------------------------------
-- Procedure
--   Perform Publish To Organizations
--
-- Purpose
--   Advertise to all resources in organizations under the starting
--   organization in the organization hierarchy.
----------------------------------------------------------------------
PROCEDURE Publish_To_Organizations (
  p_action_set_line_id             IN  pa_action_set_lines.action_set_line_id%TYPE
, p_object_id                      IN  pa_action_sets.object_id%TYPE
, p_action_code                    IN  pa_action_set_lines.action_code%TYPE
, p_action_status_code             IN  pa_action_set_lines.status_code%TYPE
, p_org_hierarchy_version_id       IN  per_org_structure_versions.org_structure_version_id%TYPE
, p_starting_organization_id       IN  hr_organization_units.organization_id%TYPE := NULL
, p_insert_audit_flag              IN  VARCHAR2 := 'T'
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
--, x_msg_count                      OUT NUMBER
--, x_msg_data                       OUT VARCHAR2
) IS

  TYPE number_tbl                     IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;
  TYPE varchar_tbl                    IS TABLE OF VARCHAR2(150)
   INDEX BY BINARY_INTEGER;

  l_organization_name_tbl  varchar_tbl;
  l_organization_id_tbl    number_tbl;
  l_action_line_audit_rec  pa_action_set_utils.insert_audit_lines_rec_type;
  l_index                  NUMBER;
  l_encoded_message_text   VARCHAR2(2000);
  l_msg_index_out          NUMBER;

  -- cursor to get all organizations under the specified starting
  -- organization in the organization hierarchy
  CURSOR get_all_child_orgs_in_hier IS
  -- SELECT child_organization_id, pa_expenditures_utils.GetOrgTlName(child_organization_id)   -- Commented for Bug 4866284
  SELECT child_organization_id, pa_resource_utils.get_organization_name(child_organization_id) -- Added for Bug 4866284
  FROM pa_org_hierarchy_denorm
  WHERE org_hierarchy_version_id = p_org_hierarchy_version_id
    AND parent_organization_id = p_starting_organization_id
    AND pa_org_use_type = 'EXPENDITURES';

 BEGIN

   --dbms_output.put_line('begin of PA_ADVERTISEMENTS_PVT.Publish_To_Organizations');

   -- Initialize the Error Stack
   PA_DEBUG.init_err_stack('PA_ADVERTISEMENTS_PVT.Publish_To_Organizations');

   --Log Message
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ADVERTISEMENTS_PVT.Publish_To_Organizations'
                        ,x_msg         => 'Beginning of PA_ADVERTISEMENTS_PVT.Publish_To_Organizations'
                        ,x_log_level   => 5);
   END IF;

   -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   --
   -- Handle PENDING action line only as REVERSE_PENDING and UPDATE_PENDING
   -- lines can be handled generically by the action set model.
   --
   IF p_action_status_code = 'PENDING' THEN

       -- get all the organizations under the specified starting
       -- organization in the organization hierarchy
       OPEN get_all_child_orgs_in_hier;
        FETCH get_all_child_orgs_in_hier BULK COLLECT INTO l_organization_id_tbl, l_organization_name_tbl;
       CLOSE get_all_child_orgs_in_hier;

       -- ERROR: Insert error into the stack when there is
       --        no organization found with the specified criteria
       IF l_organization_id_tbl.COUNT = 0 THEN

         -- insert error into error stack, get the encoded message
         -- and insert into audit table
         PA_ACTION_SET_UTILS.Add_Message(
                       p_app_short_name => 'PA'
              ,p_msg_name   => 'PA_ADV_PUB_ORG_ERR'
         );

       -- Insert the organizations found into audit table
       ELSIF p_insert_audit_flag = 'T' THEN

         FOR i IN l_organization_id_tbl.FIRST..l_organization_id_tbl.LAST LOOP
           -- insert into into the global audit record
           l_action_line_audit_rec.reason_code                 := 'CONDITION_MET';
           l_action_line_audit_rec.action_code                 := p_action_code;
           l_action_line_audit_rec.audit_display_attribute     := l_organization_name_tbl(i);
           l_action_line_audit_rec.audit_attribute             := l_organization_id_tbl(i);
           l_action_line_audit_rec.reversed_action_set_line_id := NULL;
           l_index := PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl.COUNT;
           PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl(l_index) := l_action_line_audit_rec;
         END LOOP;

         --dbms_output.put_line('number of records in audit global tbl: '||PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl.COUNT);

       END IF; -- l_organization_id_tbl.count = 0

       -- Insert the error into the audit table
       -- and return error status if there is error message in the stack
       IF FND_MSG_PUB.Count_Msg > 0 THEN
         IF p_insert_audit_flag = 'T' THEN
           FND_MSG_PUB.get (
                       p_encoded        => FND_API.G_TRUE
                      ,p_msg_index      => FND_MSG_PUB.Count_Msg
                      ,p_data           => l_encoded_message_text
                      ,p_msg_index_out  => l_msg_index_out);

           l_action_line_audit_rec.reason_code           := 'CONDITION_MET';
           l_action_line_audit_rec.action_code           := p_action_code;
           l_action_line_audit_rec.encoded_error_message := l_encoded_message_text;
           l_index := PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl.COUNT;
           PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl(l_index) := l_action_line_audit_rec;
         END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       END IF; -- IF FND_MSG_PUB.Count_Msg > 0

   END IF; -- if status is PENDING
 -- 4537865 : Included Exception Block
 EXCEPTION
        WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ADVERTISEMENTS_PVT'
                                , p_procedure_name => 'Publish_To_Organizations'
                                , p_error_text  => SUBSTRB(SQLERRM,1,240));
        RAISE ;
 END Publish_To_Organizations;

----------------------------------------------------------------------
-- Procedure
--   Perform Escalate to Next Level
--
-- Purpose
--   Advertise to all resources in organizations under a higher starting
--   organization in the organization hierarchy.
----------------------------------------------------------------------
PROCEDURE Escalate_to_Next_Level (
  p_action_set_line_id             IN  pa_action_set_lines.action_set_line_id%TYPE
, p_action_set_line_number         IN  pa_action_set_lines.action_set_line_number%TYPE
, p_action_set_id                  IN  pa_action_sets.action_set_id%TYPE
, p_action_set_line_rec_ver_num    IN  pa_action_set_lines.record_version_number%TYPE
, p_object_id                      IN  pa_action_sets.object_id%TYPE
, p_action_code                    IN  pa_action_set_lines.action_code%TYPE
, p_action_status_code             IN  pa_action_set_lines.status_code%TYPE
, p_action_set_line_cond_tbl       IN  pa_action_set_utils.action_line_cond_tbl_type
, p_insert_audit_flag              IN  VARCHAR2 := 'T'
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

  l_org_hierarchy_version_id  per_org_structure_versions.org_structure_version_id%TYPE;
  l_start_org_id              hr_organization_units.organization_id%TYPE;
  l_new_start_org_id          hr_organization_units.organization_id%TYPE;
  l_action_line_audit_rec     pa_action_set_utils.insert_audit_lines_rec_type;
  l_index                     NUMBER;
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_encoded_message_text   VARCHAR2(2000);
  l_msg_index_out          NUMBER;

  TYPE number_tbl                     IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;
  TYPE varchar_tbl                    IS TABLE OF VARCHAR2(240)
   INDEX BY BINARY_INTEGER;

  l_organization_name_tbl  varchar_tbl;
  l_organization_id_tbl    number_tbl;

  -- cursor to get the next organization up in the
  -- specified Organization Hierarchy
  CURSOR get_next_start_org(c_org_hierarchy_version_id NUMBER, c_start_org_id NUMBER) IS
  SELECT organization_id_parent
  FROM per_org_structure_elements
  WHERE org_structure_version_id = c_org_hierarchy_version_id
    AND organization_id_child = c_start_org_id;

  -- cursor to get all organizations under the specified starting
  -- organization in the organization hierarchy that have not been published to
  CURSOR get_child_orgs_in_hier(c_org_hierarchy_version_id NUMBER, c_start_org_id NUMBER) IS
  -- SELECT ohd.child_organization_id, pa_expenditures_utils.GetOrgTlName(ohd.child_organization_id)   -- Commented for Bug 4866284
  SELECT ohd.child_organization_id, pa_resource_utils.get_organization_name(ohd.child_organization_id) -- Added for Bug 4866284
  FROM pa_org_hierarchy_denorm ohd
  WHERE ohd.org_hierarchy_version_id = c_org_hierarchy_version_id
    AND ohd.parent_organization_id = c_start_org_id
    AND ohd.pa_org_use_type = 'EXPENDITURES'
  MINUS
  -- SELECT ohd.child_organization_id, pa_expenditures_utils.GetOrgTlName(ohd.child_organization_id)   -- Commented for Bug 4866284
  SELECT ohd.child_organization_id, pa_resource_utils.get_organization_name(ohd.child_organization_id) -- Added for Bug 4866284
  FROM pa_org_hierarchy_denorm ohd,
       pa_action_set_line_aud asla
  WHERE ohd.org_hierarchy_version_id = c_org_hierarchy_version_id
    AND ohd.parent_organization_id = c_start_org_id
    AND ohd.pa_org_use_type = 'EXPENDITURES'
    AND ohd.child_organization_id = to_number(asla.audit_attribute)
    AND (asla.action_code = 'ADVERTISEMENT_PUB_TO_START_ORG'
     OR  asla.action_code = 'ADVERTISEMENT_ESC_TO_NEXT_LVL')
    AND asla.active_flag = 'Y'
    AND asla.object_id = p_object_id
    AND asla.object_type = 'OPEN_ASSIGNMENT'
    AND asla.action_set_type_code = 'ADVERTISEMENT';

 BEGIN

   --dbms_output.put_line('PA_ADVERTISEMENTS_PVT.publish to all');

   -- Initialize the Error Stack
   PA_DEBUG.init_err_stack('PA_ADVERTISEMENTS_PVT.Escalate_to_Next_Level');

   --Log Message
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ADVERTISEMENTS_PVT.Escalate_to_Next_Level'
                         ,x_msg         => 'Beginning of PA_ADVERTISEMENTS_PVT.Escalate_to_Next_Level'
                         ,x_log_level   => 5);
   END IF;

   -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Handle PENDING action line only as REVERSE_PENDING and UPDATE_PENDING
   -- lines can be handled generically by the action set model.
   --
   IF p_action_status_code = 'PENDING' THEN

     -- Get the action lines with status equals Pending or Performed
     -- action code equals Publish to Organization or Escalate to Next Level
     -- and action set line number is the maximum number less than the
     -- current action line number
     SELECT to_number(action_attribute1), to_number(action_attribute2) into
            l_org_hierarchy_version_id, l_start_org_id
     FROM pa_action_set_lines
     WHERE action_set_id = p_action_set_id
     AND action_set_line_number = (
          SELECT MAX(action_set_line_number)
          FROM pa_action_set_lines
          WHERE (action_code = 'ADVERTISEMENT_PUB_TO_START_ORG'
             OR action_code = 'ADVERTISEMENT_ESC_TO_NEXT_LVL')
            AND (status_code = 'PENDING'
             OR status_code = 'COMPLETE')
            AND ACTION_SET_LINE_NUMBER < p_action_set_line_number
            AND action_set_id = p_action_set_id);

     --dbms_output.put_line('l_org_hierarchy_version_id '||l_org_hierarchy_version_id);
     --dbms_output.put_line('l_start_org_id ' || l_start_org_id);

     -- Find the next organization up in the specified Organization Hierarchy
     OPEN get_next_start_org(l_org_hierarchy_version_id, l_start_org_id);
      FETCH get_next_start_org INTO l_new_start_org_id;
     CLOSE get_next_start_org;

     --dbms_output.put_line('l_new_start_org_id ' || l_new_start_org_id);

     -- ERROR: Insert error into the stack when the next
     --        organization does not exist
     If l_new_start_org_id is null THEN

       -- insert error into error stack, get the encoded message
       -- and insert into audit table
       PA_ACTION_SET_UTILS.Add_Message(
                       p_app_short_name => 'PA'
              ,p_msg_name   => 'PA_ADV_ESC_LVL_ERR'
       );

     ELSE

       -- Update the current action line to store the new
       -- start_organization_id and org_hierarchy_version_id
       PA_ACTION_SETS_PUB.Update_Action_Set_Line (
          p_action_set_line_id        => p_action_set_line_id
         ,p_action_set_line_number    => p_action_set_line_number
         ,p_record_version_number     => p_action_set_line_rec_ver_num
         ,p_action_code               => p_action_code
         ,p_action_attribute1         => to_char(l_org_hierarchy_version_id)
         ,p_action_attribute2         => to_char(l_new_start_org_id)
         ,p_condition_tbl             => p_action_set_line_cond_tbl
         ,p_validate_only             => FND_API.G_FALSE
         ,p_commit                    => FND_API.G_FALSE
         ,p_init_msg_list             => FND_API.G_FALSE
         ,x_return_status             => x_return_status
         ,x_msg_count                 => l_msg_count
         ,x_msg_data                  => l_msg_data);

       --dbms_output.put_line('finding organizations to publish');

       -- publish to all child organizations exception the ones that
       -- have already been published to
       OPEN get_child_orgs_in_hier(l_org_hierarchy_version_id, l_new_start_org_id);
        FETCH get_child_orgs_in_hier
         BULK COLLECT INTO l_organization_id_tbl, l_organization_name_tbl;
       CLOSE get_child_orgs_in_hier;

       --dbms_output.put_line('finished finding organizations to publish');

       -- Insert organizations into audit table
       IF p_insert_audit_flag = 'T' THEN

           FOR i IN l_organization_id_tbl.FIRST..l_organization_id_tbl.LAST LOOP
             -- insert into into the global audit record
             l_action_line_audit_rec.reason_code                 := 'CONDITION_MET';
             l_action_line_audit_rec.action_code                 := p_action_code;
             l_action_line_audit_rec.audit_display_attribute     := l_organization_name_tbl(i);
             l_action_line_audit_rec.audit_attribute             := l_organization_id_tbl(i);
             l_action_line_audit_rec.reversed_action_set_line_id := NULL;
             l_index := PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl.COUNT;
             PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl(l_index) := l_action_line_audit_rec;
           END LOOP;

       END IF; -- if l_organization_id_tbl.COUNT = 0
     END IF; --if l_new_start_org_id is null

     --
     -- Insert the error into the audit table
     -- and return error status if there is error message in the stack
     --
     IF FND_MSG_PUB.Count_Msg > 0 THEN

       IF p_insert_audit_flag = 'T' THEN
         FND_MSG_PUB.get (
                       p_encoded        => FND_API.G_TRUE
                      ,p_msg_index      => FND_MSG_PUB.Count_Msg
                      ,p_data           => l_encoded_message_text
                      ,p_msg_index_out  => l_msg_index_out);

         l_action_line_audit_rec.reason_code           := 'CONDITION_MET';
         l_action_line_audit_rec.action_code           := p_action_code;
         l_action_line_audit_rec.encoded_error_message := l_encoded_message_text;
         l_index := PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl.COUNT;
         PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl(l_index) := l_action_line_audit_rec;
       END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

   END IF; -- if status is PENDING
 -- 4537865 : Included Exception Block
 EXCEPTION
        WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ADVERTISEMENTS_PVT'
                                , p_procedure_name => 'Escalate_To_Next_Level'
                                , p_error_text  => SUBSTRB(SQLERRM,1,240));
        RAISE ;
END Escalate_To_Next_Level;

----------------------------------------------------------------------
-- Procedure
--   Perform Publish To Staffing Managers
--
-- Purpose
--   Advertise to staffing managers of the specified organization.
----------------------------------------------------------------------
PROCEDURE Publish_To_Staffing_Managers (
  p_action_set_line_id             IN  pa_action_set_lines.action_set_line_id%TYPE
, p_object_id                      IN  pa_action_sets.object_id%TYPE
, p_action_code                    IN  pa_action_set_lines.action_code%TYPE
, p_action_status_code             IN  pa_action_set_lines.status_code%TYPE
, p_organization_id                IN  hr_organization_units.organization_id%TYPE
, p_insert_audit_flag              IN  VARCHAR2 := 'T'
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

  TYPE number_tbl                     IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;
  TYPE varchar_tbl                    IS TABLE OF VARCHAR2(240)
   INDEX BY BINARY_INTEGER;

  l_person_name_tbl           varchar_tbl;
  l_person_id_tbl             number_tbl;
  l_action_line_audit_rec     pa_action_set_utils.insert_audit_lines_rec_type;
  l_index                     NUMBER;
  l_encoded_message_text      VARCHAR2(2000);
  l_msg_index_out             NUMBER;

  -- cursor to get all people with resource authority
  -- in the given organization

  CURSOR get_people_with_proj_authority IS
  SELECT pro.person_name, pro.person_id
  FROM pa_people_role_on_orgs_v pro, per_people_f pf
  WHERE pro.organization_id = to_char(p_organization_id)
    AND pro.project_role_type = '3'
    AND sysdate between pro.start_date_active and
                        nvl(pro.end_date_active, sysdate)
    AND TRUNC(sysdate) between TRUNC(PF.EFFECTIVE_START_DATE) AND
                               TRUNC(PF.EFFECTIVE_END_DATE)
    AND nvl(PF.CURRENT_EMPLOYEE_FLAG,nvl(PF.CURRENT_NPW_FLAG,'N'))='Y'
    AND PF.person_id=pro.person_id;

/*  Changed the cursor as above for bug 4600093
  CURSOR get_people_with_proj_authority IS
  SELECT person_name, person_id
  FROM pa_people_role_on_orgs_v
  WHERE organization_id = to_char(p_organization_id)
    AND project_role_type = '3'
    AND sysdate between start_date_active and nvl(end_date_active, sysdate);
*/

 BEGIN

   --dbms_output.put_line('PA_ADVERTISEMENTS_PVT.publish to staffing manager');

   -- Initialize the Error Stack
   PA_DEBUG.init_err_stack('PA_ADVERTISEMENTS_PVT.Publish_To_Staffing_Managers');

   --Log Message
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ADVERTISEMENTS_PVT.Publish_To_Staffing_Managers'
                        ,x_msg         => 'Beginning of PA_ADVERTISEMENTS_PVT.Publish_To_Staffing_Managers'
                        ,x_log_level   => 5);
   END IF;

   -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Handle PENDING action line only as REVERSE_PENDING and UPDATE_PENDING
   -- lines can be handled generically by the action set model.
   --
   IF p_action_status_code = 'PENDING' THEN

     OPEN get_people_with_proj_authority;
      FETCH get_people_with_proj_authority
       BULK COLLECT INTO l_person_name_tbl, l_person_id_tbl;
     CLOSE get_people_with_proj_authority;

     -- ERROR: Insert error into the stack when there is no people
     --        with project authority in the organization
     IF l_person_id_tbl.COUNT = 0 THEN
       -- insert error to stack
       PA_ACTION_SET_UTILS.Add_Message(
                       p_app_short_name => 'PA'
              ,p_msg_name   => 'PA_ADV_PUB_SM_ERR'
       );

     ELSIF p_insert_audit_flag = 'T' THEN

       -- Insert the people into the global audit record
       FOR i IN l_person_id_tbl.FIRST..l_person_id_tbl.LAST LOOP
         l_action_line_audit_rec.reason_code           := 'CONDITION_MET';
         l_action_line_audit_rec.action_code                 := p_action_code;
         l_action_line_audit_rec.audit_display_attribute     := l_person_name_tbl(i);
         l_action_line_audit_rec.audit_attribute             := l_person_id_tbl(i);
         l_action_line_audit_rec.reversed_action_set_line_id := NULL;
         l_index := PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl.COUNT;
         PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl(l_index) := l_action_line_audit_rec;
       END LOOP;

     END IF; -- if l_person_id_tbl.COUNT = 0

     --
     -- Insert the error into the audit table
     -- and return error status if there is error message in the stack
     --
     IF FND_MSG_PUB.Count_Msg > 0 THEN
       IF p_insert_audit_flag = 'T' THEN
         FND_MSG_PUB.get (
                       p_encoded        => FND_API.G_TRUE
                      ,p_msg_index      => FND_MSG_PUB.Count_Msg
                      ,p_data           => l_encoded_message_text
                      ,p_msg_index_out  => l_msg_index_out);

         l_action_line_audit_rec.reason_code           := 'CONDITION_MET';
         l_action_line_audit_rec.action_code           := p_action_code;
         l_action_line_audit_rec.encoded_error_message := l_encoded_message_text;
         l_index := PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl.COUNT;
         PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl(l_index) := l_action_line_audit_rec;
       END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

   END IF; -- if status is PENDING
 -- 4537865 : Included Exception Block
 EXCEPTION
        WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ADVERTISEMENTS_PVT'
                                , p_procedure_name => 'Publish_To_Staffing_Managers'
                                , p_error_text  => SUBSTRB(SQLERRM,1,240));
        RAISE ;
END Publish_To_Staffing_Managers;


----------------------------------------------------------------------
-- Procedure
--   Perform Send Email
--
-- Purpose
--   Send the advertisement email to a specific email address.
----------------------------------------------------------------------
PROCEDURE Send_Email (
  p_action_set_line_id             IN  pa_action_set_lines.action_set_line_id%TYPE
, p_object_id                      IN  pa_action_sets.object_id%TYPE
, p_action_code                    IN  pa_action_set_lines.action_code%TYPE
, p_action_status_code             IN  pa_action_set_lines.status_code%TYPE
, p_email_address                  IN  VARCHAR2
, p_project_id                     IN  pa_projects_all.project_id%TYPE
, p_insert_audit_flag              IN  VARCHAR2 := 'T'
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

 l_return_status          VARCHAR2(1);
 l_wf_adhoc_user_name     VARCHAR2(240);
 l_wf_adhoc_display_name  VARCHAR2(240);
 l_wf_process             VARCHAR2(30);
 l_action_line_audit_rec  pa_action_set_utils.insert_audit_lines_rec_type;
 l_index                  NUMBER;
 l_encoded_message_text   VARCHAR2(2000);
 l_msg_index_out          NUMBER;
 l_action_status_code     VARCHAR2(30);

 --added for 4701745
 TYPE v_tab IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
 l_email_tab v_tab;

l_email_address VARCHAR2(4000) := p_email_address;
l_comma_pos NUMBER;
l_temp_email_address varchar(240);
i NUMBER := 0;
--end  for 4701745

 BEGIN
   --dbms_output.put_line('PA_ADVERTISEMENTS_PVT.send email');

   -- Initialize the Error Stack
   PA_DEBUG.init_err_stack('PA_ADVERTISEMENTS_PVT.Send_Email');

   --Log Message
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ADVERTISEMENTS_PVT.Send_Email'
                        ,x_msg         => 'Beginning of PA_ADVERTISEMENTS_PVT.Send_Email'
                        ,x_log_level   => 5);
   END IF;

   -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  /* bug 4701745*/

	IF instr(l_email_address, ',') > 0 THEN
		l_email_address := l_email_address || ',';

		WHILE nvl(length(l_email_address),-1) > 0 LOOP
				i := i + 1;
				l_comma_pos := instr(l_email_address, ',');
				l_temp_email_address := substr(l_email_address,1,l_comma_pos-1);
				l_email_tab(i) := trim(l_temp_email_address);
				l_email_address := substr(l_email_address, l_comma_pos+1);
		END LOOP;
	ELSE
		l_email_tab(1) := l_email_address;
	END IF;
 /*end bug 4701745 */

   -- create an adhoc user with the specified email address
   -- and set the notification preference to Plain Text Email
IF l_email_tab.COUNT > 0 THEN --added for 4701745

FOR j IN  l_email_tab.FIRST..l_email_tab.LAST LOOP  --added for 4701745

  IF l_email_tab(j) IS NOT NULL THEN --added for 4701745

	l_wf_adhoc_user_name:= null; --added for 4701745
	l_wf_adhoc_display_name:= null; --added for 4701745

   WF_DIRECTORY.CreateAdHocUser(
         name                      => l_wf_adhoc_user_name
       , display_name              => l_wf_adhoc_display_name
       , notification_preference   => 'MAILTEXT'
       , email_address             => l_email_tab(j)--p_email_address added for 4701745
       , expiration_date           => sysdate + 1);

   --dbms_output.put_line('ad hoc user created as '|| l_wf_adhoc_user_name);

   -- Start different wf process to send different email
   -- depending of the action line status
   IF p_action_status_code = 'PENDING' THEN
     l_wf_process        := 'PA_ADVERTISEMENT_NTF_PROCESS';
   ELSE
     l_wf_process        := 'PA_REMOVE_ADV_NTF_PROCESS';
   END IF;

   Start_Adv_Notification_WF (
       p_action_code                  =>  p_action_code
     , p_wf_user_name                 =>  l_wf_adhoc_user_name
     , p_assignment_id                =>  p_object_id
     , p_project_id                   =>  p_project_id
     , p_wf_process                   =>  l_wf_process
     , p_wf_item_type                 => 'PARADVWF'
     , x_return_status                =>  x_return_status);

   -- Insert the email address into audit table
   IF p_action_status_code = 'PENDING' AND p_insert_audit_flag = 'T' THEN

     -- insert the single audit line into the global audit record
     l_action_line_audit_rec.reason_code                 := 'CONDITION_MET';
     l_action_line_audit_rec.action_code                 := p_action_code;
     l_action_line_audit_rec.audit_display_attribute     := l_email_tab(j);--p_email_address added for 4701745;
     l_action_line_audit_rec.audit_attribute             := l_email_tab(j);--p_email_address added for 4701745;
     l_action_line_audit_rec.reversed_action_set_line_id := NULL;

     l_index := PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl.COUNT;
     PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl(l_index) := l_action_line_audit_rec;

   END IF;

  END IF; -- l_email_tab(j) NOT NULL - added for 4701745
 END LOOP; -- l_email_tab FOR loop end- added for 4701745
END IF;--end l_email_tab.count end - added for 4701745

/*end bug 4701745 */

 -- 4537865 : Included Exception Block
 EXCEPTION
        WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ADVERTISEMENTS_PVT'
                                , p_procedure_name => 'Send_Email'
                                , p_error_text  => SUBSTRB(SQLERRM,1,240));
        RAISE ;
 END Send_Email;



----------------------------------------------------------------------
-- Procedure
--   Perform Send Notification
--
-- Purpose
--   Send the advertisement notification to a specific person or role
--   on the project.
----------------------------------------------------------------------
PROCEDURE Send_Notification (
  p_action_set_line_id             IN  pa_action_set_lines.action_set_line_id%TYPE
, p_object_id                      IN  pa_action_sets.object_id%TYPE
, p_action_code                    IN  pa_action_set_lines.action_code%TYPE
, p_action_status_code             IN  pa_action_set_lines.status_code%TYPE
, p_method                         IN  VARCHAR2
, p_person_id                      IN  pa_resources_denorm.person_id%TYPE := FND_API.G_MISS_NUM
, p_project_role_id                IN  pa_project_role_types.project_role_id%TYPE := FND_API.G_MISS_NUM
, p_project_id                     IN  pa_project_assignments.project_id%TYPE
, p_insert_audit_flag              IN  VARCHAR2 := 'T'
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
--, x_msg_count                      OUT NUMBER
--, x_msg_data                       OUT VARCHAR2
) IS

  --cursor to get tpeople on the project role
  -- Commented for Performance Fix 4898314 SQL ID 14906391
  --CURSOR get_person_on_project_role IS
  --SELECT rv.resource_source_id, rv.resource_name
  --FROM   pa_project_parties pp,
  --       pa_c_resource_v rv
  --WHERE  pp.project_id = p_project_id
  --  AND  pp.project_role_id = p_project_role_id
  --  AND  pp.resource_source_id = rv.resource_source_id;

  -- Start of Performance Fix 4898314 SQL ID 14906391
  CURSOR get_person_on_project_role IS
  SELECT per.person_id resource_source_id, per.full_name resource_name
    FROM pa_project_parties pp,
	 per_people_f per
  WHERE  pp.project_id = p_project_id
    AND  pp.project_role_id = p_project_role_id
    AND  pp.resource_source_id = per.person_id
    AND  (per.employee_number IS NOT NULL OR per.npw_number IS NOT NULL)
    AND  (per.current_employee_flag = 'Y' OR per.current_npw_flag = 'Y')
    AND  trunc(sysdate) BETWEEN per.effective_start_date
			    AND per.effective_end_date
    AND  trunc(sysdate) BETWEEN pp.start_date_active and nvl(pp.end_date_active, sysdate); --bug#9500452
  -- End of Performance Fix 4898314 SQL ID 14906391

  --cursor to get person's name
  -- Commented for Performance Fix 4898314 SQL ID 14906422
  -- CURSOR get_person_name IS
  -- SELECT resource_source_id, resource_name
  -- FROM   pa_c_resource_v
  -- WHERE  resource_source_id = p_person_id;

  -- Start of Performance Fix 4898314 SQL ID 14906422
  CURSOR get_person_name IS
  SELECT per.person_id resource_source_id, per.full_name resource_name
    FROM per_people_f per
   WHERE per.person_id = p_person_id
     AND (per.employee_number IS NOT NULL OR per.npw_number IS NOT NULL)
     AND (per.current_employee_flag = 'Y' OR per.current_npw_flag = 'Y')
     AND  trunc(sysdate) BETWEEN per.effective_start_date
                             AND per.effective_end_date;
  -- End of Performance Fix 4898314 SQL ID 14906422

  l_ntf_recipient_person_id_tbl   system.pa_num_tbl_type;
  l_ntf_recipient_name_tbl        system.pa_varchar2_240_tbl_type;
  l_return_status                 VARCHAR2(1);
  l_wf_process                    VARCHAR2(30);
  l_encoded_message_text          VARCHAR2(2000);
  l_msg_index_out                 NUMBER;
  l_action_line_audit_rec         pa_action_set_utils.insert_audit_lines_rec_type;
  l_index                         NUMBER;
  l_action_status_code            VARCHAR2(30);

 BEGIN

   --dbms_output.put_line('PA_ADVERTISEMENTS_PVT.send notification');

   -- Initialize the Error Stack
   PA_DEBUG.init_err_stack('PA_ADVERTISEMENTS_PVT.Send_Notification');

   --Log Message
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ADVERTISEMENTS_PVT.Send_Notification'
                        ,x_msg         => 'Beginning of PA_ADVERTISEMENTS_PVT.Send_Notification'
                        ,x_log_level   => 5);
   END IF;

   -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- get the person_id of the notification recipients
   IF p_method = 'PROJECT_ROLE' THEN

     OPEN get_person_on_project_role;
      FETCH get_person_on_project_role
      BULK COLLECT INTO l_ntf_recipient_person_id_tbl, l_ntf_recipient_name_tbl;
     CLOSE get_person_on_project_role;

   ELSE

     OPEN get_person_name;
      FETCH get_person_name
      BULK COLLECT INTO l_ntf_recipient_person_id_tbl, l_ntf_recipient_name_tbl;
     CLOSE get_person_name;

   END IF;

   -- ERROR: Insert error into the stack when no one is found
   IF l_ntf_recipient_person_id_tbl.COUNT = 0 THEN

     IF p_action_code = 'ADVERTISEMENT_SEND_NTF_PERSON' THEN

       -- insert error into audit, 'User is not valid'
       PA_ACTION_SET_UTILS.Add_Message(
                       p_app_short_name => 'PA'
              ,p_msg_name   => 'PA_ADV_NTF_PERSON_ERR'
       );

     ELSIF p_action_code = 'ADVERTISEMENT_SEND_NTF_ROLE' THEN
       -- insert error into audit, Person does not exists for the project role
       PA_ACTION_SET_UTILS.Add_Message(
                       p_app_short_name => 'PA'
              ,p_msg_name   => 'PA_ADV_NTF_ROLE_ERR'
       );

     END IF;

  ELSE

   -- Start different wf process to send different notifications
   -- depending of the action line status
   IF p_action_status_code = 'PENDING' THEN
     l_wf_process        := 'PA_ADVERTISEMENT_NTF_PROCESS';
   ELSE
     l_wf_process        := 'PA_REMOVE_ADV_NTF_PROCESS';
   END IF;

   Start_Adv_Notification_WF (
       p_action_code                  =>  p_action_code
     , p_ntf_recipient_person_id_tbl  =>  l_ntf_recipient_person_id_tbl
     , p_ntf_recipient_name_tbl       =>  l_ntf_recipient_name_tbl
     , p_assignment_id                =>  p_object_id
     , p_project_id                   =>  p_project_id
     , p_wf_process                   =>  l_wf_process
     , p_wf_item_type                 => 'PARADVWF'
     , p_insert_audit_flag            => p_insert_audit_flag
     , x_return_status                =>  x_return_status);

  END IF; -- no person

  --
  -- Insert the error into the audit table
  -- and return error status if there is error message in the stack
  --
  IF FND_MSG_PUB.Count_Msg > 0 THEN
    IF p_insert_audit_flag = 'T' THEN

     FOR i in 1..FND_MSG_PUB.Count_Msg LOOP
       FND_MSG_PUB.get (
                   p_encoded        => FND_API.G_TRUE
                  ,p_msg_index      => i
                  ,p_data           => l_encoded_message_text
                  ,p_msg_index_out  => l_msg_index_out);

       l_action_line_audit_rec.action_code                   := p_action_code;
       l_action_line_audit_rec.encoded_error_message         := l_encoded_message_text;
       IF l_action_status_code = 'REVERSE_PENDING' THEN
         l_action_line_audit_rec.reason_code                 := 'DELETED';
         l_action_line_audit_rec.reversed_action_set_line_id := p_action_set_line_id;
       ELSIF l_action_status_code = 'UPDATE_PENDING' THEN
          l_action_line_audit_rec.reversed_action_set_line_id := p_action_set_line_id;
          l_action_line_audit_rec.reason_code                 := 'UPDATED';
       ELSE
         l_action_line_audit_rec.reason_code                 := 'CONDITION_MET';
       END IF;
       l_index := PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl.COUNT;
       PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl(l_index) := l_action_line_audit_rec;
     END LOOP;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
 -- 4537865 : Included Exception Block
 EXCEPTION
        WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ADVERTISEMENTS_PVT'
                                , p_procedure_name => 'Send_Notification'
                                , p_error_text  => SUBSTRB(SQLERRM,1,240));
        RAISE ;
 END Send_Notification;


----------------------------------------------------------------------
-- Procedure
--   Start Advertisement Notification Workflow
--
-- Purpose
--   Start Workflow process to send advertisement notification
----------------------------------------------------------------------
PROCEDURE Start_Adv_Notification_WF (
  p_action_code                  IN  pa_action_set_lines.action_code%TYPE
, p_ntf_recipient_person_id_tbl  IN  system.pa_num_tbl_type := NULL
, p_ntf_recipient_name_tbl       IN  system.pa_varchar2_240_tbl_type := NULL
, p_wf_user_name                 IN  VARCHAR2 := NULL
, p_wf_process                   IN  VARCHAR2
, p_wf_item_type                 IN  VARCHAR2 := 'PARADVWF'
, p_assignment_id                IN  pa_project_assignments.assignment_id%TYPE
, p_project_id                   IN  pa_projects_all.project_id%TYPE
, p_insert_audit_flag            IN  VARCHAR2 := 'T'
, x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

  l_ntf_recipient_person_id_tbl  system.pa_num_tbl_type;
  l_wf_item_key               NUMBER;
  l_set_text_attr_name_tbl    Wf_Engine.NameTabTyp;
  l_set_text_attr_value_tbl   Wf_Engine.TextTabTyp;
  l_set_num_attr_name_tbl     Wf_Engine.NameTabTyp;
  l_set_num_attr_value_tbl    Wf_Engine.NumTabTyp;
  l_set_date_attr_name_tbl    Wf_Engine.NameTabTyp;
  l_set_date_attr_value_tbl   Wf_Engine.DateTabTyp;
  l_err_code                  fnd_new_messages.message_name%TYPE;
  l_err_stage                 VARCHAR2(2000);
  l_err_stack                 VARCHAR2(2000);

  i                           NUMBER;
  l_ntf_recipient_user_name   fnd_user.user_name%TYPE;
  l_display_name              VARCHAR2(240);
  l_save_threshold            NUMBER;
  l_wf_item_type              VARCHAR2(8);

  l_assignment_name           pa_project_assignments.assignment_name%TYPE;
  l_start_date                pa_project_assignments.start_date%TYPE;
  l_end_date                  pa_project_assignments.end_date%TYPE;
  l_project_organization_name hr_organization_units.name%TYPE;
  l_project_role_name         pa_project_role_types.meaning%TYPE;
  l_min_resource_job_level    pa_project_assignments.min_resource_job_level%TYPE;
  l_max_resource_job_level    pa_project_assignments.max_resource_job_level%TYPE;
  l_staffing_priority_name    VARCHAR2(80);
  l_description               pa_project_assignments.description%TYPE;
  l_additional_information    pa_project_assignments.additional_information%TYPE;
  l_project_name              pa_projects_all.name%TYPE;
  l_project_number            pa_projects_all.segment1%TYPE;
  l_project_organization      HR_ALL_ORGANIZATION_UNITS.name%TYPE;
  -- 4363092 TCA changes, replaced RA views with HZ tables
  --l_project_customer          RA_CUSTOMERS.customer_name%TYPE;
  l_project_customer          hz_parties.party_name%TYPE;
  -- 4363092 done
  l_project_manager           per_all_people_f.full_name%TYPE;
  l_project_manager_id        pa_project_parties.resource_source_id%TYPE;
  l_effort                    pa_project_assignments.assignment_effort%TYPE;
  l_duration                  NUMBER;
  l_action_line_audit_rec     pa_action_set_utils.insert_audit_lines_rec_type;
  l_index                     NUMBER;
  l_requirement_overview_link VARCHAR2(2000);

  l_revenue_bill_rate         NUMBER;
  l_revenue_currency_code     VARCHAR2(15);
  l_bill_rate_override        NUMBER;
  l_bill_rate_curr_override   VARCHAR2(30);
  l_markup_percent_override   NUMBER;
  l_fcst_tp_amount_type_name  VARCHAR2(80);
  l_tp_rate_override          NUMBER;
  l_tp_currency_override      VARCHAR2(30);
  l_tp_calc_base_code_override VARCHAR2(30);
  l_tp_percent_applied_override NUMBER;
  l_work_type_name            VARCHAR2(80);
  /* Bug 3051110-Added the following variables */
  l_transfer_price_rate       pa_project_assignments.transfer_price_rate%type;
  l_transfer_pr_rate_curr     pa_project_assignments.transfer_pr_rate_curr%type;
  l_override_basis_name VARCHAR2(80) := NULL;

  --cursor to get attributes of the requirement to be
  --displayed in notifications
  -- Bug 2388060 - Apply Action Set after schedule has been created
  --  Get the Assignment Effort if it is null
  CURSOR get_requirement_info IS
  SELECT asgn.assignment_name,
         asgn.start_date,
         asgn.end_date,
--         pa_expenditures_utils.GetOrgTlName(proj.carrying_out_organization_id),    -- Commented for Bug 4866284
         pa_resource_utils.get_organization_name(proj.carrying_out_organization_id), -- Added for Bug 4866284
         prt.meaning,
         asgn.min_resource_job_level,
         asgn.max_resource_job_level,
         sp.meaning staffing_priority_name,
         nvl(asgn.assignment_effort, PA_SCHEDULE_UTILS.get_num_hours(asgn.project_id, asgn.assignment_id)),
         (trunc(asgn.end_date) - trunc(asgn.start_date) +1 ),
         asgn.description,
         asgn.additional_information,
         asgn.revenue_bill_rate,
         asgn.revenue_currency_code,
         asgn.bill_rate_override,
         asgn.bill_rate_curr_override,
         asgn.markup_percent_override,
         fcst.meaning,
         asgn.tp_rate_override,
         asgn.tp_currency_override,
         asgn.tp_calc_base_code_override,
         asgn.tp_percent_applied_override,
         wt.name,
     asgn.transfer_price_rate,   -- Added for bug 3051110
     asgn.transfer_pr_rate_curr
  FROM   pa_project_assignments asgn,
         pa_projects_all proj,
         pa_project_role_types prt,
         pa_lookups sp,
         pa_lookups fcst,
         pa_work_types_v wt
  WHERE  assignment_id = p_assignment_id
    AND  asgn.project_role_id = prt.project_role_id
    AND  asgn.project_id = proj.project_id
    AND  sp.lookup_type(+) = 'STAFFING_PRIORITY_CODE'
    AND  asgn.staffing_priority_code = sp.lookup_code(+)
    AND  fcst.lookup_type(+) = 'TP_AMOUNT_TYPE'
    AND  asgn.fcst_tp_amount_type = fcst.lookup_code(+)
    AND  asgn.work_type_id = wt.work_type_id;

  CURSOR csr_get_override_basis_name (p_override_basis_code IN VARCHAR2) IS
  SELECT plks.meaning
  FROM   pa_lookups plks
  WHERE  plks.lookup_type = 'CC_MARKUP_BASE_CODE'
  AND    plks.lookup_code = p_override_basis_code;

  --cursor to get attributes of the project to be
  --displayed in notifications
  CURSOR get_project_info IS
  SELECT proj.name,
         proj.segment1,
         hou.name,
         PA_PROJECT_PARTIES_UTILS.GET_PROJECT_MANAGER(proj.project_id),
         PA_PROJECT_PARTIES_UTILS.GET_PROJECT_MANAGER_NAME,
         PA_PROJECTS_MAINT_UTILS.GET_PRIMARY_CUSTOMER_NAME(proj.project_id)
  FROM pa_projects_all proj,
       HR_ALL_ORGANIZATION_UNITS HOU
  WHERE  proj.project_id = p_project_id
    AND  proj.CARRYING_OUT_ORGANIZATION_ID = HOU.ORGANIZATION_ID;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ADVERTISEMENTS_PVT.Start_Adv_Notification_WF');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ADVERTISEMENTS_PVT.Start_Adv_Notification_WF'
                       ,x_msg         => 'Beginning of PA_ADVERTISEMENTS_PVT.Start_Adv_Notification_WF'
                       ,x_log_level   => 5);
  END IF;

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Setting thresold value to run the process in background
  l_save_threshold    := wf_engine.threshold;
  wf_engine.threshold := -1;

  -- get the requirement and project information to be displayed
  -- in the notifications
     OPEN get_requirement_info;
     FETCH get_requirement_info INTO
         l_assignment_name,
         l_start_date,
         l_end_date,
         l_project_organization_name,
         l_project_role_name,
         l_min_resource_job_level,
         l_max_resource_job_level,
         l_staffing_priority_name,
         l_effort,
         l_duration,
         l_description,
         l_additional_information,
         l_revenue_bill_rate,
         l_revenue_currency_code,
         l_bill_rate_override,
         l_bill_rate_curr_override,
         l_markup_percent_override,
         l_fcst_tp_amount_type_name,
         l_tp_rate_override,
         l_tp_currency_override,
         l_tp_calc_base_code_override,
         l_tp_percent_applied_override,
         l_work_type_name,
     l_transfer_price_rate,   -- Added for bug 3051110
     l_transfer_pr_rate_curr;
     CLOSE get_requirement_info;

     OPEN get_project_info;
     FETCH get_project_info INTO
         l_project_name,
         l_project_number,
         l_project_organization,
         l_project_manager_id,
         l_project_manager,
         l_project_customer;
     CLOSE get_project_info;

     IF l_tp_calc_base_code_override IS NOT NULL THEN
        open csr_get_override_basis_name(l_tp_calc_base_code_override);
        fetch csr_get_override_basis_name into l_override_basis_name;
        close csr_get_override_basis_name;
     END IF;

   -- if wf user name is passed in, set person_id to -999
   IF p_wf_user_name IS NOT NULL THEN

     SELECT -999
     BULK COLLECT INTO l_ntf_recipient_person_id_tbl
     FROM pa_project_assignments
     WHERE assignment_id = p_assignment_id;

   ELSE
     l_ntf_recipient_person_id_tbl := p_ntf_recipient_person_id_tbl;
   END IF;

   -- start one wf process to send notification per recipient
   FOR i in l_ntf_recipient_person_id_tbl.FIRST ..l_ntf_recipient_person_id_tbl.LAST LOOP

     IF l_ntf_recipient_person_id_tbl(i)=-999 THEN
       l_ntf_recipient_user_name := p_wf_user_name;
     ELSE

       --Getting recepients fnd user name
       wf_directory.getusername
       (p_orig_system    => 'PER'
       ,p_orig_system_id => l_ntf_recipient_person_id_tbl(i)
       ,p_name           => l_ntf_recipient_user_name
       ,p_display_name   => l_display_name);

     END IF;

     IF l_ntf_recipient_user_name IS NULL THEN

       --dbms_output.put_line('no username for person id '|| l_ntf_recipient_person_id_tbl(i));
       -- insert error into audit, User is not valid
       PA_ACTION_SET_UTILS.Add_Message(
                       p_app_short_name => 'PA'
              ,p_msg_name   => 'PA_ADV_NTF_ERR'
                      ,p_token1         => 'PERSON_NAME'
                      ,p_value1         => p_ntf_recipient_name_tbl(i)
       );

       x_return_status := FND_API.G_RET_STS_ERROR;

     ELSE

       --dbms_output.put_line('sending notification to '|| l_ntf_recipient_user_name);

       -- Create the unique item key to launch WF with
       SELECT pa_advertisement_ntf_wf_s.nextval
       INTO   l_wf_item_key
       FROM   dual;

       -- Create the WF process
       wf_engine.CreateProcess
          ( ItemType => p_wf_item_type
          , ItemKey  => l_wf_item_key
          , process  => p_wf_process );

       --Store the item attributes in plsql tables
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'NTF_RECIPIENT';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_ntf_recipient_user_name;

       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'ASSIGNMENT_NAME';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_assignment_name;
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'ROLE_NAME';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_project_role_name;
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'ORGANIZATION_NAME';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_project_organization_name;
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'STAFFING_PRIORITY';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_staffing_priority_name;
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'DESCRIPTION';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_description;
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'ADDITIONAL_INFORMATION';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_additional_information;
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'PROJECT_NAME';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_project_name;
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'PROJECT_NUMBER';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_project_number;
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'PROJECT_ORGANIZATION_NAME';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_project_organization_name;
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'PROJECT_MANAGER';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_project_manager;
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'PROJECT_CUSTOMER';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_project_customer;
/* Bug 2529772 - added paPersonId in the link below */
       l_requirement_overview_link :=
       'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275'||'&'||'akRegionCode=PA_OPEN_ASMT_DETAILS_LAYOUT'||'&'||'paAssignmentId='||p_assignment_id||'&'||'paPersonId='||l_ntf_recipient_person_id_tbl(i)||'&'||'addBreadCrumb=RP';

       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'REQUIREMENT_LINK';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_requirement_overview_link;

       l_set_num_attr_name_tbl(l_set_num_attr_name_tbl.COUNT+1) := 'MIN_JOB_LEVEL';
       l_set_num_attr_value_tbl(l_set_num_attr_value_tbl.COUNT+1) := l_min_resource_job_level;
       l_set_num_attr_name_tbl(l_set_num_attr_name_tbl.COUNT+1) := 'MAX_JOB_LEVEL';
       l_set_num_attr_value_tbl(l_set_num_attr_value_tbl.COUNT+1) := l_max_resource_job_level;
       l_set_num_attr_name_tbl(l_set_num_attr_name_tbl.COUNT+1) := 'EFFORT';
       l_set_num_attr_value_tbl(l_set_num_attr_value_tbl.COUNT+1) := l_effort;
       l_set_num_attr_name_tbl(l_set_num_attr_name_tbl.COUNT+1) := 'DURATION';
       l_set_num_attr_value_tbl(l_set_num_attr_value_tbl.COUNT+1) := l_duration;

       l_set_date_attr_name_tbl(l_set_date_attr_name_tbl.COUNT+1) := 'START_DATE';
       l_set_date_attr_value_tbl(l_set_date_attr_value_tbl.COUNT+1) := l_start_date;
       l_set_date_attr_name_tbl(l_set_date_attr_name_tbl.COUNT+1) := 'END_DATE';
       l_set_date_attr_value_tbl(l_set_date_attr_value_tbl.COUNT+1) := l_end_date;

       l_set_num_attr_name_tbl(l_set_num_attr_name_tbl.COUNT+1) := 'REVENUE_BILL_RATE';
       l_set_num_attr_value_tbl(l_set_num_attr_value_tbl.COUNT+1) := l_revenue_bill_rate;
       l_set_num_attr_name_tbl(l_set_num_attr_name_tbl.COUNT+1) := 'BILL_RATE_OVERRIDE';
       l_set_num_attr_value_tbl(l_set_num_attr_value_tbl.COUNT+1) := l_bill_rate_override;
       l_set_num_attr_name_tbl(l_set_num_attr_name_tbl.COUNT+1) := 'TP_RATE_OVERRIDE';
       l_set_num_attr_value_tbl(l_set_num_attr_value_tbl.COUNT+1) := l_tp_rate_override;
       l_set_num_attr_name_tbl(l_set_num_attr_name_tbl.COUNT+1) := 'ASSIGNMENT_ID';    -- added for Bug 4777149
       l_set_num_attr_value_tbl(l_set_num_attr_value_tbl.COUNT+1) := p_assignment_id;  -- added for Bug 4777149


       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'REVENUE_BILL_RATE_CURR';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_revenue_currency_code;
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'BILL_RATE_OVERRIDE_CURR';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_bill_rate_curr_override;
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'TP_AMT_TYPE_NAME';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_fcst_tp_amount_type_name;
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'TP_RATE_OVERRIDE_CURR';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_tp_currency_override;
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'WORK_TYPE_NAME';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_work_type_name;
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'OVERRIDE_BASIS_NAME';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_override_basis_name;

/* Added the below code for bug 3051110 */

       l_set_num_attr_name_tbl (l_set_num_attr_name_tbl.COUNT+1) := 'TRANSFER_PRICE_RATE';
       l_set_num_attr_value_tbl(l_set_num_attr_value_tbl.COUNT+1) := l_transfer_price_rate;
       l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'TRANSFER_PR_RATE_CURR';
       l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := l_transfer_pr_rate_curr;

       IF l_markup_percent_override IS NOT NULL THEN
          l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'MARKUP_PCT_OVERRIDE';
          l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := to_char(l_markup_percent_override)||'%';
       ELSE
          l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'MARKUP_PCT_OVERRIDE';
          l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) := to_char(l_markup_percent_override);
       END IF;

       IF l_tp_percent_applied_override IS NOT NULL THEN
          IF l_override_basis_name IS NOT NULL THEN
             l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'TP_PCT_APPLIED_OVERRIDE';
             l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) :=
                ', '||to_char(l_tp_percent_applied_override)||'%';
          ELSE
             l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'TP_PCT_APPLIED_OVERRIDE';
             l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) :=
                   to_char(l_tp_percent_applied_override)||'%';
          END IF;
       ELSE
             l_set_text_attr_name_tbl(l_set_text_attr_name_tbl.COUNT+1) := 'TP_PCT_APPLIED_OVERRIDE';
             l_set_text_attr_value_tbl(l_set_text_attr_value_tbl.COUNT+1) :=
                   to_char(l_tp_percent_applied_override);
       END IF;

       --SET the item attributes (these attributes were created at design time)
       WF_ENGINE.SetItemAttrTextArray(itemtype  => p_wf_item_type,
                                   itemkey  => l_wf_item_key,
                                   aname    => l_set_text_attr_name_tbl,
                                   avalue   => l_set_text_attr_value_tbl);

       WF_ENGINE.SetItemAttrNumberArray(itemtype => p_wf_item_type,
                                    itemkey  => l_wf_item_key,
                                    aname    => l_set_num_attr_name_tbl,
                                    avalue   => l_set_num_attr_value_tbl);

       WF_ENGINE.SetItemAttrDateArray(itemtype  => p_wf_item_type,
                                   itemkey  => l_wf_item_key,
                                   aname    => l_set_date_attr_name_tbl,
                                   avalue   => l_set_date_attr_value_tbl);

       --Start the workflow process
       wf_engine.StartProcess ( itemtype => p_wf_item_type
                               ,itemkey  => l_wf_item_key );

       -- Insert into Notifications table
       PA_WORKFLOW_UTILS.Insert_WF_Processes
            (p_wf_type_code        => 'ADVERTISEMENTS_NTF_WF'
        ,p_item_type           => p_wf_item_type
        ,p_item_key            => l_wf_item_key
        ,p_entity_key1         => to_char(p_project_id)
            ,p_entity_key2         => to_char(l_ntf_recipient_person_id_tbl(i))
        ,p_description         => NULL
        ,p_err_code            => l_err_code
        ,p_err_stage           => l_err_stage
        ,p_err_stack           => l_err_stack );

       -- Insert people into audit table if the action is Send Notification
       IF p_insert_audit_flag = 'T' AND
          (p_action_code = 'ADVERTISEMENT_SEND_NTF_PERSON' OR
           p_action_code = 'ADVERTISEMENT_SEND_NTF_ROLE') THEN

         l_action_line_audit_rec.reason_code                 := 'CONDITION_MET';
         l_action_line_audit_rec.action_code                 := p_action_code;
         l_action_line_audit_rec.audit_display_attribute     := p_ntf_recipient_name_tbl(i);
         l_action_line_audit_rec.audit_attribute             := l_ntf_recipient_person_id_tbl(i);
         l_action_line_audit_rec.reversed_action_set_line_id := NULL;

         l_index := PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl.COUNT;
         PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl(l_index) := l_action_line_audit_rec;

       END IF;

      END IF; --if username is null

    END LOOP;--end i loop

   --Setting the original value
   wf_engine.threshold := l_save_threshold;
 -- 4537865 : Included Exception Block
 EXCEPTION
        WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ADVERTISEMENTS_PVT'
                                , p_procedure_name => 'Start_Adv_Notification_WF'
                                , p_error_text  => SUBSTRB(SQLERRM,1,240));
        RAISE ;
END Start_Adv_Notification_WF;

----------------------------------------------------------------------
-- Procedure
--   Perform Update Staffing Priority
--
-- Purpose
--   Update the staffing priority of the requirement.
----------------------------------------------------------------------
PROCEDURE Update_Staffing_Priority (
  p_action_set_line_id             IN  pa_action_set_lines.action_set_line_id%TYPE
, p_object_id                      IN  pa_action_sets.object_id%TYPE
, p_action_code                    IN  pa_action_set_lines.action_code%TYPE
, p_action_status_code             IN  pa_action_set_lines.status_code%TYPE
, p_staffing_priority_code         IN  pa_project_assignments.staffing_priority_code%TYPE
, p_record_version_number          IN  pa_project_assignments.record_version_number%TYPE
, p_insert_audit_flag              IN  VARCHAR2 := 'T'
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

  l_staffing_priority_name  pa_lookups.meaning%TYPE;
  l_action_line_audit_rec     pa_action_set_utils.insert_audit_lines_rec_type;
  l_index                     NUMBER;
  l_encoded_message_text   VARCHAR2(2000);
  l_msg_index_out          NUMBER;
  l_update_sp_display_attribute VARCHAR2(80);
 BEGIN

   --dbms_output.put_line('update staffing priority');

   -- Initialize the Error Stack
   PA_DEBUG.init_err_stack('PA_ADVERTISEMENTS_PVT.Update_Staffing_Priority');

   --Log Message
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ADVERTISEMENTS_PVT.Update_Staffing_Priority'
                        ,x_msg         => 'Beginning of PA_ADVERTISEMENTS_PVT.Update_Staffing_Priority'
                        ,x_log_level   => 5);
   END IF;

   -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Handle PENDING action line only as REVERSE_PENDING and UPDATE_PENDING
   -- lines can be handled generically by the action set model.
   --
   IF p_action_status_code = 'PENDING' THEN

     SELECT meaning INTO l_staffing_priority_name
     FROM pa_lookups
     WHERE lookup_type = 'STAFFING_PRIORITY_CODE'
       AND lookup_code = p_staffing_priority_code;

     -- Update the staffing priority code
     PA_PROJECT_ASSIGNMENTS_PKG.Update_Row
       ( p_assignment_id          => p_object_id
        ,p_record_version_number  => p_record_version_number
        ,p_staffing_priority_code => p_staffing_priority_code
        ,x_return_status          => x_return_status );

     -- Insert into audit table
     IF x_return_status = FND_API.G_RET_STS_SUCCESS AND p_insert_audit_flag = 'T' THEN

       -- insert into into the global audit record
       l_action_line_audit_rec.reason_code                 := 'CONDITION_MET';
       l_action_line_audit_rec.action_code                 := p_action_code;
       l_action_line_audit_rec.audit_display_attribute     := l_staffing_priority_name;
       l_action_line_audit_rec.audit_attribute             := p_staffing_priority_code;
       l_action_line_audit_rec.reversed_action_set_line_id := NULL;
       l_index := PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl.COUNT;
       PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl(l_index) := l_action_line_audit_rec;

     ELSE

      -- ERROR: Insert error into the audit table
      IF FND_MSG_PUB.Count_Msg > 0 THEN
        IF p_insert_audit_flag = 'T' THEN

          FND_MSG_PUB.get (
                 p_encoded        => FND_API.G_TRUE
                ,p_msg_index      => FND_MSG_PUB.Count_Msg
                ,p_data           => l_encoded_message_text
                ,p_msg_index_out  => l_msg_index_out);

          l_action_line_audit_rec.reason_code           := 'CONDITION_MET';
          l_action_line_audit_rec.action_code           := p_action_code;
          l_action_line_audit_rec.encoded_error_message := l_encoded_message_text;
          l_index := PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl.COUNT;
          PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl(l_index) := l_action_line_audit_rec;
        END IF; -- IF p_insert_audit_flag = 'T'
      x_return_status := FND_API.G_RET_STS_ERROR;
      END IF; -- IF FND_MSG_PUB.Count_Msg > 0

     END IF;


  ELSE -- action status is REVERSE PENDING or UPDATE PENDING

    IF p_insert_audit_flag = 'T' THEN

      -- Get the Audit Display Attribute
      SELECT meaning INTO l_update_sp_display_attribute
      FROM pa_lookups
      WHERE lookup_type = 'ADVERTISEMENT'
        AND lookup_code = 'NO_ACTION_PERFORMED';

      -- insert into into the global audit record
      IF p_action_status_code = 'REVERSE_PENDING' THEN
        l_action_line_audit_rec.reason_code                 := 'DELETED';
      ELSE
        l_action_line_audit_rec.reason_code                 := 'UPDATED';
      END IF;
      l_action_line_audit_rec.action_code                 := p_action_code;
      l_action_line_audit_rec.audit_display_attribute     := l_update_sp_display_attribute;
      l_action_line_audit_rec.audit_attribute             := p_staffing_priority_code;
      l_action_line_audit_rec.reversed_action_set_line_id := p_action_set_line_id;
      l_index := PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl.COUNT;
      PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl(l_index) := l_action_line_audit_rec;

     END IF;

   END IF; -- action status
 -- 4537865 : Included Exception Block
 EXCEPTION
        WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ADVERTISEMENTS_PVT'
                                , p_procedure_name => 'Update_Staffing_Priority'
                                , p_error_text  => SUBSTRB(SQLERRM,1,240));
        RAISE ;
 END Update_Staffing_Priority;


----------------------------------------------------------------------
-- Procedure
--   Perform Remove Advertisement
--
-- Purpose
--   Remove the visibility or advertisement of the requirement.
----------------------------------------------------------------------
PROCEDURE Remove_Advertisement (
  p_action_set_line_id             IN  pa_action_set_lines.action_set_line_id%TYPE
, p_object_id                      IN  pa_action_sets.object_id%TYPE
, p_action_code                    IN  pa_action_set_lines.action_code%TYPE
, p_action_status_code             IN  pa_action_set_lines.status_code%TYPE
, p_project_id                     IN  pa_projects_all.project_id%TYPE
, p_insert_audit_flag              IN  VARCHAR2 := 'T'
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

  TYPE number_tbl                     IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;
  TYPE varchar_tbl                    IS TABLE OF VARCHAR2(150)
   INDEX BY BINARY_INTEGER;

  l_return_status           VARCHAR2(1);
  l_action_set_line_id_tbl  pa_action_set_utils.number_tbl_type;
  l_action_code_tbl         varchar_tbl;
  l_audit_attribute_tbl     varchar_tbl;
  l_display_audit_attribute_tbl   varchar_tbl;
  l_line_status_tbl         pa_action_set_utils.varchar_tbl_type;
  l_action_set_line_id_tbl2 pa_action_set_utils.number_tbl_type;
  l_line_status_tbl2        pa_action_set_utils.varchar_tbl_type;

  i                         NUMBER;
  l_action_status_code      VARCHAR2(30);
  l_action_set_id           NUMBER;
  l_object_id               NUMBER;
  l_object_type             VARCHAR2(30);
  l_action_set_type_code    VARCHAR2(30);
  l_project_id              NUMBER;
  l_record_version_number   NUMBER;
  l_action_line_audit_rec   pa_action_set_utils.insert_audit_lines_rec_type;
  l_index                   NUMBER;
  l_encoded_message_text   VARCHAR2(2000);
  l_msg_index_out          NUMBER;
  l_audit_reason_code      VARCHAR2(30);
  l_perform_return_status  VARCHAR2(1);
  l_audit_action_code      VARCHAR2(30);
  l_update_sp_display_attribute  VARCHAR2(80);
  l_remove_adv_display_attribute VARCHAR2(80);

  -- cursor to get all the currently active audit lines
  CURSOR get_all_active_audit_lines IS
  SELECT action_set_line_id, action_code, audit_attribute, audit_display_attribute, 'REVERSED'
  FROM pa_action_set_line_aud
  WHERE object_id = p_object_id
    AND object_type = 'OPEN_ASSIGNMENT'
    AND action_set_type_code = 'ADVERTISEMENT'
    AND active_flag = 'Y'
    AND reversed_action_set_line_id is null
    AND encoded_error_message is null;

  -- cursor to get all the currently active audit lines with/without error
  CURSOR get_active_audit_lines_error IS
  SELECT action_set_line_id, 'REVERSED'
  FROM pa_action_set_line_aud
  WHERE object_id = p_object_id
    AND object_type = 'OPEN_ASSIGNMENT'
    AND action_set_type_code = 'ADVERTISEMENT'
    AND active_flag = 'Y'
    AND reversed_action_set_line_id is null
  GROUP BY action_set_line_id;  -- CH2M Performance Bug fix: 2768530

  -- cursor to get all the action lines that were reversed due to the execution
  -- of this Remove Advertisement line and are not deleted
  CURSOR get_all_reversed_lines IS
  SELECT asl.action_set_line_id, asl.action_code, asa.audit_attribute, asa.audit_display_attribute, 'COMPLETE'
  FROM pa_action_set_line_aud asa,
       pa_action_set_lines asl,
       pa_action_set_line_cond aslc
  WHERE asa.object_id = p_object_id
    AND asa.object_type = 'OPEN_ASSIGNMENT'
    AND asa.action_set_type_code = 'ADVERTISEMENT'
    AND asa.action_set_line_id = p_action_set_line_id
    AND asa.reversed_action_set_line_id IS NOT NULL
    AND asl.action_set_line_id = asa.reversed_action_set_line_id
    AND nvl(asl.line_deleted_flag, 'N') = 'N'
    AND encoded_error_message is null
    AND aslc.action_set_line_id = asl.action_set_line_id
    AND aslc.condition_date <= sysdate
    AND asl.action_set_line_id <> p_action_set_line_id;

 BEGIN

   --dbms_output.put_line('begin of PA_ADVERTISEMENTS_PVT.Remove_Advertisement');

   -- Initialize the Error Stack
   PA_DEBUG.init_err_stack('PA_ADVERTISEMENTS_PVT.Update_Staffing_Priority');

   --Log Message
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ADVERTISEMENTS_PVT.Remove_Advertisement'
                        ,x_msg         => 'Beginning of PA_ADVERTISEMENTS_PVT.Remove_Advertisement'
                        ,x_log_level   => 5);
   END IF;

   -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- CASE 1: the action status code is PENDING
   IF p_action_status_code = 'PENDING' THEN

     -- insert the Remove Advertisement record into global audit rec
     IF p_insert_audit_flag = 'T' THEN

       -- insert into into the global audit record
       l_action_line_audit_rec.reason_code                 := 'CONDITION_MET';
       l_action_line_audit_rec.action_code                 := p_action_code;
       l_action_line_audit_rec.audit_display_attribute     := null;
       l_action_line_audit_rec.audit_attribute             := null;
       l_action_line_audit_rec.reversed_action_set_line_id := NULL;
       l_index := PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl.COUNT;
       PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl(l_index) := l_action_line_audit_rec;

     END IF;

     -- get all the currently active audit lines
     -- these lines need to be reversed
     OPEN get_all_active_audit_lines;
      FETCH get_all_active_audit_lines
      BULK COLLECT INTO l_action_set_line_id_tbl,
                        l_action_code_tbl,
                        l_audit_attribute_tbl,
                        l_display_audit_attribute_tbl,
                        l_line_status_tbl;
     CLOSE get_all_active_audit_lines;

     --dbms_output.put_line('l_action_set_line_id_tbl.COUNT:'||l_action_set_line_id_tbl.COUNT);

     -- get all the currently active audit lines with/without error
     -- not all these lines need to be reversed
     -- but the line statuses and active flags need to be changed
     -- get all the currently active audit lines
     -- these lines need to be reversed
     OPEN get_active_audit_lines_error;
      FETCH get_active_audit_lines_error
      BULK COLLECT INTO l_action_set_line_id_tbl2,
                   --     l_action_code_tbl2,
                   --     l_audit_attribute_tbl2,
                   --     l_display_audit_attribute_tbl2,
                        l_line_status_tbl2;
     CLOSE get_active_audit_lines_error;

     IF l_action_set_line_id_tbl2.COUNT > 0 THEN

       -- Update the action line status to REVERSED
       PA_ACTION_SETS_PVT.Bulk_Update_Line_Status(
           p_action_set_line_id_tbl => l_action_set_line_id_tbl2
          ,p_line_status_tbl        => l_line_status_tbl2
          ,x_return_status          => l_return_status
       );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       -- Update the active flag to 'N' in the audit records
       FORALL i IN l_action_set_line_id_tbl2.FIRST ..l_action_set_line_id_tbl2.LAST
         UPDATE pa_action_set_line_aud
            SET active_flag = 'N'
          WHERE action_set_line_id = l_action_set_line_id_tbl2(i);

       -- set the action status code to REVERSE_PENDING
       -- to reverse the child records
       l_action_status_code := 'REVERSE_PENDING';
       l_audit_reason_code := 'ADVERTISEMENT_REMOVED';
     END IF; -- if l_action_set_line_id_tbl2.COUNT > 0

   --
   -- CASE 2: the action status code is REVERSE or UPDATE PENDING
   --
   ELSE

     -- get all the action lines that were reversed due to the execution
     -- of this Remove Advertisement line and are not deleted
     OPEN get_all_reversed_lines;
      FETCH get_all_reversed_lines
      BULK COLLECT INTO l_action_set_line_id_tbl,
                        l_action_code_tbl,
                        l_audit_attribute_tbl,
                        l_display_audit_attribute_tbl,
                        l_line_status_tbl;
     CLOSE get_all_reversed_lines;

     --dbms_output.put_line('l_action_set_line_id_tbl.COUNT:'||l_action_set_line_id_tbl.COUNT);

     IF l_action_set_line_id_tbl.COUNT = 0 THEN

        -- Get the Audit Display Attribute
        SELECT meaning INTO l_remove_adv_display_attribute
        FROM pa_lookups
        WHERE lookup_type = 'ADVERTISEMENT'
          AND lookup_code = 'NO_ACTION_PERFORMED';

     ELSE
        l_remove_adv_display_attribute := NULL;
     END IF;

     -- insert the Remove Advertisement record into global audit rec
     IF p_insert_audit_flag = 'T' THEN

       -- insert into into the global audit record
       IF p_action_status_code = 'REVERSE_PENDING' THEN
         l_action_line_audit_rec.reason_code                 := 'DELETED';
       ELSE
         l_action_line_audit_rec.reason_code                 := 'UPDATED';
       END IF;
       l_action_line_audit_rec.action_code                 := p_action_code;
       l_action_line_audit_rec.audit_display_attribute     := l_remove_adv_display_attribute;
       l_action_line_audit_rec.audit_attribute             := null;
       l_action_line_audit_rec.reversed_action_set_line_id := p_action_set_line_id;
       l_index := PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl.COUNT;
       PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl(l_index) := l_action_line_audit_rec;

     END IF;

     IF l_action_set_line_id_tbl.COUNT > 0 THEN

       -- update the action line status to COMPLETE
       PA_ACTION_SETS_PVT.Bulk_Update_Line_Status(
           p_action_set_line_id_tbl => l_action_set_line_id_tbl
          ,p_line_status_tbl        => l_line_status_tbl
          ,x_return_status          => l_return_status
       );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       -- set the action status code to PENDING
       -- to re-execute the child records
       l_action_status_code := 'PENDING';
       l_audit_reason_code := 'ADVERTISEMENT_REINSTATED';

     END IF; -- IF l_action_set_line_id_tbl.COUNT > 0 T

   END IF;  -- action line status status

   --
   -- Re-execute or reverse the child actions
   --
   IF l_action_set_line_id_tbl.COUNT > 0 THEN

     -- get object information
     SELECT project_id, record_version_number
     INTO l_project_id, l_record_version_number
     FROM pa_project_assignments
     WHERE assignment_id = p_object_id;

     -- handle send notifications, send email and update staffing priority
     FOR i IN l_action_set_line_id_tbl.FIRST .. l_action_set_line_id_tbl.LAST LOOP

       l_perform_return_status := FND_API.G_RET_STS_SUCCESS;
       l_audit_action_code := NULL;
       --dbms_output.put_line('l_action_set_line_id: '||l_action_set_line_id_tbl(i));

       IF l_action_code_tbl(i) = 'ADVERTISEMENT_SEND_EMAIL' OR
          l_action_code_tbl(i) =  'REVERSE_SEND_EMAIL' THEN

          Send_Email(
              p_action_set_line_id   => p_action_set_line_id
            , p_object_id            => p_object_id
            , p_action_code          => 'ADVERTISEMENT_SEND_EMAIL'
            , p_action_status_code   => l_action_status_code
            , p_project_id           => l_project_id
            , p_email_address        => l_audit_attribute_tbl(i)
            , p_insert_audit_flag    => 'F'
            , x_return_status        => l_return_status

          );
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_perform_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          -- Store difference action code in the audit table in cases
          -- of Cancel Advertisement and Reverse Cancel Advertisement
          IF p_action_status_code = 'PENDING' THEN
            l_audit_action_code := 'REVERSE_SEND_EMAIL';
          ELSE
            l_audit_action_code := 'ADVERTISEMENT_SEND_EMAIL';
          END IF;

       ELSIF l_action_code_tbl(i) = 'ADVERTISEMENT_SEND_NTF_PERSON' OR
             l_action_code_tbl(i) = 'REVERSE_SEND_NTF_PERSON' THEN

          Send_Notification(
              p_action_set_line_id   => p_action_set_line_id
            , p_object_id            => p_object_id
            , p_action_code          => 'ADVERTISEMENT_SEND_NTF_PERSON'
            , p_action_status_code   => l_action_status_code
            , p_method               => 'PERSON'
            , p_person_id            => to_number(l_audit_attribute_tbl(i))
            , p_project_id           => l_project_id
            , p_project_role_id      => null
            , p_insert_audit_flag    => 'F'
            , x_return_status        => l_return_status -- Changed from x_return_status to l_return_status : 4537865

          );
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_perform_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          -- Store difference action code in the audit table in cases
          -- of Cancel Advertisement and Reverse Cancel Advertisement
          IF p_action_status_code = 'PENDING' THEN
            l_audit_action_code := 'REVERSE_SEND_NTF_PERSON';
          ELSE
            l_audit_action_code := 'ADVERTISEMENT_SEND_NTF_PERSON';
          END IF;

       ELSIF l_action_code_tbl(i) = 'ADVERTISEMENT_SEND_NTF_ROLE' OR
             l_action_code_tbl(i) = 'REVERSE_SEND_NTF_ROLE' THEN

          Send_Notification(
              p_action_set_line_id   => p_action_set_line_id
            , p_object_id            => p_object_id
            , p_action_code          => 'ADVERTISEMENT_SEND_NTF_ROLE'
            , p_action_status_code   => l_action_status_code
            , p_method               => 'PERSON'
            , p_person_id            => to_number(l_audit_attribute_tbl(i))
            , p_project_id           => l_project_id
            , p_project_role_id      => null
            , p_insert_audit_flag    => 'F'
            , x_return_status        => l_return_status  -- Changed from x_return_status to l_return_status : 4537865

          );
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_perform_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          -- Store difference action code in the audit table in cases
          -- of Cancel Advertisement and Reverse Cancel Advertisement
          IF p_action_status_code = 'PENDING' THEN
            l_audit_action_code := 'REVERSE_SEND_NTF_ROLE';
          ELSE
            l_audit_action_code := 'ADVERTISEMENT_SEND_NTF_ROLE';
          END IF;


       ELSIF l_action_code_tbl(i) = 'ADVERTISEMENT_UPDATE_SP' OR
             l_action_code_tbl(i) = 'REVERSE_UPDATE_SP' THEN

          Update_Staffing_Priority(
              p_action_set_line_id     => p_action_set_line_id
            , p_object_id              => p_object_id
            , p_action_code            => 'ADVERTISEMENT_UPDATE_SP'
            , p_action_status_code     => l_action_status_code
            , p_staffing_priority_code => l_audit_attribute_tbl(i)
            , p_record_version_number  => l_record_version_number
            , p_insert_audit_flag      => 'F'
            , x_return_status          => l_return_status -- Changed from x_return_status to l_return_status : 4537865
          );
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_perform_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          -- Store difference action code in the audit table in cases
          -- of Cancel Advertisement and Reverse Cancel Advertisement
          IF p_action_status_code = 'PENDING' THEN
            l_audit_action_code := 'REVERSE_UPDATE_SP';

            -- Get the Audit Display Attribute
            SELECT meaning INTO l_update_sp_display_attribute
            FROM pa_lookups
            WHERE lookup_type = 'ADVERTISEMENT'
              AND lookup_code = 'NO_ACTION_PERFORMED';

          ELSE
            l_audit_action_code := 'ADVERTISEMENT_UPDATE_SP';
          END IF;

       ELSIF l_action_code_tbl(i) = 'ADVERTISEMENT_PUB_TO_ALL' OR
             l_action_code_tbl(i) = 'REVERSE_PUB_TO_ALL' THEN

          -- Store difference action code in the audit table in cases
          -- of Cancel Advertisement and Reverse Cancel Advertisement
          IF p_action_status_code = 'PENDING' THEN
            l_audit_action_code := 'REVERSE_PUB_TO_ALL';
          ELSE
            l_audit_action_code := 'ADVERTISEMENT_PUB_TO_ALL';
          END IF;

       ELSIF l_action_code_tbl(i) = 'ADVERTISEMENT_PUB_TO_START_ORG' OR
             l_action_code_tbl(i) = 'REVERSE_PUB_TO_START_ORG' THEN

          -- Store difference action code in the audit table in cases
          -- of Cancel Advertisement and Reverse Cancel Advertisement
          IF p_action_status_code = 'PENDING' THEN
            l_audit_action_code := 'REVERSE_PUB_TO_START_ORG';
          ELSE
            l_audit_action_code := 'ADVERTISEMENT_PUB_TO_START_ORG';
          END IF;

       ELSIF l_action_code_tbl(i) = 'ADVERTISEMENT_PUB_TO_SM' OR
             l_action_code_tbl(i) = 'REVERSE_PUB_TO_SM' THEN

          -- Store difference action code in the audit table in cases
          -- of Cancel Advertisement and Reverse Cancel Advertisement
          IF p_action_status_code = 'PENDING' THEN
            l_audit_action_code := 'REVERSE_PUB_TO_SM';
          ELSE
            l_audit_action_code := 'ADVERTISEMENT_PUB_TO_SM';
          END IF;

       ELSIF l_action_code_tbl(i) = 'ADVERTISEMENT_ESC_TO_NEXT_LVL' OR
             l_action_code_tbl(i) = 'REVERSE_ESC_TO_NEXT_LVL' THEN

          -- Store difference action code in the audit table in cases
          -- of Cancel Advertisement and Reverse Cancel Advertisement
          IF p_action_status_code = 'PENDING' THEN
            l_audit_action_code := 'REVERSE_ESC_TO_NEXT_LVL';
          ELSE
            l_audit_action_code := 'ADVERTISEMENT_ESC_TO_NEXT_LVL';
          END IF;

       ELSIF l_action_code_tbl(i) = 'ADVERTISEMENT_REMOVE_ADV' OR
             l_action_code_tbl(i) = 'REVERSE_REMOVE_ADV' THEN

          -- Store difference action code in the audit table in cases
          -- of Cancel Advertisement and Reverse Cancel Advertisement
          IF p_action_status_code = 'PENDING' THEN
            l_audit_action_code := 'REVERSE_REMOVE_ADV';
          ELSE
            l_audit_action_code := 'ADVERTISEMENT_REMOVE_ADV';
          END IF;

       END IF;  -- if action_code = ..

       -- Insert into into the global audit record
       IF p_insert_audit_flag = 'T' AND l_perform_return_status=FND_API.G_RET_STS_SUCCESS THEN

         l_action_line_audit_rec.reason_code                 := l_audit_reason_code;
         l_action_line_audit_rec.action_code                 := l_audit_action_code;
         l_action_line_audit_rec.audit_attribute             := l_audit_attribute_tbl(i);
         l_action_line_audit_rec.audit_display_attribute     := l_display_audit_attribute_tbl(i);

         IF l_action_status_code = 'REVERSE_PENDING' THEN
           l_action_line_audit_rec.reversed_action_set_line_id := l_action_set_line_id_tbl(i);
           IF l_audit_action_code =  'ADVERTISEMENT_UPDATE_SP' OR
              l_audit_action_code  = 'REVERSE_UPDATE_SP' THEN
             l_action_line_audit_rec.audit_display_attribute   := l_update_sp_display_attribute;
           END IF;
         ELSE
           l_action_line_audit_rec.reversed_action_set_line_id := NULL;
         END IF;

         l_index := PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl.COUNT;
         PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl(l_index) := l_action_line_audit_rec;

       ELSIF p_insert_audit_flag = 'T' AND l_perform_return_status <> FND_API.G_RET_STS_SUCCESS THEN

         FND_MSG_PUB.get (
                       p_encoded        => FND_API.G_TRUE
                      ,p_msg_index      => FND_MSG_PUB.Count_Msg
                      ,p_data           => l_encoded_message_text
                      ,p_msg_index_out  => l_msg_index_out);

         l_action_line_audit_rec.reason_code           := l_audit_reason_code;
         l_action_line_audit_rec.action_code           := l_audit_action_code;
         l_action_line_audit_rec.encoded_error_message := l_encoded_message_text;
         IF l_action_status_code = 'REVERSE_PENDING' THEN
           l_action_line_audit_rec.reversed_action_set_line_id := l_action_set_line_id_tbl(i);
         END IF;
         l_index := PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl.COUNT;
         PA_ADVERTISEMENTS_PUB.g_action_line_audit_tbl(l_index) := l_action_line_audit_rec;

       END IF; -- if p_insert_audit_flag = 'T'

     END LOOP;

   END IF; -- if l_action_set_line_id_tbl.COUNT > 0

   IF FND_MSG_PUB.Count_Msg > 0 THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

 -- 4537865 : Included Exception Block
 EXCEPTION
        WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ADVERTISEMENTS_PVT'
                                , p_procedure_name => 'Remove_Advertisement'
                                , p_error_text  => SUBSTRB(SQLERRM,1,240));
        RAISE ;
 END Remove_Advertisement;

-- Start changes for Bug 4777149
----------------------------------------------------------------------
-- Procedure
--   Perform Check  Assignment is in Open Status
--
-- Purpose
--  Check if assignment is in open status before sending the advertisement mail.
----------------------------------------------------------------------
PROCEDURE check_assignment_open(
itemtype                        IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT NOCOPY VARCHAR2 --NOCOPY required for OUT and IN/OUT parameters
) IS
v_dummy varchar2(1);
v_assig_id pa_project_assignments.assignment_id%type;

BEGIN

v_assig_id := wf_engine.GetItemAttrNumber(itemtype        => itemtype,
                                          itemkey         => itemkey,
                                          aname           => 'ASSIGNMENT_ID' );

select 'Y' into v_dummy from pa_project_assignments
	where assignment_id = v_assig_id
	and STATUS_CODE in
		(select PROJECT_STATUS_CODE from pa_project_statuses
		 where PROJECT_SYSTEM_STATUS_CODE = 'OPEN_ASGMT');

resultout := wf_engine.eng_completed||':'||'S';

Exception
	when others then
		resultout := wf_engine.eng_completed||':'||'F';
	FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ADVERTISEMENTS_PVT'
				, p_procedure_name => 'Check_Assignment_Open'
				, p_error_text	=> SUBSTRB(SQLERRM,1,240));
        --RAISE ; // commented for 7134435
END check_assignment_open;
-- End changes for Bug 4777149

END PA_ADVERTISEMENTS_PVT;


/

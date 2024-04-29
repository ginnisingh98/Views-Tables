--------------------------------------------------------
--  DDL for Package Body PA_ASSIGNMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ASSIGNMENTS_PVT" AS
/*$Header: PARAPVTB.pls 120.6.12010000.5 2010/03/30 05:53:13 sugupta ship $*/
--
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */
li_message_level NUMBER := 1;

PROCEDURE Create_Assignment
( p_assignment_rec              IN     PA_ASSIGNMENTS_PUB.Assignment_Rec_Type
 ,p_asgn_creation_mode          IN     VARCHAR2                                        := 'FULL'
 ,p_unfilled_assignment_status  IN     pa_project_assignments.status_code%TYPE         := FND_API.G_MISS_CHAR
 ,p_resource_source_id          IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,p_project_subteam_id          IN     pa_project_subteams.project_subteam_id%TYPE     := FND_API.G_MISS_NUM
 ,p_location_city               IN     pa_locations.city%TYPE                          := FND_API.G_MISS_CHAR
 ,p_location_region             IN     pa_locations.region%TYPE                        := FND_API.G_MISS_CHAR
 ,p_location_country_code       IN     pa_locations.country_code%TYPE                  := FND_API.G_MISS_CHAR
 ,p_adv_action_set_id           IN    NUMBER                                           := FND_API.G_MISS_NUM
 ,p_start_adv_action_set_flag   IN    VARCHAR2                                         := FND_API.G_MISS_CHAR
 ,p_sum_tasks_flag                              IN     VARCHAR2                                                                            := FND_API.G_FALSE  -- FP.M Development
 ,p_budget_version_id                   IN         pa_resource_assignments.budget_version_id%TYPE  := FND_API.G_MISS_NUM
 ,p_number_of_requirements      IN     NUMBER                                          := 1
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,x_new_assignment_id           OUT    NOCOPY pa_project_assignments.assignment_id%TYPE --File.Sql.39 bug 4440895
 ,x_assignment_number           OUT    NOCOPY pa_project_assignments.assignment_number%TYPE --File.Sql.39 bug 4440895
 ,x_assignment_row_id           OUT    NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_resource_id                 OUT    NOCOPY pa_resources.resource_id%TYPE --File.Sql.39 bug 4440895
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )
IS

l_assignment_rec                PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
l_project_subteam_party_id      pa_project_subteam_parties.project_subteam_party_id%TYPE;
l_return_status                 VARCHAR2(10);
l_row_id                        ROWID;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(4000);
l_assignment_effort             pa_project_assignments.assignment_effort%TYPE;
l_work_type_id                  NUMBER;
l_expenditure_type              pa_project_assignments.expenditure_type%TYPE;
l_expenditure_type_class        pa_project_assignments.expenditure_type_class%TYPE;
l_assignment_effort_calc        VARCHAR2(1) := 'N';
l_raw_revenue                   NUMBER;
l_rec_version_number            NUMBER;
-- FP.M Development
l_location_city                 pa_locations.city%TYPE;
l_location_region               pa_locations.region%TYPE;
l_location_country_code         pa_locations.country_code%TYPE;

CURSOR get_subteam_id IS
SELECT  project_subteam_id,
        primary_subteam_flag
FROM    pa_project_subteam_parties
WHERE   object_type = 'PA_PROJECT_ASSIGNMENTS'
AND     object_id   = l_assignment_rec.source_assignment_id;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ASSIGNMENTS_PVT.Create_Assignment');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Create_Assignment.begin'
                        ,x_msg         => 'Beginning of the PVT Create_Assignment'
                        ,x_log_level   => 5);
  END IF;
  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Assign p_assignment_rec to l_assignment_rec
  l_assignment_rec := p_assignment_rec;

  -- FP.M Development
  -- If l_assignment_rec.resource_list_member_id is not miss_num
  -- and p_asgn_creation_mode is not 'COPY',
  -- the api must be called by the create team role page.
  -- In this case, we need to default assignment attributes that
  -- are not specified on page.

  IF l_assignment_rec.resource_list_member_id <> FND_API.G_MISS_NUM
     AND p_asgn_creation_mode <> 'COPY' THEN

     -- Commented for Performance fix 4898314 SQL ID 14905834
     -- SELECT work_type_id
     --      ,location_id
     --      ,city
     --      ,region
     --      ,country_code
     -- INTO   l_assignment_rec.work_type_id
     --      ,l_assignment_rec.location_id
     --      ,l_location_city
     --      ,l_location_region
     --      ,l_location_country_code
     -- FROM  PA_PROJECTS_PRM_V
     -- WHERE project_id = l_assignment_rec.project_id;

     --Included for Performance fix 4898314 SQL ID 14905834
        SELECT ppa.work_type_id
              ,pl.location_id
              ,pl.city
              ,pl.region
              ,pl.country_code
        INTO   l_assignment_rec.work_type_id
             ,l_assignment_rec.location_id
             ,l_location_city
             ,l_location_region
             ,l_location_country_code
        FROM pa_projects_all ppa,pa_locations pl
        WHERE project_id = l_assignment_rec.project_id
          AND PPA.LOCATION_ID = PL.LOCATION_ID(+) ;

     -- Bug 4282413: Job levels are passed in from CrUdTeamRoleVORowImpl.
         /*
     IF p_assignment_rec.assignment_type = 'OPEN_ASSIGNMENT' THEN
        SELECT ppr.default_min_job_level
              ,ppr.default_max_job_level
        INTO   l_assignment_rec.min_resource_job_level
              ,l_assignment_rec.max_resource_job_level
        FROM   pa_project_roles_lov_v ppr
              ,fnd_lookups pl
        WHERE  pl.lookup_type = 'YES_NO'
        AND    ppr.schedulable_flag = pl.lookup_code
        AND    ppr.project_role_id = l_assignment_rec.project_role_id;
     END IF; */
  ELSE
    l_location_city             := p_location_city;
    l_location_region           := p_location_region;
    l_location_country_code     := p_location_country_code;
  END IF;

  -- END FP.M Development
  IF P_DEBUG_MODE = 'Y' THEN
        pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Create_Assignment'
                ,x_msg         => 'after FP.M'
                ,x_log_level   => li_message_level);
  END IF;

  --dbms_output.put_line('before create assignment');
  --Create Requirement/Assignment
  IF p_assignment_rec.assignment_type = 'OPEN_ASSIGNMENT' THEN

    --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Create_Assignment.create_open'
                     ,x_msg         => 'Calling Create Requirement'
                     ,x_log_level   => 5);
  END IF;

    PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment
    ( p_assignment_rec            => l_assignment_rec
     ,p_asgn_creation_mode        => p_asgn_creation_mode
     ,p_location_city             => l_location_city
     ,p_location_region           => l_location_region
     ,p_location_country_code     => l_location_country_code
     ,p_adv_action_set_id         => p_adv_action_set_id
     ,p_start_adv_action_set_flag => p_start_adv_action_set_flag
         ,p_sum_tasks_flag                        => p_sum_tasks_flag
         ,p_budget_version_id             => p_budget_version_id
     ,p_number_of_requirements    => p_number_of_requirements
     ,p_commit                    => p_commit
     ,p_validate_only             => p_validate_only
     ,x_new_assignment_id         => x_new_assignment_id
     ,x_assignment_number         => x_assignment_number
     ,x_assignment_row_id         => x_assignment_row_id
     ,x_return_status             => x_return_status
  );

        IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Create_Assignment'
                ,x_msg         => 'after open_asgn_pvt.create, status = '||x_return_status
                ,x_log_level   => li_message_level);
        END IF;

  ELSE
    --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Create_Assignment.create_staff'
                     ,x_msg         => 'Calling Create Assignment'
                     ,x_log_level   => 5);

  END IF;
    PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment
    ( p_assignment_rec             => l_assignment_rec
     ,p_unfilled_assignment_status => p_unfilled_assignment_status
     ,p_resource_source_id         => p_resource_source_id
     ,p_location_city              => l_location_city
     ,p_location_region            => l_location_region
     ,p_location_country_code      => l_location_country_code
         ,p_sum_tasks_flag                         => p_sum_tasks_flag  -- FP.M Development
         ,p_budget_version_id              => p_budget_version_id
     ,p_commit                     => p_commit
     ,p_validate_only              => p_validate_only
     ,x_new_assignment_id          => x_new_assignment_id
     ,x_assignment_row_id          => x_assignment_row_id
     ,x_resource_id                => x_resource_id
     ,x_return_status              => x_return_status
    );
  END IF;

  --check the calendar is valid from a business rule point of view
  --need to call this after create_staffed_assignment b/c we may not have
  --the resource id until create_staffed_assignment is called (create_staffed_assignment calls create_resource).
  --if calendar_type is PROJECT or OTHER, calendar_id must be not null
  --if calendar_type is RESOURCE, calendar_id must be not null

  IF ((l_assignment_rec.calendar_type='PROJECT' OR l_assignment_rec.calendar_type='OTHER') AND l_assignment_rec.calendar_id IS NOT NULL AND l_assignment_rec.calendar_id <> FND_API.G_MISS_NUM) OR
     (l_assignment_rec.calendar_type='RESOURCE' AND x_resource_id IS NOT NULL AND x_resource_id<>FND_API.G_MISS_NUM) THEN
    PA_SCHEDULE_UTILS.Check_Calendar(p_calendar_type => l_assignment_rec.calendar_type,
                                   p_calendar_id   => l_assignment_rec.calendar_id,
                                   p_resource_id   => x_resource_id,
                                   p_start_date    => l_assignment_rec.start_date,
                                   p_end_date      => l_assignment_rec.end_date,
                                   x_return_status => l_return_status,
                                   x_msg_count     => l_msg_count,
                                   x_msg_data      => l_msg_data);
  END IF;

  --dbms_output.put_line('after create assignment:'||x_return_status);

  IF PA_ASSIGNMENTS_PUB.g_assignment_id_tbl.COUNT >0 THEN

    FOR i IN PA_ASSIGNMENTS_PUB.g_assignment_id_tbl.FIRST .. PA_ASSIGNMENTS_PUB.g_assignment_id_tbl.LAST LOOP

     --If no source assignment id, then call create subteam party once
     --else loop through the source assignment's subteam party table and
     --call create subteam party on each one of the source subteam ids

     IF (l_assignment_rec.source_assignment_id IS NULL) OR
        (l_assignment_rec.source_assignment_id=FND_API.G_MISS_NUM) THEN

       -- Check the necessary input parameters are there
       IF (p_project_subteam_id IS NOT NULL AND p_project_subteam_id <> FND_API.G_MISS_NUM)  THEN

         --Log Message
         IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
            PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Create_Assignment.create_subteam_party'
                          ,x_msg         => 'Calling Create Assignment'
                          ,x_log_level   => 5);
         END IF;

          PA_PROJECT_SUBTEAM_PARTIES_PVT.Create_Subteam_Party
            ( p_validate_only                   => p_validate_only
             ,p_project_subteam_id              => p_project_subteam_id
             ,p_object_type                     => 'PA_PROJECT_ASSIGNMENTS'
             ,p_object_id                       => PA_ASSIGNMENTS_PUB.g_assignment_id_tbl(i).assignment_id
             ,x_project_subteam_party_row_id    => l_row_id
             ,x_project_subteam_party_id        => l_project_subteam_party_id
             ,x_return_status                   => l_return_status
             ,x_msg_count                       => l_msg_count
             ,x_msg_data                        => l_msg_data
           );

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           -- PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
           --                      ,p_msg_name       => l_error_message_code);
           PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
          END IF;
        END IF;

      -- else source assignment id exist, then loop through subteam party table
      ELSE

         FOR get_subteam_id_rec IN get_subteam_id LOOP
            IF get_subteam_id_rec.project_subteam_id IS NOT NULL  THEN

            --Log Message
            IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
               PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Create_Assignment.create_subteam_party'
                                  ,x_msg         => 'Calling Create Assignment'
                                  ,x_log_level   => 5);
            END IF;

           PA_PROJECT_SUBTEAM_PARTIES_PVT.Create_Subteam_Party
          (  p_validate_only               => p_validate_only
           ,p_project_subteam_id          => get_subteam_id_rec.project_subteam_id
           ,p_object_type                 => 'PA_PROJECT_ASSIGNMENTS'
           ,p_object_id                   => PA_ASSIGNMENTS_PUB.g_assignment_id_tbl(i).assignment_id
           ,p_primary_subteam_flag        => get_subteam_id_rec.primary_subteam_flag
           ,x_project_subteam_party_row_id=> l_row_id
           ,x_project_subteam_party_id    => l_project_subteam_party_id
           ,x_return_status               => l_return_status
           ,x_msg_count                   => l_msg_count
           ,x_msg_data                    => l_msg_data
          );

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           -- PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
           --                      ,p_msg_name       => l_error_message_code);
           PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;

          END IF;  --error

        END IF;      --project subteam id is not null

       END LOOP; --looping through subteams

     END IF; -- end of checking source assignment id

    END LOOP; -- LOOPING through new assignment ids

    --
    --Calculate for assignment effort

    --Do not calculate assignment effort if this is a template requirement.
    --No timeline/schedule is created for template requirements.
    IF (l_assignment_rec.project_id IS NOT NULL AND l_assignment_rec.project_id <> FND_API.G_MISS_NUM) THEN

        l_assignment_effort := PA_SCHEDULE_UTILS.get_num_hours(p_assignment_rec.project_id, PA_ASSIGNMENTS_PUB.g_assignment_id_tbl(1).assignment_id);

    END IF;

    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Create_Assignment.add_asgmt_effort'
                          ,x_msg         => 'Adding Assignment Effort.'
                          ,x_log_level   => 5);
    END IF;

    IF l_assignment_effort IS NOT NULL THEN

      SELECT record_version_number INTO l_rec_version_number
        FROM pa_project_assignments
       WHERE assignment_id = PA_ASSIGNMENTS_PUB.g_assignment_id_tbl(1).assignment_id;

      --This is an bulk update for assignment effort using the global assignment_id array
      PA_PROJECT_ASSIGNMENTS_PKG.Update_Row
       ( p_assignment_id               => NULL
        ,p_record_version_number       => l_rec_version_number
        ,p_assignment_effort           => l_assignment_effort
        ,x_return_status               => l_return_status
       );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
      END IF;
     END IF;

   END IF;  --checking there are any new assignments ids

  -- Reset the error stack when returning to the calling program
     PA_DEBUG.Reset_Err_Stack;

  -- If g_error_exists is TRUE then set the x_return_status to 'E'

  IF PA_ASSIGNMENTS_PUB.g_error_exists = FND_API.G_TRUE  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;


  EXCEPTION
    WHEN OTHERS THEN
         --  4537865 : RESET OUT params to Proper Values
         x_new_assignment_id      := NULL ;
         x_assignment_number      := NULL ;
         x_assignment_row_id      := NULL ;
         x_resource_id            := NULL ;
         -- ENd : 4537865

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ASSIGNMENTS_PVT.Create_Assignment'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Create_Assignment;



PROCEDURE Update_Assignment
( p_assignment_rec              IN     PA_ASSIGNMENTS_PUB.Assignment_Rec_Type
 ,p_project_subteam_id          IN     pa_project_subteams.project_subteam_id%TYPE     := FND_API.G_MISS_NUM
 ,p_project_subteam_party_id    IN     pa_project_subteam_parties.project_subteam_party_id%TYPE   := FND_API.G_MISS_NUM
 ,p_location_city               IN     pa_locations.city%TYPE                          := FND_API.G_MISS_CHAR
 ,p_location_region             IN     pa_locations.region%TYPE                        := FND_API.G_MISS_CHAR
 ,p_location_country_code       IN     pa_locations.country_code%TYPE                  := FND_API.G_MISS_CHAR
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_project_subteam_party_id      pa_project_subteam_parties.project_subteam_party_id%TYPE;
l_return_status                 VARCHAR2(10);
l_record_version_number         NUMBER;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(4000);
l_object_id                     NUMBER;
l_work_type_id                  NUMBER;
l_assignment_rec                PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;

-- cursor to get the utilization information
CURSOR  get_work_type IS
SELECT  work_type_id
FROM    pa_project_assignments
WHERE   assignment_id = p_assignment_rec.assignment_id;

BEGIN

  --dbms_output.put_line('Beginning PVTB Update_Assignment');

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ASSIGNMENTS_PVT.Update_Assignment');

   --Log Message
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Update_Assignment.begin'
                        ,x_msg         => 'Beginning of PVT Update_Assignment'
                        ,x_log_level   => 5);
   END IF;


  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --dbms_output.put_line('Update Subteam party 1');
  --
  --Update Subteam Party
  --
  --If Subteam Party Id exist or Subteam Id exist, then call Update Subteam Party
  IF (p_project_subteam_id IS NOT NULL AND p_project_subteam_id <> FND_API.G_MISS_NUM OR
      p_project_subteam_party_id IS NOT NULL AND p_project_subteam_party_id <> FND_API.G_MISS_NUM) AND
     (p_assignment_rec.assignment_id IS NOT NULL AND p_assignment_rec.assignment_id <>FND_API.G_MISS_NUM) THEN

     --Log Message
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Update_Assignment.update_subteam_party'
                           ,x_msg         => 'Calling Update_SPT_Assgn for subteam party.'
                           ,x_log_level   => 5);
     END IF;
     PA_PROJECT_SUBTEAM_PARTIES_PVT.Update_SPT_Assgn
       ( p_validate_only                => p_validate_only
        ,p_project_subteam_party_id     => p_project_subteam_party_id
        ,p_project_subteam_id           => p_project_subteam_id
        ,p_object_type                  => 'PA_PROJECT_ASSIGNMENTS'
        ,p_object_id                    => p_assignment_rec.assignment_id
        ,x_project_subteam_party_id     => l_project_subteam_party_id
        ,x_return_status                => l_return_status
        ,x_record_version_number        => l_record_version_number
        ,x_msg_count                    => l_msg_count
       ,x_msg_data                      => l_msg_data
      );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       -- PA_UTILS.Add_Message( p_app_short_name => 'PA'
       --                      ,p_msg_name       => l_error_message_code);
         PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;
  END IF;

  --If this is a template requirement then it is possible to update the
  --start date and the end date through this API - as template requirements
  --do not have schedules.  For requirements which belong to projects, these updates
  --are not allowed through this API and would have already caused a validation error
  --in the public API.
  IF p_assignment_rec.start_date<> FND_API.G_MISS_DATE OR p_assignment_rec.end_date<>FND_API.G_MISS_DATE THEN
     IF  p_assignment_rec.start_date > p_assignment_rec.end_date THEN
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                            ,p_msg_name       => 'PA_INVALID_START_DATE');
     PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;
  END IF;

  -- Get the old values of Work Type
  OPEN get_work_type;
  FETCH get_work_type INTO l_work_type_id;
  CLOSE get_work_type;

  --Get the new tp amount type from the work type if work type is updated
  l_assignment_rec := p_assignment_rec;

  -- FP-J Bug: no data found in Mass Update Team Role
  --  work_type_id may be passed in as null within Mass Update
  IF l_assignment_rec.work_type_id IS NOT NULL
   AND l_assignment_rec.work_type_id <> FND_API.G_MISS_NUM
   AND l_assignment_rec.work_type_id <> l_work_type_id THEN

    PA_FP_ORG_FCST_UTILS.Get_Tp_Amount_Type(
               p_project_id      => l_assignment_rec.project_id
              ,p_work_type_id    => l_assignment_rec.work_type_id
              ,x_tp_amount_type  => l_assignment_rec.fcst_tp_amount_type
              ,x_return_status   => l_return_status
              ,x_msg_count       => l_msg_count
              ,x_msg_data        => l_msg_data
    );

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
    END IF;


  END IF;


  IF l_assignment_rec.assignment_type = 'OPEN_ASSIGNMENT' THEN
   --Log Message
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Update_Assignment.update_open'
                        ,x_msg         => 'Calling update requirement.'
                        ,x_log_level   => 5);
   END IF;

    PA_OPEN_ASSIGNMENT_PVT.Update_Open_Assignment
    ( p_assignment_rec         => l_assignment_rec
     ,p_location_city          => p_location_city
     ,p_location_region        => p_location_region
     ,p_location_country_code  => p_location_country_code
     ,p_validate_only          => p_validate_only
     ,p_commit                 => p_commit
     ,x_return_status          => x_return_status
    );
  ELSE

   --Log Message
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Update_Assignment.update_staff'
                        ,x_msg         => 'Calling update assignment.'
                        ,x_log_level   => 5);
   END IF;

    PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment
    ( p_assignment_rec        => l_assignment_rec
     ,p_location_city         => p_location_city
     ,p_location_region       => p_location_region
     ,p_location_country_code => p_location_country_code
     ,p_validate_only         => p_validate_only
     ,p_commit                => p_commit
     ,x_return_status         => x_return_status
    );
  END IF;

  -- Reset the error stack when returning to the calling program
     PA_DEBUG.Reset_Err_Stack;

  -- If g_error_exists is TRUE then set the x_return_status to 'E'

  IF PA_ASSIGNMENTS_PUB.g_error_exists = FND_API.G_TRUE  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;


  EXCEPTION
    WHEN OTHERS THEN

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ASSIGNMENTS_PVT.Update_Assignment'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Update_Assignment;


PROCEDURE Delete_Assignment
( p_assignment_row_id           IN     ROWID                                           := NULL
 ,p_assignment_id               IN     pa_project_assignments.assignment_id%TYPE       := FND_API.G_MISS_NUM
 ,p_assignment_type             IN     pa_project_assignments.assignment_type%TYPE     := FND_API.G_MISS_CHAR
 ,p_record_version_number       IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,p_assignment_number           IN     pa_project_assignments.assignment_number%TYPE   := FND_API.G_MISS_NUM
 ,p_calling_module              IN     VARCHAR2                                        := FND_API.G_MISS_CHAR
 ,p_project_party_id            IN     pa_project_parties.project_party_id%TYPE        := FND_API.G_MISS_NUM
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_return_status                 VARCHAR2(10);
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(4000);
l_task_assignment_id_tbl       system.pa_num_tbl_type;
l_task_version_id_tbl              system.pa_num_tbl_type := system.pa_num_tbl_type();
l_budget_version_id_tbl        system.pa_num_tbl_type := system.pa_num_tbl_type();
l_struct_version_id_tbl        system.pa_num_tbl_type := system.pa_num_tbl_type();
l_project_assignment_id_tbl    system.pa_num_tbl_type := system.pa_num_tbl_type();
l_cur_role_flag                            pa_res_formats_b.role_enabled_flag%TYPE;


 CURSOR get_linked_res_asgmts IS
 SELECT resource_assignment_id, wbs_element_version_id, budget_version_id, project_structure_version_id
 FROM
 (
         (SELECT ra.resource_assignment_id, ra.wbs_element_version_id, bv.budget_version_id, bv.project_structure_version_id
          FROM  PA_RESOURCE_ASSIGNMENTS ra
               ,PA_BUDGET_VERSIONS bv
               ,PA_PROJ_ELEM_VER_STRUCTURE evs
--                 ,PA_PROJECT_ASSIGNMENTS pa -- 5110598 Removed PA_PROJECT_ASSIGNMENTS table usage
          WHERE ra.project_id = bv.project_id
          AND   bv.project_id = evs.project_id
		  AND   bv.budget_type_code IS NULL -- added for bug#8247628
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
		  AND   bv.budget_type_code IS NULL -- added for bug#8247628
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
  PA_DEBUG.init_err_stack('PA_ASSIGNMENTS_PVT.Delete_Assignment');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Log Message
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Delete_Assignment.begin'
                        ,x_msg         => 'Beginning of Delete_Assignment.'
                        ,x_log_level   => 5);
   END IF;

  -- Delete Subteam Party if assignment id exists
  IF (p_assignment_id IS NOT NULL AND p_assignment_id <>FND_API.G_MISS_NUM)  THEN

    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Delete_Assignment.delete_subteam_party'
                          ,x_msg         => 'Deleting subteam party'
                          ,x_log_level   => 5);
    END IF;
    PA_PROJECT_SUBTEAM_PARTIES_PVT.Delete_SubteamParty_By_Obj
    ( p_validate_only                   => p_validate_only
     ,p_object_type                     => 'PA_PROJECT_ASSIGNMENTS'
     ,p_object_id                       => p_assignment_id
     ,p_init_msg_list			=> FND_API.G_FALSE  -- Added for bug 5130421
     ,x_return_status                   => l_return_status
     ,x_msg_count                       => l_msg_count
     ,x_msg_data                        => l_msg_data
    );
    --dbms_output.put_line('return status is '||l_return_status);
    --dbms_output.put_line('message count is '||l_msg_count);
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
     -- PA_UTILS.Add_Message( p_app_short_name => 'PA'
     --                      ,p_msg_name       => l_error_message_code);
      PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
    END IF;

	  --Bug 6330317
    IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Delete_Assignment.delete_rows'
                          ,x_msg         => 'Deleting Conflict History Information'
                          ,x_log_level   => 5);
    END IF;

    --Bug#9356483
    IF p_assignment_type IN ('STAFFED_ASSIGNMENT','STAFFED_ADMIN_ASSIGNMENT') THEN

    PA_ASGN_CONFLICT_HIST_PKG.Delete_rows
    ( p_assignment_id                   => p_assignment_id
     ,x_return_status                   => l_return_status
     ,x_msg_count                       => l_msg_count
     ,x_msg_data                        => l_msg_data
    );

   END IF;
  --Bug#9356483

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
     -- PA_UTILS.Add_Message( p_app_short_name => 'PA'
     --                      ,p_msg_name       => l_error_message_code);
      PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
    END IF;
  END IF;

  -- FP.M Development
  -- run the cursor before the assignment/requirement is deleted
  OPEN  get_linked_res_asgmts;
  FETCH get_linked_res_asgmts
   BULK COLLECT INTO l_task_assignment_id_tbl,
                     l_task_version_id_tbl,
                                 l_budget_version_id_tbl,
                                         l_struct_version_id_tbl;
  CLOSE get_linked_res_asgmts;

  -- FP.M Development
  -- Check whether role is part of the deleted assignment's
  -- planning resource's resource format
  -- 4117262: Move this cursor fetch to BEFORE deleting the assignment
  l_cur_role_flag := NULL;
  OPEN  get_res_mand_attributes;
  FETCH get_res_mand_attributes INTO l_cur_role_flag;
  CLOSE get_res_mand_attributes;

  IF p_assignment_type = 'OPEN_ASSIGNMENT' THEN

   --Log Message
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Delete_Assignment.delete_open'
                        ,x_msg         => 'Deleting Requirement'
                        ,x_log_level   => 5);
   END IF;

    PA_OPEN_ASSIGNMENT_PVT.Delete_Open_Assignment
    ( p_assignment_row_id      => p_assignment_row_id
     ,p_assignment_id          => p_assignment_id
     ,p_record_version_number  => p_record_version_number
      ,p_calling_module        => p_calling_module
     ,p_commit                 => p_commit
     ,p_validate_only          => p_validate_only
     ,x_return_status          => x_return_status
    );
   --
  ELSE

   --Log Message
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Delete_Assignment.delete_staff'
                         ,x_msg         => 'Deleting Assignment'
                         ,x_log_level   => 5);
   END IF;

     PA_STAFFED_ASSIGNMENT_PVT.Delete_Staffed_Assignment
     ( p_assignment_row_id     => p_assignment_row_id
      ,p_assignment_id         => p_assignment_id
      ,p_record_version_number => p_record_version_number
      ,p_project_party_id      => p_project_party_id
      ,p_calling_module        => p_calling_module
      ,p_commit                => p_commit
     ,p_validate_only          => p_validate_only
      ,x_return_status         => x_return_status
    );
  END IF;

  -- FP.M Development
           IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
              PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Delete_Assignment.delete_staff'
                                 ,x_msg         => 'Call Update_Task_Assignments'
                                 ,x_log_level   => 5);
           END IF;


           -- 1. Change project_assignment_id to NULL (-1)
           -- 2. Don't wipe out project_role_id,
           -- 3. Wipe out named_role when it is not a mandatory attribute
           --    of planning resource
           -- 4117262: Modified to check the flag value only
           IF l_cur_role_flag = 'Y' THEN

                   Update_Task_Assignments(
                          p_task_assignment_id_tbl      =>      l_task_assignment_id_tbl
                         ,p_task_version_id_tbl         =>  l_task_version_id_tbl
                         ,p_budget_version_id_tbl       =>  l_budget_version_id_tbl
                         ,p_struct_version_id_tbl       =>  l_struct_version_id_tbl
                         ,p_project_assignment_id       =>  -1
                         ,x_return_status           =>  l_return_status
                   );
           ELSE
                   Update_Task_Assignments(
                          p_task_assignment_id_tbl      =>      l_task_assignment_id_tbl
                         ,p_task_version_id_tbl         =>  l_task_version_id_tbl
                         ,p_budget_version_id_tbl       =>  l_budget_version_id_tbl
                         ,p_struct_version_id_tbl       =>  l_struct_version_id_tbl
                         ,p_project_assignment_id       =>  -1
                         ,p_named_role                          =>  FND_API.G_MISS_CHAR
                         ,x_return_status           =>  l_return_status
                   );
           END IF;

/*


  BULK COLLECT INTO l_task_assignment_id_tbl


  l_project_assignment_id_tbl.extend(l_task_assignment_id_tbl.count);

  IF l_task_assignment_id_tbl.COUNT <>0 THEN
          FOR i IN l_task_assignment_id_tbl.FIRST .. l_task_assignment_id_tbl.LAST LOOP
              l_project_assignment_id_tbl(i) := NULL;
          END LOOP;

          pa_fp_planning_transaction_pub.update_planning_transactions
        (
                 p_context                      => 'TASK_ASSIGNMENT'
                ,p_resource_assignment_id_tbl   => l_task_assignment_id_tbl
                ,p_project_assignment_id_tbl    => l_project_assignment_id_tbl
                ,X_Return_Status                => l_return_status
                ,X_Msg_Data                     => l_msg_data
                ,X_Msg_Count                    => l_msg_count);
  END IF;
  */

  -- Reset the error stack when returning to the calling program
     PA_DEBUG.Reset_Err_Stack;

  -- If g_error_exists is TRUE then set the x_return_status to 'E'

  IF PA_ASSIGNMENTS_PUB.g_error_exists = FND_API.G_TRUE  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;


  EXCEPTION
    WHEN OTHERS THEN

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ASSIGNMENTS_PVT.Delete_Assignment'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Delete_Assignment;

/* --------------------------------------------------------------------
FUNCTION: Update_Revenue_Bill_Rate
PURPOSE:  This API updates the revenue_bill_rate for assignments passed
          in. It should be only called by the Project Forecast Process.
-------------------------------------------------------------------- */
/* PROCEDURE Update_Revenue_Bill_Rate (p_assignment_id_tbl     IN  SYSTEM.pa_num_tbl_type,
                                    p_revenue_bill_rate_tbl IN  SYSTEM.pa_num_tbl_type,
                                    x_return_status         OUT VARCHAR2)  */
 PROCEDURE Update_Revenue_Bill_Rate
( p_assignment_id_tbl           IN     PA_PLSQL_DATATYPES.IdTabTyp
 ,p_revenue_bill_rate_tbl       IN     PA_PLSQL_DATATYPES.NumTabTyp
 ,x_return_status               OUT    NOCOPY VARCHAR2 )   --File.Sql.39 bug 4440895
IS
BEGIN

  PA_DEBUG.init_err_stack('PA_ASSIGNMENTS_PVT.Update_Revenue_Bill_Rate');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_assignment_id_tbl.COUNT > 0 THEN
     FOR i IN p_assignment_id_tbl.FIRST .. p_assignment_id_tbl.LAST LOOP

         pa_project_assignments_pkg.Update_row (
                              p_assignment_id           => p_assignment_id_tbl(i),
                              p_revenue_bill_rate       => p_revenue_bill_rate_tbl(i),
                              x_return_status           => x_return_status);
     END LOOP;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        fnd_msg_pub.add_exc_msg
                (p_pkg_name       => 'PA_ASSIGNMENTS_PVT',
                 p_procedure_name => 'Update_Revenue_Bill_Rate');

   RAISE;
END Update_Revenue_Bill_Rate;

--
--

/* Added procedure Update_Transfer_Price  for bug 3051110
  This Procedure calls update_row which will update the record in pa_project_assignments table
  with the transfer price rate and transfer price rate curr passed.
*/

PROCEDURE Update_Transfer_Price
( p_assignment_id               IN     pa_project_assignments.assignment_id%TYPE
 ,p_transfer_price_rate         IN     pa_project_assignments.transfer_price_rate%TYPE
 ,p_transfer_pr_rate_curr       IN     pa_project_assignments.transfer_pr_rate_curr%TYPE
 ,p_debug_mode                  IN     VARCHAR2 default 'N'
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  pa_project_assignments_pkg.update_row(
     p_assignment_id => p_assignment_id,
     p_transfer_price_rate => p_transfer_price_rate,
     p_transfer_pr_rate_curr => p_transfer_pr_rate_curr,
     x_return_status => x_return_status);

EXCEPTION
   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        fnd_msg_pub.add_exc_msg
                (p_pkg_name       => 'PA_ASSIGNMENTS_PVT',
                 p_procedure_name => 'Update_Transfer_Price');

   RAISE;
END Update_Transfer_Price;

/* Added procedure Calc_Init_Transfer_Price for bug 3051110. (TP Enhancement)
This Procedure calls the Billing API which calculates the TP Rate and returns.
The rate is used for updation in the pa_project_assignments table.
*/

PROCEDURE Calc_Init_Transfer_Price
( p_assignment_id     IN         pa_project_assignments.assignment_id%TYPE
 ,p_start_date        IN         pa_project_assignments.start_date%TYPE
 ,p_debug_mode        IN         VARCHAR2 DEFAULT 'N'
 ,x_return_status     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_data          OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count         OUT        NOCOPY Number --File.Sql.39 bug 4440895
)
IS

lx_transfer_price_rate   pa_project_assignments.transfer_price_rate%TYPE;
lx_transfer_pr_rate_curr pa_project_assignments.transfer_pr_rate_curr%TYPE;
l_start_date  pa_project_assignments.start_date%TYPE := Null;

BEGIN

if p_debug_mode = 'Y' THEN
  pa_debug.write('PA_ASSIGNMENT_PVT.Calc_Init_Transfer_Price', 'Calling PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price' , 3);
end if;

/* Calling get_initial_transfer_price to get the transfer_price_rate and transfer_price_rate */

BEGIN

/*
This select is done for getting the min item_date from pa_forecast_items table.
There can be case that the assignment start date is a holiday (Exception in the calendar)
and hence no fi will be created for the assignment start date. So we need to get the first
working date which is done in the select below. If the min(item_date) is null, we dont call the
pa_cc_transfer_price.get_initial_transfer_price api
*/

select min(item_date) into l_start_date
from pa_forecast_items
WHERE        Assignment_id = p_assignment_id
AND          Error_Flag = 'N'
AND          Delete_Flag = 'N';

EXCEPTION WHEN NO_DATA_FOUND THEN
l_start_date := NULL;
lx_transfer_price_rate := NULL;
lx_transfer_pr_rate_curr := NULL;
END;

if p_debug_mode = 'Y' THEN
  pa_debug.write('PA_ASSIGNMENT_PVT.Calc_Init_Transfer_Price','The starting date as in forecast items table:'||l_start_date, 3);
end if;

IF l_start_date IS NOT NULL THEN

  IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Calc_Init_Transfer_Price'
          ,x_msg         => 'asgmt_id='||p_assignment_id||
                                                        ' start_date='||l_start_date||
                                                        ' debug_mod='||p_debug_mode
          ,x_log_level   => li_message_level);
  END IF;

PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price
( p_assignment_id     => p_assignment_id
 ,p_start_date        => l_start_date
 ,p_debug_mode        => p_debug_mode
 ,x_transfer_price_rate => lx_transfer_price_rate
 ,x_transfer_pr_rate_curr => lx_transfer_pr_rate_curr
 ,x_return_status     => x_return_status
 ,x_msg_data          => x_msg_data
 ,x_msg_count         => x_msg_count
);

if p_debug_mode = 'Y' THEN
  pa_debug.write('PA_ASSIGNMENT_PVT.Calc_Init_Transfer_Price',' Out of  PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 3);
  pa_debug.write('PA_ASSIGNMENT_PVT.Calc_Init_Transfer_Price','status is :'||x_return_status||' : x_msg_count:'||x_msg_count, 3);
  pa_debug.write('PA_ASSIGNMENT_PVT.Calc_Init_Transfer_Price','Transfer Price Rate:'||lx_transfer_price_rate, 3);
  pa_debug.write('PA_ASSIGNMENT_PVT.Calc_Init_Transfer_Price','Transfer Price Rate curr:'||lx_transfer_pr_rate_curr, 3);
end if;

/* Call to update_Transfer_Price to udpate the transfer_price_Rate and transfer_pr_rate_curr only if no error */

IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

IF p_debug_mode = 'Y' THEN
  pa_debug.write('PA_ASSIGNMENT_PVT.Calc_Init_Transfer_Price',' Calling update_transfer_price with proper Values', 3);
END IF;

PA_ASSIGNMENTS_PVT.Update_Transfer_Price
(
 p_assignment_id        => p_assignment_id
 ,p_transfer_price_rate  => lx_transfer_price_rate
 ,p_transfer_pr_rate_curr    => lx_transfer_pr_rate_curr
 ,x_return_status            => x_return_status
 );

END IF;

if p_debug_mode = 'Y' THEN
  pa_debug.write('PA_ASSIGNMENT_PVT.Calc_Init_Transfer_Price',' Out of update_transfer_price', 3);
  pa_debug.write('PA_ASSIGNMENT_PVT.Calc_Init_Transfer_Price',' x_return_status: '||x_return_status, 3);
end if;

END IF;
-- 4537865 : Included Exception Block
EXCEPTION
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                x_msg_count := 1;
                x_msg_data := SUBSTRB(SQLERRM,1,240);

                FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENTS_PVT'
                                        ,p_procedure_name => 'Calc_Init_Transfer_Price'
                                        ,P_error_text     => x_msg_data );
                RAISE ;
END Calc_Init_Transfer_Price;

PROCEDURE Update_Task_Assignments
( p_mode                                        IN  VARCHAR2                       := 'UPDATE'
 ,p_task_assignment_id_tbl      IN      system.pa_num_tbl_type
 ,p_task_version_id_tbl         IN  system.pa_num_tbl_type
 ,p_budget_version_id_tbl       IN  system.pa_num_tbl_type
 ,p_struct_version_id_tbl       IN  system.pa_num_tbl_type
 ,p_project_assignment_id       IN  NUMBER                                 := NULL
 ,p_resource_list_member_id IN  NUMBER                             := NULL
-- pass in all resource attributes
 ,p_resource_class_flag         IN      VARCHAR2                           := NULL
 ,p_resource_class_code         IN      VARCHAR2                           := NULL
 ,p_resource_class_id           IN      NUMBER                             := NULL
 ,p_res_type_code                       IN      VARCHAR2                           := NULL
 ,p_incur_by_res_type           IN      VARCHAR2                           := NULL
 ,p_person_id                           IN      NUMBER                             := NULL
 ,p_job_id                                      IN      NUMBER                             := NULL
 ,p_person_type_code            IN      VARCHAR2                           := NULL
 ,p_named_role                          IN      VARCHAR2                           := NULL  -- named_role
 ,p_bom_resource_id                     IN      NUMBER                             := NULL
 ,p_non_labor_resource          IN      VARCHAR2                           := NULL
 ,p_inventory_item_id           IN      NUMBER                             := NULL
 ,p_item_category_id            IN      NUMBER                             := NULL
 ,p_project_role_id                     IN  NUMBER                                 := NULL
 ,p_organization_id                     IN      NUMBER                             := NULL
 ,p_fc_res_type_code            IN      VARCHAR2                           := NULL
 ,p_expenditure_type            IN      VARCHAR2                           := NULL
 ,p_expenditure_category        IN      VARCHAR2                           := NULL
 ,p_event_type                          IN      VARCHAR2                           := NULL
 ,p_revenue_category_code       IN      VARCHAR2                           := NULL
 ,p_supplier_id                         IN      NUMBER                             := NULL
 ,p_spread_curve_id                     IN      NUMBER                             := NULL
 ,p_etc_method_code                     IN      VARCHAR2                           := NULL
 ,p_mfc_cost_type_id            IN      NUMBER                             := NULL
 ,p_incurred_by_res_flag        IN      VARCHAR2                           := NULL
 ,p_incur_by_res_class_code     IN      VARCHAR2                           := NULL
 ,p_incur_by_role_id            IN      NUMBER                             := NULL
 ,p_unit_of_measure                     IN      VARCHAR2                           := NULL
 ,p_org_id                                      IN      NUMBER                             := NULL
 ,p_rate_based_flag                     IN      VARCHAR2                           := NULL
 ,p_rate_expenditure_type       IN      VARCHAR2                           := NULL
 ,p_rate_func_curr_code         IN      VARCHAR2                           := NULL
 ,p_rate_incurred_by_org_id     IN      NUMBER                             := NULL
 ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) IS

 l_task_assignment_id_tbl       system.pa_num_tbl_type;
 l_task_version_id_tbl                  system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_budget_version_id_tbl        system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_struct_version_id_tbl        system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_update_task_asgmt_id_tbl             system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_last_struct_version_id               NUMBER;
 l_update_task_version_id_tbl   system.pa_num_tbl_type := system.pa_num_tbl_type();

 l_project_assignment_id_tbl    system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_resource_list_member_id_tbl  SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_proj_req_res_format_id       NUMBER;
 l_last_bvid                                    NUMBER;
 l_update_count                                 NUMBER;

 l_return_status                        VARCHAR2(1);
 l_msg_count                            NUMBER;
 l_msg_data                             VARCHAR2(2000);
 l_overall_return_status        VARCHAR2(1);
 l_project_id                                   NUMBER;
 l_edit_task_ok                                 VARCHAR2(1);
 l_msg_count1                                   NUMBER;
 l_msg_count2                                   NUMBER;

 l_resource_class_flag_tbl              SYSTEM.PA_VARCHAR2_1_TBL_TYPE := system.pa_varchar2_1_tbl_type();
 l_resource_class_code_tbl              SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_resource_class_id_tbl                SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_res_type_code_tbl                    SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_incur_by_res_type_tbl                SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_person_id_tbl                                SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_job_id_tbl                                   SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_person_type_code_tbl                 SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_named_role_tbl                               SYSTEM.PA_VARCHAR2_80_TBL_TYPE := system.pa_varchar2_80_tbl_type();
 l_bom_resource_id_tbl                  SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_non_labor_resource_tbl               SYSTEM.PA_VARCHAR2_20_TBL_TYPE := system.pa_varchar2_20_tbl_type();
 l_inventory_item_id_tbl                SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_item_category_id_tbl                 SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_project_role_id_tbl                  SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_organization_id_tbl                  SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_fc_res_type_code_tbl                 SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_expenditure_type_tbl                 SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_expenditure_category_tbl             SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_event_type_tbl                               SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_revenue_category_code_tbl    SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_supplier_id_tbl                              SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_spread_curve_id_tbl                  SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_etc_method_code_tbl                  SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_mfc_cost_type_id_tbl                 SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_incurred_by_res_flag_tbl             SYSTEM.PA_VARCHAR2_1_TBL_TYPE := system.pa_varchar2_1_tbl_type();
 l_incur_by_res_class_code_tbl  SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_incur_by_role_id_tbl                 SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_unit_of_measure_tbl                  SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_org_id_tbl                                   SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_rate_based_flag_tbl                  SYSTEM.PA_VARCHAR2_1_TBL_TYPE := system.pa_varchar2_1_tbl_type();
 l_rate_expenditure_type_tbl    SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_rate_func_curr_code_tbl              SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_rate_incurred_by_org_id_tbl  SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();

 -- Added for Bug 6856934
 l_structure_ver_name                  pa_proj_elem_ver_structure.name%type;

BEGIN
   l_overall_return_status := FND_API.G_RET_STS_SUCCESS;

   l_task_assignment_id_tbl := p_task_assignment_id_tbl;
   l_task_version_id_tbl        := p_task_version_id_tbl;
   l_budget_version_id_tbl  := p_budget_version_id_tbl;
   l_struct_version_id_tbl      := p_struct_version_id_tbl;
   l_update_task_asgmt_id_tbl.delete();

   IF l_task_assignment_id_tbl.COUNT <> 0 THEN

   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Update_Task_Assignments'
                          ,x_msg         => 'l_task_assignment_id_tbl.COUNT='||l_task_assignment_id_tbl.COUNT
                          ,x_log_level   => li_message_level);
   END IF;

        l_last_bvid     := l_budget_version_id_tbl(1);
        l_last_struct_version_id := l_struct_version_id_tbl(1);
        l_update_count := 0;

    SELECT project_id
    INTO   l_project_id
        FROM   pa_resource_assignments
        WHERE  resource_assignment_id = l_task_assignment_id_tbl(1);

        FOR j IN l_task_assignment_id_tbl.FIRST .. l_task_assignment_id_tbl.LAST + 1 LOOP

                IF P_DEBUG_MODE = 'Y' THEN
               pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Update_Task_Assignments'
                          ,x_msg         => 'inside loop'
                          ,x_log_level   => li_message_level);
                END IF;

           IF j = l_task_assignment_id_tbl.LAST + 1
                  OR l_budget_version_id_tbl(j) <> l_last_bvid THEN

                  IF P_DEBUG_MODE = 'Y' THEN
                         pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Update_Task_Assignments'
                          ,x_msg         => 'prepare to call'
                          ,x_log_level   => li_message_level);
                  END IF;

          l_project_assignment_id_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_resource_list_member_id_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_resource_class_flag_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_resource_class_code_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_resource_class_id_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_res_type_code_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_incur_by_res_type_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_person_id_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_job_id_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_person_type_code_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_named_role_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_bom_resource_id_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_non_labor_resource_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_inventory_item_id_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_item_category_id_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_project_role_id_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_organization_id_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_fc_res_type_code_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_expenditure_type_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_expenditure_category_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_event_type_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_revenue_category_code_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_supplier_id_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_spread_curve_id_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_etc_method_code_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_mfc_cost_type_id_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_incurred_by_res_flag_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_incur_by_res_class_code_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_incur_by_role_id_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_unit_of_measure_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_org_id_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_rate_based_flag_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_rate_expenditure_type_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_rate_func_curr_code_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);
                  l_rate_incurred_by_org_id_tbl.extend(l_update_task_asgmt_id_tbl.COUNT);

                  IF P_DEBUG_MODE = 'Y' THEN
                 pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Update_Task_Assignments'
              ,x_msg         => 'struct_version_id='||l_last_struct_version_id||
                                                                ' bvid='||l_last_bvid
              ,x_log_level   => li_message_level);
                  END IF;

          FOR i IN l_update_task_asgmt_id_tbl.FIRST .. l_update_task_asgmt_id_tbl.LAST LOOP

            l_project_assignment_id_tbl(i) := p_project_assignment_id;
                        l_resource_list_member_id_tbl(i) := p_resource_list_member_id;
                        l_resource_class_flag_tbl(i) := p_resource_class_flag;
                        l_resource_class_code_tbl(i) := p_resource_class_code;
                        l_resource_class_id_tbl(i) := p_resource_class_id;
                        l_res_type_code_tbl(i) := p_res_type_code;
                        l_incur_by_res_type_tbl(i) := p_incur_by_res_type;
                        l_person_id_tbl(i) := p_person_id;
                        l_job_id_tbl(i) := p_job_id;
                        l_person_type_code_tbl(i) := p_person_type_code;
                        l_named_role_tbl(i) := p_named_role;
                        l_bom_resource_id_tbl(i) := p_bom_resource_id;
                        l_non_labor_resource_tbl(i) := p_non_labor_resource;
                        l_inventory_item_id_tbl(i) := p_inventory_item_id;
                        l_item_category_id_tbl(i) := p_item_category_id;
                        l_project_role_id_tbl(i) := p_project_role_id;
                        l_organization_id_tbl(i) := p_organization_id;
                        l_fc_res_type_code_tbl(i) := p_fc_res_type_code;
                        l_expenditure_type_tbl(i) := p_expenditure_type;
                        l_expenditure_category_tbl(i) := p_expenditure_category;
                        l_event_type_tbl(i) := p_event_type;
                        l_revenue_category_code_tbl(i) := p_revenue_category_code;
                        l_supplier_id_tbl(i) := p_supplier_id;
                        l_spread_curve_id_tbl(i) := p_spread_curve_id;
                        l_etc_method_code_tbl(i) := p_etc_method_code;
                        l_mfc_cost_type_id_tbl(i) := p_mfc_cost_type_id;
                        l_incurred_by_res_flag_tbl(i) := p_incurred_by_res_flag;
                        l_incur_by_res_class_code_tbl(i) := p_incur_by_res_class_code;
                        l_incur_by_role_id_tbl(i) := p_incur_by_role_id;
                        l_unit_of_measure_tbl(i) := p_unit_of_measure;
                        l_org_id_tbl(i) := p_org_id;
                        l_rate_based_flag_tbl(i) := p_rate_based_flag;
                        l_rate_expenditure_type_tbl(i) := p_rate_expenditure_type;
                        l_rate_func_curr_code_tbl(i) := p_rate_func_curr_code;
                        l_rate_incurred_by_org_id_tbl(i) := p_rate_incurred_by_org_id;

                        IF P_DEBUG_MODE = 'Y' THEN
                    pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Update_Task_Assignments'
                ,x_msg         => 'i='||i||'version id='||l_update_task_version_id_tbl(i)||
                                                          ' task_id='||l_update_task_asgmt_id_tbl(i)||
                                                          ' asgmt_id='||l_project_assignment_id_tbl(i)||
                                                          ' rlm='||l_resource_list_member_id_tbl(i)
                ,x_log_level   => li_message_level);

                    pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Update_Task_Assignments'
                ,x_msg         => 'i='||i||'res_class_flag='||l_resource_class_flag_tbl(i)||
                                                          ' res_class_code='||l_resource_class_code_tbl(i)||
                                                          ' res_class_id='||l_resource_class_id_tbl(i)||
                                                          ' res_type_code='||l_res_type_code_tbl(i)||
                                                          ' person_id='||l_person_id_tbl(i)
                ,x_log_level   => li_message_level);

                    pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Update_Task_Assignments'
                ,x_msg         => 'i='||i||'job_id='||l_job_id_tbl(i)||
                                                          ' person_type_code='||l_person_type_code_tbl(i)||
                                                          ' named_role='||l_named_role_tbl(i)||
                                                          ' bom_res_id='||l_bom_resource_id_tbl(i)||
                                                          ' non_labor_res='||l_non_labor_resource_tbl(i)
                ,x_log_level   => li_message_level);

                    pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Update_Task_Assignments'
                ,x_msg         => 'i='||i||'inven_item='||l_inventory_item_id_tbl(i)||
                                                          ' item_cat_id='||l_item_category_id_tbl(i)||
                                                          ' proj_role_id='||l_project_role_id_tbl(i)||
                                                          ' org_id='||l_organization_id_tbl(i)||
                                                          ' fc_res_type='||l_fc_res_type_code_tbl(i)||
                                                          ' exp_type='||l_expenditure_type_tbl(i)
                ,x_log_level   => li_message_level);

                    pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Update_Task_Assignments'
                ,x_msg         => 'i='||i||'exp_cat='||l_expenditure_category_tbl(i)||
                                                          ' event_type='||l_event_type_tbl(i)||
                                                          ' rev_cat_code='||l_revenue_category_code_tbl(i)||
                                                          ' supplier_id='||l_supplier_id_tbl(i)||
                                                          ' spread_curve='||l_spread_curve_id_tbl(i)
                ,x_log_level   => li_message_level);

                    pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Update_Task_Assignments'
                ,x_msg         => 'i='||i||'etc_method_code='||l_etc_method_code_tbl(i)||
                                                          ' mfc_cost_type='||l_mfc_cost_type_id_tbl(i)||
                                                          ' inc_by_res_flag='||l_incurred_by_res_flag_tbl(i)||
                                                          ' inc_by_res_class='||l_incur_by_res_class_code_tbl(i)||
                                                          ' inc_by_role_id='||l_incur_by_role_id_tbl(i)||
                                                          ' unit_of_measure'||l_unit_of_measure_tbl(i)
                ,x_log_level   => li_message_level);
                        END IF;
              END LOOP;

                  -- Bug 4059887: Check privilege of update task assignments
                /*  commented and changed as below for Bug 6856934
                  l_edit_task_ok := pa_task_assignment_utils.check_edit_task_ok(
                                         P_PROJECT_ID             => l_project_id
                            ,P_STRUCTURE_VERSION_ID   => l_last_struct_version_id
                                    ,P_CURR_STRUCT_VERSION_ID => l_last_struct_version_id);
                */
                  l_edit_task_ok := PA_PROJECT_STRUCTURE_UTILS.IS_STRUC_VER_LOCKED_BY_USER(
                                                                p_user_id               => FND_GLOBAL.USER_ID,
                                                                p_structure_version_id => l_last_struct_version_id);

                  IF P_DEBUG_MODE = 'Y' THEN
                         pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Update_Task_Assignments'
              ,x_msg         => 'l_edit_task_ok='||l_edit_task_ok
              ,x_log_level   => li_message_level);
                  END IF;

         -- IF 'Y' = l_edit_task_ok THEN  Commented and changed as below for Bug 6856934
         IF  nvl(l_edit_task_ok,'X') <> 'O' THEN

                          l_msg_count1 := FND_MSG_PUB.Count_Msg;
                  pa_fp_planning_transaction_pub.update_planning_transactions (
                    p_context                      => 'TASK_ASSIGNMENT'
                    ,p_calling_context             =>  'PA_PROJECT_ASSIGNMENT'  -- Added for Bug 6856934
                           ,p_struct_elem_version_id       => l_last_struct_version_id
                       ,p_budget_version_id            => l_last_bvid
                       ,p_task_elem_version_id_tbl     => l_update_task_version_id_tbl
                       ,p_resource_assignment_id_tbl   => l_update_task_asgmt_id_tbl
                       ,p_project_assignment_id_tbl    => l_project_assignment_id_tbl
                         -- resource_list_member_id
                           ,p_resource_list_member_id_tbl  => l_resource_list_member_id_tbl
                         -- pass in all resource attributes
                           ,p_resource_class_flag_tbl      => l_resource_class_flag_tbl
                           ,p_resource_class_code_tbl      => l_resource_class_code_tbl
                           ,p_resource_class_id_tbl        => l_resource_class_id_tbl
                           ,p_res_type_code_tbl                    => l_res_type_code_tbl
        --                 ,p_incur_by_res_type_tbl        => l_incur_by_res_type_tbl
                           ,p_person_id_tbl                        => l_person_id_tbl
                           ,p_job_id_tbl                                   => l_job_id_tbl
                           ,p_person_type_code             => l_person_type_code_tbl
                           ,p_named_role_tbl                       => l_named_role_tbl  -- named_role
                           ,p_bom_resource_id_tbl                  => l_bom_resource_id_tbl
                           ,p_non_labor_resource_tbl       => l_non_labor_resource_tbl
                           ,p_inventory_item_id_tbl        => l_inventory_item_id_tbl
                           ,p_item_category_id_tbl                 => l_item_category_id_tbl
--Bug 4170933  ,p_project_role_id_tbl              => l_project_role_id_tbl
                           ,p_organization_id_tbl                  => l_organization_id_tbl
                           ,p_fc_res_type_code_tbl                 => l_fc_res_type_code_tbl
                           ,p_expenditure_type_tbl                 => l_expenditure_type_tbl
                           ,p_expenditure_category_tbl     => l_expenditure_category_tbl
                           ,p_event_type_tbl                       => l_event_type_tbl
                           ,p_revenue_category_code_tbl    => l_revenue_category_code_tbl
                           ,p_supplier_id_tbl                      => l_supplier_id_tbl
                           ,p_spread_curve_id_tbl                  => l_spread_curve_id_tbl
                           ,p_etc_method_code_tbl                  => l_etc_method_code_tbl
                           ,p_mfc_cost_type_id_tbl                 => l_mfc_cost_type_id_tbl
                           ,p_incurred_by_res_flag_tbl     => l_incurred_by_res_flag_tbl
                           ,p_incur_by_res_class_code_tbl  => l_incur_by_res_class_code_tbl
                           ,p_incur_by_role_id_tbl                 => l_incur_by_role_id_tbl
                           ,p_unit_of_measure_tbl                  => l_unit_of_measure_tbl
        --                 ,p_org_id_tbl                                   => l_org_id_tbl
        --                 ,p_rate_based_flag_tbl                  => l_rate_based_flag_tbl
        --                 ,p_rate_expenditure_type_tbl    => l_rate_expenditure_type_tbl
        --                 ,p_rate_func_curr_code_tbl      => l_rate_func_curr_code_tbl
        --                 ,p_rate_incurred_by_org_id_tbl  => l_rate_incurred_by_org_id_tbl
                   ,x_return_status                => l_return_status
                   ,x_msg_data                             => l_msg_data
                       ,x_msg_count                                => l_msg_count);

                          IF P_DEBUG_MODE = 'Y' THEN
                                 pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Update_Task_Assignments'
                       ,x_msg         => 'return status'||l_return_status
                                   ,x_log_level   => li_message_level);
                      END IF;

                          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         l_overall_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                             -- bug 4117269: Remove the error messages added by the above API
                                 l_msg_count2 := FND_MSG_PUB.Count_Msg;
                                 IF P_DEBUG_MODE = 'Y' THEN
                                pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Update_Task_Assignments'
                           ,x_msg         => ' count1='||l_msg_count1||
                                                             ' count2='||l_msg_count2
                                       ,x_log_level   => li_message_level);
                                 END IF;

                                 FOR k IN (l_msg_count1 + 1)..l_msg_count2 LOOP
                                         IF P_DEBUG_MODE = 'Y' THEN
                                        pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Update_Task_Assignments'
                           ,x_msg         => 'Deleting message at index: ' || FND_MSG_PUB.Count_Msg
                                       ,x_log_level   => li_message_level);
                     END IF;
                                         FND_MSG_PUB.delete_msg(p_msg_index => FND_MSG_PUB.Count_Msg);
                 END LOOP;

                                 PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                          ,p_msg_name       => 'PA_NO_UPDATE_ASGN_WITH_ACTUALS' );
                     PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;

                          END IF;

                  ELSE  --  If nvl(l_edit_task_ok,'X') <> 'O'

                          IF p_mode <> 'CREATE' THEN
                                -- Bug 6856934
                                Begin
                                        select ppevs.name into l_structure_ver_name
                                        from pa_proj_elem_ver_structure ppevs
                                        where ppevs.project_id = l_project_id
                                        and ppevs.element_version_id = l_last_struct_version_id;
                                Exception when NO_DATA_FOUND then
                                        null;
                                end;
                                PA_UTILS.Add_Message(
                                        p_app_short_name  => 'PA'
                                       ,p_msg_name        => 'PA_WORKPLAN_LOCKED_NO_UPD'
                                       ,p_token1          => 'TEAM_ROLE'
                                       ,p_value1          => p_named_role
                                       ,p_token2          => 'WP_VERSION_NAME'
                                       ,p_value2          => l_structure_ver_name);
                         l_overall_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                          END IF;

          END IF;  -- IF 'Y' = l_edit_task_ok THEN

                  l_update_count := 0;
                  l_update_task_version_id_tbl.delete();
                  l_update_task_asgmt_id_tbl.delete();
          l_project_assignment_id_tbl.delete();
                  l_resource_list_member_id_tbl.delete();
                  l_resource_class_flag_tbl.delete();
                  l_resource_class_code_tbl.delete();
                  l_resource_class_id_tbl.delete();
                  l_res_type_code_tbl.delete();
                  l_incur_by_res_type_tbl.delete();
                  l_person_id_tbl.delete();
                  l_job_id_tbl.delete();
                  l_person_type_code_tbl.delete();
                  l_named_role_tbl.delete();
                  l_bom_resource_id_tbl.delete();
                  l_non_labor_resource_tbl.delete();
                  l_inventory_item_id_tbl.delete();
                  l_item_category_id_tbl.delete();
                  l_project_role_id_tbl.delete();
                  l_organization_id_tbl.delete();
                  l_fc_res_type_code_tbl.delete();
                  l_expenditure_type_tbl.delete();
                  l_expenditure_category_tbl.delete();
                  l_event_type_tbl.delete();
                  l_revenue_category_code_tbl.delete();
                  l_supplier_id_tbl.delete();
                  l_spread_curve_id_tbl.delete();
                  l_etc_method_code_tbl.delete();
                  l_mfc_cost_type_id_tbl.delete();
                  l_incurred_by_res_flag_tbl.delete();
                  l_incur_by_res_class_code_tbl.delete();
                  l_incur_by_role_id_tbl.delete();
                  l_unit_of_measure_tbl.delete();
                  l_org_id_tbl.delete();
                  l_rate_based_flag_tbl.delete();
                  l_rate_expenditure_type_tbl.delete();
                  l_rate_func_curr_code_tbl.delete();
                  l_rate_incurred_by_org_id_tbl.delete();

      END IF; -- budget_version_id different

          IF j <> l_task_assignment_id_tbl.LAST + 1 THEN
                  IF P_DEBUG_MODE = 'Y' THEN
                 pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PVT.Update_Task__Assignments'
              ,x_msg         => 'j <> l_task_assignment_id_tbl.LAST + 1'
              ,x_log_level   => li_message_level);
                  END IF;

              l_update_count := l_update_count + 1;
                  l_update_task_asgmt_id_tbl.extend(1);
                  l_update_task_version_id_tbl.extend(1);
                  l_update_task_asgmt_id_tbl(l_update_count) := l_task_assignment_id_tbl(j);
                  l_update_task_version_id_tbl(l_update_count) := l_task_version_id_tbl(j);
                  l_last_bvid := l_budget_version_id_tbl(j);
                  l_last_struct_version_id := l_struct_version_id_tbl(j);
          END IF;

        END LOOP;

   END IF;      -- l_task_assignment_id_tbl.COUNT <> 0 THEN

   x_return_status := l_overall_return_status;

  -- Reset the error stack when returning to the calling program
     PA_DEBUG.Reset_err_stack;

  EXCEPTION
    WHEN OTHERS THEN

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ASSIGNMENTS_PVT.Update_Task_Assignments'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     RAISE;  -- This is optional depending on the needs


 END Update_Task_Assignments;



END pa_assignments_pvt;

/

--------------------------------------------------------
--  DDL for Package Body PA_SEARCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SEARCH_PUB" AS
--$Header: PARISPBB.pls 120.4.12010000.2 2010/01/28 14:01:40 amehrotr ship $
--

  PROCEDURE Run_Search(
  p_search_mode              IN  VARCHAR2
, p_assignment_id            IN  pa_project_assignments.assignment_id%TYPE                                   := FND_API.G_MISS_NUM
, p_assignment_number        IN  pa_project_assignments.assignment_number%TYPE                               := FND_API.G_MISS_NUM
, p_resource_source_id       IN  NUMBER                                                                      := FND_API.G_MISS_NUM
, p_resource_name            IN  pa_resources.name%TYPE                                                      := FND_API.G_MISS_CHAR
, p_project_id               IN  pa_projects_all.project_id%TYPE                                             := FND_API.G_MISS_NUM
, p_role_id                  IN  pa_project_role_types.project_role_id%TYPE                                  := FND_API.G_MISS_NUM
, p_role_name                IN  pa_project_role_types.meaning%TYPE                                          := FND_API.G_MISS_CHAR
, p_min_job_level            IN  pa_project_assignments.min_resource_job_level%TYPE                          := FND_API.G_MISS_NUM
, p_max_job_level            IN  pa_project_assignments.max_resource_job_level%TYPE                          := FND_API.G_MISS_NUM
, p_org_hierarchy_version_id IN  per_org_structure_versions.org_structure_version_id%TYPE                    := FND_API.G_MISS_NUM
, p_org_hierarchy_name       IN  per_organization_structures.name%TYPE                                       := FND_API.G_MISS_CHAR
, p_organization_id          IN  hr_organization_units.organization_id%TYPE                                  := FND_API.G_MISS_NUM
, p_organization_name        IN  hr_organization_units.name%TYPE                                             := FND_API.G_MISS_CHAR
, p_employees_only           IN  VARCHAR2                                                                    := FND_API.G_MISS_CHAR
, p_territory_code           IN  fnd_territories_vl.territory_code%TYPE                                      := FND_API.G_MISS_CHAR
, p_territory_short_name     IN  fnd_territories_vl.territory_short_name%TYPE                                := FND_API.G_MISS_CHAR
, p_start_date               IN  DATE         := FND_API.G_MISS_DATE
, p_end_date                 IN  DATE         := FND_API.G_MISS_DATE
, p_competence_id         IN  system.pa_num_tbl_type := NULL
, p_competence_alias      IN  system.pa_varchar2_30_tbl_type := NULL
, p_competence_name       IN  system.pa_varchar2_240_tbl_type := NULL
, p_rating                IN  system.pa_num_tbl_type    := NULL
, p_mandatory             IN  system.pa_varchar2_1_tbl_type := NULL
, p_provisional_availability IN  VARCHAR
, p_region                   IN  VARCHAR      := FND_API.G_MISS_CHAR
, p_city                     IN  VARCHAR      := FND_API.G_MISS_CHAR
--, p_competences              IN  pa_search_glob.Competence_Criteria_Tbl_Type
, p_work_current_loc         IN  VARCHAR
, p_work_all_loc             IN  VARCHAR
, p_travel_domestically      IN  VARCHAR
, p_travel_internationally   IN  VARCHAR
-- , p_ad_hoc_search            IN  VARCHAR      := 'N'
, p_minimum_availability     IN  NUMBER       := FND_API.G_MISS_NUM
, p_restrict_res_comp        IN  VARCHAR      := FND_API.G_MISS_CHAR
, p_exclude_candidates       IN  VARCHAR      := FND_API.G_MISS_CHAR
, p_staffing_priority_code   IN  VARCHAR      := FND_API.G_MISS_CHAR
, p_staffing_priority_name   IN  VARCHAR      := FND_API.G_MISS_CHAR
, p_staffing_owner_person_id IN  NUMBER       := FND_API.G_MISS_NUM
, p_staffing_owner_name      IN  VARCHAR      := FND_API.G_MISS_CHAR
, p_comp_match_weighting     IN  NUMBER       := FND_API.G_MISS_NUM
, p_avail_match_weighting    IN  NUMBER       := FND_API.G_MISS_NUM
, p_job_level_match_weighting IN  NUMBER      := FND_API.G_MISS_NUM
, p_get_search_criteria      IN  VARCHAR2     := FND_API.G_FALSE
, p_validate_only            IN  VARCHAR2     := FND_API.G_FALSE
, p_api_version              IN  NUMBER       := 1.0
, p_init_msg_list            IN  VARCHAR2     := FND_API.G_FALSE
, p_commit                   IN  VARCHAR2     := FND_API.G_FALSE
, p_max_msg_count            IN  NUMBER       := FND_API.G_MISS_NUM
, p_person_type		     IN  VARCHAR2     := FND_API.G_MISS_CHAR
, x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, x_msg_count                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
, x_msg_data                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

  l_index                     NUMBER;
  l_return_status             VARCHAR2(1);
  l_error_msg_data            fnd_new_messages.message_name%TYPE;
  l_error_message_code        fnd_new_messages.message_name%TYPE;
  l_competency_tbl            PA_HR_COMPETENCE_UTILS.Competency_Tbl_Typ;
  l_no_of_competencies        NUMBER;
  l_msg_index_out             NUMBER;
  l_competence_id             per_competences.competence_id%TYPE;
  -- added for Bug fix: 4537865
  l_new_competence_id	      per_competences.competence_id%TYPE;
  -- added for Bug fix: 4537865
  l_competence_alias          per_competences.competence_alias%TYPE;
  l_resource_type_id          NUMBER;
  l_competence_criteria       PA_SEARCH_GLOB.Competence_Criteria_Tbl_Type;
  l_org_structure_type        PA_ORG_HIERARCHY_DENORM.pa_org_use_type%TYPE;
  i                           NUMBER := 1;
  P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

  -- cursor to get the search criteria if a Resource search is performed
  -- directly on a requirement (without entering the search criteria
  -- on the screen).
  --
  CURSOR get_search_criteria IS
  SELECT asgn.min_resource_job_level,
         asgn.max_resource_job_level,
         asgn.start_date,
         asgn.end_date,
         asgn.competence_match_weighting,
         asgn.availability_match_weighting,
         asgn.job_level_match_weighting,
         asgn.search_min_availability,
         asgn.search_country_code,
         asgn.SEARCH_EXP_ORG_STRUCT_VER_ID,
         asgn.SEARCH_EXP_START_ORG_ID
  FROM   pa_project_assignments asgn
  WHERE  asgn.assignment_id = p_assignment_id;

  -- cursor to the the rating level from the rating level id.
  CURSOR get_step_value(l_rating_level_id NUMBER) IS
  SELECT step_value
  FROM   per_rating_levels
  WHERE  rating_level_id = l_rating_level_id;

  BEGIN

  IF (P_DEBUG_MODE ='Y') THEN
  PA_DEBUG.WRITE_LOG(x_Module    => 'pa.plsql.PA_SEARCH_PUB.Run_Search.begin',
                     x_Msg       => 'in PA_SEARCH_PUB.Run_Search',
                     x_Log_Level => 6);
  End if;

  -- Initialize the return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialise the error stack
  PA_DEBUG.init_err_stack('PA_SEARCH_PUB.Run_Search');

  -- Issue API savepoint if the transaction is to be committed
  IF (p_commit = FND_API.G_TRUE) THEN
    SAVEPOINT SEARCH_PUB_RUN_OA_SEARCH;
  END IF;

  -- Initialise message stack if required
  IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- assign the assignment id to the g_search_criteria global pl/sql record
  -- if the assignment id is passed to the API.
  IF p_assignment_id <> FND_API.G_MISS_NUM AND p_assignment_id IS NOT NULL THEN

     PA_SEARCH_GLOB.g_search_criteria.assignment_id := p_assignment_id;

  END IF;

  -- assign the project id to the g_search_criteria global pl/sql record
  -- if the project id is passed to the API.
  IF p_project_id <> FND_API.G_MISS_NUM AND p_project_id IS NOT NULL THEN

     PA_SEARCH_GLOB.g_search_criteria.project_id := p_project_id;

  END IF;

  IF (P_DEBUG_MODE ='Y') THEN
  PA_DEBUG.WRITE_LOG(
           x_Module    => 'pa.plsql.PA_SEARCH_PUB.Run_Search.validation',
           x_Msg       => 'validate input parameters',
           x_Log_Level => 6);
  End If;

  -- if this is a Requirement Search
  -- or if this is a Resource search and p_get_search_criteria is false then
  -- validate the search criteria and assign to globals.
  IF (p_search_mode = 'REQUIREMENT') OR (p_search_mode = 'ADHOC') OR
     (p_search_mode = 'RESOURCE' AND p_get_search_criteria = FND_API.G_FALSE)
  THEN

     -- validate the assignment number if it is passed to the API.
     IF p_assignment_number <> FND_API.G_MISS_NUM AND
        p_assignment_number IS NOT NULL THEN

        PA_ASSIGNMENT_UTILS.Check_Assignment_Number_Or_Id(
             p_assignment_number  => p_assignment_number,
             p_assignment_id      => p_assignment_id,
             p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag,
             x_assignment_id => PA_SEARCH_GLOB.g_search_criteria.assignment_id,
             x_return_status      => l_return_status,
             x_error_message_code => l_error_message_code);

         -- if the assignment number is not valid then
         -- add a message to the error stack.
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           PA_UTILS.Add_Message ('PA', l_error_message_code);
         END IF;

      END IF;

     -- assign the p_employees_only parameter, indicating if the search is for
     -- employees only, to the g_search_criteria global record.
     IF p_employees_only <> FND_API.G_MISS_CHAR THEN

        PA_SEARCH_GLOB.g_search_criteria.employees_only := p_employees_only;

     END IF;

     -- assign the p_restrict_res_comp parameter to the g_search_criteria
     -- global record.  This parameter is used in the Requirement Search
     -- to indicate if the a requirement should not be returned if the resource
     -- does not have one of the requirement's mandatory competences.
     --
     IF p_restrict_res_comp <> FND_API.G_MISS_CHAR THEN

        PA_SEARCH_GLOB.g_search_criteria.restrict_res_comp :=
                       p_restrict_res_comp;

     END IF;

     -- assign the p_exclude_candidates parameter to the g_search_criteria
     -- global record.  This parameter is used in the Requirement Search
     -- to indicate if a requirement should not be returned if the resource
     -- is already a candidate for that requirement.
     --
     IF p_exclude_candidates <> FND_API.G_MISS_CHAR THEN

        PA_SEARCH_GLOB.g_search_criteria.exclude_candidates :=
                       p_exclude_candidates;

     END IF;

     -- Validate input to retrieve ID values

     IF (p_search_mode = 'RESOURCE' OR p_search_mode = 'ADHOC') THEN
       l_org_structure_type := 'EXPENDITURES';
     ELSE
       l_org_structure_type := 'PROJECTS';
     END IF;

     -- Validate the org hierarchy and assign the id to the global record.
     IF (p_org_hierarchy_version_id <> FND_API.G_MISS_NUM AND
         p_org_hierarchy_version_id IS NOT NULL) OR
        (p_org_hierarchy_name <> FND_API.G_MISS_CHAR AND
         p_org_hierarchy_name IS NOT NULL )
     THEN

        PA_HR_ORG_UTILS.Check_OrgHierName_Or_Id(
           p_org_hierarchy_version_id => p_org_hierarchy_version_id,
           p_org_hierarchy_name       => p_org_hierarchy_name,
           p_check_id_flag            => PA_STARTUP.G_Check_ID_Flag,
           x_org_hierarchy_version_id => PA_SEARCH_GLOB.g_search_criteria.org_hierarchy_version_id,
           x_return_status            => l_return_status,
           x_error_msg_code           => l_error_msg_data);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          PA_UTILS.Add_Message ('PA', l_error_msg_data);
        ELSE

          -- check if the org hierarchy is of the correct type
          -- i.e. EXPENDITURES for resource search
          --      PROJECTS for requirement search
          PA_ORG_UTILS.Check_OrgHierarchy_Type(
             p_org_structure_version_id =>
               PA_SEARCH_GLOB.g_search_criteria.org_hierarchy_version_id,
             p_org_structure_type       => l_org_structure_type,
             x_return_status            => l_return_status,
             x_error_message_code       => l_error_msg_data);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            PA_UTILS.Add_Message ('PA', l_error_msg_data);
          END IF;
        END IF;

     END IF;

     -- validate the organization and assign the id to the global record.
     IF (p_organization_id <> FND_API.G_MISS_NUM AND
         p_organization_id IS NOT NULL) OR
        (p_organization_name <> FND_API.G_MISS_CHAR AND
         p_organization_name IS NOT NULL)
     THEN
        PA_HR_ORG_UTILS.Check_OrgName_Or_Id(
           p_organization_id   => p_organization_id,
           p_organization_name => p_organization_name,
           p_check_id_flag     => PA_STARTUP.G_Check_ID_Flag,
           x_organization_id   =>
                             PA_SEARCH_GLOB.g_search_criteria.organization_id,
           x_return_status     => l_return_status,
           x_error_msg_code    => l_error_msg_data);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          PA_UTILS.Add_Message ('PA', l_error_msg_data);
        ELSE
          -- check if the starting org is of the correct type
          -- i.e. EXPENDITURES for resource search
          --      PROJECTS for requirement search
          PA_ORG_UTILS.Check_Org_Type(
             p_organization_id    =>
                            PA_SEARCH_GLOB.g_search_criteria.organization_id,
             p_org_structure_type => l_org_structure_type,
             x_return_status      => l_return_status,
             x_error_message_code => l_error_msg_data);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            PA_UTILS.Add_Message ('PA', l_error_msg_data);
          END IF;
        END IF;

     END IF;

     -- check if the organization is in the organization hierarchy
     IF (p_organization_id <> FND_API.G_MISS_NUM AND
         p_organization_id IS NOT NULL) OR
        (p_organization_name <> FND_API.G_MISS_CHAR AND
         p_organization_name IS NOT NULL)
     THEN

        IF PA_SEARCH_GLOB.g_search_criteria.organization_id IS NOT NULL AND
           PA_SEARCH_GLOB.g_search_criteria.org_hierarchy_version_id IS NOT NULL
        THEN

          PA_ORG_UTILS.Check_Org_In_OrgHierarchy(
             p_organization_id          =>
                     PA_SEARCH_GLOB.g_search_criteria.organization_id,
             p_org_structure_version_id =>
                     PA_SEARCH_GLOB.g_search_criteria.org_hierarchy_version_id,
             p_org_structure_type       => l_org_structure_type,
             x_return_status            => l_return_status,
             x_error_message_code       => l_error_msg_data);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            PA_UTILS.Add_Message ('PA', l_error_msg_data);
          END IF;
       END IF;
     END IF;

     -- validate the staffing priority code and assign it to global record
     IF (p_staffing_priority_code <> FND_API.G_MISS_CHAR AND
         p_staffing_priority_code IS NOT NULL) OR
        (p_staffing_priority_name IS NOT NULL AND
         p_staffing_priority_name <> FND_API.G_MISS_CHAR)
     THEN
       PA_ASSIGNMENT_UTILS.Check_STF_PriorityName_Or_Code(
          p_staffing_priority_code => p_staffing_priority_code,
          p_staffing_priority_name => p_staffing_priority_name,
          p_check_id_flag          => PA_STARTUP.G_Check_ID_Flag,
          x_staffing_priority_code =>
                 PA_SEARCH_GLOB.g_search_criteria.staffing_priority_code,
          x_return_status          => l_return_status,
          x_error_message_code     => l_error_msg_data);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         PA_UTILS.Add_Message ('PA', l_error_msg_data);
       END IF;
     END IF;

     -- validate the staffing owner and assign it to global record
     IF (p_staffing_owner_person_id <> FND_API.G_MISS_NUM AND
         p_staffing_owner_person_id IS NOT NULL) OR
        (p_staffing_owner_name IS NOT NULL AND
         p_staffing_owner_name <> FND_API.G_MISS_CHAR)
     THEN

           PA_RESOURCE_UTILS.Check_ResourceName_Or_Id (
              p_resource_id        => p_staffing_owner_person_id
             ,p_resource_name      => p_staffing_owner_name
             ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
             ,p_date               => sysdate
             ,x_resource_id        => PA_SEARCH_GLOB.g_search_criteria.staffing_owner_person_id
             ,x_resource_type_id   => l_resource_type_id
             ,x_return_status      => l_return_status
             ,x_error_message_code => l_error_message_code);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR  l_resource_type_id <> 101 THEN
         PA_UTILS.Add_Message ('PA', 'PA_INV_STAFF_OWNER');
       END IF;

     END IF;

     -- validate the territory code and assign the territory code
     -- to the global record.
     --
     IF (p_territory_code <> FND_API.G_MISS_CHAR AND
         p_territory_code IS NOT NULL) OR
        (p_territory_short_name <> FND_API.G_MISS_CHAR AND
         p_territory_short_name IS NOT NULL)
     THEN
       PA_LOCATION_UTILS.Check_Country_Name_Or_Code(
          p_country_code       => p_territory_code,
          p_country_name       => p_territory_short_name,
          p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag,
          x_country_code    => PA_SEARCH_GLOB.g_search_criteria.territory_code,
          x_return_status      => l_return_status,
          x_error_message_code => l_error_msg_data);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         PA_UTILS.Add_Message ('PA', l_error_msg_data);
       END IF;
     END IF;

     -- Add region and city values to global search criteria.
     PA_SEARCH_GLOB.g_search_criteria.region := p_region;
     PA_SEARCH_GLOB.g_search_criteria.city := p_city;

     -- Add person type to global search criteria. Bug 6526674
	PA_SEARCH_GLOB.g_search_criteria.person_type := p_person_type;

     -- Add work preferences to global search criteria.
     PA_SEARCH_GLOB.g_search_criteria.work_current_loc := p_work_current_loc;
     PA_SEARCH_GLOB.g_search_criteria.work_all_loc := p_work_all_loc;
     PA_SEARCH_GLOB.g_search_criteria.travel_domestically :=
                    p_travel_domestically;
     PA_SEARCH_GLOB.g_search_criteria.travel_internationally :=
                    p_travel_internationally;

     -- validate match weightings and assign them to global record

     IF (p_comp_match_weighting <> FND_API.G_MISS_NUM AND
         p_comp_match_weighting IS NOT NULL) OR
        (p_avail_match_weighting <> FND_API.G_MISS_NUM AND
         p_avail_match_weighting IS NOT NULL) OR
        (p_job_level_match_weighting <> FND_API.G_MISS_NUM AND
         p_job_level_match_weighting IS NOT NULL)
     THEN

        IF p_comp_match_weighting < 0 OR p_comp_match_weighting > 100 OR
           p_avail_match_weighting < 0 OR p_avail_match_weighting > 100 OR
           p_job_level_match_weighting < 0 OR p_job_level_match_weighting > 100
        THEN

          PA_UTILS.Add_Message(
                   p_app_short_name => 'PA'
                  ,p_msg_name       => 'PA_INVALID_MATCH_WEIGHTING');
        ELSE
          -- assign match weightings to global record.
          PA_SEARCH_GLOB.g_search_criteria.competence_match_weighting :=
                         p_comp_match_weighting;
          PA_SEARCH_GLOB.g_search_criteria.availability_match_weighting :=
                         p_avail_match_weighting;
          PA_SEARCH_GLOB.g_search_criteria.job_level_match_weighting :=
                         p_job_level_match_weighting;
        END IF;
     END IF;


     -- A resource name or id may be passed in only for a requirement
     -- search for the competence match criteria.
     -- Validate the resource and get that resource's competences.
     --
     IF (p_resource_source_id <> FND_API.G_MISS_NUM AND
         p_resource_source_id IS NOT NULL) OR
        (p_resource_name <> FND_API.G_MISS_CHAR AND
         p_resource_name IS NOT NULL)
     THEN

           PA_RESOURCE_UTILS.Check_ResourceName_Or_Id (
              p_resource_id        => p_resource_source_id
             ,p_resource_name      => p_resource_name
             ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
             ,p_date               => p_start_date
             ,x_resource_id        => PA_SEARCH_GLOB.g_search_criteria.resource_source_id
             ,x_resource_type_id   => l_resource_type_id
             ,x_return_status      => l_return_status
             ,x_error_message_code => l_error_message_code);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         PA_UTILS.Add_Message ('PA', l_error_message_code);
       END IF;

     END IF;

     -- validate the role if passed in, and assign the role id to
     -- the global record.
     --
     IF (p_role_id <> FND_API.G_MISS_NUM AND p_role_id IS NOT NULL) OR
        (p_role_name <> FND_API.G_MISS_CHAR AND p_role_name IS NOT NULL)
     THEN

        PA_ROLE_UTILS.Check_Role_Name_Or_Id(
           p_role_id            => p_role_id
          ,p_role_name          => p_role_name
          ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
          ,x_role_id            => PA_SEARCH_GLOB.g_search_criteria.role_id
          ,x_return_status      => l_return_status
          ,x_error_message_code => l_error_message_code );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         PA_UTILS.Add_Message ('PA', l_error_message_code);
       END IF;

     END IF;

  --
  -- Check that max job level is >= min job level
  --
     IF (p_min_job_level <> FND_API.G_MISS_NUM AND
         p_min_job_level IS NOT NULL) OR
        (p_max_job_level <> FND_API.G_MISS_NUM AND
         p_max_job_level IS NOT NULL)
     THEN
        IF p_min_job_level > p_max_job_level THEN
          PA_UTILS.Add_Message(
                   p_app_short_name => 'PA'
                  ,p_msg_name       => 'PA_MIN_JL_GREATER_THAN_MAX');
        ELSE

          -- assign job levels to global record.
          PA_SEARCH_GLOB.g_search_criteria.min_job_level := p_min_job_level;
          PA_SEARCH_GLOB.g_search_criteria.max_job_level := p_max_job_level;
        END IF;
     END IF;

     --Check that min availability is between 0 and 100
     IF p_minimum_availability <> FND_API.G_MISS_NUM AND
        p_minimum_availability IS NOT NULL
     THEN
        IF p_minimum_availability < 0 OR p_minimum_availability > 100 THEN
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_MIN_AVAIL_INVALID');
        END IF;

        -- assign the min availability to the global record.
        PA_SEARCH_GLOB.g_search_criteria.min_availability :=
                       p_minimum_availability;

     END IF;

     -- Assign Provisional Availability to the global record.
     PA_SEARCH_GLOB.g_search_criteria.provisional_availability :=
                    p_provisional_availability;

     -- validate that start date <= end date.
     -- assign p_start_date to the global record before the validation
     -- in this case because for a requirement search ONLY the start
     -- date is required.  So we only need to do the validation
     -- if the end date is passed in as well.  The end date will only
     -- be assigned to the global record if it is passed in and valid.

     IF p_start_date <> FND_API.G_MISS_DATE AND p_start_date IS NOT NULL THEN
       PA_SEARCH_GLOB.g_search_criteria.start_date := p_start_date;
     END IF;

     IF (p_start_date <> FND_API.G_MISS_DATE AND p_start_date IS NOT NULL) AND
        (p_end_date <> FND_API.G_MISS_DATE AND p_end_date IS NOT NULL)
     THEN

        IF  p_start_date > p_end_date THEN
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_INVALID_START_DATE');

        ELSE

           -- if end date >= start date then assignment end date
           -- to the global record.
           --
           PA_SEARCH_GLOB.g_search_criteria.end_date := p_end_date;

        END IF;

        IF (p_search_mode = 'RESOURCE') AND
           Trunc(p_start_date) < Trunc(SYSDATE) AND
           Trunc(p_end_date) < Trunc(SYSDATE) THEN
           PA_UTILS.Add_Message(p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_REQ_DATES_IN_PAST');
        END IF;

     ELSIF (p_start_date <> FND_API.G_MISS_DATE AND
            p_start_date IS NOT NULL) AND
           (p_end_date = FND_API.G_MISS_DATE OR p_end_date IS NULL) THEN
       PA_SEARCH_GLOB.g_search_criteria.end_date := ADD_MONTHS(p_start_date,6);
     END IF;

     -- validate competence
     -- competence name/alias/id will only be passed in if this is a
     -- Resource Search.
     --
     -- IF (p_competence_id IS NOT NULL OR p_competence_alias IS NOT NULL OR
     --     p_competence_name IS NOT NULL) THEN
     --
     IF p_competence_id.COUNT > 0 THEN
     FOR i in p_competence_id.first .. p_competence_id.last LOOP

        -- find the number of competences already in the global comp table.
        l_index := PA_SEARCH_GLOB.g_competence_criteria.COUNT;

        IF p_competence_id(i) <> -1 THEN
            IF p_competence_id(i) = -999 THEN
               l_competence_id := NULL;
            ELSE
               l_competence_id := p_competence_id(i);
            END IF;

            IF p_competence_alias(i) = ' ' THEN
               l_competence_alias := NULL;
            ELSE
               l_competence_alias := p_competence_alias(i);
            END IF;

           PA_HR_COMPETENCE_UTILS.Check_CompName_Or_Id (
              p_competence_id    => l_competence_id, --p_competence_id(i),
              p_competence_alias => l_competence_alias, --p_competence_alias(i);
              p_competence_name  => p_competence_name(i),
              p_check_id_flag    => PA_STARTUP.G_Check_ID_Flag,
            --x_competence_id    => l_competence_id,		* Commented for Bug: 4537865
              x_competence_id	 => l_new_competence_id,	-- added for Bug fix: 4537865
              x_return_status    => l_return_status,
              x_error_msg_code   => l_error_msg_data);

              -- added for Bug fix: 4537865
		 IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		 l_competence_id := l_new_competence_id;
		 END IF;
	      -- added for Bug fix: 4537865

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              PA_UTILS.Add_Message ('PA', l_error_msg_data);
           ELSE

              -- insert the competence into the global table at l_index.
              PA_SEARCH_GLOB.g_competence_criteria(l_index).competence_id :=
                             l_competence_id;
           END IF;
        ELSE
          -- insert the competence category into the global table at l_index.
          PA_SEARCH_GLOB.g_competence_criteria(l_index).competence_id :=
                             p_competence_id(i);
        END IF;

        PA_SEARCH_GLOB.g_competence_criteria(l_index).rating_level :=
                       p_rating(i);
        PA_SEARCH_GLOB.g_competence_criteria(l_index).mandatory_flag :=
                       p_mandatory(i);
        PA_SEARCH_GLOB.g_competence_criteria(l_index).competence_name :=
                       p_competence_name(i);

    END LOOP;
    END IF;
  --
  -- END IF;
  -- IF p_search_mode <> REQUIREMENT OR RESOURCE
  -- resource search being execute from page OTHER than the resource
  -- search criteria page
  -- so we need to get the search criteria
  ELSIF p_get_search_criteria = FND_API.G_TRUE THEN

     IF (P_DEBUG_MODE ='Y') THEN
     PA_DEBUG.WRITE_LOG(
        x_Module => 'pa.plsql.PA_SEARCH_PUB.Run_Search.get_search_criteria'
       ,x_Msg => 'resource search being execute from page OTHER than the resource search criteria page, get search criteria'
       ,x_Log_Level => 6);
     End If;

        PA_SEARCH_GLOB.g_search_criteria.work_current_loc := 'N';
        PA_SEARCH_GLOB.g_search_criteria.work_all_loc := 'N';
        PA_SEARCH_GLOB.g_search_criteria.travel_domestically := 'N';
        PA_SEARCH_GLOB.g_search_criteria.travel_internationally := 'N';

     -- Assign Provisional Availability to the global record.
     PA_SEARCH_GLOB.g_search_criteria.provisional_availability := 'N';

   -- get the search criteria for the assignment.
     OPEN get_search_criteria;

     FETCH get_search_criteria INTO
           PA_SEARCH_GLOB.g_search_criteria.min_job_level,
           PA_SEARCH_GLOB.g_search_criteria.max_job_level,
           PA_SEARCH_GLOB.g_search_criteria.start_date,
           PA_SEARCH_GLOB.g_search_criteria.end_date,
           PA_SEARCH_GLOB.g_search_criteria.competence_match_weighting,
           PA_SEARCH_GLOB.g_search_criteria.availability_match_weighting,
           PA_SEARCH_GLOB.g_search_criteria.job_level_match_weighting,
           PA_SEARCH_GLOB.g_search_criteria.min_availability,
           PA_SEARCH_GLOB.g_search_criteria.territory_code,
           PA_SEARCH_GLOB.g_search_criteria.org_hierarchy_version_id,
           PA_SEARCH_GLOB.g_search_criteria.organization_id;

        IF Trunc(PA_SEARCH_GLOB.g_search_criteria.start_date) < Trunc(SYSDATE) AND
           Trunc(PA_SEARCH_GLOB.g_search_criteria.end_date) < Trunc(SYSDATE)
        THEN
           PA_UTILS.Add_Message(p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_REQ_DATES_IN_PAST');
        END IF;

      IF get_search_criteria%NOTFOUND THEN

        RAISE NO_DATA_FOUND;

      END IF;

      CLOSE get_search_criteria;

     -- get the competencies for the requirement
     PA_HR_COMPETENCE_UTILS.get_competencies(
           p_object_name => 'OPEN_ASSIGNMENT',
           p_object_id => PA_SEARCH_GLOB.g_search_criteria.assignment_id,
           x_competency_tbl => l_competency_tbl,
           x_no_of_competencies => l_no_of_competencies,
           x_error_message_code => l_error_msg_data,
           x_return_status => l_return_status);

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        PA_UTILS.Add_Message ('PA', l_error_msg_data);

     ELSIF l_competency_tbl.COUNT > 0 THEN

        -- store the competences in the global comp table.
        FOR i IN l_competency_tbl.FIRST..l_competency_tbl.LAST LOOP

           PA_SEARCH_GLOB.g_competence_criteria(i).competence_id :=
                          l_competency_tbl(i).competence_id;
           PA_SEARCH_GLOB.g_competence_criteria(i).competence_alias :=
                          l_competency_tbl(i).competence_alias;
           PA_SEARCH_GLOB.g_competence_criteria(i).mandatory_flag :=
                          l_competency_tbl(i).mandatory;

           -- get the rating level given the id if id is not null
           -- and store in global comp table.
           IF l_competency_tbl(i).rating_level_id IS NOT NULL THEN
             OPEN get_step_value(l_competency_tbl(i).rating_level_id);
             FETCH get_step_value INTO
                   PA_SEARCH_GLOB.g_competence_criteria(i).rating_level;
             CLOSE get_step_value;
	   ELSE
             PA_SEARCH_GLOB.g_competence_criteria(i).rating_level := NULL;
           END IF;

        END LOOP;

     END IF;

  END IF;

  -- If there are no errors and
  -- 1) p_validate_only = 'F', OR
  -- 2) the search criteria has not been passed to the API --
  -- we got the criteria in the API, then call the private API.

  IF FND_MSG_PUB.Count_Msg = 0 AND
    (p_validate_only = FND_API.G_FALSE OR
     p_get_search_criteria = FND_API.G_TRUE)
  THEN

    -- DEBUG
    IF (p_search_mode = 'RESOURCE' OR p_search_mode = 'ADHOC') AND
       p_get_search_criteria = FND_API.G_FALSE
    THEN
       IF (P_DEBUG_MODE ='Y') THEN
        PA_DEBUG.WRITE_LOG(
           x_Module => 'pa.plsql.PA_SEARCH_PUB.Run_Search.parameters',
           x_Msg    => 'calling pvt',
           x_Log_Level => 6);
        PA_DEBUG.WRITE_LOG(
           x_Module => 'pa.plsql.PA_SEARCH_PUB.Run_Search.parameter',
           x_Msg    => 'p_search_mode=' || p_search_mode,
           x_Log_Level => 6);
        PA_DEBUG.WRITE_LOG(
           x_Module => 'pa.plsql.PA_SEARCH_PUB.Run_Search.parameter',
           x_Msg    => 'assignment_id=' || PA_SEARCH_GLOB.g_search_criteria.assignment_id,
           x_Log_Level => 6);
        PA_DEBUG.WRITE_LOG(
           x_Module => 'pa.plsql.PA_SEARCH_PUB.Run_Search.parameter',
           x_Msg    => 'resource_source_id' || PA_SEARCH_GLOB.g_search_criteria.resource_source_id,
           x_Log_Level => 6);
        PA_DEBUG.WRITE_LOG(
           x_Module => 'pa.plsql.PA_SEARCH_PUB.Run_Search.parameter',
           x_Msg => 'project_id=' || PA_SEARCH_GLOB.g_search_criteria.project_id,
           x_Log_Level => 6);
        PA_DEBUG.WRITE_LOG(
           x_Module => 'pa.plsql.PA_SEARCH_PUB.Run_Search.parameter',
           x_Msg => 'min_job_level=' || PA_SEARCH_GLOB.g_search_criteria.min_job_level,
           x_Log_Level => 6);
        PA_DEBUG.WRITE_LOG(
           x_Module => 'pa.plsql.PA_SEARCH_PUB.Run_Search.parameter',
           x_Msg => 'max_job_level=' || PA_SEARCH_GLOB.g_search_criteria.max_job_level,
           x_Log_Level => 6);
        PA_DEBUG.WRITE_LOG(
           x_Module => 'pa.plsql.PA_SEARCH_PUB.Run_Search.parameter',
           x_Msg => 'org_hierarchy_version_id=' || PA_SEARCH_GLOB.g_search_criteria.org_hierarchy_version_id,
           x_Log_Level => 6);
        PA_DEBUG.WRITE_LOG(
           x_Module => 'pa.plsql.PA_SEARCH_PUB.Run_Search.parameter',
           x_Msg => 'organization_id=' || PA_SEARCH_GLOB.g_search_criteria.organization_id,
           x_Log_Level => 6);
        PA_DEBUG.WRITE_LOG(
           x_Module => 'pa.plsql.PA_SEARCH_PUB.Run_Search.parameter',
           x_Msg => 'territory_code=' || PA_SEARCH_GLOB.g_search_criteria.territory_code,
           x_Log_Level => 6);
        PA_DEBUG.WRITE_LOG(
           x_Module => 'pa.plsql.PA_SEARCH_PUB.Run_Search.parameter',
           x_Msg => 'start_date=' || PA_SEARCH_GLOB.g_search_criteria.start_date,
           x_Log_Level => 6);
        PA_DEBUG.WRITE_LOG(
           x_Module => 'pa.plsql.PA_SEARCH_PUB.Run_Search.parameter',
           x_Msg => 'end_date=' || PA_SEARCH_GLOB.g_search_criteria.end_date,
           x_Log_Level => 6);
        PA_DEBUG.WRITE_LOG(
           x_Module => 'pa.plsql.PA_SEARCH_PUB.Run_Search.parameter',
           x_Msg => 'min_availability=' || PA_SEARCH_GLOB.g_search_criteria.min_availability,
           x_Log_Level => 6);
       End if;

    END IF;

     -- Call Private API

    IF (P_DEBUG_MODE ='Y') THEN
    PA_DEBUG.WRITE_LOG(x_Module => 'pa.plsql.PA_SEARCH_PUB.Run_Search.call_pvt',x_Msg => 'calling PA_SEARCH_PVT.Run_Search', x_Log_Level => 6);
    End If;

    PA_SEARCH_PVT.Run_Search(
       p_search_mode         => p_search_mode
     , p_search_criteria     => PA_SEARCH_GLOB.g_search_criteria
     , p_competence_criteria => PA_SEARCH_GLOB.g_competence_criteria
     , p_commit              => p_commit
     , p_validate_only       => p_validate_only
     , x_return_status       => l_return_status
     );

     -- clear the globals
     PA_SEARCH_GLOB.g_search_criteria := NULL;
     PA_SEARCH_GLOB.g_competence_criteria.DELETE;

     -- Reset the error stack when returning to the calling environment
     PA_DEBUG.Reset_Err_Stack;

  END IF;

  --
  -- IF the number of messages is 1 then fetch the message code
  -- from the stack and return its text
  --

  x_msg_count :=  FND_MSG_PUB.Count_Msg;

  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );

  END IF;

  --if there are errors in the stack then set x_return_status.
  IF FND_MSG_PUB.Count_Msg <> 0 THEN

     x_return_status := FND_API.G_RET_STS_ERROR;

     -- clear the globals
     PA_SEARCH_GLOB.g_search_criteria := NULL;
     PA_SEARCH_GLOB.g_competence_criteria.DELETE;

  END IF;

  EXCEPTION
    WHEN OTHERS THEN

       -- clear the globals
       PA_SEARCH_GLOB.g_search_criteria := NULL;
       PA_SEARCH_GLOB.g_competence_criteria.DELETE;

      IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO SEARCH_PUB_RUN_OA_SEARCH;
      END IF;
      FND_MSG_PUB.add_exc_msg (	p_pkg_name => 'PA_SEARCH_PUB.Run_Search'
                              , p_procedure_name => PA_DEBUG.G_Err_Stack);
      x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE;

  END Run_Search;

END PA_SEARCH_PUB;

/

--------------------------------------------------------
--  DDL for Package PA_SEARCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SEARCH_PUB" AUTHID CURRENT_USER AS
--$Header: PARISPBS.pls 120.3 2007/10/29 12:14:15 anuragar ship $
--

  PROCEDURE Run_Search(
    p_search_mode           IN  VARCHAR2
   , p_assignment_id        IN  pa_project_assignments.assignment_id%TYPE                                   := FND_API.G_MISS_NUM
   , p_assignment_number    IN  pa_project_assignments.assignment_number%TYPE                               := FND_API.G_MISS_NUM
   , p_resource_source_id   IN  NUMBER                                                                      := FND_API.G_MISS_NUM
   , p_resource_name        IN  pa_resources.name%TYPE                                                      := FND_API.G_MISS_CHAR
   , p_project_id           IN  pa_projects_all.project_id%TYPE                                             := FND_API.G_MISS_NUM
   , p_role_id              IN  pa_project_role_types.project_role_id%TYPE                                  := FND_API.G_MISS_NUM
   , p_role_name            IN  pa_project_role_types.meaning%TYPE                                          := FND_API.G_MISS_CHAR
   , p_min_job_level        IN  pa_project_assignments.min_resource_job_level%TYPE                          := FND_API.G_MISS_NUM
   , p_max_job_level        IN  pa_project_assignments.max_resource_job_level%TYPE                          := FND_API.G_MISS_NUM
   , p_org_hierarchy_version_id IN  per_org_structure_versions.org_structure_version_id%TYPE                    := FND_API.G_MISS_NUM
   , p_org_hierarchy_name   IN  per_organization_structures.name%TYPE                                       := FND_API.G_MISS_CHAR
   , p_organization_id      IN  hr_organization_units.organization_id%TYPE                                  := FND_API.G_MISS_NUM
   , p_organization_name    IN  hr_organization_units.name%TYPE                                             := FND_API.G_MISS_CHAR
   , p_employees_only       IN  VARCHAR2          := FND_API.G_MISS_CHAR
   , p_territory_code       IN  fnd_territories_vl.territory_code%TYPE                                      := FND_API.G_MISS_CHAR
   , p_territory_short_name IN  fnd_territories_vl.territory_short_name%TYPE                                := FND_API.G_MISS_CHAR
   , p_start_date           IN  DATE              := FND_API.G_MISS_DATE
   , p_end_date             IN  DATE              := FND_API.G_MISS_DATE
, p_competence_id         IN  system.pa_num_tbl_type := NULL
, p_competence_alias      IN  system.pa_varchar2_30_tbl_type := NULL
, p_competence_name       IN  system.pa_varchar2_240_tbl_type := NULL
, p_rating                IN  system.pa_num_tbl_type    := NULL
, p_mandatory             IN  system.pa_varchar2_1_tbl_type := NULL
   , p_provisional_availability IN  VARCHAR	 DEFAULT 'N'
   , p_region		        IN  VARCHAR	 := FND_API.G_MISS_CHAR
   , p_city		        IN  VARCHAR	 := FND_API.G_MISS_CHAR
--   , p_competences		IN  pa_search_glob.Competence_Criteria_Tbl_Type
   , p_work_current_loc	        IN  VARCHAR	 DEFAULT 'N'
   , p_work_all_loc		IN  VARCHAR	 DEFAULT 'N'
   , p_travel_domestically	IN  VARCHAR	 DEFAULT 'N'
   , p_travel_internationally   IN  VARCHAR	 DEFAULT 'N'
-- , p_ad_hoc_search	        IN  VARCHAR	 DEFAULT 'N'
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
   , p_person_type		IN  VARCHAR2     := FND_API.G_MISS_CHAR -- Added for Bug 6526674
   , x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   , x_msg_count                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   , x_msg_data                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   );

END PA_SEARCH_PUB;

/

--------------------------------------------------------
--  DDL for Package PA_SEARCH_GLOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SEARCH_GLOB" AUTHID CURRENT_USER AS
--$Header: PARIGLBS.pls 120.3 2007/10/29 12:12:50 anuragar ship $
--


  G_ERROR_EXISTS    VARCHAR2(1) := FND_API.G_FALSE;

  TYPE resource_weekly_avail_rec_type IS
    RECORD ( resource_id                         NUMBER DEFAULT FND_API.G_MISS_NUM
           , week_start_date                     DATE DEFAULT FND_API.G_MISS_DATE
           , week_end_date                       DATE DEFAULT FND_API.G_MISS_DATE
           , number_of_hours                     NUMBER DEFAULT FND_API.G_MISS_NUM
           , number_of_days                      NUMBER DEFAULT FND_API.G_MISS_NUM
           , avg_num_of_hours                    NUMBER DEFAULT FND_API.G_MISS_NUM
          );

  TYPE resource_weekly_avail_tbl_type IS TABLE OF resource_weekly_avail_rec_type
     INDEX BY BINARY_INTEGER;


  TYPE asgn_weekly_schedule_rec_type IS
    RECORD ( assignment_id                       NUMBER DEFAULT FND_API.G_MISS_NUM
           , week_start_date                     DATE DEFAULT FND_API.G_MISS_DATE
           , week_end_date                       DATE DEFAULT FND_API.G_MISS_DATE
           , number_of_hours                     NUMBER DEFAULT FND_API.G_MISS_NUM
           , number_of_days                      NUMBER DEFAULT FND_API.G_MISS_NUM
           , avg_num_of_hours                    NUMBER DEFAULT FND_API.G_MISS_NUM
          );

  TYPE asgn_weekly_schedule_tbl_type IS TABLE OF asgn_weekly_schedule_rec_type
     INDEX BY BINARY_INTEGER;

  TYPE Search_Criteria_Rec_Type IS
    RECORD ( assignment_id		        NUMBER DEFAULT NULL
           , resource_source_id                 NUMBER DEFAULT NULL
           , project_id                         NUMBER DEFAULT NULL
           , role_id                            NUMBER DEFAULT NULL
           , min_job_level			NUMBER DEFAULT NULL
           , max_job_level			NUMBER DEFAULT NULL
           , org_hierarchy_version_id 	        NUMBER DEFAULT NULL
           , organization_id			NUMBER DEFAULT NULL
           , employees_only			VARCHAR2(1) DEFAULT NULL
           , territory_code  fnd_territories_vl.territory_code%TYPE DEFAULT NULL
           , region                             VARCHAR2(240) DEFAULT NULL
           , city                               VARCHAR2(80) DEFAULT NULL
           , start_date				DATE DEFAULT NULL
           , end_date				DATE DEFAULT NULL
           , restrict_res_comp                  VARCHAR2(1) DEFAULT 'Y'
           , exclude_candidates                 VARCHAR2(1) DEFAULT 'Y'
           , staffing_priority_code             VARCHAR2(30) DEFAULT NULL
           , staffing_owner_person_id           NUMBER DEFAULT NULL
           , min_availability                   NUMBER DEFAULT 100
           , provisional_availability           VARCHAR2(1) DEFAULT 'N'
           , competence_match_weighting         NUMBER DEFAULT NULL
           , availability_match_weighting       NUMBER DEFAULT NULL
           , job_level_match_weighting          NUMBER DEFAULT NULL
	   , work_current_loc                   VARCHAR2(1) DEFAULT NULL
	   , work_all_loc                       VARCHAR2(1) DEFAULT NULL
	   , travel_domestically                VARCHAR2(1) DEFAULT NULL
	   , travel_internationally             VARCHAR2(1) DEFAULT NULL
	   , person_type			VARCHAR2(80) DEFAULT NULL
           );


  TYPE Competence_Criteria_Rec_Type IS
    RECORD ( competence_id	NUMBER DEFAULT FND_API.G_MISS_NUM
            ,competence_name    per_competences.name%TYPE DEFAULT FND_API.G_MISS_CHAR
           , competence_alias	per_competences.competence_alias%TYPE DEFAULT FND_API.G_MISS_CHAR
           , rating_level	NUMBER DEFAULT FND_API.G_MISS_NUM
           , mandatory_flag	VARCHAR2(1) DEFAULT FND_API.G_MISS_CHAR
           );

  TYPE Competence_Criteria_Tbl_Type IS TABLE OF Competence_Criteria_Rec_Type INDEX BY BINARY_INTEGER;

  G_FIRST        VARCHAR2(1) := 'F';
  G_LAST         VARCHAR2(1) := 'L';
  G_OTHER        VARCHAR2(1) := 'O';

  g_search_criteria                 Search_Criteria_Rec_Type;
  g_competence_criteria             Competence_Criteria_Tbl_Type;

  TYPE Competence_Id_Array IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  TYPE Competence_Name_Array IS TABLE OF per_competences.name%TYPE INDEX BY BINARY_INTEGER;

  TYPE Competence_Alias_Array IS TABLE OF per_competences.competence_alias%TYPE INDEX BY BINARY_INTEGER;

  TYPE Competence_Rating_Array IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  TYPE Competence_Mandatory_Array IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

  PROCEDURE Check_Competence_Match(p_search_mode               IN  VARCHAR2,
                                   p_person_id                 IN  per_all_people_f.person_id%TYPE,
                                   p_requirement_id            IN  pa_project_assignments.assignment_id%TYPE,
--                                   p_resource_competences      IN  PA_SEARCH_GLOB.Competence_Criteria_Tbl_Type,
--                                   p_requirement_competences   IN  PA_SEARCH_GLOB.Competence_Criteria_Tbl_Type,
                                   x_mandatory_match           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                   x_mandatory_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                   x_optional_match            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                   x_optional_count            OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

  FUNCTION Check_Availability ( p_resource_id     IN NUMBER,
                                p_assignment_id   IN NUMBER,
                                p_project_id      IN NUMBER
	                      ) RETURN NUMBER;

  FUNCTION get_min_prof_level(l_competence_id IN NUMBER)
     RETURN NUMBER;

END PA_SEARCH_GLOB;

/

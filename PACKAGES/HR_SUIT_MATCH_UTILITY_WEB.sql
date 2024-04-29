--------------------------------------------------------
--  DDL for Package HR_SUIT_MATCH_UTILITY_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SUIT_MATCH_UTILITY_WEB" AUTHID CURRENT_USER AS
/* $Header: hrsmutlw.pkh 120.3 2005/12/13 13:42:55 svittal noship $ */


  TYPE g_people_rec IS RECORD(
            person_id  		   per_people_f.person_id%type
           ,employee_number	   per_people_f.employee_number%type
           ,applicant_number   per_people_f.applicant_number%type
           ,name 			   per_people_f.full_name%type
           ,work_phone 	       per_people_f.work_telephone%type
           ,hire_date          per_periods_of_service.date_start%type
           ,location_code      per_people_f.internal_location%type
           ,person_type        varchar2(2000) );
  TYPE g_person_table IS TABLE of g_people_rec
  		INDEX BY BINARY_INTEGER;

  TYPE g_competence_rec IS RECORD(
    competence_element_id per_competence_elements.competence_element_id%TYPE
   ,effective_date_from   per_competence_elements.effective_date_from%TYPE
   ,competence_id 	  per_competences.competence_id%TYPE
   ,competence_name 	  per_competences.name%TYPE
   ,low_rating_level_id   per_competence_elements.proficiency_level_id%TYPE
   ,high_rating_level_id  per_competence_elements.high_proficiency_level_id%TYPE
   ,low_step_value        per_rating_levels.step_value%TYPE
   ,low_step_name         per_rating_levels.name%TYPE
   ,high_step_value 	  per_rating_levels.step_value%TYPE
   ,high_step_name        per_rating_levels.name%TYPE
   ,mandatory 		  per_competence_elements.mandatory%TYPE
   ,checked      	  varchar(1) );
  TYPE g_competence_table IS TABLE of g_competence_rec
  		INDEX BY BINARY_INTEGER;

  TYPE g_rank_rec IS RECORD(
            id  	number
           ,name 	varchar2(2000)
           ,e_count 	number
           ,d_count 	number
           ,match_e_count  number
           ,match_d_count  number
	   ,type           varchar2(2000)
           ,assignment_id  number);
  TYPE g_rank_table IS TABLE of g_rank_rec
  		INDEX BY BINARY_INTEGER;

  TYPE g_org_rec IS RECORD(
            org_id  	hr_organization_units.organization_id%TYPE
           ,name    	hr_organization_units.name%TYPE);
  TYPE g_org_table IS TABLE of g_org_rec
  		INDEX BY BINARY_INTEGER;

  g_suit_match_work_oppor               varchar2(30) :=
                                        'HR_SUIT_MATCH_WORK_OPPOR';
  g_suit_match_openings                 varchar2(30) :=
                                        'HR_SUIT_MATCH_OPENINGS';
  g_suit_match_successions              varchar2(30) :=
                                        'HR_SUIT_MATCH_SUCCESSIONS';
  g_suit_match_deployments              varchar2(30) :=
                                        'HR_SUIT_MATCH_DEPLOYMENTS';
  g_none_type				varchar2(20) := 'N';  --None
  g_organization_type		varchar2(20) := 'O';  --Organization
  g_job_type				varchar2(20) := 'J';  --Job
  g_position_type			varchar2(20) := 'P';  --Position
  g_vacancy_type			varchar2(20) := 'V';  --Vacancy
  g_location_type			varchar2(20) := 'L';  --Location
  g_grade_type				varchar2(20) := 'G';  --Grade
  g_class_type				varchar2(20) := 'C';  --Class
  g_people_type				varchar2(20) := 'X';  --People

  --Find work opportunites for a person
  g_match_work_mode				varchar2(20) := 'SMW';
  --Compare pending job applications for a person
  g_work_vacancies_fast_path	varchar2(20) := 'SMW-FV';
  --Compare current succession options for a person
  g_work_successions_fast_path	varchar2(20) := 'SMW-FS';
  --Compare current assignments for a person
  g_work_deployments_fast_path	varchar2(20) := 'SMW-FD';
  --Classes nominated for the person
  g_work_classes_fast_path 		varchar2(20) := 'SMW-FC';

  --Suitability matching for a work opportunity
  g_match_people_mode			varchar2(20) := 'SMP';
  --Compare people assigned to a role
  g_match_peope_role_mode		varchar2(20) := 'SMP-FR';
  --Compare named successors for a position
  g_match_successors_pos_mode	varchar2(20) := 'SMP-FP';
  --Compare applicants for an opening
  g_match_applicants_van_mode	varchar2(20) := 'SMP-FV';
  --Find people for a work opportunity
  g_select_people_work_mode		varchar2(20) := 'SMP-WO';

  --Person Search module
  g_person_search_mode			varchar2(20) := 'PER';
  --Succession plan module
  g_succession_plan_mode		varchar2(20) := 'SUC';
  g_succ_plan_per_mode		varchar2(20) := 'SUC-PER';
  g_succ_plan_pos_mode		varchar2(20) := 'SUC-POS';

  g_japan_legislation_code      varchar2(5) := 'JP';

-- ---------------------------------------------------------------------------
-- get_system_person_type
-- ---------------------------------------------------------------------------

FUNCTION get_system_person_type(p_person_type_id in number)
RETURN varchar2;
-- ---------------------------------------------------------------------------
-- get_option_header
-- ---------------------------------------------------------------------------
FUNCTION get_option_header(p_mode in varchar2)
RETURN varchar2;

-- ---------------------------------------------------------------------------
-- get_lookup_meaning
-- ---------------------------------------------------------------------------
FUNCTION get_lookup_meaning
  (p_lookup_type  in varchar2
  ,p_lookup_code  in varchar2
  ,p_schema       in varchar2 default 'HR')
RETURN varchar2;

-- ---------------------------------------------------------------------------
-- get_max_step_value
-- ---------------------------------------------------------------------------

FUNCTION get_max_step_value
  (p_competence_id in hr_util_misc_web.g_varchar2_tab_type)
RETURN number;

-- ---------------------------------------------------------------------------
-- get_work_detail_name
-- ---------------------------------------------------------------------------
FUNCTION get_work_detail_name
  (p_search_type in varchar2
  ,p_search_id   in varchar2)
RETURN varchar2;

-- ---------------------------------------------------------------------------
-- encode_competence_table
-- ---------------------------------------------------------------------------
PROCEDURE encode_competence_table
  (p_competence_id    		in  hr_util_misc_web.g_varchar2_tab_type
  ,p_competence_name  		in  hr_util_misc_web.g_varchar2_tab_type
  ,p_low_rating_level_id    in  hr_util_misc_web.g_varchar2_tab_type
  ,p_high_rating_level_id   in  hr_util_misc_web.g_varchar2_tab_type
  ,p_mandatory    			in  hr_util_misc_web.g_varchar2_tab_type
  ,p_competence_table 	 out nocopy g_competence_table
  ,p_essential_count        out nocopy number
  ,p_desirable_count        out nocopy number) ;

-- ---------------------------------------------------------------------------
-- decode_competence_table
-- ---------------------------------------------------------------------------
PROCEDURE decode_competence_table
  (p_competence_table 		in g_competence_table
  ,p_competence_id    	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_competence_name  	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_low_rating_level_id    out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_high_rating_level_id   out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_mandatory    		 out nocopy hr_util_misc_web.g_varchar2_tab_type);
-- ---------------------------------------------------------------------------
-- get_person_info
-- ---------------------------------------------------------------------------

PROCEDURE get_person_info
  (p_id		    	in number
  ,p_person_table   out nocopy g_person_table);
-- ---------------------------------------------------------------------------
-- get_people_info
-- ---------------------------------------------------------------------------
PROCEDURE get_people_info
  (p_id		  		in hr_util_misc_web.g_varchar2_tab_type
  ,p_person_table   out nocopy g_person_table
  ,p_count          out nocopy number);

-- ---------------------------------------------------------------------------
-- keyflex_select_where_clause
-- ---------------------------------------------------------------------------
PROCEDURE keyflex_select_where_clause
  (p_business_group_id	in number
  ,p_keyflex_code 		in varchar2
  ,p_filter_clause      in varchar2 default null
  ,p_select_clause      out nocopy varchar2
  ,p_where_clause       out nocopy varchar2);
-- ---------------------------------------------------------------------------
-- get_keyflex_mapped_column_name
-- ---------------------------------------------------------------------------
PROCEDURE get_keyflex_mapped_column_name
  (p_business_group_id	in number
  ,p_keyflex_code 		in varchar2
  ,p_mapped_col_names out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_segment_separator out nocopy varchar2
  ,p_count              out nocopy number);

-- ---------------------------------------------------------------------------
-- get_search_count
-- ---------------------------------------------------------------------------

FUNCTION get_search_count
  (p_mode				    in varchar2
  ,p_person_type_id         in varchar2 default null
  ,p_assignment_type 		in varchar2 default null
  ,p_pre_search_type  		in varchar2
  ,p_pre_search_ids 		in varchar2
  ,p_search_type 			in varchar2
  ,p_filer_match 			in varchar2
  ,p_search_criteria 		in varchar2)
RETURN number;
-- ---------------------------------------------------------------------------
-- get_step_value
-- ---------------------------------------------------------------------------

FUNCTION get_step_value(p_rating_level_id in number)
RETURN per_rating_levels.step_value%TYPE;
-- ---------------------------------------------------------------------------
-- get_competence_name
-- ---------------------------------------------------------------------------

FUNCTION get_competence_name(p_competence_id in number)
RETURN per_competences_tl.name%type;

-- ---------------------------------------------------------------------------
-- get_drived_org_job
-- ---------------------------------------------------------------------------

PROCEDURE get_drived_org_job
  (p_pos_id  in number
  ,p_org_id  out nocopy number
  ,p_job_id  out nocopy number);
-- ---------------------------------------------------------------------------
-- get_item
-- ---------------------------------------------------------------------------

FUNCTION get_item
  (p_ids	in varchar2
  ,p_index in number)
RETURN varchar2;
-- ---------------------------------------------------------------------------
-- build_items
-- ---------------------------------------------------------------------------

FUNCTION build_items
  (p_id	in hr_util_misc_web.g_varchar2_tab_type
  ,p_start_index in number default 1)
RETURN varchar2;

-- ---------------------------------------------------------------------------
-- build_grade_sql
-- ---------------------------------------------------------------------------

FUNCTION build_grade_sql
  (p_search_type 	in varchar2
  ,p_id 			in number)
RETURN varchar2;
-- ---------------------------------------------------------------------------
-- build_sql
-- ---------------------------------------------------------------------------

FUNCTION build_sql
  (p_search_type 	in varchar2
  ,p_ids 			in varchar2)
RETURN varchar2;

-- ---------------------------------------------------------------------------
-- build_sql
-- ---------------------------------------------------------------------------

FUNCTION build_sql
  (p_mode				    in varchar2
  ,p_person_type_id         in varchar2 default null
  ,p_assignment_type 		in varchar2 default null
  ,p_pre_search_type  		in varchar2
  ,p_pre_search_ids 		in varchar2
  ,p_search_type 			in varchar2
  ,p_filer_match 			in varchar2
  ,p_search_criteria 		in varchar2)
RETURN varchar2;

-- ---------------------------------------------------------------------------
-- get_id_name
-- ---------------------------------------------------------------------------

PROCEDURE get_id_name
  (p_dynamic_sql 	in  varchar2
  ,p_id		  	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_name		   out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count        out nocopy number);

-- ---------------------------------------------------------------------------
-- get_job_info
-- ---------------------------------------------------------------------------

PROCEDURE get_job_info
  (p_search_type 	in varchar2
  ,p_id 		   	in varchar2
  ,p_name           out nocopy varchar2
  ,p_org_name       out nocopy varchar2
  ,p_location_code  out nocopy varchar2);


-- ---------------------------------------------------------------------------
-- process_filter
-- ---------------------------------------------------------------------------

FUNCTION  process_filter
  (p_filter_match in varchar2
  ,p_search_criteria in varchar2)
RETURN varchar2;
-- ---------------------------------------------------------------------------
-- get_core_competencies
-- ---------------------------------------------------------------------------

PROCEDURE get_core_competencies
  (p_business_group_id in number default null
  ,p_effective_date in date default sysdate
  ,p_competence_table out nocopy g_competence_table
  ,p_competence_count out nocopy number
  ,p_essential_count out nocopy number
  ,p_desirable_count out nocopy number);
-- ---------------------------------------------------------------------------
-- get_org_competencies
-- ---------------------------------------------------------------------------

PROCEDURE get_org_competencies
  (p_org_id in number
  ,p_effective_date in date default sysdate
  ,p_include_core_competencies in varchar2 default 'N'
  ,p_competence_table out nocopy g_competence_table
  ,p_competence_count out nocopy number
  ,p_essential_count out nocopy number
  ,p_desirable_count out nocopy number);
-- ---------------------------------------------------------------------------
-- get_job_competencies
-- ---------------------------------------------------------------------------
PROCEDURE get_job_competencies
  (p_job_id in number
  ,p_grade_id in number default null
  ,p_effective_date in date default sysdate
  ,p_include_core_competencies in varchar2 default 'N'
  ,p_competence_table out nocopy g_competence_table
  ,p_competence_count out nocopy number
  ,p_essential_count out nocopy number
  ,p_desirable_count out nocopy number);
-- ---------------------------------------------------------------------------
-- get_pos_competencies
-- ---------------------------------------------------------------------------

PROCEDURE get_pos_competencies
  (p_pos_id in number
  ,p_grade_id in number default null
  ,p_effective_date in date default sysdate
  ,p_competence_table out nocopy g_competence_table
  ,p_competence_count out nocopy number
  ,p_essential_count out nocopy number
  ,p_desirable_count out nocopy number);
-- ---------------------------------------------------------------------------
-- get_all_pos_competencies
-- ---------------------------------------------------------------------------
PROCEDURE get_all_pos_competencies
  (p_pos_id in number
  ,p_grade_id in number default null
  ,p_effective_date in date default sysdate
  ,p_include_core_competencies in varchar2 default 'N'
  ,p_competence_table out nocopy g_competence_table
  ,p_competence_count out nocopy number
  ,p_essential_count out nocopy number
  ,p_desirable_count out nocopy number);
-- ---------------------------------------------------------------------------
-- get_vac_competencies
-- ---------------------------------------------------------------------------

PROCEDURE get_vac_competencies
  (p_vacancy_id in number
  ,p_effective_date in date default sysdate
  ,p_include_core_competencies in varchar2 default 'N'
  ,p_competence_table out nocopy g_competence_table
  ,p_competence_count out nocopy number
  ,p_essential_count out nocopy number
  ,p_desirable_count out nocopy number);

-- ---------------------------------------------------------------------------
-- get_person_competencies
-- ---------------------------------------------------------------------------

PROCEDURE get_person_competencies
  (p_person_id in number
  ,p_effective_date in date default sysdate
  ,p_competence_table out nocopy g_competence_table
  ,p_competence_count out nocopy number);

-- ---------------------------------------------------------------------------
-- process_duplicate_competence
-- ---------------------------------------------------------------------------
PROCEDURE process_duplicate_competence
  (p_checked_competence_table in out nocopy g_competence_table
  ,p_against_competence_table in out nocopy g_competence_table);
-- ---------------------------------------------------------------------------
-- process_exclusive_competence
-- ---------------------------------------------------------------------------
PROCEDURE process_exclusive_competence
  (p_checked_competence_table in out nocopy g_competence_table
  ,p_against_competence_table in out nocopy g_competence_table
  ,p_competence_count         in out nocopy number
  ,p_essential_count          in out nocopy number
  ,p_desirable_count          in out nocopy number);
-- ---------------------------------------------------------------------------
-- ranking
-- ---------------------------------------------------------------------------

PROCEDURE ranking
  (p_type					in varchar2
  ,p_id       				in number
  ,p_grade_id 				in number
  ,p_person_id 				in number
  ,p_effective_date 		in date default sysdate
  ,p_essential_count 	 out nocopy number
  ,p_desirable_count 	 out nocopy number
  ,p_match_essential_count out nocopy number
  ,p_match_desirable_count  out nocopy number);

-- ---------------------------------------------------------------------------
-- ranking
-- ---------------------------------------------------------------------------

PROCEDURE ranking
  (p_person_id 				in number
  ,p_effective_date 		in date default sysdate
  ,p_competence_table 		in g_competence_table
  ,p_competence_count		in number
  ,p_match_essential_count  out nocopy number
  ,p_match_desirable_count  out nocopy number);
-- ---------------------------------------------------------------------------
-- sort_rank_list
-- ---------------------------------------------------------------------------

PROCEDURE sort_rank_list
  (p_rank_table 		in out nocopy g_rank_table
  ,p_rank_table_count	in number);
-- ---------------------------------------------------------------------------
-- get_people_by_vacancy
-- ---------------------------------------------------------------------------

PROCEDURE get_people_by_vacancy
  (p_vacancy_id 	in number
  ,p_effective_date	in date default sysdate
  ,p_person_name  out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_id 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_type out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 		 out nocopy number);

-- ---------------------------------------------------------------------------
-- get_vacancies_by_person
-- ---------------------------------------------------------------------------

PROCEDURE get_vacancies_by_person
  (p_person_id 			in number
  ,p_effective_date 	in date default sysdate
  ,p_vacancy_id 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_name 			 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 			 out nocopy number);

-- ---------------------------------------------------------------------------
-- get_succession_by_person
-- ---------------------------------------------------------------------------

PROCEDURE get_succession_by_person
  (p_person_id 		in number
  ,p_effective_date in date default sysdate
  ,p_position_id  out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_name 		 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 		 out nocopy number);

-- ---------------------------------------------------------------------------
-- get_deployment_by_person
-- ---------------------------------------------------------------------------

PROCEDURE get_deployment_by_person
  (p_person_id 		in number
  ,p_effective_date     in date default sysdate
  ,p_assignment_id      out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_position_id  out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_name 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_grade_id 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 	 out nocopy number);

-- ---------------------------------------------------------------------------
-- get_job_deployment_by_person
-- ---------------------------------------------------------------------------

PROCEDURE get_job_deployment_by_person
  (p_person_id 		in number
  ,p_effective_date     in date default sysdate
  ,p_assignment_id      out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_job_id 	        out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_name 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_grade_id 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 	 out nocopy number);

-- ---------------------------------------------------------------------------
-- get_org_deployment_by_person
-- ---------------------------------------------------------------------------

PROCEDURE get_org_deployment_by_person
  (p_person_id 		in number
  ,p_effective_date     in date default sysdate
  ,p_assignment_id      out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_org_id 	        out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_name 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 	 out nocopy number);

-- ---------------------------------------------------------------------------
-- get_vac_deployment_by_person
-- ---------------------------------------------------------------------------

PROCEDURE get_vac_deployment_by_person
  (p_person_id          in number
  ,p_effective_date     in date default sysdate
  ,p_assignment_id      out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_vac_id             out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_name               out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count              out nocopy number);
-- ---------------------------------------------------------------------------
-- get_succesors_by_position
-- ---------------------------------------------------------------------------

PROCEDURE get_succesors_by_position
  (p_pos_id 		in number
  ,p_effective_date in date default sysdate
  ,p_person_id 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_name  out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_type out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 		 out nocopy number);

-- ---------------------------------------------------------------------------
-- get_people_by_role
-- ---------------------------------------------------------------------------

PROCEDURE get_people_by_role
  (p_pre_search_type   in varchar2
  ,p_pre_search_id     in varchar2
  ,p_search_type       in varchar2
  ,p_search_id         in varchar2
  ,p_grade_id          in number default null
  ,p_person_id         out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_name       out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_type       out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count             out nocopy number);

-- ---------------------------------------------------------------------------
-- get_people_by_role_org
-- ---------------------------------------------------------------------------

PROCEDURE get_people_by_role_org
  (p_org_id 		in number
  ,p_effective_date in date default sysdate
  ,p_person_id 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_name  out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_type out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 		 out nocopy number);

-- ---------------------------------------------------------------------------
-- get_people_by_role_job
-- ---------------------------------------------------------------------------

PROCEDURE get_people_by_role_job
  (p_job_id 		in number
  ,p_grade_id 		in number default null
  ,p_effective_date in date default sysdate
  ,p_person_id 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_name  out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_type out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 		 out nocopy number);

-- ---------------------------------------------------------------------------
-- get_people_by_role_pos
-- ---------------------------------------------------------------------------

PROCEDURE get_people_by_role_pos
  (p_pos_id 		in number
  ,p_grade_id 		in number default null
  ,p_effective_date in date default sysdate
  ,p_person_id 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_name  out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_type out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 		 out nocopy number);

-- ---------------------------------------------------------------------------
-- get_people_by_course
-- ---------------------------------------------------------------------------

PROCEDURE get_people_by_course
  (p_activity_version_id 	in number
  ,p_person_id 			 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 				 out nocopy number);

-- ---------------------------------------------------------------------------
-- get_course_by_person
-- ---------------------------------------------------------------------------

PROCEDURE get_course_by_person
  (p_person_id				in number
  ,p_activity_version_id  out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_name 				 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 				 out nocopy number);


-- ---------------------------------------------------------------------------
-- get_rating_scale_by_competence
-- ---------------------------------------------------------------------------

PROCEDURE get_rating_scale_by_competence
  (p_competence_id in number
  ,p_rating_level_id out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_step_value out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_name out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count out nocopy number);



END hr_suit_match_utility_web;

 

/

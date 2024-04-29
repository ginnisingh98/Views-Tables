--------------------------------------------------------
--  DDL for Package Body PA_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SEARCH_PVT" AS
--$Header: PARISPVB.pls 120.12.12010000.8 2010/04/01 06:08:36 amehrotr ship $
--

  PROCEDURE Run_Search (
       p_search_mode          IN  VARCHAR2
     , p_search_criteria      IN  PA_SEARCH_GLOB.Search_Criteria_Rec_Type
     , p_competence_criteria  IN  PA_SEARCH_GLOB.Competence_Criteria_Tbl_Type
     , p_commit               IN  VARCHAR2
     , p_validate_only        IN  VARCHAR2
     , x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ) IS

l_assignment_days                   NUMBER := 0;

--declare local variables
TYPE number_tbl                     IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;

l_competence_id_tbl                 number_tbl;
l_rating_level_tbl                  number_tbl;

TYPE mandatory_flag                 IS TABLE OF pa_competence_criteria_temp.mandatory_flag%TYPE
    INDEX BY BINARY_INTEGER;
l_mandatory_flag_tbl                mandatory_flag;

TYPE competence_name                IS TABLE OF per_competences.name%TYPE
    INDEX BY BINARY_INTEGER;
l_competence_name_tbl               competence_name;

l_mandatory_competence_count        NUMBER:= 0;
l_mandatory_competence_match        NUMBER:= 0;
l_optional_competence_count	    NUMBER:= 0;
l_optional_competence_match         NUMBER:= 0;
l_availability_tbl                  number_tbl;
l_pot_availability_tbl              number_tbl;
l_person_avail                      NUMBER:= 0;
l_person_pot_avail                  NUMBER:= 0;
l_days_in_period_tbl                number_tbl;
l_resource_organization_name        hr_organization_units.name%TYPE;
l_person_type			    fnd_lookup_values.lookup_code%TYPE; -- Bug 6526674
TYPE resource_organization_name_tbl IS TABLE OF hr_organization_units.name%TYPE
   INDEX BY BINARY_INTEGER;

TYPE person_id_tbl                  IS TABLE OF pa_resources_denorm.person_id%TYPE
   INDEX BY BINARY_INTEGER;
l_person_id_tbl                     person_id_tbl;

TYPE resource_id_tbl                IS TABLE OF pa_resources_denorm.resource_id%TYPE
   INDEX BY BINARY_INTEGER;
l_resource_id_tbl                   resource_id_tbl;

TYPE resource_name_tbl              IS TABLE OF pa_resources_denorm.resource_name%TYPE
   INDEX BY BINARY_INTEGER;
l_resource_name_tbl                 resource_name_tbl;

TYPE resource_type_tbl              IS TABLE OF pa_resources_denorm.resource_type%TYPE
   INDEX BY BINARY_INTEGER;
l_resource_type_tbl                 resource_type_tbl;

TYPE resource_organization_id_tbl   IS TABLE OF pa_resources_denorm.resource_organization_id%TYPE
   INDEX BY BINARY_INTEGER;
l_resource_organization_id_tbl      resource_organization_id_tbl;

TYPE country_code_tbl               IS TABLE OF fnd_territories_vl.territory_code%TYPE
   INDEX BY BINARY_INTEGER;
l_country_code_tbl                  country_code_tbl;

TYPE country_tbl                    IS TABLE OF fnd_territories_vl.territory_short_name%TYPE
   INDEX BY BINARY_INTEGER;
l_country_tbl                       country_tbl;

TYPE region_tbl                     IS TABLE OF pa_locations.region%TYPE
   INDEX BY BINARY_INTEGER;
l_region_tbl                        region_tbl;

TYPE city_tbl                       IS TABLE OF pa_locations.city%TYPE
   INDEX BY BINARY_INTEGER;
l_city_tbl                          city_tbl;

TYPE email_tbl                IS TABLE OF per_all_people_f.email_address%TYPE
   INDEX BY BINARY_INTEGER;
l_email_tbl                   email_tbl;

TYPE manager_tbl              IS TABLE OF pa_resources_denorm.manager_name%TYPE
   INDEX BY BINARY_INTEGER;
l_manager_tbl                 manager_tbl;

TYPE resource_job_level_tbl         IS TABLE OF pa_resources_denorm.resource_job_level%TYPE
   INDEX BY BINARY_INTEGER;
l_resource_job_level_tbl            resource_job_level_tbl;

TYPE assignment_id_tbl              IS TABLE OF pa_project_assignments.assignment_id%TYPE
   INDEX BY BINARY_INTEGER;
l_assignment_id_tbl                 assignment_id_tbl;

TYPE assignment_name_tbl            IS TABLE OF pa_project_assignments.assignment_name%TYPE
   INDEX BY BINARY_INTEGER;
l_assignment_name_tbl               assignment_name_tbl;

TYPE assignment_number_tbl          IS TABLE OF pa_project_assignments.assignment_number%TYPE
   INDEX BY BINARY_INTEGER;
l_assignment_number_tbl             assignment_number_tbl;

TYPE assignment_start_date_tbl      IS TABLE OF pa_project_assignments.start_date%TYPE
   INDEX BY BINARY_INTEGER;
l_assignment_start_date_tbl         assignment_start_date_tbl;

TYPE assignment_end_date_tbl        IS TABLE OF pa_project_assignments.end_date%TYPE
   INDEX BY BINARY_INTEGER;
l_assignment_end_date_tbl           assignment_end_date_tbl;

TYPE status_code_tbl                IS TABLE OF pa_project_statuses.project_status_code%TYPE
   INDEX BY BINARY_INTEGER;
l_status_code_tbl                   status_code_tbl;

TYPE project_id_tbl                 IS TABLE OF pa_projects_all.project_id%TYPE
   INDEX BY BINARY_INTEGER;
l_project_id_tbl                    project_id_tbl;

TYPE project_name_tbl               IS TABLE OF pa_projects_all.name%TYPE
   INDEX BY BINARY_INTEGER;
l_project_name_tbl                  project_name_tbl;

TYPE project_number_tbl             IS TABLE OF pa_projects_all.segment1%TYPE
   INDEX BY BINARY_INTEGER;
l_project_number_tbl                project_number_tbl;

--define the variable type
TYPE search_results IS REF CURSOR;
--declare the cursor or table variable
l_search_results  search_results;
--

 --Bug Ref 9212362
CURSOR cur_competence_id_search
    IS
SELECT COUNT(1)
FROM PA_COMPETENCE_CRITERIA_TEMP
WHERE COMPETENCE_ID = -1;

l_comp_id_num NUMBER  := 0;
 --Bug Ref #6144255
CURSOR cur_res_temp_search
    IS
SELECT RESOURCE_ID
  FROM PA_SEARCH_RESULTS_TEMP
 WHERE MANDATORY_COMPETENCE_COUNT = MANDATORY_COMPETENCE_MATCH;

TYPE id_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE cur_avail_type IS REF CURSOR;

cur_avail                  cur_avail_type ;
l_person_id_tbl_tmp        id_tab;
l_pot_availability_tbl_tmp id_tab;
l_availability_tbl_tmp     id_tab;
l_resource_tab             id_tab;
index_1            NUMBER  := 0;
len                NUMBER  := 0;
str_resource_ids   VARCHAR2(32767);
stmt_select        VARCHAR2(2000);
stmt_from          VARCHAR2(2000);
stmt_where         VARCHAR2(2000);
stmt_groupby       VARCHAR2(2000);

--Bug Ref #7457064
 P_DEBUG_MODE      VARCHAR2(1);
 l_res_sql         VARCHAR2(32767);  --Added for bug 4624826
 -- Bug 7457064
 TYPE hash_map_tbl_typ IS TABLE OF NUMBER INDEX BY VARCHAR2(15);
 l_temp                   VARCHAR2(15);
 l_index                  NUMBER;
 l_resource_id_tmp_tbl    PA_PLSQL_DATATYPES.NumTabTyp;
 l_pot_avail_tmp_tbl      PA_PLSQL_DATATYPES.NumTabTyp;
 l_avail_tmp_tbl          PA_PLSQL_DATATYPES.NumTabTyp;
 l_pot_avail_tmp_hash_tbl hash_map_tbl_typ;
 l_avail_tmp_hash_tbl     hash_map_tbl_typ;

BEGIN
--hr_utility.trace_on(NULL, 'RMPA');
--hr_utility.trace('BEGINNING');

    P_DEBUG_MODE := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
    IF (P_DEBUG_MODE ='Y') THEN
	PA_DEBUG.WRITE_LOG(x_Module => 'pa.plsql.PA_SEARCH_PVT.Run_Search.begin',
			   x_Msg => 'in PA_SEARCH_PVT.Run_Search',
                           x_Log_Level => 6);
    END IF;

-- Bug 6526674 changes start here

if p_search_criteria.person_type is null then l_person_type := 'ALL';
else
select decode(lookup_code,'ALL','ALL','EMP','Y','CWK','N') into l_person_type
from fnd_lookup_values
where lookup_type in ('PERSON_TYPE','PA_ANY_ALL') and
meaning = p_search_criteria.person_type and language = userenv('LANG')
and lookup_code in ('EMP','CWK','ALL');
end if;

-- Bug 6526674 changes end here

  -- if this is a Resource Search then open the cursor variable with the
  -- appropriate SELECT statement.  The first part is executed if the
  -- country is part of the search criteria, and the second part
  -- is executed if the country is not part of the criteria.  This will allow
  -- the county part of the index to be used if it is part of the criteria.

  -- CASE 1: country is not null
  -- added the nvl around the country code join below due to the
  -- functionality change in bug 1925620.  This will cause
  -- only the first 2 columns in pa_resources_denorm_n1 to be used
  -- (country_code column in the index cannot be used b/c of the nvl)
--RD.resource_job_level BETWEEN p_search_criteria.min_job_level
                                     --AND p_search_criteria.max_job_level

  IF p_search_mode = 'RESOURCE' or p_search_mode = 'ADHOC' THEN
     -- AND p_search_criteria.territory_code IS NOT NULL THEN

   -- Start of addition for bug 4624826
   l_res_sql :=
   --	'SELECT /*+ INDEX (RD, PA_RESOURCES_DENORM_N6) */  RD.person_id, RD.resource_id, RD.resource_name,  RD.resource_type ' || -- adding hint for 6911907
        'SELECT /*+ LEADING(RD) INDEX(RD PA_RESOURCES_DENORM_N6) USE_NL(RD PDF OHD PPF) */  DISTINCT RD.person_id, RD.resource_id, RD.resource_name,  RD.resource_type ' || -- adding another hint for 6911907, --added distinct bug 9206026
   --	'SELECT   RD.person_id, RD.resource_id, RD.resource_name,  RD.resource_type ' ||
	', RD.resource_organization_id, RD.resource_country_code,RD.resource_country, RD.resource_region '||
        ', RD.resource_city, RD.resource_job_level, RD.manager_name,PPF.email_address ';

    l_res_sql := l_res_sql ||  ' FROM PA_RESOURCES_DENORM RD, PER_ALL_PEOPLE_F ppf,PA_ORG_HIERARCHY_DENORM ohd, PER_DEPLOYMENT_FACTORS pdf ';

    if p_search_criteria.min_job_level IS NOT NULL then
	l_res_sql := l_res_sql || ' WHERE RD.resource_job_level >= :1 ';
    else
	l_res_sql := l_res_sql || ' WHERE :1 IS NULL ';
    end if;

     if p_search_criteria.max_job_level IS NOT NULL then
	 l_res_sql := l_res_sql || ' AND RD.resource_job_level <= :2 ';
     else
	 l_res_sql := l_res_sql ||  ' AND :2 IS NULL ';
     end if;

     if p_search_criteria.territory_code IS NOT NULL then
	 l_res_sql := l_res_sql ||
 	 ' AND (nvl(RD.resource_country_code, :3) =  :4) ';
     else
 	 l_res_sql := l_res_sql ||
 	 ' AND (:3 is null or :4 is null)';
     end if;

     if p_search_criteria.region IS NOT NULL then
 	 l_res_sql := l_res_sql ||
 	 ' AND (nvl(RD.resource_region, :5) =  :6) ';
     else
 	 l_res_sql := l_res_sql ||
 	 ' AND (:5 is null or :6 is null) ';
     end if;

     if p_search_criteria.city IS NOT NULL then
 	  l_res_sql := l_res_sql ||
 	  ' AND (nvl(RD.resource_city, :7) =  :8) ';
     else
 	  l_res_sql := l_res_sql ||
 	 ' AND (:7 is null or :8 is null)';
     end if;

      l_res_sql := l_res_sql ||
		' AND RD.employee_flag = decode(:9,:10,:11,RD.employee_flag)' ||
		' AND RD.resource_organization_id = OHD.child_organization_id' ||
	 	' AND OHD.PARENT_ORGANIZATION_ID = :12'||
		' AND OHD.org_hierarchy_version_id = :13'||
		' AND OHD.pa_org_use_type = :14'||
		' AND RD.SCHEDULABLE_FLAG = :15'||
		' AND RD.resource_effective_start_date <= :16'||
		 ' AND RD.resource_effective_end_date >= :17'||
		 ' AND RD.person_id = ppf.person_id'||
		' AND :18 BETWEEN ppf.effective_start_date AND ppf.effective_end_date'||
		' AND RD.person_id = pdf.person_id(+)';

 	if p_search_criteria.work_current_loc = 'Y' then
 	    l_res_sql := l_res_sql ||
 	                ' AND (PDF.only_current_location = :19'||
 	                ' or PDF.only_current_location = :20) ';
 	elsif p_search_criteria.work_current_loc is null then
 	    l_res_sql := l_res_sql || ' AND (:19 is null or :20 is null) ';
 	elsif p_search_criteria.work_current_loc = 'N' then
 	    l_res_sql := l_res_sql || ' AND :19 = :20';
 	else
            l_res_sql := l_res_sql || ' AND :19 <> :20';
 	end if;

	if p_search_criteria.work_all_loc = 'Y' then
 	    l_res_sql := l_res_sql ||
 	                 ' AND (PDF.work_any_location = :21'||
 	                 ' or PDF.work_any_location = :22)';
 	elsif p_search_criteria.work_all_loc is null then
 	    l_res_sql := l_res_sql || ' AND  (:21 is null or :22 is null)';
 	elsif p_search_criteria.work_all_loc = 'N' then
 	    l_res_sql := l_res_sql || ' AND :21 = :22';
 	else
	    l_res_sql := l_res_sql || ' AND :21 <> :22';
 	end if;

        if p_search_criteria.travel_domestically = 'Y' then
 	    l_res_sql := l_res_sql ||
 	                 ' AND (PDF.travel_required = :23'||
 	                 ' or PDF.travel_required = :24)';
 	elsif p_search_criteria.travel_domestically is null then
 	    l_res_sql := l_res_sql || ' AND (:23 is null or :24 is null) ';
 	elsif p_search_criteria.travel_domestically = 'N' then
 	    l_res_sql := l_res_sql || ' AND :23 = :24';
 	else l_res_sql := l_res_sql || ' AND :23 <> :24';
 	end if;

        if p_search_criteria.travel_internationally = 'Y' then
 	    l_res_sql := l_res_sql ||
 	                 ' AND (PDF.visit_internationally = :25'||
 	                 ' or PDF.visit_internationally = :26)';
 	elsif p_search_criteria.travel_internationally is null then
 	    l_res_sql := l_res_sql || ' AND (:25 is null and :26 is null) ';
 	elsif p_search_criteria.travel_internationally = 'N' then
 	    l_res_sql := l_res_sql || ' AND :25 = :26';
 	else l_res_sql := l_res_sql || ' AND :25 <> :26';
 	end if;

	if nvl(l_person_type,'S') <> 'ALL' then
		if l_person_type = 'N' then
			l_res_sql := l_res_sql ||' AND ppf.current_npw_flag = ' || '''Y''' ;
		else
			l_res_sql := l_res_sql ||' AND ppf.current_employee_flag = ''' || l_person_type || '''';
		end if;
	end if;

	OPEN l_search_results FOR l_res_sql using p_search_criteria.min_job_level,p_search_criteria.max_job_level,
 	         p_search_criteria.territory_code,p_search_criteria.territory_code,
 	         p_search_criteria.region,p_search_criteria.region,
 	         p_search_criteria.city,p_search_criteria.city,
 	         p_search_criteria.employees_only,'Y','Y',
 	         p_search_criteria.organization_id,p_search_criteria.org_hierarchy_version_id,
 	         'EXPENDITURES','Y',
 	         p_search_criteria.start_date,p_search_criteria.start_date,
 	         p_search_criteria.start_date,
 	         p_search_criteria.work_current_loc,p_search_criteria.work_current_loc,
 	         p_search_criteria.work_all_loc,p_search_criteria.work_all_loc,
 	         p_search_criteria.travel_domestically,p_search_criteria.travel_domestically,
 	         p_search_criteria.travel_internationally,p_search_criteria.travel_internationally;

 	 -- End of addition for bug 4624826

 	 /*  Commented for bug 4624826
     OPEN l_search_results FOR
        SELECT   RD.person_id
               , RD.resource_id
               , RD.resource_name
               , RD.resource_type
               , RD.resource_organization_id
               , RD.resource_country_code
               , RD.resource_country
               , RD.resource_region
               , RD.resource_city
               , RD.resource_job_level
               , RD.manager_name
               , PPF.email_address
          FROM PA_RESOURCES_DENORM RD
             , PA_ORG_HIERARCHY_DENORM ohd
             , PER_ALL_PEOPLE_F ppf
             , PER_DEPLOYMENT_FACTORS pdf
         WHERE ((p_search_criteria.min_job_level IS NOT NULL AND
                 RD.resource_job_level >= p_search_criteria.min_job_level)
                 OR
                 p_search_criteria.min_job_level IS NULL)
           AND ((p_search_criteria.max_job_level IS NOT NULL AND
                 RD.resource_job_level <= p_search_criteria.max_job_level)
                 OR
                 p_search_criteria.max_job_level IS NULL)
           AND ((p_search_criteria.territory_code IS NOT NULL AND
                 (nvl(RD.resource_country_code,
                      p_search_criteria.territory_code) =
                      p_search_criteria.territory_code)) OR
                (p_search_criteria.territory_code IS NULL))
           AND ((p_search_criteria.region IS NOT NULL AND
                 (nvl(RD.resource_region, p_search_criteria.region) =
                      p_search_criteria.region)) OR
                (p_search_criteria.region IS NULL))
           AND ((p_search_criteria.city IS NOT NULL AND
                 (nvl(RD.resource_city, p_search_criteria.city) =
                      p_search_criteria.city)) OR
                (p_search_criteria.city IS NULL))
           AND RD.employee_flag =
               decode(p_search_criteria.employees_only,'Y','Y',RD.employee_flag)
           AND RD.resource_organization_id = OHD.child_organization_id
           AND OHD.PARENT_ORGANIZATION_ID = p_search_criteria.organization_id
           AND OHD.org_hierarchy_version_id =
               p_search_criteria.org_hierarchy_version_id
           AND OHD.pa_org_use_type = 'EXPENDITURES'
           AND RD.SCHEDULABLE_FLAG = 'Y'
           AND RD.resource_effective_start_date <= p_search_criteria.start_date
           AND NVL(RD.resource_effective_end_date, p_search_criteria.start_date) >= p_search_criteria.start_date
           AND RD.person_id = ppf.person_id
           AND p_search_criteria.start_date BETWEEN ppf.effective_start_date
                                            AND ppf.effective_end_date
           AND RD.person_id = pdf.person_id(+)
           AND ((p_search_criteria.work_current_loc = 'Y' AND
                 PDF.only_current_location = 'Y') OR
                (nvl(p_search_criteria.work_current_loc, 'N') = 'N'))
           AND ((p_search_criteria.work_all_loc = 'Y' AND
                 PDF.work_any_location = 'Y') OR
                (nvl(p_search_criteria.work_all_loc, 'N') = 'N'))
           AND ((p_search_criteria.travel_domestically = 'Y' AND
                 PDF.travel_required = 'Y') OR
                (nvl(p_search_criteria.travel_domestically, 'N') = 'N'))
           AND ((p_search_criteria.travel_internationally = 'Y' AND
                 PDF.visit_internationally = 'Y') OR
                (nvl(p_search_criteria.travel_internationally, 'N') = 'N')); */

   --if this is a Requirement Search then open the cursor variable with the
   --appropriate SELECT statement.

   -- CASE 1: assignment_id is passed in
   --use this select statement if assignment id is part of the criteria.  Do not need
   --separate select statements based on whether or not country or role is part of the criteria in
   --this case because the assignment_id unique index will be used to access the assignment
   --record.
   ELSIF p_search_mode = 'REQUIREMENT' AND (p_search_criteria.assignment_id IS NOT NULL AND p_search_criteria.assignment_id <> FND_API.G_MISS_NUM) THEN

      OPEN l_search_results FOR
        SELECT   asgn.assignment_id
               , asgn.assignment_name
               , asgn.assignment_number
               , asgn.start_date
               , asgn.end_date
               , asgn.status_code
               , proj.project_id
               , proj.name project_name
               , proj.segment1 project_number
               , loc.country_code
               , ter.territory_short_name
               , loc.region
               , loc.city
          FROM pa_project_assignments asgn
             , pa_org_hierarchy_denorm ohd
             , pa_projects_all proj
             , pa_locations loc
             , fnd_territories_vl ter
             , pa_project_statuses ps
             , pa_advertised_open_req_v aor
         WHERE asgn.assignment_id = p_search_criteria.assignment_id
           AND asgn.min_resource_job_level <=  p_search_criteria.min_job_level
           AND asgn.max_resource_job_level >=  p_search_criteria.min_job_level
           AND asgn.project_role_id = nvl(p_search_criteria.role_id, asgn.project_role_id)
           AND asgn.start_date >= p_search_criteria.start_date
           AND asgn.start_date <= p_search_criteria.end_date
           AND nvl(asgn.staffing_priority_code, -999) = nvl(p_search_criteria.staffing_priority_code, nvl(asgn.staffing_priority_code, -999))
           AND nvl(asgn.staffing_owner_person_id, -999) = nvl(p_search_criteria.staffing_owner_person_id, nvl(asgn.staffing_owner_person_id, -999))
           AND asgn.assignment_type='OPEN_ASSIGNMENT'
	   AND asgn.status_code = ps.project_status_code (+)
           AND (ps.project_system_status_code= 'OPEN_ASGMT' or ps.project_system_status_code is NULL)
	   AND asgn.project_id = proj.project_id
           AND proj.carrying_out_organization_id = OHD.child_organization_id
           AND OHD.parent_organization_id = p_search_criteria.organization_id
           AND OHD.org_hierarchy_version_id = p_search_criteria.org_hierarchy_version_id
           AND OHD.pa_org_use_type = 'PROJECTS'
           AND asgn.location_id = loc.location_id(+)
           AND nvl(loc.country_code, -999) = nvl(p_search_criteria.territory_code, nvl(loc.country_code, -999))
           AND loc.country_code = ter.territory_code(+)
           AND asgn.assignment_id = aor.assignment_id;

   -- CASE 2: no assignment_id,
   --         but role, staffing_priority_code, country are passed in
   -- use this select statement for a requirement search if assignment id is not part
   -- of the criteria and the country, staffing priority and role are part of the criteria.
   ELSIF p_search_mode = 'REQUIREMENT' AND (p_search_criteria.assignment_id IS NULL OR p_search_criteria.assignment_id = FND_API.G_MISS_NUM)
     AND (p_search_criteria.territory_code IS NOT NULL AND p_search_criteria.territory_code <> FND_API.G_MISS_CHAR)
     AND (p_search_criteria.role_id IS NOT NULL AND p_search_criteria.role_id <> FND_API.G_MISS_NUM)
     AND (p_search_criteria.staffing_priority_code IS NOT NULL AND p_search_criteria.staffing_priority_code <> FND_API.G_MISS_CHAR) THEN

   OPEN l_search_results FOR
        SELECT   asgn.assignment_id
               , asgn.assignment_name
               , asgn.assignment_number
               , asgn.start_date
               , asgn.end_date
               , asgn.status_code
               , proj.project_id
               , proj.name project_name
               , proj.segment1 project_number
               , loc.country_code
               , ter.territory_short_name
               , loc.region
               , loc.city
          FROM pa_project_assignments asgn
             , pa_org_hierarchy_denorm ohd
             , pa_projects_all proj
             , pa_locations loc
             , fnd_territories_vl ter
             , pa_project_statuses ps
             , pa_advertised_open_req_v aor
         WHERE asgn.min_resource_job_level <=  p_search_criteria.min_job_level
           AND asgn.max_resource_job_level >=  p_search_criteria.min_job_level
           AND asgn.project_role_id = p_search_criteria.role_id
           AND asgn.start_date >= p_search_criteria.start_date
           AND asgn.start_date <= p_search_criteria.end_date
           AND asgn.staffing_priority_code = p_search_criteria.staffing_priority_code
           AND nvl(asgn.staffing_owner_person_id, -999) = nvl(p_search_criteria.staffing_owner_person_id, nvl(asgn.staffing_owner_person_id, -999))
           AND asgn.assignment_type='OPEN_ASSIGNMENT'
	   AND asgn.status_code = ps.project_status_code (+)
           AND (ps.project_system_status_code= 'OPEN_ASGMT' or ps.project_system_status_code is NULL)
	   AND asgn.project_id = proj.project_id
           AND proj.carrying_out_organization_id = OHD.child_organization_id
           AND OHD.parent_organization_id = p_search_criteria.organization_id
           AND OHD.org_hierarchy_version_id = p_search_criteria.org_hierarchy_version_id
           AND OHD.pa_org_use_type = 'PROJECTS'
           AND asgn.location_id = loc.location_id
           AND loc.country_code = p_search_criteria.territory_code
           AND loc.country_code = ter.territory_code
           AND asgn.assignment_id = aor.assignment_id;

   -- CASE 3: no assignment_id and no country
   --         but role, staffing_priority_code are passed in
   -- use this select statement for a requirement search if assignment id
   -- and country are not part of the criteria, but role and staffing priority
   -- are part of the criteria.
   ELSIF p_search_mode = 'REQUIREMENT' AND (p_search_criteria.assignment_id IS NULL OR p_search_criteria.assignment_id = FND_API.G_MISS_NUM)
    AND (p_search_criteria.territory_code IS NULL OR p_search_criteria.territory_code = FND_API.G_MISS_CHAR)
    AND (p_search_criteria.role_id IS NOT NULL AND p_search_criteria.role_id <> FND_API.G_MISS_NUM)
    AND (p_search_criteria.staffing_priority_code IS NOT NULL AND p_search_criteria.staffing_priority_code <> FND_API.G_MISS_CHAR) THEN

      OPEN l_search_results FOR
        SELECT   asgn.assignment_id
               , asgn.assignment_name
               , asgn.assignment_number
               , asgn.start_date
               , asgn.end_date
               , asgn.status_code
               , proj.project_id
               , proj.name project_name
               , proj.segment1 project_number
               , loc.country_code
               , ter.territory_short_name
               , loc.region
               , loc.city
          FROM pa_project_assignments asgn
             , pa_org_hierarchy_denorm ohd
             , pa_projects_all proj
             , pa_locations loc
             , fnd_territories_vl ter
             , pa_project_statuses ps
             , pa_advertised_open_req_v aor
         WHERE asgn.min_resource_job_level <=  p_search_criteria.min_job_level
           AND asgn.max_resource_job_level >=  p_search_criteria.min_job_level
           AND asgn.project_role_id = p_search_criteria.role_id
           AND asgn.start_date >= p_search_criteria.start_date
           AND asgn.start_date <= p_search_criteria.end_date
           AND asgn.staffing_priority_code = p_search_criteria.staffing_priority_code
           AND nvl(asgn.staffing_owner_person_id, -999) = nvl(p_search_criteria.staffing_owner_person_id, nvl(asgn.staffing_owner_person_id, -999))
           AND asgn.assignment_type='OPEN_ASSIGNMENT'
	   AND asgn.status_code = ps.project_status_code (+)
           AND (ps.project_system_status_code= 'OPEN_ASGMT' or ps.project_system_status_code is NULL)
	   AND asgn.project_id = proj.project_id
           AND proj.carrying_out_organization_id = OHD.child_organization_id
           AND OHD.parent_organization_id = p_search_criteria.organization_id
           AND OHD.org_hierarchy_version_id = p_search_criteria.org_hierarchy_version_id
           AND OHD.pa_org_use_type = 'PROJECTS'
           AND asgn.location_id = loc.location_id(+)
           AND loc.country_code = ter.territory_code(+)
           AND asgn.assignment_id = aor.assignment_id;


   -- CASE 4: no assignment_id and no staffing_priority_code
   --         but role is passed in
   -- use this select statement for a requirement search if assignment id
   -- and staffing priority are not part of the criteria,
   -- but role is part of the criteria.
   ELSIF p_search_mode = 'REQUIREMENT' AND (p_search_criteria.assignment_id IS NULL OR p_search_criteria.assignment_id = FND_API.G_MISS_NUM)
    AND (p_search_criteria.staffing_priority_code IS NULL OR p_search_criteria.staffing_priority_code = FND_API.G_MISS_CHAR)
    AND (p_search_criteria.role_id IS NOT NULL AND p_search_criteria.role_id <> FND_API.G_MISS_NUM) THEN

      OPEN l_search_results FOR
        SELECT   asgn.assignment_id
               , asgn.assignment_name
               , asgn.assignment_number
               , asgn.start_date
               , asgn.end_date
               , asgn.status_code
               , proj.project_id
               , proj.name project_name
               , proj.segment1 project_number
               , loc.country_code
               , ter.territory_short_name
               , loc.region
               , loc.city
          FROM pa_project_assignments asgn
             , pa_org_hierarchy_denorm ohd
             , pa_projects_all proj
             , pa_locations loc
             , fnd_territories_vl ter
             , pa_project_statuses ps
             , pa_advertised_open_req_v aor
         WHERE asgn.min_resource_job_level <=  p_search_criteria.min_job_level
           AND asgn.max_resource_job_level >=  p_search_criteria.min_job_level
           AND asgn.project_role_id = p_search_criteria.role_id
           AND asgn.start_date >= p_search_criteria.start_date
           AND asgn.start_date <= p_search_criteria.end_date
           AND asgn.assignment_type='OPEN_ASSIGNMENT'
	   AND asgn.status_code = ps.project_status_code (+)
           AND (ps.project_system_status_code= 'OPEN_ASGMT' or ps.project_system_status_code is NULL)
           AND nvl(asgn.staffing_owner_person_id, -999) = nvl(p_search_criteria.staffing_owner_person_id, nvl(asgn.staffing_owner_person_id, -999))
           AND asgn.project_id = proj.project_id
           AND proj.carrying_out_organization_id = OHD.child_organization_id
           AND OHD.parent_organization_id = p_search_criteria.organization_id
           AND OHD.org_hierarchy_version_id = p_search_criteria.org_hierarchy_version_id
           AND OHD.pa_org_use_type = 'PROJECTS'
           AND asgn.location_id = loc.location_id(+)
           AND nvl(loc.country_code, -999) = nvl(p_search_criteria.territory_code, nvl(loc.country_code, -999))
           AND loc.country_code = ter.territory_code(+)
           AND asgn.assignment_id = aor.assignment_id;

   -- CASE 5: no assignment_id, no role
   -- use this select statement for a requirement search if assignment_id and
   -- role are not part of the criteria.
   ELSIF p_search_mode = 'REQUIREMENT' AND (p_search_criteria.assignment_id IS NULL OR p_search_criteria.assignment_id = FND_API.G_MISS_NUM) AND (p_search_criteria.role_id IS NULL OR p_search_criteria.role_id = FND_API.G_MISS_NUM) THEN

   OPEN l_search_results FOR
        SELECT   asgn.assignment_id
               , asgn.assignment_name
               , asgn.assignment_number
               , asgn.start_date
               , asgn.end_date
               , asgn.status_code
               , proj.project_id
               , proj.name project_name
               , proj.segment1 project_number
               , loc.country_code
               , ter.territory_short_name
               , loc.region
               , loc.city
          FROM pa_project_assignments asgn
             , pa_org_hierarchy_denorm ohd
             , pa_projects_all proj
             , pa_locations loc
             , fnd_territories_vl ter
             , pa_project_statuses ps
             , pa_advertised_open_req_v aor
         WHERE asgn.min_resource_job_level <=  p_search_criteria.min_job_level
           AND asgn.max_resource_job_level >=  p_search_criteria.min_job_level
           AND asgn.start_date >= p_search_criteria.start_date
           AND asgn.start_date <= p_search_criteria.end_date
           AND nvl(asgn.staffing_priority_code, -999) = nvl(p_search_criteria.staffing_priority_code, nvl(asgn.staffing_priority_code, -999))
           AND nvl(asgn.staffing_owner_person_id, -999) = nvl(p_search_criteria.staffing_owner_person_id, nvl(asgn.staffing_owner_person_id, -999))
           AND asgn.assignment_type='OPEN_ASSIGNMENT'
	   AND asgn.status_code = ps.project_status_code (+)
           AND (ps.project_system_status_code= 'OPEN_ASGMT' or ps.project_system_status_code is NULL)
           AND asgn.project_id = proj.project_id
           AND proj.carrying_out_organization_id = OHD.child_organization_id
           AND OHD.parent_organization_id = p_search_criteria.organization_id
           AND OHD.org_hierarchy_version_id = p_search_criteria.org_hierarchy_version_id
           AND OHD.pa_org_use_type = 'PROJECTS'
           AND asgn.location_id = loc.location_id(+)
           AND nvl(loc.country_code, -999) = nvl(p_search_criteria.territory_code, nvl(loc.country_code, -999))
           AND loc.country_code = ter.territory_code(+)
           AND asgn.assignment_id = aor.assignment_id;

   END IF;

   P_DEBUG_MODE := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
    IF (P_DEBUG_MODE ='Y') THEN
  PA_DEBUG.WRITE_LOG(
     x_Module =>'pa.plsql.PA_SEARCH_PVT.Run_Search.fetch_values',
     x_Msg =>'if this is a Requirement Search then fetch the values from the cursor',
     x_Log_Level => 6);
   end if;

   -- if this is a Resource Search then fetch the values from the cursor
   -- into the appropriate local variables.
   IF p_search_mode = 'RESOURCE' or p_search_mode = 'ADHOC' THEN

     FETCH l_search_results BULK COLLECT INTO l_person_id_tbl,
                                              l_resource_id_tbl,
                                              l_resource_name_tbl,
                                              l_resource_type_tbl,
                                              l_resource_organization_id_tbl,
                                              l_country_code_tbl,
                                              l_country_tbl,
                                              l_region_tbl,
                                              l_city_tbl,
                                              l_resource_job_level_tbl,
                                              l_manager_tbl,
                                              l_email_tbl;


       -- if  there are any competencies then
       -- put the competencies into plsql tables of scalars and count
       -- the mandatory/optional competencies.
       -- Need to copy into tables of scalars because can't use tables of
       -- records in bulk binds in 8i.
       IF l_person_id_tbl.COUNT > 0 THEN

          IF p_competence_criteria.COUNT > 0 THEN

             FOR i IN p_competence_criteria.FIRST .. p_competence_criteria.LAST
             LOOP

                l_competence_id_tbl(i) :=
                                       p_competence_criteria(i).competence_id;

                l_competence_name_tbl(i) :=
                                       p_competence_criteria(i).competence_name;
                l_rating_level_tbl(i) := p_competence_criteria(i).rating_level;
                l_mandatory_flag_tbl(i) :=
                                       p_competence_criteria(i).mandatory_flag;

                IF p_competence_criteria(i).mandatory_flag = 'Y' THEN
                   l_mandatory_competence_count := l_mandatory_competence_count+1;
                ELSE
                   l_optional_competence_count := l_optional_competence_count+1;
                END IF;

             END LOOP;

          END IF; --p_competence_criteria.COUNT >0

          FORALL k IN l_person_id_tbl.FIRST .. l_person_id_tbl.LAST
             INSERT INTO PA_SEARCH_RESULTS_TEMP ( person_id
                                                , resource_id
                                                , resource_organization_id
                                                , resource_name
                                                , resource_type
                                                , resource_job_level
                                                , country
                                                , country_code
                                                , region
                                                , city
                                                , optional_competence_match
                                                , optional_competence_count
                                                , mandatory_competence_match
                                                , mandatory_competence_count
                                                , availability
                                                , potential_availability
                                                , resource_email
                                                , resource_manager
                                                )
                                        VALUES ( l_person_id_tbl(k)
                                               , l_resource_id_tbl(k)
                                               , l_resource_organization_id_tbl(k)
                                               , l_resource_name_tbl(k)
                                               , l_resource_type_tbl(k)
                                               , l_resource_job_level_tbl(k)
                                               , l_country_tbl(k)
                                               , l_country_code_tbl(k)
                                               , l_region_tbl(k)
                                               , l_city_tbl(k)
                                               , 0
                                               , l_optional_competence_count
                                               , 0
                                               , l_mandatory_competence_count
                                               , null
                                               , null
                                               , l_email_tbl(k)
                                               , l_manager_tbl(k)
                                               );

          --if there is any competence criteria then do the competence match
          IF p_competence_criteria.COUNT > 0 THEN

             -- insert competence critieria into a global temporary table.
             -- that way I can join to the temp table to do the competence match
             -- instead of doing the match once per competence.
             FORALL i IN l_competence_id_tbl.FIRST .. l_competence_id_tbl.LAST
                INSERT INTO pa_competence_criteria_temp(competence_id,
                                                        competence_name,
                                                        rating_level,
                                                        mandatory_flag)
                                                 VALUES(l_competence_id_tbl(i),
                                                       l_competence_name_tbl(i),
                                                        l_rating_level_tbl(i),
                                                        l_mandatory_flag_tbl(i));

             -- do competence match.
             -- ordered hint is required because global temporary table does not
             -- have any statistics.  This was OK'd by Ahmed Alomari.
             -- update the search results table with the match.
             --
--             IF p_search_mode = 'RESOURCE' THEN
--                FORALL i IN l_person_id_tbl.FIRST .. l_person_id_tbl.LAST
--                  UPDATE pa_search_results_temp
--                   SET (mandatory_competence_match,optional_competence_match)=
--                            (SELECT /*+ ORDERED */nvl(sum(decode(pct.mandatory_flag,'Y',1,0)),0), nvl(sum(decode(pct.mandatory_flag,'N',1,0)),0)
--                               FROM pa_competence_criteria_temp pct,
--                                    per_competence_elements pce,
--                                    per_rating_levels prl
--                              WHERE pce.competence_id = pct.competence_id
--                                AND pce.person_id = l_person_id_tbl(i)
--                                AND pce.proficiency_level_id =
--                                                       prl.rating_level_id(+)
--                                AND decode(prl.step_value, NULL,
--                                          decode(pct.rating_level, NULL, -999,
--                        PA_SEARCH_GLOB.get_min_prof_level(pct.competence_id)),
--                                           prl.step_value) >=
--                             nvl(pct.rating_level, nvl(prl.step_value , -999))
--                            )
--                    WHERE person_id = l_person_id_tbl(i);

             IF p_search_mode = 'ADHOC' OR p_search_mode = 'RESOURCE' THEN

                -- hr_utility.trace('IN Competence Calculation.');
                --
                -- First do the calculation for competences, then do it
                -- for the categories.  The one for competences is same
                -- as the above, with a check for competence id to be
                -- not null.
                --
                FORALL i IN l_person_id_tbl.FIRST .. l_person_id_tbl.LAST
                  UPDATE pa_search_results_temp
                     SET (mandatory_competence_match,optional_competence_match)=
                            (SELECT /*+ ORDERED */nvl(sum(decode(pct.mandatory_flag,'Y',1,0)),0), nvl(sum(decode(pct.mandatory_flag,'N',1,0)),0)
                               FROM pa_competence_criteria_temp pct,
                                    per_competence_elements pce,
                                    per_rating_levels prl
                              WHERE (pct.competence_id <> -1 AND
                                     pce.competence_id = pct.competence_id)
                                AND pce.person_id = l_person_id_tbl(i)
                                AND pce.proficiency_level_id =
                                                         prl.rating_level_id(+)
/*code added for bug 2932045*/
                                AND PA_SEARCH_GLOB.g_search_criteria.start_date between
                                     NVL(pce.EFFECTIVE_DATE_FROM,PA_SEARCH_GLOB.g_search_criteria.start_date)
                                     and nvl(pce.EFFECTIVE_DATE_TO,PA_SEARCH_GLOB.g_search_criteria.start_date)
/*code addition ends  for bug 2932045*/
                                AND decode(prl.step_value, NULL,
                                           decode(pct.rating_level, NULL, -999,
                          PA_SEARCH_GLOB.get_min_prof_level(pct.competence_id)),
                                           prl.step_value) >=
                             nvl(pct.rating_level, nvl(prl.step_value , -999))
                            )
                    WHERE person_id = l_person_id_tbl(i);
                --
                -- Next, do the calculation for competence category - +1
                -- if one exists.  Add it to the competence match that exists.
                --
                -- hr_utility.trace('IN Competence Category Calculation.');
                --
/*
                IF p_competence_criteria.COUNT > 0 THEN

                   FOR i IN p_competence_criteria.FIRST ..
                            p_competence_criteria.LAST LOOP

                     hr_utility.trace('Comp ID is : ' ||
                            to_char(p_competence_criteria(i).competence_id));
                     hr_utility.trace('Comp Name is : ' ||
                            p_competence_criteria(i).competence_name);
                     hr_utility.trace('Comp Name is : ' ||
                            p_competence_criteria(i).mandatory_flag);
                   END LOOP;
                 END IF;
*/

--BUG#9212362
OPEN cur_competence_id_search;
FETCH cur_competence_id_search INTO l_comp_id_num;
CLOSE cur_competence_id_search;

IF (l_comp_id_num >0) THEN
                FOR i IN l_person_id_tbl.FIRST .. l_person_id_tbl.LAST LOOP
                  UPDATE pa_search_results_temp
                     SET (mandatory_competence_match,optional_competence_match)=
                         (SELECT /*+ ORDERED */
 (nvl(sum(decode(pct.mandatory_flag,'Y',1,0)),0) + nvl(mandatory_competence_match, 0)),
 (nvl(sum(decode(pct.mandatory_flag,'N',1,0)),0) + nvl(optional_competence_match, 0))
                            FROM pa_competence_criteria_temp pct
                           WHERE pct.competence_id = -1
                             AND EXISTS ( SELECT 'Y'
                                            FROM per_competence_elements pce,
                                                 per_competences pc,
                                                 per_rating_levels prl
                          WHERE pce.person_id = l_person_id_tbl(i)
                            AND pce.competence_id = pc.competence_id
/*code added for bug 2932045*/

                            AND PA_SEARCH_GLOB.g_search_criteria.start_date between
                                     NVL(pce.EFFECTIVE_DATE_FROM,PA_SEARCH_GLOB.g_search_criteria.start_date)
                                     and nvl(pce.EFFECTIVE_DATE_TO,PA_SEARCH_GLOB.g_search_criteria.start_date)
/*code addition end for bug 2932045*/
                            AND pc.name like
                               (replace(pct.competence_name, '...') || '%')
                            AND pce.proficiency_level_id =
                                prl.rating_level_id(+)
                            AND decode(prl.step_value, NULL,
                                decode(pct.rating_level, NULL, -999,
                        PA_SEARCH_GLOB.get_min_prof_level(pce.competence_id)),
                        prl.step_value) >=
                              nvl(pct.rating_level, nvl(prl.step_value , -999))
                                        )
                            )
                    WHERE person_id = l_person_id_tbl(i);
              END LOOP;
             END IF; --IF (l_comp_id_num >0) THEN

             END IF;

          END IF;  --p_competence_criteria.COUNT > 0

          -- Availability calculation is different for adhoc vs non-adhoc
          -- This part is for requirement-based resource search.
          -- do availability calculation for resources who pass the
          -- mandatory competence match
          -- or for everyone if there are no mandatory competencies. (0=0)
          -- ordered hint is required because global temporary table does not
          -- have any statistics.  This was OK'd by Ahmed Alomari.
          -- bulk collect the resources who passed the mandatory competence
          -- check and their availability into plsql tables.

          -- need to know the number of assignment days because the
          -- pa_forecast_items table does not store unassigned time
          -- resource records with 0 hours.
          -- This will be used in the following sql statement...
          --
          -- hr_utility.trace('SEARCH MODE IS' || p_search_mode);
             -- hr_utility.trace('assignment_id is : ' || to_char(p_search_criteria.assignment_id));

          IF p_search_mode = 'RESOURCE' THEN

             SELECT count(*) INTO l_assignment_days
               FROM pa_forecast_items
              WHERE assignment_id = p_search_criteria.assignment_id
                AND delete_flag = 'N'
                AND error_flag IN ('Y','N')
                AND item_date >= trunc(SYSDATE)
                AND item_quantity > 0;

             -- hr_utility.trace('after getting l_assignment_days');
             -- hr_utility.trace('l_assignment_days is : ' || to_char(l_assignment_days));
             IF l_assignment_days > 0 THEN

             -- this sql statement calculates availability for each resource
             -- in the pa_search_results_temp table.  The availability is
             -- calculated on a daily basis.  The resource avail hours is
             -- divided by the assignment hours for each day, summed up and
             -- then divided by the total number of assignment days
             -- with non-zero hours.  We need to divide by l_assignment_days
             -- because days for which a resource has 0 hours will not be in
             -- the forecast items table, but we need to take those days into
             -- account for the availability calculation as the assignment
             -- does have hours on that day - basically we need to average
             -- in 0 for those days - this is taken care of by dividing by
             -- l_assignment_days as opposed to dividing by the number of
             -- days which make the join below.
             --
             --Added for bug #  6144255
	     DELETE FROM PA_FI_ASSIG_TEMP;
	     INSERT INTO PA_FI_ASSIG_TEMP
	     (
		SELECT asgmt.item_date ,
		       asgmt.item_quantity
	          FROM pa_forecast_items asgmt
    	        WHERE asgmt.assignment_id = p_search_criteria.assignment_id
                AND asgmt.delete_flag = 'N'
                AND asgmt.error_flag IN ('Y','N')
                AND asgmt.item_date >= trunc(SYSDATE)
                AND asgmt.item_quantity > 0
	     );
  	     l_resource_tab.delete;
	     IF ( l_person_id_tbl.COUNT > 0 ) THEN
		FOR k IN l_person_id_tbl.FIRST..l_person_id_tbl.LAST LOOP
			l_availability_tbl(k) := 0;
			l_pot_availability_tbl(k) := 0;
		END LOOP;
	     END IF;
	     -- Bug Ref # 7457064, Removed multiple joins of PA_FORECAST_ITEMS
	     -- Using the temp table instead.
       	     --Bug 6911907: Changed the index to PA_FORECAST_ITEMS_N5 from PA_FORECAST_ITEMS_N3
	     --Bug 6911907: Changed the index back to PA_FORECAST_ITEMS_N3
	     -- Added filter condition
  	     stmt_select := 'SELECT /*+ INDEX (res, PA_FORECAST_ITEMS_N3) */ ' ||
                                  '  res.person_id, ' ||
			          '  TRUNC(SUM(DECODE(SIGN( ' ||
				  ' (nvl(res.capacity_quantity, 0) - nvl(res.confirmed_qty, 0) - ' ||
				  '  nvl(res.provisional_qty,0)) / asgmt.item_quantity-1),1, 1, ' ||
				  '  greatest((nvl(res.capacity_quantity, 0) - nvl(res.confirmed_qty, 0) -  ' || /*Greatest function is added for bug 2782464*/
				  '  nvl(res.provisional_qty,0)),0) / ' ||
				  '  asgmt.item_quantity))/ :1 ' || ' * 100), ' ||
			          '  TRUNC(SUM(DECODE(SIGN( ' ||
				  '  (nvl(res.capacity_quantity, 0) - nvl(res.confirmed_qty, 0))/asgmt.item_quantity-1),1, 1,' ||
				  '  greatest((nvl(res.capacity_quantity, 0) - ' ||
				  '  nvl(res.confirmed_qty, 0)), 0)/ asgmt.item_quantity))/ :1 ' || '* 100) ';

	     stmt_from :=	  '	FROM ' ||
				  '	     PA_FORECAST_ITEMS res, ' ||
  		                  '          PA_FI_ASSIG_TEMP asgmt ';

	    stmt_where :=	  '    WHERE ' ||
				  '	 res.forecast_item_type = ''U'' ' ||
				  '	 AND res.delete_flag = ''N'' ' ||
				  '	 AND res.item_date = asgmt.item_date ' ||
   				  '      AND res.item_date BETWEEN :2 AND :3'|| -- added for Bug 6911907
				  '      AND res.resource_id IN (';

	stmt_groupby :=	  '  ) GROUP BY res.person_id ';

	OPEN cur_res_temp_search;
	str_resource_ids := ' ';
	index_1 := 0;
	LOOP
	  FETCH cur_res_temp_search BULK COLLECT INTO l_resource_tab limit 1000;
	  IF ( l_resource_tab.COUNT > 0 ) THEN
	     FOR  i IN l_resource_tab.FIRST..l_resource_tab.LAST LOOP
		str_resource_ids := str_resource_ids || l_resource_tab(i) || ',';
	     END LOOP;
	     len := LENGTH(str_resource_ids) -1 ;
	     str_resource_ids := SUBSTR(str_resource_ids,1,len);
	  ELSE
	    EXIT;
	  END IF;
  	  OPEN cur_avail FOR (stmt_select || stmt_from || stmt_where || str_resource_ids || stmt_groupby)
--	  USING l_assignment_days, l_assignment_days;  -- added below for Bug 6911907
	  USING l_assignment_days, l_assignment_days,p_search_criteria.start_date,p_search_criteria.end_date;

		FETCH cur_avail BULK COLLECT INTO l_person_id_tbl_tmp, l_pot_availability_tbl_tmp,l_availability_tbl_tmp;
		CLOSE cur_avail;

		IF l_person_id_tbl_tmp.COUNT >0 THEN

			FOR j IN l_person_id_tbl_tmp.FIRST..l_person_id_tbl_tmp.LAST LOOP
				index_1 := index_1 + 1 ;
				l_person_id_tbl(index_1) := l_person_id_tbl_tmp(j);
				l_pot_availability_tbl(index_1) := l_pot_availability_tbl_tmp(j);
				l_availability_tbl(index_1) := l_availability_tbl_tmp(j);

			END LOOP;
		END IF;

		str_resource_ids := ' ';
	END LOOP;
	CLOSE cur_res_temp_search;
        --End for bug 7457064

           END IF; --l_assignment_days > 0

-- hr_utility.trace('availabi count is  ' || to_char(l_availability_tbl.COUNT));

         ELSIF p_search_mode = 'ADHOC' THEN
             -- hr_utility.trace('IN HERE ');
-- hr_utility.trace('start date is ' || to_char(p_search_criteria.start_date, 'DD-MON-YYYY'));
-- hr_utility.trace('end_date is ' || to_char(p_search_criteria.end_date, 'DD-MON-YYYY'));
             --
             -- Caculation from forecast items until new table solution
             --
             SELECT /*+ ORDERED USE_NL(srt res) INDEX (res, PA_FORECAST_ITEMS_N3)*/srt.person_id, count(res.resource_id)
              BULK COLLECT INTO l_person_id_tbl, l_days_in_period_tbl
              FROM PA_SEARCH_RESULTS_TEMP srt,
                   PA_FORECAST_ITEMS res
             WHERE srt.resource_id = res.resource_id
               AND res.forecast_item_type = 'U'
               AND res.delete_flag = 'N'
               AND res.error_flag IN ('Y','N')
               AND res.item_date BETWEEN p_search_criteria.start_date AND
                                         p_search_criteria.end_date
	       AND srt.mandatory_competence_count =
 	                    srt.mandatory_competence_match /* Added for bug 4624826 */
               AND res.capacity_quantity > 0
          GROUP BY srt.person_id ;
           /*ORDER BY srt.person_id;commented for bug 4624826 */
             --

             IF l_person_id_tbl.count > 0 THEN
             FOR i in l_person_id_tbl.first .. l_person_id_tbl.last LOOP
                --
                IF l_days_in_period_tbl(i) > 0 THEN
                   --
		   BEGIN
                   SELECT
TRUNC(SUM(greatest((nvl(res.capacity_quantity, 0) - nvl(res.confirmed_qty, 0) -
           nvl(res.provisional_qty,0)), 0) / res.capacity_quantity) /
           l_days_in_period_tbl(i) * 100),
TRUNC(SUM(greatest((nvl(res.capacity_quantity, 0) -
                    nvl(res.confirmed_qty, 0)), 0) / res.capacity_quantity) /
           l_days_in_period_tbl(i) * 100)
                    INTO l_pot_availability_tbl(i),
                         l_availability_tbl(i)
                    FROM PA_SEARCH_RESULTS_TEMP srt,
                         PA_FORECAST_ITEMS res
                   WHERE srt.person_id = l_person_id_tbl(i)
		     AND srt.resource_id = res.resource_id
                     AND res.forecast_item_type = 'U'
                     AND res.delete_flag = 'N'
                     AND res.capacity_quantity > 0
                     AND res.item_date BETWEEN p_search_criteria.start_date AND
                                               p_search_criteria.end_date
                     AND srt.mandatory_competence_count =
                         srt.mandatory_competence_match
                   GROUP BY srt.person_id;

		EXCEPTION WHEN NO_DATA_FOUND THEN
		   l_pot_availability_tbl(i) := 0;
                   l_availability_tbl(i) := 0;
                END;
                --
                ELSE
		   l_pot_availability_tbl(i) := 0;
                   l_availability_tbl(i) := 0;
                END IF;
             --
             END LOOP;
             END IF;
             --
/*
             hr_utility.trace('Person table is '|| to_char(l_person_id_tbl.count));
             hr_utility.trace('Days table is '|| to_char(l_days_in_period_tbl.count));
             hr_utility.trace('Avail table is '|| to_char(l_availability_tbl.count));
             hr_utility.trace('Pot Avail table is '|| to_char(l_pot_availability_tbl.count));
             IF l_availability_tbl.count > 0 THEN
             FOR j in l_availability_tbl.first .. l_availability_tbl.last LOOP
                 hr_utility.trace('Avail is : ' || to_char(l_availability_tbl(j)));
                 hr_utility.trace('Days is : ' || to_char(l_days_in_period_tbl(j)));
                 hr_utility.trace('Person ID is : ' || to_char(l_person_id_tbl(j)));
             END LOOP;
             END IF;
*/
             -- Do availability calculation based on new table
             --
/*
             SELECT srt.person_id,
                    confirmed.percent,
                    potential.percent
                    BULK COLLECT INTO l_person_id_tbl,
                                      l_availability_tbl,
                                      l_pot_availability_tbl
               FROM PA_SEARCH_RESULTS_TEMP srt,
                    PA_RES_AVAILABILITY confirmed,
                    PA_RES_AVAILABILITY potential
              WHERE srt.resource_id = confirmed.resource_id
                AND confirmed.record_type = 'C'
                AND p_search_criteria.start_date BETWEEN confirmed.start_date
                                                 AND confirmed.end_date
                AND srt.resource_id = potential.resource_id
                AND potential.record_type = 'B'
                AND p_search_criteria.start_date BETWEEN potential.start_date
                                                 AND potential.end_date
                AND srt.mandatory_competence_count =
                    srt.mandatory_competence_match
           GROUP BY srt.person_id;
*/

          END IF;

          -- if any resources passed the mandatory competence
          -- check(exist in l_person_id_tbl)
          -- then update the search results table with the availability,
          -- resource org name and candidate score
          -- if availability > min availabilty.
             -- hr_utility.trace('RANJANA 1 ');
             -- hr_utility.trace('l_person_id_tbl count is  ' || to_char(l_person_id_tbl.COUNT));
             -- hr_utility.trace('l_pot_availability_tbl count is  ' || to_char(l_pot_availability_tbl.COUNT));
             -- hr_utility.trace('l_availability_tbl count is  ' || to_char(l_availability_tbl.COUNT));
          IF l_person_id_tbl.COUNT > 0 THEN

           IF ( l_availability_tbl.COUNT > 0 AND l_pot_availability_tbl.COUNT > 0 ) THEN  /*Added for bug 7628377*/
             -- hr_utility.trace('l_person_id is  ' || to_char(l_person_id_tbl(1)));
             -- bug#8833203
			 FORALL k IN l_person_id_tbl_tmp.FIRST .. l_person_id_tbl_tmp.LAST
                UPDATE pa_search_results_temp
                   SET availability = l_availability_tbl(k),
                       potential_availability = l_pot_availability_tbl(k),
                       --resource_organization_name = pa_expenditures_utils.GetOrgTlName(resource_organization_id), 4778073
		       resource_organization_name = pa_resource_utils.get_organization_name(resource_organization_id),
                       candidate_score = PA_CANDIDATE_UTILS.Get_Candidate_Score(
				resource_id,
                             	l_person_id_tbl(k),
                             	p_search_criteria.assignment_id,
				p_search_criteria.project_id,
				null,
				optional_competence_match+mandatory_competence_match,
				optional_competence_count+mandatory_competence_count,
				l_availability_tbl(k),
				resource_job_level,
				p_search_criteria.min_job_level,
				p_search_criteria.max_job_level,
				p_search_criteria.competence_match_weighting,
				p_search_criteria.availability_match_weighting,
				p_search_criteria.job_level_match_weighting)
                 WHERE person_id = l_person_id_tbl(k)
                   AND ((nvl(p_search_criteria.provisional_availability, 'N') = 'N' AND
                        l_availability_tbl(k) >=
                            p_search_criteria.min_availability)
                       OR
                       (p_search_criteria.provisional_availability = 'Y' AND
                        l_pot_availability_tbl(k) >=
                            p_search_criteria.min_availability));

           END IF ; -- IF ( l_availability_tbl.COUNT > 0 AND l_pot_availability_tbl.COUNT > 0 )
          END IF; --l_person_id_tbl.COUNT >0

             -- hr_utility.trace('RANJANA 2 ');
          -- if p_search_criteria.min_availability =0 then it is possible
          -- that some people in the denorm table meet the criteria but
          -- were not updated in the above update statement because they
          -- were not in l_person_id_tbl(k) because they were not available
          -- on ANY of the requirement days.  Resource records with 0 hours
          -- do not exist in the pa_forecast_items table.
          -- In that case we need to update the availability to 0 and update
          -- the resource org name and candidate score.
          -- NOTE that the update only happens if
          -- p_search_criteria.min_availability = 0 AND
          -- availability, resource org name, and candidate score are all null,
          -- (and mandatory competence match = optional competence match)
          -- which means they were not updated in the above update statement.

          IF p_search_criteria.min_availability = 0 THEN

                UPDATE pa_search_results_temp
                   SET availability = 0,
                       potential_availability = 0,
                       --resource_organization_name = pa_expenditures_utils.GetOrgTlName(resource_organization_id), 4778073
		       resource_organization_name = pa_resource_utils.get_organization_name(resource_organization_id),
                       candidate_score = PA_CANDIDATE_UTILS.Get_Candidate_Score(
				resource_id,
                                person_id,
                             	p_search_criteria.assignment_id,
				p_search_criteria.project_id,
				null,
				optional_competence_match+mandatory_competence_match,
				optional_competence_count+mandatory_competence_count,
				0,
				resource_job_level,
				p_search_criteria.min_job_level,
				p_search_criteria.max_job_level,
				p_search_criteria.competence_match_weighting,
				p_search_criteria.availability_match_weighting,
				p_search_criteria.job_level_match_weighting)
                  WHERE mandatory_competence_count = mandatory_competence_match
                    AND availability IS NULL
                    AND resource_organization_name IS NULL
                    AND candidate_score IS NULL;

          END IF;  --p_search_criteria.min_availability > 0
             -- hr_utility.trace('RANJANA 3 ');

        -- END IF; --l_assignment_days > 0

       END IF; --l_person_id_tbl.COUNT > 0

             --hr_utility.trace_off;
   -- if this is a Requirement Search then fetch the values from the cursor
   -- into the appropriate local variables.
   ELSIF p_search_mode = 'REQUIREMENT' THEN

      FETCH l_search_results BULK COLLECT INTO l_assignment_id_tbl,
                                               l_assignment_name_tbl,
                                               l_assignment_number_tbl,
                                               l_assignment_start_date_tbl,
                                               l_assignment_end_date_tbl,
                                               l_status_code_tbl,
                                               l_project_id_tbl,
                                               l_project_name_tbl,
                                               l_project_number_tbl,
                                               l_country_code_tbl,
                                               l_country_tbl,
                                               l_region_tbl,
                                               l_city_tbl;

      IF l_assignment_id_tbl.COUNT > 0 THEN

         FORALL k IN l_assignment_id_tbl.FIRST .. l_assignment_id_tbl.LAST
            INSERT INTO PA_SEARCH_RESULTS_TEMP ( assignment_id
                                               , assignment_name
                                               , assignment_number
                                               , assignment_start_date
                                               , assignment_end_date
                                               , project_id
                                               , project_name
                                               , project_number
                                               , country
                                               , country_code
                                               , region
                                               , city
                                               , optional_competence_match
                                               , optional_competence_count
                                               , mandatory_competence_match
                                               , mandatory_competence_count
                                               )
                                        VALUES ( l_assignment_id_tbl(k)
                                               , l_assignment_name_tbl(k)
                                               , l_assignment_number_tbl(k)
                                               , l_assignment_start_date_tbl(k)
                                               , l_assignment_end_date_tbl(k)
                                               , l_project_id_tbl(k)
                                               , l_project_name_tbl(k)
                                               , l_project_number_tbl(k)
                                               , l_country_tbl(k)
                                               , l_country_code_tbl(k)
                                               , l_region_tbl(k)
                                               , l_city_tbl(k)
                                               ,0
                                               ,0
                                               ,0
                                               ,0
                                               );

          --call function show_req_in_search which checks the
          --visible in requirement search status controls for the
          --requirement's status(es).
          --delete the requirement from the results table if the requirement is not
          --to be shown due to the status controls.
          --**Calling this bulk delete is slightly faster than calling the
          --**function directly in the insert statement above.
          FORALL i IN l_assignment_id_tbl.FIRST .. l_assignment_id_tbl.LAST
            DELETE FROM pa_search_results_temp
                  WHERE show_req_in_search(l_assignment_id_tbl(i), l_status_code_tbl(i)) = 'N'
                    AND assignment_id = l_assignment_id_tbl(i);

         --if resource source id is not null then do the competence count/match
         --for all requirements returned by the initial cursor based on that resource.
         IF p_search_criteria.resource_source_id IS NOT NULL THEN

            --update the search results table with the mandatory/optional competence count
            --for all requirements.
            FORALL i IN l_assignment_id_tbl.FIRST .. l_assignment_id_tbl.LAST
               UPDATE pa_search_results_temp
                  SET (mandatory_competence_count, optional_competence_count) =
                      (SELECT nvl(sum(decode(mandatory,'Y',1,0)),0), nvl(sum(decode(mandatory,'N',1,0)),0)
                         FROM per_competence_elements pce
                        WHERE pce.object_name = 'OPEN_ASSIGNMENT'
                          AND pce.object_id = l_assignment_id_tbl(i))
                WHERE assignment_id = l_assignment_id_tbl(i);

             --update the search results table with the mandatory/optional competence match
             --for all requirments based on the resource competencies.
             FORALL i IN l_assignment_id_tbl.FIRST .. l_assignment_id_tbl.LAST
                UPDATE pa_search_results_temp
                   SET (mandatory_competence_match,optional_competence_match)=
                       (SELECT nvl(sum(decode(pce.mandatory,'Y',1,0)),0), nvl(sum(decode(pce.mandatory,'N',1,0)),0)
                          FROM per_competence_elements pce,
                               per_competence_elements pce2,
                               per_rating_levels prl,
                               per_rating_levels prl2
                         WHERE pce.object_id = l_assignment_id_tbl(i)
                           AND pce.object_name = 'OPEN_ASSIGNMENT'
                           AND pce.proficiency_level_id = prl.rating_level_id(+)
                           AND pce.competence_id = pce2.competence_id
                           AND pce2.person_id = p_search_criteria.resource_source_id
                           AND pce2.proficiency_level_id = prl2.rating_level_id(+)
                           AND decode(prl2.step_value, NULL, decode(prl.step_value, NULL, -999,  PA_SEARCH_GLOB.get_min_prof_level(pce2.competence_id)), prl2.step_value) >= nvl(prl.step_value, nvl(prl2.step_value , -999)))
                 WHERE assignment_id = l_assignment_id_tbl(i);

         END IF;  --resource source id is not null

         --update the search results table with the number of active candidates
         --and the candidate in req flag (if resource source id is not null)
         --for only requirements that passed the mandatory competence match if restrict to
         --resource's competencies is true, or for all requirements if restrict to resource's
         --competencies is false.
         UPDATE pa_search_results_temp
            SET candidate_in_req_flag = decode(p_search_criteria.resource_source_id, NULL, NULL,PA_CANDIDATE_UTILS.Check_Resource_Is_Candidate(PA_RESOURCE_UTILS.Get_Resource_Id(p_search_criteria.resource_source_id), assignment_id))
          WHERE ((mandatory_competence_count=mandatory_competence_match AND p_search_criteria.restrict_res_comp = FND_API.G_TRUE)
             OR p_search_criteria.restrict_res_comp = FND_API.G_FALSE);

      END IF; --l_assignment_id_tbl.COUNT > 0

   END IF; -- search mode check


  EXCEPTION

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ; -- 4537865
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_SEARCH_PVT.Run_Search'
                            , p_procedure_name => PA_DEBUG.G_Err_Stack);
    RAISE;


  END Run_Search;


  FUNCTION Show_Req_In_Search(p_assignment_id pa_project_assignments.assignment_id%TYPE,
                              p_status_code   pa_project_statuses.project_status_code%TYPE)
     RETURN VARCHAR2 IS

    l_show_in_search   VARCHAR2(1);

    TYPE status_code_tbl IS TABLE OF pa_project_statuses.project_status_code%TYPE
       INDEX BY BINARY_INTEGER;
    l_status_code_tbl  status_code_tbl;

  BEGIN

  --if the status code is not passed to the function then the requirement has
  --multiple statuses - so get all the statuses for the requirement
  --from pa_schedules.
  IF p_status_code IS NULL THEN

     SELECT DISTINCT status_code BULK COLLECT INTO l_status_code_tbl
       FROM pa_schedules
      WHERE assignment_id = p_assignment_id;

  --if the status code is passed to the function then assign to the plsql table.
  ELSE

     l_status_code_tbl(1) := p_status_code;

  END IF;

  --check the Visible in Requirement Search status control for all
  --statuses of the requirement.
  --Business rule is that if the requirement has multiple statuses
  --then if ANY of the statuses should be shown in requirement search
  --then show that requirement.
  FOR i IN l_status_code_tbl.FIRST .. l_status_code_tbl.LAST LOOP

     l_show_in_search := PA_PROJECT_UTILS.Check_prj_stus_action_allowed
                                       ( x_project_status_code  => l_status_code_tbl(i)
                                        ,x_action_code  => 'OPEN_ASGMT_VISIBLE');

     IF l_show_in_search = 'Y' THEN
        RETURN 'Y';
     END IF;

  END LOOP;

  RETURN 'N';

  EXCEPTION
     WHEN OTHERS THEN
        RAISE;

  END;

-- END RUN_SEARCH

  PROCEDURE Run_Auto_Search(errbuf                 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            retcode                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            p_auto_search_mode      IN VARCHAR2,
                            p_project_id            IN NUMBER,
                            p_project_number_from   IN VARCHAR2,
                            p_project_number_to     IN VARCHAR2,
                            p_proj_start_date_days  IN NUMBER,
                            p_req_start_date_days   IN NUMBER,
                            p_project_status_code   IN VARCHAR2,
                            p_debug_mode            IN VARCHAR2)
  IS

  CURSOR get_auto_search_criteria IS
  SELECT asgn.assignment_id,
         asgn.project_id,
         asgn.min_resource_job_level,
         asgn.max_resource_job_level,
         asgn.start_date,
         asgn.end_date,
         asgn.search_min_availability,
         asgn.search_country_code,
         asgn.search_exp_org_struct_ver_id,
         asgn.search_exp_start_org_id,
         asgn.search_min_candidate_score,
         asgn.COMPETENCE_MATCH_WEIGHTING,
         asgn.AVAILABILITY_MATCH_WEIGHTING,
         asgn.JOB_LEVEL_MATCH_WEIGHTING,
         asgn.ENABLE_AUTO_CAND_NOM_FLAG,
         proj.enable_automated_search
    FROM pa_project_assignments asgn,
         pa_projects_all proj,
         pa_project_statuses ps
   WHERE proj.project_id = p_project_id
     AND proj.project_id = asgn.project_id
     AND trunc(asgn.start_date) BETWEEN decode(p_req_start_date_days, NULL, asgn.start_date, trunc(SYSDATE)) AND decode(p_req_start_date_days, NULL, asgn.start_date, trunc(SYSDATE) + p_req_start_date_days)
     AND asgn.assignment_type='OPEN_ASSIGNMENT'
      AND asgn.status_code = ps.project_status_code (+)
      AND (ps.project_system_status_code= 'OPEN_ASGMT' or ps.project_system_status_code is NULL)
      AND p_auto_search_mode = 'SINGLE_PROJECT'
 UNION ALL
  SELECT asgn.assignment_id,
         asgn.project_id,
         asgn.min_resource_job_level,
         asgn.max_resource_job_level,
         asgn.start_date,
         asgn.end_date,
         asgn.search_min_availability,
         asgn.search_country_code,
         asgn.search_exp_org_struct_ver_id,
         asgn.search_exp_start_org_id,
         asgn.search_min_candidate_score,
         asgn.COMPETENCE_MATCH_WEIGHTING,
         asgn.AVAILABILITY_MATCH_WEIGHTING,
         asgn.JOB_LEVEL_MATCH_WEIGHTING,
         asgn.ENABLE_AUTO_CAND_NOM_FLAG,
         proj.enable_automated_search
    FROM pa_project_assignments asgn,
         pa_projects_all proj,
         pa_project_statuses ps
   WHERE proj.segment1 BETWEEN nvl(p_project_number_from, proj.segment1) AND nvl(p_project_number_to, proj.segment1)
     -- AND trunc(proj.start_date) BETWEEN decode(p_proj_start_date_days, NULL, proj.start_date, trunc(SYSDATE)) AND decode(p_proj_start_date_days, NULL, proj.start_date, trunc(SYSDATE) + p_proj_start_date_days)
     -- Changed for Bug 5299668
     AND trunc(nvl(proj.start_date, SYSDATE)) BETWEEN
         decode(p_proj_start_date_days, NULL, nvl(proj.start_date, trunc(SYSDATE)), trunc(SYSDATE))
         AND
         decode(p_proj_start_date_days, NULL, nvl(proj.start_date, trunc(SYSDATE)), trunc(SYSDATE) + p_proj_start_date_days)
     AND proj.project_status_code = nvl(p_project_status_code, proj.project_status_code)
     AND proj.project_id = asgn.project_id
     AND trunc(asgn.start_date) BETWEEN decode(p_req_start_date_days, NULL, asgn.start_date, trunc(SYSDATE)) AND decode(p_req_start_date_days, NULL, asgn.start_date, trunc(SYSDATE) + p_req_start_date_days)
     AND asgn.assignment_type='OPEN_ASSIGNMENT'
     AND asgn.status_code = ps.project_status_code (+)
     AND (ps.project_system_status_code= 'OPEN_ASGMT' or ps.project_system_status_code is NULL)
     AND p_auto_search_mode = 'MULTI_PROJECT'
;

   TYPE resource_id_tbl                IS TABLE OF pa_resources_denorm.resource_id%TYPE
      INDEX BY BINARY_INTEGER;
   l_resource_id_tbl                   resource_id_tbl;

   TYPE candidate_id_tbl               IS TABLE OF pa_candidates.candidate_id%TYPE
      INDEX BY BINARY_INTEGER;
   l_candidate_id_tbl                  candidate_id_tbl;

   l_competency_tbl                   PA_HR_COMPETENCE_UTILS.Competency_Tbl_Typ;
   l_min_candidate_score              NUMBER;
   l_no_of_competencies               NUMBER;
   l_error_msg_code                   fnd_new_messages.message_name%TYPE;
   l_return_status                    VARCHAR2(1);
   l_msg_data                         fnd_new_messages.message_text%TYPE;
   l_msg_count                        NUMBER;
   l_is_resource_candidate            VARCHAR2(1);
   l_nomination_comments              fnd_new_messages.message_text%TYPE;
   l_system_nom_candidate_text        fnd_new_messages.message_text%TYPE;
   l_candidates_nom_in_cycle          NUMBER := 0;
   l_req_enable_auto_cand_nom         pa_project_assignments.ENABLE_AUTO_CAND_NOM_FLAG%TYPE;
   l_proj_enable_automated_search     pa_projects_all.enable_automated_search%TYPE;
   l_status_code                      pa_project_statuses.project_status_code%TYPE;
   l_cand_system_status_code          pa_project_statuses.project_system_status_code%TYPE;
   l_candidate_in_rec		      PA_RES_MANAGEMENT_AMG_PUB.CANDIDATE_IN_REC_TYPE; -- Added for bug 9187892

   BEGIN

   IF p_debug_mode = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG,'Parameters are:');
      fnd_file.put_line(FND_FILE.LOG,'p_auto_search_mode = '||p_auto_search_mode);
      fnd_file.put_line(FND_FILE.LOG,'p_project_id = '||p_project_id);
      fnd_file.put_line(FND_FILE.LOG,'p_project_number_from = '||p_project_number_from);
      fnd_file.put_line(FND_FILE.LOG,'p_project_number_to = '||p_project_number_to);
      fnd_file.put_line(FND_FILE.LOG,'p_proj_start_date_days = '||p_proj_start_date_days);
      fnd_file.put_line(FND_FILE.LOG,'p_req_start_date_days = '||p_req_start_date_days);
      fnd_file.put_line(FND_FILE.LOG,'p_project_status_code = '||p_project_status_code);
      fnd_file.put_line(FND_FILE.LOG,'p_debug_mode = '||p_debug_mode);
      fnd_file.put_line(FND_FILE.LOG,'about to open get_auto_search_criteria cursor');
   END IF;

   OPEN get_auto_search_criteria;

   IF p_debug_mode = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG,'Cursor has been opened');
   END IF;

   LOOP

      IF p_debug_mode = 'Y' THEN
         fnd_file.put_line(FND_FILE.LOG,' ');
         fnd_file.put_line(FND_FILE.LOG,'Looping through requirements');
         fnd_file.put_line(FND_FILE.LOG,'about to fetch from cursor');
      END IF;

      FETCH get_auto_search_criteria INTO  PA_SEARCH_GLOB.g_search_criteria.assignment_id,
                                           PA_SEARCH_GLOB.g_search_criteria.project_id,
                                           PA_SEARCH_GLOB.g_search_criteria.min_job_level,
                                           PA_SEARCH_GLOB.g_search_criteria.max_job_level,
                                           PA_SEARCH_GLOB.g_search_criteria.start_date,
                                           PA_SEARCH_GLOB.g_search_criteria.end_date,
                                           PA_SEARCH_GLOB.g_search_criteria.min_availability,
                                           PA_SEARCH_GLOB.g_search_criteria.territory_code,
                                           PA_SEARCH_GLOB.g_search_criteria.org_hierarchy_version_id,
                                           PA_SEARCH_GLOB.g_search_criteria.organization_id,
                                           l_min_candidate_score,
                                           PA_SEARCH_GLOB.g_search_criteria.COMPETENCE_MATCH_WEIGHTING,
                                           PA_SEARCH_GLOB.g_search_criteria.AVAILABILITY_MATCH_WEIGHTING,
                                           PA_SEARCH_GLOB.g_search_criteria.JOB_LEVEL_MATCH_WEIGHTING,
                                           l_req_enable_auto_cand_nom,
                                           l_proj_enable_automated_search
                                           ;

   EXIT WHEN get_auto_search_criteria%NOTFOUND;

   IF p_debug_mode = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG,'record fetched from cursor');
      fnd_file.put_line(FND_FILE.LOG,'fetch from cursor complete');
      fnd_file.put_line(FND_FILE.LOG,'PA_SEARCH_GLOB.g_search_criteria.assignment_id='||PA_SEARCH_GLOB.g_search_criteria.assignment_id);
      fnd_file.put_line(FND_FILE.LOG,'PA_SEARCH_GLOB.g_search_criteria.project_id='||PA_SEARCH_GLOB.g_search_criteria.project_id);
      fnd_file.put_line(FND_FILE.LOG,'PA_SEARCH_GLOB.g_search_criteria.min_job_level='||PA_SEARCH_GLOB.g_search_criteria.min_job_level);
      fnd_file.put_line(FND_FILE.LOG,'PA_SEARCH_GLOB.g_search_criteria.max_job_level='||PA_SEARCH_GLOB.g_search_criteria.max_job_level);
      fnd_file.put_line(FND_FILE.LOG,'PA_SEARCH_GLOB.g_search_criteria.start_date='||PA_SEARCH_GLOB.g_search_criteria.start_date);
      fnd_file.put_line(FND_FILE.LOG,'PA_SEARCH_GLOB.g_search_criteria.end_date='||PA_SEARCH_GLOB.g_search_criteria.end_date);
      fnd_file.put_line(FND_FILE.LOG,'PA_SEARCH_GLOB.g_search_criteria.min_availability='||PA_SEARCH_GLOB.g_search_criteria.min_availability);
      fnd_file.put_line(FND_FILE.LOG,'PA_SEARCH_GLOB.g_search_criteria.territory_code='||PA_SEARCH_GLOB.g_search_criteria.territory_code);
      fnd_file.put_line(FND_FILE.LOG,'PA_SEARCH_GLOB.g_search_criteria.org_hierarchy_version_id='||PA_SEARCH_GLOB.g_search_criteria.org_hierarchy_version_id);
      fnd_file.put_line(FND_FILE.LOG,'PA_SEARCH_GLOB.g_search_criteria.organization_id='||PA_SEARCH_GLOB.g_search_criteria.organization_id);
      fnd_file.put_line(FND_FILE.LOG,'l_min_candidate_score='||l_min_candidate_score);
      fnd_file.put_line(FND_FILE.LOG,'PA_SEARCH_GLOB.g_search_criteria.COMPETENCE_MATCH_WEIGHTING='||PA_SEARCH_GLOB.g_search_criteria.COMPETENCE_MATCH_WEIGHTING);
      fnd_file.put_line(FND_FILE.LOG,'PA_SEARCH_GLOB.g_search_criteria.AVAILABILITY_MATCH_WEIGHTING='||PA_SEARCH_GLOB.g_search_criteria.AVAILABILITY_MATCH_WEIGHTING);
      fnd_file.put_line(FND_FILE.LOG,'PA_SEARCH_GLOB.g_search_criteria.JOB_LEVEL_MATCH_WEIGHTING='||PA_SEARCH_GLOB.g_search_criteria.JOB_LEVEL_MATCH_WEIGHTING);
      fnd_file.put_line(FND_FILE.LOG,'l_req_enable_auto_cand_nom='||l_req_enable_auto_cand_nom);
      fnd_file.put_line(FND_FILE.LOG,'l_proj_enable_automated_search='||l_proj_enable_automated_search);
      fnd_file.put_line(FND_FILE.LOG,'about to call get_competencies API');
   END IF;

        PA_SEARCH_GLOB.g_search_criteria.work_current_loc := 'N';
        PA_SEARCH_GLOB.g_search_criteria.work_all_loc := 'N';
        PA_SEARCH_GLOB.g_search_criteria.travel_domestically := 'N';
        PA_SEARCH_GLOB.g_search_criteria.travel_internationally := 'N';

     -- Assign Provisional Availability to the global record.
     PA_SEARCH_GLOB.g_search_criteria.provisional_availability := 'N';

     -- Make sure that the Requirement is not end-dated

     IF PA_SEARCH_GLOB.g_search_criteria.start_date < SYSDATE AND
        PA_SEARCH_GLOB.g_search_criteria.end_date < SYSDATE THEN
           IF p_debug_mode = 'Y' THEN
              fnd_file.put_line(FND_FILE.LOG,'Ignoring Assignment ID '||PA_SEARCH_GLOB.g_search_criteria.assignment_id ||' because it has been end-dated');
           END IF;

     ELSE -- Only Process non-end-dated assignments

     --get the competencies for the requirement
     l_competency_tbl.delete; -- Added for Bug 3098252
     PA_SEARCH_GLOB.g_competence_criteria.delete; -- Added for Bug 3098252

     PA_HR_COMPETENCE_UTILS.get_competencies(p_object_name => 'OPEN_ASSIGNMENT',
                                             p_object_id => PA_SEARCH_GLOB.g_search_criteria.assignment_id,
                                             x_competency_tbl => l_competency_tbl,
                                             x_no_of_competencies => l_no_of_competencies,
                                             x_error_message_code => l_error_msg_code,
                                             x_return_status => l_return_status);



     IF p_debug_mode = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG,'after call to get_competencies');
        fnd_file.put_line(FND_FILE.LOG,'requirement has '||l_competency_tbl.COUNT||' competencies');
     END IF;

     IF l_competency_tbl.COUNT > 0 THEN

        IF p_debug_mode = 'Y' THEN
           fnd_file.put_line(FND_FILE.LOG,'about to loop through competencies');
        END IF;

        --store the competences in the global comp table.
        FOR i IN l_competency_tbl.FIRST..l_competency_tbl.LAST LOOP

           IF p_debug_mode = 'Y' THEN
              fnd_file.put_line(FND_FILE.LOG,'in competencies loop');
           END IF;

           PA_SEARCH_GLOB.g_competence_criteria(i).competence_id := l_competency_tbl(i).competence_id;
           PA_SEARCH_GLOB.g_competence_criteria(i).competence_alias := l_competency_tbl(i).competence_alias;
           PA_SEARCH_GLOB.g_competence_criteria(i).mandatory_flag := l_competency_tbl(i).mandatory;
           PA_SEARCH_GLOB.g_competence_criteria(i).competence_name := NULL;

           --get the rating level given the id if id is not null
           --and store in global comp table.
           IF l_competency_tbl(i).rating_level_id IS NOT NULL THEN

              IF p_debug_mode = 'Y' THEN
                 fnd_file.put_line(FND_FILE.LOG,'about to get the rating level');
              END IF;

             SELECT step_value INTO PA_SEARCH_GLOB.g_competence_criteria(i).rating_level
               FROM per_rating_levels
              WHERE rating_level_id = l_competency_tbl(i).rating_level_id;

              IF p_debug_mode = 'Y' THEN
                 fnd_file.put_line(FND_FILE.LOG,'got the rating level');
              END IF;
	   ELSE
             PA_SEARCH_GLOB.g_competence_criteria(i).rating_level := NULL;
           END IF;

        END LOOP;

     END IF;

     IF p_debug_mode = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG,'about to clear the global temp tables');
     END IF;

     DELETE FROM pa_search_results_temp;
     DELETE FROM pa_competence_criteria_temp;

     IF p_debug_mode = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG,'done clearing the global temp tables');
        fnd_file.put_line(FND_FILE.LOG,'about to call run search API');
     END IF;

     Run_Search(p_search_mode          =>    'RESOURCE',
                p_search_criteria      =>    PA_SEARCH_GLOB.g_search_criteria,
                p_competence_criteria  =>    PA_SEARCH_GLOB.g_competence_criteria,
                p_commit               =>    FND_API.G_TRUE,
                p_validate_only        =>    FND_API.G_FALSE,
                x_return_status        =>    l_return_status);

     IF p_debug_mode = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG,'done with run_search API');
        fnd_file.put_line(FND_FILE.LOG,'about to bulk collect resources matching search criteria');
     END IF;

     --bulk collect the resources to be nominated
     SELECT resource_id BULK COLLECT INTO l_resource_id_tbl
      FROM pa_search_results_temp
     WHERE candidate_score >= l_min_candidate_score;

     IF p_debug_mode = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG,'done with bulk collect');
        fnd_file.put_line(FND_FILE.LOG,'number of resources returned = '||l_resource_id_tbl.COUNT);
     END IF;

      IF (l_proj_enable_automated_search = 'Y' AND l_req_enable_auto_cand_nom = 'Y') THEN

         IF p_debug_mode = 'Y' THEN
            fnd_file.put_line(FND_FILE.LOG,'auto search is enable for this requirement at the project and requirement level');
         END IF;

         --candidates will be nomimated in this run, so delete any
         --qualified candidates from the requirement.
         IF p_debug_mode = 'Y' THEN
            fnd_file.put_line(FND_FILE.LOG,'about to call API to delete qualified candidates');
         END IF;

         PA_CANDIDATE_PUB.Delete_Candidates
                          (p_assignment_id => PA_SEARCH_GLOB.g_search_criteria.assignment_id,
                           p_status_code   => '114',
                           x_return_status => l_return_status,
                           x_msg_count     => l_msg_count,
                           x_msg_data      => l_msg_data);

         IF p_debug_mode = 'Y' THEN
            fnd_file.put_line(FND_FILE.LOG,'done with call to API to delete qualified candidates');
         END IF;

         l_cand_system_status_code := 'CANDIDATE_SYSTEM_NOMINATED';

      ELSE

         l_cand_system_status_code := 'CANDIDATE_SYSTEM_QUALIFIED';

      END IF;

      --delete the previous system nominated candidates who will NOT
      --be system nominated in current run.

      IF p_debug_mode = 'Y' THEN
         fnd_file.put_line(FND_FILE.LOG,'about to bulk collect the previous system nominated / qualified candidates who will NOT be system nominated in current run.');
      END IF;

      SELECT candidate_id BULK COLLECT INTO l_candidate_id_tbl
        FROM pa_candidates cand,
             pa_project_statuses ps
       WHERE assignment_id = PA_SEARCH_GLOB.g_search_criteria.assignment_id
         AND cand.status_code = ps.project_status_code
         AND ps.status_type = 'CANDIDATE'
         AND ps.project_system_status_code = l_cand_system_status_code
         AND resource_id NOT IN
                        (SELECT resource_id
                           FROM pa_search_results_temp
                          WHERE candidate_score >= l_min_candidate_score)
	      ;

         IF p_debug_mode = 'Y' THEN
            fnd_file.put_line(FND_FILE.LOG,'number of previous system nominated candidates to be deleted = '||l_candidate_id_tbl.COUNT);
         END IF;

         IF l_candidate_id_tbl.COUNT > 0 THEN

            --** add code to LOOP THROUGH l_candidate_id_tbl AND CALL API TO DELETE CANDIDATES
            FOR i IN l_candidate_id_tbl.FIRST .. l_candidate_id_tbl.LAST LOOP

               IF p_debug_mode = 'Y' THEN
                  fnd_file.put_line(FND_FILE.LOG,'looping through candidates in order to delete');
                  fnd_file.put_line(FND_FILE.LOG,'calling withdraw_candidate API to delete candidate id '||l_candidate_id_tbl(i));
               END IF;

               PA_CANDIDATE_PUB.Withdraw_Candidate
                                   (p_candidate_id  =>  l_candidate_id_tbl(i),
                                    x_return_status =>  l_return_status,
                                    x_msg_count     =>  l_msg_count,
                                    x_msg_data      =>  l_msg_data);

               IF p_debug_mode = 'Y' THEN
                  fnd_file.put_line(FND_FILE.LOG,'after call to withdraw_candidate');
               END IF;

            END LOOP;

         END IF;


         IF p_debug_mode = 'Y' THEN
            fnd_file.put_line(FND_FILE.LOG,'about to nominate candidates or qualified candidates');
         END IF;


         IF l_resource_id_tbl.COUNT > 0 THEN

            IF p_debug_mode = 'Y' THEN
               fnd_file.put_line(FND_FILE.LOG,'there are candidates or qualified candidates to be nominated');
            END IF;

            FOR i IN l_resource_id_tbl.FIRST .. l_resource_id_tbl.LAST LOOP

               IF p_debug_mode = 'Y' THEN
                  fnd_file.put_line(FND_FILE.LOG,'in loop:  resource_id to be nominated = '||l_resource_id_tbl(i));
               END IF;

                  IF (l_proj_enable_automated_search = 'Y' AND l_req_enable_auto_cand_nom = 'Y') THEN

                     IF p_debug_mode = 'Y' THEN
                        fnd_file.put_line(FND_FILE.LOG,'auto search is enable for this requirement at the project and requirement level');
                     END IF;

                     IF l_system_nom_candidate_text IS NULL THEN

                        IF p_debug_mode = 'Y' THEN
                           fnd_file.put_line(FND_FILE.LOG,'about to get system nominated candidate text');
                        END IF;
/* 2590651 - Added two conditions for application id and language code for the
query from fnd_new_messages below */

                        SELECT message_text INTO l_system_nom_candidate_text
                          FROM fnd_new_messages
                         WHERE message_name = 'PA_SYSTEM_NOMINATED_CANDIDATE'
                           and application_id = 275
                           and language_code = userenv('LANG');

                        IF p_debug_mode = 'Y' THEN
                          fnd_file.put_line(FND_FILE.LOG,'got system nominated candidate text');
                        END IF;

                     END IF;

                     l_nomination_comments := l_system_nom_candidate_text;
                     l_status_code := '113';

                  ELSE
                     IF p_debug_mode = 'Y' THEN
                        fnd_file.put_line(FND_FILE.LOG,'auto search is NOT enabled for this requirement - nominate as qualified canidate');
                     END IF;
                     l_nomination_comments := NULL;
                     l_status_code := '114';
                  END IF;

                  --nominate the resource
                  IF p_debug_mode = 'Y' THEN
                     fnd_file.put_line(FND_FILE.LOG,'about to call Add_candidate API');
                     fnd_file.put_line(FND_FILE.LOG,'nominate resource '||l_resource_id_tbl(i)||' for assignment '||PA_SEARCH_GLOB.g_search_criteria.assignment_id|| ' on project '||PA_SEARCH_GLOB.g_search_criteria.project_id);
                  END IF;

                  --add candidate API will
                  --when I nominate as candidate:
                  --  do nothing if resource is already a CANDIDATE - any status
                  --  change status to system nominated if resource is already qualified candidate
                  --  else nominate as system nominated candidate
                  --when I nominate as qualified candidate
                  --  do nothing if resource is already a CANDIDATE - any status
                  --  do nothing if resource is already a qualified candidate
                  --  else nominate as qualified candidate

                  PA_CANDIDATE_PUB.Add_Candidate(
                              p_assignment_id         => PA_SEARCH_GLOB.g_search_criteria.assignment_id,
                              p_resource_name         => NULL,
                              p_resource_id           => l_resource_id_tbl(i),
                              p_status_code           => l_status_code, --**need to change to the system nominated status code when it is entered in SEED.
                              p_nomination_comments   => l_nomination_comments,
  		              -- Added for bug 9187892
                              p_attribute_category    => l_candidate_in_rec.attribute_category,
                              p_attribute1            => l_candidate_in_rec.attribute1,
                              p_attribute2            => l_candidate_in_rec.attribute2,
                              p_attribute3            => l_candidate_in_rec.attribute3,
                              p_attribute4            => l_candidate_in_rec.attribute4,
                              p_attribute5            => l_candidate_in_rec.attribute5,
                              p_attribute6            => l_candidate_in_rec.attribute6,
                              p_attribute7            => l_candidate_in_rec.attribute7,
                              p_attribute8            => l_candidate_in_rec.attribute8,
                              p_attribute9            => l_candidate_in_rec.attribute9,
                              p_attribute10           => l_candidate_in_rec.attribute10,
                              p_attribute11           => l_candidate_in_rec.attribute11,
                              p_attribute12           => l_candidate_in_rec.attribute12,
                              p_attribute13           => l_candidate_in_rec.attribute13,
                              p_attribute14           => l_candidate_in_rec.attribute14,
                              p_attribute15           => l_candidate_in_rec.attribute15,
                              x_return_status         => l_return_status,
                              x_msg_count             => l_msg_count,
                              x_msg_data              => l_msg_data);

                  IF p_debug_mode = 'Y' THEN
                     fnd_file.put_line(FND_FILE.LOG,'after call to Add_candidate API');
                     fnd_file.put_line(FND_FILE.LOG,'x_return_status = '||l_return_status);
                  END IF;

                  l_candidates_nom_in_cycle := l_candidates_nom_in_cycle + 1;

                  IF p_debug_mode = 'Y' THEN
                     fnd_file.put_line(FND_FILE.LOG,'candidates/qualified candidates nominated in this cycle = '||l_candidates_nom_in_cycle);
                  END IF;

            END LOOP;

         END IF;

         IF p_debug_mode = 'Y' THEN
            fnd_file.put_line(FND_FILE.LOG,'about to update last_auto_search_date for assignment id = '||PA_SEARCH_GLOB.g_search_criteria.assignment_id);
         END IF;

         --stamp the date/time on the run on the requirement record
         UPDATE PA_PROJECT_ASSIGNMENTS
            SET last_auto_search_date = SYSDATE
          WHERE assignment_id = PA_SEARCH_GLOB.g_search_criteria.assignment_id;

         IF p_debug_mode = 'Y' THEN
            fnd_file.put_line(FND_FILE.LOG,'after updating last_auto_search_date for assignment id = '||PA_SEARCH_GLOB.g_search_criteria.assignment_id);
         END IF;

      IF l_candidates_nom_in_cycle > 100 THEN

         IF p_debug_mode = 'Y' THEN
            fnd_file.put_line(FND_FILE.LOG,'about to COMMIT');
         END IF;

         COMMIT;

         IF p_debug_mode = 'Y' THEN
            fnd_file.put_line(FND_FILE.LOG,'COMMIT complete');
         END IF;

         l_candidates_nom_in_cycle := 0;

      END IF;
      END IF; -- end-dated requirements check.

      END LOOP;

     CLOSE get_auto_search_criteria;

   IF p_debug_mode = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG,'about to COMMIT');
   END IF;

   COMMIT;

   IF p_debug_mode = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG,'COMMIT complete');
   END IF;

   retcode := '0';

   EXCEPTION
      WHEN OTHERS THEN
         errbuf := SUBSTR(SQLERRM,1,240);
         retcode := '2';
         fnd_file.put_line(FND_FILE.LOG,'in when others exception block');
         fnd_file.put_line(FND_FILE.LOG,SUBSTR(SQLERRM,1,240));

   END Run_Auto_Search;


END PA_SEARCH_PVT;

/

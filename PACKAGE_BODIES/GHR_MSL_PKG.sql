--------------------------------------------------------
--  DDL for Package Body GHR_MSL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_MSL_PKG" AS
/* $Header: ghmslexe.pkb 120.21.12010000.4 2009/03/19 12:16:59 vmididho ship $ */

g_no number := 0;
g_package  varchar2(32) := 'GHR_MSL_PKG';
g_proc     varchar2(72) := null;
g_effective_date  date;
g_rg_recs_failed  NUMBER := 0;

-- Bug#5063304
l_log_text varchar2(2000) := null;
l_mslerrbuf   varchar2(2000) := null;
--l_errbuf   varchar2(2000) := null;

PROCEDURE execute_msl (p_errbuf out nocopy varchar2,
                       p_retcode out nocopy number,
                       p_mass_salary_id in number,
                       p_action in varchar2 ) is
                       --p_bus_grp_id in number) IS

p_mass_salary varchar2(32);

--
--
-- Main Cursor which fetches from per_assignments_f and per_people_f
--
/***** Splitting the cursor into two for better performance
 ***** 1. First eliminate the check of assignment_status_type_id in the cursor and have outside.
 ***** 2. One cursor as organization as not null
 ***** 3. One cursor as organization is null (One FTS will be there because
 *****    the system should search the entire database.)

cursor cur_people (effective_date date, p_org_id number) is
select ppf.person_id    PERSON_ID,
       ppf.first_name   FIRST_NAME,
       ppf.last_name    LAST_NAME,
       ppf.middle_names MIDDLE_NAMES,
       ppf.full_name    FULL_NAME,
       ppf.date_of_birth DATE_OF_BIRTH,
       ppf.national_identifier NATIONAL_IDENTIFIER,
       paf.position_id  POSITION_ID,
       paf.assignment_id ASSIGNMENT_ID,
       paf.grade_id     GRADE_ID,
       paf.job_id       JOB_ID,
       paf.location_id  LOCATION_ID,
       paf.organization_id ORGANIZATION_ID,
       paf.business_group_id BUSINESS_GROUP_ID
  from per_assignments_f   paf,
       per_people_f        ppf,
       per_person_types    ppt,
       per_assignment_status_types pas_t
 where ppf.person_id    = paf.person_id
   and paf.primary_flag = 'Y'
   and paf.assignment_type <> 'B'
   and paf.assignment_status_type_id = pas_t.assignment_status_type_id
   and pas_t.user_status not in (
                         'Terminate Assignment',
                         'Active Application',
                         'Offer',
                         'Accepted',
                         'Terminate Application',
                         'End',
                         'Terminate Appointment',
                         'Separated')
   and effective_date between paf.effective_start_date
             and nvl(paf.effective_end_date,effective_date+1)
   and ppf.person_type_id = ppt.person_type_id
   and ppt.system_person_type = 'EMP'
   and effective_date between ppf.effective_start_date
             and nvl(ppf.effective_end_date,effective_date+1)
-- VSM. Enhancements [Masscrit.doc] Organization can be null
   and paf.organization_id + 0 = nvl(p_org_id, paf.organization_id)
   and paf.position_id is not null
   order by ppf.person_id; -- 3539816 Order by added to prevent snapshot old error
****/
---
--- Bug  3539816 Order by added to prevent snapshot old error
--- 1. Cursor with organization.
---
CURSOR cur_people_org (effective_date date, p_org_id number) IS
SELECT ppf.person_id                 PERSON_ID,
       ppf.first_name                FIRST_NAME,
       ppf.last_name                 LAST_NAME,
       ppf.middle_names              MIDDLE_NAMES,
       ppf.full_name                 FULL_NAME,
       ppf.date_of_birth             DATE_OF_BIRTH,
       ppf.national_identifier       NATIONAL_IDENTIFIER,
       paf.position_id               POSITION_ID,
       paf.assignment_id             ASSIGNMENT_ID,
       paf.grade_id                  GRADE_ID,
       paf.job_id                    JOB_ID,
       paf.location_id               LOCATION_ID,
       paf.organization_id           ORGANIZATION_ID,
       paf.business_group_id         BUSINESS_GROUP_ID,
       paf.assignment_status_type_id ASSIGNMENT_STATUS_TYPE_ID
  FROM per_assignments_f   paf,
       per_people_f        ppf,
       per_person_types    ppt
 WHERE ppf.person_id           = paf.person_id
   AND effective_date between ppf.effective_start_date and ppf.effective_end_date
   AND effective_date between paf.effective_start_date and paf.effective_end_date
   AND paf.primary_flag        = 'Y'
   AND paf.assignment_type     <> 'B'
   AND ppf.person_type_id      = ppt.person_type_id
   AND ppt.system_person_type  IN ('EMP','EMP_APL')
   AND paf.organization_id     = p_org_id
   AND paf.position_id is not null
   ORDER BY ppf.person_id;


---
--- Bug  3539816 Order by added to prevent snapshot old error
--- 2. Cursor with no organization.
---
--- This SQL is tuned by joining the hr_organization_units to avoid the FTS of PAF.
--- Bug 6152582
---
CURSOR cur_people (effective_date date) IS
SELECT ppf.person_id                 PERSON_ID,
       ppf.first_name                FIRST_NAME,
       ppf.last_name                 LAST_NAME,
       ppf.middle_names              MIDDLE_NAMES,
       ppf.full_name                 FULL_NAME,
       ppf.date_of_birth             DATE_OF_BIRTH,
       ppf.national_identifier       NATIONAL_IDENTIFIER,
       paf.position_id               POSITION_ID,
       paf.assignment_id             ASSIGNMENT_ID,
       paf.grade_id                  GRADE_ID,
       paf.job_id                    JOB_ID,
       paf.location_id               LOCATION_ID,
       paf.organization_id           ORGANIZATION_ID,
       paf.business_group_id         BUSINESS_GROUP_ID,
       paf.assignment_status_type_id ASSIGNMENT_STATUS_TYPE_ID
  FROM per_assignments_f   paf,
       per_people_f        ppf,
       per_person_types    ppt,
       hr_organization_units hou
 WHERE ppf.person_id           = paf.person_id
   AND effective_date between ppf.effective_start_date and ppf.effective_end_date
   AND effective_date between paf.effective_start_date and paf.effective_end_date
   AND paf.primary_flag        = 'Y'
   AND paf.assignment_type     <> 'B'
   AND ppf.person_type_id      = ppt.person_type_id
   AND ppt.system_person_type  IN ('EMP','EMP_APL')
   AND paf.organization_id     = hou.organization_id
   AND paf.position_id is not null
   ORDER BY ppf.person_id;
--
-- Check assignment_status_type
--

CURSOR cur_ast (asg_status_type_id number) IS
SELECT user_status from per_assignment_status_types
WHERE assignment_status_type_id = asg_status_type_id
  AND upper(user_status) not in (
                         'TERMINATE ASSIGNMENT',           /* 3 */
                         'ACTIVE APPLICATION',             /* 4 */
                         'OFFER',                          /* 5 */
                         'ACCEPTED',                       /* 6 */
                         'TERMINATE APPLICATION',          /* 7 */
                         'END',                            /* 8 */
                         'TERMINATE APPOINTMENT',          /* 126 */
                         'SEPARATED');                     /* 132 */

--
-- Cursor to select from GHR_MASS_SALARIES - Where criteria is stored
-- Before executing this package
-- from ghr_mass_salary_criteria
--

cursor ghr_msl (p_msl_id number) is
select name, effective_date, mass_salary_id, user_table_id, submit_flag,
       executive_order_number, executive_order_date, ROWID, PA_REQUEST_ID,
       ORGANIZATION_ID, DUTY_STATION_ID, PERSONNEL_OFFICE_ID,
       AGENCY_CODE_SUBELEMENT, OPM_ISSUANCE_NUMBER, OPM_ISSUANCE_DATE, PROCESS_TYPE
  from ghr_mass_salaries
 where MASS_SALARY_ID = p_msl_id
   for update of user_table_id nowait;

-- VSM [family name was hardcoded previously to SALARY_CHG. Fetching it from DB now]
cursor get_sal_chg_fam is
select NOA_FAMILY_CODE
from ghr_families
where NOA_FAMILY_CODE in
    (select NOA_FAMILY_CODE from ghr_noa_families
         where  nature_of_action_id =
            (select nature_of_action_id
             from ghr_nature_of_actions
             where code = '894')
    ) and proc_method_flag = 'Y';    --AVR 13-JAN-99
 -------------   ) and update_hr_flag = 'Y';

l_assignment_id        per_assignments_f.assignment_id%type;
l_position_id          per_assignments_f.position_id%type;
l_grade_id             per_assignments_f.grade_id%type;
l_business_group_id    per_assignments_f.business_group_id%type;

l_position_title       varchar2(300);
l_position_number      varchar2(20);
l_position_seq_no      varchar2(20);

l_msl_cnt              number := 0;
l_recs_failed          number := 0;

l_tenure               varchar2(35);
l_annuitant_indicator  varchar2(35);
l_pay_rate_determinant varchar2(35);
l_work_schedule        varchar2(35);
l_part_time_hour       varchar2(35);
l_pay_table_id         number;
l_pay_plan             varchar2(30);
l_grade_or_level       varchar2(30);
-- Bug#5089732 Added current pay plan, grade_or_level
l_to_grade_id          number;
l_to_pay_plan          varchar2(30);
l_to_grade_or_level    varchar2(30);
-- Bug#5089732
l_step_or_rate         varchar2(30);
l_pay_basis            varchar2(30);
l_location_id          number;
l_duty_station_id      number;
l_duty_station_desc    ghr_pa_requests.duty_station_desc%type;
l_duty_station_code    ghr_pa_requests.duty_station_code%type;
l_effective_date       date;
l_personnel_office_id  varchar2(300);
l_org_structure_id     varchar2(300);
l_sub_element_code     varchar2(300);

l_old_basic_pay        number;
l_old_avail_pay        number;
l_old_loc_diff         number;
l_tot_old_sal          number;
l_old_auo_pay          number;
l_old_ADJ_basic_pay    number;
l_other_pay            number;


l_auo_premium_pay_indicator     varchar2(30);
l_ap_premium_pay_indicator      varchar2(30);
l_retention_allowance           number;
l_retention_allow_perc          number;     ---AVR
l_new_retention_allowance       number;     ---AVR
l_supervisory_differential      number;
l_supervisory_diff_perc         number;     ---AVR
l_new_supervisory_differential  number;     ---AVR
l_staffing_differential         number;

l_new_avail_pay             number;
l_new_loc_diff              number;
l_tot_new_sal               number;
l_new_auo_pay               number;

l_new_basic_pay             number;
l_new_locality_adj          number;
l_new_adj_basic_pay         number;
l_new_total_salary          number;
l_new_other_pay_amount      number;
l_new_au_overtime           number;
l_new_availability_pay      number;
l_out_step_or_rate          varchar2(30);
l_out_pay_rate_determinant  varchar2(30);
l_out_pay_plan              varchar2(30);
l_out_grade_id              number;
l_out_grade_or_level        varchar2(30);

l_PT_eff_start_date         date;
l_open_pay_fields           boolean;
l_message_set               boolean;
l_calculated                boolean;

l_mass_salary_id            number;
l_user_table_id             number;
l_submit_flag               varchar2(2);
l_executive_order_number    ghr_mass_salaries.executive_order_number%TYPE;
l_executive_order_date      ghr_mass_salaries.executive_order_date%TYPE;
l_opm_issuance_number       ghr_mass_salaries.opm_issuance_number%TYPE;
l_opm_issuance_date         ghr_mass_salaries.opm_issuance_date%TYPE;
l_pa_request_id             number;
l_rowid                     varchar2(30);

l_p_ORGANIZATION_ID           number;
l_p_DUTY_STATION_ID           number;
l_p_PERSONNEL_OFFICE_ID       varchar2(5);

L_row_cnt                   number := 0;

l_sf52_rec                  ghr_pa_requests%rowtype;
l_lac_sf52_rec              ghr_pa_requests%rowtype;
l_errbuf                    varchar2(2000);

l_retcode                   number;

l_pos_ei_data               per_position_extra_info%rowtype;
l_pos_grp1_rec              per_position_extra_info%rowtype;

l_pay_calc_in_data          ghr_pay_calc.pay_calc_in_rec_type;
l_pay_calc_out_data         ghr_pay_calc.pay_calc_out_rec_type;
l_sel_flg                   varchar2(2);

l_first_action_la_code1     varchar2(30);
l_first_action_la_code2     varchar2(30);

l_remark_code1              varchar2(30);
l_remark_code2              varchar2(30);
l_p_AGENCY_CODE_SUBELEMENT       varchar2(30);

----Pay cap variables
l_entitled_other_pay        NUMBER;
l_capped_other_pay          NUMBER;
l_adj_basic_message         BOOLEAN  := FALSE;
l_pay_cap_message           BOOLEAN  := FALSE;
l_temp_retention_allowance  NUMBER;
l_open_pay_fields_caps      BOOLEAN;
l_message_set_caps          BOOLEAN;
l_total_pay_check           VARCHAR2(1);
l_comment                   VARCHAR2(150);
l_comment_sal               VARCHAR2(150);
-- Bug#3968005 Commented l_pay_sel as it is not required.
-- l_pay_sel                   VARCHAR2(1) := NULL;
l_old_capped_other_pay     NUMBER;

-- Bug#5063304
l_elig_flag        BOOLEAN := FALSE;
----
REC_BUSY                    exception;
pragma exception_init(REC_BUSY,-54);

l_proc  varchar2(72) :=  g_package || '.execute_msl';

-- Bug#5063304 Moved the following cursor, variable declaration
-- from execute_msl.
CURSOR c_pay_tab_essl IS
SELECT 1 from pay_user_tables
 WHERE substr(user_table_name,1,4) = 'ESSL'
   AND user_table_id = l_user_table_id;

l_essl_table  BOOLEAN := FALSE;
l_org_name	hr_organization_units.name%type;

-- Bug 3315432 Madhuri
--
CURSOR cur_pp_prd(p_msl_id ghr_mass_salary_criteria.mass_salary_id%type)
IS
SELECT pay_plan ,pay_rate_determinant prd
FROM   ghr_mass_salary_criteria
WHERE  mass_salary_id=p_msl_id;


rec_pp_prd	pp_prd;
l_index         NUMBER:=1;
l_cnt           NUMBER;
l_process_type  ghr_mass_salaries.process_type%TYPE;
--
--
-- Local procedure msl_process
--

--
-- GPPA Update 46
--
cursor cur_eq_ppl (c_pay_plan ghr_pay_plans.pay_plan%type)
IS
select EQUIVALENT_PAY_PLAN
from ghr_pay_plans
where pay_plan = c_pay_plan;

l_eq_pay_plan ghr_pay_plans.equivalent_pay_plaN%type;

--
--

PROCEDURE msl_process( p_assignment_id  per_assignments_f.assignment_id%TYPE
							 ,p_person_id per_assignments_f.person_id%TYPE
							 ,p_position_id  per_assignments_f.position_id%TYPE
							 ,p_grade_id per_assignments_f.grade_id%TYPE
							 ,p_business_group_id per_assignments_f.business_group_iD%TYPE
							 ,p_location_id per_assignments_f.location_id%TYPE
							 ,p_organization_id per_assignments_f.organization_id%TYPE
							 ,p_date_of_birth date
							 ,p_first_name per_people_f.first_name%TYPE
							 ,p_last_name per_people_f.last_name%TYPE
                             ,p_full_name per_people_f.full_name%TYPE
                             ,p_middle_names per_people_f.middle_names%TYPE
							 ,p_national_identifier per_people_f.national_identifier%TYPE
                             ,p_personnel_office_id IN VARCHAR2
                             ,p_org_structure_id    IN VARCHAR2
                             ,p_position_title      IN VARCHAR2
                             ,p_position_number     IN VARCHAR2
                             ,p_position_seq_no     IN VARCHAR2
                             ,p_subelem_code        IN VARCHAR2
                             ,p_duty_station_id     IN ghr_duty_stations_f.duty_station_id%TYPE
                             ,p_tenure              IN VARCHAR2
                             ,p_annuitant_indicator IN VARCHAR2
                             ,p_pay_rate_determinant IN VARCHAR2
                             ,p_work_schedule       IN  VARCHAR2
                             ,p_part_time_hour      IN VARCHAR2
                             ,p_to_grade_id         IN per_assignments_f.grade_id%type
                             ,p_pay_plan            IN VARCHAR2
                             ,p_to_pay_plan         IN VARCHAR2
                             ,p_pay_table_id        IN NUMBER
                             ,p_grade_or_level      IN VARCHAR2
                             ,p_to_grade_or_level   IN VARCHAR2
                             ,p_step_or_rate        IN VARCHAR2
                             ,p_pay_basis           IN VARCHAR2
							)	IS
        -- Bug3437354
        CURSOR cur_valid_DS(p_ds_id NUMBER)
            IS
            SELECT effective_end_date  end_date
            FROM   ghr_duty_stations_f
            WHERE  duty_station_id=p_ds_id
            AND    g_effective_date between effective_start_date and effective_end_date;

            l_ds_end_date	  ghr_duty_stations_f.effective_end_date%type;

BEGIN
      savepoint execute_msl_sp;
         l_msl_cnt := l_msl_cnt +1;
	 --Bug#3968005 Initialised l_sel_flg
         l_sel_flg := NULL;
         l_pay_calc_in_data  := NULL;
         l_pay_calc_out_data := NULL;

       l_assignment_id     := p_assignment_id;
       l_position_id       := p_position_id;
       l_grade_id          := p_grade_id;
       l_business_group_id := p_business_group_iD;
       l_location_id       := p_location_id;
       -- Bug#5063304
        l_personnel_office_id  := p_personnel_office_id;
        l_org_structure_id     := p_org_structure_id;
        l_position_title       := p_position_title;
        l_position_number      := p_position_number;
        l_position_seq_no      := p_position_seq_no;
        l_sub_element_code     := p_subelem_code;
        l_duty_station_id      := p_duty_station_id;
        l_tenure               := p_tenure;
        l_annuitant_indicator  := p_annuitant_indicator;
        l_pay_rate_determinant := p_pay_rate_determinant;
        l_work_schedule        := P_work_schedule;
        l_part_time_hour       := p_part_time_hour;
        l_to_grade_id          := p_to_grade_id;
        l_pay_plan             := p_pay_plan;
        l_to_pay_plan          := p_to_pay_plan;
        l_pay_table_id         := p_pay_table_id;
        l_grade_or_level       := p_grade_or_level;
        l_to_grade_or_level    := p_to_grade_or_level;
        l_step_or_rate         := P_step_or_rate;
        l_pay_basis            := p_pay_basis;
	    hr_utility.set_location('The location id is:'||l_location_id,1);

--------GPPA Update 46 start
            ghr_msl_pkg.g_first_noa_code := NULL;
            FOR cur_eq_ppl_rec IN cur_eq_ppl(l_pay_plan)
            LOOP
                l_eq_pay_plan   := cur_eq_ppl_rec.EQUIVALENT_PAY_PLAN;
                exit;
            END LOOP;
            if l_effective_date >= to_date('2007/01/07','YYYY/MM/DD') AND
               l_eq_pay_plan = 'GS' AND
               l_lac_sf52_rec.first_action_la_code1 = 'QLP' AND
               l_lac_sf52_rec.first_action_la_code2 = 'ZLM' THEN

               ghr_msl_pkg.g_first_noa_code := '890';

            end if;
            if l_effective_date >= to_date('2007/01/07','YYYY/MM/DD') AND
               l_eq_pay_plan = 'FW' AND
               l_lac_sf52_rec.first_action_la_code1 = 'RJR' THEN

               ghr_msl_pkg.g_first_noa_code := '890';

            end if;
--------GPPA Update 46 end

        g_proc := 'Location Validation';
        -- Start of Bug3437354
        IF l_location_id IS NULL THEN
            l_mslerrbuf := ' Error: No valid Location found, salary cannot be calculated correctly'||
                               ' without the employee''s duty location. ';
                RAISE msl_error;
        END IF;

        g_proc := 'Duty Station Validation';
        IF l_duty_station_id IS NOT NULL THEN

            --
            -- Added this condition for bug 3437354, error out the record without valid Loc id
            --
            FOR rec_ds in cur_valid_ds(l_duty_station_id)
            LOOP
                l_ds_end_date	:= rec_ds.end_Date;
            END LOOP;
            IF l_ds_end_date IS NULL THEN
                hr_utility.set_location('Under DS null check'||l_duty_station_id, 1);
                l_mslerrbuf := ' Error: Duty Station associated with the location is INVALID. '||
                               'Salary cannot be calculated correctly without valid duty station. ';
                RAISE msl_error;
            END IF;

        END IF;
        -- End of bug 3437354

       /*    -- BEGIN
              ghr_pa_requests_pkg.get_SF52_loc_ddf_details
                  (p_location_id      => l_location_id
                  ,p_duty_station_id  => l_duty_station_id);
           /  *exception
              when others then
                 hr_utility.set_location(
                 'Error in Ghr_pa_requests_pkg.get_sf52_loc_ddf_details'||
                       'Err is '||sqlerrm(sqlcode),20);
                 l_mslerrbuf := 'Error in get_sf52_loc_ddf_details '||
                       'Sql Err is '|| sqlerrm(sqlcode);
                 raise msl_error;
           end;*  /



       get_pos_grp1_ddf(l_position_id,
                        l_effective_date,
                        l_pos_grp1_rec);

       l_personnel_office_id :=  l_pos_grp1_rec.poei_information3;
       l_org_structure_id    :=  l_pos_grp1_rec.poei_information5;

       get_sub_element_code_pos_title(l_position_id,
                                     p_person_id,
                                     l_business_group_id,
                                     l_assignment_id,
                                     l_effective_date,
                                     l_sub_element_code,
                                     l_position_title,
                                     l_position_number,
                                     l_position_seq_no);

	hr_utility.set_location('The duty station id is:'||l_duty_station_id,12345);

       if check_init_eligibility(l_p_duty_station_id,
                              l_p_PERSONNEL_OFFICE_ID,
                              l_p_AGENCY_CODE_SUBELEMENT,
                              l_duty_station_id,
                              l_personnel_office_id,
                              l_sub_element_code) then

		   hr_utility.set_location('check_init_eligibility    ' || l_proc,6);
		-- Bug 3457205 Filter the Pay plan table id condition also b4 checking any other thing
		-- Moving check_eligibility to here.
			-- Get PRD, work schedule etc form ASG EI
			 begin
				ghr_pa_requests_pkg.get_sf52_asg_ddf_details
						  (l_assignment_id,
						   l_effective_date,
						   l_tenure,
						   l_annuitant_indicator,
						   l_pay_rate_determinant,
						   l_work_schedule,
						   l_part_time_hour);
			 exception
				when others then
					hr_utility.set_location('Error in Ghr_pa_requests_pkg.get_sf52_asg_ddf_details'||
							  'Err is '||sqlerrm(sqlcode),20);
					l_mslerrbuf := 'Error in get_sf52_asgddf_details Sql Err is '|| sqlerrm(sqlcode);
					raise msl_error;
			 end;

-- Bug 3315432 Madhuri
--
        FOR l_cnt in 1..rec_pp_prd.COUNT LOOP

---Bug 3327999 First filter the PRD. Then check for Pay plan and Pay table ID
		IF nvl(rec_pp_prd(l_cnt).prd,l_pay_rate_determinant) = l_pay_rate_determinant THEN
		-- Get Pay table ID and other details
           BEGIN
           -- Bug#5089732 Used the overloaded procedure.
                        get_pay_plan_and_table_id
                          (l_pay_rate_determinant,p_person_id,
                           l_position_id,l_effective_date,
                           l_grade_id, l_to_grade_id,l_assignment_id,'SHOW',
                           l_pay_plan,l_to_pay_plan,l_pay_table_id,
                           l_grade_or_level, l_to_grade_or_level, l_step_or_rate,
                           l_pay_basis);
           EXCEPTION
               when msl_error then
 		           l_mslerrbuf := hr_utility.get_message;
                   raise;
           END;

		IF ( nvl(rec_pp_prd(l_cnt).pay_plan,l_pay_plan) = l_pay_plan
			and l_user_table_id = nvl(l_pay_table_id,l_user_table_id) ) THEN

			IF check_eligibility(l_mass_salary_id,
                               l_user_table_id,
                               l_pay_table_id,
                               l_pay_plan,
                               l_pay_rate_determinant,
                               p_person_id,
                               l_effective_date,
                               p_action) THEN
                hr_utility.set_location('check_eligibility    ' || l_proc,8);   */
                -- Bug#5063304 Moved this call outside check_init_eligibility condition to
                --             this location.
                -- BUG 3377958 Madhuri
                -- Pick the organization name
                g_proc := 'Fetch Organization Name';
                l_org_name :=GHR_MRE_PKG.GET_ORGANIZATION_NAME(P_ORGANIZATION_ID);
                -- BUG 3377958 Madhuri
			IF upper(p_action) = 'REPORT' AND l_submit_flag = 'P' THEN
		 	 -- BUG 3377958 Madhuri
 			    pop_dtls_from_pa_req(p_person_id,l_effective_date,l_mass_salary_id,l_org_name);
 		    	 -- BUG 3377958 Madhuri
			 ELSE
			   if check_select_flg(p_person_id,upper(p_action),
									l_effective_date,p_mass_salary_id,l_sel_flg) then

				   hr_utility.set_location('check_select_flg    ' || l_proc,7);
                   BEGIN
					hr_utility.set_location('The duty station name is:'||l_duty_station_code,12345);
					hr_utility.set_location('The duty station desc is:'||l_duty_station_desc,12345);
		            ghr_pa_requests_pkg.get_duty_station_details
                       (p_duty_station_id        => l_duty_station_id
                       ,p_effective_date        => l_effective_date
                       ,p_duty_station_code        => l_duty_station_code
                       ,p_duty_station_desc        => l_duty_station_desc);
                  EXCEPTION
                     WHEN others THEN
                        hr_utility.set_location('Error in Ghr_pa_requests_pkg.get_duty_station_details'||
                               'Err is '||sqlerrm(sqlcode),20);
                        l_mslerrbuf := 'Error in get_duty_station_details Sql Err is '|| sqlerrm(sqlcode);
                        RAISE msl_error;

                  END;

                     get_other_dtls_for_rep(l_pay_rate_determinant,
                                     l_executive_order_number,
                                     to_char(l_executive_order_date),
                                     l_first_action_la_code1,
                                     l_first_action_la_code2,
                                     l_remark_code1,
                                     l_remark_code2);

                     get_from_sf52_data_elements
                            (l_assignment_id,  l_effective_date,
                             l_old_basic_pay, l_old_avail_pay,
                             l_old_loc_diff, l_tot_old_sal,
                             l_old_auo_pay, l_old_adj_basic_pay,
                             l_other_pay, l_auo_premium_pay_indicator,
                             l_ap_premium_pay_indicator,
                             l_retention_allowance,
                             l_retention_allow_perc,
                             l_supervisory_differential,
                             l_supervisory_diff_perc,
                             l_staffing_differential);





                  l_pay_calc_in_data.person_id          := p_person_id;
                  l_pay_calc_in_data.position_id              := l_position_id;
                  --l_pay_calc_in_data.noa_family_code          := 'SALARY_CHG';
                  l_pay_calc_in_data.noa_family_code          := 'GHR_SAL_PAY_ADJ';
                  l_pay_calc_in_data.noa_code                 := nvl(g_first_noa_code,'894');
                  l_pay_calc_in_data.second_noa_code          := null;
                  l_pay_calc_in_data.first_action_la_code1    := l_lac_sf52_rec.first_action_la_code1;
                  l_pay_calc_in_data.effective_date           := l_effective_date;
                  l_pay_calc_in_data.pay_rate_determinant     := l_pay_rate_determinant;
                  l_pay_calc_in_data.pay_plan                 := l_pay_plan;
                  l_pay_calc_in_data.grade_or_level           := l_grade_or_level;
                  l_pay_calc_in_data.step_or_rate             := l_step_or_rate;
                  l_pay_calc_in_data.pay_basis                := l_pay_basis;
                  l_pay_calc_in_data.user_table_id            := l_pay_table_id;
                  l_pay_calc_in_data.duty_station_id          := l_duty_station_id;
                  l_pay_calc_in_data.auo_premium_pay_indicator := l_auo_premium_pay_indicator;
                  l_pay_calc_in_data.ap_premium_pay_indicator  := l_ap_premium_pay_indicator;
                  l_pay_calc_in_data.retention_allowance       := l_retention_allowance;
                  l_pay_calc_in_data.to_ret_allow_percentage   := l_retention_allow_perc;
                  l_pay_calc_in_data.supervisory_differential  := l_supervisory_differential;
                  l_pay_calc_in_data.staffing_differential    := l_staffing_differential;
                  l_pay_calc_in_data.current_basic_pay        := l_old_basic_pay;
               --Bug 6340584
                  l_pay_calc_in_data.open_out_locality_adj    := l_old_loc_diff;
               --
                  l_pay_calc_in_data.current_adj_basic_pay    := l_old_adj_basic_pay;
                  l_pay_calc_in_data.current_step_or_rate     := l_step_or_rate;
                  l_pay_calc_in_data.pa_request_id            := null;

                  ghr_msl_pkg.g_ses_msl_process              := 'N';

                 IF l_pay_plan in ('ES','EP','IE','FE') and l_essl_table THEN
                     ghr_msl_pkg.g_ses_msl_process           := 'Y';
                     l_step_or_rate                          := '00';
                  END IF;

                  BEGIN
                      ghr_pay_calc.sql_main_pay_calc (l_pay_calc_in_data
                           ,l_pay_calc_out_data
                           ,l_message_set
                           ,l_calculated);

                        IF l_message_set THEN
                            hr_utility.set_location( l_proc, 40);
                            l_calculated     := FALSE;
                            l_mslerrbuf  := hr_utility.get_message;
                --			raise msl_error;
                        END IF;
                  EXCEPTION
                      when msl_error then
                           g_proc := 'ghr_pay_calc';
                          raise;
                      when others then
                    ----BUG 3287299 Start
                    IF ghr_pay_calc.gm_unadjusted_pay_flg = 'Y' then
                      l_comment := 'MSL:Error: Unadjusted Basic Pay must be entered in Employee record.';
                    ELSE
                      l_comment := 'MSL:Error: See process log for details.';
                    END IF;

                    IF upper(p_action) IN ('SHOW') THEN
                          -- Bug#2383392
                            create_mass_act_prev (
                            p_effective_date          => l_effective_date,
                            p_date_of_birth           => p_date_of_birth,
                            p_full_name               => p_full_name,
                            p_national_identifier     => p_national_identifier,
                            p_duty_station_code       => l_duty_station_code,
                            p_duty_station_desc       => l_duty_station_desc,
                            p_personnel_office_id     => l_personnel_office_id,
                            p_basic_pay               => l_old_basic_pay,
                            p_new_basic_pay           => null,
                            --Bug#2383992 Added old_adj_basic_pay
                            p_adj_basic_pay           => l_old_adj_basic_pay,
                            p_new_adj_basic_pay       => null,
                            p_old_avail_pay           => l_old_avail_pay,
                            p_new_avail_pay           => null,
                            p_old_loc_diff            => l_old_loc_diff,
                            p_new_loc_diff            => null,
                            p_tot_old_sal             => l_tot_old_sal,
                            p_tot_new_sal             => null,
                            p_old_auo_pay             => l_old_auo_pay,
                            p_new_auo_pay             => null,
                            p_position_id             => l_position_id,
                            p_position_title          => l_position_title,
                            -- FWFA Changes Bug#4444609
                            p_position_number         => l_position_number,
                            p_position_seq_no         => l_position_seq_no,
                            -- FWFA Changes
                            p_org_structure_id        => l_org_structure_id,
                            p_agency_sub_element_code => l_sub_element_code,
                            p_person_id               => p_person_id,
                            p_mass_salary_id          => l_mass_salary_id,
                            p_sel_flg                 => l_sel_flg,
                            p_first_action_la_code1   => l_first_action_la_code1,
                            p_first_action_la_code2   => l_first_action_la_code2,
                            p_remark_code1            => l_remark_code1,
                            p_remark_code2            => l_remark_code2,
                            p_grade_or_level          => l_grade_or_level,
                            p_step_or_rate            => l_step_or_rate,
                            p_pay_plan                => l_pay_plan,
                            p_pay_rate_determinant    =>  null,
                            p_tenure                  => l_tenure,
                            p_action                  => p_action,
                            p_assignment_id           => l_assignment_id,
                            p_old_other_pay           => l_other_pay,
                            p_new_other_pay           => null,
                            -- Bug#2383992
                            p_old_capped_other_pay    => NULL,
                            p_new_capped_other_pay    => NULL,
                            p_old_retention_allowance => l_retention_allowance,
                            p_new_retention_allowance => NULL,
                            p_old_supervisory_differential => l_supervisory_differential,
                            p_new_supervisory_differential => NULL,
                            -- BUG 3377958 Madhuri
                            p_organization_name            => l_org_name,
                            -- BUG 3377958 Madhuri
                            -- Bug#2383992
                            -- FWFA changes Bug#4444609
                            p_input_pay_rate_determinant  => l_pay_rate_determinant,
                            p_from_pay_table_id         => l_user_table_id,
                            p_to_pay_table_id           =>  null
                            -- FWFA changes
                             );
                          END IF;
                          -- Bug#3968005 Replaced parameter l_pay_sel with l_sel_flg
                          ins_upd_per_extra_info
                             (p_person_id,l_effective_date, l_sel_flg, l_comment,p_mass_salary_id);
                          l_comment := NULL;
                          ------  BUG 3287299 End
                          hr_utility.set_location('Error in Ghr_pay_calc.sql_main_pay_calc '||
                                    'Err is '||sqlerrm(sqlcode),20);
                        l_mslerrbuf := 'Error in ghr_pay_calc  Sql Err is '|| sqlerrm(sqlcode);
                        g_proc := 'ghr_pay_calc';
                        raise msl_error;
                  END;

        ghr_msl_pkg.g_ses_msl_process              := 'N';

        l_new_basic_pay        := l_pay_calc_out_data.basic_pay;
        l_new_locality_adj     := l_pay_calc_out_data.locality_adj;
        l_new_adj_basic_pay    := l_pay_calc_out_data.adj_basic_pay;
        l_new_au_overtime      := l_pay_calc_out_data.au_overtime;
        l_new_availability_pay := l_pay_calc_out_data.availability_pay;

        --Added by mani related to the bug 5919694
	l_out_pay_plan          := l_pay_calc_out_data.out_to_pay_plan;
	l_out_grade_id          := l_pay_calc_out_data.out_to_grade_id;
	l_out_grade_or_level    := l_pay_calc_out_data.out_to_grade_or_level;


        l_out_pay_rate_determinant := l_pay_calc_out_data.out_pay_rate_determinant;


        l_out_step_or_rate        := l_pay_calc_out_data.out_step_or_rate;
        l_new_retention_allowance :=  l_pay_calc_out_data.retention_allowance;
        l_new_supervisory_differential := l_supervisory_differential;
        l_new_other_pay_amount    := l_pay_calc_out_data.other_pay_amount;
        l_entitled_other_pay      := l_new_other_pay_amount;
        if l_new_other_pay_amount = 0 then
           l_new_other_pay_amount := null;
        end if;
        l_new_total_salary        := l_pay_calc_out_data.total_salary;

     hr_utility.set_location('retention_allowance = ' || to_char(l_retention_allowance),10);
     hr_utility.set_location('Supervisory Diff Amount = ' || to_char(l_supervisory_differential),10);


-------------Call Pay cap Procedure
     begin
      l_capped_other_pay := ghr_pa_requests_pkg2.get_cop( p_assignment_id  => l_assignment_id
                                                         ,p_effective_date => l_effective_date);
      l_old_capped_other_pay :=  l_capped_other_pay;
		-- Sundar Added the following if statement to improve performance
			if hr_utility.debug_enabled = true then
				  hr_utility.set_location('Before Pay Cap    ' || l_proc,21);
				  hr_utility.set_location('l_effective_date  ' || l_effective_date,21);
				  hr_utility.set_location('l_out_pay_rate_determinant  ' || l_out_pay_rate_determinant,21);
				  hr_utility.set_location('l_pay_plan  ' || l_pay_plan,21);
				  hr_utility.set_location('l_position_id  ' || to_char(l_position_id),21);
				  hr_utility.set_location('l_pay_basis  ' || l_pay_basis,21);
				  hr_utility.set_location('person_id  ' || to_char(p_person_id),21);
				  hr_utility.set_location('l_new_basic_pay  ' || to_char(l_new_basic_pay),21);
				  hr_utility.set_location('l_new_locality_adj  ' || to_char(l_new_locality_adj),21);
				  hr_utility.set_location('l_new_adj_basic_pay  ' || to_char(l_new_adj_basic_pay),21);
				  hr_utility.set_location('l_new_total_salary  ' || to_char(l_new_total_salary),21);
				  hr_utility.set_location('l_entitled_other_pay  ' || to_char(l_entitled_other_pay),21);
				  hr_utility.set_location('l_capped_other_pay  ' || to_char(l_capped_other_pay),21);
				  hr_utility.set_location('l_new_retention_allowance  ' || to_char(l_new_retention_allowance),21);
				  hr_utility.set_location('l_new_supervisory_differential  ' || to_char(l_new_supervisory_differential),21);
				  hr_utility.set_location('l_staffing_differential  ' || to_char(l_staffing_differential),21);
				  hr_utility.set_location('l_new_au_overtime  ' || to_char(l_new_au_overtime),21);
				  hr_utility.set_location('l_new_availability_pay  ' || to_char(l_new_availability_pay),21);

			end if;


      ghr_pay_caps.do_pay_caps_main
                   (p_pa_request_id        =>    null
                   ,p_effective_date       =>    l_effective_date
                   ,p_pay_rate_determinant =>    nvl(l_out_pay_rate_determinant,l_pay_rate_determinant)
                   ,p_pay_plan             =>    nvl(l_out_pay_plan,l_pay_plan)
                   ,p_to_position_id       =>    l_position_id
                   ,p_pay_basis            =>    l_pay_basis
                   ,p_person_id            =>    p_person_id
                   ,p_noa_code             =>    nvl(g_first_noa_code,'894')
                   ,p_basic_pay            =>    l_new_basic_pay
                   ,p_locality_adj         =>    l_new_locality_adj
                   ,p_adj_basic_pay        =>    l_new_adj_basic_pay
                   ,p_total_salary         =>    l_new_total_salary
                   ,p_other_pay_amount     =>    l_entitled_other_pay
                   ,p_capped_other_pay     =>    l_capped_other_pay
                   ,p_retention_allowance  =>    l_new_retention_allowance
                   ,p_retention_allow_percentage => l_retention_allow_perc
                   ,p_supervisory_allowance =>   l_new_supervisory_differential
                   ,p_staffing_differential =>   l_staffing_differential
                   ,p_au_overtime          =>    l_new_au_overtime
                   ,p_availability_pay     =>    l_new_availability_pay
                   ,p_adj_basic_message    =>    l_adj_basic_message
                   ,p_pay_cap_message      =>    l_pay_cap_message
                   ,p_pay_cap_adj          =>    l_temp_retention_allowance
                   ,p_open_pay_fields      =>    l_open_pay_fields_caps
                   ,p_message_set          =>    l_message_set_caps
                   ,p_total_pay_check      =>    l_total_pay_check);


             l_new_other_pay_amount := nvl(l_capped_other_pay,l_entitled_other_pay);

			-- Sundar Added the following statement to improve performance
			if hr_utility.debug_enabled = true then
				  hr_utility.set_location('After Pay Cap    ' || l_proc,22);
				  hr_utility.set_location('l_effective_date  ' || l_effective_date,22);
				  hr_utility.set_location('l_out_pay_rate_determinant  ' || l_out_pay_rate_determinant,22);
				  hr_utility.set_location('l_pay_plan  ' || l_pay_plan,22);
				  hr_utility.set_location('l_position_id  ' || to_char(l_position_id),22);
				  hr_utility.set_location('l_pay_basis  ' || l_pay_basis,22);
				  hr_utility.set_location('person_id  ' || to_char(p_person_id),22);
				  hr_utility.set_location('l_new_basic_pay  ' || to_char(l_new_basic_pay),22);
				  hr_utility.set_location('l_new_locality_adj  ' || to_char(l_new_locality_adj),22);
				  hr_utility.set_location('l_new_adj_basic_pay  ' || to_char(l_new_adj_basic_pay),22);
				  hr_utility.set_location('l_new_total_salary  ' || to_char(l_new_total_salary),22);
				  hr_utility.set_location('l_entitled_other_pay  ' || to_char(l_entitled_other_pay),22);
				  hr_utility.set_location('l_capped_other_pay  ' || to_char(l_capped_other_pay),22);
				  hr_utility.set_location('l_new_retention_allowance  ' || to_char(l_new_retention_allowance),22);
				  hr_utility.set_location('l_new_supervisory_differential  ' || to_char(l_new_supervisory_differential),22);
				  hr_utility.set_location('l_staffing_differential  ' || to_char(l_staffing_differential),22);
				  hr_utility.set_location('l_new_au_overtime  ' || to_char(l_new_au_overtime),22);
				  hr_utility.set_location('l_new_availability_pay  ' || to_char(l_new_availability_pay),22);
			end if;

       IF l_pay_cap_message THEN
			IF nvl(l_temp_retention_allowance,0) > 0 THEN
			  l_comment := 'MSL: Exceeded Total Cap - reduce Retention Allow to '
					|| to_char(l_temp_retention_allowance);
			  -- Bug#3968005 Replaced l_pay_sel with l_sel_flg
			  l_sel_flg := 'N';
			ELSE
			  l_comment := 'MSL: Exceeded Total cap - pls review.';
			END IF;
       ELSIF l_adj_basic_message THEN
          l_comment := 'MSL: Exceeded Adjusted Pay Cap - Locality reduced.';
       END IF;

       -- Bug 2639698 Sundar
	   IF (l_old_basic_pay > l_new_basic_pay) THEN
			l_comment_sal := 'MSL: From Basic Pay exceeds To Basic Pay.';
       END IF;
	   -- End Bug 2639698

       IF l_pay_cap_message or l_adj_basic_message THEN
			-- Bug 2639698
		  IF (l_comment_sal IS NOT NULL) THEN
		     l_comment := l_comment_sal || ' ' || l_comment;
		  END IF;
		  -- End Bug 2639698
	     -- Bug#3968005 Replaced parameter l_pay_sel with l_sel_flg
             ins_upd_per_extra_info
               (p_person_id,l_effective_date, l_sel_flg, l_comment,p_mass_salary_id);
          l_comment := NULL;
       --------------------Bug 2639698 Sundar To add comments
	   -- Should create comments only if comments need to be inserted
       ELSIF l_comment_sal IS NOT NULL THEN
            -- Bug#3968005 Replaced parameter l_pay_sel with l_sel_flg
	    ins_upd_per_extra_info
               (p_person_id,l_effective_date, l_sel_flg, l_comment_sal,p_mass_salary_id);
	   END IF;

       l_comment_sal := NULL; -- bug 2639698
     exception
          when msl_error then
               raise;
          when others then
               hr_utility.set_location('Error in ghr_pay_caps.do_pay_caps_main ' ||
                                'Err is '||sqlerrm(sqlcode),23);
                    l_mslerrbuf := 'Error in do_pay_caps_main  Sql Err is '|| sqlerrm(sqlcode);
                    raise msl_error;
     end;


                IF upper(p_action) IN ('SHOW','REPORT') THEN
                          -- Bug#2383392


		  --6753050    modified if user manually changes position table from special
                  -- pay table identifier to '0000' then PRD should change to '0'
                  If  l_pay_rate_determinant  = '6' and
          	      get_user_table_name(l_pay_table_id) = '0000' then
		      l_out_pay_rate_determinant  := '0';
                  End If;
     	          --6753050
                    create_mass_act_prev (
                        p_effective_date          => l_effective_date,
                        p_date_of_birth           => p_date_of_birth,
                        p_full_name               => p_full_name,
                        p_national_identifier     => p_national_identifier,
                        p_duty_station_code       => l_duty_station_code,
                        p_duty_station_desc       => l_duty_station_desc,
                        p_personnel_office_id     => l_personnel_office_id,
                        p_basic_pay               => l_old_basic_pay,
                        p_new_basic_pay           => l_new_basic_pay,
                        --Bug#2383992 Added old_adj_basic_pay
                        p_adj_basic_pay           => l_old_adj_basic_pay,
                        p_new_adj_basic_pay       => l_new_adj_basic_pay,
                        p_old_avail_pay           => l_old_avail_pay,
                        p_new_avail_pay           =>  l_new_availability_pay,
                        p_old_loc_diff            => l_old_loc_diff,
                        p_new_loc_diff            => l_new_locality_adj,
                        p_tot_old_sal             => l_tot_old_sal,
                        p_tot_new_sal             =>   l_new_total_salary,
                        p_old_auo_pay             => l_old_auo_pay,
                        p_new_auo_pay             =>   l_new_au_overtime,
                        p_position_id             => l_position_id,
                        p_position_title          => l_position_title,
                        -- FWFA Changes Bug#4444609
                        p_position_number         => l_position_number,
                        p_position_seq_no         => l_position_seq_no,
                        -- FWFA Changes
                        p_org_structure_id        => l_org_structure_id,
                        p_agency_sub_element_code => l_sub_element_code,
                        p_person_id               => p_person_id,
                        p_mass_salary_id          => l_mass_salary_id,
                        p_sel_flg                 => l_sel_flg,
                        p_first_action_la_code1   => l_first_action_la_code1,
                        p_first_action_la_code2   => l_first_action_la_code2,
                        p_remark_code1            => l_remark_code1,
                        p_remark_code2            => l_remark_code2,
                        p_grade_or_level          => NVL(l_out_grade_or_level,l_grade_or_level),
                        p_step_or_rate            => l_step_or_rate,
                        p_pay_plan                => NVL(l_out_pay_plan,l_pay_plan),
                        -- FWFA Changes Bug#4444609
                        p_pay_rate_determinant    => NVL(l_out_pay_rate_determinant,l_pay_rate_determinant),
                        -- FWFA Changes
                        p_tenure                  => l_tenure,
                        p_action                  => p_action,
                        p_assignment_id           => l_assignment_id,
                        p_old_other_pay           => l_other_pay,
                        p_new_other_pay           => l_new_other_pay_amount,
                        -- Bug#2383992
                        p_old_capped_other_pay    => l_old_capped_other_pay,--NULL,
                        p_new_capped_other_pay    => l_capped_other_pay,
                        p_old_retention_allowance => l_retention_allowance,
                        p_new_retention_allowance => l_new_retention_allowance,
                        p_old_supervisory_differential => l_supervisory_differential,
                        p_new_supervisory_differential => l_new_supervisory_differential,
                        -- BUG 3377958 Madhuri
                        p_organization_name            => l_org_name,
                        -- Bug#2383992
                        -- FWFA Changes Bug#4444609
                        p_input_pay_rate_determinant   => l_pay_rate_determinant,
                        p_from_pay_table_id            => l_pay_calc_out_data.pay_table_id,
                        p_to_pay_table_id              => l_pay_calc_out_data.calculation_pay_table_id
                        -- FWFA Changes
                         );
                ELSIF upper(p_action) = 'CREATE' then

                    BEGIN
                        -- Bug#5089732 Used the overloaded procedure.
                        get_pay_plan_and_table_id
                          (l_pay_rate_determinant,p_person_id,
                           l_position_id,l_effective_date,
                           l_grade_id, l_to_grade_id,l_assignment_id,'CREATE',
                           l_pay_plan,l_to_pay_plan,l_pay_table_id,
                           l_grade_or_level, l_to_grade_or_level, l_step_or_rate,
                           l_pay_basis);
                     EXCEPTION
                       when msl_error then
 		               l_mslerrbuf := hr_utility.get_message;
                       raise;
                     END;

		     --6753050    modified if user manually changes position table from special
                     -- pay table identifier to '0000' then PRD should change to '0'
                     If l_pay_rate_determinant  = '6' and
          	        get_user_table_name(l_pay_table_id) = '0000' then
   		        l_pay_rate_determinant  := '0';
                     End If;
     	             --6753050

                     assign_to_sf52_rec(
                       p_person_id,
                       p_first_name,
                       p_last_name,
                       p_middle_names,
                       p_national_identifier,
                       p_date_of_birth,
                       l_effective_date,
                       l_assignment_id,
                       l_tenure,
                       -- Bug#5089732
                       NVL(l_out_grade_id,l_to_grade_id),
                       NVL(l_out_pay_plan,l_to_pay_plan),
                       NVL(l_out_grade_or_level,l_to_grade_or_level),
                       -- Bug#5089732
                       l_step_or_rate,
                       l_annuitant_indicator,
                       -- FWFA Changes Bug#4444609
                       NVL(l_out_pay_rate_determinant,l_pay_rate_determinant),
                       -- FWFA Changes
                       l_work_schedule,
                       l_part_time_hour,
                       l_pos_ei_data.poei_information7, --FLSA Category
                       l_pos_ei_data.poei_information8, --Bargaining Unit Status
                       l_pos_ei_data.poei_information11,--Functional Class
                       l_pos_ei_data.poei_information16,--Supervisory Status,
                       l_new_basic_pay,
                       l_new_locality_adj,
                       l_new_adj_basic_pay,
                       l_new_total_salary,
                       l_other_pay,
                       l_new_other_pay_amount,
                       l_new_au_overtime,
                       l_new_availability_pay,
                       l_new_retention_allowance,
                       l_retention_allow_perc,
                       l_new_supervisory_differential,
                       l_supervisory_diff_perc,
                       l_staffing_differential,
                       l_duty_station_id,
                       l_duty_station_code,
                       l_duty_station_desc,
                       -- FWFA Changes  Bug#4444609
                       l_pay_rate_determinant,
                       l_pay_calc_out_data.pay_table_id,
                       l_pay_calc_out_data.calculation_pay_table_id,
                       -- FWFA Changes
                       l_lac_sf52_rec,
                       l_sf52_rec);

					  BEGIN
						   ghr_mass_actions_pkg.pay_calc_rec_to_sf52_rec
							   (l_pay_calc_out_data,
								l_sf52_rec);
					  EXCEPTION
						  when others then
							  hr_utility.set_location('Error in Ghr_mass_actions_pkg.pay_calc_rec_to_sf52_rec '||
										'Err is '||sqlerrm(sqlcode),20);
							 l_mslerrbuf := 'Error in ghr_mass_act_pkg.pay_calc_to_sf52  Sql Err is '|| sqlerrm(sqlcode);
							 raise msl_error;
					  END;

                   BEGIN
		               l_sf52_rec.mass_action_id := p_mass_salary_id;
                       l_sf52_rec.rpa_type := 'MSL';
                       g_proc  := 'Create_sf52_recrod';
                       ghr_mass_changes.create_sf52_for_mass_changes
                           (p_mass_action_type => 'MASS_SALARY_CHG',
                            p_pa_request_rec  => l_sf52_rec,
                            p_errbuf           => l_errbuf,
                            p_retcode          => l_retcode);

                       ------ Added by Dinkar for List reports problem
                       ---------------------------------------
                       IF l_errbuf IS NULL THEN

					       DECLARE
					           l_pa_request_number ghr_pa_requests.request_number%TYPE;
						   BEGIN
              			       l_pa_request_number   :=
								     l_sf52_rec.request_number||'-'||p_mass_salary_id;

						       ghr_par_upd.upd
                                      (p_pa_request_id             => l_sf52_rec.pa_request_id,
                                       p_object_version_number     => l_sf52_rec.object_version_number,
                                       p_request_number            => l_pa_request_number
                                      );
						   END;

                           pr('No error in create sf52 ');

                           ghr_mto_int.log_message(
                              p_procedure => 'Successful Completion',
                              p_message   => 'Name: '||p_full_name ||
                              ' SSN: '|| p_national_identifier||
                              '  Mass Salary : '||
                              p_mass_salary ||' SF52 Successfully completed');

                           create_lac_remarks(l_pa_request_id,
                                           l_sf52_rec.pa_request_id);

                           -- Added by Enunez 11-SEP-1999
                           IF l_lac_sf52_rec.first_action_la_code1 IS NULL THEN
                               -- Added by Edward Nunez for 894 rules
                               g_proc := 'Apply_894_Rules';
                               --Bug 2012782 fix
                               IF l_out_pay_rate_determinant IS NULL THEN
                                   l_out_pay_rate_determinant := l_pay_rate_determinant;
                               END IF;
                               --Bug 2012782 fix end
                               ghr_lacs_remarks.Apply_894_Rules(
                                       l_sf52_rec.pa_request_id,
                                       l_out_pay_rate_determinant,
                                       l_pay_rate_determinant,
                                       l_out_step_or_rate,
                                       l_executive_order_number,
                                       l_executive_order_date,
                                       l_opm_issuance_number,
                                       l_opm_issuance_date,
                                       l_errbuf,
                                       l_retcode
                                       );
                               IF l_errbuf IS NOT NULL THEN
                                   IF sqlcode = 0000 THEN
                                   l_mslerrbuf := l_mslerrbuf || '; ' || l_errbuf;
                                   ELSE
                                   l_mslerrbuf := l_mslerrbuf || ' ' || l_errbuf || ' Sql Err is: '
                                                                  || sqlerrm(sqlcode);
                                   END IF;
                                   RAISE msl_error;
                               END IF;
                           END IF; -- IF l_lac_sf52_rec.first_action_la_code1
                           g_proc := 'update_SEL_FLG';

                           update_SEL_FLG(p_PERSON_ID,l_effective_date);

                           COMMIT;
                       ELSE
                           pr('Error in create sf52',l_errbuf);
                           l_recs_failed := l_recs_failed + 1;
                           -- Raising MSL_ERROR is not required as the process log
                           -- was updated in ghr_mass_changes.create_sf52_for_mass_changes pkg itself.
                           --raise msl_error;
                       END IF; -- if l_errbuf is null then
                   EXCEPTION
                      WHEN msl_error then raise;
                      WHEN others then  null;
                      l_mslerrbuf := 'Error in ghr_mass_chg.create_sf52 '||
                                   ' Sql Err is '|| sqlerrm(sqlcode);
                      RAISE msl_error;
                   END;
               END IF; --  IF upper(p_action) IN ('SHOW','REPORT') THEN
            END IF; -- end if for check_select_flg
         END IF; -- end if for p_action = 'REPORT'


         L_row_cnt := L_row_cnt + 1;
         IF upper(p_action) <> 'CREATE' THEN
             IF L_row_cnt > 50 then
                 COMMIT;
                 L_row_cnt := 0;
             END IF;
         END IF;
      EXCEPTION
         WHEN MSL_ERROR THEN
               HR_UTILITY.SET_LOCATION('Error occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),10);
               begin
                ------  BUG 3287299 -- Not to rollback for preview.
       	        if upper(p_action) <> 'SHOW' then
                  ROLLBACK TO EXECUTE_MSL_SP;
                end if;
               EXCEPTION
                  WHEN OTHERS THEN NULL;
               END;
               l_log_text  := 'Error in '||l_proc||' '||
                              ' For Mass Salary Name : '||p_mass_salary||
                              'Name: '|| p_full_name || ' SSN: ' || p_national_identifier ||
                              l_mslerrbuf;
               hr_utility.set_location('before creating entry in log file',10);
               l_recs_failed := l_recs_failed + 1;
            begin
               ghr_mto_int.log_message(
                              p_procedure => g_proc,
                              p_message   => l_log_text);
            exception
                when others then
                    hr_utility.set_message(8301, 'GHR_38475_ERROR_LOG_FAILURE');
                    hr_utility.raise_error;
            end;
         when others then
               HR_UTILITY.SET_LOCATION('Error (Others) occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),20);
               BEGIN
                 ROLLBACK TO EXECUTE_MSL_SP;
               EXCEPTION
                 WHEN OTHERS THEN NULL;
               END;
               l_log_text  := 'Error (others) in '||l_proc||
                              ' For Mass Salary Name : '||p_mass_salary||
                              'Name: '|| p_full_name || ' SSN: ' || p_national_identifier ||
                              ' Sql Err is '||sqlerrm(sqlcode);
               hr_utility.set_location('before creating entry in log file',20);
               l_recs_failed := l_recs_failed + 1;
            begin
               ghr_mto_int.log_message(
                              p_procedure => g_proc,
                              p_message   => l_log_text);
            exception
                when others then
                    hr_utility.set_message(8301, 'Create Error Log failed');
                    hr_utility.raise_error;
            end;
      END;

--
-- msl_process END

--
--
BEGIN
  g_proc  := 'execute_msl';
  hr_utility.set_location('Entering    ' || l_proc,5);

  g_first_noa_code     := null;
  p_retcode  := 0;
  BEGIN
    FOR msl IN ghr_msl (p_mass_salary_id)
    LOOP
        p_mass_salary    := msl.name;
        l_effective_date := msl.effective_date;
        l_mass_salary_id := msl.mass_salary_id;
        l_user_table_id  := msl.user_table_id;
        l_submit_flag    := msl.submit_flag;
        l_executive_order_number := msl.executive_order_number;
        l_executive_order_date :=  msl.executive_order_date;
        l_opm_issuance_number  :=  msl.opm_issuance_number;
        l_opm_issuance_date    :=  msl.opm_issuance_date;
        l_pa_request_id  := msl.pa_request_id;
        l_rowid          := msl.rowid;
        l_p_ORGANIZATION_ID        := msl.ORGANIZATION_ID;
        l_p_DUTY_STATION_ID        := msl.DUTY_STATION_ID;
        l_p_PERSONNEL_OFFICE_ID    := msl.PERSONNEL_OFFICE_ID;
        l_p_AGENCY_CODE_SUBELEMENT := msl.AGENCY_CODE_SUBELEMENT;
	    l_process_type             := msl.process_type;

		pr('Pa request id is '||to_char(l_pa_request_id));
       exit;
    END LOOP;
  EXCEPTION
    when REC_BUSY then
         hr_utility.set_location('Mass Salary is in use',1);
         l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
        -- raise error;
        hr_utility.set_message(8301, 'GHR_38477_LOCK_ON_MSL');
        hr_utility.raise_error;
--
    when others then
      hr_utility.set_location('Error in '||l_proc||' Sql err is '||sqlerrm(sqlcode),1);
--    raise_application_error(-20111,'Error while selecting from Ghr Mass Salaries');
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
  END;
   --Bug#5063304 Moved this cursor from execute_msl to this place.
  FOR c_pay_tab_essl_rec in c_pay_tab_essl
  LOOP
      l_essl_table := TRUE;
  EXIT;
  END LOOP;

  IF l_process_type = 'P' THEN

	hr_utility.set_location('befo perc' || l_proc,5);
	execute_msl_perc( p_errbuf,
                          p_retcode,
                          p_mass_salary_id,
                          p_action );

  ELSIF l_process_type = 'T' THEN

	ghr_mlc_pkg.execute_msl_pay( p_errbuf,
				 p_retcode,
				 p_mass_salary_id,
				 p_action );

  ELSIF l_process_type = 'L' THEN

	ghr_mlc_pkg.execute_mlc( p_errbuf,
				 p_retcode,
				 p_mass_salary_id,
				 p_action );

  ELSIF l_process_type = 'R' THEN
     hr_utility.set_location('befo proc' || l_proc,5);
     execute_msl_ses_range( p_errbuf,
                      p_retcode,
                      p_mass_salary_id,
                      p_action);
  ELSE

  g_effective_date := l_effective_date;



-- Bug 3315432 Madhuri
--
  FOR pp_prd IN cur_pp_prd(p_mass_salary_id)
  LOOP
	rec_pp_prd(l_index).pay_plan := pp_prd.pay_plan;
	rec_pp_prd(l_index).prd      := pp_prd.prd;
	l_index := l_index +1;
  END LOOP;

  IF upper(p_action) = 'CREATE' then
     ghr_mto_int.set_log_program_name('GHR_MSL_PKG');
  ELSE
     ghr_mto_int.set_log_program_name('MSL_'||p_mass_salary);
  END IF;

  get_lac_dtls(l_pa_request_id, l_lac_sf52_rec);

  hr_utility.set_location('After fetch msl '||to_char(l_effective_date)||' '||to_char(l_user_table_id),20);
  IF l_p_ORGANIZATION_ID is not null then
    FOR per IN cur_people_org (l_effective_date,l_p_ORGANIZATION_ID)
    LOOP

        -- Bug#5719467 Initialised the variable l_mslerrbuf to avoid ora error 6502
        l_mslerrbuf := NULL;
        -- Bug#5063304 Added the following IF Condition.
        IF  NVL(l_p_organization_id,per.organization_id) = per.organization_id THEN
            FOR ast IN cur_ast (per.assignment_status_type_id) LOOP
                                --
                -- Set all local variables to NULL
                l_personnel_office_id  := NULL;
                l_org_structure_id     := NULL;
                l_position_title       := NULL;
                l_position_number      := NULL;
                l_position_seq_no      := NULL;
                l_sub_element_code     := NULL;
                l_duty_station_id      := NULL;
                l_tenure               := NULL;
                l_annuitant_indicator  := NULL;
                l_pay_rate_determinant := NULL;
                l_work_schedule        := NULL;
                l_part_time_hour       := NULL;
                l_to_grade_id          := NULL;
                l_pay_plan             := NULL;
                l_to_pay_plan          := NULL;
                l_pay_table_id         := NULL;
                l_grade_or_level       := NULL;
                l_to_grade_or_level    := NULL;
                l_step_or_rate         := NULL;
                l_pay_basis            := NULL;
                l_elig_flag            := FALSE;
                --
                hr_utility.set_location('SSN: '||per.national_identifier,1000);
                BEGIN
                fetch_and_validate_emp(
                                p_action                => p_action
                               ,p_mass_salary_id        => p_mass_salary_id
                               ,p_mass_salary_name      => p_mass_salary
                               ,p_full_name             => per.full_name
                               ,p_national_identifier   => per.national_identifier
                               ,p_assignment_id         => per.assignment_id
                               ,p_person_id             => per.person_id
                               ,p_position_id           => per.position_id
                               ,p_grade_id              => per.grade_id
                               ,p_business_group_id     => per.business_group_id
                               ,p_location_id           => per.location_id
                               ,p_organization_id       => per.organization_id
                               ,p_msl_organization_id    => l_p_organization_id
                               ,p_msl_duty_station_id    => l_p_duty_station_id
                               ,p_msl_personnel_office_id   => l_p_personnel_office_id
                               ,p_msl_agency_code_subelement => l_p_agency_code_subelement
                               ,p_msl_user_table_id         => l_user_table_id
                               ,p_rec_pp_prd                => rec_pp_prd
                               ,p_personnel_office_id   => l_personnel_office_id
                               ,p_org_structure_id      => l_org_structure_id
                               ,p_position_title        => l_position_title
                               ,p_position_number       => l_position_number
                               ,p_position_seq_no       => l_position_seq_no
                               ,p_subelem_code          => l_sub_element_code
                               ,p_duty_station_id       => l_duty_station_id
                               ,p_tenure                => l_tenure
                               ,p_annuitant_indicator   => l_annuitant_indicator
                               ,p_pay_rate_determinant  => l_pay_rate_determinant
                               ,p_work_schedule         => l_work_schedule
                               ,p_part_time_hour        => l_part_time_hour
                               ,p_to_grade_id           => l_to_grade_id
                               ,p_pay_plan              => l_pay_plan
                               ,p_to_pay_plan           => l_to_pay_plan
                               ,p_pay_table_id          => l_pay_table_id
                               ,p_grade_or_level        => l_grade_or_level
                               ,p_to_grade_or_level     => l_to_grade_or_level
                               ,p_step_or_rate          => l_step_or_rate
                               ,p_pay_basis             => l_pay_basis
                               ,p_elig_flag             => l_elig_flag
                               );
                EXCEPTION
                    --WHEN fetch_validate_error THEN
                    --    l_elig_flag := FALSE;
                    WHEN OTHERS THEN
                        l_elig_flag := FALSE;
                END;

                IF l_elig_flag THEN

                    msl_process( p_assignment_id  => per.assignment_id
                              ,p_person_id => per.person_id
                              ,p_position_id  => per.position_id
                              ,p_grade_id => per.grade_id
                              ,p_business_group_id => per.business_group_id
                              ,p_location_id => per.location_id
                              ,p_organization_id => per.organization_id
                              ,p_date_of_birth => per.date_of_birth
                              ,p_first_name => per.first_name
                              ,p_last_name => per.last_name
                              ,p_full_name => per.full_name
                              ,p_middle_names => per.middle_names
                              ,p_national_identifier => per.national_identifier
                              ,p_personnel_office_id   => l_personnel_office_id
                            ,p_org_structure_id      => l_org_structure_id
                            ,p_position_title        => l_position_title
                            ,p_position_number       => l_position_number
                            ,p_position_seq_no       => l_position_seq_no
                            ,p_subelem_code          => l_sub_element_code
                            ,p_duty_station_id       => l_duty_station_id
                            ,p_tenure                => l_tenure
                            ,p_annuitant_indicator   => l_annuitant_indicator
                            ,p_pay_rate_determinant  => l_pay_rate_determinant
                            ,p_work_schedule         => l_work_schedule
                            ,p_part_time_hour        => l_part_time_hour
                            ,p_to_grade_id           => l_to_grade_id
                            ,p_pay_plan              => l_pay_plan
                            ,p_to_pay_plan           => l_to_pay_plan
                            ,p_pay_table_id          => l_pay_table_id
                            ,p_grade_or_level        => l_grade_or_level
                            ,p_to_grade_or_level     => l_to_grade_or_level
                            ,p_step_or_rate          => l_step_or_rate
                            ,p_pay_basis             => l_pay_basis
                              );
                END IF;
            END LOOP;
        END IF;
    END LOOP;
  ELSE
    FOR per IN cur_people (l_effective_date)
    LOOP
        -- Bug#5719467 Initialised the variable l_mslerrbuf to avoid ora error 6502
        l_mslerrbuf := NULL;
        FOR ast IN cur_ast (per.assignment_status_type_id)
        LOOP
            --
            -- Set all local variables to NULL
            l_personnel_office_id  := NULL;
            l_org_structure_id     := NULL;
            l_position_title       := NULL;
            l_position_number      := NULL;
            l_position_seq_no      := NULL;
            l_sub_element_code     := NULL;
            l_duty_station_id      := NULL;
            l_tenure               := NULL;
            l_annuitant_indicator  := NULL;
            l_pay_rate_determinant := NULL;
            l_work_schedule        := NULL;
            l_part_time_hour       := NULL;
            l_to_grade_id          := NULL;
            l_pay_plan             := NULL;
            l_to_pay_plan          := NULL;
            l_pay_table_id         := NULL;
            l_grade_or_level       := NULL;
            l_to_grade_or_level    := NULL;
            l_step_or_rate         := NULL;
            l_pay_basis            := NULL;
            l_elig_flag            := FALSE;
            --
            hr_utility.set_location('SSN: '||per.national_identifier,2000);
            BEGIN
                fetch_and_validate_emp(
                p_action                => p_action
               ,p_mass_salary_id        => p_mass_salary_id
               ,p_mass_salary_name      => p_mass_salary
               ,p_full_name             => per.full_name
               ,p_national_identifier   => per.national_identifier
               ,p_assignment_id         => per.assignment_id
               ,p_person_id             => per.person_id
               ,p_position_id           => per.position_id
               ,p_grade_id              => per.grade_id
               ,p_business_group_id     => per.business_group_id
               ,p_location_id           => per.location_id
               ,p_organization_id       => per.organization_id
               ,p_msl_organization_id    => l_p_organization_id
               ,p_msl_duty_station_id    => l_p_duty_station_id
               ,p_msl_personnel_office_id   => l_p_personnel_office_id
               ,p_msl_agency_code_subelement => l_p_agency_code_subelement
               ,p_msl_user_table_id         => l_user_table_id
               ,p_rec_pp_prd                => rec_pp_prd
               ,p_personnel_office_id   => l_personnel_office_id
               ,p_org_structure_id      => l_org_structure_id
               ,p_position_title        => l_position_title
               ,p_position_number       => l_position_number
               ,p_position_seq_no       => l_position_seq_no
               ,p_subelem_code          => l_sub_element_code
               ,p_duty_station_id       => l_duty_station_id
               ,p_tenure                => l_tenure
               ,p_annuitant_indicator   => l_annuitant_indicator
               ,p_pay_rate_determinant  => l_pay_rate_determinant
               ,p_work_schedule         => l_work_schedule
               ,p_part_time_hour        => l_part_time_hour
               ,p_to_grade_id           => l_to_grade_id
               ,p_pay_plan              => l_pay_plan
               ,p_to_pay_plan           => l_to_pay_plan
               ,p_pay_table_id          => l_pay_table_id
               ,p_grade_or_level        => l_grade_or_level
               ,p_to_grade_or_level     => l_to_grade_or_level
               ,p_step_or_rate          => l_step_or_rate
               ,p_pay_basis             => l_pay_basis
               ,p_elig_flag             => l_elig_flag
                );
            EXCEPTION
                --WHEN fetch_validate_error THEN
                   -- l_elig_flag := FALSE;
                WHEN OTHERS THEN
                    l_elig_flag := FALSE;
            END;
            IF l_elig_flag THEN
                msl_process( p_assignment_id  => per.assignment_id
                          ,p_person_id => per.person_id
                          ,p_position_id  => per.position_id
                          ,p_grade_id => per.grade_id
                          ,p_business_group_id => per.business_group_id
                          ,p_location_id => per.location_id
                          ,p_organization_id => per.organization_id
                          ,p_date_of_birth => per.date_of_birth
                          ,p_first_name => per.first_name
                          ,p_last_name => per.last_name
                          ,p_full_name => per.full_name
                          ,p_middle_names => per.middle_names
                          ,p_national_identifier => per.national_identifier
                          ,p_personnel_office_id   => l_personnel_office_id
                          ,p_org_structure_id      => l_org_structure_id
                          ,p_position_title        => l_position_title
                          ,p_position_number       => l_position_number
                          ,p_position_seq_no       => l_position_seq_no
                          ,p_subelem_code          => l_sub_element_code
                          ,p_duty_station_id       => l_duty_station_id
                          ,p_tenure                => l_tenure
                          ,p_annuitant_indicator   => l_annuitant_indicator
                          ,p_pay_rate_determinant  => l_pay_rate_determinant
                          ,p_work_schedule         => l_work_schedule
                          ,p_part_time_hour        => l_part_time_hour
                          ,p_to_grade_id           => l_to_grade_id
                          ,p_pay_plan              => l_pay_plan
                          ,p_to_pay_plan           => l_to_pay_plan
                          ,p_pay_table_id          => l_pay_table_id
                          ,p_grade_or_level        => l_grade_or_level
                          ,p_to_grade_or_level     => l_to_grade_or_level
                          ,p_step_or_rate          => l_step_or_rate
                          ,p_pay_basis             => l_pay_basis
                          );
            END IF;
        END LOOP;
    END LOOP;
  END IF;

pr('After processing is over ',to_char(l_recs_failed));
   --Bug#4016384  Add the RG expired record count to the l_recs_failed count
   l_recs_failed := l_recs_failed + g_rg_recs_failed;
   IF (l_recs_failed  = 0) THEN
     IF UPPER(p_action) = 'CREATE' THEN
       BEGIN
          UPDATE ghr_mass_salaries
             SET submit_flag = 'P'
           WHERE rowid = l_rowid;
       EXCEPTION
         WHEN others THEN
           HR_UTILITY.SET_LOCATION('Error in Update ghr_msl  Sql error '||sqlerrm(sqlcode),30);
           hr_utility.set_message(8301, 'GHR_38476_UPD_GHR_MSL_FAILURE');
           hr_utility.raise_error;
       END;
     END IF;
  ELSE
      p_errbuf   := 'Error in '||l_proc || ' Details in GHR_PROCESS_LOG';
      p_retcode  := 2;
      IF upper(p_action) = 'CREATE' THEN
         UPDATE ghr_mass_salaries
            SET submit_flag = 'E'
          WHERE rowid = l_rowid;
      END IF;
  END IF;
pr('Before commiting.....');
COMMIT;
pr('After commiting.....',to_char(l_recs_failed));

END IF;

EXCEPTION
    when others then
      HR_UTILITY.SET_LOCATION('Error (Others2) occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),30);
      BEGIN
        ROLLBACK TO EXECUTE_MSL_SP;
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;
      l_log_text  := 'Error in '||l_proc||
                     ' For Mass Salary Name : '||p_mass_salary||
                     ' Sql Err is '||sqlerrm(sqlcode);
      l_recs_failed := l_recs_failed + 1;
      hr_utility.set_location('before creating entry in log file',30);

      p_errbuf   := 'Error in '||l_proc || ' Details in GHR_PROCESS_LOG';
      p_retcode  := 2;
      IF upper(p_action) = 'CREATE' THEN
         UPDATE ghr_mass_salaries
            SET submit_flag = 'E'
          WHERE rowid = l_rowid;
          COMMIT;
      END IF;

      BEGIN
         ghr_mto_int.log_message(
                        p_procedure => g_proc,
                        p_message   => l_log_text);
      EXCEPTION
          WHEN others THEN
              hr_utility.set_message(8301, 'Create Error Log failed');
              hr_utility.raise_error;
      END;


END EXECUTE_MSL;

--
--
--

-- Function returns the request id.
-- This is coded as a wrapper for fnd_request.submit_request
-- if all the params are passed as null, the submit request is passing all the
-- params as null and so, we get wrong no of params passed error.
--

FUNCTION submit_conc_req (P_APPLICATION IN VARCHAR2,
                              P_PROGRAM IN VARCHAR2,
                              P_DESCRIPTION IN VARCHAR2,
                              P_START_TIME IN VARCHAR2,
                              P_SUB_REQUEST IN BOOLEAN,
                              P_ARGUMENT1 IN VARCHAR2,
                              P_ARGUMENT2 IN VARCHAR2)
   RETURN NUMBER IS
BEGIN
  return (fnd_request.submit_request(
   APPLICATION    => p_application
  ,PROGRAM        => p_program
  ,DESCRIPTION    => p_description
  ,START_TIME     => p_start_time
  ,SUB_REQUEST    => p_sub_request
  ,ARGUMENT1      => p_argument1
  ,ARGUMENT2      => p_argument2
 ));

END submit_conc_req;

--
--
--
-- Procedure Deletes all records processed by the report
--

PROCEDURE purge_processed_recs(p_session_id in number,
                               p_err_buf out nocopy varchar2) IS
BEGIN
   p_err_buf := null;
   DELETE from ghr_mass_actions_preview
    WHERE mass_action_type = 'SALARY'
      AND session_id  = p_session_id;
   COMMIT;

EXCEPTION
   WHEN others THEN
     p_err_buf := 'Sql err '|| sqlerrm(sqlcode);
END;

-- BUG 3377958 Madhuri
-- Added p_org_name to this proc for MSL form changes
--
PROCEDURE pop_dtls_from_pa_req(p_person_id in number,p_effective_date in date,
         p_mass_salary_id in number, p_org_name in varchar2) IS

CURSOR ghr_pa_req_cur IS
SELECT EMPLOYEE_DATE_OF_BIRTH,
       substr(EMPLOYEE_LAST_NAME||', '||EMPLOYEE_FIRST_NAME||' '||
              EMPLOYEE_MIDDLE_NAMES,1,240)  FULL_NAME,
       EMPLOYEE_NATIONAL_IDENTIFIER,
       DUTY_STATION_CODE,
       DUTY_STATION_DESC,
       PERSONNEL_OFFICE_ID,
       FROM_BASIC_PAY,
       TO_BASIC_PAY,
       --Bug#2383992
       FROM_ADJ_BASIC_PAY,
       TO_ADJ_BASIC_PAY,
       --Bug#2383992
       NULL FROM_AVAILABILITY_PAY,
       TO_AVAILABILITY_PAY,
       FROM_LOCALITY_ADJ,
       TO_LOCALITY_ADJ,
       FROM_TOTAL_SALARY,
       TO_TOTAL_SALARY,
       NULL FROM_AU_OVERTIME,
       TO_AU_OVERTIME,
       TO_POSITION_ID POSITION_ID,
       TO_POSITION_TITLE POSITION_TITLE,
       -- FWFA Changes Bug#4444609
       TO_POSITION_NUMBER POSITION_NUMBER,
       TO_POSITION_SEQ_NO POSITION_SEQ_NO,
       -- FWFA Changes
       null org_structure_id,
       FROM_AGENCY_CODE,
       PERSON_ID,
--       p_mass_salary_id
       'Y'  Sel_flag,
       first_action_la_code1,
       first_action_la_code2,
       NULL REMARK_CODE1,
       NULL REMARK_CODE2,
       from_grade_or_level,
       from_step_or_rate,
       from_pay_plan,
       PAY_RATE_DETERMINANT,
       TENURE,
       EMPLOYEE_ASSIGNMENT_ID,
       FROM_OTHER_PAY_AMOUNT,
       TO_OTHER_PAY_AMOUNT,
       --Bug#2383992
       NULL FROM_RETENTION_ALLOWANCE,
       TO_RETENTION_ALLOWANCE,
       NULL FROM_SUPERVISORY_DIFFERENTIAL,
       TO_SUPERVISORY_DIFFERENTIAL,
       NULL FROM_CAPPED_OTHER_PAY,
       NULL TO_CAPPED_OTHER_PAY,
	   RPA_TYPE,
       -- FWFA Changes Bug#4444609
       input_pay_rate_determinant,
       from_pay_table_identifier,
       to_pay_table_identifier
       -- FWFA Changes
  FROM ghr_pa_requests
 WHERE person_id = p_person_id
   AND effective_date = p_effective_date
-- Added by Dinkar for reports
   AND SUBSTR(request_number,(instr(request_number,'-')+1)) = TO_CHAR(p_mass_salary_id)
   AND first_noa_code = nvl(g_first_noa_code,'894');

-- Bug#3964284 Added the following cursor to get the custom percentage.
CURSOR ghr_mass_percent(p_pay_plan VARCHAR2,
			            p_grade    VARCHAR2,
                        p_prd      NUMBER,
			            p_msl_id   NUMBER
			           ) IS
SELECT ext.increase_percent percent
FROM   ghr_mass_salary_criteria criteria, ghr_mass_salary_criteria_ext ext
WHERE  criteria.mass_salary_id = p_msl_id
AND    criteria.mass_salary_criteria_id=ext.mass_salary_criteria_id
AND    criteria.pay_plan = p_pay_plan
AND    criteria.PAY_RATE_DETERMINANT = p_prd
And    ext.GRADE = p_grade;

l_proc    varchar2(72) :=  g_package || '.pop_dtls_from_pa_req';
l_sel_flag VARCHAR2(3) := NULL;
l_comments VARCHAR2(150) := NULL;
l_increase_percent ghr_mass_actions_preview.increase_percent%type;
l_ses_basic_pay    ghr_mass_actions_preview.to_basic_pay%type;

BEGIN
    g_proc  := 'pop_dtls_from_pa_req';

    hr_utility.set_location('Entering    ' || l_proc,5);
    FOR pa_req_rec in ghr_pa_req_cur
    LOOP
        -- To calculate percent increase from From Pay and To Pay if rpa_type = 'MPC'.
		IF pa_req_rec.rpa_type = 'MPC' THEN
			-- Bug#3964284 Get the customized increase percent from History using get_extra_info_comments procedure.
            -- If the value is NULL THEN
            --     Get the value from the table ghr_mass_salary_criteria_ext.
			-- End If;
			get_extra_info_comments
                (p_person_id => p_person_id,
                 p_effective_date => p_effective_date,
                 p_sel_flag    => l_sel_flag,
                 p_comments    => l_comments,
	             p_mass_salary_id => p_mass_salary_id,
    		     p_increase_percent => l_increase_percent,
		     p_ses_basic_pay    => l_ses_basic_pay);

            IF l_increase_percent is NULL THEN
                For cur in ghr_mass_percent(pa_req_rec.from_pay_plan,
                                             pa_req_rec.from_grade_or_level,
                                             pa_req_rec.pay_rate_determinant,
                                             p_mass_salary_id)
                LOOP
                   l_increase_percent := cur.percent;
                END LOOP;
            END IF;
		ELSE
			l_increase_percent := NULL;
		END IF;

     create_mass_act_prev (
			p_effective_date          => p_effective_date,
			p_date_of_birth           =>  pa_req_rec.employee_date_of_birth,
			p_full_name               => pa_req_rec.full_name,
			p_national_identifier     =>   pa_req_rec.employee_national_identifier,
			p_duty_station_code       => pa_req_rec.duty_station_code,
			p_duty_station_desc       => pa_req_rec.duty_station_desc,
			p_personnel_office_id     => pa_req_rec.personnel_office_id,
			p_basic_pay               =>pa_req_rec.from_basic_pay,
			p_new_basic_pay           => pa_req_rec.to_basic_pay,
			--Bug#2383992 Added old_adj_basic_pay
			p_adj_basic_pay           => pa_req_rec.from_adj_basic_pay,
			p_new_adj_basic_pay       => pa_req_rec.to_adj_basic_pay,
			p_old_avail_pay           =>  pa_req_rec.from_availability_pay,
			p_new_avail_pay           =>   pa_req_rec.to_availability_pay,
			p_old_loc_diff            =>  pa_req_rec.from_locality_adj,
			p_new_loc_diff            => pa_req_rec.to_locality_adj,
			p_tot_old_sal             =>   pa_req_rec.from_total_salary,
			p_tot_new_sal             =>   pa_req_rec.to_total_salary,
			p_old_auo_pay             =>  pa_req_rec.from_au_overtime,
			p_new_auo_pay             =>  pa_req_rec.to_au_overtime,
			p_position_id             => pa_req_rec.position_id,
			p_position_title          => pa_req_rec.position_title,
            -- FWFA Changes Bug#4444609
            p_position_number         => pa_req_rec.position_number,
            p_position_seq_no         => pa_req_rec.position_seq_no,
            -- FWFA Changes
			p_org_structure_id        => pa_req_rec.org_structure_id,
			p_agency_sub_element_code =>  pa_req_rec.from_agency_code,
			p_person_id               => pa_req_rec.person_id,
			p_mass_salary_id          =>  p_mass_salary_id,
			p_sel_flg                 => 'Y', --- Sel flag
			p_first_action_la_code1   => pa_req_rec.first_action_la_code1,
			p_first_action_la_code2   =>  pa_req_rec.first_action_la_code2,
			p_remark_code1            => pa_req_rec.remark_code1,   --- will be null
			p_remark_code2            => pa_req_rec.remark_code2,    --- will be null
			p_grade_or_level          => pa_req_rec.from_grade_or_level,
			p_step_or_rate            =>  pa_req_rec.from_step_or_rate,
			p_pay_plan                => pa_req_rec.from_pay_plan,
			p_pay_rate_determinant    =>  pa_req_rec.pay_rate_determinant,
			p_tenure                  => pa_req_rec.tenure,
			p_action                  => 'REPORT',
			p_assignment_id           => pa_req_rec.employee_assignment_id,
			p_old_other_pay           => pa_req_rec.from_other_pay_amount,
			p_new_other_pay           => pa_req_rec.to_other_pay_amount,
			-- Bug#2383992
			p_old_capped_other_pay    => pa_req_rec.from_capped_other_pay,
			p_new_capped_other_pay    => pa_req_rec.to_capped_other_pay,
			p_old_retention_allowance => pa_req_rec.from_retention_allowance,
			p_new_retention_allowance => pa_req_rec.to_retention_allowance,
			p_old_supervisory_differential => pa_req_rec.from_supervisory_differential,
			p_new_supervisory_differential => pa_req_rec.to_supervisory_differential,
			-- BUG 3377958 Madhuri
			p_organization_name            =>  p_org_name,
  		    p_increase_percent             => l_increase_percent,
			-- Bug#2383992
            -- FWFA Changes Bug#4444609
            p_input_pay_rate_determinant     =>  pa_req_rec.input_pay_rate_determinant,
            p_from_pay_table_id            =>  pa_req_rec.from_pay_table_identifier,
            p_to_pay_table_id              =>  pa_req_rec.to_pay_table_identifier
            -- FWFA Changes
  		     );
       exit;
     END LOOP;
     hr_utility.set_location('Exiting    ' || l_proc,10);
exception
  when msl_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
end pop_dtls_from_pa_req;


--
--
--

function check_select_flg_msl_perc(p_person_id in number,
                          p_action in varchar2,
                          p_effective_date in date,
                          p_mass_salary_id in number,
                          p_sel_flg in out nocopy varchar2,
						  p_increase_percent in out nocopy number
			  )
return boolean IS

   l_per_ei_data        per_people_extra_info%rowtype;
   l_comments varchar2(250);
   l_sel_flag varchar2(3);
   l_line number := 0;
   l_proc     varchar2(72) :=  g_package || '.check_select_flg_msl_perc';
   l_increase_percent ghr_mass_actions_preview.increase_percent%type; -- Added by Sundar 3843306
   l_ses_basic_pay    ghr_mass_actions_preview.to_basic_pay%type;
   l_temp_increase_percent number;
begin

  g_proc  := 'check_select_flg_msl_perc';
  l_temp_increase_percent := p_increase_percent;

  hr_utility.set_location('Entering    ' || l_proc,5);

l_line := 5;
     get_extra_info_comments(p_person_id,p_effective_date,l_sel_flag,l_comments,p_mass_salary_id,l_increase_percent,l_ses_basic_pay); -- Added by Sundar 3843306

		--------- Initialize the comments
		-- Sundar 3337361 Included GM Error, To basic pay < From basic pay in the condition
		-- Now all the messages have MSL as a prefix. Rest of the conditions are alo
		-- included for the old records which may still have old message.
     IF l_comments is not null THEN
       --Bug#4093705 Added ltrim function to verify the System generated Comments as few comments
       --            might start with Blank Spaces. Removed NVL condition as control comes here
       --            only when l_comments has Non Null value.
       IF substr(ltrim(l_comments),1,8) = 'Exceeded'
		OR substr(ltrim(l_comments),1,3) = 'MSL'
		OR substr(ltrim(l_comments),1,5) = 'Error'
		OR substr(ltrim(l_comments),1,13) = 'The From Side'
	   THEN
          ins_upd_per_extra_info
               (p_person_id,p_effective_date, l_sel_flag, null,p_mass_salary_id,l_increase_percent);
       END IF;
     END IF;
   -- Bug 3843306 If Increase percent is entered from Preview screen, the same should be retrieved
   -- and not the one entered in Grade screen.

    IF l_increase_percent IS NOT NULL THEN
		p_increase_percent := l_increase_percent;
    END IF;
    -- 8320557 added to not check percentage is 0 for pay band conversion
    IF not ghr_msl_pkg.g_sl_payband_conv then
    IF p_increase_percent = 0 THEN
		l_sel_flag := 'N';
    END IF;
    END IF;

	l_line := 10;
     if l_sel_flag is null then
          p_sel_flg := 'Y';
     else
          p_sel_flg := l_sel_flag;
     end if;

	l_line := 15;
     if p_action IN ('SHOW','REPORT') THEN
         return TRUE;
     elsif p_action = 'CREATE' THEN
         if p_sel_flg = 'Y' THEN
            return TRUE;
         else
            return FALSE;
         end if;
     end if;
exception
  when msl_error then raise;
  when others then
     p_increase_percent := l_temp_increase_percent ;
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||' @'||to_char(l_line)||'  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
end;

--
--
--
function check_select_flg(p_person_id in number,
                          p_action in varchar2,
                          p_effective_date in date,
                          p_mass_salary_id in number,
                          p_sel_flg in out nocopy varchar2
			  )
return boolean IS

   l_per_ei_data        per_people_extra_info%rowtype;
   l_comments varchar2(250);
   l_sel_flag varchar2(3);
   l_line number := 0;
   l_temp NUMBER;
   l_ses_basic_pay    ghr_mass_actions_preview.to_basic_pay%type;

   l_proc     varchar2(72) :=  g_package || '.check_select_flg';
begin

  g_proc  := 'check_select_flg';

  hr_utility.set_location('Entering    ' || l_proc,5);

l_line := 5;
     get_extra_info_comments(p_person_id,p_effective_date,l_sel_flag,l_comments,p_mass_salary_id,l_temp,l_ses_basic_pay);

		--------- Initialize the comments
		-- Sundar 3337361 Included GM Error, To basic pay < From basic pay in the condition
		-- Now all the messages have MSL as a prefix. Rest of the conditions are alo
		-- included for the old records which may still have old message.
     IF l_comments is not null THEN
       IF substr(nvl(l_comments,'@#%'),1,8) = 'Exceeded'
		OR substr(nvl(l_comments,'@#%'),1,3) = 'MSL'
		OR substr(nvl(l_comments,'@#%'),1,5) = 'Error'
		OR substr(nvl(l_comments,'@#%'),1,13) = 'The From Side'
	   THEN
          ins_upd_per_extra_info
               (p_person_id,p_effective_date, l_sel_flag, null,p_mass_salary_id);
       END IF;
     END IF;
---------


	l_line := 10;
     if l_sel_flag is null then
          p_sel_flg := 'Y';
     else
          p_sel_flg := l_sel_flag;
     end if;

	l_line := 15;
     if p_action IN ('SHOW','REPORT') THEN
         return TRUE;
     elsif p_action = 'CREATE' THEN
         if p_sel_flg = 'Y' THEN
            return TRUE;
         else
            return FALSE;
         end if;
     end if;
exception
  when msl_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||' @'||to_char(l_line)||'  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
end;


--
--
--


procedure purge_old_data (p_mass_salary_id in number) is
l_proc   varchar2(72) :=  g_package || '.purge_old_data';
BEGIN
   g_proc  := 'purge_old_data';

   hr_utility.set_location('Entering    ' || l_proc,5);
   delete from ghr_mass_actions_preview
    where mass_action_type = 'SALARY'
      and session_id  = p_mass_salary_id;
   commit;
   hr_utility.set_location('Exiting    ' || l_proc,10);
exception
  when msl_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
END;

--
--
--

PROCEDURE get_pay_plan_and_table_id (p_prd in varchar2,
                        p_person_id in number,
                        p_position_id in per_assignments_f.position_id%type,
                        p_effective_date in date,
                        p_grade_id in per_assignments_f.grade_id%type,
                        p_assignment_id in per_assignments_f.assignment_id%type,
                        p_action in varchar2,
                        p_pay_plan out nocopy varchar2,
                        p_pay_table_id out nocopy number,
                        p_grade_or_level out nocopy varchar2,
                        p_step_or_rate   out nocopy varchar2,
                        p_pay_basis out nocopy varchar2) is

p_person_extra_info_id number;
----p_locality_percent number;       --- AVR 12/08/98

l_pos_ei_data         per_position_extra_info%rowtype;
l_asg_ei_data         per_assignment_extra_info%rowtype;

cursor c_grade_kff (grd_id number) is
        select gdf.segment1
              ,gdf.segment2
          from per_grades grd,
               per_grade_definitions gdf
         where grd.grade_id = grd_id
           and grd.grade_definition_id = gdf.grade_definition_id;

   l_retained_grade_rec  ghr_pay_calc.retained_grade_rec_type;
l_proc     varchar2(72) :=  g_package || '.get_pay_plan_and_table_id';
l_line number := 0;
l_check_grade_retention VARCHAR2(200);
BEGIN
  g_proc  := 'get_pay_plan_and_table_id';
  hr_utility.set_location('Entering    ' || l_proc,5);
  ghr_mre_pkg.pr('Entering ',l_proc,'ACTION '||p_action);
  -- Bug# 4126137,4179270,4086677
  l_check_grade_retention := CHECK_GRADE_RETENTION(P_PRD,P_PERSON_ID,P_EFFECTIVE_DATE);

  IF p_action = 'CREATE' THEN

l_line := 10;
        FOR c_grade_kff_rec IN c_grade_kff (p_grade_id)
        LOOP
           p_pay_plan          := c_grade_kff_rec.segment1;
           p_grade_or_level    := c_grade_kff_rec.segment2;
           exit;
        end loop;

l_line := 20;
  hr_utility.set_location('Got grade or level and pay plan',2);
  ghr_mre_pkg.pr('Got grade or level and pay plan');

        ghr_history_fetch.fetch_positionei
                        (p_position_id      => p_position_id
                        ,p_information_type => 'GHR_US_POS_VALID_GRADE'
                        ,p_date_effective   => p_effective_date
                        ,p_pos_ei_data      => l_pos_ei_data
                        );

l_line := 30;
        P_PAY_table_id  := l_pos_ei_data.poei_information5;
        P_PAY_BASIS     := l_pos_ei_data.poei_information6;

  ghr_mre_pkg.pr(' Before fetch asgei', to_char(p_assignment_id));

        ghr_history_fetch.fetch_asgei
                        (p_assignment_id         => p_assignment_id
                        ,p_information_type      => 'GHR_US_ASG_SF52'
                        ,p_date_effective        => p_effective_date
                        ,p_asg_ei_data           => l_asg_ei_data
                        );

l_line := 40;
        p_step_or_rate           :=  l_asg_ei_data.aei_information3;

     ELSIF l_check_grade_retention = 'REGULAR' THEN
  hr_utility.set_location('Grade retention is regular',1);

  ghr_mre_pkg.pr('Grade retention is regular',1);

        FOR c_grade_kff_rec IN c_grade_kff (p_grade_id)
        LOOP
           p_pay_plan          := c_grade_kff_rec.segment1;
           p_grade_or_level    := c_grade_kff_rec.segment2;
           exit;
        end loop;

  hr_utility.set_location('Got grade or level and pay plan',2);

  ghr_mre_pkg.pr('Got grade or level and pay plan',2);

l_line := 50;
        ghr_history_fetch.fetch_positionei
                        (p_position_id      => p_position_id
                        ,p_information_type => 'GHR_US_POS_VALID_GRADE'
                        ,p_date_effective   => p_effective_date
                        ,p_pos_ei_data      => l_pos_ei_data
                        );

        P_PAY_table_id  := l_pos_ei_data.poei_information5;
        P_PAY_BASIS     := l_pos_ei_data.poei_information6;

l_line := 60;

  ghr_mre_pkg.pr('before fetch asgei 2 ',to_char(p_assignment_id));

        ghr_history_fetch.fetch_asgei
                        (p_assignment_id         => p_assignment_id
                        ,p_information_type      => 'GHR_US_ASG_SF52'
                        ,p_date_effective        => p_effective_date
                        ,p_asg_ei_data           => l_asg_ei_data
                        );
        p_step_or_rate           :=  l_asg_ei_data.aei_information3;

l_line := 70;
    ELSIF l_check_grade_retention = 'RETAIN' THEN
     --
     -- get retained details
     --
     hr_utility.set_location('Before get retained grade',4);

l_line := 80;
  ghr_mre_pkg.pr('Retained prd ',P_PRD);

  ghr_mre_pkg.pr('before get retained grade 2 ',to_char(p_person_id));

       BEGIN
           l_retained_grade_rec :=
                   ghr_pc_basic_pay.get_retained_grade_details
                                      ( p_person_id,
                                        p_effective_date);
           p_person_extra_info_id := l_retained_grade_rec.person_extra_info_id;
           p_pay_plan        := l_retained_grade_rec.pay_plan;
           p_grade_or_level  := l_retained_grade_rec.grade_or_level;
           p_step_or_rate    := l_retained_grade_rec.step_or_rate;
           p_pay_basis       := l_retained_grade_rec.pay_basis;
           p_pay_table_id    := l_retained_grade_rec.user_table_id;
 --        p_locality_percent  := l_retained_grade_rec.locality_percent;  --AVR 12/08/98
       EXCEPTION
          WHEN ghr_pay_calc.pay_calc_message THEN
             IF p_action = 'CREATE' THEN
                l_mslerrbuf := 'Error in Get retained grade for Person ID'||
                          to_char(p_person_id)||
                         'Error is '||' Sql Err is '|| sqlerrm(sqlcode);
                ghr_mre_pkg.pr('Person id '||to_char(p_person_id),'ERROR 1',l_mslerrbuf);
                raise msl_error;
             END IF;
          WHEN others THEN
                l_mslerrbuf := 'Others error in Get retained grade '||
                         'Error is '||' Sql Err is '|| sqlerrm(sqlcode);
                ghr_mre_pkg.pr('Person ID '||to_char(p_person_id),'ERROR 2',l_mslerrbuf);
                raise msl_error;
       END;
l_line := 90;
   -- Bug#4179270,4126137,4086677 Added the following ELSIF Condition.
   ELSIF l_check_grade_retention ='MSL_ERROR' THEN
       hr_utility.set_message(8301,'GHR_38927_MISSING_MA_RET_DET');
       raise msl_error;
   ELSIF l_check_grade_retention = 'OTHER_ERROR' THEN
     l_mslerrbuf := 'Others error in check_grade_retention function while fetching retained grade record. Please
                     verify the retained grade record';
      raise msl_error;
   END IF;
   hr_utility.set_location('Exiting    ' || l_proc,10);
l_line := 100;
EXCEPTION
   when msl_error then raise;
   when others then
        raise msl_error;
END get_pay_plan_and_table_id;

--
--

-- Bug#5089732 Added p_to_grade_id,p_to_pay_plan, p_to_grade_or_level parameters.
PROCEDURE get_pay_plan_and_table_id (p_prd in varchar2,
                        p_person_id in number,
                        p_position_id in per_assignments_f.position_id%type,
                        p_effective_date in date,
                        p_grade_id in per_assignments_f.grade_id%type,
                        p_to_grade_id out nocopy per_assignments_f.grade_id%type,
                        p_assignment_id in per_assignments_f.assignment_id%type,
                        p_action in varchar2,
                        p_pay_plan out nocopy varchar2,
			            p_to_pay_plan out nocopy varchar2,
                        p_pay_table_id out nocopy number,
                        p_grade_or_level out nocopy varchar2,
			            p_to_grade_or_level out nocopy varchar2,
                        p_step_or_rate   out nocopy varchar2,
                        p_pay_basis out nocopy varchar2) is

p_person_extra_info_id number;
--p_locality_percent number;       --- AVR 12/08/98

l_pos_ei_data         per_position_extra_info%rowtype;
l_asg_ei_data         per_assignment_extra_info%rowtype;


cursor c_grade_kff (grd_id number) is
        select gdf.segment1
              ,gdf.segment2
          from per_grades grd,
               per_grade_definitions gdf
         where grd.grade_id = grd_id
           and grd.grade_definition_id = gdf.grade_definition_id;

l_retained_grade_rec  ghr_pay_calc.retained_grade_rec_type;
l_proc     varchar2(72) :=  g_package || '.get_pay_plan_and_table_id';
l_line number := 0;
l_check_grade_retention VARCHAR2(200);
BEGIN
  g_proc  := 'get_pay_plan_and_table_id';
  hr_utility.set_location('Entering    ' || l_proc,5);
  ghr_mre_pkg.pr('Entering ',l_proc,'ACTION '||p_action);
  -- Bug# 4126137,4179270,4086677
  l_check_grade_retention := CHECK_GRADE_RETENTION(P_PRD,P_PERSON_ID,P_EFFECTIVE_DATE);

  IF p_action = 'CREATE' THEN

l_line := 10;
        FOR c_grade_kff_rec IN c_grade_kff (p_grade_id)
        LOOP
           p_pay_plan          := c_grade_kff_rec.segment1;
           p_grade_or_level    := c_grade_kff_rec.segment2;
           exit;
        end loop;

l_line := 20;
  hr_utility.set_location('Got grade or level and pay plan',2);
  ghr_mre_pkg.pr('Got grade or level and pay plan');

        ghr_history_fetch.fetch_positionei
                        (p_position_id      => p_position_id
                        ,p_information_type => 'GHR_US_POS_VALID_GRADE'
                        ,p_date_effective   => p_effective_date
                        ,p_pos_ei_data      => l_pos_ei_data
                        );

l_line := 30;
        -- Bug#5089732 Added the cursor to fetch the pay plan as on effective date.
        p_to_grade_id := l_pos_ei_data.poei_information3;
        FOR c_grade_kff_rec IN c_grade_kff (p_to_grade_id)
        LOOP
           p_to_pay_plan          := c_grade_kff_rec.segment1;
           p_to_grade_or_level    := c_grade_kff_rec.segment2;
           exit;
        END LOOP;
        -- Pass the position pay plan, grade or level as output for comparison, pay calculation.
        IF p_to_pay_plan <> p_pay_plan THEN
           p_pay_plan := p_to_pay_plan;
           p_grade_or_level := p_to_grade_or_level;
        END IF;

        P_PAY_table_id  := l_pos_ei_data.poei_information5;
        P_PAY_BASIS     := l_pos_ei_data.poei_information6;

  ghr_mre_pkg.pr(' Before fetch asgei', to_char(p_assignment_id));

        ghr_history_fetch.fetch_asgei
                        (p_assignment_id         => p_assignment_id
                        ,p_information_type      => 'GHR_US_ASG_SF52'
                        ,p_date_effective        => p_effective_date
                        ,p_asg_ei_data           => l_asg_ei_data
                        );

l_line := 40;
        p_step_or_rate           :=  l_asg_ei_data.aei_information3;

     ELSIF l_check_grade_retention = 'REGULAR' THEN
  hr_utility.set_location('Grade retention is regular',1);

  ghr_mre_pkg.pr('Grade retention is regular',1);

        FOR c_grade_kff_rec IN c_grade_kff (p_grade_id)
        LOOP
           p_pay_plan          := c_grade_kff_rec.segment1;
           p_grade_or_level    := c_grade_kff_rec.segment2;
           exit;
        end loop;

  hr_utility.set_location('Got grade or level and pay plan',2);

  ghr_mre_pkg.pr('Got grade or level and pay plan',2);

l_line := 50;
        ghr_history_fetch.fetch_positionei
                        (p_position_id      => p_position_id
                        ,p_information_type => 'GHR_US_POS_VALID_GRADE'
                        ,p_date_effective   => p_effective_date
                        ,p_pos_ei_data      => l_pos_ei_data
                        );
        -- Bug#5089732 Added the cursor to fetch the pay plan as on effective date.
        p_to_grade_id := l_pos_ei_data.poei_information3;
        FOR c_grade_kff_rec IN c_grade_kff (p_to_grade_id)
        LOOP
           p_to_pay_plan          := c_grade_kff_rec.segment1;
           p_to_grade_or_level    := c_grade_kff_rec.segment2;
           exit;
        end loop;
         -- Pass the position pay plan, grade or level as output for comparison, pay calculation.
        IF p_to_pay_plan <> p_pay_plan THEN
           p_pay_plan := p_to_pay_plan;
           p_grade_or_level := p_to_grade_or_level;
        END IF;
        P_PAY_table_id  := l_pos_ei_data.poei_information5;
        P_PAY_BASIS     := l_pos_ei_data.poei_information6;

l_line := 60;

  ghr_mre_pkg.pr('before fetch asgei 2 ',to_char(p_assignment_id));

        ghr_history_fetch.fetch_asgei
                        (p_assignment_id         => p_assignment_id
                        ,p_information_type      => 'GHR_US_ASG_SF52'
                        ,p_date_effective        => p_effective_date
                        ,p_asg_ei_data           => l_asg_ei_data
                        );
        p_step_or_rate           :=  l_asg_ei_data.aei_information3;

l_line := 70;
    ELSIF l_check_grade_retention = 'RETAIN' THEN
     --
     -- get retained details
     --
     hr_utility.set_location('Before get retained grade',4);

l_line := 80;
  ghr_mre_pkg.pr('Retained prd ',P_PRD);

  ghr_mre_pkg.pr('before get retained grade 2 ',to_char(p_person_id));

       BEGIN
           l_retained_grade_rec :=
                   ghr_pc_basic_pay.get_retained_grade_details
                                      ( p_person_id,
                                        p_effective_date);
           p_person_extra_info_id := l_retained_grade_rec.person_extra_info_id;
           p_pay_plan        := l_retained_grade_rec.pay_plan;
           p_grade_or_level  := l_retained_grade_rec.grade_or_level;
           p_step_or_rate    := l_retained_grade_rec.step_or_rate;
           p_pay_basis       := l_retained_grade_rec.pay_basis;
           p_pay_table_id    := l_retained_grade_rec.user_table_id;
 --        p_locality_percent  := l_retained_grade_rec.locality_percent;  --AVR 12/08/98
       EXCEPTION
          WHEN ghr_pay_calc.pay_calc_message THEN
             IF p_action = 'CREATE' THEN
                l_mslerrbuf := 'Error in Get retained grade for Person ID'||
                          to_char(p_person_id)||
                         'Error is '||' Sql Err is '|| sqlerrm(sqlcode);
                ghr_mre_pkg.pr('Person id '||to_char(p_person_id),'ERROR 1',l_mslerrbuf);
                raise msl_error;
             END IF;
          WHEN others THEN
                l_mslerrbuf := 'Others error in Get retained grade '||
                         'Error is '||' Sql Err is '|| sqlerrm(sqlcode);
                ghr_mre_pkg.pr('Person ID '||to_char(p_person_id),'ERROR 2',l_mslerrbuf);
                raise msl_error;
       END;
l_line := 85;
       -- Bug#5089732 Pass the to to position pay plan, grade, grade_id also.
       p_to_grade_id := p_grade_id;
       FOR c_grade_kff_rec IN c_grade_kff (p_to_grade_id)
        LOOP
           p_to_pay_plan          := c_grade_kff_rec.segment1;
           p_to_grade_or_level    := c_grade_kff_rec.segment2;
           exit;
        END LOOP;
l_line := 90;
   -- Bug#4179270,4126137,4086677 Added the following ELSIF Condition.
   ELSIF l_check_grade_retention ='MSL_ERROR' THEN
       hr_utility.set_message(8301,'GHR_38927_MISSING_MA_RET_DET');
       raise msl_error;
   ELSIF l_check_grade_retention = 'OTHER_ERROR' THEN
     l_mslerrbuf := 'Others error in check_grade_retention function while fetching retained grade record. Please
                     verify the retained grade record';
      raise msl_error;
   END IF;
   hr_utility.set_location('Exiting    ' || l_proc,10);
l_line := 100;
EXCEPTION
   when msl_error then raise;
   when others then
        raise msl_error;
END get_pay_plan_and_table_id;

--
--

procedure update_sel_flg (p_person_id in number,p_effective_date date) is

   l_person_extra_info_id number;
   l_object_version_number number;
   l_per_ei_data         per_people_extra_info%rowtype;
   l_proc  varchar2(72) :=  g_package || '.update_sel_flg';
l_ind number := 1;
begin
  g_proc  := 'update_sel_flg';
   hr_utility.set_location('Entering    ' || l_proc,5);
pr('Inside '||l_proc,to_char(p_person_id));
l_ind := 10;
   ghr_history_fetch.fetch_peopleei
                  (p_person_id             => p_person_id
                  ,p_information_type      => 'GHR_US_PER_MASS_ACTIONS'
                  ,p_date_effective        => p_effective_date
                  ,p_per_ei_data           => l_per_ei_data);

l_ind := 20;
   l_person_extra_info_id  := l_per_ei_data.person_extra_info_id;
   l_object_version_number := l_per_ei_data.object_version_number;

   if l_person_extra_info_id is not null then
      ghr_person_extra_info_api.update_person_extra_info
                   (P_PERSON_EXTRA_INFO_ID   => l_person_extra_info_id
                   ,P_EFFECTIVE_DATE         => sysdate
                   ,P_OBJECT_VERSION_NUMBER  => l_object_version_number
                   ,p_pei_INFORMATION3       => NULL
                   ,p_pei_INFORMATION4       => NULL
                   ,p_pei_INFORMATION5       => NULL
		   -- Bug#3988449 Added p_pei_information10 to clear the increase percentage value.
		   ,p_pei_information10      => NULL
                   ,P_PEI_INFORMATION_CATEGORY  => 'GHR_US_PER_MASS_ACTIONS');

l_ind := 30;
     hr_utility.set_location('Exiting    ' || l_proc,10);
-- There is a trigger on PER_PEOPLE_EXTRA_INFO to make the employee INVALID
-- when there is a update done on the table.
---Commented the following three lines to remove Validation functionality on Person.
---   ghr_validate_perwsepi.validate_perwsepi(p_person_id);
---   l_ind := 40;
---   ghr_validate_perwsepi.update_person_user_type(p_person_id);
   end if;

l_ind := 50;
  pr('Exiting '||l_proc,to_char(p_person_id));
exception
  when msl_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||
                           ' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||' at '||to_char(l_ind)||
                          '  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
end update_sel_flg;

--
--
--

FUNCTION GET_PAY_PLAN_NAME (PP IN VARCHAR2) RETURN VARCHAR2 IS

 CURSOR CUR_PP IS
 select pay_plan,description
   from ghr_pay_plans
  WHERE PAY_PLAN = PP;
  l_pp_desc varchar2(150);
BEGIN
  FOR PP_REC IN CUR_PP
  LOOP
     l_pp_desc := pp_rec.description;
     exit;
  END LOOP;
  return (l_pp_desc);
END;

FUNCTION GET_USER_TABLE_name (P_USER_TABLE_id IN NUMBER) RETURN VARCHAR2 IS
   CURSOR MSL_CUR IS
   select user_table_id,substr(user_table_name,0,4) user_table_name
     from pay_user_tables
         where substr(user_table_name,6,14) in
                     ('Oracle Federal','Federal Agency')
           and user_table_id = p_user_table_id;
  l_user_table_name varchar2(80);
BEGIN
    for msl in msl_cur
    LOOP
       l_user_table_name := msl.user_table_name;
       exit;
    end loop;
    return (l_user_table_name);
END;

--
--
--
/*
Procedure to get Person EI for MSL Percentage.
*/

PROCEDURE get_extra_info_comments
                (p_person_id in number,
                 p_effective_date in date,
                 p_sel_flag    in out nocopy varchar2,
                 p_comments    in out nocopy varchar2,
		 p_mass_salary_id in number,
		 p_increase_percent out nocopy number,
		 p_ses_basic_pay out nocopy number) is

  l_per_ei_data        per_people_extra_info%rowtype;
  l_proc  varchar2(72) := g_package || '.get_extra_info_comments';
  l_eff_date date;

  CURSOR chk_history (p_person_id in NUMBER ,
                      eff_date    in Date) IS
   select information9  info9
         ,information10 info10
	 ,information11 info11
	 ,information16 increase_percent -- Added by Sundar 3843306
	 ,information17 info17
   from ghr_pa_history
   where person_id = p_person_id
   and pa_history_id IN ( select max(pa_history_id)
                          from ghr_pa_history
                          where person_id  = p_person_id
                          and information5 = 'GHR_US_PER_MASS_ACTIONS'
                          and table_name   = 'PER_PEOPLE_EXTRA_INFO'
                          and effective_date = eff_date
                          group by  information11);

begin
  g_proc  := 'get_extra_info_comments';
  hr_utility.set_location('Entering    ' || l_proc,5);

  l_eff_date := p_effective_date;

  ghr_history_fetch.fetch_peopleei
                  (p_person_id             => p_person_id
                  ,p_information_type      => 'GHR_US_PER_MASS_ACTIONS'
                  ,p_date_effective        => l_eff_date
                  ,p_per_ei_data           => l_per_ei_data);

   --Bug#3988449 Added NVL and to_number in the following condition
   IF NVL(to_number(l_per_ei_data.pei_information5),hr_api.g_number) <> NVL(p_mass_salary_id,hr_api.g_number) then
      p_sel_flag := 'Y';
      p_comments := null;
      p_increase_percent := null;
      p_ses_basic_pay := null;
   else
      p_sel_flag := l_per_ei_data.pei_information3;
      p_comments := l_per_ei_data.pei_information4;
      p_increase_percent := l_per_ei_data.pei_information10; -- Added by Sundar 3843306
      p_ses_basic_pay    := l_per_ei_data.pei_information11;
   end if;

    --Bug#3988449 Added NVL and to_number to l_per_ei_data.pei_information5, p_mass_salary_id.
    IF  p_sel_flag IS NOT NULL and
        NVL(to_number(l_per_ei_data.pei_information5),hr_api.g_number) <> NVL(p_mass_salary_id,hr_api.g_number) THEN
     FOR chk_history_rec in chk_history(p_person_id => p_person_id,
					eff_date => l_eff_date) loop
       If chk_history_rec.info11 = p_mass_salary_id then
          p_sel_flag := chk_history_rec.info9;
	  p_comments := chk_history_rec.info10;--Added by Ashley
	  p_increase_percent := chk_history_rec.increase_percent; -- Added by Sundar 3843306
	  p_ses_basic_pay    := chk_history_rec.info11; -- Added by Sundar 3843306
       END IF;
     END LOOP;
   END IF;


exception
  when msl_error then
  p_increase_percent := NULL;
  raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     p_increase_percent := NULL;
     p_ses_basic_pay    := NULL;
     raise msl_error;
end;

--
--
--



procedure ins_upd_per_extra_info
               (p_person_id in number,
			    p_effective_date in date,
                p_sel_flag in varchar2,
				p_comment in varchar2,
				p_msl_id in number,
				p_increase_percent in number default NULL) is

   l_person_extra_info_id number;
   l_object_version_number number;
   l_per_ei_data         per_people_extra_info%rowtype;

   CURSOR people_ext_cur (person number) is
   SELECT person_extra_info_id, object_version_number
     FROM PER_people_EXTRA_INFO
    WHERE person_ID = person
      and information_type = 'GHR_US_PER_MASS_ACTIONS';

    l_proc    varchar2(72) :=  g_package || '.ins_upd_per_extra_info';
    l_eff_date date;

begin
  g_proc  := 'ins_upd_per_extra_info';
  hr_utility.set_location('Entering    ' || l_proc,5);
  if p_effective_date > sysdate then
       l_eff_date := sysdate;
  else
       l_eff_date := p_effective_date;
  end if;

   ghr_history_fetch.fetch_peopleei
                  (p_person_id           => p_person_id
                  ,p_information_type      => 'GHR_US_PER_MASS_ACTIONS'
                  ,p_date_effective        => l_eff_date
                  ,p_per_ei_data           => l_per_ei_data);

   l_person_extra_info_id  := l_per_ei_data.person_extra_info_id;
   l_object_version_number := l_per_ei_data.object_version_number;

   if l_person_extra_info_id is null then
      for per_ext_rec in people_ext_cur(p_person_id)
      loop
         l_person_extra_info_id  := per_ext_rec.person_extra_info_id;
         l_object_version_number := per_ext_rec.object_version_number;
      end loop;
   end if;

   if l_person_extra_info_id is not null then
        ghr_person_extra_info_api.update_person_extra_info
                       (P_PERSON_EXTRA_INFO_ID   => l_person_extra_info_id
                       ,P_EFFECTIVE_DATE           => trunc(l_eff_date)
                       ,P_OBJECT_VERSION_NUMBER    => l_object_version_number
                       ,p_pei_INFORMATION3        => p_sel_flag
                       ,p_pei_INFORMATION4        => p_comment
                       ,p_pei_INFORMATION5        => to_char(p_msl_id)
					   ,p_pei_information10       => to_char(p_increase_percent)
                       ,P_PEI_INFORMATION_CATEGORY  => 'GHR_US_PER_MASS_ACTIONS');
   else
        ghr_person_extra_info_api.create_person_extra_info
                       (P_pERSON_ID             => p_PERSON_id
                       ,P_INFORMATION_TYPE        => 'GHR_US_PER_MASS_ACTIONS'
                       ,P_EFFECTIVE_DATE          => trunc(l_eff_date)
                       ,p_pei_INFORMATION3       => p_sel_flag
                       ,p_pei_INFORMATION4       => p_comment
                       ,p_pei_INFORMATION5       => to_char(p_msl_id)
					   ,p_pei_information10       =>to_char(p_increase_percent)
                       ,P_PEI_INFORMATION_CATEGORY  => 'GHR_US_PER_MASS_ACTIONS'
                       ,P_pERSON_EXTRA_INFO_ID  => l_pERSON_extra_info_id
                       ,P_OBJECT_VERSION_NUMBER   => l_object_version_number);
   end if;

---Commented the following two lines to remove Validation functionality on Person.
-- ghr_validate_perwsepi.validate_perwsepi(p_person_id);
-- ghr_validate_perwsepi.update_person_user_type(p_person_id);

   hr_utility.set_location('Exiting    ' || l_proc,10);
exception
  when msl_error then raise;
  when others then
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
end ins_upd_per_extra_info;

--
-- Bug#5063304 Created this new procedure
PROCEDURE fetch_and_validate_emp(
                              p_action                     IN VARCHAR2
                             ,p_mass_salary_id             IN NUMBER
                             ,p_mass_salary_name           IN VARCHAR2
                             ,p_full_name                  IN per_people_f.full_name%TYPE
   			     ,p_national_identifier        IN per_people_f.national_identifier%TYPE
                             ,p_assignment_id              IN per_assignments_f.assignment_id%TYPE
			     ,p_person_id                  IN per_assignments_f.person_id%TYPE
			     ,p_position_id                IN per_assignments_f.position_id%TYPE
			     ,p_grade_id                   IN per_assignments_f.grade_id%TYPE
			     ,p_business_group_id          IN per_assignments_f.business_group_iD%TYPE
			     ,p_location_id                IN per_assignments_f.location_id%TYPE
			     ,p_organization_id            IN per_assignments_f.organization_id%TYPE
                             ,p_msl_organization_id        IN per_assignments_f.organization_id%TYPE
                             ,p_msl_duty_station_id        IN ghr_duty_stations_f.duty_station_id%TYPE
                             ,p_msl_personnel_office_id    IN VARCHAR2
                             ,p_msl_agency_code_subelement IN VARCHAR2
                             ,p_msl_user_table_id          IN NUMBER
                             ,p_rec_pp_prd                 IN pp_prd
                             ,p_personnel_office_id        OUT NOCOPY VARCHAR2
                             ,p_org_structure_id           OUT NOCOPY VARCHAR2
                             ,p_position_title             OUT NOCOPY VARCHAR2
                             ,p_position_number            OUT NOCOPY VARCHAR2
                             ,p_position_seq_no            OUT NOCOPY VARCHAR2
                             ,p_subelem_code               OUT NOCOPY VARCHAR2
                             ,p_duty_station_id     OUT NOCOPY ghr_duty_stations_f.duty_station_id%TYPE
                             ,p_tenure              OUT NOCOPY VARCHAR2
                             ,p_annuitant_indicator OUT NOCOPY VARCHAR2
                             ,p_pay_rate_determinant OUT NOCOPY VARCHAR2
                             ,p_work_schedule       OUT NOCOPY  VARCHAR2
                             ,p_part_time_hour      OUT NOCOPY VARCHAR2
                             ,p_to_grade_id         OUT NOCOPY per_assignments_f.grade_id%type
                             ,p_pay_plan            OUT NOCOPY VARCHAR2
                             ,p_to_pay_plan         OUT NOCOPY VARCHAR2
                             ,p_pay_table_id        OUT NOCOPY NUMBER
                             ,p_grade_or_level      OUT NOCOPY VARCHAR2
                             ,p_to_grade_or_level   OUT NOCOPY VARCHAR2
                             ,p_step_or_rate        OUT NOCOPY VARCHAR2
                             ,p_pay_basis           OUT NOCOPY VARCHAR2
                             ,p_elig_flag           OUT NOCOPY BOOLEAN
			                ) IS



    CURSOR msl_dtl_cur (cur_pay_plan varchar2, cur_prd varchar2) IS
    SELECT count(*) cnt
      FROM ghr_mass_salary_criteria
     WHERE mass_salary_id = p_mass_salary_id
       AND pay_plan = cur_pay_plan
       AND pay_rate_determinant = cur_prd;

    l_row_cnt               NUMBER := 0;
    l_pos_grp1_rec          per_position_extra_info%rowtype;
    l_assignment_id         per_assignments_f.assignment_id%TYPE;
    l_person_id             per_assignments_f.person_id%TYPE;
    l_position_id           per_assignments_f.position_id%TYPE;
    l_grade_id              per_assignments_f.grade_id%TYPE;
    l_business_group_id     per_assignments_f.business_group_iD%TYPE;
    l_location_id           per_assignments_f.location_id%TYPE;
    l_organization_id       per_assignments_f.organization_id%TYPE;
    l_tenure               VARCHAR2(35);
    l_annuitant_indicator  VARCHAR2(35);
    l_pay_rate_determinant VARCHAR2(35);
    l_work_schedule        VARCHAR2(35);
    l_part_time_hour       VARCHAR2(35);
    l_pay_table_id         NUMBER;
    l_pay_plan             VARCHAR2(30);
    l_grade_or_level       VARCHAR2(30);
    -- Bug#5089732 Added current pay plan, grade_or_level
    l_to_grade_id          NUMBER;
    l_to_pay_plan          VARCHAR2(30);
    l_to_grade_or_level    VARCHAR2(30);
    -- Bug#5089732
    l_step_or_rate         VARCHAR2(30);
    l_pay_basis            VARCHAR2(30);
    l_duty_station_id      NUMBER;
    l_duty_station_desc    ghr_pa_requests.duty_station_desc%type;
    l_duty_station_code    ghr_pa_requests.duty_station_code%type;
    l_effective_date       DATE;
    l_personnel_office_id  VARCHAR2(300);
    l_org_structure_id     VARCHAR2(300);
    l_sub_element_code     VARCHAR2(300);
    l_position_title       VARCHAR2(300);
    l_position_number      VARCHAR2(20);
    l_position_seq_no      VARCHAR2(20);
    l_log_text             VARCHAR2(2000) := null;
    l_retained_grade_rec  ghr_pay_calc.retained_grade_rec_type;
    l_fetch_poid_data       BOOLEAN := FALSE;
    l_fetch_ds_data         BOOLEAN := FALSE;
    l_fetch_agency_data     BOOLEAN := FALSE;
    init_elig_flag          BOOLEAN := FALSE;
    l_prd_matched           BOOLEAN := FALSE;
    l_prd_pp_matched        BOOLEAN := FALSE;


    l_proc   varchar2(72) :=  g_package || '.fetch_and_validate_emp';

BEGIN

    g_proc  := 'fetch_and_validate_emp';
    hr_utility.set_location('Entering    ' || l_proc,5);
    -- Bug#5623035 Moved the local variable assigning to here.
    l_assignment_id     := p_assignment_id;
    l_position_id       := p_position_id;
    l_grade_id          := p_grade_id;
    l_business_group_id := p_business_group_iD;
    l_location_id       := p_location_id;
    l_effective_date    := g_effective_date;

    -- Verify whether this process is required or not.
    IF p_msl_organization_id IS NOT NULL  OR
       p_msl_duty_station_id IS NOT NULL  OR
       p_msl_personnel_office_id IS NOT NULL  OR
       p_msl_agency_code_subelement IS NOT NULL THEN
        -- get the values and verify whether the record meets the condition or not.
        -- If Yes, proceed further. Otherwise, skip the other checks for this record

        hr_utility.set_location('The location id is:'||l_location_id,12345);
        hr_utility.set_location('MSL Org ID:'||p_msl_organization_id,11111);
        hr_utility.set_location('Org ID:'||p_organization_id,22222);
        IF NVL(p_msl_organization_id,p_organization_id) = p_organization_id THEN
            hr_utility.set_location('Org ID PASS',10);
            IF p_msl_personnel_office_id IS NOT NULL THEN
                hr_utility.set_location('POID CHECK',15);
                get_pos_grp1_ddf(l_position_id,
                                 l_effective_date,
                                 l_pos_grp1_rec);

                l_personnel_office_id :=  l_pos_grp1_rec.poei_information3;
                l_org_structure_id    :=  l_pos_grp1_rec.poei_information5;
                l_fetch_poid_data := TRUE;
            END IF;
            IF  (p_msl_personnel_office_id = l_personnel_office_id) OR
                NOT(l_fetch_poid_data) THEN
                hr_utility.set_location('POID PASS',20);
                IF p_msl_agency_code_subelement IS NOT NULL THEN
                    hr_utility.set_location('Agency CHECK',25);
                    get_sub_element_code_pos_title(l_position_id,
                                             p_person_id,
                                             l_business_group_id,
                                             l_assignment_id,
                                             l_effective_date,
                                             l_sub_element_code,
                                             l_position_title,
                                             l_position_number,
                                             l_position_seq_no);
                    l_fetch_agency_data := TRUE;
                END IF;
                -- Bug#5674003 Modified the following IF condition
                IF  (SUBSTR(p_msl_agency_code_subelement,1,2)  = SUBSTR(l_sub_element_code,1,2) AND
                     NVL(SUBSTR(p_msl_agency_code_subelement,3,2),SUBSTR(l_sub_element_code,3,2))=
                         SUBSTR(l_sub_element_code,3,2)
                    ) OR
                    NOT(l_fetch_agency_data) THEN
                                    hr_utility.set_location('Agency PASS',30);
                    IF p_msl_duty_station_id IS NOT NULL THEN
                        hr_utility.set_location('DS CHECK',35);
                        ghr_pa_requests_pkg.get_SF52_loc_ddf_details
                        (p_location_id      => l_location_id
                        ,p_duty_station_id  => l_duty_station_id);
                        l_fetch_ds_data := TRUE;
                    END IF;
                    IF (p_msl_duty_station_id = l_duty_station_id) OR
                       NOT(l_fetch_ds_data)THEN
                       hr_utility.set_location('DS PASS',40);
                        init_elig_flag := TRUE;
                    ELSE -- Duty Station not matching.
                       hr_utility.set_location('DS FAIL',45);
                        init_elig_flag := FALSE;
                    END IF;
                ELSE -- Agency Code Subelement Not matching.
                    hr_utility.set_location('Agency FAIL',55);
                    init_elig_flag := FALSE;
                END IF;
            ELSE -- Personnel Office ID not matching
                hr_utility.set_location('POID FAIL',65);
                init_elig_flag := FALSE;
            END IF;
        ELSE -- Organization_id is not matching.
            hr_utility.set_location('Org FAIL',75);
            init_elig_flag := FALSE;
        END IF;
    ELSE  -- If No value is entered for organization, Duty Station, Agency, POID of MSL Criteria.
       hr_utility.set_location('No INIT CRITERIA',85);
        init_elig_flag := TRUE;
    END IF;

    -- If the initial eligibility is passed then proceed further. Otherwise move to next record.
    IF init_elig_flag THEN
        hr_utility.set_location('Init Criteria Pass',95);
        ghr_pa_requests_pkg.get_sf52_asg_ddf_details
                                  (l_assignment_id,
                                   l_effective_date,
                                   l_tenure,
                                   l_annuitant_indicator,
                                   l_pay_rate_determinant,
                                   l_work_schedule,
                                   l_part_time_hour);

        FOR l_cnt in 1..p_rec_pp_prd.COUNT LOOP
           IF nvl(p_rec_pp_prd(l_cnt).prd,l_pay_rate_determinant) = l_pay_rate_determinant THEN
                hr_utility.set_location('PRD PASS',105);
                l_prd_matched := TRUE;
                exit;
           END IF;
        END LOOP;

        IF l_prd_matched THEN
            -- Bug#5089732 Used the overloaded procedure.
            BEGIN
                get_pay_plan_and_table_id
                      (l_pay_rate_determinant,p_person_id,
                       l_position_id,l_effective_date,
                       l_grade_id, l_to_grade_id,l_assignment_id,'SHOW',
                       l_pay_plan,l_to_pay_plan,l_pay_table_id,
                       l_grade_or_level, l_to_grade_or_level, l_step_or_rate,
                       l_pay_basis);
            -- Bug#4016384 Added the exception handling to report RG employees in the process log.
            EXCEPTION
                WHEN OTHERS THEN
                    -- Report the record in the process log if the pay table ID matches.
                    BEGIN
                        hr_utility.set_location('before calling expired_rg_det',10);
                        l_retained_grade_rec := ghr_pc_basic_pay.get_expired_rg_details
                                                  (p_person_id => p_person_id
                                                  ,p_effective_date => l_effective_date);
                        hr_utility.set_location('ret grd tableid:'||l_retained_grade_rec.user_table_id,99999);
                        hr_utility.set_location('MSL tableid:'||p_msl_user_table_id,99999);
                        IF l_retained_grade_rec.user_table_id = p_msl_user_table_id THEN
                            hr_utility.set_location('Rg table matches with MSL table ID',10);
                            l_log_text  := 'Error in RG Record In Mass Salary Name: '||
                                            p_mass_salary_name||'; Employee Name: '|| p_full_name ||
                                            '; SSN: ' || p_national_identifier || '; '||
                                            hr_utility.get_message;
                            BEGIN
                                ghr_mto_int.log_message(
                                      p_procedure => 'check_grade_retention',
                                      p_message   => l_log_text);
                                g_rg_recs_failed := g_rg_recs_failed + 1;
                            EXCEPTION
                                WHEN OTHERS THEN
                                   l_prd_pp_matched := FALSE;
                            END;
                        ELSE
                            l_prd_pp_matched := FALSE;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            hr_utility.set_location('WHEN OTHERS of EXPIRED RG ',999999);
                            l_prd_pp_matched := FALSE;
                    END;
                --WHEN OTHERS THEN
                    -- Skip this record from reporting.
                   -- l_prd_pp_matched := FALSE;
            END;
        END IF;

        FOR l_cnt in 1..p_rec_pp_prd.COUNT LOOP
           IF nvl(p_rec_pp_prd(l_cnt).prd,l_pay_rate_determinant) = l_pay_rate_determinant AND
              nvl(p_rec_pp_prd(l_cnt).pay_plan,l_pay_plan) = l_pay_plan THEN
                hr_utility.set_location('PP/PRD PASS',115);
                l_prd_pp_matched := TRUE;
                exit;
           END IF;
        END LOOP;

        IF l_prd_pp_matched THEN
            IF l_pay_table_id = p_msl_user_table_id THEN
                hr_utility.set_location('Table ID PASS',125);
                IF NOT (p_action = 'CREATE' AND
                            person_in_pa_req_1noa
                              (p_person_id      => p_person_id,
                               p_effective_date => l_effective_date,
                               p_first_noa_code => nvl(g_first_noa_code,'894'),
                               p_pay_plan       => p_pay_plan
                               )
                       )THEN
                     -- Pass l_pay_plan instead of l_to_pay_plan.
                     FOR msl_dtl IN msl_dtl_cur(l_pay_plan, l_pay_rate_determinant)
                     LOOP
                        IF msl_dtl.cnt <> 0 THEN
                        l_row_cnt := msl_dtl.cnt;
                        END IF;
                     END LOOP;

                    IF l_row_cnt <> 0 THEN
                        hr_utility.set_location('ROW COUNT PASS',135);
                        -- Get the required details if the related check has not been done above.
                        IF NOT l_fetch_poid_data THEN

                            get_pos_grp1_ddf(l_position_id,
                                             l_effective_date,
                                             l_pos_grp1_rec);
                        END IF;

                        IF NOT l_fetch_ds_data THEN
                            ghr_pa_requests_pkg.get_SF52_loc_ddf_details
                                        (p_location_id      => l_location_id
                                        ,p_duty_station_id  => l_duty_station_id);
                        END IF;

                        IF NOT l_fetch_agency_data THEN
                            get_sub_element_code_pos_title(
                                                         l_position_id,
                                                         p_person_id,
                                                         l_business_group_id,
                                                         l_assignment_id,
                                                         l_effective_date,
                                                         l_sub_element_code,
                                                         l_position_title,
                                                         l_position_number,
                                                         l_position_seq_no
                                                         );
                        END IF;

                        -- Set all the out parameters
                        p_elig_flag := TRUE;
                        p_personnel_office_id  := l_personnel_office_id;
                        p_org_structure_id     := l_org_structure_id;
                        p_position_title       := l_position_title;
                        p_position_number      := l_position_number;
                        p_position_seq_no      := l_position_seq_no;
                        p_subelem_code         := l_sub_element_code;
                        p_duty_station_id      := l_duty_station_id;
                        p_tenure               := l_tenure;
                        p_annuitant_indicator  := l_annuitant_indicator;
                        p_pay_rate_determinant := l_pay_rate_determinant;
                        p_work_schedule        := l_work_schedule;
                        p_part_time_hour       := l_part_time_hour;
                        p_to_grade_id          := l_to_grade_id;
                        p_pay_plan             := l_pay_plan;
                        p_to_pay_plan          := l_to_pay_plan;
                        p_pay_table_id         := l_pay_table_id;
                        p_grade_or_level       := l_grade_or_level;
                        p_to_grade_or_level    := l_to_grade_or_level;
                        p_step_or_rate         := l_step_or_rate;
                        p_pay_basis            := l_pay_basis;
                    ELSE -- If PP,PRD combinations are "0".
                        -- Raise Error
                        NULL;
                    END IF;
                ELSE -- Not (Create and RPA exists)
                    hr_utility.set_location('ROW COUNT FAIL',145);
                    p_elig_flag := FALSE;
                END IF;
            ELSE -- Pay table id is not matched
                hr_utility.set_location('Pay Table FAIL',155);
                p_elig_flag := FALSE;
            END IF;
        ELSE  -- Pay Plan and PRD not matched
            hr_utility.set_location('PP/PRD FAIL',165);
            p_elig_flag := FALSE;
        END IF;
    ELSE
        hr_utility.set_location('PP FAIL',175);
        p_elig_flag := FALSE;
    END IF;
EXCEPTION
    WHEN others THEN
        hr_utility.set_location('WHEN OTHERS',185);
        RAISE;
END fetch_and_validate_emp;
--
--
--
-- Bug#5063304 Created this new procedure
PROCEDURE fetch_and_validate_emp_perc(
                              p_action              IN VARCHAR2
                             ,p_mass_salary_id      IN NUMBER
                             ,p_mass_salary_name    IN VARCHAR2
                             ,p_full_name           IN per_people_f.full_name%TYPE
							 ,p_national_identifier IN per_people_f.national_identifier%TYPE
                             ,p_assignment_id       IN per_assignments_f.assignment_id%TYPE
							 ,p_person_id           IN per_assignments_f.person_id%TYPE
							 ,p_position_id         IN per_assignments_f.position_id%TYPE
							 ,p_grade_id            IN per_assignments_f.grade_id%TYPE
							 ,p_business_group_id   IN per_assignments_f.business_group_iD%TYPE
							 ,p_location_id         IN per_assignments_f.location_id%TYPE
							 ,p_organization_id     IN per_assignments_f.organization_id%TYPE
                             ,p_msl_organization_id       IN per_assignments_f.organization_id%TYPE
                             ,p_msl_duty_station_id       IN ghr_duty_stations_f.duty_station_id%TYPE
                             ,p_msl_personnel_office_id    IN VARCHAR2
                             ,p_msl_agency_code_subelement IN VARCHAR2
                             ,p_msl_user_table_id          IN NUMBER
                             ,p_rec_pp_prd_per_gr          IN pp_prd_per_gr
                             ,p_personnel_office_id OUT NOCOPY VARCHAR2
                             ,p_org_structure_id    OUT NOCOPY VARCHAR2
                             ,p_position_title      OUT NOCOPY VARCHAR2
                             ,p_position_number     OUT NOCOPY VARCHAR2
                             ,p_position_seq_no     OUT NOCOPY VARCHAR2
                             ,p_subelem_code        OUT NOCOPY VARCHAR2
                             ,p_duty_station_id     OUT NOCOPY ghr_duty_stations_f.duty_station_id%TYPE
                             ,p_tenure              OUT NOCOPY VARCHAR2
                             ,p_annuitant_indicator OUT NOCOPY VARCHAR2
                             ,p_pay_rate_determinant OUT NOCOPY VARCHAR2
                             ,p_work_schedule       OUT NOCOPY  VARCHAR2
                             ,p_part_time_hour      OUT NOCOPY VARCHAR2
                             ,p_pay_plan            OUT NOCOPY VARCHAR2
                             ,p_pay_table_id        OUT NOCOPY NUMBER
                             ,p_grade_or_level      OUT NOCOPY VARCHAR2
                             ,p_step_or_rate        OUT NOCOPY VARCHAR2
                             ,p_pay_basis           OUT NOCOPY VARCHAR2
                             ,p_increase_percent    OUT NOCOPY NUMBER
                             ,p_elig_flag           OUT NOCOPY BOOLEAN
			                ) IS

    CURSOR msl_dtl_cur (cur_pay_plan varchar2, cur_prd varchar2) IS
    SELECT count(*) cnt
      FROM ghr_mass_salary_criteria
     WHERE mass_salary_id = p_mass_salary_id
       AND pay_plan = cur_pay_plan
       AND pay_rate_determinant = cur_prd;

    l_row_cnt               NUMBER := 0;
    l_pos_grp1_rec          per_position_extra_info%rowtype;
    l_assignment_id         per_assignments_f.assignment_id%TYPE;
    l_person_id             per_assignments_f.person_id%TYPE;
    l_position_id           per_assignments_f.position_id%TYPE;
    l_grade_id              per_assignments_f.grade_id%TYPE;
    l_business_group_id     per_assignments_f.business_group_iD%TYPE;
    l_location_id           per_assignments_f.location_id%TYPE;
    l_organization_id       per_assignments_f.organization_id%TYPE;
    l_increase_percent      ghr_mass_actions_preview.increase_percent%type;
    l_tenure               VARCHAR2(35);
    l_annuitant_indicator  VARCHAR2(35);
    l_pay_rate_determinant VARCHAR2(35);
    l_work_schedule        VARCHAR2(35);
    l_part_time_hour       VARCHAR2(35);
    l_pay_table_id         NUMBER;
    l_pay_plan             VARCHAR2(30);
    l_grade_or_level       VARCHAR2(30);
    l_step_or_rate         VARCHAR2(30);
    l_pay_basis            VARCHAR2(30);
    l_duty_station_id      NUMBER;
    l_duty_station_desc    ghr_pa_requests.duty_station_desc%type;
    l_duty_station_code    ghr_pa_requests.duty_station_code%type;
    l_effective_date       DATE;
    l_personnel_office_id  VARCHAR2(300);
    l_org_structure_id     VARCHAR2(300);
    l_sub_element_code     VARCHAR2(300);
    l_position_title       VARCHAR2(300);
    l_position_number      VARCHAR2(20);
    l_position_seq_no      VARCHAR2(20);
    l_log_text             VARCHAR2(2000) := null;
    l_retained_grade_rec   ghr_pay_calc.retained_grade_rec_type;
    l_fetch_poid_data       BOOLEAN := FALSE;
    l_fetch_ds_data         BOOLEAN := FALSE;
    l_fetch_agency_data     BOOLEAN := FALSE;
    init_elig_flag          BOOLEAN := FALSE;
    l_prd_matched           BOOLEAN := FALSE;
    l_prd_pp_matched        BOOLEAN := FALSE;

    l_proc   varchar2(72) :=  g_package || '.fetch_and_validate_emp_perc';

BEGIN

    g_proc  := 'fetch_and_validate_emp_perc';
    hr_utility.set_location('Entering    ' || l_proc,5);
    -- Bug#5623035 Moved the local variable declaratio to here.
    l_assignment_id     := p_assignment_id;
    l_position_id       := p_position_id;
    l_grade_id          := p_grade_id;
    l_business_group_id := p_business_group_iD;
    l_location_id       := p_location_id;
    l_effective_date    := g_effective_date;
    -- Verify whether this process is required or not.
    IF p_msl_organization_id IS NOT NULL  OR
       p_msl_duty_station_id IS NOT NULL  OR
       p_msl_personnel_office_id IS NOT NULL  OR
       p_msl_agency_code_subelement IS NOT NULL THEN
        -- get the values and verify whether the record meets the condition or not.
        -- If Yes, proceed further. Otherwise, skip the other checks for this record

        hr_utility.set_location('The location id is:'||l_location_id,12345);
        hr_utility.set_location('MSL Org ID:'||p_msl_organization_id,11111);
        hr_utility.set_location('Org ID:'||p_organization_id,22222);
        IF NVL(p_msl_organization_id,p_organization_id) = p_organization_id THEN
            hr_utility.set_location('Org ID PASS',10);
            IF p_msl_personnel_office_id IS NOT NULL THEN
                hr_utility.set_location('POID CHECK',15);
                get_pos_grp1_ddf(l_position_id,
                                 l_effective_date,
                                 l_pos_grp1_rec);

                l_personnel_office_id :=  l_pos_grp1_rec.poei_information3;
                l_org_structure_id    :=  l_pos_grp1_rec.poei_information5;
                l_fetch_poid_data := TRUE;
            END IF;
            IF  (p_msl_personnel_office_id = l_personnel_office_id) OR
                NOT(l_fetch_poid_data) THEN
                hr_utility.set_location('POID PASS',20);
                IF p_msl_agency_code_subelement IS NOT NULL THEN
                    hr_utility.set_location('Agency CHECK',25);
                    get_sub_element_code_pos_title(l_position_id,
                                             p_person_id,
                                             l_business_group_id,
                                             l_assignment_id,
                                             l_effective_date,
                                             l_sub_element_code,
                                             l_position_title,
                                             l_position_number,
                                             l_position_seq_no);
                    l_fetch_agency_data := TRUE;
                END IF;
                -- Bug#5674003 Modified the following IF condition
                IF  (SUBSTR(p_msl_agency_code_subelement,1,2)  = SUBSTR(l_sub_element_code,1,2) AND
                     NVL(SUBSTR(p_msl_agency_code_subelement,3,2),SUBSTR(l_sub_element_code,3,2))=
                         SUBSTR(l_sub_element_code,3,2)
                    ) OR
                    NOT(l_fetch_agency_data) THEN
                                    hr_utility.set_location('Agency PASS',30);
                    IF p_msl_duty_station_id IS NOT NULL THEN
                        hr_utility.set_location('DS CHECK',35);
                        ghr_pa_requests_pkg.get_SF52_loc_ddf_details
                        (p_location_id      => l_location_id
                        ,p_duty_station_id  => l_duty_station_id);
                        l_fetch_ds_data := TRUE;
                    END IF;
                    IF (p_msl_duty_station_id = l_duty_station_id) OR
                       NOT(l_fetch_ds_data)THEN
                       hr_utility.set_location('DS PASS',40);
                        init_elig_flag := TRUE;
                    ELSE -- Duty Station not matching.
                       hr_utility.set_location('DS FAIL',45);
                        init_elig_flag := FALSE;
                    END IF;
                ELSE -- Agency Code Subelement Not matching.
                    hr_utility.set_location('Agency FAIL',55);
                    init_elig_flag := FALSE;
                END IF;
            ELSE -- Personnel Office ID not matching
                hr_utility.set_location('POID FAIL',65);
                init_elig_flag := FALSE;
            END IF;
        ELSE -- Organization_id is not matching.
            hr_utility.set_location('Org FAIL',75);
            init_elig_flag := FALSE;
        END IF;
    ELSE  -- If No value is entered for organization, Duty Station, Agency, POID of MSL Criteria.
       hr_utility.set_location('No INIT CRITERIA',85);
        init_elig_flag := TRUE;
    END IF;

    -- If the initial eligibility is passed then proceed further. Otherwise move to next record.
    IF init_elig_flag THEN
        hr_utility.set_location('Init Criteria Pass',95);
        ghr_pa_requests_pkg.get_sf52_asg_ddf_details
                                  (l_assignment_id,
                                   l_effective_date,
                                   l_tenure,
                                   l_annuitant_indicator,
                                   l_pay_rate_determinant,
                                   l_work_schedule,
                                   l_part_time_hour);

        FOR l_cnt in 1..p_rec_pp_prd_per_gr.COUNT LOOP
           IF nvl(p_rec_pp_prd_per_gr(l_cnt).prd,l_pay_rate_determinant) = l_pay_rate_determinant THEN
                hr_utility.set_location('PRD PASS',105);
                l_prd_matched := TRUE;
                exit;
           END IF;
        END LOOP;

        IF l_prd_matched THEN
            BEGIN
                get_pay_plan_and_table_id(l_pay_rate_determinant,p_person_id,
                           l_position_id,l_effective_date,
                           l_grade_id, l_assignment_id,'SHOW',l_pay_plan,
                           l_pay_table_id,l_grade_or_level, l_step_or_rate,
                           l_pay_basis);
            -- Bug#4016384 Added the exception handling to report RG employees in the process log.
            EXCEPTION
                WHEN MSL_ERROR THEN
                    -- Report the record in the process log if the pay table ID matches.
                    BEGIN
                        l_retained_grade_rec := ghr_pc_basic_pay.get_expired_rg_details
                                                  (p_person_id => p_person_id
                                                  ,p_effective_date => l_effective_date);

                        IF l_retained_grade_rec.user_table_id = p_msl_user_table_id THEN

                            l_log_text  := 'Error in RG Record In Mass Salary Name: '||
                                            p_mass_salary_name||'; Employee Name: '|| p_full_name ||
                                            '; SSN: ' || p_national_identifier || '; '||
                                            hr_utility.get_message;
                            BEGIN
                                ghr_mto_int.log_message(
                                      p_procedure => 'check_grade_retention',
                                      p_message   => l_log_text);
                                g_rg_recs_failed := g_rg_recs_failed + 1;
                            EXCEPTION
                                WHEN OTHERS THEN
                                   l_prd_pp_matched := FALSE;
                            END;
                        ELSE
                            l_prd_pp_matched := FALSE;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            l_prd_pp_matched := FALSE;
                    END;
                WHEN OTHERS THEN
                    -- Skip this record from reporting.
                    l_prd_pp_matched := FALSE;
            END;
        END IF;

        FOR l_cnt in 1..p_rec_pp_prd_per_gr.COUNT LOOP
           IF nvl(p_rec_pp_prd_per_gr(l_cnt).prd,l_pay_rate_determinant) = l_pay_rate_determinant AND
              nvl(p_rec_pp_prd_per_gr(l_cnt).pay_plan,l_pay_plan) = l_pay_plan  AND
              nvl(p_rec_pp_prd_per_gr(l_cnt).grade,l_grade_or_level) = l_grade_or_level THEN
                l_prd_pp_matched := TRUE;
                l_increase_percent := nvl(p_rec_pp_prd_per_gr(l_cnt).percent,0);
                EXIT;
           END IF;
        END LOOP;

        IF l_prd_pp_matched THEN
            IF l_pay_table_id = p_msl_user_table_id THEN
                hr_utility.set_location('Table ID PASS',125);
                IF NOT (p_action = 'CREATE' AND
                            person_in_pa_req_1noa
                              (p_person_id      => p_person_id,
                               p_effective_date => l_effective_date,
                               p_first_noa_code => nvl(g_first_noa_code,'894'),
                               p_pay_plan       => p_pay_plan
                               )
                       )THEN
                     FOR msl_dtl IN msl_dtl_cur(l_pay_plan, l_pay_rate_determinant)
                     LOOP
                        IF msl_dtl.cnt <> 0 THEN
                        l_row_cnt := msl_dtl.cnt;
                        END IF;
                     END LOOP;

                    IF l_row_cnt <> 0 THEN
                        hr_utility.set_location('ROW COUNT PASS',135);
                        -- Get the required details if the related check has not been done above.
                        IF NOT l_fetch_poid_data THEN

                            get_pos_grp1_ddf(l_position_id,
                                             l_effective_date,
                                             l_pos_grp1_rec);
                        END IF;

                        IF NOT l_fetch_ds_data THEN
                            ghr_pa_requests_pkg.get_SF52_loc_ddf_details
                                        (p_location_id      => l_location_id
                                        ,p_duty_station_id  => l_duty_station_id);
                        END IF;

                        IF NOT l_fetch_agency_data THEN
                            get_sub_element_code_pos_title(
                                                         l_position_id,
                                                         p_person_id,
                                                         l_business_group_id,
                                                         l_assignment_id,
                                                         l_effective_date,
                                                         l_sub_element_code,
                                                         l_position_title,
                                                         l_position_number,
                                                         l_position_seq_no
                                                         );
                        END IF;

                        -- Set all the out parameters
                        p_elig_flag := TRUE;
                        p_personnel_office_id  := l_personnel_office_id;
                        p_org_structure_id     := l_org_structure_id;
                        p_position_title       := l_position_title;
                        p_position_number      := l_position_number;
                        p_position_seq_no      := l_position_seq_no;
                        p_subelem_code         := l_sub_element_code;
                        p_duty_station_id      := l_duty_station_id;
                        p_tenure               := l_tenure;
                        p_annuitant_indicator  := l_annuitant_indicator;
                        p_pay_rate_determinant := l_pay_rate_determinant;
                        p_work_schedule        := l_work_schedule;
                        p_part_time_hour       := l_part_time_hour;
                        p_pay_plan             := l_pay_plan;
                        p_pay_table_id         := l_pay_table_id;
                        p_grade_or_level       := l_grade_or_level;
                        p_step_or_rate         := l_step_or_rate;
                        p_pay_basis            := l_pay_basis;
                        p_increase_percent     := l_increase_percent;
                    ELSE -- If PP,PRD combinations are "0".
                        -- Raise Error
                        NULL;
                    END IF;
                ELSE -- Not (Create and RPA exists)
                    hr_utility.set_location('ROW COUNT FAIL',145);
                    p_elig_flag := FALSE;
                END IF;
            ELSE -- Pay table id is not matched
                hr_utility.set_location('Pay Table FAIL',155);
                p_elig_flag := FALSE;
            END IF;
        ELSE  -- Pay Plan and PRD not matched
            hr_utility.set_location('PP/PRD FAIL',165);
            p_elig_flag := FALSE;
        END IF;
    ELSE
        hr_utility.set_location('PP FAIL',175);
        p_elig_flag := FALSE;
    END IF;
EXCEPTION
    WHEN others THEN
        hr_utility.set_location('WHEN OTHERS',185);
        RAISE;
END fetch_and_validate_emp_perc;
--
--
--

FUNCTION check_init_eligibility(p_duty_station_id in number,
                            p_PERSONNEL_OFFICE_ID in varchar2,
                            p_AGENCY_CODE_SUBELEMENT   in varchar2,
                            p_l_duty_station_id   in number,
                            p_l_personnel_office_id in varchar2,
                            p_l_sub_element_code in varchar2)
return boolean is

CURSOR cur_valid_DS(p_ds_id NUMBER)
IS
SELECT effective_end_date  end_date
FROM   ghr_duty_stations_f
WHERE  duty_station_id=p_ds_id
AND    g_effective_date between effective_start_date and effective_end_date;

l_ds_end_date	ghr_duty_stations_f.effective_end_date%type;


l_proc   varchar2(72) :=  g_package || '.check_init_eligibility';
BEGIN

  g_proc  := 'check_init_eligibility';
  hr_utility.set_location('Entering    ' || l_proc,5);

  if p_personnel_office_id is not null then
      if p_personnel_office_id <> nvl(p_l_personnel_office_id,'NULL!~') then
         return false;
      end if;
  end if;

-- VSM [Masscrit.doc]
-- 2 char - Test for Agency Code only
-- 4 char Test for agency and subelement
  if p_agency_code_subelement is not null then
      if substr(p_agency_code_subelement, 1, 2) <> nvl(substr(p_l_sub_element_code, 1, 2), 'NULL!~') then
         return false;
      end if;
  end if;

  if substr(p_agency_code_subelement, 3, 2) is not null then
      if substr(p_agency_code_subelement, 3, 2) <> nvl(substr(p_l_sub_element_code, 3, 2), 'NULL!~') then
         return false;
      end if;
  end if;

-- Start of Bug3437354
--
-- Added this condition for bug 3437354, error out the record without valid Loc id
--
      if p_duty_station_id <> nvl(p_l_duty_station_id,0) then
         return false;
      end if;

    FOR rec_ds in cur_valid_ds(p_l_duty_station_id)
    LOOP
      l_ds_end_date	:= rec_ds.end_Date;
    END LOOP;

     If l_ds_end_date IS NULL THEN
     hr_utility.set_location('Under DS null check'||p_l_duty_station_id,12345);
     raise msl_error;
     return false;
     end if;
-- End of bug 3437354
--
  pr('Eligible');
  return true;
exception
  when msl_error then --raise;
   hr_utility.set_location('Error NO DUTY STATION '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf :=
     'Error - No valid Location found, salary cannot be correctly calculated without the employee''s duty location ';
     raise msl_error;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
END check_init_eligibility;


FUNCTION check_eligibility(p_mass_salary_id  in number,
                           p_user_table_id   in  number,
                           p_pay_table_id    in  number,
                           p_pay_plan        in  varchar2,
                           p_pay_rate_determinant in varchar2,
                           p_person_id in number,
                           p_effective_date in date,
                           p_action in varchar2)
return boolean is

   cursor msl_dtl_cur (cur_pay_plan varchar2, cur_prd varchar2) is
   select count(*) count
     from ghr_mass_salary_criteria
    where mass_salary_id = p_mass_salary_id
      and pay_plan = cur_pay_plan
      and pay_rate_determinant = cur_prd;

   l_row_cnt      number := 0;
l_proc   varchar2(72) :=  g_package || '.check_eligibility';
BEGIN
  g_proc  := 'check_eligibility';
  hr_utility.set_location('Entering    ' || l_proc,5);
   --return true;

   if p_user_table_id is null or p_pay_table_id is null then
          return false;
   end if;

/************ on 3/21/1998
   if p_pay_rate_determinant not in ('0','2','3','4','6','A','B','E','F','J','K','R','S','U','V')
       then
           return false;
   end if;
**************/

   if p_pay_plan is null or p_pay_rate_determinant is null then
  ghr_mre_pkg.pr('pay plan, prd failed');
        return false;
   end if;

   IF p_user_table_id <> p_pay_table_id THEN
  ghr_mre_pkg.pr('pay table id failed');
      return false;
   END IF;

   FOR msl_dtl IN msl_dtl_cur(p_pay_plan, p_pay_rate_determinant)
   LOOP
      if msl_dtl.count <> 0 then
          l_row_cnt := msl_dtl.count;
      end if;
   END LOOP;

   IF l_row_cnt = 0 THEN
      RETURN FALSE;
   END IF;

  if p_action = 'CREATE' THEN
  if person_in_pa_req_1noa
          (p_person_id      => p_person_id,
           p_effective_date => p_effective_date,
           p_first_noa_code => nvl(g_first_noa_code,'894'),
           p_pay_plan       => p_pay_plan
           ) then
  ghr_mre_pkg.pr('1noa failed',to_char(p_person_id));
       return false;
   ELSE
  ghr_mre_pkg.pr('Eligible');
      RETURN TRUE;
  end if;
  end if;
/************ This is not required****************
  if person_in_pa_req_2noa
          (p_person_id      => p_person_id,
           p_effective_date => p_effective_date,
           p_second_noa_code => '894'
           ) then
  ghr_mre_pkg.pr('2noa failed',to_char(p_person_id));
       return false;
  end if;

*********** This is not required****************/
 return true;
exception
  when msl_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
END check_eligibility;

--
--
--

function person_in_pa_req_1noa
          (p_person_id      in number,
           p_effective_date in date,
           p_first_noa_code in varchar2,
           p_pay_plan       in varchar2,
           p_days           in number default 350
           )
  return boolean is
--
  l_name            per_people_f.full_name%type;
  -- Bug#3718167  Added l_ssn
  l_ssn             per_people_f.national_identifier%TYPE;
  l_pa_request_id   ghr_pa_requests.pa_request_id%TYPE;

  cursor csr_action_taken is
      select pr.pa_request_id, max(pa_routing_history_id) pa_routing_history_id
        from ghr_pa_requests pr, ghr_pa_routing_history prh
      where pr.pa_request_id = prh.pa_request_id
      and   person_id = p_person_id
      and   first_noa_code = p_first_noa_code
      and   effective_date = p_effective_date
      and nvl(pr.first_noa_cancel_or_correct,'X') <> ghr_history_api.g_cancel
---- Bug # 657439
      --and nvl(pr.first_noa_cancel_or_correct,'X') <> 'CANCELED'
      group by pr.pa_request_id;

    -- Bug#3718167
    cursor csr_name_ssn is
    select substr(pr.employee_last_name || ', ' || pr.employee_first_name,1,240) fname,
           pr.employee_national_identifier SSN
    from ghr_pa_requests pr
    where pr.pa_request_id = l_pa_request_id;

  cursor csr_action_taken_fw is
      select pr.pa_request_id, max(pa_routing_history_id) pa_routing_history_id
        from ghr_pa_requests pr, ghr_pa_routing_history prh
      where pr.pa_request_id = prh.pa_request_id
      and   person_id        = p_person_id
      and   first_noa_code   = p_first_noa_code
      and   effective_date   = p_effective_date
      and nvl(pr.first_noa_cancel_or_correct,'X') <> ghr_history_api.g_cancel
      group by pr.pa_request_id;

  cursor csr_eq_pay_plan is
      SELECT equivalent_pay_plan
      FROM ghr_pay_plans
     WHERE pay_plan = p_pay_plan;

    cursor pa_hist_cur (p_r_hist_id number) is
      select nvl(action_taken,' ') action_taken
        from ghr_pa_routing_history
      where pa_routing_history_id = p_r_hist_id;

  l_action_taken    ghr_pa_routing_history.action_taken%TYPE;
  l_proc     varchar2(72) :=  g_package || '.person_in_pa_req_1noa';
  l_eq_pay_plan     ghr_pay_plans.equivalent_pay_plan%type;

begin
  g_proc  := 'person_in_pa_req_1noa';
  hr_utility.set_location('Entering    ' || l_proc,5);
-- Bug 1631952 start
   for csr_eq_pay_plan_rec in csr_eq_pay_plan loop
      l_eq_pay_plan := csr_eq_pay_plan_rec.equivalent_pay_plan;
   end loop;

 if l_eq_pay_plan = 'FW' then
   for v_action_taken_fw in csr_action_taken_fw loop
       l_pa_request_id := v_action_taken_fw.pa_request_id;
       for v_name in csr_name_ssn
       loop
           l_name := v_name.fname;
	   -- Bug#3718167 Added l_ssn statement
	   l_ssn  := v_name.ssn;
       exit;
       end loop;
       for pa_hist_rec in pa_hist_cur (v_action_taken_fw.pa_routing_history_id)
       loop
           l_action_taken := pa_hist_rec.action_taken;
           exit;
       end loop;
      if l_action_taken <> 'CANCELED' then
	  -- Bug#3718167 Added SSN in the following message
          ghr_mto_int.log_message(
          p_procedure => 'RPA Exists Already',
          p_message   => 'Name: '|| l_name || '; SSN: '||l_ssn||
	                 ' - Salary Change ' ||
                         ' RPA Exists for the given FWS pay_lan and effective date' );
         return true;
      end if;
   end loop;
 else
--- Bug 1631952 end.  The same bug was extended to GS equvalent pay plans.
   for v_action_taken in csr_action_taken loop
       l_pa_request_id := v_action_taken.pa_request_id;
       for v_name in csr_name_ssn
       loop
           l_name := v_name.fname;
	   -- Bug#3718167 Added l_ssn statement
	   l_ssn  := v_name.ssn;
       exit;
       end loop;
       for pa_hist_rec in pa_hist_cur (v_action_taken.pa_routing_history_id)
       loop
           l_action_taken := pa_hist_rec.action_taken;
           exit;
       end loop;
      if l_action_taken <> 'CANCELED' then
          -- Bug#3718167 Added SSN in the following message
          ghr_mto_int.log_message(
          p_procedure => 'RPA Exists Already',
          p_message   => 'Name: '|| l_name || '; SSN: '||l_ssn||
	                 ' - Salary Change ' ||
                         ' RPA Exists for the given effective date ' );
         return true;
      end if;

   end loop;
 end if; ------Bug 1631952
   return false;
end person_in_pa_req_1noa;

--
--
--

function person_in_pa_req_2noa
          (p_person_id      in number,
           p_effective_date in date,
           p_second_noa_code in varchar2,
           p_days           in number default 350
           )
  return boolean is
--
  cursor csr_action_taken is
      select pr.pa_request_id, max(pa_routing_history_id) pa_routing_history_id
        from ghr_pa_requests pr, ghr_pa_routing_history prh
      where pr.pa_request_id = prh.pa_request_id
      and   nvl(person_id,0) = p_person_id
      and   nvl(second_noa_code,0) = p_second_noa_code
      and   nvl(effective_date,trunc(sysdate)) >= (p_effective_date-p_days)
      and nvl(pr.second_noa_cancel_or_correct,'X') <> ghr_history_api.g_cancel
--Bug 657439
--      and nvl(pr.second_noa_cancel_or_correct,'X') <> 'CANCELED'
      group by pr.pa_request_id;

    cursor pa_hist_cur (p_r_hist_id number) is
      select nvl(action_taken,' ') action_taken
        from ghr_pa_routing_history
      where pa_routing_history_id = p_r_hist_id;

  l_action_taken    ghr_pa_routing_history.action_taken%TYPE;
  l_proc     varchar2(72) :=  g_package || '.person_in_pa_req_2noa';
begin
  g_proc  := 'person_in_pa_req_2noa';
  hr_utility.set_location('Entering    ' || l_proc,5);
   for v_action_taken in csr_action_taken loop
       for pa_hist_rec in pa_hist_cur (v_action_taken.pa_routing_history_id)
       loop
           l_action_taken := pa_hist_rec.action_taken;
           exit;
       end loop;
      if l_action_taken <> 'CANCELED' then
         return true;
      end if;
   end loop;
   return false;
end person_in_pa_req_2noa;

--
--
--

FUNCTION check_grade_retention(p_prd in varchar2
                              ,p_person_id in number
                              ,p_effective_date in date) return varchar2 is

l_retained_grade_rec  ghr_pay_calc.retained_grade_rec_type;
l_per_ei_data         per_people_extra_info%rowtype;

l_proc  varchar2(72) :=  g_package || '.check_grade_retention';

BEGIN
  g_proc  := 'check_grade_retention';
  hr_utility.set_location('Entering    ' || l_proc,5);
  IF p_prd in ('A','B','E','F','U','V') THEN
     IF p_prd in ('A','B','E','F') THEN
       -- Bug#4179270,4126137,4086677 Removed the History Fetch call.
       -- Note: Do not use fetch_peopleei to get Retained grade details as it
       --       is not date tracked.
       BEGIN
	       l_retained_grade_rec :=
                   ghr_pc_basic_pay.get_retained_grade_details
                                      ( p_person_id,
                                        p_effective_date);
	       IF l_retained_grade_rec.temp_step is not null THEN
		      return 'REGULAR';
	       END IF;
	   EXCEPTION
           WHEN ghr_pay_calc.pay_calc_message THEN
                 raise msl_error;
           WHEN OTHERS THEN
                raise;
       END;
     END IF;
     return 'RETAIN';
  ELSE
     return 'REGULAR';
  END IF;
EXCEPTION
  when msl_error then
     RETURN 'MSL_ERROR';
  when others then
     RETURN 'OTHER_ERROR';
END CHECK_GRADE_RETENTION;

--
--
--

procedure get_pos_grp1_ddf (p_position_id in per_assignments_f.position_id%type,
                            p_effective_date in date,
                            p_pos_ei_data     out nocopy per_position_extra_info%rowtype)
IS

l_proc  varchar2(72) :=  g_package || '.get_pos_grp1_ddf';
--l_pos_ei_data         per_position_extra_info%type;

begin
  g_proc  := 'get_pos_grp1_ddf';
  hr_utility.set_location('Entering    ' || l_proc,5);
     ghr_history_fetch.fetch_positionei
                  (p_position_id           => p_position_id
                  ,p_information_type      => 'GHR_US_POS_GRP1'
                  ,p_date_effective        => p_effective_date
                  ,p_pos_ei_data           => p_pos_ei_data
                                        );
     hr_utility.set_location('Exiting    ' || l_proc,10);
exception
  when msl_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
END get_pos_grp1_ddf;

--
--
--

procedure get_from_sf52_data_elements (p_assignment_id in number,
                                       p_effective_date in date,
                                       p_old_basic_pay out nocopy number,
                                       p_old_avail_pay out nocopy number,
                                       p_old_loc_diff out nocopy number,
                                       p_tot_old_sal out nocopy number,
                                       p_old_auo_pay out nocopy number,
                                       p_old_adj_basic_pay out nocopy number,
                                       p_other_pay out nocopy number,
                                       p_auo_premium_pay_indicator out nocopy varchar2,
                                       p_ap_premium_pay_indicator out nocopy varchar2,
                                       p_retention_allowance out nocopy number,
                                       p_retention_allow_perc out nocopy number,
                                       p_supervisory_differential out nocopy number,
                                       p_supervisory_diff_perc out nocopy number,
                                       p_staffing_differential out nocopy number) is

  l_multi_error_flag    boolean;
  l_total_salary        number;
  l_basic_pay           number;
  l_locality_adj        number;
  l_adj_basic_pay       number;
  l_other_pay           number;
  l_au_overtime               NUMBER;
  l_auo_premium_pay_indicator VARCHAR2(30);
  l_availability_pay          NUMBER;
  l_ap_premium_pay_indicator  VARCHAR2(30);
  l_retention_allowance       NUMBER;
  l_retention_allow_perc      NUMBER;
  l_supervisory_differential  NUMBER;
  l_supervisory_diff_perc     NUMBER;
  l_staffing_differential     NUMBER;
l_proc   varchar2(72) :=  g_package || '.get_from_sf52_data_elements';

BEGIN

  g_proc  := 'get_from_sf52_data_elements';
  hr_utility.set_location('Entering    ' || l_proc,5);

-- Processing Total Pay and Adjusted Basic Pay
-- NAME    DATE       BUG           COMMENTS
-- Ashley  17-JUL-03  Payroll Intg  Modified the Input Value name
--                                  Changes from Total Salary -> Amount
--                                               Adjusted Pay -> Amount

  ghr_api.retrieve_element_entry_value
                       (p_element_name    => 'Total Pay'
                       ,p_input_value_name      => 'Amount'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_total_salary
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Total Pay = ' || to_char(l_total_salary), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  ghr_api.retrieve_element_entry_value
                       (p_element_name  => 'Basic Salary Rate'
                       ,p_input_value_name      => 'Rate'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_basic_pay
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Basic Salary Rate = ' || to_char(l_basic_pay), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

 ghr_api.retrieve_element_entry_value
 -- FWFA Changes Bug#4444609
                       (p_element_name   => 'Locality Pay or SR Supplement'
 -- FWFA Changes Modify 'Locality Pay' to 'Locality Pay or SR Supplement'
                       ,p_input_value_name      => 'Rate'
-- Changed by Ashu. 'Amount' to 'Rate'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_locality_adj
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Locality Pay = ' || to_char(l_locality_adj), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  ghr_api.retrieve_element_entry_value
                       (p_element_name  => 'Adjusted Basic Pay'
                       ,p_input_value_name      => 'Amount'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_adj_basic_pay
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Adjusted Basic Pay = ' || to_char(l_adj_basic_pay), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  ghr_api.retrieve_element_entry_value
                       (p_element_name  => 'Other Pay'
                       ,p_input_value_name      => 'Amount'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_other_pay
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Other Pay = ' || to_char(l_other_pay), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  ghr_api.retrieve_element_entry_value
                       (p_element_name  => 'AUO'
                       ,p_input_value_name      => 'Amount'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_au_overtime
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('AUO Amount = ' || to_char(l_au_overtime), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  ghr_api.retrieve_element_entry_value
                       (p_element_name  => 'AUO'
                       ,p_input_value_name      => 'Premium Pay Ind'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_auo_premium_pay_indicator
                       ,p_multiple_error_flag   => l_multi_error_flag);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  ghr_api.retrieve_element_entry_value
                       (p_element_name  => 'Availability Pay'
                       ,p_input_value_name      => 'Amount'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_availability_pay
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Availability Pay Amount = ' || to_char(l_availability_pay), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  ghr_api.retrieve_element_entry_value
                       (p_element_name  => 'Availability Pay'
                       ,p_input_value_name      => 'Premium Pay Ind'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_ap_premium_pay_indicator
                       ,p_multiple_error_flag   => l_multi_error_flag);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;
  --
  ghr_api.retrieve_element_entry_value
                       (p_element_name  => 'Retention Allowance'
                       ,p_input_value_name      => 'Amount'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_retention_allowance
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Retention Allowance Amount = ' || to_char(l_retention_allowance), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  ghr_api.retrieve_element_entry_value
                       (p_element_name  => 'Retention Allowance'
                       ,p_input_value_name      => 'Percentage'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_retention_allow_perc
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Retention Allowance Percent = ' || to_char(l_retention_allow_perc), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  ghr_api.retrieve_element_entry_value
                       (p_element_name    => 'Supervisory Differential'
                       ,p_input_value_name      => 'Amount'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_supervisory_differential
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Supervisory Diff Amount = ' || to_char(l_supervisory_differential), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  ghr_api.retrieve_element_entry_value
                       (p_element_name    => 'Supervisory Differential'
                       ,p_input_value_name      => 'Percentage'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_supervisory_diff_perc
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Supervisory Diff Percent = ' || to_char(l_supervisory_diff_perc), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

 --
 --
  ghr_api.retrieve_element_entry_value
                       (p_element_name  => 'Staffing Differential'
                       ,p_input_value_name    => 'Amount'
                       ,p_assignment_id       => p_assignment_id
                       ,p_effective_date      => p_effective_date
                       ,p_value               => l_staffing_differential
                       ,p_multiple_error_flag => l_multi_error_flag);

  hr_utility.set_location('Staffing Diff Amount = ' || to_char(l_staffing_differential), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  p_tot_old_sal               := round(l_total_salary,2);
  p_OLD_BASIC_PAY             := round(l_basic_pay,2);
  p_OLD_LOC_DIFF              := round(l_locality_adj,0);
  p_old_adj_basic_pay         := round(l_adj_basic_pay,2);
  p_other_pay                 := l_other_pay;
  p_OLD_AUO_PAY               := l_au_overtime;
  p_auo_premium_pay_indicator := l_auo_premium_pay_indicator;
  p_OLD_AVAIL_PAY             := l_availability_pay;
  p_ap_premium_pay_indicator  := l_ap_premium_pay_indicator;
  p_retention_allowance       := l_retention_allowance;
  p_retention_allow_perc      := l_retention_allow_perc;
  p_supervisory_differential  := l_supervisory_differential;
  p_supervisory_diff_perc     := l_supervisory_diff_perc;
  p_staffing_differential     := l_staffing_differential;

  hr_utility.set_location('Exiting    ' || l_proc,10);

exception
  when msl_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
END GET_FROM_SF52_DATA_ELEMENTS;

--
--
--

procedure get_sub_element_code_pos_title
               (p_position_id in per_assignments_f.position_id%type,
                p_person_id in number,
                p_business_group_id in per_assignments_f.business_group_id%type,
                p_assignment_id in per_assignments_f.assignment_id%type,
                p_effective_date in date,
                p_sub_element_code out nocopy varchar2,
                p_position_title   out nocopy varchar2,
                p_position_number   out nocopy varchar2,
                p_position_seq_no   out nocopy varchar2) is
l_proc     varchar2(72) :=  g_package || '.get_sub_element_code_pos_title';
begin
  g_proc  := 'get_sub_element_code_pos_title';
  hr_utility.set_location('Entering    ' || l_proc,5);
   p_sub_element_code := ghr_api.get_position_agency_code_pos
                   (p_position_id,p_business_group_id,p_effective_date);

   p_position_title := ghr_api.get_position_title_pos
	(p_position_id            => p_position_id
	,p_business_group_id      => p_business_group_id
        ,p_effective_date         => p_effective_date ) ;

   if p_person_id is not null then
    p_position_number := ghr_api.get_position_description_no
	(p_person_id            => p_person_id
	,p_assignment_id        => p_assignment_id
	,p_effective_date       => p_effective_date
	);

   p_position_seq_no := ghr_api.get_position_sequence_no
	(p_person_id            => p_person_id
	,p_assignment_id        => p_assignment_id
	,p_effective_date       => p_effective_date
	);
   end if;

  hr_utility.set_location('Exiting    ' || l_proc,10);
end get_sub_element_code_pos_title;

--
-- Get all details for the reporting...
--

procedure get_other_dtls_for_rep(p_prd in varchar2,
                 p_first_lac2_information1 in varchar2,
                 p_first_lac2_information2 in varchar2,
                 p_first_action_la_code1 out nocopy varchar2,
                 p_first_action_la_code2 out nocopy varchar2,
                 p_remark_code1 out nocopy varchar2,
                 p_remark_code2 out nocopy varchar2
                 ) is
l_proc   varchar2(72) :=  g_package || '.get_other_dtls_for_rep';
BEGIN
  g_proc  := 'get_other_dtls_for_rep';
  hr_utility.set_location('Entering    ' || l_proc,5);
  p_first_action_la_code1  :=  'QWM';
  p_first_action_la_code2  :=  'ZLM';

/**
       If  p_prd in ('A','B','E','F') then -- retained grade
         p_first_action_la_code1  :=  'QWM';
         p_first_action_la_code2  :=  'ZLM';
         p_remark_code1           :=  'X44';
       Elsif p_prd in ('3','J','K') then   -- retained  pay
         p_first_action_la_code1  :=  'QWM';
         p_first_action_la_code2  :=  'ZLM';
         p_remark_code1           :=  'X40';
       Elsif p_prd in ('U','V') then    -- pay and grade
         p_first_action_la_code1  :=  'QWM';
         p_first_action_la_code2  :=  'ZLM';
         p_remark_code1         :=  'X40';
         p_remark_code2         :=  'X44';
       Else
         p_first_action_la_code1  :=  'QWM';
         p_first_action_la_code2  :=  'ZLM';
       End if;
*/

   hr_utility.set_location('Exiting    ' || l_proc,10);

exception
  when msl_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
END get_other_dtls_for_rep;

--
--
--

procedure create_mass_act_prev (
 p_effective_date in date,
 p_date_of_birth in date,
 p_full_name in varchar2,
 p_national_identifier in varchar2,
 p_duty_station_code in varchar2,
 p_duty_station_desc in varchar2,
 p_personnel_office_id in varchar2,
 p_basic_pay       in number,
 p_new_basic_pay   in number,
  -- Bug#2383992
 p_adj_basic_pay       in number,
 p_new_adj_basic_pay   in number,
  -- Bug#2383992
 p_old_avail_pay   in number,
 p_new_avail_pay   in number,
 p_old_loc_diff    in number,
 p_new_loc_diff    in number,
 p_tot_old_sal     in number,
 p_tot_new_sal     in number,
 p_old_auo_pay     in number,
 p_new_auo_pay     in number,
 p_position_id in per_assignments_f.position_id%type,
 p_position_title in varchar2,
 -- FWFA Changes Bug#4444609
 p_position_number in varchar2,
 p_position_seq_no in varchar2,
-- FWFA Changes
 p_org_structure_id in varchar2,
 p_agency_sub_element_code in varchar2,
 p_person_id       in number,
 p_mass_salary_id  in number,
 p_sel_flg         in varchar2,
 p_first_action_la_code1 in varchar2,
 p_first_action_la_code2 in varchar2,
 p_remark_code1 in varchar2,
 p_remark_code2 in varchar2,
 p_grade_or_level in varchar2,
 p_step_or_rate in varchar2,
 p_pay_plan     in varchar2,
 p_pay_rate_determinant in varchar2,
 p_tenure in varchar2,
 p_action in varchar2,
 p_assignment_id in number,
 p_old_other_pay in number,
 p_new_other_pay in number,
 -- Bug#2383992
 p_old_capped_other_pay in number,
 p_new_capped_other_pay in number,
 p_old_retention_allowance in number,
 p_new_retention_allowance in number,
 p_old_supervisory_differential in number,
 p_new_supervisory_differential in number,
 p_organization_name   in varchar2,
 -- Bug#2383992
 p_increase_percent in number default null,
  -- FWFA Changes Bug#4444609
 p_input_pay_rate_determinant in varchar2,
 p_from_pay_table_id in number,
 p_to_pay_table_id   in number
 -- FWFA Changes
 )
is

 l_comb_rem varchar2(30);
 l_proc     varchar2(72) :=  g_package || '.create_mass_act_prev';

 l_cust_rec     ghr_mass_act_custom.ghr_mass_custom_out_rec_type;
 l_cust_in_rec  ghr_mass_act_custom.ghr_mass_custom_in_rec_type;
 l_poi_desc                   varchar2(80);
----Temp Promo Changes.
 l_step_or_rate  varchar2(30);
 l_retained_grade_rec  ghr_pay_calc.retained_grade_rec_type;
-- Bug# 4126137,4179270,4086677
  l_check_grade_retention VARCHAR2(200);

begin
  g_proc  := 'create_mass_act_prev';
  hr_utility.set_location('Entering    ' || l_proc,5);
  if p_remark_code2 is not null then
     l_comb_rem := p_remark_code1||', '||p_remark_code2;
  else
     l_comb_rem := p_remark_code1;
  end if;

  l_poi_desc := GHR_MRE_PKG.GET_POI_NAME (p_personnel_office_id);

  BEGIN
     l_cust_in_rec.person_id := p_person_id;
     l_cust_in_rec.position_id := p_position_id;
     l_cust_in_rec.assignment_id := p_assignment_id;
     l_cust_in_rec.national_identifier := p_national_identifier;
     l_cust_in_rec.mass_action_type := 'SALARY';
     l_cust_in_rec.mass_action_id := p_mass_salary_id;
     l_cust_in_rec.effective_date := p_effective_date;

     GHR_MASS_ACT_CUSTOM.pre_insert (
                       p_cust_in_rec => l_cust_in_rec,
                       p_cust_rec => l_cust_rec);

  exception
     when others then
     hr_utility.set_location('Error in Mass Act Custom '||
              'Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in Mass Act Custom '||
              'Err is '|| sqlerrm(sqlcode);
     raise msl_error;
  END;

  l_step_or_rate := p_step_or_rate;

    IF p_pay_rate_determinant in ('A','B','E','F') THEN

        -- Bug#4179270,4126137,4086677 Modified the following IF Condition.
        l_check_grade_retention := CHECK_GRADE_RETENTION(p_pay_rate_determinant,p_person_id,p_effective_date);
        IF  l_check_grade_retention = 'REGULAR' THEN
            BEGIN
                  l_retained_grade_rec :=
                    ghr_pc_basic_pay.get_retained_grade_details
                                              ( p_person_id,
                                                p_effective_date);
                    if l_retained_grade_rec.temp_step is not null then
                       l_step_or_rate := l_retained_grade_rec.temp_step;
                    end if;
            EXCEPTION
                when others then
                      l_mslerrbuf := 'Preview -  Others error in Get retained grade '||
                               'Error is '||' Sql Err is '|| sqlerrm(sqlcode);
                      ghr_mre_pkg.pr('Person ID '||to_char(p_person_id),'ERROR 2',l_mslerrbuf);
                      raise msl_error;
            END;
        ELSIF l_check_grade_retention ='MSL_ERROR' THEN
           hr_utility.set_message(8301,'GHR_38927_MISSING_MA_RET_DET');
           raise msl_error;
        ELSIF l_check_grade_retention = 'OTHER_ERROR' THEN
             l_mslerrbuf := 'Others error in check_grade_retention function while fetching retained grade record. Please
                             verify the retained grade record';
              raise msl_error;
        END IF;
    END IF;

insert into GHR_MASS_ACTIONS_PREVIEW
(
 mass_action_type,
 --report_type,
 ui_type,
 session_id,
 effective_date,
 employee_date_of_birth,
 full_name,
 national_identifier,
 duty_station_code,
 duty_station_desc,
 personnel_office_id,
 from_basic_pay,
 to_basic_pay,
   -- Bug#2383992
 from_adj_basic_pay       ,
 to_adj_basic_pay   ,
    -- Bug#2383992
 from_availability_pay,
 to_availability_pay,
 from_locality_adj,
 to_locality_adj,
 from_total_salary,
 to_total_salary,
 from_auo_pay,
 to_auo_pay,
 from_other_pay,
 to_other_pay,
  -- Bug#2383992
  from_capped_other_pay,
 to_capped_other_pay,
 from_retention_allowance,
 to_retention_allowance,
 from_supervisory_differential ,
 to_supervisory_differential ,
 -- Bug#2383992
 position_id,
 position_title,
 -- FWFA Changes Bug#4444609
 position_number,
 position_seq_no,
 -- FWFA Changes
 org_structure_id,
 agency_code,
 person_id,
 select_flag,
 first_noa_code,
 first_action_la_code1,
 first_action_la_code2,
 grade_or_level,
 step_or_rate,
 pay_plan,
 pay_rate_determinant,
 tenure,
 POI_DESC,
 organization_name,
 -- FWFA Changes Bug#4444609
 input_pay_rate_determinant,
 from_pay_table_identifier,
 to_pay_table_identifier,
 -- FWFA Changes
 USER_ATTRIBUTE1,
 USER_ATTRIBUTE2,
 USER_ATTRIBUTE3,
 USER_ATTRIBUTE4,
 USER_ATTRIBUTE5,
 USER_ATTRIBUTE6,
 USER_ATTRIBUTE7,
 USER_ATTRIBUTE8,
 USER_ATTRIBUTE9,
 USER_ATTRIBUTE10,
 USER_ATTRIBUTE11,
 USER_ATTRIBUTE12,
 USER_ATTRIBUTE13,
 USER_ATTRIBUTE14,
 USER_ATTRIBUTE15,
 USER_ATTRIBUTE16,
 USER_ATTRIBUTE17,
 USER_ATTRIBUTE18,
 USER_ATTRIBUTE19,
 USER_ATTRIBUTE20,
 increase_percent
)
values
(
 'SALARY',
 /*--decode(p_action,'REPORT',userenv('SESSIONID'),p_mass_realignment_id),*/
 decode(p_action,'SHOW','FORM','REPORT'),
 userenv('SESSIONID'),
 p_effective_date,
 p_date_of_birth,
 p_full_name,
 p_national_identifier,
 p_duty_station_code,
 p_duty_station_desc,
 p_personnel_office_id,
 p_basic_pay,
 p_new_basic_pay,
 -- Bug#2383992
 p_adj_basic_pay       ,
 p_new_adj_basic_pay   ,
 -- Bug#2383992
 p_old_avail_pay,
 p_new_avail_pay,
 p_old_loc_diff,
 p_new_loc_diff,
 p_tot_old_sal,
 p_tot_new_sal,
 p_old_auo_pay,
 p_new_auo_pay,
 p_old_other_pay,                 ----------- nvl(p_old_auo_pay,0)+ nvl(p_old_avail_pay,0),
 p_new_other_pay,                 ----------- nvl(p_new_auo_pay,0)+ nvl(p_new_avail_pay,0),
  -- Bug#2383992
 p_old_capped_other_pay,
 p_new_capped_other_pay,
 p_old_retention_allowance,
 p_new_retention_allowance,
 p_old_supervisory_differential ,
 p_new_supervisory_differential ,
 -- Bug#2383992
 p_position_id,
 p_position_title,
 -- FWFA Changes Bug#4444609
 p_position_number,
 p_position_seq_no,
 -- FWFA Changes
 p_org_structure_id,
 p_agency_sub_element_code,
 p_person_id,
 p_sel_flg,
 nvl(g_first_noa_code,'894'),
 p_first_action_la_code1,
 p_first_action_la_code2,
 p_grade_or_level,
 l_step_or_rate,
 p_pay_plan,
 p_pay_rate_determinant,
 p_tenure,
 l_poi_desc,
 p_organization_name,
 -- FWFA Changes Bug#4444609
 p_input_pay_rate_determinant,
 p_from_pay_table_id,
 p_to_pay_table_id,
 -- FWFA Changes
 l_cust_rec.user_attribute1,
 l_cust_rec.user_attribute2,
 l_cust_rec.user_attribute3,
 l_cust_rec.user_attribute4,
 l_cust_rec.user_attribute5,
 l_cust_rec.user_attribute6,
 l_cust_rec.user_attribute7,
 l_cust_rec.user_attribute8,
 l_cust_rec.user_attribute9,
 l_cust_rec.user_attribute10,
 l_cust_rec.user_attribute11,
 l_cust_rec.user_attribute12,
 l_cust_rec.user_attribute13,
 l_cust_rec.user_attribute14,
 l_cust_rec.user_attribute15,
 l_cust_rec.user_attribute16,
 l_cust_rec.user_attribute17,
 l_cust_rec.user_attribute18,
 l_cust_rec.user_attribute19,
 l_cust_rec.user_attribute20,
 p_increase_percent
);

     hr_utility.set_location('Exiting    ' || l_proc,10);
exception
   when msl_error then raise;
   when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
end create_mass_act_prev;

--
--
--

procedure get_lac_dtls
            (p_pa_request_id  in number,
             p_sf52_rec       out nocopy ghr_pa_requests%rowtype) IS

l_proc varchar2(72) :=  g_package || '.get_lac_dtls';

cursor cur_pa_req_cur is
select * from ghr_pa_requests
 where pa_request_id = p_pa_request_id;

begin
  g_proc  := 'get_lac_dtls';
  hr_utility.set_location('Entering    ' || l_proc,5);

pr('Entering '||l_proc||' Pa req id ',to_char(p_pa_request_id));
if p_pa_request_id is null then
    pr('PA request id is null.................');
else

  for cur_pa_rec in cur_pa_req_cur
  loop
     p_sf52_rec := cur_pa_rec;
     exit;
  end loop;
end if;

  hr_utility.set_location('Exiting    ' || l_proc,10);
exception
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
end get_lac_dtls;

--
--
--

procedure create_lac_remarks
            (p_pa_request_id  in number,
             p_new_pa_request_id  in number) is

l_proc varchar2(72) :=  g_package || '.create_lac_remarks';

cursor cur_pa_rem_cur is
select * from ghr_pa_remarks
 where pa_request_id = p_pa_request_id;

l_remarks_rec     ghr_pa_remarks%rowtype;

begin
  g_proc  := 'create_lac_remarks';
  hr_utility.set_location('Entering    ' || l_proc,5);

  pr('Inside '||l_proc,to_char(p_pa_request_id),to_char(p_new_pa_request_id));

    FOR CUR_PA_REM_rec in cur_pa_rem_cur
    loop

      l_remarks_rec := cur_pa_rem_rec;

pr('Rem id '||to_char(l_remarks_rec.remark_id));
    ghr_pa_remarks_api.create_pa_remarks
    (p_validate                 => false
    ,p_pa_request_id            => p_new_pa_request_id
    ,p_remark_id                => l_remarks_rec.remark_id
    ,p_description              => l_remarks_rec.description
    ,p_remark_code_information1 => l_remarks_rec.remark_code_information1
    ,p_remark_code_information2 => l_remarks_rec.remark_code_information2
    ,p_remark_code_information3 => l_remarks_rec.remark_code_information3
    ,p_remark_code_information4 => l_remarks_rec.remark_code_information4
    ,p_remark_code_information5 => l_remarks_rec.remark_code_information5
    ,p_pa_remark_id             => l_remarks_rec.pa_remark_id
    ,p_object_version_number    => l_remarks_rec.object_version_number
    );

  end loop;

  hr_utility.set_location('Exiting    ' || l_proc,10);

exception
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
end create_lac_remarks;

--
--
--

procedure upd_ext_info_to_null(p_effective_date in date) is

  cursor cur1 is
  select person_id
    FROM PER_people_EXTRA_INFO
   WHERE information_type = 'GHR_US_PER_MASS_ACTIONS'
     AND pei_INFORMATION3 IS NOT NULL;

l_person_id number;

l_proc   varchar2(72) :=  g_package || '.upd_ext_info_to_null';

begin
  g_proc  := 'upd_ext_info_to_null';
  hr_utility.set_location('Entering    ' || l_proc,5);

  pr('Inside '||l_proc);

  for per_ext_rec in cur1
  loop
     l_person_id := per_ext_rec.person_id;
     update_sel_flg (l_person_id,p_effective_date);
  end loop;

  commit;

  pr('Exiting '||l_proc);
  hr_utility.set_location('Exiting    ' || l_proc,10);

exception
  when msl_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
end;

--
--
--

PROCEDURE assign_to_sf52_rec(
 p_person_id              in number,
 p_first_name             in varchar2,
 p_last_name              in varchar2,
 p_middle_names           in varchar2,
 p_national_identifier    in varchar2,
 p_date_of_birth          in date,
 p_effective_date         in date,
 p_assignment_id          in number,
 p_tenure                 in varchar2,
 -- Bug#5089732 Added to_grade_id, to_pay_plan,to_grade_or_level parameters.
 p_to_grade_id            in number,
 p_to_pay_plan            in varchar2,
 p_to_grade_or_level      in varchar2,
 -- Bug#5089732
 p_step_or_rate           in varchar2,
 p_annuitant_indicator    in varchar2,
 p_pay_rate_determinant   in varchar2,
 p_work_schedule          in varchar2,
 p_part_time_hour         in varchar2,
 p_flsa_category          in varchar2,
 p_bargaining_unit_status in varchar2,
 p_functional_class       in varchar2,
 p_supervisory_status     in varchar2,
 p_basic_pay              in number,
 p_to_locality_adj        in number,
 p_to_adj_basic_pay       in number,
 p_to_total_salary        in number,
 p_from_other_pay_amount  in number,
 p_to_other_pay_amount    in number,
 p_to_au_overtime         in number,
 p_to_availability_pay    in number,
 p_to_retention_allowance in number,
 p_to_retention_allow_perce in number,
 p_to_supervisory_differential in number,
 p_to_supervisory_diff_perce in number,
 p_to_staffing_differential in number,
 p_duty_station_id        in number,
 p_duty_station_code      in ghr_pa_requests.duty_station_code%type,
 p_duty_station_desc      in ghr_pa_requests.duty_station_desc%type,
 -- FWFA Changes Bug#4444609
 p_input_pay_rate_determinant in ghr_pa_requests.input_pay_rate_determinant%type,
 p_from_pay_table_id       in ghr_pa_requests.from_pay_table_identifier%type,
 p_to_pay_table_id         in ghr_pa_requests.to_pay_table_identifier%type,
  -- FWFA Changes
 p_lac_sf52_rec           in ghr_pa_requests%rowtype,
 p_sf52_rec               out nocopy ghr_pa_requests%rowtype) IS

l_proc   varchar2(72) :=  g_package || '.assign_to_sf52_rec';
begin

  g_proc  := 'assign_to_sf52_rec';

  hr_utility.set_location('Entering    ' || l_proc,5);

 p_sf52_rec.person_id := p_person_id;
 p_sf52_rec.employee_first_name := p_first_name;
 p_sf52_rec.employee_last_name := p_last_name;
 p_sf52_rec.employee_middle_names := p_middle_names;
 p_sf52_rec.employee_national_identifier := p_national_identifier;
 p_sf52_rec.employee_date_of_birth := p_date_of_birth;
 p_sf52_rec.effective_date := p_effective_date;
 p_sf52_rec.employee_assignment_id := p_assignment_id;
 p_sf52_rec.tenure := p_tenure;
 -- Bug#5089732 Added to_grade_id, to_pay_plan,to_grade_or_level parameters.
 p_sf52_rec.to_grade_id       := p_to_grade_id;
 p_sf52_rec.to_pay_plan       := p_to_pay_plan;
 p_sf52_rec.to_grade_or_level := p_to_grade_or_level;
 -- Bug35089732
 p_sf52_rec.to_step_or_rate := p_step_or_rate;
 p_sf52_rec.annuitant_indicator  := p_annuitant_indicator;
 p_sf52_rec.pay_rate_determinant  := p_pay_rate_determinant;
 p_sf52_rec.work_schedule := p_work_schedule;
 p_sf52_rec.part_time_hours := p_part_time_hour;
 p_sf52_rec.flsa_category := p_flsa_category;
 p_sf52_rec.bargaining_unit_status := p_bargaining_unit_status;
 p_sf52_rec.functional_class := p_functional_class;
 p_sf52_rec.supervisory_status := p_supervisory_status;
 p_sf52_rec.to_basic_pay := p_basic_pay;
 p_sf52_rec.to_locality_adj := p_to_locality_adj;
 p_sf52_rec.to_adj_basic_pay := p_to_adj_basic_pay;
 p_sf52_rec.to_total_salary := p_to_total_salary;
 p_sf52_rec.from_other_pay_amount := p_from_other_pay_amount;
 p_sf52_rec.to_other_pay_amount := p_to_other_pay_amount;
 p_sf52_rec.to_au_overtime := p_to_au_overtime;
 p_sf52_rec.to_availability_pay := p_to_availability_pay;
 if p_to_retention_allowance = 0 or p_to_retention_allowance is null then
    p_sf52_rec.to_retention_allowance := null;
 else
    p_sf52_rec.to_retention_allowance := p_to_retention_allowance;
 end if;
 p_sf52_rec.to_retention_allow_percentage := p_to_retention_allow_perce;
 if p_to_supervisory_differential = 0 or p_to_supervisory_differential is null then
    p_sf52_rec.to_supervisory_differential := null;
 else
    p_sf52_rec.to_supervisory_differential := p_to_supervisory_differential;
 end if;
 p_sf52_rec.to_supervisory_diff_percentage := p_to_supervisory_diff_perce;
 p_sf52_rec.to_staffing_differential := p_to_staffing_differential;
 p_sf52_rec.duty_station_id := p_duty_station_id;
 p_sf52_rec.duty_station_code := p_duty_station_code;
 p_sf52_rec.duty_station_desc := p_duty_station_desc;
 -- FWFA Changes Bug#4444609
 p_sf52_rec.input_pay_rate_determinant := p_input_pay_rate_determinant;
 p_sf52_rec.from_pay_table_identifier  := p_from_pay_table_id;
 p_sf52_rec.to_pay_table_identifier    := p_to_pay_table_id;
 -- FWFA Changes
 p_sf52_rec.FIRST_LAC1_INFORMATION1 := p_lac_sf52_rec.FIRST_LAC1_INFORMATION1;
 p_sf52_rec.FIRST_LAC1_INFORMATION2 := p_lac_sf52_rec.FIRST_LAC1_INFORMATION2;
 p_sf52_rec.FIRST_LAC1_INFORMATION3 := p_lac_sf52_rec.FIRST_LAC1_INFORMATION3;
 p_sf52_rec.FIRST_LAC1_INFORMATION4 := p_lac_sf52_rec.FIRST_LAC1_INFORMATION4;
 p_sf52_rec.FIRST_LAC1_INFORMATION5 := p_lac_sf52_rec.FIRST_LAC1_INFORMATION5;
 p_sf52_rec.SECOND_LAC1_INFORMATION1 := p_lac_sf52_rec.SECOND_LAC1_INFORMATION1;
 p_sf52_rec.SECOND_LAC1_INFORMATION2 := p_lac_sf52_rec.SECOND_LAC1_INFORMATION2;
 p_sf52_rec.SECOND_LAC1_INFORMATION3 := p_lac_sf52_rec.SECOND_LAC1_INFORMATION3;
 p_sf52_rec.SECOND_LAC1_INFORMATION4 := p_lac_sf52_rec.SECOND_LAC1_INFORMATION4;
 p_sf52_rec.SECOND_LAC1_INFORMATION5 := p_lac_sf52_rec.SECOND_LAC1_INFORMATION5;
 p_sf52_rec.FIRST_ACTION_LA_CODE1 := p_lac_sf52_rec.FIRST_ACTION_LA_CODE1;
 p_sf52_rec.FIRST_ACTION_LA_CODE2 := p_lac_sf52_rec.FIRST_ACTION_LA_CODE2;
 p_sf52_rec.FIRST_ACTION_LA_DESC1 := p_lac_sf52_rec.FIRST_ACTION_LA_DESC1;
 p_sf52_rec.FIRST_ACTION_LA_DESC2 := p_lac_sf52_rec.FIRST_ACTION_LA_DESC2;

     hr_utility.set_location('Exiting    ' || l_proc,10);

exception
  when msl_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
end assign_to_sf52_rec;

--
--
--

procedure pr (msg varchar2,par1 in varchar2 default null,
            par2 in varchar2 default null) is
begin
--  g_no := g_no +1;
--  insert into l_tmp values (g_no,substr(msg||'-'||par1||' -'||par2||'-',1,199));
 -- DBMS_OUTPUT.PUT_LINE(msg||'-'||par1||' -'||par2||'-');

    ghr_mto_int.put_line(msg||'-'||par1||' -'||par2||'-');
exception
  when others then
     hr_utility.set_location('Error in pr '||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in pr  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
end;

-- 3843306
-- Start of MSL Percentage Changes
-- This is same as Execute_msl except for few modifications
--
--+-----------------------------------------------------------------+------
--+ Procedure for Mass Percentage Pay Adjustmentfor Range employees +--
--+ ----------------------------------------------------------------+------
PROCEDURE execute_msl_perc (p_errbuf out nocopy varchar2,
                       p_retcode out nocopy number,
                       p_mass_salary_id in number,
                       p_action in varchar2) is
                       --p_bus_grp_id in number) is

p_mass_salary varchar2(32);

--
--
-- Main Cursor which fetches from per_assignments_f and per_people_f
--
--
--1. Cursor with organization.
---


cursor cur_people_org (effective_date date, p_org_id number) is
select ppf.person_id                 PERSON_ID,
       ppf.first_name                FIRST_NAME,
       ppf.last_name                 LAST_NAME,
       ppf.middle_names              MIDDLE_NAMES,
       ppf.full_name                 FULL_NAME,
       ppf.date_of_birth             DATE_OF_BIRTH,
       ppf.national_identifier       NATIONAL_IDENTIFIER,
       paf.position_id               POSITION_ID,
       paf.assignment_id             ASSIGNMENT_ID,
       paf.grade_id                  GRADE_ID,
       paf.job_id                    JOB_ID,
       paf.location_id               LOCATION_ID,
       paf.organization_id           ORGANIZATION_ID,
       paf.business_group_id         BUSINESS_GROUP_ID,
       paf.assignment_status_type_id ASSIGNMENT_STATUS_TYPE_ID
  from per_assignments_f   paf,
       per_people_f        ppf,
       per_person_types    ppt
 where ppf.person_id           = paf.person_id
   and effective_date between ppf.effective_start_date and ppf.effective_end_date
   and effective_date between paf.effective_start_date and paf.effective_end_date
   and paf.primary_flag        = 'Y'
   and paf.assignment_type     <> 'B'
   and ppf.person_type_id      = ppt.person_type_id
   and ppt.system_person_type  IN ('EMP','EMP_APL')
   and paf.organization_id     = p_org_id
   and paf.position_id is not null
   order by ppf.person_id;

---
--- Bug  3539816 Order by added to prevent snapshot old error
--- 2. Cursor with no organization.
---
--- This SQL is tuned by joining the hr_organization_units to avoid the FTS of PAF.
--- Bug 6152582
---
cursor cur_people (effective_date date) is
select ppf.person_id                 PERSON_ID,
       ppf.first_name                FIRST_NAME,
       ppf.last_name                 LAST_NAME,
       ppf.middle_names              MIDDLE_NAMES,
       ppf.full_name                 FULL_NAME,
       ppf.date_of_birth             DATE_OF_BIRTH,
       ppf.national_identifier       NATIONAL_IDENTIFIER,
       paf.position_id               POSITION_ID,
       paf.assignment_id             ASSIGNMENT_ID,
       paf.grade_id                  GRADE_ID,
       paf.job_id                    JOB_ID,
       paf.location_id               LOCATION_ID,
       paf.organization_id           ORGANIZATION_ID,
       paf.business_group_id         BUSINESS_GROUP_ID,
       paf.assignment_status_type_id ASSIGNMENT_STATUS_TYPE_ID
  from per_assignments_f   paf,
       per_people_f        ppf,
       per_person_types    ppt,
       hr_organization_units hou
 where ppf.person_id           = paf.person_id
   and effective_date between ppf.effective_start_date and ppf.effective_end_date
   and effective_date between paf.effective_start_date and paf.effective_end_date
   and paf.primary_flag        = 'Y'
   and paf.assignment_type     <> 'B'
   and ppf.person_type_id      = ppt.person_type_id
   and ppt.system_person_type  IN ('EMP','EMP_APL')
   and paf.organization_id     = hou.organization_id
   and paf.position_id is not null
   order by ppf.person_id;
--
-- Check assignment_status_type
--

cursor cur_ast (asg_status_type_id number) is
select user_status from per_assignment_status_types
where assignment_status_type_id = asg_status_type_id
  and upper(user_status) not in (
                         'TERMINATE ASSIGNMENT',           /* 3 */
                         'ACTIVE APPLICATION',             /* 4 */
                         'OFFER',                          /* 5 */
                         'ACCEPTED',                       /* 6 */
                         'TERMINATE APPLICATION',          /* 7 */
                         'END',                            /* 8 */
                         'TERMINATE APPOINTMENT',          /* 126 */
                         'SEPARATED');                     /* 132 */

--
-- Cursor to select from GHR_MASS_SALARIES - Where criteria is stored
-- Before executing this package
-- from ghr_mass_salary_criteria

cursor ghr_msl (p_msl_id number) is
select name, effective_date, mass_salary_id, user_table_id, submit_flag,
       executive_order_number, executive_order_date, ROWID, PA_REQUEST_ID,
       ORGANIZATION_ID, DUTY_STATION_ID, PERSONNEL_OFFICE_ID,
       AGENCY_CODE_SUBELEMENT, OPM_ISSUANCE_NUMBER, OPM_ISSUANCE_DATE, PROCESS_TYPE
  from ghr_mass_salaries
 where MASS_SALARY_ID = p_msl_id
   for update of user_table_id nowait;

-- VSM [family name was hardcoded previously to SALARY_CHG. Fetching it from DB now]
/*cursor get_sal_chg_fam is
select NOA_FAMILY_CODE
from ghr_families
where NOA_FAMILY_CODE in
    (select NOA_FAMILY_CODE from ghr_noa_families
         where  nature_of_action_id =
            (select nature_of_action_id
             from ghr_nature_of_actions
             where code = '894')
    ) and proc_method_flag = 'Y';    --AVR 13-JAN-99	  */
 -------------   ) and update_hr_flag = 'Y';

l_assignment_id        per_assignments_f.assignment_id%type;
l_position_id          per_assignments_f.position_id%type;
l_grade_id             per_assignments_f.grade_id%type;
l_business_group_id    per_assignments_f.business_group_id%type;

l_position_title       varchar2(300);
l_position_number      varchar2(20);
l_position_seq_no      varchar2(20);

l_msl_cnt              number := 0;
l_recs_failed          number := 0;

l_tenure               varchar2(35);
l_annuitant_indicator  varchar2(35);
l_pay_rate_determinant varchar2(35);
l_work_schedule        varchar2(35);
l_part_time_hour       varchar2(35);
l_pay_table_id         number;
l_pay_plan             varchar2(30);
l_grade_or_level       varchar2(30);
l_step_or_rate         varchar2(30);
l_pay_basis            varchar2(30);
l_location_id          number;
l_duty_station_id      number;
l_duty_station_desc    ghr_pa_requests.duty_station_desc%type;
l_duty_station_code    ghr_pa_requests.duty_station_code%type;
l_effective_date       date;
l_personnel_office_id  varchar2(300);
l_org_structure_id     varchar2(300);
l_sub_element_code     varchar2(300);

l_old_basic_pay        number;
l_old_avail_pay        number;
l_old_loc_diff         number;
l_tot_old_sal          number;
l_old_auo_pay          number;
l_old_ADJ_basic_pay    number;
l_other_pay            number;


l_auo_premium_pay_indicator     varchar2(30);
l_ap_premium_pay_indicator      varchar2(30);
l_retention_allowance           number;
l_retention_allow_perc          number;     ---AVR
l_new_retention_allowance       number;     ---AVR
l_supervisory_differential      number;
l_supervisory_diff_perc         number;     ---AVR
l_new_supervisory_differential  number;     ---AVR
l_staffing_differential         number;

l_new_avail_pay             number;
l_new_loc_diff              number;
l_tot_new_sal               number;
l_new_auo_pay               number;

l_new_basic_pay             number;
l_new_locality_adj          number;
l_new_adj_basic_pay         number;
l_new_total_salary          number;
l_new_other_pay_amount      number;
l_new_au_overtime           number;
l_new_availability_pay      number;
l_out_step_or_rate          varchar2(30);
l_out_pay_rate_determinant  varchar2(30);
l_PT_eff_start_date         date;
l_open_pay_fields           boolean;
l_message_set               boolean;
l_calculated                boolean;

l_mass_salary_id            number;
l_user_table_id             number;
l_submit_flag               varchar2(2);
l_executive_order_number    ghr_mass_salaries.executive_order_number%TYPE;
l_executive_order_date      ghr_mass_salaries.executive_order_date%TYPE;
l_opm_issuance_number       ghr_mass_salaries.opm_issuance_number%TYPE;
l_opm_issuance_date         ghr_mass_salaries.opm_issuance_date%TYPE;
l_pa_request_id             number;
l_rowid                     varchar2(30);

l_p_ORGANIZATION_ID           number;
l_p_DUTY_STATION_ID           number;
l_p_PERSONNEL_OFFICE_ID       varchar2(5);

L_row_cnt                   number := 0;

l_sf52_rec                  ghr_pa_requests%rowtype;
l_lac_sf52_rec              ghr_pa_requests%rowtype;
l_errbuf                    varchar2(2000);

l_retcode                   number;

l_pos_ei_data               per_position_extra_info%rowtype;
l_pos_grp1_rec              per_position_extra_info%rowtype;

l_pay_calc_in_data          ghr_pay_calc.pay_calc_in_rec_type;
l_pay_calc_out_data         ghr_pay_calc.pay_calc_out_rec_type;
l_sel_flg                   varchar2(2);

l_first_action_la_code1     varchar2(30);
l_first_action_la_code2     varchar2(30);

l_remark_code1              varchar2(30);
l_remark_code2              varchar2(30);
l_p_AGENCY_CODE_SUBELEMENT       varchar2(30);

----Pay cap variables
l_entitled_other_pay        NUMBER;
l_capped_other_pay          NUMBER;
l_adj_basic_message         BOOLEAN  := FALSE;
l_pay_cap_message           BOOLEAN  := FALSE;
l_temp_retention_allowance  NUMBER;
l_open_pay_fields_caps      BOOLEAN;
l_message_set_caps          BOOLEAN;
l_total_pay_check           VARCHAR2(1);
l_comment                   VARCHAR2(150);
l_comment_sal               VARCHAR2(150);
l_pay_sel                   VARCHAR2(1) := NULL;
l_old_capped_other_pay     NUMBER;
----
l_row_low NUMBER;
l_row_high NUMBER;
l_comment_range VARCHAR2(150);
l_comments      VARCHAR2(150);

REC_BUSY                    exception;
pragma exception_init(REC_BUSY,-54);

l_proc  varchar2(72) :=  g_package || '.execute_msl_perc';

cursor c_pay_tab_essl is
  select 1 from pay_user_tables
  where substr(user_table_name,1,4) = 'ESSL'
  and user_table_id = l_user_table_id;

l_essl_table  BOOLEAN := FALSE;
l_org_name	hr_organization_units.name%type;

-- Bug 3315432 Madhuri
--
CURSOR cur_pp_prd_per_gr(p_msl_id ghr_mass_salary_criteria.mass_salary_id%type)
IS
SELECT criteria.pay_plan pay_plan,
       criteria.pay_rate_determinant prd,
       ext.increase_percent percent,
       ext.grade grade
FROM   ghr_mass_salary_criteria criteria, ghr_mass_salary_criteria_ext ext
WHERE  criteria.mass_salary_id=p_msl_id
AND    criteria.mass_salary_criteria_id=ext.mass_salary_criteria_id;


rec_pp_prd_per_gr pp_prd_per_gr;

l_index         NUMBER:=1;
l_cnt           NUMBER;
l_increase_percent NUMBER;
l_cust_percent     NUMBER;
l_elig_flag        BOOLEAN := FALSE;
--
-- Defining the record type variable
--
l_pay_calc_msl_percentage  ghr_mass_salary_criteria_ext.increase_percent%type;
l_ses_basic_pay   NUMBER;
--
--

--
-- GPPA Update 46
--
cursor cur_eq_ppl (c_pay_plan ghr_pay_plans.pay_plan%type)
IS
select EQUIVALENT_PAY_PLAN
from ghr_pay_plans
where pay_plan = c_pay_plan;

l_eq_pay_plan ghr_pay_plans.equivalent_pay_plaN%type;

--
--
PROCEDURE msl_perc_process(p_assignment_id  per_assignments_f.assignment_id%TYPE
							 ,p_person_id per_assignments_f.person_id%TYPE
							 ,p_position_id  per_assignments_f.position_id%TYPE
							 ,p_grade_id per_assignments_f.grade_id%TYPE
							 ,p_business_group_id per_assignments_f.business_group_iD%TYPE
							 ,p_location_id per_assignments_f.location_id%TYPE
							 ,p_organization_id per_assignments_f.organization_id%TYPE
							 ,p_date_of_birth date
							 ,p_first_name per_people_f.first_name%TYPE
							 ,p_last_name per_people_f.last_name%TYPE
                             ,p_full_name per_people_f.full_name%TYPE
                             ,p_middle_names per_people_f.middle_names%TYPE
							 ,p_national_identifier per_people_f.national_identifier%TYPE
                             ,p_personnel_office_id IN VARCHAR2
                             ,p_org_structure_id    IN VARCHAR2
                             ,p_position_title      IN VARCHAR2
                             ,p_position_number     IN VARCHAR2
                             ,p_position_seq_no     IN VARCHAR2
                             ,p_subelem_code        IN VARCHAR2
                             ,p_duty_station_id     IN ghr_duty_stations_f.duty_station_id%TYPE
                             ,p_tenure              IN VARCHAR2
                             ,p_annuitant_indicator IN VARCHAR2
                             ,p_pay_rate_determinant IN VARCHAR2
                             ,p_work_schedule       IN  VARCHAR2
                             ,p_part_time_hour      IN VARCHAR2
                             ,p_pay_plan            IN VARCHAR2
                             ,p_pay_table_id        IN NUMBER
                             ,p_grade_or_level      IN VARCHAR2
                             ,p_step_or_rate        IN VARCHAR2
                             ,p_pay_basis           IN VARCHAR2
                             ,p_increase_percent    IN VARCHAR2
               ) IS

    -- Bug3437354
    CURSOR cur_valid_DS(p_ds_id NUMBER)
        IS
        SELECT effective_end_date  end_date
        FROM   ghr_duty_stations_f
        WHERE  duty_station_id=p_ds_id
        AND    g_effective_date between effective_start_date and effective_end_date;
 --7577249
    cursor get_sal_chg_fam is
    select NOA_FAMILY_CODE
    from ghr_families
    where NOA_FAMILY_CODE in
       (select NOA_FAMILY_CODE from ghr_noa_families
        where  nature_of_action_id =
            (select nature_of_action_id
             from ghr_nature_of_actions
             where code = nvl(g_first_noa_code,'894') and g_effective_date between date_from and nvl(date_to,g_effective_date))
        ) and proc_method_flag = 'Y';
--7577249
        l_ds_end_date	  ghr_duty_stations_f.effective_end_date%type;

	l_locality_adj      number;
	l_multi_error_flag  boolean;

BEGIN
      savepoint execute_msl_perc_sp;
         l_msl_cnt := l_msl_cnt +1;
         --Bug#3968005 Initialised l_sel_flg
         l_sel_flg := NULL;
         l_pay_calc_in_data  := NULL;
         l_pay_calc_out_data := NULL;


       l_assignment_id     := p_assignment_id;
       l_position_id       := p_position_id;
       l_grade_id          := p_grade_id;
       l_business_group_id := p_business_group_iD;
       l_location_id       := p_location_id;

       -- Bug#5063304
        l_personnel_office_id  := p_personnel_office_id;
        l_org_structure_id     := p_org_structure_id;
        l_position_title       := p_position_title;
        l_position_number      := p_position_number;
        l_position_seq_no      := p_position_seq_no;
        l_sub_element_code     := p_subelem_code;
        l_duty_station_id      := p_duty_station_id;
        l_tenure               := p_tenure;
        l_annuitant_indicator  := p_annuitant_indicator;
        l_pay_rate_determinant := p_pay_rate_determinant;
        l_work_schedule        := P_work_schedule;
        l_part_time_hour       := p_part_time_hour;
        l_pay_plan             := p_pay_plan;
        l_pay_table_id         := p_pay_table_id;
        l_grade_or_level       := p_grade_or_level;
        l_step_or_rate         := P_step_or_rate;
        l_pay_basis            := p_pay_basis;

	hr_utility.set_location('The location id is:'||l_location_id,12345);

        ghr_msl_pkg.g_first_noa_code := '894';
--------GPPA Update 46 start
          --  ghr_msl_pkg.g_first_noa_code := NULL;
            FOR cur_eq_ppl_rec IN cur_eq_ppl(l_pay_plan)
            LOOP
                l_eq_pay_plan   := cur_eq_ppl_rec.EQUIVALENT_PAY_PLAN;
                exit;
            END LOOP;
            if l_effective_date >= to_date('2007/01/07','YYYY/MM/DD') AND
               l_eq_pay_plan = 'GS' AND
               l_lac_sf52_rec.first_action_la_code1 = 'QLP' AND
               l_lac_sf52_rec.first_action_la_code2 = 'ZLM' THEN

               ghr_msl_pkg.g_first_noa_code := '890';

            end if;
            if l_effective_date >= to_date('2007/01/07','YYYY/MM/DD') AND
               l_eq_pay_plan = 'FW' AND
               l_lac_sf52_rec.first_action_la_code1 = 'RJR' THEN

               ghr_msl_pkg.g_first_noa_code := '890';

            end if;
--------GPPA Update 46 end


---- Start of Bug #7577249
       IF l_essl_table and (l_eq_pay_plan = 'ES' OR l_pay_plan = 'FE') then
        If l_pay_plan in ('ES', 'FE', 'IE', 'EP') and
 	    l_lac_sf52_rec.first_action_la_code1 = 'Q3A' then
	    ghr_msl_pkg.g_first_noa_code := '891';
	elsif l_pay_plan in ('ES', 'FE', 'IE', 'EP') and
            l_lac_sf52_rec.first_action_la_code1 = 'Q3B' then
	    ghr_msl_pkg.g_first_noa_code := '892';
	elsif l_pay_plan in ('ES', 'FE', 'IE', 'EP') and
	      l_lac_sf52_rec.first_action_la_code1 = 'Q3D' then
	    ghr_msl_pkg.g_first_noa_code := '890';
        elsif l_pay_plan in ('ES', 'FE', 'IE', 'EP') and
	      l_lac_sf52_rec.first_action_la_code1 = 'Q3E' then
	    ghr_msl_pkg.g_first_noa_code := '890';
	end if;
       END IF;

       --------end of Bug #7577249

       -- Bug 8320557 SL Equivalent Pay band conv
       ghr_msl_pkg.g_sl_payband_conv := FALSE;
       ---Changes related to SL/ST/IP conversion
       If l_essl_table and l_eq_pay_plan = 'SL' then
--         If l_pay_plan in ('SL', 'ST', 'IP') then
	   If l_effective_date = to_date('2009/04/12','YYYY/MM/DD') then
	       --Fetching the locality adjustment as this conversion
	       -- is applicable only if locality is available
               ghr_api.retrieve_element_entry_value
                       (p_element_name          => 'Locality Pay or SR Supplement'
                       ,p_input_value_name      => 'Rate'
                       ,p_assignment_id         => l_assignment_id
                       ,p_effective_date        => l_effective_date
                       ,p_value                 => l_locality_adj
                       ,p_multiple_error_flag   => l_multi_error_flag);

               if l_multi_error_flag then
                  hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
                  hr_utility.raise_error;
               end if;

	       If NVL(l_locality_adj,0) > 0 then
	          ghr_msl_pkg.g_sl_payband_conv := TRUE;
	          ghr_msl_pkg.g_first_noa_code := '890';
		  l_lac_sf52_rec.first_action_la_code1 := 'ZLM';
                  l_lac_sf52_rec.first_action_la_desc1 := 'P.L. 110-372';
	       end if;
	   end if;
--	end if;
      end if;
--------end of Bug #8320557



    -- Start of Bug3437354
        g_proc := 'Location Validation';
        IF l_location_id IS NULL THEN
            l_mslerrbuf := 'Error - No valid Location found, salary cannot be calculated correctly'||
                               ' without the employee''s duty location. ';
                RAISE msl_error;
        END IF;
        g_proc := 'Duty Station Validation';
        IF l_duty_station_id IS NOT NULL THEN

            --
            -- Added this condition for bug 3437354, error out the record without valid Loc id
            --
            FOR rec_ds in cur_valid_ds(l_duty_station_id)
            LOOP
                l_ds_end_date	:= rec_ds.end_Date;
            END LOOP;
            IF l_ds_end_date IS NULL THEN
                hr_utility.set_location('Under DS null check'||l_duty_station_id,12345);
                l_mslerrbuf := 'Error - Duty Station associated with the location is INVALID. '||
                               'Salary cannot be calculated correctly without valid duty station. ';
                RAISE msl_error;
            END IF;

        END IF;
        -- End of bug 3437354

       /*begin
          ghr_pa_requests_pkg.get_SF52_loc_ddf_details
              (p_location_id      => l_location_id
              ,p_duty_station_id  => l_duty_station_id);
       exception
          when others then
             hr_utility.set_location(
             'Error in Ghr_pa_requests_pkg.get_sf52_loc_ddf_details'||
                   'Err is '||sqlerrm(sqlcode),20);
             l_mslerrbuf := 'Error in get_sf52_loc_ddf_details '||
                   'Sql Err is '|| sqlerrm(sqlcode);
             raise msl_error;
       end;*/

	--
	-- BUG 3377958 Madhuri
	-- Pick the organization name
	--
	l_org_name :=GHR_MRE_PKG.GET_ORGANIZATION_NAME(p_ORGANIZATION_ID);
	-- BUG 3377958 Madhuri
	--
       /*get_pos_grp1_ddf(l_position_id,
                        l_effective_date,
                        l_pos_grp1_rec);

       l_personnel_office_id :=  l_pos_grp1_rec.poei_information3;
       l_org_structure_id    :=  l_pos_grp1_rec.poei_information5;

       get_sub_element_code_pos_title(l_position_id,
                                     p_person_id,
                                     l_business_group_id,
                                     l_assignment_id,
                                     l_effective_date,
                                     l_sub_element_code,
                                     l_position_title,
                                     l_position_number,
                                     l_position_seq_no);

	hr_utility.set_location('The duty station id is:'||l_duty_station_id,12345);

       if check_init_eligibility(l_p_duty_station_id,
                              l_p_PERSONNEL_OFFICE_ID,
                              l_p_AGENCY_CODE_SUBELEMENT,
                              l_duty_station_id,
                              l_personnel_office_id,
                              l_sub_element_code) then

		   hr_utility.set_location('check_init_eligibility    ' || l_proc,6);
		-- Bug 3457205 Filter the Pay plan table id condition also b4 checking any other thing
		-- Moving check_eligibility to here.
			-- Get PRD, work schedule etc form ASG EI
			 begin
				ghr_pa_requests_pkg.get_sf52_asg_ddf_details
						  (l_assignment_id,
						   l_effective_date,
						   l_tenure,
						   l_annuitant_indicator,
						   l_pay_rate_determinant,
						   l_work_schedule,
						   l_part_time_hour);
			 exception
				when others then
					hr_utility.set_location('Error in Ghr_pa_requests_pkg.get_sf52_asg_ddf_details'||
							  'Err is '||sqlerrm(sqlcode),20);
					l_mslerrbuf := 'Error in get_sf52_asgddf_details Sql Err is '|| sqlerrm(sqlcode);
					raise msl_error;
			 end;

-- Bug 3315432 Madhuri
--
        FOR l_cnt in 1..rec_pp_prd_per_gr.COUNT LOOP

/ *	IF ( nvl(rec_pp_prd_per_gr(l_cnt).pay_plan,l_pay_plan) = l_pay_plan
	    and nvl(rec_pp_prd_per_gr(l_cnt).prd,l_pay_rate_determinant) = l_pay_rate_determinant
	    and l_user_table_id = nvl(l_pay_table_id,l_user_table_id) ) THEN * /

---Bug 3327999 First filter the PRD. Then check for Pay plan and Pay table ID
		IF nvl(rec_pp_prd_per_gr(l_cnt).prd,l_pay_rate_determinant) = l_pay_rate_determinant THEN
		-- Get Pay table ID and other details
           BEGIN
		       get_pay_plan_and_table_id(l_pay_rate_determinant,p_person_id,
                           l_position_id,l_effective_date,
                           l_grade_id, l_assignment_id,'SHOW',l_pay_plan,
                           l_pay_table_id,l_grade_or_level, l_step_or_rate,
                           l_pay_basis);
           EXCEPTION
               when msl_error then
                 l_mslerrbuf := hr_utility.get_message;
                 raise;
           END;

		IF ( nvl(rec_pp_prd_per_gr(l_cnt).pay_plan,l_pay_plan) = l_pay_plan
			and l_user_table_id = nvl(l_pay_table_id,l_user_table_id) ) THEN

		IF ( nvl(rec_pp_prd_per_gr(l_cnt).grade,l_grade_or_level)=l_grade_or_level
			and nvl(rec_pp_prd_per_gr(l_cnt).percent,0) <> 0 ) THEN


			IF check_eligibility(l_mass_salary_id,
                               l_user_table_id,
                               l_pay_table_id,
                               l_pay_plan,
                               l_pay_rate_determinant,
                               p_person_id,
                               l_effective_date,
                               p_action) THEN
                hr_utility.set_location('check_eligibility    ' || l_proc,8);

			 l_increase_percent := nvl(rec_pp_prd_per_gr(l_cnt).percent,0);*/

			 if upper(p_action) = 'REPORT' AND l_submit_flag = 'P' THEN
		 	 -- BUG 3377958 Madhuri
 			    pop_dtls_from_pa_req(p_person_id,l_effective_date,l_mass_salary_id,l_org_name);
 		    	 -- BUG 3377958 Madhuri
			 ELSE
			   if check_select_flg_msl_perc(p_person_id,upper(p_action),
						l_effective_date,p_mass_salary_id,l_sel_flg,
						l_increase_percent ) then

				   hr_utility.set_location('check_select_flg    ' || l_proc,7);
                   begin
					hr_utility.set_location('The duty station name is:'||l_duty_station_code,12345);
					hr_utility.set_location('The duty station desc is:'||l_duty_station_desc,12345);

			     ghr_pa_requests_pkg.get_duty_station_details
                       (p_duty_station_id        => l_duty_station_id
                       ,p_effective_date        => l_effective_date
                       ,p_duty_station_code        => l_duty_station_code
                       ,p_duty_station_desc        => l_duty_station_desc);
                  exception
                     when others then
                        hr_utility.set_location('Error in Ghr_pa_requests_pkg.get_duty_station_details'||
                               'Err is '||sqlerrm(sqlcode),20);
                    l_mslerrbuf := 'Error in get_duty_station_details Sql Err is '|| sqlerrm(sqlcode);
                    raise msl_error;

                  end;

                     get_other_dtls_for_rep(l_pay_rate_determinant,
                                     l_executive_order_number,
                                     to_char(l_executive_order_date),
                                     l_first_action_la_code1,
                                     l_first_action_la_code2,
                                     l_remark_code1,
                                     l_remark_code2);

                     get_from_sf52_data_elements
                            (l_assignment_id,  l_effective_date,
                             l_old_basic_pay, l_old_avail_pay,
                             l_old_loc_diff, l_tot_old_sal,
                             l_old_auo_pay, l_old_adj_basic_pay,
                             l_other_pay, l_auo_premium_pay_indicator,
                             l_ap_premium_pay_indicator,
                             l_retention_allowance,
                             l_retention_allow_perc,
                             l_supervisory_differential,
                             l_supervisory_diff_perc,
                             l_staffing_differential);

--7577249 commented hardcoding and fetched the family code from DB
-- as it changes the NOA code based on LAC for SES perc process.
  open get_sal_chg_fam;
  fetch get_sal_chg_fam into l_pay_calc_in_data.noa_family_code;
  close get_sal_chg_fam;
--7577249



  l_pay_calc_in_data.person_id          := p_person_id;
  l_pay_calc_in_data.position_id              := l_position_id;
  --l_pay_calc_in_data.noa_family_code          := 'SALARY_CHG';
  --l_pay_calc_in_data.noa_family_code          := 'GHR_SAL_PAY_ADJ';
  l_pay_calc_in_data.noa_code                 := nvl(g_first_noa_code,'894');
  l_pay_calc_in_data.second_noa_code          := null;
  l_pay_calc_in_data.first_action_la_code1    := l_lac_sf52_rec.first_action_la_code1;
  l_pay_calc_in_data.effective_date           := l_effective_date;
  l_pay_calc_in_data.pay_rate_determinant     := l_pay_rate_determinant;
  l_pay_calc_in_data.pay_plan                 := l_pay_plan;
  l_pay_calc_in_data.grade_or_level           := l_grade_or_level;
  l_pay_calc_in_data.step_or_rate             := l_step_or_rate;
  l_pay_calc_in_data.pay_basis                := l_pay_basis;
  l_pay_calc_in_data.user_table_id            := l_pay_table_id;
  l_pay_calc_in_data.duty_station_id          := l_duty_station_id;
  l_pay_calc_in_data.auo_premium_pay_indicator := l_auo_premium_pay_indicator;
  l_pay_calc_in_data.ap_premium_pay_indicator  := l_ap_premium_pay_indicator;
  l_pay_calc_in_data.retention_allowance       := l_retention_allowance;
  l_pay_calc_in_data.to_ret_allow_percentage   := l_retention_allow_perc;
  l_pay_calc_in_data.supervisory_differential  := l_supervisory_differential;
  l_pay_calc_in_data.staffing_differential    := l_staffing_differential;
  l_pay_calc_in_data.current_basic_pay        := l_old_basic_pay;
  l_pay_calc_in_data.current_adj_basic_pay    := l_old_adj_basic_pay;
  l_pay_calc_in_data.current_step_or_rate     := l_step_or_rate;
  l_pay_calc_in_data.pa_request_id            := null;

  ghr_msl_pkg.g_ses_msl_process              := 'N';

  if l_pay_plan in ('ES','EP','IE','FE') and l_essl_table then
     ghr_msl_pkg.g_ses_msl_process           := 'Y';
     l_step_or_rate                          := '00';
  end if;

  -- Bug # 8320557 to add basic pay with locality
  if ghr_msl_pkg.g_sl_payband_conv then
     l_pay_calc_in_data.open_range_out_basic_pay   := l_old_basic_pay+l_old_loc_diff;
  else

  ---3843306
  -- Start of MSL percentage changes
  --
  --l_pay_calc_msl_percentage := rec_pp_prd_per_gr(l_cnt).percent;
	  l_pay_calc_msl_percentage := l_increase_percent; -- Bug 3843306

     get_extra_info_comments(p_person_id,l_effective_date,l_pay_sel,
                             l_comments,p_mass_salary_id,l_cust_percent,l_ses_basic_pay); -- Added by AVR 3964284
     l_comments := NULL;

  -- Recalculate Open range basic pay with new %.
	   ghr_pay_calc.get_open_pay_table_values
                          (p_user_table_id     =>   l_pay_table_id
                         ,p_pay_plan          =>  l_pay_plan
                          ,p_grade_or_level    =>   l_grade_or_level
                        ,p_effective_date    =>  NVL(l_effective_date,TRUNC(sysdate))
                          ,p_row_high          =>  l_row_high
                          ,p_row_low           =>  l_row_low );
-- MSL Percentage issue
	IF l_pay_basis='PA' THEN
	  l_pay_calc_in_data.open_range_out_basic_pay := round(l_pay_calc_in_data.current_basic_pay *
                 				( 1 + ( l_pay_calc_msl_percentage / 100 ) ),0);
	ELSIF l_pay_basis='PH' THEN
	  l_pay_calc_in_data.open_range_out_basic_pay := round(l_pay_calc_in_data.current_basic_pay *
                 				( 1 + ( l_pay_calc_msl_percentage / 100 ) ),2);
	ELSE
	  l_pay_calc_in_data.open_range_out_basic_pay := round(l_pay_calc_in_data.current_basic_pay *
                 				( 1 + ( l_pay_calc_msl_percentage / 100 ) ),0);
        END IF;

		IF l_pay_calc_in_data.open_range_out_basic_pay < l_row_low THEN
		   l_comment_range := 'MSL:New Basic Pay is set to table minimum ' || l_row_low;
           l_comments := substr(l_comments || ' ' || l_comment_range , 1,150);
			ins_upd_per_extra_info
				   (p_person_id,l_effective_date, l_sel_flg, l_comments,p_mass_salary_id,l_cust_percent);
			l_pay_calc_in_data.open_range_out_basic_pay := l_row_low;
		   l_comment_range:= NULL;

		ELSIF l_pay_calc_in_data.open_range_out_basic_pay > l_row_high THEN
		   l_comment_range := 'MSL:New Basic Pay is set to table maximum ' || l_row_high;
           l_comments := substr(l_comments || ' ' || l_comment_range , 1,150);
		   ins_upd_per_extra_info
				   (p_person_id,l_effective_date, l_sel_flg, l_comments,p_mass_salary_id,l_cust_percent);
		   l_pay_calc_in_data.open_range_out_basic_pay := l_row_high;
		   l_comment_range:= NULL;
		ELSE
		   l_comment_range:= NULL;
		END IF;
     end if;

  -- 3843306
  -- End of MSL percentage Changes
              begin
                  ghr_pay_calc.sql_main_pay_calc (l_pay_calc_in_data
                       ,l_pay_calc_out_data
                       ,l_message_set
                       ,l_calculated);

					IF l_message_set THEN
						hr_utility.set_location( l_proc, 40);
						l_calculated     := FALSE;
						l_mslerrbuf  := hr_utility.get_message;
			--			raise msl_error;
					END IF;
              exception
                  when msl_error then
                       g_proc := 'ghr_pay_calc';
                      raise;
                  when others then
                ----BUG 3287299 Start
                IF ghr_pay_calc.gm_unadjusted_pay_flg = 'Y' then
                  l_comment := 'MSL:Error: Unadjusted Basic Pay must be entered in Employee record.';
                ELSE
                  l_comment := 'MSL:Error: See process log for details.';
                END IF;

                IF upper(p_action) IN ('SHOW') THEN
                      -- Bug#2383392
                     create_mass_act_prev (
			p_effective_date          => l_effective_date,
			p_date_of_birth           => p_date_of_birth,
			p_full_name               => p_full_name,
			p_national_identifier     => p_national_identifier,
			p_duty_station_code       => l_duty_station_code,
			p_duty_station_desc       => l_duty_station_desc,
			p_personnel_office_id     => l_personnel_office_id,
			p_basic_pay               => l_old_basic_pay,
			p_new_basic_pay           => null,
			--Bug#2383992 Added old_adj_basic_pay
			p_adj_basic_pay           => l_old_adj_basic_pay,
			p_new_adj_basic_pay       => null,
			p_old_avail_pay           => l_old_avail_pay,
			p_new_avail_pay           => null,
			p_old_loc_diff            => l_old_loc_diff,
			p_new_loc_diff            => null,
			p_tot_old_sal             => l_tot_old_sal,
			p_tot_new_sal             => null,
			p_old_auo_pay             => l_old_auo_pay,
			p_new_auo_pay             => null,
			p_position_id             => l_position_id,
			p_position_title          => l_position_title,
             -- FWFA Changes Bug#4444609
            p_position_number         => l_position_number,
            p_position_seq_no         => l_position_seq_no,
             -- FWFA Changes
			p_org_structure_id        => l_org_structure_id,
			p_agency_sub_element_code => l_sub_element_code,
			p_person_id               => p_person_id,
			p_mass_salary_id          => l_mass_salary_id,
			p_sel_flg                 => l_sel_flg,
			p_first_action_la_code1   => l_first_action_la_code1,
			p_first_action_la_code2   => l_first_action_la_code2,
			p_remark_code1            => l_remark_code1,
			p_remark_code2            => l_remark_code2,
			p_grade_or_level          => l_grade_or_level,
			p_step_or_rate            => l_step_or_rate,
			p_pay_plan                => l_pay_plan,
			p_pay_rate_determinant    => NULL,
			p_tenure                  => l_tenure,
			p_action                  => p_action,
			p_assignment_id           => l_assignment_id,
			p_old_other_pay           => l_other_pay,
			p_new_other_pay           => null,
			-- Bug#2383992
			p_old_capped_other_pay    => NULL,
			p_new_capped_other_pay    => NULL,
			p_old_retention_allowance => l_retention_allowance,
			p_new_retention_allowance => NULL,
			p_old_supervisory_differential => l_supervisory_differential,
			p_new_supervisory_differential => NULL,
			-- BUG 3377958 Madhuri
			p_organization_name            => l_org_name,
			-- BUG 3377958 Madhuri
			-- Bug#2383992
			p_increase_percent => l_pay_calc_msl_percentage,
            -- FWFA Changes Bug#4444609
            p_input_pay_rate_determinant  => l_pay_rate_determinant,
            p_from_pay_table_id         => l_user_table_id,
            p_to_pay_table_id           =>  null
            -- FWFA Changes
             );
                      END IF;
                      l_comments := substr(l_comments || ' ' || l_comment , 1,150);
                      ins_upd_per_extra_info
                         (p_person_id,l_effective_date, l_sel_flg, l_comments,p_mass_salary_id,l_cust_percent);
                      l_comment := NULL;
                      ------  BUG 3287299 End
                      hr_utility.set_location('Error in Ghr_pay_calc.sql_main_pay_calc '||
                                'Err is '||sqlerrm(sqlcode),20);
                    l_mslerrbuf := 'Error in ghr_pay_calc  Sql Err is '|| sqlerrm(sqlcode);
                    g_proc := 'ghr_pay_calc';
                    raise msl_error;
              end;

        ghr_msl_pkg.g_ses_msl_process              := 'N';

        l_new_basic_pay        := l_pay_calc_out_data.basic_pay;
        l_new_locality_adj     := l_pay_calc_out_data.locality_adj;
        l_new_adj_basic_pay    := l_pay_calc_out_data.adj_basic_pay;
        l_new_au_overtime      := l_pay_calc_out_data.au_overtime;
        l_new_availability_pay := l_pay_calc_out_data.availability_pay;

        l_out_pay_rate_determinant := l_pay_calc_out_data.out_pay_rate_determinant;
        l_out_step_or_rate         := l_pay_calc_out_data.out_step_or_rate;
        l_new_retention_allowance :=  l_pay_calc_out_data.retention_allowance;
        l_new_supervisory_differential := l_supervisory_differential;
        l_new_other_pay_amount         := l_pay_calc_out_data.other_pay_amount;
        l_entitled_other_pay      := l_new_other_pay_amount;
        if l_new_other_pay_amount = 0 then
           l_new_other_pay_amount := null;
        end if;
        l_new_total_salary        := l_pay_calc_out_data.total_salary;

     hr_utility.set_location('retention_allowance = ' || to_char(l_retention_allowance),10);
     hr_utility.set_location('Supervisory Diff Amount = ' || to_char(l_supervisory_differential),10);

-------------Call Pay cap Procedure
     begin
      l_capped_other_pay := ghr_pa_requests_pkg2.get_cop( p_assignment_id  => l_assignment_id
                                                         ,p_effective_date => l_effective_date);
      l_old_capped_other_pay :=  l_capped_other_pay;
		-- Sundar Added the following if statement to improve performance
			if hr_utility.debug_enabled = true then
				  hr_utility.set_location('Before Pay Cap    ' || l_proc,21);
				  hr_utility.set_location('l_effective_date  ' || l_effective_date,21);
				  hr_utility.set_location('l_out_pay_rate_determinant  ' || l_out_pay_rate_determinant,21);
				  hr_utility.set_location('l_pay_plan  ' || l_pay_plan,21);
				  hr_utility.set_location('l_position_id  ' || to_char(l_position_id),21);
				  hr_utility.set_location('l_pay_basis  ' || l_pay_basis,21);
				  hr_utility.set_location('person_id  ' || to_char(p_person_id),21);
				  hr_utility.set_location('l_new_basic_pay  ' || to_char(l_new_basic_pay),21);
				  hr_utility.set_location('l_new_locality_adj  ' || to_char(l_new_locality_adj),21);
				  hr_utility.set_location('l_new_adj_basic_pay  ' || to_char(l_new_adj_basic_pay),21);
				  hr_utility.set_location('l_new_total_salary  ' || to_char(l_new_total_salary),21);
				  hr_utility.set_location('l_entitled_other_pay  ' || to_char(l_entitled_other_pay),21);
				  hr_utility.set_location('l_capped_other_pay  ' || to_char(l_capped_other_pay),21);
				  hr_utility.set_location('l_new_retention_allowance  ' || to_char(l_new_retention_allowance),21);
				  hr_utility.set_location('l_new_supervisory_differential  ' || to_char(l_new_supervisory_differential),21);
				  hr_utility.set_location('l_staffing_differential  ' || to_char(l_staffing_differential),21);
				  hr_utility.set_location('l_new_au_overtime  ' || to_char(l_new_au_overtime),21);
				  hr_utility.set_location('l_new_availability_pay  ' || to_char(l_new_availability_pay),21);
			end if;


      ghr_pay_caps.do_pay_caps_main
                   (p_pa_request_id        =>    null
                   ,p_effective_date       =>    l_effective_date
                   ,p_pay_rate_determinant =>    nvl(l_out_pay_rate_determinant,l_pay_rate_determinant)
                   ,p_pay_plan             =>    l_pay_plan
                   ,p_to_position_id       =>    l_position_id
                   ,p_pay_basis            =>    l_pay_basis
                   ,p_person_id            =>    p_person_id
                   ,p_noa_code             =>    nvl(g_first_noa_code,'894')
                   ,p_basic_pay            =>    l_new_basic_pay
                   ,p_locality_adj         =>    l_new_locality_adj
                   ,p_adj_basic_pay        =>    l_new_adj_basic_pay
                   ,p_total_salary         =>    l_new_total_salary
                   ,p_other_pay_amount     =>    l_entitled_other_pay
                   ,p_capped_other_pay     =>    l_capped_other_pay
                   ,p_retention_allowance  =>    l_new_retention_allowance
                   ,p_retention_allow_percentage => l_retention_allow_perc
                   ,p_supervisory_allowance =>   l_new_supervisory_differential
                   ,p_staffing_differential =>   l_staffing_differential
                   ,p_au_overtime          =>    l_new_au_overtime
                   ,p_availability_pay     =>    l_new_availability_pay
                   ,p_adj_basic_message    =>    l_adj_basic_message
                   ,p_pay_cap_message      =>    l_pay_cap_message
                   ,p_pay_cap_adj          =>    l_temp_retention_allowance
                   ,p_open_pay_fields      =>    l_open_pay_fields_caps
                   ,p_message_set          =>    l_message_set_caps
                   ,p_total_pay_check      =>    l_total_pay_check);


             l_new_other_pay_amount := nvl(l_capped_other_pay,l_entitled_other_pay);

			-- Sundar Added the following statement to improve performance
			if hr_utility.debug_enabled = true then
				  hr_utility.set_location('After Pay Cap    ' || l_proc,22);
				  hr_utility.set_location('l_effective_date  ' || l_effective_date,22);
				  hr_utility.set_location('l_out_pay_rate_determinant  ' || l_out_pay_rate_determinant,22);
				  hr_utility.set_location('l_pay_plan  ' || l_pay_plan,22);
				  hr_utility.set_location('l_position_id  ' || to_char(l_position_id),22);
				  hr_utility.set_location('l_pay_basis  ' || l_pay_basis,22);
				  hr_utility.set_location('person_id  ' || to_char(p_person_id),22);
				  hr_utility.set_location('l_new_basic_pay  ' || to_char(l_new_basic_pay),22);
				  hr_utility.set_location('l_new_locality_adj  ' || to_char(l_new_locality_adj),22);
				  hr_utility.set_location('l_new_adj_basic_pay  ' || to_char(l_new_adj_basic_pay),22);
				  hr_utility.set_location('l_new_total_salary  ' || to_char(l_new_total_salary),22);
				  hr_utility.set_location('l_entitled_other_pay  ' || to_char(l_entitled_other_pay),22);
				  hr_utility.set_location('l_capped_other_pay  ' || to_char(l_capped_other_pay),22);
				  hr_utility.set_location('l_new_retention_allowance  ' || to_char(l_new_retention_allowance),22);
				  hr_utility.set_location('l_new_supervisory_differential  ' || to_char(l_new_supervisory_differential),22);
				  hr_utility.set_location('l_staffing_differential  ' || to_char(l_staffing_differential),22);
				  hr_utility.set_location('l_new_au_overtime  ' || to_char(l_new_au_overtime),22);
				  hr_utility.set_location('l_new_availability_pay  ' || to_char(l_new_availability_pay),22);
			end if;

       IF l_pay_cap_message THEN
			IF nvl(l_temp_retention_allowance,0) > 0 THEN
			  l_comment := 'MSL: Exceeded Total Cap - reduce Retention Allow to '
										|| to_char(l_temp_retention_allowance);
			  l_sel_flg := 'N';
			ELSE
			  l_comment := 'MSL: Exceeded Total cap - pls review.';
			END IF;
       ELSIF l_adj_basic_message THEN
          l_comment := 'MSL: Exceeded Adjusted Pay Cap - Locality reduced.';
       END IF;

       -- Bug 2639698 Sundar
	   IF (l_old_basic_pay > l_new_basic_pay) THEN
			l_comment_sal := 'MSL: From Basic Pay exceeds To Basic Pay.';
       END IF;
	   -- End Bug 2639698

       IF l_pay_cap_message or l_adj_basic_message THEN
			-- Bug 2639698
		  IF (l_comment_sal IS NOT NULL) THEN
		     l_comment := l_comment_sal || ' ' || l_comment;
		  END IF;
		  -- End Bug 2639698
          l_comments := substr(l_comments || ' ' || l_comment, 1,150);
          ins_upd_per_extra_info
               (p_person_id,l_effective_date, l_sel_flg, l_comments,p_mass_salary_id,l_cust_percent);
          l_comment := NULL;
       --------------------Bug 2639698 Sundar To add comments
	   -- Should create comments only if comments need to be inserted
	   ELSIF l_comment_sal IS NOT NULL THEN
          l_comments := substr(l_comments || ' ' || l_comment_sal, 1,150);
		  ins_upd_per_extra_info
               (p_person_id,l_effective_date, l_sel_flg, l_comments,p_mass_salary_id,l_cust_percent);
	   END IF;

       l_comment_sal := NULL; -- bug 2639698
     exception
          when msl_error then
               raise;
          when others then
               hr_utility.set_location('Error in ghr_pay_caps.do_pay_caps_main ' ||
                                'Err is '||sqlerrm(sqlcode),23);
                    l_mslerrbuf := 'Error in do_pay_caps_main  Sql Err is '|| sqlerrm(sqlcode);
                    raise msl_error;
     end;

                IF upper(p_action) IN ('SHOW','REPORT') THEN
                          -- Bug#2383392
                    create_mass_act_prev (
                        p_effective_date          => l_effective_date,
                        p_date_of_birth           => p_date_of_birth,
                        p_full_name               => p_full_name,
                        p_national_identifier     => p_national_identifier,
                        p_duty_station_code       => l_duty_station_code,
                        p_duty_station_desc       => l_duty_station_desc,
                        p_personnel_office_id     => l_personnel_office_id,
                        p_basic_pay               => l_old_basic_pay,
                        p_new_basic_pay           => l_new_basic_pay,
                        --Bug#2383992 Added old_adj_basic_pay
                        p_adj_basic_pay           => l_old_adj_basic_pay,
                        p_new_adj_basic_pay       => l_new_adj_basic_pay,
                        p_old_avail_pay           => l_old_avail_pay,
                        p_new_avail_pay           =>  l_new_availability_pay,
                        p_old_loc_diff            => l_old_loc_diff,
                        p_new_loc_diff            => l_new_locality_adj,
                        p_tot_old_sal             => l_tot_old_sal,
                        p_tot_new_sal             =>   l_new_total_salary,
                        p_old_auo_pay             => l_old_auo_pay,
                        p_new_auo_pay             =>   l_new_au_overtime,
                        p_position_id             => l_position_id,
                        p_position_title          => l_position_title,
                    -- FWFA Changes Bug#4444609
                        p_position_number         => l_position_number,
                        p_position_seq_no         => l_position_seq_no,
                    -- FWFA Changes
                        p_org_structure_id        => l_org_structure_id,
                        p_agency_sub_element_code => l_sub_element_code,
                        p_person_id               => p_person_id,
                        p_mass_salary_id          => l_mass_salary_id,
                        p_sel_flg                 => l_sel_flg,
                        p_first_action_la_code1   => l_first_action_la_code1,
                        p_first_action_la_code2   => l_first_action_la_code2,
                        p_remark_code1            => l_remark_code1,
                        p_remark_code2            => l_remark_code2,
                        p_grade_or_level          => l_grade_or_level,
                        p_step_or_rate            => l_step_or_rate,
                        p_pay_plan                => l_pay_plan,
                        p_pay_rate_determinant    => NVL(l_out_pay_rate_determinant,l_pay_rate_determinant),
                        p_tenure                  => l_tenure,
                        p_action                  => p_action,
                        p_assignment_id           => l_assignment_id,
                        p_old_other_pay           => l_other_pay,
                        p_new_other_pay           => l_new_other_pay_amount,
                        -- Bug#2383992
                        p_old_capped_other_pay    => l_old_capped_other_pay,--NULL,
                        p_new_capped_other_pay    => l_capped_other_pay,
                        p_old_retention_allowance => l_retention_allowance,
                        p_new_retention_allowance => l_new_retention_allowance,
                        p_old_supervisory_differential => l_supervisory_differential,
                        p_new_supervisory_differential => l_new_supervisory_differential,
                        -- BUG 3377958 Madhuri
                        p_organization_name            => l_org_name,
                        -- Bug#2383992
                        p_increase_percent => l_pay_calc_msl_percentage,
                        -- FWFA Changes Bug#4444609
                        p_input_pay_rate_determinant     => l_pay_rate_determinant,
                        p_from_pay_table_id            => l_pay_calc_out_data.pay_table_id,
                        p_to_pay_table_id              => l_pay_calc_out_data.calculation_pay_table_id
                        -- FWFA Changes
                         );


                ELSIF upper(p_action) = 'CREATE' then
                    BEGIN
                       get_pay_plan_and_table_id
                          (l_pay_rate_determinant,p_person_id,
                           l_position_id,l_effective_date,
                           l_grade_id, l_assignment_id,'CREATE',
                           l_pay_plan,l_pay_table_id,
                           l_grade_or_level, l_step_or_rate,
                           l_pay_basis);
                    EXCEPTION
                    when msl_error then
                      l_mslerrbuf := hr_utility.get_message;
                      raise;
                    END;
                    assign_to_sf52_rec(
                       p_person_id,
                       p_first_name,
                       p_last_name,
                       p_middle_names,
                       p_national_identifier,
                       p_date_of_birth,
                       l_effective_date,
                       l_assignment_id,
                       l_tenure,
                       -- Bug#5089732
                       l_grade_id,
                       l_pay_plan,
                       l_grade_or_level,
                       -- Bug#5089732
                       l_step_or_rate,
                       l_annuitant_indicator,
                       -- FWFA Changes Bug#4444609
                       NVL(l_out_pay_rate_determinant,l_pay_rate_determinant),
                       -- FWFA Changes
                       l_work_schedule,
                       l_part_time_hour,
                       l_pos_ei_data.poei_information7, --FLSA Category
                       l_pos_ei_data.poei_information8, --Bargaining Unit Status
                       l_pos_ei_data.poei_information11,--Functional Class
                       l_pos_ei_data.poei_information16,--Supervisory Status,
                       l_new_basic_pay,
                       l_new_locality_adj,
                       l_new_adj_basic_pay,
                       l_new_total_salary,
                       l_other_pay,
                       l_new_other_pay_amount,
                       l_new_au_overtime,
                       l_new_availability_pay,
                       l_new_retention_allowance,
                       l_retention_allow_perc,
                       l_new_supervisory_differential,
                       l_supervisory_diff_perc,
                       l_staffing_differential,
                       l_duty_station_id,
                       l_duty_station_code,
                       l_duty_station_desc,
                       -- FWFA Changes Bug#4444609
                       l_pay_rate_determinant,
                       l_pay_calc_out_data.pay_table_id,
                       l_pay_calc_out_data.calculation_pay_table_id,
                       -- FWFA Changes
                       l_lac_sf52_rec,
                       l_sf52_rec);

					/* Bug#3964284 Commented the following code as PAY RELATED FIELDS are already
                                   Assigned to l_sf52_rec variable in the above procedure call(i.e.assign_to_sf52_rec)
                       */

                   BEGIN

		               l_sf52_rec.mass_action_id := p_mass_salary_id;
                       l_sf52_rec.rpa_type := 'MPC';
                       g_proc  := 'create_sf52_recrod';
                       ghr_mass_changes.create_sf52_for_mass_changes
                               (p_mass_action_type => 'MASS_SALARY_CHG',
                                p_pa_request_rec  => l_sf52_rec,
                                p_errbuf           => l_errbuf,
                                p_retcode          => l_retcode);

                       ------ Added by Dinkar for List reports problem
                       ---------------------------------------
                       IF l_errbuf IS NULL THEN
                           DECLARE
                               l_pa_request_number ghr_pa_requests.request_number%TYPE;
						   BEGIN
         				       l_pa_request_number   :=
							    	 l_sf52_rec.request_number||'-'||p_mass_salary_id;

						       ghr_par_upd.upd
                              (p_pa_request_id             => l_sf52_rec.pa_request_id,
                               p_object_version_number     => l_sf52_rec.object_version_number,
                               p_request_number            => l_pa_request_number
                              );
						   END;

                           pr('No error in create sf52 ');
                           ghr_mto_int.log_message(
                              p_procedure => 'Successful Completion',
                              p_message   => 'Name: '||p_full_name ||
                              ' SSN: '|| p_national_identifier||
                              '  Mass Salary : '||
                              p_mass_salary ||' SF52 Successfully completed');

                           create_lac_remarks(l_pa_request_id,
                                           l_sf52_rec.pa_request_id);

                           -- Added by Enunez 11-SEP-1999
                           IF l_lac_sf52_rec.first_action_la_code1 IS NULL THEN
                               -- Added by Edward Nunez for 894 rules
                               g_proc := 'Apply_894_Rules';
                               --Bug 2012782 fix
                               IF l_out_pay_rate_determinant IS NULL THEN
                                  l_out_pay_rate_determinant := l_pay_rate_determinant;
                               END IF;
                               --Bug 2012782 fix end
                               ghr_lacs_remarks.Apply_894_Rules(
                                   l_sf52_rec.pa_request_id,
                                   l_out_pay_rate_determinant,
                                   l_pay_rate_determinant,
                                   l_out_step_or_rate,
                                   l_executive_order_number,
                                   l_executive_order_date,
                                   l_opm_issuance_number,
                                   l_opm_issuance_date,
                                   l_errbuf,
                                   l_retcode
                                   );
                               IF l_errbuf IS NOT NULL THEN
                                   l_mslerrbuf := l_mslerrbuf || ' ' || l_errbuf || ' Sql Err is '
                                                                  || sqlerrm(sqlcode);
                                   RAISE msl_error;
                               END IF;
                           END IF; -- IF l_lac_sf52_rec.first_action_la_code1
                           g_proc := 'update_SEL_FLG';

                           update_SEL_FLG(p_PERSON_ID,l_effective_date);

                           COMMIT;
                       ELSE
                           pr('Error in create sf52',l_errbuf);
                           hr_utility.set_location('Error in '||to_char(p_position_id),20);
                           l_recs_failed := l_recs_failed + 1;
                           -- Error raising is not required as the error is written to process
                           -- log in the create_sf52_for_mass_changes procedure.
                           --raise msl_error;
                       END IF; -- if l_errbuf is null then
                   EXCEPTION
                       when msl_error then raise;
                       when others then  null;
                           l_mslerrbuf := 'Error in ghr_mass_chg.create_sf52 '||
                                          ' Sql Err is '|| sqlerrm(sqlcode);
                           RAISE msl_error;
                   END;
               END IF; --  IF upper(p_action) IN ('SHOW','REPORT') THEN
           END IF; -- end if for check_select_flg
       END IF; -- end if for p_action = 'REPORT'

       l_row_cnt := l_row_cnt + 1;
       IF UPPER(p_action) <> 'CREATE' THEN
           IF L_row_cnt > 50 THEN
               COMMIT;
               L_row_cnt := 0;
           END IF;
       END IF;
   EXCEPTION
         WHEN MSL_ERROR THEN
               HR_UTILITY.SET_LOCATION('Error occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),10);
               begin
                ------  BUG 3287299 -- Not to rollback for preview.
       	        if upper(p_action) <> 'SHOW' then
                  ROLLBACK TO execute_msl_perc_SP;
                end if;
               EXCEPTION
                  WHEN OTHERS THEN NULL;
               END;
               l_log_text  := 'Error in '||l_proc||' '||
                              ' For Mass Salary Name : '||p_mass_salary||
                              'Name: '|| p_full_name || ' SSN: ' || p_national_identifier ||' '||
                              l_mslerrbuf;
               hr_utility.set_location('before creating entry in log file',10);
               l_recs_failed := l_recs_failed + 1;
            begin
               ghr_mto_int.log_message(
                              p_procedure => g_proc,
                              p_message   => l_log_text);

            exception
                when others then
                    hr_utility.set_message(8301, 'GHR_38475_ERROR_LOG_FAILURE');
                    hr_utility.raise_error;
            end;
         when others then
               HR_UTILITY.SET_LOCATION('Error (Others) occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),20);
               BEGIN
                 ROLLBACK TO execute_msl_perc_SP;
               EXCEPTION
                 WHEN OTHERS THEN NULL;
               END;
               l_log_text  := 'Error (others) in '||l_proc||
                              ' For Mass Salary Name : '||p_mass_salary||
                              'Name: '|| p_full_name || ' SSN: ' || p_national_identifier ||
                              ' Sql Err is '||sqlerrm(sqlcode);
               hr_utility.set_location('before creating entry in log file',20);
               l_recs_failed := l_recs_failed + 1;
            begin
               ghr_mto_int.log_message(
                              p_procedure => g_proc,
                              p_message   => l_log_text);

            exception
                when others then
                    hr_utility.set_message(8301, 'Create Error Log failed');
                    hr_utility.raise_error;
            end;


   END msl_perc_process;

BEGIN

  g_proc  := 'execute_msl_perc';
  hr_utility.set_location('Entering    ' || l_proc,5);
  p_retcode  := 0;

  g_first_noa_code     := null;
  BEGIN
    FOR msl IN ghr_msl (p_mass_salary_id)
    LOOP
        p_mass_salary    := msl.name;
        l_effective_date := msl.effective_date;
        l_mass_salary_id := msl.mass_salary_id;
        l_user_table_id  := msl.user_table_id;
        l_submit_flag    := msl.submit_flag;
        l_executive_order_number := msl.executive_order_number;
        l_executive_order_date :=  msl.executive_order_date;
        l_opm_issuance_number  :=  msl.opm_issuance_number;
        l_opm_issuance_date    :=  msl.opm_issuance_date;
        l_pa_request_id  := msl.pa_request_id;
        l_rowid          := msl.rowid;
        l_p_ORGANIZATION_ID        := msl.ORGANIZATION_ID;
        l_p_DUTY_STATION_ID        := msl.DUTY_STATION_ID;
        l_p_PERSONNEL_OFFICE_ID    := msl.PERSONNEL_OFFICE_ID;
        l_p_AGENCY_CODE_SUBELEMENT := msl.AGENCY_CODE_SUBELEMENT;

		pr('Pa request id is '||to_char(l_pa_request_id));
       exit;
    END LOOP;
  EXCEPTION
    when REC_BUSY then
         hr_utility.set_location('Mass Salary is in use',1);
         l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
        -- raise error;
        hr_utility.set_message(8301, 'GHR_38477_LOCK_ON_MSL');
        hr_utility.raise_error;
--
    when others then
  hr_utility.set_location('Error in '||l_proc||' Sql err is '||sqlerrm(sqlcode),1);
--    raise_application_error(-20111,'Error while selecting from Ghr Mass Salaries');
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
  END;

  g_effective_date := l_effective_date;

  for c_pay_tab_essl_rec in c_pay_tab_essl loop
      l_essl_table := TRUE;
  exit;
  end loop;

-- Bug 3315432 Madhuri
--
  FOR pp_prd_per_gr IN cur_pp_prd_per_gr(p_mass_salary_id)
  LOOP
	rec_pp_prd_per_gr(l_index).pay_plan := pp_prd_per_gr.pay_plan;
	rec_pp_prd_per_gr(l_index).prd      := pp_prd_per_gr.prd;
	rec_pp_prd_per_gr(l_index).percent  := pp_prd_per_gr.percent;
	rec_pp_prd_per_gr(l_index).grade    := pp_prd_per_gr.grade;
	l_index := l_index +1;

  END LOOP;

  IF upper(p_action) = 'CREATE' then
     ghr_mto_int.set_log_program_name('GHR_MSL_PKG');
  ELSE
     ghr_mto_int.set_log_program_name('MSL_'||p_mass_salary);
  END IF;

--  Commented out by Edward Nunez. It's not needed anymore with 894 rules
--  IF upper(p_action) = 'CREATE' then
--    if l_pa_request_id is null then
--       hr_utility.set_message(8301, 'GHR_99999_SELECT_LAC_REMARKS');
--       hr_utility.raise_error;
--    END IF;
--  END IF;

  get_lac_dtls(l_pa_request_id,
               l_lac_sf52_rec);

  --purge_old_data(l_mass_salary_id);

  hr_utility.set_location('After fetch msl '||to_char(l_effective_date)
    ||' '||to_char(l_user_table_id),20);

IF l_p_ORGANIZATION_ID is not null then
    FOR per IN cur_people_org (l_effective_date,l_p_ORGANIZATION_ID)
    LOOP
        -- Bug#5719467 Initialised the variable l_mslerrbuf to avoid ora error 6502
        l_mslerrbuf := NULL;
        -- Bug#5063304 Added the following IF Condition.
        IF  NVL(l_p_organization_id,per.organization_id) = per.organization_id THEN
            FOR ast IN cur_ast (per.assignment_status_type_id)
            LOOP
                -- Set all local variables to NULL
                l_personnel_office_id  := NULL;
                l_org_structure_id     := NULL;
                l_position_title       := NULL;
                l_position_number      := NULL;
                l_position_seq_no      := NULL;
                l_sub_element_code     := NULL;
                l_duty_station_id      := NULL;
                l_tenure               := NULL;
                l_annuitant_indicator  := NULL;
                l_pay_rate_determinant := NULL;
                l_work_schedule        := NULL;
                l_part_time_hour       := NULL;
                l_pay_plan             := NULL;
                l_pay_table_id         := NULL;
                l_grade_or_level       := NULL;
                l_step_or_rate         := NULL;
                l_pay_basis            := NULL;
                l_increase_percent     := NULL;
                l_elig_flag            := FALSE;
                --
                BEGIN
                    fetch_and_validate_emp_perc(
                                    p_action                => p_action
                                   ,p_mass_salary_id        => p_mass_salary_id
                                   ,p_mass_salary_name      => p_mass_salary
                                   ,p_full_name             => per.full_name
                                   ,p_national_identifier   => per.national_identifier
                                   ,p_assignment_id         => per.assignment_id
                                   ,p_person_id             => per.person_id
                                   ,p_position_id           => per.position_id
                                   ,p_grade_id              => per.grade_id
                                   ,p_business_group_id     => per.business_group_id
                                   ,p_location_id           => per.location_id
                                   ,p_organization_id       => per.organization_id
                                   ,p_msl_organization_id    => l_p_organization_id
                                   ,p_msl_duty_station_id    => l_p_duty_station_id
                                   ,p_msl_personnel_office_id   => l_p_personnel_office_id
                                   ,p_msl_agency_code_subelement => l_p_agency_code_subelement
                                   ,p_msl_user_table_id         => l_user_table_id
                                   ,p_rec_pp_prd_per_gr         => rec_pp_prd_per_gr
                                   ,p_personnel_office_id   => l_personnel_office_id
                                   ,p_org_structure_id      => l_org_structure_id
                                   ,p_position_title        => l_position_title
                                   ,p_position_number       => l_position_number
                                   ,p_position_seq_no       => l_position_seq_no
                                   ,p_subelem_code          => l_sub_element_code
                                   ,p_duty_station_id       => l_duty_station_id
                                   ,p_tenure                => l_tenure
                                   ,p_annuitant_indicator   => l_annuitant_indicator
                                   ,p_pay_rate_determinant  => l_pay_rate_determinant
                                   ,p_work_schedule         => l_work_schedule
                                   ,p_part_time_hour        => l_part_time_hour
                                   ,p_pay_plan              => l_pay_plan
                                   ,p_pay_table_id          => l_pay_table_id
                                   ,p_grade_or_level        => l_grade_or_level
                                   ,p_step_or_rate          => l_step_or_rate
                                   ,p_pay_basis             => l_pay_basis
                                   ,p_increase_percent      => l_increase_percent
                                   ,p_elig_flag             => l_elig_flag
                                   );
                EXCEPTION
                    --WHEN fetch_validate_error THEN
                       --l_elig_flag := FALSE;
                    WHEN OTHERS THEN
                        l_elig_flag := FALSE;
                END;

                IF l_elig_flag THEN
                    msl_perc_process( p_assignment_id  => per.assignment_id
                              ,p_person_id => per.person_id
                              ,p_position_id  => per.position_id
                              ,p_grade_id => per.grade_id
                              ,p_business_group_id => per.business_group_id
                              ,p_location_id => per.location_id
                              ,p_organization_id => per.organization_id
                              ,p_date_of_birth => per.date_of_birth
                              ,p_first_name => per.first_name
                              ,p_last_name => per.last_name
                              ,p_full_name => per.full_name
                              ,p_middle_names => per.middle_names
                              ,p_national_identifier => per.national_identifier
                              ,p_personnel_office_id   => l_personnel_office_id
                              ,p_org_structure_id      => l_org_structure_id
                              ,p_position_title        => l_position_title
                              ,p_position_number       => l_position_number
                              ,p_position_seq_no       => l_position_seq_no
                              ,p_subelem_code          => l_sub_element_code
                              ,p_duty_station_id       => l_duty_station_id
                              ,p_tenure                => l_tenure
                              ,p_annuitant_indicator   => l_annuitant_indicator
                              ,p_pay_rate_determinant  => l_pay_rate_determinant
                              ,p_work_schedule         => l_work_schedule
                              ,p_part_time_hour        => l_part_time_hour
                              ,p_pay_plan              => l_pay_plan
                              ,p_pay_table_id          => l_pay_table_id
                              ,p_grade_or_level        => l_grade_or_level
                              ,p_step_or_rate          => l_step_or_rate
                              ,p_pay_basis             => l_pay_basis
                              ,p_increase_percent      => l_increase_percent
                              );

                   END IF;
               END LOOP;
           END IF;
       END LOOP;
   ELSE
    FOR per IN cur_people (l_effective_date)
    LOOP
        -- Bug#5719467 Initialised the variable l_mslerrbuf to avoid ora error 6502
        l_mslerrbuf := NULL;
        FOR ast IN cur_ast (per.assignment_status_type_id)
        LOOP
            --
            -- Set all local variables to NULL
            l_personnel_office_id  := NULL;
            l_org_structure_id     := NULL;
            l_position_title       := NULL;
            l_position_number      := NULL;
            l_position_seq_no      := NULL;
            l_sub_element_code     := NULL;
            l_duty_station_id      := NULL;
            l_tenure               := NULL;
            l_annuitant_indicator  := NULL;
            l_pay_rate_determinant := NULL;
            l_work_schedule        := NULL;
            l_part_time_hour       := NULL;
            l_pay_plan             := NULL;
            l_pay_table_id         := NULL;
            l_grade_or_level       := NULL;
            l_step_or_rate         := NULL;
            l_pay_basis            := NULL;
            l_increase_percent     := NULL;
            l_elig_flag            := FALSE;
            --
            BEGIN
                fetch_and_validate_emp_perc(
                                        p_action                => p_action
                                       ,p_mass_salary_id        => p_mass_salary_id
                                       ,p_mass_salary_name      => p_mass_salary
                                       ,p_full_name             => per.full_name
                                       ,p_national_identifier   => per.national_identifier
                                       ,p_assignment_id         => per.assignment_id
                                       ,p_person_id             => per.person_id
                                       ,p_position_id           => per.position_id
                                       ,p_grade_id              => per.grade_id
                                       ,p_business_group_id     => per.business_group_id
                                       ,p_location_id           => per.location_id
                                       ,p_organization_id       => per.organization_id
                                       ,p_msl_organization_id    => l_p_organization_id
                                       ,p_msl_duty_station_id    => l_p_duty_station_id
                                       ,p_msl_personnel_office_id   => l_p_personnel_office_id
                                       ,p_msl_agency_code_subelement => l_p_agency_code_subelement
                                       ,p_msl_user_table_id         => l_user_table_id
                                       ,p_rec_pp_prd_per_gr         => rec_pp_prd_per_gr
                                       ,p_personnel_office_id   => l_personnel_office_id
                                       ,p_org_structure_id      => l_org_structure_id
                                       ,p_position_title        => l_position_title
                                       ,p_position_number       => l_position_number
                                       ,p_position_seq_no       => l_position_seq_no
                                       ,p_subelem_code          => l_sub_element_code
                                       ,p_duty_station_id       => l_duty_station_id
                                       ,p_tenure                => l_tenure
                                       ,p_annuitant_indicator   => l_annuitant_indicator
                                       ,p_pay_rate_determinant  => l_pay_rate_determinant
                                       ,p_work_schedule         => l_work_schedule
                                       ,p_part_time_hour        => l_part_time_hour
                                       ,p_pay_plan              => l_pay_plan
                                       ,p_pay_table_id          => l_pay_table_id
                                       ,p_grade_or_level        => l_grade_or_level
                                       ,p_step_or_rate          => l_step_or_rate
                                       ,p_pay_basis             => l_pay_basis
                                       ,p_increase_percent      => l_increase_percent
                                       ,p_elig_flag             => l_elig_flag
                                       );
                    EXCEPTION
                        --WHEN fetch_validate_error THEN
                          --  l_elig_flag := FALSE;
                        WHEN OTHERS THEN
                            l_elig_flag := FALSE;
                    END;
                    IF l_elig_flag THEN

                        msl_perc_process(
                                       p_assignment_id  => per.assignment_id
                                      ,p_person_id => per.person_id
                                      ,p_position_id  => per.position_id
                                      ,p_grade_id => per.grade_id
                                      ,p_business_group_id => per.business_group_id
                                      ,p_location_id => per.location_id
                                      ,p_organization_id => per.organization_id
                                      ,p_date_of_birth => per.date_of_birth
                                      ,p_first_name => per.first_name
                                      ,p_last_name => per.last_name
                                      ,p_full_name => per.full_name
                                      ,p_middle_names => per.middle_names
                                      ,p_national_identifier => per.national_identifier
                                      ,p_personnel_office_id   => l_personnel_office_id
                                      ,p_org_structure_id      => l_org_structure_id
                                      ,p_position_title        => l_position_title
                                      ,p_position_number       => l_position_number
                                      ,p_position_seq_no       => l_position_seq_no
                                      ,p_subelem_code          => l_sub_element_code
                                      ,p_duty_station_id       => l_duty_station_id
                                      ,p_tenure                => l_tenure
                                      ,p_annuitant_indicator   => l_annuitant_indicator
                                      ,p_pay_rate_determinant  => l_pay_rate_determinant
                                      ,p_work_schedule         => l_work_schedule
                                      ,p_part_time_hour        => l_part_time_hour
                                      ,p_pay_plan              => l_pay_plan
                                      ,p_pay_table_id          => l_pay_table_id
                                      ,p_grade_or_level        => l_grade_or_level
                                      ,p_step_or_rate          => l_step_or_rate
                                      ,p_pay_basis             => l_pay_basis
                                      ,p_increase_percent      => l_increase_percent
                                      );
                    END IF;

        END LOOP;
    END LOOP;
  END IF;

  pr('After processing is over ',to_char(l_recs_failed));
/*
    if (l_recs_failed  < (l_msl_cnt  * (1/3))) then
*/
   if (l_recs_failed  = 0) then
     IF upper(p_action) = 'CREATE' THEN
       begin
          update ghr_mass_salaries
             set submit_flag = 'P'
           where rowid = l_rowid;
       EXCEPTION
         when others then
           HR_UTILITY.SET_LOCATION('Error in Update ghr_msl  Sql error '||sqlerrm(sqlcode),30);
           hr_utility.set_message(8301, 'GHR_38476_UPD_GHR_MSL_FAILURE');
           hr_utility.raise_error;
       END;
-----Bug 2849262. Updating extra info to null is already done by Update_sel_flg in the main loop.
-----             So it is not required to do in global if you see the procedure upd_ext_info_to_null
-----             Commenting the following line. Dated 14-OCT-2003.
-----
-----  upd_ext_info_to_null(l_effective_date);
     end if;
  ELSE
--if (l_recs_failed  <> 0) then
      p_errbuf   := 'Error in '||l_proc || ' Details in GHR_PROCESS_LOG';
      p_retcode  := 2;
      IF upper(p_action) = 'CREATE' THEN
         update ghr_mass_salaries
            set submit_flag = 'E'
          where rowid = l_rowid;
      END IF;
  end if;
pr('Before commiting.....');
COMMIT;
pr('After commiting.....',to_char(l_recs_failed));

EXCEPTION
    when others then
--    raise_application_error(-20121,'Error in execute_msl_perc Err is '||sqlerrm(sqlcode));
      HR_UTILITY.SET_LOCATION('Error (Others2) occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),30);
      BEGIN
        ROLLBACK TO execute_msl_perc_SP;
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;
      l_log_text  := 'Error in '||l_proc||
                     ' For Mass Salary Name : '||p_mass_salary||
                     ' Sql Err is '||sqlerrm(sqlcode);
      l_recs_failed := l_recs_failed + 1;
      hr_utility.set_location('before creating entry in log file',30);

      p_errbuf   := 'Error in '||l_proc || ' Details in GHR_PROCESS_LOG';
      p_retcode  := 2;
      IF upper(p_action) = 'CREATE' THEN
         update ghr_mass_salaries
            set submit_flag = 'E'
          where rowid = l_rowid;
          commit;
      END IF;

      begin
         ghr_mto_int.log_message(
                        p_procedure => g_proc,
                        p_message   => l_log_text);

      exception
          when others then
              hr_utility.set_message(8301, 'Create Error Log failed');
              hr_utility.raise_error;
      end;

END execute_msl_perc;
-- 3843306
-- END of MSL Percentage Changes
-- This is same as Execute_msl except for few modifications
--
PROCEDURE set_ses_msl_process(ses_flag varchar2)
IS
BEGIN
	ghr_msl_pkg.g_ses_msl_process := ses_flag;
END set_ses_msl_process;

-- Bug#5063304 Created this new procedure

--5470182 -- For SES Relative Rate Range
-- Bug#5063304 Created this new procedure
PROCEDURE fetch_and_validate_emp_ses(
                              p_action              IN VARCHAR2
                             ,p_mass_salary_id      IN NUMBER
                             ,p_mass_salary_name    IN VARCHAR2
                             ,p_full_name           IN per_people_f.full_name%TYPE
			     ,p_national_identifier IN per_people_f.national_identifier%TYPE
                             ,p_assignment_id       IN per_assignments_f.assignment_id%TYPE
			     ,p_person_id           IN per_assignments_f.person_id%TYPE
			     ,p_position_id                IN per_assignments_f.position_id%TYPE
			     ,p_grade_id                   IN per_assignments_f.grade_id%TYPE
			     ,p_business_group_id          IN per_assignments_f.business_group_iD%TYPE
			     ,p_location_id                IN per_assignments_f.location_id%TYPE
			     ,p_organization_id            IN per_assignments_f.organization_id%TYPE
                             ,p_msl_organization_id        IN per_assignments_f.organization_id%TYPE
                             ,p_msl_duty_station_id        IN ghr_duty_stations_f.duty_station_id%TYPE
                             ,p_msl_personnel_office_id    IN VARCHAR2
                             ,p_msl_agency_code_subelement IN VARCHAR2
                             ,p_msl_user_table_id          IN NUMBER
                             ,p_rec_pp_prd                 IN pp_prd
                             ,p_personnel_office_id        OUT NOCOPY VARCHAR2
                             ,p_org_structure_id           OUT NOCOPY VARCHAR2
                             ,p_position_title             OUT NOCOPY VARCHAR2
                             ,p_position_number            OUT NOCOPY VARCHAR2
                             ,p_position_seq_no            OUT NOCOPY VARCHAR2
                             ,p_subelem_code               OUT NOCOPY VARCHAR2
                             ,p_duty_station_id            OUT NOCOPY ghr_duty_stations_f.duty_station_id%TYPE
                             ,p_tenure                     OUT NOCOPY VARCHAR2
                             ,p_annuitant_indicator        OUT NOCOPY VARCHAR2
                             ,p_pay_rate_determinant       OUT NOCOPY VARCHAR2
                             ,p_work_schedule              OUT NOCOPY  VARCHAR2
                             ,p_part_time_hour             OUT NOCOPY VARCHAR2
                             ,p_to_grade_id                OUT NOCOPY per_assignments_f.grade_id%type
                             ,p_pay_plan                   OUT NOCOPY VARCHAR2
                             ,p_to_pay_plan                OUT NOCOPY VARCHAR2
                             ,p_pay_table_id               OUT NOCOPY NUMBER
                             ,p_grade_or_level         OUT NOCOPY VARCHAR2
                             ,p_to_grade_or_level   OUT NOCOPY VARCHAR2
                             ,p_step_or_rate        OUT NOCOPY VARCHAR2
                             ,p_pay_basis           OUT NOCOPY VARCHAR2
                             ,p_elig_flag           OUT NOCOPY BOOLEAN
			                ) IS



    CURSOR msl_dtl_cur (cur_pay_plan varchar2, cur_prd varchar2) IS
    SELECT count(*) cnt
      FROM ghr_mass_salary_criteria
     WHERE mass_salary_id = p_mass_salary_id
       AND pay_plan = cur_pay_plan
       AND pay_rate_determinant = cur_prd;

    l_row_cnt               NUMBER := 0;
    l_pos_grp1_rec          per_position_extra_info%rowtype;
    l_assignment_id         per_assignments_f.assignment_id%TYPE;
    l_person_id             per_assignments_f.person_id%TYPE;
    l_position_id           per_assignments_f.position_id%TYPE;
    l_grade_id              per_assignments_f.grade_id%TYPE;
    l_business_group_id     per_assignments_f.business_group_iD%TYPE;
    l_location_id           per_assignments_f.location_id%TYPE;
    l_organization_id       per_assignments_f.organization_id%TYPE;
    l_tenure               VARCHAR2(35);
    l_annuitant_indicator  VARCHAR2(35);
    l_pay_rate_determinant VARCHAR2(35);
    l_work_schedule        VARCHAR2(35);
    l_part_time_hour       VARCHAR2(35);
    l_pay_table_id         NUMBER;
    l_pay_plan             VARCHAR2(30);
    l_grade_or_level       VARCHAR2(30);
    -- Bug#5089732 Added current pay plan, grade_or_level
    l_to_grade_id          NUMBER;
    l_to_pay_plan          VARCHAR2(30);
    l_to_grade_or_level    VARCHAR2(30);
    -- Bug#5089732
    l_step_or_rate         VARCHAR2(30);
    l_pay_basis            VARCHAR2(30);
    l_duty_station_id      NUMBER;
    l_duty_station_desc    ghr_pa_requests.duty_station_desc%type;
    l_duty_station_code    ghr_pa_requests.duty_station_code%type;
    l_effective_date       DATE;
    l_personnel_office_id  VARCHAR2(300);
    l_org_structure_id     VARCHAR2(300);
    l_sub_element_code     VARCHAR2(300);
    l_position_title       VARCHAR2(300);
    l_position_number      VARCHAR2(20);
    l_position_seq_no      VARCHAR2(20);
    l_log_text             VARCHAR2(2000) := null;
    l_retained_grade_rec  ghr_pay_calc.retained_grade_rec_type;
    l_fetch_poid_data       BOOLEAN := FALSE;
    l_fetch_ds_data         BOOLEAN := FALSE;
    l_fetch_agency_data     BOOLEAN := FALSE;
    init_elig_flag          BOOLEAN := FALSE;
    l_prd_matched           BOOLEAN := FALSE;
    l_prd_pp_matched        BOOLEAN := FALSE;
    l_rat_matched           BOOLEAN := FALSE;


    --5470182
     l_special_info_type                    ghr_api.special_information_type;



    l_proc   varchar2(72) :=  g_package || '.fetch_and_validate_emp_ses';

BEGIN

    g_proc  := 'fetch_and_validate_emp_ses';
    hr_utility.set_location('Entering    ' || l_proc,5);

    -- Bug#5623035 Moved the local variable assigning to here.
    l_assignment_id     := p_assignment_id;
    l_position_id       := p_position_id;
    l_grade_id          := p_grade_id;
    l_business_group_id := p_business_group_iD;
    l_location_id       := p_location_id;
    l_effective_date    := g_effective_date;

    -- Verify whether this process is required or not.
    IF p_msl_organization_id IS NOT NULL  OR
       p_msl_duty_station_id IS NOT NULL  OR
       p_msl_personnel_office_id IS NOT NULL  OR
       p_msl_agency_code_subelement IS NOT NULL THEN
        -- get the values and verify whether the record meets the condition or not.
        -- If Yes, proceed further. Otherwise, skip the other checks for this record

        hr_utility.set_location('The location id is:'||l_location_id,12345);
        hr_utility.set_location('MSL Org ID:'||p_msl_organization_id,11111);
        hr_utility.set_location('Org ID:'||p_organization_id,22222);
        IF NVL(p_msl_organization_id,p_organization_id) = p_organization_id THEN
            hr_utility.set_location('Org ID PASS',10);
            IF p_msl_personnel_office_id IS NOT NULL THEN
                hr_utility.set_location('POID CHECK',15);
                get_pos_grp1_ddf(l_position_id,
                                 l_effective_date,
                                 l_pos_grp1_rec);

                l_personnel_office_id :=  l_pos_grp1_rec.poei_information3;
                l_org_structure_id    :=  l_pos_grp1_rec.poei_information5;
                l_fetch_poid_data := TRUE;
            END IF;
            IF  (p_msl_personnel_office_id = l_personnel_office_id) OR
                NOT(l_fetch_poid_data) THEN

	    hr_utility.set_location('POID PASS',20);
                IF p_msl_agency_code_subelement IS NOT NULL THEN
                    hr_utility.set_location('Agency CHECK',25);
                    get_sub_element_code_pos_title(l_position_id,
                                             p_person_id,
                                             l_business_group_id,
                                             l_assignment_id,
                                             l_effective_date,
                                             l_sub_element_code,
                                             l_position_title,
                                             l_position_number,
                                             l_position_seq_no);
                    l_fetch_agency_data := TRUE;
                END IF;
                -- Bug#5674003 Modified the following IF condition
                IF  (SUBSTR(p_msl_agency_code_subelement,1,2)  = SUBSTR(l_sub_element_code,1,2) AND
                     NVL(SUBSTR(p_msl_agency_code_subelement,3,2),SUBSTR(l_sub_element_code,3,2))=
                         SUBSTR(l_sub_element_code,3,2)
                    ) OR
                    NOT(l_fetch_agency_data) THEN
                                    hr_utility.set_location('Agency PASS',30);
                    IF p_msl_duty_station_id IS NOT NULL THEN
                        hr_utility.set_location('DS CHECK',35);
                        ghr_pa_requests_pkg.get_SF52_loc_ddf_details
                        (p_location_id      => l_location_id
                        ,p_duty_station_id  => l_duty_station_id);
                        l_fetch_ds_data := TRUE;
                    END IF;
                    IF (p_msl_duty_station_id = l_duty_station_id) OR
                       NOT(l_fetch_ds_data)THEN
                       hr_utility.set_location('DS PASS',40);
                        init_elig_flag := TRUE;
                    ELSE -- Duty Station not matching.
                       hr_utility.set_location('DS FAIL',45);
                        init_elig_flag := FALSE;
                    END IF;
                ELSE -- Agency Code Subelement Not matching.
                    hr_utility.set_location('Agency FAIL',55);
                    init_elig_flag := FALSE;
                END IF;
            ELSE -- Personnel Office ID not matching
                hr_utility.set_location('POID FAIL',65);
                init_elig_flag := FALSE;
            END IF;
        ELSE -- Organization_id is not matching.
            hr_utility.set_location('Org FAIL',75);
            init_elig_flag := FALSE;
        END IF;
    ELSE  -- If No value is entered for organization, Duty Station, Agency, POID of MSL Criteria.
       hr_utility.set_location('No INIT CRITERIA',85);
        init_elig_flag := TRUE;
    END IF;

    -- If the initial eligibility is passed then proceed further. Otherwise move to next record.
    IF init_elig_flag THEN
        hr_utility.set_location('Init Criteria Pass',95);
        ghr_pa_requests_pkg.get_sf52_asg_ddf_details
                                  (l_assignment_id,
                                   l_effective_date,
                                   l_tenure,
                                   l_annuitant_indicator,
                                   l_pay_rate_determinant,
                                   l_work_schedule,
                                   l_part_time_hour);

        FOR l_cnt in 1..p_rec_pp_prd.COUNT LOOP
           IF nvl(p_rec_pp_prd(l_cnt).prd,l_pay_rate_determinant) = l_pay_rate_determinant THEN
                hr_utility.set_location('PRD PASS',105);
                l_prd_matched := TRUE;
                exit;
           END IF;
        END LOOP;

        IF l_prd_matched THEN
            -- Bug#5089732 Used the overloaded procedure.
            BEGIN
                get_pay_plan_and_table_id
                      (l_pay_rate_determinant,p_person_id,
                       l_position_id,l_effective_date,
                       l_grade_id, l_to_grade_id,l_assignment_id,'SHOW',
                       l_pay_plan,l_to_pay_plan,l_pay_table_id,
                       l_grade_or_level, l_to_grade_or_level, l_step_or_rate,
                       l_pay_basis);
            -- Bug#4016384 Added the exception handling to report RG employees in the process log.
            EXCEPTION
                WHEN OTHERS THEN
                    -- Report the record in the process log if the pay table ID matches.
                    BEGIN
                        hr_utility.set_location('before calling expired_rg_det',10);
                        l_retained_grade_rec := ghr_pc_basic_pay.get_expired_rg_details
                                                  (p_person_id => p_person_id
                                                  ,p_effective_date => l_effective_date);
                        hr_utility.set_location('ret grd tableid:'||l_retained_grade_rec.user_table_id,99999);
                        hr_utility.set_location('MSL tableid:'||p_msl_user_table_id,99999);
                        IF l_retained_grade_rec.user_table_id = p_msl_user_table_id THEN
                            hr_utility.set_location('Rg table matches with MSL table ID',10);
                            l_log_text  := 'Error in RG Record In Mass Salary Name: '||
                                            p_mass_salary_name||'; Employee Name: '|| p_full_name ||
                                            '; SSN: ' || p_national_identifier || '; '||
                                            hr_utility.get_message;
                            BEGIN
                                ghr_mto_int.log_message(
                                      p_procedure => 'check_grade_retention',
                                      p_message   => l_log_text);
                                g_rg_recs_failed := g_rg_recs_failed + 1;
                            EXCEPTION
                                WHEN OTHERS THEN
                                   l_prd_pp_matched := FALSE;
                            END;
                        ELSE
                            l_prd_pp_matched := FALSE;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            hr_utility.set_location('WHEN OTHERS of EXPIRED RG ',999999);
                            l_prd_pp_matched := FALSE;
                    END;
                --WHEN OTHERS THEN
                    -- Skip this record from reporting.
                   -- l_prd_pp_matched := FALSE;
            END;
        END IF;

        FOR l_cnt in 1..p_rec_pp_prd.COUNT LOOP
           IF nvl(p_rec_pp_prd(l_cnt).prd,l_pay_rate_determinant) = l_pay_rate_determinant AND
              nvl(p_rec_pp_prd(l_cnt).pay_plan,l_pay_plan) = l_pay_plan THEN
                hr_utility.set_location('PP/PRD PASS',115);
                l_prd_pp_matched := TRUE;
                exit;
           END IF;
        END LOOP;


	--5470182
	IF l_prd_pp_matched AND l_pay_table_id = p_msl_user_table_id THEN
            ghr_history_fetch.return_special_information
                        (p_person_id         =>  p_person_id,
                         p_structure_name    =>  'US Fed Perf Appraisal',
                         p_effective_date    =>  l_effective_date,
                         p_special_info      =>  l_special_info_type
                        );

           -- BUG #6528698 Appraisal effective date need to be considered instead of Appraisal start date
             /* Rating of Record Level must be within 12 months*/
             IF l_effective_date between fnd_date.canonical_to_date(l_special_info_type.segment3)
	                        and     ADD_MONTHS(fnd_date.canonical_to_date(l_special_info_type.segment3),12) THEN
               /*Rating of Record Level must be '3','4' '5' or Rating of Record
	         must be 'E','F' or 'O'*/
              IF l_special_info_type.segment5 in ('3','4','5')
	         OR
                 l_special_info_type.segment2 in ('E','F','O') THEN
	         l_rat_matched :=TRUE;

   	      END IF; -- rating of recor level comp
             END IF; -- rating of record level with in 12 months
	    END IF;  -- prd and payplan matched and user table id matched
	    --5470182

        IF l_rat_matched THEN
            IF l_pay_table_id = p_msl_user_table_id THEN
                hr_utility.set_location('Table ID PASS',125);
                IF NOT (p_action = 'CREATE' AND
                            person_in_pa_req_1noa
                              (p_person_id      => p_person_id,
                               p_effective_date => l_effective_date,
                               p_first_noa_code => nvl(g_first_noa_code,'890'),
                               p_pay_plan       => p_pay_plan
                               )
                       )THEN
                     -- Pass l_pay_plan instead of l_to_pay_plan.
                     FOR msl_dtl IN msl_dtl_cur(l_pay_plan, l_pay_rate_determinant)
                     LOOP
                        IF msl_dtl.cnt <> 0 THEN
                        l_row_cnt := msl_dtl.cnt;
                        END IF;
                     END LOOP;

                    IF l_row_cnt <> 0 THEN
                        hr_utility.set_location('ROW COUNT PASS',135);
                        -- Get the required details if the related check has not been done above.
                        IF NOT l_fetch_poid_data THEN

                            get_pos_grp1_ddf(l_position_id,
                                             l_effective_date,
                                             l_pos_grp1_rec);
                        END IF;

                        IF NOT l_fetch_ds_data THEN
                            ghr_pa_requests_pkg.get_SF52_loc_ddf_details
                                        (p_location_id      => l_location_id
                                        ,p_duty_station_id  => l_duty_station_id);
                        END IF;

                        IF NOT l_fetch_agency_data THEN
                            get_sub_element_code_pos_title(
                                                         l_position_id,
                                                         p_person_id,
                                                         l_business_group_id,
                                                         l_assignment_id,
                                                         l_effective_date,
                                                         l_sub_element_code,
                                                         l_position_title,
                                                         l_position_number,
                                                         l_position_seq_no
                                                         );
                        END IF;

                        -- Set all the out parameters
                        p_elig_flag := TRUE;
                        p_personnel_office_id  := l_personnel_office_id;
                        p_org_structure_id     := l_org_structure_id;
                        p_position_title       := l_position_title;
                        p_position_number      := l_position_number;
                        p_position_seq_no      := l_position_seq_no;
                        p_subelem_code         := l_sub_element_code;
                        p_duty_station_id      := l_duty_station_id;
                        p_tenure               := l_tenure;
                        p_annuitant_indicator  := l_annuitant_indicator;
                        p_pay_rate_determinant := l_pay_rate_determinant;
                        p_work_schedule        := l_work_schedule;
                        p_part_time_hour       := l_part_time_hour;
                        p_to_grade_id          := l_to_grade_id;
                        p_pay_plan             := l_pay_plan;
                        p_to_pay_plan          := l_to_pay_plan;
                        p_pay_table_id         := l_pay_table_id;
                        p_grade_or_level       := l_grade_or_level;
                        p_to_grade_or_level    := l_to_grade_or_level;
                        p_step_or_rate         := l_step_or_rate;
                        p_pay_basis            := l_pay_basis;
                    ELSE -- If PP,PRD combinations are "0".
                        -- Raise Error
                        NULL;
                    END IF;
                ELSE -- Not (Create and RPA exists)
                    hr_utility.set_location('ROW COUNT FAIL',145);
                    p_elig_flag := FALSE;
                END IF;
            ELSE -- Pay table id is not matched
                hr_utility.set_location('Pay Table FAIL',155);
                p_elig_flag := FALSE;
            END IF;
        ELSE  -- Pay Plan and PRD not matched
            hr_utility.set_location('PP/PRD FAIL',165);
            p_elig_flag := FALSE;
        END IF;
    ELSE
        hr_utility.set_location('PP FAIL',175);
        p_elig_flag := FALSE;
    END IF;
EXCEPTION
    WHEN others THEN
        hr_utility.set_location('WHEN OTHERS',185);
        RAISE;
END fetch_and_validate_emp_ses;

PROCEDURE execute_msl_ses_range (p_errbuf out nocopy varchar2,
                                 p_retcode out nocopy number,
                                 p_mass_salary_id in number,
                                 p_action in varchar2) is

p_mass_salary varchar2(32);

--
--
-- Main Cursor which fetches from per_assignments_f and per_people_f
--
--
--1. Cursor with organization.
---
cursor cur_people_org (effective_date date, p_org_id number) is
select ppf.person_id                 PERSON_ID,
       ppf.first_name                FIRST_NAME,
       ppf.last_name                 LAST_NAME,
       ppf.middle_names              MIDDLE_NAMES,
       ppf.full_name                 FULL_NAME,
       ppf.date_of_birth             DATE_OF_BIRTH,
       ppf.national_identifier       NATIONAL_IDENTIFIER,
       paf.position_id               POSITION_ID,
       paf.assignment_id             ASSIGNMENT_ID,
       paf.grade_id                  GRADE_ID,
       paf.job_id                    JOB_ID,
       paf.location_id               LOCATION_ID,
       paf.organization_id           ORGANIZATION_ID,
       paf.business_group_id         BUSINESS_GROUP_ID,
       paf.assignment_status_type_id ASSIGNMENT_STATUS_TYPE_ID
  from per_assignments_f   paf,
       per_people_f        ppf,
       per_person_types    ppt
 where ppf.person_id           = paf.person_id
   and effective_date between ppf.effective_start_date and ppf.effective_end_date
   and effective_date between paf.effective_start_date and paf.effective_end_date
   and paf.primary_flag        = 'Y'
   and paf.assignment_type     <> 'B'
   and ppf.person_type_id      = ppt.person_type_id
   and ppt.system_person_type  IN ('EMP','EMP_APL')
   and paf.organization_id     = p_org_id
   and paf.position_id is not null
   order by ppf.person_id;

---
--- Bug  3539816 Order by added to prevent snapshot old error
--- 2. Cursor with no organization.
---
cursor cur_people (effective_date date) is
select ppf.person_id                 PERSON_ID,
       ppf.first_name                FIRST_NAME,
       ppf.last_name                 LAST_NAME,
       ppf.middle_names              MIDDLE_NAMES,
       ppf.full_name                 FULL_NAME,
       ppf.date_of_birth             DATE_OF_BIRTH,
       ppf.national_identifier       NATIONAL_IDENTIFIER,
       paf.position_id               POSITION_ID,
       paf.assignment_id             ASSIGNMENT_ID,
       paf.grade_id                  GRADE_ID,
       paf.job_id                    JOB_ID,
       paf.location_id               LOCATION_ID,
       paf.organization_id           ORGANIZATION_ID,
       paf.business_group_id         BUSINESS_GROUP_ID,
       paf.assignment_status_type_id ASSIGNMENT_STATUS_TYPE_ID
  from per_assignments_f   paf,
       per_people_f        ppf,
       per_person_types    ppt,
       hr_organization_units hou
 where ppf.person_id           = paf.person_id
   and effective_date between ppf.effective_start_date and ppf.effective_end_date
   and effective_date between paf.effective_start_date and paf.effective_end_date
   and paf.primary_flag        = 'Y'
   and paf.assignment_type     <> 'B'
   and ppf.person_type_id      = ppt.person_type_id
   and ppt.system_person_type  IN ('EMP','EMP_APL')
   and paf.organization_id     = hou.organization_id
   and paf.position_id is not null
   order by ppf.person_id;
--
-- Check assignment_status_type
--

cursor cur_ast (asg_status_type_id number)
    is
    select user_status
    from per_assignment_status_types
    where assignment_status_type_id = asg_status_type_id
  and upper(user_status) not in (
                         'TERMINATE ASSIGNMENT',           /* 3 */
                         'ACTIVE APPLICATION',             /* 4 */
                         'OFFER',                          /* 5 */
                         'ACCEPTED',                       /* 6 */
                         'TERMINATE APPLICATION',          /* 7 */
                         'END',                            /* 8 */
                         'TERMINATE APPOINTMENT',          /* 126 */
                         'SEPARATED');                     /* 132 */

--
-- Cursor to select from GHR_MASS_SALARIES - Where criteria is stored
-- Before executing this package
-- from ghr_mass_salary_criteria

cursor ghr_msl (p_msl_id number) is
select name, effective_date, mass_salary_id, user_table_id, submit_flag,
       executive_order_number, executive_order_date, ROWID, PA_REQUEST_ID,
       ORGANIZATION_ID, DUTY_STATION_ID, PERSONNEL_OFFICE_ID,
       AGENCY_CODE_SUBELEMENT, OPM_ISSUANCE_NUMBER, OPM_ISSUANCE_DATE, PROCESS_TYPE
  from ghr_mass_salaries
 where MASS_SALARY_ID = p_msl_id
   for update of user_table_id nowait;

-- VSM [family name was hardcoded previously to SALARY_CHG. Fetching it from DB now]
cursor get_sal_chg_fam is
select NOA_FAMILY_CODE
from ghr_families
where NOA_FAMILY_CODE in
    (select NOA_FAMILY_CODE from ghr_noa_families
         where  nature_of_action_id =
            (select nature_of_action_id
             from ghr_nature_of_actions
             where code = '890')
    ) and proc_method_flag = 'Y';    --AVR 13-JAN-99
 -------------   ) and update_hr_flag = 'Y';

l_assignment_id        per_assignments_f.assignment_id%type;
l_position_id          per_assignments_f.position_id%type;
l_grade_id             per_assignments_f.grade_id%type;
l_business_group_id    per_assignments_f.business_group_id%type;

l_position_title       varchar2(300);
l_position_number      varchar2(20);
l_position_seq_no      varchar2(20);

l_msl_cnt              number := 0;
l_recs_failed          number := 0;

l_tenure               varchar2(35);
l_annuitant_indicator  varchar2(35);
l_pay_rate_determinant varchar2(35);
l_work_schedule        varchar2(35);
l_part_time_hour       varchar2(35);
l_pay_table_id         number;
l_pay_plan             varchar2(30);
l_grade_or_level       varchar2(30);
l_step_or_rate         varchar2(30);
l_pay_basis            varchar2(30);
l_location_id          number;
l_duty_station_id      number;
l_duty_station_desc    ghr_pa_requests.duty_station_desc%type;
l_duty_station_code    ghr_pa_requests.duty_station_code%type;
l_effective_date       date;
l_personnel_office_id  varchar2(300);
l_org_structure_id     varchar2(300);
l_sub_element_code     varchar2(300);

l_old_basic_pay        number;
l_old_avail_pay        number;
l_old_loc_diff         number;
l_tot_old_sal          number;
l_old_auo_pay          number;
l_old_ADJ_basic_pay    number;
l_other_pay            number;

l_out_step_or_rate          varchar2(30);
l_out_pay_rate_determinant  varchar2(30);
l_out_pay_plan              varchar2(30);
l_out_grade_id              number;
l_out_grade_or_level        varchar2(30);


l_auo_premium_pay_indicator     varchar2(30);
l_ap_premium_pay_indicator      varchar2(30);
l_retention_allowance           number;
l_retention_allow_perc          number;     ---AVR
l_new_retention_allowance       number;     ---AVR
l_supervisory_differential      number;
l_supervisory_diff_perc         number;     ---AVR
l_new_supervisory_differential  number;     ---AVR
l_staffing_differential         number;

l_new_avail_pay             number;
l_new_loc_diff              number;
l_tot_new_sal               number;
l_new_auo_pay               number;

l_new_basic_pay             number;
l_new_locality_adj          number;
l_new_adj_basic_pay         number;
l_new_total_salary          number;
l_new_other_pay_amount      number;
l_new_au_overtime           number;
l_new_availability_pay      number;

l_open_pay_fields           boolean;
l_message_set               boolean;
l_calculated                boolean;

l_mass_salary_id            number;
l_user_table_id             number;
l_submit_flag               varchar2(2);

l_executive_order_number    ghr_mass_salaries.executive_order_number%TYPE;
l_executive_order_date      ghr_mass_salaries.executive_order_date%TYPE;
l_opm_issuance_number       ghr_mass_salaries.opm_issuance_number%TYPE;
l_opm_issuance_date         ghr_mass_salaries.opm_issuance_date%TYPE;
l_pa_request_id             number;
l_rowid                     varchar2(30);

l_p_ORGANIZATION_ID           number;
l_p_DUTY_STATION_ID           number;
l_p_PERSONNEL_OFFICE_ID       varchar2(5);

L_row_cnt                   number := 0;

l_sf52_rec                  ghr_pa_requests%rowtype;
l_lac_sf52_rec              ghr_pa_requests%rowtype;
l_errbuf                    varchar2(2000);

l_retcode                   number;

l_pos_ei_data               per_position_extra_info%rowtype;
l_pos_grp1_rec              per_position_extra_info%rowtype;

l_pay_calc_in_data          ghr_pay_calc.pay_calc_in_rec_type;
l_pay_calc_out_data         ghr_pay_calc.pay_calc_out_rec_type;
l_sel_flg                   varchar2(2);

l_first_action_la_code1     varchar2(30);
l_first_action_la_code2     varchar2(30);

l_remark_code1              varchar2(30);
l_remark_code2              varchar2(30);
l_p_AGENCY_CODE_SUBELEMENT       varchar2(30);

----Pay cap variables
l_entitled_other_pay        NUMBER;
l_capped_other_pay          NUMBER;
l_adj_basic_message         BOOLEAN  := FALSE;
l_pay_cap_message           BOOLEAN  := FALSE;
l_temp_retention_allowance  NUMBER;
l_open_pay_fields_caps      BOOLEAN;
l_message_set_caps          BOOLEAN;
l_total_pay_check           VARCHAR2(1);
l_comment                   VARCHAR2(150);
l_comment_sal               VARCHAR2(150);
l_pay_sel                   VARCHAR2(1) := NULL;
l_old_capped_other_pay     NUMBER;
----
l_row_low NUMBER;
l_row_high NUMBER;
l_comment_range VARCHAR2(150);
l_comments      VARCHAR2(150);

-- Bug#5089732 Added current pay plan, grade_or_level
l_to_grade_id          per_assignments_f.grade_id%type;
l_to_pay_plan          varchar2(30);
l_to_grade_or_level    varchar2(30);
-- Bug#5089732

REC_BUSY                    exception;
pragma exception_init(REC_BUSY,-54);

l_proc  varchar2(72) :=  g_package || '.execute_msl_ses_range';

cursor c_pay_tab_essl is
  select 1 from pay_user_tables
  where substr(user_table_name,1,4) = 'ESSL'
  and user_table_id = l_user_table_id;

l_essl_table  BOOLEAN := FALSE;
l_org_name	hr_organization_units.name%type;

CURSOR cur_pp_prd(p_msl_id ghr_mass_salary_criteria.mass_salary_id%type)
IS
SELECT pay_plan ,pay_rate_determinant prd
FROM   ghr_mass_salary_criteria
WHERE  mass_salary_id=p_msl_id;

rec_pp_prd   pp_prd;

l_index         NUMBER:=1;
l_cnt           NUMBER;
l_elig_flag        BOOLEAN := FALSE;
--

--
-- GPPA Update 46
--
cursor cur_eq_ppl (c_pay_plan ghr_pay_plans.pay_plan%type)
IS
select EQUIVALENT_PAY_PLAN
from ghr_pay_plans
where pay_plan = c_pay_plan;

l_eq_pay_plan ghr_pay_plans.equivalent_pay_plaN%type;
l_ses_basic_pay ghr_mass_actions_preview.to_basic_pay%type;


PROCEDURE msl_ses_process(p_assignment_id  per_assignments_f.assignment_id%TYPE
		     ,p_person_id per_assignments_f.person_id%TYPE
		     ,p_position_id  per_assignments_f.position_id%TYPE
		     ,p_grade_id per_assignments_f.grade_id%TYPE
		     ,p_business_group_id per_assignments_f.business_group_iD%TYPE
		     ,p_location_id per_assignments_f.location_id%TYPE
		     ,p_organization_id per_assignments_f.organization_id%TYPE
		     ,p_date_of_birth date
		     ,p_first_name per_people_f.first_name%TYPE
		     ,p_last_name per_people_f.last_name%TYPE
                     ,p_full_name per_people_f.full_name%TYPE
                             ,p_middle_names per_people_f.middle_names%TYPE
							 ,p_national_identifier per_people_f.national_identifier%TYPE
                             ,p_personnel_office_id IN VARCHAR2
                             ,p_org_structure_id    IN VARCHAR2
                             ,p_position_title      IN VARCHAR2
                             ,p_position_number     IN VARCHAR2
                             ,p_position_seq_no     IN VARCHAR2
                             ,p_subelem_code        IN VARCHAR2
                             ,p_duty_station_id     IN ghr_duty_stations_f.duty_station_id%TYPE
                             ,p_tenure              IN VARCHAR2
                             ,p_annuitant_indicator IN VARCHAR2
                             ,p_pay_rate_determinant IN VARCHAR2
                             ,p_work_schedule       IN  VARCHAR2
                             ,p_part_time_hour      IN VARCHAR2
                             ,p_to_grade_id         IN per_assignments_f.grade_id%type
                             ,p_pay_plan            IN VARCHAR2
                             ,p_to_pay_plan         IN VARCHAR2
                             ,p_pay_table_id        IN NUMBER
                             ,p_grade_or_level      IN VARCHAR2
                             ,p_to_grade_or_level   IN VARCHAR2
                             ,p_step_or_rate        IN VARCHAR2
                             ,p_pay_basis           IN VARCHAR2
							)	IS
        -- Bug3437354
        CURSOR cur_valid_DS(p_ds_id NUMBER)
            IS
            SELECT effective_end_date  end_date
            FROM   ghr_duty_stations_f
            WHERE  duty_station_id=p_ds_id
            AND    g_effective_date between effective_start_date and effective_end_date;

            l_ds_end_date	  ghr_duty_stations_f.effective_end_date%type;

BEGIN
      savepoint execute_msl_sp;
         l_msl_cnt := l_msl_cnt +1;
	 --Bug#3968005 Initialised l_sel_flg
         l_sel_flg := NULL;
         l_pay_calc_in_data  := NULL;
         l_pay_calc_out_data := NULL;

       l_assignment_id     := p_assignment_id;
       l_position_id       := p_position_id;
       l_grade_id          := p_grade_id;
       l_business_group_id := p_business_group_iD;
       l_location_id       := p_location_id;
       -- Bug#5063304
        l_personnel_office_id  := p_personnel_office_id;
        l_org_structure_id     := p_org_structure_id;
        l_position_title       := p_position_title;
        l_position_number      := p_position_number;
        l_position_seq_no      := p_position_seq_no;
        l_sub_element_code     := p_subelem_code;
        l_duty_station_id      := p_duty_station_id;
        l_tenure               := p_tenure;
        l_annuitant_indicator  := p_annuitant_indicator;
        l_pay_rate_determinant := p_pay_rate_determinant;
        l_work_schedule        := P_work_schedule;
        l_part_time_hour       := p_part_time_hour;
        l_to_grade_id          := p_to_grade_id;
        l_pay_plan             := p_pay_plan;
        l_to_pay_plan          := p_to_pay_plan;
        l_pay_table_id         := p_pay_table_id;
        l_grade_or_level       := p_grade_or_level;
        l_to_grade_or_level    := p_to_grade_or_level;
        l_step_or_rate         := P_step_or_rate;
        l_pay_basis            := p_pay_basis;
	    hr_utility.set_location('The location id is:'||l_location_id,1);
 /*5470182 need to be commented
--------GPPA Update 46 start
            ghr_msl_pkg.g_first_noa_code := NULL;
            FOR cur_eq_ppl_rec IN cur_eq_ppl(l_pay_plan)
            LOOP
                l_eq_pay_plan   := cur_eq_ppl_rec.EQUIVALENT_PAY_PLAN;
                exit;
            END LOOP;
            if l_effective_date >= to_date('2007/01/07','YYYY/MM/DD') AND
               l_eq_pay_plan = 'GS' AND
               l_lac_sf52_rec.first_action_la_code1 = 'QLP' AND
               l_lac_sf52_rec.first_action_la_code2 = 'ZLM' THEN

               ghr_msl_pkg.g_first_noa_code := '890';

            end if;
            if l_effective_date >= to_date('2007/01/07','YYYY/MM/DD') AND
               l_eq_pay_plan = 'FW' AND
               l_lac_sf52_rec.first_action_la_code1 = 'RJR' THEN

               ghr_msl_pkg.g_first_noa_code := '890';

            end if;
--------GPPA Update 46 end */

--5470182
       ghr_msl_pkg.g_first_noa_code := '890';
       l_lac_sf52_rec.first_action_la_code1 := 'Q3C';
--       l_lac_sf52_rec.first_action_la_desc1 := 'Reg. 534.404(h)';
       l_lac_sf52_rec.first_action_la_desc1 := ghr_pa_requests_pkg.get_lookup_description(800,'GHR_US_LEGAL_AUTHORITY','Q3C');

        g_proc := 'Location Validation';
        -- Start of Bug3437354
        IF l_location_id IS NULL THEN
            l_mslerrbuf := ' Error: No valid Location found, salary cannot be calculated correctly'||
                               ' without the employee''s duty location. ';
                RAISE msl_error;
        END IF;

        g_proc := 'Duty Station Validation';
        IF l_duty_station_id IS NOT NULL THEN

            --
            -- Added this condition for bug 3437354, error out the record without valid Loc id
            --
            FOR rec_ds in cur_valid_ds(l_duty_station_id)
            LOOP
                l_ds_end_date	:= rec_ds.end_Date;
            END LOOP;
            IF l_ds_end_date IS NULL THEN
                hr_utility.set_location('Under DS null check'||l_duty_station_id, 1);
                l_mslerrbuf := ' Error: Duty Station associated with the location is INVALID. '||
                               'Salary cannot be calculated correctly without valid duty station. ';
                RAISE msl_error;
            END IF;

        END IF;
        -- End of bug 3437354

       /*    -- BEGIN
              ghr_pa_requests_pkg.get_SF52_loc_ddf_details
                  (p_location_id      => l_location_id
                  ,p_duty_station_id  => l_duty_station_id);
           /  *exception
              when others then
                 hr_utility.set_location(
                 'Error in Ghr_pa_requests_pkg.get_sf52_loc_ddf_details'||
                       'Err is '||sqlerrm(sqlcode),20);
                 l_mslerrbuf := 'Error in get_sf52_loc_ddf_details '||
                       'Sql Err is '|| sqlerrm(sqlcode);
                 raise msl_error;
           end;*  /



       get_pos_grp1_ddf(l_position_id,
                        l_effective_date,
                        l_pos_grp1_rec);

       l_personnel_office_id :=  l_pos_grp1_rec.poei_information3;
       l_org_structure_id    :=  l_pos_grp1_rec.poei_information5;

       get_sub_element_code_pos_title(l_position_id,
                                     p_person_id,
                                     l_business_group_id,
                                     l_assignment_id,
                                     l_effective_date,
                                     l_sub_element_code,
                                     l_position_title,
                                     l_position_number,
                                     l_position_seq_no);

	hr_utility.set_location('The duty station id is:'||l_duty_station_id,12345);

       if check_init_eligibility(l_p_duty_station_id,
                              l_p_PERSONNEL_OFFICE_ID,
                              l_p_AGENCY_CODE_SUBELEMENT,
                              l_duty_station_id,
                              l_personnel_office_id,
                              l_sub_element_code) then

		   hr_utility.set_location('check_init_eligibility    ' || l_proc,6);
		-- Bug 3457205 Filter the Pay plan table id condition also b4 checking any other thing
		-- Moving check_eligibility to here.
			-- Get PRD, work schedule etc form ASG EI
			 begin
				ghr_pa_requests_pkg.get_sf52_asg_ddf_details
						  (l_assignment_id,
						   l_effective_date,
						   l_tenure,
						   l_annuitant_indicator,
						   l_pay_rate_determinant,
						   l_work_schedule,
						   l_part_time_hour);
			 exception
				when others then
					hr_utility.set_location('Error in Ghr_pa_requests_pkg.get_sf52_asg_ddf_details'||
							  'Err is '||sqlerrm(sqlcode),20);
					l_mslerrbuf := 'Error in get_sf52_asgddf_details Sql Err is '|| sqlerrm(sqlcode);
					raise msl_error;
			 end;

-- Bug 3315432 Madhuri
--
        FOR l_cnt in 1..rec_pp_prd.COUNT LOOP

---Bug 3327999 First filter the PRD. Then check for Pay plan and Pay table ID
		IF nvl(rec_pp_prd(l_cnt).prd,l_pay_rate_determinant) = l_pay_rate_determinant THEN
		-- Get Pay table ID and other details
           BEGIN
           -- Bug#5089732 Used the overloaded procedure.
                        get_pay_plan_and_table_id
                          (l_pay_rate_determinant,p_person_id,
                           l_position_id,l_effective_date,
                           l_grade_id, l_to_grade_id,l_assignment_id,'SHOW',
                           l_pay_plan,l_to_pay_plan,l_pay_table_id,
                           l_grade_or_level, l_to_grade_or_level, l_step_or_rate,
                           l_pay_basis);
           EXCEPTION
               when msl_error then
 		           l_mslerrbuf := hr_utility.get_message;
                   raise;
           END;

		IF ( nvl(rec_pp_prd(l_cnt).pay_plan,l_pay_plan) = l_pay_plan
			and l_user_table_id = nvl(l_pay_table_id,l_user_table_id) ) THEN

			IF check_eligibility(l_mass_salary_id,
                               l_user_table_id,
                               l_pay_table_id,
                               l_pay_plan,
                               l_pay_rate_determinant,
                               p_person_id,
                               l_effective_date,
                               p_action) THEN
                hr_utility.set_location('check_eligibility    ' || l_proc,8);   */
                -- Bug#5063304 Moved this call outside check_init_eligibility condition to
                --             this location.
                -- BUG 3377958 Madhuri
                -- Pick the organization name
                g_proc := 'Fetch Organization Name';
                l_org_name :=GHR_MRE_PKG.GET_ORGANIZATION_NAME(P_ORGANIZATION_ID);
		l_ses_basic_pay := NULL;
                -- BUG 3377958 Madhuri
			IF upper(p_action) = 'REPORT' AND l_submit_flag = 'P' THEN
		 	 -- BUG 3377958 Madhuri
 			    pop_dtls_from_pa_req(p_person_id,l_effective_date,l_mass_salary_id,l_org_name);
 		    	 -- BUG 3377958 Madhuri
			 ELSE
			   if check_select_flg_ses(p_person_id,upper(p_action),
									l_effective_date,p_mass_salary_id,l_sel_flg,l_ses_basic_pay) then

				   hr_utility.set_location('check_select_flg    ' || l_proc,7);
                   BEGIN
					hr_utility.set_location('The duty station name is:'||l_duty_station_code,12345);
					hr_utility.set_location('The duty station desc is:'||l_duty_station_desc,12345);
		            ghr_pa_requests_pkg.get_duty_station_details
                       (p_duty_station_id        => l_duty_station_id
                       ,p_effective_date        => l_effective_date
                       ,p_duty_station_code        => l_duty_station_code
                       ,p_duty_station_desc        => l_duty_station_desc);
                  EXCEPTION
                     WHEN others THEN
                        hr_utility.set_location('Error in Ghr_pa_requests_pkg.get_duty_station_details'||
                               'Err is '||sqlerrm(sqlcode),20);
                        l_mslerrbuf := 'Error in get_duty_station_details Sql Err is '|| sqlerrm(sqlcode);
                        RAISE msl_error;

                  END;

                     get_other_dtls_for_rep(l_pay_rate_determinant,
                                     l_executive_order_number,
                                     to_char(l_executive_order_date),
                                     l_first_action_la_code1,
                                     l_first_action_la_code2,
                                     l_remark_code1,
                                     l_remark_code2);

                     get_from_sf52_data_elements
                            (l_assignment_id,  l_effective_date,
                             l_old_basic_pay, l_old_avail_pay,
                             l_old_loc_diff, l_tot_old_sal,
                             l_old_auo_pay, l_old_adj_basic_pay,
                             l_other_pay, l_auo_premium_pay_indicator,
                             l_ap_premium_pay_indicator,
                             l_retention_allowance,
                             l_retention_allow_perc,
                             l_supervisory_differential,
                             l_supervisory_diff_perc,
                             l_staffing_differential);

                  l_pay_calc_in_data.person_id          := p_person_id;
                  l_pay_calc_in_data.position_id              := l_position_id;
                  --l_pay_calc_in_data.noa_family_code          := 'SALARY_CHG';
                  l_pay_calc_in_data.noa_family_code          := 'GHR_SAL_PAY_ADJ';
                  l_pay_calc_in_data.noa_code                 := nvl(g_first_noa_code,'890');
                  l_pay_calc_in_data.second_noa_code          := null;
                  l_pay_calc_in_data.first_action_la_code1    := l_lac_sf52_rec.first_action_la_code1;
                  l_pay_calc_in_data.effective_date           := l_effective_date;
                  l_pay_calc_in_data.pay_rate_determinant     := l_pay_rate_determinant;
                  l_pay_calc_in_data.pay_plan                 := l_pay_plan;
                  l_pay_calc_in_data.grade_or_level           := l_grade_or_level;
                  l_pay_calc_in_data.step_or_rate             := l_step_or_rate;
                  l_pay_calc_in_data.pay_basis                := l_pay_basis;
                  l_pay_calc_in_data.user_table_id            := l_pay_table_id;
                  l_pay_calc_in_data.duty_station_id          := l_duty_station_id;
                  l_pay_calc_in_data.auo_premium_pay_indicator := l_auo_premium_pay_indicator;
                  l_pay_calc_in_data.ap_premium_pay_indicator  := l_ap_premium_pay_indicator;
                  l_pay_calc_in_data.retention_allowance       := l_retention_allowance;
                  l_pay_calc_in_data.to_ret_allow_percentage   := l_retention_allow_perc;
                  l_pay_calc_in_data.supervisory_differential  := l_supervisory_differential;
                  l_pay_calc_in_data.staffing_differential    := l_staffing_differential;
                  l_pay_calc_in_data.current_basic_pay        := l_old_basic_pay;
                  l_pay_calc_in_data.current_adj_basic_pay    := l_old_adj_basic_pay;
                  l_pay_calc_in_data.current_step_or_rate     := l_step_or_rate;
                  l_pay_calc_in_data.pa_request_id            := null;

		  l_pay_calc_in_data.open_range_out_basic_pay := l_ses_basic_pay;

                  ghr_msl_pkg.g_ses_msl_process              := 'N';

                 IF l_pay_plan in ('ES','EP','IE','FE') and l_essl_table THEN
                     ghr_msl_pkg.g_ses_msl_process           := 'Y';
                     l_step_or_rate                          := '00';
                  END IF;

                  BEGIN
                      ghr_pay_calc.sql_main_pay_calc (l_pay_calc_in_data
                           ,l_pay_calc_out_data
                           ,l_message_set
                           ,l_calculated);

                        IF l_message_set THEN
                            hr_utility.set_location( l_proc, 40);
                            l_calculated     := FALSE;
                            l_mslerrbuf  := hr_utility.get_message;
                --			raise msl_error;
                        END IF;
                  EXCEPTION
                      when msl_error then
                           g_proc := 'ghr_pay_calc';
                          raise;
                      when others then
                    ----BUG 3287299 Start
                    IF ghr_pay_calc.gm_unadjusted_pay_flg = 'Y' then
                      l_comment := 'MSL:Error: Unadjusted Basic Pay must be entered in Employee record.';
                    ELSE
                      l_comment := 'MSL:Error: See process log for details.';
                    END IF;

                    IF upper(p_action) IN ('SHOW') THEN
                          -- Bug#2383392
                            create_mass_act_prev (
                            p_effective_date          => l_effective_date,
                            p_date_of_birth           => p_date_of_birth,
                            p_full_name               => p_full_name,
                            p_national_identifier     => p_national_identifier,
                            p_duty_station_code       => l_duty_station_code,
                            p_duty_station_desc       => l_duty_station_desc,
                            p_personnel_office_id     => l_personnel_office_id,
                            p_basic_pay               => l_old_basic_pay,
                            p_new_basic_pay           => null,
                            --Bug#2383992 Added old_adj_basic_pay
                            p_adj_basic_pay           => l_old_adj_basic_pay,
                            p_new_adj_basic_pay       => null,
                            p_old_avail_pay           => l_old_avail_pay,
                            p_new_avail_pay           => null,
                            p_old_loc_diff            => l_old_loc_diff,
                            p_new_loc_diff            => null,
                            p_tot_old_sal             => l_tot_old_sal,
                            p_tot_new_sal             => null,
                            p_old_auo_pay             => l_old_auo_pay,
                            p_new_auo_pay             => null,
                            p_position_id             => l_position_id,
                            p_position_title          => l_position_title,
                            -- FWFA Changes Bug#4444609
                            p_position_number         => l_position_number,
                            p_position_seq_no         => l_position_seq_no,
                            -- FWFA Changes
                            p_org_structure_id        => l_org_structure_id,
                            p_agency_sub_element_code => l_sub_element_code,
                            p_person_id               => p_person_id,
                            p_mass_salary_id          => l_mass_salary_id,
                            p_sel_flg                 => l_sel_flg,
                            p_first_action_la_code1   => l_first_action_la_code1,
                            p_first_action_la_code2   => l_first_action_la_code2,
                            p_remark_code1            => l_remark_code1,
                            p_remark_code2            => l_remark_code2,
                            p_grade_or_level          => l_grade_or_level,
                            p_step_or_rate            => l_step_or_rate,
                            p_pay_plan                => l_pay_plan,
                            p_pay_rate_determinant    =>  null,
                            p_tenure                  => l_tenure,
                            p_action                  => p_action,
                            p_assignment_id           => l_assignment_id,
                            p_old_other_pay           => l_other_pay,
                            p_new_other_pay           => null,
                            -- Bug#2383992
                            p_old_capped_other_pay    => NULL,
                            p_new_capped_other_pay    => NULL,
                            p_old_retention_allowance => l_retention_allowance,
                            p_new_retention_allowance => NULL,
                            p_old_supervisory_differential => l_supervisory_differential,
                            p_new_supervisory_differential => NULL,
                            -- BUG 3377958 Madhuri
                            p_organization_name            => l_org_name,
                            -- BUG 3377958 Madhuri
                            -- Bug#2383992
                            -- FWFA changes Bug#4444609
                            p_input_pay_rate_determinant  => l_pay_rate_determinant,
                            p_from_pay_table_id         => l_user_table_id,
                            p_to_pay_table_id           =>  null
                            -- FWFA changes
                             );
                          END IF;
                          -- Bug#3968005 Replaced parameter l_pay_sel with l_sel_flg
                          ins_upd_per_ses_extra_info
                             (p_person_id,l_effective_date, l_sel_flg, l_comment,p_mass_salary_id);
                          l_comment := NULL;
                          ------  BUG 3287299 End
                          hr_utility.set_location('Error in Ghr_pay_calc.sql_main_pay_calc '||
                                    'Err is '||sqlerrm(sqlcode),20);
                        l_mslerrbuf := 'Error in ghr_pay_calc  Sql Err is '|| sqlerrm(sqlcode);
                        g_proc := 'ghr_pay_calc';
                        raise msl_error;
                  END;

        ghr_msl_pkg.g_ses_msl_process              := 'N';

        l_new_basic_pay        := l_pay_calc_out_data.basic_pay;
        l_new_locality_adj     := l_pay_calc_out_data.locality_adj;
        l_new_adj_basic_pay    := l_pay_calc_out_data.adj_basic_pay;
        l_new_au_overtime      := l_pay_calc_out_data.au_overtime;
        l_new_availability_pay := l_pay_calc_out_data.availability_pay;

        --Added by mani related to the bug 5919694
	l_out_pay_plan          := l_pay_calc_out_data.out_to_pay_plan;
	l_out_grade_id          := l_pay_calc_out_data.out_to_grade_id;
	l_out_grade_or_level    := l_pay_calc_out_data.out_to_grade_or_level;


        l_out_pay_rate_determinant := l_pay_calc_out_data.out_pay_rate_determinant;
        l_out_step_or_rate         := l_pay_calc_out_data.out_step_or_rate;
        l_new_retention_allowance :=  l_pay_calc_out_data.retention_allowance;
        l_new_supervisory_differential := l_supervisory_differential;
        l_new_other_pay_amount         := l_pay_calc_out_data.other_pay_amount;
        l_entitled_other_pay      := l_new_other_pay_amount;
        if l_new_other_pay_amount = 0 then
           l_new_other_pay_amount := null;
        end if;
        l_new_total_salary        := l_pay_calc_out_data.total_salary;

     hr_utility.set_location('retention_allowance = ' || to_char(l_retention_allowance),10);
     hr_utility.set_location('Supervisory Diff Amount = ' || to_char(l_supervisory_differential),10);


-------------Call Pay cap Procedure
     begin
      l_capped_other_pay := ghr_pa_requests_pkg2.get_cop( p_assignment_id  => l_assignment_id
                                                         ,p_effective_date => l_effective_date);
      l_old_capped_other_pay :=  l_capped_other_pay;
		-- Sundar Added the following if statement to improve performance
			if hr_utility.debug_enabled = true then
				  hr_utility.set_location('Before Pay Cap    ' || l_proc,21);
				  hr_utility.set_location('l_effective_date  ' || l_effective_date,21);
				  hr_utility.set_location('l_out_pay_rate_determinant  ' || l_out_pay_rate_determinant,21);
				  hr_utility.set_location('l_pay_plan  ' || l_pay_plan,21);
				  hr_utility.set_location('l_position_id  ' || to_char(l_position_id),21);
				  hr_utility.set_location('l_pay_basis  ' || l_pay_basis,21);
				  hr_utility.set_location('person_id  ' || to_char(p_person_id),21);
				  hr_utility.set_location('l_new_basic_pay  ' || to_char(l_new_basic_pay),21);
				  hr_utility.set_location('l_new_locality_adj  ' || to_char(l_new_locality_adj),21);
				  hr_utility.set_location('l_new_adj_basic_pay  ' || to_char(l_new_adj_basic_pay),21);
				  hr_utility.set_location('l_new_total_salary  ' || to_char(l_new_total_salary),21);
				  hr_utility.set_location('l_entitled_other_pay  ' || to_char(l_entitled_other_pay),21);
				  hr_utility.set_location('l_capped_other_pay  ' || to_char(l_capped_other_pay),21);
				  hr_utility.set_location('l_new_retention_allowance  ' || to_char(l_new_retention_allowance),21);
				  hr_utility.set_location('l_new_supervisory_differential  ' || to_char(l_new_supervisory_differential),21);
				  hr_utility.set_location('l_staffing_differential  ' || to_char(l_staffing_differential),21);
				  hr_utility.set_location('l_new_au_overtime  ' || to_char(l_new_au_overtime),21);
				  hr_utility.set_location('l_new_availability_pay  ' || to_char(l_new_availability_pay),21);

			end if;


      ghr_pay_caps.do_pay_caps_main
                   (p_pa_request_id        =>    null
                   ,p_effective_date       =>    l_effective_date
                   ,p_pay_rate_determinant =>    nvl(l_out_pay_rate_determinant,l_pay_rate_determinant)
                   ,p_pay_plan             =>    nvl(l_out_pay_plan,l_pay_plan)
                   ,p_to_position_id       =>    l_position_id
                   ,p_pay_basis            =>    l_pay_basis
                   ,p_person_id            =>    p_person_id
                   ,p_noa_code             =>    nvl(g_first_noa_code,'894')
                   ,p_basic_pay            =>    l_new_basic_pay
                   ,p_locality_adj         =>    l_new_locality_adj
                   ,p_adj_basic_pay        =>    l_new_adj_basic_pay
                   ,p_total_salary         =>    l_new_total_salary
                   ,p_other_pay_amount     =>    l_entitled_other_pay
                   ,p_capped_other_pay     =>    l_capped_other_pay
                   ,p_retention_allowance  =>    l_new_retention_allowance
                   ,p_retention_allow_percentage => l_retention_allow_perc
                   ,p_supervisory_allowance =>   l_new_supervisory_differential
                   ,p_staffing_differential =>   l_staffing_differential
                   ,p_au_overtime          =>    l_new_au_overtime
                   ,p_availability_pay     =>    l_new_availability_pay
                   ,p_adj_basic_message    =>    l_adj_basic_message
                   ,p_pay_cap_message      =>    l_pay_cap_message
                   ,p_pay_cap_adj          =>    l_temp_retention_allowance
                   ,p_open_pay_fields      =>    l_open_pay_fields_caps
                   ,p_message_set          =>    l_message_set_caps
                   ,p_total_pay_check      =>    l_total_pay_check);


             l_new_other_pay_amount := nvl(l_capped_other_pay,l_entitled_other_pay);

			-- Sundar Added the following statement to improve performance
			if hr_utility.debug_enabled = true then
				  hr_utility.set_location('After Pay Cap    ' || l_proc,22);
				  hr_utility.set_location('l_effective_date  ' || l_effective_date,22);
				  hr_utility.set_location('l_out_pay_rate_determinant  ' || l_out_pay_rate_determinant,22);
				  hr_utility.set_location('l_pay_plan  ' || l_pay_plan,22);
				  hr_utility.set_location('l_position_id  ' || to_char(l_position_id),22);
				  hr_utility.set_location('l_pay_basis  ' || l_pay_basis,22);
				  hr_utility.set_location('person_id  ' || to_char(p_person_id),22);
				  hr_utility.set_location('l_new_basic_pay  ' || to_char(l_new_basic_pay),22);
				  hr_utility.set_location('l_new_locality_adj  ' || to_char(l_new_locality_adj),22);
				  hr_utility.set_location('l_new_adj_basic_pay  ' || to_char(l_new_adj_basic_pay),22);
				  hr_utility.set_location('l_new_total_salary  ' || to_char(l_new_total_salary),22);
				  hr_utility.set_location('l_entitled_other_pay  ' || to_char(l_entitled_other_pay),22);
				  hr_utility.set_location('l_capped_other_pay  ' || to_char(l_capped_other_pay),22);
				  hr_utility.set_location('l_new_retention_allowance  ' || to_char(l_new_retention_allowance),22);
				  hr_utility.set_location('l_new_supervisory_differential  ' || to_char(l_new_supervisory_differential),22);
				  hr_utility.set_location('l_staffing_differential  ' || to_char(l_staffing_differential),22);
				  hr_utility.set_location('l_new_au_overtime  ' || to_char(l_new_au_overtime),22);
				  hr_utility.set_location('l_new_availability_pay  ' || to_char(l_new_availability_pay),22);
			end if;

       IF l_pay_cap_message THEN
	 IF nvl(l_temp_retention_allowance,0) > 0 THEN
	    l_comment := 'MSL: Exceeded Total Cap - reduce Retention Allow to '
			|| to_char(l_temp_retention_allowance);
	  -- Bug#3968005 Replaced l_pay_sel with l_sel_flg
	     l_sel_flg := 'N';
	 ELSE
	     l_comment := 'MSL: Exceeded Total cap - pls review.';
	 END IF;
       ELSIF l_adj_basic_message THEN
          l_comment := 'MSL: Exceeded Adjusted Pay Cap - Locality reduced.';
       END IF;



       -- Bug 2639698 Sundar
	   IF (l_old_basic_pay > l_new_basic_pay) THEN
			l_comment_sal := 'MSL: From Basic Pay exceeds To Basic Pay.';
       END IF;
	   -- End Bug 2639698

       IF l_pay_cap_message or l_adj_basic_message THEN
			-- Bug 2639698
		  IF (l_comment_sal IS NOT NULL) THEN
		     l_comment := l_comment_sal || ' ' || l_comment;
		  END IF;
		  -- End Bug 2639698
	     -- Bug#3968005 Replaced parameter l_pay_sel with l_sel_flg
             ins_upd_per_extra_info
               (p_person_id,l_effective_date, l_sel_flg, l_comment,p_mass_salary_id);
          l_comment := NULL;
       --------------------Bug 2639698 Sundar To add comments
	   -- Should create comments only if comments need to be inserted
       ELSIF l_comment_sal IS NOT NULL THEN
            -- Bug#3968005 Replaced parameter l_pay_sel with l_sel_flg
	    ins_upd_per_extra_info
               (p_person_id,l_effective_date, l_sel_flg, l_comment_sal,p_mass_salary_id);
	   END IF;

       l_comment_sal := NULL; -- bug 2639698
     exception
          when msl_error then
               raise;
          when others then
	   IF ghr_msl_pkg.g_ses_bp_capped = TRUE and upper(p_action) IN ('SHOW') THEN
              l_comment := 'MSL: Exceeded Basic Pay Cap EX III';
    	      l_sel_flg := 'N';
	      ins_upd_per_extra_info
               (p_person_id,l_effective_date, l_sel_flg, l_comment,p_mass_salary_id);
	      l_comment := NULL;
           ELSE
               hr_utility.set_location('Error in ghr_pay_caps.do_pay_caps_main ' ||
                                'Err is '||sqlerrm(sqlcode),23);
                    l_mslerrbuf := 'Error in do_pay_caps_main  Sql Err is '|| sqlerrm(sqlcode);
                    raise msl_error;
           END IF;
     end;


                IF upper(p_action) IN ('SHOW','REPORT') THEN
                          -- Bug#2383392
                    create_mass_act_prev (
                        p_effective_date          => l_effective_date,
                        p_date_of_birth           => p_date_of_birth,
                        p_full_name               => p_full_name,
                        p_national_identifier     => p_national_identifier,
                        p_duty_station_code       => l_duty_station_code,
                        p_duty_station_desc       => l_duty_station_desc,
                        p_personnel_office_id     => l_personnel_office_id,
                        p_basic_pay               => l_old_basic_pay,
                        p_new_basic_pay           => l_new_basic_pay,
                        --Bug#2383992 Added old_adj_basic_pay
                        p_adj_basic_pay           => l_old_adj_basic_pay,
                        p_new_adj_basic_pay       => l_new_adj_basic_pay,
                        p_old_avail_pay           => l_old_avail_pay,
                        p_new_avail_pay           =>  l_new_availability_pay,
                        p_old_loc_diff            => l_old_loc_diff,
                        p_new_loc_diff            => l_new_locality_adj,
                        p_tot_old_sal             => l_tot_old_sal,
                        p_tot_new_sal             =>   l_new_total_salary,
                        p_old_auo_pay             => l_old_auo_pay,
                        p_new_auo_pay             =>   l_new_au_overtime,
                        p_position_id             => l_position_id,
                        p_position_title          => l_position_title,
                        -- FWFA Changes Bug#4444609
                        p_position_number         => l_position_number,
                        p_position_seq_no         => l_position_seq_no,
                        -- FWFA Changes
                        p_org_structure_id        => l_org_structure_id,
                        p_agency_sub_element_code => l_sub_element_code,
                        p_person_id               => p_person_id,
                        p_mass_salary_id          => l_mass_salary_id,
                        p_sel_flg                 => l_sel_flg,
                        p_first_action_la_code1   => l_first_action_la_code1,
                        p_first_action_la_code2   => l_first_action_la_code2,
                        p_remark_code1            => l_remark_code1,
                        p_remark_code2            => l_remark_code2,
                        p_grade_or_level          => NVL(l_out_grade_or_level,l_grade_or_level),
                        p_step_or_rate            => l_step_or_rate,
                        p_pay_plan                => NVL(l_out_pay_plan,l_pay_plan),
                        -- FWFA Changes Bug#4444609
                        p_pay_rate_determinant    => NVL(l_out_pay_rate_determinant,l_pay_rate_determinant),
                        -- FWFA Changes
                        p_tenure                  => l_tenure,
                        p_action                  => p_action,
                        p_assignment_id           => l_assignment_id,
                        p_old_other_pay           => l_other_pay,
                        p_new_other_pay           => l_new_other_pay_amount,
                        -- Bug#2383992
                        p_old_capped_other_pay    => l_old_capped_other_pay,--NULL,
                        p_new_capped_other_pay    => l_capped_other_pay,
                        p_old_retention_allowance => l_retention_allowance,
                        p_new_retention_allowance => l_new_retention_allowance,
                        p_old_supervisory_differential => l_supervisory_differential,
                        p_new_supervisory_differential => l_new_supervisory_differential,
                        -- BUG 3377958 Madhuri
                        p_organization_name            => l_org_name,
                        -- Bug#2383992
                        -- FWFA Changes Bug#4444609
                        p_input_pay_rate_determinant   => l_pay_rate_determinant,
                        p_from_pay_table_id            => l_pay_calc_out_data.pay_table_id,
                        p_to_pay_table_id              => l_pay_calc_out_data.calculation_pay_table_id
                        -- FWFA Changes
                         );
                ELSIF upper(p_action) = 'CREATE' then

                    BEGIN
                        -- Bug#5089732 Used the overloaded procedure.
                        get_pay_plan_and_table_id
                          (l_pay_rate_determinant,p_person_id,
                           l_position_id,l_effective_date,
                           l_grade_id, l_to_grade_id,l_assignment_id,'CREATE',
                           l_pay_plan,l_to_pay_plan,l_pay_table_id,
                           l_grade_or_level, l_to_grade_or_level, l_step_or_rate,
                           l_pay_basis);
                     EXCEPTION
                       when msl_error then
 		               l_mslerrbuf := hr_utility.get_message;
                       raise;
                     END;

                     assign_to_sf52_rec(
                       p_person_id,
                       p_first_name,
                       p_last_name,
                       p_middle_names,
                       p_national_identifier,
                       p_date_of_birth,
                       l_effective_date,
                       l_assignment_id,
                       l_tenure,
                       -- Bug#5089732
                       NVL(l_out_grade_id,l_to_grade_id),
                       NVL(l_out_pay_plan,l_to_pay_plan),
                       NVL(l_out_grade_or_level,l_to_grade_or_level),
                       -- Bug#5089732
                       l_step_or_rate,
                       l_annuitant_indicator,
                       -- FWFA Changes Bug#4444609
                       NVL(l_out_pay_rate_determinant,l_pay_rate_determinant),
                       -- FWFA Changes
                       l_work_schedule,
                       l_part_time_hour,
                       l_pos_ei_data.poei_information7, --FLSA Category
                       l_pos_ei_data.poei_information8, --Bargaining Unit Status
                       l_pos_ei_data.poei_information11,--Functional Class
                       l_pos_ei_data.poei_information16,--Supervisory Status,
                       l_new_basic_pay,
                       l_new_locality_adj,
                       l_new_adj_basic_pay,
                       l_new_total_salary,
                       l_other_pay,
                       l_new_other_pay_amount,
                       l_new_au_overtime,
                       l_new_availability_pay,
                       l_new_retention_allowance,
                       l_retention_allow_perc,
                       l_new_supervisory_differential,
                       l_supervisory_diff_perc,
                       l_staffing_differential,
                       l_duty_station_id,
                       l_duty_station_code,
                       l_duty_station_desc,
                       -- FWFA Changes  Bug#4444609
                       l_pay_rate_determinant,
                       l_pay_calc_out_data.pay_table_id,
                       l_pay_calc_out_data.calculation_pay_table_id,
                       -- FWFA Changes
                       l_lac_sf52_rec,
                       l_sf52_rec);

					  BEGIN
						   ghr_mass_actions_pkg.pay_calc_rec_to_sf52_rec
							   (l_pay_calc_out_data,
								l_sf52_rec);
					  EXCEPTION
						  when others then
							  hr_utility.set_location('Error in Ghr_mass_actions_pkg.pay_calc_rec_to_sf52_rec '||
										'Err is '||sqlerrm(sqlcode),20);
							 l_mslerrbuf := 'Error in ghr_mass_act_pkg.pay_calc_to_sf52  Sql Err is '|| sqlerrm(sqlcode);
							 raise msl_error;
					  END;

                   BEGIN
		               l_sf52_rec.mass_action_id := p_mass_salary_id;
                       l_sf52_rec.rpa_type := 'MRR';
                       g_proc  := 'Create_sf52_recrod';
                       ghr_mass_changes.create_sf52_for_mass_changes
                           (p_mass_action_type => 'MASS_SALARY_CHG',
                            p_pa_request_rec  => l_sf52_rec,
                            p_errbuf           => l_errbuf,
                            p_retcode          => l_retcode);

                       ------ Added by Dinkar for List reports problem
                       ---------------------------------------
                       IF l_errbuf IS NULL THEN

					       DECLARE
					           l_pa_request_number ghr_pa_requests.request_number%TYPE;
						   BEGIN
              			       l_pa_request_number   :=
								     l_sf52_rec.request_number||'-'||p_mass_salary_id;

						       ghr_par_upd.upd
                                      (p_pa_request_id             => l_sf52_rec.pa_request_id,
                                       p_object_version_number     => l_sf52_rec.object_version_number,
                                       p_request_number            => l_pa_request_number
                                      );
						   END;

                           pr('No error in create sf52 ');

                           ghr_mto_int.log_message(
                              p_procedure => 'Successful Completion',
                              p_message   => 'Name: '||p_full_name ||
                              ' SSN: '|| p_national_identifier||
                              '  Mass Salary : '||
                              p_mass_salary ||' SF52 Successfully completed');

                           create_lac_remarks(l_pa_request_id,
                                           l_sf52_rec.pa_request_id);

   --5470182
/*                          -- Added by Enunez 11-SEP-1999
                           IF l_lac_sf52_rec.first_action_la_code1 IS NULL THEN
                               -- Added by Edward Nunez for 894 rules
                               g_proc := 'Apply_894_Rules';
                               --Bug 2012782 fix
                               IF l_out_pay_rate_determinant IS NULL THEN
                                   l_out_pay_rate_determinant := l_pay_rate_determinant;
                               END IF;
                               --Bug 2012782 fix end
                               ghr_lacs_remarks.Apply_894_Rules(
                                       l_sf52_rec.pa_request_id,
                                       l_out_pay_rate_determinant,
                                       l_pay_rate_determinant,
                                       l_out_step_or_rate,
                                       l_executive_order_number,
                                       l_executive_order_date,
                                       l_opm_issuance_number,
                                       l_opm_issuance_date,
                                       l_errbuf,
                                       l_retcode
                                       );
                               IF l_errbuf IS NOT NULL THEN
                                   IF sqlcode = 0000 THEN
                                   l_mslerrbuf := l_mslerrbuf || '; ' || l_errbuf;
                                   ELSE
                                   l_mslerrbuf := l_mslerrbuf || ' ' || l_errbuf || ' Sql Err is: '
                                                                  || sqlerrm(sqlcode);
                                   END IF;
                                   RAISE msl_error;
                               END IF;
                           END IF; -- IF l_lac_sf52_rec.first_action_la_code1*/
                           g_proc := 'update_SEL_FLG';

                           update_SEL_FLG(p_PERSON_ID,l_effective_date);

                           COMMIT;
                       ELSE
                           pr('Error in create sf52',l_errbuf);
                           l_recs_failed := l_recs_failed + 1;
                           -- Raising MSL_ERROR is not required as the process log
                           -- was updated in ghr_mass_changes.create_sf52_for_mass_changes pkg itself.
                           --raise msl_error;
                       END IF; -- if l_errbuf is null then
                   EXCEPTION
                      WHEN msl_error then raise;
                      WHEN others then  null;
                      l_mslerrbuf := 'Error in ghr_mass_chg.create_sf52 '||
                                   ' Sql Err is '|| sqlerrm(sqlcode);
                      RAISE msl_error;
                   END;
               END IF; --  IF upper(p_action) IN ('SHOW','REPORT') THEN
            END IF; -- end if for check_select_flg
         END IF; -- end if for p_action = 'REPORT'


         L_row_cnt := L_row_cnt + 1;
         IF upper(p_action) <> 'CREATE' THEN
             IF L_row_cnt > 50 then
                 COMMIT;
                 L_row_cnt := 0;
             END IF;
         END IF;
      EXCEPTION
         WHEN MSL_ERROR THEN
               HR_UTILITY.SET_LOCATION('Error occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),10);
               begin
                ------  BUG 3287299 -- Not to rollback for preview.
       	        if upper(p_action) <> 'SHOW' then
                  ROLLBACK TO EXECUTE_MSL_SP;
                end if;
               EXCEPTION
                  WHEN OTHERS THEN NULL;
               END;
               l_log_text  := 'Error in '||l_proc||' '||
                              ' For Mass Salary Name : '||p_mass_salary||
                              'Name: '|| p_full_name || ' SSN: ' || p_national_identifier ||
                              l_mslerrbuf;
               hr_utility.set_location('before creating entry in log file',10);
               l_recs_failed := l_recs_failed + 1;
            begin
               ghr_mto_int.log_message(
                              p_procedure => g_proc,
                              p_message   => l_log_text);
            exception
                when others then
                    hr_utility.set_message(8301, 'GHR_38475_ERROR_LOG_FAILURE');
                    hr_utility.raise_error;
            end;
         when others then
               HR_UTILITY.SET_LOCATION('Error (Others) occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),20);
               BEGIN
                 ROLLBACK TO EXECUTE_MSL_SP;
               EXCEPTION
                 WHEN OTHERS THEN NULL;
               END;
               l_log_text  := 'Error (others) in '||l_proc||
                              ' For Mass Salary Name : '||p_mass_salary||
                              'Name: '|| p_full_name || ' SSN: ' || p_national_identifier ||
                              ' Sql Err is '||sqlerrm(sqlcode);
               hr_utility.set_location('before creating entry in log file',20);
               l_recs_failed := l_recs_failed + 1;
            begin
               ghr_mto_int.log_message(
                              p_procedure => g_proc,
                              p_message   => l_log_text);
            exception
                when others then
                    hr_utility.set_message(8301, 'Create Error Log failed');
                    hr_utility.raise_error;
            end;
      END msl_ses_process;

BEGIN

  g_proc  := 'execute_msl_ses_range';
  hr_utility.set_location('Entering    ' || l_proc,5);
  p_retcode  := 0;

  g_first_noa_code     := null;
  BEGIN
    FOR msl IN ghr_msl (p_mass_salary_id)
    LOOP
        p_mass_salary    := msl.name;
        l_effective_date := msl.effective_date;
        l_mass_salary_id := msl.mass_salary_id;
        l_user_table_id  := msl.user_table_id;
        l_submit_flag    := msl.submit_flag;


        l_executive_order_number := msl.executive_order_number;
        l_executive_order_date :=  msl.executive_order_date;

        l_opm_issuance_number  :=  msl.opm_issuance_number;
        l_opm_issuance_date    :=  msl.opm_issuance_date;
        l_pa_request_id  := msl.pa_request_id;
        l_rowid          := msl.rowid;
        l_p_ORGANIZATION_ID        := msl.ORGANIZATION_ID;
        l_p_DUTY_STATION_ID        := msl.DUTY_STATION_ID;
        l_p_PERSONNEL_OFFICE_ID    := msl.PERSONNEL_OFFICE_ID;
        l_p_AGENCY_CODE_SUBELEMENT := msl.AGENCY_CODE_SUBELEMENT;

		pr('Pa request id is '||to_char(l_pa_request_id));
       exit;
    END LOOP;
  EXCEPTION
    when REC_BUSY then
         hr_utility.set_location('Mass Salary is in use',1);
         l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
        -- raise error;
        hr_utility.set_message(8301, 'GHR_38477_LOCK_ON_MSL');
        hr_utility.raise_error;
--
    when others then
      hr_utility.set_location('Error in '||l_proc||' Sql err is '||sqlerrm(sqlcode),1);
--    raise_application_error(-20111,'Error while selecting from Ghr Mass Salaries');
      l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
      raise msl_error;
  END;

  g_effective_date := l_effective_date;

  for c_pay_tab_essl_rec in c_pay_tab_essl loop
      l_essl_table := TRUE;
      exit;
  end loop;
--5470182

FOR pp_prd IN cur_pp_prd(p_mass_salary_id)
  LOOP
	rec_pp_prd(l_index).pay_plan := pp_prd.pay_plan;
	rec_pp_prd(l_index).prd      := pp_prd.prd;
	l_index := l_index +1;
  END LOOP;


/*-- Bug 3315432 Madhuri
--
  FOR pp_prd_per_gr IN cur_pp_prd_per_gr(p_mass_salary_id)
  LOOP
	rec_pp_prd_per_gr(l_index).pay_plan := pp_prd_per_gr.pay_plan;
	rec_pp_prd_per_gr(l_index).prd      := pp_prd_per_gr.prd;
	rec_pp_prd_per_gr(l_index).percent  := pp_prd_per_gr.percent;
	rec_pp_prd_per_gr(l_index).grade    := pp_prd_per_gr.grade;
	l_index := l_index +1;

  END LOOP;*/

  IF upper(p_action) = 'CREATE' then
     ghr_mto_int.set_log_program_name('GHR_MSL_PKG');
  ELSE
     ghr_mto_int.set_log_program_name('MSL_'||p_mass_salary);
  END IF;

--  Commented out by Edward Nunez. It's not needed anymore with 894 rules
--  IF upper(p_action) = 'CREATE' then
--    if l_pa_request_id is null then
--       hr_utility.set_message(8301, 'GHR_99999_SELECT_LAC_REMARKS');
--       hr_utility.raise_error;
--    END IF;
--  END IF;

  get_lac_dtls(l_pa_request_id,
               l_lac_sf52_rec);

  --purge_old_data(l_mass_salary_id);

  hr_utility.set_location('After fetch msl '||to_char(l_effective_date)
    ||' '||to_char(l_user_table_id),20);

IF l_p_ORGANIZATION_ID is not null then
    FOR per IN cur_people_org (l_effective_date,l_p_ORGANIZATION_ID)
    LOOP
        -- Bug#5719467 Initialised the variable l_mslerrbuf to avoid ora error 6502
        l_mslerrbuf := NULL;
        -- Bug#5063304 Added the following IF Condition.
        IF  NVL(l_p_organization_id,per.organization_id) = per.organization_id THEN
            FOR ast IN cur_ast (per.assignment_status_type_id)
            LOOP
                -- Set all local variables to NULL
                 l_personnel_office_id  := NULL;
                 l_org_structure_id     := NULL;
                 l_position_title       := NULL;
                 l_position_number      := NULL;
                 l_position_seq_no      := NULL;
                 l_sub_element_code     := NULL;
                 l_duty_station_id      := NULL;
                 l_tenure               := NULL;
                 l_annuitant_indicator  := NULL;
                 l_pay_rate_determinant := NULL;
                 l_work_schedule        := NULL;
                 l_part_time_hour       := NULL;
                 l_to_grade_id          := NULL;
                 l_pay_plan             := NULL;
                 l_to_pay_plan          := NULL;
                 l_pay_table_id         := NULL;
                 l_grade_or_level       := NULL;
                 l_to_grade_or_level    := NULL;
                 l_step_or_rate         := NULL;
                 l_pay_basis            := NULL;
                 l_elig_flag            := FALSE;
                --
                BEGIN
                   fetch_and_validate_emp_ses(
                                p_action                => p_action
                               ,p_mass_salary_id        => p_mass_salary_id
                               ,p_mass_salary_name      => p_mass_salary
                               ,p_full_name             => per.full_name
                               ,p_national_identifier   => per.national_identifier
                               ,p_assignment_id         => per.assignment_id
                               ,p_person_id             => per.person_id
                               ,p_position_id           => per.position_id
                               ,p_grade_id              => per.grade_id
                               ,p_business_group_id     => per.business_group_id
                               ,p_location_id           => per.location_id
                               ,p_organization_id       => per.organization_id
                               ,p_msl_organization_id    => l_p_organization_id
                               ,p_msl_duty_station_id    => l_p_duty_station_id
                               ,p_msl_personnel_office_id   => l_p_personnel_office_id
                               ,p_msl_agency_code_subelement => l_p_agency_code_subelement
                               ,p_msl_user_table_id         => l_user_table_id
                               ,p_rec_pp_prd                => rec_pp_prd
                               ,p_personnel_office_id   => l_personnel_office_id
                               ,p_org_structure_id      => l_org_structure_id
                               ,p_position_title        => l_position_title
                               ,p_position_number       => l_position_number
                               ,p_position_seq_no       => l_position_seq_no
                               ,p_subelem_code          => l_sub_element_code
                               ,p_duty_station_id       => l_duty_station_id
                               ,p_tenure                => l_tenure
                               ,p_annuitant_indicator   => l_annuitant_indicator
                               ,p_pay_rate_determinant  => l_pay_rate_determinant
                               ,p_work_schedule         => l_work_schedule
                               ,p_part_time_hour        => l_part_time_hour
                               ,p_to_grade_id           => l_to_grade_id
                               ,p_pay_plan              => l_pay_plan
                               ,p_to_pay_plan           => l_to_pay_plan
                               ,p_pay_table_id          => l_pay_table_id
                               ,p_grade_or_level        => l_grade_or_level
                               ,p_to_grade_or_level     => l_to_grade_or_level
                               ,p_step_or_rate          => l_step_or_rate
                               ,p_pay_basis             => l_pay_basis
                               ,p_elig_flag             => l_elig_flag
                               );
                EXCEPTION
                    --WHEN fetch_validate_error THEN
                       --l_elig_flag := FALSE;
                    WHEN OTHERS THEN
                        l_elig_flag := FALSE;
                END;

                IF l_elig_flag THEN
		    msl_ses_process( p_assignment_id  => per.assignment_id
                                    ,p_person_id => per.person_id
                                    ,p_position_id  => per.position_id
                                    ,p_grade_id => per.grade_id
                                    ,p_business_group_id => per.business_group_id
                                    ,p_location_id => per.location_id
                                    ,p_organization_id => per.organization_id
                                    ,p_date_of_birth => per.date_of_birth
                                    ,p_first_name => per.first_name
                                    ,p_last_name => per.last_name
                                    ,p_full_name => per.full_name
                                    ,p_middle_names => per.middle_names
                                    ,p_national_identifier => per.national_identifier
                                    ,p_personnel_office_id   => l_personnel_office_id
                                    ,p_org_structure_id      => l_org_structure_id
                                    ,p_position_title        => l_position_title
                                    ,p_position_number       => l_position_number
                                    ,p_position_seq_no       => l_position_seq_no
                                    ,p_subelem_code          => l_sub_element_code
                                    ,p_duty_station_id       => l_duty_station_id
                                    ,p_tenure                => l_tenure
                                    ,p_annuitant_indicator   => l_annuitant_indicator
                                    ,p_pay_rate_determinant  => l_pay_rate_determinant
                                    ,p_work_schedule         => l_work_schedule
                                    ,p_part_time_hour        => l_part_time_hour
				    ,p_to_grade_id           => l_to_grade_id
                                    ,p_pay_plan              => l_pay_plan
                                    ,p_to_pay_plan           => l_to_pay_plan
                                    ,p_pay_table_id          => l_pay_table_id
                                    ,p_grade_or_level        => l_grade_or_level
                                    ,p_to_grade_or_level     => l_to_grade_or_level
                                    ,p_step_or_rate          => l_step_or_rate
                                    ,p_pay_basis             => l_pay_basis
                              );
                 END IF;
               END LOOP;
           END IF;
       END LOOP;
   ELSE
    FOR per IN cur_people (l_effective_date)
    LOOP
        -- Bug#5719467 Initialised the variable l_mslerrbuf to avoid ora error 6502
        l_mslerrbuf := NULL;
        FOR ast IN cur_ast (per.assignment_status_type_id)
        LOOP
            --
            -- Set all local variables to NULL
            l_personnel_office_id  := NULL;
            l_org_structure_id     := NULL;
            l_position_title       := NULL;
            l_position_number      := NULL;
            l_position_seq_no      := NULL;
            l_sub_element_code     := NULL;
            l_duty_station_id      := NULL;
            l_tenure               := NULL;
            l_annuitant_indicator  := NULL;
            l_pay_rate_determinant := NULL;
            l_work_schedule        := NULL;
            l_part_time_hour       := NULL;
            l_to_grade_id          := NULL;
            l_pay_plan             := NULL;
            l_to_pay_plan          := NULL;
            l_pay_table_id         := NULL;
            l_grade_or_level       := NULL;
            l_to_grade_or_level    := NULL;
            l_step_or_rate         := NULL;
            l_pay_basis            := NULL;
            l_elig_flag            := FALSE;
            --
            BEGIN
                fetch_and_validate_emp_ses(
                                        p_action                => p_action
                                       ,p_mass_salary_id        => p_mass_salary_id
                                       ,p_mass_salary_name      => p_mass_salary
                                       ,p_full_name             => per.full_name
                                       ,p_national_identifier   => per.national_identifier
                                       ,p_assignment_id         => per.assignment_id
                                       ,p_person_id             => per.person_id
                                       ,p_position_id           => per.position_id
                                       ,p_grade_id              => per.grade_id
                                       ,p_business_group_id     => per.business_group_id
                                       ,p_location_id           => per.location_id
                                       ,p_organization_id       => per.organization_id
                                       ,p_msl_organization_id    => l_p_organization_id
                                       ,p_msl_duty_station_id    => l_p_duty_station_id
                                       ,p_msl_personnel_office_id   => l_p_personnel_office_id
                                       ,p_msl_agency_code_subelement => l_p_agency_code_subelement
                                       ,p_msl_user_table_id         => l_user_table_id
                                       ,p_rec_pp_prd               => rec_pp_prd
                                       ,p_personnel_office_id   => l_personnel_office_id
                                       ,p_org_structure_id      => l_org_structure_id
                                       ,p_position_title        => l_position_title
                                       ,p_position_number       => l_position_number
                                       ,p_position_seq_no       => l_position_seq_no
                                       ,p_subelem_code          => l_sub_element_code
                                       ,p_duty_station_id       => l_duty_station_id
                                       ,p_tenure                => l_tenure
                                       ,p_annuitant_indicator   => l_annuitant_indicator
                                       ,p_pay_rate_determinant  => l_pay_rate_determinant
                                       ,p_work_schedule         => l_work_schedule
                                       ,p_part_time_hour        => l_part_time_hour
				       ,p_to_grade_id           => l_to_grade_id
                                       ,p_pay_plan              => l_pay_plan
                                       ,p_to_pay_plan           => l_to_pay_plan
                                       ,p_pay_table_id          => l_pay_table_id
                                       ,p_grade_or_level        => l_grade_or_level
                                       ,p_to_grade_or_level     => l_to_grade_or_level
                                       ,p_step_or_rate          => l_step_or_rate
                                       ,p_pay_basis             => l_pay_basis
                                       ,p_elig_flag             => l_elig_flag
                                        );
                    EXCEPTION
                        --WHEN fetch_validate_error THEN
                          --  l_elig_flag := FALSE;
                        WHEN OTHERS THEN
                            l_elig_flag := FALSE;
                    END;
                    IF l_elig_flag THEN
		       msl_ses_process(
                                       p_assignment_id  => per.assignment_id
                                      ,p_person_id => per.person_id
                                      ,p_position_id  => per.position_id
                                      ,p_grade_id => per.grade_id
                                      ,p_business_group_id => per.business_group_id
                                      ,p_location_id => per.location_id
                                      ,p_organization_id => per.organization_id
                                      ,p_date_of_birth => per.date_of_birth
                                      ,p_first_name => per.first_name
                                      ,p_last_name => per.last_name
                                      ,p_full_name => per.full_name
                                      ,p_middle_names => per.middle_names
                                      ,p_national_identifier => per.national_identifier
                                      ,p_personnel_office_id   => l_personnel_office_id
                                      ,p_org_structure_id      => l_org_structure_id
                                      ,p_position_title        => l_position_title
                                      ,p_position_number       => l_position_number
                                      ,p_position_seq_no       => l_position_seq_no
                                      ,p_subelem_code          => l_sub_element_code
                                      ,p_duty_station_id       => l_duty_station_id
                                      ,p_tenure                => l_tenure
                                      ,p_annuitant_indicator   => l_annuitant_indicator
                                      ,p_pay_rate_determinant  => l_pay_rate_determinant
                                      ,p_work_schedule         => l_work_schedule
                                      ,p_part_time_hour        => l_part_time_hour
                                      ,p_to_grade_id           => l_to_grade_id
                                      ,p_pay_plan              => l_pay_plan
                                      ,p_to_pay_plan           => l_to_pay_plan
                                      ,p_pay_table_id          => l_pay_table_id
                                      ,p_grade_or_level        => l_grade_or_level
                                      ,p_to_grade_or_level     => l_to_grade_or_level
                                      ,p_step_or_rate          => l_step_or_rate
                                      ,p_pay_basis             => l_pay_basis
                                      );
                    END IF;

        END LOOP;
    END LOOP;
  END IF;

  pr('After processing is over ',to_char(l_recs_failed));
/*
    if (l_recs_failed  < (l_msl_cnt  * (1/3))) then
*/
   if (l_recs_failed  = 0) then
     IF upper(p_action) = 'CREATE' THEN
       begin
          update ghr_mass_salaries
             set submit_flag = 'P'
           where rowid = l_rowid;
       EXCEPTION
         when others then
           HR_UTILITY.SET_LOCATION('Error in Update ghr_msl  Sql error '||sqlerrm(sqlcode),30);
           hr_utility.set_message(8301, 'GHR_38476_UPD_GHR_MSL_FAILURE');
           hr_utility.raise_error;
       END;
-----Bug 2849262. Updating extra info to null is already done by Update_sel_flg in the main loop.
-----             So it is not required to do in global if you see the procedure upd_ext_info_to_null
-----             Commenting the following line. Dated 14-OCT-2003.
-----
-----  upd_ext_info_to_null(l_effective_date);
     end if;
  ELSE
--if (l_recs_failed  <> 0) then
      p_errbuf   := 'Error in '||l_proc || ' Details in GHR_PROCESS_LOG';
      p_retcode  := 2;
      IF upper(p_action) = 'CREATE' THEN
         update ghr_mass_salaries
            set submit_flag = 'E'
          where rowid = l_rowid;
      END IF;
  end if;
pr('Before commiting.....');
COMMIT;
pr('After commiting.....',to_char(l_recs_failed));

EXCEPTION
    when others then
--    raise_application_error(-20121,'Error in execute_msl_ses Err is '||sqlerrm(sqlcode));
      HR_UTILITY.SET_LOCATION('Error (Others2) occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),30);
      BEGIN
        ROLLBACK TO execute_msl_ses_sp;
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;
      l_log_text  := 'Error in '||l_proc||
                     ' For Mass Salary Name : '||p_mass_salary||
                     ' Sql Err is '||sqlerrm(sqlcode);
      l_recs_failed := l_recs_failed + 1;
      hr_utility.set_location('before creating entry in log file',30);

      p_errbuf   := 'Error in '||l_proc || ' Details in GHR_PROCESS_LOG';
      p_retcode  := 2;
      IF upper(p_action) = 'CREATE' THEN
         update ghr_mass_salaries
            set submit_flag = 'E'
          where rowid = l_rowid;
          commit;
      END IF;

      begin
         ghr_mto_int.log_message(
                        p_procedure => g_proc,
                        p_message   => l_log_text);

      exception
          when others then
              hr_utility.set_message(8301, 'Create Error Log failed');
              hr_utility.raise_error;
      end;

END execute_msl_ses_range;


procedure ins_upd_per_ses_extra_info
               (p_person_id in number,
			    p_effective_date in date,
                p_sel_flag in varchar2,
				p_comment in varchar2,
				p_msl_id in number,
				p_ses_basic_pay in number default NULL) is

   l_person_extra_info_id number;
   l_object_version_number number;
   l_per_ei_data         per_people_extra_info%rowtype;

   CURSOR people_ext_cur (person number) is
   SELECT person_extra_info_id, object_version_number
     FROM PER_people_EXTRA_INFO
    WHERE person_ID = person
      and information_type = 'GHR_US_PER_MASS_ACTIONS';

    l_proc    varchar2(72) :=  g_package || '.ins_upd_per_ses_extra_info';
    l_eff_date date;

begin
  g_proc  := 'ins_upd_per_ses_extra_info';
  hr_utility.set_location('Entering    ' || l_proc,5);
  if p_effective_date > sysdate then
       l_eff_date := sysdate;
  else
       l_eff_date := p_effective_date;
  end if;

   ghr_history_fetch.fetch_peopleei
                  (p_person_id           => p_person_id
                  ,p_information_type      => 'GHR_US_PER_MASS_ACTIONS'
                  ,p_date_effective        => l_eff_date
                  ,p_per_ei_data           => l_per_ei_data);

   l_person_extra_info_id  := l_per_ei_data.person_extra_info_id;
   l_object_version_number := l_per_ei_data.object_version_number;

   if l_person_extra_info_id is null then
      for per_ext_rec in people_ext_cur(p_person_id)
      loop
         l_person_extra_info_id  := per_ext_rec.person_extra_info_id;
         l_object_version_number := per_ext_rec.object_version_number;
      end loop;
   end if;

   if l_person_extra_info_id is not null then
        ghr_person_extra_info_api.update_person_extra_info
                       (P_PERSON_EXTRA_INFO_ID   => l_person_extra_info_id
                       ,P_EFFECTIVE_DATE           => trunc(l_eff_date)
                       ,P_OBJECT_VERSION_NUMBER    => l_object_version_number
                       ,p_pei_INFORMATION3        => p_sel_flag
                       ,p_pei_INFORMATION4        => p_comment
                       ,p_pei_INFORMATION5        => to_char(p_msl_id)
		       ,p_pei_information10       => NULL
		       ,p_pei_information11       => to_char(p_ses_basic_pay)
                       ,P_PEI_INFORMATION_CATEGORY  => 'GHR_US_PER_MASS_ACTIONS');
   else
        ghr_person_extra_info_api.create_person_extra_info
                       (P_pERSON_ID               => p_PERSON_id
                       ,P_INFORMATION_TYPE        => 'GHR_US_PER_MASS_ACTIONS'
                       ,P_EFFECTIVE_DATE          => trunc(l_eff_date)
                       ,p_pei_INFORMATION3        => p_sel_flag
                       ,p_pei_INFORMATION4        => p_comment
                       ,p_pei_INFORMATION5        => to_char(p_msl_id)
		       ,p_pei_information10       =>NULL
		       ,p_pei_information11       => to_char(p_ses_basic_pay)
                       ,P_PEI_INFORMATION_CATEGORY  => 'GHR_US_PER_MASS_ACTIONS'
                       ,P_pERSON_EXTRA_INFO_ID  => l_pERSON_extra_info_id
                       ,P_OBJECT_VERSION_NUMBER   => l_object_version_number);
   end if;

---Commented the following two lines to remove Validation functionality on Person.
-- ghr_validate_perwsepi.validate_perwsepi(p_person_id);
-- ghr_validate_perwsepi.update_person_user_type(p_person_id);

   hr_utility.set_location('Exiting    ' || l_proc,10);
exception
  when msl_error then raise;
  when others then
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
end ins_upd_per_ses_extra_info;


function check_select_flg_ses(p_person_id in number,
                              p_action in varchar2,
                              p_effective_date in date,
                              p_mass_salary_id in number,
                              p_sel_flg in out nocopy varchar2,
			      p_ses_basic_pay in out nocopy number
			  )
return boolean IS

   l_per_ei_data        per_people_extra_info%rowtype;
   l_comments varchar2(250);
   l_sel_flag varchar2(3);
   l_line number := 0;
   l_proc     varchar2(72) :=  g_package || '.check_select_flg_ses';
   l_ses_basic_pay ghr_mass_actions_preview.to_basic_pay%type;
   l_temp_ses_basic_pay number;
   l_increase_percent number;
begin

  g_proc  := 'check_select_flg_ses';
  l_temp_ses_basic_pay := p_ses_basic_pay;

  hr_utility.set_location('Entering    ' || l_proc,5);

  get_extra_info_comments(p_person_id,p_effective_date,l_sel_flag,l_comments,p_mass_salary_id,l_increase_percent,l_ses_basic_pay); -- Added by Sundar 3843306

   -------- Initialize the comments
   -- Sundar 3337361 Included GM Error, To basic pay < From basic pay in the condition
   -- Now all the messages have MSL as a prefix. Rest of the conditions are alo
   -- included for the old records which may still have old message.
   IF l_comments is not null THEN
       --Bug#4093705 Added ltrim function to verify the System generated Comments as few comments
       --            might start with Blank Spaces. Removed NVL condition as control comes here
       --            only when l_comments has Non Null value.
       IF substr(ltrim(l_comments),1,8) = 'Exceeded'
		OR substr(ltrim(l_comments),1,3) = 'MSL'
		OR substr(ltrim(l_comments),1,5) = 'Error'
		OR substr(ltrim(l_comments),1,13) = 'The From Side'
	   THEN
          ins_upd_per_ses_extra_info
               (p_person_id,p_effective_date, l_sel_flag, null,p_mass_salary_id,l_ses_basic_pay);
       END IF;
     END IF;
   -- Bug 3843306 If Increase percent is entered from Preview screen, the same should be retrieved
   -- and not the one entered in Grade screen.

    IF l_ses_basic_pay IS NOT NULL THEN
		p_ses_basic_pay := l_ses_basic_pay;
    END IF;

     if l_sel_flag is null then
          p_sel_flg := 'Y';
     else
          p_sel_flg := l_sel_flag;
     end if;

	l_line := 15;
     if p_action IN ('SHOW','REPORT') THEN
         return TRUE;
     elsif p_action = 'CREATE' THEN
         if p_sel_flg = 'Y' THEN
            return TRUE;
         else
            return FALSE;
         end if;
     end if;
exception
  when msl_error then raise;
  when others then
     p_ses_basic_pay := l_temp_ses_basic_pay ;
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||' @'||to_char(l_line)||'  Sql Err is '|| sqlerrm(sqlcode);
     raise msl_error;
end check_select_flg_ses;


END GHR_MSL_PKG;

/

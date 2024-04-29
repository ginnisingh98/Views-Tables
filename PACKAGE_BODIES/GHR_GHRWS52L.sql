--------------------------------------------------------
--  DDL for Package Body GHR_GHRWS52L
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_GHRWS52L" AS
/* $Header: ghrws52l.pkb 120.13.12000000.3 2007/03/05 05:14:15 vmididho ship $ */




procedure GHRWS52L
(
  p_pa_request_rec 					in 	ghr_pa_requests%rowtype
 ,p_per_group1                		in 	ghr_api.per_group1_type
 ,p_per_retained_grade              in	ghr_api.per_retained_grade_type
 ,p_per_sep_retire                	in	ghr_api.per_sep_retire_type
 ,p_per_conversions					in 	ghr_api.per_conversions_type
 ,p_per_uniformed_services   		in	ghr_api.per_uniformed_services_type
 ,p_pos_grp1                    	in	ghr_api.pos_grp1_type
 ,p_pos_valid_grade                 in	ghr_api.pos_valid_grade_type
 ,p_loc_info                   		in	ghr_api.loc_info_type
 ,p_sf52_from_data                  in	ghr_api.prior_sf52_data_type
 ,p_personal_info					in	ghr_api.personal_info_type
 ,p_agency_code                     in  varchar2
 ,p_gov_awards_type                 in  ghr_api.government_awards_type
 ,p_perf_appraisal_type             in  ghr_api.performance_appraisal_type
 ,p_health_plan                     in  varchar2
 ,p_race_ethnic_info				in  ghr_api.per_race_ethnic_type	-- Bug 4724337 Race or National Origin changes
)
is
--
 l_proc varchar2(61) := 'GHR_GHRWS52L.GHRWS52';
 l_academic_discipline          		ghr_pa_requests.ACADEMIC_DISCIPLINE%Type;
 l_Adj_Base_Pay                 		ghr_pa_requests.TO_ADJ_BASIC_PAY%type;
 l_Agency_Code                   		varchar2(30);
 -- l_Agency                              varchar2(30);
 l_agency_subelement		 		varchar2(30);
 l_as_of_date                     		date;
 l_Benefit_Amount              		ghr_pa_request_extra_info.rei_information7%type;
 l_bargaining_unit_status_code   		ghr_pa_requests.BARGAINING_UNIT_STATUS%type;
 l_citizenship           			ghr_pa_requests.CITIZENSHIP%type;
 l_credit_mil_svc            			per_people_extra_info.pei_information5%type;
 l_Cur_Appt_Auth_1                    	per_people_extra_info.pei_information8%type;
 l_Cur_Appt_Auth_2                    	per_people_extra_info.pei_information9%type;
 l_Duty_Station_ID 				hr_location_extra_info.lei_information3%type;
 l_Duty_Station_Lookup_Code     		ghr_duty_stations_f.Duty_Station_Code%type;
 l_education_level              		ghr_pa_requests.EDUCATION_LEVEL%type;
 l_effective_date					ghr_pa_requests.EFFECTIVE_DATE%type;
 l_Employee_Date_of_Birth       		per_people_f.date_of_birth%type;
 l_Employee_First_Name          		ghr_pa_requests.EMPLOYEE_FIRST_NAME%type;
 l_Employee_Last_Name           		ghr_pa_requests.EMPLOYEE_LAST_NAME%type;
 l_employee_National_ID       		per_people_f.national_identifier%type;
 l_fegli_code      				ghr_pa_requests.FEGLI%type;
 l_fers_coverage            			per_people_extra_info.pei_information3%type;
 l_First_Action_NOA_LA_Code1       		ghr_pa_requests.FIRST_ACTION_LA_CODE1%type;
 l_First_Action_NOA_LA_Code2       		ghr_pa_requests.FIRST_ACTION_LA_CODE2%type;
 l_First_NOAC_Lookup_Code       		ghr_pa_requests.FIRST_NOA_CODE%type;
 -- Bug#4486823 RRR Changes
 l_First_NOAC_Lookup_Desc       		ghr_pa_requests.FIRST_NOA_DESC%type;
 l_flsa_category                		ghr_pa_requests.FLSA_CATEGORY%type;
 l_functional_class    				ghr_pa_requests.FUNCTIONAL_CLASS%type;
 l_health_plan	 	        		varchar2(30);
 l_Handicap                     		per_people_extra_info.pei_information11%type;
 l_Indiv_Award            			ghr_pa_request_extra_info.rei_information6%type;
 --l_locality_pay_area				hr_location_extra_info.lei_information4%type;
 l_locality_pay_area	                  ghr_locality_pay_areas_f.Locality_Pay_Area_Code%type;
 l_Occupation_code                   	ghr_pa_requests.to_occ_code%type;
-- l_Occupation_code                	per_position_extra_info.poei_information6%type;
 l_One_Time_Payment_Amount      		ghr_pa_requests.AWARD_AMOUNT%type;
 l_Organ_Component              		per_position_extra_info.poei_information5%type;

 l_pay_rate_determinant_code    		ghr_pa_requests.PAY_RATE_DETERMINANT%type;
 l_Personnel_Officer_ID           		per_position_extra_info.poei_information3%type;
 l_Position_Occ_Code            		ghr_pa_requests.POSITION_OCCUPIED%type;
 l_Prior_Basic_Pay           			varchar2(30); -- ghr_pa_requests.FROM_BASIC_PAY%type;
 -- l_prior_location_id     			hr_locations.location_id%type
 l_prior_duty_station    			ghr_duty_stations_f.Duty_Station_Code%type;
 l_Prior_Grade_Or_Level      			per_grade_definitions.segment2%type;
 l_Prior_Locality_Adj        			varchar2(30); --ghr_pa_requests.FROM_LOCALITY_ADJ%type;
 l_prior_locality_pay_area			ghr_locality_pay_areas_f.Locality_Pay_Area_Code%type;
 l_Prior_Occupation_code          		per_job_definitions.segment1%type;
 l_Prior_Pay_Basis  		  		per_position_extra_info.poei_information6%type;
 l_Prior_Pay_Plan            			per_grade_definitions.segment1%type;
 l_Prior_Pay_Rate_Det_Code      		per_assignment_extra_info.aei_information6%type;
 l_Prior_Step_Or_Rate        			per_assignment_extra_info.aei_information3%type;
 l_prior_work_schedule_code       		ghr_pa_requests.WORK_SCHEDULE%type;
 l_Production_Date          			date;
 l_Race_National_Region         		per_people_extra_info.pei_information5%type;
 l_rating_of_record_level 			ghr_pa_request_extra_info.rei_information5%type;
 l_rating_of_record_pattern			ghr_pa_request_extra_info.rei_information4%type;
 l_rating_of_record_period			ghr_pa_request_extra_info.rei_information6%type;
 l_rating_of_record_per_starts   	        ghr_pa_request_extra_info.rei_information19%type;   --4753117
 l_retain_grade					per_people_extra_info.pei_information3%type;
 l_retain_pay_plan				per_people_extra_info.pei_information5%type;
 l_retain_step					per_people_extra_info.pei_information4%type;
 l_temp_step					per_people_extra_info.pei_information9%type;
 l_Retirement_Plan_Code         		ghr_pa_requests.RETIREMENT_PLAN%type;
 l_Retention_Allowance          		varchar2(30); -- ghr_pa_requests.TO_RETENTION_ALLOWANCE%type;  --number(15,2)
 l_Second_NOAC_Lookup_code                ghr_pa_requests.SECOND_NOA_CODE%type;
 l_Service_Computation_Date     		ghr_pa_requests.SERVICE_COMP_DATE%type;
 l_Sex                          		per_people_f.sex%type;
 l_special_pay_table_id           		per_position_extra_info.poei_information5%type;
 l_staffing_differential          		varchar2(30); -- ghr_pa_requests.TO_STAFFING_DIFFERENTIAL%type;  --number(15,2)
 l_submission_date                		date;
 l_supervisory_differential       		varchar2(30); -- ghr_pa_requests.TO_SUPERVISORY_DIFFERENTIAL%type; --number(15,2)
 l_Supervisory_Status_Code      		ghr_pa_requests.SUPERVISORY_STATUS%type;
 l_Tenure_Group_Code            		ghr_pa_requests.TENURE%type;
 l_To_Basic_Pay                 		varchar2(30); -- ghr_pa_requests.TO_BASIC_PAY%type;
 l_To_Grade_Or_Level            		ghr_pa_requests.TO_GRADE_OR_LEVEL%type;
 l_To_Locality_Adj              		varchar2(30); -- ghr_pa_requests.TO_LOCALITY_ADJ%type;
 l_To_Pay_Basis                 		ghr_pa_requests.TO_PAY_BASIS%type;
 l_To_Pay_Plan                  		ghr_pa_requests.TO_PAY_PLAN%type;
 l_To_Pay_Status                          varchar2(30);
 l_To_Position_ID                         ghr_pa_requests.TO_Position_ID%type;
 l_To_Step_Or_Rate              		ghr_pa_requests.TO_STEP_OR_RATE%type;
 l_rpa_Step_Or_Rate              		ghr_pa_requests.TO_STEP_OR_RATE%type;
 l_Veterans_Preference_Code       		ghr_pa_requests.VETERANS_PREFERENCE%type;
 l_Veterans_Status_Code         		ghr_pa_requests.VETERANS_STATUS%type;
 l_work_schedule_code             		ghr_pa_requests.WORK_SCHEDULE%type;
 l_year_degree_attained         		ghr_pa_requests.YEAR_DEGREE_ATTAINED%type;
 l_prior_effective_date                   ghr_pa_requests.effective_date%type;
 l_prior_loc_adj_effective_date           ghr_pa_requests.effective_date%type;
 l_session                                ghr_history_api.g_session_var_type;
 l_element_entry_value_id                 pay_element_entry_values_f.element_entry_value_id%type;
 l_prior_ds_effective_date                      ghr_pa_requests.effective_date%type;
---Bug 5855843
 l_prior_ds_effective_date_flag        BOOLEAN;
---Bug 5855843
 l_org_structure_id       					per_position_extra_info.poei_information5%type;
l_update34_date                           date;
l_race_ethnic_info 						 varchar2(30);  -- Bug 4724337 Race or National Origin changes



 CURSOR cur_dutystation IS
     select dst.duty_station_code
          , lpa.locality_pay_area_code
 from ghr_duty_stations_f dst
    , ghr_locality_pay_areas_f lpa
 where dst.LOCALITY_PAY_AREA_ID = lpa.LOCALITY_PAY_AREA_ID
 and  dst.DUTY_STATION_ID       = p_loc_info.duty_station_id
 and  nvl(p_pa_request_rec.effective_date,trunc(sysdate))
      between dst.effective_start_date and dst.effective_end_date
 and  nvl(p_pa_request_rec.effective_date,trunc(sysdate))
      between lpa.effective_start_date and lpa.effective_end_date;

-----Bug 5855843 Start
CURSOR cur_ds_prior_date IS
       select effective_date
       from ghr_pa_requests
       where pa_notification_id is not null
       and person_id = p_pa_request_rec.person_id
       and effective_date <= p_pa_request_rec.effective_date
       order by effective_date desc;
-----Bug 5855843 end

CURSOR cur_prior_dutystation IS
 select dst.duty_station_code
      , lpa.locality_pay_area_code
 from ghr_duty_stations_f dst
    , ghr_locality_pay_areas_f lpa
    , hr_locations loc
    , hr_location_extra_info lei
 where
      loc.location_id           = p_sf52_from_data.duty_station_location_id
 and  lei.location_id           = loc.location_id
 and  lei.information_type      = 'GHR_US_LOC_INFORMATION'
 and  dst.duty_station_id       = lei.lei_information3
 and  lpa.LOCALITY_PAY_AREA_ID  = dst.LOCALITY_PAY_AREA_ID
 and  nvl(l_prior_ds_effective_date,trunc(sysdate))
      between dst.effective_start_date and dst.effective_end_date
 and  nvl(l_prior_ds_effective_date,trunc(sysdate))
      between lpa.effective_start_date and lpa.effective_end_date;


-- cursor added by skutteti to fetch the prior effective date, used for prior salary checks.
-------------------------------------------------------------------------------
--
-- Cursor modified for Payroll Integration
--
Cursor c_eev_id (p_element_name     varchar2,
                 p_input_value_name varchar2,
		 p_bg_id            NUMBER) is
   SELECT    eev.element_entry_value_id,
             eev.effective_start_date
      FROM   pay_element_types_f elt,
             pay_input_values_f ipv,
             pay_element_links_f eli,
             pay_element_entries_f ele,
             pay_element_entry_values_f eev
     WHERE  trunc(p_pa_request_rec.effective_date) between elt.effective_start_date
                                    and elt.effective_end_date
            and trunc(p_pa_request_rec.effective_date) between ipv.effective_start_date
                                    and ipv.effective_end_date
            and trunc(p_pa_request_rec.effective_date) between eli.effective_start_date
                                    and eli.effective_end_date
            and trunc(p_pa_request_rec.effective_date) between ele.effective_start_date
                                    and ele.effective_end_date
            and trunc(p_pa_request_rec.effective_date) between eev.effective_start_date
                                    and eev.effective_end_date
            and elt.element_type_id = ipv.element_type_id
            --and elt.element_type_id = eli.element_type_id + 0 --commented for bug 5208846
            and elt.element_type_id = eli.element_type_id
--          and upper(elt.element_name) =  upper('Basic Salary Rate')
            and upper(elt.element_name) =  upper(p_element_name)
            and ipv.input_value_id = eev.input_value_id
            and ele.assignment_id =    p_pa_request_rec.employee_assignment_id
           -- and ele.element_entry_id + 0 = eev.element_entry_id   --Commented for bug 5208846
            and ele.element_entry_id = eev.element_entry_id
--          and upper(ipv.name) =  upper('Salary');
            and upper(ipv.name) =  upper(p_input_value_name)
--	    and NVL(elt.business_group_id,0)=NVL(ipv.business_group_id,0)
	    and (elt.business_group_id is NULL or elt.business_group_id=p_bg_id);

-- Bug 2589851
-- Changed the c_prior_date cursor to filter out the subsequent actions
-- processed after the effective date
-- Bug 2897202
-- condition (pa_request_id <  p_pa_request_rec.altered_pa_request_id)  removed.
-- Eliminate the original and correction actions.

-- Bug#3278827 Peformance Issue.
-- Modified the query. Changed the table from ghr_element_entry_values_h_v to ghr_pa_hisotry

CURSOR c_prior_date (p_element_entry_value_id  varchar2) is
       SELECT  FND_DATE.CANONICAL_TO_DATE(INFORMATION2) effective_start_date
       FROM    ghr_pa_history                                      -- ghr_element_entry_values_h_v
       WHERE   TABLE_NAME = 'PAY_ELEMENT_ENTRY_VALUES_F'
       AND     INFORMATION1 = p_element_entry_value_id  -- information1 holds element_entry_value_id
       AND     effective_date <= l_effective_date
       AND     pa_request_id not in
         (SELECT pa_request_id
         FROM   ghr_pa_requests par
	 WHERE  ((par.first_noa_id = l_session.noa_id_correct)
                 OR
                 (par.first_noa_code = '002' and par.second_noa_id = l_session.noa_id_correct))
         CONNECT BY par.pa_request_id =  prior par.altered_pa_request_id
         START WITH par.pa_request_id =  p_pa_request_rec.altered_pa_request_id )
       ORDER BY 1 desc;
--
-- Cursor to get prior effective date for fetching the from duty station
-- Bug#3278827 Peformance Issue.
-- Modified the query. Changed the table from ghr_assignments_h_v to ghr_pa_hisotry

CURSOR c_prior_ds_date (p_assignment_id  in number)  is
       SELECT  FND_DATE.CANONICAL_TO_DATE(INFORMATION2) effective_start_date
       FROM    ghr_pa_history                                 -- ghr_assignments_h_v
       WHERE   TABLE_NAME = 'PER_ASSIGNMENTS_F'
       AND     INFORMATION1 =  to_Char(p_assignment_id)     -- information1 holds assignment_id
       AND     pa_request_id not in
              (SELECT pa_request_id
               FROM   ghr_pa_history his
               CONNECT BY his.pa_request_id =  prior his.altered_pa_request_id
               START WITH his.pa_request_id =  p_pa_request_rec.altered_pa_request_id )
       ORDER BY 1 desc;
-- New cursor for non correction actions
cursor c_prior_ds_date_non_correct(p_assignment_id in number) is
      select effective_start_date
        from per_all_assignments_f
        where assignment_id = p_assignment_id
        and p_pa_request_rec.effective_date between
            effective_start_date and nvl(effective_end_date,trunc(sysdate))
        order by effective_start_date desc;

-- cursor added by skutteti to identify whether the user entered retained pay table is a special table.
--
CURSOR c_special_pay_table (pay_table_id varchar2) is
       SELECT user_table_id
       FROM   pay_user_tables
       WHERE  user_table_id = pay_table_id
       AND    upper(user_table_name) like upper('%SPECIAL%RATE%');
-- cursor added by vravikan for converting basic pay for pay plans having equivalent pay plan as 'FW'
-- Bug# 963123
cursor c_fw_pay_plans( p_pay_plan varchar2) is
       SELECT 'X'
	 FROM ghr_pay_plans
	WHERE equivalent_pay_plan = 'FW'
        AND   pay_plan = p_pay_plan;
cursor c_740_rei is
select count(rei_information3) rei_count
       from ghr_pa_request_extra_info
       where pa_request_id = p_pa_request_rec.pa_request_id
       and information_type = 'GHR_US_PAR_TERM_RG_POSN_CHG'
       and rei_information5 = 'Y'
       and nvl(rei_information30,hr_api.g_varchar2) <> 'Original RPA';

Cursor c_rg_pei is
      SELECT  count(person_extra_info_id) pei_count
      FROM   per_people_extra_info pei
      WHERE  pei.person_id = p_pa_request_rec.person_id
      AND    pei.information_type = 'GHR_US_RETAINED_GRADE'
      AND    l_effective_date
             BETWEEN NVL(fnd_date.canonical_to_date(pei.pei_information1) ,l_effective_date)
      AND            NVL(fnd_date.canonical_to_date(pei.pei_information2) ,l_effective_date);

 ------------------ cursor created to handle Null Org Struct id for MRE Correction

Cursor c_pei_null_OPM(p_position_id number) is
select poei_information5 l_org_structure_id
from per_position_extra_info
where information_type='GHR_US_POS_GRP1' and position_id=p_position_id;

----------------------------------- cursor to handle changes to LAC codes for Correction to Apptmt action 1274541
Cursor c_Corr_LAC_Codes(p_pa_request_id number) is
select second_action_la_code1,second_action_la_code2,first_noa_code,second_noa_code
from ghr_pa_requests
where pa_request_id=p_pa_request_id and first_noa_code='002';


Cursor fam_code(p_second_noa_id number) is
select noa_family_code from ghr_noa_families
where nature_of_action_id=p_second_noa_id and noa_family_code='APP'
AND
nature_of_action_id not in (select nature_of_action_id from ghr_noa_families
where noa_family_code='APPT_TRANS');

CURSOR cur_temp_step
IS
SELECT  rei_information3 temp_step
FROM    ghr_pa_request_extra_info
WHERE   pa_request_id = p_pa_request_rec.pa_request_id
AND     information_type = 'GHR_US_PAR_RG_TEMP_PROMO';


---------------------------------------------------------- added 2 cursors for 1274541
l_first_noa_code ghr_pa_requests.first_noa_code%type;
l_second_noa_code ghr_pa_requests.second_noa_code%type;
l_fam_code ghr_pa_requests.noa_family_code%type;

l_pei_count number;
l_rei_count number;
-- Payroll Integration
-- Pick BG id
Cursor Cur_bg(p_assignment_id NUMBER,p_eff_date DATE) is
       Select distinct business_group_id bg
       from per_assignments_f
       where assignment_id = p_assignment_id
       and p_eff_date between effective_start_Date
       and effective_end_date;

ll_bg_id       NUMBER;
ll_pay_basis   VARCHAR2(80);
ll_effective_date    DATE;
l_new_element_name    VARCHAR2(80);
-- for bug 3191704
--
CURSOR cur_rei_poi(p_par_id in NUMBER)
IS
SELECT rei_information5
FROM   ghr_pa_request_extra_info
WHERE  pa_request_id=p_par_id
AND    information_type='GHR_US_PAR_REALIGNMENT';

target_poi              ghr_pa_requests.personnel_office_id%type;
--
-- for bug 3191704

--
Begin
 -- Initialize the global variables
 g_temp_step := NULL;
 g_fw_annualize := NULL;
if g_bypass_cpdf <> TRUE then
--
 hr_utility.set_location('entering'||l_proc,10);
--
-- Initialization
 -- Pick the business group id and also pay basis for later use
  ll_effective_date := p_pa_request_rec.effective_date;
  For BG_rec in Cur_BG(p_pa_request_rec.employee_assignment_id,ll_effective_date)
  Loop
   ll_bg_id:=BG_rec.bg;
  End Loop;

-- Picking the Pay basis from the RPA

   If (p_pa_request_rec.from_pay_basis is NULL and
       p_pa_request_rec.to_pay_basis is not NULL) then
    ll_pay_basis:=p_pa_request_rec.to_pay_basis;

   elsif (p_pa_request_rec.from_pay_basis is NOT NULL and
         p_pa_request_rec.to_pay_basis is NULL) then
     ll_pay_basis:=p_pa_request_rec.from_pay_basis;

   elsif (p_pa_request_rec.from_pay_basis is NOT NULL and
         p_pa_request_rec.to_pay_basis is NOT NULL) then
     ll_pay_basis:=p_pa_request_rec.to_pay_basis;

   elsif (p_pa_request_rec.from_pay_basis is NULL and
         p_pa_request_rec.to_pay_basis is NULL) then
         ll_pay_basis:='PA';
   End If;
--
 l_academic_discipline         :=p_pa_request_rec.ACADEMIC_DISCIPLINE;
 l_Adj_Base_Pay                :=p_pa_request_rec.TO_ADJ_BASIC_PAY;
 l_agency_subelement           := p_agency_code;
 l_Agency_Code                 := substr(l_agency_subelement,1,2);
 l_as_of_date                  :=Null;
 l_Benefit_Amount              :=p_gov_awards_type.tangible_benefit_dollars;
 l_bargaining_unit_status_code :=p_pa_request_rec.BARGAINING_UNIT_STATUS;
 l_citizenship                 :=p_pa_request_rec.CITIZENSHIP;
 l_credit_mil_svc              :=p_per_uniformed_services.creditable_military_service;
-------------------------------------------------------------------------------------- code added for 1274541
FOR corr_lac IN c_Corr_LAC_Codes(p_pa_request_rec.pa_request_id) LOOP
l_first_noa_code := corr_lac.first_noa_code;
l_second_noa_code:= corr_lac.second_noa_code;
END LOOP;
IF l_first_noa_code = '002' then
If l_second_noa_code = p_pa_request_rec.first_noa_code then
FOR fam_code_rec IN fam_code(p_pa_request_rec.first_noa_id)
LOOP
l_fam_code		:= fam_code_rec.noa_family_code;
END LOOP;
end if;
end if;


IF (l_first_noa_code='002' AND l_fam_code='APP') THEN
	FOR corr_lac_rec in c_Corr_LAC_Codes(p_pa_request_rec.pa_request_id)
	LOOP

	 l_Cur_Appt_Auth_1             :=corr_lac_rec.second_action_la_code1;
	 l_Cur_Appt_Auth_2             :=corr_lac_rec.second_action_la_code2;

	END LOOP;

ELSE
l_Cur_Appt_Auth_1             :=p_per_group1.org_appointment_auth_code1;
l_Cur_Appt_Auth_2             :=p_per_group1.org_appointment_auth_code2;
END IF;

---------------------------------------------------------------------------------- code added for 1274541

--
 hr_utility.set_location('Before dutystation cur rec '|| l_proc, 20);
--
 FOR cur_dutystation_rec IN  cur_dutystation LOOP
     l_Duty_Station_Lookup_Code := cur_dutystation_rec.duty_station_code;
     l_locality_pay_area        := cur_dutystation_rec.locality_pay_area_code;
 END LOOP;

 l_education_level              :=p_pa_request_rec.EDUCATION_LEVEL;
 l_effective_date        	:=p_pa_request_rec.EFFECTIVE_DATE;
 l_Employee_Date_of_Birth       :=p_personal_info.p_date_of_birth;
 l_Employee_First_Name          :=p_pa_request_rec.EMPLOYEE_FIRST_NAME;
 l_Employee_Last_Name           :=p_pa_request_rec.EMPLOYEE_LAST_NAME;
 l_employee_National_ID         :=p_personal_info.p_national_identifier;
 l_fegli_code                   :=p_pa_request_rec.FEGLI;
 l_fers_coverage                :=p_per_sep_retire.fers_coverage;
 l_First_Action_NOA_LA_Code1    :=p_pa_request_rec.FIRST_ACTION_LA_CODE1;
 l_First_Action_NOA_LA_Code2    :=p_pa_request_rec.FIRST_ACTION_LA_CODE2;

 l_First_NOAC_Lookup_Code       :=p_pa_request_rec.FIRST_NOA_CODE;
 -- Bug#4486823 RRR Changes.
 l_First_NOAC_Lookup_desc       :=p_pa_request_rec.FIRST_NOA_DESC;
 l_flsa_category                :=p_pa_request_rec.FLSA_CATEGORY;
 l_functional_class             :=p_pa_request_rec.FUNCTIONAL_CLASS;
 l_health_plan                  :=p_health_plan;
 l_Handicap                     :=p_per_group1.handicap_code;
 l_Indiv_Award                  :=p_gov_awards_type.group_award;
 l_One_Time_Payment_Amount      :=p_pa_request_rec.AWARD_AMOUNT;
 l_Organ_Component              :=p_pos_grp1.organization_structure_id;

 l_Position_Occ_Code            :=p_pa_request_rec.POSITION_OCCUPIED;

-------------------------- 2623692  for MRE correction
if( p_pos_grp1.organization_structure_id is null) then

		FOR OPM_CUR IN c_pei_null_OPM(p_pa_request_rec.from_position_id) LOOP
			l_Organ_Component              :=OPM_CUR.l_org_structure_id;
		END LOOP;
else
 l_Organ_Component              :=p_pos_grp1.organization_structure_id;
end if;


if (p_pa_request_rec.FIRST_NOA_CODE='790') then

 --l_Personnel_Officer_ID         :=p_pa_request_rec.personnel_office_id;
 -- for bug 3191704
  FOR poi_rec IN cur_rei_poi(p_pa_request_rec.pa_request_id)
  LOOP
   target_poi := poi_rec.rei_information5;
  END LOOP;
  --
  IF target_poi IS NOT NULL THEN
   l_Personnel_Officer_ID := target_poi;
  ELSE
   l_Personnel_Officer_ID := p_pa_request_rec.personnel_office_id;
  END IF;
  -- IF target POI is not null check
else

 l_Personnel_Officer_ID         :=p_pos_grp1.personnel_office_id;
end if;


-------- bug#2623692
 --
 -- fetch the prior date for the locality adj element
 -- this is used for the prior locality adj edits

 -- Payroll Integration
 -- New element name is picked for Adj Basic pay
 l_new_element_name := pqp_fedhr_uspay_int_utils.return_new_element_name(
                                         p_fedhr_element_name => 'Adjusted Basic Pay',
                                           p_business_group_id  => ll_bg_id,
	                                   p_effective_date     => ll_effective_date,
	                                   p_pay_basis          => NULL);

-- Processing Adjusted basic pay
-- NAME    DATE       BUG           COMMENTS
-- Ashley  17-JUL-03  Payroll Intg  Modified the Input Value name
--                                  Changes from Adjusted Pay -> Amount

 for  eev_id in c_eev_id (p_element_name     => l_new_element_name,
                          p_input_value_name => 'Amount',
			  p_bg_id            => ll_bg_id)
 loop
     l_prior_loc_adj_effective_date  := eev_id.effective_start_date;
     l_element_entry_value_id        := eev_id.element_entry_value_id;
 end loop;
 if l_session.noa_id_correct is not null then -- for correction
    for prior_date in c_prior_date (p_element_entry_value_id => l_element_entry_value_id )
    loop
        l_prior_loc_adj_effective_date := prior_date.effective_start_date;
        exit;
    end loop;
 end if;
--
 hr_utility.set_location('Before dutystation prior rec '|| l_proc, 30);
--
ghr_history_api.get_g_session_var(l_session);
 If l_session.noa_id_correct is not null then
   For prior_ds_date_rec in c_prior_ds_date(p_pa_request_rec.employee_assignment_id) loop
     l_prior_ds_effective_date   :=  prior_ds_date_rec.effective_start_date;
     exit;
   End loop;
 else
-- Start Bug 1676026
 -- Prior Locality Adjustment effective date is used rather than using the current
 -- Assignment effective start date since current assignment effective start date
 -- fetching wrong locality pay area
/*
   For prior_ds_date_rec in c_prior_ds_date_non_correct(p_pa_request_rec.employee_assignment_id) loop
     l_prior_ds_effective_date   :=  prior_ds_date_rec.effective_start_date;
     exit;
   End loop;
*/
 l_prior_ds_effective_date   :=  l_prior_loc_adj_effective_date;
 -- End Bug 1676026

 end if;
 hr_utility.set_location('prior ds effective date is '||to_char(l_prior_ds_effective_date,'dd-mon-yyyy')||l_proc, 30);

 l_prior_ds_effective_date_flag := FALSE;
 hr_utility.set_location('l_prior_ds_effective_date_flag is FALSE' || l_proc,32);
 FOR cur_prior_dutystation_rec IN  cur_prior_dutystation LOOP
     l_prior_ds_effective_date_flag := TRUE;
 hr_utility.set_location('l_prior_ds_effective_date_flag is TRUE' || l_proc,34);
     l_prior_duty_station      := cur_prior_dutystation_rec.duty_station_code;
     l_prior_locality_pay_area := cur_prior_dutystation_rec.locality_pay_area_code;
 END LOOP;

---Bug 5855843 End
 if not l_prior_ds_effective_date_flag then
    FOR cur_ds_prior_date_rec IN cur_ds_prior_date LOOP
        l_prior_ds_effective_date := cur_ds_prior_date_rec.effective_date;
        hr_utility.set_location('l_prior_ds_effective_date ' || to_char(l_prior_ds_effective_date,'dd-mon-yy') ||  l_proc,36);
        exit;
    END LOOP;
    FOR cur_prior_dutystation_rec IN cur_prior_dutystation LOOP
     l_prior_duty_station      := cur_prior_dutystation_rec.duty_station_code;
     l_prior_locality_pay_area := cur_prior_dutystation_rec.locality_pay_area_code;
     hr_utility.set_location('l_prior_ds_code ' || l_prior_duty_station  ||  l_proc,38);
    END LOOP;

     l_prior_ds_effective_date   :=  l_prior_loc_adj_effective_date;
end if;
---Bug 5855843 End
 l_Prior_Basic_Pay             :=to_char(p_sf52_from_data.basic_pay);
 l_Prior_Grade_Or_Level        :=p_sf52_from_data.grade_or_level;
 l_Prior_Locality_Adj          :=to_char(p_sf52_from_data.locality_adj);
 l_Prior_Occupation_code       :=p_sf52_from_data.occ_code;
 l_Prior_Pay_Basis             :=p_sf52_from_data.pay_basis;
 l_Prior_Pay_Plan              :=p_sf52_from_data.pay_plan;
 l_prior_work_schedule_code    :=p_sf52_from_data.WORK_SCHEDULE;
 l_Production_Date             :=Null;
 l_Race_National_Region        :=p_per_group1.race_national_origin;
 l_rating_of_record_level      :=p_perf_appraisal_type.rating_rec_level;
 l_rating_of_record_pattern    :=p_perf_appraisal_type.rating_rec_pattern;
 l_rating_of_record_period     :=p_perf_appraisal_type.date_appr_ends;
--Bug# 4753117 28-Feb-07 Veeramani  adding Appraisal start date
   l_rating_of_record_per_starts   :=p_perf_appraisal_type.date_appr_starts;
-- End of Bug#4753117

for rei_rec in  c_740_rei loop
   l_rei_count := rei_rec.rei_count;
 end loop;
 for pei_rec in  c_rg_pei loop
   l_pei_count := pei_rec.pei_count;
 end loop;
 hr_utility.set_location('l_rei_count is '||l_rei_count,1);
 hr_utility.set_location('l_pei_count is '||l_pei_count,2);
 IF p_pa_request_rec.first_noa_code in ('703','866') THEN
   FOR cur_temp_step_rec IN cur_temp_step LOOP
     l_temp_step  := cur_temp_step_rec.temp_step;
   END LOOP;
   hr_utility.set_location('l_temp_step value is '|| l_temp_step, 31);
 ELSIF p_per_retained_grade.temp_step is not null THEN
   If l_first_noac_lookup_code in ('867','892','893') then
     If l_session.noa_id_correct is null  then
       l_temp_step               := p_per_retained_grade.temp_step + 1;
       IF l_temp_step < 10 then
         l_temp_step := '0'||trim(l_temp_step);
       END IF;
     Else
       l_temp_step               := p_per_retained_grade.temp_step;
     End if;
   Else
     l_temp_step                 := p_per_retained_grade.temp_step;
   End if;
 END IF;
 hr_utility.set_location('l_temp_step value is '|| l_temp_step, 32);
 ghr_history_api.get_g_session_var(l_session);
 IF l_temp_step is NULL then
   l_Prior_Pay_Rate_Det_Code     :=p_sf52_from_data.pay_rate_determinant;
   l_Prior_Step_Or_Rate          :=p_sf52_from_data.step_or_rate;
 ELSE
   IF l_first_noac_lookup_code in ('703') THEN
     l_Prior_Pay_Rate_Det_Code     :=p_sf52_from_data.pay_rate_determinant;
     l_Prior_Step_Or_Rate          :=p_sf52_from_data.step_or_rate;
   ELSE
    -- 4701896. To Bypass edit 570.50.2.
	-- Bug# 5195807 NVL condition added
     l_Prior_Pay_Rate_Det_Code     := NVL(p_pa_request_rec.input_pay_rate_determinant,p_sf52_from_data.pay_rate_determinant);
    /* for special_pay_table in
       c_special_pay_table (p_pos_valid_grade.pay_table_id)loop
      l_Prior_Pay_Rate_Det_Code     := '6';
    end loop; */
    If l_first_noac_lookup_code in ('867','892','893') then
-- Bug 3021003 Commented the code as both normal and correction
-- actions should have the same step.
--     If l_session.noa_id_correct is null  then
        -- Bug#4716290 For A,B,E,F,U,V prior prd should be "0".
        IF l_prior_pay_rate_det_code IN ('A', 'B', 'E', 'F', 'U', 'V') THEN
            l_Prior_Step_Or_Rate := '00';
        ELSE
	       l_Prior_Step_Or_Rate := to_number(l_temp_step) - 1;
        END IF;
--     Else
--       l_Prior_Step_Or_Rate := l_temp_step;
    ELSE
      -- 4701896. To Bypass edit 580.19.2.
      IF l_prior_pay_rate_det_code IN ('A', 'B', 'E', 'F', 'U', 'V') THEN
        l_Prior_Step_Or_Rate := '00';
      ELSE
        l_Prior_Step_Or_Rate := l_temp_step;
      END IF;
    End if;
   END IF;
 END IF;
 hr_utility.set_location('l_temp_step value is '|| l_temp_step, 33);
 IF l_temp_step is NULL then
   IF p_pa_request_rec.first_noa_code = '702' and
    p_pa_request_rec.pay_rate_determinant not in
       ('A','B','E','F','M','U','V') THEN
     l_retain_grade                := null;
   ELSIF p_pa_request_rec.first_noa_code = '740' and
         p_pa_request_rec.pay_rate_determinant not in
       ('A','B','E','F','M','U','V') and
    l_rei_count = l_pei_count THEN
      hr_utility.set_location('l_rei_count is '||l_rei_count,3);
      hr_utility.set_location('l_pei_count is '||l_pei_count,4);
      l_retain_grade                := null;
   ELSE
     l_retain_grade              :=p_per_retained_grade.retain_grade;
   END IF;
   l_retain_pay_plan             :=p_per_retained_grade.retain_pay_plan;

   hr_utility.set_location('RG temp step value is '|| p_per_retained_grade.temp_step, 30);
   hr_utility.set_location('RG step value is '|| p_per_retained_grade.retain_step_or_rate, 30);
   ghr_history_api.get_g_session_var(l_session);
   If l_first_noac_lookup_code in ('867','892','893') then
     If l_session.noa_id_correct is null  then
       if p_per_retained_grade.retain_step_or_rate <>  '10' then
         l_retain_step   := '0' ||(p_per_retained_grade.retain_step_or_rate + 1 );
       else
         l_retain_step   := p_per_retained_grade.retain_step_or_rate + 1;
       end if;
     Else
       l_retain_step                 :=p_per_retained_grade.retain_step_or_rate;
     End if;
   Else
     l_retain_step                 :=p_per_retained_grade.retain_step_or_rate;
   End if;
 ELSE
   l_retain_grade                := null;
 End if;

 hr_utility.set_location('retain step value is '|| l_retain_step, 30);

 l_Retirement_Plan_Code        :=p_pa_request_rec.RETIREMENT_PLAN;
 l_Retention_Allowance         :=p_pa_request_rec.TO_RETENTION_ALLOWANCE;
--
 hr_utility.set_location('After some assignments '|| l_proc, 30);
--

 l_Second_NOAC_Lookup_code    :=p_pa_request_rec.SECOND_NOA_CODE;
 l_Service_Computation_Date   :=p_pa_request_rec.SERVICE_COMP_DATE;
 l_Sex                        :=p_personal_info.p_sex;
-- l_special_pay_table_id       :=p_pos_valid_grade.pay_table_id;         -- commented by skuttei on 17-apr-98
 l_staffing_differential      :=p_pa_request_rec.TO_STAFFING_DIFFERENTIAL;
 l_submission_date            :=Null;
 l_supervisory_differential   :=p_pa_request_rec.TO_SUPERVISORY_DIFFERENTIAL;
 l_Supervisory_Status_Code    :=p_pa_request_rec.SUPERVISORY_STATUS;
 l_Tenure_Group_Code          :=p_pa_request_rec.TENURE;
 l_To_Pay_Status              :=Null;
 l_Veterans_Preference_Code   :=p_pa_request_rec.VETERANS_PREFERENCE;
 l_Veterans_Status_Code       :=p_pa_request_rec.VETERANS_STATUS;
 l_year_degree_attained       :=to_char(p_pa_request_rec.YEAR_DEGREE_ATTAINED);

-- added by skutteti on 17-apr-98 to get the special pay table id for the cpdf checks.
if  p_per_retained_grade.retain_grade is not null then
    for special_pay_table in c_special_pay_table (p_per_retained_grade.retain_pay_table_id)loop
        l_special_pay_table_id := special_pay_table.user_table_id;
    end loop;
else
    for special_pay_table in c_special_pay_table (p_pos_valid_grade.pay_table_id)loop
        l_special_pay_table_id := special_pay_table.user_table_id;
    end loop;
end if;


--
-- if to_position_id is null, assign 'from' data to 'to' data.
--
l_To_Position_ID              := p_pa_request_rec.TO_Position_ID;
--
 hr_utility.set_location('After some more assignments '|| l_proc, 40);
--

if l_To_Position_ID is not null then

--	l_Occupation_code           :=p_pos_grp1.occupation_category_code;
 	l_Occupation_code           :=p_pa_request_rec.to_occ_code;
	l_To_Pay_Basis              :=p_pa_request_rec.TO_PAY_BASIS;
	l_To_Grade_Or_Level         :=p_pa_request_rec.TO_GRADE_OR_LEVEL;
	l_To_Pay_Plan               :=p_pa_request_rec.TO_PAY_PLAN;
	l_To_Locality_Adj           := to_char(p_pa_request_rec.TO_LOCALITY_ADJ);
	l_To_Basic_Pay 	          := to_char(p_pa_request_rec.TO_BASIC_PAY);
	l_pay_rate_determinant_code :=p_pa_request_rec.PAY_RATE_DETERMINANT;
    IF l_temp_step IS NULL THEN
        l_To_Step_Or_Rate           :=p_pa_request_rec.TO_STEP_OR_RATE;
        l_pay_rate_determinant_code :=p_pa_request_rec.PAY_RATE_DETERMINANT;
    ELSE
        l_To_Step_Or_Rate           := l_temp_step;
        l_RPA_Step_Or_Rate       := p_pa_request_rec.TO_STEP_OR_RATE;
        l_pay_rate_determinant_code := '0';
        -- Bug#4657737 Commented the following code. Why is this resetting of PRD required?
        /* FOR special_pay_table in c_special_pay_table (p_pos_valid_grade.pay_table_id)loop
            l_Prior_Pay_Rate_Det_Code := '6';
        END LOOP;*/
    END IF;
	l_work_schedule_code        :=p_pa_request_rec.WORK_SCHEDULE;
/*
else
 	l_To_Basic_Pay              :=to_char(p_sf52_from_data.basic_pay);
 	l_To_Grade_Or_Level         :=p_sf52_from_data.grade_or_level;
 	l_To_Locality_Adj           :=to_char(p_sf52_from_data.locality_adj);
 	l_Occupation_code           :=p_sf52_from_data.occ_code;
 	l_To_Pay_Basis              :=p_sf52_from_data.pay_basis;
 	l_To_Pay_Plan               :=p_sf52_from_data.pay_plan;
 	l_pay_rate_determinant_code :=p_sf52_from_data.pay_rate_determinant;
 	l_To_Step_Or_Rate           :=p_sf52_from_data.step_or_rate;
	l_work_schedule_code        :=p_sf52_from_data.WORK_SCHEDULE;
*/
   -- Adding for SLR Bug 3536448
   IF (p_pa_request_rec.noa_family_code='GHR_STUDENT_LOAN') THEN
     l_to_basic_pay := p_pa_request_rec.from_basic_pay;
     l_to_pay_basis := p_pa_request_rec.from_pay_basis;
   END IF;
end if;
--
 hr_utility.set_location('After Position assignments '|| l_proc, 50);
--
l_update34_date := ghr_pay_caps.update34_implemented_date(p_pa_request_rec.person_id);
  If (l_update34_date is null
     OR
     nvl(p_pa_request_rec.effective_date,sysdate ) <  l_update34_date)
--     and      (p_pa_request_rec.noa_family_code<>'GHR_STUDENT_LOAN')
  THEN
    for  pay_plan_rec in c_fw_pay_plans(l_to_pay_plan) loop
      l_to_Basic_Pay                   := ghr_pay_calc.convert_amount(l_to_basic_pay,
                                                                      l_to_pay_basis,
                                                                      'PA');
      g_fw_annualize := 'Y';
    end loop;
    for  prior_pay_plan_rec in c_fw_pay_plans(l_prior_pay_plan) loop
      l_Prior_Basic_Pay                := ghr_pay_calc.convert_amount(l_prior_basic_pay,
                                                                      l_prior_pay_basis,
                                                                       'PA');
    end loop;
 elsif  nvl(p_pa_request_rec.effective_date,sysdate ) >= l_update34_date  THEN
    for  pay_plan_rec in c_fw_pay_plans(l_to_pay_plan) loop
      l_to_Basic_Pay                   := ghr_pay_calc.convert_amount(l_to_basic_pay,
                                                                      l_to_pay_basis,
                                                                      'PA');
      g_fw_annualize := 'Y';
    end loop;
    for  prior_pay_plan_rec in c_fw_pay_plans(l_prior_pay_plan) loop
      l_Prior_Basic_Pay                := ghr_pay_calc.convert_amount(l_prior_basic_pay,
                                                                      l_prior_pay_basis,
                                                                       'PA');
    end loop;
  end if;


-- need to get the effective_date of the prior pay table
--  Say for instance, the employee had a previous change in his basic pay on the 30-DEC-97 based on
-- the pay table effective then
-- If then there is a subsequent action on the 13-MAR-98, (assuming the new pay tables are
-- effective as of the 04-JAN-98' , then we should be getting the values from
-- the pay table effective as of his prior pay change to do any check on his prior pay basis

-- Payroll Integration
-- Changes needed here -Madhuri.
l_new_element_name := pqp_fedhr_uspay_int_utils.return_new_element_name
                                  (p_fedhr_element_name => 'Basic Salary Rate',
                                   p_business_group_id  => ll_bg_id,
                                   p_effective_date     => ll_effective_date,
                                   p_pay_basis          => ll_pay_basis);

 for  eev_id in c_eev_id (p_element_name     => l_new_element_name,
                          p_input_value_name => 'Rate',
			  p_bg_id            => ll_bg_id)
 loop
     l_prior_effective_date    := eev_id.effective_start_date;
     l_element_entry_value_id  := eev_id.element_entry_value_id;
 end loop;

 hr_utility.set_location('l_prior_effective date is '|| l_prior_effective_date, 60);
 hr_utility.set_location('l_element_entry_value_id is '|| l_element_entry_value_id, 60);
 ghr_history_api.get_g_session_var(l_session);
 hr_utility.set_location('l_session.noa_id_correct is '|| l_session.noa_id_correct, 60);
 if l_session.noa_id_correct is not null then -- for correction
    for prior_date in c_prior_date (p_element_entry_value_id => l_element_entry_value_id )

    loop
        l_prior_effective_date  := prior_date.effective_start_date;
 hr_utility.set_location('l_prior_effective date is '|| l_prior_effective_date, 61);
 hr_utility.set_location('l_element_entry_value_id is '|| l_element_entry_value_id, 61);
        exit;
    end loop;
 end if;

	 -- Bug 4724337 Race or National Origin changes
	IF p_race_ethnic_info.p_hispanic IS NOT NULL OR
		p_race_ethnic_info.p_american_indian IS NOT NULL OR
		p_race_ethnic_info.p_asian IS NOT NULL OR
		p_race_ethnic_info.p_black_afr_american IS NOT NULL OR
		p_race_ethnic_info.p_hawaiian_pacific IS NOT NULL OR
		p_race_ethnic_info.p_white IS NOT NULL THEN

		l_race_ethnic_info := NVL(p_race_ethnic_info.p_hispanic,' ') || NVL(p_race_ethnic_info.p_american_indian,' ') || NVL(p_race_ethnic_info.p_asian,' ') ||
								NVL(p_race_ethnic_info.p_black_afr_american,' ') || NVL(p_race_ethnic_info.p_hawaiian_pacific,' ') || NVL(p_race_ethnic_info.p_white,' ');
		hr_utility.set_location('Ethnicity value is ' || l_race_ethnic_info,1234);
	END IF;
	-- End Bug 4724337 Race or National Origin changes


 g_academic_discipline              := 	l_academic_discipline;
 g_Adj_Base_Pay                     :=  l_Adj_Base_Pay;
 g_Agency_Code                      :=  l_Agency_Code;
 g_agency_subelement                :=	l_agency_subelement;
 g_as_of_date                       :=  l_as_of_date;
 g_Benefit_Amount                   :=	l_Benefit_Amount;
 g_bargaining_unit_status_code      := 	l_bargaining_unit_status_code;
 g_citizenship                      :=	l_citizenship;
 g_credit_mil_svc                   :=	l_credit_mil_svc;
 g_Cur_Appt_Auth_1                  :=    l_Cur_Appt_Auth_1;
 g_Cur_Appt_Auth_2                  :=    l_Cur_Appt_Auth_2;
 g_Duty_Station_ID 	            	:=	l_Duty_Station_ID;
 g_Duty_Station_Lookup_Code         :=	l_Duty_Station_Lookup_Code;
 g_education_level                  :=	l_education_level;
 g_effective_date	                :=	l_effective_date;
 g_Employee_Date_of_Birth           :=	l_Employee_Date_of_Birth;
 g_Employee_First_Name              :=	l_Employee_First_Name;
 g_Employee_Last_Name               :=	l_Employee_Last_Name;
 g_employee_National_ID             :=	l_employee_National_ID;
 g_fegli_code      	  	      		:=	l_fegli_code;
 g_fers_coverage            	    :=	l_fers_coverage;
 g_First_Action_NOA_LA_Code1        :=   	l_First_Action_NOA_LA_Code1;
 g_First_Action_NOA_LA_Code2        :=   	l_First_Action_NOA_LA_Code2;
 g_First_NOAC_Lookup_Code           :=	l_First_NOAC_Lookup_Code;
 g_flsa_category                    :=	l_flsa_category;
 g_functional_class    	            :=	l_functional_class;
 g_health_plan	 	            	:=	l_health_plan;
 g_Handicap                         :=	l_Handicap;
 g_Indiv_Award                      :=	l_Indiv_Award;
 g_locality_pay_area	            :=    l_locality_pay_area;
 g_Occupation_code                  :=    l_Occupation_code;
 g_One_Time_Payment_Amount          :=	l_One_Time_Payment_Amount;
 g_Organ_Component                  :=	l_Organ_Component;
 g_pay_rate_determinant_code        :=	l_pay_rate_determinant_code;
 g_Personnel_Officer_ID             :=  	l_Personnel_Officer_ID;
 g_Position_Occ_Code                :=	l_Position_Occ_Code;
 g_Prior_Basic_Pay                  :=	l_Prior_Basic_Pay;
 g_prior_duty_station    			:=	l_prior_duty_station;
 g_Prior_Grade_Or_Level      		:=	l_prior_Grade_Or_Level;
 g_Prior_Locality_Adj        		:=	l_Prior_Locality_Adj;
 g_prior_locality_pay_area			:=	l_prior_locality_pay_area;
 g_Prior_Occupation_code      		:=    l_Prior_Occupation_code;
 g_Prior_Pay_Basis  				:=	l_Prior_Pay_Basis;
 g_Prior_Pay_Plan            		:=	l_Prior_Pay_Plan;
 g_Prior_Pay_Rate_Det_Code    	:=	l_Prior_Pay_Rate_Det_Code;
 g_Prior_Step_Or_Rate        	:=	l_Prior_Step_Or_Rate;
 g_prior_work_schedule_code   :=  	l_prior_work_schedule_code;
 g_Production_Date          	:=	l_Production_Date;
 g_Race_National_Region       :=	l_Race_National_Region;
 g_rating_of_record_level 	:=	l_rating_of_record_level;
 g_rating_of_record_pattern	:=	l_rating_of_record_pattern;
 g_rating_of_record_period	:=	l_rating_of_record_period;
 g_retain_grade			:=	l_retain_grade;
 g_retain_pay_plan		:=	l_retain_pay_plan;
 g_retain_step			:=	l_retain_step;
 g_temp_step			:=	l_temp_step;
 g_Retirement_Plan_Code       :=	l_Retirement_Plan_Code;
 g_Retention_Allowance        :=	l_Retention_Allowance;
 g_Second_NOAC_Lookup_code    :=    l_Second_NOAC_Lookup_code;
 g_Service_Computation_Date   :=	l_Service_Computation_Date;
 g_Sex                        :=	l_Sex;
 g_special_pay_table_id       :=  	l_special_pay_table_id;
 g_staffing_differential      :=  	l_staffing_differential;
 g_submission_date            :=  	l_submission_date;
 g_supervisory_differential   :=  	l_supervisory_differential;
 g_Supervisory_Status_Code    :=	l_Supervisory_Status_Code;
 g_Tenure_Group_Code          :=	l_Tenure_Group_Code;
 g_To_Basic_Pay               :=	l_To_Basic_Pay;
 g_To_Grade_Or_Level          :=	l_To_Grade_Or_Level;
 g_To_Locality_Adj            :=	l_To_Locality_Adj;
 g_To_Pay_Basis               :=	l_To_Pay_Basis;
 g_To_Pay_Plan                :=	l_To_Pay_Plan;
 g_To_Pay_Status              :=    l_To_Pay_Status;
 g_To_Position_ID             :=    l_To_Position_ID;
 g_To_Step_Or_Rate            :=  	l_To_Step_Or_Rate;
 g_Veterans_Preference_Code   :=    l_Veterans_Preference_Code;
 g_Veterans_Status_Code       :=  	l_Veterans_Status_Code;
 g_work_schedule_code         :=    l_work_schedule_code;
 g_year_degree_attained	      :=    l_year_degree_attained;
 g_race_ethnic_info			  := 	l_race_ethnic_info;

--
--
 hr_utility.set_location('Calling CPDF Check'|| l_proc, 60);
--

GHR_CPDF_CHECK.call_CPDF_Check
(

   p_academic_discipline             =>  l_academic_discipline
  ,p_Adj_Base_Pay                    =>  l_Adj_Base_Pay
  ,p_agency                          =>  l_Agency_Code
  ,p_agency_subelement               =>  l_agency_subelement
  ,p_as_of_date                      =>  l_as_of_date
  ,p_Benefit_Amount                  =>  l_Benefit_Amount
  ,p_bargaining_unit_status_code     =>  l_bargaining_unit_status_code
  ,p_citizenship                     =>  l_citizenship
  ,p_credit_mil_svc                  =>  l_credit_mil_svc
  ,p_Cur_Appt_Auth_1                 =>  l_Cur_Appt_Auth_1
  ,p_Cur_Appt_Auth_2                 =>  l_Cur_Appt_Auth_2
  ,p_Duty_Station_Lookup_Code        =>  l_Duty_Station_Lookup_Code
  ,p_education_level                 =>  l_education_level
  ,p_effective_date                  =>  l_effective_date
  ,p_Employee_Date_of_Birth          =>  l_Employee_Date_of_Birth
  ,p_Employee_First_Name             =>  l_Employee_First_Name
  ,p_Employee_Last_Name              =>  l_Employee_last_Name
  ,p_employee_National_ID            =>  l_employee_National_ID
  ,p_fegli_code                      =>  l_fegli_code
  ,p_fers_coverage                   =>  l_fers_coverage
  ,p_First_Action_NOA_LA_Code1       =>  l_First_Action_NOA_LA_Code1
  ,p_First_Action_NOA_LA_Code2       =>  l_First_Action_NOA_LA_Code2
  ,p_First_NOAC_Lookup_Code          =>  l_First_NOAC_Lookup_Code
  --Bug#4486823 RRR Changes
  ,p_First_NOAC_Lookup_desc          =>  l_First_NOAC_Lookup_desc
  ,p_flsa_category                   =>  l_flsa_category
  ,p_functional_class                =>  l_functional_class
  ,p_health_plan                     =>  l_health_plan
  ,p_handicap                        =>  l_Handicap
  ,p_Indiv_Award                     =>  l_Indiv_Award
  ,p_locality_pay_area               =>  l_locality_pay_area
  ,p_occupation_code                 =>  l_Occupation_code
  ,p_One_Time_Payment_Amount         =>  l_One_Time_Payment_Amount
  ,p_Organ_Component                 =>  l_Organ_Component
  ,p_pay_rate_determinant_code       =>  l_pay_rate_determinant_code
  ,p_Personnel_Officer_ID            =>  l_Personnel_Officer_ID
  ,p_Position_Occ_Code               =>  l_Position_Occ_Code
  ,p_Prior_Basic_Pay                 =>  l_Prior_Basic_Pay
  ,p_prior_duty_station              =>  l_prior_duty_station
  ,p_Prior_Grade_Or_Level            =>  l_Prior_Grade_Or_Level
  ,p_Prior_Locality_Adj              =>  l_Prior_Locality_Adj
  ,p_prior_locality_pay_area         =>  l_prior_locality_pay_area
  ,p_Prior_Occupation_code           =>  l_prior_occupation_code
  ,p_Prior_Pay_Basis                 =>  l_Prior_Pay_Basis
  ,p_Prior_Pay_Plan                  =>  l_Prior_Pay_Plan
  ,p_Prior_Pay_Rate_Det_Code         =>  l_Prior_Pay_Rate_Det_Code
  ,p_Prior_Step_Or_Rate              =>  l_Prior_Step_Or_Rate
  ,p_prior_work_schedule_code        =>  l_prior_work_schedule_code
  ,p_Production_Date                 =>  l_Production_Date
  ,p_Race_National_Region            =>  l_Race_National_Region
  ,p_rating_of_record_level          =>  l_rating_of_record_level
  ,p_rating_of_record_pattern	     =>  l_rating_of_record_pattern
  ,p_rating_of_record_period	     =>  l_rating_of_record_period
  --Bug# 4753117 28-Feb-07	Veeramani  adding Appraisal start date as a parameter to the procedure
  ,p_rating_of_record_per_starts  =>  l_rating_of_record_per_starts
  ,p_retain_grade	             =>  l_retain_grade
  ,p_retain_pay_plan		     =>  l_retain_pay_plan
  ,p_retain_step	             =>  l_retain_step
  ,p_Retirement_Plan_Code            =>  l_retirement_plan_code
  ,p_Retention_Allowance             =>  l_Retention_Allowance
  ,p_Second_NOAC_Lookup_code         =>  l_Second_NOAC_Lookup_code
  ,p_Service_Computation_Date        =>  l_Service_Computation_Date
  ,p_Sex                             =>  l_sex
  ,p_special_pay_table_id            =>  l_special_pay_table_id
  ,p_staffing_differential           =>  l_staffing_differential
  ,p_submission_date                 =>  l_submission_date
  ,p_supervisory_differential        =>  l_supervisory_differential
  ,p_Supervisory_Status_Code         =>  l_Supervisory_Status_Code
  ,p_Tenure_Group_Code               =>  l_Tenure_Group_Code
  ,p_To_Basic_Pay                    =>  l_To_Basic_Pay
  ,p_To_Grade_Or_Level               =>  l_To_grade_or_level
  ,p_To_Locality_Adj                 =>  l_To_locality_adj
  ,p_To_Pay_Basis                    =>  l_To_pay_basis
  ,p_To_Pay_Plan                     =>  l_To_pay_plan
  ,p_to_pay_status                   =>  l_To_pay_status
  ,p_To_Step_Or_Rate                 =>  l_To_step_or_rate
  ,p_Veterans_Preference_Code        =>  l_veterans_preference_code
  ,p_Veterans_Status_Code            =>  l_Veterans_Status_Code
  ,p_work_schedule_code              =>  l_work_schedule_code
  ,p_year_degree_attained            =>  l_year_degree_attained
  ,p_assignment_id                   =>  p_pa_request_rec.employee_assignment_id
  ,p_noa_family_code                 =>  p_pa_request_rec.noa_family_code
  ,p_prior_effective_date            =>  l_prior_effective_date
  ,p_prior_loc_adj_effective_date    =>  l_prior_loc_adj_effective_date
  ,p_rpa_step_or_rate             	 =>  l_rpa_step_or_rate
  ,p_ethnic_race_info				 =>	 l_race_ethnic_info
);
--
 hr_utility.set_location('After Calling CPDF Check'|| l_proc, 70);
--

end if;
--
 hr_utility.set_location('Calling Agency Check'|| l_proc, 80);
--
--
 hr_utility.set_location('Calling Validate Check'|| l_proc, 90);
--

end GHRWS52L;
--
procedure CPDF_Parameter_Check is
--
--
begin
--
null;

  hr_utility.set_location('p_academic_discipline '||g_academic_discipline,1);
  hr_utility.set_location('p_Adj_Base_Pay '||g_Adj_Base_Pay,2);
  hr_utility.set_location('p_Agency_Code '||g_Agency_Code,3);
  hr_utility.set_location('p_agency_subelement '||g_agency_subelement,4);
  hr_utility.set_location('p_as_of_date '||g_as_of_date,5);
  hr_utility.set_location('p_Benefit_Amount '||g_Benefit_Amount,6);
  hr_utility.set_location('p_bargaining_unit_status_code '||g_bargaining_unit_status_code,7);
  hr_utility.set_location('p_citizenship '||g_citizenship,8);
  hr_utility.set_location('p_credit_mil_svc '||g_credit_mil_svc,9);
  hr_utility.set_location('p_Cur_Appt_Auth_1 '||g_Cur_Appt_Auth_1,10);
  hr_utility.set_location('p_Cur_Appt_Auth_2 '||g_Cur_Appt_Auth_2,11);
  hr_utility.set_location('p_Duty_Station_ID '||g_Duty_Station_ID,12);
  hr_utility.set_location('p_Duty_Station_Lookup_Code '||g_Duty_Station_Lookup_Code,13);
  hr_utility.set_location('p_education_level '||g_education_level,14);
  hr_utility.set_location('p_effective_date '||g_effective_date,15);
  hr_utility.set_location('p_Employee_Date_of_Birth '||g_Employee_Date_of_Birth,16);
  hr_utility.set_location('p_Employee_First_Name '||g_Employee_First_name,17);
  hr_utility.set_location('p_Employee_Last_Name '||g_Employee_Last_name,18);
  hr_utility.set_location('p_employee_National_ID '||g_employee_National_ID,19);
  hr_utility.set_location('p_fegli_code '||g_fegli_code,20);
  hr_utility.set_location('p_fers_coverage '||g_fers_coverage,21);
  hr_utility.set_location('p_First_Action_NOA_LA_Code1 '||g_First_Action_NOA_LA_Code1,22);
  hr_utility.set_location('p_First_Action_NOA_LA_Code2 '||g_First_Action_NOA_LA_Code2,23);
  hr_utility.set_location('p_First_NOAC_Lookup_Code '||g_First_NOAC_Lookup_Code,24);
  -- Bug#4486823 RRR Changes
  hr_utility.set_location('p_First_NOAC_Lookup_desc '||g_First_NOAC_Lookup_desc,24);
  hr_utility.set_location('p_flsa_category '||g_flsa_category,25);
  hr_utility.set_location('p_functional_class '||g_functional_class,26);
  hr_utility.set_location('p_health_plan '||g_health_plan,27);
  hr_utility.set_location('p_Handicap '||g_Handicap,28);
  hr_utility.set_location('p_Indiv_Award '||g_Indiv_Award,29);
  hr_utility.set_location('p_locality_pay_area '||g_locality_pay_area,30);
  hr_utility.set_location('p_Occupation_code '||g_Occupation_code,31);
  hr_utility.set_location('p_One_Time_Payment_Amount '||g_One_Time_Payment_Amount,32);
  hr_utility.set_location('p_Organ_Component '||g_Organ_Component,33);
  hr_utility.set_location('p_pay_rate_determinant_code '||g_pay_rate_determinant_code,34);
  hr_utility.set_location('p_Personnel_Officer_ID '||g_Personnel_Officer_ID,35);
  hr_utility.set_location('p_Position_Occ_Code '||g_Position_Occ_Code,36);
  hr_utility.set_location('p_Prior_Basic_Pay '||g_Prior_Basic_Pay,37);
  hr_utility.set_location('p_prior_duty_station '||g_prior_duty_station,38);
  hr_utility.set_location('p_Prior_Grade_Or_Level '||g_Prior_Grade_Or_Level,39);
  hr_utility.set_location('p_Prior_Locality_Adj '||g_Prior_Locality_Adj,40);
  hr_utility.set_location('p_prior_locality_pay_area '||g_prior_locality_pay_area,41);
  hr_utility.set_location('p_Prior_Occupation_code '||g_Prior_Occupation_code,42);
  hr_utility.set_location('p_Prior_Pay_Basis '||g_Prior_Pay_Basis,43);
  hr_utility.set_location('p_Prior_Pay_Plan '||g_Prior_Pay_Plan,44);
  hr_utility.set_location('p_Prior_Pay_Rate_Det_Code '||g_Prior_Pay_Rate_Det_Code,45);
  hr_utility.set_location('p_Prior_Step_Or_Rate '||g_Prior_Step_Or_Rate,46);
  hr_utility.set_location('p_prior_work_schedule_code '||g_prior_work_schedule_code,47);
  hr_utility.set_location('p_Production_Date '||g_Production_Date,48);
  hr_utility.set_location('p_Race_National_Region '||g_Race_National_Region,49);
  hr_utility.set_location('p_rating_of_record_level '||g_rating_of_record_level,50);
  hr_utility.set_location('p_rating_of_record_pattern '||g_rating_of_record_pattern,51);
  hr_utility.set_location('p_rating_of_record_period '||g_rating_of_record_period,52);
  hr_utility.set_location('p_retain_grade '||g_retain_grade,53);
  hr_utility.set_location('p_retain_pay_plan '||g_retain_pay_plan,54);
  hr_utility.set_location('p_retain_step '||g_retain_step,55);
  hr_utility.set_location('p_Retirement_Plan_Code '||g_Retirement_Plan_Code,56);
  hr_utility.set_location('p_Retention_Allowance '||g_Retention_Allowance,57);
  hr_utility.set_location('p_Second_NOAC_Lookup_code '||g_Second_NOAC_Lookup_code,58);
  hr_utility.set_location('p_Service_Computation_Date '||g_Service_Computation_Date,59);
  hr_utility.set_location('p_Sex '||g_Sex,60);
  hr_utility.set_location('p_special_pay_table_id '||g_special_pay_table_id,61);
  hr_utility.set_location('p_staffing_differential '||g_staffing_differential,62);
  hr_utility.set_location('p_submission_date '||g_submission_date,63);
  hr_utility.set_location('p_supervisory_differential '||g_supervisory_differential,64);
  hr_utility.set_location('p_Supervisory_Status_Code '||g_Supervisory_Status_Code,65);
  hr_utility.set_location('p_Tenure_Group_Code '||g_Tenure_Group_Code,66);
  hr_utility.set_location('p_To_Basic_Pay '||g_To_Basic_Pay,67);
  hr_utility.set_location('p_To_Grade_Or_Level '||g_To_Grade_Or_Level,68);
  hr_utility.set_location('p_To_Locality_Adj '||g_To_Locality_Adj,69);
  hr_utility.set_location('p_To_Pay_Basis '||g_To_Pay_Basis,70);
  hr_utility.set_location('p_To_Pay_Plan '||g_To_Pay_Plan,71);
  hr_utility.set_location('p_to_pay_status '||g_to_pay_status,72);
  hr_utility.set_location('p_To_Step_Or_Rate '||g_To_Step_Or_Rate,73);
  hr_utility.set_location('p_Veterans_Preference_Code '||g_Veterans_Preference_Code,74);
  hr_utility.set_location('p_Veterans_Status_Code '||g_Veterans_Status_Code,75);
  hr_utility.set_location('p_work_schedule_code '||g_work_schedule_code,76);
  hr_utility.set_location('p_year_degree_attained '||g_year_degree_attained,77);
  hr_utility.set_location('p_race_ethnic_info '||g_race_ethnic_info,77);

 --
end CPDF_Parameter_Check;
--
end GHR_GHRWS52L;

/

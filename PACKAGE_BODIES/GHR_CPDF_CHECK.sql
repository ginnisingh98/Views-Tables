--------------------------------------------------------
--  DDL for Package Body GHR_CPDF_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CPDF_CHECK" as
/* $Header: ghcpdf00.pkb 120.14.12010000.12 2009/09/18 11:41:13 vmididho ship $ */



procedure call_CPDF_Check
  (
   p_academic_discipline          	in varchar2
  ,p_Adj_Base_Pay                 	in number
  ,p_Agency                       	in varchar2   -- Non-SF52 Data Item
  ,p_agency_subelement		 		in varchar2   -- Non-SF52 Data Item
  ,p_as_of_date                     in date       -- Non-SF52 Data Item
  ,p_Benefit_Amount              	in varchar2   -- Non-SF52 Data Item
  ,p_bargaining_unit_status_code   	in varchar2
  ,p_citizenship           			in varchar2
  ,p_credit_mil_svc            		in varchar2   -- Non-SF52 Data Item
  ,p_Cur_Appt_Auth_1                in varchar2   -- non SF52 item
  ,p_Cur_Appt_Auth_2                in varchar2   -- non SF52 item
  ,p_Duty_Station_Lookup_Code     	in varchar2
  ,p_education_level              	in varchar2
  ,p_effective_date					in date
  ,p_Employee_Date_of_Birth       	in date
  ,p_Employee_First_Name          	in varchar2
  ,p_Employee_Last_Name           	in varchar2
  ,p_employee_National_ID       	in varchar2
  ,p_fegli_code      				in varchar2
  ,p_fers_coverage            		in varchar2   -- Non-SF52 Data Item
  ,p_First_Action_NOA_LA_Code1      in varchar2
  ,p_First_Action_NOA_LA_Code2      in varchar2
  ,p_First_NOAC_Lookup_Code       	in varchar2
  -- Bug#4486823 RRR Changes
  ,p_First_NOAC_Lookup_desc       	in varchar2
  ,p_flsa_category                	in varchar2
  ,p_functional_class    			in varchar2
  ,p_health_plan	 	        	in varchar2   -- Non-SF52 Data Item
  ,p_Handicap                     	in varchar2   -- Non-SF52 Data Item
  ,p_Indiv_Award            		in varchar2   -- Non-SF52 Data Item
  ,p_locality_pay_area				in varchar2   -- Non-SF52 Data Item
  ,p_Occupation_code                in varchar2   -- Non-SF52 Data Item
  ,p_One_Time_Payment_Amount      	in number
  ,p_Organ_Component              	in varchar2   -- Non-SF52 Data Item
  ,p_pay_rate_determinant_code    	in varchar2
  ,p_Personnel_Officer_ID           in varchar2   -- Non-SF52 Data Item
  ,p_Position_Occ_Code            	in varchar2
  ,p_Prior_Basic_Pay           		in varchar2   -- Non-SF52 Data Item
  ,p_prior_duty_station    			in varchar2   -- Non-SF52 Data Item
  ,p_Prior_Grade_Or_Level      		in varchar2   -- Non-SF52 Data Item
  ,p_Prior_Locality_Adj        		in varchar2   -- Non-SF52 Data Item
  ,p_prior_locality_pay_area		in varchar2   -- Non-SF52 Data Item
  ,p_Prior_Occupation_code          in varchar2   -- Non-SF52 Data Item
  ,p_Prior_Pay_Basis  		  		in varchar2   -- Non-SF52 Data Item
  ,p_Prior_Pay_Plan            		in varchar2   -- Non-SF52 Data Item
  ,p_Prior_Pay_Rate_Det_Code      	in varchar2   -- Non-SF52 Data Item
  ,p_Prior_Step_Or_Rate        		in varchar2   -- Non-SF52 Data Item
  ,p_prior_work_schedule_code       in varchar2   -- Non-SF52 Data Item
  ,p_Production_Date          		in date       -- Non-SF52 Data Item
  ,p_Race_National_Region         	in varchar2   -- Non-SF52 Data Item
  ,p_rating_of_record_level 		in varchar2   -- Non-SF52 Data Item
  ,p_rating_of_record_pattern		in varchar2   -- Non-SF52 Data Item
  ,p_rating_of_record_period		in varchar2   -- Non-SF52 Data Item
  ,p_rating_of_record_per_starts     in varchar2   -- Non-SF52 Data Item
  ,p_retain_grade					in varchar2   -- Non-SF52 Data Item
  ,p_retain_pay_plan				in varchar2
  ,p_retain_step					in varchar2   -- Non-SF52 Data Item
  ,p_Retirement_Plan_Code         	in varchar2
  ,p_Retention_Allowance          	in varchar2   -- Non-SF52 Data Item
  ,p_Second_NOAC_Lookup_code        in varchar2
  ,p_Service_Computation_Date     	in Date
  ,p_Sex                          	in varchar2   -- Non-SF52 Data Item
  ,p_special_pay_table_id           in varchar2   -- Non-SF52 Data Item
  ,p_staffing_differential        	in varchar2   -- Non-SF52 Data Item
  ,p_submission_date              	in date       -- Non-SF52 Data Item
  ,p_supervisory_differential     	in varchar2   -- Non-SF52 Data Item
  ,p_Supervisory_Status_Code      	in varchar2
  ,p_Tenure_Group_Code            	in varchar2
  ,p_To_Basic_Pay                 	in varchar2
  ,p_To_Grade_Or_Level            	in varchar2
  ,p_To_Locality_Adj              	in varchar2
  ,p_To_Pay_Basis                 	in varchar2
  ,p_To_Pay_Plan                  	in varchar2
  ,p_to_pay_status		      		in varchar2   -- Non-SF52 Data Item
  ,p_To_Step_Or_Rate              	in varchar2
  ,p_Veterans_Preference_Code       in varchar2
  ,p_Veterans_Status_Code         	in varchar2
  ,p_work_schedule_code             in varchar2
  ,p_year_degree_attained         	in varchar2
  ,p_assignment_id                  in number
  ,p_noa_family_code                in varchar2
  ,p_prior_effective_date           in date
  ,p_prior_loc_adj_effective_date   in date
  ,p_rpa_step_or_rate            	in varchar2
  ,p_ethnic_race_info				in varchar2 -- Bug 4724337 Race or National Origin changes
 ) is
/*

Missing CPDF Data Items: 4/11/97

-- p_Agency_Code                   		varchar2;   -- Non-SF52 Data Item
-- p_Agency                         	varchar2;
-- p_agency_subelement		 		varchar2;   -- Non-SF52 Data Item
-- p_as_of_date                     	date;       -- Non-SF52 Data Item
-- p_Benefit_Amount              		varchar2;   -- Non-SF52 Data Item;
-- p_health_plan	 	                  varchar2;   -- Non-SF52 Data Item
-- p_Indiv_Award            			varchar2;
-- p_Organ_Component              		varchar2;   -- Non-SF52 Data Item
-- p_to_Pay_Status                        varchar2;   -- Non-SF52 Data Item
-- p_prior_duty_station    			varchar2;   -- Non-SF52 Data Item
-- p_prior_locality_pay_area			varchar2;   -- Non-SF52 Data Item
-- p_prior_work_schedule_code       	varchar2;   -- Non-SF52 Data Item
-- p_Production_Date          		date;       -- Non-SF52 Data Item
-- p_rating_of_record_level 			varchar2;   -- Non-SF52 Data Item
-- p_rating_of_record_pattern			varchar2;   -- Non-SF52 Data Item
-- p_rating_of_record_period			varchar2;   -- Non-SF52 Data Item
-- p_Retention_Allowance          		varchar2;   -- Non-SF52 Data Item
-- p_staffing_differential          	varchar2;   -- Non-SF52 Data Item
-- p_submission_date                	date;       -- Non-SF52 Data Item
-- p_supervisory_differential       	varchar2;   -- Non-SF52 Data Item

Missing CPDF Data Items: 9/9/97


-- p_as_of_date                     		date;       -- Non-SF52 Data Item
-- p_to_Pay_Status                            	varchar2;   -- Non-SF52 Data Item
-- p_Production_Date          			date;       -- Non-SF52 Data Item
-- p_submission_date                		date;       -- Non-SF52 Data Item
*/

l_proc                                    varchar2(61) := 'CALL_CPDF_CHECK';
l_session                                 ghr_history_api.g_session_var_type;
l_pay_rate_determinant						varchar2(30); ----Bug# 5639003
l_step_or_rate  ghr_pa_requests.to_step_or_rate%type;
l_rpa_step_or_rate  ghr_pa_requests.to_step_or_rate%type;
Begin

 hr_utility.set_location('Entering ...'|| l_proc, 10);


 hr_utility.set_location('p_academic_discipline : '||p_academic_discipline, 5);
 hr_utility.set_location('p_Adj_Base_Pay :'||to_char(p_Adj_Base_Pay), 5);
 hr_utility.set_location('p_Agency :'||p_Agency , 5);
 hr_utility.set_location('p_agency_subelement :'||p_agency_subelement , 5);
 hr_utility.set_location('p_as_of_date :'||fnd_date.date_to_chardate(p_as_of_date), 5);
 hr_utility.set_location('p_Benefit_Amount :'||p_Benefit_Amount , 5);
 hr_utility.set_location('p_bargaining_unit_status_code :'||p_bargaining_unit_status_code , 5);
 hr_utility.set_location('p_citizenship :'||p_citizenship , 5);
 hr_utility.set_location('p_Cur_Appt_Auth_1 :'||p_Cur_Appt_Auth_1 , 5);
 hr_utility.set_location('p_Cur_Appt_Auth_2 :'||p_Cur_Appt_Auth_2 , 5);
 hr_utility.set_location('p_Duty_Station_Lookup_Code :'||p_Duty_Station_Lookup_Code , 5);
 hr_utility.set_location('p_education_level :'||p_education_level , 5);
 hr_utility.set_location('p_effective_date :'||p_effective_date , 5);
 hr_utility.set_location('p_prior_effective_date :'||fnd_date.date_to_chardate(p_prior_effective_date) , 5);
 hr_utility.set_location('p_Employee_First_Name :'|| substr(p_Employee_First_Name,1,30) , 5);
 hr_utility.set_location('p_Employee_Last_Name :'|| substr(p_Employee_last_Name,1,30) , 5);
 hr_utility.set_location('p_employee_National_ID :'||p_employee_National_ID , 5);
 hr_utility.set_location('p_fegli_code :'||p_fegli_code , 5);
 hr_utility.set_location('p_First_Action_NOA_LA_Code1 :'||p_First_Action_NOA_LA_Code1 , 5);
 hr_utility.set_location('p_First_Action_NOA_LA_Code2 :'||p_First_Action_NOA_LA_Code2 , 5);
 hr_utility.set_location('p_First_NOAC_Lookup_Code :'||p_First_NOAC_Lookup_Code , 5);
 -- Bug#4486823 RRR Changes
 hr_utility.set_location('p_First_NOAC_Lookup_desc :'||p_First_NOAC_Lookup_desc , 5);
 hr_utility.set_location('p_flsa_category :'||p_flsa_category , 5);
 hr_utility.set_location('p_functional_class :'||p_functional_class , 5);
 hr_utility.set_location('p_locality_pay_area :'||p_locality_pay_area , 5);
 hr_utility.set_location('p_One_Time_Payment_Amount :'||p_One_Time_Payment_Amount , 5);
 hr_utility.set_location('p_pay_rate_determinant_code :'||p_pay_rate_determinant_code, 5 );
 hr_utility.set_location('p_Prior_Basic_Pay :'||p_Prior_Basic_Pay , 5);
 hr_utility.set_location('p_prior_duty_station :'||p_prior_duty_station , 5);
 hr_utility.set_location('p_Prior_Grade_Or_Level :'||p_Prior_Grade_Or_Level , 5);
 hr_utility.set_location('p_prior_locality_pay_area :'||p_prior_locality_pay_area , 5);
 hr_utility.set_location('p_Prior_Occupation_code :'||p_Prior_Occupation_code , 5);
 hr_utility.set_location('p_Prior_Pay_Basis :'||p_Prior_Pay_Basis , 5);
 hr_utility.set_location('p_Prior_Pay_Plan :'||p_Prior_Pay_Plan , 5);
 hr_utility.set_location('p_Prior_Pay_Rate_Det_Code :'||p_Prior_Pay_Rate_Det_Code , 5);
 hr_utility.set_location('p_Prior_Step_Or_Rate :'||p_Prior_Step_Or_Rate , 5);
 hr_utility.set_location('p_prior_work_schedule_code :'||p_prior_work_schedule_code , 5);
 hr_utility.set_location('p_retain_grade :'||p_retain_grade , 5);
 hr_utility.set_location('p_retain_pay_plan :'||p_retain_pay_plan , 5);
 hr_utility.set_location('p_retain_step :'||p_retain_step , 5);
 hr_utility.set_location('p_special_pay_table_id :'||p_special_pay_table_id, 5);
 hr_utility.set_location('p_To_Basic_Pay :'||p_To_Basic_Pay , 5);
 hr_utility.set_location('p_To_Grade_Or_Level :'||p_To_Grade_Or_Level , 5);
 hr_utility.set_location('p_To_Locality_Adj :'||p_To_Locality_Adj , 5);
 hr_utility.set_location('p_To_Pay_Basis :'||p_To_Pay_Basis , 5);
 hr_utility.set_location('p_To_Grade_Or_Level :'||p_To_Grade_Or_Level , 5);
 hr_utility.set_location('p_To_Locality_Adj :'||p_To_Locality_Adj , 5);
 hr_utility.set_location('p_To_Pay_Basis :'||p_To_Pay_Basis , 5);
 hr_utility.set_location('p_To_Pay_Plan :'||p_To_Pay_Plan , 5);
 hr_utility.set_location('p_to_pay_status :'||p_to_pay_status , 5);
 hr_utility.set_location('p_work_schedule_code :'||p_work_schedule_code , 5);
 hr_utility.set_location('p_assignment_id :'||p_assignment_id , 5);
 hr_utility.set_location('p_Veterans_Status_Code :'||p_Veterans_Status_Code , 5);
 hr_utility.set_location('p_noa_family_code :'||p_noa_family_code , 5);
--Begin Bug# 5639003
IF p_noa_family_code IN ('AWARD','GHR_INCENTIVE') or p_First_NOAC_Lookup_Code = '825' THEN
	l_pay_rate_determinant := NULL;
ELSE
	l_pay_rate_determinant := p_pay_rate_determinant_code;
END IF;
--End Bug# 5639003
/* Calling GHR_CPDF_CHECK1 */
--
 hr_utility.set_location('Calling GHR_CPDF_CHECK1.chk_bargaining_unit '|| l_proc, 10);
--

GHR_CPDF_CHECK1.chk_bargaining_unit
  (p_to_pay_plan
  ,p_agency_subelement
  ,p_bargaining_unit_status_code
  );

--
 hr_utility.set_location('Calling GHR_CPDF_CHECK1.chk_fegli '|| l_proc, 11);
--

GHR_CPDF_CHECK1.chk_fegli
  (p_to_basic_pay
  ,p_to_pay_plan
  ,p_fegli_code
  ,p_effective_date
  );

 hr_utility.set_location('Calling GHR_CPDF_CHECK1.chk_fsla_category'|| l_proc, 12);

GHR_CPDF_CHECK1.chk_fsla_category
  (p_duty_station_lookup_code
  ,p_to_pay_plan
  ,p_agency_subelement
  ,p_flsa_category
  ,p_to_grade_or_level
  ,p_effective_date --Bug# 5619873
  );
 hr_utility.set_location('Calling GHR_CPDF_CHECK1.chk_functional_classification'|| l_proc, 13);

GHR_CPDF_CHECK1.chk_functional_classification
  (p_Occupation_code
  ,p_functional_class
  ,p_effective_date --Bug# 5619873
  );

--
 hr_utility.set_location('Calling GHR_CPDF_CHECK1.chk_health_plan '|| l_proc, 14);
--

GHR_CPDF_CHECK1.chk_health_plan
  (p_health_plan
  ,p_tenure_group_code
  ,p_work_schedule_code
  ,p_to_pay_basis
  ,p_to_pay_status
  ,p_submission_date
  ,p_Cur_Appt_Auth_1
  ,p_Cur_Appt_Auth_2
  );

 hr_utility.set_location('Calling GHR_CPDF_CHECK1.chk_retain_grade'|| l_proc, 15);

GHR_CPDF_CHECK1.chk_retain_grade
  (p_retain_pay_plan
  ,p_retain_grade
  ,l_pay_rate_determinant
  ,p_effective_date
  );
 hr_utility.set_location('Calling GHR_CPDF_CHECK1.chk_retain_pay_plan'|| l_proc, 16);

GHR_CPDF_CHECK1.chk_retain_pay_plan
  (p_retain_grade
  ,p_retain_pay_plan
  ,p_retain_step
  ,p_to_pay_plan
,l_pay_rate_determinant
  ,p_effective_date

  );


 hr_utility.set_location('Calling GHR_CPDF_CHECK1.chk_retain_step'|| l_proc, 17);
GHR_CPDF_CHECK1.chk_retain_step
  (l_pay_rate_determinant
  ,p_first_action_noa_la_code1
  ,p_first_action_noa_la_code2
  ,p_Cur_Appt_Auth_1
  ,p_Cur_Appt_Auth_2
  ,p_retain_pay_plan
  ,p_retain_grade
  ,p_retain_step
  ,p_effective_date
  );

 hr_utility.set_location('Calling GHR_CPDF_CHECK1.chk_retirement_plan'|| l_proc, 18);
-- For Dual corrections with Return to Duty combination this validation has been removed
-- as this validation will be validated during udpate HR of second action correction of dual combination
--Bug #8690175	---Bug # 8838531 added the validation for both normal and corrections
--ghr_history_api.get_g_session_var(l_session);
If NOT(NVL(ghr_process_sf52.g_dual_action_yn,'N') = 'Y'
       and p_noa_family_code IN ('RETURN_TO_DUTY')) then
  GHR_CPDF_CHECK1.chk_retirement_plan
    (p_retirement_plan_code
    ,p_fers_coverage
     );
end if;
--Bug #8690175


 hr_utility.set_location('Calling GHR_CPDF_CHECK1.chk_special_pay_table_id'|| l_proc, 19);
GHR_CPDF_CHECK1.chk_special_pay_table_id
  (l_pay_rate_determinant
  ,p_to_pay_plan
  ,p_special_pay_table_id
  -- FWFA Changes Bug#4444609
  ,p_effective_date
  -- FWFA Changes
  );


 hr_utility.set_location('Calling GHR_CPDF_CHECK1.chk_us_citizenship'|| l_proc, 20);
GHR_CPDF_CHECK1.chk_us_citizenship
  (p_citizenship
  ,p_duty_station_lookup_code
  );

 hr_utility.set_location('Calling GHR_CPDF_CHECK1.chk_century_info'|| l_proc, 37);
GHR_CPDF_CHECK1.chk_century_info (
   p_date_of_birth                   => p_employee_date_of_birth
  ,p_effective_date                  => p_effective_date
  ,p_Service_Computation_Date        => p_service_computation_date
  ,p_year_degree_attained            => p_year_degree_attained
  ,p_rating_of_record_period         => p_rating_of_record_period
  ,p_rating_of_record_per_starts     => p_rating_of_record_per_starts
  );



/* Calling GHR_CPDF_CHECK2 */
--
 hr_utility.set_location('Calling GHR_CPDF_CHECK2.chk_instructional_pgm '|| l_proc, 40);
--

GHR_CPDF_CHECK2.chk_instructional_pgm
  (p_education_level
  ,p_academic_discipline
  ,p_year_degree_attained
  ,p_first_noac_lookup_code
  ,p_effective_date
  ,p_tenure_group_code
  ,p_to_pay_plan
  ,p_Employee_Date_of_Birth
  );

 hr_utility.set_location('Calling GHR_CPDF_CHECK2.chk_award_amount '|| l_proc, 41);
GHR_CPDF_CHECK2.chk_Award_Amount
(  p_First_NOAC_Lookup_Code
  -- Bug#4486823
  ,p_First_NOAC_lookup_Desc
  ,p_One_Time_Payment_Amount
  ,p_To_Basic_Pay
  ,p_Adj_Base_Pay
  ,p_First_Action_NOA_LA_Code1
  ,p_First_Action_NOA_LA_Code2
  ,p_to_pay_plan
  ,p_effective_date
);


 hr_utility.set_location('Calling GHR_CPDF_CHECK2.chk_benefit_amount '|| l_proc, 42);

GHR_CPDF_CHECK2.chk_Benefit_Amount
  (p_First_NOAC_Lookup_Code
  ,p_Benefit_Amount
  ,p_effective_date
);


 hr_utility.set_location('Calling GHR_CPDF_CHECK2.chk_benefit_amount '|| l_proc, 43);

GHR_CPDF_CHECK2.chk_Cur_Appt_Auth
  (p_First_Action_NOA_LA_Code1
  ,p_First_Action_NOA_LA_Code2
  ,p_Cur_Appt_Auth_1
  ,p_Cur_Appt_Auth_2
  ,p_Agency_Subelement
  ,p_Occupation_Code
  ,p_First_NOAC_Lookup_Code
  ,p_Position_Occ_Code
  ,p_To_Pay_Plan
  ,p_Handicap
  ,p_Tenure_Group_Code
  ,p_To_Grade_Or_Level
  ,p_Veterans_Preference_Code
  ,p_Duty_Station_Lookup_Code
  ,p_Service_Computation_Date
  ,p_effective_date
  );
--
 hr_utility.set_location('Calling GHR_CPDF_CHECK2.chk_Date_of_Birth '|| l_proc, 50);
--


GHR_CPDF_CHECK2.chk_Date_of_Birth
  ( p_First_NOAC_Lookup_Code
   ,p_Effective_Date
   ,p_Employee_Date_of_Birth
   ,p_Duty_Station_Lookup_Code
   ,p_as_of_date
  );

 hr_utility.set_location('Calling GHR_CPDF_CHECK2.chk_duty_station '|| l_proc, 51);

GHR_CPDF_CHECK2.chk_duty_station
  (p_to_pay_plan
  ,p_agency_subelement
  ,p_duty_station_lookup_code
  ,p_First_Action_NOA_LA_Code1
  ,p_First_Action_NOA_LA_Code2
  ,p_effective_date
  );
 hr_utility.set_location('Calling GHR_CPDF_CHECK2.chk_education_level '|| l_proc, 52);

GHR_CPDF_CHECK2.chk_Education_Level
  ( p_tenure_group_code
   ,p_education_level
   ,p_to_pay_plan
  );


 hr_utility.set_location('Calling GHR_CPDF_CHECK2.chk_effective_date '|| l_proc, 53);
GHR_CPDF_CHECK2.chk_effective_date
  ( p_First_NOAC_Lookup_Code
   ,p_Effective_Date
   ,p_Production_Date
  );

 hr_utility.set_location('Calling GHR_CPDF_CHECK2.chk_handicap '|| l_proc, 54);

GHR_CPDF_CHECK2.chk_Handicap
  (p_First_Action_NOA_LA_Code1
  ,p_First_Action_NOA_LA_Code2
  ,p_First_NOAC_Lookup_Code
  ,p_Effective_Date
  ,p_Handicap
  );


 hr_utility.set_location('Calling GHR_CPDF_CHECK2.chk_indiv_award '|| l_proc, 55);
GHR_CPDF_CHECK2.chk_indiv_Award
  (p_First_NOAC_Lookup_Code
  ,p_Indiv_Award
  ,p_effective_date
  );


/* Calling GHR_CPDF_CHECK3 */
--
 hr_utility.set_location('Calling GHR_CPDF_CHECK3.chk_Nature_of_Action '|| l_proc, 60);
--

GHR_CPDF_CHECK3.chk_Nature_of_Action (
   p_First_NOAC_Lookup_Code       =>  p_First_NOAC_Lookup_Code
  ,p_Second_NOAC_Lookup_code      =>  p_Second_NOAC_Lookup_code
  ,p_First_Action_NOA_Code1       =>  p_First_Action_NOA_LA_Code1
  ,p_First_Action_NOA_Code2       =>  p_First_Action_NOA_LA_Code2
  ,p_Cur_Appt_Auth_1              =>  p_Cur_Appt_Auth_1
  ,p_Cur_Appt_Auth_2              =>  p_Cur_Appt_Auth_2
  ,p_Employee_Date_of_Birth       =>  p_Employee_Date_of_Birth
  ,p_Duty_Station_Lookup_Code     =>  p_Duty_Station_Lookup_Code
  ,p_Employee_First_Name          =>  p_Employee_First_Name
  ,p_Employee_Last_Name           =>  p_Employee_Last_Name
  ,p_Handicap                     =>  p_handicap
  ,p_Organ_Component              =>  p_Organ_Component
  ,p_Personal_Office_ID           =>  p_Personnel_Officer_ID
  ,p_Position_Occ_Code            =>  p_Position_Occ_Code
  ,p_Race_National_Region         =>  p_Race_National_Region
  ,p_Retirement_Plan_Code         =>  p_Retirement_Plan_Code
  ,p_Service_Computation_Date     =>  p_Service_Computation_Date
  ,p_Sex                          =>  p_sex
  ,p_Supervisory_Status_Code      =>  p_supervisory_status_code
  ,p_Tenure_Group_Code            =>  p_Tenure_Group_Code
  ,p_Veterans_Pref_Code           =>  p_Veterans_Preference_Code
  ,p_Veterans_Status_Code         =>  p_Veterans_status_Code
  ,p_Occupation                   =>  p_occupation_code
  ,p_To_Pay_Basis                 =>  p_to_pay_basis
  ,p_To_Grade_Or_Level            =>  p_To_Grade_Or_Level
  ,p_To_Pay_Plan                  =>  p_To_pay_plan
  ,p_pay_rate_determinant_code    =>  l_pay_rate_determinant
  ,p_To_Basic_Pay                 =>  p_to_basic_pay
  ,p_To_Step_Or_Rate              =>  p_To_Step_Or_Rate
  ,p_Work_Sche_Code               =>  p_work_schedule_code
  ,p_Prior_Occupation             =>  p_Prior_Occupation_code
  ,p_Prior_To_Pay_Basis           =>  p_Prior_Pay_Basis
  ,p_Prior_To_Grade_Or_Level      =>  p_Prior_Grade_Or_Level
  ,p_Prior_To_Pay_Plan            =>  p_Prior_Pay_Plan
  ,p_Prior_Pay_Rate_Det_Code      =>  p_Prior_Pay_Rate_Det_Code
  ,p_Prior_To_Basic_Pay           =>  p_Prior_Basic_Pay
  ,p_Prior_To_Step_Or_Rate        =>  p_Prior_Step_Or_Rate
  ,p_Prior_Work_Sche_Code         =>  p_prior_work_schedule_code
  ,p_prior_duty_station           =>  p_prior_duty_station
  ,p_Retention_Allowance          =>  p_Retention_Allowance
  ,p_Staff_Diff                   =>  p_staffing_differential
  ,p_Supervisory_Diff             =>  p_supervisory_differential
  ,p_To_Locality_Adj              =>  p_To_Locality_Adj
  ,p_Prior_To_Locality_Adj        =>  p_Prior_Locality_Adj
  ,p_noa_family_code              =>  p_noa_family_code
  ,p_effective_date               =>  p_effective_date
  ,p_agency_subelement            =>  p_agency_subelement
  ,p_ethnic_race_info			  => p_ethnic_race_info
);


 hr_utility.set_location('Calling GHR_CPDF_CHECK3.chk_occupation '|| l_proc, 61);
GHR_CPDF_CHECK3.chk_occupation
  (p_to_pay_plan
  ,p_Occupation_code
  ,p_agency_subelement
  ,p_duty_station_lookup_code
,p_effective_date
);
-- hr_utility.set_location('Calling pay_basis '||p_to_pay_basis, 62);
-- hr_utility.set_location('Calling PAY PLAN '||p_to_pay_plan, 62);
-- hr_utility.set_location('Calling PRD  '||p_pay_rate_determinant_code, 62);
-- hr_utility.set_location('Calling basic pay '||p_to_basic_pay, 62);

--- Using NVL(p_retain_pay_plan,p_to_pay_plan) as we need to pick the retained pay plan
--- if any retained grade details exist for that person
---
GHR_CPDF_CHECK3.chk_pay_basis
  ( NVL(p_retain_pay_plan,p_to_pay_plan)
  ,p_to_pay_basis
  ,p_to_basic_pay
  ,p_agency_subelement
  ,p_Position_Occ_Code --Bug# 5745356
  ,p_effective_date
  ,l_pay_rate_determinant
   );

 hr_utility.set_location('Calling GHR_CPDF_CHECK3.chk_pay_grade '|| l_proc, 63);
GHR_CPDF_CHECK3.chk_pay_grade
  (p_to_pay_plan
  ,p_to_grade_or_level
  ,l_pay_rate_determinant
  ,p_first_action_noa_la_code1
  ,p_first_action_noa_la_code2
  ,p_First_NOAC_Lookup_Code
  ,p_Second_NOAC_Lookup_code
  ,p_effective_date
);

 hr_utility.set_location('Calling GHR_CPDF_CHECK3.chk_pay_plan '|| l_proc, 64);
GHR_CPDF_CHECK3.chk_pay_plan
  (p_to_pay_plan
  ,p_agency_subelement
  ,p_personnel_officer_ID
  ,p_to_grade_or_level
  ,p_first_action_noa_la_code1
  ,p_first_action_noa_la_code2
  ,p_Cur_Appt_Auth_1
  ,p_Cur_Appt_Auth_2
  ,p_first_NOAC_Lookup_Code
  ,l_pay_rate_determinant
  ,p_Effective_Date
  ,p_prior_pay_plan
  ,p_prior_grade_or_level
  ,p_Agency
  ,p_Supervisory_status_code
  );

--
 hr_utility.set_location('Calling GHR_CPDF_CHECK3.chk_pay_rate_determinant '|| l_proc, 70);
--

GHR_CPDF_CHECK3.chk_pay_rate_determinant
  (l_pay_rate_determinant
   ,nvl(ghr_process_sf52.g_dual_prior_prd,p_prior_pay_rate_det_code) --8288066 Added for dual actions
  ,p_to_pay_plan
  ,p_first_noac_lookup_code
  ,p_duty_station_lookup_code
  ,p_agency
  ,p_effective_date
);

/* Calling GHR_CPDF_CHECK4 */
--
 hr_utility.set_location('Calling GHR_CPDF_CHECK4.chk_Legal_Authority '|| l_proc, 80);
--

GHR_CPDF_CHECK4.chk_Legal_Authority
  (p_To_Play_Plan              =>  p_To_Pay_Plan
  ,p_Agency_Sub_Element        =>  p_Agency_SubElement
  ,p_First_Action_NOA_LA_Code1 =>  p_First_Action_NOA_LA_Code1
  ,p_First_Action_NOA_LA_Code2 =>  p_First_Action_NOA_LA_Code2
  ,p_First_NOAC_Lookup_Code    =>  p_First_NOAC_Lookup_Code
  ,p_effective_date            =>  p_effective_date
  ,p_position_occupied_code    =>  p_Position_Occ_Code
  );

/* Calling GHR_CPDF_CHECK5 */
--
 hr_utility.set_location('Calling GHR_CPDF_CHECK5.chk_rating_of_rec '|| l_proc, 90);
--

GHR_CPDF_CHECK5.chk_rating_of_rec
  (p_rating_of_record_level
  ,p_rating_of_record_pattern
  ,p_rating_of_record_period
  ,p_rating_of_record_per_starts
  ,p_first_noac_lookup_code
  ,p_effective_date
  ,p_submission_date
  ,p_to_pay_plan
  );

 hr_utility.set_location('Calling GHR_CPDF_CHECK5.chk_position_occupied '|| l_proc, 91);
GHR_CPDF_CHECK5.chk_position_occupied
  (p_position_occ_code
  ,p_to_pay_plan
  ,p_first_noac_lookup_code
  ,p_effective_date
  );

 hr_utility.set_location('Calling GHR_CPDF_CHECK5.chk_prior_occupation '|| l_proc, 92);

GHR_CPDF_CHECK5.chk_prior_occupation
  (p_prior_occupation_code
  ,p_occupation_code
  ,p_first_noac_lookup_code
  ,p_prior_pay_plan
  ,p_agency_subelement
  ,p_effective_date
  );

 hr_utility.set_location('Calling GHR_CPDF_CHECK5.chk_prior_pay_basis '|| l_proc, 93);

GHR_CPDF_CHECK5.chk_prior_pay_basis
  (p_prior_pay_basis
  ,p_prior_pay_plan
  ,p_agency_subelement
  ,p_prior_basic_pay
  ,p_effective_date
  ,p_prior_effective_date
  ,p_prior_pay_rate_det_code
  );


 hr_utility.set_location('Calling GHR_CPDF_CHECK5.chk_prior_grade '|| l_proc, 94);
GHR_CPDF_CHECK5.chk_prior_grade
  (p_prior_pay_plan
  ,p_to_grade_or_level
  ,p_prior_grade_or_level
  ,p_to_pay_plan
  ,p_first_noac_lookup_code
  ,p_prior_pay_rate_det_code
  ,p_effective_date
  );


 hr_utility.set_location('Calling GHR_CPDF_CHECK5.chk_prior_pay_plan '|| l_proc, 95);
GHR_CPDF_CHECK5.chk_prior_pay_plan
  (p_prior_pay_plan
  ,p_to_pay_plan
  ,p_first_noac_lookup_code
  --,p_prior_effective_date -- deleted Bug# 6010943
  ,p_effective_date --  Added Bug# 6010943
  );


 hr_utility.set_location('Calling GHR_CPDF_CHECK5.chk_prior_pay_rate_determinant '|| l_proc, 96);
GHR_CPDF_CHECK5.chk_prior_pay_rate_determinant
  (p_prior_pay_rate_det_code
  ,l_pay_rate_determinant
  ,p_prior_pay_plan
  ,p_to_pay_plan
  ,p_agency
  ,p_First_NOAC_Lookup_Code
  ,p_prior_duty_station
  ,p_prior_effective_date
  ,p_effective_date
  );

--
 hr_utility.set_location('Calling GHR_CPDF_CHECK5.chk_prior_step_or_rate '|| l_proc, 100);
--


GHR_CPDF_CHECK5.chk_prior_step_or_rate
  (p_prior_step_or_rate
  ,p_first_noac_lookup_code
  ,nvl(p_rpa_step_or_rate,p_to_step_or_rate) --Bug# 4947801
  ,l_pay_rate_determinant
  ,p_to_pay_plan
  ,p_prior_pay_rate_det_code
  ,p_prior_pay_plan
  ,p_prior_grade_or_level
  ,p_prior_effective_date
  ,p_cur_appt_auth_1
  ,p_cur_appt_auth_2
  ,p_effective_date
  );

/* Calling GHR_CPDF_CHECK6 */
--
 hr_utility.set_location('Calling GHR_CPDF_CHECK6.chk_prior_work_schedule '|| l_proc, 110);
--

GHR_CPDF_CHECK6.chk_prior_work_schedule
  (p_prior_work_schedule_code
  ,p_work_schedule_code
  ,p_first_noac_lookup_code
  );

 hr_utility.set_location('Calling GHR_CPDF_CHECK6.chk_race_or_natnl_origin '|| l_proc, 111);

GHR_CPDF_CHECK6.chk_race_or_natnl_origin
  (p_Race_National_Region
  ,p_duty_station_lookup_code
  ,p_ethnic_race_info
   ,p_First_NOAC_Lookup_Code -- Bug 4754941
  ,p_Second_NOAC_Lookup_code
  ,p_effective_date
  );

 hr_utility.set_location('Calling GHR_CPDF_CHECK6.chk_prior_duty_station '|| l_proc, 112);


GHR_CPDF_CHECK6.chk_prior_duty_station
  (p_prior_duty_station
  ,p_agency_subelement
  );

 hr_utility.set_location('Calling GHR_CPDF_CHECK6.chk_retention_allowance '|| l_proc, 113);

GHR_CPDF_CHECK6.chk_retention_allowance
  (p_retention_allowance
  ,p_to_pay_plan
  ,p_to_basic_pay
  ,p_first_noac_lookup_code
  ,p_first_action_noa_la_code1
  ,p_first_action_noa_la_code2
  ,p_effective_date --Bug# 8309414
  );


 hr_utility.set_location('Calling GHR_CPDF_CHECK6.chk_staffing_differential '|| l_proc, 114);

GHR_CPDF_CHECK6.chk_staffing_differential
  (p_staffing_differential
  ,p_first_noac_lookup_code
  ,p_first_action_noa_la_code1
  ,p_first_action_noa_la_code2
  );


 hr_utility.set_location('Calling GHR_CPDF_CHECK6.chk_supervisory_differential '|| l_proc, 115);
GHR_CPDF_CHECK6.chk_supervisory_differential
  (p_supervisory_differential
  ,p_first_noac_lookup_code
  ,p_first_action_noa_la_code1
  ,p_first_action_noa_la_code2
  ,p_effective_date
  );


 hr_utility.set_location('Calling GHR_CPDF_CHECK6.chk_service_comp_date '|| l_proc, 116);

GHR_CPDF_CHECK6.chk_service_comp_date
  (p_service_computation_date
  ,p_effective_date
  ,p_employee_date_of_birth
  ,p_duty_station_lookup_code
  ,p_first_noac_lookup_code
  ,p_credit_mil_svc
  ,p_submission_date
 );

 hr_utility.set_location('Calling GHR_CPDF_CHECK6.chk_social_security '|| l_proc, 117);

-- Added the parameter p_effective_date for Bug#5487271
GHR_CPDF_CHECK6.chk_Social_Security
  ( p_agency_subelement
   ,p_employee_National_ID
   ,p_personnel_officer_ID
   ,p_effective_date
  );

 hr_utility.set_location('Calling GHR_CPDF_CHECK6.chk_step_or_rate '|| l_proc, 118);
 l_step_or_rate := p_to_step_or_rate;
 l_rpa_step_or_rate := p_rpa_step_or_rate;
GHR_CPDF_CHECK6.chk_step_or_rate
  (l_step_or_rate
  ,l_pay_rate_determinant
  ,p_to_pay_plan
  ,p_to_grade_or_level
  ,p_first_action_noa_la_code1
  ,p_first_action_noa_la_code2
  ,p_Cur_Appt_Auth_1
  ,p_Cur_Appt_Auth_2
  ,p_effective_date
  ,l_rpa_step_or_rate
  );


 hr_utility.set_location('Calling GHR_CPDF_CHECK6.chk_supervisory_status '|| l_proc, 119);
GHR_CPDF_CHECK6.chk_supervisory_status
  (p_supervisory_status_code
  ,p_to_pay_plan
  ,p_effective_date
  );

 hr_utility.set_location('Calling GHR_CPDF_CHECK6.chk_tenure '|| l_proc, 120);
GHR_CPDF_CHECK6.chk_tenure
  (p_tenure_group_code
  ,p_to_pay_plan
  ,p_first_action_noa_la_code1
  ,p_first_action_noa_la_code2
  ,p_first_noac_lookup_code
  ,p_Cur_Appt_Auth_1
  ,p_Cur_Appt_Auth_2
  ,p_effective_date
  );

 hr_utility.set_location('Calling GHR_CPDF_CHECK6.chk_veterans_pref '|| l_proc, 121);
GHR_CPDF_CHECK6.chk_veterans_pref
  (p_veterans_preference_code
  ,p_first_action_noa_la_code1
  ,p_first_action_noa_la_code2
  );

 hr_utility.set_location('Calling GHR_CPDF_CHECK6.chk_veterans_status '|| l_proc, 122);

GHR_CPDF_CHECK6.chk_veterans_status
  (p_veterans_status_code
  ,p_veterans_preference_code
  ,p_first_noac_lookup_code
  ,p_agency_subelement
  ,p_First_Action_NOA_LA_Code1
  );

 hr_utility.set_location('Calling GHR_CPDF_CHECK6.chk_work_schedule '|| l_proc, 123);
GHR_CPDF_CHECK6.chk_work_schedule
  (p_work_schedule_code
  ,p_first_noac_lookup_code
  );

 hr_utility.set_location('Calling GHR_CPDF_CHECK6.chk_degree_attained '|| l_proc, 124);
GHR_CPDF_CHECK6.chk_degree_attained
   ( p_effective_date
    ,p_year_degree_attained
    ,p_as_of_date
   );


/* Calling GHR_CPDF_CHECK7 */
--
 hr_utility.set_location('Calling GHR_CPDF_CHECK7.chk_prior_basic_pay '|| l_proc, 125);
--

--8850376 removed prior prd for Return to duty as all latest values are passed
GHR_CPDF_CHECK7.chk_prior_basic_pay
  (p_prior_pay_plan
  ,l_pay_rate_determinant
  ,p_prior_pay_rate_det_code
  ,p_prior_basic_pay
  ,p_retain_pay_plan
  ,p_retain_grade
  ,p_retain_step
  ,p_agency_subelement
  ,p_prior_grade_or_level
  ,p_prior_step_or_rate
  ,p_prior_pay_basis
  ,p_first_noac_lookup_code
  ,p_to_basic_pay
  ,p_to_pay_basis
  ,p_effective_date
  ,p_prior_effective_date
  );

 hr_utility.set_location('Calling GHR_CPDF_CHECK7.chk_locality_adj '|| l_proc, 126);
GHR_CPDF_CHECK7.chk_locality_adj
  (p_to_pay_plan	              => p_to_pay_plan
  ,p_to_basic_pay		        => p_to_basic_pay
  ,p_pay_rate_determinant_code  => l_pay_rate_determinant
  ,p_retained_pay_plan	        => p_retain_pay_plan
  ,p_Prior_Pay_Plan             => p_prior_pay_plan
  ,p_prior_pay_rate_det_code    => p_prior_pay_rate_det_code
  ,p_locality_pay_area          => p_locality_pay_area
  ,p_to_locality_adj            => p_to_locality_adj
  ,p_effective_date             => p_effective_date
  ,p_as_of_date                 => p_as_of_date
  ,p_first_noac_lookup_code     => p_first_noac_lookup_code
  ,p_agency_subelement          => p_agency_subelement
  ,p_duty_station_Code          => p_Duty_Station_Lookup_Code
  ,p_special_pay_table_id       => p_special_pay_table_id     --Bug# 5745356(upd50)
  );

--
-- Get the session variable to check whether the action is correction
-- If correction skip the prior locality edits as the prior_locality_pay_area
-- and prior_duty_station_id values is incorrect. In anycase the original
-- pa request would have passed through them.
-- Bug #709282
--

--8850376 removed prior prd for Return to duty as all latest values are passed

 hr_utility.set_location('Calling GHR_CPDF_CHECK7.chk_prior_locality_adj '|| l_proc, 127);
ghr_history_api.get_g_session_var(l_session);
If l_session.noa_id_correct is null then
   GHR_CPDF_CHECK7.chk_prior_locality_adj
     (p_to_pay_plan                   => p_to_pay_plan
     ,p_to_basic_pay                  => p_to_basic_pay
     ,p_Prior_Pay_Plan                => p_prior_pay_plan
     ,p_pay_rate_determinant_code     => l_pay_rate_determinant
     ,p_retained_pay_plan             => p_retain_pay_plan
     ,p_prior_pay_rate_det_code       => p_prior_pay_rate_det_code
     ,p_locality_pay_area             => p_locality_pay_area
     ,p_prior_locality_pay_area       => p_prior_locality_pay_area
     ,p_prior_basic_pay               => p_prior_basic_pay
     ,p_to_locality_adj               => p_to_locality_adj
     ,p_prior_locality_adj            => p_prior_locality_adj
     ,p_prior_loc_adj_effective_date  => p_prior_loc_adj_effective_date
     ,p_first_noac_lookup_code        => p_first_noac_lookup_code
     ,p_as_of_date                    => p_as_of_date
     ,p_agency_subelement             => p_agency_subelement
     ,p_prior_duty_station            => p_prior_duty_station
     ,p_effective_date                => p_effective_date
     );
end if;

/* Calling GHR_CPDF_CHECK8 */
--
 hr_utility.set_location('Calling GHR_CPDF_CHECK8.basic_pay '|| l_proc, 130);
--

GHR_CPDF_CHECK8.basic_pay
  (p_to_pay_plan
  ,l_pay_rate_determinant
  ,p_to_basic_pay
  ,p_retain_pay_plan
  ,p_retain_grade
  ,p_retain_step
  ,p_agency_subelement
  ,p_to_grade_or_level
  ,p_to_step_or_rate
  ,p_to_pay_basis
  ,p_first_action_noa_la_code1
  ,p_first_action_noa_la_code2
  ,p_first_noac_lookup_code
  ,p_effective_date
  ,p_occupation_code
  );

end call_CPDF_Check;

--
--
function get_basic_pay
   (table_name            in varchar2
    ,row_name             in varchar2
    ,column_name          in varchar2
    ,effective_date       in date)
RETURN NUMBER
IS
   basic_pay	number(10,2);
BEGIN
   SELECT  to_number(value) into basic_pay
   FROM    pay_user_columns                     udc,
           pay_user_rows_f                      udr,
           pay_user_tables                      udt,
           pay_user_column_instances_f          uci
   WHERE   udc.user_column_name = column_name
   AND     effective_date between
           uci.effective_start_date and
           uci.effective_end_date
   AND     effective_date between
           udr.effective_start_date and
           udr.effective_end_date
   AND     udr.row_low_range_or_name = row_name
   AND     udt.user_table_name = table_name
   AND     udr.user_table_id = udt.user_table_id
   AND     udc.user_table_id = udt.user_table_id
   AND     uci.user_row_id = udr.user_row_id
   AND     uci.user_column_id = udc.user_column_id;
return basic_pay;

EXCEPTION
   WHEN NO_DATA_FOUND
      THEN
         return null;
end get_basic_pay;


end GHR_CPDF_CHECK;

/

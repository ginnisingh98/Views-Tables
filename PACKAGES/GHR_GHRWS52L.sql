--------------------------------------------------------
--  DDL for Package GHR_GHRWS52L
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_GHRWS52L" AUTHID CURRENT_USER AS
/* $Header: ghrws52l.pkh 120.4.12000000.1 2007/01/18 14:16:37 appldev ship $ */
--

 g_bypass_cpdf                            boolean := FALSE;

 g_academic_discipline          		varchar2(30);
 g_Adj_Base_Pay                 		ghr_pa_requests.TO_ADJ_BASIC_PAY%type;
 g_Agency_Code                   		varchar2(30);
 g_agency_subelement		 		varchar2(30);
 g_as_of_date                     		date;
 g_Benefit_Amount              		varchar2(30);
 g_bargaining_unit_status_code   		ghr_pa_requests.BARGAINING_UNIT_STATUS%type;
 g_citizenship           			ghr_pa_requests.CITIZENSHIP%type;
 g_credit_mil_svc            			per_people_extra_info.pei_information5%type;
 g_Cur_Appt_Auth_1                    	per_people_extra_info.pei_information8%type;
 g_Cur_Appt_Auth_2                    	per_people_extra_info.pei_information9%type;
 g_Duty_Station_ID 				hr_location_extra_info.lei_information3%type;
 g_Duty_Station_Lookup_Code     		ghr_duty_stations_f.Duty_Station_Code%type;
 g_education_level              		ghr_pa_requests.EDUCATION_LEVEL%type;
 g_effective_date					ghr_pa_requests.EFFECTIVE_DATE%type;
 g_Employee_Date_of_Birth       		per_people_f.date_of_birth%type;
 g_Employee_First_Name          		ghr_pa_requests.EMPLOYEE_FIRST_NAME%type;
 g_Employee_Last_Name           		ghr_pa_requests.EMPLOYEE_LAST_NAME%type;
 g_employee_National_ID       		varchar2(30);
 g_fegli_code      				ghr_pa_requests.FEGLI%type;
 g_fers_coverage            			per_people_extra_info.pei_information3%type;
 g_First_Action_NOA_LA_Code1       		ghr_pa_requests.FIRST_ACTION_LA_CODE1%type;
 g_First_Action_NOA_LA_Code2       		ghr_pa_requests.FIRST_ACTION_LA_CODE2%type;
 g_First_NOAC_Lookup_Code       		varchar2(30);
 -- Bug#4486823 RRR Changes
 g_First_NOAC_Lookup_desc       		ghr_pa_requests.first_noa_desc%TYPE;
 g_flsa_category                		ghr_pa_requests.FLSA_CATEGORY%type;
 g_functional_class    				ghr_pa_requests.FUNCTIONAL_CLASS%type;
 g_health_plan	 	        		varchar2(30);
 g_Handicap                     		per_people_extra_info.pei_information11%type;
 g_Indiv_Award            			varchar2(30);
 g_locality_pay_area	                  ghr_locality_pay_areas_f.Locality_Pay_Area_Code%type;
 g_Occupation_code                   	ghr_pa_requests.to_occ_code%type;
 g_One_Time_Payment_Amount      		ghr_pa_requests.AWARD_AMOUNT%type;
 g_Organ_Component              		per_position_extra_info.poei_information5%type;
 g_pay_rate_determinant_code    		ghr_pa_requests.PAY_RATE_DETERMINANT%type;
 g_Personnel_Officer_ID           		per_position_extra_info.poei_information3%type;
 g_Position_Occ_Code            		ghr_pa_requests.POSITION_OCCUPIED%type;
 g_Prior_Basic_Pay           			varchar2(30); --number;
 g_prior_duty_station    			varchar2(30);
 g_Prior_Grade_Or_Level      			per_grade_definitions.segment2%type;
 g_Prior_Locality_Adj        			varchar2(30); --number;
 g_prior_locality_pay_area			varchar2(30);
 g_Prior_Occupation_code          		per_job_definitions.segment1%type;
 g_Prior_Pay_Basis  		  		per_position_extra_info.poei_information6%type;
 g_Prior_Pay_Plan            			per_grade_definitions.segment1%type;
 g_Prior_Pay_Rate_Det_Code      		per_assignment_extra_info.aei_information6%type;
 g_Prior_Step_Or_Rate        			per_assignment_extra_info.aei_information3%type;
 g_prior_work_schedule_code       		varchar2(30);
 g_Production_Date          			date;
 g_Race_National_Region         		per_people_extra_info.pei_information5%type;
 g_rating_of_record_level 			varchar2(30);
 g_rating_of_record_pattern			varchar2(30);
 g_rating_of_record_period			varchar2(30);
 g_retain_grade					per_people_extra_info.pei_information3%type;
 g_retain_pay_plan				per_people_extra_info.pei_information5%type;
 g_retain_step					per_people_extra_info.pei_information4%type;
 g_temp_step					per_people_extra_info.pei_information9%type;
 g_fw_annualize                         varchar2(1);
 g_Retirement_Plan_Code         		ghr_pa_requests.RETIREMENT_PLAN%type;
 g_Retention_Allowance          		varchar2(30);
 g_Second_NOAC_Lookup_code              varchar2(30);
 g_Service_Computation_Date     		ghr_pa_requests.SERVICE_COMP_DATE%type;
 g_Sex                          		per_people_f.sex%type;
 g_special_pay_table_id           		per_position_extra_info.poei_information5%type;
 g_staffing_differential          		varchar2(30);
 g_submission_date                		date;
 g_supervisory_differential       		varchar2(30);
 g_Supervisory_Status_Code      		ghr_pa_requests.SUPERVISORY_STATUS%type;
 g_Tenure_Group_Code            		ghr_pa_requests.TENURE%type;
 g_To_Basic_Pay                 		varchar2(30); -- ghr_pa_requests.TO_BASIC_PAY%type;
 g_To_Grade_Or_Level            		ghr_pa_requests.TO_GRADE_OR_LEVEL%type;
 g_To_Locality_Adj              		varchar2(30);  --ghr_pa_requests.TO_LOCALITY_ADJ%type;
 g_To_Pay_Basis                 		ghr_pa_requests.TO_PAY_BASIS%type;
 g_To_Pay_Plan                  		ghr_pa_requests.TO_PAY_PLAN%type;
 g_To_Pay_Status                        varchar2(30);
 g_To_Position_ID                       ghr_pa_requests.TO_Position_ID%type;
 g_To_Step_Or_Rate              		ghr_pa_requests.TO_STEP_OR_RATE%type;
 g_Veterans_Preference_Code       		ghr_pa_requests.VETERANS_PREFERENCE%type;
 g_Veterans_Status_Code         		ghr_pa_requests.VETERANS_STATUS%type;
 g_work_schedule_code             		ghr_pa_requests.WORK_SCHEDULE%type;
 g_year_degree_attained         		ghr_pa_requests.YEAR_DEGREE_ATTAINED%type;
 g_race_ethnic_info						varchar2(30); -- -- Bug 4724337 Race or National Origin changes

--
--
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
  );

--
procedure CPDF_Parameter_Check;
--
end GHR_GHRWS52L;

 

/

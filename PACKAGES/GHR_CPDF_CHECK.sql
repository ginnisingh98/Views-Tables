--------------------------------------------------------
--  DDL for Package GHR_CPDF_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CPDF_CHECK" AUTHID CURRENT_USER AS
/* $Header: ghcpdf00.pkh 120.3.12010000.1 2008/07/28 10:25:11 appldev ship $ */

-- <Precedure Info>
-- Name:
--    call_CPDF_Check
-- Note:
--
--

PROCEDURE call_CPDF_Check
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
  ,p_First_Action_NOA_LA_Code1    	in varchar2
  ,p_First_Action_NOA_LA_Code2     	in varchar2
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
  -- Bug 4753117 added new parameter
  ,p_rating_of_record_per_starts        in varchar2   -- Non-SF52 Data Item
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
 );

FUNCTION get_basic_pay
   (table_name                          in varchar2
    ,row_name                           in varchar2
    ,column_name                        in varchar2
    ,effective_date                     in date)
RETURN NUMBER;

end GHR_CPDF_CHECK;

/

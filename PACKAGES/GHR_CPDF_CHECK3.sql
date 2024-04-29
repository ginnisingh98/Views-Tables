--------------------------------------------------------
--  DDL for Package GHR_CPDF_CHECK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CPDF_CHECK3" AUTHID CURRENT_USER as
/* $Header: ghcpdf03.pkh 120.2.12010000.1 2008/07/28 10:25:45 appldev ship $ */


-- <Precedure Info>
-- Name:
--   Nature of Action
-- Sections in CPDF:
--   C37 - C40
-- Note:
--
--



procedure chk_Nature_of_Action
  (p_First_NOAC_Lookup_Code       in varchar2
  ,p_Second_NOAC_Lookup_code      in varchar2
  ,p_First_Action_NOA_Code1       in varchar2
  ,p_First_Action_NOA_Code2       in varchar2
  ,p_Cur_Appt_Auth_1              in    varchar2  --non SF52 item
  ,p_Cur_Appt_Auth_2              in    varchar2  --non SF52 item
  ,p_Employee_Date_of_Birth       in date
  ,p_Duty_Station_Lookup_Code     in varchar2
  ,p_Employee_First_Name          in varchar2
  ,p_Employee_Last_Name           in varchar2
  ,p_Handicap                     in varchar2   --non SF52 item
  ,p_Organ_Component              in varchar2   --non SF52 item
  ,p_Personal_Office_ID           in varchar2   --non SF52 item
  ,p_Position_Occ_Code            in varchar2
  ,p_Race_National_Region         in varchar2   --non SF52 item
  ,p_Retirement_Plan_Code         in varchar2
  ,p_Service_Computation_Date     in Date
  ,p_Sex                          in varchar2   --non SF52 item
  ,p_Supervisory_Status_Code      in varchar2
  ,p_Tenure_Group_Code            in varchar2
  ,p_Veterans_Pref_Code           in varchar2
  ,p_Veterans_Status_Code         in varchar2
  ,p_Occupation                   in varchar2   --non SF52 item
  ,p_To_Pay_Basis                 in varchar2
  ,p_To_Grade_Or_Level            in varchar2
  ,p_To_Pay_Plan                  in varchar2
  ,p_pay_rate_determinant_code    in varchar2
  ,p_To_Basic_Pay                 in varchar2
  ,p_To_Step_Or_Rate              in varchar2
  ,p_Work_Sche_Code               in varchar2
  ,p_Prior_Occupation             in varchar2   --non SF52 item
  ,p_Prior_To_Pay_Basis           in varchar2   --non SF52 item
  ,p_Prior_To_Grade_Or_Level      in varchar2   --non SF52 item
  ,p_Prior_To_Pay_Plan            in varchar2   --non SF52 item
  ,p_Prior_Pay_Rate_Det_Code      in varchar2   --non SF52 item
  ,p_Prior_To_Basic_Pay           in varchar2   --non SF52 item
  ,p_Prior_To_Step_Or_Rate        in varchar2   --non SF52 item
  ,p_Prior_Work_Sche_Code         in varchar2   --non SF52 item
  ,p_prior_duty_station           in varchar2
  ,p_Retention_Allowance          in varchar2   --non SF52 item
  ,p_Staff_Diff                   in varchar2   --non SF52 item
  ,p_Supervisory_Diff             in varchar2   --non SF52 item
  ,p_To_Locality_Adj              in varchar2
  ,p_Prior_To_Locality_Adj        in varchar2   --non SF52 item
  ,p_noa_family_code              in varchar2
  ,p_effective_date               in date
  ,p_agency_subelement            in varchar2
  ,p_ethnic_race_info             in varchar2
  );

-- <Precedure Info>
-- Name:
--   Occupation
-- Sections in CPDF:
--   C40 - C41
-- Note:
--
--

procedure chk_occupation
  (p_to_pay_plan              in varchar2
  ,p_occ_code                 in varchar2
  ,p_agency_sub               in varchar2 	-- non SF52 item
  ,p_duty_station_lookup_code in varchar2
,p_effective_date           in date

);

-- -- Name:
--   Pay Basis
-- Sections in CPDF:
--   C42
-- Note:
--
--

procedure chk_pay_basis
  (p_to_pay_plan            in    varchar2
  ,p_pay_basis              in    varchar2
  ,p_basic_pay              in    varchar2
  ,p_agency_subelement      in    varchar2   --non SF52 item
  ,p_occ_code               in    varchar2 --Bug# 5745356
  ,p_effective_date         in    date
  ,p_pay_rate_determinant_code   in varchar2
   );

-- Name:
--   Pay Grade
-- Sections in CPDF:
--   C43 - C46
-- Note:
--

procedure chk_pay_grade
  (p_to_pay_plan               	in varchar2
  ,p_to_grade_or_level         	in varchar2
  ,p_pay_rate_determinant_code 	in varchar2
  ,p_first_action_noa_la_code1 	in varchar2
  ,p_first_action_noa_la_code2 	in varchar2
  ,p_First_NOAC_Lookup_Code       	in varchar2
  ,p_Second_NOAC_Lookup_code        in varchar2
  ,p_effective_date                 in date
);



-- <Precedure Info>
-- Name:
--   Pay Plan
-- Sections in CPDF:
--   C-47 - C-50
-- Note:
--

procedure chk_pay_plan
  (p_to_pay_plan                  in    varchar2
  ,p_agency_subelement            in    varchar2       --non SF52
  ,p_pers_office_identifier       in    varchar2       --non SF52
  ,p_to_grade_or_level            in    varchar2
  ,p_first_action_noa_la_code1    in    varchar2
  ,p_first_action_noa_la_code2    in    varchar2
  ,p_Cur_Appt_Auth_1              in    varchar2  --non SF52 item
  ,p_Cur_Appt_Auth_2              in    varchar2  --non SF52 item
  ,p_first_NOAC_Lookup_Code       in    varchar2
  ,p_Pay_Rate_Determinant_Code    in    varchar2
  ,p_Effective_Date               in    date
  ,p_prior_pay_plan               in    varchar2       --non SF52
  ,p_prior_grade                  in    varchar2       --non SF52
  ,p_Agency                       in    varchar2       --non SF52
  ,p_Supervisory_status_code      in    varchar2
  );
--
-- <Precedure Info>
-- Name:
--   Pay Rate Determinant
-- Sections in CPDF:
--   C-51, C-52
-- Note:
--

procedure chk_pay_rate_determinant
  (p_pay_rate_determinant_code       	in varchar2
  ,p_prior_pay_rate_det_code 		in varchar2  --non SF52
  ,p_to_pay_plan                     	in varchar2
  ,p_first_noa_lookup_code           	in varchar2
  ,p_duty_station_lookup_code        	in varchar2
  ,p_agency                          	in varchar2
  ,p_effective_date                     in date
);

end GHR_CPDF_CHECK3;

/

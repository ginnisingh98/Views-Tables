--------------------------------------------------------
--  DDL for Package GHR_CPDF_CHECK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CPDF_CHECK2" AUTHID CURRENT_USER as
/* $Header: ghcpdf02.pkh 120.2.12010000.1 2008/07/28 10:25:40 appldev ship $ */

-- <Precedure Info>
-- Name:
--   instructional program
-- Sections in CPDF:
--   C-8 - C-9
-- Note:
--

procedure chk_instructional_pgm
  (p_education_level              in varchar2
  ,p_academic_discipline          in varchar2
  ,p_year_degree_attained         in varchar2
  ,p_first_noac_lookup_code       in varchar2
  ,p_effective_date               in date
  ,p_tenure_group_code            in varchar2
  ,p_to_pay_plan                  in varchar2
  ,p_employee_date_of_birth  	    in Date
  );

-- <Precedure Info>
-- Name:
--   Award_Amount
-- Sections in CPDF:
--   C-10, C-11
-- Note:
--

procedure chk_Award_Amount
(  p_First_NOAC_Lookup_Code       in varchar2
  -- Bug#4486823 RRR Changes
  ,p_First_NOAC_Lookup_desc       in varchar2
  ,p_One_Time_Payment_Amount      in number
  ,p_To_Basic_Pay                 in number
  ,p_Adj_Base_Pay                 in number
  ,p_First_Action_NOA_LA_Code1    in varchar2
  ,p_First_Action_NOA_LA_Code2    in varchar2
  ,p_to_pay_plan                  in varchar2
  ,p_effective_date               in date
);


--
-- <Precedure Info>
-- Name:
--   Benefit Amount
-- Sections in CPDF:
--   C-11
-- Note:
--

procedure chk_Benefit_Amount
  (p_First_NOAC_Lookup_Code      in varchar2
  ,p_Benefit_Amount              in varchar2   --non SF52
  ,p_effective_date              in date
);


-- <Precedure Info>
-- Name:
--   Current Appointment Authority
-- Sections in CPDF:
--   C-12 - C-19
-- Note:
--

procedure chk_Cur_Appt_Auth
  (p_First_Action_NOA_LA_Code1    in varchar2
  ,p_First_Action_NOA_LA_Code2    in varchar2
  ,p_Cur_Appt_Auth_1              in varchar2  --non SF52 item
  ,p_Cur_Appt_Auth_2              in varchar2  --non SF52 item
  ,p_Agency_Subelement            in varchar2          --non SF52
  ,p_To_OCC_Code                  in varchar2
  ,p_First_NOAC_Lookup_Code       in varchar2
  ,p_Position_Occupied_Code       in varchar2
  ,p_To_Pay_Plan                  in varchar2
  ,p_Handicap                     in varchar2          --non SF52
  ,p_Tenure_Goupe_Code            in varchar2
  ,p_To_Grade_Or_Level            in varchar2
  ,p_Vet_Pref_Code                in varchar2
  ,p_Duty_Station_Lookup_Code     in varchar2
  ,p_Service_Computation_Date     in Date
  ,p_effective_date               in date
  );

--
-- <Precedure Info>
-- Name:
--   Date_of_Birth
-- Sections in CPDF:
--   C-20
-- Note:
--

procedure chk_Date_of_Birth
  ( p_First_NOAC_Lookup_Code   in varchar2
   ,p_Effective_Date           in date
   ,p_Employee_Date_of_Birth   in date
   ,p_Duty_Station_Lookup_Code in varchar2
   ,p_as_of_date               in date
  );


--
--
-- <Precedure Info>
-- Name:
--   Duty Station
-- Sections in CPDF:
--   C-20, C-21
-- Note:
--

procedure chk_duty_station
  (p_to_play_plan       		in varchar2
  ,p_agency_sub_element 		in varchar2
  ,p_duty_station_lookup  		in varchar2
  ,p_First_Action_NOA_LA_Code1 	in varchar2
  ,p_First_Action_NOA_LA_Code2 	in varchar2
  ,p_effective_date             in date
  );


--
-- <Precedure Info>
-- Name:
--   Education Level
-- Sections in CPDF:
--    C-21
-- Note:
--

procedure chk_Education_Level
  ( p_tenure_group_code        in varchar2
   ,p_education_level          in varchar2
   ,p_pay_plan                 in varchar2
  );

--
-- <Precedure Info>
-- Name:
--   Effective Date
-- Sections in CPDF:
--    C-22
-- Note:
--

procedure chk_effective_date
  ( p_First_NOAC_Lookup_Code   in varchar2
   ,p_Effective_Date           in date
   ,p_Production_Date          in date  -- Non SF52 item
  );



-- <Precedure Info>
-- Name:
--    Handicap
-- Sections in CPDF:
--   C-23
-- Note:
--

procedure chk_Handicap
  (p_First_Action_NOA_Code1 in varchar2
  ,p_First_Action_NOA_Code2 in varchar2
  ,p_First_NOAC_Lookup_Code in varchar2
  ,p_Effective_Date         in date --bug# 5619873
  ,p_Handicap               in varchar2   --non SF52 item
  );

--
-- <Precedure Info>
-- Name:
--   Individual/Group Award
-- Sections in CPDF:
--   C-23
-- Note:
--

procedure chk_indiv_Award
  (p_First_NOAC_Lookup_Code in varchar2
  ,p_Indiv_Award            in varchar2
  ,p_effective_date         in date
  );

end GHR_CPDF_CHECK2;

/

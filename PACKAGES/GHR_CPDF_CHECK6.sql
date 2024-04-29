--------------------------------------------------------
--  DDL for Package GHR_CPDF_CHECK6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CPDF_CHECK6" AUTHID CURRENT_USER as
/* $Header: ghcpdf06.pkh 120.2.12010000.2 2009/03/10 13:29:12 utokachi ship $ */


--
-- <Precedure Info>
-- Name:
--   Prior Work Schedule
-- Sections in CPDF:
--   C74 - C75
-- Note:
--

procedure chk_prior_work_schedule
  (p_prior_work_schedule      in varchar2   --non SF52
  ,p_work_schedule_code       in varchar2
  ,p_first_noac_lookup_code   in varchar2
  );


-- Race or National Origin
-- <Precedure Info>
-- Name:
--   Race or National Origin
-- Sections in CPDF:
--   C75 - C76
-- Note:
--

procedure chk_race_or_natnl_origin
  (p_race_or_natnl_origin       in varchar2   --non SF52
  ,p_duty_station_lookup_code   in varchar2
  ,p_ethnic_race_info           in varchar2
  ,p_first_action_noa_la_code1  in varchar2
  ,p_first_action_noa_la_code2  in varchar2
  ,p_effective_date             in date
  );



-- <Precedure Info>
-- Name:
--   Prior Duty Station
-- Sections in CPDF:
--   C87
-- Note:
--

procedure chk_prior_duty_station
  (p_prior_duty_station    	in varchar2
  ,p_agency_subelement 		in varchar2
  );


--
-- <Precedure Info>
-- Name:
--   Retention Allowance
-- Sections in CPDF:
--   C88
-- Note:
--

 procedure chk_retention_allowance
  (p_retention_allowance             in varchar2   --non SF52
  ,p_to_pay_plan                     in varchar2
  ,p_to_basic_pay                    in varchar2
  ,p_first_noac_lookup_code          in varchar2
  ,p_first_action_noa_la_code1       in varchar2
  ,p_first_action_noa_la_code2       in varchar2
  ,p_effective_date                  in date --Bug# 8309414
  );


--
-- <Precedure Info>
-- Name:
--   Staffing Differential
-- Sections in CPDF:
--   C89
-- Note:
--

procedure chk_staffing_differential
  (p_staffing_differential        in varchar2
  ,p_first_noac_lookup_code       in varchar2
  ,p_first_action_noa_la_code1    in varchar2
  ,p_first_action_noa_la_code2    in varchar2
  );


--
-- <Precedure Info>
-- Name:
--   Supervisor Differential
-- Sections in CPDF:
--   C89
-- Note:
--
procedure chk_supervisory_differential
  (p_supervisory_differential             in varchar2  --non SF52
  ,p_first_noac_lookup_code               in varchar2
  ,p_first_action_noa_la_code1            in varchar2
  ,p_first_action_noa_la_code2            in varchar2
  ,p_effective_date                       in date
  );


--
-- <Precedure Info>
-- Name:
--   Service Computation Date
-- Sections in CPDF:
--   C90
-- Note:
--

procedure chk_service_comp_date
  (p_service_computation_date  in date
  ,p_effective_date            in date
  ,p_employee_date_of_birth    in date
  ,p_duty_station_lookup_code  in varchar2
  ,p_first_noac_lookup_code    in varchar2
  ,p_credit_mil_svc            in varchar2  --non SF52
  ,p_submission_date           in date      --non SF52
 );



--
--
-- <Precedure Info>
-- Name:
--   Social Security
-- Sections in CPDF:
--   Note
-- Note:
--


procedure chk_Social_Security
  ( p_agency_sub                 in varchar2   --non SF52
   ,p_employee_National_ID       in varchar2
   ,p_personnel_officer_ID       in varchar2   --non SF52
   ,p_effective_date             in date       --Bug 5487271
  );

--
-- <Precedure Info>
-- Name:
--   Step or Rate
-- Sections in CPDF:
--   C91 - C94
-- Note:
--
procedure chk_step_or_rate
  (p_step_or_rate              in varchar2
  ,p_pay_rate_determinant      in varchar2
  ,p_to_pay_plan               in varchar2
  ,p_to_grade_or_level         in varchar2
  ,p_first_action_noa_la_code1 in varchar2
  ,p_first_action_noa_la_code2 in varchar2
  ,p_Cur_Appt_Auth_1           in varchar2  --non SF52 item
  ,p_Cur_Appt_Auth_2           in varchar2  --non SF52 item
  ,p_effective_date            in date
  ,p_rpa_step_or_rate       in varchar2
  );

--
-- <Precedure Info>
-- Name:
--   Supervisory Status
-- Sections in CPDF:
--   C95
-- Note:
--
procedure chk_supervisory_status
  (p_supervisory_status_code in varchar2
  ,p_to_pay_plan             in varchar2
  ,p_effective_date          in date
  );


--
-- <Precedure Info>
-- Name:
--   Tenure
-- Sections in CPDF:
--   C96 - C98
-- Note:
--

procedure chk_tenure
  (p_tenure_group_code         in varchar2
  ,p_to_pay_plan               in varchar2
  ,p_first_action_noa_la_code1 in varchar2
  ,p_first_action_noa_la_code2 in varchar2
  ,p_first_noac_lookup_code    in varchar2
  ,p_Cur_Appt_Auth_1           in varchar2  --non SF52 item
  ,p_Cur_Appt_Auth_2           in varchar2  --non SF52 item
  ,p_effective_date            in date
  );

--
--
-- <Precedure Info>
-- Name:
--   Veterans Preference
-- Sections in CPDF:
--   C99
-- Note:
--
procedure chk_veterans_pref
  (p_veterans_preference_code 	in varchar2
  ,p_first_action_noa_la_code1 	in varchar2
  ,p_first_action_noa_la_code2 	in varchar2
  );


--
-- <Precedure Info>
-- Name:
--   Veterans Status
-- Sections in CPDF:
--   C99
-- Note:
--
procedure chk_veterans_status
  (p_veterans_status_code     	in varchar2
  ,p_veterans_preference_code 	in varchar2
  ,p_first_noac_lookup_code     in varchar2
  ,p_agency_sub                         in varchar2   --non SF52
  ,p_first_action_noa_la_code1          in varchar2

  );


--
-- <Precedure Info>
-- Name:
--   Work Schedule
-- Sections in CPDF:
--   C99
-- Note:
--
procedure chk_work_schedule
  (p_work_schedule_code     in varchar2
  ,p_first_noac_lookup_code in varchar2
  );

procedure chk_degree_attained
   ( p_effective_date       in date
    ,p_year_degree_attained in varchar2
    ,p_as_of_date           in date
   );

End GHR_CPDF_CHECK6;

/

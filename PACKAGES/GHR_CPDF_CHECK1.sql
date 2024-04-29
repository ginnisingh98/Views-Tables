--------------------------------------------------------
--  DDL for Package GHR_CPDF_CHECK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CPDF_CHECK1" AUTHID CURRENT_USER as
/* $Header: ghcpdf01.pkh 120.4.12010000.1 2008/07/28 10:25:32 appldev ship $ */

-- <Precedure Info>
-- Name:
--   bargaining unit
-- Sections in CPDF:
--   B8
-- Note:
--

procedure chk_bargaining_unit
  (p_to_pay_plan                   in varchar2
  ,p_agency_sub_element            in varchar2     --non SF52
  ,p_bargaining_unit_status_code   in varchar2
  );

-- <Precedure Info>
-- Name:
--   Federal Employees Group Life Insurance
-- Sections in CPDF:
--   B16
-- Note:
--

procedure chk_fegli
  (p_to_basic_pay    in  varchar2
  ,p_to_pay_plan     in  varchar2
  ,p_fegli_code      in  varchar2
  ,p_effective_date  in  date
  );

-- <Precedure Info>
-- Name:
--   FSLA Category
-- Sections in CPDF:
--   B17
-- Note:
--

procedure chk_fsla_category
  (p_duty_station_lookup_code     in    varchar2
  ,p_to_pay_plan                  in    varchar2
  ,p_agency_subelement            in    varchar2       --non SF52
  ,p_flsa_category                in    varchar2
  ,p_to_grade_or_level            in    varchar2
  ,p_effective_date               in    date --Bug# 5619873
  );


-- <Precedure Info>
-- Name:
--   Functional Classification-- Sections in CPDF:
--   B18
-- Note:
--
procedure chk_functional_classification
  (p_to_occ_code         in  varchar2
  ,p_functional_class    in  varchar2
  ,p_effective_date      in  date --Bug# 5619873
  );

-- <Precedure Info>
-- Name:
--   HEALTH PLAN
-- Sections in CPDF:
--   B19
-- Note:
--

 procedure chk_health_plan
  (p_health_plan	 	            	in	varchar2  --non SF52
  ,p_tenure_group_code		      	in	varchar2
  ,p_work_schedule_code 	      	in	varchar2
  ,p_to_pay_basis		            	in	varchar2
  ,p_to_pay_status		      	in	varchar2
  ,p_submission_date                    	in    date      --non SF52
  ,p_Cur_Appt_Auth_1                      in    varchar2
  ,p_Cur_Appt_Auth_2                      in    varchar2

  );

-- <Precedure Info>
-- Name:
--   Retained Grade
-- Sections in CPDF:
--   B30 - B32
-- Note:
--

procedure chk_retain_grade
  (p_retain_pay_plan               	in     varchar2   --non SF52
  ,p_retain_grade                  	in     varchar2   --non SF52
  ,p_pay_rate_determinant_code     	in     varchar2
  ,p_effective_date					in	   date
  );


-- <Precedure Info>
-- Name:
--   Retained Pay Plan
-- Sections in CPDF:
--    B32
-- Note:
--

procedure chk_retain_pay_plan
  (p_retain_grade      			in varchar2   --non SF52
  ,p_retain_pay_plan   			in varchar2   --non SF52
  ,p_retain_step       			in varchar2   --non SF52
  ,p_to_pay_plan       			in varchar2
,p_pay_rate_determinant_code          in varchar2
  ,p_effective_date                     in date

  );

--
-- <Precedure Info>
-- Name:
--   Retained Step
-- Sections in CPDF:
--    B33
-- Note:
--

procedure chk_retain_step
  (p_pay_rate_determinant_code   in  varchar2
  ,p_first_action_noa_la_code1   in  varchar2
  ,p_first_action_noa_la_code2   in  varchar2
  ,p_Cur_Appt_Auth_1                   in varchar2  --non SF52 item
  ,p_Cur_Appt_Auth_2                   in varchar2  --non SF52 item
  ,p_retain_pay_plan             in  varchar2  --non SF52
  ,p_retain_grade                in  varchar2  --non SF52
  ,p_retain_step                 in  varchar2  --non SF52
  ,p_effective_date              in date
  );

-- -- <Precedure Info>
-- Name:
--   Retirement Plan
-- Sections in CPDF:
--    B33,B34
-- Note:
--

procedure chk_retirement_plan
  (p_retirement_plan_code     in  varchar2
  ,p_fers_coverage            in  varchar2  --non SF52
  );


-- <Precedure Info>
-- Name:
--   special_pay_table_id
-- Sections in CPDF:
--    B49
-- Note:


procedure chk_special_pay_table_id
  (p_pay_rate_determinant_code       in varchar2
  ,p_to_pay_plan                     in varchar2
  ,p_special_pay_table_id            in varchar2 --non SF52
  -- FWFA Changes Bug#4444609
  ,p_effective_date                  in date
  -- FWFA Changes
  );

--
-- <Precedure Info>
-- Name:
--   U.S. Citizenship
-- Sections in CPDF:
--    B56
-- Note:

procedure chk_us_citizenship
  (p_citizenship           		in   varchar2
  ,p_duty_station_lookup_code 	in   varchar2
  );

procedure chk_century_info (
   p_date_of_birth                  in   date
  ,p_effective_date                 in   date
  ,p_Service_Computation_Date       in   date
  ,p_year_degree_attained           in   varchar2
  ,p_rating_of_record_period        in   varchar2
  ,p_rating_of_record_per_starts    in   varchar2
  );


end GHR_CPDF_CHECK1;

/

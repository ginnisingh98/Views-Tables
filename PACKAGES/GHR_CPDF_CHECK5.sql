--------------------------------------------------------
--  DDL for Package GHR_CPDF_CHECK5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CPDF_CHECK5" AUTHID CURRENT_USER as
/* $Header: ghcpdf05.pkh 120.3.12010000.1 2008/07/28 10:25:54 appldev ship $ */

-- <Precedure Info>
-- Name:
--   RATING OF RECORD
-- Sections in CPDF:
--   C53
-- Note:
--
--


procedure chk_rating_of_rec
  (p_rating_of_record_level 	    in 	varchar2  -- non SF52
  ,p_rating_of_record_pattern	    in	varchar2  -- non SF52
  ,p_rating_of_record_period	    in	varchar2  -- non SF52
  ,p_rating_of_record_per_starts    in	varchar2  -- non SF52
  ,p_first_noac_lookup_code         in  varchar2
  ,p_effective_date                 in  date
  ,p_submission_date                in  date         -- non SF52
  ,p_to_pay_plan                    in  varchar2
  );



--
-- <Precedure Info>
-- Name:
--   Position Occupied
-- Sections in CPDF:
--   C53, C54
-- Note:
--
--


procedure chk_position_occupied
  (p_position_occupied_code 	in varchar2
  ,p_to_pay_plan            	in varchar2
  ,p_first_noac_lookup_code   in varchar2
  ,p_effective_date           in date
  );

--
-- <Precedure Info>
-- Name:
--   Prior Occupation
-- Sections in CPDF:
--   C54, C55
-- Note:
--
procedure chk_prior_occupation
  (p_prior_occupation_code         in  varchar2  --non SF52
  ,p_occupation_code               in  varchar2  --non SF52
  ,p_first_noac_lookup_code        in  varchar2
  ,p_prior_pay_plan                in  varchar2  --non SF52
  ,p_agency_subelement             in  varchar2  --non SF52
  ,p_effective_date                in  date
  );


-- <Precedure Info>
-- Name:
--   Prior Pay Basis
-- Sections in CPDF:
--   C56
-- Note:
--
procedure chk_prior_pay_basis
  (p_prior_pay_basis      in  varchar2  --non SF52
  ,p_prior_pay_plan       in  varchar2  --non SF52
  ,p_agency_subelement    in  varchar2  --non SF52
  ,p_prior_basic_pay      in  varchar2  --non SF52
  ,p_effective_date       in  date
  ,p_prior_effective_date in date
  ,p_prior_pay_rate_det_code in varchar2
  );


--
-- <Precedure Info>
-- Name:
--   Prior Grade
-- Sections in CPDF:
--   C57 - C62
-- Note:
--
procedure chk_prior_grade
  (p_prior_pay_plan         	in  varchar2  --non SF52
  ,p_grade_or_level         	in  varchar2
  ,p_prior_grade            	in  varchar2  --non SF52
  ,p_to_pay_plan            	in  varchar2
  ,p_first_noac_lookup_code 	in  varchar2
  ,p_prior_pay_rate_det_code	in  varchar2  --non SF52
  ,p_effective_date           in  date
  );


--
-- <Precedure Info>
-- Name:
--   Prior Pay Plan
-- Sections in CPDF:
--   C62
-- Note:
--
procedure chk_prior_pay_plan
  (p_prior_pay_plan            in  varchar2  --non SF52
  ,p_to_pay_plan               in  varchar2
  ,p_first_noac_lookup_code    in  varchar2
  --,p_prior_effective_date      in date --Bug# 6010943
  ,p_effective_date      in date -- add Bug# 6010943
  );



-- <Precedure Info>
-- Name:
--   Prior Pay Rate Determinant
-- Sections in CPDF:
--   C62 - C64
-- Note:
--


procedure chk_prior_pay_rate_determinant
  (p_prior_pay_rate_det_code    in varchar2       --non SF52 item
  ,p_pay_rate_determinant       in varchar2
  ,p_prior_pay_plan             in varchar2       --non SF52 item
  ,p_to_pay_plan                in varchar2
  ,p_agency                     in varchar2
  ,p_First_NOAC_Lookup_Code     in varchar2
  ,p_prior_duty_stn             in varchar2       --non SF52 item
  ,p_prior_effective_date       in date
  ,P_effective_date				in date           -- FWFA Change
  );


--
-- <Precedure Info>
-- Name:
--   Prior Step or Rate
-- Sections in CPDF:
--   C70 - C74
-- Note:
--

procedure chk_prior_step_or_rate
  (p_prior_step_or_rate         in varchar2    --non SF52
  ,p_first_noac_lookup_code     in varchar2
  ,p_to_step_or_rate            in varchar2
  ,p_pay_rate_determinant_code  in varchar2
  ,p_to_pay_plan                in varchar2
  ,p_prior_pay_rate_det_code    in varchar2    --non SF52
  ,p_prior_pay_plan             in varchar2    --non SF52
  ,p_prior_grade                in varchar2    --non SF52
 ,p_prior_effective_date       in date
 ,p_cur_appt_auth_1            in varchar2
  ,p_cur_appt_auth_2            in varchar2
  ,p_effective_date             in date


  );

End GHR_CPDF_CHECK5;

/

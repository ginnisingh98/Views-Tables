--------------------------------------------------------
--  DDL for Package GHR_CPDF_CHECK8
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CPDF_CHECK8" AUTHID CURRENT_USER as
/* $Header: ghcpdf08.pkh 120.0.12000000.1 2007/01/18 13:34:17 appldev noship $ */

--

-- <Precedure Info>
-- Name:
--     BASIC PAY
-- Sections in CPDF:
--   C76 - C82
-- Note:
--
--
procedure basic_pay
  (p_to_pay_plan			in	varchar2
  ,p_rate_determinant_code	        in	varchar2
  ,p_to_basic_pay			in	varchar2
  ,p_retained_pay_plan			in 	varchar2	/* Non-SF52 Data Item */
  ,p_retained_grade			in 	varchar2	/* Non-SF52 Data Item */
  ,p_retained_step			in	varchar2	/* Non-SF52 Data Item */
  ,p_agency_subelement			in	varchar2	/* Non-SF52 Data Item */
  ,p_to_grade_or_level			in	varchar2
  ,p_to_step_or_rate			in 	varchar2
  ,p_to_pay_basis				in 	varchar2
  ,p_first_action_noa_la_code1 	in	varchar2
  ,p_first_action_noa_la_code2	in	varchar2
  ,p_first_noac_lookup_code		in	varchar2
  ,p_effective_date			in    date
,p_occupation_code                           in  varchar2
  );

end GHR_CPDF_CHECK8;

 

/

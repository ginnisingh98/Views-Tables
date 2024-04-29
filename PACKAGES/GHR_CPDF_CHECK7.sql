--------------------------------------------------------
--  DDL for Package GHR_CPDF_CHECK7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CPDF_CHECK7" AUTHID CURRENT_USER as
/* $Header: ghcpdf07.pkh 120.1.12010000.1 2008/07/28 10:26:03 appldev ship $ */

-- <Precedure Info>
-- Name:
-- Prior BASIC PAY
-- Sections in CPDF:
--   C65 - C70
-- Note:
--
--
procedure chk_prior_basic_pay
  (p_prior_pay_plan			 	in	varchar2	/* Non-SF52 Data Item */
  ,p_pay_determinant_code                 in    varchar2
  ,p_prior_pay_rate_det_code		      in	varchar2	/* Non-SF52 Data Item */
  ,p_prior_basic_pay				in	varchar2	/* Non-SF52 Data Item */
  ,p_retained_pay_plan				in 	varchar2	/* Non-SF52 Data Item */
  ,p_retained_grade				in 	varchar2	/* Non-SF52 Data Item */
  ,p_retained_step				in	varchar2	/* Non-SF52 Data Item */
  ,p_agency_subelement				in	varchar2	/* Non-SF52 Data Item */
  ,p_prior_grade_or_level			in	varchar2	/* Non-SF52 Data Item */
  ,p_prior_step_or_rate				in 	varchar2	/* Non-SF52 Data Item */
  ,p_prior_pay_basis				in 	varchar2	/* Non-SF52 Data Item */
  ,p_first_noac_lookup_code			in  	varchar2
  ,p_to_basic_pay				      in	varchar2
  ,p_to_pay_basis				      in    varchar2
  ,p_effective_date				in	date
  ,p_prior_effective_date                 in    date
  );


--
-- <Precedure Info>
-- Name:
-- Locality Adjustment
-- Sections in CPDF:
--   C82 - C85
-- Note:
--
--
/* Table 25 contains up to a maximum of 3 percentages.
   The locality adjustment amount will pass the lookup if, as a percentage of basic pay,
   it represents any percentage shown for the locality area, with the "as of date" of the
   file falling within the date range, on Table 25.  (If a more percise check is needed,
   as is the case of area 41, a subsequent relationship edit will catch the error.)
   Locality pay is generated within CPDF according to the duty station.  For definitions,
   see the Guide to Personnel Data Standards. */

procedure chk_locality_adj
  (p_to_pay_plan				in  varchar2
  ,p_to_basic_pay                   in  varchar2
  ,p_pay_rate_determinant_code	in  varchar2
  ,p_retained_pay_plan			in  varchar2
  ,p_prior_pay_plan                 in  varchar2
  ,p_prior_pay_rate_det_code		in  varchar2	/* Non-SF52 Data Item */
  ,p_locality_pay_area			in  varchar2	/* Non-SF52 Data Item */
  ,p_to_locality_adj			in  varchar2
  ,p_effective_date			in  date
  ,p_as_of_date                     in  date            /* Non-SF52 */
  ,p_first_noac_lookup_code         in  varchar2
  ,p_agency_subelement              in  varchar2
  ,p_duty_station_code              in  varchar2
  ,p_special_pay_table_id            in varchar2 --Bug# 5745356(upd50)
  );


--
-- <Precedure Info>
-- Name:
-- PRIOR LOCALITY ADJUSTMENT
-- Sections in CPDF:
--   C86, C87
-- Note:
--

procedure chk_prior_locality_adj
  (p_to_pay_plan					in	varchar2
  ,p_to_basic_pay                         in    varchar2
  ,p_prior_pay_plan                       in    varchar2
  ,p_pay_rate_determinant_code		in	varchar2
  ,p_retained_pay_plan				in	varchar2
  ,p_prior_pay_rate_det_code			in	varchar2	/* Non-SF52 Data Item */
  ,p_locality_pay_area				in	varchar2	/* Non-SF52 Data Item */
  ,p_prior_locality_pay_area			in	varchar2	/* Non-SF52 Data Item */
  ,p_prior_basic_pay                      in    varchar2
  ,p_to_locality_adj				in	varchar2
  ,p_prior_locality_adj				in	varchar2	/* Non-SF52 Data Item */
  ,p_prior_loc_adj_effective_date         in    date
  ,p_first_noac_lookup_code			in	varchar2
  ,p_as_of_date                         	in    date            /* Non-SF52 */
  ,p_agency_subelement                    in    varchar2
  ,p_prior_duty_station                   in    varchar2
  ,p_effective_date                       in    date
  );

end GHR_CPDF_CHECK7;

/

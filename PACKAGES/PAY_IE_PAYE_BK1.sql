--------------------------------------------------------
--  DDL for Package PAY_IE_PAYE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_PAYE_BK1" AUTHID CURRENT_USER as
/* $Header: pyipdapi.pkh 120.9 2008/01/11 06:59:21 rrajaman noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ie_paye_details_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ie_paye_details_b
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_assignment_id                 in     number
  ,p_info_source                   in     varchar2
  ,p_tax_basis                     in     varchar2
  ,p_certificate_start_date        in     date
  ,p_tax_assess_basis              in     varchar2
  ,p_certificate_issue_date        in     date
  ,p_certificate_end_date          in     date
  ,p_weekly_tax_credit             in     number
  ,p_weekly_std_rate_cut_off       in     number
  ,p_monthly_tax_credit            in     number
  ,p_monthly_std_rate_cut_off      in     number
  ,p_tax_deducted_to_date          in     number
  ,p_pay_to_date                   in     number
  ,p_disability_benefit            in     number
  ,p_lump_sum_payment              in     number
  ,p_Tax_This_Employment	      in    Number
  ,p_Previous_Employment_Start_Dt	in	date
  ,p_Previous_Employment_End_Date	in	date
  ,p_Pay_This_Employment		in	number
  ,p_PAYE_Previous_Employer		in	varchar2
  ,p_P45P3_Or_P46				in	varchar2
  ,p_Already_Submitted			in	varchar2
  --,p_P45P3_Or_P46_Processed		in	varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ie_paye_details_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ie_paye_details_a
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_assignment_id                 in     number
  ,p_info_source                   in     varchar2
  ,p_tax_basis                     in     varchar2
  ,p_certificate_start_date        in     date
  ,p_tax_assess_basis              in     varchar2
  ,p_certificate_issue_date        in     date
  ,p_certificate_end_date          in     date
  ,p_weekly_tax_credit             in     number
  ,p_weekly_std_rate_cut_off       in     number
  ,p_monthly_tax_credit            in     number
  ,p_monthly_std_rate_cut_off      in     number
  ,p_tax_deducted_to_date          in     number
  ,p_pay_to_date                   in     number
  ,p_disability_benefit            in     number
  ,p_lump_sum_payment              in     number
  ,p_paye_details_id               in     number
  ,p_object_version_number         in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  ,p_Tax_This_Employment	      in    Number
  ,p_Previous_Employment_Start_Dt	in	date
  ,p_Previous_Employment_End_Date	in	date
  ,p_Pay_This_Employment		in	number
  ,p_PAYE_Previous_Employer		in	varchar2
  ,p_P45P3_Or_P46				in	varchar2
  ,p_Already_Submitted			in	varchar2
  --,p_P45P3_Or_P46_Processed		in	varchar2
  );
--
end pay_ie_paye_bk1;

/

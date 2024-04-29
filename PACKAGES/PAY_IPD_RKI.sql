--------------------------------------------------------
--  DDL for Package PAY_IPD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IPD_RKI" AUTHID CURRENT_USER as
/* $Header: pyipdrhi.pkh 120.0 2005/05/29 05:59:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_paye_details_id              in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_object_version_number        in number
  ,p_assignment_id                in number
  ,p_info_source                  in varchar2
  ,p_comm_period_no               in number
  ,p_tax_basis                    in varchar2
  ,p_certificate_start_date       in date
  ,p_certificate_end_date         in date
  ,p_tax_assess_basis             in varchar2
  ,p_weekly_tax_credit            in number
  ,p_weekly_std_rate_cut_off      in number
  ,p_monthly_tax_credit           in number
  ,p_monthly_std_rate_cut_off     in number
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_certificate_issue_date       in date
  );
end pay_ipd_rki;

 

/

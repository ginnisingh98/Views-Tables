--------------------------------------------------------
--  DDL for Package PAY_PSD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PSD_RKI" AUTHID CURRENT_USER as
/* $Header: pypsdrhi.pkh 120.0 2005/10/14 06:40 mseshadr noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_sii_details_id               in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_per_or_asg_id                in number
  ,p_business_group_id            in number
  ,p_contract_category            in varchar2
  ,p_object_version_number        in number
  ,p_emp_social_security_info     in varchar2
  ,p_old_age_contribution         in varchar2
  ,p_pension_contribution         in varchar2
  ,p_sickness_contribution        in varchar2
  ,p_work_injury_contribution     in varchar2
  ,p_labor_contribution           in varchar2
  ,p_health_contribution          in varchar2
  ,p_unemployment_contribution    in varchar2
  ,p_old_age_cont_end_reason      in varchar2
  ,p_pension_cont_end_reason      in varchar2
  ,p_sickness_cont_end_reason     in varchar2
  ,p_work_injury_cont_end_reason  in varchar2
  ,p_labor_fund_cont_end_reason   in varchar2
  ,p_health_cont_end_reason       in varchar2
  ,p_unemployment_cont_end_reason in varchar2
  ,p_program_id                   in number
  ,p_program_login_id             in number
  ,p_program_application_id       in number
  ,p_request_id                   in number
  );
end pay_psd_rki;

 

/

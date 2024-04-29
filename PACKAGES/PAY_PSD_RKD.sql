--------------------------------------------------------
--  DDL for Package PAY_PSD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PSD_RKD" AUTHID CURRENT_USER as
/* $Header: pypsdrhi.pkh 120.0 2005/10/14 06:40 mseshadr noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_sii_details_id               in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_per_or_asg_id_o              in number
  ,p_business_group_id_o          in number
  ,p_contract_category_o          in varchar2
  ,p_object_version_number_o      in number
  ,p_emp_social_security_info_o   in varchar2
  ,p_old_age_contribution_o       in varchar2
  ,p_pension_contribution_o       in varchar2
  ,p_sickness_contribution_o      in varchar2
  ,p_work_injury_contribution_o   in varchar2
  ,p_labor_contribution_o         in varchar2
  ,p_health_contribution_o        in varchar2
  ,p_unemployment_contribution_o  in varchar2
  ,p_old_age_cont_end_reason_o    in varchar2
  ,p_pension_cont_end_reason_o    in varchar2
  ,p_sickness_cont_end_reason_o   in varchar2
  ,p_work_injury_cont_end_reaso_o in varchar2
  ,p_labor_fund_cont_end_reason_o in varchar2
  ,p_health_cont_end_reason_o     in varchar2
  ,p_unemployment_cont_end_reas_o in varchar2
  ,p_program_id_o                 in number
  ,p_program_login_id_o           in number
  ,p_program_application_id_o     in number
  ,p_request_id_o                 in number
  );
--
end pay_psd_rkd;

 

/

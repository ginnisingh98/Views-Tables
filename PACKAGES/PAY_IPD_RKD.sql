--------------------------------------------------------
--  DDL for Package PAY_IPD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IPD_RKD" AUTHID CURRENT_USER as
/* $Header: pyipdrhi.pkh 120.0 2005/05/29 05:59:14 appldev noship $ */
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
  ,p_paye_details_id              in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_object_version_number_o      in number
  ,p_assignment_id_o              in number
  ,p_info_source_o                in varchar2
  ,p_comm_period_no_o             in number
  ,p_tax_basis_o                  in varchar2
  ,p_certificate_start_date_o     in date
  ,p_certificate_end_date_o       in date
  ,p_tax_assess_basis_o           in varchar2
  ,p_weekly_tax_credit_o          in number
  ,p_weekly_std_rate_cut_off_o    in number
  ,p_monthly_tax_credit_o         in number
  ,p_monthly_std_rate_cut_off_o   in number
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  ,p_certificate_issue_date_o     in date
  );
--
end pay_ipd_rkd;

 

/

--------------------------------------------------------
--  DDL for Package PAY_PPD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PPD_RKD" AUTHID CURRENT_USER as
/* $Header: pyppdrhi.pkh 120.1 2006/01/02 00:35 mseshadr noship $ */
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
  ,p_per_or_asg_id_o              in number
  ,p_business_group_id_o          in number
  ,p_contract_category_o          in varchar2
  ,p_object_version_number_o      in number
  ,p_tax_reduction_o              in varchar2
  ,p_tax_calc_with_spouse_child_o in varchar2
  ,p_income_reduction_o           in varchar2
  ,p_income_reduction_amount_o    in number
  ,p_rate_of_tax_o                in varchar2
  ,p_program_id_o                 in number
  ,p_program_login_id_o           in number
  ,p_program_application_id_o     in number
  ,p_request_id_o                 in number
  );
--
end pay_ppd_rkd;

 

/

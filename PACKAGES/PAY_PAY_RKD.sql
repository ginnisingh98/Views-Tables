--------------------------------------------------------
--  DDL for Package PAY_PAY_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAY_RKD" AUTHID CURRENT_USER as
/* $Header: pypayrhi.pkh 120.2 2007/09/10 12:32:13 ckesanap noship $ */
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
  ,p_payroll_id                   in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_default_payment_method_id_o  in number
  ,p_business_group_id_o          in number
  ,p_consolidation_set_id_o       in number
  ,p_cost_allocation_keyflex_id_o in number
  ,p_suspense_account_keyflex_i_o in number
  ,p_gl_set_of_books_id_o         in number
  ,p_soft_coding_keyflex_id_o     in number
  ,p_period_type_o                in varchar2
  ,p_organization_id_o            in number
  ,p_cut_off_date_offset_o        in number
  ,p_direct_deposit_date_offset_o in number
  ,p_first_period_end_date_o      in date
  ,p_negative_pay_allowed_flag_o  in varchar2
  ,p_number_of_years_o            in number
  ,p_pay_advice_date_offset_o     in number
  ,p_pay_date_offset_o            in number
  ,p_payroll_name_o               in varchar2
  ,p_workload_shifting_level_o    in varchar2
  ,p_comment_id_o                 in number
  ,p_comments_o                   in varchar2
  ,p_midpoint_offset_o            in number
  ,p_attribute_category_o         in varchar2
  ,p_attribute1_o                 in varchar2
  ,p_attribute2_o                 in varchar2
  ,p_attribute3_o                 in varchar2
  ,p_attribute4_o                 in varchar2
  ,p_attribute5_o                 in varchar2
  ,p_attribute6_o                 in varchar2
  ,p_attribute7_o                 in varchar2
  ,p_attribute8_o                 in varchar2
  ,p_attribute9_o                 in varchar2
  ,p_attribute10_o                in varchar2
  ,p_attribute11_o                in varchar2
  ,p_attribute12_o                in varchar2
  ,p_attribute13_o                in varchar2
  ,p_attribute14_o                in varchar2
  ,p_attribute15_o                in varchar2
  ,p_attribute16_o                in varchar2
  ,p_attribute17_o                in varchar2
  ,p_attribute18_o                in varchar2
  ,p_attribute19_o                in varchar2
  ,p_attribute20_o                in varchar2
  ,p_arrears_flag_o               in varchar2
  ,p_payroll_type_o               in varchar2
  ,p_prl_information_category_o   in varchar2
  ,p_prl_information1_o           in varchar2
  ,p_prl_information2_o           in varchar2
  ,p_prl_information3_o           in varchar2
  ,p_prl_information4_o           in varchar2
  ,p_prl_information5_o           in varchar2
  ,p_prl_information6_o           in varchar2
  ,p_prl_information7_o           in varchar2
  ,p_prl_information8_o           in varchar2
  ,p_prl_information9_o           in varchar2
  ,p_prl_information10_o          in varchar2
  ,p_prl_information11_o          in varchar2
  ,p_prl_information12_o          in varchar2
  ,p_prl_information13_o          in varchar2
  ,p_prl_information14_o          in varchar2
  ,p_prl_information15_o          in varchar2
  ,p_prl_information16_o          in varchar2
  ,p_prl_information17_o          in varchar2
  ,p_prl_information18_o          in varchar2
  ,p_prl_information19_o          in varchar2
  ,p_prl_information20_o          in varchar2
  ,p_prl_information21_o          in varchar2
  ,p_prl_information22_o          in varchar2
  ,p_prl_information23_o          in varchar2
  ,p_prl_information24_o          in varchar2
  ,p_prl_information25_o          in varchar2
  ,p_prl_information26_o          in varchar2
  ,p_prl_information27_o          in varchar2
  ,p_prl_information28_o          in varchar2
  ,p_prl_information29_o          in varchar2
  ,p_prl_information30_o          in varchar2
  ,p_multi_assignments_flag_o     in varchar2
  ,p_period_reset_years_o         in varchar2
  ,p_object_version_number_o      in number
  ,p_payslip_view_date_offset_o   in number
  );
--
end pay_pay_rkd;

/

--------------------------------------------------------
--  DDL for Package PAY_PAY_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAY_RKI" AUTHID CURRENT_USER as
/* $Header: pypayrhi.pkh 120.2 2007/09/10 12:32:13 ckesanap noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_payroll_id                   in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_default_payment_method_id    in number
  ,p_business_group_id            in number
  ,p_consolidation_set_id         in number
  ,p_cost_allocation_keyflex_id   in number
  ,p_suspense_account_keyflex_id  in number
  ,p_gl_set_of_books_id           in number
  ,p_soft_coding_keyflex_id       in number
  ,p_period_type                  in varchar2
  ,p_organization_id              in number
  ,p_cut_off_date_offset          in number
  ,p_direct_deposit_date_offset   in number
  ,p_first_period_end_date        in date
  ,p_negative_pay_allowed_flag    in varchar2
  ,p_number_of_years              in number
  ,p_pay_advice_date_offset       in number
  ,p_pay_date_offset              in number
  ,p_payroll_name                 in varchar2
  ,p_workload_shifting_level      in varchar2
  ,p_comment_id                   in number
  ,p_comments                     in varchar2
  ,p_midpoint_offset              in number
  ,p_attribute_category           in varchar2
  ,p_attribute1                   in varchar2
  ,p_attribute2                   in varchar2
  ,p_attribute3                   in varchar2
  ,p_attribute4                   in varchar2
  ,p_attribute5                   in varchar2
  ,p_attribute6                   in varchar2
  ,p_attribute7                   in varchar2
  ,p_attribute8                   in varchar2
  ,p_attribute9                   in varchar2
  ,p_attribute10                  in varchar2
  ,p_attribute11                  in varchar2
  ,p_attribute12                  in varchar2
  ,p_attribute13                  in varchar2
  ,p_attribute14                  in varchar2
  ,p_attribute15                  in varchar2
  ,p_attribute16                  in varchar2
  ,p_attribute17                  in varchar2
  ,p_attribute18                  in varchar2
  ,p_attribute19                  in varchar2
  ,p_attribute20                  in varchar2
  ,p_arrears_flag                 in varchar2
  ,p_payroll_type                 in varchar2
  ,p_prl_information_category     in varchar2
  ,p_prl_information1             in varchar2
  ,p_prl_information2             in varchar2
  ,p_prl_information3             in varchar2
  ,p_prl_information4             in varchar2
  ,p_prl_information5             in varchar2
  ,p_prl_information6             in varchar2
  ,p_prl_information7             in varchar2
  ,p_prl_information8             in varchar2
  ,p_prl_information9             in varchar2
  ,p_prl_information10            in varchar2
  ,p_prl_information11            in varchar2
  ,p_prl_information12            in varchar2
  ,p_prl_information13            in varchar2
  ,p_prl_information14            in varchar2
  ,p_prl_information15            in varchar2
  ,p_prl_information16            in varchar2
  ,p_prl_information17            in varchar2
  ,p_prl_information18            in varchar2
  ,p_prl_information19            in varchar2
  ,p_prl_information20            in varchar2
  ,p_prl_information21            in varchar2
  ,p_prl_information22            in varchar2
  ,p_prl_information23            in varchar2
  ,p_prl_information24            in varchar2
  ,p_prl_information25            in varchar2
  ,p_prl_information26            in varchar2
  ,p_prl_information27            in varchar2
  ,p_prl_information28            in varchar2
  ,p_prl_information29            in varchar2
  ,p_prl_information30            in varchar2
  ,p_multi_assignments_flag       in varchar2
  ,p_period_reset_years           in varchar2
  ,p_object_version_number        in number
  ,p_payslip_view_date_offset     in number
  );
end pay_pay_rki;

/

--------------------------------------------------------
--  DDL for Package PAY_PEL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PEL_RKU" AUTHID CURRENT_USER as
/* $Header: pypelrhi.pkh 120.2.12010000.1 2008/07/27 23:21:57 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_element_link_id              in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_payroll_id                   in number
  ,p_job_id                       in number
  ,p_position_id                  in number
  ,p_people_group_id              in number
  ,p_cost_allocation_keyflex_id   in number
  ,p_organization_id              in number
  ,p_element_type_id              in number
  ,p_location_id                  in number
  ,p_grade_id                     in number
  ,p_balancing_keyflex_id         in number
  ,p_business_group_id            in number
  ,p_element_set_id               in number
  ,p_pay_basis_id                 in number
  ,p_costable_type                in varchar2
  ,p_link_to_all_payrolls_flag    in varchar2
  ,p_multiply_value_flag          in varchar2
  ,p_standard_link_flag           in varchar2
  ,p_transfer_to_gl_flag          in varchar2
  ,p_comment_id                   in number
  ,p_comments                     in varchar2
  ,p_employment_category          in varchar2
  ,p_qualifying_age               in number
  ,p_qualifying_length_of_service in number
  ,p_qualifying_units             in varchar2
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
  ,p_object_version_number        in number
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_payroll_id_o                 in number
  ,p_job_id_o                     in number
  ,p_position_id_o                in number
  ,p_people_group_id_o            in number
  ,p_cost_allocation_keyflex_id_o in number
  ,p_organization_id_o            in number
  ,p_element_type_id_o            in number
  ,p_location_id_o                in number
  ,p_grade_id_o                   in number
  ,p_balancing_keyflex_id_o       in number
  ,p_business_group_id_o          in number
  ,p_element_set_id_o             in number
  ,p_pay_basis_id_o               in number
  ,p_costable_type_o              in varchar2
  ,p_link_to_all_payrolls_flag_o  in varchar2
  ,p_multiply_value_flag_o        in varchar2
  ,p_standard_link_flag_o         in varchar2
  ,p_transfer_to_gl_flag_o        in varchar2
  ,p_comment_id_o                 in number
  ,p_comments_o                   in varchar2
  ,p_employment_category_o        in varchar2
  ,p_qualifying_age_o             in number
  ,p_qualifying_length_of_servi_o in number
  ,p_qualifying_units_o           in varchar2
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
  ,p_object_version_number_o      in number
  );
--
end pay_pel_rku;

/

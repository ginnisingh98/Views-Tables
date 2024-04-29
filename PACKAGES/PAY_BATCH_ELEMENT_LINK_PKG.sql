--------------------------------------------------------
--  DDL for Package PAY_BATCH_ELEMENT_LINK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BATCH_ELEMENT_LINK_PKG" AUTHID CURRENT_USER AS
/* $Header: pybel.pkh 120.1 2006/09/26 14:58:16 thabara noship $ */


--------------------------------------------------------------------------------
procedure insert_row
  (p_rowid                        in out nocopy varchar2
  ,p_batch_element_link_id        in out nocopy number
  ,p_element_link_id              in     number
  ,p_effective_date               in     date
  ,p_payroll_id                   in     number
  ,p_job_id                       in     number
  ,p_position_id                  in     number
  ,p_people_group_id              in     number
  ,p_cost_allocation_keyflex_id   in     number
  ,p_organization_id              in     number
  ,p_element_type_id              in     number
  ,p_location_id                  in     number
  ,p_grade_id                     in     number
  ,p_balancing_keyflex_id         in     number
  ,p_business_group_id            in     number
  ,p_element_set_id               in     number
  ,p_pay_basis_id                 in     number
  ,p_costable_type                in     varchar2
  ,p_link_to_all_payrolls_flag    in     varchar2
  ,p_multiply_value_flag          in     varchar2
  ,p_standard_link_flag           in     varchar2
  ,p_transfer_to_gl_flag          in     varchar2
  ,p_comment_id                   in     number
  ,p_employment_category          in     varchar2
  ,p_qualifying_age               in     number
  ,p_qualifying_length_of_service in     number
  ,p_qualifying_units             in     varchar2
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_attribute16                  in     varchar2
  ,p_attribute17                  in     varchar2
  ,p_attribute18                  in     varchar2
  ,p_attribute19                  in     varchar2
  ,p_attribute20                  in     varchar2
  ,p_object_status                in     varchar2
  );
-------------------------------------------------------------------------------
procedure lock_row
  (p_rowid                        in     varchar2
  ,p_batch_element_link_id        in     number
  ,p_element_link_id              in     number
  ,p_effective_date               in     date
  ,p_payroll_id                   in     number
  ,p_job_id                       in     number
  ,p_position_id                  in     number
  ,p_people_group_id              in     number
  ,p_cost_allocation_keyflex_id   in     number
  ,p_organization_id              in     number
  ,p_element_type_id              in     number
  ,p_location_id                  in     number
  ,p_grade_id                     in     number
  ,p_balancing_keyflex_id         in     number
  ,p_business_group_id            in     number
  ,p_element_set_id               in     number
  ,p_pay_basis_id                 in     number
  ,p_costable_type                in     varchar2
  ,p_link_to_all_payrolls_flag    in     varchar2
  ,p_multiply_value_flag          in     varchar2
  ,p_standard_link_flag           in     varchar2
  ,p_transfer_to_gl_flag          in     varchar2
  ,p_comment_id                   in     number
  ,p_employment_category          in     varchar2
  ,p_qualifying_age               in     number
  ,p_qualifying_length_of_service in     number
  ,p_qualifying_units             in     varchar2
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_attribute16                  in     varchar2
  ,p_attribute17                  in     varchar2
  ,p_attribute18                  in     varchar2
  ,p_attribute19                  in     varchar2
  ,p_attribute20                  in     varchar2
  ,p_object_status                in     varchar2
  );
--------------------------------------------------------------------------------
procedure update_row
  (p_rowid                        in     varchar2
  ,p_batch_element_link_id        in     number
  ,p_element_link_id              in     number
  ,p_effective_date               in     date
  ,p_payroll_id                   in     number
  ,p_job_id                       in     number
  ,p_position_id                  in     number
  ,p_people_group_id              in     number
  ,p_cost_allocation_keyflex_id   in     number
  ,p_organization_id              in     number
  ,p_element_type_id              in     number
  ,p_location_id                  in     number
  ,p_grade_id                     in     number
  ,p_balancing_keyflex_id         in     number
  ,p_business_group_id            in     number
  ,p_element_set_id               in     number
  ,p_pay_basis_id                 in     number
  ,p_costable_type                in     varchar2
  ,p_link_to_all_payrolls_flag    in     varchar2
  ,p_multiply_value_flag          in     varchar2
  ,p_standard_link_flag           in     varchar2
  ,p_transfer_to_gl_flag          in     varchar2
  ,p_comment_id                   in     number
  ,p_employment_category          in     varchar2
  ,p_qualifying_age               in     number
  ,p_qualifying_length_of_service in     number
  ,p_qualifying_units             in     varchar2
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_attribute16                  in     varchar2
  ,p_attribute17                  in     varchar2
  ,p_attribute18                  in     varchar2
  ,p_attribute19                  in     varchar2
  ,p_attribute20                  in     varchar2
  );
--------------------------------------------------------------------------------
procedure delete_row
  (p_rowid 		          in     varchar2
  );
--------------------------------------------------------------------------------

end pay_batch_element_link_pkg;

/

--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_BKM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_BKM" AUTHID CURRENT_USER as
/* $Header: peasgapi.pkh 120.11.12010000.4 2009/07/28 10:08:56 ghshanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_cwk_asg_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cwk_asg_b
  (p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in     number
  ,p_assignment_category		  in     varchar2
  ,p_assignment_number            in     varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_default_code_comb_id         in     number
  ,p_establishment_id             in     number
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_project_title				  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_supervisor_id                in     number
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_title                        in     varchar2
  ,p_vendor_assignment_number     in     varchar2
  ,p_vendor_employee_number       in     varchar2
  ,p_vendor_id                    in     number
  ,p_vendor_site_id               in     number
  ,p_po_header_id                 in     number
  ,p_po_line_id                   in     number
  ,p_projected_assignment_end     in     date
  ,p_assignment_status_type_id    in     number
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
  ,p_attribute21                  in     varchar2
  ,p_attribute22                  in     varchar2
  ,p_attribute23                  in     varchar2
  ,p_attribute24                  in     varchar2
  ,p_attribute25                  in     varchar2
  ,p_attribute26                  in     varchar2
  ,p_attribute27                  in     varchar2
  ,p_attribute28                  in     varchar2
  ,p_attribute29                  in     varchar2
  ,p_attribute30                  in     varchar2
  ,p_scl_segment1                 in     varchar2
  ,p_scl_segment2                 in     varchar2
  ,p_scl_segment3                 in     varchar2
  ,p_scl_segment4                 in     varchar2
  ,p_scl_segment5                 in     varchar2
  ,p_scl_segment6                 in     varchar2
  ,p_scl_segment7                 in     varchar2
  ,p_scl_segment8                 in     varchar2
  ,p_scl_segment9                 in     varchar2
  ,p_scl_segment10                in     varchar2
  ,p_scl_segment11                in     varchar2
  ,p_scl_segment12                in     varchar2
  ,p_scl_segment13                in     varchar2
  ,p_scl_segment14                in     varchar2
  ,p_scl_segment15                in     varchar2
  ,p_scl_segment16                in     varchar2
  ,p_scl_segment17                in     varchar2
  ,p_scl_segment18                in     varchar2
  ,p_scl_segment19                in     varchar2
  ,p_scl_segment20                in     varchar2
  ,p_scl_segment21                in     varchar2
  ,p_scl_segment22                in     varchar2
  ,p_scl_segment23                in     varchar2
  ,p_scl_segment24                in     varchar2
  ,p_scl_segment25                in     varchar2
  ,p_scl_segment26                in     varchar2
  ,p_scl_segment27                in     varchar2
  ,p_scl_segment28                in     varchar2
  ,p_scl_segment29                in     varchar2
  ,p_scl_segment30                in     varchar2
  ,p_supervisor_assignment_id     in     number
);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_cwk_asg_a >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cwk_asg_a
  (p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in     number
  ,p_assignment_category		  in     varchar2
  ,p_assignment_number            in     varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_default_code_comb_id         in     number
  ,p_establishment_id             in     number
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_project_title				  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_supervisor_id                in     number
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_title                        in     varchar2
  ,p_vendor_assignment_number     in     varchar2
  ,p_vendor_employee_number       in     varchar2
  ,p_vendor_id                    in     number
  ,p_vendor_site_id               in     number
  ,p_po_header_id                 in     number
  ,p_po_line_id                   in     number
  ,p_projected_assignment_end     in     date
  ,p_assignment_status_type_id    in     number
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
  ,p_attribute21                  in     varchar2
  ,p_attribute22                  in     varchar2
  ,p_attribute23                  in     varchar2
  ,p_attribute24                  in     varchar2
  ,p_attribute25                  in     varchar2
  ,p_attribute26                  in     varchar2
  ,p_attribute27                  in     varchar2
  ,p_attribute28                  in     varchar2
  ,p_attribute29                  in     varchar2
  ,p_attribute30                  in     varchar2
  ,p_scl_segment1                 in     varchar2
  ,p_scl_segment2                 in     varchar2
  ,p_scl_segment3                 in     varchar2
  ,p_scl_segment4                 in     varchar2
  ,p_scl_segment5                 in     varchar2
  ,p_scl_segment6                 in     varchar2
  ,p_scl_segment7                 in     varchar2
  ,p_scl_segment8                 in     varchar2
  ,p_scl_segment9                 in     varchar2
  ,p_scl_segment10                in     varchar2
  ,p_scl_segment11                in     varchar2
  ,p_scl_segment12                in     varchar2
  ,p_scl_segment13                in     varchar2
  ,p_scl_segment14                in     varchar2
  ,p_scl_segment15                in     varchar2
  ,p_scl_segment16                in     varchar2
  ,p_scl_segment17                in     varchar2
  ,p_scl_segment18                in     varchar2
  ,p_scl_segment19                in     varchar2
  ,p_scl_segment20                in     varchar2
  ,p_scl_segment21                in     varchar2
  ,p_scl_segment22                in     varchar2
  ,p_scl_segment23                in     varchar2
  ,p_scl_segment24                in     varchar2
  ,p_scl_segment25                in     varchar2
  ,p_scl_segment26                in     varchar2
  ,p_scl_segment27                in     varchar2
  ,p_scl_segment28                in     varchar2
  ,p_scl_segment29                in     varchar2
  ,p_scl_segment30                in     varchar2
  ,p_org_now_no_manager_warning   in     boolean
  ,p_effective_start_date         in     date
  ,p_effective_end_date           in     date
  ,p_comment_id                   in     number
  ,p_no_managers_warning          in     boolean
  ,p_other_manager_warning        in     boolean
  ,p_soft_coding_keyflex_id       in     number
  ,p_concatenated_segments        in     varchar2
  ,p_hourly_salaried_warning      in     boolean
  ,p_supervisor_assignment_id     in     number
);
  --
end hr_assignment_bkm;

/

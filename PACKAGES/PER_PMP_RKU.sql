--------------------------------------------------------
--  DDL for Package PER_PMP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PMP_RKU" AUTHID CURRENT_USER as
/* $Header: pepmprhi.pkh 120.2.12010000.3 2010/01/27 15:49:21 rsykam ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_plan_id                      in number
  ,p_object_version_number        in number
  ,p_plan_name                    in varchar2
  ,p_administrator_person_id      in number
  ,p_previous_plan_id             in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_status_code                  in varchar2
  ,p_hierarchy_type_code          in varchar2
  ,p_supervisor_id                in number
  ,p_supervisor_assignment_id     in number
  ,p_organization_structure_id    in number
  ,p_org_structure_version_id     in number
  ,p_top_organization_id          in number
  ,p_position_structure_id        in number
  ,p_pos_structure_version_id     in number
  ,p_top_position_id              in number
  ,p_hierarchy_levels             in number
  ,p_automatic_enrollment_flag    in varchar2
  ,p_assignment_types_code        in varchar2
  ,p_primary_asg_only_flag        in varchar2
  ,p_include_obj_setting_flag     in varchar2
  ,p_obj_setting_start_date       in date
  ,p_obj_setting_deadline         in date
  ,p_obj_set_outside_period_flag  in varchar2
  ,p_method_code                  in varchar2
  ,p_notify_population_flag       in varchar2
  ,p_automatic_allocation_flag    in varchar2
  ,p_copy_past_objectives_flag    in varchar2
  ,p_sharing_alignment_task_flag  in varchar2
  ,p_include_appraisals_flag      in varchar2
  ,p_change_sc_status_flag in varchar2
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
  ,p_attribute21                  in varchar2
  ,p_attribute22                  in varchar2
  ,p_attribute23                  in varchar2
  ,p_attribute24                  in varchar2
  ,p_attribute25                  in varchar2
  ,p_attribute26                  in varchar2
  ,p_attribute27                  in varchar2
  ,p_attribute28                  in varchar2
  ,p_attribute29                  in varchar2
  ,p_attribute30                  in varchar2
  ,p_update_library_objectives in varchar2    -- 8740021 bug fix
  ,p_automatic_approval_flag in varchar2
  ,p_object_version_number_o      in number
  ,p_plan_name_o                  in varchar2
  ,p_administrator_person_id_o    in number
  ,p_previous_plan_id_o           in number
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_status_code_o                in varchar2
  ,p_hierarchy_type_code_o        in varchar2
  ,p_supervisor_id_o              in number
  ,p_supervisor_assignment_id_o   in number
  ,p_organization_structure_id_o  in number
  ,p_org_structure_version_id_o   in number
  ,p_top_organization_id_o        in number
  ,p_position_structure_id_o      in number
  ,p_pos_structure_version_id_o   in number
  ,p_hierarchy_levels_o           in number
  ,p_top_position_id_o            in number
  ,p_automatic_enrollment_flag_o  in varchar2
  ,p_assignment_types_code_o      in varchar2
  ,p_primary_asg_only_flag_o      in varchar2
  ,p_include_obj_setting_flag_o   in varchar2
  ,p_obj_setting_start_date_o     in date
  ,p_obj_setting_deadline_o       in date
  ,p_obj_set_outside_period_fla_o in varchar2
  ,p_method_code_o                in varchar2
  ,p_notify_population_flag_o     in varchar2
  ,p_automatic_allocation_flag_o  in varchar2
  ,p_copy_past_objectives_flag_o  in varchar2
  ,p_sharing_alignment_task_fla_o in varchar2
  ,p_include_appraisals_flag_o    in varchar2
,p_change_sc_status_flag_o in varchar2
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
  ,p_attribute21_o                in varchar2
  ,p_attribute22_o                in varchar2
  ,p_attribute23_o                in varchar2
  ,p_attribute24_o                in varchar2
  ,p_attribute25_o                in varchar2
  ,p_attribute26_o                in varchar2
  ,p_attribute27_o                in varchar2
  ,p_attribute28_o                in varchar2
  ,p_attribute29_o                in varchar2
  ,p_attribute30_o                in varchar2
  ,p_update_library_objectives_o in varchar2   -- 8740021 bug fix
  ,p_automatic_approval_flag_o  in varchar2
  );
--
end per_pmp_rku;

/

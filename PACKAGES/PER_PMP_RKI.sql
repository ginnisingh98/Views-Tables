--------------------------------------------------------
--  DDL for Package PER_PMP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PMP_RKI" AUTHID CURRENT_USER as
/* $Header: pepmprhi.pkh 120.2.12010000.3 2010/01/27 15:49:21 rsykam ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
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
  ,p_update_library_objectives in varchar2   -- 8740021 bug fix
  ,p_automatic_approval_flag in varchar2
  );
end per_pmp_rki;

/

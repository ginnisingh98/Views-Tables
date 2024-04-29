--------------------------------------------------------
--  DDL for Package BEN_CWB_PERSON_INFO_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_PERSON_INFO_BK1" AUTHID CURRENT_USER as
/* $Header: becpiapi.pkh 120.2 2005/10/17 04:59:32 steotia noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_person_info_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_person_info_b
  (p_group_per_in_ler_id         in     number
  ,p_assignment_id               in     number
  ,p_person_id                   in     number
  ,p_supervisor_id               in     number
  ,p_effective_date              in     date
  ,p_full_name                   in     varchar2
  ,p_brief_name                  in     varchar2
  ,p_custom_name                 in     varchar2
  ,p_supervisor_full_name        in     varchar2
  ,p_supervisor_brief_name       in     varchar2
  ,p_supervisor_custom_name      in     varchar2
  ,p_legislation_code            in     varchar2
  ,p_years_employed              in     number
  ,p_years_in_job                in     number
  ,p_years_in_position           in     number
  ,p_years_in_grade              in     number
  ,p_employee_number             in     varchar2
  ,p_start_date                  in     date
  ,p_original_start_date         in     date
  ,p_adjusted_svc_date           in     date
  ,p_base_salary                 in     number
  ,p_base_salary_change_date     in     date
  ,p_payroll_name                in     varchar2
  ,p_performance_rating          in     varchar2
  ,p_performance_rating_type     in     varchar2
  ,p_performance_rating_date     in     date
  ,p_business_group_id           in     number
  ,p_organization_id             in     number
  ,p_job_id                      in     number
  ,p_grade_id                    in     number
  ,p_position_id                 in     number
  ,p_people_group_id             in     number
  ,p_soft_coding_keyflex_id      in     number
  ,p_location_id                 in     number
  ,p_pay_rate_id                 in     number
  ,p_assignment_status_type_id   in     number
  ,p_frequency                   in     varchar2
  ,p_grade_annulization_factor   in     number
  ,p_pay_annulization_factor     in     number
  ,p_grd_min_val                 in     number
  ,p_grd_max_val                 in     number
  ,p_grd_mid_point               in     number
  ,p_grd_quartile                in     varchar2
  ,p_grd_comparatio              in     number
  ,p_emp_category                in     varchar2
  ,p_change_reason               in     varchar2
  ,p_normal_hours                in     number
  ,p_email_address               in     varchar2
  ,p_base_salary_frequency       in     varchar2
  ,p_new_assgn_ovn               in     number
  ,p_new_perf_event_id           in     number
  ,p_new_perf_review_id          in     number
  ,p_post_process_stat_cd        in     varchar2
  ,p_feedback_rating             in     varchar2
  ,p_feedback_comments           in     varchar2
  ,p_custom_segment1             in     varchar2
  ,p_custom_segment2             in     varchar2
  ,p_custom_segment3             in     varchar2
  ,p_custom_segment4             in     varchar2
  ,p_custom_segment5             in     varchar2
  ,p_custom_segment6             in     varchar2
  ,p_custom_segment7             in     varchar2
  ,p_custom_segment8             in     varchar2
  ,p_custom_segment9             in     varchar2
  ,p_custom_segment10            in     varchar2
  ,p_custom_segment11            in     number
  ,p_custom_segment12            in     number
  ,p_custom_segment13            in     number
  ,p_custom_segment14            in     number
  ,p_custom_segment15            in     number
  ,p_custom_segment16            in     number
  ,p_custom_segment17            in     number
  ,p_custom_segment18            in     number
  ,p_custom_segment19            in     number
  ,p_custom_segment20            in     number
  ,p_ass_attribute_category      in     varchar2
  ,p_ass_attribute1              in     varchar2
  ,p_ass_attribute2              in     varchar2
  ,p_ass_attribute3              in     varchar2
  ,p_ass_attribute4              in     varchar2
  ,p_ass_attribute5              in     varchar2
  ,p_ass_attribute6              in     varchar2
  ,p_ass_attribute7              in     varchar2
  ,p_ass_attribute8              in     varchar2
  ,p_ass_attribute9              in     varchar2
  ,p_ass_attribute10             in     varchar2
  ,p_ass_attribute11             in     varchar2
  ,p_ass_attribute12             in     varchar2
  ,p_ass_attribute13             in     varchar2
  ,p_ass_attribute14             in     varchar2
  ,p_ass_attribute15             in     varchar2
  ,p_ass_attribute16             in     varchar2
  ,p_ass_attribute17             in     varchar2
  ,p_ass_attribute18             in     varchar2
  ,p_ass_attribute19             in     varchar2
  ,p_ass_attribute20             in     varchar2
  ,p_ass_attribute21             in     varchar2
  ,p_ass_attribute22             in     varchar2
  ,p_ass_attribute23             in     varchar2
  ,p_ass_attribute24             in     varchar2
  ,p_ass_attribute25             in     varchar2
  ,p_ass_attribute26             in     varchar2
  ,p_ass_attribute27             in     varchar2
  ,p_ass_attribute28             in     varchar2
  ,p_ass_attribute29             in     varchar2
  ,p_ass_attribute30             in     varchar2
  ,p_ws_comments                 in     varchar2
  ,p_people_group_name           in     varchar2
  ,p_people_group_segment1       in     varchar2
  ,p_people_group_segment2       in     varchar2
  ,p_people_group_segment3       in     varchar2
  ,p_people_group_segment4       in     varchar2
  ,p_people_group_segment5       in     varchar2
  ,p_people_group_segment6       in     varchar2
  ,p_people_group_segment7       in     varchar2
  ,p_people_group_segment8       in     varchar2
  ,p_people_group_segment9       in     varchar2
  ,p_people_group_segment10      in     varchar2
  ,p_people_group_segment11      in     varchar2
  ,p_cpi_attribute_category      in     varchar2
  ,p_cpi_attribute1              in     varchar2
  ,p_cpi_attribute2              in     varchar2
  ,p_cpi_attribute3              in     varchar2
  ,p_cpi_attribute4              in     varchar2
  ,p_cpi_attribute5              in     varchar2
  ,p_cpi_attribute6              in     varchar2
  ,p_cpi_attribute7              in     varchar2
  ,p_cpi_attribute8              in     varchar2
  ,p_cpi_attribute9              in     varchar2
  ,p_cpi_attribute10             in     varchar2
  ,p_cpi_attribute11             in     varchar2
  ,p_cpi_attribute12             in     varchar2
  ,p_cpi_attribute13             in     varchar2
  ,p_cpi_attribute14             in     varchar2
  ,p_cpi_attribute15             in     varchar2
  ,p_cpi_attribute16             in     varchar2
  ,p_cpi_attribute17             in     varchar2
  ,p_cpi_attribute18             in     varchar2
  ,p_cpi_attribute19             in     varchar2
  ,p_cpi_attribute20             in     varchar2
  ,p_cpi_attribute21             in     varchar2
  ,p_cpi_attribute22             in     varchar2
  ,p_cpi_attribute23             in     varchar2
  ,p_cpi_attribute24             in     varchar2
  ,p_cpi_attribute25             in     varchar2
  ,p_cpi_attribute26             in     varchar2
  ,p_cpi_attribute27             in     varchar2
  ,p_cpi_attribute28             in     varchar2
  ,p_cpi_attribute29             in     varchar2
  ,p_cpi_attribute30             in     varchar2
  ,p_feedback_date               in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_person_info_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_person_info_a
  (p_group_per_in_ler_id         in     number
  ,p_assignment_id               in     number
  ,p_person_id                   in     number
  ,p_supervisor_id               in     number
  ,p_effective_date              in     date
  ,p_full_name                   in     varchar2
  ,p_brief_name                  in     varchar2
  ,p_custom_name                 in     varchar2
  ,p_supervisor_full_name        in     varchar2
  ,p_supervisor_brief_name       in     varchar2
  ,p_supervisor_custom_name      in     varchar2
  ,p_legislation_code            in     varchar2
  ,p_years_employed              in     number
  ,p_years_in_job                in     number
  ,p_years_in_position           in     number
  ,p_years_in_grade              in     number
  ,p_employee_number             in     varchar2
  ,p_start_date                  in     date
  ,p_original_start_date         in     date
  ,p_adjusted_svc_date           in     date
  ,p_base_salary                 in     number
  ,p_base_salary_change_date     in     date
  ,p_payroll_name                in     varchar2
  ,p_performance_rating          in     varchar2
  ,p_performance_rating_type     in     varchar2
  ,p_performance_rating_date     in     date
  ,p_business_group_id           in     number
  ,p_organization_id             in     number
  ,p_job_id                      in     number
  ,p_grade_id                    in     number
  ,p_position_id                 in     number
  ,p_people_group_id             in     number
  ,p_soft_coding_keyflex_id      in     number
  ,p_location_id                 in     number
  ,p_pay_rate_id                 in     number
  ,p_assignment_status_type_id   in     number
  ,p_frequency                   in     varchar2
  ,p_grade_annulization_factor   in     number
  ,p_pay_annulization_factor     in     number
  ,p_grd_min_val                 in     number
  ,p_grd_max_val                 in     number
  ,p_grd_mid_point               in     number
  ,p_grd_quartile                in     varchar2
  ,p_grd_comparatio              in     number
  ,p_emp_category                in     varchar2
  ,p_change_reason               in     varchar2
  ,p_normal_hours                in     number
  ,p_email_address               in     varchar2
  ,p_base_salary_frequency       in     varchar2
  ,p_new_assgn_ovn               in     number
  ,p_new_perf_event_id           in     number
  ,p_new_perf_review_id          in     number
  ,p_post_process_stat_cd        in     varchar2
  ,p_feedback_rating             in     varchar2
  ,p_feedback_comments           in     varchar2
  ,p_custom_segment1             in     varchar2
  ,p_custom_segment2             in     varchar2
  ,p_custom_segment3             in     varchar2
  ,p_custom_segment4             in     varchar2
  ,p_custom_segment5             in     varchar2
  ,p_custom_segment6             in     varchar2
  ,p_custom_segment7             in     varchar2
  ,p_custom_segment8             in     varchar2
  ,p_custom_segment9             in     varchar2
  ,p_custom_segment10            in     varchar2
  ,p_custom_segment11            in     number
  ,p_custom_segment12            in     number
  ,p_custom_segment13            in     number
  ,p_custom_segment14            in     number
  ,p_custom_segment15            in     number
  ,p_custom_segment16            in     number
  ,p_custom_segment17            in     number
  ,p_custom_segment18            in     number
  ,p_custom_segment19            in     number
  ,p_custom_segment20            in     number
  ,p_ass_attribute_category      in     varchar2
  ,p_ass_attribute1              in     varchar2
  ,p_ass_attribute2              in     varchar2
  ,p_ass_attribute3              in     varchar2
  ,p_ass_attribute4              in     varchar2
  ,p_ass_attribute5              in     varchar2
  ,p_ass_attribute6              in     varchar2
  ,p_ass_attribute7              in     varchar2
  ,p_ass_attribute8              in     varchar2
  ,p_ass_attribute9              in     varchar2
  ,p_ass_attribute10             in     varchar2
  ,p_ass_attribute11             in     varchar2
  ,p_ass_attribute12             in     varchar2
  ,p_ass_attribute13             in     varchar2
  ,p_ass_attribute14             in     varchar2
  ,p_ass_attribute15             in     varchar2
  ,p_ass_attribute16             in     varchar2
  ,p_ass_attribute17             in     varchar2
  ,p_ass_attribute18             in     varchar2
  ,p_ass_attribute19             in     varchar2
  ,p_ass_attribute20             in     varchar2
  ,p_ass_attribute21             in     varchar2
  ,p_ass_attribute22             in     varchar2
  ,p_ass_attribute23             in     varchar2
  ,p_ass_attribute24             in     varchar2
  ,p_ass_attribute25             in     varchar2
  ,p_ass_attribute26             in     varchar2
  ,p_ass_attribute27             in     varchar2
  ,p_ass_attribute28             in     varchar2
  ,p_ass_attribute29             in     varchar2
  ,p_ass_attribute30             in     varchar2
  ,p_ws_comments                 in     varchar2
  ,p_people_group_name           in     varchar2
  ,p_people_group_segment1       in     varchar2
  ,p_people_group_segment2       in     varchar2
  ,p_people_group_segment3       in     varchar2
  ,p_people_group_segment4       in     varchar2
  ,p_people_group_segment5       in     varchar2
  ,p_people_group_segment6       in     varchar2
  ,p_people_group_segment7       in     varchar2
  ,p_people_group_segment8       in     varchar2
  ,p_people_group_segment9       in     varchar2
  ,p_people_group_segment10      in     varchar2
  ,p_people_group_segment11      in     varchar2
  ,p_cpi_attribute_category      in     varchar2
  ,p_cpi_attribute1              in     varchar2
  ,p_cpi_attribute2              in     varchar2
  ,p_cpi_attribute3              in     varchar2
  ,p_cpi_attribute4              in     varchar2
  ,p_cpi_attribute5              in     varchar2
  ,p_cpi_attribute6              in     varchar2
  ,p_cpi_attribute7              in     varchar2
  ,p_cpi_attribute8              in     varchar2
  ,p_cpi_attribute9              in     varchar2
  ,p_cpi_attribute10             in     varchar2
  ,p_cpi_attribute11             in     varchar2
  ,p_cpi_attribute12             in     varchar2
  ,p_cpi_attribute13             in     varchar2
  ,p_cpi_attribute14             in     varchar2
  ,p_cpi_attribute15             in     varchar2
  ,p_cpi_attribute16             in     varchar2
  ,p_cpi_attribute17             in     varchar2
  ,p_cpi_attribute18             in     varchar2
  ,p_cpi_attribute19             in     varchar2
  ,p_cpi_attribute20             in     varchar2
  ,p_cpi_attribute21             in     varchar2
  ,p_cpi_attribute22             in     varchar2
  ,p_cpi_attribute23             in     varchar2
  ,p_cpi_attribute24             in     varchar2
  ,p_cpi_attribute25             in     varchar2
  ,p_cpi_attribute26             in     varchar2
  ,p_cpi_attribute27             in     varchar2
  ,p_cpi_attribute28             in     varchar2
  ,p_cpi_attribute29             in     varchar2
  ,p_cpi_attribute30             in     varchar2
  ,p_feedback_date               in     date
  ,p_object_version_number       in     number
  );
--
end BEN_CWB_PERSON_INFO_BK1;

 

/
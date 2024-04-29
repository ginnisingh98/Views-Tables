--------------------------------------------------------
--  DDL for Package BEN_CPI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPI_RKD" AUTHID CURRENT_USER as
/* $Header: becpirhi.pkh 120.0 2005/05/28 01:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_group_per_in_ler_id          in number
  ,p_assignment_id_o              in number
  ,p_person_id_o                  in number
  ,p_supervisor_id_o              in number
  ,p_effective_date_o             in date
  ,p_full_name_o                  in varchar2
  ,p_brief_name_o                 in varchar2
  ,p_custom_name_o                in varchar2
  ,p_supervisor_full_name_o       in varchar2
  ,p_supervisor_brief_name_o      in varchar2
  ,p_supervisor_custom_name_o     in varchar2
  ,p_legislation_code_o           in varchar2
  ,p_years_employed_o             in number
  ,p_years_in_job_o               in number
  ,p_years_in_position_o          in number
  ,p_years_in_grade_o             in number
  ,p_employee_number_o            in varchar2
  ,p_start_date_o                 in date
  ,p_original_start_date_o        in date
  ,p_adjusted_svc_date_o          in date
  ,p_base_salary_o                in number
  ,p_base_salary_change_date_o    in date
  ,p_payroll_name_o               in varchar2
  ,p_performance_rating_o         in varchar2
  ,p_performance_rating_type_o    in varchar2
  ,p_performance_rating_date_o    in date
  ,p_business_group_id_o          in number
  ,p_organization_id_o            in number
  ,p_job_id_o                     in number
  ,p_grade_id_o                   in number
  ,p_position_id_o                in number
  ,p_people_group_id_o            in number
  ,p_soft_coding_keyflex_id_o     in number
  ,p_location_id_o                in number
  ,p_pay_rate_id_o                in number
  ,p_assignment_status_type_id_o  in number
  ,p_frequency_o                  in varchar2
  ,p_grade_annulization_factor_o  in number
  ,p_pay_annulization_factor_o    in number
  ,p_grd_min_val_o                in number
  ,p_grd_max_val_o                in number
  ,p_grd_mid_point_o              in number
  ,p_grd_quartile_o               in varchar2
  ,p_grd_comparatio_o             in number
  ,p_emp_category_o               in varchar2
  ,p_change_reason_o              in varchar2
  ,p_normal_hours_o               in number
  ,p_email_address_o              in varchar2
  ,p_base_salary_frequency_o      in varchar2
  ,p_new_assgn_ovn_o              in number
  ,p_new_perf_event_id_o          in number
  ,p_new_perf_review_id_o         in number
  ,p_post_process_stat_cd_o       in varchar2
  ,p_feedback_rating_o            in varchar2
  ,p_feedback_comments_o          in varchar2
  ,p_object_version_number_o      in number
  ,p_custom_segment1_o            in varchar2
  ,p_custom_segment2_o            in varchar2
  ,p_custom_segment3_o            in varchar2
  ,p_custom_segment4_o            in varchar2
  ,p_custom_segment5_o            in varchar2
  ,p_custom_segment6_o            in varchar2
  ,p_custom_segment7_o            in varchar2
  ,p_custom_segment8_o            in varchar2
  ,p_custom_segment9_o            in varchar2
  ,p_custom_segment10_o           in varchar2
  ,p_custom_segment11_o           in number
  ,p_custom_segment12_o           in number
  ,p_custom_segment13_o           in number
  ,p_custom_segment14_o           in number
  ,p_custom_segment15_o           in number
  ,p_custom_segment16_o           in number
  ,p_custom_segment17_o           in number
  ,p_custom_segment18_o           in number
  ,p_custom_segment19_o           in number
  ,p_custom_segment20_o           in number
  ,p_people_group_name_o          in varchar2
  ,p_people_group_segment1_o      in varchar2
  ,p_people_group_segment2_o      in varchar2
  ,p_people_group_segment3_o      in varchar2
  ,p_people_group_segment4_o      in varchar2
  ,p_people_group_segment5_o      in varchar2
  ,p_people_group_segment6_o      in varchar2
  ,p_people_group_segment7_o      in varchar2
  ,p_people_group_segment8_o      in varchar2
  ,p_people_group_segment9_o      in varchar2
  ,p_people_group_segment10_o     in varchar2
  ,p_people_group_segment11_o     in varchar2
  ,p_ass_attribute_category_o     in varchar2
  ,p_ass_attribute1_o             in varchar2
  ,p_ass_attribute2_o             in varchar2
  ,p_ass_attribute3_o             in varchar2
  ,p_ass_attribute4_o             in varchar2
  ,p_ass_attribute5_o             in varchar2
  ,p_ass_attribute6_o             in varchar2
  ,p_ass_attribute7_o             in varchar2
  ,p_ass_attribute8_o             in varchar2
  ,p_ass_attribute9_o             in varchar2
  ,p_ass_attribute10_o            in varchar2
  ,p_ass_attribute11_o            in varchar2
  ,p_ass_attribute12_o            in varchar2
  ,p_ass_attribute13_o            in varchar2
  ,p_ass_attribute14_o            in varchar2
  ,p_ass_attribute15_o            in varchar2
  ,p_ass_attribute16_o            in varchar2
  ,p_ass_attribute17_o            in varchar2
  ,p_ass_attribute18_o            in varchar2
  ,p_ass_attribute19_o            in varchar2
  ,p_ass_attribute20_o            in varchar2
  ,p_ass_attribute21_o            in varchar2
  ,p_ass_attribute22_o            in varchar2
  ,p_ass_attribute23_o            in varchar2
  ,p_ass_attribute24_o            in varchar2
  ,p_ass_attribute25_o            in varchar2
  ,p_ass_attribute26_o            in varchar2
  ,p_ass_attribute27_o            in varchar2
  ,p_ass_attribute28_o            in varchar2
  ,p_ass_attribute29_o            in varchar2
  ,p_ass_attribute30_o            in varchar2
  ,p_ws_comments_o                in varchar2
  ,p_cpi_attribute_category_o     in varchar2
  ,p_cpi_attribute1_o             in varchar2
  ,p_cpi_attribute2_o             in varchar2
  ,p_cpi_attribute3_o             in varchar2
  ,p_cpi_attribute4_o             in varchar2
  ,p_cpi_attribute5_o             in varchar2
  ,p_cpi_attribute6_o             in varchar2
  ,p_cpi_attribute7_o             in varchar2
  ,p_cpi_attribute8_o             in varchar2
  ,p_cpi_attribute9_o             in varchar2
  ,p_cpi_attribute10_o            in varchar2
  ,p_cpi_attribute11_o            in varchar2
  ,p_cpi_attribute12_o            in varchar2
  ,p_cpi_attribute13_o            in varchar2
  ,p_cpi_attribute14_o            in varchar2
  ,p_cpi_attribute15_o            in varchar2
  ,p_cpi_attribute16_o            in varchar2
  ,p_cpi_attribute17_o            in varchar2
  ,p_cpi_attribute18_o            in varchar2
  ,p_cpi_attribute19_o            in varchar2
  ,p_cpi_attribute20_o            in varchar2
  ,p_cpi_attribute21_o            in varchar2
  ,p_cpi_attribute22_o            in varchar2
  ,p_cpi_attribute23_o            in varchar2
  ,p_cpi_attribute24_o            in varchar2
  ,p_cpi_attribute25_o            in varchar2
  ,p_cpi_attribute26_o            in varchar2
  ,p_cpi_attribute27_o            in varchar2
  ,p_cpi_attribute28_o            in varchar2
  ,p_cpi_attribute29_o            in varchar2
  ,p_cpi_attribute30_o            in varchar2
  ,p_feedback_date_o                in date
  );
--
end ben_cpi_rkd;

 

/

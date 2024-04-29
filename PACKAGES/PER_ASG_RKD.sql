--------------------------------------------------------
--  DDL for Package PER_ASG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASG_RKD" AUTHID CURRENT_USER as
/* $Header: peasgrhi.pkh 120.4.12010000.2 2009/11/20 06:56:26 sidsaxen ship $ */
--
-- ---------------------------------------------------------------------------+
-- |----------------------------< after_delete >------------------------------|
-- ---------------------------------------------------------------------------+
--
procedure after_delete
  (p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_validation_start_date          in date
  ,p_validation_end_date            in date
  ,p_assignment_id                  in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_org_now_no_manager_warning     in boolean
  ,p_object_version_number          in number
  ,p_effective_start_date_o         in date
  ,p_effective_end_date_o           in date
  ,p_business_group_id_o            in number
  ,p_recruiter_id_o                 in number
  ,p_grade_id_o                     in number
  ,p_position_id_o                  in number
  ,p_job_id_o                       in number
  ,p_assignment_status_type_id_o    in number
  ,p_payroll_id_o                   in number
  ,p_location_id_o                  in number
  ,p_person_referred_by_id_o        in number
  ,p_supervisor_id_o                in number
  ,p_special_ceiling_step_id_o      in number
  ,p_person_id_o                    in number
  ,p_recruitment_activity_id_o      in number
  ,p_source_organization_id_o       in number
  ,p_organization_id_o              in number
  ,p_people_group_id_o              in number
  ,p_soft_coding_keyflex_id_o       in number
  ,p_vacancy_id_o                   in number
  ,p_pay_basis_id_o                 in number
  ,p_assignment_sequence_o          in number
  ,p_assignment_type_o              in varchar2
  ,p_primary_flag_o                 in varchar2
  ,p_application_id_o               in number
  ,p_assignment_number_o            in varchar2
  ,p_change_reason_o                in varchar2
  ,p_comment_id_o                   in number
  ,p_date_probation_end_o           in date
  ,p_default_code_comb_id_o         in number
  ,p_employment_category_o          in varchar2
  ,p_frequency_o                    in varchar2
  ,p_internal_address_line_o        in varchar2
  ,p_manager_flag_o                 in varchar2
  ,p_normal_hours_o                 in number
  ,p_perf_review_period_o           in number
  ,p_perf_review_period_frequen_o   in varchar2
  ,p_period_of_service_id_o         in number
  ,p_probation_period_o             in number
  ,p_probation_unit_o               in varchar2
  ,p_sal_review_period_o            in number
  ,p_sal_review_period_frequen_o    in varchar2
  ,p_set_of_books_id_o              in number
  ,p_source_type_o                  in varchar2
  ,p_time_normal_finish_o           in varchar2
  ,p_time_normal_start_o            in varchar2
  ,p_bargaining_unit_code_o         in varchar2
  ,p_labour_union_member_flag_o     in varchar2
  ,p_hourly_salaried_code_o         in varchar2
  ,p_request_id_o                   in number
  ,p_program_application_id_o       in number
  ,p_program_id_o                   in number
  ,p_program_update_date_o          in date
  ,p_ass_attribute_category_o       in varchar2
  ,p_ass_attribute1_o               in varchar2
  ,p_ass_attribute2_o               in varchar2
  ,p_ass_attribute3_o               in varchar2
  ,p_ass_attribute4_o               in varchar2
  ,p_ass_attribute5_o               in varchar2
  ,p_ass_attribute6_o               in varchar2
  ,p_ass_attribute7_o               in varchar2
  ,p_ass_attribute8_o               in varchar2
  ,p_ass_attribute9_o               in varchar2
  ,p_ass_attribute10_o              in varchar2
  ,p_ass_attribute11_o              in varchar2
  ,p_ass_attribute12_o              in varchar2
  ,p_ass_attribute13_o              in varchar2
  ,p_ass_attribute14_o              in varchar2
  ,p_ass_attribute15_o              in varchar2
  ,p_ass_attribute16_o              in varchar2
  ,p_ass_attribute17_o              in varchar2
  ,p_ass_attribute18_o              in varchar2
  ,p_ass_attribute19_o              in varchar2
  ,p_ass_attribute20_o              in varchar2
  ,p_ass_attribute21_o              in varchar2
  ,p_ass_attribute22_o              in varchar2
  ,p_ass_attribute23_o              in varchar2
  ,p_ass_attribute24_o              in varchar2
  ,p_ass_attribute25_o              in varchar2
  ,p_ass_attribute26_o              in varchar2
  ,p_ass_attribute27_o              in varchar2
  ,p_ass_attribute28_o              in varchar2
  ,p_ass_attribute29_o              in varchar2
  ,p_ass_attribute30_o              in varchar2
  ,p_title_o                        in varchar2
  ,p_contract_id_o                  in number
  ,p_establishment_id_o             in number
  ,p_collective_agreement_id_o      in number
  ,p_cagr_grade_def_id_o            in number
  ,p_cagr_id_flex_num_o             in number
  ,p_object_version_number_o        in number
  ,p_notice_period_o                in number
  ,p_notice_period_uom_o            in varchar2
  ,p_employee_category_o            in varchar2
  ,p_work_at_home_o                 in varchar2
  ,p_job_post_source_name_o         in varchar2
  ,p_posting_content_id_o           in number
  ,p_placement_date_start_o         in date
  ,p_vendor_id_o                    in number
  ,p_vendor_employee_number_o       in varchar2
  ,p_vendor_assignment_number_o     in varchar2
  ,p_assignment_category_o          in varchar2
  ,p_project_title_o                in varchar2
  ,p_applicant_rank_o               in number
  ,p_grade_ladder_pgm_id_o          in number
  ,p_supervisor_assignment_id_o     in number
  ,p_vendor_site_id_o               in number
  ,p_po_header_id_o                 in number
  ,p_po_line_id_o                   in number
  ,p_projected_assignment_end_o     in date
  );
--
end per_asg_rkd;

/
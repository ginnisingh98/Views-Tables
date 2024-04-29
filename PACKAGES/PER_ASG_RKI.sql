--------------------------------------------------------
--  DDL for Package PER_ASG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASG_RKI" AUTHID CURRENT_USER as
/* $Header: peasgrhi.pkh 120.4.12010000.2 2009/11/20 06:56:26 sidsaxen ship $ */
--
-- ---------------------------------------------------------------------------+
-- |-----------------------------< after_insert >-----------------------------|
-- ---------------------------------------------------------------------------+
--
procedure after_insert
  (p_effective_date                 in date
  ,p_validation_start_date          in date
  ,p_validation_end_date            in date
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_assignment_id                  in number
  ,p_business_group_id              in number
  ,p_recruiter_id                   in number
  ,p_grade_id                       in number
  ,p_position_id                    in number
  ,p_job_id                         in number
  ,p_assignment_status_type_id      in number
  ,p_payroll_id                     in number
  ,p_location_id                    in number
  ,p_person_referred_by_id          in number
  ,p_supervisor_id                  in number
  ,p_special_ceiling_step_id        in number
  ,p_person_id                      in number
  ,p_recruitment_activity_id        in number
  ,p_source_organization_id         in number
  ,p_organization_id                in number
  ,p_people_group_id                in number
  ,p_soft_coding_keyflex_id         in number
  ,p_vacancy_id                     in number
  ,p_pay_basis_id                   in number
  ,p_assignment_sequence            in number
  ,p_assignment_type                in varchar2
  ,p_primary_flag                   in varchar2
  ,p_application_id                 in number
  ,p_assignment_number              in varchar2
  ,p_change_reason                  in varchar2
  ,p_comment_id                     in number
  ,p_date_probation_end             in date
  ,p_default_code_comb_id           in number
  ,p_employment_category            in varchar2
  ,p_frequency                      in varchar2
  ,p_internal_address_line          in varchar2
  ,p_manager_flag                   in varchar2
  ,p_normal_hours                   in number
  ,p_perf_review_period             in number
  ,p_perf_review_period_frequen     in varchar2
  ,p_period_of_service_id           in number
  ,p_probation_period               in number
  ,p_probation_unit                 in varchar2
  ,p_sal_review_period              in number
  ,p_sal_review_period_frequen      in varchar2
  ,p_set_of_books_id                in number
  ,p_source_type                    in varchar2
  ,p_time_normal_finish             in varchar2
  ,p_time_normal_start              in varchar2
  ,p_bargaining_unit_code           in varchar2
  ,p_labour_union_member_flag       in varchar2
  ,p_hourly_salaried_code           in varchar2
  ,p_request_id                     in number
  ,p_program_application_id         in number
  ,p_program_id                     in number
  ,p_program_update_date            in date
  ,p_ass_attribute_category         in varchar2
  ,p_ass_attribute1                 in varchar2
  ,p_ass_attribute2                 in varchar2
  ,p_ass_attribute3                 in varchar2
  ,p_ass_attribute4                 in varchar2
  ,p_ass_attribute5                 in varchar2
  ,p_ass_attribute6                 in varchar2
  ,p_ass_attribute7                 in varchar2
  ,p_ass_attribute8                 in varchar2
  ,p_ass_attribute9                 in varchar2
  ,p_ass_attribute10                in varchar2
  ,p_ass_attribute11                in varchar2
  ,p_ass_attribute12                in varchar2
  ,p_ass_attribute13                in varchar2
  ,p_ass_attribute14                in varchar2
  ,p_ass_attribute15                in varchar2
  ,p_ass_attribute16                in varchar2
  ,p_ass_attribute17                in varchar2
  ,p_ass_attribute18                in varchar2
  ,p_ass_attribute19                in varchar2
  ,p_ass_attribute20                in varchar2
  ,p_ass_attribute21                in varchar2
  ,p_ass_attribute22                in varchar2
  ,p_ass_attribute23                in varchar2
  ,p_ass_attribute24                in varchar2
  ,p_ass_attribute25                in varchar2
  ,p_ass_attribute26                in varchar2
  ,p_ass_attribute27                in varchar2
  ,p_ass_attribute28                in varchar2
  ,p_ass_attribute29                in varchar2
  ,p_ass_attribute30                in varchar2
  ,p_title                          in varchar2
  ,p_contract_id                    in number
  ,p_establishment_id               in number
  ,p_collective_agreement_id        in number
  ,p_cagr_grade_def_id              in number
  ,p_cagr_id_flex_num               in number
  ,p_object_version_number          in number
  ,p_notice_period                  in number
  ,p_notice_period_uom              in varchar2
  ,p_employee_category              in varchar2
  ,p_work_at_home                   in varchar2
  ,p_job_post_source_name           in varchar2
  ,p_posting_content_id             in number
  ,p_placement_date_start           in date
  ,p_vendor_id                      in number
  ,p_vendor_employee_number         in varchar2
  ,p_vendor_assignment_number       in varchar2
  ,p_assignment_category            in varchar2
  ,p_project_title                  in varchar2
  ,p_applicant_rank                 in number
  ,p_grade_ladder_pgm_id            in number
  ,p_supervisor_assignment_id       in number
  ,p_vendor_site_id                 in number
  ,p_po_header_id                   in number
  ,p_po_line_id                     in number
  ,p_projected_assignment_end       in date
 );
end per_asg_rki;

/

--------------------------------------------------------
--  DDL for Package HR_PROCESS_ASSIGNMENT_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PROCESS_ASSIGNMENT_SS" AUTHID CURRENT_USER AS
/* $Header: hrascwrs.pkh 120.1.12010000.4 2010/03/26 07:22:41 gpurohit ship $*/

g_data_error            exception;
g_date_format  constant varchar2(10):='RRRR-MM-DD';
g_new_hire_registration  constant varchar2(30) := 'REGISTRATION';  --04/15/02
g_hire_an_applicant      constant varchar2(30) := 'APPLICANT_HIRE'; -- 2355929
g_canonical_date	constant date	     := to_date('4712-01-01', 'RRRR-MM-DD');

gv_ele_warning             constant varchar2(200) := 'HR_ELEMENT_WARNING';
-- NTF changes
-- added by Vineeth
TYPE ref_cursor IS REF CURSOR;

-- End of NTF changes
--

--
procedure update_object_version
  (p_transaction_step_id in     number
  ,p_login_person_id in number);

--
procedure get_asg_from_tt
(p_transaction_step_id in     number
,p_assignment_rec   out nocopy per_all_assignments_f%rowtype);
--
procedure get_assignment_from_tt
(p_item_type                in     varchar2
,p_item_key                 in     varchar2
,p_actid                    in     varchar2
,p_transaction_step_id      in     varchar2
,p_assignment_id            out nocopy varchar2
,p_object_version_number    out nocopy varchar2
,p_effective_date           out nocopy varchar2
,p_grade_id                 out nocopy varchar2
,p_position_id              out nocopy varchar2
,p_job_id                   out nocopy varchar2
,p_location_id              out nocopy varchar2
,p_special_ceiling_step_id  out nocopy varchar2
,p_organization_id          out nocopy varchar2
,p_employment_category      out nocopy varchar2
,p_supervisor_id            out nocopy varchar2
,p_manager_flag             out nocopy varchar2
,p_normal_hours             out nocopy varchar2
,p_frequency                out nocopy varchar2
,p_time_normal_finish       out nocopy varchar2
,p_time_normal_start        out nocopy varchar2
,p_bargaining_unit_code     out nocopy varchar2
,p_labour_union_member_flag out nocopy varchar2
,p_assignment_status_type_id out nocopy varchar2
,p_change_reason             out nocopy varchar2
,p_ass_attribute_category    out nocopy varchar2
,p_ass_attribute1            out nocopy varchar2
,p_ass_attribute2            out nocopy varchar2
,p_ass_attribute3            out nocopy varchar2
,p_ass_attribute4            out nocopy varchar2
,p_ass_attribute5            out nocopy varchar2
,p_ass_attribute6            out nocopy varchar2
,p_ass_attribute7            out nocopy varchar2
,p_ass_attribute8            out nocopy varchar2
,p_ass_attribute9            out nocopy varchar2
,p_ass_attribute10           out nocopy varchar2
,p_ass_attribute11           out nocopy varchar2
,p_ass_attribute12           out nocopy varchar2
,p_ass_attribute13           out nocopy varchar2
,p_ass_attribute14           out nocopy varchar2
,p_ass_attribute15           out nocopy varchar2
,p_ass_attribute16           out nocopy varchar2
,p_ass_attribute17           out nocopy varchar2
,p_ass_attribute18           out nocopy varchar2
,p_ass_attribute19           out nocopy varchar2
,p_ass_attribute20           out nocopy varchar2
,p_ass_attribute21           out nocopy varchar2
,p_ass_attribute22           out nocopy varchar2
,p_ass_attribute23           out nocopy varchar2
,p_ass_attribute24           out nocopy varchar2
,p_ass_attribute25           out nocopy varchar2
,p_ass_attribute26           out nocopy varchar2
,p_ass_attribute27           out nocopy varchar2
,p_ass_attribute28           out nocopy varchar2
,p_ass_attribute29           out nocopy varchar2
,p_ass_attribute30           out nocopy varchar2
,p_soft_coding_keyflex_id    out nocopy varchar2
,p_people_group_id           out nocopy varchar2
,p_org_name                  out nocopy varchar2
,p_job_name                  out nocopy varchar2
,p_pos_name                  out nocopy varchar2
,p_grade_name                out nocopy varchar2
,p_contract_id               out nocopy varchar2
,p_establishment_id          out nocopy varchar2
,p_cagr_grade_def_id         out nocopy varchar2
,p_collective_agreement_id   out nocopy varchar2
,p_cagr_id_flex_num          out nocopy varchar2
,p_payroll_id                out nocopy varchar2
,p_pay_basis_id              out nocopy varchar2
,p_sal_review_period         out nocopy varchar2
,p_sal_review_period_frequency out nocopy varchar2
,p_date_probation_end        out nocopy varchar2
,p_probation_period          out nocopy varchar2
,p_probation_unit            out nocopy varchar2
,p_notice_period             out nocopy varchar2
,p_notice_period_uom         out nocopy varchar2
,p_employee_category         out nocopy varchar2
,p_work_at_home              out nocopy varchar2
,p_job_post_source_name      out nocopy varchar2
,p_perf_review_period        out nocopy varchar2
,p_perf_review_period_frequency out nocopy varchar2
,p_internal_address_line     out nocopy varchar2
,p_display_org               out nocopy varchar2
,p_display_job               out nocopy varchar2
,p_display_pos               out nocopy varchar2
,p_display_grade             out nocopy varchar2
,p_display_ass_status        out nocopy varchar2
,p_business_group_id         out nocopy varchar2
,p_title                     out nocopy varchar2
,p_default_code_comb_id      out nocopy varchar2
,p_set_of_books_id           out nocopy varchar2
,p_source_type               out nocopy varchar2
,p_project_title             out nocopy varchar2
,p_vendor_assignment_number  out nocopy varchar2
,p_vendor_employee_number    out nocopy varchar2
,p_vendor_id                 out nocopy varchar2
,p_assignment_type           out nocopy varchar2
,p_grade_ladder_pgm_id       out nocopy varchar2
,p_supervisor_assignment_id  out nocopy varchar2
,p_vendor_name               out nocopy varchar2
,p_po_header_id                 out nocopy varchar2
,p_po_line_id                 out nocopy varchar2
,p_vendor_site_id                 out nocopy varchar2
,p_po_number                 out nocopy varchar2
,p_po_line_number                 out nocopy varchar2
,p_vendor_site_name                 out nocopy varchar2
,p_projected_asgn_end         out nocopy date

);
--
procedure get_assignment_from_tt
(p_transaction_step_id in     number
,p_assignment_id             out nocopy number
,p_object_version_number     out nocopy number
,p_effective_date            out nocopy varchar2
,p_grade_id                  out nocopy number
,p_position_id               out nocopy number
,p_job_id                    out nocopy number
,p_location_id               out nocopy number
,p_special_ceiling_step_id   out nocopy number
,p_organization_id           out nocopy number
,p_employment_category       out nocopy varchar2
,p_supervisor_id             out nocopy number
,p_manager_flag              out nocopy varchar2
,p_normal_hours              out nocopy number
,p_frequency                 out nocopy varchar2
,p_time_normal_finish        out nocopy varchar2
,p_time_normal_start         out nocopy varchar2
,p_bargaining_unit_code      out nocopy varchar2
,p_labour_union_member_flag    out nocopy varchar2
,p_assignment_status_type_id out nocopy number
,p_change_reason             out nocopy varchar2
,p_ass_attribute_category    out nocopy varchar2
,p_ass_attribute1            out nocopy varchar2
,p_ass_attribute2            out nocopy varchar2
,p_ass_attribute3            out nocopy varchar2
,p_ass_attribute4            out nocopy varchar2
,p_ass_attribute5            out nocopy varchar2
,p_ass_attribute6            out nocopy varchar2
,p_ass_attribute7            out nocopy varchar2
,p_ass_attribute8            out nocopy varchar2
,p_ass_attribute9            out nocopy varchar2
,p_ass_attribute10           out nocopy varchar2
,p_ass_attribute11           out nocopy varchar2
,p_ass_attribute12           out nocopy varchar2
,p_ass_attribute13           out nocopy varchar2
,p_ass_attribute14           out nocopy varchar2
,p_ass_attribute15           out nocopy varchar2
,p_ass_attribute16           out nocopy varchar2
,p_ass_attribute17           out nocopy varchar2
,p_ass_attribute18           out nocopy varchar2
,p_ass_attribute19           out nocopy varchar2
,p_ass_attribute20           out nocopy varchar2
,p_ass_attribute21           out nocopy varchar2
,p_ass_attribute22           out nocopy varchar2
,p_ass_attribute23           out nocopy varchar2
,p_ass_attribute24           out nocopy varchar2
,p_ass_attribute25           out nocopy varchar2
,p_ass_attribute26           out nocopy varchar2
,p_ass_attribute27           out nocopy varchar2
,p_ass_attribute28           out nocopy varchar2
,p_ass_attribute29           out nocopy varchar2
,p_ass_attribute30           out nocopy varchar2
,p_soft_coding_keyflex_id    out nocopy number
,p_people_group_id           out nocopy number
,p_contract_id               out nocopy number
,p_establishment_id          out nocopy number
,p_cagr_grade_def_id         out nocopy number
,p_collective_agreement_id   out nocopy number
,p_cagr_id_flex_num          out nocopy number
,p_payroll_id                out nocopy number
,p_pay_basis_id              out nocopy number
,p_sal_review_period         out nocopy number
,p_sal_review_period_frequency out nocopy varchar2
,p_date_probation_end        out nocopy date
,p_probation_period          out nocopy number
,p_probation_unit            out nocopy varchar2
,p_notice_period             out nocopy number
,p_notice_period_uom         out nocopy varchar2
,p_employee_category         out nocopy varchar2
,p_work_at_home              out nocopy varchar2
,p_job_post_source_name      out nocopy varchar2
,p_perf_review_period        out nocopy number
,p_perf_review_period_frequency out nocopy varchar2
,p_internal_address_line     out nocopy varchar2
,p_display_org               out nocopy varchar2
,p_display_job               out nocopy varchar2
,p_display_pos               out nocopy varchar2
,p_display_grade             out nocopy varchar2
,p_display_ass_status        out nocopy varchar2
,p_business_group_id         out nocopy number
,p_title                     out nocopy varchar2
,p_default_code_comb_id      out nocopy number
,p_set_of_books_id           out nocopy number
,p_source_type               out nocopy varchar2
,p_project_title             out nocopy varchar2
,p_vendor_assignment_number  out nocopy varchar2
,p_vendor_employee_number    out nocopy varchar2
,p_vendor_id                 out nocopy number
,p_assignment_type           out nocopy varchar2
,p_grade_ladder_pgm_id       out nocopy number
,p_supervisor_assignment_id  out nocopy number
,p_po_header_id                 out nocopy number
,p_po_line_id                out nocopy number
,p_vendor_site_id                 out nocopy number
,p_projected_asgn_end       out nocopy date
);


procedure process_save
(p_save_mode                in     varchar2 default null
,p_item_type                in     varchar2
,p_item_key                 in     varchar2
,p_actid                    in     varchar2
,p_login_person_id          in     varchar2 default null
,p_assignment_id            in     varchar2
,p_object_version_number    in     varchar2
,p_effective_date           in     varchar2
,p_grade_id                 in     varchar2 default to_char(hr_api.g_number)
,p_position_id              in     varchar2 default to_char(hr_api.g_number)
,p_job_id                   in     varchar2 default to_char(hr_api.g_number)
,p_location_id              in     varchar2 default to_char(hr_api.g_number)
,p_special_ceiling_step_id  in     varchar2 default to_char(hr_api.g_number)
,p_organization_id          in     varchar2 default to_char(hr_api.g_number)
,p_employment_category      in     varchar2 default hr_api.g_varchar2
,p_supervisor_id            in     varchar2 default to_char(hr_api.g_number)
,p_manager_flag             in     varchar2 default hr_api.g_varchar2
,p_normal_hours             in     varchar2 default to_char(hr_api.g_number)
,p_frequency                in     varchar2 default hr_api.g_varchar2
,p_time_normal_finish       in     varchar2 default hr_api.g_varchar2
,p_time_normal_start        in     varchar2 default hr_api.g_varchar2
,p_bargaining_unit_code     in     varchar2 default hr_api.g_varchar2
,p_labour_union_member_flag in     varchar2 default hr_api.g_varchar2
,p_assignment_status_type_id in    varchar2 default to_char(hr_api.g_number)
,p_change_reason            in     varchar2 default hr_api.g_varchar2
,p_ass_attribute_category   in     varchar2 default hr_api.g_varchar2
,p_ass_attribute1           in     varchar2 default hr_api.g_varchar2
,p_ass_attribute2           in     varchar2 default hr_api.g_varchar2
,p_ass_attribute3           in     varchar2 default hr_api.g_varchar2
,p_ass_attribute4           in     varchar2 default hr_api.g_varchar2
,p_ass_attribute5           in     varchar2 default hr_api.g_varchar2
,p_ass_attribute6           in     varchar2 default hr_api.g_varchar2
,p_ass_attribute7           in     varchar2 default hr_api.g_varchar2
,p_ass_attribute8           in     varchar2 default hr_api.g_varchar2
,p_ass_attribute9           in     varchar2 default hr_api.g_varchar2
,p_ass_attribute10          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute11          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute12          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute13          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute14          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute15          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute16          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute17          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute18          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute19          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute20          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute21          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute22          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute23          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute24          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute25          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute26          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute27          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute28          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute29          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute30          in     varchar2 default hr_api.g_varchar2
,p_soft_coding_keyflex_id   in     varchar2 default to_char(hr_api.g_number)
,p_people_group_id          in     varchar2 default to_char(hr_api.g_number)
,p_hrs_last_date            in     varchar2 default hr_api.g_varchar2
,p_display_pos              in     varchar2 default hr_api.g_varchar2
,p_display_org              in     varchar2 default hr_api.g_varchar2
,p_display_job              in     varchar2 default hr_api.g_varchar2
,p_display_ass_status       in     varchar2 default hr_api.g_varchar2
,p_grade_lov                in     varchar2 default hr_api.g_varchar2
,p_approver_id              in     varchar2   default to_char(hr_api.g_number)
,p_review_proc_call         in     varchar2
,p_display_grade            in     varchar2 default hr_api.g_varchar2
,p_contract_id              in     varchar2 default to_char(hr_api.g_number)
,p_establishment_id         in     varchar2 default to_char(hr_api.g_number)
,p_cagr_grade_def_id        in     varchar2 default to_char(hr_api.g_number)
,p_collective_agreement_id  in     varchar2 default to_char(hr_api.g_number)
,p_cagr_id_flex_num         in     varchar2 default to_char(hr_api.g_number)
,p_payroll_id               in     varchar2   default to_char(hr_api.g_number)
,p_pay_basis_id             in     varchar2   default to_char(hr_api.g_number)
,p_sal_review_period        in     varchar2   default to_char(hr_api.g_number)
,p_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
,p_date_probation_end       in varchar2 default to_char(hr_api.g_date,g_date_format)
,p_probation_period         in varchar2 default to_char(hr_api.g_number)
,p_probation_unit           in varchar2 default hr_api.g_varchar2
,p_notice_period            in varchar2 default to_char(hr_api.g_number)
,p_notice_period_uom        in varchar2 default hr_api.g_varchar2
,p_employee_category        in varchar2 default hr_api.g_varchar2
,p_work_at_home             in varchar2 default hr_api.g_varchar2
,p_job_post_source_name     in varchar2 default hr_api.g_varchar2
,p_perf_review_period       in varchar2 default to_char(hr_api.g_number)
,p_perf_review_period_frequency in varchar2 default hr_api.g_varchar2
,p_internal_address_line    in varchar2 default hr_api.g_varchar2
,p_element_changed          in out nocopy varchar2
,p_page_error               in out nocopy varchar2
,p_page_error_msg           in out nocopy varchar2
,p_page_warning             in out nocopy varchar2
,p_page_warning_msg         in out nocopy varchar2
,p_organization_error       in out nocopy varchar2
,p_organization_error_msg   in out nocopy varchar2
,p_job_error                in out nocopy varchar2
,p_job_error_msg            in out nocopy varchar2
,p_position_error           in out nocopy varchar2
,p_position_error_msg       in out nocopy varchar2
,p_grade_error              in out nocopy varchar2
,p_grade_error_msg          in out nocopy varchar2
,p_supervisor_error         in out nocopy varchar2
,p_supervisor_error_msg     in out nocopy varchar2
,p_location_error           in out nocopy varchar2
,p_location_error_msg       in out nocopy varchar2
,p_transaction_step_id      in out nocopy varchar2
,p_flow_mode                in     varchar2 default null
,p_rptg_grp_id              in     varchar2 default null
,p_plan_id                  in     varchar2 default null
,p_effective_date_option    in     varchar2 default null
,p_title                    in varchar2 default hr_api.g_varchar2
,p_default_code_comb_id     in varchar2 default to_char(hr_api.g_number)
,p_set_of_books_id          in varchar2 default to_char(hr_api.g_number)
,p_source_type              in varchar2 default hr_api.g_varchar2
,p_project_title            in varchar2 default hr_api.g_varchar2
,p_vendor_assignment_number in varchar2 default hr_api.g_varchar2
,p_vendor_employee_number   in varchar2 default hr_api.g_varchar2
,p_vendor_id                in varchar2 default to_char(hr_api.g_number)
,p_assignment_type          in varchar2 default hr_api.g_varchar2
,p_grade_ladder_pgm_id      in varchar2 default to_char(hr_api.g_number)
,p_supervisor_assignment_id in varchar2 default to_char(hr_api.g_number)
-- GSP changes
,p_salary_change_warning    in out nocopy varchar2
,p_gsp_post_process_warning out nocopy varchar2
,p_gsp_salary_effective_date out nocopy date
-- End of GSP changes
,p_po_header_id             in varchar2 default to_char(hr_api.g_number)
,p_po_line_id             in varchar2 default to_char(hr_api.g_number)
,p_vendor_site_id             in varchar2 default to_char(hr_api.g_number)
,p_projected_asgn_end in date  default g_canonical_date
);

procedure process_save
(p_save_mode                in     varchar2  default null
,p_item_type                in     wf_items.item_type%TYPE
,p_item_key                 in     wf_items.item_key%TYPE
,p_actid                    in wf_activity_attr_values.process_activity_id%type
,p_login_person_id          in     number
,p_assignment_id            in     number
,p_object_version_number    in     number
,p_effective_date           in     varchar2
,p_grade_id                 in     number   default hr_api.g_number
,p_position_id              in     number   default hr_api.g_number
,p_job_id                   in     number   default hr_api.g_number
,p_location_id              in     number   default hr_api.g_number
,p_special_ceiling_step_id  in     number   default hr_api.g_number
,p_organization_id          in     number   default hr_api.g_number
,p_employment_category      in     varchar2 default hr_api.g_varchar2
,p_supervisor_id            in     number   default hr_api.g_number
,p_manager_flag             in     varchar2 default hr_api.g_varchar2
,p_normal_hours             in     number   default hr_api.g_number
,p_frequency                in     varchar2 default hr_api.g_varchar2
,p_time_normal_finish       in     varchar2 default hr_api.g_varchar2
,p_time_normal_start        in     varchar2 default hr_api.g_varchar2
,p_bargaining_unit_code         in     varchar2 default hr_api.g_varchar2
,p_labour_union_member_flag     in     varchar2 default hr_api.g_varchar2
,p_assignment_status_type_id in    number   default hr_api.g_number
,p_change_reason            in     varchar2 default hr_api.g_varchar2
,p_ass_attribute_category   in     varchar2 default hr_api.g_varchar2
,p_ass_attribute1           in     varchar2 default hr_api.g_varchar2
,p_ass_attribute2           in     varchar2 default hr_api.g_varchar2
,p_ass_attribute3           in     varchar2 default hr_api.g_varchar2
,p_ass_attribute4           in     varchar2 default hr_api.g_varchar2
,p_ass_attribute5           in     varchar2 default hr_api.g_varchar2
,p_ass_attribute6           in     varchar2 default hr_api.g_varchar2
,p_ass_attribute7           in     varchar2 default hr_api.g_varchar2
,p_ass_attribute8           in     varchar2 default hr_api.g_varchar2
,p_ass_attribute9           in     varchar2 default hr_api.g_varchar2
,p_ass_attribute10          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute11          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute12          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute13          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute14          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute15          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute16          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute17          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute18          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute19          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute20          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute21          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute22          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute23          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute24          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute25          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute26          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute27          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute28          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute29          in     varchar2 default hr_api.g_varchar2
,p_ass_attribute30          in     varchar2 default hr_api.g_varchar2
,p_soft_coding_keyflex_id   in     number   default hr_api.g_number
,p_people_group_id          in     number   default hr_api.g_number
,p_hrs_last_date            in     varchar2 default hr_api.g_varchar2
,p_display_pos              in     varchar2 default hr_api.g_varchar2
,p_display_org              in     varchar2 default hr_api.g_varchar2
,p_display_job              in     varchar2 default hr_api.g_varchar2
,p_display_ass_status       in     varchar2 default hr_api.g_varchar2
,p_grade_lov                in     varchar2 default hr_api.g_varchar2
,p_approver_id              in     number   default hr_api.g_number
,p_review_proc_call         in     varchar2
,p_display_grade            in     varchar2 default hr_api.g_varchar2
,p_contract_id                  in     number default hr_api.g_number
,p_establishment_id             in     number default hr_api.g_number
,p_cagr_grade_def_id            in     number default hr_api.g_number
,p_collective_agreement_id      in     number default hr_api.g_number
,p_cagr_id_flex_num             in     number default hr_api.g_number
,p_payroll_id                   in     number default hr_api.g_number
,p_pay_basis_id                 in     number default hr_api.g_number
,p_sal_review_period            in     number default hr_api.g_number
,p_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
,p_date_probation_end       in date default hr_api.g_date
,p_probation_period         in number default hr_api.g_number
,p_probation_unit           in varchar2 default hr_api.g_varchar2
,p_notice_period            in number default hr_api.g_number
,p_notice_period_uom        in varchar2 default hr_api.g_varchar2
,p_employee_category        in varchar2 default hr_api.g_varchar2
,p_work_at_home             in varchar2 default hr_api.g_varchar2
,p_job_post_source_name     in varchar2 default hr_api.g_varchar2
,p_perf_review_period       in number default hr_api.g_number
,p_perf_review_period_frequency in varchar2 default hr_api.g_varchar2
,p_internal_address_line    in varchar2 default hr_api.g_varchar2
,p_element_changed          in out nocopy varchar2
,p_page_error               in out nocopy varchar2
,p_page_error_msg           in out nocopy varchar2
,p_page_warning             in out nocopy varchar2
,p_page_warning_msg         in out nocopy varchar2
,p_organization_error       in out nocopy varchar2
,p_organization_error_msg   in out nocopy varchar2
,p_job_error                in out nocopy varchar2
,p_job_error_msg            in out nocopy varchar2
,p_position_error           in out nocopy varchar2
,p_position_error_msg       in out nocopy varchar2
,p_grade_error              in out nocopy varchar2
,p_grade_error_msg          in out nocopy varchar2
,p_supervisor_error         in out nocopy varchar2
,p_supervisor_error_msg     in out nocopy varchar2
,p_location_error           in out nocopy varchar2
,p_location_error_msg       in out nocopy varchar2
,p_transaction_step_id      in out nocopy varchar2
,p_flow_mode                in     varchar2 default null
,p_rptg_grp_id              in     varchar2 default null
,p_plan_id                  in     varchar2 default null
,p_effective_date_option    in     varchar2 default null
,p_title                    in varchar2 default hr_api.g_varchar2
,p_default_code_comb_id     in number default hr_api.g_number
,p_set_of_books_id          in number default hr_api.g_number
,p_source_type              in varchar2 default hr_api.g_varchar2
,p_project_title            in varchar2 default hr_api.g_varchar2
,p_vendor_assignment_number in varchar2 default hr_api.g_varchar2
,p_vendor_employee_number   in varchar2 default hr_api.g_varchar2
,p_vendor_id                in number default hr_api.g_number
,p_assignment_type          in varchar2 default hr_api.g_varchar2
,p_grade_ladder_pgm_id      in number default hr_api.g_number
,p_supervisor_assignment_id in number default hr_api.g_number
-- GSP changes
,p_salary_change_warning    in out nocopy varchar2
,p_gsp_post_process_warning out nocopy varchar2
,p_gsp_salary_effective_date out nocopy date
-- End of GSP changes
,p_po_header_id in number default hr_api.g_number
,p_po_line_id in number default hr_api.g_number
,p_vendor_site_id in number default hr_api.g_number
,p_proj_asgn_end       in date default g_canonical_date

);


-- This procedure is to recover all of the assignment data from the transaction
-- tables and save the data into database.
procedure process_api
(p_validate                 in     boolean default false
,p_transaction_step_id      in     number
,p_effective_date           in     varchar2 default null
);

-- This is the procedure to update the assignment data, including
-- the People Group and Soft Coded Key Flexfields
procedure update_assignment
(p_validate                 in     boolean default false
,p_login_person_id          in     number default null
,p_new_hire_appl_hire       in     varchar2 default 'N'
,p_assignment_id            in     number
,p_object_version_number    in     number
,p_effective_date           in     date
,p_datetrack_update_mode    in     varchar2
,p_organization_id          in     number
,p_position_id              in     number   default null
,p_job_id                   in     number   default null
,p_grade_id                 in     number   default null
,p_location_id              in     number   default null
,p_employment_category      in     varchar2 default null
,p_supervisor_id            in     number   default null
,p_manager_flag             in     varchar2 default null
,p_normal_hours             in     number   default null
,p_frequency                in     varchar2 default null
,p_time_normal_finish       in     varchar2 default null
,p_time_normal_start        in     varchar2 default null
,p_bargaining_unit_code         in     varchar2 default null
,p_labour_union_member_flag     in     varchar2 default null
,p_assignment_status_type_id in    number   default null
,p_change_reason            in     varchar2 default null
,p_ass_attribute_category   in     varchar2 default null
,p_ass_attribute1           in     varchar2 default null
,p_ass_attribute2           in     varchar2 default null
,p_ass_attribute3           in     varchar2 default null
,p_ass_attribute4           in     varchar2 default null
,p_ass_attribute5           in     varchar2 default null
,p_ass_attribute6           in     varchar2 default null
,p_ass_attribute7           in     varchar2 default null
,p_ass_attribute8           in     varchar2 default null
,p_ass_attribute9           in     varchar2 default null
,p_ass_attribute10          in     varchar2 default null
,p_ass_attribute11          in     varchar2 default null
,p_ass_attribute12          in     varchar2 default null
,p_ass_attribute13          in     varchar2 default null
,p_ass_attribute14          in     varchar2 default null
,p_ass_attribute15          in     varchar2 default null
,p_ass_attribute16          in     varchar2 default null
,p_ass_attribute17          in     varchar2 default null
,p_ass_attribute18          in     varchar2 default null
,p_ass_attribute19          in     varchar2 default null
,p_ass_attribute20          in     varchar2 default null
,p_ass_attribute21          in     varchar2 default null
,p_ass_attribute22          in     varchar2 default null
,p_ass_attribute23          in     varchar2 default null
,p_ass_attribute24          in     varchar2 default null
,p_ass_attribute25          in     varchar2 default null
,p_ass_attribute26          in     varchar2 default null
,p_ass_attribute27          in     varchar2 default null
,p_ass_attribute28          in     varchar2 default null
,p_ass_attribute29          in     varchar2 default null
,p_ass_attribute30          in     varchar2 default null
,p_soft_coding_keyflex_id   in out nocopy    number
,p_people_group_id          in     number   default null
,p_contract_id                  in     number default null
,p_establishment_id             in     number default null
,p_cagr_grade_def_id            in     number default null
,p_collective_agreement_id      in     number default null
,p_cagr_id_flex_num             in     number default null
,p_payroll_id                   in     number default null
,p_pay_basis_id                 in     number default null
,p_sal_review_period            in     number default null
,p_sal_review_period_frequency  in     varchar2 default null
,p_date_probation_end       in date default null
,p_probation_period         in number default null
,p_probation_unit           in varchar2 default null
,p_notice_period            in number default null
,p_notice_period_uom        in varchar2 default null
,p_employee_category        in varchar2 default null
,p_work_at_home             in varchar2 default null
,p_job_post_source_name     in varchar2 default null
,p_perf_review_period       in number default null
,p_perf_review_period_frequency in varchar2 default null
,p_internal_address_line    in varchar2 default null
,p_business_group_id        in     per_all_assignments_f.business_group_id%TYPE
--GSP change
,p_grade_ladder_pgm_id      in     per_all_assignments_f.grade_ladder_pgm_id%TYPE
-- End of GSP change
,p_assignment_type          in     per_all_assignments_f.assignment_type%TYPE
,p_vacancy_id               in     per_all_assignments_f.vacancy_id%TYPE
,p_special_ceiling_step_id  in out nocopy per_all_assignments_f.special_ceiling_step_id%TYPE
,p_primary_flag             in     per_all_assignments_f.primary_flag%TYPE
,p_person_id                in     per_all_assignments_f.person_id%TYPE
,p_effective_start_date        out nocopy date
,p_effective_end_date          out nocopy date
,p_element_warning          in     boolean
,p_element_changed          in out nocopy varchar2
,p_email_id                 in     varchar2 default null
,p_page_error               in out nocopy varchar2
,p_page_error_msg           in out nocopy varchar2
,p_page_warning             in out nocopy varchar2
,p_page_warning_msg         in out nocopy varchar2
,p_organization_error       in out nocopy varchar2
,p_organization_error_msg   in out nocopy varchar2
,p_job_error                in out nocopy varchar2
,p_job_error_msg            in out nocopy varchar2
,p_position_error           in out nocopy varchar2
,p_position_error_msg       in out nocopy varchar2
,p_grade_error              in out nocopy varchar2
,p_grade_error_msg          in out nocopy varchar2
,p_supervisor_error         in out nocopy varchar2
,p_supervisor_error_msg     in out nocopy varchar2
,p_location_error           in out nocopy varchar2
,p_location_error_msg       in out nocopy varchar2
,p_title                    in varchar2 default null
,p_default_code_comb_id     in number default null
,p_set_of_books_id          in number default null
,p_source_type              in varchar2 default null
,p_project_title            in varchar2 default null
,p_vendor_assignment_number in varchar2 default null
,p_vendor_employee_number   in varchar2 default null
,p_vendor_id                in number default null
--GSP populates salary information GL assignment
,p_ltt_salary_data    IN OUT NOCOPY  sshr_sal_prop_tab_typ
,p_gsp_post_process_warning out nocopy varchar2
-- End of GSP
,p_po_header_id                in number default null
,p_po_line_id                in number default null
,p_vendor_site_id                in number default null
,p_projected_asgn_end        in date default null
,p_j_changed	in varchar2	default 'Y'
);

procedure update_apl_assignment
(p_validate	in boolean default false,
p_assignment_rec in out nocopy per_all_assignments_f%rowtype,
p_effective_date	in date,
p_person_id	in number,
p_appl_assignment_id	in number,
p_person_type_id	in number,
p_overwrite_primary	in varchar2,
p_ovn	in number
);
--
-- NTF changes
function get_assignment
(p_transaction_step_id in number) return ref_cursor;

function get_rec_cnt return NUMBER;

--End of NTF changes
--

FUNCTION get_po_number(p_po_header_id in number)
   RETURN VARCHAR2;

FUNCTION get_po_line_nuber(p_po_line_id in number)
   RETURN number;

FUNCTION get_vend_site_name(p_vendor_site_id in number)
   RETURN VARCHAR2;

FUNCTION get_probation_end_date(p_probation_end_date in varchar2)
   RETURN varchar2;

end hr_process_assignment_ss;

/

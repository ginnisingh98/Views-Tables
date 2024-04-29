--------------------------------------------------------
--  DDL for Package Body HR_PROCESS_ASSIGNMENT_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PROCESS_ASSIGNMENT_SS" AS
/* $Header: hrascwrs.pkb 120.16.12010000.20 2010/05/12 14:51:08 gpurohit ship $*/


g_package      constant varchar2(75):='HR_PROCESS_ASSIGNMENT_SS.';
g_api_name     constant varchar2(75):=g_package || 'PROCESS_API';
g_data_error            exception;
--g_date_format  constant varchar2(10):='RRRR/MM/DD';
g_registration boolean :=false;
g_applicant_hire boolean := false;
g_exemp_hire boolean := false;
--

-- bug 5032032
PROCEDURE update_salary_proposal(p_assignment_id number
                                 , p_effective_date date) IS

     l_pay_proposal_id           per_pay_proposals.pay_proposal_id%TYPE;
     l_pyp_object_version_number per_pay_proposals.object_version_number%TYPE;
     l_change_date               per_pay_proposals.change_date%TYPE;
     l_proposed_salary           per_pay_proposals.PROPOSED_SALARY_N%TYPE;
     l_approved_flag             varchar2(1) := 'Y';
     l_inv_next_sal_date_warning boolean;
     l_proposed_salary_warning   boolean;
     l_approved_warning          boolean;
     l_payroll_warning           boolean;

     cursor csr_payproposal is
        select pay_proposal_id, object_version_number, change_date
              ,PROPOSED_SALARY_N
          from per_pay_proposals
          where assignment_id = p_assignment_id
          order by change_date DESC;
  BEGIN
    open csr_payproposal;
    fetch csr_payproposal into l_pay_proposal_id, l_pyp_object_version_number
                              ,l_change_date, l_proposed_salary;
    if csr_payproposal%found and l_change_date < p_effective_date then

        hr_maintain_proposal_api.cre_or_upd_salary_proposal
          (p_pay_proposal_id              => l_pay_proposal_id
          ,p_object_version_number        => l_pyp_object_version_number
          ,p_change_date                  => p_effective_date
          ,p_approved                     => l_approved_flag
          ,p_inv_next_sal_date_warning    => l_inv_next_sal_date_warning
          ,p_proposed_salary_warning      => l_proposed_salary_warning
          ,p_approved_warning             => l_approved_warning
          ,p_payroll_warning              => l_payroll_warning
        );
    end if;
    close csr_payproposal;
  END update_salary_proposal;


-- bug 5032032
procedure get_asg_from_tt
(p_transaction_step_id in     number
,p_assignment_rec   out nocopy per_all_assignments_f%rowtype) is
l_proc   varchar2(72)  := g_package||'get_asg_from_tt';

begin
--dbms_output.put_line(' ');
hr_utility.set_location('Entering:'||l_proc, 5);
p_assignment_rec.assignment_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_ASSIGNMENT_ID');
--
p_assignment_rec.object_version_number :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_OBJECT_VERSION_NUMBER');
--
p_assignment_rec.business_group_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_BUSINESS_GROUP_ID');
--
p_assignment_rec.person_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PERSON_ID');
--
p_assignment_rec.organization_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ORGANIZATION_ID');
--
p_assignment_rec.grade_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_GRADE_ID');
--
p_assignment_rec.position_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_POSITION_ID');
--
p_assignment_rec.job_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_JOB_ID');
--
p_assignment_rec.location_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_LOCATION_ID');
--
p_assignment_rec.special_ceiling_step_id  :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SPECIAL_CEILING_STEP_ID');
--
p_assignment_rec.employment_category :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EMPLOYMENT_CATEGORY');
--
p_assignment_rec.supervisor_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SUPERVISOR_ID');
--
p_assignment_rec.manager_flag :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_MANAGER_FLAG');
--
p_assignment_rec.normal_hours  :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NORMAL_HOURS');
--
p_assignment_rec.frequency :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_FREQUENCY');
--
p_assignment_rec.time_normal_finish  :=
    substr(hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TIME_NORMAL_FINISH'),0,5);
--
p_assignment_rec.time_normal_start :=
    substr(hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TIME_NORMAL_START'),0,5);
--
p_assignment_rec.bargaining_unit_code  :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_BARGAINING_UNIT_CODE');
--
p_assignment_rec.labour_union_member_flag :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_LABOUR_UNION_MEMBER_FLAG');
--
p_assignment_rec.assignment_status_type_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASSIGNMENT_STATUS_TYPE_ID');
--
p_assignment_rec.change_reason  :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CHANGE_REASON');
--
p_assignment_rec.ass_attribute_category :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE_CATEGORY');
--
p_assignment_rec.ass_attribute1 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE1');
--
p_assignment_rec.ass_attribute2 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE2');
--
p_assignment_rec.ass_attribute3 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE3');
--
p_assignment_rec.ass_attribute4 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE4');
--
p_assignment_rec.ass_attribute5 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE5');
--
p_assignment_rec.ass_attribute6 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE6');
--
p_assignment_rec.ass_attribute7 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE7');
--
p_assignment_rec.ass_attribute8 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE8');
--
p_assignment_rec.ass_attribute9 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE9');
--
p_assignment_rec.ass_attribute10 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE10');
--
p_assignment_rec.ass_attribute11 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE11');
--
p_assignment_rec.ass_attribute12 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE12');
--
p_assignment_rec.ass_attribute13 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE13');
--
p_assignment_rec.ass_attribute14 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE14');
--
p_assignment_rec.ass_attribute15 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE15');
--
p_assignment_rec.ass_attribute16 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE16');
--
p_assignment_rec.ass_attribute17 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE17');
--
p_assignment_rec.ass_attribute18 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE18');
--
p_assignment_rec.ass_attribute19 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE19');
--
p_assignment_rec.ass_attribute20 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE20');
--
p_assignment_rec.ass_attribute21 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE21');
--
p_assignment_rec.ass_attribute22 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE22');
--
p_assignment_rec.ass_attribute23 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE23');
--
p_assignment_rec.ass_attribute24 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE24');
--
p_assignment_rec.ass_attribute25 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE25');
--
p_assignment_rec.ass_attribute26 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE26');
--
p_assignment_rec.ass_attribute27 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE27');
--
p_assignment_rec.ass_attribute28 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE28');
--
p_assignment_rec.ass_attribute29 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE29');
--
p_assignment_rec.ass_attribute30 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE30');
--
p_assignment_rec.contract_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CONTRACT_ID');
--
p_assignment_rec.establishment_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ESTABLISHMENT_ID');
--
p_assignment_rec.cagr_grade_def_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CAGR_GRADE_DEF_ID');
--
p_assignment_rec.collective_agreement_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_COLLECTIVE_AGREEMENT_ID');
--
p_assignment_rec.cagr_id_flex_num :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CAGR_ID_FLEX_NUM');
--
p_assignment_rec.payroll_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PAYROLL_ID');
--
p_assignment_rec.pay_basis_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PAY_BASIS_ID');
--
p_assignment_rec.sal_review_period :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SAL_REVIEW_PERIOD');
--
p_assignment_rec.sal_review_period_frequency :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SAL_REVIEW_PERIOD_FREQUENCY');

--
p_assignment_rec.date_probation_end :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DATE_PROBATION_END');
--
p_assignment_rec.probation_period :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PROBATION_PERIOD');
--
p_assignment_rec.probation_unit :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PROBATION_UNIT');
--
p_assignment_rec.notice_period :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NOTICE_PERIOD');
--
p_assignment_rec.notice_period_uom :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NOTICE_PERIOD_UOM');
--
p_assignment_rec.employee_category :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EMPLOYEE_CATEGORY');
--
p_assignment_rec.work_at_home :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_WORK_AT_HOME');
--
p_assignment_rec.job_post_source_name :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_JOB_POST_SOURCE_NAME');
--
p_assignment_rec.perf_review_period :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PERF_REVIEW_PERIOD');
--
p_assignment_rec.perf_review_period_frequency :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PERF_REVIEW_PERIOD_FREQUENCY');
--
p_assignment_rec.internal_address_line :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INTERNAL_ADDRESS_LINE');
--
p_assignment_rec.people_group_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PEOPLE_GROUP_ID');
--
p_assignment_rec.soft_coding_keyflex_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SOFT_CODING_KEYFLEX_ID');
--
p_assignment_rec.title:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TITLE');
--
  p_assignment_rec.project_title:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PROJECT_TITLE');
--
  p_assignment_rec.source_type:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SOURCE_TYPE');
--
  p_assignment_rec.vendor_assignment_number:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_VENDOR_ASSIGNMENT_NUMBER');
--
  p_assignment_rec.vendor_employee_number:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_VENDOR_EMPLOYEE_NUMBER');
--
  p_assignment_rec.default_code_comb_id := to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DEFAULT_CODE_COMB_ID'));
--
  p_assignment_rec.set_of_books_id := to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SET_OF_BOOKS_ID'));
--
  p_assignment_rec.vendor_id := to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_VENDOR_ID'));
--
  p_assignment_rec.assignment_type:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASSIGNMENT_TYPE');
--
  -- GSP change
  p_assignment_rec.grade_ladder_pgm_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_GRADE_LADDER_PGM_ID');
  -- End of GSP change

  --p_assignment_rec.supervisor_assignment_id:=
  --  hr_transaction_api.get_number_value
  --  (p_transaction_step_id => p_transaction_step_id
  --  ,p_name                => 'P_SUPERVISOR_ASSIGNMENT_ID');
--

  p_assignment_rec.po_header_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PO_HEADER_ID');

  p_assignment_rec.po_line_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PO_LINE_ID');

  p_assignment_rec.vendor_site_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_VENDOR_SITE_ID');


  p_assignment_rec.projected_assignment_end :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PROJ_ASGN_END');

hr_utility.set_location('Exiting:'||l_proc, 15);
end get_asg_from_tt;
--
procedure get_assignment_from_tt
(p_item_type                in     varchar2
,p_item_key                 in     varchar2
,p_actid                    in     varchar2
,p_transaction_step_id      in     varchar2
,p_assignment_id             out nocopy varchar2
,p_object_version_number     out nocopy varchar2
,p_effective_date            out nocopy varchar2
,p_grade_id                  out nocopy varchar2
,p_position_id               out nocopy varchar2
,p_job_id                    out nocopy varchar2
,p_location_id               out nocopy varchar2
,p_special_ceiling_step_id   out nocopy varchar2
,p_organization_id           out nocopy varchar2
,p_employment_category       out nocopy varchar2
,p_supervisor_id             out nocopy varchar2
,p_manager_flag              out nocopy varchar2
,p_normal_hours              out nocopy varchar2
,p_frequency                 out nocopy varchar2
,p_time_normal_finish        out nocopy varchar2
,p_time_normal_start         out nocopy varchar2
,p_bargaining_unit_code      out nocopy varchar2
,p_labour_union_member_flag  out nocopy varchar2
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
,p_projected_asgn_end        out nocopy date


)is

cursor csr_org_name(p_id in number) is
select name
from hr_organization_units
where organization_id = p_id;

cursor csr_job_name(p_id in number) is
select name
from per_jobs_vl
where job_id = p_id;

cursor csr_pos_name(p_id in number) is
select name
from hr_positions_f
where position_id = p_id
and to_date(p_effective_date,g_date_format)
between effective_start_date
and effective_end_date;

cursor csr_grade_name(p_id in number) is
select name
from per_grades_vl
where grade_id = p_id;

cursor csr_vendor_name(p_id in number) is
select vendor_name
from po_vendors
where vendor_id = p_id;

cursor csr_po_number(p_id in number) is
-- 4894113: R12 performance repository related fix
-- ISSUE : Shared memory size 2,413,494
-- RESOLUTION:
-- 1.Since we are interested only in  poh.segment1 we can
-- drop the rest of the columns and unwanted WHERE clauses from the
-- view po_temp_labor_headers_v
-- 2. The SQL below we have retained all the WHERE clauses
-- dealing with the table po_headers_all, but dropped the rest
-- which are not required in this case.

SELECT poh.segment1 po_number
FROM
    po_headers_all poh
WHERE
    poh.po_header_id = p_id
    AND poh.type_lookup_code = 'STANDARD'
    AND poh.authorization_status IN ('APPROVED', 'PRE-APPROVED')
    AND poh.approved_flag = 'Y'
    AND poh.enabled_flag = 'Y'
    AND NVL(poh.cancel_flag, 'N') <> 'Y'
    AND NVL(poh.frozen_flag, 'N') <> 'Y'
    AND poh.org_id IS NOT NULL
    AND EXISTS
    (
    SELECT
        NULL
    FROM po_lines_all pol ,
        po_line_types_b polt
    WHERE pol.po_header_id = poh.po_header_id
        AND NVL(pol.cancel_flag, 'N') <> 'Y'
        AND pol.line_type_id = polt.line_type_id
        AND polt.purchase_basis = 'TEMP LABOR'
    );

--select po_number
--from po_temp_labor_headers_v
--where po_header_id = p_id;

cursor csr_po_line_number(p_id in number) is
select line_number
from po_temp_labor_lines_v
where po_line_id = p_id;

cursor csr_vendor_site_name(p_id in number) is
select vendor_site_code
from po_vendor_sites_all
where vendor_site_id  = p_id;

  l_transaction_id       number;
  l_transaction_step_id  number;
  l_proc   varchar2(72)  := g_package||'get_assignment_from_tt';

begin


  hr_utility.set_location('Entering:'||l_proc, 5);
  if p_transaction_step_id is null then

    hr_utility.set_location('if p_transaction_step_id is null then:'||l_proc,10);
    hr_assignment_common_save_web.get_step
          (p_item_type           => p_item_type
          ,p_item_key            => p_item_key
          ,p_api_name            => g_api_name
          ,p_transaction_step_id => l_transaction_step_id
          ,p_transaction_id      => l_transaction_id);
  else
    l_transaction_step_id := to_number(p_transaction_step_id);
  end if;

  if l_transaction_step_id is null then
  hr_utility.set_location('l_transaction_step_id is null thenExiting:'||l_proc, 15);
    return;
  end if;
--
  p_assignment_id:= to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id =>  l_transaction_step_id
    ,p_name                => 'P_ASSIGNMENT_ID'));
--
  p_business_group_id:= to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id =>  l_transaction_step_id
    ,p_name                => 'P_BUSINESS_GROUP_ID'));
--
  p_effective_date:= to_char(
    hr_transaction_api.get_date_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_EFFECTIVE_DATE')
   ,g_date_format);
--
  p_object_version_number := to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id =>  l_transaction_step_id
    ,p_name                => 'P_OBJECT_VERSION_NUMBER'));
--
  p_organization_id := to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ORGANIZATION_ID'));
--
  open csr_org_name(to_number(p_organization_id));
  fetch csr_org_name into p_org_name;
  close csr_org_name;
--
  p_position_id := to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_POSITION_ID'));
--
  open csr_pos_name(to_number(p_position_id));
  fetch csr_pos_name into p_pos_name;
  close csr_pos_name;
--
  p_job_id := to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_JOB_ID'));
--
  open csr_job_name(to_number(p_job_id));
  fetch csr_job_name into p_job_name;
  close csr_job_name;
--
  p_grade_id := to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_GRADE_ID'));
--
  open csr_grade_name(to_number(p_grade_id));
  fetch csr_grade_name into p_grade_name;
  close csr_grade_name;
--
  p_location_id := to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_LOCATION_ID'));
--
  p_employment_category :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_EMPLOYMENT_CATEGORY');
--
  p_supervisor_id := to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_SUPERVISOR_ID'));
--
  p_manager_flag :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_MANAGER_FLAG');
--

  -- Fix for Bug 2943224 and 3205625 for number format/invalid number error
  p_normal_hours := to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_NORMAL_HOURS')
     ,'9999999999999999999D999', 'NLS_NUMERIC_CHARACTERS = ''.,'''
    );
--
  p_frequency :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_FREQUENCY');
--
  p_time_normal_finish :=
    substr(hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_TIME_NORMAL_FINISH'),0,5);
--
  p_time_normal_start :=
    substr(hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_TIME_NORMAL_START'),0,5);
--
  p_bargaining_unit_code :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_BARGAINING_UNIT_CODE');
--
  p_labour_union_member_flag :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_LABOUR_UNION_MEMBER_FLAG');
--
  p_special_ceiling_step_id := to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_SPECIAL_CEILING_STEP_ID'));
--
  p_assignment_status_type_id := to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASSIGNMENT_STATUS_TYPE_ID'));
--
  p_change_reason :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_CHANGE_REASON');
--
  p_ass_attribute_category :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE_CATEGORY');
--
  p_ass_attribute1 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE1');
--
  p_ass_attribute2 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE2');
--
  p_ass_attribute3 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE3');
--
  p_ass_attribute4 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE4');
--
  p_ass_attribute5 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE5');
--
  p_ass_attribute6 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE6');
--
  p_ass_attribute7 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE7');
--
  p_ass_attribute8 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE8');
--
  p_ass_attribute9 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE9');
--
  p_ass_attribute10 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE10');
--
  p_ass_attribute11 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE11');
--
  p_ass_attribute12 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE12');
--
  p_ass_attribute13 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE13');
--
  p_ass_attribute14 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE14');
--
  p_ass_attribute15 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE15');
--
  p_ass_attribute16 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE16');
--
  p_ass_attribute17 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE17');
--
  p_ass_attribute18 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE18');
--
  p_ass_attribute19 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE19');
--
  p_ass_attribute20 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE20');
--
  p_ass_attribute21 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE21');
--
  p_ass_attribute22 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE22');
--
  p_ass_attribute23 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE23');
--
  p_ass_attribute24 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE24');
--
  p_ass_attribute25 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE25');
--
  p_ass_attribute26 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE26');
--
  p_ass_attribute27 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE27');
--
  p_ass_attribute28 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE28');
--
  p_ass_attribute29 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE29');
--
  p_ass_attribute30 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE30');

  p_people_group_id:=to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_PEOPLE_GROUP_ID'));
--
  p_soft_coding_keyflex_id:= to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_SOFT_CODING_KEYFLEX_ID'));
--
  p_sal_review_period:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_SAL_REVIEW_PERIOD');
--
  p_sal_review_period_frequency:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_SAL_REVIEW_PERIOD_FREQUENCY');
--
  p_date_probation_end:= to_char(
    hr_transaction_api.get_date_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_DATE_PROBATION_END'), g_date_format);
--
  p_probation_period:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_PROBATION_PERIOD');
--
  p_probation_unit:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_PROBATION_UNIT');
--
  p_notice_period:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_NOTICE_PERIOD');
--
  p_notice_period_uom:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_NOTICE_PERIOD_UOM');
--
  p_employee_category:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_EMPLOYEE_CATEGORY');
--
  p_work_at_home:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_WORK_AT_HOME');
--
  p_job_post_source_name:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_JOB_POST_SOURCE_NAME');
--
  p_perf_review_period:= to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_PERF_REVIEW_PERIOD'));
--
  p_perf_review_period_frequency:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_PERF_REVIEW_PERIOD_FREQUENCY');
--
  p_internal_address_line:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_INTERNAL_ADDRESS_LINE');
--
  p_payroll_id:=
    to_char(hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_PAYROLL_ID'));
--
  p_pay_basis_id:=
    to_char(hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_PAY_BASIS_ID'));
--
  p_contract_id:=
    to_char(hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_CONTRACT_ID'));
--
  p_establishment_id:=
    to_char(hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ESTABLISHMENT_ID'));
--
  p_cagr_grade_def_id:=
    to_char(hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_CAGR_GRADE_DEF_ID'));
--
  p_collective_agreement_id:=
    to_char(hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_COLLECTIVE_AGREEMENT_ID'));
--
  p_cagr_id_flex_num:=
    to_char(hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_CAGR_ID_FLEX_NUM'));
--
  p_display_org:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_DISPLAY_ORG');
--
  p_display_job:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_DISPLAY_JOB');
--
  p_display_pos:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_DISPLAY_POS');
--
  p_display_grade:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_DISPLAY_GRADE');
--
  p_display_ass_status:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_DISPLAY_ASS_STATUS');
--
  p_title:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_TITLE');
--
  p_project_title:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_PROJECT_TITLE');
--
  p_source_type:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_SOURCE_TYPE');
--
  p_vendor_assignment_number:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_VENDOR_ASSIGNMENT_NUMBER');
--
  p_vendor_employee_number:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_VENDOR_EMPLOYEE_NUMBER');
--
  p_default_code_comb_id := to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_DEFAULT_CODE_COMB_ID'));
--
  p_set_of_books_id := to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_SET_OF_BOOKS_ID'));
--
  p_vendor_id := to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_VENDOR_ID'));
--
  open csr_vendor_name(to_number(p_vendor_id));
  fetch csr_vendor_name into p_vendor_name;
  close csr_vendor_name;
--
  p_po_header_id := to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_PO_HEADER_ID'));
--
  open csr_po_number(to_number(p_po_header_id));
  fetch csr_po_number into p_po_number;
  close csr_po_number;

  p_po_line_id := to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_PO_LINE_ID'));
--
  open csr_po_line_number(to_number(p_po_line_id));
  fetch csr_po_line_number into p_po_line_number;
  close csr_po_line_number;

  p_vendor_site_id := to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_VENDOR_SITE_ID'));
--
  open csr_vendor_site_name(to_number(p_vendor_site_id));
  fetch csr_vendor_site_name into p_vendor_site_name;
  close csr_vendor_site_name;

  p_projected_asgn_end :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_PROJ_ASGN_END');

--

  p_assignment_type:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_ASSIGNMENT_TYPE');
--
  -- GSP changes
  p_grade_ladder_pgm_id := to_char(
    hr_transaction_api.get_number_value
    (p_transaction_step_id => l_transaction_step_id
    ,p_name                => 'P_GRADE_LADDER_PGM_ID'));
  -- End of GSP changes

  --p_supervisor_assignment_id := to_char(
  --  hr_transaction_api.get_number_value
  --  (p_transaction_step_id => l_transaction_step_id
  --  ,p_name                => 'P_SUPERVISOR_ASSIGNMENT_ID'));
--

hr_utility.set_location('Exiting:'||l_proc, 20);
end get_assignment_from_tt;

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
,p_labour_union_member_flag  out nocopy varchar2
,p_assignment_status_type_id  out nocopy number
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
,p_projected_asgn_end        out nocopy date

) is
l_proc   varchar2(72)  := g_package||'get_assignment_from_tt';

begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_assignment_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_ASSIGNMENT_ID');
--
  p_business_group_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_BUSINESS_GROUP_ID');
--
  p_effective_date:=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EFFECTIVE_DATE');
--
  p_object_version_number :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_OBJECT_VERSION_NUMBER');
--
  p_position_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_POSITION_ID');
--
  p_job_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_JOB_ID');
--
  p_grade_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_GRADE_ID');
--
  p_location_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_LOCATION_ID');
--
  p_employment_category :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EMPLOYMENT_CATEGORY');
--
  p_supervisor_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SUPERVISOR_ID');
--
  p_manager_flag :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_MANAGER_FLAG');
--
  p_normal_hours :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NORMAL_HOURS');
--
  p_frequency :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_FREQUENCY');
--
  p_time_normal_finish :=
    substr(hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TIME_NORMAL_FINISH'),0,5);
--
  p_time_normal_start :=
    substr(hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TIME_NORMAL_START'),0,5);
--
  p_bargaining_unit_code :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_BARGAINING_UNIT_CODE');
--
  p_labour_union_member_flag :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_LABOUR_UNION_MEMBER_FLAG');
--
  p_special_ceiling_step_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SPECIAL_CEILING_STEP_ID');
--
  p_assignment_status_type_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASSIGNMENT_STATUS_TYPE_ID');
--
  p_change_reason :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CHANGE_REASON');
--
  p_ass_attribute_category :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE_CATEGORY');
--
  p_ass_attribute1 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE1');
--
  p_ass_attribute2 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE2');
--
  p_ass_attribute3 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE3');
--
  p_ass_attribute4 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE4');
--
  p_ass_attribute5 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE5');
--
  p_ass_attribute6 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE6');
--
  p_ass_attribute7 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE7');
--
  p_ass_attribute8 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE8');
--
  p_ass_attribute9 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE9');
--
  p_ass_attribute10 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE10');
--
  p_ass_attribute11 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE11');
--
  p_ass_attribute12 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE12');
--
  p_ass_attribute13 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE13');
--
  p_ass_attribute14 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE14');
--
  p_ass_attribute15 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE15');
--
  p_ass_attribute16 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE16');
--
  p_ass_attribute17 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE17');
--
  p_ass_attribute18 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE18');
--
  p_ass_attribute19 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE19');
--
  p_ass_attribute20 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE20');
--
  p_ass_attribute21 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE21');
--
  p_ass_attribute22 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE22');
--
  p_ass_attribute23 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE23');
--
  p_ass_attribute24 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE24');
--
  p_ass_attribute25 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE25');
--
  p_ass_attribute26 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE26');
--
  p_ass_attribute27 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE27');
--
  p_ass_attribute28 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE28');
--
  p_ass_attribute29 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE29');
--
  p_ass_attribute30 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE30');

  p_people_group_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PEOPLE_GROUP_ID');
--
  p_soft_coding_keyflex_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SOFT_CODING_KEYFLEX_ID');
--
  p_sal_review_period:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SAL_REVIEW_PERIOD');
--
  p_sal_review_period_frequency:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SAL_REVIEW_PERIOD_FREQUENCY');
--
  p_date_probation_end :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DATE_PROBATION_END');
--
  p_probation_period :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PROBATION_PERIOD');
--
  p_probation_unit :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PROBATION_UNIT');
--
  p_notice_period :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NOTICE_PERIOD');
--
  p_notice_period_uom :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NOTICE_PERIOD_UOM');
--
  p_employee_category :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EMPLOYEE_CATEGORY');
--
  p_work_at_home :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_WORK_AT_HOME');
--
  p_job_post_source_name :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_JOB_POST_SOURCE_NAME');
--
  p_perf_review_period :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PERF_REVIEW_PERIOD');
--
  p_perf_review_period_frequency :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PERF_REVIEW_PERIOD_FREQUENCY');
--
  p_internal_address_line :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INTERNAL_ADDRESS_LINE');
--
  p_payroll_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PAYROLL_ID');
--
  p_pay_basis_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PAY_BASIS_ID');
--
  p_contract_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CONTRACT_ID');
--
  p_establishment_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ESTABLISHMENT_ID');
--
  p_cagr_grade_def_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CAGR_GRADE_DEF_ID');
--
  p_collective_agreement_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_COLLECTIVE_AGREEMENT_ID');
--
  p_cagr_id_flex_num:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CAGR_ID_FLEX_NUM');
--
  p_display_org:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DISPLAY_ORG');
--
  p_display_job:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DISPLAY_JOB');
--
  p_display_pos:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DISPLAY_POS');
--
  p_display_grade:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DISPLAY_GRADE');
--
  p_display_ass_status:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DISPLAY_ASS_STATUS');
--
--
  p_title:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TITLE');
--
  p_project_title:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PROJECT_TITLE');
--
  p_source_type:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SOURCE_TYPE');
--
  p_vendor_assignment_number:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_VENDOR_ASSIGNMENT_NUMBER');
--
  p_vendor_employee_number:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_VENDOR_EMPLOYEE_NUMBER');
--
  p_default_code_comb_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DEFAULT_CODE_COMB_ID');
--
  p_set_of_books_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SET_OF_BOOKS_ID');
--
  p_vendor_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_VENDOR_ID');
--
  p_po_header_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PO_HEADER_ID');
--
  p_po_line_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PO_LINE_ID');
--
  p_vendor_site_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_VENDOR_SITE_ID');
--

  p_assignment_type:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASSIGNMENT_TYPE');
--
  -- GSP changes
  p_grade_ladder_pgm_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_GRADE_LADDER_PGM_ID');

 -- End of GSP changes

--
  -- p_supervisor_assignment_id :=
  --  hr_transaction_api.get_number_value
  --  (p_transaction_step_id => p_transaction_step_id
  --  ,p_name                => 'P_SUPERVISOR_ASSIGNMENT_ID');
--

  p_projected_asgn_end :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PROJ_ASGN_END');

hr_utility.set_location('Exiting:'||l_proc, 15);
end get_assignment_from_tt;

procedure process_save
(p_save_mode                in     varchar2  default null
,p_item_type                in     varchar2
,p_item_key                 in     varchar2
,p_actid                    in     varchar2
,p_login_person_id          in     varchar2 default null
,p_assignment_id            in     varchar2
,p_object_version_number    in     varchar2
,p_effective_date           in     varchar2
,p_grade_id                 in     varchar2   default to_char(hr_api.g_number)
,p_position_id              in     varchar2   default to_char(hr_api.g_number)
,p_job_id                   in     varchar2   default to_char(hr_api.g_number)
,p_location_id              in     varchar2   default to_char(hr_api.g_number)
,p_special_ceiling_step_id  in     varchar2   default to_char(hr_api.g_number)
,p_organization_id          in     varchar2   default to_char(hr_api.g_number)
,p_employment_category      in     varchar2 default hr_api.g_varchar2
,p_supervisor_id            in     varchar2   default to_char(hr_api.g_number)
,p_manager_flag             in     varchar2 default hr_api.g_varchar2
,p_normal_hours             in     varchar2   default to_char(hr_api.g_number)
,p_frequency                in     varchar2 default hr_api.g_varchar2
,p_time_normal_finish       in     varchar2 default hr_api.g_varchar2
,p_time_normal_start        in     varchar2 default hr_api.g_varchar2
,p_bargaining_unit_code         in     varchar2 default hr_api.g_varchar2
,p_labour_union_member_flag     in     varchar2 default hr_api.g_varchar2
,p_assignment_status_type_id in    varchar2   default to_char(hr_api.g_number)
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
,p_contract_id                  in     varchar2 default to_char(hr_api.g_number)
,p_establishment_id         in     varchar2 default to_char(hr_api.g_number)
,p_cagr_grade_def_id        in     varchar2 default to_char(hr_api.g_number)
,p_collective_agreement_id      in     varchar2 default to_char(hr_api.g_number)
,p_cagr_id_flex_num             in     varchar2 default to_char(hr_api.g_number)
,p_payroll_id           in     varchar2   default to_char(hr_api.g_number)
,p_pay_basis_id         in     varchar2   default to_char(hr_api.g_number)
,p_sal_review_period    in     varchar2   default to_char(hr_api.g_number)
,p_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
,p_date_probation_end       in varchar2 default to_char(hr_api.g_date,g_date_format)
,p_probation_period         in varchar2 default to_char(hr_api.g_number)
,p_probation_unit           in varchar2 default hr_api.g_varchar2
,p_notice_period             in varchar2 default to_char(hr_api.g_number)
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
) is
l_proc   varchar2(72)  := g_package||'process_save';
begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  process_save
    (p_save_mode => p_save_mode
    ,p_item_type => p_item_type
    ,p_item_key => p_item_key
    ,p_actid => to_number(p_actid)
    ,p_login_person_id => to_number(p_login_person_id)
    ,p_assignment_id => to_number(p_assignment_id)
    ,p_object_version_number => to_number(p_object_version_number)
    ,p_effective_date => p_effective_date
    ,p_grade_id => to_number(p_grade_id)
    ,p_position_id => to_number(p_position_id)
    ,p_job_id  => to_number(p_job_id)
    ,p_location_id => to_number(p_location_id)
    ,p_special_ceiling_step_id => to_number(p_special_ceiling_step_id)
    ,p_organization_id => to_number(p_organization_id)
    ,p_employment_category => p_employment_category
    ,p_supervisor_id => to_number(p_supervisor_id)
    ,p_manager_flag => p_manager_flag
    -- Fix for Bug 2943224 for number format which
    -- is always in fixed decimal format
    ,p_normal_hours => to_number(p_normal_hours,'9999999999999999999D999',
                                   'NLS_NUMERIC_CHARACTERS = ''.,''')
    ,p_frequency => p_frequency
    ,p_time_normal_finish => p_time_normal_finish
    ,p_time_normal_start => p_time_normal_start
    ,p_bargaining_unit_code => p_bargaining_unit_code
    ,p_labour_union_member_flag => p_labour_union_member_flag
    ,p_assignment_status_type_id => to_number(p_assignment_status_type_id)
    ,p_change_reason => p_change_reason
    ,p_ass_attribute_category => p_ass_attribute_category
    ,p_ass_attribute1 => p_ass_attribute1
    ,p_ass_attribute2 => p_ass_attribute2
    ,p_ass_attribute3 => p_ass_attribute3
    ,p_ass_attribute4 => p_ass_attribute4
    ,p_ass_attribute5 => p_ass_attribute5
    ,p_ass_attribute6 => p_ass_attribute6
    ,p_ass_attribute7 => p_ass_attribute7
    ,p_ass_attribute8 => p_ass_attribute8
    ,p_ass_attribute9 => p_ass_attribute9
    ,p_ass_attribute10 => p_ass_attribute10
    ,p_ass_attribute11 => p_ass_attribute11
    ,p_ass_attribute12 => p_ass_attribute12
    ,p_ass_attribute13 => p_ass_attribute13
    ,p_ass_attribute14 => p_ass_attribute14
    ,p_ass_attribute15 => p_ass_attribute15
    ,p_ass_attribute16 => p_ass_attribute16
    ,p_ass_attribute17 => p_ass_attribute17
    ,p_ass_attribute18 => p_ass_attribute18
    ,p_ass_attribute19 => p_ass_attribute19
    ,p_ass_attribute20 => p_ass_attribute20
    ,p_ass_attribute21 => p_ass_attribute21
    ,p_ass_attribute22 => p_ass_attribute22
    ,p_ass_attribute23 => p_ass_attribute23
    ,p_ass_attribute24 => p_ass_attribute24
    ,p_ass_attribute25 => p_ass_attribute25
    ,p_ass_attribute26 => p_ass_attribute26
    ,p_ass_attribute27 => p_ass_attribute27
    ,p_ass_attribute28 => p_ass_attribute28
    ,p_ass_attribute29 => p_ass_attribute29
    ,p_ass_attribute30 => p_ass_attribute30
    ,p_soft_coding_keyflex_id => to_number(p_soft_coding_keyflex_id)
    ,p_people_group_id => to_number(p_people_group_id)
    ,p_hrs_last_date => p_hrs_last_date
    ,p_display_pos => p_display_pos
    ,p_display_org => p_display_org
    ,p_display_job => p_display_job
    ,p_display_ass_status => p_display_ass_status
    ,p_grade_lov => p_grade_lov
    ,p_approver_id => to_number(p_approver_id)
    ,p_review_proc_call => p_review_proc_call
    ,p_element_changed => p_element_changed
    ,p_display_grade => p_display_grade
    ,p_contract_id => to_number(p_contract_id)
    ,p_establishment_id => to_number(p_establishment_id)
    ,p_cagr_grade_def_id => to_number(p_cagr_grade_def_id)
    ,p_collective_agreement_id => to_number(p_collective_agreement_id)
    ,p_cagr_id_flex_num => to_number(p_cagr_id_flex_num)
    ,p_payroll_id => to_number(p_payroll_id)
    ,p_pay_basis_id => to_number(p_pay_basis_id)
    ,p_sal_review_period => to_number(p_sal_review_period)
    ,p_sal_review_period_frequency => p_sal_review_period_frequency
    ,p_date_probation_end => to_date(p_date_probation_end,g_date_format)
    ,p_probation_period => to_number(p_probation_period)
    ,p_probation_unit => p_probation_unit
    ,p_notice_period => to_number(p_notice_period)
    ,p_notice_period_uom => p_notice_period_uom
    ,p_employee_category => p_employee_category
    ,p_work_at_home => p_work_at_home
    ,p_job_post_source_name => p_job_post_source_name
    ,p_perf_review_period => to_number(p_perf_review_period)
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_internal_address_line => p_internal_address_line
    ,p_page_error => p_page_error
    ,p_page_error_msg => p_page_error_msg
    ,p_page_warning => p_page_warning
    ,p_page_warning_msg => p_page_warning_msg
    ,p_organization_error => p_organization_error
    ,p_organization_error_msg => p_organization_error_msg
    ,p_job_error => p_job_error
    ,p_job_error_msg => p_job_error_msg
    ,p_position_error => p_position_error
    ,p_position_error_msg => p_position_error_msg
    ,p_grade_error => p_grade_error
    ,p_grade_error_msg => p_grade_error_msg
    ,p_supervisor_error => p_supervisor_error
    ,p_supervisor_error_msg => p_supervisor_error_msg
    ,p_location_error => p_location_error
    ,p_location_error_msg => p_location_error_msg
    ,p_transaction_step_id => p_transaction_step_id
    ,p_flow_mode=>p_flow_mode
    ,p_rptg_grp_id           => p_rptg_grp_id
    ,p_plan_id                 => p_plan_id
    ,p_effective_date_option => p_effective_date_option
    ,p_title                  => p_title
    ,p_default_code_comb_id   => to_number(p_default_code_comb_id)
    ,p_set_of_books_id        => to_number(p_set_of_books_id)
    ,p_source_type            => p_source_type
    ,p_project_title          => p_project_title
    ,p_vendor_assignment_number => p_vendor_assignment_number
    ,p_vendor_employee_number   => p_vendor_employee_number
    ,p_vendor_id                => to_number(p_vendor_id)
    ,p_assignment_type          => p_assignment_type
    ,p_grade_ladder_pgm_id      => to_number(p_grade_ladder_pgm_id)
    ,p_supervisor_assignment_id => to_number(p_supervisor_assignment_id)
    -- GSP change
    ,p_salary_change_warning => p_salary_change_warning
    ,p_gsp_post_process_warning => p_gsp_post_process_warning
    ,p_gsp_salary_effective_date => p_gsp_salary_effective_date
    -- GSP change
    ,p_po_header_id => to_number(p_po_header_id)
    ,p_po_line_id => to_number(p_po_line_id)
    ,p_vendor_site_id => to_number(p_vendor_site_id)
    ,p_proj_asgn_end => p_projected_asgn_end

    );
    hr_utility.set_location('Exiting:'||l_proc, 15);

end process_save;

-- This code is for applying several workflow steps of assignment data in
-- one step in the database. The first time that this is called in a process, a
-- new transaction step is created and all of the data are written to the
-- transaction tables. When a subsequent step in the process starts, it reads
-- the previous data from the previous transaction step, and overwrites only
-- the fields which it supplies so that all of the data from all of the steps
-- is  validated together, and then it is saved together
--
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
-- GSP change
,p_salary_change_warning    in out nocopy varchar2
,p_gsp_post_process_warning out nocopy varchar2
,p_gsp_salary_effective_date out nocopy date
-- End of GSP change
,p_po_header_id in  number default hr_api.g_number
,p_po_line_id in  number default hr_api.g_number
,p_vendor_site_id in  number default hr_api.g_number
,p_proj_asgn_end in date  default g_canonical_date

) is
l_assignment_id        per_all_assignments_f.assignment_id%TYPE;
l_person_id            per_all_assignments_f.person_id%TYPE;
l_item_type            hr_api_transaction_steps.item_type%TYPE;
l_item_key             hr_api_transaction_steps.item_key%TYPE;
l_activity_id          hr_api_transaction_steps.activity_id%TYPE;
l_effective_date       date;
l_effective_start_date date;
l_effective_end_date   date;
l_transaction_id       number;
l_result               varchar2(100);
l_transaction_step_id  number;
l_count                number;
l_trans_tbl            hr_transaction_ss.transaction_table;
l_assignment_rec       per_all_assignments_f%rowtype;
l_old_assignment_rec   per_all_assignments_f%rowtype;
l_db_assignment_rec    per_all_assignments_f%rowtype;
l_date_error           boolean default false;
l_special_ceiling_step_id per_all_assignments_f.special_ceiling_step_id%TYPE;
l_trns_object_version_number number;
l_datetrack_update_mode varchar2(30);
l_last_change_date     date;
l_review_proc_call     varchar2(4000);
l_activity_id_list     varchar2(4000);
l_element_warning      boolean default TRUE;
l_hrs_last_date        varchar2(30);
l_display_pos          varchar2(30);
l_display_org          varchar2(30);
l_display_job          varchar2(30);
l_display_ass_status   varchar2(30);
l_grade_lov            varchar2(30);    -- Bug #1004255 fix
l_approver_id          number;
l_email_id             varchar2(200);
l_element_changed      varchar2(1);
i_changed              boolean := FALSE; --changed by current module
others_changed         boolean := FALSE; --changed by other modules
j_changed	varchar2(2)	:= 'N';
l_term_sec_asg	  varchar(2);
ln_ovn                 number;
l_display_grade        varchar2(30);  -- Bug #1067636 fix
l_name                 varchar2(2000);
l_original_name        varchar2(2000); --ns
l_proc_order 	number;    --bug 6065339

l_pay_step_id  	    number;	--bug 6405208
l_pay_activity_id    number;

-- variables and cursor for applicant_hire
l_object_version_number number;
l_per_object_version_number number;
l_employee_number number;
l_per_effective_start_date date;
l_per_effective_end_date date;
l_unaccepted_asg_del_warning boolean;
l_assign_payroll_warning boolean;
l_new_hire_appl_hire varchar2(10);

-- 04/12/02 Salary Basis Enhancement Change Begins
l_legislation_code    VARCHAR2(150) default null;
-- 04/12/02 Salary Basis Enhancement Change Ends
dummy varchar2(5);

-- GSP changes
  ltt_salary_data  sshr_sal_prop_tab_typ;
  lv_salary_change_warning  VARCHAR2(30) default null;
  lv_gsp_api_mode VARCHAR2(30) default null;
  lv_gsp_review_proc_call VARCHAR2(30) default null;
     -- need to changed
  lv_gsp_flow_mode  VARCHAR2(30) default null;
  ln_gsp_step_id NUMBER;
  --lb_grade_ladder_changed boolean default false;
  --lb_grade_changed boolean default false;
  --lb_special_ceiling_step_id_chg boolean default false;
  lc_temp_grade_ladder_id NUMBER;

  ln_gsp_activity_id NUMBER;
  lv_gsp_activity_id VARCHAR2(30) default null;

  lb_grd_ldr_exists_flag boolean default false;
  l_proc   varchar2(72)  := g_package||'process_save';

    lc_temp_upd_sal_cd    varchar2(30);
    ln_gsp_txn_id number;
    ln_gsp_update_mode    varchar2(10);

    -- cursor to find whether assigned grade ladder id updates
    -- the salary using Grade Step Progression
    CURSOR lc_sal_updateable_grade_ladder
    (p_grade_ladder_id in per_all_assignments_f.grade_ladder_pgm_id%TYPE ,
     p_effective_date in date
    ) IS
     select pgm_id, update_salary_cd  from ben_pgm_f
        where
         -- grade ladder does not allow update of  salary
         --(update_salary_cd is null or update_salary_cd = 'NO_UPDATE')
         -- salary updated by the  progression system should not be manually overidden
         --and  (gsp_allow_override_flag is null or gsp_allow_override_flag = 'N')
         --and
         pgm_id = p_grade_ladder_id
         and p_effective_date between effective_start_date and effective_end_date;


--End of GSP changes

-- cursor to get the applicant object_version_number from
-- per_all_people_f
cursor per_applicant_rec(p_appl_person_id in number,
                         p_appl_effective_date in date) is
select object_version_number
from per_all_people_f
where person_id = p_appl_person_id
and p_appl_effective_date between effective_start_date
and effective_end_date;

--
-- cursor to get the applicant object_version_number from
-- per_all_assignments_f
cursor asg_applicant_rec(p_appl_assign_id in number,
                         p_appl_effective_date in date) is
select object_version_number,
       assignment_status_type_id
from per_all_assignments_f
where assignment_id = p_appl_assign_id
and p_appl_effective_date between effective_start_date
and effective_end_date;

--

cursor last_change_date is
select max(asf.effective_start_date)
from per_all_assignments_f asf,
     per_assignment_status_types past
where asf.assignment_id=l_assignment_id
and asf.ASSIGNMENT_STATUS_TYPE_ID = past.ASSIGNMENT_STATUS_TYPE_ID;
-- ns 10-May-03: Since termination is handled on the effective date page
-- and update insert may be allowed even if future dated termination,
-- we do not need this check here
-- and past.PER_SYSTEM_STATUS <> 'TERM_ASSIGN';

-- New cursor to see if any assignment record exist for the selected date
cursor correction_date is
select null
from   per_all_assignments_f asf,
       per_assignment_status_types past
where  asf.assignment_id             = l_assignment_id
and    asf.assignment_status_type_id = past.assignment_status_type_id
and    asf.effective_start_date      = l_effective_date;

cursor csr_org_name(p_id in number) is
select name
from hr_organization_units
where organization_id = p_id;

cursor csr_job_name(p_id in number) is
select name
from per_jobs_vl
where job_id = p_id;

cursor csr_pos_name(p_id in number) is
select name
from hr_positions_f
where position_id = p_id
and to_date(p_effective_date,g_date_format)
between effective_start_date
and effective_end_date;

cursor csr_grade_name(p_id in number) is
select name
from per_grades_vl
where grade_id = p_id;

cursor csr_assignment is
select assignment_id
from per_all_assignments_f
where assignment_id = p_assignment_id;

cursor process_order(l_item_type in varchar2,l_item_key in varchar2) is
select processing_order from hr_api_transaction_steps where
item_type=l_item_type and item_key=l_item_key and api_name='HR_SUPERVISOR_SS.PROCESS_API';

cursor pay_step(l_item_type in varchar2,l_item_key in varchar2) is	--bug6405208
select transaction_step_id,activity_id from hr_api_transaction_steps where
item_type=l_item_type and item_key=l_item_key and api_name='HR_PAY_RATE_SS.PROCESS_API';

cursor step_grade_step(l_item_type in varchar2,l_item_key in varchar2) is
select null from hr_api_transaction_steps where
item_type=l_item_type and item_key=l_item_key and api_name='HR_PROCESS_ASSIGNMENT_STEP_SS.PROCESS_API';

l_re_hire_flow varchar2(25) default null;

  cursor csr_pgp_segments(p_people_group_id in number) is
  select * from pay_people_groups
  where people_group_id = p_people_group_id;

  cursor csr_scl_segments(p_soft_coding_keyflex_id in number) is
  select * from hr_soft_coding_keyflex
  where soft_coding_keyflex_id = p_soft_coding_keyflex_id;

  l_people_groups csr_pgp_segments%rowtype;
  l_soft_coding_keyflex csr_scl_segments%rowtype;
  all_pgp_null  varchar2(2)  := 'N';
  all_scl_null  varchar2(2)  := 'N';

cursor csr_per_step_id is
select transaction_step_id from hr_api_transaction_steps
  where item_type=l_item_type and item_key=l_item_key
  and api_name='HR_PROCESS_PERSON_SS.PROCESS_API';
l_per_step_id	number;
l_asgn_change_mode	varchar2(2);
l_person_type_id	number;

cursor csr_get_prim_asg is
select *
from per_all_assignments_f
where person_id = l_person_id and primary_flag = 'Y' and assignment_type = 'E'
and l_effective_date between effective_start_date and effective_end_date;
--
begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  l_object_version_number := p_object_version_number;

-- first check if this is being called for registration.
  if p_flow_mode is not null and
     p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
  then
    hr_utility.set_location('p_flow_mode = hr_process_assignment_ss.g_new_hire_registration:'||l_proc,10);
    g_registration := true;
  end if;

-- validate seesion
  l_assignment_id := p_assignment_id;
  l_item_type := p_item_type;
  l_item_key := p_item_key;
  l_activity_id := p_actid;
--Code For Re-Hire
  if l_item_type is not null and l_item_key is not null then
  	l_person_id := wf_engine.GetItemAttrText(l_item_type,l_item_key,'CURRENT_PERSON_ID');
  	l_re_hire_flow := wf_engine.GetItemAttrText(l_item_type,l_item_key,'HR_FLOW_IDENTIFIER',true);
  end if;
  if nvl(l_re_hire_flow,'N') = 'EX_EMP' then
  g_exemp_hire := true;
  hr_new_user_reg_ss.processExEmpTransaction
	(WfItemType => l_item_type
        ,WfItemKey => l_item_key
        ,PersonId => l_person_id
        ,AssignmentId => l_assignment_id
        ,p_error_message => p_page_error_msg);
  begin
	select object_version_number into l_object_version_number from per_all_assignments_f where assignment_id = l_assignment_id;
  exception
  when others then
  null;
  end;
  end if;
--End of ReHire Code
--Validate the p_assignment_id
  if g_registration then
    hr_utility.set_location('  if g_registration then:'||l_proc,15);
    open csr_assignment;
    fetch csr_assignment into l_assignment_id;
    if csr_assignment%notfound then
      hr_utility.set_location('    if csr_assignment%notfound then:'||l_proc,20);
      hr_api.legislation_hooks('DISABLE');		-- bug 6405208
      hr_new_user_reg_ss.processNewUserTransaction
        (WfItemType => l_item_type
        ,WfItemKey => l_item_key
        ,PersonId => l_person_id
        ,AssignmentId => l_assignment_id);
      hr_api.legislation_hooks('ENABLE');		-- bug 6405208
    end if;
    close csr_assignment;
  end if;
--
-- get the e-mail address for error messages
--
--  l_email_id := wf_engine.getItemAttrText
--                (itemtype => l_item_type
--                ,itemkey  => l_item_key
--                ,aname    => hr_assignment_util_web.gv_wf_email_id);
--
-- check that we have a valid date
--

  begin
    l_effective_date :=to_date(p_effective_date, g_date_format);
  exception
    when others then
    --Should add page level error
    hr_utility.set_location('Exception:Others'||l_proc,555);
    hr_utility.raise_error;
    /*hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => to_char(SQLCODE)
      ,p_errormsg   => sqlerrm
      );*/
    l_date_error:=true;
  end;

-- GSP Changes
 -- set the effective salary date
 p_gsp_salary_effective_date := l_effective_date;
-- End of GSP changes

--
  if not l_date_error then
--
-- look to see if we are looking for an element warning or error
--
   IF hr_mee_workflow_service.check_web_page_code(
      p_item_type => l_item_type,
      p_item_key  => l_item_key,
      p_actid     => l_activity_id,
      p_web_page_section_code =>
                hr_process_assignment_ss.gv_ele_warning) THEN
      if(hr_mee_workflow_service.get_web_page_code(
        p_item_type => l_item_type,
        p_item_key  => l_item_key,
        p_actID     => l_activity_id,
        p_web_page_section_code =>hr_process_assignment_ss.gv_ele_warning)
                 = 'Y') then
        l_element_warning:=TRUE;
      else
        l_element_warning:=FALSE;
      end if;
    ELSE
      l_element_warning:=FALSE;
    END IF;
    l_element_changed:=p_element_changed;

   open csr_per_step_id;
   fetch csr_per_step_id into l_per_step_id;
   close csr_per_step_id;

   l_asgn_change_mode :=     hr_transaction_api.get_varchar2_value
                             (p_transaction_step_id =>  l_per_step_id
                             ,p_name                => 'P_ASGN_CHANGE_MODE');

-- ----------------------------------------------------------------------------
-- get original database data, we need to compare it with transaction table
-- and input values to decide if any changes have been made
-- ----------------------------------------------------------------------------

   if (l_asgn_change_mode = 'V' OR l_asgn_change_mode = 'W') then
      open csr_get_prim_asg;
      fetch csr_get_prim_asg into l_db_assignment_rec;
      close csr_get_prim_asg;
  else
    hr_assignment_common_save_web.get_asg_from_asg
                  (p_assignment_id     => l_assignment_id
                  ,p_effective_date    => l_effective_date
                  ,p_assignment_rec    => l_db_assignment_rec);
  end if;
--
-- look to see if we have already a transaction step in progress
-- this check is based on the api_name and not the activity_id because
-- each step will have a different activity_id.
--
    hr_assignment_common_save_web.get_step
          (p_item_type           => l_item_type
          ,p_item_key            => l_item_key
          ,p_api_name            => g_api_name
          ,p_transaction_step_id => l_transaction_step_id
          ,p_transaction_id      => l_transaction_id);
    --IF l_transaction_step_id is null then
--
-- There are no pre-existing steps, so this is the first time this has been
-- called
--

   -------------------------------------------------------------------------
   -- get the existing data from the online tables
   -------------------------------------------------------------------------
      l_old_assignment_rec := l_db_assignment_rec;

--
-- look for the last change date so that we can work out what date track
-- update mode we are using
--

      open last_change_date;
      fetch last_change_date into l_last_change_date;
      if last_change_date%notfound then
        close last_change_date;
      --
      -- if we cannot find this assignment record then there must be an error
      --
      --Should add page level error
        fnd_message.set_name('PER','HR_ASG_NOT_FOUND');
        hr_utility.raise_error;
        /*hr_errors_api.addErrorToTable
        (p_errorfield => null
        ,p_errormsg   => fnd_message.get);*/
      else
        close last_change_date;
      end if;
--
      if l_effective_date>l_last_change_date then
        --
        -- if the effective date is after the date of the last change then we
        -- are doing an update
        --
        hr_utility.set_location('l_effective_date>l_last_change_date then:'||l_proc,30);
        l_datetrack_update_mode:='UPDATE';

        --  registration always need this as Correction.
        if (p_flow_mode is not null and
           p_flow_mode = hr_process_assignment_ss.g_new_hire_registration) OR (nvl(l_re_hire_flow,'N') = 'EX_EMP')
        then
           hr_utility.set_location('p_flow_mode is not null and: NewHireReg'||l_proc,35);
           l_datetrack_update_mode :=  'CORRECTION';
        end if;

      else
           open  correction_date;
           fetch correction_date into dummy;

           if correction_date%FOUND then
              -- if the effective date is equal an existing assignment
              -- start date then we
              -- are doing a correction
              --
              hr_utility.set_location('if correction_date%FOUND then:'||l_proc,40);
              l_datetrack_update_mode:='CORRECTION';
           else
              --
              IF ( fnd_profile.value('PQH_DT_RULE_FUTUR_CHANGE_FOUND')
                 = 'APPROVE_ONLY') THEN
                  hr_utility.set_location('Approve only:'||l_proc,45);
                  l_datetrack_update_mode:='UPDATE_CHANGE_INSERT';
              ELSE
                  --Throw error if date track profile is turned off and
                  --future dated change is found
                  fnd_message.set_name('PER','HR_DATE_TOO_EARLY');
                  hr_utility.raise_error;
              END  IF;
              --
           end if;

           close correction_date;

      end if;

   IF l_transaction_step_id is null then
      hr_utility.set_location('IF l_transaction_step_id is null then:'||l_proc,50);
      --
      --since this is the first time in, we take the display pos and activity_id
      -- as they are.
      --

      l_review_proc_call := p_review_proc_call;
      l_activity_id_list := l_activity_id;
    else
      -- this is not the first time through.
      -- get the existing data from the transaction tables
      -- Bug 2365524: set the l_element_changed only if the transaction
      -- value is not null
      if hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => l_transaction_step_id
           ,p_name                => 'P_ELEMENT_CHANGED') is not null
      then
        l_element_changed :=
          hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => l_transaction_step_id
           ,p_name                => 'P_ELEMENT_CHANGED');
      end if;
      --warning has already been raised.
      if l_element_changed is not null then
        l_element_warning := TRUE;
      end if;
      get_asg_from_tt
        (p_transaction_step_id => l_transaction_step_id
         ,p_assignment_rec    => l_old_assignment_rec);
      -- we pick up the old review page and activity_id lists to
      -- append to
      l_review_proc_call:=    hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => l_transaction_step_id
        ,p_name                => 'P_REVIEW_PROC_CALL');
      l_activity_id_list:= hr_transaction_api.get_varchar2_value
        (p_transaction_step_id => l_transaction_step_id
        ,p_name                => 'P_REVIEW_ACTID');
      -- check that effective_date and date track update mode
      -- have not changed
      if (l_effective_date<> to_date(hr_transaction_ss.get_wf_effective_date
                        (p_transaction_step_id => l_transaction_step_id)
                        ,g_date_format))
      then
        --Should add page level error
        fnd_message.set_name('PER','HR_EFF_DATE_CHANGED');
        hr_utility.raise_error;
        /*hr_errors_api.addErrorToTable
          (p_errorfield => null
          ,p_errormsg   => fnd_message.get);*/
      end if;
      /*l_datetrack_update_mode:=
         hr_transaction_api.get_varchar2_value(
            p_transaction_step_id => l_transaction_step_id,
            p_name                => 'P_DATETRACK_UPDATE_MODE'
            );*/
      if nvl(l_re_hire_flow,'N') = 'EX_EMP' then
	l_datetrack_update_mode:='CORRECTION';
      end if;
    end if;
    i_changed := FALSE;
    others_changed := FALSE;
    -- Set the l_assignment_rec.business_group_id and person_id accordingly.
    -- Otherwise, we will get HR_7207_API_MANDATORY_ARG error in
    -- per_asg_bus1.chk_organization_id and other assignment fields
    -- because of the uninitialized value in the rec.
    l_assignment_rec.business_group_id :=
          l_old_assignment_rec.business_group_id;
    l_assignment_rec.person_id :=
          l_old_assignment_rec.person_id;
if (p_grade_id = hr_api.g_number) then
  l_assignment_rec.grade_id := l_old_assignment_rec.grade_id;
  if nvl(l_old_assignment_rec.grade_id, hr_api.g_number)
     <> nvl(l_db_assignment_rec.grade_id, hr_api.g_number)
  then
       others_changed:=TRUE;
  end if;
else
  l_assignment_rec.grade_id := p_grade_id;
  if (nvl(p_grade_id,-1) <> nvl(l_db_assignment_rec.grade_id,-1) ) then
    i_changed:=TRUE;
  end if;
end if;

if (p_position_id = hr_api.g_number) then
    l_assignment_rec.position_id :=
    l_old_assignment_rec.position_id;
    if nvl(l_old_assignment_rec.position_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.position_id, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.position_id := p_position_id;
    if (nvl(p_position_id, -1) <> nvl(l_db_assignment_rec.position_id,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_job_id = hr_api.g_number) then
    l_assignment_rec.job_id :=
    l_old_assignment_rec.job_id;
    if nvl(l_old_assignment_rec.job_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.job_id, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.job_id := p_job_id;
    if (nvl(p_job_id, -1) <> nvl(l_db_assignment_rec.job_id,-1)) then
       i_changed:=TRUE;
    end if;
end if;

if (p_location_id = hr_api.g_number) then
    l_assignment_rec.location_id :=
    l_old_assignment_rec.location_id;
    if nvl(l_old_assignment_rec.location_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.location_id, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.location_id := p_location_id;
    if (nvl(p_location_id, -1) <> nvl(l_db_assignment_rec.location_id,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_supervisor_id = hr_api.g_number) then
    l_assignment_rec.supervisor_id :=
    l_old_assignment_rec.supervisor_id;
    if nvl(l_old_assignment_rec.supervisor_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.supervisor_id, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.supervisor_id := p_supervisor_id;
    if (nvl(p_supervisor_id, -1) <> nvl(l_db_assignment_rec.supervisor_id,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_special_ceiling_step_id = hr_api.g_number) then
    l_assignment_rec.special_ceiling_step_id :=
    l_old_assignment_rec.special_ceiling_step_id;
    if nvl(l_old_assignment_rec.special_ceiling_step_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.special_ceiling_step_id, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.special_ceiling_step_id := p_special_ceiling_step_id;
    if (nvl(p_special_ceiling_step_id, -1) <>
       nvl(l_db_assignment_rec.special_ceiling_step_id,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_organization_id = hr_api.g_number) then
    l_assignment_rec.organization_id :=
    l_old_assignment_rec.organization_id;
    if nvl(l_old_assignment_rec.organization_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.organization_id, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.organization_id := p_organization_id;
    if (nvl(p_organization_id, -1) <>
       nvl(l_db_assignment_rec.organization_id,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_employment_category = hr_api.g_varchar2) then
    l_assignment_rec.employment_category :=
    l_old_assignment_rec.employment_category;
    if nvl(l_old_assignment_rec.employment_category, hr_api.g_varchar2)
       <> nvl(l_db_assignment_rec.employment_category, hr_api.g_varchar2)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.employment_category := p_employment_category;
    if (nvl(p_employment_category, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.employment_category, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_manager_flag = hr_api.g_varchar2) then
    l_assignment_rec.manager_flag :=
    l_old_assignment_rec.manager_flag;
    if nvl(l_old_assignment_rec.manager_flag, hr_api.g_varchar2)
       <> nvl(l_db_assignment_rec.manager_flag, hr_api.g_varchar2)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.manager_flag := p_manager_flag;
    if (nvl(p_manager_flag, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.manager_flag, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_frequency = hr_api.g_varchar2) then
    l_assignment_rec.frequency :=
    l_old_assignment_rec.frequency;
    if nvl(l_old_assignment_rec.frequency, hr_api.g_varchar2)
       <> nvl(l_db_assignment_rec.frequency, hr_api.g_varchar2)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.frequency := p_frequency;
    if (nvl(p_frequency, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.frequency, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_normal_hours = hr_api.g_number) then
    l_assignment_rec.normal_hours :=
    l_old_assignment_rec.normal_hours;
    if nvl(l_old_assignment_rec.normal_hours, hr_api.g_number)
       <> nvl(l_db_assignment_rec.normal_hours, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.normal_hours := p_normal_hours;
    if (nvl(p_normal_hours, -1) <>
       nvl(l_db_assignment_rec.normal_hours,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_time_normal_finish = hr_api.g_varchar2) then
    l_assignment_rec.time_normal_finish :=
    l_old_assignment_rec.time_normal_finish;
    if nvl(l_old_assignment_rec.time_normal_finish, hr_api.g_varchar2)
       <> nvl(l_db_assignment_rec.time_normal_finish, hr_api.g_varchar2)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.time_normal_finish := p_time_normal_finish;
    if (nvl(p_time_normal_finish, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.time_normal_finish, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_time_normal_start = hr_api.g_varchar2) then
    l_assignment_rec.time_normal_start :=
    l_old_assignment_rec.time_normal_start;
    if nvl(l_old_assignment_rec.time_normal_start, hr_api.g_varchar2)
       <> nvl(l_db_assignment_rec.time_normal_start, hr_api.g_varchar2)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.time_normal_start := p_time_normal_start;
    if (nvl(p_time_normal_start, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.time_normal_start, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_bargaining_unit_code = hr_api.g_varchar2) then
    l_assignment_rec.bargaining_unit_code :=
    l_old_assignment_rec.bargaining_unit_code;
    if nvl(l_old_assignment_rec.bargaining_unit_code, hr_api.g_varchar2)
       <> nvl(l_db_assignment_rec.bargaining_unit_code, hr_api.g_varchar2)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.bargaining_unit_code := p_bargaining_unit_code;
    if (nvl(p_bargaining_unit_code, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.bargaining_unit_code, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_labour_union_member_flag = hr_api.g_varchar2) then
    l_assignment_rec.labour_union_member_flag :=
    l_old_assignment_rec.labour_union_member_flag;
    if nvl(l_old_assignment_rec.labour_union_member_flag, hr_api.g_varchar2)
       <> nvl(l_db_assignment_rec.labour_union_member_flag, hr_api.g_varchar2)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.labour_union_member_flag := p_labour_union_member_flag;
    if (nvl(p_labour_union_member_flag, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.labour_union_member_flag, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;


if (p_ass_attribute_category = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute_category :=
    l_old_assignment_rec.ass_attribute_category;
    if nvl(l_old_assignment_rec.ass_attribute_category, hr_api.g_varchar2)
       <> nvl(l_db_assignment_rec.ass_attribute_category, hr_api.g_varchar2)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute_category := p_ass_attribute_category;
    if (nvl(p_ass_attribute_category, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute_category, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_change_reason = hr_api.g_varchar2) then
    l_assignment_rec.change_reason :=
    l_old_assignment_rec.change_reason;
    if (nvl(l_db_assignment_rec.change_reason, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.change_reason, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.change_reason := p_change_reason;
    if (nvl(p_change_reason, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.change_reason, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute1 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute1 :=
    l_old_assignment_rec.ass_attribute1;
    if (nvl(l_db_assignment_rec.ass_attribute1, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute1, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute1 := p_ass_attribute1;
    if (nvl(p_ass_attribute1, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute1, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute2 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute2 :=
    l_old_assignment_rec.ass_attribute2;
    if (nvl(l_db_assignment_rec.ass_attribute2, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute2, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute2 := p_ass_attribute2;
    if (nvl(p_ass_attribute2, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute2, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute3 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute3 :=
    l_old_assignment_rec.ass_attribute3;
    if (nvl(l_db_assignment_rec.ass_attribute3, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute3, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute3 := p_ass_attribute3;
    if (nvl(p_ass_attribute3, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute3, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute4 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute4 :=
    l_old_assignment_rec.ass_attribute4;
    if (nvl(l_db_assignment_rec.ass_attribute4, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute4, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute4 := p_ass_attribute4;
    if (nvl(p_ass_attribute4, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute4, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute5 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute5 :=
    l_old_assignment_rec.ass_attribute5;
    if (nvl(l_db_assignment_rec.ass_attribute5, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute5, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute5 := p_ass_attribute5;
    if (nvl(p_ass_attribute5, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute5, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute6 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute6 :=
    l_old_assignment_rec.ass_attribute6;
    if (nvl(l_db_assignment_rec.ass_attribute6, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute6, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute6 := p_ass_attribute6;
    if (nvl(p_ass_attribute6, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute6, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute7 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute7 :=
    l_old_assignment_rec.ass_attribute7;
    if (nvl(l_db_assignment_rec.ass_attribute7, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute7, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute7 := p_ass_attribute7;
    if (nvl(p_ass_attribute7, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute7, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute8 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute8 :=
    l_old_assignment_rec.ass_attribute8;
    if (nvl(l_db_assignment_rec.ass_attribute8, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute8, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute8 := p_ass_attribute8;
    if (nvl(p_ass_attribute8, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute8, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute9 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute9 :=
    l_old_assignment_rec.ass_attribute9;
    if (nvl(l_db_assignment_rec.ass_attribute9, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute9, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute9 :=p_ass_attribute9;
    if (nvl(p_ass_attribute9, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute9, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute10 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute10 :=
    l_old_assignment_rec.ass_attribute10;
    if (nvl(l_db_assignment_rec.ass_attribute10, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute10, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute10 := p_ass_attribute10;
    if (nvl(p_ass_attribute10, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute10, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute11 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute11 :=
    l_old_assignment_rec.ass_attribute11;
    if (nvl(l_db_assignment_rec.ass_attribute11, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute11, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute11 := p_ass_attribute11;
    if (nvl(p_ass_attribute11, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute11, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute12 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute12 :=
    l_old_assignment_rec.ass_attribute12;
    if (nvl(l_db_assignment_rec.ass_attribute12, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute12, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute12 := p_ass_attribute12;
    if (nvl(p_ass_attribute12, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute12, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute13 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute13 :=
    l_old_assignment_rec.ass_attribute13;
    if (nvl(l_db_assignment_rec.ass_attribute13, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute13, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute13 := p_ass_attribute13;
    if (nvl(p_ass_attribute13, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute13, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute14 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute14 :=
    l_old_assignment_rec.ass_attribute14;
    if (nvl(l_db_assignment_rec.ass_attribute14, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute14, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute14 := p_ass_attribute14;
    if (nvl(p_ass_attribute14, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute14, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute15 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute15 :=
    l_old_assignment_rec.ass_attribute15;
    if (nvl(l_db_assignment_rec.ass_attribute15, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute15, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute15 := p_ass_attribute15;
    if (nvl(p_ass_attribute15, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute15, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute16 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute16 :=
    l_old_assignment_rec.ass_attribute16;
    if (nvl(l_db_assignment_rec.ass_attribute16, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute16, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute16 := p_ass_attribute16;
    if (nvl(p_ass_attribute16, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute16, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute17 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute17 :=
    l_old_assignment_rec.ass_attribute17;
    if (nvl(l_db_assignment_rec.ass_attribute17, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute17, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute17 := p_ass_attribute17;
    if (nvl(p_ass_attribute17, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute17, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute18 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute18 :=
    l_old_assignment_rec.ass_attribute18;
    if (nvl(l_db_assignment_rec.ass_attribute18, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute18, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute18 := p_ass_attribute18;
    if (nvl(p_ass_attribute18, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute18, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute19 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute19 :=
    l_old_assignment_rec.ass_attribute19;
    if (nvl(l_db_assignment_rec.ass_attribute19, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute19, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute19 := p_ass_attribute19;
    if (nvl(p_ass_attribute19, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute19, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute20 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute20 :=
    l_old_assignment_rec.ass_attribute20;
    if (nvl(l_db_assignment_rec.ass_attribute20, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute20, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute20 := p_ass_attribute20;
    if (nvl(p_ass_attribute20, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute20, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute21 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute21 :=
    l_old_assignment_rec.ass_attribute21;
    if (nvl(l_db_assignment_rec.ass_attribute21, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute21, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute21 := p_ass_attribute21;
    if (nvl(p_ass_attribute21, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute21, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute22 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute22 :=
    l_old_assignment_rec.ass_attribute22;
    if (nvl(l_db_assignment_rec.ass_attribute22, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute22, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute22 := p_ass_attribute22;
    if (nvl(p_ass_attribute22, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute22, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute23 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute23 :=
    l_old_assignment_rec.ass_attribute23;
    if (nvl(l_db_assignment_rec.ass_attribute23, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute23, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute23 := p_ass_attribute23;
    if (nvl(p_ass_attribute23, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute23, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute24 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute24 :=
    l_old_assignment_rec.ass_attribute24;
    if (nvl(l_db_assignment_rec.ass_attribute24, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute24, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute24 := p_ass_attribute24;
    if (nvl(p_ass_attribute24, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute24, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute25 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute25 :=
    l_old_assignment_rec.ass_attribute25;
    if (nvl(l_db_assignment_rec.ass_attribute25, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute25, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute25 := p_ass_attribute25;
    if (nvl(p_ass_attribute25, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute25, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute26 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute26 :=
    l_old_assignment_rec.ass_attribute26;
    if (nvl(l_db_assignment_rec.ass_attribute26, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute26, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute26 := p_ass_attribute26;
    if (nvl(p_ass_attribute26, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute26, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute27 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute27 :=
    l_old_assignment_rec.ass_attribute27;
    if (nvl(l_db_assignment_rec.ass_attribute27, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute27, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute27 := p_ass_attribute27;
    if (nvl(p_ass_attribute27, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute27, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute28 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute28 :=
    l_old_assignment_rec.ass_attribute28;
    if (nvl(l_db_assignment_rec.ass_attribute28, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute28, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute28 := p_ass_attribute28;
    if (nvl(p_ass_attribute28, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute28, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute29 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute29 :=
    l_old_assignment_rec.ass_attribute29;
    if (nvl(l_db_assignment_rec.ass_attribute29, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute29, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute29 := p_ass_attribute29;
    if (nvl(p_ass_attribute29, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute29, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_ass_attribute30 = hr_api.g_varchar2) then
    l_assignment_rec.ass_attribute30 :=
    l_old_assignment_rec.ass_attribute30;
    if (nvl(l_db_assignment_rec.ass_attribute30, hr_api.g_varchar2) <>
       nvl(l_old_assignment_rec.ass_attribute30, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.ass_attribute30 := p_ass_attribute30;
    if (nvl(p_ass_attribute30, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.ass_attribute30, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

open csr_pgp_segments(l_db_assignment_rec.people_group_id);
fetch csr_pgp_segments into l_people_groups;
close csr_pgp_segments;

if (l_people_groups.segment1 is null and l_people_groups.segment2 is null and
    l_people_groups.segment3 is null and l_people_groups.segment4 is null and
    l_people_groups.segment5 is null and l_people_groups.segment6 is null and
    l_people_groups.segment7 is null and l_people_groups.segment8 is null and
    l_people_groups.segment9 is null and l_people_groups.segment10 is null and
    l_people_groups.segment11 is null and l_people_groups.segment12 is null and
    l_people_groups.segment13 is null and l_people_groups.segment14 is null and
    l_people_groups.segment15 is null and l_people_groups.segment16 is null and
    l_people_groups.segment17 is null and l_people_groups.segment18 is null and
    l_people_groups.segment19 is null and l_people_groups.segment20 is null and
    l_people_groups.segment21 is null and l_people_groups.segment22 is null and
    l_people_groups.segment23 is null and l_people_groups.segment24 is null and
    l_people_groups.segment25 is null and l_people_groups.segment26 is null and
    l_people_groups.segment27 is null and l_people_groups.segment28 is null and
    l_people_groups.segment29 is null and l_people_groups.segment30 is null) then
  all_pgp_null := 'Y';
end if;

if (p_people_group_id = hr_api.g_number) then
    l_assignment_rec.people_group_id :=
    l_old_assignment_rec.people_group_id;
  if (l_old_assignment_rec.people_group_id is not null OR all_pgp_null = 'N') then
    if nvl(l_old_assignment_rec.people_group_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.people_group_id, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
  end if;
else
    l_assignment_rec.people_group_id := p_people_group_id;
  if (p_people_group_id is not null OR all_pgp_null = 'N') then
    if (nvl(p_people_group_id, -1)
       <> nvl(l_db_assignment_rec.people_group_id,-1))
    then
       i_changed:=TRUE;
    end if;
  end if;
end if;

open csr_scl_segments(l_db_assignment_rec.soft_coding_keyflex_id);
fetch csr_scl_segments into l_soft_coding_keyflex;
close csr_scl_segments;

if (l_soft_coding_keyflex.segment1 is null and l_soft_coding_keyflex.segment2 is null and
    l_soft_coding_keyflex.segment3 is null and l_soft_coding_keyflex.segment4 is null and
    l_soft_coding_keyflex.segment5 is null and l_soft_coding_keyflex.segment6 is null and
    l_soft_coding_keyflex.segment7 is null and l_soft_coding_keyflex.segment8 is null and
    l_soft_coding_keyflex.segment9 is null and l_soft_coding_keyflex.segment10 is null and
    l_soft_coding_keyflex.segment11 is null and l_soft_coding_keyflex.segment12 is null and
    l_soft_coding_keyflex.segment13 is null and l_soft_coding_keyflex.segment14 is null and
    l_soft_coding_keyflex.segment15 is null and l_soft_coding_keyflex.segment16 is null and
    l_soft_coding_keyflex.segment17 is null and l_soft_coding_keyflex.segment18 is null and
    l_soft_coding_keyflex.segment19 is null and l_soft_coding_keyflex.segment20 is null and
    l_soft_coding_keyflex.segment21 is null and l_soft_coding_keyflex.segment22 is null and
    l_soft_coding_keyflex.segment23 is null and l_soft_coding_keyflex.segment24 is null and
    l_soft_coding_keyflex.segment25 is null and l_soft_coding_keyflex.segment26 is null and
    l_soft_coding_keyflex.segment27 is null and l_soft_coding_keyflex.segment28 is null and
    l_soft_coding_keyflex.segment29 is null and l_soft_coding_keyflex.segment30 is null) then
  all_scl_null := 'Y';
end if;

if (p_soft_coding_keyflex_id = hr_api.g_number) then
    l_assignment_rec.soft_coding_keyflex_id :=
    l_old_assignment_rec.soft_coding_keyflex_id;
  if (l_old_assignment_rec.soft_coding_keyflex_id is not null OR all_scl_null = 'N') then
    if nvl(l_old_assignment_rec.soft_coding_keyflex_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.soft_coding_keyflex_id, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
  end if;
else
    l_assignment_rec.soft_coding_keyflex_id := p_soft_coding_keyflex_id;
  if (p_soft_coding_keyflex_id is not null OR all_scl_null = 'N') then
    if (nvl(p_soft_coding_keyflex_id, -1)
       <> nvl(l_db_assignment_rec.soft_coding_keyflex_id,-1))
    then
       i_changed:=TRUE;
    end if;
  end if;
end if;

if (p_sal_review_period_frequency = hr_api.g_varchar2) then
    l_assignment_rec.sal_review_period_frequency :=
    l_old_assignment_rec.sal_review_period_frequency;
    if (nvl(l_db_assignment_rec.sal_review_period_frequency, hr_api.g_varchar2)
       <>
       nvl(l_old_assignment_rec.sal_review_period_frequency, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.sal_review_period_frequency :=
                p_sal_review_period_frequency;
    if (nvl(p_sal_review_period_frequency, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.sal_review_period_frequency, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_sal_review_period = hr_api.g_number) then
    l_assignment_rec.sal_review_period :=
    l_old_assignment_rec.sal_review_period;
    if nvl(l_old_assignment_rec.sal_review_period, hr_api.g_number)
       <> nvl(l_db_assignment_rec.sal_review_period, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.sal_review_period := p_sal_review_period;
    if (nvl(p_sal_review_period, -1) <>
         nvl(l_db_assignment_rec.sal_review_period,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_probation_period = hr_api.g_number) then
    l_assignment_rec.probation_period :=
    l_old_assignment_rec.probation_period;
    if nvl(l_old_assignment_rec.probation_period, hr_api.g_number)
       <> nvl(l_db_assignment_rec.probation_period, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.probation_period := p_probation_period;
    if (nvl(p_probation_period, -1) <>
         nvl(l_db_assignment_rec.probation_period,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (to_char(p_date_probation_end) = to_char(hr_api.g_date)) then
    l_assignment_rec.date_probation_end :=
    l_old_assignment_rec.date_probation_end;

    if (nvl(l_db_assignment_rec.date_probation_end, hr_api.g_date)
       <>
       nvl(l_old_assignment_rec.date_probation_end, hr_api.g_date))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.date_probation_end :=
                p_date_probation_end;
    if (nvl(p_date_probation_end, hr_api.g_date) <>
       nvl(l_db_assignment_rec.date_probation_end, hr_api.g_date))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_probation_unit = hr_api.g_varchar2) then
    l_assignment_rec.probation_unit :=
    l_old_assignment_rec.probation_unit;
    if (nvl(l_db_assignment_rec.probation_unit, hr_api.g_varchar2)
       <>
       nvl(l_old_assignment_rec.probation_unit, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.probation_unit :=
                p_probation_unit;
    if (nvl(p_probation_unit, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.probation_unit, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_notice_period = hr_api.g_number) then
    l_assignment_rec.notice_period :=
    l_old_assignment_rec.notice_period;
    if nvl(l_old_assignment_rec.notice_period, hr_api.g_number)
       <> nvl(l_db_assignment_rec.notice_period, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.notice_period := p_notice_period;
    if (nvl(p_notice_period, -1) <>
         nvl(l_db_assignment_rec.notice_period,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_notice_period_uom = hr_api.g_varchar2) then
    l_assignment_rec.notice_period_uom :=
    l_old_assignment_rec.notice_period_uom;
    if (nvl(l_db_assignment_rec.notice_period_uom, hr_api.g_varchar2)
       <>
       nvl(l_old_assignment_rec.notice_period_uom, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.notice_period_uom :=
                p_notice_period_uom;
    if (nvl(p_notice_period_uom, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.notice_period_uom, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_employee_category = hr_api.g_varchar2) then
    l_assignment_rec.employee_category :=
    l_old_assignment_rec.employee_category;
    if (nvl(l_db_assignment_rec.employee_category, hr_api.g_varchar2)
       <>
       nvl(l_old_assignment_rec.employee_category, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.employee_category :=
                p_employee_category;
    if (nvl(p_employee_category, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.employee_category, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_work_at_home = hr_api.g_varchar2) then
    l_assignment_rec.work_at_home :=
    l_old_assignment_rec.work_at_home;
    if (nvl(l_db_assignment_rec.work_at_home, hr_api.g_varchar2)
       <>
       nvl(l_old_assignment_rec.work_at_home, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.work_at_home :=
                p_work_at_home;
    if (nvl(p_work_at_home, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.work_at_home, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_job_post_source_name = hr_api.g_varchar2) then
    l_assignment_rec.job_post_source_name :=
    l_old_assignment_rec.job_post_source_name;
    if (nvl(l_db_assignment_rec.job_post_source_name, hr_api.g_varchar2)
       <>
       nvl(l_old_assignment_rec.job_post_source_name, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.job_post_source_name :=
                p_job_post_source_name;
    if (nvl(p_job_post_source_name, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.job_post_source_name, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_title = hr_api.g_varchar2) then
    l_assignment_rec.title :=
    l_old_assignment_rec.title;
    if nvl(l_old_assignment_rec.title, hr_api.g_varchar2)
       <> nvl(l_db_assignment_rec.title, hr_api.g_varchar2)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.title := p_title;
    if (nvl(p_title, -1) <>
         nvl(l_db_assignment_rec.title,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_project_title = hr_api.g_varchar2) then
    l_assignment_rec.project_title :=
    l_old_assignment_rec.project_title;
    if nvl(l_old_assignment_rec.project_title, hr_api.g_varchar2)
       <> nvl(l_db_assignment_rec.project_title, hr_api.g_varchar2)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.project_title := p_project_title;
    if (nvl(p_project_title, -1) <>
         nvl(l_db_assignment_rec.project_title,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_source_type = hr_api.g_varchar2) then
    l_assignment_rec.source_type :=
    l_old_assignment_rec.source_type;
    if nvl(l_old_assignment_rec.source_type, hr_api.g_varchar2)
       <> nvl(l_db_assignment_rec.source_type, hr_api.g_varchar2)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.source_type := p_source_type;
    if (nvl(p_source_type, -1) <>
         nvl(l_db_assignment_rec.source_type,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_vendor_assignment_number = hr_api.g_varchar2) then
    l_assignment_rec.vendor_assignment_number :=
    l_old_assignment_rec.vendor_assignment_number;
    if nvl(l_old_assignment_rec.vendor_assignment_number, hr_api.g_varchar2)
       <> nvl(l_db_assignment_rec.vendor_assignment_number, hr_api.g_varchar2)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.vendor_assignment_number := p_vendor_assignment_number;
    if (nvl(p_vendor_assignment_number, -1) <>
         nvl(l_db_assignment_rec.vendor_assignment_number,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_vendor_employee_number = hr_api.g_varchar2) then
    l_assignment_rec.vendor_employee_number :=
    l_old_assignment_rec.vendor_employee_number;
    if nvl(l_old_assignment_rec.vendor_employee_number, hr_api.g_varchar2)
       <> nvl(l_db_assignment_rec.vendor_employee_number, hr_api.g_varchar2)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.vendor_employee_number := p_vendor_employee_number;
    if (nvl(p_vendor_employee_number, -1) <>
         nvl(l_db_assignment_rec.vendor_employee_number,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_default_code_comb_id = hr_api.g_number) then
    l_assignment_rec.default_code_comb_id :=
    l_old_assignment_rec.default_code_comb_id;
    if nvl(l_old_assignment_rec.default_code_comb_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.default_code_comb_id, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.default_code_comb_id := p_default_code_comb_id;
    if (nvl(p_default_code_comb_id, -1) <>
         nvl(l_db_assignment_rec.default_code_comb_id,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_set_of_books_id = hr_api.g_number) then
    l_assignment_rec.set_of_books_id :=
    l_old_assignment_rec.set_of_books_id;
    if nvl(l_old_assignment_rec.set_of_books_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.set_of_books_id, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.set_of_books_id := p_set_of_books_id;
    if (nvl(p_set_of_books_id, -1) <>
         nvl(l_db_assignment_rec.set_of_books_id,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_vendor_id = hr_api.g_number) then
    l_assignment_rec.vendor_id :=
    l_old_assignment_rec.vendor_id;
    if nvl(l_old_assignment_rec.vendor_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.vendor_id, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.vendor_id := p_vendor_id;
    if (nvl(p_vendor_id, -1) <>
         nvl(l_db_assignment_rec.vendor_id,-1))
    then
       i_changed:=TRUE;
    end if;
end if;


if (p_po_header_id = hr_api.g_number) then
    l_assignment_rec.po_header_id :=
    l_old_assignment_rec.po_header_id;
    if nvl(l_old_assignment_rec.po_header_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.po_header_id, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.po_header_id := p_po_header_id;
    if (nvl(p_po_header_id, -1) <>
         nvl(l_db_assignment_rec.po_header_id,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_po_line_id = hr_api.g_number) then
    l_assignment_rec.po_line_id :=
    l_old_assignment_rec.po_line_id;
    if nvl(l_old_assignment_rec.po_line_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.po_line_id, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.po_line_id := p_po_line_id;
    if (nvl(p_po_line_id, -1) <>
         nvl(l_db_assignment_rec.po_line_id,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_vendor_site_id = hr_api.g_number) then
    l_assignment_rec.vendor_site_id :=
    l_old_assignment_rec.vendor_site_id;
    if nvl(l_old_assignment_rec.vendor_site_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.vendor_site_id, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.vendor_site_id := p_vendor_site_id;
    if (nvl(p_vendor_site_id, -1) <>
         nvl(l_db_assignment_rec.vendor_site_id,-1))
    then
       i_changed:=TRUE;
    end if;
end if;


if (p_proj_asgn_end = g_canonical_date) then
    l_assignment_rec.projected_assignment_end :=
    l_old_assignment_rec.projected_assignment_end;
    if (nvl(l_db_assignment_rec.projected_assignment_end, g_canonical_date)
       <>
       nvl(l_old_assignment_rec.projected_assignment_end, g_canonical_date))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.projected_assignment_end :=
                p_proj_asgn_end;
    if (nvl(p_proj_asgn_end,g_canonical_date) <>
       nvl(l_db_assignment_rec.projected_assignment_end,g_canonical_date))
    then
       i_changed:=TRUE;
    end if;
end if;

-- the following 2 fields are planed for sshr 5.2.
-- We will enable it later.

-- GSP change
if (p_grade_ladder_pgm_id = hr_api.g_number) then
    l_assignment_rec.grade_ladder_pgm_id :=
    l_old_assignment_rec.grade_ladder_pgm_id;
    if nvl(l_old_assignment_rec.grade_ladder_pgm_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.grade_ladder_pgm_id, hr_api.g_number)
    then
       --lb_grade_ladder_changed := true;
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.grade_ladder_pgm_id := p_grade_ladder_pgm_id;
    if (nvl(p_grade_ladder_pgm_id, -1) <>
         nvl(l_db_assignment_rec.grade_ladder_pgm_id,-1))
    then
       --lb_grade_ladder_changed := true;
       i_changed:=TRUE;
    end if;
end if;
--End of GSP change

--if (p_supervisor_assignment_id = hr_api.g_number) then
--    l_assignment_rec.supervisor_assignment_id :=
--    l_old_assignment_rec.supervisor_assignment_id;
--    if nvl(l_old_assignment_rec.supervisor_assignment_id, hr_api.g_number)
--       <> nvl(l_db_assignment_rec.supervisor_assignment_id, hr_api.g_number)
--    then
--       others_changed:=TRUE;
--    end if;
--else
--    l_assignment_rec.supervisor_assignment_id := p_supervisor_assignment_id;
--    if (nvl(p_supervisor_assignment_id, -1) <>
--         nvl(l_db_assignment_rec.supervisor_assignment_id,-1))
--    then
--       i_changed:=TRUE;
--    end if;
--end if;

if (p_assignment_type = hr_api.g_varchar2) then
    l_assignment_rec.assignment_type :=
    l_old_assignment_rec.assignment_type;
    if nvl(l_old_assignment_rec.assignment_type, hr_api.g_varchar2)
       <> nvl(l_db_assignment_rec.assignment_type, hr_api.g_varchar2)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.assignment_type := p_assignment_type;
    if (nvl(p_assignment_type, -1) <>
         nvl(l_db_assignment_rec.assignment_type,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_perf_review_period = hr_api.g_number) then
    l_assignment_rec.perf_review_period :=
    l_old_assignment_rec.perf_review_period;
    if nvl(l_old_assignment_rec.perf_review_period, hr_api.g_number)
       <> nvl(l_db_assignment_rec.perf_review_period, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.perf_review_period := p_perf_review_period;
    if (nvl(p_perf_review_period, -1) <>
         nvl(l_db_assignment_rec.perf_review_period,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_perf_review_period_frequency = hr_api.g_varchar2) then
    l_assignment_rec.perf_review_period_frequency :=
    l_old_assignment_rec.perf_review_period_frequency;
    if (nvl(l_db_assignment_rec.perf_review_period_frequency, hr_api.g_varchar2)
       <>
      nvl(l_old_assignment_rec.perf_review_period_frequency, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.perf_review_period_frequency :=
                p_perf_review_period_frequency;
    if (nvl(p_perf_review_period_frequency, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.perf_review_period_frequency, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_internal_address_line = hr_api.g_varchar2) then
    l_assignment_rec.internal_address_line :=
    l_old_assignment_rec.internal_address_line;
    if (nvl(l_db_assignment_rec.internal_address_line, hr_api.g_varchar2)
       <>
       nvl(l_old_assignment_rec.internal_address_line, hr_api.g_varchar2))
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.internal_address_line :=
                p_internal_address_line;
    if (nvl(p_internal_address_line, hr_api.g_varchar2) <>
       nvl(l_db_assignment_rec.internal_address_line, hr_api.g_varchar2))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_payroll_id = hr_api.g_number) then
    l_assignment_rec.payroll_id :=
    l_old_assignment_rec.payroll_id;
    if nvl(l_old_assignment_rec.payroll_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.payroll_id, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.payroll_id := p_payroll_id;
    if (nvl(p_payroll_id, -1) <> nvl(l_db_assignment_rec.payroll_id,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

-- 04/12/02 Salary Basis Enhancement Change Begins
-- IF payroll is installed and the payroll_id is null, we need to issue an
-- error message when a salary basis is changed because we cannot derive the
-- mid pay period which needs the payroll_id to access the per_time_periods
-- table.
l_legislation_code := hr_misc_web.get_legislation_code
                       (p_assignment_id => l_assignment_id);

if (p_pay_basis_id = hr_api.g_number) then
    l_assignment_rec.pay_basis_id :=
    l_old_assignment_rec.pay_basis_id;
    if nvl(l_old_assignment_rec.pay_basis_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.pay_basis_id, hr_api.g_number)
    then
       -- 05/14/02 - Bug 2374140 Fix Begins
       -- Removed the code to set the WF item attribute HR_MID_PAY_PERIOD_CHANGE
       -- here.  Instead, we'll set it in the Approvals process when a trans
       -- is submitted.
       -- The reason is that if we set it here, in a Save For Later transaction
       -- where the user stopped at the Pay Rate page and change the effective
       -- date on re-entry of the SFL transaction, this item attribute will not
       -- be reset because the Assignment page will not be relaunched.  Only the
       -- Pay Rate page will be relaunched.  Yet, we cannot set it in the
       -- Pay Rate page because if there is any module comes after Pay Rate
       -- in the chained process, this same problem will occur in a SFL if the
       -- user last stopped at the page which comes after Pay Rate and changes
       -- the effective date on a reentry of the SFL transaction.

       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.pay_basis_id := p_pay_basis_id;
    if (nvl(p_pay_basis_id, -1) <> nvl(l_db_assignment_rec.pay_basis_id,-1))
    then
       -- 05/14/02 - Bug 2374140 Fix Begins
       -- Removed the code to set the WF item attribute HR_MID_PAY_PERIOD_CHANGE
       -- here.  Instead, we'll set it in the Approvals process when a trans
       -- is submitted.
       -- The reason is that if we set it here, in a Save For Later transaction
       -- where the user stopped at the Pay Rate page and change the effective
       -- date on re-entry of the SFL transaction, this item attribute will not
       -- be reset because the Assignment page will not be relaunched.  Only the
       -- Pay Rate page will be relaunched.  Yet, we cannot set it in the
       -- Pay Rate page because if there is any module comes after Pay Rate
       -- in the chained process, this same problem will occur in a SFL if the
       -- user last stopped at the page which comes after Pay Rate and changes
       -- the effective date on a reentry of the SFL transaction.

       i_changed:=TRUE;
    end if;

    -- 05/14/02 - Bug 2374140 Fix Ends
end if;


if (p_contract_id = hr_api.g_number) then
    l_assignment_rec.contract_id :=
    l_old_assignment_rec.contract_id;
    if nvl(l_old_assignment_rec.contract_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.contract_id, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.contract_id := p_contract_id;
    if (nvl(p_contract_id, -1) <> nvl(l_db_assignment_rec.contract_id,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_establishment_id = hr_api.g_number) then
    l_assignment_rec.establishment_id :=
    l_old_assignment_rec.establishment_id;
    if nvl(l_old_assignment_rec.establishment_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.establishment_id, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.establishment_id := p_establishment_id;
    if (nvl(p_establishment_id, -1) <>
        nvl(l_db_assignment_rec.establishment_id,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_cagr_grade_def_id = hr_api.g_number) then
    l_assignment_rec.cagr_grade_def_id :=
    l_old_assignment_rec.cagr_grade_def_id;
    if nvl(l_old_assignment_rec.cagr_grade_def_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.cagr_grade_def_id, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.cagr_grade_def_id := p_cagr_grade_def_id;
    if (nvl(p_cagr_grade_def_id, -1) <>
        nvl(l_db_assignment_rec.cagr_grade_def_id,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_cagr_id_flex_num = hr_api.g_number) then
    l_assignment_rec.cagr_id_flex_num :=
    l_old_assignment_rec.cagr_id_flex_num;
    if nvl(l_old_assignment_rec.cagr_id_flex_num, hr_api.g_number)
       <> nvl(l_db_assignment_rec.cagr_id_flex_num, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.cagr_id_flex_num := p_cagr_id_flex_num;
    if (nvl(p_cagr_id_flex_num, -1) <>
        nvl(l_db_assignment_rec.cagr_id_flex_num,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_collective_agreement_id = hr_api.g_number) then
    l_assignment_rec.collective_agreement_id :=
    l_old_assignment_rec.collective_agreement_id;
    if nvl(l_old_assignment_rec.collective_agreement_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.collective_agreement_id, hr_api.g_number)
    then
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.collective_agreement_id := p_collective_agreement_id;
    if (nvl(p_collective_agreement_id, -1) <>
        nvl(l_db_assignment_rec.collective_agreement_id,-1))
    then
       i_changed:=TRUE;
    end if;
end if;

if (p_assignment_status_type_id = hr_api.g_number) then
    l_assignment_rec.assignment_status_type_id :=
    l_old_assignment_rec.assignment_status_type_id;
    if nvl(l_old_assignment_rec.assignment_status_type_id, hr_api.g_number)
       <> nvl(l_db_assignment_rec.assignment_status_type_id, hr_api.g_number)
    then
       if i_changed or others_changed then
          j_changed := 'Y';
       end if;
       others_changed:=TRUE;
    end if;
else
    l_assignment_rec.assignment_status_type_id := p_assignment_status_type_id;
    if (nvl(p_assignment_status_type_id, -1) <>
       nvl(l_db_assignment_rec.assignment_status_type_id, -1))
    then
       if i_changed or others_changed then
          j_changed := 'Y';
       end if;
       i_changed:=TRUE;
    end if;
end if;

l_term_sec_asg := wf_engine.getitemattrtext(p_item_type, p_item_key,
                                                'HR_TERM_SEC_ASG',true);

if (l_term_sec_asg is null OR l_term_sec_asg <> 'Y') then
  j_changed := 'Y';
end if;

if ( p_hrs_last_date= hr_api.g_varchar2) then
    l_hrs_last_date :=
    null;
else
    l_hrs_last_date := p_hrs_last_date;
end if;
if ( p_display_pos= hr_api.g_varchar2) then
    l_display_pos :=
    null;
else
    l_display_pos := p_display_pos;
end if;

if ( p_display_org= hr_api.g_varchar2) then
    l_display_org :=
    null;
else
    l_display_org := p_display_org;
end if;
if ( p_display_ass_status= hr_api.g_varchar2) then
    l_display_ass_status :=
    null;
else
    l_display_ass_status := p_display_ass_status;
end if;
if ( p_display_job= hr_api.g_varchar2) then
    l_display_job :=
    null;
else
    l_display_job := p_display_job;
end if;
-- Bug #1067636 fix begins
if ( p_display_grade = hr_api.g_varchar2) then
    l_display_grade :=
    null;
else
    l_display_grade := p_display_grade;
end if;
-- Bug #1067636 fix ends

-- Bug #1004255 fix
if ( p_grade_lov = hr_api.g_varchar2) then
    l_grade_lov := null;
else
    l_grade_lov := p_grade_lov;
end if;

if ( p_approver_id= hr_api.g_number) then
    l_approver_id :=
    null;
else
    l_approver_id := p_approver_id;
end if;

-- This is added for registration to support the Browser Back issues which was prohibiting the
-- commit to the transaction tables if the data is not changed and in turn was not letting the
-- rollback call to execute .

if p_flow_mode is not null and
   p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
then
i_changed := TRUE;
end if;
-- Code end for registration.

if i_changed or others_changed
then
if p_save_mode <> 'SAVE_FOR_LATER' then
--
-- To support applicant hire in New Hire process, we need to convert the applicant
-- to employee then update the assignment and rollback the employee to applicant

l_person_type_id :=     hr_transaction_api.get_number_value
			(p_transaction_step_id =>  l_per_step_id
			,p_name                => 'P_PERSON_TYPE_ID');

if(l_db_assignment_rec.assignment_type = 'A' AND (l_asgn_change_mode is null OR
     l_asgn_change_mode = 'N' OR l_asgn_change_mode = 'Y') ) then
   g_applicant_hire := true;
   -- first get the object_version_number for the applicant from
   -- per_all_people_f
   open per_applicant_rec(l_old_assignment_rec.person_id, l_effective_date);
   fetch per_applicant_rec into l_per_object_version_number;
   close per_applicant_rec;

   SAVEPOINT applicant_hire;

   -- get the employee number from Basic Details Step
   /*hr_person_info_util_ss.get_trns_employee_number(
                        p_item_type => p_item_type
                       ,p_item_key => p_item_key
                       ,p_employee_number => l_employee_number);

   --call the hr_applicant_api.hire_applicant
   hr_applicant_api.hire_applicant(
      p_validate => false
     ,p_hire_date => l_effective_date
     ,p_person_id => l_db_assignment_rec.person_id
     ,p_per_object_version_number => l_per_object_version_number
     ,p_assignment_id => l_db_assignment_rec.assignment_id
     ,p_employee_number => l_employee_number
     ,p_per_effective_start_date => l_per_effective_start_date
     ,p_per_effective_end_date => l_per_effective_end_date
     ,p_unaccepted_asg_del_warning  => l_unaccepted_asg_del_warning
     ,p_assign_payroll_warning => l_assign_payroll_warning);*/

-- Also we need to call the Primay Address Step as the primary address needs to be
-- created for the applicant, incase payroll is entered
   -- we need to call the HR_PROCESS_PERSON_SS.PROCESS_API
   -- to update the person's info first
   -- before update the assignment. Such as birthday is required for
   -- payroll.
   hr_new_user_reg_ss.process_selected_transaction(p_item_type => l_item_type,
                                                   p_item_key => l_item_key
                         ,p_api_name => 'HR_PROCESS_PERSON_SS.PROCESS_API');
   hr_new_user_reg_ss.process_selected_transaction(p_item_type => l_item_type,
                                                   p_item_key => l_item_key
			 ,p_api_name => 'HR_PROCESS_ADDRESS_SS.PROCESS_API');

-- Need to use the latest object version number and also assginment_status_type_id
-- before calling the update_assignment as the above api call will change the object
-- version number and update the assignment record in correction mode
-- first get the object_version_number for the applicant from
-- per_all_assignments_f
   open asg_applicant_rec(l_assignment_id, l_effective_date);
   fetch asg_applicant_rec into l_object_version_number
                               ,l_assignment_rec.assignment_status_type_id;
   close asg_applicant_rec;

   l_datetrack_update_mode :=  'CORRECTION';

end if;

if (l_asgn_change_mode = 'V' or l_asgn_change_mode = 'W') then
   open per_applicant_rec(l_old_assignment_rec.person_id, l_effective_date);
   fetch per_applicant_rec into l_per_object_version_number;
   close per_applicant_rec;
   g_applicant_hire := true;
   SAVEPOINT applicant_hire;
end if;

  if (l_asgn_change_mode = 'Y') then
    l_assignment_rec.primary_flag := 'Y';
  else
    l_assignment_rec.primary_flag := l_db_assignment_rec.primary_flag;
  end if;

--
-- the data has changed, so we call the api --
--
--update_assignment will check default gre when l_new_hire_appl_hire is 'Y'
if p_flow_mode is not null or g_applicant_hire then
  l_new_hire_appl_hire := 'Y';
else
  l_new_hire_appl_hire := 'N';
end if;

-- GSP Support code
 -- check whether grade/step/ got changed based on Grade Ladder setup,
 -- then only I need to store Pay Rate Txn data
  hr_pay_rate_gsp_ss.check_grade_ladder_exists(
                   p_business_group_id =>  l_assignment_rec.organization_id,
                   p_effective_date =>  l_effective_date,
                   p_grd_ldr_exists_flag => lb_grd_ldr_exists_flag);

 if(lb_grd_ldr_exists_flag) then
--     and (lb_special_ceiling_step_id_chg or lb_grade_changed) ) then

   -- check whether grade ladder won't allow salary update
   open lc_sal_updateable_grade_ladder(p_grade_ladder_id =>
                              l_assignment_rec.grade_ladder_pgm_id,
                              p_effective_date => l_effective_date
                              );
   fetch lc_sal_updateable_grade_ladder into lc_temp_grade_ladder_id, lc_temp_upd_sal_cd;
   if (lc_sal_updateable_grade_ladder%FOUND) THEN
    -- initializing local salary data table type to pass to store into txn
    ltt_salary_data := sshr_sal_prop_tab_typ(sshr_sal_prop_obj_typ(
                null,-- pay_proposal_id       NUMBER,
                l_assignment_id,-- assignment_id         NUMBER,
                l_assignment_rec.business_group_id,--business_group_id   NUMBER,
                l_effective_date,--effective_date        DATE,
                null,--comments              VARCHAR2(2000),
                null,--next_sal_review_date  DATE,
                null,--salary_change_amount  NUMBER ,
                null,--salary_change_percent NUMBER ,
                null,--annual_change         NUMBER ,
                null,--proposed_salary       NUMBER ,
                null,--proposed_percent      NUMBER ,
                null,--proposal_reason       VARCHAR2(30),
                null,--ranking               NUMBER,
                null,--current_salary        NUMBER,
                null,--performance_review_id NUMBER,
                null,--multiple_components   VARCHAR2(1),
                null,--element_entry_id      NUMBER ,
                null,--selection_mode        VARCHAR2(1),
                null,--ovn                   NUMBER,
                null,--currency              VARCHAR2(15),
                null,--pay_basis_name        VARCHAR2(80),
                null,--annual_equivalent     NUMBER ,
                null,--total_percent        NUMBER ,
                null,--quartile              NUMBER ,
                null,--comparatio            NUMBER ,
                null,--lv_selection_mode     VARCHAR2(1),
                null,--attribute_category           VARCHAR2(150),
                null,--attribute1            VARCHAR2(150),
                null,--attribute2            VARCHAR2(150),
                null,--attribute3            VARCHAR2(150),
                null,--attribute4            VARCHAR2(150),
                null,--attribute5            VARCHAR2(150),
                null,--attribute6            VARCHAR2(150),
                null,--attribute7            VARCHAR2(150),
                null,--attribute8            VARCHAR2(150),
                null,--attribute9            VARCHAR2(150),
                null,--attribute10           VARCHAR2(150),
                null,--attribute11           VARCHAR2(150),
                null,--attribute12           VARCHAR2(150),
                null,--attribute13           VARCHAR2(150),
                null,--attribute14           VARCHAR2(150),
                null,--attribute15           VARCHAR2(150),
                null,--attribute16           VARCHAR2(150),
                null,--attribute17           VARCHAR2(150),
                null,--attribute18           VARCHAR2(150),
                null,--attribute19           VARCHAR2(150),
                null,--attribute20           VARCHAR2(150),
                null, --no_of_components       NUMBER,
                -- 04/12/02 Salary Basis Enhancement Begins
                null,  -- salary_basis_change_type varchar2(30)
                null,  -- default_date           date
                null,  -- default_bg_id          number
                null,  -- default_currency       VARCHAR2(15)
                null,  -- default_format_string  VARCHAR2(40)
                null,  -- default_salary_basis_name  varchar2(30)
                null,  -- default_pay_basis_name     varchar2(80)
                null,  -- default_pay_basis      varchar2(30)
                null,  -- default_pay_annual_factor  number
                null,  -- default_grade          VARCHAR2(240)
                null,  -- default_grade_annual_factor number
                null,  -- default_minimum_salary      number
                null,  -- default_maximum_salary      number
                null,  -- default_midpoint_salary     number
                null,  -- default_prev_salary         number
                null,  -- default_last_change_date    date
                null,  -- default_element_entry_id    number
                null,  -- default_basis_changed       number
                null,  -- default_uom                 VARCHAR2(30)
                null,  -- default_grade_uom           VARCHAR2(30)
                null,  -- default_change_amount       number
                null,  -- default_change_percent      number
                null,  -- default_quartile            number
                null,  -- default_comparatio          number
                null,  -- default_last_pay_change     varchar2(200)
                null,  -- default_flsa_status         varchar2(80)
                null,  -- default_currency_symbol     varchar2(4)
                null,   -- default_precision           number
                -- 04/12/02 Salary Basis Enhancement Ends
                -- GSP
                null,    -- salary_effective_date    date
                null,    -- gsp_dummy_txn            varchar2(30)
                -- End of GSP
                null,
                null,
                null,
                null,
                null
          ));
      -- store the current salary in the ltt_salary_data
      hr_pay_rate_gsp_ss.get_employee_current_salary(
                            p_assignment_id =>  l_assignment_id,
                            P_effective_date => l_effective_date,
                            p_ltt_salary_data => ltt_salary_data);
      -- In case of SFL for new hire, we are getting new salary
      -- so we are setting current salary to zero
      if p_flow_mode is not null and
         p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
      then
           ltt_salary_data(1).current_salary := 0;
      end if;
      -- end of fix
     end if;
     close lc_sal_updateable_grade_ladder;
  end if;
  -- End of GSP support change

if (l_asgn_change_mode is null OR l_asgn_change_mode = 'N' OR
      l_asgn_change_mode = 'Y') then
update_assignment
(p_validate                 =>     true
,p_login_person_id          =>     p_login_person_id
,p_new_hire_appl_hire       =>     l_new_hire_appl_hire
,p_assignment_id            =>     l_assignment_id
,p_object_version_number    =>     l_object_version_number
,p_effective_date           =>     l_effective_date
,p_datetrack_update_mode    =>     l_datetrack_update_mode
,p_organization_id          =>     l_assignment_rec.organization_id
,p_position_id              =>     l_assignment_rec.position_id
,p_job_id                   =>     l_assignment_rec.job_id
,p_grade_id                 =>     l_assignment_rec.grade_id
,p_location_id              =>     l_assignment_rec.location_id
,p_employment_category      =>     l_assignment_rec.employment_category
,p_supervisor_id            =>     l_assignment_rec.supervisor_id
,p_manager_flag             =>     l_assignment_rec.manager_flag
,p_frequency                =>     l_assignment_rec.frequency
,p_normal_hours             =>     l_assignment_rec.normal_hours
,p_time_normal_finish       =>     l_assignment_rec.time_normal_finish
,p_time_normal_start        =>     l_assignment_rec.time_normal_start
,p_bargaining_unit_code     =>     l_assignment_rec.bargaining_unit_code
,p_labour_union_member_flag =>     l_assignment_rec.labour_union_member_flag
,p_assignment_status_type_id=>     l_assignment_rec.assignment_status_type_id
,p_change_reason            =>     l_assignment_rec.change_reason
,p_special_ceiling_step_id  =>     l_assignment_rec.special_ceiling_step_id
,p_ass_attribute_category   =>     l_assignment_rec.ass_attribute_category
,p_ass_attribute1           =>     l_assignment_rec.ass_attribute1
,p_ass_attribute2           =>     l_assignment_rec.ass_attribute2
,p_ass_attribute3           =>     l_assignment_rec.ass_attribute3
,p_ass_attribute4           =>     l_assignment_rec.ass_attribute4
,p_ass_attribute5           =>     l_assignment_rec.ass_attribute5
,p_ass_attribute6           =>     l_assignment_rec.ass_attribute6
,p_ass_attribute7           =>     l_assignment_rec.ass_attribute7
,p_ass_attribute8           =>     l_assignment_rec.ass_attribute8
,p_ass_attribute9           =>     l_assignment_rec.ass_attribute9
,p_ass_attribute10          =>     l_assignment_rec.ass_attribute10
,p_ass_attribute11          =>     l_assignment_rec.ass_attribute11
,p_ass_attribute12          =>     l_assignment_rec.ass_attribute12
,p_ass_attribute13          =>     l_assignment_rec.ass_attribute13
,p_ass_attribute14          =>     l_assignment_rec.ass_attribute14
,p_ass_attribute15          =>     l_assignment_rec.ass_attribute15
,p_ass_attribute16          =>     l_assignment_rec.ass_attribute16
,p_ass_attribute17          =>     l_assignment_rec.ass_attribute17
,p_ass_attribute18          =>     l_assignment_rec.ass_attribute18
,p_ass_attribute19          =>     l_assignment_rec.ass_attribute19
,p_ass_attribute20          =>     l_assignment_rec.ass_attribute20
,p_ass_attribute21          =>     l_assignment_rec.ass_attribute21
,p_ass_attribute22          =>     l_assignment_rec.ass_attribute22
,p_ass_attribute23          =>     l_assignment_rec.ass_attribute23
,p_ass_attribute24          =>     l_assignment_rec.ass_attribute24
,p_ass_attribute25          =>     l_assignment_rec.ass_attribute25
,p_ass_attribute26          =>     l_assignment_rec.ass_attribute26
,p_ass_attribute27          =>     l_assignment_rec.ass_attribute27
,p_ass_attribute28          =>     l_assignment_rec.ass_attribute28
,p_ass_attribute29          =>     l_assignment_rec.ass_attribute29
,p_ass_attribute30          =>     l_assignment_rec.ass_attribute30
,p_soft_coding_keyflex_id   =>     l_assignment_rec.soft_coding_keyflex_id
,p_people_group_id          =>     l_assignment_rec.people_group_id
,p_contract_id              =>     l_assignment_rec.contract_id
,p_establishment_id         =>     l_assignment_rec.establishment_id
,p_cagr_grade_def_id        =>     l_assignment_rec.cagr_grade_def_id
,p_collective_agreement_id  =>     l_assignment_rec.collective_agreement_id
,p_cagr_id_flex_num         =>     l_assignment_rec.cagr_id_flex_num
,p_payroll_id               =>     l_assignment_rec.payroll_id
,p_pay_basis_id             =>     l_assignment_rec.pay_basis_id
,p_sal_review_period        =>     l_assignment_rec.sal_review_period
,p_sal_review_period_frequency => l_assignment_rec.sal_review_period_frequency
,p_date_probation_end       =>     l_assignment_rec.date_probation_end
,p_probation_period         =>      l_assignment_rec.probation_period
,p_probation_unit           =>     l_assignment_rec.probation_unit
,p_notice_period            =>     l_assignment_rec.notice_period
,p_notice_period_uom        =>     l_assignment_rec.notice_period_uom
,p_employee_category        =>     l_assignment_rec.employee_category
,p_work_at_home             =>     l_assignment_rec.work_at_home
,p_job_post_source_name     =>     l_assignment_rec.job_post_source_name
,p_perf_review_period       =>     l_assignment_rec.perf_review_period
,p_perf_review_period_frequency => l_assignment_rec.perf_review_period_frequency
,p_internal_address_line    =>     l_assignment_rec.internal_address_line
,p_business_group_id        =>     l_assignment_rec.business_group_id
-- GSP change
,p_grade_ladder_pgm_id      =>     l_assignment_rec.grade_ladder_pgm_id
-- End of GSP change
,p_assignment_type          =>     l_assignment_rec.assignment_type
--,p_supervisor_assignment_id =>     l_assignment_rec.supervisor_assignment_id
,p_vacancy_id               =>     l_assignment_rec.vacancy_id
,p_primary_flag             =>     l_assignment_rec.primary_flag
,p_person_id                =>     l_assignment_rec.person_id
,p_default_code_comb_id     =>     l_assignment_rec.default_code_comb_id
,p_project_title            =>     l_assignment_rec.project_title
,p_set_of_books_id          =>     l_assignment_rec.set_of_books_id
,p_source_type              =>     l_assignment_rec.source_type
,p_title                    =>     l_assignment_rec.title
,p_vendor_assignment_number =>     l_assignment_rec.vendor_assignment_number
,p_vendor_employee_number   =>     l_assignment_rec.vendor_employee_number
,p_vendor_id                =>     l_assignment_rec.vendor_id
,p_effective_start_date     =>     l_effective_start_date
,p_effective_end_date       =>     l_effective_end_date
,p_element_warning          =>     l_element_warning
,p_element_changed          =>     l_element_changed
,p_email_id                 =>     l_email_id
,p_page_error => p_page_error
,p_page_error_msg => p_page_error_msg
,p_page_warning => p_page_warning
,p_page_warning_msg => p_page_warning_msg
,p_organization_error => p_organization_error
,p_organization_error_msg => p_organization_error_msg
,p_job_error => p_job_error
,p_job_error_msg => p_job_error_msg
,p_position_error => p_position_error
,p_position_error_msg => p_position_error_msg
,p_grade_error => p_grade_error
,p_grade_error_msg => p_grade_error_msg
,p_supervisor_error => p_supervisor_error
,p_supervisor_error_msg => p_supervisor_error_msg
,p_location_error => p_location_error
,p_location_error_msg => p_location_error_msg
-- GSP change
,p_ltt_salary_data => ltt_salary_data
,p_gsp_post_process_warning => p_gsp_post_process_warning
-- End of GSP change
,p_po_header_id => p_po_header_id
,p_po_line_id  => p_po_line_id
,p_vendor_site_id  => p_vendor_site_id
,p_projected_asgn_end => p_proj_asgn_end
,p_j_changed => j_changed
);
else
l_assignment_rec.object_version_number := l_object_version_number;
l_assignment_rec.assignment_id := l_assignment_id;

update_apl_assignment(
p_assignment_rec => l_assignment_rec
,p_validate	=>	true
,p_effective_date  =>	l_effective_date
,p_person_id	=>	l_assignment_rec.person_id
,p_appl_assignment_id  =>	l_assignment_id
,p_person_type_id  =>	l_person_type_id
,p_overwrite_primary  =>	l_asgn_change_mode
,p_ovn	=> l_per_object_version_number);
end if;
p_element_changed:=l_element_changed;


else --end p_save_mode = 'SAVE_FOR_LATER'
  if(l_db_assignment_rec.assignment_type = 'A') then
    l_datetrack_update_mode :=  'CORRECTION';
  end if;
end if; --end p_save_mode <> 'SAVE_FOR_LATER'
--
-- if there were errors, handle them
--
--start registration
-- This is to rollback the dummy person created during the process request phase of the assignment page
-- the new user registration.
if p_flow_mode is not null and
   p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
then
rollback;
end if;
--end registration
--

-- applicant_hire
if (g_applicant_hire) then
   rollback to applicant_hire;
end if;

if g_exemp_hire then
rollback;
end if;

if NVL(p_element_changed,'X') <> 'W'  OR
   p_save_mode = 'SAVE_FOR_LATER' then
  --
  -- no error or save for later, so save to transaction table
  --
  if l_transaction_step_id is null then
    --
    -- first of all check if this transaction is already in progress
    --
    l_transaction_id:=hr_transaction_ss.get_transaction_id
                      (p_item_type   =>   l_item_type
                      ,p_item_key    =>   l_item_key);
    --
    -- if the transaction is not already in progress, create a new one
    --
    if l_transaction_id is null then
      hr_transaction_ss.start_transaction
      (itemtype    =>    l_item_type
      ,itemkey     =>    l_item_key
      ,actid       =>    l_activity_id
      ,funmode     =>    'RUN'
      ,p_login_person_id => p_login_person_id
      ,p_plan_id   =>    p_plan_id
      ,p_rptg_grp_id    =>  p_rptg_grp_id
      ,p_effective_date_option  => p_effective_date_option
      ,result      =>    l_result);
    --
      l_transaction_id:=hr_transaction_ss.get_transaction_id
                        (p_item_type   =>   l_item_type
                        ,p_item_key    =>   l_item_key);
      if l_transaction_id is null then
        fnd_message.set_name('PER', 'HR_CREATE_TRANSACTION_ID_ERR');
        hr_utility.raise_error;
      end if;
    end if;
    --
    -- create a transaction step
    --

  if (l_asgn_change_mode ='V' OR l_asgn_change_mode ='W') then
    hr_transaction_api.create_trans_step
      (p_validate              => false
      ,p_creator_person_id     => p_login_person_id
      ,p_transaction_id        => l_transaction_id
      ,p_api_name              => g_api_name
      ,p_item_type             => l_item_type
      ,p_item_key              => l_item_key
      ,p_activity_id           => l_activity_id
      ,p_transaction_step_id   => l_transaction_step_id
      ,p_processing_order      => 1
      ,p_object_version_number => l_trns_object_version_number
      );
  else
    open process_order(l_item_type,l_item_key);
    fetch process_order into l_proc_order;
    if process_order%found then
    hr_transaction_api.create_trans_step
      (p_validate              => false
      ,p_creator_person_id     => p_login_person_id
      ,p_transaction_id        => l_transaction_id
      ,p_api_name              => g_api_name
      ,p_item_type             => l_item_type
      ,p_item_key              => l_item_key
      ,p_activity_id           => l_activity_id
      ,p_transaction_step_id   => l_transaction_step_id
      ,p_processing_order      => l_proc_order - 1
      ,p_object_version_number => l_trns_object_version_number
      );
    else
    hr_transaction_api.create_transaction_step
      (p_validate              => false
      ,p_creator_person_id     => p_login_person_id
      ,p_transaction_id        => l_transaction_id
      ,p_api_name              => g_api_name
      ,p_item_type             => l_item_type
      ,p_item_key              => l_item_key
      ,p_activity_id           => l_activity_id
      ,p_transaction_step_id   => l_transaction_step_id
      ,p_object_version_number => l_trns_object_version_number
      );
     end if;
     close process_order;
  end if;
  --
  end if;
  --p_transaction_step_id := to_char(l_transaction_step_id);

  -- save the parameters to the temporary tables
  --
  l_count:=1;
  l_trans_tbl(l_count).param_name      := 'P_ASSIGNMENT_ID';
  l_trans_tbl(l_count).param_value     :=  l_assignment_id;
  l_trans_tbl(l_count).param_original_value := l_assignment_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_OBJECT_VERSION_NUMBER';
  l_trans_tbl(l_count).param_value     :=  p_object_version_number;
  l_trans_tbl(l_count).param_original_value := p_object_version_number;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_EFFECTIVE_DATE';
  l_trans_tbl(l_count).param_value     :=  p_effective_date;
  l_trans_tbl(l_count).param_original_value := p_effective_date; --ns
  l_trans_tbl(l_count).param_data_type := 'DATE';
  --
  --ns start
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_EFFECTIVE_DATE_OPTION';
  l_trans_tbl(l_count).param_value     :=  p_effective_date_option;
  l_trans_tbl(l_count).param_original_value := p_effective_date_option;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --ns end
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ELEMENT_CHANGED';
  l_trans_tbl(l_count).param_value     :=  p_element_changed;
  l_trans_tbl(l_count).param_original_value := p_element_changed; --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_DATETRACK_UPDATE_MODE';
  l_trans_tbl(l_count).param_value     :=  l_datetrack_update_mode;
  l_trans_tbl(l_count).param_original_value := l_datetrack_update_mode; --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ORGANIZATION_ID';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.organization_id;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.organization_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_BUSINESS_GROUP_ID';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.business_group_id;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.business_group_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_PERSON_ID';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.person_id;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.person_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_LOGIN_PERSON_ID';
  l_trans_tbl(l_count).param_value     :=  p_login_person_id;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_name := null;
  open csr_org_name(l_assignment_rec.organization_id);
  fetch csr_org_name into l_name;
  close csr_org_name;

  --ns start
  l_original_name := null;
  open csr_org_name(l_db_assignment_rec.organization_id);
  fetch csr_org_name into l_original_name;
  close csr_org_name;
  --ns end

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ORG_NAME';
  l_trans_tbl(l_count).param_value     :=  l_name;
  l_trans_tbl(l_count).param_original_value := l_original_name ;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_POSITION_ID';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.position_id;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.position_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_name := null;
  open csr_pos_name(l_assignment_rec.position_id);
  fetch csr_pos_name into l_name;
  close csr_pos_name;

  --ns start
  l_original_name := null;
  open csr_pos_name(l_db_assignment_rec.position_id);
  fetch csr_pos_name into l_original_name;
  close csr_pos_name;
  --ns end

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_POS_NAME';
  l_trans_tbl(l_count).param_value     :=  l_name;
  l_trans_tbl(l_count).param_original_value := l_original_name ;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_JOB_ID';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.job_id;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.job_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_name := null;
  open csr_job_name(l_assignment_rec.job_id);
  fetch csr_job_name into l_name;
  close csr_job_name;

  --ns start
  l_original_name := null;
  open csr_job_name(l_db_assignment_rec.job_id);
  fetch csr_job_name into l_original_name;
  close csr_job_name;
  --ns end

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_JOB_NAME';
  l_trans_tbl(l_count).param_value     :=  l_name;
  l_trans_tbl(l_count).param_original_value := l_original_name ;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_GRADE_ID';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.grade_id;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.grade_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_name := null;
  open csr_grade_name(l_assignment_rec.grade_id);
  fetch csr_grade_name into l_name;
  close csr_grade_name;

  --ns start
  l_original_name := null;
  open csr_grade_name(l_db_assignment_rec.grade_id);
  fetch csr_grade_name into l_original_name;
  close csr_grade_name;
  --ns end

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_GRADE_NAME';
  l_trans_tbl(l_count).param_value     :=  l_name;
  l_trans_tbl(l_count).param_original_value := l_original_name ;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_LOCATION_ID';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.location_id;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.location_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_EMPLOYMENT_CATEGORY';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.employment_category;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.employment_category;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_SUPERVISOR_ID';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.supervisor_id;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.supervisor_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_MANAGER_FLAG';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.manager_flag;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.manager_flag;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_NORMAL_HOURS';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.normal_hours;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.normal_hours;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_FREQUENCY';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.frequency;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.frequency;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_TIME_NORMAL_FINISH';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.time_normal_finish;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.time_normal_finish;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_TIME_NORMAL_START';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.time_normal_start;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.time_normal_start;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_BARGAINING_UNIT_CODE';
  l_trans_tbl(l_count).param_value  :=  l_assignment_rec.bargaining_unit_code;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.bargaining_unit_code;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_LABOUR_UNION_MEMBER_FLAG';
  l_trans_tbl(l_count).param_value := l_assignment_rec.labour_union_member_flag;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.labour_union_member_flag;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_SPECIAL_CEILING_STEP_ID';
  l_trans_tbl(l_count).param_value
    := l_assignment_rec.special_ceiling_step_id;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.special_ceiling_step_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASSIGNMENT_STATUS_TYPE_ID';
  l_trans_tbl(l_count).param_value
    := l_assignment_rec.assignment_status_type_id;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.assignment_status_type_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_CHANGE_REASON';
  l_trans_tbl(l_count).param_value
    :=  l_assignment_rec.change_reason;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.change_reason;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
--
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE_CATEGORY';
  l_trans_tbl(l_count).param_value
    :=  l_assignment_rec.ass_attribute_category;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute_category;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE1';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute1;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute1;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE2';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute2;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute2;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE3';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute3;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute3;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE4';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute4;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute4;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE5';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute5;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute5;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE6';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute6;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute6;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE7';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute7;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute7;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE8';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute8;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute8;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE9';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute9;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute9;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE10';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute10;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute10;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE11';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute11;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute11;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE12';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute12;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute12;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE13';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute13;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute13;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE14';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute14;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute14;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE15';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute15;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute15;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE16';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute16;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute16;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE17';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute17;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute17;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE18';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute18;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute18;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE19';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute19;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute19;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE20';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute20;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute20;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE21';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute21;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute21;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE22';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute22;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute22;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE23';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute23;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute23;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE24';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute24;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute24;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE25';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute25;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute25;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE26';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute26;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute26;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE27';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute27;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute27;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE28';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute28;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute28;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE29';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute29;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute29;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASS_ATTRIBUTE30';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.ass_attribute30;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.ass_attribute30;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_PEOPLE_GROUP_ID';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.people_group_id;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.people_group_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_SOFT_CODING_KEYFLEX_ID';
  l_trans_tbl(l_count).param_value :=  l_assignment_rec.soft_coding_keyflex_id;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.soft_coding_keyflex_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_PAYROLL_ID';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.payroll_id;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.payroll_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
 --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_PAY_BASIS_ID';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.pay_basis_id;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.pay_basis_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
--
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_SAL_REVIEW_PERIOD';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.sal_review_period;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.sal_review_period;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
--
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_SAL_REVIEW_PERIOD_FREQUENCY';
  l_trans_tbl(l_count).param_value     :=
         l_assignment_rec.sal_review_period_frequency;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.sal_review_period_frequency;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
--
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_DATE_PROBATION_END';
  l_trans_tbl(l_count).param_value     :=
         to_char(l_assignment_rec.date_probation_end,g_date_format);
  l_trans_tbl(l_count).param_original_value := to_char(l_db_assignment_rec.date_probation_end,g_date_format);  --ns
  l_trans_tbl(l_count).param_data_type := 'DATE';
--
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_PROBATION_PERIOD';
  l_trans_tbl(l_count).param_value     :=
         l_assignment_rec.probation_period;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.probation_period;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
--
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_PROBATION_UNIT';
  l_trans_tbl(l_count).param_value     :=
         l_assignment_rec.probation_unit;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.probation_unit;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
--
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_NOTICE_PERIOD';
  l_trans_tbl(l_count).param_value     :=
         l_assignment_rec.notice_period;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.notice_period;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
--
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_NOTICE_PERIOD_UOM';
  l_trans_tbl(l_count).param_value     :=
         l_assignment_rec.notice_period_uom;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.notice_period_uom;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
--
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_EMPLOYEE_CATEGORY';
  l_trans_tbl(l_count).param_value     :=
         l_assignment_rec.employee_category;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.employee_category;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
--
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_WORK_AT_HOME';
  l_trans_tbl(l_count).param_value     :=
         l_assignment_rec.work_at_home;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.work_at_home;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
--
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_JOB_POST_SOURCE_NAME';
  l_trans_tbl(l_count).param_value     :=
         l_assignment_rec.job_post_source_name;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.job_post_source_name;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
--
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_PERF_REVIEW_PERIOD';
  l_trans_tbl(l_count).param_value     :=
         l_assignment_rec.perf_review_period;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.perf_review_period;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
--
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_PERF_REVIEW_PERIOD_FREQUENCY';
  l_trans_tbl(l_count).param_value     :=
         l_assignment_rec.perf_review_period_frequency;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.perf_review_period_frequency;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
--
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_INTERNAL_ADDRESS_LINE';
  l_trans_tbl(l_count).param_value     :=
         l_assignment_rec.internal_address_line;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.internal_address_line;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_CONTRACT_ID';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.contract_id;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.contract_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ESTABLISHMENT_ID';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.establishment_id;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.establishment_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_COLLECTIVE_AGREEMENT_ID';
  l_trans_tbl(l_count).param_value :=  l_assignment_rec.collective_agreement_id;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.collective_agreement_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_CAGR_ID_FLEX_NUM';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.cagr_id_flex_num;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.cagr_id_flex_num;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_CAGR_GRADE_DEF_ID';
  l_trans_tbl(l_count).param_value     :=  l_assignment_rec.cagr_grade_def_id;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.cagr_grade_def_id;      --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_LABOUR_UNION_MEMBER_FLAG';
  l_trans_tbl(l_count).param_value := l_assignment_rec.labour_union_member_flag;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.labour_union_member_flag;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_BARGAINING_UNIT_CODE';
  l_trans_tbl(l_count).param_value := l_assignment_rec.bargaining_unit_code;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.bargaining_unit_code;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_DEFAULT_CODE_COMB_ID';
  l_trans_tbl(l_count).param_value := l_assignment_rec.default_code_comb_id;
  l_trans_tbl(l_count).param_original_value :=
         l_db_assignment_rec.default_code_comb_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_SET_OF_BOOKS_ID';
  l_trans_tbl(l_count).param_value := l_assignment_rec.set_of_books_id;
  l_trans_tbl(l_count).param_original_value :=
         l_db_assignment_rec.set_of_books_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VENDOR_ID';
  l_trans_tbl(l_count).param_value := l_assignment_rec.vendor_id;
  l_trans_tbl(l_count).param_original_value :=
         l_db_assignment_rec.vendor_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_ASSIGNMENT_TYPE';
  l_trans_tbl(l_count).param_value := l_assignment_rec.assignment_type;
  l_trans_tbl(l_count).param_original_value :=
         l_db_assignment_rec.assignment_type;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  --
  --l_count:=l_count+1;
  --l_trans_tbl(l_count).param_name      := 'P_SUPERVISOR_ASSIGNMENT_ID';
  --l_trans_tbl(l_count).param_value := l_assignment_rec.supervisor_assignment_id;
  --l_trans_tbl(l_count).param_original_value :=
  --       l_db_assignment_rec.supervisor_assignment_id;  --ns
  --l_trans_tbl(l_count).param_data_type := 'NUMBER';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_TITLE';
  l_trans_tbl(l_count).param_value := l_assignment_rec.title;
  l_trans_tbl(l_count).param_original_value :=
         l_db_assignment_rec.title;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_PROJECT_TITLE';
  l_trans_tbl(l_count).param_value := l_assignment_rec.project_title;
  l_trans_tbl(l_count).param_original_value :=
         l_db_assignment_rec.project_title;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_SOURCE_TYPE';
  l_trans_tbl(l_count).param_value := l_assignment_rec.source_type;
  l_trans_tbl(l_count).param_original_value :=
         l_db_assignment_rec.source_type;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VENDOR_ASSIGNMENT_NUMBER';
  l_trans_tbl(l_count).param_value := l_assignment_rec.vendor_assignment_number;
  l_trans_tbl(l_count).param_original_value :=
         l_db_assignment_rec.vendor_assignment_number;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VENDOR_EMPLOYEE_NUMBER';
  l_trans_tbl(l_count).param_value := l_assignment_rec.vendor_employee_number;
  l_trans_tbl(l_count).param_original_value :=
         l_db_assignment_rec.vendor_employee_number;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_SAVE_MODE';
  l_trans_tbl(l_count).param_value     :=  p_save_mode;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  -- look to see if the review page is already in the list
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_REVIEW_PROC_CALL';

  -- Bug 1043890 fix
  if i_changed
  then
    if(instr(l_review_proc_call,p_review_proc_call)>0) then
      --
      -- it is in the list already so just write the list
      --
      l_trans_tbl(l_count).param_value     :=  l_review_proc_call;
    else
      --
      -- it is not in the list, so add the delimiter and write the value
      --
      l_trans_tbl(l_count).param_value     :=  l_review_proc_call
                                           || '|!|'|| p_review_proc_call;
    end if;
  else
    -- if I am not changed, delete my review proc call from list
    if (instr(l_review_proc_call, '|!|'|| p_review_proc_call)>0)
    then
      l_trans_tbl(l_count).param_value :=
        replace(l_review_proc_call, '|!|'|| p_review_proc_call);
    elsif (instr(l_review_proc_call, p_review_proc_call)>0)
    then
      l_trans_tbl(l_count).param_value :=
        ltrim(replace(l_review_proc_call, p_review_proc_call),'|!|');
    else
      l_trans_tbl(l_count).param_value := l_review_proc_call;
    end if;
  end if;

  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  -- look to see if the activity_id is already in the list
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_REVIEW_ACTID';

  if i_changed
  then
    if(instr(l_activity_id_list,to_char(l_activity_id))>0) then
      --
      -- it is in the list already so just write the list
      --
      l_trans_tbl(l_count).param_value     :=  l_activity_id_list;
    else
      --
      -- it is not in the list, so add the delimiter and write the value
      --
      l_trans_tbl(l_count).param_value     :=  l_activity_id_list
                                             ||'|!|'||to_char(l_activity_id);
    end if;

  else
    -- if I am not changed, delete my activity id from list
    if (instr(l_activity_id_list, '|!|'|| to_char(l_activity_id))>0)
    then -- fixed for bug 3047196
      l_trans_tbl(l_count).param_value :=
        replace(l_activity_id_list, '|!|'|| to_char(l_activity_id));
    elsif (instr(l_activity_id_list, to_char(l_activity_id)||'|!|')>0)
    then
      l_trans_tbl(l_count).param_value :=
        ltrim(replace(l_activity_id_list, to_char(l_activity_id)||'|!|'));
    else
      l_trans_tbl(l_count).param_value     := l_activity_id_list;
    end if;

  end if;

  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
 --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_HRS_LAST_DATE';
  l_trans_tbl(l_count).param_value     :=  l_hrs_last_date;
-- fix for bug # 1255275
  l_trans_tbl(l_count).param_data_type := 'DATE';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_DISPLAY_POS';
  l_trans_tbl(l_count).param_value     :=  l_display_pos;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_DISPLAY_ORG';
  l_trans_tbl(l_count).param_value     :=  l_display_org;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_DISPLAY_JOB';
  l_trans_tbl(l_count).param_value     :=  l_display_job;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_DISPLAY_ASS_STATUS';
  l_trans_tbl(l_count).param_value     :=  l_display_ass_status;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  -- Bug #1067636 fix begins
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_DISPLAY_GRADE';
  l_trans_tbl(l_count).param_value     :=  l_display_grade;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  -- Bug #1067636 fix ends
  --
  -- Bug #1004255 fix
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_GRADE_LOV';
  l_trans_tbl(l_count).param_value     :=  l_grade_lov;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_APPROVER_ID';
  l_trans_tbl(l_count).param_value     :=  l_approver_id;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  --
  -- GSP change
  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_GRADE_LADDER_PGM_ID';
  l_trans_tbl(l_count).param_value := l_assignment_rec.grade_ladder_pgm_id;
  l_trans_tbl(l_count).param_original_value :=
         l_db_assignment_rec.grade_ladder_pgm_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';
 -- End of GSP change



  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_PO_HEADER_ID';
  l_trans_tbl(l_count).param_value := l_assignment_rec.po_header_id;
  l_trans_tbl(l_count).param_original_value :=
         l_db_assignment_rec.po_header_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_PO_LINE_ID';
  l_trans_tbl(l_count).param_value := l_assignment_rec.po_line_id;
  l_trans_tbl(l_count).param_original_value :=
         l_db_assignment_rec.po_line_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_VENDOR_SITE_ID';
  l_trans_tbl(l_count).param_value := l_assignment_rec.vendor_site_id;
  l_trans_tbl(l_count).param_original_value :=
         l_db_assignment_rec.vendor_site_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_PROJ_ASGN_END';
  l_trans_tbl(l_count).param_value := to_char(l_assignment_rec.projected_assignment_end, g_date_format);
    if(l_db_assignment_rec.projected_assignment_end is not null) then
      l_trans_tbl(l_count).param_original_value :=
             to_char(l_db_assignment_rec.projected_assignment_end, g_date_format);  --ns
    else
      l_trans_tbl(l_count).param_original_value :=
             l_db_assignment_rec.projected_assignment_end;  --ns
    end if;
  l_trans_tbl(l_count).param_data_type := 'DATE';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_PRIMARY_FLAG';
  l_trans_tbl(l_count).param_value :=  l_assignment_rec.primary_flag;
  l_trans_tbl(l_count).param_original_value := l_db_assignment_rec.primary_flag;  --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_J_CHANGED';
  l_trans_tbl(l_count).param_value := j_changed;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
  --
  -- save the transaction step
  --
  hr_transaction_ss.save_transaction_step
    (p_item_type             => l_item_type
    ,p_item_key              => l_item_key
    ,p_actid                 => l_activity_id
    ,p_login_person_id     => p_login_person_id
    ,p_transaction_step_id   => l_transaction_step_id
    ,p_transaction_data      => l_trans_tbl
    ,p_plan_id    => p_plan_id
    ,p_rptg_grp_id        => p_rptg_grp_id
    ,p_effective_date_option  => p_effective_date_option
    );

    open pay_step(l_item_type,l_item_key);		--bug6405208
    fetch pay_step into l_pay_step_id,l_pay_activity_id;
    if (pay_step%found and l_pay_activity_id <> -1 and
                                    l_assignment_rec.pay_basis_id is null) then
        hr_transaction_ss.delete_transaction_step
                (p_transaction_step_id => l_pay_step_id
                 ,p_login_person_id => p_login_person_id);
    end if;
    close pay_step;

  -- GSP
  -- Check whether grade/step changed and Grade Ladder setup is done
  -- for the business group

  open step_grade_step(l_item_type,l_item_key);
  fetch step_grade_step into dummy;

  if(lb_grd_ldr_exists_flag and step_grade_step%notfound) then
--     and ( lb_special_ceiling_step_id_chg or lb_grade_changed) ) then

   -- check whether grade ladder won't allow salary update
   open lc_sal_updateable_grade_ladder(p_grade_ladder_id =>
           l_assignment_rec.grade_ladder_pgm_id,
           p_effective_date => l_effective_date
           );
   fetch lc_sal_updateable_grade_ladder into lc_temp_grade_ladder_id, lc_temp_upd_sal_cd;

   -- if there is any salary change , then only it should create
   -- PayRate GSP Txn
   if ((lc_sal_updateable_grade_ladder%FOUND) and
        ( (ltt_salary_data(1).salary_change_amount < 0)
        or  (ltt_salary_data(1).salary_change_amount > 0))) THEN
     lv_gsp_review_proc_call := 'HrPayRate';
     lv_gsp_flow_mode := p_flow_mode ;
     ln_gsp_activity_id := -1;

     -- increment the process order for displaying pay rate page
     -- in review page
     hr_transaction_api.Set_Process_Order_String(p_item_type => l_item_type
                      ,p_item_key  => l_item_key
                      ,p_actid => ln_gsp_activity_id);

     -- display warning only once, thats next time onwards
     -- ignore salary change warning

     if(p_salary_change_warning <> 'IGNORE') then
       p_salary_change_warning := 'WARNING';
       hr_utility.trace('p_salary_change_warning' || p_salary_change_warning);
     end if;

     p_gsp_salary_effective_date := ltt_salary_data(1).salary_effective_date;

     -- Save the Pay Rate GSP Txn
     if (lc_temp_upd_sal_cd = 'SALARY_BASIS') then
        PER_SSHR_CHANGE_PAY.get_transaction_step(
             p_item_type          =>    l_item_type,
             p_item_key           => l_item_key,
             p_activity_id         => -1,
             p_login_person_id    => p_login_person_id,
             p_api_name           => 'PER_SSHR_CHANGE_PAY.PROCESS_API',
             p_transaction_id      =>    ln_gsp_txn_id,
             p_transaction_step_id   => ln_gsp_step_id,
             p_update_mode           => ln_gsp_update_mode,
             p_effective_date_option   =>    p_effective_date_option);

        hr_pay_rate_gsp_ss.create_pay_txn(
            p_ltt_salary_data =>  ltt_salary_data,
            p_transaction_id    =>  ln_gsp_txn_id,
            p_transaction_step_id   =>  ln_gsp_step_id,
            p_item_type         =>  l_item_type,
            p_item_key          =>  l_item_key,
            p_assignment_id     =>  l_assignment_id,
            p_effective_date    =>  l_effective_date,
            p_pay_basis_id      =>  l_assignment_rec.pay_basis_id,
            p_old_pay_basis_id  =>  l_db_assignment_rec.pay_basis_id,
            p_business_group_id =>  l_assignment_rec.business_group_id
            );
     else
     hr_pay_rate_gsp_ss.save_gsp_txn(
        p_item_type             => l_item_type,
        p_item_key              => l_item_key,
        p_act_id                 => ln_gsp_activity_id,
        p_ltt_salary_data      => ltt_salary_data,
        --p_api_mode             => lv_gsp_api_mode,
        p_review_proc_call     => lv_gsp_review_proc_call,
        --p_save_mode            => p_save_mode,
        p_flow_mode            => lv_gsp_flow_mode,
        p_step_id              => ln_gsp_step_id,
        p_rptg_grp_id        => p_rptg_grp_id,
        p_plan_id    => p_plan_id,
        p_effective_date_option  => p_effective_date_option
       );
     end if;

--    end if;
--    close lc_sal_updateable_grade_ladder;
   else

        -- there is no change in grade or step and no change in salary
        -- then remove the existing PayRate Transaction if any with
        -- activityId = -1

        -- Need to see if an asg txn step id exists or not.
        hr_assignment_common_save_web.get_step
         (p_item_type           => p_item_type
         ,p_item_key            => p_item_key
         ,p_api_name            => 'PER_SSHR_CHANGE_PAY.PROCESS_API'
         ,p_transaction_step_id => ln_gsp_step_id
         ,p_transaction_id      => l_transaction_id);

     if (ln_gsp_step_id is null) then
        hr_assignment_common_save_web.get_step
         (p_item_type           => p_item_type
         ,p_item_key            => p_item_key
         ,p_api_name            => 'HR_PAY_RATE_SS.PROCESS_API'
         ,p_transaction_step_id => ln_gsp_step_id
         ,p_transaction_id      => l_transaction_id);
     end if;

         IF (ln_gsp_step_id IS NOT NULL)
         THEN
           lv_gsp_activity_id := hr_transaction_api.get_varchar2_value
               (p_transaction_step_id => ln_gsp_step_id
              ,p_name                => 'P_REVIEW_ACTID');
           -- for Pay Rate GSP Txn, Review Activity Id  is -1
           if((lv_gsp_activity_id is not null) and (to_number(lv_gsp_activity_id) = -1))
           THEN
            hr_transaction_ss.delete_transaction_step
                (p_transaction_step_id => ln_gsp_step_id
                 ,p_login_person_id => p_login_person_id);
            delete from per_pay_transactions where TRANSACTION_STEP_ID=ln_gsp_step_id;
           end if;
         END IF;
    end if;
    close lc_sal_updateable_grade_ladder;
  end if;
  close step_grade_step;
-- End of GSP
  p_transaction_step_id := l_transaction_step_id;
end if; -- this any element changed if statemenet
else
  -- Bug 1043890 fix
  p_transaction_step_id := null;
  IF l_transaction_step_id IS NOT NULL
  THEN
    hr_transaction_ss.delete_transaction_step
     (p_transaction_step_id => l_transaction_step_id
     ,p_login_person_id => p_login_person_id);
  END IF;
  -- GSP Change
  -- delete the existing PayRate Transaction if any
  -- Need to see if an asg txn step id exists or not.
   hr_assignment_common_save_web.get_step
    (p_item_type           => p_item_type
    ,p_item_key            => p_item_key
    ,p_api_name            => 'PER_SSHR_CHANGE_PAY.PROCESS_API'
    ,p_transaction_step_id => ln_gsp_step_id
    ,p_transaction_id      => l_transaction_id);

if (ln_gsp_step_id is null) then
  hr_assignment_common_save_web.get_step
     (p_item_type           => p_item_type
      ,p_item_key            => p_item_key
      ,p_api_name            => 'HR_PAY_RATE_SS.PROCESS_API'
      ,p_transaction_step_id => ln_gsp_step_id
      ,p_transaction_id      => l_transaction_id);
end if;

  IF (ln_gsp_step_id IS NOT NULL)
   THEN
       lv_gsp_activity_id := hr_transaction_api.get_number_value
               (p_transaction_step_id => ln_gsp_step_id
               ,p_name                => 'P_REVIEW_ACTID');
         if((lv_gsp_activity_id is not null) and (to_number(lv_gsp_activity_id) = -1))
         THEN
            hr_transaction_ss.delete_transaction_step
                (p_transaction_step_id => ln_gsp_step_id
                 ,p_login_person_id => p_login_person_id);
            delete from per_pay_transactions where TRANSACTION_STEP_ID=ln_gsp_step_id;
        end if;
  END IF;
  -- End of GSP change code
end if;
  end if;

-- only for registration
  if(g_registration) then
   -- set it back to false to avoid global variable problems with SS connection pooling
    g_registration := false;
  end if;

-- applicant_hire
  if (g_applicant_hire) then
    g_applicant_hire := false;
  end if;

   if (hr_utility.check_warning) then
         p_page_warning_msg := hr_utility.get_message;
   end if;

EXCEPTION
  when hr_utility.hr_error then
    hr_message.provide_error;
    p_page_error := hr_message.last_message_app;
    --p_page_error_msg := hr_message.last_message_name;
    p_page_error_msg := hr_message.get_message_text;
     -- If its registration then roll back the dummy person
      if(g_registration) then
         rollback;
     -- set it back to false to avoid global variable problems with SS connection pooling
          g_registration:= false;
      end if;
-- applicant_hire
    if (g_applicant_hire) then
       rollback to applicant_hire;
       g_applicant_hire := false;
    end if;
  when others then
      if(g_registration) then
         rollback;
         g_registration:= false;
      end if;
-- applicant_hire
    if (g_applicant_hire) then
       rollback to applicant_hire;
       g_applicant_hire := false;
    end if;
    raise;
hr_utility.set_location('Exiting:'||l_proc, 40);
end process_save;

procedure update_object_version
  (p_transaction_step_id in     number
  ,p_login_person_id in number) is

  cursor csr_new_object_number(p_asg_id in number) is
  select object_version_number
    from per_all_assignments_f
   where assignment_id = p_asg_id
     and assignment_type = 'E'
   order by object_version_number desc;

  l_old_object_number number;
  l_assignment_id number;
  l_new_object_number number;
  l_proc   varchar2(72)  := g_package||'update_object_version';

begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  l_assignment_id :=
      hr_transaction_api.get_number_value
      (p_transaction_step_id =>  p_transaction_step_id
      ,p_name                => 'P_ASSIGNMENT_ID');

    open csr_new_object_number(l_assignment_id);
    fetch csr_new_object_number into l_new_object_number;
    close csr_new_object_number;

  l_old_object_number :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_OBJECT_VERSION_NUMBER');

  if l_old_object_number <> l_new_object_number then
    hr_utility.set_location('if l_old_object_number <> l_new_object_number then:'||l_proc,10);
    hr_transaction_api.set_number_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_person_id           => p_login_person_id
    ,p_name                => 'P_OBJECT_VERSION_NUMBER'
    ,p_value               => l_new_object_number);
  end if;

hr_utility.set_location('Exiting:'||l_proc, 15);
end update_object_version;
--
--This procedure is to recover all of the assignment data from the transaction
-- tables and save the data into database.
procedure process_api
(p_validate                 in     boolean default false
,p_transaction_step_id      in     number
,p_effective_date           in     varchar2 default null
) is

l_assignment_rec             per_all_assignments_f%rowtype;
l_effective_date             date;
l_datetrack_update_mode      varchar2(30);
l_j_changed	varchar2(2)	:= 'N';
--
l_special_ceiling_step_id    per_all_assignments_f.special_ceiling_step_id%TYPE;
l_effective_start_date       date;
l_effective_end_date         date;
l_people_group_id            per_all_assignments_f.people_group_id%TYPE;
l_group_name                 VARCHAR2(2000);
l_org_now_no_manager_warning boolean;
l_other_manager_warning      boolean;
l_spp_delete_warning         boolean;
l_entries_changed_warning    VARCHAR2(30);
l_tax_district_changed_warning boolean;
l_soft_coding_keyflex_id     per_all_assignments_f.soft_coding_keyflex_id%TYPE;
l_comment_id                 per_all_assignments_f.comment_id%TYPE;
l_concatenated_segments      VARCHAR2(2000);
l_element_changed            VARCHAR2(1) default 'W';

l_page_error               varchar2(2000);
l_page_error_msg           varchar2(2000);
l_page_warning             varchar2(2000);
l_page_warning_msg         varchar2(2000);
l_organization_error       varchar2(2000);
l_organization_error_msg   varchar2(2000);
l_job_error                varchar2(2000);
l_job_error_msg            varchar2(2000);
l_position_error           varchar2(2000);
l_position_error_msg       varchar2(2000);
l_grade_error              varchar2(2000);
l_grade_error_msg          varchar2(2000);
l_supervisor_error         varchar2(2000);
l_supervisor_error_msg     varchar2(2000);
l_location_error           varchar2(2000);
l_location_error_msg       varchar2(2000);

-- variables and cursors for applicant_hire
l_appl_assignment_type per_all_assignments_f.assignment_type%type;
l_new_hire_appl_hire       varchar2(10);
l_login_person_id          number;

-- GSP
  ltt_salary_data  sshr_sal_prop_tab_typ;
  lv_gsp_post_process_warning  varchar2(2000);
  l_proc   varchar2(72)  := g_package||'process_api';
-- End of GSP

-- cursor to get the applicant object_version_number from
-- per_all_assignments_f
cursor asg_applicant_rec(p_appl_assign_id in number,
                         p_appl_effective_date in date) is
select object_version_number,
       assignment_type,
       assignment_status_type_id
from per_all_assignments_f
where assignment_id = p_appl_assign_id
and p_appl_effective_date between effective_start_date
and effective_end_date;

CURSOR cur_txnStep (c_txnStepId NUMBER ) IS
SELECT item_type,item_key
FROM   hr_api_transaction_steps
WHERE  transaction_step_id = c_txnStepId;

l_item_type varchar2(50);
l_item_key varchar2(50);
l_rehire_flow varchar2(10) default null;

cursor csr_per_step_id is
select transaction_step_id from hr_api_transaction_steps
  where item_type=l_item_type and item_key=l_item_key
  and api_name='HR_PROCESS_PERSON_SS.PROCESS_API';
l_per_step_id	number;
l_asgn_change_mode	varchar2(2);
l_person_type_id	number;

cursor per_applicant_rec(p_appl_person_id in number,
                         	                p_appl_effective_date in date) is
select object_version_number
from per_all_people_f
where person_id = p_appl_person_id
and p_appl_effective_date between effective_start_date
and effective_end_date;

l_per_object_version_number	number;

begin
--
-- recover all of the assignment values
--
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  if (p_effective_date is not null) then
    hr_utility.set_location('  if (p_effective_date is not null) then:'||l_proc,10);
    l_effective_date:= to_date(p_effective_date,g_date_format);
  else
    l_effective_date:= to_date(
      hr_transaction_ss.get_wf_effective_date
        (p_transaction_step_id => p_transaction_step_id),g_date_format);
  end if;
--
  l_datetrack_update_mode:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DATETRACK_UPDATE_MODE');

  l_j_changed:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_J_CHANGED');

    OPEN  cur_txnStep (p_transaction_step_id);
    FETCH cur_txnStep INTO l_item_type,l_item_key;
    CLOSE cur_txnStep;

    if l_item_type is not null and l_item_key is not null then
  	l_rehire_flow := wf_engine.GetItemAttrText(l_item_type,l_item_key,'HR_FLOW_IDENTIFIER',true);
    end if;

    if nvl(l_rehire_flow,'N') = 'EX_EMP' then
	l_datetrack_update_mode :=  'CORRECTION';
    end if;

open csr_per_step_id;
fetch csr_per_step_id into l_per_step_id;
close csr_per_step_id;

l_asgn_change_mode :=     hr_transaction_api.get_varchar2_value
    	                   (p_transaction_step_id =>  l_per_step_id
	                   ,p_name                => 'P_ASGN_CHANGE_MODE');

l_person_type_id :=     hr_transaction_api.get_number_value
    	          (p_transaction_step_id =>  l_per_step_id
	          ,p_name                => 'P_PERSON_TYPE_ID');
--
  get_asg_from_tt
    (p_transaction_step_id => p_transaction_step_id
    ,p_assignment_rec      => l_assignment_rec);
--
   open per_applicant_rec(l_assignment_rec.person_id, l_effective_date);
   fetch per_applicant_rec into l_per_object_version_number;
   close	per_applicant_rec;

  l_special_ceiling_step_id:=l_assignment_rec.special_ceiling_step_id;

-- start registration
-- If its a new user registration flow then the assignmentId which is coming
-- from transaction table will not be valid because the person has just been
-- created by the process_api of the hr_process_person_ss.process_api.
-- We can get that person Id and assignment id by making a call
-- to the global parameters but we need to branch out the code.
-- We also need the latest Object version Number not the one on transaction tbl

-- adding the session id check to avoid connection pooling problems.
  if (( hr_process_person_ss.g_assignment_id is not null) and
                (hr_process_person_ss.g_session_id= ICX_SEC.G_SESSION_ID))
  then
    hr_utility.set_location('session id is ICX_SEC.G_SESSION_ID:'||l_proc,15);
    l_assignment_rec.person_id := hr_process_person_ss.g_person_id;
    l_assignment_rec.assignment_id := hr_process_person_ss.g_assignment_id;
    l_assignment_rec.object_version_number:=hr_process_person_ss.g_asg_object_version_number;
    -- Hard code ovn to 1 for the new user registration process
    --l_assignment_rec.object_version_number:=1;
    l_new_hire_appl_hire := 'Y';
 end if;

-- end registration
--

   -- applicant_hire
   -- check if we are updating applicant, if yes we need to get the
   -- latest object version
   -- number of the applicant who has became employee in BD page
   if (hr_process_person_ss.g_is_applicant  and
      (hr_process_person_ss.g_session_id= ICX_SEC.G_SESSION_ID)) then
      hr_utility.set_location('Applicaant  ICX_SEC.G_SESSION_ID:'||l_proc,20);
      open asg_applicant_rec(l_assignment_rec.assignment_id, l_effective_date);
      fetch asg_applicant_rec into l_assignment_rec.object_version_number
                               ,l_appl_assignment_type
                               ,l_assignment_rec.assignment_status_type_id;
      close asg_applicant_rec;
      l_new_hire_appl_hire := 'Y';
   end if;
  -- end registration

  if l_new_hire_appl_hire = 'Y' then
    hr_utility.set_location('if l_new_hire_appl_hire = Y then:'||l_proc,25);
    l_login_person_id:=
      hr_transaction_api.get_number_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_LOGIN_PERSON_ID');
  end if;

  -- GSP support code
    -- initializing local salary data table type to pass as a parameter
    ltt_salary_data := sshr_sal_prop_tab_typ(sshr_sal_prop_obj_typ(
                null,-- pay_proposal_id       NUMBER,
                null,-- assignment_id         NUMBER,
                null,--business_group_id     NUMBER,
                null,--effective_date        DATE,
                null,--comments              VARCHAR2(2000),
                null,--next_sal_review_date  DATE,
                null,--salary_change_amount  NUMBER ,
                null,--salary_change_percent NUMBER ,
                null,--annual_change         NUMBER ,
                null,--proposed_salary       NUMBER ,
                null,--proposed_percent      NUMBER ,
                null,--proposal_reason       VARCHAR2(30),
                null,--ranking               NUMBER,
                null,--current_salary        NUMBER,
                null,--performance_review_id NUMBER,
                null,--multiple_components   VARCHAR2(1),
                null,--element_entry_id      NUMBER ,
                null,--selection_mode        VARCHAR2(1),
                null,--ovn                   NUMBER,
                null,--currency              VARCHAR2(15),
                null,--pay_basis_name        VARCHAR2(80),
                null,--annual_equivalent     NUMBER ,
                null,--total_percent        NUMBER ,
                null,--quartile              NUMBER ,
                null,--comparatio            NUMBER ,
                null,--lv_selection_mode     VARCHAR2(1),
                null,--attribute_category           VARCHAR2(150),
                null,--attribute1            VARCHAR2(150),
                null,--attribute2            VARCHAR2(150),
                null,--attribute3            VARCHAR2(150),
                null,--attribute4            VARCHAR2(150),
                null,--attribute5            VARCHAR2(150),
                null,--attribute6            VARCHAR2(150),
                null,--attribute7            VARCHAR2(150),
                null,--attribute8            VARCHAR2(150),
                null,--attribute9            VARCHAR2(150),
                null,--attribute10           VARCHAR2(150),
                null,--attribute11           VARCHAR2(150),
                null,--attribute12           VARCHAR2(150),
                null,--attribute13           VARCHAR2(150),
                null,--attribute14           VARCHAR2(150),
                null,--attribute15           VARCHAR2(150),
                null,--attribute16           VARCHAR2(150),
                null,--attribute17           VARCHAR2(150),
                null,--attribute18           VARCHAR2(150),
                null,--attribute19           VARCHAR2(150),
                null,--attribute20           VARCHAR2(150),
                null, --no_of_components       NUMBER,
                -- 04/12/02 Salary Basis Enhancement Begins
                null,  -- salary_basis_change_type varchar2(30)
                null,  -- default_date           date
                null,  -- default_bg_id          number
                null,  -- default_currency       VARCHAR2(15)
                null,  -- default_format_string  VARCHAR2(40)
                null,  -- default_salary_basis_name  varchar2(30)
                null,  -- default_pay_basis_name     varchar2(80)
                null,  -- default_pay_basis      varchar2(30)
                null,  -- default_pay_annual_factor  number
                null,  -- default_grade          VARCHAR2(240)
                null,  -- default_grade_annual_factor number
                null,  -- default_minimum_salary      number
                null,  -- default_maximum_salary      number
                null,  -- default_midpoint_salary     number
                null,  -- default_prev_salary         number
                null,  -- default_last_change_date    date
                null,  -- default_element_entry_id    number
                null,  -- default_basis_changed       number
                null,  -- default_uom                 VARCHAR2(30)
                null,  -- default_grade_uom           VARCHAR2(30)
                null,  -- default_change_amount       number
                null,  -- default_change_percent      number
                null,  -- default_quartile            number
                null,  -- default_comparatio          number
                null,  -- default_last_pay_change     varchar2(200)
                null,  -- default_flsa_status         varchar2(80)
                null,  -- default_currency_symbol     varchar2(4)
                null,   -- default_precision           number
                -- 04/12/02 Salary Basis Enhancement Ends
                -- GSP
                null,    -- salary_effective_date    date
                null,    -- gsp_dummy_txn            varchar2(30)
                -- End of GSP
                null,
                null,
                null,
                null,
                null
                ));

  --END of GSP
if (l_asgn_change_mode is null OR l_asgn_change_mode = 'Y' OR
       l_asgn_change_mode = 'N') then
  update_assignment(
    p_validate                 =>     p_validate
   ,p_login_person_id          =>     l_login_person_id
   ,p_new_hire_appl_hire       =>     l_new_hire_appl_hire
   ,p_assignment_id            =>     l_assignment_rec.assignment_id
   ,p_object_version_number    =>     l_assignment_rec.object_version_number
   ,p_effective_date           =>     l_effective_date
   ,p_datetrack_update_mode    =>     l_datetrack_update_mode
   ,p_organization_id          =>     l_assignment_rec.organization_id
   ,p_position_id              =>     l_assignment_rec.position_id
   ,p_job_id                   =>     l_assignment_rec.job_id
   ,p_grade_id                 =>     l_assignment_rec.grade_id
   ,p_location_id              =>     l_assignment_rec.location_id
   ,p_employment_category      =>     l_assignment_rec.employment_category
   ,p_supervisor_id            =>     l_assignment_rec.supervisor_id
   ,p_manager_flag             =>     l_assignment_rec.manager_flag
   ,p_normal_hours             =>     l_assignment_rec.normal_hours
   ,p_frequency                =>     l_assignment_rec.frequency
   ,p_time_normal_finish       =>     l_assignment_rec.time_normal_finish
   ,p_time_normal_start        =>     l_assignment_rec.time_normal_start
   ,p_bargaining_unit_code     =>     l_assignment_rec.bargaining_unit_code
   ,p_labour_union_member_flag =>     l_assignment_rec.labour_union_member_flag
   ,p_assignment_status_type_id=>     l_assignment_rec.assignment_status_type_id
   ,p_change_reason            =>     l_assignment_rec.change_reason
   ,p_ass_attribute_category   =>     l_assignment_rec.ass_attribute_category
   ,p_ass_attribute1           =>     l_assignment_rec.ass_attribute1
   ,p_ass_attribute2           =>     l_assignment_rec.ass_attribute2
   ,p_ass_attribute3           =>     l_assignment_rec.ass_attribute3
   ,p_ass_attribute4           =>     l_assignment_rec.ass_attribute4
   ,p_ass_attribute5           =>     l_assignment_rec.ass_attribute5
   ,p_ass_attribute6           =>     l_assignment_rec.ass_attribute6
   ,p_ass_attribute7           =>     l_assignment_rec.ass_attribute7
   ,p_ass_attribute8           =>     l_assignment_rec.ass_attribute8
   ,p_ass_attribute9           =>     l_assignment_rec.ass_attribute9
   ,p_ass_attribute10          =>     l_assignment_rec.ass_attribute10
   ,p_ass_attribute11          =>     l_assignment_rec.ass_attribute11
   ,p_ass_attribute12          =>     l_assignment_rec.ass_attribute12
   ,p_ass_attribute13          =>     l_assignment_rec.ass_attribute13
   ,p_ass_attribute14          =>     l_assignment_rec.ass_attribute14
   ,p_ass_attribute15          =>     l_assignment_rec.ass_attribute15
   ,p_ass_attribute16          =>     l_assignment_rec.ass_attribute16
   ,p_ass_attribute17          =>     l_assignment_rec.ass_attribute17
   ,p_ass_attribute18          =>     l_assignment_rec.ass_attribute18
   ,p_ass_attribute19          =>     l_assignment_rec.ass_attribute19
   ,p_ass_attribute20          =>     l_assignment_rec.ass_attribute20
   ,p_ass_attribute21          =>     l_assignment_rec.ass_attribute21
   ,p_ass_attribute22          =>     l_assignment_rec.ass_attribute22
   ,p_ass_attribute23          =>     l_assignment_rec.ass_attribute23
   ,p_ass_attribute24          =>     l_assignment_rec.ass_attribute24
   ,p_ass_attribute25          =>     l_assignment_rec.ass_attribute25
   ,p_ass_attribute26          =>     l_assignment_rec.ass_attribute26
   ,p_ass_attribute27          =>     l_assignment_rec.ass_attribute27
   ,p_ass_attribute28          =>     l_assignment_rec.ass_attribute28
   ,p_ass_attribute29          =>     l_assignment_rec.ass_attribute29
   ,p_ass_attribute30          =>     l_assignment_rec.ass_attribute30
   ,p_soft_coding_keyflex_id   =>     l_assignment_rec.soft_coding_keyflex_id
   ,p_people_group_id          =>     l_assignment_rec.people_group_id
   ,p_payroll_id               =>     l_assignment_rec.payroll_id
   ,p_pay_basis_id             =>     l_assignment_rec.pay_basis_id
   ,p_sal_review_period        =>     l_assignment_rec.sal_review_period
  ,p_sal_review_period_frequency => l_assignment_rec.sal_review_period_frequency
   ,p_date_probation_end       =>     l_assignment_rec.date_probation_end
   ,p_probation_period         =>     l_assignment_rec.probation_period
   ,p_probation_unit           =>     l_assignment_rec.probation_unit
   ,p_notice_period            =>     l_assignment_rec.notice_period
   ,p_notice_period_uom        =>     l_assignment_rec.notice_period_uom
   ,p_employee_category        =>     l_assignment_rec.employee_category
   ,p_work_at_home             =>     l_assignment_rec.work_at_home
   ,p_job_post_source_name     =>     l_assignment_rec.job_post_source_name
   ,p_perf_review_period       =>     l_assignment_rec.perf_review_period
   ,p_perf_review_period_frequency =>
                  l_assignment_rec.perf_review_period_frequency
   ,p_internal_address_line    =>     l_assignment_rec.internal_address_line
   ,p_contract_id              =>     l_assignment_rec.contract_id
   ,p_establishment_id         =>     l_assignment_rec.establishment_id
   ,p_cagr_grade_def_id        =>     l_assignment_rec.cagr_grade_def_id
   ,p_collective_agreement_id  =>     l_assignment_rec.collective_agreement_id
   ,p_cagr_id_flex_num         =>     l_assignment_rec.cagr_id_flex_num
   ,p_business_group_id        =>     l_assignment_rec.business_group_id
   ,p_grade_ladder_pgm_id      =>     l_assignment_rec.grade_ladder_pgm_id
   ,p_assignment_type          =>     l_assignment_rec.assignment_type
   --,p_supervisor_assignment_id =>     l_assignment_rec.supervisor_assignment_id
   ,p_vacancy_id               =>     l_assignment_rec.vacancy_id
   ,p_special_ceiling_step_id  =>     l_special_ceiling_step_id
   ,p_primary_flag             =>     l_assignment_rec.primary_flag
   ,p_person_id                =>     l_assignment_rec.person_id
   ,p_default_code_comb_id     =>     l_assignment_rec.default_code_comb_id
   ,p_project_title            =>     l_assignment_rec.project_title
   ,p_set_of_books_id          =>     l_assignment_rec.set_of_books_id
   ,p_source_type              =>     l_assignment_rec.source_type
   ,p_title                    =>     l_assignment_rec.title
   ,p_vendor_assignment_number =>     l_assignment_rec.vendor_assignment_number
   ,p_vendor_employee_number   =>     l_assignment_rec.vendor_employee_number
   ,p_vendor_id                =>     l_assignment_rec.vendor_id
   ,p_effective_start_date     =>     l_effective_start_date
   ,p_effective_end_date       =>     l_effective_end_date
   ,p_element_warning          =>     TRUE
   ,p_element_changed          =>     l_element_changed
   ,p_page_error => l_page_error
   ,p_page_error_msg => l_page_error_msg
   ,p_page_warning => l_page_warning
   ,p_page_warning_msg => l_page_warning_msg
   ,p_organization_error => l_organization_error
   ,p_organization_error_msg => l_organization_error_msg
   ,p_job_error => l_job_error
   ,p_job_error_msg => l_job_error_msg
   ,p_position_error => l_position_error
   ,p_position_error_msg => l_position_error_msg
   ,p_grade_error => l_grade_error
   ,p_grade_error_msg => l_grade_error_msg
   ,p_supervisor_error => l_supervisor_error
   ,p_supervisor_error_msg => l_supervisor_error_msg
   ,p_location_error => l_location_error
   ,p_location_error_msg => l_location_error_msg
   -- GSP change
   ,p_ltt_salary_data => ltt_salary_data
   ,p_gsp_post_process_warning => lv_gsp_post_process_warning
  -- End of GSP change
   ,p_po_header_id => l_assignment_rec.po_header_id
   ,p_po_line_id => l_assignment_rec.po_line_id
   ,p_vendor_site_id => l_assignment_rec.vendor_site_id
   ,p_projected_asgn_end => l_assignment_rec.projected_assignment_end
   ,p_j_changed	=>  l_j_changed
);
else
update_apl_assignment(
p_assignment_rec => l_assignment_rec
,p_validate	=>	p_validate
,p_effective_date  =>	l_effective_date
,p_person_id	=>	l_assignment_rec.person_id
,p_appl_assignment_id  =>	l_assignment_rec.assignment_id
,p_person_type_id  =>	l_person_type_id
,p_overwrite_primary  =>	l_asgn_change_mode
,p_ovn	=> l_per_object_version_number);
end if;

 hr_transaction_swi.set_person_context(l_assignment_rec.person_id
                                      ,l_assignment_rec.assignment_id
                                      ,l_effective_date);


--bug 5032032 fix begin
if l_new_hire_appl_hire = 'Y' then
update_salary_proposal(l_assignment_rec.assignment_id,l_effective_date);
end if;
--bug 5032032 fix end

end process_api;

procedure update_apl_assignment
(p_validate	in boolean default false,
p_assignment_rec in out nocopy per_all_assignments_f%rowtype,
p_effective_date  in date,
p_person_id	in number,
p_appl_assignment_id  in number,
p_person_type_id  in number,
p_overwrite_primary  in varchar2,
p_ovn  in number
) is
l_per_effective_start_date	date;
l_per_effective_end_date	date;
l_unaccepted_asg_del_warning	boolean;
l_assign_payroll_warning	boolean;
l_oversubscribed_vacancy_id	number;
l_ovn  number	:=  p_ovn;
l_assignment_rec	per_all_assignments_f%rowtype := p_assignment_rec;

cursor csr_prim_asg is
select assignment_id from per_all_assignments_f where
person_id = p_person_id and primary_flag='Y' and assignment_type='E' and
p_effective_date between effective_start_date and effective_end_date;

l_prim_asgid	number;

begin
   hr_employee_applicant_api.hire_employee_applicant
      (p_validate          =>	p_validate,
       p_hire_date         =>       p_effective_date,
       p_asg_rec	=> l_assignment_rec,
       p_person_id         => 	p_person_id,
       p_primary_assignment_id     => p_appl_assignment_id,
       p_person_type_id    =>	p_person_type_id,
       p_overwrite_primary     =>   p_overwrite_primary,
       p_per_object_version_number	=> l_ovn,
       p_per_effective_start_date   =>  l_per_effective_start_date,
       p_per_effective_end_date     =>  l_per_effective_end_date,
       p_unaccepted_asg_del_warning =>  l_unaccepted_asg_del_warning,
       p_assign_payroll_warning     =>  l_assign_payroll_warning,
       p_oversubscribed_vacancy_id  =>  l_oversubscribed_vacancy_id,
       p_called_from => 'SSHR'
     );

        p_assignment_rec	:=	l_assignment_rec;
end;

--This is the procedure to update the assignment data, including
--   the People Group and Soft Coded Key Flexfields
--
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
,p_bargaining_unit_code     in     varchar2 default null
,p_labour_union_member_flag in     varchar2 default null
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
-- GSP change
,p_grade_ladder_pgm_id      in    per_all_assignments_f.grade_ladder_pgm_id%TYPE
-- GSP change
,p_assignment_type          in     per_all_assignments_f.assignment_type%TYPE
--,p_supervisor_assignment_id in per_all_assignments_f.supervisor_assignment_id%TYPE
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
--GSP populates salary information from Grade Ladder assignment
,p_ltt_salary_data    IN OUT NOCOPY  sshr_sal_prop_tab_typ
,p_gsp_post_process_warning out nocopy varchar2
-- End of GSP
,p_po_header_id                in number default null
,p_po_line_id                in number default null
,p_vendor_site_id                in number default null
,p_projected_asgn_end        in date default null
,p_j_changed	in varchar2   default 'Y'
) is
--

l_effective_date             date;
l_object_version_number      per_all_assignments_f.object_version_number%TYPE;
l_effective_start_date       date;
l_effective_end_date         date;
-- Fix for 3633612 to pass new people group flx ccid to hr_assignment_api, so that these
-- hr_assignment_api's  won't validate the old segment values.
l_people_group_id            per_all_assignments_f.people_group_id%TYPE
                              := p_people_group_id;
l_group_name                 VARCHAR2(2000);
l_org_now_no_manager_warning boolean;
l_other_manager_warning      boolean;
l_spp_delete_warning         boolean;
l_entries_changed_warning    VARCHAR2(30);
l_tax_district_changed_warning boolean;
l_soft_coding_keyflex_id     per_all_assignments_f.soft_coding_keyflex_id%TYPE;
l_cagr_grade_def_id          per_all_assignments_f.cagr_grade_def_id%TYPE;
l_cagr_concatenated_segments varchar2(2000);
l_comment_id                 per_all_assignments_f.comment_id%TYPE;
l_concatenated_segments      VARCHAR2(2000);
l_hourly_salaried_warning    boolean default false;
l_validation_start_date      per_assignments_f.effective_start_date%TYPE;
l_validation_end_date        per_assignments_f.effective_end_date%TYPE;
l_validate                   boolean;
l_inv_pos_grade_warning      boolean;
l_org_error                  boolean default false;
l_job_error                  boolean default false;
l_pos_error                  boolean default false;
l_old_wc_code                number;
l_old_job_id                 number;
l_new_wc_code                number;
l_assignment_status_type     varchar2(30);

-- for disabling the descriptive flex field
l_add_struct_d hr_dflex_utility.l_ignore_dfcode_varray :=
                           hr_dflex_utility.l_ignore_dfcode_varray();
-- for disabling the key flex field
l_add_struct_k hr_kflex_utility.l_ignore_kfcode_varray :=
                           hr_kflex_utility.l_ignore_kfcode_varray();
--
-- GSP changes
 lb_grd_ldr_exists_flag  boolean default false;
-- End of GSP changes
l_proc   varchar2(72)  := g_package||'update_assignment';
--
cursor current_job_id is
select job_id
from per_all_assignments_f
where assignment_id=p_assignment_id
and l_effective_date between effective_start_date and effective_end_date;

--
cursor wc_code(pc_job_id number) is
select jwc.wc_code
from pay_job_wc_code_usages jwc,
hr_locations_all hl
where jwc.job_id = pc_job_id
and hl.location_id = p_location_id
and jwc.state_code = hl.region_2;
--
cursor status_type is
select per_system_status
from per_assignment_status_types
where assignment_status_type_id=p_assignment_status_type_id;
--

  cursor csr_pgp_segments is
  select *
  from pay_people_groups
  where people_group_id = p_people_group_id;

  cursor csr_scl_segments is
  select *
  from hr_soft_coding_keyflex
  where soft_coding_keyflex_id = p_soft_coding_keyflex_id;

  cursor csr_cag_segments is
  select *
  from per_cagr_grades_def
  where cagr_grade_def_id = p_cagr_grade_def_id;

  cursor csr_default_work_schedule(leg_code  in varchar2) is
  select to_char(user_column_id)
  from pay_user_columns puc, hr_organization_information hoi
  WHERE (HOI.org_information1 = to_char(PUC.user_table_id)
       OR HOI.org_information1 is null )
  AND  HOI.org_information_context  = 'Work Schedule'
  AND  HOI.organization_id  = p_organization_id
  AND  (puc.business_group_id is null or
        puc.business_group_id = p_business_group_id)
  AND  (puc.legislation_code is null or
        puc.legislation_code = leg_code)
  and puc.user_column_name = hoi.org_information2;

  /*cursor csr_validate_work_schedule(leg_code  in varchar2,
                                   segment4 in number) is
  select to_char(user_column_id)
  from pay_user_columns puc, hr_organization_information hoi
  WHERE (HOI.org_information1 = to_char(PUC.user_table_id)
       OR HOI.org_information1 is null )
  AND  HOI.org_information_context  = 'Work Schedule'
  AND  HOI.organization_id  = p_organization_id
  AND  (puc.business_group_id is null or
        puc.business_group_id = p_business_group_id)
  AND  (puc.legislation_code is null or
        puc.legislation_code = leg_code)
  and  puc.user_column_id = segment4;*/

  cursor csr_default_gre is
  select scl.segment1
  from hr_soft_coding_keyflex scl,
       per_all_assignments_f asg
  where asg.person_id = p_login_person_id
  and asg.business_group_id = p_business_group_id --the new hire business group
  and asg.primary_flag = 'Y'
  and trunc(sysdate) between asg.effective_start_date
      and asg.effective_end_date
  and asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id;

 -- Fix for Bug # 3116369
   cursor csr_cwk_scl_idsel(leg_code  in varchar2) is
    select rule_mode
    from   pay_legislation_rules    plr
    where  plr.legislation_code  = leg_code
    and    plr.rule_type         = 'CWK_S'
    and    exists
          (select null
           from   fnd_segment_attribute_values fsav
           where  fsav.id_flex_num             = plr.rule_mode
           and    fsav.application_id          = 800
           and    fsav.id_flex_code            = 'SCL'
           and    fsav.segment_attribute_type  = 'ASSIGNMENT'
           and    fsav.attribute_value         = 'Y')
    and    exists
          (select null
           from   pay_legislation_rules        plr2
           where  plr2.legislation_code        = plr.legislation_code
           and    plr2.rule_type               = 'CWK_SDL'
           and    plr2.rule_mode               = 'A') ;


  cursor csr_emp_scl_idsel(leg_code  in varchar2) is
    select rule_mode
       from   pay_legislation_rules
       where  legislation_code = leg_code
       and    rule_type        = 'S'
       and    exists
           (select null
            from   fnd_segment_attribute_values
            where  id_flex_num = rule_mode
            and    application_id = 800
            and    id_flex_code = 'SCL'
            and    segment_attribute_type = 'ASSIGNMENT'
            and    attribute_value = 'Y')
       and    exists
           (select null
            from   pay_legislation_rules
            where  legislation_code  = leg_code
            and    rule_type = 'SDL'
            and    rule_mode = 'A');

cursor check_payroll_scl is
    select asg.assignment_id,
               asg.payroll_id,
               asg.soft_coding_keyflex_id
      from per_all_assignments_f asg
     where asg.person_id                 = p_person_id
       and l_effective_date between asg.effective_start_date
                                       and asg.effective_end_date
       and asg.assignment_type = 'E'
       and assignment_id <> p_assignment_id
       and asg.payroll_id is not null
       and asg.soft_coding_keyflex_id is null
       order by asg.assignment_id;
  --
  l_flex_num               fnd_id_flex_segments.id_flex_num%TYPE;
  l_scl_hide_flag varchar2(1);

  l_people_groups csr_pgp_segments%rowtype;
  l_soft_coding_keyflex csr_scl_segments%rowtype;
  l_cagr_grades_def csr_cag_segments%rowtype;
  l_legislation_code   per_business_groups.legislation_code%TYPE;
  l_new_hire_default  varchar2(10);

  l_old_payroll_id number;
  l_validate_start_date date;
  l_validate_end_date date;
  l_entries_changed varchar2(250);

  l_asg_future_changes_warning	boolean;
  l_pay_proposal_warning	boolean;

begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  l_effective_date :=trunc(p_effective_date);

  l_validate_start_date := p_effective_start_date;
  l_validate_end_date := p_effective_end_date;

  open csr_pgp_segments;
  fetch csr_pgp_segments into l_people_groups;
  close csr_pgp_segments;

  open csr_scl_segments;
  fetch csr_scl_segments into l_soft_coding_keyflex;
  close csr_scl_segments;

  open csr_cag_segments;
  fetch csr_cag_segments into l_cagr_grades_def;
  close csr_cag_segments;
--
-- get the current job_id for wc_validation
--
  open current_job_id;
  fetch current_job_id into l_old_job_id;
  if current_job_id%found then
    close current_job_id;
  else
    close current_job_id;
  end if;

  -- Set default SCL for new hire and applicant hire only
  -- for US legislation.
  -- if p_soft_coding_keyflex_id is null, the GRE region must be turned off
  -- for the new hire flow or the applicant hire flow.
  -- we need to set the GRE and Work Schedule default values. Otherwise,
  -- core hr api will raise error HR_50001_EMP_ASS_NO_GRE.
  -- The default GRE and Work Schedule values are set when the p_login_person_id
  -- is not null (update_assignment is called by the process_save).
  -- The login_person_id is null when update_assignment is called by
  -- process_api. The default values should not be set when called by
  -- process_api because the default values are already in transation table.
  -- if p_soft_coding_keyflex_id is null, then it must be a new hire or
  -- applicant hire.
  l_legislation_code := hr_misc_web.get_legislation_code
                  (p_assignment_id => p_assignment_id,
                   p_effective_date => l_effective_date);
  l_new_hire_default := fnd_profile.value('HR_SSHR_NEW_HIRE_DEFAULTS');

  -- Bug Fix for 3116369
  -- find the scl hide flag logic in order to set the default values for gre and
  -- workschedule segments Bug fix for 3116369
  l_scl_hide_flag := 'N';
  if p_assignment_type = 'C' then
        hr_utility.set_location('if p_assignment_type = C then:'||l_proc,25);
        OPEN csr_cwk_scl_idsel(l_legislation_code);
        FETCH csr_cwk_scl_idsel INTO l_flex_num;
        IF csr_cwk_scl_idsel%NOTFOUND THEN
          l_scl_hide_flag := 'Y';
        END IF;
        CLOSE csr_cwk_scl_idsel;
  else
        OPEN csr_emp_scl_idsel(l_legislation_code);
        FETCH csr_emp_scl_idsel INTO l_flex_num;
        IF csr_emp_scl_idsel%NOTFOUND THEN
          l_scl_hide_flag := 'Y';
        END IF;
        CLOSE csr_emp_scl_idsel;
  end if;

  if (p_login_person_id is not null and
     p_new_hire_appl_hire = 'Y' and
     p_soft_coding_keyflex_id is null and
     (l_new_hire_default is null or l_new_hire_default = 'Y') and
     l_scl_hide_flag = 'N')
  then
    if l_legislation_code = 'US' then
      -- set default GRE
      open csr_default_gre;
      fetch csr_default_gre into l_soft_coding_keyflex.segment1;
      close csr_default_gre;
    end if;
    -- set default work schedule
    open csr_default_work_schedule(l_legislation_code);
    fetch csr_default_work_schedule into l_soft_coding_keyflex.segment4;
    close csr_default_work_schedule;
  end if;

if (p_new_hire_appl_hire = 'Y' and l_legislation_code = 'US') then
   for c in check_payroll_scl loop
      update per_all_assignments_f set soft_coding_keyflex_id = p_soft_coding_keyflex_id
       where assignment_id = c.assignment_id and l_effective_date between
       effective_start_date and effective_end_date;
   end loop;
end if;

  -- validate the work schedule segment4 when not new hire.
  -- this could be invalid if the SCL is truned off in the web page
  -- and organization has been changed.

  /*if p_login_person_id is not null and
     p_new_hire_appl_hire = 'N'and
     l_soft_coding_keyflex.segment4 is not null and
     l_legislation_code = 'US' then
    begin
    open csr_validate_work_schedule
      (l_legislation_code, to_number(l_soft_coding_keyflex.segment4));
    fetch csr_validate_work_schedule into l_soft_coding_keyflex.segment4;
    if csr_validate_work_schedule%notfound then
      --not a valid work_schedule
      -- set default work schedule
      open csr_default_work_schedule(l_legislation_code);
      fetch csr_default_work_schedule into l_soft_coding_keyflex.segment4;
      if csr_default_work_schedule%notfound then
        l_soft_coding_keyflex.segment4 := null;
      end if;
      close csr_default_work_schedule;
    end if;
    close csr_validate_work_schedule;
    exception
      when others then
        null;
    end;
  end if;*/
--
-- since we are calling more than one api, we must issue our own
-- savepoint and manage the rollback ourselves.
--
  savepoint validate_assignment;
--
  l_object_version_number:=p_object_version_number;
  l_validate := p_validate;

if (p_j_changed = 'Y' or p_j_changed is null) then
  if p_assignment_type = 'C' then
    hr_utility.set_location('if p_assignment_type = C then:'||l_proc,30);
    l_add_struct_k.extend(1);
    l_add_struct_k(l_add_struct_k.count) := 'SCL';
    hr_kflex_utility.create_ignore_kf_validation(p_rec => l_add_struct_k);
    --
    -- code for disabling the descriptive flex field
    l_add_struct_d.extend(1);
    l_add_struct_d(l_add_struct_d.count) := 'PER_ASSIGNMENTS';

    hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);

    hr_assignment_api.update_cwk_asg_criteria
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => p_datetrack_update_mode
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => l_object_version_number
      ,p_grade_id                     => p_grade_id
      ,p_position_id                  => p_position_id
      ,p_job_id                       => p_job_id
      ,p_location_id                  => p_location_id
      ,p_organization_id              => p_organization_id
      ,p_pay_basis_id                 => p_pay_basis_id

     -- Fix for Bug #3083706 for updating people grp for CWK
      ,p_segment1                     => l_people_groups.segment1
      ,p_segment2                     => l_people_groups.segment2
      ,p_segment3                     => l_people_groups.segment3
      ,p_segment4                     => l_people_groups.segment4
      ,p_segment5                     => l_people_groups.segment5
      ,p_segment6                     => l_people_groups.segment6
      ,p_segment7                     => l_people_groups.segment7
      ,p_segment8                     => l_people_groups.segment8
      ,p_segment9                     => l_people_groups.segment9
      ,p_segment10                    => l_people_groups.segment10
      ,p_segment11                    => l_people_groups.segment11
      ,p_segment12                    => l_people_groups.segment12
      ,p_segment13                    => l_people_groups.segment13
      ,p_segment14                    => l_people_groups.segment14
      ,p_segment15                    => l_people_groups.segment15
      ,p_segment16                    => l_people_groups.segment16
      ,p_segment17                    => l_people_groups.segment17
      ,p_segment18                    => l_people_groups.segment18
      ,p_segment19                    => l_people_groups.segment19
      ,p_segment20                    => l_people_groups.segment20
      ,p_segment21                    => l_people_groups.segment21
      ,p_segment22                    => l_people_groups.segment22
      ,p_segment23                    => l_people_groups.segment23
      ,p_segment24                    => l_people_groups.segment24
      ,p_segment25                    => l_people_groups.segment25
      ,p_segment26                    => l_people_groups.segment26
      ,p_segment27                    => l_people_groups.segment27
      ,p_segment28                    => l_people_groups.segment28
      ,p_segment29                    => l_people_groups.segment29
      ,p_segment30                    => l_people_groups.segment30
    -- end of the bug Fix for #3083706

      ,p_people_group_name            => l_group_name
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_people_group_id              => l_people_group_id
      ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
      ,p_other_manager_warning        => l_other_manager_warning
      ,p_spp_delete_warning           => l_spp_delete_warning
      ,p_entries_changed_warning      => l_entries_changed_warning
      ,p_tax_district_changed_warning => l_tax_district_changed_warning
      );

    hr_dflex_utility.remove_ignore_df_validation;
    hr_kflex_utility.remove_ignore_kf_validation;
    --

    l_soft_coding_keyflex_id := p_soft_coding_keyflex_id;

    hr_assignment_api.update_cwk_asg
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => 'CORRECTION'
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => l_object_version_number
      -- Fix for updating assignment_category for CWK , fix for Bug #3083776
      ,p_assignment_category          => p_employment_category
      ,p_change_reason                => p_change_reason
      --,p_comments                     => p_comments
      ,p_default_code_comb_id         => p_default_code_comb_id
      ,p_establishment_id             => p_establishment_id
      ,p_frequency                    => p_frequency
      ,p_internal_address_line        => p_internal_address_line
      ,p_labour_union_member_flag     => p_labour_union_member_flag
      ,p_manager_flag                 => p_manager_flag
      ,p_normal_hours                 => p_normal_hours
      ,p_project_title                => p_project_title
      ,p_set_of_books_id              => p_set_of_books_id
      ,p_source_type                  => p_source_type
      ,p_supervisor_id                => p_supervisor_id
      ,p_time_normal_finish           => p_time_normal_finish
      ,p_time_normal_start            => p_time_normal_start
      ,p_title                        => p_title
      ,p_vendor_assignment_number     => p_vendor_assignment_number
      ,p_vendor_employee_number       => p_vendor_employee_number
      ,p_vendor_id                    => p_vendor_id
      ,p_po_header_id                 => p_po_header_id
      ,p_po_line_id                   => p_po_line_id
      ,p_vendor_site_id               => p_vendor_site_id
      ,p_projected_assignment_end     => p_projected_asgn_end
      --,p_assignment_status_type_id    => p_assignment_status_type_id --3262804
      ,p_attribute_category       => p_ass_attribute_category
      ,p_attribute1               => p_ass_attribute1
      ,p_attribute2               => p_ass_attribute2
      ,p_attribute3               => p_ass_attribute3
      ,p_attribute4               => p_ass_attribute4
      ,p_attribute5               => p_ass_attribute5
      ,p_attribute6               => p_ass_attribute6
      ,p_attribute7               => p_ass_attribute7
      ,p_attribute8               => p_ass_attribute8
      ,p_attribute9               => p_ass_attribute9
      ,p_attribute10              => p_ass_attribute10
      ,p_attribute11              => p_ass_attribute11
      ,p_attribute12              => p_ass_attribute12
      ,p_attribute13              => p_ass_attribute13
      ,p_attribute14              => p_ass_attribute14
      ,p_attribute15              => p_ass_attribute15
      ,p_attribute16              => p_ass_attribute16
      ,p_attribute17              => p_ass_attribute17
      ,p_attribute18              => p_ass_attribute18
      ,p_attribute19              => p_ass_attribute19
      ,p_attribute20              => p_ass_attribute20
      ,p_attribute21              => p_ass_attribute21
      ,p_attribute22              => p_ass_attribute22
      ,p_attribute23              => p_ass_attribute23
      ,p_attribute24              => p_ass_attribute24
      ,p_attribute25              => p_ass_attribute25
      ,p_attribute26              => p_ass_attribute26
      ,p_attribute27              => p_ass_attribute27
      ,p_attribute28              => p_ass_attribute28
      ,p_attribute29              => p_ass_attribute29
      ,p_attribute30              => p_ass_attribute30
      ,p_scl_segment1             => l_soft_coding_keyflex.segment1
      ,p_scl_segment2             => l_soft_coding_keyflex.segment2
      ,p_scl_segment3             => l_soft_coding_keyflex.segment3
      ,p_scl_segment4             => l_soft_coding_keyflex.segment4
      ,p_scl_segment5             => l_soft_coding_keyflex.segment5
      ,p_scl_segment6             => l_soft_coding_keyflex.segment6
      ,p_scl_segment7             => l_soft_coding_keyflex.segment7
      ,p_scl_segment8             => l_soft_coding_keyflex.segment8
      ,p_scl_segment9             => l_soft_coding_keyflex.segment9
      ,p_scl_segment10            => l_soft_coding_keyflex.segment10
      ,p_scl_segment11            => l_soft_coding_keyflex.segment11
      ,p_scl_segment12            => l_soft_coding_keyflex.segment12
      ,p_scl_segment13            => l_soft_coding_keyflex.segment13
      ,p_scl_segment14            => l_soft_coding_keyflex.segment14
      ,p_scl_segment15            => l_soft_coding_keyflex.segment15
      ,p_scl_segment16            => l_soft_coding_keyflex.segment16
      ,p_scl_segment17            => l_soft_coding_keyflex.segment17
      ,p_scl_segment18            => l_soft_coding_keyflex.segment18
      ,p_scl_segment19            => l_soft_coding_keyflex.segment19
      ,p_scl_segment20            => l_soft_coding_keyflex.segment20
      ,p_scl_segment21            => l_soft_coding_keyflex.segment21
      ,p_scl_segment22            => l_soft_coding_keyflex.segment22
      ,p_scl_segment23            => l_soft_coding_keyflex.segment23
      ,p_scl_segment24            => l_soft_coding_keyflex.segment24
      ,p_scl_segment25            => l_soft_coding_keyflex.segment25
      ,p_scl_segment26            => l_soft_coding_keyflex.segment26
      ,p_scl_segment27            => l_soft_coding_keyflex.segment27
      ,p_scl_segment28            => l_soft_coding_keyflex.segment28
      ,p_scl_segment29            => l_soft_coding_keyflex.segment29
      ,p_scl_segment30            => l_soft_coding_keyflex.segment30
      ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_comment_id                   => l_comment_id
      ,p_no_managers_warning          => l_org_now_no_manager_warning
      ,p_other_manager_warning        => l_other_manager_warning
      ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_hourly_salaried_warning      => l_hourly_salaried_warning
      );
      p_soft_coding_keyflex_id := l_soft_coding_keyflex_id;
  else
-- perform field level validation first to obtain as much error information
-- as possible
--
-- call the assignment criteria api
-- this enters all of the data which have element link dependencies
--
  -- Added for turn off key flex field validation
  l_add_struct_k.extend(1);
  l_add_struct_k(l_add_struct_k.count) := 'SCL';
  l_add_struct_k.extend(1);
  l_add_struct_k(l_add_struct_k.count) := 'CAGR';

  hr_kflex_utility.create_ignore_kf_validation(p_rec => l_add_struct_k);
  --
  -- code for disabling the descriptive flex field
  l_add_struct_d.extend(1);
  l_add_struct_d(l_add_struct_d.count) := 'PER_ASSIGNMENTS';

  hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);
    --
    hr_assignment_api.update_emp_asg_criteria
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => p_datetrack_update_mode
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => l_object_version_number
      ,p_grade_id                     => p_grade_id
      ,p_position_id                  => p_position_id
      ,p_job_id                       => p_job_id
      ,p_location_id                  => p_location_id
      ,p_special_ceiling_step_id      => p_special_ceiling_step_id
      ,p_organization_id              => p_organization_id
      ,p_employment_category          => p_employment_category
      --,p_payroll_id                   => p_payroll_id
      ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
      --,p_supervisor_assignment_id     => p_supervisor_assignment_id
      ,p_pay_basis_id                 => p_pay_basis_id
      ,p_segment1                     => l_people_groups.segment1
      ,p_segment2                     => l_people_groups.segment2
      ,p_segment3                     => l_people_groups.segment3
      ,p_segment4                     => l_people_groups.segment4
      ,p_segment5                     => l_people_groups.segment5
      ,p_segment6                     => l_people_groups.segment6
      ,p_segment7                     => l_people_groups.segment7
      ,p_segment8                     => l_people_groups.segment8
      ,p_segment9                     => l_people_groups.segment9
      ,p_segment10                    => l_people_groups.segment10
      ,p_segment11                    => l_people_groups.segment11
      ,p_segment12                    => l_people_groups.segment12
      ,p_segment13                    => l_people_groups.segment13
      ,p_segment14                    => l_people_groups.segment14
      ,p_segment15                    => l_people_groups.segment15
      ,p_segment16                    => l_people_groups.segment16
      ,p_segment17                    => l_people_groups.segment17
      ,p_segment18                    => l_people_groups.segment18
      ,p_segment19                    => l_people_groups.segment19
      ,p_segment20                    => l_people_groups.segment20
      ,p_segment21                    => l_people_groups.segment21
      ,p_segment22                    => l_people_groups.segment22
      ,p_segment23                    => l_people_groups.segment23
      ,p_segment24                    => l_people_groups.segment24
      ,p_segment25                    => l_people_groups.segment25
      ,p_segment26                    => l_people_groups.segment26
      ,p_segment27                    => l_people_groups.segment27
      ,p_segment28                    => l_people_groups.segment28
      ,p_segment29                    => l_people_groups.segment29
      ,p_segment30                    => l_people_groups.segment30
      ,p_contract_id                  => p_contract_id
      ,p_establishment_id             => p_establishment_id
      ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_people_group_id              => l_people_group_id
      ,p_group_name                   => l_group_name
      ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
      ,p_other_manager_warning        => l_other_manager_warning
      ,p_spp_delete_warning           => l_spp_delete_warning
      ,p_entries_changed_warning      => l_entries_changed_warning
      ,p_tax_district_changed_warning => l_tax_district_changed_warning
      ,p_gsp_post_process_warning     => p_gsp_post_process_warning
      );
--
   -- bug 5547271
   if (hr_process_person_ss.g_is_applicant) then
   begin
    select PAYROLL_ID into l_old_payroll_id
    from per_all_assignments_f
    where assignment_id = p_assignment_id and p_effective_date between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE;
   end;
    hrentmnt.maintain_entries_asg
    (p_assignment_id                => p_assignment_id
    ,p_old_payroll_id               => l_old_payroll_id
    ,p_new_payroll_id               => p_payroll_id
    ,p_business_group_id            => p_business_group_id
    ,p_operation                    => 'HIRE_APPL'
    ,p_actual_term_date             => null
    ,p_last_standard_date           => null
    ,p_final_process_date           => null
    ,p_dt_mode                      => p_datetrack_update_mode ---check??
    ,p_validation_start_date        => l_validate_start_date
    ,p_validation_end_date          => l_validate_end_date
    ,p_entries_changed              => l_entries_changed
    ,p_old_people_group_id          => -1
    ,p_new_people_group_id          => p_people_group_id
    );
    if l_entries_changed_warning <> 'S' then
    l_entries_changed_warning := nvl(l_entries_changed, 'N');
    end if;

    end if;

    -- bug 5547271

-- look to see if the elements have changed
--
  if (l_entries_changed_warning<>'N') then
  --
  -- if the elements have changed, look to see if we want a
  -- warning or an error
  --
    if p_element_warning then
    --
    -- we want a warning, so look to see if the warning has already been
    -- raised and this is the second time through the process
    --
      if p_element_changed is null then
      --
      -- since p_element_changed is null, the warning has not already been
      -- raised, so raise it
      --
        hr_utility.set_location('if p_element_changed is null then:'||l_proc,35);
        p_element_changed:='W';
        --fnd_message.set_name('PER', 'HR_ELEMENT_CHANGED_WARNING_WEB');
        --hr_utility.raise_error;
        -- Should add page level warning
        /*hr_errors_api.addErrorToTable
        (p_errorfield   => null
        ,p_errorcode    => to_char(SQLCODE)
        ,p_errormsg     => hr_util_misc_web.return_msg_text
                           (p_message_name =>'HR_ELEMENT_CHANGED_WARNING_WEB'
                           ,p_application_id => 'PER')
        ,p_warningflag  => true
        );*/
      else
        --warning already raised. will not raise it again.
        p_element_changed:='X';
      end if;
    --
    else
      --
      -- we want a error, so raise one.
      --
      -- Should add page level warning
      fnd_message.set_name('PER', 'HR_ELEMENT_CHANGED_WEB');
      hr_utility.raise_error;
      /*hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => to_char(SQLCODE)
      ,p_errormsg   => hr_util_misc_web.return_msg_text
                       (p_message_name   => 'HR_ELEMENT_CHANGED_WEB'
                       ,p_application_id => 'PER')
      ,p_email_id   => p_email_id
      ,p_email_msg  => hr_util_misc_web.return_msg_text
                       (p_message_name => 'HR_ELEMENT_CHANGE_EMAILTXT_WEB'
                       ,p_application_id => 'PER')
      );*/
      l_validate:=TRUE;
    end if;
  end if;
--  if hr_misc_web.get_legislation_code(p_assignment_id=>p_assignment_id) = 'US'
--  then
--
-- look to see if the wc code has changed
--
-- get the WC code for the new job
--
-- Bug 2610926: do not check wc error.
--  open wc_code(p_job_id);
--  fetch wc_code into l_new_wc_code;
--  if wc_code%found then
--    close wc_code;
--  else
    -- if there is no appropriate WC code for this job set the code to -1
--    close wc_code;
--    l_new_wc_code:=-1;
--  end if;
--
-- get the WC code for the new job
--
--  open wc_code(l_old_job_id);
--  fetch wc_code into l_old_wc_code;
--  if wc_code%found then
--    close wc_code;
--  else
    -- if there is no appropriate WC code for this job set the code to -1
--    close wc_code;
--    l_old_wc_code:=-1;
--  end if;
--
-- if the WC code has changed then always raise an error.
-- this will not happen in non-US legislations as both codes will have been
-- read as to -1, so will match
--
--  if(l_old_wc_code<>l_new_wc_code) then
    --Should add page level error
    /*hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => to_char(SQLCODE)
      ,p_errormsg   => hr_util_misc_web.return_msg_text
                       (p_message_name   => 'HR_JOB_CHANGES_WC_RATE_WEB'
                       ,p_application_id => 'PER')
      ,p_email_id   => p_email_id
      ,p_email_msg  => hr_util_misc_web.return_msg_text
                       (p_message_name   => 'HR_WC_RATE_CHG_EMAILTXT_WEB'
                       ,p_application_id => 'PER')
      );*/
--      l_validate:=TRUE;
--      fnd_message.set_name('PER', 'HR_JOB_CHANGES_WC_RATE_WEB');
--      hr_utility.raise_error;
--  end if;
--  end if; --end check wc_code
--
-- if there is no manager in the organization now then raise a warning
--
  /*if (l_org_now_no_manager_warning) then
    --Should add page level warning
    fnd_message.set_name('PER','HR_51124_MMV_NO_MGR_EXIST_ORG');
    hr_utility.raise_error;
    hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errormsg   => fnd_message.get
      ,p_warningflag => TRUE);
  end if;*/
--
-- if there are other managers then raise a warning
--
  /*if (l_other_manager_warning) then
    --Should add page level warning
    fnd_message.set_name('PER','HR_51125_MMV_MRE_MRG_EXIST_ORG');
    hr_utility.raise_error;
    hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errormsg   => fnd_message.get
      ,p_warningflag => TRUE);
  end if;*/
--
-- if there are no errors from the previous api call then call the
-- assignment information api.
-- This is always called in CORRECTION mode because once we have made an UPDATE
-- to the row to make another change to it will be a correction.

  --First remove the remove_ignore_df_validation
  -- and remove_ignore_kf_validation

  hr_dflex_utility.remove_ignore_df_validation;
  hr_kflex_utility.remove_ignore_kf_validation;
  --

    l_soft_coding_keyflex_id := p_soft_coding_keyflex_id;

    hr_assignment_api.update_emp_asg
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => 'CORRECTION'
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => l_object_version_number
      ,p_supervisor_id                => p_supervisor_id
      ,p_manager_flag                 => p_manager_flag
      ,p_normal_hours                 => p_normal_hours
      ,p_frequency                    => p_frequency
      ,p_time_normal_finish           => p_time_normal_finish
      ,p_time_normal_start            => p_time_normal_start
      ,p_bargaining_unit_code         => p_bargaining_unit_code
      ,p_labour_union_member_flag     => p_labour_union_member_flag
      ,p_sal_review_period            => p_sal_review_period
      ,p_sal_review_period_frequency  => p_sal_review_period_frequency
      ,p_date_probation_end           => p_date_probation_end
      ,p_probation_period             => p_probation_period
      ,p_probation_unit               => p_probation_unit
      ,p_notice_period                => p_notice_period
      ,p_notice_period_uom            => p_notice_period_uom
      ,p_employee_category            => p_employee_category
      ,p_work_at_home                 => p_work_at_home
      ,p_job_post_source_name         => p_job_post_source_name
      ,p_perf_review_period           => p_perf_review_period
      ,p_perf_review_period_frequency => p_perf_review_period_frequency
      ,p_internal_address_line        => p_internal_address_line
      ,p_ass_attribute_category       => p_ass_attribute_category
      ,p_ass_attribute1               => p_ass_attribute1
      ,p_ass_attribute2               => p_ass_attribute2
      ,p_ass_attribute3               => p_ass_attribute3
      ,p_ass_attribute4               => p_ass_attribute4
      ,p_ass_attribute5               => p_ass_attribute5
      ,p_ass_attribute6               => p_ass_attribute6
      ,p_ass_attribute7               => p_ass_attribute7
      ,p_ass_attribute8               => p_ass_attribute8
      ,p_ass_attribute9               => p_ass_attribute9
      ,p_ass_attribute10              => p_ass_attribute10
      ,p_ass_attribute11              => p_ass_attribute11
      ,p_ass_attribute12              => p_ass_attribute12
      ,p_ass_attribute13              => p_ass_attribute13
      ,p_ass_attribute14              => p_ass_attribute14
      ,p_ass_attribute15              => p_ass_attribute15
      ,p_ass_attribute16              => p_ass_attribute16
      ,p_ass_attribute17              => p_ass_attribute17
      ,p_ass_attribute18              => p_ass_attribute18
      ,p_ass_attribute19              => p_ass_attribute19
      ,p_ass_attribute20              => p_ass_attribute20
      ,p_ass_attribute21              => p_ass_attribute21
      ,p_ass_attribute22              => p_ass_attribute22
      ,p_ass_attribute23              => p_ass_attribute23
      ,p_ass_attribute24              => p_ass_attribute24
      ,p_ass_attribute25              => p_ass_attribute25
      ,p_ass_attribute26              => p_ass_attribute26
      ,p_ass_attribute27              => p_ass_attribute27
      ,p_ass_attribute28              => p_ass_attribute28
      ,p_ass_attribute29              => p_ass_attribute29
      ,p_ass_attribute30              => p_ass_attribute30
      ,p_segment1                     => l_SOFt_coding_keyflex.segment1
      ,p_segment2                     => l_soft_coding_keyflex.segment2
      ,p_segment3                     => l_soft_coding_keyflex.segment3
      ,p_segment4                     => l_soft_coding_keyflex.segment4
      ,p_segment5                     => l_soft_coding_keyflex.segment5
      ,p_segment6                     => l_soft_coding_keyflex.segment6
      ,p_segment7                     => l_soft_coding_keyflex.segment7
      ,p_segment8                     => l_soft_coding_keyflex.segment8
      ,p_segment9                     => l_soft_coding_keyflex.segment9
      ,p_segment10                    => l_soft_coding_keyflex.segment10
      ,p_segment11                    => l_soft_coding_keyflex.segment11
      ,p_segment12                    => l_soft_coding_keyflex.segment12
      ,p_segment13                    => l_soft_coding_keyflex.segment13
      ,p_segment14                    => l_soft_coding_keyflex.segment14
      ,p_segment15                    => l_soft_coding_keyflex.segment15
      ,p_segment16                    => l_soft_coding_keyflex.segment16
      ,p_segment17                    => l_soft_coding_keyflex.segment17
      ,p_segment18                    => l_soft_coding_keyflex.segment18
      ,p_segment19                    => l_soft_coding_keyflex.segment19
      ,p_segment20                    => l_soft_coding_keyflex.segment20
      ,p_segment21                    => l_soft_coding_keyflex.segment21
      ,p_segment22                    => l_soft_coding_keyflex.segment22
      ,p_segment23                    => l_soft_coding_keyflex.segment23
      ,p_segment24                    => l_soft_coding_keyflex.segment24
      ,p_segment25                    => l_soft_coding_keyflex.segment25
      ,p_segment26                    => l_soft_coding_keyflex.segment26
      ,p_segment27                    => l_soft_coding_keyflex.segment27
      ,p_segment28                    => l_soft_coding_keyflex.segment28
      ,p_segment29                    => l_soft_coding_keyflex.segment29
      ,p_segment30                    => l_soft_coding_keyflex.segment30
      ,p_cag_segment1                 => l_cagr_grades_def.segment1
      ,p_cag_segment2                 => l_cagr_grades_def.segment2
      ,p_cag_segment3                 => l_cagr_grades_def.segment3
      ,p_cag_segment4                 => l_cagr_grades_def.segment4
      ,p_cag_segment5                 => l_cagr_grades_def.segment5
      ,p_cag_segment6                 => l_cagr_grades_def.segment6
      ,p_cag_segment7                 => l_cagr_grades_def.segment7
      ,p_cag_segment8                 => l_cagr_grades_def.segment8
      ,p_cag_segment9                 => l_cagr_grades_def.segment9
      ,p_cag_segment10                => l_cagr_grades_def.segment10
      ,p_cag_segment11                 => l_cagr_grades_def.segment11
      ,p_cag_segment12                 => l_cagr_grades_def.segment12
      ,p_cag_segment13                 => l_cagr_grades_def.segment13
      ,p_cag_segment14                 => l_cagr_grades_def.segment14
      ,p_cag_segment15                 => l_cagr_grades_def.segment15
      ,p_cag_segment16                 => l_cagr_grades_def.segment16
      ,p_cag_segment17                 => l_cagr_grades_def.segment17
      ,p_cag_segment18                 => l_cagr_grades_def.segment18
      ,p_cag_segment19                 => l_cagr_grades_def.segment19
      ,p_cag_segment20                => l_cagr_grades_def.segment20
      --,p_contract_id                  => p_contract_id
      --,p_establishment_id             => p_establishment_id
      ,p_collective_agreement_id      => p_collective_agreement_id
      ,p_cagr_id_flex_num             => p_cagr_id_flex_num
      ,p_cagr_grade_def_id            => l_cagr_grade_def_id
      ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
      ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
      ,p_comment_id                   => l_comment_id
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_no_managers_warning          => l_org_now_no_manager_warning
      ,p_other_manager_warning        => l_other_manager_warning
      ,p_title                        => p_title
      );

   p_soft_coding_keyflex_id := l_soft_coding_keyflex_id;

--
-- check the warning flags again
--
    /*if(l_org_now_no_manager_warning) then
      --Should add page level warning
      --fnd_message.set_name('PER','HR_51124_MMV_NO_MGR_EXIST_ORG');
      --hr_utility.raise_error;
      hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errormsg   => fnd_message.get
      ,p_warningflag => TRUE);
    end if;
    if(l_other_manager_warning) then
      --Should add page level warning
      --fnd_message.set_name('PER','HR_51125_MMV_MRE_MRG_EXIST_ORG');
      --hr_utility.raise_error;
      hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errormsg   => fnd_message.get
      ,p_warningflag => TRUE);
    end if;*/

    --update_emp_asg_criteria again. this is a work around of bug 2493923.
    hr_assignment_api.update_emp_asg_criteria
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => 'CORRECTION'
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => l_object_version_number
      ,p_grade_id                     => p_grade_id
      ,p_special_ceiling_step_id      => p_special_ceiling_step_id
      ,p_payroll_id                   => p_payroll_id
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_people_group_id              => l_people_group_id
      ,p_group_name                   => l_group_name
      ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
      ,p_other_manager_warning        => l_other_manager_warning
      ,p_spp_delete_warning           => l_spp_delete_warning
      ,p_entries_changed_warning      => l_entries_changed_warning
      ,p_tax_district_changed_warning => l_tax_district_changed_warning
      ,p_gsp_post_process_warning     => p_gsp_post_process_warning
      );
   end if;
end if;
    --
    -- update the assignment status type
    --
    --
    -- chack to see what type of status the new id corresponds to.
    --
    open status_type;
    fetch status_type into l_assignment_status_type;
    if status_type%notfound then
      close status_type;
    else
      close status_type;

      --
      -- if we have an active assignment type then use the activate_emp_asg api
      if l_assignment_status_type='ACTIVE_ASSIGN' then
      --
      -- active emp assignment
      --
        hr_utility.set_location('if l_assignment_status_type=ACTIVE_ASSIGN then:'||l_proc,40);
        hr_assignment_api.activate_emp_asg
        (p_effective_date               => l_effective_date
        ,p_datetrack_update_mode        => 'CORRECTION'
        ,p_assignment_id                => p_assignment_id
        ,p_object_version_number        => l_object_version_number
        ,p_assignment_status_type_id    => p_assignment_status_type_id
        ,p_change_reason                => p_change_reason
        ,p_effective_start_date         => l_effective_start_date
        ,p_effective_end_date           => l_effective_end_date);
      elsif l_assignment_status_type='ACTIVE_CWK' then
      --
      --active cwk assignment
      --
        hr_assignment_api.activate_cwk_asg
        (p_effective_date               => l_effective_date
        ,p_datetrack_update_mode        => 'CORRECTION'
        ,p_assignment_id                => p_assignment_id
        ,p_object_version_number        => l_object_version_number
        ,p_assignment_status_type_id    => p_assignment_status_type_id
        ,p_change_reason                => p_change_reason
        ,p_effective_start_date         => l_effective_start_date
        ,p_effective_end_date           => l_effective_end_date);
      elsif l_assignment_status_type='SUSP_ASSIGN' then
      --
      -- suspend emp assignment
      --
        hr_assignment_api.suspend_emp_asg
        (p_effective_date               => l_effective_date
        ,p_datetrack_update_mode        => 'CORRECTION'
        ,p_assignment_id                => p_assignment_id
        ,p_object_version_number        => l_object_version_number
        ,p_assignment_status_type_id    => p_assignment_status_type_id
        ,p_change_reason                => p_change_reason
        ,p_effective_start_date         => l_effective_start_date
        ,p_effective_end_date           => l_effective_end_date);
      elsif l_assignment_status_type='SUSP_CWK_ASG' then
      --
      -- suspend cwk assignment
      --
        hr_assignment_api.suspend_cwk_asg
        (p_effective_date               => l_effective_date
        ,p_datetrack_update_mode        => 'CORRECTION'
        ,p_assignment_id                => p_assignment_id
        ,p_object_version_number        => l_object_version_number
        ,p_assignment_status_type_id    => p_assignment_status_type_id
        ,p_change_reason                => p_change_reason
        ,p_effective_start_date         => l_effective_start_date
        ,p_effective_end_date           => l_effective_end_date);

      elsif l_assignment_status_type = 'TERM_ASSIGN' then
         hr_assignment_api.actual_termination_emp_asg
         (p_assignment_id                => p_assignment_id
         ,p_object_version_number        => l_object_version_number
         ,p_actual_termination_date      => l_effective_date - 1
        ,p_assignment_status_type_id    => p_assignment_status_type_id
        ,p_effective_start_date         => l_effective_start_date
        ,p_effective_end_date           => l_effective_end_date
         ,p_asg_future_changes_warning	=> l_asg_future_changes_warning
         ,p_entries_changed_warning	=> l_entries_changed_warning
         ,p_pay_proposal_warning	=> l_pay_proposal_warning);

      elsif p_assignment_type = 'E' and l_assignment_status_type = 'END' then
          hr_assignment_api.actual_termination_emp_asg
         (p_assignment_id                => p_assignment_id
         ,p_object_version_number        => l_object_version_number
         ,p_actual_termination_date      => l_effective_date
        ,p_effective_start_date         => l_effective_start_date
        ,p_effective_end_date           => l_effective_end_date
         ,p_asg_future_changes_warning	=> l_asg_future_changes_warning
         ,p_entries_changed_warning	=> l_entries_changed_warning
         ,p_pay_proposal_warning	=> l_pay_proposal_warning);

           hr_assignment_api.final_process_emp_asg
          (p_assignment_id                => p_assignment_id
         ,p_object_version_number        => l_object_version_number
         ,p_final_process_date      => l_effective_date
        ,p_effective_start_date         => l_effective_start_date
        ,p_effective_end_date           => l_effective_end_date
         ,p_asg_future_changes_warning	=> l_asg_future_changes_warning
         ,p_entries_changed_warning	=> l_entries_changed_warning
         ,p_org_now_no_manager_warning	=> l_org_now_no_manager_warning);

     elsif p_assignment_type = 'C' and l_assignment_status_type = 'END' then

         hr_assignment_api.actual_termination_cwk_asg
         (p_assignment_id                => p_assignment_id
         ,p_object_version_number        => l_object_version_number
         ,p_actual_termination_date      => l_effective_date
        ,p_effective_start_date         => l_effective_start_date
        ,p_effective_end_date           => l_effective_end_date
         ,p_asg_future_changes_warning	=> l_asg_future_changes_warning
         ,p_entries_changed_warning	=> l_entries_changed_warning
         ,p_pay_proposal_warning	=> l_pay_proposal_warning);

           hr_assignment_api.final_process_cwk_asg
          (p_assignment_id                => p_assignment_id
         ,p_object_version_number        => l_object_version_number
         ,p_final_process_date      => l_effective_date
        ,p_effective_start_date         => l_effective_start_date
        ,p_effective_end_date           => l_effective_end_date
         ,p_asg_future_changes_warning	=> l_asg_future_changes_warning
         ,p_entries_changed_warning	=> l_entries_changed_warning
         ,p_org_now_no_manager_warning	=> l_org_now_no_manager_warning);
      end if;
    end if;
    --
    p_effective_start_date:=l_effective_start_date;
    p_effective_end_date:=l_effective_end_date;

    -- GSP changes
     -- get salary information in to ltt_salary_data
     hr_pay_rate_gsp_ss.check_grade_ladder_exists(
                   p_business_group_id =>  p_organization_id,
                   p_effective_date =>  l_effective_date,
                   p_grd_ldr_exists_flag => lb_grd_ldr_exists_flag);
     -- may be required to add grade or step or ladder change condition
     if(lb_grd_ldr_exists_flag) then
       hr_utility.set_location('if(lb_grd_ldr_exists_flag) then:'||l_proc,45);
       hr_pay_rate_gsp_ss.get_employee_salary(
                            p_assignment_id =>  p_assignment_id,
                            P_effective_date => l_effective_date,
                            p_ltt_salary_data => p_ltt_salary_data);
     end if;
    -- End of GSP changes
 --bug 5032032 fix begin
if p_new_hire_appl_hire = 'Y' then
update_salary_proposal(p_assignment_id,l_effective_date);
end if;
--bug 5032032 fix end
  --
  -- if we are in validate only mode, rollback
  --
  if l_validate=TRUE then
    hr_utility.set_location('if l_validate=TRUE then:rollback'||l_proc,50);
    rollback to validate_assignment;
  end if;

--
-- handle any errors that are raised.
--
exception
when others then
  hr_utility.set_location('Exception:Others'||l_proc,555);
  rollback to validate_assignment;
  --hr_utility.raise_error;
  raise;
  --hr_message.provide_error;
  --Should add page level error
  /*hr_errors_api.addErrorToTable
  (p_errorfield => null
  ,p_errorcode  => hr_message.last_message_number
  ,p_errormsg   => hr_message.get_message_text);*/
end update_assignment;

--
FUNCTION get_assignment(p_transaction_step_id in number)
  RETURN ref_cursor IS
    csr ref_cursor;

asgRec hr_transaction_ss.transaction_data;
l_proc   varchar2(72)  := g_package||'get_assignment';
l_old_mgr_flag varchar2(10);
l_old_labour_union_flag varchar2(10);
l_old_organization_id number;
l_old_pay_basis_id    number;
l_old_grade_id           number;
l_primary_flag	varchar2(4);
l_assignment_id number;
l_effective_date date;

cursor csr_prim_flag is
    select primary_flag into l_primary_flag from per_all_assignments_f
    where assignment_id = l_assignment_id and trunc(l_effective_date)
    between effective_start_date and effective_end_date;

begin
hr_utility.set_location('Entering:'||l_proc, 5);

 -- Fetch Original Manager Flag
 l_old_mgr_flag := hr_transaction_api.get_original_varchar2_value(p_transaction_step_id,'P_MANAGER_FLAG');
 -- Fetch Original Labour Union Flag
 l_old_labour_union_flag := hr_transaction_api.get_original_varchar2_value(p_transaction_step_id,'P_LABOUR_UNION_MEMBER_FLAG');
 l_old_organization_id := hr_transaction_api.get_number_value(p_transaction_step_id,'P_ORGANIZATION_ID');
 l_old_pay_basis_id := hr_transaction_api.get_original_number_value(p_transaction_step_id,'P_PAY_BASIS_ID');
 l_old_grade_id := hr_transaction_api.get_original_number_value(p_transaction_step_id,'P_GRADE_ID');
 l_primary_flag := hr_transaction_api.get_varchar2_value(p_transaction_step_id,'P_PRIMARY_FLAG');
 l_assignment_id := hr_transaction_api.get_number_value(p_transaction_step_id,'P_ASSIGNMENT_ID');
 l_effective_date := hr_transaction_api.get_date_value(p_transaction_step_id,'P_EFFECTIVE_DATE');

 if l_primary_flag is null then
    open csr_prim_flag;
    fetch csr_prim_flag into l_primary_flag;
    close csr_prim_flag;
    if l_primary_flag is null then
       l_primary_flag := 'Y';
    end if;
  end if;

hr_transaction_ss.get_transaction_data
  (p_transaction_step_id => p_transaction_step_id
  ,p_transaction_data    => asgRec);

  IF (asgRec.name.count < 108) THEN
  hr_utility.set_location('IF (asgRec.name.count < 108) THEN:'||l_proc,10);
  BEGIN
    hr_utility.set_location('Entering For Loop:'||l_proc,15);
    FOR I in asgRec.name.count+1 .. 108 LOOP
        asgRec.name(I) := null;
        asgRec.number_value(I) := null;
        asgRec.varchar2_value(I) := null;
        asgRec.date_value(I) := null;
    END LOOP;
    hr_utility.set_location('Exiting For Loop:'||l_proc,15);
  END;
  END IF;

open csr for
SELECT
             asgRec.number_value(1) assignment_id,
             asgRec.number_value(8) business_group_id,
             asgRec.number_value(7) organization_id,
             org.name organization_name,
             asgRec.number_value(2) object_version_number,
             asgRec.number_value(12) position_id,
             pos.name position_name,
             asgRec.number_value(14) job_id,
             job.name job_name,
             asgRec.number_value(16) grade_id,
             grade.name grade_name,
             asgRec.number_value(18) location_id,
             asgRec.varchar2_value(19) employment_category,
             asgRec.number_value(20) supervisor_id,
             asgRec.varchar2_value(21) manager_flag,
             asgRec.number_value(22) normal_hours,
             asgRec.varchar2_value(23) frequency,
             asgRec.varchar2_value(24) time_normal_finish,
             asgRec.varchar2_value(25) time_normal_start,
             asgRec.number_value(28) special_ceiling_step_id,
             asgRec.number_value(29) assignment_status_type_id,
             asgRec.varchar2_value(30) change_reason,
             asgRec.varchar2_value(31) ass_attribute_category,
             asgRec.varchar2_value(32) ass_attribute1,
             asgRec.varchar2_value(33) ass_attribute2,
             asgRec.varchar2_value(34) ass_attribute3,
             asgRec.varchar2_value(35) ass_attribute4,
             asgRec.varchar2_value(36) ass_attribute5,
             asgRec.varchar2_value(37) ass_attribute6,
             asgRec.varchar2_value(38) ass_attribute7,
             asgRec.varchar2_value(39) ass_attribute8,
             asgRec.varchar2_value(40) ass_attribute9,
             asgRec.varchar2_value(41) ass_attribute10,
             asgRec.varchar2_value(42) ass_attribute11,
             asgRec.varchar2_value(43) ass_attribute12,
             asgRec.varchar2_value(44) ass_attribute13,
             asgRec.varchar2_value(45) ass_attribute14,
             asgRec.varchar2_value(46) ass_attribute15,
             asgRec.varchar2_value(47) ass_attribute16,
             asgRec.varchar2_value(48) ass_attribute17,
             asgRec.varchar2_value(49) ass_attribute18,
             asgRec.varchar2_value(50) ass_attribute19,
             asgRec.varchar2_value(51) ass_attribute20,
             asgRec.varchar2_value(52) ass_attribute21,
             asgRec.varchar2_value(53) ass_attribute22,
             asgRec.varchar2_value(54) ass_attribute23,
             asgRec.varchar2_value(55) ass_attribute24,
             asgRec.varchar2_value(56) ass_attribute25,
             asgRec.varchar2_value(57) ass_attribute26,
             asgRec.varchar2_value(58) ass_attribute27,
             asgRec.varchar2_value(59) ass_attribute28,
             asgRec.varchar2_value(60) ass_attribute29,
             asgRec.varchar2_value(61) ass_attribute30,
             asgRec.number_value(62) people_group_id,
             asgRec.number_value(63) soft_coding_keyflex_id,
             asgRec.number_value(66) sal_review_period,
             asgRec.varchar2_value(67) sal_review_period_frequency,
             asgRec.number_value(71) notice_period,
             asgRec.varchar2_value(73) employee_category,
             asgRec.varchar2_value(74) work_at_home,
             asgRec.varchar2_value(75) job_post_source_name,
             asgRec.number_value(76) perf_review_period,
             asgRec.varchar2_value(77) perf_review_period_frequency,
             asgRec.number_value(64) payroll_id,
             asgRec.number_value(65) pay_basis_id,
             asgRec.number_value(80) establishment_id,
             asgRec.varchar2_value(88) title,
             asgRec.varchar2_value(89) project_title,
             asgRec.varchar2_value(90) source_type,
             asgRec.varchar2_value(91) vendor_assignment_number,
             asgRec.varchar2_value(92) vendor_employee_number,
             asgRec.number_value(84) default_code_comb_id,
             asgRec.number_value(85) set_of_books_id,
             asgRec.number_value(86) vendor_id,
             vendor.vendor_name vendor_name,
             asgRec.varchar2_value(87) assignment_type,
             asgRec.number_value(104) grade_ladder_id,
             pgm.name grade_ladder_name,
             asgRec.number_value(105) po_header_id,
             asgRec.number_value(106) po_line_id,
             asgRec.number_value(107) vendor_site_id,
             po_heads.segment1 po_number,
             po_lines.line_num po_line_number,
             vend_sits.vendor_site_code vendor_site_name,
             asgRec.DATE_VALUE(108) projected_assignment_end,
             ---  Position Defaulting changes
             asgRec.number_value(69) probation_period,
             asgRec.varchar2_value(70) probation_unit,
             asgRec.DATE_VALUE(68) date_probation_end,
             asgRec.varchar2_value(72) notice_period_uom,
             asgRec.varchar2_value(26) bargaining_unit_code,
             hl_bargaining_unit.meaning bargaining_unit_name,
             asgRec.varchar2_value(27) labour_union_member_flag,
             l_old_mgr_flag          old_manager_flag,
             l_old_labour_union_flag old_labour_union_flag,
             l_old_organization_id     old_organization_id,
             l_old_pay_basis_id        old_pay_basis_id,
             l_old_grade_id	old_grade_id,
             l_primary_flag                 primary_flag
             from
                  hr_api_transaction_steps ts
                 ,hr_api_transaction_values otv, hr_all_organization_units_tl  org
                 ,hr_api_transaction_values jtv, per_jobs_tl job
                 ,hr_api_transaction_values ptv, hr_all_positions_f_tl pos
                 ,hr_api_transaction_values gtv, per_grades_tl  grade
                 ,hr_api_transaction_values vtv, po_vendors vendor
                 ,hr_api_transaction_values gltv, ben_pgm_f pgm
                 ,hr_api_transaction_values htv, po_headers_all po_heads
                 ,hr_api_transaction_values ltv, po_lines_all po_lines
                 ,hr_api_transaction_values stv, po_vendor_sites_all vend_sits
                 ,hr_api_transaction_values btv, hr_lookups hl_bargaining_unit

             where

                  ts.transaction_step_id = p_transaction_step_id
                  and otv.transaction_step_id(+) = ts.transaction_step_id
                  and otv.name(+) = 'P_ORGANIZATION_ID'
                  and otv.number_value = org.organization_id(+)
                  and org.language(+) = userenv('LANG')

                  and jtv.transaction_step_id(+) = ts.transaction_step_id
                  and jtv.name(+) = 'P_JOB_ID'
                  and jtv.number_value = job.job_id(+)
                  and job.language(+) = userenv('LANG')

                  and ptv.transaction_step_id(+) = ts.transaction_step_id
                  and ptv.name(+) = 'P_POSITION_ID'
                  and ptv.number_value = pos.position_id(+)
                  and pos.language(+) = userenv('LANG')

                  and gtv.transaction_step_id(+) = ts.transaction_step_id
                  and gtv.name(+) = 'P_GRADE_ID'
                  and gtv.number_value = grade.grade_id(+)
                  and grade.language(+) = userenv('LANG')

                  and vtv.transaction_step_id(+) = ts.transaction_step_id
                  and vtv.name(+) = 'P_VENDOR_ID'
                  and vtv.number_value = vendor.vendor_id(+)

                  and gltv.transaction_step_id(+) = ts.transaction_step_id
                  and gltv.name(+) = 'P_GRADE_LADDER_PGM_ID'
                  and gltv.number_value = pgm.pgm_id(+)

                  and htv.transaction_step_id(+) = ts.transaction_step_id
                  and htv.name(+) = 'P_PO_HEADER_ID'
                  and htv.number_value = po_heads.po_header_id(+)

                  and ltv.transaction_step_id(+) = ts.transaction_step_id
                  and ltv.name(+) = 'P_PO_LINE_ID'
                  and ltv.number_value = po_lines.po_line_id(+)

                  and stv.transaction_step_id(+) = ts.transaction_step_id
                  and stv.name(+) = 'P_VENDOR_SITE_ID'
                  and stv.number_value = vend_sits.vendor_site_id(+)

                  and btv.transaction_step_id(+) = ts.transaction_step_id
                  and btv.name(+) = 'P_BARGAINING_UNIT_CODE'
                  and btv.varchar2_value =  hl_bargaining_unit.lookup_code(+) -- Bug 7603539
                  and hl_bargaining_unit.lookup_type(+) = 'BARGAINING_UNIT_CODE'
                  and hl_bargaining_unit.enabled_flag(+) = 'Y'
                  and (trunc(sysdate) between nvl(hl_bargaining_unit.start_date_active(+), trunc(sysdate))
                  and nvl(hl_bargaining_unit.end_date_active(+), trunc(sysdate)));


  hr_utility.set_location('Exiting:'||l_proc, 20);
  return csr;
END;

FUNCTION get_rec_cnt
  RETURN NUMBER IS
  Cnt NUMBER:= 1;
BEGIN
  hr_utility.set_location('Entering:get_rec_cnt', 5);
  hr_utility.set_location('Exiting:get_rec_cnt', 10);
  RETURN Cnt;
END;
--

FUNCTION get_po_number(p_po_header_id in number)
   RETURN VARCHAR2 is
cursor csr_po_number(p_id in number) is
-- 4894113: R12 performance repository related fix
-- ISSUE : Shared memory size 2,413,494
-- RESOLUTION:
-- 1.Since we are interested only in  poh.segment1 we can
-- drop the rest of the columns and unwanted WHERE clauses from the
-- view po_temp_labor_headers_v
-- 2. The SQL below we have retained all the WHERE clauses
-- dealing with the table po_headers_all, but dropped the rest
-- which are not required in this case.

SELECT poh.segment1 po_number
FROM
    po_headers_all poh
WHERE
    poh.po_header_id = p_id
    AND poh.type_lookup_code = 'STANDARD'
    AND poh.authorization_status IN ('APPROVED', 'PRE-APPROVED')
    AND poh.approved_flag = 'Y'
    AND poh.enabled_flag = 'Y'
    AND NVL(poh.cancel_flag, 'N') <> 'Y'
    AND NVL(poh.frozen_flag, 'N') <> 'Y'
    AND poh.org_id IS NOT NULL
    AND EXISTS
    (
    SELECT
        NULL
    FROM po_lines_all pol ,
        po_line_types_b polt
    WHERE pol.po_header_id = poh.po_header_id
        AND NVL(pol.cancel_flag, 'N') <> 'Y'
        AND pol.line_type_id = polt.line_type_id
        AND polt.purchase_basis = 'TEMP LABOR'
    );

--select po_number
--from po_temp_labor_headers_v
--where po_header_id = p_id;


l_po_number po_temp_labor_headers_v.po_number%TYPE;
l_proc   varchar2(72)  := g_package||'get_po_number';

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  open csr_po_number(p_po_header_id);
  fetch csr_po_number into l_po_number;
  close csr_po_number;

  hr_utility.set_location('Exiting:'||l_proc, 15);
  return l_po_number;
END;

FUNCTION get_po_line_nuber(p_po_line_id in number)
   RETURN number is
cursor csr_po_line_number(p_id in number) is
select line_number
from po_temp_labor_lines_v
where po_line_id = p_id;

l_po_line_number number;
l_proc   varchar2(72)  := g_package||'get_po_line_nuber';

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  open csr_po_line_number(p_po_line_id);
  fetch csr_po_line_number into l_po_line_number;
  close csr_po_line_number;


  hr_utility.set_location('Exiting:'||l_proc, 15);
  return l_po_line_number;
END;

FUNCTION get_vend_site_name(p_vendor_site_id in number)
   RETURN VARCHAR2 is
cursor csr_vendor_site_name(p_id in number) is
select vendor_site_code
from po_vendor_sites_all
where vendor_site_id  = p_id;

l_vendor_site_name po_vendor_sites_all.vendor_site_code%TYPE;
l_proc   varchar2(72)  := g_package||'get_vend_site_name';

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  open csr_vendor_site_name(p_vendor_site_id);
  fetch csr_vendor_site_name into l_vendor_site_name;
  close csr_vendor_site_name;


  hr_utility.set_location('Exiting:'||l_proc, 15);
  return l_vendor_site_name;
END;

-- End of NTF change

-- Decode funtion for probation_end_date to display it in user
-- preference format
FUNCTION get_probation_end_date(p_probation_end_date in varchar2)
   RETURN varchar2 is
l_dateformat   VARCHAR2(30);
BEGIN

 fnd_profile.get('ICX_DATE_FORMAT_MASK',l_dateformat);
 return to_char(to_date(p_probation_end_date, l_dateformat),l_dateformat);
 Exception
 WHEN OTHERS THEN
   return to_char(to_date(p_probation_end_date,'RRRR/MM/DD'), l_dateformat);
END;

--
end hr_process_assignment_ss;

/

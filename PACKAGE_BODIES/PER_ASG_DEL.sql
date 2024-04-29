--------------------------------------------------------
--  DDL for Package Body PER_ASG_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ASG_DEL" as
/* $Header: peasgrhi.pkb 120.19.12010000.7 2009/11/20 09:42:17 sidsaxen ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  per_asg_del.';  -- Global package name
g_debug    boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_delete_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic for the datetrack
--   delete modes: ZAP, DELETE, FUTURE_CHANGE and DELETE_NEXT_CHANGE. The
--   execution is as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) If the delete mode is DELETE_NEXT_CHANGE then delete where the
--      effective start date is equal to the validation start date.
--   3) If the delete mode is not DELETE_NEXT_CHANGE then delete
--      all rows for the entity where the effective start date is greater
--      than or equal to the validation start date.
--   4) To raise any errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_dml
    (p_rec              in out nocopy per_asg_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc    varchar2(72) := g_package||'dt_delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode = 'DELETE_NEXT_CHANGE') then
    hr_utility.set_location(l_proc, 10);
    per_asg_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from per_all_assignments_f
    where assignment_id        = p_rec.assignment_id
    and      effective_start_date = p_validation_start_date;
    --
    per_asg_shd.g_api_dml := false;   -- Unset the api dml status
  Else
    hr_utility.set_location(l_proc, 15);
    per_asg_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from per_all_assignments_f
    where assignment_id         = p_rec.assignment_id
    and      effective_start_date >= p_validation_start_date;
    --
    per_asg_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    per_asg_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
    (p_rec              in out nocopy per_asg_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc    varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_delete_dml(p_rec            => p_rec,
        p_effective_date    => p_effective_date,
        p_datetrack_mode    => p_datetrack_mode,
               p_validation_start_date    => p_validation_start_date,
        p_validation_end_date    => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_delete >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_delete process controls the execution of dml
--   for the datetrack modes: DELETE, FUTURE_CHANGE
--   and DELETE_NEXT_CHANGE only.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the pre_delete
--   procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_delete
    (p_rec              in out nocopy per_asg_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc    varchar2(72) := g_package||'dt_pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode <> 'ZAP') then
    --
    p_rec.effective_start_date := per_asg_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = 'DELETE') then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    per_asg_shd.upd_effective_end_date
      (p_effective_date            => p_effective_date,
       p_base_key_value            => p_rec.assignment_id,
       p_new_effective_end_date => p_rec.effective_end_date,
       p_validation_start_date  => p_validation_start_date,
       p_validation_end_date    => p_validation_end_date,
       p_object_version_number  => p_rec.object_version_number);
  --
  -- 70.1 change g start.
  --
  Else
    p_rec.effective_start_date := null;
    p_rec.effective_end_date   := null;
  --
  -- 70.1 change g end.
  --
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End dt_pre_delete;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the del procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_delete_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete
    (p_rec              in out nocopy per_asg_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc    varchar2(72) := g_package||'pre_delete';
--
  -- Cursor C_Sel1 select comments to be deleted
  --
  Cursor C_Sel1 is
    select asg1.comment_id
    from   per_all_assignments_f asg1
    where  asg1.comment_id           is not null
    and    asg1.assignment_id         = p_rec.assignment_id
    and    asg1.effective_start_date <= p_validation_end_date
    and    asg1.effective_end_date   >= p_validation_start_date
    and    not exists
           (select 1
            from   per_all_assignments_f asg2
            where  asg2.comment_id           = asg1.comment_id
            and    asg2.assignment_id        = asg1.assignment_id
            and   (asg2.effective_start_date > p_validation_end_date
             or    asg2.effective_end_date   < p_validation_start_date));
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Delete any possible comments
  --
  For Comm_Del In C_Sel1 Loop
    hr_comm_api.del(p_comment_id        => Comm_Del.comment_id);
  End Loop;
  --
  dt_pre_delete
    (p_rec              => p_rec,
     p_effective_date         => p_effective_date,
     p_datetrack_mode         => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   delete dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the del procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete
    (p_rec                         in  per_asg_shd.g_rec_type,
     p_effective_date              in  date,
     p_datetrack_mode              in  varchar2,
     p_validation_start_date       in  date,
     p_validation_end_date         in  date,
     p_org_now_no_manager_warning  in  boolean,
     p_loc_change_tax_issues       OUT nocopy boolean,
     p_delete_asg_budgets          OUT nocopy boolean,
     p_element_salary_warning      OUT nocopy boolean,
     p_element_entries_warning     OUT nocopy boolean,
     p_spp_warning                 OUT nocopy boolean,
     p_cost_warning                OUT nocopy boolean,
     p_life_events_exists   	   OUT nocopy boolean,
     p_cobra_coverage_elements     OUT nocopy boolean,
     p_assgt_term_elements         OUT nocopy boolean,
     ---
     p_new_prim_ass_id             IN number,
     p_prim_change_flag            IN varchar2,
     p_new_end_date                IN date,
     p_new_primary_flag            IN varchar2,
     p_s_pay_id                    IN number,
     p_cancel_atd                  IN date,
     p_cancel_lspd                 IN date,
     p_reterm_atd                  IN date,
     p_reterm_lspd                 IN date,
     ---
     p_appl_asg_new_end_date       IN date ) is
--
  l_proc                       varchar2(72) := g_package||'post_delete';
  l_loc_change_tax_issues      boolean; --4888485 , all declarations below are new
  l_delete_asg_budgets         boolean;
  l_element_salary_warning     boolean;
  l_element_entries_warning    boolean;
  l_spp_warning                boolean;
  l_cost_warning               boolean;
  l_life_events_exists         boolean;
  l_cobra_coverage_elements    boolean;
  l_assgt_term_elements        boolean;
  l_org_now_no_manager_warning boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_delete.
  --
  if g_debug then
     hr_utility.set_location('Before calling post_delete checks ', 10);
  end if;
  -- 4888485 -- Added new params
  hr_assignment_internal.post_delete
    (p_rec                        => p_rec,
     p_effective_date             => p_effective_date,
     p_datetrack_mode             => p_datetrack_mode,
     p_validation_start_date      => p_validation_start_date,
     p_validation_end_date        => p_validation_end_date,
     p_org_now_no_manager_warning => l_org_now_no_manager_warning,
     p_loc_change_tax_issues      => l_loc_change_tax_issues,
     p_delete_asg_budgets         => l_delete_asg_budgets,
     p_element_salary_warning     => l_element_salary_warning,
     p_element_entries_warning    => l_element_entries_warning,
     p_spp_warning                => l_spp_warning,
     P_cost_warning               => l_cost_warning,
     p_life_events_exists   	  => l_life_events_exists,
     p_cobra_coverage_elements    => l_cobra_coverage_elements,
     p_assgt_term_elements        => l_assgt_term_elements,
     ---
     p_new_prim_ass_id            => p_new_prim_ass_id,
     p_prim_change_flag           => p_prim_change_flag,
     p_new_end_date               => p_new_end_date,
     p_new_primary_flag           => p_new_primary_flag,
     p_s_pay_id                   => p_s_pay_id,
     p_cancel_atd                 => p_cancel_atd,
     p_cancel_lspd                => p_cancel_lspd,
     p_reterm_atd                 => p_reterm_atd,
     p_reterm_lspd                => p_reterm_lspd,
     ---
     p_appl_asg_new_end_date      => p_appl_asg_new_end_date );
  --
  begin
    per_asg_rkd.after_delete
      (p_effective_date            => p_effective_date
      ,p_datetrack_mode            => p_datetrack_mode
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      ,p_assignment_id               => p_rec.assignment_id
      ,p_effective_start_date      => p_rec.effective_start_date
      ,p_effective_end_date        => p_rec.effective_end_date
      ,p_org_now_no_manager_warning
                                   => p_org_now_no_manager_warning
      ,p_object_version_number     => p_rec.object_version_number
      ,p_effective_start_date_o
          => per_asg_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
          => per_asg_shd.g_old_rec.effective_end_date
      ,p_business_group_id_o
          => per_asg_shd.g_old_rec.business_group_id
      ,p_recruiter_id_o
          => per_asg_shd.g_old_rec.recruiter_id
      ,p_grade_id_o
          => per_asg_shd.g_old_rec.grade_id
      ,p_position_id_o
          => per_asg_shd.g_old_rec.position_id
      ,p_job_id_o
          => per_asg_shd.g_old_rec.job_id
      ,p_assignment_status_type_id_o
          => per_asg_shd.g_old_rec.assignment_status_type_id
      ,p_payroll_id_o
          => per_asg_shd.g_old_rec.payroll_id
      ,p_location_id_o
          => per_asg_shd.g_old_rec.location_id
      ,p_person_referred_by_id_o
          => per_asg_shd.g_old_rec.person_referred_by_id
      ,p_supervisor_id_o
          => per_asg_shd.g_old_rec.supervisor_id
      ,p_special_ceiling_step_id_o
          => per_asg_shd.g_old_rec.special_ceiling_step_id
      ,p_person_id_o
          => per_asg_shd.g_old_rec.person_id
      ,p_recruitment_activity_id_o
          => per_asg_shd.g_old_rec.recruitment_activity_id
      ,p_source_organization_id_o
          => per_asg_shd.g_old_rec.source_organization_id
      ,p_organization_id_o
          => per_asg_shd.g_old_rec.organization_id
      ,p_people_group_id_o
          => per_asg_shd.g_old_rec.people_group_id
      ,p_soft_coding_keyflex_id_o
          => per_asg_shd.g_old_rec.soft_coding_keyflex_id
      ,p_vacancy_id_o
          => per_asg_shd.g_old_rec.vacancy_id
      ,p_pay_basis_id_o
          => per_asg_shd.g_old_rec.pay_basis_id
      ,p_assignment_sequence_o
          => per_asg_shd.g_old_rec.assignment_sequence
      ,p_assignment_type_o
          => per_asg_shd.g_old_rec.assignment_type
      ,p_primary_flag_o
          => per_asg_shd.g_old_rec.primary_flag
      ,p_application_id_o
          => per_asg_shd.g_old_rec.application_id
      ,p_assignment_number_o
          => per_asg_shd.g_old_rec.assignment_number
      ,p_change_reason_o
          => per_asg_shd.g_old_rec.change_reason
      ,p_comment_id_o
          => per_asg_shd.g_old_rec.comment_id
      ,p_date_probation_end_o
          => per_asg_shd.g_old_rec.date_probation_end
      ,p_default_code_comb_id_o
          => per_asg_shd.g_old_rec.default_code_comb_id
      ,p_employment_category_o
          => per_asg_shd.g_old_rec.employment_category
      ,p_frequency_o
          => per_asg_shd.g_old_rec.frequency
      ,p_internal_address_line_o
          => per_asg_shd.g_old_rec.internal_address_line
      ,p_manager_flag_o
          => per_asg_shd.g_old_rec.manager_flag
      ,p_normal_hours_o
          => per_asg_shd.g_old_rec.normal_hours
      ,p_perf_review_period_o
          => per_asg_shd.g_old_rec.perf_review_period
      ,p_perf_review_period_frequen_o
          => per_asg_shd.g_old_rec.perf_review_period_frequency
      ,p_period_of_service_id_o
          => per_asg_shd.g_old_rec.period_of_service_id
      ,p_probation_period_o
          => per_asg_shd.g_old_rec.probation_period
      ,p_probation_unit_o
          => per_asg_shd.g_old_rec.probation_unit
      ,p_sal_review_period_o
          => per_asg_shd.g_old_rec.sal_review_period
      ,p_sal_review_period_frequen_o
          => per_asg_shd.g_old_rec.sal_review_period_frequency
      ,p_set_of_books_id_o
          => per_asg_shd.g_old_rec.set_of_books_id
      ,p_source_type_o
          => per_asg_shd.g_old_rec.source_type
      ,p_time_normal_finish_o
          => per_asg_shd.g_old_rec.time_normal_finish
      ,p_time_normal_start_o
          => per_asg_shd.g_old_rec.time_normal_start
      ,p_bargaining_unit_code_o
          => per_asg_shd.g_old_rec.bargaining_unit_code
      ,p_labour_union_member_flag_o
          => per_asg_shd.g_old_rec.labour_union_member_flag
      ,p_hourly_salaried_code_o
          => per_asg_shd.g_old_rec.hourly_salaried_code
      ,p_request_id_o
          => per_asg_shd.g_old_rec.request_id
      ,p_program_application_id_o
          => per_asg_shd.g_old_rec.program_application_id
      ,p_program_id_o
          => per_asg_shd.g_old_rec.program_id
      ,p_program_update_date_o
          => per_asg_shd.g_old_rec.program_update_date
      ,p_ass_attribute_category_o
          => per_asg_shd.g_old_rec.ass_attribute_category
      ,p_ass_attribute1_o
          => per_asg_shd.g_old_rec.ass_attribute1
      ,p_ass_attribute2_o
          => per_asg_shd.g_old_rec.ass_attribute2
      ,p_ass_attribute3_o
          => per_asg_shd.g_old_rec.ass_attribute3
      ,p_ass_attribute4_o
          => per_asg_shd.g_old_rec.ass_attribute4
      ,p_ass_attribute5_o
          => per_asg_shd.g_old_rec.ass_attribute5
      ,p_ass_attribute6_o
          => per_asg_shd.g_old_rec.ass_attribute6
      ,p_ass_attribute7_o
          => per_asg_shd.g_old_rec.ass_attribute7
      ,p_ass_attribute8_o
          => per_asg_shd.g_old_rec.ass_attribute8
      ,p_ass_attribute9_o
          => per_asg_shd.g_old_rec.ass_attribute9
      ,p_ass_attribute10_o
          => per_asg_shd.g_old_rec.ass_attribute10
      ,p_ass_attribute11_o
          => per_asg_shd.g_old_rec.ass_attribute11
      ,p_ass_attribute12_o
          => per_asg_shd.g_old_rec.ass_attribute12
      ,p_ass_attribute13_o
          => per_asg_shd.g_old_rec.ass_attribute13
      ,p_ass_attribute14_o
          => per_asg_shd.g_old_rec.ass_attribute14
      ,p_ass_attribute15_o
          => per_asg_shd.g_old_rec.ass_attribute15
      ,p_ass_attribute16_o
          => per_asg_shd.g_old_rec.ass_attribute16
      ,p_ass_attribute17_o
          => per_asg_shd.g_old_rec.ass_attribute17
      ,p_ass_attribute18_o
          => per_asg_shd.g_old_rec.ass_attribute18
      ,p_ass_attribute19_o
          => per_asg_shd.g_old_rec.ass_attribute19
      ,p_ass_attribute20_o
          => per_asg_shd.g_old_rec.ass_attribute20
      ,p_ass_attribute21_o
          => per_asg_shd.g_old_rec.ass_attribute21
      ,p_ass_attribute22_o
          => per_asg_shd.g_old_rec.ass_attribute22
      ,p_ass_attribute23_o
          => per_asg_shd.g_old_rec.ass_attribute23
      ,p_ass_attribute24_o
          => per_asg_shd.g_old_rec.ass_attribute24
      ,p_ass_attribute25_o
          => per_asg_shd.g_old_rec.ass_attribute25
      ,p_ass_attribute26_o
          => per_asg_shd.g_old_rec.ass_attribute26
      ,p_ass_attribute27_o
          => per_asg_shd.g_old_rec.ass_attribute27
      ,p_ass_attribute28_o
          => per_asg_shd.g_old_rec.ass_attribute28
      ,p_ass_attribute29_o
          => per_asg_shd.g_old_rec.ass_attribute29
      ,p_ass_attribute30_o
          => per_asg_shd.g_old_rec.ass_attribute30
      ,p_title_o
          => per_asg_shd.g_old_rec.title
      ,p_contract_id_o
          => per_asg_shd.g_old_rec.contract_id
      ,p_establishment_id_o
          => per_asg_shd.g_old_rec.establishment_id
      ,p_collective_agreement_id_o
          => per_asg_shd.g_old_rec.collective_agreement_id
      ,p_cagr_grade_def_id_o
          => per_asg_shd.g_old_rec.cagr_grade_def_id
      ,p_cagr_id_flex_num_o
          => per_asg_shd.g_old_rec.cagr_id_flex_num
      ,p_object_version_number_o
          => per_asg_shd.g_old_rec.object_version_number
      ,p_notice_period_o
          => per_asg_shd.g_old_rec.notice_period
      ,p_notice_period_uom_o
          => per_asg_shd.g_old_rec.notice_period_uom
      ,p_employee_category_o
          => per_asg_shd.g_old_rec.employee_category
      ,p_work_at_home_o
          => per_asg_shd.g_old_rec.work_at_home
      ,p_job_post_source_name_o
          => per_asg_shd.g_old_rec.job_post_source_name
      ,p_posting_content_id_o
          => per_asg_shd.g_old_rec.posting_content_id
      ,p_placement_date_start_o
          => per_asg_shd.g_old_rec.period_of_placement_date_start
      ,p_vendor_id_o
          => per_asg_shd.g_old_rec.vendor_id
      ,p_vendor_employee_number_o
          => per_asg_shd.g_old_rec.vendor_employee_number
      ,p_vendor_assignment_number_o
          => per_asg_shd.g_old_rec.vendor_assignment_number
      ,p_assignment_category_o
          => per_asg_shd.g_old_rec.assignment_category
      ,p_project_title_o
          => per_asg_shd.g_old_rec.project_title
      ,p_applicant_rank_o
          => per_asg_shd.g_old_rec.applicant_rank
      ,p_grade_ladder_pgm_id_o
          => per_asg_shd.g_old_rec.grade_ladder_pgm_id
      ,p_supervisor_assignment_id_o
          => per_asg_shd.g_old_rec.supervisor_assignment_id
      ,p_vendor_site_id_o
          => per_asg_shd.g_old_rec.vendor_site_id
      ,p_po_header_id_o
          => per_asg_shd.g_old_rec.po_header_id
      ,p_po_line_id_o
          => per_asg_shd.g_old_rec.po_line_id
      ,p_projected_assignment_end_o
          => per_asg_shd.g_old_rec.projected_assignment_end
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_ALL_ASSIGNMENTS_F'
        ,p_hook_type   => 'AD'
        );
  end;
  -- End of API User Hook for post_delete.
  --
  -- Temporary hardcoded hook added for pay object group functionality. Will
  -- replace by proper hook when dynamic triggers for assignments converted
  -- to package dynamic triggers.
  --
hr_utility.trace('ovn: '||to_char(p_rec.object_version_number));
  pay_pog_all_assignments_pkg.after_delete
  (p_effective_date               => p_effective_date
  ,p_datetrack_mode               => p_datetrack_mode
  ,p_validation_start_date        => p_validation_start_date
  ,p_validation_end_date          => p_validation_end_date
  ,P_ASSIGNMENT_ID                => p_rec.assignment_id
  ,P_EFFECTIVE_END_DATE           => p_rec.effective_end_date
  ,P_EFFECTIVE_START_DATE         => p_rec.effective_start_date
  ,P_OBJECT_VERSION_NUMBER        => p_rec.object_version_number
  ,P_ORG_NOW_NO_MANAGER_WARNING   => p_org_now_no_manager_warning
  ,P_APPLICANT_RANK_O             => per_asg_shd.g_old_rec.applicant_rank
  ,P_APPLICATION_ID_O             => per_asg_shd.g_old_rec.application_id
  ,P_ASSIGNMENT_CATEGORY_O        => per_asg_shd.g_old_rec.assignment_category
  ,P_ASSIGNMENT_NUMBER_O          => per_asg_shd.g_old_rec.assignment_number
  ,P_ASSIGNMENT_SEQUENCE_O        => per_asg_shd.g_old_rec.assignment_sequence
  ,P_ASSIGNMENT_STATUS_TYPE_ID_O  => per_asg_shd.g_old_rec.assignment_status_type_id
  ,P_ASSIGNMENT_TYPE_O            => per_asg_shd.g_old_rec.assignment_type
  ,P_ASS_ATTRIBUTE1_O             => per_asg_shd.g_old_rec.ass_attribute1
  ,P_ASS_ATTRIBUTE10_O            => per_asg_shd.g_old_rec.ass_attribute10
  ,P_ASS_ATTRIBUTE11_O            => per_asg_shd.g_old_rec.ass_attribute11
  ,P_ASS_ATTRIBUTE12_O            => per_asg_shd.g_old_rec.ass_attribute12
  ,P_ASS_ATTRIBUTE13_O            => per_asg_shd.g_old_rec.ass_attribute13
  ,P_ASS_ATTRIBUTE14_O            => per_asg_shd.g_old_rec.ass_attribute14
  ,P_ASS_ATTRIBUTE15_O            => per_asg_shd.g_old_rec.ass_attribute15
  ,P_ASS_ATTRIBUTE16_O            => per_asg_shd.g_old_rec.ass_attribute16
  ,P_ASS_ATTRIBUTE17_O            => per_asg_shd.g_old_rec.ass_attribute17
  ,P_ASS_ATTRIBUTE18_O            => per_asg_shd.g_old_rec.ass_attribute18
  ,P_ASS_ATTRIBUTE19_O            => per_asg_shd.g_old_rec.ass_attribute19
  ,P_ASS_ATTRIBUTE2_O             => per_asg_shd.g_old_rec.ass_attribute2
  ,P_ASS_ATTRIBUTE20_O            => per_asg_shd.g_old_rec.ass_attribute20
  ,P_ASS_ATTRIBUTE21_O            => per_asg_shd.g_old_rec.ass_attribute21
  ,P_ASS_ATTRIBUTE22_O            => per_asg_shd.g_old_rec.ass_attribute22
  ,P_ASS_ATTRIBUTE23_O            => per_asg_shd.g_old_rec.ass_attribute23
  ,P_ASS_ATTRIBUTE24_O            => per_asg_shd.g_old_rec.ass_attribute24
  ,P_ASS_ATTRIBUTE25_O            => per_asg_shd.g_old_rec.ass_attribute25
  ,P_ASS_ATTRIBUTE26_O            => per_asg_shd.g_old_rec.ass_attribute26
  ,P_ASS_ATTRIBUTE27_O            => per_asg_shd.g_old_rec.ass_attribute27
  ,P_ASS_ATTRIBUTE28_O            => per_asg_shd.g_old_rec.ass_attribute28
  ,P_ASS_ATTRIBUTE29_O            => per_asg_shd.g_old_rec.ass_attribute29
  ,P_ASS_ATTRIBUTE3_O             => per_asg_shd.g_old_rec.ass_attribute3
  ,P_ASS_ATTRIBUTE30_O            => per_asg_shd.g_old_rec.ass_attribute30
  ,P_ASS_ATTRIBUTE4_O             => per_asg_shd.g_old_rec.ass_attribute4
  ,P_ASS_ATTRIBUTE5_O             => per_asg_shd.g_old_rec.ass_attribute5
  ,P_ASS_ATTRIBUTE6_O             => per_asg_shd.g_old_rec.ass_attribute6
  ,P_ASS_ATTRIBUTE7_O             => per_asg_shd.g_old_rec.ass_attribute7
  ,P_ASS_ATTRIBUTE8_O             => per_asg_shd.g_old_rec.ass_attribute8
  ,P_ASS_ATTRIBUTE9_O             => per_asg_shd.g_old_rec.ass_attribute9
  ,P_ASS_ATTRIBUTE_CATEGORY_O     => per_asg_shd.g_old_rec.ass_attribute_category
  ,P_BARGAINING_UNIT_CODE_O       => per_asg_shd.g_old_rec.bargaining_unit_code
  ,P_BUSINESS_GROUP_ID_O          => per_asg_shd.g_old_rec.business_group_id
  ,P_CAGR_GRADE_DEF_ID_O          => per_asg_shd.g_old_rec.cagr_grade_def_id
  ,P_CAGR_ID_FLEX_NUM_O           => per_asg_shd.g_old_rec.cagr_id_flex_num
  ,P_CHANGE_REASON_O              => per_asg_shd.g_old_rec.change_reason
  ,P_COLLECTIVE_AGREEMENT_ID_O    => per_asg_shd.g_old_rec.collective_agreement_id
  ,P_COMMENT_ID_O                 => per_asg_shd.g_old_rec.comment_id
  ,P_CONTRACT_ID_O                => per_asg_shd.g_old_rec.contract_id
  ,P_DATE_PROBATION_END_O         => per_asg_shd.g_old_rec.date_probation_end --fix for bug 5108658
  ,P_DEFAULT_CODE_COMB_ID_O       => per_asg_shd.g_old_rec.default_code_comb_id
  ,P_EFFECTIVE_END_DATE_O         => per_asg_shd.g_old_rec.effective_end_date
  ,P_EFFECTIVE_START_DATE_O       => per_asg_shd.g_old_rec.effective_start_date
  ,P_EMPLOYEE_CATEGORY_O          => per_asg_shd.g_old_rec.employee_category
  ,P_EMPLOYMENT_CATEGORY_O        => per_asg_shd.g_old_rec.employment_category
  ,P_ESTABLISHMENT_ID_O           => per_asg_shd.g_old_rec.establishment_id
  ,P_FREQUENCY_O                  => per_asg_shd.g_old_rec.frequency
  ,P_GRADE_ID_O                   => per_asg_shd.g_old_rec.grade_id
  ,P_HOURLY_SALARIED_CODE_O       => per_asg_shd.g_old_rec.hourly_salaried_code
  ,P_INTERNAL_ADDRESS_LINE_O      => per_asg_shd.g_old_rec.internal_address_line
  ,P_JOB_ID_O                     => per_asg_shd.g_old_rec.job_id
  ,P_JOB_POST_SOURCE_NAME_O       => per_asg_shd.g_old_rec.job_post_source_name
  ,P_LABOUR_UNION_MEMBER_FLAG_O   => per_asg_shd.g_old_rec.labour_union_member_flag
  ,P_LOCATION_ID_O                => per_asg_shd.g_old_rec.location_id
  ,P_MANAGER_FLAG_O               => per_asg_shd.g_old_rec.manager_flag
  ,P_NORMAL_HOURS_O               => per_asg_shd.g_old_rec.normal_hours
  ,P_NOTICE_PERIOD_O              => per_asg_shd.g_old_rec.notice_period
  ,P_NOTICE_PERIOD_UOM_O          => per_asg_shd.g_old_rec.notice_period_uom
  ,P_OBJECT_VERSION_NUMBER_O      => per_asg_shd.g_old_rec.object_version_number
  ,P_ORGANIZATION_ID_O            => per_asg_shd.g_old_rec.organization_id
  ,P_PAYROLL_ID_O                 => per_asg_shd.g_old_rec.payroll_id
  ,P_PAY_BASIS_ID_O               => per_asg_shd.g_old_rec.pay_basis_id
  ,P_PEOPLE_GROUP_ID_O            => per_asg_shd.g_old_rec.people_group_id
  ,P_PERF_REVIEW_PERIOD_O         => per_asg_shd.g_old_rec.perf_review_period
  ,P_PERF_REVIEW_PERIOD_FREQUEN_O => per_asg_shd.g_old_rec.perf_review_period_frequency
  ,P_PERIOD_OF_SERVICE_ID_O       => per_asg_shd.g_old_rec.period_of_service_id
  ,P_PERSON_ID_O                  => per_asg_shd.g_old_rec.person_id
  ,P_PERSON_REFERRED_BY_ID_O      => per_asg_shd.g_old_rec.person_referred_by_id
  ,P_PLACEMENT_DATE_START_O       => per_asg_shd.g_old_rec.period_of_placement_date_start
  ,P_POSITION_ID_O                => per_asg_shd.g_old_rec.position_id
  ,P_POSTING_CONTENT_ID_O         => per_asg_shd.g_old_rec.posting_content_id
  ,P_PRIMARY_FLAG_O               => per_asg_shd.g_old_rec.primary_flag
  ,P_PROBATION_PERIOD_O           => per_asg_shd.g_old_rec.probation_period
  ,P_PROBATION_UNIT_O             => per_asg_shd.g_old_rec.probation_unit
  ,P_PROGRAM_APPLICATION_ID_O     => per_asg_shd.g_old_rec.program_application_id
  ,P_PROGRAM_ID_O                 => per_asg_shd.g_old_rec.program_id
  ,P_PROGRAM_UPDATE_DATE_O        => per_asg_shd.g_old_rec.program_update_date
  ,P_PROJECT_TITLE_O              => per_asg_shd.g_old_rec.project_title
  ,P_RECRUITER_ID_O               => per_asg_shd.g_old_rec.recruiter_id
  ,P_RECRUITMENT_ACTIVITY_ID_O    => per_asg_shd.g_old_rec.recruitment_activity_id
  ,P_REQUEST_ID_O                 => per_asg_shd.g_old_rec.request_id
  ,P_SAL_REVIEW_PERIOD_O          => per_asg_shd.g_old_rec.sal_review_period
  ,P_SAL_REVIEW_PERIOD_FREQUEN_O  => per_asg_shd.g_old_rec.sal_review_period_frequency
  ,P_SET_OF_BOOKS_ID_O            => per_asg_shd.g_old_rec.set_of_books_id
  ,P_SOFT_CODING_KEYFLEX_ID_O     => per_asg_shd.g_old_rec.soft_coding_keyflex_id
  ,P_SOURCE_ORGANIZATION_ID_O     => per_asg_shd.g_old_rec.source_organization_id
  ,P_SOURCE_TYPE_O                => per_asg_shd.g_old_rec.source_type
  ,P_SPECIAL_CEILING_STEP_ID_O    => per_asg_shd.g_old_rec.special_ceiling_step_id
  ,P_SUPERVISOR_ID_O              => per_asg_shd.g_old_rec.supervisor_id
  ,P_TIME_NORMAL_FINISH_O         => per_asg_shd.g_old_rec.time_normal_finish
  ,P_TIME_NORMAL_START_O          => per_asg_shd.g_old_rec.time_normal_start
  ,P_TITLE_O                      => per_asg_shd.g_old_rec.title
  ,P_VACANCY_ID_O                 => per_asg_shd.g_old_rec.vacancy_id
  ,P_VENDOR_ASSIGNMENT_NUMBER_O   => per_asg_shd.g_old_rec.vendor_assignment_number
  ,P_VENDOR_EMPLOYEE_NUMBER_O     => per_asg_shd.g_old_rec.vendor_employee_number
  ,P_VENDOR_ID_O                  => per_asg_shd.g_old_rec.vendor_id
  ,P_WORK_AT_HOME_O               => per_asg_shd.g_old_rec.work_at_home
  ,P_GRADE_LADDER_PGM_ID_O        => per_asg_shd.g_old_rec.grade_ladder_pgm_id
  ,P_SUPERVISOR_ASSIGNMENT_ID_O   => per_asg_shd.g_old_rec.supervisor_assignment_id
  ,P_VENDOR_SITE_ID_O             => per_asg_shd.g_old_rec.vendor_site_id
  ,P_PO_HEADER_ID_O               => per_asg_shd.g_old_rec.po_header_id
  ,P_PO_LINE_ID_O                 => per_asg_shd.g_old_rec.po_line_id
  ,P_PROJECTED_ASSIGNMENT_END_O   => per_asg_shd.g_old_rec.projected_assignment_end
  );
 -- Call to Workflow Sync Procedure For Assignments
    per_pqh_shr.per_asg_wf_sync('POST_DELETE',
                            p_rec,
                            per_asg_shd.g_old_rec.position_id,
                            p_effective_date,
                            p_validation_start_date,
                            p_validation_end_date,
                            p_datetrack_mode);

  -- End of call to Workflow Sync Procedure For Assignments
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec                             in  out nocopy     per_asg_shd.g_rec_type,
  p_effective_date                  in  date,
  p_effective_start_date            OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE,
  p_effective_end_date              OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE,
  --  p_validation_start_date       out nocopy    date,
  --  p_validation_end_date         out nocopy    date,
  p_datetrack_mode                  in  varchar2,
  p_validate                        in  boolean default false,
  p_org_now_no_manager_warning      out nocopy boolean,
  p_loc_change_tax_issues           OUT nocopy boolean,
  p_delete_asg_budgets              OUT nocopy boolean,
  p_element_salary_warning          OUT nocopy boolean,
  p_element_entries_warning         OUT nocopy boolean,
  p_spp_warning                     OUT nocopy boolean,
  P_cost_warning                    OUT nocopy Boolean,
  p_life_events_exists   	    OUT nocopy Boolean,
  p_cobra_coverage_elements         OUT nocopy Boolean,
  p_assgt_term_elements             OUT nocopy Boolean
  ) is
--
  l_proc                       varchar2(72) := g_package||'del';
  l_validation_start_date      date;
  l_validation_end_date        date;
  l_org_now_no_manager_warning boolean;
  l_loc_change_tax_issues      boolean; --4888485 , all declarations below are new
  l_delete_asg_budgets         boolean;
  l_element_salary_warning     boolean;
  l_element_entries_warning    boolean;
  l_spp_warning                boolean;
  l_cost_warning               boolean;
  l_life_events_exists         boolean;
  l_cobra_coverage_elements    boolean;
  l_assgt_term_elements        boolean;
  l_new_prim_ass_id	       number;
  l_prim_change_flag	       varchar2(1);
  l_new_end_date               date;
  l_new_primary_flag           varchar2(20);
  l_new_primary_ass_id         number;
  l_primary_change_flag        varchar2(20);
  l_s_pay_id                   number;
  l_cancel_atd                 date;
  l_cancel_lspd                date;
  l_reterm_atd                 date;
  l_reterm_lspd                date;
  l_appl_asg_new_end_date      date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack delete mode is valid
  --
  dt_api.validate_dt_del_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT del_per_asg;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  per_asg_shd.lck
    (p_effective_date     => p_effective_date,
           p_datetrack_mode     => p_datetrack_mode,
           p_assignment_id     => p_rec.assignment_id,
           p_object_version_number => p_rec.object_version_number,
           p_validation_start_date => l_validation_start_date,
           p_validation_end_date     => l_validation_end_date);
  --
  -- Call the supporting delete validate operation
  --
  -- 4888485 -- Modified the following call and added new API out params.
  --
  per_asg_bus1.delete_validate
    (p_rec                        => p_rec,
     p_effective_date             => p_effective_date,
     p_datetrack_mode             => p_datetrack_mode,
     p_validation_start_date      => l_validation_start_date,
     p_validation_end_date        => l_validation_end_date,
     p_org_now_no_manager_warning => l_org_now_no_manager_warning,
     p_loc_change_tax_issues      => l_loc_change_tax_issues,
     p_delete_asg_budgets         => l_delete_asg_budgets,
     p_element_salary_warning     => l_element_salary_warning,
     p_element_entries_warning    => l_element_entries_warning,
     p_spp_warning                => l_spp_warning,
     P_cost_warning               => l_cost_warning,
     p_life_events_exists   	  => l_life_events_exists,
     p_cobra_coverage_elements    => l_cobra_coverage_elements,
     p_assgt_term_elements        => l_assgt_term_elements,
     ---
     p_new_prim_ass_id            => l_new_prim_ass_id,
     p_prim_change_flag           => l_prim_change_flag,
     p_new_end_date               => l_new_end_date,
     p_new_primary_flag           => l_new_primary_flag,
     p_s_pay_id                   => l_s_pay_id,
     p_cancel_atd                 => l_cancel_atd,
     p_cancel_lspd                => l_cancel_lspd,
     p_reterm_atd                 => l_reterm_atd,
     p_reterm_lspd                => l_reterm_lspd,
     ---
     p_appl_asg_new_end_date      => l_appl_asg_new_end_date);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete
    (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  -- Delete the row.
  --
  delete_dml
    (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  -- Call the supporting post-delete operation
  --
  -- 4888485 -- Modified post_delete call and added new out params.
  --
  post_delete
    (p_rec                        => p_rec,
     p_effective_date             => p_effective_date,
     p_datetrack_mode             => p_datetrack_mode,
     p_validation_start_date      => l_validation_start_date,
     p_validation_end_date        => l_validation_end_date,
     p_org_now_no_manager_warning => l_org_now_no_manager_warning,
     p_loc_change_tax_issues      => l_loc_change_tax_issues,
     p_delete_asg_budgets         => l_delete_asg_budgets,
     p_element_salary_warning     => l_element_salary_warning,
     p_element_entries_warning    => l_element_entries_warning,
     p_spp_warning                => l_spp_warning,
     P_cost_warning               => l_cost_warning,
     p_life_events_exists   	  => l_life_events_exists,
     p_cobra_coverage_elements    => l_cobra_coverage_elements,
     p_assgt_term_elements        => l_assgt_term_elements,
     ---
     p_new_prim_ass_id            => l_new_prim_ass_id,
     p_prim_change_flag           => l_prim_change_flag,
     p_new_end_date               => l_new_end_date,
     p_new_primary_flag           => l_new_primary_flag,
     p_s_pay_id                   => l_s_pay_id,
     p_cancel_atd                 => l_cancel_atd,
     p_cancel_lspd                => l_cancel_lspd,
     p_reterm_atd                 => l_reterm_atd,
     p_reterm_lspd                => l_reterm_lspd,
     ---
     p_appl_asg_new_end_date      => l_appl_asg_new_end_date );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Set validation start, end dates and org_now_no_manager_warning
  --
--4888485
--  p_validation_start_date    := l_validation_start_date;
--  p_validation_end_date      := l_validation_end_date;
  p_effective_start_date       := l_validation_start_date;
  p_effective_end_date         := l_validation_end_date;
  p_org_now_no_manager_warning := l_org_now_no_manager_warning;
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO del_per_asg;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_validate                     IN     boolean default false
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date               IN     DATE
  ,p_datetrack_mode               IN     VARCHAR2
  ,p_object_version_number        IN OUT NOCOPY per_all_assignments_f.object_version_number%TYPE
  ,p_effective_start_date            OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
  ,p_loc_change_tax_issues           OUT NOCOPY boolean
  ,p_delete_asg_budgets              OUT NOCOPY boolean
  ,p_org_now_no_manager_warning      OUT NOCOPY boolean
  ,p_element_salary_warning          OUT NOCOPY boolean
  ,p_element_entries_warning         OUT NOCOPY boolean
  ,p_spp_warning                     OUT NOCOPY boolean
  ,P_cost_warning                    OUT NOCOPY Boolean
  ,p_life_events_exists   	     OUT NOCOPY Boolean
  ,p_cobra_coverage_elements         OUT NOCOPY Boolean
  ,p_assgt_term_elements             OUT NOCOPY Boolean
  )  is
--
  l_rec        per_asg_shd.g_rec_type;
  l_proc       varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.assignment_id             := p_assignment_id;
  l_rec.object_version_number     := p_object_version_number;
  --
  -- Having converted the arguments into the per_asg_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec,
      p_effective_date,
      p_effective_start_date,
      p_effective_end_date,
--      p_validation_start_date,
--      p_validation_end_date,
      p_datetrack_mode,
      p_validate,
      p_org_now_no_manager_warning,
      p_loc_change_tax_issues,
      p_delete_asg_budgets,
      p_element_salary_warning,
      p_element_entries_warning,
      p_spp_warning,
      p_cost_warning,
      p_life_events_exists,
      p_cobra_coverage_elements,
      p_assgt_term_elements);
  --
  -- Set the out arguments
  --

  -- 4888485
  p_object_version_number := l_rec.object_version_number;
  p_effective_start_date  := l_rec.effective_start_date;
  p_effective_end_date    := l_rec.effective_end_date;
  --  p_business_group_id     := per_asg_shd.g_old_rec.business_group_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_assignment_id              in  number,
  p_effective_start_date       out nocopy date,
  p_effective_end_date         out nocopy date,
  p_business_group_id          out nocopy number,
  p_object_version_number      in  out nocopy number,
  p_effective_date             in  date,
  p_validation_start_date      out nocopy date,
  p_validation_end_date        out nocopy date,
  p_datetrack_mode             in  varchar2,
  p_validate                   in  boolean default false,
  p_org_now_no_manager_warning out nocopy boolean
  ) is
--
  l_rec         per_asg_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'del';
  l_loc_change_tax_issues       boolean;
  l_delete_asg_budgets          boolean;  -- addded the new loc vars -- 4888485
  l_element_salary_warning      boolean;
  l_element_entries_warning     boolean;
  l_spp_warning                 boolean;
  l_cost_warning                boolean;
  l_life_events_exists          boolean;
  l_cobra_coverage_elements     boolean;
  l_assgt_term_elements         boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  del(p_validate,
      p_assignment_id,
      p_effective_date,
      p_datetrack_mode,
      p_object_version_number,
      p_effective_start_date,
      p_effective_end_date,
      --      p_validation_start_date,
      --      p_validation_end_date,
      l_loc_change_tax_issues,
      l_delete_asg_budgets,
      p_org_now_no_manager_warning,
      l_element_salary_warning,
      l_element_entries_warning,
      l_spp_warning,
      l_cost_warning,
      l_life_events_exists,
      l_cobra_coverage_elements,
      l_assgt_term_elements);
  --
  p_validation_start_date := p_effective_start_date;
  p_validation_end_date   := p_effective_end_date;
  --Added for 5012244
  p_business_group_id     := per_asg_shd.g_old_rec.business_group_id;
  --
  hr_utility.set_location('Leaving'||l_proc, 25);
End del;
--
end per_asg_del;

/

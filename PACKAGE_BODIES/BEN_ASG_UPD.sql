--------------------------------------------------------
--  DDL for Package Body BEN_ASG_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ASG_UPD" as
/* $Header: beasgrhi.pkb 120.0.12010000.3 2008/08/25 13:43:54 ppentapa ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  ben_asg_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_update_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of dml from the datetrack mode
--   of CORRECTION only. It is important to note that the object version
--   number is only increment by 1 because the datetrack correction is
--   soley for one datetracked row.
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1) Get the next object_version_number.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the
--   update_dml procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_dml
    (p_rec              in out nocopy per_asg_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc    varchar2(72) := g_package||'dt_update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode = 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
      (p_base_table_name    => 'per_all_assignments_f',
       p_base_key_column    => 'assignment_id',
       p_base_key_value    => p_rec.assignment_id);
    --
    per_asg_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the per_all_assignments_f Row
    --
    update  per_all_assignments_f
    set
    assignment_id                   = p_rec.assignment_id,
    recruiter_id                    = p_rec.recruiter_id,
    grade_id                        = p_rec.grade_id,
    position_id                     = p_rec.position_id,
    job_id                          = p_rec.job_id,
    assignment_status_type_id       = p_rec.assignment_status_type_id,
    payroll_id                      = p_rec.payroll_id,
    location_id                     = p_rec.location_id,
    person_referred_by_id           = p_rec.person_referred_by_id,
    supervisor_id                   = p_rec.supervisor_id,
    special_ceiling_step_id         = p_rec.special_ceiling_step_id,
    recruitment_activity_id         = p_rec.recruitment_activity_id,
    source_organization_id          = p_rec.source_organization_id,
    organization_id                 = p_rec.organization_id,
    people_group_id                 = p_rec.people_group_id,
    soft_coding_keyflex_id          = p_rec.soft_coding_keyflex_id,
    vacancy_id                      = p_rec.vacancy_id,
    pay_basis_id                    = p_rec.pay_basis_id,
    application_id                  = p_rec.application_id,
    assignment_number               = p_rec.assignment_number,
    change_reason                   = p_rec.change_reason,
    comment_id                      = p_rec.comment_id,
    date_probation_end              = p_rec.date_probation_end,
    default_code_comb_id            = p_rec.default_code_comb_id,
    employment_category             = p_rec.employment_category,
    frequency                       = p_rec.frequency,
    internal_address_line           = p_rec.internal_address_line,
    manager_flag                    = p_rec.manager_flag,
    normal_hours                    = p_rec.normal_hours,
    perf_review_period              = p_rec.perf_review_period,
    perf_review_period_frequency    = p_rec.perf_review_period_frequency,
    probation_period                = p_rec.probation_period,
    probation_unit                  = p_rec.probation_unit,
    sal_review_period               = p_rec.sal_review_period,
    sal_review_period_frequency     = p_rec.sal_review_period_frequency,
    set_of_books_id                 = p_rec.set_of_books_id,
    source_type                     = p_rec.source_type,
    time_normal_finish              = p_rec.time_normal_finish,
    time_normal_start               = p_rec.time_normal_start,
    bargaining_unit_code            = p_rec.bargaining_unit_code,
    labour_union_member_flag        = p_rec.labour_union_member_flag,
    hourly_salaried_code            = p_rec.hourly_salaried_code,
    request_id                      = p_rec.request_id,
    program_application_id          = p_rec.program_application_id,
    program_id                      = p_rec.program_id,
    program_update_date             = p_rec.program_update_date,
    ass_attribute_category          = p_rec.ass_attribute_category,
    ass_attribute1                  = p_rec.ass_attribute1,
    ass_attribute2                  = p_rec.ass_attribute2,
    ass_attribute3                  = p_rec.ass_attribute3,
    ass_attribute4                  = p_rec.ass_attribute4,
    ass_attribute5                  = p_rec.ass_attribute5,
    ass_attribute6                  = p_rec.ass_attribute6,
    ass_attribute7                  = p_rec.ass_attribute7,
    ass_attribute8                  = p_rec.ass_attribute8,
    ass_attribute9                  = p_rec.ass_attribute9,
    ass_attribute10                 = p_rec.ass_attribute10,
    ass_attribute11                 = p_rec.ass_attribute11,
    ass_attribute12                 = p_rec.ass_attribute12,
    ass_attribute13                 = p_rec.ass_attribute13,
    ass_attribute14                 = p_rec.ass_attribute14,
    ass_attribute15                 = p_rec.ass_attribute15,
    ass_attribute16                 = p_rec.ass_attribute16,
    ass_attribute17                 = p_rec.ass_attribute17,
    ass_attribute18                 = p_rec.ass_attribute18,
    ass_attribute19                 = p_rec.ass_attribute19,
    ass_attribute20                 = p_rec.ass_attribute20,
    ass_attribute21                 = p_rec.ass_attribute21,
    ass_attribute22                 = p_rec.ass_attribute22,
    ass_attribute23                 = p_rec.ass_attribute23,
    ass_attribute24                 = p_rec.ass_attribute24,
    ass_attribute25                 = p_rec.ass_attribute25,
    ass_attribute26                 = p_rec.ass_attribute26,
    ass_attribute27                 = p_rec.ass_attribute27,
    ass_attribute28                 = p_rec.ass_attribute28,
    ass_attribute29                 = p_rec.ass_attribute29,
    ass_attribute30                 = p_rec.ass_attribute30,
    title                           = p_rec.title,
    object_version_number           = p_rec.object_version_number ,
    contract_id                     = p_rec.contract_id,
    establishment_id                = p_rec.establishment_id,
    collective_agreement_id         = p_rec.collective_agreement_id,
    cagr_grade_def_id               = p_rec.cagr_grade_def_id,
    cagr_id_flex_num                = p_rec.cagr_id_flex_num,
    notice_period           = p_rec.notice_period,
    notice_period_uom           = p_rec.notice_period_uom,
    employee_category           = p_rec.employee_category,
    work_at_home            = p_rec.work_at_home,
    job_post_source_name        = p_rec.job_post_source_name,
    posting_content_id              = p_rec.posting_content_id,
    period_of_placement_date_start  = p_rec.period_of_placement_date_start,
    vendor_id                       = p_rec.vendor_id,
    vendor_employee_number          = p_rec.vendor_employee_number,
    vendor_assignment_number        = p_rec.vendor_assignment_number,
    assignment_category             = p_rec.assignment_category,
    project_title                   = p_rec.project_title,
    applicant_rank                  = p_rec.applicant_rank
    where   assignment_id           = p_rec.assignment_id
    and     effective_start_date    = p_validation_start_date
    and     effective_end_date      = p_validation_end_date;
    --
    per_asg_shd.g_api_dml := false;   -- Unset the api dml status
    --
    -- Set the effective start and end dates
    --
    p_rec.effective_start_date := p_validation_start_date;
    p_rec.effective_end_date   := p_validation_end_date;
  End If;
--
hr_utility.set_location(' Leaving:'||l_proc, 15);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_asg_shd.g_api_dml := false;   -- Unset the api dml status
    per_asg_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_asg_shd.g_api_dml := false;   -- Unset the api dml status
    per_asg_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_asg_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_update_dml control logic which handles
--   the actual datetrack dml.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
    (p_rec              in out nocopy per_asg_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc    varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_update_dml(p_rec            => p_rec,
        p_effective_date    => p_effective_date,
        p_datetrack_mode    => p_datetrack_mode,
               p_validation_start_date    => p_validation_start_date,
        p_validation_end_date    => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_update >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_update procedure controls the execution
--   of dml for the datetrack modes of: UPDATE, UPDATE_OVERRIDE
--   and UPDATE_CHANGE_INSERT only. The execution required is as
--   follows:
--
--   1) Providing the datetrack update mode is not 'CORRECTION'
--      then set the effective end date of the current row (this
--      will be the validation_start_date - 1).
--   2) If the datetrack mode is 'UPDATE_OVERRIDE' then call the
--      corresponding delete_dml process to delete any future rows
--      where the effective_start_date is greater than or equal to
--    the validation_start_date.
--   3) Call the insert_dml process to insert the new updated row
--      details..
--
-- Pre Conditions:
--   This is an internal procedure which is called from the
--   pre_update procedure.
--
-- In Arguments:
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
Procedure dt_pre_update
    (p_rec              in out nocopy    per_asg_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc              varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number  number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Update the current effective end date
    --
    per_asg_shd.upd_effective_end_date
     (p_effective_date           => p_effective_date,
      p_base_key_value           => p_rec.assignment_id,
      p_new_effective_end_date => (p_validation_start_date - 1),
      p_validation_start_date  => p_validation_start_date,
      p_validation_end_date    => p_validation_end_date,
      p_object_version_number  => l_dummy_version_number);
    --
    If (p_datetrack_mode = 'UPDATE_OVERRIDE') then
      hr_utility.set_location(l_proc, 15);
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      per_asg_del.delete_dml
        (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
    End If;
    hr_utility.set_location(l_proc, 20);
    --
    -- We must now insert the updated row
    --
    ben_asg_ins.insert_dml
      (p_rec            => p_rec,
       p_effective_date        => p_effective_date,
       p_datetrack_mode        => p_datetrack_mode,
       p_validation_start_date    => p_validation_start_date,
       p_validation_end_date    => p_validation_end_date);
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End dt_pre_update;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_update_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
    (p_rec              in out nocopy    per_asg_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc    varchar2(72) := g_package||'pre_update';
  l_rowid       varchar2(72);
  l_eed         date;
  l_esd         date;
--
  Cursor csr_rowid is
     select rowid, effective_start_date, effective_end_date
     from per_all_assignments_f
     where assignment_id = p_rec.assignment_id
     and p_effective_date between
         effective_start_date and effective_end_date;
--
  cursor csr_rowid_u is
     select rowid
     from per_all_assignments_f
     where assignment_id = p_rec.assignment_id
     and p_effective_date -1 between
         effective_start_date and effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Insert the comment text if comments exist
  --
  If (p_rec.comment_text is not null and p_rec.comment_id is null) then
    hr_comm_api.ins(p_comment_id        => p_rec.comment_id,
                    p_source_table_name => 'PER_ALL_ASSIGNMENTS_F',
                    p_comment_text      => p_rec.comment_text);
  -- Update the comments if they have changed
  ElsIf (p_rec.comment_id is not null and p_rec.comment_text <>
         per_asg_shd.g_old_rec.comment_text) then
    hr_comm_api.upd(p_comment_id        => p_rec.comment_id,
                    p_source_table_name => 'PER_ALL_ASSIGNMENTS_F',
                    p_comment_text      => p_rec.comment_text);
  End If;
  hr_utility.set_location(l_proc, 10);
  --
  -- Generate date probation end
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_DATE_PROBATION_END c,e and f
  -- Rule CHK_PROBATION_PERIOD c
  -- Rule CHK_PROBATION_UNIT d
  --
  per_asg_bus2.gen_date_probation_end
    (p_assignment_id         =>  p_rec.assignment_id
    ,p_effective_date        =>  P_effective_date
    ,p_probation_unit        =>  p_rec.probation_unit
    ,p_probation_period      =>  p_rec.probation_period
    ,p_validation_start_date =>  p_validation_start_date
    ,p_object_version_number =>  p_rec.object_version_number
    ,p_date_probation_end    =>  p_rec.date_probation_end
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  dt_pre_update
    (p_rec                    => p_rec,
     p_effective_date         => p_effective_date,
     p_datetrack_mode         => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
  --
  -- Check for DT mode, if correction use current values
  -- else use values from currently existing record.
  --
  if p_datetrack_mode <> 'CORRECTION' then
     open csr_rowid_u;
     fetch csr_rowid_u into l_rowid;
     close csr_rowid_u;
     l_esd := p_rec.effective_start_date;
     l_eed := p_rec.effective_end_date;
  else
     open csr_rowid;
     fetch csr_rowid into l_rowid, l_esd, l_eed;
     close csr_rowid;
  end if;
  --
  ben_asg_ins.g_trgr_loc_chg := FALSE; --Bug 2666342

  ben_dt_trgr_handle.assignment
    (p_rowid                   => l_rowid
    ,p_assignment_id           => p_rec.assignment_id
    ,p_business_group_id       => p_rec.business_group_id
    ,p_person_id               => p_rec.person_id
    ,p_effective_start_date    => l_esd
    ,p_effective_end_date      => l_eed
    ,p_assignment_status_type_id  => p_rec.assignment_status_type_id
    ,p_assignment_type         => p_rec.assignment_type
    ,p_organization_id         => p_rec.organization_id
    ,p_primary_flag            => p_rec.primary_flag
    ,p_change_reason           => p_rec.change_reason
    ,p_employment_category     => p_rec.employment_category
    ,p_frequency               => p_rec.frequency
    ,p_grade_id                => p_rec.grade_id
    ,p_job_id                  => p_rec.job_id
    ,p_position_id             => p_rec.position_id
    ,p_location_id             => p_rec.location_id
    ,p_normal_hours            => p_rec.normal_hours
    ,p_payroll_id              => p_rec.payroll_id
    ,p_pay_basis_id            => p_rec.pay_basis_id
    ,p_bargaining_unit_code    => p_rec.bargaining_unit_code
    ,p_labour_union_member_flag => p_rec.labour_union_member_flag
    ,p_hourly_salaried_code    => p_rec.hourly_salaried_code
    ,p_people_group_id    => p_rec.people_group_id
    ,p_ass_attribute1 => p_rec.ass_attribute1
    ,p_ass_attribute2 => p_rec.ass_attribute2
    ,p_ass_attribute3 => p_rec.ass_attribute3
    ,p_ass_attribute4 => p_rec.ass_attribute4
    ,p_ass_attribute5 => p_rec.ass_attribute5
    ,p_ass_attribute6 => p_rec.ass_attribute6
    ,p_ass_attribute7 => p_rec.ass_attribute7
    ,p_ass_attribute8 => p_rec.ass_attribute8
    ,p_ass_attribute9 => p_rec.ass_attribute9
    ,p_ass_attribute10 => p_rec.ass_attribute10
    ,p_ass_attribute11 => p_rec.ass_attribute11
    ,p_ass_attribute12 => p_rec.ass_attribute12
    ,p_ass_attribute13 => p_rec.ass_attribute13
    ,p_ass_attribute14 => p_rec.ass_attribute14
    ,p_ass_attribute15 => p_rec.ass_attribute15
    ,p_ass_attribute16 => p_rec.ass_attribute16
    ,p_ass_attribute17 => p_rec.ass_attribute17
    ,p_ass_attribute18 => p_rec.ass_attribute18
    ,p_ass_attribute19 => p_rec.ass_attribute19
    ,p_ass_attribute20 => p_rec.ass_attribute20
    ,p_ass_attribute21 => p_rec.ass_attribute21
    ,p_ass_attribute22 => p_rec.ass_attribute22
    ,p_ass_attribute23 => p_rec.ass_attribute23
    ,p_ass_attribute24 => p_rec.ass_attribute24
    ,p_ass_attribute25 => p_rec.ass_attribute25
    ,p_ass_attribute26 => p_rec.ass_attribute26
    ,p_ass_attribute27 => p_rec.ass_attribute27
    ,p_ass_attribute28 => p_rec.ass_attribute28
    ,p_ass_attribute29 => p_rec.ass_attribute29
    ,p_ass_attribute30 => p_rec.ass_attribute30
    );

    -- Reset the variable after checking for Assignment LEs
    ben_asg_ins.g_trgr_loc_chg := TRUE;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
    (p_rec                    in per_asg_shd.g_rec_type,
     p_effective_date           in date,
     p_datetrack_mode           in varchar2,
     p_validation_start_date       in date,
     p_validation_end_date           in date,
         p_payroll_id_updated          in boolean,
         p_other_manager_warning       in boolean,
         p_hourly_salaried_warning     in boolean,
         p_no_managers_warning         in boolean,
         p_org_now_no_manager_warning  in boolean) is
--
  l_proc    varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_update.
  begin
    per_asg_rku.after_update
      (p_effective_date                 => p_effective_date
      ,p_datetrack_mode                 => p_datetrack_mode
      ,p_validation_start_date          => p_validation_start_date
      ,p_validation_end_date            => p_validation_end_date
      ,p_assignment_id                  => p_rec.assignment_id
      ,p_effective_start_date           => p_rec.effective_start_date
      ,p_effective_end_date             => p_rec.effective_end_date
      ,p_recruiter_id                   => p_rec.recruiter_id
      ,p_grade_id                       => p_rec.grade_id
      ,p_position_id                    => p_rec.position_id
      ,p_job_id                         => p_rec.job_id
      ,p_assignment_status_type_id      => p_rec.assignment_status_type_id
      ,p_payroll_id                     => p_rec.payroll_id
      ,p_location_id                    => p_rec.location_id
      ,p_person_referred_by_id          => p_rec.person_referred_by_id
      ,p_supervisor_id                  => p_rec.supervisor_id
      ,p_special_ceiling_step_id        => p_rec.special_ceiling_step_id
      ,p_recruitment_activity_id        => p_rec.recruitment_activity_id
      ,p_source_organization_id         => p_rec.source_organization_id
      ,p_organization_id                => p_rec.organization_id
      ,p_people_group_id                => p_rec.people_group_id
      ,p_soft_coding_keyflex_id         => p_rec.soft_coding_keyflex_id
      ,p_vacancy_id                     => p_rec.vacancy_id
      ,p_pay_basis_id                   => p_rec.pay_basis_id
      ,p_assignment_type                => p_rec.assignment_type
      ,p_primary_flag                   => p_rec.primary_flag
      ,p_application_id                 => p_rec.application_id
      ,p_assignment_number              => p_rec.assignment_number
      ,p_change_reason                  => p_rec.change_reason
      ,p_comment_id                     => p_rec.comment_id
      ,p_comments                       => p_rec.comment_text
      ,p_date_probation_end             => p_rec.date_probation_end
      ,p_default_code_comb_id           => p_rec.default_code_comb_id
      ,p_employment_category            => p_rec.employment_category
      ,p_frequency                      => p_rec.frequency
      ,p_internal_address_line          => p_rec.internal_address_line
      ,p_manager_flag                   => p_rec.manager_flag
      ,p_normal_hours                   => p_rec.normal_hours
      ,p_perf_review_period             => p_rec.perf_review_period
      ,p_perf_review_period_frequen     => p_rec.perf_review_period_frequency
      ,p_period_of_service_id           => p_rec.period_of_service_id
      ,p_probation_period               => p_rec.probation_period
      ,p_probation_unit                 => p_rec.probation_unit
      ,p_sal_review_period              => p_rec.sal_review_period
      ,p_sal_review_period_frequen      => p_rec.sal_review_period_frequency
      ,p_set_of_books_id                => p_rec.set_of_books_id
      ,p_source_type                    => p_rec.source_type
      ,p_time_normal_finish             => p_rec.time_normal_finish
      ,p_time_normal_start              => p_rec.time_normal_start
      ,p_bargaining_unit_code           => p_rec.bargaining_unit_code
      ,p_labour_union_member_flag       => p_rec.labour_union_member_flag
      ,p_hourly_salaried_code           => p_rec.hourly_salaried_code
      ,p_request_id                     => p_rec.request_id
      ,p_program_application_id         => p_rec.program_application_id
      ,p_program_id                     => p_rec.program_id
      ,p_program_update_date            => p_rec.program_update_date
      ,p_ass_attribute_category         => p_rec.ass_attribute_category
      ,p_ass_attribute1                 => p_rec.ass_attribute1
      ,p_ass_attribute2                 => p_rec.ass_attribute2
      ,p_ass_attribute3                 => p_rec.ass_attribute3
      ,p_ass_attribute4                 => p_rec.ass_attribute4
      ,p_ass_attribute5                 => p_rec.ass_attribute5
      ,p_ass_attribute6                 => p_rec.ass_attribute6
      ,p_ass_attribute7                 => p_rec.ass_attribute7
      ,p_ass_attribute8                 => p_rec.ass_attribute8
      ,p_ass_attribute9                 => p_rec.ass_attribute9
      ,p_ass_attribute10                => p_rec.ass_attribute10
      ,p_ass_attribute11                => p_rec.ass_attribute11
      ,p_ass_attribute12                => p_rec.ass_attribute12
      ,p_ass_attribute13                => p_rec.ass_attribute13
      ,p_ass_attribute14                => p_rec.ass_attribute14
      ,p_ass_attribute15                => p_rec.ass_attribute15
      ,p_ass_attribute16                => p_rec.ass_attribute16
      ,p_ass_attribute17                => p_rec.ass_attribute17
      ,p_ass_attribute18                => p_rec.ass_attribute18
      ,p_ass_attribute19                => p_rec.ass_attribute19
      ,p_ass_attribute20                => p_rec.ass_attribute20
      ,p_ass_attribute21                => p_rec.ass_attribute21
      ,p_ass_attribute22                => p_rec.ass_attribute22
      ,p_ass_attribute23                => p_rec.ass_attribute23
      ,p_ass_attribute24                => p_rec.ass_attribute24
      ,p_ass_attribute25                => p_rec.ass_attribute25
      ,p_ass_attribute26                => p_rec.ass_attribute26
      ,p_ass_attribute27                => p_rec.ass_attribute27
      ,p_ass_attribute28                => p_rec.ass_attribute28
      ,p_ass_attribute29                => p_rec.ass_attribute29
      ,p_ass_attribute30                => p_rec.ass_attribute30
      ,p_title                          => p_rec.title
      ,p_contract_id                    => p_rec.contract_id
      ,p_establishment_id               => p_rec.establishment_id
      ,p_collective_agreement_id        => p_rec.collective_agreement_id
      ,p_cagr_grade_def_id              => p_rec.cagr_grade_def_id
      ,p_cagr_id_flex_num               => p_rec.cagr_id_flex_num
      ,p_object_version_number          => p_rec.object_version_number
      ,p_payroll_id_updated             => p_payroll_id_updated
      ,p_other_manager_warning          => p_other_manager_warning
      ,p_hourly_salaried_warning        => p_hourly_salaried_warning
      ,p_no_managers_warning            => p_no_managers_warning
      ,p_org_now_no_manager_warning     => p_org_now_no_manager_warning
      ,p_notice_period              => p_rec.notice_period
      ,p_notice_period_uom      => p_rec.notice_period_uom
      ,p_employee_category      => p_rec.employee_category
      ,p_work_at_home           => p_rec.work_at_home
      ,p_job_post_source_name       => p_rec.job_post_source_name
      ,p_posting_content_id             => p_rec.posting_content_id
      ,p_placement_date_start => p_rec.period_of_placement_date_start
      ,p_vendor_id                      => p_rec.vendor_id
      ,p_vendor_employee_number         => p_rec.vendor_employee_number
      ,p_vendor_assignment_number       => p_rec.vendor_assignment_number
      ,p_assignment_category            => p_rec.assignment_category
      ,p_project_title                  => p_rec.project_title
      ,p_applicant_rank                 => p_rec.applicant_rank
      ,p_grade_ladder_pgm_id            => p_rec.grade_ladder_pgm_id
      ,p_supervisor_assignment_id       => p_rec.supervisor_assignment_id     /*Bug 2976136*/
      ,p_vendor_site_id                 => p_rec.vendor_site_id
      ,p_po_header_id                   => p_rec.po_header_id
      ,p_po_line_id                     => p_rec.po_line_id
      ,p_projected_assignment_end       => p_rec.projected_assignment_end
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
      ,p_assignment_sequence_o
          => per_asg_shd.g_old_rec.assignment_sequence
      ,p_pay_basis_id_o
          => per_asg_shd.g_old_rec.pay_basis_id
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
          => per_asg_shd.g_old_rec.supervisor_assignment_id   /*Bug 2976136*/
      ,p_vendor_site_id_o                 => per_asg_shd.g_old_rec.vendor_site_id
      ,p_po_header_id_o                   => per_asg_shd.g_old_rec.po_header_id
      ,p_po_line_id_o                     => per_asg_shd.g_old_rec.po_line_id
      ,p_projected_assignment_end_o       => per_asg_shd.g_old_rec.projected_assignment_end

       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_ALL_ASSIGNMENTS_F'
        ,p_hook_type   => 'AU'
        );
  end;
  -- End of API User Hook for post_update.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding argument value for update. When
--   we attempt to update a row through the Upd business process , certain
--   arguments can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd business process to determine which attributes
--   have NOT been specified we need to check if the argument has a reserved
--   system default value. Therefore, for all attributes which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Pre Conditions:
--   This private procedure can only be called from the upd process.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted argument
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy per_asg_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    per_asg_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.recruiter_id = hr_api.g_number) then
    p_rec.recruiter_id :=
    per_asg_shd.g_old_rec.recruiter_id;
  End If;
  If (p_rec.grade_id = hr_api.g_number) then
    p_rec.grade_id :=
    per_asg_shd.g_old_rec.grade_id;
  End If;
  If (p_rec.position_id = hr_api.g_number) then
    p_rec.position_id :=
    per_asg_shd.g_old_rec.position_id;
  End If;
  If (p_rec.job_id = hr_api.g_number) then
    p_rec.job_id :=
    per_asg_shd.g_old_rec.job_id;
  End If;
  If (p_rec.assignment_status_type_id = hr_api.g_number) then
    p_rec.assignment_status_type_id :=
    per_asg_shd.g_old_rec.assignment_status_type_id;
  End If;
  If (p_rec.payroll_id = hr_api.g_number) then
    p_rec.payroll_id :=
    per_asg_shd.g_old_rec.payroll_id;
  End If;
  If (p_rec.location_id = hr_api.g_number) then
    p_rec.location_id :=
    per_asg_shd.g_old_rec.location_id;
  End If;
  If (p_rec.person_referred_by_id = hr_api.g_number) then
    p_rec.person_referred_by_id :=
    per_asg_shd.g_old_rec.person_referred_by_id;
  End If;
  If (p_rec.supervisor_id = hr_api.g_number) then
    p_rec.supervisor_id :=
    per_asg_shd.g_old_rec.supervisor_id;
  End If;
  If (p_rec.special_ceiling_step_id = hr_api.g_number) then
    p_rec.special_ceiling_step_id :=
    per_asg_shd.g_old_rec.special_ceiling_step_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    per_asg_shd.g_old_rec.person_id;
  End If;
  If (p_rec.recruitment_activity_id = hr_api.g_number) then
    p_rec.recruitment_activity_id :=
    per_asg_shd.g_old_rec.recruitment_activity_id;
  End If;
  If (p_rec.source_organization_id = hr_api.g_number) then
    p_rec.source_organization_id :=
    per_asg_shd.g_old_rec.source_organization_id;
  End If;
  If (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    per_asg_shd.g_old_rec.organization_id;
  End If;
  If (p_rec.people_group_id = hr_api.g_number) then
    p_rec.people_group_id :=
    per_asg_shd.g_old_rec.people_group_id;
  End If;
  If (p_rec.soft_coding_keyflex_id = hr_api.g_number) then
    p_rec.soft_coding_keyflex_id :=
    per_asg_shd.g_old_rec.soft_coding_keyflex_id;
  End If;
  If (p_rec.vacancy_id = hr_api.g_number) then
    p_rec.vacancy_id :=
    per_asg_shd.g_old_rec.vacancy_id;
  End If;
  If (p_rec.pay_basis_id = hr_api.g_number) then
    p_rec.pay_basis_id :=
    per_asg_shd.g_old_rec.pay_basis_id;
  End If;
  If (p_rec.assignment_sequence = hr_api.g_number) then
    p_rec.assignment_sequence :=
    per_asg_shd.g_old_rec.assignment_sequence;
  End If;
  If (p_rec.assignment_type = hr_api.g_varchar2) then
    p_rec.assignment_type :=
    per_asg_shd.g_old_rec.assignment_type;
  End If;
  If (p_rec.primary_flag = hr_api.g_varchar2) then
    p_rec.primary_flag :=
    per_asg_shd.g_old_rec.primary_flag;
  End If;
  If (p_rec.application_id = hr_api.g_number) then
    p_rec.application_id :=
    per_asg_shd.g_old_rec.application_id;
  End If;
  If (p_rec.assignment_number = hr_api.g_varchar2) then
    p_rec.assignment_number :=
    per_asg_shd.g_old_rec.assignment_number;
  End If;
  If (p_rec.change_reason = hr_api.g_varchar2) then
    p_rec.change_reason :=
    per_asg_shd.g_old_rec.change_reason;
  End If;
  If (p_rec.comment_id = hr_api.g_number) then
    p_rec.comment_id :=
    per_asg_shd.g_old_rec.comment_id;
  End If;
  If (p_rec.comment_text = hr_api.g_varchar2) then
    p_rec.comment_text :=
    per_asg_shd.g_old_rec.comment_text;
  End If;
  If (p_rec.date_probation_end = hr_api.g_date) then
    p_rec.date_probation_end :=
    per_asg_shd.g_old_rec.date_probation_end;
  End If;
  If (p_rec.default_code_comb_id = hr_api.g_number) then
    p_rec.default_code_comb_id :=
    per_asg_shd.g_old_rec.default_code_comb_id;
  End If;
  If (p_rec.employment_category = hr_api.g_varchar2) then
    p_rec.employment_category :=
    per_asg_shd.g_old_rec.employment_category;
  End If;
  If (p_rec.frequency = hr_api.g_varchar2) then
    p_rec.frequency :=
    per_asg_shd.g_old_rec.frequency;
  End If;
  If (p_rec.internal_address_line = hr_api.g_varchar2) then
    p_rec.internal_address_line :=
    per_asg_shd.g_old_rec.internal_address_line;
  End If;
  If (p_rec.manager_flag = hr_api.g_varchar2) then
    p_rec.manager_flag :=
    per_asg_shd.g_old_rec.manager_flag;
  End If;
  If (p_rec.normal_hours = hr_api.g_number) then
    p_rec.normal_hours :=
    per_asg_shd.g_old_rec.normal_hours;
  End If;
  If (p_rec.perf_review_period = hr_api.g_number) then
    p_rec.perf_review_period :=
    per_asg_shd.g_old_rec.perf_review_period;
  End If;
  If (p_rec.perf_review_period_frequency = hr_api.g_varchar2) then
    p_rec.perf_review_period_frequency :=
    per_asg_shd.g_old_rec.perf_review_period_frequency;
  End If;
  If (p_rec.period_of_service_id = hr_api.g_number) then
    p_rec.period_of_service_id :=
    per_asg_shd.g_old_rec.period_of_service_id;
  End If;
  If (p_rec.probation_period = hr_api.g_number) then
    p_rec.probation_period :=
    per_asg_shd.g_old_rec.probation_period;
  End If;
  If (p_rec.probation_unit = hr_api.g_varchar2) then
    p_rec.probation_unit :=
    per_asg_shd.g_old_rec.probation_unit;
  End If;
  If (p_rec.sal_review_period = hr_api.g_number) then
    p_rec.sal_review_period :=
    per_asg_shd.g_old_rec.sal_review_period;
  End If;
  If (p_rec.sal_review_period_frequency = hr_api.g_varchar2) then
    p_rec.sal_review_period_frequency :=
    per_asg_shd.g_old_rec.sal_review_period_frequency;
  End If;
  If (p_rec.set_of_books_id = hr_api.g_number) then
    p_rec.set_of_books_id :=
    per_asg_shd.g_old_rec.set_of_books_id;
  End If;
  If (p_rec.source_type = hr_api.g_varchar2) then
    p_rec.source_type :=
    per_asg_shd.g_old_rec.source_type;
  End If;
  If (p_rec.time_normal_finish = hr_api.g_varchar2) then
    p_rec.time_normal_finish :=
    per_asg_shd.g_old_rec.time_normal_finish;
  End If;
  If (p_rec.time_normal_start = hr_api.g_varchar2) then
    p_rec.time_normal_start :=
    per_asg_shd.g_old_rec.time_normal_start;
  End If;
  If (p_rec.bargaining_unit_code = hr_api.g_varchar2) then
    p_rec.bargaining_unit_code :=
    per_asg_shd.g_old_rec.bargaining_unit_code;
  End If;
  If (p_rec.labour_union_member_flag = hr_api.g_varchar2) then
    p_rec.labour_union_member_flag :=
    per_asg_shd.g_old_rec.labour_union_member_flag;
  End If;
  If (p_rec.hourly_salaried_code = hr_api.g_varchar2) then
    p_rec.hourly_salaried_code :=
    per_asg_shd.g_old_rec.hourly_salaried_code;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    per_asg_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    per_asg_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    per_asg_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    per_asg_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.ass_attribute_category = hr_api.g_varchar2) then
    p_rec.ass_attribute_category :=
    per_asg_shd.g_old_rec.ass_attribute_category;
  End If;
  If (p_rec.ass_attribute1 = hr_api.g_varchar2) then
    p_rec.ass_attribute1 :=
    per_asg_shd.g_old_rec.ass_attribute1;
  End If;
  If (p_rec.ass_attribute2 = hr_api.g_varchar2) then
    p_rec.ass_attribute2 :=
    per_asg_shd.g_old_rec.ass_attribute2;
  End If;
  If (p_rec.ass_attribute3 = hr_api.g_varchar2) then
    p_rec.ass_attribute3 :=
    per_asg_shd.g_old_rec.ass_attribute3;
  End If;
  If (p_rec.ass_attribute4 = hr_api.g_varchar2) then
    p_rec.ass_attribute4 :=
    per_asg_shd.g_old_rec.ass_attribute4;
  End If;
  If (p_rec.ass_attribute5 = hr_api.g_varchar2) then
    p_rec.ass_attribute5 :=
    per_asg_shd.g_old_rec.ass_attribute5;
  End If;
  If (p_rec.ass_attribute6 = hr_api.g_varchar2) then
    p_rec.ass_attribute6 :=
    per_asg_shd.g_old_rec.ass_attribute6;
  End If;
  If (p_rec.ass_attribute7 = hr_api.g_varchar2) then
    p_rec.ass_attribute7 :=
    per_asg_shd.g_old_rec.ass_attribute7;
  End If;
  If (p_rec.ass_attribute8 = hr_api.g_varchar2) then
    p_rec.ass_attribute8 :=
    per_asg_shd.g_old_rec.ass_attribute8;
  End If;
  If (p_rec.ass_attribute9 = hr_api.g_varchar2) then
    p_rec.ass_attribute9 :=
    per_asg_shd.g_old_rec.ass_attribute9;
  End If;
  If (p_rec.ass_attribute10 = hr_api.g_varchar2) then
    p_rec.ass_attribute10 :=
    per_asg_shd.g_old_rec.ass_attribute10;
  End If;
  If (p_rec.ass_attribute11 = hr_api.g_varchar2) then
    p_rec.ass_attribute11 :=
    per_asg_shd.g_old_rec.ass_attribute11;
  End If;
  If (p_rec.ass_attribute12 = hr_api.g_varchar2) then
    p_rec.ass_attribute12 :=
    per_asg_shd.g_old_rec.ass_attribute12;
  End If;
  If (p_rec.ass_attribute13 = hr_api.g_varchar2) then
    p_rec.ass_attribute13 :=
    per_asg_shd.g_old_rec.ass_attribute13;
  End If;
  If (p_rec.ass_attribute14 = hr_api.g_varchar2) then
    p_rec.ass_attribute14 :=
    per_asg_shd.g_old_rec.ass_attribute14;
  End If;
  If (p_rec.ass_attribute15 = hr_api.g_varchar2) then
    p_rec.ass_attribute15 :=
    per_asg_shd.g_old_rec.ass_attribute15;
  End If;
  If (p_rec.ass_attribute16 = hr_api.g_varchar2) then
    p_rec.ass_attribute16 :=
    per_asg_shd.g_old_rec.ass_attribute16;
  End If;
  If (p_rec.ass_attribute17 = hr_api.g_varchar2) then
    p_rec.ass_attribute17 :=
    per_asg_shd.g_old_rec.ass_attribute17;
  End If;
  If (p_rec.ass_attribute18 = hr_api.g_varchar2) then
    p_rec.ass_attribute18 :=
    per_asg_shd.g_old_rec.ass_attribute18;
  End If;
  If (p_rec.ass_attribute19 = hr_api.g_varchar2) then
    p_rec.ass_attribute19 :=
    per_asg_shd.g_old_rec.ass_attribute19;
  End If;
  If (p_rec.ass_attribute20 = hr_api.g_varchar2) then
    p_rec.ass_attribute20 :=
    per_asg_shd.g_old_rec.ass_attribute20;
  End If;
  If (p_rec.ass_attribute21 = hr_api.g_varchar2) then
    p_rec.ass_attribute21 :=
    per_asg_shd.g_old_rec.ass_attribute21;
  End If;
  If (p_rec.ass_attribute22 = hr_api.g_varchar2) then
    p_rec.ass_attribute22 :=
    per_asg_shd.g_old_rec.ass_attribute22;
  End If;
  If (p_rec.ass_attribute23 = hr_api.g_varchar2) then
    p_rec.ass_attribute23 :=
    per_asg_shd.g_old_rec.ass_attribute23;
  End If;
  If (p_rec.ass_attribute24 = hr_api.g_varchar2) then
    p_rec.ass_attribute24 :=
    per_asg_shd.g_old_rec.ass_attribute24;
  End If;
  If (p_rec.ass_attribute25 = hr_api.g_varchar2) then
    p_rec.ass_attribute25 :=
    per_asg_shd.g_old_rec.ass_attribute25;
  End If;
  If (p_rec.ass_attribute26 = hr_api.g_varchar2) then
    p_rec.ass_attribute26 :=
    per_asg_shd.g_old_rec.ass_attribute26;
  End If;
  If (p_rec.ass_attribute27 = hr_api.g_varchar2) then
    p_rec.ass_attribute27 :=
    per_asg_shd.g_old_rec.ass_attribute27;
  End If;
  If (p_rec.ass_attribute28 = hr_api.g_varchar2) then
    p_rec.ass_attribute28 :=
    per_asg_shd.g_old_rec.ass_attribute28;
  End If;
  If (p_rec.ass_attribute29 = hr_api.g_varchar2) then
    p_rec.ass_attribute29 :=
    per_asg_shd.g_old_rec.ass_attribute29;
  End If;
  If (p_rec.ass_attribute30 = hr_api.g_varchar2) then
    p_rec.ass_attribute30 :=
    per_asg_shd.g_old_rec.ass_attribute30;
  End If;
  If (p_rec.title = hr_api.g_varchar2) then
    p_rec.title :=
    per_asg_shd.g_old_rec.title;
  End If;
 If (p_rec.contract_id = hr_api.g_number) then
    p_rec.contract_id :=
    per_asg_shd.g_old_rec.contract_id;
  End If;
 If (p_rec.establishment_id = hr_api.g_number) then
    p_rec.establishment_id :=
    per_asg_shd.g_old_rec.establishment_id;
  End If;
 If (p_rec.collective_agreement_id = hr_api.g_number) then
    p_rec.collective_agreement_id :=
    per_asg_shd.g_old_rec.collective_agreement_id;
  End If;
 If (p_rec.cagr_grade_def_id = hr_api.g_number) then
    p_rec.cagr_grade_def_id :=
    per_asg_shd.g_old_rec.cagr_grade_def_id;
  End If;
 If (p_rec.cagr_id_flex_num = hr_api.g_number) then
    p_rec.cagr_id_flex_num :=
    per_asg_shd.g_old_rec.cagr_id_flex_num;
  End If;
 If (p_rec.notice_period = hr_api.g_number) then
    p_rec.notice_period :=
    per_asg_shd.g_old_rec.notice_period;
  End If;
 If (p_rec.notice_period_uom = hr_api.g_varchar2) then
    p_rec.notice_period_uom :=
    per_asg_shd.g_old_rec.notice_period_uom;
  End If;
 If (p_rec.employee_category = hr_api.g_varchar2) then
    p_rec.employee_category :=
    per_asg_shd.g_old_rec.employee_category;
  End If;
 If (p_rec.work_at_home = hr_api.g_varchar2) then
    p_rec.work_at_home :=
    per_asg_shd.g_old_rec.work_at_home;
  End If;
 If (p_rec.job_post_source_name = hr_api.g_varchar2) then
    p_rec.job_post_source_name :=
    per_asg_shd.g_old_rec.job_post_source_name;
  End If;
 If (p_rec.posting_content_id = hr_api.g_number) then
    p_rec.posting_content_id :=
    per_asg_shd.g_old_rec.posting_content_id;
  End If;
 If (p_rec.period_of_placement_date_start = hr_api.g_date) then
    p_rec.period_of_placement_date_start :=
    per_asg_shd.g_old_rec.period_of_placement_date_start;
  End If;
 If (p_rec.vendor_id = hr_api.g_number) then
    p_rec.vendor_id :=
    per_asg_shd.g_old_rec.vendor_id;
  End If;
 If (p_rec.vendor_employee_number = hr_api.g_varchar2) then
    p_rec.vendor_employee_number :=
    per_asg_shd.g_old_rec.vendor_employee_number;
  End If;
 If (p_rec.vendor_assignment_number = hr_api.g_varchar2) then
    p_rec.vendor_assignment_number :=
    per_asg_shd.g_old_rec.vendor_assignment_number;
  End If;
 If (p_rec.assignment_category = hr_api.g_varchar2) then
    p_rec.assignment_category :=
    per_asg_shd.g_old_rec.assignment_category;
  End If;
 If (p_rec.project_title = hr_api.g_varchar2) then
    p_rec.project_title :=
    per_asg_shd.g_old_rec.project_title;
  End If;

  If (p_rec.applicant_rank = hr_api.g_number) then
      p_rec.applicant_rank :=
      per_asg_shd.g_old_rec.applicant_rank;
  End If;
  --

  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec                    in out nocopy     per_asg_shd.g_rec_type,
  p_effective_date            in     date,
  p_datetrack_mode            in     varchar2,
  p_validation_start_date       out nocopy     date,
  p_validation_end_date         out nocopy     date,
  p_validate                in     boolean default false,
  p_payroll_id_updated          out nocopy     boolean,
  p_other_manager_warning       out nocopy     boolean,
  p_hourly_salaried_warning     out nocopy     boolean,
  p_no_managers_warning         out nocopy     boolean,
  p_org_now_no_manager_warning  out nocopy     boolean
  ) is
--
  l_proc            varchar2(72) := g_package||'upd';
  l_validation_start_date    date;
  l_validation_end_date        date;
  l_inv_pos_grade_warning       boolean;
  l_payroll_id_updated          boolean;
  l_other_manager_warning       boolean;
  l_hourly_salaried_warning       boolean;
  l_no_managers_warning         boolean;
  l_org_now_no_manager_warning  boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT upd_ben_asg;
    --
  End If;
  --
  -- We must lock the row which we need to update.
  --
  per_asg_shd.lck
    (p_effective_date     => p_effective_date,
           p_datetrack_mode     => p_datetrack_mode,
           p_assignment_id     => p_rec.assignment_id,
           p_object_version_number => p_rec.object_version_number,
           p_validation_start_date => l_validation_start_date,
           p_validation_end_date     => l_validation_end_date
        );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  convert_defs(p_rec);

  /*
  --
  -- Removed validations for default benefits assignment
  --
  -- 2. Call the supporting update validate operations.
  --
  per_asg_bus1.update_validate
    (p_rec                  => p_rec,
     p_effective_date          => p_effective_date,
     p_datetrack_mode            => p_datetrack_mode,
     p_validation_start_date      => l_validation_start_date,
     p_validation_end_date          => l_validation_end_date,
         p_payroll_id_updated         => l_payroll_id_updated,
         p_other_manager_warning      => p_other_manager_warning,
         p_hourly_salaried_warning    => p_hourly_salaried_warning,
         p_no_managers_warning        => p_no_managers_warning,
         p_org_now_no_manager_warning => p_org_now_no_manager_warning,
         p_inv_pos_grade_warning      => l_inv_pos_grade_warning);
   */

  --
  -- Check Business Group
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);

  --
  -- Generate / Check Assignment Number
  --
  per_asg_bus1.gen_chk_assignment_number
    (p_assignment_id          =>  p_rec.assignment_id
    ,p_business_group_id      =>  p_rec.business_group_id
    ,p_assignment_type        =>  p_rec.assignment_type
    ,p_assignment_sequence    =>  p_rec.assignment_sequence
    ,p_assignment_number      =>  p_rec.assignment_number
    ,p_person_id              =>  p_rec.person_id
    ,p_effective_date         =>  p_effective_date
    ,p_object_version_number  =>  p_rec.object_version_number
    );

  --
  -- Call the supporting pre-update operation
  --
  pre_update
    (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  -- Update the row.
  --
  update_dml
    (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  -- Call the supporting post-update operation
  --
  post_update
    (p_rec                  => p_rec,
     p_effective_date          => p_effective_date,
     p_datetrack_mode          => p_datetrack_mode,
     p_validation_start_date      => l_validation_start_date,
     p_validation_end_date          => l_validation_end_date,
         p_payroll_id_updated         => l_payroll_id_updated,
         p_other_manager_warning      => l_other_manager_warning,
         p_hourly_salaried_warning      => l_hourly_salaried_warning,
         p_no_managers_warning        => l_no_managers_warning,
         p_org_now_no_manager_warning => l_org_now_no_manager_warning);
  --
  -- Set validation start and end dates
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  -- Set other output arguments
  --
  p_payroll_id_updated         := l_payroll_id_updated;
  --p_other_manager_warning      := l_other_manager_warning;
  --p_no_managers_warning        := l_no_managers_warning;
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
    ROLLBACK TO upd_ben_asg;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_assignment_id                in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,

  p_business_group_id            out nocopy number,
  p_recruiter_id                 in number           default hr_api.g_number,
  p_grade_id                     in number           default hr_api.g_number,
  p_position_id                  in number           default hr_api.g_number,
  p_job_id                       in number           default hr_api.g_number,
  p_assignment_status_type_id    in number           default hr_api.g_number,
  p_payroll_id                   in number           default hr_api.g_number,
  p_location_id                  in number           default hr_api.g_number,
  p_person_referred_by_id        in number           default hr_api.g_number,
  p_supervisor_id                in number           default hr_api.g_number,
  p_special_ceiling_step_id      in number           default hr_api.g_number,
  p_recruitment_activity_id      in number           default hr_api.g_number,
  p_source_organization_id       in number           default hr_api.g_number,

  p_organization_id              in number           default hr_api.g_number,
  p_people_group_id              in number           default hr_api.g_number,
  p_soft_coding_keyflex_id       in number           default hr_api.g_number,
  p_vacancy_id                   in number           default hr_api.g_number,
  p_pay_basis_id                 in number           default hr_api.g_number,
  p_assignment_type              in varchar2         default hr_api.g_varchar2,
  p_primary_flag                 in varchar2         default hr_api.g_varchar2,
  p_application_id               in number           default hr_api.g_number,
  p_assignment_number            in varchar2         default hr_api.g_varchar2,
  p_change_reason                in varchar2         default hr_api.g_varchar2,
  p_comment_id                   out nocopy number,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_date_probation_end           in date             default hr_api.g_date,

  p_default_code_comb_id         in number           default hr_api.g_number,
  p_employment_category          in varchar2         default hr_api.g_varchar2,
  p_frequency                    in varchar2         default hr_api.g_varchar2,
  p_internal_address_line        in varchar2         default hr_api.g_varchar2,
  p_manager_flag                 in varchar2         default hr_api.g_varchar2,
  p_normal_hours                 in number           default hr_api.g_number,
  p_perf_review_period           in number           default hr_api.g_number,
  p_perf_review_period_frequency in varchar2         default hr_api.g_varchar2,
  p_period_of_service_id         in number           default hr_api.g_number,
  p_probation_period             in number           default hr_api.g_number,
  p_probation_unit               in varchar2         default hr_api.g_varchar2,
  p_sal_review_period            in number           default hr_api.g_number,
  p_sal_review_period_frequency  in varchar2         default hr_api.g_varchar2,
  p_set_of_books_id              in number           default hr_api.g_number,

  p_source_type                  in varchar2         default hr_api.g_varchar2,
  p_time_normal_finish           in varchar2         default hr_api.g_varchar2,
  p_time_normal_start            in varchar2         default hr_api.g_varchar2,
  p_bargaining_unit_code         in varchar2         default hr_api.g_varchar2,
  p_labour_union_member_flag     in varchar2         default hr_api.g_varchar2,
  p_hourly_salaried_code         in varchar2         default hr_api.g_varchar2,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_ass_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_ass_attribute1               in varchar2         default hr_api.g_varchar2,
  p_ass_attribute2               in varchar2         default hr_api.g_varchar2,
  p_ass_attribute3               in varchar2         default hr_api.g_varchar2,
  p_ass_attribute4               in varchar2         default hr_api.g_varchar2,
  p_ass_attribute5               in varchar2         default hr_api.g_varchar2,

  p_ass_attribute6               in varchar2         default hr_api.g_varchar2,
  p_ass_attribute7               in varchar2         default hr_api.g_varchar2,
  p_ass_attribute8               in varchar2         default hr_api.g_varchar2,
  p_ass_attribute9               in varchar2         default hr_api.g_varchar2,
  p_ass_attribute10              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute11              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute12              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute13              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute14              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute15              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute16              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute17              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute18              in varchar2         default hr_api.g_varchar2,

  p_ass_attribute19              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute20              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute21              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute22              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute23              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute24              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute25              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute26              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute27              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute28              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute29              in varchar2         default hr_api.g_varchar2,
  p_ass_attribute30              in varchar2         default hr_api.g_varchar2,
  p_title                        in varchar2         default hr_api.g_varchar2,
  p_contract_id                  in number           default hr_api.g_number,
  p_establishment_id             in number           default hr_api.g_number,
  p_collective_agreement_id      in number           default hr_api.g_number,
  p_cagr_grade_def_id            in number           default hr_api.g_number,
  p_cagr_id_flex_num             in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_notice_period        in number       default hr_api.g_number,
  p_notice_period_uom        in varchar2         default hr_api.g_varchar2,
  p_employee_category        in varchar2         default hr_api.g_varchar2,
  p_work_at_home         in varchar2         default hr_api.g_varchar2,
  p_job_post_source_name     in varchar2         default hr_api.g_varchar2,
  p_posting_content_id           in number           default hr_api.g_number,
  p_placement_date_start         in date             default hr_api.g_date,
  p_vendor_id                    in number           default hr_api.g_number,
  p_vendor_employee_number        in varchar2         default hr_api.g_varchar2,
  p_vendor_assignment_number     in varchar2         default hr_api.g_varchar2,
  p_assignment_category          in varchar2         default hr_api.g_varchar2,
  p_project_title                in varchar2         default hr_api.g_varchar2,
  p_applicant_rank               in number           default hr_api.g_number,
  p_payroll_id_updated           out nocopy boolean,
  p_other_manager_warning        out nocopy boolean,
  p_hourly_salaried_warning      out nocopy boolean,
  p_no_managers_warning          out nocopy boolean,
  p_org_now_no_manager_warning   out nocopy boolean,
  p_validation_start_date        out nocopy date,
  p_validation_end_date          out nocopy date,
  p_effective_date         in date,
  p_datetrack_mode         in varchar2,
  p_validate             in boolean      default false
  ) is
--
  l_rec        per_asg_shd.g_rec_type;

  l_proc    varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_asg_shd.convert_args
  (
  p_assignment_id,
  null,

  null,
  hr_api.g_number,
  p_recruiter_id,
  p_grade_id,
  p_position_id,
  p_job_id,
  p_assignment_status_type_id,
  p_payroll_id,
  p_location_id,
  p_person_referred_by_id,
  p_supervisor_id,
  p_special_ceiling_step_id,
  hr_api.g_number,

  p_recruitment_activity_id,
  p_source_organization_id,
  p_organization_id,
  p_people_group_id,
  p_soft_coding_keyflex_id,
  p_vacancy_id,
  p_pay_basis_id,
  hr_api.g_number,
  p_assignment_type,
  p_primary_flag,
  p_application_id,
  p_assignment_number,
  p_change_reason,
  hr_api.g_number,
  p_comments,
  p_date_probation_end,
  p_default_code_comb_id,
  p_employment_category,
  p_frequency,
  p_internal_address_line,
  p_manager_flag,
  p_normal_hours,
  p_perf_review_period,
  p_perf_review_period_frequency,
  p_period_of_service_id,
  p_probation_period,
  p_probation_unit,
  p_sal_review_period,
  p_sal_review_period_frequency,
  p_set_of_books_id,
  p_source_type,
  p_time_normal_finish,
  p_time_normal_start,
  p_bargaining_unit_code,
  p_labour_union_member_flag,
  p_hourly_salaried_code,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_ass_attribute_category,
  p_ass_attribute1,
  p_ass_attribute2,
  p_ass_attribute3,
  p_ass_attribute4,
  p_ass_attribute5,
  p_ass_attribute6,
  p_ass_attribute7,
  p_ass_attribute8,
  p_ass_attribute9,
  p_ass_attribute10,
  p_ass_attribute11,
  p_ass_attribute12,
  p_ass_attribute13,
  p_ass_attribute14,
  p_ass_attribute15,
  p_ass_attribute16,
  p_ass_attribute17,
  p_ass_attribute18,
  p_ass_attribute19,
  p_ass_attribute20,
  p_ass_attribute21,
  p_ass_attribute22,
  p_ass_attribute23,
  p_ass_attribute24,
  p_ass_attribute25,
  p_ass_attribute26,
  p_ass_attribute27,
  p_ass_attribute28,
  p_ass_attribute29,
  p_ass_attribute30,
  p_title,
  p_object_version_number,
  p_contract_id,
  p_establishment_id,
  p_collective_agreement_id,
  p_cagr_grade_def_id,
  p_cagr_id_flex_num,
  p_notice_period,
  p_notice_period_uom,
  p_employee_category,
  p_work_at_home,
  p_job_post_source_name,
  p_posting_content_id,
  p_placement_date_start,
  p_vendor_id,
  p_vendor_employee_number,
  p_vendor_assignment_number,
  p_assignment_category,
  p_project_title,
  p_applicant_rank,
  null,
  null,     /*Bug 2976136*/
  null, ---  p_vendor_site_id
  null, ---  p_po_header_id
  null, ---  p_po_line_id
  null  ---  p_projected_assignment_end
);
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec,
      p_effective_date,

      p_datetrack_mode,
      p_validation_start_date,
      p_validation_end_date,
      p_validate,
      p_payroll_id_updated,
      p_other_manager_warning,
      p_hourly_salaried_warning,
      p_no_managers_warning,
      p_org_now_no_manager_warning);
  --
  p_business_group_id           := l_rec.business_group_id;
  p_comment_id                  := l_rec.comment_id;
  p_effective_end_date          := l_rec.effective_end_date;
  p_effective_start_date        := l_rec.effective_start_date;

  p_object_version_number       := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_asg_upd;

/

--------------------------------------------------------
--  DDL for Package Body BEN_ASG_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ASG_INS" as
/* $Header: beasgrhi.pkb 120.0.12010000.3 2008/08/25 13:43:54 ppentapa ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  ben_asg_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_insert_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic for datetrack. The
--   functions of this procedure are as follows:
--   1) Get the object_version_number.
--   2) To set the effective start and end dates to the corresponding
--      validation start and end dates. Also, the object version number
--      record attribute is set.
--   3) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   4) To insert the row into the schema with the derived effective start
--      and end dates and the object version number.
--   5) To trap any constraint violations that may have occurred.
--   6) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the
--   insert_dml and pre_update (logic permitting) procedure and must have
--   all mandatory arguments set.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_insert_dml
    (p_rec              in out nocopy per_asg_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date
        ) is
--
-- Cursor to select 'old' created AOL who column values
--
  Cursor C_Sel1 Is
    select asg.created_by,
           asg.creation_date
    from   per_all_assignments_f asg
    where  asg.assignment_id        = p_rec.assignment_id
    and    asg.effective_start_date =
             per_asg_shd.g_old_rec.effective_start_date
    and    asg.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc        varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          per_all_assignments_f.created_by%TYPE;
  l_creation_date       per_all_assignments_f.creation_date%TYPE;
  l_last_update_date       per_all_assignments_f.last_update_date%TYPE;
  l_last_updated_by     per_all_assignments_f.last_updated_by%TYPE;
  l_last_update_login   per_all_assignments_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
    (p_base_table_name => 'per_all_assignments_f',
     p_base_key_column => 'assignment_id',
     p_base_key_value  => p_rec.assignment_id);
  --
  -- Set the effective start and end dates to the corresponding
  -- validation start and end dates
  --
  p_rec.effective_start_date := p_validation_start_date;
  p_rec.effective_end_date   := p_validation_end_date;
  --
  -- If the datetrack_mode is not INSERT then we must populate the WHO
  -- columns with the 'old' creation values and 'new' updated values.
  --
  If (p_datetrack_mode <> 'INSERT') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Select the 'old' created values
    --
    Open C_Sel1;
    Fetch C_Sel1 Into l_created_by, l_creation_date;
    If C_Sel1%notfound Then
      --
      -- The previous 'old' created row has not been found. We need
      -- to error as an internal datetrack problem exists.
      --
      Close C_Sel1;
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP','10');
      hr_utility.raise_error;
    End If;
    Close C_Sel1;
    --
    -- Set the AOL updated WHO values
    --
    l_last_update_date   := sysdate;
    l_last_updated_by    := fnd_global.user_id;
    l_last_update_login  := fnd_global.login_id;
  End If;
  --
  per_asg_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: per_all_assignments_f
  --
  insert into per_all_assignments_f
  (    assignment_id,
    effective_start_date,
    effective_end_date,
    business_group_id,
    recruiter_id,
    grade_id,
    position_id,
    job_id,
    assignment_status_type_id,
    payroll_id,
    location_id,
    person_referred_by_id,
    supervisor_id,
    special_ceiling_step_id,
    person_id,
    recruitment_activity_id,
    source_organization_id,
    organization_id,
    people_group_id,
    soft_coding_keyflex_id,
    vacancy_id,
    pay_basis_id,
    assignment_sequence,
    assignment_type,
    primary_flag,
    application_id,
    assignment_number,
    change_reason,
    comment_id,
    date_probation_end,
    default_code_comb_id,
    employment_category,
    frequency,
    internal_address_line,
    manager_flag,
    normal_hours,
    perf_review_period,
    perf_review_period_frequency,
    period_of_service_id,
    probation_period,
    probation_unit,
    sal_review_period,
    sal_review_period_frequency,
    set_of_books_id,
    source_type,
    time_normal_finish,
    time_normal_start,
    bargaining_unit_code,
    labour_union_member_flag,
    hourly_salaried_code,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    ass_attribute_category,
    ass_attribute1,
    ass_attribute2,
    ass_attribute3,
    ass_attribute4,
    ass_attribute5,
    ass_attribute6,
    ass_attribute7,
    ass_attribute8,
    ass_attribute9,
    ass_attribute10,
    ass_attribute11,
    ass_attribute12,
    ass_attribute13,
    ass_attribute14,
    ass_attribute15,
    ass_attribute16,
    ass_attribute17,
    ass_attribute18,
    ass_attribute19,
    ass_attribute20,
    ass_attribute21,
    ass_attribute22,
    ass_attribute23,
    ass_attribute24,
    ass_attribute25,
    ass_attribute26,
    ass_attribute27,
    ass_attribute28,
    ass_attribute29,
    ass_attribute30,
    title,
    contract_id,
    establishment_id,
    collective_agreement_id,
    cagr_grade_def_id,
    cagr_id_flex_num,
    object_version_number,
    created_by,
    creation_date,
    last_update_date,
    last_updated_by,
    last_update_login,
    notice_period,
    notice_period_uom,
    employee_category,
    work_at_home,
    job_post_source_name,
    posting_content_id,
    period_of_placement_date_start,
    vendor_id,
    vendor_employee_number,
    vendor_assignment_number,
    assignment_category,
    project_title,
    applicant_rank
  )
  Values
  (    p_rec.assignment_id,
    p_rec.effective_start_date,
    p_rec.effective_end_date,
    p_rec.business_group_id,
    p_rec.recruiter_id,
    p_rec.grade_id,
    p_rec.position_id,
    p_rec.job_id,
    p_rec.assignment_status_type_id,
    p_rec.payroll_id,
    p_rec.location_id,
    p_rec.person_referred_by_id,
    p_rec.supervisor_id,
    p_rec.special_ceiling_step_id,
    p_rec.person_id,
    p_rec.recruitment_activity_id,
    p_rec.source_organization_id,
    p_rec.organization_id,
    p_rec.people_group_id,
    p_rec.soft_coding_keyflex_id,
    p_rec.vacancy_id,
    p_rec.pay_basis_id,
    p_rec.assignment_sequence,
    p_rec.assignment_type,
    p_rec.primary_flag,
    p_rec.application_id,
    p_rec.assignment_number,
    p_rec.change_reason,
    p_rec.comment_id,
    p_rec.date_probation_end,
    p_rec.default_code_comb_id,
    p_rec.employment_category,
    p_rec.frequency,
    p_rec.internal_address_line,
    p_rec.manager_flag,
    p_rec.normal_hours,
    p_rec.perf_review_period,
    p_rec.perf_review_period_frequency,
    p_rec.period_of_service_id,
    p_rec.probation_period,
    p_rec.probation_unit,
    p_rec.sal_review_period,
    p_rec.sal_review_period_frequency,
    p_rec.set_of_books_id,
    p_rec.source_type,
    p_rec.time_normal_finish,
        p_rec.time_normal_start,
        p_rec.bargaining_unit_code,
        p_rec.labour_union_member_flag,
        p_rec.hourly_salaried_code,
    p_rec.request_id,
    p_rec.program_application_id,
    p_rec.program_id,
    p_rec.program_update_date,
    p_rec.ass_attribute_category,
    p_rec.ass_attribute1,
    p_rec.ass_attribute2,
    p_rec.ass_attribute3,
    p_rec.ass_attribute4,
    p_rec.ass_attribute5,
    p_rec.ass_attribute6,
    p_rec.ass_attribute7,
    p_rec.ass_attribute8,
    p_rec.ass_attribute9,
    p_rec.ass_attribute10,
    p_rec.ass_attribute11,
    p_rec.ass_attribute12,
    p_rec.ass_attribute13,
    p_rec.ass_attribute14,
    p_rec.ass_attribute15,
    p_rec.ass_attribute16,
    p_rec.ass_attribute17,
    p_rec.ass_attribute18,
    p_rec.ass_attribute19,
    p_rec.ass_attribute20,
    p_rec.ass_attribute21,
    p_rec.ass_attribute22,
    p_rec.ass_attribute23,
    p_rec.ass_attribute24,
    p_rec.ass_attribute25,
    p_rec.ass_attribute26,
    p_rec.ass_attribute27,
    p_rec.ass_attribute28,
    p_rec.ass_attribute29,
    p_rec.ass_attribute30,
    p_rec.title,
    p_rec.contract_id,
    p_rec.establishment_id,
    p_rec.collective_agreement_id,
    p_rec.cagr_grade_def_id,
    p_rec.cagr_id_flex_num,
    p_rec.object_version_number,
    l_created_by,
    l_creation_date,
    l_last_update_date,
    l_last_updated_by,
    l_last_update_login,
    p_rec.notice_period,
    p_rec.notice_period_uom,
    p_rec.employee_category,
    p_rec.work_at_home,
    p_rec.job_post_source_name,
    p_rec.posting_content_id,
    p_rec.period_of_placement_date_start,
    p_rec.vendor_id,
    p_rec.vendor_employee_number,
    p_rec.vendor_assignment_number,
    p_rec.assignment_category,
    p_rec.project_title,
    p_rec.applicant_rank
  );
  --
  per_asg_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
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
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
    (p_rec              in out nocopy per_asg_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc    varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_insert_dml(p_rec            => p_rec,
        p_effective_date    => p_effective_date,
        p_datetrack_mode    => p_datetrack_mode,
               p_validation_start_date    => p_validation_start_date,
        p_validation_end_date    => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--   Also, if comments are defined for this entity, the comments insert
--   logic will also be called, generating a comment_id if required.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
    (p_rec              in out nocopy per_asg_shd.g_rec_type,
     p_effective_date        in date,
     p_datetrack_mode        in varchar2,
     p_validation_start_date    in date,
     p_validation_end_date        in date) is
--
  l_proc    varchar2(72) := g_package||'pre_insert';
  l_benefits    varchar2(1);
--
  Cursor C_Sel1 is select per_assignments_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.assignment_id;
  Close C_Sel1;
  hr_utility.set_location(l_proc, 10);
  --
  -- Insert the comment text if comments exist
  --
  If (p_rec.comment_text is not null) then
    hr_comm_api.ins(p_comment_id        => p_rec.comment_id,
                    p_source_table_name => 'PER_ALL_ASSIGNMENTS_F',
                    p_comment_text      => p_rec.comment_text);
  End If;
  hr_utility.set_location(l_proc, 20);
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
  hr_utility.set_location(l_proc, 30);
  --
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
    (p_rec              in per_asg_shd.g_rec_type,
     p_effective_date     in date,
     p_datetrack_mode     in varchar2,
     p_validation_start_date in date,
     p_validation_end_date     in date) is
--
  l_proc    varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  g_trgr_loc_chg := FALSE; --Bug 2666342

  ben_dt_trgr_handle.assignment
    (p_rowid                   => null
    ,p_assignment_id           => p_rec.assignment_id
    ,p_business_group_id       => p_rec.business_group_id
    ,p_person_id               => p_rec.person_id
    ,p_effective_start_date    => p_rec.effective_start_date
    ,p_effective_end_date      => p_rec.effective_end_date
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
    g_trgr_loc_chg := TRUE;
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    per_asg_rki.after_insert
      (p_effective_date                 => p_effective_date
      ,p_validation_start_date          => p_validation_start_date
      ,p_validation_end_date            => p_validation_end_date
      ,p_assignment_id                  => p_rec.assignment_id
      ,p_effective_start_date           => p_rec.effective_start_date
      ,p_effective_end_date             => p_rec.effective_end_date
      ,p_business_group_id              => p_rec.business_group_id
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
      ,p_person_id                      => p_rec.person_id
      ,p_recruitment_activity_id        => p_rec.recruitment_activity_id
      ,p_source_organization_id         => p_rec.source_organization_id
      ,p_organization_id                => p_rec.organization_id
      ,p_people_group_id                => p_rec.people_group_id
      ,p_soft_coding_keyflex_id         => p_rec.soft_coding_keyflex_id
      ,p_vacancy_id                     => p_rec.vacancy_id
      ,p_pay_basis_id                   => p_rec.pay_basis_id
      ,p_assignment_sequence            => p_rec.assignment_sequence
      ,p_assignment_type                => p_rec.assignment_type
      ,p_primary_flag                   => p_rec.primary_flag
      ,p_application_id                 => p_rec.application_id
      ,p_assignment_number              => p_rec.assignment_number
      ,p_change_reason                  => p_rec.change_reason
      ,p_comment_id                     => p_rec.comment_id
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
      ,p_notice_period          => p_rec.notice_period
      ,p_notice_period_uom      => p_rec.notice_period_uom
      ,p_employee_category      => p_rec.employee_category
      ,p_work_at_home           => p_rec.work_at_home
      ,p_job_post_source_name       => p_rec.job_post_source_name
      ,p_posting_content_id             => p_rec.posting_content_id
      ,p_placement_date_start           => p_rec.period_of_placement_date_start
      ,p_vendor_id                      => p_rec.vendor_id
      ,p_vendor_employee_number          => p_rec.vendor_employee_number
      ,p_vendor_assignment_number       => p_rec.vendor_assignment_number
      ,p_assignment_category            => p_rec.assignment_category
      ,p_project_title                  => p_rec.project_title
      ,p_applicant_rank                 => p_rec.applicant_rank
      ,p_grade_ladder_pgm_id	        => p_rec.grade_ladder_pgm_id
      ,p_supervisor_assignment_id       => p_rec.supervisor_assignment_id  --Bug 2976136
      ,p_vendor_site_id                 => p_rec.vendor_site_id
      ,p_po_header_id                   => p_rec.po_header_id
      ,p_po_line_id                     => p_rec.po_line_id
      ,p_projected_assignment_end       => p_rec.projected_assignment_end
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_ALL_ASSIGNMENTS_F'
        ,p_hook_type   => 'AI'
        );
  end;
  -- End of API User Hook for post_insert.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_lck >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The ins_lck process has one main function to perform. When inserting
--   a datetracked row, we must validate the DT mode.
--   be manipulated.
--
-- Pre Conditions:
--   This procedure can only be called for the datetrack mode of INSERT.
--
-- In Arguments:
--
-- Post Success:
--   On successful completion of the ins_lck process the parental
--   datetracked rows will be locked providing the p_enforce_foreign_locking
--   argument value is TRUE.
--   If the p_enforce_foreign_locking argument value is FALSE then the
--   parential rows are not locked.
--
-- Post Failure:
--   The Lck process can fail for:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) When attempting to the lock the parent which doesn't exist.
--      For the entity to be locked the parent must exist!
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins_lck
    (p_effective_date     in  date,
     p_datetrack_mode     in  varchar2,
     p_rec              in  per_asg_shd.g_rec_type,
     p_validation_start_date out nocopy date,
     p_validation_end_date     out nocopy date) is
--
  l_proc          varchar2(72) := g_package||'ins_lck';
  l_validation_start_date date;
  l_validation_end_date      date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate the datetrack mode getting the validation start
  -- and end dates for the specified datetrack operation.
  --
  -- added position_id in parent table validation SCNair [VM]
  --
  -- Removed reference to pay_payrolls_f
  -- as part of fix for bug 1056246.
  --

         --parent_table_name1      => 'pay_payrolls_f',
         --parent_key_column1      => 'payroll_id',
         --parent_key_value1       => p_rec.payroll_id,
  dt_api.validate_dt_mode
        (p_effective_date          => p_effective_date,
         p_datetrack_mode          => p_datetrack_mode,
         p_base_table_name         => 'per_all_assignments_f',
         p_base_key_column         => 'assignment_id',
         p_base_key_value          => p_rec.assignment_id,
         p_parent_table_name1     => 'per_all_people_f',
         p_parent_key_column1     => 'person_id',
         p_parent_key_value1      => p_rec.person_id,
         p_enforce_foreign_locking => false, --true,
         p_validation_start_date   => l_validation_start_date,
         p_validation_end_date     => l_validation_end_date);
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
End ins_lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec                       in out nocopy per_asg_shd.g_rec_type,
  p_effective_date             in     date,
  p_validate                   in     boolean default false,
  p_validate_df_flex           in     boolean default true,
  p_other_manager_warning      out nocopy boolean,
  p_hourly_salaried_warning    out nocopy boolean
  ) is
--
  l_proc            varchar2(72) := g_package||'ins';
  l_datetrack_mode        varchar2(30) := 'INSERT';
  l_validation_start_date    date;
  l_validation_end_date        date;
  l_inv_pos_grade_warning       boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT ins_ben_asg;
    --
  End If;
  --
  -- Call the lock operation
  --
  ins_lck
    (p_effective_date     => p_effective_date,
     p_datetrack_mode     => l_datetrack_mode,
     p_rec              => p_rec,
         p_validation_start_date => l_validation_start_date,
         p_validation_end_date   => l_validation_end_date
        );


  /*

  --
  -- Validation Removed for default benefits assignment creation
  --
  --

  -- Call the supporting insert validate operations
  --
  per_asg_bus1.insert_validate
    (p_rec                  => p_rec,
     p_effective_date          => p_effective_date,
     p_datetrack_mode          => l_datetrack_mode,
     p_validation_start_date      => l_validation_start_date,
     p_validation_end_date          => l_validation_end_date,
         p_validate_df_flex           => p_validate_df_flex,
         p_other_manager_warning      => p_other_manager_warning,
         p_hourly_salaried_warning    => p_hourly_salaried_warning,
         p_inv_pos_grade_warning      => l_inv_pos_grade_warning
        );

  */

  --
  -- Check Business Group
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);

  --
  -- Generate Assignment Sequence
  --
  per_asg_bus2.gen_assignment_sequence
    (p_assignment_type      =>  p_rec.assignment_type
    ,p_person_id            =>  p_rec.person_id
    ,p_assignment_sequence  =>  p_rec.assignment_sequence
    );

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
  -- Call the supporting pre-insert operation
  --
  pre_insert
     (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => l_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date
        );
  --
  -- Insert the row
  --
  insert_dml
     (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => l_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date
        );
  --
  -- Call the supporting post-insert operation
  --
  post_insert
     (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => l_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date
        );
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
    ROLLBACK TO ins_ben_asg;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_assignment_id                out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_business_group_id            in number,
  p_recruiter_id                 in number           default null,
  p_grade_id                     in number           default null,
  p_position_id                  in number           default null,
  p_job_id                       in number           default null,
  p_assignment_status_type_id    in number,
  p_payroll_id                   in number           default null,
  p_location_id                  in number           default null,
  p_person_referred_by_id        in number           default null,
  p_supervisor_id                in number           default null,
  p_special_ceiling_step_id      in number           default null,
  p_person_id                    in number,
  p_recruitment_activity_id      in number           default null,
  p_source_organization_id       in number           default null,
  p_organization_id              in number,
  p_people_group_id              in number           default null,
  p_soft_coding_keyflex_id       in number           default null,
  p_vacancy_id                   in number           default null,
  p_pay_basis_id                 in number           default null,
  p_assignment_sequence          out nocopy number,
  p_assignment_type              in varchar2,
  p_primary_flag                 in varchar2,
  p_application_id               in number           default null,
  p_assignment_number            in out nocopy varchar2,
  p_change_reason                in varchar2         default null,
  p_comment_id                   out nocopy number,
  p_comments                     in varchar2         default null,
  p_date_probation_end           in date             default null,
  p_default_code_comb_id         in number           default null,
  p_employment_category          in varchar2         default null,
  p_frequency                    in varchar2         default null,
  p_internal_address_line        in varchar2         default null,
  p_manager_flag                 in varchar2         default null,
  p_normal_hours                 in number           default null,
  p_perf_review_period           in number           default null,
  p_perf_review_period_frequency in varchar2         default null,
  p_period_of_service_id         in number           default null,
  p_probation_period             in number           default null,
  p_probation_unit               in varchar2         default null,
  p_sal_review_period            in number           default null,
  p_sal_review_period_frequency  in varchar2         default null,
  p_set_of_books_id              in number           default null,
  p_source_type                  in varchar2         default null,
  p_time_normal_finish           in varchar2         default null,
  p_time_normal_start            in varchar2         default null,
  p_bargaining_unit_code         in varchar2         default null,
  p_labour_union_member_flag     in varchar2         default 'N',
  p_hourly_salaried_code         in varchar2         default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_ass_attribute_category       in varchar2         default null,
  p_ass_attribute1               in varchar2         default null,
  p_ass_attribute2               in varchar2         default null,
  p_ass_attribute3               in varchar2         default null,
  p_ass_attribute4               in varchar2         default null,
  p_ass_attribute5               in varchar2         default null,
  p_ass_attribute6               in varchar2         default null,
  p_ass_attribute7               in varchar2         default null,
  p_ass_attribute8               in varchar2         default null,
  p_ass_attribute9               in varchar2         default null,
  p_ass_attribute10              in varchar2         default null,
  p_ass_attribute11              in varchar2         default null,
  p_ass_attribute12              in varchar2         default null,
  p_ass_attribute13              in varchar2         default null,
  p_ass_attribute14              in varchar2         default null,
  p_ass_attribute15              in varchar2         default null,
  p_ass_attribute16              in varchar2         default null,
  p_ass_attribute17              in varchar2         default null,
  p_ass_attribute18              in varchar2         default null,
  p_ass_attribute19              in varchar2         default null,
  p_ass_attribute20              in varchar2         default null,
  p_ass_attribute21              in varchar2         default null,
  p_ass_attribute22              in varchar2         default null,
  p_ass_attribute23              in varchar2         default null,
  p_ass_attribute24              in varchar2         default null,
  p_ass_attribute25              in varchar2         default null,
  p_ass_attribute26              in varchar2         default null,
  p_ass_attribute27              in varchar2         default null,
  p_ass_attribute28              in varchar2         default null,
  p_ass_attribute29              in varchar2         default null,
  p_ass_attribute30              in varchar2         default null,
  p_title                        in varchar2         default null,
  p_validate_df_flex             in boolean          default true,
  p_object_version_number        out nocopy number,
  p_other_manager_warning        out nocopy boolean,
  p_hourly_salaried_warning      out nocopy boolean,
  p_effective_date         in date,
  p_validate             in boolean   default false ,
  p_contract_id                  in number           default null,
  p_establishment_id             in number           default null,
  p_collective_agreement_id      in number           default null,
  p_cagr_grade_def_id            in number           default null,
  p_cagr_id_flex_num             in number           default null,
  p_notice_period        in number       default null,
  p_notice_period_uom        in varchar2         default null,
  p_employee_category        in varchar2         default null,
  p_work_at_home         in varchar2         default null,
  p_job_post_source_name     in varchar2         default null,
  p_posting_content_id           in number           default null,
  p_placement_date_start         in date             default null,
  p_vendor_id                    in number           default null,
  p_vendor_employee_number        in varchar2         default null,
  p_vendor_assignment_number     in varchar2         default null,
  p_assignment_category          in varchar2         default null,
  p_project_title                in varchar2         default null,
  p_applicant_rank               in number           default null
)
 is
--
  l_rec        per_asg_shd.g_rec_type;
  l_proc    varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_asg_shd.convert_args
  (
  null,
  null,
  null,
  p_business_group_id,
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
  p_person_id,
  p_recruitment_activity_id,
  p_source_organization_id,
  p_organization_id,
  p_people_group_id,
  p_soft_coding_keyflex_id,
  p_vacancy_id,
  p_pay_basis_id,
  null,
  p_assignment_type,
  p_primary_flag,
  p_application_id,
  p_assignment_number,
  p_change_reason,
  null,
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
  null ,
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
  null,  --Bug 2976136
  null ,---  p_vendor_site_id
  null, ---  p_po_header_id
  null, ---  p_po_line_id
  null ---   p_projected_assignment_end
  );
  --
  -- Having converted the arguments into the per_asg_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec,
      p_effective_date,
      p_validate,
      p_validate_df_flex,
      p_other_manager_warning,
      p_hourly_salaried_warning
     );
  --
  -- Set the OUT arguments.
  --
  p_assignment_id            := l_rec.assignment_id;
  p_effective_start_date      := l_rec.effective_start_date;
  p_effective_end_date        := l_rec.effective_end_date;
  p_object_version_number     := l_rec.object_version_number;
  p_comment_id                  := l_rec.comment_id;
  p_assignment_number           := l_rec.assignment_number;
  p_assignment_sequence         := l_rec.assignment_sequence;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_asg_ins;

/

--------------------------------------------------------
--  DDL for Package Body HR_PSF_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PSF_INS" as
/* $Header: hrpsfrhi.pkb 120.6.12010000.6 2009/11/26 10:02:00 brsinha ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_psf_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_position_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_position_id  in  number) is
--
  l_proc       varchar2(72) ;
--
Begin
g_debug := hr_utility.debug_enabled;
if g_debug then
l_proc        := g_package||'set_base_key_value';
  hr_utility.set_location('Entering:'||l_proc, 10);
end if;
  --
  hr_psf_ins.g_position_id_i := p_position_id;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end if;
End set_base_key_value;
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
--   3) To insert the row into the schema with the derived effective start
--      and end dates and the object version number.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   insert_dml and pre_update (logic permitting) procedure and must have
--   all mandatory arguments set.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_insert_dml
   (p_rec          in out nocopy hr_psf_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
-- Cursor to select 'old' created AOL who column values
--
  Cursor C_Sel1 Is
    select t.created_by,
           t.creation_date
    from   hr_all_positions_f t
    where  t.position_id       = p_rec.position_id
    and    t.effective_start_date =
             hr_psf_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc    varchar2(72) ;
  l_created_by          hr_all_positions_f.created_by%TYPE;
  l_creation_date       hr_all_positions_f.creation_date%TYPE;
  l_last_update_date    hr_all_positions_f.last_update_date%TYPE;
  l_last_updated_by     hr_all_positions_f.last_updated_by%TYPE;
  l_last_update_login   hr_all_positions_f.last_update_login%TYPE;
--
Begin
if g_debug then
  l_proc     := g_package||'dt_insert_dml';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
   (p_base_table_name => 'hr_all_positions_f',
    p_base_key_column => 'position_id',
    p_base_key_value  => p_rec.position_id);
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
if g_debug then
    hr_utility.set_location(l_proc, 10);
end if;
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
  --
  -- Insert the row into: hr_all_positions_f
  --
  insert into hr_all_positions_f
  (   position_id,
   effective_start_date,
   effective_end_date,
   availability_status_id,
   business_group_id,
   entry_step_id,
   entry_grade_rule_id,
   job_id,
   location_id,
   organization_id,
   pay_freq_payroll_id,
   position_definition_id,
   position_transaction_id,
   prior_position_id,
   relief_position_id,
   entry_grade_id,
   successor_position_id,
   supervisor_position_id,
   amendment_date,
   amendment_recommendation,
   amendment_ref_number,
   bargaining_unit_cd,
   current_job_prop_end_date,
   current_org_prop_end_date,
   avail_status_prop_end_date,
   date_effective,
   date_end,
   earliest_hire_date,
   fill_by_date,
   frequency,
   fte,
   max_persons,
   name,
   overlap_period,
   overlap_unit_cd,
   pay_term_end_day_cd,
   pay_term_end_month_cd,
   permanent_temporary_flag,
   permit_recruitment_flag,
   position_type,
   posting_description,
   probation_period,
   probation_period_unit_cd,
   replacement_required_flag,
   review_flag,
   seasonal_flag,
   security_requirements,
   status,
   term_start_day_cd,
   term_start_month_cd,
   time_normal_finish,
   time_normal_start,
   update_source_cd,
   working_hours,
   works_council_approval_flag,
   work_period_type_cd,
   work_term_end_day_cd,
   work_term_end_month_cd,
        comments,
        proposed_fte_for_layoff,
        proposed_date_for_layoff,
        pay_basis_id,
        supervisor_id,
        copied_to_old_table_flag,
   information1,
   information2,
   information3,
   information4,
   information5,
   information6,
   information7,
   information8,
   information9,
   information10,
   information11,
   information12,
   information13,
   information14,
   information15,
   information16,
   information17,
   information18,
   information19,
   information20,
   information21,
   information22,
   information23,
   information24,
   information25,
   information26,
   information27,
   information28,
   information29,
   information30,
   information_category,
   attribute1,
   attribute2,
   attribute3,
   attribute4,
   attribute5,
   attribute6,
   attribute7,
   attribute8,
   attribute9,
   attribute10,
   attribute11,
   attribute12,
   attribute13,
   attribute14,
   attribute15,
   attribute16,
   attribute17,
   attribute18,
   attribute19,
   attribute20,
   attribute21,
   attribute22,
   attribute23,
   attribute24,
   attribute25,
   attribute26,
   attribute27,
   attribute28,
   attribute29,
   attribute30,
   attribute_category,
   request_id,
   program_application_id,
   program_id,
   program_update_date,
   object_version_number
      , created_by,
      creation_date,
      last_update_date,
      last_updated_by,
      last_update_login
  )
  Values
  (   p_rec.position_id,
   p_rec.effective_start_date,
   p_rec.effective_end_date,
   p_rec.availability_status_id,
   p_rec.business_group_id,
   p_rec.entry_step_id,
   p_rec.entry_grade_rule_id,
   p_rec.job_id,
   p_rec.location_id,
   p_rec.organization_id,
   p_rec.pay_freq_payroll_id,
   p_rec.position_definition_id,
   p_rec.position_transaction_id,
   p_rec.prior_position_id,
   p_rec.relief_position_id,
   p_rec.entry_grade_id,
   p_rec.successor_position_id,
   p_rec.supervisor_position_id,
   p_rec.amendment_date,
   p_rec.amendment_recommendation,
   p_rec.amendment_ref_number,
   p_rec.bargaining_unit_cd,
   p_rec.current_job_prop_end_date,
   p_rec.current_org_prop_end_date,
   p_rec.avail_status_prop_end_date,
   p_rec.date_effective,
   p_rec.date_end,
   p_rec.earliest_hire_date,
   p_rec.fill_by_date,
   p_rec.frequency,
   p_rec.fte,
   p_rec.max_persons,
   p_rec.name,
   p_rec.overlap_period,
   p_rec.overlap_unit_cd,
   p_rec.pay_term_end_day_cd,
   p_rec.pay_term_end_month_cd,
   p_rec.permanent_temporary_flag,
   p_rec.permit_recruitment_flag,
   p_rec.position_type,
   p_rec.posting_description,
   p_rec.probation_period,
   p_rec.probation_period_unit_cd,
   p_rec.replacement_required_flag,
   p_rec.review_flag,
   p_rec.seasonal_flag,
   p_rec.security_requirements,
   p_rec.status,
   p_rec.term_start_day_cd,
   p_rec.term_start_month_cd,
   p_rec.time_normal_finish,
   p_rec.time_normal_start,
   p_rec.update_source_cd,
   p_rec.working_hours,
   p_rec.works_council_approval_flag,
   p_rec.work_period_type_cd,
   p_rec.work_term_end_day_cd,
   p_rec.work_term_end_month_cd,
        p_rec.comments,
        p_rec.proposed_fte_for_layoff,
        p_rec.proposed_date_for_layoff,
        p_rec.pay_basis_id,
        p_rec.supervisor_id,
        p_rec.copied_to_old_table_flag,
   p_rec.information1,
   p_rec.information2,
   p_rec.information3,
   p_rec.information4,
   p_rec.information5,
   p_rec.information6,
   p_rec.information7,
   p_rec.information8,
   p_rec.information9,
   p_rec.information10,
   p_rec.information11,
   p_rec.information12,
   p_rec.information13,
   p_rec.information14,
   p_rec.information15,
   p_rec.information16,
   p_rec.information17,
   p_rec.information18,
   p_rec.information19,
   p_rec.information20,
   p_rec.information21,
   p_rec.information22,
   p_rec.information23,
   p_rec.information24,
   p_rec.information25,
   p_rec.information26,
   p_rec.information27,
   p_rec.information28,
   p_rec.information29,
   p_rec.information30,
   p_rec.information_category,
   p_rec.attribute1,
   p_rec.attribute2,
   p_rec.attribute3,
   p_rec.attribute4,
   p_rec.attribute5,
   p_rec.attribute6,
   p_rec.attribute7,
   p_rec.attribute8,
   p_rec.attribute9,
   p_rec.attribute10,
   p_rec.attribute11,
   p_rec.attribute12,
   p_rec.attribute13,
   p_rec.attribute14,
   p_rec.attribute15,
   p_rec.attribute16,
   p_rec.attribute17,
   p_rec.attribute18,
   p_rec.attribute19,
   p_rec.attribute20,
   p_rec.attribute21,
   p_rec.attribute22,
   p_rec.attribute23,
   p_rec.attribute24,
   p_rec.attribute25,
   p_rec.attribute26,
   p_rec.attribute27,
   p_rec.attribute28,
   p_rec.attribute29,
   p_rec.attribute30,
   p_rec.attribute_category,
   p_rec.request_id,
   p_rec.program_application_id,
   p_rec.program_id,
   p_rec.program_update_date,
   p_rec.object_version_number
   , l_created_by,
      l_creation_date,
      l_last_update_date,
      l_last_updated_by,
      l_last_update_login
  );
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 15);
end if;
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    hr_psf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    hr_psf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
   (p_rec          in out nocopy hr_psf_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc varchar2(72) ;
--
Begin
g_debug := hr_utility.debug_enabled;
if g_debug then
 l_proc   := g_package||'insert_dml';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  dt_insert_dml(p_rec         => p_rec,
      p_effective_date  => p_effective_date,
      p_datetrack_mode  => p_datetrack_mode,
            p_validation_start_date => p_validation_start_date,
      p_validation_end_date   => p_validation_end_date);
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
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
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Parameters:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
   (p_rec         in out nocopy hr_psf_shd.g_rec_type,
    p_effective_date    in date,
    p_datetrack_mode    in varchar2,
    p_validation_start_date   in date,
    p_validation_end_date     in date) is
--
  l_proc varchar2(72);
--
  cursor C_Sel1 is select hr_all_positions_f_s.nextval from sys.dual;
--
--
Begin
if g_debug then
 l_proc   := g_package||'pre_insert';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.position_id;
  Close C_Sel1;
  --
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
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
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Parameters:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
   (p_rec          in hr_psf_shd.g_rec_type,
    p_effective_date  in date,
    p_datetrack_mode  in varchar2,
    p_validation_start_date in date,
    p_validation_end_date   in date) is
--
  l_proc varchar2(72) ;
--
Begin
if g_debug then
 l_proc   := g_package||'post_insert';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  -- Start of API User Hook for post_insert.
  begin
  hr_psf_rki.after_insert(
  p_position_id                  => p_rec.position_id                 ,
  p_effective_start_date         => p_rec.effective_start_date        ,
  p_effective_end_date           => p_rec.effective_end_date          ,
  p_availability_status_id       => p_rec.availability_status_id      ,
  p_business_group_id            => p_rec.business_group_id           ,
  p_entry_step_id                => p_rec.entry_step_id               ,
  p_entry_grade_rule_id          => p_rec.entry_grade_rule_id         ,
  p_job_id                       => p_rec.job_id                      ,
  p_location_id                  => p_rec.location_id                 ,
  p_organization_id              => p_rec.organization_id             ,
  p_pay_freq_payroll_id          => p_rec.pay_freq_payroll_id         ,
  p_position_definition_id       => p_rec.position_definition_id      ,
  p_position_transaction_id      => p_rec.position_transaction_id     ,
  p_prior_position_id            => p_rec.prior_position_id           ,
  p_relief_position_id           => p_rec.relief_position_id          ,
  p_entry_grade_id               => p_rec.entry_grade_id              ,
  p_successor_position_id        => p_rec.successor_position_id       ,
  p_supervisor_position_id       => p_rec.supervisor_position_id      ,
  p_amendment_date               => p_rec.amendment_date              ,
  p_amendment_recommendation     => p_rec.amendment_recommendation    ,
  p_amendment_ref_number         => p_rec.amendment_ref_number        ,
  p_bargaining_unit_cd           => p_rec.bargaining_unit_cd          ,
  p_comments                     => p_rec.comments                    ,
  p_current_job_prop_end_date    => p_rec.current_job_prop_end_date   ,
  p_current_org_prop_end_date    => p_rec.current_org_prop_end_date   ,
  p_avail_status_prop_end_date   => p_rec.avail_status_prop_end_date  ,
  p_date_effective               => p_rec.date_effective              ,
  p_date_end                     => p_rec.date_end                    ,
  p_earliest_hire_date           => p_rec.earliest_hire_date          ,
  p_fill_by_date                 => p_rec.fill_by_date                ,
  p_frequency                    => p_rec.frequency                   ,
  p_fte                          => p_rec.fte                         ,
  p_max_persons                  => p_rec.max_persons                 ,
  p_name                         => p_rec.name                        ,
  p_overlap_period               => p_rec.overlap_period              ,
  p_overlap_unit_cd              => p_rec.overlap_unit_cd             ,
  p_pay_term_end_day_cd          => p_rec.pay_term_end_day_cd         ,
  p_pay_term_end_month_cd        => p_rec.pay_term_end_month_cd       ,
  p_permanent_temporary_flag     => p_rec.permanent_temporary_flag    ,
  p_permit_recruitment_flag      => p_rec.permit_recruitment_flag     ,
  p_position_type                => p_rec.position_type               ,
  p_posting_description          => p_rec.posting_description         ,
  p_probation_period             => p_rec.probation_period            ,
  p_probation_period_unit_cd     => p_rec.probation_period_unit_cd    ,
  p_replacement_required_flag    => p_rec.replacement_required_flag   ,
  p_review_flag                  => p_rec.review_flag                 ,
  p_seasonal_flag                => p_rec.seasonal_flag               ,
  p_security_requirements        => p_rec.security_requirements       ,
  p_status                       => p_rec.status                      ,
  p_term_start_day_cd            => p_rec.term_start_day_cd           ,
  p_term_start_month_cd          => p_rec.term_start_month_cd         ,
  p_time_normal_finish           => p_rec.time_normal_finish          ,
  p_time_normal_start            => p_rec.time_normal_start           ,
  p_update_source_cd             => p_rec.update_source_cd            ,
  p_working_hours                => p_rec.working_hours               ,
  p_works_council_approval_flag  => p_rec.works_council_approval_flag ,
  p_work_period_type_cd          => p_rec.work_period_type_cd         ,
  p_work_term_end_day_cd         => p_rec.work_term_end_day_cd        ,
  p_work_term_end_month_cd       => p_rec.work_term_end_month_cd      ,
  p_proposed_fte_for_layoff      => p_rec.proposed_fte_for_layoff     ,
  p_proposed_date_for_layoff     => p_rec.proposed_date_for_layoff    ,
  p_pay_basis_id                 => p_rec.pay_basis_id                ,
  p_supervisor_id                => p_rec.supervisor_id               ,
  p_copied_to_old_table_flag     => p_rec.copied_to_old_table_flag    ,
  p_information1                 => p_rec.information1                ,
  p_information2                 => p_rec.information2                ,
  p_information3                 => p_rec.information3                ,
  p_information4                 => p_rec.information4                ,
  p_information5                 => p_rec.information5                ,
  p_information6                 => p_rec.information6                ,
  p_information7                 => p_rec.information7                ,
  p_information8                 => p_rec.information8                ,
  p_information9                 => p_rec.information9                ,
  p_information10                => p_rec.information10               ,
  p_information11                => p_rec.information11               ,
  p_information12                => p_rec.information12               ,
  p_information13                => p_rec.information13               ,
  p_information14                => p_rec.information14               ,
  p_information15                => p_rec.information15               ,
  p_information16                => p_rec.information16               ,
  p_information17                => p_rec.information17               ,
  p_information18                => p_rec.information18               ,
  p_information19                => p_rec.information19               ,
  p_information20                => p_rec.information20               ,
  p_information21                => p_rec.information21               ,
  p_information22                => p_rec.information22               ,
  p_information23                => p_rec.information23               ,
  p_information24                => p_rec.information24               ,
  p_information25                => p_rec.information25               ,
  p_information26                => p_rec.information26               ,
  p_information27                => p_rec.information27               ,
  p_information28                => p_rec.information28               ,
  p_information29                => p_rec.information29               ,
  p_information30                => p_rec.information30               ,
  p_information_category         => p_rec.information_category        ,
  p_attribute1                   => p_rec.attribute1                  ,
  p_attribute2                   => p_rec.attribute2                  ,
  p_attribute3                   => p_rec.attribute3                  ,
  p_attribute4                   => p_rec.attribute4                  ,
  p_attribute5                   => p_rec.attribute5                  ,
  p_attribute6                   => p_rec.attribute6                  ,
  p_attribute7                   => p_rec.attribute7                  ,
  p_attribute8                   => p_rec.attribute8                  ,
  p_attribute9                   => p_rec.attribute9                  ,
  p_attribute10                  => p_rec.attribute10                 ,
  p_attribute11                  => p_rec.attribute11                 ,
  p_attribute12                  => p_rec.attribute12                 ,
  p_attribute13                  => p_rec.attribute13                 ,
  p_attribute14                  => p_rec.attribute14                 ,
  p_attribute15                  => p_rec.attribute15                 ,
  p_attribute16                  => p_rec.attribute16                 ,
  p_attribute17                  => p_rec.attribute17                 ,
  p_attribute18                  => p_rec.attribute18                 ,
  p_attribute19                  => p_rec.attribute19                 ,
  p_attribute20                  => p_rec.attribute20                 ,
  p_attribute21                  => p_rec.attribute21                 ,
  p_attribute22                  => p_rec.attribute22                 ,
  p_attribute23                  => p_rec.attribute23                 ,
  p_attribute24                  => p_rec.attribute24                 ,
  p_attribute25                  => p_rec.attribute25                 ,
  p_attribute26                  => p_rec.attribute26                 ,
  p_attribute27                  => p_rec.attribute27                 ,
  p_attribute28                  => p_rec.attribute28                 ,
  p_attribute29                  => p_rec.attribute29                 ,
  p_attribute30                  => p_rec.attribute30                 ,
  p_attribute_category           => p_rec.attribute_category          ,
  p_request_id                   => p_rec.request_id                  ,
  p_program_application_id       => p_rec.program_application_id      ,
  p_program_id                   => p_rec.program_id                  ,
  p_program_update_date          => p_rec.program_update_date         ,
  p_object_version_number        => p_rec.object_version_number       ,
  p_effective_date         => p_effective_date       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_ALL_POSITIONS'
        ,p_hook_type   => 'AI'
        );
  End ;
  --
  hr_psf_shd.position_wf_sync(p_rec.position_id , p_validation_start_date);
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
End post_insert;
--
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
-- Prerequisites:
--   This procedure can only be called for the datetrack mode of INSERT.
--
-- In Parameters:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins_lck
   (p_effective_date  in  date,
    p_datetrack_mode  in  varchar2,
    p_rec          in  hr_psf_shd.g_rec_type,
    p_validation_start_date out nocopy date,
    p_validation_end_date   out nocopy date) is
--
  l_proc      varchar2(72) ;
  l_validation_start_date date;
  l_validation_end_date   date;
  l_status                varchar2(30);
--
  cursor c1 is
  select system_type_cd
  from per_shared_types
  where shared_type_id = p_rec.availability_status_id;
--
Begin
if g_debug then
l_proc         := g_package||'ins_lck';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  -- Validate the datetrack mode mode getting the validation start
  -- and end dates for the specified datetrack operation.
  --
  dt_api.validate_dt_mode
   (p_effective_date    => p_effective_date,
    p_datetrack_mode    => p_datetrack_mode,
    p_base_table_name      => 'hr_all_positions_f',
    p_base_key_column      => 'position_id',
    p_base_key_value       => p_rec.position_id,
    p_parent_table_name1      => 'hr_all_positions_f',
    p_parent_key_column1      => 'successor_position_id',
    p_parent_key_value1       => p_rec.position_id,
    p_parent_table_name2      => 'hr_all_positions_f',
    p_parent_key_column2      => 'supervisor_position_id',
    p_parent_key_value2       => p_rec.position_id,
    p_parent_table_name3      => 'hr_all_positions_f',
    p_parent_key_column3      => 'relief_position_id',
    p_parent_key_value3       => p_rec.position_id,
/*  p_parent_table_name4      => 'hr_all_positions_f',
    p_parent_key_column4      => 'position_id',
    p_parent_key_value4       => p_rec.position_id,
*/
       p_enforce_foreign_locking => true,
    p_validation_start_date   => l_validation_start_date,
    p_validation_end_date     => l_validation_end_date);
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  -- if date_Effective is different from effective_start_date and the status is ACTIVE
  -- then validation_Start_Date becomes same as date_effective
  --
/*  open c1;
  fetch c1 into l_status;
  close c1;
  if l_status is null then
     null;
  end if;
  if l_status = 'ACTIVE' then
    if p_rec.date_Effective <> p_validation_start_date then
      p_validation_start_Date := p_rec.date_Effective;
    end if;
  end if;
  */
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
--
End ins_lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy hr_psf_shd.g_rec_type,
  p_effective_date in     date,
  p_validate       in     boolean default false
  ) is
--
  l_proc       varchar2(72);
  l_datetrack_mode      varchar2(30) := 'INSERT';
  l_validation_start_date  date;
  l_validation_end_date    date;
Begin
g_debug := hr_utility.debug_enabled;
if g_debug then
l_proc          := g_package||'ins';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT ins_per_per;
  End If;
  --
  -- Call the lock operation
  --
  ins_lck
   (p_effective_date  => p_effective_date,
    p_datetrack_mode  => l_datetrack_mode,
    p_rec          => p_rec,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting insert validate operations
  --
  hr_psf_bus.insert_validate
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => l_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => l_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  -- Insert the row
  --
  insert_dml
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => l_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  --
  --
/*
  open c1;
  fetch c1 into l_view_all_positions_flag;
  close c1;

  if l_view_all_positions_flag <> 'Y' then
    insert into per_position_list
    (position_id, security_profile_id)
    values
    (p_rec.position_id, p_rec.security_profile_id);
  end if;
*/
  --
  -- Call the supporting post-insert operation
  --
  post_insert
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => l_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;

Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ins_per_per;
--
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_position_id                  out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_availability_status_id       in number           default null,
  p_business_group_id            in number,
  p_entry_step_id                in number           default null,
  p_entry_grade_rule_id          in number           default null,
  p_job_id                       in number,
  p_location_id                  in number           default null,
  p_organization_id              in number,
  p_pay_freq_payroll_id          in number           default null,
  p_position_definition_id       in number,
  p_position_transaction_id      in number           default null,
  p_prior_position_id            in number           default null,
  p_relief_position_id           in number           default null,
  p_entry_grade_id        in number           default null,
  p_successor_position_id        in number           default null,
  p_supervisor_position_id       in number           default null,
  p_amendment_date               in date             default null,
  p_amendment_recommendation     in varchar2         default null,
  p_amendment_ref_number         in varchar2         default null,
  p_bargaining_unit_cd           in varchar2         default null,
  p_comments                     in varchar2         default null,
  p_current_job_prop_end_date    in date             default null,
  p_current_org_prop_end_date    in date             default null,
  p_avail_status_prop_end_date   in date             default null,
  p_date_effective               in date,
  p_date_end                     in date             default null,
  p_earliest_hire_date           in date             default null,
  p_fill_by_date                 in date             default null,
  p_frequency                    in varchar2         default null,
  p_fte                          in number           default null,
  p_max_persons                  in number           default null,
  p_name                         in varchar2         default null,
  p_overlap_period               in number           default null,
  p_overlap_unit_cd              in varchar2         default null,
  p_pay_term_end_day_cd          in varchar2         default null,
  p_pay_term_end_month_cd        in varchar2         default null,
  p_permanent_temporary_flag     in varchar2         default null,
  p_permit_recruitment_flag      in varchar2         default null,
  p_position_type                in varchar2         default null,
  p_posting_description          in varchar2         default null,
  p_probation_period             in number           default null,
  p_probation_period_unit_cd     in varchar2         default null,
  p_replacement_required_flag    in varchar2         default null,
  p_review_flag                  in varchar2         default null,
  p_seasonal_flag                in varchar2         default null,
  p_security_requirements        in varchar2         default null,
  p_status                       in varchar2         default null,
  p_term_start_day_cd            in varchar2         default null,
  p_term_start_month_cd          in varchar2         default null,
  p_time_normal_finish           in varchar2         default null,
  p_time_normal_start            in varchar2         default null,
  p_update_source_cd             in varchar2         default null,
  p_working_hours                in number           default null,
  p_works_council_approval_flag  in varchar2         default null,
  p_work_period_type_cd          in varchar2         default null,
  p_work_term_end_day_cd         in varchar2         default null,
  p_work_term_end_month_cd       in varchar2         default null,
  p_proposed_fte_for_layoff      in number           default null,
  p_proposed_date_for_layoff     in date             default null,
  p_pay_basis_id                 in  number          default null,
  p_supervisor_id                in  number          default null,
  p_copied_to_old_table_flag     in  varchar2        default null,
  p_information1                 in varchar2         default null,
  p_information2                 in varchar2         default null,
  p_information3                 in varchar2         default null,
  p_information4                 in varchar2         default null,
  p_information5                 in varchar2         default null,
  p_information6                 in varchar2         default null,
  p_information7                 in varchar2         default null,
  p_information8                 in varchar2         default null,
  p_information9                 in varchar2         default null,
  p_information10                in varchar2         default null,
  p_information11                in varchar2         default null,
  p_information12                in varchar2         default null,
  p_information13                in varchar2         default null,
  p_information14                in varchar2         default null,
  p_information15                in varchar2         default null,
  p_information16                in varchar2         default null,
  p_information17                in varchar2         default null,
  p_information18                in varchar2         default null,
  p_information19                in varchar2         default null,
  p_information20                in varchar2         default null,
  p_information21                in varchar2         default null,
  p_information22                in varchar2         default null,
  p_information23                in varchar2         default null,
  p_information24                in varchar2         default null,
  p_information25                in varchar2         default null,
  p_information26                in varchar2         default null,
  p_information27                in varchar2         default null,
  p_information28                in varchar2         default null,
  p_information29                in varchar2         default null,
  p_information30                in varchar2         default null,
  p_information_category         in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_attribute21                  in varchar2         default null,
  p_attribute22                  in varchar2         default null,
  p_attribute23                  in varchar2         default null,
  p_attribute24                  in varchar2         default null,
  p_attribute25                  in varchar2         default null,
  p_attribute26                  in varchar2         default null,
  p_attribute27                  in varchar2         default null,
  p_attribute28                  in varchar2         default null,
  p_attribute29                  in varchar2         default null,
  p_attribute30                  in varchar2         default null,
  p_attribute_category           in varchar2         default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_object_version_number        out nocopy number,
  p_effective_date       in date,
  p_validate                     in boolean  default false,
  p_security_profile_id in number default hr_security.get_security_profile
  ) is
--
  l_rec     hr_psf_shd.g_rec_type;
  l_proc varchar2(72) ;
--
Begin
g_debug := hr_utility.debug_enabled;
if g_debug then
l_proc    := g_package||'ins';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  hr_psf_shd.convert_args
  (
  null,
  null,
  null,
  p_availability_status_id,
  p_business_group_id,
  p_entry_step_id,
  p_entry_grade_rule_id,
  p_job_id,
  p_location_id,
  p_organization_id,
  p_pay_freq_payroll_id,
  p_position_definition_id,
  p_position_transaction_id,
  p_prior_position_id,
  p_relief_position_id,
  p_entry_grade_id,
  p_successor_position_id,
  p_supervisor_position_id,
  p_amendment_date,
  p_amendment_recommendation,
  p_amendment_ref_number,
  p_bargaining_unit_cd,
  p_comments,
  p_current_job_prop_end_date,
  p_current_org_prop_end_date,
  p_avail_status_prop_end_date,
  p_date_effective,
  p_date_end,
  p_earliest_hire_date,
  p_fill_by_date,
  p_frequency,
  p_fte,
  p_max_persons,
  p_name,
  p_overlap_period,
  p_overlap_unit_cd,
  p_pay_term_end_day_cd,
  p_pay_term_end_month_cd,
  p_permanent_temporary_flag,
  p_permit_recruitment_flag,
  p_position_type,
  p_posting_description,
  p_probation_period,
  p_probation_period_unit_cd,
  p_replacement_required_flag,
  p_review_flag,
  p_seasonal_flag,
  p_security_requirements,
  p_status,
  p_term_start_day_cd,
  p_term_start_month_cd,
  p_time_normal_finish,
  p_time_normal_start,
  p_update_source_cd,
  p_working_hours,
  p_works_council_approval_flag,
  p_work_period_type_cd,
  p_work_term_end_day_cd,
  p_work_term_end_month_cd,
  p_proposed_fte_for_layoff,
  p_proposed_date_for_layoff,
  p_pay_basis_id,
  p_supervisor_id,
  p_copied_to_old_table_flag,
  p_information1,
  p_information2,
  p_information3,
  p_information4,
  p_information5,
  p_information6,
  p_information7,
  p_information8,
  p_information9,
  p_information10,
  p_information11,
  p_information12,
  p_information13,
  p_information14,
  p_information15,
  p_information16,
  p_information17,
  p_information18,
  p_information19,
  p_information20,
  p_information21,
  p_information22,
  p_information23,
  p_information24,
  p_information25,
  p_information26,
  p_information27,
  p_information28,
  p_information29,
  p_information30,
  p_information_category,
  p_attribute1,
  p_attribute2,
  p_attribute3,
  p_attribute4,
  p_attribute5,
  p_attribute6,
  p_attribute7,
  p_attribute8,
  p_attribute9,
  p_attribute10,
  p_attribute11,
  p_attribute12,
  p_attribute13,
  p_attribute14,
  p_attribute15,
  p_attribute16,
  p_attribute17,
  p_attribute18,
  p_attribute19,
  p_attribute20,
  p_attribute21,
  p_attribute22,
  p_attribute23,
  p_attribute24,
  p_attribute25,
  p_attribute26,
  p_attribute27,
  p_attribute28,
  p_attribute29,
  p_attribute30,
  p_attribute_category,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  null,
  p_security_profile_id
  );
  --
  -- Having converted the arguments into the psf_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date, p_validate);
  --
  -- Set the OUT arguments.
  --
  p_position_id         := l_rec.position_id;
  p_effective_start_date   := l_rec.effective_start_date;
  p_effective_end_date     := l_rec.effective_end_date;
  p_object_version_number  := l_rec.object_version_number;
  --
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
End ins;
--
end hr_psf_ins;

/

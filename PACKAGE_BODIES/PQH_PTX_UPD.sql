--------------------------------------------------------
--  DDL for Package Body PQH_PTX_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PTX_UPD" as
/* $Header: pqptxrhi.pkb 120.0.12010000.2 2008/08/05 13:41:09 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_ptx_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy pqh_ptx_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  -- Update the pqh_position_transactions Row
  --
  update pqh_position_transactions
  set
  position_transaction_id           = p_rec.position_transaction_id,
  action_date                       = p_rec.action_date,
  position_id                       = p_rec.position_id,
  availability_status_id            = p_rec.availability_status_id,
  business_group_id                 = p_rec.business_group_id,
  entry_step_id                     = p_rec.entry_step_id,
  entry_grade_rule_id                     = p_rec.entry_grade_rule_id,
  job_id                            = p_rec.job_id,
  location_id                       = p_rec.location_id,
  organization_id                   = p_rec.organization_id,
  pay_freq_payroll_id               = p_rec.pay_freq_payroll_id,
  position_definition_id            = p_rec.position_definition_id,
  prior_position_id                 = p_rec.prior_position_id,
  relief_position_id                = p_rec.relief_position_id,
  entry_grade_id             = p_rec.entry_grade_id,
  successor_position_id             = p_rec.successor_position_id,
  supervisor_position_id            = p_rec.supervisor_position_id,
  amendment_date                    = p_rec.amendment_date,
  amendment_recommendation          = p_rec.amendment_recommendation,
  amendment_ref_number              = p_rec.amendment_ref_number,
  avail_status_prop_end_date        = p_rec.avail_status_prop_end_date,
  bargaining_unit_cd                = p_rec.bargaining_unit_cd,
  comments                          = p_rec.comments,
  country1                          = p_rec.country1,
  country2                          = p_rec.country2,
  country3                          = p_rec.country3,
  current_job_prop_end_date         = p_rec.current_job_prop_end_date,
  current_org_prop_end_date         = p_rec.current_org_prop_end_date,
  date_effective                    = p_rec.date_effective,
  date_end                          = p_rec.date_end,
  earliest_hire_date                = p_rec.earliest_hire_date,
  fill_by_date                      = p_rec.fill_by_date,
  frequency                         = p_rec.frequency,
  fte                               = p_rec.fte,
  fte_capacity                      = p_rec.fte_capacity,
  location1                         = p_rec.location1,
  location2                         = p_rec.location2,
  location3                         = p_rec.location3,
  max_persons                       = p_rec.max_persons,
  name                              = p_rec.name,
  other_requirements                = p_rec.other_requirements,
  overlap_period                    = p_rec.overlap_period,
  overlap_unit_cd                   = p_rec.overlap_unit_cd,
  passport_required                 = p_rec.passport_required,
  pay_term_end_day_cd               = p_rec.pay_term_end_day_cd,
  pay_term_end_month_cd             = p_rec.pay_term_end_month_cd,
  permanent_temporary_flag          = p_rec.permanent_temporary_flag,
  permit_recruitment_flag           = p_rec.permit_recruitment_flag,
  position_type                     = p_rec.position_type,
  posting_description               = p_rec.posting_description,
  probation_period                  = p_rec.probation_period,
  probation_period_unit_cd          = p_rec.probation_period_unit_cd,
  relocate_domestically             = p_rec.relocate_domestically,
  relocate_internationally          = p_rec.relocate_internationally,
  replacement_required_flag         = p_rec.replacement_required_flag,
  review_flag                       = p_rec.review_flag,
  seasonal_flag                     = p_rec.seasonal_flag,
  security_requirements             = p_rec.security_requirements,
  service_minimum                   = p_rec.service_minimum,
  term_start_day_cd                 = p_rec.term_start_day_cd,
  term_start_month_cd               = p_rec.term_start_month_cd,
  time_normal_finish                = p_rec.time_normal_finish,
  time_normal_start                 = p_rec.time_normal_start,
  transaction_status                = p_rec.transaction_status,
  travel_required                   = p_rec.travel_required,
  working_hours                     = p_rec.working_hours,
  works_council_approval_flag       = p_rec.works_council_approval_flag,
  work_any_country                  = p_rec.work_any_country,
  work_any_location                 = p_rec.work_any_location,
  work_period_type_cd               = p_rec.work_period_type_cd,
  work_schedule                     = p_rec.work_schedule,
  work_duration                     = p_rec.work_duration,
  work_term_end_day_cd              = p_rec.work_term_end_day_cd,
  work_term_end_month_cd            = p_rec.work_term_end_month_cd,
  proposed_fte_for_layoff           = p_rec.proposed_fte_for_layoff,
  proposed_date_for_layoff          = p_rec.proposed_date_for_layoff,
  information1                      = p_rec.information1,
  information2                      = p_rec.information2,
  information3                      = p_rec.information3,
  information4                      = p_rec.information4,
  information5                      = p_rec.information5,
  information6                      = p_rec.information6,
  information7                      = p_rec.information7,
  information8                      = p_rec.information8,
  information9                      = p_rec.information9,
  information10                     = p_rec.information10,
  information11                     = p_rec.information11,
  information12                     = p_rec.information12,
  information13                     = p_rec.information13,
  information14                     = p_rec.information14,
  information15                     = p_rec.information15,
  information16                     = p_rec.information16,
  information17                     = p_rec.information17,
  information18                     = p_rec.information18,
  information19                     = p_rec.information19,
  information20                     = p_rec.information20,
  information21                     = p_rec.information21,
  information22                     = p_rec.information22,
  information23                     = p_rec.information23,
  information24                     = p_rec.information24,
  information25                     = p_rec.information25,
  information26                     = p_rec.information26,
  information27                     = p_rec.information27,
  information28                     = p_rec.information28,
  information29                     = p_rec.information29,
  information30                     = p_rec.information30,
  information_category              = p_rec.information_category,
  attribute1                        = p_rec.attribute1,
  attribute2                        = p_rec.attribute2,
  attribute3                        = p_rec.attribute3,
  attribute4                        = p_rec.attribute4,
  attribute5                        = p_rec.attribute5,
  attribute6                        = p_rec.attribute6,
  attribute7                        = p_rec.attribute7,
  attribute8                        = p_rec.attribute8,
  attribute9                        = p_rec.attribute9,
  attribute10                       = p_rec.attribute10,
  attribute11                       = p_rec.attribute11,
  attribute12                       = p_rec.attribute12,
  attribute13                       = p_rec.attribute13,
  attribute14                       = p_rec.attribute14,
  attribute15                       = p_rec.attribute15,
  attribute16                       = p_rec.attribute16,
  attribute17                       = p_rec.attribute17,
  attribute18                       = p_rec.attribute18,
  attribute19                       = p_rec.attribute19,
  attribute20                       = p_rec.attribute20,
  attribute21                       = p_rec.attribute21,
  attribute22                       = p_rec.attribute22,
  attribute23                       = p_rec.attribute23,
  attribute24                       = p_rec.attribute24,
  attribute25                       = p_rec.attribute25,
  attribute26                       = p_rec.attribute26,
  attribute27                       = p_rec.attribute27,
  attribute28                       = p_rec.attribute28,
  attribute29                       = p_rec.attribute29,
  attribute30                       = p_rec.attribute30,
  attribute_category                = p_rec.attribute_category,
  object_version_number             = p_rec.object_version_number,
  pay_basis_id			    = p_rec.pay_basis_id,
  supervisor_id			    = p_rec.supervisor_id,
  wf_transaction_category_id	    = p_rec.wf_transaction_category_id
  where position_transaction_id = p_rec.position_transaction_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_ptx_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_ptx_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_ptx_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    Raise;
End update_dml;
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
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in pqh_ptx_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(
p_effective_date in date,p_rec in pqh_ptx_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
  l_effective_start_date            date;
  l_effective_end_date              date;
  l_position_definition_id          number;
  l_valid_grades_changed_warning    boolean;
  l_name                            hr_all_positions_f.name%type;
  l_review_flag                     hr_all_positions_f.review_flag%type;
  l_object_version_number           number;
  l_effective_date                  date        :=sysdate;
  l_datetrack_mode                  varchar2(20):='UPDATE';
--
--
cursor c_review_flag(p_position_id number) is
select review_flag
from hr_all_positions_f
where position_id = p_position_id;
--
cursor c1(p_position_id number, p_effective_date date) is
select review_flag, object_version_number
from hr_all_positions_f
where position_id = p_position_id
and p_effective_date between effective_start_date and effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
if p_rec.position_id is not null then
  open c_review_flag(p_rec.position_id);
  fetch c_review_flag into l_review_flag;
  close c_review_flag;
  --
  if (nvl(p_rec.review_flag,'N') = 'Y' and nvl(l_review_flag,'N') = 'Y'
    and nvl(pqh_ptx_shd.g_old_rec.review_flag,'N') = 'N')then
    hr_utility.set_message(1802, 'PQH_POSITION_UNDER_REVIEW');
    hr_utility.raise_error;
 /* Bug 6524175 changes
  elsif ((nvl(p_rec.review_flag,'N') = 'Y' and nvl(l_review_flag,'N') = 'N')
    or (nvl(p_rec.review_flag,'N') = 'N' and nvl(l_review_flag,'N') = 'Y'))then */
    --
  else
    update hr_all_positions_f
    set review_flag = p_rec.review_flag
    where position_id = p_rec.position_id;
/*
    hr_position_api.update_position(
      p_validate                   => false,
      p_position_id            	 => p_rec.position_id,
      p_effective_start_date    	 => l_effective_start_date,
      p_effective_end_date	 => l_effective_end_date,
      p_position_definition_id     => l_position_definition_id,
      p_valid_grades_changed_warning=> l_valid_grades_changed_warning,
      p_name                       => l_name,
      p_review_flag                => p_rec.review_flag,
      p_object_version_number   	 => l_object_version_number,
      p_effective_date	  	 => l_effective_date,
      p_datetrack_mode		 => l_datetrack_mode
    );
*/
end if;
end if;
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    pqh_ptx_rku.after_update
      (
  p_position_transaction_id       =>p_rec.position_transaction_id
 ,p_action_date                   =>p_rec.action_date
 ,p_position_id                   =>p_rec.position_id
 ,p_availability_status_id        =>p_rec.availability_status_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_entry_step_id                 =>p_rec.entry_step_id
 ,p_entry_grade_rule_id                 =>p_rec.entry_grade_rule_id
 ,p_job_id                        =>p_rec.job_id
 ,p_location_id                   =>p_rec.location_id
 ,p_organization_id               =>p_rec.organization_id
 ,p_pay_freq_payroll_id           =>p_rec.pay_freq_payroll_id
 ,p_position_definition_id        =>p_rec.position_definition_id
 ,p_prior_position_id             =>p_rec.prior_position_id
 ,p_relief_position_id            =>p_rec.relief_position_id
 ,p_entry_grade_id         =>p_rec.entry_grade_id
 ,p_successor_position_id         =>p_rec.successor_position_id
 ,p_supervisor_position_id        =>p_rec.supervisor_position_id
 ,p_amendment_date                =>p_rec.amendment_date
 ,p_amendment_recommendation      =>p_rec.amendment_recommendation
 ,p_amendment_ref_number          =>p_rec.amendment_ref_number
 ,p_avail_status_prop_end_date    =>p_rec.avail_status_prop_end_date
 ,p_bargaining_unit_cd            =>p_rec.bargaining_unit_cd
 ,p_comments                      =>p_rec.comments
 ,p_country1                      =>p_rec.country1
 ,p_country2                      =>p_rec.country2
 ,p_country3                      =>p_rec.country3
 ,p_current_job_prop_end_date     =>p_rec.current_job_prop_end_date
 ,p_current_org_prop_end_date     =>p_rec.current_org_prop_end_date
 ,p_date_effective                =>p_rec.date_effective
 ,p_date_end                      =>p_rec.date_end
 ,p_earliest_hire_date            =>p_rec.earliest_hire_date
 ,p_fill_by_date                  =>p_rec.fill_by_date
 ,p_frequency                     =>p_rec.frequency
 ,p_fte                           =>p_rec.fte
 ,p_fte_capacity                  =>p_rec.fte_capacity
 ,p_location1                     =>p_rec.location1
 ,p_location2                     =>p_rec.location2
 ,p_location3                     =>p_rec.location3
 ,p_max_persons                   =>p_rec.max_persons
 ,p_name                          =>p_rec.name
 ,p_other_requirements            =>p_rec.other_requirements
 ,p_overlap_period                =>p_rec.overlap_period
 ,p_overlap_unit_cd               =>p_rec.overlap_unit_cd
 ,p_passport_required             =>p_rec.passport_required
 ,p_pay_term_end_day_cd           =>p_rec.pay_term_end_day_cd
 ,p_pay_term_end_month_cd         =>p_rec.pay_term_end_month_cd
 ,p_permanent_temporary_flag      =>p_rec.permanent_temporary_flag
 ,p_permit_recruitment_flag       =>p_rec.permit_recruitment_flag
 ,p_position_type                 =>p_rec.position_type
 ,p_posting_description           =>p_rec.posting_description
 ,p_probation_period              =>p_rec.probation_period
 ,p_probation_period_unit_cd      =>p_rec.probation_period_unit_cd
 ,p_relocate_domestically         =>p_rec.relocate_domestically
 ,p_relocate_internationally      =>p_rec.relocate_internationally
 ,p_replacement_required_flag     =>p_rec.replacement_required_flag
 ,p_review_flag                   =>p_rec.review_flag
 ,p_seasonal_flag                 =>p_rec.seasonal_flag
 ,p_security_requirements         =>p_rec.security_requirements
 ,p_service_minimum               =>p_rec.service_minimum
 ,p_term_start_day_cd             =>p_rec.term_start_day_cd
 ,p_term_start_month_cd           =>p_rec.term_start_month_cd
 ,p_time_normal_finish            =>p_rec.time_normal_finish
 ,p_time_normal_start             =>p_rec.time_normal_start
 ,p_transaction_status            =>p_rec.transaction_status
 ,p_travel_required               =>p_rec.travel_required
 ,p_working_hours                 =>p_rec.working_hours
 ,p_works_council_approval_flag   =>p_rec.works_council_approval_flag
 ,p_work_any_country              =>p_rec.work_any_country
 ,p_work_any_location             =>p_rec.work_any_location
 ,p_work_period_type_cd           =>p_rec.work_period_type_cd
 ,p_work_schedule                 =>p_rec.work_schedule
 ,p_work_duration                 =>p_rec.work_duration
 ,p_work_term_end_day_cd          =>p_rec.work_term_end_day_cd
 ,p_work_term_end_month_cd        =>p_rec.work_term_end_month_cd
 ,p_proposed_fte_for_layoff       =>p_rec.proposed_fte_for_layoff
 ,p_proposed_date_for_layoff      =>p_rec.proposed_date_for_layoff
 ,p_information1                  =>p_rec.information1
 ,p_information2                  =>p_rec.information2
 ,p_information3                  =>p_rec.information3
 ,p_information4                  =>p_rec.information4
 ,p_information5                  =>p_rec.information5
 ,p_information6                  =>p_rec.information6
 ,p_information7                  =>p_rec.information7
 ,p_information8                  =>p_rec.information8
 ,p_information9                  =>p_rec.information9
 ,p_information10                 =>p_rec.information10
 ,p_information11                 =>p_rec.information11
 ,p_information12                 =>p_rec.information12
 ,p_information13                 =>p_rec.information13
 ,p_information14                 =>p_rec.information14
 ,p_information15                 =>p_rec.information15
 ,p_information16                 =>p_rec.information16
 ,p_information17                 =>p_rec.information17
 ,p_information18                 =>p_rec.information18
 ,p_information19                 =>p_rec.information19
 ,p_information20                 =>p_rec.information20
 ,p_information21                 =>p_rec.information21
 ,p_information22                 =>p_rec.information22
 ,p_information23                 =>p_rec.information23
 ,p_information24                 =>p_rec.information24
 ,p_information25                 =>p_rec.information25
 ,p_information26                 =>p_rec.information26
 ,p_information27                 =>p_rec.information27
 ,p_information28                 =>p_rec.information28
 ,p_information29                 =>p_rec.information29
 ,p_information30                 =>p_rec.information30
 ,p_information_category          =>p_rec.information_category
 ,p_attribute1                    =>p_rec.attribute1
 ,p_attribute2                    =>p_rec.attribute2
 ,p_attribute3                    =>p_rec.attribute3
 ,p_attribute4                    =>p_rec.attribute4
 ,p_attribute5                    =>p_rec.attribute5
 ,p_attribute6                    =>p_rec.attribute6
 ,p_attribute7                    =>p_rec.attribute7
 ,p_attribute8                    =>p_rec.attribute8
 ,p_attribute9                    =>p_rec.attribute9
 ,p_attribute10                   =>p_rec.attribute10
 ,p_attribute11                   =>p_rec.attribute11
 ,p_attribute12                   =>p_rec.attribute12
 ,p_attribute13                   =>p_rec.attribute13
 ,p_attribute14                   =>p_rec.attribute14
 ,p_attribute15                   =>p_rec.attribute15
 ,p_attribute16                   =>p_rec.attribute16
 ,p_attribute17                   =>p_rec.attribute17
 ,p_attribute18                   =>p_rec.attribute18
 ,p_attribute19                   =>p_rec.attribute19
 ,p_attribute20                   =>p_rec.attribute20
 ,p_attribute21                   =>p_rec.attribute21
 ,p_attribute22                   =>p_rec.attribute22
 ,p_attribute23                   =>p_rec.attribute23
 ,p_attribute24                   =>p_rec.attribute24
 ,p_attribute25                   =>p_rec.attribute25
 ,p_attribute26                   =>p_rec.attribute26
 ,p_attribute27                   =>p_rec.attribute27
 ,p_attribute28                   =>p_rec.attribute28
 ,p_attribute29                   =>p_rec.attribute29
 ,p_attribute30                   =>p_rec.attribute30
 ,p_attribute_category            =>p_rec.attribute_category
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_action_date_o                 =>pqh_ptx_shd.g_old_rec.action_date
 ,p_position_id_o                 =>pqh_ptx_shd.g_old_rec.position_id
 ,p_availability_status_id_o      =>pqh_ptx_shd.g_old_rec.availability_status_id
 ,p_business_group_id_o           =>pqh_ptx_shd.g_old_rec.business_group_id
 ,p_entry_step_id_o               =>pqh_ptx_shd.g_old_rec.entry_step_id
 ,p_entry_grade_rule_id_o               =>pqh_ptx_shd.g_old_rec.entry_grade_rule_id
 ,p_job_id_o                      =>pqh_ptx_shd.g_old_rec.job_id
 ,p_location_id_o                 =>pqh_ptx_shd.g_old_rec.location_id
 ,p_organization_id_o             =>pqh_ptx_shd.g_old_rec.organization_id
 ,p_pay_freq_payroll_id_o         =>pqh_ptx_shd.g_old_rec.pay_freq_payroll_id
 ,p_position_definition_id_o      =>pqh_ptx_shd.g_old_rec.position_definition_id
 ,p_prior_position_id_o           =>pqh_ptx_shd.g_old_rec.prior_position_id
 ,p_relief_position_id_o          =>pqh_ptx_shd.g_old_rec.relief_position_id
 ,p_entry_grade_id_o       =>pqh_ptx_shd.g_old_rec.entry_grade_id
 ,p_successor_position_id_o       =>pqh_ptx_shd.g_old_rec.successor_position_id
 ,p_supervisor_position_id_o      =>pqh_ptx_shd.g_old_rec.supervisor_position_id
 ,p_amendment_date_o              =>pqh_ptx_shd.g_old_rec.amendment_date
 ,p_amendment_recommendation_o    =>pqh_ptx_shd.g_old_rec.amendment_recommendation
 ,p_amendment_ref_number_o        =>pqh_ptx_shd.g_old_rec.amendment_ref_number
 ,p_avail_status_prop_end_date_o  =>pqh_ptx_shd.g_old_rec.avail_status_prop_end_date
 ,p_bargaining_unit_cd_o          =>pqh_ptx_shd.g_old_rec.bargaining_unit_cd
 ,p_comments_o                    =>pqh_ptx_shd.g_old_rec.comments
 ,p_country1_o                    =>pqh_ptx_shd.g_old_rec.country1
 ,p_country2_o                    =>pqh_ptx_shd.g_old_rec.country2
 ,p_country3_o                    =>pqh_ptx_shd.g_old_rec.country3
 ,p_current_job_prop_end_date_o   =>pqh_ptx_shd.g_old_rec.current_job_prop_end_date
 ,p_current_org_prop_end_date_o   =>pqh_ptx_shd.g_old_rec.current_org_prop_end_date
 ,p_date_effective_o              =>pqh_ptx_shd.g_old_rec.date_effective
 ,p_date_end_o                    =>pqh_ptx_shd.g_old_rec.date_end
 ,p_earliest_hire_date_o          =>pqh_ptx_shd.g_old_rec.earliest_hire_date
 ,p_fill_by_date_o                =>pqh_ptx_shd.g_old_rec.fill_by_date
 ,p_frequency_o                   =>pqh_ptx_shd.g_old_rec.frequency
 ,p_fte_o                         =>pqh_ptx_shd.g_old_rec.fte
 ,p_fte_capacity_o                =>pqh_ptx_shd.g_old_rec.fte_capacity
 ,p_location1_o                   =>pqh_ptx_shd.g_old_rec.location1
 ,p_location2_o                   =>pqh_ptx_shd.g_old_rec.location2
 ,p_location3_o                   =>pqh_ptx_shd.g_old_rec.location3
 ,p_max_persons_o                 =>pqh_ptx_shd.g_old_rec.max_persons
 ,p_name_o                        =>pqh_ptx_shd.g_old_rec.name
 ,p_other_requirements_o          =>pqh_ptx_shd.g_old_rec.other_requirements
 ,p_overlap_period_o              =>pqh_ptx_shd.g_old_rec.overlap_period
 ,p_overlap_unit_cd_o             =>pqh_ptx_shd.g_old_rec.overlap_unit_cd
 ,p_passport_required_o           =>pqh_ptx_shd.g_old_rec.passport_required
 ,p_pay_term_end_day_cd_o         =>pqh_ptx_shd.g_old_rec.pay_term_end_day_cd
 ,p_pay_term_end_month_cd_o       =>pqh_ptx_shd.g_old_rec.pay_term_end_month_cd
 ,p_permanent_temporary_flag_o    =>pqh_ptx_shd.g_old_rec.permanent_temporary_flag
 ,p_permit_recruitment_flag_o     =>pqh_ptx_shd.g_old_rec.permit_recruitment_flag
 ,p_position_type_o               =>pqh_ptx_shd.g_old_rec.position_type
 ,p_posting_description_o         =>pqh_ptx_shd.g_old_rec.posting_description
 ,p_probation_period_o            =>pqh_ptx_shd.g_old_rec.probation_period
 ,p_probation_period_unit_cd_o    =>pqh_ptx_shd.g_old_rec.probation_period_unit_cd
 ,p_relocate_domestically_o       =>pqh_ptx_shd.g_old_rec.relocate_domestically
 ,p_relocate_internationally_o    =>pqh_ptx_shd.g_old_rec.relocate_internationally
 ,p_replacement_required_flag_o   =>pqh_ptx_shd.g_old_rec.replacement_required_flag
 ,p_review_flag_o                 =>pqh_ptx_shd.g_old_rec.review_flag
 ,p_seasonal_flag_o               =>pqh_ptx_shd.g_old_rec.seasonal_flag
 ,p_security_requirements_o       =>pqh_ptx_shd.g_old_rec.security_requirements
 ,p_service_minimum_o             =>pqh_ptx_shd.g_old_rec.service_minimum
 ,p_term_start_day_cd_o           =>pqh_ptx_shd.g_old_rec.term_start_day_cd
 ,p_term_start_month_cd_o         =>pqh_ptx_shd.g_old_rec.term_start_month_cd
 ,p_time_normal_finish_o          =>pqh_ptx_shd.g_old_rec.time_normal_finish
 ,p_time_normal_start_o           =>pqh_ptx_shd.g_old_rec.time_normal_start
 ,p_transaction_status_o          =>pqh_ptx_shd.g_old_rec.transaction_status
 ,p_travel_required_o             =>pqh_ptx_shd.g_old_rec.travel_required
 ,p_working_hours_o               =>pqh_ptx_shd.g_old_rec.working_hours
 ,p_works_council_approval_fla_o =>pqh_ptx_shd.g_old_rec.works_council_approval_flag
 ,p_work_any_country_o            =>pqh_ptx_shd.g_old_rec.work_any_country
 ,p_work_any_location_o           =>pqh_ptx_shd.g_old_rec.work_any_location
 ,p_work_period_type_cd_o         =>pqh_ptx_shd.g_old_rec.work_period_type_cd
 ,p_work_schedule_o               =>pqh_ptx_shd.g_old_rec.work_schedule
 ,p_work_duration_o               =>pqh_ptx_shd.g_old_rec.work_duration
 ,p_work_term_end_day_cd_o        =>pqh_ptx_shd.g_old_rec.work_term_end_day_cd
 ,p_work_term_end_month_cd_o      =>pqh_ptx_shd.g_old_rec.work_term_end_month_cd
 ,p_proposed_fte_for_layoff_o     =>pqh_ptx_shd.g_old_rec.proposed_fte_for_layoff
 ,p_proposed_date_for_layoff_o    =>pqh_ptx_shd.g_old_rec.proposed_date_for_layoff
 ,p_information1_o                =>pqh_ptx_shd.g_old_rec.information1
 ,p_information2_o                =>pqh_ptx_shd.g_old_rec.information2
 ,p_information3_o                =>pqh_ptx_shd.g_old_rec.information3
 ,p_information4_o                =>pqh_ptx_shd.g_old_rec.information4
 ,p_information5_o                =>pqh_ptx_shd.g_old_rec.information5
 ,p_information6_o                =>pqh_ptx_shd.g_old_rec.information6
 ,p_information7_o                =>pqh_ptx_shd.g_old_rec.information7
 ,p_information8_o                =>pqh_ptx_shd.g_old_rec.information8
 ,p_information9_o                =>pqh_ptx_shd.g_old_rec.information9
 ,p_information10_o               =>pqh_ptx_shd.g_old_rec.information10
 ,p_information11_o               =>pqh_ptx_shd.g_old_rec.information11
 ,p_information12_o               =>pqh_ptx_shd.g_old_rec.information12
 ,p_information13_o               =>pqh_ptx_shd.g_old_rec.information13
 ,p_information14_o               =>pqh_ptx_shd.g_old_rec.information14
 ,p_information15_o               =>pqh_ptx_shd.g_old_rec.information15
 ,p_information16_o               =>pqh_ptx_shd.g_old_rec.information16
 ,p_information17_o               =>pqh_ptx_shd.g_old_rec.information17
 ,p_information18_o               =>pqh_ptx_shd.g_old_rec.information18
 ,p_information19_o               =>pqh_ptx_shd.g_old_rec.information19
 ,p_information20_o               =>pqh_ptx_shd.g_old_rec.information20
 ,p_information21_o               =>pqh_ptx_shd.g_old_rec.information21
 ,p_information22_o               =>pqh_ptx_shd.g_old_rec.information22
 ,p_information23_o               =>pqh_ptx_shd.g_old_rec.information23
 ,p_information24_o               =>pqh_ptx_shd.g_old_rec.information24
 ,p_information25_o               =>pqh_ptx_shd.g_old_rec.information25
 ,p_information26_o               =>pqh_ptx_shd.g_old_rec.information26
 ,p_information27_o               =>pqh_ptx_shd.g_old_rec.information27
 ,p_information28_o               =>pqh_ptx_shd.g_old_rec.information28
 ,p_information29_o               =>pqh_ptx_shd.g_old_rec.information29
 ,p_information30_o               =>pqh_ptx_shd.g_old_rec.information30
 ,p_information_category_o        =>pqh_ptx_shd.g_old_rec.information_category
 ,p_attribute1_o                  =>pqh_ptx_shd.g_old_rec.attribute1
 ,p_attribute2_o                  =>pqh_ptx_shd.g_old_rec.attribute2
 ,p_attribute3_o                  =>pqh_ptx_shd.g_old_rec.attribute3
 ,p_attribute4_o                  =>pqh_ptx_shd.g_old_rec.attribute4
 ,p_attribute5_o                  =>pqh_ptx_shd.g_old_rec.attribute5
 ,p_attribute6_o                  =>pqh_ptx_shd.g_old_rec.attribute6
 ,p_attribute7_o                  =>pqh_ptx_shd.g_old_rec.attribute7
 ,p_attribute8_o                  =>pqh_ptx_shd.g_old_rec.attribute8
 ,p_attribute9_o                  =>pqh_ptx_shd.g_old_rec.attribute9
 ,p_attribute10_o                 =>pqh_ptx_shd.g_old_rec.attribute10
 ,p_attribute11_o                 =>pqh_ptx_shd.g_old_rec.attribute11
 ,p_attribute12_o                 =>pqh_ptx_shd.g_old_rec.attribute12
 ,p_attribute13_o                 =>pqh_ptx_shd.g_old_rec.attribute13
 ,p_attribute14_o                 =>pqh_ptx_shd.g_old_rec.attribute14
 ,p_attribute15_o                 =>pqh_ptx_shd.g_old_rec.attribute15
 ,p_attribute16_o                 =>pqh_ptx_shd.g_old_rec.attribute16
 ,p_attribute17_o                 =>pqh_ptx_shd.g_old_rec.attribute17
 ,p_attribute18_o                 =>pqh_ptx_shd.g_old_rec.attribute18
 ,p_attribute19_o                 =>pqh_ptx_shd.g_old_rec.attribute19
 ,p_attribute20_o                 =>pqh_ptx_shd.g_old_rec.attribute20
 ,p_attribute21_o                 =>pqh_ptx_shd.g_old_rec.attribute21
 ,p_attribute22_o                 =>pqh_ptx_shd.g_old_rec.attribute22
 ,p_attribute23_o                 =>pqh_ptx_shd.g_old_rec.attribute23
 ,p_attribute24_o                 =>pqh_ptx_shd.g_old_rec.attribute24
 ,p_attribute25_o                 =>pqh_ptx_shd.g_old_rec.attribute25
 ,p_attribute26_o                 =>pqh_ptx_shd.g_old_rec.attribute26
 ,p_attribute27_o                 =>pqh_ptx_shd.g_old_rec.attribute27
 ,p_attribute28_o                 =>pqh_ptx_shd.g_old_rec.attribute28
 ,p_attribute29_o                 =>pqh_ptx_shd.g_old_rec.attribute29
 ,p_attribute30_o                 =>pqh_ptx_shd.g_old_rec.attribute30
 ,p_attribute_category_o          =>pqh_ptx_shd.g_old_rec.attribute_category
 ,p_object_version_number_o       =>pqh_ptx_shd.g_old_rec.object_version_number
 ,p_pay_basis_id_o		  =>pqh_ptx_shd.g_old_rec.pay_basis_id
 ,p_supervisor_id_o		  =>pqh_ptx_shd.g_old_rec.supervisor_id
 ,p_wf_transaction_category_id_o  =>pqh_ptx_shd.g_old_rec.wf_transaction_category_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_position_transactions'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
  --
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
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy pqh_ptx_shd.g_rec_type) is
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
  If (p_rec.action_date = hr_api.g_date) then
    p_rec.action_date :=
    pqh_ptx_shd.g_old_rec.action_date;
  End If;
  If (p_rec.position_id = hr_api.g_number) then
    p_rec.position_id :=
    pqh_ptx_shd.g_old_rec.position_id;
  End If;
  If (p_rec.availability_status_id = hr_api.g_number) then
    p_rec.availability_status_id :=
    pqh_ptx_shd.g_old_rec.availability_status_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pqh_ptx_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.entry_step_id = hr_api.g_number) then
    p_rec.entry_step_id :=
    pqh_ptx_shd.g_old_rec.entry_step_id;
  End If;
  If (p_rec.entry_grade_rule_id = hr_api.g_number) then
    p_rec.entry_grade_rule_id :=
    pqh_ptx_shd.g_old_rec.entry_grade_rule_id;
  End If;
  If (p_rec.job_id = hr_api.g_number) then
    p_rec.job_id :=
    pqh_ptx_shd.g_old_rec.job_id;
  End If;
  If (p_rec.location_id = hr_api.g_number) then
    p_rec.location_id :=
    pqh_ptx_shd.g_old_rec.location_id;
  End If;
  If (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    pqh_ptx_shd.g_old_rec.organization_id;
  End If;
  If (p_rec.pay_freq_payroll_id = hr_api.g_number) then
    p_rec.pay_freq_payroll_id :=
    pqh_ptx_shd.g_old_rec.pay_freq_payroll_id;
  End If;
  If (p_rec.position_definition_id = hr_api.g_number) then
    p_rec.position_definition_id :=
    pqh_ptx_shd.g_old_rec.position_definition_id;
  End If;
  If (p_rec.prior_position_id = hr_api.g_number) then
    p_rec.prior_position_id :=
    pqh_ptx_shd.g_old_rec.prior_position_id;
  End If;
  If (p_rec.relief_position_id = hr_api.g_number) then
    p_rec.relief_position_id :=
    pqh_ptx_shd.g_old_rec.relief_position_id;
  End If;
  If (p_rec.entry_grade_id = hr_api.g_number) then
    p_rec.entry_grade_id :=
    pqh_ptx_shd.g_old_rec.entry_grade_id;
  End If;
  If (p_rec.successor_position_id = hr_api.g_number) then
    p_rec.successor_position_id :=
    pqh_ptx_shd.g_old_rec.successor_position_id;
  End If;
  If (p_rec.supervisor_position_id = hr_api.g_number) then
    p_rec.supervisor_position_id :=
    pqh_ptx_shd.g_old_rec.supervisor_position_id;
  End If;
  If (p_rec.amendment_date = hr_api.g_date) then
    p_rec.amendment_date :=
    pqh_ptx_shd.g_old_rec.amendment_date;
  End If;
  If (p_rec.amendment_recommendation = hr_api.g_varchar2) then
    p_rec.amendment_recommendation :=
    pqh_ptx_shd.g_old_rec.amendment_recommendation;
  End If;
  If (p_rec.amendment_ref_number = hr_api.g_varchar2) then
    p_rec.amendment_ref_number :=
    pqh_ptx_shd.g_old_rec.amendment_ref_number;
  End If;
  If (p_rec.avail_status_prop_end_date = hr_api.g_date) then
    p_rec.avail_status_prop_end_date :=
    pqh_ptx_shd.g_old_rec.avail_status_prop_end_date;
  End If;
  If (p_rec.bargaining_unit_cd = hr_api.g_varchar2) then
    p_rec.bargaining_unit_cd :=
    pqh_ptx_shd.g_old_rec.bargaining_unit_cd;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    pqh_ptx_shd.g_old_rec.comments;
  End If;
  If (p_rec.country1 = hr_api.g_varchar2) then
    p_rec.country1 :=
    pqh_ptx_shd.g_old_rec.country1;
  End If;
  If (p_rec.country2 = hr_api.g_varchar2) then
    p_rec.country2 :=
    pqh_ptx_shd.g_old_rec.country2;
  End If;
  If (p_rec.country3 = hr_api.g_varchar2) then
    p_rec.country3 :=
    pqh_ptx_shd.g_old_rec.country3;
  End If;
  If (p_rec.current_job_prop_end_date = hr_api.g_date) then
    p_rec.current_job_prop_end_date :=
    pqh_ptx_shd.g_old_rec.current_job_prop_end_date;
  End If;
  If (p_rec.current_org_prop_end_date = hr_api.g_date) then
    p_rec.current_org_prop_end_date :=
    pqh_ptx_shd.g_old_rec.current_org_prop_end_date;
  End If;
  If (p_rec.date_effective = hr_api.g_date) then
    p_rec.date_effective :=
    pqh_ptx_shd.g_old_rec.date_effective;
  End If;
  If (p_rec.date_end = hr_api.g_date) then
    p_rec.date_end :=
    pqh_ptx_shd.g_old_rec.date_end;
  End If;
  If (p_rec.earliest_hire_date = hr_api.g_date) then
    p_rec.earliest_hire_date :=
    pqh_ptx_shd.g_old_rec.earliest_hire_date;
  End If;
  If (p_rec.fill_by_date = hr_api.g_date) then
    p_rec.fill_by_date :=
    pqh_ptx_shd.g_old_rec.fill_by_date;
  End If;
  If (p_rec.frequency = hr_api.g_varchar2) then
    p_rec.frequency :=
    pqh_ptx_shd.g_old_rec.frequency;
  End If;
  If (p_rec.fte = hr_api.g_number) then
    p_rec.fte :=
    pqh_ptx_shd.g_old_rec.fte;
  End If;
  If (p_rec.fte_capacity = hr_api.g_varchar2) then
    p_rec.fte_capacity :=
    pqh_ptx_shd.g_old_rec.fte_capacity;
  End If;
  If (p_rec.location1 = hr_api.g_varchar2) then
    p_rec.location1 :=
    pqh_ptx_shd.g_old_rec.location1;
  End If;
  If (p_rec.location2 = hr_api.g_varchar2) then
    p_rec.location2 :=
    pqh_ptx_shd.g_old_rec.location2;
  End If;
  If (p_rec.location3 = hr_api.g_varchar2) then
    p_rec.location3 :=
    pqh_ptx_shd.g_old_rec.location3;
  End If;
  If (p_rec.max_persons = hr_api.g_number) then
    p_rec.max_persons :=
    pqh_ptx_shd.g_old_rec.max_persons;
  End If;
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    pqh_ptx_shd.g_old_rec.name;
  End If;
  If (p_rec.other_requirements = hr_api.g_varchar2) then
    p_rec.other_requirements :=
    pqh_ptx_shd.g_old_rec.other_requirements;
  End If;
  If (p_rec.overlap_period = hr_api.g_number) then
    p_rec.overlap_period :=
    pqh_ptx_shd.g_old_rec.overlap_period;
  End If;
  If (p_rec.overlap_unit_cd = hr_api.g_varchar2) then
    p_rec.overlap_unit_cd :=
    pqh_ptx_shd.g_old_rec.overlap_unit_cd;
  End If;
  If (p_rec.passport_required = hr_api.g_varchar2) then
    p_rec.passport_required :=
    pqh_ptx_shd.g_old_rec.passport_required;
  End If;
  If (p_rec.pay_term_end_day_cd = hr_api.g_varchar2) then
    p_rec.pay_term_end_day_cd :=
    pqh_ptx_shd.g_old_rec.pay_term_end_day_cd;
  End If;
  If (p_rec.pay_term_end_month_cd = hr_api.g_varchar2) then
    p_rec.pay_term_end_month_cd :=
    pqh_ptx_shd.g_old_rec.pay_term_end_month_cd;
  End If;
  If (p_rec.permanent_temporary_flag = hr_api.g_varchar2) then
    p_rec.permanent_temporary_flag :=
    pqh_ptx_shd.g_old_rec.permanent_temporary_flag;
  End If;
  If (p_rec.permit_recruitment_flag = hr_api.g_varchar2) then
    p_rec.permit_recruitment_flag :=
    pqh_ptx_shd.g_old_rec.permit_recruitment_flag;
  End If;
  If (p_rec.position_type = hr_api.g_varchar2) then
    p_rec.position_type :=
    pqh_ptx_shd.g_old_rec.position_type;
  End If;
  If (p_rec.posting_description = hr_api.g_varchar2) then
    p_rec.posting_description :=
    pqh_ptx_shd.g_old_rec.posting_description;
  End If;
  If (p_rec.probation_period = hr_api.g_number) then
    p_rec.probation_period :=
    pqh_ptx_shd.g_old_rec.probation_period;
  End If;
  If (p_rec.probation_period_unit_cd = hr_api.g_varchar2) then
    p_rec.probation_period_unit_cd :=
    pqh_ptx_shd.g_old_rec.probation_period_unit_cd;
  End If;
  If (p_rec.relocate_domestically = hr_api.g_varchar2) then
    p_rec.relocate_domestically :=
    pqh_ptx_shd.g_old_rec.relocate_domestically;
  End If;
  If (p_rec.relocate_internationally = hr_api.g_varchar2) then
    p_rec.relocate_internationally :=
    pqh_ptx_shd.g_old_rec.relocate_internationally;
  End If;
  If (p_rec.replacement_required_flag = hr_api.g_varchar2) then
    p_rec.replacement_required_flag :=
    pqh_ptx_shd.g_old_rec.replacement_required_flag;
  End If;
  If (p_rec.review_flag = hr_api.g_varchar2) then
    p_rec.review_flag :=
    pqh_ptx_shd.g_old_rec.review_flag;
  End If;
  If (p_rec.seasonal_flag = hr_api.g_varchar2) then
    p_rec.seasonal_flag :=
    pqh_ptx_shd.g_old_rec.seasonal_flag;
  End If;
  If (p_rec.security_requirements = hr_api.g_varchar2) then
    p_rec.security_requirements :=
    pqh_ptx_shd.g_old_rec.security_requirements;
  End If;
  If (p_rec.service_minimum = hr_api.g_varchar2) then
    p_rec.service_minimum :=
    pqh_ptx_shd.g_old_rec.service_minimum;
  End If;
  If (p_rec.term_start_day_cd = hr_api.g_varchar2) then
    p_rec.term_start_day_cd :=
    pqh_ptx_shd.g_old_rec.term_start_day_cd;
  End If;
  If (p_rec.term_start_month_cd = hr_api.g_varchar2) then
    p_rec.term_start_month_cd :=
    pqh_ptx_shd.g_old_rec.term_start_month_cd;
  End If;
  If (p_rec.time_normal_finish = hr_api.g_varchar2) then
    p_rec.time_normal_finish :=
    pqh_ptx_shd.g_old_rec.time_normal_finish;
  End If;
  If (p_rec.time_normal_start = hr_api.g_varchar2) then
    p_rec.time_normal_start :=
    pqh_ptx_shd.g_old_rec.time_normal_start;
  End If;
  If (p_rec.transaction_status = hr_api.g_varchar2) then
    p_rec.transaction_status :=
    pqh_ptx_shd.g_old_rec.transaction_status;
  End If;
  If (p_rec.travel_required = hr_api.g_varchar2) then
    p_rec.travel_required :=
    pqh_ptx_shd.g_old_rec.travel_required;
  End If;
  If (p_rec.working_hours = hr_api.g_number) then
    p_rec.working_hours :=
    pqh_ptx_shd.g_old_rec.working_hours;
  End If;
  If (p_rec.works_council_approval_flag = hr_api.g_varchar2) then
    p_rec.works_council_approval_flag :=
    pqh_ptx_shd.g_old_rec.works_council_approval_flag;
  End If;
  If (p_rec.work_any_country = hr_api.g_varchar2) then
    p_rec.work_any_country :=
    pqh_ptx_shd.g_old_rec.work_any_country;
  End If;
  If (p_rec.work_any_location = hr_api.g_varchar2) then
    p_rec.work_any_location :=
    pqh_ptx_shd.g_old_rec.work_any_location;
  End If;
  If (p_rec.work_period_type_cd = hr_api.g_varchar2) then
    p_rec.work_period_type_cd :=
    pqh_ptx_shd.g_old_rec.work_period_type_cd;
  End If;
  If (p_rec.work_schedule = hr_api.g_varchar2) then
    p_rec.work_schedule :=
    pqh_ptx_shd.g_old_rec.work_schedule;
  End If;
  If (p_rec.work_duration = hr_api.g_varchar2) then
    p_rec.work_duration :=
    pqh_ptx_shd.g_old_rec.work_duration;
  End If;
  If (p_rec.work_term_end_day_cd = hr_api.g_varchar2) then
    p_rec.work_term_end_day_cd :=
    pqh_ptx_shd.g_old_rec.work_term_end_day_cd;
  End If;
  If (p_rec.work_term_end_month_cd = hr_api.g_varchar2) then
    p_rec.work_term_end_month_cd :=
    pqh_ptx_shd.g_old_rec.work_term_end_month_cd;
  End If;
  If (p_rec.proposed_fte_for_layoff = hr_api.g_number) then
    p_rec.proposed_fte_for_layoff :=
    pqh_ptx_shd.g_old_rec.proposed_fte_for_layoff;
  End If;
  If (p_rec.proposed_date_for_layoff = hr_api.g_date) then
    p_rec.proposed_date_for_layoff :=
    pqh_ptx_shd.g_old_rec.proposed_date_for_layoff;
  End If;
  If (p_rec.information1 = hr_api.g_varchar2) then
    p_rec.information1 :=
    pqh_ptx_shd.g_old_rec.information1;
  End If;
  If (p_rec.information2 = hr_api.g_varchar2) then
    p_rec.information2 :=
    pqh_ptx_shd.g_old_rec.information2;
  End If;
  If (p_rec.information3 = hr_api.g_varchar2) then
    p_rec.information3 :=
    pqh_ptx_shd.g_old_rec.information3;
  End If;
  If (p_rec.information4 = hr_api.g_varchar2) then
    p_rec.information4 :=
    pqh_ptx_shd.g_old_rec.information4;
  End If;
  If (p_rec.information5 = hr_api.g_varchar2) then
    p_rec.information5 :=
    pqh_ptx_shd.g_old_rec.information5;
  End If;
  If (p_rec.information6 = hr_api.g_varchar2) then
    p_rec.information6 :=
    pqh_ptx_shd.g_old_rec.information6;
  End If;
  If (p_rec.information7 = hr_api.g_varchar2) then
    p_rec.information7 :=
    pqh_ptx_shd.g_old_rec.information7;
  End If;
  If (p_rec.information8 = hr_api.g_varchar2) then
    p_rec.information8 :=
    pqh_ptx_shd.g_old_rec.information8;
  End If;
  If (p_rec.information9 = hr_api.g_varchar2) then
    p_rec.information9 :=
    pqh_ptx_shd.g_old_rec.information9;
  End If;
  If (p_rec.information10 = hr_api.g_varchar2) then
    p_rec.information10 :=
    pqh_ptx_shd.g_old_rec.information10;
  End If;
  If (p_rec.information11 = hr_api.g_varchar2) then
    p_rec.information11 :=
    pqh_ptx_shd.g_old_rec.information11;
  End If;
  If (p_rec.information12 = hr_api.g_varchar2) then
    p_rec.information12 :=
    pqh_ptx_shd.g_old_rec.information12;
  End If;
  If (p_rec.information13 = hr_api.g_varchar2) then
    p_rec.information13 :=
    pqh_ptx_shd.g_old_rec.information13;
  End If;
  If (p_rec.information14 = hr_api.g_varchar2) then
    p_rec.information14 :=
    pqh_ptx_shd.g_old_rec.information14;
  End If;
  If (p_rec.information15 = hr_api.g_varchar2) then
    p_rec.information15 :=
    pqh_ptx_shd.g_old_rec.information15;
  End If;
  If (p_rec.information16 = hr_api.g_varchar2) then
    p_rec.information16 :=
    pqh_ptx_shd.g_old_rec.information16;
  End If;
  If (p_rec.information17 = hr_api.g_varchar2) then
    p_rec.information17 :=
    pqh_ptx_shd.g_old_rec.information17;
  End If;
  If (p_rec.information18 = hr_api.g_varchar2) then
    p_rec.information18 :=
    pqh_ptx_shd.g_old_rec.information18;
  End If;
  If (p_rec.information19 = hr_api.g_varchar2) then
    p_rec.information19 :=
    pqh_ptx_shd.g_old_rec.information19;
  End If;
  If (p_rec.information20 = hr_api.g_varchar2) then
    p_rec.information20 :=
    pqh_ptx_shd.g_old_rec.information20;
  End If;
  If (p_rec.information21 = hr_api.g_varchar2) then
    p_rec.information21 :=
    pqh_ptx_shd.g_old_rec.information21;
  End If;
  If (p_rec.information22 = hr_api.g_varchar2) then
    p_rec.information22 :=
    pqh_ptx_shd.g_old_rec.information22;
  End If;
  If (p_rec.information23 = hr_api.g_varchar2) then
    p_rec.information23 :=
    pqh_ptx_shd.g_old_rec.information23;
  End If;
  If (p_rec.information24 = hr_api.g_varchar2) then
    p_rec.information24 :=
    pqh_ptx_shd.g_old_rec.information24;
  End If;
  If (p_rec.information25 = hr_api.g_varchar2) then
    p_rec.information25 :=
    pqh_ptx_shd.g_old_rec.information25;
  End If;
  If (p_rec.information26 = hr_api.g_varchar2) then
    p_rec.information26 :=
    pqh_ptx_shd.g_old_rec.information26;
  End If;
  If (p_rec.information27 = hr_api.g_varchar2) then
    p_rec.information27 :=
    pqh_ptx_shd.g_old_rec.information27;
  End If;
  If (p_rec.information28 = hr_api.g_varchar2) then
    p_rec.information28 :=
    pqh_ptx_shd.g_old_rec.information28;
  End If;
  If (p_rec.information29 = hr_api.g_varchar2) then
    p_rec.information29 :=
    pqh_ptx_shd.g_old_rec.information29;
  End If;
  If (p_rec.information30 = hr_api.g_varchar2) then
    p_rec.information30 :=
    pqh_ptx_shd.g_old_rec.information30;
  End If;
  If (p_rec.information_category = hr_api.g_varchar2) then
    p_rec.information_category :=
    pqh_ptx_shd.g_old_rec.information_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    pqh_ptx_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    pqh_ptx_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    pqh_ptx_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    pqh_ptx_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    pqh_ptx_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    pqh_ptx_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    pqh_ptx_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    pqh_ptx_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    pqh_ptx_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    pqh_ptx_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    pqh_ptx_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    pqh_ptx_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    pqh_ptx_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    pqh_ptx_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    pqh_ptx_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    pqh_ptx_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    pqh_ptx_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    pqh_ptx_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    pqh_ptx_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    pqh_ptx_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.attribute21 = hr_api.g_varchar2) then
    p_rec.attribute21 :=
    pqh_ptx_shd.g_old_rec.attribute21;
  End If;
  If (p_rec.attribute22 = hr_api.g_varchar2) then
    p_rec.attribute22 :=
    pqh_ptx_shd.g_old_rec.attribute22;
  End If;
  If (p_rec.attribute23 = hr_api.g_varchar2) then
    p_rec.attribute23 :=
    pqh_ptx_shd.g_old_rec.attribute23;
  End If;
  If (p_rec.attribute24 = hr_api.g_varchar2) then
    p_rec.attribute24 :=
    pqh_ptx_shd.g_old_rec.attribute24;
  End If;
  If (p_rec.attribute25 = hr_api.g_varchar2) then
    p_rec.attribute25 :=
    pqh_ptx_shd.g_old_rec.attribute25;
  End If;
  If (p_rec.attribute26 = hr_api.g_varchar2) then
    p_rec.attribute26 :=
    pqh_ptx_shd.g_old_rec.attribute26;
  End If;
  If (p_rec.attribute27 = hr_api.g_varchar2) then
    p_rec.attribute27 :=
    pqh_ptx_shd.g_old_rec.attribute27;
  End If;
  If (p_rec.attribute28 = hr_api.g_varchar2) then
    p_rec.attribute28 :=
    pqh_ptx_shd.g_old_rec.attribute28;
  End If;
  If (p_rec.attribute29 = hr_api.g_varchar2) then
    p_rec.attribute29 :=
    pqh_ptx_shd.g_old_rec.attribute29;
  End If;
  If (p_rec.attribute30 = hr_api.g_varchar2) then
    p_rec.attribute30 :=
    pqh_ptx_shd.g_old_rec.attribute30;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    pqh_ptx_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.pay_basis_id = hr_api.g_number) then
    p_rec.pay_basis_id :=
    pqh_ptx_shd.g_old_rec.pay_basis_id;
  End If;
  If (p_rec.supervisor_id = hr_api.g_number) then
    p_rec.supervisor_id :=
    pqh_ptx_shd.g_old_rec.supervisor_id;
  End If;
  If (p_rec.wf_transaction_category_id = hr_api.g_number) then
    p_rec.wf_transaction_category_id :=
    pqh_ptx_shd.g_old_rec.wf_transaction_category_id;
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
  p_effective_date in date,
  p_rec        in out nocopy pqh_ptx_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqh_ptx_shd.lck
	(
	p_rec.position_transaction_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  pqh_ptx_bus.update_validate(p_rec
  ,p_effective_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(
p_effective_date,p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date in date,
  p_position_transaction_id      in number,
  p_action_date                  in date             default hr_api.g_date,
  p_position_id                  in number           default hr_api.g_number,
  p_availability_status_id       in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_entry_step_id                in number           default hr_api.g_number,
  p_entry_grade_rule_id                in number           default hr_api.g_number,
  p_job_id                       in number           default hr_api.g_number,
  p_location_id                  in number           default hr_api.g_number,
  p_organization_id              in number           default hr_api.g_number,
  p_pay_freq_payroll_id          in number           default hr_api.g_number,
  p_position_definition_id       in number           default hr_api.g_number,
  p_prior_position_id            in number           default hr_api.g_number,
  p_relief_position_id           in number           default hr_api.g_number,
  p_entry_grade_id        in number           default hr_api.g_number,
  p_successor_position_id        in number           default hr_api.g_number,
  p_supervisor_position_id       in number           default hr_api.g_number,
  p_amendment_date               in date             default hr_api.g_date,
  p_amendment_recommendation     in varchar2         default hr_api.g_varchar2,
  p_amendment_ref_number         in varchar2         default hr_api.g_varchar2,
  p_avail_status_prop_end_date   in date             default hr_api.g_date,
  p_bargaining_unit_cd           in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_country1                     in varchar2         default hr_api.g_varchar2,
  p_country2                     in varchar2         default hr_api.g_varchar2,
  p_country3                     in varchar2         default hr_api.g_varchar2,
  p_current_job_prop_end_date    in date             default hr_api.g_date,
  p_current_org_prop_end_date    in date             default hr_api.g_date,
  p_date_effective               in date             default hr_api.g_date,
  p_date_end                     in date             default hr_api.g_date,
  p_earliest_hire_date           in date             default hr_api.g_date,
  p_fill_by_date                 in date             default hr_api.g_date,
  p_frequency                    in varchar2         default hr_api.g_varchar2,
  p_fte                          in number           default hr_api.g_number,
  p_fte_capacity                 in varchar2         default hr_api.g_varchar2,
  p_location1                    in varchar2         default hr_api.g_varchar2,
  p_location2                    in varchar2         default hr_api.g_varchar2,
  p_location3                    in varchar2         default hr_api.g_varchar2,
  p_max_persons                  in number           default hr_api.g_number,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_other_requirements           in varchar2         default hr_api.g_varchar2,
  p_overlap_period               in number           default hr_api.g_number,
  p_overlap_unit_cd              in varchar2         default hr_api.g_varchar2,
  p_passport_required            in varchar2         default hr_api.g_varchar2,
  p_pay_term_end_day_cd          in varchar2         default hr_api.g_varchar2,
  p_pay_term_end_month_cd        in varchar2         default hr_api.g_varchar2,
  p_permanent_temporary_flag     in varchar2         default hr_api.g_varchar2,
  p_permit_recruitment_flag      in varchar2         default hr_api.g_varchar2,
  p_position_type                in varchar2         default hr_api.g_varchar2,
  p_posting_description          in varchar2         default hr_api.g_varchar2,
  p_probation_period             in number           default hr_api.g_number,
  p_probation_period_unit_cd     in varchar2         default hr_api.g_varchar2,
  p_relocate_domestically        in varchar2         default hr_api.g_varchar2,
  p_relocate_internationally     in varchar2         default hr_api.g_varchar2,
  p_replacement_required_flag    in varchar2         default hr_api.g_varchar2,
  p_review_flag                  in varchar2         default hr_api.g_varchar2,
  p_seasonal_flag                in varchar2         default hr_api.g_varchar2,
  p_security_requirements        in varchar2         default hr_api.g_varchar2,
  p_service_minimum              in varchar2         default hr_api.g_varchar2,
  p_term_start_day_cd            in varchar2         default hr_api.g_varchar2,
  p_term_start_month_cd          in varchar2         default hr_api.g_varchar2,
  p_time_normal_finish           in varchar2         default hr_api.g_varchar2,
  p_time_normal_start            in varchar2         default hr_api.g_varchar2,
  p_transaction_status           in varchar2         default hr_api.g_varchar2,
  p_travel_required              in varchar2         default hr_api.g_varchar2,
  p_working_hours                in number           default hr_api.g_number,
  p_works_council_approval_flag  in varchar2         default hr_api.g_varchar2,
  p_work_any_country             in varchar2         default hr_api.g_varchar2,
  p_work_any_location            in varchar2         default hr_api.g_varchar2,
  p_work_period_type_cd          in varchar2         default hr_api.g_varchar2,
  p_work_schedule                in varchar2         default hr_api.g_varchar2,
  p_work_duration                in varchar2         default hr_api.g_varchar2,
  p_work_term_end_day_cd         in varchar2         default hr_api.g_varchar2,
  p_work_term_end_month_cd       in varchar2         default hr_api.g_varchar2,
  p_proposed_fte_for_layoff      in number           default hr_api.g_number,
  p_proposed_date_for_layoff     in date             default hr_api.g_date,
  p_information1                 in varchar2         default hr_api.g_varchar2,
  p_information2                 in varchar2         default hr_api.g_varchar2,
  p_information3                 in varchar2         default hr_api.g_varchar2,
  p_information4                 in varchar2         default hr_api.g_varchar2,
  p_information5                 in varchar2         default hr_api.g_varchar2,
  p_information6                 in varchar2         default hr_api.g_varchar2,
  p_information7                 in varchar2         default hr_api.g_varchar2,
  p_information8                 in varchar2         default hr_api.g_varchar2,
  p_information9                 in varchar2         default hr_api.g_varchar2,
  p_information10                in varchar2         default hr_api.g_varchar2,
  p_information11                in varchar2         default hr_api.g_varchar2,
  p_information12                in varchar2         default hr_api.g_varchar2,
  p_information13                in varchar2         default hr_api.g_varchar2,
  p_information14                in varchar2         default hr_api.g_varchar2,
  p_information15                in varchar2         default hr_api.g_varchar2,
  p_information16                in varchar2         default hr_api.g_varchar2,
  p_information17                in varchar2         default hr_api.g_varchar2,
  p_information18                in varchar2         default hr_api.g_varchar2,
  p_information19                in varchar2         default hr_api.g_varchar2,
  p_information20                in varchar2         default hr_api.g_varchar2,
  p_information21                in varchar2         default hr_api.g_varchar2,
  p_information22                in varchar2         default hr_api.g_varchar2,
  p_information23                in varchar2         default hr_api.g_varchar2,
  p_information24                in varchar2         default hr_api.g_varchar2,
  p_information25                in varchar2         default hr_api.g_varchar2,
  p_information26                in varchar2         default hr_api.g_varchar2,
  p_information27                in varchar2         default hr_api.g_varchar2,
  p_information28                in varchar2         default hr_api.g_varchar2,
  p_information29                in varchar2         default hr_api.g_varchar2,
  p_information30                in varchar2         default hr_api.g_varchar2,
  p_information_category         in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_attribute21                  in varchar2         default hr_api.g_varchar2,
  p_attribute22                  in varchar2         default hr_api.g_varchar2,
  p_attribute23                  in varchar2         default hr_api.g_varchar2,
  p_attribute24                  in varchar2         default hr_api.g_varchar2,
  p_attribute25                  in varchar2         default hr_api.g_varchar2,
  p_attribute26                  in varchar2         default hr_api.g_varchar2,
  p_attribute27                  in varchar2         default hr_api.g_varchar2,
  p_attribute28                  in varchar2         default hr_api.g_varchar2,
  p_attribute29                  in varchar2         default hr_api.g_varchar2,
  p_attribute30                  in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number ,
  p_pay_basis_id		 in number	     default hr_api.g_number,
  p_supervisor_id		 in number	     default hr_api.g_number,
  p_wf_transaction_category_id	 in number	     default hr_api.g_number
  ) is
--
  l_rec	  pqh_ptx_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_ptx_shd.convert_args
  (
  p_position_transaction_id,
  p_action_date,
  p_position_id,
  p_availability_status_id,
  p_business_group_id,
  p_entry_step_id,
  p_entry_grade_rule_id,
  p_job_id,
  p_location_id,
  p_organization_id,
  p_pay_freq_payroll_id,
  p_position_definition_id,
  p_prior_position_id,
  p_relief_position_id,
  p_entry_grade_id,
  p_successor_position_id,
  p_supervisor_position_id,
  p_amendment_date,
  p_amendment_recommendation,
  p_amendment_ref_number,
  p_avail_status_prop_end_date,
  p_bargaining_unit_cd,
  p_comments,
  p_country1,
  p_country2,
  p_country3,
  p_current_job_prop_end_date,
  p_current_org_prop_end_date,
  p_date_effective,
  p_date_end,
  p_earliest_hire_date,
  p_fill_by_date,
  p_frequency,
  p_fte,
  p_fte_capacity,
  p_location1,
  p_location2,
  p_location3,
  p_max_persons,
  p_name,
  p_other_requirements,
  p_overlap_period,
  p_overlap_unit_cd,
  p_passport_required,
  p_pay_term_end_day_cd,
  p_pay_term_end_month_cd,
  p_permanent_temporary_flag,
  p_permit_recruitment_flag,
  p_position_type,
  p_posting_description,
  p_probation_period,
  p_probation_period_unit_cd,
  p_relocate_domestically,
  p_relocate_internationally,
  p_replacement_required_flag,
  p_review_flag,
  p_seasonal_flag,
  p_security_requirements,
  p_service_minimum,
  p_term_start_day_cd,
  p_term_start_month_cd,
  p_time_normal_finish,
  p_time_normal_start,
  p_transaction_status,
  p_travel_required,
  p_working_hours,
  p_works_council_approval_flag,
  p_work_any_country,
  p_work_any_location,
  p_work_period_type_cd,
  p_work_schedule,
  p_work_duration,
  p_work_term_end_day_cd,
  p_work_term_end_month_cd,
  p_proposed_fte_for_layoff,
  p_proposed_date_for_layoff,
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
  p_object_version_number,
  p_pay_basis_id,
  p_supervisor_id,
  p_wf_transaction_category_id
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(
    p_effective_date,l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqh_ptx_upd;

/

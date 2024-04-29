--------------------------------------------------------
--  DDL for Package Body PQH_PTX_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PTX_INS" as
/* $Header: pqptxrhi.pkb 120.0.12010000.2 2008/08/05 13:41:09 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_ptx_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy pqh_ptx_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: pqh_position_transactions
  --
  insert into pqh_position_transactions
  (	position_transaction_id,
	action_date,
	position_id,
	availability_status_id,
	business_group_id,
	entry_step_id,
	entry_grade_rule_id,
	job_id,
	location_id,
	organization_id,
	pay_freq_payroll_id,
	position_definition_id,
	prior_position_id,
	relief_position_id,
	entry_grade_id,
	successor_position_id,
	supervisor_position_id,
	amendment_date,
	amendment_recommendation,
	amendment_ref_number,
	avail_status_prop_end_date,
	bargaining_unit_cd,
	comments,
	country1,
	country2,
	country3,
	current_job_prop_end_date,
	current_org_prop_end_date,
	date_effective,
	date_end,
	earliest_hire_date,
	fill_by_date,
	frequency,
	fte,
        fte_capacity,
	location1,
	location2,
	location3,
	max_persons,
	name,
	other_requirements,
	overlap_period,
	overlap_unit_cd,
	passport_required,
	pay_term_end_day_cd,
	pay_term_end_month_cd,
	permanent_temporary_flag,
	permit_recruitment_flag,
	position_type,
	posting_description,
	probation_period,
	probation_period_unit_cd,
	relocate_domestically,
	relocate_internationally,
	replacement_required_flag,
	review_flag,
	seasonal_flag,
	security_requirements,
	service_minimum,
	term_start_day_cd,
	term_start_month_cd,
	time_normal_finish,
	time_normal_start,
	transaction_status,
	travel_required,
	working_hours,
	works_council_approval_flag,
	work_any_country,
	work_any_location,
	work_period_type_cd,
	work_schedule,
	work_duration,
	work_term_end_day_cd,
	work_term_end_month_cd,
        proposed_fte_for_layoff,
        proposed_date_for_layoff,
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
	object_version_number ,
	pay_basis_id,
	supervisor_id,
	wf_transaction_category_id
  )
  Values
  (	p_rec.position_transaction_id,
	p_rec.action_date,
	p_rec.position_id,
	p_rec.availability_status_id,
	p_rec.business_group_id,
	p_rec.entry_step_id,
	p_rec.entry_grade_rule_id,
	p_rec.job_id,
	p_rec.location_id,
	p_rec.organization_id,
	p_rec.pay_freq_payroll_id,
	p_rec.position_definition_id,
	p_rec.prior_position_id,
	p_rec.relief_position_id,
	p_rec.entry_grade_id,
	p_rec.successor_position_id,
	p_rec.supervisor_position_id,
	p_rec.amendment_date,
	p_rec.amendment_recommendation,
	p_rec.amendment_ref_number,
	p_rec.avail_status_prop_end_date,
	p_rec.bargaining_unit_cd,
	p_rec.comments,
	p_rec.country1,
	p_rec.country2,
	p_rec.country3,
	p_rec.current_job_prop_end_date,
	p_rec.current_org_prop_end_date,
	p_rec.date_effective,
	p_rec.date_end,
	p_rec.earliest_hire_date,
	p_rec.fill_by_date,
	p_rec.frequency,
	p_rec.fte,
        p_rec.fte_capacity,
	p_rec.location1,
	p_rec.location2,
	p_rec.location3,
	p_rec.max_persons,
	p_rec.name,
	p_rec.other_requirements,
	p_rec.overlap_period,
	p_rec.overlap_unit_cd,
	p_rec.passport_required,
	p_rec.pay_term_end_day_cd,
	p_rec.pay_term_end_month_cd,
	p_rec.permanent_temporary_flag,
	p_rec.permit_recruitment_flag,
	p_rec.position_type,
	p_rec.posting_description,
	p_rec.probation_period,
	p_rec.probation_period_unit_cd,
	p_rec.relocate_domestically,
	p_rec.relocate_internationally,
	p_rec.replacement_required_flag,
	p_rec.review_flag,
	p_rec.seasonal_flag,
	p_rec.security_requirements,
	p_rec.service_minimum,
	p_rec.term_start_day_cd,
	p_rec.term_start_month_cd,
	p_rec.time_normal_finish,
	p_rec.time_normal_start,
	p_rec.transaction_status,
	p_rec.travel_required,
	p_rec.working_hours,
	p_rec.works_council_approval_flag,
	p_rec.work_any_country,
	p_rec.work_any_location,
	p_rec.work_period_type_cd,
	p_rec.work_schedule,
	p_rec.work_duration,
	p_rec.work_term_end_day_cd,
	p_rec.work_term_end_month_cd,
        p_rec.proposed_fte_for_layoff,
        p_rec.proposed_date_for_layoff,
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
	p_rec.object_version_number ,
	p_rec.pay_basis_id,
	p_rec.supervisor_id,
	p_rec.wf_transaction_category_id
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
Procedure pre_insert(p_rec  in out nocopy pqh_ptx_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pqh_position_transactions_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.position_transaction_id;
  Close C_Sel1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
Procedure post_insert(
p_effective_date in date,p_rec in pqh_ptx_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
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
--  if (nvl(p_rec.review_flag,'N') = 'Y' and nvl(l_review_flag,'N') = 'Y'
--    and nvl(pqh_ptx_shd.g_old_rec.review_flag,'N') = 'N')then

  if ( nvl(l_review_flag,'N') = 'Y')then
    hr_utility.set_message(8302, 'PQH_POSITION_UNDER_REVIEW');
    hr_utility.raise_error;
  /* Bug 6524175 Changes
  elsif ((nvl(p_rec.review_flag,'N') = 'Y' and nvl(l_review_flag,'N') = 'N'))then */
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
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    pqh_ptx_rki.after_insert
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
 ,p_pay_basis_id		  =>p_rec.pay_basis_id
 ,p_supervisor_id		  =>p_rec.supervisor_id
 ,p_wf_transaction_category_id	  =>p_rec.wf_transaction_category_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_position_transactions'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_rec        in out nocopy pqh_ptx_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqh_ptx_bus.insert_validate(p_rec
  ,p_effective_date);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec);
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(
p_effective_date,p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_position_transaction_id      out nocopy number,
  p_action_date                  in date             default null,
  p_position_id                  in number           default null,
  p_availability_status_id       in number           default null,
  p_business_group_id            in number           default null,
  p_entry_step_id                in number           default null,
  p_entry_grade_rule_id                in number           default null,
  p_job_id                       in number           default null,
  p_location_id                  in number           default null,
  p_organization_id              in number           default null,
  p_pay_freq_payroll_id          in number           default null,
  p_position_definition_id       in number           default null,
  p_prior_position_id            in number           default null,
  p_relief_position_id           in number           default null,
  p_entry_grade_id        in number           default null,
  p_successor_position_id        in number           default null,
  p_supervisor_position_id       in number           default null,
  p_amendment_date               in date             default null,
  p_amendment_recommendation     in varchar2         default null,
  p_amendment_ref_number         in varchar2         default null,
  p_avail_status_prop_end_date   in date             default null,
  p_bargaining_unit_cd           in varchar2         default null,
  p_comments                     in varchar2         default null,
  p_country1                     in varchar2         default null,
  p_country2                     in varchar2         default null,
  p_country3                     in varchar2         default null,
  p_current_job_prop_end_date    in date             default null,
  p_current_org_prop_end_date    in date             default null,
  p_date_effective               in date             default null,
  p_date_end                     in date             default null,
  p_earliest_hire_date           in date             default null,
  p_fill_by_date                 in date             default null,
  p_frequency                    in varchar2         default null,
  p_fte                          in number           default null,
  p_fte_capacity                 in varchar2         default null,
  p_location1                    in varchar2         default null,
  p_location2                    in varchar2         default null,
  p_location3                    in varchar2         default null,
  p_max_persons                  in number           default null,
  p_name                         in varchar2         default null,
  p_other_requirements           in varchar2         default null,
  p_overlap_period               in number           default null,
  p_overlap_unit_cd              in varchar2         default null,
  p_passport_required            in varchar2         default null,
  p_pay_term_end_day_cd          in varchar2         default null,
  p_pay_term_end_month_cd        in varchar2         default null,
  p_permanent_temporary_flag     in varchar2         default null,
  p_permit_recruitment_flag      in varchar2         default null,
  p_position_type                in varchar2         default null,
  p_posting_description          in varchar2         default null,
  p_probation_period             in number           default null,
  p_probation_period_unit_cd     in varchar2         default null,
  p_relocate_domestically        in varchar2         default null,
  p_relocate_internationally     in varchar2         default null,
  p_replacement_required_flag    in varchar2         default null,
  p_review_flag                  in varchar2         default null,
  p_seasonal_flag                in varchar2         default null,
  p_security_requirements        in varchar2         default null,
  p_service_minimum              in varchar2         default null,
  p_term_start_day_cd            in varchar2         default null,
  p_term_start_month_cd          in varchar2         default null,
  p_time_normal_finish           in varchar2         default null,
  p_time_normal_start            in varchar2         default null,
  p_transaction_status           in varchar2         default null,
  p_travel_required              in varchar2         default null,
  p_working_hours                in number           default null,
  p_works_council_approval_flag  in varchar2         default null,
  p_work_any_country             in varchar2         default null,
  p_work_any_location            in varchar2         default null,
  p_work_period_type_cd          in varchar2         default null,
  p_work_schedule                in varchar2         default null,
  p_work_duration                in varchar2         default null,
  p_work_term_end_day_cd         in varchar2         default null,
  p_work_term_end_month_cd       in varchar2         default null,
  p_proposed_fte_for_layoff      in number           default null,
  p_proposed_date_for_layoff     in date             default null,
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
  p_object_version_number        out nocopy number,
  p_pay_basis_id	         in number           default null,
  p_supervisor_id	         in number           default null,
  p_wf_transaction_category_id	 in number           default null
  ) is
--
  l_rec	  pqh_ptx_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqh_ptx_shd.convert_args
  (
  null,
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
  null ,
  p_pay_basis_id,
  p_supervisor_id,
  p_wf_transaction_category_id
  );
  --
  -- Having converted the arguments into the pqh_ptx_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_position_transaction_id := l_rec.position_transaction_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqh_ptx_ins;

/

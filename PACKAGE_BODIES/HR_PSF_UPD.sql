--------------------------------------------------------
--  DDL for Package Body HR_PSF_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PSF_UPD" as
/* $Header: hrpsfrhi.pkb 120.6.12010000.6 2009/11/26 10:02:00 brsinha ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_psf_upd.';  -- Global package name
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
--   2) To update the specified row in the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   update_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_dml
   (p_rec          in out nocopy hr_psf_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc varchar2(72)  ;
--
Begin
if g_debug then
l_proc    := g_package||'dt_update_dml';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  -- Added by Anirban for bug #5855944

    update per_all_positions
    set
  	position_id 			= p_rec.position_id,
	business_group_id 		= p_rec.business_group_id,
	job_id 				= p_rec.job_id,
	organization_id 		= p_rec.organization_id,
	successor_position_id 		= p_rec.successor_position_id,
	relief_position_id 		= p_rec.relief_position_id,
	location_id 			= p_rec.location_id,
	position_definition_id 		= p_rec.position_definition_id,
	date_effective 			= p_rec.date_effective,
	comments 			= p_rec.comments,
	date_end 			= p_rec.date_end,
	frequency 			= p_rec.frequency,
	name 				= p_rec.name,
	probation_period 		= p_rec.probation_period,
	probation_period_units 		= p_rec.probation_period_unit_cd,
	replacement_required_flag 	= p_rec.replacement_required_flag,
	time_normal_finish 		= p_rec.time_normal_finish,
	time_normal_start 		= p_rec.time_normal_start,
        status 				= p_rec.status,
	working_hours 			= p_rec.working_hours,
	request_id 			= p_rec.request_id,
	program_application_id 		= p_rec.program_application_id,
	program_id 			= p_rec.program_id,
	program_update_date 		= p_rec.program_update_date,
	attribute_category 		= p_rec.attribute_category,
	attribute1                      = p_rec.attribute1,
	attribute2                      = p_rec.attribute2,
	attribute3                      = p_rec.attribute3,
	attribute4                      = p_rec.attribute4,
	attribute5                      = p_rec.attribute5,
	attribute6                      = p_rec.attribute6,
	attribute7                      = p_rec.attribute7,
	attribute8                      = p_rec.attribute8,
	attribute9                      = p_rec.attribute9,
	attribute10                     = p_rec.attribute10,
	attribute11                     = p_rec.attribute11,
	attribute12                     = p_rec.attribute12,
	attribute13                     = p_rec.attribute13,
	attribute14                     = p_rec.attribute14,
	attribute15                     = p_rec.attribute15,
	attribute16                     = p_rec.attribute16,
	attribute17                     = p_rec.attribute17,
	attribute18                     = p_rec.attribute18,
	attribute19                     = p_rec.attribute19,
	attribute20                     = p_rec.attribute20,
	object_version_number           = p_rec.object_version_number

   where   position_id = p_rec.position_id ;

    -- End Addition by Anirban
  If (p_datetrack_mode = 'CORRECTION') then
if g_debug then
    hr_utility.set_location(l_proc, 10);
end if;
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
     (p_base_table_name => 'hr_all_positions_f',
      p_base_key_column => 'position_id',
      p_base_key_value  => p_rec.position_id);
    --
    --
    -- Update the hr_all_positions_f Row
    --
    update  hr_all_positions_f
    set
    position_id                     = p_rec.position_id,
    availability_status_id          = p_rec.availability_status_id,
    business_group_id               = p_rec.business_group_id,
    entry_step_id                   = p_rec.entry_step_id,
    entry_grade_rule_id             = p_rec.entry_grade_rule_id,
    job_id                          = p_rec.job_id,
    location_id                     = p_rec.location_id,
    organization_id                 = p_rec.organization_id,
    pay_freq_payroll_id             = p_rec.pay_freq_payroll_id,
    position_definition_id          = p_rec.position_definition_id,
    position_transaction_id         = p_rec.position_transaction_id,
    prior_position_id               = p_rec.prior_position_id,
    relief_position_id              = p_rec.relief_position_id,
    entry_grade_id           = p_rec.entry_grade_id,
    successor_position_id           = p_rec.successor_position_id,
    supervisor_position_id          = p_rec.supervisor_position_id,
    amendment_date                  = p_rec.amendment_date,
    amendment_recommendation        = p_rec.amendment_recommendation,
    amendment_ref_number            = p_rec.amendment_ref_number,
    bargaining_unit_cd              = p_rec.bargaining_unit_cd,
    current_job_prop_end_date       = p_rec.current_job_prop_end_date,
    current_org_prop_end_date       = p_rec.current_org_prop_end_date,
    avail_status_prop_end_date      = p_rec.avail_status_prop_end_date,
    date_effective                  = p_rec.date_effective,
    date_end                        = p_rec.date_end,
    earliest_hire_date              = p_rec.earliest_hire_date,
    fill_by_date                    = p_rec.fill_by_date,
    frequency                       = p_rec.frequency,
    fte                             = p_rec.fte,
    max_persons                     = p_rec.max_persons,
    name                            = p_rec.name,
    overlap_period                  = p_rec.overlap_period,
    overlap_unit_cd                 = p_rec.overlap_unit_cd,
    pay_term_end_day_cd             = p_rec.pay_term_end_day_cd,
    pay_term_end_month_cd           = p_rec.pay_term_end_month_cd,
    permanent_temporary_flag        = p_rec.permanent_temporary_flag,
    permit_recruitment_flag         = p_rec.permit_recruitment_flag,
    position_type                   = p_rec.position_type,
    posting_description             = p_rec.posting_description,
    probation_period                = p_rec.probation_period,
    probation_period_unit_cd        = p_rec.probation_period_unit_cd,
    replacement_required_flag       = p_rec.replacement_required_flag,
    review_flag                     = p_rec.review_flag,
    seasonal_flag                   = p_rec.seasonal_flag,
    security_requirements           = p_rec.security_requirements,
    status                          = p_rec.status,
    term_start_day_cd               = p_rec.term_start_day_cd,
    term_start_month_cd             = p_rec.term_start_month_cd,
    time_normal_finish              = p_rec.time_normal_finish,
    time_normal_start               = p_rec.time_normal_start,
    update_source_cd                = p_rec.update_source_cd,
    working_hours                   = p_rec.working_hours,
    works_council_approval_flag     = p_rec.works_council_approval_flag,
    work_period_type_cd             = p_rec.work_period_type_cd,
    work_term_end_day_cd            = p_rec.work_term_end_day_cd,
    work_term_end_month_cd          = p_rec.work_term_end_month_cd,
    comments                        = p_rec.comments,
    proposed_fte_for_layoff         = p_rec.proposed_fte_for_layoff,
    proposed_date_for_layoff        = p_rec.proposed_date_for_layoff,
    pay_basis_id                    = p_rec.pay_basis_id,
    supervisor_id                   = p_rec.supervisor_id,
    copied_to_old_table_flag        = p_rec.copied_to_old_table_flag,
    information1                    = p_rec.information1,
    information2                    = p_rec.information2,
    information3                    = p_rec.information3,
    information4                    = p_rec.information4,
    information5                    = p_rec.information5,
    information6                    = p_rec.information6,
    information7                    = p_rec.information7,
    information8                    = p_rec.information8,
    information9                    = p_rec.information9,
    information10                   = p_rec.information10,
    information11                   = p_rec.information11,
    information12                   = p_rec.information12,
    information13                   = p_rec.information13,
    information14                   = p_rec.information14,
    information15                   = p_rec.information15,
    information16                   = p_rec.information16,
    information17                   = p_rec.information17,
    information18                   = p_rec.information18,
    information19                   = p_rec.information19,
    information20                   = p_rec.information20,
    information21                   = p_rec.information21,
    information22                   = p_rec.information22,
    information23                   = p_rec.information23,
    information24                   = p_rec.information24,
    information25                   = p_rec.information25,
    information26                   = p_rec.information26,
    information27                   = p_rec.information27,
    information28                   = p_rec.information28,
    information29                   = p_rec.information29,
    information30                   = p_rec.information30,
    information_category            = p_rec.information_category,
    attribute1                      = p_rec.attribute1,
    attribute2                      = p_rec.attribute2,
    attribute3                      = p_rec.attribute3,
    attribute4                      = p_rec.attribute4,
    attribute5                      = p_rec.attribute5,
    attribute6                      = p_rec.attribute6,
    attribute7                      = p_rec.attribute7,
    attribute8                      = p_rec.attribute8,
    attribute9                      = p_rec.attribute9,
    attribute10                     = p_rec.attribute10,
    attribute11                     = p_rec.attribute11,
    attribute12                     = p_rec.attribute12,
    attribute13                     = p_rec.attribute13,
    attribute14                     = p_rec.attribute14,
    attribute15                     = p_rec.attribute15,
    attribute16                     = p_rec.attribute16,
    attribute17                     = p_rec.attribute17,
    attribute18                     = p_rec.attribute18,
    attribute19                     = p_rec.attribute19,
    attribute20                     = p_rec.attribute20,
    attribute21                     = p_rec.attribute21,
    attribute22                     = p_rec.attribute22,
    attribute23                     = p_rec.attribute23,
    attribute24                     = p_rec.attribute24,
    attribute25                     = p_rec.attribute25,
    attribute26                     = p_rec.attribute26,
    attribute27                     = p_rec.attribute27,
    attribute28                     = p_rec.attribute28,
    attribute29                     = p_rec.attribute29,
    attribute30                     = p_rec.attribute30,
    attribute_category              = p_rec.attribute_category,
    request_id                      = p_rec.request_id,
    program_application_id          = p_rec.program_application_id,
    program_id                      = p_rec.program_id,
    program_update_date             = p_rec.program_update_date,
    object_version_number           = p_rec.object_version_number
    where   position_id = p_rec.position_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    --
    -- Set the effective start and end dates
    --
    p_rec.effective_start_date := p_validation_start_date;
    p_rec.effective_end_date   := p_validation_end_date;
  End If;
--
if g_debug then
hr_utility.set_location(' Leaving:'||l_proc, 15);
end if;
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
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
   (p_rec          in out nocopy hr_psf_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc varchar2(72);
--
Begin
g_debug := hr_utility.debug_enabled;
if g_debug then
 l_proc   := g_package||'update_dml';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  dt_update_dml(p_rec         => p_rec,
      p_effective_date  => p_effective_date,
      p_datetrack_mode  => p_datetrack_mode,
            p_validation_start_date => p_validation_start_date,
      p_validation_end_date   => p_validation_end_date);
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
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
-- the validation_start_date.
--   3) Call the insert_dml process to insert the new updated row
--      details..
--
-- Prerequisites:
--   This is an internal procedure which is called from the
--   pre_update procedure.
--
-- In Parameters:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_update
   (p_rec          in out nocopy hr_psf_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc          varchar2(72) ;
  l_dummy_version_number number;
--
Begin
if g_debug then
 l_proc            := g_package||'dt_pre_update';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  If (p_datetrack_mode <> 'CORRECTION') then
if g_debug then
    hr_utility.set_location(l_proc, 10);
end if;
    --
    -- Update the current effective end date
    --
    hr_psf_shd.upd_effective_end_date
     (p_effective_date         => p_effective_date,
      p_base_key_value         => p_rec.position_id,
      p_new_effective_end_date => (p_validation_start_date - 1),
      p_validation_start_date  => p_validation_start_date,
      p_validation_end_date    => p_validation_end_date,
      p_object_version_number  => l_dummy_version_number);
    --
    If (p_datetrack_mode = 'UPDATE_OVERRIDE') then
if g_debug then
      hr_utility.set_location(l_proc, 15);
end if;
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows,
      --
      hr_psf_del.delete_dml
        (p_rec        => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => p_datetrack_mode,
    p_validation_start_date => p_validation_start_date,
    p_validation_end_date   => p_validation_end_date);
    End If;
if g_debug then
    hr_utility.set_location(l_proc, 20);
end if;
    --
    -- We must now insert the updated row
    --
    hr_psf_ins.insert_dml
      (p_rec         => p_rec,
       p_effective_date    => p_effective_date,
       p_datetrack_mode    => p_datetrack_mode,
       p_validation_start_date   => p_validation_start_date,
       p_validation_end_date  => p_validation_end_date);
  End If;
End dt_pre_update;
--
-- This procedure is called before checking any validation trigger
-- because many validations are dependent on date_effective and when date_effective
-- is going to be changed then validation should happen later only.
--
procedure update_date_effective
(p_rec          in out nocopy hr_psf_shd.g_rec_type
,p_datetrack_mode        in varchar2
,p_effective_date        in date
,p_validation_start_date in out nocopy date
,p_validation_end_date   in date)
is
l_min_esd date;
l_esd date;
l_prev_eed date;
l_present_stat varchar2(30);
l_prev_stat varchar2(30);
l_next_esd date;
-- cursor to fetch all rows of the position for update
  cursor pos_all is
      select date_effective
      from hr_all_positions_f
      where position_id  = p_rec.position_id
      for update of date_effective;

 -- cursor to fetch minimum effective_start_date
    cursor pos_min_esd is
      select min(effective_start_date)
      from hr_all_positions_f
      where position_id = p_rec.position_id ;

-- cursor to fetch the first row
     cursor pos_first_row(min_esd date) is
       select effective_start_date
       from hr_All_positions_f
       where position_id = p_rec.position_id and
             effective_start_date = l_min_esd
       for update of effective_start_date ;

-- cursor to fetch the previous row from database current row
     cursor pos_prev_row is
       select effective_end_date
       from hr_All_positions_f
       where position_id = p_rec.position_id and
             effective_end_date = p_validation_start_date -1
       for update of effective_end_date ;

-- cursor to fetch the next active row from database
     cursor next_active_row(p_effective_date date) is
       select effective_start_date
       from hr_All_positions_f pos
       where position_id = p_rec.position_id
             and effective_start_date > p_effective_date
        and hr_psf_shd.get_availability_status(pos.availability_status_id
        ,p_rec.business_group_id ) = 'ACTIVE'
       order by effective_start_date ;
-- cursor to update the current row in database as effective start date is not passed to api
     cursor current_row (p_effective_start_date date) is
        select effective_start_date
        from hr_all_positions_f
        where position_id = p_rec.position_id
        and effective_start_date = p_effective_start_date
   for update of effective_start_date ;
l_chg_date_effective boolean;
l_new_date_effective date;
l_old_esd date;
l_ll  date;
l_ul  date;
l_updateable boolean;
l_proc               varchar2(72) ;
begin
if g_debug then
l_proc                := g_package||'update_date_effective' ;
   hr_utility.set_location('entering'||l_proc,5);
end if;
   if p_rec.date_effective <> hr_psf_shd.g_old_rec.date_effective then
      -- user has changed date effective in this record
if g_debug then
      hr_utility.set_location('date effective has been changed'||l_proc,10);
end if;
      if p_datetrack_mode ='CORRECTION' then
if g_debug then
         hr_utility.set_location('datetrack mode correction '||l_proc,20);
end if;
         hr_psf_bus.DE_Update_properties(
          p_position_id           => p_rec.position_id,
          p_effective_Start_Date  => hr_psf_shd.g_old_rec.effective_start_date,
          p_updateable            => l_updateable,
          p_lower_limit           => l_ll,
          p_upper_limit           => l_ul);
         if l_updateable and p_rec.date_effective between l_ll and l_ul then
            -- and the date effective is between the allowed limits
            -- change date effective for all records
if g_debug then
            hr_utility.set_location('date effective change valid '||l_proc,30);
end if;
            for i in pos_all loop
               update hr_all_positions_f
               set date_effective = p_rec.date_effective
               where current of pos_all ;
            end loop;
            if hr_psf_bus.all_proposed_only_position(p_rec.position_id) then
if g_debug then
               hr_utility.set_location('all_proposed only_position '||l_proc,40);
end if;
               open pos_min_esd;
               fetch pos_min_esd into l_min_esd;
               close pos_min_esd;
               if p_rec.date_effective < l_min_esd then
             if l_min_esd = p_validation_start_date then
           -- current row is the first row
           p_validation_start_date := p_rec.date_effective;
             end if;
                  -- date effective is less than esd of first row change the esd of first row
                  open pos_first_row(l_min_esd);
                  fetch pos_first_row into l_esd;
                  update hr_all_positions_f
                  set effective_start_date = p_rec.date_effective
        where current of pos_first_row;
                  close pos_first_row;
               end if;
            elsif hr_psf_bus.first_active_position_row(p_rec.position_id,p_validation_start_date) then
          -- change effective end_date of previous row
if g_debug then
               hr_utility.set_location('first_active_position_row '||l_proc,50);
end if;
          open pos_prev_row;
          fetch pos_prev_row into l_prev_eed;
               if l_prev_eed is not null then
if g_debug then
                  hr_utility.set_location('first_active_position_row '||l_proc,55);
end if;
             update hr_all_positions_f
             set effective_end_date = p_rec.date_effective - 1
             where current of pos_prev_row;
               end if;
          close pos_prev_row;

          -- current row effective_start_date is changed to date_effective
               open current_row(hr_psf_shd.g_old_rec.effective_start_date);
               fetch current_row into l_old_esd;
               if l_old_esd is not null then
             p_rec.effective_start_date := p_rec.date_effective;
                  update hr_all_positions_f
                  set effective_start_date = p_rec.date_effective
                  where current of current_row;
               end if;
          close current_row;
          -- form values are also updated to reflect the change
          p_validation_start_date := p_rec.date_effective;
            end if;
if g_debug then
            hr_utility.set_location('p_rec.date_effective:'||to_char(p_rec.date_effective)||l_proc, 90);
end if;
         else
if g_debug then
            hr_utility.set_location('DE changed but either non doable or wrong limits'||l_proc,15);
end if;
         end if;
      else
         -- raise the error that date_effective cannot be changed in
         -- any other datetrack mode
         hr_utility.set_message(800, 'PER_DE_CHANGE_ONLY_CORRECTION');
         hr_utility.raise_error;
      end if;
   else
if g_debug then
      hr_utility.set_location('user has not changed date effective'||l_proc,164);
end if;
   end if;
   if p_rec.availability_status_id <> hr_psf_shd.g_old_rec.availability_status_id then
      -- user has changed availability_status_id in this record
if g_debug then
      hr_utility.set_location('Avail_stat changed '||l_proc,60);
end if;
      hr_psf_bus.chk_availability_status_id(p_position_id            => p_rec.position_id
                                           ,p_business_group_id      => p_rec.business_group_id
                                           ,p_datetrack_mode         => p_datetrack_mode
                                           ,p_validation_start_date  => p_validation_start_date
                                           ,p_availability_status_id => p_rec.availability_status_id
                                           ,p_effective_date         => p_effective_date
                                           ,p_date_effective         => p_rec.date_effective
                                           ,p_object_version_number  => p_rec.object_version_number
                                           ,p_old_avail_status_id    => hr_psf_shd.g_old_rec.availability_status_id
                             );
if g_debug then
      hr_utility.set_location('after chk_avail_stat '||l_proc, 70);
end if;
      l_present_stat := hr_psf_shd.get_availability_status(p_rec.availability_status_id,
                                         p_rec.business_group_id);
      l_prev_stat := hr_psf_shd.get_availability_status(
                                         hr_psf_shd.g_old_rec.availability_status_id,
                                         p_rec.business_group_id);
      if (hr_psf_bus.all_proposed_only_position(p_rec.position_id))
    and l_present_stat = 'ACTIVE' then
if g_debug then
         hr_utility.set_location('all_proposed_position'||l_proc, 90);
end if;
    -- all_proposed row changed into first active
    if p_datetrack_mode ='CORRECTION' then
if g_debug then
            hr_utility.set_location('correction'||l_proc, 95);
end if;
       -- all proposed position chnaged in correction mode to active
       -- then date_effective should be equal to effective_start_date of current row
       if p_rec.date_effective <> p_validation_start_date then
          hr_utility.set_message(800,'PER_DE_EQ_ESD_CORR');
          hr_utility.raise_error;
       end if;
    end if;
    if p_datetrack_mode ='UPDATE' then
       -- all proposed position chnaged in correction mode to active
       -- then date_effective should be equal to effective_start_date of current row
if g_debug then
            hr_utility.set_location('correction'||l_proc, 97);
end if;
       if p_rec.date_effective <> p_effective_date then
          hr_utility.set_message(800,'PER_DE_EQ_ED_UPD');
          hr_utility.raise_error;
       end if;
    end if;
      elsif (hr_psf_bus.first_active_position_row(p_rec.position_id,hr_psf_shd.g_old_rec.effective_start_date)) then
    -- find out the ESD of next active row  and make that as Date_effective and the same
    -- is to be done for all the records of that position
if g_debug then
         hr_utility.set_location('first_active_position'||l_proc, 80);
end if;

   -- Bug Fix : 3381555
   if (hr_psf_shd.get_availability_status(p_rec.availability_status_id
        ,p_rec.business_group_id ) <> 'ELIMINATED' ) then
        --
        -- Proposed change is not for eliminate, then get the next active row's esd for the
        -- given validation_start_date.
        --
    open next_active_row(p_validation_start_date);
    fetch next_active_row into l_next_esd;
    close next_active_row;
     --
    End if;

    if l_next_esd is not null then
       -- There exists an active row after the current row
if g_debug then
            hr_utility.set_location('first_active_position'||l_proc, 85);
end if;
            p_rec.date_effective := l_next_esd;
            for i in pos_all loop
               update hr_all_positions_f
               set date_effective = p_rec.date_effective
               where current of pos_all ;
            end loop;
    end if;
      elsif l_present_stat = 'ACTIVE' and l_prev_stat ='PROPOSED' then
      -- neither first active nor all proposed but current row becoming first active
if g_debug then
         hr_utility.set_location('making first_active_row'||l_proc, 100);
end if;
    if p_datetrack_mode ='CORRECTION' then
if g_debug then
            hr_utility.set_location('mode correction'||l_proc, 102);
end if;
       -- a proposed position changed in correction mode to active
       -- then date_effective should be equal to effective_start_date of current row
       p_rec.date_effective := p_validation_start_date ;
            for i in pos_all loop
               update hr_all_positions_f
               set date_effective = p_rec.date_effective
               where current of pos_all ;
            end loop;
    end if;
    if p_datetrack_mode ='UPDATE_CHANGE_INSERT'
            or p_datetrack_mode ='UPDATE_OVERRIDE'
            or p_datetrack_mode ='UPDATE' then
if g_debug then
            hr_utility.set_location('mode update_change_insert'||l_proc, 112);
end if;
       p_rec.date_effective := p_effective_date ;
            for i in pos_all loop
               update hr_all_positions_f
               set date_effective = p_rec.date_effective
               where current of pos_all ;
            end loop;
    end if;
      end if;
   end if;
if g_debug then
   hr_utility.set_location('leaving '||l_proc, 200);
end if;
end update_date_effective;
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
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_update_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
   (p_rec          in out nocopy hr_psf_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in out nocopy date,
    p_validation_end_date   in out nocopy date) is
--
  l_proc varchar2(72);
  l_min_esd     date;
  l_proposed    boolean ;
  l_active_rows      number ;
  l_current_row_stat varchar2(30) ;
  l_new_date_effective date ;
  l_chg_date_effective boolean ;
  cursor c1 is
  select min(effective_start_date)
  from hr_all_positions_f
  where position_id = p_rec.position_id;

-- cursor to fetch all rows of the position for update
  cursor pos_all is
      select date_effective
      from hr_all_positions_f
      where position_id  = p_rec.position_id
      for update of date_effective;

-- cursor to fetch the previous row
  cursor pos_prev is
    select effective_start_date,effective_end_date
    from hr_all_positions_f
    where position_id = p_rec.position_id and
          effective_end_date = hr_psf_shd.g_old_rec.effective_start_date - 1
    for update of effective_start_date,effective_end_date;

-- cursor to fetch the first row
     cursor pos_first(p_min_esd date) is
       select effective_start_date, effective_end_date
       from hr_All_positions_f
       where position_id = p_rec.position_id and
             effective_start_date = p_min_esd
       for update of effective_start_date ;
-- cursor to fetch ESD from current row
     cursor pos_current(p_effective_date date) is
       select effective_start_date
       from hr_All_positions_f
       where position_id = p_rec.position_id and
             p_effective_date between effective_start_date and effective_end_date;
-- cursor to check active rows for the position prior to the effective_start_date of their row
    cursor pos_active_rows(p_position_id number,p_effective_start_date date) is
       select count(*)
       from hr_all_positions_f pos
       where pos.position_id = p_position_id
       and pos.effective_start_date < p_effective_start_date
       and hr_psf_shd.get_availability_status(pos.availability_status_id
        ,p_rec.business_group_id ) = 'ACTIVE';
Begin

if g_debug then
 l_proc  :=    g_package||'pre_update';
  hr_utility.set_location('Entering:'|| l_proc, 5);
end if;

  --
  --
  --
  dt_pre_update
    (p_rec          => p_rec,
     p_effective_date        => p_effective_date,
     p_datetrack_mode        => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
  --
  -- Logic to update date_effective on all the position rows
  -- if date_effective has changed
  -- if effective_date is changed prior to effective_Start_Date of
  -- first row, effective_start_Date also moves to the same date
  --
  if g_debug then
  hr_utility.set_location('performing validation '||l_proc, 10);
  end if;
/*
  if p_rec.date_effective <> hr_psf_shd.g_old_rec.date_effective then
   --
   -- check the date_track mode, if it is not correction then
   -- change in date_effective is not allowed
   --
      if p_datetrack_mode <> 'CORRECTION' then
         -- raise the error that date_effective cannot be changed in
         -- any other datetrack mode
         hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE', l_proc);
         hr_utility.set_message_token('STEP','15');
         hr_utility.raise_error;
      end if;
   --
   -- update date_effective of the all rows of the position for the
   -- date_effective
   --
    open pos_current(p_effective_date);
    fetch pos_current into p_rec.effective_start_date;
    close pos_current;

    for i in pos_all loop
        update hr_all_positions_f
          set date_effective = p_rec.date_effective
          where current of pos_all ;
    end loop;

   -- If the current position is all_proposed then no change in
   -- start date or end date is performed while first record's start
   -- is to be changed which is outside the condition

   l_proposed := hr_psf_bus.all_proposed_only_position(p_rec.position_id);

   if l_proposed = false then
       l_current_row_stat := hr_psf_shd.get_availability_status(p_rec.availability_status_id
        ,p_rec.business_group_id ) ;
      if l_current_row_stat = 'ACTIVE' then
       --
       -- update effective start date of current row
       --
        update hr_all_positions_f
        set effective_Start_date = p_rec.date_effective
        where position_id = p_rec.position_id and
              effective_start_date = hr_psf_shd.g_old_rec.effective_start_date;
        if sql%rowcount = 0 then
          hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE', l_proc);
          hr_utility.set_message_token('STEP','5');
          hr_utility.raise_error;
        end if;
        p_validation_start_date    := p_rec.date_effective;
        p_rec.effective_start_date := p_rec.date_effective;
        --
        -- update previous row's effective_end_date
        for j in pos_prev loop
            update hr_all_positions_f
            set effective_end_date = p_rec.date_effective - 1
            where current of pos_prev ;
        end loop;
      end if;
    end if;

    --
    --
    -- Find effective_start_date of the first row
    --
    open c1;
    fetch c1 into l_min_esd;
    close c1;
    if g_debug then
    hr_utility.set_location('l_min_esd = ' || to_char(l_min_esd) || l_proc, 100);
    end if;
    --
    -- if esd for the first row is later than new date_Effective
    if l_min_esd > p_rec.date_effective then
      --
      -- move esd of the first row to date_Effective
      --
      for k in pos_first(l_min_esd) loop
      if g_debug then
          hr_utility.set_location('k.effective_start_date = ' ||
                           to_char(k.effective_start_date) || l_proc, 110);
          hr_utility.set_location('p_rec.effective_start_date = ' ||
                           to_char(p_rec.effective_start_date) || l_proc, 110);
      end if;
          update hr_All_positions_f
          set effective_Start_Date = p_rec.date_effective
          where current of pos_first ;

          if p_rec.effective_start_date = k.effective_start_date then
          if g_debug then
             hr_utility.set_location('In Current Row = First Row ' || l_proc, 115);
          end if;
             p_validation_start_date    := p_rec.date_effective;
             p_rec.effective_start_date := p_rec.date_effective;
          end if;
          if g_debug then
          hr_utility.set_location('p_rec.effective_start_date = ' ||
                           to_char(p_rec.effective_start_date) || l_proc, 150);
          end if;
        end loop;

      --
    end if;

  end if;
*/
if g_debug then
  hr_utility.set_location('p_validation_start_date '
            || to_char(p_validation_start_date) || ' ' || l_proc, 100);
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  end if;
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
Procedure post_update
   (p_rec          in hr_psf_shd.g_rec_type,
    p_effective_date  in date,
    p_datetrack_mode  in varchar2,
    p_validation_start_date in date,
    p_validation_end_date   in date) is
--
  l_proc varchar2(72);
--
Begin
if g_debug then
l_proc    := g_package||'post_update';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  -- User Hook
  Begin
  hr_psf_rku.after_update(
  p_position_id                  => p_rec.position_id                 ,
  p_effective_start_date         => p_rec.effective_start_date        ,
  p_effective_end_date           => p_rec.effective_end_date          ,
  p_availability_status_id       => p_rec.availability_status_id      ,
--  p_business_group_id            => p_rec.business_group_id           ,
  p_entry_step_id                => p_rec.entry_step_id               ,
  p_entry_grade_rule_id          => p_rec.entry_grade_rule_id         ,
--  p_job_id                       => p_rec.job_id                      ,
  p_location_id                  => p_rec.location_id                 ,
--  p_organization_id              => p_rec.organization_id             ,
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
  p_effective_date       => p_effective_date          ,
  p_datetrack_mode               => p_datetrack_mode                  ,
  p_effective_start_date_o       => hr_psf_shd.g_old_rec.effective_start_date      ,
  p_effective_end_date_o         => hr_psf_shd.g_old_rec.effective_end_date        ,
  p_availability_status_id_o     => hr_psf_shd.g_old_rec.availability_status_id    ,
  p_business_group_id_o          => hr_psf_shd.g_old_rec.business_group_id         ,
  p_entry_step_id_o              => hr_psf_shd.g_old_rec.entry_step_id             ,
  p_entry_grade_rule_id_o        => hr_psf_shd.g_old_rec.entry_grade_rule_id       ,
  p_job_id_o                     => hr_psf_shd.g_old_rec.job_id                    ,
  p_location_id_o                => hr_psf_shd.g_old_rec.location_id               ,
  p_organization_id_o            => hr_psf_shd.g_old_rec.organization_id             ,
  p_pay_freq_payroll_id_o        => hr_psf_shd.g_old_rec.pay_freq_payroll_id       ,
  p_position_definition_id_o     => hr_psf_shd.g_old_rec.position_definition_id    ,
  p_position_transaction_id_o    => hr_psf_shd.g_old_rec.position_transaction_id   ,
  p_prior_position_id_o          => hr_psf_shd.g_old_rec.prior_position_id         ,
  p_relief_position_id_o         => hr_psf_shd.g_old_rec.relief_position_id        ,
  p_entry_grade_id_o             => hr_psf_shd.g_old_rec.entry_grade_id            ,
  p_successor_position_id_o      => hr_psf_shd.g_old_rec.successor_position_id     ,
  p_supervisor_position_id_o     => hr_psf_shd.g_old_rec.supervisor_position_id    ,
  p_amendment_date_o             => hr_psf_shd.g_old_rec.amendment_date            ,
  p_amendment_recommendation_o   => hr_psf_shd.g_old_rec.amendment_recommendation  ,
  p_amendment_ref_number_o       => hr_psf_shd.g_old_rec.amendment_ref_number      ,
  p_bargaining_unit_cd_o         => hr_psf_shd.g_old_rec.bargaining_unit_cd        ,
  p_comments_o                   => hr_psf_shd.g_old_rec.comments                  ,
  p_current_job_prop_end_date_o  => hr_psf_shd.g_old_rec.current_job_prop_end_date ,
  p_current_org_prop_end_date_o  => hr_psf_shd.g_old_rec.current_org_prop_end_date ,
  p_avail_status_prop_end_date_o => hr_psf_shd.g_old_rec.avail_status_prop_end_date,
  p_date_effective_o             => hr_psf_shd.g_old_rec.date_effective            ,
  p_date_end_o                   => hr_psf_shd.g_old_rec.date_end                  ,
  p_earliest_hire_date_o         => hr_psf_shd.g_old_rec.earliest_hire_date        ,
  p_fill_by_date_o               => hr_psf_shd.g_old_rec.fill_by_date              ,
  p_frequency_o                  => hr_psf_shd.g_old_rec.frequency                 ,
  p_fte_o                        => hr_psf_shd.g_old_rec.fte                       ,
  p_max_persons_o                => hr_psf_shd.g_old_rec.max_persons               ,
  p_name_o                       => hr_psf_shd.g_old_rec.name                      ,
  p_overlap_period_o             => hr_psf_shd.g_old_rec.overlap_period            ,
  p_overlap_unit_cd_o            => hr_psf_shd.g_old_rec.overlap_unit_cd           ,
  p_pay_term_end_day_cd_o        => hr_psf_shd.g_old_rec.pay_term_end_day_cd       ,
  p_pay_term_end_month_cd_o      => hr_psf_shd.g_old_rec.pay_term_end_month_cd     ,
  p_permanent_temporary_flag_o   => hr_psf_shd.g_old_rec.permanent_temporary_flag  ,
  p_permit_recruitment_flag_o    => hr_psf_shd.g_old_rec.permit_recruitment_flag   ,
  p_position_type_o              => hr_psf_shd.g_old_rec.position_type             ,
  p_posting_description_o        => hr_psf_shd.g_old_rec.posting_description       ,
  p_probation_period_o           => hr_psf_shd.g_old_rec.probation_period          ,
  p_probation_period_unit_cd_o   => hr_psf_shd.g_old_rec.probation_period_unit_cd  ,
  p_replacement_required_flag_o  => hr_psf_shd.g_old_rec.replacement_required_flag ,
  p_review_flag_o                => hr_psf_shd.g_old_rec.review_flag               ,
  p_seasonal_flag_o              => hr_psf_shd.g_old_rec.seasonal_flag             ,
  p_security_requirements_o      => hr_psf_shd.g_old_rec.security_requirements     ,
  p_status_o                     => hr_psf_shd.g_old_rec.status                    ,
  p_term_start_day_cd_o          => hr_psf_shd.g_old_rec.term_start_day_cd         ,
  p_term_start_month_cd_o        => hr_psf_shd.g_old_rec.term_start_month_cd       ,
  p_time_normal_finish_o         => hr_psf_shd.g_old_rec.time_normal_finish        ,
  p_time_normal_start_o          => hr_psf_shd.g_old_rec.time_normal_start         ,
  p_update_source_cd_o           => hr_psf_shd.g_old_rec.update_source_cd          ,
  p_working_hours_o              => hr_psf_shd.g_old_rec.working_hours             ,
  p_works_council_approval_fla_o => hr_psf_shd.g_old_rec.works_council_approval_flag,
  p_work_period_type_cd_o        => hr_psf_shd.g_old_rec.work_period_type_cd       ,
  p_work_term_end_day_cd_o       => hr_psf_shd.g_old_rec.work_term_end_day_cd      ,
  p_work_term_end_month_cd_o     => hr_psf_shd.g_old_rec.work_term_end_month_cd    ,
  p_proposed_fte_for_layoff_o    => hr_psf_shd.g_old_rec.proposed_fte_for_layoff   ,
  p_proposed_date_for_layoff_o   => hr_psf_shd.g_old_rec.proposed_date_for_layoff  ,
  p_pay_basis_id_o               => hr_psf_shd.g_old_rec.pay_basis_id              ,
  p_supervisor_id_o              => hr_psf_shd.g_old_rec.supervisor_id             ,
  p_copied_to_old_table_flag_o   => hr_psf_shd.g_old_rec.copied_to_old_table_flag  ,
  p_information1_o               => hr_psf_shd.g_old_rec.information1              ,
  p_information2_o               => hr_psf_shd.g_old_rec.information2              ,
  p_information3_o               => hr_psf_shd.g_old_rec.information3              ,
  p_information4_o               => hr_psf_shd.g_old_rec.information4              ,
  p_information5_o               => hr_psf_shd.g_old_rec.information5              ,
  p_information6_o               => hr_psf_shd.g_old_rec.information6              ,
  p_information7_o               => hr_psf_shd.g_old_rec.information7              ,
  p_information8_o               => hr_psf_shd.g_old_rec.information8              ,
  p_information9_o               => hr_psf_shd.g_old_rec.information9              ,
  p_information10_o              => hr_psf_shd.g_old_rec.information10             ,
  p_information11_o              => hr_psf_shd.g_old_rec.information11             ,
  p_information12_o              => hr_psf_shd.g_old_rec.information12             ,
  p_information13_o              => hr_psf_shd.g_old_rec.information13             ,
  p_information14_o              => hr_psf_shd.g_old_rec.information14             ,
  p_information15_o              => hr_psf_shd.g_old_rec.information15             ,
  p_information16_o              => hr_psf_shd.g_old_rec.information16             ,
  p_information17_o              => hr_psf_shd.g_old_rec.information17             ,
  p_information18_o              => hr_psf_shd.g_old_rec.information18             ,
  p_information19_o              => hr_psf_shd.g_old_rec.information19             ,
  p_information20_o              => hr_psf_shd.g_old_rec.information20             ,
  p_information21_o              => hr_psf_shd.g_old_rec.information21             ,
  p_information22_o              => hr_psf_shd.g_old_rec.information22             ,
  p_information23_o              => hr_psf_shd.g_old_rec.information23             ,
  p_information24_o              => hr_psf_shd.g_old_rec.information24             ,
  p_information25_o              => hr_psf_shd.g_old_rec.information25             ,
  p_information26_o              => hr_psf_shd.g_old_rec.information26             ,
  p_information27_o              => hr_psf_shd.g_old_rec.information27             ,
  p_information28_o              => hr_psf_shd.g_old_rec.information28             ,
  p_information29_o              => hr_psf_shd.g_old_rec.information29             ,
  p_information30_o              => hr_psf_shd.g_old_rec.information30             ,
  p_information_category_o       => hr_psf_shd.g_old_rec.information_category      ,
  p_attribute1_o                 => hr_psf_shd.g_old_rec.attribute1                ,
  p_attribute2_o                 => hr_psf_shd.g_old_rec.attribute2                ,
  p_attribute3_o                 => hr_psf_shd.g_old_rec.attribute3                ,
  p_attribute4_o                 => hr_psf_shd.g_old_rec.attribute4                ,
  p_attribute5_o                 => hr_psf_shd.g_old_rec.attribute5                ,
  p_attribute6_o                 => hr_psf_shd.g_old_rec.attribute6                ,
  p_attribute7_o                 => hr_psf_shd.g_old_rec.attribute7                ,
  p_attribute8_o                 => hr_psf_shd.g_old_rec.attribute8                ,
  p_attribute9_o                 => hr_psf_shd.g_old_rec.attribute9                ,
  p_attribute10_o                => hr_psf_shd.g_old_rec.attribute10               ,
  p_attribute11_o                => hr_psf_shd.g_old_rec.attribute11               ,
  p_attribute12_o                => hr_psf_shd.g_old_rec.attribute12               ,
  p_attribute13_o                => hr_psf_shd.g_old_rec.attribute13               ,
  p_attribute14_o                => hr_psf_shd.g_old_rec.attribute14               ,
  p_attribute15_o                => hr_psf_shd.g_old_rec.attribute15               ,
  p_attribute16_o                => hr_psf_shd.g_old_rec.attribute16               ,
  p_attribute17_o                => hr_psf_shd.g_old_rec.attribute17               ,
  p_attribute18_o                => hr_psf_shd.g_old_rec.attribute18               ,
  p_attribute19_o                => hr_psf_shd.g_old_rec.attribute19               ,
  p_attribute20_o                => hr_psf_shd.g_old_rec.attribute20               ,
  p_attribute21_o                => hr_psf_shd.g_old_rec.attribute21               ,
  p_attribute22_o                => hr_psf_shd.g_old_rec.attribute22               ,
  p_attribute23_o                => hr_psf_shd.g_old_rec.attribute23               ,
  p_attribute24_o                => hr_psf_shd.g_old_rec.attribute24               ,
  p_attribute25_o                => hr_psf_shd.g_old_rec.attribute25               ,
  p_attribute26_o                => hr_psf_shd.g_old_rec.attribute26               ,
  p_attribute27_o                => hr_psf_shd.g_old_rec.attribute27               ,
  p_attribute28_o                => hr_psf_shd.g_old_rec.attribute28               ,
  p_attribute29_o                => hr_psf_shd.g_old_rec.attribute29               ,
  p_attribute30_o                => hr_psf_shd.g_old_rec.attribute30               ,
  p_attribute_category_o         => hr_psf_shd.g_old_rec.attribute_category        ,
  p_request_id_o                 => hr_psf_shd.g_old_rec.request_id                ,
  p_program_application_id_o     => hr_psf_shd.g_old_rec.program_application_id    ,
  p_program_id_o                 => hr_psf_shd.g_old_rec.program_id                ,
  p_program_update_date_o        => hr_psf_shd.g_old_rec.program_update_date       ,
  p_object_version_number_o      => hr_psf_shd.g_old_rec.object_version_number     );
  --
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_ALL_POSITIONS'
        ,p_hook_type   => 'AU'
        );
  End;
  --
  hr_psf_shd.position_wf_sync(p_rec.position_id , p_validation_start_date);
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
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
Procedure convert_defs(p_rec in out nocopy hr_psf_shd.g_rec_type) is
--
  l_proc  varchar2(72) ;
--
Begin
  --
if g_debug then
 l_proc   := g_package||'convert_defs';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.availability_status_id = hr_api.g_number) then
    p_rec.availability_status_id :=
    hr_psf_shd.g_old_rec.availability_status_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    hr_psf_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.entry_step_id = hr_api.g_number) then
    p_rec.entry_step_id :=
    hr_psf_shd.g_old_rec.entry_step_id;
  End If;
  If (p_rec.entry_grade_rule_id = hr_api.g_number) then
    p_rec.entry_grade_rule_id :=
    hr_psf_shd.g_old_rec.entry_grade_rule_id;
  End If;
  If (p_rec.job_id = hr_api.g_number) then
    p_rec.job_id :=
    hr_psf_shd.g_old_rec.job_id;
  End If;
  If (p_rec.location_id = hr_api.g_number) then
    p_rec.location_id :=
    hr_psf_shd.g_old_rec.location_id;
  End If;
  If (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    hr_psf_shd.g_old_rec.organization_id;
  End If;
  If (p_rec.pay_freq_payroll_id = hr_api.g_number) then
    p_rec.pay_freq_payroll_id :=
    hr_psf_shd.g_old_rec.pay_freq_payroll_id;
  End If;
  If (p_rec.position_definition_id = hr_api.g_number) then
    p_rec.position_definition_id :=
    hr_psf_shd.g_old_rec.position_definition_id;
  End If;
  If (p_rec.position_transaction_id = hr_api.g_number) then
    p_rec.position_transaction_id :=
    hr_psf_shd.g_old_rec.position_transaction_id;
  End If;
  If (p_rec.prior_position_id = hr_api.g_number) then
    p_rec.prior_position_id :=
    hr_psf_shd.g_old_rec.prior_position_id;
  End If;
  If (p_rec.relief_position_id = hr_api.g_number) then
    p_rec.relief_position_id :=
    hr_psf_shd.g_old_rec.relief_position_id;
  End If;
  If (p_rec.entry_grade_id = hr_api.g_number) then
    p_rec.entry_grade_id :=
    hr_psf_shd.g_old_rec.entry_grade_id;
  End If;
  If (p_rec.successor_position_id = hr_api.g_number) then
    p_rec.successor_position_id :=
    hr_psf_shd.g_old_rec.successor_position_id;
  End If;
  If (p_rec.supervisor_position_id = hr_api.g_number) then
    p_rec.supervisor_position_id :=
    hr_psf_shd.g_old_rec.supervisor_position_id;
  End If;
  If (p_rec.amendment_date = hr_api.g_date) then
    p_rec.amendment_date :=
    hr_psf_shd.g_old_rec.amendment_date;
  End If;
  If (p_rec.amendment_recommendation = hr_api.g_varchar2) then
    p_rec.amendment_recommendation :=
    hr_psf_shd.g_old_rec.amendment_recommendation;
  End If;
  If (p_rec.amendment_ref_number = hr_api.g_varchar2) then
    p_rec.amendment_ref_number :=
    hr_psf_shd.g_old_rec.amendment_ref_number;
  End If;
  If (p_rec.bargaining_unit_cd = hr_api.g_varchar2) then
    p_rec.bargaining_unit_cd :=
    hr_psf_shd.g_old_rec.bargaining_unit_cd;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    hr_psf_shd.g_old_rec.comments;
  End If;
  If (p_rec.current_job_prop_end_date = hr_api.g_date) then
    p_rec.current_job_prop_end_date :=
    hr_psf_shd.g_old_rec.current_job_prop_end_date;
  End If;
  If (p_rec.current_org_prop_end_date = hr_api.g_date) then
    p_rec.current_org_prop_end_date :=
    hr_psf_shd.g_old_rec.current_org_prop_end_date;
  End If;
  If (p_rec.avail_status_prop_end_date = hr_api.g_date) then
    p_rec.avail_status_prop_end_date :=
    hr_psf_shd.g_old_rec.avail_status_prop_end_date;
  End If;
  If (p_rec.date_effective = hr_api.g_date) then
    p_rec.date_effective :=
    hr_psf_shd.g_old_rec.date_effective;
  End If;
  If (p_rec.date_end = hr_api.g_date) then
    p_rec.date_end :=
    hr_psf_shd.g_old_rec.date_end;
  End If;
  If (p_rec.earliest_hire_date = hr_api.g_date) then
    p_rec.earliest_hire_date :=
    hr_psf_shd.g_old_rec.earliest_hire_date;
  End If;
  If (p_rec.fill_by_date = hr_api.g_date) then
    p_rec.fill_by_date :=
    hr_psf_shd.g_old_rec.fill_by_date;
  End If;
  If (p_rec.frequency = hr_api.g_varchar2) then
    p_rec.frequency :=
    hr_psf_shd.g_old_rec.frequency;
  End If;
  If (p_rec.fte = hr_api.g_number) then
    p_rec.fte :=
    hr_psf_shd.g_old_rec.fte;
  End If;
  If (p_rec.max_persons = hr_api.g_number) then
    p_rec.max_persons :=
    hr_psf_shd.g_old_rec.max_persons;
  End If;
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    hr_psf_shd.g_old_rec.name;
  End If;
  If (p_rec.overlap_period = hr_api.g_number) then
    p_rec.overlap_period :=
    hr_psf_shd.g_old_rec.overlap_period;
  End If;
  If (p_rec.overlap_unit_cd = hr_api.g_varchar2) then
    p_rec.overlap_unit_cd :=
    hr_psf_shd.g_old_rec.overlap_unit_cd;
  End If;
  If (p_rec.pay_term_end_day_cd = hr_api.g_varchar2) then
    p_rec.pay_term_end_day_cd :=
    hr_psf_shd.g_old_rec.pay_term_end_day_cd;
  End If;
  If (p_rec.pay_term_end_month_cd = hr_api.g_varchar2) then
    p_rec.pay_term_end_month_cd :=
    hr_psf_shd.g_old_rec.pay_term_end_month_cd;
  End If;
  If (p_rec.permanent_temporary_flag = hr_api.g_varchar2) then
    p_rec.permanent_temporary_flag :=
    hr_psf_shd.g_old_rec.permanent_temporary_flag;
  End If;
  If (p_rec.permit_recruitment_flag = hr_api.g_varchar2) then
    p_rec.permit_recruitment_flag :=
    hr_psf_shd.g_old_rec.permit_recruitment_flag;
  End If;
  If (p_rec.position_type = hr_api.g_varchar2) then
    p_rec.position_type :=
    hr_psf_shd.g_old_rec.position_type;
  End If;
  If (p_rec.posting_description = hr_api.g_varchar2) then
    p_rec.posting_description :=
    hr_psf_shd.g_old_rec.posting_description;
  End If;
  If (p_rec.probation_period = hr_api.g_number) then
    p_rec.probation_period :=
    hr_psf_shd.g_old_rec.probation_period;
  End If;
  If (p_rec.probation_period_unit_cd = hr_api.g_varchar2) then
    p_rec.probation_period_unit_cd :=
    hr_psf_shd.g_old_rec.probation_period_unit_cd;
  End If;
  If (p_rec.replacement_required_flag = hr_api.g_varchar2) then
    p_rec.replacement_required_flag :=
    hr_psf_shd.g_old_rec.replacement_required_flag;
  End If;
  If (p_rec.review_flag = hr_api.g_varchar2) then
    p_rec.review_flag :=
    hr_psf_shd.g_old_rec.review_flag;
  End If;
  If (p_rec.seasonal_flag = hr_api.g_varchar2) then
    p_rec.seasonal_flag :=
    hr_psf_shd.g_old_rec.seasonal_flag;
  End If;
  If (p_rec.security_requirements = hr_api.g_varchar2) then
    p_rec.security_requirements :=
    hr_psf_shd.g_old_rec.security_requirements;
  End If;
  If (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    hr_psf_shd.g_old_rec.status;
  End If;
  If (p_rec.term_start_day_cd = hr_api.g_varchar2) then
    p_rec.term_start_day_cd :=
    hr_psf_shd.g_old_rec.term_start_day_cd;
  End If;
  If (p_rec.term_start_month_cd = hr_api.g_varchar2) then
    p_rec.term_start_month_cd :=
    hr_psf_shd.g_old_rec.term_start_month_cd;
  End If;
  If (p_rec.time_normal_finish = hr_api.g_varchar2) then
    p_rec.time_normal_finish :=
    hr_psf_shd.g_old_rec.time_normal_finish;
  End If;
  If (p_rec.time_normal_start = hr_api.g_varchar2) then
    p_rec.time_normal_start :=
    hr_psf_shd.g_old_rec.time_normal_start;
  End If;
  If (p_rec.update_source_cd = hr_api.g_varchar2) then
    p_rec.update_source_cd :=
    hr_psf_shd.g_old_rec.update_source_cd;
  End If;
  If (p_rec.working_hours = hr_api.g_number) then
    p_rec.working_hours :=
    hr_psf_shd.g_old_rec.working_hours;
  End If;
  If (p_rec.works_council_approval_flag = hr_api.g_varchar2) then
    p_rec.works_council_approval_flag :=
    hr_psf_shd.g_old_rec.works_council_approval_flag;
  End If;
  If (p_rec.work_period_type_cd = hr_api.g_varchar2) then
    p_rec.work_period_type_cd :=
    hr_psf_shd.g_old_rec.work_period_type_cd;
  End If;
  If (p_rec.work_term_end_day_cd = hr_api.g_varchar2) then
    p_rec.work_term_end_day_cd :=
    hr_psf_shd.g_old_rec.work_term_end_day_cd;
  End If;
  If (p_rec.work_term_end_month_cd = hr_api.g_varchar2) then
    p_rec.work_term_end_month_cd :=
    hr_psf_shd.g_old_rec.work_term_end_month_cd;
  End If;
  If (p_rec.proposed_fte_for_layoff = hr_api.g_number) then
    p_rec.proposed_fte_for_layoff :=
    hr_psf_shd.g_old_rec.proposed_fte_for_layoff;
  End If;
  If (p_rec.proposed_date_for_layoff = hr_api.g_date) then
    p_rec.proposed_date_for_layoff :=
    hr_psf_shd.g_old_rec.proposed_date_for_layoff;
  End If;
  If (p_rec.pay_basis_id = hr_api.g_number) then
    p_rec.pay_basis_id :=
    hr_psf_shd.g_old_rec.pay_basis_id;
  End If;
  If (p_rec.supervisor_id = hr_api.g_number) then
    p_rec.supervisor_id :=
    hr_psf_shd.g_old_rec.supervisor_id;
  End If;
  If (p_rec.copied_to_old_table_flag = hr_api.g_varchar2) then
    p_rec.copied_to_old_table_flag :=
    hr_psf_shd.g_old_rec.copied_to_old_table_flag;
  End If;
  If (p_rec.information1 = hr_api.g_varchar2) then
    p_rec.information1 :=
    hr_psf_shd.g_old_rec.information1;
  End If;
  If (p_rec.information2 = hr_api.g_varchar2) then
    p_rec.information2 :=
    hr_psf_shd.g_old_rec.information2;
  End If;
  If (p_rec.information3 = hr_api.g_varchar2) then
    p_rec.information3 :=
    hr_psf_shd.g_old_rec.information3;
  End If;
  If (p_rec.information4 = hr_api.g_varchar2) then
    p_rec.information4 :=
    hr_psf_shd.g_old_rec.information4;
  End If;
  If (p_rec.information5 = hr_api.g_varchar2) then
    p_rec.information5 :=
    hr_psf_shd.g_old_rec.information5;
  End If;
  If (p_rec.information6 = hr_api.g_varchar2) then
    p_rec.information6 :=
    hr_psf_shd.g_old_rec.information6;
  End If;
  If (p_rec.information7 = hr_api.g_varchar2) then
    p_rec.information7 :=
    hr_psf_shd.g_old_rec.information7;
  End If;
  If (p_rec.information8 = hr_api.g_varchar2) then
    p_rec.information8 :=
    hr_psf_shd.g_old_rec.information8;
  End If;
  If (p_rec.information9 = hr_api.g_varchar2) then
    p_rec.information9 :=
    hr_psf_shd.g_old_rec.information9;
  End If;
  If (p_rec.information10 = hr_api.g_varchar2) then
    p_rec.information10 :=
    hr_psf_shd.g_old_rec.information10;
  End If;
  If (p_rec.information11 = hr_api.g_varchar2) then
    p_rec.information11 :=
    hr_psf_shd.g_old_rec.information11;
  End If;
  If (p_rec.information12 = hr_api.g_varchar2) then
    p_rec.information12 :=
    hr_psf_shd.g_old_rec.information12;
  End If;
  If (p_rec.information13 = hr_api.g_varchar2) then
    p_rec.information13 :=
    hr_psf_shd.g_old_rec.information13;
  End If;
  If (p_rec.information14 = hr_api.g_varchar2) then
    p_rec.information14 :=
    hr_psf_shd.g_old_rec.information14;
  End If;
  If (p_rec.information15 = hr_api.g_varchar2) then
    p_rec.information15 :=
    hr_psf_shd.g_old_rec.information15;
  End If;
  If (p_rec.information16 = hr_api.g_varchar2) then
    p_rec.information16 :=
    hr_psf_shd.g_old_rec.information16;
  End If;
  If (p_rec.information17 = hr_api.g_varchar2) then
    p_rec.information17 :=
    hr_psf_shd.g_old_rec.information17;
  End If;
  If (p_rec.information18 = hr_api.g_varchar2) then
    p_rec.information18 :=
    hr_psf_shd.g_old_rec.information18;
  End If;
  If (p_rec.information19 = hr_api.g_varchar2) then
    p_rec.information19 :=
    hr_psf_shd.g_old_rec.information19;
  End If;
  If (p_rec.information20 = hr_api.g_varchar2) then
    p_rec.information20 :=
    hr_psf_shd.g_old_rec.information20;
  End If;
  If (p_rec.information21 = hr_api.g_varchar2) then
    p_rec.information21 :=
    hr_psf_shd.g_old_rec.information21;
  End If;
  If (p_rec.information22 = hr_api.g_varchar2) then
    p_rec.information22 :=
    hr_psf_shd.g_old_rec.information22;
  End If;
  If (p_rec.information23 = hr_api.g_varchar2) then
    p_rec.information23 :=
    hr_psf_shd.g_old_rec.information23;
  End If;
  If (p_rec.information24 = hr_api.g_varchar2) then
    p_rec.information24 :=
    hr_psf_shd.g_old_rec.information24;
  End If;
  If (p_rec.information25 = hr_api.g_varchar2) then
    p_rec.information25 :=
    hr_psf_shd.g_old_rec.information25;
  End If;
  If (p_rec.information26 = hr_api.g_varchar2) then
    p_rec.information26 :=
    hr_psf_shd.g_old_rec.information26;
  End If;
  If (p_rec.information27 = hr_api.g_varchar2) then
    p_rec.information27 :=
    hr_psf_shd.g_old_rec.information27;
  End If;
  If (p_rec.information28 = hr_api.g_varchar2) then
    p_rec.information28 :=
    hr_psf_shd.g_old_rec.information28;
  End If;
  If (p_rec.information29 = hr_api.g_varchar2) then
    p_rec.information29 :=
    hr_psf_shd.g_old_rec.information29;
  End If;
  If (p_rec.information30 = hr_api.g_varchar2) then
    p_rec.information30 :=
    hr_psf_shd.g_old_rec.information30;
  End If;
  If (p_rec.information_category = hr_api.g_varchar2) then
    p_rec.information_category :=
    hr_psf_shd.g_old_rec.information_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    hr_psf_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    hr_psf_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    hr_psf_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    hr_psf_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    hr_psf_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    hr_psf_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    hr_psf_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    hr_psf_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    hr_psf_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    hr_psf_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    hr_psf_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    hr_psf_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    hr_psf_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    hr_psf_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    hr_psf_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    hr_psf_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    hr_psf_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    hr_psf_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    hr_psf_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    hr_psf_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.attribute21 = hr_api.g_varchar2) then
    p_rec.attribute21 :=
    hr_psf_shd.g_old_rec.attribute21;
  End If;
  If (p_rec.attribute22 = hr_api.g_varchar2) then
    p_rec.attribute22 :=
    hr_psf_shd.g_old_rec.attribute22;
  End If;
  If (p_rec.attribute23 = hr_api.g_varchar2) then
    p_rec.attribute23 :=
    hr_psf_shd.g_old_rec.attribute23;
  End If;
  If (p_rec.attribute24 = hr_api.g_varchar2) then
    p_rec.attribute24 :=
    hr_psf_shd.g_old_rec.attribute24;
  End If;
  If (p_rec.attribute25 = hr_api.g_varchar2) then
    p_rec.attribute25 :=
    hr_psf_shd.g_old_rec.attribute25;
  End If;
  If (p_rec.attribute26 = hr_api.g_varchar2) then
    p_rec.attribute26 :=
    hr_psf_shd.g_old_rec.attribute26;
  End If;
  If (p_rec.attribute27 = hr_api.g_varchar2) then
    p_rec.attribute27 :=
    hr_psf_shd.g_old_rec.attribute27;
  End If;
  If (p_rec.attribute28 = hr_api.g_varchar2) then
    p_rec.attribute28 :=
    hr_psf_shd.g_old_rec.attribute28;
  End If;
  If (p_rec.attribute29 = hr_api.g_varchar2) then
    p_rec.attribute29 :=
    hr_psf_shd.g_old_rec.attribute29;
  End If;
  If (p_rec.attribute30 = hr_api.g_varchar2) then
    p_rec.attribute30 :=
    hr_psf_shd.g_old_rec.attribute30;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    hr_psf_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    hr_psf_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    hr_psf_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    hr_psf_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    hr_psf_shd.g_old_rec.program_update_date;
  End If;

  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out nocopy  hr_psf_shd.g_rec_type,
  p_effective_date   in    date,
  p_datetrack_mode   in    varchar2,
  p_validate            in      boolean  default false
  ) is
--
  l_proc       varchar2(72) ;
  l_validation_start_date  date;
  l_validation_end_date    date;
--
Begin
g_debug := hr_utility.debug_enabled;
 if g_debug then
 l_proc         := g_package||'upd (rec)';
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('ovn 1is: '||to_char(p_rec.object_version_number)||l_proc, 5);
end if;
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT upd_per_per;
  End If;
  --
  --
  -- We must lock the row which we need to update.
  --
  hr_psf_shd.lck
   (p_effective_date  => p_effective_date,
          p_datetrack_mode  => p_datetrack_mode,
          p_position_id  => p_rec.position_id,
          p_object_version_number => p_rec.object_version_number,
          p_validation_start_date => l_validation_start_date,
          p_validation_end_date   => l_validation_end_date);
if g_debug then
  hr_utility.set_location('ovn 2 is: '||to_char(p_rec.object_version_number)||l_proc, 5);
end if;
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  -- hr_utility.set_location('ovn 3 is: '||to_char(p_rec.object_version_number)||l_proc, 5);
  --
  -- date effective is changed based on the status change
  --
  update_date_effective
   (p_rec                   => p_rec
   ,p_datetrack_mode        => p_datetrack_mode
   ,p_effective_date        => p_effective_date
   ,p_validation_start_date => l_validation_start_date
   ,p_validation_end_date   => l_validation_end_date);
if g_debug then
  hr_utility.set_location('ovn 4 is: '||to_char(p_rec.object_version_number)||l_proc, 5);
end if;
  if (not per_refresh_position.refreshing_position) then
    if g_debug then
      hr_utility.set_location('VALIDATING POSITION :'||l_proc, 5);
    end if;
    --
    -- validations are performed based on the new date effective
    --
    hr_psf_bus.update_validate
    (p_rec          => p_rec,
     p_effective_date  => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date   => l_validation_end_date);
  end if;
if g_debug then
  hr_utility.set_location('ovn 5 is: '||to_char(p_rec.object_version_number)||l_proc, 5);
end if;
  --
  -- Call the supporting pre-update operation
  --
  pre_update
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => p_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
if g_debug then
  hr_utility.set_location('ovn 6 is: '||to_char(p_rec.object_version_number)||l_proc, 5);

  hr_utility.set_location('p_validation_start_date '
            || to_char(l_validation_start_date) || ' ' || l_proc, 100);
end if;
  --
  -- Update the row.
  --
  update_dml
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => p_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
if g_debug then
  hr_utility.set_location('ovn 7 is: '||to_char(p_rec.object_version_number)||l_proc, 5);
  hr_utility.set_location('p_validation_start_date '
            || to_char(l_validation_start_date) || ' ' || l_proc, 110);
end if;
  --
  -- Call the supporting post-update operation
  --
  post_update
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => p_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
if g_debug then
  hr_utility.set_location('p_validation_start_date '
            || to_char(l_validation_start_date) || ' ' || l_proc, 120);
  hr_utility.set_location('ovn 8 is: '||to_char(p_rec.object_version_number)||l_proc, 5);
  end if;
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
  if g_debug then
     hr_utility.set_location('p_validation_start_date '
            || to_char(l_validation_start_date) || ' ' || l_proc, 120);
end if;
    Raise HR_Api.Validate_Enabled;
  else
  if g_debug then
     hr_utility.set_location('p_validation_start_date '
            || to_char(l_validation_start_date) || ' ' || l_proc, 120);
end if;
  End If;
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
    ROLLBACK TO upd_per_per;

End upd;
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_position_id                  in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_availability_status_id       in number           default hr_api.g_number,
--  p_business_group_id            in number           default hr_api.g_number,
  p_entry_step_id                in number           default hr_api.g_number,
  p_entry_grade_rule_id          in number           default hr_api.g_number,
--  p_job_id                       in number           default hr_api.g_number,
  p_location_id                  in number           default hr_api.g_number,
--  p_organization_id              in number           default hr_api.g_number,
  p_pay_freq_payroll_id          in number           default hr_api.g_number,
  p_position_definition_id       in number           default hr_api.g_number,
  p_position_transaction_id      in number           default hr_api.g_number,
  p_prior_position_id            in number           default hr_api.g_number,
  p_relief_position_id           in number           default hr_api.g_number,
  p_entry_grade_id               in number           default hr_api.g_number,
  p_successor_position_id        in number           default hr_api.g_number,
  p_supervisor_position_id       in number           default hr_api.g_number,
  p_amendment_date               in date             default hr_api.g_date,
  p_amendment_recommendation     in varchar2         default hr_api.g_varchar2,
  p_amendment_ref_number         in varchar2         default hr_api.g_varchar2,
  p_bargaining_unit_cd           in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_current_job_prop_end_date    in date             default hr_api.g_date,
  p_current_org_prop_end_date    in date             default hr_api.g_date,
  p_avail_status_prop_end_date   in date             default hr_api.g_date,
  p_date_effective               in date             default hr_api.g_date,
  p_date_end                     in date             default hr_api.g_date,
  p_earliest_hire_date           in date             default hr_api.g_date,
  p_fill_by_date                 in date             default hr_api.g_date,
  p_frequency                    in varchar2         default hr_api.g_varchar2,
  p_fte                          in number           default hr_api.g_number,
  p_max_persons                  in number           default hr_api.g_number,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_overlap_period               in number           default hr_api.g_number,
  p_overlap_unit_cd              in varchar2         default hr_api.g_varchar2,
  p_pay_term_end_day_cd          in varchar2         default hr_api.g_varchar2,
  p_pay_term_end_month_cd        in varchar2         default hr_api.g_varchar2,
  p_permanent_temporary_flag     in varchar2         default hr_api.g_varchar2,
  p_permit_recruitment_flag      in varchar2         default hr_api.g_varchar2,
  p_position_type                in varchar2         default hr_api.g_varchar2,
  p_posting_description          in varchar2         default hr_api.g_varchar2,
  p_probation_period             in number           default hr_api.g_number,
  p_probation_period_unit_cd     in varchar2         default hr_api.g_varchar2,
  p_replacement_required_flag    in varchar2         default hr_api.g_varchar2,
  p_review_flag                  in varchar2         default hr_api.g_varchar2,
  p_seasonal_flag                in varchar2         default hr_api.g_varchar2,
  p_security_requirements        in varchar2         default hr_api.g_varchar2,
  p_status                       in varchar2         default hr_api.g_varchar2,
  p_term_start_day_cd            in varchar2         default hr_api.g_varchar2,
  p_term_start_month_cd          in varchar2         default hr_api.g_varchar2,
  p_time_normal_finish           in varchar2         default hr_api.g_varchar2,
  p_time_normal_start            in varchar2         default hr_api.g_varchar2,
  p_update_source_cd             in varchar2         default hr_api.g_varchar2,
  p_working_hours                in number           default hr_api.g_number,
  p_works_council_approval_flag  in varchar2         default hr_api.g_varchar2,
  p_work_period_type_cd          in varchar2         default hr_api.g_varchar2,
  p_work_term_end_day_cd         in varchar2         default hr_api.g_varchar2,
  p_work_term_end_month_cd       in varchar2         default hr_api.g_varchar2,
  p_proposed_fte_for_layoff      in number           default hr_api.g_number,
  p_proposed_date_for_layoff     in date             default hr_api.g_date,
  p_pay_basis_id                 in  number          default hr_api.g_number,
  p_supervisor_id                in  number          default hr_api.g_number,
  p_copied_to_old_table_flag     in  varchar2         default hr_api.g_varchar2,
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
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_object_version_number        in out nocopy number,
  p_effective_date       in date,
  p_datetrack_mode       in varchar2,
  p_validate                     in boolean  default false
  ) is
--
  l_rec     hr_psf_shd.g_rec_type;
  l_proc varchar2(72) ;
--
Begin
if g_debug then
   l_proc    :=  g_package||'upd';
   hr_utility.set_location('Entering:'||l_proc, 5);
end if;

  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  hr_psf_shd.convert_args
  (
  p_position_id,
  null,
  null,
  p_availability_status_id,
  hr_api.g_number,                          -- p_business_group_id,
  p_entry_step_id,
  p_entry_grade_rule_id,
  hr_api.g_number,                          -- p_job_id,
  p_location_id,
  hr_api.g_number ,                         -- p_organization_id,
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
  p_object_version_number,
  null
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_effective_date, p_datetrack_mode, p_validate);
  if g_debug then
  hr_utility.set_location('l_rec.effective_start_date '  || to_char(l_rec.effective_start_date) || ' ' || l_proc, 100);
 end if;
  p_object_version_number       := l_rec.object_version_number;
  p_effective_start_date        := l_rec.effective_start_date;
  p_effective_end_date          := l_rec.effective_end_date;
   if g_debug then
  hr_utility.set_location('p_effective_start_date ' || to_char(p_effective_start_date) || ' ' || l_proc, 100);
   hr_utility.set_location(' Leaving:'||l_proc, 10);
   end if;
  --
  --
End upd;
--
end hr_psf_upd;

/

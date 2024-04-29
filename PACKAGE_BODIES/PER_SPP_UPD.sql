--------------------------------------------------------
--  DDL for Package Body PER_SPP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SPP_UPD" as
/* $Header: pespprhi.pkb 120.2.12010000.4 2008/11/05 14:50:57 brsinha ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_spp_upd.';  -- Global package name
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
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   update_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_dml
  (p_rec                   in out nocopy per_spp_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc	varchar2(72) := g_package||'dt_update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode = hr_api.g_correction) then
    hr_utility.set_location(l_proc, 10);
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
        (p_base_table_name => 'per_spinal_point_placements_f'
        ,p_base_key_column => 'placement_id'
        ,p_base_key_value  => p_rec.placement_id
        );
    --
  hr_utility.set_location('Entering:'||l_proc, 10);
  hr_utility.set_location('Reason '|| p_rec.reason, 10);
  hr_utility.set_location('Placement ID '||p_rec.placement_id, 10);
  hr_utility.set_location('Step ID '||p_rec.step_id, 10);
  hr_utility.set_location('OVN '||p_rec.object_version_number, 10);
  hr_utility.set_location('Start Date '||p_validation_start_date, 10);
  hr_utility.set_location('End Date '||p_validation_end_date, 10);
  hr_utility.set_location('Increment Number'||p_rec.increment_number, 20);
    per_spp_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the per_spinal_point_placements_f Row
    --
    update  per_spinal_point_placements_f
    set
     placement_id                         = p_rec.placement_id
    ,business_group_id                    = p_rec.business_group_id
    ,assignment_id                        = p_rec.assignment_id
    ,step_id                              = p_rec.step_id
    ,auto_increment_flag                  = p_rec.auto_increment_flag
    ,parent_spine_id                      = p_rec.parent_spine_id
    ,reason                               = p_rec.reason
    ,request_id                           = p_rec.request_id
    ,program_application_id               = p_rec.program_application_id
    ,program_id                           = p_rec.program_id
    ,program_update_date                  = p_rec.program_update_date
    ,increment_number                     = p_rec.increment_number
    ,object_version_number                = p_rec.object_version_number
    ,information1                         = p_rec.information1
    ,information2                         = p_rec.information2
    ,information3                         = p_rec.information3
    ,information4                         = p_rec.information4
    ,information5                         = p_rec.information5
    ,information6                         = p_rec.information6
    ,information7                         = p_rec.information7
    ,information8                         = p_rec.information8
    ,information9                         = p_rec.information9
    ,information10                        = p_rec.information10
    ,information11                        = p_rec.information11
    ,information12                        = p_rec.information12
    ,information13                        = p_rec.information13
    ,information14                        = p_rec.information14
    ,information15                        = p_rec.information15
    ,information16                        = p_rec.information16
    ,information17                        = p_rec.information17
    ,information18                        = p_rec.information18
    ,information19                        = p_rec.information19
    ,information20                        = p_rec.information20
    ,information21                        = p_rec.information21
    ,information22                        = p_rec.information22
    ,information23                        = p_rec.information23
    ,information24                        = p_rec.information24
    ,information25                        = p_rec.information25
    ,information26                        = p_rec.information26
    ,information27                        = p_rec.information27
    ,information28                        = p_rec.information28
    ,information29                        = p_rec.information29
    ,information30                        = p_rec.information30
    ,information_category                 = p_rec.information_category
    where   placement_id = p_rec.placement_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    per_spp_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location('Entering:'||l_proc, 15);
    --
    -- Set the effective start and end dates
    --
    p_rec.effective_start_date := p_validation_start_date;
    p_rec.effective_end_date   := p_validation_end_date;
  End If;
--
hr_utility.set_location(' Leaving:'||l_proc, 20);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_spp_shd.g_api_dml := false;   -- Unset the api dml status
    per_spp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_spp_shd.g_api_dml := false;   -- Unset the api dml status
    per_spp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_spp_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec                      in out nocopy per_spp_shd.g_rec_type
  ,p_effective_date           in date
  ,p_datetrack_mode           in varchar2
  ,p_validation_start_date    in date
  ,p_validation_end_date      in date
  ) is
--
  l_proc	varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_spp_upd.dt_update_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
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
--	the validation_start_date.
--   3) Call the insert_dml process to insert the new updated row
--      details.
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
  (p_rec                     in out nocopy per_spp_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc	         varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> hr_api.g_correction) then
    --
    -- Update the current effective end date
    --
    per_spp_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value	        => p_rec.placement_id
      ,p_new_effective_end_date => (p_validation_start_date - 1)
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
      ,p_object_version_number  => l_dummy_version_number
      );
    --
    If (p_datetrack_mode = hr_api.g_update_override) then
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      per_spp_del.delete_dml
        (p_rec                   => p_rec
        ,p_effective_date        => p_effective_date
        ,p_datetrack_mode        => p_datetrack_mode
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        );
    End If;
    --
    -- We must now insert the updated row
    --
    per_spp_ins.insert_dml
      (p_rec                    => p_rec
      ,p_effective_date	        => p_effective_date
      ,p_datetrack_mode	        => p_datetrack_mode
      ,p_validation_start_date  => p_validation_start_date
      ,p_validation_end_date    => p_validation_end_date
      );
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
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
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
  (p_rec                   in out nocopy per_spp_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc	varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_update
    (p_rec                   => p_rec
    ,p_effective_date	     => p_effective_date
    ,p_datetrack_mode	     => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< post_update >-------------------------------|
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
--   A Pl/Sql record structure.
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
  (p_rec                   in per_spp_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc	varchar2(72) := g_package||'post_update';
-- code changes start for bug 7457065
 l_step_end_date        per_spinal_point_steps_f.effective_end_date%type; -- added for 7457065
 l_next_placement_st_date  per_spinal_point_steps_f.effective_start_date%type; -- added for 7457065

    cursor c_step_end_date is
    select max(effective_end_date)
    from per_spinal_point_steps_f
    where step_id = p_rec.step_id;

    cursor c_next_placement_st_date is
    select min(effective_start_date)
    from per_spinal_point_placements_f
    where assignment_id = p_rec.assignment_id
    and effective_start_date > p_rec.effective_start_date;
-- code changes end for bug 7457065

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Code Changes start for Bug 7457065
  open c_step_end_date;
  fetch c_step_end_date into l_step_end_date;
  close c_step_end_date;
  hr_utility.set_location(l_proc, 6);
  if l_step_end_date < p_rec.effective_end_date then
    open c_next_placement_st_date;
    fetch c_next_placement_st_date into l_next_placement_st_date;
    close c_next_placement_st_date;
      hr_utility.set_location(l_proc, 7);
    if l_next_placement_st_date is not null then
        hr_utility.set_location(l_proc, 8);
      if l_next_placement_st_date > l_step_end_date + 1 then
         fnd_message.set_name('PER', 'HR_50439_SP_GAP_ERROR');
	 fnd_message.set_token('END_DATE',l_step_end_date);
         fnd_message.raise_error;
      end if;
          hr_utility.set_location(l_proc, 9);
    else
        hr_utility.set_location(l_proc, 10);
      update per_spinal_point_placements_f
      set effective_end_date = l_step_end_date
      where placement_id = p_rec.placement_id
      and effective_start_date = p_rec.effective_start_date;
      hr_utility.set_location(l_proc, 11);
    end if;
      hr_utility.set_location(l_proc, 12);
  end if;

  hr_utility.set_location(l_proc, 13);
-- Code Changes end for Bug 7457065
  begin
    --
    per_spp_rku.after_update
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_placement_id
      => p_rec.placement_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_step_id
      => p_rec.step_id
      ,p_auto_increment_flag
      => p_rec.auto_increment_flag
      ,p_parent_spine_id
      => p_rec.parent_spine_id
      ,p_reason
      => p_rec.reason
      ,p_request_id
      => p_rec.request_id
      ,p_program_application_id
      => p_rec.program_application_id
      ,p_program_id
      => p_rec.program_id
      ,p_program_update_date
      => p_rec.program_update_date
      ,p_increment_number
      => p_rec.increment_number
      ,p_information1                     => p_rec.information1
      ,p_information2                     => p_rec.information2
      ,p_information3                     => p_rec.information3
      ,p_information4                     => p_rec.information4
      ,p_information5                     => p_rec.information5
      ,p_information6                     => p_rec.information6
      ,p_information7                     => p_rec.information7
      ,p_information8                     => p_rec.information8
      ,p_information9                     => p_rec.information9
      ,p_information10                    => p_rec.information10
      ,p_information11                    => p_rec.information11
      ,p_information12                    => p_rec.information12
      ,p_information13                    => p_rec.information13
      ,p_information14                    => p_rec.information14
      ,p_information15                    => p_rec.information15
      ,p_information16                    => p_rec.information16
      ,p_information17                    => p_rec.information17
      ,p_information18                    => p_rec.information18
      ,p_information19                    => p_rec.information19
      ,p_information20                    => p_rec.information20
      ,p_information21                    => p_rec.information21
      ,p_information22                    => p_rec.information22
      ,p_information23                    => p_rec.information23
      ,p_information24                    => p_rec.information24
      ,p_information25                    => p_rec.information25
      ,p_information26                    => p_rec.information26
      ,p_information27                    => p_rec.information27
      ,p_information28                    => p_rec.information28
      ,p_information29                    => p_rec.information29
      ,p_information30                    => p_rec.information30
      ,p_information_category             => p_rec.information_category
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_effective_start_date_o
      => per_spp_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => per_spp_shd.g_old_rec.effective_end_date
      ,p_business_group_id_o
      => per_spp_shd.g_old_rec.business_group_id
      ,p_assignment_id_o
      => per_spp_shd.g_old_rec.assignment_id
      ,p_step_id_o
      => per_spp_shd.g_old_rec.step_id
      ,p_auto_increment_flag_o
      => per_spp_shd.g_old_rec.auto_increment_flag
      ,p_parent_spine_id_o
      => per_spp_shd.g_old_rec.parent_spine_id
      ,p_reason_o
      => per_spp_shd.g_old_rec.reason
      ,p_request_id_o
      => per_spp_shd.g_old_rec.request_id
      ,p_program_application_id_o
      => per_spp_shd.g_old_rec.program_application_id
      ,p_program_id_o
      => per_spp_shd.g_old_rec.program_id
      ,p_program_update_date_o
      => per_spp_shd.g_old_rec.program_update_date
      ,p_increment_number_o
      => per_spp_shd.g_old_rec.increment_number
      ,p_information1_o                   => per_spp_shd.g_old_rec.information1
      ,p_information2_o                   => per_spp_shd.g_old_rec.information2
      ,p_information3_o                   => per_spp_shd.g_old_rec.information3
      ,p_information4_o                   => per_spp_shd.g_old_rec.information4
      ,p_information5_o                   => per_spp_shd.g_old_rec.information5
      ,p_information6_o                   => per_spp_shd.g_old_rec.information6
      ,p_information7_o                   => per_spp_shd.g_old_rec.information7
      ,p_information8_o                   => per_spp_shd.g_old_rec.information8
      ,p_information9_o                   => per_spp_shd.g_old_rec.information9
      ,p_information10_o                  => per_spp_shd.g_old_rec.information10
      ,p_information11_o                  => per_spp_shd.g_old_rec.information11
      ,p_information12_o                  => per_spp_shd.g_old_rec.information12
      ,p_information13_o                  => per_spp_shd.g_old_rec.information13
      ,p_information14_o                  => per_spp_shd.g_old_rec.information14
      ,p_information15_o                  => per_spp_shd.g_old_rec.information15
      ,p_information16_o                  => per_spp_shd.g_old_rec.information16
      ,p_information17_o                  => per_spp_shd.g_old_rec.information17
      ,p_information18_o                  => per_spp_shd.g_old_rec.information18
      ,p_information19_o                  => per_spp_shd.g_old_rec.information19
      ,p_information20_o                  => per_spp_shd.g_old_rec.information20
      ,p_information21_o                  => per_spp_shd.g_old_rec.information21
      ,p_information22_o                  => per_spp_shd.g_old_rec.information22
      ,p_information23_o                  => per_spp_shd.g_old_rec.information23
      ,p_information24_o                  => per_spp_shd.g_old_rec.information24
      ,p_information25_o                  => per_spp_shd.g_old_rec.information25
      ,p_information26_o                  => per_spp_shd.g_old_rec.information26
      ,p_information27_o                  => per_spp_shd.g_old_rec.information27
      ,p_information28_o                  => per_spp_shd.g_old_rec.information28
      ,p_information29_o                  => per_spp_shd.g_old_rec.information29
      ,p_information30_o                  => per_spp_shd.g_old_rec.information30
      ,p_information_category_o           => per_spp_shd.g_old_rec.information_category
      ,p_object_version_number_o
      => per_spp_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_SPINAL_POINT_PLACEMENTS_F'
        ,p_hook_type   => 'AU');
      --
  end;
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
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs
  (p_rec in out nocopy per_spp_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    per_spp_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    per_spp_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.step_id = hr_api.g_number) then
    p_rec.step_id :=
    per_spp_shd.g_old_rec.step_id;
  End If;
  If (p_rec.auto_increment_flag = hr_api.g_varchar2) then
    p_rec.auto_increment_flag :=
    per_spp_shd.g_old_rec.auto_increment_flag;
  End If;
  If (p_rec.parent_spine_id = hr_api.g_number) then
    p_rec.parent_spine_id :=
    per_spp_shd.g_old_rec.parent_spine_id;
  End If;
  If (p_rec.reason = hr_api.g_varchar2) then
    p_rec.reason :=
    per_spp_shd.g_old_rec.reason;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    per_spp_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    per_spp_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    per_spp_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    per_spp_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.increment_number = hr_api.g_number) then
    p_rec.increment_number :=
    per_spp_shd.g_old_rec.increment_number;
  End If;
  If (p_rec.information1 = hr_api.g_varchar2) then
    p_rec.information1 := per_spp_shd.g_old_rec.information1;
  End If;
  If (p_rec.information2 = hr_api.g_varchar2) then
    p_rec.information2 := per_spp_shd.g_old_rec.information2;
  End If;
  If (p_rec.information3 = hr_api.g_varchar2) then
    p_rec.information3 := per_spp_shd.g_old_rec.information3;
  End If;
  If (p_rec.information3 = hr_api.g_varchar2) then
    p_rec.information3 := per_spp_shd.g_old_rec.information3;
  End If;
  If (p_rec.information4 = hr_api.g_varchar2) then
    p_rec.information4 := per_spp_shd.g_old_rec.information4;
  End If;
  If (p_rec.information5 = hr_api.g_varchar2) then
    p_rec.information5 := per_spp_shd.g_old_rec.information5;
  End If;
  If (p_rec.information6 = hr_api.g_varchar2) then
    p_rec.information6 := per_spp_shd.g_old_rec.information6;
  End If;
  If (p_rec.information7 = hr_api.g_varchar2) then
    p_rec.information7 := per_spp_shd.g_old_rec.information7;
  End If;
  If (p_rec.information8 = hr_api.g_varchar2) then
    p_rec.information8 := per_spp_shd.g_old_rec.information8;
  End If;
  If (p_rec.information9 = hr_api.g_varchar2) then
    p_rec.information9 := per_spp_shd.g_old_rec.information9;
  End If;
  If (p_rec.information10 = hr_api.g_varchar2) then
    p_rec.information10 := per_spp_shd.g_old_rec.information10;
  End If;
  If (p_rec.information11 = hr_api.g_varchar2) then
    p_rec.information11 := per_spp_shd.g_old_rec.information11;
  End If;
  If (p_rec.information12 = hr_api.g_varchar2) then
    p_rec.information12 := per_spp_shd.g_old_rec.information12;
  End If;
  If (p_rec.information13 = hr_api.g_varchar2) then
    p_rec.information13 := per_spp_shd.g_old_rec.information13;
  End If;
  If (p_rec.information14 = hr_api.g_varchar2) then
    p_rec.information14 := per_spp_shd.g_old_rec.information14;
  End If;
  If (p_rec.information15 = hr_api.g_varchar2) then
    p_rec.information15 := per_spp_shd.g_old_rec.information15;
  End If;
  If (p_rec.information16 = hr_api.g_varchar2) then
    p_rec.information16 := per_spp_shd.g_old_rec.information16;
  End If;
  If (p_rec.information17 = hr_api.g_varchar2) then
    p_rec.information17 := per_spp_shd.g_old_rec.information17;
  End If;
  If (p_rec.information18 = hr_api.g_varchar2) then
    p_rec.information18 := per_spp_shd.g_old_rec.information18;
  End If;
  If (p_rec.information19 = hr_api.g_varchar2) then
    p_rec.information19 := per_spp_shd.g_old_rec.information19;
  End If;
  If (p_rec.information20 = hr_api.g_varchar2) then
    p_rec.information20 := per_spp_shd.g_old_rec.information20;
  End If;
  If (p_rec.information21 = hr_api.g_varchar2) then
    p_rec.information21 := per_spp_shd.g_old_rec.information21;
  End If;
  If (p_rec.information22 = hr_api.g_varchar2) then
    p_rec.information22 := per_spp_shd.g_old_rec.information22;
  End If;
  If (p_rec.information23 = hr_api.g_varchar2) then
    p_rec.information23 := per_spp_shd.g_old_rec.information23;
  End If;
  If (p_rec.information24 = hr_api.g_varchar2) then
    p_rec.information24 := per_spp_shd.g_old_rec.information24;
  End If;
  If (p_rec.information25 = hr_api.g_varchar2) then
    p_rec.information25 := per_spp_shd.g_old_rec.information25;
  End If;
  If (p_rec.information26 = hr_api.g_varchar2) then
    p_rec.information26 := per_spp_shd.g_old_rec.information26;
  End If;
  If (p_rec.information27 = hr_api.g_varchar2) then
    p_rec.information27 := per_spp_shd.g_old_rec.information27;
  End If;
  If (p_rec.information28 = hr_api.g_varchar2) then
    p_rec.information28 := per_spp_shd.g_old_rec.information28;
  End If;
  If (p_rec.information29 = hr_api.g_varchar2) then
    p_rec.information29 := per_spp_shd.g_old_rec.information29;
  End If;
  If (p_rec.information30 = hr_api.g_varchar2) then
    p_rec.information30 := per_spp_shd.g_old_rec.information30;
  End If;
  If (p_rec.information_category = hr_api.g_varchar2) then
    p_rec.information_category := per_spp_shd.g_old_rec.information_category;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date in     date
  ,p_datetrack_mode in out nocopy varchar2
  ,p_rec            in out nocopy per_spp_shd.g_rec_type
  ) is
--
  l_proc			varchar2(72) := g_package||'upd';
  l_validation_start_date	date;
  l_validation_end_date		date;
  l_datetrack_mode		varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to update.
  --
  per_spp_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_placement_id                     => p_rec.placement_id
    ,p_object_version_number            => p_rec.object_version_number
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  per_spp_upd.convert_defs(p_rec);
  --
  per_spp_bus.update_validate
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call the supporting pre-update operation
  --
  pre_update
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Update the row.
  --
  update_dml
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date	            => l_validation_end_date
    );
  --
  -- Call the supporting post-update operation
  --

  post_update
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );

End upd;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< upd >-------------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_datetrack_mode               in out nocopy varchar2
  ,p_placement_id                 in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number
  ,p_assignment_id                in     number
  ,p_step_id                      in     number
  ,p_auto_increment_flag          in     varchar2
-- ,p_parent_spine_id              in     number
  ,p_reason                       in     varchar2
  ,p_request_id                   in     number
  ,p_program_application_id       in     number
  ,p_program_id                   in     number
  ,p_program_update_date          in     date
  ,p_increment_number             in     number
  ,p_information1                 in     varchar2
  ,p_information2                 in     varchar2
  ,p_information3                 in     varchar2
  ,p_information4                 in     varchar2
  ,p_information5                 in     varchar2
  ,p_information6                 in     varchar2
  ,p_information7                 in     varchar2
  ,p_information8                 in     varchar2
  ,p_information9                 in     varchar2
  ,p_information10                in     varchar2
  ,p_information11                in     varchar2
  ,p_information12                in     varchar2
  ,p_information13                in     varchar2
  ,p_information14                in     varchar2
  ,p_information15                in     varchar2
  ,p_information16                in     varchar2
  ,p_information17                in     varchar2
  ,p_information18                in     varchar2
  ,p_information19                in     varchar2
  ,p_information20                in     varchar2
  ,p_information21                in     varchar2
  ,p_information22                in     varchar2
  ,p_information23                in     varchar2
  ,p_information24                in     varchar2
  ,p_information25                in     varchar2
  ,p_information26                in     varchar2
  ,p_information27                in     varchar2
  ,p_information28                in     varchar2
  ,p_information29                in     varchar2
  ,p_information30                in     varchar2
  ,p_information_category         in     varchar2
  ,p_effective_start_date         in out nocopy date
  ,p_effective_end_date           in out nocopy date
  ) is
--
  l_rec		per_spp_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
  l_parent_spine_id per_spinal_point_placements_f.parent_spine_id%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('assignment_id :'||p_assignment_id,5);
  hr_utility.set_location('effective_date :'||p_effective_date,5);
  --
  -- Get the parent_spine_id
  --
    select distinct parent_spine_id
    into l_parent_spine_id
    from per_grade_spines_f pgs,
         per_all_assignments_f paa
    where paa.grade_id = pgs.grade_id
    and   paa.assignment_id = p_assignment_id
    and   p_effective_date between paa.effective_start_date
			       and paa.effective_end_date
    and   p_effective_date between pgs.effective_start_date
                               and pgs.effective_end_date;
  --
  hr_utility.set_location('Entering:'||l_proc, 6);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_spp_shd.convert_args
    (p_placement_id
    ,p_effective_start_date
    ,p_effective_end_date
    ,p_business_group_id
    ,p_assignment_id
    ,p_step_id
    ,p_auto_increment_flag
    ,l_parent_spine_id
    ,p_reason
    ,p_request_id
    ,p_program_application_id
    ,p_program_id
    ,p_program_update_date
    ,p_increment_number
    ,p_information1
    ,p_information2
    ,p_information3
    ,p_information4
    ,p_information5
    ,p_information6
    ,p_information7
    ,p_information8
    ,p_information9
    ,p_information10
    ,p_information11
    ,p_information12
    ,p_information13
    ,p_information14
    ,p_information15
    ,p_information16
    ,p_information17
    ,p_information18
    ,p_information19
    ,p_information20
    ,p_information21
    ,p_information22
    ,p_information23
    ,p_information24
    ,p_information25
    ,p_information26
    ,p_information27
    ,p_information28
    ,p_information29
    ,p_information30
    ,p_information_category
    ,p_object_version_number
    );
  hr_utility.set_location('Entering:'||l_proc, 7);
  /*
  select effective_start_date,effective_end_date
  into l_rec.effective_start_date, l_rec.effective_end_date
  from per_spinal_point_placements_f
  where placement_id = p_placement_id
  and p_effective_date between effective_start_date
     			   and effective_end_date;
  */
  hr_utility.set_location('Entering:'||l_proc, 8);
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_spp_upd.upd
    (p_effective_date
    ,p_datetrack_mode
    ,l_rec
    );
  --
  -- Set the out parameters
  --
  p_object_version_number            := l_rec.object_version_number;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

  /* added this exception for bug 6346478 which will fix 6024292.
     The fix for 6024292 has been reverted as it is raising bug 6346478*/

  exception
  when no_data_found then
   hr_utility.set_message(800, 'HR_289829_NO_SPP_REC_FOR_EDATE');
   hr_utility.raise_error;
End upd;
--
end per_spp_upd;

/

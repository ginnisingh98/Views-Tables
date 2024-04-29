--------------------------------------------------------
--  DDL for Package Body PER_REI_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_REI_UPD" as
/* $Header: pereirhi.pkb 115.6 2003/10/07 19:01:25 ttagawa noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_rei_upd.';  -- Global package name
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
--   This procedure controls the actual dml update logic. The functions of
--   this procedure are as follows:
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
  (p_rec                   in out nocopy per_rei_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'dt_update_dml';
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
        (p_base_table_name => 'per_contact_extra_info_f'
        ,p_base_key_column => 'contact_extra_info_id'
        ,p_base_key_value  => p_rec.contact_extra_info_id
        );
    --
    per_rei_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the per_contact_extra_info_f Row
    --
    update  per_contact_extra_info_f
    set
     contact_extra_info_id                = p_rec.contact_extra_info_id
    ,contact_relationship_id              = p_rec.contact_relationship_id
    ,information_type                     = p_rec.information_type
    ,cei_information_category             = p_rec.cei_information_category
    ,cei_information1                     = p_rec.cei_information1
    ,cei_information2                     = p_rec.cei_information2
    ,cei_information3                     = p_rec.cei_information3
    ,cei_information4                     = p_rec.cei_information4
    ,cei_information5                     = p_rec.cei_information5
    ,cei_information6                     = p_rec.cei_information6
    ,cei_information7                     = p_rec.cei_information7
    ,cei_information8                     = p_rec.cei_information8
    ,cei_information9                     = p_rec.cei_information9
    ,cei_information10                    = p_rec.cei_information10
    ,cei_information11                    = p_rec.cei_information11
    ,cei_information12                    = p_rec.cei_information12
    ,cei_information13                    = p_rec.cei_information13
    ,cei_information14                    = p_rec.cei_information14
    ,cei_information15                    = p_rec.cei_information15
    ,cei_information16                    = p_rec.cei_information16
    ,cei_information17                    = p_rec.cei_information17
    ,cei_information18                    = p_rec.cei_information18
    ,cei_information19                    = p_rec.cei_information19
    ,cei_information20                    = p_rec.cei_information20
    ,cei_information21                    = p_rec.cei_information21
    ,cei_information22                    = p_rec.cei_information22
    ,cei_information23                    = p_rec.cei_information23
    ,cei_information24                    = p_rec.cei_information24
    ,cei_information25                    = p_rec.cei_information25
    ,cei_information26                    = p_rec.cei_information26
    ,cei_information27                    = p_rec.cei_information27
    ,cei_information28                    = p_rec.cei_information28
    ,cei_information29                    = p_rec.cei_information29
    ,cei_information30                    = p_rec.cei_information30
    ,cei_attribute_category               = p_rec.cei_attribute_category
    ,cei_attribute1                       = p_rec.cei_attribute1
    ,cei_attribute2                       = p_rec.cei_attribute2
    ,cei_attribute3                       = p_rec.cei_attribute3
    ,cei_attribute4                       = p_rec.cei_attribute4
    ,cei_attribute5                       = p_rec.cei_attribute5
    ,cei_attribute6                       = p_rec.cei_attribute6
    ,cei_attribute7                       = p_rec.cei_attribute7
    ,cei_attribute8                       = p_rec.cei_attribute8
    ,cei_attribute9                       = p_rec.cei_attribute9
    ,cei_attribute10                      = p_rec.cei_attribute10
    ,cei_attribute11                      = p_rec.cei_attribute11
    ,cei_attribute12                      = p_rec.cei_attribute12
    ,cei_attribute13                      = p_rec.cei_attribute13
    ,cei_attribute14                      = p_rec.cei_attribute14
    ,cei_attribute15                      = p_rec.cei_attribute15
    ,cei_attribute16                      = p_rec.cei_attribute16
    ,cei_attribute17                      = p_rec.cei_attribute17
    ,cei_attribute18                      = p_rec.cei_attribute18
    ,cei_attribute19                      = p_rec.cei_attribute19
    ,cei_attribute20                      = p_rec.cei_attribute20
    ,object_version_number                = p_rec.object_version_number
    ,request_id                           = p_rec.request_id
    ,program_application_id               = p_rec.program_application_id
    ,program_id                           = p_rec.program_id
    ,program_update_date                  = p_rec.program_update_date
    where   contact_extra_info_id = p_rec.contact_extra_info_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    per_rei_shd.g_api_dml := false;   -- Unset the api dml status
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
    per_rei_shd.g_api_dml := false;   -- Unset the api dml status
    per_rei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_rei_shd.g_api_dml := false;   -- Unset the api dml status
    per_rei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_rei_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec                      in out nocopy per_rei_shd.g_rec_type
  ,p_effective_date           in date
  ,p_datetrack_mode           in varchar2
  ,p_validation_start_date    in date
  ,p_validation_end_date      in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_rei_upd.dt_update_dml
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
--      the validation_start_date.
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
  (p_rec                     in out nocopy     per_rei_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc                 varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> hr_api.g_correction) then
    --
    -- Update the current effective end date
    --
    per_rei_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date
      ,p_base_key_value         => p_rec.contact_extra_info_id
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
      per_rei_del.delete_dml
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
    per_rei_ins.insert_dml
      (p_rec                    => p_rec
      ,p_effective_date         => p_effective_date
      ,p_datetrack_mode         => p_datetrack_mode
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
  (p_rec                   in out nocopy per_rei_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_update
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
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
--   This private procedure contains any processing which is required after
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
  (p_rec                   in per_rei_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_rei_rku.after_update
      (p_effective_date
      => p_effective_date
      ,p_datetrack_mode
      => p_datetrack_mode
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_contact_extra_info_id
      => p_rec.contact_extra_info_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_contact_relationship_id
      => p_rec.contact_relationship_id
      ,p_information_type
      => p_rec.information_type
      ,p_cei_information_category
      => p_rec.cei_information_category
      ,p_cei_information1
      => p_rec.cei_information1
      ,p_cei_information2
      => p_rec.cei_information2
      ,p_cei_information3
      => p_rec.cei_information3
      ,p_cei_information4
      => p_rec.cei_information4
      ,p_cei_information5
      => p_rec.cei_information5
      ,p_cei_information6
      => p_rec.cei_information6
      ,p_cei_information7
      => p_rec.cei_information7
      ,p_cei_information8
      => p_rec.cei_information8
      ,p_cei_information9
      => p_rec.cei_information9
      ,p_cei_information10
      => p_rec.cei_information10
      ,p_cei_information11
      => p_rec.cei_information11
      ,p_cei_information12
      => p_rec.cei_information12
      ,p_cei_information13
      => p_rec.cei_information13
      ,p_cei_information14
      => p_rec.cei_information14
      ,p_cei_information15
      => p_rec.cei_information15
      ,p_cei_information16
      => p_rec.cei_information16
      ,p_cei_information17
      => p_rec.cei_information17
      ,p_cei_information18
      => p_rec.cei_information18
      ,p_cei_information19
      => p_rec.cei_information19
      ,p_cei_information20
      => p_rec.cei_information20
      ,p_cei_information21
      => p_rec.cei_information21
      ,p_cei_information22
      => p_rec.cei_information22
      ,p_cei_information23
      => p_rec.cei_information23
      ,p_cei_information24
      => p_rec.cei_information24
      ,p_cei_information25
      => p_rec.cei_information25
      ,p_cei_information26
      => p_rec.cei_information26
      ,p_cei_information27
      => p_rec.cei_information27
      ,p_cei_information28
      => p_rec.cei_information28
      ,p_cei_information29
      => p_rec.cei_information29
      ,p_cei_information30
      => p_rec.cei_information30
      ,p_cei_attribute_category
      => p_rec.cei_attribute_category
      ,p_cei_attribute1
      => p_rec.cei_attribute1
      ,p_cei_attribute2
      => p_rec.cei_attribute2
      ,p_cei_attribute3
      => p_rec.cei_attribute3
      ,p_cei_attribute4
      => p_rec.cei_attribute4
      ,p_cei_attribute5
      => p_rec.cei_attribute5
      ,p_cei_attribute6
      => p_rec.cei_attribute6
      ,p_cei_attribute7
      => p_rec.cei_attribute7
      ,p_cei_attribute8
      => p_rec.cei_attribute8
      ,p_cei_attribute9
      => p_rec.cei_attribute9
      ,p_cei_attribute10
      => p_rec.cei_attribute10
      ,p_cei_attribute11
      => p_rec.cei_attribute11
      ,p_cei_attribute12
      => p_rec.cei_attribute12
      ,p_cei_attribute13
      => p_rec.cei_attribute13
      ,p_cei_attribute14
      => p_rec.cei_attribute14
      ,p_cei_attribute15
      => p_rec.cei_attribute15
      ,p_cei_attribute16
      => p_rec.cei_attribute16
      ,p_cei_attribute17
      => p_rec.cei_attribute17
      ,p_cei_attribute18
      => p_rec.cei_attribute18
      ,p_cei_attribute19
      => p_rec.cei_attribute19
      ,p_cei_attribute20
      => p_rec.cei_attribute20
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_request_id
      => p_rec.request_id
      ,p_program_application_id
      => p_rec.program_application_id
      ,p_program_id
      => p_rec.program_id
      ,p_program_update_date
      => p_rec.program_update_date
      ,p_effective_start_date_o
      => per_rei_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => per_rei_shd.g_old_rec.effective_end_date
      ,p_contact_relationship_id_o
      => per_rei_shd.g_old_rec.contact_relationship_id
      ,p_information_type_o
      => per_rei_shd.g_old_rec.information_type
      ,p_cei_information_category_o
      => per_rei_shd.g_old_rec.cei_information_category
      ,p_cei_information1_o
      => per_rei_shd.g_old_rec.cei_information1
      ,p_cei_information2_o
      => per_rei_shd.g_old_rec.cei_information2
      ,p_cei_information3_o
      => per_rei_shd.g_old_rec.cei_information3
      ,p_cei_information4_o
      => per_rei_shd.g_old_rec.cei_information4
      ,p_cei_information5_o
      => per_rei_shd.g_old_rec.cei_information5
      ,p_cei_information6_o
      => per_rei_shd.g_old_rec.cei_information6
      ,p_cei_information7_o
      => per_rei_shd.g_old_rec.cei_information7
      ,p_cei_information8_o
      => per_rei_shd.g_old_rec.cei_information8
      ,p_cei_information9_o
      => per_rei_shd.g_old_rec.cei_information9
      ,p_cei_information10_o
      => per_rei_shd.g_old_rec.cei_information10
      ,p_cei_information11_o
      => per_rei_shd.g_old_rec.cei_information11
      ,p_cei_information12_o
      => per_rei_shd.g_old_rec.cei_information12
      ,p_cei_information13_o
      => per_rei_shd.g_old_rec.cei_information13
      ,p_cei_information14_o
      => per_rei_shd.g_old_rec.cei_information14
      ,p_cei_information15_o
      => per_rei_shd.g_old_rec.cei_information15
      ,p_cei_information16_o
      => per_rei_shd.g_old_rec.cei_information16
      ,p_cei_information17_o
      => per_rei_shd.g_old_rec.cei_information17
      ,p_cei_information18_o
      => per_rei_shd.g_old_rec.cei_information18
      ,p_cei_information19_o
      => per_rei_shd.g_old_rec.cei_information19
      ,p_cei_information20_o
      => per_rei_shd.g_old_rec.cei_information20
      ,p_cei_information21_o
      => per_rei_shd.g_old_rec.cei_information21
      ,p_cei_information22_o
      => per_rei_shd.g_old_rec.cei_information22
      ,p_cei_information23_o
      => per_rei_shd.g_old_rec.cei_information23
      ,p_cei_information24_o
      => per_rei_shd.g_old_rec.cei_information24
      ,p_cei_information25_o
      => per_rei_shd.g_old_rec.cei_information25
      ,p_cei_information26_o
      => per_rei_shd.g_old_rec.cei_information26
      ,p_cei_information27_o
      => per_rei_shd.g_old_rec.cei_information27
      ,p_cei_information28_o
      => per_rei_shd.g_old_rec.cei_information28
      ,p_cei_information29_o
      => per_rei_shd.g_old_rec.cei_information29
      ,p_cei_information30_o
      => per_rei_shd.g_old_rec.cei_information30
      ,p_cei_attribute_category_o
      => per_rei_shd.g_old_rec.cei_attribute_category
      ,p_cei_attribute1_o
      => per_rei_shd.g_old_rec.cei_attribute1
      ,p_cei_attribute2_o
      => per_rei_shd.g_old_rec.cei_attribute2
      ,p_cei_attribute3_o
      => per_rei_shd.g_old_rec.cei_attribute3
      ,p_cei_attribute4_o
      => per_rei_shd.g_old_rec.cei_attribute4
      ,p_cei_attribute5_o
      => per_rei_shd.g_old_rec.cei_attribute5
      ,p_cei_attribute6_o
      => per_rei_shd.g_old_rec.cei_attribute6
      ,p_cei_attribute7_o
      => per_rei_shd.g_old_rec.cei_attribute7
      ,p_cei_attribute8_o
      => per_rei_shd.g_old_rec.cei_attribute8
      ,p_cei_attribute9_o
      => per_rei_shd.g_old_rec.cei_attribute9
      ,p_cei_attribute10_o
      => per_rei_shd.g_old_rec.cei_attribute10
      ,p_cei_attribute11_o
      => per_rei_shd.g_old_rec.cei_attribute11
      ,p_cei_attribute12_o
      => per_rei_shd.g_old_rec.cei_attribute12
      ,p_cei_attribute13_o
      => per_rei_shd.g_old_rec.cei_attribute13
      ,p_cei_attribute14_o
      => per_rei_shd.g_old_rec.cei_attribute14
      ,p_cei_attribute15_o
      => per_rei_shd.g_old_rec.cei_attribute15
      ,p_cei_attribute16_o
      => per_rei_shd.g_old_rec.cei_attribute16
      ,p_cei_attribute17_o
      => per_rei_shd.g_old_rec.cei_attribute17
      ,p_cei_attribute18_o
      => per_rei_shd.g_old_rec.cei_attribute18
      ,p_cei_attribute19_o
      => per_rei_shd.g_old_rec.cei_attribute19
      ,p_cei_attribute20_o
      => per_rei_shd.g_old_rec.cei_attribute20
      ,p_object_version_number_o
      => per_rei_shd.g_old_rec.object_version_number
      ,p_request_id_o
      => per_rei_shd.g_old_rec.request_id
      ,p_program_application_id_o
      => per_rei_shd.g_old_rec.program_application_id
      ,p_program_id_o
      => per_rei_shd.g_old_rec.program_id
      ,p_program_update_date_o
      => per_rei_shd.g_old_rec.program_update_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_CONTACT_EXTRA_INFO_F'
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
  (p_rec in out nocopy per_rei_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.contact_relationship_id = hr_api.g_number) then
    p_rec.contact_relationship_id :=
    per_rei_shd.g_old_rec.contact_relationship_id;
  End If;
  If (p_rec.information_type = hr_api.g_varchar2) then
    p_rec.information_type :=
    per_rei_shd.g_old_rec.information_type;
  End If;
  If (p_rec.cei_information_category = hr_api.g_varchar2) then
    p_rec.cei_information_category :=
    per_rei_shd.g_old_rec.cei_information_category;
  End If;
  If (p_rec.cei_information1 = hr_api.g_varchar2) then
    p_rec.cei_information1 :=
    per_rei_shd.g_old_rec.cei_information1;
  End If;
  If (p_rec.cei_information2 = hr_api.g_varchar2) then
    p_rec.cei_information2 :=
    per_rei_shd.g_old_rec.cei_information2;
  End If;
  If (p_rec.cei_information3 = hr_api.g_varchar2) then
    p_rec.cei_information3 :=
    per_rei_shd.g_old_rec.cei_information3;
  End If;
  If (p_rec.cei_information4 = hr_api.g_varchar2) then
    p_rec.cei_information4 :=
    per_rei_shd.g_old_rec.cei_information4;
  End If;
  If (p_rec.cei_information5 = hr_api.g_varchar2) then
    p_rec.cei_information5 :=
    per_rei_shd.g_old_rec.cei_information5;
  End If;
  If (p_rec.cei_information6 = hr_api.g_varchar2) then
    p_rec.cei_information6 :=
    per_rei_shd.g_old_rec.cei_information6;
  End If;
  If (p_rec.cei_information7 = hr_api.g_varchar2) then
    p_rec.cei_information7 :=
    per_rei_shd.g_old_rec.cei_information7;
  End If;
  If (p_rec.cei_information8 = hr_api.g_varchar2) then
    p_rec.cei_information8 :=
    per_rei_shd.g_old_rec.cei_information8;
  End If;
  If (p_rec.cei_information9 = hr_api.g_varchar2) then
    p_rec.cei_information9 :=
    per_rei_shd.g_old_rec.cei_information9;
  End If;
  If (p_rec.cei_information10 = hr_api.g_varchar2) then
    p_rec.cei_information10 :=
    per_rei_shd.g_old_rec.cei_information10;
  End If;
  If (p_rec.cei_information11 = hr_api.g_varchar2) then
    p_rec.cei_information11 :=
    per_rei_shd.g_old_rec.cei_information11;
  End If;
  If (p_rec.cei_information12 = hr_api.g_varchar2) then
    p_rec.cei_information12 :=
    per_rei_shd.g_old_rec.cei_information12;
  End If;
  If (p_rec.cei_information13 = hr_api.g_varchar2) then
    p_rec.cei_information13 :=
    per_rei_shd.g_old_rec.cei_information13;
  End If;
  If (p_rec.cei_information14 = hr_api.g_varchar2) then
    p_rec.cei_information14 :=
    per_rei_shd.g_old_rec.cei_information14;
  End If;
  If (p_rec.cei_information15 = hr_api.g_varchar2) then
    p_rec.cei_information15 :=
    per_rei_shd.g_old_rec.cei_information15;
  End If;
  If (p_rec.cei_information16 = hr_api.g_varchar2) then
    p_rec.cei_information16 :=
    per_rei_shd.g_old_rec.cei_information16;
  End If;
  If (p_rec.cei_information17 = hr_api.g_varchar2) then
    p_rec.cei_information17 :=
    per_rei_shd.g_old_rec.cei_information17;
  End If;
  If (p_rec.cei_information18 = hr_api.g_varchar2) then
    p_rec.cei_information18 :=
    per_rei_shd.g_old_rec.cei_information18;
  End If;
  If (p_rec.cei_information19 = hr_api.g_varchar2) then
    p_rec.cei_information19 :=
    per_rei_shd.g_old_rec.cei_information19;
  End If;
  If (p_rec.cei_information20 = hr_api.g_varchar2) then
    p_rec.cei_information20 :=
    per_rei_shd.g_old_rec.cei_information20;
  End If;
  If (p_rec.cei_information21 = hr_api.g_varchar2) then
    p_rec.cei_information21 :=
    per_rei_shd.g_old_rec.cei_information21;
  End If;
  If (p_rec.cei_information22 = hr_api.g_varchar2) then
    p_rec.cei_information22 :=
    per_rei_shd.g_old_rec.cei_information22;
  End If;
  If (p_rec.cei_information23 = hr_api.g_varchar2) then
    p_rec.cei_information23 :=
    per_rei_shd.g_old_rec.cei_information23;
  End If;
  If (p_rec.cei_information24 = hr_api.g_varchar2) then
    p_rec.cei_information24 :=
    per_rei_shd.g_old_rec.cei_information24;
  End If;
  If (p_rec.cei_information25 = hr_api.g_varchar2) then
    p_rec.cei_information25 :=
    per_rei_shd.g_old_rec.cei_information25;
  End If;
  If (p_rec.cei_information26 = hr_api.g_varchar2) then
    p_rec.cei_information26 :=
    per_rei_shd.g_old_rec.cei_information26;
  End If;
  If (p_rec.cei_information27 = hr_api.g_varchar2) then
    p_rec.cei_information27 :=
    per_rei_shd.g_old_rec.cei_information27;
  End If;
  If (p_rec.cei_information28 = hr_api.g_varchar2) then
    p_rec.cei_information28 :=
    per_rei_shd.g_old_rec.cei_information28;
  End If;
  If (p_rec.cei_information29 = hr_api.g_varchar2) then
    p_rec.cei_information29 :=
    per_rei_shd.g_old_rec.cei_information29;
  End If;
  If (p_rec.cei_information30 = hr_api.g_varchar2) then
    p_rec.cei_information30 :=
    per_rei_shd.g_old_rec.cei_information30;
  End If;
  If (p_rec.cei_attribute_category = hr_api.g_varchar2) then
    p_rec.cei_attribute_category :=
    per_rei_shd.g_old_rec.cei_attribute_category;
  End If;
  If (p_rec.cei_attribute1 = hr_api.g_varchar2) then
    p_rec.cei_attribute1 :=
    per_rei_shd.g_old_rec.cei_attribute1;
  End If;
  If (p_rec.cei_attribute2 = hr_api.g_varchar2) then
    p_rec.cei_attribute2 :=
    per_rei_shd.g_old_rec.cei_attribute2;
  End If;
  If (p_rec.cei_attribute3 = hr_api.g_varchar2) then
    p_rec.cei_attribute3 :=
    per_rei_shd.g_old_rec.cei_attribute3;
  End If;
  If (p_rec.cei_attribute4 = hr_api.g_varchar2) then
    p_rec.cei_attribute4 :=
    per_rei_shd.g_old_rec.cei_attribute4;
  End If;
  If (p_rec.cei_attribute5 = hr_api.g_varchar2) then
    p_rec.cei_attribute5 :=
    per_rei_shd.g_old_rec.cei_attribute5;
  End If;
  If (p_rec.cei_attribute6 = hr_api.g_varchar2) then
    p_rec.cei_attribute6 :=
    per_rei_shd.g_old_rec.cei_attribute6;
  End If;
  If (p_rec.cei_attribute7 = hr_api.g_varchar2) then
    p_rec.cei_attribute7 :=
    per_rei_shd.g_old_rec.cei_attribute7;
  End If;
  If (p_rec.cei_attribute8 = hr_api.g_varchar2) then
    p_rec.cei_attribute8 :=
    per_rei_shd.g_old_rec.cei_attribute8;
  End If;
  If (p_rec.cei_attribute9 = hr_api.g_varchar2) then
    p_rec.cei_attribute9 :=
    per_rei_shd.g_old_rec.cei_attribute9;
  End If;
  If (p_rec.cei_attribute10 = hr_api.g_varchar2) then
    p_rec.cei_attribute10 :=
    per_rei_shd.g_old_rec.cei_attribute10;
  End If;
  If (p_rec.cei_attribute11 = hr_api.g_varchar2) then
    p_rec.cei_attribute11 :=
    per_rei_shd.g_old_rec.cei_attribute11;
  End If;
  If (p_rec.cei_attribute12 = hr_api.g_varchar2) then
    p_rec.cei_attribute12 :=
    per_rei_shd.g_old_rec.cei_attribute12;
  End If;
  If (p_rec.cei_attribute13 = hr_api.g_varchar2) then
    p_rec.cei_attribute13 :=
    per_rei_shd.g_old_rec.cei_attribute13;
  End If;
  If (p_rec.cei_attribute14 = hr_api.g_varchar2) then
    p_rec.cei_attribute14 :=
    per_rei_shd.g_old_rec.cei_attribute14;
  End If;
  If (p_rec.cei_attribute15 = hr_api.g_varchar2) then
    p_rec.cei_attribute15 :=
    per_rei_shd.g_old_rec.cei_attribute15;
  End If;
  If (p_rec.cei_attribute16 = hr_api.g_varchar2) then
    p_rec.cei_attribute16 :=
    per_rei_shd.g_old_rec.cei_attribute16;
  End If;
  If (p_rec.cei_attribute17 = hr_api.g_varchar2) then
    p_rec.cei_attribute17 :=
    per_rei_shd.g_old_rec.cei_attribute17;
  End If;
  If (p_rec.cei_attribute18 = hr_api.g_varchar2) then
    p_rec.cei_attribute18 :=
    per_rei_shd.g_old_rec.cei_attribute18;
  End If;
  If (p_rec.cei_attribute19 = hr_api.g_varchar2) then
    p_rec.cei_attribute19 :=
    per_rei_shd.g_old_rec.cei_attribute19;
  End If;
  If (p_rec.cei_attribute20 = hr_api.g_varchar2) then
    p_rec.cei_attribute20 :=
    per_rei_shd.g_old_rec.cei_attribute20;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    per_rei_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    per_rei_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    per_rei_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    per_rei_shd.g_old_rec.program_update_date;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date in     date
  ,p_datetrack_mode in     varchar2
  ,p_rec            in out nocopy per_rei_shd.g_rec_type
  ) is
--
  l_proc                        varchar2(72) := g_package||'upd';
  l_validation_start_date       date;
  l_validation_end_date         date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to update.
  --
  per_rei_shd.lck
    (p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_contact_extra_info_id            => p_rec.contact_extra_info_id
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
  per_rei_upd.convert_defs(p_rec);
  --
  per_rei_bus.update_validate
    (p_rec                              => p_rec
    ,p_effective_date                   => p_effective_date
    ,p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => l_validation_start_date
    ,p_validation_end_date              => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
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
    ,p_validation_end_date                  => l_validation_end_date
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
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< upd >-------------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_contact_extra_info_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_contact_relationship_id      in     number    default hr_api.g_number
  ,p_information_type             in     varchar2  default hr_api.g_varchar2
  ,p_cei_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_cei_information1             in     varchar2  default hr_api.g_varchar2
  ,p_cei_information2             in     varchar2  default hr_api.g_varchar2
  ,p_cei_information3             in     varchar2  default hr_api.g_varchar2
  ,p_cei_information4             in     varchar2  default hr_api.g_varchar2
  ,p_cei_information5             in     varchar2  default hr_api.g_varchar2
  ,p_cei_information6             in     varchar2  default hr_api.g_varchar2
  ,p_cei_information7             in     varchar2  default hr_api.g_varchar2
  ,p_cei_information8             in     varchar2  default hr_api.g_varchar2
  ,p_cei_information9             in     varchar2  default hr_api.g_varchar2
  ,p_cei_information10            in     varchar2  default hr_api.g_varchar2
  ,p_cei_information11            in     varchar2  default hr_api.g_varchar2
  ,p_cei_information12            in     varchar2  default hr_api.g_varchar2
  ,p_cei_information13            in     varchar2  default hr_api.g_varchar2
  ,p_cei_information14            in     varchar2  default hr_api.g_varchar2
  ,p_cei_information15            in     varchar2  default hr_api.g_varchar2
  ,p_cei_information16            in     varchar2  default hr_api.g_varchar2
  ,p_cei_information17            in     varchar2  default hr_api.g_varchar2
  ,p_cei_information18            in     varchar2  default hr_api.g_varchar2
  ,p_cei_information19            in     varchar2  default hr_api.g_varchar2
  ,p_cei_information20            in     varchar2  default hr_api.g_varchar2
  ,p_cei_information21            in     varchar2  default hr_api.g_varchar2
  ,p_cei_information22            in     varchar2  default hr_api.g_varchar2
  ,p_cei_information23            in     varchar2  default hr_api.g_varchar2
  ,p_cei_information24            in     varchar2  default hr_api.g_varchar2
  ,p_cei_information25            in     varchar2  default hr_api.g_varchar2
  ,p_cei_information26            in     varchar2  default hr_api.g_varchar2
  ,p_cei_information27            in     varchar2  default hr_api.g_varchar2
  ,p_cei_information28            in     varchar2  default hr_api.g_varchar2
  ,p_cei_information29            in     varchar2  default hr_api.g_varchar2
  ,p_cei_information30            in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_cei_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
--
  l_rec         per_rei_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_rei_shd.convert_args
    (p_contact_extra_info_id
    ,null
    ,null
    ,p_contact_relationship_id
    ,p_information_type
    ,p_cei_information_category
    ,p_cei_information1
    ,p_cei_information2
    ,p_cei_information3
    ,p_cei_information4
    ,p_cei_information5
    ,p_cei_information6
    ,p_cei_information7
    ,p_cei_information8
    ,p_cei_information9
    ,p_cei_information10
    ,p_cei_information11
    ,p_cei_information12
    ,p_cei_information13
    ,p_cei_information14
    ,p_cei_information15
    ,p_cei_information16
    ,p_cei_information17
    ,p_cei_information18
    ,p_cei_information19
    ,p_cei_information20
    ,p_cei_information21
    ,p_cei_information22
    ,p_cei_information23
    ,p_cei_information24
    ,p_cei_information25
    ,p_cei_information26
    ,p_cei_information27
    ,p_cei_information28
    ,p_cei_information29
    ,p_cei_information30
    ,p_cei_attribute_category
    ,p_cei_attribute1
    ,p_cei_attribute2
    ,p_cei_attribute3
    ,p_cei_attribute4
    ,p_cei_attribute5
    ,p_cei_attribute6
    ,p_cei_attribute7
    ,p_cei_attribute8
    ,p_cei_attribute9
    ,p_cei_attribute10
    ,p_cei_attribute11
    ,p_cei_attribute12
    ,p_cei_attribute13
    ,p_cei_attribute14
    ,p_cei_attribute15
    ,p_cei_attribute16
    ,p_cei_attribute17
    ,p_cei_attribute18
    ,p_cei_attribute19
    ,p_cei_attribute20
    ,p_object_version_number
    ,p_request_id
    ,p_program_application_id
    ,p_program_id
    ,p_program_update_date
    );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_rei_upd.upd
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
End upd;
--
end per_rei_upd;

/

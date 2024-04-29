--------------------------------------------------------
--  DDL for Package Body PER_PJI_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PJI_UPD" as
/* $Header: pepjirhi.pkb 115.8 2002/12/03 15:41:52 eumenyio ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pji_upd.';  -- Global package name
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
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
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
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
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
Procedure update_dml
  (p_rec in out nocopy per_pji_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  -- Update the per_prev_job_extra_info Row
  --
  update per_prev_job_extra_info
    set
     previous_job_extra_info_id      = p_rec.previous_job_extra_info_id
    ,previous_job_id                 = p_rec.previous_job_id
    ,information_type                = p_rec.information_type
    ,pji_attribute_category          = p_rec.pji_attribute_category
    ,pji_attribute1                  = p_rec.pji_attribute1
    ,pji_attribute2                  = p_rec.pji_attribute2
    ,pji_attribute3                  = p_rec.pji_attribute3
    ,pji_attribute4                  = p_rec.pji_attribute4
    ,pji_attribute5                  = p_rec.pji_attribute5
    ,pji_attribute6                  = p_rec.pji_attribute6
    ,pji_attribute7                  = p_rec.pji_attribute7
    ,pji_attribute8                  = p_rec.pji_attribute8
    ,pji_attribute9                  = p_rec.pji_attribute9
    ,pji_attribute10                 = p_rec.pji_attribute10
    ,pji_attribute11                 = p_rec.pji_attribute11
    ,pji_attribute12                 = p_rec.pji_attribute12
    ,pji_attribute13                 = p_rec.pji_attribute13
    ,pji_attribute14                 = p_rec.pji_attribute14
    ,pji_attribute15                 = p_rec.pji_attribute15
    ,pji_attribute16                 = p_rec.pji_attribute16
    ,pji_attribute17                 = p_rec.pji_attribute17
    ,pji_attribute18                 = p_rec.pji_attribute18
    ,pji_attribute19                 = p_rec.pji_attribute19
    ,pji_attribute20                 = p_rec.pji_attribute20
    ,pji_attribute21                 = p_rec.pji_attribute21
    ,pji_attribute22                 = p_rec.pji_attribute22
    ,pji_attribute23                 = p_rec.pji_attribute23
    ,pji_attribute24                 = p_rec.pji_attribute24
    ,pji_attribute25                 = p_rec.pji_attribute25
    ,pji_attribute26                 = p_rec.pji_attribute26
    ,pji_attribute27                 = p_rec.pji_attribute27
    ,pji_attribute28                 = p_rec.pji_attribute28
    ,pji_attribute29                 = p_rec.pji_attribute29
    ,pji_attribute30                 = p_rec.pji_attribute30
    ,pji_information_category        = p_rec.pji_information_category
    ,pji_information1                = p_rec.pji_information1
    ,pji_information2                = p_rec.pji_information2
    ,pji_information3                = p_rec.pji_information3
    ,pji_information4                = p_rec.pji_information4
    ,pji_information5                = p_rec.pji_information5
    ,pji_information6                = p_rec.pji_information6
    ,pji_information7                = p_rec.pji_information7
    ,pji_information8                = p_rec.pji_information8
    ,pji_information9                = p_rec.pji_information9
    ,pji_information10               = p_rec.pji_information10
    ,pji_information11               = p_rec.pji_information11
    ,pji_information12               = p_rec.pji_information12
    ,pji_information13               = p_rec.pji_information13
    ,pji_information14               = p_rec.pji_information14
    ,pji_information15               = p_rec.pji_information15
    ,pji_information16               = p_rec.pji_information16
    ,pji_information17               = p_rec.pji_information17
    ,pji_information18               = p_rec.pji_information18
    ,pji_information19               = p_rec.pji_information19
    ,pji_information20               = p_rec.pji_information20
    ,pji_information21               = p_rec.pji_information21
    ,pji_information22               = p_rec.pji_information22
    ,pji_information23               = p_rec.pji_information23
    ,pji_information24               = p_rec.pji_information24
    ,pji_information25               = p_rec.pji_information25
    ,pji_information26               = p_rec.pji_information26
    ,pji_information27               = p_rec.pji_information27
    ,pji_information28               = p_rec.pji_information28
    ,pji_information29               = p_rec.pji_information29
    ,pji_information30               = p_rec.pji_information30
    ,object_version_number           = p_rec.object_version_number
    where previous_job_extra_info_id = p_rec.previous_job_extra_info_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_pji_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_pji_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_pji_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception wil be raised
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
Procedure pre_update
  (p_rec in per_pji_shd.g_rec_type
  ) is
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
  (p_rec                          in per_pji_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_pji_rku.after_update
      (p_previous_job_extra_info_id
      => p_rec.previous_job_extra_info_id
      ,p_previous_job_id
      => p_rec.previous_job_id
      ,p_information_type
      => p_rec.information_type
      ,p_pji_attribute_category
      => p_rec.pji_attribute_category
      ,p_pji_attribute1
      => p_rec.pji_attribute1
      ,p_pji_attribute2
      => p_rec.pji_attribute2
      ,p_pji_attribute3
      => p_rec.pji_attribute3
      ,p_pji_attribute4
      => p_rec.pji_attribute4
      ,p_pji_attribute5
      => p_rec.pji_attribute5
      ,p_pji_attribute6
      => p_rec.pji_attribute6
      ,p_pji_attribute7
      => p_rec.pji_attribute7
      ,p_pji_attribute8
      => p_rec.pji_attribute8
      ,p_pji_attribute9
      => p_rec.pji_attribute9
      ,p_pji_attribute10
      => p_rec.pji_attribute10
      ,p_pji_attribute11
      => p_rec.pji_attribute11
      ,p_pji_attribute12
      => p_rec.pji_attribute12
      ,p_pji_attribute13
      => p_rec.pji_attribute13
      ,p_pji_attribute14
      => p_rec.pji_attribute14
      ,p_pji_attribute15
      => p_rec.pji_attribute15
      ,p_pji_attribute16
      => p_rec.pji_attribute16
      ,p_pji_attribute17
      => p_rec.pji_attribute17
      ,p_pji_attribute18
      => p_rec.pji_attribute18
      ,p_pji_attribute19
      => p_rec.pji_attribute19
      ,p_pji_attribute20
      => p_rec.pji_attribute20
      ,p_pji_attribute21
      => p_rec.pji_attribute21
      ,p_pji_attribute22
      => p_rec.pji_attribute22
      ,p_pji_attribute23
      => p_rec.pji_attribute23
      ,p_pji_attribute24
      => p_rec.pji_attribute24
      ,p_pji_attribute25
      => p_rec.pji_attribute25
      ,p_pji_attribute26
      => p_rec.pji_attribute26
      ,p_pji_attribute27
      => p_rec.pji_attribute27
      ,p_pji_attribute28
      => p_rec.pji_attribute28
      ,p_pji_attribute29
      => p_rec.pji_attribute29
      ,p_pji_attribute30
      => p_rec.pji_attribute30
      ,p_pji_information_category
      => p_rec.pji_information_category
      ,p_pji_information1
      => p_rec.pji_information1
      ,p_pji_information2
      => p_rec.pji_information2
      ,p_pji_information3
      => p_rec.pji_information3
      ,p_pji_information4
      => p_rec.pji_information4
      ,p_pji_information5
      => p_rec.pji_information5
      ,p_pji_information6
      => p_rec.pji_information6
      ,p_pji_information7
      => p_rec.pji_information7
      ,p_pji_information8
      => p_rec.pji_information8
      ,p_pji_information9
      => p_rec.pji_information9
      ,p_pji_information10
      => p_rec.pji_information10
      ,p_pji_information11
      => p_rec.pji_information11
      ,p_pji_information12
      => p_rec.pji_information12
      ,p_pji_information13
      => p_rec.pji_information13
      ,p_pji_information14
      => p_rec.pji_information14
      ,p_pji_information15
      => p_rec.pji_information15
      ,p_pji_information16
      => p_rec.pji_information16
      ,p_pji_information17
      => p_rec.pji_information17
      ,p_pji_information18
      => p_rec.pji_information18
      ,p_pji_information19
      => p_rec.pji_information19
      ,p_pji_information20
      => p_rec.pji_information20
      ,p_pji_information21
      => p_rec.pji_information21
      ,p_pji_information22
      => p_rec.pji_information22
      ,p_pji_information23
      => p_rec.pji_information23
      ,p_pji_information24
      => p_rec.pji_information24
      ,p_pji_information25
      => p_rec.pji_information25
      ,p_pji_information26
      => p_rec.pji_information26
      ,p_pji_information27
      => p_rec.pji_information27
      ,p_pji_information28
      => p_rec.pji_information28
      ,p_pji_information29
      => p_rec.pji_information29
      ,p_pji_information30
      => p_rec.pji_information30
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_PREV_JOB_EXTRA_INFO'
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
  (p_rec in out nocopy per_pji_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.previous_job_id = hr_api.g_number) then
    p_rec.previous_job_id :=
    per_pji_shd.g_old_rec.previous_job_id;
  End If;
  If (p_rec.information_type = hr_api.g_varchar2) then
    p_rec.information_type :=
    per_pji_shd.g_old_rec.information_type;
  End If;
  If (p_rec.pji_attribute_category = hr_api.g_varchar2) then
    p_rec.pji_attribute_category :=
    per_pji_shd.g_old_rec.pji_attribute_category;
  End If;
  If (p_rec.pji_attribute1 = hr_api.g_varchar2) then
    p_rec.pji_attribute1 :=
    per_pji_shd.g_old_rec.pji_attribute1;
  End If;
  If (p_rec.pji_attribute2 = hr_api.g_varchar2) then
    p_rec.pji_attribute2 :=
    per_pji_shd.g_old_rec.pji_attribute2;
  End If;
  If (p_rec.pji_attribute3 = hr_api.g_varchar2) then
    p_rec.pji_attribute3 :=
    per_pji_shd.g_old_rec.pji_attribute3;
  End If;
  If (p_rec.pji_attribute4 = hr_api.g_varchar2) then
    p_rec.pji_attribute4 :=
    per_pji_shd.g_old_rec.pji_attribute4;
  End If;
  If (p_rec.pji_attribute5 = hr_api.g_varchar2) then
    p_rec.pji_attribute5 :=
    per_pji_shd.g_old_rec.pji_attribute5;
  End If;
  If (p_rec.pji_attribute6 = hr_api.g_varchar2) then
    p_rec.pji_attribute6 :=
    per_pji_shd.g_old_rec.pji_attribute6;
  End If;
  If (p_rec.pji_attribute7 = hr_api.g_varchar2) then
    p_rec.pji_attribute7 :=
    per_pji_shd.g_old_rec.pji_attribute7;
  End If;
  If (p_rec.pji_attribute8 = hr_api.g_varchar2) then
    p_rec.pji_attribute8 :=
    per_pji_shd.g_old_rec.pji_attribute8;
  End If;
  If (p_rec.pji_attribute9 = hr_api.g_varchar2) then
    p_rec.pji_attribute9 :=
    per_pji_shd.g_old_rec.pji_attribute9;
  End If;
  If (p_rec.pji_attribute10 = hr_api.g_varchar2) then
    p_rec.pji_attribute10 :=
    per_pji_shd.g_old_rec.pji_attribute10;
  End If;
  If (p_rec.pji_attribute11 = hr_api.g_varchar2) then
    p_rec.pji_attribute11 :=
    per_pji_shd.g_old_rec.pji_attribute11;
  End If;
  If (p_rec.pji_attribute12 = hr_api.g_varchar2) then
    p_rec.pji_attribute12 :=
    per_pji_shd.g_old_rec.pji_attribute12;
  End If;
  If (p_rec.pji_attribute13 = hr_api.g_varchar2) then
    p_rec.pji_attribute13 :=
    per_pji_shd.g_old_rec.pji_attribute13;
  End If;
  If (p_rec.pji_attribute14 = hr_api.g_varchar2) then
    p_rec.pji_attribute14 :=
    per_pji_shd.g_old_rec.pji_attribute14;
  End If;
  If (p_rec.pji_attribute15 = hr_api.g_varchar2) then
    p_rec.pji_attribute15 :=
    per_pji_shd.g_old_rec.pji_attribute15;
  End If;
  If (p_rec.pji_attribute16 = hr_api.g_varchar2) then
    p_rec.pji_attribute16 :=
    per_pji_shd.g_old_rec.pji_attribute16;
  End If;
  If (p_rec.pji_attribute17 = hr_api.g_varchar2) then
    p_rec.pji_attribute17 :=
    per_pji_shd.g_old_rec.pji_attribute17;
  End If;
  If (p_rec.pji_attribute18 = hr_api.g_varchar2) then
    p_rec.pji_attribute18 :=
    per_pji_shd.g_old_rec.pji_attribute18;
  End If;
  If (p_rec.pji_attribute19 = hr_api.g_varchar2) then
    p_rec.pji_attribute19 :=
    per_pji_shd.g_old_rec.pji_attribute19;
  End If;
  If (p_rec.pji_attribute20 = hr_api.g_varchar2) then
    p_rec.pji_attribute20 :=
    per_pji_shd.g_old_rec.pji_attribute20;
  End If;
  If (p_rec.pji_attribute21 = hr_api.g_varchar2) then
    p_rec.pji_attribute21 :=
    per_pji_shd.g_old_rec.pji_attribute21;
  End If;
  If (p_rec.pji_attribute22 = hr_api.g_varchar2) then
    p_rec.pji_attribute22 :=
    per_pji_shd.g_old_rec.pji_attribute22;
  End If;
  If (p_rec.pji_attribute23 = hr_api.g_varchar2) then
    p_rec.pji_attribute23 :=
    per_pji_shd.g_old_rec.pji_attribute23;
  End If;
  If (p_rec.pji_attribute24 = hr_api.g_varchar2) then
    p_rec.pji_attribute24 :=
    per_pji_shd.g_old_rec.pji_attribute24;
  End If;
  If (p_rec.pji_attribute25 = hr_api.g_varchar2) then
    p_rec.pji_attribute25 :=
    per_pji_shd.g_old_rec.pji_attribute25;
  End If;
  If (p_rec.pji_attribute26 = hr_api.g_varchar2) then
    p_rec.pji_attribute26 :=
    per_pji_shd.g_old_rec.pji_attribute26;
  End If;
  If (p_rec.pji_attribute27 = hr_api.g_varchar2) then
    p_rec.pji_attribute27 :=
    per_pji_shd.g_old_rec.pji_attribute27;
  End If;
  If (p_rec.pji_attribute28 = hr_api.g_varchar2) then
    p_rec.pji_attribute28 :=
    per_pji_shd.g_old_rec.pji_attribute28;
  End If;
  If (p_rec.pji_attribute29 = hr_api.g_varchar2) then
    p_rec.pji_attribute29 :=
    per_pji_shd.g_old_rec.pji_attribute29;
  End If;
  If (p_rec.pji_attribute30 = hr_api.g_varchar2) then
    p_rec.pji_attribute30 :=
    per_pji_shd.g_old_rec.pji_attribute30;
  End If;
  If (p_rec.pji_information_category = hr_api.g_varchar2) then
    p_rec.pji_information_category :=
    per_pji_shd.g_old_rec.pji_information_category;
  End If;
  If (p_rec.pji_information1 = hr_api.g_varchar2) then
    p_rec.pji_information1 :=
    per_pji_shd.g_old_rec.pji_information1;
  End If;
  If (p_rec.pji_information2 = hr_api.g_varchar2) then
    p_rec.pji_information2 :=
    per_pji_shd.g_old_rec.pji_information2;
  End If;
  If (p_rec.pji_information3 = hr_api.g_varchar2) then
    p_rec.pji_information3 :=
    per_pji_shd.g_old_rec.pji_information3;
  End If;
  If (p_rec.pji_information4 = hr_api.g_varchar2) then
    p_rec.pji_information4 :=
    per_pji_shd.g_old_rec.pji_information4;
  End If;
  If (p_rec.pji_information5 = hr_api.g_varchar2) then
    p_rec.pji_information5 :=
    per_pji_shd.g_old_rec.pji_information5;
  End If;
  If (p_rec.pji_information6 = hr_api.g_varchar2) then
    p_rec.pji_information6 :=
    per_pji_shd.g_old_rec.pji_information6;
  End If;
  If (p_rec.pji_information7 = hr_api.g_varchar2) then
    p_rec.pji_information7 :=
    per_pji_shd.g_old_rec.pji_information7;
  End If;
  If (p_rec.pji_information8 = hr_api.g_varchar2) then
    p_rec.pji_information8 :=
    per_pji_shd.g_old_rec.pji_information8;
  End If;
  If (p_rec.pji_information9 = hr_api.g_varchar2) then
    p_rec.pji_information9 :=
    per_pji_shd.g_old_rec.pji_information9;
  End If;
  If (p_rec.pji_information10 = hr_api.g_varchar2) then
    p_rec.pji_information10 :=
    per_pji_shd.g_old_rec.pji_information10;
  End If;
  If (p_rec.pji_information11 = hr_api.g_varchar2) then
    p_rec.pji_information11 :=
    per_pji_shd.g_old_rec.pji_information11;
  End If;
  If (p_rec.pji_information12 = hr_api.g_varchar2) then
    p_rec.pji_information12 :=
    per_pji_shd.g_old_rec.pji_information12;
  End If;
  If (p_rec.pji_information13 = hr_api.g_varchar2) then
    p_rec.pji_information13 :=
    per_pji_shd.g_old_rec.pji_information13;
  End If;
  If (p_rec.pji_information14 = hr_api.g_varchar2) then
    p_rec.pji_information14 :=
    per_pji_shd.g_old_rec.pji_information14;
  End If;
  If (p_rec.pji_information15 = hr_api.g_varchar2) then
    p_rec.pji_information15 :=
    per_pji_shd.g_old_rec.pji_information15;
  End If;
  If (p_rec.pji_information16 = hr_api.g_varchar2) then
    p_rec.pji_information16 :=
    per_pji_shd.g_old_rec.pji_information16;
  End If;
  If (p_rec.pji_information17 = hr_api.g_varchar2) then
    p_rec.pji_information17 :=
    per_pji_shd.g_old_rec.pji_information17;
  End If;
  If (p_rec.pji_information18 = hr_api.g_varchar2) then
    p_rec.pji_information18 :=
    per_pji_shd.g_old_rec.pji_information18;
  End If;
  If (p_rec.pji_information19 = hr_api.g_varchar2) then
    p_rec.pji_information19 :=
    per_pji_shd.g_old_rec.pji_information19;
  End If;
  If (p_rec.pji_information20 = hr_api.g_varchar2) then
    p_rec.pji_information20 :=
    per_pji_shd.g_old_rec.pji_information20;
  End If;
  If (p_rec.pji_information21 = hr_api.g_varchar2) then
    p_rec.pji_information21 :=
    per_pji_shd.g_old_rec.pji_information21;
  End If;
  If (p_rec.pji_information22 = hr_api.g_varchar2) then
    p_rec.pji_information22 :=
    per_pji_shd.g_old_rec.pji_information22;
  End If;
  If (p_rec.pji_information23 = hr_api.g_varchar2) then
    p_rec.pji_information23 :=
    per_pji_shd.g_old_rec.pji_information23;
  End If;
  If (p_rec.pji_information24 = hr_api.g_varchar2) then
    p_rec.pji_information24 :=
    per_pji_shd.g_old_rec.pji_information24;
  End If;
  If (p_rec.pji_information25 = hr_api.g_varchar2) then
    p_rec.pji_information25 :=
    per_pji_shd.g_old_rec.pji_information25;
  End If;
  If (p_rec.pji_information26 = hr_api.g_varchar2) then
    p_rec.pji_information26 :=
    per_pji_shd.g_old_rec.pji_information26;
  End If;
  If (p_rec.pji_information27 = hr_api.g_varchar2) then
    p_rec.pji_information27 :=
    per_pji_shd.g_old_rec.pji_information27;
  End If;
  If (p_rec.pji_information28 = hr_api.g_varchar2) then
    p_rec.pji_information28 :=
    per_pji_shd.g_old_rec.pji_information28;
  End If;
  If (p_rec.pji_information29 = hr_api.g_varchar2) then
    p_rec.pji_information29 :=
    per_pji_shd.g_old_rec.pji_information29;
  End If;
  If (p_rec.pji_information30 = hr_api.g_varchar2) then
    p_rec.pji_information30 :=
    per_pji_shd.g_old_rec.pji_information30;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy per_pji_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_pji_shd.lck
    (p_rec.previous_job_extra_info_id
    ,p_rec.object_version_number
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  per_pji_bus.update_validate
     (p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  per_pji_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  per_pji_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  per_pji_upd.post_update
     (p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_previous_job_extra_info_id   in     number
  ,p_object_version_number        in out nocopy number
  ,p_previous_job_id              in     number    default hr_api.g_number
  ,p_information_type             in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_pji_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_pji_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_pji_information1             in     varchar2  default hr_api.g_varchar2
  ,p_pji_information2             in     varchar2  default hr_api.g_varchar2
  ,p_pji_information3             in     varchar2  default hr_api.g_varchar2
  ,p_pji_information4             in     varchar2  default hr_api.g_varchar2
  ,p_pji_information5             in     varchar2  default hr_api.g_varchar2
  ,p_pji_information6             in     varchar2  default hr_api.g_varchar2
  ,p_pji_information7             in     varchar2  default hr_api.g_varchar2
  ,p_pji_information8             in     varchar2  default hr_api.g_varchar2
  ,p_pji_information9             in     varchar2  default hr_api.g_varchar2
  ,p_pji_information10            in     varchar2  default hr_api.g_varchar2
  ,p_pji_information11            in     varchar2  default hr_api.g_varchar2
  ,p_pji_information12            in     varchar2  default hr_api.g_varchar2
  ,p_pji_information13            in     varchar2  default hr_api.g_varchar2
  ,p_pji_information14            in     varchar2  default hr_api.g_varchar2
  ,p_pji_information15            in     varchar2  default hr_api.g_varchar2
  ,p_pji_information16            in     varchar2  default hr_api.g_varchar2
  ,p_pji_information17            in     varchar2  default hr_api.g_varchar2
  ,p_pji_information18            in     varchar2  default hr_api.g_varchar2
  ,p_pji_information19            in     varchar2  default hr_api.g_varchar2
  ,p_pji_information20            in     varchar2  default hr_api.g_varchar2
  ,p_pji_information21            in     varchar2  default hr_api.g_varchar2
  ,p_pji_information22            in     varchar2  default hr_api.g_varchar2
  ,p_pji_information23            in     varchar2  default hr_api.g_varchar2
  ,p_pji_information24            in     varchar2  default hr_api.g_varchar2
  ,p_pji_information25            in     varchar2  default hr_api.g_varchar2
  ,p_pji_information26            in     varchar2  default hr_api.g_varchar2
  ,p_pji_information27            in     varchar2  default hr_api.g_varchar2
  ,p_pji_information28            in     varchar2  default hr_api.g_varchar2
  ,p_pji_information29            in     varchar2  default hr_api.g_varchar2
  ,p_pji_information30            in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   per_pji_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_pji_shd.convert_args
  (p_previous_job_extra_info_id
  ,p_previous_job_id
  ,p_information_type
  ,p_pji_attribute_category
  ,p_pji_attribute1
  ,p_pji_attribute2
  ,p_pji_attribute3
  ,p_pji_attribute4
  ,p_pji_attribute5
  ,p_pji_attribute6
  ,p_pji_attribute7
  ,p_pji_attribute8
  ,p_pji_attribute9
  ,p_pji_attribute10
  ,p_pji_attribute11
  ,p_pji_attribute12
  ,p_pji_attribute13
  ,p_pji_attribute14
  ,p_pji_attribute15
  ,p_pji_attribute16
  ,p_pji_attribute17
  ,p_pji_attribute18
  ,p_pji_attribute19
  ,p_pji_attribute20
  ,p_pji_attribute21
  ,p_pji_attribute22
  ,p_pji_attribute23
  ,p_pji_attribute24
  ,p_pji_attribute25
  ,p_pji_attribute26
  ,p_pji_attribute27
  ,p_pji_attribute28
  ,p_pji_attribute29
  ,p_pji_attribute30
  ,p_pji_information_category
  ,p_pji_information1
  ,p_pji_information2
  ,p_pji_information3
  ,p_pji_information4
  ,p_pji_information5
  ,p_pji_information6
  ,p_pji_information7
  ,p_pji_information8
  ,p_pji_information9
  ,p_pji_information10
  ,p_pji_information11
  ,p_pji_information12
  ,p_pji_information13
  ,p_pji_information14
  ,p_pji_information15
  ,p_pji_information16
  ,p_pji_information17
  ,p_pji_information18
  ,p_pji_information19
  ,p_pji_information20
  ,p_pji_information21
  ,p_pji_information22
  ,p_pji_information23
  ,p_pji_information24
  ,p_pji_information25
  ,p_pji_information26
  ,p_pji_information27
  ,p_pji_information28
  ,p_pji_information29
  ,p_pji_information30
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_pji_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_pji_upd;

/

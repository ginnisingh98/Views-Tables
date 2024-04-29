--------------------------------------------------------
--  DDL for Package Body PER_PJU_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PJU_UPD" as
/* $Header: pepjurhi.pkb 115.14 2002/12/04 10:55:38 eumenyio ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pju_upd.';  -- Global package name
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
  (p_rec in out nocopy per_pju_shd.g_rec_type
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
  --
  --
  -- Update the per_previous_job_usages Row
  --
  update per_previous_job_usages
    set
     previous_job_usage_id           = p_rec.previous_job_usage_id
    ,assignment_id                   = p_rec.assignment_id
    ,previous_employer_id            = p_rec.previous_employer_id
    ,previous_job_id                 = p_rec.previous_job_id
    ,start_date                      = p_rec.start_date
    ,end_date                        = p_rec.end_date
    ,period_years                    = p_rec.period_years
    ,period_months                   = p_rec.period_months
    ,period_days                     = p_rec.period_days
    ,pju_attribute_category          = p_rec.pju_attribute_category
    ,pju_attribute1                  = p_rec.pju_attribute1
    ,pju_attribute2                  = p_rec.pju_attribute2
    ,pju_attribute3                  = p_rec.pju_attribute3
    ,pju_attribute4                  = p_rec.pju_attribute4
    ,pju_attribute5                  = p_rec.pju_attribute5
    ,pju_attribute6                  = p_rec.pju_attribute6
    ,pju_attribute7                  = p_rec.pju_attribute7
    ,pju_attribute8                  = p_rec.pju_attribute8
    ,pju_attribute9                  = p_rec.pju_attribute9
    ,pju_attribute10                 = p_rec.pju_attribute10
    ,pju_attribute11                 = p_rec.pju_attribute11
    ,pju_attribute12                 = p_rec.pju_attribute12
    ,pju_attribute13                 = p_rec.pju_attribute13
    ,pju_attribute14                 = p_rec.pju_attribute14
    ,pju_attribute15                 = p_rec.pju_attribute15
    ,pju_attribute16                 = p_rec.pju_attribute16
    ,pju_attribute17                 = p_rec.pju_attribute17
    ,pju_attribute18                 = p_rec.pju_attribute18
    ,pju_attribute19                 = p_rec.pju_attribute19
    ,pju_attribute20                 = p_rec.pju_attribute20
    ,pju_information_category        = p_rec.pju_information_category
    ,pju_information1                = p_rec.pju_information1
    ,pju_information2                = p_rec.pju_information2
    ,pju_information3                = p_rec.pju_information3
    ,pju_information4                = p_rec.pju_information4
    ,pju_information5                = p_rec.pju_information5
    ,pju_information6                = p_rec.pju_information6
    ,pju_information7                = p_rec.pju_information7
    ,pju_information8                = p_rec.pju_information8
    ,pju_information9                = p_rec.pju_information9
    ,pju_information10               = p_rec.pju_information10
    ,pju_information11               = p_rec.pju_information11
    ,pju_information12               = p_rec.pju_information12
    ,pju_information13               = p_rec.pju_information13
    ,pju_information14               = p_rec.pju_information14
    ,pju_information15               = p_rec.pju_information15
    ,pju_information16               = p_rec.pju_information16
    ,pju_information17               = p_rec.pju_information17
    ,pju_information18               = p_rec.pju_information18
    ,pju_information19               = p_rec.pju_information19
    ,pju_information20               = p_rec.pju_information20
    ,object_version_number           = p_rec.object_version_number
    where previous_job_usage_id = p_rec.previous_job_usage_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_pju_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_pju_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_pju_shd.constraint_error
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
  (p_rec in per_pju_shd.g_rec_type
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
  (p_rec                          in per_pju_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_pju_rku.after_update
      (p_previous_job_usage_id
      => p_rec.previous_job_usage_id
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_previous_employer_id
      => p_rec.previous_employer_id
      ,p_previous_job_id
      => p_rec.previous_job_id
      ,p_start_date
      => p_rec.start_date
      ,p_end_date
      => p_rec.end_date
      ,p_period_years
      => p_rec.period_years
      ,p_period_months
      => p_rec.period_months
      ,p_period_days
      => p_rec.period_days
      ,p_pju_attribute_category
      => p_rec.pju_attribute_category
      ,p_pju_attribute1
      => p_rec.pju_attribute1
      ,p_pju_attribute2
      => p_rec.pju_attribute2
      ,p_pju_attribute3
      => p_rec.pju_attribute3
      ,p_pju_attribute4
      => p_rec.pju_attribute4
      ,p_pju_attribute5
      => p_rec.pju_attribute5
      ,p_pju_attribute6
      => p_rec.pju_attribute6
      ,p_pju_attribute7
      => p_rec.pju_attribute7
      ,p_pju_attribute8
      => p_rec.pju_attribute8
      ,p_pju_attribute9
      => p_rec.pju_attribute9
      ,p_pju_attribute10
      => p_rec.pju_attribute10
      ,p_pju_attribute11
      => p_rec.pju_attribute11
      ,p_pju_attribute12
      => p_rec.pju_attribute12
      ,p_pju_attribute13
      => p_rec.pju_attribute13
      ,p_pju_attribute14
      => p_rec.pju_attribute14
      ,p_pju_attribute15
      => p_rec.pju_attribute15
      ,p_pju_attribute16
      => p_rec.pju_attribute16
      ,p_pju_attribute17
      => p_rec.pju_attribute17
      ,p_pju_attribute18
      => p_rec.pju_attribute18
      ,p_pju_attribute19
      => p_rec.pju_attribute19
      ,p_pju_attribute20
      => p_rec.pju_attribute20
      ,p_pju_information_category
      => p_rec.pju_information_category
      ,p_pju_information1
      => p_rec.pju_information1
      ,p_pju_information2
      => p_rec.pju_information2
      ,p_pju_information3
      => p_rec.pju_information3
      ,p_pju_information4
      => p_rec.pju_information4
      ,p_pju_information5
      => p_rec.pju_information5
      ,p_pju_information6
      => p_rec.pju_information6
      ,p_pju_information7
      => p_rec.pju_information7
      ,p_pju_information8
      => p_rec.pju_information8
      ,p_pju_information9
      => p_rec.pju_information9
      ,p_pju_information10
      => p_rec.pju_information10
      ,p_pju_information11
      => p_rec.pju_information11
      ,p_pju_information12
      => p_rec.pju_information12
      ,p_pju_information13
      => p_rec.pju_information13
      ,p_pju_information14
      => p_rec.pju_information14
      ,p_pju_information15
      => p_rec.pju_information15
      ,p_pju_information16
      => p_rec.pju_information16
      ,p_pju_information17
      => p_rec.pju_information17
      ,p_pju_information18
      => p_rec.pju_information18
      ,p_pju_information19
      => p_rec.pju_information19
      ,p_pju_information20
      => p_rec.pju_information20
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_PREVIOUS_JOB_USAGES'
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
  (p_rec in out nocopy per_pju_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    per_pju_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.previous_employer_id = hr_api.g_number) then
    p_rec.previous_employer_id :=
    per_pju_shd.g_old_rec.previous_employer_id;
  End If;
  If (p_rec.previous_job_id = hr_api.g_number) then
    p_rec.previous_job_id :=
    per_pju_shd.g_old_rec.previous_job_id;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    per_pju_shd.g_old_rec.start_date;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    per_pju_shd.g_old_rec.end_date;
  End If;
  If (p_rec.period_years = hr_api.g_number) then
    p_rec.period_years :=
    per_pju_shd.g_old_rec.period_years;
  End If;
  If (p_rec.period_months = hr_api.g_number) then
    p_rec.period_months :=
    per_pju_shd.g_old_rec.period_months;
  End If;
  If (p_rec.period_days = hr_api.g_number) then
    p_rec.period_days :=
    per_pju_shd.g_old_rec.period_days;
  End If;
  If (p_rec.pju_attribute_category = hr_api.g_varchar2) then
    p_rec.pju_attribute_category :=
    per_pju_shd.g_old_rec.pju_attribute_category;
  End If;
  If (p_rec.pju_attribute1 = hr_api.g_varchar2) then
    p_rec.pju_attribute1 :=
    per_pju_shd.g_old_rec.pju_attribute1;
  End If;
  If (p_rec.pju_attribute2 = hr_api.g_varchar2) then
    p_rec.pju_attribute2 :=
    per_pju_shd.g_old_rec.pju_attribute2;
  End If;
  If (p_rec.pju_attribute3 = hr_api.g_varchar2) then
    p_rec.pju_attribute3 :=
    per_pju_shd.g_old_rec.pju_attribute3;
  End If;
  If (p_rec.pju_attribute4 = hr_api.g_varchar2) then
    p_rec.pju_attribute4 :=
    per_pju_shd.g_old_rec.pju_attribute4;
  End If;
  If (p_rec.pju_attribute5 = hr_api.g_varchar2) then
    p_rec.pju_attribute5 :=
    per_pju_shd.g_old_rec.pju_attribute5;
  End If;
  If (p_rec.pju_attribute6 = hr_api.g_varchar2) then
    p_rec.pju_attribute6 :=
    per_pju_shd.g_old_rec.pju_attribute6;
  End If;
  If (p_rec.pju_attribute7 = hr_api.g_varchar2) then
    p_rec.pju_attribute7 :=
    per_pju_shd.g_old_rec.pju_attribute7;
  End If;
  If (p_rec.pju_attribute8 = hr_api.g_varchar2) then
    p_rec.pju_attribute8 :=
    per_pju_shd.g_old_rec.pju_attribute8;
  End If;
  If (p_rec.pju_attribute9 = hr_api.g_varchar2) then
    p_rec.pju_attribute9 :=
    per_pju_shd.g_old_rec.pju_attribute9;
  End If;
  If (p_rec.pju_attribute10 = hr_api.g_varchar2) then
    p_rec.pju_attribute10 :=
    per_pju_shd.g_old_rec.pju_attribute10;
  End If;
  If (p_rec.pju_attribute11 = hr_api.g_varchar2) then
    p_rec.pju_attribute11 :=
    per_pju_shd.g_old_rec.pju_attribute11;
  End If;
  If (p_rec.pju_attribute12 = hr_api.g_varchar2) then
    p_rec.pju_attribute12 :=
    per_pju_shd.g_old_rec.pju_attribute12;
  End If;
  If (p_rec.pju_attribute13 = hr_api.g_varchar2) then
    p_rec.pju_attribute13 :=
    per_pju_shd.g_old_rec.pju_attribute13;
  End If;
  If (p_rec.pju_attribute14 = hr_api.g_varchar2) then
    p_rec.pju_attribute14 :=
    per_pju_shd.g_old_rec.pju_attribute14;
  End If;
  If (p_rec.pju_attribute15 = hr_api.g_varchar2) then
    p_rec.pju_attribute15 :=
    per_pju_shd.g_old_rec.pju_attribute15;
  End If;
  If (p_rec.pju_attribute16 = hr_api.g_varchar2) then
    p_rec.pju_attribute16 :=
    per_pju_shd.g_old_rec.pju_attribute16;
  End If;
  If (p_rec.pju_attribute17 = hr_api.g_varchar2) then
    p_rec.pju_attribute17 :=
    per_pju_shd.g_old_rec.pju_attribute17;
  End If;
  If (p_rec.pju_attribute18 = hr_api.g_varchar2) then
    p_rec.pju_attribute18 :=
    per_pju_shd.g_old_rec.pju_attribute18;
  End If;
  If (p_rec.pju_attribute19 = hr_api.g_varchar2) then
    p_rec.pju_attribute19 :=
    per_pju_shd.g_old_rec.pju_attribute19;
  End If;
  If (p_rec.pju_attribute20 = hr_api.g_varchar2) then
    p_rec.pju_attribute20 :=
    per_pju_shd.g_old_rec.pju_attribute20;
  End If;
  If (p_rec.pju_information_category = hr_api.g_varchar2) then
    p_rec.pju_information_category :=
    per_pju_shd.g_old_rec.pju_information_category;
  End If;
  If (p_rec.pju_information1 = hr_api.g_varchar2) then
    p_rec.pju_information1 :=
    per_pju_shd.g_old_rec.pju_information1;
  End If;
  If (p_rec.pju_information2 = hr_api.g_varchar2) then
    p_rec.pju_information2 :=
    per_pju_shd.g_old_rec.pju_information2;
  End If;
  If (p_rec.pju_information3 = hr_api.g_varchar2) then
    p_rec.pju_information3 :=
    per_pju_shd.g_old_rec.pju_information3;
  End If;
  If (p_rec.pju_information4 = hr_api.g_varchar2) then
    p_rec.pju_information4 :=
    per_pju_shd.g_old_rec.pju_information4;
  End If;
  If (p_rec.pju_information5 = hr_api.g_varchar2) then
    p_rec.pju_information5 :=
    per_pju_shd.g_old_rec.pju_information5;
  End If;
  If (p_rec.pju_information6 = hr_api.g_varchar2) then
    p_rec.pju_information6 :=
    per_pju_shd.g_old_rec.pju_information6;
  End If;
  If (p_rec.pju_information7 = hr_api.g_varchar2) then
    p_rec.pju_information7 :=
    per_pju_shd.g_old_rec.pju_information7;
  End If;
  If (p_rec.pju_information8 = hr_api.g_varchar2) then
    p_rec.pju_information8 :=
    per_pju_shd.g_old_rec.pju_information8;
  End If;
  If (p_rec.pju_information9 = hr_api.g_varchar2) then
    p_rec.pju_information9 :=
    per_pju_shd.g_old_rec.pju_information9;
  End If;
  If (p_rec.pju_information10 = hr_api.g_varchar2) then
    p_rec.pju_information10 :=
    per_pju_shd.g_old_rec.pju_information10;
  End If;
  If (p_rec.pju_information11 = hr_api.g_varchar2) then
    p_rec.pju_information11 :=
    per_pju_shd.g_old_rec.pju_information11;
  End If;
  If (p_rec.pju_information12 = hr_api.g_varchar2) then
    p_rec.pju_information12 :=
    per_pju_shd.g_old_rec.pju_information12;
  End If;
  If (p_rec.pju_information13 = hr_api.g_varchar2) then
    p_rec.pju_information13 :=
    per_pju_shd.g_old_rec.pju_information13;
  End If;
  If (p_rec.pju_information14 = hr_api.g_varchar2) then
    p_rec.pju_information14 :=
    per_pju_shd.g_old_rec.pju_information14;
  End If;
  If (p_rec.pju_information15 = hr_api.g_varchar2) then
    p_rec.pju_information15 :=
    per_pju_shd.g_old_rec.pju_information15;
  End If;
  If (p_rec.pju_information16 = hr_api.g_varchar2) then
    p_rec.pju_information16 :=
    per_pju_shd.g_old_rec.pju_information16;
  End If;
  If (p_rec.pju_information17 = hr_api.g_varchar2) then
    p_rec.pju_information17 :=
    per_pju_shd.g_old_rec.pju_information17;
  End If;
  If (p_rec.pju_information18 = hr_api.g_varchar2) then
    p_rec.pju_information18 :=
    per_pju_shd.g_old_rec.pju_information18;
  End If;
  If (p_rec.pju_information19 = hr_api.g_varchar2) then
    p_rec.pju_information19 :=
    per_pju_shd.g_old_rec.pju_information19;
  End If;
  If (p_rec.pju_information20 = hr_api.g_varchar2) then
    p_rec.pju_information20 :=
    per_pju_shd.g_old_rec.pju_information20;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy per_pju_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_pju_shd.lck
    (p_rec.previous_job_usage_id
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
  per_pju_bus.update_validate
     (p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  per_pju_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  per_pju_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  per_pju_upd.post_update
     (p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_previous_job_usage_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_previous_employer_id         in     number    default hr_api.g_number
  ,p_previous_job_id              in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_period_years                 in     number    default hr_api.g_number
  ,p_period_months                in     number    default hr_api.g_number
  ,p_period_days                  in     number    default hr_api.g_number
  ,p_pju_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pju_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pju_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pju_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pju_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pju_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pju_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pju_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pju_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pju_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pju_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pju_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pju_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pju_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pju_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pju_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pju_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pju_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pju_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pju_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pju_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pju_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_pju_information1             in     varchar2  default hr_api.g_varchar2
  ,p_pju_information2             in     varchar2  default hr_api.g_varchar2
  ,p_pju_information3             in     varchar2  default hr_api.g_varchar2
  ,p_pju_information4             in     varchar2  default hr_api.g_varchar2
  ,p_pju_information5             in     varchar2  default hr_api.g_varchar2
  ,p_pju_information6             in     varchar2  default hr_api.g_varchar2
  ,p_pju_information7             in     varchar2  default hr_api.g_varchar2
  ,p_pju_information8             in     varchar2  default hr_api.g_varchar2
  ,p_pju_information9             in     varchar2  default hr_api.g_varchar2
  ,p_pju_information10            in     varchar2  default hr_api.g_varchar2
  ,p_pju_information11            in     varchar2  default hr_api.g_varchar2
  ,p_pju_information12            in     varchar2  default hr_api.g_varchar2
  ,p_pju_information13            in     varchar2  default hr_api.g_varchar2
  ,p_pju_information14            in     varchar2  default hr_api.g_varchar2
  ,p_pju_information15            in     varchar2  default hr_api.g_varchar2
  ,p_pju_information16            in     varchar2  default hr_api.g_varchar2
  ,p_pju_information17            in     varchar2  default hr_api.g_varchar2
  ,p_pju_information18            in     varchar2  default hr_api.g_varchar2
  ,p_pju_information19            in     varchar2  default hr_api.g_varchar2
  ,p_pju_information20            in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   per_pju_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_pju_shd.convert_args
  (p_previous_job_usage_id
  ,p_assignment_id
  ,p_previous_employer_id
  ,p_previous_job_id
  ,p_start_date
  ,p_end_date
  ,p_period_years
  ,p_period_months
  ,p_period_days
  ,p_pju_attribute_category
  ,p_pju_attribute1
  ,p_pju_attribute2
  ,p_pju_attribute3
  ,p_pju_attribute4
  ,p_pju_attribute5
  ,p_pju_attribute6
  ,p_pju_attribute7
  ,p_pju_attribute8
  ,p_pju_attribute9
  ,p_pju_attribute10
  ,p_pju_attribute11
  ,p_pju_attribute12
  ,p_pju_attribute13
  ,p_pju_attribute14
  ,p_pju_attribute15
  ,p_pju_attribute16
  ,p_pju_attribute17
  ,p_pju_attribute18
  ,p_pju_attribute19
  ,p_pju_attribute20
  ,p_pju_information_category
  ,p_pju_information1
  ,p_pju_information2
  ,p_pju_information3
  ,p_pju_information4
  ,p_pju_information5
  ,p_pju_information6
  ,p_pju_information7
  ,p_pju_information8
  ,p_pju_information9
  ,p_pju_information10
  ,p_pju_information11
  ,p_pju_information12
  ,p_pju_information13
  ,p_pju_information14
  ,p_pju_information15
  ,p_pju_information16
  ,p_pju_information17
  ,p_pju_information18
  ,p_pju_information19
  ,p_pju_information20
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_pju_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_pju_upd;

/

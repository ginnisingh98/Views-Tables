--------------------------------------------------------
--  DDL for Package Body PER_PJO_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PJO_UPD" as
/* $Header: pepjorhi.pkb 120.0.12010000.2 2008/08/06 09:28:19 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pjo_upd.';  -- Global package name
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
  (p_rec in out nocopy per_pjo_shd.g_rec_type
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
  -- Update the per_previous_jobs Row
  --
  update per_previous_jobs
    set
     previous_job_id                 = p_rec.previous_job_id
    ,previous_employer_id            = p_rec.previous_employer_id
    ,start_date                      = p_rec.start_date
    ,end_date                        = p_rec.end_date
    ,period_years                    = p_rec.period_years
    ,period_days                     = p_rec.period_days
    ,job_name                        = p_rec.job_name
    ,employment_category             = p_rec.employment_category
    ,description                     = p_rec.description
    ,pjo_attribute_category          = p_rec.pjo_attribute_category
    ,pjo_attribute1                  = p_rec.pjo_attribute1
    ,pjo_attribute2                  = p_rec.pjo_attribute2
    ,pjo_attribute3                  = p_rec.pjo_attribute3
    ,pjo_attribute4                  = p_rec.pjo_attribute4
    ,pjo_attribute5                  = p_rec.pjo_attribute5
    ,pjo_attribute6                  = p_rec.pjo_attribute6
    ,pjo_attribute7                  = p_rec.pjo_attribute7
    ,pjo_attribute8                  = p_rec.pjo_attribute8
    ,pjo_attribute9                  = p_rec.pjo_attribute9
    ,pjo_attribute10                 = p_rec.pjo_attribute10
    ,pjo_attribute11                 = p_rec.pjo_attribute11
    ,pjo_attribute12                 = p_rec.pjo_attribute12
    ,pjo_attribute13                 = p_rec.pjo_attribute13
    ,pjo_attribute14                 = p_rec.pjo_attribute14
    ,pjo_attribute15                 = p_rec.pjo_attribute15
    ,pjo_attribute16                 = p_rec.pjo_attribute16
    ,pjo_attribute17                 = p_rec.pjo_attribute17
    ,pjo_attribute18                 = p_rec.pjo_attribute18
    ,pjo_attribute19                 = p_rec.pjo_attribute19
    ,pjo_attribute20                 = p_rec.pjo_attribute20
    ,pjo_attribute21                 = p_rec.pjo_attribute21
    ,pjo_attribute22                 = p_rec.pjo_attribute22
    ,pjo_attribute23                 = p_rec.pjo_attribute23
    ,pjo_attribute24                 = p_rec.pjo_attribute24
    ,pjo_attribute25                 = p_rec.pjo_attribute25
    ,pjo_attribute26                 = p_rec.pjo_attribute26
    ,pjo_attribute27                 = p_rec.pjo_attribute27
    ,pjo_attribute28                 = p_rec.pjo_attribute28
    ,pjo_attribute29                 = p_rec.pjo_attribute29
    ,pjo_attribute30                 = p_rec.pjo_attribute30
    ,pjo_information_category        = p_rec.pjo_information_category
    ,pjo_information1                = p_rec.pjo_information1
    ,pjo_information2                = p_rec.pjo_information2
    ,pjo_information3                = p_rec.pjo_information3
    ,pjo_information4                = p_rec.pjo_information4
    ,pjo_information5                = p_rec.pjo_information5
    ,pjo_information6                = p_rec.pjo_information6
    ,pjo_information7                = p_rec.pjo_information7
    ,pjo_information8                = p_rec.pjo_information8
    ,pjo_information9                = p_rec.pjo_information9
    ,pjo_information10               = p_rec.pjo_information10
    ,pjo_information11               = p_rec.pjo_information11
    ,pjo_information12               = p_rec.pjo_information12
    ,pjo_information13               = p_rec.pjo_information13
    ,pjo_information14               = p_rec.pjo_information14
    ,pjo_information15               = p_rec.pjo_information15
    ,pjo_information16               = p_rec.pjo_information16
    ,pjo_information17               = p_rec.pjo_information17
    ,pjo_information18               = p_rec.pjo_information18
    ,pjo_information19               = p_rec.pjo_information19
    ,pjo_information20               = p_rec.pjo_information20
    ,pjo_information21               = p_rec.pjo_information21
    ,pjo_information22               = p_rec.pjo_information22
    ,pjo_information23               = p_rec.pjo_information23
    ,pjo_information24               = p_rec.pjo_information24
    ,pjo_information25               = p_rec.pjo_information25
    ,pjo_information26               = p_rec.pjo_information26
    ,pjo_information27               = p_rec.pjo_information27
    ,pjo_information28               = p_rec.pjo_information28
    ,pjo_information29               = p_rec.pjo_information29
    ,pjo_information30               = p_rec.pjo_information30
    ,object_version_number           = p_rec.object_version_number
    ,all_assignments                 = p_rec.all_assignments
    ,period_months                   = p_rec.period_months
    where previous_job_id = p_rec.previous_job_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_pjo_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_pjo_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_pjo_shd.constraint_error
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
  (p_rec in per_pjo_shd.g_rec_type
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
  (p_effective_date               in date
  ,p_rec                          in per_pjo_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_pjo_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_previous_job_id
      => p_rec.previous_job_id
      ,p_previous_employer_id
      => p_rec.previous_employer_id
      ,p_start_date
      => p_rec.start_date
      ,p_end_date
      => p_rec.end_date
      ,p_period_years
      => p_rec.period_years
      ,p_period_days
      => p_rec.period_days
      ,p_job_name
      => p_rec.job_name
      ,p_employment_category
      => p_rec.employment_category
      ,p_description
      => p_rec.description
      ,p_pjo_attribute_category
      => p_rec.pjo_attribute_category
      ,p_pjo_attribute1
      => p_rec.pjo_attribute1
      ,p_pjo_attribute2
      => p_rec.pjo_attribute2
      ,p_pjo_attribute3
      => p_rec.pjo_attribute3
      ,p_pjo_attribute4
      => p_rec.pjo_attribute4
      ,p_pjo_attribute5
      => p_rec.pjo_attribute5
      ,p_pjo_attribute6
      => p_rec.pjo_attribute6
      ,p_pjo_attribute7
      => p_rec.pjo_attribute7
      ,p_pjo_attribute8
      => p_rec.pjo_attribute8
      ,p_pjo_attribute9
      => p_rec.pjo_attribute9
      ,p_pjo_attribute10
      => p_rec.pjo_attribute10
      ,p_pjo_attribute11
      => p_rec.pjo_attribute11
      ,p_pjo_attribute12
      => p_rec.pjo_attribute12
      ,p_pjo_attribute13
      => p_rec.pjo_attribute13
      ,p_pjo_attribute14
      => p_rec.pjo_attribute14
      ,p_pjo_attribute15
      => p_rec.pjo_attribute15
      ,p_pjo_attribute16
      => p_rec.pjo_attribute16
      ,p_pjo_attribute17
      => p_rec.pjo_attribute17
      ,p_pjo_attribute18
      => p_rec.pjo_attribute18
      ,p_pjo_attribute19
      => p_rec.pjo_attribute19
      ,p_pjo_attribute20
      => p_rec.pjo_attribute20
      ,p_pjo_attribute21
      => p_rec.pjo_attribute21
      ,p_pjo_attribute22
      => p_rec.pjo_attribute22
      ,p_pjo_attribute23
      => p_rec.pjo_attribute23
      ,p_pjo_attribute24
      => p_rec.pjo_attribute24
      ,p_pjo_attribute25
      => p_rec.pjo_attribute25
      ,p_pjo_attribute26
      => p_rec.pjo_attribute26
      ,p_pjo_attribute27
      => p_rec.pjo_attribute27
      ,p_pjo_attribute28
      => p_rec.pjo_attribute28
      ,p_pjo_attribute29
      => p_rec.pjo_attribute29
      ,p_pjo_attribute30
      => p_rec.pjo_attribute30
      ,p_pjo_information_category
      => p_rec.pjo_information_category
      ,p_pjo_information1
      => p_rec.pjo_information1
      ,p_pjo_information2
      => p_rec.pjo_information2
      ,p_pjo_information3
      => p_rec.pjo_information3
      ,p_pjo_information4
      => p_rec.pjo_information4
      ,p_pjo_information5
      => p_rec.pjo_information5
      ,p_pjo_information6
      => p_rec.pjo_information6
      ,p_pjo_information7
      => p_rec.pjo_information7
      ,p_pjo_information8
      => p_rec.pjo_information8
      ,p_pjo_information9
      => p_rec.pjo_information9
      ,p_pjo_information10
      => p_rec.pjo_information10
      ,p_pjo_information11
      => p_rec.pjo_information11
      ,p_pjo_information12
      => p_rec.pjo_information12
      ,p_pjo_information13
      => p_rec.pjo_information13
      ,p_pjo_information14
      => p_rec.pjo_information14
      ,p_pjo_information15
      => p_rec.pjo_information15
      ,p_pjo_information16
      => p_rec.pjo_information16
      ,p_pjo_information17
      => p_rec.pjo_information17
      ,p_pjo_information18
      => p_rec.pjo_information18
      ,p_pjo_information19
      => p_rec.pjo_information19
      ,p_pjo_information20
      => p_rec.pjo_information20
      ,p_pjo_information21
      => p_rec.pjo_information21
      ,p_pjo_information22
      => p_rec.pjo_information22
      ,p_pjo_information23
      => p_rec.pjo_information23
      ,p_pjo_information24
      => p_rec.pjo_information24
      ,p_pjo_information25
      => p_rec.pjo_information25
      ,p_pjo_information26
      => p_rec.pjo_information26
      ,p_pjo_information27
      => p_rec.pjo_information27
      ,p_pjo_information28
      => p_rec.pjo_information28
      ,p_pjo_information29
      => p_rec.pjo_information29
      ,p_pjo_information30
      => p_rec.pjo_information30
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_all_assignments
      => p_rec.all_assignments
      ,p_period_months
      => p_rec.period_months
      ,p_previous_employer_id_o
      => per_pjo_shd.g_old_rec.previous_employer_id
      ,p_start_date_o
      => per_pjo_shd.g_old_rec.start_date
      ,p_end_date_o
      => per_pjo_shd.g_old_rec.end_date
      ,p_period_years_o
      => per_pjo_shd.g_old_rec.period_years
      ,p_period_days_o
      => per_pjo_shd.g_old_rec.period_days
      ,p_job_name_o
      => per_pjo_shd.g_old_rec.job_name
      ,p_employment_category_o
      => per_pjo_shd.g_old_rec.employment_category
      ,p_description_o
      => per_pjo_shd.g_old_rec.description
      ,p_pjo_attribute_category_o
      => per_pjo_shd.g_old_rec.pjo_attribute_category
      ,p_pjo_attribute1_o
      => per_pjo_shd.g_old_rec.pjo_attribute1
      ,p_pjo_attribute2_o
      => per_pjo_shd.g_old_rec.pjo_attribute2
      ,p_pjo_attribute3_o
      => per_pjo_shd.g_old_rec.pjo_attribute3
      ,p_pjo_attribute4_o
      => per_pjo_shd.g_old_rec.pjo_attribute4
      ,p_pjo_attribute5_o
      => per_pjo_shd.g_old_rec.pjo_attribute5
      ,p_pjo_attribute6_o
      => per_pjo_shd.g_old_rec.pjo_attribute6
      ,p_pjo_attribute7_o
      => per_pjo_shd.g_old_rec.pjo_attribute7
      ,p_pjo_attribute8_o
      => per_pjo_shd.g_old_rec.pjo_attribute8
      ,p_pjo_attribute9_o
      => per_pjo_shd.g_old_rec.pjo_attribute9
      ,p_pjo_attribute10_o
      => per_pjo_shd.g_old_rec.pjo_attribute10
      ,p_pjo_attribute11_o
      => per_pjo_shd.g_old_rec.pjo_attribute11
      ,p_pjo_attribute12_o
      => per_pjo_shd.g_old_rec.pjo_attribute12
      ,p_pjo_attribute13_o
      => per_pjo_shd.g_old_rec.pjo_attribute13
      ,p_pjo_attribute14_o
      => per_pjo_shd.g_old_rec.pjo_attribute14
      ,p_pjo_attribute15_o
      => per_pjo_shd.g_old_rec.pjo_attribute15
      ,p_pjo_attribute16_o
      => per_pjo_shd.g_old_rec.pjo_attribute16
      ,p_pjo_attribute17_o
      => per_pjo_shd.g_old_rec.pjo_attribute17
      ,p_pjo_attribute18_o
      => per_pjo_shd.g_old_rec.pjo_attribute18
      ,p_pjo_attribute19_o
      => per_pjo_shd.g_old_rec.pjo_attribute19
      ,p_pjo_attribute20_o
      => per_pjo_shd.g_old_rec.pjo_attribute20
      ,p_pjo_attribute21_o
      => per_pjo_shd.g_old_rec.pjo_attribute21
      ,p_pjo_attribute22_o
      => per_pjo_shd.g_old_rec.pjo_attribute22
      ,p_pjo_attribute23_o
      => per_pjo_shd.g_old_rec.pjo_attribute23
      ,p_pjo_attribute24_o
      => per_pjo_shd.g_old_rec.pjo_attribute24
      ,p_pjo_attribute25_o
      => per_pjo_shd.g_old_rec.pjo_attribute25
      ,p_pjo_attribute26_o
      => per_pjo_shd.g_old_rec.pjo_attribute26
      ,p_pjo_attribute27_o
      => per_pjo_shd.g_old_rec.pjo_attribute27
      ,p_pjo_attribute28_o
      => per_pjo_shd.g_old_rec.pjo_attribute28
      ,p_pjo_attribute29_o
      => per_pjo_shd.g_old_rec.pjo_attribute29
      ,p_pjo_attribute30_o
      => per_pjo_shd.g_old_rec.pjo_attribute30
      ,p_pjo_information_category_o
      => per_pjo_shd.g_old_rec.pjo_information_category
      ,p_pjo_information1_o
      => per_pjo_shd.g_old_rec.pjo_information1
      ,p_pjo_information2_o
      => per_pjo_shd.g_old_rec.pjo_information2
      ,p_pjo_information3_o
      => per_pjo_shd.g_old_rec.pjo_information3
      ,p_pjo_information4_o
      => per_pjo_shd.g_old_rec.pjo_information4
      ,p_pjo_information5_o
      => per_pjo_shd.g_old_rec.pjo_information5
      ,p_pjo_information6_o
      => per_pjo_shd.g_old_rec.pjo_information6
      ,p_pjo_information7_o
      => per_pjo_shd.g_old_rec.pjo_information7
      ,p_pjo_information8_o
      => per_pjo_shd.g_old_rec.pjo_information8
      ,p_pjo_information9_o
      => per_pjo_shd.g_old_rec.pjo_information9
      ,p_pjo_information10_o
      => per_pjo_shd.g_old_rec.pjo_information10
      ,p_pjo_information11_o
      => per_pjo_shd.g_old_rec.pjo_information11
      ,p_pjo_information12_o
      => per_pjo_shd.g_old_rec.pjo_information12
      ,p_pjo_information13_o
      => per_pjo_shd.g_old_rec.pjo_information13
      ,p_pjo_information14_o
      => per_pjo_shd.g_old_rec.pjo_information14
      ,p_pjo_information15_o
      => per_pjo_shd.g_old_rec.pjo_information15
      ,p_pjo_information16_o
      => per_pjo_shd.g_old_rec.pjo_information16
      ,p_pjo_information17_o
      => per_pjo_shd.g_old_rec.pjo_information17
      ,p_pjo_information18_o
      => per_pjo_shd.g_old_rec.pjo_information18
      ,p_pjo_information19_o
      => per_pjo_shd.g_old_rec.pjo_information19
      ,p_pjo_information20_o
      => per_pjo_shd.g_old_rec.pjo_information20
      ,p_pjo_information21_o
      => per_pjo_shd.g_old_rec.pjo_information21
      ,p_pjo_information22_o
      => per_pjo_shd.g_old_rec.pjo_information22
      ,p_pjo_information23_o
      => per_pjo_shd.g_old_rec.pjo_information23
      ,p_pjo_information24_o
      => per_pjo_shd.g_old_rec.pjo_information24
      ,p_pjo_information25_o
      => per_pjo_shd.g_old_rec.pjo_information25
      ,p_pjo_information26_o
      => per_pjo_shd.g_old_rec.pjo_information26
      ,p_pjo_information27_o
      => per_pjo_shd.g_old_rec.pjo_information27
      ,p_pjo_information28_o
      => per_pjo_shd.g_old_rec.pjo_information28
      ,p_pjo_information29_o
      => per_pjo_shd.g_old_rec.pjo_information29
      ,p_pjo_information30_o
      => per_pjo_shd.g_old_rec.pjo_information30
      ,p_object_version_number_o
      => per_pjo_shd.g_old_rec.object_version_number
      ,p_all_assignments_o
      => per_pjo_shd.g_old_rec.all_assignments
      ,p_period_months_o
      => per_pjo_shd.g_old_rec.period_months
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_PREVIOUS_JOBS'
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
  (p_rec in out nocopy per_pjo_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.previous_employer_id = hr_api.g_number) then
    p_rec.previous_employer_id :=
    per_pjo_shd.g_old_rec.previous_employer_id;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    per_pjo_shd.g_old_rec.start_date;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    per_pjo_shd.g_old_rec.end_date;
  End If;
  If (p_rec.period_years = hr_api.g_number) then
    p_rec.period_years :=
    per_pjo_shd.g_old_rec.period_years;
  End If;
  If (p_rec.period_days = hr_api.g_number) then
    p_rec.period_days :=
    per_pjo_shd.g_old_rec.period_days;
  End If;
  If (p_rec.job_name = hr_api.g_varchar2) then
    p_rec.job_name :=
    per_pjo_shd.g_old_rec.job_name;
  End If;
  If (p_rec.employment_category = hr_api.g_varchar2) then
    p_rec.employment_category :=
    per_pjo_shd.g_old_rec.employment_category;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    per_pjo_shd.g_old_rec.description;
  End If;
  If (p_rec.pjo_attribute_category = hr_api.g_varchar2) then
    p_rec.pjo_attribute_category :=
    per_pjo_shd.g_old_rec.pjo_attribute_category;
  End If;
  If (p_rec.pjo_attribute1 = hr_api.g_varchar2) then
    p_rec.pjo_attribute1 :=
    per_pjo_shd.g_old_rec.pjo_attribute1;
  End If;
  If (p_rec.pjo_attribute2 = hr_api.g_varchar2) then
    p_rec.pjo_attribute2 :=
    per_pjo_shd.g_old_rec.pjo_attribute2;
  End If;
  If (p_rec.pjo_attribute3 = hr_api.g_varchar2) then
    p_rec.pjo_attribute3 :=
    per_pjo_shd.g_old_rec.pjo_attribute3;
  End If;
  If (p_rec.pjo_attribute4 = hr_api.g_varchar2) then
    p_rec.pjo_attribute4 :=
    per_pjo_shd.g_old_rec.pjo_attribute4;
  End If;
  If (p_rec.pjo_attribute5 = hr_api.g_varchar2) then
    p_rec.pjo_attribute5 :=
    per_pjo_shd.g_old_rec.pjo_attribute5;
  End If;
  If (p_rec.pjo_attribute6 = hr_api.g_varchar2) then
    p_rec.pjo_attribute6 :=
    per_pjo_shd.g_old_rec.pjo_attribute6;
  End If;
  If (p_rec.pjo_attribute7 = hr_api.g_varchar2) then
    p_rec.pjo_attribute7 :=
    per_pjo_shd.g_old_rec.pjo_attribute7;
  End If;
  If (p_rec.pjo_attribute8 = hr_api.g_varchar2) then
    p_rec.pjo_attribute8 :=
    per_pjo_shd.g_old_rec.pjo_attribute8;
  End If;
  If (p_rec.pjo_attribute9 = hr_api.g_varchar2) then
    p_rec.pjo_attribute9 :=
    per_pjo_shd.g_old_rec.pjo_attribute9;
  End If;
  If (p_rec.pjo_attribute10 = hr_api.g_varchar2) then
    p_rec.pjo_attribute10 :=
    per_pjo_shd.g_old_rec.pjo_attribute10;
  End If;
  If (p_rec.pjo_attribute11 = hr_api.g_varchar2) then
    p_rec.pjo_attribute11 :=
    per_pjo_shd.g_old_rec.pjo_attribute11;
  End If;
  If (p_rec.pjo_attribute12 = hr_api.g_varchar2) then
    p_rec.pjo_attribute12 :=
    per_pjo_shd.g_old_rec.pjo_attribute12;
  End If;
  If (p_rec.pjo_attribute13 = hr_api.g_varchar2) then
    p_rec.pjo_attribute13 :=
    per_pjo_shd.g_old_rec.pjo_attribute13;
  End If;
  If (p_rec.pjo_attribute14 = hr_api.g_varchar2) then
    p_rec.pjo_attribute14 :=
    per_pjo_shd.g_old_rec.pjo_attribute14;
  End If;
  If (p_rec.pjo_attribute15 = hr_api.g_varchar2) then
    p_rec.pjo_attribute15 :=
    per_pjo_shd.g_old_rec.pjo_attribute15;
  End If;
  If (p_rec.pjo_attribute16 = hr_api.g_varchar2) then
    p_rec.pjo_attribute16 :=
    per_pjo_shd.g_old_rec.pjo_attribute16;
  End If;
  If (p_rec.pjo_attribute17 = hr_api.g_varchar2) then
    p_rec.pjo_attribute17 :=
    per_pjo_shd.g_old_rec.pjo_attribute17;
  End If;
  If (p_rec.pjo_attribute18 = hr_api.g_varchar2) then
    p_rec.pjo_attribute18 :=
    per_pjo_shd.g_old_rec.pjo_attribute18;
  End If;
  If (p_rec.pjo_attribute19 = hr_api.g_varchar2) then
    p_rec.pjo_attribute19 :=
    per_pjo_shd.g_old_rec.pjo_attribute19;
  End If;
  If (p_rec.pjo_attribute20 = hr_api.g_varchar2) then
    p_rec.pjo_attribute20 :=
    per_pjo_shd.g_old_rec.pjo_attribute20;
  End If;
  If (p_rec.pjo_attribute21 = hr_api.g_varchar2) then
    p_rec.pjo_attribute21 :=
    per_pjo_shd.g_old_rec.pjo_attribute21;
  End If;
  If (p_rec.pjo_attribute22 = hr_api.g_varchar2) then
    p_rec.pjo_attribute22 :=
    per_pjo_shd.g_old_rec.pjo_attribute22;
  End If;
  If (p_rec.pjo_attribute23 = hr_api.g_varchar2) then
    p_rec.pjo_attribute23 :=
    per_pjo_shd.g_old_rec.pjo_attribute23;
  End If;
  If (p_rec.pjo_attribute24 = hr_api.g_varchar2) then
    p_rec.pjo_attribute24 :=
    per_pjo_shd.g_old_rec.pjo_attribute24;
  End If;
  If (p_rec.pjo_attribute25 = hr_api.g_varchar2) then
    p_rec.pjo_attribute25 :=
    per_pjo_shd.g_old_rec.pjo_attribute25;
  End If;
  If (p_rec.pjo_attribute26 = hr_api.g_varchar2) then
    p_rec.pjo_attribute26 :=
    per_pjo_shd.g_old_rec.pjo_attribute26;
  End If;
  If (p_rec.pjo_attribute27 = hr_api.g_varchar2) then
    p_rec.pjo_attribute27 :=
    per_pjo_shd.g_old_rec.pjo_attribute27;
  End If;
  If (p_rec.pjo_attribute28 = hr_api.g_varchar2) then
    p_rec.pjo_attribute28 :=
    per_pjo_shd.g_old_rec.pjo_attribute28;
  End If;
  If (p_rec.pjo_attribute29 = hr_api.g_varchar2) then
    p_rec.pjo_attribute29 :=
    per_pjo_shd.g_old_rec.pjo_attribute29;
  End If;
  If (p_rec.pjo_attribute30 = hr_api.g_varchar2) then
    p_rec.pjo_attribute30 :=
    per_pjo_shd.g_old_rec.pjo_attribute30;
  End If;
  If (p_rec.pjo_information_category = hr_api.g_varchar2) then
    p_rec.pjo_information_category :=
    per_pjo_shd.g_old_rec.pjo_information_category;
  End If;
  If (p_rec.pjo_information1 = hr_api.g_varchar2) then
    p_rec.pjo_information1 :=
    per_pjo_shd.g_old_rec.pjo_information1;
  End If;
  If (p_rec.pjo_information2 = hr_api.g_varchar2) then
    p_rec.pjo_information2 :=
    per_pjo_shd.g_old_rec.pjo_information2;
  End If;
  If (p_rec.pjo_information3 = hr_api.g_varchar2) then
    p_rec.pjo_information3 :=
    per_pjo_shd.g_old_rec.pjo_information3;
  End If;
  If (p_rec.pjo_information4 = hr_api.g_varchar2) then
    p_rec.pjo_information4 :=
    per_pjo_shd.g_old_rec.pjo_information4;
  End If;
  If (p_rec.pjo_information5 = hr_api.g_varchar2) then
    p_rec.pjo_information5 :=
    per_pjo_shd.g_old_rec.pjo_information5;
  End If;
  If (p_rec.pjo_information6 = hr_api.g_varchar2) then
    p_rec.pjo_information6 :=
    per_pjo_shd.g_old_rec.pjo_information6;
  End If;
  If (p_rec.pjo_information7 = hr_api.g_varchar2) then
    p_rec.pjo_information7 :=
    per_pjo_shd.g_old_rec.pjo_information7;
  End If;
  If (p_rec.pjo_information8 = hr_api.g_varchar2) then
    p_rec.pjo_information8 :=
    per_pjo_shd.g_old_rec.pjo_information8;
  End If;
  If (p_rec.pjo_information9 = hr_api.g_varchar2) then
    p_rec.pjo_information9 :=
    per_pjo_shd.g_old_rec.pjo_information9;
  End If;
  If (p_rec.pjo_information10 = hr_api.g_varchar2) then
    p_rec.pjo_information10 :=
    per_pjo_shd.g_old_rec.pjo_information10;
  End If;
  If (p_rec.pjo_information11 = hr_api.g_varchar2) then
    p_rec.pjo_information11 :=
    per_pjo_shd.g_old_rec.pjo_information11;
  End If;
  If (p_rec.pjo_information12 = hr_api.g_varchar2) then
    p_rec.pjo_information12 :=
    per_pjo_shd.g_old_rec.pjo_information12;
  End If;
  If (p_rec.pjo_information13 = hr_api.g_varchar2) then
    p_rec.pjo_information13 :=
    per_pjo_shd.g_old_rec.pjo_information13;
  End If;
  If (p_rec.pjo_information14 = hr_api.g_varchar2) then
    p_rec.pjo_information14 :=
    per_pjo_shd.g_old_rec.pjo_information14;
  End If;
  If (p_rec.pjo_information15 = hr_api.g_varchar2) then
    p_rec.pjo_information15 :=
    per_pjo_shd.g_old_rec.pjo_information15;
  End If;
  If (p_rec.pjo_information16 = hr_api.g_varchar2) then
    p_rec.pjo_information16 :=
    per_pjo_shd.g_old_rec.pjo_information16;
  End If;
  If (p_rec.pjo_information17 = hr_api.g_varchar2) then
    p_rec.pjo_information17 :=
    per_pjo_shd.g_old_rec.pjo_information17;
  End If;
  If (p_rec.pjo_information18 = hr_api.g_varchar2) then
    p_rec.pjo_information18 :=
    per_pjo_shd.g_old_rec.pjo_information18;
  End If;
  If (p_rec.pjo_information19 = hr_api.g_varchar2) then
    p_rec.pjo_information19 :=
    per_pjo_shd.g_old_rec.pjo_information19;
  End If;
  If (p_rec.pjo_information20 = hr_api.g_varchar2) then
    p_rec.pjo_information20 :=
    per_pjo_shd.g_old_rec.pjo_information20;
  End If;
  If (p_rec.pjo_information21 = hr_api.g_varchar2) then
    p_rec.pjo_information21 :=
    per_pjo_shd.g_old_rec.pjo_information21;
  End If;
  If (p_rec.pjo_information22 = hr_api.g_varchar2) then
    p_rec.pjo_information22 :=
    per_pjo_shd.g_old_rec.pjo_information22;
  End If;
  If (p_rec.pjo_information23 = hr_api.g_varchar2) then
    p_rec.pjo_information23 :=
    per_pjo_shd.g_old_rec.pjo_information23;
  End If;
  If (p_rec.pjo_information24 = hr_api.g_varchar2) then
    p_rec.pjo_information24 :=
    per_pjo_shd.g_old_rec.pjo_information24;
  End If;
  If (p_rec.pjo_information25 = hr_api.g_varchar2) then
    p_rec.pjo_information25 :=
    per_pjo_shd.g_old_rec.pjo_information25;
  End If;
  If (p_rec.pjo_information26 = hr_api.g_varchar2) then
    p_rec.pjo_information26 :=
    per_pjo_shd.g_old_rec.pjo_information26;
  End If;
  If (p_rec.pjo_information27 = hr_api.g_varchar2) then
    p_rec.pjo_information27 :=
    per_pjo_shd.g_old_rec.pjo_information27;
  End If;
  If (p_rec.pjo_information28 = hr_api.g_varchar2) then
    p_rec.pjo_information28 :=
    per_pjo_shd.g_old_rec.pjo_information28;
  End If;
  If (p_rec.pjo_information29 = hr_api.g_varchar2) then
    p_rec.pjo_information29 :=
    per_pjo_shd.g_old_rec.pjo_information29;
  End If;
  If (p_rec.pjo_information30 = hr_api.g_varchar2) then
    p_rec.pjo_information30 :=
    per_pjo_shd.g_old_rec.pjo_information30;
  End If;
  If (p_rec.all_assignments = hr_api.g_varchar2) then
    p_rec.all_assignments :=
    per_pjo_shd.g_old_rec.all_assignments;
  End If;
  If (p_rec.period_months = hr_api.g_number) then
    p_rec.period_months :=
    per_pjo_shd.g_old_rec.period_months;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy per_pjo_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_pjo_shd.lck
    (p_rec.previous_job_id
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
  per_pjo_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  -- Call the supporting pre-update operation
  --
  per_pjo_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  per_pjo_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  per_pjo_upd.post_update
     (p_effective_date
     ,p_rec
     );
     -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_previous_job_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_previous_employer_id         in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_period_years                 in     number    default hr_api.g_number
  ,p_period_days                  in     number    default hr_api.g_number
  ,p_job_name                     in     varchar2  default hr_api.g_varchar2
  ,p_employment_category          in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information1             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information2             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information3             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information4             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information5             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information6             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information7             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information8             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information9             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information10            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information11            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information12            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information13            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information14            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information15            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information16            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information17            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information18            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information19            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information20            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information21            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information22            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information23            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information24            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information25            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information26            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information27            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information28            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information29            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information30            in     varchar2  default hr_api.g_varchar2
  ,p_all_assignments              in     varchar2  default hr_api.g_varchar2
  ,p_period_months                in     number    default hr_api.g_number
  ) is
--
  l_rec   per_pjo_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_pjo_shd.convert_args
  (p_previous_job_id
  ,p_previous_employer_id
  ,p_start_date
  ,p_end_date
  ,p_period_years
  ,p_period_days
  ,p_job_name
  ,p_employment_category
  ,p_description
  ,p_pjo_attribute_category
  ,p_pjo_attribute1
  ,p_pjo_attribute2
  ,p_pjo_attribute3
  ,p_pjo_attribute4
  ,p_pjo_attribute5
  ,p_pjo_attribute6
  ,p_pjo_attribute7
  ,p_pjo_attribute8
  ,p_pjo_attribute9
  ,p_pjo_attribute10
  ,p_pjo_attribute11
  ,p_pjo_attribute12
  ,p_pjo_attribute13
  ,p_pjo_attribute14
  ,p_pjo_attribute15
  ,p_pjo_attribute16
  ,p_pjo_attribute17
  ,p_pjo_attribute18
  ,p_pjo_attribute19
  ,p_pjo_attribute20
  ,p_pjo_attribute21
  ,p_pjo_attribute22
  ,p_pjo_attribute23
  ,p_pjo_attribute24
  ,p_pjo_attribute25
  ,p_pjo_attribute26
  ,p_pjo_attribute27
  ,p_pjo_attribute28
  ,p_pjo_attribute29
  ,p_pjo_attribute30
  ,p_pjo_information_category
  ,p_pjo_information1
  ,p_pjo_information2
  ,p_pjo_information3
  ,p_pjo_information4
  ,p_pjo_information5
  ,p_pjo_information6
  ,p_pjo_information7
  ,p_pjo_information8
  ,p_pjo_information9
  ,p_pjo_information10
  ,p_pjo_information11
  ,p_pjo_information12
  ,p_pjo_information13
  ,p_pjo_information14
  ,p_pjo_information15
  ,p_pjo_information16
  ,p_pjo_information17
  ,p_pjo_information18
  ,p_pjo_information19
  ,p_pjo_information20
  ,p_pjo_information21
  ,p_pjo_information22
  ,p_pjo_information23
  ,p_pjo_information24
  ,p_pjo_information25
  ,p_pjo_information26
  ,p_pjo_information27
  ,p_pjo_information28
  ,p_pjo_information29
  ,p_pjo_information30
  ,p_object_version_number
  ,p_all_assignments
  ,p_period_months
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_pjo_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_pjo_upd;

/

--------------------------------------------------------
--  DDL for Package Body PER_PML_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PML_UPD" as
/* $Header: pepmlrhi.pkb 120.5.12010000.4 2010/01/15 07:29:24 rvagvala ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pml_upd.';  -- Global package name
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
  (p_rec in out nocopy per_pml_shd.g_rec_type
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
  -- Update the per_objectives_library Row
  --
  update per_objectives_library
    set
     objective_id                    = p_rec.objective_id
    ,object_version_number           = p_rec.object_version_number
    ,objective_name                  = p_rec.objective_name
    ,valid_from                      = p_rec.valid_from
    ,valid_to                        = p_rec.valid_to
    ,target_date                     = p_rec.target_date
    ,next_review_date                = p_rec.next_review_date
    ,group_code                      = p_rec.group_code
    ,priority_code                   = p_rec.priority_code
    ,appraise_flag                   = p_rec.appraise_flag
    ,weighting_percent               = p_rec.weighting_percent
    ,measurement_style_code          = p_rec.measurement_style_code
    ,measure_name                    = p_rec.measure_name
    ,target_value                    = p_rec.target_value
    ,uom_code                        = p_rec.uom_code
    ,measure_type_code               = p_rec.measure_type_code
    ,measure_comments                = p_rec.measure_comments
    ,eligibility_type_code           = p_rec.eligibility_type_code
    ,details                         = p_rec.details
    ,success_criteria                = p_rec.success_criteria
    ,comments                        = p_rec.comments
    ,attribute_category              = p_rec.attribute_category
    ,attribute1                      = p_rec.attribute1
    ,attribute2                      = p_rec.attribute2
    ,attribute3                      = p_rec.attribute3
    ,attribute4                      = p_rec.attribute4
    ,attribute5                      = p_rec.attribute5
    ,attribute6                      = p_rec.attribute6
    ,attribute7                      = p_rec.attribute7
    ,attribute8                      = p_rec.attribute8
    ,attribute9                      = p_rec.attribute9
    ,attribute10                     = p_rec.attribute10
    ,attribute11                     = p_rec.attribute11
    ,attribute12                     = p_rec.attribute12
    ,attribute13                     = p_rec.attribute13
    ,attribute14                     = p_rec.attribute14
    ,attribute15                     = p_rec.attribute15
    ,attribute16                     = p_rec.attribute16
    ,attribute17                     = p_rec.attribute17
    ,attribute18                     = p_rec.attribute18
    ,attribute19                     = p_rec.attribute19
    ,attribute20                     = p_rec.attribute20
    ,attribute21                     = p_rec.attribute21
    ,attribute22                     = p_rec.attribute22
    ,attribute23                     = p_rec.attribute23
    ,attribute24                     = p_rec.attribute24
    ,attribute25                     = p_rec.attribute25
    ,attribute26                     = p_rec.attribute26
    ,attribute27                     = p_rec.attribute27
    ,attribute28                     = p_rec.attribute28
    ,attribute29                     = p_rec.attribute29
    ,attribute30                     = p_rec.attribute30
    where objective_id = p_rec.objective_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_pml_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_pml_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_pml_shd.constraint_error
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
  (p_rec in per_pml_shd.g_rec_type
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
  ,p_rec                          in per_pml_shd.g_rec_type
  ,p_duplicate_name_warning       in boolean
  ,p_weighting_over_100_warning   in boolean
  ,p_weighting_appraisal_warning  in boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_pml_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_objective_id
      => p_rec.objective_id
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_objective_name
      => p_rec.objective_name
      ,p_valid_from
      => p_rec.valid_from
      ,p_valid_to
      => p_rec.valid_to
      ,p_target_date
      => p_rec.target_date
      ,p_next_review_date
      => p_rec.next_review_date
      ,p_group_code
      => p_rec.group_code
      ,p_priority_code
      => p_rec.priority_code
      ,p_appraise_flag
      => p_rec.appraise_flag
      ,p_weighting_percent
      => p_rec.weighting_percent
      ,p_measurement_style_code
      => p_rec.measurement_style_code
      ,p_measure_name
      => p_rec.measure_name
      ,p_target_value
      => p_rec.target_value
      ,p_uom_code
      => p_rec.uom_code
      ,p_measure_type_code
      => p_rec.measure_type_code
      ,p_measure_comments
      => p_rec.measure_comments
      ,p_eligibility_type_code
      => p_rec.eligibility_type_code
      ,p_details
      => p_rec.details
      ,p_success_criteria
      => p_rec.success_criteria
      ,p_comments
      => p_rec.comments
      ,p_attribute_category
      => p_rec.attribute_category
      ,p_attribute1
      => p_rec.attribute1
      ,p_attribute2
      => p_rec.attribute2
      ,p_attribute3
      => p_rec.attribute3
      ,p_attribute4
      => p_rec.attribute4
      ,p_attribute5
      => p_rec.attribute5
      ,p_attribute6
      => p_rec.attribute6
      ,p_attribute7
      => p_rec.attribute7
      ,p_attribute8
      => p_rec.attribute8
      ,p_attribute9
      => p_rec.attribute9
      ,p_attribute10
      => p_rec.attribute10
      ,p_attribute11
      => p_rec.attribute11
      ,p_attribute12
      => p_rec.attribute12
      ,p_attribute13
      => p_rec.attribute13
      ,p_attribute14
      => p_rec.attribute14
      ,p_attribute15
      => p_rec.attribute15
      ,p_attribute16
      => p_rec.attribute16
      ,p_attribute17
      => p_rec.attribute17
      ,p_attribute18
      => p_rec.attribute18
      ,p_attribute19
      => p_rec.attribute19
      ,p_attribute20
      => p_rec.attribute20
      ,p_attribute21
      => p_rec.attribute21
      ,p_attribute22
      => p_rec.attribute22
      ,p_attribute23
      => p_rec.attribute23
      ,p_attribute24
      => p_rec.attribute24
      ,p_attribute25
      => p_rec.attribute25
      ,p_attribute26
      => p_rec.attribute26
      ,p_attribute27
      => p_rec.attribute27
      ,p_attribute28
      => p_rec.attribute28
      ,p_attribute29
      => p_rec.attribute29
      ,p_attribute30
      => p_rec.attribute30
      ,p_duplicate_name_warning
      => p_duplicate_name_warning
      ,p_weighting_over_100_warning
      => p_weighting_over_100_warning
      ,p_weighting_appraisal_warning
      => p_weighting_appraisal_warning
      ,p_object_version_number_o
      => per_pml_shd.g_old_rec.object_version_number
      ,p_objective_name_o
      => per_pml_shd.g_old_rec.objective_name
      ,p_valid_from_o
      => per_pml_shd.g_old_rec.valid_from
      ,p_valid_to_o
      => per_pml_shd.g_old_rec.valid_to
      ,p_target_date_o
      => per_pml_shd.g_old_rec.target_date
      ,p_next_review_date_o
      => per_pml_shd.g_old_rec.next_review_date
      ,p_group_code_o
      => per_pml_shd.g_old_rec.group_code
      ,p_priority_code_o
      => per_pml_shd.g_old_rec.priority_code
      ,p_appraise_flag_o
      => per_pml_shd.g_old_rec.appraise_flag
      ,p_weighting_percent_o
      => per_pml_shd.g_old_rec.weighting_percent
      ,p_measurement_style_code_o
      => per_pml_shd.g_old_rec.measurement_style_code
      ,p_measure_name_o
      => per_pml_shd.g_old_rec.measure_name
      ,p_target_value_o
      => per_pml_shd.g_old_rec.target_value
      ,p_uom_code_o
      => per_pml_shd.g_old_rec.uom_code
      ,p_measure_type_code_o
      => per_pml_shd.g_old_rec.measure_type_code
      ,p_measure_comments_o
      => per_pml_shd.g_old_rec.measure_comments
      ,p_eligibility_type_code_o
      => per_pml_shd.g_old_rec.eligibility_type_code
      ,p_details_o
      => per_pml_shd.g_old_rec.details
      ,p_success_criteria_o
      => per_pml_shd.g_old_rec.success_criteria
      ,p_comments_o
      => per_pml_shd.g_old_rec.comments
      ,p_attribute_category_o
      => per_pml_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => per_pml_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => per_pml_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => per_pml_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => per_pml_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => per_pml_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => per_pml_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => per_pml_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => per_pml_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => per_pml_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => per_pml_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => per_pml_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => per_pml_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => per_pml_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => per_pml_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => per_pml_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => per_pml_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => per_pml_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => per_pml_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => per_pml_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => per_pml_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => per_pml_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => per_pml_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => per_pml_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => per_pml_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => per_pml_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => per_pml_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => per_pml_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => per_pml_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => per_pml_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => per_pml_shd.g_old_rec.attribute30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_OBJECTIVES_LIBRARY'
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
  (p_rec in out nocopy per_pml_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.objective_name = hr_api.g_varchar2) then
    p_rec.objective_name :=
    per_pml_shd.g_old_rec.objective_name;
  End If;
  If (p_rec.valid_from = hr_api.g_date) then
    p_rec.valid_from :=
    per_pml_shd.g_old_rec.valid_from;
  End If;
  If (p_rec.valid_to = hr_api.g_date) then
    p_rec.valid_to :=
    per_pml_shd.g_old_rec.valid_to;
  End If;
  If (p_rec.target_date = hr_api.g_date) then
    p_rec.target_date :=
    per_pml_shd.g_old_rec.target_date;
  End If;
  If (p_rec.next_review_date = hr_api.g_date) then
    p_rec.next_review_date :=
    per_pml_shd.g_old_rec.next_review_date;
  End If;
  If (p_rec.group_code = hr_api.g_varchar2) then
    p_rec.group_code :=
    per_pml_shd.g_old_rec.group_code;
  End If;
  If (p_rec.priority_code = hr_api.g_varchar2) then
    p_rec.priority_code :=
    per_pml_shd.g_old_rec.priority_code;
  End If;
  If (p_rec.appraise_flag = hr_api.g_varchar2) then
    p_rec.appraise_flag :=
    per_pml_shd.g_old_rec.appraise_flag;
  End If;
  If (p_rec.weighting_percent = hr_api.g_number) then
    p_rec.weighting_percent :=
    per_pml_shd.g_old_rec.weighting_percent;
  End If;
  If (p_rec.measurement_style_code = hr_api.g_varchar2) then
    p_rec.measurement_style_code :=
    per_pml_shd.g_old_rec.measurement_style_code;
  End If;
  If (p_rec.measure_name = hr_api.g_varchar2) then
    p_rec.measure_name :=
    per_pml_shd.g_old_rec.measure_name;
  End If;
  If (p_rec.target_value = hr_api.g_number) then
    p_rec.target_value :=
    per_pml_shd.g_old_rec.target_value;
  End If;
  If (p_rec.uom_code = hr_api.g_varchar2) then
    p_rec.uom_code :=
    per_pml_shd.g_old_rec.uom_code;
  End If;
  If (p_rec.measure_type_code = hr_api.g_varchar2) then
    p_rec.measure_type_code :=
    per_pml_shd.g_old_rec.measure_type_code;
  End If;
  If (p_rec.measure_comments = hr_api.g_varchar2) then
    p_rec.measure_comments :=
    per_pml_shd.g_old_rec.measure_comments;
  End If;
  If (p_rec.eligibility_type_code = hr_api.g_varchar2) then
    p_rec.eligibility_type_code :=
    per_pml_shd.g_old_rec.eligibility_type_code;
  End If;
  If (p_rec.details = hr_api.g_varchar2) then
    p_rec.details :=
    per_pml_shd.g_old_rec.details;
  End If;
  If (p_rec.success_criteria = hr_api.g_varchar2) then
    p_rec.success_criteria :=
    per_pml_shd.g_old_rec.success_criteria;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    per_pml_shd.g_old_rec.comments;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    per_pml_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    per_pml_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    per_pml_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    per_pml_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    per_pml_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    per_pml_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    per_pml_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    per_pml_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    per_pml_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    per_pml_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    per_pml_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    per_pml_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    per_pml_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    per_pml_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    per_pml_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    per_pml_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    per_pml_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    per_pml_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    per_pml_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    per_pml_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    per_pml_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.attribute21 = hr_api.g_varchar2) then
    p_rec.attribute21 :=
    per_pml_shd.g_old_rec.attribute21;
  End If;
  If (p_rec.attribute22 = hr_api.g_varchar2) then
    p_rec.attribute22 :=
    per_pml_shd.g_old_rec.attribute22;
  End If;
  If (p_rec.attribute23 = hr_api.g_varchar2) then
    p_rec.attribute23 :=
    per_pml_shd.g_old_rec.attribute23;
  End If;
  If (p_rec.attribute24 = hr_api.g_varchar2) then
    p_rec.attribute24 :=
    per_pml_shd.g_old_rec.attribute24;
  End If;
  If (p_rec.attribute25 = hr_api.g_varchar2) then
    p_rec.attribute25 :=
    per_pml_shd.g_old_rec.attribute25;
  End If;
  If (p_rec.attribute26 = hr_api.g_varchar2) then
    p_rec.attribute26 :=
    per_pml_shd.g_old_rec.attribute26;
  End If;
  If (p_rec.attribute27 = hr_api.g_varchar2) then
    p_rec.attribute27 :=
    per_pml_shd.g_old_rec.attribute27;
  End If;
  If (p_rec.attribute28 = hr_api.g_varchar2) then
    p_rec.attribute28 :=
    per_pml_shd.g_old_rec.attribute28;
  End If;
  If (p_rec.attribute29 = hr_api.g_varchar2) then
    p_rec.attribute29 :=
    per_pml_shd.g_old_rec.attribute29;
  End If;
  If (p_rec.attribute30 = hr_api.g_varchar2) then
    p_rec.attribute30 :=
    per_pml_shd.g_old_rec.attribute30;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_rec                          in out nocopy per_pml_shd.g_rec_type
  ,p_duplicate_name_warning          out nocopy boolean
  ,p_weighting_over_100_warning	     out nocopy	boolean
  ,p_weighting_appraisal_warning     out nocopy	boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_pml_shd.lck
    (p_rec.objective_id
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
  per_pml_bus.update_validate
     (p_effective_date
     ,p_rec
     ,p_duplicate_name_warning
     ,p_weighting_over_100_warning
     ,p_weighting_appraisal_warning
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  per_pml_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  per_pml_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  per_pml_upd.post_update
     (p_effective_date              => p_effective_date
     ,p_rec                         => p_rec
     ,p_duplicate_name_warning      => p_duplicate_name_warning
     ,p_weighting_over_100_warning  => p_weighting_over_100_warning
     ,p_weighting_appraisal_warning => p_weighting_appraisal_warning
     );
  --
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
  ,p_objective_id                 in     number
  ,p_object_version_number        in out nocopy number
  ,p_objective_name               in     varchar2  default hr_api.g_varchar2
  ,p_measurement_style_code       in     varchar2  default hr_api.g_varchar2
  ,p_eligibility_type_code        in     varchar2  default hr_api.g_varchar2
  ,p_valid_from                   in     date      default hr_api.g_date
  ,p_valid_to                     in     date      default hr_api.g_date
  ,p_target_date                  in     date      default hr_api.g_date
  ,p_next_review_date             in     date      default hr_api.g_date
  ,p_group_code                   in     varchar2  default hr_api.g_varchar2
  ,p_priority_code                in     varchar2  default hr_api.g_varchar2
  ,p_appraise_flag                in     varchar2  default hr_api.g_varchar2
  ,p_weighting_percent            in     number    default hr_api.g_number
  ,p_measure_name                 in     varchar2  default hr_api.g_varchar2
  ,p_target_value                 in     number    default hr_api.g_number
  ,p_uom_code                     in     varchar2  default hr_api.g_varchar2
  ,p_measure_type_code            in     varchar2  default hr_api.g_varchar2
  ,p_measure_comments             in     varchar2  default hr_api.g_varchar2
  ,p_details                      in     varchar2  default hr_api.g_varchar2
  ,p_success_criteria             in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_duplicate_name_warning          out nocopy   boolean
  ,p_weighting_over_100_warning      out nocopy   boolean
  ,p_weighting_appraisal_warning     out nocopy   boolean
  ) is
--
  l_rec   per_pml_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
  l_duplicate_name_warning       boolean;
  l_weighting_over_100_warning   boolean;
  l_weighting_appraisal_warning  boolean;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_pml_shd.convert_args
  (p_objective_id
  ,p_object_version_number
  ,p_objective_name
  ,p_valid_from
  ,p_valid_to
  ,p_target_date
  ,p_next_review_date
  ,p_group_code
  ,p_priority_code
  ,p_appraise_flag
  ,p_weighting_percent
  ,p_measurement_style_code
  ,p_measure_name
  ,p_target_value
  ,p_uom_code
  ,p_measure_type_code
  ,p_measure_comments
  ,p_eligibility_type_code
  ,p_details
  ,p_success_criteria
  ,p_comments
  ,p_attribute_category
  ,p_attribute1
  ,p_attribute2
  ,p_attribute3
  ,p_attribute4
  ,p_attribute5
  ,p_attribute6
  ,p_attribute7
  ,p_attribute8
  ,p_attribute9
  ,p_attribute10
  ,p_attribute11
  ,p_attribute12
  ,p_attribute13
  ,p_attribute14
  ,p_attribute15
  ,p_attribute16
  ,p_attribute17
  ,p_attribute18
  ,p_attribute19
  ,p_attribute20
  ,p_attribute21
  ,p_attribute22
  ,p_attribute23
  ,p_attribute24
  ,p_attribute25
  ,p_attribute26
  ,p_attribute27
  ,p_attribute28
  ,p_attribute29
  ,p_attribute30
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_pml_upd.upd
     (p_effective_date
     ,l_rec
     ,l_duplicate_name_warning
     ,l_weighting_over_100_warning
     ,l_weighting_appraisal_warning
     );
  p_object_version_number       := l_rec.object_version_number;
  p_duplicate_name_warning      := l_duplicate_name_warning;
  p_weighting_over_100_warning  := l_weighting_over_100_warning;
  p_weighting_appraisal_warning := l_weighting_appraisal_warning;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_pml_upd;

/

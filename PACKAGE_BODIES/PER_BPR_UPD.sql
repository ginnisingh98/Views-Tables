--------------------------------------------------------
--  DDL for Package Body PER_BPR_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BPR_UPD" as
/* $Header: pebprrhi.pkb 115.6 2002/12/02 14:33:23 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bpr_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy per_bpr_shd.g_rec_type) is
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
  -- Update the per_bf_payroll_runs Row
  --
  update per_bf_payroll_runs
  set
  payroll_run_id                    = p_rec.payroll_run_id,
  payroll_identifier                = p_rec.payroll_identifier,
  period_start_date                 = p_rec.period_start_date,
  period_end_date                   = p_rec.period_end_date,
  processing_date                   = p_rec.processing_date,
  object_version_number             = p_rec.object_version_number,
  bpr_attribute_category                = p_rec.bpr_attribute_category,
  bpr_attribute1                        = p_rec.bpr_attribute1,
  bpr_attribute2                        = p_rec.bpr_attribute2,
  bpr_attribute3                        = p_rec.bpr_attribute3,
  bpr_attribute4                        = p_rec.bpr_attribute4,
  bpr_attribute5                        = p_rec.bpr_attribute5,
  bpr_attribute6                        = p_rec.bpr_attribute6,
  bpr_attribute7                        = p_rec.bpr_attribute7,
  bpr_attribute8                        = p_rec.bpr_attribute8,
  bpr_attribute9                        = p_rec.bpr_attribute9,
  bpr_attribute10                       = p_rec.bpr_attribute10,
  bpr_attribute11                       = p_rec.bpr_attribute11,
  bpr_attribute12                       = p_rec.bpr_attribute12,
  bpr_attribute13                       = p_rec.bpr_attribute13,
  bpr_attribute14                       = p_rec.bpr_attribute14,
  bpr_attribute15                       = p_rec.bpr_attribute15,
  bpr_attribute16                       = p_rec.bpr_attribute16,
  bpr_attribute17                       = p_rec.bpr_attribute17,
  bpr_attribute18                       = p_rec.bpr_attribute18,
  bpr_attribute19                       = p_rec.bpr_attribute19,
  bpr_attribute20                       = p_rec.bpr_attribute20,
  bpr_attribute21                       = p_rec.bpr_attribute21,
  bpr_attribute22                       = p_rec.bpr_attribute22,
  bpr_attribute23                       = p_rec.bpr_attribute23,
  bpr_attribute24                       = p_rec.bpr_attribute24,
  bpr_attribute25                       = p_rec.bpr_attribute25,
  bpr_attribute26                       = p_rec.bpr_attribute26,
  bpr_attribute27                       = p_rec.bpr_attribute27,
  bpr_attribute28                       = p_rec.bpr_attribute28,
  bpr_attribute29                       = p_rec.bpr_attribute29,
  bpr_attribute30                       = p_rec.bpr_attribute30

  where payroll_run_id = p_rec.payroll_run_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_bpr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_bpr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_bpr_shd.constraint_error
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
Procedure pre_update(p_rec in per_bpr_shd.g_rec_type) is
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
Procedure post_update(p_effective_date   in  date,
                      p_rec in per_bpr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_bpr_rku.after_update
      (p_effective_date              => p_effective_date,
      p_payroll_run_id             => p_rec.payroll_run_id,
      p_payroll_identifier         => p_rec.payroll_identifier,
      p_period_start_date          => p_rec.period_start_date,
      p_period_end_date            => p_rec.period_end_date,
      p_processing_date            => p_rec.processing_date,
      p_object_version_number      => p_rec.object_version_number,
      p_bpr_attribute_category         => p_rec.bpr_attribute_category,
      p_bpr_attribute1                 => p_rec.bpr_attribute1,
      p_bpr_attribute2                 => p_rec.bpr_attribute2,
      p_bpr_attribute3                 => p_rec.bpr_attribute3,
      p_bpr_attribute4                 => p_rec.bpr_attribute4,
      p_bpr_attribute5                 => p_rec.bpr_attribute5,
      p_bpr_attribute6                 => p_rec.bpr_attribute6,
      p_bpr_attribute7                 => p_rec.bpr_attribute7,
      p_bpr_attribute8                 => p_rec.bpr_attribute8,
      p_bpr_attribute9                 => p_rec.bpr_attribute9,
      p_bpr_attribute10                => p_rec.bpr_attribute10,
      p_bpr_attribute11                => p_rec.bpr_attribute11,
      p_bpr_attribute12                => p_rec.bpr_attribute12,
      p_bpr_attribute13                => p_rec.bpr_attribute13,
      p_bpr_attribute14                => p_rec.bpr_attribute14,
      p_bpr_attribute15                => p_rec.bpr_attribute15,
      p_bpr_attribute16                => p_rec.bpr_attribute16,
      p_bpr_attribute17                => p_rec.bpr_attribute17,
      p_bpr_attribute18                => p_rec.bpr_attribute18,
      p_bpr_attribute19                => p_rec.bpr_attribute19,
      p_bpr_attribute20                => p_rec.bpr_attribute20,
      p_bpr_attribute21                => p_rec.bpr_attribute21,
      p_bpr_attribute22                => p_rec.bpr_attribute22,
      p_bpr_attribute23                => p_rec.bpr_attribute23,
      p_bpr_attribute24                => p_rec.bpr_attribute24,
      p_bpr_attribute25                => p_rec.bpr_attribute25,
      p_bpr_attribute26                => p_rec.bpr_attribute26,
      p_bpr_attribute27                => p_rec.bpr_attribute27,
      p_bpr_attribute28                => p_rec.bpr_attribute28,
      p_bpr_attribute29                => p_rec.bpr_attribute29,
      p_bpr_attribute30                => p_rec.bpr_attribute30,
      p_payroll_id_o
      => per_bpr_shd.g_old_rec.payroll_id,
      p_business_group_id_o
      => per_bpr_shd.g_old_rec.business_group_id,
      p_payroll_identifier_o
      => per_bpr_shd.g_old_rec.payroll_identifier,
      p_period_start_date_o
      => per_bpr_shd.g_old_rec.period_start_date,
      p_period_end_date_o
      => per_bpr_shd.g_old_rec.period_end_date,
      p_processing_date_o
      => per_bpr_shd.g_old_rec.processing_date,
      p_object_version_number_o
      => per_bpr_shd.g_old_rec.object_version_number,
      p_bpr_attribute_category_o
      => per_bpr_shd.g_old_rec.bpr_attribute_category,
      p_bpr_attribute1_o
      => per_bpr_shd.g_old_rec.bpr_attribute1,
      p_bpr_attribute2_o
      => per_bpr_shd.g_old_rec.bpr_attribute2,
      p_bpr_attribute3_o
      => per_bpr_shd.g_old_rec.bpr_attribute3,
      p_bpr_attribute4_o
      => per_bpr_shd.g_old_rec.bpr_attribute4,
      p_bpr_attribute5_o
      => per_bpr_shd.g_old_rec.bpr_attribute5,
      p_bpr_attribute6_o
      => per_bpr_shd.g_old_rec.bpr_attribute6,
      p_bpr_attribute7_o
      => per_bpr_shd.g_old_rec.bpr_attribute7,
      p_bpr_attribute8_o
      => per_bpr_shd.g_old_rec.bpr_attribute8,
      p_bpr_attribute9_o
      => per_bpr_shd.g_old_rec.bpr_attribute9,
      p_bpr_attribute10_o
      => per_bpr_shd.g_old_rec.bpr_attribute10,
      p_bpr_attribute11_o
      => per_bpr_shd.g_old_rec.bpr_attribute11,
      p_bpr_attribute12_o
      => per_bpr_shd.g_old_rec.bpr_attribute12,
      p_bpr_attribute13_o
      => per_bpr_shd.g_old_rec.bpr_attribute13,
      p_bpr_attribute14_o
      => per_bpr_shd.g_old_rec.bpr_attribute14,
      p_bpr_attribute15_o
      => per_bpr_shd.g_old_rec.bpr_attribute15,
      p_bpr_attribute16_o
      => per_bpr_shd.g_old_rec.bpr_attribute16,
      p_bpr_attribute17_o
      => per_bpr_shd.g_old_rec.bpr_attribute17,
      p_bpr_attribute18_o
      => per_bpr_shd.g_old_rec.bpr_attribute18,
      p_bpr_attribute19_o
      => per_bpr_shd.g_old_rec.bpr_attribute19,
      p_bpr_attribute20_o
      => per_bpr_shd.g_old_rec.bpr_attribute20,
      p_bpr_attribute21_o
      => per_bpr_shd.g_old_rec.bpr_attribute21,
      p_bpr_attribute22_o
      => per_bpr_shd.g_old_rec.bpr_attribute22,
      p_bpr_attribute23_o
      => per_bpr_shd.g_old_rec.bpr_attribute23,
      p_bpr_attribute24_o
      => per_bpr_shd.g_old_rec.bpr_attribute24,
      p_bpr_attribute25_o
      => per_bpr_shd.g_old_rec.bpr_attribute25,
      p_bpr_attribute26_o
      => per_bpr_shd.g_old_rec.bpr_attribute26,
      p_bpr_attribute27_o
      => per_bpr_shd.g_old_rec.bpr_attribute27,
      p_bpr_attribute28_o
      => per_bpr_shd.g_old_rec.bpr_attribute28,
      p_bpr_attribute29_o
      => per_bpr_shd.g_old_rec.bpr_attribute29,
      p_bpr_attribute30_o
      => per_bpr_shd.g_old_rec.bpr_attribute30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_BF_PAYROLL_RUNS'
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
--   A Pl/Sql record structre.
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
Procedure convert_defs(p_rec in out nocopy per_bpr_shd.g_rec_type) is
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
  If (p_rec.payroll_id = hr_api.g_number) then
    p_rec.payroll_id :=
    per_bpr_shd.g_old_rec.payroll_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    per_bpr_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.payroll_identifier = hr_api.g_varchar2) then
    p_rec.payroll_identifier :=
    per_bpr_shd.g_old_rec.payroll_identifier;
  End If;
  If (p_rec.period_start_date = hr_api.g_date) then
    p_rec.period_start_date :=
    per_bpr_shd.g_old_rec.period_start_date;
  End If;
  If (p_rec.period_end_date = hr_api.g_date) then
    p_rec.period_end_date :=
    per_bpr_shd.g_old_rec.period_end_date;
  End If;
  If (p_rec.processing_date = hr_api.g_date) then
    p_rec.processing_date :=
    per_bpr_shd.g_old_rec.processing_date;
  End If;
  If (p_rec.bpr_attribute_category = hr_api.g_varchar2) then
    p_rec.bpr_attribute_category :=
    per_bpr_shd.g_old_rec.bpr_attribute_category;
  End If;
  If (p_rec.bpr_attribute1 = hr_api.g_varchar2) then
    p_rec.bpr_attribute1:=
    per_bpr_shd.g_old_rec.bpr_attribute1;
  End If;
  If (p_rec.bpr_attribute2 = hr_api.g_varchar2) then
    p_rec.bpr_attribute2:=
    per_bpr_shd.g_old_rec.bpr_attribute2;
  End If;
  If (p_rec.bpr_attribute3 = hr_api.g_varchar2) then
    p_rec.bpr_attribute3:=
    per_bpr_shd.g_old_rec.bpr_attribute3;
  End If;
  If (p_rec.bpr_attribute4 = hr_api.g_varchar2) then
  p_rec.bpr_attribute4:=
    per_bpr_shd.g_old_rec.bpr_attribute4;
  End If;
  If (p_rec.bpr_attribute5 = hr_api.g_varchar2) then
    p_rec.bpr_attribute5:=
    per_bpr_shd.g_old_rec.bpr_attribute5;
  End If;
  If (p_rec.bpr_attribute6 = hr_api.g_varchar2) then
    p_rec.bpr_attribute6:=
    per_bpr_shd.g_old_rec.bpr_attribute6;
  End If;
  If (p_rec.bpr_attribute7 = hr_api.g_varchar2) then
    p_rec.bpr_attribute7:=
    per_bpr_shd.g_old_rec.bpr_attribute7;
  End If;
  If (p_rec.bpr_attribute8 = hr_api.g_varchar2) then
    p_rec.bpr_attribute8:=
    per_bpr_shd.g_old_rec.bpr_attribute8;
  End If;
  If (p_rec.bpr_attribute9 = hr_api.g_varchar2) then
    p_rec.bpr_attribute9:=
    per_bpr_shd.g_old_rec.bpr_attribute9;
  End If;
  If (p_rec.bpr_attribute10 = hr_api.g_varchar2) then
    p_rec.bpr_attribute10:=
    per_bpr_shd.g_old_rec.bpr_attribute10;
  End If;
  If (p_rec.bpr_attribute11 = hr_api.g_varchar2) then
    p_rec.bpr_attribute11:=
    per_bpr_shd.g_old_rec.bpr_attribute11;
  End If;
  If (p_rec.bpr_attribute12 = hr_api.g_varchar2) then
    p_rec.bpr_attribute12:=
    per_bpr_shd.g_old_rec.bpr_attribute12;
  End If;
  If (p_rec.bpr_attribute13 = hr_api.g_varchar2) then
    p_rec.bpr_attribute13:=
    per_bpr_shd.g_old_rec.bpr_attribute13;
  End If;
  If (p_rec.bpr_attribute14 = hr_api.g_varchar2) then
    p_rec.bpr_attribute14:=
    per_bpr_shd.g_old_rec.bpr_attribute14;
  End If;
  If (p_rec.bpr_attribute15 = hr_api.g_varchar2) then
    p_rec.bpr_attribute15:=
    per_bpr_shd.g_old_rec.bpr_attribute15;
  End If;
  If (p_rec.bpr_attribute16 = hr_api.g_varchar2) then
    p_rec.bpr_attribute16:=
    per_bpr_shd.g_old_rec.bpr_attribute16;
  End If;
  If (p_rec.bpr_attribute17 = hr_api.g_varchar2) then
    p_rec.bpr_attribute17:=
    per_bpr_shd.g_old_rec.bpr_attribute17;
  End If;
  If (p_rec.bpr_attribute18 = hr_api.g_varchar2) then
    p_rec.bpr_attribute18:=
    per_bpr_shd.g_old_rec.bpr_attribute18;
  End If;
  If (p_rec.bpr_attribute19 = hr_api.g_varchar2) then
    p_rec.bpr_attribute19:=
    per_bpr_shd.g_old_rec.bpr_attribute19;
  End If;
  If (p_rec.bpr_attribute20 = hr_api.g_varchar2) then
    p_rec.bpr_attribute20:=
    per_bpr_shd.g_old_rec.bpr_attribute20;
  End If;
  If (p_rec.bpr_attribute21 = hr_api.g_varchar2) then
    p_rec.bpr_attribute21:=
    per_bpr_shd.g_old_rec.bpr_attribute21;
  End If;
  If (p_rec.bpr_attribute22 = hr_api.g_varchar2) then
    p_rec.bpr_attribute22:=
    per_bpr_shd.g_old_rec.bpr_attribute22;
  End If;
  If (p_rec.bpr_attribute23 = hr_api.g_varchar2) then
    p_rec.bpr_attribute23:=
    per_bpr_shd.g_old_rec.bpr_attribute23;
  End If;
  If (p_rec.bpr_attribute24 = hr_api.g_varchar2) then
    p_rec.bpr_attribute24:=
    per_bpr_shd.g_old_rec.bpr_attribute24;
  End If;
  If (p_rec.bpr_attribute25 = hr_api.g_varchar2) then
    p_rec.bpr_attribute25:=
    per_bpr_shd.g_old_rec.bpr_attribute25;
  End If;
  If (p_rec.bpr_attribute26 = hr_api.g_varchar2) then
    p_rec.bpr_attribute26:=
    per_bpr_shd.g_old_rec.bpr_attribute26;
  End If;
  If (p_rec.bpr_attribute27 = hr_api.g_varchar2) then
    p_rec.bpr_attribute27:=
    per_bpr_shd.g_old_rec.bpr_attribute27;
  End If;
  If (p_rec.bpr_attribute28 = hr_api.g_varchar2) then
    p_rec.bpr_attribute28:=
    per_bpr_shd.g_old_rec.bpr_attribute28;
  End If;
  If (p_rec.bpr_attribute29 = hr_api.g_varchar2) then
    p_rec.bpr_attribute29:=
    per_bpr_shd.g_old_rec.bpr_attribute29;
  End If;
  If (p_rec.bpr_attribute30 = hr_api.g_varchar2) then
    p_rec.bpr_attribute30:=
    per_bpr_shd.g_old_rec.bpr_attribute30;
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
  p_effective_date   in  date,
  p_rec        in out nocopy per_bpr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_bpr_shd.lck
    (
      p_rec.payroll_run_id,
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
  per_bpr_bus.update_validate(p_effective_date,
                             p_rec
                             );
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
  post_update(p_effective_date
	     ,p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
   p_effective_date   in  date,
  p_payroll_run_id              in number,
  p_payroll_identifier          in varchar2       default hr_api.g_varchar2,
  p_period_start_date           in date           default hr_api.g_date,
  p_period_end_date             in date           default hr_api.g_date,
  p_processing_date             in date           default hr_api.g_date,
  p_object_version_number       in out nocopy number,
  p_bpr_attribute_category          in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute1                  in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute2                  in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute3                  in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute4                  in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute5                  in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute6                  in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute7                  in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute8                  in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute9                  in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute10                 in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute11                 in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute12                 in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute13                 in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute14                 in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute15                 in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute16                 in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute17                 in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute18                 in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute19                 in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute20                 in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute21                 in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute22                 in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute23                 in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute24                 in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute25                 in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute26                 in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute27                 in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute28                 in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute29                 in varchar2       default hr_api.g_varchar2,
  p_bpr_attribute30                 in varchar2       default hr_api.g_varchar2
  ) is
--
  l_rec	  per_bpr_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_bpr_shd.convert_args
  (
  p_payroll_run_id,
  hr_api.g_number,
  hr_api.g_number,
  p_payroll_identifier,
  p_period_start_date,
  p_period_end_date,
  p_processing_date,
  p_object_version_number,
  p_bpr_attribute_category,
  p_bpr_attribute1,
  p_bpr_attribute2,
  p_bpr_attribute3,
  p_bpr_attribute4,
  p_bpr_attribute5,
  p_bpr_attribute6,
  p_bpr_attribute7,
  p_bpr_attribute8,
  p_bpr_attribute9,
  p_bpr_attribute10,
  p_bpr_attribute11,
  p_bpr_attribute12,
  p_bpr_attribute13,
  p_bpr_attribute14,
  p_bpr_attribute15,
  p_bpr_attribute16,
  p_bpr_attribute17,
  p_bpr_attribute18,
  p_bpr_attribute19,
  p_bpr_attribute20,
  p_bpr_attribute21,
  p_bpr_attribute22,
  p_bpr_attribute23,
  p_bpr_attribute24,
  p_bpr_attribute25,
  p_bpr_attribute26,
  p_bpr_attribute27,
  p_bpr_attribute28,
  p_bpr_attribute29,
  p_bpr_attribute30
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(p_effective_date,
      l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_bpr_upd;

/

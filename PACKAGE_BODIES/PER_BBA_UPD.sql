--------------------------------------------------------
--  DDL for Package Body PER_BBA_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BBA_UPD" as
/* $Header: pebbarhi.pkb 115.8 2002/12/02 13:03:45 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bba_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy per_bba_shd.g_rec_type) is
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
  -- Update the per_bf_balance_amounts Row
  --
  update per_bf_balance_amounts
  set
  balance_amount_id                 = p_rec.balance_amount_id,
  ytd_amount                        = p_rec.ytd_amount,
  fytd_amount                       = p_rec.fytd_amount,
  ptd_amount                        = p_rec.ptd_amount,
  mtd_amount                        = p_rec.mtd_amount,
  qtd_amount                        = p_rec.qtd_amount,
  run_amount                        = p_rec.run_amount,
  object_version_number             = p_rec.object_version_number,
  bba_attribute_category                = p_rec.bba_attribute_category,
  bba_attribute1                        = p_rec.bba_attribute1,
  bba_attribute2                        = p_rec.bba_attribute2,
  bba_attribute3                        = p_rec.bba_attribute3,
  bba_attribute4                        = p_rec.bba_attribute4,
  bba_attribute5                        = p_rec.bba_attribute5,
  bba_attribute6                        = p_rec.bba_attribute6,
  bba_attribute7                        = p_rec.bba_attribute7,
  bba_attribute8                        = p_rec.bba_attribute8,
  bba_attribute9                        = p_rec.bba_attribute9,
  bba_attribute10                       = p_rec.bba_attribute10,
  bba_attribute11                       = p_rec.bba_attribute11,
  bba_attribute12                       = p_rec.bba_attribute12,
  bba_attribute13                       = p_rec.bba_attribute13,
  bba_attribute14                       = p_rec.bba_attribute14,
  bba_attribute15                       = p_rec.bba_attribute15,
  bba_attribute16                       = p_rec.bba_attribute16,
  bba_attribute17                       = p_rec.bba_attribute17,
  bba_attribute18                       = p_rec.bba_attribute18,
  bba_attribute19                       = p_rec.bba_attribute19,
  bba_attribute20                       = p_rec.bba_attribute20,
  bba_attribute21                       = p_rec.bba_attribute21,
  bba_attribute22                       = p_rec.bba_attribute22,
  bba_attribute23                       = p_rec.bba_attribute23,
  bba_attribute24                       = p_rec.bba_attribute24,
  bba_attribute25                       = p_rec.bba_attribute25,
  bba_attribute26                       = p_rec.bba_attribute26,
  bba_attribute27                       = p_rec.bba_attribute27,
  bba_attribute28                       = p_rec.bba_attribute28,
  bba_attribute29                       = p_rec.bba_attribute29,
  bba_attribute30                       = p_rec.bba_attribute30
  where balance_amount_id = p_rec.balance_amount_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_bba_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_bba_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_bba_shd.constraint_error
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
Procedure pre_update(p_rec in per_bba_shd.g_rec_type) is
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
                      p_rec in per_bba_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_bba_rku.after_update
      (p_effective_date              => p_effective_date,
      p_balance_amount_id          => p_rec.balance_amount_id,
      p_ytd_amount                 => p_rec.ytd_amount,
      p_fytd_amount                => p_rec.fytd_amount,
      p_ptd_amount                 => p_rec.ptd_amount,
      p_mtd_amount                 => p_rec.mtd_amount,
      p_qtd_amount                 => p_rec.qtd_amount,
      p_run_amount                 => p_rec.run_amount,
      p_object_version_number      => p_rec.object_version_number,
      p_bba_attribute_category         => p_rec.bba_attribute_category,
      p_bba_attribute1                 => p_rec.bba_attribute1,
      p_bba_attribute2                 => p_rec.bba_attribute2,
      p_bba_attribute3                 => p_rec.bba_attribute3,
      p_bba_attribute4                 => p_rec.bba_attribute4,
      p_bba_attribute5                 => p_rec.bba_attribute5,
      p_bba_attribute6                 => p_rec.bba_attribute6,
      p_bba_attribute7                 => p_rec.bba_attribute7,
      p_bba_attribute8                 => p_rec.bba_attribute8,
      p_bba_attribute9                 => p_rec.bba_attribute9,
      p_bba_attribute10                => p_rec.bba_attribute10,
      p_bba_attribute11                => p_rec.bba_attribute11,
      p_bba_attribute12                => p_rec.bba_attribute12,
      p_bba_attribute13                => p_rec.bba_attribute13,
      p_bba_attribute14                => p_rec.bba_attribute14,
      p_bba_attribute15                => p_rec.bba_attribute15,
      p_bba_attribute16                => p_rec.bba_attribute16,
      p_bba_attribute17                => p_rec.bba_attribute17,
      p_bba_attribute18                => p_rec.bba_attribute18,
      p_bba_attribute19                => p_rec.bba_attribute19,
      p_bba_attribute20                => p_rec.bba_attribute20,
      p_bba_attribute21                => p_rec.bba_attribute21,
      p_bba_attribute22                => p_rec.bba_attribute22,
      p_bba_attribute23                => p_rec.bba_attribute23,
      p_bba_attribute24                => p_rec.bba_attribute24,
      p_bba_attribute25                => p_rec.bba_attribute25,
      p_bba_attribute26                => p_rec.bba_attribute26,
      p_bba_attribute27                => p_rec.bba_attribute27,
      p_bba_attribute28                => p_rec.bba_attribute28,
      p_bba_attribute29                => p_rec.bba_attribute29,
      p_bba_attribute30                => p_rec.bba_attribute30,
      p_balance_type_id_o
      => per_bba_shd.g_old_rec.balance_type_id,
      p_processed_assignment_id_o
      => per_bba_shd.g_old_rec.processed_assignment_id,
      p_business_group_id_o
      => per_bba_shd.g_old_rec.business_group_id,
      p_ytd_amount_o
      => per_bba_shd.g_old_rec.ytd_amount,
      p_fytd_amount_o
      => per_bba_shd.g_old_rec.fytd_amount,
      p_ptd_amount_o
      => per_bba_shd.g_old_rec.ptd_amount,
      p_mtd_amount_o
      => per_bba_shd.g_old_rec.mtd_amount,
      p_qtd_amount_o
      => per_bba_shd.g_old_rec.qtd_amount,
      p_run_amount_o
      => per_bba_shd.g_old_rec.run_amount,
      p_object_version_number_o
      => per_bba_shd.g_old_rec.object_version_number,
       p_bba_attribute_category_o
      => per_bba_shd.g_old_rec.bba_attribute_category,
      p_bba_attribute1_o
      => per_bba_shd.g_old_rec.bba_attribute1,
      p_bba_attribute2_o
      => per_bba_shd.g_old_rec.bba_attribute2,
      p_bba_attribute3_o
      => per_bba_shd.g_old_rec.bba_attribute3,
      p_bba_attribute4_o
      => per_bba_shd.g_old_rec.bba_attribute4,
      p_bba_attribute5_o
      => per_bba_shd.g_old_rec.bba_attribute5,
      p_bba_attribute6_o
      => per_bba_shd.g_old_rec.bba_attribute6,
      p_bba_attribute7_o
      => per_bba_shd.g_old_rec.bba_attribute7,
      p_bba_attribute8_o
      => per_bba_shd.g_old_rec.bba_attribute8,
      p_bba_attribute9_o
      => per_bba_shd.g_old_rec.bba_attribute9,
      p_bba_attribute10_o
      => per_bba_shd.g_old_rec.bba_attribute10,
      p_bba_attribute11_o
      => per_bba_shd.g_old_rec.bba_attribute11,
      p_bba_attribute12_o
      => per_bba_shd.g_old_rec.bba_attribute12,
      p_bba_attribute13_o
      => per_bba_shd.g_old_rec.bba_attribute13,
      p_bba_attribute14_o
      => per_bba_shd.g_old_rec.bba_attribute14,
      p_bba_attribute15_o
      => per_bba_shd.g_old_rec.bba_attribute15,
      p_bba_attribute16_o
      => per_bba_shd.g_old_rec.bba_attribute16,
      p_bba_attribute17_o
      => per_bba_shd.g_old_rec.bba_attribute17,
      p_bba_attribute18_o
      => per_bba_shd.g_old_rec.bba_attribute18,
      p_bba_attribute19_o
      => per_bba_shd.g_old_rec.bba_attribute19,
      p_bba_attribute20_o
      => per_bba_shd.g_old_rec.bba_attribute20,
      p_bba_attribute21_o
      => per_bba_shd.g_old_rec.bba_attribute21,
      p_bba_attribute22_o
      => per_bba_shd.g_old_rec.bba_attribute22,
      p_bba_attribute23_o
      => per_bba_shd.g_old_rec.bba_attribute23,
      p_bba_attribute24_o
      => per_bba_shd.g_old_rec.bba_attribute24,
      p_bba_attribute25_o
      => per_bba_shd.g_old_rec.bba_attribute25,
      p_bba_attribute26_o
      => per_bba_shd.g_old_rec.bba_attribute26,
      p_bba_attribute27_o
      => per_bba_shd.g_old_rec.bba_attribute27,
      p_bba_attribute28_o
      => per_bba_shd.g_old_rec.bba_attribute28,
      p_bba_attribute29_o
      => per_bba_shd.g_old_rec.bba_attribute29,
      p_bba_attribute30_o
      => per_bba_shd.g_old_rec.bba_attribute30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_BF_BALANCE_AMOUNTS'
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
Procedure convert_defs(p_rec in out nocopy per_bba_shd.g_rec_type) is
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
  If (p_rec.balance_type_id = hr_api.g_number) then
    p_rec.balance_type_id :=
    per_bba_shd.g_old_rec.balance_type_id;
  End If;
  If (p_rec.processed_assignment_id = hr_api.g_number) then
    p_rec.processed_assignment_id :=
    per_bba_shd.g_old_rec.processed_assignment_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    per_bba_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.ytd_amount = hr_api.g_number) then
    p_rec.ytd_amount :=
    per_bba_shd.g_old_rec.ytd_amount;
  End If;
  If (p_rec.fytd_amount = hr_api.g_number) then
    p_rec.fytd_amount :=
    per_bba_shd.g_old_rec.fytd_amount;
  End If;
  If (p_rec.ptd_amount = hr_api.g_number) then
    p_rec.ptd_amount :=
    per_bba_shd.g_old_rec.ptd_amount;
  End If;
  If (p_rec.mtd_amount = hr_api.g_number) then
    p_rec.mtd_amount :=
    per_bba_shd.g_old_rec.mtd_amount;
  End If;
  If (p_rec.qtd_amount = hr_api.g_number) then
    p_rec.qtd_amount :=
    per_bba_shd.g_old_rec.qtd_amount;
  End If;
  If (p_rec.run_amount = hr_api.g_number) then
    p_rec.run_amount :=
    per_bba_shd.g_old_rec.run_amount;
  End If;
  If (p_rec.bba_attribute_category = hr_api.g_varchar2) then
    p_rec.bba_attribute_category :=
    per_bba_shd.g_old_rec.bba_attribute_category;
  End If;
  If (p_rec.bba_attribute1 = hr_api.g_varchar2) then
    p_rec.bba_attribute1:=
    per_bba_shd.g_old_rec.bba_attribute1;
End If;
  If (p_rec.bba_attribute2 = hr_api.g_varchar2) then
    p_rec.bba_attribute2:=
    per_bba_shd.g_old_rec.bba_attribute2;
  End If;
  If (p_rec.bba_attribute3 = hr_api.g_varchar2) then
    p_rec.bba_attribute3:=
    per_bba_shd.g_old_rec.bba_attribute3;
  End If;
  If (p_rec.bba_attribute4 = hr_api.g_varchar2) then
    p_rec.bba_attribute4:=
    per_bba_shd.g_old_rec.bba_attribute4;
  End If;
  If (p_rec.bba_attribute5 = hr_api.g_varchar2) then
    p_rec.bba_attribute5:=
    per_bba_shd.g_old_rec.bba_attribute5;
  End If;
  If (p_rec.bba_attribute6 = hr_api.g_varchar2) then
    p_rec.bba_attribute6:=
    per_bba_shd.g_old_rec.bba_attribute6;
  End If;
  If (p_rec.bba_attribute7 = hr_api.g_varchar2) then
    p_rec.bba_attribute7:=
    per_bba_shd.g_old_rec.bba_attribute7;
  End If;
  If (p_rec.bba_attribute8 = hr_api.g_varchar2) then
    p_rec.bba_attribute8:=
    per_bba_shd.g_old_rec.bba_attribute8;
  End If;
  If (p_rec.bba_attribute9 = hr_api.g_varchar2) then
    p_rec.bba_attribute9:=
    per_bba_shd.g_old_rec.bba_attribute9;
  End If;
  If (p_rec.bba_attribute10 = hr_api.g_varchar2) then
    p_rec.bba_attribute10:=
    per_bba_shd.g_old_rec.bba_attribute10;
  End If;
  If (p_rec.bba_attribute11 = hr_api.g_varchar2) then
    p_rec.bba_attribute11:=
    per_bba_shd.g_old_rec.bba_attribute11;
  End If;
  If (p_rec.bba_attribute12 = hr_api.g_varchar2) then
    p_rec.bba_attribute12:=
    per_bba_shd.g_old_rec.bba_attribute12;
  End If;
  If (p_rec.bba_attribute13 = hr_api.g_varchar2) then
    p_rec.bba_attribute13:=
    per_bba_shd.g_old_rec.bba_attribute13;
  End If;
  If (p_rec.bba_attribute14 = hr_api.g_varchar2) then
    p_rec.bba_attribute14:=
    per_bba_shd.g_old_rec.bba_attribute14;
  End If;
  If (p_rec.bba_attribute15 = hr_api.g_varchar2) then
    p_rec.bba_attribute15:=
    per_bba_shd.g_old_rec.bba_attribute15;
  End If;
  If (p_rec.bba_attribute16 = hr_api.g_varchar2) then
    p_rec.bba_attribute16:=
    per_bba_shd.g_old_rec.bba_attribute16;
  End If;
  If (p_rec.bba_attribute17 = hr_api.g_varchar2) then
    p_rec.bba_attribute17:=
    per_bba_shd.g_old_rec.bba_attribute17;
  End If;
  If (p_rec.bba_attribute18 = hr_api.g_varchar2) then
    p_rec.bba_attribute18:=
    per_bba_shd.g_old_rec.bba_attribute18;
  End If;
  If (p_rec.bba_attribute19 = hr_api.g_varchar2) then
    p_rec.bba_attribute19:=
    per_bba_shd.g_old_rec.bba_attribute19;
  End If;
  If (p_rec.bba_attribute20 = hr_api.g_varchar2) then
    p_rec.bba_attribute20:=
    per_bba_shd.g_old_rec.bba_attribute20;
  End If;
  If (p_rec.bba_attribute21 = hr_api.g_varchar2) then
    p_rec.bba_attribute21:=
    per_bba_shd.g_old_rec.bba_attribute21;
   End If;
  If (p_rec.bba_attribute22 = hr_api.g_varchar2) then
    p_rec.bba_attribute22:=
    per_bba_shd.g_old_rec.bba_attribute22;
  End If;
  If (p_rec.bba_attribute23 = hr_api.g_varchar2) then
    p_rec.bba_attribute23:=
    per_bba_shd.g_old_rec.bba_attribute23;
  End If;
  If (p_rec.bba_attribute24 = hr_api.g_varchar2) then
    p_rec.bba_attribute24:=
    per_bba_shd.g_old_rec.bba_attribute24;
  End If;
  If (p_rec.bba_attribute25 = hr_api.g_varchar2) then
    p_rec.bba_attribute25:=
    per_bba_shd.g_old_rec.bba_attribute25;
  End If;
  If (p_rec.bba_attribute26 = hr_api.g_varchar2) then
    p_rec.bba_attribute26:=
    per_bba_shd.g_old_rec.bba_attribute26;
  End If;
  If (p_rec.bba_attribute27 = hr_api.g_varchar2) then
    p_rec.bba_attribute27:=
    per_bba_shd.g_old_rec.bba_attribute27;
  End If;
  If (p_rec.bba_attribute28 = hr_api.g_varchar2) then
    p_rec.bba_attribute28:=
    per_bba_shd.g_old_rec.bba_attribute28;
  End If;
  If (p_rec.bba_attribute29 = hr_api.g_varchar2) then
    p_rec.bba_attribute29:=
    per_bba_shd.g_old_rec.bba_attribute29;
  End If;
  If (p_rec.bba_attribute30 = hr_api.g_varchar2) then
    p_rec.bba_attribute30:=
    per_bba_shd.g_old_rec.bba_attribute30;
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
  p_rec        in out nocopy per_bba_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_bba_shd.lck
    (
      p_rec.balance_amount_id,
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
  per_bba_bus.update_validate(p_effective_date,
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
  post_update(p_effective_date,
                             p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
   p_effective_date   in  date,
  p_balance_amount_id            in number,
  p_ytd_amount                   in number         default hr_api.g_number,
  p_fytd_amount                  in number         default hr_api.g_number,
  p_ptd_amount                   in number         default hr_api.g_number,
  p_mtd_amount                   in number         default hr_api.g_number,
  p_qtd_amount                   in number         default hr_api.g_number,
  p_run_amount                   in number         default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_bba_attribute_category       in varchar2       default hr_api.g_varchar2,
  p_bba_attribute1               in varchar2       default hr_api.g_varchar2,
  p_bba_attribute2               in varchar2       default hr_api.g_varchar2,
  p_bba_attribute3               in varchar2       default hr_api.g_varchar2,
  p_bba_attribute4               in varchar2       default hr_api.g_varchar2,
  p_bba_attribute5               in varchar2       default hr_api.g_varchar2,
  p_bba_attribute6               in varchar2       default hr_api.g_varchar2,
  p_bba_attribute7               in varchar2       default hr_api.g_varchar2,
  p_bba_attribute8               in varchar2       default hr_api.g_varchar2,
  p_bba_attribute9               in varchar2       default hr_api.g_varchar2,
  p_bba_attribute10              in varchar2       default hr_api.g_varchar2,
  p_bba_attribute11              in varchar2       default hr_api.g_varchar2,
  p_bba_attribute12              in varchar2       default hr_api.g_varchar2,
  p_bba_attribute13              in varchar2       default hr_api.g_varchar2,
  p_bba_attribute14              in varchar2       default hr_api.g_varchar2,
  p_bba_attribute15              in varchar2       default hr_api.g_varchar2,
  p_bba_attribute16              in varchar2       default hr_api.g_varchar2,
  p_bba_attribute17              in varchar2       default hr_api.g_varchar2,
  p_bba_attribute18              in varchar2       default hr_api.g_varchar2,
  p_bba_attribute19              in varchar2       default hr_api.g_varchar2,
  p_bba_attribute20              in varchar2       default hr_api.g_varchar2,
  p_bba_attribute21              in varchar2       default hr_api.g_varchar2,
  p_bba_attribute22              in varchar2       default hr_api.g_varchar2,
  p_bba_attribute23              in varchar2       default hr_api.g_varchar2,
  p_bba_attribute24              in varchar2       default hr_api.g_varchar2,
  p_bba_attribute25              in varchar2       default hr_api.g_varchar2,
  p_bba_attribute26              in varchar2       default hr_api.g_varchar2,
  p_bba_attribute27              in varchar2       default hr_api.g_varchar2,
  p_bba_attribute28              in varchar2       default hr_api.g_varchar2,
  p_bba_attribute29              in varchar2       default hr_api.g_varchar2,
  p_bba_attribute30              in varchar2       default hr_api.g_varchar2
  ) is
--
  l_rec	  per_bba_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_bba_shd.convert_args
  (
  p_balance_amount_id,
  hr_api.g_number,
  hr_api.g_number,
  hr_api.g_number,
  p_ytd_amount,
  p_fytd_amount,
  p_ptd_amount,
  p_mtd_amount,
  p_qtd_amount,
  p_run_amount,
  p_object_version_number,
  p_bba_attribute_category,
  p_bba_attribute1,
  p_bba_attribute2,
  p_bba_attribute3,
  p_bba_attribute4,
  p_bba_attribute5,
  p_bba_attribute6,
  p_bba_attribute7,
  p_bba_attribute8,
  p_bba_attribute9,
  p_bba_attribute10,
  p_bba_attribute11,
  p_bba_attribute12,
  p_bba_attribute13,
  p_bba_attribute14,
  p_bba_attribute15,
  p_bba_attribute16,
  p_bba_attribute17,
  p_bba_attribute18,
  p_bba_attribute19,
  p_bba_attribute20,
  p_bba_attribute21,
  p_bba_attribute22,
  p_bba_attribute23,
  p_bba_attribute24,
  p_bba_attribute25,
  p_bba_attribute26,
  p_bba_attribute27,
  p_bba_attribute28,
  p_bba_attribute29,
  p_bba_attribute30
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
end per_bba_upd;

/

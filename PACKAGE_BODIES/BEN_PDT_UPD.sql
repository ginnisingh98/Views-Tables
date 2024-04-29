--------------------------------------------------------
--  DDL for Package Body BEN_PDT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PDT_UPD" as
/* $Header: bepdtrhi.pkb 115.0 2003/10/30 09:33 rpillay noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_pdt_upd.';  -- Global package name
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
  (p_rec in out nocopy ben_pdt_shd.g_rec_type
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
  -- Update the ben_pymt_check_det Row
  --
  update ben_pymt_check_det
    set
     pymt_check_det_id               = p_rec.pymt_check_det_id
    ,person_id                       = p_rec.person_id
    ,business_group_id               = p_rec.business_group_id
    ,check_num                       = p_rec.check_num
    ,pymt_dt                         = p_rec.pymt_dt
    ,pymt_amt                        = p_rec.pymt_amt
    ,pdt_attribute_category          = p_rec.pdt_attribute_category
    ,pdt_attribute1                  = p_rec.pdt_attribute1
    ,pdt_attribute2                  = p_rec.pdt_attribute2
    ,pdt_attribute3                  = p_rec.pdt_attribute3
    ,pdt_attribute4                  = p_rec.pdt_attribute4
    ,pdt_attribute5                  = p_rec.pdt_attribute5
    ,pdt_attribute6                  = p_rec.pdt_attribute6
    ,pdt_attribute7                  = p_rec.pdt_attribute7
    ,pdt_attribute8                  = p_rec.pdt_attribute8
    ,pdt_attribute9                  = p_rec.pdt_attribute9
    ,pdt_attribute10                 = p_rec.pdt_attribute10
    ,pdt_attribute11                 = p_rec.pdt_attribute11
    ,pdt_attribute12                 = p_rec.pdt_attribute12
    ,pdt_attribute13                 = p_rec.pdt_attribute13
    ,pdt_attribute14                 = p_rec.pdt_attribute14
    ,pdt_attribute15                 = p_rec.pdt_attribute15
    ,pdt_attribute16                 = p_rec.pdt_attribute16
    ,pdt_attribute17                 = p_rec.pdt_attribute17
    ,pdt_attribute18                 = p_rec.pdt_attribute18
    ,pdt_attribute19                 = p_rec.pdt_attribute19
    ,pdt_attribute20                 = p_rec.pdt_attribute20
    ,pdt_attribute21                 = p_rec.pdt_attribute21
    ,pdt_attribute22                 = p_rec.pdt_attribute22
    ,pdt_attribute23                 = p_rec.pdt_attribute23
    ,pdt_attribute24                 = p_rec.pdt_attribute24
    ,pdt_attribute25                 = p_rec.pdt_attribute25
    ,pdt_attribute26                 = p_rec.pdt_attribute26
    ,pdt_attribute27                 = p_rec.pdt_attribute27
    ,pdt_attribute28                 = p_rec.pdt_attribute28
    ,pdt_attribute29                 = p_rec.pdt_attribute29
    ,pdt_attribute30                 = p_rec.pdt_attribute30
    ,object_version_number           = p_rec.object_version_number
    where pymt_check_det_id = p_rec.pymt_check_det_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    ben_pdt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ben_pdt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ben_pdt_shd.constraint_error
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
  (p_rec in ben_pdt_shd.g_rec_type
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
  ,p_rec                          in ben_pdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ben_pdt_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_pymt_check_det_id
      => p_rec.pymt_check_det_id
      ,p_person_id
      => p_rec.person_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_check_num
      => p_rec.check_num
      ,p_pymt_dt
      => p_rec.pymt_dt
      ,p_pymt_amt
      => p_rec.pymt_amt
      ,p_pdt_attribute_category
      => p_rec.pdt_attribute_category
      ,p_pdt_attribute1
      => p_rec.pdt_attribute1
      ,p_pdt_attribute2
      => p_rec.pdt_attribute2
      ,p_pdt_attribute3
      => p_rec.pdt_attribute3
      ,p_pdt_attribute4
      => p_rec.pdt_attribute4
      ,p_pdt_attribute5
      => p_rec.pdt_attribute5
      ,p_pdt_attribute6
      => p_rec.pdt_attribute6
      ,p_pdt_attribute7
      => p_rec.pdt_attribute7
      ,p_pdt_attribute8
      => p_rec.pdt_attribute8
      ,p_pdt_attribute9
      => p_rec.pdt_attribute9
      ,p_pdt_attribute10
      => p_rec.pdt_attribute10
      ,p_pdt_attribute11
      => p_rec.pdt_attribute11
      ,p_pdt_attribute12
      => p_rec.pdt_attribute12
      ,p_pdt_attribute13
      => p_rec.pdt_attribute13
      ,p_pdt_attribute14
      => p_rec.pdt_attribute14
      ,p_pdt_attribute15
      => p_rec.pdt_attribute15
      ,p_pdt_attribute16
      => p_rec.pdt_attribute16
      ,p_pdt_attribute17
      => p_rec.pdt_attribute17
      ,p_pdt_attribute18
      => p_rec.pdt_attribute18
      ,p_pdt_attribute19
      => p_rec.pdt_attribute19
      ,p_pdt_attribute20
      => p_rec.pdt_attribute20
      ,p_pdt_attribute21
      => p_rec.pdt_attribute21
      ,p_pdt_attribute22
      => p_rec.pdt_attribute22
      ,p_pdt_attribute23
      => p_rec.pdt_attribute23
      ,p_pdt_attribute24
      => p_rec.pdt_attribute24
      ,p_pdt_attribute25
      => p_rec.pdt_attribute25
      ,p_pdt_attribute26
      => p_rec.pdt_attribute26
      ,p_pdt_attribute27
      => p_rec.pdt_attribute27
      ,p_pdt_attribute28
      => p_rec.pdt_attribute28
      ,p_pdt_attribute29
      => p_rec.pdt_attribute29
      ,p_pdt_attribute30
      => p_rec.pdt_attribute30
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_person_id_o
      => ben_pdt_shd.g_old_rec.person_id
      ,p_business_group_id_o
      => ben_pdt_shd.g_old_rec.business_group_id
      ,p_check_num_o
      => ben_pdt_shd.g_old_rec.check_num
      ,p_pymt_dt_o
      => ben_pdt_shd.g_old_rec.pymt_dt
      ,p_pymt_amt_o
      => ben_pdt_shd.g_old_rec.pymt_amt
      ,p_pdt_attribute_category_o
      => ben_pdt_shd.g_old_rec.pdt_attribute_category
      ,p_pdt_attribute1_o
      => ben_pdt_shd.g_old_rec.pdt_attribute1
      ,p_pdt_attribute2_o
      => ben_pdt_shd.g_old_rec.pdt_attribute2
      ,p_pdt_attribute3_o
      => ben_pdt_shd.g_old_rec.pdt_attribute3
      ,p_pdt_attribute4_o
      => ben_pdt_shd.g_old_rec.pdt_attribute4
      ,p_pdt_attribute5_o
      => ben_pdt_shd.g_old_rec.pdt_attribute5
      ,p_pdt_attribute6_o
      => ben_pdt_shd.g_old_rec.pdt_attribute6
      ,p_pdt_attribute7_o
      => ben_pdt_shd.g_old_rec.pdt_attribute7
      ,p_pdt_attribute8_o
      => ben_pdt_shd.g_old_rec.pdt_attribute8
      ,p_pdt_attribute9_o
      => ben_pdt_shd.g_old_rec.pdt_attribute9
      ,p_pdt_attribute10_o
      => ben_pdt_shd.g_old_rec.pdt_attribute10
      ,p_pdt_attribute11_o
      => ben_pdt_shd.g_old_rec.pdt_attribute11
      ,p_pdt_attribute12_o
      => ben_pdt_shd.g_old_rec.pdt_attribute12
      ,p_pdt_attribute13_o
      => ben_pdt_shd.g_old_rec.pdt_attribute13
      ,p_pdt_attribute14_o
      => ben_pdt_shd.g_old_rec.pdt_attribute14
      ,p_pdt_attribute15_o
      => ben_pdt_shd.g_old_rec.pdt_attribute15
      ,p_pdt_attribute16_o
      => ben_pdt_shd.g_old_rec.pdt_attribute16
      ,p_pdt_attribute17_o
      => ben_pdt_shd.g_old_rec.pdt_attribute17
      ,p_pdt_attribute18_o
      => ben_pdt_shd.g_old_rec.pdt_attribute18
      ,p_pdt_attribute19_o
      => ben_pdt_shd.g_old_rec.pdt_attribute19
      ,p_pdt_attribute20_o
      => ben_pdt_shd.g_old_rec.pdt_attribute20
      ,p_pdt_attribute21_o
      => ben_pdt_shd.g_old_rec.pdt_attribute21
      ,p_pdt_attribute22_o
      => ben_pdt_shd.g_old_rec.pdt_attribute22
      ,p_pdt_attribute23_o
      => ben_pdt_shd.g_old_rec.pdt_attribute23
      ,p_pdt_attribute24_o
      => ben_pdt_shd.g_old_rec.pdt_attribute24
      ,p_pdt_attribute25_o
      => ben_pdt_shd.g_old_rec.pdt_attribute25
      ,p_pdt_attribute26_o
      => ben_pdt_shd.g_old_rec.pdt_attribute26
      ,p_pdt_attribute27_o
      => ben_pdt_shd.g_old_rec.pdt_attribute27
      ,p_pdt_attribute28_o
      => ben_pdt_shd.g_old_rec.pdt_attribute28
      ,p_pdt_attribute29_o
      => ben_pdt_shd.g_old_rec.pdt_attribute29
      ,p_pdt_attribute30_o
      => ben_pdt_shd.g_old_rec.pdt_attribute30
      ,p_object_version_number_o
      => ben_pdt_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_PYMT_CHECK_DET'
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
  (p_rec in out nocopy ben_pdt_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    ben_pdt_shd.g_old_rec.person_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_pdt_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.check_num = hr_api.g_varchar2) then
    p_rec.check_num :=
    ben_pdt_shd.g_old_rec.check_num;
  End If;
  If (p_rec.pymt_dt = hr_api.g_date) then
    p_rec.pymt_dt :=
    ben_pdt_shd.g_old_rec.pymt_dt;
  End If;
  If (p_rec.pymt_amt = hr_api.g_number) then
    p_rec.pymt_amt :=
    ben_pdt_shd.g_old_rec.pymt_amt;
  End If;
  If (p_rec.pdt_attribute_category = hr_api.g_varchar2) then
    p_rec.pdt_attribute_category :=
    ben_pdt_shd.g_old_rec.pdt_attribute_category;
  End If;
  If (p_rec.pdt_attribute1 = hr_api.g_varchar2) then
    p_rec.pdt_attribute1 :=
    ben_pdt_shd.g_old_rec.pdt_attribute1;
  End If;
  If (p_rec.pdt_attribute2 = hr_api.g_varchar2) then
    p_rec.pdt_attribute2 :=
    ben_pdt_shd.g_old_rec.pdt_attribute2;
  End If;
  If (p_rec.pdt_attribute3 = hr_api.g_varchar2) then
    p_rec.pdt_attribute3 :=
    ben_pdt_shd.g_old_rec.pdt_attribute3;
  End If;
  If (p_rec.pdt_attribute4 = hr_api.g_varchar2) then
    p_rec.pdt_attribute4 :=
    ben_pdt_shd.g_old_rec.pdt_attribute4;
  End If;
  If (p_rec.pdt_attribute5 = hr_api.g_varchar2) then
    p_rec.pdt_attribute5 :=
    ben_pdt_shd.g_old_rec.pdt_attribute5;
  End If;
  If (p_rec.pdt_attribute6 = hr_api.g_varchar2) then
    p_rec.pdt_attribute6 :=
    ben_pdt_shd.g_old_rec.pdt_attribute6;
  End If;
  If (p_rec.pdt_attribute7 = hr_api.g_varchar2) then
    p_rec.pdt_attribute7 :=
    ben_pdt_shd.g_old_rec.pdt_attribute7;
  End If;
  If (p_rec.pdt_attribute8 = hr_api.g_varchar2) then
    p_rec.pdt_attribute8 :=
    ben_pdt_shd.g_old_rec.pdt_attribute8;
  End If;
  If (p_rec.pdt_attribute9 = hr_api.g_varchar2) then
    p_rec.pdt_attribute9 :=
    ben_pdt_shd.g_old_rec.pdt_attribute9;
  End If;
  If (p_rec.pdt_attribute10 = hr_api.g_varchar2) then
    p_rec.pdt_attribute10 :=
    ben_pdt_shd.g_old_rec.pdt_attribute10;
  End If;
  If (p_rec.pdt_attribute11 = hr_api.g_varchar2) then
    p_rec.pdt_attribute11 :=
    ben_pdt_shd.g_old_rec.pdt_attribute11;
  End If;
  If (p_rec.pdt_attribute12 = hr_api.g_varchar2) then
    p_rec.pdt_attribute12 :=
    ben_pdt_shd.g_old_rec.pdt_attribute12;
  End If;
  If (p_rec.pdt_attribute13 = hr_api.g_varchar2) then
    p_rec.pdt_attribute13 :=
    ben_pdt_shd.g_old_rec.pdt_attribute13;
  End If;
  If (p_rec.pdt_attribute14 = hr_api.g_varchar2) then
    p_rec.pdt_attribute14 :=
    ben_pdt_shd.g_old_rec.pdt_attribute14;
  End If;
  If (p_rec.pdt_attribute15 = hr_api.g_varchar2) then
    p_rec.pdt_attribute15 :=
    ben_pdt_shd.g_old_rec.pdt_attribute15;
  End If;
  If (p_rec.pdt_attribute16 = hr_api.g_varchar2) then
    p_rec.pdt_attribute16 :=
    ben_pdt_shd.g_old_rec.pdt_attribute16;
  End If;
  If (p_rec.pdt_attribute17 = hr_api.g_varchar2) then
    p_rec.pdt_attribute17 :=
    ben_pdt_shd.g_old_rec.pdt_attribute17;
  End If;
  If (p_rec.pdt_attribute18 = hr_api.g_varchar2) then
    p_rec.pdt_attribute18 :=
    ben_pdt_shd.g_old_rec.pdt_attribute18;
  End If;
  If (p_rec.pdt_attribute19 = hr_api.g_varchar2) then
    p_rec.pdt_attribute19 :=
    ben_pdt_shd.g_old_rec.pdt_attribute19;
  End If;
  If (p_rec.pdt_attribute20 = hr_api.g_varchar2) then
    p_rec.pdt_attribute20 :=
    ben_pdt_shd.g_old_rec.pdt_attribute20;
  End If;
  If (p_rec.pdt_attribute21 = hr_api.g_varchar2) then
    p_rec.pdt_attribute21 :=
    ben_pdt_shd.g_old_rec.pdt_attribute21;
  End If;
  If (p_rec.pdt_attribute22 = hr_api.g_varchar2) then
    p_rec.pdt_attribute22 :=
    ben_pdt_shd.g_old_rec.pdt_attribute22;
  End If;
  If (p_rec.pdt_attribute23 = hr_api.g_varchar2) then
    p_rec.pdt_attribute23 :=
    ben_pdt_shd.g_old_rec.pdt_attribute23;
  End If;
  If (p_rec.pdt_attribute24 = hr_api.g_varchar2) then
    p_rec.pdt_attribute24 :=
    ben_pdt_shd.g_old_rec.pdt_attribute24;
  End If;
  If (p_rec.pdt_attribute25 = hr_api.g_varchar2) then
    p_rec.pdt_attribute25 :=
    ben_pdt_shd.g_old_rec.pdt_attribute25;
  End If;
  If (p_rec.pdt_attribute26 = hr_api.g_varchar2) then
    p_rec.pdt_attribute26 :=
    ben_pdt_shd.g_old_rec.pdt_attribute26;
  End If;
  If (p_rec.pdt_attribute27 = hr_api.g_varchar2) then
    p_rec.pdt_attribute27 :=
    ben_pdt_shd.g_old_rec.pdt_attribute27;
  End If;
  If (p_rec.pdt_attribute28 = hr_api.g_varchar2) then
    p_rec.pdt_attribute28 :=
    ben_pdt_shd.g_old_rec.pdt_attribute28;
  End If;
  If (p_rec.pdt_attribute29 = hr_api.g_varchar2) then
    p_rec.pdt_attribute29 :=
    ben_pdt_shd.g_old_rec.pdt_attribute29;
  End If;
  If (p_rec.pdt_attribute30 = hr_api.g_varchar2) then
    p_rec.pdt_attribute30 :=
    ben_pdt_shd.g_old_rec.pdt_attribute30;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy ben_pdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ben_pdt_shd.lck
    (p_rec.pymt_check_det_id
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
  ben_pdt_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  ben_pdt_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  ben_pdt_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  ben_pdt_upd.post_update
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_pymt_check_det_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_check_num                    in     varchar2  default hr_api.g_varchar2
  ,p_pymt_dt                      in     date      default hr_api.g_date
  ,p_pymt_amt                     in     number    default hr_api.g_number
  ,p_pdt_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_pdt_attribute30              in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   ben_pdt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_pdt_shd.convert_args
  (p_pymt_check_det_id
  ,p_person_id
  ,p_business_group_id
  ,p_check_num
  ,p_pymt_dt
  ,p_pymt_amt
  ,p_pdt_attribute_category
  ,p_pdt_attribute1
  ,p_pdt_attribute2
  ,p_pdt_attribute3
  ,p_pdt_attribute4
  ,p_pdt_attribute5
  ,p_pdt_attribute6
  ,p_pdt_attribute7
  ,p_pdt_attribute8
  ,p_pdt_attribute9
  ,p_pdt_attribute10
  ,p_pdt_attribute11
  ,p_pdt_attribute12
  ,p_pdt_attribute13
  ,p_pdt_attribute14
  ,p_pdt_attribute15
  ,p_pdt_attribute16
  ,p_pdt_attribute17
  ,p_pdt_attribute18
  ,p_pdt_attribute19
  ,p_pdt_attribute20
  ,p_pdt_attribute21
  ,p_pdt_attribute22
  ,p_pdt_attribute23
  ,p_pdt_attribute24
  ,p_pdt_attribute25
  ,p_pdt_attribute26
  ,p_pdt_attribute27
  ,p_pdt_attribute28
  ,p_pdt_attribute29
  ,p_pdt_attribute30
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ben_pdt_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_pdt_upd;

/

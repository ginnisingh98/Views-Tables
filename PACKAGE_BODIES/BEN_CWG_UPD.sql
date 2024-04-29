--------------------------------------------------------
--  DDL for Package Body BEN_CWG_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWG_UPD" as
/* $Header: becwgrhi.pkb 120.0 2005/05/28 01:29:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cwg_upd.';  -- Global package name
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
  (p_rec in out nocopy ben_cwg_shd.g_rec_type
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
  -- Update the ben_cwb_wksht_grp Row
  --
  update ben_cwb_wksht_grp
    set
     cwb_wksht_grp_id                = p_rec.cwb_wksht_grp_id
    ,ordr_num                        = p_rec.ordr_num
    ,wksht_grp_cd                    = p_rec.wksht_grp_cd
    ,label                           = p_rec.label
    ,cwg_attribute_category          = p_rec.cwg_attribute_category
    ,cwg_attribute1                  = p_rec.cwg_attribute1
    ,cwg_attribute2                  = p_rec.cwg_attribute2
    ,cwg_attribute3                  = p_rec.cwg_attribute3
    ,cwg_attribute4                  = p_rec.cwg_attribute4
    ,cwg_attribute5                  = p_rec.cwg_attribute5
    ,cwg_attribute6                  = p_rec.cwg_attribute6
    ,cwg_attribute7                  = p_rec.cwg_attribute7
    ,cwg_attribute8                  = p_rec.cwg_attribute8
    ,cwg_attribute9                  = p_rec.cwg_attribute9
    ,cwg_attribute10                 = p_rec.cwg_attribute10
    ,cwg_attribute11                 = p_rec.cwg_attribute11
    ,cwg_attribute12                 = p_rec.cwg_attribute12
    ,cwg_attribute13                 = p_rec.cwg_attribute13
    ,cwg_attribute14                 = p_rec.cwg_attribute14
    ,cwg_attribute15                 = p_rec.cwg_attribute15
    ,cwg_attribute16                 = p_rec.cwg_attribute16
    ,cwg_attribute17                 = p_rec.cwg_attribute17
    ,cwg_attribute18                 = p_rec.cwg_attribute18
    ,cwg_attribute19                 = p_rec.cwg_attribute19
    ,cwg_attribute20                 = p_rec.cwg_attribute20
    ,cwg_attribute21                 = p_rec.cwg_attribute21
    ,cwg_attribute22                 = p_rec.cwg_attribute22
    ,cwg_attribute23                 = p_rec.cwg_attribute23
    ,cwg_attribute24                 = p_rec.cwg_attribute24
    ,cwg_attribute25                 = p_rec.cwg_attribute25
    ,cwg_attribute26                 = p_rec.cwg_attribute26
    ,cwg_attribute27                 = p_rec.cwg_attribute27
    ,cwg_attribute28                 = p_rec.cwg_attribute28
    ,cwg_attribute29                 = p_rec.cwg_attribute29
    ,cwg_attribute30                 = p_rec.cwg_attribute30
    ,status_cd                       = p_rec.status_cd
    ,hidden_cd                     = p_rec.hidden_cd
    ,object_version_number           = p_rec.object_version_number
    where cwb_wksht_grp_id = p_rec.cwb_wksht_grp_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    ben_cwg_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ben_cwg_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ben_cwg_shd.constraint_error
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
  (p_rec in ben_cwg_shd.g_rec_type
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
  ,p_rec                          in ben_cwg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ben_cwg_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_cwb_wksht_grp_id
      => p_rec.cwb_wksht_grp_id
      ,p_ordr_num
      => p_rec.ordr_num
      ,p_wksht_grp_cd
      => p_rec.wksht_grp_cd
      ,p_label
      => p_rec.label
      ,p_cwg_attribute_category
      => p_rec.cwg_attribute_category
      ,p_cwg_attribute1
      => p_rec.cwg_attribute1
      ,p_cwg_attribute2
      => p_rec.cwg_attribute2
      ,p_cwg_attribute3
      => p_rec.cwg_attribute3
      ,p_cwg_attribute4
      => p_rec.cwg_attribute4
      ,p_cwg_attribute5
      => p_rec.cwg_attribute5
      ,p_cwg_attribute6
      => p_rec.cwg_attribute6
      ,p_cwg_attribute7
      => p_rec.cwg_attribute7
      ,p_cwg_attribute8
      => p_rec.cwg_attribute8
      ,p_cwg_attribute9
      => p_rec.cwg_attribute9
      ,p_cwg_attribute10
      => p_rec.cwg_attribute10
      ,p_cwg_attribute11
      => p_rec.cwg_attribute11
      ,p_cwg_attribute12
      => p_rec.cwg_attribute12
      ,p_cwg_attribute13
      => p_rec.cwg_attribute13
      ,p_cwg_attribute14
      => p_rec.cwg_attribute14
      ,p_cwg_attribute15
      => p_rec.cwg_attribute15
      ,p_cwg_attribute16
      => p_rec.cwg_attribute16
      ,p_cwg_attribute17
      => p_rec.cwg_attribute17
      ,p_cwg_attribute18
      => p_rec.cwg_attribute18
      ,p_cwg_attribute19
      => p_rec.cwg_attribute19
      ,p_cwg_attribute20
      => p_rec.cwg_attribute20
      ,p_cwg_attribute21
      => p_rec.cwg_attribute21
      ,p_cwg_attribute22
      => p_rec.cwg_attribute22
      ,p_cwg_attribute23
      => p_rec.cwg_attribute23
      ,p_cwg_attribute24
      => p_rec.cwg_attribute24
      ,p_cwg_attribute25
      => p_rec.cwg_attribute25
      ,p_cwg_attribute26
      => p_rec.cwg_attribute26
      ,p_cwg_attribute27
      => p_rec.cwg_attribute27
      ,p_cwg_attribute28
      => p_rec.cwg_attribute28
      ,p_cwg_attribute29
      => p_rec.cwg_attribute29
      ,p_cwg_attribute30 => p_rec.cwg_attribute30
      ,p_status_cd       => p_rec.status_cd
      ,p_hidden_cd      => p_rec.hidden_cd
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_business_group_id_o
      => ben_cwg_shd.g_old_rec.business_group_id
      ,p_pl_id_o
      => ben_cwg_shd.g_old_rec.pl_id
      ,p_ordr_num_o
      => ben_cwg_shd.g_old_rec.ordr_num
      ,p_wksht_grp_cd_o
      => ben_cwg_shd.g_old_rec.wksht_grp_cd
      ,p_label_o
      => ben_cwg_shd.g_old_rec.label
      ,p_cwg_attribute_category_o
      => ben_cwg_shd.g_old_rec.cwg_attribute_category
      ,p_cwg_attribute1_o
      => ben_cwg_shd.g_old_rec.cwg_attribute1
      ,p_cwg_attribute2_o
      => ben_cwg_shd.g_old_rec.cwg_attribute2
      ,p_cwg_attribute3_o
      => ben_cwg_shd.g_old_rec.cwg_attribute3
      ,p_cwg_attribute4_o
      => ben_cwg_shd.g_old_rec.cwg_attribute4
      ,p_cwg_attribute5_o
      => ben_cwg_shd.g_old_rec.cwg_attribute5
      ,p_cwg_attribute6_o
      => ben_cwg_shd.g_old_rec.cwg_attribute6
      ,p_cwg_attribute7_o
      => ben_cwg_shd.g_old_rec.cwg_attribute7
      ,p_cwg_attribute8_o
      => ben_cwg_shd.g_old_rec.cwg_attribute8
      ,p_cwg_attribute9_o
      => ben_cwg_shd.g_old_rec.cwg_attribute9
      ,p_cwg_attribute10_o
      => ben_cwg_shd.g_old_rec.cwg_attribute10
      ,p_cwg_attribute11_o
      => ben_cwg_shd.g_old_rec.cwg_attribute11
      ,p_cwg_attribute12_o
      => ben_cwg_shd.g_old_rec.cwg_attribute12
      ,p_cwg_attribute13_o
      => ben_cwg_shd.g_old_rec.cwg_attribute13
      ,p_cwg_attribute14_o
      => ben_cwg_shd.g_old_rec.cwg_attribute14
      ,p_cwg_attribute15_o
      => ben_cwg_shd.g_old_rec.cwg_attribute15
      ,p_cwg_attribute16_o
      => ben_cwg_shd.g_old_rec.cwg_attribute16
      ,p_cwg_attribute17_o
      => ben_cwg_shd.g_old_rec.cwg_attribute17
      ,p_cwg_attribute18_o
      => ben_cwg_shd.g_old_rec.cwg_attribute18
      ,p_cwg_attribute19_o
      => ben_cwg_shd.g_old_rec.cwg_attribute19
      ,p_cwg_attribute20_o
      => ben_cwg_shd.g_old_rec.cwg_attribute20
      ,p_cwg_attribute21_o
      => ben_cwg_shd.g_old_rec.cwg_attribute21
      ,p_cwg_attribute22_o
      => ben_cwg_shd.g_old_rec.cwg_attribute22
      ,p_cwg_attribute23_o
      => ben_cwg_shd.g_old_rec.cwg_attribute23
      ,p_cwg_attribute24_o
      => ben_cwg_shd.g_old_rec.cwg_attribute24
      ,p_cwg_attribute25_o
      => ben_cwg_shd.g_old_rec.cwg_attribute25
      ,p_cwg_attribute26_o
      => ben_cwg_shd.g_old_rec.cwg_attribute26
      ,p_cwg_attribute27_o
      => ben_cwg_shd.g_old_rec.cwg_attribute27
      ,p_cwg_attribute28_o
      => ben_cwg_shd.g_old_rec.cwg_attribute28
      ,p_cwg_attribute29_o
      => ben_cwg_shd.g_old_rec.cwg_attribute29
      ,p_cwg_attribute30_o => ben_cwg_shd.g_old_rec.cwg_attribute30
      ,p_status_cd_o       =>  ben_cwg_shd.g_old_rec.status_cd
      ,p_hidden_cd_o      => ben_cwg_shd.g_old_rec.hidden_cd
      ,p_object_version_number_o => ben_cwg_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_CWB_WKSHT_GRP'
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
  (p_rec in out nocopy ben_cwg_shd.g_rec_type
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
    ben_cwg_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.pl_id = hr_api.g_number) then
    p_rec.pl_id :=
    ben_cwg_shd.g_old_rec.pl_id;
  End If;
  If (p_rec.ordr_num = hr_api.g_number) then
    p_rec.ordr_num :=
    ben_cwg_shd.g_old_rec.ordr_num;
  End If;
  If (p_rec.wksht_grp_cd = hr_api.g_varchar2) then
    p_rec.wksht_grp_cd :=
    ben_cwg_shd.g_old_rec.wksht_grp_cd;
  End If;
  If (p_rec.label = hr_api.g_varchar2) then
    p_rec.label :=
    ben_cwg_shd.g_old_rec.label;
  End If;
  If (p_rec.cwg_attribute_category = hr_api.g_varchar2) then
    p_rec.cwg_attribute_category :=
    ben_cwg_shd.g_old_rec.cwg_attribute_category;
  End If;
  If (p_rec.cwg_attribute1 = hr_api.g_varchar2) then
    p_rec.cwg_attribute1 :=
    ben_cwg_shd.g_old_rec.cwg_attribute1;
  End If;
  If (p_rec.cwg_attribute2 = hr_api.g_varchar2) then
    p_rec.cwg_attribute2 :=
    ben_cwg_shd.g_old_rec.cwg_attribute2;
  End If;
  If (p_rec.cwg_attribute3 = hr_api.g_varchar2) then
    p_rec.cwg_attribute3 :=
    ben_cwg_shd.g_old_rec.cwg_attribute3;
  End If;
  If (p_rec.cwg_attribute4 = hr_api.g_varchar2) then
    p_rec.cwg_attribute4 :=
    ben_cwg_shd.g_old_rec.cwg_attribute4;
  End If;
  If (p_rec.cwg_attribute5 = hr_api.g_varchar2) then
    p_rec.cwg_attribute5 :=
    ben_cwg_shd.g_old_rec.cwg_attribute5;
  End If;
  If (p_rec.cwg_attribute6 = hr_api.g_varchar2) then
    p_rec.cwg_attribute6 :=
    ben_cwg_shd.g_old_rec.cwg_attribute6;
  End If;
  If (p_rec.cwg_attribute7 = hr_api.g_varchar2) then
    p_rec.cwg_attribute7 :=
    ben_cwg_shd.g_old_rec.cwg_attribute7;
  End If;
  If (p_rec.cwg_attribute8 = hr_api.g_varchar2) then
    p_rec.cwg_attribute8 :=
    ben_cwg_shd.g_old_rec.cwg_attribute8;
  End If;
  If (p_rec.cwg_attribute9 = hr_api.g_varchar2) then
    p_rec.cwg_attribute9 :=
    ben_cwg_shd.g_old_rec.cwg_attribute9;
  End If;
  If (p_rec.cwg_attribute10 = hr_api.g_varchar2) then
    p_rec.cwg_attribute10 :=
    ben_cwg_shd.g_old_rec.cwg_attribute10;
  End If;
  If (p_rec.cwg_attribute11 = hr_api.g_varchar2) then
    p_rec.cwg_attribute11 :=
    ben_cwg_shd.g_old_rec.cwg_attribute11;
  End If;
  If (p_rec.cwg_attribute12 = hr_api.g_varchar2) then
    p_rec.cwg_attribute12 :=
    ben_cwg_shd.g_old_rec.cwg_attribute12;
  End If;
  If (p_rec.cwg_attribute13 = hr_api.g_varchar2) then
    p_rec.cwg_attribute13 :=
    ben_cwg_shd.g_old_rec.cwg_attribute13;
  End If;
  If (p_rec.cwg_attribute14 = hr_api.g_varchar2) then
    p_rec.cwg_attribute14 :=
    ben_cwg_shd.g_old_rec.cwg_attribute14;
  End If;
  If (p_rec.cwg_attribute15 = hr_api.g_varchar2) then
    p_rec.cwg_attribute15 :=
    ben_cwg_shd.g_old_rec.cwg_attribute15;
  End If;
  If (p_rec.cwg_attribute16 = hr_api.g_varchar2) then
    p_rec.cwg_attribute16 :=
    ben_cwg_shd.g_old_rec.cwg_attribute16;
  End If;
  If (p_rec.cwg_attribute17 = hr_api.g_varchar2) then
    p_rec.cwg_attribute17 :=
    ben_cwg_shd.g_old_rec.cwg_attribute17;
  End If;
  If (p_rec.cwg_attribute18 = hr_api.g_varchar2) then
    p_rec.cwg_attribute18 :=
    ben_cwg_shd.g_old_rec.cwg_attribute18;
  End If;
  If (p_rec.cwg_attribute19 = hr_api.g_varchar2) then
    p_rec.cwg_attribute19 :=
    ben_cwg_shd.g_old_rec.cwg_attribute19;
  End If;
  If (p_rec.cwg_attribute20 = hr_api.g_varchar2) then
    p_rec.cwg_attribute20 :=
    ben_cwg_shd.g_old_rec.cwg_attribute20;
  End If;
  If (p_rec.cwg_attribute21 = hr_api.g_varchar2) then
    p_rec.cwg_attribute21 :=
    ben_cwg_shd.g_old_rec.cwg_attribute21;
  End If;
  If (p_rec.cwg_attribute22 = hr_api.g_varchar2) then
    p_rec.cwg_attribute22 :=
    ben_cwg_shd.g_old_rec.cwg_attribute22;
  End If;
  If (p_rec.cwg_attribute23 = hr_api.g_varchar2) then
    p_rec.cwg_attribute23 :=
    ben_cwg_shd.g_old_rec.cwg_attribute23;
  End If;
  If (p_rec.cwg_attribute24 = hr_api.g_varchar2) then
    p_rec.cwg_attribute24 :=
    ben_cwg_shd.g_old_rec.cwg_attribute24;
  End If;
  If (p_rec.cwg_attribute25 = hr_api.g_varchar2) then
    p_rec.cwg_attribute25 :=
    ben_cwg_shd.g_old_rec.cwg_attribute25;
  End If;
  If (p_rec.cwg_attribute26 = hr_api.g_varchar2) then
    p_rec.cwg_attribute26 :=
    ben_cwg_shd.g_old_rec.cwg_attribute26;
  End If;
  If (p_rec.cwg_attribute27 = hr_api.g_varchar2) then
    p_rec.cwg_attribute27 :=
    ben_cwg_shd.g_old_rec.cwg_attribute27;
  End If;
  If (p_rec.cwg_attribute28 = hr_api.g_varchar2) then
    p_rec.cwg_attribute28 :=
    ben_cwg_shd.g_old_rec.cwg_attribute28;
  End If;
  If (p_rec.cwg_attribute29 = hr_api.g_varchar2) then
    p_rec.cwg_attribute29 :=
    ben_cwg_shd.g_old_rec.cwg_attribute29;
  End If;
  If (p_rec.cwg_attribute30 = hr_api.g_varchar2) then
    p_rec.cwg_attribute30 :=
    ben_cwg_shd.g_old_rec.cwg_attribute30;
  End If;

  --
  If (p_rec.status_cd      = hr_api.g_varchar2) then
    p_rec.status_cd    := ben_cwg_shd.g_old_rec.status_cd;
  End If;

  If (p_rec.hidden_cd = hr_api.g_varchar2) then
    p_rec.hidden_cd  := ben_cwg_shd.g_old_rec.hidden_cd;
  End If;

End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy ben_cwg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ben_cwg_shd.lck
    (p_rec.cwb_wksht_grp_id
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
  ben_cwg_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  ben_cwg_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  ben_cwg_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  ben_cwg_upd.post_update
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
  ,p_cwb_wksht_grp_id             in     number
  ,p_object_version_number        in out nocopy number
  ,p_ordr_num                     in     number    default hr_api.g_number
  ,p_wksht_grp_cd                 in     varchar2  default hr_api.g_varchar2
  ,p_label                        in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_cwg_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_status_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_hidden_cd                   in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   ben_cwg_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_cwg_shd.convert_args
  (p_cwb_wksht_grp_id
  ,hr_api.g_number
  ,hr_api.g_number
  ,p_ordr_num
  ,p_wksht_grp_cd
  ,p_label
  ,p_cwg_attribute_category
  ,p_cwg_attribute1
  ,p_cwg_attribute2
  ,p_cwg_attribute3
  ,p_cwg_attribute4
  ,p_cwg_attribute5
  ,p_cwg_attribute6
  ,p_cwg_attribute7
  ,p_cwg_attribute8
  ,p_cwg_attribute9
  ,p_cwg_attribute10
  ,p_cwg_attribute11
  ,p_cwg_attribute12
  ,p_cwg_attribute13
  ,p_cwg_attribute14
  ,p_cwg_attribute15
  ,p_cwg_attribute16
  ,p_cwg_attribute17
  ,p_cwg_attribute18
  ,p_cwg_attribute19
  ,p_cwg_attribute20
  ,p_cwg_attribute21
  ,p_cwg_attribute22
  ,p_cwg_attribute23
  ,p_cwg_attribute24
  ,p_cwg_attribute25
  ,p_cwg_attribute26
  ,p_cwg_attribute27
  ,p_cwg_attribute28
  ,p_cwg_attribute29
  ,p_cwg_attribute30
  ,p_status_cd
  ,p_hidden_cd
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ben_cwg_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_cwg_upd;

/

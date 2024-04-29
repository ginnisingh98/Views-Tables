--------------------------------------------------------
--  DDL for Package Body BEN_AGF_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_AGF_UPD" as
/* $Header: beagfrhi.pkb 120.0 2005/05/28 00:23:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_agf_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy ben_agf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  ben_agf_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_age_fctr Row
  --
  update ben_age_fctr
  set
  age_fctr_id                       = p_rec.age_fctr_id,
  name                              = p_rec.name,
  mx_age_num                        = p_rec.mx_age_num,
  mn_age_num                        = p_rec.mn_age_num,
  age_uom                           = p_rec.age_uom,
  no_mn_age_flag                    = p_rec.no_mn_age_flag,
  no_mx_age_flag                    = p_rec.no_mx_age_flag,
  age_to_use_cd                     = p_rec.age_to_use_cd,
  age_det_cd                        = p_rec.age_det_cd,
  age_det_rl                        = p_rec.age_det_rl,
  rndg_cd                           = p_rec.rndg_cd,
  rndg_rl                           = p_rec.rndg_rl,
  age_calc_rl                       = p_rec.age_calc_rl,
  business_group_id                 = p_rec.business_group_id,
  agf_attribute_category            = p_rec.agf_attribute_category,
  agf_attribute1                    = p_rec.agf_attribute1,
  agf_attribute2                    = p_rec.agf_attribute2,
  agf_attribute3                    = p_rec.agf_attribute3,
  agf_attribute4                    = p_rec.agf_attribute4,
  agf_attribute5                    = p_rec.agf_attribute5,
  agf_attribute6                    = p_rec.agf_attribute6,
  agf_attribute7                    = p_rec.agf_attribute7,
  agf_attribute8                    = p_rec.agf_attribute8,
  agf_attribute9                    = p_rec.agf_attribute9,
  agf_attribute10                   = p_rec.agf_attribute10,
  agf_attribute11                   = p_rec.agf_attribute11,
  agf_attribute12                   = p_rec.agf_attribute12,
  agf_attribute13                   = p_rec.agf_attribute13,
  agf_attribute14                   = p_rec.agf_attribute14,
  agf_attribute15                   = p_rec.agf_attribute15,
  agf_attribute16                   = p_rec.agf_attribute16,
  agf_attribute17                   = p_rec.agf_attribute17,
  agf_attribute18                   = p_rec.agf_attribute18,
  agf_attribute19                   = p_rec.agf_attribute19,
  agf_attribute20                   = p_rec.agf_attribute20,
  agf_attribute21                   = p_rec.agf_attribute21,
  agf_attribute22                   = p_rec.agf_attribute22,
  agf_attribute23                   = p_rec.agf_attribute23,
  agf_attribute24                   = p_rec.agf_attribute24,
  agf_attribute25                   = p_rec.agf_attribute25,
  agf_attribute26                   = p_rec.agf_attribute26,
  agf_attribute27                   = p_rec.agf_attribute27,
  agf_attribute28                   = p_rec.agf_attribute28,
  agf_attribute29                   = p_rec.agf_attribute29,
  agf_attribute30                   = p_rec.agf_attribute30,
  object_version_number             = p_rec.object_version_number
  where age_fctr_id = p_rec.age_fctr_id;
  --
  ben_agf_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_agf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_agf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_agf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_agf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_agf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_agf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_agf_shd.g_api_dml := false;   -- Unset the api dml status
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
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in ben_agf_shd.g_rec_type) is
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
Procedure post_update(
p_effective_date in date,p_rec in ben_agf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    ben_agf_rku.after_update
      (
  p_age_fctr_id                   =>p_rec.age_fctr_id
 ,p_name                          =>p_rec.name
 ,p_mx_age_num                    =>p_rec.mx_age_num
 ,p_mn_age_num                    =>p_rec.mn_age_num
 ,p_age_uom                       =>p_rec.age_uom
 ,p_no_mn_age_flag                =>p_rec.no_mn_age_flag
 ,p_no_mx_age_flag                =>p_rec.no_mx_age_flag
 ,p_age_to_use_cd                 =>p_rec.age_to_use_cd
 ,p_age_det_cd                    =>p_rec.age_det_cd
 ,p_age_det_rl                    =>p_rec.age_det_rl
 ,p_rndg_cd                       =>p_rec.rndg_cd
 ,p_rndg_rl                       =>p_rec.rndg_rl
 ,p_age_calc_rl                   =>p_rec.age_calc_rl
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_agf_attribute_category        =>p_rec.agf_attribute_category
 ,p_agf_attribute1                =>p_rec.agf_attribute1
 ,p_agf_attribute2                =>p_rec.agf_attribute2
 ,p_agf_attribute3                =>p_rec.agf_attribute3
 ,p_agf_attribute4                =>p_rec.agf_attribute4
 ,p_agf_attribute5                =>p_rec.agf_attribute5
 ,p_agf_attribute6                =>p_rec.agf_attribute6
 ,p_agf_attribute7                =>p_rec.agf_attribute7
 ,p_agf_attribute8                =>p_rec.agf_attribute8
 ,p_agf_attribute9                =>p_rec.agf_attribute9
 ,p_agf_attribute10               =>p_rec.agf_attribute10
 ,p_agf_attribute11               =>p_rec.agf_attribute11
 ,p_agf_attribute12               =>p_rec.agf_attribute12
 ,p_agf_attribute13               =>p_rec.agf_attribute13
 ,p_agf_attribute14               =>p_rec.agf_attribute14
 ,p_agf_attribute15               =>p_rec.agf_attribute15
 ,p_agf_attribute16               =>p_rec.agf_attribute16
 ,p_agf_attribute17               =>p_rec.agf_attribute17
 ,p_agf_attribute18               =>p_rec.agf_attribute18
 ,p_agf_attribute19               =>p_rec.agf_attribute19
 ,p_agf_attribute20               =>p_rec.agf_attribute20
 ,p_agf_attribute21               =>p_rec.agf_attribute21
 ,p_agf_attribute22               =>p_rec.agf_attribute22
 ,p_agf_attribute23               =>p_rec.agf_attribute23
 ,p_agf_attribute24               =>p_rec.agf_attribute24
 ,p_agf_attribute25               =>p_rec.agf_attribute25
 ,p_agf_attribute26               =>p_rec.agf_attribute26
 ,p_agf_attribute27               =>p_rec.agf_attribute27
 ,p_agf_attribute28               =>p_rec.agf_attribute28
 ,p_agf_attribute29               =>p_rec.agf_attribute29
 ,p_agf_attribute30               =>p_rec.agf_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_name_o                        =>ben_agf_shd.g_old_rec.name
 ,p_mx_age_num_o                  =>ben_agf_shd.g_old_rec.mx_age_num
 ,p_mn_age_num_o                  =>ben_agf_shd.g_old_rec.mn_age_num
 ,p_age_uom_o                     =>ben_agf_shd.g_old_rec.age_uom
 ,p_no_mn_age_flag_o              =>ben_agf_shd.g_old_rec.no_mn_age_flag
 ,p_no_mx_age_flag_o              =>ben_agf_shd.g_old_rec.no_mx_age_flag
 ,p_age_to_use_cd_o               =>ben_agf_shd.g_old_rec.age_to_use_cd
 ,p_age_det_cd_o                  =>ben_agf_shd.g_old_rec.age_det_cd
 ,p_age_det_rl_o                  =>ben_agf_shd.g_old_rec.age_det_rl
 ,p_rndg_cd_o                     =>ben_agf_shd.g_old_rec.rndg_cd
 ,p_rndg_rl_o                     =>ben_agf_shd.g_old_rec.rndg_rl
 ,p_age_calc_rl_o                 =>ben_agf_shd.g_old_rec.age_calc_rl
 ,p_business_group_id_o           =>ben_agf_shd.g_old_rec.business_group_id
 ,p_agf_attribute_category_o      =>ben_agf_shd.g_old_rec.agf_attribute_category
 ,p_agf_attribute1_o              =>ben_agf_shd.g_old_rec.agf_attribute1
 ,p_agf_attribute2_o              =>ben_agf_shd.g_old_rec.agf_attribute2
 ,p_agf_attribute3_o              =>ben_agf_shd.g_old_rec.agf_attribute3
 ,p_agf_attribute4_o              =>ben_agf_shd.g_old_rec.agf_attribute4
 ,p_agf_attribute5_o              =>ben_agf_shd.g_old_rec.agf_attribute5
 ,p_agf_attribute6_o              =>ben_agf_shd.g_old_rec.agf_attribute6
 ,p_agf_attribute7_o              =>ben_agf_shd.g_old_rec.agf_attribute7
 ,p_agf_attribute8_o              =>ben_agf_shd.g_old_rec.agf_attribute8
 ,p_agf_attribute9_o              =>ben_agf_shd.g_old_rec.agf_attribute9
 ,p_agf_attribute10_o             =>ben_agf_shd.g_old_rec.agf_attribute10
 ,p_agf_attribute11_o             =>ben_agf_shd.g_old_rec.agf_attribute11
 ,p_agf_attribute12_o             =>ben_agf_shd.g_old_rec.agf_attribute12
 ,p_agf_attribute13_o             =>ben_agf_shd.g_old_rec.agf_attribute13
 ,p_agf_attribute14_o             =>ben_agf_shd.g_old_rec.agf_attribute14
 ,p_agf_attribute15_o             =>ben_agf_shd.g_old_rec.agf_attribute15
 ,p_agf_attribute16_o             =>ben_agf_shd.g_old_rec.agf_attribute16
 ,p_agf_attribute17_o             =>ben_agf_shd.g_old_rec.agf_attribute17
 ,p_agf_attribute18_o             =>ben_agf_shd.g_old_rec.agf_attribute18
 ,p_agf_attribute19_o             =>ben_agf_shd.g_old_rec.agf_attribute19
 ,p_agf_attribute20_o             =>ben_agf_shd.g_old_rec.agf_attribute20
 ,p_agf_attribute21_o             =>ben_agf_shd.g_old_rec.agf_attribute21
 ,p_agf_attribute22_o             =>ben_agf_shd.g_old_rec.agf_attribute22
 ,p_agf_attribute23_o             =>ben_agf_shd.g_old_rec.agf_attribute23
 ,p_agf_attribute24_o             =>ben_agf_shd.g_old_rec.agf_attribute24
 ,p_agf_attribute25_o             =>ben_agf_shd.g_old_rec.agf_attribute25
 ,p_agf_attribute26_o             =>ben_agf_shd.g_old_rec.agf_attribute26
 ,p_agf_attribute27_o             =>ben_agf_shd.g_old_rec.agf_attribute27
 ,p_agf_attribute28_o             =>ben_agf_shd.g_old_rec.agf_attribute28
 ,p_agf_attribute29_o             =>ben_agf_shd.g_old_rec.agf_attribute29
 ,p_agf_attribute30_o             =>ben_agf_shd.g_old_rec.agf_attribute30
 ,p_object_version_number_o       =>ben_agf_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_age_fctr'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
  --
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
--   errors within this procedure will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy ben_agf_shd.g_rec_type) is
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
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    ben_agf_shd.g_old_rec.name;
  End If;
  If (p_rec.mx_age_num = hr_api.g_number) then
    p_rec.mx_age_num :=
    ben_agf_shd.g_old_rec.mx_age_num;
  End If;
  If (p_rec.mn_age_num = hr_api.g_number) then
    p_rec.mn_age_num :=
    ben_agf_shd.g_old_rec.mn_age_num;
  End If;
  If (p_rec.age_uom = hr_api.g_varchar2) then
    p_rec.age_uom :=
    ben_agf_shd.g_old_rec.age_uom;
  End If;
  If (p_rec.no_mn_age_flag = hr_api.g_varchar2) then
    p_rec.no_mn_age_flag :=
    ben_agf_shd.g_old_rec.no_mn_age_flag;
  End If;
  If (p_rec.no_mx_age_flag = hr_api.g_varchar2) then
    p_rec.no_mx_age_flag :=
    ben_agf_shd.g_old_rec.no_mx_age_flag;
  End If;
  If (p_rec.age_to_use_cd = hr_api.g_varchar2) then
    p_rec.age_to_use_cd :=
    ben_agf_shd.g_old_rec.age_to_use_cd;
  End If;
  If (p_rec.age_det_cd = hr_api.g_varchar2) then
    p_rec.age_det_cd :=
    ben_agf_shd.g_old_rec.age_det_cd;
  End If;
  If (p_rec.age_det_rl = hr_api.g_number) then
    p_rec.age_det_rl :=
    ben_agf_shd.g_old_rec.age_det_rl;
  End If;
  If (p_rec.rndg_cd = hr_api.g_varchar2) then
    p_rec.rndg_cd :=
    ben_agf_shd.g_old_rec.rndg_cd;
  End If;
  If (p_rec.rndg_rl = hr_api.g_number) then
    p_rec.rndg_rl :=
    ben_agf_shd.g_old_rec.rndg_rl;
  End If;
  If (p_rec.age_calc_rl = hr_api.g_number) then
    p_rec.age_calc_rl :=
    ben_agf_shd.g_old_rec.age_calc_rl;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_agf_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.agf_attribute_category = hr_api.g_varchar2) then
    p_rec.agf_attribute_category :=
    ben_agf_shd.g_old_rec.agf_attribute_category;
  End If;
  If (p_rec.agf_attribute1 = hr_api.g_varchar2) then
    p_rec.agf_attribute1 :=
    ben_agf_shd.g_old_rec.agf_attribute1;
  End If;
  If (p_rec.agf_attribute2 = hr_api.g_varchar2) then
    p_rec.agf_attribute2 :=
    ben_agf_shd.g_old_rec.agf_attribute2;
  End If;
  If (p_rec.agf_attribute3 = hr_api.g_varchar2) then
    p_rec.agf_attribute3 :=
    ben_agf_shd.g_old_rec.agf_attribute3;
  End If;
  If (p_rec.agf_attribute4 = hr_api.g_varchar2) then
    p_rec.agf_attribute4 :=
    ben_agf_shd.g_old_rec.agf_attribute4;
  End If;
  If (p_rec.agf_attribute5 = hr_api.g_varchar2) then
    p_rec.agf_attribute5 :=
    ben_agf_shd.g_old_rec.agf_attribute5;
  End If;
  If (p_rec.agf_attribute6 = hr_api.g_varchar2) then
    p_rec.agf_attribute6 :=
    ben_agf_shd.g_old_rec.agf_attribute6;
  End If;
  If (p_rec.agf_attribute7 = hr_api.g_varchar2) then
    p_rec.agf_attribute7 :=
    ben_agf_shd.g_old_rec.agf_attribute7;
  End If;
  If (p_rec.agf_attribute8 = hr_api.g_varchar2) then
    p_rec.agf_attribute8 :=
    ben_agf_shd.g_old_rec.agf_attribute8;
  End If;
  If (p_rec.agf_attribute9 = hr_api.g_varchar2) then
    p_rec.agf_attribute9 :=
    ben_agf_shd.g_old_rec.agf_attribute9;
  End If;
  If (p_rec.agf_attribute10 = hr_api.g_varchar2) then
    p_rec.agf_attribute10 :=
    ben_agf_shd.g_old_rec.agf_attribute10;
  End If;
  If (p_rec.agf_attribute11 = hr_api.g_varchar2) then
    p_rec.agf_attribute11 :=
    ben_agf_shd.g_old_rec.agf_attribute11;
  End If;
  If (p_rec.agf_attribute12 = hr_api.g_varchar2) then
    p_rec.agf_attribute12 :=
    ben_agf_shd.g_old_rec.agf_attribute12;
  End If;
  If (p_rec.agf_attribute13 = hr_api.g_varchar2) then
    p_rec.agf_attribute13 :=
    ben_agf_shd.g_old_rec.agf_attribute13;
  End If;
  If (p_rec.agf_attribute14 = hr_api.g_varchar2) then
    p_rec.agf_attribute14 :=
    ben_agf_shd.g_old_rec.agf_attribute14;
  End If;
  If (p_rec.agf_attribute15 = hr_api.g_varchar2) then
    p_rec.agf_attribute15 :=
    ben_agf_shd.g_old_rec.agf_attribute15;
  End If;
  If (p_rec.agf_attribute16 = hr_api.g_varchar2) then
    p_rec.agf_attribute16 :=
    ben_agf_shd.g_old_rec.agf_attribute16;
  End If;
  If (p_rec.agf_attribute17 = hr_api.g_varchar2) then
    p_rec.agf_attribute17 :=
    ben_agf_shd.g_old_rec.agf_attribute17;
  End If;
  If (p_rec.agf_attribute18 = hr_api.g_varchar2) then
    p_rec.agf_attribute18 :=
    ben_agf_shd.g_old_rec.agf_attribute18;
  End If;
  If (p_rec.agf_attribute19 = hr_api.g_varchar2) then
    p_rec.agf_attribute19 :=
    ben_agf_shd.g_old_rec.agf_attribute19;
  End If;
  If (p_rec.agf_attribute20 = hr_api.g_varchar2) then
    p_rec.agf_attribute20 :=
    ben_agf_shd.g_old_rec.agf_attribute20;
  End If;
  If (p_rec.agf_attribute21 = hr_api.g_varchar2) then
    p_rec.agf_attribute21 :=
    ben_agf_shd.g_old_rec.agf_attribute21;
  End If;
  If (p_rec.agf_attribute22 = hr_api.g_varchar2) then
    p_rec.agf_attribute22 :=
    ben_agf_shd.g_old_rec.agf_attribute22;
  End If;
  If (p_rec.agf_attribute23 = hr_api.g_varchar2) then
    p_rec.agf_attribute23 :=
    ben_agf_shd.g_old_rec.agf_attribute23;
  End If;
  If (p_rec.agf_attribute24 = hr_api.g_varchar2) then
    p_rec.agf_attribute24 :=
    ben_agf_shd.g_old_rec.agf_attribute24;
  End If;
  If (p_rec.agf_attribute25 = hr_api.g_varchar2) then
    p_rec.agf_attribute25 :=
    ben_agf_shd.g_old_rec.agf_attribute25;
  End If;
  If (p_rec.agf_attribute26 = hr_api.g_varchar2) then
    p_rec.agf_attribute26 :=
    ben_agf_shd.g_old_rec.agf_attribute26;
  End If;
  If (p_rec.agf_attribute27 = hr_api.g_varchar2) then
    p_rec.agf_attribute27 :=
    ben_agf_shd.g_old_rec.agf_attribute27;
  End If;
  If (p_rec.agf_attribute28 = hr_api.g_varchar2) then
    p_rec.agf_attribute28 :=
    ben_agf_shd.g_old_rec.agf_attribute28;
  End If;
  If (p_rec.agf_attribute29 = hr_api.g_varchar2) then
    p_rec.agf_attribute29 :=
    ben_agf_shd.g_old_rec.agf_attribute29;
  End If;
  If (p_rec.agf_attribute30 = hr_api.g_varchar2) then
    p_rec.agf_attribute30 :=
    ben_agf_shd.g_old_rec.agf_attribute30;
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
  p_effective_date in date,
  p_rec        in out nocopy ben_agf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ben_agf_shd.lck
	(
	p_rec.age_fctr_id,
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
  ben_agf_bus.update_validate(p_rec
  ,p_effective_date);
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
  post_update(
p_effective_date,p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date in date,
  p_age_fctr_id                  in number,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_mx_age_num                   in number           default hr_api.g_number,
  p_mn_age_num                   in number           default hr_api.g_number,
  p_age_uom                      in varchar2         default hr_api.g_varchar2,
  p_no_mn_age_flag               in varchar2         default hr_api.g_varchar2,
  p_no_mx_age_flag               in varchar2         default hr_api.g_varchar2,
  p_age_to_use_cd                in varchar2         default hr_api.g_varchar2,
  p_age_det_cd                   in varchar2         default hr_api.g_varchar2,
  p_age_det_rl                   in number           default hr_api.g_number,
  p_rndg_cd                      in varchar2         default hr_api.g_varchar2,
  p_rndg_rl                      in number           default hr_api.g_number,
  p_age_calc_rl                  in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_agf_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_agf_attribute1               in varchar2         default hr_api.g_varchar2,
  p_agf_attribute2               in varchar2         default hr_api.g_varchar2,
  p_agf_attribute3               in varchar2         default hr_api.g_varchar2,
  p_agf_attribute4               in varchar2         default hr_api.g_varchar2,
  p_agf_attribute5               in varchar2         default hr_api.g_varchar2,
  p_agf_attribute6               in varchar2         default hr_api.g_varchar2,
  p_agf_attribute7               in varchar2         default hr_api.g_varchar2,
  p_agf_attribute8               in varchar2         default hr_api.g_varchar2,
  p_agf_attribute9               in varchar2         default hr_api.g_varchar2,
  p_agf_attribute10              in varchar2         default hr_api.g_varchar2,
  p_agf_attribute11              in varchar2         default hr_api.g_varchar2,
  p_agf_attribute12              in varchar2         default hr_api.g_varchar2,
  p_agf_attribute13              in varchar2         default hr_api.g_varchar2,
  p_agf_attribute14              in varchar2         default hr_api.g_varchar2,
  p_agf_attribute15              in varchar2         default hr_api.g_varchar2,
  p_agf_attribute16              in varchar2         default hr_api.g_varchar2,
  p_agf_attribute17              in varchar2         default hr_api.g_varchar2,
  p_agf_attribute18              in varchar2         default hr_api.g_varchar2,
  p_agf_attribute19              in varchar2         default hr_api.g_varchar2,
  p_agf_attribute20              in varchar2         default hr_api.g_varchar2,
  p_agf_attribute21              in varchar2         default hr_api.g_varchar2,
  p_agf_attribute22              in varchar2         default hr_api.g_varchar2,
  p_agf_attribute23              in varchar2         default hr_api.g_varchar2,
  p_agf_attribute24              in varchar2         default hr_api.g_varchar2,
  p_agf_attribute25              in varchar2         default hr_api.g_varchar2,
  p_agf_attribute26              in varchar2         default hr_api.g_varchar2,
  p_agf_attribute27              in varchar2         default hr_api.g_varchar2,
  p_agf_attribute28              in varchar2         default hr_api.g_varchar2,
  p_agf_attribute29              in varchar2         default hr_api.g_varchar2,
  p_agf_attribute30              in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number
  ) is
--
  l_rec	  ben_agf_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_agf_shd.convert_args
  (
  p_age_fctr_id,
  p_name,
  p_mx_age_num,
  p_mn_age_num,
  p_age_uom,
  p_no_mn_age_flag,
  p_no_mx_age_flag,
  p_age_to_use_cd,
  p_age_det_cd,
  p_age_det_rl,
  p_rndg_cd,
  p_rndg_rl,
  p_age_calc_rl,
  p_business_group_id,
  p_agf_attribute_category,
  p_agf_attribute1,
  p_agf_attribute2,
  p_agf_attribute3,
  p_agf_attribute4,
  p_agf_attribute5,
  p_agf_attribute6,
  p_agf_attribute7,
  p_agf_attribute8,
  p_agf_attribute9,
  p_agf_attribute10,
  p_agf_attribute11,
  p_agf_attribute12,
  p_agf_attribute13,
  p_agf_attribute14,
  p_agf_attribute15,
  p_agf_attribute16,
  p_agf_attribute17,
  p_agf_attribute18,
  p_agf_attribute19,
  p_agf_attribute20,
  p_agf_attribute21,
  p_agf_attribute22,
  p_agf_attribute23,
  p_agf_attribute24,
  p_agf_attribute25,
  p_agf_attribute26,
  p_agf_attribute27,
  p_agf_attribute28,
  p_agf_attribute29,
  p_agf_attribute30,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(
    p_effective_date,l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_agf_upd;

/

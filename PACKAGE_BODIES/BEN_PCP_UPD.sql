--------------------------------------------------------
--  DDL for Package Body BEN_PCP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PCP_UPD" as
/* $Header: bepcprhi.pkb 115.13 2002/12/16 12:00:12 vsethi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pcp_upd.';  -- Global package name
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
  (p_rec in out nocopy ben_pcp_shd.g_rec_type
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
  ben_pcp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_pl_pcp Row
  --
  update ben_pl_pcp
    set
     pl_pcp_id                       = p_rec.pl_pcp_id
    ,pl_id                           = p_rec.pl_id
    ,business_group_id               = p_rec.business_group_id
    ,pcp_strt_dt_cd                  = p_rec.pcp_strt_dt_cd
    ,pcp_dsgn_cd                     = p_rec.pcp_dsgn_cd
    ,pcp_dpnt_dsgn_cd                = p_rec.pcp_dpnt_dsgn_cd
    ,pcp_rpstry_flag                 = p_rec.pcp_rpstry_flag
    ,pcp_can_keep_flag               = p_rec.pcp_can_keep_flag
    ,pcp_radius                      = p_rec.pcp_radius
    ,pcp_radius_uom                  = p_rec.pcp_radius_uom
    ,pcp_radius_warn_flag            = p_rec.pcp_radius_warn_flag
    ,pcp_num_chgs                    = p_rec.pcp_num_chgs
    ,pcp_num_chgs_uom                = p_rec.pcp_num_chgs_uom
    ,pcp_attribute_category          = p_rec.pcp_attribute_category
    ,pcp_attribute1                  = p_rec.pcp_attribute1
    ,pcp_attribute2                  = p_rec.pcp_attribute2
    ,pcp_attribute3                  = p_rec.pcp_attribute3
    ,pcp_attribute4                  = p_rec.pcp_attribute4
    ,pcp_attribute5                  = p_rec.pcp_attribute5
    ,pcp_attribute6                  = p_rec.pcp_attribute6
    ,pcp_attribute7                  = p_rec.pcp_attribute7
    ,pcp_attribute8                  = p_rec.pcp_attribute8
    ,pcp_attribute9                  = p_rec.pcp_attribute9
    ,pcp_attribute10                 = p_rec.pcp_attribute10
    ,pcp_attribute11                 = p_rec.pcp_attribute11
    ,pcp_attribute12                 = p_rec.pcp_attribute12
    ,pcp_attribute13                 = p_rec.pcp_attribute13
    ,pcp_attribute14                 = p_rec.pcp_attribute14
    ,pcp_attribute15                 = p_rec.pcp_attribute15
    ,pcp_attribute16                 = p_rec.pcp_attribute16
    ,pcp_attribute17                 = p_rec.pcp_attribute17
    ,pcp_attribute18                 = p_rec.pcp_attribute18
    ,pcp_attribute19                 = p_rec.pcp_attribute19
    ,pcp_attribute20                 = p_rec.pcp_attribute20
    ,pcp_attribute21                 = p_rec.pcp_attribute21
    ,pcp_attribute22                 = p_rec.pcp_attribute22
    ,pcp_attribute23                 = p_rec.pcp_attribute23
    ,pcp_attribute24                 = p_rec.pcp_attribute24
    ,pcp_attribute25                 = p_rec.pcp_attribute25
    ,pcp_attribute26                 = p_rec.pcp_attribute26
    ,pcp_attribute27                 = p_rec.pcp_attribute27
    ,pcp_attribute28                 = p_rec.pcp_attribute28
    ,pcp_attribute29                 = p_rec.pcp_attribute29
    ,pcp_attribute30                 = p_rec.pcp_attribute30
    ,object_version_number           = p_rec.object_version_number
    where pl_pcp_id = p_rec.pl_pcp_id;
  --
  ben_pcp_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_pcp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pcp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_pcp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pcp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_pcp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pcp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_pcp_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in ben_pcp_shd.g_rec_type
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
--   This private procedure contains any processing which is required after the
--   update dml.
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
  (p_rec                          in ben_pcp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ben_pcp_rku.after_update
      (p_pl_pcp_id
      => p_rec.pl_pcp_id
      ,p_pl_id
      => p_rec.pl_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_pcp_strt_dt_cd
      => p_rec.pcp_strt_dt_cd
      ,p_pcp_dsgn_cd
      => p_rec.pcp_dsgn_cd
      ,p_pcp_dpnt_dsgn_cd
      => p_rec.pcp_dpnt_dsgn_cd
      ,p_pcp_rpstry_flag
      => p_rec.pcp_rpstry_flag
      ,p_pcp_can_keep_flag
      => p_rec.pcp_can_keep_flag
      ,p_pcp_radius
      => p_rec.pcp_radius
      ,p_pcp_radius_uom
      => p_rec.pcp_radius_uom
      ,p_pcp_radius_warn_flag
      => p_rec.pcp_radius_warn_flag
      ,p_pcp_num_chgs
      => p_rec.pcp_num_chgs
      ,p_pcp_num_chgs_uom
      => p_rec.pcp_num_chgs_uom
      ,p_pcp_attribute_category
      => p_rec.pcp_attribute_category
      ,p_pcp_attribute1
      => p_rec.pcp_attribute1
      ,p_pcp_attribute2
      => p_rec.pcp_attribute2
      ,p_pcp_attribute3
      => p_rec.pcp_attribute3
      ,p_pcp_attribute4
      => p_rec.pcp_attribute4
      ,p_pcp_attribute5
      => p_rec.pcp_attribute5
      ,p_pcp_attribute6
      => p_rec.pcp_attribute6
      ,p_pcp_attribute7
      => p_rec.pcp_attribute7
      ,p_pcp_attribute8
      => p_rec.pcp_attribute8
      ,p_pcp_attribute9
      => p_rec.pcp_attribute9
      ,p_pcp_attribute10
      => p_rec.pcp_attribute10
      ,p_pcp_attribute11
      => p_rec.pcp_attribute11
      ,p_pcp_attribute12
      => p_rec.pcp_attribute12
      ,p_pcp_attribute13
      => p_rec.pcp_attribute13
      ,p_pcp_attribute14
      => p_rec.pcp_attribute14
      ,p_pcp_attribute15
      => p_rec.pcp_attribute15
      ,p_pcp_attribute16
      => p_rec.pcp_attribute16
      ,p_pcp_attribute17
      => p_rec.pcp_attribute17
      ,p_pcp_attribute18
      => p_rec.pcp_attribute18
      ,p_pcp_attribute19
      => p_rec.pcp_attribute19
      ,p_pcp_attribute20
      => p_rec.pcp_attribute20
      ,p_pcp_attribute21
      => p_rec.pcp_attribute21
      ,p_pcp_attribute22
      => p_rec.pcp_attribute22
      ,p_pcp_attribute23
      => p_rec.pcp_attribute23
      ,p_pcp_attribute24
      => p_rec.pcp_attribute24
      ,p_pcp_attribute25
      => p_rec.pcp_attribute25
      ,p_pcp_attribute26
      => p_rec.pcp_attribute26
      ,p_pcp_attribute27
      => p_rec.pcp_attribute27
      ,p_pcp_attribute28
      => p_rec.pcp_attribute28
      ,p_pcp_attribute29
      => p_rec.pcp_attribute29
      ,p_pcp_attribute30
      => p_rec.pcp_attribute30
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_pl_id_o
      => ben_pcp_shd.g_old_rec.pl_id
      ,p_business_group_id_o
      => ben_pcp_shd.g_old_rec.business_group_id
      ,p_pcp_strt_dt_cd_o
      => ben_pcp_shd.g_old_rec.pcp_strt_dt_cd
      ,p_pcp_dsgn_cd_o
      => ben_pcp_shd.g_old_rec.pcp_dsgn_cd
      ,p_pcp_dpnt_dsgn_cd_o
      => ben_pcp_shd.g_old_rec.pcp_dpnt_dsgn_cd
      ,p_pcp_rpstry_flag_o
      => ben_pcp_shd.g_old_rec.pcp_rpstry_flag
      ,p_pcp_can_keep_flag_o
      => ben_pcp_shd.g_old_rec.pcp_can_keep_flag
      ,p_pcp_radius_o
      => ben_pcp_shd.g_old_rec.pcp_radius
      ,p_pcp_radius_uom_o
      => ben_pcp_shd.g_old_rec.pcp_radius_uom
      ,p_pcp_radius_warn_flag_o
      => ben_pcp_shd.g_old_rec.pcp_radius_warn_flag
      ,p_pcp_num_chgs_o
      => ben_pcp_shd.g_old_rec.pcp_num_chgs
      ,p_pcp_num_chgs_uom_o
      => ben_pcp_shd.g_old_rec.pcp_num_chgs_uom
      ,p_pcp_attribute_category_o
      => ben_pcp_shd.g_old_rec.pcp_attribute_category
      ,p_pcp_attribute1_o
      => ben_pcp_shd.g_old_rec.pcp_attribute1
      ,p_pcp_attribute2_o
      => ben_pcp_shd.g_old_rec.pcp_attribute2
      ,p_pcp_attribute3_o
      => ben_pcp_shd.g_old_rec.pcp_attribute3
      ,p_pcp_attribute4_o
      => ben_pcp_shd.g_old_rec.pcp_attribute4
      ,p_pcp_attribute5_o
      => ben_pcp_shd.g_old_rec.pcp_attribute5
      ,p_pcp_attribute6_o
      => ben_pcp_shd.g_old_rec.pcp_attribute6
      ,p_pcp_attribute7_o
      => ben_pcp_shd.g_old_rec.pcp_attribute7
      ,p_pcp_attribute8_o
      => ben_pcp_shd.g_old_rec.pcp_attribute8
      ,p_pcp_attribute9_o
      => ben_pcp_shd.g_old_rec.pcp_attribute9
      ,p_pcp_attribute10_o
      => ben_pcp_shd.g_old_rec.pcp_attribute10
      ,p_pcp_attribute11_o
      => ben_pcp_shd.g_old_rec.pcp_attribute11
      ,p_pcp_attribute12_o
      => ben_pcp_shd.g_old_rec.pcp_attribute12
      ,p_pcp_attribute13_o
      => ben_pcp_shd.g_old_rec.pcp_attribute13
      ,p_pcp_attribute14_o
      => ben_pcp_shd.g_old_rec.pcp_attribute14
      ,p_pcp_attribute15_o
      => ben_pcp_shd.g_old_rec.pcp_attribute15
      ,p_pcp_attribute16_o
      => ben_pcp_shd.g_old_rec.pcp_attribute16
      ,p_pcp_attribute17_o
      => ben_pcp_shd.g_old_rec.pcp_attribute17
      ,p_pcp_attribute18_o
      => ben_pcp_shd.g_old_rec.pcp_attribute18
      ,p_pcp_attribute19_o
      => ben_pcp_shd.g_old_rec.pcp_attribute19
      ,p_pcp_attribute20_o
      => ben_pcp_shd.g_old_rec.pcp_attribute20
      ,p_pcp_attribute21_o
      => ben_pcp_shd.g_old_rec.pcp_attribute21
      ,p_pcp_attribute22_o
      => ben_pcp_shd.g_old_rec.pcp_attribute22
      ,p_pcp_attribute23_o
      => ben_pcp_shd.g_old_rec.pcp_attribute23
      ,p_pcp_attribute24_o
      => ben_pcp_shd.g_old_rec.pcp_attribute24
      ,p_pcp_attribute25_o
      => ben_pcp_shd.g_old_rec.pcp_attribute25
      ,p_pcp_attribute26_o
      => ben_pcp_shd.g_old_rec.pcp_attribute26
      ,p_pcp_attribute27_o
      => ben_pcp_shd.g_old_rec.pcp_attribute27
      ,p_pcp_attribute28_o
      => ben_pcp_shd.g_old_rec.pcp_attribute28
      ,p_pcp_attribute29_o
      => ben_pcp_shd.g_old_rec.pcp_attribute29
      ,p_pcp_attribute30_o
      => ben_pcp_shd.g_old_rec.pcp_attribute30
      ,p_object_version_number_o
      => ben_pcp_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_PL_PCP'
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
  (p_rec in out nocopy ben_pcp_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.pl_id = hr_api.g_number) then
    p_rec.pl_id :=
    ben_pcp_shd.g_old_rec.pl_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_pcp_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.pcp_strt_dt_cd = hr_api.g_varchar2) then
    p_rec.pcp_strt_dt_cd :=
    ben_pcp_shd.g_old_rec.pcp_strt_dt_cd;
  End If;
  If (p_rec.pcp_dsgn_cd = hr_api.g_varchar2) then
    p_rec.pcp_dsgn_cd :=
    ben_pcp_shd.g_old_rec.pcp_dsgn_cd;
  End If;
  If (p_rec.pcp_dpnt_dsgn_cd = hr_api.g_varchar2) then
    p_rec.pcp_dpnt_dsgn_cd :=
    ben_pcp_shd.g_old_rec.pcp_dpnt_dsgn_cd;
  End If;
  If (p_rec.pcp_rpstry_flag = hr_api.g_varchar2) then
    p_rec.pcp_rpstry_flag :=
    ben_pcp_shd.g_old_rec.pcp_rpstry_flag;
  End If;
  If (p_rec.pcp_can_keep_flag = hr_api.g_varchar2) then
    p_rec.pcp_can_keep_flag :=
    ben_pcp_shd.g_old_rec.pcp_can_keep_flag;
  End If;
  If (p_rec.pcp_radius = hr_api.g_number) then
    p_rec.pcp_radius :=
    ben_pcp_shd.g_old_rec.pcp_radius;
  End If;
  If (p_rec.pcp_radius_uom = hr_api.g_varchar2) then
    p_rec.pcp_radius_uom :=
    ben_pcp_shd.g_old_rec.pcp_radius_uom;
  End If;
  If (p_rec.pcp_radius_warn_flag = hr_api.g_varchar2) then
    p_rec.pcp_radius_warn_flag :=
    ben_pcp_shd.g_old_rec.pcp_radius_warn_flag;
  End If;
  If (p_rec.pcp_num_chgs = hr_api.g_number) then
    p_rec.pcp_num_chgs :=
    ben_pcp_shd.g_old_rec.pcp_num_chgs;
  End If;
  If (p_rec.pcp_num_chgs_uom = hr_api.g_varchar2) then
    p_rec.pcp_num_chgs_uom :=
    ben_pcp_shd.g_old_rec.pcp_num_chgs_uom;
  End If;
  If (p_rec.pcp_attribute_category = hr_api.g_varchar2) then
    p_rec.pcp_attribute_category :=
    ben_pcp_shd.g_old_rec.pcp_attribute_category;
  End If;
  If (p_rec.pcp_attribute1 = hr_api.g_varchar2) then
    p_rec.pcp_attribute1 :=
    ben_pcp_shd.g_old_rec.pcp_attribute1;
  End If;
  If (p_rec.pcp_attribute2 = hr_api.g_varchar2) then
    p_rec.pcp_attribute2 :=
    ben_pcp_shd.g_old_rec.pcp_attribute2;
  End If;
  If (p_rec.pcp_attribute3 = hr_api.g_varchar2) then
    p_rec.pcp_attribute3 :=
    ben_pcp_shd.g_old_rec.pcp_attribute3;
  End If;
  If (p_rec.pcp_attribute4 = hr_api.g_varchar2) then
    p_rec.pcp_attribute4 :=
    ben_pcp_shd.g_old_rec.pcp_attribute4;
  End If;
  If (p_rec.pcp_attribute5 = hr_api.g_varchar2) then
    p_rec.pcp_attribute5 :=
    ben_pcp_shd.g_old_rec.pcp_attribute5;
  End If;
  If (p_rec.pcp_attribute6 = hr_api.g_varchar2) then
    p_rec.pcp_attribute6 :=
    ben_pcp_shd.g_old_rec.pcp_attribute6;
  End If;
  If (p_rec.pcp_attribute7 = hr_api.g_varchar2) then
    p_rec.pcp_attribute7 :=
    ben_pcp_shd.g_old_rec.pcp_attribute7;
  End If;
  If (p_rec.pcp_attribute8 = hr_api.g_varchar2) then
    p_rec.pcp_attribute8 :=
    ben_pcp_shd.g_old_rec.pcp_attribute8;
  End If;
  If (p_rec.pcp_attribute9 = hr_api.g_varchar2) then
    p_rec.pcp_attribute9 :=
    ben_pcp_shd.g_old_rec.pcp_attribute9;
  End If;
  If (p_rec.pcp_attribute10 = hr_api.g_varchar2) then
    p_rec.pcp_attribute10 :=
    ben_pcp_shd.g_old_rec.pcp_attribute10;
  End If;
  If (p_rec.pcp_attribute11 = hr_api.g_varchar2) then
    p_rec.pcp_attribute11 :=
    ben_pcp_shd.g_old_rec.pcp_attribute11;
  End If;
  If (p_rec.pcp_attribute12 = hr_api.g_varchar2) then
    p_rec.pcp_attribute12 :=
    ben_pcp_shd.g_old_rec.pcp_attribute12;
  End If;
  If (p_rec.pcp_attribute13 = hr_api.g_varchar2) then
    p_rec.pcp_attribute13 :=
    ben_pcp_shd.g_old_rec.pcp_attribute13;
  End If;
  If (p_rec.pcp_attribute14 = hr_api.g_varchar2) then
    p_rec.pcp_attribute14 :=
    ben_pcp_shd.g_old_rec.pcp_attribute14;
  End If;
  If (p_rec.pcp_attribute15 = hr_api.g_varchar2) then
    p_rec.pcp_attribute15 :=
    ben_pcp_shd.g_old_rec.pcp_attribute15;
  End If;
  If (p_rec.pcp_attribute16 = hr_api.g_varchar2) then
    p_rec.pcp_attribute16 :=
    ben_pcp_shd.g_old_rec.pcp_attribute16;
  End If;
  If (p_rec.pcp_attribute17 = hr_api.g_varchar2) then
    p_rec.pcp_attribute17 :=
    ben_pcp_shd.g_old_rec.pcp_attribute17;
  End If;
  If (p_rec.pcp_attribute18 = hr_api.g_varchar2) then
    p_rec.pcp_attribute18 :=
    ben_pcp_shd.g_old_rec.pcp_attribute18;
  End If;
  If (p_rec.pcp_attribute19 = hr_api.g_varchar2) then
    p_rec.pcp_attribute19 :=
    ben_pcp_shd.g_old_rec.pcp_attribute19;
  End If;
  If (p_rec.pcp_attribute20 = hr_api.g_varchar2) then
    p_rec.pcp_attribute20 :=
    ben_pcp_shd.g_old_rec.pcp_attribute20;
  End If;
  If (p_rec.pcp_attribute21 = hr_api.g_varchar2) then
    p_rec.pcp_attribute21 :=
    ben_pcp_shd.g_old_rec.pcp_attribute21;
  End If;
  If (p_rec.pcp_attribute22 = hr_api.g_varchar2) then
    p_rec.pcp_attribute22 :=
    ben_pcp_shd.g_old_rec.pcp_attribute22;
  End If;
  If (p_rec.pcp_attribute23 = hr_api.g_varchar2) then
    p_rec.pcp_attribute23 :=
    ben_pcp_shd.g_old_rec.pcp_attribute23;
  End If;
  If (p_rec.pcp_attribute24 = hr_api.g_varchar2) then
    p_rec.pcp_attribute24 :=
    ben_pcp_shd.g_old_rec.pcp_attribute24;
  End If;
  If (p_rec.pcp_attribute25 = hr_api.g_varchar2) then
    p_rec.pcp_attribute25 :=
    ben_pcp_shd.g_old_rec.pcp_attribute25;
  End If;
  If (p_rec.pcp_attribute26 = hr_api.g_varchar2) then
    p_rec.pcp_attribute26 :=
    ben_pcp_shd.g_old_rec.pcp_attribute26;
  End If;
  If (p_rec.pcp_attribute27 = hr_api.g_varchar2) then
    p_rec.pcp_attribute27 :=
    ben_pcp_shd.g_old_rec.pcp_attribute27;
  End If;
  If (p_rec.pcp_attribute28 = hr_api.g_varchar2) then
    p_rec.pcp_attribute28 :=
    ben_pcp_shd.g_old_rec.pcp_attribute28;
  End If;
  If (p_rec.pcp_attribute29 = hr_api.g_varchar2) then
    p_rec.pcp_attribute29 :=
    ben_pcp_shd.g_old_rec.pcp_attribute29;
  End If;
  If (p_rec.pcp_attribute30 = hr_api.g_varchar2) then
    p_rec.pcp_attribute30 :=
    ben_pcp_shd.g_old_rec.pcp_attribute30;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date in date,
   p_rec                          in out nocopy ben_pcp_shd.g_rec_type )
   is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ben_pcp_shd.lck
    (p_rec.pl_pcp_id
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
  ben_pcp_bus.update_validate
     (p_rec
     ,p_effective_date);
  --
  -- Call the supporting pre-update operation
  --
  ben_pcp_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  ben_pcp_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  ben_pcp_upd.post_update
     (p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date in date
  ,p_pl_pcp_id                    in     number
  ,p_object_version_number        in out nocopy number
  ,p_pl_id                        in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_pcp_rpstry_flag              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_can_keep_flag            in     varchar2  default hr_api.g_varchar2
  ,p_pcp_radius_warn_flag         in     varchar2  default hr_api.g_varchar2
  ,p_pcp_strt_dt_cd               in     varchar2  default hr_api.g_varchar2
  ,p_pcp_dsgn_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_pcp_dpnt_dsgn_cd             in     varchar2  default hr_api.g_varchar2
  ,p_pcp_radius                   in     number    default hr_api.g_number
  ,p_pcp_radius_uom               in     varchar2  default hr_api.g_varchar2
  ,p_pcp_num_chgs                 in     number    default hr_api.g_number
  ,p_pcp_num_chgs_uom             in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_pcp_attribute30              in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec	  ben_pcp_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_pcp_shd.convert_args
  (p_pl_pcp_id
  ,p_pl_id
  ,p_business_group_id
  ,p_pcp_strt_dt_cd
  ,p_pcp_dsgn_cd
  ,p_pcp_dpnt_dsgn_cd
  ,p_pcp_rpstry_flag
  ,p_pcp_can_keep_flag
  ,p_pcp_radius
  ,p_pcp_radius_uom
  ,p_pcp_radius_warn_flag
  ,p_pcp_num_chgs
  ,p_pcp_num_chgs_uom
  ,p_pcp_attribute_category
  ,p_pcp_attribute1
  ,p_pcp_attribute2
  ,p_pcp_attribute3
  ,p_pcp_attribute4
  ,p_pcp_attribute5
  ,p_pcp_attribute6
  ,p_pcp_attribute7
  ,p_pcp_attribute8
  ,p_pcp_attribute9
  ,p_pcp_attribute10
  ,p_pcp_attribute11
  ,p_pcp_attribute12
  ,p_pcp_attribute13
  ,p_pcp_attribute14
  ,p_pcp_attribute15
  ,p_pcp_attribute16
  ,p_pcp_attribute17
  ,p_pcp_attribute18
  ,p_pcp_attribute19
  ,p_pcp_attribute20
  ,p_pcp_attribute21
  ,p_pcp_attribute22
  ,p_pcp_attribute23
  ,p_pcp_attribute24
  ,p_pcp_attribute25
  ,p_pcp_attribute26
  ,p_pcp_attribute27
  ,p_pcp_attribute28
  ,p_pcp_attribute29
  ,p_pcp_attribute30
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ben_pcp_upd.upd
     (p_effective_date, l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_pcp_upd;

/

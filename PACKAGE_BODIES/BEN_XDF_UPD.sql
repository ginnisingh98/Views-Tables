--------------------------------------------------------
--  DDL for Package Body BEN_XDF_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XDF_UPD" as
/* $Header: bexdfrhi.pkb 120.6 2006/07/10 21:53:55 tjesumic ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xdf_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy ben_xdf_shd.g_rec_type) is
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
  ben_xdf_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_ext_dfn Row
  --
  update ben_ext_dfn
  set
  ext_dfn_id                        = p_rec.ext_dfn_id,
  name                              = p_rec.name,
  xml_tag_name                      = p_rec.xml_tag_name,
  xdo_template_id                   = p_rec.xdo_template_id,
  data_typ_cd                       = p_rec.data_typ_cd,
  ext_typ_cd                        = p_rec.ext_typ_cd,
  output_name                       = p_rec.output_name,
  output_type                       = p_rec.output_type,
  apnd_rqst_id_flag                 = p_rec.apnd_rqst_id_flag,
  prmy_sort_cd                      = p_rec.prmy_sort_cd,
  scnd_sort_cd                      = p_rec.scnd_sort_cd,
  strt_dt                           = p_rec.strt_dt,
  end_dt                            = p_rec.end_dt,
  ext_crit_prfl_id                  = p_rec.ext_crit_prfl_id,
  ext_file_id                       = p_rec.ext_file_id,
  business_group_id                 = p_rec.business_group_id,
  legislation_code                  = p_rec.legislation_code,
  xdf_attribute_category            = p_rec.xdf_attribute_category,
  xdf_attribute1                    = p_rec.xdf_attribute1,
  xdf_attribute2                    = p_rec.xdf_attribute2,
  xdf_attribute3                    = p_rec.xdf_attribute3,
  xdf_attribute4                    = p_rec.xdf_attribute4,
  xdf_attribute5                    = p_rec.xdf_attribute5,
  xdf_attribute6                    = p_rec.xdf_attribute6,
  xdf_attribute7                    = p_rec.xdf_attribute7,
  xdf_attribute8                    = p_rec.xdf_attribute8,
  xdf_attribute9                    = p_rec.xdf_attribute9,
  xdf_attribute10                   = p_rec.xdf_attribute10,
  xdf_attribute11                   = p_rec.xdf_attribute11,
  xdf_attribute12                   = p_rec.xdf_attribute12,
  xdf_attribute13                   = p_rec.xdf_attribute13,
  xdf_attribute14                   = p_rec.xdf_attribute14,
  xdf_attribute15                   = p_rec.xdf_attribute15,
  xdf_attribute16                   = p_rec.xdf_attribute16,
  xdf_attribute17                   = p_rec.xdf_attribute17,
  xdf_attribute18                   = p_rec.xdf_attribute18,
  xdf_attribute19                   = p_rec.xdf_attribute19,
  xdf_attribute20                   = p_rec.xdf_attribute20,
  xdf_attribute21                   = p_rec.xdf_attribute21,
  xdf_attribute22                   = p_rec.xdf_attribute22,
  xdf_attribute23                   = p_rec.xdf_attribute23,
  xdf_attribute24                   = p_rec.xdf_attribute24,
  xdf_attribute25                   = p_rec.xdf_attribute25,
  xdf_attribute26                   = p_rec.xdf_attribute26,
  xdf_attribute27                   = p_rec.xdf_attribute27,
  xdf_attribute28                   = p_rec.xdf_attribute28,
  xdf_attribute29                   = p_rec.xdf_attribute29,
  xdf_attribute30                   = p_rec.xdf_attribute30,
  last_update_date                  = p_rec.last_update_date,
  last_updated_by                   = p_rec.last_updated_by,
  last_update_login                 = p_rec.last_update_login,
  object_version_number             = p_rec.object_version_number,
  drctry_name                       = p_rec.drctry_name,
  kickoff_wrt_prc_flag              = p_rec.kickoff_wrt_prc_flag,
  upd_cm_sent_dt_flag               = p_rec.upd_cm_sent_dt_flag,
  spcl_hndl_flag                    = p_rec.spcl_hndl_flag,
  ext_global_flag                   = p_rec.ext_global_flag,
  cm_display_flag                   = p_rec.cm_display_flag,
  use_eff_dt_for_chgs_flag          = p_rec.use_eff_dt_for_chgs_flag,
  ext_post_prcs_rl                  = p_rec.ext_post_prcs_rl
  where ext_dfn_id = p_rec.ext_dfn_id;
  --
  ben_xdf_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_xdf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xdf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_xdf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xdf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_xdf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xdf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_xdf_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in ben_xdf_shd.g_rec_type) is
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
p_effective_date in date,p_rec in ben_xdf_shd.g_rec_type) is
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
    ben_xdf_rku.after_update
      (
  p_ext_dfn_id                    =>p_rec.ext_dfn_id
 ,p_name                          =>p_rec.name
 ,p_xml_tag_name                  =>p_rec.xml_tag_name
 ,p_xdo_template_id               =>p_rec.xdo_template_id
 ,p_data_typ_cd                   =>p_rec.data_typ_cd
 ,p_ext_typ_cd                    =>p_rec.ext_typ_cd
 ,p_output_name                   =>p_rec.output_name
 ,p_output_type                   =>p_rec.output_type
 ,p_apnd_rqst_id_flag             =>p_rec.apnd_rqst_id_flag
 ,p_prmy_sort_cd                  =>p_rec.prmy_sort_cd
 ,p_scnd_sort_cd                  =>p_rec.scnd_sort_cd
 ,p_strt_dt                       =>p_rec.strt_dt
 ,p_end_dt                        =>p_rec.end_dt
 ,p_ext_crit_prfl_id              =>p_rec.ext_crit_prfl_id
 ,p_ext_file_id                   =>p_rec.ext_file_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_legislation_code              =>p_rec.legislation_code
 ,p_xdf_attribute_category        =>p_rec.xdf_attribute_category
 ,p_xdf_attribute1                =>p_rec.xdf_attribute1
 ,p_xdf_attribute2                =>p_rec.xdf_attribute2
 ,p_xdf_attribute3                =>p_rec.xdf_attribute3
 ,p_xdf_attribute4                =>p_rec.xdf_attribute4
 ,p_xdf_attribute5                =>p_rec.xdf_attribute5
 ,p_xdf_attribute6                =>p_rec.xdf_attribute6
 ,p_xdf_attribute7                =>p_rec.xdf_attribute7
 ,p_xdf_attribute8                =>p_rec.xdf_attribute8
 ,p_xdf_attribute9                =>p_rec.xdf_attribute9
 ,p_xdf_attribute10               =>p_rec.xdf_attribute10
 ,p_xdf_attribute11               =>p_rec.xdf_attribute11
 ,p_xdf_attribute12               =>p_rec.xdf_attribute12
 ,p_xdf_attribute13               =>p_rec.xdf_attribute13
 ,p_xdf_attribute14               =>p_rec.xdf_attribute14
 ,p_xdf_attribute15               =>p_rec.xdf_attribute15
 ,p_xdf_attribute16               =>p_rec.xdf_attribute16
 ,p_xdf_attribute17               =>p_rec.xdf_attribute17
 ,p_xdf_attribute18               =>p_rec.xdf_attribute18
 ,p_xdf_attribute19               =>p_rec.xdf_attribute19
 ,p_xdf_attribute20               =>p_rec.xdf_attribute20
 ,p_xdf_attribute21               =>p_rec.xdf_attribute21
 ,p_xdf_attribute22               =>p_rec.xdf_attribute22
 ,p_xdf_attribute23               =>p_rec.xdf_attribute23
 ,p_xdf_attribute24               =>p_rec.xdf_attribute24
 ,p_xdf_attribute25               =>p_rec.xdf_attribute25
 ,p_xdf_attribute26               =>p_rec.xdf_attribute26
 ,p_xdf_attribute27               =>p_rec.xdf_attribute27
 ,p_xdf_attribute28               =>p_rec.xdf_attribute28
 ,p_xdf_attribute29               =>p_rec.xdf_attribute29
 ,p_xdf_attribute30               =>p_rec.xdf_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_drctry_name                   =>p_rec.drctry_name
 ,p_kickoff_wrt_prc_flag          =>p_rec.kickoff_wrt_prc_flag
 ,p_upd_cm_sent_dt_flag           =>p_rec.upd_cm_sent_dt_flag
 ,p_spcl_hndl_flag                =>p_rec.spcl_hndl_flag
 ,p_ext_global_flag               =>p_rec.ext_global_flag
 ,p_cm_display_flag               =>p_rec.cm_display_flag
 ,p_use_eff_dt_for_chgs_flag      =>p_rec.use_eff_dt_for_chgs_flag
 ,p_ext_post_prcs_rl              =>p_rec.ext_post_prcs_rl
 ,p_effective_date                =>p_effective_date
 ,p_name_o                        =>ben_xdf_shd.g_old_rec.name
 ,p_xml_tag_name_o                =>ben_xdf_shd.g_old_rec.xml_tag_name
 ,p_xdo_template_id_o             =>ben_xdf_shd.g_old_rec.xdo_template_id
 ,p_data_typ_cd_o                 =>ben_xdf_shd.g_old_rec.data_typ_cd
 ,p_ext_typ_cd_o                  =>ben_xdf_shd.g_old_rec.ext_typ_cd
 ,p_output_name_o                 =>ben_xdf_shd.g_old_rec.output_name
 ,p_output_type_o                 =>ben_xdf_shd.g_old_rec.output_type
 ,p_apnd_rqst_id_flag_o           =>ben_xdf_shd.g_old_rec.apnd_rqst_id_flag
 ,p_prmy_sort_cd_o                =>ben_xdf_shd.g_old_rec.prmy_sort_cd
 ,p_scnd_sort_cd_o                =>ben_xdf_shd.g_old_rec.scnd_sort_cd
 ,p_strt_dt_o                     =>ben_xdf_shd.g_old_rec.strt_dt
 ,p_end_dt_o                      =>ben_xdf_shd.g_old_rec.end_dt
 ,p_ext_crit_prfl_id_o            =>ben_xdf_shd.g_old_rec.ext_crit_prfl_id
 ,p_ext_file_id_o                 =>ben_xdf_shd.g_old_rec.ext_file_id
 ,p_business_group_id_o           =>ben_xdf_shd.g_old_rec.business_group_id
 ,p_legislation_code_o            =>ben_xdf_shd.g_old_rec.legislation_code
 ,p_xdf_attribute_category_o      =>ben_xdf_shd.g_old_rec.xdf_attribute_category
 ,p_xdf_attribute1_o              =>ben_xdf_shd.g_old_rec.xdf_attribute1
 ,p_xdf_attribute2_o              =>ben_xdf_shd.g_old_rec.xdf_attribute2
 ,p_xdf_attribute3_o              =>ben_xdf_shd.g_old_rec.xdf_attribute3
 ,p_xdf_attribute4_o              =>ben_xdf_shd.g_old_rec.xdf_attribute4
 ,p_xdf_attribute5_o              =>ben_xdf_shd.g_old_rec.xdf_attribute5
 ,p_xdf_attribute6_o              =>ben_xdf_shd.g_old_rec.xdf_attribute6
 ,p_xdf_attribute7_o              =>ben_xdf_shd.g_old_rec.xdf_attribute7
 ,p_xdf_attribute8_o              =>ben_xdf_shd.g_old_rec.xdf_attribute8
 ,p_xdf_attribute9_o              =>ben_xdf_shd.g_old_rec.xdf_attribute9
 ,p_xdf_attribute10_o             =>ben_xdf_shd.g_old_rec.xdf_attribute10
 ,p_xdf_attribute11_o             =>ben_xdf_shd.g_old_rec.xdf_attribute11
 ,p_xdf_attribute12_o             =>ben_xdf_shd.g_old_rec.xdf_attribute12
 ,p_xdf_attribute13_o             =>ben_xdf_shd.g_old_rec.xdf_attribute13
 ,p_xdf_attribute14_o             =>ben_xdf_shd.g_old_rec.xdf_attribute14
 ,p_xdf_attribute15_o             =>ben_xdf_shd.g_old_rec.xdf_attribute15
 ,p_xdf_attribute16_o             =>ben_xdf_shd.g_old_rec.xdf_attribute16
 ,p_xdf_attribute17_o             =>ben_xdf_shd.g_old_rec.xdf_attribute17
 ,p_xdf_attribute18_o             =>ben_xdf_shd.g_old_rec.xdf_attribute18
 ,p_xdf_attribute19_o             =>ben_xdf_shd.g_old_rec.xdf_attribute19
 ,p_xdf_attribute20_o             =>ben_xdf_shd.g_old_rec.xdf_attribute20
 ,p_xdf_attribute21_o             =>ben_xdf_shd.g_old_rec.xdf_attribute21
 ,p_xdf_attribute22_o             =>ben_xdf_shd.g_old_rec.xdf_attribute22
 ,p_xdf_attribute23_o             =>ben_xdf_shd.g_old_rec.xdf_attribute23
 ,p_xdf_attribute24_o             =>ben_xdf_shd.g_old_rec.xdf_attribute24
 ,p_xdf_attribute25_o             =>ben_xdf_shd.g_old_rec.xdf_attribute25
 ,p_xdf_attribute26_o             =>ben_xdf_shd.g_old_rec.xdf_attribute26
 ,p_xdf_attribute27_o             =>ben_xdf_shd.g_old_rec.xdf_attribute27
 ,p_xdf_attribute28_o             =>ben_xdf_shd.g_old_rec.xdf_attribute28
 ,p_xdf_attribute29_o             =>ben_xdf_shd.g_old_rec.xdf_attribute29
 ,p_xdf_attribute30_o             =>ben_xdf_shd.g_old_rec.xdf_attribute30
 ,p_object_version_number_o       =>ben_xdf_shd.g_old_rec.object_version_number
 ,p_drctry_name_o                 =>ben_xdf_shd.g_old_rec.drctry_name
 ,p_kickoff_wrt_prc_flag_o        =>ben_xdf_shd.g_old_rec.kickoff_wrt_prc_flag
 ,p_upd_cm_sent_dt_flag_o         =>ben_xdf_shd.g_old_rec.upd_cm_sent_dt_flag
 ,p_spcl_hndl_flag_o              =>ben_xdf_shd.g_old_rec.spcl_hndl_flag
 ,p_ext_global_flag_o             =>ben_xdf_shd.g_old_rec.ext_global_flag
 ,p_cm_display_flag_o             =>ben_xdf_shd.g_old_rec.cm_display_flag
 ,p_use_eff_dt_for_chgs_flag_o    =>ben_xdf_shd.g_old_rec.use_eff_dt_for_chgs_flag
 ,p_ext_post_prcs_rl_o            =>ben_xdf_shd.g_old_rec.ext_post_prcs_rl
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_ext_dfn'
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
Procedure convert_defs(p_rec in out nocopy ben_xdf_shd.g_rec_type) is
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
    ben_xdf_shd.g_old_rec.name;
  End If;

  If (p_rec.xml_tag_name = hr_api.g_varchar2) then
    p_rec.xml_tag_name :=
    ben_xdf_shd.g_old_rec.xml_tag_name;
  End If;

  If (p_rec.xdo_template_id = hr_api.g_number) then
    p_rec.xdo_template_id :=
    ben_xdf_shd.g_old_rec.xdo_template_id;
  End If;

  If (p_rec.data_typ_cd = hr_api.g_varchar2) then
    p_rec.data_typ_cd :=
    ben_xdf_shd.g_old_rec.data_typ_cd;
  End If;
  If (p_rec.ext_typ_cd = hr_api.g_varchar2) then
    p_rec.ext_typ_cd :=
    ben_xdf_shd.g_old_rec.ext_typ_cd;
  End If;
  If (p_rec.output_name = hr_api.g_varchar2) then
    p_rec.output_name :=
    ben_xdf_shd.g_old_rec.output_name;
  End If;
  If (p_rec.apnd_rqst_id_flag = hr_api.g_varchar2) then
    p_rec.apnd_rqst_id_flag :=
    ben_xdf_shd.g_old_rec.apnd_rqst_id_flag;
  End If;
  If (p_rec.prmy_sort_cd = hr_api.g_varchar2) then
    p_rec.prmy_sort_cd :=
    ben_xdf_shd.g_old_rec.prmy_sort_cd;
  End If;
  If (p_rec.scnd_sort_cd = hr_api.g_varchar2) then
    p_rec.scnd_sort_cd :=
    ben_xdf_shd.g_old_rec.scnd_sort_cd;
  End If;
  If (p_rec.strt_dt = hr_api.g_varchar2) then
    p_rec.strt_dt :=
    ben_xdf_shd.g_old_rec.strt_dt;
  End If;
  If (p_rec.end_dt = hr_api.g_varchar2) then
    p_rec.end_dt :=
    ben_xdf_shd.g_old_rec.end_dt;
  End If;
  If (p_rec.ext_crit_prfl_id = hr_api.g_number) then
    p_rec.ext_crit_prfl_id :=
    ben_xdf_shd.g_old_rec.ext_crit_prfl_id;
  End If;
  If (p_rec.ext_file_id = hr_api.g_number) then
    p_rec.ext_file_id :=
    ben_xdf_shd.g_old_rec.ext_file_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_xdf_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.legislation_code = hr_api.g_varchar2) then
    p_rec.legislation_code :=
    ben_xdf_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.xdf_attribute_category = hr_api.g_varchar2) then
    p_rec.xdf_attribute_category :=
    ben_xdf_shd.g_old_rec.xdf_attribute_category;
  End If;
  If (p_rec.xdf_attribute1 = hr_api.g_varchar2) then
    p_rec.xdf_attribute1 :=
    ben_xdf_shd.g_old_rec.xdf_attribute1;
  End If;
  If (p_rec.xdf_attribute2 = hr_api.g_varchar2) then
    p_rec.xdf_attribute2 :=
    ben_xdf_shd.g_old_rec.xdf_attribute2;
  End If;
  If (p_rec.xdf_attribute3 = hr_api.g_varchar2) then
    p_rec.xdf_attribute3 :=
    ben_xdf_shd.g_old_rec.xdf_attribute3;
  End If;
  If (p_rec.xdf_attribute4 = hr_api.g_varchar2) then
    p_rec.xdf_attribute4 :=
    ben_xdf_shd.g_old_rec.xdf_attribute4;
  End If;
  If (p_rec.xdf_attribute5 = hr_api.g_varchar2) then
    p_rec.xdf_attribute5 :=
    ben_xdf_shd.g_old_rec.xdf_attribute5;
  End If;
  If (p_rec.xdf_attribute6 = hr_api.g_varchar2) then
    p_rec.xdf_attribute6 :=
    ben_xdf_shd.g_old_rec.xdf_attribute6;
  End If;
  If (p_rec.xdf_attribute7 = hr_api.g_varchar2) then
    p_rec.xdf_attribute7 :=
    ben_xdf_shd.g_old_rec.xdf_attribute7;
  End If;
  If (p_rec.xdf_attribute8 = hr_api.g_varchar2) then
    p_rec.xdf_attribute8 :=
    ben_xdf_shd.g_old_rec.xdf_attribute8;
  End If;
  If (p_rec.xdf_attribute9 = hr_api.g_varchar2) then
    p_rec.xdf_attribute9 :=
    ben_xdf_shd.g_old_rec.xdf_attribute9;
  End If;
  If (p_rec.xdf_attribute10 = hr_api.g_varchar2) then
    p_rec.xdf_attribute10 :=
    ben_xdf_shd.g_old_rec.xdf_attribute10;
  End If;
  If (p_rec.xdf_attribute11 = hr_api.g_varchar2) then
    p_rec.xdf_attribute11 :=
    ben_xdf_shd.g_old_rec.xdf_attribute11;
  End If;
  If (p_rec.xdf_attribute12 = hr_api.g_varchar2) then
    p_rec.xdf_attribute12 :=
    ben_xdf_shd.g_old_rec.xdf_attribute12;
  End If;
  If (p_rec.xdf_attribute13 = hr_api.g_varchar2) then
    p_rec.xdf_attribute13 :=
    ben_xdf_shd.g_old_rec.xdf_attribute13;
  End If;
  If (p_rec.xdf_attribute14 = hr_api.g_varchar2) then
    p_rec.xdf_attribute14 :=
    ben_xdf_shd.g_old_rec.xdf_attribute14;
  End If;
  If (p_rec.xdf_attribute15 = hr_api.g_varchar2) then
    p_rec.xdf_attribute15 :=
    ben_xdf_shd.g_old_rec.xdf_attribute15;
  End If;
  If (p_rec.xdf_attribute16 = hr_api.g_varchar2) then
    p_rec.xdf_attribute16 :=
    ben_xdf_shd.g_old_rec.xdf_attribute16;
  End If;
  If (p_rec.xdf_attribute17 = hr_api.g_varchar2) then
    p_rec.xdf_attribute17 :=
    ben_xdf_shd.g_old_rec.xdf_attribute17;
  End If;
  If (p_rec.xdf_attribute18 = hr_api.g_varchar2) then
    p_rec.xdf_attribute18 :=
    ben_xdf_shd.g_old_rec.xdf_attribute18;
  End If;
  If (p_rec.xdf_attribute19 = hr_api.g_varchar2) then
    p_rec.xdf_attribute19 :=
    ben_xdf_shd.g_old_rec.xdf_attribute19;
  End If;
  If (p_rec.xdf_attribute20 = hr_api.g_varchar2) then
    p_rec.xdf_attribute20 :=
    ben_xdf_shd.g_old_rec.xdf_attribute20;
  End If;
  If (p_rec.xdf_attribute21 = hr_api.g_varchar2) then
    p_rec.xdf_attribute21 :=
    ben_xdf_shd.g_old_rec.xdf_attribute21;
  End If;
  If (p_rec.xdf_attribute22 = hr_api.g_varchar2) then
    p_rec.xdf_attribute22 :=
    ben_xdf_shd.g_old_rec.xdf_attribute22;
  End If;
  If (p_rec.xdf_attribute23 = hr_api.g_varchar2) then
    p_rec.xdf_attribute23 :=
    ben_xdf_shd.g_old_rec.xdf_attribute23;
  End If;
  If (p_rec.xdf_attribute24 = hr_api.g_varchar2) then
    p_rec.xdf_attribute24 :=
    ben_xdf_shd.g_old_rec.xdf_attribute24;
  End If;
  If (p_rec.xdf_attribute25 = hr_api.g_varchar2) then
    p_rec.xdf_attribute25 :=
    ben_xdf_shd.g_old_rec.xdf_attribute25;
  End If;
  If (p_rec.xdf_attribute26 = hr_api.g_varchar2) then
    p_rec.xdf_attribute26 :=
    ben_xdf_shd.g_old_rec.xdf_attribute26;
  End If;
  If (p_rec.xdf_attribute27 = hr_api.g_varchar2) then
    p_rec.xdf_attribute27 :=
    ben_xdf_shd.g_old_rec.xdf_attribute27;
  End If;
  If (p_rec.xdf_attribute28 = hr_api.g_varchar2) then
    p_rec.xdf_attribute28 :=
    ben_xdf_shd.g_old_rec.xdf_attribute28;
  End If;
  If (p_rec.xdf_attribute29 = hr_api.g_varchar2) then
    p_rec.xdf_attribute29 :=
    ben_xdf_shd.g_old_rec.xdf_attribute29;
  End If;
  If (p_rec.xdf_attribute30 = hr_api.g_varchar2) then
    p_rec.xdf_attribute30 :=
    ben_xdf_shd.g_old_rec.xdf_attribute30;
  End If;
  If (p_rec.drctry_name = hr_api.g_varchar2) then
    p_rec.drctry_name :=
    ben_xdf_shd.g_old_rec.drctry_name;
  End If;
  If (p_rec.kickoff_wrt_prc_flag = hr_api.g_varchar2) then
    p_rec.kickoff_wrt_prc_flag :=
    ben_xdf_shd.g_old_rec.kickoff_wrt_prc_flag;
  End If;
  If (p_rec.upd_cm_sent_dt_flag = hr_api.g_varchar2) then
    p_rec.upd_cm_sent_dt_flag :=
    ben_xdf_shd.g_old_rec.upd_cm_sent_dt_flag;
  End If;
  If (p_rec.spcl_hndl_flag = hr_api.g_varchar2) then
    p_rec.spcl_hndl_flag :=
    ben_xdf_shd.g_old_rec.spcl_hndl_flag;
  End If;

  If (p_rec.ext_global_flag = hr_api.g_varchar2) then
    p_rec.ext_global_flag :=
    ben_xdf_shd.g_old_rec.ext_global_flag;
  End If;

  If (p_rec.cm_display_flag = hr_api.g_varchar2) then
    p_rec.cm_display_flag :=
    ben_xdf_shd.g_old_rec.cm_display_flag;
  End If;

  If (p_rec.use_eff_dt_for_chgs_flag = hr_api.g_varchar2) then
    p_rec.use_eff_dt_for_chgs_flag :=
    ben_xdf_shd.g_old_rec.use_eff_dt_for_chgs_flag;
  End If;
  If (p_rec.ext_post_prcs_rl = hr_api.g_number) then
    p_rec.ext_post_prcs_rl :=
    ben_xdf_shd.g_old_rec.ext_post_prcs_rl;
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
  p_rec        in out nocopy ben_xdf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ben_xdf_shd.lck
	(
	p_rec.ext_dfn_id,
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
  ben_xdf_bus.update_validate(p_rec
  ,p_effective_date);
  --- vlidate the xml_tag_name
  ben_xel_bus.chk_xml_name_format
          ( p_xml_tag_name    => p_rec.xml_tag_name
          ) ;
  ---
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
  p_ext_dfn_id                   in number,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_xml_tag_name                 in varchar2         default hr_api.g_varchar2,
  p_xdo_template_id              in number         default hr_api.g_number,
  p_data_typ_cd                  in varchar2         default hr_api.g_varchar2,
  p_ext_typ_cd                   in varchar2         default hr_api.g_varchar2,
  p_output_name                  in varchar2         default hr_api.g_varchar2,
  p_output_type                  in varchar2         default hr_api.g_varchar2,
  p_apnd_rqst_id_flag            in varchar2         default hr_api.g_varchar2,
  p_prmy_sort_cd                 in varchar2         default hr_api.g_varchar2,
  p_scnd_sort_cd                 in varchar2         default hr_api.g_varchar2,
  p_strt_dt                      in varchar2         default hr_api.g_varchar2,
  p_end_dt                       in varchar2         default hr_api.g_varchar2,
  p_ext_crit_prfl_id             in number           default hr_api.g_number,
  p_ext_file_id                  in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_legislation_code             in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute1               in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute2               in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute3               in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute4               in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute5               in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute6               in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute7               in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute8               in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute9               in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute10              in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute11              in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute12              in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute13              in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute14              in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute15              in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute16              in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute17              in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute18              in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute19              in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute20              in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute21              in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute22              in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute23              in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute24              in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute25              in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute26              in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute27              in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute28              in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute29              in varchar2         default hr_api.g_varchar2,
  p_xdf_attribute30              in varchar2         default hr_api.g_varchar2,
  p_last_update_date             in date             default hr_api.g_date,
  p_creation_date                in date             default hr_api.g_date,
  p_last_updated_by              in number           default hr_api.g_number,
  p_last_update_login            in number           default hr_api.g_number,
  p_created_by                   in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_drctry_name                  in varchar2         default hr_api.g_varchar2,
  p_kickoff_wrt_prc_flag         in varchar2         default hr_api.g_varchar2,
  p_upd_cm_sent_dt_flag          in varchar2         default hr_api.g_varchar2,
  p_spcl_hndl_flag               in varchar2         default hr_api.g_varchar2,
  p_ext_global_flag              in varchar2         default hr_api.g_varchar2,
  p_cm_display_flag              in varchar2         default hr_api.g_varchar2,
  p_use_eff_dt_for_chgs_flag     in varchar2         default hr_api.g_varchar2,
  p_ext_post_prcs_rl             in number           default hr_api.g_number
  ) is
--
  l_rec	  ben_xdf_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_xdf_shd.convert_args
  (
  p_ext_dfn_id,
  p_name,
  p_xml_tag_name,
  p_xdo_template_id,
  p_data_typ_cd,
  p_ext_typ_cd,
  p_output_name,
  p_output_type,
  p_apnd_rqst_id_flag,
  p_prmy_sort_cd,
  p_scnd_sort_cd,
  p_strt_dt,
  p_end_dt,
  p_ext_crit_prfl_id,
  p_ext_file_id,
  p_business_group_id,
  p_legislation_code,
  p_xdf_attribute_category,
  p_xdf_attribute1,
  p_xdf_attribute2,
  p_xdf_attribute3,
  p_xdf_attribute4,
  p_xdf_attribute5,
  p_xdf_attribute6,
  p_xdf_attribute7,
  p_xdf_attribute8,
  p_xdf_attribute9,
  p_xdf_attribute10,
  p_xdf_attribute11,
  p_xdf_attribute12,
  p_xdf_attribute13,
  p_xdf_attribute14,
  p_xdf_attribute15,
  p_xdf_attribute16,
  p_xdf_attribute17,
  p_xdf_attribute18,
  p_xdf_attribute19,
  p_xdf_attribute20,
  p_xdf_attribute21,
  p_xdf_attribute22,
  p_xdf_attribute23,
  p_xdf_attribute24,
  p_xdf_attribute25,
  p_xdf_attribute26,
  p_xdf_attribute27,
  p_xdf_attribute28,
  p_xdf_attribute29,
  p_xdf_attribute30,
  p_last_update_date ,
  p_creation_date    ,
  p_last_updated_by  ,
  p_last_update_login,
  p_created_by       ,
  p_object_version_number,
  p_drctry_name,
  p_kickoff_wrt_prc_flag,
  p_upd_cm_sent_dt_flag,
  p_spcl_hndl_flag,
  p_ext_global_flag,
  p_cm_display_flag,
  p_use_eff_dt_for_chgs_flag,
  p_ext_post_prcs_rl
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
end ben_xdf_upd;

/

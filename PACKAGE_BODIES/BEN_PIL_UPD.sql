--------------------------------------------------------
--  DDL for Package Body BEN_PIL_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PIL_UPD" as
/* $Header: bepilrhi.pkb 120.3 2006/09/26 10:56:35 bmanyam noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pil_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy ben_pil_shd.g_rec_type) is
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
  ben_pil_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_per_in_ler Row
  --
  update ben_per_in_ler
  set
  per_in_ler_id                     = p_rec.per_in_ler_id,
  per_in_ler_stat_cd                = p_rec.per_in_ler_stat_cd,
  prvs_stat_cd                      = p_rec.prvs_stat_cd,
  lf_evt_ocrd_dt                    = p_rec.lf_evt_ocrd_dt,
  trgr_table_pk_id                  = p_rec.trgr_table_pk_id,
  procd_dt                          = p_rec.procd_dt,
  strtd_dt                          = p_rec.strtd_dt,
  voidd_dt                          = p_rec.voidd_dt,
  bckt_dt                           = p_rec.bckt_dt,
  clsd_dt                           = p_rec.clsd_dt,
  ntfn_dt                           = p_rec.ntfn_dt,
  ptnl_ler_for_per_id               = p_rec.ptnl_ler_for_per_id,
  bckt_per_in_ler_id                = p_rec.bckt_per_in_ler_id,
  ler_id                            = p_rec.ler_id,
  person_id                         = p_rec.person_id,
  business_group_id                 = p_rec.business_group_id,
  ASSIGNMENT_ID                     = p_rec.ASSIGNMENT_ID,
  WS_MGR_ID                         = p_rec.WS_MGR_ID,
  GROUP_PL_ID                       = p_rec.GROUP_PL_ID,
  MGR_OVRID_PERSON_ID               = p_rec.MGR_OVRID_PERSON_ID,
  MGR_OVRID_DT                      = p_rec.MGR_OVRID_DT,
  pil_attribute_category            = p_rec.pil_attribute_category,
  pil_attribute1                    = p_rec.pil_attribute1,
  pil_attribute2                    = p_rec.pil_attribute2,
  pil_attribute3                    = p_rec.pil_attribute3,
  pil_attribute4                    = p_rec.pil_attribute4,
  pil_attribute5                    = p_rec.pil_attribute5,
  pil_attribute6                    = p_rec.pil_attribute6,
  pil_attribute7                    = p_rec.pil_attribute7,
  pil_attribute8                    = p_rec.pil_attribute8,
  pil_attribute9                    = p_rec.pil_attribute9,
  pil_attribute10                   = p_rec.pil_attribute10,
  pil_attribute11                   = p_rec.pil_attribute11,
  pil_attribute12                   = p_rec.pil_attribute12,
  pil_attribute13                   = p_rec.pil_attribute13,
  pil_attribute14                   = p_rec.pil_attribute14,
  pil_attribute15                   = p_rec.pil_attribute15,
  pil_attribute16                   = p_rec.pil_attribute16,
  pil_attribute17                   = p_rec.pil_attribute17,
  pil_attribute18                   = p_rec.pil_attribute18,
  pil_attribute19                   = p_rec.pil_attribute19,
  pil_attribute20                   = p_rec.pil_attribute20,
  pil_attribute21                   = p_rec.pil_attribute21,
  pil_attribute22                   = p_rec.pil_attribute22,
  pil_attribute23                   = p_rec.pil_attribute23,
  pil_attribute24                   = p_rec.pil_attribute24,
  pil_attribute25                   = p_rec.pil_attribute25,
  pil_attribute26                   = p_rec.pil_attribute26,
  pil_attribute27                   = p_rec.pil_attribute27,
  pil_attribute28                   = p_rec.pil_attribute28,
  pil_attribute29                   = p_rec.pil_attribute29,
  pil_attribute30                   = p_rec.pil_attribute30,
  request_id                        = p_rec.request_id,
  program_application_id            = p_rec.program_application_id,
  program_id                        = p_rec.program_id,
  program_update_date               = p_rec.program_update_date,
  object_version_number             = p_rec.object_version_number
  where per_in_ler_id = p_rec.per_in_ler_id;
  --
  ben_pil_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_pil_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pil_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_pil_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pil_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_pil_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pil_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_pil_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in ben_pil_shd.g_rec_type) is
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
p_effective_date in date,p_rec in ben_pil_shd.g_rec_type) is
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
    ben_pil_rku.after_update
      (
  p_per_in_ler_id                 =>p_rec.per_in_ler_id
 ,p_per_in_ler_stat_cd            =>p_rec.per_in_ler_stat_cd
 ,p_prvs_stat_cd                  =>p_rec.prvs_stat_cd
 ,p_lf_evt_ocrd_dt                =>p_rec.lf_evt_ocrd_dt
 ,p_trgr_table_pk_id              =>p_rec.trgr_table_pk_id
 ,p_procd_dt                      =>p_rec.procd_dt
 ,p_strtd_dt                      =>p_rec.strtd_dt
 ,p_voidd_dt                      =>p_rec.voidd_dt
 ,p_bckt_dt                       =>p_rec.bckt_dt
 ,p_clsd_dt                       =>p_rec.clsd_dt
 ,p_ntfn_dt                       =>p_rec.ntfn_dt
 ,p_ptnl_ler_for_per_id           =>p_rec.ptnl_ler_for_per_id
 ,p_bckt_per_in_ler_id            =>p_rec.bckt_per_in_ler_id
 ,p_ler_id                        =>p_rec.ler_id
 ,p_person_id                     =>p_rec.person_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_ASSIGNMENT_ID                  =>  p_rec.ASSIGNMENT_ID
 ,p_WS_MGR_ID                      =>  p_rec.WS_MGR_ID
 ,p_GROUP_PL_ID                    =>  p_rec.GROUP_PL_ID
 ,p_MGR_OVRID_PERSON_ID            =>  p_rec.MGR_OVRID_PERSON_ID
 ,p_MGR_OVRID_DT                   =>  p_rec.MGR_OVRID_DT
 ,p_pil_attribute_category        =>p_rec.pil_attribute_category
 ,p_pil_attribute1                =>p_rec.pil_attribute1
 ,p_pil_attribute2                =>p_rec.pil_attribute2
 ,p_pil_attribute3                =>p_rec.pil_attribute3
 ,p_pil_attribute4                =>p_rec.pil_attribute4
 ,p_pil_attribute5                =>p_rec.pil_attribute5
 ,p_pil_attribute6                =>p_rec.pil_attribute6
 ,p_pil_attribute7                =>p_rec.pil_attribute7
 ,p_pil_attribute8                =>p_rec.pil_attribute8
 ,p_pil_attribute9                =>p_rec.pil_attribute9
 ,p_pil_attribute10               =>p_rec.pil_attribute10
 ,p_pil_attribute11               =>p_rec.pil_attribute11
 ,p_pil_attribute12               =>p_rec.pil_attribute12
 ,p_pil_attribute13               =>p_rec.pil_attribute13
 ,p_pil_attribute14               =>p_rec.pil_attribute14
 ,p_pil_attribute15               =>p_rec.pil_attribute15
 ,p_pil_attribute16               =>p_rec.pil_attribute16
 ,p_pil_attribute17               =>p_rec.pil_attribute17
 ,p_pil_attribute18               =>p_rec.pil_attribute18
 ,p_pil_attribute19               =>p_rec.pil_attribute19
 ,p_pil_attribute20               =>p_rec.pil_attribute20
 ,p_pil_attribute21               =>p_rec.pil_attribute21
 ,p_pil_attribute22               =>p_rec.pil_attribute22
 ,p_pil_attribute23               =>p_rec.pil_attribute23
 ,p_pil_attribute24               =>p_rec.pil_attribute24
 ,p_pil_attribute25               =>p_rec.pil_attribute25
 ,p_pil_attribute26               =>p_rec.pil_attribute26
 ,p_pil_attribute27               =>p_rec.pil_attribute27
 ,p_pil_attribute28               =>p_rec.pil_attribute28
 ,p_pil_attribute29               =>p_rec.pil_attribute29
 ,p_pil_attribute30               =>p_rec.pil_attribute30
 ,p_request_id                    =>p_rec.request_id
 ,p_program_application_id        =>p_rec.program_application_id
 ,p_program_id                    =>p_rec.program_id
 ,p_program_update_date           =>p_rec.program_update_date
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_per_in_ler_stat_cd_o          =>ben_pil_shd.g_old_rec.per_in_ler_stat_cd
 ,p_prvs_stat_cd_o                =>ben_pil_shd.g_old_rec.prvs_stat_cd
 ,p_lf_evt_ocrd_dt_o              =>ben_pil_shd.g_old_rec.lf_evt_ocrd_dt
 ,p_trgr_table_pk_id_o            =>ben_pil_shd.g_old_rec.trgr_table_pk_id
 ,p_procd_dt_o                    =>ben_pil_shd.g_old_rec.procd_dt
 ,p_strtd_dt_o                    =>ben_pil_shd.g_old_rec.strtd_dt
 ,p_voidd_dt_o                    =>ben_pil_shd.g_old_rec.voidd_dt
 ,p_bckt_dt_o                     =>ben_pil_shd.g_old_rec.bckt_dt
 ,p_clsd_dt_o                     =>ben_pil_shd.g_old_rec.clsd_dt
 ,p_ntfn_dt_o                     =>ben_pil_shd.g_old_rec.ntfn_dt
 ,p_ptnl_ler_for_per_id_o         =>ben_pil_shd.g_old_rec.ptnl_ler_for_per_id
 ,p_bckt_per_in_ler_id_o          =>ben_pil_shd.g_old_rec.bckt_per_in_ler_id
 ,p_ler_id_o                      =>ben_pil_shd.g_old_rec.ler_id
 ,p_person_id_o                   =>ben_pil_shd.g_old_rec.person_id
 ,p_business_group_id_o           =>ben_pil_shd.g_old_rec.business_group_id
 ,p_ASSIGNMENT_ID_o                =>  ben_pil_shd.g_old_rec.ASSIGNMENT_ID
 ,p_WS_MGR_ID_o                    =>  ben_pil_shd.g_old_rec.WS_MGR_ID
 ,p_GROUP_PL_ID_o                  =>  ben_pil_shd.g_old_rec.GROUP_PL_ID
 ,p_MGR_OVRID_PERSON_ID_o          =>  ben_pil_shd.g_old_rec.MGR_OVRID_PERSON_ID
 ,p_MGR_OVRID_DT_o                 =>  ben_pil_shd.g_old_rec.MGR_OVRID_DT
 ,p_pil_attribute_category_o      =>ben_pil_shd.g_old_rec.pil_attribute_category
 ,p_pil_attribute1_o              =>ben_pil_shd.g_old_rec.pil_attribute1
 ,p_pil_attribute2_o              =>ben_pil_shd.g_old_rec.pil_attribute2
 ,p_pil_attribute3_o              =>ben_pil_shd.g_old_rec.pil_attribute3
 ,p_pil_attribute4_o              =>ben_pil_shd.g_old_rec.pil_attribute4
 ,p_pil_attribute5_o              =>ben_pil_shd.g_old_rec.pil_attribute5
 ,p_pil_attribute6_o              =>ben_pil_shd.g_old_rec.pil_attribute6
 ,p_pil_attribute7_o              =>ben_pil_shd.g_old_rec.pil_attribute7
 ,p_pil_attribute8_o              =>ben_pil_shd.g_old_rec.pil_attribute8
 ,p_pil_attribute9_o              =>ben_pil_shd.g_old_rec.pil_attribute9
 ,p_pil_attribute10_o             =>ben_pil_shd.g_old_rec.pil_attribute10
 ,p_pil_attribute11_o             =>ben_pil_shd.g_old_rec.pil_attribute11
 ,p_pil_attribute12_o             =>ben_pil_shd.g_old_rec.pil_attribute12
 ,p_pil_attribute13_o             =>ben_pil_shd.g_old_rec.pil_attribute13
 ,p_pil_attribute14_o             =>ben_pil_shd.g_old_rec.pil_attribute14
 ,p_pil_attribute15_o             =>ben_pil_shd.g_old_rec.pil_attribute15
 ,p_pil_attribute16_o             =>ben_pil_shd.g_old_rec.pil_attribute16
 ,p_pil_attribute17_o             =>ben_pil_shd.g_old_rec.pil_attribute17
 ,p_pil_attribute18_o             =>ben_pil_shd.g_old_rec.pil_attribute18
 ,p_pil_attribute19_o             =>ben_pil_shd.g_old_rec.pil_attribute19
 ,p_pil_attribute20_o             =>ben_pil_shd.g_old_rec.pil_attribute20
 ,p_pil_attribute21_o             =>ben_pil_shd.g_old_rec.pil_attribute21
 ,p_pil_attribute22_o             =>ben_pil_shd.g_old_rec.pil_attribute22
 ,p_pil_attribute23_o             =>ben_pil_shd.g_old_rec.pil_attribute23
 ,p_pil_attribute24_o             =>ben_pil_shd.g_old_rec.pil_attribute24
 ,p_pil_attribute25_o             =>ben_pil_shd.g_old_rec.pil_attribute25
 ,p_pil_attribute26_o             =>ben_pil_shd.g_old_rec.pil_attribute26
 ,p_pil_attribute27_o             =>ben_pil_shd.g_old_rec.pil_attribute27
 ,p_pil_attribute28_o             =>ben_pil_shd.g_old_rec.pil_attribute28
 ,p_pil_attribute29_o             =>ben_pil_shd.g_old_rec.pil_attribute29
 ,p_pil_attribute30_o             =>ben_pil_shd.g_old_rec.pil_attribute30
 ,p_request_id_o                  =>ben_pil_shd.g_old_rec.request_id
 ,p_program_application_id_o      =>ben_pil_shd.g_old_rec.program_application_id
 ,p_program_id_o                  =>ben_pil_shd.g_old_rec.program_id
 ,p_program_update_date_o         =>ben_pil_shd.g_old_rec.program_update_date
 ,p_object_version_number_o       =>ben_pil_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_per_in_ler'
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
Procedure convert_defs(p_rec in out nocopy ben_pil_shd.g_rec_type) is
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
  If (p_rec.per_in_ler_stat_cd = hr_api.g_varchar2) then
    p_rec.per_in_ler_stat_cd :=
    ben_pil_shd.g_old_rec.per_in_ler_stat_cd;
  End If;
  If (p_rec.prvs_stat_cd       = hr_api.g_varchar2) then
    p_rec.prvs_stat_cd       :=
    ben_pil_shd.g_old_rec.prvs_stat_cd      ;
  End If;
  If (p_rec.lf_evt_ocrd_dt = hr_api.g_date) then
    p_rec.lf_evt_ocrd_dt :=
    ben_pil_shd.g_old_rec.lf_evt_ocrd_dt;
  End If;
  If (p_rec.trgr_table_pk_id = hr_api.g_number) then
    p_rec.trgr_table_pk_id :=
    ben_pil_shd.g_old_rec.trgr_table_pk_id;
  End If;
  If (p_rec.procd_dt = hr_api.g_date) then
    p_rec.procd_dt :=
    ben_pil_shd.g_old_rec.procd_dt;
  End If;
  If (p_rec.strtd_dt = hr_api.g_date) then
    p_rec.strtd_dt :=
    ben_pil_shd.g_old_rec.strtd_dt;
  End If;
  If (p_rec.voidd_dt = hr_api.g_date) then
    p_rec.voidd_dt :=
    ben_pil_shd.g_old_rec.voidd_dt;
  End If;
  If (p_rec.bckt_dt = hr_api.g_date) then
    p_rec.bckt_dt :=
    ben_pil_shd.g_old_rec.bckt_dt;
  End If;
  If (p_rec.clsd_dt = hr_api.g_date) then
    p_rec.clsd_dt :=
    ben_pil_shd.g_old_rec.clsd_dt;
  End If;
  If (p_rec.ntfn_dt = hr_api.g_date) then
    p_rec.ntfn_dt :=
    ben_pil_shd.g_old_rec.ntfn_dt;
  End If;
  If (p_rec.ptnl_ler_for_per_id = hr_api.g_number) then
    p_rec.ptnl_ler_for_per_id :=
    ben_pil_shd.g_old_rec.ptnl_ler_for_per_id;
  End If;
  If (p_rec.bckt_per_in_ler_id  = hr_api.g_number) then
    p_rec.bckt_per_in_ler_id  :=
    ben_pil_shd.g_old_rec.bckt_per_in_ler_id ;
  End If;
  If (p_rec.ler_id = hr_api.g_number) then
    p_rec.ler_id :=
    ben_pil_shd.g_old_rec.ler_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    ben_pil_shd.g_old_rec.person_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_pil_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.ASSIGNMENT_ID = hr_api.g_number) then
    p_rec.ASSIGNMENT_ID :=
    ben_pil_shd.g_old_rec.ASSIGNMENT_ID;
  End If;
  If (p_rec.WS_MGR_ID = hr_api.g_number) then
    p_rec.WS_MGR_ID :=
    ben_pil_shd.g_old_rec.WS_MGR_ID;
  End If;
  If (p_rec.GROUP_PL_ID = hr_api.g_number) then
    p_rec.GROUP_PL_ID :=
    ben_pil_shd.g_old_rec.GROUP_PL_ID;
  End If;
  If (p_rec.MGR_OVRID_PERSON_ID = hr_api.g_number) then
    p_rec.MGR_OVRID_PERSON_ID :=
    ben_pil_shd.g_old_rec.MGR_OVRID_PERSON_ID;
  End If;
  If (p_rec.MGR_OVRID_DT = hr_api.g_date) then
    p_rec.MGR_OVRID_DT :=
    ben_pil_shd.g_old_rec.MGR_OVRID_DT;
  End If;
  If (p_rec.pil_attribute_category = hr_api.g_varchar2) then
    p_rec.pil_attribute_category :=
    ben_pil_shd.g_old_rec.pil_attribute_category;
  End If;
  If (p_rec.pil_attribute1 = hr_api.g_varchar2) then
    p_rec.pil_attribute1 :=
    ben_pil_shd.g_old_rec.pil_attribute1;
  End If;
  If (p_rec.pil_attribute2 = hr_api.g_varchar2) then
    p_rec.pil_attribute2 :=
    ben_pil_shd.g_old_rec.pil_attribute2;
  End If;
  If (p_rec.pil_attribute3 = hr_api.g_varchar2) then
    p_rec.pil_attribute3 :=
    ben_pil_shd.g_old_rec.pil_attribute3;
  End If;
  If (p_rec.pil_attribute4 = hr_api.g_varchar2) then
    p_rec.pil_attribute4 :=
    ben_pil_shd.g_old_rec.pil_attribute4;
  End If;
  If (p_rec.pil_attribute5 = hr_api.g_varchar2) then
    p_rec.pil_attribute5 :=
    ben_pil_shd.g_old_rec.pil_attribute5;
  End If;
  If (p_rec.pil_attribute6 = hr_api.g_varchar2) then
    p_rec.pil_attribute6 :=
    ben_pil_shd.g_old_rec.pil_attribute6;
  End If;
  If (p_rec.pil_attribute7 = hr_api.g_varchar2) then
    p_rec.pil_attribute7 :=
    ben_pil_shd.g_old_rec.pil_attribute7;
  End If;
  If (p_rec.pil_attribute8 = hr_api.g_varchar2) then
    p_rec.pil_attribute8 :=
    ben_pil_shd.g_old_rec.pil_attribute8;
  End If;
  If (p_rec.pil_attribute9 = hr_api.g_varchar2) then
    p_rec.pil_attribute9 :=
    ben_pil_shd.g_old_rec.pil_attribute9;
  End If;
  If (p_rec.pil_attribute10 = hr_api.g_varchar2) then
    p_rec.pil_attribute10 :=
    ben_pil_shd.g_old_rec.pil_attribute10;
  End If;
  If (p_rec.pil_attribute11 = hr_api.g_varchar2) then
    p_rec.pil_attribute11 :=
    ben_pil_shd.g_old_rec.pil_attribute11;
  End If;
  If (p_rec.pil_attribute12 = hr_api.g_varchar2) then
    p_rec.pil_attribute12 :=
    ben_pil_shd.g_old_rec.pil_attribute12;
  End If;
  If (p_rec.pil_attribute13 = hr_api.g_varchar2) then
    p_rec.pil_attribute13 :=
    ben_pil_shd.g_old_rec.pil_attribute13;
  End If;
  If (p_rec.pil_attribute14 = hr_api.g_varchar2) then
    p_rec.pil_attribute14 :=
    ben_pil_shd.g_old_rec.pil_attribute14;
  End If;
  If (p_rec.pil_attribute15 = hr_api.g_varchar2) then
    p_rec.pil_attribute15 :=
    ben_pil_shd.g_old_rec.pil_attribute15;
  End If;
  If (p_rec.pil_attribute16 = hr_api.g_varchar2) then
    p_rec.pil_attribute16 :=
    ben_pil_shd.g_old_rec.pil_attribute16;
  End If;
  If (p_rec.pil_attribute17 = hr_api.g_varchar2) then
    p_rec.pil_attribute17 :=
    ben_pil_shd.g_old_rec.pil_attribute17;
  End If;
  If (p_rec.pil_attribute18 = hr_api.g_varchar2) then
    p_rec.pil_attribute18 :=
    ben_pil_shd.g_old_rec.pil_attribute18;
  End If;
  If (p_rec.pil_attribute19 = hr_api.g_varchar2) then
    p_rec.pil_attribute19 :=
    ben_pil_shd.g_old_rec.pil_attribute19;
  End If;
  If (p_rec.pil_attribute20 = hr_api.g_varchar2) then
    p_rec.pil_attribute20 :=
    ben_pil_shd.g_old_rec.pil_attribute20;
  End If;
  If (p_rec.pil_attribute21 = hr_api.g_varchar2) then
    p_rec.pil_attribute21 :=
    ben_pil_shd.g_old_rec.pil_attribute21;
  End If;
  If (p_rec.pil_attribute22 = hr_api.g_varchar2) then
    p_rec.pil_attribute22 :=
    ben_pil_shd.g_old_rec.pil_attribute22;
  End If;
  If (p_rec.pil_attribute23 = hr_api.g_varchar2) then
    p_rec.pil_attribute23 :=
    ben_pil_shd.g_old_rec.pil_attribute23;
  End If;
  If (p_rec.pil_attribute24 = hr_api.g_varchar2) then
    p_rec.pil_attribute24 :=
    ben_pil_shd.g_old_rec.pil_attribute24;
  End If;
  If (p_rec.pil_attribute25 = hr_api.g_varchar2) then
    p_rec.pil_attribute25 :=
    ben_pil_shd.g_old_rec.pil_attribute25;
  End If;
  If (p_rec.pil_attribute26 = hr_api.g_varchar2) then
    p_rec.pil_attribute26 :=
    ben_pil_shd.g_old_rec.pil_attribute26;
  End If;
  If (p_rec.pil_attribute27 = hr_api.g_varchar2) then
    p_rec.pil_attribute27 :=
    ben_pil_shd.g_old_rec.pil_attribute27;
  End If;
  If (p_rec.pil_attribute28 = hr_api.g_varchar2) then
    p_rec.pil_attribute28 :=
    ben_pil_shd.g_old_rec.pil_attribute28;
  End If;
  If (p_rec.pil_attribute29 = hr_api.g_varchar2) then
    p_rec.pil_attribute29 :=
    ben_pil_shd.g_old_rec.pil_attribute29;
  End If;
  If (p_rec.pil_attribute30 = hr_api.g_varchar2) then
    p_rec.pil_attribute30 :=
    ben_pil_shd.g_old_rec.pil_attribute30;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    ben_pil_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    ben_pil_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    ben_pil_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    ben_pil_shd.g_old_rec.program_update_date;
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
  p_rec        in out nocopy ben_pil_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ben_pil_shd.lck
	(
	p_rec.per_in_ler_id,
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
  ben_pil_bus.update_validate(p_rec
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
--
-- DBI - Added DBI Event Logging Hooks
  /* Commented. Need to uncomment when DBI goes into mainline
   	5554590 : Enabled DBI logging into mainline. */
  if HRI_BPL_BEN_UTIL.enable_ben_col_evt_que then
      HRI_OPL_BEN_ELCTN_EVNTS_EQ.update_event (p_rec 	     => null ,
  					                   p_pil_rec      => p_rec ,
					                   p_called_from    => 'PIL' ,
		                               p_effective_date  => p_effective_date,
		                               p_datetrack_mode  => 'UPDATE' );
  end if;

  --
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date in date,
  p_per_in_ler_id                in number,
  p_per_in_ler_stat_cd           in varchar2         default hr_api.g_varchar2,
  p_prvs_stat_cd                 in varchar2         default hr_api.g_varchar2,
  p_lf_evt_ocrd_dt               in date             default hr_api.g_date,
  p_trgr_table_pk_id             in number           default hr_api.g_number,
  p_procd_dt                     in date             default hr_api.g_date,
  p_strtd_dt                     in date             default hr_api.g_date,
  p_voidd_dt                     in date             default hr_api.g_date,
  p_bckt_dt                      in date             default hr_api.g_date,
  p_clsd_dt                      in date             default hr_api.g_date,
  p_ntfn_dt                      in date             default hr_api.g_date,
  p_ptnl_ler_for_per_id          in number           default hr_api.g_number,
  p_bckt_per_in_ler_id           in number           default hr_api.g_number,
  p_ler_id                       in number           default hr_api.g_number,
  p_person_id                    in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_ASSIGNMENT_ID                  in  number    default hr_api.g_number,
  p_WS_MGR_ID                      in  number    default hr_api.g_number,
  p_GROUP_PL_ID                    in  number    default hr_api.g_number,
  p_MGR_OVRID_PERSON_ID            in  number    default hr_api.g_number,
  p_MGR_OVRID_DT                   in  date      default hr_api.g_date,
  p_pil_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_pil_attribute1               in varchar2         default hr_api.g_varchar2,
  p_pil_attribute2               in varchar2         default hr_api.g_varchar2,
  p_pil_attribute3               in varchar2         default hr_api.g_varchar2,
  p_pil_attribute4               in varchar2         default hr_api.g_varchar2,
  p_pil_attribute5               in varchar2         default hr_api.g_varchar2,
  p_pil_attribute6               in varchar2         default hr_api.g_varchar2,
  p_pil_attribute7               in varchar2         default hr_api.g_varchar2,
  p_pil_attribute8               in varchar2         default hr_api.g_varchar2,
  p_pil_attribute9               in varchar2         default hr_api.g_varchar2,
  p_pil_attribute10              in varchar2         default hr_api.g_varchar2,
  p_pil_attribute11              in varchar2         default hr_api.g_varchar2,
  p_pil_attribute12              in varchar2         default hr_api.g_varchar2,
  p_pil_attribute13              in varchar2         default hr_api.g_varchar2,
  p_pil_attribute14              in varchar2         default hr_api.g_varchar2,
  p_pil_attribute15              in varchar2         default hr_api.g_varchar2,
  p_pil_attribute16              in varchar2         default hr_api.g_varchar2,
  p_pil_attribute17              in varchar2         default hr_api.g_varchar2,
  p_pil_attribute18              in varchar2         default hr_api.g_varchar2,
  p_pil_attribute19              in varchar2         default hr_api.g_varchar2,
  p_pil_attribute20              in varchar2         default hr_api.g_varchar2,
  p_pil_attribute21              in varchar2         default hr_api.g_varchar2,
  p_pil_attribute22              in varchar2         default hr_api.g_varchar2,
  p_pil_attribute23              in varchar2         default hr_api.g_varchar2,
  p_pil_attribute24              in varchar2         default hr_api.g_varchar2,
  p_pil_attribute25              in varchar2         default hr_api.g_varchar2,
  p_pil_attribute26              in varchar2         default hr_api.g_varchar2,
  p_pil_attribute27              in varchar2         default hr_api.g_varchar2,
  p_pil_attribute28              in varchar2         default hr_api.g_varchar2,
  p_pil_attribute29              in varchar2         default hr_api.g_varchar2,
  p_pil_attribute30              in varchar2         default hr_api.g_varchar2,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_object_version_number        in out nocopy number
  ) is
--
  l_rec	  ben_pil_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_pil_shd.convert_args
  (
  p_per_in_ler_id,
  p_per_in_ler_stat_cd,
  p_prvs_stat_cd      ,
  p_lf_evt_ocrd_dt,
  p_trgr_table_pk_id,
  p_procd_dt,
  p_strtd_dt,
  p_voidd_dt,
  p_bckt_dt,
  p_clsd_dt,
  p_ntfn_dt,
  p_ptnl_ler_for_per_id,
  p_bckt_per_in_ler_id ,
  p_ler_id,
  p_person_id,
  p_business_group_id,
  p_ASSIGNMENT_ID,
  p_WS_MGR_ID,
  p_GROUP_PL_ID,
  p_MGR_OVRID_PERSON_ID,
  p_MGR_OVRID_DT,
  p_pil_attribute_category,
  p_pil_attribute1,
  p_pil_attribute2,
  p_pil_attribute3,
  p_pil_attribute4,
  p_pil_attribute5,
  p_pil_attribute6,
  p_pil_attribute7,
  p_pil_attribute8,
  p_pil_attribute9,
  p_pil_attribute10,
  p_pil_attribute11,
  p_pil_attribute12,
  p_pil_attribute13,
  p_pil_attribute14,
  p_pil_attribute15,
  p_pil_attribute16,
  p_pil_attribute17,
  p_pil_attribute18,
  p_pil_attribute19,
  p_pil_attribute20,
  p_pil_attribute21,
  p_pil_attribute22,
  p_pil_attribute23,
  p_pil_attribute24,
  p_pil_attribute25,
  p_pil_attribute26,
  p_pil_attribute27,
  p_pil_attribute28,
  p_pil_attribute29,
  p_pil_attribute30,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
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
end ben_pil_upd;

/

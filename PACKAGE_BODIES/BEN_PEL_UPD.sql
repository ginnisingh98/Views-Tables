--------------------------------------------------------
--  DDL for Package Body BEN_PEL_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PEL_UPD" as
/* $Header: bepelrhi.pkb 120.3.12000000.2 2007/05/13 23:02:25 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_pel_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy ben_pel_shd.g_rec_type) is
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
  ben_pel_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_pil_elctbl_chc_popl Row
  --
  update ben_pil_elctbl_chc_popl
  set
  pil_elctbl_chc_popl_id            = p_rec.pil_elctbl_chc_popl_id,
  dflt_enrt_dt                      = p_rec.dflt_enrt_dt,
  dflt_asnd_dt                      = p_rec.dflt_asnd_dt,
  elcns_made_dt                     = p_rec.elcns_made_dt,
  cls_enrt_dt_to_use_cd             = p_rec.cls_enrt_dt_to_use_cd,
  enrt_typ_cycl_cd                  = p_rec.enrt_typ_cycl_cd,
  enrt_perd_end_dt                  = p_rec.enrt_perd_end_dt,
  enrt_perd_strt_dt                 = p_rec.enrt_perd_strt_dt,
  procg_end_dt                      = p_rec.procg_end_dt,
  pil_elctbl_popl_stat_cd           = p_rec.pil_elctbl_popl_stat_cd,
  acty_ref_perd_cd                  = p_rec.acty_ref_perd_cd,
  uom                               = p_rec.uom,
  comments                               = p_rec.comments,
  mgr_ovrid_dt                               = p_rec.mgr_ovrid_dt,
  ws_mgr_id                               = p_rec.ws_mgr_id,
  mgr_ovrid_person_id                               = p_rec.mgr_ovrid_person_id,
  assignment_id                               = p_rec.assignment_id,
  --cwb
  bdgt_acc_cd                       = p_rec.bdgt_acc_cd,
  pop_cd                            = p_rec.pop_cd,
  bdgt_due_dt                       = p_rec.bdgt_due_dt,
  bdgt_export_flag                  = p_rec.bdgt_export_flag,
  bdgt_iss_dt                       = p_rec.bdgt_iss_dt,
  bdgt_stat_cd                      = p_rec.bdgt_stat_cd,
  ws_acc_cd                         = p_rec.ws_acc_cd,
  ws_due_dt                         = p_rec.ws_due_dt,
  ws_export_flag                    = p_rec.ws_export_flag,
  ws_iss_dt                         = p_rec.ws_iss_dt,
  ws_stat_cd                        = p_rec.ws_stat_cd,
  --cwb
  reinstate_cd                      = p_rec.reinstate_cd,
  reinstate_ovrdn_cd                = p_rec.reinstate_ovrdn_cd,
  auto_asnd_dt                      = p_rec.auto_asnd_dt,
  cbr_elig_perd_strt_dt             = p_rec.cbr_elig_perd_strt_dt,
  cbr_elig_perd_end_dt              = p_rec.cbr_elig_perd_end_dt,
  lee_rsn_id                        = p_rec.lee_rsn_id,
  enrt_perd_id                      = p_rec.enrt_perd_id,
  per_in_ler_id                     = p_rec.per_in_ler_id,
  pgm_id                            = p_rec.pgm_id,
  pl_id                             = p_rec.pl_id,
  business_group_id                 = p_rec.business_group_id,
  pel_attribute_category            = p_rec.pel_attribute_category,
  pel_attribute1                    = p_rec.pel_attribute1,
  pel_attribute2                    = p_rec.pel_attribute2,
  pel_attribute3                    = p_rec.pel_attribute3,
  pel_attribute4                    = p_rec.pel_attribute4,
  pel_attribute5                    = p_rec.pel_attribute5,
  pel_attribute6                    = p_rec.pel_attribute6,
  pel_attribute7                    = p_rec.pel_attribute7,
  pel_attribute8                    = p_rec.pel_attribute8,
  pel_attribute9                    = p_rec.pel_attribute9,
  pel_attribute10                   = p_rec.pel_attribute10,
  pel_attribute11                   = p_rec.pel_attribute11,
  pel_attribute12                   = p_rec.pel_attribute12,
  pel_attribute13                   = p_rec.pel_attribute13,
  pel_attribute14                   = p_rec.pel_attribute14,
  pel_attribute15                   = p_rec.pel_attribute15,
  pel_attribute16                   = p_rec.pel_attribute16,
  pel_attribute17                   = p_rec.pel_attribute17,
  pel_attribute18                   = p_rec.pel_attribute18,
  pel_attribute19                   = p_rec.pel_attribute19,
  pel_attribute20                   = p_rec.pel_attribute20,
  pel_attribute21                   = p_rec.pel_attribute21,
  pel_attribute22                   = p_rec.pel_attribute22,
  pel_attribute23                   = p_rec.pel_attribute23,
  pel_attribute24                   = p_rec.pel_attribute24,
  pel_attribute25                   = p_rec.pel_attribute25,
  pel_attribute26                   = p_rec.pel_attribute26,
  pel_attribute27                   = p_rec.pel_attribute27,
  pel_attribute28                   = p_rec.pel_attribute28,
  pel_attribute29                   = p_rec.pel_attribute29,
  pel_attribute30                   = p_rec.pel_attribute30,
  request_id                        = p_rec.request_id,
  program_application_id            = p_rec.program_application_id,
  program_id                        = p_rec.program_id,
  program_update_date               = p_rec.program_update_date,
  object_version_number             = p_rec.object_version_number,
  defer_deenrol_flag                = p_rec.defer_deenrol_flag,
  deenrol_made_dt		    = p_rec.deenrol_made_dt
  where pil_elctbl_chc_popl_id = p_rec.pil_elctbl_chc_popl_id;
  --
  ben_pel_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_pel_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pel_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_pel_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pel_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_pel_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pel_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_pel_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in ben_pel_shd.g_rec_type) is
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
p_effective_date in date,p_rec in ben_pel_shd.g_rec_type) is
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
    ben_pel_rku.after_update
      (
  p_pil_elctbl_chc_popl_id        =>p_rec.pil_elctbl_chc_popl_id
 ,p_dflt_enrt_dt                  =>p_rec.dflt_enrt_dt
 ,p_dflt_asnd_dt                  =>p_rec.dflt_asnd_dt
 ,p_elcns_made_dt                 =>p_rec.elcns_made_dt
 ,p_cls_enrt_dt_to_use_cd         =>p_rec.cls_enrt_dt_to_use_cd
 ,p_enrt_typ_cycl_cd              =>p_rec.enrt_typ_cycl_cd
 ,p_enrt_perd_end_dt              =>p_rec.enrt_perd_end_dt
 ,p_enrt_perd_strt_dt             =>p_rec.enrt_perd_strt_dt
 ,p_procg_end_dt                  =>p_rec.procg_end_dt
 ,p_pil_elctbl_popl_stat_cd       =>p_rec.pil_elctbl_popl_stat_cd
 ,p_acty_ref_perd_cd              =>p_rec.acty_ref_perd_cd
 ,p_uom                           =>p_rec.uom
 ,p_comments                           =>p_rec.comments
 ,p_mgr_ovrid_dt                           =>p_rec.mgr_ovrid_dt
 ,p_ws_mgr_id                           =>p_rec.ws_mgr_id
 ,p_mgr_ovrid_person_id                           =>p_rec.mgr_ovrid_person_id
 ,p_assignment_id                           =>p_rec.assignment_id
  --cwb
 ,p_bdgt_acc_cd                     =>p_rec.bdgt_acc_cd
 ,p_pop_cd                          =>p_rec.pop_cd
 ,p_bdgt_due_dt                     =>p_rec.bdgt_due_dt
 ,p_bdgt_export_flag                =>p_rec.bdgt_export_flag
 ,p_bdgt_iss_dt                     =>p_rec.bdgt_iss_dt
 ,p_bdgt_stat_cd                    =>p_rec.bdgt_stat_cd
 ,p_ws_acc_cd                       =>p_rec.ws_acc_cd
 ,p_ws_due_dt                       =>p_rec.ws_due_dt
 ,p_ws_export_flag                  =>p_rec.ws_export_flag
 ,p_ws_iss_dt                       =>p_rec.ws_iss_dt
 ,p_ws_stat_cd                      =>p_rec.ws_stat_cd
  --cwb
 ,p_reinstate_cd                  => p_rec.reinstate_cd
 ,p_reinstate_ovrdn_cd            => p_rec.reinstate_ovrdn_cd
 ,p_auto_asnd_dt                  =>p_rec.auto_asnd_dt
 ,p_cbr_elig_perd_strt_dt         =>p_rec.cbr_elig_perd_strt_dt
 ,p_cbr_elig_perd_end_dt          =>p_rec.cbr_elig_perd_end_dt
 ,p_lee_rsn_id                    =>p_rec.lee_rsn_id
 ,p_enrt_perd_id                  =>p_rec.enrt_perd_id
 ,p_per_in_ler_id                 =>p_rec.per_in_ler_id
 ,p_pgm_id                        =>p_rec.pgm_id
 ,p_pl_id                         =>p_rec.pl_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_pel_attribute_category        =>p_rec.pel_attribute_category
 ,p_pel_attribute1                =>p_rec.pel_attribute1
 ,p_pel_attribute2                =>p_rec.pel_attribute2
 ,p_pel_attribute3                =>p_rec.pel_attribute3
 ,p_pel_attribute4                =>p_rec.pel_attribute4
 ,p_pel_attribute5                =>p_rec.pel_attribute5
 ,p_pel_attribute6                =>p_rec.pel_attribute6
 ,p_pel_attribute7                =>p_rec.pel_attribute7
 ,p_pel_attribute8                =>p_rec.pel_attribute8
 ,p_pel_attribute9                =>p_rec.pel_attribute9
 ,p_pel_attribute10               =>p_rec.pel_attribute10
 ,p_pel_attribute11               =>p_rec.pel_attribute11
 ,p_pel_attribute12               =>p_rec.pel_attribute12
 ,p_pel_attribute13               =>p_rec.pel_attribute13
 ,p_pel_attribute14               =>p_rec.pel_attribute14
 ,p_pel_attribute15               =>p_rec.pel_attribute15
 ,p_pel_attribute16               =>p_rec.pel_attribute16
 ,p_pel_attribute17               =>p_rec.pel_attribute17
 ,p_pel_attribute18               =>p_rec.pel_attribute18
 ,p_pel_attribute19               =>p_rec.pel_attribute19
 ,p_pel_attribute20               =>p_rec.pel_attribute20
 ,p_pel_attribute21               =>p_rec.pel_attribute21
 ,p_pel_attribute22               =>p_rec.pel_attribute22
 ,p_pel_attribute23               =>p_rec.pel_attribute23
 ,p_pel_attribute24               =>p_rec.pel_attribute24
 ,p_pel_attribute25               =>p_rec.pel_attribute25
 ,p_pel_attribute26               =>p_rec.pel_attribute26
 ,p_pel_attribute27               =>p_rec.pel_attribute27
 ,p_pel_attribute28               =>p_rec.pel_attribute28
 ,p_pel_attribute29               =>p_rec.pel_attribute29
 ,p_pel_attribute30               =>p_rec.pel_attribute30
 ,p_request_id                    =>p_rec.request_id
 ,p_program_application_id        =>p_rec.program_application_id
 ,p_program_id                    =>p_rec.program_id
 ,p_program_update_date           =>p_rec.program_update_date
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_defer_deenrol_flag            =>p_rec.defer_deenrol_flag
 ,p_deenrol_made_dt               =>p_rec.deenrol_made_dt
 ,p_dflt_enrt_dt_o                =>ben_pel_shd.g_old_rec.dflt_enrt_dt
 ,p_dflt_asnd_dt_o                =>ben_pel_shd.g_old_rec.dflt_asnd_dt
 ,p_elcns_made_dt_o               =>ben_pel_shd.g_old_rec.elcns_made_dt
 ,p_cls_enrt_dt_to_use_cd_o       =>ben_pel_shd.g_old_rec.cls_enrt_dt_to_use_cd
 ,p_enrt_typ_cycl_cd_o            =>ben_pel_shd.g_old_rec.enrt_typ_cycl_cd
 ,p_enrt_perd_end_dt_o            =>ben_pel_shd.g_old_rec.enrt_perd_end_dt
 ,p_enrt_perd_strt_dt_o           =>ben_pel_shd.g_old_rec.enrt_perd_strt_dt
 ,p_procg_end_dt_o                =>ben_pel_shd.g_old_rec.procg_end_dt
 ,p_pil_elctbl_popl_stat_cd_o     =>ben_pel_shd.g_old_rec.pil_elctbl_popl_stat_cd
 ,p_acty_ref_perd_cd_o            =>ben_pel_shd.g_old_rec.acty_ref_perd_cd
 ,p_uom_o                         =>ben_pel_shd.g_old_rec.uom
 ,p_comments_o                         =>ben_pel_shd.g_old_rec.comments
 ,p_mgr_ovrid_dt_o                         =>ben_pel_shd.g_old_rec.mgr_ovrid_dt
 ,p_ws_mgr_id_o                         =>ben_pel_shd.g_old_rec.ws_mgr_id
 ,p_mgr_ovrid_person_id_o                         =>ben_pel_shd.g_old_rec.mgr_ovrid_person_id
 ,p_assignment_id_o                         =>ben_pel_shd.g_old_rec.assignment_id
  --cwb
 ,p_bdgt_acc_cd_o                     =>ben_pel_shd.g_old_rec.bdgt_acc_cd
 ,p_pop_cd_o                          =>ben_pel_shd.g_old_rec.pop_cd
 ,p_bdgt_due_dt_o                     =>ben_pel_shd.g_old_rec.bdgt_due_dt
 ,p_bdgt_export_flag_o                =>ben_pel_shd.g_old_rec.bdgt_export_flag
 ,p_bdgt_iss_dt_o                     =>ben_pel_shd.g_old_rec.bdgt_iss_dt
 ,p_bdgt_stat_cd_o                    =>ben_pel_shd.g_old_rec.bdgt_stat_cd
 ,p_ws_acc_cd_o                       =>ben_pel_shd.g_old_rec.ws_acc_cd
 ,p_ws_due_dt_o                       =>ben_pel_shd.g_old_rec.ws_due_dt
 ,p_ws_export_flag_o                  =>ben_pel_shd.g_old_rec.ws_export_flag
 ,p_ws_iss_dt_o                       =>ben_pel_shd.g_old_rec.ws_iss_dt
 ,p_ws_stat_cd_o                      =>ben_pel_shd.g_old_rec.ws_stat_cd
  --cwb
 ,p_reinstate_cd_o                =>ben_pel_shd.g_old_rec.reinstate_cd
 ,p_reinstate_ovrdn_cd_o          =>ben_pel_shd.g_old_rec.reinstate_ovrdn_cd
 ,p_auto_asnd_dt_o                =>ben_pel_shd.g_old_rec.auto_asnd_dt
 ,p_cbr_elig_perd_strt_dt_o       =>ben_pel_shd.g_old_rec.cbr_elig_perd_strt_dt
 ,p_cbr_elig_perd_end_dt_o        =>ben_pel_shd.g_old_rec.cbr_elig_perd_end_dt
 ,p_lee_rsn_id_o                  =>ben_pel_shd.g_old_rec.lee_rsn_id
 ,p_enrt_perd_id_o                =>ben_pel_shd.g_old_rec.enrt_perd_id
 ,p_per_in_ler_id_o               =>ben_pel_shd.g_old_rec.per_in_ler_id
 ,p_pgm_id_o                      =>ben_pel_shd.g_old_rec.pgm_id
 ,p_pl_id_o                       =>ben_pel_shd.g_old_rec.pl_id
 ,p_business_group_id_o           =>ben_pel_shd.g_old_rec.business_group_id
 ,p_pel_attribute_category_o      =>ben_pel_shd.g_old_rec.pel_attribute_category
 ,p_pel_attribute1_o              =>ben_pel_shd.g_old_rec.pel_attribute1
 ,p_pel_attribute2_o              =>ben_pel_shd.g_old_rec.pel_attribute2
 ,p_pel_attribute3_o              =>ben_pel_shd.g_old_rec.pel_attribute3
 ,p_pel_attribute4_o              =>ben_pel_shd.g_old_rec.pel_attribute4
 ,p_pel_attribute5_o              =>ben_pel_shd.g_old_rec.pel_attribute5
 ,p_pel_attribute6_o              =>ben_pel_shd.g_old_rec.pel_attribute6
 ,p_pel_attribute7_o              =>ben_pel_shd.g_old_rec.pel_attribute7
 ,p_pel_attribute8_o              =>ben_pel_shd.g_old_rec.pel_attribute8
 ,p_pel_attribute9_o              =>ben_pel_shd.g_old_rec.pel_attribute9
 ,p_pel_attribute10_o             =>ben_pel_shd.g_old_rec.pel_attribute10
 ,p_pel_attribute11_o             =>ben_pel_shd.g_old_rec.pel_attribute11
 ,p_pel_attribute12_o             =>ben_pel_shd.g_old_rec.pel_attribute12
 ,p_pel_attribute13_o             =>ben_pel_shd.g_old_rec.pel_attribute13
 ,p_pel_attribute14_o             =>ben_pel_shd.g_old_rec.pel_attribute14
 ,p_pel_attribute15_o             =>ben_pel_shd.g_old_rec.pel_attribute15
 ,p_pel_attribute16_o             =>ben_pel_shd.g_old_rec.pel_attribute16
 ,p_pel_attribute17_o             =>ben_pel_shd.g_old_rec.pel_attribute17
 ,p_pel_attribute18_o             =>ben_pel_shd.g_old_rec.pel_attribute18
 ,p_pel_attribute19_o             =>ben_pel_shd.g_old_rec.pel_attribute19
 ,p_pel_attribute20_o             =>ben_pel_shd.g_old_rec.pel_attribute20
 ,p_pel_attribute21_o             =>ben_pel_shd.g_old_rec.pel_attribute21
 ,p_pel_attribute22_o             =>ben_pel_shd.g_old_rec.pel_attribute22
 ,p_pel_attribute23_o             =>ben_pel_shd.g_old_rec.pel_attribute23
 ,p_pel_attribute24_o             =>ben_pel_shd.g_old_rec.pel_attribute24
 ,p_pel_attribute25_o             =>ben_pel_shd.g_old_rec.pel_attribute25
 ,p_pel_attribute26_o             =>ben_pel_shd.g_old_rec.pel_attribute26
 ,p_pel_attribute27_o             =>ben_pel_shd.g_old_rec.pel_attribute27
 ,p_pel_attribute28_o             =>ben_pel_shd.g_old_rec.pel_attribute28
 ,p_pel_attribute29_o             =>ben_pel_shd.g_old_rec.pel_attribute29
 ,p_pel_attribute30_o             =>ben_pel_shd.g_old_rec.pel_attribute30
 ,p_request_id_o                  =>ben_pel_shd.g_old_rec.request_id
 ,p_program_application_id_o      =>ben_pel_shd.g_old_rec.program_application_id
 ,p_program_id_o                  =>ben_pel_shd.g_old_rec.program_id
 ,p_program_update_date_o         =>ben_pel_shd.g_old_rec.program_update_date
 ,p_object_version_number_o       =>ben_pel_shd.g_old_rec.object_version_number
 ,p_defer_deenrol_flag_o          =>ben_pel_shd.g_old_rec.defer_deenrol_flag
 ,p_deenrol_made_dt_o             =>ben_pel_shd.g_old_rec.deenrol_made_dt
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_pil_elctbl_chc_popl'
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
Procedure convert_defs(p_rec in out nocopy ben_pel_shd.g_rec_type) is
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
  If (p_rec.dflt_enrt_dt = hr_api.g_date) then
    p_rec.dflt_enrt_dt :=
    ben_pel_shd.g_old_rec.dflt_enrt_dt;
  End If;
  If (p_rec.dflt_asnd_dt = hr_api.g_date) then
    p_rec.dflt_asnd_dt :=
    ben_pel_shd.g_old_rec.dflt_asnd_dt;
  End If;
  If (p_rec.elcns_made_dt = hr_api.g_date) then
    p_rec.elcns_made_dt :=
    ben_pel_shd.g_old_rec.elcns_made_dt;
  End If;
  If (p_rec.cls_enrt_dt_to_use_cd = hr_api.g_varchar2) then
    p_rec.cls_enrt_dt_to_use_cd :=
    ben_pel_shd.g_old_rec.cls_enrt_dt_to_use_cd;
  End If;
  If (p_rec.enrt_typ_cycl_cd = hr_api.g_varchar2) then
    p_rec.enrt_typ_cycl_cd :=
    ben_pel_shd.g_old_rec.enrt_typ_cycl_cd;
  End If;
  If (p_rec.enrt_perd_end_dt = hr_api.g_date) then
    p_rec.enrt_perd_end_dt :=
    ben_pel_shd.g_old_rec.enrt_perd_end_dt;
  End If;
  If (p_rec.enrt_perd_strt_dt = hr_api.g_date) then
    p_rec.enrt_perd_strt_dt :=
    ben_pel_shd.g_old_rec.enrt_perd_strt_dt;
  End If;
  If (p_rec.procg_end_dt = hr_api.g_date) then
    p_rec.procg_end_dt :=
    ben_pel_shd.g_old_rec.procg_end_dt;
  End If;
  If (p_rec.pil_elctbl_popl_stat_cd = hr_api.g_varchar2) then
    p_rec.pil_elctbl_popl_stat_cd :=
    ben_pel_shd.g_old_rec.pil_elctbl_popl_stat_cd;
  End If;
  If (p_rec.acty_ref_perd_cd = hr_api.g_varchar2) then
    p_rec.acty_ref_perd_cd :=
    ben_pel_shd.g_old_rec.acty_ref_perd_cd;
  End If;

  If (p_rec.uom = hr_api.g_varchar2) then
    p_rec.uom :=
    ben_pel_shd.g_old_rec.uom;
  End If;

  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    ben_pel_shd.g_old_rec.comments;
  End If;

  If (p_rec.mgr_ovrid_dt = hr_api.g_date) then
    p_rec.mgr_ovrid_dt :=
    ben_pel_shd.g_old_rec.mgr_ovrid_dt;
  End If;

  If (p_rec.ws_mgr_id = hr_api.g_number) then
    p_rec.ws_mgr_id :=
    ben_pel_shd.g_old_rec.ws_mgr_id;
  End If;

  If (p_rec.mgr_ovrid_person_id = hr_api.g_number) then
    p_rec.mgr_ovrid_person_id :=
    ben_pel_shd.g_old_rec.mgr_ovrid_person_id;
  End If;

  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    ben_pel_shd.g_old_rec.assignment_id;
  End If;

  If (p_rec.mgr_ovrid_person_id = hr_api.g_number) then
    p_rec.mgr_ovrid_person_id :=
    ben_pel_shd.g_old_rec.mgr_ovrid_person_id;
  End If;


  -- cwb
  If (p_rec.bdgt_acc_cd = hr_api.g_varchar2) then
    p_rec.bdgt_acc_cd :=
    ben_pel_shd.g_old_rec.bdgt_acc_cd;
  End If;
  If (p_rec.pop_cd = hr_api.g_varchar2) then
    p_rec.pop_cd :=
    ben_pel_shd.g_old_rec.pop_cd;
  End If;
  If (p_rec.bdgt_due_dt = hr_api.g_date) then
    p_rec.bdgt_due_dt :=
    ben_pel_shd.g_old_rec.bdgt_due_dt;
  End If;
  If (p_rec.bdgt_export_flag = hr_api.g_varchar2) then
    p_rec.bdgt_export_flag :=
    ben_pel_shd.g_old_rec.bdgt_export_flag;
  End If;
  If (p_rec.bdgt_iss_dt = hr_api.g_date) then
    p_rec.bdgt_iss_dt :=
    ben_pel_shd.g_old_rec.bdgt_iss_dt;
  End If;
  If (p_rec.bdgt_stat_cd = hr_api.g_varchar2) then
    p_rec.bdgt_stat_cd :=
    ben_pel_shd.g_old_rec.bdgt_stat_cd;
  End If;
  If (p_rec.ws_acc_cd = hr_api.g_varchar2) then
    p_rec.ws_acc_cd :=
    ben_pel_shd.g_old_rec.ws_acc_cd;
  End If;
  If (p_rec.ws_due_dt = hr_api.g_date) then
    p_rec.ws_due_dt :=
    ben_pel_shd.g_old_rec.ws_due_dt;
  End If;
  If (p_rec.ws_export_flag = hr_api.g_varchar2) then
    p_rec.ws_export_flag :=
    ben_pel_shd.g_old_rec.ws_export_flag;
  End If;
  If (p_rec.ws_iss_dt = hr_api.g_date) then
    p_rec.ws_iss_dt :=
    ben_pel_shd.g_old_rec.ws_iss_dt;
  End If;
  If (p_rec.ws_stat_cd = hr_api.g_varchar2) then
    p_rec.ws_stat_cd :=
    ben_pel_shd.g_old_rec.ws_stat_cd;
  End If;
  -- cwb
  If (p_rec.reinstate_cd = hr_api.g_varchar2) then
    p_rec.reinstate_cd :=
    ben_pel_shd.g_old_rec.reinstate_cd;
  End If;
  If (p_rec.reinstate_ovrdn_cd = hr_api.g_varchar2) then
    p_rec.reinstate_ovrdn_cd :=
    ben_pel_shd.g_old_rec.reinstate_ovrdn_cd;
  End If;
  If (p_rec.auto_asnd_dt = hr_api.g_date) then
    p_rec.auto_asnd_dt :=
    ben_pel_shd.g_old_rec.auto_asnd_dt;
  End If;
  If (p_rec.cbr_elig_perd_strt_dt = hr_api.g_date) then
    p_rec.cbr_elig_perd_strt_dt :=
    ben_pel_shd.g_old_rec.cbr_elig_perd_strt_dt;
  End If;
  If (p_rec.cbr_elig_perd_end_dt = hr_api.g_date) then
    p_rec.cbr_elig_perd_end_dt :=
    ben_pel_shd.g_old_rec.cbr_elig_perd_end_dt;
  End If;
  If (p_rec.lee_rsn_id = hr_api.g_number) then
    p_rec.lee_rsn_id :=
    ben_pel_shd.g_old_rec.lee_rsn_id;
  End If;
  If (p_rec.enrt_perd_id = hr_api.g_number) then
    p_rec.enrt_perd_id :=
    ben_pel_shd.g_old_rec.enrt_perd_id;
  End If;
  If (p_rec.per_in_ler_id = hr_api.g_number) then
    p_rec.per_in_ler_id :=
    ben_pel_shd.g_old_rec.per_in_ler_id;
  End If;
  If (p_rec.pgm_id = hr_api.g_number) then
    p_rec.pgm_id :=
    ben_pel_shd.g_old_rec.pgm_id;
  End If;
  If (p_rec.pl_id = hr_api.g_number) then
    p_rec.pl_id :=
    ben_pel_shd.g_old_rec.pl_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_pel_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.pel_attribute_category = hr_api.g_varchar2) then
    p_rec.pel_attribute_category :=
    ben_pel_shd.g_old_rec.pel_attribute_category;
  End If;
  If (p_rec.pel_attribute1 = hr_api.g_varchar2) then
    p_rec.pel_attribute1 :=
    ben_pel_shd.g_old_rec.pel_attribute1;
  End If;
  If (p_rec.pel_attribute2 = hr_api.g_varchar2) then
    p_rec.pel_attribute2 :=
    ben_pel_shd.g_old_rec.pel_attribute2;
  End If;
  If (p_rec.pel_attribute3 = hr_api.g_varchar2) then
    p_rec.pel_attribute3 :=
    ben_pel_shd.g_old_rec.pel_attribute3;
  End If;
  If (p_rec.pel_attribute4 = hr_api.g_varchar2) then
    p_rec.pel_attribute4 :=
    ben_pel_shd.g_old_rec.pel_attribute4;
  End If;
  If (p_rec.pel_attribute5 = hr_api.g_varchar2) then
    p_rec.pel_attribute5 :=
    ben_pel_shd.g_old_rec.pel_attribute5;
  End If;
  If (p_rec.pel_attribute6 = hr_api.g_varchar2) then
    p_rec.pel_attribute6 :=
    ben_pel_shd.g_old_rec.pel_attribute6;
  End If;
  If (p_rec.pel_attribute7 = hr_api.g_varchar2) then
    p_rec.pel_attribute7 :=
    ben_pel_shd.g_old_rec.pel_attribute7;
  End If;
  If (p_rec.pel_attribute8 = hr_api.g_varchar2) then
    p_rec.pel_attribute8 :=
    ben_pel_shd.g_old_rec.pel_attribute8;
  End If;
  If (p_rec.pel_attribute9 = hr_api.g_varchar2) then
    p_rec.pel_attribute9 :=
    ben_pel_shd.g_old_rec.pel_attribute9;
  End If;
  If (p_rec.pel_attribute10 = hr_api.g_varchar2) then
    p_rec.pel_attribute10 :=
    ben_pel_shd.g_old_rec.pel_attribute10;
  End If;
  If (p_rec.pel_attribute11 = hr_api.g_varchar2) then
    p_rec.pel_attribute11 :=
    ben_pel_shd.g_old_rec.pel_attribute11;
  End If;
  If (p_rec.pel_attribute12 = hr_api.g_varchar2) then
    p_rec.pel_attribute12 :=
    ben_pel_shd.g_old_rec.pel_attribute12;
  End If;
  If (p_rec.pel_attribute13 = hr_api.g_varchar2) then
    p_rec.pel_attribute13 :=
    ben_pel_shd.g_old_rec.pel_attribute13;
  End If;
  If (p_rec.pel_attribute14 = hr_api.g_varchar2) then
    p_rec.pel_attribute14 :=
    ben_pel_shd.g_old_rec.pel_attribute14;
  End If;
  If (p_rec.pel_attribute15 = hr_api.g_varchar2) then
    p_rec.pel_attribute15 :=
    ben_pel_shd.g_old_rec.pel_attribute15;
  End If;
  If (p_rec.pel_attribute16 = hr_api.g_varchar2) then
    p_rec.pel_attribute16 :=
    ben_pel_shd.g_old_rec.pel_attribute16;
  End If;
  If (p_rec.pel_attribute17 = hr_api.g_varchar2) then
    p_rec.pel_attribute17 :=
    ben_pel_shd.g_old_rec.pel_attribute17;
  End If;
  If (p_rec.pel_attribute18 = hr_api.g_varchar2) then
    p_rec.pel_attribute18 :=
    ben_pel_shd.g_old_rec.pel_attribute18;
  End If;
  If (p_rec.pel_attribute19 = hr_api.g_varchar2) then
    p_rec.pel_attribute19 :=
    ben_pel_shd.g_old_rec.pel_attribute19;
  End If;
  If (p_rec.pel_attribute20 = hr_api.g_varchar2) then
    p_rec.pel_attribute20 :=
    ben_pel_shd.g_old_rec.pel_attribute20;
  End If;
  If (p_rec.pel_attribute21 = hr_api.g_varchar2) then
    p_rec.pel_attribute21 :=
    ben_pel_shd.g_old_rec.pel_attribute21;
  End If;
  If (p_rec.pel_attribute22 = hr_api.g_varchar2) then
    p_rec.pel_attribute22 :=
    ben_pel_shd.g_old_rec.pel_attribute22;
  End If;
  If (p_rec.pel_attribute23 = hr_api.g_varchar2) then
    p_rec.pel_attribute23 :=
    ben_pel_shd.g_old_rec.pel_attribute23;
  End If;
  If (p_rec.pel_attribute24 = hr_api.g_varchar2) then
    p_rec.pel_attribute24 :=
    ben_pel_shd.g_old_rec.pel_attribute24;
  End If;
  If (p_rec.pel_attribute25 = hr_api.g_varchar2) then
    p_rec.pel_attribute25 :=
    ben_pel_shd.g_old_rec.pel_attribute25;
  End If;
  If (p_rec.pel_attribute26 = hr_api.g_varchar2) then
    p_rec.pel_attribute26 :=
    ben_pel_shd.g_old_rec.pel_attribute26;
  End If;
  If (p_rec.pel_attribute27 = hr_api.g_varchar2) then
    p_rec.pel_attribute27 :=
    ben_pel_shd.g_old_rec.pel_attribute27;
  End If;
  If (p_rec.pel_attribute28 = hr_api.g_varchar2) then
    p_rec.pel_attribute28 :=
    ben_pel_shd.g_old_rec.pel_attribute28;
  End If;
  If (p_rec.pel_attribute29 = hr_api.g_varchar2) then
    p_rec.pel_attribute29 :=
    ben_pel_shd.g_old_rec.pel_attribute29;
  End If;
  If (p_rec.pel_attribute30 = hr_api.g_varchar2) then
    p_rec.pel_attribute30 :=
    ben_pel_shd.g_old_rec.pel_attribute30;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    ben_pel_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    ben_pel_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    ben_pel_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    ben_pel_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.defer_deenrol_flag = hr_api.g_varchar2) then
    p_rec.defer_deenrol_flag :=
    ben_pel_shd.g_old_rec.defer_deenrol_flag;
  End If;
  If (p_rec.deenrol_made_dt = hr_api.g_date) then
    p_rec.deenrol_made_dt :=
    ben_pel_shd.g_old_rec.deenrol_made_dt;
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
  p_rec        in out nocopy ben_pel_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ben_pel_shd.lck
    (
    p_rec.pil_elctbl_chc_popl_id,
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
  ben_pel_bus.update_validate(p_rec
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

    -- DBI - Added DBI Event Logging Hooks
  /* Commented. Need to uncomment when DBI goes into mainline
  5554590 : Enabled DBI logging into mainline */
    if HRI_BPL_BEN_UTIL.enable_ben_col_evt_que then
        HRI_OPL_BEN_ELCTN_EVNTS_EQ.update_event (p_rec => p_rec ,
                                                 p_pil_rec => null,
                                                 p_called_from => 'PEL' ,
                                                 p_effective_date => p_effective_date,
                                                 p_datetrack_mode => 'UPDATE' );
    end if;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date in date,
  p_pil_elctbl_chc_popl_id       in number,
  p_dflt_enrt_dt                 in date             default hr_api.g_date,
  p_dflt_asnd_dt                 in date             default hr_api.g_date,
  p_elcns_made_dt                in date             default hr_api.g_date,
  p_cls_enrt_dt_to_use_cd        in varchar2         default hr_api.g_varchar2,
  p_enrt_typ_cycl_cd             in varchar2         default hr_api.g_varchar2,
  p_enrt_perd_end_dt             in date             default hr_api.g_date,
  p_enrt_perd_strt_dt            in date             default hr_api.g_date,
  p_procg_end_dt                 in date             default hr_api.g_date,
  p_pil_elctbl_popl_stat_cd      in varchar2         default hr_api.g_varchar2,
  p_acty_ref_perd_cd             in varchar2         default hr_api.g_varchar2,
  p_uom                          in varchar2         default hr_api.g_varchar2,
  p_comments                          in varchar2         default hr_api.g_varchar2,
  p_mgr_ovrid_dt                          in date         default hr_api.g_date,
  p_ws_mgr_id                          in number         default hr_api.g_number,
  p_mgr_ovrid_person_id                          in number         default hr_api.g_number,
  p_assignment_id                          in number         default hr_api.g_number,
  --cwb
  p_bdgt_acc_cd                in varchar2         default hr_api.g_varchar2,
  p_pop_cd                     in varchar2         default hr_api.g_varchar2,
  p_bdgt_due_dt                in date             default hr_api.g_date,
  p_bdgt_export_flag           in varchar2         default hr_api.g_varchar2,
  p_bdgt_iss_dt                in date             default hr_api.g_date,
  p_bdgt_stat_cd               in varchar2         default hr_api.g_varchar2,
  p_ws_acc_cd                  in varchar2         default hr_api.g_varchar2,
  p_ws_due_dt                  in date             default hr_api.g_date,
  p_ws_export_flag             in varchar2         default hr_api.g_varchar2,
  p_ws_iss_dt                  in date             default hr_api.g_date,
  p_ws_stat_cd                 in varchar2         default hr_api.g_varchar2,
  --cwb
  p_reinstate_cd               in varchar2         default hr_api.g_varchar2,
  p_reinstate_ovrdn_cd         in varchar2         default hr_api.g_varchar2,
  p_auto_asnd_dt                 in date             default hr_api.g_date,
  p_cbr_elig_perd_strt_dt        in date             default hr_api.g_date,
  p_cbr_elig_perd_end_dt         in date             default hr_api.g_date,
  p_lee_rsn_id                   in number           default hr_api.g_number,
  p_enrt_perd_id                 in number           default hr_api.g_number,
  p_per_in_ler_id                in number           default hr_api.g_number,
  p_pgm_id                       in number           default hr_api.g_number,
  p_pl_id                        in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_pel_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_pel_attribute1               in varchar2         default hr_api.g_varchar2,
  p_pel_attribute2               in varchar2         default hr_api.g_varchar2,
  p_pel_attribute3               in varchar2         default hr_api.g_varchar2,
  p_pel_attribute4               in varchar2         default hr_api.g_varchar2,
  p_pel_attribute5               in varchar2         default hr_api.g_varchar2,
  p_pel_attribute6               in varchar2         default hr_api.g_varchar2,
  p_pel_attribute7               in varchar2         default hr_api.g_varchar2,
  p_pel_attribute8               in varchar2         default hr_api.g_varchar2,
  p_pel_attribute9               in varchar2         default hr_api.g_varchar2,
  p_pel_attribute10              in varchar2         default hr_api.g_varchar2,
  p_pel_attribute11              in varchar2         default hr_api.g_varchar2,
  p_pel_attribute12              in varchar2         default hr_api.g_varchar2,
  p_pel_attribute13              in varchar2         default hr_api.g_varchar2,
  p_pel_attribute14              in varchar2         default hr_api.g_varchar2,
  p_pel_attribute15              in varchar2         default hr_api.g_varchar2,
  p_pel_attribute16              in varchar2         default hr_api.g_varchar2,
  p_pel_attribute17              in varchar2         default hr_api.g_varchar2,
  p_pel_attribute18              in varchar2         default hr_api.g_varchar2,
  p_pel_attribute19              in varchar2         default hr_api.g_varchar2,
  p_pel_attribute20              in varchar2         default hr_api.g_varchar2,
  p_pel_attribute21              in varchar2         default hr_api.g_varchar2,
  p_pel_attribute22              in varchar2         default hr_api.g_varchar2,
  p_pel_attribute23              in varchar2         default hr_api.g_varchar2,
  p_pel_attribute24              in varchar2         default hr_api.g_varchar2,
  p_pel_attribute25              in varchar2         default hr_api.g_varchar2,
  p_pel_attribute26              in varchar2         default hr_api.g_varchar2,
  p_pel_attribute27              in varchar2         default hr_api.g_varchar2,
  p_pel_attribute28              in varchar2         default hr_api.g_varchar2,
  p_pel_attribute29              in varchar2         default hr_api.g_varchar2,
  p_pel_attribute30              in varchar2         default hr_api.g_varchar2,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_object_version_number        in out nocopy number,
  p_defer_deenrol_flag           in varchar2         default hr_api.g_varchar2,
  p_deenrol_made_dt              in date             default hr_api.g_date
  ) is
--
  l_rec   ben_pel_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_pel_shd.convert_args
  (
  p_pil_elctbl_chc_popl_id,
  p_dflt_enrt_dt,
  p_dflt_asnd_dt,
  p_elcns_made_dt,
  p_cls_enrt_dt_to_use_cd,
  p_enrt_typ_cycl_cd,
  p_enrt_perd_end_dt,
  p_enrt_perd_strt_dt,
  p_procg_end_dt,
  p_pil_elctbl_popl_stat_cd,
  p_acty_ref_perd_cd,
  p_uom,
  p_comments,
  p_mgr_ovrid_dt,
  p_ws_mgr_id,
  p_mgr_ovrid_person_id,
  p_assignment_id,
  --cwb
  p_bdgt_acc_cd,
  p_pop_cd,
  p_bdgt_due_dt,
  p_bdgt_export_flag,
  p_bdgt_iss_dt,
  p_bdgt_stat_cd,
  p_ws_acc_cd,
  p_ws_due_dt,
  p_ws_export_flag,
  p_ws_iss_dt,
  p_ws_stat_cd,
  --cwb
  p_reinstate_cd,
  p_reinstate_ovrdn_cd,
  p_auto_asnd_dt,
  p_cbr_elig_perd_strt_dt,
  p_cbr_elig_perd_end_dt,
  p_lee_rsn_id,
  p_enrt_perd_id,
  p_per_in_ler_id,
  p_pgm_id,
  p_pl_id,
  p_business_group_id,
  p_pel_attribute_category,
  p_pel_attribute1,
  p_pel_attribute2,
  p_pel_attribute3,
  p_pel_attribute4,
  p_pel_attribute5,
  p_pel_attribute6,
  p_pel_attribute7,
  p_pel_attribute8,
  p_pel_attribute9,
  p_pel_attribute10,
  p_pel_attribute11,
  p_pel_attribute12,
  p_pel_attribute13,
  p_pel_attribute14,
  p_pel_attribute15,
  p_pel_attribute16,
  p_pel_attribute17,
  p_pel_attribute18,
  p_pel_attribute19,
  p_pel_attribute20,
  p_pel_attribute21,
  p_pel_attribute22,
  p_pel_attribute23,
  p_pel_attribute24,
  p_pel_attribute25,
  p_pel_attribute26,
  p_pel_attribute27,
  p_pel_attribute28,
  p_pel_attribute29,
  p_pel_attribute30,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_object_version_number,
  p_defer_deenrol_flag,
  p_deenrol_made_dt
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
end ben_pel_upd;

/

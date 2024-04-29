--------------------------------------------------------
--  DDL for Package Body BEN_ENP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENP_UPD" as
/* $Header: beenprhi.pkb 120.1.12000000.3 2007/05/13 22:36:53 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_enp_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy ben_enp_shd.g_rec_type) is
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
  ben_enp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_enrt_perd Row
  --
  update ben_enrt_perd
  set
  enrt_perd_id                      = p_rec.enrt_perd_id,
  business_group_id                 = p_rec.business_group_id,
  yr_perd_id                        = p_rec.yr_perd_id,
  popl_enrt_typ_cycl_id             = p_rec.popl_enrt_typ_cycl_id,
  end_dt                            = p_rec.end_dt,
  strt_dt                           = p_rec.strt_dt,
  asnd_lf_evt_dt                    = p_rec.asnd_lf_evt_dt,
  cls_enrt_dt_to_use_cd             = p_rec.cls_enrt_dt_to_use_cd,
  dflt_enrt_dt                      = p_rec.dflt_enrt_dt,
  enrt_cvg_strt_dt_cd               = p_rec.enrt_cvg_strt_dt_cd,
  rt_strt_dt_rl                     = p_rec.rt_strt_dt_rl,
  enrt_cvg_end_dt_cd                = p_rec.enrt_cvg_end_dt_cd,
  enrt_cvg_strt_dt_rl               = p_rec.enrt_cvg_strt_dt_rl,
  enrt_cvg_end_dt_rl                = p_rec.enrt_cvg_end_dt_rl,
  procg_end_dt                      = p_rec.procg_end_dt,
  rt_strt_dt_cd                     = p_rec.rt_strt_dt_cd,
  rt_end_dt_cd                      = p_rec.rt_end_dt_cd,
  rt_end_dt_rl                      = p_rec.rt_end_dt_rl,
  bdgt_upd_strt_dt                  = p_rec.bdgt_upd_strt_dt,
  bdgt_upd_end_dt                   = p_rec.bdgt_upd_end_dt,
  ws_upd_strt_dt                    = p_rec.ws_upd_strt_dt,
  ws_upd_end_dt                     = p_rec.ws_upd_end_dt,
  dflt_ws_acc_cd                    = p_rec.dflt_ws_acc_cd,
  prsvr_bdgt_cd                     = p_rec.prsvr_bdgt_cd,
  uses_bdgt_flag                    = p_rec.uses_bdgt_flag,
  auto_distr_flag                   = p_rec.auto_distr_flag,
  hrchy_to_use_cd                   = p_rec.hrchy_to_use_cd,
  pos_structure_version_id             = p_rec.pos_structure_version_id,
  emp_interview_type_cd             = p_rec.emp_interview_type_cd,
  wthn_yr_perd_id                   = p_rec.wthn_yr_perd_id,
  ler_id                            = p_rec.ler_id,
  perf_revw_strt_dt                 = p_rec.perf_revw_strt_dt,
  asg_updt_eff_date                 = p_rec.asg_updt_eff_date,
  enp_attribute_category            = p_rec.enp_attribute_category,
  enp_attribute1                    = p_rec.enp_attribute1,
  enp_attribute2                    = p_rec.enp_attribute2,
  enp_attribute3                    = p_rec.enp_attribute3,
  enp_attribute4                    = p_rec.enp_attribute4,
  enp_attribute5                    = p_rec.enp_attribute5,
  enp_attribute6                    = p_rec.enp_attribute6,
  enp_attribute7                    = p_rec.enp_attribute7,
  enp_attribute8                    = p_rec.enp_attribute8,
  enp_attribute9                    = p_rec.enp_attribute9,
  enp_attribute10                   = p_rec.enp_attribute10,
  enp_attribute11                   = p_rec.enp_attribute11,
  enp_attribute12                   = p_rec.enp_attribute12,
  enp_attribute13                   = p_rec.enp_attribute13,
  enp_attribute14                   = p_rec.enp_attribute14,
  enp_attribute15                   = p_rec.enp_attribute15,
  enp_attribute16                   = p_rec.enp_attribute16,
  enp_attribute17                   = p_rec.enp_attribute17,
  enp_attribute18                   = p_rec.enp_attribute18,
  enp_attribute19                   = p_rec.enp_attribute19,
  enp_attribute20                   = p_rec.enp_attribute20,
  enp_attribute21                   = p_rec.enp_attribute21,
  enp_attribute22                   = p_rec.enp_attribute22,
  enp_attribute23                   = p_rec.enp_attribute23,
  enp_attribute24                   = p_rec.enp_attribute24,
  enp_attribute25                   = p_rec.enp_attribute25,
  enp_attribute26                   = p_rec.enp_attribute26,
  enp_attribute27                   = p_rec.enp_attribute27,
  enp_attribute28                   = p_rec.enp_attribute28,
  enp_attribute29                   = p_rec.enp_attribute29,
  enp_attribute30                   = p_rec.enp_attribute30,
  enrt_perd_det_ovrlp_bckdt_cd      = p_rec.enrt_perd_det_ovrlp_bckdt_cd,
      --cwb
  data_freeze_date                = p_rec.data_freeze_date,
  Sal_chg_reason_cd               = p_rec.Sal_chg_reason_cd,
  Approval_mode_cd                = p_rec.Approval_mode_cd,
  hrchy_ame_trn_cd                = p_rec.hrchy_ame_trn_cd,
  hrchy_rl                        = p_rec.hrchy_rl,
  hrchy_ame_app_id                = p_rec.hrchy_ame_app_id,
  --
  object_version_number           = p_rec.object_version_number ,
  reinstate_cd			  = p_rec.reinstate_cd,
  reinstate_ovrdn_cd		  = p_rec.reinstate_ovrdn_cd,
  defer_deenrol_flag		  = p_rec.defer_deenrol_flag
  where enrt_perd_id = p_rec.enrt_perd_id;
  --
  ben_enp_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_enp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_enp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_enp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_enp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_enp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_enp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_enp_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in ben_enp_shd.g_rec_type) is
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
p_effective_date in date,p_rec in ben_enp_shd.g_rec_type) is
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
    ben_enp_rku.after_update
      (
  p_enrt_perd_id                  =>p_rec.enrt_perd_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_yr_perd_id                    =>p_rec.yr_perd_id
 ,p_popl_enrt_typ_cycl_id         =>p_rec.popl_enrt_typ_cycl_id
 ,p_end_dt                        =>p_rec.end_dt
 ,p_strt_dt                       =>p_rec.strt_dt
 ,p_asnd_lf_evt_dt                =>p_rec.asnd_lf_evt_dt
 ,p_cls_enrt_dt_to_use_cd         =>p_rec.cls_enrt_dt_to_use_cd
 ,p_dflt_enrt_dt                  =>p_rec.dflt_enrt_dt
 ,p_enrt_cvg_strt_dt_cd           =>p_rec.enrt_cvg_strt_dt_cd
 ,p_rt_strt_dt_rl                 =>p_rec.rt_strt_dt_rl
 ,p_enrt_cvg_end_dt_cd            =>p_rec.enrt_cvg_end_dt_cd
 ,p_enrt_cvg_strt_dt_rl           =>p_rec.enrt_cvg_strt_dt_rl
 ,p_enrt_cvg_end_dt_rl            =>p_rec.enrt_cvg_end_dt_rl
 ,p_procg_end_dt                  =>p_rec.procg_end_dt
 ,p_rt_strt_dt_cd                 =>p_rec.rt_strt_dt_cd
 ,p_rt_end_dt_cd                  =>p_rec.rt_end_dt_cd
 ,p_rt_end_dt_rl                  =>p_rec.rt_end_dt_rl
 ,p_bdgt_upd_strt_dt              =>p_rec.bdgt_upd_strt_dt
 ,p_bdgt_upd_end_dt               =>p_rec.bdgt_upd_end_dt
 ,p_ws_upd_strt_dt                =>p_rec.ws_upd_strt_dt
 ,p_ws_upd_end_dt                 =>p_rec.ws_upd_end_dt
 ,p_dflt_ws_acc_cd                =>p_rec.dflt_ws_acc_cd
 ,p_prsvr_bdgt_cd                 =>p_rec.prsvr_bdgt_cd
 ,p_uses_bdgt_flag                =>p_rec.uses_bdgt_flag
 ,p_auto_distr_flag               =>p_rec.auto_distr_flag
 ,p_hrchy_to_use_cd               =>p_rec.hrchy_to_use_cd
 ,p_pos_structure_version_id         =>p_rec.pos_structure_version_id
 ,p_emp_interview_type_cd         =>p_rec.emp_interview_type_cd
 ,p_wthn_yr_perd_id               =>p_rec.wthn_yr_perd_id
 ,p_ler_id                        =>p_rec.ler_id
 ,p_perf_revw_strt_dt             =>p_rec.perf_revw_strt_dt
 ,p_asg_updt_eff_date             =>p_rec.asg_updt_eff_date
 ,p_enp_attribute_category        =>p_rec.enp_attribute_category
 ,p_enp_attribute1                =>p_rec.enp_attribute1
 ,p_enp_attribute2                =>p_rec.enp_attribute2
 ,p_enp_attribute3                =>p_rec.enp_attribute3
 ,p_enp_attribute4                =>p_rec.enp_attribute4
 ,p_enp_attribute5                =>p_rec.enp_attribute5
 ,p_enp_attribute6                =>p_rec.enp_attribute6
 ,p_enp_attribute7                =>p_rec.enp_attribute7
 ,p_enp_attribute8                =>p_rec.enp_attribute8
 ,p_enp_attribute9                =>p_rec.enp_attribute9
 ,p_enp_attribute10               =>p_rec.enp_attribute10
 ,p_enp_attribute11               =>p_rec.enp_attribute11
 ,p_enp_attribute12               =>p_rec.enp_attribute12
 ,p_enp_attribute13               =>p_rec.enp_attribute13
 ,p_enp_attribute14               =>p_rec.enp_attribute14
 ,p_enp_attribute15               =>p_rec.enp_attribute15
 ,p_enp_attribute16               =>p_rec.enp_attribute16
 ,p_enp_attribute17               =>p_rec.enp_attribute17
 ,p_enp_attribute18               =>p_rec.enp_attribute18
 ,p_enp_attribute19               =>p_rec.enp_attribute19
 ,p_enp_attribute20               =>p_rec.enp_attribute20
 ,p_enp_attribute21               =>p_rec.enp_attribute21
 ,p_enp_attribute22               =>p_rec.enp_attribute22
 ,p_enp_attribute23               =>p_rec.enp_attribute23
 ,p_enp_attribute24               =>p_rec.enp_attribute24
 ,p_enp_attribute25               =>p_rec.enp_attribute25
 ,p_enp_attribute26               =>p_rec.enp_attribute26
 ,p_enp_attribute27               =>p_rec.enp_attribute27
 ,p_enp_attribute28               =>p_rec.enp_attribute28
 ,p_enp_attribute29               =>p_rec.enp_attribute29
 ,p_enp_attribute30               =>p_rec.enp_attribute30
 ,p_enrt_perd_det_ovrlp_bckdt_cd  =>p_rec.enrt_perd_det_ovrlp_bckdt_cd
  --cwb
 ,p_data_freeze_date              =>p_rec.data_freeze_date
 ,p_Sal_chg_reason_cd             =>p_rec.Sal_chg_reason_cd
 ,p_Approval_mode_cd              =>p_rec.Approval_mode_cd
 ,p_hrchy_ame_trn_cd              =>p_rec.hrchy_ame_trn_cd
 ,p_hrchy_rl                      =>p_rec.hrchy_rl
 ,p_hrchy_ame_app_id              =>p_rec.hrchy_ame_app_id
  --
 ,p_object_version_number         =>p_rec.object_version_number
  ,p_reinstate_cd				=>	p_rec.reinstate_cd
  ,p_reinstate_ovrdn_cd		=>    p_rec.reinstate_ovrdn_cd
 ,p_effective_date                =>p_effective_date
 ,p_defer_deenrol_flag         => p_rec.defer_deenrol_flag
 ,p_business_group_id_o           =>ben_enp_shd.g_old_rec.business_group_id
 ,p_yr_perd_id_o                  =>ben_enp_shd.g_old_rec.yr_perd_id
 ,p_popl_enrt_typ_cycl_id_o       =>ben_enp_shd.g_old_rec.popl_enrt_typ_cycl_id
 ,p_end_dt_o                      =>ben_enp_shd.g_old_rec.end_dt
 ,p_strt_dt_o                     =>ben_enp_shd.g_old_rec.strt_dt
 ,p_asnd_lf_evt_dt_o                =>ben_enp_shd.g_old_rec.asnd_lf_evt_dt
 ,p_cls_enrt_dt_to_use_cd_o       =>ben_enp_shd.g_old_rec.cls_enrt_dt_to_use_cd
 ,p_dflt_enrt_dt_o                =>ben_enp_shd.g_old_rec.dflt_enrt_dt
 ,p_enrt_cvg_strt_dt_cd_o         =>ben_enp_shd.g_old_rec.enrt_cvg_strt_dt_cd
 ,p_rt_strt_dt_rl_o               =>ben_enp_shd.g_old_rec.rt_strt_dt_rl
 ,p_enrt_cvg_end_dt_cd_o          =>ben_enp_shd.g_old_rec.enrt_cvg_end_dt_cd
 ,p_enrt_cvg_strt_dt_rl_o         =>ben_enp_shd.g_old_rec.enrt_cvg_strt_dt_rl
 ,p_enrt_cvg_end_dt_rl_o          =>ben_enp_shd.g_old_rec.enrt_cvg_end_dt_rl
 ,p_procg_end_dt_o                =>ben_enp_shd.g_old_rec.procg_end_dt
 ,p_rt_strt_dt_cd_o               =>ben_enp_shd.g_old_rec.rt_strt_dt_cd
 ,p_rt_end_dt_cd_o                =>ben_enp_shd.g_old_rec.rt_end_dt_cd
 ,p_rt_end_dt_rl_o                =>ben_enp_shd.g_old_rec.rt_end_dt_rl
 ,p_bdgt_upd_strt_dt_o            =>ben_enp_shd.g_old_rec.bdgt_upd_strt_dt
 ,p_bdgt_upd_end_dt_o             =>ben_enp_shd.g_old_rec.bdgt_upd_end_dt
 ,p_ws_upd_strt_dt_o              =>ben_enp_shd.g_old_rec.ws_upd_strt_dt
 ,p_ws_upd_end_dt_o               =>ben_enp_shd.g_old_rec.ws_upd_end_dt
 ,p_dflt_ws_acc_cd_o              =>ben_enp_shd.g_old_rec.dflt_ws_acc_cd
 ,p_prsvr_bdgt_cd_o               =>ben_enp_shd.g_old_rec.prsvr_bdgt_cd
 ,p_uses_bdgt_flag_o              =>ben_enp_shd.g_old_rec.uses_bdgt_flag
 ,p_auto_distr_flag_o             =>ben_enp_shd.g_old_rec.auto_distr_flag
 ,p_hrchy_to_use_cd_o             =>ben_enp_shd.g_old_rec.hrchy_to_use_cd
 ,p_pos_structure_version_id_o       =>ben_enp_shd.g_old_rec.pos_structure_version_id
 ,p_emp_interview_type_cd_o       =>ben_enp_shd.g_old_rec.emp_interview_type_cd
 ,p_wthn_yr_perd_id_o             =>ben_enp_shd.g_old_rec.wthn_yr_perd_id
 ,p_ler_id_o                      =>ben_enp_shd.g_old_rec.ler_id
 ,p_perf_revw_strt_dt_o           =>ben_enp_shd.g_old_rec.perf_revw_strt_dt
 ,p_asg_updt_eff_date_o           =>ben_enp_shd.g_old_rec.asg_updt_eff_date
 ,p_enp_attribute_category_o      =>ben_enp_shd.g_old_rec.enp_attribute_category
 ,p_enp_attribute1_o              =>ben_enp_shd.g_old_rec.enp_attribute1
 ,p_enp_attribute2_o              =>ben_enp_shd.g_old_rec.enp_attribute2
 ,p_enp_attribute3_o              =>ben_enp_shd.g_old_rec.enp_attribute3
 ,p_enp_attribute4_o              =>ben_enp_shd.g_old_rec.enp_attribute4
 ,p_enp_attribute5_o              =>ben_enp_shd.g_old_rec.enp_attribute5
 ,p_enp_attribute6_o              =>ben_enp_shd.g_old_rec.enp_attribute6
 ,p_enp_attribute7_o              =>ben_enp_shd.g_old_rec.enp_attribute7
 ,p_enp_attribute8_o              =>ben_enp_shd.g_old_rec.enp_attribute8
 ,p_enp_attribute9_o              =>ben_enp_shd.g_old_rec.enp_attribute9
 ,p_enp_attribute10_o             =>ben_enp_shd.g_old_rec.enp_attribute10
 ,p_enp_attribute11_o             =>ben_enp_shd.g_old_rec.enp_attribute11
 ,p_enp_attribute12_o             =>ben_enp_shd.g_old_rec.enp_attribute12
 ,p_enp_attribute13_o             =>ben_enp_shd.g_old_rec.enp_attribute13
 ,p_enp_attribute14_o             =>ben_enp_shd.g_old_rec.enp_attribute14
 ,p_enp_attribute15_o             =>ben_enp_shd.g_old_rec.enp_attribute15
 ,p_enp_attribute16_o             =>ben_enp_shd.g_old_rec.enp_attribute16
 ,p_enp_attribute17_o             =>ben_enp_shd.g_old_rec.enp_attribute17
 ,p_enp_attribute18_o             =>ben_enp_shd.g_old_rec.enp_attribute18
 ,p_enp_attribute19_o             =>ben_enp_shd.g_old_rec.enp_attribute19
 ,p_enp_attribute20_o             =>ben_enp_shd.g_old_rec.enp_attribute20
 ,p_enp_attribute21_o             =>ben_enp_shd.g_old_rec.enp_attribute21
 ,p_enp_attribute22_o             =>ben_enp_shd.g_old_rec.enp_attribute22
 ,p_enp_attribute23_o             =>ben_enp_shd.g_old_rec.enp_attribute23
 ,p_enp_attribute24_o             =>ben_enp_shd.g_old_rec.enp_attribute24
 ,p_enp_attribute25_o             =>ben_enp_shd.g_old_rec.enp_attribute25
 ,p_enp_attribute26_o             =>ben_enp_shd.g_old_rec.enp_attribute26
 ,p_enp_attribute27_o             =>ben_enp_shd.g_old_rec.enp_attribute27
 ,p_enp_attribute28_o             =>ben_enp_shd.g_old_rec.enp_attribute28
 ,p_enp_attribute29_o             =>ben_enp_shd.g_old_rec.enp_attribute29
 ,p_enp_attribute30_o             =>ben_enp_shd.g_old_rec.enp_attribute30
 --,p_enrt_perd_det_ovrlp_bckdt_cd_o             =>ben_enp_shd.g_old_rec.enrt_perd_det_ovrlp_bckdt_cd
 ,p_enrt_perd_det_ovrlp_cd_o             =>ben_enp_shd.g_old_rec.enrt_perd_det_ovrlp_bckdt_cd
   --cwb
 ,p_data_freeze_date_o             =>ben_enp_shd.g_old_rec.data_freeze_date
 ,p_Sal_chg_reason_cd_o            =>ben_enp_shd.g_old_rec.Sal_chg_reason_cd
 ,p_Approval_mode_cd_o             =>ben_enp_shd.g_old_rec.Approval_mode_cd
 ,p_hrchy_ame_trn_cd_o             =>ben_enp_shd.g_old_rec.hrchy_ame_trn_cd
 ,p_hrchy_rl_o                     =>ben_enp_shd.g_old_rec.hrchy_rl
 ,p_hrchy_ame_app_id_o             =>ben_enp_shd.g_old_rec.hrchy_ame_app_id
  --
 ,p_object_version_number_o       =>ben_enp_shd.g_old_rec.object_version_number
  ,p_reinstate_cd_o				=>	ben_enp_shd.g_old_rec.reinstate_cd
  ,p_reinstate_ovrdn_cd_o		=>    ben_enp_shd.g_old_rec.reinstate_ovrdn_cd
 ,p_defer_deenrol_flag_o                => ben_enp_shd.g_old_rec.defer_deenrol_flag

      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_enrt_perd'
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
Procedure convert_defs(p_rec in out nocopy ben_enp_shd.g_rec_type) is
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
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_enp_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.yr_perd_id = hr_api.g_number) then
    p_rec.yr_perd_id :=
    ben_enp_shd.g_old_rec.yr_perd_id;
  End If;
  If (p_rec.popl_enrt_typ_cycl_id = hr_api.g_number) then
    p_rec.popl_enrt_typ_cycl_id :=
    ben_enp_shd.g_old_rec.popl_enrt_typ_cycl_id;
  End If;
  If (p_rec.end_dt = hr_api.g_date) then
    p_rec.end_dt :=
    ben_enp_shd.g_old_rec.end_dt;
  End If;
  If (p_rec.strt_dt = hr_api.g_date) then
    p_rec.strt_dt :=
    ben_enp_shd.g_old_rec.strt_dt;
  End If;
  If (p_rec.asnd_lf_evt_dt = hr_api.g_date) then
    p_rec.asnd_lf_evt_dt :=
    ben_enp_shd.g_old_rec.asnd_lf_evt_dt;
  End If;
  If (p_rec.cls_enrt_dt_to_use_cd = hr_api.g_varchar2) then
    p_rec.cls_enrt_dt_to_use_cd :=
    ben_enp_shd.g_old_rec.cls_enrt_dt_to_use_cd;
  End If;
  If (p_rec.dflt_enrt_dt = hr_api.g_date) then
    p_rec.dflt_enrt_dt :=
    ben_enp_shd.g_old_rec.dflt_enrt_dt;
  End If;
  If (p_rec.enrt_cvg_strt_dt_cd = hr_api.g_varchar2) then
    p_rec.enrt_cvg_strt_dt_cd :=
    ben_enp_shd.g_old_rec.enrt_cvg_strt_dt_cd;
  End If;
  If (p_rec.rt_strt_dt_rl = hr_api.g_number) then
    p_rec.rt_strt_dt_rl :=
    ben_enp_shd.g_old_rec.rt_strt_dt_rl;
  End If;
  If (p_rec.enrt_cvg_end_dt_cd = hr_api.g_varchar2) then
    p_rec.enrt_cvg_end_dt_cd :=
    ben_enp_shd.g_old_rec.enrt_cvg_end_dt_cd;
  End If;
  If (p_rec.enrt_cvg_strt_dt_rl = hr_api.g_number) then
    p_rec.enrt_cvg_strt_dt_rl :=
    ben_enp_shd.g_old_rec.enrt_cvg_strt_dt_rl;
  End If;
  If (p_rec.enrt_cvg_end_dt_rl = hr_api.g_number) then
    p_rec.enrt_cvg_end_dt_rl :=
    ben_enp_shd.g_old_rec.enrt_cvg_end_dt_rl;
  End If;
  If (p_rec.procg_end_dt = hr_api.g_date) then
    p_rec.procg_end_dt :=
    ben_enp_shd.g_old_rec.procg_end_dt;
  End If;
  If (p_rec.rt_strt_dt_cd = hr_api.g_varchar2) then
    p_rec.rt_strt_dt_cd :=
    ben_enp_shd.g_old_rec.rt_strt_dt_cd;
  End If;
  If (p_rec.rt_end_dt_cd = hr_api.g_varchar2) then
    p_rec.rt_end_dt_cd :=
    ben_enp_shd.g_old_rec.rt_end_dt_cd;
  End If;
  If (p_rec.rt_end_dt_rl = hr_api.g_number) then
    p_rec.rt_end_dt_rl :=
    ben_enp_shd.g_old_rec.rt_end_dt_rl;
  End If;
-- CompWorkBench Additions
    If (p_rec.bdgt_upd_strt_dt = hr_api.g_date) then
      p_rec.bdgt_upd_strt_dt :=
      ben_enp_shd.g_old_rec.bdgt_upd_strt_dt;
    End If;
    If (p_rec.bdgt_upd_end_dt= hr_api.g_date) then
      p_rec.bdgt_upd_end_dt :=
      ben_enp_shd.g_old_rec.bdgt_upd_end_dt;
    End If;
    If (p_rec.ws_upd_strt_dt= hr_api.g_date) then
      p_rec.ws_upd_strt_dt :=
      ben_enp_shd.g_old_rec.ws_upd_strt_dt;
    End If;
    If (p_rec.ws_upd_end_dt = hr_api.g_date) then
      p_rec.ws_upd_end_dt :=
      ben_enp_shd.g_old_rec.ws_upd_end_dt;
    End If;
    If (p_rec.dflt_ws_acc_cd= hr_api.g_varchar2) then
      p_rec.dflt_ws_acc_cd :=
      ben_enp_shd.g_old_rec.dflt_ws_acc_cd;
    End If;
    If (p_rec.prsvr_bdgt_cd = hr_api.g_varchar2) then
      p_rec.prsvr_bdgt_cd :=
      ben_enp_shd.g_old_rec.prsvr_bdgt_cd;
    End If;
    If (p_rec.uses_bdgt_flag = hr_api.g_varchar2) then
      p_rec.uses_bdgt_flag :=
      ben_enp_shd.g_old_rec.uses_bdgt_flag;
    End If;
    If (p_rec.auto_distr_flag = hr_api.g_varchar2) then
      p_rec.auto_distr_flag :=
      ben_enp_shd.g_old_rec.auto_distr_flag;
    End If;
    If (p_rec.hrchy_to_use_cd = hr_api.g_varchar2) then
      p_rec.hrchy_to_use_cd :=
      ben_enp_shd.g_old_rec.hrchy_to_use_cd;
    End If;
    If (p_rec.pos_structure_version_id = hr_api.g_number) then
      p_rec.pos_structure_version_id :=
      ben_enp_shd.g_old_rec.pos_structure_version_id;
    End If;
    If (p_rec.emp_interview_type_cd = hr_api.g_varchar2) then
      p_rec.emp_interview_type_cd :=
      ben_enp_shd.g_old_rec.emp_interview_type_cd;
    End If;
    If (p_rec.wthn_yr_perd_id = hr_api.g_number) then
      p_rec.wthn_yr_perd_id :=
      ben_enp_shd.g_old_rec.wthn_yr_perd_id;
    End If;
    If (p_rec.ler_id = hr_api.g_number) then
      p_rec.ler_id :=
      ben_enp_shd.g_old_rec.ler_id;
    End If;
    If (p_rec.perf_revw_strt_dt = hr_api.g_date) then
      p_rec.perf_revw_strt_dt :=
      ben_enp_shd.g_old_rec.perf_revw_strt_dt;
    End If;
    If (p_rec.asg_updt_eff_date = hr_api.g_date) then
      p_rec.asg_updt_eff_date :=
      ben_enp_shd.g_old_rec.asg_updt_eff_date;
    End If;
-- end CompWorkBench additions
  If (p_rec.enp_attribute_category = hr_api.g_varchar2) then
    p_rec.enp_attribute_category :=
    ben_enp_shd.g_old_rec.enp_attribute_category;
  End If;
  If (p_rec.enp_attribute1 = hr_api.g_varchar2) then
    p_rec.enp_attribute1 :=
    ben_enp_shd.g_old_rec.enp_attribute1;
  End If;
  If (p_rec.enp_attribute2 = hr_api.g_varchar2) then
    p_rec.enp_attribute2 :=
    ben_enp_shd.g_old_rec.enp_attribute2;
  End If;
  If (p_rec.enp_attribute3 = hr_api.g_varchar2) then
    p_rec.enp_attribute3 :=
    ben_enp_shd.g_old_rec.enp_attribute3;
  End If;
  If (p_rec.enp_attribute4 = hr_api.g_varchar2) then
    p_rec.enp_attribute4 :=
    ben_enp_shd.g_old_rec.enp_attribute4;
  End If;
  If (p_rec.enp_attribute5 = hr_api.g_varchar2) then
    p_rec.enp_attribute5 :=
    ben_enp_shd.g_old_rec.enp_attribute5;
  End If;
  If (p_rec.enp_attribute6 = hr_api.g_varchar2) then
    p_rec.enp_attribute6 :=
    ben_enp_shd.g_old_rec.enp_attribute6;
  End If;
  If (p_rec.enp_attribute7 = hr_api.g_varchar2) then
    p_rec.enp_attribute7 :=
    ben_enp_shd.g_old_rec.enp_attribute7;
  End If;
  If (p_rec.enp_attribute8 = hr_api.g_varchar2) then
    p_rec.enp_attribute8 :=
    ben_enp_shd.g_old_rec.enp_attribute8;
  End If;
  If (p_rec.enp_attribute9 = hr_api.g_varchar2) then
    p_rec.enp_attribute9 :=
    ben_enp_shd.g_old_rec.enp_attribute9;
  End If;
  If (p_rec.enp_attribute10 = hr_api.g_varchar2) then
    p_rec.enp_attribute10 :=
    ben_enp_shd.g_old_rec.enp_attribute10;
  End If;
  If (p_rec.enp_attribute11 = hr_api.g_varchar2) then
    p_rec.enp_attribute11 :=
    ben_enp_shd.g_old_rec.enp_attribute11;
  End If;
  If (p_rec.enp_attribute12 = hr_api.g_varchar2) then
    p_rec.enp_attribute12 :=
    ben_enp_shd.g_old_rec.enp_attribute12;
  End If;
  If (p_rec.enp_attribute13 = hr_api.g_varchar2) then
    p_rec.enp_attribute13 :=
    ben_enp_shd.g_old_rec.enp_attribute13;
  End If;
  If (p_rec.enp_attribute14 = hr_api.g_varchar2) then
    p_rec.enp_attribute14 :=
    ben_enp_shd.g_old_rec.enp_attribute14;
  End If;
  If (p_rec.enp_attribute15 = hr_api.g_varchar2) then
    p_rec.enp_attribute15 :=
    ben_enp_shd.g_old_rec.enp_attribute15;
  End If;
  If (p_rec.enp_attribute16 = hr_api.g_varchar2) then
    p_rec.enp_attribute16 :=
    ben_enp_shd.g_old_rec.enp_attribute16;
  End If;
  If (p_rec.enp_attribute17 = hr_api.g_varchar2) then
    p_rec.enp_attribute17 :=
    ben_enp_shd.g_old_rec.enp_attribute17;
  End If;
  If (p_rec.enp_attribute18 = hr_api.g_varchar2) then
    p_rec.enp_attribute18 :=
    ben_enp_shd.g_old_rec.enp_attribute18;
  End If;
  If (p_rec.enp_attribute19 = hr_api.g_varchar2) then
    p_rec.enp_attribute19 :=
    ben_enp_shd.g_old_rec.enp_attribute19;
  End If;
  If (p_rec.enp_attribute20 = hr_api.g_varchar2) then
    p_rec.enp_attribute20 :=
    ben_enp_shd.g_old_rec.enp_attribute20;
  End If;
  If (p_rec.enp_attribute21 = hr_api.g_varchar2) then
    p_rec.enp_attribute21 :=
    ben_enp_shd.g_old_rec.enp_attribute21;
  End If;
  If (p_rec.enp_attribute22 = hr_api.g_varchar2) then
    p_rec.enp_attribute22 :=
    ben_enp_shd.g_old_rec.enp_attribute22;
  End If;
  If (p_rec.enp_attribute23 = hr_api.g_varchar2) then
    p_rec.enp_attribute23 :=
    ben_enp_shd.g_old_rec.enp_attribute23;
  End If;
  If (p_rec.enp_attribute24 = hr_api.g_varchar2) then
    p_rec.enp_attribute24 :=
    ben_enp_shd.g_old_rec.enp_attribute24;
  End If;
  If (p_rec.enp_attribute25 = hr_api.g_varchar2) then
    p_rec.enp_attribute25 :=
    ben_enp_shd.g_old_rec.enp_attribute25;
  End If;
  If (p_rec.enp_attribute26 = hr_api.g_varchar2) then
    p_rec.enp_attribute26 :=
    ben_enp_shd.g_old_rec.enp_attribute26;
  End If;
  If (p_rec.enp_attribute27 = hr_api.g_varchar2) then
    p_rec.enp_attribute27 :=
    ben_enp_shd.g_old_rec.enp_attribute27;
  End If;
  If (p_rec.enp_attribute28 = hr_api.g_varchar2) then
    p_rec.enp_attribute28 :=
    ben_enp_shd.g_old_rec.enp_attribute28;
  End If;
  If (p_rec.enp_attribute29 = hr_api.g_varchar2) then
    p_rec.enp_attribute29 :=
    ben_enp_shd.g_old_rec.enp_attribute29;
  End If;
  If (p_rec.enp_attribute30 = hr_api.g_varchar2) then
    p_rec.enp_attribute30 :=
    ben_enp_shd.g_old_rec.enp_attribute30;
  End If;
  --
  If (p_rec.enrt_perd_det_ovrlp_bckdt_cd = hr_api.g_varchar2) then
    p_rec.enrt_perd_det_ovrlp_bckdt_cd :=
    ben_enp_shd.g_old_rec.enrt_perd_det_ovrlp_bckdt_cd;
  End if;

 --- cwb
  If (p_rec.data_freeze_date = hr_api.g_date) then
      p_rec.data_freeze_date :=
      ben_enp_shd.g_old_rec.data_freeze_date;
  End If;

  If (p_rec.Sal_chg_reason_cd = hr_api.g_varchar2) then
    p_rec.Sal_chg_reason_cd :=
    ben_enp_shd.g_old_rec.Sal_chg_reason_cd;
  End if;

  If (p_rec.Approval_mode_cd = hr_api.g_varchar2) then
    p_rec.Approval_mode_cd :=
    ben_enp_shd.g_old_rec.Approval_mode_cd;
  End if;

  If (p_rec.hrchy_ame_trn_cd = hr_api.g_varchar2) then
    p_rec.hrchy_ame_trn_cd :=
    ben_enp_shd.g_old_rec.hrchy_ame_trn_cd;
  End if;

  If (p_rec.hrchy_rl = hr_api.g_number) then
      p_rec.hrchy_rl :=
      ben_enp_shd.g_old_rec.hrchy_rl;
  End If;

  If (p_rec.hrchy_ame_app_id = hr_api.g_number) then
      p_rec.hrchy_ame_app_id :=
      ben_enp_shd.g_old_rec.hrchy_ame_app_id;
  End If;

  If (p_rec.reinstate_cd = hr_api.g_varchar2) then
    p_rec.reinstate_cd :=
    ben_enp_shd.g_old_rec.reinstate_cd;
  End if;

If (p_rec.reinstate_ovrdn_cd = hr_api.g_varchar2) then
    p_rec.reinstate_ovrdn_cd :=
    ben_enp_shd.g_old_rec.reinstate_ovrdn_cd;
  End if;

If (p_rec.defer_deenrol_flag = hr_api.g_varchar2) then
    p_rec.defer_deenrol_flag :=
    ben_enp_shd.g_old_rec.defer_deenrol_flag;
  End if;
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
  p_rec        in out nocopy ben_enp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ben_enp_shd.lck
	(
	p_rec.enrt_perd_id,
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
  ben_enp_bus.update_validate(p_rec
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
  p_enrt_perd_id                 in number,
  p_business_group_id            in number           ,
  p_yr_perd_id                   in number           ,
  p_popl_enrt_typ_cycl_id        in number           ,
  p_end_dt                       in date             ,
  p_strt_dt                      in date             ,
  p_asnd_lf_evt_dt               in date             ,
  p_cls_enrt_dt_to_use_cd        in varchar2         ,
  p_dflt_enrt_dt                 in date             ,
  p_enrt_cvg_strt_dt_cd          in varchar2         ,
  p_rt_strt_dt_rl                in number           ,
  p_enrt_cvg_end_dt_cd           in varchar2         ,
  p_enrt_cvg_strt_dt_rl          in number           ,
  p_enrt_cvg_end_dt_rl           in number           ,
  p_procg_end_dt                 in date             ,
  p_rt_strt_dt_cd                in varchar2         ,
  p_rt_end_dt_cd                 in varchar2         ,
  p_rt_end_dt_rl                 in number           ,
  p_bdgt_upd_strt_dt             in  date            ,
  p_bdgt_upd_end_dt              in  date            ,
  p_ws_upd_strt_dt               in  date            ,
  p_ws_upd_end_dt                in  date            ,
  p_dflt_ws_acc_cd               in  varchar2        ,
  p_prsvr_bdgt_cd                in  varchar2        ,
  p_uses_bdgt_flag               in  varchar2        ,
  p_auto_distr_flag              in  varchar2        ,
  p_hrchy_to_use_cd              in  varchar2        ,
  p_pos_structure_version_id        in  number       ,
  p_emp_interview_type_cd        in  varchar2        ,
  p_wthn_yr_perd_id              in  number          ,
  p_ler_id                       in  number          ,
  p_perf_revw_strt_dt            in date             ,
  p_asg_updt_eff_date            in date             ,
  p_enp_attribute_category       in varchar2         ,
  p_enp_attribute1               in varchar2         ,
  p_enp_attribute2               in varchar2         ,
  p_enp_attribute3               in varchar2         ,
  p_enp_attribute4               in varchar2         ,
  p_enp_attribute5               in varchar2         ,
  p_enp_attribute6               in varchar2         ,
  p_enp_attribute7               in varchar2         ,
  p_enp_attribute8               in varchar2         ,
  p_enp_attribute9               in varchar2         ,
  p_enp_attribute10              in varchar2         ,
  p_enp_attribute11              in varchar2         ,
  p_enp_attribute12              in varchar2         ,
  p_enp_attribute13              in varchar2         ,
  p_enp_attribute14              in varchar2         ,
  p_enp_attribute15              in varchar2         ,
  p_enp_attribute16              in varchar2         ,
  p_enp_attribute17              in varchar2         ,
  p_enp_attribute18              in varchar2         ,
  p_enp_attribute19              in varchar2         ,
  p_enp_attribute20              in varchar2         ,
  p_enp_attribute21              in varchar2         ,
  p_enp_attribute22              in varchar2         ,
  p_enp_attribute23              in varchar2         ,
  p_enp_attribute24              in varchar2         ,
  p_enp_attribute25              in varchar2         ,
  p_enp_attribute26              in varchar2         ,
  p_enp_attribute27              in varchar2         ,
  p_enp_attribute28              in varchar2         ,
  p_enp_attribute29              in varchar2         ,
  p_enp_attribute30              in varchar2         ,
  p_enrt_perd_det_ovrlp_bckdt_cd in varchar2         ,
    --cwb
  p_data_freeze_date             in  date    ,
  p_Sal_chg_reason_cd            in  varchar2,
  p_Approval_mode_cd             in  varchar2,
  p_hrchy_ame_trn_cd             in  varchar2,
  p_hrchy_rl                     in  number,
  p_hrchy_ame_app_id             in  number ,
  ---
  p_object_version_number        in out nocopy number ,
  p_reinstate_cd			in varchar2,
  p_reinstate_ovrdn_cd		in varchar2,
  p_defer_deenrol_flag          in varchar2
  ) is
--
  l_rec	  ben_enp_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_enp_shd.convert_args
  (
  p_enrt_perd_id,
  p_business_group_id,
  p_yr_perd_id,
  p_popl_enrt_typ_cycl_id,
  p_end_dt,
  p_strt_dt,
  p_asnd_lf_evt_dt,
  p_cls_enrt_dt_to_use_cd,
  p_dflt_enrt_dt,
  p_enrt_cvg_strt_dt_cd,
  p_rt_strt_dt_rl,
  p_enrt_cvg_end_dt_cd,
  p_enrt_cvg_strt_dt_rl,
  p_enrt_cvg_end_dt_rl,
  p_procg_end_dt,
  p_rt_strt_dt_cd,
  p_rt_end_dt_cd,
  p_rt_end_dt_rl,
  p_bdgt_upd_strt_dt,
  p_bdgt_upd_end_dt,
  p_ws_upd_strt_dt,
  p_ws_upd_end_dt,
  p_dflt_ws_acc_cd,
  p_prsvr_bdgt_cd,
  p_uses_bdgt_flag,
  p_auto_distr_flag,
  p_hrchy_to_use_cd,
  p_pos_structure_version_id,
  p_emp_interview_type_cd,
  p_wthn_yr_perd_id,
  p_ler_id,
  p_perf_revw_strt_dt,
  p_asg_updt_eff_date,
  p_enp_attribute_category,
  p_enp_attribute1,
  p_enp_attribute2,
  p_enp_attribute3,
  p_enp_attribute4,
  p_enp_attribute5,
  p_enp_attribute6,
  p_enp_attribute7,
  p_enp_attribute8,
  p_enp_attribute9,
  p_enp_attribute10,
  p_enp_attribute11,
  p_enp_attribute12,
  p_enp_attribute13,
  p_enp_attribute14,
  p_enp_attribute15,
  p_enp_attribute16,
  p_enp_attribute17,
  p_enp_attribute18,
  p_enp_attribute19,
  p_enp_attribute20,
  p_enp_attribute21,
  p_enp_attribute22,
  p_enp_attribute23,
  p_enp_attribute24,
  p_enp_attribute25,
  p_enp_attribute26,
  p_enp_attribute27,
  p_enp_attribute28,
  p_enp_attribute29,
  p_enp_attribute30,
  p_enrt_perd_det_ovrlp_bckdt_cd,
  --cwb
  p_data_freeze_date,
  p_Sal_chg_reason_cd,
  p_Approval_mode_cd,
  p_hrchy_ame_trn_cd,
  p_hrchy_rl        ,
  p_hrchy_ame_app_id,
  --
  p_object_version_number ,
  p_reinstate_cd,
  p_reinstate_ovrdn_cd,
  p_defer_deenrol_flag
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
end ben_enp_upd;

/

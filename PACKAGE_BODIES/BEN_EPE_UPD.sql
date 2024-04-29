--------------------------------------------------------
--  DDL for Package Body BEN_EPE_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EPE_UPD" as
/* $Header: beeperhi.pkb 120.0 2005/05/28 02:36:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_epe_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy ben_epe_shd.g_rec_type) is
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
  ben_epe_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_elig_per_elctbl_chc Row
  --
  update ben_elig_per_elctbl_chc
  set
  elig_per_elctbl_chc_id            = p_rec.elig_per_elctbl_chc_id,
--  enrt_typ_cycl_cd                  = p_rec.enrt_typ_cycl_cd,
  enrt_cvg_strt_dt_cd               = p_rec.enrt_cvg_strt_dt_cd,
--  enrt_perd_end_dt                  = p_rec.enrt_perd_end_dt,
--  enrt_perd_strt_dt                 = p_rec.enrt_perd_strt_dt,
  enrt_cvg_strt_dt_rl               = p_rec.enrt_cvg_strt_dt_rl,
--  rt_strt_dt                        = p_rec.rt_strt_dt,
--  rt_strt_dt_rl                     = p_rec.rt_strt_dt_rl,
--  rt_strt_dt_cd                     = p_rec.rt_strt_dt_cd,
  ctfn_rqd_flag                     = p_rec.ctfn_rqd_flag,
  pil_elctbl_chc_popl_id            = p_rec.pil_elctbl_chc_popl_id,
  roll_crs_flag                = p_rec.roll_crs_flag,
  crntly_enrd_flag                  = p_rec.crntly_enrd_flag,
  dflt_flag                         = p_rec.dflt_flag,
  elctbl_flag                       = p_rec.elctbl_flag,
  mndtry_flag                       = p_rec.mndtry_flag,
  in_pndg_wkflow_flag               = p_rec.in_pndg_wkflow_flag,
--  dflt_enrt_dt                      = p_rec.dflt_enrt_dt,
  dpnt_cvg_strt_dt_cd               = p_rec.dpnt_cvg_strt_dt_cd,
  dpnt_cvg_strt_dt_rl               = p_rec.dpnt_cvg_strt_dt_rl,
  enrt_cvg_strt_dt                  = p_rec.enrt_cvg_strt_dt,
  alws_dpnt_dsgn_flag               = p_rec.alws_dpnt_dsgn_flag,
  dpnt_dsgn_cd                      = p_rec.dpnt_dsgn_cd,
  ler_chg_dpnt_cvg_cd               = p_rec.ler_chg_dpnt_cvg_cd,
  erlst_deenrt_dt                   = p_rec.erlst_deenrt_dt,
  procg_end_dt                      = p_rec.procg_end_dt,
  comp_lvl_cd                       = p_rec.comp_lvl_cd,
  pl_id                             = p_rec.pl_id,
  oipl_id                           = p_rec.oipl_id,
  pgm_id                            = p_rec.pgm_id,
  plip_id                           = p_rec.plip_id,
  ptip_id                           = p_rec.ptip_id,
  pl_typ_id                         = p_rec.pl_typ_id,
  oiplip_id                         = p_rec.oiplip_id,
  cmbn_plip_id                      = p_rec.cmbn_plip_id,
  cmbn_ptip_id                      = p_rec.cmbn_ptip_id,
  cmbn_ptip_opt_id                  = p_rec.cmbn_ptip_opt_id,
  assignment_id                     = p_rec.assignment_id,
  spcl_rt_pl_id                     = p_rec.spcl_rt_pl_id,
  spcl_rt_oipl_id                   = p_rec.spcl_rt_oipl_id,
  must_enrl_anthr_pl_id             = p_rec.must_enrl_anthr_pl_id,
  interim_elig_per_elctbl_chc_id    = p_rec.int_elig_per_elctbl_chc_id,
  prtt_enrt_rslt_id                 = p_rec.prtt_enrt_rslt_id,
  bnft_prvdr_pool_id                = p_rec.bnft_prvdr_pool_id,
  per_in_ler_id                     = p_rec.per_in_ler_id,
  yr_perd_id                        = p_rec.yr_perd_id,
  auto_enrt_flag                    = p_rec.auto_enrt_flag,
  business_group_id                 = p_rec.business_group_id,
  pl_ordr_num                       = p_rec.pl_ordr_num,
  plip_ordr_num                     = p_rec.plip_ordr_num,
  ptip_ordr_num                       = p_rec.ptip_ordr_num,
  oipl_ordr_num                       = p_rec.oipl_ordr_num,
  -- cwb
  comments                          = p_rec.comments,
  elig_flag                         = p_rec.elig_flag,
  elig_ovrid_dt                     = p_rec.elig_ovrid_dt,
  elig_ovrid_person_id              = p_rec.elig_ovrid_person_id,
  inelig_rsn_cd                     = p_rec.inelig_rsn_cd,
  mgr_ovrid_dt                      = p_rec.mgr_ovrid_dt,
  mgr_ovrid_person_id               = p_rec.mgr_ovrid_person_id,
  ws_mgr_id                         = p_rec.ws_mgr_id,
  -- cwb
  epe_attribute_category            = p_rec.epe_attribute_category,
  epe_attribute1                    = p_rec.epe_attribute1,
  epe_attribute2                    = p_rec.epe_attribute2,
  epe_attribute3                    = p_rec.epe_attribute3,
  epe_attribute4                    = p_rec.epe_attribute4,
  epe_attribute5                    = p_rec.epe_attribute5,
  epe_attribute6                    = p_rec.epe_attribute6,
  epe_attribute7                    = p_rec.epe_attribute7,
  epe_attribute8                    = p_rec.epe_attribute8,
  epe_attribute9                    = p_rec.epe_attribute9,
  epe_attribute10                   = p_rec.epe_attribute10,
  epe_attribute11                   = p_rec.epe_attribute11,
  epe_attribute12                   = p_rec.epe_attribute12,
  epe_attribute13                   = p_rec.epe_attribute13,
  epe_attribute14                   = p_rec.epe_attribute14,
  epe_attribute15                   = p_rec.epe_attribute15,
  epe_attribute16                   = p_rec.epe_attribute16,
  epe_attribute17                   = p_rec.epe_attribute17,
  epe_attribute18                   = p_rec.epe_attribute18,
  epe_attribute19                   = p_rec.epe_attribute19,
  epe_attribute20                   = p_rec.epe_attribute20,
  epe_attribute21                   = p_rec.epe_attribute21,
  epe_attribute22                   = p_rec.epe_attribute22,
  epe_attribute23                   = p_rec.epe_attribute23,
  epe_attribute24                   = p_rec.epe_attribute24,
  epe_attribute25                   = p_rec.epe_attribute25,
  epe_attribute26                   = p_rec.epe_attribute26,
  epe_attribute27                   = p_rec.epe_attribute27,
  epe_attribute28                   = p_rec.epe_attribute28,
  epe_attribute29                   = p_rec.epe_attribute29,
  epe_attribute30                   = p_rec.epe_attribute30,
  approval_status_cd                   = p_rec.approval_status_cd,
  fonm_cvg_strt_dt                  = p_rec.fonm_cvg_strt_dt,
  cryfwd_elig_dpnt_cd               = p_rec.cryfwd_elig_dpnt_cd,
  request_id                        = p_rec.request_id,
  program_application_id            = p_rec.program_application_id,
  program_id                        = p_rec.program_id,
  program_update_date               = p_rec.program_update_date,
  object_version_number             = p_rec.object_version_number
  where elig_per_elctbl_chc_id = p_rec.elig_per_elctbl_chc_id;
  --
  ben_epe_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_epe_shd.g_api_dml := false;   -- Unset the api dml status
    ben_epe_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_epe_shd.g_api_dml := false;   -- Unset the api dml status
    ben_epe_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_epe_shd.g_api_dml := false;   -- Unset the api dml status
    ben_epe_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_epe_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in ben_epe_shd.g_rec_type) is
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
Procedure post_update(p_rec in ben_epe_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
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
Procedure convert_defs(p_rec in out nocopy ben_epe_shd.g_rec_type) is
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
--  If (p_rec.enrt_typ_cycl_cd = hr_api.g_varchar2) then
--    p_rec.enrt_typ_cycl_cd :=
--    ben_epe_shd.g_old_rec.enrt_typ_cycl_cd;
--  End If;
  If (p_rec.enrt_cvg_strt_dt_cd = hr_api.g_varchar2) then
    p_rec.enrt_cvg_strt_dt_cd :=
    ben_epe_shd.g_old_rec.enrt_cvg_strt_dt_cd;
  End If;
--  If (p_rec.enrt_perd_end_dt = hr_api.g_date) then
--    p_rec.enrt_perd_end_dt :=
--    ben_epe_shd.g_old_rec.enrt_perd_end_dt;
--  End If;
--  If (p_rec.enrt_perd_strt_dt = hr_api.g_date) then
--    p_rec.enrt_perd_strt_dt :=
--    ben_epe_shd.g_old_rec.enrt_perd_strt_dt;
--  End If;
  If (p_rec.enrt_cvg_strt_dt_rl = hr_api.g_varchar2) then
    p_rec.enrt_cvg_strt_dt_rl :=
    ben_epe_shd.g_old_rec.enrt_cvg_strt_dt_rl;
  End If;
--  If (p_rec.rt_strt_dt = hr_api.g_date) then
--    p_rec.rt_strt_dt :=
--    ben_epe_shd.g_old_rec.rt_strt_dt;
--  End If;
--  If (p_rec.rt_strt_dt_rl = hr_api.g_varchar2) then
--    p_rec.rt_strt_dt_rl :=
--    ben_epe_shd.g_old_rec.rt_strt_dt_rl;
--  End If;
--  If (p_rec.rt_strt_dt_cd = hr_api.g_varchar2) then
--    p_rec.rt_strt_dt_cd :=
--    ben_epe_shd.g_old_rec.rt_strt_dt_cd;
--  End If;
  If (p_rec.ctfn_rqd_flag = hr_api.g_varchar2) then
    p_rec.ctfn_rqd_flag :=
    ben_epe_shd.g_old_rec.ctfn_rqd_flag;
  End If;
  If (p_rec.pil_elctbl_chc_popl_id = hr_api.g_number) then
    p_rec.pil_elctbl_chc_popl_id :=
    ben_epe_shd.g_old_rec.pil_elctbl_chc_popl_id;
  End If;
  If (p_rec.roll_crs_flag = hr_api.g_varchar2) then
    p_rec.roll_crs_flag :=
    ben_epe_shd.g_old_rec.roll_crs_flag;
  End If;
  If (p_rec.crntly_enrd_flag = hr_api.g_varchar2) then
    p_rec.crntly_enrd_flag :=
    ben_epe_shd.g_old_rec.crntly_enrd_flag;
  End If;
  If (p_rec.dflt_flag = hr_api.g_varchar2) then
    p_rec.dflt_flag :=
    ben_epe_shd.g_old_rec.dflt_flag;
  End If;
  If (p_rec.elctbl_flag = hr_api.g_varchar2) then
    p_rec.elctbl_flag :=
    ben_epe_shd.g_old_rec.elctbl_flag;
  End If;
  If (p_rec.mndtry_flag = hr_api.g_varchar2) then
    p_rec.mndtry_flag :=
    ben_epe_shd.g_old_rec.mndtry_flag;
  End If;
  If (p_rec.in_pndg_wkflow_flag = hr_api.g_varchar2) then
    p_rec.in_pndg_wkflow_flag :=
    ben_epe_shd.g_old_rec.in_pndg_wkflow_flag;
  End If;
--  If (p_rec.dflt_enrt_dt = hr_api.g_date) then
--    p_rec.dflt_enrt_dt :=
--    ben_epe_shd.g_old_rec.dflt_enrt_dt;
--  End If;
  If (p_rec.dpnt_cvg_strt_dt_cd = hr_api.g_varchar2) then
    p_rec.dpnt_cvg_strt_dt_cd :=
    ben_epe_shd.g_old_rec.dpnt_cvg_strt_dt_cd;
  End If;
  If (p_rec.dpnt_cvg_strt_dt_rl = hr_api.g_varchar2) then
    p_rec.dpnt_cvg_strt_dt_rl :=
    ben_epe_shd.g_old_rec.dpnt_cvg_strt_dt_rl;
  End If;
  If (p_rec.enrt_cvg_strt_dt = hr_api.g_date) then
    p_rec.enrt_cvg_strt_dt :=
    ben_epe_shd.g_old_rec.enrt_cvg_strt_dt;
  End If;
  If (p_rec.alws_dpnt_dsgn_flag = hr_api.g_varchar2) then
    p_rec.alws_dpnt_dsgn_flag :=
    ben_epe_shd.g_old_rec.alws_dpnt_dsgn_flag;
  End If;
  If (p_rec.dpnt_dsgn_cd = hr_api.g_varchar2) then
    p_rec.dpnt_dsgn_cd :=
    ben_epe_shd.g_old_rec.dpnt_dsgn_cd;
  End If;
  If (p_rec.ler_chg_dpnt_cvg_cd = hr_api.g_varchar2) then
    p_rec.ler_chg_dpnt_cvg_cd :=
    ben_epe_shd.g_old_rec.ler_chg_dpnt_cvg_cd;
  End If;
  If (p_rec.erlst_deenrt_dt = hr_api.g_date) then
    p_rec.erlst_deenrt_dt :=
    ben_epe_shd.g_old_rec.erlst_deenrt_dt;
  End If;
  If (p_rec.procg_end_dt = hr_api.g_date) then
    p_rec.procg_end_dt :=
    ben_epe_shd.g_old_rec.procg_end_dt;
  End If;
  If (p_rec.comp_lvl_cd = hr_api.g_varchar2) then
    p_rec.comp_lvl_cd :=
    ben_epe_shd.g_old_rec.comp_lvl_cd;
  End If;
  If (p_rec.pl_id = hr_api.g_number) then
    p_rec.pl_id :=
    ben_epe_shd.g_old_rec.pl_id;
  End If;
  If (p_rec.oipl_id = hr_api.g_number) then
    p_rec.oipl_id :=
    ben_epe_shd.g_old_rec.oipl_id;
  End If;
  If (p_rec.pgm_id = hr_api.g_number) then
    p_rec.pgm_id :=
    ben_epe_shd.g_old_rec.pgm_id;
  End If;
  If (p_rec.plip_id = hr_api.g_number) then
    p_rec.plip_id :=
    ben_epe_shd.g_old_rec.plip_id;
  End If;
  If (p_rec.ptip_id = hr_api.g_number) then
    p_rec.ptip_id :=
    ben_epe_shd.g_old_rec.ptip_id;
  End If;
  If (p_rec.pl_typ_id = hr_api.g_number) then
    p_rec.pl_typ_id :=
    ben_epe_shd.g_old_rec.pl_typ_id;
  End If;
  If (p_rec.oiplip_id = hr_api.g_number) then
    p_rec.oiplip_id :=
    ben_epe_shd.g_old_rec.oiplip_id;
  End If;
  If (p_rec.cmbn_ptip_id = hr_api.g_number) then
    p_rec.cmbn_ptip_id :=
    ben_epe_shd.g_old_rec.cmbn_ptip_id;
  End If;
  If (p_rec.cmbn_plip_id = hr_api.g_number) then
    p_rec.cmbn_plip_id :=
    ben_epe_shd.g_old_rec.cmbn_plip_id;
  End If;
  If (p_rec.cmbn_ptip_opt_id = hr_api.g_number) then
    p_rec.cmbn_ptip_opt_id :=
    ben_epe_shd.g_old_rec.cmbn_ptip_opt_id;
  End If;
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    ben_epe_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.spcl_rt_pl_id = hr_api.g_number) then
    p_rec.spcl_rt_pl_id :=
    ben_epe_shd.g_old_rec.spcl_rt_pl_id;
  End If;
  If (p_rec.spcl_rt_oipl_id = hr_api.g_number) then
    p_rec.spcl_rt_oipl_id :=
    ben_epe_shd.g_old_rec.spcl_rt_oipl_id;
  End If;
  If (p_rec.must_enrl_anthr_pl_id = hr_api.g_number) then
    p_rec.must_enrl_anthr_pl_id :=
    ben_epe_shd.g_old_rec.must_enrl_anthr_pl_id;
  End If;
  If (p_rec.int_elig_per_elctbl_chc_id = hr_api.g_number) then
    p_rec.int_elig_per_elctbl_chc_id :=
    ben_epe_shd.g_old_rec.int_elig_per_elctbl_chc_id;
  End If;
  If (p_rec.prtt_enrt_rslt_id = hr_api.g_number) then
    p_rec.prtt_enrt_rslt_id :=
    ben_epe_shd.g_old_rec.prtt_enrt_rslt_id;
  End If;
  If (p_rec.bnft_prvdr_pool_id = hr_api.g_number) then
    p_rec.bnft_prvdr_pool_id :=
    ben_epe_shd.g_old_rec.bnft_prvdr_pool_id;
  End If;
  If (p_rec.per_in_ler_id = hr_api.g_number) then
    p_rec.per_in_ler_id :=
    ben_epe_shd.g_old_rec.per_in_ler_id;
  End If;
  If (p_rec.yr_perd_id = hr_api.g_number) then
    p_rec.yr_perd_id :=
    ben_epe_shd.g_old_rec.yr_perd_id;
  End If;
  If (p_rec.auto_enrt_flag = hr_api.g_varchar2) then
    p_rec.auto_enrt_flag :=
    ben_epe_shd.g_old_rec.auto_enrt_flag;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_epe_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.pl_ordr_num= hr_api.g_number) then
    p_rec.pl_ordr_num:=
    ben_epe_shd.g_old_rec.pl_ordr_num;
  End If;
  If (p_rec.plip_ordr_num= hr_api.g_number) then
    p_rec.plip_ordr_num:=
    ben_epe_shd.g_old_rec.plip_ordr_num;
  End If;
  If (p_rec.ptip_ordr_num= hr_api.g_number) then
    p_rec.ptip_ordr_num:=
    ben_epe_shd.g_old_rec.ptip_ordr_num;
  End If;
  If (p_rec.oipl_ordr_num= hr_api.g_number) then
    p_rec.oipl_ordr_num:=
    ben_epe_shd.g_old_rec.oipl_ordr_num;
  End If;
  -- cwb
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    ben_epe_shd.g_old_rec.comments;
  End If;
  If (p_rec.elig_flag = hr_api.g_varchar2) then
    p_rec.elig_flag :=
    ben_epe_shd.g_old_rec.elig_flag;
  End If;
  If (p_rec.elig_ovrid_dt = hr_api.g_date) then
    p_rec.elig_ovrid_dt :=
    ben_epe_shd.g_old_rec.elig_ovrid_dt;
  End If;
  If (p_rec.elig_ovrid_person_id = hr_api.g_number) then
    p_rec.elig_ovrid_person_id :=
    ben_epe_shd.g_old_rec.elig_ovrid_person_id;
  End If;
  If (p_rec.inelig_rsn_cd = hr_api.g_varchar2) then
    p_rec.inelig_rsn_cd :=
    ben_epe_shd.g_old_rec.inelig_rsn_cd;
  End If;
  If (p_rec.mgr_ovrid_dt = hr_api.g_date) then
    p_rec.mgr_ovrid_dt :=
    ben_epe_shd.g_old_rec.mgr_ovrid_dt;
  End If;
  If (p_rec.mgr_ovrid_person_id = hr_api.g_number) then
    p_rec.mgr_ovrid_person_id :=
    ben_epe_shd.g_old_rec.mgr_ovrid_person_id;
  End If;
  If (p_rec.ws_mgr_id = hr_api.g_number) then
    p_rec.ws_mgr_id :=
    ben_epe_shd.g_old_rec.ws_mgr_id;
  End If;
  -- cwb
  If (p_rec.epe_attribute_category = hr_api.g_varchar2) then
    p_rec.epe_attribute_category :=
    ben_epe_shd.g_old_rec.epe_attribute_category;
  End If;
  If (p_rec.epe_attribute1 = hr_api.g_varchar2) then
    p_rec.epe_attribute1 :=
    ben_epe_shd.g_old_rec.epe_attribute1;
  End If;
  If (p_rec.epe_attribute2 = hr_api.g_varchar2) then
    p_rec.epe_attribute2 :=
    ben_epe_shd.g_old_rec.epe_attribute2;
  End If;
  If (p_rec.epe_attribute3 = hr_api.g_varchar2) then
    p_rec.epe_attribute3 :=
    ben_epe_shd.g_old_rec.epe_attribute3;
  End If;
  If (p_rec.epe_attribute4 = hr_api.g_varchar2) then
    p_rec.epe_attribute4 :=
    ben_epe_shd.g_old_rec.epe_attribute4;
  End If;
  If (p_rec.epe_attribute5 = hr_api.g_varchar2) then
    p_rec.epe_attribute5 :=
    ben_epe_shd.g_old_rec.epe_attribute5;
  End If;
  If (p_rec.epe_attribute6 = hr_api.g_varchar2) then
    p_rec.epe_attribute6 :=
    ben_epe_shd.g_old_rec.epe_attribute6;
  End If;
  If (p_rec.epe_attribute7 = hr_api.g_varchar2) then
    p_rec.epe_attribute7 :=
    ben_epe_shd.g_old_rec.epe_attribute7;
  End If;
  If (p_rec.epe_attribute8 = hr_api.g_varchar2) then
    p_rec.epe_attribute8 :=
    ben_epe_shd.g_old_rec.epe_attribute8;
  End If;
  If (p_rec.epe_attribute9 = hr_api.g_varchar2) then
    p_rec.epe_attribute9 :=
    ben_epe_shd.g_old_rec.epe_attribute9;
  End If;
  If (p_rec.epe_attribute10 = hr_api.g_varchar2) then
    p_rec.epe_attribute10 :=
    ben_epe_shd.g_old_rec.epe_attribute10;
  End If;
  If (p_rec.epe_attribute11 = hr_api.g_varchar2) then
    p_rec.epe_attribute11 :=
    ben_epe_shd.g_old_rec.epe_attribute11;
  End If;
  If (p_rec.epe_attribute12 = hr_api.g_varchar2) then
    p_rec.epe_attribute12 :=
    ben_epe_shd.g_old_rec.epe_attribute12;
  End If;
  If (p_rec.epe_attribute13 = hr_api.g_varchar2) then
    p_rec.epe_attribute13 :=
    ben_epe_shd.g_old_rec.epe_attribute13;
  End If;
  If (p_rec.epe_attribute14 = hr_api.g_varchar2) then
    p_rec.epe_attribute14 :=
    ben_epe_shd.g_old_rec.epe_attribute14;
  End If;
  If (p_rec.epe_attribute15 = hr_api.g_varchar2) then
    p_rec.epe_attribute15 :=
    ben_epe_shd.g_old_rec.epe_attribute15;
  End If;
  If (p_rec.epe_attribute16 = hr_api.g_varchar2) then
    p_rec.epe_attribute16 :=
    ben_epe_shd.g_old_rec.epe_attribute16;
  End If;
  If (p_rec.epe_attribute17 = hr_api.g_varchar2) then
    p_rec.epe_attribute17 :=
    ben_epe_shd.g_old_rec.epe_attribute17;
  End If;
  If (p_rec.epe_attribute18 = hr_api.g_varchar2) then
    p_rec.epe_attribute18 :=
    ben_epe_shd.g_old_rec.epe_attribute18;
  End If;
  If (p_rec.epe_attribute19 = hr_api.g_varchar2) then
    p_rec.epe_attribute19 :=
    ben_epe_shd.g_old_rec.epe_attribute19;
  End If;
  If (p_rec.epe_attribute20 = hr_api.g_varchar2) then
    p_rec.epe_attribute20 :=
    ben_epe_shd.g_old_rec.epe_attribute20;
  End If;
  If (p_rec.epe_attribute21 = hr_api.g_varchar2) then
    p_rec.epe_attribute21 :=
    ben_epe_shd.g_old_rec.epe_attribute21;
  End If;
  If (p_rec.epe_attribute22 = hr_api.g_varchar2) then
    p_rec.epe_attribute22 :=
    ben_epe_shd.g_old_rec.epe_attribute22;
  End If;
  If (p_rec.epe_attribute23 = hr_api.g_varchar2) then
    p_rec.epe_attribute23 :=
    ben_epe_shd.g_old_rec.epe_attribute23;
  End If;
  If (p_rec.epe_attribute24 = hr_api.g_varchar2) then
    p_rec.epe_attribute24 :=
    ben_epe_shd.g_old_rec.epe_attribute24;
  End If;
  If (p_rec.epe_attribute25 = hr_api.g_varchar2) then
    p_rec.epe_attribute25 :=
    ben_epe_shd.g_old_rec.epe_attribute25;
  End If;
  If (p_rec.epe_attribute26 = hr_api.g_varchar2) then
    p_rec.epe_attribute26 :=
    ben_epe_shd.g_old_rec.epe_attribute26;
  End If;
  If (p_rec.epe_attribute27 = hr_api.g_varchar2) then
    p_rec.epe_attribute27 :=
    ben_epe_shd.g_old_rec.epe_attribute27;
  End If;
  If (p_rec.epe_attribute28 = hr_api.g_varchar2) then
    p_rec.epe_attribute28 :=
    ben_epe_shd.g_old_rec.epe_attribute28;
  End If;
  If (p_rec.epe_attribute29 = hr_api.g_varchar2) then
    p_rec.epe_attribute29 :=
    ben_epe_shd.g_old_rec.epe_attribute29;
  End If;
  If (p_rec.epe_attribute30 = hr_api.g_varchar2) then
    p_rec.epe_attribute30 :=
    ben_epe_shd.g_old_rec.epe_attribute30;
  End If;
  If (p_rec.approval_status_cd = hr_api.g_varchar2) then
    p_rec.approval_status_cd :=
    ben_epe_shd.g_old_rec.approval_status_cd;
  End If;
  If (p_rec.fonm_cvg_strt_dt = hr_api.g_date) then
    p_rec.fonm_cvg_strt_dt :=
    ben_epe_shd.g_old_rec.fonm_cvg_strt_dt;
  End If;
  If (p_rec.cryfwd_elig_dpnt_cd = hr_api.g_varchar2) then
    p_rec.cryfwd_elig_dpnt_cd :=
    ben_epe_shd.g_old_rec.cryfwd_elig_dpnt_cd;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    ben_epe_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    ben_epe_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    ben_epe_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    ben_epe_shd.g_old_rec.program_update_date;
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
  p_effective_date               in date,
  p_rec        in out nocopy ben_epe_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ben_epe_shd.lck
	(
	p_rec.elig_per_elctbl_chc_id,
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
  ben_epe_bus.update_validate(p_rec,p_effective_date);
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
  post_update(p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date               in date,
  p_elig_per_elctbl_chc_id       in number,
--  p_enrt_typ_cycl_cd             in varchar2         default hr_api.g_varchar2,
  p_enrt_cvg_strt_dt_cd          in varchar2         default hr_api.g_varchar2,
--  p_enrt_perd_end_dt             in date             default hr_api.g_date,
--  p_enrt_perd_strt_dt            in date             default hr_api.g_date,
  p_enrt_cvg_strt_dt_rl          in varchar2         default hr_api.g_varchar2,
--  p_rt_strt_dt                   in date             default hr_api.g_date,
--  p_rt_strt_dt_rl                in varchar2         default hr_api.g_varchar2,
--  p_rt_strt_dt_cd                in varchar2         default hr_api.g_varchar2,
  p_ctfn_rqd_flag                in varchar2         default hr_api.g_varchar2,
  p_pil_elctbl_chc_popl_id       in number           default hr_api.g_number,
  p_roll_crs_flag                in varchar2         default hr_api.g_varchar2,
  p_crntly_enrd_flag             in varchar2         default hr_api.g_varchar2,
  p_dflt_flag                    in varchar2         default hr_api.g_varchar2,
  p_elctbl_flag                  in varchar2         default hr_api.g_varchar2,
  p_mndtry_flag                  in varchar2         default hr_api.g_varchar2,
  p_in_pndg_wkflow_flag          in varchar2         default hr_api.g_varchar2,
--  p_dflt_enrt_dt                 in date             default hr_api.g_date,
  p_dpnt_cvg_strt_dt_cd          in varchar2         default hr_api.g_varchar2,
  p_dpnt_cvg_strt_dt_rl          in varchar2         default hr_api.g_varchar2,
  p_enrt_cvg_strt_dt             in date             default hr_api.g_date,
  p_alws_dpnt_dsgn_flag          in varchar2         default hr_api.g_varchar2,
  p_dpnt_dsgn_cd                 in varchar2         default hr_api.g_varchar2,
  p_ler_chg_dpnt_cvg_cd          in varchar2         default hr_api.g_varchar2,
  p_erlst_deenrt_dt              in date             default hr_api.g_date,
  p_procg_end_dt                 in date             default hr_api.g_date,
  p_comp_lvl_cd                  in varchar2         default hr_api.g_varchar2,
  p_pl_id                        in number           default hr_api.g_number,
  p_oipl_id                      in number           default hr_api.g_number,
  p_pgm_id                       in number           default hr_api.g_number,
  p_plip_id                      in number           default hr_api.g_number,
  p_ptip_id                      in number           default hr_api.g_number,
  p_pl_typ_id                    in number           default hr_api.g_number,
  p_oiplip_id                    in number           default hr_api.g_number,
  p_cmbn_plip_id                 in number           default hr_api.g_number,
  p_cmbn_ptip_id                 in number           default hr_api.g_number,
  p_cmbn_ptip_opt_id             in number           default hr_api.g_number,
  p_assignment_id                in number           default hr_api.g_number,
  p_spcl_rt_pl_id                in number           default hr_api.g_number,
  p_spcl_rt_oipl_id              in number           default hr_api.g_number,
  p_must_enrl_anthr_pl_id        in number           default hr_api.g_number,
  p_int_elig_per_elctbl_chc_id in number         default hr_api.g_number,
  p_prtt_enrt_rslt_id            in number           default hr_api.g_number,
  p_bnft_prvdr_pool_id           in number           default hr_api.g_number,
  p_per_in_ler_id                in number           default hr_api.g_number,
  p_yr_perd_id                   in number           default hr_api.g_number,
  p_auto_enrt_flag               in varchar2         default hr_api.g_varchar2,
  p_business_group_id            in number           default hr_api.g_number,
  p_pl_ordr_num                  in number           default hr_api.g_number,
  p_plip_ordr_num                  in number           default hr_api.g_number,
  p_ptip_ordr_num                  in number           default hr_api.g_number,
  p_oipl_ordr_num                  in number           default hr_api.g_number,
  -- cwb
  p_comments                        in  varchar2       default hr_api.g_varchar2,
  p_elig_flag                       in  varchar2       default hr_api.g_varchar2,
  p_elig_ovrid_dt                   in  date           default hr_api.g_date,
  p_elig_ovrid_person_id            in  number         default hr_api.g_number,
  p_inelig_rsn_cd                   in  varchar2       default hr_api.g_varchar2,
  p_mgr_ovrid_dt                    in  date           default hr_api.g_date,
  p_mgr_ovrid_person_id             in  number         default hr_api.g_number,
  p_ws_mgr_id                       in  number         default hr_api.g_number,
  -- cwb
  p_epe_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_epe_attribute1               in varchar2         default hr_api.g_varchar2,
  p_epe_attribute2               in varchar2         default hr_api.g_varchar2,
  p_epe_attribute3               in varchar2         default hr_api.g_varchar2,
  p_epe_attribute4               in varchar2         default hr_api.g_varchar2,
  p_epe_attribute5               in varchar2         default hr_api.g_varchar2,
  p_epe_attribute6               in varchar2         default hr_api.g_varchar2,
  p_epe_attribute7               in varchar2         default hr_api.g_varchar2,
  p_epe_attribute8               in varchar2         default hr_api.g_varchar2,
  p_epe_attribute9               in varchar2         default hr_api.g_varchar2,
  p_epe_attribute10              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute11              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute12              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute13              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute14              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute15              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute16              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute17              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute18              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute19              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute20              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute21              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute22              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute23              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute24              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute25              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute26              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute27              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute28              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute29              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute30              in varchar2         default hr_api.g_varchar2,
  p_approval_status_cd              in varchar2         default hr_api.g_varchar2,
  p_fonm_cvg_strt_dt              in date            default hr_api.g_date,
  p_cryfwd_elig_dpnt_cd          in varchar2         default hr_api.g_varchar2,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_object_version_number        in out nocopy number
  ) is
--
  l_rec	  ben_epe_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_epe_shd.convert_args
  (
  p_elig_per_elctbl_chc_id,
--  p_enrt_typ_cycl_cd,
  p_enrt_cvg_strt_dt_cd,
--  p_enrt_perd_end_dt,
--  p_enrt_perd_strt_dt,
  p_enrt_cvg_strt_dt_rl,
--  p_rt_strt_dt,
--  p_rt_strt_dt_rl,
--  p_rt_strt_dt_cd,
  p_ctfn_rqd_flag,
  p_pil_elctbl_chc_popl_id,
  p_roll_crs_flag,
  p_crntly_enrd_flag,
  p_dflt_flag,
  p_elctbl_flag,
  p_mndtry_flag,
  p_in_pndg_wkflow_flag,
--  p_dflt_enrt_dt,
  p_dpnt_cvg_strt_dt_cd,
  p_dpnt_cvg_strt_dt_rl,
  p_enrt_cvg_strt_dt,
  p_alws_dpnt_dsgn_flag,
  p_dpnt_dsgn_cd,
  p_ler_chg_dpnt_cvg_cd,
  p_erlst_deenrt_dt,
  p_procg_end_dt,
  p_comp_lvl_cd,
  p_pl_id,
  p_oipl_id,
  p_pgm_id,
  p_plip_id,
  p_ptip_id,
  p_pl_typ_id,
  p_oiplip_id,
  p_cmbn_plip_id,
  p_cmbn_ptip_id,
  p_cmbn_ptip_opt_id,
  p_assignment_id,
  p_spcl_rt_pl_id,
  p_spcl_rt_oipl_id,
  p_must_enrl_anthr_pl_id,
  p_int_elig_per_elctbl_chc_id,
  p_prtt_enrt_rslt_id,
  p_bnft_prvdr_pool_id,
  p_per_in_ler_id,
  p_yr_perd_id,
  p_auto_enrt_flag,
  p_business_group_id,
  p_pl_ordr_num,
  p_plip_ordr_num,
  p_ptip_ordr_num,
  p_oipl_ordr_num,
  -- cwb
  p_comments,
  p_elig_flag,
  p_elig_ovrid_dt,
  p_elig_ovrid_person_id,
  p_inelig_rsn_cd,
  p_mgr_ovrid_dt,
  p_mgr_ovrid_person_id,
  p_ws_mgr_id,
  -- cwb
  p_epe_attribute_category,
  p_epe_attribute1,
  p_epe_attribute2,
  p_epe_attribute3,
  p_epe_attribute4,
  p_epe_attribute5,
  p_epe_attribute6,
  p_epe_attribute7,
  p_epe_attribute8,
  p_epe_attribute9,
  p_epe_attribute10,
  p_epe_attribute11,
  p_epe_attribute12,
  p_epe_attribute13,
  p_epe_attribute14,
  p_epe_attribute15,
  p_epe_attribute16,
  p_epe_attribute17,
  p_epe_attribute18,
  p_epe_attribute19,
  p_epe_attribute20,
  p_epe_attribute21,
  p_epe_attribute22,
  p_epe_attribute23,
  p_epe_attribute24,
  p_epe_attribute25,
  p_epe_attribute26,
  p_epe_attribute27,
  p_epe_attribute28,
  p_epe_attribute29,
  p_epe_attribute30,
  p_approval_status_cd,
  p_fonm_cvg_strt_dt,
  p_cryfwd_elig_dpnt_cd,
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
  upd(p_effective_date,l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_epe_upd;

/

--------------------------------------------------------
--  DDL for Package Body BEN_ECR_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ECR_UPD" as
/* $Header: beecrrhi.pkb 115.21 2002/12/27 20:59:56 pabodla ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ecr_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy ben_ecr_shd.g_rec_type) is
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
  ben_ecr_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_enrt_rt Row
  --
  update ben_enrt_rt
  set
  enrt_rt_id                   = p_rec.enrt_rt_id,
--  ordr_num		       = p_rec.ordr_num,
  acty_typ_cd                  = p_rec.acty_typ_cd,
  tx_typ_cd                    = p_rec.tx_typ_cd,
  ctfn_rqd_flag                = p_rec.ctfn_rqd_flag,
  dflt_flag                    = p_rec.dflt_flag,
  dflt_pndg_ctfn_flag          = p_rec.dflt_pndg_ctfn_flag,
  dsply_on_enrt_flag           = p_rec.dsply_on_enrt_flag,
  use_to_calc_net_flx_cr_flag  = p_rec.use_to_calc_net_flx_cr_flag,
  entr_val_at_enrt_flag        = p_rec.entr_val_at_enrt_flag,
  asn_on_enrt_flag             = p_rec.asn_on_enrt_flag,
  rl_crs_only_flag             = p_rec.rl_crs_only_flag,
  dflt_val                     = p_rec.dflt_val,
  ann_val                      = p_rec.ann_val,
  ann_mn_elcn_val              = p_rec.ann_mn_elcn_val,
  ann_mx_elcn_val              = p_rec.ann_mx_elcn_val,
  val                          = p_rec.val,
  nnmntry_uom                  = p_rec.nnmntry_uom,
  mx_elcn_val                  = p_rec.mx_elcn_val,
  mn_elcn_val                  = p_rec.mn_elcn_val,
  incrmt_elcn_val              = p_rec.incrmt_elcn_val,
  cmcd_acty_ref_perd_cd        = p_rec.cmcd_acty_ref_perd_cd,
  cmcd_mn_elcn_val             = p_rec.cmcd_mn_elcn_val,
  cmcd_mx_elcn_val             = p_rec.cmcd_mx_elcn_val,
  cmcd_val                     = p_rec.cmcd_val,
  cmcd_dflt_val                = p_rec.cmcd_dflt_val,
  rt_usg_cd                    = p_rec.rt_usg_cd,
  ann_dflt_val                 = p_rec.ann_dflt_val,
  bnft_rt_typ_cd               = p_rec.bnft_rt_typ_cd,
  rt_mlt_cd                    = p_rec.rt_mlt_cd,
  dsply_mn_elcn_val            = p_rec.dsply_mn_elcn_val,
  dsply_mx_elcn_val            = p_rec.dsply_mx_elcn_val,
  entr_ann_val_flag            = p_rec.entr_ann_val_flag,
  rt_strt_dt                   = p_rec.rt_strt_dt,
  rt_strt_dt_cd                = p_rec.rt_strt_dt_cd,
  rt_strt_dt_rl                = p_rec.rt_strt_dt_rl,
  rt_typ_cd                    = p_rec.rt_typ_cd,
  elig_per_elctbl_chc_id       = p_rec.elig_per_elctbl_chc_id,
  acty_base_rt_id              = p_rec.acty_base_rt_id,
  spcl_rt_enrt_rt_id           = p_rec.spcl_rt_enrt_rt_id,
  enrt_bnft_id                 = p_rec.enrt_bnft_id,
  prtt_rt_val_id               = p_rec.prtt_rt_val_id,
  decr_bnft_prvdr_pool_id      = p_rec.decr_bnft_prvdr_pool_id,
  cvg_amt_calc_mthd_id         = p_rec.cvg_amt_calc_mthd_id,
  actl_prem_id                 = p_rec.actl_prem_id,
  comp_lvl_fctr_id             = p_rec.comp_lvl_fctr_id,
  ptd_comp_lvl_fctr_id         = p_rec.ptd_comp_lvl_fctr_id,
  clm_comp_lvl_fctr_id         = p_rec.clm_comp_lvl_fctr_id,
  business_group_id            = p_rec.business_group_id,
   --cwb
  iss_val                      = p_rec.iss_val ,
  val_last_upd_date            = p_rec.val_last_upd_date ,
  val_last_upd_person_id       = p_rec.val_last_upd_person_id,
   --cwb
  pp_in_yr_used_num            = p_rec.pp_in_yr_used_num,
  ecr_attribute_category       = p_rec.ecr_attribute_category,
  ecr_attribute1               = p_rec.ecr_attribute1,
  ecr_attribute2               = p_rec.ecr_attribute2,
  ecr_attribute3               = p_rec.ecr_attribute3,
  ecr_attribute4               = p_rec.ecr_attribute4,
  ecr_attribute5               = p_rec.ecr_attribute5,
  ecr_attribute6               = p_rec.ecr_attribute6,
  ecr_attribute7               = p_rec.ecr_attribute7,
  ecr_attribute8               = p_rec.ecr_attribute8,
  ecr_attribute9               = p_rec.ecr_attribute9,
  ecr_attribute10              = p_rec.ecr_attribute10,
  ecr_attribute11              = p_rec.ecr_attribute11,
  ecr_attribute12              = p_rec.ecr_attribute12,
  ecr_attribute13              = p_rec.ecr_attribute13,
  ecr_attribute14              = p_rec.ecr_attribute14,
  ecr_attribute15              = p_rec.ecr_attribute15,
  ecr_attribute16              = p_rec.ecr_attribute16,
  ecr_attribute17              = p_rec.ecr_attribute17,
  ecr_attribute18              = p_rec.ecr_attribute18,
  ecr_attribute19              = p_rec.ecr_attribute19,
  ecr_attribute20              = p_rec.ecr_attribute20,
  ecr_attribute21              = p_rec.ecr_attribute21,
  ecr_attribute22              = p_rec.ecr_attribute22,
  ecr_attribute23              = p_rec.ecr_attribute23,
  ecr_attribute24              = p_rec.ecr_attribute24,
  ecr_attribute25              = p_rec.ecr_attribute25,
  ecr_attribute26              = p_rec.ecr_attribute26,
  ecr_attribute27              = p_rec.ecr_attribute27,
  ecr_attribute28              = p_rec.ecr_attribute28,
  ecr_attribute29              = p_rec.ecr_attribute29,
  ecr_attribute30              = p_rec.ecr_attribute30,
  last_update_login            = p_rec.last_update_login,
  created_by                   = p_rec.created_by,
  creation_date                = p_rec.creation_date,
  last_updated_by              = p_rec.last_updated_by,
  last_update_date             = p_rec.last_update_date,
  request_id                   = p_rec.request_id,
  program_application_id       = p_rec.program_application_id,
  program_id                   = p_rec.program_id,
  program_update_date          = p_rec.program_update_date,
  object_version_number        = p_rec.object_version_number
  where enrt_rt_id = p_rec.enrt_rt_id;
  --
  ben_ecr_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_ecr_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ecr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_ecr_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ecr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_ecr_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ecr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_ecr_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in ben_ecr_shd.g_rec_type) is
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
Procedure post_update(p_rec            in ben_ecr_shd.g_rec_type,
                      p_effective_date in date) is
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
Procedure convert_defs(p_rec in out nocopy ben_ecr_shd.g_rec_type) is
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
  If (p_rec.ordr_num = hr_api.g_number) then
          p_rec.ordr_num :=
          ben_abr_shd.g_old_rec.ordr_num;
  End If;
  If (p_rec.acty_typ_cd = hr_api.g_varchar2) then
    p_rec.acty_typ_cd :=
    ben_ecr_shd.g_old_rec.acty_typ_cd;
  End If;
  If (p_rec.tx_typ_cd = hr_api.g_varchar2) then
    p_rec.tx_typ_cd :=
    ben_ecr_shd.g_old_rec.tx_typ_cd;
  End If;
  If (p_rec.ctfn_rqd_flag = hr_api.g_varchar2) then
    p_rec.ctfn_rqd_flag :=
    ben_ecr_shd.g_old_rec.ctfn_rqd_flag;
  End If;
  If (p_rec.dflt_flag = hr_api.g_varchar2) then
    p_rec.dflt_flag :=
    ben_ecr_shd.g_old_rec.dflt_flag;
  End If;
  If (p_rec.dflt_pndg_ctfn_flag = hr_api.g_varchar2) then
    p_rec.dflt_pndg_ctfn_flag :=
    ben_ecr_shd.g_old_rec.dflt_pndg_ctfn_flag;
  End If;
  If (p_rec.dsply_on_enrt_flag = hr_api.g_varchar2) then
    p_rec.dsply_on_enrt_flag :=
    ben_ecr_shd.g_old_rec.dsply_on_enrt_flag;
  End If;
  If (p_rec.use_to_calc_net_flx_cr_flag = hr_api.g_varchar2) then
    p_rec.use_to_calc_net_flx_cr_flag :=
    ben_ecr_shd.g_old_rec.use_to_calc_net_flx_cr_flag;
  End If;
  If (p_rec.entr_val_at_enrt_flag = hr_api.g_varchar2) then
    p_rec.entr_val_at_enrt_flag :=
    ben_ecr_shd.g_old_rec.entr_val_at_enrt_flag;
  End If;
  If (p_rec.asn_on_enrt_flag = hr_api.g_varchar2) then
    p_rec.asn_on_enrt_flag :=
    ben_ecr_shd.g_old_rec.asn_on_enrt_flag;
  End If;
  If (p_rec.rl_crs_only_flag = hr_api.g_varchar2) then
    p_rec.rl_crs_only_flag :=
    ben_ecr_shd.g_old_rec.rl_crs_only_flag;
  End If;
  If (p_rec.dflt_val = hr_api.g_number) then
    p_rec.dflt_val :=
    ben_ecr_shd.g_old_rec.dflt_val;
  End If;
  If (p_rec.ann_val = hr_api.g_number) then
    p_rec.ann_val :=
    ben_ecr_shd.g_old_rec.ann_val;
  End If;
  If (p_rec.ann_mn_elcn_val = hr_api.g_number) then
    p_rec.ann_mn_elcn_val :=
    ben_ecr_shd.g_old_rec.ann_mn_elcn_val;
  End If;
  If (p_rec.ann_mx_elcn_val = hr_api.g_number) then
    p_rec.ann_mx_elcn_val :=
    ben_ecr_shd.g_old_rec.ann_mx_elcn_val;
  End If;
  If (p_rec.val = hr_api.g_number) then
    p_rec.val :=
    ben_ecr_shd.g_old_rec.val;
  End If;
  If (p_rec.nnmntry_uom = hr_api.g_varchar2) then
    p_rec.nnmntry_uom :=
    ben_ecr_shd.g_old_rec.nnmntry_uom;
  End If;
  If (p_rec.mx_elcn_val = hr_api.g_number) then
    p_rec.mx_elcn_val :=
    ben_ecr_shd.g_old_rec.mx_elcn_val;
  End If;
  If (p_rec.mn_elcn_val = hr_api.g_number) then
    p_rec.mn_elcn_val :=
    ben_ecr_shd.g_old_rec.mn_elcn_val;
  End If;
  If (p_rec.incrmt_elcn_val = hr_api.g_number) then
    p_rec.incrmt_elcn_val :=
    ben_ecr_shd.g_old_rec.incrmt_elcn_val;
  End If;
  If (p_rec.cmcd_acty_ref_perd_cd = hr_api.g_varchar2) then
    p_rec.cmcd_acty_ref_perd_cd :=
    ben_ecr_shd.g_old_rec.cmcd_acty_ref_perd_cd;
  End If;
  If (p_rec.cmcd_mn_elcn_val = hr_api.g_number) then
    p_rec.cmcd_mn_elcn_val :=
    ben_ecr_shd.g_old_rec.cmcd_mn_elcn_val;
  End If;
  If (p_rec.cmcd_mx_elcn_val = hr_api.g_number) then
    p_rec.cmcd_mx_elcn_val :=
    ben_ecr_shd.g_old_rec.cmcd_mx_elcn_val;
  End If;
  If (p_rec.cmcd_val = hr_api.g_number) then
    p_rec.cmcd_val :=
    ben_ecr_shd.g_old_rec.cmcd_val;
  End If;
  If (p_rec.cmcd_dflt_val = hr_api.g_number) then
    p_rec.cmcd_dflt_val :=
    ben_ecr_shd.g_old_rec.cmcd_dflt_val;
  End If;
  If (p_rec.elig_per_elctbl_chc_id = hr_api.g_number) then
    p_rec.elig_per_elctbl_chc_id :=
    ben_ecr_shd.g_old_rec.elig_per_elctbl_chc_id;
  End If;
  If (p_rec.acty_base_rt_id = hr_api.g_number) then
    p_rec.acty_base_rt_id :=
    ben_ecr_shd.g_old_rec.acty_base_rt_id;
  End If;
  If (p_rec.spcl_rt_enrt_rt_id = hr_api.g_number) then
    p_rec.spcl_rt_enrt_rt_id :=
    ben_ecr_shd.g_old_rec.spcl_rt_enrt_rt_id;
  End If;
  If (p_rec.enrt_bnft_id = hr_api.g_number) then
    p_rec.enrt_bnft_id :=
    ben_ecr_shd.g_old_rec.enrt_bnft_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_ecr_shd.g_old_rec.business_group_id;
  End If;
  --cwb
  If (p_rec.iss_val = hr_api.g_number) then
    p_rec.iss_val :=
    ben_ecr_shd.g_old_rec.iss_val;
  End If;
  If (p_rec.val_last_upd_person_id = hr_api.g_number) then
    p_rec.val_last_upd_person_id :=
    ben_ecr_shd.g_old_rec.val_last_upd_person_id;
  End If;
  If (p_rec.val_last_upd_date = hr_api.g_date) then
    p_rec.val_last_upd_date :=
    ben_ecr_shd.g_old_rec.val_last_upd_date;
  End If;
  --cwb
  If (p_rec.pp_in_yr_used_num = hr_api.g_number) then
    p_rec.pp_in_yr_used_num :=
    ben_ecr_shd.g_old_rec.pp_in_yr_used_num;
  End If;
  If (p_rec.ecr_attribute_category = hr_api.g_varchar2) then
    p_rec.ecr_attribute_category :=
    ben_ecr_shd.g_old_rec.ecr_attribute_category;
  End If;
  If (p_rec.ecr_attribute1 = hr_api.g_varchar2) then
    p_rec.ecr_attribute1 :=
    ben_ecr_shd.g_old_rec.ecr_attribute1;
  End If;
  If (p_rec.ecr_attribute2 = hr_api.g_varchar2) then
    p_rec.ecr_attribute2 :=
    ben_ecr_shd.g_old_rec.ecr_attribute2;
  End If;
  If (p_rec.ecr_attribute3 = hr_api.g_varchar2) then
    p_rec.ecr_attribute3 :=
    ben_ecr_shd.g_old_rec.ecr_attribute3;
  End If;
  If (p_rec.ecr_attribute4 = hr_api.g_varchar2) then
    p_rec.ecr_attribute4 :=
    ben_ecr_shd.g_old_rec.ecr_attribute4;
  End If;
  If (p_rec.ecr_attribute5 = hr_api.g_varchar2) then
    p_rec.ecr_attribute5 :=
    ben_ecr_shd.g_old_rec.ecr_attribute5;
  End If;
  If (p_rec.ecr_attribute6 = hr_api.g_varchar2) then
    p_rec.ecr_attribute6 :=
    ben_ecr_shd.g_old_rec.ecr_attribute6;
  End If;
  If (p_rec.ecr_attribute7 = hr_api.g_varchar2) then
    p_rec.ecr_attribute7 :=
    ben_ecr_shd.g_old_rec.ecr_attribute7;
  End If;
  If (p_rec.ecr_attribute8 = hr_api.g_varchar2) then
    p_rec.ecr_attribute8 :=
    ben_ecr_shd.g_old_rec.ecr_attribute8;
  End If;
  If (p_rec.ecr_attribute9 = hr_api.g_varchar2) then
    p_rec.ecr_attribute9 :=
    ben_ecr_shd.g_old_rec.ecr_attribute9;
  End If;
  If (p_rec.ecr_attribute10 = hr_api.g_varchar2) then
    p_rec.ecr_attribute10 :=
    ben_ecr_shd.g_old_rec.ecr_attribute10;
  End If;
  If (p_rec.ecr_attribute11 = hr_api.g_varchar2) then
    p_rec.ecr_attribute11 :=
    ben_ecr_shd.g_old_rec.ecr_attribute11;
  End If;
  If (p_rec.ecr_attribute12 = hr_api.g_varchar2) then
    p_rec.ecr_attribute12 :=
    ben_ecr_shd.g_old_rec.ecr_attribute12;
  End If;
  If (p_rec.ecr_attribute13 = hr_api.g_varchar2) then
    p_rec.ecr_attribute13 :=
    ben_ecr_shd.g_old_rec.ecr_attribute13;
  End If;
  If (p_rec.ecr_attribute14 = hr_api.g_varchar2) then
    p_rec.ecr_attribute14 :=
    ben_ecr_shd.g_old_rec.ecr_attribute14;
  End If;
  If (p_rec.ecr_attribute15 = hr_api.g_varchar2) then
    p_rec.ecr_attribute15 :=
    ben_ecr_shd.g_old_rec.ecr_attribute15;
  End If;
  If (p_rec.ecr_attribute16 = hr_api.g_varchar2) then
    p_rec.ecr_attribute16 :=
    ben_ecr_shd.g_old_rec.ecr_attribute16;
  End If;
  If (p_rec.ecr_attribute17 = hr_api.g_varchar2) then
    p_rec.ecr_attribute17 :=
    ben_ecr_shd.g_old_rec.ecr_attribute17;
  End If;
  If (p_rec.ecr_attribute18 = hr_api.g_varchar2) then
    p_rec.ecr_attribute18 :=
    ben_ecr_shd.g_old_rec.ecr_attribute18;
  End If;
  If (p_rec.ecr_attribute19 = hr_api.g_varchar2) then
    p_rec.ecr_attribute19 :=
    ben_ecr_shd.g_old_rec.ecr_attribute19;
  End If;
  If (p_rec.ecr_attribute20 = hr_api.g_varchar2) then
    p_rec.ecr_attribute20 :=
    ben_ecr_shd.g_old_rec.ecr_attribute20;
  End If;
  If (p_rec.ecr_attribute21 = hr_api.g_varchar2) then
    p_rec.ecr_attribute21 :=
    ben_ecr_shd.g_old_rec.ecr_attribute21;
  End If;
  If (p_rec.ecr_attribute22 = hr_api.g_varchar2) then
    p_rec.ecr_attribute22 :=
    ben_ecr_shd.g_old_rec.ecr_attribute22;
  End If;
  If (p_rec.ecr_attribute23 = hr_api.g_varchar2) then
    p_rec.ecr_attribute23 :=
    ben_ecr_shd.g_old_rec.ecr_attribute23;
  End If;
  If (p_rec.ecr_attribute24 = hr_api.g_varchar2) then
    p_rec.ecr_attribute24 :=
    ben_ecr_shd.g_old_rec.ecr_attribute24;
  End If;
  If (p_rec.ecr_attribute25 = hr_api.g_varchar2) then
    p_rec.ecr_attribute25 :=
    ben_ecr_shd.g_old_rec.ecr_attribute25;
  End If;
  If (p_rec.ecr_attribute26 = hr_api.g_varchar2) then
    p_rec.ecr_attribute26 :=
    ben_ecr_shd.g_old_rec.ecr_attribute26;
  End If;
  If (p_rec.ecr_attribute27 = hr_api.g_varchar2) then
    p_rec.ecr_attribute27 :=
    ben_ecr_shd.g_old_rec.ecr_attribute27;
  End If;
  If (p_rec.ecr_attribute28 = hr_api.g_varchar2) then
    p_rec.ecr_attribute28 :=
    ben_ecr_shd.g_old_rec.ecr_attribute28;
  End If;
  If (p_rec.ecr_attribute29 = hr_api.g_varchar2) then
    p_rec.ecr_attribute29 :=
    ben_ecr_shd.g_old_rec.ecr_attribute29;
  End If;
  If (p_rec.ecr_attribute30 = hr_api.g_varchar2) then
    p_rec.ecr_attribute30 :=
    ben_ecr_shd.g_old_rec.ecr_attribute30;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    ben_ecr_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    ben_ecr_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    ben_ecr_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    ben_ecr_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.prtt_rt_val_id = hr_api.g_number) then
    p_rec.prtt_rt_val_id :=
    ben_ecr_shd.g_old_rec.prtt_rt_val_id;
  End If;
  If (p_rec.rt_usg_cd = hr_api.g_varchar2) then
    p_rec.rt_usg_cd :=
    ben_ecr_shd.g_old_rec.rt_usg_cd;
  End If;
  If (p_rec.decr_bnft_prvdr_pool_id = hr_api.g_number) then
    p_rec.decr_bnft_prvdr_pool_id :=
    ben_ecr_shd.g_old_rec.decr_bnft_prvdr_pool_id;
  End If;
  If (p_rec.ann_dflt_val = hr_api.g_number) then
    p_rec.ann_dflt_val :=
    ben_ecr_shd.g_old_rec.ann_dflt_val;
  End If;
  If (p_rec.bnft_rt_typ_cd = hr_api.g_varchar2) then
    p_rec.bnft_rt_typ_cd :=
    ben_ecr_shd.g_old_rec.bnft_rt_typ_cd;
  End If;
  If (p_rec.rt_mlt_cd = hr_api.g_varchar2) then
    p_rec.rt_mlt_cd :=
    ben_ecr_shd.g_old_rec.rt_mlt_cd;
  End If;
  If (p_rec.dsply_mn_elcn_val = hr_api.g_number) then
    p_rec.dsply_mn_elcn_val :=
    ben_ecr_shd.g_old_rec.dsply_mn_elcn_val;
  End If;
  If (p_rec.dsply_mx_elcn_val = hr_api.g_number) then
    p_rec.dsply_mx_elcn_val :=
    ben_ecr_shd.g_old_rec.dsply_mx_elcn_val;
  End If;
  If (p_rec.entr_ann_val_flag = hr_api.g_varchar2) then
    p_rec.entr_ann_val_flag :=
    ben_ecr_shd.g_old_rec.entr_ann_val_flag;
  End If;
  If (p_rec.rt_strt_dt = hr_api.g_date) then
    p_rec.rt_strt_dt :=
    ben_ecr_shd.g_old_rec.rt_strt_dt;
  End If;
  If (p_rec.rt_strt_dt_cd = hr_api.g_varchar2) then
    p_rec.rt_strt_dt_cd :=
    ben_ecr_shd.g_old_rec.rt_strt_dt_cd;
  End If;
  If (p_rec.rt_strt_dt_rl = hr_api.g_number) then
    p_rec.rt_strt_dt_rl :=
    ben_ecr_shd.g_old_rec.rt_strt_dt_rl;
  End If;
  If (p_rec.rt_typ_cd = hr_api.g_varchar2) then
    p_rec.rt_typ_cd :=
    ben_ecr_shd.g_old_rec.rt_typ_cd;
  End If;
  If (p_rec.cvg_amt_calc_mthd_id = hr_api.g_number) then
    p_rec.cvg_amt_calc_mthd_id :=
    ben_ecr_shd.g_old_rec.cvg_amt_calc_mthd_id;
  End If;
  If (p_rec.actl_prem_id = hr_api.g_number) then
    p_rec.actl_prem_id :=
    ben_ecr_shd.g_old_rec.actl_prem_id;
  End If;
  If (p_rec.comp_lvl_fctr_id = hr_api.g_number) then
    p_rec.comp_lvl_fctr_id :=
    ben_ecr_shd.g_old_rec.comp_lvl_fctr_id;
  End If;
  If (p_rec.ptd_comp_lvl_fctr_id = hr_api.g_number) then
    p_rec.ptd_comp_lvl_fctr_id :=
    ben_ecr_shd.g_old_rec.ptd_comp_lvl_fctr_id;
  End If;
  If (p_rec.clm_comp_lvl_fctr_id = hr_api.g_number) then
    p_rec.clm_comp_lvl_fctr_id :=
    ben_ecr_shd.g_old_rec.clm_comp_lvl_fctr_id;
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
  (p_rec            in out nocopy ben_ecr_shd.g_rec_type,
   p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ben_ecr_shd.lck
	(p_rec.enrt_rt_id,
	 p_rec.object_version_number);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ben_ecr_bus.update_validate(p_rec,p_effective_date);
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
  post_update(p_rec,p_effective_date);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
    p_effective_date              in  date,
  	p_enrt_rt_id                  in  NUMBER,
  	p_ordr_num			 in number           default hr_api.g_number,
  	p_acty_typ_cd                 in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_tx_typ_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ctfn_rqd_flag               in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dflt_flag                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dflt_pndg_ctfn_flag         in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dsply_on_enrt_flag          in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_use_to_calc_net_flx_cr_flag in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_entr_val_at_enrt_flag       in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_asn_on_enrt_flag            in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rl_crs_only_flag            in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dflt_val                    in  NUMBER    DEFAULT hr_api.g_number,
  	p_ann_val                     in  NUMBER    DEFAULT hr_api.g_number,
  	p_ann_mn_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
  	p_ann_mx_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
  	p_val                         in  NUMBER    DEFAULT hr_api.g_number,
  	p_nnmntry_uom                 in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_mx_elcn_val                 in  NUMBER    DEFAULT hr_api.g_number,
  	p_mn_elcn_val                 in  NUMBER    DEFAULT hr_api.g_number,
  	p_incrmt_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_acty_ref_perd_cd       in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_cmcd_mn_elcn_val            in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_mx_elcn_val            in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_val                    in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_dflt_val               in  NUMBER    DEFAULT hr_api.g_number,
  	p_rt_usg_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ann_dflt_val                in  NUMBER    DEFAULT hr_api.g_number,
  	p_bnft_rt_typ_cd              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rt_mlt_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dsply_mn_elcn_val           in  NUMBER    DEFAULT hr_api.g_number,
  	p_dsply_mx_elcn_val           in  NUMBER    DEFAULT hr_api.g_number,
  	p_entr_ann_val_flag           in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rt_strt_dt                  in  DATE      DEFAULT hr_api.g_date,
  	p_rt_strt_dt_cd               in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rt_strt_dt_rl               in  NUMBER    DEFAULT hr_api.g_number,
  	p_rt_typ_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_elig_per_elctbl_chc_id      in  NUMBER    DEFAULT hr_api.g_number,
  	p_acty_base_rt_id             in  NUMBER    DEFAULT hr_api.g_number,
  	p_spcl_rt_enrt_rt_id          in  NUMBER    DEFAULT hr_api.g_number,
  	p_enrt_bnft_id                in  NUMBER    DEFAULT hr_api.g_number,
  	p_prtt_rt_val_id              in  NUMBER    DEFAULT hr_api.g_number,
  	p_decr_bnft_prvdr_pool_id     in  NUMBER    DEFAULT hr_api.g_number,
  	p_cvg_amt_calc_mthd_id        in  NUMBER    DEFAULT hr_api.g_number,
  	p_actl_prem_id                in  NUMBER    DEFAULT hr_api.g_number,
  	p_comp_lvl_fctr_id            in  NUMBER    DEFAULT hr_api.g_number,
  	p_ptd_comp_lvl_fctr_id        in  NUMBER    DEFAULT hr_api.g_number,
  	p_clm_comp_lvl_fctr_id        in  NUMBER    DEFAULT hr_api.g_number,
  	p_business_group_id           in  NUMBER    DEFAULT hr_api.g_number,
        --cwb
        p_iss_val                     in  number    DEFAULT hr_api.g_number,
        p_val_last_upd_date           in  date      DEFAULT hr_api.g_date,
        p_val_last_upd_person_id      in  number    DEFAULT hr_api.g_number,
        --cwb
        p_pp_in_yr_used_num           in  number    default hr_api.g_number,
  	p_ecr_attribute_category      in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute1              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute2              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute3              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute4              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute5              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute6              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute7              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute8              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute9              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute10             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute11             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute12             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute13             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute14             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute15             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute16             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute17             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute18             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute19             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute20             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute21             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute22             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute23             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute24             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute25             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute26             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute27             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute28             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute29             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute30             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_last_update_login           in  NUMBER    DEFAULT hr_api.g_number,
    p_created_by                  in  NUMBER    DEFAULT hr_api.g_number,
    p_creation_date               in  DATE      DEFAULT hr_api.g_date,
    p_last_updated_by             in  NUMBER    DEFAULT hr_api.g_number,
    p_last_update_date            in  DATE      DEFAULT hr_api.g_date,
    p_request_id                  in  NUMBER    DEFAULT hr_api.g_number,
    p_program_application_id      in  NUMBER    DEFAULT hr_api.g_number,
    p_program_id                  in  NUMBER    DEFAULT hr_api.g_number,
    p_program_update_date         in  DATE      DEFAULT hr_api.g_date,
    p_object_version_number       in out nocopy NUMBER
  ) is
--
  l_rec	  ben_ecr_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_ecr_shd.convert_args
  (
  p_enrt_rt_id,
  p_ordr_num,
  p_acty_typ_cd,
  p_tx_typ_cd,
  p_ctfn_rqd_flag,
  p_dflt_flag,
  p_dflt_pndg_ctfn_flag,
  p_dsply_on_enrt_flag,
  p_use_to_calc_net_flx_cr_flag,
  p_entr_val_at_enrt_flag,
  p_asn_on_enrt_flag,
  p_rl_crs_only_flag,
  p_dflt_val,
  p_ann_val,
  p_ann_mn_elcn_val,
  p_ann_mx_elcn_val,
  p_val,
  p_nnmntry_uom,
  p_mx_elcn_val,
  p_mn_elcn_val,
  p_incrmt_elcn_val,
  p_cmcd_acty_ref_perd_cd,
  p_cmcd_mn_elcn_val,
  p_cmcd_mx_elcn_val,
  p_cmcd_val,
  p_cmcd_dflt_val,
  p_rt_usg_cd,
  p_ann_dflt_val,
  p_bnft_rt_typ_cd,
  p_rt_mlt_cd,
  p_dsply_mn_elcn_val,
  p_dsply_mx_elcn_val,
  p_entr_ann_val_flag,
  p_rt_strt_dt,
  p_rt_strt_dt_cd,
  p_rt_strt_dt_rl,
  p_rt_typ_cd,
  p_elig_per_elctbl_chc_id,
  p_acty_base_rt_id,
  p_spcl_rt_enrt_rt_id,
  p_enrt_bnft_id,
  p_prtt_rt_val_id,
  p_decr_bnft_prvdr_pool_id,
  p_cvg_amt_calc_mthd_id,
  p_actl_prem_id,
  p_comp_lvl_fctr_id,
  p_ptd_comp_lvl_fctr_id,
  p_clm_comp_lvl_fctr_id,
  p_business_group_id,
  --cwb
  p_iss_val               ,
  p_val_last_upd_date     ,
  p_val_last_upd_person_id,
  --cwb
  p_pp_in_yr_used_num,
  p_ecr_attribute_category,
  p_ecr_attribute1,
  p_ecr_attribute2,
  p_ecr_attribute3,
  p_ecr_attribute4,
  p_ecr_attribute5,
  p_ecr_attribute6,
  p_ecr_attribute7,
  p_ecr_attribute8,
  p_ecr_attribute9,
  p_ecr_attribute10,
  p_ecr_attribute11,
  p_ecr_attribute12,
  p_ecr_attribute13,
  p_ecr_attribute14,
  p_ecr_attribute15,
  p_ecr_attribute16,
  p_ecr_attribute17,
  p_ecr_attribute18,
  p_ecr_attribute19,
  p_ecr_attribute20,
  p_ecr_attribute21,
  p_ecr_attribute22,
  p_ecr_attribute23,
  p_ecr_attribute24,
  p_ecr_attribute25,
  p_ecr_attribute26,
  p_ecr_attribute27,
  p_ecr_attribute28,
  p_ecr_attribute29,
  p_ecr_attribute30,
  p_last_update_login,
  p_created_by,
  p_creation_date,
  p_last_updated_by,
  p_last_update_date,
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
    upd(l_rec,p_effective_date);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_ecr_upd;

/

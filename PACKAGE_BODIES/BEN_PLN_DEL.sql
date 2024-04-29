--------------------------------------------------------
--  DDL for Package Body BEN_PLN_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLN_DEL" as
/* $Header: beplnrhi.pkb 120.8.12010000.2 2008/08/18 09:47:19 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_pln_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_delete_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic for the datetrack
--   delete modes: ZAP, DELETE, FUTURE_CHANGE and DELETE_NEXT_CHANGE. The
--   execution is as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) If the delete mode is DELETE_NEXT_CHANGE then delete where the
--      effective start date is equal to the validation start date.
--   3) If the delete mode is not DELETE_NEXT_CHANGE then delete
--      all rows for the entity where the effective start date is greater
--      than or equal to the validation start date.
--   4) To raise any errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_dml
        (p_rec                   in out nocopy ben_pln_shd.g_rec_type,
         p_effective_date        in     date,
         p_datetrack_mode        in     varchar2,
         p_validation_start_date in     date,
         p_validation_end_date   in     date) is
--
  l_proc        varchar2(72) := g_package||'dt_delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode = 'DELETE_NEXT_CHANGE') then
    hr_utility.set_location(l_proc, 10);
    ben_pln_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from ben_pl_f
    where       pl_id = p_rec.pl_id
    and   effective_start_date = p_validation_start_date;
    --
    ben_pln_shd.g_api_dml := false;   -- Unset the api dml status
  Else
    hr_utility.set_location(l_proc, 15);
    ben_pln_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from ben_pl_f
    where        pl_id = p_rec.pl_id
    and   effective_start_date >= p_validation_start_date;
    --
    ben_pln_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When Others Then
    ben_pln_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
        (p_rec                   in out nocopy ben_pln_shd.g_rec_type,
         p_effective_date        in     date,
         p_datetrack_mode        in     varchar2,
         p_validation_start_date in     date,
         p_validation_end_date   in     date) is
--
  l_proc        varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_delete_dml(p_rec                   => p_rec,
                p_effective_date        => p_effective_date,
                p_datetrack_mode        => p_datetrack_mode,
                p_validation_start_date => p_validation_start_date,
                p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_delete >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_delete process controls the execution of dml
--   for the datetrack modes: DELETE, FUTURE_CHANGE
--   and DELETE_NEXT_CHANGE only.
--
-- Prerequisites:
--   This is an internal procedure which is called from the pre_delete
--   procedure.
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
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_delete
        (p_rec                   in out nocopy ben_pln_shd.g_rec_type,
         p_effective_date        in     date,
         p_datetrack_mode        in     varchar2,
         p_validation_start_date in     date,
         p_validation_end_date   in     date) is
--
  l_proc        varchar2(72) := g_package||'dt_pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode <> 'ZAP') then
    --
    p_rec.effective_start_date := ben_pln_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = 'DELETE') then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    ben_pln_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date,
       p_base_key_value         => p_rec.pl_id,
       p_new_effective_end_date => p_rec.effective_end_date,
       p_validation_start_date  => p_validation_start_date,
       p_validation_end_date    => p_validation_end_date,
       p_object_version_number  => p_rec.object_version_number);
  Else
    p_rec.effective_start_date := null;
    p_rec.effective_end_date   := null;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End dt_pre_delete;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_delete_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete
        (p_rec                   in out nocopy ben_pln_shd.g_rec_type,
         p_effective_date        in     date,
         p_datetrack_mode        in     varchar2,
         p_validation_start_date in     date,
         p_validation_end_date   in     date) is
--
  l_proc        varchar2(72) := g_package||'pre_delete';
--
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_delete
    (p_rec                   => p_rec,
     p_effective_date        => p_effective_date,
     p_datetrack_mode        => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete
        (p_rec                   in ben_pln_shd.g_rec_type,
         p_effective_date        in date,
         p_datetrack_mode        in varchar2,
         p_validation_start_date in date,
         p_validation_end_date   in date) is
--
  l_proc        varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_delete.
  --
  -- Added for GSP validations
  pqh_gsp_ben_validations.pl_validations
  	(  p_pl_id			=> p_rec.pl_id
  	 , p_effective_date 		=> p_effective_date
  	 , p_dml_operation 		=> 'D'
  	 );

  begin
    --
    --
    ben_pln_rkd.after_delete
      (
      p_pl_id                          => p_rec.pl_id
     ,p_datetrack_mode                 => p_datetrack_mode
     ,p_validation_start_date          => p_validation_start_date
     ,p_validation_end_date            => p_validation_end_date
     ,p_effective_start_date           => p_rec.effective_start_date
     ,p_effective_end_date             => p_rec.effective_end_date
     ,p_effective_start_date_o         => ben_pln_shd.g_old_rec.effective_start_date
     ,p_effective_end_date_o           => ben_pln_shd.g_old_rec.effective_end_date
     ,p_name_o                        => ben_pln_shd.g_old_rec.name
     ,p_alws_qdro_flag_o              => ben_pln_shd.g_old_rec.alws_qdro_flag
     ,p_alws_qmcso_flag_o             => ben_pln_shd.g_old_rec.alws_qmcso_flag
     ,p_alws_reimbmts_flag_o          => ben_pln_shd.g_old_rec.alws_reimbmts_flag
     ,p_bnf_addl_instn_txt_alwd_fl_o  => ben_pln_shd.g_old_rec.bnf_addl_instn_txt_alwd_flag
     ,p_bnf_adrs_rqd_flag_o           => ben_pln_shd.g_old_rec.bnf_adrs_rqd_flag
     ,p_bnf_cntngt_bnfs_alwd_flag_o   => ben_pln_shd.g_old_rec.bnf_cntngt_bnfs_alwd_flag
     ,p_bnf_ctfn_rqd_flag_o           => ben_pln_shd.g_old_rec.bnf_ctfn_rqd_flag
     ,p_bnf_dob_rqd_flag_o            => ben_pln_shd.g_old_rec.bnf_dob_rqd_flag
     ,p_bnf_dsge_mnr_ttee_rqd_flag_o  => ben_pln_shd.g_old_rec.bnf_dsge_mnr_ttee_rqd_flag
     ,p_bnf_incrmt_amt_o              => ben_pln_shd.g_old_rec.bnf_incrmt_amt
     ,p_bnf_dflt_bnf_cd_o             => ben_pln_shd.g_old_rec.bnf_dflt_bnf_cd
     ,p_bnf_legv_id_rqd_flag_o        => ben_pln_shd.g_old_rec.bnf_legv_id_rqd_flag
     ,p_bnf_may_dsgt_org_flag_o       => ben_pln_shd.g_old_rec.bnf_may_dsgt_org_flag
     ,p_bnf_mn_dsgntbl_amt_o          => ben_pln_shd.g_old_rec.bnf_mn_dsgntbl_amt
     ,p_bnf_mn_dsgntbl_pct_val_o      => ben_pln_shd.g_old_rec.bnf_mn_dsgntbl_pct_val
     ,p_rqd_perd_enrt_nenrt_val_o     => ben_pln_shd.g_old_rec.rqd_perd_enrt_nenrt_val
     ,p_ordr_num_o                    => ben_pln_shd.g_old_rec.ordr_num
     ,p_bnf_pct_incrmt_val_o          => ben_pln_shd.g_old_rec.bnf_pct_incrmt_val
     ,p_bnf_pct_amt_alwd_cd_o         => ben_pln_shd.g_old_rec.bnf_pct_amt_alwd_cd
     ,p_bnf_qdro_rl_apls_flag_o       => ben_pln_shd.g_old_rec.bnf_qdro_rl_apls_flag
     ,p_dflt_to_asn_pndg_ctfn_cd_o    => ben_pln_shd.g_old_rec.dflt_to_asn_pndg_ctfn_cd
     ,p_dflt_to_asn_pndg_ctfn_rl_o    => ben_pln_shd.g_old_rec.dflt_to_asn_pndg_ctfn_rl
     ,p_drvbl_fctr_apls_rts_flag_o    => ben_pln_shd.g_old_rec.drvbl_fctr_apls_rts_flag
     ,p_drvbl_fctr_prtn_elig_flag_o   => ben_pln_shd.g_old_rec.drvbl_fctr_prtn_elig_flag
     ,p_dpnt_dsgn_cd_o                => ben_pln_shd.g_old_rec.dpnt_dsgn_cd
     ,p_elig_apls_flag_o              => ben_pln_shd.g_old_rec.elig_apls_flag
     ,p_invk_dcln_prtn_pl_flag_o      => ben_pln_shd.g_old_rec.invk_dcln_prtn_pl_flag
     ,p_invk_flx_cr_pl_flag_o         => ben_pln_shd.g_old_rec.invk_flx_cr_pl_flag
     ,p_imptd_incm_calc_cd_o          => ben_pln_shd.g_old_rec.imptd_incm_calc_cd
     ,p_drvbl_dpnt_elig_flag_o        => ben_pln_shd.g_old_rec.drvbl_dpnt_elig_flag
     ,p_trk_inelig_per_flag_o         => ben_pln_shd.g_old_rec.trk_inelig_per_flag
     ,p_pl_cd_o                       => ben_pln_shd.g_old_rec.pl_cd
     ,p_auto_enrt_mthd_rl_o           => ben_pln_shd.g_old_rec.auto_enrt_mthd_rl
     ,p_ivr_ident_o                   => ben_pln_shd.g_old_rec.ivr_ident
     ,p_url_ref_name_o                => ben_pln_shd.g_old_rec.url_ref_name
     ,p_cmpr_clms_to_cvg_or_bal_cd_o  => ben_pln_shd.g_old_rec.cmpr_clms_to_cvg_or_bal_cd
     ,p_cobra_pymt_due_dy_num_o       => ben_pln_shd.g_old_rec.cobra_pymt_due_dy_num
     ,p_dpnt_cvd_by_othr_apls_flag_o  => ben_pln_shd.g_old_rec.dpnt_cvd_by_othr_apls_flag
     ,p_enrt_mthd_cd_o                => ben_pln_shd.g_old_rec.enrt_mthd_cd
     ,p_enrt_cd_o                     => ben_pln_shd.g_old_rec.enrt_cd
     ,p_enrt_cvg_strt_dt_cd_o         => ben_pln_shd.g_old_rec.enrt_cvg_strt_dt_cd
     ,p_enrt_cvg_end_dt_cd_o          => ben_pln_shd.g_old_rec.enrt_cvg_end_dt_cd
     ,p_frfs_aply_flag_o              => ben_pln_shd.g_old_rec.frfs_aply_flag
     ,p_hc_pl_subj_hcfa_aprvl_flag_o  => ben_pln_shd.g_old_rec.hc_pl_subj_hcfa_aprvl_flag
     ,p_hghly_cmpd_rl_apls_flag_o     => ben_pln_shd.g_old_rec.hghly_cmpd_rl_apls_flag
     ,p_incptn_dt_o                   => ben_pln_shd.g_old_rec.incptn_dt
     ,p_mn_cvg_rl_o                   => ben_pln_shd.g_old_rec.mn_cvg_rl
     ,p_mn_cvg_rqd_amt_o              => ben_pln_shd.g_old_rec.mn_cvg_rqd_amt
     ,p_mn_opts_rqd_num_o             => ben_pln_shd.g_old_rec.mn_opts_rqd_num
     ,p_mx_cvg_alwd_amt_o             => ben_pln_shd.g_old_rec.mx_cvg_alwd_amt
     ,p_mx_cvg_rl_o                   => ben_pln_shd.g_old_rec.mx_cvg_rl
     ,p_mx_opts_alwd_num_o            => ben_pln_shd.g_old_rec.mx_opts_alwd_num
     ,p_mx_cvg_wcfn_mlt_num_o         => ben_pln_shd.g_old_rec.mx_cvg_wcfn_mlt_num
     ,p_mx_cvg_wcfn_amt_o             => ben_pln_shd.g_old_rec.mx_cvg_wcfn_amt
     ,p_mx_cvg_incr_alwd_amt_o        => ben_pln_shd.g_old_rec.mx_cvg_incr_alwd_amt
     ,p_mx_cvg_incr_wcf_alwd_amt_o    => ben_pln_shd.g_old_rec.mx_cvg_incr_wcf_alwd_amt
     ,p_mx_cvg_mlt_incr_num_o         => ben_pln_shd.g_old_rec.mx_cvg_mlt_incr_num
     ,p_mx_cvg_mlt_incr_wcf_num_o     => ben_pln_shd.g_old_rec.mx_cvg_mlt_incr_wcf_num
     ,p_mx_wtg_dt_to_use_cd_o         => ben_pln_shd.g_old_rec.mx_wtg_dt_to_use_cd
     ,p_mx_wtg_dt_to_use_rl_o         => ben_pln_shd.g_old_rec.mx_wtg_dt_to_use_rl
     ,p_mx_wtg_perd_prte_uom_o        => ben_pln_shd.g_old_rec.mx_wtg_perd_prte_uom
     ,p_mx_wtg_perd_prte_val_o        => ben_pln_shd.g_old_rec.mx_wtg_perd_prte_val
     ,p_mx_wtg_perd_rl_o              => ben_pln_shd.g_old_rec.mx_wtg_perd_rl
     ,p_nip_dflt_enrt_cd_o            => ben_pln_shd.g_old_rec.nip_dflt_enrt_cd
     ,p_nip_dflt_enrt_det_rl_o        => ben_pln_shd.g_old_rec.nip_dflt_enrt_det_rl
     ,p_dpnt_adrs_rqd_flag_o          => ben_pln_shd.g_old_rec.dpnt_adrs_rqd_flag
     ,p_dpnt_cvg_end_dt_cd_o          => ben_pln_shd.g_old_rec.dpnt_cvg_end_dt_cd
     ,p_dpnt_cvg_end_dt_rl_o          => ben_pln_shd.g_old_rec.dpnt_cvg_end_dt_rl
     ,p_dpnt_cvg_strt_dt_cd_o         => ben_pln_shd.g_old_rec.dpnt_cvg_strt_dt_cd
     ,p_dpnt_cvg_strt_dt_rl_o         => ben_pln_shd.g_old_rec.dpnt_cvg_strt_dt_rl
     ,p_dpnt_dob_rqd_flag_o           => ben_pln_shd.g_old_rec.dpnt_dob_rqd_flag
     ,p_dpnt_leg_id_rqd_flag_o        => ben_pln_shd.g_old_rec.dpnt_leg_id_rqd_flag
     ,p_dpnt_no_ctfn_rqd_flag_o       => ben_pln_shd.g_old_rec.dpnt_no_ctfn_rqd_flag
     ,p_no_mn_cvg_amt_apls_flag_o     => ben_pln_shd.g_old_rec.no_mn_cvg_amt_apls_flag
     ,p_no_mn_cvg_incr_apls_flag_o    => ben_pln_shd.g_old_rec.no_mn_cvg_incr_apls_flag
     ,p_no_mn_opts_num_apls_flag_o    => ben_pln_shd.g_old_rec.no_mn_opts_num_apls_flag
     ,p_no_mx_cvg_amt_apls_flag_o     => ben_pln_shd.g_old_rec.no_mx_cvg_amt_apls_flag
     ,p_no_mx_cvg_incr_apls_flag_o    => ben_pln_shd.g_old_rec.no_mx_cvg_incr_apls_flag
     ,p_no_mx_opts_num_apls_flag_o    => ben_pln_shd.g_old_rec.no_mx_opts_num_apls_flag
     ,p_nip_pl_uom_o                  => ben_pln_shd.g_old_rec.nip_pl_uom
     ,p_rqd_perd_enrt_nenrt_uom_o     => ben_pln_shd.g_old_rec.rqd_perd_enrt_nenrt_uom
     ,p_nip_acty_ref_perd_cd_o        => ben_pln_shd.g_old_rec.nip_acty_ref_perd_cd
     ,p_nip_enrt_info_rt_freq_cd_o    => ben_pln_shd.g_old_rec.nip_enrt_info_rt_freq_cd
     ,p_per_cvrd_cd_o                 => ben_pln_shd.g_old_rec.per_cvrd_cd
     ,p_enrt_cvg_end_dt_rl_o          => ben_pln_shd.g_old_rec.enrt_cvg_end_dt_rl
     ,p_postelcn_edit_rl_o            => ben_pln_shd.g_old_rec.postelcn_edit_rl
     ,p_enrt_cvg_strt_dt_rl_o         => ben_pln_shd.g_old_rec.enrt_cvg_strt_dt_rl
     ,p_prort_prtl_yr_cvg_rstrn_cd_o  => ben_pln_shd.g_old_rec.prort_prtl_yr_cvg_rstrn_cd
     ,p_prort_prtl_yr_cvg_rstrn_rl_o  => ben_pln_shd.g_old_rec.prort_prtl_yr_cvg_rstrn_rl
     ,p_prtn_elig_ovrid_alwd_flag_o   => ben_pln_shd.g_old_rec.prtn_elig_ovrid_alwd_flag
     ,p_svgs_pl_flag_o                => ben_pln_shd.g_old_rec.svgs_pl_flag
     ,p_subj_to_imptd_incm_typ_cd_o   => ben_pln_shd.g_old_rec.subj_to_imptd_incm_typ_cd
     ,p_use_all_asnts_elig_flag_o     => ben_pln_shd.g_old_rec.use_all_asnts_elig_flag
     ,p_use_all_asnts_for_rt_flag_o   => ben_pln_shd.g_old_rec.use_all_asnts_for_rt_flag
     ,p_vstg_apls_flag_o              => ben_pln_shd.g_old_rec.vstg_apls_flag
     ,p_wvbl_flag_o                   => ben_pln_shd.g_old_rec.wvbl_flag
     ,p_hc_svc_typ_cd_o               => ben_pln_shd.g_old_rec.hc_svc_typ_cd
     ,p_pl_stat_cd_o                  => ben_pln_shd.g_old_rec.pl_stat_cd
     ,p_prmry_fndg_mthd_cd_o          => ben_pln_shd.g_old_rec.prmry_fndg_mthd_cd
     ,p_rt_end_dt_cd_o                => ben_pln_shd.g_old_rec.rt_end_dt_cd
     ,p_rt_end_dt_rl_o                => ben_pln_shd.g_old_rec.rt_end_dt_rl
     ,p_rt_strt_dt_rl_o               => ben_pln_shd.g_old_rec.rt_strt_dt_rl
     ,p_rt_strt_dt_cd_o               => ben_pln_shd.g_old_rec.rt_strt_dt_cd
     ,p_bnf_dsgn_cd_o                 => ben_pln_shd.g_old_rec.bnf_dsgn_cd
     ,p_pl_typ_id_o                   => ben_pln_shd.g_old_rec.pl_typ_id
     ,p_business_group_id_o           => ben_pln_shd.g_old_rec.business_group_id
     ,p_enrt_pl_opt_flag_o            => ben_pln_shd.g_old_rec.enrt_pl_opt_flag
     ,p_bnft_prvdr_pool_id_o          => ben_pln_shd.g_old_rec.bnft_prvdr_pool_id
     ,p_MAY_ENRL_PL_N_OIPL_FLAG_o     => ben_pln_shd.g_old_rec.MAY_ENRL_PL_N_OIPL_FLAG
     ,p_ENRT_RL_o                     => ben_pln_shd.g_old_rec.ENRT_RL
     ,p_rqd_perd_enrt_nenrt_rl_o      => ben_pln_shd.g_old_rec.rqd_perd_enrt_nenrt_rl
     ,p_ALWS_UNRSTRCTD_ENRT_FLAG_o    => ben_pln_shd.g_old_rec.ALWS_UNRSTRCTD_ENRT_FLAG
     ,p_BNFT_OR_OPTION_RSTRCTN_CD_o   => ben_pln_shd.g_old_rec.BNFT_OR_OPTION_RSTRCTN_CD
     ,p_CVG_INCR_R_DECR_ONLY_CD_o     => ben_pln_shd.g_old_rec.CVG_INCR_R_DECR_ONLY_CD
     ,p_unsspnd_enrt_cd_o             => ben_pln_shd.g_old_rec.unsspnd_enrt_cd
     ,p_pln_attribute_category_o      => ben_pln_shd.g_old_rec.pln_attribute_category
     ,p_pln_attribute1_o              => ben_pln_shd.g_old_rec.pln_attribute1
     ,p_pln_attribute2_o              => ben_pln_shd.g_old_rec.pln_attribute2
     ,p_pln_attribute3_o              => ben_pln_shd.g_old_rec.pln_attribute3
     ,p_pln_attribute4_o              => ben_pln_shd.g_old_rec.pln_attribute4
     ,p_pln_attribute5_o              => ben_pln_shd.g_old_rec.pln_attribute5
     ,p_pln_attribute6_o              => ben_pln_shd.g_old_rec.pln_attribute6
     ,p_pln_attribute7_o              => ben_pln_shd.g_old_rec.pln_attribute7
     ,p_pln_attribute8_o              => ben_pln_shd.g_old_rec.pln_attribute8
     ,p_pln_attribute9_o              => ben_pln_shd.g_old_rec.pln_attribute9
     ,p_pln_attribute10_o             => ben_pln_shd.g_old_rec.pln_attribute10
     ,p_pln_attribute11_o             => ben_pln_shd.g_old_rec.pln_attribute11
     ,p_pln_attribute12_o             => ben_pln_shd.g_old_rec.pln_attribute12
     ,p_pln_attribute13_o             => ben_pln_shd.g_old_rec.pln_attribute13
     ,p_pln_attribute14_o             => ben_pln_shd.g_old_rec.pln_attribute14
     ,p_pln_attribute15_o             => ben_pln_shd.g_old_rec.pln_attribute15
     ,p_pln_attribute16_o             => ben_pln_shd.g_old_rec.pln_attribute16
     ,p_pln_attribute17_o             => ben_pln_shd.g_old_rec.pln_attribute17
     ,p_pln_attribute18_o             => ben_pln_shd.g_old_rec.pln_attribute18
     ,p_pln_attribute19_o             => ben_pln_shd.g_old_rec.pln_attribute19
     ,p_pln_attribute20_o             => ben_pln_shd.g_old_rec.pln_attribute20
     ,p_pln_attribute21_o             => ben_pln_shd.g_old_rec.pln_attribute21
     ,p_pln_attribute22_o             => ben_pln_shd.g_old_rec.pln_attribute22
     ,p_pln_attribute23_o             => ben_pln_shd.g_old_rec.pln_attribute23
     ,p_pln_attribute24_o             => ben_pln_shd.g_old_rec.pln_attribute24
     ,p_pln_attribute25_o             => ben_pln_shd.g_old_rec.pln_attribute25
     ,p_pln_attribute26_o             => ben_pln_shd.g_old_rec.pln_attribute26
     ,p_pln_attribute27_o             => ben_pln_shd.g_old_rec.pln_attribute27
     ,p_pln_attribute28_o             => ben_pln_shd.g_old_rec.pln_attribute28
     ,p_pln_attribute29_o             => ben_pln_shd.g_old_rec.pln_attribute29
     ,p_pln_attribute30_o             => ben_pln_shd.g_old_rec.pln_attribute30
     ,p_susp_if_ctfn_not_prvd_flag_o =>  ben_pln_shd.g_old_rec.susp_if_ctfn_not_prvd_flag
     ,p_ctfn_determine_cd_o          =>  ben_pln_shd.g_old_rec.ctfn_determine_cd
     ,p_susp_if_dpnt_ssn_nt_prv_cd_o => ben_pln_shd.g_old_rec.susp_if_dpnt_ssn_nt_prv_cd
     ,p_susp_if_dpnt_dob_nt_prv_cd_o => ben_pln_shd.g_old_rec.susp_if_dpnt_dob_nt_prv_cd
     ,p_susp_if_dpnt_adr_nt_prv_cd_o => ben_pln_shd.g_old_rec.susp_if_dpnt_adr_nt_prv_cd
     ,p_susp_if_ctfn_not_dpnt_flag_o => ben_pln_shd.g_old_rec.susp_if_ctfn_not_dpnt_flag
     ,p_susp_if_bnf_ssn_nt_prv_cd_o  => ben_pln_shd.g_old_rec.susp_if_bnf_ssn_nt_prv_cd
     ,p_susp_if_bnf_dob_nt_prv_cd_o  => ben_pln_shd.g_old_rec.susp_if_bnf_dob_nt_prv_cd
     ,p_susp_if_bnf_adr_nt_prv_cd_o  => ben_pln_shd.g_old_rec.susp_if_bnf_adr_nt_prv_cd
     ,p_susp_if_ctfn_not_bnf_flag_o  => ben_pln_shd.g_old_rec.susp_if_ctfn_not_bnf_flag
     ,p_dpnt_ctfn_determine_cd_o     => ben_pln_shd.g_old_rec.dpnt_ctfn_determine_cd
     ,p_bnf_ctfn_determine_cd_o      => ben_pln_shd.g_old_rec.bnf_ctfn_determine_cd
     ,p_object_version_number_o       => ben_pln_shd.g_old_rec.object_version_number
     ,p_actl_prem_id_o                => ben_pln_shd.g_old_rec.actl_prem_id
     ,p_vrfy_fmly_mmbr_cd_o           => ben_pln_shd.g_old_rec.vrfy_fmly_mmbr_cd
     ,p_vrfy_fmly_mmbr_rl_o           => ben_pln_shd.g_old_rec.vrfy_fmly_mmbr_rl
     ,p_alws_tmpry_id_crd_flag_o      => ben_pln_shd.g_old_rec.alws_tmpry_id_crd_flag
     ,p_nip_dflt_flag_o               => ben_pln_shd.g_old_rec.nip_dflt_flag
     ,p_frfs_distr_mthd_cd_o          =>  ben_pln_shd.g_old_rec.frfs_distr_mthd_cd
     ,p_frfs_distr_mthd_rl_o          =>  ben_pln_shd.g_old_rec.frfs_distr_mthd_rl
     ,p_frfs_cntr_det_cd_o            =>  ben_pln_shd.g_old_rec.frfs_cntr_det_cd
     ,p_frfs_distr_det_cd_o           =>  ben_pln_shd.g_old_rec.frfs_distr_det_cd
     ,p_cost_alloc_keyflex_1_id_o     =>  ben_pln_shd.g_old_rec.cost_alloc_keyflex_1_id
     ,p_cost_alloc_keyflex_2_id_o     =>  ben_pln_shd.g_old_rec.cost_alloc_keyflex_2_id
     ,p_post_to_gl_flag_o             =>  ben_pln_shd.g_old_rec.post_to_gl_flag
     ,p_frfs_val_det_cd_o             =>  ben_pln_shd.g_old_rec.frfs_val_det_cd
     ,p_frfs_mx_cryfwd_val_o          =>  ben_pln_shd.g_old_rec.frfs_mx_cryfwd_val
     ,p_frfs_portion_det_cd_o         =>  ben_pln_shd.g_old_rec.frfs_portion_det_cd
     ,p_bndry_perd_cd_o               =>  ben_pln_shd.g_old_rec.bndry_perd_cd
     ,p_short_name_o                  =>  ben_pln_shd.g_old_rec.short_name
     ,p_short_code_o                  =>  ben_pln_shd.g_old_rec.short_code
     ,p_legislation_code_o            =>  ben_pln_shd.g_old_rec.legislation_code
     ,p_legislation_subgroup_o        =>  ben_pln_shd.g_old_rec.legislation_subgroup
     ,p_group_pl_id_o                 =>  ben_pln_shd.g_old_rec.group_pl_id
     ,p_mapping_table_name_o          =>  ben_pln_shd.g_old_rec.mapping_table_name
     ,p_mapping_table_pk_id_o         =>  ben_pln_shd.g_old_rec.mapping_table_pk_id
     ,p_function_code_o               =>  ben_pln_shd.g_old_rec.function_code
     ,p_pl_yr_not_applcbl_flag_o      =>  ben_pln_shd.g_old_rec.pl_yr_not_applcbl_flag
     ,p_use_csd_rsd_prccng_cd_o       =>  ben_pln_shd.g_old_rec.use_csd_rsd_prccng_cd
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_pl_f'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  -- End of API User Hook for post_delete.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec                 in out nocopy  ben_pln_shd.g_rec_type,
  p_effective_date      in      date,
  p_datetrack_mode      in      varchar2
  ) is
--
  l_proc                        varchar2(72) := g_package||'del';
  l_validation_start_date       date;
  l_validation_end_date         date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack delete mode is valid
  --
  dt_api.validate_dt_del_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to delete.
  --
  ben_pln_shd.lck
        (p_effective_date        => p_effective_date,
         p_datetrack_mode        => p_datetrack_mode,
         p_pl_id         => p_rec.pl_id,
         p_object_version_number => p_rec.object_version_number,
         p_validation_start_date => l_validation_start_date,
         p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting delete validate operation
  --
  ben_pln_bus.delete_validate
        (p_rec                   => p_rec,
         p_effective_date        => p_effective_date,
         p_datetrack_mode        => p_datetrack_mode,
         p_validation_start_date => l_validation_start_date,
         p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete
        (p_rec                   => p_rec,
         p_effective_date        => p_effective_date,
         p_datetrack_mode        => p_datetrack_mode,
         p_validation_start_date => l_validation_start_date,
         p_validation_end_date   => l_validation_end_date);
  --
  -- Delete the row.
  --
  delete_dml
        (p_rec                   => p_rec,
         p_effective_date        => p_effective_date,
         p_datetrack_mode        => p_datetrack_mode,
         p_validation_start_date => l_validation_start_date,
         p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting post-delete operation
  --
  post_delete
        (p_rec                   => p_rec,
         p_effective_date        => p_effective_date,
         p_datetrack_mode        => p_datetrack_mode,
         p_validation_start_date => l_validation_start_date,
         p_validation_end_date   => l_validation_end_date);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_pl_id         in     number,
  p_effective_start_date     out nocopy date,
  p_effective_end_date       out nocopy date,
  p_object_version_number in out nocopy number,
  p_effective_date        in     date,
  p_datetrack_mode        in     varchar2
  ) is
--
  l_rec         ben_pln_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.pl_id           := p_pl_id;
  l_rec.object_version_number   := p_object_version_number;
  --
  -- Having converted the arguments into the ben_pln_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_effective_date, p_datetrack_mode);
  --
  -- Set the out arguments
  --
  p_object_version_number := l_rec.object_version_number;
  p_effective_start_date  := l_rec.effective_start_date;
  p_effective_end_date    := l_rec.effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_pln_del;

/

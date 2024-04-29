--------------------------------------------------------
--  DDL for Package Body BEN_PLN_UPD2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLN_UPD2" as
/* $Header: beplnrhi.pkb 120.8.12010000.2 2008/08/18 09:47:19 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_pln_upd2.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure convert_defs(p_rec in out nocopy ben_pln_shd.g_rec_type) is
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
  If (p_rec.pl_typ_id = hr_api.g_number) then
    p_rec.pl_typ_id :=
    ben_pln_shd.g_old_rec.pl_typ_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_pln_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    ben_pln_shd.g_old_rec.name;
  End If;
  If (p_rec.alws_qdro_flag = hr_api.g_varchar2) then
    p_rec.alws_qdro_flag :=
    ben_pln_shd.g_old_rec.alws_qdro_flag;
  End If;
  If (p_rec.alws_qmcso_flag = hr_api.g_varchar2) then
    p_rec.alws_qmcso_flag :=
    ben_pln_shd.g_old_rec.alws_qmcso_flag;
  End If;
  If (p_rec.bnf_addl_instn_txt_alwd_flag = hr_api.g_varchar2) then
    p_rec.bnf_addl_instn_txt_alwd_flag :=
    ben_pln_shd.g_old_rec.bnf_addl_instn_txt_alwd_flag;
  End If;
  If (p_rec.bnf_adrs_rqd_flag = hr_api.g_varchar2) then
    p_rec.bnf_adrs_rqd_flag :=
    ben_pln_shd.g_old_rec.bnf_adrs_rqd_flag;
  End If;
  If (p_rec.bnf_cntngt_bnfs_alwd_flag = hr_api.g_varchar2) then
    p_rec.bnf_cntngt_bnfs_alwd_flag :=
    ben_pln_shd.g_old_rec.bnf_cntngt_bnfs_alwd_flag;
  End If;
  If (p_rec.bnf_ctfn_rqd_flag = hr_api.g_varchar2) then
    p_rec.bnf_ctfn_rqd_flag :=
    ben_pln_shd.g_old_rec.bnf_ctfn_rqd_flag;
  End If;
  If (p_rec.bnf_dob_rqd_flag = hr_api.g_varchar2) then
    p_rec.bnf_dob_rqd_flag :=
    ben_pln_shd.g_old_rec.bnf_dob_rqd_flag;
  End If;
  If (p_rec.bnf_dsge_mnr_ttee_rqd_flag = hr_api.g_varchar2) then
    p_rec.bnf_dsge_mnr_ttee_rqd_flag :=
    ben_pln_shd.g_old_rec.bnf_dsge_mnr_ttee_rqd_flag;
  End If;
  If (p_rec.bnf_incrmt_amt = hr_api.g_number) then
    p_rec.bnf_incrmt_amt :=
    ben_pln_shd.g_old_rec.bnf_incrmt_amt;
  End If;
  If (p_rec.bnf_dflt_bnf_cd = hr_api.g_varchar2) then
    p_rec.bnf_dflt_bnf_cd :=
    ben_pln_shd.g_old_rec.bnf_dflt_bnf_cd;
  End If;
  If (p_rec.bnf_legv_id_rqd_flag = hr_api.g_varchar2) then
    p_rec.bnf_legv_id_rqd_flag :=
    ben_pln_shd.g_old_rec.bnf_legv_id_rqd_flag;
  End If;
  If (p_rec.bnf_may_dsgt_org_flag = hr_api.g_varchar2) then
    p_rec.bnf_may_dsgt_org_flag :=
    ben_pln_shd.g_old_rec.bnf_may_dsgt_org_flag;
  End If;
  If (p_rec.bnf_mn_dsgntbl_amt = hr_api.g_number) then
    p_rec.bnf_mn_dsgntbl_amt :=
    ben_pln_shd.g_old_rec.bnf_mn_dsgntbl_amt;
  End If;
  If (p_rec.bnf_mn_dsgntbl_pct_val = hr_api.g_number) then
    p_rec.bnf_mn_dsgntbl_pct_val :=
    ben_pln_shd.g_old_rec.bnf_mn_dsgntbl_pct_val;
  End If;
  If (p_rec.rqd_perd_enrt_nenrt_val = hr_api.g_number) then
    p_rec.rqd_perd_enrt_nenrt_val :=
    ben_pln_shd.g_old_rec.rqd_perd_enrt_nenrt_val;
  End If;
  If (p_rec.ordr_num = hr_api.g_number) then
    p_rec.ordr_num :=
    ben_pln_shd.g_old_rec.ordr_num;
  End If;
  If (p_rec.bnf_pct_incrmt_val = hr_api.g_number) then
    p_rec.bnf_pct_incrmt_val :=
    ben_pln_shd.g_old_rec.bnf_pct_incrmt_val;
  End If;
  If (p_rec.bnf_pct_amt_alwd_cd = hr_api.g_varchar2) then
    p_rec.bnf_pct_amt_alwd_cd :=
    ben_pln_shd.g_old_rec.bnf_pct_amt_alwd_cd;
  End If;
  If (p_rec.bnf_qdro_rl_apls_flag = hr_api.g_varchar2) then
    p_rec.bnf_qdro_rl_apls_flag :=
    ben_pln_shd.g_old_rec.bnf_qdro_rl_apls_flag;
  End If;
  If (p_rec.per_cvrd_cd = hr_api.g_varchar2) then
    p_rec.per_cvrd_cd :=
    ben_pln_shd.g_old_rec.per_cvrd_cd;
  End If;
  If (p_rec.svgs_pl_flag = hr_api.g_varchar2) then
    p_rec.svgs_pl_flag :=
    ben_pln_shd.g_old_rec.svgs_pl_flag;
  End If;
  If (p_rec.dflt_to_asn_pndg_ctfn_cd = hr_api.g_varchar2) then
    p_rec.dflt_to_asn_pndg_ctfn_cd :=
    ben_pln_shd.g_old_rec.dflt_to_asn_pndg_ctfn_cd;
  End If;
  If (p_rec.dflt_to_asn_pndg_ctfn_rl = hr_api.g_number) then
    p_rec.dflt_to_asn_pndg_ctfn_rl :=
    ben_pln_shd.g_old_rec.dflt_to_asn_pndg_ctfn_rl;
  End If;
  If (p_rec.postelcn_edit_rl = hr_api.g_number) then
    p_rec.postelcn_edit_rl :=
    ben_pln_shd.g_old_rec.postelcn_edit_rl;
  End If;
  If (p_rec.drvbl_fctr_apls_rts_flag = hr_api.g_varchar2) then
    p_rec.drvbl_fctr_apls_rts_flag :=
    ben_pln_shd.g_old_rec.drvbl_fctr_apls_rts_flag;
  End If;
  If (p_rec.drvbl_fctr_prtn_elig_flag = hr_api.g_varchar2) then
    p_rec.drvbl_fctr_prtn_elig_flag :=
    ben_pln_shd.g_old_rec.drvbl_fctr_prtn_elig_flag;
  End If;
  If (p_rec.dpnt_dsgn_cd = hr_api.g_varchar2) then
    p_rec.dpnt_dsgn_cd :=
    ben_pln_shd.g_old_rec.dpnt_dsgn_cd;
  End If;
  If (p_rec.elig_apls_flag = hr_api.g_varchar2) then
    p_rec.elig_apls_flag :=
    ben_pln_shd.g_old_rec.elig_apls_flag;
  End If;
  If (p_rec.invk_dcln_prtn_pl_flag = hr_api.g_varchar2) then
    p_rec.invk_dcln_prtn_pl_flag :=
    ben_pln_shd.g_old_rec.invk_dcln_prtn_pl_flag;
  End If;
  If (p_rec.invk_flx_cr_pl_flag = hr_api.g_varchar2) then
    p_rec.invk_flx_cr_pl_flag :=
    ben_pln_shd.g_old_rec.invk_flx_cr_pl_flag;
  End If;
  If (p_rec.imptd_incm_calc_cd = hr_api.g_varchar2) then
    p_rec.imptd_incm_calc_cd :=
    ben_pln_shd.g_old_rec.imptd_incm_calc_cd;
  End If;
  If (p_rec.drvbl_dpnt_elig_flag = hr_api.g_varchar2) then
    p_rec.drvbl_dpnt_elig_flag :=
    ben_pln_shd.g_old_rec.drvbl_dpnt_elig_flag;
  End If;
  If (p_rec.trk_inelig_per_flag = hr_api.g_varchar2) then
    p_rec.trk_inelig_per_flag :=
    ben_pln_shd.g_old_rec.trk_inelig_per_flag;
  End If;
  If (p_rec.pl_cd = hr_api.g_varchar2) then
    p_rec.pl_cd :=
    ben_pln_shd.g_old_rec.pl_cd;
  End If;
  If (p_rec.auto_enrt_mthd_rl = hr_api.g_number) then
    p_rec.auto_enrt_mthd_rl :=
    ben_pln_shd.g_old_rec.auto_enrt_mthd_rl;
  End If;
  If (p_rec.ivr_ident = hr_api.g_varchar2) then
    p_rec.ivr_ident :=
    ben_pln_shd.g_old_rec.ivr_ident;
  End If;
  If (p_rec.url_ref_name = hr_api.g_varchar2) then
    p_rec.url_ref_name :=
    ben_pln_shd.g_old_rec.url_ref_name;
  End If;
  If (p_rec.cmpr_clms_to_cvg_or_bal_cd = hr_api.g_varchar2) then
    p_rec.cmpr_clms_to_cvg_or_bal_cd :=
    ben_pln_shd.g_old_rec.cmpr_clms_to_cvg_or_bal_cd;
  End If;
  If (p_rec.cobra_pymt_due_dy_num = hr_api.g_number) then
    p_rec.cobra_pymt_due_dy_num :=
    ben_pln_shd.g_old_rec.cobra_pymt_due_dy_num;
  End If;
  If (p_rec.dpnt_cvd_by_othr_apls_flag = hr_api.g_varchar2) then
    p_rec.dpnt_cvd_by_othr_apls_flag :=
    ben_pln_shd.g_old_rec.dpnt_cvd_by_othr_apls_flag;
  End If;
  If (p_rec.enrt_mthd_cd = hr_api.g_varchar2) then
    p_rec.enrt_mthd_cd :=
    ben_pln_shd.g_old_rec.enrt_mthd_cd;
  End If;
  If (p_rec.enrt_cd = hr_api.g_varchar2) then
    p_rec.enrt_cd :=
    ben_pln_shd.g_old_rec.enrt_cd;
  End If;
  If (p_rec.enrt_cvg_strt_dt_cd = hr_api.g_varchar2) then
    p_rec.enrt_cvg_strt_dt_cd :=
    ben_pln_shd.g_old_rec.enrt_cvg_strt_dt_cd;
  End If;
  If (p_rec.enrt_cvg_end_dt_cd = hr_api.g_varchar2) then
    p_rec.enrt_cvg_end_dt_cd :=
    ben_pln_shd.g_old_rec.enrt_cvg_end_dt_cd;
  End If;
  If (p_rec.frfs_aply_flag = hr_api.g_varchar2) then
    p_rec.frfs_aply_flag :=
    ben_pln_shd.g_old_rec.frfs_aply_flag;
  End If;
  If (p_rec.hc_pl_subj_hcfa_aprvl_flag = hr_api.g_varchar2) then
    p_rec.hc_pl_subj_hcfa_aprvl_flag :=
    ben_pln_shd.g_old_rec.hc_pl_subj_hcfa_aprvl_flag;
  End If;
  If (p_rec.hghly_cmpd_rl_apls_flag = hr_api.g_varchar2) then
    p_rec.hghly_cmpd_rl_apls_flag :=
    ben_pln_shd.g_old_rec.hghly_cmpd_rl_apls_flag;
  End If;
  If (p_rec.incptn_dt = hr_api.g_date) then
    p_rec.incptn_dt :=
    ben_pln_shd.g_old_rec.incptn_dt;
  End If;
  If (p_rec.mn_cvg_rl = hr_api.g_number) then
    p_rec.mn_cvg_rl :=
    ben_pln_shd.g_old_rec.mn_cvg_rl;
  End If;
  If (p_rec.mn_cvg_rqd_amt = hr_api.g_number) then
    p_rec.mn_cvg_rqd_amt :=
    ben_pln_shd.g_old_rec.mn_cvg_rqd_amt;
  End If;
  If (p_rec.mn_opts_rqd_num = hr_api.g_number) then
    p_rec.mn_opts_rqd_num :=
    ben_pln_shd.g_old_rec.mn_opts_rqd_num;
  End If;
  If (p_rec.mx_cvg_alwd_amt = hr_api.g_number) then
    p_rec.mx_cvg_alwd_amt :=
    ben_pln_shd.g_old_rec.mx_cvg_alwd_amt;
  End If;
  If (p_rec.mx_cvg_rl = hr_api.g_number) then
    p_rec.mx_cvg_rl :=
    ben_pln_shd.g_old_rec.mx_cvg_rl;
  End If;
  If (p_rec.mx_opts_alwd_num = hr_api.g_number) then
    p_rec.mx_opts_alwd_num :=
    ben_pln_shd.g_old_rec.mx_opts_alwd_num;
  End If;
  If (p_rec.mx_cvg_wcfn_mlt_num = hr_api.g_number) then
    p_rec.mx_cvg_wcfn_mlt_num :=
    ben_pln_shd.g_old_rec.mx_cvg_wcfn_mlt_num;
  End If;
  If (p_rec.mx_cvg_wcfn_amt = hr_api.g_number) then
    p_rec.mx_cvg_wcfn_amt :=
    ben_pln_shd.g_old_rec.mx_cvg_wcfn_amt;
  End If;
  If (p_rec.mx_cvg_incr_alwd_amt = hr_api.g_number) then
    p_rec.mx_cvg_incr_alwd_amt :=
    ben_pln_shd.g_old_rec.mx_cvg_incr_alwd_amt;
  End If;
  If (p_rec.mx_cvg_incr_wcf_alwd_amt = hr_api.g_number) then
    p_rec.mx_cvg_incr_wcf_alwd_amt :=
    ben_pln_shd.g_old_rec.mx_cvg_incr_wcf_alwd_amt;
  End If;
  If (p_rec.mx_cvg_mlt_incr_num = hr_api.g_number) then
    p_rec.mx_cvg_mlt_incr_num :=
    ben_pln_shd.g_old_rec.mx_cvg_mlt_incr_num;
  End If;
  If (p_rec.mx_cvg_mlt_incr_wcf_num = hr_api.g_number) then
    p_rec.mx_cvg_mlt_incr_wcf_num :=
    ben_pln_shd.g_old_rec.mx_cvg_mlt_incr_wcf_num;
  End If;
  If (p_rec.mx_wtg_dt_to_use_cd = hr_api.g_varchar2) then
    p_rec.mx_wtg_dt_to_use_cd :=
    ben_pln_shd.g_old_rec.mx_wtg_dt_to_use_cd;
  End If;
  If (p_rec.mx_wtg_dt_to_use_rl = hr_api.g_number) then
    p_rec.mx_wtg_dt_to_use_rl :=
    ben_pln_shd.g_old_rec.mx_wtg_dt_to_use_rl;
  End If;
  If (p_rec.mx_wtg_perd_prte_uom = hr_api.g_varchar2) then
    p_rec.mx_wtg_perd_prte_uom :=
    ben_pln_shd.g_old_rec.mx_wtg_perd_prte_uom;
  End If;
  If (p_rec.mx_wtg_perd_prte_val = hr_api.g_number) then
    p_rec.mx_wtg_perd_prte_val :=
    ben_pln_shd.g_old_rec.mx_wtg_perd_prte_val;
  End If;
  If (p_rec.mx_wtg_perd_rl = hr_api.g_number) then
    p_rec.mx_wtg_perd_rl :=
    ben_pln_shd.g_old_rec.mx_wtg_perd_rl;
  End If;
  If (p_rec.nip_dflt_enrt_cd = hr_api.g_varchar2) then
    p_rec.nip_dflt_enrt_cd :=
    ben_pln_shd.g_old_rec.nip_dflt_enrt_cd;
  End If;
  If (p_rec.nip_dflt_enrt_det_rl = hr_api.g_number) then
    p_rec.nip_dflt_enrt_det_rl :=
    ben_pln_shd.g_old_rec.nip_dflt_enrt_det_rl;
  End If;
  If (p_rec.dpnt_adrs_rqd_flag = hr_api.g_varchar2) then
    p_rec.dpnt_adrs_rqd_flag :=
    ben_pln_shd.g_old_rec.dpnt_adrs_rqd_flag;
  End If;
  If (p_rec.dpnt_cvg_end_dt_cd = hr_api.g_varchar2) then
    p_rec.dpnt_cvg_end_dt_cd :=
    ben_pln_shd.g_old_rec.dpnt_cvg_end_dt_cd;
  End If;
  If (p_rec.dpnt_cvg_end_dt_rl = hr_api.g_number) then
    p_rec.dpnt_cvg_end_dt_rl :=
    ben_pln_shd.g_old_rec.dpnt_cvg_end_dt_rl;
  End If;
  If (p_rec.dpnt_cvg_strt_dt_cd = hr_api.g_varchar2) then
    p_rec.dpnt_cvg_strt_dt_cd :=
    ben_pln_shd.g_old_rec.dpnt_cvg_strt_dt_cd;
  End If;
  If (p_rec.dpnt_cvg_strt_dt_rl = hr_api.g_number) then
    p_rec.dpnt_cvg_strt_dt_rl :=
    ben_pln_shd.g_old_rec.dpnt_cvg_strt_dt_rl;
  End If;
  If (p_rec.dpnt_dob_rqd_flag = hr_api.g_varchar2) then
    p_rec.dpnt_dob_rqd_flag :=
    ben_pln_shd.g_old_rec.dpnt_dob_rqd_flag;
  End If;
  If (p_rec.dpnt_leg_id_rqd_flag = hr_api.g_varchar2) then
    p_rec.dpnt_leg_id_rqd_flag :=
    ben_pln_shd.g_old_rec.dpnt_leg_id_rqd_flag;
  End If;
  If (p_rec.dpnt_no_ctfn_rqd_flag = hr_api.g_varchar2) then
    p_rec.dpnt_no_ctfn_rqd_flag :=
    ben_pln_shd.g_old_rec.dpnt_no_ctfn_rqd_flag;
  End If;
  If (p_rec.no_mn_cvg_amt_apls_flag = hr_api.g_varchar2) then
    p_rec.no_mn_cvg_amt_apls_flag :=
    ben_pln_shd.g_old_rec.no_mn_cvg_amt_apls_flag;
  End If;
  If (p_rec.no_mn_cvg_incr_apls_flag = hr_api.g_varchar2) then
    p_rec.no_mn_cvg_incr_apls_flag :=
    ben_pln_shd.g_old_rec.no_mn_cvg_incr_apls_flag;
  End If;
  If (p_rec.no_mn_opts_num_apls_flag = hr_api.g_varchar2) then
    p_rec.no_mn_opts_num_apls_flag :=
    ben_pln_shd.g_old_rec.no_mn_opts_num_apls_flag;
  End If;
  If (p_rec.no_mx_cvg_amt_apls_flag = hr_api.g_varchar2) then
    p_rec.no_mx_cvg_amt_apls_flag :=
    ben_pln_shd.g_old_rec.no_mx_cvg_amt_apls_flag;
  End If;
  If (p_rec.no_mx_cvg_incr_apls_flag = hr_api.g_varchar2) then
    p_rec.no_mx_cvg_incr_apls_flag :=
    ben_pln_shd.g_old_rec.no_mx_cvg_incr_apls_flag;
  End If;
  If (p_rec.no_mx_opts_num_apls_flag = hr_api.g_varchar2) then
    p_rec.no_mx_opts_num_apls_flag :=
    ben_pln_shd.g_old_rec.no_mx_opts_num_apls_flag;
  End If;
  If (p_rec.nip_pl_uom = hr_api.g_varchar2) then
    p_rec.nip_pl_uom :=
    ben_pln_shd.g_old_rec.nip_pl_uom;
  End If;
  If (p_rec.rqd_perd_enrt_nenrt_uom = hr_api.g_varchar2) then
    p_rec.rqd_perd_enrt_nenrt_uom :=
    ben_pln_shd.g_old_rec.rqd_perd_enrt_nenrt_uom;
  End If;
  If (p_rec.nip_acty_ref_perd_cd = hr_api.g_varchar2) then
    p_rec.nip_acty_ref_perd_cd :=
    ben_pln_shd.g_old_rec.nip_acty_ref_perd_cd;
  End If;
  If (p_rec.nip_enrt_info_rt_freq_cd = hr_api.g_varchar2) then
    p_rec.nip_enrt_info_rt_freq_cd :=
    ben_pln_shd.g_old_rec.nip_enrt_info_rt_freq_cd;
  End If;
  If (p_rec.enrt_cvg_end_dt_rl = hr_api.g_number) then
    p_rec.enrt_cvg_end_dt_rl :=
    ben_pln_shd.g_old_rec.enrt_cvg_end_dt_rl;
  End If;
  If (p_rec.enrt_cvg_strt_dt_rl = hr_api.g_number) then
    p_rec.enrt_cvg_strt_dt_rl :=
    ben_pln_shd.g_old_rec.enrt_cvg_strt_dt_rl;
  End If;
  If (p_rec.prort_prtl_yr_cvg_rstrn_cd = hr_api.g_varchar2) then
    p_rec.prort_prtl_yr_cvg_rstrn_cd :=
    ben_pln_shd.g_old_rec.prort_prtl_yr_cvg_rstrn_cd;
  End If;
  If (p_rec.prort_prtl_yr_cvg_rstrn_rl = hr_api.g_number) then
    p_rec.prort_prtl_yr_cvg_rstrn_rl :=
    ben_pln_shd.g_old_rec.prort_prtl_yr_cvg_rstrn_rl;
  End If;
  If (p_rec.prtn_elig_ovrid_alwd_flag = hr_api.g_varchar2) then
    p_rec.prtn_elig_ovrid_alwd_flag :=
    ben_pln_shd.g_old_rec.prtn_elig_ovrid_alwd_flag;
  End If;
  If (p_rec.rt_end_dt_rl = hr_api.g_number) then
    p_rec.rt_end_dt_rl :=
    ben_pln_shd.g_old_rec.rt_end_dt_rl;
  End If;
  If (p_rec.rt_strt_dt_rl = hr_api.g_number) then
    p_rec.rt_strt_dt_rl :=
    ben_pln_shd.g_old_rec.rt_strt_dt_rl;
  End If;
  If (p_rec.subj_to_imptd_incm_typ_cd = hr_api.g_varchar2) then
    p_rec.subj_to_imptd_incm_typ_cd :=
    ben_pln_shd.g_old_rec.subj_to_imptd_incm_typ_cd;
  End If;
  If (p_rec.use_all_asnts_elig_flag = hr_api.g_varchar2) then
    p_rec.use_all_asnts_elig_flag :=
    ben_pln_shd.g_old_rec.use_all_asnts_elig_flag;
  End If;
  If (p_rec.use_all_asnts_for_rt_flag = hr_api.g_varchar2) then
    p_rec.use_all_asnts_for_rt_flag :=
    ben_pln_shd.g_old_rec.use_all_asnts_for_rt_flag;
  End If;
  If (p_rec.vstg_apls_flag = hr_api.g_varchar2) then
    p_rec.vstg_apls_flag :=
    ben_pln_shd.g_old_rec.vstg_apls_flag;
  End If;
  If (p_rec.wvbl_flag = hr_api.g_varchar2) then
    p_rec.wvbl_flag :=
    ben_pln_shd.g_old_rec.wvbl_flag;
  End If;
  If (p_rec.hc_svc_typ_cd = hr_api.g_varchar2) then
    p_rec.hc_svc_typ_cd :=
    ben_pln_shd.g_old_rec.hc_svc_typ_cd;
  End If;
  If (p_rec.pl_stat_cd = hr_api.g_varchar2) then
    p_rec.pl_stat_cd :=
    ben_pln_shd.g_old_rec.pl_stat_cd;
  End If;
  If (p_rec.prmry_fndg_mthd_cd = hr_api.g_varchar2) then
    p_rec.prmry_fndg_mthd_cd :=
    ben_pln_shd.g_old_rec.prmry_fndg_mthd_cd;
  End If;
  If (p_rec.rt_end_dt_cd = hr_api.g_varchar2) then
    p_rec.rt_end_dt_cd :=
    ben_pln_shd.g_old_rec.rt_end_dt_cd;
  End If;
  If (p_rec.rt_strt_dt_cd = hr_api.g_varchar2) then
    p_rec.rt_strt_dt_cd :=
    ben_pln_shd.g_old_rec.rt_strt_dt_cd;
  End If;
  If (p_rec.bnf_dsgn_cd = hr_api.g_varchar2) then
    p_rec.bnf_dsgn_cd :=
    ben_pln_shd.g_old_rec.bnf_dsgn_cd;
  End If;
  If (p_rec.alws_reimbmts_flag = hr_api.g_varchar2) then
    p_rec.alws_reimbmts_flag :=
    ben_pln_shd.g_old_rec.alws_reimbmts_flag;
  End If;
  If (p_rec.enrt_pl_opt_flag = hr_api.g_varchar2) then
    p_rec.enrt_pl_opt_flag :=
    ben_pln_shd.g_old_rec.enrt_pl_opt_flag;
  End If;
  If (p_rec.bnft_prvdr_pool_id = hr_api.g_number) then
    p_rec.bnft_prvdr_pool_id :=
    ben_pln_shd.g_old_rec.bnft_prvdr_pool_id;
  End If;
  If (p_rec.MAY_ENRL_PL_N_OIPL_FLAG = hr_api.g_VARCHAR2) then
    p_rec.MAY_ENRL_PL_N_OIPL_FLAG :=
    ben_pln_shd.g_old_rec.MAY_ENRL_PL_N_OIPL_FLAG;
  End If;
  If (p_rec.ENRT_RL = hr_api.g_NUMBER) then
    p_rec.ENRT_RL :=
    ben_pln_shd.g_old_rec.ENRT_RL;
  End If;
  If (p_rec.rqd_perd_enrt_nenrt_rl = hr_api.g_NUMBER) then
    p_rec.rqd_perd_enrt_nenrt_rl :=
    ben_pln_shd.g_old_rec.rqd_perd_enrt_nenrt_rl;
  End If;
  If (p_rec.ALWS_UNRSTRCTD_ENRT_FLAG = hr_api.g_VARCHAR2) then
    p_rec.ALWS_UNRSTRCTD_ENRT_FLAG :=
    ben_pln_shd.g_old_rec.ALWS_UNRSTRCTD_ENRT_FLAG;
  End If;
  If (p_rec.ALWS_TMPRY_ID_CRD_FLAG = hr_api.g_VARCHAR2) then
    p_rec.ALWS_TMPRY_ID_CRD_FLAG :=
    ben_pln_shd.g_old_rec.ALWS_TMPRY_ID_CRD_FLAG;
  End If;
  If (p_rec.BNFT_OR_OPTION_RSTRCTN_CD = hr_api.g_VARCHAR2) then
    p_rec.BNFT_OR_OPTION_RSTRCTN_CD :=
    ben_pln_shd.g_old_rec.BNFT_OR_OPTION_RSTRCTN_CD;
  End If;
  If (p_rec.CVG_INCR_R_DECR_ONLY_CD = hr_api.g_VARCHAR2) then
    p_rec.CVG_INCR_R_DECR_ONLY_CD :=
    ben_pln_shd.g_old_rec.CVG_INCR_R_DECR_ONLY_CD;
  End If;
  If (p_rec.unsspnd_enrt_cd = hr_api.g_VARCHAR2) then
    p_rec.unsspnd_enrt_cd :=
    ben_pln_shd.g_old_rec.unsspnd_enrt_cd;
  End If;
  If (p_rec.pln_attribute_category = hr_api.g_varchar2) then
    p_rec.pln_attribute_category :=
    ben_pln_shd.g_old_rec.pln_attribute_category;
  End If;
  If (p_rec.pln_attribute1 = hr_api.g_varchar2) then
    p_rec.pln_attribute1 :=
    ben_pln_shd.g_old_rec.pln_attribute1;
  End If;
  If (p_rec.pln_attribute2 = hr_api.g_varchar2) then
    p_rec.pln_attribute2 :=
    ben_pln_shd.g_old_rec.pln_attribute2;
  End If;
  If (p_rec.pln_attribute3 = hr_api.g_varchar2) then
    p_rec.pln_attribute3 :=
    ben_pln_shd.g_old_rec.pln_attribute3;
  End If;
  If (p_rec.pln_attribute4 = hr_api.g_varchar2) then
    p_rec.pln_attribute4 :=
    ben_pln_shd.g_old_rec.pln_attribute4;
  End If;
  If (p_rec.pln_attribute5 = hr_api.g_varchar2) then
    p_rec.pln_attribute5 :=
    ben_pln_shd.g_old_rec.pln_attribute5;
  End If;
  If (p_rec.pln_attribute6 = hr_api.g_varchar2) then
    p_rec.pln_attribute6 :=
    ben_pln_shd.g_old_rec.pln_attribute6;
  End If;
  If (p_rec.pln_attribute7 = hr_api.g_varchar2) then
    p_rec.pln_attribute7 :=
    ben_pln_shd.g_old_rec.pln_attribute7;
  End If;
  If (p_rec.pln_attribute8 = hr_api.g_varchar2) then
    p_rec.pln_attribute8 :=
    ben_pln_shd.g_old_rec.pln_attribute8;
  End If;
  If (p_rec.pln_attribute9 = hr_api.g_varchar2) then
    p_rec.pln_attribute9 :=
    ben_pln_shd.g_old_rec.pln_attribute9;
  End If;
  If (p_rec.pln_attribute10 = hr_api.g_varchar2) then
    p_rec.pln_attribute10 :=
    ben_pln_shd.g_old_rec.pln_attribute10;
  End If;
  If (p_rec.pln_attribute11 = hr_api.g_varchar2) then
    p_rec.pln_attribute11 :=
    ben_pln_shd.g_old_rec.pln_attribute11;
  End If;
  If (p_rec.pln_attribute12 = hr_api.g_varchar2) then
    p_rec.pln_attribute12 :=
    ben_pln_shd.g_old_rec.pln_attribute12;
  End If;
  If (p_rec.pln_attribute13 = hr_api.g_varchar2) then
    p_rec.pln_attribute13 :=
    ben_pln_shd.g_old_rec.pln_attribute13;
  End If;
  If (p_rec.pln_attribute14 = hr_api.g_varchar2) then
    p_rec.pln_attribute14 :=
    ben_pln_shd.g_old_rec.pln_attribute14;
  End If;
  If (p_rec.pln_attribute15 = hr_api.g_varchar2) then
    p_rec.pln_attribute15 :=
    ben_pln_shd.g_old_rec.pln_attribute15;
  End If;
  If (p_rec.pln_attribute16 = hr_api.g_varchar2) then
    p_rec.pln_attribute16 :=
    ben_pln_shd.g_old_rec.pln_attribute16;
  End If;
  If (p_rec.pln_attribute17 = hr_api.g_varchar2) then
    p_rec.pln_attribute17 :=
    ben_pln_shd.g_old_rec.pln_attribute17;
  End If;
  If (p_rec.pln_attribute18 = hr_api.g_varchar2) then
    p_rec.pln_attribute18 :=
    ben_pln_shd.g_old_rec.pln_attribute18;
  End If;
  If (p_rec.pln_attribute19 = hr_api.g_varchar2) then
    p_rec.pln_attribute19 :=
    ben_pln_shd.g_old_rec.pln_attribute19;
  End If;
  If (p_rec.pln_attribute20 = hr_api.g_varchar2) then
    p_rec.pln_attribute20 :=
    ben_pln_shd.g_old_rec.pln_attribute20;
  End If;
  If (p_rec.pln_attribute21 = hr_api.g_varchar2) then
    p_rec.pln_attribute21 :=
    ben_pln_shd.g_old_rec.pln_attribute21;
  End If;
  If (p_rec.pln_attribute22 = hr_api.g_varchar2) then
    p_rec.pln_attribute22 :=
    ben_pln_shd.g_old_rec.pln_attribute22;
  End If;
  If (p_rec.pln_attribute23 = hr_api.g_varchar2) then
    p_rec.pln_attribute23 :=
    ben_pln_shd.g_old_rec.pln_attribute23;
  End If;
  If (p_rec.pln_attribute24 = hr_api.g_varchar2) then
    p_rec.pln_attribute24 :=
    ben_pln_shd.g_old_rec.pln_attribute24;
  End If;
  If (p_rec.pln_attribute25 = hr_api.g_varchar2) then
    p_rec.pln_attribute25 :=
    ben_pln_shd.g_old_rec.pln_attribute25;
  End If;
  If (p_rec.pln_attribute26 = hr_api.g_varchar2) then
    p_rec.pln_attribute26 :=
    ben_pln_shd.g_old_rec.pln_attribute26;
  End If;
  If (p_rec.pln_attribute27 = hr_api.g_varchar2) then
    p_rec.pln_attribute27 :=
    ben_pln_shd.g_old_rec.pln_attribute27;
  End If;
  If (p_rec.pln_attribute28 = hr_api.g_varchar2) then
    p_rec.pln_attribute28 :=
    ben_pln_shd.g_old_rec.pln_attribute28;
  End If;
  If (p_rec.pln_attribute29 = hr_api.g_varchar2) then
    p_rec.pln_attribute29 :=
    ben_pln_shd.g_old_rec.pln_attribute29;
  End If;
  If (p_rec.pln_attribute30 = hr_api.g_varchar2) then
    p_rec.pln_attribute30 :=
    ben_pln_shd.g_old_rec.pln_attribute30;
  End If;
  If (p_rec.susp_if_ctfn_not_prvd_flag = hr_api.g_varchar2) then
    p_rec.susp_if_ctfn_not_prvd_flag :=
    ben_pln_shd.g_old_rec.susp_if_ctfn_not_prvd_flag;
  End If;
  If (p_rec.ctfn_determine_cd = hr_api.g_varchar2) then
    p_rec.ctfn_determine_cd :=
    ben_pln_shd.g_old_rec.ctfn_determine_cd;
  End If;
  If (p_rec.susp_if_dpnt_ssn_nt_prv_cd = hr_api.g_varchar2) then
    p_rec.susp_if_dpnt_ssn_nt_prv_cd :=
    ben_pln_shd.g_old_rec.susp_if_dpnt_ssn_nt_prv_cd;
  End If;
  If (p_rec.susp_if_dpnt_dob_nt_prv_cd = hr_api.g_varchar2) then
    p_rec.susp_if_dpnt_dob_nt_prv_cd :=
    ben_pln_shd.g_old_rec.susp_if_dpnt_dob_nt_prv_cd;
  End If;
  If (p_rec.susp_if_dpnt_adr_nt_prv_cd = hr_api.g_varchar2) then
    p_rec.susp_if_dpnt_adr_nt_prv_cd :=
    ben_pln_shd.g_old_rec.susp_if_dpnt_adr_nt_prv_cd;
  End If;
  If (p_rec.susp_if_ctfn_not_dpnt_flag = hr_api.g_varchar2) then
    p_rec.susp_if_ctfn_not_dpnt_flag :=
    ben_pln_shd.g_old_rec.susp_if_ctfn_not_dpnt_flag;
  End If;
  If (p_rec.susp_if_bnf_ssn_nt_prv_cd = hr_api.g_varchar2) then
    p_rec.susp_if_bnf_ssn_nt_prv_cd :=
    ben_pln_shd.g_old_rec.susp_if_bnf_ssn_nt_prv_cd;
  End If;
  If (p_rec.susp_if_bnf_dob_nt_prv_cd = hr_api.g_varchar2) then
    p_rec.susp_if_bnf_dob_nt_prv_cd :=
    ben_pln_shd.g_old_rec.susp_if_bnf_dob_nt_prv_cd;
  End If;
  If (p_rec.susp_if_bnf_adr_nt_prv_cd = hr_api.g_varchar2) then
    p_rec.susp_if_bnf_adr_nt_prv_cd :=
    ben_pln_shd.g_old_rec.susp_if_bnf_adr_nt_prv_cd;
  End If;
  If (p_rec.susp_if_ctfn_not_bnf_flag = hr_api.g_varchar2) then
    p_rec.susp_if_ctfn_not_bnf_flag :=
    ben_pln_shd.g_old_rec.susp_if_ctfn_not_bnf_flag;
  End If;
  If (p_rec.dpnt_ctfn_determine_cd = hr_api.g_varchar2) then
    p_rec.dpnt_ctfn_determine_cd :=
    ben_pln_shd.g_old_rec.dpnt_ctfn_determine_cd;
  End If;
  If (p_rec.bnf_ctfn_determine_cd = hr_api.g_varchar2) then
    p_rec.bnf_ctfn_determine_cd :=
    ben_pln_shd.g_old_rec.bnf_ctfn_determine_cd;
  End If;
  If (p_rec.actl_prem_id = hr_api.g_number) then
    p_rec.actl_prem_id :=
    ben_pln_shd.g_old_rec.actl_prem_id;
  End If;
  If (p_rec.nip_dflt_flag = hr_api.g_varchar2) then
    p_rec.nip_dflt_flag :=
    ben_pln_shd.g_old_rec.nip_dflt_flag;
  End If;
  If (p_rec.frfs_distr_mthd_cd= hr_api.g_varchar2) then
    p_rec.frfs_distr_mthd_cd:=
    ben_pln_shd.g_old_rec.frfs_distr_mthd_cd;
  End If;
  If (p_rec.frfs_distr_mthd_rl= hr_api.g_number) then
    p_rec.frfs_distr_mthd_rl:=
    ben_pln_shd.g_old_rec.frfs_distr_mthd_rl;
  End If;
  If (p_rec.frfs_cntr_det_cd= hr_api.g_varchar2) then
    p_rec.frfs_cntr_det_cd:=
    ben_pln_shd.g_old_rec.frfs_cntr_det_cd;
  End If;
  If (p_rec.frfs_distr_det_cd= hr_api.g_varchar2) then
    p_rec.frfs_distr_det_cd:=
    ben_pln_shd.g_old_rec.frfs_distr_det_cd;
  End If;
  If (p_rec.cost_alloc_keyflex_1_id= hr_api.g_number) then
    p_rec.cost_alloc_keyflex_1_id:=
    ben_pln_shd.g_old_rec.cost_alloc_keyflex_1_id;
  End If;
  If (p_rec.cost_alloc_keyflex_2_id= hr_api.g_number) then
    p_rec.cost_alloc_keyflex_2_id:=
    ben_pln_shd.g_old_rec.cost_alloc_keyflex_2_id;
  End If;
  If (p_rec.post_to_gl_flag= hr_api.g_varchar2) then
    p_rec.post_to_gl_flag:=
    ben_pln_shd.g_old_rec.post_to_gl_flag;
  End If;
  If (p_rec.frfs_val_det_cd= hr_api.g_varchar2) then
    p_rec.frfs_val_det_cd:=
    ben_pln_shd.g_old_rec.frfs_val_det_cd;
  End If;
  If (p_rec.frfs_mx_cryfwd_val= hr_api.g_number) then
    p_rec.frfs_mx_cryfwd_val:=
    ben_pln_shd.g_old_rec.frfs_mx_cryfwd_val;
  End If;
  If (p_rec.frfs_portion_det_cd= hr_api.g_varchar2) then
    p_rec.frfs_portion_det_cd:=
    ben_pln_shd.g_old_rec.frfs_portion_det_cd;
  End If;
  If (p_rec.bndry_perd_cd= hr_api.g_varchar2) then
    p_rec.bndry_perd_cd:=
    ben_pln_shd.g_old_rec.bndry_perd_cd;
  End If;
  If (p_rec.short_name= hr_api.g_varchar2) then
      p_rec.short_name:=
      ben_pln_shd.g_old_rec.short_name;
  End If;
  If (p_rec.short_code= hr_api.g_varchar2) then
      p_rec.short_code:=
      ben_pln_shd.g_old_rec.short_code;
  End If;
  If (p_rec.legislation_code= hr_api.g_varchar2) then
            p_rec.legislation_code:=
            ben_pln_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.legislation_subgroup= hr_api.g_varchar2) then
            p_rec.legislation_subgroup:=
            ben_pln_shd.g_old_rec.legislation_subgroup;
  End If;

  If (p_rec.group_pl_id= hr_api.g_number) then
            p_rec.group_pl_id:=
            ben_pln_shd.g_old_rec.group_pl_id;
  End If;
  If (p_rec.mapping_table_name= hr_api.g_varchar2) then
      p_rec.mapping_table_name:=
      ben_pln_shd.g_old_rec.mapping_table_name;
  End If;
  If (p_rec.mapping_table_pk_id= hr_api.g_number) then
      p_rec.mapping_table_pk_id:=
      ben_pln_shd.g_old_rec.mapping_table_pk_id;
  End If;
  If (p_rec.Function_code= hr_api.g_varchar2) then
      p_rec.Function_code:=
      ben_pln_shd.g_old_rec.Function_code;
  End If;
  If (p_rec.pl_yr_not_applcbl_flag= hr_api.g_varchar2) then
      p_rec.pl_yr_not_applcbl_flag:=
      ben_pln_shd.g_old_rec.pl_yr_not_applcbl_flag;
  End If;
  If (p_rec.use_csd_rsd_prccng_cd= hr_api.g_varchar2) then
      p_rec.use_csd_rsd_prccng_cd:=
      ben_pln_shd.g_old_rec.use_csd_rsd_prccng_cd;
  End If;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
end ben_pln_upd2;

/

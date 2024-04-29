--------------------------------------------------------
--  DDL for Package Body BEN_PLN_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLN_INS" as
/* $Header: beplnrhi.pkb 120.8.12010000.2 2008/08/18 09:47:19 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  ben_pln_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_insert_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic for datetrack. The
--   functions of this procedure are as follows:
--   1) Get the object_version_number.
--   2) To set the effective start and end dates to the corresponding
--      validation start and end dates. Also, the object version number
--      record attribute is set.
--   3) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   4) To insert the row into the schema with the derived effective start
--      and end dates and the object version number.
--   5) To trap any constraint violations that may have occurred.
--   6) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   insert_dml and pre_update (logic permitting) procedure and must have
--   all mandatory arguments set.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_insert_dml
    (p_rec              in out nocopy ben_pln_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
-- Cursor to select 'old' created AOL who column values
--
  Cursor C_Sel1 Is
    select t.created_by,
           t.creation_date
    from   ben_pl_f t
    where  t.pl_id       = p_rec.pl_id
    and    t.effective_start_date =
             ben_pln_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc        varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          ben_pl_f.created_by%TYPE;
  l_creation_date       ben_pl_f.creation_date%TYPE;
  l_last_update_date    ben_pl_f.last_update_date%TYPE;
  l_last_updated_by     ben_pl_f.last_updated_by%TYPE;
  l_last_update_login   ben_pl_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
    (p_base_table_name => 'ben_pl_f',
     p_base_key_column => 'pl_id',
     p_base_key_value  => p_rec.pl_id);
  --
  -- Set the effective start and end dates to the corresponding
  -- validation start and end dates
  --
  p_rec.effective_start_date := p_validation_start_date;
  p_rec.effective_end_date   := p_validation_end_date;
  --
  -- If the datetrack_mode is not INSERT then we must populate the WHO
  -- columns with the 'old' creation values and 'new' updated values.
  --
  If (p_datetrack_mode <> 'INSERT') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Select the 'old' created values
    --
    Open C_Sel1;
    Fetch C_Sel1 Into l_created_by, l_creation_date;
    If C_Sel1%notfound Then
      --
      -- The previous 'old' created row has not been found. We need
      -- to error as an internal datetrack problem exists.
      --
      Close C_Sel1;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    End If;
    Close C_Sel1;
    --
    -- Set the AOL updated WHO values
    --
    l_last_update_date   := sysdate;
    l_last_updated_by    := fnd_global.user_id;
    l_last_update_login  := fnd_global.login_id;
  End If;
  --
   ben_pln_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_pl_f
  --
  insert into ben_pl_f
    (pl_id
    ,effective_start_date
    ,effective_end_date
    ,name
    ,alws_qdro_flag
    ,alws_qmcso_flag
    ,alws_reimbmts_flag
    ,bnf_addl_instn_txt_alwd_flag
    ,bnf_adrs_rqd_flag
    ,bnf_cntngt_bnfs_alwd_flag
    ,bnf_ctfn_rqd_flag
    ,bnf_dob_rqd_flag
    ,bnf_dsge_mnr_ttee_rqd_flag
    ,bnf_incrmt_amt
    ,bnf_dflt_bnf_cd
    ,bnf_legv_id_rqd_flag
    ,bnf_may_dsgt_org_flag
    ,bnf_mn_dsgntbl_amt
    ,bnf_mn_dsgntbl_pct_val
    ,rqd_perd_enrt_nenrt_val
    ,ordr_num
    ,bnf_pct_incrmt_val
    ,bnf_pct_amt_alwd_cd
    ,bnf_qdro_rl_apls_flag
    ,dflt_to_asn_pndg_ctfn_cd
    ,dflt_to_asn_pndg_ctfn_rl
    ,drvbl_fctr_apls_rts_flag
    ,drvbl_fctr_prtn_elig_flag
    ,dpnt_dsgn_cd
    ,elig_apls_flag
    ,invk_dcln_prtn_pl_flag
    ,invk_flx_cr_pl_flag
    ,imptd_incm_calc_cd
    ,drvbl_dpnt_elig_flag
    ,trk_inelig_per_flag
    ,pl_cd
    ,auto_enrt_mthd_rl
    ,ivr_ident
    ,url_ref_name
    ,cmpr_clms_to_cvg_or_bal_cd
    ,cobra_pymt_due_dy_num
    ,dpnt_cvd_by_othr_apls_flag
    ,enrt_mthd_cd
    ,enrt_cd
    ,enrt_cvg_strt_dt_cd
    ,enrt_cvg_end_dt_cd
    ,frfs_aply_flag
    ,hc_pl_subj_hcfa_aprvl_flag
    ,hghly_cmpd_rl_apls_flag
    ,incptn_dt
    ,mn_cvg_rl
    ,mn_cvg_rqd_amt
    ,mn_opts_rqd_num
    ,mx_cvg_alwd_amt
    ,mx_cvg_rl
    ,mx_opts_alwd_num
    ,mx_cvg_wcfn_mlt_num
    ,mx_cvg_wcfn_amt
    ,mx_cvg_incr_alwd_amt
    ,mx_cvg_incr_wcf_alwd_amt
    ,mx_cvg_mlt_incr_num
    ,mx_cvg_mlt_incr_wcf_num
    ,mx_wtg_dt_to_use_cd
    ,mx_wtg_dt_to_use_rl
    ,mx_wtg_perd_prte_uom
    ,mx_wtg_perd_prte_val
    ,mx_wtg_perd_rl
    ,nip_dflt_enrt_cd
    ,nip_dflt_enrt_det_rl
    ,dpnt_adrs_rqd_flag
    ,dpnt_cvg_end_dt_cd
    ,dpnt_cvg_end_dt_rl
    ,dpnt_cvg_strt_dt_cd
    ,dpnt_cvg_strt_dt_rl
    ,dpnt_dob_rqd_flag
    ,dpnt_leg_id_rqd_flag
    ,dpnt_no_ctfn_rqd_flag
    ,no_mn_cvg_amt_apls_flag
    ,no_mn_cvg_incr_apls_flag
    ,no_mn_opts_num_apls_flag
    ,no_mx_cvg_amt_apls_flag
    ,no_mx_cvg_incr_apls_flag
    ,no_mx_opts_num_apls_flag
    ,nip_pl_uom
    ,rqd_perd_enrt_nenrt_uom
    ,nip_acty_ref_perd_cd
    ,nip_enrt_info_rt_freq_cd
    ,per_cvrd_cd
    ,enrt_cvg_end_dt_rl
    ,postelcn_edit_rl
    ,enrt_cvg_strt_dt_rl
    ,prort_prtl_yr_cvg_rstrn_cd
    ,prort_prtl_yr_cvg_rstrn_rl
    ,prtn_elig_ovrid_alwd_flag
    ,svgs_pl_flag
    ,subj_to_imptd_incm_typ_cd
    ,use_all_asnts_elig_flag
    ,use_all_asnts_for_rt_flag
    ,vstg_apls_flag
    ,wvbl_flag
    ,hc_svc_typ_cd
    ,pl_stat_cd
    ,prmry_fndg_mthd_cd
    ,rt_end_dt_cd
    ,rt_end_dt_rl
    ,rt_strt_dt_rl
    ,rt_strt_dt_cd
    ,bnf_dsgn_cd
    ,pl_typ_id
    ,business_group_id
    ,enrt_pl_opt_flag
    ,bnft_prvdr_pool_id
    ,may_enrl_pl_n_oipl_flag
    ,enrt_rl
    ,rqd_perd_enrt_nenrt_rl
    ,alws_unrstrctd_enrt_flag
    ,bnft_or_option_rstrctn_cd
    ,cvg_incr_r_decr_only_cd
    ,unsspnd_enrt_cd
    ,pln_attribute_category
    ,pln_attribute1
    ,pln_attribute2
    ,pln_attribute3
    ,pln_attribute4
    ,pln_attribute5
    ,pln_attribute6
    ,pln_attribute7
    ,pln_attribute8
    ,pln_attribute9
    ,pln_attribute10
    ,pln_attribute11
    ,pln_attribute12
    ,pln_attribute13
    ,pln_attribute14
    ,pln_attribute15
    ,pln_attribute16
    ,pln_attribute17
    ,pln_attribute18
    ,pln_attribute19
    ,pln_attribute20
    ,pln_attribute21
    ,pln_attribute22
    ,pln_attribute23
    ,pln_attribute24
    ,pln_attribute25
    ,pln_attribute26
    ,pln_attribute27
    ,pln_attribute28
    ,pln_attribute29
    ,pln_attribute30
    ,susp_if_ctfn_not_prvd_flag
    ,ctfn_determine_cd
    ,susp_if_dpnt_ssn_nt_prv_cd
    ,susp_if_dpnt_dob_nt_prv_cd
    ,susp_if_dpnt_adr_nt_prv_cd
    ,susp_if_ctfn_not_dpnt_flag
    ,susp_if_bnf_ssn_nt_prv_cd
    ,susp_if_bnf_dob_nt_prv_cd
    ,susp_if_bnf_adr_nt_prv_cd
    ,susp_if_ctfn_not_bnf_flag
    ,dpnt_ctfn_determine_cd
    ,bnf_ctfn_determine_cd
    ,object_version_number
    ,actl_prem_id
    ,vrfy_fmly_mmbr_cd
    ,vrfy_fmly_mmbr_rl
    ,created_by
    ,creation_date
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,alws_tmpry_id_crd_flag
    ,nip_dflt_flag
    ,frfs_distr_mthd_cd
    ,frfs_distr_mthd_rl
    ,frfs_cntr_det_cd
    ,frfs_distr_det_cd
    ,cost_alloc_keyflex_1_id
    ,cost_alloc_keyflex_2_id
    ,post_to_gl_flag
    ,frfs_val_det_cd
    ,frfs_mx_cryfwd_val
    ,frfs_portion_det_cd
    ,bndry_perd_cd
    ,short_name
    ,short_code
    ,legislation_code
    ,legislation_subgroup
    ,group_pl_id
    ,mapping_table_name
    ,mapping_table_pk_id
    ,function_code
    ,pl_yr_not_applcbl_flag
    ,use_csd_rsd_prccng_cd
    )
  values
    (p_rec.pl_id
    ,p_rec.effective_start_date
    ,p_rec.effective_end_date
    ,p_rec.name
    ,p_rec.alws_qdro_flag
    ,p_rec.alws_qmcso_flag
    ,p_rec.alws_reimbmts_flag
    ,p_rec.bnf_addl_instn_txt_alwd_flag
    ,p_rec.bnf_adrs_rqd_flag
    ,p_rec.bnf_cntngt_bnfs_alwd_flag
    ,p_rec.bnf_ctfn_rqd_flag
    ,p_rec.bnf_dob_rqd_flag
    ,p_rec.bnf_dsge_mnr_ttee_rqd_flag
    ,p_rec.bnf_incrmt_amt
    ,p_rec.bnf_dflt_bnf_cd
    ,p_rec.bnf_legv_id_rqd_flag
    ,p_rec.bnf_may_dsgt_org_flag
    ,p_rec.bnf_mn_dsgntbl_amt
    ,p_rec.bnf_mn_dsgntbl_pct_val
    ,p_rec.rqd_perd_enrt_nenrt_val
    ,p_rec.ordr_num
    ,p_rec.bnf_pct_incrmt_val
    ,p_rec.bnf_pct_amt_alwd_cd
    ,p_rec.bnf_qdro_rl_apls_flag
    ,p_rec.dflt_to_asn_pndg_ctfn_cd
    ,p_rec.dflt_to_asn_pndg_ctfn_rl
    ,p_rec.drvbl_fctr_apls_rts_flag
    ,p_rec.drvbl_fctr_prtn_elig_flag
    ,p_rec.dpnt_dsgn_cd
    ,p_rec.elig_apls_flag
    ,p_rec.invk_dcln_prtn_pl_flag
    ,p_rec.invk_flx_cr_pl_flag
    ,p_rec.imptd_incm_calc_cd
    ,p_rec.drvbl_dpnt_elig_flag
    ,p_rec.trk_inelig_per_flag
    ,p_rec.pl_cd
    ,p_rec.auto_enrt_mthd_rl
    ,p_rec.ivr_ident
    ,p_rec.url_ref_name
    ,p_rec.cmpr_clms_to_cvg_or_bal_cd
    ,p_rec.cobra_pymt_due_dy_num
    ,p_rec.dpnt_cvd_by_othr_apls_flag
    ,p_rec.enrt_mthd_cd
    ,p_rec.enrt_cd
    ,p_rec.enrt_cvg_strt_dt_cd
    ,p_rec.enrt_cvg_end_dt_cd
    ,p_rec.frfs_aply_flag
    ,p_rec.hc_pl_subj_hcfa_aprvl_flag
    ,p_rec.hghly_cmpd_rl_apls_flag
    ,p_rec.incptn_dt
    ,p_rec.mn_cvg_rl
    ,p_rec.mn_cvg_rqd_amt
    ,p_rec.mn_opts_rqd_num
    ,p_rec.mx_cvg_alwd_amt
    ,p_rec.mx_cvg_rl
    ,p_rec.mx_opts_alwd_num
    ,p_rec.mx_cvg_wcfn_mlt_num
    ,p_rec.mx_cvg_wcfn_amt
    ,p_rec.mx_cvg_incr_alwd_amt
    ,p_rec.mx_cvg_incr_wcf_alwd_amt
    ,p_rec.mx_cvg_mlt_incr_num
    ,p_rec.mx_cvg_mlt_incr_wcf_num
    ,p_rec.mx_wtg_dt_to_use_cd
    ,p_rec.mx_wtg_dt_to_use_rl
    ,p_rec.mx_wtg_perd_prte_uom
    ,p_rec.mx_wtg_perd_prte_val
    ,p_rec.mx_wtg_perd_rl
    ,p_rec.nip_dflt_enrt_cd
    ,p_rec.nip_dflt_enrt_det_rl
    ,p_rec.dpnt_adrs_rqd_flag
    ,p_rec.dpnt_cvg_end_dt_cd
    ,p_rec.dpnt_cvg_end_dt_rl
    ,p_rec.dpnt_cvg_strt_dt_cd
    ,p_rec.dpnt_cvg_strt_dt_rl
    ,p_rec.dpnt_dob_rqd_flag
    ,p_rec.dpnt_leg_id_rqd_flag
    ,p_rec.dpnt_no_ctfn_rqd_flag
    ,p_rec.no_mn_cvg_amt_apls_flag
    ,p_rec.no_mn_cvg_incr_apls_flag
    ,p_rec.no_mn_opts_num_apls_flag
    ,p_rec.no_mx_cvg_amt_apls_flag
    ,p_rec.no_mx_cvg_incr_apls_flag
    ,p_rec.no_mx_opts_num_apls_flag
    ,p_rec.nip_pl_uom
    ,p_rec.rqd_perd_enrt_nenrt_uom
    ,p_rec.nip_acty_ref_perd_cd
    ,p_rec.nip_enrt_info_rt_freq_cd
    ,p_rec.per_cvrd_cd
    ,p_rec.enrt_cvg_end_dt_rl
    ,p_rec.postelcn_edit_rl
    ,p_rec.enrt_cvg_strt_dt_rl
    ,p_rec.prort_prtl_yr_cvg_rstrn_cd
    ,p_rec.prort_prtl_yr_cvg_rstrn_rl
    ,p_rec.prtn_elig_ovrid_alwd_flag
    ,p_rec.svgs_pl_flag
    ,p_rec.subj_to_imptd_incm_typ_cd
    ,p_rec.use_all_asnts_elig_flag
    ,p_rec.use_all_asnts_for_rt_flag
    ,p_rec.vstg_apls_flag
    ,p_rec.wvbl_flag
    ,p_rec.hc_svc_typ_cd
    ,p_rec.pl_stat_cd
    ,p_rec.prmry_fndg_mthd_cd
    ,p_rec.rt_end_dt_cd
    ,p_rec.rt_end_dt_rl
    ,p_rec.rt_strt_dt_rl
    ,p_rec.rt_strt_dt_cd
    ,p_rec.bnf_dsgn_cd
    ,p_rec.pl_typ_id
    ,p_rec.business_group_id
    ,p_rec.enrt_pl_opt_flag
    ,p_rec.bnft_prvdr_pool_id
    ,p_rec.may_enrl_pl_n_oipl_flag
    ,p_rec.enrt_rl
    ,p_rec.rqd_perd_enrt_nenrt_rl
    ,p_rec.alws_unrstrctd_enrt_flag
    ,p_rec.bnft_or_option_rstrctn_cd
    ,p_rec.cvg_incr_r_decr_only_cd
    ,p_rec.unsspnd_enrt_cd
    ,p_rec.pln_attribute_category
    ,p_rec.pln_attribute1
    ,p_rec.pln_attribute2
    ,p_rec.pln_attribute3
    ,p_rec.pln_attribute4
    ,p_rec.pln_attribute5
    ,p_rec.pln_attribute6
    ,p_rec.pln_attribute7
    ,p_rec.pln_attribute8
    ,p_rec.pln_attribute9
    ,p_rec.pln_attribute10
    ,p_rec.pln_attribute11
    ,p_rec.pln_attribute12
    ,p_rec.pln_attribute13
    ,p_rec.pln_attribute14
    ,p_rec.pln_attribute15
    ,p_rec.pln_attribute16
    ,p_rec.pln_attribute17
    ,p_rec.pln_attribute18
    ,p_rec.pln_attribute19
    ,p_rec.pln_attribute20
    ,p_rec.pln_attribute21
    ,p_rec.pln_attribute22
    ,p_rec.pln_attribute23
    ,p_rec.pln_attribute24
    ,p_rec.pln_attribute25
    ,p_rec.pln_attribute26
    ,p_rec.pln_attribute27
    ,p_rec.pln_attribute28
    ,p_rec.pln_attribute29
    ,p_rec.pln_attribute30
    ,p_rec.susp_if_ctfn_not_prvd_flag
    ,p_rec.ctfn_determine_cd
    ,p_rec.susp_if_dpnt_ssn_nt_prv_cd
    ,p_rec.susp_if_dpnt_dob_nt_prv_cd
    ,p_rec.susp_if_dpnt_adr_nt_prv_cd
    ,p_rec.susp_if_ctfn_not_dpnt_flag
    ,p_rec.susp_if_bnf_ssn_nt_prv_cd
    ,p_rec.susp_if_bnf_dob_nt_prv_cd
    ,p_rec.susp_if_bnf_adr_nt_prv_cd
    ,p_rec.susp_if_ctfn_not_bnf_flag
    ,p_rec.dpnt_ctfn_determine_cd
    ,p_rec.bnf_ctfn_determine_cd
    ,p_rec.object_version_number
    ,p_rec.actl_prem_id
    ,p_rec.vrfy_fmly_mmbr_cd
    ,p_rec.vrfy_fmly_mmbr_rl
    ,l_created_by
    ,l_creation_date
    ,l_last_update_date
    ,l_last_updated_by
    ,l_last_update_login
    ,p_rec.alws_tmpry_id_crd_flag
    ,p_rec.nip_dflt_flag
    ,p_rec.frfs_distr_mthd_cd
    ,p_rec.frfs_distr_mthd_rl
    ,p_rec.frfs_cntr_det_cd
    ,p_rec.frfs_distr_det_cd
    ,p_rec.cost_alloc_keyflex_1_id
    ,p_rec.cost_alloc_keyflex_2_id
    ,p_rec.post_to_gl_flag
    ,p_rec.frfs_val_det_cd
    ,p_rec.frfs_mx_cryfwd_val
    ,p_rec.frfs_portion_det_cd
    ,p_rec.bndry_perd_cd
    ,p_rec.short_name
    ,p_rec.short_code
    ,p_rec.legislation_code
    ,p_rec.legislation_subgroup
    ,p_rec.group_pl_id
    ,p_rec.mapping_table_name
    ,p_rec.mapping_table_pk_id
    ,p_rec.function_code
    ,p_rec.pl_yr_not_applcbl_flag
    ,p_rec.use_csd_rsd_prccng_cd
    );
  --
  ben_pln_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_pln_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pln_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_pln_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pln_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_pln_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
    (p_rec              in out nocopy ben_pln_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc    varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_insert_dml(p_rec            => p_rec,
        p_effective_date    => p_effective_date,
        p_datetrack_mode    => p_datetrack_mode,
               p_validation_start_date    => p_validation_start_date,
        p_validation_end_date    => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--   Also, if comments are defined for this entity, the comments insert
--   logic will also be called, generating a comment_id if required.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
    (p_rec              in out nocopy ben_pln_shd.g_rec_type,
     p_effective_date        in date,
     p_datetrack_mode        in varchar2,
     p_validation_start_date    in date,
     p_validation_end_date        in date) is
  --
  l_proc    varchar2(72) := g_package||'pre_insert';
  --
  cursor c1 is
    select ben_pl_f_s.nextval
    from   sys.dual;
  --
 cursor c_pln_typ_opt_typ_cd is
  select opt_typ_cd
  from   ben_pl_typ_f
  where  pl_typ_id = p_rec.pl_typ_id
  and    business_group_id = p_rec.business_group_id
  and    p_effective_date
         between effective_start_date
         and     effective_end_date
   ;

  l_opt_typ_cd  ben_pl_typ_f.opt_typ_cd%type ;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
    --
    fetch c1 into p_rec.pl_id;
    --
  close c1;
  --- if CWB and the group_pl_id is null then assign the pl_id and mke it parent
  if p_rec.group_pl_id is null then
     open c_pln_typ_opt_typ_cd ;
     fetch c_pln_typ_opt_typ_cd into l_opt_typ_cd ;
     close c_pln_typ_opt_typ_cd  ;
     if l_opt_typ_cd = 'CWB' then
         p_rec.group_pl_id := p_rec.pl_id;
      hr_utility.set_location('CWB parent plan id :'|| p_rec.group_pl_id, 5);
     --
--ICM Changes
     elsif l_opt_typ_cd = 'ICM' then
        --
	 p_rec.alws_unrstrctd_enrt_flag := 'Y';
	 p_rec.nip_enrt_info_rt_freq_cd := 'PP';
	 p_rec.enrt_cvg_strt_dt_cd := 'AED';
	 p_rec.enrt_cvg_end_dt_cd := 'ODBED';
	 p_rec.trk_inelig_per_flag := 'Y';
        --
     end if;
     --
--ICM Changes
  end if ;
  --
  --Bug : 3460429
  ben_pln_bus.chk_pl_group_id(p_pl_id             => p_rec.pl_id,
                              p_group_pl_id       => p_rec.group_pl_id,
                              p_pl_typ_id         => p_rec.pl_typ_id,
                              p_effective_date    => p_effective_date,
                              p_name              => p_rec.name
                              ) ;
  --Bug : 3460429
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
    (p_rec              in ben_pln_shd.g_rec_type,
     p_effective_date     in date,
     p_datetrack_mode     in varchar2,
     p_validation_start_date in date,
     p_validation_end_date     in date) is
--
  l_proc    varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_insert.
  --
  -- Added for GSP validations
  pqh_gsp_ben_validations.pl_validations
    	(  p_pl_id			=> p_rec.pl_id
    	 , p_effective_date 		=> p_effective_date
    	 , p_business_group_id  	=> p_rec.business_group_id
    	 , p_dml_operation 		=> 'I'
    	 , p_pl_Typ_Id			=> p_rec.pl_Typ_Id
    	 , p_Mapping_Table_PK_ID	=> p_rec.Mapping_Table_PK_ID
    	 , p_pl_stat_cd			=> p_rec.pl_stat_cd
    	 );


  begin
    --

    --

    ben_pln_rki.after_insert
    (
      p_pl_id                         => p_rec.pl_id
     ,p_effective_start_date          => p_rec.effective_start_date
     ,p_effective_end_date            => p_rec.effective_end_date
     ,p_name                          => p_rec.name
     ,p_alws_qdro_flag                => p_rec.alws_qdro_flag
     ,p_alws_qmcso_flag               => p_rec.alws_qmcso_flag
     ,p_alws_reimbmts_flag            => p_rec.alws_reimbmts_flag
     ,p_bnf_addl_instn_txt_alwd_flag  => p_rec.bnf_addl_instn_txt_alwd_flag
     ,p_bnf_adrs_rqd_flag             => p_rec.bnf_adrs_rqd_flag
     ,p_bnf_cntngt_bnfs_alwd_flag     => p_rec.bnf_cntngt_bnfs_alwd_flag
     ,p_bnf_ctfn_rqd_flag             => p_rec.bnf_ctfn_rqd_flag
     ,p_bnf_dob_rqd_flag              => p_rec.bnf_dob_rqd_flag
     ,p_bnf_dsge_mnr_ttee_rqd_flag    => p_rec.bnf_dsge_mnr_ttee_rqd_flag
     ,p_bnf_incrmt_amt                => p_rec.bnf_incrmt_amt
     ,p_bnf_dflt_bnf_cd               => p_rec.bnf_dflt_bnf_cd
     ,p_bnf_legv_id_rqd_flag          => p_rec.bnf_legv_id_rqd_flag
     ,p_bnf_may_dsgt_org_flag         => p_rec.bnf_may_dsgt_org_flag
     ,p_bnf_mn_dsgntbl_amt            => p_rec.bnf_mn_dsgntbl_amt
     ,p_bnf_mn_dsgntbl_pct_val        => p_rec.bnf_mn_dsgntbl_pct_val
     ,p_rqd_perd_enrt_nenrt_val       => p_rec.rqd_perd_enrt_nenrt_val
     ,p_ordr_num                      => p_rec.ordr_num
     ,p_bnf_pct_incrmt_val            => p_rec.bnf_pct_incrmt_val
     ,p_bnf_pct_amt_alwd_cd           => p_rec.bnf_pct_amt_alwd_cd
     ,p_bnf_qdro_rl_apls_flag         => p_rec.bnf_qdro_rl_apls_flag
     ,p_dflt_to_asn_pndg_ctfn_cd      => p_rec.dflt_to_asn_pndg_ctfn_cd
     ,p_dflt_to_asn_pndg_ctfn_rl      => p_rec.dflt_to_asn_pndg_ctfn_rl
     ,p_drvbl_fctr_apls_rts_flag      => p_rec.drvbl_fctr_apls_rts_flag
     ,p_drvbl_fctr_prtn_elig_flag     => p_rec.drvbl_fctr_prtn_elig_flag
     ,p_dpnt_dsgn_cd                  => p_rec.dpnt_dsgn_cd
     ,p_elig_apls_flag                => p_rec.elig_apls_flag
     ,p_invk_dcln_prtn_pl_flag        => p_rec.invk_dcln_prtn_pl_flag
     ,p_invk_flx_cr_pl_flag           => p_rec.invk_flx_cr_pl_flag
     ,p_imptd_incm_calc_cd            => p_rec.imptd_incm_calc_cd
     ,p_drvbl_dpnt_elig_flag          => p_rec.drvbl_dpnt_elig_flag
     ,p_trk_inelig_per_flag           => p_rec.trk_inelig_per_flag
     ,p_pl_cd                         => p_rec.pl_cd
     ,p_auto_enrt_mthd_rl             => p_rec.auto_enrt_mthd_rl
     ,p_ivr_ident                     => p_rec.ivr_ident
     ,p_url_ref_name                  => p_rec.url_ref_name
     ,p_cmpr_clms_to_cvg_or_bal_cd    => p_rec.cmpr_clms_to_cvg_or_bal_cd
     ,p_cobra_pymt_due_dy_num         => p_rec.cobra_pymt_due_dy_num
     ,p_dpnt_cvd_by_othr_apls_flag    => p_rec.dpnt_cvd_by_othr_apls_flag
     ,p_enrt_mthd_cd                  => p_rec.enrt_mthd_cd
     ,p_enrt_cd                       => p_rec.enrt_cd
     ,p_enrt_cvg_strt_dt_cd           => p_rec.enrt_cvg_strt_dt_cd
     ,p_enrt_cvg_end_dt_cd            => p_rec.enrt_cvg_end_dt_cd
     ,p_frfs_aply_flag                => p_rec.frfs_aply_flag
     ,p_hc_pl_subj_hcfa_aprvl_flag    => p_rec.hc_pl_subj_hcfa_aprvl_flag
     ,p_hghly_cmpd_rl_apls_flag       => p_rec.hghly_cmpd_rl_apls_flag
     ,p_incptn_dt                     => p_rec.incptn_dt
     ,p_mn_cvg_rl                     => p_rec.mn_cvg_rl
     ,p_mn_cvg_rqd_amt                => p_rec.mn_cvg_rqd_amt
     ,p_mn_opts_rqd_num               => p_rec.mn_opts_rqd_num
     ,p_mx_cvg_alwd_amt               => p_rec.mx_cvg_alwd_amt
     ,p_mx_cvg_rl                     => p_rec.mx_cvg_rl
     ,p_mx_opts_alwd_num              => p_rec.mx_opts_alwd_num
     ,p_mx_cvg_wcfn_mlt_num           => p_rec.mx_cvg_wcfn_mlt_num
     ,p_mx_cvg_wcfn_amt               => p_rec.mx_cvg_wcfn_amt
     ,p_mx_cvg_incr_alwd_amt          => p_rec.mx_cvg_incr_alwd_amt
     ,p_mx_cvg_incr_wcf_alwd_amt      => p_rec.mx_cvg_incr_wcf_alwd_amt
     ,p_mx_cvg_mlt_incr_num           => p_rec.mx_cvg_mlt_incr_num
     ,p_mx_cvg_mlt_incr_wcf_num       => p_rec.mx_cvg_mlt_incr_wcf_num
     ,p_mx_wtg_dt_to_use_cd           => p_rec.mx_wtg_dt_to_use_cd
     ,p_mx_wtg_dt_to_use_rl           => p_rec.mx_wtg_dt_to_use_rl
     ,p_mx_wtg_perd_prte_uom          => p_rec.mx_wtg_perd_prte_uom
     ,p_mx_wtg_perd_prte_val          => p_rec.mx_wtg_perd_prte_val
     ,p_mx_wtg_perd_rl                => p_rec.mx_wtg_perd_rl
     ,p_nip_dflt_enrt_cd              => p_rec.nip_dflt_enrt_cd
     ,p_nip_dflt_enrt_det_rl          => p_rec.nip_dflt_enrt_det_rl
     ,p_dpnt_adrs_rqd_flag            => p_rec.dpnt_adrs_rqd_flag
     ,p_dpnt_cvg_end_dt_cd            => p_rec.dpnt_cvg_end_dt_cd
     ,p_dpnt_cvg_end_dt_rl            => p_rec.dpnt_cvg_end_dt_rl
     ,p_dpnt_cvg_strt_dt_cd           => p_rec.dpnt_cvg_strt_dt_cd
     ,p_dpnt_cvg_strt_dt_rl           => p_rec.dpnt_cvg_strt_dt_rl
     ,p_dpnt_dob_rqd_flag             => p_rec.dpnt_dob_rqd_flag
     ,p_dpnt_leg_id_rqd_flag          => p_rec.dpnt_leg_id_rqd_flag
     ,p_dpnt_no_ctfn_rqd_flag         => p_rec.dpnt_no_ctfn_rqd_flag
     ,p_no_mn_cvg_amt_apls_flag       => p_rec.no_mn_cvg_amt_apls_flag
     ,p_no_mn_cvg_incr_apls_flag      => p_rec.no_mn_cvg_incr_apls_flag
     ,p_no_mn_opts_num_apls_flag      => p_rec.no_mn_opts_num_apls_flag
     ,p_no_mx_cvg_amt_apls_flag       => p_rec.no_mx_cvg_amt_apls_flag
     ,p_no_mx_cvg_incr_apls_flag      => p_rec.no_mx_cvg_incr_apls_flag
     ,p_no_mx_opts_num_apls_flag      => p_rec.no_mx_opts_num_apls_flag
     ,p_nip_pl_uom                    => p_rec.nip_pl_uom
     ,p_rqd_perd_enrt_nenrt_uom       => p_rec.rqd_perd_enrt_nenrt_uom
     ,p_nip_acty_ref_perd_cd          => p_rec.nip_acty_ref_perd_cd
     ,p_nip_enrt_info_rt_freq_cd      => p_rec.nip_enrt_info_rt_freq_cd
     ,p_per_cvrd_cd                   => p_rec.per_cvrd_cd
     ,p_enrt_cvg_end_dt_rl            => p_rec.enrt_cvg_end_dt_rl
     ,p_postelcn_edit_rl              => p_rec.postelcn_edit_rl
     ,p_enrt_cvg_strt_dt_rl           => p_rec.enrt_cvg_strt_dt_rl
     ,p_prort_prtl_yr_cvg_rstrn_cd    => p_rec.prort_prtl_yr_cvg_rstrn_cd
     ,p_prort_prtl_yr_cvg_rstrn_rl    => p_rec.prort_prtl_yr_cvg_rstrn_rl
     ,p_prtn_elig_ovrid_alwd_flag     => p_rec.prtn_elig_ovrid_alwd_flag
     ,p_svgs_pl_flag                  => p_rec.svgs_pl_flag
     ,p_subj_to_imptd_incm_typ_cd     => p_rec.subj_to_imptd_incm_typ_cd
     ,p_use_all_asnts_elig_flag       => p_rec.use_all_asnts_elig_flag
     ,p_use_all_asnts_for_rt_flag     => p_rec.use_all_asnts_for_rt_flag
     ,p_vstg_apls_flag                => p_rec.vstg_apls_flag
     ,p_wvbl_flag                     => p_rec.wvbl_flag
     ,p_hc_svc_typ_cd                 => p_rec.hc_svc_typ_cd
     ,p_pl_stat_cd                    => p_rec.pl_stat_cd
     ,p_prmry_fndg_mthd_cd            => p_rec.prmry_fndg_mthd_cd
     ,p_rt_end_dt_cd                  => p_rec.rt_end_dt_cd
     ,p_rt_end_dt_rl                  => p_rec.rt_end_dt_rl
     ,p_rt_strt_dt_rl                 => p_rec.rt_strt_dt_rl
     ,p_rt_strt_dt_cd                 => p_rec.rt_strt_dt_cd
     ,p_bnf_dsgn_cd                   => p_rec.bnf_dsgn_cd
     ,p_pl_typ_id                     => p_rec.pl_typ_id
     ,p_business_group_id             => p_rec.business_group_id
     ,p_enrt_pl_opt_flag              => p_rec.enrt_pl_opt_flag
     ,p_bnft_prvdr_pool_id            => p_rec.bnft_prvdr_pool_id
     ,p_MAY_ENRL_PL_N_OIPL_FLAG       => p_rec.may_enrl_pl_n_oipl_flag
     ,p_ENRT_RL                       => p_rec.ENRT_RL
     ,p_rqd_perd_enrt_nenrt_rl        => p_rec.rqd_perd_enrt_nENRT_RL
     ,p_ALWS_UNRSTRCTD_ENRT_FLAG      => p_rec.ALWS_UNRSTRCTD_ENRT_FLAG
     ,p_BNFT_OR_OPTION_RSTRCTN_CD     => p_rec.BNFT_OR_OPTION_RSTRCTN_CD
     ,p_CVG_INCR_R_DECR_ONLY_CD       => p_rec.CVG_INCR_R_DECR_ONLY_CD
     ,p_unsspnd_enrt_cd               => p_rec.unsspnd_enrt_cd
     ,p_pln_attribute_category        => p_rec.pln_attribute_category
     ,p_pln_attribute1                => p_rec.pln_attribute1
     ,p_pln_attribute2                => p_rec.pln_attribute2
     ,p_pln_attribute3                => p_rec.pln_attribute3
     ,p_pln_attribute4                => p_rec.pln_attribute4
     ,p_pln_attribute5                => p_rec.pln_attribute5
     ,p_pln_attribute6                => p_rec.pln_attribute6
     ,p_pln_attribute7                => p_rec.pln_attribute7
     ,p_pln_attribute8                => p_rec.pln_attribute8
     ,p_pln_attribute9                => p_rec.pln_attribute9
     ,p_pln_attribute10               => p_rec.pln_attribute10
     ,p_pln_attribute11               => p_rec.pln_attribute11
     ,p_pln_attribute12               => p_rec.pln_attribute12
     ,p_pln_attribute13               => p_rec.pln_attribute13
     ,p_pln_attribute14               => p_rec.pln_attribute14
     ,p_pln_attribute15               => p_rec.pln_attribute15
     ,p_pln_attribute16               => p_rec.pln_attribute16
     ,p_pln_attribute17               => p_rec.pln_attribute17
     ,p_pln_attribute18               => p_rec.pln_attribute18
     ,p_pln_attribute19               => p_rec.pln_attribute19
     ,p_pln_attribute20               => p_rec.pln_attribute20
     ,p_pln_attribute21               => p_rec.pln_attribute21
     ,p_pln_attribute22               => p_rec.pln_attribute22
     ,p_pln_attribute23               => p_rec.pln_attribute23
     ,p_pln_attribute24               => p_rec.pln_attribute24
     ,p_pln_attribute25               => p_rec.pln_attribute25
     ,p_pln_attribute26               => p_rec.pln_attribute26
     ,p_pln_attribute27               => p_rec.pln_attribute27
     ,p_pln_attribute28               => p_rec.pln_attribute28
     ,p_pln_attribute29               => p_rec.pln_attribute29
     ,p_pln_attribute30               => p_rec.pln_attribute30
     ,p_susp_if_ctfn_not_prvd_flag    => p_rec.susp_if_ctfn_not_prvd_flag
     ,p_ctfn_determine_cd             => p_rec.ctfn_determine_cd
     ,p_susp_if_dpnt_ssn_nt_prv_cd    => p_rec.susp_if_dpnt_ssn_nt_prv_cd
     ,p_susp_if_dpnt_dob_nt_prv_cd    => p_rec.susp_if_dpnt_dob_nt_prv_cd
     ,p_susp_if_dpnt_adr_nt_prv_cd    => p_rec.susp_if_dpnt_adr_nt_prv_cd
     ,p_susp_if_ctfn_not_dpnt_flag    => p_rec.susp_if_ctfn_not_dpnt_flag
     ,p_susp_if_bnf_ssn_nt_prv_cd     => p_rec.susp_if_bnf_ssn_nt_prv_cd
     ,p_susp_if_bnf_dob_nt_prv_cd     => p_rec.susp_if_bnf_dob_nt_prv_cd
     ,p_susp_if_bnf_adr_nt_prv_cd     => p_rec.susp_if_bnf_adr_nt_prv_cd
     ,p_susp_if_ctfn_not_bnf_flag     => p_rec.susp_if_ctfn_not_bnf_flag
     ,p_dpnt_ctfn_determine_cd        => p_rec.dpnt_ctfn_determine_cd
     ,p_bnf_ctfn_determine_cd         => p_rec.bnf_ctfn_determine_cd
     ,p_object_version_number         => p_rec.object_version_number
     ,p_effective_date                => p_effective_date
     ,p_validation_start_date         => p_validation_start_date
     ,p_validation_end_date           => p_validation_end_date
     ,p_actl_prem_id                  => p_rec.actl_prem_id
     ,p_vrfy_fmly_mmbr_cd             => p_rec.vrfy_fmly_mmbr_cd
     ,p_vrfy_fmly_mmbr_rl             => p_rec.vrfy_fmly_mmbr_rl
     ,p_ALWS_TMPRY_ID_CRD_FLAG        => p_rec.ALWS_TMPRY_ID_CRD_FLAG
     ,p_nip_dflt_flag                 => p_rec.nip_dflt_flag
     ,p_frfs_distr_mthd_cd            =>  p_rec.frfs_distr_mthd_cd
     ,p_frfs_distr_mthd_rl            =>  p_rec.frfs_distr_mthd_rl
     ,p_frfs_cntr_det_cd              =>  p_rec.frfs_cntr_det_cd
     ,p_frfs_distr_det_cd             =>  p_rec.frfs_distr_det_cd
     ,p_cost_alloc_keyflex_1_id       =>  p_rec.cost_alloc_keyflex_1_id
     ,p_cost_alloc_keyflex_2_id       =>  p_rec.cost_alloc_keyflex_2_id
     ,p_post_to_gl_flag               =>  p_rec.post_to_gl_flag
     ,p_frfs_val_det_cd               =>  p_rec.frfs_val_det_cd
     ,p_frfs_mx_cryfwd_val            =>  p_rec.frfs_mx_cryfwd_val
     ,p_frfs_portion_det_cd           =>  p_rec.frfs_portion_det_cd
     ,p_bndry_perd_cd                 =>  p_rec.bndry_perd_cd
     ,p_short_name                    =>  p_rec.short_name
     ,p_short_code                    =>  p_rec.short_code
     ,p_legislation_code              =>  p_rec.legislation_code
     ,p_legislation_subgroup          =>  p_rec.legislation_subgroup
     ,p_group_pl_id                   =>  p_rec.group_pl_id
     ,p_mapping_table_name            =>  p_rec.mapping_table_name
     ,p_mapping_table_pk_id           =>  p_rec.mapping_table_pk_id
     ,p_function_code                 =>  p_rec.function_code
     ,p_pl_yr_not_applcbl_flag        =>  p_rec.pl_yr_not_applcbl_flag
     ,p_use_csd_rsd_prccng_cd         =>  p_rec.use_csd_rsd_prccng_cd
    );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_pl_f'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_lck >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The ins_lck process has one main function to perform. When inserting
--   a datetracked row, we must validate the DT mode.
--   be manipulated.
--
-- Prerequisites:
--   This procedure can only be called for the datetrack mode of INSERT.
--
-- In Parameters:
--
-- Post Success:
--   On successful completion of the ins_lck process the parental
--   datetracked rows will be locked providing the p_enforce_foreign_locking
--   argument value is TRUE.
--   If the p_enforce_foreign_locking argument value is FALSE then the
--   parential rows are not locked.
--
-- Post Failure:
--   The Lck process can fail for:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) When attempting to the lock the parent which doesn't exist.
--      For the entity to be locked the parent must exist!
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins_lck
    (p_effective_date     in  date,
     p_datetrack_mode     in  varchar2,
     p_rec              in  ben_pln_shd.g_rec_type,
     p_validation_start_date out nocopy date,
     p_validation_end_date     out nocopy date) is
--
  l_proc           varchar2(72) := g_package||'ins_lck';
  l_validation_start_date  date;
  l_validation_end_date       date;
  l_validation_start_date1 date;
  l_validation_end_date1   date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate the datetrack mode mode getting the validation start
  -- and end dates for the specified datetrack operation.
  --
  dt_api.validate_dt_mode
    (p_effective_date       => p_effective_date,
     p_datetrack_mode       => p_datetrack_mode,
     p_base_table_name       => 'ben_pl_f',
     p_base_key_column       => 'pl_id',
     p_base_key_value        => p_rec.pl_id,
     p_parent_table_name1      => 'ff_formulas_f',
     p_parent_key_column1      => 'formula_id',
     p_parent_key_value1       => p_rec.auto_enrt_mthd_rl,
     p_parent_table_name2      => 'ff_formulas_f',
     p_parent_key_column2      => 'formula_id',
     p_parent_key_value2       => p_rec.mn_cvg_rl,
     p_parent_table_name3      => 'ff_formulas_f',
     p_parent_key_column3      => 'formula_id',
     p_parent_key_value3       => p_rec.mx_cvg_rl,
     p_parent_table_name4      => 'ff_formulas_f',
     p_parent_key_column4      => 'formula_id',
     p_parent_key_value4       => p_rec.mx_wtg_perd_rl,
     p_parent_table_name5      => 'ff_formulas_f',
     p_parent_key_column5      => 'formula_id',
     p_parent_key_value5       => p_rec.dpnt_cvg_strt_dt_rl,
     p_parent_table_name6      => 'ff_formulas_f',
     p_parent_key_column6      => 'formula_id',
     p_parent_key_value6       => p_rec.dpnt_cvg_end_dt_rl,
     p_parent_table_name7      => 'ff_formulas_f',
     p_parent_key_column7      => 'formula_id',
     p_parent_key_value7       => p_rec.postelcn_edit_rl,
     p_parent_table_name8      => 'ff_formulas_f',
     p_parent_key_column8      => 'formula_id',
     p_parent_key_value8       => p_rec.enrt_cvg_strt_dt_rl,
     p_parent_table_name9      => 'ff_formulas_f',
     p_parent_key_column9      => 'formula_id',
     p_parent_key_value9       => p_rec.enrt_cvg_end_dt_rl,
     p_parent_table_name10      => 'ff_formulas_f',
     p_parent_key_column10      => 'formula_id',
     p_parent_key_value10       => p_rec.prort_prtl_yr_cvg_rstrn_rl,
     p_enforce_foreign_locking => true,
     p_validation_start_date   => l_validation_start_date,
     p_validation_end_date       => l_validation_end_date);
  --
  dt_api.validate_dt_mode
    (p_effective_date       => p_effective_date,
     p_datetrack_mode       => p_datetrack_mode,
     p_base_table_name       => 'ben_pl_f',
     p_base_key_column       => 'pl_id',
     p_base_key_value        => p_rec.pl_id,
     p_parent_table_name1      => 'ff_formulas_f',
     p_parent_key_column1      => 'formula_id',
     p_parent_key_value1       => p_rec.rt_end_dt_rl,
     p_parent_table_name2      => 'ff_formulas_f',
     p_parent_key_column2      => 'formula_id',
     p_parent_key_value2       => p_rec.rt_strt_dt_rl,
     p_parent_table_name3      => 'ben_pl_typ_f',
     p_parent_key_column3      => 'pl_typ_id',
     p_parent_key_value3       => p_rec.pl_typ_id,
     p_parent_table_name4      => 'ff_formulas_f',
     p_parent_key_column4      => 'formula_id',
     p_parent_key_value4       => p_rec.nip_dflt_enrt_det_rl,
     p_parent_table_name5      => 'ff_formulas_f',
     p_parent_key_column5      => 'formula_id',
     p_parent_key_value5       => p_rec.mx_wtg_dt_to_use_rl,
     p_parent_table_name6      => 'ben_bnft_prvdr_pool_f',
     p_parent_key_column6      => 'bnft_prvdr_pool_id',
     p_parent_key_value6       => p_rec.bnft_prvdr_pool_id,
     p_parent_table_name7      => 'ff_formulas_f',
     p_parent_key_column7      => 'formula_id',
     p_parent_key_value7       => p_rec.ENRT_RL,
     p_enforce_foreign_locking => true,
     p_validation_start_date   => l_validation_start_date1,
     p_validation_end_date       => l_validation_end_date1);
  --
  -- Set the validation start and end date OUT arguments
  --
  if l_validation_start_date > l_validation_start_date1 then
    --
    p_validation_start_date := l_validation_start_date;
    --
  else
    --
    p_validation_start_date := l_validation_start_date1;
    --
  end if;
  --
  if l_validation_end_date > l_validation_end_date1 then
    --
    p_validation_end_date := l_validation_end_date1;
    --
  else
    --
    p_validation_end_date := l_validation_end_date;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End ins_lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec           in out nocopy ben_pln_shd.g_rec_type,
  p_effective_date in     date
  ) is
--
  l_proc            varchar2(72) := g_package||'ins';
  l_datetrack_mode        varchar2(30) := 'INSERT';
  l_validation_start_date    date;
  l_validation_end_date        date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the lock operation
  --
  ins_lck
    (p_effective_date     => p_effective_date,
     p_datetrack_mode     => l_datetrack_mode,
     p_rec              => p_rec,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  --
  -- Call the supporting insert validate operations
  --
  ben_pln_bus.insert_validate
    (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => l_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert
     (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => l_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  -- Insert the row
  --
  insert_dml
     (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => l_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  -- Call the supporting post-insert operation
  --
  post_insert
     (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => l_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_pl_id                        out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_name                         in varchar2,
  p_alws_qdro_flag               in varchar2         ,
  p_alws_qmcso_flag              in varchar2         ,
  p_alws_reimbmts_flag           in varchar2         ,
  p_bnf_addl_instn_txt_alwd_flag in varchar2         ,
  p_bnf_adrs_rqd_flag            in varchar2         ,
  p_bnf_cntngt_bnfs_alwd_flag    in varchar2         ,
  p_bnf_ctfn_rqd_flag            in varchar2         ,
  p_bnf_dob_rqd_flag             in varchar2         ,
  p_bnf_dsge_mnr_ttee_rqd_flag   in varchar2         ,
  p_bnf_incrmt_amt               in number           ,
  p_bnf_dflt_bnf_cd              in varchar2         ,
  p_bnf_legv_id_rqd_flag         in varchar2         ,
  p_bnf_may_dsgt_org_flag        in varchar2         ,
  p_bnf_mn_dsgntbl_amt           in number           ,
  p_bnf_mn_dsgntbl_pct_val       in number           ,
  p_rqd_perd_enrt_nenrt_val      in number           ,
  p_ordr_num                     in number           ,
  p_bnf_pct_incrmt_val           in number           ,
  p_bnf_pct_amt_alwd_cd          in varchar2         ,
  p_bnf_qdro_rl_apls_flag        in varchar2         ,
  p_dflt_to_asn_pndg_ctfn_cd     in varchar2         ,
  p_dflt_to_asn_pndg_ctfn_rl     in number           ,
  p_drvbl_fctr_apls_rts_flag     in varchar2         ,
  p_drvbl_fctr_prtn_elig_flag    in varchar2         ,
  p_dpnt_dsgn_cd                 in varchar2         ,
  p_elig_apls_flag               in varchar2         ,
  p_invk_dcln_prtn_pl_flag       in varchar2         ,
  p_invk_flx_cr_pl_flag          in varchar2         ,
  p_imptd_incm_calc_cd           in varchar2         ,
  p_drvbl_dpnt_elig_flag         in varchar2         ,
  p_trk_inelig_per_flag          in varchar2         ,
  p_pl_cd                        in varchar2	     ,
  p_auto_enrt_mthd_rl            in number           ,
  p_ivr_ident                    in varchar2         ,
  p_url_ref_name                 in varchar2         ,
  p_cmpr_clms_to_cvg_or_bal_cd   in varchar2         ,
  p_cobra_pymt_due_dy_num        in number           ,
  p_dpnt_cvd_by_othr_apls_flag   in varchar2         ,
  p_enrt_mthd_cd                 in varchar2         ,
  p_enrt_cd                      in varchar2         ,
  p_enrt_cvg_strt_dt_cd          in varchar2         ,
  p_enrt_cvg_end_dt_cd           in varchar2         ,
  p_frfs_aply_flag               in varchar2         ,
  p_hc_pl_subj_hcfa_aprvl_flag   in varchar2         ,
  p_hghly_cmpd_rl_apls_flag      in varchar2         ,
  p_incptn_dt                    in date             ,
  p_mn_cvg_rl                    in number           ,
  p_mn_cvg_rqd_amt               in number           ,
  p_mn_opts_rqd_num              in number           ,
  p_mx_cvg_alwd_amt              in number           ,
  p_mx_cvg_rl                    in number           ,
  p_mx_opts_alwd_num             in number           ,
  p_mx_cvg_wcfn_mlt_num          in number           ,
  p_mx_cvg_wcfn_amt              in number           ,
  p_mx_cvg_incr_alwd_amt         in number           ,
  p_mx_cvg_incr_wcf_alwd_amt     in number           ,
  p_mx_cvg_mlt_incr_num          in number           ,
  p_mx_cvg_mlt_incr_wcf_num      in number           ,
  p_mx_wtg_dt_to_use_cd          in varchar2         ,
  p_mx_wtg_dt_to_use_rl          in number           ,
  p_mx_wtg_perd_prte_uom         in varchar2         ,
  p_mx_wtg_perd_prte_val         in number           ,
  p_mx_wtg_perd_rl               in number           ,
  p_nip_dflt_enrt_cd             in varchar2         ,
  p_nip_dflt_enrt_det_rl         in number           ,
  p_dpnt_adrs_rqd_flag           in varchar2         ,
  p_dpnt_cvg_end_dt_cd           in varchar2         ,
  p_dpnt_cvg_end_dt_rl           in number           ,
  p_dpnt_cvg_strt_dt_cd          in varchar2         ,
  p_dpnt_cvg_strt_dt_rl          in number           ,
  p_dpnt_dob_rqd_flag            in varchar2         ,
  p_dpnt_leg_id_rqd_flag         in varchar2         ,
  p_dpnt_no_ctfn_rqd_flag        in varchar2         ,
  p_no_mn_cvg_amt_apls_flag      in varchar2         ,
  p_no_mn_cvg_incr_apls_flag     in varchar2         ,
  p_no_mn_opts_num_apls_flag     in varchar2         ,
  p_no_mx_cvg_amt_apls_flag      in varchar2         ,
  p_no_mx_cvg_incr_apls_flag     in varchar2         ,
  p_no_mx_opts_num_apls_flag     in varchar2         ,
  p_nip_pl_uom                   in varchar2         ,
  p_rqd_perd_enrt_nenrt_uom      in varchar2         ,
  p_nip_acty_ref_perd_cd         in varchar2         ,
  p_nip_enrt_info_rt_freq_cd     in varchar2         ,
  p_per_cvrd_cd                  in varchar2         ,
  p_enrt_cvg_end_dt_rl           in number           ,
  p_postelcn_edit_rl             in number           ,
  p_enrt_cvg_strt_dt_rl          in number           ,
  p_prort_prtl_yr_cvg_rstrn_cd   in varchar2         ,
  p_prort_prtl_yr_cvg_rstrn_rl   in number           ,
  p_prtn_elig_ovrid_alwd_flag    in varchar2         ,
  p_svgs_pl_flag                 in varchar2         ,
  p_subj_to_imptd_incm_typ_cd    in varchar2         ,
  p_use_all_asnts_elig_flag      in varchar2         ,
  p_use_all_asnts_for_rt_flag    in varchar2         ,
  p_vstg_apls_flag               in varchar2         ,
  p_wvbl_flag                    in varchar2         ,
  p_hc_svc_typ_cd                in varchar2         ,
  p_pl_stat_cd                   in varchar2         ,
  p_prmry_fndg_mthd_cd           in varchar2         ,
  p_rt_end_dt_cd                 in varchar2         ,
  p_rt_end_dt_rl                 in number           ,
  p_rt_strt_dt_rl                in number           ,
  p_rt_strt_dt_cd                in varchar2         ,
  p_bnf_dsgn_cd                  in varchar2         ,
  p_pl_typ_id                    in number,
  p_business_group_id            in number,
  p_enrt_pl_opt_flag             in varchar2,
  p_bnft_prvdr_pool_id           in number,
  p_MAY_ENRL_PL_N_OIPL_FLAG      in VARCHAR2,
  p_ENRT_RL                      in NUMBER,
  p_rqd_perd_enrt_nenrt_rl       in NUMBER,
  p_ALWS_UNRSTRCTD_ENRT_FLAG     in VARCHAR2,
  p_BNFT_OR_OPTION_RSTRCTN_CD    in VARCHAR2,
  p_CVG_INCR_R_DECR_ONLY_CD      in VARCHAR2,
  p_unsspnd_enrt_cd              in varchar2         ,
  p_pln_attribute_category       in varchar2         ,
  p_pln_attribute1               in varchar2         ,
  p_pln_attribute2               in varchar2         ,
  p_pln_attribute3               in varchar2         ,
  p_pln_attribute4               in varchar2         ,
  p_pln_attribute5               in varchar2         ,
  p_pln_attribute6               in varchar2         ,
  p_pln_attribute7               in varchar2         ,
  p_pln_attribute8               in varchar2         ,
  p_pln_attribute9               in varchar2         ,
  p_pln_attribute10              in varchar2         ,
  p_pln_attribute11              in varchar2         ,
  p_pln_attribute12              in varchar2         ,
  p_pln_attribute13              in varchar2         ,
  p_pln_attribute14              in varchar2         ,
  p_pln_attribute15              in varchar2         ,
  p_pln_attribute16              in varchar2         ,
  p_pln_attribute17              in varchar2         ,
  p_pln_attribute18              in varchar2         ,
  p_pln_attribute19              in varchar2         ,
  p_pln_attribute20              in varchar2         ,
  p_pln_attribute21              in varchar2         ,
  p_pln_attribute22              in varchar2         ,
  p_pln_attribute23              in varchar2         ,
  p_pln_attribute24              in varchar2         ,
  p_pln_attribute25              in varchar2         ,
  p_pln_attribute26              in varchar2         ,
  p_pln_attribute27              in varchar2         ,
  p_pln_attribute28              in varchar2         ,
  p_pln_attribute29              in varchar2         ,
  p_pln_attribute30              in varchar2         ,
  p_susp_if_ctfn_not_prvd_flag     in  varchar2 ,
  p_ctfn_determine_cd              in  varchar2 ,
  p_susp_if_dpnt_ssn_nt_prv_cd     in  varchar2 ,
  p_susp_if_dpnt_dob_nt_prv_cd     in  varchar2 ,
  p_susp_if_dpnt_adr_nt_prv_cd     in  varchar2 ,
  p_susp_if_ctfn_not_dpnt_flag     in  varchar2 ,
  p_susp_if_bnf_ssn_nt_prv_cd      in  varchar2 ,
  p_susp_if_bnf_dob_nt_prv_cd      in  varchar2 ,
  p_susp_if_bnf_adr_nt_prv_cd      in  varchar2 ,
  p_susp_if_ctfn_not_bnf_flag      in  varchar2 ,
  p_dpnt_ctfn_determine_cd         in  varchar2 ,
  p_bnf_ctfn_determine_cd          in  varchar2 ,
  p_object_version_number        out nocopy number,
  p_actl_prem_id                 in number           ,
  p_effective_date               in date,
  p_vrfy_fmly_mmbr_cd            in varchar2         ,
  p_vrfy_fmly_mmbr_rl            in number           ,
  p_ALWS_TMPRY_ID_CRD_FLAG       in VARCHAR2,
  p_nip_dflt_flag                in varchar2         ,
  p_frfs_distr_mthd_cd           in  varchar2  ,
  p_frfs_distr_mthd_rl           in  number    ,
  p_frfs_cntr_det_cd             in  varchar2  ,
  p_frfs_distr_det_cd            in  varchar2  ,
  p_cost_alloc_keyflex_1_id      in  number    ,
  p_cost_alloc_keyflex_2_id      in  number    ,
  p_post_to_gl_flag              in  varchar2  ,
  p_frfs_val_det_cd              in  varchar2  ,
  p_frfs_mx_cryfwd_val           in  number    ,
  p_frfs_portion_det_cd          in  varchar2  ,
  p_bndry_perd_cd                in  varchar2  ,
  p_short_name			 in  varchar2 ,
  p_short_code			 in  varchar2,
  p_legislation_code		 in  varchar2,
  p_legislation_subgroup	 in  varchar2,
  p_group_pl_id			 in  number,
  p_mapping_table_name           in  varchar2,
  p_mapping_table_pk_id          in  number,
  p_function_code                in  varchar2,
  p_pl_yr_not_applcbl_flag       in  varchar2,
  p_use_csd_rsd_prccng_cd        in  varchar2

    ) is
--
  l_rec        ben_pln_shd.g_rec_type;
  l_proc    varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_pln_shd.convert_args
  (
     null
    ,null
    ,null
    ,p_name
    ,p_alws_qdro_flag
    ,p_alws_qmcso_flag
    ,p_alws_reimbmts_flag
    ,p_bnf_addl_instn_txt_alwd_flag
    ,p_bnf_adrs_rqd_flag
    ,p_bnf_cntngt_bnfs_alwd_flag
    ,p_bnf_ctfn_rqd_flag
    ,p_bnf_dob_rqd_flag
    ,p_bnf_dsge_mnr_ttee_rqd_flag
    ,p_bnf_incrmt_amt
    ,p_bnf_dflt_bnf_cd
    ,p_bnf_legv_id_rqd_flag
    ,p_bnf_may_dsgt_org_flag
    ,p_bnf_mn_dsgntbl_amt
    ,p_bnf_mn_dsgntbl_pct_val
    ,p_rqd_perd_enrt_nenrt_val
    ,p_ordr_num
    ,p_bnf_pct_incrmt_val
    ,p_bnf_pct_amt_alwd_cd
    ,p_bnf_qdro_rl_apls_flag
    ,p_dflt_to_asn_pndg_ctfn_cd
    ,p_dflt_to_asn_pndg_ctfn_rl
    ,p_drvbl_fctr_apls_rts_flag
    ,p_drvbl_fctr_prtn_elig_flag
    ,p_dpnt_dsgn_cd
    ,p_elig_apls_flag
    ,p_invk_dcln_prtn_pl_flag
    ,p_invk_flx_cr_pl_flag
    ,p_imptd_incm_calc_cd
    ,p_drvbl_dpnt_elig_flag
    ,p_trk_inelig_per_flag
    ,p_pl_cd
    ,p_auto_enrt_mthd_rl
    ,p_ivr_ident
    ,p_url_ref_name
    ,p_cmpr_clms_to_cvg_or_bal_cd
    ,p_cobra_pymt_due_dy_num
    ,p_dpnt_cvd_by_othr_apls_flag
    ,p_enrt_mthd_cd
    ,p_enrt_cd
    ,p_enrt_cvg_strt_dt_cd
    ,p_enrt_cvg_end_dt_cd
    ,p_frfs_aply_flag
    ,p_hc_pl_subj_hcfa_aprvl_flag
    ,p_hghly_cmpd_rl_apls_flag
    ,p_incptn_dt
    ,p_mn_cvg_rl
    ,p_mn_cvg_rqd_amt
    ,p_mn_opts_rqd_num
    ,p_mx_cvg_alwd_amt
    ,p_mx_cvg_rl
    ,p_mx_opts_alwd_num
    ,p_mx_cvg_wcfn_mlt_num
    ,p_mx_cvg_wcfn_amt
    ,p_mx_cvg_incr_alwd_amt
    ,p_mx_cvg_incr_wcf_alwd_amt
    ,p_mx_cvg_mlt_incr_num
    ,p_mx_cvg_mlt_incr_wcf_num
    ,p_mx_wtg_dt_to_use_cd
    ,p_mx_wtg_dt_to_use_rl
    ,p_mx_wtg_perd_prte_uom
    ,p_mx_wtg_perd_prte_val
    ,p_mx_wtg_perd_rl
    ,p_nip_dflt_enrt_cd
    ,p_nip_dflt_enrt_det_rl
    ,p_dpnt_adrs_rqd_flag
    ,p_dpnt_cvg_end_dt_cd
    ,p_dpnt_cvg_end_dt_rl
    ,p_dpnt_cvg_strt_dt_cd
    ,p_dpnt_cvg_strt_dt_rl
    ,p_dpnt_dob_rqd_flag
    ,p_dpnt_leg_id_rqd_flag
    ,p_dpnt_no_ctfn_rqd_flag
    ,p_no_mn_cvg_amt_apls_flag
    ,p_no_mn_cvg_incr_apls_flag
    ,p_no_mn_opts_num_apls_flag
    ,p_no_mx_cvg_amt_apls_flag
    ,p_no_mx_cvg_incr_apls_flag
    ,p_no_mx_opts_num_apls_flag
    ,p_nip_pl_uom
    ,p_rqd_perd_enrt_nenrt_uom
    ,p_nip_acty_ref_perd_cd
    ,p_nip_enrt_info_rt_freq_cd
    ,p_per_cvrd_cd
    ,p_enrt_cvg_end_dt_rl
    ,p_postelcn_edit_rl
    ,p_enrt_cvg_strt_dt_rl
    ,p_prort_prtl_yr_cvg_rstrn_cd
    ,p_prort_prtl_yr_cvg_rstrn_rl
    ,p_prtn_elig_ovrid_alwd_flag
    ,p_svgs_pl_flag
    ,p_subj_to_imptd_incm_typ_cd
    ,p_use_all_asnts_elig_flag
    ,p_use_all_asnts_for_rt_flag
    ,p_vstg_apls_flag
    ,p_wvbl_flag
    ,p_hc_svc_typ_cd
    ,p_pl_stat_cd
    ,p_prmry_fndg_mthd_cd
    ,p_rt_end_dt_cd
    ,p_rt_end_dt_rl
    ,p_rt_strt_dt_rl
    ,p_rt_strt_dt_cd
    ,p_bnf_dsgn_cd
    ,p_pl_typ_id
    ,p_business_group_id
    ,p_enrt_pl_opt_flag
    ,p_bnft_prvdr_pool_id
    ,p_MAY_ENRL_PL_N_OIPL_FLAG
    ,p_ENRT_RL
    ,p_rqd_perd_enrt_nenrt_rl
    ,p_ALWS_UNRSTRCTD_ENRT_FLAG
    ,p_BNFT_OR_OPTION_RSTRCTN_CD
    ,p_CVG_INCR_R_DECR_ONLY_CD
    ,p_unsspnd_enrt_cd
    ,p_pln_attribute_category
    ,p_pln_attribute1
    ,p_pln_attribute2
    ,p_pln_attribute3
    ,p_pln_attribute4
    ,p_pln_attribute5
    ,p_pln_attribute6
    ,p_pln_attribute7
    ,p_pln_attribute8
    ,p_pln_attribute9
    ,p_pln_attribute10
    ,p_pln_attribute11
    ,p_pln_attribute12
    ,p_pln_attribute13
    ,p_pln_attribute14
    ,p_pln_attribute15
    ,p_pln_attribute16
    ,p_pln_attribute17
    ,p_pln_attribute18
    ,p_pln_attribute19
    ,p_pln_attribute20
    ,p_pln_attribute21
    ,p_pln_attribute22
    ,p_pln_attribute23
    ,p_pln_attribute24
    ,p_pln_attribute25
    ,p_pln_attribute26
    ,p_pln_attribute27
    ,p_pln_attribute28
    ,p_pln_attribute29
    ,p_pln_attribute30
    ,p_susp_if_ctfn_not_prvd_flag
    ,p_ctfn_determine_cd
    ,p_susp_if_dpnt_ssn_nt_prv_cd
    ,p_susp_if_dpnt_dob_nt_prv_cd
    ,p_susp_if_dpnt_adr_nt_prv_cd
    ,p_susp_if_ctfn_not_dpnt_flag
    ,p_susp_if_bnf_ssn_nt_prv_cd
    ,p_susp_if_bnf_dob_nt_prv_cd
    ,p_susp_if_bnf_adr_nt_prv_cd
    ,p_susp_if_ctfn_not_bnf_flag
    ,p_dpnt_ctfn_determine_cd
    ,p_bnf_ctfn_determine_cd
    ,null
    ,p_actl_prem_id
    ,p_vrfy_fmly_mmbr_cd
    ,p_vrfy_fmly_mmbr_rl
    ,p_ALWS_TMPRY_ID_CRD_FLAG
    ,p_nip_dflt_flag
    ,p_frfs_distr_mthd_cd
    ,p_frfs_distr_mthd_rl
    ,p_frfs_cntr_det_cd
    ,p_frfs_distr_det_cd
    ,p_cost_alloc_keyflex_1_id
    ,p_cost_alloc_keyflex_2_id
    ,p_post_to_gl_flag
    ,p_frfs_val_det_cd
    ,p_frfs_mx_cryfwd_val
    ,p_frfs_portion_det_cd
    ,p_bndry_perd_cd
    ,p_short_name
    ,p_short_code
    ,p_legislation_code
    ,p_legislation_subgroup
    ,p_group_pl_id
    ,p_mapping_table_name
    ,p_mapping_table_pk_id
    ,p_function_code
    ,p_pl_yr_not_applcbl_flag
    ,p_use_csd_rsd_prccng_cd

  );
  --
  -- Having converted the arguments into the ben_pln_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ins(l_rec, p_effective_date);
  --
  -- Set the OUT arguments.
  --
  p_pl_id            := l_rec.pl_id;
  p_effective_start_date      := l_rec.effective_start_date;
  p_effective_end_date        := l_rec.effective_end_date;
  p_object_version_number     := l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_pln_ins;

/

--------------------------------------------------------
--  DDL for Package Body BEN_PLN_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLN_UPD" as
/* $Header: beplnrhi.pkb 120.8.12010000.2 2008/08/18 09:47:19 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  ben_pln_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_update_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of dml from the datetrack mode
--   of CORRECTION only. It is important to note that the object version
--   number is only increment by 1 because the datetrack correction is
--   soley for one datetracked row.
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1) Get the next object_version_number.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   update_dml procedure.
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
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_dml
    (p_rec              in out nocopy ben_pln_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc    varchar2(72) := g_package||'dt_update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode = 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
      (p_base_table_name    => 'ben_pl_f',
       p_base_key_column    => 'pl_id',
       p_base_key_value    => p_rec.pl_id);
    --
    ben_pln_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the ben_pl_f Row
    --
    update  ben_pl_f
    set
     NAME                          = p_rec.NAME
    ,ALWS_QDRO_FLAG                = p_rec.ALWS_QDRO_FLAG
    ,ALWS_QMCSO_FLAG               = p_rec.ALWS_QMCSO_FLAG
    ,ALWS_REIMBMTS_FLAG            = p_rec.ALWS_REIMBMTS_FLAG
    ,BNF_ADDL_INSTN_TXT_ALWD_FLAG  = p_rec.BNF_ADDL_INSTN_TXT_ALWD_FLAG
    ,BNF_ADRS_RQD_FLAG             = p_rec.BNF_ADRS_RQD_FLAG
    ,BNF_CNTNGT_BNFS_ALWD_FLAG     = p_rec.BNF_CNTNGT_BNFS_ALWD_FLAG
    ,BNF_CTFN_RQD_FLAG             = p_rec.BNF_CTFN_RQD_FLAG
    ,BNF_DOB_RQD_FLAG              = p_rec.BNF_DOB_RQD_FLAG
    ,BNF_DSGE_MNR_TTEE_RQD_FLAG    = p_rec.BNF_DSGE_MNR_TTEE_RQD_FLAG
    ,BNF_INCRMT_AMT                = p_rec.BNF_INCRMT_AMT
    ,BNF_DFLT_BNF_CD               = p_rec.BNF_DFLT_BNF_CD
    ,BNF_LEGV_ID_RQD_FLAG          = p_rec.BNF_LEGV_ID_RQD_FLAG
    ,BNF_MAY_DSGT_ORG_FLAG         = p_rec.BNF_MAY_DSGT_ORG_FLAG
    ,BNF_MN_DSGNTBL_AMT            = p_rec.BNF_MN_DSGNTBL_AMT
    ,BNF_MN_DSGNTBL_PCT_VAL        = p_rec.BNF_MN_DSGNTBL_PCT_VAL
    ,rqd_perd_enrt_nenrt_val       = p_rec.rqd_perd_enrt_nenrt_val
    ,ordr_num                      = p_rec.ordr_num
    ,BNF_PCT_INCRMT_VAL            = p_rec.BNF_PCT_INCRMT_VAL
    ,BNF_PCT_AMT_ALWD_CD           = p_rec.BNF_PCT_AMT_ALWD_CD
    ,BNF_QDRO_RL_APLS_FLAG         = p_rec.BNF_QDRO_RL_APLS_FLAG
    ,DFLT_TO_ASN_PNDG_CTFN_CD      = p_rec.DFLT_TO_ASN_PNDG_CTFN_CD
    ,DFLT_TO_ASN_PNDG_CTFN_RL      = p_rec.DFLT_TO_ASN_PNDG_CTFN_RL
    ,DRVBL_FCTR_APLS_RTS_FLAG      = p_rec.DRVBL_FCTR_APLS_RTS_FLAG
    ,DRVBL_FCTR_PRTN_ELIG_FLAG     = p_rec.DRVBL_FCTR_PRTN_ELIG_FLAG
    ,DPNT_DSGN_CD                  = p_rec.DPNT_DSGN_CD
    ,ELIG_APLS_FLAG                = p_rec.ELIG_APLS_FLAG
    ,INVK_DCLN_PRTN_PL_FLAG        = p_rec.INVK_DCLN_PRTN_PL_FLAG
    ,INVK_FLX_CR_PL_FLAG           = p_rec.INVK_FLX_CR_PL_FLAG
    ,IMPTD_INCM_CALC_CD            = p_rec.IMPTD_INCM_CALC_CD
    ,DRVBL_DPNT_ELIG_FLAG          = p_rec.DRVBL_DPNT_ELIG_FLAG
    ,TRK_INELIG_PER_FLAG           = p_rec.TRK_INELIG_PER_FLAG
    ,PL_CD                         = p_rec.PL_CD
    ,AUTO_ENRT_MTHD_RL             = p_rec.AUTO_ENRT_MTHD_RL
    ,IVR_IDENT                     = p_rec.IVR_IDENT
    ,URL_REF_NAME                  = p_rec.URL_REF_NAME
    ,CMPR_CLMS_TO_CVG_OR_BAL_CD    = p_rec.CMPR_CLMS_TO_CVG_OR_BAL_CD
    ,COBRA_PYMT_DUE_DY_NUM         = p_rec.COBRA_PYMT_DUE_DY_NUM
    ,DPNT_CVD_BY_OTHR_APLS_FLAG    = p_rec.DPNT_CVD_BY_OTHR_APLS_FLAG
    ,ENRT_MTHD_CD                  = p_rec.ENRT_MTHD_CD
    ,ENRT_CD                       = p_rec.ENRT_CD
    ,ENRT_CVG_STRT_DT_CD           = p_rec.ENRT_CVG_STRT_DT_CD
    ,ENRT_CVG_END_DT_CD            = p_rec.ENRT_CVG_END_DT_CD
    ,FRFS_APLY_FLAG                = p_rec.FRFS_APLY_FLAG
    ,HC_PL_SUBJ_HCFA_APRVL_FLAG    = p_rec.HC_PL_SUBJ_HCFA_APRVL_FLAG
    ,HGHLY_CMPD_RL_APLS_FLAG       = p_rec.HGHLY_CMPD_RL_APLS_FLAG
    ,INCPTN_DT                     = p_rec.INCPTN_DT
    ,MN_CVG_RL                     = p_rec.MN_CVG_RL
    ,MN_CVG_RQD_AMT                = p_rec.MN_CVG_RQD_AMT
    ,MN_OPTS_RQD_NUM               = p_rec.MN_OPTS_RQD_NUM
    ,MX_CVG_ALWD_AMT               = p_rec.MX_CVG_ALWD_AMT
    ,MX_CVG_RL                     = p_rec.MX_CVG_RL
    ,MX_OPTS_ALWD_NUM              = p_rec.MX_OPTS_ALWD_NUM
    ,MX_CVG_WCFN_MLT_NUM           = p_rec.MX_CVG_WCFN_MLT_NUM
    ,MX_CVG_WCFN_AMT               = p_rec.MX_CVG_WCFN_AMT
    ,MX_CVG_INCR_ALWD_AMT          = p_rec.MX_CVG_INCR_ALWD_AMT
    ,MX_CVG_INCR_WCF_ALWD_AMT      = p_rec.MX_CVG_INCR_WCF_ALWD_AMT
    ,MX_CVG_MLT_INCR_NUM           = p_rec.MX_CVG_MLT_INCR_NUM
    ,MX_CVG_MLT_INCR_WCF_NUM       = p_rec.MX_CVG_MLT_INCR_WCF_NUM
    ,MX_WTG_DT_TO_USE_CD           = p_rec.MX_WTG_DT_TO_USE_CD
    ,MX_WTG_DT_TO_USE_RL           = p_rec.MX_WTG_DT_TO_USE_RL
    ,MX_WTG_PERD_PRTE_UOM          = p_rec.MX_WTG_PERD_PRTE_UOM
    ,MX_WTG_PERD_PRTE_VAL          = p_rec.MX_WTG_PERD_PRTE_VAL
    ,MX_WTG_PERD_RL                = p_rec.MX_WTG_PERD_RL
    ,NIP_DFLT_ENRT_CD              = p_rec.NIP_DFLT_ENRT_CD
    ,NIP_DFLT_ENRT_DET_RL          = p_rec.NIP_DFLT_ENRT_DET_RL
    ,DPNT_ADRS_RQD_FLAG            = p_rec.DPNT_ADRS_RQD_FLAG
    ,DPNT_CVG_END_DT_CD            = p_rec.DPNT_CVG_END_DT_CD
    ,DPNT_CVG_END_DT_RL            = p_rec.DPNT_CVG_END_DT_RL
    ,DPNT_CVG_STRT_DT_CD           = p_rec.DPNT_CVG_STRT_DT_CD
    ,DPNT_CVG_STRT_DT_RL           = p_rec.DPNT_CVG_STRT_DT_RL
    ,DPNT_DOB_RQD_FLAG             = p_rec.DPNT_DOB_RQD_FLAG
    ,DPNT_LEG_ID_RQD_FLAG          = p_rec.DPNT_LEG_ID_RQD_FLAG
    ,DPNT_NO_CTFN_RQD_FLAG         = p_rec.DPNT_NO_CTFN_RQD_FLAG
    ,NO_MN_CVG_AMT_APLS_FLAG       = p_rec.NO_MN_CVG_AMT_APLS_FLAG
    ,NO_MN_CVG_INCR_APLS_FLAG      = p_rec.NO_MN_CVG_INCR_APLS_FLAG
    ,NO_MN_OPTS_NUM_APLS_FLAG      = p_rec.NO_MN_OPTS_NUM_APLS_FLAG
    ,NO_MX_CVG_AMT_APLS_FLAG       = p_rec.NO_MX_CVG_AMT_APLS_FLAG
    ,NO_MX_CVG_INCR_APLS_FLAG      = p_rec.NO_MX_CVG_INCR_APLS_FLAG
    ,NO_MX_OPTS_NUM_APLS_FLAG      = p_rec.NO_MX_OPTS_NUM_APLS_FLAG
    ,NIP_PL_UOM                    = p_rec.NIP_PL_UOM
    ,rqd_perd_enrt_nenrt_uom       = p_rec.rqd_perd_enrt_nenrt_uom
    ,NIP_ACTY_REF_PERD_CD          = p_rec.NIP_ACTY_REF_PERD_CD
    ,NIP_ENRT_INFO_RT_FREQ_CD      = p_rec.NIP_ENRT_INFO_RT_FREQ_CD
    ,PER_CVRD_CD                   = p_rec.PER_CVRD_CD
    ,ENRT_CVG_END_DT_RL            = p_rec.ENRT_CVG_END_DT_RL
    ,POSTELCN_EDIT_RL              = p_rec.POSTELCN_EDIT_RL
    ,ENRT_CVG_STRT_DT_RL           = p_rec.ENRT_CVG_STRT_DT_RL
    ,PRORT_PRTL_YR_CVG_RSTRN_CD    = p_rec.PRORT_PRTL_YR_CVG_RSTRN_CD
    ,PRORT_PRTL_YR_CVG_RSTRN_RL    = p_rec.PRORT_PRTL_YR_CVG_RSTRN_RL
    ,PRTN_ELIG_OVRID_ALWD_FLAG     = p_rec.PRTN_ELIG_OVRID_ALWD_FLAG
    ,SVGS_PL_FLAG                  = p_rec.SVGS_PL_FLAG
    ,SUBJ_TO_IMPTD_INCM_TYP_CD     = p_rec.SUBJ_TO_IMPTD_INCM_TYP_CD
    ,USE_ALL_ASNTS_ELIG_FLAG       = p_rec.USE_ALL_ASNTS_ELIG_FLAG
    ,USE_ALL_ASNTS_FOR_RT_FLAG     = p_rec.USE_ALL_ASNTS_FOR_RT_FLAG
    ,VSTG_APLS_FLAG                = p_rec.VSTG_APLS_FLAG
    ,WVBL_FLAG                     = p_rec.WVBL_FLAG
    ,HC_SVC_TYP_CD                 = p_rec.HC_SVC_TYP_CD
    ,PL_STAT_CD                    = p_rec.PL_STAT_CD
    ,PRMRY_FNDG_MTHD_CD            = p_rec.PRMRY_FNDG_MTHD_CD
    ,RT_END_DT_CD                  = p_rec.RT_END_DT_CD
    ,RT_END_DT_RL                  = p_rec.RT_END_DT_RL
    ,RT_STRT_DT_RL                 = p_rec.RT_STRT_DT_RL
    ,RT_STRT_DT_CD                 = p_rec.RT_STRT_DT_CD
    ,BNF_DSGN_CD                   = p_rec.BNF_DSGN_CD
    ,PL_TYP_ID                     = p_rec.PL_TYP_ID
    ,BUSINESS_GROUP_ID             = p_rec.BUSINESS_GROUP_ID
    ,ENRT_PL_OPT_FLAG              = p_rec.ENRT_PL_OPT_FLAG
    ,BNFT_PRVDR_POOL_ID            = p_rec.BNFT_PRVDR_POOL_ID
    ,MAY_ENRL_PL_N_OIPL_FLAG       = p_rec.MAY_ENRL_PL_N_OIPL_FLAG
    ,ENRT_RL                       = p_rec.ENRT_RL
    ,rqd_perd_enrt_nenrt_rl        = p_rec.rqd_perd_enrt_nENRT_RL
    ,ALWS_UNRSTRCTD_ENRT_FLAG      = p_rec.ALWS_UNRSTRCTD_ENRT_FLAG
    ,BNFT_OR_OPTION_RSTRCTN_CD     = p_rec.BNFT_OR_OPTION_RSTRCTN_CD
    ,CVG_INCR_R_DECR_ONLY_CD       = p_rec.CVG_INCR_R_DECR_ONLY_CD
    ,unsspnd_enrt_cd               = p_rec.unsspnd_enrt_cd
    ,PLN_ATTRIBUTE_CATEGORY        = p_rec.PLN_ATTRIBUTE_CATEGORY
    ,PLN_ATTRIBUTE1                = p_rec.PLN_ATTRIBUTE1
    ,PLN_ATTRIBUTE2                = p_rec.PLN_ATTRIBUTE2
    ,PLN_ATTRIBUTE3                = p_rec.PLN_ATTRIBUTE3
    ,PLN_ATTRIBUTE4                = p_rec.PLN_ATTRIBUTE4
    ,PLN_ATTRIBUTE5                = p_rec.PLN_ATTRIBUTE5
    ,PLN_ATTRIBUTE6                = p_rec.PLN_ATTRIBUTE6
    ,PLN_ATTRIBUTE7                = p_rec.PLN_ATTRIBUTE7
    ,PLN_ATTRIBUTE8                = p_rec.PLN_ATTRIBUTE8
    ,PLN_ATTRIBUTE9                = p_rec.PLN_ATTRIBUTE9
    ,PLN_ATTRIBUTE10               = p_rec.PLN_ATTRIBUTE10
    ,PLN_ATTRIBUTE11               = p_rec.PLN_ATTRIBUTE11
    ,PLN_ATTRIBUTE12               = p_rec.PLN_ATTRIBUTE12
    ,PLN_ATTRIBUTE13               = p_rec.PLN_ATTRIBUTE13
    ,PLN_ATTRIBUTE14               = p_rec.PLN_ATTRIBUTE14
    ,PLN_ATTRIBUTE15               = p_rec.PLN_ATTRIBUTE15
    ,PLN_ATTRIBUTE16               = p_rec.PLN_ATTRIBUTE16
    ,PLN_ATTRIBUTE17               = p_rec.PLN_ATTRIBUTE17
    ,PLN_ATTRIBUTE18               = p_rec.PLN_ATTRIBUTE18
    ,PLN_ATTRIBUTE19               = p_rec.PLN_ATTRIBUTE19
    ,PLN_ATTRIBUTE20               = p_rec.PLN_ATTRIBUTE20
    ,PLN_ATTRIBUTE21               = p_rec.PLN_ATTRIBUTE21
    ,PLN_ATTRIBUTE22               = p_rec.PLN_ATTRIBUTE22
    ,PLN_ATTRIBUTE23               = p_rec.PLN_ATTRIBUTE23
    ,PLN_ATTRIBUTE24               = p_rec.PLN_ATTRIBUTE24
    ,PLN_ATTRIBUTE25               = p_rec.PLN_ATTRIBUTE25
    ,PLN_ATTRIBUTE26               = p_rec.PLN_ATTRIBUTE26
    ,PLN_ATTRIBUTE27               = p_rec.PLN_ATTRIBUTE27
    ,PLN_ATTRIBUTE28               = p_rec.PLN_ATTRIBUTE28
    ,PLN_ATTRIBUTE29               = p_rec.PLN_ATTRIBUTE29
    ,PLN_ATTRIBUTE30               = p_rec.PLN_ATTRIBUTE30
    ,susp_if_ctfn_not_prvd_flag  = p_rec.susp_if_ctfn_not_prvd_flag
    ,ctfn_determine_cd           =  p_rec.ctfn_determine_cd
    ,susp_if_dpnt_ssn_nt_prv_cd  =  p_rec.susp_if_dpnt_ssn_nt_prv_cd
    ,susp_if_dpnt_dob_nt_prv_cd  =  p_rec.susp_if_dpnt_dob_nt_prv_cd
    ,susp_if_dpnt_adr_nt_prv_cd  =  p_rec.susp_if_dpnt_adr_nt_prv_cd
    ,susp_if_ctfn_not_dpnt_flag  =  p_rec.susp_if_ctfn_not_dpnt_flag
    ,susp_if_bnf_ssn_nt_prv_cd   =  p_rec.susp_if_bnf_ssn_nt_prv_cd
    ,susp_if_bnf_dob_nt_prv_cd   =  p_rec.susp_if_bnf_dob_nt_prv_cd
    ,susp_if_bnf_adr_nt_prv_cd   =  p_rec.susp_if_bnf_adr_nt_prv_cd
    ,susp_if_ctfn_not_bnf_flag   =  p_rec.susp_if_ctfn_not_bnf_flag
    ,dpnt_ctfn_determine_cd      =  p_rec.dpnt_ctfn_determine_cd
    ,bnf_ctfn_determine_cd       =  p_rec.bnf_ctfn_determine_cd
--    ,LAST_UPDATE_DATE              = p_rec.LAST_UPDATE_DATE
--    ,LAST_UPDATED_BY               = p_rec.LAST_UPDATED_BY
--    ,LAST_UPDATE_LOGIN             = p_rec.LAST_UPDATE_LOGIN
--    ,CREATED_BY                    = p_rec.CREATED_BY
--    ,CREATION_DATE                 = p_rec.CREATION_DATE
    ,OBJECT_VERSION_NUMBER         = p_rec.OBJECT_VERSION_NUMBER
    ,ACTL_PREM_ID                  = p_rec.ACTL_PREM_ID
    ,VRFY_FMLY_MMBR_CD             = p_rec.VRFY_FMLY_MMBR_CD
    ,VRFY_FMLY_MMBR_RL             = p_rec.VRFY_FMLY_MMBR_RL
    ,ALWS_TMPRY_ID_CRD_FLAG        = p_rec.ALWS_TMPRY_ID_CRD_FLAG
    ,NIP_DFLT_FLAG                 = p_rec.NIP_DFLT_FLAG
    ,frfs_distr_mthd_cd            =  p_rec.frfs_distr_mthd_cd
    ,frfs_distr_mthd_rl            =  p_rec.frfs_distr_mthd_rl
    ,frfs_cntr_det_cd              =  p_rec.frfs_cntr_det_cd
    ,frfs_distr_det_cd             =  p_rec.frfs_distr_det_cd
    ,cost_alloc_keyflex_1_id       =  p_rec.cost_alloc_keyflex_1_id
    ,cost_alloc_keyflex_2_id       =  p_rec.cost_alloc_keyflex_2_id
    ,post_to_gl_flag               =  p_rec.post_to_gl_flag
    ,frfs_val_det_cd               =  p_rec.frfs_val_det_cd
    ,frfs_mx_cryfwd_val            =  p_rec.frfs_mx_cryfwd_val
    ,frfs_portion_det_cd           =  p_rec.frfs_portion_det_cd
    ,bndry_perd_cd                 =  p_rec.bndry_perd_cd
    ,short_name                    =  p_rec.short_name
    ,short_code                    =  p_rec.short_code
    ,legislation_code              =  p_rec.legislation_code
    ,legislation_subgroup          =  p_rec.legislation_subgroup
    ,group_pl_id                   =  p_rec.group_pl_id
    ,mapping_table_name            =  p_rec.mapping_table_name
    ,mapping_table_pk_id           =  p_rec.mapping_table_pk_id
    ,function_code                 =  p_rec.function_code
    ,pl_yr_not_applcbl_flag        =  p_rec.pl_yr_not_applcbl_flag
    ,use_csd_rsd_prccng_cd         =  p_rec.use_csd_rsd_prccng_cd
    where   pl_id = p_rec.pl_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    ben_pln_shd.g_api_dml := false;   -- Unset the api dml status
    --
    -- Set the effective start and end dates
    --
    p_rec.effective_start_date := p_validation_start_date;
    p_rec.effective_end_date   := p_validation_end_date;
  End If;
--
hr_utility.set_location(' Leaving:'||l_proc, 15);
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
End dt_update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_update_dml control logic which handles
--   the actual datetrack dml.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
    (p_rec              in out nocopy ben_pln_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc    varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_update_dml(p_rec            => p_rec,
        p_effective_date    => p_effective_date,
        p_datetrack_mode    => p_datetrack_mode,
               p_validation_start_date    => p_validation_start_date,
        p_validation_end_date    => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_update >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_update procedure controls the execution
--   of dml for the datetrack modes of: UPDATE, UPDATE_OVERRIDE
--   and UPDATE_CHANGE_INSERT only. The execution required is as
--   follows:
--
--   1) Providing the datetrack update mode is not 'CORRECTION'
--      then set the effective end date of the current row (this
--      will be the validation_start_date - 1).
--   2) If the datetrack mode is 'UPDATE_OVERRIDE' then call the
--      corresponding delete_dml process to delete any future rows
--      where the effective_start_date is greater than or equal to
--    the validation_start_date.
--   3) Call the insert_dml process to insert the new updated row
--      details..
--
-- Prerequisites:
--   This is an internal procedure which is called from the
--   pre_update procedure.
--
-- In Parameters:
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
Procedure dt_pre_update
    (p_rec              in out nocopy    ben_pln_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc             varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Update the current effective end date
    --
    ben_pln_shd.upd_effective_end_date
     (p_effective_date           => p_effective_date,
      p_base_key_value           => p_rec.pl_id,
      p_new_effective_end_date => (p_validation_start_date - 1),
      p_validation_start_date  => p_validation_start_date,
      p_validation_end_date    => p_validation_end_date,
      p_object_version_number  => l_dummy_version_number);
    --
    If (p_datetrack_mode = 'UPDATE_OVERRIDE') then
      hr_utility.set_location(l_proc, 15);
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      ben_pln_del.delete_dml
        (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
    End If;
    hr_utility.set_location(l_proc, 20);
    --
    -- We must now insert the updated row
    --
    ben_pln_ins.insert_dml
      (p_rec            => p_rec,
       p_effective_date        => p_effective_date,
       p_datetrack_mode        => p_datetrack_mode,
       p_validation_start_date    => p_validation_start_date,
       p_validation_end_date    => p_validation_end_date);
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End dt_pre_update;
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
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_update_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
    (p_rec              in out nocopy    ben_pln_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc    varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_update
    (p_rec              => p_rec,
     p_effective_date         => p_effective_date,
     p_datetrack_mode         => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
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
Procedure post_update
    (p_rec              in ben_pln_shd.g_rec_type,
     p_effective_date     in date,
     p_datetrack_mode     in varchar2,
     p_validation_start_date in date,
     p_validation_end_date     in date) is
--
  l_proc    varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Start of API User Hook for post_update.
  -- Added for GSP validations
  pqh_gsp_ben_validations.pl_validations
  	(  p_pl_id			=> p_rec.pl_id
  	 , p_effective_date 		=> p_effective_date
  	 , p_business_group_id  	=> p_rec.business_group_id
  	 , p_dml_operation 		=> 'U'
  	 , p_pl_Typ_Id			=> p_rec.pl_Typ_Id
  	 , p_Mapping_Table_PK_ID	=> p_rec.Mapping_Table_PK_ID
  	 , p_pl_stat_cd			=> p_rec.pl_stat_cd
  	 );

  --

  begin
    --
    --
    ben_pln_rku.after_update
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
     ,p_MAY_ENRL_PL_N_OIPL_FLAG       => p_rec.MAY_ENRL_PL_N_OIPL_FLAG
     ,p_enrt_RL                       => p_rec.enrt_RL
     ,p_rqd_perd_enrt_nenrt_rl        => p_rec.rqd_perd_enrt_nenrt_RL
     ,p_alws_UNRSTRCTD_ENRT_FLAG      => p_rec.alws_UNRSTRCTD_ENRT_FLAG
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
     ,p_susp_if_ctfn_not_prvd_flag     =>  p_rec.susp_if_ctfn_not_prvd_flag
     ,p_ctfn_determine_cd              =>  p_rec.ctfn_determine_cd
     ,p_susp_if_dpnt_ssn_nt_prv_cd     =>  p_rec.susp_if_dpnt_ssn_nt_prv_cd
     ,p_susp_if_dpnt_dob_nt_prv_cd     =>  p_rec.susp_if_dpnt_dob_nt_prv_cd
     ,p_susp_if_dpnt_adr_nt_prv_cd     =>  p_rec.susp_if_dpnt_adr_nt_prv_cd
     ,p_susp_if_ctfn_not_dpnt_flag     =>  p_rec.susp_if_ctfn_not_dpnt_flag
     ,p_susp_if_bnf_ssn_nt_prv_cd      =>  p_rec.susp_if_bnf_ssn_nt_prv_cd
     ,p_susp_if_bnf_dob_nt_prv_cd      =>  p_rec.susp_if_bnf_dob_nt_prv_cd
     ,p_susp_if_bnf_adr_nt_prv_cd      =>  p_rec.susp_if_bnf_adr_nt_prv_cd
     ,p_susp_if_ctfn_not_bnf_flag      =>  p_rec.susp_if_ctfn_not_bnf_flag
     ,p_dpnt_ctfn_determine_cd         =>  p_rec.dpnt_ctfn_determine_cd
     ,p_bnf_ctfn_determine_cd          =>  p_rec.bnf_ctfn_determine_cd
     ,p_object_version_number         => p_rec.object_version_number
     ,p_effective_date                => p_effective_date
     ,p_datetrack_mode                => p_datetrack_mode
     ,p_validation_start_date         => p_validation_start_date
     ,p_validation_end_date           => p_validation_end_date
     ,p_alws_TMPRY_ID_CRD_FLAG      => p_rec.alws_TMPRY_ID_CRD_FLAG
     ,p_actl_prem_id                  => p_rec.actl_prem_id
     ,p_vrfy_fmly_mmbr_cd             => p_rec.vrfy_fmly_mmbr_cd
     ,p_vrfy_fmly_mmbr_rl             => p_rec.vrfy_fmly_mmbr_rl
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
     ,p_effective_start_date_o        => ben_pln_shd.g_old_rec.effective_start_date
     ,p_effective_end_date_o          => ben_pln_shd.g_old_rec.effective_end_date
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
     ,p_ENRT_RL_o                     => ben_pln_shd.g_old_rec.enrt_rl
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
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec            in out nocopy     ben_pln_shd.g_rec_type,
  p_effective_date    in     date,
  p_datetrack_mode    in     varchar2
  ) is
--
  l_proc            varchar2(72) := g_package||'upd';
  l_validation_start_date    date;
  l_validation_end_date        date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to update.
  --
  ben_pln_shd.lck
    (p_effective_date     => p_effective_date,
           p_datetrack_mode     => p_datetrack_mode,
           p_pl_id     => p_rec.pl_id,
           p_object_version_number => p_rec.object_version_number,
           p_validation_start_date => l_validation_start_date,
           p_validation_end_date     => l_validation_end_date);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  ben_pln_upd2.convert_defs(p_rec);
  hr_utility.set_location('xxxxx l_validation_start_date '||l_validation_start_date, 100);
  hr_utility.set_location('xxxx l_validation_end_date '||l_validation_end_date, 100);
  ben_pln_bus.update_validate
    (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode       => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update
    (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  -- Update the row.
  --
  update_dml
    (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  -- Call the supporting post-update operation
  --
  post_update
    (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_pl_id                        in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_name                         in varchar2         ,
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
  p_pl_cd                        in varchar2         ,
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
  p_pl_typ_id                    in number           ,
  p_business_group_id            in number           ,
  p_enrt_pl_opt_flag             in varchar2         ,
  p_bnft_prvdr_pool_id           in number           ,
  p_MAY_ENRL_PL_N_OIPL_FLAG      in VARCHAR2         ,
  p_ENRT_RL                      in NUMBER           ,
  p_rqd_perd_enrt_nenrt_rl       in NUMBER           ,
  p_ALWS_UNRSTRCTD_ENRT_FLAG     in VARCHAR2         ,
  p_BNFT_OR_OPTION_RSTRCTN_CD    in VARCHAR2         ,
  p_CVG_INCR_R_DECR_ONLY_CD      in VARCHAR2         ,
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
  p_object_version_number        in out nocopy number,
  p_actl_prem_id                 in number           ,
  p_effective_date               in date,
  p_datetrack_mode               in varchar2,
  p_vrfy_fmly_mmbr_cd            in varchar2         ,
  p_vrfy_fmly_mmbr_rl            in number           ,
  p_alws_tmpry_id_crd_flag       in varchar2         ,
  p_nip_dflt_flag                in varchar2         ,
  p_frfs_distr_mthd_cd           in  varchar2        ,
  p_frfs_distr_mthd_rl           in  number          ,
  p_frfs_cntr_det_cd             in  varchar2        ,
  p_frfs_distr_det_cd            in  varchar2        ,
  p_cost_alloc_keyflex_1_id      in  number          ,
  p_cost_alloc_keyflex_2_id      in  number          ,
  p_post_to_gl_flag              in  varchar2        ,
  p_frfs_val_det_cd              in  varchar2        ,
  p_frfs_mx_cryfwd_val           in  number          ,
  p_frfs_portion_det_cd          in  varchar2        ,
  p_bndry_perd_cd                in  varchar2        ,
  p_short_name			 in  varchar2        ,
  p_short_code			 in  varchar2        ,
  p_legislation_code		 in  varchar2        ,
  p_legislation_subgroup         in  varchar2        ,
  p_group_pl_id           	 in  number          ,
  p_mapping_table_name           in  varchar2        ,
  p_mapping_table_pk_id          in  number          ,
  p_function_code                in  varchar2        ,
  p_pl_yr_not_applcbl_flag       in  varchar2        ,
  p_use_csd_rsd_prccng_cd        in  varchar2
  ) is
--
  l_rec        ben_pln_shd.g_rec_type;
  l_proc    varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
     ben_pln_shd.convert_args
  (
     p_pl_id
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
    ,p_object_version_number
    ,p_actl_prem_id
    ,p_vrfy_fmly_mmbr_cd
    ,p_vrfy_fmly_mmbr_rl
    ,p_alws_tmpry_id_crd_flag
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
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_effective_date, p_datetrack_mode);
  p_object_version_number       := l_rec.object_version_number;
  p_effective_start_date        := l_rec.effective_start_date;
  p_effective_end_date          := l_rec.effective_end_date;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_pln_upd;

/

--------------------------------------------------------
--  DDL for Package BEN_PLN_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLN_SHD" AUTHID CURRENT_USER as
/* $Header: beplnrhi.pkh 120.2.12010000.1 2008/07/29 12:51:04 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
   PL_ID                                    NUMBER(15)
  ,EFFECTIVE_START_DATE                     DATE
  ,EFFECTIVE_END_DATE                       DATE
  ,NAME                                     VARCHAR2(240) -- UTF8 Change Bug 2254683
  ,ALWS_QDRO_FLAG                           VARCHAR2(30)
  ,ALWS_QMCSO_FLAG                          VARCHAR2(30)
  ,ALWS_REIMBMTS_FLAG                       VARCHAR2(30)
  ,BNF_ADDL_INSTN_TXT_ALWD_FLAG             VARCHAR2(30)
  ,BNF_ADRS_RQD_FLAG                        VARCHAR2(30)
  ,BNF_CNTNGT_BNFS_ALWD_FLAG                VARCHAR2(30)
  ,BNF_CTFN_RQD_FLAG                        VARCHAR2(30)
  ,BNF_DOB_RQD_FLAG                         VARCHAR2(30)
  ,BNF_DSGE_MNR_TTEE_RQD_FLAG               VARCHAR2(30)
  ,BNF_INCRMT_AMT                           NUMBER       --(15)
  ,BNF_DFLT_BNF_CD                          VARCHAR2(30)
  ,BNF_LEGV_ID_RQD_FLAG                     VARCHAR2(30)
  ,BNF_MAY_DSGT_ORG_FLAG                    VARCHAR2(30)
  ,BNF_MN_DSGNTBL_AMT                       NUMBER       --(15)
  ,BNF_MN_DSGNTBL_PCT_VAL                   NUMBER(15,2)  -- Bug 6012543, precision changed, (15) to (15,2).
  ,rqd_perd_enrt_nenrt_val                  NUMBER(15)
  ,ordr_num                                 NUMBER(15)
  ,BNF_PCT_INCRMT_VAL                       NUMBER(15,2)   -- Bug 6012543, precision changed, (15) to (15,2).
  ,BNF_PCT_AMT_ALWD_CD                      VARCHAR2(30)
  ,BNF_QDRO_RL_APLS_FLAG                    VARCHAR2(30)
  ,DFLT_TO_ASN_PNDG_CTFN_CD                 VARCHAR2(30)
  ,DFLT_TO_ASN_PNDG_CTFN_RL                 NUMBER(15)
  ,DRVBL_FCTR_APLS_RTS_FLAG                 VARCHAR2(30)
  ,DRVBL_FCTR_PRTN_ELIG_FLAG                VARCHAR2(30)
  ,DPNT_DSGN_CD                             VARCHAR2(30)
  ,ELIG_APLS_FLAG                           VARCHAR2(30)
  ,INVK_DCLN_PRTN_PL_FLAG                   VARCHAR2(30)
  ,INVK_FLX_CR_PL_FLAG                      VARCHAR2(30)
  ,IMPTD_INCM_CALC_CD                       VARCHAR2(30)
  ,DRVBL_DPNT_ELIG_FLAG                     VARCHAR2(30)
  ,TRK_INELIG_PER_FLAG                      VARCHAR2(30)
  ,PL_CD                                    VARCHAR2(30)
  ,AUTO_ENRT_MTHD_RL                        NUMBER(15)
  ,IVR_IDENT                                VARCHAR2(90) -- UTF8 Change Bug 2254683
  ,URL_REF_NAME                             VARCHAR2(240)
  ,CMPR_CLMS_TO_CVG_OR_BAL_CD               VARCHAR2(30)
  ,COBRA_PYMT_DUE_DY_NUM                    NUMBER(15)
  ,DPNT_CVD_BY_OTHR_APLS_FLAG               VARCHAR2(30)
  ,ENRT_MTHD_CD                             VARCHAR2(30)
  ,ENRT_CD                                  VARCHAR2(30)
  ,ENRT_CVG_STRT_DT_CD                      VARCHAR2(30)
  ,ENRT_CVG_END_DT_CD                       VARCHAR2(30)
  ,FRFS_APLY_FLAG                           VARCHAR2(30)
  ,HC_PL_SUBJ_HCFA_APRVL_FLAG               VARCHAR2(30)
  ,HGHLY_CMPD_RL_APLS_FLAG                  VARCHAR2(30)
  ,INCPTN_DT                                DATE
  ,MN_CVG_RL                                NUMBER(15)
  ,MN_CVG_RQD_AMT                           NUMBER       --(15)
  ,MN_OPTS_RQD_NUM                          NUMBER(15)
  ,MX_CVG_ALWD_AMT                          NUMBER       --(15)
  ,MX_CVG_RL                                NUMBER(15)
  ,MX_OPTS_ALWD_NUM                         NUMBER(15)
  ,MX_CVG_WCFN_MLT_NUM                      NUMBER(15)
  ,MX_CVG_WCFN_AMT                          NUMBER       --(15)
  ,MX_CVG_INCR_ALWD_AMT                     NUMBER       --(15)
  ,MX_CVG_INCR_WCF_ALWD_AMT                 NUMBER       --(15)
  ,MX_CVG_MLT_INCR_NUM                      NUMBER(15)
  ,MX_CVG_MLT_INCR_WCF_NUM                  NUMBER(15)
  ,MX_WTG_DT_TO_USE_CD                      VARCHAR2(30)
  ,MX_WTG_DT_TO_USE_RL                      NUMBER(15)
  ,MX_WTG_PERD_PRTE_UOM                     VARCHAR2(30)
  ,MX_WTG_PERD_PRTE_VAL                     NUMBER(15)
  ,MX_WTG_PERD_RL                           NUMBER(15)
  ,NIP_DFLT_ENRT_CD                         VARCHAR2(30)
  ,NIP_DFLT_ENRT_DET_RL                     NUMBER(15)
  ,DPNT_ADRS_RQD_FLAG                       VARCHAR2(30)
  ,DPNT_CVG_END_DT_CD                       VARCHAR2(30)
  ,DPNT_CVG_END_DT_RL                       NUMBER(15)
  ,DPNT_CVG_STRT_DT_CD                      VARCHAR2(30)
  ,DPNT_CVG_STRT_DT_RL                      NUMBER(15)
  ,DPNT_DOB_RQD_FLAG                        VARCHAR2(30)
  ,DPNT_LEG_ID_RQD_FLAG                     VARCHAR2(30)
  ,DPNT_NO_CTFN_RQD_FLAG                    VARCHAR2(30)
  ,NO_MN_CVG_AMT_APLS_FLAG                  VARCHAR2(30)
  ,NO_MN_CVG_INCR_APLS_FLAG                 VARCHAR2(30)
  ,NO_MN_OPTS_NUM_APLS_FLAG                 VARCHAR2(30)
  ,NO_MX_CVG_AMT_APLS_FLAG                  VARCHAR2(30)
  ,NO_MX_CVG_INCR_APLS_FLAG                 VARCHAR2(30)
  ,NO_MX_OPTS_NUM_APLS_FLAG                 VARCHAR2(30)
  ,NIP_PL_UOM                               VARCHAR2(30)
  ,rqd_perd_enrt_nenrt_uom                  VARCHAR2(30)
  ,NIP_ACTY_REF_PERD_CD                     VARCHAR2(30)
  ,NIP_ENRT_INFO_RT_FREQ_CD                 VARCHAR2(30)
  ,PER_CVRD_CD                              VARCHAR2(30)
  ,ENRT_CVG_END_DT_RL                       NUMBER(15)
  ,POSTELCN_EDIT_RL                         NUMBER(15)
  ,ENRT_CVG_STRT_DT_RL                      NUMBER(15)
  ,PRORT_PRTL_YR_CVG_RSTRN_CD               VARCHAR2(30)
  ,PRORT_PRTL_YR_CVG_RSTRN_RL               NUMBER(15)
  ,PRTN_ELIG_OVRID_ALWD_FLAG                VARCHAR2(30)
  ,SVGS_PL_FLAG                             VARCHAR2(30)
  ,SUBJ_TO_IMPTD_INCM_TYP_CD                VARCHAR2(30)
  ,USE_ALL_ASNTS_ELIG_FLAG                  VARCHAR2(30)
  ,USE_ALL_ASNTS_FOR_RT_FLAG                VARCHAR2(30)
  ,VSTG_APLS_FLAG                           VARCHAR2(30)
  ,WVBL_FLAG                                VARCHAR2(30)
  ,HC_SVC_TYP_CD                            VARCHAR2(30)
  ,PL_STAT_CD                               VARCHAR2(30)
  ,PRMRY_FNDG_MTHD_CD                       VARCHAR2(30)
  ,RT_END_DT_CD                             VARCHAR2(30)
  ,RT_END_DT_RL                             NUMBER(15)
  ,RT_STRT_DT_RL                            NUMBER(15)
  ,RT_STRT_DT_CD                            VARCHAR2(30)
  ,BNF_DSGN_CD                              VARCHAR2(30)
  ,PL_TYP_ID                                NUMBER(15)
  ,BUSINESS_GROUP_ID                        NUMBER(15)
  ,ENRT_PL_OPT_FLAG                         VARCHAR2(30)
  ,BNFT_PRVDR_POOL_ID                       NUMBER(15)
  ,MAY_ENRL_PL_N_OIPL_FLAG                  VARCHAR2(30)
  ,ENRT_RL                                  NUMBER
  ,rqd_perd_enrt_nenrt_rl                   NUMBER
  ,ALWS_UNRSTRCTD_ENRT_FLAG                 VARCHAR2(30)
  ,BNFT_OR_OPTION_RSTRCTN_CD                VARCHAR2(30)
  ,CVG_INCR_R_DECR_ONLY_CD                  VARCHAR2(30)
  ,unsspnd_enrt_cd                          VARCHAR2(30)
  ,PLN_ATTRIBUTE_CATEGORY                   VARCHAR2(30)
  ,PLN_ATTRIBUTE1                           VARCHAR2(150)
  ,PLN_ATTRIBUTE2                           VARCHAR2(150)
  ,PLN_ATTRIBUTE3                           VARCHAR2(150)
  ,PLN_ATTRIBUTE4                           VARCHAR2(150)
  ,PLN_ATTRIBUTE5                           VARCHAR2(150)
  ,PLN_ATTRIBUTE6                           VARCHAR2(150)
  ,PLN_ATTRIBUTE7                           VARCHAR2(150)
  ,PLN_ATTRIBUTE8                           VARCHAR2(150)
  ,PLN_ATTRIBUTE9                           VARCHAR2(150)
  ,PLN_ATTRIBUTE10                          VARCHAR2(150)
  ,PLN_ATTRIBUTE11                          VARCHAR2(150)
  ,PLN_ATTRIBUTE12                          VARCHAR2(150)
  ,PLN_ATTRIBUTE13                          VARCHAR2(150)
  ,PLN_ATTRIBUTE14                          VARCHAR2(150)
  ,PLN_ATTRIBUTE15                          VARCHAR2(150)
  ,PLN_ATTRIBUTE16                          VARCHAR2(150)
  ,PLN_ATTRIBUTE17                          VARCHAR2(150)
  ,PLN_ATTRIBUTE18                          VARCHAR2(150)
  ,PLN_ATTRIBUTE19                          VARCHAR2(150)
  ,PLN_ATTRIBUTE20                          VARCHAR2(150)
  ,PLN_ATTRIBUTE21                          VARCHAR2(150)
  ,PLN_ATTRIBUTE22                          VARCHAR2(150)
  ,PLN_ATTRIBUTE23                          VARCHAR2(150)
  ,PLN_ATTRIBUTE24                          VARCHAR2(150)
  ,PLN_ATTRIBUTE25                          VARCHAR2(150)
  ,PLN_ATTRIBUTE26                          VARCHAR2(150)
  ,PLN_ATTRIBUTE27                          VARCHAR2(150)
  ,PLN_ATTRIBUTE28                          VARCHAR2(150)
  ,PLN_ATTRIBUTE29                          VARCHAR2(150)
  ,PLN_ATTRIBUTE30                          VARCHAR2(150)
  ,susp_if_ctfn_not_prvd_flag               varchar2(30)
  ,ctfn_determine_cd                        varchar2(30)
  ,susp_if_dpnt_ssn_nt_prv_cd               varchar2(30)
  ,susp_if_dpnt_dob_nt_prv_cd               varchar2(30)
  ,susp_if_dpnt_adr_nt_prv_cd               varchar2(30)
  ,susp_if_ctfn_not_dpnt_flag               varchar2(30)
  ,susp_if_bnf_ssn_nt_prv_cd                varchar2(30)
  ,susp_if_bnf_dob_nt_prv_cd                varchar2(30)
  ,susp_if_bnf_adr_nt_prv_cd                varchar2(30)
  ,susp_if_ctfn_not_bnf_flag                varchar2(30)
  ,dpnt_ctfn_determine_cd                   varchar2(30)
  ,bnf_ctfn_determine_cd                    varchar2(30)
  ,LAST_UPDATE_DATE                         DATE
  ,LAST_UPDATED_BY                          NUMBER(15)
  ,LAST_UPDATE_LOGIN                        NUMBER(15)
  ,CREATED_BY                               NUMBER(15)
  ,CREATION_DATE                            DATE
  ,OBJECT_VERSION_NUMBER                    NUMBER(9)
  ,ACTL_PREM_ID                             NUMBER(15)
  ,VRFY_FMLY_MMBR_CD                      VARCHAR2(30)
  ,VRFY_FMLY_MMBR_RL                      NUMBER(15)
  ,ALWS_TMPRY_ID_CRD_FLAG                 VARCHAR2(30)
  ,NIP_DFLT_FLAG                          VARCHAR2(30)
  ,frfs_distr_mthd_cd                     VARCHAR2(30)
  ,frfs_distr_mthd_rl                     NUMBER(15)
  ,frfs_cntr_det_cd                       VARCHAR2(30)
  ,frfs_distr_det_cd                      VARCHAR2(30)
  ,cost_alloc_keyflex_1_id                NUMBER(15)
  ,cost_alloc_keyflex_2_id                NUMBER(15)
  ,post_to_gl_flag                        VARCHAR2(30)
  ,frfs_val_det_cd                        VARCHAR2(30)
  ,frfs_mx_cryfwd_val                     NUMBER(15)
  ,frfs_portion_det_cd                    VARCHAR2(30)
  ,bndry_perd_cd                          VARCHAR2(30)
  ,short_name                             VARCHAR2(30)
  ,short_code                             VARCHAR2(30)
  ,legislation_code                             VARCHAR2(30)
  ,legislation_subgroup                             VARCHAR2(30)
  ,group_pl_id                          NUMBER
  ,mapping_table_name                     VARCHAR2(60)
  ,mapping_table_pk_id                    NUMBER
  ,function_code                          VARCHAR2(30)
  ,pl_yr_not_applcbl_flag                      VARCHAR2(30)
  ,use_csd_rsd_prccng_cd                      VARCHAR2(30)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
g_api_dml  boolean;                               -- Global api dml status
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will return the current g_api_dml private global
--   boolean status.
--   The g_api_dml status determines if at the time of the function
--   being executed if a dml statement (i.e. INSERT, UPDATE or DELETE)
--   is being issued from within an api.
--   If the status is TRUE then a dml statement is being issued from
--   within this entity api.
--   This function is primarily to support database triggers which
--   need to maintain the object_version_number for non-supported
--   dml statements (i.e. dml statement issued outside of the api layer).
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   None.
--
-- Post Success:
--   Processing continues.
--   If the function returns a TRUE value then, dml is being executed from
--   within this api.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called when a constraint has been violated (i.e.
--   The exception hr_api.check_integrity_violated,
--   hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--   hr_api.unique_integrity_violated has been raised).
--   The exceptions can only be raised as follows:
--   1) A check constraint can only be violated during an INSERT or UPDATE
--      dml operation.
--   2) A parent integrity constraint can only be violated during an
--      INSERT or UPDATE dml operation.
--   3) A child integrity constraint can only be violated during an
--      DELETE dml operation.
--   4) A unique integrity constraint can only be violated during INSERT or
--      UPDATE dml operation.
--
-- Prerequisites:
--   1) Either hr_api.check_integrity_violated,
--      hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--      hr_api.unique_integrity_violated has been raised with the subsequent
--      stripping of the constraint name from the generated error message
--      text.
--   2) Standalone validation test which corresponds with a constraint error.
--
-- In Parameter:
--   p_constraint_name is in upper format and is just the constraint name
--   (e.g. not prefixed by brackets, schema owner etc).
--
-- Post Success:
--   Development dependant.
--
-- Post Failure:
--   Developement dependant.
--
-- Developer Implementation Notes:
--   For each constraint being checked the hr system package failure message
--   has been generated as a template only. These system error messages should
--   be modified as required (i.e. change the system failure message to a user
--   friendly defined error message).
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to populate the g_old_rec record with the current
--   row from the database for the specified primary key provided that the
--   primary key exists, and is valid, and does not already match the current
--   g_old_rec.
--   The function will always return a TRUE value if the g_old_rec is
--   populated with the current row. A FALSE value will be returned if all of
--   the primary key arguments are null.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--   A value of TRUE will be returned indiciating that the g_old_rec is
--   current.
--   A value of FALSE will be returned if all of the primary key arguments
--   have a null value (this indicates that the row has not be inserted into
--   the Schema), and therefore could never have a corresponding row.
--
-- Post Failure:
--   A failure can only occur under two circumstances:
--   1) The primary key is invalid (i.e. a row does not exist for the
--      specified primary key values).
--   2) If an object_version_number exists but is NOT the same as the current
--      g_old_rec value.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function api_updating
  (p_effective_date		in date,
   p_pl_id		in number,
   p_object_version_number	in number
  ) Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_del_modes >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to determine what datetrack delete modes are
--   allowed as of the effective date for this entity. The procedure will
--   return a corresponding Boolean value for each of the delete modes
--   available where TRUE indicates that the corresponding delete mode is
--   available.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_effective_date
--     Specifies the date at which the datetrack modes will be operated on.
--   p_base_key_value
--     Specifies the primary key value for this datetrack entity.
--     (E.g. For this entity the assignment of the argument would be:
--           p_base_key_value = :pl_id).
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Failure might occur if for the specified effective date and primary key
--   value a row doesn't exist.
--
-- Developer Implementation Notes:
--   This procedure could require changes if this entity has any sepcific
--   delete restrictions.
--   For example, this entity might disallow the datetrack delete mode of
--   ZAP. To implement this you would have to set and return a Boolean value
--   of FALSE after the call to the dt_api.find_dt_del_modes procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
	(p_effective_date	  in     date,
	 p_base_key_value	  in     number,
	 p_zap                   out nocopy boolean,
	 p_delete                out nocopy boolean,
	 p_future_change	     out nocopy boolean,
	 p_delete_next_change    out nocopy boolean);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to determine what datetrack update modes are
--   allowed as of the effective date for this entity. The procedure will
--   return a corresponding Boolean value for each of the update modes
--   available where TRUE indicates that the corresponding update mode
--   is available.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_effective_date
--     Specifies the date at which the datetrack modes will be operated on.
--   p_base_key_value
--     Specifies the primary key value for this datetrack entity.
--     (E.g. For this entity the assignment of the argument would be:
--           p_base_key_value = :pl_id).
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Failure might occur if for the specified effective date and primary key
--   value a row doesn't exist.
--
-- Developer Implementation Notes:
--   This procedure could require changes if this entity has any sepcific
--   delete restrictions.
--   For example, this entity might disallow the datetrack update mode of
--   UPDATE. To implement this you would have to set and return a Boolean
--   value of FALSE after the call to the dt_api.find_dt_upd_modes procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_correction	 out nocopy boolean,
	 p_update	 out nocopy boolean,
	 p_update_override out nocopy boolean,
	 p_update_change_insert out nocopy boolean);
--
-- ----------------------------------------------------------------------------
-- |------------------------< upd_effective_end_date >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure will update the specified datetrack row with the
--   specified new effective end date. The object version number is also
--   set to the next object version number. DateTrack modes which call
--   this procedure are: UPDATE, UPDATE_CHANGE_INSERT,
--   UPDATE_OVERRIDE, DELETE, FUTURE_CHANGE and DELETE_NEXT_CHANGE.
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_new_effective_end_date
--     Specifies the new effective end date which will be set for the
--     row as of the effective date.
--   p_base_key_value
--     Specifies the primary key value for this datetrack entity.
--     (E.g. For this entity the assignment of the argument would be:
--           p_base_key_value = :pl_id).
--
-- Post Success:
--   The specified row will be updated with the new effective end date and
--   object_version_number.
--
-- Post Failure:
--   Failure might occur if for the specified effective date and primary key
--   value a row doesn't exist.
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
Procedure upd_effective_end_date
	(p_effective_date		in date,
	 p_base_key_value		in number,
	 p_new_effective_end_date	in date,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date,
         p_object_version_number       out nocopy number);
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Lck process for datetrack is complicated and comprises of the
--   following processing
--   The processing steps are as follows:
--   1) The row to be updated or deleted must be locked.
--      By locking this row, the g_old_rec record data type is populated.
--   2) If a comment exists the text is selected from hr_comments.
--   3) The datetrack mode is then validated to ensure the operation is
--      valid. If the mode is valid the validation start and end dates for
--      the mode will be derived and returned. Any required locking is
--      completed when the datetrack mode is validated.
--
-- Prerequisites:
--   When attempting to call the lck procedure the object version number,
--   primary key, effective date and datetrack mode must be specified.
--
-- In Parameters:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update or delete mode.
--
-- Post Success:
--   On successful completion of the Lck process the row to be updated or
--   deleted will be locked and selected into the global data structure
--   g_old_rec.
--
-- Post Failure:
--   The Lck process can fail for three reasons:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) The row which is required to be locked doesn't exist in the HR Schema.
--      This error is trapped and reported using the message name
--      'HR_7220_INVALID_PRIMARY_KEY'.
--   3) The row although existing in the HR Schema has a different object
--      version number than the object version number specified.
--      This error is trapped and reported using the message name
--      'HR_7155_OBJECT_INVALID'.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure lck
	(p_effective_date	 in  date,
	 p_datetrack_mode	 in  varchar2,
	 p_pl_id	 in  number,
	 p_object_version_number in  number,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute parameters into the record
--   structure parameter g_rec_type.
--
-- Prerequisites:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Parameters:
--
-- Post Success:
--   A returning record structure will be returned.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
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
Function convert_args
	(
	p_pl_id                         in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_name                          in varchar2,
	p_alws_qdro_flag                in varchar2,
	p_alws_qmcso_flag               in varchar2,
	p_alws_reimbmts_flag            in varchar2,
	p_bnf_addl_instn_txt_alwd_flag  in varchar2,
	p_bnf_adrs_rqd_flag             in varchar2,
	p_bnf_cntngt_bnfs_alwd_flag     in varchar2,
	p_bnf_ctfn_rqd_flag             in varchar2,
	p_bnf_dob_rqd_flag              in varchar2,
	p_bnf_dsge_mnr_ttee_rqd_flag    in varchar2,
	p_bnf_incrmt_amt                in number,
	p_bnf_dflt_bnf_cd               in varchar2,
	p_bnf_legv_id_rqd_flag          in varchar2,
	p_bnf_may_dsgt_org_flag         in varchar2,
	p_bnf_mn_dsgntbl_amt            in number,
	p_bnf_mn_dsgntbl_pct_val        in number,
	p_rqd_perd_enrt_nenrt_val        in number,
	p_ordr_num        in number,
	p_bnf_pct_incrmt_val            in number,
	p_bnf_pct_amt_alwd_cd           in varchar2,
	p_bnf_qdro_rl_apls_flag         in varchar2,
	p_dflt_to_asn_pndg_ctfn_cd      in varchar2,
	p_dflt_to_asn_pndg_ctfn_rl      in number,
	p_drvbl_fctr_apls_rts_flag      in varchar2,
	p_drvbl_fctr_prtn_elig_flag     in varchar2,
	p_dpnt_dsgn_cd                  in varchar2,
	p_elig_apls_flag                in varchar2,
	p_invk_dcln_prtn_pl_flag        in varchar2,
	p_invk_flx_cr_pl_flag           in varchar2,
	p_imptd_incm_calc_cd            in varchar2,
	p_drvbl_dpnt_elig_flag          in varchar2,
	p_trk_inelig_per_flag           in varchar2,
	p_pl_cd                         in varchar2,
	p_auto_enrt_mthd_rl             in number,
	p_ivr_ident                     in varchar2,
        p_url_ref_name                  in varchar2,
	p_cmpr_clms_to_cvg_or_bal_cd    in varchar2,
	p_cobra_pymt_due_dy_num         in number,
	p_dpnt_cvd_by_othr_apls_flag    in varchar2,
	p_enrt_mthd_cd                  in varchar2,
	p_enrt_cd                       in varchar2,
	p_enrt_cvg_strt_dt_cd           in varchar2,
	p_enrt_cvg_end_dt_cd            in varchar2,
	p_frfs_aply_flag                in varchar2,
	p_hc_pl_subj_hcfa_aprvl_flag    in varchar2,
	p_hghly_cmpd_rl_apls_flag       in varchar2,
	p_incptn_dt                     in date,
	p_mn_cvg_rl                     in number,
	p_mn_cvg_rqd_amt                in number,
	p_mn_opts_rqd_num               in number,
	p_mx_cvg_alwd_amt               in number,
	p_mx_cvg_rl                     in number,
	p_mx_opts_alwd_num              in number,
	p_mx_cvg_wcfn_mlt_num           in number,
	p_mx_cvg_wcfn_amt               in number,
	p_mx_cvg_incr_alwd_amt          in number,
	p_mx_cvg_incr_wcf_alwd_amt      in number,
	p_mx_cvg_mlt_incr_num           in number,
	p_mx_cvg_mlt_incr_wcf_num       in number,
	p_mx_wtg_dt_to_use_cd           in varchar2,
	p_mx_wtg_dt_to_use_rl           in number,
	p_mx_wtg_perd_prte_uom          in varchar2,
	p_mx_wtg_perd_prte_val          in number,
        p_mx_wtg_perd_rl                in number,
	p_nip_dflt_enrt_cd              in varchar2,
	p_nip_dflt_enrt_det_rl          in number,
	p_dpnt_adrs_rqd_flag            in varchar2,
	p_dpnt_cvg_end_dt_cd            in varchar2,
	p_dpnt_cvg_end_dt_rl            in number,
	p_dpnt_cvg_strt_dt_cd           in varchar2,
	p_dpnt_cvg_strt_dt_rl           in number,
	p_dpnt_dob_rqd_flag             in varchar2,
	p_dpnt_leg_id_rqd_flag          in varchar2,
	p_dpnt_no_ctfn_rqd_flag         in varchar2,
	p_no_mn_cvg_amt_apls_flag       in varchar2,
	p_no_mn_cvg_incr_apls_flag      in varchar2,
	p_no_mn_opts_num_apls_flag      in varchar2,
	p_no_mx_cvg_amt_apls_flag       in varchar2,
	p_no_mx_cvg_incr_apls_flag      in varchar2,
	p_no_mx_opts_num_apls_flag      in varchar2,
	p_nip_pl_uom                    in varchar2,
	p_rqd_perd_enrt_nenrt_uom                    in varchar2,
	p_nip_acty_ref_perd_cd          in varchar2,
	p_nip_enrt_info_rt_freq_cd      in varchar2,
	p_per_cvrd_cd                   in varchar2,
	p_enrt_cvg_end_dt_rl            in number,
	p_postelcn_edit_rl              in number,
	p_enrt_cvg_strt_dt_rl           in number,
	p_prort_prtl_yr_cvg_rstrn_cd    in varchar2,
	p_prort_prtl_yr_cvg_rstrn_rl    in number,
	p_prtn_elig_ovrid_alwd_flag     in varchar2,
	p_svgs_pl_flag                  in varchar2,
	p_subj_to_imptd_incm_typ_cd     in varchar2,
	p_use_all_asnts_elig_flag       in varchar2,
	p_use_all_asnts_for_rt_flag     in varchar2,
	p_vstg_apls_flag                in varchar2,
	p_wvbl_flag                     in varchar2,
	p_hc_svc_typ_cd                 in varchar2,
	p_pl_stat_cd                    in varchar2,
	p_prmry_fndg_mthd_cd            in varchar2,
	p_rt_end_dt_cd                  in varchar2,
	p_rt_end_dt_rl                  in number,
	p_rt_strt_dt_rl                 in number,
	p_rt_strt_dt_cd                 in varchar2,
	p_bnf_dsgn_cd                   in varchar2,
	p_pl_typ_id                     in number,
	p_business_group_id             in number,
        p_enrt_pl_opt_flag              in varchar2,
        p_bnft_prvdr_pool_id            in number,
        p_MAY_ENRL_PL_N_OIPL_FLAG       in VARCHAR2,
        p_ENRT_RL                       in NUMBER,
        p_rqd_perd_enrt_nenrt_rl                       in NUMBER,
        p_ALWS_UNRSTRCTD_ENRT_FLAG      in VARCHAR2,
        p_BNFT_OR_OPTION_RSTRCTN_CD     in VARCHAR2,
        p_CVG_INCR_R_DECR_ONLY_CD       in VARCHAR2,
        p_unsspnd_enrt_cd               in varchar2,
 	p_pln_attribute_category        in varchar2,
	p_pln_attribute1                in varchar2,
	p_pln_attribute2                in varchar2,
	p_pln_attribute3                in varchar2,
	p_pln_attribute4                in varchar2,
	p_pln_attribute5                in varchar2,
	p_pln_attribute6                in varchar2,
	p_pln_attribute7                in varchar2,
	p_pln_attribute8                in varchar2,
	p_pln_attribute9                in varchar2,
	p_pln_attribute10               in varchar2,
	p_pln_attribute11               in varchar2,
	p_pln_attribute12               in varchar2,
	p_pln_attribute13               in varchar2,
	p_pln_attribute14               in varchar2,
	p_pln_attribute15               in varchar2,
	p_pln_attribute16               in varchar2,
	p_pln_attribute17               in varchar2,
	p_pln_attribute18               in varchar2,
	p_pln_attribute19               in varchar2,
	p_pln_attribute20               in varchar2,
	p_pln_attribute21               in varchar2,
	p_pln_attribute22               in varchar2,
	p_pln_attribute23               in varchar2,
	p_pln_attribute24               in varchar2,
	p_pln_attribute25               in varchar2,
	p_pln_attribute26               in varchar2,
	p_pln_attribute27               in varchar2,
	p_pln_attribute28               in varchar2,
	p_pln_attribute29               in varchar2,
	p_pln_attribute30               in varchar2,
        p_susp_if_ctfn_not_prvd_flag     in  varchar2,
        p_ctfn_determine_cd              in  varchar2,
        p_susp_if_dpnt_ssn_nt_prv_cd     in  varchar2,
        p_susp_if_dpnt_dob_nt_prv_cd     in  varchar2,
        p_susp_if_dpnt_adr_nt_prv_cd     in  varchar2,
        p_susp_if_ctfn_not_dpnt_flag     in  varchar2,
        p_susp_if_bnf_ssn_nt_prv_cd      in  varchar2,
        p_susp_if_bnf_dob_nt_prv_cd      in  varchar2,
        p_susp_if_bnf_adr_nt_prv_cd      in  varchar2,
        p_susp_if_ctfn_not_bnf_flag      in  varchar2,
        p_dpnt_ctfn_determine_cd         in  varchar2,
        p_bnf_ctfn_determine_cd          in  varchar2,
	p_object_version_number         in number,
	p_actl_prem_id                  in number,
        p_vrfy_fmly_mmbr_cd             in varchar2,
        p_vrfy_fmly_mmbr_rl             in number,
        p_ALWS_TMPRY_ID_CRD_FLAG        in VARCHAR2,
        p_nip_dflt_flag                 in VARCHAR2,
        p_frfs_distr_mthd_cd            in  varchar2,
        p_frfs_distr_mthd_rl            in  number,
        p_frfs_cntr_det_cd              in  varchar2,
        p_frfs_distr_det_cd             in  varchar2,
        p_cost_alloc_keyflex_1_id       in  number,
        p_cost_alloc_keyflex_2_id       in  number,
        p_post_to_gl_flag               in  varchar2,
        p_frfs_val_det_cd               in  varchar2,
        p_frfs_mx_cryfwd_val            in  number,
        p_frfs_portion_det_cd           in  varchar2,
        p_bndry_perd_cd                 in  varchar2,
        p_short_name		        in  varchar2,
	p_short_code		        in  varchar2,
	p_legislation_code	        in  varchar2,
	p_legislation_subgroup	        in  varchar2,
        p_group_pl_id                   in  number,
        p_mapping_table_name            in  varchar2,
        p_mapping_table_pk_id           in  number,
        p_function_code                 in  varchar2,
        p_pl_yr_not_applcbl_flag        in  varchar2,
        p_use_csd_rsd_prccng_cd         in  VARCHAR2
	)
	Return g_rec_type;
--
end ben_pln_shd;

/

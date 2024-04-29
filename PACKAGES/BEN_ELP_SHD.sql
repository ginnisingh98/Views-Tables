--------------------------------------------------------
--  DDL for Package BEN_ELP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELP_SHD" AUTHID CURRENT_USER as
/* $Header: beelprhi.pkh 120.1.12000000.1 2007/01/19 05:29:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  eligy_prfl_id                     number(15),
  effective_start_date              date,
  effective_end_date                date,
  name                              varchar2(240),
  description                       varchar2(2000),
  stat_cd                           varchar2(30),
  asmt_to_use_cd                    varchar2(30),
  elig_enrld_plip_flag              varchar2(30),
  elig_cbr_quald_bnf_flag           varchar2(30),
  elig_enrld_ptip_flag              varchar2(30),
  elig_dpnt_cvrd_plip_flag          varchar2(30),
  elig_dpnt_cvrd_ptip_flag          varchar2(30),
  elig_dpnt_cvrd_pgm_flag           varchar2(30),
  elig_job_flag                     varchar2(30),
  elig_hrly_slrd_flag               varchar2(30),
  elig_pstl_cd_flag                 varchar2(30),
  elig_lbr_mmbr_flag                varchar2(30),
  elig_lgl_enty_flag                varchar2(30),
  elig_benfts_grp_flag              varchar2(30),
  elig_wk_loc_flag                  varchar2(30),
  elig_brgng_unit_flag              varchar2(30),
  elig_age_flag                     varchar2(30),
  elig_los_flag                     varchar2(30),
  elig_per_typ_flag                 varchar2(30),
  elig_fl_tm_pt_tm_flag             varchar2(30),
  elig_ee_stat_flag                 varchar2(30),
  elig_grd_flag                     varchar2(30),
  elig_pct_fl_tm_flag               varchar2(30),
  elig_asnt_set_flag                varchar2(30),
  elig_hrs_wkd_flag                 varchar2(30),
  elig_comp_lvl_flag                varchar2(30),
  elig_org_unit_flag                varchar2(30),
  elig_loa_rsn_flag                 varchar2(30),
  elig_pyrl_flag                    varchar2(30),
  elig_schedd_hrs_flag              varchar2(30),
  elig_py_bss_flag                  varchar2(30),
  eligy_prfl_rl_flag                varchar2(30),
  elig_cmbn_age_los_flag            varchar2(30),
  cntng_prtn_elig_prfl_flag         varchar2(30),
  elig_prtt_pl_flag                 varchar2(30),
  elig_ppl_grp_flag                 varchar2(30),
  elig_svc_area_flag                varchar2(30),
  elig_ptip_prte_flag               varchar2(30),
  elig_no_othr_cvg_flag             varchar2(30),
  elig_enrld_pl_flag                varchar2(30),
  elig_enrld_oipl_flag              varchar2(30),
  elig_enrld_pgm_flag               varchar2(30),
  elig_dpnt_cvrd_pl_flag            varchar2(30),
  elig_lvg_rsn_flag                 varchar2(30),
  elig_optd_mdcr_flag               varchar2(30),
  elig_tbco_use_flag                varchar2(30),
  elig_dpnt_othr_ptip_flag          varchar2(30),
  business_group_id                 number(15),
  elp_attribute_category            varchar2(30),
  elp_attribute1                    varchar2(150),
  elp_attribute2                    varchar2(150),
  elp_attribute3                    varchar2(150),
  elp_attribute4                    varchar2(150),
  elp_attribute5                    varchar2(150),
  elp_attribute6                    varchar2(150),
  elp_attribute7                    varchar2(150),
  elp_attribute8                    varchar2(150),
  elp_attribute9                    varchar2(150),
  elp_attribute10                   varchar2(150),
  elp_attribute11                   varchar2(150),
  elp_attribute12                   varchar2(150),
  elp_attribute13                   varchar2(150),
  elp_attribute14                   varchar2(150),
  elp_attribute15                   varchar2(150),
  elp_attribute16                   varchar2(150),
  elp_attribute17                   varchar2(150),
  elp_attribute18                   varchar2(150),
  elp_attribute19                   varchar2(150),
  elp_attribute20                   varchar2(150),
  elp_attribute21                   varchar2(150),
  elp_attribute22                   varchar2(150),
  elp_attribute23                   varchar2(150),
  elp_attribute24                   varchar2(150),
  elp_attribute25                   varchar2(150),
  elp_attribute26                   varchar2(150),
  elp_attribute27                   varchar2(150),
  elp_attribute28                   varchar2(150),
  elp_attribute29                   varchar2(150),
  elp_attribute30                   varchar2(150),
  elig_mrtl_sts_flag                varchar2(30),
  elig_gndr_flag                    varchar2(30),
  elig_dsblty_ctg_flag              varchar2(30),
  elig_dsblty_rsn_flag              varchar2(30),
  elig_dsblty_dgr_flag              varchar2(30),
  elig_suppl_role_flag              varchar2(30),
  elig_qual_titl_flag               varchar2(30),
  elig_pstn_flag                    varchar2(30),
  elig_prbtn_perd_flag              varchar2(30),
  elig_sp_clng_prg_pt_flag          varchar2(30),
  bnft_cagr_prtn_cd                 varchar2(30),
  elig_dsbld_flag                   varchar2(30),
  elig_ttl_cvg_vol_flag             varchar2(30),
  elig_ttl_prtt_flag                varchar2(30),
  elig_comptncy_flag                varchar2(30),
  elig_hlth_cvg_flag                varchar2(30),
  elig_anthr_pl_flag                varchar2(30),
  elig_qua_in_gr_flag		    varchar2(30),
  elig_perf_rtng_flag		    varchar2(30),
  elig_crit_values_flag             varchar2(30),   /* RBC */
  object_version_number             number(9)
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
   p_eligy_prfl_id		in number,
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
--           p_base_key_value = :eligy_prfl_id).
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
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_zap		 out nocopy boolean,
	 p_delete	 out nocopy boolean,
	 p_future_change out nocopy boolean,
	 p_delete_next_change out nocopy boolean);
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
--           p_base_key_value = :eligy_prfl_id).
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
--           p_base_key_value = :eligy_prfl_id).
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
	 p_eligy_prfl_id	 in  number,
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
	p_eligy_prfl_id                 in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_name                          in varchar2,
	p_description                   in varchar2,
	p_stat_cd                       in varchar2,
	p_asmt_to_use_cd                in varchar2,
        p_elig_enrld_plip_flag          in varchar2,
        p_elig_cbr_quald_bnf_flag       in varchar2,
        p_elig_enrld_ptip_flag          in varchar2,
        p_elig_dpnt_cvrd_plip_flag      in varchar2,
        p_elig_dpnt_cvrd_ptip_flag      in varchar2,
        p_elig_dpnt_cvrd_pgm_flag       in varchar2,
        p_elig_job_flag                 in varchar2,
        p_elig_hrly_slrd_flag           in varchar2,
        p_elig_pstl_cd_flag             in varchar2,
        p_elig_lbr_mmbr_flag            in varchar2,
        p_elig_lgl_enty_flag            in varchar2,
        p_elig_benfts_grp_flag          in varchar2,
        p_elig_wk_loc_flag              in varchar2,
        p_elig_brgng_unit_flag          in varchar2,
        p_elig_age_flag                 in varchar2,
        p_elig_los_flag                 in varchar2,
        p_elig_per_typ_flag             in varchar2,
        p_elig_fl_tm_pt_tm_flag         in varchar2,
        p_elig_ee_stat_flag             in varchar2,
        p_elig_grd_flag                 in varchar2,
        p_elig_pct_fl_tm_flag           in varchar2,
        p_elig_asnt_set_flag            in varchar2,
        p_elig_hrs_wkd_flag             in varchar2,
        p_elig_comp_lvl_flag            in varchar2,
        p_elig_org_unit_flag            in varchar2,
        p_elig_loa_rsn_flag             in varchar2,
        p_elig_pyrl_flag                in varchar2,
        p_elig_schedd_hrs_flag          in varchar2,
        p_elig_py_bss_flag              in varchar2,
        p_eligy_prfl_rl_flag            in varchar2,
        p_elig_cmbn_age_los_flag        in varchar2,
        p_cntng_prtn_elig_prfl_flag     in varchar2,
        p_elig_prtt_pl_flag             in varchar2,
        p_elig_ppl_grp_flag             in varchar2,
        p_elig_svc_area_flag            in varchar2,
        p_elig_ptip_prte_flag           in varchar2,
        p_elig_no_othr_cvg_flag         in varchar2,
        p_elig_enrld_pl_flag            in varchar2,
        p_elig_enrld_oipl_flag          in varchar2,
        p_elig_enrld_pgm_flag           in varchar2,
        p_elig_dpnt_cvrd_pl_flag        in varchar2,
        p_elig_lvg_rsn_flag             in varchar2,
        p_elig_optd_mdcr_flag           in varchar2,
        p_elig_tbco_use_flag            in varchar2,
        p_elig_dpnt_othr_ptip_flag      in varchar2,
	p_business_group_id             in number,
	p_elp_attribute_category        in varchar2,
	p_elp_attribute1                in varchar2,
	p_elp_attribute2                in varchar2,
	p_elp_attribute3                in varchar2,
	p_elp_attribute4                in varchar2,
	p_elp_attribute5                in varchar2,
	p_elp_attribute6                in varchar2,
	p_elp_attribute7                in varchar2,
	p_elp_attribute8                in varchar2,
	p_elp_attribute9                in varchar2,
	p_elp_attribute10               in varchar2,
	p_elp_attribute11               in varchar2,
	p_elp_attribute12               in varchar2,
	p_elp_attribute13               in varchar2,
	p_elp_attribute14               in varchar2,
	p_elp_attribute15               in varchar2,
	p_elp_attribute16               in varchar2,
	p_elp_attribute17               in varchar2,
	p_elp_attribute18               in varchar2,
	p_elp_attribute19               in varchar2,
	p_elp_attribute20               in varchar2,
	p_elp_attribute21               in varchar2,
	p_elp_attribute22               in varchar2,
	p_elp_attribute23               in varchar2,
	p_elp_attribute24               in varchar2,
	p_elp_attribute25               in varchar2,
	p_elp_attribute26               in varchar2,
	p_elp_attribute27               in varchar2,
	p_elp_attribute28               in varchar2,
	p_elp_attribute29               in varchar2,
	p_elp_attribute30               in varchar2,
        p_elig_mrtl_sts_flag            in varchar2,
        p_elig_gndr_flag                in varchar2,
        p_elig_dsblty_ctg_flag          in varchar2,
        p_elig_dsblty_rsn_flag          in varchar2,
        p_elig_dsblty_dgr_flag          in varchar2,
        p_elig_suppl_role_flag          in varchar2,
        p_elig_qual_titl_flag           in varchar2,
        p_elig_pstn_flag                in varchar2,
        p_elig_prbtn_perd_flag          in varchar2,
        p_elig_sp_clng_prg_pt_flag      in varchar2,
        p_bnft_cagr_prtn_cd             in varchar2,
	p_elig_dsbld_flag               in varchar2,
	p_elig_ttl_cvg_vol_flag         in varchar2,
	p_elig_ttl_prtt_flag            in varchar2,
	p_elig_comptncy_flag            in varchar2,
	p_elig_hlth_cvg_flag		in varchar2,
	p_elig_anthr_pl_flag		in varchar2,
	p_elig_qua_in_gr_flag		in varchar2,
	p_elig_perf_rtng_flag		in varchar2,
        p_elig_crit_values_flag         in varchar2,   /* RBC */
        p_object_version_number         in number
	)
	Return g_rec_type;
--
end ben_elp_shd;

 

/
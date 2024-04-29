--------------------------------------------------------
--  DDL for Package BEN_VPF_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VPF_SHD" AUTHID CURRENT_USER as
/* $Header: bevpfrhi.pkh 120.0.12010000.1 2008/07/29 13:07:58 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  vrbl_rt_prfl_id                   number(15),
  effective_start_date              date,
  effective_end_date                date,
  pl_typ_opt_typ_id                 number(15),
  pl_id                             number(15),
  oipl_id                           number(15),
  comp_lvl_fctr_id                  number(15),
  business_group_id                 number(15),
  acty_typ_cd                       varchar2(30),
  rt_typ_cd                         varchar2(30),
  bnft_rt_typ_cd                    varchar2(30),
  tx_typ_cd                         varchar2(30),
  vrbl_rt_trtmt_cd                  varchar2(30),
  acty_ref_perd_cd                  varchar2(30),
  mlt_cd                            varchar2(30),
  incrmnt_elcn_val                  number,        --(15,6),
  dflt_elcn_val                     number,        --(15,6),
  mx_elcn_val                       number,        --(15,6),
  mn_elcn_val                       number,        --(15,6),
  lwr_lmt_val                       number,
  lwr_lmt_calc_rl                   number(15),
  upr_lmt_val                       number,
  upr_lmt_calc_rl                   number(15),
  ultmt_upr_lmt                     number,
  ultmt_lwr_lmt                     number,
  ultmt_upr_lmt_calc_rl             number(15),
  ultmt_lwr_lmt_calc_rl             number(15),
  ann_mn_elcn_val                   number,
  ann_mx_elcn_val                   number,
  val                               number,        --(15,6),
  name                              varchar2(240),
  no_mn_elcn_val_dfnd_flag          varchar2(30),
  no_mx_elcn_val_dfnd_flag          varchar2(30),
  alwys_sum_all_cvg_flag            varchar2(30),
  alwys_cnt_all_prtts_flag          varchar2(30),
  val_calc_rl                       number(15),
  vrbl_rt_prfl_stat_cd              varchar2(30),
  vrbl_usg_cd                       varchar2(30),
  asmt_to_use_cd                    varchar2(30),
  rndg_cd                           varchar2(30),
  rndg_rl                           number(15),
  rt_hrly_slrd_flag                 varchar2(30),
  rt_pstl_cd_flag                   varchar2(30),
  rt_lbr_mmbr_flag                  varchar2(30),
  rt_lgl_enty_flag                  varchar2(30),
  rt_benfts_grp_flag                varchar2(30),
  rt_wk_loc_flag                    varchar2(30),
  rt_brgng_unit_flag                varchar2(30),
  rt_age_flag                       varchar2(30),
  rt_los_flag                       varchar2(30),
  rt_per_typ_flag                   varchar2(30),
  rt_fl_tm_pt_tm_flag               varchar2(30),
  rt_ee_stat_flag                   varchar2(30),
  rt_grd_flag                       varchar2(30),
  rt_pct_fl_tm_flag                 varchar2(30),
  rt_asnt_set_flag                  varchar2(30),
  rt_hrs_wkd_flag                   varchar2(30),
  rt_comp_lvl_flag                  varchar2(30),
  rt_org_unit_flag                  varchar2(30),
  rt_loa_rsn_flag                   varchar2(30),
  rt_pyrl_flag                      varchar2(30),
  rt_schedd_hrs_flag                varchar2(30),
  rt_py_bss_flag                    varchar2(30),
  rt_prfl_rl_flag                   varchar2(30),
  rt_cmbn_age_los_flag              varchar2(30),
  rt_prtt_pl_flag                   varchar2(30),
  rt_svc_area_flag                  varchar2(30),
  rt_ppl_grp_flag                   varchar2(30),
  rt_dsbld_flag                     varchar2(30),
  rt_hlth_cvg_flag                  varchar2(30),
  rt_poe_flag                       varchar2(30),
  rt_ttl_cvg_vol_flag               varchar2(30),
  rt_ttl_prtt_flag                  varchar2(30),
  rt_gndr_flag                      varchar2(30),
  rt_tbco_use_flag                  varchar2(30),
  vpf_attribute_category            varchar2(30),
  vpf_attribute1                    varchar2(150),
  vpf_attribute2                    varchar2(150),
  vpf_attribute3                    varchar2(150),
  vpf_attribute4                    varchar2(150),
  vpf_attribute5                    varchar2(150),
  vpf_attribute6                    varchar2(150),
  vpf_attribute7                    varchar2(150),
  vpf_attribute8                    varchar2(150),
  vpf_attribute9                    varchar2(150),
  vpf_attribute10                   varchar2(150),
  vpf_attribute11                   varchar2(150),
  vpf_attribute12                   varchar2(150),
  vpf_attribute13                   varchar2(150),
  vpf_attribute14                   varchar2(150),
  vpf_attribute15                   varchar2(150),
  vpf_attribute16                   varchar2(150),
  vpf_attribute17                   varchar2(150),
  vpf_attribute18                   varchar2(150),
  vpf_attribute19                   varchar2(150),
  vpf_attribute20                   varchar2(150),
  vpf_attribute21                   varchar2(150),
  vpf_attribute22                   varchar2(150),
  vpf_attribute23                   varchar2(150),
  vpf_attribute24                   varchar2(150),
  vpf_attribute25                   varchar2(150),
  vpf_attribute26                   varchar2(150),
  vpf_attribute27                   varchar2(150),
  vpf_attribute28                   varchar2(150),
  vpf_attribute29                   varchar2(150),
  vpf_attribute30                   varchar2(150),
  object_version_number             number(9),
  rt_cntng_prtn_prfl_flag           varchar2(30),
  rt_cbr_quald_bnf_flag             varchar2(30),
  rt_optd_mdcr_flag                 varchar2(30),
  rt_lvg_rsn_flag                   varchar2(30),
  rt_pstn_flag                      varchar2(30),
  rt_comptncy_flag                  varchar2(30),
  rt_job_flag                       varchar2(30),
  rt_qual_titl_flag                 varchar2(30),
  rt_dpnt_cvrd_pl_flag              varchar2(30),
  rt_dpnt_cvrd_plip_flag            varchar2(30),
  rt_dpnt_cvrd_ptip_flag            varchar2(30),
  rt_dpnt_cvrd_pgm_flag             varchar2(30),
  rt_enrld_oipl_flag                varchar2(30),
  rt_enrld_pl_flag                  varchar2(30),
  rt_enrld_plip_flag                varchar2(30),
  rt_enrld_ptip_flag                varchar2(30),
  rt_enrld_pgm_flag                 varchar2(30),
  rt_prtt_anthr_pl_flag             varchar2(30),
  rt_othr_ptip_flag                 varchar2(30),
  rt_no_othr_cvg_flag               varchar2(30),
  rt_dpnt_othr_ptip_flag            varchar2(30),
  rt_qua_in_gr_flag    	    	    varchar2(30),
  rt_perf_rtng_flag    	            varchar2(30),
  rt_elig_prfl_flag    	            varchar2(30)
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
   p_vrbl_rt_prfl_id		in number,
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
--           p_base_key_value = :vrbl_rt_prfl_id).
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
--           p_base_key_value = :vrbl_rt_prfl_id).
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
--           p_base_key_value = :vrbl_rt_prfl_id).
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
	 p_vrbl_rt_prfl_id	 in  number,
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
	p_vrbl_rt_prfl_id               in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_pl_typ_opt_typ_id             in number,
	p_pl_id                         in number,
	p_oipl_id                       in number,
        p_comp_lvl_fctr_id              in number,
	p_business_group_id             in number,
	p_acty_typ_cd                   in varchar2,
	p_rt_typ_cd                     in varchar2,
	p_bnft_rt_typ_cd                in varchar2,
	p_tx_typ_cd                     in varchar2,
	p_vrbl_rt_trtmt_cd              in varchar2,
	p_acty_ref_perd_cd              in varchar2,
	p_mlt_cd                        in varchar2,
	p_incrmnt_elcn_val              in number,
	p_dflt_elcn_val                 in number,
	p_mx_elcn_val                   in number,
	p_mn_elcn_val                   in number,
        p_lwr_lmt_val                   in number,
        p_lwr_lmt_calc_rl               in number,
        p_upr_lmt_val                   in number,
        p_upr_lmt_calc_rl               in number,
        p_ultmt_upr_lmt                 in number,
        p_ultmt_lwr_lmt                 in number,
        p_ultmt_upr_lmt_calc_rl         in number,
        p_ultmt_lwr_lmt_calc_rl         in number,
        p_ann_mn_elcn_val               in number,
        p_ann_mx_elcn_val               in number,
	p_val                           in number,
	p_name                          in varchar2,
	p_no_mn_elcn_val_dfnd_flag      in varchar2,
	p_no_mx_elcn_val_dfnd_flag      in varchar2,
        p_alwys_sum_all_cvg_flag        in varchar2,
        p_alwys_cnt_all_prtts_flag      in varchar2,
	p_val_calc_rl                   in number,
	p_vrbl_rt_prfl_stat_cd          in varchar2,
        p_vrbl_usg_cd                   in varchar2,
        p_asmt_to_use_cd                in varchar2,
        p_rndg_cd                       in varchar2,
        p_rndg_rl                       in number,
        p_rt_hrly_slrd_flag             in varchar2,
        p_rt_pstl_cd_flag               in varchar2,
        p_rt_lbr_mmbr_flag              in varchar2,
        p_rt_lgl_enty_flag              in varchar2,
        p_rt_benfts_grp_flag            in varchar2,
        p_rt_wk_loc_flag                in varchar2,
        p_rt_brgng_unit_flag            in varchar2,
        p_rt_age_flag                   in varchar2,
        p_rt_los_flag                   in varchar2,
        p_rt_per_typ_flag               in varchar2,
        p_rt_fl_tm_pt_tm_flag           in varchar2,
        p_rt_ee_stat_flag               in varchar2,
        p_rt_grd_flag                   in varchar2,
        p_rt_pct_fl_tm_flag             in varchar2,
        p_rt_asnt_set_flag              in varchar2,
        p_rt_hrs_wkd_flag               in varchar2,
        p_rt_comp_lvl_flag              in varchar2,
        p_rt_org_unit_flag              in varchar2,
        p_rt_loa_rsn_flag               in varchar2,
        p_rt_pyrl_flag                  in varchar2,
        p_rt_schedd_hrs_flag            in varchar2,
        p_rt_py_bss_flag                in varchar2,
        p_rt_prfl_rl_flag               in varchar2,
        p_rt_cmbn_age_los_flag          in varchar2,
        p_rt_prtt_pl_flag               in varchar2,
        p_rt_svc_area_flag              in varchar2,
        p_rt_ppl_grp_flag               in varchar2,
        p_rt_dsbld_flag                 in varchar2,
        p_rt_hlth_cvg_flag              in varchar2,
        p_rt_poe_flag                   in varchar2,
        p_rt_ttl_cvg_vol_flag           in varchar2,
        p_rt_ttl_prtt_flag              in varchar2,
        p_rt_gndr_flag                  in varchar2,
        p_rt_tbco_use_flag              in varchar2,
	p_vpf_attribute_category        in varchar2,
	p_vpf_attribute1                in varchar2,
	p_vpf_attribute2                in varchar2,
	p_vpf_attribute3                in varchar2,
	p_vpf_attribute4                in varchar2,
	p_vpf_attribute5                in varchar2,
	p_vpf_attribute6                in varchar2,
	p_vpf_attribute7                in varchar2,
	p_vpf_attribute8                in varchar2,
	p_vpf_attribute9                in varchar2,
	p_vpf_attribute10               in varchar2,
	p_vpf_attribute11               in varchar2,
	p_vpf_attribute12               in varchar2,
	p_vpf_attribute13               in varchar2,
	p_vpf_attribute14               in varchar2,
	p_vpf_attribute15               in varchar2,
	p_vpf_attribute16               in varchar2,
	p_vpf_attribute17               in varchar2,
	p_vpf_attribute18               in varchar2,
	p_vpf_attribute19               in varchar2,
	p_vpf_attribute20               in varchar2,
	p_vpf_attribute21               in varchar2,
	p_vpf_attribute22               in varchar2,
	p_vpf_attribute23               in varchar2,
	p_vpf_attribute24               in varchar2,
	p_vpf_attribute25               in varchar2,
	p_vpf_attribute26               in varchar2,
	p_vpf_attribute27               in varchar2,
	p_vpf_attribute28               in varchar2,
	p_vpf_attribute29               in varchar2,
	p_vpf_attribute30               in varchar2,
	p_object_version_number         in number ,
	p_rt_cntng_prtn_prfl_flag	in varchar2,
	p_rt_cbr_quald_bnf_flag  	in varchar2,
	p_rt_optd_mdcr_flag      	in varchar2,
	p_rt_lvg_rsn_flag        	in varchar2,
	p_rt_pstn_flag           	in varchar2,
	p_rt_comptncy_flag       	in varchar2,
	p_rt_job_flag            	in varchar2,
	p_rt_qual_titl_flag      	in varchar2,
	p_rt_dpnt_cvrd_pl_flag   	in varchar2,
	p_rt_dpnt_cvrd_plip_flag 	in varchar2,
	p_rt_dpnt_cvrd_ptip_flag 	in varchar2,
	p_rt_dpnt_cvrd_pgm_flag  	in varchar2,
	p_rt_enrld_oipl_flag     	in varchar2,
	p_rt_enrld_pl_flag       	in varchar2,
	p_rt_enrld_plip_flag     	in varchar2,
	p_rt_enrld_ptip_flag     	in varchar2,
	p_rt_enrld_pgm_flag      	in varchar2,
	p_rt_prtt_anthr_pl_flag  	in varchar2,
	p_rt_othr_ptip_flag      	in varchar2,
	p_rt_no_othr_cvg_flag    	in varchar2,
	p_rt_dpnt_othr_ptip_flag 	in varchar2,
 	p_rt_qua_in_gr_flag             in varchar2,
	p_rt_perf_rtng_flag 	        in varchar2,
	p_rt_elig_prfl_flag 	        in varchar2
	)
	Return g_rec_type;
--
end ben_vpf_shd;

/

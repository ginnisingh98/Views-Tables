--------------------------------------------------------
--  DDL for Package BEN_ABR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ABR_SHD" AUTHID CURRENT_USER as
/* $Header: beabrrhi.pkh 120.7 2008/05/15 06:23:00 pvelvano noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  acty_base_rt_id                   number(15),
  effective_start_date              date,
  effective_end_date                date,
  ordr_num			    number(15),
  acty_typ_cd                       varchar2(30),
  sub_acty_typ_cd                       varchar2(30),
  name                              varchar2(240),
  rt_typ_cd                         varchar2(30),
  bnft_rt_typ_cd                    varchar2(30),
  tx_typ_cd                         varchar2(30),
  use_to_calc_net_flx_cr_flag       varchar2(30),
  asn_on_enrt_flag                  varchar2(30),
  abv_mx_elcn_val_alwd_flag         varchar2(30),
  blw_mn_elcn_alwd_flag             varchar2(30),
  dsply_on_enrt_flag                varchar2(30),
  parnt_chld_cd                     varchar2(30),
  use_calc_acty_bs_rt_flag          varchar2(30),
  uses_ded_sched_flag               varchar2(30),
  uses_varbl_rt_flag                varchar2(30),
  vstg_sched_apls_flag              varchar2(30),
  rt_mlt_cd                         varchar2(30),
  proc_each_pp_dflt_flag            varchar2(30),
  prdct_flx_cr_when_elig_flag       varchar2(30),
  no_std_rt_used_flag               varchar2(30),
  rcrrg_cd                          varchar2(30),
  mn_elcn_val                       number,
  mx_elcn_val                       number,
  lwr_lmt_val                       number,
  lwr_lmt_calc_rl                   number(15),
  upr_lmt_val                       number,
  upr_lmt_calc_rl                   number(15),
  ptd_comp_lvl_fctr_id              number(15),
  clm_comp_lvl_fctr_id              number(15),
  entr_ann_val_flag                 varchar2(30),
  ann_mn_elcn_val                   number,
  ann_mx_elcn_val                   number,
  wsh_rl_dy_mo_num                  number(15),
  uses_pymt_sched_flag              varchar2(30),
  nnmntry_uom                       varchar2(30),
  val                               number,
  incrmt_elcn_val                   number,
  rndg_cd                           varchar2(30),
  val_ovrid_alwd_flag               varchar2(30),
  prtl_mo_det_mthd_cd               varchar2(30),
  acty_base_rt_stat_cd              varchar2(30),
  procg_src_cd                      varchar2(30),
  dflt_val                          number,
  dflt_flag                         varchar2(30),
  frgn_erg_ded_typ_cd               varchar2(30),
  frgn_erg_ded_name                 varchar2(240),
  frgn_erg_ded_ident                varchar2(90),
  no_mx_elcn_val_dfnd_flag          varchar2(30),
  prtl_mo_det_mthd_rl               number(15),
  entr_val_at_enrt_flag             varchar2(30),
  prtl_mo_eff_dt_det_rl             number(15),
  rndg_rl                           number(15),
  val_calc_rl                       number(15),
  no_mn_elcn_val_dfnd_flag          varchar2(30),
  prtl_mo_eff_dt_det_cd             varchar2(30),
  only_one_bal_typ_alwd_flag        varchar2(30),
  rt_usg_cd                         varchar2(30),
  prort_mn_ann_elcn_val_cd          varchar2(30),
  prort_mn_ann_elcn_val_rl          number(15),
  prort_mx_ann_elcn_val_cd          varchar2(30),
  prort_mx_ann_elcn_val_rl          number(15),
  one_ann_pymt_cd                   varchar2(30),
  det_pl_ytd_cntrs_cd               varchar2(30),
  asmt_to_use_cd                    varchar2(30),
  ele_rqd_flag                      varchar2(30),
  subj_to_imptd_incm_flag           varchar2(30),
  element_type_id                   number(15),
  input_value_id                    number(15),
  input_va_calc_rl                  number(15),
  comp_lvl_fctr_id                  number(15),
  parnt_acty_base_rt_id             number(15),
  pgm_id                            number(15),
  pl_id                             number(15),
  oipl_id                           number(15),
  opt_id                            number(15),
  oiplip_id                         number(15),
  plip_id                           number(15),
  ptip_id                           number(15),
  cmbn_plip_id                      number(15),
  cmbn_ptip_id                      number(15),
  cmbn_ptip_opt_id                  number(15),
  vstg_for_acty_rt_id               number(15),
  actl_prem_id                      number(15),
  TTL_COMP_LVL_FCTR_ID              number(15),
  COST_ALLOCATION_KEYFLEX_ID        number(15),
  ALWS_CHG_CD                       varchar2(30),
  ele_entry_val_cd                  varchar2(30),
  pay_rate_grade_rule_id            number(15),
  rate_periodization_cd             varchar2(30),
  rate_periodization_rl             number(15),
  mn_mx_elcn_rl			    number,
  mapping_table_name                varchar2(60),
  mapping_table_pk_id               number,
  business_group_id                 number(15),
  context_pgm_id                    number(15),
  context_pl_id                     number(15),
  context_opt_id                    number(15),
  element_det_rl                    number(15),
  currency_det_cd                   varchar2(30),
  abr_attribute_category            varchar2(30),
  abr_attribute1                    varchar2(150),
  abr_attribute2                    varchar2(150),
  abr_attribute3                    varchar2(150),
  abr_attribute4                    varchar2(150),
  abr_attribute5                    varchar2(150),
  abr_attribute6                    varchar2(150),
  abr_attribute7                    varchar2(150),
  abr_attribute8                    varchar2(150),
  abr_attribute9                    varchar2(150),
  abr_attribute10                   varchar2(150),
  abr_attribute11                   varchar2(150),
  abr_attribute12                   varchar2(150),
  abr_attribute13                   varchar2(150),
  abr_attribute14                   varchar2(150),
  abr_attribute15                   varchar2(150),
  abr_attribute16                   varchar2(150),
  abr_attribute17                   varchar2(150),
  abr_attribute18                   varchar2(150),
  abr_attribute19                   varchar2(150),
  abr_attribute20                   varchar2(150),
  abr_attribute21                   varchar2(150),
  abr_attribute22                   varchar2(150),
  abr_attribute23                   varchar2(150),
  abr_attribute24                   varchar2(150),
  abr_attribute25                   varchar2(150),
  abr_attribute26                   varchar2(150),
  abr_attribute27                   varchar2(150),
  abr_attribute28                   varchar2(150),
  abr_attribute29                   varchar2(150),
  abr_attribute30                   varchar2(150),
  abr_seq_num                       number(15),
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
   p_acty_base_rt_id		in number,
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
--           p_base_key_value = :acty_base_rt_id).
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
--           p_base_key_value = :acty_base_rt_id).
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
--           p_base_key_value = :acty_base_rt_id).
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
	 p_acty_base_rt_id	 in  number,
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
	p_acty_base_rt_id               in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_ordr_num			in number,
	p_acty_typ_cd                   in varchar2,
	p_sub_acty_typ_cd               in varchar2,
	p_name                          in varchar2,
	p_rt_typ_cd                     in varchar2,
	p_bnft_rt_typ_cd                in varchar2,
	p_tx_typ_cd                     in varchar2,
	p_use_to_calc_net_flx_cr_flag   in varchar2,
	p_asn_on_enrt_flag              in varchar2,
	p_abv_mx_elcn_val_alwd_flag     in varchar2,
	p_blw_mn_elcn_alwd_flag         in varchar2,
	p_dsply_on_enrt_flag            in varchar2,
	p_parnt_chld_cd                 in varchar2,
	p_use_calc_acty_bs_rt_flag      in varchar2,
	p_uses_ded_sched_flag           in varchar2,
	p_uses_varbl_rt_flag            in varchar2,
	p_vstg_sched_apls_flag          in varchar2,
	p_rt_mlt_cd                     in varchar2,
	p_proc_each_pp_dflt_flag        in varchar2,
	p_prdct_flx_cr_when_elig_flag   in varchar2,
	p_no_std_rt_used_flag           in varchar2,
	p_rcrrg_cd                      in varchar2,
	p_mn_elcn_val                   in number,
	p_mx_elcn_val                   in number,
        p_lwr_lmt_val                   in number,
        p_lwr_lmt_calc_rl               in number,
        p_upr_lmt_val                   in number,
        p_upr_lmt_calc_rl               in number,
        p_ptd_comp_lvl_fctr_id          in number,
        p_clm_comp_lvl_fctr_id          in number,
        p_entr_ann_val_flag             in varchar2,
        p_ann_mn_elcn_val               in number,
        p_ann_mx_elcn_val               in number,
        p_wsh_rl_dy_mo_num              in number,
	p_uses_pymt_sched_flag          in varchar2,
	p_nnmntry_uom                   in varchar2,
	p_val                           in number,
	p_incrmt_elcn_val               in number,
	p_rndg_cd                       in varchar2,
	p_val_ovrid_alwd_flag           in varchar2,
	p_prtl_mo_det_mthd_cd           in varchar2,
	p_acty_base_rt_stat_cd          in varchar2,
	p_procg_src_cd                  in varchar2,
	p_dflt_val                      in number,
	p_dflt_flag                     in varchar2,
	p_frgn_erg_ded_typ_cd           in varchar2,
	p_frgn_erg_ded_name             in varchar2,
	p_frgn_erg_ded_ident            in varchar2,
	p_no_mx_elcn_val_dfnd_flag      in varchar2,
	p_prtl_mo_det_mthd_rl           in number,
	p_entr_val_at_enrt_flag         in varchar2,
	p_prtl_mo_eff_dt_det_rl         in number,
	p_rndg_rl                       in number,
	p_val_calc_rl                   in number,
	p_no_mn_elcn_val_dfnd_flag      in varchar2,
	p_prtl_mo_eff_dt_det_cd         in varchar2,
	p_only_one_bal_typ_alwd_flag    in varchar2,
	p_rt_usg_cd                     in varchar2,
        p_prort_mn_ann_elcn_val_cd      in varchar2,
        p_prort_mn_ann_elcn_val_rl      in number,
        p_prort_mx_ann_elcn_val_cd      in varchar2,
        p_prort_mx_ann_elcn_val_rl      in number,
        p_one_ann_pymt_cd               in varchar2,
        p_det_pl_ytd_cntrs_cd           in varchar2,
        p_asmt_to_use_cd                in varchar2,
        p_ele_rqd_flag                  in varchar2,
        p_subj_to_imptd_incm_flag       in varchar2,
	p_element_type_id               in number,
        p_input_value_id                in number,
        p_input_va_calc_rl              in number,
        p_comp_lvl_fctr_id              in number,
        p_parnt_acty_base_rt_id         in number,
	p_pgm_id                        in number,
	p_pl_id                         in number,
	p_oipl_id                       in number,
        p_opt_id                        in number,
        p_oiplip_id                     in number,
	p_plip_id                       in number,
	p_ptip_id                       in number,
	p_cmbn_plip_id                  in number,
	p_cmbn_ptip_id                  in number,
	p_cmbn_ptip_opt_id              in number,
	p_vstg_for_acty_rt_id           in number,
        p_actl_prem_id                  in number,
        p_TTL_COMP_LVL_FCTR_ID          in number,
        p_COST_ALLOCATION_KEYFLEX_ID    in number,
        p_ALWS_CHG_CD                   in varchar2,
        p_ele_entry_val_cd              in varchar2,
        p_pay_rate_grade_rule_id        in number,
        p_rate_periodization_cd         in varchar2,
        p_rate_periodization_rl          in number,
	p_mn_mx_elcn_rl 		in number,
	p_mapping_table_name            in varchar2,
	p_mapping_table_pk_id            in number,
	p_business_group_id             in number,
        p_context_pgm_id                  in number,
        p_context_pl_id                   in number,
        p_context_opt_id                  in number,
	p_element_det_rl                  in number,
        p_currency_det_cd                 in varchar2,
	p_abr_attribute_category        in varchar2,
	p_abr_attribute1                in varchar2,
	p_abr_attribute2                in varchar2,
	p_abr_attribute3                in varchar2,
	p_abr_attribute4                in varchar2,
	p_abr_attribute5                in varchar2,
	p_abr_attribute6                in varchar2,
	p_abr_attribute7                in varchar2,
	p_abr_attribute8                in varchar2,
	p_abr_attribute9                in varchar2,
	p_abr_attribute10               in varchar2,
	p_abr_attribute11               in varchar2,
	p_abr_attribute12               in varchar2,
	p_abr_attribute13               in varchar2,
	p_abr_attribute14               in varchar2,
	p_abr_attribute15               in varchar2,
	p_abr_attribute16               in varchar2,
	p_abr_attribute17               in varchar2,
	p_abr_attribute18               in varchar2,
	p_abr_attribute19               in varchar2,
	p_abr_attribute20               in varchar2,
	p_abr_attribute21               in varchar2,
	p_abr_attribute22               in varchar2,
	p_abr_attribute23               in varchar2,
	p_abr_attribute24               in varchar2,
	p_abr_attribute25               in varchar2,
	p_abr_attribute26               in varchar2,
	p_abr_attribute27               in varchar2,
	p_abr_attribute28               in varchar2,
	p_abr_attribute29               in varchar2,
	p_abr_attribute30               in varchar2,
	p_abr_seq_num                   in  number,
	p_object_version_number         in number
	)
	Return g_rec_type;
--
end ben_abr_shd;

/

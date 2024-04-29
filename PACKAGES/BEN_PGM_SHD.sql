--------------------------------------------------------
--  DDL for Package BEN_PGM_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PGM_SHD" AUTHID CURRENT_USER as
/* $Header: bepgmrhi.pkh 120.0 2005/05/28 10:47:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  pgm_id                            number(15),
  effective_start_date              date,
  effective_end_date                date,
  name                              varchar2(240), -- UTF8 Change Bug 2254683
  dpnt_adrs_rqd_flag                varchar2(30),
  pgm_prvds_no_auto_enrt_flag       varchar2(30),
  dpnt_dob_rqd_flag                 varchar2(30),
  pgm_prvds_no_dflt_enrt_flag       varchar2(30),
  dpnt_legv_id_rqd_flag             varchar2(30),
  dpnt_dsgn_lvl_cd                  varchar2(30),
  pgm_stat_cd                       varchar2(30),
  ivr_ident                         varchar2(90), -- UTF8 Change Bug 2254683
  pgm_typ_cd                        varchar2(30),
  elig_apls_flag                    varchar2(30),
  uses_all_asmts_for_rts_flag       varchar2(30),
  url_ref_name                      varchar2(240),
  pgm_desc                          varchar2(2000),
  prtn_elig_ovrid_alwd_flag         varchar2(30),
  pgm_use_all_asnts_elig_flag       varchar2(30),
  dpnt_dsgn_cd                      varchar2(30),
  mx_dpnt_pct_prtt_lf_amt           number(15),
  mx_sps_pct_prtt_lf_amt            number(15),
  acty_ref_perd_cd                  varchar2(30),
  coord_cvg_for_all_pls_flg         varchar2(30),
  enrt_cvg_end_dt_cd                varchar2(30),
  enrt_cvg_end_dt_rl                number(15),
  dpnt_cvg_end_dt_cd                varchar2(30),
  dpnt_cvg_end_dt_rl                number(15),
  dpnt_cvg_strt_dt_cd               varchar2(30),
  dpnt_cvg_strt_dt_rl               number(15),
  dpnt_dsgn_no_ctfn_rqd_flag        varchar2(30),
  drvbl_fctr_dpnt_elig_flag         varchar2(30),
  drvbl_fctr_prtn_elig_flag         varchar2(30),
  enrt_cvg_strt_dt_cd               varchar2(30),
  enrt_cvg_strt_dt_rl               number(15),
  enrt_info_rt_freq_cd              varchar2(30),
  rt_strt_dt_cd                     varchar2(30),
  rt_strt_dt_rl                     number(15),
  rt_end_dt_cd                      varchar2(30),
  rt_end_dt_rl                      number(15),
  pgm_grp_cd                        varchar2(30),
  pgm_uom                           varchar2(30),
  drvbl_fctr_apls_rts_flag          varchar2(30),
  alws_unrstrctd_enrt_flag          varchar2(30),
  enrt_cd                           varchar2(30),
  enrt_mthd_cd                      varchar2(30),
  poe_lvl_cd                        varchar2(30),
  enrt_rl                           number(15),
  auto_enrt_mthd_rl                 number(15),
  trk_inelig_per_flag               varchar2(30),
  business_group_id                 number(15),
  per_cvrd_cd                       varchar2(30),
  vrfy_fmly_mmbr_rl                 number(15),
  vrfy_fmly_mmbr_cd                 varchar2(30),
  short_name	   		    varchar2(30), 	--FHR
  short_code	   		    varchar2(30), 	--FHR
    legislation_code	   		    varchar2(30),
    legislation_subgroup	   		    varchar2(30),
  Dflt_pgm_flag                     Varchar2(30),
  Use_prog_points_flag              Varchar2(30),
  Dflt_step_cd                      Varchar2(30),
  Dflt_step_rl                      number(15) ,
  Update_salary_cd                  Varchar2(30),
  Use_multi_pay_rates_flag          Varchar2(30),
  dflt_element_type_id              number(15),
  Dflt_input_value_id               number(15) ,
  Use_scores_cd                     Varchar2(30),
  Scores_calc_mthd_cd               Varchar2(30),
  Scores_calc_rl                    number(15),
  gsp_allow_override_flag            varchar2(30),
  use_variable_rates_flag            varchar2(30),
  salary_calc_mthd_cd            varchar2(30),
  salary_calc_mthd_rl            number(15),
  susp_if_dpnt_ssn_nt_prv_cd        varchar2(30),
  susp_if_dpnt_dob_nt_prv_cd        varchar2(30),
  susp_if_dpnt_adr_nt_prv_cd        varchar2(30),
  susp_if_ctfn_not_dpnt_flag        varchar2(30),
  dpnt_ctfn_determine_cd            varchar2(30),
  pgm_attribute_category            varchar2(30),
  pgm_attribute1                    varchar2(150),
  pgm_attribute2                    varchar2(150),
  pgm_attribute3                    varchar2(150),
  pgm_attribute4                    varchar2(150),
  pgm_attribute5                    varchar2(150),
  pgm_attribute6                    varchar2(150),
  pgm_attribute7                    varchar2(150),
  pgm_attribute8                    varchar2(150),
  pgm_attribute9                    varchar2(150),
  pgm_attribute10                   varchar2(150),
  pgm_attribute11                   varchar2(150),
  pgm_attribute12                   varchar2(150),
  pgm_attribute13                   varchar2(150),
  pgm_attribute14                   varchar2(150),
  pgm_attribute15                   varchar2(150),
  pgm_attribute16                   varchar2(150),
  pgm_attribute17                   varchar2(150),
  pgm_attribute18                   varchar2(150),
  pgm_attribute19                   varchar2(150),
  pgm_attribute20                   varchar2(150),
  pgm_attribute21                   varchar2(150),
  pgm_attribute22                   varchar2(150),
  pgm_attribute23                   varchar2(150),
  pgm_attribute24                   varchar2(150),
  pgm_attribute25                   varchar2(150),
  pgm_attribute26                   varchar2(150),
  pgm_attribute27                   varchar2(150),
  pgm_attribute28                   varchar2(150),
  pgm_attribute29                   varchar2(150),
  pgm_attribute30                   varchar2(150),
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
   p_pgm_id		in number,
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
--           p_base_key_value = :pgm_id).
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
--           p_base_key_value = :pgm_id).
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
--           p_base_key_value = :pgm_id).
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
	 p_pgm_id	 in  number,
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
	p_pgm_id                        in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_name                          in varchar2,
	p_dpnt_adrs_rqd_flag            in varchar2,
	p_pgm_prvds_no_auto_enrt_flag   in varchar2,
	p_dpnt_dob_rqd_flag             in varchar2,
	p_pgm_prvds_no_dflt_enrt_flag   in varchar2,
	p_dpnt_legv_id_rqd_flag         in varchar2,
	p_dpnt_dsgn_lvl_cd              in varchar2,
	p_pgm_stat_cd                   in varchar2,
	p_ivr_ident                     in varchar2,
	p_pgm_typ_cd                    in varchar2,
	p_elig_apls_flag                in varchar2,
	p_uses_all_asmts_for_rts_flag   in varchar2,
	p_url_ref_name                  in varchar2,
	p_pgm_desc                      in varchar2,
	p_prtn_elig_ovrid_alwd_flag     in varchar2,
	p_pgm_use_all_asnts_elig_flag   in varchar2,
	p_dpnt_dsgn_cd                  in varchar2,
	p_mx_dpnt_pct_prtt_lf_amt       in number,
	p_mx_sps_pct_prtt_lf_amt        in number,
	p_acty_ref_perd_cd              in varchar2,
	p_coord_cvg_for_all_pls_flg     in varchar2,
	p_enrt_cvg_end_dt_cd            in varchar2,
	p_enrt_cvg_end_dt_rl            in number,
	p_dpnt_cvg_end_dt_cd            in varchar2,
	p_dpnt_cvg_end_dt_rl            in number,
	p_dpnt_cvg_strt_dt_cd           in varchar2,
	p_dpnt_cvg_strt_dt_rl           in number,
	p_dpnt_dsgn_no_ctfn_rqd_flag    in varchar2,
	p_drvbl_fctr_dpnt_elig_flag     in varchar2,
	p_drvbl_fctr_prtn_elig_flag     in varchar2,
	p_enrt_cvg_strt_dt_cd           in varchar2,
	p_enrt_cvg_strt_dt_rl           in number,
	p_enrt_info_rt_freq_cd          in varchar2,
	p_rt_strt_dt_cd                 in varchar2,
	p_rt_strt_dt_rl                 in number,
	p_rt_end_dt_cd                  in varchar2,
	p_rt_end_dt_rl                  in number,
	p_pgm_grp_cd                    in varchar2,
	p_pgm_uom                       in varchar2,
	p_drvbl_fctr_apls_rts_flag      in varchar2,
        p_alws_unrstrctd_enrt_flag      in  varchar2,
        p_enrt_cd                       in  varchar2,
        p_enrt_mthd_cd                  in  varchar2,
        p_poe_lvl_cd                    in  varchar2,
        p_enrt_rl                       in  number,
        p_auto_enrt_mthd_rl             in  number,
	p_trk_inelig_per_flag           in  varchar2,
	p_business_group_id             in  number,
        p_per_cvrd_cd                   in  varchar2,
        P_vrfy_fmly_mmbr_rl             in  number,
        P_vrfy_fmly_mmbr_cd             in  varchar2,
        p_short_name			in varchar2,	--FHR
	p_short_code			in varchar2,	--FHR
		p_legislation_code			in varchar2,
		p_legislation_subgroup			in varchar2,
        p_Dflt_pgm_flag                 in  Varchar2,
        p_Use_prog_points_flag          in  Varchar2,
        p_Dflt_step_cd                  in  Varchar2,
        p_Dflt_step_rl                  in  number,
        p_Update_salary_cd              in  Varchar2,
        p_Use_multi_pay_rates_flag      in  Varchar2,
        p_dflt_element_type_id          in  number,
        p_Dflt_input_value_id           in  number,
        p_Use_scores_cd                 in  Varchar2,
        p_Scores_calc_mthd_cd           in  Varchar2,
        p_Scores_calc_rl                in  number,
	p_gsp_allow_override_flag        in varchar2,
	p_use_variable_rates_flag        in varchar2,
	p_salary_calc_mthd_cd        in varchar2,
	p_salary_calc_mthd_rl        in number,
        p_susp_if_dpnt_ssn_nt_prv_cd    in  varchar2,
        p_susp_if_dpnt_dob_nt_prv_cd    in  varchar2,
        p_susp_if_dpnt_adr_nt_prv_cd    in  varchar2,
        p_susp_if_ctfn_not_dpnt_flag    in  varchar2,
        p_dpnt_ctfn_determine_cd        in  varchar2,
	p_pgm_attribute_category        in varchar2,
	p_pgm_attribute1                in varchar2,
	p_pgm_attribute2                in varchar2,
	p_pgm_attribute3                in varchar2,
	p_pgm_attribute4                in varchar2,
	p_pgm_attribute5                in varchar2,
	p_pgm_attribute6                in varchar2,
	p_pgm_attribute7                in varchar2,
	p_pgm_attribute8                in varchar2,
	p_pgm_attribute9                in varchar2,
	p_pgm_attribute10               in varchar2,
	p_pgm_attribute11               in varchar2,
	p_pgm_attribute12               in varchar2,
	p_pgm_attribute13               in varchar2,
	p_pgm_attribute14               in varchar2,
	p_pgm_attribute15               in varchar2,
	p_pgm_attribute16               in varchar2,
	p_pgm_attribute17               in varchar2,
	p_pgm_attribute18               in varchar2,
	p_pgm_attribute19               in varchar2,
	p_pgm_attribute20               in varchar2,
	p_pgm_attribute21               in varchar2,
	p_pgm_attribute22               in varchar2,
	p_pgm_attribute23               in varchar2,
	p_pgm_attribute24               in varchar2,
	p_pgm_attribute25               in varchar2,
	p_pgm_attribute26               in varchar2,
	p_pgm_attribute27               in varchar2,
	p_pgm_attribute28               in varchar2,
	p_pgm_attribute29               in varchar2,
	p_pgm_attribute30               in varchar2,
	p_object_version_number         in number
	)
	Return g_rec_type;
--
end ben_pgm_shd;

 

/
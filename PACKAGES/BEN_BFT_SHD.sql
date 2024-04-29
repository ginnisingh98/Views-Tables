--------------------------------------------------------
--  DDL for Package BEN_BFT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BFT_SHD" AUTHID CURRENT_USER as
/* $Header: bebftrhi.pkh 120.0 2005/05/28 00:40:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  benefit_action_id                 number(15),
  process_date                      date,
  uneai_effective_date              date,
  mode_cd                           varchar2(30),
  derivable_factors_flag            varchar2(30),
  close_uneai_flag                  varchar2(30),
  validate_flag                     varchar2(30),
  person_id                         number(15),
  person_type_id                    number(15),
  pgm_id                            number(15),
  business_group_id                 number(15),
  pl_id                             number(15),
  popl_enrt_typ_cycl_id             number(15),
  no_programs_flag                  varchar2(30),
  no_plans_flag                     varchar2(30),
  comp_selection_rl                 number(15),
  person_selection_rl               number(15),
  ler_id                            number(15),
  organization_id                   number(15),
  benfts_grp_id                     number(15),
  location_id                       number(15),
  pstl_zip_rng_id                   number(15),
  rptg_grp_id                       number(15),
  pl_typ_id                         number(15),
  opt_id                            number(15),
  eligy_prfl_id                     number(15),
  vrbl_rt_prfl_id                   number(15),
  legal_entity_id                   number(15),
  payroll_id                        number(15),
  debug_messages_flag               varchar2(30),
  cm_trgr_typ_cd                    varchar2(30),
  cm_typ_id                         number(15),
  age_fctr_id                       number(15),
  min_age                           number(15),
  max_age                           number(15),
  los_fctr_id                       number(15),
  min_los                           number(15),
  max_los                           number(15),
  cmbn_age_los_fctr_id              number(15),
  min_cmbn                          number(15),
  max_cmbn                          number(15),
  date_from                         date,
  elig_enrol_cd                     varchar2(30),
  actn_typ_id                       number(15),
  use_fctr_to_sel_flag              varchar2(30),
  los_det_to_use_cd                 varchar2(30),
  audit_log_flag                    varchar2(30),
  lmt_prpnip_by_org_flag            varchar2(30),
  lf_evt_ocrd_dt                    date,
  ptnl_ler_for_per_stat_cd          varchar2(30),
  bft_attribute_category            varchar2(30),
  bft_attribute1                    varchar2(150),
  bft_attribute3                    varchar2(150),
  bft_attribute4                    varchar2(150),
  bft_attribute5                    varchar2(150),
  bft_attribute6                    varchar2(150),
  bft_attribute7                    varchar2(150),
  bft_attribute8                    varchar2(150),
  bft_attribute9                    varchar2(150),
  bft_attribute10                   varchar2(150),
  bft_attribute11                   varchar2(150),
  bft_attribute12                   varchar2(150),
  bft_attribute13                   varchar2(150),
  bft_attribute14                   varchar2(150),
  bft_attribute15                   varchar2(150),
  bft_attribute16                   varchar2(150),
  bft_attribute17                   varchar2(150),
  bft_attribute18                   varchar2(150),
  bft_attribute19                   varchar2(150),
  bft_attribute20                   varchar2(150),
  bft_attribute21                   varchar2(150),
  bft_attribute22                   varchar2(150),
  bft_attribute23                   varchar2(150),
  bft_attribute24                   varchar2(150),
  bft_attribute25                   varchar2(150),
  bft_attribute26                   varchar2(150),
  bft_attribute27                   varchar2(150),
  bft_attribute28                   varchar2(150),
  bft_attribute29                   varchar2(150),
  bft_attribute30                   varchar2(150),
  request_id                        number(15),
  program_application_id            number(15),
  program_id                        number(15),
  program_update_date               date,
  object_version_number             number(9),
  enrt_perd_id                      number(15),
  inelg_action_cd                   varchar2(30),
  org_hierarchy_id                   number,
  org_starting_node_id                   number,
  grade_ladder_id                   number,
  asg_events_to_all_sel_dt                   varchar2(30),
  rate_id                   number,
  per_sel_dt_cd                   varchar2(30),
  per_sel_freq_cd                   varchar2(30),
  per_sel_dt_from                   date,
  per_sel_dt_to                   date,
  year_from                   number,
  year_to                   number,
  cagr_id                   number,
  qual_type                   number,
  qual_status                   varchar2(30),
  concat_segs                   varchar2(2000),
  grant_price_val                   number
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
--   This function is used to populate the g_old_rec record with the
--   current row from the database for the specified primary key
--   provided that the primary key exists and is valid and does not
--   already match the current g_old_rec. The function will always return
--   a TRUE value if the g_old_rec is populated with the current row.
--   A FALSE value will be returned if all of the primary key arguments
--   are null.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--   A value of TRUE will be returned indiciating that the g_old_rec
--   is current.
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
  (
  p_benefit_action_id                  in number,
  p_object_version_number              in number
  )      Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Lck process has two main functions to perform. Firstly, the row to be
--   updated or deleted must be locked. The locking of the row will only be
--   successful if the row is not currently locked by another user.
--   Secondly, during the locking of the row, the row is selected into
--   the g_old_rec data structure which enables the current row values from the
--   server to be available to the api.
--
-- Prerequisites:
--   When attempting to call the lock the object version number (if defined)
--   is mandatory.
--
-- In Parameters:
--   The arguments to the Lck process are the primary key(s) which uniquely
--   identify the row and the object version number of row.
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
--   For each primary key and the object version number arguments add a
--   call to hr_api.mandatory_arg_error procedure to ensure that these
--   argument values are not null.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_benefit_action_id                  in number,
  p_object_version_number              in number
  );
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
	p_benefit_action_id             in number,
	p_process_date                  in date,
	p_uneai_effective_date          in date,
	p_mode_cd                       in varchar2,
	p_derivable_factors_flag        in varchar2,
	p_close_uneai_flag              in varchar2,
	p_validate_flag                 in varchar2,
	p_person_id                     in number,
	p_person_type_id                in number,
	p_pgm_id                        in number,
	p_business_group_id             in number,
	p_pl_id                         in number,
	p_popl_enrt_typ_cycl_id         in number,
	p_no_programs_flag              in varchar2,
	p_no_plans_flag                 in varchar2,
	p_comp_selection_rl             in number,
	p_person_selection_rl           in number,
	p_ler_id                        in number,
	p_organization_id               in number,
	p_benfts_grp_id                 in number,
	p_location_id                   in number,
	p_pstl_zip_rng_id               in number,
	p_rptg_grp_id                   in number,
	p_pl_typ_id                     in number,
	p_opt_id                        in number,
	p_eligy_prfl_id                 in number,
	p_vrbl_rt_prfl_id               in number,
	p_legal_entity_id               in number,
	p_payroll_id                    in number,
	p_debug_messages_flag           in varchar2,
  p_cm_trgr_typ_cd                in varchar2,
  p_cm_typ_id                     in number,
  p_age_fctr_id                   in number,
  p_min_age                       in number,
  p_max_age                       in number,
  p_los_fctr_id                   in number,
  p_min_los                       in number,
  p_max_los                       in number,
  p_cmbn_age_los_fctr_id          in number,
  p_min_cmbn                      in number,
  p_max_cmbn                      in number,
  p_date_from                     in date,
  p_elig_enrol_cd                 in varchar2,
  p_actn_typ_id                   in number,
  p_use_fctr_to_sel_flag          in varchar2,
  p_los_det_to_use_cd             in varchar2,
  p_audit_log_flag                in varchar2,
  p_lmt_prpnip_by_org_flag        in varchar2,
  p_lf_evt_ocrd_dt                in date,
  p_ptnl_ler_for_per_stat_cd      in varchar2,
	p_bft_attribute_category        in varchar2,
	p_bft_attribute1                in varchar2,
	p_bft_attribute3                in varchar2,
	p_bft_attribute4                in varchar2,
	p_bft_attribute5                in varchar2,
	p_bft_attribute6                in varchar2,
	p_bft_attribute7                in varchar2,
	p_bft_attribute8                in varchar2,
	p_bft_attribute9                in varchar2,
	p_bft_attribute10               in varchar2,
	p_bft_attribute11               in varchar2,
	p_bft_attribute12               in varchar2,
	p_bft_attribute13               in varchar2,
	p_bft_attribute14               in varchar2,
	p_bft_attribute15               in varchar2,
	p_bft_attribute16               in varchar2,
	p_bft_attribute17               in varchar2,
	p_bft_attribute18               in varchar2,
	p_bft_attribute19               in varchar2,
	p_bft_attribute20               in varchar2,
	p_bft_attribute21               in varchar2,
	p_bft_attribute22               in varchar2,
	p_bft_attribute23               in varchar2,
	p_bft_attribute24               in varchar2,
	p_bft_attribute25               in varchar2,
	p_bft_attribute26               in varchar2,
	p_bft_attribute27               in varchar2,
	p_bft_attribute28               in varchar2,
	p_bft_attribute29               in varchar2,
	p_bft_attribute30               in varchar2,
  p_request_id                    in number,
  p_program_application_id        in number,
  p_program_id                    in number,
  p_program_update_date           in date,
	p_object_version_number         in number,
	p_enrt_perd_id                  in number,
	p_inelg_action_cd               in varchar2,
	p_org_hierarchy_id               in number,
	p_org_starting_node_id               in number,
	p_grade_ladder_id               in number,
	p_asg_events_to_all_sel_dt               in varchar2,
	p_rate_id               in number,
	p_per_sel_dt_cd               in varchar2,
	p_per_sel_freq_cd               in varchar2,
	p_per_sel_dt_from               in date,
	p_per_sel_dt_to               in date,
	p_year_from               in number,
	p_year_to               in number,
	p_cagr_id               in number,
	p_qual_type               in number,
	p_qual_status               in varchar2,
	p_concat_segs               in varchar2,
  p_grant_price_val               in number
	)
	Return g_rec_type;
--
end ben_bft_shd;

 

/

--------------------------------------------------------
--  DDL for Package BEN_CPD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPD_SHD" AUTHID CURRENT_USER as
/* $Header: becpdrhi.pkh 120.1.12010000.3 2010/03/12 06:10:29 sgnanama ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (pl_id                           number(15)
  ,lf_evt_ocrd_dt                  date
  ,oipl_id                         number(15)
  ,effective_date                  date
  ,name                            varchar2(240)
  ,group_pl_id                     number(15)
  ,group_oipl_id                   number(15)
  ,opt_hidden_flag                 varchar2(30)
  ,opt_id                          number(15)
  ,pl_uom                          varchar2(30)
  ,pl_ordr_num                     number(15)
  ,oipl_ordr_num                   number(15)
  ,pl_xchg_rate                    number
  ,opt_count                       number(9)         -- Increased length
  ,uses_bdgt_flag                  varchar2(30)
  ,prsrv_bdgt_cd                   varchar2(30)
  ,upd_start_dt                    date
  ,upd_end_dt                      date
  ,approval_mode                   varchar2(30)
  ,enrt_perd_start_dt              date
  ,enrt_perd_end_dt                date
  ,yr_perd_start_dt                date
  ,yr_perd_end_dt                  date
  ,wthn_yr_start_dt                date
  ,wthn_yr_end_dt                  date
  ,enrt_perd_id                    number(15)
  ,yr_perd_id                      number(15)
  ,business_group_id               number(15)
  ,perf_revw_strt_dt               date
  ,asg_updt_eff_date               date
  ,emp_interview_typ_cd            varchar2(30)
  ,salary_change_reason            varchar2(30)
  ,ws_abr_id                       number(15)
  ,ws_nnmntry_uom                  varchar2(30)
  ,ws_rndg_cd                      varchar2(30)
  ,ws_sub_acty_typ_cd              varchar2(30)
  ,dist_bdgt_abr_id                number(15)
  ,dist_bdgt_nnmntry_uom           varchar2(30)
  ,dist_bdgt_rndg_cd               varchar2(30)
  ,ws_bdgt_abr_id                  number(15)
  ,ws_bdgt_nnmntry_uom             varchar2(30)
  ,ws_bdgt_rndg_cd                 varchar2(30)
  ,rsrv_abr_id                     number(15)
  ,rsrv_nnmntry_uom                varchar2(30)
  ,rsrv_rndg_cd                    varchar2(30)
  ,elig_sal_abr_id                 number(15)
  ,elig_sal_nnmntry_uom            varchar2(30)
  ,elig_sal_rndg_cd                varchar2(30)
  ,misc1_abr_id                    number(15)
  ,misc1_nnmntry_uom               varchar2(30)
  ,misc1_rndg_cd                   varchar2(30)
  ,misc2_abr_id                    number(15)
  ,misc2_nnmntry_uom               varchar2(30)
  ,misc2_rndg_cd                   varchar2(30)
  ,misc3_abr_id                    number(15)
  ,misc3_nnmntry_uom               varchar2(30)
  ,misc3_rndg_cd                   varchar2(30)
  ,stat_sal_abr_id                 number(15)
  ,stat_sal_nnmntry_uom            varchar2(30)
  ,stat_sal_rndg_cd                varchar2(30)
  ,rec_abr_id                      number(15)
  ,rec_nnmntry_uom                 varchar2(30)
  ,rec_rndg_cd                     varchar2(30)
  ,tot_comp_abr_id                 number(15)
  ,tot_comp_nnmntry_uom            varchar2(30)
  ,tot_comp_rndg_cd                varchar2(30)
  ,oth_comp_abr_id                 number(15)
  ,oth_comp_nnmntry_uom            varchar2(30)
  ,oth_comp_rndg_cd                varchar2(30)
  ,actual_flag                     varchar2(30)
  ,acty_ref_perd_cd                varchar2(30)
  ,legislation_code                varchar2(30)
  ,pl_annulization_factor          number
  ,pl_stat_cd                      varchar2(30)
  ,uom_precision                   number
  ,ws_element_type_id              number(15)
  ,ws_input_value_id               number(15)
  ,data_freeze_date                date
  ,ws_amt_edit_cd                  varchar2(30)
  ,ws_amt_edit_enf_cd_for_nulls    varchar2(30)
  ,ws_over_budget_edit_cd          varchar2(30)
  ,ws_over_budget_tolerance_pct    number
  ,bdgt_over_budget_edit_cd        varchar2(30)
  ,bdgt_over_budget_tolerance_pct  number
  ,auto_distr_flag                 varchar2(30)
  ,pqh_document_short_name         varchar2(30)
  ,ovrid_rt_strt_dt                date
  ,do_not_process_flag             varchar2(30)
  ,ovr_perf_revw_strt_dt           date
  ,post_zero_salary_increase       varchar2(10)
  ,show_appraisals_n_days          number
  ,grade_range_validation          varchar2(20)
  ,object_version_number           number(9)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
-- Global table name
g_tab_nam  constant varchar2(30) := 'BEN_CWB_PL_DSGN';
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
--  {Start Of Comments}
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
  (p_pl_id                                in     number
  ,p_lf_evt_ocrd_dt                       in     date
  ,p_oipl_id                              in     number
  ,p_object_version_number                in     number
  )      Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   The Lck process has two main functions to perform. Firstly, the row to be
--   updated or deleted must be locked. The locking of the row will only be
--   successful if the row is not currently locked by another user.
--   Secondly, during the locking of the row, the row is selected into
--   the g_old_rec data structure which enables the current row values from
--   the server to be available to the api.
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
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure lck
  (p_pl_id                                in     number
  ,p_lf_evt_ocrd_dt                       in     date
  ,p_oipl_id                              in     number
  ,p_object_version_number                in     number
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
--   No direct error handling is required within this function.  Any possible
--   errors within this function will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
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
  (p_pl_id                          in number
  ,p_oipl_id                        in number
  ,p_lf_evt_ocrd_dt                 in date
  ,p_effective_date                 in date
  ,p_name                           in varchar2
  ,p_group_pl_id                    in number
  ,p_group_oipl_id                  in number
  ,p_opt_hidden_flag                in varchar2
  ,p_opt_id                         in number
  ,p_pl_uom                         in varchar2
  ,p_pl_ordr_num                    in number
  ,p_oipl_ordr_num                  in number
  ,p_pl_xchg_rate                   in number
  ,p_opt_count                      in number
  ,p_uses_bdgt_flag                 in varchar2
  ,p_prsrv_bdgt_cd                  in varchar2
  ,p_upd_start_dt                   in date
  ,p_upd_end_dt                     in date
  ,p_approval_mode                  in varchar2
  ,p_enrt_perd_start_dt             in date
  ,p_enrt_perd_end_dt               in date
  ,p_yr_perd_start_dt               in date
  ,p_yr_perd_end_dt                 in date
  ,p_wthn_yr_start_dt               in date
  ,p_wthn_yr_end_dt                 in date
  ,p_enrt_perd_id                   in number
  ,p_yr_perd_id                     in number
  ,p_business_group_id              in number
  ,p_perf_revw_strt_dt              in date
  ,p_asg_updt_eff_date              in date
  ,p_emp_interview_typ_cd           in varchar2
  ,p_salary_change_reason           in varchar2
  ,p_ws_abr_id                      in number
  ,p_ws_nnmntry_uom                 in varchar2
  ,p_ws_rndg_cd                     in varchar2
  ,p_ws_sub_acty_typ_cd             in varchar2
  ,p_dist_bdgt_abr_id               in number
  ,p_dist_bdgt_nnmntry_uom          in varchar2
  ,p_dist_bdgt_rndg_cd              in varchar2
  ,p_ws_bdgt_abr_id                 in number
  ,p_ws_bdgt_nnmntry_uom            in varchar2
  ,p_ws_bdgt_rndg_cd                in varchar2
  ,p_rsrv_abr_id                    in number
  ,p_rsrv_nnmntry_uom               in varchar2
  ,p_rsrv_rndg_cd                   in varchar2
  ,p_elig_sal_abr_id                in number
  ,p_elig_sal_nnmntry_uom           in varchar2
  ,p_elig_sal_rndg_cd               in varchar2
  ,p_misc1_abr_id                   in number
  ,p_misc1_nnmntry_uom              in varchar2
  ,p_misc1_rndg_cd                  in varchar2
  ,p_misc2_abr_id                   in number
  ,p_misc2_nnmntry_uom              in varchar2
  ,p_misc2_rndg_cd                  in varchar2
  ,p_misc3_abr_id                   in number
  ,p_misc3_nnmntry_uom              in varchar2
  ,p_misc3_rndg_cd                  in varchar2
  ,p_stat_sal_abr_id                in number
  ,p_stat_sal_nnmntry_uom           in varchar2
  ,p_stat_sal_rndg_cd               in varchar2
  ,p_rec_abr_id                     in number
  ,p_rec_nnmntry_uom                in varchar2
  ,p_rec_rndg_cd                    in varchar2
  ,p_tot_comp_abr_id                in number
  ,p_tot_comp_nnmntry_uom           in varchar2
  ,p_tot_comp_rndg_cd               in varchar2
  ,p_oth_comp_abr_id                in number
  ,p_oth_comp_nnmntry_uom           in varchar2
  ,p_oth_comp_rndg_cd               in varchar2
  ,p_actual_flag                    in varchar2
  ,p_acty_ref_perd_cd               in varchar2
  ,p_legislation_code               in varchar2
  ,p_pl_annulization_factor         in number
  ,p_pl_stat_cd                     in varchar2
  ,p_uom_precision                  in number
  ,p_ws_element_type_id             in number
  ,p_ws_input_value_id              in number
  ,p_data_freeze_date               in date
  ,p_ws_amt_edit_cd                 in varchar2
  ,p_ws_amt_edit_enf_cd_for_nul     in varchar2
  ,p_ws_over_budget_edit_cd         in varchar2
  ,p_ws_over_budget_tol_pct         in number
  ,p_bdgt_over_budget_edit_cd       in varchar2
  ,p_bdgt_over_budget_tol_pct       in number
  ,p_auto_distr_flag                in varchar2
  ,p_pqh_document_short_name        in varchar2
  ,p_ovrid_rt_strt_dt               in date
  ,p_do_not_process_flag            in varchar2
  ,p_ovr_perf_revw_strt_dt          in date
  ,p_post_zero_salary_increase      in varchar2
  ,p_show_appraisals_n_days         in number
  ,p_grade_range_validation         in  varchar2
  ,p_object_version_number          in number
  )
  Return g_rec_type;
--
end ben_cpd_shd;

/

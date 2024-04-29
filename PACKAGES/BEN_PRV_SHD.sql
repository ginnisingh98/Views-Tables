--------------------------------------------------------
--  DDL for Package BEN_PRV_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRV_SHD" AUTHID CURRENT_USER as
/* $Header: beprvrhi.pkh 120.0.12000000.1 2007/01/19 22:14:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  prtt_rt_val_id                    number(15),
  enrt_rt_id			    number(15),
  rt_strt_dt                        date,
  rt_end_dt                         date,
  rt_typ_cd                         varchar2(30),
  tx_typ_cd                         varchar2(30),
  ordr_num			    number,
  acty_typ_cd                       varchar2(30),
  mlt_cd                            varchar2(30),
  acty_ref_perd_cd                  varchar2(30),
  rt_val                            number,
  ann_rt_val                        number(15,2),
  cmcd_rt_val                       number(15,2),
  cmcd_ref_perd_cd                  varchar2(30),
  bnft_rt_typ_cd                    varchar2(30),
  dsply_on_enrt_flag                varchar2(30),
  rt_ovridn_flag                    varchar2(30),
  rt_ovridn_thru_dt                 date,
  elctns_made_dt                    date,
  prtt_rt_val_stat_cd               varchar2(30),
  prtt_enrt_rslt_id                 number(15),
  cvg_amt_calc_mthd_id              number(15),
  actl_prem_id                      number(15),
  comp_lvl_fctr_id                  number(15),
  element_entry_value_id            number(15),
  per_in_ler_id                     number(15),
  ended_per_in_ler_id               number(15),
  acty_base_rt_id                   number(15),
  prtt_reimbmt_rqst_id              number(15),
  prtt_rmt_aprvd_fr_pymt_id         number(15),
  pp_in_yr_used_num                 number(15),
  business_group_id                 number(15),
  prv_attribute_category            varchar2(30),
  prv_attribute1                    varchar2(150),
  prv_attribute2                    varchar2(150),
  prv_attribute3                    varchar2(150),
  prv_attribute4                    varchar2(150),
  prv_attribute5                    varchar2(150),
  prv_attribute6                    varchar2(150),
  prv_attribute7                    varchar2(150),
  prv_attribute8                    varchar2(150),
  prv_attribute9                    varchar2(150),
  prv_attribute10                   varchar2(150),
  prv_attribute11                   varchar2(150),
  prv_attribute12                   varchar2(150),
  prv_attribute13                   varchar2(150),
  prv_attribute14                   varchar2(150),
  prv_attribute15                   varchar2(150),
  prv_attribute16                   varchar2(150),
  prv_attribute17                   varchar2(150),
  prv_attribute18                   varchar2(150),
  prv_attribute19                   varchar2(150),
  prv_attribute20                   varchar2(150),
  prv_attribute21                   varchar2(150),
  prv_attribute22                   varchar2(150),
  prv_attribute23                   varchar2(150),
  prv_attribute24                   varchar2(150),
  prv_attribute25                   varchar2(150),
  prv_attribute26                   varchar2(150),
  prv_attribute27                   varchar2(150),
  prv_attribute28                   varchar2(150),
  prv_attribute29                   varchar2(150),
  prv_attribute30                   varchar2(150),
  pk_id_table_name                  varchar2(100),
  pk_id                             number(15),
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
  p_prtt_rt_val_id                     in number,
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
  p_prtt_rt_val_id                     in number,
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
	p_prtt_rt_val_id                in number,
	p_enrt_rt_id			in number,
	p_rt_strt_dt                    in date,
	p_rt_end_dt                     in date,
	p_rt_typ_cd                     in varchar2,
	p_tx_typ_cd                     in varchar2,
	p_ordr_num			in number,
	p_acty_typ_cd                   in varchar2,
	p_mlt_cd                        in varchar2,
	p_acty_ref_perd_cd              in varchar2,
	p_rt_val                        in number,
	p_ann_rt_val                    in number,
	p_cmcd_rt_val                   in number,
	p_cmcd_ref_perd_cd              in varchar2,
	p_bnft_rt_typ_cd                in varchar2,
	p_dsply_on_enrt_flag            in varchar2,
	p_rt_ovridn_flag                in varchar2,
	p_rt_ovridn_thru_dt             in date,
	p_elctns_made_dt                in date,
	p_prtt_rt_val_stat_cd           in varchar2,
	p_prtt_enrt_rslt_id             in number,
	p_cvg_amt_calc_mthd_id          in number,
	p_actl_prem_id                  in number,
	p_comp_lvl_fctr_id              in number,
	p_element_entry_value_id        in number,
	p_per_in_ler_id                 in number,
	p_ended_per_in_ler_id           in number,
	p_acty_base_rt_id               in number,
	p_prtt_reimbmt_rqst_id          in number,
        p_prtt_rmt_aprvd_fr_pymt_id     in number,
        p_pp_in_yr_used_num             in  number,
	p_business_group_id             in number,
	p_prv_attribute_category        in varchar2,
	p_prv_attribute1                in varchar2,
	p_prv_attribute2                in varchar2,
	p_prv_attribute3                in varchar2,
	p_prv_attribute4                in varchar2,
	p_prv_attribute5                in varchar2,
	p_prv_attribute6                in varchar2,
	p_prv_attribute7                in varchar2,
	p_prv_attribute8                in varchar2,
	p_prv_attribute9                in varchar2,
	p_prv_attribute10               in varchar2,
	p_prv_attribute11               in varchar2,
	p_prv_attribute12               in varchar2,
	p_prv_attribute13               in varchar2,
	p_prv_attribute14               in varchar2,
	p_prv_attribute15               in varchar2,
	p_prv_attribute16               in varchar2,
	p_prv_attribute17               in varchar2,
	p_prv_attribute18               in varchar2,
	p_prv_attribute19               in varchar2,
	p_prv_attribute20               in varchar2,
	p_prv_attribute21               in varchar2,
	p_prv_attribute22               in varchar2,
	p_prv_attribute23               in varchar2,
	p_prv_attribute24               in varchar2,
	p_prv_attribute25               in varchar2,
	p_prv_attribute26               in varchar2,
	p_prv_attribute27               in varchar2,
	p_prv_attribute28               in varchar2,
	p_prv_attribute29               in varchar2,
	p_prv_attribute30               in varchar2,
        p_pk_id_table_name              in varchar2,
        p_pk_id                         in number,
	p_object_version_number         in number
	)
	Return g_rec_type;
--
end ben_prv_shd;

 

/

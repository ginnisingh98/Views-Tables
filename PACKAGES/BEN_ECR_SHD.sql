--------------------------------------------------------
--  DDL for Package BEN_ECR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ECR_SHD" AUTHID CURRENT_USER as
/* $Header: beecrrhi.pkh 120.0 2005/05/28 01:53:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
 enrt_rt_id                      NUMBER(15,0),
 ordr_num			 number(15),
 acty_typ_cd                     VARCHAR2(30),
 tx_typ_cd                       VARCHAR2(30),
 ctfn_rqd_flag                   VARCHAR2(30),
 dflt_flag                       VARCHAR2(30),
 dflt_pndg_ctfn_flag             VARCHAR2(30),
 dsply_on_enrt_flag              VARCHAR2(30),
 use_to_calc_net_flx_cr_flag     VARCHAR2(30),
 entr_val_at_enrt_flag           VARCHAR2(30),
 asn_on_enrt_flag                VARCHAR2(30),
 rl_crs_only_flag                VARCHAR2(30),
 dflt_val                        NUMBER,
 ann_val                         NUMBER,
 ann_mn_elcn_val                 NUMBER,
 ann_mx_elcn_val                 NUMBER,
 val                             NUMBER,
 nnmntry_uom                     VARCHAR2(30),
 mx_elcn_val                     NUMBER,
 mn_elcn_val                     NUMBER,
 incrmt_elcn_val                 NUMBER,
 cmcd_acty_ref_perd_cd           VARCHAR2(30),
 cmcd_mn_elcn_val                NUMBER,
 cmcd_mx_elcn_val                NUMBER,
 cmcd_val                        NUMBER,
 cmcd_dflt_val                   NUMBER,
 rt_usg_cd                       VARCHAR2(30),
 ann_dflt_val                    NUMBER(15,2),
 bnft_rt_typ_cd                  VARCHAR2(30),
 rt_mlt_cd                       VARCHAR2(30),
 dsply_mn_elcn_val               NUMBER(15,2),
 dsply_mx_elcn_val               NUMBER(15,2),
 entr_ann_val_flag               VARCHAR2(30),
 rt_strt_dt                      DATE,
 rt_strt_dt_cd                   VARCHAR2(30),
 rt_strt_dt_rl                   NUMBER(15,0),
 rt_typ_cd                       VARCHAR2(30),
 elig_per_elctbl_chc_id          NUMBER(15,0),
 acty_base_rt_id                 NUMBER(15,0),
 spcl_rt_enrt_rt_id              NUMBER(15,0),
 enrt_bnft_id                    NUMBER(15),
 prtt_rt_val_id                  NUMBER(15,0),
 decr_bnft_prvdr_pool_id         NUMBER(15),
 cvg_amt_calc_mthd_id            NUMBER(15),
 actl_prem_id                    NUMBER(15),
 comp_lvl_fctr_id                NUMBER(15),
 ptd_comp_lvl_fctr_id            NUMBER(15),
 clm_comp_lvl_fctr_id            NUMBER(15),
 business_group_id               NUMBER(15),
 --cwb
 iss_val                         number,
 val_last_upd_date               date,
 val_last_upd_person_id          number(15),
 --cwb
 pp_in_yr_used_num               number(15),
 ecr_attribute_category          VARCHAR2(30),
 ecr_attribute1                  VARCHAR2(150),
 ecr_attribute2                  VARCHAR2(150),
 ecr_attribute3                  VARCHAR2(150),
 ecr_attribute4                  VARCHAR2(150),
 ecr_attribute5                  VARCHAR2(150),
 ecr_attribute6                  VARCHAR2(150),
 ecr_attribute7                  VARCHAR2(150),
 ecr_attribute8                  VARCHAR2(150),
 ecr_attribute9                  VARCHAR2(150),
 ecr_attribute10                 VARCHAR2(150),
 ecr_attribute11                 VARCHAR2(150),
 ecr_attribute12                 VARCHAR2(150),
 ecr_attribute13                 VARCHAR2(150),
 ecr_attribute14                 VARCHAR2(150),
 ecr_attribute15                 VARCHAR2(150),
 ecr_attribute16                 VARCHAR2(150),
 ecr_attribute17                 VARCHAR2(150),
 ecr_attribute18                 VARCHAR2(150),
 ecr_attribute19                 VARCHAR2(150),
 ecr_attribute20                 VARCHAR2(150),
 ecr_attribute21                 VARCHAR2(150),
 ecr_attribute22                 VARCHAR2(150),
 ecr_attribute23                 VARCHAR2(150),
 ecr_attribute24                 VARCHAR2(150),
 ecr_attribute25                 VARCHAR2(150),
 ecr_attribute26                 VARCHAR2(150),
 ecr_attribute27                 VARCHAR2(150),
 ecr_attribute28                 VARCHAR2(150),
 ecr_attribute29                 VARCHAR2(150),
 ecr_attribute30                 VARCHAR2(150),
 last_update_login               NUMBER(15),
 created_by                      NUMBER(15),
 creation_date                   DATE,
 last_updated_by                 NUMBER(15),
 last_update_date                DATE,
 request_id                      NUMBER(15),
 program_application_id          NUMBER(15),
 program_id                      NUMBER(15),
 program_update_date             DATE,
 object_version_number           NUMBER(9)
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
  p_enrt_rt_id                         in number,
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
  p_enrt_rt_id                         in number,
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
	p_enrt_rt_id                  in  NUMBER,
	p_ordr_num		      in number,
	p_acty_typ_cd                 in  VARCHAR2,
	p_tx_typ_cd                   in  VARCHAR2,
	p_ctfn_rqd_flag               in  VARCHAR2,
	p_dflt_flag                   in  VARCHAR2,
	p_dflt_pndg_ctfn_flag         in  VARCHAR2,
	p_dsply_on_enrt_flag          in  VARCHAR2,
	p_use_to_calc_net_flx_cr_flag in  VARCHAR2,
	p_entr_val_at_enrt_flag       in  VARCHAR2,
	p_asn_on_enrt_flag            in  VARCHAR2,
	p_rl_crs_only_flag            in  VARCHAR2,
	p_dflt_val                    in  NUMBER,
	p_ann_val                     in  NUMBER,
	p_ann_mn_elcn_val             in  NUMBER,
	p_ann_mx_elcn_val             in  NUMBER,
	p_val                         in  NUMBER,
	p_nnmntry_uom                 in  VARCHAR2,
	p_mx_elcn_val                 in  NUMBER,
	p_mn_elcn_val                 in  NUMBER,
	p_incrmt_elcn_val             in  NUMBER,
	p_cmcd_acty_ref_perd_cd       in  VARCHAR2,
	p_cmcd_mn_elcn_val            in  NUMBER,
	p_cmcd_mx_elcn_val            in  NUMBER,
	p_cmcd_val                    in  NUMBER,
	p_cmcd_dflt_val               in  NUMBER,
	p_rt_usg_cd                   in  VARCHAR2,
	p_ann_dflt_val                in  NUMBER,
	p_bnft_rt_typ_cd              in  VARCHAR2,
	p_rt_mlt_cd                   in  VARCHAR2,
	p_dsply_mn_elcn_val           in  NUMBER,
	p_dsply_mx_elcn_val           in  NUMBER,
	p_entr_ann_val_flag           in  VARCHAR2,
	p_rt_strt_dt                  in  DATE,
	p_rt_strt_dt_cd               in  VARCHAR2,
	p_rt_strt_dt_rl               in  NUMBER,
	p_rt_typ_cd                   in  VARCHAR2,
	p_elig_per_elctbl_chc_id      in  NUMBER,
	p_acty_base_rt_id             in  NUMBER,
	p_spcl_rt_enrt_rt_id          in  NUMBER,
	p_enrt_bnft_id                in  NUMBER,
	p_prtt_rt_val_id              in  NUMBER,
	p_decr_bnft_prvdr_pool_id     in  NUMBER,
	p_cvg_amt_calc_mthd_id        in  NUMBER,
	p_actl_prem_id                in  NUMBER,
	p_comp_lvl_fctr_id            in  NUMBER,
	p_ptd_comp_lvl_fctr_id        in  NUMBER,
	p_clm_comp_lvl_fctr_id        in  NUMBER,
	p_business_group_id           in  NUMBER,
        --cwb
        p_iss_val                     in  number,
        p_val_last_upd_date           in  date,
        p_val_last_upd_person_id      in  number,
        --cwb
        p_pp_in_yr_used_num           in  number,
	p_ecr_attribute_category      in  VARCHAR2,
	p_ecr_attribute1              in  VARCHAR2,
	p_ecr_attribute2              in  VARCHAR2,
	p_ecr_attribute3              in  VARCHAR2,
	p_ecr_attribute4              in  VARCHAR2,
	p_ecr_attribute5              in  VARCHAR2,
	p_ecr_attribute6              in  VARCHAR2,
	p_ecr_attribute7              in  VARCHAR2,
	p_ecr_attribute8              in  VARCHAR2,
	p_ecr_attribute9              in  VARCHAR2,
	p_ecr_attribute10             in  VARCHAR2,
	p_ecr_attribute11             in  VARCHAR2,
	p_ecr_attribute12             in  VARCHAR2,
	p_ecr_attribute13             in  VARCHAR2,
	p_ecr_attribute14             in  VARCHAR2,
	p_ecr_attribute15             in  VARCHAR2,
	p_ecr_attribute16             in  VARCHAR2,
	p_ecr_attribute17             in  VARCHAR2,
	p_ecr_attribute18             in  VARCHAR2,
	p_ecr_attribute19             in  VARCHAR2,
	p_ecr_attribute20             in  VARCHAR2,
	p_ecr_attribute21             in  VARCHAR2,
	p_ecr_attribute22             in  VARCHAR2,
    p_ecr_attribute23             in  VARCHAR2,
    p_ecr_attribute24             in  VARCHAR2,
    p_ecr_attribute25             in  VARCHAR2,
    p_ecr_attribute26             in  VARCHAR2,
    p_ecr_attribute27             in  VARCHAR2,
    p_ecr_attribute28             in  VARCHAR2,
    p_ecr_attribute29             in  VARCHAR2,
    p_ecr_attribute30             in  VARCHAR2,
    p_last_update_login           in  NUMBER,
    p_created_by                  in  NUMBER,
    p_creation_date               in  DATE,
    p_last_updated_by             in  NUMBER,
    p_last_update_date            in  DATE,
    p_request_id                  in  NUMBER,
    p_program_application_id      in  NUMBER,
    p_program_id                  in  NUMBER,
    p_program_update_date         in  DATE,
    p_object_version_number       in  NUMBER
	)
	Return g_rec_type;
--
end ben_ecr_shd;

 

/

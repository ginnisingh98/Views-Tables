--------------------------------------------------------
--  DDL for Package BEN_ENB_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENB_SHD" AUTHID CURRENT_USER as
/* $Header: beenbrhi.pkh 120.0 2005/05/28 02:27:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
   enrt_bnft_id                    NUMBER(15,0) ,
   dflt_flag                       VARCHAR2(30)  ,
   val_has_bn_prortd_flag          VARCHAR2(30)  ,
   bndry_perd_cd                   VARCHAR2(30) ,
   val                             NUMBER       ,
   nnmntry_uom                     VARCHAR2(30) ,
   bnft_typ_cd                     VARCHAR2(30) ,
   entr_val_at_enrt_flag           VARCHAR2(30),
   mn_val                          NUMBER(15,2) ,
   mx_val                          NUMBER(15,2) ,
   incrmt_val                      NUMBER(15,2) ,
   dflt_val                        NUMBER(15,2) ,
   rt_typ_cd                       VARCHAR2(30) ,
   cvg_mlt_cd                      VARCHAR2(30) ,
   ctfn_rqd_flag                   VARCHAR2(30) ,
   ordr_num                        NUMBER(15) ,
   crntly_enrld_flag               VARCHAR2(30) ,
   elig_per_elctbl_chc_id          NUMBER(15,0) ,
   prtt_enrt_rslt_id               NUMBER(15,0) ,
   comp_lvl_fctr_id                NUMBER(15)   ,
   business_group_id               NUMBER(15)   ,
   enb_attribute_category          VARCHAR2(30) ,
   enb_attribute1                  VARCHAR2(150),
   enb_attribute2                  VARCHAR2(150),
   enb_attribute3                  VARCHAR2(150),
   enb_attribute4                  VARCHAR2(150),
   enb_attribute5                  VARCHAR2(150),
   enb_attribute6                  VARCHAR2(150),
   enb_attribute7                  VARCHAR2(150),
   enb_attribute8                  VARCHAR2(150),
   enb_attribute9                  VARCHAR2(150),
   enb_attribute10                 VARCHAR2(150),
   enb_attribute11                 VARCHAR2(150),
   enb_attribute12                 VARCHAR2(150),
   enb_attribute13                 VARCHAR2(150),
   enb_attribute14                 VARCHAR2(150),
   enb_attribute15                 VARCHAR2(150),
   enb_attribute16                 VARCHAR2(150),
   enb_attribute17                 VARCHAR2(150),
   enb_attribute18                 VARCHAR2(150),
   enb_attribute19                 VARCHAR2(150),
   enb_attribute20                 VARCHAR2(150),
   enb_attribute21                 VARCHAR2(150),
   enb_attribute22                 VARCHAR2(150),
   enb_attribute23                 VARCHAR2(150),
   enb_attribute24                 VARCHAR2(150),
   enb_attribute25                 VARCHAR2(150),
   enb_attribute26                 VARCHAR2(150),
   enb_attribute27                 VARCHAR2(150),
   enb_attribute28                 VARCHAR2(150),
   enb_attribute29                 VARCHAR2(150),
   enb_attribute30                 VARCHAR2(150),
   request_id                      NUMBER(15)   ,
   program_application_id          NUMBER(15)   ,
   program_id                      NUMBER(15)   ,
   mx_wout_ctfn_val                NUMBER	,
   mx_wo_ctfn_flag                 varchar2(30) ,
   program_update_date             DATE         ,
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
  p_enrt_bnft_id                       in number,
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
  p_enrt_bnft_id                       in number,
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
   p_enrt_bnft_id                   in  number
  ,p_dflt_flag                      in  varchar2
  ,p_val_has_bn_prortd_flag         in  varchar2
  ,p_bndry_perd_cd                  in  varchar2
  ,p_val                            in  number
  ,p_nnmntry_uom                    in  varchar2
  ,p_bnft_typ_cd                    in  varchar2
  ,p_entr_val_at_enrt_flag          in  varchar2
  ,p_mn_val                         in  number
  ,p_mx_val                         in  number
  ,p_incrmt_val                     in  number
  ,p_dflt_val                       in  number
  ,p_rt_typ_cd                      in  varchar2
  ,p_cvg_mlt_cd                     in  varchar2
  ,p_ctfn_rqd_flag                  in  varchar2
  ,p_ordr_num                       in  number
  ,p_crntly_enrld_flag              in  varchar2
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_prtt_enrt_rslt_id              in  number
  ,p_comp_lvl_fctr_id               in  number
  ,p_business_group_id              in  number
  ,p_enb_attribute_category         in  varchar2
  ,p_enb_attribute1                 in  varchar2
  ,p_enb_attribute2                 in  varchar2
  ,p_enb_attribute3                 in  varchar2
  ,p_enb_attribute4                 in  varchar2
  ,p_enb_attribute5                 in  varchar2
  ,p_enb_attribute6                 in  varchar2
  ,p_enb_attribute7                 in  varchar2
  ,p_enb_attribute8                 in  varchar2
  ,p_enb_attribute9                 in  varchar2
  ,p_enb_attribute10                in  varchar2
  ,p_enb_attribute11                in  varchar2
  ,p_enb_attribute12                in  varchar2
  ,p_enb_attribute13                in  varchar2
  ,p_enb_attribute14                in  varchar2
  ,p_enb_attribute15                in  varchar2
  ,p_enb_attribute16                in  varchar2
  ,p_enb_attribute17                in  varchar2
  ,p_enb_attribute18                in  varchar2
  ,p_enb_attribute19                in  varchar2
  ,p_enb_attribute20                in  varchar2
  ,p_enb_attribute21                in  varchar2
  ,p_enb_attribute22                in  varchar2
  ,p_enb_attribute23                in  varchar2
  ,p_enb_attribute24                in  varchar2
  ,p_enb_attribute25                in  varchar2
  ,p_enb_attribute26                in  varchar2
  ,p_enb_attribute27                in  varchar2
  ,p_enb_attribute28                in  varchar2
  ,p_enb_attribute29                in  varchar2
  ,p_enb_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_mx_wout_ctfn_val               in  number
  ,p_mx_wo_ctfn_flag                in  varchar2
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
 )
	Return g_rec_type;
--
end ben_enb_shd;

 

/
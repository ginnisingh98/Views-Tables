--------------------------------------------------------
--  DDL for Package BEN_CSO_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CSO_SHD" AUTHID CURRENT_USER as
/* $Header: becsorhi.pkh 120.0.12010000.1 2008/07/29 11:15:47 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (cwb_stock_optn_dtls_id          number(15)
  ,grant_id                        number(15)
  ,grant_number                    varchar2(30)
  ,grant_name                      varchar2(100)
  ,grant_type                      varchar2(30)
  ,grant_date                      date
  ,grant_shares                    number
  ,grant_price                     number
  ,value_at_grant                  number
  ,current_share_price             number
  ,current_shares_outstanding      number
  ,vested_shares                   number
  ,unvested_shares                 number
  ,exercisable_shares              number
  ,exercised_shares                number
  ,cancelled_shares                number
  ,trading_symbol                  varchar2(30)
  ,expiration_date                 date
  ,reason_code                     varchar2(30)
  ,class                           varchar2(30)
  ,misc                            varchar2(100)
  ,employee_number                 varchar2(30)
  ,person_id                       number(15)
  ,business_group_id               number(15)
  ,prtt_rt_val_id                  number(15)
  ,object_version_number           number(9)
  ,cso_attribute_category          varchar2(30)
  ,cso_attribute1                  varchar2(150)
  ,cso_attribute2                  varchar2(150)
  ,cso_attribute3                  varchar2(150)
  ,cso_attribute4                  varchar2(150)
  ,cso_attribute5                  varchar2(150)
  ,cso_attribute6                  varchar2(150)
  ,cso_attribute7                  varchar2(150)
  ,cso_attribute8                  varchar2(150)
  ,cso_attribute9                  varchar2(150)
  ,cso_attribute10                 varchar2(150)
  ,cso_attribute11                 varchar2(150)
  ,cso_attribute12                 varchar2(150)
  ,cso_attribute13                 varchar2(150)
  ,cso_attribute14                 varchar2(150)
  ,cso_attribute15                 varchar2(150)
  ,cso_attribute16                 varchar2(150)
  ,cso_attribute17                 varchar2(150)
  ,cso_attribute18                 varchar2(150)
  ,cso_attribute19                 varchar2(150)
  ,cso_attribute20                 varchar2(150)
  ,cso_attribute21                 varchar2(150)
  ,cso_attribute22                 varchar2(150)
  ,cso_attribute23                 varchar2(150)
  ,cso_attribute24                 varchar2(150)
  ,cso_attribute25                 varchar2(150)
  ,cso_attribute26                 varchar2(150)
  ,cso_attribute27                 varchar2(150)
  ,cso_attribute28                 varchar2(150)
  ,cso_attribute29                 varchar2(150)
  ,cso_attribute30                 varchar2(150)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
-- Global table name
g_tab_nam  constant varchar2(30) := 'BEN_CWB_STOCK_OPTN_DTLS';
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
  (p_cwb_stock_optn_dtls_id               in     number
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
  (p_cwb_stock_optn_dtls_id               in     number
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
  (p_cwb_stock_optn_dtls_id         in number
  ,p_grant_id                       in number
  ,p_grant_number                   in varchar2
  ,p_grant_name                     in varchar2
  ,p_grant_type                     in varchar2
  ,p_grant_date                     in date
  ,p_grant_shares                   in number
  ,p_grant_price                    in number
  ,p_value_at_grant                 in number
  ,p_current_share_price            in number
  ,p_current_shares_outstanding     in number
  ,p_vested_shares                  in number
  ,p_unvested_shares                in number
  ,p_exercisable_shares             in number
  ,p_exercised_shares               in number
  ,p_cancelled_shares               in number
  ,p_trading_symbol                 in varchar2
  ,p_expiration_date                in date
  ,p_reason_code                    in varchar2
  ,p_class                          in varchar2
  ,p_misc                           in varchar2
  ,p_employee_number                in varchar2
  ,p_person_id                      in number
  ,p_business_group_id              in number
  ,p_prtt_rt_val_id                 in number
  ,p_object_version_number          in number
  ,p_cso_attribute_category         in varchar2
  ,p_cso_attribute1                 in varchar2
  ,p_cso_attribute2                 in varchar2
  ,p_cso_attribute3                 in varchar2
  ,p_cso_attribute4                 in varchar2
  ,p_cso_attribute5                 in varchar2
  ,p_cso_attribute6                 in varchar2
  ,p_cso_attribute7                 in varchar2
  ,p_cso_attribute8                 in varchar2
  ,p_cso_attribute9                 in varchar2
  ,p_cso_attribute10                in varchar2
  ,p_cso_attribute11                in varchar2
  ,p_cso_attribute12                in varchar2
  ,p_cso_attribute13                in varchar2
  ,p_cso_attribute14                in varchar2
  ,p_cso_attribute15                in varchar2
  ,p_cso_attribute16                in varchar2
  ,p_cso_attribute17                in varchar2
  ,p_cso_attribute18                in varchar2
  ,p_cso_attribute19                in varchar2
  ,p_cso_attribute20                in varchar2
  ,p_cso_attribute21                in varchar2
  ,p_cso_attribute22                in varchar2
  ,p_cso_attribute23                in varchar2
  ,p_cso_attribute24                in varchar2
  ,p_cso_attribute25                in varchar2
  ,p_cso_attribute26                in varchar2
  ,p_cso_attribute27                in varchar2
  ,p_cso_attribute28                in varchar2
  ,p_cso_attribute29                in varchar2
  ,p_cso_attribute30                in varchar2
  )
  Return g_rec_type;
--
end ben_cso_shd;

/

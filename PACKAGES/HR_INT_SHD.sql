--------------------------------------------------------
--  DDL for Package HR_INT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_INT_SHD" AUTHID CURRENT_USER as
/* $Header: hrintrhi.pkh 120.0 2005/05/31 00:52:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (integration_id                  number(15)
  ,integration_key                 varchar2(100)
  ,party_type                      varchar2(240)
  ,party_name                      varchar2(360)
  ,party_site_name                 varchar2(904)
  ,transaction_type                varchar2(100)
  ,transaction_subtype             varchar2(100)
  ,standard_code                   varchar2(30)
  ,ext_trans_type                  varchar2(100)
  ,ext_trans_subtype               varchar2(100)
  ,trans_direction                 varchar2(20)
  ,url                             varchar2(2000)
  ,synched                         varchar2(9)       -- Increased length
  ,ext_application_id              number(15)
  ,application_name                varchar2(80)
  ,application_type                varchar2(80)
  ,application_url                 varchar2(1000)
  ,logout_url                      varchar2(1000)
  ,user_field                      varchar2(80)
  ,password_field                  varchar2(80)
  ,authentication_needed           varchar2(80)
  ,field_name1                     varchar2(80)
  ,field_value1                    varchar2(1000)
  ,field_name2                     varchar2(80)
  ,field_value2                    varchar2(1000)
  ,field_name3                     varchar2(80)
  ,field_value3                    varchar2(1000)
  ,field_name4                     varchar2(80)
  ,field_value4                    varchar2(1000)
  ,field_name5                     varchar2(80)
  ,field_value5                    varchar2(1000)
  ,field_name6                     varchar2(80)
  ,field_value6                    varchar2(1000)
  ,field_name7                     varchar2(80)
  ,field_value7                    varchar2(1000)
  ,field_name8                     varchar2(80)
  ,field_value8                    varchar2(1000)
  ,field_name9                     varchar2(80)
  ,field_value9                    varchar2(1000)
  ,object_version_number           number(9)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
-- Global table name
g_tab_nam  constant varchar2(30) := 'HR_KI_INTEGRATIONS';
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
  (p_integration_id                       in     number
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
  (p_integration_id                       in     number
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
  (p_integration_id                 in number
  ,p_integration_key                in varchar2
  ,p_party_type                     in varchar2
  ,p_party_name                     in varchar2
  ,p_party_site_name                in varchar2
  ,p_transaction_type               in varchar2
  ,p_transaction_subtype            in varchar2
  ,p_standard_code                  in varchar2
  ,p_ext_trans_type                 in varchar2
  ,p_ext_trans_subtype              in varchar2
  ,p_trans_direction                in varchar2
  ,p_url                            in varchar2
  ,p_synched                        in varchar2
  ,p_ext_application_id             in number
  ,p_application_name               in varchar2
  ,p_application_type               in varchar2
  ,p_application_url                in varchar2
  ,p_logout_url                     in varchar2
  ,p_user_field                     in varchar2
  ,p_password_field                 in varchar2
  ,p_authentication_needed          in varchar2
  ,p_field_name1                    in varchar2
  ,p_field_value1                   in varchar2
  ,p_field_name2                    in varchar2
  ,p_field_value2                   in varchar2
  ,p_field_name3                    in varchar2
  ,p_field_value3                   in varchar2
  ,p_field_name4                    in varchar2
  ,p_field_value4                   in varchar2
  ,p_field_name5                    in varchar2
  ,p_field_value5                   in varchar2
  ,p_field_name6                    in varchar2
  ,p_field_value6                   in varchar2
  ,p_field_name7                    in varchar2
  ,p_field_value7                   in varchar2
  ,p_field_name8                    in varchar2
  ,p_field_value8                   in varchar2
  ,p_field_name9                    in varchar2
  ,p_field_value9                   in varchar2
  ,p_object_version_number          in number
  )
  Return g_rec_type;
--
end hr_int_shd;

 

/

--------------------------------------------------------
--  DDL for Package OTA_TSR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TSR_SHD" AUTHID CURRENT_USER as
/* $Header: ottsr01t.pkh 120.1 2006/02/13 02:49:09 jbharath noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  supplied_resource_id              number(9),
  vendor_id                         number(15),
  business_group_id                 number(9),
  resource_definition_id            number(15),
  consumable_flag                   varchar2(30),
  object_version_number             number(9),        -- Increased length
  resource_type                     varchar2(30),
  start_date                        date,
  comments                          varchar2(2000),
  cost                              number(17,2),     -- Increased length
  cost_unit                         varchar2(30),
  currency_code                     varchar2(30),
  end_date                          date,
  internal_address_line             varchar2(80),
  lead_time                         number(17,2),     -- Increased length
  name                              varchar2(400),    -- Increased length bug#5018347
  supplier_reference                varchar2(80),
  tsr_information_category          varchar2(30),
  tsr_information1                  varchar2(150),
  tsr_information2                  varchar2(150),
  tsr_information3                  varchar2(150),
  tsr_information4                  varchar2(150),
  tsr_information5                  varchar2(150),
  tsr_information6                  varchar2(150),
  tsr_information7                  varchar2(150),
  tsr_information8                  varchar2(150),
  tsr_information9                  varchar2(150),
  tsr_information10                 varchar2(150),
  tsr_information11                 varchar2(150),
  tsr_information12                 varchar2(150),
  tsr_information13                 varchar2(150),
  tsr_information14                 varchar2(150),
  tsr_information15                 varchar2(150),
  tsr_information16                 varchar2(150),
  tsr_information17                 varchar2(150),
  tsr_information18                 varchar2(150),
  tsr_information19                 varchar2(150),
  tsr_information20                 varchar2(150),
  training_center_id                number(15),
  location_id				number(15),
  trainer_id                        number(10),
  special_instruction               varchar2(2000)
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
-- Pre Conditions:
--   None.
--
-- In Arguments:
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
--   Public.
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
-- Pre Conditions:
--   1) Either hr_api.check_integrity_violated,
--      hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--      hr_api.unique_integrity_violated has been raised with the subsequent
--      stripping of the constraint name from the generated error message
--      text.
--   2) Standalone validation test which correspond with a constraint error.
--
-- In Arguments:
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
--   Public.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in varchar2);
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
-- Pre Conditions:
--   None.
--
-- In Arguments:
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
  p_supplied_resource_id               in number,
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
-- Pre Conditions:
--   When attempting to call the lock the object version number (if defined)
--   is mandatory.
--
-- In Arguments:
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
--   Public.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_supplied_resource_id               in number,
  p_object_version_number              in number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute arguments into the record
--   structure g_rec_type.
--
-- Pre Conditions:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Arguments:
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_supplied_resource_id          in number,
	p_vendor_id                     in number,
	p_business_group_id             in number,
	p_resource_definition_id        in number,
	p_consumable_flag               in varchar2,
	p_object_version_number         in number,
	p_resource_type                 in varchar2,
	p_start_date                    in date,
	p_comments                      in varchar2,
	p_cost                          in number,
	p_cost_unit                     in varchar2,
	p_currency_code                 in varchar2,
	p_end_date                      in date,
	p_internal_address_line         in varchar2,
	p_lead_time                     in number,
	p_name                          in varchar2,
	p_supplier_reference            in varchar2,
	p_tsr_information_category      in varchar2,
	p_tsr_information1              in varchar2,
	p_tsr_information2              in varchar2,
	p_tsr_information3              in varchar2,
	p_tsr_information4              in varchar2,
	p_tsr_information5              in varchar2,
	p_tsr_information6              in varchar2,
	p_tsr_information7              in varchar2,
	p_tsr_information8              in varchar2,
	p_tsr_information9              in varchar2,
	p_tsr_information10             in varchar2,
	p_tsr_information11             in varchar2,
	p_tsr_information12             in varchar2,
	p_tsr_information13             in varchar2,
	p_tsr_information14             in varchar2,
	p_tsr_information15             in varchar2,
	p_tsr_information16             in varchar2,
	p_tsr_information17             in varchar2,
	p_tsr_information18             in varchar2,
	p_tsr_information19             in varchar2,
	p_tsr_information20             in varchar2,
      p_training_center_id            in number,
      p_location_id			  in number,
      p_trainer_id                    in number,
      p_special_instruction           in varchar2
	)
	Return g_rec_type;
--
end ota_tsr_shd;

 

/

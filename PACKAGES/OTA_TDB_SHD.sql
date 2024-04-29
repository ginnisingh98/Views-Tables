--------------------------------------------------------
--  DDL for Package OTA_TDB_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TDB_SHD" AUTHID CURRENT_USER as
/* $Header: ottdb01t.pkh 120.5.12010000.2 2009/08/13 09:15:22 smahanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  booking_id                        number(9),
  booking_status_type_id            number(9),
  delegate_person_id               ota_delegate_bookings.delegate_person_id%TYPE,
  contact_id                        number(15),
  business_group_id                 number(9),
  event_id                          number(9),
  customer_id                       number(15),
  authorizer_person_id              ota_delegate_bookings.authorizer_person_id%TYPE,
  date_booking_placed               date,
  corespondent                      varchar2(30),
  internal_booking_flag             varchar2(30),
  number_of_places                  number(9),
  object_version_number             number(9),        -- Increased length
  administrator                     number(9),
  booking_priority                  varchar2(30),
  comments                          varchar2(2000),
  contact_address_id                number(15),
  delegate_contact_phone            varchar2(30),
  delegate_contact_fax              varchar2(30),
  -- Modified for Bug#4049773
  --third_party_customer_id           number(9),
  --third_party_contact_id            number(9),
  --third_party_address_id            number(9),
  third_party_customer_id           number(15),
  third_party_contact_id            number(15),
  third_party_address_id            number(15),
  third_party_contact_phone         varchar2(30),
  third_party_contact_fax           varchar2(30),
  date_status_changed               date,
  failure_reason                    varchar2(30),
  attendance_result                 varchar2(255),
  language_id                       number(9),
  source_of_booking                 varchar2(30),
  special_booking_instructions      varchar2(2000),
  successful_attendance_flag        varchar2(30),
  tdb_information_category          varchar2(30),
  tdb_information1                  varchar2(150),
  tdb_information2                  varchar2(150),
  tdb_information3                  varchar2(150),
  tdb_information4                  varchar2(150),
  tdb_information5                  varchar2(150),
  tdb_information6                  varchar2(150),
  tdb_information7                  varchar2(150),
  tdb_information8                  varchar2(150),
  tdb_information9                  varchar2(150),
  tdb_information10                 varchar2(150),
  tdb_information11                 varchar2(150),
  tdb_information12                 varchar2(150),
  tdb_information13                 varchar2(150),
  tdb_information14                 varchar2(150),
  tdb_information15                 varchar2(150),
  tdb_information16                 varchar2(150),
  tdb_information17                 varchar2(150),
  tdb_information18                 varchar2(150),
  tdb_information19                 varchar2(150),
  tdb_information20                 varchar2(150),
  organization_id                   number(15),
  sponsor_person_id                 ota_delegate_bookings.sponsor_person_id%TYPE,
  sponsor_assignment_id             ota_delegate_bookings.sponsor_assignment_id%TYPE,
  person_address_id                 number(15),
  delegate_assignment_id            ota_delegate_bookings.delegate_assignment_id%TYPE,
  delegate_contact_id               number(15),
  delegate_contact_email            varchar2(240),
  third_party_email                 varchar2(240),
  person_address_type               varchar2(30),
  line_id             number(15),
  org_id           number(15),
  daemon_flag            varchar2(15),
  daemon_type            varchar2(15),
  old_event_id                      number(9),
  quote_line_id                     number,
  interface_source                  varchar2(30),
  total_training_time               varchar2(10),
  content_player_status             varchar2(30),
  score                       number ,
  completed_content        number ,
  total_content	                  number,
  booking_justification_id                number(15)
  ,is_history_flag                 varchar2(9)
  ,sign_eval_status            ota_delegate_bookings.sign_eval_status%TYPE,
  is_mandatory_enrollment      ota_delegate_bookings.is_mandatory_enrollment%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
g_created_by  number;                             -- Global creation user
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
  p_booking_id                         in number,
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
  p_booking_id                         in number,
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
   p_booking_id                    in number,
   p_booking_status_type_id        in number,
   p_delegate_person_id            in number,
   p_contact_id                    in number,
   p_business_group_id             in number,
   p_event_id                      in number,
   p_customer_id                   in number,
   p_authorizer_person_id          in number,
   p_date_booking_placed           in date,
        p_corespondent                  in varchar2,
   p_internal_booking_flag         in varchar2,
   p_number_of_places              in number,
   p_object_version_number         in number,
   p_administrator                 in number,
   p_booking_priority              in varchar2,
   p_comments                      in varchar2,
   p_contact_address_id            in number,
      p_delegate_contact_phone        in varchar2,
      p_delegate_contact_fax          in varchar2,
      p_third_party_customer_id       in number,
      p_third_party_contact_id        in number,
      p_third_party_address_id        in number,
      p_third_party_contact_phone     in varchar2,
      p_third_party_contact_fax       in varchar2,
   p_date_status_changed           in date,
   p_failure_reason                in varchar2,
      p_attendance_result             in varchar2,
   p_language_id                   in number,
   p_source_of_booking             in varchar2,
   p_special_booking_instructions  in varchar2,
   p_successful_attendance_flag    in varchar2,
   p_tdb_information_category      in varchar2,
   p_tdb_information1              in varchar2,
   p_tdb_information2              in varchar2,
   p_tdb_information3              in varchar2,
   p_tdb_information4              in varchar2,
   p_tdb_information5              in varchar2,
   p_tdb_information6              in varchar2,
   p_tdb_information7              in varchar2,
   p_tdb_information8              in varchar2,
   p_tdb_information9              in varchar2,
   p_tdb_information10             in varchar2,
   p_tdb_information11             in varchar2,
   p_tdb_information12             in varchar2,
   p_tdb_information13             in varchar2,
   p_tdb_information14             in varchar2,
   p_tdb_information15             in varchar2,
   p_tdb_information16             in varchar2,
   p_tdb_information17             in varchar2,
   p_tdb_information18             in varchar2,
   p_tdb_information19             in varchar2,
   p_tdb_information20             in varchar2,
      p_organization_id               in number,
      p_sponsor_person_id             in number,
      p_sponsor_assignment_id         in number,
      p_person_address_id             in number,
      p_delegate_assignment_id        in number,
      p_delegate_contact_id           in number,
      p_delegate_contact_email        in varchar2,
      p_third_party_email             in varchar2,
      p_person_address_type           in varchar2,
      p_line_id                 in number,
      p_org_id            in number,
      p_daemon_flag          in varchar2,
      p_daemon_type          in varchar2,
      p_old_event_id                  in number,
      p_quote_line_id                 in number,
      p_interface_source              in varchar2,
   p_total_training_time           in varchar2 ,
   p_content_player_status         in varchar2 ,
   p_score                   in number   ,
   p_completed_content       in number   ,
  	p_total_content	              in number,
	p_booking_justification_id            in number
  ,p_is_history_flag                in varchar2
  ,p_sign_eval_status             in varchar2 default null
  ,p_is_mandatory_enrollment      in varchar2 default 'N')
   Return g_rec_type;
--
end ota_tdb_shd;

/

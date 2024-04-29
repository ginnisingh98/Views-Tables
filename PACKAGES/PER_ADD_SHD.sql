--------------------------------------------------------
--  DDL for Package PER_ADD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ADD_SHD" AUTHID CURRENT_USER as
/* $Header: peaddrhi.pkh 120.0.12010000.1 2008/07/28 04:03:04 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  address_id                        number(15),
  business_group_id                 number(15),
  person_id                         per_addresses.person_id%TYPE,
  date_from                         date,
  primary_flag                      varchar2(30),
  derived_locale                    varchar2(240),
  style                             varchar2(30),
  address_line1                     varchar2(240),-- UTF8: Increased from 60 to 240
  address_line2                     varchar2(240),-- UTF8: Increased from 60 to 240
  address_line3                     varchar2(240),-- UTF8: Increased from 60 to 240
  address_type                      varchar2(30),
  comments                          long,
  country                           varchar2(60),
  date_to                           date,
  postal_code                       varchar2(30),
  region_1                          varchar2(120), -- UTF8: Increased from 70 to 120
  region_2                          varchar2(120), -- UTF8: Increased from 70 to 120
  region_3                          varchar2(120), -- UTF8: Increased from 70 to 120
  telephone_number_1                varchar2(60),
  telephone_number_2                varchar2(60),
  telephone_number_3                varchar2(60),
  town_or_city                      varchar2(30),
  request_id                        number(15),
  program_application_id            number(15),
  program_id                        number(15),
  program_update_date               date,
  addr_attribute_category           varchar2(30),
  addr_attribute1                   varchar2(150),
  addr_attribute2                   varchar2(150),
  addr_attribute3                   varchar2(150),
  addr_attribute4                   varchar2(150),
  addr_attribute5                   varchar2(150),
  addr_attribute6                   varchar2(150),
  addr_attribute7                   varchar2(150),
  addr_attribute8                   varchar2(150),
  addr_attribute9                   varchar2(150),
  addr_attribute10                  varchar2(150),
  addr_attribute11                  varchar2(150),
  addr_attribute12                  varchar2(150),
  addr_attribute13                  varchar2(150),
  addr_attribute14                  varchar2(150),
  addr_attribute15                  varchar2(150),
  addr_attribute16                  varchar2(150),
  addr_attribute17                  varchar2(150),
  addr_attribute18                  varchar2(150),
  addr_attribute19                  varchar2(150),
  addr_attribute20                  varchar2(150),
  add_information13                 varchar2(150),
  add_information14                 varchar2(150),
  add_information15                 varchar2(150),
  add_information16                 varchar2(150),
  add_information17                 varchar2(150),
  add_information18                 varchar2(150),
  add_information19                 varchar2(150),
  add_information20                 varchar2(150),
  object_version_number             number(9),
  party_id                          per_addresses.party_id%TYPE,
  geometry                          per_addresses.geometry%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Table Handler Use Only            |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
g_api_dml  boolean;                               -- Global api dml status
g_tab_nam constant varchar2(30) := 'PER_ADDRESSES';
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
--   Internal Table Handler Use Only.
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_address_id                         in number,
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_address_id                         in number,
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_address_id                    in number,
	p_business_group_id             in number,
	p_person_id                     in number,
	p_date_from                     in date,
	p_primary_flag                  in varchar2,
	p_style                         in varchar2,
	p_address_line1                 in varchar2,
	p_address_line2                 in varchar2,
	p_address_line3                 in varchar2,
	p_address_type                  in varchar2,
	p_comments                      in long,
	p_country                       in varchar2,
	p_date_to                       in date,
	p_postal_code                   in varchar2,
	p_region_1                      in varchar2,
	p_region_2                      in varchar2,
	p_region_3                      in varchar2,
	p_telephone_number_1            in varchar2,
	p_telephone_number_2            in varchar2,
	p_telephone_number_3            in varchar2,
	p_town_or_city                  in varchar2,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
	p_addr_attribute_category       in varchar2,
	p_addr_attribute1               in varchar2,
	p_addr_attribute2               in varchar2,
	p_addr_attribute3               in varchar2,
	p_addr_attribute4               in varchar2,
	p_addr_attribute5               in varchar2,
	p_addr_attribute6               in varchar2,
	p_addr_attribute7               in varchar2,
	p_addr_attribute8               in varchar2,
	p_addr_attribute9               in varchar2,
	p_addr_attribute10              in varchar2,
	p_addr_attribute11              in varchar2,
	p_addr_attribute12              in varchar2,
	p_addr_attribute13              in varchar2,
	p_addr_attribute14              in varchar2,
	p_addr_attribute15              in varchar2,
	p_addr_attribute16              in varchar2,
	p_addr_attribute17              in varchar2,
	p_addr_attribute18              in varchar2,
	p_addr_attribute19              in varchar2,
	p_addr_attribute20              in varchar2,
	p_add_information13             in varchar2,
	p_add_information14             in varchar2,
	p_add_information15             in varchar2,
	p_add_information16             in varchar2,
	p_add_information17             in varchar2,
	p_add_information18             in varchar2,
	p_add_information19             in varchar2,
	p_add_information20             in varchar2,
	p_object_version_number         in number,
	p_party_id                      in number  default null
	)
	Return g_rec_type;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------------< derive_locale >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Populated the 'derived_locale' element of p_rec record structure.  This
--    is acheived the use of legislative specific functions contained within
--    localization utility packages.  If the localization package doesn't
--    exist, or does not contain the required function, a default value is
--    entered into the structure.
--
--  In Arguments:
--    p_rec
--
--  Access Status:
--    Internal Development Use Only.
--
procedure derive_locale(p_rec in out nocopy per_add_shd.g_rec_type);

end per_add_shd;

/

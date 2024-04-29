--------------------------------------------------------
--  DDL for Package HR_LOC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOC_SHD" AUTHID CURRENT_USER AS
/* $Header: hrlocrhi.pkh 120.1 2005/07/18 06:20:20 bshukla noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
-- Note longitude and latitude are defined as number(10,7) on database, but we
-- need to be able to store hr_api.g_number (an 9 digit integer) for updates.
-- Therefore, in the record structure we use number(16,7).
--
--
TYPE g_rec_type IS RECORD
  (
     location_id                       NUMBER(15),
     entered_by                        NUMBER(15),
     location_code                     VARCHAR2(60),
     timezone_code                     VARCHAR2(50),
     address_line_1                    VARCHAR2(240),
     address_line_2                    VARCHAR2(240),
     address_line_3                    VARCHAR2(240),
     bill_to_site_flag                 VARCHAR2(30),
     country                           VARCHAR2(60),
     description                       VARCHAR2(240),
     designated_receiver_id            NUMBER(15),
     in_organization_flag              VARCHAR2(30),
     inactive_date                     DATE,
     inventory_organization_id         NUMBER(15),
     office_site_flag                  VARCHAR2(30),
     postal_code                       VARCHAR2(30),
     receiving_site_flag               VARCHAR2(30),
     region_1                          VARCHAR2(120),
     region_2                          VARCHAR2(120),
     region_3                          VARCHAR2(120),
     ship_to_location_id               NUMBER(15),
     ship_to_site_flag                 VARCHAR2(30),
     derived_locale                    VARCHAR2(240),
     style                             VARCHAR2(30),
     tax_name                          VARCHAR2(15),
     telephone_number_1                VARCHAR2(60),
     telephone_number_2                VARCHAR2(60),
     telephone_number_3                VARCHAR2(60),
     town_or_city                      VARCHAR2(30),
     loc_information13                 VARCHAR2(150),
     loc_information14                 VARCHAR2(150),
     loc_information15                 VARCHAR2(150),
     loc_information16                 VARCHAR2(150),
     loc_information17                 VARCHAR2(150),
     loc_information18                 VARCHAR2(150),
     loc_information19                 VARCHAR2(150),
     loc_information20                 VARCHAR2(150),
     attribute_category                VARCHAR2(30),
     attribute1                        VARCHAR2(150),
     attribute2                        VARCHAR2(150),
     attribute3                        VARCHAR2(150),
     attribute4                        VARCHAR2(150),
     attribute5                        VARCHAR2(150),
     attribute6                        VARCHAR2(150),
     attribute7                        VARCHAR2(150),
     attribute8                        VARCHAR2(150),
     attribute9                        VARCHAR2(150),
     attribute10                       VARCHAR2(150),
     attribute11                       VARCHAR2(150),
     attribute12                       VARCHAR2(150),
     attribute13                       VARCHAR2(150),
     attribute14                       VARCHAR2(150),
     attribute15                       VARCHAR2(150),
     attribute16                       VARCHAR2(150),
     attribute17                       VARCHAR2(150),
     attribute18                       VARCHAR2(150),
     attribute19                       VARCHAR2(150),
     attribute20                       VARCHAR2(150),
     global_attribute_category         VARCHAR2(150),
     global_attribute1                 VARCHAR2(150),
     global_attribute2                 VARCHAR2(150),
     global_attribute3                 VARCHAR2(150),
     global_attribute4                 VARCHAR2(150),
     global_attribute5                 VARCHAR2(150),
     global_attribute6                 VARCHAR2(150),
     global_attribute7                 VARCHAR2(150),
     global_attribute8                 VARCHAR2(150),
     global_attribute9                 VARCHAR2(150),
     global_attribute10                VARCHAR2(150),
     global_attribute11                VARCHAR2(150),
     global_attribute12                VARCHAR2(150),
     global_attribute13                VARCHAR2(150),
     global_attribute14                VARCHAR2(150),
     global_attribute15                VARCHAR2(150),
     global_attribute16                VARCHAR2(150),
     global_attribute17                VARCHAR2(150),
     global_attribute18                VARCHAR2(150),
     global_attribute19                VARCHAR2(150),
     global_attribute20                VARCHAR2(150),
     legal_address_flag                 VARCHAR2(30),
     tp_header_id                      NUMBER(15),
     ece_tp_location_code              VARCHAR2(35),
     object_version_number             NUMBER(9),
     business_group_id                 NUMBER(15),
     geometry                          MDSYS.SDO_GEOMETRY
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--

  g_old_rec  g_rec_type;                            -- Global record definition
  g_api_dml  BOOLEAN;                               -- Global api dml status --

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
FUNCTION return_api_dml_status RETURN BOOLEAN;
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
PROCEDURE constraint_error
  (p_constraint_name IN all_constraints.constraint_name%type);
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
FUNCTION api_updating
  (
   p_location_id                        IN NUMBER,
   p_object_version_number              IN NUMBER
  ) RETURN BOOLEAN;
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
PROCEDURE lck
  (
   p_location_id                        IN NUMBER,
   p_object_version_number              IN NUMBER
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
FUNCTION convert_args
  (
   p_location_id                   IN NUMBER,
   p_location_code                 IN VARCHAR2,
   p_timezone_code                 IN VARCHAR2,
   p_address_line_1                IN VARCHAR2,
   p_address_line_2                IN VARCHAR2,
   p_address_line_3                IN VARCHAR2,
   p_bill_to_site_flag             IN VARCHAR2,
   p_country                       IN VARCHAR2,
   p_description                   IN VARCHAR2,
   p_designated_receiver_id        IN NUMBER,
   p_in_organization_flag          IN VARCHAR2,
   p_inactive_date                 IN DATE,
   p_inventory_organization_id     IN NUMBER,
   p_office_site_flag              IN VARCHAR2,
   p_postal_code                   IN VARCHAR2,
   p_receiving_site_flag           IN VARCHAR2,
   p_region_1                      IN VARCHAR2,
   p_region_2                      IN VARCHAR2,
   p_region_3                      IN VARCHAR2,
   p_ship_to_location_id           IN NUMBER,
   p_ship_to_site_flag             IN VARCHAR2,
   p_style                         IN VARCHAR2,
   p_tax_name                      IN VARCHAR2,
   p_telephone_number_1            IN VARCHAR2,
   p_telephone_number_2            IN VARCHAR2,
   p_telephone_number_3            IN VARCHAR2,
   p_town_or_city                  IN VARCHAR2,
   p_loc_information13             IN VARCHAR2,
   p_loc_information14             IN VARCHAR2,
   p_loc_information15             IN VARCHAR2,
   p_loc_information16             IN VARCHAR2,
   p_loc_information17             IN VARCHAR2,
   p_loc_information18             IN VARCHAR2,
   p_loc_information19             IN VARCHAR2,
   p_loc_information20             IN VARCHAR2,
   p_attribute_category            IN VARCHAR2,
   p_attribute1                    IN VARCHAR2,
   p_attribute2                    IN VARCHAR2,
   p_attribute3                    IN VARCHAR2,
   p_attribute4                    IN VARCHAR2,
   p_attribute5                    IN VARCHAR2,
   p_attribute6                    IN VARCHAR2,
   p_attribute7                    IN VARCHAR2,
   p_attribute8                    IN VARCHAR2,
   p_attribute9                    IN VARCHAR2,
   p_attribute10                   IN VARCHAR2,
   p_attribute11                   IN VARCHAR2,
   p_attribute12                   IN VARCHAR2,
   p_attribute13                   IN VARCHAR2,
   p_attribute14                   IN VARCHAR2,
   p_attribute15                   IN VARCHAR2,
   p_attribute16                   IN VARCHAR2,
   p_attribute17                   IN VARCHAR2,
   p_attribute18                   IN VARCHAR2,
   p_attribute19                   IN VARCHAR2,
   p_attribute20                   IN VARCHAR2,
   p_global_attribute_category     IN VARCHAR2,
   p_global_attribute1             IN VARCHAR2,
   p_global_attribute2             IN VARCHAR2,
   p_global_attribute3             IN VARCHAR2,
   p_global_attribute4             IN VARCHAR2,
   p_global_attribute5             IN VARCHAR2,
   p_global_attribute6             IN VARCHAR2,
   p_global_attribute7             IN VARCHAR2,
   p_global_attribute8             IN VARCHAR2,
   p_global_attribute9             IN VARCHAR2,
   p_global_attribute10            IN VARCHAR2,
   p_global_attribute11            IN VARCHAR2,
   p_global_attribute12            IN VARCHAR2,
   p_global_attribute13            IN VARCHAR2,
   p_global_attribute14            IN VARCHAR2,
   p_global_attribute15            IN VARCHAR2,
   p_global_attribute16            IN VARCHAR2,
   p_global_attribute17            IN VARCHAR2,
   p_global_attribute18            IN VARCHAR2,
   p_global_attribute19            IN VARCHAR2,
   p_global_attribute20            IN VARCHAR2,
   p_legal_address_flag             IN VARCHAR2,
   p_tp_header_id                  IN NUMBER,
   p_ece_tp_location_code          IN VARCHAR2,
   p_object_version_number         IN NUMBER,
   p_business_group_id             IN NUMBER
  )
   RETURN g_rec_type;
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
procedure derive_locale(p_rec in out nocopy hr_loc_shd.g_rec_type);

END hr_loc_shd;

 

/

--------------------------------------------------------
--  DDL for Package PAY_PYR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PYR_SHD" AUTHID CURRENT_USER AS
/* $Header: pypyrrhi.pkh 120.0 2005/05/29 08:11:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
TYPE g_rec_type IS RECORD
  (rate_id                         NUMBER(15)
  ,business_group_id               NUMBER(15)
  ,parent_spine_id                 NUMBER(15)
  ,name                            VARCHAR2(80)
  ,rate_type                       VARCHAR2(30)
  ,rate_uom                        VARCHAR2(30)
  ,comments                        VARCHAR2(2000)    -- pseudo column
  ,request_id                      NUMBER(15)
  ,program_application_id          NUMBER(15)
  ,program_id                      NUMBER(15)
  ,program_update_date             DATE
  ,attribute_category              VARCHAR2(30)
  ,attribute1                      VARCHAR2(150)
  ,attribute2                      VARCHAR2(150)
  ,attribute3                      VARCHAR2(150)
  ,attribute4                      VARCHAR2(150)
  ,attribute5                      VARCHAR2(150)
  ,attribute6                      VARCHAR2(150)
  ,attribute7                      VARCHAR2(150)
  ,attribute8                      VARCHAR2(150)
  ,attribute9                      VARCHAR2(150)
  ,attribute10                     VARCHAR2(150)
  ,attribute11                     VARCHAR2(150)
  ,attribute12                     VARCHAR2(150)
  ,attribute13                     VARCHAR2(150)
  ,attribute14                     VARCHAR2(150)
  ,attribute15                     VARCHAR2(150)
  ,attribute16                     VARCHAR2(150)
  ,attribute17                     VARCHAR2(150)
  ,attribute18                     VARCHAR2(150)
  ,attribute19                     VARCHAR2(150)
  ,attribute20                     VARCHAR2(150)
  ,rate_basis                      VARCHAR2(30)
  ,asg_rate_type                   VARCHAR2(30)
  ,object_version_NUMBER           NUMBER(9)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
-- Global table name
g_tab_nam  constant VARCHAR2(30) := 'PAY_RATES';
g_api_dml  BOOLEAN;                               -- Global api dml status
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will return the current g_api_dml private global
--   BOOLEAN status.
--   The g_api_dml status determines if at the time of the function
--   being executed if a dml statement (i.e. INSERT, UPDATE or DELETE)
--   is being issued from within an api.
--   If the status is TRUE then a dml statement is being issued from
--   within this entity api.
--   This function is primarily to support database triggers which
--   need to maintain the object_version_NUMBER for non-supported
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
--   This PROCEDURE is called when a constraint has been violated (i.e.
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
--   p_constraint_name is IN upper format and is just the constraint name
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
  (p_constraint_name IN all_constraints.constraint_name%TYPE);
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
--   2) If an object_version_NUMBER exists but is NOT the same as the current
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
  (p_rate_id                              IN     NUMBER
  ,p_object_version_NUMBER                IN     NUMBER
  )      RETURN BOOLEAN;
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
--   When attempting to call the lock the object version NUMBER (if defined)
--   is mandatory.
--
-- In Parameters:
--   The arguments to the Lck process are the primary key(s) which uniquely
--   identify the row and the object version NUMBER of row.
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
--   2) The row which is required to be locked doesn't exist IN the HR Schema.
--      This error is trapped and reported using the message name
--      'HR_7220_INVALID_PRIMARY_KEY'.
--   3) The row although existing IN the HR Schema has a different object
--      version NUMBER than the object version NUMBER specified.
--      This error is trapped and reported using the message name
--      'HR_7155_OBJECT_INVALID'.
--
-- Developer Implementation Notes:
--   For each primary key and the object version NUMBER arguments add a
--   call to hr_api.mandatory_arg_error PROCEDURE to ensure that these
--   argument values are not null.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE lck
  (p_rate_id                              IN     NUMBER
  ,p_object_version_NUMBER                IN     NUMBER
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
FUNCTION convert_args
  (p_rate_id                        IN NUMBER
  ,p_business_group_id              IN NUMBER
  ,p_parent_spine_id                IN NUMBER
  ,p_name                           IN VARCHAR2
  ,p_rate_type                      IN VARCHAR2
  ,p_rate_uom                       IN VARCHAR2
  ,p_comments                       IN VARCHAR2
  ,p_attribute_category             IN VARCHAR2
  ,p_attribute1                     IN VARCHAR2
  ,p_attribute2                     IN VARCHAR2
  ,p_attribute3                     IN VARCHAR2
  ,p_attribute4                     IN VARCHAR2
  ,p_attribute5                     IN VARCHAR2
  ,p_attribute6                     IN VARCHAR2
  ,p_attribute7                     IN VARCHAR2
  ,p_attribute8                     IN VARCHAR2
  ,p_attribute9                     IN VARCHAR2
  ,p_attribute10                    IN VARCHAR2
  ,p_attribute11                    IN VARCHAR2
  ,p_attribute12                    IN VARCHAR2
  ,p_attribute13                    IN VARCHAR2
  ,p_attribute14                    IN VARCHAR2
  ,p_attribute15                    IN VARCHAR2
  ,p_attribute16                    IN VARCHAR2
  ,p_attribute17                    IN VARCHAR2
  ,p_attribute18                    IN VARCHAR2
  ,p_attribute19                    IN VARCHAR2
  ,p_attribute20                    IN VARCHAR2
  ,p_rate_basis                     IN VARCHAR2
  ,p_asg_rate_type                  IN VARCHAR2
  ,p_object_version_number          IN NUMBER
  )
  RETURN g_rec_type;
--
END pay_pyr_shd;

 

/

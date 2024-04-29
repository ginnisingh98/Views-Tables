--------------------------------------------------------
--  DDL for Package PER_ASN_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASN_SHD" AUTHID CURRENT_USER as
/* $Header: peasnrhi.pkh 120.0.12010000.2 2008/08/06 09:03:04 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  assessment_id                     number(9),
  assessment_type_id                number(9),
  business_group_id                 number(15),
  person_id                         per_assessments.person_id%TYPE,
  assessment_group_id               number(9),
  assessment_period_start_date      date,
  assessment_period_end_date        date,
  assessment_date                   date,
  assessor_person_id                per_assessments.assessor_person_id%TYPE,
  appraisal_id                      number(9),
  group_date			    date,
  group_initiator_id		    number(9),
  comments                          varchar2(2000),   -- pseudo column
  total_score                       number,
  status                            varchar2(30),
  attribute_category                varchar2(30),
  attribute1                        varchar2(150),
  attribute2                        varchar2(150),
  attribute3                        varchar2(150),
  attribute4                        varchar2(150),
  attribute5                        varchar2(150),
  attribute6                        varchar2(150),
  attribute7                        varchar2(150),
  attribute8                        varchar2(150),
  attribute9                        varchar2(150),
  attribute10                       varchar2(150),
  attribute11                       varchar2(150),
  attribute12                       varchar2(150),
  attribute13                       varchar2(150),
  attribute14                       varchar2(150),
  attribute15                       varchar2(150),
  attribute16                       varchar2(150),
  attribute17                       varchar2(150),
  attribute18                       varchar2(150),
  attribute19                       varchar2(150),
  attribute20                       varchar2(150),
  object_version_number             number(9)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
g_tab_nam constant varchar2(30)  := 'PER_ASSESSMENTS';
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
-- Pre Conditions:
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
  p_assessment_id                      in number,
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
  p_assessment_id                      in number,
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_assessment_id                 in number,
	p_assessment_type_id            in number,
	p_business_group_id             in number,
	p_person_id                     in number,
	p_assessment_group_id           in number,
	p_assessment_period_start_date  in date,
	p_assessment_period_end_date    in date,
	p_assessment_date               in date,
	p_assessor_person_id            in number,
        p_appraisal_id                  in number,
	p_group_date                    in date,
	p_group_initiator_id            in number,
	p_comments                      in varchar2,
	p_total_score                   in number,
	p_status                        in varchar2,
	p_attribute_category            in varchar2,
	p_attribute1                    in varchar2,
	p_attribute2                    in varchar2,
	p_attribute3                    in varchar2,
	p_attribute4                    in varchar2,
	p_attribute5                    in varchar2,
	p_attribute6                    in varchar2,
	p_attribute7                    in varchar2,
	p_attribute8                    in varchar2,
	p_attribute9                    in varchar2,
	p_attribute10                   in varchar2,
	p_attribute11                   in varchar2,
	p_attribute12                   in varchar2,
	p_attribute13                   in varchar2,
	p_attribute14                   in varchar2,
	p_attribute15                   in varchar2,
	p_attribute16                   in varchar2,
	p_attribute17                   in varchar2,
	p_attribute18                   in varchar2,
	p_attribute19                   in varchar2,
	p_attribute20                   in varchar2,
	p_object_version_number         in number
	)
	Return g_rec_type;
--
end per_asn_shd;

/

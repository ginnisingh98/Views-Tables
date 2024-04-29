--------------------------------------------------------
--  DDL for Package PE_AEI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PE_AEI_SHD" AUTHID CURRENT_USER as
/* $Header: peaeirhi.pkh 120.0 2005/05/31 05:08:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------+
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------+
--
Type g_rec_type Is Record
  (
  assignment_extra_info_id          number(15),
  assignment_id                     per_assignment_extra_info.assignment_id%TYPE,
  information_type                  varchar2(40),
  request_id                        number(15),
  program_application_id            number(15),
  program_id                        number(15),
  program_update_date               date,
  aei_attribute_category            varchar2(30),
  aei_attribute1                    varchar2(150),
  aei_attribute2                    varchar2(150),
  aei_attribute3                    varchar2(150),
  aei_attribute4                    varchar2(150),
  aei_attribute5                    varchar2(150),
  aei_attribute6                    varchar2(150),
  aei_attribute7                    varchar2(150),
  aei_attribute8                    varchar2(150),
  aei_attribute9                    varchar2(150),
  aei_attribute10                   varchar2(150),
  aei_attribute11                   varchar2(150),
  aei_attribute12                   varchar2(150),
  aei_attribute13                   varchar2(150),
  aei_attribute14                   varchar2(150),
  aei_attribute15                   varchar2(150),
  aei_attribute16                   varchar2(150),
  aei_attribute17                   varchar2(150),
  aei_attribute18                   varchar2(150),
  aei_attribute19                   varchar2(150),
  aei_attribute20                   varchar2(150),
  aei_information_category          varchar2(30),
  aei_information1                  varchar2(150),
  aei_information2                  varchar2(150),
  aei_information3                  varchar2(150),
  aei_information4                  varchar2(150),
  aei_information5                  varchar2(150),
  aei_information6                  varchar2(150),
  aei_information7                  varchar2(150),
  aei_information8                  varchar2(150),
  aei_information9                  varchar2(150),
  aei_information10                 varchar2(150),
  aei_information11                 varchar2(150),
  aei_information12                 varchar2(150),
  aei_information13                 varchar2(150),
  aei_information14                 varchar2(150),
  aei_information15                 varchar2(150),
  aei_information16                 varchar2(150),
  aei_information17                 varchar2(150),
  aei_information18                 varchar2(150),
  aei_information19                 varchar2(150),
  aei_information20                 varchar2(150),
  aei_information21                 varchar2(150),
  aei_information22                 varchar2(150),
  aei_information23                 varchar2(150),
  aei_information24                 varchar2(150),
  aei_information25                 varchar2(150),
  aei_information26                 varchar2(150),
  aei_information27                 varchar2(150),
  aei_information28                 varchar2(150),
  aei_information29                 varchar2(150),
  aei_information30                 varchar2(150),
  object_version_number             number(9)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                       -- Global record definition
g_called_from_form   boolean := FALSE;       -- Global flag set to true by forms
--                                              code calling the RH. If true,
--                                              flexfield validation is not
--                                              performed.
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
  p_assignment_extra_info_id           in number,
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
  p_assignment_extra_info_id           in number,
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
	p_assignment_extra_info_id      in number,
	p_assignment_id                 in number,
	p_information_type              in varchar2,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
	p_aei_attribute_category        in varchar2,
	p_aei_attribute1                in varchar2,
	p_aei_attribute2                in varchar2,
	p_aei_attribute3                in varchar2,
	p_aei_attribute4                in varchar2,
	p_aei_attribute5                in varchar2,
	p_aei_attribute6                in varchar2,
	p_aei_attribute7                in varchar2,
	p_aei_attribute8                in varchar2,
	p_aei_attribute9                in varchar2,
	p_aei_attribute10               in varchar2,
	p_aei_attribute11               in varchar2,
	p_aei_attribute12               in varchar2,
	p_aei_attribute13               in varchar2,
	p_aei_attribute14               in varchar2,
	p_aei_attribute15               in varchar2,
	p_aei_attribute16               in varchar2,
	p_aei_attribute17               in varchar2,
	p_aei_attribute18               in varchar2,
	p_aei_attribute19               in varchar2,
	p_aei_attribute20               in varchar2,
	p_aei_information_category      in varchar2,
	p_aei_information1              in varchar2,
	p_aei_information2              in varchar2,
	p_aei_information3              in varchar2,
	p_aei_information4              in varchar2,
	p_aei_information5              in varchar2,
	p_aei_information6              in varchar2,
	p_aei_information7              in varchar2,
	p_aei_information8              in varchar2,
	p_aei_information9              in varchar2,
	p_aei_information10             in varchar2,
	p_aei_information11             in varchar2,
	p_aei_information12             in varchar2,
	p_aei_information13             in varchar2,
	p_aei_information14             in varchar2,
	p_aei_information15             in varchar2,
	p_aei_information16             in varchar2,
	p_aei_information17             in varchar2,
	p_aei_information18             in varchar2,
	p_aei_information19             in varchar2,
	p_aei_information20             in varchar2,
	p_aei_information21             in varchar2,
	p_aei_information22             in varchar2,
	p_aei_information23             in varchar2,
	p_aei_information24             in varchar2,
	p_aei_information25             in varchar2,
	p_aei_information26             in varchar2,
	p_aei_information27             in varchar2,
	p_aei_information28             in varchar2,
	p_aei_information29             in varchar2,
	p_aei_information30             in varchar2,
	p_object_version_number         in number
	)
	Return g_rec_type;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< set_called_from_form >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to set the global g_called_from_form which controls
--   the execution of the df and ddf data validation. When set the df and ddf
--   validation is bypassed.
--
-- Pre Conditions:
--   This is a public function
--
-- In Parameters:
--
-- Post Success:
--   The global variable is set.
--
-- Post Failure:
--   No failure condition exists.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure set_called_from_form
        ( p_flag    in boolean );
--
end pe_aei_shd;

 

/

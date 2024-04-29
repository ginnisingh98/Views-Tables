--------------------------------------------------------
--  DDL for Package PQP_VRI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VRI_SHD" AUTHID CURRENT_USER as
/* $Header: pqvrirhi.pkh 120.0.12010000.2 2008/08/08 07:24:24 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (veh_repos_extra_info_id         number(15)
  ,vehicle_repository_id           number(15)
  ,information_type                varchar2(40)
  ,vrei_attribute_category         varchar2(150)
  ,vrei_attribute1                 varchar2(150)
  ,vrei_attribute2                 varchar2(150)
  ,vrei_attribute3                 varchar2(150)
  ,vrei_attribute4                 varchar2(150)
  ,vrei_attribute5                 varchar2(150)
  ,vrei_attribute6                 varchar2(150)
  ,vrei_attribute7                 varchar2(150)
  ,vrei_attribute8                 varchar2(150)
  ,vrei_attribute9                 varchar2(150)
  ,vrei_attribute10                varchar2(150)
  ,vrei_attribute11                varchar2(150)
  ,vrei_attribute12                varchar2(150)
  ,vrei_attribute13                varchar2(150)
  ,vrei_attribute14                varchar2(150)
  ,vrei_attribute15                varchar2(150)
  ,vrei_attribute16                varchar2(150)
  ,vrei_attribute17                varchar2(150)
  ,vrei_attribute18                varchar2(150)
  ,vrei_attribute19                varchar2(150)
  ,vrei_attribute20                varchar2(150)
  ,vrei_information_category       varchar2(150)
  ,vrei_information1               varchar2(150)
  ,vrei_information2               varchar2(150)
  ,vrei_information3               varchar2(150)
  ,vrei_information4               varchar2(150)
  ,vrei_information5               varchar2(150)
  ,vrei_information6               varchar2(150)
  ,vrei_information7               varchar2(150)
  ,vrei_information8               varchar2(150)
  ,vrei_information9               varchar2(150)
  ,vrei_information10              varchar2(150)
  ,vrei_information11              varchar2(150)
  ,vrei_information12              varchar2(150)
  ,vrei_information13              varchar2(150)
  ,vrei_information14              varchar2(150)
  ,vrei_information15              varchar2(150)
  ,vrei_information16              varchar2(150)
  ,vrei_information17              varchar2(150)
  ,vrei_information18              varchar2(150)
  ,vrei_information19              varchar2(150)
  ,vrei_information20              varchar2(150)
  ,vrei_information21              varchar2(150)
  ,vrei_information22              varchar2(150)
  ,vrei_information23              varchar2(150)
  ,vrei_information24              varchar2(150)
  ,vrei_information25              varchar2(150)
  ,vrei_information26              varchar2(150)
  ,vrei_information27              varchar2(150)
  ,vrei_information28              varchar2(150)
  ,vrei_information29              varchar2(150)
  ,vrei_information30              varchar2(150)
  ,object_version_number           number(9)
  ,request_id                      number(15)
  ,program_application_id          number(15)
  ,program_id                      number(15)
  ,program_update_date             date
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
-- Global table name
g_tab_nam  constant varchar2(30) := 'PQP_VEH_REPOS_EXTRA_INFO';
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
  (p_veh_repos_extra_info_id              in     number
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
  (p_veh_repos_extra_info_id              in     number
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
  (p_veh_repos_extra_info_id        in number
  ,p_vehicle_repository_id          in number
  ,p_information_type               in varchar2
  ,p_vrei_attribute_category        in varchar2
  ,p_vrei_attribute1                in varchar2
  ,p_vrei_attribute2                in varchar2
  ,p_vrei_attribute3                in varchar2
  ,p_vrei_attribute4                in varchar2
  ,p_vrei_attribute5                in varchar2
  ,p_vrei_attribute6                in varchar2
  ,p_vrei_attribute7                in varchar2
  ,p_vrei_attribute8                in varchar2
  ,p_vrei_attribute9                in varchar2
  ,p_vrei_attribute10               in varchar2
  ,p_vrei_attribute11               in varchar2
  ,p_vrei_attribute12               in varchar2
  ,p_vrei_attribute13               in varchar2
  ,p_vrei_attribute14               in varchar2
  ,p_vrei_attribute15               in varchar2
  ,p_vrei_attribute16               in varchar2
  ,p_vrei_attribute17               in varchar2
  ,p_vrei_attribute18               in varchar2
  ,p_vrei_attribute19               in varchar2
  ,p_vrei_attribute20               in varchar2
  ,p_vrei_information_category      in varchar2
  ,p_vrei_information1              in varchar2
  ,p_vrei_information2              in varchar2
  ,p_vrei_information3              in varchar2
  ,p_vrei_information4              in varchar2
  ,p_vrei_information5              in varchar2
  ,p_vrei_information6              in varchar2
  ,p_vrei_information7              in varchar2
  ,p_vrei_information8              in varchar2
  ,p_vrei_information9              in varchar2
  ,p_vrei_information10             in varchar2
  ,p_vrei_information11             in varchar2
  ,p_vrei_information12             in varchar2
  ,p_vrei_information13             in varchar2
  ,p_vrei_information14             in varchar2
  ,p_vrei_information15             in varchar2
  ,p_vrei_information16             in varchar2
  ,p_vrei_information17             in varchar2
  ,p_vrei_information18             in varchar2
  ,p_vrei_information19             in varchar2
  ,p_vrei_information20             in varchar2
  ,p_vrei_information21             in varchar2
  ,p_vrei_information22             in varchar2
  ,p_vrei_information23             in varchar2
  ,p_vrei_information24             in varchar2
  ,p_vrei_information25             in varchar2
  ,p_vrei_information26             in varchar2
  ,p_vrei_information27             in varchar2
  ,p_vrei_information28             in varchar2
  ,p_vrei_information29             in varchar2
  ,p_vrei_information30             in varchar2
  ,p_object_version_number          in number
  ,p_request_id                     in number
  ,p_program_application_id         in number
  ,p_program_id                     in number
  ,p_program_update_date            in date
  )
  Return g_rec_type;
--
end pqp_vri_shd;

/
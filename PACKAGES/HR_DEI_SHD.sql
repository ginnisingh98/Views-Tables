--------------------------------------------------------
--  DDL for Package HR_DEI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DEI_SHD" AUTHID CURRENT_USER as
/* $Header: hrdeirhi.pkh 120.1.12010000.2 2010/04/07 11:45:05 tkghosh ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (document_extra_info_id          number(15)
  ,person_id                       number(10)
  ,document_type_id                number(15)
  ,document_number                 varchar2(60)
  ,date_from                       date
  ,date_to                         date
  ,issued_by                       varchar2(60)
  ,issued_at                       varchar2(60)
  ,issued_date                     date
  ,issuing_authority               varchar2(60)
  ,verified_by                     number(15)
  ,verified_date                   date
  ,related_object_name             varchar2(60)
  ,related_object_id_col           varchar2(60)
  ,related_object_id               number(15)
  ,dei_attribute_category          varchar2(30)
  ,dei_attribute1                  varchar2(150)
  ,dei_attribute2                  varchar2(150)
  ,dei_attribute3                  varchar2(150)
  ,dei_attribute4                  varchar2(150)
  ,dei_attribute5                  varchar2(150)
  ,dei_attribute6                  varchar2(150)
  ,dei_attribute7                  varchar2(150)
  ,dei_attribute8                  varchar2(150)
  ,dei_attribute9                  varchar2(150)
  ,dei_attribute10                 varchar2(150)
  ,dei_attribute11                 varchar2(150)
  ,dei_attribute12                 varchar2(150)
  ,dei_attribute13                 varchar2(150)
  ,dei_attribute14                 varchar2(150)
  ,dei_attribute15                 varchar2(150)
  ,dei_attribute16                 varchar2(150)
  ,dei_attribute17                 varchar2(150)
  ,dei_attribute18                 varchar2(150)
  ,dei_attribute19                 varchar2(150)
  ,dei_attribute20                 varchar2(150)
  ,dei_attribute21                 varchar2(150)
  ,dei_attribute22                 varchar2(150)
  ,dei_attribute23                 varchar2(150)
  ,dei_attribute24                 varchar2(150)
  ,dei_attribute25                 varchar2(150)
  ,dei_attribute26                 varchar2(150)
  ,dei_attribute27                 varchar2(150)
  ,dei_attribute28                 varchar2(150)
  ,dei_attribute29                 varchar2(150)
  ,dei_attribute30                 varchar2(150)
  ,dei_information_category        varchar2(30)
  ,dei_information1                varchar2(150)
  ,dei_information2                varchar2(150)
  ,dei_information3                varchar2(150)
  ,dei_information4                varchar2(150)
  ,dei_information5                varchar2(150)
  ,dei_information6                varchar2(150)
  ,dei_information7                varchar2(150)
  ,dei_information8                varchar2(150)
  ,dei_information9                varchar2(150)
  ,dei_information10               varchar2(150)
  ,dei_information11               varchar2(150)
  ,dei_information12               varchar2(150)
  ,dei_information13               varchar2(150)
  ,dei_information14               varchar2(150)
  ,dei_information15               varchar2(150)
  ,dei_information16               varchar2(150)
  ,dei_information17               varchar2(150)
  ,dei_information18               varchar2(150)
  ,dei_information19               varchar2(150)
  ,dei_information20               varchar2(150)
  ,dei_information21               varchar2(150)
  ,dei_information22               varchar2(150)
  ,dei_information23               varchar2(150)
  ,dei_information24               varchar2(150)
  ,dei_information25               varchar2(150)
  ,dei_information26               varchar2(150)
  ,dei_information27               varchar2(150)
  ,dei_information28               varchar2(150)
  ,dei_information29               varchar2(150)
  ,dei_information30               varchar2(150)
  ,request_id                      number(15)
  ,program_application_id          number(15)
  ,program_id                      number(15)
  ,program_update_date             date
  ,object_version_number           number(9)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
-- Global table name
g_tab_nam  constant varchar2(30) := 'HR_DOCUMENT_EXTRA_INFO';
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
  (p_document_extra_info_id               in     number
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
  (p_document_extra_info_id               in     number
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
  (p_document_extra_info_id         in number
  ,p_person_id                      in number
  ,p_document_type_id               in number
  ,p_document_number                in varchar2
  ,p_date_from                      in date
  ,p_date_to                        in date
  ,p_issued_by                      in varchar2
  ,p_issued_at                      in varchar2
  ,p_issued_date                    in date
  ,p_issuing_authority              in varchar2
  ,p_verified_by                    in number
  ,p_verified_date                  in date
  ,p_related_object_name            in varchar2
  ,p_related_object_id_col          in varchar2
  ,p_related_object_id              in number
  ,p_dei_attribute_category         in varchar2
  ,p_dei_attribute1                 in varchar2
  ,p_dei_attribute2                 in varchar2
  ,p_dei_attribute3                 in varchar2
  ,p_dei_attribute4                 in varchar2
  ,p_dei_attribute5                 in varchar2
  ,p_dei_attribute6                 in varchar2
  ,p_dei_attribute7                 in varchar2
  ,p_dei_attribute8                 in varchar2
  ,p_dei_attribute9                 in varchar2
  ,p_dei_attribute10                in varchar2
  ,p_dei_attribute11                in varchar2
  ,p_dei_attribute12                in varchar2
  ,p_dei_attribute13                in varchar2
  ,p_dei_attribute14                in varchar2
  ,p_dei_attribute15                in varchar2
  ,p_dei_attribute16                in varchar2
  ,p_dei_attribute17                in varchar2
  ,p_dei_attribute18                in varchar2
  ,p_dei_attribute19                in varchar2
  ,p_dei_attribute20                in varchar2
  ,p_dei_attribute21                in varchar2
  ,p_dei_attribute22                in varchar2
  ,p_dei_attribute23                in varchar2
  ,p_dei_attribute24                in varchar2
  ,p_dei_attribute25                in varchar2
  ,p_dei_attribute26                in varchar2
  ,p_dei_attribute27                in varchar2
  ,p_dei_attribute28                in varchar2
  ,p_dei_attribute29                in varchar2
  ,p_dei_attribute30                in varchar2
  ,p_dei_information_category       in varchar2
  ,p_dei_information1               in varchar2
  ,p_dei_information2               in varchar2
  ,p_dei_information3               in varchar2
  ,p_dei_information4               in varchar2
  ,p_dei_information5               in varchar2
  ,p_dei_information6               in varchar2
  ,p_dei_information7               in varchar2
  ,p_dei_information8               in varchar2
  ,p_dei_information9               in varchar2
  ,p_dei_information10              in varchar2
  ,p_dei_information11              in varchar2
  ,p_dei_information12              in varchar2
  ,p_dei_information13              in varchar2
  ,p_dei_information14              in varchar2
  ,p_dei_information15              in varchar2
  ,p_dei_information16              in varchar2
  ,p_dei_information17              in varchar2
  ,p_dei_information18              in varchar2
  ,p_dei_information19              in varchar2
  ,p_dei_information20              in varchar2
  ,p_dei_information21              in varchar2
  ,p_dei_information22              in varchar2
  ,p_dei_information23              in varchar2
  ,p_dei_information24              in varchar2
  ,p_dei_information25              in varchar2
  ,p_dei_information26              in varchar2
  ,p_dei_information27              in varchar2
  ,p_dei_information28              in varchar2
  ,p_dei_information29              in varchar2
  ,p_dei_information30              in varchar2
  ,p_request_id                     in number
  ,p_program_application_id         in number
  ,p_program_id                     in number
  ,p_program_update_date            in date
  ,p_object_version_number          in number
  )
  Return g_rec_type;
--
end hr_dei_shd;

/

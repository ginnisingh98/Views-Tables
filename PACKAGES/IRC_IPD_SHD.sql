--------------------------------------------------------
--  DDL for Package IRC_IPD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IPD_SHD" AUTHID CURRENT_USER as
/* $Header: iripdrhi.pkh 120.0 2005/07/26 15:09:47 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (pending_data_id                 number(15)
  ,email_address                   varchar2(100)
  ,vacancy_id                      number(15)
  ,last_name                       varchar2(150)
  ,first_name                      varchar2(150)
  ,user_password                   varchar2(100)
  ,resume_file_name                varchar2(240)
  ,resume_description              varchar2(240)
  ,resume_mime_type                varchar2(30)
  ,source_type                     varchar2(30)
  ,job_post_source_name            varchar2(240)
  ,posting_content_id              number(15)
  ,person_id                       number(15)
  ,processed                       varchar2(30)
  ,sex                             varchar2(30)
  ,date_of_birth                   date
  ,per_information_category        varchar2(30)
  ,per_information1                varchar2(150)
  ,per_information2                varchar2(150)
  ,per_information3                varchar2(150)
  ,per_information4                varchar2(150)
  ,per_information5                varchar2(150)
  ,per_information6                varchar2(150)
  ,per_information7                varchar2(150)
  ,per_information8                varchar2(150)
  ,per_information9                varchar2(150)
  ,per_information10               varchar2(150)
  ,per_information11               varchar2(150)
  ,per_information12               varchar2(150)
  ,per_information13               varchar2(150)
  ,per_information14               varchar2(150)
  ,per_information15               varchar2(150)
  ,per_information16               varchar2(150)
  ,per_information17               varchar2(150)
  ,per_information18               varchar2(150)
  ,per_information19               varchar2(150)
  ,per_information20               varchar2(150)
  ,per_information21               varchar2(150)
  ,per_information22               varchar2(150)
  ,per_information23               varchar2(150)
  ,per_information24               varchar2(150)
  ,per_information25               varchar2(150)
  ,per_information26               varchar2(150)
  ,per_information27               varchar2(150)
  ,per_information28               varchar2(150)
  ,per_information29               varchar2(150)
  ,per_information30               varchar2(150)
  ,error_message                   varchar2(4000)
  ,creation_date                   date
  ,last_update_date                date
  ,allow_access                    varchar2(30)
  ,user_guid                       raw(16)
  ,visitor_resp_key                varchar2(30)
  ,visitor_resp_appl_id            number(15)
  ,security_group_key              varchar2(30)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
-- Global table name
g_tab_nam  constant varchar2(30) := 'IRC_PENDING_DATA';
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
  (p_pending_data_id                      in     number
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
  (p_pending_data_id                      in     number
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
  (p_pending_data_id                in number
  ,p_email_address                  in varchar2
  ,p_vacancy_id                     in number
  ,p_last_name                      in varchar2
  ,p_first_name                     in varchar2
  ,p_user_password                  in varchar2
  ,p_resume_file_name               in varchar2
  ,p_resume_description             in varchar2
  ,p_resume_mime_type               in varchar2
  ,p_source_type                    in varchar2
  ,p_job_post_source_name           in varchar2
  ,p_posting_content_id             in number
  ,p_person_id                      in number
  ,p_processed                      in varchar2
  ,p_sex                            in varchar2
  ,p_date_of_birth                  in date
  ,p_per_information_category       in varchar2
  ,p_per_information1               in varchar2
  ,p_per_information2               in varchar2
  ,p_per_information3               in varchar2
  ,p_per_information4               in varchar2
  ,p_per_information5               in varchar2
  ,p_per_information6               in varchar2
  ,p_per_information7               in varchar2
  ,p_per_information8               in varchar2
  ,p_per_information9               in varchar2
  ,p_per_information10              in varchar2
  ,p_per_information11              in varchar2
  ,p_per_information12              in varchar2
  ,p_per_information13              in varchar2
  ,p_per_information14              in varchar2
  ,p_per_information15              in varchar2
  ,p_per_information16              in varchar2
  ,p_per_information17              in varchar2
  ,p_per_information18              in varchar2
  ,p_per_information19              in varchar2
  ,p_per_information20              in varchar2
  ,p_per_information21              in varchar2
  ,p_per_information22              in varchar2
  ,p_per_information23              in varchar2
  ,p_per_information24              in varchar2
  ,p_per_information25              in varchar2
  ,p_per_information26              in varchar2
  ,p_per_information27              in varchar2
  ,p_per_information28              in varchar2
  ,p_per_information29              in varchar2
  ,p_per_information30              in varchar2
  ,p_error_message                  in varchar2
  ,p_creation_date                  in date
  ,p_last_update_date               in date
  ,p_allow_access                   in varchar2
  ,p_user_guid                      in raw
  ,p_visitor_resp_key               in varchar2
  ,p_visitor_resp_appl_id           in number
  ,p_security_group_key             in varchar2
  )
  Return g_rec_type;
--
end irc_ipd_shd;

 

/

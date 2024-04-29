--------------------------------------------------------
--  DDL for Package PAY_AUD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AUD_SHD" AUTHID CURRENT_USER as
/* $Header: pyaudrhi.pkh 120.0 2005/05/29 03:04:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (stat_trans_audit_id            number(15)
  ,transaction_type                varchar2(30)
  ,transaction_subtype             varchar2(30)
  ,transaction_date                date
  ,transaction_effective_date      date
  ,business_group_id               number(15)
  ,person_id                       number(9)
  ,assignment_id                   number(9)
  ,source1                         varchar2(30)
  ,source1_type                    varchar2(30)
  ,source2                         varchar2(30)
  ,source2_type                    varchar2(30)
  ,source3                         varchar2(30)
  ,source3_type                    varchar2(30)
  ,source4                         varchar2(30)
  ,source4_type                    varchar2(30)
  ,source5                         varchar2(30)
  ,source5_type                    varchar2(30)
  ,transaction_parent_id           number(15)
  ,audit_information_category      varchar2(30)
  ,audit_information1              varchar2(150)
  ,audit_information2              varchar2(150)
  ,audit_information3              varchar2(150)
  ,audit_information4              varchar2(150)
  ,audit_information5              varchar2(150)
  ,audit_information6              varchar2(150)
  ,audit_information7              varchar2(150)
  ,audit_information8              varchar2(150)
  ,audit_information9              varchar2(150)
  ,audit_information10             varchar2(150)
  ,audit_information11             varchar2(150)
  ,audit_information12             varchar2(150)
  ,audit_information13             varchar2(150)
  ,audit_information14             varchar2(150)
  ,audit_information15             varchar2(150)
  ,audit_information16             varchar2(150)
  ,audit_information17             varchar2(150)
  ,audit_information18             varchar2(150)
  ,audit_information19             varchar2(150)
  ,audit_information20             varchar2(150)
  ,audit_information21             varchar2(150)
  ,audit_information22             varchar2(150)
  ,audit_information23             varchar2(150)
  ,audit_information24             varchar2(150)
  ,audit_information25             varchar2(150)
  ,audit_information26             varchar2(150)
  ,audit_information27             varchar2(150)
  ,audit_information28             varchar2(150)
  ,audit_information29             varchar2(150)
  ,audit_information30             varchar2(150)
  ,title                           varchar2(30)
  ,object_version_number           number(9)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
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
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
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
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure lck
  (p_stat_trans_audit_id                 in     number
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
Function convert_args
  (p_stat_trans_audit_id           in number
  ,p_transaction_type               in varchar2
  ,p_transaction_subtype            in varchar2
  ,p_transaction_date               in date
  ,p_transaction_effective_date     in date
  ,p_business_group_id              in number
  ,p_person_id                      in number
  ,p_assignment_id                  in number
  ,p_source1                        in varchar2
  ,p_source1_type                   in varchar2
  ,p_source2                        in varchar2
  ,p_source2_type                   in varchar2
  ,p_source3                        in varchar2
  ,p_source3_type                   in varchar2
  ,p_source4                        in varchar2
  ,p_source4_type                   in varchar2
  ,p_source5                        in varchar2
  ,p_source5_type                   in varchar2
  ,p_transaction_parent_id          in number
  ,p_audit_information_category     in varchar2
  ,p_audit_information1             in varchar2
  ,p_audit_information2             in varchar2
  ,p_audit_information3             in varchar2
  ,p_audit_information4             in varchar2
  ,p_audit_information5             in varchar2
  ,p_audit_information6             in varchar2
  ,p_audit_information7             in varchar2
  ,p_audit_information8             in varchar2
  ,p_audit_information9             in varchar2
  ,p_audit_information10            in varchar2
  ,p_audit_information11            in varchar2
  ,p_audit_information12            in varchar2
  ,p_audit_information13            in varchar2
  ,p_audit_information14            in varchar2
  ,p_audit_information15            in varchar2
  ,p_audit_information16            in varchar2
  ,p_audit_information17            in varchar2
  ,p_audit_information18            in varchar2
  ,p_audit_information19            in varchar2
  ,p_audit_information20            in varchar2
  ,p_audit_information21            in varchar2
  ,p_audit_information22            in varchar2
  ,p_audit_information23            in varchar2
  ,p_audit_information24            in varchar2
  ,p_audit_information25            in varchar2
  ,p_audit_information26            in varchar2
  ,p_audit_information27            in varchar2
  ,p_audit_information28            in varchar2
  ,p_audit_information29            in varchar2
  ,p_audit_information30            in varchar2
  ,p_title                          in varchar2
  ,p_object_version_number          in number
  )
  Return g_rec_type;
--
end pay_aud_shd;

 

/

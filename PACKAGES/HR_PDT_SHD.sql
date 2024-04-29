--------------------------------------------------------
--  DDL for Package HR_PDT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PDT_SHD" AUTHID CURRENT_USER as
/* $Header: hrpdtrhi.pkh 120.1.12010000.1 2008/07/28 03:39:04 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (person_deployment_id            number(15)
  ,object_version_number           number(15)
  ,from_business_group_id          number(15)
  ,to_business_group_id            number(15)
  ,from_person_id                  number(15)
  ,to_person_id                    number(15)
  ,person_type_id                   number(15)
  ,start_date                      date
  ,end_date                        date
  ,deployment_reason               varchar2(30)
  ,employee_number                 varchar2(30)
  ,leaving_reason                  varchar2(30)
  ,leaving_person_type_id          number(15)
  ,permanent                       varchar2(9)       -- Increased length
  ,status                          varchar2(30)
  ,status_change_reason            varchar2(30)
  ,status_change_date              date
  ,deplymt_policy_id               number(15)
  ,organization_id                 number(15)
  ,location_id                     number(15)
  ,job_id                          number(15)
  ,position_id                     number(15)
  ,grade_id                        number(15)
  ,supervisor_id                   number(15)
  ,supervisor_assignment_id        number(15)
  ,retain_direct_reports           varchar2(9)       -- Increased length
  ,payroll_id                      number(15)
  ,pay_basis_id                    number(15)
  ,proposed_salary                 varchar2(60)
  ,people_group_id                 number(15)
  ,soft_coding_keyflex_id          number(15)
  ,assignment_status_type_id       number(15)
  ,ass_status_change_reason        varchar2(30)
  ,assignment_category             varchar2(30)
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
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
-- Global table name
g_tab_nam  constant varchar2(30) := 'HR_PERSON_DEPLOYMENTS';
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
  (p_person_deployment_id                 in     number
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
  (p_person_deployment_id                 in     number
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
  (p_person_deployment_id           in number
  ,p_object_version_number          in number
  ,p_from_business_group_id         in number
  ,p_to_business_group_id           in number
  ,p_from_person_id                 in number
  ,p_to_person_id                   in number
  ,p_person_type_id                 in number
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_deployment_reason              in varchar2
  ,p_employee_number                in varchar2
  ,p_leaving_reason                 in varchar2
  ,p_leaving_person_type_id         in number
  ,p_permanent                      in varchar2
  ,p_status                         in varchar2
  ,p_status_change_reason           in varchar2
  ,p_status_change_date             in date
  ,p_deplymt_policy_id              in number
  ,p_organization_id                in number
  ,p_location_id                    in number
  ,p_job_id                         in number
  ,p_position_id                    in number
  ,p_grade_id                       in number
  ,p_supervisor_id                  in number
  ,p_supervisor_assignment_id       in number
  ,p_retain_direct_reports          in varchar2
  ,p_payroll_id                     in number
  ,p_pay_basis_id                   in number
  ,p_proposed_salary                in varchar2
  ,p_people_group_id                in number
  ,p_soft_coding_keyflex_id         in number
  ,p_assignment_status_type_id      in number
  ,p_ass_status_change_reason       in varchar2
  ,p_assignment_category            in varchar2
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
  )
  Return g_rec_type;
--
end hr_pdt_shd;

/

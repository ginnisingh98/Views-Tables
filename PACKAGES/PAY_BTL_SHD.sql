--------------------------------------------------------
--  DDL for Package PAY_BTL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BTL_SHD" AUTHID CURRENT_USER as
/* $Header: pybtlrhi.pkh 120.2 2005/10/17 00:50:22 mkataria noship $ */

--
type segment_value is varray(30) of varchar2(150);
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (batch_line_id                   number(15)
  ,cost_allocation_keyflex_id      number(9)
  ,element_type_id                 number(9)
  ,assignment_id                   number(10)
  ,batch_id                        number(15)
  ,batch_line_status               varchar2(30)
  ,assignment_number               varchar2(30)
  ,batch_sequence                  number(9)
  ,concatenated_segments           varchar2(240)
  ,effective_date                  date
  ,element_name                    varchar2(80)
  ,entry_type                      varchar2(9)       -- Increased length
  ,reason                          varchar2(80)
  ,segment1                        varchar2(60)
  ,segment2                        varchar2(60)
  ,segment3                        varchar2(60)
  ,segment4                        varchar2(60)
  ,segment5                        varchar2(60)
  ,segment6                        varchar2(60)
  ,segment7                        varchar2(60)
  ,segment8                        varchar2(60)
  ,segment9                        varchar2(60)
  ,segment10                       varchar2(60)
  ,segment11                       varchar2(60)
  ,segment12                       varchar2(60)
  ,segment13                       varchar2(60)
  ,segment14                       varchar2(60)
  ,segment15                       varchar2(60)
  ,segment16                       varchar2(60)
  ,segment17                       varchar2(60)
  ,segment18                       varchar2(60)
  ,segment19                       varchar2(60)
  ,segment20                       varchar2(60)
  ,segment21                       varchar2(60)
  ,segment22                       varchar2(60)
  ,segment23                       varchar2(60)
  ,segment24                       varchar2(60)
  ,segment25                       varchar2(60)
  ,segment26                       varchar2(60)
  ,segment27                       varchar2(60)
  ,segment28                       varchar2(60)
  ,segment29                       varchar2(60)
  ,segment30                       varchar2(60)
  ,value_1                         varchar2(80)
  ,value_2                         varchar2(80)
  ,value_3                         varchar2(80)
  ,value_4                         varchar2(80)
  ,value_5                         varchar2(80)
  ,value_6                         varchar2(80)
  ,value_7                         varchar2(80)
  ,value_8                         varchar2(80)
  ,value_9                         varchar2(80)
  ,value_10                        varchar2(80)
  ,value_11                        varchar2(80)
  ,value_12                        varchar2(80)
  ,value_13                        varchar2(80)
  ,value_14                        varchar2(80)
  ,value_15                        varchar2(80)
  ,attribute_category              varchar2(30)
  ,attribute1                      varchar2(150)
  ,attribute2                      varchar2(150)
  ,attribute3                      varchar2(150)
  ,attribute4                      varchar2(150)
  ,attribute5                      varchar2(150)
  ,attribute6                      varchar2(150)
  ,attribute7                      varchar2(150)
  ,attribute8                      varchar2(150)
  ,attribute9                      varchar2(150)
  ,attribute10                     varchar2(150)
  ,attribute11                     varchar2(150)
  ,attribute12                     varchar2(150)
  ,attribute13                     varchar2(150)
  ,attribute14                     varchar2(150)
  ,attribute15                     varchar2(150)
  ,attribute16                     varchar2(150)
  ,attribute17                     varchar2(150)
  ,attribute18                     varchar2(150)
  ,attribute19                     varchar2(150)
  ,attribute20                     varchar2(150)
  ,entry_information_category      varchar2(30)
  ,entry_information1              varchar2(150)
  ,entry_information2              varchar2(150)
  ,entry_information3              varchar2(150)
  ,entry_information4              varchar2(150)
  ,entry_information5              varchar2(150)
  ,entry_information6              varchar2(150)
  ,entry_information7              varchar2(150)
  ,entry_information8              varchar2(150)
  ,entry_information9              varchar2(150)
  ,entry_information10             varchar2(150)
  ,entry_information11             varchar2(150)
  ,entry_information12             varchar2(150)
  ,entry_information13             varchar2(150)
  ,entry_information14             varchar2(150)
  ,entry_information15             varchar2(150)
  ,entry_information16             varchar2(150)
  ,entry_information17             varchar2(150)
  ,entry_information18             varchar2(150)
  ,entry_information19             varchar2(150)
  ,entry_information20             varchar2(150)
  ,entry_information21             varchar2(150)
  ,entry_information22             varchar2(150)
  ,entry_information23             varchar2(150)
  ,entry_information24             varchar2(150)
  ,entry_information25             varchar2(150)
  ,entry_information26             varchar2(150)
  ,entry_information27             varchar2(150)
  ,entry_information28             varchar2(150)
  ,entry_information29             varchar2(150)
  ,entry_information30             varchar2(150)
  ,date_earned                     date
  ,personal_payment_method_id      number(9)
  ,subpriority                     number
  ,effective_start_date            date
  ,effective_end_date              date
  ,object_version_number           number(9)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
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
  (p_batch_line_id                        in     number
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
  (p_batch_line_id                        in     number
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
  (p_batch_line_id                  in number
  ,p_cost_allocation_keyflex_id     in number
  ,p_element_type_id                in number
  ,p_assignment_id                  in number
  ,p_batch_id                       in number
  ,p_batch_line_status              in varchar2
  ,p_assignment_number              in varchar2
  ,p_batch_sequence                 in number
  ,p_concatenated_segments          in varchar2
  ,p_effective_date                 in date
  ,p_element_name                   in varchar2
  ,p_entry_type                     in varchar2
  ,p_reason                         in varchar2
  ,p_segment1                       in varchar2
  ,p_segment2                       in varchar2
  ,p_segment3                       in varchar2
  ,p_segment4                       in varchar2
  ,p_segment5                       in varchar2
  ,p_segment6                       in varchar2
  ,p_segment7                       in varchar2
  ,p_segment8                       in varchar2
  ,p_segment9                       in varchar2
  ,p_segment10                      in varchar2
  ,p_segment11                      in varchar2
  ,p_segment12                      in varchar2
  ,p_segment13                      in varchar2
  ,p_segment14                      in varchar2
  ,p_segment15                      in varchar2
  ,p_segment16                      in varchar2
  ,p_segment17                      in varchar2
  ,p_segment18                      in varchar2
  ,p_segment19                      in varchar2
  ,p_segment20                      in varchar2
  ,p_segment21                      in varchar2
  ,p_segment22                      in varchar2
  ,p_segment23                      in varchar2
  ,p_segment24                      in varchar2
  ,p_segment25                      in varchar2
  ,p_segment26                      in varchar2
  ,p_segment27                      in varchar2
  ,p_segment28                      in varchar2
  ,p_segment29                      in varchar2
  ,p_segment30                      in varchar2
  ,p_value_1                        in varchar2
  ,p_value_2                        in varchar2
  ,p_value_3                        in varchar2
  ,p_value_4                        in varchar2
  ,p_value_5                        in varchar2
  ,p_value_6                        in varchar2
  ,p_value_7                        in varchar2
  ,p_value_8                        in varchar2
  ,p_value_9                        in varchar2
  ,p_value_10                       in varchar2
  ,p_value_11                       in varchar2
  ,p_value_12                       in varchar2
  ,p_value_13                       in varchar2
  ,p_value_14                       in varchar2
  ,p_value_15                       in varchar2
  ,p_attribute_category             in varchar2
  ,p_attribute1                     in varchar2
  ,p_attribute2                     in varchar2
  ,p_attribute3                     in varchar2
  ,p_attribute4                     in varchar2
  ,p_attribute5                     in varchar2
  ,p_attribute6                     in varchar2
  ,p_attribute7                     in varchar2
  ,p_attribute8                     in varchar2
  ,p_attribute9                     in varchar2
  ,p_attribute10                    in varchar2
  ,p_attribute11                    in varchar2
  ,p_attribute12                    in varchar2
  ,p_attribute13                    in varchar2
  ,p_attribute14                    in varchar2
  ,p_attribute15                    in varchar2
  ,p_attribute16                    in varchar2
  ,p_attribute17                    in varchar2
  ,p_attribute18                    in varchar2
  ,p_attribute19                    in varchar2
  ,p_attribute20                    in varchar2
  ,p_entry_information_category     in varchar2
  ,p_entry_information1             in varchar2
  ,p_entry_information2             in varchar2
  ,p_entry_information3             in varchar2
  ,p_entry_information4             in varchar2
  ,p_entry_information5             in varchar2
  ,p_entry_information6             in varchar2
  ,p_entry_information7             in varchar2
  ,p_entry_information8             in varchar2
  ,p_entry_information9             in varchar2
  ,p_entry_information10            in varchar2
  ,p_entry_information11            in varchar2
  ,p_entry_information12            in varchar2
  ,p_entry_information13            in varchar2
  ,p_entry_information14            in varchar2
  ,p_entry_information15            in varchar2
  ,p_entry_information16            in varchar2
  ,p_entry_information17            in varchar2
  ,p_entry_information18            in varchar2
  ,p_entry_information19            in varchar2
  ,p_entry_information20            in varchar2
  ,p_entry_information21            in varchar2
  ,p_entry_information22            in varchar2
  ,p_entry_information23            in varchar2
  ,p_entry_information24            in varchar2
  ,p_entry_information25            in varchar2
  ,p_entry_information26            in varchar2
  ,p_entry_information27            in varchar2
  ,p_entry_information28            in varchar2
  ,p_entry_information29            in varchar2
  ,p_entry_information30            in varchar2
  ,p_date_earned                    in date
  ,p_personal_payment_method_id     in number
  ,p_subpriority                    in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_object_version_number          in number
  )
  Return g_rec_type;

-- ----------------------------------------------------------------------------
-- |-----------------------------< keyflex_comb >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure is used to return cost_allocation_keyflex_id through OUT
--  parameter.
--
-- Prerequisites:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Parameters:
--
-- Post Success:
--   CCID for COST keyflex field structure will be returned in OUT parameter.
--
-- Post Failure:
--
--   app_exception.application_exception will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

--
Procedure keyflex_comb(
    p_dml_mode               in     varchar2  default hr_api.g_varchar2,
    p_appl_short_name        in     varchar2  default hr_api.g_varchar2,
    p_flex_code              in     varchar2  default hr_api.g_varchar2,
    p_segment1               in     varchar2  default hr_api.g_varchar2,
    p_segment2               in     varchar2  default hr_api.g_varchar2,
    p_segment3               in     varchar2  default hr_api.g_varchar2,
    p_segment4               in     varchar2  default hr_api.g_varchar2,
    p_segment5               in     varchar2  default hr_api.g_varchar2,
    p_segment6               in     varchar2  default hr_api.g_varchar2,
    p_segment7               in     varchar2  default hr_api.g_varchar2,
    p_segment8               in     varchar2  default hr_api.g_varchar2,
    p_segment9               in     varchar2  default hr_api.g_varchar2,
    p_segment10              in     varchar2  default hr_api.g_varchar2,
    p_segment11              in     varchar2  default hr_api.g_varchar2,
    p_segment12              in     varchar2  default hr_api.g_varchar2,
    p_segment13              in     varchar2  default hr_api.g_varchar2,
    p_segment14              in     varchar2  default hr_api.g_varchar2,
    p_segment15              in     varchar2  default hr_api.g_varchar2,
    p_segment16              in     varchar2  default hr_api.g_varchar2,
    p_segment17              in     varchar2  default hr_api.g_varchar2,
    p_segment18              in     varchar2  default hr_api.g_varchar2,
    p_segment19              in     varchar2  default hr_api.g_varchar2,
    p_segment20              in     varchar2  default hr_api.g_varchar2,
    p_segment21              in     varchar2  default hr_api.g_varchar2,
    p_segment22              in     varchar2  default hr_api.g_varchar2,
    p_segment23              in     varchar2  default hr_api.g_varchar2,
    p_segment24              in     varchar2  default hr_api.g_varchar2,
    p_segment25              in     varchar2  default hr_api.g_varchar2,
    p_segment26              in     varchar2  default hr_api.g_varchar2,
    p_segment27              in     varchar2  default hr_api.g_varchar2,
    p_segment28              in     varchar2  default hr_api.g_varchar2,
    p_segment29              in     varchar2  default hr_api.g_varchar2,
    p_segment30              in     varchar2  default hr_api.g_varchar2,
    p_concat_segments_in     in     varchar2  default hr_api.g_varchar2,
    p_batch_line_id          in     number  default hr_api.g_number,
    p_batch_id               in     number  default hr_api.g_number,
    --
    -- OUT parameter,
    -- l_rec.cost_allocation_keyflex_id may have a new value
    --
    p_ccid                   in out nocopy  number,
    p_concat_segments_out    out    nocopy  varchar2
    );

-- ----------------------------------------------------------------------------
-- |---------------------------< get_flex_segs >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure is used to return values of segments. If segments and CCID
-- both are passed, segment values will be given preference.
--
-- In Parameters: Segment Values and CCID.
--
-- Post Success:
-- Segment values will be returned.
--
-- Post Failure:
--
--   app_exception.application_exception will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure get_flex_segs
(
p_rec  in out nocopy g_rec_type
);

end pay_btl_shd;

 

/

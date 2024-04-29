--------------------------------------------------------
--  DDL for Package PAY_SET_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SET_SHD" AUTHID CURRENT_USER as
/* $Header: pysetrhi.pkh 120.0 2005/05/29 08:39:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  element_type_id                   number(9),
  template_id                       number(9),
  classification_name               varchar2(80),
  additional_entry_allowed_flag     varchar2(30),
  adjustment_only_flag              varchar2(30),
  closed_for_entry_flag             varchar2(30),
  element_name                      varchar2(80),
  indirect_only_flag                varchar2(30),
  multiple_entries_allowed_flag     varchar2(30),
  multiply_value_flag               varchar2(30),
  post_termination_rule             varchar2(30),
  process_in_run_flag               varchar2(30),
  relative_processing_priority      number(9),
  processing_type                   varchar2(30),
  standard_link_flag                varchar2(30),
  input_currency_code               varchar2(15),
  output_currency_code              varchar2(15),
  benefit_classification_name       varchar2(80),
  description                       varchar2(240),
  qualifying_age                    number(9),        -- Increased length
  qualifying_length_of_service      number(11,2),     -- Increased length
  qualifying_units                  varchar2(30),
  reporting_name                    varchar2(80),
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
  element_information_category      varchar2(30),
  element_information1              varchar2(150),
  element_information2              varchar2(150),
  element_information3              varchar2(150),
  element_information4              varchar2(150),
  element_information5              varchar2(150),
  element_information6              varchar2(150),
  element_information7              varchar2(150),
  element_information8              varchar2(150),
  element_information9              varchar2(150),
  element_information10             varchar2(150),
  element_information11             varchar2(150),
  element_information12             varchar2(150),
  element_information13             varchar2(150),
  element_information14             varchar2(150),
  element_information15             varchar2(150),
  element_information16             varchar2(150),
  element_information17             varchar2(150),
  element_information18             varchar2(150),
  element_information19             varchar2(150),
  element_information20             varchar2(150),
  third_party_pay_only_flag         varchar2(30),
  skip_formula                      varchar2(80),
  payroll_formula_id                number(9),
  exclusion_rule_id                 number(9),
  iterative_flag                    varchar2(30),
  iterative_priority                number(9),
  iterative_formula_name            varchar2(80),
  process_mode                      varchar2(30),
  grossup_flag                      varchar2(30),
  advance_indicator                 varchar2(30),
  advance_payable                   varchar2(30),
  advance_deduction                 varchar2(30),
  process_advance_entry             varchar2(30),
  proration_group                   varchar2(80),
  proration_formula                 varchar2(80),
  recalc_event_group                varchar2(80),
  once_each_period_flag             varchar2(30),
  object_version_number             number(9)
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
Function api_updating
  (
  p_element_type_id                    in number,
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
Procedure lck
  (
  p_element_type_id                    in number,
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
Function convert_args
	(
	p_element_type_id               in number,
	p_template_id                   in number,
	p_classification_name           in varchar2,
	p_additional_entry_allowed_fla  in varchar2,
	p_adjustment_only_flag          in varchar2,
	p_closed_for_entry_flag         in varchar2,
	p_element_name                  in varchar2,
	p_indirect_only_flag            in varchar2,
	p_multiple_entries_allowed_fla  in varchar2,
	p_multiply_value_flag           in varchar2,
	p_post_termination_rule         in varchar2,
	p_process_in_run_flag           in varchar2,
	p_relative_processing_priority  in number,
	p_processing_type               in varchar2,
	p_standard_link_flag            in varchar2,
	p_input_currency_code           in varchar2,
	p_output_currency_code          in varchar2,
	p_benefit_classification_name   in varchar2,
	p_description                   in varchar2,
	p_qualifying_age                in number,
	p_qualifying_length_of_service  in number,
	p_qualifying_units              in varchar2,
	p_reporting_name                in varchar2,
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
	p_element_information_category  in varchar2,
	p_element_information1          in varchar2,
	p_element_information2          in varchar2,
	p_element_information3          in varchar2,
	p_element_information4          in varchar2,
	p_element_information5          in varchar2,
	p_element_information6          in varchar2,
	p_element_information7          in varchar2,
	p_element_information8          in varchar2,
	p_element_information9          in varchar2,
	p_element_information10         in varchar2,
	p_element_information11         in varchar2,
	p_element_information12         in varchar2,
	p_element_information13         in varchar2,
	p_element_information14         in varchar2,
	p_element_information15         in varchar2,
	p_element_information16         in varchar2,
	p_element_information17         in varchar2,
	p_element_information18         in varchar2,
	p_element_information19         in varchar2,
	p_element_information20         in varchar2,
	p_third_party_pay_only_flag     in varchar2,
	p_skip_formula                  in varchar2,
	p_payroll_formula_id            in number,
	p_exclusion_rule_id             in number,
        p_iterative_flag                in varchar2,
        p_iterative_priority            in number,
        p_iterative_formula_name        in varchar2,
        p_process_mode                  in varchar2,
        p_grossup_flag                  in varchar2,
        p_advance_indicator             in varchar2,
        p_advance_payable               in varchar2,
        p_advance_deduction             in varchar2,
        p_process_advance_entry         in varchar2,
        p_proration_group               in varchar2,
        p_proration_formula             in varchar2,
        p_recalc_event_group            in varchar2,
        p_once_each_period_flag         in varchar2,
	p_object_version_number         in number
	)
	Return g_rec_type;
--
end pay_set_shd;

 

/

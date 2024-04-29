--------------------------------------------------------
--  DDL for Package PER_CEI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CEI_SHD" AUTHID CURRENT_USER as
/* $Header: peceirhi.pkh 120.1 2006/10/18 09:02:59 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (cagr_entitlement_item_id        number(15)
  ,item_name                       varchar2(80)
  ,element_type_id                 number(15)
  ,input_value_id                  varchar2(15)
  ,column_type                     varchar2(30)
  ,column_size                     number(15)
  ,legislation_code                varchar2(30)
  ,cagr_api_id                     number(10)
  ,cagr_api_param_id               number(10)
  ,business_group_id               number(15)
  ,beneficial_rule                 varchar2(30)
  ,category_name                   varchar2(30)
  ,uom                             varchar2(30)
  ,flex_value_set_id               number(10)
  ,beneficial_formula_id           number(15)
  ,object_version_number           number(9)
  ,ben_rule_value_set_id           number(10)
  ,mult_entries_allowed_flag       varchar2(30)
  ,auto_create_entries_flag        varchar2(30) -- Added for CEI enhancement
  ,opt_id                          number(15));
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
--
--  ---------------------------------------------------------------------------
--  |---------------------< entitlement_item_in_use >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--  Check to see if the entitlement item is being used by a collective
--  agreement. If it is then it returns TRUE otherwise it returns FALSE
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_entitlement_item_id
--    p_item_name
--    p_cagr_api_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Development Use Only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
FUNCTION entitlement_item_in_use
  (p_cagr_entitlement_item_id IN per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE)
  RETURN BOOLEAN;
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
  (p_cagr_entitlement_item_id             in     number
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
  (p_cagr_entitlement_item_id             in     number,
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
  (p_cagr_entitlement_item_id       in number
  ,p_item_name                      in varchar2
  ,p_element_type_id                in number
  ,p_input_value_id                 in varchar2
  ,p_column_type                    in varchar2
  ,p_column_size                    in number
  ,p_legislation_code               in varchar2
  ,p_cagr_api_id                    in number
  ,p_cagr_api_param_id              in number
  ,p_business_group_id              in number
  ,p_beneficial_rule                in varchar2
  ,p_category_name                  in varchar2
  ,p_uom                            in varchar2
  ,p_flex_value_set_id              in number
  ,p_beneficial_formula_id          in number
  ,p_object_version_number          in number
  ,p_ben_rule_value_set_id          in number
  ,p_mult_entries_allowed_flag      in varchar2
  ,p_auto_create_entries_flag       in varchar2 -- Added for CEI enhancement
  ,p_opt_id                         in number) Return g_rec_type;
--
end per_cei_shd;

/

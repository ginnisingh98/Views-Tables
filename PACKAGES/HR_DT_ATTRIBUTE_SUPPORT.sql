--------------------------------------------------------
--  DDL for Package HR_DT_ATTRIBUTE_SUPPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DT_ATTRIBUTE_SUPPORT" AUTHID CURRENT_USER as
/* $Header: dtattsup.pkh 115.1 2002/12/09 15:38:56 apholt ship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_parameter_char >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will return the character/varchar2 parameter value to be
--   used within a business process api.
--
--   If the parameter is being changed then it is added to the internal
--   structures and used for comparison operations on future rows.
--
-- Pre-Requisities:
--   The new and current value parameters must be in a varchar2 format.
--
-- In Parameters:
--   p_effective_date_row  --> set to true if looking at the first row
--   p_parameter_name      --> specifies the parameter name
--   p_new_value           --> if on the first row then specifies the new
--                             value to be used
--   p_current_value       --> specifies the current row value
--
-- Post Success:
--   The function will be set to the correct value to be passed to
--   a BP API.
--
-- Post Failure:
--   None.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function get_parameter_char
  (p_effective_date_row       in boolean  default false
  ,p_parameter_name  in varchar2
  ,p_new_value       in varchar2 default null
  ,p_current_value   in varchar2) return varchar2;
-- ----------------------------------------------------------------------------
-- |----------------------< get_parameter_number >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will return the number parameter value to be
--   used within a business process api.
--
--   If the parameter is being changed then it is added to the internal
--   structures and used for comparison operations on future rows.
--
-- Pre-Requisities:
--   The new and current value parameters must be in a number format.
--
-- In Parameters:
--   p_effective_date_row  --> set to true if looking at the first row
--   p_parameter_name      --> specifies the parameter name
--   p_new_value           --> if on the first row then specifies the new
--                             value to be used
--   p_current_value       --> specifies the current row value
--
-- Post Success:
--   The function will be set to the correct value to be passed to
--   a BP API.
--
-- Post Failure:
--   None.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function get_parameter_number
  (p_effective_date_row       in boolean  default false
  ,p_parameter_name  in varchar2
  ,p_new_value       in number   default null
  ,p_current_value   in number) return number;
-- ----------------------------------------------------------------------------
-- |------------------------< get_parameter_date >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will return the date parameter value to be
--   used within a business process api.
--
--   If the parameter is being changed then it is added to the internal
--   structures and used for comparison operations on future rows.
--
-- Pre-Requisities:
--   The new and current value parameters must be in a date format.
--
-- In Parameters:
--   p_effective_date_row  --> set to true if looking at the first row
--   p_parameter_name      --> specifies the parameter name
--   p_new_value           --> if on the first row then specifies the new
--                             value to be used
--   p_current_value       --> specifies the current row value
--
-- Post Success:
--   The function will be set to the correct value to be passed to
--   a BP API.
--
-- Post Failure:
--   None.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function get_parameter_date
  (p_effective_date_row       in boolean  default false
  ,p_parameter_name  in varchar2
  ,p_new_value       in date     default null
  ,p_current_value   in date) return date;
-- ----------------------------------------------------------------------------
-- |-----------------------< is_current_row_changing >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function determines if any attributes/parameters are being modified.
--
--   If true is returned then at least one attribute/parameter is being
--   modified. False is returned if no modifications are taking place.
--
-- Pre-Requisities:
--   None.
--
-- In Parameters:
--   None.
--
-- Post Success:
--   A boolean value will be returned.
--
-- Post Failure:
--   None.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function is_current_row_changing return boolean;
-- ----------------------------------------------------------------------------
-- |---------------------< reset_parameter_statuses >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure will reset all of the internal attribute/parameter statuses
--   for changing parameters to true. This ensures that processing for past
--   rows can take place. This call should only be executed when the processing
--   of the current and future rows has taken place and before any past rows.
--
-- Pre-Requisities:
--   None.
--
-- In Parameters:
--
-- Post Success:
--   All internal parameters statuses are set to true.
--
-- Post Failure:
--   None.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure reset_parameter_statuses;
--
end hr_dt_attribute_support;

 

/

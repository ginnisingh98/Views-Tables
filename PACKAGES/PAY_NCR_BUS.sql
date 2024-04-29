--------------------------------------------------------
--  DDL for Package PAY_NCR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NCR_BUS" AUTHID CURRENT_USER as
/* $Header: pyncrrhi.pkh 120.0 2005/05/29 06:52:22 appldev noship $ */
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_net_calculation_rule_id already exists.
--
--  In Arguments:
--    p_net_calculation_rule_id
--
--  Post Success:
--    If the value is found this function will return the values business
--    group legislation code.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
function return_legislation_code
  (p_net_calculation_rule_id in number) return varchar2;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_date_input_value >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates the date input value for a net calculation rule -
--    this input value must be present for all rules on an accrual plan,
--    with the exception of the absence element's rule.
--
--  Prerequisites:
--
--  In Arguments:
--    p_accrual_plan_id
--    p_input_value_id
--    p_date_input_value_id
--
--  Post Success:
--    If date input value is present, processing continues.
--
--  Post Failure:
--    An error is raised if date input value is null.
--
--  Access Status:
--    Internal Development Use Only.
--
procedure chk_date_input_value (p_accrual_plan_id     in number,
                                p_input_value_id      in number,
                                p_date_input_value_id in number );
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_duplicate_rule >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks the rule is not a duplicate for a particular plan.
--
--  Prerequisites:
--
--  In Arguments:
--    p_accrual_plan_id
--    p_net_calc_rule_id
--    p_input_value_id
--    p_date_input_value_id
--
--  Post Success:
--    If duplicate not found, processing continues.
--
--  Post Failure:
--    An error is raised if duplicate is found
--
--  Access Status:
--    Internal Development Use Only.
--
procedure chk_duplicate_rule (p_accrual_plan_id     in number,
                              p_net_calc_rule_id    in number,
                              p_input_value_id      in number,
                              p_date_input_value_id in number );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.
--
-- Prerequisites:
--   This private procedure is called from ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pay_ncr_shd.g_rec_type);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all update business rules
--   validation.
--
-- Prerequisites:
--   This private procedure is called from upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For update, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pay_ncr_shd.g_rec_type);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all delete business rules
--   validation.
--
-- Prerequisites:
--   This private procedure is called from del procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For delete, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_ncr_shd.g_rec_type);
--
end pay_ncr_bus;

 

/

--------------------------------------------------------
--  DDL for Package PAY_PAP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAP_BUS" AUTHID CURRENT_USER as
/* $Header: pypaprhi.pkh 120.0 2005/05/29 07:14:36 appldev noship $ */
--
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_security_group_id >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Sets the security_group_id in CLIENT_INFO for the person's business
--   group context.
--
-- Prerequisites:
--   None,
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    Yes  Number   Person to use for
--                                                deriving the security group
--                                                context.
--
-- Post Success:
--   The security_group_id will be set in CLIENT_INFO.
--
-- Post Failure:
--   An error is raised if the person does not exist.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
--procedure set_security_group_id
--(p_accrual_plan_id       in     pay_accrual_plans.accrual_plan_id%TYPE
--);
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_accrual_plan_id already exists.
--
--  In Arguments:
--    p_accrual_plan_id
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
  (p_accrual_plan_id in number) return varchar2;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_ff_name >----------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Returns the name of a Fast Formula given an ID.  The ID is also validated
--    against the business group / legislation and given formula type.
--
--  Prerequisites:
--    None.
--
--  In Arguments:
--    p_effective_date
--    p_business_group_id
--    p_formula_id
--    p_formula_type_name
--
--  Post Success:
--    The Fast Formula name is returned.
--
--  Post Failure:
--    The Fast Formula name is returned as null.  No error is raised.
--
--  Access Status:
--    Internal Development Use Only.
--
FUNCTION return_ff_name
  (p_effective_date           IN DATE
  ,p_business_group_id        IN NUMBER
  ,p_formula_id               IN NUMBER
  ,p_formula_type_name        IN VARCHAR2) RETURN VARCHAR2;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_accrual_plan_name >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates the plan name.  The name must not be duplicated within
--    the accrual plans table; the name must not cause any clashes
--    with the element type names that the plan will create
--
--  Prerequisites:
--    None.
--
--  In Arguments:
--    p_accrual_plan_id
--    p_accrual_plan_name
--    p_business_group_id
--
--  Post Success:
--    If no clashing plan name is found, processing continues.
--
--  Post Failure:
--    An error is raised if a clashing plan name is found.
--
--  Access Status:
--    Internal Development Use Only.
--
PROCEDURE chk_accrual_plan_name
  (p_accrual_plan_id       IN NUMBER
  ,p_accrual_plan_name     IN VARCHAR2
  ,p_business_group_id     IN NUMBER);
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_accrual_category >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates the accrual category exists in the lookup and that it is
--    effective as of the session date.
--
--  Prerequisites:
--    None.
--
--  In Arguments:
--    p_effective_date
--    p_accrual_plan_id
--    p_object_version_number
--    p_accrual_category
--
--  Post Success:
--    If the lookup exists and is valid, processing continues.
--
--  Post Failure:
--    An error is raised and processing stops.
--
--  Access Status:
--    Internal Development Use Only.
--
PROCEDURE chk_accrual_category
  (p_effective_date           IN DATE
  ,p_accrual_plan_id          IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_accrual_category         IN VARCHAR2);
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_accrual_start >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates the accrual start exists in the lookup and that it is
--    effective as of the session date.
--
--  Prerequisites:
--    None.
--
--  In Arguments:
--    p_effective_date
--    p_accrual_plan_id
--    p_object_version_number
--    p_accrual_start
--
--  Post Success:
--    If the lookup exists and is valid, processing continues.
--
--  Post Failure:
--    An error is raised and processing stops.
--
--  Access Status:
--    Internal Development Use Only.
--
PROCEDURE chk_accrual_start
  (p_effective_date           IN DATE
  ,p_accrual_plan_id          IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_accrual_start            IN VARCHAR2);
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_accrual_units_of_measure >--------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates the accrual UOM exists in the lookup and that it is
--    effective as of the session date.
--
--  Prerequisites:
--    None.
--
--  In Arguments:
--    p_effective_date
--    p_accrual_plan_id
--    p_object_version_number
--    p_accrual_units_of_measure
--
--  Post Success:
--    If the lookup exists and is valid, processing continues.
--
--  Post Failure:
--    An error is raised and processing stops.
--
--  Access Status:
--    Internal Development Use Only.
--
PROCEDURE chk_accrual_units_of_measure
  (p_effective_date           IN DATE
  ,p_accrual_plan_id          IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_accrual_units_of_measure IN VARCHAR2);
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_accrual_formula_id >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the formula exists in FF formulas, that it is set to
--    the correct formula type and that it is effective at the session date.
--
--  Prerequisites:
--    None.
--
--  In Arguments:
--    p_effective_date
--    p_accrual_plan_id
--    p_object_version_number
--    p_business_group_id
--    p_accrual_formula_id
--
--  Post Success:
--    If the formula is vald, processing continues.
--
--  Post Failure:
--    An error is raised and processing no longer continues.
--
--  Access Status:
--    Internal Development Use Only.
--
PROCEDURE chk_accrual_formula_id
  (p_effective_date           IN DATE
  ,p_accrual_plan_id          IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_business_group_id        IN NUMBER
  ,p_accrual_formula_id       IN NUMBER);
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_co_formula_id >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the formula exists in FF formulas, that it is set to
--    the correct formula type and that it is effective at the session date.
--    If a seeded formula is used, it is also validated for compatibility
--    against the accrual formula.
--
--  Prerequisites:
--    p_accrual_formula_id has already been validated.
--
--  In Arguments:
--    p_effective_date
--    p_accrual_plan_id
--    p_object_version_number
--    p_business_group_id
--    p_accrual_formula_id
--    p_co_formula_id
--
--  Post Success:
--    If the formula is vald, processing continues.
--
--  Post Failure:
--    An error is raised and processing no longer continues.
--
--  Access Status:
--    Internal Development Use Only.
--
PROCEDURE chk_co_formula_id
  (p_effective_date           IN DATE
  ,p_accrual_plan_id          IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_business_group_id        IN NUMBER
  ,p_accrual_formula_id       IN NUMBER
  ,p_co_formula_id            IN NUMBER);
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_pto_input_value_id >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the nominated absence element is a valid input value
--    and has a corresponding absence type.
--
--  Prerequisites:
--    p_accrual_units_of_measure has been validated successfully.
--
--  In Arguments:
--    p_accrual_plan_id
--    p_object_version_number
--    p_pto_input_value_id
--    p_business_group_id
--    p_accrual_units_of_measure
--
--  Post Success:
--    If no error is found, processing continues.
--
--  Post Failure:
--    An error is raised and processing no longer continues.
--
--  Access Status:
--    Internal Development Use Only.
--
PROCEDURE chk_pto_input_value_id
  (p_accrual_plan_id          IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_pto_input_value_id       IN NUMBER
  ,p_business_group_id        IN NUMBER
  ,p_accrual_units_of_measure IN VARCHAR2);
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_defined_balance_id >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the defined balance is valid and that it is compatible
--    with the Accrual formula.
--
--  Prerequisites:
--    p_accrual_formula_id has already been successfully validated.
--
--  In Arguments:
--    p_effective_date
--    p_accrual_plan_id
--    p_object_version_number
--    p_business_group_id
--    p_accrual_formula_id
--    p_defined_balance_id
--
--  Out Arguments:
--    p_check_accrual_ff
--
--  Post Success:
--    If no error is found, processing continues.  p_check_accrual_ff is set
--    when a non-core accrual FF is being used and the defined balance is
--    being set for the first time.  This warns about the importance of
--    using a balance compatible accrual FF.
--
--  Post Failure:
--    An error is raised and processing stops.
--
--  Access Status:
--    Internal Development Use Only.
--
PROCEDURE chk_defined_balance_id
  (p_effective_date           IN  DATE
  ,p_accrual_plan_id          IN  NUMBER
  ,p_object_version_number    IN  NUMBER
  ,p_business_group_id        IN  NUMBER
  ,p_accrual_formula_id       IN  NUMBER
  ,p_defined_balance_id       IN  NUMBER
  ,p_check_accrual_ff         OUT NOCOPY BOOLEAN);
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_ineligible_period_type >----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates the ineligible period type exists in the lookup and that it is
--    effective as of the session date.
--
--  Prerequisites:
--    None.
--
--  In Arguments:
--    p_effective_date
--    p_accrual_plan_id
--    p_object_version_number
--    p_ineligible_period_type
--
--  Post Success:
--    If the lookup exists and is valid, processing continues.
--
--  Post Failure:
--    An error is raised and processing stops.
--
--  Access Status:
--    Internal Development Use Only.
--
PROCEDURE chk_ineligible_period_type
  (p_effective_date           IN DATE
  ,p_accrual_plan_id          IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_ineligible_period_type   IN VARCHAR2);
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_ineligibility_formula_id >--------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the formula exists in FF formulas, that it is set to
--    the correct formula type and that it is effective at the session date.
--
--  Prerequisites:
--    None.
--
--  In Arguments:
--    p_effective_date
--    p_accrual_plan_id
--    p_object_version_number
--    p_business_group_id
--    p_ineligibility_formula_id
--
--  Post Success:
--    If the formula is vald, processing continues.
--
--  Post Failure:
--    An error is raised and processing no longer continues.
--
--  Access Status:
--    Internal Development Use Only.
--
PROCEDURE chk_ineligibility_formula_id
  (p_effective_date           IN DATE
  ,p_accrual_plan_id          IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_business_group_id        IN NUMBER
  ,p_ineligibility_formula_id IN NUMBER);
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
--   p_effective_date.
--   A Pl/Sql record structure.
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
PROCEDURE insert_validate
  (p_effective_date   IN  DATE
  ,p_rec              IN  pay_pap_shd.g_rec_type
  ,p_check_accrual_ff OUT NOCOPY BOOLEAN);
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
--   p_effective_date
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
PROCEDURE update_validate
  (p_effective_date   IN  DATE
  ,p_rec              IN  pay_pap_shd.g_rec_type
  ,p_check_accrual_ff OUT NOCOPY BOOLEAN);
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
Procedure delete_validate(p_rec in pay_pap_shd.g_rec_type);
--
end pay_pap_bus;

 

/

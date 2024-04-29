--------------------------------------------------------
--  DDL for Package PAY_PBA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PBA_BUS" AUTHID CURRENT_USER as
/* $Header: pypbarhi.pkh 120.0 2005/05/29 07:18:02 appldev noship $ */
--
-- ---------------------------------------------------------------------------
-- |----------------------< set_security_group_id >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Sets the security_group_id in CLIENT_INFO for the appropriate business
--    group context.
--    It is only valid to call this procedure when the primary key
--    is within a buisiness group context.
--
--  Prerequisites:
--    The primary key identified by p_balance_attribute_id
--     already exists.
--
--  In Arguments:
--    p_balance_attribute_id
--
--
--  Post Success:
--    The security_group_id will be set in CLIENT_INFO.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--    An error is also raised when the primary key data is outside
--    of a buisiness group context.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
procedure set_security_group_id
  (p_balance_attribute_id                 in number
  ,p_associated_column1                   in varchar2 default null
  );
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< return_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_balance_attribute_id
--     already exists.
--
--  In Arguments:
--    p_balance_attribute_id
--
--
--  Post Success:
--    The business group's legislation code will be returned.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
FUNCTION return_legislation_code
  (p_balance_attribute_id                 in     number
  ) RETURN varchar2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_attribute_id >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to check the validity of the attribute_id
--   entered. The following rules apply
--
--    Mode     Attribute_id Result
--    ------   -----------  ---------------------------------------------------
--    USER     USER         USER row in balance_attributes
--    USER     STARTUP      USER row in balance_attributes
--    USER     GENERIC      USER row in balance_attributes
--    STARTUP  USER         Error - This mode cannot access USER attributes
--    STARTUP  STARTUP      STARTUP row in balance_attributes
--    STARTUP  GENERIC      STARTUP row in balance_attributes
--    GENERIC  USER         Error - This mode cannot access USER attributes
--    GENERIC  STARTUP      Error - This mode cannot access STARTUP attributes
--    GENERIC  GENERIC      GENERIC row in balance_attributes
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if a valid attribute_id exists.
--
-- Post Failure:
--   An application error is raised if the attribute_id does not exist.
--   entered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_attribute_id
  (p_balance_attribute_id in number
  ,p_attribute_id         in number
  ,p_business_group_id    in number default null
  ,p_legislation_code     in varchar2 default null);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_def_bal_id >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to check the validity of the attribute_id
--   entered. The following rules apply
--
--    Mode     Attribute_id Result
--    ------   -----------  ---------------------------------------------------
--    USER     USER         USER row in balance_attributes
--    USER     STARTUP      USER row in balance_attributes
--    USER     GENERIC      USER row in balance_attributes
--    STARTUP  USER         Error - This mode cannot access USER def balances
--    STARTUP  STARTUP      STARTUP row in balance_attributes
--    STARTUP  GENERIC      STARTUP row in balance_attributes
--    GENERIC  USER         Error - This mode cannot access USER def balances
--    GENERIC  STARTUP      Error - This mode cannot access STARTUP def balances
--    GENERIC  GENERIC      GENERIC row in balance_attributes
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if a valid defined_balance_id exists.
--
-- Post Failure:
--   An application error is raised if the defined_balance_id does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_def_bal_id
  (p_balance_attribute_id in number
  ,p_defined_balance_id   in number
  ,p_business_group_id    in number default null
  ,p_legislation_code     in varchar2 default null);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.
--
-- Prerequisites:
--   This private procedure is called from ins procedure.
--
-- In Parameters:
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
--   For insert, your business rules should be executed from this procedure
--   and should ideally (unless really necessary) just be straight procedure
--   or function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in pay_pba_shd.g_rec_type
  );
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
--   For delete, your business rules should be executed from this procedure
--   and should ideally (unless really necessary) just be straight procedure
--   or function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec              in pay_pba_shd.g_rec_type
  );
--
end pay_pba_bus;

 

/
